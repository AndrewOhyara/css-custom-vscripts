::GetLanguage <- function() 
{ // Returns the language of the server. A little useless for dedicated servers.
    if (IsDedicatedServer())
        return Convars.GetStr("cl_language");
    else
        return Convars.GetClientConvarValue("cl_language", 1);  // Listen server host entindex is always 1.
}

::HijackServer <- function() 
{   // Happy Days
    print("Doxing players...");
    throw "No";
    # Ent(1).Destroy(); // This literally removes the player entity and you view will be set at vector 0,0,0 (like hl2 in the citadel)
}

// NOTE: 
// CSS has sv_allow_point_servercommand set to "always"by default.
// This method won't work if the cvar is "disallow".
// TIP: Be a good boy and don't make valve add the "official" value as TF2 has.
::IssueCommandOnServer <- function(command)
{   // Executes a command on the server. Don't be a L4D2 original Helms Deep survival map developer (aka. samurai)
    local point_servercommand = Entities.CreateByClassname("point_servercommand");
    point_servercommand.AcceptInput("Command", command, null, null);
    EntFireByHandle(point_servercommand, "Kill", "", 0.01, null, null);
}

::ForceGameEnd <- function()
{   // It literally ends the current match as if it was the last round. (intermission)
    local end_game = Entities.FindByClassname(null, "game_end");
    if (!end_game)
        end_game = Entities.CreateByClassname("game_end");

    end_game.AcceptInput("EndGame", "", null, null);
}

::ForceRoundEnd <- function(reason)
{   // It ends the current round. See "ROUND END REASONS" in const.nut
    local info_map_parameters = Entities.FindByClassname(null, "info_map_parameters");
    if (!info_map_parameters)
        info_map_parameters = Entities.CreateByClassname("info_map_parameters");

    info_map_parameters.AcceptInput("FireWinCondition", reason.tostring(), null, null);
}

::GetRandomPlayer <- function() 
{   // Returns the handle of a random alive CT/TT player. 

}

// UPDATE FUNCTION

class CUpdateManager {
    static bLoaded = false // This will make sure no the Init function won't get called more than once. (Sadly it can still being modified even if it was instantiated)
    static UpdateEnt = null
    static scope = null

    constructor()
    {
        if (this.bLoaded)
            return;
    }
}

::Update <- {
    IsLoaded = false
    
    Init = function() 
    {
        if (::Update.IsLoaded || CUpdateManager["bLoaded"])
        {
            error("[Update] Init function can only be called once per map load!\n");
            return;
        }
        local update_ent = Ent("*_UpdateEnt_*");
        if (!update_ent)
        {
            update_ent = Entities.CreateByClassname("info_target");
            update_ent.KeyValueFromString("targetname", UniqueString("_UpdateEnt_"));
        }
        update_ent.ValidateScriptScope();
        update_ent.GetScriptScope()["UpdateGroup"] <- {
            /*
            "identifier" : 
            {
                func = (function instance)
                interval = 1.0
                is_disabled = false
                is_preserved = true
                last_time = 19.01
            }
            */
        };
        update_ent.GetScriptScope()["UpdateThink"] <- function() 
        {
            foreach (idx, table in UpdateGroup)
            {
                if (UpdateGroup[idx]["is_disabled"])
                    continue;

                if (Time() - UpdateGroup[idx]["last_time"] >= UpdateGroup[idx]["interval"])
                {
                    UpdateGroup[idx]["last_time"] = Time();   
                    UpdateGroup[idx]["func"]();
                }
            }
            return -1;
        };
        //update_ent.AddEFlags(1);    // EFL_KILLME 
        CUpdateManager["UpdateEnt"] <- update_ent;
        CUpdateManager["scope"] <- update_ent.GetScriptScope();
        CUpdateManager["bLoaded"] <- true;
        ::Update.IsLoaded = true;
        AddThinkToEnt(update_ent, "UpdateThink");
        local updatemanager = CUpdateManager();
    }

    Add = function(identifier, func_var, refire_interval = 1.0, start_disabled = false, preserved = true)
    {
        local update_scope = CUpdateManager["scope"]["UpdateGroup"];
        if (identifier in update_scope)
        {
            error("[Update] The identifier " + identifier + " is already added.\n");
            return;
        }
        update_scope[identifier] <- 
        {
            func = func_var
            func_name = func_var.getinfos()["name"]
            interval = ::Clamp(refire_interval, 0, 999999)
            is_disabled = start_disabled
            is_preserved = preserved
            last_time = Time()
        }
        printl("[Update] The function " + update_scope[identifier]["func_name"] + " with identifier " + identifier + " has been added successfully.");
        return true;
    }

    Remove = function(identifier) 
    {
        local update_scope = CUpdateManager["scope"]["UpdateGroup"];
        if (!(identifier in update_scope))
        {
            error("[Update] The identifier " + identifier + " doesn't exist!\n");
            return;
        }
        printl("[Update] The function " + update_scope[identifier]["func_name"] + " with identifier " + identifier + " has been removed successfully.");
        delete update_scope[identifier];
        return true;
    }

    Toggle = function(identifier) 
    {
        local update_scope = CUpdateManager["scope"]["UpdateGroup"];
        if (!(identifier in update_scope))
        {
            error("[Update] The identifier " + identifier + " doesn't exist!\n");
            return;
        }
        else if (update_scope[identifier]["is_disabled"])
        {
            update_scope[identifier]["is_disabled"] = false;
            printl("[Update] The function " + update_scope[identifier]["func_name"] + " with identifier " + identifier + " is ENABLED.");
        }
        else
        {
            update_scope[identifier]["is_disabled"] = true;
            printl("[Update] The function " + update_scope[identifier]["func_name"] + " with identifier " + identifier + " is DISABLED.");
        }
        return true;
    }

    GetInterval = function(identifier) 
    {
        local update_scope = CUpdateManager["scope"]["UpdateGroup"];
        if (!(identifier in update_scope))
        {
            error("[Update] The identifier " + identifier + " doesn't exist!\n");
            return;
        }
        return update_scope[identifier]["interval"];
    }

    SetInterval = function(identifier, new_interval)
    {
        local update_scope = CUpdateManager["scope"]["UpdateGroup"];
        if (!(identifier in update_scope))
        {
            error("[Update] The identifier " + identifier + " doesn't exist!\n");
            return;
        }
        update_scope[identifier]["interval"] = new_interval;
        update_scope[identifier]["last_time"] = Time();
        printl("[Update] The function " + update_scope[identifier]["func_name"] + " with identifier " + identifier + " has set its interval to " + new_interval);
        return true;
    }
}

