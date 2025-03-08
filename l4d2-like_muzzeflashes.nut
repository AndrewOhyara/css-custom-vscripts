// Original source: https://developer.valvesoftware.com/wiki/Counter-Strike:_Source/Scripting/VScript_Examples#L4D2-like_muzzleflashes)
// Requires the effects/muzzleflash_light texture from L4D2, or just use a plain white one and recolor it.
if ("MuzzleflashEvents" in this) 
    MuzzleflashEvents.clear();

MuzzleflashEvents <-
{
	OnGameEvent_weapon_fire = function(params)
	{
		if (params.weapon == "knife")
			return
			
		local player = GetPlayerFromUserID(params.userid);
		local host = player == GetListenServerHost();

      // Before creating the entity, we must make sure the player has the flashlight off.
      // The flashlight is a projected texture itself, so the entity will not work properly
      local bFlashlightOn = (NetProps.GetPropInt(player, "m_fEffects") & 4) ? true : false;
      if (bFlashlightOn)
         NetProps.SetPropInt(player, "m_fEffects", 0);   // A little risky if the netprop is higher than 4.
		
		local light = SpawnEntityFromTable("env_projectedtexture",
		{
			origin        = player.EyePosition() + player.EyeAngles().Forward() * -16.0
			angles        = player.EyeAngles()
			lightfov      = 110
			lightcolor    = "255 255 180 250"   //original: 750
			enableshadows = host
			farz          = host ? 800.0 : 300.0
		})
		NetProps.SetPropBool(light, "m_bForcePurgeFixedupStrings", true);
		light.AcceptInput("SpotlightTexture", "effects/muzzleflash_light", null, null);
		EntFireByHandle(light, "Kill", "", 0.01, null, null);
		// I won't bother in turning on the flashlight again.
	}
} 
__CollectGameEventCallbacks(MuzzleflashEvents);
