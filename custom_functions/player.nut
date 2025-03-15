// PLAYER

// GETTERS
::GetPlayerName <- function(client)
{
    return NetProps.GetPropString(client, "m_szNetname");
}

::GetActiveWeapon <- function(client)   // This does exist in TF2.
{
    return NetProps.GetPropEntity(client, "m_hActiveWeapon");
}

::GetLastWeapon <- function(client)
{
    return NetProps.GetPropEntity(client, "m_hLastWeapon");
}

// TIP: You may want to use this in a think function.
::GetShotsFired <- function(client)
{   // Returns the shots fired of the player. The counter resets if the player stops shooting. (It doesn't include grenades).
    return NetProps.GetPropInt(client, "cslocaldata.m_iShotsFired");
}

::GetPlayerRagdoll <- function(client)
{   // Returns the handle of the ragdoll that belongs to the client.
    return NetProps.GetPropEntity(client, "m_hRagdoll");
}

::GetPlayerArmor <- function(client)
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.GetPropInt(client, "m_ArmorValue");
}

::GetLastPlaceName <- function(client)
{   // [ONLY OFFICIAL MAPS] Returns the last place of a player (ex. "BombsiteA")
    return NetProps.GetPropString(client, "m_szLastPlaceName");
}

// Is "cs_player_manager" EntIndexToHScript(MaxClients().tointeger()+6)?
::GetPlayerUserID <- function(client)
{
    return NetProps.GetPropIntArray(PLAYER_MANAGER_ENTITY, "m_iUserID", client.entindex());
}


::GetPlayerClass <- function(client)
{   // Returns the integer class of the player (Choosing a Phoenix and a "Seal Team 6"). See PLAYER_CLASS in "const.nut"
    return NetProps.GetPropInt(client, "m_iClass");
}

::GetPlayerClassString <- function(client)
{   // Same as above, but it will return the name of the class
    switch (GetPlayerClass(client)) 
    {
        case CS_PLAYER_CLASS.PHOENIX_CONNEXION:
            return "Phoenix Connexion";
        case CS_PLAYER_CLASS.ELITE_CREW:
            return "Elite Crew";
        case CS_PLAYER_CLASS.ARCTIC_AVENGERS:
            return "Arctic Avengers";
        case CS_PLAYER_CLASS.GUERILLA_WARFARE:
            return "Guerilla Warfare";
        case CS_PLAYER_CLASS.SEAL_TEAM_6:
            return "Seal Team 6";
        case CS_PLAYER_CLASS.GSG_9:
            return "GSG-9";
        case CS_PLAYER_CLASS.SAS:
            return "SAS";
        case CS_PLAYER_CLASS.GIGN:
            return "GIGN";
        default:
            return null;
    }
}

::GetButtonMask <- function(client)
{   // L4D2's vscript function. Returns the buttons that are being pressed by the player.
    return NetProps.GetPropInt(client, "m_nButtons");
}

// Check this: https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Fetching_player_name_or_Steam_ID
::GetNetworkIDString <- function(client)
{   // Same function from l4d2 but sadly css stores the id in a SteamID3 format instead of SteamID2. Also, it's not always available. You have been warned!
    return NetProps.GetPropString(client, "m_szNetworkIDString");
}

// BUG: DOESN'T WORK! The Array "m_iAccountID" doesn't exist when calling by GetPropIntArray() and GetPropArraySize()
// but it does when you use NetProps.GetTable()
/*
::GetAccountID <- function(client)
{   // Returns the "AccountID" of the player (The third slot of a SteamID3)
    return NetProps.GetPropStringArray(PLAYER_MANAGER_ENTITY, "m_iAccountID", client.entindex());
}
*/


::GetMyWeapons <- function (client, bShouldPrint = false)
{   // Basically returns the netprop array "m_hMyWeapons" from a player.
    local m_hMyWeapons = [];
    local array_size = NetProps.GetPropArraySize(client, "m_hMyWeapons");   // Just in case.
    
    if (bShouldPrint)
        printl("====== m_hMyWeapons for: " + GetPlayerName(client) + " ======");
    for (local i = 0; i < array_size;  i++)
    {
        local wep = NetProps.GetPropEntityArray(client, "m_hMyWeapons", i);

        m_hMyWeapons.push(wep);
        if (bShouldPrint)
            printl("\tslot[" + i + "] = " + wep);
    }
    if (bShouldPrint)
        printl("=====================================================");

    return m_hMyWeapons;
}

