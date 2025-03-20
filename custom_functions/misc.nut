::GetLanguage <- function() 
{ // Returns the language of the server. NOTE: You only need this once. (Unless you update the cvar to test smth)
    if (IsDedicatedServer())
        return ;
    else
        return Convars.GetClientConvarValue("cl_language", 1);  // Listen server host entindex is always 1.
}

::HijackServer <- function() 
{   // Happy Days
    throw "No";
}

::IssueCommandOnServer <- function(command)
{   // Executes a command on the server. Don't be a L4D2 original Helms Deep survival map developer (aka. samurai)
    local point_servercommand = Entities.CreateByClassname("point_servercommand");
    point_servercommand.AcceptInput("Command", command, null, null);
    EntFireByHandle(point_servercommand, "Kill", "", 0.01, null, null);
}

// UPDATE FUNCTION
class CUpdateManager {
    static bLoaded = false   // This will make sure no the Init function won't get called more than once.

    FuncGroup = null;
    EntThink = null;
    FuncAmount = null;
    
};

::UpdateUtil <- {
    IsLoaded = false
    UpdateEnt = null
    FuncAmount = 0
    UpdateGroup = [/*{func = (function : 0x000001EE46F6CA60) refire_interval = 1.0 timer = Time() is_disabled = false}*/]

    Init = function()
    {
        if (("CUpdateManager" in getroottable() && CUpdateManager["bLoaded"])) // This function should be called once per map load.
        {
            error("[UpdateUtil] Init function can only be called once per map load\n");
            return;
        }
        printl("intialling |||||||||||||||||||||||||||||||||||||||||")
        local main_entity = Ent("*_UpdateEntity_*");
        if (!main_entity)
        {
            UpdateUtil.UpdateEnt = Entities.CreateByClassname("info_target");
            UpdateUtil.UpdateEnt.KeyValueFromString("targetname", UniqueString("_UpdateEntity_"));
            UpdateUtil.UpdateEnt.DispatchSpawn();
        }
        else 
            UpdateUtil.UpdateEnt = main_entity;
        
        UpdateUtil.UpdateEnt.ValidateScriptScope();
        UpdateUtil.UpdateEnt.GetScriptScope()["UpdateFunc"] <- function() 
        {
            UpdateUtil.UpdateFunc(); 
            return -1;
        };
        AddThinkToEnt(UpdateUtil.UpdateEnt, "UpdateFunc");
        UpdateUtil.IsLoaded = true;

        if ("CUpdateManager" in getroottable())
        {
            getroottable()["CUpdateManager"]["bLoaded"] <- true;
            local class_inst = CUpdateManager(); // Once we instantiated anything with this class, the static won't be able to be modified.
        }
    }

    UpdateFunc = function() 
    {
        foreach (idx, func in UpdateUtil.UpdateGroup) 
        {
            if (Time() - UpdateUtil.UpdateGroup[idx]["timer"] >= UpdateUtil.UpdateGroup[idx]["refire_interval"])
            {
                UpdateUtil.UpdateGroup[idx]["timer"] = Time();
                if (!UpdateUtil.UpdateGroup[idx]["is_disabled"])
                    UpdateUtil.UpdateGroup[idx]["func"]();
            }
        }
    }

    IsInUpdateGroup = function(func)
    {   // NOTE: Re-defining the same funcion again counts as a different function object
        for (local i = 0; i < UpdateUtil.UpdateGroup.len(); i++)
        {
            if (UpdateUtil.UpdateGroup[i]["func"] == func)
                return UpdateUtil.UpdateGroup[i];
        }
        return null;
    }

    AddUpdate = function(func, interval = 1.0, start_disabled = false, is_preserved = false)  // I belive the lowest interval is 0.015 for 66 ticks.
    { 
        if (typeof func != "function")
        {
            error("[UpdateUtil] The parameter <func> must be a function type\n");
            return;
        }
        if (UpdateUtil.IsInUpdateGroup(func) != null)
        {
            error("[UpdateUtil] The function " + func.getinfos()["name"] + " is already added!\n");
            return false;
        }

        local new_table = 
        {
            func_id = UpdateUtil.FuncAmount
            func_name = func.getinfos()["name"] 
            func = func 
            refire_interval = 
            interval timer = Time() 
            is_disabled = start_disabled
            preserved = is_preserved    // The function will be removed in a new round
        };
        UpdateUtil.UpdateGroup.append(new_table);
        printl("[UpdateUtils] function " + new_table.func_name + "() has been added successfully.");
        UpdateUtil.FuncAmount++;
        return true;
    }

    ToggleUpdate = function(func)
    {
        local bDidToggle = false;
        for (local i = 0; i < UpdateUtil.UpdateGroup.len(); i++)
        {
            if (UpdateUtil.UpdateGroup[i]["func"] == func)
            {
                if (UpdateUtil.UpdateGroup[i]["is_disabled"])
                {
                    UpdateUtil.UpdateGroup[i]["is_disabled"] = false;
                    printl("[UpdateUtil] Function " + UpdateUtil.UpdateGroup[i]["func_name"] + "() is ENABLED.");
                }
                else 
                {
                    UpdateUtil.UpdateGroup[i]["is_disabled"] = true;
                    printl("[UpdateUtil] Function " + UpdateUtil.UpdateGroup[i]["func_name"] + "() is DISABLED.");
                }    
                bDidToggle = true;
                break;
            }
        }
        return bDidToggle;
    }

    RemoveUpdate = function(func)
    {
        local bDidRemove = false;
        for (local i = 0; i < UpdateUtil.UpdateGroup.len(); i++)
        {
            if (UpdateUtil.UpdateGroup[i]["func"] == func)
            {
                printl("[UpdateUtil] Removing function " + UpdateUtil.UpdateGroup[i]["func_name"] + "()...");
                UpdateUtil.UpdateGroup.remove(i);
                bDidRemove = true;
                break;
            }
        }
        if (bDidRemove)
            UpdateUtil.FuncAmount--;

        return bDidRemove;
    }

}
UpdateUtil.Init();

// CLASSES
class CCustomCvar {
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

        name = cvarname;
        value = cvar_val;
        min_value = cvar_min_val;
        max_value = cvar_max_val;
        default_value = cvar_default_val

    }
}

