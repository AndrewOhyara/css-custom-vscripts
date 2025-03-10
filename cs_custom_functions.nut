// Custom methods based on l4d2 vscript.
if (this != getroottable())
    throw "This script must the included in the root scope, please.";

Msg("\n[CSS: Custom Functions] Loading script...\n");

// TEAM
const TEAM_UNASSIGNED = 0;  // "Select Team" screen.
const TEAM_SPECTATOR = 1;
const TEAM_TERRORIST = 2;
const TEAM_COUNTER_TERRORIST = 3;

// PLAYER CLASS
enum CS_PLAYER_CLASS 
{   // This is the order of the player class for m_iClass netprop.
    NOCLASS,    // Spectator/Unassigned
    // Terrorist
    PHOENIX_CONNEXION,
    ELITE_CREW,
    ARCTIC_AVENGERS,
    GUERILLA_WARFARE,
    // Counter-Terrorist
    SEAL_TEAM_6,
    GSG_9,
    SAS,
    GIGN
}
enum CS_PLAYER_SKIN
{
    NOCLASS = "",    // Spectator/Unassigned
    // Terrorist
    PHOENIX_CONNEXION = "models/player/t_phoenix.mdl",
    ELITE_CREW = "models/player/t_leet.mdl",
    ARCTIC_AVENGERS = "models/player/t_arctic.mdl",
    GUERILLA_WARFARE = "models/player/t_guerilla.mdl",
    // Counter-Terrorist
    SEAL_TEAM_6 = "models/player/ct_urban.mdl",
    GSG_9 = "models/player/ct_gsg9.mdl",
    SAS = "models/player/ct_sas.mdl",
    GIGN = "models/player/ct_gign.mdl"
}

// DAMAGE TYPE
const DMG_GENERIC = 0;
const DMG_CRUSH = 1;
const DMG_BULLET = 2;
const DMG_SLASH = 4;
const DMG_BURN = 8;
const DMG_VEHICLE = 16;
const DMG_FALL = 32;
const DMG_BLAST = 64;
const DMG_CLUB = 128;
const DMG_SHOCK = 256;
const DMG_SONIC = 512;
const DMG_ENERGYBEAM = 1024;
const DMG_PREVENT_PHYSICS_FORCE = 2048;
const DMG_NEVERGIB = 4096;
const DMG_ALWAYSGIB = 8192;
const DMG_DROWN = 16384;
const DMG_PARALYZE = 32768;
const DMG_NERVEGAS = 65536;
const DMG_POISON = 131072;
const DMG_RADIATION = 262144;
const DMG_DROWNRECOVER = 524288;
const DMG_ACID = 1048576;
const DMG_SLOWBURN = 2097152;
const DMG_REMOVENORAGDOLL = 4194304;
const DMG_PHYSGUN = 8388608;
const DMG_PLASMA = 16777216;
const DMG_AIRBOAT = 33554432;
const DMG_DISSOLVE = 67108864;
const DMG_BLAST_SURFACE = 134217728;
const DMG_DIRECT = 268435456;
const DMG_BUCKSHOT = 536870912;
const DMG_HEADSHOT = 1073741824;
const DMG_LASTGENERICFLAG = -2147483648;

::MaxPlayers <- MaxClients().tointeger(); // Extracted from: https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Iterating_Through_Players
::GetListenServerHost <- @() PlayerInstanceFromIndex(1);

// ENTITIES
// Syntax: DissolveEntity(<Handle entity or Int entindex>, <Int type>, <Int magnitude>)
::DissolveEntity <- function(any, type = 0, magnitude = 0)
{   // Dissolves any physical entity. WARNING: Undesired effects on players if this used on them. (Use this method on their ragdolls instead)
    local ent = any;
    if (typeof any == "integer")
    {
        ent = EntIndexToHScript(any);
    }
    else if (typeof ent != "instance")
    {
        return;
    }
    if (ent == Entities.First())
        return;

    local dissolver = Entities.CreateByClassname("env_entity_dissolver");
    dissolver.KeyValueFromString("target", "!activator");
    dissolver.KeyValueFromInt("dissolvetype", type);
    dissolver.KeyValueFromInt("magnitude", type);
  
    Entities.DispatchSpawn(dissolver);
  
    dissolver.AcceptInput("Dissolve", "", ent, null);
    dissolver.AcceptInput("Kill", "", null, null);
}

