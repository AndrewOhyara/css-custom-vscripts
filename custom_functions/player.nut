// PLAYER
// Note: "CBaseMultiplayerPlayer" is the native class that handles the player entity in multiplayer games.
// So using this inside a function is basically referencing to the instance.

// GETTERS
CBaseMultiplayerPlayer.GetPlayerName <- function()
{
    return NetProps.GetPropString(this, "m_szNetname");
}

CBaseMultiplayerPlayer.GetActiveWeapon <- function()   // This does exist in TF2. But not here somehow
{
    return NetProps.GetPropEntity(this, "m_hActiveWeapon");
}

CBaseMultiplayerPlayer.GetLastWeapon <- function()
{
    return NetProps.GetPropEntity(this, "m_hLastWeapon");
}

// TIP: You may want to use this in a think function.
CBaseMultiplayerPlayer.GetShotsFired <- function()
{   // Returns the shots fired of the player. The counter resets if the player stops shooting. (It doesn't include grenades).
    return NetProps.GetPropInt(this, "cslocaldata.m_iShotsFired");
}

CBaseMultiplayerPlayer.GetPlayerRagdoll <- function()
{   // Returns the handle of the ragdoll that belongs to the this.
    return NetProps.GetPropEntity(this, "m_hRagdoll");
}

CBaseMultiplayerPlayer.GetPlayerArmor <- function()
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.GetPropInt(this, "m_ArmorValue");
}

CBaseMultiplayerPlayer.GetLastPlaceName <- function()
{   // [ONLY OFFICIAL MAPS] Returns the last place of a player (ex. "BombsiteA")
    return NetProps.GetPropString(this, "m_szLastPlaceName");
}

CBaseMultiplayerPlayer.GetPlayerUserID <- function()
{
    return NetProps.GetPropIntArray(::GetPlayerManager(), "m_iUserID", this.entindex());
}

CBaseMultiplayerPlayer.GetPlayerClass <- function()
{   // Returns the integer class of the player (Choosing a Phoenix and a "Seal Team 6"). See PLAYER_CLASS in "const.nut"
    return NetProps.GetPropInt(this, "m_iClass");
}

