// ENTITY
// FUNCTIONS

// Syntax: DissolveEntity(<Handle entity or Int entindex>, <Int type>, <Int magnitude>)
::DissolveEntity <- function(any, type = 0, magnitude = 0)
{   // Dissolves any physical entity. WARNING: Undesired effects on players if this used on them. (Use this method on their ragdolls instead)
    local ent = any;
    if (typeof any == "integer")
    {
        ent = Ent(any);
    }
    else if (typeof ent != "instance")
    {
        return;
    }
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

// NOTE: When using it with a player to another player, for some reason, the trace will point a little higher and poiting to spots like the head will return null.
::GetEntityPointingAt <- function(any_ent, bIgnoreWorldSpawn = true, iMask = 33579137)
{  // It basically returns the pointed entity of another entity. If bIgnoreWorldSpawn is false, it will return worldspawn if it's the entity that's being pointed. 
   // Since entities are classes, we can know if it has the method "EyePosition" and "EyeAngles".
   local eye_pos = null;
   local bSupportEyes = true;
   if ("EyePosition" in any_ent && "EyeAngles" in any_ent)
   {  // Both of these methods must be present in the entity class.
        eye_pos = any_ent.EyePosition();
      //if (any_ent.GetClassname() == "player")   // For some reason, you must point a little down to get a player entity.
         //eye_pos += Vector(0, 0, -8);   // Thought, this doesn't happen with another entity.
   }
   else
   {
        eye_pos =   any_ent.GetOrigin();
        bSupportEyes = false;
   }

   // We are additioning the pos with the foward vector of the eyes that's multiplied by 99999.
   // Meaning the destination vector (ex. (-71104.046875, -984113.750000, -150380.21875)) will be far enough to catch anything.
   // You can also use the Scale() method. 
   local dest_pos = null;
   if (bSupportEyes)
   {
        dest_pos = eye_pos + any_ent.EyeAngles().Forward().Scale(999999);
   }
   else 
   {
        dest_pos = eye_pos + any_ent.GetAbsAngles().Forward().Scale(999999);
   }

   // Then, trace a line.
   local trace_table = 
   {
        start = eye_pos
        end = dest_pos
        mask = iMask   // Default mask is MASK_VISIBLE_AND_NPCS (33579137)
        ignore = any_ent  // ofc, we don't want to include the entity itself
   }
   TraceLineEx(trace_table);

    if (!trace_table.hit)
        return null;

    if (!IsValidSafe(trace_table.enthit)) // Your typical NULL pointer situation.
        return null;

    if (trace_table.enthit == any_ent)  // If the enthit is the entity itself.
        return null;

    if (bIgnoreWorldSpawn && trace_table.enthit.GetClassname() == "worldspawn")
        return null;

    return trace_table.enthit;
}

::GetPointingPosition <- function(any_ent, bIgnoreWorldSpawn = false, iMask = 1174421507)
{  // It basically returns the vector where the trace ended.
   // Since entities are classes, we can know if it has the method "EyePosition" and "EyeAngles".
   local eye_pos = null;
   local bSupportEyes = true;
   if ("EyePosition" in any_ent && "EyeAngles" in any_ent)
   {  // Both of these methods must be present in the entity class.
        eye_pos = any_ent.EyePosition();
      //if (any_ent.GetClassname() == "player")   // For some reason, you must point a little down to get a player entity.
         //eye_pos += Vector(0, 0, -8);   // Thought, this doesn't happen with another entity.
   }
   else
   {
        eye_pos =   any_ent.GetOrigin();
        bSupportEyes = false;
   }

   // We are additioning the pos with the foward vector of the eyes that's multiplied by 99999.
   // Meaning the destination vector (ex. (-71104.046875, -984113.750000, -150380.21875)) will be far enough to catch anything.
   // You can also use the Scale() method. 
   local dest_pos = null;
   if (bSupportEyes)
   {
        dest_pos = eye_pos + any_ent.EyeAngles().Forward().Scale(999999);
   }
   else 
   {
        dest_pos = eye_pos + any_ent.GetAbsAngles().Forward().Scale(999999);
   }

   // Then, trace a line.
   local trace_table = 
   {
        start = eye_pos
        end = dest_pos
        mask = iMask   // Default mask is MASK_VISIBLE_AND_NPCS (33579137)
        ignore = any_ent  // ofc, we don't want to include the entity itself
   }
   TraceLineEx(trace_table);

    if (!trace_table.hit)
        return null;

    if (!IsValidSafe(trace_table.enthit)) // Your typical NULL pointer situation.
        return null;

    if (trace_table.enthit == any_ent)  // If the enthit is the entity itself.
        return null;

    if (bIgnoreWorldSpawn && trace_table.enthit.GetClassname() == "worldspawn")
        return null;

    return trace_table.pos;
}

// STATEMENTS
::IsOnGround <- function(any_ent)
{
    if (any_ent.GetFlags() & FL_ONGROUND) // FL_ONGROUND
        return true;

    return false;
}