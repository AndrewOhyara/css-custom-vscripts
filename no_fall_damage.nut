if ("NoFallDamage" in this)
    NoFallDamage.clear();

::NoFallDamage <- 
{
    OnScriptHook_OnTakeDamage = function(params)
    {
        local victim = params["const_entity"];
        local attacker = params["attacker"];
        local inflictor = params["inflictor"];
        local weapon = params["weapon"];
        local damage_type = params["damage_type"];
        local damage_base = params["const_base_damage"];
        local damage = params["damage"];
        local damage_position = params["damage_position"];
        local damage_force = params["damage_force"];
        local max_damage = params["max_damage"];
        local ammo_type = params["ammo_type"];  // -1 if knife.

        // Removing fall damage for players
        // See damage flags here: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions/Constants#FDmgType
        if (victim.IsPlayer() && damage_type == 32) // DMG_FALL flag
        {
            params.damage = 0;  // Set the damage key to whatever you want.
        }
    }
}
__CollectGameEventCallbacks(NoFallDamage);