// NOTE: When using it with a player to another player, for some reason, the trace will point a little higher and poiting to spots like the head will return null.
::GetEntityPointingAt <- function(any_ent, bIgnoreWorldSpawn = true, iMask = 33579137)
{  // It basically returns the pointed entity of another entity. If bIgnoreWorldSpawn is true, it will return worldspawn if it's the entity that's being pointed. 
   // Since entities are classes, we can know if it has the method "EyePosition" and "EyeAngles".
   local eye_pos = null;
   local bSupportEyes = true;
   if ("EyePosition" in any_ent && "EyeAngles" in any_ent)
   {  // Both of these methods must be present in the entity class.
        eye_pos = any_ent.EyePosition();
      //if (any_ent.GetClassname() == "player")   // For some reason, you must point a little down to get a player entity.
         //eye_pos += Vector(0, 0, -8);   // Thought, this doesn't happen with another entity.
   }
   else
   {
        eye_pos =   any_ent.GetOrigin();
        bSupportEyes = false;
   }

   // We are additioning the pos with the foward vector of the eyes that's multiplied by 99999.
   // Meaning the destination vector (ex. (-71104.046875, -984113.750000, -150380.21875)) will be far enough to catch anything.
   // You can also use the Scale() method. 
   local dest_pos = null;
   if (bSupportEyes)
   {
        dest_pos = eye_pos + any_ent.EyeAngles().Forward().Scale(999999);
   }
   else 
   {
        dest_pos = eye_pos + any_ent.GetAbsAngles().Forward().Scale(999999);
   }

   // Then, trace a line.
   local trace_table = 
   {
        start = eye_pos
        end = dest_pos
        mask = iMask   // Default mask is MASK_VISIBLE_AND_NPCS (33579137)
        ignore = any_ent  // ofc, we don't want to include the entity itself
   }
   TraceLineEx(trace_table);

    if (!trace_table.hit)
        return null;

    if (!trace_table.enthit || trace_table.enthit == null || !trace_table.enthit.IsValid())   // Your typical NULL pointer situation.
        return null;

    if (trace_table.enthit == any_ent)  // If the enthit is the entity itself.
        return null;

    if (bIgnoreWorldSpawn && trace_table.enthit.GetClassname() == "worldspawn")
        return null;

    return trace_table.enthit;
}

::GetPointingPosition <- function(any_ent, bIgnoreWorldSpawn = false, iMask = 1174421507)
{  // It basically returns the vector where the trace ended.
   // Since entities are classes, we can know if it has the method "EyePosition" and "EyeAngles".
   local eye_pos = null;
   local bSupportEyes = true;
   if ("EyePosition" in any_ent && "EyeAngles" in any_ent)
   {  // Both of these methods must be present in the entity class.
        eye_pos = any_ent.EyePosition();
      //if (any_ent.GetClassname() == "player")   // For some reason, you must point a little down to get a player entity.
         //eye_pos += Vector(0, 0, -8);   // Thought, this doesn't happen with another entity.
   }
   else
   {
        eye_pos =   any_ent.GetOrigin();
        bSupportEyes = false;
   }

   // We are additioning the pos with the foward vector of the eyes that's multiplied by 99999.
   // Meaning the destination vector (ex. (-71104.046875, -984113.750000, -150380.21875)) will be far enough to catch anything.
   // You can also use the Scale() method. 
   local dest_pos = null;
   if (bSupportEyes)
   {
        dest_pos = eye_pos + any_ent.EyeAngles().Forward().Scale(999999);
   }
   else 
   {
        dest_pos = eye_pos + any_ent.GetAbsAngles().Forward().Scale(999999);
   }

   // Then, trace a line.
   local trace_table = 
   {
        start = eye_pos
        end = dest_pos
        mask = iMask   // Default mask is MASK_VISIBLE_AND_NPCS (33579137)
        ignore = any_ent  // ofc, we don't want to include the entity itself
   }
   TraceLineEx(trace_table);

    if (!trace_table.hit)
        return null;

    if (!trace_table.enthit || trace_table.enthit == null || !trace_table.enthit.IsValid())   // Your typical NULL pointer situation.
        return null;

    if (trace_table.enthit == any_ent)  // If the enthit is the entity itself.
        return null;

    if (bIgnoreWorldSpawn && trace_table.enthit.GetClassname() == "worldspawn")
        return null;

    return trace_table.pos;
}

