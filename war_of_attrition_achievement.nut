if ("WAAachievement" in this)
    WAAachievement.clear();

::WAAachievement <- 
{
    bEnabled = true
    OppositeHostTeam = -1
    ClearStringFromPool =  function(string)
    {
        local dummy = Entities.CreateByClassname("info_target");
        dummy.KeyValueFromString("targetname", string);
        NetProps.SetPropBool(dummy, "m_bForcePurgeFixedupStrings", true);
        dummy.Destroy();
    }

    EntFireCodeSafe =  function(entity, code, delay = 0.0, activator = null, caller = null)
    {
        EntFireByHandle(entity, "RunScriptCode", code, delay, activator, caller);
        ::WAAachievement.ClearStringFromPool(code);
    }

    SlayTeam = function(team = -1, bIgnoreHumanClients = false)   // UNASSIGNED = 0 | SPEC = 1 | TT = 2 | CT = 3
    {   // For a faster call , you may want to use GetPlayers() from custom_functions/player.nut.
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
            WAAachievement.SlayTeam(host_team, true);

            if (host_team == 2)
                WAAachievement.OppositeHostTeam = 3;
            else if (host_team == 3)
                WAAachievement.OppositeHostTeam = 2;
        }
    }

    SlayOppositeHostTeam = function()
    {
        WAAachievement.SlayTeam(WAAachievement.OppositeHostTeam);
    }

    OnGameEvent_round_freeze_end = function (params) 
    {
        if (!WAAachievement.bEnabled)
            return;
            
        EntFireCodeSafe(Entities.First(), "WAAachievement.SlayHostTeam()", 0.2, null, null);
        EntFireCodeSafe(Entities.First(), "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 4\")", 1, null, null);
        EntFireCodeSafe(Entities.First(), "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 3\")", 2, null, null);
        EntFireCodeSafe(Entities.First(), "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 2\")", 3, null, null);
        EntFireCodeSafe(Entities.First(), "ClientPrint(null, 3,  \"\x07FFFFFF\" + \"KILLING YOUR ENEMIES IN... 1\")", 4, null, null);
        EntFireCodeSafe(Entities.First(), "ClientPrint(null, 3,  \"\x07FF3F3F\" + \"PERISH!\")", 5, null, null);
        EntFireCodeSafe(Entities.First(), "WAAachievement.SlayOppositeHostTeam()", 5, null, null);
    }
}
__CollectGameEventCallbacks(WAAachievement);
