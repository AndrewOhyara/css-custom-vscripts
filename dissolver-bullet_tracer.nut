if ("DissolveCorpse" in this)
   DissolveCorpse.clear();

DissolveCorpse <- {
   DissolveEntity = function(any, type = 0, magnitude = 0)
   {
      local ent = any;
    if (typeof any == "integer")
        ent = EntIndexToHScript(any);
    else if (typeof ent != "instance")
        return;

    if (ent == Entities.First())
        return;

      local dissolver = Entities.CreateByClassname("env_entity_dissolver");
      dissolver.KeyValueFromString("target", "!activator");
      dissolver.KeyValueFromInt("dissolvetype", type);
      dissolver.KeyValueFromInt("magnitude", type);

      dissolver.DispatchSpawn();

      dissolver.AcceptInput("Dissolve", "", ent, null);
      dissolver.AcceptInput("Kill", "", null, null);
   }

   OnGameEvent_player_death = function(params)
   {
      local client = GetPlayerFromUserID(params["userid"]);
      if (!client)
         return;

      local ragdoll = NetProps.GetPropEntity(client, "m_hRagdoll");
      if (ragdoll != null && ragdoll.IsValid())
      {
        EntFireByHandle(Entities.First(), "RunScriptCode", "DissolveCorpse.DissolveEntity("+ragdoll.entindex()+",0,1)", 1, null, null);
      }
   }
}
__CollectGameEventCallbacks(DissolveCorpse);


// Code modified from: https://developer.valvesoftware.com/wiki/Counter-Strike:_Source/Scripting/VScript_Examples#Bullet_Tracers_for_AK47
if("m_Events" in this) 
    m_Events.clear()

m_Events <-
{
    function OnGameEvent_bullet_impact(d)
    {
        local ply = GetPlayerFromUserID(d.userid)
        local weapon = NetProps.GetPropEntity(ply, "m_hActiveWeapon")

        if(weapon && weapon.IsValid() && ply && ply.IsValid() && !IsPlayerABot(ply))
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

            EntFireByHandle(beam, "Kill", "", 0, null, null)

            EntFireByHandle(targetStart, "Kill", "", 0.01, null, null)
            EntFireByHandle(targetEnd, "Kill", "", 0.01, null, null)
        }
    }
}
__CollectGameEventCallbacks(m_Events);