::IsOnGround <- function(any_ent)
{
    if (any_ent.GetFlags() & 1) // FL_ONGROUND
        return true;

    return false;
}


// PLAYER
::GetPlayerName <- function(client)
{
    return NetProps.GetPropString(client, "m_szNetname");
}

::GetActiveWeapon <- function(client)
{
    return NetProps.GetPropEntity(client, "m_hActiveWeapon");
}

::GetLastWeapon <- function(client)
{
    return NetProps.GetPropEntity(client, "m_hLastWeapon");
}

::GetShotsFired <- function(client)
{   // Returns the shots fired of the player. The counter resets if the player stops shooting. (It doesn't include grenades).
    return NetProps.GetPropInt(client, "cslocaldata.m_iShotsFired");
}

::GetRagdoll <- function(client)
{   // Returns the handle of the ragdoll that belongs to the client.
    return NetProps.GetPropEntity(client, "m_hRagdoll");
}

::GetPlayerArmor <- function(client)
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.GetPropInt(client, "m_ArmorValue");
}

::SetPlayerArmor <- function(client, value)
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.SetPropInt(client, "m_ArmorValue", value);
}

::GetLastPlaceName <- function(client)
{   // [ONLY OFFICIAL MAPS] Returns the last place of a player (ex. "BombsiteA")
    return NetProps.GetPropString(client, "m_szLastPlaceName");
}

// Is "cs_player_manager" EntIndexToHScript(MaxClients().tointeger()+6)?
::GetPlayerUserID <- function(client)
{
    return NetProps.GetPropIntArray(Entities.FindByClassname(null, "cs_player_manager"), "m_iUserID", client.entindex());
}

::GetPlayerClass <- function(client)
{   // Returns the integer class of the player (Choosing a Phoenix and a "Seal Team 6"). See PLAYER_CLASS
    return NetProps.GetPropInt(client, "m_iClass");
}

::SetPlayerClass <- function(client, iClass, bShouldSetModel = false)   // If bShouldSetModel is true, the function will change the model as well.
{   // Changes the class of a player. Note: You can't set any class outside the team the player belongs in (ex. PHOENIX to SAS).
    local bHasChanged = false;
    local team = client.GetTeam();
    local models = [    // If valve dares to change the values...
        "models/player/t_phoenix.mdl",    // Spectator/Unassigned. This slot will never be used anyway.
        // Terrorist
        "models/player/t_phoenix.mdl",
        "models/player/t_leet.mdl",
        "models/player/t_arctic.mdl",
        "models/player/t_guerilla.mdl",
        // Counter-Terrorist
        "models/player/ct_urban.mdl",
        "models/player/ct_gsg9.mdl",
        "models/player/ct_sas.mdl",
        "models/player/ct_gign.mdl"
    ];
    
    if ((iClass > 0 && iClass < 9) && team > 1)
    {
        if (iClass <= 4 && team == 2)
        {
            NetProps.SetPropInt(client, "m_iClass", iClass);
            bHasChanged = true;
            print("TERROR")
        }
        else if (iClass >= 5 && team == 3)
        {
            NetProps.SetPropInt(client, "m_iClass", iClass);
            bHasChanged = true;
            print("CT")
        }
        if (bShouldSetModel && bHasChanged)
        {   
            // Matches easier behaviour of the SetModel input, automatically precaches, maintains sequence/cycle if possible. Also clears the bone cache.
            client.SetModelSimple(models[iClass]);
        } 
    }
    return;
}

