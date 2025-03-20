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
::WORLDSPAWN <- Entities.First();
::GetListenServerHost <- @() null;
if(!IsDedicatedServer())
{
    ::GetListenServerHost <- @() PlayerInstanceFromIndex(1);
}

// FILES
IncludeScript("custom_functions/const", this);
IncludeScript("custom_functions/utilities", this);
IncludeScript("custom_functions/entity", this);
IncludeScript("custom_functions/player", this);
IncludeScript("custom_functions/weapon", this);
IncludeScript("custom_functions/misc", this);




