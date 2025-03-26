///// CONSTANTS BECAUSE VALVE FORGOT TO INCLUDE THEM IN CSS /////
const CSSCF_ACTIVE = true;
const CSSCF_VERSION = 0.1;
getconsttable()["MAXPLAYERS"] <- MaxClients().tointeger();

// PLAYER CLASS
enum CS_PLAYER_CLASS 
{   // This is the order of the player class for m_iClass netprop.
    NO_CLASS,    // 0: Spectator/Unassigned
    // Terrorist
    PHOENIX_CONNEXION,  // 1 
    ELITE_CREW, // 2
    ARCTIC_AVENGERS,    // 3
    GUERILLA_WARFARE,   // 4
    // Counter-Terrorist
    SEAL_TEAM_6,    // 5    | 1 in class selection
    GSG_9,  // 6    | 2 in class selection
    SAS,    // 7    | 3 in class selection
    GIGN    // 8    | 4 in class selection
}

enum CS_PLAYER_SKIN
{   // The same as above but with their modelnames.
    NO_CLASS = "",    // Spectator/Unassigned
    // Terrorist
    PHOENIX_CONNEXION = "models/player/t_phoenix.mdl",
    ELITE_CREW = "models/player/t_leet.mdl",
    ARCTIC_AVENGERS = "models/player/t_arctic.mdl",
    GUERILLA_WARFARE = "models/player/t_guerilla.mdl",
    // Counter-Terrorist
    SEAL_TEAM_6 = "models/player/ct_urban.mdl",
    GSG_9 = "models/player/ct_gsg9.mdl",
    SAS = "models/player/ct_sas.mdl",
    GIGN = "models/player/ct_gign.mdl"
}

// ROUND END REASONS
enum ROUND_END_REASONS 
{
    TARGET_BOMBED,  // COMMON: BOMB DETONATED
    VIP_ESCAPE,
    VIP_ASSASSINATED,
    TERRORIST_ESCAPED,
    CT_PREVENTED_ESCAPE,
    ESCAPING_TERRORIST_NEUTRALIZED,
    BOMB_DEFUSED,   // COMMON
    CT_WIN, // COMMON
    TERRORIST_WIN,  // COMMON
    ROUND_DRAW, // COMMON
    ALL_HOSTAGES_RESCUED,   // COMMON
    TARGET_SAVED,   // COMMON: BOMBING FAILED
    HOSTAGES_NOT_RESCUED,   // COMMON
    TERRORIST_NOT_ESCAPED,
    VIP_NOT_ESCAPED,
    GAME_COMMENCING // COMMON
}

// TEAM. The amount of "cs_team_manager" entities is the same as the amount of teams. DO NOT EVEN DARE TO KILL THEM. Please :p
const TEAM_UNASSIGNED = 0;  // "Select Team" screen.
const TEAM_SPECTATOR = 1;
const TEAM_TERRORIST = 2;
const TEAM_COUNTER_TERRORIST = 3;

// CBasePlayer BUTTONS
const IN_ATTACK = 1;
const IN_JUMP = 2;
const IN_DUCK = 4;
const IN_FORWARD = 8;
const IN_BACK = 16;
const IN_USE = 32;
const IN_CANCEL = 64;   // What's this?
const IN_LEFT = 128;
const IN_RIGHT = 256;
const IN_MOVELEFT = 512;
const IN_MOVERIGHT = 1024;
const IN_ATTACK2 = 2048;
const IN_RUN = 4096;
const IN_RELOAD = 8192;
const IN_ALT1 = 16384;
const IN_ALT2 = 32768;
const IN_SCORE = 65536; // Same for +showscores
const IN_SPEED = 131072;    // It's the walk action.
const IN_WALK = 262144; // It's not walk action in-game. it's IN_SPEED instead!
const IN_ZOOM = 524288;
const IN_WEAPON1 = 1048576; // What's this?
const IN_WEAPON2 = 2097152; // What's this?
const IN_BULLRUSH = 4194304;
const IN_GRENADE1 = 8388608;
const IN_GRENADE2 = 16777216;
const IN_ATTACK3 = 33554432;

// DAMAGE TYPE
const DMG_GENERIC = 0;
const DMG_CRUSH = 1;
const DMG_BULLET = 2;
const DMG_SLASH = 4;
const DMG_BURN = 8;
const DMG_VEHICLE = 16;
const DMG_FALL = 32;
const DMG_BLAST = 64;
const DMG_CLUB = 128;
const DMG_SHOCK = 256;
const DMG_SONIC = 512;
const DMG_ENERGYBEAM = 1024;
const DMG_PREVENT_PHYSICS_FORCE = 2048;
const DMG_NEVERGIB = 4096;
const DMG_ALWAYSGIB = 8192;
const DMG_DROWN = 16384;
const DMG_PARALYZE = 32768;
const DMG_NERVEGAS = 65536;
const DMG_POISON = 131072;
const DMG_RADIATION = 262144;
const DMG_DROWNRECOVER = 524288;
const DMG_ACID = 1048576;
const DMG_SLOWBURN = 2097152;
const DMG_REMOVENORAGDOLL = 4194304;
const DMG_PHYSGUN = 8388608;
const DMG_PLASMA = 16777216;
const DMG_AIRBOAT = 33554432;
const DMG_DISSOLVE = 67108864;
const DMG_BLAST_SURFACE = 134217728;
const DMG_DIRECT = 268435456;   // Damage from being on fire. (DMG_BURN relates to external sources hurting you). Entityflame 
const DMG_BUCKSHOT = 536870912;
const DMG_HEADSHOT = 1073741824;
const DMG_LASTGENERICFLAG = -2147483648;

