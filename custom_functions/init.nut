// Custom methods based on l4d2 vscript.
if (this != getroottable())
    throw "[CSSCF] This script must the included in the root scope, please.";

if ("CSSCF_ACTIVE" in getconsttable() && getconsttable()["CSSCF_ACTIVE"])
    throw "[CSSCF] This script is already loaded.";

local csscf_version = 0.1;
if ("CSSCF_VERSION" in getconsttable() && getconsttable()["CSSCF_VERSION"] < csscf_version)
    throw "[CSSCF] This script is outdated.";

Msg("\n[CSS Custom Functions] Loading script...\n");
Entities.First().ValidateScriptScope(); // In case we want to store anything before reloading this file.

// GLOBALS
::GetListenServerHost <- @() null;
if(!IsDedicatedServer())
{
    ::GetListenServerHost <- @() PlayerInstanceFromIndex(1);
}
::GAMERULES_ENITY <- Entities.FindByClassname(null, "cs_gamerules");   // There's only one cs_gamerules entity
::PLAYER_MANAGER_ENTITY <- Entities.FindByClassname(null, "cs_player_manager");   // There's only one cs_player_manager entity

IncludeScript("custom_functions/const");
IncludeScript("custom_functions/utilities");
IncludeScript("custom_functions/entity");
IncludeScript("custom_functions/player");
IncludeScript("custom_functions/weapon");
