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
::ForcePrimaryAttack <- function(client)
{   // Forces the primary attack of a weapon.
    NetProps.SetPropBool(client, "m_bLagCompensation", false);
    GetActiveWeapon(client).PrimaryAttack();
    NetProps.SetPropBool(client, "m_bLagCompensation", true);
}

::ForceSecondaryAttack <- function(client) // Does this have any use in CSS?
{   // Forces the secondary attack of a weapon.
    NetProps.SetPropBool(client, "m_bLagCompensation", false);
    GetActiveWeapon(client).SecondaryAttack();
    NetProps.SetPropBool(client, "m_bLagCompensation", true);
}