::GetPlayerClassString <- function(client)
{   // Same as above, but it will return the name of the class
    local iClass = NetProps.GetPropInt(client, "m_iClass");
    switch (iClass) 
    {
        case 1:
            return "Phoenix Connexion";
        case 2:
            return "Elite Crew";
        case 3:
            return "Arctic Avengers";
        case 4:
            return "Guerilla Warfare";
        case 5:
            return "Seal Team 6";
        case 6:
            return "GSG-9";
        case 7:
            return "SAS";
        case 8:
            return "GIGN";
        default:
            return null;
    }
}

::GetPlayerScore <- function(client)
{   // Returns the score of the player.
    return NetProps.GetPropIntArray(Entities.FindByClassname(null, "cs_player_manager"), "m_iScore", client.entindex());
} // You cannot set the amount tho... You can use game_score in that case.

// ---------------------- GIVING SCORE TO PLAYERS --------------------- //
// Removing the main entity per script load in case round is not restarted. (Testing)
if (("CurrentMainGameScoreEnt" in this) && (CurrentMainGameScoreEnt != null && CurrentMainGameScoreEnt.IsValid()))
    CurrentMainGameScoreEnt.Kill();

// We don't want to create a lot of entites to run out of edicts in the same frame;
// Hopefully, we will only need one of these and the entity won't conflict with another game_score from the map (ZE maps).
::CurrentMainGameScoreEnt <- null;
::SetPlayerScore <- function(client, score, bConserveOldScore = false)
{   // Set's the score of the player. if bConserveOldScore is true, it won't reset the score before applying the new score value.
    if (!CurrentMainGameScoreEnt || CurrentMainGameScoreEnt == null || !CurrentMainGameScoreEnt.IsValid()) // Create a new game_score if our main entity doesn't exist yet.
    {
        CurrentMainGameScoreEnt = SpawnEntityFromTable("game_score", {targetname = UniqueString("game_score") spawnflags = 1});
    }
    local old_score = NetProps.GetPropIntArray(Entities.FindByClassname(null, "cs_player_manager"), "m_iScore", client.entindex());
    if (!bConserveOldScore)
    {
        old_score *= -1;
        CurrentMainGameScoreEnt.KeyValueFromInt("points", old_score);
        // Using EntFireByHandle() will do addition (ex. 10 will add 10 and -10 will substract 10 instead of substracting the current score).
        // A reasonable explanation is because this method isn't synchronous as the wiki states. It waits for the end of the current frame.
        // Basically we were calling those methods at the same time making the only "points" to apply from the penultimate line and never from the above line.
        // Hopefully, "AcceptInput" is a thing. It's processed instantly. Respecting the lineal order of this method.
        CurrentMainGameScoreEnt.AcceptInput("ApplyScore", "", client, null);
    }
    CurrentMainGameScoreEnt.KeyValueFromInt("points", score);
    CurrentMainGameScoreEnt.AcceptInput("ApplyScore", "", client, null);
}
// ---------------------- GIVING SCORE TO PLAYERS --------------------- //

::GetPlayerDeathAmount <- function(client)
{   // Returns the death amount of the player.
    return NetProps.GetPropInt(client, "m_iDeaths");
}   

::SetPlayerDeathAmount <- function(client, amount)
{   // Sets the death amount of the player.
    NetProps.SetPropInt(client, "m_iDeaths", amount);
}

::GetPlayerPing <- function(client)
{
    return NetProps.GetPropIntArray(Entities.FindByClassname(null, "cs_player_manager"), "m_iPing", client.entindex());
}

