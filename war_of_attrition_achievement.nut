if ("WarOfAttritionAchievement" in this)
    WarOfAttritionAchievement.clear();

::WarOfAttritionAchievement <- 
{
    OppositeHostTeam = -1
    SlayTeam = function(team = -1, bIgnoreHumanClients = false)   // UNASSIGNED = 0 | SPEC = 1 | TT = 2 | CT = 3
    {   // For a faster call , you may want to use GetPlayers() from cs_custom_functions.
        for (local client; client = Entities.FindByClassname(client, "player");)
        {
            if ((client != null && client.IsValid()) && client.GetTeam() == team)
            {
                if (bIgnoreHumanClients && !IsPlayerABot(client))
                    continue;

                client.TakeDamage(client.GetMaxHealth() * client.GetMaxHealth(), 0, Entities.First());  // DMG_GENERIC
            }
        }
    }

    SlayHostTeam = function()
    {
        local host = PlayerInstanceFromIndex(1); // Safe GetListenServerHost()
        if (host != null && host.IsValid() && host.IsPlayer())
        {
            local host_team = host.GetTeam();
            ClientPrint(null, 3, "\x07FF3F3F" + "KILLING YOUR TEAM...");
            WarOfAttritionAchievement.SlayTeam(host_team, true);
            if (host_team == 2)
            {
                WarOfAttritionAchievement.OppositeHostTeam = 3;
            }
            else if (host_team == 3)
            {
                WarOfAttritionAchievement.OppositeHostTeam = 2;
            }
        }
    }

    SlayOppositeHostTeam = function()
    {
        WarOfAttritionAchievement.SlayTeam(WarOfAttritionAchievement.OppositeHostTeam);
    }

    OnGameEvent_round_freeze_end = function (params) 
    {
        EntFireByHandle(Entities.First(), "RunScriptCode", "WarOfAttritionAchievement.SlayHostTeam()", 0.2, null, null);
        EntFireByHandle(Entities.First(), "RunScriptCode", "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 4\")", 1, null, null);
        EntFireByHandle(Entities.First(), "RunScriptCode", "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 3\")", 2, null, null);
        EntFireByHandle(Entities.First(), "RunScriptCode", "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 2\")", 3, null, null);
        EntFireByHandle(Entities.First(), "RunScriptCode", "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 1\")", 4, null, null);
        EntFireByHandle(Entities.First(), "RunScriptCode", "ClientPrint(null, 3,  \"\x07FF3F3F\" + \"PERISH!\")", 5, null, null);
        EntFireByHandle(Entities.First(), "RunScriptCode", "WarOfAttritionAchievement.SlayOppositeHostTeam()", 5, null, null);
    }
}
__CollectGameEventCallbacks(WarOfAttritionAchievement);