CBaseMultiplayerPlayer.GetPlayerClassString <- function()
{   // Same as above, but it will return the name of the class
    switch (GetPlayerClass()) 
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

CBaseMultiplayerPlayer.GetButtonMask <- function()
{   // L4D2's vscript function. Returns the buttons that are being pressed by the player.
    return NetProps.GetPropInt(this, "m_nButtons");
}

// Check this: https://developer.valvesoftware.com/wiki/Source_SDK_Base_2013/Scripting/VScript_Examples#Fetching_player_name_or_Steam_ID
// NOTE: The "fix" is added in this library.
CBaseMultiplayerPlayer.GetSteamID <- function()
{   // Returns the steam id of a player in STEAMID3 format. It's not always available. You have been warned!
    return strip(NetProps.GetPropString(this, "m_szNetworkIDString"));
}

// BUG: DOESN'T WORK! The Array "m_iAccountID" doesn't exist when calling by GetPropIntArray() and GetPropArraySize()
// but it does when you use NetProps.GetTable(), though that may be slower.
/*
CBaseMultiplayerPlayer.GetAccountID <- function()
{   // Returns the "AccountID" of the player (The third slot of a SteamID3)
    return NetProps.GetPropStringArray(GetPlayerManager(), "m_iAccountID", this.entindex());
}
*/


CBaseMultiplayerPlayer.GetMyWeapons <- function (bShouldPrint = false)
{   // Basically returns the netprop array "m_hMyWeapons" from a player.
    local m_hMyWeapons = [];
    local array_size = NetProps.GetPropArraySize(this, "m_hMyWeapons");   // Just in case.
    
    if (bShouldPrint)
        printl("====== m_hMyWeapons for: " + GetPlayerName() + " ======");
    for (local i = 0; i < array_size;  i++)
    {
        local wep = NetProps.GetPropEntityArray(this, "m_hMyWeapons", i);

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
CBaseMultiplayerPlayer.GetInvTable <- function(bShouldPrint = false) // Don't use this for another game than vanilla css. Requires GetMyWeapons method
{   // Similar as l4d2's GetInvTable but this will return the table instead. You can also decide to print the table in the console.
    local table = {};
    local weapons = GetMyWeapons();
    for (local i = 0; i < weapons.len(); i++)
    {
        local ent = weapons[i];
        if (!IsValidSafe(ent))
            continue;

        local slot = ent.GetSlot();

        if (slot == 0)
            table["slot0"] <- ent;
        else if (slot == 1)
            table["slot1"] <- ent;
        else if (slot == 2)
            table["slot2"] <- ent;
        else if (slot == 3)
        {
            if (!("slot3" in table))
                table["slot3"] <- array(3);

            if (ent.GetClassname() == "weapon_hegrenade")
                table["slot3"][0] = ent;
            else if (ent.GetClassname() == "weapon_flashbang")
                table["slot3"][1] = ent;
            else if (ent.GetClassname() == "weapon_smokegrenade")
                table["slot3"][2] = ent;  
        }
        else if (slot == 4)
            table["slot4"] <- ent;
    }

    if (bShouldPrint)
    {   // I'd rather to print this table manually
        printl("====== InvTable for: " + GetPlayerName() + " ======");
        if ("slot0" in table)
            printl("\tslot0 = " + table["slot0"]);
        if ("slot1" in table)
            printl("\tslot1 = " + table["slot1"]);
        if ("slot2" in table)
            printl("\tslot2 = " + table["slot2"]);
        if ("slot3" in table)
        {
            printl("\tslot3 = [");
            for (local i = 0; i < table["slot3"].len(); i++)
            {
                printl("\t\t" + table["slot3"][i] + ",");
            }
            printl("\t        ]");
        }
        if ("slot4" in table)
            printl("\tslot4 = " + table["slot4"]);
        printl("=====================================================");
    }
    return table;
}

CBaseMultiplayerPlayer.GetPlayerPing <- function()
{
    return NetProps.GetPropIntArray(::GetPlayerManager(), "m_iPing", this.entindex());
}

CBaseMultiplayerPlayer.GetPlayerClanTag <- function()
{
    return NetProps.GetPropStringArray(::GetPlayerManager(), "m_szClan", this.entindex());
}


// NOTES: 
// You cannot set the amount tho...
// The amount doesn't reset when changing to the spectator team unless the spectator joins again to any team.
CBaseMultiplayerPlayer.GetPlayerMVPs <- function()
{   // Retuns the MVPs of a player.
   return NetProps.GetPropIntArray(GetPlayerManager(), "m_iMVPs", this.entindex());
}

// NOTE: The amount doesn't reset when changing to the spectator team unless the spectator joins again to any team.
CBaseMultiplayerPlayer.GetThrowGrenadeCount <- function()
{   // Returns the "m_iThrowGrenadeCounter" netprop. It's kinda useless because it resets each 8 throws.
    return NetProps.GetPropInt(this, "m_iThrowGrenadeCounter");
}

CBaseMultiplayerPlayer.GetDeathAmount <- function()
{   // Returns the death amount of the player.
    return NetProps.GetPropInt(this, "m_iDeaths");
}   

CBaseMultiplayerPlayer.GetPlayerMoney <- function()
{   // Returns the in-game money amount of the player.
    return NetProps.GetPropInt(this, "m_iAccount");
}

CBaseMultiplayerPlayer.GetPlayerScore <- function()
{   // Returns the score of the player.
    return NetProps.GetPropIntArray(::GetPlayerManager(), "m_iScore", this.entindex());
} // You cannot set the amount tho... You can use game_score in that case.

CBaseMultiplayerPlayer.GetPlayerLanguage <- function()
{   // Returns the cl_language value from a player.
    return Convars.GetClientConvarValue("cl_language", this.entindex());
}

CBaseMultiplayerPlayer.GetConnectMethod <- function()
{   // Returns the cl_connectmethod from a player (How the this joined the server. E.g. listenserver, serverbrowser_internet, serverbrowser_favorites)
    return Convars.GetClientConvarValue("cl_connectmethod", this.entindex());
}

CBaseMultiplayerPlayer.GetPlayerLerp <- function() 
{   // Returns the value of "cl_interp" from a player
    return NetProps.GetPropFloat(this, "m_fLerpTime");
}

CBaseMultiplayerPlayer.GetLaggedMovementValue <- function() 
{   // Returns the value of "m_flLaggedMovementValue". (speed?)
    return NetProps.GetPropFloat(this, "m_flLaggedMovementValue");
}

// SETTERS
CBaseMultiplayerPlayer.SetLaggedMovementValue <- function(value) 
{
    NetProps.SetPropFloat(this, "m_flLaggedMovementValue", value);
}

// NOTE: Setting it more than 127 sets negative values while in the hud returns a different value
CBaseMultiplayerPlayer.SetPlayerArmor <- function(value)
{   // Returns the value of the armor (kevlar/kevlar+helmet).
    return NetProps.SetPropInt(this, "m_ArmorValue", value);
}

// NOTES:
// This may be used as a fix for the SAS throwing issue. Or you just can use SetModelSimple()
// Keep in mind if you don't set a model that belongs to its class, the class model will be set automatically in a new round.
CBaseMultiplayerPlayer.SetPlayerClass <- function(iClass, bShouldSetModel = false)
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
        NetProps.SetPropInt(this, "m_iClass", iClass);
        if (bShouldSetModel)
        {   
            // Matches easier behaviour of the SetModel input, automatically precaches, maintains sequence/cycle if possible. Also clears the bone cache.
            this.SetModelSimple(models[iClass]);
        } 
    }
}

CBaseMultiplayerPlayer.SetDeathAmount <- function(amount)
{   // Sets the death amount of the player. ToConfirm: It's reflected on the server.
    NetProps.SetPropInt(this, "m_iDeaths", amount);
}

// [FIXED] Any value beyond it, will give you the rest of the money starting from 0 (ex. 65545 will set the m_iAccount to 9).
CBaseMultiplayerPlayer.SetPlayerMoney <- function(amount)
{   // Sets the in-game money amount of the player. The maximun amount is 65535. No Patrick, you won't become rich from this.
    NetProps.SetPropInt(this, "m_iAccount", ::Clamp(amount, 0, 65535));
}

CBaseMultiplayerPlayer.SetPlayerScore <- function(score, bConserveOldScore = false)
{   // Set's the score of the player. if bConserveOldScore is true, it won't reset the score before applying the new score value.
    local game_score = SpawnEntityFromTable("game_score", {spawnflags = 1});    // Negative values flag
    local old_score = GetPlayerScore();
    if (!bConserveOldScore)
    {
        old_score *= -1;
        game_score.KeyValueFromInt("points", old_score);
        // Using EntFireByHandle() will do addition (ex. 10 will add 10 and -10 will substract 10 instead of substracting the current score).
        // A reasonable explanation is because this method isn't synchronous as the wiki states. It waits for the end of the current frame.
        // Basically we were calling those methods at the same time making the only "points" to apply from the penultimate line and never from the above line.
        // Hopefully, "AcceptInput" is a thing. It's processed instantly. Respecting the lineal order of this method.
        game_score.AcceptInput("ApplyScore", "", this, null);
    }
    game_score.KeyValueFromInt("points", score);
    game_score.AcceptInput("ApplyScore", "", this, null);
    game_score.Kill();
}

CBaseMultiplayerPlayer.SetPlayerTeam <- function(team)
{   // Changes the "m_iTeamNum" netprop. Unlike this.SetTeam(team), you won't die. But it may bring undesired effects.
    NetProps.SetPropInt(this, "m_iTeamNum", team);
}


// STATEMENTS
CBaseMultiplayerPlayer.HasBomb <- function() 
{   // Returns true if the player has the c4.
    local m_hMyWeapons = GetMyWeapons();
    for (local i = 0; i < m_hMyWeapons.len(); i++)
    {
        local weapon = m_hMyWeapons[i];
        if (!IsValidSafe(weapon))
            continue;

        if (weapon.GetClassname() == "weapon_c4")
            return true;
    }
    return false;
}

CBaseMultiplayerPlayer.HasBombDefuser <- function()
{   // Returns true if the player has picked up a bomb defuser.
    return NetProps.GetPropBool(this, "m_bHasDefuser");
}

CBaseMultiplayerPlayer.HasHelmet <- function()
{   // Returns true if the player has helmet.
    return NetProps.GetPropBool(this, "m_bHasHelmet");
}

CBaseMultiplayerPlayer.HasNightvision <- function()
{   // Returns true if the player has nightvision.
    return NetProps.GetPropBool(this, "m_bHasNightVision");
}

CBaseMultiplayerPlayer.HasDominated <- function(who)
{   // Returns true if "who" is dominated by the player.
    return NetProps.GetPropBoolArray(this, "cslocaldata.m_bPlayerDominated", who.entindex());
}

CBaseMultiplayerPlayer.IsDominatingMe <- function(who)
{   // Returns true if "who" is dominating the player.
    return NetProps.GetPropBoolArray(this, "cslocaldata.m_bPlayerDominatingMe", who.entindex());
}

CBaseMultiplayerPlayer.IsInBombsite <- function()  
{   // Returns true if the player is in the bomb trigger area.
    if (NetProps.GetPropBool(this, "m_bInBombZone"))
        return true;

    for (local trigger; trigger = Entities.FindByClassname(trigger, "func_bomb_target");)
    {
        if (IsValidSafe(trigger) && (::IsInTrigger(GetOrigin(), trigger) || ::IsInTrigger(GetCenter(), trigger) || ::IsInTrigger(EyePosition(), trigger)))
            return true;   
    }
    return false;
}

CBaseMultiplayerPlayer.IsInRescueZone <- function() 
{   // Returns true if the player is touching the "func_hostage_rescue" trigger.
    return NetProps.GetPropBool(this, "m_bInHostageRescueZone");
}

CBaseMultiplayerPlayer.IsDefusingBomb <- function()
{   // Returns true if the player is defusing the bomb.
    return NetProps.GetPropBool(this, "m_bIsDefusing");
}

CBaseMultiplayerPlayer.IsInBuyZone <- function()
{   // Returns true if the player is in their team buy zone area.
    return NetProps.GetPropBool(this, "m_bInBuyZone");
}

CBaseMultiplayerPlayer.IsNightvisionOn <- function()
{   // Returns true if the player has the nightvision on.
    return NetProps.GetPropBool(this, "m_bNightVisionOn");
}

CBaseMultiplayerPlayer.IsFlashlightOn <- function() 
{   // Returns true if the player has the flashligh on.
    return (NetProps.GetPropInt(this, "m_fEffects") & EF_DIMLIGHT) ? true : false;
}

// UTIL FUNCTIONS
::Player <- function(userid_or_name)
{   // "Takes a player userid or username, returns the player entity"
    local hPlayer = null;
    if (typeof userid_or_name == "string")
        hPlayer = GetPlayerByName(userid_or_name);
    else if (typeof userid_or_name == "integer")
        hPlayer = GetPlayerFromUserID(userid_or_name);
    
    if(IsValidSafe(hPlayer) && hPlayer.IsPlayer())
        return hPlayer; 
}

::GetPlayers <- function(bShouldPrint = false)
{   // Returns the clients in an array.
    local players = [];
    for (local i = 1; i <= MAXPLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);  // We want thiss, that's why we are not using Ent()
        if (!IsValidSafe(player))
            continue;

        players.push(player);

        if (bShouldPrint)
            printl(i + " | Name: " + player.GetPlayerName() + " | Team: " + player.GetTeam() + (IsPlayerABot(player) ? " | BOT": ""));
    }
    return players;
}

