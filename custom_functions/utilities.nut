// UTILS
// ENTITIES
::IsValidSafe <- function(any_ent)
{   // Your typical NULL pointer prevention. The variable may not be null but still storing an instance object that's invalid. That's where IsValid() shines.
    if (any_ent != null && any_ent.IsValid())
        return true;

    return false;
}

::Ent <- function( idxorname )
{   // "Takes an entity index or name, returns the entity" - Ported from l4d2 scriptedmode.nuc
	local hEnt = null;
	if ( typeof(idxorname) == "string" )
		hEnt = Entities.FindByName( null, idxorname );
	else if ( typeof(idxorname) == "integer" )
		hEnt = EntIndexToHScript( idxorname );
	if (IsValidSafe(hEnt))
		return hEnt;
}

::GetBombPlayer <- function()
{   // Returns the index of the player that is carrying the bomb. There must be only one c4 per map.
    return NetProps.GetPropInt(PLAYER_MANAGER_ENTITY, "m_iPlayerC4");
}

::GetBombPosition <- function()
{   // Returns the vector position of the bomb. There must be only one c4 per map.
    return NetProps.GetPropVector(PLAYER_MANAGER_ENTITY, "m_vecC4");
}

// Warning: Calling other positions than 'a' and 'b' will return any of those two vectors spots.
::GetBombsitePosition <- function(bombsite = "", bShouldPrint = false)
{   // Returns the center vector of a desired bombsite (based on func_bombsite center?). There are only "A" and "B" bombsites in a defuse map.
    local sBombsite = bombsite.toupper();
    local vBombiste = NetProps.GetPropVector(PLAYER_MANAGER_ENTITY, "m_bombsiteCenter" + sBombsite);
    if (bShouldPrint)
        printl("Found Bombsite " + sBombsite + " at " + vBombiste.ToKVString());

    return vPos;
}

// STRING
// Imagine someone using quotation marks for their username. Quite annoying when trying to store it in a variable.
// I may recommend you this function for every username you want to store just in case.
// If the username doesn't have any quotation marks, the method will just return the string.
::RemoveQuotationMarks <- function(string = "")
{	// Basically, returns a string without the quotation marks (eg. ""F1"" to "F1"). This is for a better text parsing.
	if (!string || string == null || typeof string != "string" || string.len() <= 0)
	    return;

	if (string.find("\"") == null)
		return string;

	local new_srt = split(string, "\"");
	local result = "";

	for (local i = 0; i < new_srt.len(); i++)
		result = result + new_srt[i];
        
	return result;
}

// FLOAT | INTEGERS
// if "var_default" is not null, "var" will take its value instead of "var_min" or "var_max".
::Clamp <- function(var, var_min, var_max, var_default = null)
{   // Your typical clamp function to ensure the boundaries of your variable
    if (var < var_min)
    {
        if (var_default != null)
            var = var_default;
        else
            var = var_min;
    }
    else if (var > var_max)
    {
        if (var_default != null)
            var = var_default;
        else
            var = var_max;
    }
    return var;
}

::NumBetween <- function(a, b, num) // Backported from l4d2 "sm_utilities.nut"
{   // is num between a,b where a and b do not have to be ordered
	return (b > a ? num > a && num < b : num > b && num < a)
}

// VECTORS AND QANGLES
::StringToQAngle <- function(str, delimiter)
{
    local qangle = QAngle(0, 0, 0);
    local result = split(str, delimiter);

    qangle.x = result[0].tofloat();
    qangle.y = result[1].tofloat();
    qangle.z = result[2].tofloat();

    return qangle;
}

::StringToVector <- function(str, delimiter)    // Backported from l4d2 "sm_utilities.nut"
{   // Why did valve decide to convert the axis into integers instead of floats? That's illegalism! Fixed here. (TLS update as well)
    local vec = Vector(0, 0, 0);
    local result = split(srt, delimiter);

    vec.x = result[0].tofloat();
    vec.y = result[1].tofloat();
    vec.z = result[2].tofloat();

    return vec;
}

/*
    Syntax:
    GetVectorDistance(<Vector startVector>, <Vector endVector>)
    startVector: The vector you want to start the distance.(Reference point)
    endVector: The vector you want to end the distance.
*/
::GetVectorDistance <- function(startVector, endVector)
{   // Returns the vector distance from a start to an end point. You may want to use Length() for a single unit distance.
    return endVector - startVector;
}