::GetPlayerClanTag <- function(client)
{
    return NetProps.GetPropStringArray(Entities.FindByClassname(null, "cs_player_manager"), "m_szClan", client.entindex());
}

// Check this: https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Fetching_player_name_or_Steam_ID
::GetNetworkIDString <- function(client)
{   // Same function from l4d2 but sadly css stores the id in a SteamID3 format instead of SteamID2. Also, it's not always available. You have been warned!
    return NetProps.GetPropString(client, "m_szNetworkIDString");
}

/* // BUG: DOESN'T WORK! The Array "m_iAccountID" doesn't exist when calling by GetPropIntArray() and GetPropArraySize() but it does when you use NetProps.GetTable()
::GetPlayerAccountID <- function(client)
{   // Returns the "AccountID" of the player (The third slot of a SteamID3)
    return NetProps.GetPropStringArray(Entities.FindByClassname(null, "cs_player_manager"), "m_iAccountID", client.entindex());
}
*/

::GetPlayerMVPs <- function(client)
{   // Retuns the times a player is the MVPs. Note: The amount doesn't reset when changing to the spectator team unless the spectator joins again to any team.
   return NetProps.GetPropIntArray(Entities.FindByClassname(null, "cs_player_manager"), "m_iMVPs", client.entindex());
}   // You cannot set the amount tho...

::GetThrowGrenadeCount <- function(client)
{   // Returns the "m_iThrowGrenadeCounter" netprop. It's kinda useless because it resets each 8 throws.
    // The amount doesn't reset when changing to the spectator team unless the spectator joins again to any team.
    return NetProps.GetPropInt(client, "m_iThrowGrenadeCounter");
}

::GetButtonMask <- function(client)
{   // L4D2's vscript function. Returns the buttons that are being pressed by the player.
    return NetProps.GetPropInt(client, "m_nButtons");
}

::GetMyWeapons <- function (client, bShouldPrint = false)
{   // Basically returns the netprop array "m_hMyWeapons" from a player.
    local m_hMyWeapons = [];
    local array_size = NetProps.GetPropArraySize(client, "m_hMyWeapons");   // Just in case.
    
    if (bShouldPrint)
        printl("====== m_hMyWeapons for: " + GetPlayerName(client) + " ======");
    for (local i = 0; i < array_size;  i++)
    {
        local wep = NetProps.GetPropEntityArray(client, "m_hMyWeapons", i);
        //if ((!wep || wep == null) && bShouldSkipNull)
            //continue;

        m_hMyWeapons.push(wep);
        if (bShouldPrint)
            printl("\tslot[" + i + "] = " + wep);
    }
    if (bShouldPrint)
        printl("=====================================================");

    return m_hMyWeapons;
}