// NOTES:
// "item_defuser" is removed when is picked up by a player but "m_bHasDefuser" is set to true.
// Same for "item_ngvs", with "m_bHasNightVision" is set to true.
::GetInvTable <- function(client, bShouldPrint = false) // Don't use this for another game than vanilla css. Requires GetMyWeapons method
{   // Similar as l4d2's GetInvTable but this will return the table instead. You can also decide to print the table in the console.
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
    if (primary() != null && IsValidSafe(primary()))
        table["slot1"] <- primary();
    if (secondary != null && IsValidSafe(secondary))
        table["slot2"] <- secondary;
    if (melee != null && IsValidSafe(melee))
        table["slot3"] <- melee;
    if (grenade || flashbang() || smokegrenade())
    {   // In this case, we will store the grenades in an array
        table["slot4"] <- [];

        if (grenade != null && IsValidSafe(grenade))
            table["slot4"].push(grenade);
        if (flashbang() != null && IsValidSafe(flashbang()))
            table["slot4"].push(flashbang());
        if (smokegrenade() != null && IsValidSafe(smokegrenade()))
            table["slot4"].push(smokegrenade());
    }
    if (c4_bomb() != null && IsValidSafe(c4_bomb()))
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

::GetPlayerPing <- function(client)
{
    return NetProps.GetPropIntArray(PLAYER_MANAGER_ENTITY, "m_iPing", client.entindex());
}

::GetPlayerClanTag <- function(client)
{
    return NetProps.GetPropStringArray(PLAYER_MANAGER_ENTITY, "m_szClan", client.entindex());
}


// NOTES: 
// You cannot set the amount tho...
// The amount doesn't reset when changing to the spectator team unless the spectator joins again to any team.
::GetPlayerMVPs <- function(client)
{   // Retuns the MVPs of a player.
   return NetProps.GetPropIntArray(PLAYER_MANAGER_ENTITY, "m_iMVPs", client.entindex());
}

// NOTE: The amount doesn't reset when changing to the spectator team unless the spectator joins again to any team.
::GetThrowGrenadeCount <- function(client)
{   // Returns the "m_iThrowGrenadeCounter" netprop. It's kinda useless because it resets each 8 throws.
    return NetProps.GetPropInt(client, "m_iThrowGrenadeCounter");
}

::GetPlayerDeathAmount <- function(client)
{   // Returns the death amount of the player.
    return NetProps.GetPropInt(client, "m_iDeaths");
}   

::GetPlayerMoney <- function(client)
{   // Returns the in-game money amount of the player.
    return NetProps.GetPropInt(client, "m_iAccount");
}

::GetPlayerScore <- function(client)
{   // Returns the score of the player.
    return NetProps.GetPropIntArray(PLAYER_MANAGER_ENTITY, "m_iScore", client.entindex());
} // You cannot set the amount tho... You can use game_score in that case.

::GetPlayerLanguage <- function(client)
{   // Returns the cl_language value from a player.
    Convars.GetClientConvarValue("cl_language", client.entindex());
}

::GetConnectMethod <- function(client)
{   // Returns the cl_connectmethod from a player (How the client joined the server. E.g. listenserver, serverbrowser_internet, serverbrowser_favorites)
    Convars.GetClientConvarValue("cl_connectmethod", client.entindex());
}




// SETTERS
::SetPlayerArmor <- function(client, value)
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.SetPropInt(client, "m_ArmorValue", value);
}


// NOTES:
// This may be used as a fix for the SAS throwing issue. Or you just can use SetModelSimple()
// Keep in mind if you don't set a model that belongs to its class, the class model will be set automatically in a new round.
::SetPlayerClass <- function(client, iClass, bShouldSetModel = false)
{   // Changes the class of a player. If bShouldSetModel is true, the function will change the model as well.
    local bHasChanged = false;
    local models = [    // If valve dares to change the values...
        CS_PLAYER_SKIN.NO_CLASS,    // Spectator/Unassigned. This slot will never be used anyway.
        // Terrorist
        CS_PLAYER_SKIN.PHOENIX_CONNEXION,
        CS_PLAYER_SKIN.ELITE_CREW,
        CS_PLAYER_SKIN.ARCTIC_AVENGERS,
        CS_PLAYER_SKIN.GUERILLA_WARFARE,
        // Counter-Terrorist
        CS_PLAYER_SKIN.SEAL_TEAM_6,
        CS_PLAYER_SKIN.GSG_9,
        CS_PLAYER_SKIN.SAS,
        CS_PLAYER_SKIN.GIGN,
    ];
    
    if (iClass > 0 && iClass < 9)
    {
        NetProps.SetPropInt(client, "m_iClass", iClass);
        if (bShouldSetModel)
        {   
            // Matches easier behaviour of the SetModel input, automatically precaches, maintains sequence/cycle if possible. Also clears the bone cache.
            client.SetModelSimple(models[iClass]);
        } 
    }
}

