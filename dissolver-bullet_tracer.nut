if ("DissolveCorpse" in this)
    ::DissolveCorpse.clear();

::DissolveCorpse <- {
    // READ: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions#INextBotComponent:~:text=Calling-,RunScriptCode
    ClearStringFromPool = function(string)
    {
        local dummy = Entities.CreateByClassname("info_target");
        dummy.KeyValueFromString("targetname", string);
        NetProps.SetPropBool(dummy, "m_bForcePurgeFixedupStrings", true);
        dummy.Destroy();
    }

    // READ: https://developer.valvesoftware.com/wiki/Team_Fortress_2/Scripting/Script_Functions#INextBotComponent:~:text=Calling-,RunScriptCode
    EntFireCodeSafe = function(entity, code, delay = 0.0, activator = null, caller = null)
    {
        EntFireByHandle(entity, "RunScriptCode", code, delay, activator, caller);
        ::DissolveCorpse.ClearStringFromPool(code);
    }

    DissolveEntity = function(any, type = 0)
    {
        local ent = any;
        if (typeof any == "integer")
            ent = EntIndexToHScript(any);
        else if (typeof ent != "instance")
            return;

        if (ent == Entities.First())
            return;

        local dissolver = Entities.CreateByClassname("env_entity_dissolver");
        NetProps.SetPropBool(dissolver, "m_bForcePurgeFixedupStrings", true);
        dissolver.KeyValueFromString("target", "!activator");
        dissolver.KeyValueFromInt("dissolvetype", type);
        dissolver.AcceptInput("Dissolve", "", ent, null);
        dissolver.Kill();
    }

    OnGameEvent_player_death = function(params)
    {
        local client = GetPlayerFromUserID(params["userid"]);
        if (!client)
            return;

        local ragdoll = NetProps.GetPropEntity(client, "m_hRagdoll");
        if (ragdoll != null && ragdoll.IsValid())
            EntFireCodeSafe(Entities.First(), "DissolveCorpse.DissolveEntity("+ragdoll.entindex()+",0)", 1, null, null);
    }
}
__CollectGameEventCallbacks(DissolveCorpse);


// Code modified from: https://developer.valvesoftware.com/wiki/Counter-Strike:_Source/Scripting/VScript_Examples#Bullet_Tracers_for_AK47
if("BulletTracers" in this) 
    ::BulletTracers.clear();

::BulletTracers <-
{
    function OnGameEvent_bullet_impact(d)
    {
        local ply = GetPlayerFromUserID(d.userid)
        local weapon = NetProps.GetPropEntity(ply, "m_hActiveWeapon")
        // Shotguns fire more than one bullet per shot. Imagine if 60 players shoot a shotgun at the same time. That would be like 300-500 ents in the same frame.
        if (weapon && weapon.IsValid() && ply && ply.IsValid() && !IsPlayerABot(ply) && weapon.GetClassname() != "weapon_m3" && weapon.GetClassname() != "weapon_xm1014")
        {
            local targetStart = SpawnEntityFromTable("info_target", {
                targetname = UniqueString()
                origin = ply.GetAttachmentOrigin(ply.LookupAttachment("muzzle_flash"))
            })
            local targetEnd = SpawnEntityFromTable("info_target", {
                targetname = UniqueString()
                origin = Vector(d.x, d.y, d.z)
            })

            local beam = SpawnEntityFromTable("env_beam", {
                rendercolor = "0 255 255"
                LightningStart = targetStart.GetName()
                LightningEnd = targetEnd.GetName()
                BoltWidth = 1
                texture = "sprites/laserbeam.spr"
                spawnflags = 1
            })

	        // when entity is created new string are placed into game string table which has a limit, if it is exceeded, the game crashes
		// in our case, where we create an entity, every time the bullet_impact event is fired, this table is filled with new strings
		// m_bForcePurgeFixedupStrings netprop will help you avoid this
		NetProps.SetPropBool(targetStart, "m_bForcePurgeFixedupStrings", true)
		NetProps.SetPropBool(targetEnd, "m_bForcePurgeFixedupStrings", true)
		NetProps.SetPropBool(beam, "m_bForcePurgeFixedupStrings", true)
	
	        EntFireByHandle(beam, "Kill", "", 0, null, null)
	        EntFireByHandle(targetStart, "Kill", "", 0.01, null, null)
	        EntFireByHandle(targetEnd, "Kill", "", 0.01, null, null)
        }
    }
}
__CollectGameEventCallbacks(::BulletTracers);
