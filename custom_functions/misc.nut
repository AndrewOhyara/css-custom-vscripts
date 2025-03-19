// UPDATE FUNCTION
::UpdateUtil <- {
    IsLoaded = false
    UpdateEnt = null
    FuncAmount = 0
    UpdateGroup = [/*{func = (function : 0x000001EE46F6CA60) refire_interval = 1.0 timer = Time() is_disabled = false}*/]
    Init = function()
    {
        if (UpdateUtil.IsLoaded)   // This function should be called once per map load.
        {
            error("[UpdateUtil] Init function can only be called once per map load\n");
            return;
        }

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
//__CollectGameEventCallbacks(UpdateUtil);
UpdateUtil.Init();

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