// Original source: https://developer.valvesoftware.com/wiki/Counter-Strike:_Source/Scripting/VScript_Examples#L4D2-like_muzzleflashes)
// Requires the effects/muzzleflash_light texture from L4D2, or just use a plain white one and recolor it.
// Reality: There's no need to import it. The projected light will still looking good.
// Recommendation: Since the projected light exists for 0.01 seconds, it does still count toward the edict limit. 
// So, i would recommend using this only for real players or maybe VIPs and admins.
if ("MuzzleflashEvents" in this) 
    MuzzleflashEvents.clear();

MuzzleflashEvents <-
{
	OnGameEvent_weapon_fire = function(params)
	{
	//return false;
		if (params.weapon == "knife" || params.weapon == "hegrenade" || params.weapon == "flashbang" || params.weapon == "smokegrenade" || params.weapon == "tmp")
			return
			
		local player = GetPlayerFromUserID(params.userid);
		if (!player || player == null || !player.IsValid())
			return;

		local weapon = NetProps.GetPropEntity(player, "m_hActiveWeapon");
		if (!weapon || weapon == null || !weapon.IsValid())
			return;

		local silencer_on = NetProps.GetPropBool(weapon, "m_bSilencerOn");
		if (silencer_on)
			return;

		local host = player == GetListenServerHost();
    		// Before creating the entity, we must make sure the player has the flashlight off.
    		// The flashlight is a projected texture itself, so the entity will not work properly
    		local bFlashlightOn = (NetProps.GetPropInt(player, "m_fEffects") & 4) ? true : false;
    		if (bFlashlightOn)
        		NetProps.SetPropInt(player, "m_fEffects", (NetProps.GetPropInt(player, "m_fEffects") & ~4)); // FIXED
		
		local light = SpawnEntityFromTable("env_projectedtexture",
		{
			origin        = player.EyePosition() + player.EyeAngles().Forward() * -16.0
			angles        = player.EyeAngles()
			lightfov      = 110
			lightcolor    = "255 255 180 60"   //original: 750
			enableshadows = true
			farz          = 730.0
		})
		NetProps.SetPropBool(light, "m_bForcePurgeFixedupStrings", true);

		// Uncomment the next line if you imported the L4D2 muzzeflash texture
		//light.AcceptInput("SpotlightTexture", "effects/muzzleflash_light", null, null);

		EntFireByHandle(light, "Kill", "", 0.0015, null, null);
		// I won't bother in turning on the flashlight again.
	}
} 
__CollectGameEventCallbacks(MuzzleflashEvents);
