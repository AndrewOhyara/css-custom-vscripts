// WEAPONS

// NOTE: Only works for weapons with an owner because they have the m_iAmmo netprop array. Weird
CBaseCombatWeapon.GetPrimaryAmmo <- function()
{   // Returns the primary ammo of a weapon.
    if (IsValidSafe(GetOwner()))
        return NetProps.GetPropIntArray(GetOwner(), "m_iAmmo", GetPrimaryAmmoType());
}

// NOTE: Only works for weapons with an owner because they have the m_iAmmo netprop array. Weird
CBaseCombatWeapon.SetPrimaryAmmo <- function(ammo)  // You can even set ammo for grenades. That's a nice incentive for flashbang waves.
{   // Sets the primary ammo of a weapon. 
    if (IsValidSafe(GetOwner()))
        NetProps.SetPropIntArray(GetOwner(), "m_iAmmo", ammo, GetPrimaryAmmoType());
}

CBaseCombatWeapon.HasBurstMode <- function()
{
    return NetProps.HasProp(this, "m_bBurstMode");
}

CBaseCombatWeapon.IsInBurstMode <- function()
{
    return NetProps.GetPropBool(this, "m_bBurstMode");
}

CBaseCombatWeapon.HasSilencer <- function() 
{
    return NetProps.HasProp(this, "m_bSilencerOn");
}

CBaseCombatWeapon.IsSilencerOn <- function() 
{
    return NetProps.GetPropBool(this, "m_bSilencerOn");
}


