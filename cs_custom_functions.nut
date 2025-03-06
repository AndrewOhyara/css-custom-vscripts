// Custom methods based on l4d2 vscript.
if (this != getroottable())
    throw "This script must the included in the root scope, please.";

const TEAM_UNASSIGNED = 0;  // "Select Team" screen.
const TEAM_SPECTATOR = 1;
const TEAM_TERRORIST = 2;
const TEAM_COUNTER_TERRORIST = 3;
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
::MaxPlayers <- MaxClients().tointeger(); // Extracted from: https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Iterating_Through_Players
::GetListenServerHost <- @() PlayerInstanceFromIndex(1);

// PLAYER
::GetPlayerName <- function(client)
{
    return NetProps.GetPropString(client, "m_szNetname");
}

::GetActiveWeapon <- function(client)
{
    return NetProps.GetPropEntity(client, "m_hActiveWeapon");
}

::GetPlayerArmor <- function(client)
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.GetPropInt(client, "m_ArmorValue");
}

::SetPlayerArmor <- function(client, value)
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.SetPropInt(client, "m_ArmorValue", value);
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
{
    return NetProps.GetPropInt(client, "m_nButtons");
}

::GetMyWeapons <- function (client, bShouldPrint = false)
{   // Basically returns the netprop array "m_hMyWeapons" from a player. [REMOVED] If 'bShouldSkipNull' is true, it will not include the null slots of the array.
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

::GetInvTable <- function(client, bShouldPrint = false) // Don't use this for another game than vanilla css.
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
    // Any value over this, will give you the rest of the money starting from 0 (ex. 65545 will set the m_iAccount to 9).
    if (amount <= 65535)    
        NetProps.SetPropInt(client, "m_iAccount", amount);
}

::ToggleDrawViewmodel <- function(client)
{   // Client-side function: hide or show the view model. It resets every round. Some entities like "point_viewcontrol" messes with the netprop.
    // It doesn't hide the muzzleflash.
    local m_bDrawViewmodel = NetProps.GetPropBool(client, "m_Local.m_bDrawViewmodel");
    if (m_bDrawViewmodel)
        NetProps.SetPropBool(client, "m_Local.m_bDrawViewmodel", false);
    else
        NetProps.SetPropBool(client, "m_Local.m_bDrawViewmodel", true);
}

::HasBombDefuser <- function(client)
{   // Returns true if the player has picked up a bomb defuser
    // Wait, isn't this the same as NetProps.GetPropBoolArray(Entities.FindByClassname(null, "cs_player_manager"), "m_bHasDefuser", client.entindex())?¿
    return NetProps.GetPropBool(client, "m_bHasDefuser");
}

// WEAPONS
::GetPrimaryAmmo <- function(client, weapon)
{   // Returns the primary ammo of a weapon. Only works for picked up weapons. Weird
    return NetProps.GetPropIntArray(client, "m_iAmmo", weapon.GetPrimaryAmmoType());
}

::SetPrimaryAmmo <- function(client, weapon, ammo)  // You can even set ammo for grenades. That's a nice incentive for flashbang waves.
{   // Sets the primary ammo of a weapon. Only works for picked up weapons. Weird
    NetProps.SetPropIntArray(client, "m_iAmmo", ammo, weapon.GetPrimaryAmmoType());
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

// UTILS
::Ent <- function( idxorname )
{   // "Takes an entity index or name, returns the entity" - Ported from scriptedmode.nuc
	local hEnt = null
	if ( typeof(idxorname) == "string" )
		hEnt = Entities.FindByName( null, idxorname );
	else if ( typeof(idxorname) == "integer" )
		hEnt = EntIndexToHScript( idxorname );
	if (hEnt)
		return hEnt;

	printl( "Hey! no entity for " + idxorname );
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
{   // Returns the index of the player that has picked up the bomb. There must be only one c4 per map.
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
    return (developer() > 0 || Convars.GetBool("sv_cheats") == "1") ? true : false;
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
