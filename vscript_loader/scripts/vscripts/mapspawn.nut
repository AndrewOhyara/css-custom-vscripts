Msg("VSCRIPT: Running mapspawn.nut\n");
// ---------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------
g_VscriptFileOrder <- 1;                        // File counter
g_iVscriptMaxLoad <- 256;                       // Maximum allowed vscript files to be loaded
g_VscriptListFile <- "vscript_loader_list_all"; // list file path
g_VscriptFileList <- [];                        // List of vscript files
g_VscriptScopedScripts <- {};                   // Scoped scripts will be referenced by it's path here if 'scope' is not null or root
g_MapScript <- {}                               // Scope for round-only scripts (like l4d2's director_base_addon).

// ---------------------------------------------------------------------
// Excecution
// ---------------------------------------------------------------------
if (!("VscriptLoader" in getroottable()))
{
    ::VscriptLoader <- {
        Calls = 0
        Enabled = true
        ShouldLoadFiles = false
        FileLoadFinished = false
        EntityToListen = null
        RoundStartCount = 0

        function IsCheatingSession()
        {
            return developer() > 0 || Convars.GetBool("sv_cheats");
        }

        function errorl(msg)
        {   // Prints an error message with a line feed after.
            error(msg + "\n");
        }

        function IncludeScriptSafe(file, scope = null)
        {
            local gr = {data = file success = null error = null};
            try 
            {
                local status = IncludeScript(file, scope);
                gr.success = status;
                gr.error = "";
            }
            catch (ex)
            {
                gr.success = false;
                gr.error = ex;
            }
            return gr;
        }

        // Slightly modified from the VDC website. Adding support for logical entities that doesn't have an entity index
        // because they will always return 0.
        function SetDestroyCallback(entity, callback)
        {
            entity.ValidateScriptScope();
            local original_scope = entity.GetScriptScope();
            original_scope.setdelegate({}.setdelegate({
                    parent   = original_scope.getdelegate()
                    id       = entity.GetScriptId()
                    index    = entity.entindex()
                    callback = callback
                    _get = function(k)
                    {
                        return parent[k]
                    }
                    _delslot = function(k)
                    {
                        if (k == id)
                        {
                            entity = EntIndexToHScript(index);
                            local scope;
                            if (!entity || !entity.IsValid())
                                scope = original_scope;
                            else                        
                                scope = entity.GetScriptScope();

                            scope.self <- entity;
                            callback.pcall(scope);
                        }
                        delete parent[k]
                    }
                })
            )
        }

        function ConstructEntity(eventname = "")
        {
            if (EntityToListen != null && EntityToListen.IsValid())
                return;

            if (IsCheatingSession())
                printl("[VSCRIPT LOADER][DEBUG] Constructing EntityToListen in event " + eventname);

            EntityToListen = Entities.CreateByClassname("logic_timer");
            EntityToListen.KeyValueFromString("targetname", UniqueString("dummy_logictimer_"));
            NetProps.SetPropBool(EntityToListen, "m_bForcePurgeFixedupStrings", true);
            SetDestroyCallback(EntityToListen, function()
            {
                ///// TRICK TO LISTEN WHEN A SERVER CLOSES OR CHANGESLEVEL /////
                // First() doesn't always return worldspawn if we don't restart from the very first round for listen servers.
                // it can return the host instead.
                // local world = Entities.First();   
                local world = Entities.FindByClassname(null, "worldspawn");
                // To avoid loading round-only scripts again if the map changes or server closes because the VM is still alive for a few ms.
                if (!world || !world.IsValid())
                {
                    if (::VscriptLoader.IsCheatingSession())
                        printl("[VSCRIPT LOADER][DEBUG] Server shutdown or changelevel detected. Not reloading scripts\n\t" +
                                "worldspawn handle: " + world + " | mapname: " + GetMapName() + " | time: " + Time() + " | frame: " + GetFrameCount());

                    return;
                }

                if ("g_MapScript" in getroottable() && g_MapScript != null) 
                {
                    g_MapScript.clear(); // clean the table
                    ::VscriptLoader.LoadRoundOnlyFiles();
                }
                if (::VscriptLoader.IsCheatingSession())
                    printl("[VSCRIPT LOADER][DEBUG] EntityToListen HAS BEEN REMOVED, HOPE THIS WORKS BEFORE STARTING A NEW ROUND");
            })
        }

        function OnGameEvent_round_start(params)
        {
            ConstructEntity("round_start");
            RoundStartCount++;
        }

        function OnGameEvent_dod_round_start(params)
        {   // Day of Defeat Source round_start support!
            ConstructEntity("dod_round_start");
            RoundStartCount++;
        }

        // TF2 SUPPORT
        function OnGameEvent_teamplay_round_start(params)
        {	// Team Fortress 2 round_start support!
            ConstructEntity("teamplay_round_start");
            RoundStartCount++;
        }

        function OnGameEvent_scorestats_accumulated_update(params)
        {   // CLEANUP EVENT
            if (EntityToListen != null && EntityToListen.IsValid())
            {
                printl("[VSCRIPT LOADER][DEBUG] Killing EntityToListen in scorestats_accumulated_update");
                EntityToListen.Kill();
            }
        }

        function OnGameEvent_recalculate_holidays(params)
        {   // CLEANUP EVENT FOR MVM?
            if ("GetRoundState" in getroottable() && typeof GetRoundState == "native function" && GetRoundState() == 3)
            {
                if (EntityToListen != null && EntityToListen.IsValid())
                {
                    printl("[VSCRIPT LOADER][DEBUG] Killing EntityToListen in recalculate_holidays");
                    EntityToListen.Kill();
                }
            }
        }
        // TF2 SUPPORT

        function AddScript(script_data)
        {
            if (typeof script_data != "table" || script_data.len() == 0)
                return;

            g_VscriptFileList.push(script_data);
            return true;
        }

        function LoadFiles()
        {
            if (!ShouldLoadFiles || FileLoadFinished || Calls > 1)
                return;

            local loaded_count = 0;
            for (local i = 0; i < g_VscriptFileList.len() && g_VscriptFileOrder <= g_iVscriptMaxLoad; i++)
            {
                local script = g_VscriptFileList[i];
                local path = "path" in script ? script["path"] : null;
                local scope = "scope" in script ? script["scope"] : null;
                local round_only = "round_only" in script ? !!script["round_only"] : false;

                if (!scope)
                    scope = getroottable();

                if (!path)
                {
                    printl("[VSCRIPT LOADER] File " + g_VscriptFileOrder + " has no 'path'. Skipping...");
                    g_VscriptFileOrder++;
                    continue;
                }

                if (round_only)
                    scope = getroottable()["g_MapScript"];

                local response = IncludeScriptSafe(path, scope);
                if (path.find(".nut") == null || !endswith(path, ".nut"))
                    path += ".nut";

                if (response.success)
                {
                    printl(">>> Loaded addon script " + path + " (Order in list: " + g_VscriptFileOrder +")");
                    if (scope != getroottable() && scope != getroottable()["g_MapScript"])
                        g_VscriptScopedScripts[path] <- scope;

                    loaded_count++;
                }
                else
                {
                    errorl("[VSCRIPT LOADER] Couldn't load file " + path + " (Order in list: " + g_VscriptFileOrder +")\n\tError: " + response.error);
                }
                g_VscriptFileOrder++;
            }
            printf("[VSCRIPT LOADER] Done. %d/%d scripts loaded.\n", loaded_count, g_VscriptFileList.len());
            FileLoadFinished = true;
        }

        function LoadRoundOnlyFiles()
        {
            if (Calls < 1)
            {
                //Calls++;
                if (IsCheatingSession())
                    printl("[VSCRIPT LOADER][DEBUG] Attempt to call LoadRoundOnlyFiles() failed.")

                return;
            }

            printl("[VSCRIPT LOADER] Loading round-only scripts...");
            local round_only_order = 1;
            local round_only_loaded_count = 0;
            for (local i = 0; i < g_VscriptFileList.len() && round_only_order <= g_iVscriptMaxLoad; i++)
            {
                local script = g_VscriptFileList[i];
                local path = "path" in script ? script["path"] : null;
                local scope = "scope" in script ? script["scope"] : null;
                local round_only = "round_only" in script ? script["round_only"] : false;

                if (!path)
                {
                    printl("[VSCRIPT LOADER] File " + (i+1) + " has no 'path'. Skipping...");
                    round_only_order++;
                    continue;
                }

                if (!round_only)
                    continue;
                else
                    scope = getroottable()["g_MapScript"];

                local response = IncludeScriptSafe(path, scope);
                if (path.find(".nut") == null || !endswith(path, ".nut"))
                    path += ".nut";

                if (response.success)
                {
                    printl(">>> Loaded addon script " + path + " (Order in list: " + (i+1) +")");
                    if (scope != getroottable() && scope != getroottable()["g_MapScript"])
                        g_VscriptScopedScripts[path] <- scope;

                    round_only_loaded_count++;
                }
                else
                {
                    errorl("[VSCRIPT LOADER] Couldn't load file " + path + " (Order in list: " + (i+1) +")\n\tError: " + response.error);
                }
                round_only_order++;
            }
            round_only_order--;
            printf("[VSCRIPT LOADER] Done. %d/%d round-only scripts loaded.\n", round_only_loaded_count, round_only_order);
        }

        function Init()
        {
            local is_l4d2 = Convars.GetFloat("z_view_distance");
            if (!Enabled || is_l4d2)   // l4d2 has a built-in addon scripts loader, lol!
                return;

            local res = IncludeScriptSafe(g_VscriptListFile, getroottable());
            if (!res.success)
            {
                errorl("[VSCRIPT LOADER] Could not load list file: " + g_VscriptListFile);
                errorl("Error: " + res.error);
                return;
            }

            // Showing the list id just in case the user want to reassure their list is actually loading.
            if ("g_VscriptListId" in getroottable())
                printl("[VSCRIPT LOADER] Active list ID: " + g_VscriptListId);
            else 
                printl("[VSCRIPT LOADER] No list ID found in " + g_VscriptListFile);

            // The script stops here if the list is empty.
            if (!g_VscriptFileList || g_VscriptFileList.len() == 0)
            {
                errorl("[VSCRIPT LOADER] Script list empty. Not loading.")
                return;
            }
            ShouldLoadFiles = true;
            LoadFiles();
            ConstructEntity("::VscriptLoader.Init()");

            Calls++;
        }
    }
}
__CollectGameEventCallbacks(::VscriptLoader);
::VscriptLoader.Init();


