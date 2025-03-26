// UTILS
// ENTITIES
::IsValidSafe <- function(any_ent)
{   // Your typical NULL pointer prevention. The variable may not be null but still storing an invalid instance object. That's where IsValid() shines.
    if (any_ent != null && any_ent.IsValid())
        return true;

    return false;
}

::Ent <- function(idxorname)
{   // "Takes an entity index or name, returns the entity" - Ported from l4d2 scriptedmode.nuc
	local hEnt = null;
	if (typeof(idxorname) == "string")
		hEnt = Entities.FindByName(null, idxorname);
	else if (typeof(idxorname) == "integer")
		hEnt = EntIndexToHScript(idxorname);
	if (IsValidSafe(hEnt))
		return hEnt;
}

::GetGamerules <- function()    // This was initially a global but it sometimes returned NULL so, no.
{ // Returns the cs_gamerules entity. It's a shortcut of Entities.FindByClassname(null, "cs_gamerules").
    return Entities.FindByClassname(null, "cs_gamerules");
}

::GetPlayerManager <- function ()   // This was initially a global but it sometimes returned NULL so, no.
{ // Returns the cs_player_manager entity. It's a shortcut of Entities.FindByClassname(null, "cs_player_manager").
    return Entities.FindByClassname(null, "cs_player_manager");
}

::GetBombPlayer <- function()
{   // Returns the index of the player that is carrying the bomb. There must be only one c4 per map.
    return NetProps.GetPropInt(GetPlayerManager(), "m_iPlayerC4");
}

::GetBombPosition <- function()
{   // Returns the vector position of the bomb. There must be only one c4 per map.
    return NetProps.GetPropVector(GetPlayerManager(), "m_vecC4");
}

// [WARNING]: Calling other positions than 'a' and 'b' will return any of those two spots.
::GetBombsitePosition <- function(bombsite = "")
{   // Returns the center vector of a desired bombsite (based on func_bomb_target center?). There are only "A" and "B" bombsites in a defuse map.
    return NetProps.GetPropVector(GetPlayerManager(), "m_bombsiteCenter" + bombsite.toupper());
}

// STRING
// Imagine someone using quotation marks for their username. Like: I like "cheeseburger".
// Quite annoying when trying to store it in a variable or in a file to causing errors on reading.
// I recommend you this function for every username you want to store just in case.
// If the string doesn't have any quotation marks, the method will just return the string itself.
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

::IsStringNullOrEmpty <- function(str) 
{
    if (!str || str == null)
        return true;

    if (typeof str == "string" && str.len() <= 0)
        return true;

    return false;
}

// READ: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions#INextBotComponent:~:text=Calling-,RunScriptCode
::ClearStringFromPool <- function(string)
{
	local dummy = Entities.CreateByClassname("info_target");
	dummy.KeyValueFromString("targetname", string);
	NetProps.SetPropBool(dummy, "m_bForcePurgeFixedupStrings", true);
	dummy.Destroy();
}

::FormatToJson <- function(var) 
{   // Returns static data types as a string for a json file (ex. table, array, int, float, class)
    local sData = null;
    local bIsFirstIndex = true;
    switch (typeof var) 
    {
        case "string": 
            sData = "\"" + var + "\"";
            break;
        case "integer":
        case "float": 
            sData = var.tostring();
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
                if (!bIsFirstIndex)
                    sData += ",";
                else
                    bIsFirstIndex = false;

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
                if (!bIsFirstIndex)
                    sData += ",";
                else
                    bIsFirstIndex = false;

                sData += ::FormatToJson(var[i]);
            }
            sData += "]";
        }
        break;
        case "instance":
          sData = "\"" + var.GetClassname() + "\"";
          break;
        case "bool":
          sData = var;
          break;
        default:
          sData = "\"" + typeof var +"\""; // Why would you like smth like "(native function : 0x000002CF3DE48310)" in a JSON file?
    }
    return sData;
}