::GetPlayerByName <- function(stringUserName =  "")
{   // Returns the player handle by it's username...?
    local client = null;
    local name_to_look_for = RemoveQuotationMarks(strip(stringUserName)).tolower();
    local players = GetPlayers();
    for (local i = 0; i < players.len(); i++)
    {
        local player = players[i];
        if (!IsValidSafe(player))
            continue;

        local username = RemoveQuotationMarks(strip(player.GetPlayerName())).tolower();
        if (username == name_to_look_for || username.find(name_to_look_for) != null)
        {
            client = player;
            break;
        }
    }
    return client;
}

// Notes: 
// To use this, you must include the function like this:
/*
// Let's say you want to slay everyone:
DoAllPlayers(function(client){
    if ((client.GetTeam() != 2 && client.GetTeam() != 3))
        return;

    client.Slay(2) // DMG_BULLET
})
*/
::DoAllPlayers <- function(func, team = null, bIgnoreBots = false, bIgnoreHumans = false)
{   // Performs a method to each client. You can filter by team, bots and human players too.
    local players = ::GetPlayers();
    for (local i = 0; i < players.len(); i++)
    {
        local client = players[i];
        if (!IsValidSafe(client) || (team && client.GetTeam() != team) || (bIgnoreBots && IsPlayerABot(client)) || (bIgnoreHumans && !IsPlayerABot(client)))
            continue;

        func(client);   // It took me 2 days to understand this line.
    }
}