/*
    Syntax:
    ReflectFromVector(<Vector vectorToReflect>, <Vector referenceVector>, <array AxisToExclude>)
    vectorToReflect: The vector you want to reflect.
    referenceVector: The vector you want the <vectorToReflect> to reflect from.
    AxisToExclude: The axis of the <vectorToReflect> you want to exclude from being reflected.
*/
::ReflectFromVector <- function(vectorToReflect, referenceVector, AxisToExclude = ["z"])
{   // Basically, returns the x, y, z prime values of a vector from a reference. "AxisToExclude" is an array to exclude axis to be reflected
    local vDistance = GetVectorDistance(vectorToReflect,  referenceVector);
    local vPrime = referenceVector + vDistance; // Prime vector are reflected values.
    // We want to filter whatever the user puts in the AxisToEclude param. Meaning, the only valid values are the vector axis 
    // Ex: ["x"], ["x", "y"], ["y"], ["z"].
    // Either way, you wouldn't want to use this for the 3 axis or it will just return the vectorToReflect vector.
    local PrimeTable = {x = vPrime.x y = vPrime.y z = vPrime.z};  

    for (local i = 0; i < AxisToExclude.len(); i++) 
    {
        local axis = AxisToExclude[i];
        // This is the part we are going to filter the valid axis.
        if (!(axis in PrimeTable))
            continue;

        vPrime[axis] = vectorToReflect[axis];
    }
    return vPrime;
}

// FOR DEBUGGING
function DeepPrintTable(table)  // Backported and modified from l4d2 "sm_utilities.nut"
{   
	printl("{\n");

    print("\n}");
}

// MISC
::IsCheatingSession <- function()
{
    return (developer() > 0 || Convars.GetBool("sv_cheats"));
}

::IsAutoBunnyhopEnabled <- function()
{
    return Convars.GetBool("sv_autobunnyhopping");
}

::IsBunnyhopEnabled <- function()
{
    return Convars.GetBool("sv_enablebunnyhopping");
}

::IsFlashlightEnabled <- function()
{
    return Convars.GetBool("mp_flashlight");
}

::IsFreezeTimeEnded <- function()
{   // Returns true if the round freeze period ends. You can do the same by hooking the event "round_freeze_end"
    return NetProps.GetPropBool(GAMERULES_ENTITY, "m_bFreezePeriod");
}

::IsGiftGrabEventActive <- function()
{   // Returns true if the gift grab event is active.
    return NetProps.GetPropBool(GAMERULES_ENTITY, "m_bWinterHolidayActive");
}

::SetForceGiftGrabEvent <- function(bool)
{   // Forces or disables the Gift Grab event.
    NetProps.SetPropBool(GAMERULES_ENTITY, "m_bWinterHolidayActive", bool);
}

::GetRoundDuration <- function()
{   // Returns the round time in seconds.
    return Time() - NetProps.GetPropFloat(GAMERULES_ENTITY, "m_iRoundTime");
}

::GetRoundTime <- function()
{   // Returns the duration of the current round
    return Time() - NetProps.GetPropFloat(GAMERULES_ENTITY, "m_fRoundStartTime");
}

::GetCompleteRoundTime <- function()
{   // Returns the duration of the current round but it includes the freeze time.
    return Time() - NetProps.GetPropFloat(GAMERULES_ENTITY, "m_flGameStartTime"); 
}

::MapHasBombTarget <- function()
{   // Returns true if the map has bomb target
    return NetProps.GetPropBool(GAMERULES_ENTITY, "m_bMapHasBombTarget");
}

::MapHasRescueZone <- function()
{   // Returns true if the map has rescue zone
    return NetProps.GetPropBool(GAMERULES_ENTITY, "m_bMapHasRescueZone");
}


// RESTORED FUNCTIONS...?
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
        else if (func.getinfos()["name"] == null)
        {
            error("[UpdateUtil] The function must have a name. Please.\n");
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
        printl("[UpdateUtils] function " + new_table.funcname + "() has been added successfully.");
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
/*
    OnGameEvent_round_start = function(params) 
    {
        for (local i = 0; i < UpdateUtil.UpdateGroup.len(); i++)
        {
            if (!UpdateUtil.UpdateGroup[i]["preserved"])
                UpdateUtil.UpdateGroup.remove(i);
        }
    }*/
}
__CollectGameEventCallbacks(UpdateUtil);
UpdateUtil.Init();