// FLOAT | INTEGERS
// if "var_default" is not null, "var" will take its value instead of "var_min" or "var_max".
::Clamp <- function(var, var_min, var_max, var_default = null)
{   // Your typical clamp function to ensure the boundaries of your variable
    if (var_default != null && (var < var_min || var > var_max))
        var = var_default
    else if (var < var_min)
        var = var_min;
    else if (var > var_max)
        var = var_max;

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
    GetVectorDistance(<Vector inputVector>, <Vector referenceVector>)
    referenceVector: The vector you want to start the distance.(Reference point)
    inputVector: The vector you want to end the distance.
*/
::GetVectorDistance <- function(inputVector, referenceVector)
{   // Returns the vector distance of the input vector from a reference point.
    return referenceVector - inputVector;
}

::GetSingleDistance <- function(inputVector, referenceVector)
{   // Returns the length distance from a start to an end point.
    return ::GetVectorDistance(inputVector, referenceVector).Length();
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
    local vDistance = ::GetVectorDistance(vectorToReflect, referenceVector);
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

::IsVectorGreaterOrEqual <- function(vector, thisvector)
{
    return (vector.x >= thisvector.x && vector.y >= thisvector.y && vector.z >= thisvector.z);
}

::IsVectorLowerOrEqual <- function(vector, thisvector)
{
    return (vector.x <= thisvector.x && vector.y <= thisvector.y && vector.z <= thisvector.z);
}

::IsVectorWithinRange <- function(vectorInput, vectorMinRange, vectorMaxRange)
{
    return ::IsVectorGreaterOrEqual(vectorInput, vectorMinRange) && ::IsVectorLowerOrEqual(vectorInput, vectorMaxRange);
}

// TABLE | ARRAY
::DeepPrintTable <- function(table, prefix = "", bShouldPrint = true)  // Backported and modified from l4d2 "sm_utilities.nut"
{   
    local tData = "\n" + prefix;
    if (typeof table == "table")
        tData = tData + "{\n";
    else
    {
        tData = tData + "[\n";
    }

    foreach (key, val in table) 
    {
        tData = tData + prefix + "\t" + key + " = ";
        local val_type = typeof val;
        if (val_type == "table")
        {
            tData = tData + prefix + DeepPrintTable(val, "\t\t",false);
        }
        else if (val_type == "array")
        {
            tData = tData + prefix + "\n\t[\n";
            for (local i = 0; i < val.len(); i++)
            {
                local arr_val = val[i];
                local arr_val_type = typeof arr_val;
                if (arr_val_type == "table")
                {
                    tData = tData + prefix + DeepPrintTable(arr_val, "\t\t",false);
                }
                else if (arr_val_type == "string")
                    tData = tData + "\t\t\"" + arr_val + "\",\n";
                else
                    tData = tData + "\t\t" + arr_val + ",\n"
            }
            tData = tData + prefix + "\n\t]\n";
        }
        else if (val_type == "string")
        {
            tData = tData + "\"" + val + "\"\n";
        }
        else 
            tData = tData + val + "\n";
    }
    if (typeof table == "table")
        tData = tData + prefix + "}\n";
    else
        tData = tData + prefix + "]\n";
    

    if (bShouldPrint)
        printl(tData);

    return tData;
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

::IsFreezePeriod <- function()
{   // Returns true if the round freeze period ends. You can do the same by hooking the event "round_freeze_end"
    return NetProps.GetPropBool(GetGamerules(), "m_bFreezePeriod");
}

// To Comfirm: What's this? a leftlover or the netprop for background maps for singleplayer?
// [WARNING]: 
// - Setting this to true will literally hide the hud (not the main menu) for everyone.
// - You may or may not teleport back to the spawn in the next round.
// - You will be completely frozen in the next round (camera&movement).
// All of this if you don't set it back to false before the round resets.
::IsLogoMap <- function() 
{   // Returns true if the netprop is true... yikes.
    return NetProps.GetPropBool(GetGamerules(), "m_bLogoMap");
}

// NOTES: It's the "Dynamic Weapon Pricing" feature from 2006 (https://counterstrike.fandom.com/wiki/Dynamic_Weapon_Pricing)
// - It forces the startmoney to 800 regardless of "mp_startmoney" value.
// - May or may not crash the game when opening the buy menu
// - The buy menu gets buggy with the feature leftovers.
// - The weapon prices remain the same.
// - It's definitely a leftover netprop.
// TIP: Keep this on false.
::IsBlackMarketActive <- function() 
{   // Returns true if the black market is enabled.
    return NetProps.GetPropBool(GetGamerules(), "m_bBlackMarket");
}

::IsGiftGrabEventActive <- function()
{   // Returns true if the gift grab event is active.
    return NetProps.GetPropBool(GetGamerules(), "m_bWinterHolidayActive");
}

::SetForceGiftGrabEvent <- function(bool)
{   // Forces or disables the Gift Grab event.
    NetProps.SetPropBool(GetGamerules(), "m_bWinterHolidayActive", bool);
}

::GetRoundDuration <- function()
{   // Returns the time in seconds of the duration of the round.
    return NetProps.GetPropInt(GetGamerules(), "m_iRoundTime");
}

::GetRoundTime <- function()
{   // Returns the duration of the current round
    return Time() - NetProps.GetPropFloat(GetGamerules(), "m_fRoundStartTime");
}

::GetCompleteRoundTime <- function()
{   // Returns the duration of the current round but it includes the freeze time.
    return Time() - NetProps.GetPropFloat(GetGamerules(), "m_flGameStartTime"); 
}

::HasMapBombTarget <- function()
{   // Returns true if the map has bomb target
    return NetProps.GetPropBool(GetGamerules(), "m_bMapHasBombTarget");
}

::HasMapRescueZone <- function()
{   // Returns true if the map has rescue zone (aka. hostage)
    return NetProps.GetPropBool(GetGamerules(), "m_bMapHasRescueZone");
}

// NOTES: The netprop value isn't updated if 'mp_ignore_round_win_conditions' cvar is 1.
// - Setting the cvar back to 0, the value will update the next time you rescue or kill a hostage.
// - The value isn't updated in real time. You may want to use a delay to get the real value.
// - The value will always update before decreasing or increasing the count (in case you create more hostage_entity)
// Ex: The value is 4 > Set the netprop value wrongly to 1 > Kill or rescue one hostage > The value will be set to 3.
// TIP: Don't change the value.
::GetRemainingHostages <- function() 
{   // Retuns the remaining hostages to be rescued or killed in the round.
    return NetProps.GetPropInt(GetGamerules(), "m_iHostagesRemaining");
}

// READ: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions#INextBotComponent:~:text=Calling-,RunScriptCode
::EntFireCodeSafe <- function(entity, code, delay = 0.0, activator = null, caller = null)
{
	EntFireByHandle(entity, "RunScriptCode", code, delay, activator, caller);
	::ClearStringFromPool(code);
}


// IN-CONSTRUCTION!
::SaveTable <- function(strIdentifier, tableInput)
{   // From L4D2: It saves the table that persist across round and map transitions until the server closes.
    local filename = "savadatatable.save";
    if (!FileToString(filename))
    {
        local tData = "{\n"
        
        tData = tData + "\n}";
    }
    else
    {
        local table_src = compilestring("return {"+FileToString(filename)+"}")();

    }
}

::RestoreTable <- function(srtIdentifier, tableOutput)
{   // From L4D2: Restores the table that was saved by SaveTable(). The table data removes itself from the memory.
    
}
