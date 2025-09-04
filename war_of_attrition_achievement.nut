::MaxPlayers <- MaxClients().tointeger();

if ("WAAachievement" in this)
    WAAachievement.clear();

::WAAachievement <- 
{
    bEnabled = true
    OppositeHostTeam = -1
    RunWithDelay = function(func, delay = 0.0)
	{
		local worldspawn = Entities.First();	
		worldspawn.ValidateScriptScope();
		local worldspawn_scope = worldspawn.GetScriptScope();
		local func_name = UniqueString();
		worldspawn_scope[func_name] <- function[this]()
		{
			delete worldspawn_scope[func_name];
			func();
		}
		EntFireByHandle(worldspawn, "CallScriptFunction", func_name, delay, null, null);
		return func_name;
	}

    SlayTeam = function(team = -1, bIgnoreHumanClients = false)   // UNASSIGNED = 0 | SPEC = 1 | TT = 2 | CT = 3
    {
        for (local i = 1; i <= MaxPlayers; i++)
        {
            local client = PlayerInstanceFromIndex(i);
            if (!client || client.GetTeam() != team || (bIgnoreHumanClients && !IsPlayerABot(client)))
                continue;

            client.TakeDamage(client.GetHealth() * client.GetHealth(), 0, Entities.First());    // DMG_GENERIC
        }
    }

    SlayHostTeam = function()
    {
        local host = PlayerInstanceFromIndex(1); // Safe GetListenServerHost()
        if (host != null && host.IsValid())
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
            
        RunWithDelay(@() WAAachievement.SlayHostTeam(), 0.2);
        RunWithDelay(@() ClientPrint(null, 3,  "\x07FFFFFF" + "KILLING YOUR ENEMIES IN... 4"), 1);
        RunWithDelay(@() ClientPrint(null, 3,  "\x07FFFFFF" + "KILLING YOUR ENEMIES IN... 3"), 2);
        RunWithDelay(@() ClientPrint(null, 3,  "\x07FFFFFF" + "KILLING YOUR ENEMIES IN... 2"), 3);
        RunWithDelay(@() ClientPrint(null, 3,  "\x07FFFFFF" + "KILLING YOUR ENEMIES IN... 1"), 4);
        RunWithDelay(@() ClientPrint(null, 3,  "\x07FF3F3F" + "PERISH!"), 5);
        RunWithDelay(@() WAAachievement.SlayOppositeHostTeam(), 5);
    }
}
__CollectGameEventCallbacks(WAAachievement);