::GetInvTable <- function(client, bShouldPrint = false) // Don't use this for another game than vanilla css. Requires GetMyWeapons method
{   // Similar as l4d2's GetInvTable but this will return the table instead. You can also decide if print the table in the console.
    // "item_defuser" is removed when is picked up by a player but "m_bHasDefuser" is set to true.
    // Same for "item_ngvs", with "m_bHasNightVision" is set to true.
    if (client.GetTeam() <= 1)
        return;

    local table = {};
    local m_hMyWeapons = GetMyWeapons(client);
    local primary = function()
    {
        if (client.GetTeam() == 2) // The c4 takes the slot2
            return m_hMyWeapons[3];
        else (client.GetTeam() == 3)
            return m_hMyWeapons[2];
    }

    local secondary = m_hMyWeapons[1];
    local melee = m_hMyWeapons[0];
    local grenade = m_hMyWeapons[4];
    local flashbang = function()
    {
        if (client.GetTeam() == 2) // It takes the slot 5
            return m_hMyWeapons[5];
        else (client.GetTeam() == 3) // It takes the slot 3
            return m_hMyWeapons[3];
    }

    local smokegrenade = function()
    {
        if (client.GetTeam() == 2) // It takes the slot 6
            return m_hMyWeapons[6];
        else (client.GetTeam() == 3) // It takes the slot 5
            return m_hMyWeapons[5];
    }
    local c4_bomb = function()
    {
        if (client.GetTeam() == 2) // It takes the slot 2 for TT
            return m_hMyWeapons[2];

        return null;
    }

    // Yeah, in CS:S, the slot order begins at 1.
    if (primary() != null && primary().IsValid())
        table["slot1"] <- primary();
    if (secondary != null && secondary.IsValid())
        table["slot2"] <- secondary;
    if (melee != null && melee.IsValid())
        table["slot3"] <- melee;
    if (grenade || flashbang() || smokegrenade())
    {   // In this case, we will store the grenades in an array
        table["slot4"] <- [];

        if (grenade != null && grenade.IsValid())
            table["slot4"].push(grenade);
        if (flashbang() != null && flashbang().IsValid())
            table["slot4"].push(flashbang());
        if (smokegrenade() != null && smokegrenade().IsValid())
            table["slot4"].push(smokegrenade());
    }
    if (c4_bomb() != null && c4_bomb().IsValid())
        table["slot5"] <- c4_bomb();

    if (bShouldPrint)
    {   // I'd rather to print this table manually
        printl("====== InvTable for: " + GetPlayerName(client) + " ======");
        if ("slot1" in table)
            printl("\tslot1 = " + table["slot1"]);
        if ("slot2" in table)
            printl("\tslot2 = " + table["slot2"]);
        if ("slot3" in table)
            printl("\tslot3 = " + table["slot3"]);
        if ("slot4" in table)
        {
            printl("\tslot4 = [");
            for (local i = 0; i < table["slot4"].len(); i++)
            {
                printl("\t\t" + table["slot4"][i] + ",");
            }
            printl("\t        ]");
        }
        if ("slot5" in table)
            printl("\tslot5 = " + table["slot5"]);
        printl("=====================================================");
    }
    return table;
}

::GetPlayerMoney <- function(client)
{   // Returns the in-game money amount of the player.
    return NetProps.GetPropInt(client, "m_iAccount");
}

::SetPlayerMoney <- function(client, amount)
{   // Sets the in-game money amount of the player. The maximun amount is 65535. No Patrick, you won't become rich from this.
    // Any value beyond it, will give you the rest of the money starting from 0 (ex. 65545 will set the m_iAccount to 9).
    if (amount <= 65535)    
        NetProps.SetPropInt(client, "m_iAccount", amount);
}

::ToggleDrawViewmodel <- function(client)
{   // Client-side function: hide or show the view model. It resets every round. Some entities like "point_viewcontrol" messes with the netprop.
    // It doesn't hide the muzzleflash.
    local m_bDrawViewmodel = NetProps.GetPropBool(client, "m_Local.m_bDrawViewmodel");
    if (m_bDrawViewmodel)
        NetProps.SetPropBool(client, "localdata.m_Local.m_bDrawViewmodel", false);
    else
        NetProps.SetPropBool(client, "localdata.m_Local.m_bDrawViewmodel", true);
}

::HasBombDefuser <- function(client)
{   // Returns true if the player has picked up a bomb defuser.
    // Wait, isn't this the same as NetProps.GetPropBoolArray(Entities.FindByClassname(null, "cs_player_manager"), "m_bHasDefuser", client.entindex())?¿
    return NetProps.GetPropBool(client, "m_bHasDefuser");
}

::HasHelmet <- function(client)
{   // Returns true if the player has helmet.
    return NetProps.GetPropBool(client, "m_bHasHelmet");
}

::HasNightvision <- function(client)
{   // Returns true if the player has nightvision.
    return NetProps.GetPropBool(client, "m_bHasNightVision");
}

