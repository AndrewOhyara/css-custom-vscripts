// Infinite ammo script example.
// You can modify the logic to filter which players and weapons can be set with inifinite ammo.
if ("InfinteAmmoScript" in this)
    InfinteAmmoScript.clear();

::InfinteAmmoScript <- {
    OnGameEvent_weapon_fire = function(params)
    {
        if (!("weapon" in params) || !("userid" in params) || params.weapon == "knife")
			return;

        local client = GetPlayerFromUserID(params.userid);
		if (!client || !client.IsValid() || !client.IsAlive())
			return;

        local weapon = NetProps.GetPropEntity(client, "m_hActiveWeapon");
		if (!weapon || !weapon.IsValid())
			return;

        local max_clip = weapon.GetMaxClip1();
        local clip = weapon.Clip1();

        if (params.weapon.find("grenade") != null || params.weapon == "flashbang")
        {   // Grenades don't have clip and have ammo instead.
            NetProps.SetPropIntArray(client, "m_iAmmo", 2, weapon.GetPrimaryAmmoType());    // ammo consistency: 0 -> 1
        }

        if (max_clip < 1)
            max_clip = 1;   // In case the max_clip is less than 1.

        if (clip <= max_clip)
        {
            weapon.SetClip1(max_clip+1);    // clip consistency: 29 -> 30 (Doesn't apply for high ping players)
        }
    }
};
__CollectGameEventCallbacks(InfinteAmmoScript);