CBaseMultiplayerPlayer.GetDominationList <- function(type = 0, bShouldPrint = false)
{   // Returns the array of "m_bPlayerDominated" (type = 0) and "m_bPlayerDominatingMe" (type = 1).
    if (!IsValidSafe(this) || GetClassname() != "player")
        return;

    local DominationList = [];
    local srtPropertyName = "m_bPlayerDominated";
    if (type == 1)
        srtPropertyName = "m_bPlayerDominatingMe";

    local lenght = NetProps.GetPropArraySize(this, srtPropertyName);
    if (bShouldPrint)        
        printl("=========== " + srtPropertyName + " for: " + GetPlayerName() + " ===========");    
    for (local i = 0; i < lenght; i++)
    {
        local bool = NetProps.GetPropBoolArray(this, srtPropertyName, i);
        DominationList.push(bool);

        if (bShouldPrint)
        {
            local player = PlayerInstanceFromIndex(i);
            printl("\tIndex [" + i + "] " + (player != null ? player.GetPlayerName() : "NULL") + " = " + bool);
        }
    }
    if (bShouldPrint)
        printl("=====================================================");

    return DominationList;
}

// NOTE: It doesn't hide the muzzleflash.
CBaseMultiplayerPlayer.ToggleDrawViewmodel <- function()
{   // client-side: hide or show the view model. It resets every round. Some entities like "point_viewcontrol" messes with the netprop.
    local m_bDrawViewmodel = NetProps.GetPropBool(this, "m_Local.m_bDrawViewmodel");
    if (m_bDrawViewmodel)
        NetProps.SetPropBool(this, "localdata.m_Local.m_bDrawViewmodel", false);
    else
        NetProps.SetPropBool(this, "localdata.m_Local.m_bDrawViewmodel", true);
}