// "PLAYER" FLAGS
const FL_ONGROUND =	1;
const FL_DUCKING = 2;
const FL_ANIMDUCKING = 4;
const FL_WATERJUMP = 8;
const PLAYER_FLAG_BITS = 11;
const FL_ONTRAIN = 16;
const FL_INRAIN = 32;
const FL_FROZEN	= 64;
const FL_ATCONTROLS	= 128;
const FL_CLIENT	= 256;
const FL_FAKECLIENT	= 512;
const FL_INWATER = 1024;
const FL_FLY = 2048;
const FL_SWIM = 4096;
const FL_CONVEYOR = 8192;
const FL_NPC = 16384;
const FL_GODMODE = 32768;
const FL_NOTARGET = 65536;
const FL_AIMTARGET = 131072;
const FL_PARTIALGROUND = 262144;
const FL_STATICPROP = 524288;
const FL_GRAPHED = 1048576;
const FL_GRENADE = 2097152;
const FL_STEPMOVEMENT = 4194304;
const FL_DONTTOUCH = 8388608;
const FL_BASEVELOCITY = 16777216;
const FL_WORLDBRUSH = 33554432;
const FL_OBJECT = 67108864;
const FL_KILLME = 134217728;
const FL_ONFIRE = 268435456;
const FL_DISSOLVING = 536870912;
const FL_TRANSRAGDOLL = 1073741824;
const FL_UNBLOCKABLE_BY_PLAYER = 2147483648;

// SOLID FLAGS
const FSOLID_CUSTOMRAYTEST = 1;
const FSOLID_CUSTOMBOXTEST = 2;
const FSOLID_NOT_SOLID = 4;
const FSOLID_TRIGGER = 8;
const FSOLID_MAX_BITS = 10;
const FSOLID_NOT_STANDABLE = 16;
const FSOLID_VOLUME_CONTENTS = 32;
const FSOLID_FORCE_WORLD_ALIGNED = 64;
const FSOLID_USE_TRIGGER_BOUNDS = 128;
const FSOLID_ROOT_PARENT_ALIGNED = 256;
const FSOLID_TRIGGER_TOUCH_DEBRIS = 512;

// [NO OFFICIAL] WATER LEVEL
const WL_NOTINWATER = 0;
const WL_FEET = 1;  // The origin of the entity.
const WL_WAIST = 2; // The center of the entity.
const WL_EYES = 3;  // The eyes of the entity.

// MOVETYPE
const MOVETYPE_NONE	= 0; // Freezes the entity, outside sources can't move it.
const MOVETYPE_ISOMETRIC = 1;    // For players in TF2 commander view etc. Do not use this for normal players!
const MOVETYPE_WALK = 2; // 	Default player (client) move type.
const MOVETYPE_STEP = 3; // NPC movement
const MOVETYPE_FLY = 4;  // Fly with no gravity.
const MOVETYPE_FLYGRAVITY = 5;   // Fly with gravity.
const MOVETYPE_VPHYSICS = 6;    // Physics movetype (prop models etc.)
const MOVETYPE_PUSH = 7;    // No clip to world, but pushes and crushes things.
const MOVETYPE_NOCLIP = 8;  // Noclip, behaves exactly the same as console command.
const MOVETYPE_LADDER = 9;  // For players, when moving on a ladder.
const MOVETYPE_OBSERVER = 10;   // Spectator movetype. DO NOT use this to make player spectate.
const MOVETYPE_CUSTOM = 11; // Custom movetype, can be applied to the player to prevent the default movement code from running, while still calling the related hooks.
const MOVETYPE_LAST = 11;   // This is for...? Confirm: This works in css.

// MOVECOLLIDE
const MOVECOLLIDE_DEFAULT =	0;
const MOVECOLLIDE_FLY_BOUNCE = 1;
const MOVECOLLIDE_FLY_CUSTOM = 2;
const MOVECOLLIDE_FLY_SLIDE	= 3;
const MOVECOLLIDE_MAX_BITS = 3;
const MOVECOLLIDE_COUNT = 4;