::GetDominationList <- function(client, type = 0, bShouldPrint = false)
{   // Returns the array of "m_bPlayerDominated" (type = 0) and "m_bPlayerDominatingMe" (type = 1).
    local DominationList = [];
    local srtPropertyName = "m_bPlayerDominated";
    if (type == 1)
        srtPropertyName = "m_bPlayerDominatingMe";

    if (bShouldPrint)        
        printl("=========== " + srtPropertyName + " for: " + GetPlayerName(client) + " ===========");    
    for (local i = 0; i < 66; i++)
    {
        local bool = NetProps.GetPropBoolArray(client, srtPropertyName, i);
        DominationList.push(bool);

        if (bShouldPrint)
        {
            local player = PlayerInstanceFromIndex(i);
            printl("\tClientIndex [" + i + "] " + (player != null ? GetPlayerName(player) : "NULL") + " = " + bool);
        }
    }
    if (bShouldPrint)
        printl("=====================================================");

    return DominationList;
}

::IsDominatingMe <- function(client, who)
{   // Returns true if "who" is dominating the client.
    return NetProps.GetPropBoolArray(client, "cslocaldata.m_bPlayerDominatingMe", who.entindex());
}

::IsDominated <- function(client, who)
{   // Returns true if "who" is dominated by the client.
    return NetProps.GetPropBoolArray(client, "cslocaldata.m_bPlayerDominated", who.entindex());
}

// NOTE: This only works with bomb carriers. You may want to use GetBombPlayer() first. Otherwise, it will always return false.
::IsBombPlayerInBombsite <- function(client)  
{   // Returns true if the player is in the bomb trigger area.
    return NetProps.GetPropBool(client, "m_bInBombZone");
}

::IsDefusingBomb <- function(client)
{   // Returns true if the player is defusing the bomb.
    return NetProps.GetPropBool(client, "m_bIsDefusing");
}

::IsInBuyZone <- function(client)
{   // Returns true if the player is in their team buy zone area.
    return NetProps.GetPropBool(client, "m_bInBuyZone");
}

::IsNightvisionOn <- function(client)
{   // Returns true if the player has the nightvision on.
    return NetProps.GetPropBool(client, "m_bNightVisionOn");
}

// WEAPONS
::GetPrimaryAmmo <- function(client, weapon)
{   // Returns the primary ammo of a weapon. Only works for weapons with a player as the owner. Weird
    return NetProps.GetPropIntArray(client, "localdata.m_iAmmo", weapon.GetPrimaryAmmoType());
}

::SetPrimaryAmmo <- function(client, weapon, ammo)  // You can even set ammo for grenades. That's a nice incentive for flashbang waves.
{   // Sets the primary ammo of a weapon. Only works for weapons with a player as the owner. Weird
    NetProps.SetPropIntArray(client, "localdata.m_iAmmo", ammo, weapon.GetPrimaryAmmoType());
}

// READ: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions#CBaseCombatWeapon:~:text=by%20setting%20the-,m_bLagCompensation,-netprop%20%E2%86%93%20on
::ShootPrimaryAttack <- function(client)
{   // Shoots the primary attack of a weapon.
    NetProps.SetPropBool(client, "m_bLagCompensation", false);
    NetProps.GetPropEntity(client, "m_hActiveWeapon").PrimaryAttack();
    NetProps.SetPropBool(client, "m_bLagCompensation", true);
}


// VECTORS AND QANGLES
::StringToQAngle <- function(str, delimiter)
{   // Why did valve decide to convert the axis into integers instead of floats? That's illegalism! Fixed here. (TLS update as well)
    local qangle = QAngle(0, 0, 0);
    local result = split(str, delimiter);

    qangle.x = result[0].tofloat();
    qangle.y = result[1].tofloat();
    qangle.z = result[2].tofloat();

    return qangle;
}

::StringToVector <- function(str, delimiter)
{   // Why did valve decide to convert the axis into integers instead of floats? That's illegalism! Fixed here. (TLS update as well)
    local vec = Vector(0, 0, 0);
    local result = split(str, delimiter);

    vec.x = result[0].tofloat();
    vec.y = result[1].tofloat();
    vec.z = result[2].tofloat();

    return vec;
}

