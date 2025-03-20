// WEAPONS
::GetPrimaryAmmo <- function(client, weapon)
{   // Returns the primary ammo of a weapon. Only works for weapons with a player as the owner. Weird
    return NetProps.GetPropIntArray(client, "localdata.m_iAmmo", weapon.GetPrimaryAmmoType());
}

::SetPrimaryAmmo <- function(client, weapon, ammo)  // You can even set ammo for grenades. That's a nice incentive for flashbang waves.
{   // Sets the primary ammo of a weapon. Only works for weapons with a player as the owner. Weird
    NetProps.SetPropIntArray(client, "localdata.m_iAmmo", ammo, weapon.GetPrimaryAmmoType());
}