::SetPlayerDeathAmount <- function(client, amount)
{   // Sets the death amount of the player. ToConfirm: It's reflected on the server.
    NetProps.SetPropInt(client, "m_iDeaths", amount);
}

// [FIXED] Any value beyond it, will give you the rest of the money starting from 0 (ex. 65545 will set the m_iAccount to 9).
::SetPlayerMoney <- function(client, amount)
{   // Sets the in-game money amount of the player. The maximun amount is 65535. No Patrick, you won't become rich from this.
    NetProps.SetPropInt(client, "m_iAccount", Clamp(amount, 0, 65535));
}

// ---------------------- GIVING SCORE TO PLAYERS --------------------- //
// Removing the main entity per script load in case round is not restarted. (Testing)
if (("CurrentMainGameScoreEnt" in this) && (CurrentMainGameScoreEnt != null && CurrentMainGameScoreEnt.IsValid()))
    CurrentMainGameScoreEnt.Kill();

// We don't want to create a lot of entites to run out of edicts in the same frame;
// Hopefully, we will only need one of these and the entity won't conflict with another game_score from the map (ZE maps).
::CurrentMainGameScoreEnt <- null;
::SetPlayerScore <- function(client, score, bConserveOldScore = false)
{   // Set's the score of the player. if bConserveOldScore is true, it won't reset the score before applying the new score value.
    if (!IsValidSafe(CurrentMainGameScoreEnt))
    {   // Create a new game_score if our main entity doesn't exist yet.
        CurrentMainGameScoreEnt = SpawnEntityFromTable("game_score", {targetname = UniqueString("game_score") spawnflags = 1});
    }
    local old_score = GetPlayerScore(client);
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





// STATEMENTS
::HasBombDefuser <- function(client)
{   // Returns true if the player has picked up a bomb defuser.
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

// UTIL FUNCTIONS
::GetPlayers <- function(bShouldPrint = false)
{   // Returns the clients in an array.
    local players = [];
    for (local i = 1; i <= MAXPLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);  // We want clients, that's why we are not using Ent()
        if (!IsValidSafe(player))
            continue;

        players.push(player);

        if (bShouldPrint)
            printl(i + " | Name: " + GetPlayerName(player) + " | Team: " + player.GetTeam() + (IsPlayerABot(player) ? " | BOT": ""));
    }
    return players;
}

::GetPlayerByName <- function(stringUserName =  "")
{   // Returns the player handle by it's username...?
    local client = null;
    local name_to_look_for = strip(stringUserName).tolower();
    local players = GetPlayers();
    for (local i = 0; i < players.len(); i++)
    {
        local player = players[i];
        if (!IsValidSafe(player))
            continue;

        local username = strip(GetPlayerName(player)).tolower();
        if (username == name_to_look_for || username.find(name_to_look_for) != null)
        {
            client = player;
            break;
        }
    }
    return client;
}

::GetDominationList <- function(client, type = 0, bShouldPrint = false)
{   // Returns the array of "m_bPlayerDominated" (type = 0) and "m_bPlayerDominatingMe" (type = 1).
    if (!IsValidSafe(client) || client.GetClassname() != "player")
        return;

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

// NOTE: It doesn't hide the muzzleflash.
::ToggleDrawViewmodel <- function(client)
{   // Client-side: hide or show the view model. It resets every round. Some entities like "point_viewcontrol" messes with the netprop.
    local m_bDrawViewmodel = NetProps.GetPropBool(client, "m_Local.m_bDrawViewmodel");
    if (m_bDrawViewmodel)
        NetProps.SetPropBool(client, "localdata.m_Local.m_bDrawViewmodel", false);
    else
        NetProps.SetPropBool(client, "localdata.m_Local.m_bDrawViewmodel", true);
}