/*
    Syntax:
    GetVectorDistance(<Vector input>, <Vector reference>)
    startVector: The vector you want to start the distance.
    endVector: The vector you want to end the distance.
*/
::GetVectorDistance <- function(startVector, endVector)
{   // Returns the vector distance from a start to an end point. You may want to use Length() for a single unit distance.
    return endVector - startVector;
}

/*
    Syntax:
    ReflectFromVector(<Vector input>, <Vector reference>, <array AxisToExclude>)
    input: The vector you want to reflect.
    reference: The vector you want the <input> to reflect from.
    AxisToExclude: The axis of the <input> you want to exclude from being reflected.
*/
::ReflectFromVector <- function(input, reference, AxisToExclude = ["z"])
{   // Basically, returns the x, y, z prime values of input from a reference. "AxisToExclude" is an array to exclude axis to be reflected
    local vDistance = reference - input;
    local vPrime = reference + vDistance; // Prime vector are reflected values.
    // We want to filter whatever the user puts in the AxisToEclude param. Meaning, the only valid values are the vector axis 
    // Ex: ["x"], ["x", "y"], ["y"], ["z"].
    // Either way, you wouldn't want to use this for the 3 axis or it will just return the input vector.
    local PrimeTable = {x = vPrime.x y = vPrime.y z = vPrime.z};  

    for (local i = 0; i < AxisToEclude.len(); i++) 
    {
        local axis = AxisToEclude[i];
        // This is the part we are going to filter the valid axis.
        if (!(axis in PrimeTable))
            continue;

        vPrime[axis] = AxisToEclude[axis];
    }
    return vPrime;
}

// UTILS
::Ent <- function( idxorname )
{   // "Takes an entity index or name, returns the entity" - Ported from l4d2 scriptedmode.nuc
	local hEnt = null
	if ( typeof(idxorname) == "string" )
		hEnt = Entities.FindByName( null, idxorname );
	else if ( typeof(idxorname) == "integer" )
		hEnt = EntIndexToHScript( idxorname );
	if (hEnt)
		return hEnt;

	//printl( "Hey! no entity for " + idxorname );
}

::GetPlayers <- function(bShouldPrint = false)
{   // Returns the clients in an array.
    local players = [];
    for (local i = 1; i <= MaxPlayers; i++)
    {
        local player = PlayerInstanceFromIndex(i);  // We want clients, that's why we are not using Ent()
        if (!player || player == null || !player.IsValid())
            continue;

        players.push(player);

        if (bShouldPrint)
            printl(i + " | Name: " + GetPlayerName(player) + " | Team: " + player.GetTeam() + (IsPlayerABot(player) ? " | BOT": ""));
    }
    return players;
}

::GetBombPlayer <- function()
{   // Returns the index of the player that is carrying the bomb. There must be only one c4 per map.
    return NetProps.GetPropInt(Entities.FindByClassname(null, "cs_player_manager"), "m_iPlayerC4");
}

::GetBombPosition <- function()
{   // Returns the vector position of the bomb. There must be only one c4 per map.
    return NetProps.GetPropVector(Entities.FindByClassname(null, "cs_player_manager"), "m_vecC4");
}

::GetBombsitePosition <- function(position = "", bShouldPrint = false)
{   // Returns the center vector of a desired bombsite (based on func_bombsite center?). There are only "A" and "B" bombsites in a defuse map.
    // Warning: Calling another positions than 'a' and 'b' will return any of those two vectors spots.
    local sPos = position.toupper();
    local vPos = NetProps.GetPropVector(Entities.FindByClassname(null, "cs_player_manager"), "m_bombsiteCenter" + sPos);
    if (bShouldPrint)
        printl("Found Bombsite " + sPos + " at " + vPos.ToKVString());

    return vPos;
}



// MISC
::IsCheatingSession <- function()
{
    return (developer() > 0 || Convars.GetBool("sv_cheats")) ? true : false;
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