// NOTE: 
// If mp_friendlyfire is 0 and the client and the attacker are in the same team, the client won't be slayed unless you enable ff.
CBaseMultiplayerPlayer.Slay <- function(dmg_type = DMG_GENERIC, attacker = WORLDSPAWN)
{   // Slays a player. By default, the attacker is the world. Setting to null, the victim is the client.
    TakeDamage(GetMaxHealth() * GetMaxHealth(), dmg_type, attacker);
}

CBaseMultiplayerPlayer.SwapTeam <- function(bShouldSetModel = false)
{   // Swaps the player team. Only for CT and TT players.
    local iClass = GetPlayerClass();
    if (GetTeam() != 2 && GetTeam() !=  3)
        return;

    switch (iClass) 
    {
        // TERRORIST
        case CS_PLAYER_CLASS.PHOENIX_CONNEXION:
            SetPlayerTeam(3);
            SetPlayerClass(CS_PLAYER_CLASS.SEAL_TEAM_6, bShouldSetModel);
            break;
        case CS_PLAYER_CLASS.ELITE_CREW:
            SetPlayerTeam(3);
            SetPlayerClass(CS_PLAYER_CLASS.GSG_9, bShouldSetModel);
            break;
        case CS_PLAYER_CLASS.ARCTIC_AVENGERS:
            SetPlayerTeam(3);
            SetPlayerClass(CS_PLAYER_CLASS.SAS, bShouldSetModel);
            break;
        case CS_PLAYER_CLASS.GUERILLA_WARFARE:
            SetPlayerTeam(3);
            SetPlayerClass(CS_PLAYER_CLASS.GIGN, bShouldSetModel);
            break;
        // COUNTER-TERRORIST
        case CS_PLAYER_CLASS.SEAL_TEAM_6:
            SetPlayerTeam(2);
            SetPlayerClass(CS_PLAYER_CLASS.PHOENIX_CONNEXION, bShouldSetModel);
            break;
        case CS_PLAYER_CLASS.GSG_9:
            SetPlayerTeam(2);
            SetPlayerClass(CS_PLAYER_CLASS.ELITE_CREW, bShouldSetModel);
            break;
        case CS_PLAYER_CLASS.SAS:
            SetPlayerTeam(2);
            SetPlayerClass(CS_PLAYER_CLASS.ARCTIC_AVENGERS, bShouldSetModel);
            break;
        case CS_PLAYER_CLASS.GIGN:
            SetPlayerTeam(2);
            SetPlayerClass(CS_PLAYER_CLASS.GUERILLA_WARFARE, bShouldSetModel);
    }
}