// HOOKS
class CHookManager {
    static bLoaded = false   // This will make sure no the Init function won't get called more than once. (Sadly it can still being modified even if it was instantiated)
}

::Hook <- {
    FuncEvents = {
        /*
        round_start = 
        {
            "identifier" : function_instance
        }
        OnTakeDamage =
        {
            "identifier" :
            {
                func = function_instance

            }
        }
        */
    }
    Events = {
        /*
        OnGameEvent_round_start = function(params)
        {
            
        }
        */
    }

    Init = function() 
    {
        if ("CHookManager" in getroottable() && getroottable()["CHookManager"]["bLoaded"])
        {
            error("[Hook] Init function can only be called once per map load!\n");
            return;
        }



        if ("CHookManager" in getroottable())
        {
            getroottable()["CHookManager"]["bLoaded"] <- true;
            local hookinstance = CHookManager();
        }
    }

    Add = function(eventname, identifier, func)    // Should i validate the eventname?
    {

        if (!(eventname in ::Hook.FuncEvents))
            ::Hook.FuncEvents[eventname] <- {};

        
        if (identifier in ::Hook.FuncEvents[eventname])
        {
            error("[Hook] The identifier " + identifier + " is already added in " + eventname + " table!\n");
            return;
        }
        ::Hook.FuncEvents[eventname][identifier] <- func;

        
        local eventfunc = "OnGameEvent_" + eventname;
        if (eventname.tolower() == "OnTakeDamage")
            eventfunc = "OnScriptHook_" + eventname;

        if (!(eventfunc in ::Hook.Events))
        {
            ::Hook.Events[eventfunc] <- function(params)
            {
                foreach (idx, val in ::Hook.FuncEvents[eventname]) 
                    val(params);
            }
        }
        __CollectGameEventCallbacks(::Hook.Events); // XD
    }

    Remove = function(eventname, identifier)
    {
        if (!(eventname in ::Hook.FuncEvents))
        {
            error("[Hook] The eventname " + eventname + " is not registred!\n");
            return;
        }
        else if (identifier in ::Hook.FuncEvents[eventname])
            delete ::Hook.FuncEvents[eventname][identifier];

        # TODO: Find a way to clean this table without messing up the vscript event hook table
        // If we are removing a hook, it means the OnGameEvent_ function was added.
        /*local eventfunc = "OnGameEvent_" + eventname;
        if (eventname.tolower() == "OnTakeDamage")
            eventfunc = "OnScriptHook_" + eventname;

        if (::Hook.FuncEvents[eventname].len() <= 0)
        {
            delete::Hook.Events[eventfunc];
            __CollectGameEventCallbacks(::Hook.Events);
        }*/
    }

    DumpTable = function() 
    {
        ::DeepPrintTable(::Hook);
    }
}

::CustomFog <- {
    FogGroup = []

    GetFogCount = function() 
    {
        return ::CustomFog.FogGroup.len();
    }

    Add = function() 
    {
        
    }

    Remove = function() 
    {
        
    }

}


class CCustomCvar {
    static bLoaded = false;
    static valid_types = ["integer", "float", "string"];
    _type = null;
    name = null;
    value = null;
    min_value = null;
    max_value = null;
    default_value = null;

    constructor(cvarname, cvar_val, cvar_min_val, cvar_max_val, cvar_default_val)
    {
        local val_type = typeof cvar_val;
        if (valid_types.find(val_type) == null)
        {
            error("[CustomCvars] The data type of the the cvar value is invalid. [expecting: integer, float, string]\n");
            return;
        }
        else if ("CustomCvars" in getroottable() && ::CustomCvars["CvarTable"].find(cvarname) != null)
        {
            error("[CustomCvars] The cvar " +cvarname+" is already added!\n");
            return;
        }
        name = cvarname;
        value = cvar_val;
        min_value = cvar_min_val;
        max_value = cvar_max_val;
        default_value = cvar_default_val
        if ("CustomCvars" in getroottable())
            ::CustomCvars["CvarTable"].append(this);
    }
}

::CustomCvars <- {
    CvarTable = []
    Init = function() 
    {
        if ("CCustomCvar" in getroottable() && getroottable()["CCustomCvar"]["bLoaded"])
        {
            error("[CustomCvars] Init function can only be called once per map load!\n");
            return;
        }



        if ("CCustomCvar" in getroottable())
        {
            getroottable()["CCustomCvar"]["bLoaded"] <- true;
            local hookinstance = CCustomCvar();
        }
    }

    
}

class CCustomConfigs {

}


// INIT
::Update.Init();


