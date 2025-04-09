local clienttable = null;
if ("MultiJump" in this)
{
    if (::MultiJump.IsValidSafe(::MultiJump.ThinkEnt))
        ::MultiJump.ThinkEnt.Kill();

    clienttable = ::MultiJump.Clients;
    ::MultiJump.clear();
}

::MultiJump <- {
    ThinkEnt = null
    Configs = {
        EnableScript = true
        AutoAddClients = true
        JumpLimit = 1
        JumpForce = 300
        TF2mode = false
        TF2sideForce = 265
        DoAirStop = false
        ThinkInterval = -1
        FallDamage = false
        CanClientsChangeConfigs = true
        AnnouncementInterval = 150
        DebugJumps = false
        Users = {}
    }
    Clients = {}

    GetNumTypeFromString = function(str)
    {   // Returns the number type of a string if it can be converted to int or float. 0: none - 1: integer - 2: float
        if (!str)
            return 0;

        local new_num = null;
        try {
            new_num = str.tofloat();    // Don't try this on another languages.
        } catch (exception){
            return 0;
        }
        if (floor(new_num) == new_num) // (ex. 3 != 3.1 ? integer : float)
            return 1;
        else
            return 2;

        return 0;
    }

    // NOTES: This method is slightly modified from the Custom Functions Library.
    // The assumption here is the user will never use arrays and the limit of the Users table is barely 100 PLAYERS (75 SAFE).
    // I can't help, it's just a Vscript limitation of not reading more than 16384 bytes from a file.
    SerializeTableOrArray = function(var, prefix = "", bIgnorePrefix = false)
    {   // This do the proper format for exporting an array or table by StringToFile() along with compilestring() later
        if (typeof var != "table" && typeof var != "array")
            return;

        local function HasAnyNonAlphanumericChar(str)
        {   // Returns true if the string has any non alphanumeric character (ex. [],.,?,$,%,etc)
            if (!str || typeof str != "string")
                return;

            local reg = regexp("[^_0-9a-zA-Z]+");
            if (reg.search(str) != null)
                return true;

            return false;
        }

        local function FormatToJson(var)
        {   // Returns static data types as a string for a json file (ex. table, array, int, float, class)
            local sData = null;
            local bIsFirst = true;
            switch (typeof var)
            {
                case "string":
                    sData = "\"" + var + "\"";
                    break;
                case "integer":
                case "float":
                case "bool":
                    sData = var;
                    break;
                case "Vector":
                case "QAngle":
                case "Vector2D":
                case "Vector4D":
                case "Quaternion":
                    sData = "\"" + var.ToKVString() + "\"";
                    break;
                case "table":
                case "class":
                {
                    sData = "{";
                    foreach (idx, value in var)
                    {
                        if (!bIsFirst)
                            sData += ",";
                        else
                            bIsFirst = false;

                        sData += "\"" + idx + "\":";
                        sData += ::FormatToJson(value);
                    }
                    sData += "}";
                }
                break;
                case "array":
                {
                    sData = "[";
                    for (local i = 0; i < var.len(); i++)
                    {
                        if (!bIsFirst)
                            sData += ",";
                        else
                            bIsFirst = false;

                        sData += ::FormatToJson(var[i]);
                    }
                    sData += "]";
                }
                break;
                case "instance":
                sData = "\"" + var + "\"";    // It wil return something like ([1] player)
                break;
                default:
                sData = "\"" + typeof var +"\""; // Why would you like smth like "(native function : 0x000002CF3DE48310)" in a JSON file?
            }
            return sData;
        }

        local tData = "";
        local bIsFirst = true;
        if (typeof var == "table")
        {
            tData += (bIgnorePrefix ? "" : prefix) + "{" + (bIgnorePrefix ? "" : "\n");
            foreach(idx, val in var)
            {
                if (!bIsFirst)
                    tData += (bIgnorePrefix ? "" : "\n");
                else
                    bIsFirst = false;

                tData += (bIgnorePrefix ? "" : prefix) + (bIgnorePrefix ? "" : "");
                // There's a different equal symbol for string keys (ex. "123" : true | "[U:1:216118329]" : {}).
                // It's great for storing let's say... userids as an example. though, i'd rather using steamid instead
                // but the choice is yours ofc.
                // TIP: If you inteed to get the table/value from an integer key that has been parsed in scriptdata and then compiled,
                // make sure to convert your input integer to string before asking if the key exists.
                // Ex: table = {"1" : "Hello Word"} -> myint = 1 -> if (myint.tostring() in table) <- will return true.
                local keytype = GetNumTypeFromString(idx);
                if (keytype > 0 || HasAnyNonAlphanumericChar(idx))
                tData += "\"" + idx + "\":";
                else if (keytype == 0)
                tData += idx + "=";

                if (typeof val != "table" && typeof val != "array")
                    tData += FormatToJson(val);
                else
                {
                    if (typeof val == "table")
                        tData += (bIgnorePrefix ? "" : "\n");

                    tData += ::MultiJump.SerializeTableOrArray(val);
                }
                // We dont wan't glued values and keys. It may give errors at compiling. (ex. {key = val key1 = val1} -> "{key = valkey1 = val2}").
                tData += (bIgnorePrefix ? " " : "");
            }
            tData += (bIgnorePrefix ? "" : "\n") + (bIgnorePrefix ? "" : prefix) + "}";
        }
        else
        {
            local hastables = false;
            tData +=  "[";
            for (local i = 0; i < var.len(); i++)
            {
                if (!bIsFirst)
                    tData += ",";
                else
                    bIsFirst = false;

                local value = var[i];
                if (typeof value != "table" && typeof value != "array")
                    tData += FormatToJson(value);
                else
                {
                    tData += (bIgnorePrefix ? "" : "\n");
                    if (typeof value == "table")
                        hastables = true;
                    else
                        tData += (bIgnorePrefix ? "" : prefix + "\t");

                    tData += ::MultiJump.SerializeTableOrArray(value);

                    if (hastables)
                        tData += (i == var.len() - 1 ? (bIgnorePrefix ? "" : "\n") : "");
                }
            }
            tData += (bIgnorePrefix ? "" : (hastables ? prefix : "")) + "]";
        }
        return tData;
    }

    Clamp = function(var, var_min, var_max, var_default = null)
    {   // Your typical clamp function to ensure the boundaries of your variable
        if (var_default != null && (var < var_min || var > var_max))
            var = var_default
        else if (var < var_min)
            var = var_min;
        else if (var > var_max)
            var = var_max;

        return var;
    }

    ManageConfigs = function(save = false)
    {
        local path = "multijump/";
        local filename = "multijump_configs.cfg";
        local filename_default = "multijump_configs_default.cfg";
        local file = path + filename;
        local file_default = path + filename_default;
        local existence = FileToString(file);
        local existence_default = FileToString(file_default);

        if (existence && !save)
        {
            local read_table = null;
            try {
                read_table = compilestring("return " + existence)();
                foreach (key, val in ::MultiJump.Configs)
                {
                    if (key in read_table)
                    {
                        if (key != "ThinkInterval")
                            ::MultiJump.Configs[key] = read_table[key];
                        else
                            ::MultiJump.Configs[key] = ::MultiJump.Clamp(read_table[key], -1, 1, -1);
                    }
                }
                for (local i = 1; i <= MaxClients().tointeger(); i++)
                {
                    local client = PlayerInstanceFromIndex(i);
                    if (!IsValidSafe(client))
                         continue;

                    local steamid = ::MultiJump.GetSteamID(client);
                    local userid = ::MultiJump.GetPlayerUserID(client);
                    if (steamid in ::MultiJump.Configs.Users)
                        ::MultiJump.Add(userid);
                }
            } catch (exception){
                error("[MultiJump Vscript] An exception has ocurred: " + exception + "\n");
                printl("[MultiJump Vscript] Using default settings...");
            }
        }
        else if (!existence_default || save)
        {
            StringToFile(file, ::MultiJump.SerializeTableOrArray(::MultiJump.Configs));
        }
        else if (!save)
            StringToFile(file, existence_default);
    }

    DebugPrint = function(client, context = null, vector_velocity = null)
    {
        if (!::MultiJump.Configs.DebugJumps)
            return;

        local msg = "";
        switch(context)
        {
            case "tf2jump_forward":
                msg = "TF2 MODE FORWARD";
                break;
            case "tf2jump_backwards":
                msg = "TF2 MODE BACKWARDS";
                break;
            case "tf2jump_left":
                msg = "TF2 MODE LEFT";
                break;
            case "tf2jump_right":
                msg = "TF2 MODE RIGHT";
                break;
            case "tf2jump_stop_air":
                msg = "TF2 MODE STOP IN AIR";
                break;
            case "jump_normal_script":
                msg = "NORMAL MODE";
                break;
            default:
                return;
        }
        if (vector_velocity != null && typeof vector_velocity == "Vector")
            ClientPrint(client, 3, "[" + Time() + "] APPLYING " + msg + " VELOCITY | VELOCITY RESULT: " + vector_velocity.Length());
    }

    IsValidSafe = function(ent)
    {
        return ent != null && ent.IsValid();
    }

    Init = function()
    {
        if (IsValidSafe(::MultiJump.ThinkEnt))
            return;

        local entname = "_double_jump_manager_" + GetFrameCount().tostring();
        local ent = Entities.FindByName(null, entname);
        if (!IsValidSafe(ent))
        {
            // We don't need a perserved entity. And in case the script is disabled by the server or the host, the entity won't "auto-spawn" again.
            ent = SpawnEntityFromTable("logic_script", {targetname = entname});
            ent.ValidateScriptScope();
            ent.GetScriptScope()["LastSetDebugTime"] <- Time();
            ent.GetScriptScope()["LastAnnouncementTime"] <- Time();
            ent.GetScriptScope()["JumpThinkExclusiveFunction"] <- function()
            {
                if (!::MultiJump.Configs["EnableScript"])
                    return;

                if (Time() - LastAnnouncementTime >= ::MultiJump.Configs.AnnouncementInterval && ::MultiJump.Configs.AnnouncementInterval > 0)
                {
                    LastAnnouncementTime = Time();
                    ClientPrint(null, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "This script is enabled on this server. Type \"!mj_help\" to see the commands.");
                }
                local cTable = ::MultiJump.Clients;
                foreach (steamid, table in cTable)
                {
                    local client = GetPlayerFromUserID(cTable[steamid]["Userid"]);
                    if (!::MultiJump.IsValidSafe(client))
                        continue;

                    local buttons = ::MultiJump.GetButtonMask(client);
                    local buttons_changed = cTable[steamid]["LastButton"] ^ buttons;
                    local buttons_pressed = buttons_changed & buttons;
                    local buttons_released = buttons_changed & (~buttons);

                    local is_on_ground = NetProps.GetPropInt(client, "m_hGroundEntity");
                    if (client.IsAlive() && cTable[steamid]["JumpEnabled"] && !client.IsNoclipping() && !::MultiJump.IsFreezePeriod() && !cTable[steamid]["DisabledByAdmin"])
                    {
                        // The reason we are calculating the time is because the jump from the ground still counts as a jump in air
                        // since the flag "FL_ONGROUND" it's removed from the player at the same frame we do the jump for our think interval.
                        // The lowest time i found in the calculation is: 0.0149994.
                        // The least stable amount of interval we can use after a ground jump is 0.046
                        // Being in water counts as not being on the ground.
                        if ((buttons_pressed & 2) > 0 && (Time() - cTable[steamid]["LastGroundTime"] >= 0.046) && client.GetWaterLevel() < 2 && is_on_ground == -1)
                        {
                            if (cTable[steamid]["TimesJumped"] < cTable[steamid]["JumpLimit"])
                            {
                                ::MultiJump.DoJumpOnClient(client, cTable[steamid]["JumpForce"], cTable[steamid]["TF2sideForce"], cTable[steamid]["TF2mode"], cTable[steamid]["DoAirStop"]);
                                if (::MultiJump.Configs.DebugJumps)
                                {
                                    EmitSoundOnClient("Bot.StuckSound", client);
                                    local ijumps = cTable[steamid]["TimesJumped"] + 1;
                                    ClientPrint(client, 4, "["+Time()+"] DOING JUMP | INTERVAL : " + (Time() - cTable[steamid]["LastGroundTime"]) + " | JUMPS MADE: " + ijumps + " | JUMP LIMIT " + cTable[steamid]["JumpLimit"]);
                                }
                            }
                            cTable[steamid]["TimesJumped"]++;
                            cTable[steamid]["DidJump"] = true;
                            LastSetDebugTime = Time() + 2.3;
                        }
                        if (Time() - LastSetDebugTime >= 0.1 && (!cTable[steamid]["DidJump"] && ::MultiJump.Configs.DebugJumps))
                        {
                            LastSetDebugTime = Time();
                            ClientPrint(client, 4, "VELOCITY " + client.GetAbsVelocity().Length());
                        }
                    }
                    if (is_on_ground > 0)
                    {   // This make it up for those frames the event hooks cannot cover.
                        cTable[steamid]["LastGroundTime"] = Time();
                        cTable[steamid]["TimesJumped"] = 0;
                        cTable[steamid]["DidJump"] = false;
                    }
                    cTable[steamid]["LastButton"] = buttons;
                }
                return  ::MultiJump.Clamp(::MultiJump.Configs.ThinkInterval, -1, 1, -1);
            }
            AddThinkToEnt(ent, "JumpThinkExclusiveFunction");
            ::MultiJump.ThinkEnt = ent;
        }
        ::MultiJump.ManageConfigs();
    }

    IsOnGround = function(client)
    {
        return ((client.GetFlags() & 1) > 0 ? true : false);
    }

    IsFreezePeriod = function()
    {   // Players can still jumping if they spam the jump button enough between round_end and round_start. This statement will make sure to not let them do that.
        return NetProps.GetPropBool(Entities.FindByClassname(null, "cs_gamerules"), "m_bFreezePeriod");
    }

    GetSteamID = function(client)
    {
        return NetProps.GetPropString(client, "m_szNetworkIDString");
    }

    GetPlayerUserID = function(client)
    {
        return NetProps.GetPropIntArray(Entities.FindByClassname(null, "cs_player_manager"), "m_iUserID", client.entindex());
    }

    GetButtonMask = function(client)
    {
        return NetProps.GetPropInt(client, "m_nButtons");
    }

    GetPlayerName = function(client)
    {
        return NetProps.GetPropString(client, "m_szNetname")
    }

    Add = function(userid)
    {
        local client = GetPlayerFromUserID(userid);
        if (!IsValidSafe(client) || IsPlayerABot(client))
            return;

        local steamid = ::MultiJump.GetSteamID(client);
        if (!(steamid in ::MultiJump.Clients) || steamid in ::MultiJump.Configs.Users)
        {
            ::MultiJump.Clients[steamid] <- {
                Username = ::MultiJump.GetPlayerName(client)
                Userid = userid
                TimesJumped = 0
                DidJump = false
                JumpLimit = ::MultiJump.Configs["JumpLimit"]
                JumpForce = ::MultiJump.Configs["JumpForce"]
                TF2mode = ::MultiJump.Configs["TF2mode"]
                TF2sideForce = ::MultiJump.Configs["TF2sideForce"]
                DoAirStop = ::MultiJump.Configs["DoAirStop"]
                FallDamage = ::MultiJump.Configs["FallDamage"]
                JumpEnabled = true
                LastGroundTime = Time()
                LastButton = ::MultiJump.GetButtonMask(client)
                Gravity = client.GetGravity()
                DisabledByAdmin = false
            }
            if (steamid in ::MultiJump.Configs.Users)
            {
                ::MultiJump.Clients[steamid].JumpLimit = ::MultiJump.Configs.Users[steamid]["JumpLimit"];
                ::MultiJump.Clients[steamid].JumpForce = ::MultiJump.Configs.Users[steamid]["JumpForce"];
                ::MultiJump.Clients[steamid].TF2mode = ::MultiJump.Configs.Users[steamid]["TF2mode"];
                ::MultiJump.Clients[steamid].TF2sideForce = ::MultiJump.Configs.Users[steamid]["TF2sideForce"];
                ::MultiJump.Clients[steamid].DoAirStop = ::MultiJump.Configs.Users[steamid]["DoAirStop"]
                ::MultiJump.Clients[steamid].FallDamage = ::MultiJump.Configs.Users[steamid]["FallDamage"];
                ::MultiJump.Clients[steamid].JumpEnabled = ::MultiJump.Configs.Users[steamid]["JumpEnabled"];
                ::MultiJump.Clients[steamid].DisabledByAdmin = ::MultiJump.Configs.Users[steamid]["DisabledByAdmin"];
            }
        }
        return ::MultiJump.Clients[steamid];
    }

    AddToUsersTable = function(userid)
    {   // Add a new user to the user table and saves the changes in the config file.
        local client = GetPlayerFromUserID(userid);
        if (!IsValidSafe(client) || IsPlayerABot(client))
            return;

        local steamid = ::MultiJump.GetSteamID(client);
        if (steamid in ::MultiJump.Configs.Users)
            return;

        local client_table = clone ::MultiJump.Add(userid);
        // Thanks foreach. You only had one freaking job.
        delete client_table["LastButton"];
        delete client_table["Userid"];
        delete client_table["TimesJumped"];
        delete client_table["Gravity"];
        delete client_table["LastGroundTime"];
        delete client_table["DidJump"];
        delete client_table["Username"];

        ::MultiJump.Configs.Users[steamid] <- client_table;
        ::MultiJump.ManageConfigs(true);
        return true;
    }

    RemoveFromUsersTable = function(steamid)
    {
        if (!(steamid in ::MultiJump.Configs.Users))
            return;

        delete ::MultiJump.Configs.Users[steamid];
        ::MultiJump.ManageConfigs(true);
        return true;
    }

    Remove = function(userid)
    {   // This won't remove the pre-defined users in the config file.
        local client = GetPlayerFromUserID(userid);
        if (!IsValidSafe(client))
            return;

        local steamid = ::MultiJump.GetSteamID(client);
        if (steamid in ::MultiJump.Clients)
            delete ::MultiJump.Clients[steamid];
    }

    GetWASDbuttons = function(client)
    {
        if (!IsValidSafe(client) || !client.IsPlayer())
            return;

        local buttons = NetProps.GetPropInt(client, "m_nButtons");
        return {    // Returning a table for WASD keys.
            w = buttons & 8
            s = buttons & 16
            a = buttons & 512
            d = buttons & 1024
        }
    }

    DoJumpOnClient = function(client, jump_height = 0, front_velocity = 0, tf2_jump = false, stop_in_air = false)
    {
        if (!IsValidSafe(client) || !client.IsPlayer())
            return;

        local wasd_table = GetWASDbuttons(client);
        local vector_velocity = client.GetAbsVelocity();
        vector_velocity["z"] = jump_height;

        // Calculating velocity for tf2 mode.
        local vector_forward = client.GetAbsAngles().Forward();
        vector_forward["x"] *= front_velocity;
        vector_forward["y"] *= front_velocity;
        vector_forward["z"] = jump_height;

        local vector_left = (client.GetAbsAngles().Left() * -1); // Left() returns right for some reason.
        vector_left["x"] *= front_velocity;
        vector_left["y"] *= front_velocity;
        vector_left["z"] = jump_height;

        if (wasd_table["w"] > 0 && wasd_table["s"] == 0 && tf2_jump)
        {
            client.SetAbsVelocity(vector_forward);
            ::MultiJump.DebugPrint(client, "tf2jump_forward", vector_forward);
        }
        else if (wasd_table["s"] > 0 && wasd_table["w"] == 0 && tf2_jump)
        {
            vector_forward["x"] *= -1;
            vector_forward["y"] *= -1;
            client.SetAbsVelocity(vector_forward);
            ::MultiJump.DebugPrint(client, "tf2jump_backwards", vector_forward);
        }
            else if (wasd_table["a"] > 0 && wasd_table["d"] == 0 && tf2_jump)
        {
                client.SetAbsVelocity(vector_left);
                ::MultiJump.DebugPrint(client, "tf2jump_left", vector_left);
        }
        else if (wasd_table["d"] > 0 && wasd_table["a"] == 0 && tf2_jump)
        {
            vector_left["x"] *= -1;
            vector_left["y"] *= -1;
            client.SetAbsVelocity(vector_left);
            ::MultiJump.DebugPrint(client, "tf2jump_right", vector_left);
        }
        else if (stop_in_air && (wasd_table["w"] + wasd_table["s"] + wasd_table["a"] + wasd_table["d"]) <= 0)
        {   // The scout stops any passive velocity if the player isn't pressing any WASD buttons
            vector_velocity["x"] = 0;
            vector_velocity["y"] = 0;
            client.SetAbsVelocity(vector_velocity);
            ::MultiJump.DebugPrint(client, "tf2jump_stop_air", vector_velocity);
        }
        else
        {
            client.SetAbsVelocity(vector_velocity);
            ::MultiJump.DebugPrint(client, "jump_normal_script", vector_velocity);
        }
    }

    OnGameEvent_round_start = function(params)
    {
        if (!::MultiJump.Configs["EnableScript"])
            return;

        ::MultiJump.Init();
    }

    OnGameEvent_round_freeze_end = function(params)
    {
        if (!::MultiJump.Configs["EnableScript"])
            return;

        ClientPrint(null, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "This script is enabled on this server. Type \"!mj_help\" to see the commands.");
    }

    OnGameEvent_player_spawn = function(params)
    {
        if (!::MultiJump.Configs["EnableScript"])
            return;

        local client = GetPlayerFromUserID(params.userid);
        if (!IsValidSafe(client))
            return;

        if (client.GetTeam() == 0)
            SendGlobalGameEvent("player_activate", {userid = params.userid});

        local steamid = ::MultiJump.GetSteamID(client);
        if (!IsDedicatedServer() && client == GetListenServerHost() && !(steamid in ::MultiJump.Configs.Users))
            ::MultiJump.AddToUsersTable(params.userid);

        if (::MultiJump.Configs["AutoAddClients"])
            ::MultiJump.Add(params.userid);

        if (client.GetTeam() != 0 && client.GetTeam() != 1 && steamid in ::MultiJump.Clients && ::MultiJump.Clients[steamid]["JumpEnabled"] && !::MultiJump.Clients[steamid]["DisabledByAdmin"])
            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "You can jump in air");
    }

    OnGameEvent_player_say = function(params)
    {
        local client = GetPlayerFromUserID(params.userid);
        if (!IsValidSafe(client))
            return;

        local steamid = ::MultiJump.GetSteamID(client);

        local text = params["text"];
        if (text.slice(0, 1) == "!" || text.slice(0, 1) == "/")
        {
            local command = split(text.slice(1), " ");
            local candosave = false;

            if (command.len() > 0 && ::MultiJump.Configs["EnableScript"] && steamid in ::MultiJump.Clients)
            {
                if (!::MultiJump.Configs["CanClientsChangeConfigs"])
                {
                    ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "Custom configs are disabled by the server.");
                }
                else
                {
                    switch (command[0])
                    {
                        case "mj_help":
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "See the console...");
                            ClientPrint(client, 2, "====== CLIENT COMMANDS ======");
                            ClientPrint(client, 2, "mj_configs - Print your configs in console.");
                            ClientPrint(client, 2, "mj_multijump - Enable or disable multijump.");
                            ClientPrint(client, 2, "mj_tf2mode - Enable or disable TF2 Scout jump mode");
                            ClientPrint(client, 2, "mj_falldamage - Enable or disable the falldamage.");
                            ClientPrint(client, 2, "mj_airstop - Enable or disable the TF2 airstop if you aren't pressing any WASD buttons when doing the airjump.");
                            ClientPrint(client, 2, "mj_jumplimit <number> - How many jumps you can do in air.");
                            ClientPrint(client, 2, "mj_jumpforce <number> - The force of the jump in the air.");
                            ClientPrint(client, 2, "mj_tf2_sideforce <number> - The force of the side jump in air for TF2 Scout jump mode.");
                            break;
                        case "mj_configs":
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "See the console...");
                            ClientPrint(client, 2, "========== YOUR CONFIGS ==========");
                            ClientPrint(client, 2, steamid + " : ");
                            foreach (key, value in ::MultiJump.Clients[steamid])
                                ClientPrint(client, 2, "\t" + key + " = " + value);
                            ClientPrint(client, 2, "========== YOUR CONFIGS ==========");
                            break;
                        case "mj_multijump":
                            if (!::MultiJump.Clients[steamid]["JumpEnabled"])
                                ::MultiJump.Clients[steamid]["JumpEnabled"] = true;
                            else
                                ::MultiJump.Clients[steamid]["JumpEnabled"] = false;

                            if (steamid in ::MultiJump.Configs.Users)
                            {
                                ::MultiJump.Configs.Users[steamid]["JumpEnabled"] = ::MultiJump.Clients[steamid]["JumpEnabled"];
                                candosave = true;
                            }
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "JumpEnabled set to " + ::MultiJump.Clients[steamid]["JumpEnabled"]);
                            break;
                        case "mj_tf2mode":
                            if (!::MultiJump.Clients[steamid]["TF2mode"])
                                ::MultiJump.Clients[steamid]["TF2mode"] = true;
                            else
                                ::MultiJump.Clients[steamid]["TF2mode"] = false;

                            if (steamid in ::MultiJump.Configs.Users)
                            {
                                ::MultiJump.Configs.Users[steamid]["TF2mode"] = ::MultiJump.Clients[steamid]["TF2mode"];
                                candosave = true;
                            }
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "TF2mode set to " + ::MultiJump.Clients[steamid]["TF2mode"]);
                            break;
                        case "mj_falldamage":
                            if (!::MultiJump.Clients[steamid]["FallDamage"])
                                ::MultiJump.Clients[steamid]["FallDamage"] = true;
                            else
                                ::MultiJump.Clients[steamid]["FallDamage"] = false;

                            if (steamid in ::MultiJump.Configs.Users)
                            {
                                ::MultiJump.Configs.Users[steamid]["FallDamage"] = ::MultiJump.Clients[steamid]["FallDamage"];
                                candosave = true;
                            }
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "FallDamage set to " + ::MultiJump.Clients[steamid]["FallDamage"]);
                            break;
                        case "mj_airstop":
                            if (!::MultiJump.Clients[steamid]["DoAirStop"])
                                ::MultiJump.Clients[steamid]["DoAirStop"] = true;
                            else
                                ::MultiJump.Clients[steamid]["DoAirStop"] = false;

                            if (steamid in ::MultiJump.Configs.Users)
                            {
                                ::MultiJump.Configs.Users[steamid]["DoAirStop"] = ::MultiJump.Clients[steamid]["DoAirStop"];
                                candosave = true;
                            }
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "DoAirStop set to " + ::MultiJump.Clients[steamid]["DoAirStop"]);
                            break;
                        case "mj_jumplimit":
                            if (command.len() > 1)
                            {
                                local value = command[1];
                                local currentvalue = ::MultiJump.Clients[steamid]["JumpLimit"];
                                if ((GetNumTypeFromString(value) != 1 && GetNumTypeFromString(value) != 2) || floor(currentvalue) == floor(value.tofloat()) || value.tofloat() < 0)
                                    return;

                                value = value.tofloat();
                                ::MultiJump.Clients[steamid]["JumpLimit"] = floor(value);
                                if (steamid in ::MultiJump.Configs.Users)
                                {
                                    ::MultiJump.Configs.Users[steamid]["JumpLimit"] = floor(value);
                                    candosave = true;
                                }
                                ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "\"JumpLimit\" set to " + value);
                            }
                            break;
                        case "mj_jumpforce":
                            if (command.len() > 1)
                            {
                                local value = command[1];
                                local currentvalue = ::MultiJump.Clients[steamid]["JumpForce"];
                                if ((GetNumTypeFromString(value) != 1 && GetNumTypeFromString(value) != 2) || floor(currentvalue) == floor(value.tofloat()) || value.tofloat() < 0)
                                    return;

                                value = value.tofloat();
                                ::MultiJump.Clients[steamid]["JumpForce"] = value;
                                if (steamid in ::MultiJump.Configs.Users)
                                {
                                    ::MultiJump.Configs.Users[steamid]["JumpForce"] = value;
                                    candosave = true;
                                }
                                ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "\"JumpForce\" set to " + value);
                            }
                            break;
                        case "mj_tf2_sideforce":
                            if (command.len() > 1)
                            {
                                local value = command[1];
                                local currentvalue = ::MultiJump.Clients[steamid]["TF2sideForce"];
                                if ((GetNumTypeFromString(value) != 1 && GetNumTypeFromString(value) != 2) || floor(currentvalue) == floor(value.tofloat()) || value.tofloat() < 0)
                                    return;

                                value = value.tofloat();

                                ::MultiJump.Clients[steamid]["TF2sideForce"] = value;
                                if (steamid in ::MultiJump.Configs.Users)
                                {
                                    ::MultiJump.Configs.Users[steamid]["TF2sideForce"] = value;
                                    candosave = true;
                                }
                                ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "\"TF2sideForce\" set to " + value);
                            }
                            break;
                    }
                }
            }
            if (command.len() > 0 && client == GetListenServerHost())
            {
                switch (command[0])
                {
                    case "mj_help":
                        ClientPrint(client, 2, "=== ADMIN COMMANDS ===");
                        ClientPrint(client, 2, "mj_print_clients - Print the configs of all clients in the console.");
                        ClientPrint(client, 2, "mj_script_toggle - Enable or disable the script for the server.");
                        ClientPrint(client, 2, "mj_autoadd_clients - Enable or disable the auto add of new connected clients (It's not stored in the config file).");
                        ClientPrint(client, 2, "mj_client_can_config - Enable or disable the ability of the clients to modify their own configs.");
                        ClientPrint(client, 2, "mj_client_toggle <userid> <save_changes: true | false. Default: false> - Enable or disable the jump ability of a connected client.");
                        ClientPrint(client, 2, "mj_add_temporal_client <userid> - Adds a temporal client in the client table. It's not stored in the config file.");
                        ClientPrint(client, 2, "mj_save_client <userid> - Saves a connected client in the config file.");
                        ClientPrint(client, 2, "mj_remove_saved_client <steamid3> - Removes a client by the steamid3 from the config file.");
                        ClientPrint(client, 2, "mj_debug - Enable or disable the debug mode for the server.");
                        ClientPrint(client, 2, "mj_reload_configs - Reloads the config file.");
                        break;
                    case "mj_print_clients":
                        ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "See the console...");
                        ClientPrint(client, 2, "========== CLIENTS TABLE ==========");
                        foreach (steamid, table in ::MultiJump.Clients)
                        {
                            ClientPrint(client, 2, steamid + " : ");
                            foreach (key, value in table)
                                ClientPrint(client, 2, "\t" + key + " = " + value);
                        }
                        ClientPrint(client, 2, "========== CLIENTS TABLE ==========");
                        break;
                    case "mj_script_toggle":
                        if (!::MultiJump.Configs["EnableScript"])
                        {
                            ::MultiJump.Init();
                            ::MultiJump.Configs["EnableScript"] = true;
                        }
                        else
                        {
                            ::MultiJump.Configs["EnableScript"] = false;
                            if (IsValidSafe(::MultiJump.ThinkEnt))
                            {
                                ::MultiJump.ThinkEnt.Kill();
                                ::MultiJump.ThinkEnt = null;
                            }
                        }
                        candosave = true;
                        ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "Script enabled set to " + ::MultiJump.Configs["EnableScript"] + ".");
                        break;
                    case "mj_autoadd_clients":
                        if (!::MultiJump.Configs["AutoAddClients"])
                            ::MultiJump.Configs["AutoAddClients"] = true;
                        else
                            ::MultiJump.Configs["AutoAddClients"] = false;

                        candosave = true;
                        ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "\"AutoAddClients\" set to " + ::MultiJump.Configs["AutoAddClients"] + ".");
                        break;
                    case "mj_client_can_config":
                        if (!::MultiJump.Configs["CanClientsChangeConfigs"])
                            ::MultiJump.Configs["CanClientsChangeConfigs"] = true;
                        else
                            ::MultiJump.Configs["CanClientsChangeConfigs"] = false;

                        candosave = true;
                        ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "\"CanClientsChangeConfigs\" set to " + ::MultiJump.Configs["CanClientsChangeConfigs"] + ".");
                        break;
                    case "mj_client_toggle":
                        if (command.len() > 1)
                        {
                            local value = command[1];
                            if (GetNumTypeFromString(value) != 1 && GetNumTypeFromString(value) != 2)
                                return;

                            local target = GetPlayerFromUserID(value.tointeger());
                            if (!IsValidSafe(target))
                                return;

                            local target_steamid = GetSteamID(target);
                            if (!(target_steamid in ::MultiJump.Clients))
                                return;

                            if (::MultiJump.Clients[target_steamid]["DisabledByAdmin"])
                                ::MultiJump.Clients[target_steamid]["DisabledByAdmin"] = false;
                            else
                                ::MultiJump.Clients[target_steamid]["DisabledByAdmin"] = true;

                            if (target_steamid in ::MultiJump.Configs.Users)
                            {
                                if (::MultiJump.Configs.Users[target_steamid]["DisabledByAdmin"])
                                    ::MultiJump.Configs.Users[target_steamid]["DisabledByAdmin"] = false;
                                else
                                    ::MultiJump.Configs.Users[target_steamid]["DisabledByAdmin"] = true;

                                if (command.len() > 2)
                                {
                                    local value2 = command[2];
                                    if (value2 != null && typeof value2 == "bool" && value2)
                                        candosave = true;
                                }
                            }
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "Jump for " + ::MultiJump.GetPlayerName(target) + " is " + !::MultiJump.Clients[target_steamid]["DisabledByAdmin"]);
                        }
                        break;
                    case "mj_add_temporal_client":
                        if (command.len() > 1)
                        {
                            local value = command[1];
                            if (GetNumTypeFromString(value) != 1 && GetNumTypeFromString(value) != 2)
                                return;

                            value = value.tointeger();
                            local target = GetPlayerFromUserID(value);
                            if (!IsValidSafe(target) || GetSteamID(target) in ::MultiJump.Clients)
                                return;

                            ::MultiJump.Add(value);
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "Client " + ::MultiJump.GetPlayerName(target) + " is temporaly added.");
                        }
                        break;
                    case "mj_save_client":
                        if (command.len() > 1)
                        {
                            local value = command[1];
                            if (GetNumTypeFromString(value) != 1 && GetNumTypeFromString(value) != 2)
                                return;

                            value = value.tointeger();
                            local target = GetPlayerFromUserID(value);
                            if (!IsValidSafe(target) || !::MultiJump.AddToUsersTable(value))
                                return;

                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "The user " + ::MultiJump.GetPlayerName(target) + " was added and saved in the 'Users' table.");
                        }
                        break;
                    case "mj_remove_saved_client":
                        if (command.len() > 1)
                        {
                            local value = command[1];
                            if (!value || typeof value != "string")
                                return;

                            if (!::MultiJump.RemoveFromUsersTable(value))
                                return;

                            delete ::MultiJump.Clients[value];
                            ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + value + " was removed from the 'Users' table.");
                        }
                        break;
                    case "mj_debug":
                        if (::MultiJump.Configs["DebugJumps"])
                            ::MultiJump.Configs["DebugJumps"] = false;
                        else
                            ::MultiJump.Configs["DebugJumps"] = true;

                        ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "Debug is " + (::MultiJump.Configs["DebugJumps"] ? "enabled" : "disabled") + ".");
                        break;
                    case "mj_reload_configs":
                        ::MultiJump.ManageConfigs();
                        ClientPrint(client, 3, "\x04" + "[MultiJump Vscript]" + "\x07990000" + "[ADMIN] " + "\x07E0E0E0" + "Configs file reloaded.");
                        break;
                    }
            }
            if (steamid in ::MultiJump.Clients && ::MultiJump.Clients[steamid]["DisabledByAdmin"])
                ClientPrint(client, 3, "\x04" + "[MultiJump Vscript] " + "\x07E0E0E0" + "Your ability to jump is disabled by the server.");
            if (candosave)
                ::MultiJump.ManageConfigs(true);
        }
    }

    OnGameEvent_player_footstep = function(params)
    {
        if (!::MultiJump.Configs["EnableScript"])
            return;

        local client = GetPlayerFromUserID(params.userid);
        if (!IsValidSafe(client))
            return;

        local steamid = ::MultiJump.GetSteamID(client);
        if (steamid in ::MultiJump.Clients)
        {
            ::MultiJump.Clients[steamid]["LastGroundTime"] = Time();
        }
    }

    OnGameEvent_player_disconnect =  function(params)
    {
        local client = GetPlayerFromUserID(params.userid);
        if (!IsValidSafe(client))
            return;

        ::MultiJump.Remove(params.userid);
    }

    OnScriptHook_OnTakeDamage = function(params)
    {
        if (!::MultiJump.Configs["EnableScript"])
            return;

        local victim = params["const_entity"];
        local attacker = params["attacker"];
        local inflictor = params["inflictor"];
        local weapon = params["weapon"];
        local damage_type = params["damage_type"];
        local damage_base = params["const_base_damage"];
        local damage = params["damage"];
        local damage_position = params["damage_position"];
        local damage_force = params["damage_force"];
        local max_damage = params["max_damage"];
        local ammo_type = params["ammo_type"];  // -1 if knife.

        if (!IsValidSafe(victim) || !victim.IsPlayer() || IsPlayerABot(victim))
            return;

        local steamid = ::MultiJump.GetSteamID(victim);
        local userid = ::MultiJump.GetPlayerUserID(victim);
        if (damage_type == 32 && steamid in ::MultiJump.Clients && !::MultiJump.Clients[steamid]["FallDamage"])
            params.damage = 0;
    }
}
__CollectGameEventCallbacks(::MultiJump);
if (clienttable != null)
    ::MultiJump.Clients = clienttable;