// NOTE: It won't work unless everyone has changed their collision group to 2 or 17
CBaseMultiplayerPlayer.ToggleNoblock <- function() 
{   // Enables/Disables the player colliding with another players.
    local collision_group = GetCollisionGroup();
    if (collision_group != 2 && collision_group !=  17)   
    {
        SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER);   // 2
    }
    else 
    {
        SetCollisionGroup(COLLISION_GROUP_PLAYER);
    }
}

CBaseMultiplayerPlayer.IssueCommand <- function(command)
{   // Executes a command on the client. (Only SERVER_CAN_EXECUTE)
    local point_clientcommand = Entities.CreateByClassname("point_clientcommand");
    point_clientcommand.AcceptInput("Command", command, this, this);
    EntFireByHandle(point_clientcommand, "Kill", "", 0.01, null, null);
}

CBaseMultiplayerPlayer.ForceRespawn <- function(bIgnoreLifeState = true)
{   // Respawns the player. if "bIgnoreLifeState" is false, it won't do anything if the player is alive.
    if (!bIgnoreLifeState && IsAlive())
        return;

    // According to the wiki, the player must set their "m_iPlayerState" netprop to 0 before using DispatchSpawn() method so they will fully respawn.
    NetProps.SetPropInt(this, "m_iPlayerState", 0);   // 0 is alive.
    DispatchSpawn();
}

// READ: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions#CBaseCombatWeapon:~:text=by%20setting%20the-,m_bLagCompensation,-netprop%20%E2%86%93%20on
CBaseMultiplayerPlayer.ForcePrimaryAttack <- function()
{   // Forces the primary attack of a weapon.
    NetProps.SetPropBool(this, "m_bLagCompensation", false);
    GetActiveWeapon().PrimaryAttack();
    NetProps.SetPropBool(this, "m_bLagCompensation", true);
}

CBaseMultiplayerPlayer.ForceSecondaryAttack <- function()
{   // Forces the secondary attack of a weapon.
    // The lagcomp doesn't make sense cause css doesn't have secondary attacks. Instead they are weapon modes (burst mode, silencer, zoom)
    // But i will leave it as it is just in case.
    NetProps.SetPropBool(this, "m_bLagCompensation", false);
    GetActiveWeapon().SecondaryAttack();
    NetProps.SetPropBool(this, "m_bLagCompensation", true);
}

CBaseMultiplayerPlayer.ForceSay <- function(msg, teamonly = false)
{   // Force the player to say anything
    Say(this, msg, teamonly);
}

// NOTES: 
// The ammo_amount paramter is for setting a custom value for your weapon.
// The reason i am doing this, it's because i don't want to use Convars.GetFloat("<ammo_ammotype_max>")
// That method is slow due reading the entire list of cvars at calling.
// Imagine doing a function that gives a new weapon to everyone.
CBaseMultiplayerPlayer.GiveItem <- function(item, ammo_amount = 0)
{   // Gives an item to the player. Returns the weapon handle. For "item_*" entities. It won't return the handle.
    if (!startswith(item, "weapon_") && !startswith(item, "item_"))
        return;

    // For some reason, item_ entities don't always equip on player, meaning they still exist in the world, adding to the edict count.
    // The best way to avoid this is just faking the pickup
    local my_item = SpawnEntityFromTable(item, {origin = GetOrigin() ammo = ammo_amount});

    if (IsValidSafe(my_item))
        return my_item;
}

CBaseMultiplayerPlayer.ToggleFlashlight <- function(bShouldPlaySound = true)
{   // Turns on/off the player's flashlight. This may not work if mp_flashlight is 0. If bShouldPlaySound is true, it will play the flashlight sound on the player
    if (!IsFlashlightOn())
    {
        if (bShouldPlaySound)
            EmitSoundOnClient("Player.FlashlightOn", this);

        ::AddEffectFlag(this, EF_DIMLIGHT);
    }
    else
    {
        if (bShouldPlaySound)
            EmitSoundOnClient("Player.FlashlightOff", this);    // Who knows if the client uses a different sound for this gamesound.

        ::RemoveEffectFlag(this, EF_DIMLIGHT);
    }
}