// COLLISION GROUPS
const COLLISION_GROUP_NONE = 0;
const COLLISION_GROUP_DEBRIS = 1;
const COLLISION_GROUP_DEBRIS_TRIGGER = 2;
const COLLISION_GROUP_INTERACTIVE_DEBRIS =3;
const COLLISION_GROUP_INTERACTIVE = 4;
const COLLISION_GROUP_PLAYER = 5;
const COLLISION_GROUP_BREAKABLE_GLASS = 6;
const COLLISION_GROUP_VEHICLE = 7;
const COLLISION_GROUP_PLAYER_MOVEMENT = 8;
const COLLISION_GROUP_NPC = 9;
const COLLISION_GROUP_IN_VEHICLE = 10;
const COLLISION_GROUP_WEAPON = 11;
const COLLISION_GROUP_VEHICLE_CLIP = 12;
const COLLISION_GROUP_PROJECTILE = 13;
const COLLISION_GROUP_DOOR_BLOCKER = 14;
const COLLISION_GROUP_PASSABLE_DOOR = 15;
const COLLISION_GROUP_DISSOLVING = 16;
const COLLISION_GROUP_PUSHAWAY = 17;
const COLLISION_GROUP_NPC_ACTOR = 18;
const COLLISION_GROUP_NPC_SCRIPTED = 19;
const LAST_SHARED_COLLISION_GROUP = 20;

// SOLID TYPE
const SOLID_NONE = 0;
const SOLID_BSP = 1;
const SOLID_BBOX = 2;
const SOLID_OBB = 3;
const SOLID_OBB_YAW = 4;
const SOLID_CUSTOM = 5;
const SOLID_VPHYSICS = 6;
const SOLID_LAST = 7;


// HUD NOTIFY
const HUD_PRINTNOTIFY = 1;
const HUD_PRINTCONSOLE = 2;
const HUD_PRINTTALK = 3;
const HUD_PRINTCENTER = 4;

// ENTITY EFFECTS
const EF_NONE = 0;  // This does not exist but it's here for easy understanding.
const EF_BONEMERGE = 1; // Bonemerge always (very expensive!). Merges bones of names shared with a parent entity to the position and direction of the parent's.
const EF_BRIGHTLIGHT = 2;   // Bright, dynamic light at entity origin. Emits a dynamic light of RGB(250,250,250) and a random radius of 400 to 431 from the origin.
const EF_DIMLIGHT = 4;  // Dim, dynamic light at entity origin" | player's flashlight
const EF_NOINTERP = 8;  // No movement interpolation. Don't interpolate on the next frame. May cause crashes!
const EF_MAX_BITS = 10;
const EF_NOSHADOW = 16; // Don't cast shadows. Don't create a render-to-texture shadow, does not affect projected texture shadows.
const EF_NODRAW = 32;   // Don't draw entity (entity is fully ignored by clients, NOT server; can cause collision problems)
const EF_NORECEIVESHADOW = 64;  // Don't receive dynamic shadows.
const EF_BONEMERGE_FASTCULL = 128;  // Bonemerge only in PVS, better performance but prone to disappearing. Use with Bonemerge.
const EF_ITEM_BLINK = 256;  // Unsubtle blink. Blink an item so that the user notices it. Added for original Xbox, and not very subtle.
const EF_PARENT_ANIMATES = 512; // Flag parent as always animating and realign each frame.

// RENDER MODE  || wtf with these tf2's constant names?
const kRenderNormal = 0;
const kRenderTransColor = 1;
const kRenderTransTexture = 2;
const kRenderGlow = 3;
const kRenderTransAlpha = 4;
const kRenderTransAdd = 5;
const kRenderEnvironmental = 6;
const kRenderTransAddFrameBlend = 7;
const kRenderTransAlphaAdd = 8;
const kRenderWorldGlow = 9;
const kRenderNone = 10;
const kRenderModeCount = 11;    // Confirm: This works in css.

// RENDER FX
const kRenderFxNone = 0;
const kRenderFxPulseSlow = 1;
const kRenderFxPulseFast = 2;
const kRenderFxPulseSlowWide = 3;
const kRenderFxPulseFastWide = 4;
const kRenderFxFadeSlow = 5;
const kRenderFxFadeFast = 6;
const kRenderFxSolidSlow = 7;
const kRenderFxSolidFast = 8;
const kRenderFxStrobeSlow = 9;
const kRenderFxStrobeFast = 10;
const kRenderFxStrobeFaster = 11;
const kRenderFxFlickerSlow = 12;
const kRenderFxFlickerFast = 13;
const kRenderFxNoDissipation =14;
const kRenderFxDistort = 15;
const kRenderFxHologram = 16;
const kRenderFxExplode = 17;
const kRenderFxGlowShell = 18;
const kRenderFxClampMinScale = 19;
const kRenderFxEnvRain = 20;
const kRenderFxEnvSnow = 21;
const kRenderFxSpotlight = 22;
const kRenderFxRagdoll = 23;
const kRenderFxPulseFastWider = 24;
const kRenderFxMax = 25;