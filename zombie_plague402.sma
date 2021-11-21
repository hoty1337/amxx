/*================================================================================
 [Plugin Customization]
=================================================================================*/

// All customization settings have been moved
// to external files to allow easier editing
new const ZP_CUSTOMIZATION_FILE[] = "zombieplague.ini"
new const ZP_EXTRAITEMS_FILE[] = "zp_extraitems.ini"
new const ZP_ZOMBIECLASSES_FILE[] = "zp_zombieclasses.ini"

// Limiters for stuff not worth making dynamic arrays out of (increase if needed)
const MAX_CSDM_SPAWNS = 128
const MAX_STATS_SAVED = 64

/*================================================================================
 Customization ends here! Yes, that's it. Editing anything beyond
 here is not officially supported. Proceed at your own risk...
=================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <engine>
//#include <dhudmessage>

native show_vip_menu(id)
native show_admin_menu(id)
native show_boss_menu(id)
native show_prem_menu(id)
native admin_main_menu(id)
native show_ad_menu1(id)
native show_ruletka_menu(id)
native humanclass_open(id)
native donate_show(id)     
native grab_set_color(id, set)

native zp_get_character(id)
native zp_get_character_choosed(id)

native give_skull11(id)
native give_dart(id)
native give_balrog5(id)
native give_balrog7(id)
native give_dinfi(id)

/*================================================================================
 [Constants, Offsets, Macros]
=================================================================================*/
// Day
new g_day_num
#define MAX_PLAYERS 32
new g_fMainInformerColor[MAX_PLAYERS + 1][3], g_iInformerCord[MAX_PLAYERS + 1],
Float:g_fMainInformerPosX[MAX_PLAYERS + 1], Float:g_fMainInformerPosY[MAX_PLAYERS + 1], g_chat_bz[MAX_PLAYERS + 1], g_informer[MAX_PLAYERS + 1], iPlayerAimInfo[MAX_PLAYERS + 1]

new const g_day_string[][] =
{
    "0", "1", "2", "3", "4", "5",
    "6", "7", "8", "9", "10",
    "11", "12", "13", "14", "15",
    "16", "17", "18", "19", "20",
    "21", "22", "23", "24", "25",
    "26", "27", "28", "29", "30",
    "31", "32", "33", "34", "35",
    "36", "37", "38", "39", "40",
    "41", "42", "43", "44", "45",
    "46", "47", "48", "49", "50"	
}
/* ---> Day System ---> */

new const Commands[][]=
{
	"galil",
	"defender",
	"ak47",
	"cv47",
	"scout",
	"sg552",
	"krieg552",
	"awp",
	"magnum",
	"g3sg1",
	"d3au1",
	"famas",
	"clarion",
	"m4a1",
	"aug",
	"bullpup",
	"krieg550",
	"glock",
	"9x19mm",
	"km45",
	"p228",
	"228compact",
	"nighthawk",
	"elites",
	"fn57",
	"fiveseven",
	"12gauge",
	"xm1014",
	"autoshotgun",
	"mac10",
	"tmp",
	"mp",
	"mp5",
	"smg",
	"ump45",
	"p90",
	"c90",
	"m249",
	"vest",
	"vesthelm",
	"flash",
	"hegren",
	"sgren",
	"nvgs",
	"shield",
	
	"cl_setautobuy", 
	"cl_autobuy",
	"cl_setrebuy",
	"cl_rebuy",
	"buyequip"
}

#define LEVEL_MAX            110
#define LEVEL_EXP_COUNT        15

new Float:g_knife_abil[33]

new const CHARACTER[][] =
{
	"Gerrard",
	"Sas",
	"Nano",
	"Hunter",
	"Raf Simons",
	"Kenjy",
	"SpetsnaZ",
	"Black Guard"
}

// INFORMER
#define HUD_1_CORD 0.02
#define HUD_2_CORD 0.92
#define HUD_3_CORD -1.0
#define HUD_4_CORD 0.86

// Proka4ka Oo
new g_iToken[33]

#define SND_MENU_OFF "BZ_sound/off.wav"
#pragma tabsize 0

new Votes_mode_ALL
new Votes_mode_CUR[2]
new Voted_Already[33]
new time_vote
new g_nemesis_mod, g_survivor_mod

// Plugin Version
new const PLUGIN_VERSION[] = "4.3 Fix5a"

// Customization file sections
enum
{
	SECTION_NONE = 0,
	SECTION_ACCESS_FLAGS,
	SECTION_PLAYER_MODELS,
	SECTION_WEAPON_MODELS,
	SECTION_GRENADE_SPRITES,
	SECTION_SOUNDS,
	SECTION_AMBIENCE_SOUNDS,
	SECTION_BUY_MENU_WEAPONS,
	SECTION_BUY_MENU_KNIFES,
	SECTION_EXTRA_ITEMS_WEAPONS,
	SECTION_WEATHER_EFFECTS,
	SECTION_SKY,
	SECTION_LIGHTNING,
	SECTION_ZOMBIE_DECALS,
	SECTION_KNOCKBACK,
	SECTION_OBJECTIVE_ENTS,
	SECTION_SVC_BAD
}

// Access flags
enum
{
	ACCESS_ENABLE_MOD = 0,
	ACCESS_ADMIN_MENU,
	ACCESS_MODE_INFECTION,
	ACCESS_MODE_NEMESIS,
	ACCESS_MODE_SURVIVOR,
	ACCESS_MODE_SWARM,
	ACCESS_MODE_MULTI,
	ACCESS_MODE_PLAGUE,
	ACCESS_MAKE_ZOMBIE,
	ACCESS_MAKE_HUMAN,
	ACCESS_MAKE_NEMESIS,
	ACCESS_MAKE_SURVIVOR,
	ACCESS_RESPAWN_PLAYERS,
	ACCESS_ADMIN_MODELS,
	MAX_ACCESS_FLAGS
}

// Task offsets
enum (+=100)
{
	TASK_MODEL = 2000,
	TASK_TEAM,
	TASK_SPAWN,
	TASK_BLOOD,
	TASK_AURA,
	TASK_BURN,
	TASK_NVISION,
	TASK_FLASH,
	TASK_CHARGE,
	TASK_SHOWHUD,
	TASK_AFFECT,
	TASK_MAKEZOMBIE,
	TASK_WARMUP,
	TASK_THUNDER_PRE,
	TASK_THUNDER,

	TASK_AMBIENCESOUNDS
}

// IDs inside tasks
#define ID_MODEL (taskid - TASK_MODEL)
#define ID_TEAM (taskid - TASK_TEAM)
#define ID_SPAWN (taskid - TASK_SPAWN)
#define ID_BLOOD (taskid - TASK_BLOOD)
#define ID_AURA (taskid - TASK_AURA)
#define ID_BURN (taskid - TASK_BURN)
#define ID_NVISION (taskid - TASK_NVISION)
#define ID_FLASH (taskid - TASK_FLASH)
#define ID_CHARGE (taskid - TASK_CHARGE)
#define ID_SHOWHUD (taskid - TASK_SHOWHUD)

// BP Ammo Refill task
#define REFILL_WEAPONID args[0]

// For weapon buy menu handlers
#define WPN_STARTID g_menu_data[id][1]
#define WPN_MAXIDS ArraySize(g_primary_items)
#define WPN_SELECTION (g_menu_data[id][1]+key)
#define WPN_AUTO_ON g_menu_data[id][2]
#define WPN_AUTO_PRI g_menu_data[id][3]
#define WPN_AUTO_SEC g_menu_data[id][4]

// For player list menu handlers
#define PL_ACTION g_menu_data[id][0]

// For remembering menu pages
#define MENU_PAGE_ZCLASS g_menu_data[id][5]
#define MENU_PAGE_EXTRAS g_menu_data[id][6]
#define MENU_PAGE_PLAYERS g_menu_data[id][7]

// Menu selections
const MENU_KEY_AUTOSELECT = 7
const MENU_KEY_BACK = 7
const MENU_KEY_NEXT = 8
const MENU_KEY_EXIT = 9

// Hard coded extra items
enum
{
	EXTRA_ANTIDOTE=0,
	EXTRA_MADNESS,
	EXTRA_ZOMBIBOMB,
	EXTRA_SHOCKBOMB,
	EXTRA_NOKNOCK,
	EXTRA_HEALTH,
	EXTRA_ARMOR,
    EXTRA_CAKE,
	/*EXTRA_SURVIVOR,*/
	EXTRA_UNLIMITED,
	EXTRA_NORECOIL,
    EXTRA_FLAMEGR,
    EXTRA_ICEGR,
	EXTRA_PIPE,
	EXTRA_HEALTH2
} 

// Game modes
enum
{
	MODE_NONE = 0,
	MODE_INFECTION,
	MODE_NEMESIS,
	MODE_SURVIVOR,
	MODE_SWARM,
	MODE_MULTI,
	MODE_PLAGUE
}

// ZP Teams
const ZP_TEAM_NO_ONE = 0
const ZP_TEAM_ANY = 0
const ZP_TEAM_ZOMBIE = (1<<0)
const ZP_TEAM_HUMAN = (1<<1)
const ZP_TEAM_NEMESIS = (1<<2)
const ZP_TEAM_SURVIVOR = (1<<3)
new const ZP_TEAM_NAMES[][] = { "ZOMBIE , HUMAN", "ZOMBIE", "HUMAN", "ZOMBIE , HUMAN", "NEMESIS",
			"ZOMBIE , NEMESIS", "HUMAN , NEMESIS", "ZOMBIE , HUMAN , NEMESIS",
			"SURVIVOR", "ZOMBIE , SURVIVOR", "HUMAN , SURVIVOR", "ZOMBIE , HUMAN , SURVIVOR",
			"NEMESIS , SURVIVOR", "ZOMBIE , NEMESIS , SURVIVOR", "HUMAN, NEMESIS, SURVIVOR",
			"ZOMBIE , HUMAN , NEMESIS , SURVIVOR" }

// Zombie classes
const ZCLASS_NONE = -1

// HUD messages
const Float:HUD_EVENT_X = -1.0
const Float:HUD_EVENT_Y = 0.2
const Float:HUD_WARMUP_X = -1.0
const Float:HUD_WARMUP_Y = 0.11
const Float:HUD_WARMUP_X2 = -1.0
const Float:HUD_WARMUP_Y2 = 0.2
const Float:HUD_INFECT_X = 0.05
const Float:HUD_INFECT_Y = 0.45
const Float:HUD_SPECT_X = -1.0
const Float:HUD_SPECT_Y = 0.8
const Float:HUD_STATS_X = 0.02
const Float:HUD_STATS_Y = 0.9

// Hack to be able to use Ham_Player_ResetMaxSpeed (by joaquimandrade)
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

// CS Player PData Offsets (win32)
const PDATA_SAFE = 2
const OFFSET_PAINSHOCK = 108 // ConnorMcLeod
const OFFSET_CSTEAMS = 114
const OFFSET_CSMONEY = 115
const OFFSET_CSMENUCODE = 205
const OFFSET_FLASHLIGHT_BATTERY = 244
const OFFSET_CSDEATHS = 444
const OFFSET_MODELINDEX = 491 // Orangutanz

// CS Player CBase Offsets (win32)
const OFFSET_ACTIVE_ITEM = 373

// CS Weapon CBase Offsets (win32)
const OFFSET_WEAPONOWNER = 41

// Linux diff's
const OFFSET_LINUX = 5 // offsets 5 higher in Linux builds
const OFFSET_LINUX_WEAPONS = 4 // weapon offsets are only 4 steps higher on Linux

// CS Teams
enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}
new const CS_TEAM_NAMES[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }

// Some constants
const HIDE_MONEY = (1<<5)
const UNIT_SECOND = (1<<12)
const DMG_HEGRENADE = (1<<24)
const IMPULSE_FLASHLIGHT = 100
const USE_USING = 2
const USE_STOPPED = 0
const STEPTIME_SILENT = 999
const BREAK_GLASS = 0x01
const FFADE_IN = 0x0000
const FFADE_STAYOUT = 0x0004
const PEV_SPEC_TARGET = pev_iuser2

/*-----BossManager(start)-----*/
native zl_boss_map()
static Map_Boss = 0
/*-----BossManager(End)-----*/

// Max BP ammo for weapons
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

// Max Clip for weapons
new const MAXCLIP[] = { -1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 50 }

// Amount of ammo to give when buying additional clips for weapons
new const BUYAMMO[] = { -1, 13, -1, 30, -1, 8, -1, 12, 30, -1, 30, 50, 12, 30, 30, 30, 12, 30,
			10, 30, 30, 8, 30, 30, 30, -1, 7, 30, 30, -1, 50 }

// Ammo IDs for weapons
new const AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7 }

// Ammo Type Names for weapons
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }

// Weapon IDs for ammo types
new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE,
			CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4 }

// Weapon entity names
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }

// CS sounds
new const sound_flashlight[] = "items/flashlight1.wav"
new const sound_buyammo[] = "items/9mmclip1.wav"
new const sound_armorhit[] = "player/bhit_helmet-1.wav"

// Explosion radius for custom grenades
const Float:NADE_EXPLOSION_RADIUS = 240.0

// HACK: pev_ field used to store additional ammo on weapons
const PEV_ADDITIONAL_AMMO = pev_iuser1

// HACK: pev_ field used to store custom nade types and their values
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_JUMP = 1110
const NADE_TYPE_SHOCK = 1111
const NADE_TYPE_NAPALM = 2222
const NADE_TYPE_FROST = 3333
const NADE_TYPE_ANTIDOTE = 4444
const NADE_TYPE_PIPE = 5555
const PEV_FLARE_COLOR = pev_punchangle
const PEV_FLARE_DURATION = pev_flSwimTime

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

// Allowed weapons for zombies (added grenades/bomb for sub-plugin support, since they shouldn't be getting them anyway)
const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4)

// Classnames for separate model entities
new const MODEL_ENT_CLASSNAME[] = "player_model"
new const WEAPON_ENT_CLASSNAME[] = "weapon_model"

// Menu keys
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
const KEYSMENU3 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_0

// Ambience Sounds
enum
{
	AMBIENCE_SOUNDS_INFECTION = 0,
	AMBIENCE_SOUNDS_NEMESIS,
	AMBIENCE_SOUNDS_SURVIVOR,
	AMBIENCE_SOUNDS_SWARM,
	AMBIENCE_SOUNDS_PLAGUE,
	MAX_AMBIENCE_SOUNDS
}

// Admin menu actions
enum
{
    ACTION_ZOMBIEFY_HUMANIZE = 0,
    ACTION_MAKE_NEMESIS,
    ACTION_MAKE_SURVIVOR,
    ACTION_MODE_SWARM,
    ACTION_MODE_MULTI,
    ACTION_MODE_PLAGUE,
    ACTION_RESPAWN_PLAYER
}

// Custom forward return values
const ZP_PLUGIN_HANDLED = 97

/*================================================================================
 [Global Variables]
=================================================================================*/
new g_armor_limit[33], g_cake_limit[33], g_madness_limit[33], g_unlimited[33], g_norecoil[33], g_flamegr[33], g_flashgr[33], g_noknock[33], g_antidote_limit[33]
new g_surv_limit
new g_pipe_bomb[33], g_health_limit[33], g_health_limit2[33]

#define ARMOR_LIMIT 5
#define PIPE_LIMIT 2
#define MADNESS_LIMIT 3

new g_adm_Color[33]

// Player vars
new g_szPrivilege[33][32]
new g_surv_name[32]
new g_nem_name[32]
new g_zombie[33] // is zombie
new g_nemesis[33] // is nemesis
new g_survivor[33] // is survivor
new g_firstzombie[33] // is first zombie
new g_lastzombie[33] // is last zombie
new g_lasthuman[33] // is last human
new g_frozen[33] // is frozen (can't move)
new Float:g_frozen_gravity[33] // store previous gravity when frozen
new g_nodamage[33] // has spawn protection/zombie madness
new g_respawn_as_zombie[33] // should respawn as zombie
new g_zombieclass[33] // zombie class
new g_zombieclassnext[33] // zombie class for next infection
new g_flashlight[33] // has custom flashlight turned on
new g_flashbattery[33] = { 100, ... } // custom flashlight battery
new g_canbuy[33] // is allowed to buy a new weapon through the menu
new g_ammopacks[33] // ammo pack count
new g_lvl[33]
new g_exp[33]
new g_pts[33][10]
new g_damagedealt_human[33] // damage dealt as human (used to calculate ammo packs reward)
new g_damagedealt_zombie[33] // damage dealt as zombie (used to calculate ammo packs reward)
new Float:g_lastleaptime[33] // time leap was last used
new g_playermodel[33][32] // current model's short name [player][model]
new g_menu_data[33][8] // data for some menu handlers
new g_ent_playermodel[33] // player model entity
new g_ent_weaponmodel[33] // weapon model entity
new g_burning_duration[33] // burning task duration
new Float:g_buytime[33] // used to calculate custom buytime
new g_vip[33]
new g_vip_stop[33][10]
new g_knife[33]
new EntTimer
new g_Timer[33]

// Game vars
new g_warmup
new g_pluginenabled // ZP enabled
new g_newround // new round starting
new g_endround // round ended
new g_nemround // nemesis round
new g_survround // survivor round
new g_swarmround // swarm round
new g_plagueround // plague round
new g_modestarted // mode fully started
new g_lastmode // last played mode
new g_scorezombies, g_scorehumans, g_gamecommencing // team scores
new g_spawnCount, g_spawnCount2 // available spawn points counter
new Float:g_spawns[MAX_CSDM_SPAWNS][3], Float:g_spawns2[MAX_CSDM_SPAWNS][3] // spawn points data
new g_lights_i // lightning current lights counter
new g_lights_cycle[32] // current lightning cycle
new g_lights_cycle_len // lightning cycle length
new Float:g_models_targettime // for adding delays between Model Change messages
new Float:g_teams_targettime // for adding delays between Team Change messages
new g_MsgSync, g_MsgSync2, g_MsgSync4 // message sync objects
new g_trailSpr, g_exploSpr, g_flameSpr, g_smokeSpr, g_glassSpr, g_metalgibs, SprLighting // grenade sprites
new g_explo_fireSpr,g_explo_frostSpr,g_explo_antidoteSpr, g_explo_zbombSpr
new g_gibs_fireSpr, g_gibs_frostSpr
new g_freezetime // whether CS's freeze time is on
new g_maxplayers // max players counter
new g_czero // whether we are running on a CZ server
new g_hamczbots // whether ham forwards are registered for CZ bots
new g_fwSpawn, g_fwPrecacheSound // spawn and precache sound forward handles
new g_arrays_created // to prevent stuff from being registered before initializing arrays
new g_lastplayerleaving // flag for whenever a player leaves and another takes his place
new g_switchingteam // flag for whenever a player's team change emessage is sent
new g_buyzone_ent // custom buyzone entity

// Message IDs vars
new g_msgScoreInfo, g_msgNVGToggle, g_msgScoreAttrib, g_msgAmmoPickup, g_msgScreenFade,
g_msgDeathMsg, g_msgHideWeapon, g_msgCrosshair,
g_msgFlashlight, g_msgFlashBat, g_msgTeamInfo, g_msgDamage, g_msgSayText, g_msgScreenShake, g_msgCurWeapon

// Some forward handlers
new g_fwRoundStart, g_fwRoundEnd, g_fwUserInfected_pre, g_fwUserInfected_post,
g_fwUserHumanized_pre, g_fwUserHumanized_post, g_fwUserInfect_attempt,
g_fwUserHumanize_attempt, g_fwExtraItemSelected, g_fwUserUnfrozen,
g_fwUserLastZombie, g_fwUserLastHuman, g_fwDummyResult

// Temporary Database vars (used to restore players stats in case they get disconnected)
new db_name[MAX_STATS_SAVED][32] // player name
new db_ammopacks[MAX_STATS_SAVED] // ammo pack count
new db_zombieclass[MAX_STATS_SAVED] // zombie class
new db_slot_i // additional saved slots counter (should start on maxplayers+1)

// Extra Items vars
new g_extraitem_i // loaded extra items counter
new Array:g_extraitem_realname
new Array:g_extraitem_name // caption
new Array:g_extraitem_cost // cost
new Array:g_extraitem_bolt // bolt
new Array:g_extraitem_team // team
new Array:g_extraitem_slot // slot
new Array:g_extraitem_lvl // slot
new Array:g_extraitem_weapon // weapon type name
new Array:g_extraitem_new

new const item_slots[][] =
{
	"PISTOLS",
	"SHOTGUN",
	"SUB MACHINE GUNS",
	"RIFLE",
	"MACHINE GUNS",
	"EQUIPMENT",
	"SYPER"
}

enum
{
	PISTOLS = 0,
	SHOTGUN,
	SUB_MACHINE_GUNS,
	RIFLE,
	MACHINE_GUNS,
	EQUIPMENT,
	SYPER
}

// Zombie Classes vars
new Array:g_zclass_name // caption
new Array:g_zclass_info // description
new Array:g_zclass_modelsstart // start position in models array
new Array:g_zclass_modelsend // end position in models array
new Array:g_zclass_playermodel // player models array
new Array:g_zclass_modelindex // model indices array
new Array:g_zclass_clawmodel // claw model
new Array:g_zclass_zbombmodel // claw model
new Array:g_zclass_hp // health
new Array:g_zclass_spd // speed
new Array:g_zclass_grav // gravity
new Array:g_zclass_kb // knockback
new g_zclass_i // loaded zombie classes counter

// For zombie classes file parsing
new Array:g_zclass2_realname, Array:g_zclass2_name, Array:g_zclass2_info,
Array:g_zclass2_modelsstart, Array:g_zclass2_modelsend, Array:g_zclass2_playermodel,
Array:g_zclass2_modelindex, Array:g_zclass2_clawmodel, Array:g_zclass2_zbombmodel, Array:g_zclass2_hp,
Array:g_zclass2_spd, Array:g_zclass2_grav, Array:g_zclass2_kb, Array:g_zclass_new

new g_draw_sound[7][64], g_hit_normal_sound[7][64], g_hit_miss_sound[7][64], g_hit_stab_sound[7][64], g_hit_wall_sound[7][64], model_vknife_human[7][64],  model_pknife_human[7][64]

new Array:class_sound_infect, Array:class_sound_pain, Array:class_sound_die,
Array:class_sound_miss_slash, Array:class_sound_miss_wall, Array:class_sound_hit_normal, Array:class_sound_hit_stab, Array:class_sound_burn,
Array:pointer_class_sound_infect, Array:pointer_class_sound_pain, Array:pointer_class_sound_die,
Array:pointer_class_sound_miss_slash, Array:pointer_class_sound_miss_wall, Array:pointer_class_sound_hit_normal, Array:pointer_class_sound_hit_stab, Array:pointer_class_sound_burn

new Array:nemesis_hit_normal, Array:nemesis_hit_stab, Array:nemesis_miss_slash, Array:nemesis_miss_wall, Array:nemesis_die,
Array:nemesis_pain

// Customization vars
new g_access_flag[MAX_ACCESS_FLAGS], Array:model_nemesis, Array:model_survivor,
Array:model_admin_human, Array:model_human,
Array:g_modelindex_nemesis, Array:g_modelindex_survivor, g_same_models_for_all,
Array:g_modelindex_admin_human, 
model_vknife_nemesis[64],
model_grenade_pipe[64] , model_wgrenade_pipe[64], model_pgrenade_pipe[64],
model_grenade_fire[64], model_grenade_frost[64], model_grenade_antidote[64],
model_wgrenade_frost[64], model_wgrenade_fire[64], model_wgrenade_antidote[64],
model_pgrenade_frost[64], model_pgrenade_fire[64], model_pgrenade_antidote[64],
sprite_grenade_trail[64], sprite_grenade_ring[64], sprite_grenade_fire[64],
sprite_grenade_smoke[64], sprite_grenade_glass[64], 
sprite_grenade_explofire[64], sprite_grenade_explofrost[64], sprite_grenade_exploantidote[64],
sprite_grenade_gibsfire[64], sprite_grenade_gibsfrost[64],
sprite_grenade_explozbomb[64],

Array:sound_firstzm,
Array:sound_headshot,
Array:sound_lastman,
Array:sound_win_zombies,
Array:sound_win_humans, Array:sound_win_no_one, Array:sound_win_zombies_ismp3,
Array:sound_win_humans_ismp3, Array:sound_win_no_one_ismp3,
g_ambience_rain,
Array:zombie_madness, Array:sound_nemesis, Array:sound_survivor,
Array:sound_swarm, Array:sound_multi, Array:sound_plague, 
Array:grenade_fire, Array:grenade_fire_player, Array:grenade_zbomb, Array:grenade_antidote,
Array:grenade_frost, Array:grenade_frost_player, Array:grenade_frost_break,
Array:grenade_flare, Array:sound_antidote, Array:sound_thunder, g_ambience_sounds[MAX_AMBIENCE_SOUNDS],
Array:sound_ambience1, Array:sound_ambience2, Array:sound_ambience3, Array:sound_ambience4,
Array:sound_ambience5, Array:sound_ambience1_duration, Array:sound_ambience2_duration,
Array:sound_ambience3_duration, Array:sound_ambience4_duration,
Array:sound_ambience5_duration, Array:sound_ambience1_ismp3, Array:sound_ambience2_ismp3,
Array:sound_ambience3_ismp3, Array:sound_ambience4_ismp3, Array:sound_ambience5_ismp3,
Array:g_primary_items, Array:g_secondary_items, Array:g_additional_items,
Array:g_primary_weaponids, Array:g_secondary_weaponids, Array:g_extraweapon_names,
Array:g_extraweapon_items, Array:g_extraweapon_costs,
g_ambience_snow, g_ambience_fog, g_fog_density[10], g_fog_color[12], g_sky_enable,
Array:g_sky_names, Array:lights_thunder, Array:zombie_decals, Array:g_objective_ents,
Float:g_modelchange_delay, g_set_modelindex_offset, g_handle_models_on_separate_ent,
Float:kb_weapon_power[31] = { -1.0, ... }, g_force_consistency

// CVAR pointers
new cvar_lighting, cvar_plague, cvar_plaguechance, cvar_zombiefirsthp, cvar_removemoney,
cvar_thunder, cvar_zombiebonushp, cvar_nemhp, cvar_nem, cvar_surv,
cvar_nemchance, cvar_deathmatch, cvar_hitzones, cvar_humanhp,
cvar_nemgravity, cvar_flashsize, cvar_ammodamage_human,
cvar_survpainfree, cvar_nempainfree, cvar_nemspd, cvar_survchance,
cvar_survhp, cvar_survspd, cvar_humanspd, cvar_swarmchance, cvar_flashdrain,
cvar_zombiebleeding, cvar_removedoors, cvar_customflash, cvar_randspawn, cvar_multi,
cvar_multichance, cvar_infammo, cvar_swarm, cvar_ammoinfect, cvar_toggle,
cvar_knockbackpower, cvar_triggered, cvar_flashcharge,
cvar_firegrenades, cvar_frostgrenades, cvar_survgravity, cvar_logcommands, 
cvar_humangravity, cvar_spawnprotection, cvar_zclasses,
cvar_extraitems, cvar_humanlasthp, cvar_nemignorefrags, cvar_warmup,
cvar_flashdist, cvar_survignorefrags, cvar_fireduration, cvar_firedamage,
cvar_flaregrenades, cvar_knockbackducking, cvar_knockbackdamage, cvar_knockbackzvel,
cvar_multiratio,
cvar_preventconsecutive, cvar_botquota,
cvar_zombiepainfree, cvar_fireslowdown, cvar_nemignoreammo, cvar_survignoreammo, cvar_knockback,
cvar_fragsinfect, cvar_fragskill, cvar_humanarmor, cvar_removedropped,
cvar_plagueratio, cvar_knockbackdist, cvar_leapzombies,
cvar_leapzombiesforce, cvar_leapzombiesheight, cvar_leapzombiescooldown, cvar_leapnemesis,
cvar_leapnemesisforce, cvar_leapnemesisheight, cvar_leapnemesiscooldown, cvar_leapsurvivor,
cvar_leapsurvivorforce, cvar_leapsurvivorheight, cvar_nemminplayers, cvar_survminplayers,
cvar_respawnafterlast, cvar_leapsurvivorcooldown, cvar_statssave,
cvar_swarmminplayers, cvar_multiminplayers, cvar_plagueminplayers, cvar_nembasehp, cvar_blockpushables, cvar_respawnworldspawnkill,
cvar_madnessduration, cvar_plaguenemnum, cvar_plaguenemhpmulti, cvar_plaguesurvhpmulti,
cvar_plaguesurvnum, cvar_infectionscreenfade, cvar_infectionscreenshake,
cvar_infectionsparkle, cvar_infectiontracers, cvar_infectionparticles,
cvar_allowrespawnsurv, cvar_flashshowall, cvar_allowrespawninfection, cvar_allowrespawnnem,
cvar_allowrespawnswarm, cvar_allowrespawnplague, cvar_nemknockback,
cvar_flashcolor[3],
cvar_hudicons,
cvar_startammopacks, cvar_randweapons, cvar_keephealthondisconnect,
cvar_buyzonetime, cvar_huddisplay

// Cached stuff for players
new g_isconnected[33] // whether player is connected
new g_isalive[33] // whether player is alive
new g_isbot[33] // whether player is a bot
new g_currentweapon[33] // player's current weapon id
new g_playername[33][32] // player's name
new Float:g_zombie_spd[33] // zombie class speed
new Float:g_zombie_knockback[33] // zombie class knockback
new g_zombie_classname[33][32] // zombie class name
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])
#define is_user_valid(%1) (1 <= %1 <= g_maxplayers)

// Cached CVARs
new g_cached_customflash, g_cached_leapzombies, g_cached_leapnemesis,
g_cached_leapsurvivor, Float:g_cached_leapzombiescooldown, Float:g_cached_leapnemesiscooldown,
Float:g_cached_leapsurvivorcooldown, Float:g_cached_buytime

/*================================================================================
 [Natives, Precache and Init]
=================================================================================*/

public plugin_natives()
{
	// Player specific natives
	register_native("zp_get_user_zombie", "native_get_user_zombie", 1)
	register_native("zp_get_user_nemesis", "native_get_user_nemesis", 1)
	register_native("zp_get_user_survivor", "native_get_user_survivor", 1)
	register_native("zp_get_user_first_zombie", "native_get_user_first_zombie", 1)
	register_native("zp_get_user_last_zombie", "native_get_user_last_zombie", 1)
	register_native("zp_get_user_last_human", "native_get_user_last_human", 1)
	register_native("zp_get_user_zombie_class", "native_get_user_zombie_class", 1)
	register_native("zp_get_user_next_class", "native_get_user_next_class", 1)
	register_native("zp_set_user_zombie_class", "native_set_user_zombie_class", 1)
	register_native("zp_get_user_ammo_packs", "native_get_user_ammo_packs", 1)
	register_native("zp_set_user_ammo_packs", "native_set_user_ammo_packs", 1)
    register_native("zp_get_user_token", "zp_get_user_token", 1)
	register_native("zp_buy_random_item", "zp_buy_random_item", 1)
    register_native("zp_set_user_token", "zp_set_user_token", 1)
	
	register_native("zp_set_user_admgrab", "zp_set_user_admgrab", 1)
	
	register_native("zp_get_user_admgrab", "zp_get_user_admgrab", 1)
	
	register_native("zp_get_user_lvl", "native_get_user_lvl", 1)
	register_native("zp_set_user_lvl", "native_set_user_lvl", 1)
	
	register_native("zp_get_user_exp", "native_get_user_exp", 1)
	register_native("zp_set_user_exp", "native_set_user_exp", 1)
	
	register_native("zp_get_user_pts", "native_get_user_pts", 1)
	register_native("zp_set_user_pts", "native_set_user_pts", 1)
	
	register_native("zp_give_pipe_bomb", "give_pipe_native", 1)
	
	register_native("zp_get_zombie_maxhealth", "native_get_zombie_maxhealth", 1)
	register_native("zp_get_user_batteries", "native_get_user_batteries", 1)
	register_native("zp_set_user_batteries", "native_set_user_batteries", 1)
	register_native("zp_infect_user", "native_infect_user", 1)
	register_native("zp_disinfect_user", "native_disinfect_user", 1)
	register_native("zp_make_user_nemesis", "native_make_user_nemesis", 1)
	register_native("zp_make_user_survivor", "native_make_user_survivor", 1)
	register_native("zp_respawn_user", "native_respawn_user", 1)
	register_native("zp_force_buy_extra_item", "native_force_buy_extra_item", 1)
	register_native("zp_override_user_model", "native_override_user_model", 1)
	
	// Round natives
	register_native("zp_has_round_started", "native_has_round_started", 1)
	register_native("zp_is_nemesis_round", "native_is_nemesis_round", 1)
	register_native("zp_is_survivor_round", "native_is_survivor_round", 1)
	register_native("zp_is_swarm_round", "native_is_swarm_round", 1)
	register_native("zp_is_plague_round", "native_is_plague_round", 1)
	register_native("zp_get_zombie_count", "native_get_zombie_count", 1)
	register_native("zp_get_human_count", "native_get_human_count", 1)
	register_native("zp_get_nemesis_count", "native_get_nemesis_count", 1)
	register_native("zp_get_survivor_count", "native_get_survivor_count", 1)
	
	// External additions natives
	register_native("zp_register_extra_item", "native_register_extra_item", 1)
	register_native("zp_register_zombie_class", "native_register_zombie_class", 1)
	register_native("zp_get_extra_item_id", "native_get_extra_item_id", 1)
	register_native("zp_get_zombie_class_id", "native_get_zombie_class_id", 1)
	register_native("zp_get_zombie_class_info", "native_get_zombie_class_info", 1)

	register_native("zp_color_menu", "zp_color_menu", 1)
}

public zp_get_user_token(id)
{	
	return g_iToken[id];
}

public zp_set_user_token(id, amount)
{	
	g_iToken[id] = amount;
	return true;
}

public plugin_precache()
{
	// Register earlier to show up in plugins list properly after plugin disable/error at loading
	register_plugin("Zombie Plague", PLUGIN_VERSION, "MeRcyLeZZ")
	
    /*-----BossManager(start)-----*/
    Map_Boss = zl_boss_map()
    /*-----BossManager(End)-----*/
	
	// To switch plugin on/off
	register_concmd("zp_toggle", "cmd_toggle", _, "<1/0> - Enable/Disable Zombie Plague (will restart the current map)", 0)
	cvar_toggle = register_cvar("zp_on", "1")
	
	// Plugin disabled?
	if (!get_pcvar_num(cvar_toggle)) return;
	g_pluginenabled = true
	
	// Initialize a few dynamically sized arrays (alright, maybe more than just a few...)
	model_nemesis = ArrayCreate(32, 1)
	model_survivor = ArrayCreate(32, 1)
	model_admin_human = ArrayCreate(32, 1)
	model_human = ArrayCreate(32, 1)
	g_modelindex_nemesis = ArrayCreate(1, 1)
	g_modelindex_survivor = ArrayCreate(1, 1)
	g_modelindex_admin_human = ArrayCreate(1, 1)
	sound_win_zombies = ArrayCreate(64, 1)
	sound_firstzm = ArrayCreate(64, 1)
	sound_headshot = ArrayCreate(64, 1)
	sound_lastman = ArrayCreate(64, 1)
	sound_win_zombies_ismp3 = ArrayCreate(1, 1)
	sound_win_humans = ArrayCreate(64, 1)
	sound_win_humans_ismp3 = ArrayCreate(1, 1)
	sound_win_no_one = ArrayCreate(64, 1)
	sound_win_no_one_ismp3 = ArrayCreate(1, 1)
	zombie_madness = ArrayCreate(64, 1)
	sound_nemesis = ArrayCreate(64, 1)
	sound_survivor = ArrayCreate(64, 1)
	sound_swarm = ArrayCreate(64, 1)
	sound_multi = ArrayCreate(64, 1)
	sound_plague = ArrayCreate(64, 1)
	grenade_fire = ArrayCreate(64, 1)
	grenade_fire_player = ArrayCreate(64, 1)
	grenade_zbomb = ArrayCreate(64, 1)
	grenade_antidote = ArrayCreate(64, 1)
	grenade_frost = ArrayCreate(64, 1)
	grenade_frost_player = ArrayCreate(64, 1)
	grenade_frost_break = ArrayCreate(64, 1)
	grenade_flare = ArrayCreate(64, 1)
	sound_antidote = ArrayCreate(64, 1)
	sound_thunder = ArrayCreate(64, 1)
	sound_ambience1 = ArrayCreate(64, 1)
	sound_ambience2 = ArrayCreate(64, 1)
	sound_ambience3 = ArrayCreate(64, 1)
	sound_ambience4 = ArrayCreate(64, 1)
	sound_ambience5 = ArrayCreate(64, 1)
	sound_ambience1_duration = ArrayCreate(1, 1)
	sound_ambience2_duration = ArrayCreate(1, 1)
	sound_ambience3_duration = ArrayCreate(1, 1)
	sound_ambience4_duration = ArrayCreate(1, 1)
	sound_ambience5_duration = ArrayCreate(1, 1)
	sound_ambience1_ismp3 = ArrayCreate(1, 1)
	sound_ambience2_ismp3 = ArrayCreate(1, 1)
	sound_ambience3_ismp3 = ArrayCreate(1, 1)
	sound_ambience4_ismp3 = ArrayCreate(1, 1)
	sound_ambience5_ismp3 = ArrayCreate(1, 1)
	g_primary_items = ArrayCreate(32, 1)
	g_secondary_items = ArrayCreate(32, 1)
	g_additional_items = ArrayCreate(32, 1)
	g_primary_weaponids = ArrayCreate(1, 1)
	g_secondary_weaponids = ArrayCreate(1, 1)
	g_extraweapon_names = ArrayCreate(32, 1)
	g_extraweapon_items = ArrayCreate(32, 1)
	g_extraweapon_costs = ArrayCreate(1, 1)
	g_sky_names = ArrayCreate(32, 1)
	lights_thunder = ArrayCreate(32, 1)
	zombie_decals = ArrayCreate(1, 1)
	g_objective_ents = ArrayCreate(32, 1)
	g_extraitem_realname = ArrayCreate(32, 1)
	g_extraitem_name = ArrayCreate(64, 1)
	g_extraitem_cost = ArrayCreate(1, 1)
	g_extraitem_bolt = ArrayCreate(1, 1)
	g_extraitem_team = ArrayCreate(1, 1)
	g_extraitem_slot = ArrayCreate(1, 1)
	g_extraitem_lvl = ArrayCreate(1, 1)
	g_extraitem_weapon = ArrayCreate(32, 1)
	g_extraitem_new = ArrayCreate(1, 1)
	g_zclass_name = ArrayCreate(32, 1)
	g_zclass_info = ArrayCreate(32, 1)
	g_zclass_modelsstart = ArrayCreate(1, 1)
	g_zclass_modelsend = ArrayCreate(1, 1)
	g_zclass_playermodel = ArrayCreate(32, 1)
	g_zclass_modelindex = ArrayCreate(1, 1)
	g_zclass_clawmodel = ArrayCreate(32, 1)
	g_zclass_zbombmodel = ArrayCreate(32, 1)
	g_zclass_hp = ArrayCreate(1, 1)
	g_zclass_spd = ArrayCreate(1, 1)
	g_zclass_grav = ArrayCreate(1, 1)
	g_zclass_kb = ArrayCreate(1, 1)
	g_zclass2_realname = ArrayCreate(32, 1)
	g_zclass2_name = ArrayCreate(32, 1)
	g_zclass2_info = ArrayCreate(32, 1)
	g_zclass2_modelsstart = ArrayCreate(1, 1)
	g_zclass2_modelsend = ArrayCreate(1, 1)
	g_zclass2_playermodel = ArrayCreate(32, 1)
	g_zclass2_modelindex = ArrayCreate(1, 1)
	g_zclass2_clawmodel = ArrayCreate(32, 1)
	g_zclass2_zbombmodel = ArrayCreate(32, 1)
	g_zclass2_hp = ArrayCreate(1, 1)
	g_zclass2_spd = ArrayCreate(1, 1)
	g_zclass2_grav = ArrayCreate(1, 1)
	g_zclass2_kb = ArrayCreate(1, 1)
	g_zclass_new = ArrayCreate(1, 1)
	
	class_sound_infect = ArrayCreate(64, 1)
	class_sound_pain = ArrayCreate(64, 1)
	class_sound_die = ArrayCreate(64, 1)
	class_sound_miss_slash = ArrayCreate(64, 1)
	class_sound_miss_wall = ArrayCreate(64, 1)
	class_sound_hit_normal = ArrayCreate(64, 1)
	class_sound_hit_stab = ArrayCreate(64, 1)
	class_sound_burn = ArrayCreate(64, 1)
	
	pointer_class_sound_infect = ArrayCreate(10, 1)
	pointer_class_sound_pain = ArrayCreate(10, 1)
	pointer_class_sound_die = ArrayCreate(10, 1)
	pointer_class_sound_miss_slash = ArrayCreate(64, 1)
	pointer_class_sound_miss_wall = ArrayCreate(64, 1)
	pointer_class_sound_hit_normal = ArrayCreate(64, 1)
	pointer_class_sound_hit_stab = ArrayCreate(64, 1)
	pointer_class_sound_burn = ArrayCreate(10, 1)
	
	nemesis_hit_normal = ArrayCreate(64, 1)
	nemesis_hit_stab = ArrayCreate(64, 1)
	nemesis_miss_slash = ArrayCreate(64, 1) 
	nemesis_miss_wall = ArrayCreate(64, 1)
	nemesis_pain = ArrayCreate(64, 1) 
	nemesis_die = ArrayCreate(64, 1)
	
	// Allow registering stuff now
	g_arrays_created = true
	
	// Load customization data
	load_customization_from_files()
	
	new i, buffer[100]
	
	load_extras()
	
	// Custom player models
	for (i = 0; i < ArraySize(model_nemesis); i++)
	{
		ArrayGetString(model_nemesis, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_nemesis, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		// Precache modelT.mdl files too
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < ArraySize(model_survivor); i++)
	{
		ArrayGetString(model_survivor, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_survivor, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		// Precache modelT.mdl files too
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < ArraySize(model_admin_human); i++)
	{
		ArrayGetString(model_admin_human, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_admin_human, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		// Precache modelT.mdl files too
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < ArraySize(model_human); i++)
	{
		ArrayGetString(model_human, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_admin_human, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		// Precache modelT.mdl files too
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}

	// Custom weapon models
	engfunc(EngFunc_PrecacheModel, model_vknife_human[0])
	engfunc(EngFunc_PrecacheModel, model_vknife_human[1])
	engfunc(EngFunc_PrecacheModel, model_vknife_human[2])
	engfunc(EngFunc_PrecacheModel, model_vknife_human[3])
	engfunc(EngFunc_PrecacheModel, model_vknife_human[4])
	engfunc(EngFunc_PrecacheModel, model_vknife_human[5])
	engfunc(EngFunc_PrecacheModel, model_vknife_human[6])
	
	engfunc(EngFunc_PrecacheModel, model_pknife_human[0])
	engfunc(EngFunc_PrecacheModel, model_pknife_human[1])
	engfunc(EngFunc_PrecacheModel, model_pknife_human[2])
	engfunc(EngFunc_PrecacheModel, model_pknife_human[3])
	engfunc(EngFunc_PrecacheModel, model_pknife_human[4])
	engfunc(EngFunc_PrecacheModel, model_pknife_human[5])
	engfunc(EngFunc_PrecacheModel, model_pknife_human[6])
	
	engfunc(EngFunc_PrecacheModel, model_vknife_nemesis)
	engfunc(EngFunc_PrecacheModel, model_grenade_pipe)
	engfunc(EngFunc_PrecacheModel, model_grenade_fire)
	engfunc(EngFunc_PrecacheModel, model_grenade_frost)
	engfunc(EngFunc_PrecacheModel, model_grenade_antidote)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_fire)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_frost)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_antidote)
	engfunc(EngFunc_PrecacheModel, model_wgrenade_pipe)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_fire)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_pipe)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_frost)
	engfunc(EngFunc_PrecacheModel, model_pgrenade_antidote)
	
	for (i = 0; i < 5; i++){
		engfunc(EngFunc_PrecacheSound, g_draw_sound[i])
		engfunc(EngFunc_PrecacheSound, g_hit_normal_sound[i])
		engfunc(EngFunc_PrecacheSound, g_hit_miss_sound[i])
		engfunc(EngFunc_PrecacheSound, g_hit_stab_sound[i])
		engfunc(EngFunc_PrecacheSound, g_hit_wall_sound[i])
	}
	
	// Custom sprites for grenades
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
	g_flameSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_fire)
	g_smokeSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_smoke)
	g_glassSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_glass)
	g_metalgibs= engfunc(EngFunc_PrecacheModel, "models/metalplategibs.mdl")
	
	g_explo_fireSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_explofire)
	g_explo_frostSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_explofrost)
	g_explo_antidoteSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_exploantidote)
	g_explo_zbombSpr= engfunc(EngFunc_PrecacheModel, sprite_grenade_explozbomb) 
	
	g_gibs_fireSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_gibsfire)
	g_gibs_frostSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_gibsfrost)
	
	
	for (i = 1; i < 11; i++) {
		new snd[32]
		formatex(snd, 31, "BZ_sound/countdown/%d.wav", i)
		precache_sound(snd)
	}
	
	for (i = 0; i < ArraySize(sound_firstzm); i++)
	{
		ArrayGetString(sound_firstzm, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(sound_headshot); i++)
	{
		ArrayGetString(sound_headshot, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(sound_lastman); i++)
	{
		ArrayGetString(sound_lastman, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	// Custom sounds
	for (i = 0; i < ArraySize(sound_win_zombies); i++)
	{
		ArrayGetString(sound_win_zombies, i, buffer, charsmax(buffer))
		if (ArrayGetCell(sound_win_zombies_ismp3, i))
		{
			format(buffer, charsmax(buffer), "sound/%s", buffer)
			engfunc(EngFunc_PrecacheGeneric, buffer)
		}
		else
		{
			engfunc(EngFunc_PrecacheSound, buffer)
		}
	}
	for (i = 0; i < ArraySize(sound_win_humans); i++)
	{
		ArrayGetString(sound_win_humans, i, buffer, charsmax(buffer))
		if (ArrayGetCell(sound_win_humans_ismp3, i))
		{
			format(buffer, charsmax(buffer), "sound/%s", buffer)
			engfunc(EngFunc_PrecacheGeneric, buffer)
		}
		else
		{
			engfunc(EngFunc_PrecacheSound, buffer)
		}
	}
	for (i = 0; i < ArraySize(sound_win_no_one); i++)
	{
		ArrayGetString(sound_win_no_one, i, buffer, charsmax(buffer))
		if (ArrayGetCell(sound_win_no_one_ismp3, i))
		{
			format(buffer, charsmax(buffer), "sound/%s", buffer)
			engfunc(EngFunc_PrecacheGeneric, buffer)
		}
		else
		{
			engfunc(EngFunc_PrecacheSound, buffer)
		}
	}

	for (i = 0; i < ArraySize(nemesis_pain); i++)
	{
		ArrayGetString(nemesis_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(nemesis_hit_normal); i++)
	{
		ArrayGetString(nemesis_hit_normal, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(nemesis_hit_stab); i++)
	{
		ArrayGetString(nemesis_hit_stab, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(nemesis_miss_slash); i++)
	{
		ArrayGetString(nemesis_miss_slash, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(nemesis_miss_wall); i++)
	{
		ArrayGetString(nemesis_miss_wall, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(nemesis_die); i++)
	{
		ArrayGetString(nemesis_die, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_madness); i++)
	{
		ArrayGetString(zombie_madness, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_nemesis); i++)
	{
		ArrayGetString(sound_nemesis, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_survivor); i++)
	{
		ArrayGetString(sound_survivor, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_swarm); i++)
	{
		ArrayGetString(sound_swarm, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_multi); i++)
	{
		ArrayGetString(sound_multi, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_plague); i++)
	{
		ArrayGetString(sound_plague, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_fire); i++)
	{
		ArrayGetString(grenade_fire, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_zbomb); i++)
	{
		ArrayGetString(grenade_zbomb, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_antidote); i++)
	{
		ArrayGetString(grenade_antidote, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_fire_player); i++)
	{
		ArrayGetString(grenade_fire_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost); i++)
	{
		ArrayGetString(grenade_frost, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost_player); i++)
	{
		ArrayGetString(grenade_frost_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost_break); i++)
	{
		ArrayGetString(grenade_frost_break, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_flare); i++)
	{
		ArrayGetString(grenade_flare, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_antidote); i++)
	{
		ArrayGetString(sound_antidote, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_thunder); i++)
	{
		ArrayGetString(sound_thunder, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	for (i = 0; i < ArraySize(class_sound_infect); i++)
	{
		ArrayGetString(class_sound_infect, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(class_sound_pain); i++)
	{
		ArrayGetString(class_sound_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(class_sound_burn); i++)
	{
		ArrayGetString(class_sound_burn, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(class_sound_die); i++)
	{
		ArrayGetString(class_sound_die, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	for (i = 0; i < ArraySize(class_sound_miss_slash); i++)
	{
		ArrayGetString(class_sound_miss_slash, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(class_sound_miss_wall); i++)
	{
		ArrayGetString(class_sound_miss_wall, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}	
	for (i = 0; i < ArraySize(class_sound_hit_normal); i++)
	{
		ArrayGetString(class_sound_hit_normal, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(class_sound_hit_stab); i++)
	{
		ArrayGetString(class_sound_hit_stab, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	// Ambience Sounds
	if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION])
	{
		for (i = 0; i < ArraySize(sound_ambience1); i++)
		{
			ArrayGetString(sound_ambience1, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience1_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS])
	{
		for (i = 0; i < ArraySize(sound_ambience2); i++)
		{
			ArrayGetString(sound_ambience2, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience2_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR])
	{
		for (i = 0; i < ArraySize(sound_ambience3); i++)
		{
			ArrayGetString(sound_ambience3, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience3_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM])
	{
		for (i = 0; i < ArraySize(sound_ambience4); i++)
		{
			ArrayGetString(sound_ambience4, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience4_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE])
	{
		for (i = 0; i < ArraySize(sound_ambience5); i++)
		{
			ArrayGetString(sound_ambience5, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience5_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	
	// CS sounds (just in case)
	engfunc(EngFunc_PrecacheSound, sound_flashlight)
	engfunc(EngFunc_PrecacheSound, sound_buyammo)
	engfunc(EngFunc_PrecacheSound, sound_armorhit)
	engfunc(EngFunc_PrecacheModel, "models/BZ_models/p_zombibomb.mdl")
	engfunc(EngFunc_PrecacheModel, "models/BZ_models/w_zombibomb.mdl")
	
	precache_sound(SND_MENU_OFF)
	precache_sound("BZ_sound/countdown/prepare.wav")
	precache_sound("BZ_sound/countdown/attacking.wav")
	precache_sound("weapons/dryfire_rifle.wav")
	
	new ent
	
    /*-----BossManager(start)-----*/
    if (!Map_Boss) {
        // Fake Hostage (to force round ending)
        ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
        if (pev_valid(ent))
        {
            engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
            dllfunc(DLLFunc_Spawn, ent)
        }
    }
    /*-----BossManager(End)-----*/
	
	// Fake Hostage (to force round ending)
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	
	// Weather/ambience effects
	if (g_ambience_fog)
	{
		ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
		if (pev_valid(ent))
		{
			fm_set_kvd(ent, "density", g_fog_density, "env_fog")
			fm_set_kvd(ent, "rendercolor", g_fog_color, "env_fog")
		}
	}
	if (g_ambience_rain) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
	if (g_ambience_snow) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))
	
	// Custom buyzone for all players
	g_buyzone_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	if (pev_valid(g_buyzone_ent))
	{
		dllfunc(DLLFunc_Spawn, g_buyzone_ent)
		set_pev(g_buyzone_ent, pev_solid, SOLID_NOT)
	}
	
	// Prevent some entities from spawning
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	
	// Prevent hostage sounds from being precached
	g_fwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound")
}

public plugin_init()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// No zombie classes?
	if (!g_zclass_i) set_fail_state("No zombie classes loaded!")
	
	// Language files
	register_dictionary("zombie_plague.txt")
	
	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("StatusValue", "event_show_status", "be", "1=2", "2!0");
	register_event("StatusValue", "event_hide_status", "be", "1=1", "2=0");
	register_logevent("logevent_round_start",2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_event("AmmoX", "event_ammo_x", "be")
	if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] || g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] || g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] || g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] || g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE])
		register_event("30", "event_intermission", "a")
	
	// HAM Forwards
	EntTimer = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(EntTimer, pev_classname, "Timer")
	RegisterHamFromEntity(Ham_Think, EntTimer, "Ham_Timer")
	set_pev(EntTimer, pev_nextthink, get_gametime() + 1.0)
	
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeed_Post", 1)
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_pushable", "fw_UsePushable")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_AddPlayerItem, "player", "fw_AddPlayerItem")
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife","fw_Attack")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife","fw_Attack")
	
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++){
		if (WEAPONENTNAMES[i][0]) {
			RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
			RegisterHam(Ham_Weapon_PrimaryAttack, WEAPONENTNAMES[i], "fw_Weapon_PrimaryAttack_Post", 1)
		}
	}

	// FM Forwards
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	register_forward(FM_ClientKill, "fw_ClientKill")
	register_forward(FM_EmitSound, "fw_EmitSound")
	if (!g_handle_models_on_separate_ent) register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	unregister_forward(FM_Spawn, g_fwSpawn)
	unregister_forward(FM_PrecacheSound, g_fwPrecacheSound)
	
	// Client commands
	register_clcmd("say zpmenu", "clcmd_saymenu")
	register_clcmd("say /zpmenu", "clcmd_saymenu")
	register_clcmd("nightvision", "clcmd_nightvision")
	register_clcmd("drop", "clcmd_drop")
	register_clcmd("buyammo1", "clcmd_buyammo")
	register_clcmd("buyammo2", "clcmd_buyammo")
	register_clcmd("chooseteam", "clcmd_changeteam")
	register_clcmd("jointeam", "clcmd_changeteam")
	
	register_clcmd("buy", "go_buy")
	register_clcmd("client_buy_open", "go_buy")
	register_clcmd("buyequip", "go_buy")
	
	for(new i; i<=charsmax(Commands); i++)
		register_clcmd(Commands[i], "BlockAutobuy")	
	
	// Menus
	register_menu("Game Menu", KEYSMENU, "menu_game")
	register_menu("Privil Menu", KEYSMENU, "menu_privil")
	register_menu("Cabinet Menu", KEYSMENU, "menu_cabinet")
	register_menu("Settings Menu", KEYSMENU, "menu_settings")
	register_menu("Colors2 Menu", KEYSMENU, "menu_colors_bz")
	register_menu("Knife Menu", KEYSMENU, "menu_knife")
	register_menu("Points Menu", KEYSMENU, "menu_points")
	register_menu("Buy Menu 1", KEYSMENU, "menu_buy1")
	//register_menu("Buy Menu 2", KEYSMENU, "menu_buy2")
	register_menu("Buy Menu 3", KEYSMENU, "menu_buy3")
	register_menu("Mod Info", KEYSMENU, "menu_info")
	register_menu("Admin Menu", KEYSMENU, "menu_admin")
	register_menu("Colors Menu", KEYSMENU, "menu_colors")
	register_menu("Obmen Menu", KEYSMENU, "menu_obmen")
	register_menu("Modes Vote Menu", KEYSMENU, "menu_modes")
	
	// CS Buy Menus (to prevent zombies/survivor from buying)
	register_menucmd(register_menuid("#Buy", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyPistol", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyShotgun", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuySub", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyRifle", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyMachine", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyItem", 1), 511, "menu_cs_buy")
	register_menucmd(-28, 511, "menu_cs_buy")
	register_menucmd(-29, 511, "menu_cs_buy")
	register_menucmd(-30, 511, "menu_cs_buy")
	register_menucmd(-32, 511, "menu_cs_buy")
	register_menucmd(-31, 511, "menu_cs_buy")
	register_menucmd(-33, 511, "menu_cs_buy")
	register_menucmd(-34, 511, "menu_cs_buy")
	
	// Admin commands
	register_concmd("zp_zombie11", "cmd_zombie", _, "<target> - Turn someone into a Zombie", 0)
	register_concmd("zp_human1212", "cmd_human", _, "<target> - Turn someone back to Human", 0)
	register_concmd("zp_nemesis121", "cmd_nemesis", _, "<target> - Turn someone into a Nemesis", 0)
	register_concmd("zp_survivor1212", "cmd_survivor", _, "<target> - Turn someone into a Survivor", 0)
	register_concmd("zp_respawn1212", "cmd_respawn", _, "<target> - Respawn someone", 0)
	register_concmd("zp_swarm12", "cmd_swarm", _, " - Start Swarm Mode", 0)
	register_concmd("zp_multi1212", "cmd_multi", _, " - Start Multi Infection", 0)
	register_concmd("zp_plague1212", "cmd_plague", _, " - Start Plague Mode", 0)
	
	// Message IDs
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	g_msgNVGToggle = get_user_msgid("NVGToggle")
	g_msgFlashlight = get_user_msgid("Flashlight")
	g_msgFlashBat = get_user_msgid("FlashBat")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgDamage = get_user_msgid("Damage")
    g_msgHideWeapon = get_user_msgid("HideWeapon")
    g_msgCrosshair = get_user_msgid("Crosshair")
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	
	// Message hooks
	register_message(g_msgScoreAttrib,   "message_scoreattrib" );
	register_message(g_msgCurWeapon, "message_cur_weapon")
    register_message(get_user_msgid("Money"), "message_money")
	register_message(get_user_msgid("Health"), "message_health")
	register_message(g_msgFlashBat, "message_flashbat")
	register_message(g_msgScreenFade, "message_screenfade")
	register_message(g_msgNVGToggle, "message_nvgtoggle")
	if (g_handle_models_on_separate_ent) register_message(get_user_msgid("ClCorpse"), "message_clcorpse")
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")
	register_message(g_msgAmmoPickup, "message_ammopickup")
	register_message(get_user_msgid("Scenario"), "message_scenario")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"), "message_sendaudio")
	register_message(get_user_msgid("TeamScore"), "message_teamscore")
	register_message(g_msgTeamInfo, "message_teaminfo")
	register_message(get_user_msgid("StatusIcon"), "message_statusicon")
	
	// CVARS - General Purpose
	cvar_warmup = register_cvar("zp_delay", "10")
	cvar_lighting = register_cvar("zp_lighting", "a")
	cvar_thunder = register_cvar("zp_thunderclap", "90")
	cvar_triggered = register_cvar("zp_triggered_lights", "1")
	cvar_removedoors = register_cvar("zp_remove_doors", "0")
	cvar_blockpushables = register_cvar("zp_blockuse_pushables", "1")
	cvar_randspawn = register_cvar("zp_random_spawn", "1")
	cvar_respawnworldspawnkill = register_cvar("zp_respawn_on_worldspawn_kill", "1")
	cvar_removedropped = register_cvar("zp_remove_dropped", "0")
    cvar_removemoney = register_cvar("zp_remove_money", "1")
	cvar_buyzonetime = register_cvar("zp_buyzone_time", "0.0")
	cvar_randweapons = register_cvar("zp_random_weapons", "0")
	cvar_zclasses = register_cvar("zp_zombie_classes", "1")
	cvar_statssave = register_cvar("zp_stats_save", "0")
	cvar_startammopacks = register_cvar("zp_starting_ammo_packs", "200")
	cvar_preventconsecutive = register_cvar("zp_prevent_consecutive_modes", "1")
	cvar_keephealthondisconnect = register_cvar("zp_keep_health_on_disconnect", "1")
	cvar_huddisplay = register_cvar("zp_hud_display", "1")
	
	// CVARS - Deathmatch
	cvar_deathmatch = register_cvar("zp_deathmatch", "0")
	cvar_spawnprotection = register_cvar("zp_spawn_protection", "5")
	cvar_respawnafterlast = register_cvar("zp_respawn_after_last_human", "1")
	cvar_allowrespawninfection = register_cvar("zp_infection_allow_respawn", "1")
	cvar_allowrespawnnem = register_cvar("zp_nem_allow_respawn", "0")
	cvar_allowrespawnsurv = register_cvar("zp_surv_allow_respawn", "0")
	cvar_allowrespawnswarm = register_cvar("zp_swarm_allow_respawn", "0")
	cvar_allowrespawnplague = register_cvar("zp_plague_allow_respawn", "0")
	
	// CVARS - Extra Items
	cvar_extraitems = register_cvar("zp_extra_items", "1")
	cvar_madnessduration = register_cvar("zp_extra_madness_duration", "5.0")
	
	// CVARS - Flashlight
	cvar_customflash = register_cvar("zp_flash_custom", "0")
	cvar_flashsize = register_cvar("zp_flash_size", "10")
	cvar_flashdrain = register_cvar("zp_flash_drain", "1")
	cvar_flashcharge = register_cvar("zp_flash_charge", "5")
	cvar_flashdist = register_cvar("zp_flash_distance", "1000")
	cvar_flashcolor[0] = register_cvar("zp_flash_color_R", "100")
	cvar_flashcolor[1] = register_cvar("zp_flash_color_G", "100")
	cvar_flashcolor[2] = register_cvar("zp_flash_color_B", "100")
	cvar_flashshowall = register_cvar("zp_flash_show_all", "1")
	
	// CVARS - Knockback
	cvar_knockback = register_cvar("zp_knockback", "0")
	cvar_knockbackdamage = register_cvar("zp_knockback_damage", "1")
	cvar_knockbackpower = register_cvar("zp_knockback_power", "1")
	cvar_knockbackzvel = register_cvar("zp_knockback_zvel", "0")
	cvar_knockbackducking = register_cvar("zp_knockback_ducking", "0.25")
	cvar_knockbackdist = register_cvar("zp_knockback_distance", "500")
	cvar_nemknockback = register_cvar("zp_knockback_nemesis", "0.25")
	
	// CVARS - Leap
	cvar_leapzombies = register_cvar("zp_leap_zombies", "0")
	cvar_leapzombiesforce = register_cvar("zp_leap_zombies_force", "500")
	cvar_leapzombiesheight = register_cvar("zp_leap_zombies_height", "300")
	cvar_leapzombiescooldown = register_cvar("zp_leap_zombies_cooldown", "5.0")
	cvar_leapnemesis = register_cvar("zp_leap_nemesis", "1")
	cvar_leapnemesisforce = register_cvar("zp_leap_nemesis_force", "500")
	cvar_leapnemesisheight = register_cvar("zp_leap_nemesis_height", "300")
	cvar_leapnemesiscooldown = register_cvar("zp_leap_nemesis_cooldown", "5.0")
	cvar_leapsurvivor = register_cvar("zp_leap_survivor", "0")
	cvar_leapsurvivorforce = register_cvar("zp_leap_survivor_force", "500")
	cvar_leapsurvivorheight = register_cvar("zp_leap_survivor_height", "300")
	cvar_leapsurvivorcooldown = register_cvar("zp_leap_survivor_cooldown", "5.0")
	
	// CVARS - Humans
	cvar_humanhp = register_cvar("zp_human_health", "100")
	cvar_humanlasthp = register_cvar("zp_human_last_extrahp", "0")
	cvar_humanspd = register_cvar("zp_human_speed", "240")
	cvar_humangravity = register_cvar("zp_human_gravity", "1.0")
	cvar_humanarmor = register_cvar("zp_human_armor_protect", "1")
	cvar_infammo = register_cvar("zp_human_unlimited_ammo", "0")
	cvar_ammodamage_human = register_cvar("zp_human_damage_reward", "500")
	cvar_fragskill = register_cvar("zp_human_frags_for_kill", "1")
	
	// CVARS - Custom Grenades
	cvar_firegrenades = register_cvar("zp_fire_grenades", "1")
	cvar_fireduration = register_cvar("zp_fire_duration", "10")
	cvar_firedamage = register_cvar("zp_fire_damage", "5")
	cvar_fireslowdown = register_cvar("zp_fire_slowdown", "0.5")
	cvar_frostgrenades = register_cvar("zp_frost_grenades", "1")
	cvar_flaregrenades = register_cvar("zp_flare_grenades","1")
	
	// CVARS - Zombies
	cvar_zombiefirsthp = register_cvar("zp_zombie_first_hp", "2.0")
	cvar_hitzones = register_cvar("zp_zombie_hitzones", "0")
	cvar_zombiebonushp = register_cvar("zp_zombie_infect_health", "100")
	cvar_zombiepainfree = register_cvar("zp_zombie_painfree", "2")
	cvar_zombiebleeding = register_cvar("zp_zombie_bleeding", "1")
	cvar_ammoinfect = register_cvar("zp_zombie_infect_reward", "1")
	cvar_fragsinfect = register_cvar("zp_zombie_frags_for_infect", "1")
	
	// CVARS - Special Effects
	cvar_infectionscreenfade = register_cvar("zp_infection_screenfade", "1")
	cvar_infectionscreenshake = register_cvar("zp_infection_screenshake", "1")
	cvar_infectionsparkle = register_cvar("zp_infection_sparkle", "1")
	cvar_infectiontracers = register_cvar("zp_infection_tracers", "1")
	cvar_infectionparticles = register_cvar("zp_infection_particles", "1")
	cvar_hudicons = register_cvar("zp_hud_icons", "1")
	
	// CVARS - Nemesis
	cvar_nem = register_cvar("zp_nem_enabled", "1")
	cvar_nemchance = register_cvar("zp_nem_chance", "20")
	cvar_nemminplayers = register_cvar("zp_nem_min_players", "0")
	cvar_nemhp = register_cvar("zp_nem_health", "0")
	cvar_nembasehp = register_cvar("zp_nem_base_health", "0")
	cvar_nemspd = register_cvar("zp_nem_speed", "250")
	cvar_nemgravity = register_cvar("zp_nem_gravity", "0.5")
	cvar_nempainfree = register_cvar("zp_nem_painfree", "0")
	cvar_nemignorefrags = register_cvar("zp_nem_ignore_frags", "1")
	cvar_nemignoreammo = register_cvar("zp_nem_ignore_rewards", "1")
	
	// CVARS - Survivor
	cvar_surv = register_cvar("zp_surv_enabled", "1")
	cvar_survchance = register_cvar("zp_surv_chance", "20")
	cvar_survminplayers = register_cvar("zp_surv_min_players", "0")
	cvar_survhp = register_cvar("zp_surv_health", "0")
	cvar_survspd = register_cvar("zp_surv_speed", "230")
	cvar_survgravity = register_cvar("zp_surv_gravity", "1.25")
	cvar_survpainfree = register_cvar("zp_surv_painfree", "1")
	cvar_survignorefrags = register_cvar("zp_surv_ignore_frags", "1")
	cvar_survignoreammo = register_cvar("zp_surv_ignore_rewards", "1")
	
	// CVARS - Swarm Mode
	cvar_swarm = register_cvar("zp_swarm_enabled", "1")
	cvar_swarmchance = register_cvar("zp_swarm_chance", "20")
	cvar_swarmminplayers = register_cvar("zp_swarm_min_players", "0")
	
	// CVARS - Multi Infection
	cvar_multi = register_cvar("zp_multi_enabled", "1")
	cvar_multichance = register_cvar("zp_multi_chance", "20")
	cvar_multiminplayers = register_cvar("zp_multi_min_players", "0")
	cvar_multiratio = register_cvar("zp_multi_ratio", "0.15")
	
	// CVARS - Plague Mode
	cvar_plague = register_cvar("zp_plague_enabled", "1")
	cvar_plaguechance = register_cvar("zp_plague_chance", "30")
	cvar_plagueminplayers = register_cvar("zp_plague_min_players", "0")
	cvar_plagueratio = register_cvar("zp_plague_ratio", "0.5")
	cvar_plaguenemnum = register_cvar("zp_plague_nem_number", "1")
	cvar_plaguenemhpmulti = register_cvar("zp_plague_nem_hp_multi", "0.5")
	cvar_plaguesurvnum = register_cvar("zp_plague_surv_number", "1")
	cvar_plaguesurvhpmulti = register_cvar("zp_plague_surv_hp_multi", "0.5")
	
	// CVARS - Others
	cvar_logcommands = register_cvar("zp_logcommands", "1")
	cvar_botquota = get_cvar_pointer("bot_quota")
	register_cvar("zp_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("zp_version", PLUGIN_VERSION)
	
	// Custom Forwards
	g_fwRoundStart = CreateMultiForward("zp_round_started", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwRoundEnd = CreateMultiForward("zp_round_ended", ET_IGNORE, FP_CELL)
	g_fwUserInfected_pre = CreateMultiForward("zp_user_infected_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserInfected_post = CreateMultiForward("zp_user_infected_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanized_pre = CreateMultiForward("zp_user_humanized_pre", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwUserHumanized_post = CreateMultiForward("zp_user_humanized_post", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwUserInfect_attempt = CreateMultiForward("zp_user_infect_attempt", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanize_attempt = CreateMultiForward("zp_user_humanize_attempt", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwExtraItemSelected = CreateMultiForward("zp_extra_item_selected", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwUserUnfrozen = CreateMultiForward("zp_user_unfrozen", ET_IGNORE, FP_CELL)
	g_fwUserLastZombie = CreateMultiForward("zp_user_last_zombie", ET_IGNORE, FP_CELL)
	g_fwUserLastHuman = CreateMultiForward("zp_user_last_human", ET_IGNORE, FP_CELL)
	
	// Collect random spawn points
	load_spawns()
	
	// Set a random skybox?
    /*-----BossManager(start)-----*/
    if (g_sky_enable && !Map_Boss/*Block Sky*/)
    /*-----BossManager(End)-----*/
	{
		new sky[32]
		ArrayGetString(g_sky_names, random_num(0, ArraySize(g_sky_names) - 1), sky, charsmax(sky))
		set_cvar_string("sv_skyname", sky)
	}
	
	// Disable sky lighting so it doesn't mess with our custom lighting
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
	
	// Create the HUD Sync Objects
	g_MsgSync = CreateHudSyncObj()
	g_MsgSync2 = CreateHudSyncObj()
	g_MsgSync4 = CreateHudSyncObj()
	
	// Get Max Players
	g_maxplayers = get_maxplayers()
	
	// Reserved saving slots starts on maxplayers+1
	db_slot_i = g_maxplayers+1
	
	// Check if it's a CZ server
	new mymod[6]
	get_modname(mymod, charsmax(mymod))
	if (equal(mymod, "czero")) g_czero = 1
}

public plugin_cfg()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// Get configs dir
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))
	
	// Execute config file (zombieplague.cfg)
	server_cmd("exec %s/zombieplague.cfg", cfgdir)
	
	// Prevent any more stuff from registering
	g_arrays_created = false
	
	// Save customization data
	save_customization()
	
	// Lighting task
	set_task(5.0, "lighting_effects", _, _, _, "b")
	
	// Cache CVARs after configs are loaded / call roundstart manually
	set_task(0.5, "cache_cvars")
	set_task(0.5, "event_round_start")
	set_task(0.5, "logevent_round_start")
}

/*================================================================================
 [Main Events]
=================================================================================*/

public event_show_status(id)
{
	if(!pev_valid(id)) 
		return;
		
	if(iPlayerAimInfo[id])
		return
		
	static aimid
	aimid = read_data(2)
	
	if(!pev_valid(aimid)) 
		return;	
	
	if(g_zombie[aimid] != g_zombie[id])
		return   		
		
	if(g_zombie[id])
	{
		set_hudmessage(0, 255, 255, -1.0, 0.60, 0, 0.0, 5.0, 0.2, 0.2, -1)
		ShowSyncHudMsg(id, g_MsgSync4, "%s^n[Аммо: %d]^n[Уровень: %d]^n[Здоровье: %d]", g_playername[aimid], g_ammopacks[aimid] ,g_lvl[aimid], pev(aimid, pev_health))
	}
	else
	{
		set_hudmessage(0, 255, 255, -1.0, 0.60, 0, 0.0, 5.0, 0.2, 0.2, -1)
		ShowSyncHudMsg(id, g_MsgSync4, "%s^n[Аммо: %d]^n[Уровень: %d]^n[Здоровье: %d]^n[Броня: %d]^n[%s]", g_playername[aimid], g_ammopacks[aimid] ,g_lvl[aimid], pev(aimid, pev_health), get_user_armor(aimid), CHARACTER[zp_get_character(aimid)])
	}
}
 
//Added Fixed
public event_hide_status(id)
{
	if(!pev_valid(id)) 
		return;
		
	ClearSyncHud(id, g_MsgSync4)
}

new random_color
// Event Round Start
public event_round_start()
{
	// Remove doors/lights?
	set_task(0.1, "remove_stuff")
	
	if(fnGetPlaying()>=2){
      g_day_num++
       if(g_day_num>50) g_day_num=0
	}
	
	random_color=random_num(0, 1)
	
	// New round starting
	g_newround = true
	if(g_surv_limit) g_surv_limit--
	g_endround = false
	g_survround = false
	g_nemround = false
	g_swarmround = false
	g_plagueround = false
	g_modestarted = false
	
	// Freezetime begins
	g_freezetime = true
	
    for(new id = 0; id <= get_maxplayers(); id++)
	{
        if(g_vip[id] > 0) g_vip[id]--
		Voted_Already[id]=0
		Votes_mode_CUR[1]=0
		Votes_mode_CUR[0]=0
		Votes_mode_ALL=0
	}
		
	if(fnGetPlaying() >= 2){
		if(g_day_num % 5 == 0){
			remove_task(TASK_AMBIENCESOUNDS)
			set_task(2.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS)
			
			time_vote=20
			set_task(1.0, "task_modes_voting" , 7777, _, _, "b")
			return
		}
		remove_task(TASK_MAKEZOMBIE)
		set_task(2.0 + get_pcvar_float(cvar_warmup), "make_zombie_task", TASK_MAKEZOMBIE)
		
		remove_task(TASK_WARMUP)
		g_warmup=get_pcvar_num(cvar_warmup)+1
		set_task(1.0, "Task_Warmup", TASK_WARMUP)
	}
	else
		set_task(5.0, "Task_NoPlayers", TASK_WARMUP)
}

public Task_NoPlayers(taskid)
{
  if(!Map_Boss) { 
	if(fnGetPlaying()>=2){
		// Set a new "Make Zombie Task"
		remove_task(TASK_MAKEZOMBIE)
		set_task(2.0 + get_pcvar_float(cvar_warmup), "make_zombie_task", TASK_MAKEZOMBIE)
		
		remove_task(TASK_WARMUP)
		g_warmup=get_pcvar_num(cvar_warmup)+1
		set_task(1.0, "Task_Warmup", TASK_WARMUP)
		return
	}
	
	set_task(5.0, "Task_NoPlayers", TASK_WARMUP)
   }
}

new minus_color[] = {0, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250}
public Task_Warmup(taskid,id)
{
	g_warmup--
	if(!g_warmup) return
	
	new sound[32]	
	
	if(g_nemesis_mod == 10){
		if(g_warmup ==18){
			set_dhudmessage(255, 0, 0, HUD_WARMUP_X, HUD_WARMUP_Y, 0, 6.0, 3.1, 0.0, 0.0)
			show_dhudmessage(0, "НАСТУПАЕТ ТЬМА...^nБЕГИТЕ, ГЛУПЦЫ!")
		}
		else if(g_warmup<=15){
			if(g_warmup<=10){
				format(sound, 31, "BZ_sound/countdown/%d.wav", g_warmup)
				PlaySound(sound)
			}
		
			new szSec[16]; get_ending(g_warmup, "секунд", "секунду", "секунды", szSec, charsmax(szSec));
			
			set_dhudmessage(random(100), random(255), random(255), HUD_WARMUP_X, HUD_WARMUP_Y, 0, 6.0, 1.1, 0.0, 0.0)
			show_dhudmessage(0, "Дьявол выходит на свободу...^nОсталось %d %s", g_warmup, szSec)
		}
		
		set_task(1.0, "Task_Warmup", TASK_WARMUP)
		return
	}
	
	if(g_survivor_mod == 10){
		if(g_warmup == 18){
			set_dhudmessage(0, 255, 0, HUD_WARMUP_X, HUD_WARMUP_Y, 0, 6.0, 3.1, 0.0, 0.0)
			show_dhudmessage(0, "ИДЁТ СПАСИТЕЛЬ...^nОН БУДЕТ ОДИН!")
		}
		else if(g_warmup<=15){
			if(g_warmup<=10){
				format(sound, 31, "BZ_sound/countdown/%d.wav", g_warmup)
				PlaySound(sound)
			}
		
			new szSec[16]; get_ending(g_warmup, "секунд", "секунду", "секунды", szSec, charsmax(szSec));
			
			set_dhudmessage(random(0), random(255), random(255), HUD_WARMUP_X, HUD_WARMUP_Y, 0, 6.0, 1.1, 0.0, 0.0)
			show_dhudmessage(0, "Герой через...^nОсталось %d %s", g_warmup, szSec)
		}
		
		set_task(1.0, "Task_Warmup", TASK_WARMUP)
		return
	}	
	
	if(g_warmup<=10) {
		format(sound, 31, "BZ_sound/countdown/%d.wav", g_warmup)
		PlaySound(sound)
		
		new szSec[16]; get_ending(g_warmup, "секунд", "секунду", "секунды", szSec, charsmax(szSec));
	
		if(random_color) set_dhudmessage(0, minus_color[g_warmup], 255, HUD_WARMUP_X, HUD_WARMUP_Y, 0, 0.0, 1.1, 0.0, 0.0)
		else set_dhudmessage(0, 255, minus_color[g_warmup], HUD_WARMUP_X, HUD_WARMUP_Y, 0, 0.0, 1.1, 0.0, 0.1)
		show_dhudmessage(0, "Внимание^nЗаражение через...^n%d %s", g_warmup, szSec)
	}
	else if(g_warmup==17) {
		format(sound, 31, "BZ_sound/countdown/prepare.wav")
		PlaySound(sound)
	
		set_dhudmessage(0, 255, 0, HUD_WARMUP_X, HUD_WARMUP_Y, 0, 0.0, 1.1, 0.0, 0.1)
		show_dhudmessage(0, "Приготовьтесь к бою...")
	}
	else if(g_warmup==13) {
		format(sound, 31, "BZ_sound/countdown/attacking.wav")
		PlaySound(sound)
	
		set_dhudmessage(0, 255, 255, HUD_WARMUP_X, HUD_WARMUP_Y, 0, 0.0, 1.1, 0.0, 0.1)
		show_dhudmessage(0, "Вирус атакует...")
	}	
	
	set_task(1.0, "Task_Warmup", TASK_WARMUP)
}

stock get_ending(num, const a[], const b[], const c[], output[], lenght)
{
	new num100 = num % 100, num10 = num % 10;
	if(num100 >=5 && num100 <= 20 || num10 == 0 || num10 >= 5 && num10 <= 9) format(output, lenght, "%s", a);
	else if(num10 == 1) format(output, lenght, "%s", b);
	else if(num10 >= 2 && num10 <= 4) format(output, lenght, "%s", c);
}

// Log Event Round Start
public logevent_round_start()
{
	// Freezetime ends
	g_freezetime = false
}

// Log Event Round End
public logevent_round_end()
{
	// Prevent this from getting called twice when restarting (bugfix)
	static Float:lastendtime, Float:current_time
	current_time = get_gametime()
	if (current_time - lastendtime < 0.5) return;
	lastendtime = current_time
		
	// Round ended
	g_endround = true
	
	// Stop old tasks (if any)
	remove_task(TASK_MAKEZOMBIE)
	remove_task(TASK_WARMUP)
	
	// Stop ambience sounds
	if ((g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && g_nemround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && g_survround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && g_swarmround) || (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && g_plagueround) || (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && !g_nemround && !g_survround && !g_swarmround && !g_plagueround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		ambience_sound_stop()
	}
	
	// Show HUD notice, play win sound, update team scores...
	static sound[64]
  if(!Map_Boss) { 
	if (!fnGetZombies())
	{		
		// Human team wins
		set_dhudmessage(0, 255, 255, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 5.0, 1.0, 1.0)
        show_dhudmessage(0, "ВНИМАНИЕ^nЛЮДИ СМОГЛИ УНИЧТОЖИТЬ ВИРУС^nМИР СПАСЕН...")
		g_nemesis_mod = 0
		g_survivor_mod = 0
		
		// Play win sound and increase score, unless game commencing
		ArrayGetString(sound_win_humans, random_num(0, ArraySize(sound_win_humans) - 1), sound, charsmax(sound))
		PlaySound(sound)
		if (!g_gamecommencing) g_scorehumans++
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_HUMAN);
	}
	else if (!fnGetHumans())
	{
		
		// Zombie team wins
		set_dhudmessage(255, 0, 0, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.5, 2.0, 1.0)
        show_dhudmessage(0, "ВНИМАНИЕ^nЗОМБИ ЗАХВАТИЛИ ВЕСЬ МИР^nМИР УНИЧТОЖЕН...")
		g_nemesis_mod = 0
		g_survivor_mod = 0
		
		// Play win sound and increase score, unless game commencing
		ArrayGetString(sound_win_zombies, random_num(0, ArraySize(sound_win_zombies) - 1), sound, charsmax(sound))
		PlaySound(sound)
		if (!g_gamecommencing) g_scorezombies++
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_ZOMBIE);
	}
	else
	{
		// No one wins
		set_dhudmessage(255, 255, 255, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 3.0, 2.0, 1.0)
        show_dhudmessage(0, "ВНИМАНИЕ^nЛЮДИ СМОГЛИ СКРЫТЬСЯ...^nНО ЭТО ЕЩЕ НЕ КОНЕЦ...")
		g_nemesis_mod = 0
		g_survivor_mod = 0
		
		// Play win sound
		ArrayGetString(sound_win_no_one, random_num(0, ArraySize(sound_win_no_one) - 1), sound, charsmax(sound))
		PlaySound(sound)
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_NO_ONE);
	}
	
	message_begin(MSG_BROADCAST, g_msgScreenFade)
	write_short((1<<12)*4)	// Duration
	write_short(1<<12)	// Hold time
	write_short(0x0001)	// Fade type
	write_byte (random(255))	// Red
	write_byte (random(255))	// Green
	write_byte (random(255))	// Blue
	write_byte (255)	// Alpha
	message_end()
	
	// Game commencing triggers round end
	g_gamecommencing = false
	
	// Balance the teams
	balance_teams()
  }
}

// Event Map Ended
public event_intermission()
{
	// Remove ambience sounds task
	remove_task(TASK_AMBIENCESOUNDS)
}

// BP Ammo update
public event_ammo_x(id)
{
	// Humans only
	if (g_zombie[id])
		return;
	
	// Get ammo type
	static type
	type = read_data(1)
	
	// Unknown ammo type
	if (type >= sizeof AMMOWEAPON)
		return;
	
	// Get weapon's id
	static weapon
	weapon = AMMOWEAPON[type]
	
	// Primary and secondary only
	if (MAXBPAMMO[weapon] <= 2)
		return;
	
	// Get ammo amount
	static amount
	amount = read_data(2)
	
	// Unlimited BP Ammo?
	
	if (amount < MAXBPAMMO[weapon])
	{
		static args[1]
		args[0] = weapon
		set_task(0.1, "refill_bpammo", id, args, sizeof args)
	}
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

// Entity Spawn Forward
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32], objective[32], size = ArraySize(g_objective_ents)
	pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check whether it needs to be removed
	for (new i = 0; i < size; i++)
	{
		ArrayGetString(g_objective_ents, i, objective, charsmax(objective))
		
		if (equal(classname, objective))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

// Sound Precache Forward
public fw_PrecacheSound(const sound[])
{
	// Block all those unneeeded hostage sounds
	if (equal(sound, "hostage", 7))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Ham Player Spawn Post Forward
public fw_PlayerSpawn_Post(id)
{
	// Not alive or didn't join a team yet
	if (!is_user_alive(id) || !fm_cs_get_user_team(id))
		return;
		
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		if(get_user_armor(id) < 50)
			set_user_armor(id, 50)
	
	// Player spawned
	g_isalive[id] = true
	
	g_armor_limit[id]=0
	g_cake_limit[id]=0
	g_madness_limit[id]=0
	g_unlimited[id]=0
	g_norecoil[id]=0
	g_health_limit[id]=0
	g_health_limit2[id]=0
	g_flamegr[id]=0
	g_flashgr[id]=0
	g_pipe_bomb[id]=0
	g_noknock[id]=0
	g_antidote_limit[id]=0
	
	// Remove previous tasks
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_NVISION)
	
	static weapon_ent;weapon_ent=get_pdata_cbase(id,373,5)
	
	// Spawn at a random location?
	if (get_pcvar_num(cvar_randspawn)) do_random_spawn(id)
	
    // Hide money?
    if (get_pcvar_num(cvar_removemoney)) set_task(0.4, "task_hide_money", id+TASK_SPAWN)
	
	// Respawn player if he dies because of a worldspawn kill?
    /*-----BossManager(start)-----*/
    if (get_pcvar_num(cvar_respawnworldspawnkill) && !Map_Boss /*Fix SpawnKill*/)
    /*-----BossManager(End)-----*/
		set_task(2.0, "respawn_player_check_task", id+TASK_SPAWN)
	
	// Spawn as zombie?
	if (g_respawn_as_zombie[id] && !g_newround)
	{
		reset_vars(id, 0) // reset player vars
		zombieme(id, 0, 0, 0, 0) // make him zombie right away
		
		set_pev(id, pev_takedamage, DAMAGE_NO)
		
		fm_set_rendering(id, kRenderFxGlowShell, 255, 123, 0, kRenderNormal, 15)
		
		set_task(2.5, "remove_spawn_protection", id+TASK_SPAWN)
		
		g_nodamage[id] = true

		return;
	}
	
	if(g_survivor[id]||g_zombie[id]){
		fm_strip_user_weapons(id)
		fm_give_item(id, "weapon_knife")
	}
	
	// Reset player vars
	reset_vars(id, 0)
	g_buytime[id] = get_gametime()
	
	if(pev_valid(weapon_ent)) ExecuteHamB(Ham_Item_Deploy,weapon_ent)	
	
	if (!g_newround)
	{		
		// Make temporarily invisible
		set_pev(id, pev_takedamage, DAMAGE_NO)
		
		fm_set_rendering(id, kRenderFxGlowShell, 255, 123, 0, kRenderNormal, 15)
		
		// Set task to remove it
		set_task(2.5, "remove_spawn_protection", id+TASK_SPAWN)
		
		g_nodamage[id] = true
	}
	
	// Show custom buy menu?
	if (!WPN_AUTO_ON) set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
	
    /*-----BossManager(start)-----*/	
	if(!g_zombie[id]) {
    fm_set_user_health(id, get_pcvar_num(cvar_humanhp) + 35*g_pts[id][0])
	if(g_pts[id][4]) set_pev(id, pev_gravity, 1.0 - g_pts[id][4]*0.04)
	else set_pev(id, pev_gravity, 1.0)
	if(g_pts[id][1]) set_pev(id, pev_armorvalue, pev(id, pev_armorvalue)+float(5*g_pts[id][1]))
	  }
    /*-----BossManager(start)-----*/
	
	// Set human maxspeed
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	
	// Switch to CT if spawning mid-round
	if (!g_newround && fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
 	  // Get current model for comparing it with the current one
	  fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
	  // Set the right model, after checking that we don't already have it
	  size = ArraySize(model_admin_human)
			
	  for (i = 0; i < size; i++)
	  {
		  ArrayGetString(model_admin_human, i, tempmodel, charsmax(tempmodel))
		  if (equal(currentmodel, tempmodel)) already_has_model = true
	  }
					
	   if (!already_has_model)
	   {
		   iRand = random_num(0, size - 1)
		   ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
		   if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
		   set_pev(id, pev_body, zp_get_character(id))
	   }
		
	if (!already_has_model)
	{
		if (g_newround)
			set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
		else
			fm_user_model_update(id+TASK_MODEL)
	}
	fm_set_rendering(id)
	
	// Turn off his flashlight (prevents double flashlight bug/exploit)
	turn_off_flashlight(id)
	
	// Replace weapon models (bugfix)
	if (pev_valid(weapon_ent)) replace_weapon_models(id, cs_get_weapon_id(weapon_ent))
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	// Player killed
	g_isalive[victim] = false

	g_nodamage[victim] = false
	
	g_Timer[victim]=4
	
	// Turn off custom flashlight when killed
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[victim] = false
		g_flashbattery[victim] = 100
		
		// Remove previous tasks
		remove_task(victim+TASK_CHARGE)
		remove_task(victim+TASK_FLASH)
	}
	
	// Stop bleeding/burning/aura when killed
	if (g_zombie[victim])
	{
		remove_task(victim+TASK_BLOOD)
		remove_task(victim+TASK_AURA)
		remove_task(victim+TASK_BURN)
	}
	
	// Nemesis explodes!
	if (g_nemesis[victim])
		SetHamParamInteger(3, 2)
		
	if(g_survivor[victim]){
		fm_set_rendering(victim,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,0)
		
		new origin[3]
		get_user_origin(victim, origin)
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	        write_byte(108); // TE_BREAKMODEL 
	        write_coord(origin[0]); // x 
	        write_coord(origin[1]); // y 
	        write_coord(origin[2] + 20); // z 
	        write_coord(16); // size x 
	        write_coord(16); // size y 
	        write_coord(16); // size z 
	        write_coord(random_num(-50,50)); // velocity x 
	        write_coord(random_num(-50,50)); // velocity y 
	        write_coord(25); // velocity z 
	        write_byte(25); // random velocity 
	        write_short(g_metalgibs); // model index that you want to break 
	        write_byte(50); // count 
	        write_byte(35); // life 
	        write_byte(0x02); // flags: BREAK_GLASS 
	        message_end();  
	}
	
	// Determine whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	// Killed by a non-player entity or self killed
	if (selfkill) return;
	
	// Ignore Nemesis/Survivor Frags?
	if ((g_nemesis[attacker] && get_pcvar_num(cvar_nemignorefrags)) || (g_survivor[attacker] && get_pcvar_num(cvar_survignorefrags)))
		RemoveFrags(attacker, victim)
	
	// Zombie/nemesis killed human, reward ammo packs
    if (g_zombie[attacker] && (!g_nemesis[attacker] || !get_pcvar_num(cvar_nemignoreammo)))
        g_ammopacks[attacker] += get_pcvar_num(cvar_ammoinfect)
	
	// Human killed zombie, add up the extra frags for kill
	if (!g_zombie[attacker] && get_pcvar_num(cvar_fragskill) > 1)
		UpdateFrags(attacker, victim, get_pcvar_num(cvar_fragskill) - 1, 0, 0)
	
	// Zombie killed human, add up the extra frags for kill
	if (g_zombie[attacker] && get_pcvar_num(cvar_fragsinfect) > 1)
		UpdateFrags(attacker, victim, get_pcvar_num(cvar_fragsinfect) - 1, 0, 0)
}

// Ham Player Killed Post Forward
public fw_PlayerKilled_Post(victim, attacker, shouldgib, id)
{
	// Last Zombie Check
	fnCheckLastZombie()
	
	// Determine whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	static headshot
	if(!selfkill){
		headshot=get_pdata_int(victim, 75, 5) == HIT_HEAD?true:false
	}
	
	if(!selfkill&&!g_zombie[attacker]) {
		if(headshot) client_print(attacker, print_center, "[В голову!]")
		else client_print(attacker, print_center, "[Зомби убит]")
	}
	
	if(!selfkill&&!g_survivor[attacker]&&!g_nemesis[attacker]/*&&!g_zombie[attacker]*/){
		new sound[64]
		new name[32], name1[32], name2[32]
		
		if(fnGetPlaying()>=2){	
            if(g_lvl[attacker] == LEVEL_MAX && g_exp[attacker] == LEVEL_EXP_COUNT*g_lvl[attacker]) return				
			if(g_survivor[victim]) {
			    get_user_name(attacker, name1, 31)				
		        zp_colored_print(0, "^x04[ZP]^x01 Игрок ^x04 %s ^x01убил ^x04Героя ^x01(Приз: ^x04 10 опыта и 50 аммо^x01)", name1)
			    g_exp[attacker]+=10
				g_ammopacks[attacker] += 50
			}
			else if(g_nemesis[victim]) {
			    get_user_name(attacker, name2, 31)				
		        zp_colored_print(0, "^x04[ZP]^x01 Игрок ^x04 %s ^x01убил ^x04Дьвола ^x01(Приз: ^x04 10 опыта и 50 аммо^x01)", name2)
			    g_exp[attacker]+=10
				g_ammopacks[attacker] += 50
			}else {
			  if(!g_zombie[attacker]) {
				if(!headshot) g_exp[attacker]++
				else g_exp[attacker]+=2
				g_iToken[attacker]++
			  }
			}
			if(g_exp[attacker]>=LEVEL_EXP_COUNT*g_lvl[attacker]){
                g_lvl[attacker]++
	            g_exp[attacker]=0
				g_ammopacks[attacker] += 50
				
                get_user_name(attacker, name, 31)				
				zp_colored_print(0, "^x04[ZP]^x01 Игрок ^x04%s ^x01достиг ^x04%i ^x01уровня и получает ^x04 50 ^x01аммо!", name, g_lvl[attacker])
				
				set_dhudmessage(255, 255, 0, -1.0, 0.78, 0, 6.0, 1.0, 0.0, 1.5)
				show_dhudmessage(attacker, "+1 Уровень")
			}
			else{
				set_dhudmessage(0, 255, 0, -1.0, 0.78, 0, 6.0, 1.0, 0.0, 1.5)
				if(g_survivor[victim]||g_nemesis[victim]) show_dhudmessage(attacker, "+10 Опыта")
				else {
				   if(!g_zombie[attacker]) {
					if(!headshot) show_dhudmessage(attacker, "+1 Опыт")
					else show_dhudmessage(attacker, "+2 Опыта")
					}
				}
			}
		}
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, attacker)
		write_short(UNIT_SECOND)
		write_short(0)
		write_short(FFADE_IN)
		if(g_zombie[id]){
			write_byte(255)
			write_byte(130)
			write_byte(150)
		}else{
			write_byte(171)
			write_byte(130)
			write_byte(255)
		}
		write_byte(200)
		message_end()
		
		if(headshot) {
			ArrayGetString(sound_headshot, 0, sound, charsmax(sound))
			PlaySoundId(sound, attacker)
		}
	}	
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
    // Non-player damage or self damage
    if (victim == attacker || !is_user_valid_connected(attacker))
        return HAM_IGNORED;
    
    // New round starting or round ended
    if (g_newround || g_endround)
        return HAM_SUPERCEDE;
    
    // Victim shouldn't take damage or victim is frozen
    if (g_nodamage[victim] || g_frozen[victim])
        return HAM_SUPERCEDE;
    
    // Prevent friendly fire
    if (g_zombie[attacker] == g_zombie[victim])
        return HAM_SUPERCEDE;
    
    // Attacker is human...
    if (!g_zombie[attacker])
    {
		if(g_pts[attacker][3]){
			SetHamParamFloat(4, damage+((damage/100.0)*g_pts[attacker][3]))
		}
		
		if (get_user_weapon(attacker)==CSW_KNIFE&&inflictor == attacker)
		{
				switch(g_knife[attacker])
				{
					case 0:{
						SetHamParamFloat(4, damage*5.0)
					}
					case 3:{
						SetHamParamFloat(4, damage*4.0)
					}
					case 4:{
						SetHamParamFloat(4, damage*4.0)
					}
					default: SetHamParamFloat(4, damage*3.0)
				}
				
				if(g_knife[attacker]==5)
				{
					set_fire(victim)
				}
			    if(g_knife[attacker]==6) {
				 if(g_knife_abil[attacker]<=get_gametime())
				 {
					set_freeze(victim)
					g_knife_abil[attacker]=get_gametime()+30.0
                 }			
			}
		} 		
        
        // Reward ammo packs
        if (!g_survivor[attacker] || !get_pcvar_num(cvar_survignoreammo))
        {
            // Store damage dealt
            g_damagedealt_human[attacker] += floatround(damage)
            
            // Reward ammo packs for every [ammo damage] dealt
            while (g_damagedealt_human[attacker] > get_pcvar_num(cvar_ammodamage_human))
            {
                g_ammopacks[attacker]++
                g_damagedealt_human[attacker] -= get_pcvar_num(cvar_ammodamage_human)
            }
        }
			
		new Float:zm_hp
		pev(victim, pev_health, zm_hp)
		client_print(attacker, print_center, "Урон: %d / HP: %d", floatround(damage), floatround(zm_hp-damage))
        
        return HAM_IGNORED;
    }
    
    // Attacker is zombie...
	
	if (g_zombie[attacker])
	{
		new Float:hum_hp
		pev(victim, pev_health, hum_hp)
		client_print(attacker, print_center, "HP: %d", floatround(hum_hp-damage))
    }
    
    // Prevent infection/damage by HE grenade (bugfix)
    if (damage_type & DMG_HEGRENADE)
        return HAM_SUPERCEDE;
    
    // Nemesis?
    if (g_nemesis[attacker])
    {
        // Ignore nemesis damage override if damage comes from a 3rd party entity
        // (to prevent this from affecting a sub-plugin's rockets e.g.)
        if (inflictor == attacker)
        {
            // Set nemesis damage
            SetHamParamFloat(4, damage*10.0)
        }
        
        return HAM_IGNORED;
    }
    
    // Last human or not an infection round
    if (g_survround || g_nemround || g_swarmround || g_plagueround || fnGetHumans() == 1)
        return HAM_IGNORED; // human is killed
    
    // Does human armor need to be reduced before infecting?
    if (get_pcvar_num(cvar_humanarmor))
    {
        // Get victim armor
        static Float:armor
        pev(victim, pev_armorvalue, armor)
        
        // If he has some, block the infection and reduce armor instead
        if (armor > 0.0)
        {
            emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
            if (armor - damage > 0.0) {
                set_pev(victim, pev_armorvalue, armor - damage)
                client_print(attacker, print_center, "Броня: %d", floatround(armor-damage))
            }
            else{
                cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
                client_print(attacker, print_center, "Брони нет", floatround(armor-damage))
            }
            return HAM_SUPERCEDE;
        }
    }
	
	// Infection allowed
	zombieme(victim, attacker, 0, 0, 1) // turn into zombie
	return HAM_SUPERCEDE;
}

stock create_velocity_vector(victim,attacker,Float:velocity[3])
{
        if(!is_user_alive(attacker))
                return 0;

        new Float:vicorigin[3];
        new Float:attorigin[3];
        pev(victim, pev_origin , vicorigin);
        pev(attacker, pev_origin , attorigin);

        new Float:origin2[3]
        origin2[0] = vicorigin[0] - attorigin[0];
        origin2[1] = vicorigin[1] - attorigin[1];

        new Float:largestnum = 0.0;

        if(floatabs(origin2[0])>largestnum) largestnum = floatabs(origin2[0]);
        if(floatabs(origin2[1])>largestnum) largestnum = floatabs(origin2[1]);

        origin2[0] /= largestnum;
        origin2[1] /= largestnum;
        
	if(g_survivor[attacker]){
		velocity[0] = ( origin2[0] * 40000 ) / floatround(get_distance_f(vicorigin, attorigin));
		velocity[1] = ( origin2[1] * 40000 ) / floatround(get_distance_f(vicorigin, attorigin));
	}
	else{
	        switch(g_knife[attacker]){
	        	case 1:{
	        		velocity[0] = ( origin2[0] * 30000 ) / floatround(get_distance_f(vicorigin, attorigin));
				velocity[1] = ( origin2[1] * 30000 ) / floatround(get_distance_f(vicorigin, attorigin));
	        	}
	        	case 5:{
	        		velocity[0] = ( origin2[0] * 30000 ) / floatround(get_distance_f(vicorigin, attorigin));
				velocity[1] = ( origin2[1] * 30000 ) / floatround(get_distance_f(vicorigin, attorigin));
	        	}
	        	default:{
	        		velocity[0] = ( origin2[0] * 25000 ) / floatround(get_distance_f(vicorigin, attorigin));
				velocity[1] = ( origin2[1] * 25000 ) / floatround(get_distance_f(vicorigin, attorigin));
	        	}
	        }
        }
        
 
        if(velocity[0] <= 20.0 || velocity[1] <= 20.0)
        velocity[2] = random_float(200.0 , 275.0);

        return 1;
}

// Ham Take Damage Post Forward
public fw_TakeDamage_Post(victim)
{
    // --- Check if victim should be Pain Shock Free ---
    
    // Check if proper CVARs are enabled
    if (g_zombie[victim])
    {
        if (g_nemesis[victim])
        {
            if (!get_pcvar_num(cvar_nempainfree)) return;
        }
        else
        {
            switch (get_pcvar_num(cvar_zombiepainfree))
            {
                case 0: return;
                case 2: if (!g_lastzombie[victim]) return;
            }
        }
    }
    else
    {
        if (g_survivor[victim])
        {
            if (!get_pcvar_num(cvar_survpainfree)) return;
        }
        else return;
    }
    
    // Set pain shock free offset
    set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX)
}

// Ham Trace Attack Forward
public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	// New round starting or round ended
	if (g_newround || g_endround)
		return HAM_SUPERCEDE;
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim] || g_frozen[victim])
		return HAM_SUPERCEDE;
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
		return HAM_SUPERCEDE;
		
	if(g_survivor[victim]){
		new Float:vecEnd[3]
		get_tr2(tracehandle,TR_vecEndPos,vecEnd)
	
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_SPARKS)
		engfunc(EngFunc_WriteCoord,vecEnd[0])
		engfunc(EngFunc_WriteCoord,vecEnd[1])
		engfunc(EngFunc_WriteCoord,vecEnd[2])
		message_end()
		
		emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Victim isn't a zombie or not bullet damage, nothing else to do here
	if (!g_zombie[victim] || !(damage_type & DMG_BULLET))
		return HAM_IGNORED;
	
	// If zombie hitzones are enabled, check whether we hit an allowed one
	if (get_pcvar_num(cvar_hitzones) && !g_nemesis[victim] && !(get_pcvar_num(cvar_hitzones) & (1<<get_tr2(tracehandle, TR_iHitgroup))))
		return HAM_SUPERCEDE;
	
	
	// Nemesis knockback disabled, nothing else to do here
	if (g_nemesis[victim]||g_noknock[victim])
		return HAM_IGNORED;
	
	if(get_user_weapon(attacker)==CSW_KNIFE)	{
		new Float:vec[3];
		new Float:oldvelo[3];
		pev(victim, pev_velocity, oldvelo);
		oldvelo[2]+=10.0
		set_pev(victim, pev_velocity, oldvelo);
		create_velocity_vector(victim , attacker , vec);
		vec[0] += oldvelo[0]
		vec[1] += oldvelo[1]
		set_pev(victim, pev_velocity, vec)
		
		return HAM_IGNORED;
	}
		                        
		                      
	
	// Get whether the victim is in a crouch state
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	
	// Zombie knockback when ducking disabled
	if (ducking && get_pcvar_float(cvar_knockbackducking) == 0.0)
		return HAM_IGNORED;
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > get_pcvar_num(cvar_knockbackdist))
		return HAM_IGNORED;
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	// Use damage on knockback calculation
	if (get_pcvar_num(cvar_knockbackdamage))
		xs_vec_mul_scalar(direction, damage, direction)
	
	// Use weapon power on knockback calculation
	if (get_pcvar_num(cvar_knockbackpower) && kb_weapon_power[g_currentweapon[attacker]] > 0.0)
		xs_vec_mul_scalar(direction, kb_weapon_power[g_currentweapon[attacker]], direction)
	
	// Apply ducking knockback multiplier
	if (ducking)
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_knockbackducking), direction)
	
	// Apply zombie class/nemesis knockback multiplier
	if (g_nemesis[victim])
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_nemknockback), direction)
	else
		xs_vec_mul_scalar(direction, g_zombie_knockback[victim], direction)
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	// Should knockback also affect vertical velocity?
	if (!get_pcvar_num(cvar_knockbackzvel))
		direction[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)
	
	return HAM_IGNORED;
}

// Ham Reset MaxSpeed Post Forward
public fw_ResetMaxSpeed_Post(id)
{
	// Freezetime active or player not alive
	if (g_freezetime || !g_isalive[id])
		return;
	
	set_player_maxspeed(id)
}

// Ham Use Stationary Gun Forward
public fw_UseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zombie[caller])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Use Stationary Gun Post Forward
public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	// Someone stopped using a stationary gun
	if (use_type == USE_STOPPED && is_user_valid_connected(caller))
		replace_weapon_models(caller, g_currentweapon[caller]) // replace weapon models (bugfix)
}

// Ham Use Pushable Forward
public fw_UsePushable()
{
	// Prevent speed bug with pushables?
	if (get_pcvar_num(cvar_blockpushables))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Touch Forward
public fw_TouchWeapon(weapon, id)
{
	// Not a player
	if (!is_user_valid_connected(id))
		return HAM_IGNORED;
	
	// Dont pickup weapons if zombie or survivor (+PODBot MM fix)
	if (g_zombie[id] || (g_survivor[id] && !g_isbot[id]))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Pickup Forward
public fw_AddPlayerItem(id, weapon_ent)
{
	// HACK: Retrieve our custom extra ammo from the weapon
	static extra_ammo
	extra_ammo = pev(weapon_ent, PEV_ADDITIONAL_AMMO)
	
	// If present
	if (extra_ammo)
	{
		// Get weapon's id
		static weaponid
		weaponid = cs_get_weapon_id(weapon_ent)
		
		// Add to player's bpammo
		ExecuteHamB(Ham_GiveAmmo, id, extra_ammo, AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
		set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, 0)
	}
}

public fw_Attack(weapon_entity)
{
	static id; id = get_pdata_cbase(weapon_entity, 41, 4)
	
	if(!g_firstzombie[id]||!g_zombie[id]) return
}

public fw_Weapon_PrimaryAttack_Post(weapon_entity)
{
	static id; id = get_pdata_cbase(weapon_entity, 41, 4)
	if(!g_norecoil[id]) return
	set_pev(id, pev_punchangle, {0.0, 0.0, 0.0})
}

// Ham Weapon Deploy Forward
public fw_Item_Deploy_Post(weapon_ent)
{
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Valid owner?
	if (!pev_valid(owner))
		return;
	
	// Get weapon's id
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	// Store current weapon's id for reference
	g_currentweapon[owner] = weaponid
	
	// Replace weapon models with custom ones
	replace_weapon_models(owner, weaponid)
	
	// Zombie not holding an allowed weapon for some reason
	if (g_zombie[owner] && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
	{
		// Switch to knife
		g_currentweapon[owner] = CSW_KNIFE
		engclient_cmd(owner, "weapon_knife")
	}
}

// WeaponMod bugfix
//forward wpn_gi_reset_weapon(id);
public wpn_gi_reset_weapon(id)
{
	// Replace knife model
	replace_weapon_models(id, CSW_KNIFE)
}

// Client joins the game
public client_putinserver(id)
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// Player joined
	g_isconnected[id] = true
	g_fMainInformerColor[id] = {255, 255, 0};
	g_fMainInformerPosX[id] = 0.02;
	g_fMainInformerPosY[id] = 0.16;
	g_Timer[id]=4
	
	// Cache player's name
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	// Initialize player vars
	reset_vars(id, 1)
	
	// Load player stats?
	if (get_pcvar_num(cvar_statssave)) load_stats(id)
	
	// Set some tasks for humans only
	if (!is_user_bot(id))
	{
		// Set the custom HUD display task if enabled
		if (get_pcvar_num(cvar_huddisplay))
			set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")
		
		// Disable minmodels for clients to see zombies properly
		set_task(5.0, "disable_minmodels", id)
		
		if(get_user_flags(id) & ADMIN_SLAY) formatex(g_szPrivilege[id], 31, "Создатель")
		else if(get_user_flags(id) & ADMIN_LEVEL_D) formatex(g_szPrivilege[id], 31, "BOSS")
		else if(get_user_flags(id) & ADMIN_BAN) formatex(g_szPrivilege[id], 31, "ADMIN")
		else if(get_user_flags(id) & ADMIN_LEVEL_G) formatex(g_szPrivilege[id], 31, "PREMIUM")
		else if(get_user_flags(id) & ADMIN_LEVEL_A) formatex(g_szPrivilege[id], 31, "VIP")
		else formatex(g_szPrivilege[id], 31, "Игрок")
	}
	else
	{
		// Set bot flag
		g_isbot[id] = true
		
		// CZ bots seem to use a different "classtype" for player entities
		// (or something like that) which needs to be hooked separately
		if (!g_hamczbots && cvar_botquota)
		{
			// Set a task to let the private data initialize
			set_task(0.1, "register_ham_czbots", id)
		}
	}
}

// Client leaving
public fw_ClientDisconnect(id)
{
	// Check that we still have both humans and zombies to keep the round going
	if (g_isalive[id]) check_round(id)
	
	// Temporarily save player stats?
	if (get_pcvar_num(cvar_statssave)) save_stats(id)
	
	// Remove previous tasks
	remove_task(id+TASK_TEAM)
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_NVISION)
	remove_task(id+TASK_SHOWHUD)
	
	if (g_handle_models_on_separate_ent)
	{
		// Remove custom model entities
		fm_remove_model_ents(id)
	}
	
	// Player left, clear cached flags
	g_isconnected[id] = false
	g_isbot[id] = false
	g_isalive[id] = false
	
	g_knife[id]=0
}

// Client left
public fw_ClientDisconnect_Post()
{
	// Last Zombie Check
	fnCheckLastZombie()
}

// Client Kill Forward
public fw_ClientKill()
{
	return FMRES_SUPERCEDE;
}

// Emit Sound Forward
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	// Replace these next sounds for zombies only
	if (!is_user_valid_connected(id))
		return FMRES_IGNORED;
	
	static sound[64]
		
	if(!g_zombie[id])
	{
		if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
		{
			
			if (sample[14] == 'd') 
			{
				formatex(sound, charsmax(sound), "%s", g_draw_sound[g_knife[id]])
			}
			else if (sample[14] == 'h')
			{
				if (sample[17] == 'w') 
				{
					formatex(sound, charsmax(sound), "%s", g_hit_wall_sound[g_knife[id]])
				}
				else 
				{
					formatex(sound, charsmax(sound), "%s", g_hit_normal_sound[g_knife[id]])
				}
			}
			else
			{
				if (sample[15] == 'l') 
				{
					 formatex(sound, charsmax(sound), "%s", g_hit_miss_sound[g_knife[id]])
				}
				else 
				{
					formatex(sound, charsmax(sound), "%s", g_hit_stab_sound[g_knife[id]])
					
					
				}
			}
			
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE
		}
		return FMRES_IGNORED;
	}
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if (g_nemesis[id])
			ArrayGetString(nemesis_pain, random_num(0, ArraySize(nemesis_pain) - 1), sound, charsmax(sound))
		else {
			static pointers[10], end
			ArrayGetArray(pointer_class_sound_pain, g_zombieclass[id], pointers)
	
			for (new i; i < 10; i++)
			{
				if (pointers[i] != -1)
					end = i
			}
	
			ArrayGetString(class_sound_pain, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
		}
		
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie attacks with knife
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			if(g_nemesis[id])
				ArrayGetString(nemesis_miss_slash, random_num(0, ArraySize(nemesis_miss_slash) - 1), sound, charsmax(sound))
			else {
				static pointers[10], end
				ArrayGetArray(pointer_class_sound_miss_slash, g_zombieclass[id], pointers)
	
				for (new i; i < 10; i++)
				{
					if (pointers[i] != -1)
						end = i
				}
			
				ArrayGetString(class_sound_miss_slash, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
			}
			
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				if(g_nemesis[id])
					ArrayGetString(nemesis_miss_wall, random_num(0, ArraySize(nemesis_miss_wall) - 1), sound, charsmax(sound))
				else {
					static pointers[10], end
					ArrayGetArray(pointer_class_sound_miss_wall, g_zombieclass[id], pointers)
			
					for (new i; i < 10; i++)
					{
						if (pointers[i] != -1)
							end = i
					}
			
					ArrayGetString(class_sound_miss_wall, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
				}
				
				emit_sound(id, channel, sound, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
			else
			{
				if(g_nemesis[id])
					ArrayGetString(nemesis_hit_normal, random_num(0, ArraySize(nemesis_hit_normal) - 1), sound, charsmax(sound))
				else {				
					static pointers[10], end
					ArrayGetArray(pointer_class_sound_hit_normal, g_zombieclass[id], pointers)
			
					for (new i; i < 10; i++)
					{
						if (pointers[i] != -1)
							end = i
					}
			
					ArrayGetString(class_sound_hit_normal, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
				}
				
				emit_sound(id, channel, sound, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			if(g_nemesis[id])
				ArrayGetString(nemesis_hit_stab, random_num(0, ArraySize(nemesis_hit_stab) - 1), sound, charsmax(sound))
			else {	
				static pointers[10], end
				ArrayGetArray(pointer_class_sound_hit_stab, g_zombieclass[id], pointers)
			
				for (new i; i < 10; i++)
				{
					if (pointers[i] != -1)
						end = i
				}
			
				ArrayGetString(class_sound_hit_stab, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
			}
			
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		if(g_nemesis[id])
			ArrayGetString(nemesis_die, random_num(0, ArraySize(nemesis_die) - 1), sound, charsmax(sound))
		else {	
			static pointers[10], end
			ArrayGetArray(pointer_class_sound_die, g_zombieclass[id], pointers)
			
			for (new i; i < 10; i++)
			{
				if (pointers[i] != -1)
					end = i
			}
			
			ArrayGetString(class_sound_die, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
		}
		
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

// Forward Set ClientKey Value -prevent CS from changing player models-
public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{
	// Block CS model changes
	if (key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l')
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Forward Client User Info Changed -prevent players from changing models-
public fw_ClientUserInfoChanged(id)
{
	// Cache player's name
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	if (!g_handle_models_on_separate_ent)
	{
		// Get current model
		static currentmodel[32]
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// If they're different, set model again
		if (!equal(currentmodel, g_playermodel[id]) && !task_exists(id+TASK_MODEL))
			fm_cs_set_user_model(id+TASK_MODEL)
	}
}

// Forward Set Model
public fw_SetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
		return FMRES_IGNORED
	
	// Remove weapons?
	if (get_pcvar_float(cvar_removedropped) > 0.0)
	{
		// Get entity's classname
		static classname[10]
		pev(entity, pev_classname, classname, charsmax(classname))
		
		// Check if it's a weapon box
		if (equal(classname, "weaponbox"))
		{
			// They get automatically removed when thinking
			set_pev(entity, pev_nextthink, get_gametime() + get_pcvar_float(cvar_removedropped))
			return FMRES_IGNORED
		}
	}
	
	// Narrow down our matches a bit
	if (model[7] != 'w' || model[8] != '_')
		return FMRES_IGNORED
	
	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Grenade not yet thrown
	if (dmgtime == 0.0)
		return FMRES_IGNORED
	
	// Get whether grenade's owner is a zombie
	if (g_zombie[pev(entity, pev_owner)])
	{
		if (model[9] == 'h' && model[10] == 'e') // Infection Bomb
		{			
			fm_set_rendering(entity, kRenderFxGlowShell, 255, 165, 0, kRenderNormal, 16);
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(255) // r
			write_byte(165) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_JUMP)
			
			engfunc(EngFunc_SetModel, entity, "models/BZ_models/w_zombibomb.mdl")
			
			return FMRES_SUPERCEDE
		}
		else if (model[9] == 's' && model[10] == 'm')
		{
			fm_set_rendering(entity, kRenderFxGlowShell, 0, 200, 200, kRenderNormal, 16);
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(0) // r
			write_byte(200) // g
			write_byte(200) // b
			write_byte(200) // brightness
			message_end()
			
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_SHOCK)
			
			engfunc(EngFunc_SetModel, entity, "models/BZ_models/w_zombibomb.mdl")
			
			return FMRES_SUPERCEDE
		}
	}
	else if (model[9] == 'h' && model[10] == 'e')
	{
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_trailSpr) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(255) // r
		write_byte(64) // g
		write_byte(64) // b
		write_byte(250) // brightness
		message_end()
		
		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)
		
		engfunc(EngFunc_SetModel, entity, model_wgrenade_fire)
		
		return FMRES_SUPERCEDE
	}
	else if (model[9] == 'f' && model[10] == 'l')
	{
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_trailSpr) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(100) // r
		write_byte(149) // g
		write_byte(237) // b
		write_byte(250) // brightness
		message_end()
		
		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FROST)
		
		engfunc(EngFunc_SetModel, entity, model_wgrenade_frost)
		
		return FMRES_SUPERCEDE
	}
	else if (model[9] == 's' && model[10] == 'm' && get_pcvar_num(cvar_flaregrenades)) // Flare
	{
		if(g_pipe_bomb[pev(entity, pev_owner)]){
			g_pipe_bomb[pev(entity, pev_owner)]--
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(200) // r
			write_byte(50) // g
			write_byte(25) // b
			write_byte(170) // brightness
			message_end()
			
			// Set grenade type on the thrown grenade entity
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_PIPE)
			
			set_pev(entity, pev_dmgtime, get_gametime()+5.0)
			set_pev(entity, pev_nextthink, get_gametime()+1.0)
			
			engfunc(EngFunc_SetModel, entity, model_wgrenade_pipe)
			
			return FMRES_SUPERCEDE
		}
		
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_trailSpr) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(20) // r
		write_byte(170) // g
		write_byte(250) // b
		write_byte(170) // brightness
		message_end()
		
		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_ANTIDOTE)
		
		engfunc(EngFunc_SetModel, entity, model_wgrenade_antidote)
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public hook(entity) // Magnet func. Hooks zombies to nade
{
	//Bugfix
	if (!pev_valid(entity))
	{
		return;
	}
	
	static Float:originF[3], Float:radius, victim = -1;
	radius = NADE_EXPLOSION_RADIUS
	pev(entity, pev_origin, originF);
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, radius)) != 0)
	{
		if (!is_user_valid_alive(victim) || !g_zombie[victim]||g_nodamage[victim]|| g_nemesis[victim])
			continue;

		new Float:fl_Velocity[3];
		new vicOrigin[3], originN[3];

		get_user_origin(victim, vicOrigin);
		originN[0] = floatround(originF[0]);
		originN[1] = floatround(originF[1]);
		originN[2] = floatround(originF[2]);
		
		new distance = get_distance(originN, vicOrigin);

		if (distance > 1)
		{
			new Float:fl_Time = distance / 90.0

			fl_Velocity[0] = (originN[0] - vicOrigin[0]) / fl_Time;
			fl_Velocity[1] = (originN[1] - vicOrigin[1]) / fl_Time;
			fl_Velocity[2] = (originN[2] - vicOrigin[2]) / fl_Time;
		} else
		{
			fl_Velocity[0] = 0.0
			fl_Velocity[1] = 0.0
			fl_Velocity[2] = 0.0
		}

		entity_set_vector(victim, EV_VEC_velocity, fl_Velocity);
		

		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, victim)
		write_short(1<<14) // amplitude
		write_short(1<<14) // duration
		write_short(1<<14) // frequency
		message_end()
	}
}

pipe_explo(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	new r, g, b
	
	// Collisions
	static victim
	victim = -1
	
	static attacker
	attacker=pev(ent, pev_owner)
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim] || g_nemesis[victim] || g_firstzombie[victim])
			continue;
			
		//Молния
		
		pev(victim, pev_origin, originF)
		
		switch(random_num(0,3))
		{
					case 0:
					{
						r=124
						g=252
						b=0
					}
					case 1:
					{
						r=153
						g=50
						b=204
					}
					case 2:
					{
						r=0
						g=229
						b=238
					}
					case 3:
					{
						r=131
						g=111
						b=255
					}
		}
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
		write_byte(0)		//TE_BEAMPOINTS
		engfunc(EngFunc_WriteCoord,originF[0])	// start position
		engfunc(EngFunc_WriteCoord,originF[1])
		engfunc(EngFunc_WriteCoord,originF[2]+32)
		engfunc(EngFunc_WriteCoord,originF[0])	// end position 
		engfunc(EngFunc_WriteCoord,originF[1]+random_num(-10, 10))
		engfunc(EngFunc_WriteCoord,originF[2]+256)
		write_short(SprLighting)
		write_byte(1)	// framestart
		write_byte(5)	// framerate
		write_byte(10)	// life in 0.1's
		write_byte(60)	// width
		write_byte(30)	// noise
		write_byte(r)
		write_byte(g)
		write_byte(b)
		write_byte(255)	// brightness
		write_byte(0)	// speed
		message_end()
		
		
		ExecuteHamB(Ham_Killed, victim, attacker, 0)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Ham Grenade Think Forward
public fw_ThinkGrenade(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return HAM_IGNORED;
	
	// Get damage time of grenade
	static Float:dmgtime, Float:current_time
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime()
	
	if(pev(entity, PEV_NADE_TYPE)==NADE_TYPE_PIPE)
	{
		if (dmgtime < current_time){
			emit_sound(entity, CHAN_ITEM, "weapons/lasthope_attack.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			pipe_explo(entity)
			return HAM_SUPERCEDE;
		}
		
		set_pev(entity, pev_nextthink, get_gametime()+0.1)
		hook(entity)
		
		if(dmgtime-current_time<1.0){
			create_pipe_blast2(entity)
			
		}
		else if(dmgtime-current_time<2.0){
			if(!pev(entity,pev_flSwimTime)){
				create_pipe_blast2(entity)
				set_pev(entity, pev_flSwimTime, 2)
				emit_sound(entity, CHAN_ITEM, "weapons/lasthope_ready.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			else set_pev(entity, pev_flSwimTime, pev(entity, pev_flSwimTime)-1)
		}
		else if(dmgtime-current_time<2.5){
			if(!pev(entity,pev_flSwimTime)){
				create_pipe_blast2(entity)
				set_pev(entity, pev_flSwimTime, 5)
			}
			else set_pev(entity, pev_flSwimTime, pev(entity, pev_flSwimTime)-1)
		}
		else {
			if(!pev(entity,pev_flSwimTime)){
				create_pipe_blast(entity)
				set_pev(entity, pev_flSwimTime, 5)
			}
			else set_pev(entity, pev_flSwimTime, pev(entity, pev_flSwimTime)-1)
		}
		
		
		
		return HAM_SUPERCEDE;
	}	
	
	// Check if it's time to go off
	if (dmgtime > current_time)
		return HAM_IGNORED;
	
	// Check if it's one of our custom nades
	switch (pev(entity, PEV_NADE_TYPE))
	{
		case NADE_TYPE_SHOCK: // Infection Bomb
		{
			shock_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_JUMP: // Infection Bomb
		{
			jump_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_NAPALM: // Napalm Grenade
		{
			fire_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FROST: // Frost Grenade
		{
			frost_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_ANTIDOTE: // Flare
		{
			antidote_explode(entity)
			return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}

// Forward CmdStart
public fw_CmdStart(id, handle)
{
	// Not alive
	if (!g_isalive[id]) return;
	
	// Check if it's a flashlight impulse
	if (get_uc(handle, UC_Impulse) != IMPULSE_FLASHLIGHT) return;
	
	// Block it I say!
	set_uc(handle, UC_Impulse, 0)
}

// Forward Player PreThink
public fw_PlayerPreThink(id)
{
	// Not alive
	if (!g_isalive[id])
		return;
	
	if (pev_valid(g_buyzone_ent))
		dllfunc(DLLFunc_Touch, g_buyzone_ent, id)

	set_pev(id, pev_fuser2, 0.0)
	
	// Player frozen?
	if (g_frozen[id])
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		return; // shouldn't leap while frozen
	}
	
	// --- Check if player should leap ---
	
	// Don't allow leap during freezetime
	if (g_freezetime)
		return;
		
	if (get_user_weapon(id) == CSW_KNIFE&&!g_zombie[id])
        {
                if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))
                {
                        new flags = pev(id, pev_flags)
                        new waterlvl = pev(id, pev_waterlevel)
                        
                        if ((flags & FL_ONGROUND)&&waterlvl <= 1&&!(flags & FL_WATERJUMP))
                        {
	                        new Float:fVelocity[3]
	                        pev(id, pev_velocity, fVelocity)
	                        switch(g_knife[id]){
	                        	case 1:  fVelocity[2] += 350.0
								case 4:  fVelocity[2] += 320.0
	                        	default:  fVelocity[2] += 300.0
	                        }
	                        
	                        set_pev(id, pev_velocity, fVelocity)
	                        set_pev(id, pev_gaitsequence, 6)
                        }
                }
        }
	
	// Check if proper CVARs are enabled and retrieve leap settings
	static Float:cooldown, Float:current_time
	if (g_zombie[id])
	{
		if (g_nemesis[id])
		{
			if (!g_cached_leapnemesis) return;
			cooldown = g_cached_leapnemesiscooldown
		}
		else
		{
			switch (g_cached_leapzombies)
			{
				case 0: return;
				case 2: if (!g_firstzombie[id]) return;
				case 3: if (!g_lastzombie[id]) return;
			}
			cooldown = g_cached_leapzombiescooldown
		}
	}
	else
	{
		if (g_survivor[id])
		{
			if (!g_cached_leapsurvivor) return;
			cooldown = g_cached_leapsurvivorcooldown
		}
		else return;
	}
	
	current_time = get_gametime()
	
	// Cooldown not over yet
	if (current_time - g_lastleaptime[id] < cooldown)
		return;
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!g_isbot[id] && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return;
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
		return;
	
	static Float:velocity[3]
	
	// Make velocity vector
	velocity_by_aim(id, g_survivor[id] ? get_pcvar_num(cvar_leapsurvivorforce) : g_nemesis[id] ? get_pcvar_num(cvar_leapnemesisforce) : get_pcvar_num(cvar_leapzombiesforce), velocity)
	
	// Set custom height
	velocity[2] = g_survivor[id] ? get_pcvar_float(cvar_leapsurvivorheight) : g_nemesis[id] ? get_pcvar_float(cvar_leapnemesisheight) : get_pcvar_float(cvar_leapzombiesheight)
	
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
	
	// Update last leap time
	g_lastleaptime[id] = current_time
}

/*================================================================================
 [Client Commands]
=================================================================================*/

// Say "/zpmenu"
public clcmd_saymenu(id)
{
	show_menu_game(id) // show game menu
}

// Nightvision toggle
public clcmd_nightvision(id)
{	
	return PLUGIN_HANDLED;
}

// Weapon Drop
public clcmd_drop(id)
{
	// Survivor should stick with its weapon
	if (g_survivor[id])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Buy BP Ammo
public clcmd_buyammo(id)
{
	// Not alive or infinite ammo setting enabled
	if (!g_isalive[id] || get_pcvar_num(cvar_infammo))
		return PLUGIN_HANDLED;
	
	// Not human
	if (g_zombie[id])
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_HUMAN_ONLY")
		return PLUGIN_HANDLED;
	}
	
	// Custom buytime enabled and human player standing in buyzone, allow buying weapon's ammo normally instead
	if (g_cached_buytime > 0.0 && !g_survivor[id] && (get_gametime() < g_buytime[id] + g_cached_buytime) && cs_get_user_buyzone(id))
		return PLUGIN_CONTINUE;
	
	// Not enough ammo packs
	if (g_ammopacks[id] < 1)
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "NOT_ENOUGH_AMMO")
		return PLUGIN_HANDLED;
	}
	
	// Get user weapons
	static weapons[32], num, i, currentammo, weaponid, refilled
	num = 0 // reset passed weapons count (bugfix)
	refilled = false
	get_user_weapons(id, weapons, num)
	
	// Loop through them and give the right ammo type
	for (i = 0; i < num; i++)
	{
		// Prevents re-indexing the array
		weaponid = weapons[i]
		
		// Primary and secondary only
		if (MAXBPAMMO[weaponid] > 2)
		{
			// Get current ammo of the weapon
			currentammo = cs_get_user_bpammo(id, weaponid)
			
			// Give additional ammo
			ExecuteHamB(Ham_GiveAmmo, id, BUYAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
			
			// Check whether we actually refilled the weapon's ammo
			if (cs_get_user_bpammo(id, weaponid) - currentammo > 0) refilled = true
		}
	}
	
	// Weapons already have full ammo
	if (!refilled) return PLUGIN_HANDLED;
	
	// Deduce ammo packs, play clip purchase sound, and notify player
	g_ammopacks[id]--
	emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
	zp_colored_print(id, "^x04[ZP]^x01 %L", id, "AMMO_BOUGHT")
	
	return PLUGIN_HANDLED;
}

// Block Team Change
public clcmd_changeteam(id)
{
	set_pdata_int(id, 125, get_pdata_int(id, 125, 5) &  ~(1<<8), 5)
	
	static team
	team = fm_cs_get_user_team(id)
	
	// Unless it's a spectator joining the game
	if (team == FM_CS_TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE;
	
	// Pressing 'M' (chooseteam) ingame should show the main menu instead
	show_menu_game(id)
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Menus]
=================================================================================*/

// Game Menu
show_menu_game(id)
{
	// Player disconnected?
	if (!g_isconnected[id]) return
	
	static menu[512], len
	len = 0
	
	if(Map_Boss)
	{
	   len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	   len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия:\r [%s]^n", g_szPrivilege[id])
	   len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wГлавное меню - \r[M]^n")
	   len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wСпециальное меню \r[BZ]^n^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "\r[1]\w Магазин^n^n")
	
	   if(is_user_alive(id))
		   len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wЗастрял? \r(Жми)^n")
	   else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dЗастрял? \r(Мертв)^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "\r[3]\w Купить \r(VIP)^n^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "\r[4]\y Админ меню^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	}else{
	   len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	   len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия:\r [%s]^n", g_szPrivilege[id])
	   len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wГлавное меню - \r[M]^n^n")
	
       if(g_modestarted || zp_get_character_choosed(id))	
       len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dВыбрать класс \r[H]^n")
	   else len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wВыбрать класс человека \r[H]^n")
	   
	   len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wВыбрать класс \r[Z]^n^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "\r[3]\w Магазин^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "\r[4]\w Кабинет^n^n")
	
       if(fnGetPlaying()<14) len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dАрена с боссами \r[14]^n")	
	   else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wАрена с боссами \r[Hot]^n")	
	
	   if(is_user_alive(id))
		  len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wЗастрял? \r(Жми)^n")
	   else len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dЗастрял? \r(Мертв)^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "\r[7]\w Купить \r(VIP)^n^n")
	
	   if (g_survround || g_nemround)
	   len += formatex(menu[len], charsmax(menu) - len, "\r[8]\y Админ меню^n")
	   else len += formatex(menu[len], charsmax(menu) - len, "\r[8]\y Меню привилегий^n")
	
	   len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
   }
	
	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Game Menu")
}

// Privil Menu
public show_menu_privil(id)
{
	// Player disconnected?
	if (!g_isconnected[id]) return
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия:\r [%s]^n", g_szPrivilege[id])
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wМеню привилегий - \r[M]^n^n")
	
    if(get_user_flags(id) & ADMIN_LEVEL_H)
    len += formatex(menu[len], charsmax(menu) - len, "\r[1]\y Вип \rменю^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[1]\y Вип \dменю^n")
	
    if(get_user_flags(id) & ADMIN_LEVEL_E)
    len += formatex(menu[len], charsmax(menu) - len, "\r[2]\y Премиум \rменю^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2]\y Премиум \dменю ^n")	
	
	if(get_user_flags(id) & ADMIN_LEVEL_B)
	len += formatex(menu[len], charsmax(menu) - len, "\r[3]\y Админ \rменю^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3]\y Админ \dменю^n")
	
	if(get_user_flags(id) & ADMIN_LEVEL_D)
	len += formatex(menu[len], charsmax(menu) - len, "\r[4]\y Босс \rменю^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4]\y Босс \dменю^n")
	
	if(get_user_flags(id) & ADMIN_SLAY)
	len += formatex(menu[len], charsmax(menu) - len, "\r[5]\y Ядерное \rменю^n^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5]\y Ядерное \dменю^n^n")
	
	if(get_user_flags(id) & ADMIN_LEVEL_D)
		len += formatex(menu[len], charsmax(menu) - len, "\r[6]\w Раздача аммо^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[6]\d Раздача аммо^n")
	
	if(get_user_flags(id) & ADMIN_LEVEL_B)
		len += formatex(menu[len], charsmax(menu) - len, "\r[7]\w Управление \rZP 4.3^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[7]\d Управление \rZP 4.3^n")
	
	if(get_user_flags(id) & ADMIN_LEVEL_B)
		len += formatex(menu[len], charsmax(menu) - len, "\r[8]\w AMXMODMENU^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[8]\d AMXMODMENU^n")
	
	/*if(get_user_flags(id) & ADMIN_LEVEL_D)
		len += formatex(menu[len], charsmax(menu) - len, "\r[9]\w Выбрать цвет граба^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[9]\d Выбрать цвет граба^n")*/
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Privil Menu")
}

// Cabinet Menu
public show_menu_cabinet(id)
{
	// Player disconnected?
	if (!g_isconnected[id]) return
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия:\r [%s]^n", g_szPrivilege[id])
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wИгровой кабинет - \r[M]^n^n")	

    len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yНастройки^n^n")	
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wПрокачка^n")
	
    if(g_day_num>=3) len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wБонус^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dБонус \r[3]^n")
	
	if(fnGetPlaying()<=1) len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dПеревод аммо^n")
    else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wПеревод аммо^n")
	
    len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wЦентр обмена^n")

    len += formatex(menu[len], charsmax(menu) - len, "^n\r[9] \wНазад^n")  
	
    // 0. Exit
    len += formatex(menu[len], charsmax(menu) - len, "\r[0] \wВыход")
	
	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Cabinet Menu")
}

// Obmen Menu
public show_menu_obmen(id)
{
	// Player disconnected?
	if (!g_isconnected[id]) return
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wЦентр обмена - \r[M]^n^n")	

	if(g_iToken[id]>=10) 
    len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wОбменять \r[10 Б] \wна \r[50 Аммо]^n")
    else len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dОбменять \r[10 Б] \dна \r[50 Аммо]^n")
	
    if(g_iToken[id]>=50) 
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wОбменять \r[50 Б] \wна \r[500 Аммо]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dОбменять \r[50 Б] \dна \r[500 Аммо]^n")
	
	if(g_ammopacks[id]>=100)
    len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wОбменять \r[100 Аммо] \wна \r[10 Б]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dОбменять \r[100 Аммо] \dна \r[10 Б]^n")
	
	if(g_ammopacks[id]>=700)
    len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wОбменять \r[700 Аммо] \wна \r[50 Б]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dОбменять \r[700 Аммо] \dна \r[50 Б]^n")
	
	if(g_ammopacks[id]>=500)
    len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wОбменять \r[500 Аммо] \wна \r[EXP: 20]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dОбменять \r[500 Аммо] \dна \r[EXP: 20]^n")
	
	if(g_ammopacks[id]>=200)
    len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wОбменять \r[200 Аммо] \wна \r[EXP: 10]^n")
    else len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dОбменять \r[200 Аммо] \dна \r[EXP: 10]^n")	

    len += formatex(menu[len], charsmax(menu) - len, "^n\r[9] \wНазад^n")  
	
    // 0. Exit
    len += formatex(menu[len], charsmax(menu) - len, "\r[0] \wВыход")
	
	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Obmen Menu")
}

public settings_bz(id) 
{
    static menu[512], len
    len = 0

     len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wНастройки \r[BZ]^n^n")
    
    // 1. Proka4ka
    len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wИнформер \r[%s]^n", g_informer[id] ? "Выкл" : "Вкл")
	
    len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wЦвет информера^n")
	
    len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wРасположение инфор. \r[%s]^n", g_iInformerCord[id] ? "Справа":"Слева")
	
    len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wЧат \r[%s]^n", g_chat_bz[id] ? "Английский":"Русский")	
	
    len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wИнформация об игроке \r[%s]^n", iPlayerAimInfo[id] ? "Выкл":"Вкл")			

    len += formatex(menu[len], charsmax(menu) - len, "^n\r[9] \wНазад^n")  
	
    // 0. Exit
    len += formatex(menu[len], charsmax(menu) - len, "\r[0] \wВыход")
	
	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)

    show_menu(id, KEYSMENU, menu, -1, "Settings Menu")
}

// Buy Menu 1
public show_menu_buy1(taskid)
{
	// Get player's id
	static id
	(taskid > g_maxplayers) ? (id = ID_SPAWN) : (id = taskid);
	
	// Player dead?
	if (!g_isalive[id])
		return;
	
	// Zombies or survivors get no guns
	if (g_zombie[id] || g_survivor[id])
		return;
	
	// Bots pick their weapons randomly / Random weapons setting enabled
	if (get_pcvar_num(cvar_randweapons) || g_isbot[id])
	{
		buy_primary_weapon(id, random_num(0, ArraySize(g_primary_items) - 1))
		//menu_buy2(id, random_num(0, ArraySize(g_secondary_items) - 1))
		return;
	}
	
    static menu[512], len
    len = 0

    // Title
    len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n", id, WPN_STARTID+1, min(WPN_STARTID+7, WPN_MAXIDS))
    len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wВыбери основное оружие \r[BZ]^n^n")    
    
    // 1-7. Weapon List
        len += formatex(menu[len], charsmax(menu) - len, "\r[1]\w Взять \r[AK-47 + Deagle]^n")
        len += formatex(menu[len], charsmax(menu) - len, "\r[2]\w Взять \r[M4A1 + Deagle]^n^n")
		if(g_lvl[id]>=5)
        len += formatex(menu[len], charsmax(menu) - len, "\r[3]\w Взять \r[Easy kit] \d- \r[10 аммо]^n")
		else len += formatex(menu[len], charsmax(menu) - len, "\r[3]\d Взять \r[Easy kit] \d- \r[LVL: 5]^n")
		if(g_lvl[id]>=25)
        len += formatex(menu[len], charsmax(menu) - len, "\r[4]\w Взять \r[Average kit] \d- \r[20 аммо]^n")
		else len += formatex(menu[len], charsmax(menu) - len, "\r[4]\d Взять \r[Average kit] \d- \r[L :25]^n")
		if(g_lvl[id]>=50)
        len += formatex(menu[len], charsmax(menu) - len, "\r[5]\w Взять \r[Powerful kit] \d- \r[30 аммо]^n")
		else len += formatex(menu[len], charsmax(menu) - len, "\r[5]\d Взять \r[Powerful kit] \d- \r[L: 50]^n^n\yВ стандартный набор входит:^n\d- Deagle^n- Взрывная,ледяная граната^n")
    
    // 9. Next/Back - 0. Exit
    len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu 1")
}


/*show_menu_buy2(id)
{
	// Player dead?
	if (!g_isalive[id])
		return;
	
	static menu[250], len, weap, maxloops
	len = 0
	maxloops = ArraySize(g_secondary_items)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yХалявное оружие:^n")
	
	// 1-6. Weapon List
	for (weap = 0; weap < maxloops; weap++)
		len += formatex(menu[len], charsmax(menu) - len, "^n\r%d.\w %s", weap+1, WEAPONNAMES[ArrayGetCell(g_secondary_weaponids, weap)])
	
	// 8. Auto Select
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r8.\w Не показывать")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\w Выход")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu 2")
}*/

// Zombie Class Menu
public show_menu_zclass(id)
{
    // Player disconnected
    if (!g_isconnected[id])
        return;
    
    // Bots pick their zombie class randomly
    if (g_isbot[id])
    {
        g_zombieclassnext[id] = random_num(0, g_zclass_i - 1)
        return;
    }
    
    static menuid, menu[512], len, class, buffer[256], buffer2[256]
    len = 0    
    
    // Title
    len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wВыбери зомби \r[BZ]")
    menuid = menu_create(menu, "menu_zclass")
    
    // Class List
    for (class = 0; class < g_zclass_i; class++)
    {
        // Retrieve name and info
        ArrayGetString(g_zclass_name, class, buffer, charsmax(buffer))
        ArrayGetString(g_zclass_info, class, buffer2, charsmax(buffer2))
        
        // Add to menu
        if (class == g_zombieclassnext[id])
            formatex(menu, charsmax(menu), "\d%s %s \r(*)", buffer, buffer2)
        else
            formatex(menu, charsmax(menu), "%s \y%s", buffer, buffer2)
        
        buffer[0] = class
        buffer[1] = 0
        menu_additem(menuid, menu, buffer)
    }
    
    // Back - Next - Exit
    formatex(menu, charsmax(menu), "Назад")
    menu_setprop(menuid, MPROP_BACKNAME, menu)
    formatex(menu, charsmax(menu), "Вперед")
    menu_setprop(menuid, MPROP_NEXTNAME, menu)
    formatex(menu, charsmax(menu), "Выход")
    menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_ZCLASS = min(MENU_PAGE_ZCLASS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
    
	menu_display(id, menuid, MENU_PAGE_ZCLASS)
}

// Help Menu
show_menu_info(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return;
	
	static menu[150]
	
	formatex(menu, charsmax(menu), "\y%L^n^n\r1.\w %L^n\r2.\w %L^n\r3.\w %L^n\r4.\w %L^n^n\r0.\w %L", id, "MENU_INFO_TITLE", id, "MENU_INFO1", id,"MENU_INFO2", id,"MENU_INFO3", id,"MENU_INFO4", id, "MENU_EXIT")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Mod Info")
}

// Admin Menu
show_menu_admin(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return;
	
	static menu[512], len
	len = 0
	new AdmCan=0
	if(get_user_flags(id) & ADMIN_LEVEL_B) AdmCan=1
	
    // Title
    len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wУправление ZP 4.3 \r[BZ]^n^n\yСделать игрока^n")
    
    // 1. Zombiefy/Humanize command
    if (AdmCan)
    len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wЗомби/Человеком^n")
    else
    len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dЗомби/Человеком^n")
    
    // 2. Nemesis command
    if (AdmCan && g_vip[id] == 0 && !native_has_round_started())
    len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wДьяволом^n")
    else
    len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dДьяволом^n")
    
    // 3. Survivor command
    if (AdmCan && g_vip[id] == 0 && !native_has_round_started())
    len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wГероем^n^n\yИгровые моды^n")
    else
    len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dГероем^n^n\yИгровые моды^n")
    
    // 5. Swarm mode command
    if (AdmCan && allowed_swarm() && !g_vip_stop[id][0])
    len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wКучу на кучу^n")
    else
    len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dКучу на кучу^n")
    
    // 6. Multi infection command
    if (AdmCan && allowed_multi() && !g_vip_stop[id][1])
    len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wМнож. заражение^n")
    else
    len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dМнож. заражение^n")
    
    // 7. Plague mode command
    if ((get_user_flags(id) & ADMIN_LEVEL_B) && allowed_plague() && !g_vip_stop[id][2])
    len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wЧума^n^n\yВозрождение^n")
    else
    len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dЧума^n^n\yВозрождение^n")

    if (AdmCan)
    {
        len += formatex(menu[len], charsmax(menu) - len, "\r[7] \wВозродить^n")        
    }
    else
    len += formatex(menu[len], charsmax(menu) - len, "\r[7] \dВозродить^n")
    
    // 0. Exit
    len += formatex(menu[len], charsmax(menu) - len, "^n\r[0] \wВыход")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Admin Menu")
	
	//ALLOWED
}

// Player List Menu
show_menu_player_list(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return;
	
	static menuid, menu[128], player, buffer[2]
	new AdmCan=0
	if(get_user_flags(id) & ADMIN_LEVEL_B) AdmCan=1
	
	// Title
	switch (PL_ACTION)
	{
        case ACTION_ZOMBIEFY_HUMANIZE: formatex(menu, charsmax(menu), "\r[Зомби/Человеком]^n\wВыберите игрока:")
        case ACTION_MAKE_NEMESIS: formatex(menu, charsmax(menu), "\r[Дьяволом]^n\wВыберите игрока:")
        case ACTION_MAKE_SURVIVOR: formatex(menu, charsmax(menu), "\r[Героем]^n\wВыберите игрока:")
        case ACTION_RESPAWN_PLAYER: formatex(menu, charsmax(menu), "\r[Возродить]^n\wВыберите игрока:")
	}
	menuid = menu_create(menu, "menu_player_list")
	
	// Player List
	for (player = 0; player <= g_maxplayers; player++)
	{
		// Skip if not connected
		if (!g_isconnected[player])
			continue;
		
		// Format text depending on the action to take
		switch (PL_ACTION)
		{
			case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[player])
				{
					if (allowed_human(player) && AdmCan)
						formatex(menu, charsmax(menu), "%s \r[%s]", g_playername[player], g_nemesis[player]?"Дьявол":"Зомби")
					else
						formatex(menu, charsmax(menu), "\d%s [%s]", g_playername[player], g_nemesis[player]?"Дьявол":"Зомби")
				}
				else
				{
					if (allowed_zombie(player) && AdmCan)
						formatex(menu, charsmax(menu), "%s \y[%s]", g_playername[player], g_survivor[player]?"Герой":"Человек")
					else
						formatex(menu, charsmax(menu), "\d%s [%s]", g_playername[player], g_survivor[player]?"Герой":"Человек")
				}
			}
			case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (allowed_nemesis(player) && AdmCan)
				{
					if (g_zombie[player])
						formatex(menu, charsmax(menu), "%s \r[%s]", g_playername[player], g_nemesis[player]?"Дьявол":"Зомби")
					else
						formatex(menu, charsmax(menu), "%s \y[%s]", g_playername[player], g_survivor[player]?"Герой":"Человек")
				}
				else
					formatex(menu, charsmax(menu), "\d%s [%s]", g_playername[player], g_zombie[player] ? g_nemesis[player]?"Дьявол":"Зомби" : g_survivor[player]?"Герой":"Человек")
			}
			case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (allowed_survivor(player) && AdmCan)
				{
					if (g_zombie[player])
						formatex(menu, charsmax(menu), "%s \r[%s]", g_playername[player], g_nemesis[player]?"Дьявол":"Зомби")
					else
						formatex(menu, charsmax(menu), "%s \y[%s]", g_playername[player], g_survivor[player]?"Герой":"Человек")
				}
				else
					formatex(menu, charsmax(menu), "\d%s [%s]", g_playername[player], g_zombie[player] ? g_nemesis[player]?"Дьявол":"Зомби" : g_survivor[player]?"Герой":"Человек")
			}
			case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (allowed_respawn(player) && AdmCan)
					formatex(menu, charsmax(menu), "%s", g_playername[player])
				else
					formatex(menu, charsmax(menu), "\d%s", g_playername[player])
			}
		}
		
		// Add player
		buffer[0] = player
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_PLAYERS = min(MENU_PAGE_PLAYERS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menuid, MENU_PAGE_PLAYERS)
}

/*================================================================================
 [Menu Handlers]
=================================================================================*/

// Game Menu
public menu_game(id, key)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return PLUGIN_HANDLED;
	
	if(Map_Boss) {
	switch (key)
	{	
		case 0:
		{
			if(!g_isalive[id]){
				show_menu_game(id)
				return PLUGIN_HANDLED
			}
			
			if(g_survivor[id]||g_nemesis[id]){
				show_menu_game(id)
				return PLUGIN_HANDLED
			}
			
			go_buy(id)
		}
		
		case 1:{
			// Check if player is stuck
			if (g_isalive[id])
			{
				if (is_player_stuck(id))
				{
					// Move to an initial spawn
					if (get_pcvar_num(cvar_randspawn))
						do_random_spawn(id) // random spawn (including CSDM)
					else
						do_random_spawn(id, 1) // regular spawn
				}
				else {
					client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
					zp_colored_print(id, "^x04[ZP]^x01 Вы не застряли!")
					show_menu_game(id)
				}
			}
			else
				show_menu_game(id)
		}
		
		case 2:{		
		  cont_menu(id)
		}			
		
		case 3: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_B)) {
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 ADMIN^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			admin_main_menu(id)
	   }  
  }
  }else{
	switch (key)
	{
        case 0: {
		  if(g_modestarted || zp_get_character_choosed(id)) {
              zp_colored_print(id, "^x04[ZP]^x01 Выбрать класс можно только до начала ^x04 ЗАРАЖЕНИЯ ^x01или ваш класс уже ^x04ВЫБРАН!")		
		      client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)	
		  }else{
		  		humanclass_open(id)
          }	
        }	
		case 1: show_menu_zclass(id)
		case 2:
		{
			if(!g_isalive[id]){
				show_menu_game(id)
				return PLUGIN_HANDLED
			}
			
			if(g_survivor[id]||g_nemesis[id]){
				show_menu_game(id)
				return PLUGIN_HANDLED
			}
			
			go_buy(id)
		}
		
		case 3:{
			show_menu_cabinet(id)
		}
		
		case 4: {
		   if(fnGetPlaying()<14) {
		     zp_colored_print(id, "^x04[ZP]^x01 Недостаточно игроков!")
			 client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			 show_menu_game(id)
		   } else { 
		     client_cmd(id, "boss_vote")
		   }
		}
		
		case 5:{
			// Check if player is stuck
			if (g_isalive[id])
			{
				if (is_player_stuck(id))
				{
					// Move to an initial spawn
					if (get_pcvar_num(cvar_randspawn))
						do_random_spawn(id) // random spawn (including CSDM)
					else
						do_random_spawn(id, 1) // regular spawn
				}
				else {
					client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
					zp_colored_print(id, "^x04[ZP]^x01 Вы не застряли!")
					show_menu_game(id)
				}
			}
			else
				show_menu_game(id)
		}
		
		case 6:{		
		  cont_menu(id)
		}			
		
		case 7: {
          if(g_survround || g_nemround) {
		     if(get_user_flags(id) & ADMIN_LEVEL_B) {
			    admin_main_menu(id) 
				} else {
			    show_menu_game(id)
			    client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
		        zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 ADMIN^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
             }
		  }	 
          else show_menu_privil(id)			 
	   }
	}
 }
	
	return PLUGIN_HANDLED;
}

public menu_privil(id, key)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return PLUGIN_HANDLED;
	
	switch (key)
	{	
		case 0: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_H)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 VIP^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			show_vip_menu(id)
		}
		
		case 1: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_E)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 PREMIUM^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			show_prem_menu(id)
		}		
		
		case 2: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_B)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 ADMIN^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			show_admin_menu(id)
		}
		
		case 3: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_D)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 BOSS^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			show_boss_menu(id)
		}
		
		case 4: {
			if(!(get_user_flags(id) & ADMIN_CVAR)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 OWNER^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			show_ad_menu1(id)
		}	

		
		
		case 5: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_D)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 BOSS^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			show_ad_menu1(id)
		}		
		case 6: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_B)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 ADMIN^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			show_menu_admin(id)
		}
		
		case 7: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_B)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 ADMIN^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			admin_main_menu(id)
		}
		
		/*case 8: {
			if(!(get_user_flags(id) & ADMIN_LEVEL_D)){
				show_menu_privil(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 BOSS^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				return PLUGIN_HANDLED;
			}
			zp_color_menu(id)
		}*/
	}
	
	return PLUGIN_HANDLED;
}

public menu_cabinet(id, key)
{
    switch (key)
    {
        case 0: settings_bz(id)    
        case 1: show_points_menu(id)
        case 2: // Help Menu
        { 
		  if(g_day_num>=3){
             show_ruletka_menu(id)
		  } else {
                zp_colored_print(id, "^x04[ZP]^x01 Взять бонус можно с ^x04 3ого ^x01дня")	
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)	
                show_menu_cabinet(id)	
          }				
        }
        case 3: 
		{
		  if(fnGetPlaying()<=1) {
                zp_colored_print(id, "^x04[ZP]^x01 Недостаточно игроков!")	
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)	
                show_menu_cabinet(id)	
          } else {				
		    donate_show(id)
		  }
		}  
		case 4: show_menu_obmen(id)
        case 8: show_menu_game(id)
    }
    
    return PLUGIN_HANDLED;
}

public menu_obmen(id, key)
{
    switch (key)
    {
        case 0: 
		{
		    if(g_iToken[id]>=10) {
			  g_iToken[id] -= 10
			  g_ammopacks[id] += 50
			  zp_colored_print(id, "^x04[ZP]^x01 Вы успешно обменяли ^x04 10 болтов ^x01 на ^x04 50 ^x01аммо!")	
			  show_menu_obmen(id)
			} else {
			zp_colored_print(id, "^x04[ZP]^x01 У вас недостаточно болтов!")	
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			show_menu_obmen(id)
		    }
		}
        case 1: 
		{
		    if(g_iToken[id]>=50) {
			  g_iToken[id] -= 50
			  g_ammopacks[id] += 500
			  zp_colored_print(id, "^x04[ZP]^x01 Вы успешно обменяли ^x04 10 болтов ^x01 на ^x04 500 ^x01аммо!")	
			  show_menu_obmen(id)
			} else {
			zp_colored_print(id, "^x04[ZP]^x01 У вас недостаточно болтов!")	
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			show_menu_obmen(id)
		    }
		}
        case 2: 
		{
		    if(g_ammopacks[id]>=100) {
			  g_iToken[id] += 10
			  g_ammopacks[id] -= 100
			  zp_colored_print(id, "^x04[ZP]^x01 Вы успешно обменяли ^x04 100 аммо ^x01 на ^x04 10 ^x01болтов!")	
			  show_menu_obmen(id)
			} else {
			zp_colored_print(id, "^x04[ZP]^x01 У вас недостаточно аммо!")	
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			show_menu_obmen(id)
		    }
		}
        case 3: 
		{
		    if(g_ammopacks[id]>=700) {
			  g_iToken[id] += 50
			  g_ammopacks[id] -= 700
			  zp_colored_print(id, "^x04[ZP]^x01 Вы успешно обменяли ^x04 700 аммо ^x01 на ^x04 50 ^x01болтов!")	
			  show_menu_obmen(id)
			} else {
			zp_colored_print(id, "^x04[ZP]^x01 У вас недостаточно аммо!")	
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			show_menu_obmen(id)
		    }
		}
        case 4: 
		{
		    if(g_ammopacks[id]>=500) {
			  g_exp[id] += 20
			  g_ammopacks[id] -= 500
			  zp_colored_print(id, "^x04[ZP]^x01 Вы успешно обменяли ^x04 500 аммо ^x01 на ^x04 20 ^x01опыта!")	
			  show_menu_obmen(id)
			} else {
			zp_colored_print(id, "^x04[ZP]^x01 У вас недостаточно аммо!")	
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			show_menu_obmen(id)
		    }
		}
        case 5: 
		{
		    if(g_ammopacks[id]>=200) {
			  g_exp[id] += 10
			  g_ammopacks[id] -= 200
			  zp_colored_print(id, "^x04[ZP]^x01 Вы успешно обменяли ^x04 200 аммо ^x01 на ^x04 10 ^x01опыта!")	
			  show_menu_obmen(id)
			} else {
			zp_colored_print(id, "^x04[ZP]^x01 У вас недостаточно аммо!")	
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			show_menu_obmen(id)
		    }
		}
        case 8: show_menu_cabinet(id)      
    } 
    return PLUGIN_HANDLED;
}

public menu_settings(id, key)
{
    switch (key)
    {
        case 0:
		{	
            g_informer[id] = !g_informer[id];
		
            if(g_informer[id]) {
				g_informer[id] = true
            } else{
				g_informer[id] = false
            } settings_bz(id)
		}	
        case 1: color_informer(id)
        case 2: 
        {
            g_iInformerCord[id] = !g_iInformerCord[id];
			
            if(g_iInformerCord[id]) {
			    g_fMainInformerPosX[id] = 0.85;
			    g_fMainInformerPosY[id] = 0.16;
            } else{
			    g_fMainInformerPosX[id] = 0.02;
			    g_fMainInformerPosY[id] = 0.16;
            } settings_bz(id)		
        }
        case 3: // Extra Items
        {
            g_chat_bz[id] = !g_chat_bz[id];
			
            if(g_chat_bz[id]) {
		       client_cmd(id, "say /eng2")
            } else{
		       client_cmd(id, "say /rus2")
            } settings_bz(id)
        }
		case 4:
		{
            iPlayerAimInfo[id] = !iPlayerAimInfo[id];		
		
			if(iPlayerAimInfo[id]) {
				iPlayerAimInfo[id] = true
			} else{
				iPlayerAimInfo[id] = false
			}
			settings_bz(id)
		}
        case 8: show_menu_cabinet(id)
    }
    
    return PLUGIN_HANDLED;
}


public color_informer(id) 
{
    static menu[512], len
    len = 0
    
    len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wЦвет информера \r[BZ]^n^n")
    
    len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wЖёлтый^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wКрасный^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wБелый^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wФиолетовый^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wРозовый^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wЗеленый^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[7] \wТёмно-синий^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[8] \wСиний^n")
    len += formatex(menu[len], charsmax(menu) - len, "^n\r[9] \wНазад^n")  
	
    // 0. Exit
    len += formatex(menu[len], charsmax(menu) - len, "\r[0] \wВыход")

    show_menu(id, KEYSMENU, menu, -1, "Colors2 Menu")
}

public menu_colors_bz(id, key)
{
    switch (key)
    {
		case 0: g_fMainInformerColor[id] = {255, 255, 0}, color_informer(id);
		case 1: g_fMainInformerColor[id] = {255, 0, 0}, color_informer(id);
		case 2: g_fMainInformerColor[id] = {255, 250, 250}, color_informer(id);
		case 3: g_fMainInformerColor[id] = {238, 130, 238}, color_informer(id);
		case 4: g_fMainInformerColor[id] = {255, 110, 180}, color_informer(id);
		case 5: g_fMainInformerColor[id] = {0, 255, 0}, color_informer(id);
		case 6: g_fMainInformerColor[id] = {0, 0, 255}, color_informer(id);
		case 7: g_fMainInformerColor[id] = {0, 191, 255}, color_informer(id);
        case 8: settings_bz(id)
    }
}

// Buy Menu 1
public menu_buy1(id, key)
{
	if (!g_isalive[id]) return PLUGIN_HANDLED;
	
	if (g_zombie[id] || g_survivor[id]) return PLUGIN_HANDLED;
	
	if (key >= MENU_KEY_AUTOSELECT || WPN_SELECTION >= WPN_MAXIDS)
	{
		switch (key)
		{
			case MENU_KEY_AUTOSELECT: // toggle auto select
			{
				WPN_AUTO_ON = 1
				return PLUGIN_HANDLED;
			}
			case MENU_KEY_EXIT: // exit
			{
				return PLUGIN_HANDLED;
			}
		}
		
		// Show buy menu again
		show_menu_buy1(id)
		return PLUGIN_HANDLED;
	}
	
	// Store selected weapon id
	WPN_AUTO_PRI = WPN_SELECTION
	
	// Buy primary weapon
	buy_primary_weapon(id, WPN_AUTO_PRI)
	
	return PLUGIN_HANDLED;
}

// Buy Primary Weapon
buy_primary_weapon(id, selection)
{
	// Drop previous weapons
	//drop_weapons(id, 1)
	//drop_weapons(id, 2)
	
	// Strip off from weapons
	//fm_strip_user_weapons(id)
	//fm_give_item(id, "weapon_knife")
	
	// Get weapon's id and name
	static weaponid, wname[32]
	weaponid = ArrayGetCell(g_primary_weaponids, selection)
	ArrayGetString(g_primary_items, selection, wname, charsmax(wname))
	
    if(weaponid == CSW_AK47) 
    {
       drop_weapons(id, 1)
       drop_weapons(id, 2)
       give_item(id, "weapon_deagle")
       cs_set_user_bpammo(id, CSW_DEAGLE, 35)       
    }    
    if(weaponid == CSW_M4A1) 
    {
       drop_weapons(id, 1)
       drop_weapons(id, 2)
       give_item(id, "weapon_deagle")    
       cs_set_user_bpammo(id, CSW_DEAGLE, 35)
    } 
    if(weaponid == CSW_XM1014) 
    {
        if(g_lvl[id] < 5)
        {        
            zp_colored_print(id, "^x04[ZP] ^x01Этот набор доступен с ^x04 5 ^x01уровня!")
            show_menu_buy1(id)
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			return PLUGIN_HANDLED
        }
        if(g_ammopacks[id] < 10)
        {        
            zp_colored_print(id, "^x04[ZP] ^x01Чтобы взять данный набор нужно иметь ^x04 10 ^x01аммо!")
            show_menu_buy1(id)
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			return PLUGIN_HANDLED
        }
        drop_weapons(id, 1)
        drop_weapons(id, 2)
        give_skull11(id)
        give_item(id, "weapon_deagle")    
        cs_set_user_bpammo(id, CSW_DEAGLE, 35)
        cs_set_user_armor(id,35,CS_ARMOR_KEVLAR)
		g_ammopacks[id] -= 10
    } 
    if(weaponid == CSW_AUG) 
    {
        if(g_lvl[id] < 25)
        {        
            zp_colored_print(id, "^x04[ZP] ^x01Этот набор доступен с ^x04 25 ^x01уровня!")
            show_menu_buy1(id)
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			return PLUGIN_HANDLED
        }
        if(g_ammopacks[id] < 20)
        {        
            zp_colored_print(id, "^x04[ZP] ^x01Чтобы взять данный набор нужно иметь ^x04 20 ^x01аммо!")
            show_menu_buy1(id)
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			return PLUGIN_HANDLED
        }
        drop_weapons(id, 1)
        drop_weapons(id, 2)
        give_dart(id)
		give_balrog5(id)
        cs_set_user_armor(id,50,CS_ARMOR_KEVLAR)
		g_ammopacks[id] -= 20
    } 
    if(weaponid == CSW_M249) 
    {
        if(g_lvl[id] < 50)
        {        
            zp_colored_print(id, "^x04[ZP] ^x01Этот набор доступен с ^x04 50 ^x01уровня!")
            show_menu_buy1(id)
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			return PLUGIN_HANDLED
        }
        if(g_ammopacks[id] < 30)
        {        
            zp_colored_print(id, "^x04[ZP] ^x01Чтобы взять данный набор нужно иметь ^x04 30 ^x01аммо!")
            show_menu_buy1(id)
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
			return PLUGIN_HANDLED
        }
        drop_weapons(id, 1)
        drop_weapons(id, 2)
        give_dinfi(id)
		give_balrog7(id)
        cs_set_user_armor(id,150,CS_ARMOR_KEVLAR)
		g_ammopacks[id] -= 30
    }
	
	// Give the new weapon and full ammo
	fm_give_item(id, wname)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
	
	// Weapons bought
	g_canbuy[id] = false
	
	// Give additional items
	static i
	for (i = 0; i < ArraySize(g_additional_items); i++)
	{
		ArrayGetString(g_additional_items, i, wname, charsmax(wname))
		fm_give_item(id, wname)
		
        show_menu_knifes(id)
	}
}

// Buy Menu 2
/*public menu_buy2(id, key)
{
	// Player dead?
	if (!g_isalive[id])
		return PLUGIN_HANDLED;
	
	// Zombies or survivors get no guns
	if (g_zombie[id] || g_survivor[id])
		return PLUGIN_HANDLED;
	
	// Special keys / weapon list exceeded
	if (key >= ArraySize(g_secondary_items))
	{
		// Toggle autoselect
		if (key == MENU_KEY_AUTOSELECT){
			WPN_AUTO_ON = 1
			return PLUGIN_HANDLED;
		}
		
		// Reshow menu unless user exited
		if (key != MENU_KEY_EXIT)
			show_menu_buy2(id)
		
		return PLUGIN_HANDLED;
	}
	
	// Store selected weapon
	WPN_AUTO_SEC = key
	
	// Drop secondary gun again, in case we picked another (bugfix)
	drop_weapons(id, 2)
	
	// Get weapon's id
	static weaponid, wname[32]
	weaponid = ArrayGetCell(g_secondary_weaponids, key)
	ArrayGetString(g_secondary_items, key, wname, charsmax(wname))
	
	// Give the new weapon and full ammo
	fm_give_item(id, wname)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
	
	return PLUGIN_HANDLED;
}*/

// Buy Extra Item
buy_extra_item(id, itemid, ignorecost = 0)
{
	// Retrieve item's team
	static team
	team = ArrayGetCell(g_extraitem_team, itemid)
	
	// Check for team/class specific items
	if ((g_zombie[id] && !g_nemesis[id] && !(team & ZP_TEAM_ZOMBIE)) || (!g_zombie[id] && !g_survivor[id] && !(team & ZP_TEAM_HUMAN)) || (g_nemesis[id] && !(team & ZP_TEAM_NEMESIS)) || (g_survivor[id] && !(team & ZP_TEAM_SURVIVOR)))
	{
		zp_colored_print(id, "^x04[ZP]^x01 Ошибка!")
		return;
	}
	
	// Check for hard coded items with special conditions
	if ((itemid == EXTRA_ANTIDOTE && (g_endround || g_swarmround || g_nemround || g_survround || g_plagueround || fnGetZombies() <= 1 || fnGetHumans() == 1))
	|| (itemid == EXTRA_MADNESS && g_nodamage[id]) 
	|| (itemid == EXTRA_ZOMBIBOMB && (g_endround || g_nemround || g_survround)))
	{
		client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
		zp_colored_print(id, "^x04[ZP]^x01 Ошибка! Это нельзя сейчас использовать.")
		return;
	}
	
	if (ArrayGetCell(g_extraitem_lvl, itemid) > g_lvl[id])
	{
		client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
		zp_colored_print(id, "^x04[ZP]^x01 Для покупки данного оружия/снаряжения нужно иметь ^x04[L: %d]",ArrayGetCell(g_extraitem_lvl, itemid))
		return;
	}
	
	if (!ignorecost)
    {
        // Check that we have enough ammo packs
        if (g_iToken[id] < ArrayGetCell(g_extraitem_bolt, itemid))
        {
			client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
            zp_colored_print(id, "^x04[ZP]^x01 Для покупки данного предмета, нужно иметь ^x04(Б: %d)", ArrayGetCell(g_extraitem_bolt, itemid))
            return;
        }
    }
	
	// Ignore item's cost?
    if (!ignorecost)
    {
        // Check that we have enough ammo packs
        if (g_ammopacks[id] < ArrayGetCell(g_extraitem_cost, itemid))
        { 
		    client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
            zp_colored_print(id, "^x04[ZP]^x01 У вас не хватает ^x04АММО!")
            return;
        }
    }
	
	// Check which kind of item we're buying
	switch (itemid)
	{
		case EXTRA_ANTIDOTE: // Antidote
		{
			if(g_antidote_limit[id]){
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_antidote_limit[id]=1
			humanme(id, 0, 0)
		}
		case EXTRA_MADNESS: // Zombie Madness
		{
			if(g_madness_limit[id]>=MADNESS_LIMIT){
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_madness_limit[id]++
			
			g_nodamage[id] = true
			set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
			set_task(get_pcvar_float(cvar_madnessduration), "madness_over", id+TASK_BLOOD)
			
			static sound[64]
			ArrayGetString(zombie_madness, random_num(0, ArraySize(zombie_madness) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case EXTRA_ZOMBIBOMB: // Infection Bomb
		{			
			// Already own one
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				if((cs_get_user_bpammo(id, CSW_SMOKEGRENADE) < 3))
				{
					// Increase BP ammo on it instead
					cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1)
					
					// Flash ammo in hud
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(AMMOID[CSW_HEGRENADE]) // ammo id
					write_byte(1) // ammo amount
					message_end()
					
					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}else{
					client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
					zp_colored_print(id, "^x04[ZP]^x01 У вас максимум гранат!")
					return
				}
			}
			else fm_give_item(id, "weapon_hegrenade")
		}
		case EXTRA_SHOCKBOMB:
		{
			// Already own one
			if (user_has_weapon(id, CSW_SMOKEGRENADE))
			{
				if((cs_get_user_bpammo(id, CSW_SMOKEGRENADE) < 3))
				{
					// Increase BP ammo on it instead
					cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1)
					
					// Flash ammo in hud
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(AMMOID[CSW_SMOKEGRENADE]) // ammo id
					write_byte(1) // ammo amount
					message_end()
					
					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}else{
					client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
					zp_colored_print(id, "^x04[ZP]^x01 У вас максимум гранат!")
					return
				}
			}
			else fm_give_item(id, "weapon_smokegrenade")
		}
		case EXTRA_NOKNOCK:{
			if(g_noknock[id]){
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_noknock[id]=true
		}
		case EXTRA_HEALTH:
		{
			if(g_health_limit[id]>=5)
			{
				zp_colored_print(id, "^x04[ZP]^x01 Невозможно купить здоровье! ^x04(Лимит покупки: 5 раз)")
				return
			}
			g_health_limit[id]++
			
			new Float:hp
			pev(id, pev_health, hp)
			set_pev(id, pev_health, hp+1000.0)
		}		
		case EXTRA_HEALTH2:
		{
			if(g_health_limit2[id]>=3)
			{
				zp_colored_print(id, "^x04[ZP]^x01 Невозможно купить здоровье! ^x04(Лимит покупки: 3 раза)")
				return
			}
			g_health_limit2[id]++
			
			new Float:hp
			pev(id, pev_health, hp)
			set_pev(id, pev_health, hp+50.0)
		}	
		case EXTRA_ARMOR:
		{
			if(g_armor_limit[id]>=ARMOR_LIMIT){
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			
			new Float:armor
			pev(id, pev_armorvalue, armor)
			
			if(armor >= 300.0){
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 Нельзя купить броню! Лимит брони: 300")
				return
			}
			
			g_armor_limit[id]++
			
			set_pev(id, pev_armorvalue, armor + 100.0)
		}
		/*case EXTRA_SURVIVOR:
		{
			if(g_newround&&g_lastmode!=MODE_SURVIVOR&&!g_surv_limit){
				make_a_zombie(MODE_SURVIVOR, id)
				remove_task(TASK_MAKEZOMBIE)
				remove_task(TASK_WARMUP)
				g_surv_limit=6
			}
			else {
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				zp_colored_print(id, "^x04[ZP]^x01 Стать терминатором можно только до заражения!")
				return
			}
		}*/
		case EXTRA_UNLIMITED:
		{
			if(g_unlimited[id]) {
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			
			g_unlimited[id]=1
		}
		case EXTRA_NORECOIL:
		{
			if(g_norecoil[id]) {
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_norecoil[id]=1
		}
		case EXTRA_CAKE:{
			if(g_cake_limit[id]){
				zp_colored_print(id, "^x04[ZP]^x01 Невозможно купить Тортик! ^x04(Лимит покупки: 1 раз)")
				return
			}
			
			fm_give_item(id, "weapon_smokegrenade")
			g_cake_limit[id]++
		}		
		case EXTRA_FLAMEGR:{
			// Already own one
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				if((cs_get_user_bpammo(id, CSW_SMOKEGRENADE) < 3))
				{
					// Increase BP ammo on it instead
					cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1)
					
					// Flash ammo in hud
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(AMMOID[CSW_HEGRENADE]) // ammo id
					write_byte(1) // ammo amount
					message_end()
					
					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}else{
					client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
					zp_colored_print(id, "^x04[ZP]^x01 У вас максимум гранат!")
					return
				}
			}
			else fm_give_item(id, "weapon_hegrenade")
		}
		case EXTRA_ICEGR:{
			// Already own one
			if (user_has_weapon(id, CSW_FLASHBANG))
			{
				if((cs_get_user_bpammo(id, CSW_SMOKEGRENADE) < 3))
				{
					// Increase BP ammo on it instead
					cs_set_user_bpammo(id, CSW_FLASHBANG, cs_get_user_bpammo(id, CSW_FLASHBANG) + 1)
					
					// Flash ammo in hud
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(AMMOID[CSW_FLASHBANG]) // ammo id
					write_byte(1) // ammo amount
					message_end()
					
					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}else{
					client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
					zp_colored_print(id, "^x04[ZP]^x01 У вас максимум гранат!")
					return
				}
			}
			else fm_give_item(id, "weapon_flashbang")
		}
		case EXTRA_PIPE:
		{
			if(g_pipe_bomb[id]>=PIPE_LIMIT){
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
		
			if (user_has_weapon(id, CSW_SMOKEGRENADE))
			{
				if((cs_get_user_bpammo(id, CSW_SMOKEGRENADE) < 3))
				{
					cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE) + 1)
					
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(AMMOID[CSW_SMOKEGRENADE]) // ammo id
					write_byte(1) // ammo amount
					message_end()
						
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					g_pipe_bomb[id]++
				}
				else
				{
					
					zp_colored_print(id, "^x04[ZP]^x01 Невозможно купить гранату! ^x04(Лимит гранат: 3)")
					return
				}
			}
			
			else {
				g_pipe_bomb[id]++
				fm_give_item(id, "weapon_smokegrenade")
			}
		}		
		default:
		{
			if (ArrayGetCell(g_extraitem_weapon, itemid) != 0)
			{
				// Get weapon's id and name
				static weaponid, wname[32]
				ArrayGetString(g_extraitem_weapon, itemid, wname, charsmax(wname))
				weaponid = cs_weapon_name_to_id(wname)
				
				// If we are giving a primary/secondary weapon
				if (MAXBPAMMO[weaponid] > 2)
				{
					// Make user drop the previous one
					if ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM) {
						drop_weapons(id, 1)
					}
					else {
						drop_weapons(id, 2)
					}
					
					// Give full BP ammo for the new one
					ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
				}
				// If we are giving a grenade which the user already owns
				else if (user_has_weapon(id, weaponid))
				{
					if((cs_get_user_bpammo(id, weaponid) < 5))
					{
						// Increase BP ammo on it instead
						cs_set_user_bpammo(id, weaponid, cs_get_user_bpammo(id, weaponid) + 1)
					
						// Flash ammo in hud
						message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
						write_byte(AMMOID[weaponid]) // ammo id
						write_byte(1) // ammo amount
						message_end()
						
						// Play clip purchase sound
						emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
						
						
					}
					else
					{
						zp_colored_print(id, "^x04[ZP]^x01 Невозможно купить гранату! ^x04(Лимит гранат: 5 раза)")
						return
					}
				}
				else fm_give_item(id, wname)
			}
			else // Custom additions
			{
                // Item selected forward
                ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
                
                // Item purchase blocked, restore buyer's ammo packs
                if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
                {
				   return
				}
            }
        }
    }
	
	if (!ignorecost) g_iToken[id] -= ArrayGetCell(g_extraitem_bolt, itemid)
	if (!ignorecost) g_ammopacks[id] -= ArrayGetCell(g_extraitem_cost, itemid)
}

public give_pipe_native(id) {
    g_pipe_bomb[id]++
	fm_give_item(id, "weapon_smokegrenade")
}

// Zombie Class Menu
public menu_zclass(id, menuid, item)
{
	// Player disconnected?
	if (!is_user_connected(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_ZCLASS)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve zombie class id
	static buffer[2], dummy, classid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	classid = buffer[0]
	
	// Store selection for the next infection
	g_zombieclassnext[id] = classid

	static name[32]
	ArrayGetString(g_zclass_name, g_zombieclassnext[id], name, charsmax(name))
	
    if(g_zombieclassnext[id] == 5 && !(get_user_flags(id) & ADMIN_LEVEL_H))
    {
       client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
       zp_colored_print(id, "^x04[ZP]^x01 Данный класс доступен только^x04 Випам^x01!")
       g_zombieclassnext[id] = 0
       show_menu_zclass(id)
    }
    else if(g_zombieclassnext[id] == 6 && !(get_user_flags(id) & ADMIN_LEVEL_E))
    {
	   client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
       zp_colored_print(id, "^x04[ZP]^x01 Данный класс доступен только^x04 Премиум^x01!")
       g_zombieclassnext[id] = 0
       show_menu_zclass(id)
    }
    else if(g_zombieclassnext[id] == 7 && !(get_user_flags(id) & ADMIN_LEVEL_B))
    {
	   client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
       zp_colored_print(id, "^x04[ZP]^x01 Данный класс доступен только^x04 Админам^x01!")
       g_zombieclassnext[id] = 0
       show_menu_zclass(id)
	}
    else if(g_zombieclassnext[id] == 8 && !(get_user_flags(id) & ADMIN_LEVEL_D))
    {
	   client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
       zp_colored_print(id, "^x04[ZP]^x01 Данный класс доступен только^x04 Боссам^x01!")
       g_zombieclassnext[id] = 0
       show_menu_zclass(id)
	}
    else 
	{
	   // Show selected zombie class info and stats
	   zp_colored_print(id, "^x04[ZP]^x01 Вы выбрали класс: ^x04%s", name)
	   zp_colored_print(id, "^x04[ZP] ^x01Здоровье: %d ^x04| ^x01Скорость: %d ^x04| ^x01Гравитация: %d ^x04| ^x01Отброс: %d%%", ArrayGetCell(g_zclass_hp, g_zombieclassnext[id]), ArrayGetCell(g_zclass_spd, g_zombieclassnext[id]),
	   floatround(Float:ArrayGetCell(g_zclass_grav, g_zombieclassnext[id]) * 800.0), id, "ZOMBIE_ATTRIB4", floatround(Float:ArrayGetCell(g_zclass_kb, g_zombieclassnext[id]) * 100.0))
	}

	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Info Menu
public menu_info(id, key)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return PLUGIN_HANDLED;
	
	static motd[1500], len
	len = 0
	
	switch (key)
	{
		case 0: // General
		{
			static weather, lighting[2]
			weather = 0
			get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))
			strtolower(lighting)
			
			len += formatex(motd[len], charsmax(motd) - len, "%L ", id, "MOTD_INFO11", "Zombie Plague", PLUGIN_VERSION, "MeRcyLeZZ")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO12")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_A")
			
			if (g_ambience_fog)
			{
				len += formatex(motd[len], charsmax(motd) - len, (weather < 1) ? " %L" : ". %L", id, "MOTD_FOG")
				weather++
			}
			if (g_ambience_rain)
			{
				len += formatex(motd[len], charsmax(motd) - len, (weather < 1) ? " %L" : ". %L", id, "MOTD_RAIN")
				weather++
			}
			if (g_ambience_snow)
			{
				len += formatex(motd[len], charsmax(motd) - len, (weather < 1) ? " %L" : ". %L", id, "MOTD_SNOW")
				weather++
			}
			if (weather < 1) len += formatex(motd[len], charsmax(motd) - len, " %L", id, "MOTD_DISABLED")
			
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_B", lighting)
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_C", id, get_pcvar_num(cvar_triggered) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (lighting[0] >= 'a' && lighting[0] <= 'd' && get_pcvar_float(cvar_thunder) > 0.0) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_D", floatround(get_pcvar_float(cvar_thunder)))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_E", id, get_pcvar_num(cvar_removedoors) > 0 ? get_pcvar_num(cvar_removedoors) > 1 ? "MOTD_DOORS" : "MOTD_ROTATING" : "MOTD_ENABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_F", id, get_pcvar_num(cvar_deathmatch) > 0 ? get_pcvar_num(cvar_deathmatch) > 1 ? get_pcvar_num(cvar_deathmatch) > 2 ? "MOTD_ENABLED" : "MOTD_DM_ZOMBIE" : "MOTD_DM_HUMAN" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_deathmatch)) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_G", floatround(get_pcvar_float(cvar_spawnprotection)))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_H", id, get_pcvar_num(cvar_randspawn) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_I", id, get_pcvar_num(cvar_extraitems) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_J", id, get_pcvar_num(cvar_zclasses) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_L", id, g_cached_customflash ? "MOTD_ENABLED" : "MOTD_DISABLED")
			
			show_motd(id, motd)
		}
		case 1: // Humans
		{
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_A", get_pcvar_num(cvar_humanhp))
			if (get_pcvar_num(cvar_humanlasthp) > 0) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_B", get_pcvar_num(cvar_humanlasthp))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_C", get_pcvar_num(cvar_humanspd))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_D", floatround(get_pcvar_float(cvar_humangravity) * 800.0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_E", id, get_pcvar_num(cvar_infammo) > 0 ? get_pcvar_num(cvar_infammo) > 1 ? "MOTD_AMMO_CLIP" : "MOTD_AMMO_BP" : "MOTD_LIMITED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_F", get_pcvar_num(cvar_ammodamage_human))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_G", id, get_pcvar_num(cvar_firegrenades) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_H", id, get_pcvar_num(cvar_frostgrenades) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_I", id, get_pcvar_num(cvar_flaregrenades) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_J", id, get_pcvar_num(cvar_knockback) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			
			show_motd(id, motd)
		}
		case 2: // Zombies
		{
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_A", ArrayGetCell(g_zclass_hp, 0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_B", floatround(float(ArrayGetCell(g_zclass_hp, 0)) * get_pcvar_float(cvar_zombiefirsthp)))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_D", ArrayGetCell(g_zclass_spd, 0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_E", floatround(Float:ArrayGetCell(g_zclass_grav, 0) * 800.0))
			if (get_pcvar_num(cvar_zombiebonushp)) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_F", get_pcvar_num(cvar_zombiebonushp))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_G", id, get_pcvar_num(cvar_zombiepainfree) > 0 ? get_pcvar_num(cvar_zombiepainfree) > 1 ? "MOTD_LASTZOMBIE" : "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_H", id, get_pcvar_num(cvar_zombiebleeding) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_I", get_pcvar_num(cvar_ammoinfect))
			
			show_motd(id, motd)
		}
		case 3: // Gameplay Modes
		{
			static nemhp[5], survhp[5]
			
			// Get nemesis and survivor health
			num_to_str(get_pcvar_num(cvar_nemhp), nemhp, charsmax(nemhp))
			num_to_str(get_pcvar_num(cvar_survhp), survhp, charsmax(survhp))
			
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_A", id, get_pcvar_num(cvar_nem) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_nem))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_B", get_pcvar_num(cvar_nemchance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_C", get_pcvar_num(cvar_nemhp) > 0 ? nemhp : "[Auto]")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_D", get_pcvar_num(cvar_nemspd))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_E", floatround(get_pcvar_float(cvar_nemgravity) * 800.0))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_F", id, g_cached_leapnemesis ? "MOTD_ENABLED" : "MOTD_DISABLED")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_G", id, get_pcvar_num(cvar_nempainfree) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			}
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_H", id, get_pcvar_num(cvar_surv) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_surv))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_I", get_pcvar_num(cvar_survchance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_J", get_pcvar_num(cvar_survhp) > 0 ? survhp : "[Auto]")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_K", get_pcvar_num(cvar_survspd))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_L", floatround(get_pcvar_float(cvar_survgravity) * 800.0))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_M", id, g_cached_leapsurvivor ? "MOTD_ENABLED" : "MOTD_DISABLED")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_N", id, get_pcvar_num(cvar_survpainfree) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			}
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_O", id, get_pcvar_num(cvar_swarm) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_swarm)) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_P", get_pcvar_num(cvar_swarmchance))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_Q", id, get_pcvar_num(cvar_multi) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_multi))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_R", get_pcvar_num(cvar_multichance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_S", floatround(get_pcvar_float(cvar_multiratio) * 100.0))
			}
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_T", id, get_pcvar_num(cvar_plague) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_plague))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_U", get_pcvar_num(cvar_plaguechance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_V", floatround(get_pcvar_float(cvar_plagueratio) * 100.0))
			}
			
			show_motd(id, motd)
		}
		default: return PLUGIN_HANDLED;
	}
	
	// Show help menu again if user wishes to read another topic
	show_menu_info(id)
	
	return PLUGIN_HANDLED;
}

// Admin Menu
public menu_admin(id, key)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return PLUGIN_HANDLED;
		
	new AdmCan=0
	if(get_user_flags(id) & ADMIN_LEVEL_B) AdmCan=1
	
    switch (key)
    {
        case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
        {
            if (AdmCan)
            {
                // Show player list for admin to pick a target
                PL_ACTION = ACTION_ZOMBIEFY_HUMANIZE
                show_menu_player_list(id)
            }
            else
            {
                zp_colored_print(id, "^x04[ZP]^x01 У вас нет доступа")
                show_menu_admin(id)
            }
        }
        case ACTION_MAKE_NEMESIS: // Nemesis command
        {
            if (AdmCan)
            {
                if(g_vip[id] == 0)
                {
                    if(!native_has_round_started())
                    {
                        PL_ACTION = ACTION_MAKE_NEMESIS
                        show_menu_player_list(id)
                    }
                    else if(native_has_round_started())
                    {
                        zp_colored_print(id, "^x04[ZP]^x01 Данный пункт работает только до начала заражения!")
                        show_menu_admin(id)
                    }
                }
                else
                {
                    zp_colored_print(id, "^x04[ZP]^x01 Будет доступно через %d раундов", g_vip[id])
                    show_menu_admin(id)
                }
            }
            else
            {
                zp_colored_print(id, "^x04[ZP]^x01 У вас нет доступа")
                show_menu_admin(id)
            }
        }
        case ACTION_MAKE_SURVIVOR: // Survivor command
        {
            if (AdmCan)
            {
                if(g_vip[id] == 0)
                {
                    if(!native_has_round_started())
                    {
                        PL_ACTION = ACTION_MAKE_SURVIVOR
                        show_menu_player_list(id)
                    }
                    else if(native_has_round_started())
                    {
                        zp_colored_print(id, "^x04[ZP]^x01 Данный пункт работает только до начала заражения!")
                        show_menu_admin(id)
                    }
                }
                else
                {
                    zp_colored_print(id, "^x04[ZP]^x01 Будет доступно через %d раундов", g_vip[id])
                    show_menu_admin(id)
                }
            }
            else
            {
                zp_colored_print(id, "^x04[ZP]^x01 У вас нет доступа")
                show_menu_admin(id)
            }
        }
        case ACTION_MODE_SWARM: // Swarm Mode command
        {
            if (AdmCan)
            {
                if (allowed_swarm())
                {
                    if(!g_vip_stop[id][0])
                    {
                        g_vip_stop[id][0] = true
                        command_swarm(id)
                    }
                }
                else 
                    zp_colored_print(id, "^x04[ZP]^x01 Недопустимая команда")
            }
            else
            zp_colored_print(id, "^x04[ZP]^x01 У вас нет доступа")
            
            show_menu_admin(id)
        }
        case ACTION_MODE_MULTI: // Multiple Infection command
        {
            if (AdmCan)
            {
                if (allowed_multi())
                {
                    if(!g_vip_stop[id][1])
                    {
                        g_vip_stop[id][1] = true
                        command_multi(id)
                    }
                }
                else
                    zp_colored_print(id, "^x04[ZP]^x01 Недопустимая команда")
            }
            else
            zp_colored_print(id, "^x04[ZP]^x01 У вас нет доступа")
            
            show_menu_admin(id)
        }
        case ACTION_MODE_PLAGUE: // Plague Mode command
        {
            if (AdmCan)
            {
                if (allowed_plague())
                {
                    if(!g_vip_stop[id][2])
                    {
                        g_vip_stop[id][2] = true
                        command_plague(id)
                    }
                }
                else
                    zp_colored_print(id, "^x04[ZP]^x01 Недопустимая команда")
            }
            else
            zp_colored_print(id, "^x04[ZP]^x01 У вас нет доступа")
            
            show_menu_admin(id)
        }
        case ACTION_RESPAWN_PLAYER: // Respawn command
        {
            if (AdmCan)
            {
                PL_ACTION = ACTION_RESPAWN_PLAYER
                show_menu_player_list(id)
            }
            else
            {
                zp_colored_print(id, "^x04[ZP]^x01 У вас нет доступа")
                show_menu_admin(id)
            }
        }
    }
    
    return PLUGIN_HANDLED;
}

// Player List Menu
public menu_player_list(id, menuid, item)
{
	// Player disconnected?
	if (!is_user_connected(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_PLAYERS)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		show_menu_admin(id)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve player id
	static buffer[2], dummy, playerid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	playerid = buffer[0]
	
	// Perform action on player
	
	// Get admin flags
	new AdmCan=0
	if(get_user_flags(id) & ADMIN_LEVEL_B) AdmCan=1
	
	// Make sure it's still connected
	if (g_isconnected[playerid])
	{
		// Perform the right action if allowed
		switch (PL_ACTION)
		{
			case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[playerid])
				{
					if (AdmCan)
					{
						if (allowed_human(playerid))
							command_human(id, playerid)
						else
							zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
					}
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				}
				else
				{
					if (AdmCan)
					{
						if (allowed_zombie(playerid))
							command_zombie(id, playerid)
						else
							zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
					}
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				}
			}
			case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (AdmCan)
				{
					if (allowed_nemesis(playerid))
						command_nemesis(id, playerid)
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (AdmCan)
				{
					if (allowed_survivor(playerid))
						command_survivor(id, playerid)
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (AdmCan)
				{
					if (allowed_respawn(playerid))
						command_respawn(id, playerid)
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
	}
	else
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
	
	menu_destroy(menuid)
	show_menu_player_list(id)
	return PLUGIN_HANDLED;
}

// CS Buy MenusMenus
public menu_cs_buy(id, key)
{
	message_begin(MSG_ONE, get_user_msgid("BuyClose"), _, id)
	message_end()
	
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Admin Commands]
=================================================================================*/

// zp_toggle [1/0]
public cmd_toggle(id, level, cid)
{
	// Check for access flag - Enable/Disable Mod
	if (!cmd_access(id, g_access_flag[ACCESS_ENABLE_MOD], cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	new arg[2]
	read_argv(1, arg, charsmax(arg))
	
	// Mod already enabled/disabled
	if (str_to_num(arg) == g_pluginenabled)
		return PLUGIN_HANDLED;
	
	// Set toggle cvar
	set_pcvar_num(cvar_toggle, str_to_num(arg))
	client_print(id, print_console, "Zombie Plague %L.", id, str_to_num(arg) ? "MOTD_ENABLED" : "MOTD_DISABLED")
	
	// Retrieve map name
	new mapname[32]
	get_mapname(mapname, charsmax(mapname))
	
	// Restart current map
	server_cmd("changelevel %s", mapname)
	
	return PLUGIN_HANDLED;
}

// zp_zombie [target]
public cmd_zombie(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
	{
		// Start Mode Infection
		if (!cmd_access(id, g_access_flag[ACCESS_MODE_INFECTION], cid, 2))
			return PLUGIN_HANDLED;
	}
	else
	{
		// Make Zombie
		if (!cmd_access(id, g_access_flag[ACCESS_MAKE_ZOMBIE], cid, 2))
			return PLUGIN_HANDLED;
	}
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be zombie
	if (!allowed_zombie(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED
	}
	
	command_zombie(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_human [target]
public cmd_human(id, level, cid)
{
	// Check for access flag - Make Human
	if (!cmd_access(id, g_access_flag[ACCESS_MAKE_HUMAN], cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be human
	if (!allowed_human(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_human(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_survivor [target]
public cmd_survivor(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
	{
		// Start Mode Survivor
		if (!cmd_access(id, g_access_flag[ACCESS_MODE_SURVIVOR], cid, 2))
			return PLUGIN_HANDLED;
	}
	else
	{
		// Make Survivor
		if (!cmd_access(id, g_access_flag[ACCESS_MAKE_SURVIVOR], cid, 2))
			return PLUGIN_HANDLED;
	}
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be survivor
	if (!allowed_survivor(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_survivor(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_nemesis [target]
public cmd_nemesis(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
	{
		// Start Mode Nemesis
		if (!cmd_access(id, g_access_flag[ACCESS_MODE_NEMESIS], cid, 2))
			return PLUGIN_HANDLED;
	}
	else
	{
		// Make Nemesis
		if (!cmd_access(id, g_access_flag[ACCESS_MAKE_NEMESIS], cid, 2))
			return PLUGIN_HANDLED;
	}
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be nemesis
	if (!allowed_nemesis(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_nemesis(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_respawn [target]
public cmd_respawn(id, level, cid)
{
	// Check for access flag - Respawn
	if (!cmd_access(id, g_access_flag[ACCESS_RESPAWN_PLAYERS], cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF)
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be respawned
	if (!allowed_respawn(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_respawn(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_swarm
public cmd_swarm(id, level, cid)
{
	// Check for access flag - Mode Swarm
	if (!cmd_access(id, g_access_flag[ACCESS_MODE_SWARM], cid, 1))
		return PLUGIN_HANDLED;
	
	// Swarm mode not allowed
	if (!allowed_swarm())
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_swarm(id)
	
	return PLUGIN_HANDLED;
}

// zp_multi
public cmd_multi(id, level, cid)
{
	// Check for access flag - Mode Multi
	if (!cmd_access(id, g_access_flag[ACCESS_MODE_MULTI], cid, 1))
		return PLUGIN_HANDLED;
	
	// Multi infection mode not allowed
	if (!allowed_multi())
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_multi(id)
	
	return PLUGIN_HANDLED;
}

// zp_plague
public cmd_plague(id, level, cid)
{
	// Check for access flag - Mode Plague
	if (!cmd_access(id, g_access_flag[ACCESS_MODE_PLAGUE], cid, 1))
		return PLUGIN_HANDLED;
	
	// Plague mode not allowed
	if (!allowed_plague())
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_plague(id)
	
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Message Hooks]
=================================================================================*/

public message_scoreattrib(msg_id, msg_dest, msg_entity)
{
	static id;
	id = get_msg_arg_int(1)
    
	if(get_user_flags(id) & ADMIN_LEVEL_H && !get_msg_arg_int(2)) set_msg_arg_int(2, ARG_BYTE, (1 << 2))
}

// Current Weapon info
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Not alive or zombie
	if (!g_isalive[msg_entity] || g_zombie[msg_entity])
		return;
	
	// Not an active weapon
	if (get_msg_arg_int(1) != 1)
		return;
	
	// Unlimited clip disabled for class
	if (!g_survivor[msg_entity] && !g_unlimited[msg_entity])
		return;
	
	// Get weapon's id
	static weapon
	weapon = get_msg_arg_int(2)
	
	// Unlimited Clip Ammo for this weapon?
	if (MAXBPAMMO[weapon] > 2)
	{
		// Max out clip ammo
		static weapon_ent
		weapon_ent = fm_cs_get_current_weapon_ent(msg_entity)
		if (pev_valid(weapon_ent)) cs_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		
		// HUD should show full clip all the time
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
	}
}

// Take off player's money
public message_money(msg_id, msg_dest, msg_entity)
{
    // Remove money setting enabled?
    if (!get_pcvar_num(cvar_removemoney))
        return PLUGIN_CONTINUE;
    
    fm_cs_set_user_money(msg_entity, 0)
    return PLUGIN_HANDLED;
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// Block flashlight battery messages if custom flashlight is enabled instead
public message_flashbat()
{
	if (g_cached_customflash)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Flashbangs should only affect zombies
public message_screenfade(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200)
		return PLUGIN_CONTINUE;
	
	// Nemesis shouldn't be FBed
	if (g_zombie[msg_entity] && !g_nemesis[msg_entity])
	{
		// Set flash color to nighvision's
		set_msg_arg_int(4, get_msg_argtype(4), 255)
		set_msg_arg_int(5, get_msg_argtype(5), 255)
		set_msg_arg_int(6, get_msg_argtype(6), 255)
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_HANDLED;
}

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public message_nvgtoggle()
{
	return PLUGIN_HANDLED;
}

// Set correct model on player corpses
public message_clcorpse()
{
	set_msg_arg_string(1, g_playermodel[get_msg_arg_int(12)])
}

// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public message_hostagepos()
{
	return PLUGIN_HANDLED;
}

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		logevent_round_end()
		g_scorehumans = 0
		g_scorezombies = 0
	}
	// Game commencing, reset scores only (round end is automatically triggered)
	else if (equal(textmsg, "#Game_Commencing"))
	{
		g_gamecommencing = true
		g_scorehumans = 0
		g_scorezombies = 0
	}
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	
	switch (team[0])
	{
		// CT
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_scorehumans)
		// Terrorist
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_scorezombies)
	}
}

// Team Switch (or player joining a team for first time)
public message_teaminfo(msg_id, msg_dest)
{
	// Only hook global messages
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return;
	
	// Don't pick up our own TeamInfo messages for this player (bugfix)
	if (g_switchingteam) return;
	
	// Get player's id
	static id
	id = get_msg_arg_int(1)
	
	// Invalid player id? (bugfix)
	if (!(1 <= id <= g_maxplayers)) return;
	
	// Round didn't start yet, nothing to worry about
	if (g_newround) return;
	
	// Get his new team
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	
	// Perform some checks to see if they should join a different team instead
	switch (team[0])
	{
		case 'C': // CT
		{
			if (g_survround && fnGetHumans()) // survivor alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
			else if (!fnGetZombies()) // no zombies alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
		}
		case 'T': // Terrorist
		{
			if ((g_swarmround || g_survround) && fnGetHumans()) // survivor alive or swarm round w/ humans --> spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
			}
			else if (fnGetZombies()) // zombies alive --> switch to CT
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				set_msg_arg_string(2, "CT")
			}
		}
	}
}

public message_statusicon(msg_id, msg_dest, msg_entity)
{
	if (!is_user_alive(msg_entity)||get_msg_arg_int(1)!= 1)
		return
	
	static sprite[10]
	
	get_msg_arg_string(2, sprite, charsmax(sprite))
	
	if (!equal(sprite, "buyzone"))
		return
	
	set_msg_arg_int(3, get_msg_argtype(1), 0)
	set_msg_arg_int(4, get_msg_argtype(1), 0)
	set_msg_arg_int(5, get_msg_argtype(1), 0)
}

/*================================================================================
 [Main Functions]
=================================================================================*/

// Make Zombie Task
public make_zombie_task()
{
	// Call make a zombie with no specific mode
	if(g_nemesis_mod == 10) 
		make_a_zombie(MODE_NEMESIS, fnGetRandomAlive(random_num(1, fnGetAlive())))
	else if(g_survivor_mod == 10)
		make_a_zombie(MODE_SURVIVOR, fnGetRandomAlive(random_num(1, fnGetAlive())))
	else if(fnGetPlaying() >=15)
		make_a_zombie(MODE_NONE, fnGetRandomAlive(random_num(2, fnGetAlive())))
	else if(fnGetPlaying() >=25)
		make_a_zombie(MODE_NONE, fnGetRandomAlive(random_num(3, fnGetAlive())))
	else if(fnGetPlaying() >=32)
		make_a_zombie(MODE_NONE, fnGetRandomAlive(random_num(4, fnGetAlive())))
	else make_a_zombie(MODE_NONE, 0)
}

// Make a Zombie Function
make_a_zombie(mode, id)
{
	// Get alive players count
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	// Not enough players, come back later!
    /*-----BossManager(start)-----*/
    if (iPlayersnum < 1 || Map_Boss /*Block Infection*/)
    /*-----BossManager(End)-----*/
	{
		set_task(2.0, "make_zombie_task", TASK_MAKEZOMBIE)
		return;
	}
	
	// Round started!
	g_newround = false
	
	// Set up some common vars
	static forward_id, sound[64], iZombies, iMaxZombies
	
	if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SURVIVOR) && random_num(1, get_pcvar_num(cvar_survchance)) == get_pcvar_num(cvar_surv) && iPlayersnum >= get_pcvar_num(cvar_survminplayers)) || mode == MODE_SURVIVOR)
	{
		// Survivor Mode
		g_survround = true
		g_lastmode = MODE_SURVIVOR
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a survivor
		humanme(id, 1, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Survivor or already a zombie
			if (g_survivor[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		// Play survivor sound
		ArrayGetString(sound_survivor, random_num(0, ArraySize(sound_survivor) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Survivor HUD notice
		set_dhudmessage(0, 255, 130, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0)
        show_dhudmessage(0, "ВНИМАНИЕ^nОН ПРИШЕЛ СПАСТИ НАС - %s^nГЕРОЙ", g_playername[forward_id])
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SURVIVOR, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SWARM) && random_num(1, get_pcvar_num(cvar_swarmchance)) == get_pcvar_num(cvar_swarm) && iPlayersnum >= get_pcvar_num(cvar_swarmminplayers)) || mode == MODE_SWARM)
	{		
		// Swarm Mode
		g_swarmround = true
		g_lastmode = MODE_SWARM
		
		// Make sure there are alive players on both teams (BUGFIX)
		if (!fnGetAliveTs())
		{
			// Move random player to T team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			fm_user_team_update(id)
		}
		else if (!fnGetAliveCTs())
		{
			// Move random player to CT team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
		
		// Turn every T into a zombie
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Not a Terrorist
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_T)
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		// Play swarm sound
		ArrayGetString(sound_swarm, random_num(0, ArraySize(sound_swarm) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Swarm HUD notice
		set_dhudmessage(200, 40, 40, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0)
        show_dhudmessage(0, "ВНИМАНИЕ^nВИРУС МУТИРОВАЛ...^nКУЧА НА КУЧУ")
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SWARM, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_MULTI) && random_num(1, get_pcvar_num(cvar_multichance)) == get_pcvar_num(cvar_multi) && floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil) >= 2 && floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil) < iPlayersnum && iPlayersnum >= get_pcvar_num(cvar_multiminplayers)) || mode == MODE_MULTI)
	{
		// Multi Infection Mode
		g_lastmode = MODE_MULTI
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, 0, 1, 0)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who aren't zombies
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play multi infection sound
		ArrayGetString(sound_multi, random_num(0, ArraySize(sound_multi) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Multi Infection HUD notice
		set_dhudmessage(0, 205, 102, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0)
        show_dhudmessage(0, "ВНИМАНИЕ^nВИРУС РАСПОЛЗАЕТСЯ^nМАССОВОЕ ЗАРАЖЕНИЕ")
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_MULTI, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_PLAGUE) && random_num(1, get_pcvar_num(cvar_plaguechance)) == get_pcvar_num(cvar_plague) && floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil) >= 1
	&& iPlayersnum-(get_pcvar_num(cvar_plaguesurvnum)+get_pcvar_num(cvar_plaguenemnum)+floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)) >= 1 && iPlayersnum >= get_pcvar_num(cvar_plagueminplayers)) || mode == MODE_PLAGUE)
	{
		// Plague Mode
		g_plagueround = true
		g_lastmode = MODE_PLAGUE
		
		// Turn specified amount of players into Survivors
		static iSurvivors, iMaxSurvivors
		iMaxSurvivors = get_pcvar_num(cvar_plaguesurvnum)
		iSurvivors = 0
		
		while (iSurvivors < iMaxSurvivors)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor?
			if (g_survivor[id])
				continue;
			
			// If not, turn him into one
			humanme(id, 1, 0)
			iSurvivors++
			
			// Apply survivor health multiplier
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_plaguesurvhpmulti)))
		}
		
		// Turn specified amount of players into Nemesis
		static iNemesis, iMaxNemesis
		iMaxNemesis = get_pcvar_num(cvar_plaguenemnum)
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (g_survivor[id] || g_nemesis[id])
				continue;
			
			// If not, turn him into one
			zombieme(id, 0, 1, 0, 0)
			iNemesis++
			
			// Apply nemesis health multiplier
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_plaguenemhpmulti)))
		}
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, 0, 1, 0)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play plague sound
		ArrayGetString(sound_plague, random_num(0, ArraySize(sound_plague) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Plague HUD notice
		set_dhudmessage(205, 149, 12, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0)
        show_dhudmessage(0, "ВНИМАНИЕ^nВИРУС ОБРЕЛ ПОЛНУЮ ФОРМУ^nЧУМА")
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_PLAGUE, 0);
	}
	else
	{
		// Single Infection Mode or Nemesis Mode
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_NEMESIS) && random_num(1, get_pcvar_num(cvar_nemchance)) == get_pcvar_num(cvar_nem) && iPlayersnum >= get_pcvar_num(cvar_nemminplayers)) || mode == MODE_NEMESIS)
		{
			// Nemesis Mode
			g_nemround = true
			g_lastmode = MODE_NEMESIS
			
			// Turn player into nemesis
			zombieme(id, 0, 1, 0, 0)
		}
		else
		{
			// Single Infection Mode
			g_lastmode = MODE_INFECTION
			
			// Turn player into the first zombie
			zombieme(id, 0, 0, 0, 0)
		}
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First zombie/nemesis
			if (g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		if (g_nemround)
		{
			// Play Nemesis sound
			ArrayGetString(sound_nemesis, random_num(0, ArraySize(sound_nemesis) - 1), sound, charsmax(sound))
			PlaySound(sound);
			
			// Show Nemesis HUD notice
			set_dhudmessage(205, 38, 38, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0)
            show_dhudmessage(0, "ВНИМАНИЕ^nСАМ ДЬЯВОЛ - %s^nВЫРВАЛСЯ ИЗ АДА...", g_playername[forward_id])
			
			// Mode fully started!
			g_modestarted = true
			
			// Round start forward
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_NEMESIS, forward_id);
		}
		else
		{
			// Show First Zombie HUD notice
			set_dhudmessage(205, 0, 205, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 5.0, 1.0, 1.0)
            show_dhudmessage(0, "ВНИМАНИЕ^nВИРУС ПОРАЗИЛ ТЕЛО - %s^nОН ПОЧТИ НЕВИДИМ...", g_playername[forward_id])
			
			// Mode fully started!
			g_modestarted = true
			
			// Round start forward
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_INFECTION, forward_id);
		}
	}
	
	// Start ambience sounds after a mode begins
	if ((g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && g_nemround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && g_survround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && g_swarmround) || (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && g_plagueround) || (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && !g_nemround && !g_survround && !g_swarmround && !g_plagueround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		set_task(2.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS)
	}
}

public zp_buy_random_item(id)
{
	new item=random_num(6, g_extraitem_i-1) 
	
	buy_extra_item(id, item, 1)
	
	new name[64]
	ArrayGetString(g_extraitem_name, item, name, charsmax(name))
	
	replace(name, charsmax(name), "\r", "")
	replace(name, charsmax(name), "\y", "")
	replace(name, charsmax(name), "\w", "")
	replace(name, charsmax(name), "\d", "")
	
	zp_colored_print(id, "^x04[ZP]^x01 Вы выиграли оружие: %s", name)
}

// Zombie Me Function (player id, infector, turn into a nemesis, silent mode, deathmsg and rewards)
zombieme(id, infector, nemesis, silentmode, rewards)
{
	// User infect attempt forward
	ExecuteForward(g_fwUserInfect_attempt, g_fwDummyResult, id, infector, nemesis)
	
	// One or more plugins blocked the infection. Only allow this after making sure it's
	// not going to leave us with no zombies. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first zombie e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetZombies() > g_lastplayerleaving)
		return;
	
	// Pre user infect forward
	ExecuteForward(g_fwUserInfected_pre, g_fwDummyResult, id, infector, nemesis)
	
    // Show zombie class menu if they haven't chosen any (e.g. just connected)
    if (g_zombieclassnext[id] == ZCLASS_NONE && get_pcvar_num(cvar_zclasses))
        set_task(0.2, "show_menu_zclass", id)
	
	// Set selected zombie class
	g_zombieclass[id] = g_zombieclassnext[id]
	// If no class selected yet, use the first (default) one
	if (g_zombieclass[id] == ZCLASS_NONE) g_zombieclass[id] = 0
	
	// Way to go...
	g_zombie[id] = true
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	
	// Remove survivor's aura (bugfix)
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_BRIGHTLIGHT)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Show deathmsg and reward infector?
	if (rewards && infector)
	{
		// Send death notice and fix the "dead" attrib on scoreboard
		SendDeathMsg(infector, id)
		FixDeadAttrib(id)
		
		// Reward frags, deaths, health, and ammo packs
        UpdateFrags(infector, id, get_pcvar_num(cvar_fragsinfect), 1, 1)
        g_ammopacks[infector] += get_pcvar_num(cvar_ammoinfect)
		fm_set_user_health(infector, pev(infector, pev_health) + 1000)		
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, infector)
		write_short(UNIT_SECOND)
		write_short(0)
		write_short(FFADE_IN)
		write_byte(255)
		write_byte(130)
		write_byte(150)
		write_byte(200)
		message_end()
	}
	
	if(infector&&g_firstzombie[infector]){
		g_firstzombie[infector]=0
		fm_set_rendering(infector)
	}
	
	// Cache speed, knockback, and name for player's class
	g_zombie_spd[id] = float(ArrayGetCell(g_zclass_spd, g_zombieclass[id]))
	g_zombie_knockback[id] = Float:ArrayGetCell(g_zclass_kb, g_zombieclass[id])
	ArrayGetString(g_zclass_name, g_zombieclass[id], g_zombie_classname[id], charsmax(g_zombie_classname[]))
	
	// Set zombie attributes based on the mode
	static sound[64]
	if (!silentmode)
	{
		if (nemesis)
		{
			// Nemesis
			g_nemesis[id] = true
			
			get_user_name(id, g_nem_name, 31)
			
			// Set health [0 = auto]
			if (get_pcvar_num(cvar_nemhp) == 0)
			{
				if (get_pcvar_num(cvar_nembasehp) == 0)
					fm_set_user_health(id, ArrayGetCell(g_zclass_hp, 0) * fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_nembasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_nemhp))		
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_nemgravity))
			else g_frozen_gravity[id] = get_pcvar_float(cvar_nemgravity)
			
			// Set nemesis maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		}
		else if (fnGetZombies() == 1)
		{
			// First zombie
			g_firstzombie[id] = true
			
			// Set health
			fm_set_user_health(id, floatround(float(ArrayGetCell(g_zclass_hp, g_zombieclass[id])) * get_pcvar_float(cvar_zombiefirsthp)))
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
			else g_frozen_gravity[id] = Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id])
			
			// Set zombie maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Infection sound
			static pointers[10], end
			ArrayGetArray(pointer_class_sound_infect, g_zombieclass[id], pointers)

			for (new i; i < 10; i++)
			{
				if (pointers[i] != -1)
					end = i
			}

			ArrayGetString(class_sound_infect, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
			
			emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			ArrayGetString(sound_firstzm, random_num(0, ArraySize(sound_firstzm) - 1), sound, charsmax(sound))
			PlaySound(sound)
		}
		else
		{
			// Infected by someone
			
			// Set health
			fm_set_user_health(id, ArrayGetCell(g_zclass_hp, g_zombieclass[id]))
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
			else g_frozen_gravity[id] = Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id])
			
			// Set zombie maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Infection sound
			static pointers[10], end
			ArrayGetArray(pointer_class_sound_infect, g_zombieclass[id], pointers)

			for (new i; i < 10; i++)
			{
				if (pointers[i] != -1)
					end = i
			}

			ArrayGetString(class_sound_infect, random_num(pointers[0], pointers[end]), sound, charsmax(sound))
			
			emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	else
	{
		// Silent mode, no HUD messages, no infection sounds
		
		// Set health
		fm_set_user_health(id, ArrayGetCell(g_zclass_hp, g_zombieclass[id]))
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
		else g_frozen_gravity[id] = Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id])
		
		// Set zombie maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	}
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	
	// Switch to T
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_T) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (g_nemesis[id])
		{
			iRand = random_num(0, ArraySize(model_nemesis) - 1)
			ArrayGetString(model_nemesis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nemesis, iRand))
		}
		else
		{
			iRand = random_num(ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]), ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]) - 1)
			ArrayGetString(g_zclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_zclass_modelindex, iRand))
		}
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		// Nemesis glow / remove glow on player model entity, unless frozen
		if (!g_frozen[id])
		{
			fm_set_rendering(g_ent_playermodel[id])
		}
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (g_nemesis[id])
		{
			size = ArraySize(model_nemesis)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_nemesis, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_nemesis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nemesis, iRand))
			}
		}
		else
		{
				for (i = ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]); i < ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]); i++)
				{
					ArrayGetString(g_zclass_playermodel, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]), ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]) - 1)
					ArrayGetString(g_zclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_zclass_modelindex, iRand))
				}
		}
		
		// Need to change the model?
		if (!already_has_model)
		{
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
            fm_cs_set_user_model(id+TASK_MODEL)
		}
		
		// Nemesis glow / remove glow, unless frozen
		if (!g_frozen[id])
		{
			fm_set_rendering(id)
		}
	}
	
	// Remove any zoom (bugfix)
	cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
	
	// Remove armor
	cs_set_user_armor(id, 0, CS_ARMOR_NONE)
	
	// Drop weapons when infected
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip zombies from guns and give them a knife
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")

	if(!g_nemesis[id] && !g_survround && !g_nemround)
	{
		fm_give_item(id, "weapon_hegrenade")
		engclient_cmd(id, "weapon_knife")
	}
	
	// Fancy effects
	infection_effects(id)
		
	// Turn off zombie's flashlight
	turn_off_flashlight(id)
	
	// Post user infect forward
	ExecuteForward(g_fwUserInfected_post, g_fwDummyResult, id, infector, nemesis)
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Function Human Me (player id, turn into a survivor, silent mode)
humanme(id, survivor, silentmode)
{
	// User humanize attempt forward
	ExecuteForward(g_fwUserHumanize_attempt, g_fwDummyResult, id, survivor)
	
	// One or more plugins blocked the "humanization". Only allow this after making sure it's
	// not going to leave us with no humans. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first survivor e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetHumans() > g_lastplayerleaving)
		return;
	
	// Pre user humanize forward
	ExecuteForward(g_fwUserHumanized_pre, g_fwDummyResult, id, survivor)
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_NVISION)
	
	// Reset some vars
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_canbuy[id] = true
	g_buytime[id] = get_gametime()
	
	// Remove survivor's aura (bugfix)
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_BRIGHTLIGHT)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Set human attributes based on the mode
	if (survivor)
	{
		// Survivor
		g_survivor[id] = true
		
		get_user_name(id, g_surv_name, 31)
		
		fm_set_user_health(id, 5000)
		
		set_pev(id, pev_armorvalue, 500.0)
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_survgravity))
		else g_frozen_gravity[id] = get_pcvar_float(cvar_survgravity)
		
		// Set survivor maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
				
		// Turn off his flashlight
		turn_off_flashlight(id)		
	}
	else
	{
		// Human taking an antidote
		
		// Set health
		fm_set_user_health(id, get_pcvar_num(cvar_humanhp))
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_humangravity))
		else g_frozen_gravity[id] = get_pcvar_float(cvar_humangravity)
		
		// Set human maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		
		// Show custom buy menu?
		if (!WPN_AUTO_ON)
			set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
		
		// Silent mode = no HUD messages, no antidote sound
		if (!silentmode)
		{
			// Antidote sound
			static sound[64]
			ArrayGetString(sound_antidote, random_num(0, ArraySize(sound_antidote) - 1), sound, charsmax(sound))
			PlaySound(sound)
		}
	}
	
	// Switch to CT
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (g_survivor[id])
		{
			iRand = random_num(0, ArraySize(model_survivor) - 1)
			ArrayGetString(model_survivor, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_survivor, iRand))
		}
        else
		{
			iRand = random_num(0, size - 1)
		    ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))			
			set_pev(id, pev_body, zp_get_character(id))
	    }  
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		// Set survivor glow / remove glow on player model entity, unless frozen
		if (!g_frozen[id])
		{
			fm_set_rendering(g_ent_playermodel[id])
		}
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (g_survivor[id])
		{
			size = ArraySize(model_survivor)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_survivor, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_survivor, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_survivor, iRand))
			}
		}
		else
		{
			    size = ArraySize(model_admin_human)
			    for (i = 0; i < size; i++)
			    {
				   ArrayGetString(model_admin_human, i, tempmodel, charsmax(tempmodel))
				   if (equal(currentmodel, tempmodel)) already_has_model = true
			    }
						
			    if (!already_has_model)
			    {
				   iRand = random_num(0, size - 1)
				   ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				   if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))			
				   set_pev(id, pev_body, zp_get_character(id))
			    }
         }			
	}
		
	if (!already_has_model)
	{
		if (g_newround)
			set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
		else
			fm_user_model_update(id+TASK_MODEL)
	}
	
	// Post user humanize forward
	ExecuteForward(g_fwUserHumanized_post, g_fwDummyResult, id, survivor)
	
	// Last Zombie Check
	fnCheckLastZombie()
}

/*================================================================================
 [Other Functions and Tasks]
=================================================================================*/

public cache_cvars()
{
	g_cached_customflash = get_pcvar_num(cvar_customflash)
	g_cached_leapzombies = get_pcvar_num(cvar_leapzombies)
	g_cached_leapzombiescooldown = get_pcvar_float(cvar_leapzombiescooldown)
	g_cached_leapnemesis = get_pcvar_num(cvar_leapnemesis)
	g_cached_leapnemesiscooldown = get_pcvar_float(cvar_leapnemesiscooldown)
	g_cached_leapsurvivor = get_pcvar_num(cvar_leapsurvivor)
	g_cached_leapsurvivorcooldown = get_pcvar_float(cvar_leapsurvivorcooldown)
	g_cached_buytime = get_pcvar_float(cvar_buyzonetime)
}

load_customization_from_files()
{
	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_CUSTOMIZATION_FILE)
	
	// File not present
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}
	
	// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], section
	
	// Open customization file for reading
	new file = fopen(path, "rt")
	
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// New section starting
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		
		// Get key and value(s)
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		
		// Trim spaces
		trim(key)
		trim(value)
		
		switch (section)
		{
			case SECTION_ACCESS_FLAGS:
			{
				if (equal(key, "ENABLE/DISABLE MOD"))
					g_access_flag[ACCESS_ENABLE_MOD] = read_flags(value)
				else if (equal(key, "ADMIN MENU"))
					g_access_flag[ACCESS_ADMIN_MENU] = read_flags(value)
				else if (equal(key, "START MODE INFECTION"))
					g_access_flag[ACCESS_MODE_INFECTION] = read_flags(value)
				else if (equal(key, "START MODE NEMESIS"))
					g_access_flag[ACCESS_MODE_NEMESIS] = read_flags(value)
				else if (equal(key, "START MODE SURVIVOR"))
					g_access_flag[ACCESS_MODE_SURVIVOR] = read_flags(value)
				else if (equal(key, "START MODE SWARM"))
					g_access_flag[ACCESS_MODE_SWARM] = read_flags(value)
				else if (equal(key, "START MODE MULTI"))
					g_access_flag[ACCESS_MODE_MULTI] = read_flags(value)
				else if (equal(key, "START MODE PLAGUE"))
					g_access_flag[ACCESS_MODE_PLAGUE] = read_flags(value)
				else if (equal(key, "MAKE ZOMBIE"))
					g_access_flag[ACCESS_MAKE_ZOMBIE] = read_flags(value)
				else if (equal(key, "MAKE HUMAN"))
					g_access_flag[ACCESS_MAKE_HUMAN] = read_flags(value)
				else if (equal(key, "MAKE NEMESIS"))
					g_access_flag[ACCESS_MAKE_NEMESIS] = read_flags(value)
				else if (equal(key, "MAKE SURVIVOR"))
					g_access_flag[ACCESS_MAKE_SURVIVOR] = read_flags(value)
				else if (equal(key, "RESPAWN PLAYERS"))
					g_access_flag[ACCESS_RESPAWN_PLAYERS] = read_flags(value)
				else if (equal(key, "ADMIN MODELS"))
					g_access_flag[ACCESS_ADMIN_MODELS] = read_flags(value)
			}
			case SECTION_PLAYER_MODELS:
			{
			    if (equal(key, "NEMESIS"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_nemesis, key)
					}
				}
				else if (equal(key, "SURVIVOR"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_survivor, key)
					}
				}
				else if (equal(key, "PRIVILEGES"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_admin_human, key)
					}
				}
				else if (equal(key, "PRIVILEGES2"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_human, key)
					}
				}
				else if (equal(key, "FORCE CONSISTENCY"))
					g_force_consistency = str_to_num(value)
				else if (equal(key, "SAME MODELS FOR ALL"))
					g_same_models_for_all = str_to_num(value)
				else if (g_same_models_for_all && equal(key, "ZOMBIE"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(g_zclass_playermodel, key)
						
						// Precache model and retrieve its modelindex
						formatex(linedata, charsmax(linedata), "models/player/%s/%s.mdl", key, key)
						ArrayPushCell(g_zclass_modelindex, engfunc(EngFunc_PrecacheModel, linedata))
						if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, linedata)
						if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, linedata)
						// Precache modelT.mdl files too
						copy(linedata[strlen(linedata)-4], charsmax(linedata) - (strlen(linedata)-4), "T.mdl")
						if (file_exists(linedata)) engfunc(EngFunc_PrecacheModel, linedata)
					}
				}
			}
			case SECTION_WEAPON_MODELS:
			{
				if (equal(key, "V_KNIFE 1"))
					copy(model_vknife_human[0], 63, value)
				else if (equal(key, "V_KNIFE 2"))
					copy(model_vknife_human[1], 63, value)
				else if (equal(key, "V_KNIFE 3"))
					copy(model_vknife_human[2], 63, value)
				else if (equal(key, "V_KNIFE 4"))
					copy(model_vknife_human[3], 63, value)
				else if (equal(key, "V_KNIFE 5"))
					copy(model_vknife_human[4], 63, value)
				else if (equal(key, "V_KNIFE 6"))
					copy(model_vknife_human[5], 63, value)
				else if (equal(key, "V_KNIFE 7"))
					copy(model_vknife_human[6], 63, value)
				
				if (equal(key, "P_KNIFE 1"))
					copy(model_pknife_human[0], 63, value)
				else if (equal(key, "P_KNIFE 2"))
					copy(model_pknife_human[1], 63, value)
				else if (equal(key, "P_KNIFE 3"))
					copy(model_pknife_human[2], 63, value)
				else if (equal(key, "P_KNIFE 4"))
					copy(model_pknife_human[3], 63, value)
				else if (equal(key, "P_KNIFE 5"))
					copy(model_pknife_human[4], 63, value)
				else if (equal(key, "P_KNIFE 6"))
					copy(model_pknife_human[5], 63, value)
				else if (equal(key, "P_KNIFE 7"))
					copy(model_pknife_human[6], 63, value)
					
				if (equal(key, "V_KNIFE NEMESIS"))
					copy(model_vknife_nemesis, charsmax(model_vknife_nemesis), value)
				else if (equal(key, "V_GRENADE FIRE"))
					copy(model_grenade_fire, charsmax(model_grenade_fire), value)
				else if (equal(key, "V_GRENADE FROST"))
					copy(model_grenade_frost, charsmax(model_grenade_frost), value)
				else if (equal(key, "V_GRENADE ANTIDOTE"))
					copy(model_grenade_antidote, charsmax(model_grenade_antidote), value)
				else if (equal(key, "V_GRENADE PIPE"))
					copy(model_grenade_pipe, charsmax(model_grenade_pipe), value)
				else if (equal(key, "P_GRENADE FIRE"))
					copy(model_pgrenade_fire, charsmax(model_pgrenade_fire), value)
				else if (equal(key, "P_GRENADE FROST"))
					copy(model_pgrenade_frost, charsmax(model_pgrenade_frost), value)
				else if (equal(key, "P_GRENADE ANTIDOTE"))
					copy(model_pgrenade_antidote, charsmax(model_pgrenade_antidote), value)
				else if (equal(key, "P_GRENADE PIPE"))
					copy(model_pgrenade_pipe, charsmax(model_pgrenade_pipe), value)
				else if (equal(key, "W_GRENADE PIPE"))
					copy(model_wgrenade_pipe, charsmax(model_wgrenade_pipe), value)
				else if (equal(key, "W_GRENADE FIRE"))
					copy(model_wgrenade_fire, charsmax(model_wgrenade_fire), value)
				else if (equal(key, "W_GRENADE FROST"))
					copy(model_wgrenade_frost, charsmax(model_wgrenade_frost), value)
				else if (equal(key, "W_GRENADE ANTIDOTE"))
					copy(model_wgrenade_antidote, charsmax(model_wgrenade_antidote), value)
			}
			case SECTION_GRENADE_SPRITES:
			{
				if (equal(key, "TRAIL"))
					copy(sprite_grenade_trail, charsmax(sprite_grenade_trail), value)
				else if (equal(key, "RING"))
					copy(sprite_grenade_ring, charsmax(sprite_grenade_ring), value)
				else if (equal(key, "FIRE"))
					copy(sprite_grenade_fire, charsmax(sprite_grenade_fire), value)
				else if (equal(key, "SMOKE"))
					copy(sprite_grenade_smoke, charsmax(sprite_grenade_smoke), value)
				else if (equal(key, "GLASS"))
					copy(sprite_grenade_glass, charsmax(sprite_grenade_glass), value)
				else if (equal(key, "EXPLODE FIRE"))
					copy(sprite_grenade_explofire, charsmax(sprite_grenade_explofire), value)	
				else if (equal(key, "EXPLODE FROST"))
					copy(sprite_grenade_explofrost, charsmax(sprite_grenade_explofrost), value)	
				else if (equal(key, "EXPLODE ANTIDOTE"))
					copy(sprite_grenade_exploantidote, charsmax(sprite_grenade_exploantidote), value)
				else if (equal(key, "EXPLODE ZBOMB"))
					copy(sprite_grenade_explozbomb, charsmax(sprite_grenade_explozbomb), value)
				else if (equal(key, "GIBS FIRE"))
					copy(sprite_grenade_gibsfire, charsmax(sprite_grenade_gibsfire), value)	
				else if (equal(key, "GIBS FROST"))
					copy(sprite_grenade_gibsfrost, charsmax(sprite_grenade_gibsfrost), value)
			}
			case SECTION_SOUNDS:
			{
				if (equal(key, "KNIFE_DRAW 1"))
					copy(g_draw_sound[0], 63, value)
				else if (equal(key, "KNIFE_HIT_N 1"))
					copy(g_hit_normal_sound[0], 63, value)
				else if (equal(key, "KNIFE_HIT_S 1"))
					copy(g_hit_stab_sound[0], 63, value)
				else if (equal(key, "KNIFE_WALL 1"))
					copy(g_hit_wall_sound[0], 63, value)
				else if (equal(key, "KNIFE_MISS 1"))
					copy(g_hit_miss_sound[0], 63, value)
				
				else if (equal(key, "KNIFE_DRAW 2"))
					copy(g_draw_sound[1], 63, value)
				else if (equal(key, "KNIFE_HIT_N 2"))
					copy(g_hit_normal_sound[1], 63, value)
				else if (equal(key, "KNIFE_HIT_S 2"))
					copy(g_hit_stab_sound[1], 63, value)
				else if (equal(key, "KNIFE_WALL 2"))
					copy(g_hit_wall_sound[1], 63, value)
				else if (equal(key, "KNIFE_MISS 2"))
					copy(g_hit_miss_sound[1], 63, value)
					
				else if (equal(key, "KNIFE_DRAW 3"))
					copy(g_draw_sound[2], 63, value)
				else if (equal(key, "KNIFE_HIT_N 3"))
					copy(g_hit_normal_sound[2], 63, value)
				else if (equal(key, "KNIFE_HIT_S 3"))
					copy(g_hit_stab_sound[2], 63, value)
				else if (equal(key, "KNIFE_WALL 3"))
					copy(g_hit_wall_sound[2], 63, value)
				else if (equal(key, "KNIFE_MISS 3"))
					copy(g_hit_miss_sound[2], 63, value)
					
				else if (equal(key, "KNIFE_DRAW 4"))
					copy(g_draw_sound[3], 63, value)
				else if (equal(key, "KNIFE_HIT_N 4"))
					copy(g_hit_normal_sound[3], 63, value)
				else if (equal(key, "KNIFE_HIT_S 4"))
					copy(g_hit_stab_sound[3], 63, value)
				else if (equal(key, "KNIFE_WALL 4"))
					copy(g_hit_wall_sound[3], 63, value)
				else if (equal(key, "KNIFE_MISS 4"))
					copy(g_hit_miss_sound[3], 63, value)
				
				else if (equal(key, "KNIFE_DRAW 5"))
					copy(g_draw_sound[4], 63, value)
				else if (equal(key, "KNIFE_HIT_N 5"))
					copy(g_hit_normal_sound[4], 63, value)
				else if (equal(key, "KNIFE_HIT_S 5"))
					copy(g_hit_stab_sound[4], 63, value)
				else if (equal(key, "KNIFE_WALL 5"))
					copy(g_hit_wall_sound[4], 63, value)
				else if (equal(key, "KNIFE_MISS 5"))
					copy(g_hit_miss_sound[4], 63, value)	
					
				else if (equal(key, "KNIFE_DRAW 6"))
					copy(g_draw_sound[5], 63, value)
				else if (equal(key, "KNIFE_HIT_N 6"))
					copy(g_hit_normal_sound[5], 63, value)
				else if (equal(key, "KNIFE_HIT_S 6"))
					copy(g_hit_stab_sound[5], 63, value)
				else if (equal(key, "KNIFE_WALL 6"))
					copy(g_hit_wall_sound[5], 63, value)
				else if (equal(key, "KNIFE_MISS 6"))
					copy(g_hit_miss_sound[5], 63, value)
					
				else if (equal(key, "KNIFE_DRAW 7"))
					copy(g_draw_sound[6], 63, value)
				else if (equal(key, "KNIFE_HIT_N 7"))
					copy(g_hit_normal_sound[6], 63, value)
				else if (equal(key, "KNIFE_HIT_S 7"))
					copy(g_hit_stab_sound[6], 63, value)
				else if (equal(key, "KNIFE_WALL 7"))
					copy(g_hit_wall_sound[6], 63, value)
				else if (equal(key, "KNIFE_MISS 7"))
					copy(g_hit_miss_sound[6], 63, value)
					
				else if (equal(key, "FIRST ZOMBIE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_firstzm, key)
					}
				}
				else if (equal(key, "LAST MAN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_lastman, key)
					}
				}	
				else if (equal(key, "HEADSHOT"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_headshot, key)
					}
				}
				
				else if (equal(key, "WIN ZOMBIES"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_zombies, key)
						ArrayPushCell(sound_win_zombies_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (equal(key, "WIN HUMANS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_humans, key)
						ArrayPushCell(sound_win_humans_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (equal(key, "WIN NO ONE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_no_one, key)
						ArrayPushCell(sound_win_no_one_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (equal(key, "NEMESIS HIT STAB"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_hit_stab, key)
					}
				}
				else if (equal(key, "NEMESIS HIT NORMAL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_hit_normal, key)
					}
				}
				else if (equal(key, "NEMESIS MISS WALL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_miss_wall, key)
					}
				}
				else if (equal(key, "NEMESIS MISS SLASH"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_miss_slash, key)
					}
				}
				else if (equal(key, "NEMESIS PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_pain, key)
					}
				}
				else if (equal(key, "NEMESIS DIE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_die, key)
					}
				}
				else if (equal(key, "NEMESIS PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_pain, key)
					}
				}
				else if (equal(key, "ZOMBIE MADNESS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_madness, key)
					}
				}
				else if (equal(key, "ROUND NEMESIS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_nemesis, key)
					}
				}
				else if (equal(key, "ROUND SURVIVOR"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_survivor, key)
					}
				}
				else if (equal(key, "ROUND SWARM"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_swarm, key)
					}
				}
				else if (equal(key, "ROUND MULTI"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_multi, key)
					}
				}
				else if (equal(key, "ROUND PLAGUE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_plague, key)
					}
				}
				else if (equal(key, "GRENADE ZBOMB EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_zbomb, key)
					}
				}
				else if (equal(key, "GRENADE ANTIDOTE EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_antidote, key)
					}
				} 
				else if (equal(key, "GRENADE FIRE EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_fire, key)
					}
				}
				else if (equal(key, "GRENADE FIRE PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_fire_player, key)
					}
				}
				else if (equal(key, "GRENADE FROST EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost, key)
					}
				}
				else if (equal(key, "GRENADE FROST PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost_player, key)
					}
				}
				else if (equal(key, "GRENADE FROST BREAK"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost_break, key)
					}
				}
				else if (equal(key, "GRENADE FLARE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_flare, key)
					}
				}
				else if (equal(key, "ANTIDOTE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_antidote, key)
					}
				}
				else if (equal(key, "THUNDER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_thunder, key)
					}
				}
			}
			case SECTION_AMBIENCE_SOUNDS:
			{
				if (equal(key, "INFECTION ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && equal(key, "INFECTION SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience1, key)
						ArrayPushCell(sound_ambience1_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && equal(key, "INFECTION DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience1_duration, str_to_num(key))
					}
				}
				else if (equal(key, "NEMESIS ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && equal(key, "NEMESIS SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience2, key)
						ArrayPushCell(sound_ambience2_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && equal(key, "NEMESIS DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience2_duration, str_to_num(key))
					}
				}
				else if (equal(key, "SURVIVOR ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && equal(key, "SURVIVOR SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience3, key)
						ArrayPushCell(sound_ambience3_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && equal(key, "SURVIVOR DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience3_duration, str_to_num(key))
					}
				}
				else if (equal(key, "SWARM ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && equal(key, "SWARM SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience4, key)
						ArrayPushCell(sound_ambience4_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && equal(key, "SWARM DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience4_duration, str_to_num(key))
					}
				}
				else if (equal(key, "PLAGUE ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && equal(key, "PLAGUE SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience5, key)
						ArrayPushCell(sound_ambience5_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && equal(key, "PLAGUE DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience5_duration, str_to_num(key))
					}
				}
			}
			case SECTION_BUY_MENU_WEAPONS:
			{
				if (equal(key, "PRIMARY"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_primary_items, key)
						ArrayPushCell(g_primary_weaponids, cs_weapon_name_to_id(key))
					}
				}
				else if (equal(key, "SECONDARY"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_secondary_items, key)
						ArrayPushCell(g_secondary_weaponids, cs_weapon_name_to_id(key))
					}
				}
				else if (equal(key, "ADDITIONAL ITEMS"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_additional_items, key)
					}
				}
			}
			case SECTION_EXTRA_ITEMS_WEAPONS:
			{
				if (equal(key, "NAMES"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_extraweapon_names, key)
					}
				}
				else if (equal(key, "ITEMS"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_extraweapon_items, key)
					}
				}
				else if (equal(key, "COSTS"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushCell(g_extraweapon_costs, str_to_num(key))
					}
				}
			}
			case SECTION_WEATHER_EFFECTS:
			{
				if (equal(key, "RAIN"))
					g_ambience_rain = str_to_num(value)
				else if (equal(key, "SNOW"))
					g_ambience_snow = str_to_num(value)
				else if (equal(key, "FOG"))
					g_ambience_fog = str_to_num(value)
				else if (equal(key, "FOG DENSITY"))
					copy(g_fog_density, charsmax(g_fog_density), value)
				else if (equal(key, "FOG COLOR"))
					copy(g_fog_color, charsmax(g_fog_color), value)
			}
			case SECTION_SKY:
			{
				if (equal(key, "ENABLE"))
					g_sky_enable = str_to_num(value)
				else if (equal(key, "SKY NAMES"))
				{
					// Parse sky names
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to skies array
						ArrayPushString(g_sky_names, key)
						
						// Preache custom sky files
						formatex(linedata, charsmax(linedata), "gfx/env/%sbk.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sdn.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sft.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%slf.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%srt.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sup.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
					}
				}
			}
			case SECTION_LIGHTNING:
			{
				if (equal(key, "LIGHTS"))
				{
					// Parse lights
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to lightning array
						ArrayPushString(lights_thunder, key)
					}
				}
			}
			case SECTION_ZOMBIE_DECALS:
			{
				if (equal(key, "DECALS"))
				{
					// Parse decals
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to zombie decals array
						ArrayPushCell(zombie_decals, str_to_num(key))
					}
				}
			}
			case SECTION_KNOCKBACK:
			{
				// Format weapon entity name
				strtolower(key)
				format(key, charsmax(key), "weapon_%s", key)
				
				// Add value to knockback power array
				kb_weapon_power[cs_weapon_name_to_id(key)] = str_to_float(value)
			}
			case SECTION_OBJECTIVE_ENTS:
			{
				if (equal(key, "CLASSNAMES"))
				{
					// Parse classnames
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to objective ents array
						ArrayPushString(g_objective_ents, key)
					}
				}
			}
			case SECTION_SVC_BAD:
			{
				if (equal(key, "MODELCHANGE DELAY"))
					g_modelchange_delay = str_to_float(value)
				else if (equal(key, "HANDLE MODELS ON SEPARATE ENT"))
					g_handle_models_on_separate_ent = str_to_num(value)
				else if (equal(key, "SET MODELINDEX OFFSET"))
					g_set_modelindex_offset = str_to_num(value)
			}
		}
	}
	if (file) fclose(file)
	
	// Build zombie classes file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_ZOMBIECLASSES_FILE)
	
	// Parse if present
	if (file_exists(path))
	{
		static pos, temparr[64]
		
		// Open zombie classes file for reading
		file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
			
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
			
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
			
			// New class starting
			if (linedata[0] == '[')
			{
				// Remove first and last characters (braces)
				linedata[strlen(linedata) - 1] = 0
				copy(linedata, charsmax(linedata), linedata[1])
				
				// Store its real name for future reference
				ArrayPushString(g_zclass2_realname, linedata)
				continue;
			}
			
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			
			// Trim spaces
			trim(key)
			trim(value)
			
			if (equal(key, "NAME"))
				ArrayPushString(g_zclass2_name, value)
			else if (equal(key, "INFO"))
				ArrayPushString(g_zclass2_info, value)
			else if (equal(key, "MODELS"))
			{
				// Set models start index
				ArrayPushCell(g_zclass2_modelsstart, ArraySize(g_zclass2_playermodel))
				
				// Parse class models
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					// Add to class models array
					ArrayPushString(g_zclass2_playermodel, key)
					ArrayPushCell(g_zclass2_modelindex, -1)
				}
				
				// Set models end index
				ArrayPushCell(g_zclass2_modelsend, ArraySize(g_zclass2_playermodel))
			}
			else if (equal(key, "CLAWMODEL"))
				ArrayPushString(g_zclass2_clawmodel, value)
			else if (equal(key, "ZBOMBMODEL"))
				ArrayPushString(g_zclass2_zbombmodel, value)
			else if (equal(key, "HEALTH"))
				ArrayPushCell(g_zclass2_hp, str_to_num(value))
			else if (equal(key, "SPEED"))
				ArrayPushCell(g_zclass2_spd, str_to_num(value))
			else if (equal(key, "GRAVITY"))
				ArrayPushCell(g_zclass2_grav, str_to_float(value))
			else if (equal(key, "KNOCKBACK"))
				ArrayPushCell(g_zclass2_kb, str_to_float(value))
			else if (equal(key, "INFECT"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_infect, key)
					temparr[pos++] = ArraySize(class_sound_infect) - 1
				}
				
				ArrayPushArray(pointer_class_sound_infect, temparr)
			}
			else if (equal(key, "BURN"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_burn, key)
					temparr[pos++] = ArraySize(class_sound_burn) - 1
				}
				
				ArrayPushArray(pointer_class_sound_burn, temparr)
			}
			else if (equal(key, "PAIN"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_pain, key)
					temparr[pos++] = ArraySize(class_sound_pain) - 1
				}
				
				ArrayPushArray(pointer_class_sound_pain, temparr)
			}
			else if (equal(key, "DIE"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_die, key)
					temparr[pos++] = ArraySize(class_sound_die) - 1
				}
				
				ArrayPushArray(pointer_class_sound_die, temparr)
			}
			else if (equal(key, "MISS SLASH"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_miss_slash, key)
					temparr[pos++] = ArraySize(class_sound_miss_slash) - 1
				}
				
				ArrayPushArray(pointer_class_sound_miss_slash, temparr)
			}
			else if (equal(key, "MISS WALL"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_miss_wall, key)
					temparr[pos++] = ArraySize(class_sound_miss_wall) - 1
				}
				
				ArrayPushArray(pointer_class_sound_miss_wall, temparr)
			}
			else if (equal(key, "HIT NORMAL"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_hit_normal, key)
					temparr[pos++] = ArraySize(class_sound_hit_normal) - 1
				}
				
				ArrayPushArray(pointer_class_sound_hit_normal, temparr)
			}
			else if (equal(key, "HIT STAB"))
			{
				pos = 0
				arrayset(temparr, -1, sizeof(temparr))
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					ArrayPushString(class_sound_hit_stab, key)
					temparr[pos++] = ArraySize(class_sound_hit_stab) - 1
				}
				
				ArrayPushArray(pointer_class_sound_hit_stab, temparr)
			}
		}
		if (file) fclose(file)
	}
}

load_extras()
{
	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	
	// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], teams
	
	// Build extra items file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_EXTRAITEMS_FILE)
	
	// Parse if present
	if (file_exists(path))
	{
		// Open extra items file for reading
		new file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
			
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
			
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
			
			// New item starting
			if (linedata[0] == '[')
			{
				// Remove first and last characters (braces)
				linedata[strlen(linedata) - 1] = 0
				copy(linedata, charsmax(linedata), linedata[1])
				
				// Store its real name for future reference
				ArrayPushString(g_extraitem_realname, linedata)
				ArrayPushCell(g_extraitem_new, 0)
				g_extraitem_i++
				continue;
			}
			
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			
			// Trim spaces
			trim(key)
			trim(value)
			
			if (equal(key, "NAME"))
				ArrayPushString(g_extraitem_name, value)
			else if (equal(key, "COST"))
				ArrayPushCell(g_extraitem_cost, str_to_num(value))
			else if (equal(key, "BOLT"))
				ArrayPushCell(g_extraitem_bolt, str_to_num(value))	
			else if (equal(key, "TEAMS"))
			{
				// Clear teams bitsum
				teams = 0
				
				// Parse teams
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_ZOMBIE]))
						teams |= ZP_TEAM_ZOMBIE
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_HUMAN]))
						teams |= ZP_TEAM_HUMAN
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_NEMESIS]))
						teams |= ZP_TEAM_NEMESIS
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_SURVIVOR]))
						teams |= ZP_TEAM_SURVIVOR
				}
				
				// Add to teams array
				ArrayPushCell(g_extraitem_team, teams)
			}
			else if (equal(key, "SLOT"))
			{
				static i;
				for (i = 0; i < sizeof item_slots; i++)
				{
					if (equal(item_slots[i], value))
					{
						ArrayPushCell(g_extraitem_slot, i)
						break;
					}
				}
			}
			else if(equal(key, "LEVEL"))
			{
				ArrayPushCell(g_extraitem_lvl, str_to_num(value))
			}
			else if (equal(key, "WEAPON"))
			{
				if (equal(value, "NONE"))
					ArrayPushCell(g_extraitem_weapon, 0)
				else
					ArrayPushString(g_extraitem_weapon, value)	
			}
		}
		if (file) fclose(file)
	}
}

save_customization()
{
	new i, k, buffer[512]
	
	// Build zombie classes file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_ZOMBIECLASSES_FILE)
	
	// Open zombie classes file for appending data
	new file = fopen(path, "at"), size = ArraySize(g_zclass_name)
	
	// Add any new zombie classes data at the end if needed
	for (i = 0; i < size; i++)
	{
		if (ArrayGetCell(g_zclass_new, i))
		{
			// Add real name
			ArrayGetString(g_zclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^n[%s]", buffer)
			fputs(file, buffer)
			
			// Add caption
			ArrayGetString(g_zclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nNAME = %s", buffer)
			fputs(file, buffer)
			
			// Add info
			ArrayGetString(g_zclass_info, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nINFO = %s", buffer)
			fputs(file, buffer)
			
			// Add models
			for (k = ArrayGetCell(g_zclass_modelsstart, i); k < ArrayGetCell(g_zclass_modelsend, i); k++)
			{
				if (k == ArrayGetCell(g_zclass_modelsstart, i))
				{
					// First model, overwrite buffer
					ArrayGetString(g_zclass_playermodel, k, buffer, charsmax(buffer))
				}
				else
				{
					// Successive models, append to buffer
					ArrayGetString(g_zclass_playermodel, k, path, charsmax(path))
					format(buffer, charsmax(buffer), "%s , %s", buffer, path)
				}
			}
			format(buffer, charsmax(buffer), "^nMODELS = %s", buffer)
			fputs(file, buffer)
			
			// Add clawmodel
			ArrayGetString(g_zclass_clawmodel, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nCLAWMODEL = %s", buffer)
			fputs(file, buffer)
			
			format(buffer, charsmax(buffer), "^nZBOMBMODEL = v_zombibomb.mdl")
			fputs(file, buffer)
			
			// Add health
			formatex(buffer, charsmax(buffer), "^nHEALTH = %d", ArrayGetCell(g_zclass_hp, i))
			fputs(file, buffer)
			
			// Add speed
			formatex(buffer, charsmax(buffer), "^nSPEED = %d", ArrayGetCell(g_zclass_spd, i))
			fputs(file, buffer)
			
			// Add gravity
			formatex(buffer, charsmax(buffer), "^nGRAVITY = %.2f", Float:ArrayGetCell(g_zclass_grav, i))
			fputs(file, buffer)
			
			// Add knockback
			formatex(buffer, charsmax(buffer), "^nKNOCKBACK = %.2f^n", Float:ArrayGetCell(g_zclass_kb, i))
			fputs(file, buffer)
			
			// Add infect sound
			fputs(file, "^nINFECT = BZ_sound/all/human_death_01.wav , BZ_sound/all/human_death_02.wav")
			
			// Add burn sound
			fputs(file, "^nBURN = BZ_sound/all/zombi_hurt_1.wav , BZ_sound/all/zombi_hurt_2.wav")
			
			// Add pain sound
			fputs(file, "^nPAIN = BZ_sound/all/zombi_hurt_1.wav , BZ_sound/all/zombi_hurt_2.wav")
			
			// Add die sound
			fputs(file, "^nDIE = BZ_sound/all/zombi_death_1.wav , BZ_sound/all/zombi_death_2.wav")
			
			// Add miss slash sound
			fputs(file, "^nMISS SLASH = BZ_sound/all/zombi_swing_1.wav , BZ_sound/all/zombi_swing_2.wav , BZ_sound/all/zombi_swing_3.wav")
			
			// Add miss wall sound
			fputs(file, "^nMISS WALL = BZ_sound/all/zombi_wall_1.wav , BZ_sound/all/zombi_wall_2.wav , BZ_sound/all/zombi_wall_3.wav")
			
			// Add hit normal sound
			fputs(file, "^nHIT NORMAL = BZ_sound/all/zombi_attack_1.wav , BZ_sound/all/zombi_attack_2.wav , BZ_sound/all/zombi_attack_3.wav")		
			
			// Add hit stab sound
			fputs(file, "^nHIT STAB = BZ_sound/all/zombi_attack_1.wav , BZ_sound/all/zombi_attack_2.wav , BZ_sound/all/zombi_attack_3.wav^n")

		}
	}
	fclose(file)
	
	// Build extra items file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_EXTRAITEMS_FILE)
	
	// Open extra items file for appending data
	file = fopen(path, "at")
	size = ArraySize(g_extraitem_name)
	
	// Add any new extra items data at the end if needed
	for (i = 0; i < size; i++)
	{
		if (ArrayGetCell(g_extraitem_new, i))
		{
			// Add real name
			ArrayGetString(g_extraitem_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^n[%s]", buffer)
			fputs(file, buffer)
			
			// Add caption
			ArrayGetString(g_extraitem_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nNAME = %s", buffer)
			fputs(file, buffer)
			
			// Add cost
			formatex(buffer, charsmax(buffer), "^nCOST = %d", ArrayGetCell(g_extraitem_cost, i))
			fputs(file, buffer)
			
			formatex(buffer, charsmax(buffer), "^nBOLT = %d", ArrayGetCell(g_extraitem_bolt, i))
			fputs(file, buffer)
			
			// Add team
			formatex(buffer, charsmax(buffer), "^nTEAMS = %s", ZP_TEAM_NAMES[ArrayGetCell(g_extraitem_team, i)])
			fputs(file, buffer)
			
			formatex(buffer, charsmax(buffer), "^nSLOT = 6^n")
			fputs(file, buffer)
		}
	}
	fclose(file)
	
	// Free arrays containing class/item overrides
	ArrayDestroy(g_zclass2_realname)
	ArrayDestroy(g_zclass2_name)
	ArrayDestroy(g_zclass2_info)
	ArrayDestroy(g_zclass2_modelsstart)
	ArrayDestroy(g_zclass2_modelsend)
	ArrayDestroy(g_zclass2_playermodel)
	ArrayDestroy(g_zclass2_modelindex)
	ArrayDestroy(g_zclass2_clawmodel)
	ArrayDestroy(g_zclass2_zbombmodel)
	ArrayDestroy(g_zclass2_hp)
	ArrayDestroy(g_zclass2_spd)
	ArrayDestroy(g_zclass2_grav)
	ArrayDestroy(g_zclass2_kb)
	ArrayDestroy(g_zclass_new)
	ArrayDestroy(g_extraitem_new)
}

// Register Ham Forwards for CZ bots
public register_ham_czbots(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !g_isconnected[id] || !get_pcvar_num(cvar_botquota))
		return;
	
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled")
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled_Post", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage_Post", 1)
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")
	RegisterHamFromEntity(Ham_Player_ResetMaxSpeed, id, "fw_ResetMaxSpeed_Post", 1)
	
	// Ham forwards for CZ bots succesfully registered
	g_hamczbots = true
	
	// If the bot has already spawned, call the forward manually for him
	if (is_user_alive(id)) fw_PlayerSpawn_Post(id)
}

// Disable minmodels task
public disable_minmodels(id)
{
	if (!g_isconnected[id]) return;
	client_cmd(id, "cl_minmodels 0")
}

// Bots automatically buy extra items
public bot_buy_extras(taskid)
{
	// Nemesis or Survivor bots have nothing to buy by default
	if (!g_isalive[ID_SPAWN] || g_survivor[ID_SPAWN] || g_nemesis[ID_SPAWN])
		return;
}

// Refill BP Ammo Task
public refill_bpammo(const args[], id)
{
	// Player died or turned into a zombie
	if (!g_isalive[id] || g_zombie[id])
		return;
	
	set_msg_block(g_msgAmmoPickup, BLOCK_ONCE)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[REFILL_WEAPONID], AMMOTYPE[REFILL_WEAPONID], MAXBPAMMO[REFILL_WEAPONID])
}

// Balance Teams Task
balance_teams()
{
	// Get amount of users playing
	static iPlayersnum
	iPlayersnum = fnGetPlaying()
	
	// No players, don't bother
	if (iPlayersnum < 1) return;
	
	// Split players evenly
	static iTerrors, iMaxTerrors, id, team[33]
	iMaxTerrors = iPlayersnum/2
	iTerrors = 0
	
	// First, set everyone to CT
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED)
			continue;
		
		// Set team
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		team[id] = FM_CS_TEAM_CT
	}
	
	// Then randomly set half of the players to Terrorists
	while (iTerrors < iMaxTerrors)
	{
		// Keep looping through all players
		if (++id > g_maxplayers) id = 1
		
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		// Skip if not playing or already a Terrorist
		if (team[id] != FM_CS_TEAM_CT)
			continue;
		
		// Random chance
		if (random_num(0, 1))
		{
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			team[id] = FM_CS_TEAM_T
			iTerrors++
		}
	}
}

// Respawn Player Task (deathmatch)
public respawn_player_task(taskid)
{
	// Already alive or round ended
	if (g_isalive[ID_SPAWN] || g_endround)
		return;
	
	// Get player's team
	static team
	team = fm_cs_get_user_team(ID_SPAWN)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return;
	
	// Respawn player automatically if allowed on current round
	if ((!g_survround || get_pcvar_num(cvar_allowrespawnsurv)) && (!g_swarmround || get_pcvar_num(cvar_allowrespawnswarm)) && (!g_nemround || get_pcvar_num(cvar_allowrespawnnem)) && (!g_plagueround || get_pcvar_num(cvar_allowrespawnplague)))
	{
		// Infection rounds = none of the above
		if (!get_pcvar_num(cvar_allowrespawninfection) && !g_survround && !g_nemround && !g_swarmround && !g_plagueround)
			return;
		
		// Respawn if only the last human is left? (ignore this setting on survivor rounds)
		if (!g_survround && !get_pcvar_num(cvar_respawnafterlast) && fnGetHumans() <= 1)
			return;
		
		// Respawn as zombie?
		if (get_pcvar_num(cvar_deathmatch) == 2 || (get_pcvar_num(cvar_deathmatch) == 3 && random_num(0, 1)) || (get_pcvar_num(cvar_deathmatch) == 4 && fnGetZombies() < fnGetAlive()/2))
			g_respawn_as_zombie[ID_SPAWN] = true
		
		// Override respawn as zombie setting on nemesis and survivor rounds
		if (g_survround) g_respawn_as_zombie[ID_SPAWN] = true
		else if (g_nemround) g_respawn_as_zombie[ID_SPAWN] = false
		
		respawn_player_manually(ID_SPAWN)
	}
}

// Respawn Player Check Task (if killed by worldspawn)
public respawn_player_check_task(taskid)
{
	// Successfully spawned or round ended
	if (g_isalive[ID_SPAWN] || g_endround)
		return;
	
	// Get player's team
	static team
	team = fm_cs_get_user_team(ID_SPAWN)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return;
	
	// If player was being spawned as a zombie, set the flag again
	if (g_zombie[ID_SPAWN]) g_respawn_as_zombie[ID_SPAWN] = true
	else g_respawn_as_zombie[ID_SPAWN] = false
	
	respawn_player_manually(ID_SPAWN)
}

// Respawn Player Manually (called after respawn checks are done)
respawn_player_manually(id)
{
	// Set proper team before respawning, so that the TeamInfo message that's sent doesn't confuse PODBots
	if (g_respawn_as_zombie[id])
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
	else
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
	
	// Respawning a player has never been so easy
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

// Check Round Task -check that we still have both zombies and humans on a round-
check_round(leaving_player)
{
	// Round ended or make_a_zombie task still active
	if (g_endround || task_exists(TASK_MAKEZOMBIE))
		return;
	
	// Get alive players count
	static iPlayersnum, id
	iPlayersnum = fnGetAlive()
	
	// Last alive player, don't bother
	if (iPlayersnum < 2)
		return;
	
	// Last zombie disconnecting
	if (g_zombie[leaving_player] && fnGetZombies() == 1)
	{
		// Only one CT left, don't bother
		if (fnGetHumans() == 1 && fnGetCTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last zombie left notice
		zp_colored_print(0, "^x04[ZP]^x01 %s Стал зомби! (Прошлый зомби вышел из игры)", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Nemesis or just a zombie?
		if (g_nemesis[leaving_player])
			zombieme(id, 0, 1, 0, 0)
		else
			zombieme(id, 0, 0, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Nemesis, set chosen player's health to that of the one who's leaving
		if (get_pcvar_num(cvar_keephealthondisconnect) && g_nemesis[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
	
	// Last human disconnecting
	else if (!g_zombie[leaving_player] && fnGetHumans() == 1)
	{
		// Only one T left, don't bother
		if (fnGetZombies() == 1 && fnGetTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last human left notice
		zp_colored_print(0, "^x04[ZP]^x01 %s Стал человеком! (Прошлый человек вышел из игры)", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Survivor or just a human?
		if (g_survivor[leaving_player])
			humanme(id, 1, 0)
		else
			humanme(id, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Survivor, set chosen player's health to that of the one who's leaving
		if (get_pcvar_num(cvar_keephealthondisconnect) && g_survivor[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
}

// Lighting Effects Task
public lighting_effects()
{
	// Cache some CVAR values at every 5 secs
	cache_cvars()
	
	// Get lighting style
	static lighting[2]
	get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))
	strtolower(lighting)
	
	// Lighting disabled? ["0"]
	if (lighting[0] == '0')
		return;
	
	// Darkest light settings?
	if (lighting[0] >= 'a' && lighting[0] <= 'd')
	{
		static thunderclap_in_progress, Float:thunder
		thunderclap_in_progress = task_exists(TASK_THUNDER)
		thunder = get_pcvar_float(cvar_thunder)
		
		// Set thunderclap tasks if not existant
		if (thunder > 0.0 && !task_exists(TASK_THUNDER_PRE) && !thunderclap_in_progress)
		{
			g_lights_i = 0
			ArrayGetString(lights_thunder, random_num(0, ArraySize(lights_thunder) - 1), g_lights_cycle, charsmax(g_lights_cycle))
			g_lights_cycle_len = strlen(g_lights_cycle)
			set_task(thunder, "thunderclap", TASK_THUNDER_PRE)
		}
		
		// Set lighting only when no thunderclaps are going on
		if (!thunderclap_in_progress){
			if(g_nemesis_mod == 10)
				engfunc(EngFunc_LightStyle, 0, "b")
			else 
				engfunc(EngFunc_LightStyle, 0, lighting)
		} 
	}
	else
	{
		// Remove thunderclap tasks
		remove_task(TASK_THUNDER_PRE)
		remove_task(TASK_THUNDER)
		
		// Set lighting
		if(g_nemesis_mod == 10)
			engfunc(EngFunc_LightStyle, 0, "b")
		else 
			engfunc(EngFunc_LightStyle, 0, lighting)
	}
}

// Thunderclap task
public thunderclap()
{
	// Play thunder sound
	if (g_lights_i == 0)
	{
		static sound[64]
		ArrayGetString(sound_thunder, random_num(0, ArraySize(sound_thunder) - 1), sound, charsmax(sound))
		PlaySound(sound)
	}
	
	// Set lighting
	static light[2]
	light[0] = g_lights_cycle[g_lights_i]
	engfunc(EngFunc_LightStyle, 0, light)
	
	g_lights_i++
	
	// Lighting cycle end?
	if (g_lights_i >= g_lights_cycle_len)
	{
		remove_task(TASK_THUNDER)
		lighting_effects()
	}
	// Lighting cycle start?
	else if (!task_exists(TASK_THUNDER))
		set_task(0.1, "thunderclap", TASK_THUNDER, _, _, "b")
}

// Ambience Sound Effects Task
public ambience_sound_effects(taskid)
{
	// Play a random sound depending on the round
	static sound[64], iRand, duration
	
	if (g_nemround) // Nemesis Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience2) - 1)
		ArrayGetString(sound_ambience2, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience2_duration, iRand)
	}
	else if (g_survround) // Survivor Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience3) - 1)
		ArrayGetString(sound_ambience3, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience3_duration, iRand)
	}
	else if (g_swarmround) // Swarm Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience4) - 1)
		ArrayGetString(sound_ambience4, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience4_duration, iRand)
	}
	else if (g_plagueround) // Plague Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience5) - 1)
		ArrayGetString(sound_ambience5, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience5_duration, iRand)
	}
	else // Infection Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience1) - 1)
		ArrayGetString(sound_ambience1, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience1_duration, iRand)
	}
	
	// Play it on clients
	PlaySound(sound)
	
	// Set the task for when the sound is done playing
	set_task(float(duration), "ambience_sound_effects", TASK_AMBIENCESOUNDS)
}

// Ambience Sounds Stop Task
ambience_sound_stop()
{
	client_cmd(0, "mp3 stop; stopsound")
}

// Flashlight Charge Task
public flashlight_charge(taskid)
{
	// Drain or charge?
	if (g_flashlight[ID_CHARGE])
		g_flashbattery[ID_CHARGE] -= get_pcvar_num(cvar_flashdrain)
	else
		g_flashbattery[ID_CHARGE] += get_pcvar_num(cvar_flashcharge)
	
	// Battery fully charged
	if (g_flashbattery[ID_CHARGE] >= 100)
	{
		// Don't exceed 100%
		g_flashbattery[ID_CHARGE] = 100
		
		// Update flashlight battery on HUD
		message_begin(MSG_ONE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(100) // battery
		message_end()
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Battery depleted
	if (g_flashbattery[ID_CHARGE] <= 0)
	{
		// Turn it off
		g_flashlight[ID_CHARGE] = false
		g_flashbattery[ID_CHARGE] = 0
		
		// Play flashlight toggle sound
		emit_sound(ID_CHARGE, CHAN_ITEM, sound_flashlight, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, ID_CHARGE)
		write_byte(0) // toggle
		write_byte(0) // battery
		message_end()
		
		// Remove flashlight task for this player
		remove_task(ID_CHARGE+TASK_FLASH)
	}
	else
	{
		// Update flashlight battery on HUD
		message_begin(MSG_ONE_UNRELIABLE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(g_flashbattery[ID_CHARGE]) // battery
		message_end()
	}
}

// Remove Spawn Protection Task
public remove_spawn_protection(taskid)
{
	// Not alive
	if (!g_isalive[ID_SPAWN])
		return;
	
	// Remove spawn protection
	g_nodamage[ID_SPAWN] = false
	set_pev(ID_SPAWN, pev_takedamage, DAMAGE_YES)
	
	fm_set_rendering(ID_SPAWN)
}

// Hide Player's Money Task
public task_hide_money(taskid)
{
    // Not alive
    if (!g_isalive[ID_SPAWN])
        return;
    
    // Hide money
    message_begin(MSG_ONE, g_msgHideWeapon, _, ID_SPAWN)
    write_byte(HIDE_MONEY) // what to hide bitsum
    message_end()
    
    // Hide the HL crosshair that's drawn
    message_begin(MSG_ONE, g_msgCrosshair, _, ID_SPAWN)
    write_byte(0) // toggle
    message_end()
}

// Turn Off Flashlight and Restore Batteries
turn_off_flashlight(id)
{
	// Restore batteries for the next use
	fm_cs_set_user_batteries(id, 100)
	
	// Check if flashlight is on
	if (pev(id, pev_effects) & EF_DIMLIGHT)
	{
		// Turn it off
		set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT)
	}
	else
	{
		// Clear any stored flashlight impulse (bugfix)
		set_pev(id, pev_impulse, 0)
	}
	
	// Turn off custom flashlight
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[id] = false
		g_flashbattery[id] = 100
		
		// Update flashlight HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, id)
		write_byte(0) // toggle
		write_byte(100) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
	}
}

jump_explode(Entity)
{
    if(Entity < 0)
       return
       
    static Float:flOrigin[3]
    pev(Entity, pev_origin, flOrigin)
        
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_EXPLOSION) // Temporary entity ID
    engfunc(EngFunc_WriteCoord, flOrigin[0]) // engfunc because float
    engfunc(EngFunc_WriteCoord, flOrigin[1])
    engfunc(EngFunc_WriteCoord, flOrigin[2]+40)
    write_short(g_explo_zbombSpr) // Sprite index
    write_byte(24) // Scale
    write_byte(20) // Framerate
    write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS|TE_EXPLFLAG_NOPARTICLES) // Flags
    message_end()
    
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
    write_byte(TE_PARTICLEBURST) // TE id
    engfunc(EngFunc_WriteCoord, flOrigin[0]) // engfunc because float
    engfunc(EngFunc_WriteCoord, flOrigin[1])
    engfunc(EngFunc_WriteCoord, flOrigin[2]+5)
    write_short(250) // radius
    write_byte(108) // particle color
    write_byte(16) // duration * 10 will be randomized a bit
    message_end()
           
    static sound[64]
    ArrayGetString(grenade_zbomb, random_num(0, ArraySize(grenade_zbomb) - 1), sound, charsmax(sound))
    emit_sound(Entity, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)

    static i
    i = -1
	
    while ((i = engfunc(EngFunc_FindEntityInSphere, i, flOrigin, NADE_EXPLOSION_RADIUS)) != 0)
    {
        if(!is_user_alive(i))
            continue
                  
        new Float:flVictimOrigin[3]
        pev(i, pev_origin, flVictimOrigin)
               
        new Float:flDistance = get_distance_f (flOrigin, flVictimOrigin)   
               
        static Float:flSpeed
        flSpeed = 650.0
    
        static Float:flNewSpeed
        flNewSpeed = flSpeed * (1.0 - (flDistance / 450.0))
               
        static Float:flVelocity[3]
        get_speed_vector(flOrigin, flVictimOrigin, flNewSpeed, flVelocity)
                       
        set_pev(i, pev_velocity, flVelocity)
    
        message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, i)
        write_short(UNIT_SECOND*4) // amplitude             
        write_short(UNIT_SECOND*2) // duration
        write_short(UNIT_SECOND*10) // frequency
        message_end()   
        
        message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, i)
	write_short(UNIT_SECOND) // Duration
	write_short(0) // Hold Time
	write_short(FFADE_IN) // Fade type
	write_byte(255) // Red amount
	write_byte(165) // Green amount
	write_byte(0) // Blue amount
	write_byte(100) // Alpha
	message_end()
    }

    engfunc(EngFunc_RemoveEntity, Entity)
}

shock_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	create_blast5(originF)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION) // Temporary entity ID
	engfunc(EngFunc_WriteCoord, originF[0]) // engfunc because float
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2]+40)
	write_short(g_explo_zbombSpr) // Sprite index
	write_byte(24) // Scale
	write_byte(20) // Framerate
	write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NODLIGHTS|TE_EXPLFLAG_NOPARTICLES) // Flags
	message_end()
    
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_PARTICLEBURST) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // engfunc because float
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2]+5)
	write_short(250) // radius
	write_byte(47) // particle color
	write_byte(16) // duration * 10 will be randomized a bit
	message_end()
           
	static sound[64]
	ArrayGetString(grenade_zbomb, random_num(0, ArraySize(grenade_zbomb) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive unfrozen zombies
		if (!is_user_valid_alive(victim) || g_zombie[victim])
			continue;
			
		set_task(0.1, "affect_victim", victim+TASK_AFFECT, _, _, "a", 100)
		
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

public affect_victim(taskid)
{
	new ID_AFFECT = taskid-TASK_AFFECT
	if(!is_user_connected(ID_AFFECT)||!is_user_alive(ID_AFFECT) || g_zombie[ID_AFFECT]||g_lasthuman[ID_AFFECT]) {
		remove_task(taskid)
		return
	}
	
	new r, g, b, a
	if(random_num(0,100)<=10){
		r=0
		g=0
		b=0
		a=255
	}
	else
	{
		r=random_num (0, 50) 
		b=random_num (200, 250) 
		g=random_num (200, 250) 
		a=random_num (50, 200)
	}
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, ID_AFFECT)
	write_short(UNIT_SECOND) // Duration
	write_short(0) // Hold Time
	write_short(FFADE_IN) // Fade type
	write_byte(r) // Red amount
	write_byte(g) // Green amount
	write_byte(b) // Blue amount
	write_byte(a) // Alpha
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, ID_AFFECT)
	write_short(UNIT_SECOND * random_num(3, 10)) // amplitude             
	write_short(UNIT_SECOND * 2) // duration
	write_short(UNIT_SECOND * random_num(3, 10)) // frequency
	message_end()
	
	new Float:cloc[3]
	cloc[0] = random_float(-10.0, 10.0)
	cloc[1] = random_float(-10.0, 10.0)
	cloc[2] = random_float(-10.0, 10.0)
	
	set_pev(ID_AFFECT, pev_punchangle, cloc)
}

// Fire Grenade Explosion
fire_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast2(originF)
	
	// Fire nade explode sound
	static sound[64]
	ArrayGetString(grenade_fire, random_num(0, ArraySize(grenade_fire) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION) // Temporary entity ID
	engfunc(EngFunc_WriteCoord, originF[0]) // engfunc because float
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2] + 40)
	write_short(g_explo_fireSpr) // Sprite index
	write_byte(13) // Scale
	write_byte(18) // Framerate
	write_byte(TE_EXPLFLAG_NOSOUND) // Flags
	message_end()
		
	message_begin (MSG_BROADCAST,SVC_TEMPENTITY)
        write_byte(TE_SPRITETRAIL) // Throws a shower of sprites or models
        engfunc(EngFunc_WriteCoord, originF[ 0 ]) // start pos
        engfunc(EngFunc_WriteCoord, originF[ 1 ])
        engfunc(EngFunc_WriteCoord, originF[ 2 ] + 200.0)
        engfunc(EngFunc_WriteCoord, originF[ 0 ]) // velocity
        engfunc(EngFunc_WriteCoord, originF[ 1 ])
        engfunc(EngFunc_WriteCoord, originF[ 2 ] + 30.0)
        write_short(g_gibs_fireSpr) // spr
        write_byte(30) // (count)
        write_byte(5) // (life in 0.1's)
        write_byte(2) // byte (scale in 0.1's)
        write_byte(50) // (velocity along vector in 10's)
        write_byte(10) // (randomness of velocity in 10's)
        message_end() 
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim])
			continue;
		
		// Heat icon?
		if (get_pcvar_num(cvar_hudicons))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_BURN) // damage type
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		if (g_nemesis[victim]) // fire duration (nemesis is fire resistant)
			g_burning_duration[victim] += get_pcvar_num(cvar_fireduration)
		else
			g_burning_duration[victim] += get_pcvar_num(cvar_fireduration) * 5
		
		// Set burning task on victim if not present
		if (!task_exists(victim+TASK_BURN))
			set_task(0.2, "burning_flame", victim+TASK_BURN, _, _, "b")
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

antidote_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast4(originF)
	
	// Fire nade explode sound
	static sound[64]
	ArrayGetString(grenade_antidote, random_num(0, ArraySize(grenade_antidote) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION) // Temporary entity ID
	engfunc(EngFunc_WriteCoord, originF[0]) // engfunc because float
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2] + 40)
	write_short(g_explo_antidoteSpr) // Sprite index
	write_byte(20) // Scale
	write_byte(17) // Framerate
	write_byte(TE_EXPLFLAG_NOSOUND) // Flags
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_WORLDDECAL)
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2])
	write_byte(engfunc(EngFunc_DecalIndex, "{scorch3"))
	message_end()
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_nodamage[victim] || g_nemesis[victim] || g_lastzombie[victim])
			continue;
		
		// Heat icon?
		if (get_pcvar_num(cvar_hudicons))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_NERVEGAS) // damage type
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		humanme(victim, 0, 1)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Frost Grenade Explosion
frost_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast3(originF)
	
	// Frost nade explode sound
	static sound[64]
	ArrayGetString(grenade_frost, random_num(0, ArraySize(grenade_frost) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION) // Temporary entity ID
	engfunc(EngFunc_WriteCoord, originF[0]) // engfunc because float
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2] + 40)
	write_short(g_explo_frostSpr) // Sprite index
	write_byte(13) // Scale
	write_byte(18) // Framerate
	write_byte(TE_EXPLFLAG_NOSOUND) // Flags
	message_end()
	
	message_begin (MSG_BROADCAST,SVC_TEMPENTITY)
        write_byte(TE_SPRITETRAIL) // Throws a shower of sprites or models
        engfunc(EngFunc_WriteCoord, originF[ 0 ]) // start pos
        engfunc(EngFunc_WriteCoord, originF[ 1 ])
        engfunc(EngFunc_WriteCoord, originF[ 2 ] + 200.0)
        engfunc(EngFunc_WriteCoord, originF[ 0 ]) // velocity
        engfunc(EngFunc_WriteCoord, originF[ 1 ])
        engfunc(EngFunc_WriteCoord, originF[ 2 ] + 30.0)
        write_short(g_gibs_frostSpr) // spr
        write_byte(30) // (count)
        write_byte(5) // (life in 0.1's)
        write_byte(2) // byte (scale in 0.1's)
        write_byte(50) // (velocity along vector in 10's)
        write_byte(10) // (randomness of velocity in 10's)
        message_end() 
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive unfrozen zombies
		if (!is_user_valid_alive(victim) || !g_zombie[victim] || g_frozen[victim] || g_nodamage[victim])
			continue;
		
		// Nemesis shouldn't be frozen
		if (g_nemesis[victim])
		{
			// Get player's origin
			static origin2[3]
			get_user_origin(victim, origin2)
			
			// Broken glass sound
			ArrayGetString(grenade_frost_break, random_num(0, ArraySize(grenade_frost_break) - 1), sound, charsmax(sound))
			emit_sound(victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			// Glass shatter
			message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
			write_byte(TE_BREAKMODEL) // TE id
			write_coord(origin2[0]) // x
			write_coord(origin2[1]) // y
			write_coord(origin2[2]+24) // z
			write_coord(16) // size x
			write_coord(16) // size y
			write_coord(16) // size z
			write_coord(random_num(-50, 50)) // velocity x
			write_coord(random_num(-50, 50)) // velocity y
			write_coord(25) // velocity z
			write_byte(10) // random velocity
			write_short(g_glassSpr) // model
			write_byte(10) // count
			write_byte(25) // life
			write_byte(BREAK_GLASS) // flags
			message_end()
			
			continue;
		}
		
		// Freeze icon?
		if (get_pcvar_num(cvar_hudicons))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_DROWN) // damage type - DMG_FREEZE
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		// Light blue glow while frozen
		if (g_handle_models_on_separate_ent)
			fm_set_rendering(g_ent_playermodel[victim], kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
		else
			fm_set_rendering(victim, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
		
		// Freeze sound
		ArrayGetString(grenade_frost_player, random_num(0, ArraySize(grenade_frost_player) - 1), sound, charsmax(sound))
		emit_sound(victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Add a blue tint to their screen
		message_begin(MSG_ONE, g_msgScreenFade, _, victim)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(FFADE_STAYOUT) // fade type
		write_byte(0) // red
		write_byte(50) // green
		write_byte(200) // blue
		write_byte(100) // alpha
		message_end()
		
		// Set the frozen flag
		g_frozen[victim] = true
		
		// Save player's old gravity (bugfix)
		pev(victim, pev_gravity, g_frozen_gravity[victim])
		
		// Prevent from jumping
		if (pev(victim, pev_flags) & FL_ONGROUND)
			set_pev(victim, pev_gravity, 999999.9) // set really high
		else
			set_pev(victim, pev_gravity, 0.000001) // no gravity
		
		// Prevent from moving
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		
		// Set a task to remove the freeze
		set_task(g_firstzombie[victim]? 2.0:4.0, "remove_freeze", victim)

	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Remove freeze task
public remove_freeze(id)
{
	// Not alive or not frozen anymore
	if (!g_isalive[id] || !g_frozen[id])
		return;
	
	// Unfreeze
	g_frozen[id] = false;
	
	// Restore gravity and maxspeed (bugfix)
	set_pev(id, pev_gravity, g_frozen_gravity[id])
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	
	// Restore rendering
	if (g_handle_models_on_separate_ent)
	{
		fm_set_rendering(g_ent_playermodel[id])
	}
	else
	{
		fm_set_rendering(id)
	}
	
	// Gradually remove screen's blue tint
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(0) // red
	write_byte(50) // green
	write_byte(200) // blue
	write_byte(100) // alpha
	message_end()
	
	// Broken glass sound
	static sound[64]
	ArrayGetString(grenade_frost_break, random_num(0, ArraySize(grenade_frost_break) - 1), sound, charsmax(sound))
	emit_sound(id, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get player's origin
	static origin2[3]
	get_user_origin(id, origin2)
	
	// Glass shatter
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
	write_byte(TE_BREAKMODEL) // TE id
	write_coord(origin2[0]) // x
	write_coord(origin2[1]) // y
	write_coord(origin2[2]+24) // z
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50, 50)) // velocity x
	write_coord(random_num(-50, 50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_glassSpr) // model
	write_byte(10) // count
	write_byte(25) // life
	write_byte(BREAK_GLASS) // flags
	message_end()
	
	ExecuteForward(g_fwUserUnfrozen, g_fwDummyResult, id);
}

// Remove Stuff Task
public remove_stuff()
{
	static ent
	
	// Remove rotating doors
	if (get_pcvar_num(cvar_removedoors) > 0)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door_rotating")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Remove all doors
	if (get_pcvar_num(cvar_removedoors) > 1)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Triggered lights
	if (!get_pcvar_num(cvar_triggered))
	{
		ent = -1
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "light")) != 0)
		{
			dllfunc(DLLFunc_Use, ent, 0); // turn off the light
			set_pev(ent, pev_targetname, 0) // prevent it from being triggered
		}
	}
}

// Set Custom Weapon Models
replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_KNIFE: // Custom knife models
		{
			if (g_zombie[id])
			{
				if (g_nemesis[id]) // Nemesis
				{
					set_pev(id, pev_viewmodel2, model_vknife_nemesis)
					set_pev(id, pev_weaponmodel2, "")
				}
				else // Zombies
				{
					static clawmodel[100]
					ArrayGetString(g_zclass_clawmodel, g_zombieclass[id], clawmodel, charsmax(clawmodel))
					format(clawmodel, charsmax(clawmodel), "models/BZ_models/%s", clawmodel)
					set_pev(id, pev_viewmodel2, clawmodel)
					set_pev(id, pev_weaponmodel2, "")
				}
			}
			else // Humans
			{
			    set_pev(id, pev_viewmodel2, model_vknife_human[g_knife[id]])
				set_pev(id, pev_weaponmodel2, model_pknife_human[g_knife[id]])
		     }
		}
		case CSW_HEGRENADE: // Infection bomb or fire grenade
		{
			if (g_zombie[id]){

				static clawmodel[100]
				ArrayGetString(g_zclass_zbombmodel, g_zombieclass[id], clawmodel, charsmax(clawmodel))
				format(clawmodel, charsmax(clawmodel), "models/BZ_models/%s", clawmodel)
				set_pev(id, pev_viewmodel2, clawmodel)
				set_pev(id, pev_weaponmodel2, "models/BZ_models/p_zombibomb.mdl")
			}
			else{
				set_pev(id, pev_viewmodel2, model_grenade_fire)
				set_pev(id, pev_weaponmodel2, model_pgrenade_fire)
			}
		}
		case CSW_FLASHBANG: // Frost grenade
		{
			set_pev(id, pev_viewmodel2, model_grenade_frost)
			set_pev(id, pev_weaponmodel2, model_pgrenade_frost)
		}
		case CSW_SMOKEGRENADE: // Flare grenade
		{
			if (g_zombie[id]){

				static clawmodel[100]
				ArrayGetString(g_zclass_zbombmodel, g_zombieclass[id], clawmodel, charsmax(clawmodel))
				format(clawmodel, charsmax(clawmodel), "models/BZ_models/%s", clawmodel)
				set_pev(id, pev_viewmodel2, clawmodel)
				set_pev(id, pev_weaponmodel2, "models/BZ_models/p_zombibomb.mdl")
			}
			else{
				if(g_pipe_bomb[id])
				{
					set_pev(id, pev_viewmodel2, model_grenade_pipe)
					set_pev(id, pev_weaponmodel2, model_pgrenade_pipe)
				}else{
					set_pev(id, pev_viewmodel2, model_grenade_antidote)
					set_pev(id, pev_weaponmodel2, model_pgrenade_antidote)
				}
			}
		}
	}
	
	// Update model on weaponmodel ent
	if (g_handle_models_on_separate_ent) fm_set_weaponmodel_ent(id)
}

// Reset Player Vars
reset_vars(id, resetall)
{
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_lastzombie[id] = false
	g_lasthuman[id] = false
	g_frozen[id] = false
	g_nodamage[id] = false
	g_respawn_as_zombie[id] = false
	g_flashlight[id] = false
	g_flashbattery[id] = 100
	g_canbuy[id] = true
	g_burning_duration[id] = 0
	
	if (resetall)
	{
		g_ammopacks[id] = get_pcvar_num(cvar_startammopacks)
		g_zombieclass[id] = ZCLASS_NONE
		g_zombieclassnext[id] = ZCLASS_NONE
		g_damagedealt_human[id] = 0
		g_damagedealt_zombie[id] = 0
		WPN_AUTO_ON = 0
		WPN_STARTID = 0
		PL_ACTION = 0
		MENU_PAGE_ZCLASS = 0
		MENU_PAGE_EXTRAS = 0
		MENU_PAGE_PLAYERS = 0
	}
}

// Show HUD Task
public ShowHUD(taskid)
{
	static id
	id = ID_SHOWHUD;
	
	// Player died?
	if (!g_isalive[id])
	{
		// Get spectating target
		id = pev(id, PEV_SPEC_TARGET)
		
		// Target not alive
		if (!g_isalive[id]) return;
	}
	
	// Format classname
	static class[32], red, green, blue
	
	if (g_zombie[id]) // zombies
	{
        red = random_num(0,255)
        green = random_num(0,255)
        blue = random_num(0,255)	
	
		if (g_nemesis[id])
			formatex(class, charsmax(class), "Дьявол")
		else
			copy(class, charsmax(class), g_zombie_classname[id])
	}
	else // humans
	{
        red = random_num(0,255)
        green = random_num(0,255)
        blue = random_num(0,255)	
	
		if (g_survivor[id]) {
			formatex(class, charsmax(class), "Герой")
		}else{
			if(id != ID_SHOWHUD)
			{
				formatex(class, charsmax(class), "%s", CHARACTER[zp_get_character(id)])
			}else{
				formatex(class, charsmax(class), "%s", CHARACTER[zp_get_character(ID_SHOWHUD)])
			}  
		}	
	}
	
	// Spectating someone else?
	if (id != ID_SHOWHUD)
	{
        // Show name, health, class, and ammo packs
        set_dhudmessage(red, green, blue, HUD_3_CORD, HUD_4_CORD, 0, 6.0, 1.1, 0.0, 0.0)
        show_dhudmessage(ID_SHOWHUD, "[Наблюдение: %s]^n[HP: %d] [%s] [Аммо: %d] [Уровень: %d]", g_playername[id], pev(id, pev_health), class, g_ammopacks[id], g_lvl[id])
	}
	else
	{				
            // Show health, class and ammo packs
            set_hudmessage(g_fMainInformerColor[id][0], g_fMainInformerColor[id][1], g_fMainInformerColor[id][2], HUD_1_CORD, HUD_2_CORD, 0, 6.0, 1.1, 0.0, 0.0, false)
            if(g_zombie[id]) ShowSyncHudMsg(id, g_MsgSync, "%s^n%Здоровье: %d^nАммо: %d | Болты: %d^nLevel: %d | Exp: %d / %d", class, pev(ID_SHOWHUD, pev_health), g_ammopacks[id], g_iToken[id] , g_lvl[ID_SHOWHUD], g_exp[ID_SHOWHUD], LEVEL_EXP_COUNT*g_lvl[id])
            else ShowSyncHudMsg(id, g_MsgSync,"%s | %Здоровье: %d | Броня: %d^nАммо: %d | Болты: %d | Level: %d | Exp: %d / %d", class, pev(ID_SHOWHUD, pev_health), get_user_armor(id), g_ammopacks[id], g_iToken[id] , g_lvl[ID_SHOWHUD], g_exp[ID_SHOWHUD], LEVEL_EXP_COUNT*g_lvl[id])			
		
	        if(g_informer[id]) return			
		
			set_hudmessage(g_fMainInformerColor[id][0], g_fMainInformerColor[id][1], g_fMainInformerColor[id][2], g_fMainInformerPosX[ID_SHOWHUD], g_fMainInformerPosY[ID_SHOWHUD], 0, 6.0, 1.1, 0.0, 0.0)
			
			if(Map_Boss) {
				ShowSyncHudMsg(id, g_MsgSync2, "Опасная зона^nГнев зомби призвал - БОССА!^n^nVIP - 100rub.^nPREMIUM - 150rub.^nADMIN - 190rub.^nBOSS - 270rub.^n^nVK: vk.com/goodgame16")
			}			
			else if(fnGetPlaying()<2) {
				ShowSyncHudMsg(id, g_MsgSync2, "Карантин^nНедостаточно игроков^nМинимум 2 игрока^n^nVK: vk.com/goodgame16")
			}
			else if(g_newround) {
				ShowSyncHudMsg(id, g_MsgSync2, "Выживание, День: %s^nРежим: *Выбирается*^n^nVIP - 100rub.^nPREMIUM - 150rub.^nADMIN - 190rub.^nBOSS - 270rub.^n^nVK: vk.com/goodgame16", g_day_string[g_day_num])
			}
			else if(g_nemround) {
				ShowSyncHudMsg(id, g_MsgSync2, "Выживание, День: %s^nРежим: Дьявол^nДьявол: %s^nЛюди: %i^n^nVK: vk.com/goodgame16", g_day_string[g_day_num], g_nem_name, fnGetHumans())
			}
			else if(g_survround) {
				ShowSyncHudMsg(id, g_MsgSync2, "Выживание, День: %s^nРежим: Герой^nГерой: %s^nЗараженных: %i^n^nVK: vk.com/goodgame16", g_day_string[g_day_num], g_surv_name, fnGetZombies())
			}
			else if(g_swarmround) {
				ShowSyncHudMsg(id, g_MsgSync2, "Выживание, День: %s^nРежим: Куча на куча^nЛюди: %i^nЗараженных: %i^n^nVK: vk.com/goodgame16", g_day_string[g_day_num], fnGetHumans(),fnGetZombies())
			}
			else if(g_plagueround) {
				ShowSyncHudMsg(id, g_MsgSync2, "Выживание, День: %s^nРежим: Чума^nЛюди: %i^nЗараженных: %i^n^nVK: vk.com/goodgame16", g_day_string[g_day_num], fnGetHumans(),fnGetZombies())
			}				
			else {
				ShowSyncHudMsg(id, g_MsgSync2, "Выживание, День: %s^nРежим: Простая инфекция^nЛюди: %i^nЗараженных: %i^n^nVK: vk.com/goodgame16", g_day_string[g_day_num], fnGetHumans(),fnGetZombies())
			} 
	}
}

// Madness Over Task
public madness_over(taskid)
{
	g_nodamage[ID_BLOOD] = false
}

// Place user at a random spawn
do_random_spawn(id, regularspawns = 0)
{
	static hull, sp_index, i
	
	// Get whether the player is crouching
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	
	// Use regular spawns?
	if (!regularspawns)
	{
		// No spawns?
		if (!g_spawnCount)
			return;
		
		// Choose random spawn to start looping at
		sp_index = random_num(0, g_spawnCount - 1)
		
		// Try to find a clear spawn
		for (i = sp_index + 1; /*no condition*/; i++)
		{
			// Start over when we reach the end
			if (i >= g_spawnCount) i = 0
			
			// Free spawn space?
			if (is_hull_vacant(g_spawns[i], hull))
			{
				// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, id, g_spawns[i])
				break;
			}
			
			// Loop completed, no free space found
			if (i == sp_index) break;
		}
	}
	else
	{
		// No spawns?
		if (!g_spawnCount2)
			return;
		
		// Choose random spawn to start looping at
		sp_index = random_num(0, g_spawnCount2 - 1)
		
		// Try to find a clear spawn
		for (i = sp_index + 1; /*no condition*/; i++)
		{
			// Start over when we reach the end
			if (i >= g_spawnCount2) i = 0
			
			// Free spawn space?
			if (is_hull_vacant(g_spawns2[i], hull))
			{
				// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, id, g_spawns2[i])
				break;
			}
			
			// Loop completed, no free space found
			if (i == sp_index) break;
		}
	}
}

// Get Zombies -returns alive zombies number-
fnGetZombies()
{
	static iZombies, id
	iZombies = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_zombie[id])
			iZombies++
	}
	
	return iZombies;
}

// Get Humans -returns alive humans number-
fnGetHumans()
{
	static iHumans, id
	iHumans = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && !g_zombie[id])
			iHumans++
	}
	
	return iHumans;
}

// Get Nemesis -returns alive nemesis number-
fnGetNemesis()
{
	static iNemesis, id
	iNemesis = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_nemesis[id])
			iNemesis++
	}
	
	return iNemesis;
}

// Get Survivors -returns alive survivors number-
fnGetSurvivors()
{
	static iSurvivors, id
	iSurvivors = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_survivor[id])
			iSurvivors++
	}
	
	return iSurvivors;
}

// Get Alive -returns alive players number-
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
	}
	
	return iAlive;
}

// Get Random Alive -returns index of alive player number n -
fnGetRandomAlive(n)
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
		
		if (iAlive == n)
			return id;
	}
	
	return -1;
}

// Get Playing -returns number of users playing-
fnGetPlaying()
{
	static iPlaying, id, team
	iPlaying = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{
			team = fm_cs_get_user_team(id)
			
			if (team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED)
				iPlaying++
		}
	}
	
	return iPlaying;
}

// Get CTs -returns number of CTs connected-
fnGetCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Ts -returns number of Ts connected-
fnGetTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Get Alive CTs -returns number of CTs alive-
fnGetAliveCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Alive Ts -returns number of Ts alive-
fnGetAliveTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Last Zombie Check -check for last zombie and set its flag-
fnCheckLastZombie()
{
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Last zombie
		if (g_isalive[id] && g_zombie[id] && !g_nemesis[id] && fnGetZombies() == 1)
		{
			if (!g_lastzombie[id])
			{
				// Last zombie forward
				ExecuteForward(g_fwUserLastZombie, g_fwDummyResult, id);
			}
			g_lastzombie[id] = true
		}
		else
			g_lastzombie[id] = false
		
		// Last human
		if (g_isalive[id] && !g_zombie[id] && !g_survivor[id] && fnGetHumans() == 1)
		{
			if (!g_lasthuman[id]&&fnGetPlaying()>=3&&!g_newround)
			{
				// Last human forward
				ExecuteForward(g_fwUserLastHuman, g_fwDummyResult, id);
				
				new sound[64]
				ArrayGetString(sound_lastman, 0, sound, charsmax(sound))
				PlaySound(sound)
				
				set_dhudmessage(0, 255, 0, HUD_WARMUP_X, HUD_WARMUP_Y, 0, 0.0, 2.5, 0.0, 1.0)
				show_dhudmessage(0, "ВНИМАНИЕ^n%s^nОСТАЛСЯ ПОСЛЕДНИМ ЧЕЛОВЕКОМ!", g_playername[id])
				
				// Reward extra hp
				fm_set_user_health(id, 500)
			}
			g_lasthuman[id] = true
		}
		else
			g_lasthuman[id] = false
	}
}

// Save player's stats to database
save_stats(id)
{
	// Check whether there is another record already in that slot
	if (db_name[id][0] && !equal(g_playername[id], db_name[id]))
	{
		// If DB size is exceeded, write over old records
		if (db_slot_i >= sizeof db_name)
			db_slot_i = g_maxplayers+1
		
		// Move previous record onto an additional save slot
		copy(db_name[db_slot_i], charsmax(db_name[]), db_name[id])
		db_ammopacks[db_slot_i] = db_ammopacks[id]
		db_zombieclass[db_slot_i] = db_zombieclass[id]
		db_slot_i++
	}
	
	// Now save the current player stats
	copy(db_name[id], charsmax(db_name[]), g_playername[id]) // name
    db_ammopacks[id] = g_ammopacks[id]  // ammo packs
	db_zombieclass[id] = g_zombieclassnext[id] // zombie class
}

// Load player's stats from database (if a record is found)
load_stats(id)
{
	// Look for a matching record
	static i
	for (i = 0; i < sizeof db_name; i++)
	{
		if (equal(g_playername[id], db_name[i]))
		{
			// Bingo!
            g_ammopacks[id] = db_ammopacks[i]
			g_zombieclass[id] = db_zombieclass[i]
			g_zombieclassnext[id] = db_zombieclass[i]
			return;
		}
	}
}

// Checks if a player is allowed to be zombie
allowed_zombie(id)
{
	if ((g_zombie[id] && !g_nemesis[id]) || g_endround || !g_isalive[id] || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be human
allowed_human(id)
{
	if ((!g_zombie[id] && !g_survivor[id]) || g_endround || !g_isalive[id] || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be survivor
allowed_survivor(id)
{
	if (g_endround || g_survivor[id] || !g_isalive[id] || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be nemesis
allowed_nemesis(id)
{
	if (g_endround || g_nemesis[id] || !g_isalive[id] || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to respawn
allowed_respawn(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	if (g_endround || team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED || g_isalive[id])
		return false;
	
	return true;
}

// Checks if swarm mode is allowed
allowed_swarm()
{
	/*if (g_endround || !g_newround)
		return false;*/
	
	return true;
}

// Checks if multi infection mode is allowed
allowed_multi()
{
	if (g_endround || !g_newround || floatround(fnGetAlive()*get_pcvar_float(cvar_multiratio), floatround_ceil) < 2 || floatround(fnGetAlive()*get_pcvar_float(cvar_multiratio), floatround_ceil) >= fnGetAlive())
		return false;
	
	return true;
}

// Checks if plague mode is allowed
allowed_plague()
{
	if (g_endround || !g_newround || floatround((fnGetAlive()-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil) < 1
	|| fnGetAlive()-(get_pcvar_num(cvar_plaguesurvnum)+get_pcvar_num(cvar_plaguenemnum)+floatround((fnGetAlive()-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)) < 1)
		return false;
	
	return true;
}

// Admin Command. zp_zombie
command_zombie(id, player)
{	
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01сделал ^x04%s - ^x01Зомби!", g_playername[id], g_playername[player])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01сделал ^x04%s - ^x01Зомби!", g_playername[id], g_playername[player])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01сделал ^x04%s - ^x01Зомби!", g_playername[id], g_playername[player])

	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER, "CMD_INFECT", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		remove_task(TASK_WARMUP)
		make_a_zombie(MODE_INFECTION, player)
	}
	else
	{
		// Just infect
		zombieme(player, 0, 0, 0, 0)
	}
}

// Admin Command. zp_human
command_human(id, player)
{
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01сделал ^x04%s - ^x01Человеком!", g_playername[id], g_playername[player])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01сделал ^x04%s - ^x01Человеком!", g_playername[id], g_playername[player])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01сделал ^x04%s - ^x01Человеком!", g_playername[id], g_playername[player])
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_DISINFECT", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Turn to human
	humanme(player, 0, 0)
}

// Admin Command. zp_survivor
command_survivor(id, player)
{
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01сделал ^x04%s - ^x01Героем!", g_playername[id], g_playername[player])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01сделал ^x04%s - ^x01Героем!", g_playername[id], g_playername[player])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01сделал ^x04%s - ^x01Героем!", g_playername[id], g_playername[player])

	 // Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_SURVIVAL", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		remove_task(TASK_WARMUP)
		make_a_zombie(MODE_SURVIVOR, player)
	}
	else
	{
		// Turn player into a Survivor
		humanme(player, 1, 0)
	}
}

// Admin Command. zp_nemesis
command_nemesis(id, player)
{	
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01сделал ^x04%s - ^x01Дьяволом!", g_playername[id], g_playername[player])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01сделал ^x04%s - ^x01Дьяволом!", g_playername[id], g_playername[player])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01сделал ^x04%s - ^x01Дьяволом!", g_playername[id], g_playername[player])

	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_NEMESIS", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		remove_task(TASK_WARMUP)
		make_a_zombie(MODE_NEMESIS, player)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(player, 0, 1, 0, 0)
	}
}

// Admin Command. zp_respawn
command_respawn(id, player)
{
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01возродил ^x04%s", g_playername[id], g_playername[player])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01возродил ^x04%s", g_playername[id], g_playername[player])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01возродил ^x04%s", g_playername[id], g_playername[player])


	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER, "CMD_RESPAWN", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Respawn as zombie?
	if (get_pcvar_num(cvar_deathmatch) == 2 || (get_pcvar_num(cvar_deathmatch) == 3 && random_num(0, 1)) || (get_pcvar_num(cvar_deathmatch) == 4 && fnGetZombies() < fnGetAlive()/2))
		g_respawn_as_zombie[player] = true
	
	// Override respawn as zombie setting on nemesis and survivor rounds
	if (g_survround) g_respawn_as_zombie[player] = true
	else if (g_nemround) g_respawn_as_zombie[player] = false
	
	respawn_player_manually(player);
}

// Admin Command. zp_swarm
command_swarm(id)
{
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01запустил ^x04Кучу на кучу!", g_playername[id])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01запустил ^x04Кучу на кучу!", g_playername[id])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01запустил ^x04Кучу на кучу!", g_playername[id])

	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER, "CMD_SWARM", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Swarm Mode
	remove_task(TASK_MAKEZOMBIE)
	remove_task(TASK_WARMUP)
	make_a_zombie(MODE_SWARM, 0)
}

// Admin Command. zp_multi
command_multi(id)
{
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01запустил ^x04Массовое заражение!", g_playername[id])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01запустил ^x04Массовое заражение!", g_playername[id])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01запустил ^x04Массовое заражение!", g_playername[id])

	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_MULTI", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Multi Infection
	remove_task(TASK_MAKEZOMBIE)
	remove_task(TASK_WARMUP)
	make_a_zombie(MODE_MULTI, 0)
}

// Admin Command. zp_plague
command_plague(id)
{
    if(get_user_flags(id) & ADMIN_CVAR) zp_colored_print(0, "^x04[ZP] ^x01Создатель ^x04%s ^x01запустил ^x04Чуму!", g_playername[id])
	else if(get_user_flags(id) & ADMIN_LEVEL_D) zp_colored_print(0, "^x04[ZP] ^x01Босс ^x04%s ^x01запустил ^x04Чуму!", g_playername[id])
    else zp_colored_print(0, "^x04[ZP] ^x01Админ ^x04%s ^x01запустил ^x04Чуму!", g_playername[id])

	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_PLAGUE", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Plague Mode
	remove_task(TASK_MAKEZOMBIE)
	remove_task(TASK_WARMUP)
	make_a_zombie(MODE_PLAGUE, 0)
}

// Set proper maxspeed for player
set_player_maxspeed(id)
{
	// If frozen, prevent from moving
	if (g_frozen[id])
	{
		set_pev(id, pev_maxspeed, 1.0)
	}
	// Otherwise, set maxspeed directly
	else
	{
		if (g_zombie[id])
		{
			if (g_nemesis[id])
				set_pev(id, pev_maxspeed, get_pcvar_float(cvar_nemspd))
			else
				set_pev(id, pev_maxspeed, g_zombie_spd[id])
		}
		else
		{
			if (g_survivor[id])
				set_pev(id, pev_maxspeed, 260.0)
			else if(g_currentweapon[id]==CSW_KNIFE){
				switch(g_knife[id]){
					case 2: set_pev(id, pev_maxspeed, 320.0+g_pts[id][2]+5)
					case 3: set_pev(id, pev_maxspeed, 310.0+g_pts[id][2]+5)
					case 4: set_pev(id, pev_maxspeed, 310.0+g_pts[id][2]+5)
					case 5: set_pev(id, pev_maxspeed, 310.0+g_pts[id][2]+5)
					case 6: set_pev(id, pev_maxspeed, 310.0+g_pts[id][2]+5)
					default: set_pev(id, pev_maxspeed, 290.0+g_pts[id][2]+5)
				}
			}
			else {
				if(g_pts[id][2]) set_pev(id, pev_maxspeed, 250.0+g_pts[id][2]+5)
				else set_pev(id, pev_maxspeed, 250.0)
			}
		}
	}
}

/*================================================================================
 [Custom Natives]
=================================================================================*/

// Native: zp_get_user_zombie
public native_get_user_zombie(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_zombie[id];
}

// Native: zp_get_user_nemesis
public native_get_user_nemesis(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_nemesis[id];
}

// Native: zp_get_user_survivor
public native_get_user_survivor(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_survivor[id];
}

public native_get_user_first_zombie(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_firstzombie[id];
}

// Native: zp_get_user_last_zombie
public native_get_user_last_zombie(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_lastzombie[id];
}

// Native: zp_get_user_last_human
public native_get_user_last_human(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_lasthuman[id];
}

// Native: zp_get_user_zombie_class
public native_get_user_zombie_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_zombieclass[id];
}

// Native: zp_get_user_next_class
public native_get_user_next_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_zombieclassnext[id];
}

// Native: zp_set_user_zombie_class
public native_set_user_zombie_class(id, classid)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	if (classid < 0 || classid >= g_zclass_i)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
		return false;
	}
	
	g_zombieclassnext[id] = classid
	return true;
}

// Native: zp_get_user_ammo_packs
public native_get_user_ammo_packs(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_ammopacks[id];
}

// Native: zp_set_user_ammo_packs
public native_set_user_ammo_packs(id, amount)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	g_ammopacks[id] = amount;
	return true;
}

public native_get_user_lvl(id)
{
	return g_lvl[id];
}

public native_set_user_lvl(id, amount)
{
	g_lvl[id] = amount;
	return true;
}

public native_get_user_exp(id)
{
	return g_exp[id];
}

public native_set_user_exp(id, amount)
{	
	g_exp[id] = amount;
	return true;
}

public native_get_user_pts(id, pts)
{
	return g_pts[id][pts];
}

public native_set_user_pts(id, pts,amount)
{
	g_pts[id][pts] = amount;
	return true;
}

// Native: zp_get_zombie_maxhealth
public native_get_zombie_maxhealth(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	if (!g_zombie[id] || g_nemesis[id])
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Player not a normal zombie (%d)", id)
		return -1;
	}
	
	if (g_firstzombie[id])
		return floatround(float(ArrayGetCell(g_zclass_hp, g_zombieclass[id])) * 2.0);
	
	return ArrayGetCell(g_zclass_hp, g_zombieclass[id]);
}

// Native: zp_get_user_batteries
public native_get_user_batteries(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_flashbattery[id];
}

// Native: zp_set_user_batteries
public native_set_user_batteries(id, value)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	g_flashbattery[id] = clamp(value, 0, 100);
	
	if (g_cached_customflash)
	{
		// Set the flashlight charge task to update battery status
		remove_task(id+TASK_CHARGE)
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
	}
	return true;
}

// Native: zp_infect_user
public native_infect_user(id, infector, silent, rewards)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be zombie
	if (!allowed_zombie(id))
		return false;
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		remove_task(TASK_WARMUP)
		make_a_zombie(MODE_INFECTION, id)
	}
	else
	{
		// Just infect (plus some checks)
		zombieme(id, is_user_valid_alive(infector) ? infector : 0, 0, (silent == 1) ? 1 : 0, (rewards == 1) ? 1 : 0)
	}
	return true;
}

// Native: zp_disinfect_user
public native_disinfect_user(id, silent)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be human
	if (!allowed_human(id))
		return false;
	
	// Turn to human
	humanme(id, 0, (silent == 1) ? 1 : 0)
	return true;
}

// Native: zp_make_user_nemesis
public native_make_user_nemesis(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be nemesis
	if (!allowed_nemesis(id))
		return false;
	
	// New round?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		remove_task(TASK_WARMUP)
		make_a_zombie(MODE_NEMESIS, id)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(id, 0, 1, 0, 0)
	}
	return true;
}

// Native: zp_make_user_survivor
public native_make_user_survivor(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be survivor
	if (!allowed_survivor(id))
		return false;
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		remove_task(TASK_WARMUP)
		make_a_zombie(MODE_SURVIVOR, id)
	}
	else
	{
		// Turn player into a Survivor
		humanme(id, 1, 0)
	}
	
	return true;
}

// Native: zp_respawn_user
public native_respawn_user(id, team)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Respawn not allowed
	if (!allowed_respawn(id))
		return false;
	
	// Respawn as zombie?
	g_respawn_as_zombie[id] = (team == ZP_TEAM_ZOMBIE) ? true : false
	
	// Respawnish!
	respawn_player_manually(id)
	return true;
}

// Native: zp_force_buy_extra_item
public native_force_buy_extra_item(id, itemid, ignorecost)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	if (itemid < 0 || itemid >= g_extraitem_i)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid extra item id (%d)", itemid)
		return false;
	}
	
	buy_extra_item(id, itemid, ignorecost)
	return true;
}

// Native: zp_override_user_model
public native_override_user_model(id, const newmodel[], modelindex)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Strings passed byref
	param_convert(2)
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	
	// Custom models stuff
	static currentmodel[32]
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		copy(g_playermodel[id], charsmax(g_playermodel[]), newmodel)
		if (g_set_modelindex_offset && modelindex) fm_cs_set_user_model_index(id, modelindex)
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (!equal(currentmodel, newmodel))
		{
			copy(g_playermodel[id], charsmax(g_playermodel[]), newmodel)
			if (g_set_modelindex_offset && modelindex) fm_cs_set_user_model_index(id, modelindex)
			
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
	}
	return true;
}

// Native: zp_has_round_started
public native_has_round_started()
{
	if (g_newround) return 0; // not started
	if (g_modestarted) return 1; // started
	return 2; // starting
}

// Native: zp_is_nemesis_round
public native_is_nemesis_round()
{
	return g_nemround;
}

// Native: zp_is_survivor_round
public native_is_survivor_round()
{
	return g_survround;
}

// Native: zp_is_swarm_round
public native_is_swarm_round()
{
	return g_swarmround;
}

// Native: zp_is_plague_round
public native_is_plague_round()
{
	return g_plagueround;
}

// Native: zp_get_zombie_count
public native_get_zombie_count()
{
	return fnGetZombies();
}

// Native: zp_get_human_count
public native_get_human_count()
{
	return fnGetHumans();
}

// Native: zp_get_nemesis_count
public native_get_nemesis_count()
{
	return fnGetNemesis();
}

// Native: zp_get_survivor_count
public native_get_survivor_count()
{
	return fnGetSurvivors();
}

// Native: zp_register_extra_item
public native_register_extra_item(const name[], cost, bolt, team)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Arrays not yet initialized
	if (!g_arrays_created)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register extra item yet (%s)", name)
		return -1;
	}
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register extra item with an empty name")
		return -1;
	}
	
	new index, extraitem_name[128]
	for (index = 0; index < g_extraitem_i; index++)
	{
		ArrayGetString(g_extraitem_realname, index, extraitem_name, charsmax(extraitem_name))
		if (equali(name, extraitem_name))
		{
			// Return id under which we registered the item
			return index;
		}
	}
	
	// For backwards compatibility
	if (team == ZP_TEAM_ANY)
		team = (ZP_TEAM_ZOMBIE|ZP_TEAM_HUMAN)
	
	// Add the item
	ArrayPushString(g_extraitem_realname, name)
	ArrayPushString(g_extraitem_name, name)
	ArrayPushCell(g_extraitem_cost, cost)
	ArrayPushCell(g_extraitem_bolt, bolt)
	ArrayPushCell(g_extraitem_team, team)
	ArrayPushCell(g_extraitem_slot, EQUIPMENT)
	ArrayPushCell(g_extraitem_lvl, 0)
	ArrayPushString(g_extraitem_weapon, "NONE")
	
	// Set temporary new item flag
	ArrayPushCell(g_extraitem_new, 1)
	g_extraitem_i++

	// Return id under which we registered the item
	return g_extraitem_i-1;
}

// Native: zp_register_zombie_class
public native_register_zombie_class(const name[], const info[], const model[], const clawmodel[], hp, speed, Float:gravity, Float:knockback)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	param_convert(2)
	param_convert(3)
	param_convert(4)
	
	// Arrays not yet initialized
	if (!g_arrays_created)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register zombie class yet (%s)", name)
		return -1;
	}
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register zombie class with an empty name")
		return -1;
	}
	
	new index, zombieclass_name[32]
	for (index = 0; index < g_zclass_i; index++)
	{
		ArrayGetString(g_zclass_name, index, zombieclass_name, charsmax(zombieclass_name))
		if (equali(name, zombieclass_name))
		{
			log_error(AMX_ERR_NATIVE, "[ZP] Zombie class already registered (%s)", name)
			return -1;
		}
	}
	
	// Add the class
	ArrayPushString(g_zclass_name, name)
	ArrayPushString(g_zclass_info, info)
	
	// Using same zombie models for all classes?
	if (g_same_models_for_all)
	{
		ArrayPushCell(g_zclass_modelsstart, 0)
		ArrayPushCell(g_zclass_modelsend, ArraySize(g_zclass_playermodel))
	}
	else
	{
		ArrayPushCell(g_zclass_modelsstart, ArraySize(g_zclass_playermodel))
		ArrayPushString(g_zclass_playermodel, model)
		ArrayPushCell(g_zclass_modelsend, ArraySize(g_zclass_playermodel))
		ArrayPushCell(g_zclass_modelindex, -1)
	}
	
	ArrayPushString(g_zclass_clawmodel, clawmodel)
	new szZombibomb[32]
	formatex(szZombibomb, 31, "v_zombibomb.mdl")
	ArrayPushString(g_zclass_zbombmodel, szZombibomb)
	ArrayPushCell(g_zclass_hp, hp)
	ArrayPushCell(g_zclass_spd, speed)
	ArrayPushCell(g_zclass_grav, gravity)
	ArrayPushCell(g_zclass_kb, knockback)
	
	// Set temporary new class flag
	ArrayPushCell(g_zclass_new, 1)
	
	// Override zombie classes data with our customizations
	new i, k, buffer[32], Float:buffer2, nummodels_custom, nummodels_default, prec_mdl[100], size = ArraySize(g_zclass2_realname)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(g_zclass2_realname, i, buffer, charsmax(buffer))
		
		// Check if this is the intended class to override
		if (!equal(name, buffer))
			continue;
		
		// Remove new class flag
		ArraySetCell(g_zclass_new, g_zclass_i, 0)
		
		// Replace caption
		ArrayGetString(g_zclass2_name, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_name, g_zclass_i, buffer)
		
		// Replace info
		ArrayGetString(g_zclass2_info, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_info, g_zclass_i, buffer)
		
		// Replace models, unless using same models for all classes
		if (!g_same_models_for_all)
		{
			nummodels_custom = ArrayGetCell(g_zclass2_modelsend, i) - ArrayGetCell(g_zclass2_modelsstart, i)
			nummodels_default = ArrayGetCell(g_zclass_modelsend, g_zclass_i) - ArrayGetCell(g_zclass_modelsstart, g_zclass_i)
			
			// Replace each player model and model index
			for (k = 0; k < min(nummodels_custom, nummodels_default); k++)
			{
				ArrayGetString(g_zclass2_playermodel, ArrayGetCell(g_zclass2_modelsstart, i) + k, buffer, charsmax(buffer))
				ArraySetString(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k, buffer)
				
				// Precache player model and replace its modelindex with the real one
				formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
				ArraySetCell(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k, engfunc(EngFunc_PrecacheModel, prec_mdl))
				if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
				if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
				// Precache modelT.mdl files too
				copy(prec_mdl[strlen(prec_mdl)-4], charsmax(prec_mdl) - (strlen(prec_mdl)-4), "T.mdl")
				if (file_exists(prec_mdl)) engfunc(EngFunc_PrecacheModel, prec_mdl)
			}
			
			// We have more custom models than what we can accommodate,
			// Let's make some space...
			if (nummodels_custom > nummodels_default)
			{
				for (k = nummodels_default; k < nummodels_custom; k++)
				{
					ArrayGetString(g_zclass2_playermodel, ArrayGetCell(g_zclass2_modelsstart, i) + k, buffer, charsmax(buffer))
					ArrayInsertStringAfter(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k - 1, buffer)
					
					// Precache player model and retrieve its modelindex
					formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
					ArrayInsertCellAfter(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k - 1, engfunc(EngFunc_PrecacheModel, prec_mdl))
					if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
					if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
					// Precache modelT.mdl files too
					copy(prec_mdl[strlen(prec_mdl)-4], charsmax(prec_mdl) - (strlen(prec_mdl)-4), "T.mdl")
					if (file_exists(prec_mdl)) engfunc(EngFunc_PrecacheModel, prec_mdl)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_zclass_modelsend, g_zclass_i, ArrayGetCell(g_zclass_modelsend, g_zclass_i) + (nummodels_custom - nummodels_default))
			}
			
			/* --- Not needed since classes can't have more than 1 default model for now ---
			// We have less custom models than what this class has by default,
			// Get rid of those extra entries...
			if (nummodels_custom < nummodels_default)
			{
				for (k = nummodels_custom; k < nummodels_default; k++)
				{
					ArrayDeleteItem(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + nummodels_custom)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_zclass_modelsend, g_zclass_i, ArrayGetCell(g_zclass_modelsend, g_zclass_i) - (nummodels_default - nummodels_custom))
			}
			*/
		}
		
		// Replace clawmodel
		ArrayGetString(g_zclass2_clawmodel, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_clawmodel, g_zclass_i, buffer)
		
		// Precache clawmodel
		formatex(prec_mdl, charsmax(prec_mdl), "models/BZ_models/%s", buffer)
		engfunc(EngFunc_PrecacheModel, prec_mdl)
		
		ArrayGetString(g_zclass2_zbombmodel, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_zbombmodel, g_zclass_i, buffer)
		
		formatex(prec_mdl, charsmax(prec_mdl), "models/BZ_models/%s", buffer)
		engfunc(EngFunc_PrecacheModel, prec_mdl)
		
		// Replace health
		buffer[0] = ArrayGetCell(g_zclass2_hp, i)
		ArraySetCell(g_zclass_hp, g_zclass_i, buffer[0])
		
		// Replace speed
		buffer[0] = ArrayGetCell(g_zclass2_spd, i)
		ArraySetCell(g_zclass_spd, g_zclass_i, buffer[0])
		
		// Replace gravity
		buffer2 = Float:ArrayGetCell(g_zclass2_grav, i)
		ArraySetCell(g_zclass_grav, g_zclass_i, buffer2)
		
		// Replace knockback
		buffer2 = Float:ArrayGetCell(g_zclass2_kb, i)
		ArraySetCell(g_zclass_kb, g_zclass_i, buffer2)
	}
	
	// If class was not overriden with customization data
	if (ArrayGetCell(g_zclass_new, g_zclass_i))
	{
		// If not using same models for all classes
		if (!g_same_models_for_all)
		{
			// Precache default class model and replace modelindex with the real one
			formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", model, model)
			ArraySetCell(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i), engfunc(EngFunc_PrecacheModel, prec_mdl))
			if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
			if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
			// Precache modelT.mdl files too
			copy(prec_mdl[strlen(prec_mdl)-4], charsmax(prec_mdl) - (strlen(prec_mdl)-4), "T.mdl")
			if (file_exists(prec_mdl)) engfunc(EngFunc_PrecacheModel, prec_mdl)
		}
		
		// Precache default clawmodel
		formatex(prec_mdl, charsmax(prec_mdl), "models/BZ_models/%s", clawmodel)
		engfunc(EngFunc_PrecacheModel, prec_mdl)
	}
	
	// Increase registered classes counter
	g_zclass_i++
	
	// Return id under which we registered the class
	return g_zclass_i-1;
}

// Native: zp_get_extra_item_id
public native_get_extra_item_id(const name[])
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Loop through every item (not using Tries since ZP should work on AMXX 1.8.0)
	static i, item_name[32]
	for (i = 0; i < g_extraitem_i; i++)
	{
		ArrayGetString(g_extraitem_name, i, item_name, charsmax(item_name))
		
		// Check if this is the item to retrieve
		if (equali(name, item_name))
			return i;
	}
	
	return -1;
}

// Native: zp_get_zombie_class_id
public native_get_zombie_class_id(const name[])
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Loop through every class (not using Tries since ZP should work on AMXX 1.8.0)
	static i, class_name[32]
	for (i = 0; i < g_zclass_i; i++)
	{
		ArrayGetString(g_zclass_name, i, class_name, charsmax(class_name))
		
		// Check if this is the class to retrieve
		if (equali(name, class_name))
			return i;
	}
	
	return -1;
}

// Native: zp_get_zombie_class_info
public native_get_zombie_class_info(classid, info[], len)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	// Invalid class
	if (classid < 0 || classid >= g_zclass_i)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
		return false;
	}
	
	// Strings passed byref
	param_convert(2)
	
	// Fetch zombie class info
	ArrayGetString(g_zclass_info, classid, info, len)
	return true;
}

/*================================================================================
 [Custom Messages]
=================================================================================*/

// Custom Flashlight
public set_user_flashlight(taskid)
{
	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(ID_FLASH, pev_origin, originF)
	fm_get_aim_origin(ID_FLASH, destoriginF)
	
	// Max distance check
	if (get_distance_f(originF, destoriginF) > get_pcvar_float(cvar_flashdist))
		return;
	
	// Send to all players?
	if (get_pcvar_num(cvar_flashshowall))
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, destoriginF, 0)
	else
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_FLASH)
	
	// Flashlight
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, destoriginF[0]) // x
	engfunc(EngFunc_WriteCoord, destoriginF[1]) // y
	engfunc(EngFunc_WriteCoord, destoriginF[2]) // z
	write_byte(get_pcvar_num(cvar_flashsize)) // radius
	write_byte(get_pcvar_num(cvar_flashcolor[0])) // r
	write_byte(get_pcvar_num(cvar_flashcolor[1])) // g
	write_byte(get_pcvar_num(cvar_flashcolor[2])) // b
	write_byte(3) // life
	write_byte(0) // decay rate
	message_end()
}

// Infection special effects
infection_effects(id)
{
	// Screen fade? (unless frozen)
	if (!g_frozen[id] && get_pcvar_num(cvar_infectionscreenfade))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
		write_short(UNIT_SECOND) // duration
		write_short(0) // hold time
		write_short(FFADE_IN) // fade type
		write_byte(255) // r
		write_byte(0) // g
		write_byte(0) // b
		write_byte (255) // alpha
		message_end()
	}
	
	// Screen shake?
	if (get_pcvar_num(cvar_infectionscreenshake))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
		write_short(UNIT_SECOND*4) // amplitude
		write_short(UNIT_SECOND*2) // duration
		write_short(UNIT_SECOND*10) // frequency
		message_end()
	}
	
	// Infection icon?
	if (get_pcvar_num(cvar_hudicons))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_NERVEGAS) // damage type - DMG_RADIATION
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(id, origin)
	
	// Tracers?
	if (get_pcvar_num(cvar_infectiontracers))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_IMPLOSION) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(128) // radius
		write_byte(20) // count
		write_byte(3) // duration
		message_end()
	}
	
	// Particle burst?
	if (get_pcvar_num(cvar_infectionparticles))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_PARTICLEBURST) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_short(50) // radius
		write_byte(70) // color
		write_byte(3) // duration (will be randomized a bit)
		message_end()
	}
	
	// Light sparkle?
	if (get_pcvar_num(cvar_infectionsparkle))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_DLIGHT) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(20) // radius
		write_byte(255) // r
		write_byte(0) // g
		write_byte(0) // b
		write_byte(2) // life
		write_byte(0) // decay rate
		message_end()
	}
}

// Nemesis/madness aura task
public zombie_aura(taskid)
{
	// Not nemesis, not in zombie madness
	if (!g_nemesis[ID_AURA] && !g_nodamage[ID_AURA])
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(ID_AURA, origin)
	
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(20) // radius
	write_byte(255) // r
	write_byte(0) // g
	write_byte(0) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

// Make zombies leave footsteps and bloodstains on the floor
public make_blood(taskid)
{
	// Only bleed when moving on ground
	if (!(pev(ID_BLOOD, pev_flags) & FL_ONGROUND) || fm_get_speed(ID_BLOOD) < 80)
		return;
	
	// Get user origin
	static Float:originF[3]
	pev(ID_BLOOD, pev_origin, originF)
	
	// If ducking set a little lower
	if (pev(ID_BLOOD, pev_bInDuck))
		originF[2] -= 18.0
	else
		originF[2] -= 36.0
	
	// Send the decal message
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_WORLDDECAL) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(ArrayGetCell(zombie_decals, random_num(0, ArraySize(zombie_decals) - 1)) + (g_czero * 12)) // random decal number (offsets +12 for CZ)
	message_end()
}

// Flare Lighting Effects
/*flare_lighting(entity, duration)
{
	// Get origin and color
	static Float:originF[3], color[3]
	pev(entity, pev_origin, originF)
	pev(entity, PEV_FLARE_COLOR, color)
	
	// Lighting
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(get_pcvar_num(cvar_flaresize)) // radius
	write_byte(color[0]) // r
	write_byte(color[1]) // g
	write_byte(color[2]) // b
	write_byte(21) //life
	write_byte((duration < 2) ? 3 : 0) //decay rate
	message_end()
	
	// Sparks
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPARKS) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	message_end()
}*/

// Burning Flames
public burning_flame(taskid)
{
	// Get player origin and flags
	static origin[3], flags
	get_user_origin(ID_BURN, origin)
	flags = pev(ID_BURN, pev_flags)
	
	// Madness mode - in water - burning stopped
	if (g_nodamage[ID_BURN] || (flags & FL_INWATER) || g_burning_duration[ID_BURN] < 1)
	{
		// Smoke sprite
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_SMOKE) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]-50) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Randomly play burning zombie scream sounds (not for nemesis)
	if (!g_nemesis[ID_BURN] && !random_num(0, 20))
	{
		static sound[64]
		ArrayGetString(grenade_fire_player, random_num(0, ArraySize(grenade_fire_player) - 1), sound, charsmax(sound))
		emit_sound(ID_BURN, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Fire slow down, unless nemesis
	if (!g_nemesis[ID_BURN] && (flags & FL_ONGROUND) && get_pcvar_float(cvar_fireslowdown) > 0.0)
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, get_pcvar_float(cvar_fireslowdown), velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}
	
	// Get player's health
	static health
	health = pev(ID_BURN, pev_health)
	
	// Take damage from the fire
	if (health - floatround(get_pcvar_float(cvar_firedamage), floatround_ceil) > 0)
		fm_set_user_health(ID_BURN, health - floatround(get_pcvar_float(cvar_firedamage), floatround_ceil))
	
	// Flame sprite
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE) // TE id
	write_coord(origin[0]+random_num(-5, 5)) // x
	write_coord(origin[1]+random_num(-5, 5)) // y
	write_coord(origin[2]+random_num(-10, 10)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	// Decrease burning duration counter
	g_burning_duration[ID_BURN]--
}

create_pipe_blast(entity)
{
	new Float:originF[3]
	pev(entity, pev_origin, originF)
	
	emit_sound(entity, CHAN_VOICE, "weapons/lasthope_beep.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(200) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

create_pipe_blast2(entity)
{
	new Float:originF[3]
	pev(entity, pev_origin, originF)
	
	emit_sound(entity, CHAN_VOICE, "weapons/lasthope_beep.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(200) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Infection Bomb: Green Blast
/*create_blast(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}*/

// Fire Grenade: Fire Blast
create_blast2(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(255) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(200) // red
	write_byte(20) // green
	write_byte(20) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Frost Grenade: Freeze Blast
create_blast3(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(255) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(50) // green
	write_byte(250) // blue
	write_byte(250) // brightness
	write_byte(0) // speed
	message_end()
}


create_blast4(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(255) // green
	write_byte(127) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(15) // red
	write_byte(50) // green
	write_byte(255) // blue
	write_byte(100) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(215) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

create_blast5(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(250) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Fix Dead Attrib on scoreboard
FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
}

// Send Death Message for infections
SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) // killer
	write_byte(victim) // victim
	write_byte(1) // headshot flag
	write_string("infection") // killer's weapon
	message_end()
}

// Update Player Frags and Deaths
UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	// Set attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	// Set victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	
	// Update scoreboard with attacker and victim info
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(cs_get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(attacker)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(victim) // id
		write_short(pev(victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(victim)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(victim)) // team
		message_end()
	}
}

// Remove Player Frags (when Nemesis/Survivor ignore_frags cvar is enabled)
RemoveFrags(attacker, victim)
{
	// Remove attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) - 1))
	
	// Remove victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) - 1)
}

// Plays a sound on clients
PlaySound(const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(0, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(0, "spk ^"%s^"", sound)
}

PlaySoundId(const sound[],id)
{
	client_cmd(id, "spk ^"%s^"", sound)
}

// Prints a colored message to target (use 0 for everyone), supports ML formatting.
// Note: I still need to make something like gungame's LANG_PLAYER_C to avoid unintended
// argument replacement when a function passes -1 (it will be considered a LANG_PLAYER)
zp_colored_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	
	// Send to everyone
	if (!target)
	{
		static player
		for (player = 1; player <= g_maxplayers; player++)
		{
			// Not connected
			if (!g_isconnected[player])
				continue;
			
			// Remember changed arguments
			static changed[5], changedcount // [5] = max LANG_PLAYER occurencies
			changedcount = 0
			
			// Replace LANG_PLAYER with player id
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			// Format message for player
			vformat(buffer, charsmax(buffer), message, 3)
			
			// Send it
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			// Replace back player id's with LANG_PLAYER
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	// Send to specific target
	else
	{
		/*
		// Not needed since you should set the ML argument
		// to the player's id for a targeted print message
		
		// Replace LANG_PLAYER with player id
		for (i = 2; i < argscount; i++)
		{
			if (getarg(i) == LANG_PLAYER)
				setarg(i, 0, target)
		}
		*/
		
		// Format message for player
		vformat(buffer, charsmax(buffer), message, 3)
		
		// Send it
		message_begin(MSG_ONE, g_msgSayText, _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}

/*================================================================================
 [Stocks]
=================================================================================*/

// Set an entity's key value (from fakemeta_util)
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity));
}

// Get entity's aim origins (from fakemeta_util)
stock fm_get_aim_origin(id, Float:origin[3])
{
	static Float:origin1F[3], Float:origin2F[3]
	pev(id, pev_origin, origin1F)
	pev(id, pev_view_ofs, origin2F)
	xs_vec_add(origin1F, origin2F, origin1F)

	pev(id, pev_v_angle, origin2F);
	engfunc(EngFunc_MakeVectors, origin2F)
	global_get(glb_v_forward, origin2F)
	xs_vec_mul_scalar(origin2F, 9999.0, origin2F)
	xs_vec_add(origin1F, origin2F, origin2F)

	engfunc(EngFunc_TraceLine, origin1F, origin2F, 0, id, 0)
	get_tr2(0, TR_vecEndPos, origin)
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

// Give an item to a player (from fakemeta_util)
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF)
	set_pev(ent, pev_origin, originF)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	static save
	save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, id)
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent)
}

// Strip user weapons (from fakemeta_util)
stock fm_strip_user_weapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	engfunc(EngFunc_RemoveEntity, ent)
}

// Collect random spawn points
stock load_spawns()
{
	// Check for CSDM spawns of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), "%s/csdm/%s.spawns.cfg", cfgdir, mapname)
	
	// Load CSDM spawns if present
	if (file_exists(filepath))
	{
		new csdmdata[10][6], file = fopen(filepath,"rt")
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			
			// invalid spawn
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			
			// get spawn point data
			parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5,csdmdata[3],5,csdmdata[4],5,csdmdata[5],5,csdmdata[6],5,csdmdata[7],5,csdmdata[8],5,csdmdata[9],5)
			
			// origin
			g_spawns[g_spawnCount][0] = floatstr(csdmdata[0])
			g_spawns[g_spawnCount][1] = floatstr(csdmdata[1])
			g_spawns[g_spawnCount][2] = floatstr(csdmdata[2])
			
			// increase spawn count
			g_spawnCount++
			if (g_spawnCount >= sizeof g_spawns) break;
		}
		if (file) fclose(file)
	}
	else
	{
		// Collect regular spawns
		collect_spawns_ent("info_player_start")
		collect_spawns_ent("info_player_deathmatch")
	}
	
	// Collect regular spawns for non-random spawning unstuck
	collect_spawns_ent2("info_player_start")
	collect_spawns_ent2("info_player_deathmatch")
}

// Collect spawn points from entity origins
stock collect_spawns_ent(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns[g_spawnCount][0] = originF[0]
		g_spawns[g_spawnCount][1] = originF[1]
		g_spawns[g_spawnCount][2] = originF[2]
		
		// increase spawn count
		g_spawnCount++
		if (g_spawnCount >= sizeof g_spawns) break;
	}
}

// Collect spawn points from entity origins
stock collect_spawns_ent2(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns2[g_spawnCount2][0] = originF[0]
		g_spawns2[g_spawnCount2][1] = originF[1]
		g_spawns2[g_spawnCount2][2] = originF[2]
		
		// increase spawn count
		g_spawnCount2++
		if (g_spawnCount2 >= sizeof g_spawns2) break;
	}
}

// Drop primary/secondary weapons
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			// Hack: store weapon bpammo on PEV_ADDITIONAL_AMMO
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

// Stock by (probably) Twilight Suzuka -counts number of chars in a string
stock str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

// Checks if a space is vacant (credits to VEN)
stock is_hull_vacant(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Check if a player is stuck (credits to VEN)
stock is_player_stuck(id)
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Simplified get_weaponid (CS only)
stock cs_weapon_name_to_id(const weapon[])
{
	static i
	for (i = 0; i < sizeof WEAPONENTNAMES; i++)
	{
		if (equal(weapon, WEAPONENTNAMES[i]))
			return i;
	}
	
	return 0;
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

// Get Weapon Entity's Owner
stock fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

// Set User Deaths
stock fm_cs_set_user_deaths(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}

// Get User Team
stock fm_cs_get_user_team(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return FM_CS_TEAM_UNASSIGNED;
	
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

// Set a Player's Team
stock fm_cs_set_user_team(id, team)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX)
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSMONEY, value, OFFSET_LINUX)
}

// Set User Flashlight Batteries
stock fm_cs_set_user_batteries(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX)
}

// Update Player's Team on all clients (adding needed delays)
stock fm_user_team_update(id)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_teams_targettime >= 0.1)
	{
		set_task(0.1, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = current_time + 0.1
	}
	else
	{
		set_task((g_teams_targettime + 0.1) - current_time, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = g_teams_targettime + 0.1
	}
}

// Send User Team Message
public fm_cs_set_user_team_msg(taskid)
{
	// Note to self: this next message can now be received by other plugins
	
	// Set the switching team flag
	g_switchingteam = true
	
	// Tell everyone my new team
	emessage_begin(MSG_ALL, g_msgTeamInfo)
	ewrite_byte(ID_TEAM) // player
	ewrite_string(CS_TEAM_NAMES[fm_cs_get_user_team(ID_TEAM)]) // team
	emessage_end()
	
	// Done switching team
	g_switchingteam = false
}

// Set the precached model index (updates hitboxes server side)
stock fm_cs_set_user_model_index(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_MODELINDEX, value, OFFSET_LINUX)
}

// Set Player Model on Entity
stock fm_set_playermodel_ent(id)
{
	// Make original player entity invisible without hiding shadows or firing effects
	fm_set_rendering(id, kRenderFxNone, 255, 255, 255, kRenderTransTexture, 1)
	
	// Format model string
	static model[100]
	formatex(model, charsmax(model), "models/player/%s/%s.mdl", g_playermodel[id], g_playermodel[id])
	
	// Set model on entity or make a new one if unexistant
	if (!pev_valid(g_ent_playermodel[id]))
	{
		g_ent_playermodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_playermodel[id])) return;
		
		set_pev(g_ent_playermodel[id], pev_classname, MODEL_ENT_CLASSNAME)
		set_pev(g_ent_playermodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_playermodel[id], pev_aiment, id)
		set_pev(g_ent_playermodel[id], pev_owner, id)
	}
	
	engfunc(EngFunc_SetModel, g_ent_playermodel[id], model)
}

// Set Weapon Model on Entity
stock fm_set_weaponmodel_ent(id)
{
	// Get player's p_ weapon model
	static model[100]
	pev(id, pev_weaponmodel2, model, charsmax(model))
	
	// Set model on entity or make a new one if unexistant
	if (!pev_valid(g_ent_weaponmodel[id]))
	{
		g_ent_weaponmodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_weaponmodel[id])) return;
		
		set_pev(g_ent_weaponmodel[id], pev_classname, WEAPON_ENT_CLASSNAME)
		set_pev(g_ent_weaponmodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_weaponmodel[id], pev_aiment, id)
		set_pev(g_ent_weaponmodel[id], pev_owner, id)
	}
	
	engfunc(EngFunc_SetModel, g_ent_weaponmodel[id], model)
}

// Remove Custom Model Entities
stock fm_remove_model_ents(id)
{
	// Remove "playermodel" ent if present
	if (pev_valid(g_ent_playermodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_playermodel[id])
		g_ent_playermodel[id] = 0
	}
	// Remove "weaponmodel" ent if present
	if (pev_valid(g_ent_weaponmodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_weaponmodel[id])
		g_ent_weaponmodel[id] = 0
	}
}

// Set User Model
public fm_cs_set_user_model(taskid)
{
	set_user_info(ID_MODEL, "model", g_playermodel[ID_MODEL])
}

// Get User Model -model passed byref-
stock fm_cs_get_user_model(player, model[], len)
{
	get_user_info(player, "model", model, len)
}

// Update Player's Model on all clients (adding needed delays)
public fm_user_model_update(taskid)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		fm_cs_set_user_model(taskid)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "fm_cs_set_user_model", taskid)
		g_models_targettime = g_models_targettime + g_modelchange_delay
	}
}

public go_buy(id)
{
	if (!g_isalive[id]) return PLUGIN_HANDLED
		
	message_begin(MSG_ONE, get_user_msgid("BuyClose"), _, id)
	message_end()
	
	if(g_survivor[id] || g_nemesis[id]) return PLUGIN_HANDLED
	
	if(g_zombie[id]) menu_buy3(id, 5)
	else clcmd_buy(id)
	
	return PLUGIN_HANDLED
}

public clcmd_buy(id)
{	
	static menu[512], len
	len = 0
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wМагазин \d| \wLVL: \r[%d]^n^n", g_lvl[id])
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1]\w Пистолеты^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[2]\w Дробовики^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[3]\w Автоматы^n")
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[4]\w Снайперки^n")
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[5]\w Пулеметы^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[6]\y Снаряжение^n")
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[7]\w Спец-оружия^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len,  "\r[8]\w Ножи^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len,  "\r[0]\w Выход")

	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu 3")
}

public menu_buy3(id, key)
{
	if (!g_isalive[id]||g_survivor[id]||g_nemesis[id]) return
	
	if (key == 7)
	{
		show_menu_knifes(id)
		return
	}	
	
	if(key>6) return
		
	static menuid, menu[1024], item, team, buffer[1024]
	
	switch (key)
	{
		case 0: formatex(menu, charsmax(menu), "\r[ZP] \wМагазин \d| \wПистолеты \r[BZ]")
		case 1: formatex(menu, charsmax(menu), "\r[ZP] \wМагазин \d| \wДробовики \r[BZ]")
		case 2: formatex(menu, charsmax(menu), "\r[ZP] \wМагазин \d| \wАвтоматы \r[BZ]")
		case 3: formatex(menu, charsmax(menu), "\r[ZP] \wМагазин \d| \wВинтовки \r[BZ]")
		case 4: formatex(menu, charsmax(menu), "\r[ZP] \wМагазин \d| \wПулеметы \r[BZ]")
		case 5: formatex(menu, charsmax(menu), "\r[ZP] \wСнаряжение \r[BZ]")
		case 6: formatex(menu, charsmax(menu), "\r[ZP] \wСпец-оружие \r[BZ]")
	}
	
	new lvl

	menuid = menu_create(menu, "menu_extras3")
	
	for (item = 0; item < g_extraitem_i; item++)
	{
		// Retrieve item's team
		team = ArrayGetCell(g_extraitem_team, item)
		lvl=ArrayGetCell(g_extraitem_lvl, item)

		if ((g_zombie[id] && !g_nemesis[id] && !(team & ZP_TEAM_ZOMBIE)) || !g_zombie[id] && !g_survivor[id] && !(team & ZP_TEAM_HUMAN))
			continue;
		
		if (ArrayGetCell(g_extraitem_slot, item) != key)
			continue;
		
		ArrayGetString(g_extraitem_name, item, buffer, charsmax(buffer))
	
		if(lvl){
			// Add Item Name and Cost
			if(item==EXTRA_ARMOR) {
				if(g_armor_limit[id]>=5) formatex(menu, charsmax(menu), "\r[С] \wБроня \r[+100] \r[%d|5]", g_armor_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[%d|5]", buffer, ArrayGetCell(g_extraitem_cost, item), g_armor_limit[id])
			}
			else if(item==EXTRA_CAKE) {
				if(g_cake_limit[id]>=1) formatex(menu, charsmax(menu), "\r[Гр] \wАнтидот \r[%d|1]", g_cake_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d] \r[%d|1]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item), g_cake_limit[id])
			}
			else if(item==EXTRA_MADNESS){ 
				if(g_madness_limit[id]>=3) formatex(menu, charsmax(menu), "\r[С] \wБешенство \r[%d|3]", g_madness_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[%d|3]", buffer, ArrayGetCell(g_extraitem_cost, item), g_madness_limit[id])
			}
			else if(item==EXTRA_UNLIMITED){ 
				if(g_unlimited[id]) formatex(menu, charsmax(menu), "\r[C] \wБеск. Патроны \r[Уже есть]")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
			}
			else if(item==EXTRA_NORECOIL){ 
				if(g_norecoil[id]) formatex(menu, charsmax(menu), "\r[C] \wБез отдачи \r[Уже есть]")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
			}
			else if(item==EXTRA_FLAMEGR){ 
				if(g_flamegr[id]) formatex(menu, charsmax(menu), "\r[Гр] \wОгн.")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			else if(item==EXTRA_ICEGR){ 
				if(g_flashgr[id]) formatex(menu, charsmax(menu), "\r[Гр] \wЛёд")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			else if(item==EXTRA_NOKNOCK){ 
				if(g_noknock[id]) formatex(menu, charsmax(menu), "\r[C] \wУбрать отброс \r[Уже есть]")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			else if(item==EXTRA_HEALTH){ 
				if(g_health_limit[id]>=5) formatex(menu, charsmax(menu), "\r[С] \wЗдоровье \r[%d|5]", g_health_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L :%d] \r[%d|5]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item), g_health_limit[id])
			}
			else if(item==EXTRA_PIPE){ 
				if(g_pipe_bomb[id]>=2) formatex(menu, charsmax(menu), "\r[Гр] \wМолния \r[%d|2]", g_pipe_bomb[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d] \r[%d|2]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item), g_pipe_bomb[id])
			}
			else if(item==EXTRA_HEALTH2){ 
				if(g_health_limit2[id]>=3) formatex(menu, charsmax(menu), "\r[С] \wЗдоровье \r[%d|3]", g_health_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[%d|3]", buffer, ArrayGetCell(g_extraitem_cost, item), g_health_limit2[id])
			}
			else if(0 < ArrayGetCell(g_extraitem_bolt, item))
			{
				if(g_lvl[id]<ArrayGetCell(g_extraitem_lvl, item)) formatex(menu, charsmax(menu), "\d%s \y[Б: %d] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_bolt, item),ArrayGetCell(g_extraitem_lvl, item))
				else formatex(menu, charsmax(menu), "\d%s \y[Б: %d]", buffer, ArrayGetCell(g_extraitem_bolt, item))
			}
			else {
				if(g_lvl[id]<ArrayGetCell(g_extraitem_lvl, item)) formatex(menu, charsmax(menu), "\d%s \y[%d Аммо] \r[L :%d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
				else if(g_lvl[id]>=ArrayGetCell(g_extraitem_lvl, item)) formatex(menu, charsmax(menu), "\d%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
			}
		}
		else{
			// Add Item Name and Cost
			if(item==EXTRA_ARMOR) {
				if(g_armor_limit[id]>=5) formatex(menu, charsmax(menu), "\r[С] \wБроня \r[+100] \r[%d|5\r]", g_armor_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[%d|5]", buffer, ArrayGetCell(g_extraitem_cost, item), g_armor_limit[id])
			}
			else if(item==EXTRA_CAKE) {
				if(g_cake_limit[id]>=1) formatex(menu, charsmax(menu), "\r[Гр] \wАнтидот \r[%d|1]", g_cake_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d] \r[%d|1]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item), g_cake_limit[id])
			}
			else if(item==EXTRA_MADNESS){ 
				if(g_madness_limit[id]>=2) formatex(menu, charsmax(menu), "\r[С] \wБешенство \r[%d|3]", g_madness_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[%d|3]", buffer, ArrayGetCell(g_extraitem_cost, item), g_madness_limit[id])
			}
			else if(item==EXTRA_UNLIMITED){ 
				if(g_unlimited[id]) formatex(menu, charsmax(menu), "\r[C] \wБеск. Патроны \r[Уже есть]")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[LVL:%d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
			}
			else if(item==EXTRA_NORECOIL){ 
				if(g_norecoil[id]) formatex(menu, charsmax(menu), "\r[C] \wБез отдачи \r[Уже есть]")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
			}
			else if(item==EXTRA_FLAMEGR){ 
				if(g_flamegr[id]) formatex(menu, charsmax(menu), "\r[Гр] \wОгн.")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			else if(item==EXTRA_ICEGR){ 
				if(g_flashgr[id]) formatex(menu, charsmax(menu), "\r[Гр] \wЛёд")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			else if(item==EXTRA_NOKNOCK){ 
				if(g_noknock[id]) formatex(menu, charsmax(menu), "\r[C] \wУбрать отброс \r[Уже есть]")
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
			}
			else if(item==EXTRA_HEALTH){ 
				if(g_health_limit[id]>=5) formatex(menu, charsmax(menu), "\r[С] \wЗдоровье \r[%d|5]", g_health_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d] \r[%d|5]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item), g_health_limit[id])
			}
			else if(item==EXTRA_PIPE){ 
				if(g_pipe_bomb[id]>=2) formatex(menu, charsmax(menu), "\r[Гр] \wМолния \r[%d|2]", g_pipe_bomb[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d] \r[%d|2]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item), g_pipe_bomb[id])
			}
			else if(item==EXTRA_HEALTH2){ 
				if(g_health_limit2[id]>=3) formatex(menu, charsmax(menu), "\r[С] \wЗдоровье \r[%d|3]", g_health_limit[id])
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[%d|3]", buffer, ArrayGetCell(g_extraitem_cost, item), g_health_limit2[id])
			}
			else if(0 < ArrayGetCell(g_extraitem_bolt, item))
			{
				if(g_lvl[id]<ArrayGetCell(g_extraitem_lvl, item)) formatex(menu, charsmax(menu), "\d%s \y[Б: %d] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_bolt, item),ArrayGetCell(g_extraitem_lvl, item))
				else formatex(menu, charsmax(menu), "\d%s \y[Б: %d]", buffer, ArrayGetCell(g_extraitem_bolt, item))
			}
			else {
				if(g_lvl[id]<ArrayGetCell(g_extraitem_lvl, item)) formatex(menu, charsmax(menu), "\d%s \y[%d Аммо] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
				else if(g_lvl[id]>=ArrayGetCell(g_extraitem_lvl, item)) formatex(menu, charsmax(menu), "\d%s \y[%d Аммо]", buffer, ArrayGetCell(g_extraitem_cost, item))
				else formatex(menu, charsmax(menu), "%s \y[%d Аммо] \r[L: %d]", buffer, ArrayGetCell(g_extraitem_cost, item),ArrayGetCell(g_extraitem_lvl, item))
			}
		}
		
		buffer[0] = item
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}	
	
	if (menu_items(menuid) <= 0)
	{
		zp_colored_print(id, "^x04[ZP]^x01 Магазин пуст")
		menu_destroy(menuid)
		return
	}
	
	formatex(menu, charsmax(menu), "Назад")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	
	formatex(menu, charsmax(menu), "Далее")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	
	formatex(menu, charsmax(menu), "Выход")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menuid)
}

public menu_extras3(id, menuid, item)
{
	// Player disconnected?
	if (!is_user_connected(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Dead players are not allowed to buy items
	if (!g_isalive[id] || g_survivor[id] || g_nemesis[id])
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve extra item id
	static buffer[2], dummy, itemid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	itemid = buffer[0]
		
	// Attempt to buy the item
	buy_extra_item(id, itemid)
	menu_destroy(menuid)
	
	return PLUGIN_HANDLED
}

show_menu_knifes(id)
{	
	if (!g_isalive[id]||g_survivor[id]||g_nemesis[id]) return
	
	static menu[512], len
	len = 0

	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wПривилегия:\r [%s]^n\r[ZP] \wВыбери холодное оружие \r[BZ]^n^n", g_szPrivilege[id])
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wHammer \r[Урон]^n")
	if(g_lvl[id]>=15)
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wSnap Blade \r[Прыжок]^n")
	  else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dSnap Blade \r[Прыжок] \d- \r[L: 15]^n")
	if(g_lvl[id]>=25)
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wSheep Sword \r[Скорость]^n^n")
	  else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dSheep Sword \r[Скорость] \d- \r[L: 25]^n^n")
	
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wKatana \r(У+С)^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dKatana \r(У+С) \r(VIP)^n")	
	
	if(get_user_flags(id) & ADMIN_LEVEL_E)
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wFire Snake \r(У+П+С)^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dFire Snake \r(У+П+С) \d- \r(PREMIUM)^n")
	  
	if(get_user_flags(id) & ADMIN_LEVEL_B)
	len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wLaser Sword \r(Огонь)^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dLaser Sword \r(Огонь) \d- \r(ADMIN)^n")
	  
	if(get_user_flags(id) & ADMIN_LEVEL_D)
	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \wIce Thanatos \r(Лёд)^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[7] \dIce Thanatos \r(Лёд) \d- \r(BOSS)^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0] \wВыход")

	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Knife Menu")
}

public menu_knife(id, key, itemid)
{
	if (!g_isalive[id] || g_survivor[id] || g_nemesis[id]) return
	
	if(key>6) return
	
	// Player disconnected?
	if (!g_isconnected[id])
		return
		
	switch(key)
	{
	    case 0: g_knife[id]=0
		case 1:
		{
			if(g_lvl[id]<15)
			{
				zp_colored_print(id, "^x04[ZP]^x01 Для взятия ^x04 Snap Blade ^x01нужно иметь ^x04(15 LVL)")
				show_menu_knifes(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_knife[id]=1
		}
		case 2:
		{
			if(g_lvl[id]<25)
			{
				zp_colored_print(id, "^x04[ZP]^x01 Для взятия ^x04 Sheep Sword ^x01нужно иметь ^x04(25 LVL)")
				show_menu_knifes(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_knife[id]=2
		}
	case 3:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_H))
			{
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 VIP^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				show_menu_knifes(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_knife[id]=3
		}
	case 4:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_E))
			{
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 PREMIUM^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm ")
				show_menu_knifes(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_knife[id]=4
		}
		case 5:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_B))
			{
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 ADMIN^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				show_menu_knifes(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_knife[id]=5
		}
		case 6:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_D))
			{
				zp_colored_print(id, "^x04[ZP]^x01 У вас нету ^x04 BOSS^x01 прав, напишите в VK: ^x04 vk.com/dikiyzm")
				show_menu_knifes(id)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
				return
			}
			g_knife[id]=6
		}
	}
	
	static weapon_ent;weapon_ent=get_pdata_cbase(id,373,5)
	if(pev_valid(weapon_ent)) ExecuteHamB(Ham_Item_Deploy,weapon_ent)
}

public cont_menu(id) 
{
    new menu[512], len, keys = MENU_KEY_0
    len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wЗаконное Мясо^n\r[ZP] \wИнформация^n^n\yСтоимость привилегий:^n")
    
    len += formatex(menu[len], charsmax(menu) - len, "\r[#] \wVIP - \r100rub.^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[#] \wPREMIUM - \r150rub.^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[#] \wАдмин - \r190rub.^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[#] \wБосс - \r270rub.^n^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[#] \wПодробное описание в \rVK:^n\dvk.com/goodgame16^n^n\yПокупка привилегий:^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[#] \wПокупка привилегий в Discord: \rC.S.1.6#5442^n")
    len += formatex(menu[len], charsmax(menu) - len, "\r[#] \wПокупка привилегий в VK: \rvk.com/dikiyzm^n^n")
    
    len += formatex(menu[len], charsmax(menu) - len, "\r[0] \wВыход")
    
    if (pev_valid(id) == 2) set_pdata_int(id, 205, 0, 5)
    show_menu(id, keys, menu, -1, "Cont Menu")
    return PLUGIN_HANDLED
}

public Ham_Timer(Ent) {
	if (!pev_valid(Ent))
		return HAM_IGNORED
	
	static ClassName[32]
	pev(Ent, pev_classname, ClassName, charsmax(ClassName))
	
	if (!equal(ClassName, "Timer"))
		return HAM_IGNORED

	static team
	for(new id = 1; id <= get_maxplayers(); id++) {
		if (!is_user_connected(id) || g_isalive[id] || !g_Timer[id] || g_endround)
			continue
			
		team = fm_cs_get_user_team(id)
		if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
			continue
			
		g_Timer[id]--
		if(g_Timer[id]==3){
			message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id)
			write_short(3)
			message_end()
		}
		if(!g_Timer[id]) {
			if(g_nemround){
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				g_respawn_as_zombie[id]=0
			}
			else {
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				g_respawn_as_zombie[id]=1
			}
			
			
			ExecuteHamB(Ham_CS_RoundRespawn, id)
		}
		else if(g_Timer[id]<4) client_print(id, print_center, "Возрождение через %d сек", g_Timer[id])
		
	}

	set_pev(Ent, pev_nextthink, get_gametime() + 1.0)
	return HAM_HANDLED
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
       
	return 1;
}

public set_fire(victim)
{
		if (get_pcvar_num(cvar_hudicons))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_BURN) // damage type
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		if (g_nemesis[victim]) // fire duration (nemesis is fire resistant)
			g_burning_duration[victim] += 5
		else
			g_burning_duration[victim] += 20
		
		// Set burning task on victim if not present
		if (!task_exists(victim+TASK_BURN))
			set_task(0.2, "burning_flame", victim+TASK_BURN, _, _, "b")
}

public set_freeze(victim)
{		
		new sound[64]
		if (g_nemesis[victim])
		{
			// Get player's origin
			static origin2[3]
			get_user_origin(victim, origin2)
			
			// Broken glass sound
			ArrayGetString(grenade_frost_break, random_num(0, ArraySize(grenade_frost_break) - 1), sound, charsmax(sound))
			emit_sound(victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			// Glass shatter
			message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
			write_byte(TE_BREAKMODEL) // TE id
			write_coord(origin2[0]) // x
			write_coord(origin2[1]) // y
			write_coord(origin2[2]+24) // z
			write_coord(16) // size x
			write_coord(16) // size y
			write_coord(16) // size z
			write_coord(random_num(-50, 50)) // velocity x
			write_coord(random_num(-50, 50)) // velocity y
			write_coord(25) // velocity z
			write_byte(10) // random velocity
			write_short(g_glassSpr) // model
			write_byte(10) // count
			write_byte(25) // life
			write_byte(BREAK_GLASS) // flags
			message_end()
			
			return;
		}
		
		// Freeze icon?
		if (get_pcvar_num(cvar_hudicons))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
			write_byte(0) // damage save
			write_byte(0) // damage take
			write_long(DMG_DROWN) // damage type - DMG_FREEZE
			write_coord(0) // x
			write_coord(0) // y
			write_coord(0) // z
			message_end()
		}
		
		// Light blue glow while frozen
		if (g_handle_models_on_separate_ent)
			fm_set_rendering(g_ent_playermodel[victim], kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
		else
			fm_set_rendering(victim, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25)
		
		// Freeze sound
		ArrayGetString(grenade_frost_player, random_num(0, ArraySize(grenade_frost_player) - 1), sound, charsmax(sound))
		emit_sound(victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Add a blue tint to their screen
		message_begin(MSG_ONE, g_msgScreenFade, _, victim)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(FFADE_STAYOUT) // fade type
		write_byte(0) // red
		write_byte(50) // green
		write_byte(200) // blue
		write_byte(100) // alpha
		message_end()
		
		// Set the frozen flag
		g_frozen[victim] = true
		
		// Save player's old gravity (bugfix)
		pev(victim, pev_gravity, g_frozen_gravity[victim])
		
		// Prevent from jumping
		if (pev(victim, pev_flags) & FL_ONGROUND)
			set_pev(victim, pev_gravity, 999999.9) // set really high
		else
			set_pev(victim, pev_gravity, 0.000001) // no gravity
		
		// Prevent from moving
		ExecuteHamB(Ham_Player_ResetMaxSpeed, victim)
		
		// Set a task to remove the freeze
		set_task(random_float(1.0, 2.0), "remove_freeze", victim)
}

public BlockAutobuy(id)
	return PLUGIN_HANDLED

public show_points_menu(id)
{
    if(!is_user_connected(id)) return
	
    static menu[512], len
    len = 0
            
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПрокачка \d| \wБолты:\r [%i]^n^n", g_iToken[id])
    
    if(g_iToken[id] >= 15 && !(g_pts[id][0] >= 30))
        len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wЗдоровье \r[%i/30]^n", g_pts[id][0])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dЗдоровье \r[%i/30] \r[15 Б]^n", g_pts[id][0])
            
    if(g_pts[id][1] >= g_lvl[id]/5)
        len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dБроня \r[%i/20] \y[L: %i]^n", g_pts[id][1], g_pts[id][1]*5+5)
    else if(g_iToken[id] < 20 || g_pts[id][1] >= 20)
        len += formatex(menu[len], charsmax(menu) - len, "\r[2]\d Броня \r[%i/20] \r[20 Б]^n", g_pts[id][1])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[2]\w Броня \r[%i/20]^n", g_pts[id][1])
        
    if(g_pts[id][2] >= g_lvl[id]/10)
        len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dСкорость \r[%i/10] \y[L: %i]^n", g_pts[id][2], g_pts[id][2]*10+10)
    else if(g_iToken[id] < 15 || g_pts[id][2] >= 10)
        len += formatex(menu[len], charsmax(menu) - len, "\r[3]\d Скорость \r[%i/10] \r[15 Б]^n", g_pts[id][2])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[3]\w Скорость \r[%i/10]^n", g_pts[id][2])
            
    if(g_pts[id][3] >= g_lvl[id]/10)
        len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dУрон \r[%i/10] \y[L: %i]^n", g_pts[id][3], g_pts[id][3]*10+10)
    else if(g_iToken[id] < 20 || g_pts[id][3] >= 10)
        len += formatex(menu[len], charsmax(menu) - len, "\r[4]\d Урон \r[%i/10] \r[20 Б]^n", g_pts[id][3])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[4]\w Урон \r[%i/10]^n", g_pts[id][3])
        
    if(g_pts[id][4] >= g_lvl[id]/15)
        len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dГравитация \r[%i/10] \y[L: %i]^n^n", g_pts[id][4], g_pts[id][4]*15+15)
    else if(g_iToken[id] < 15 || g_pts[id][4] >= 10)
        len += formatex(menu[len], charsmax(menu) - len, "\r[5]\d Гравитация \r[%i/10] \r[15 Б]^n^n", g_pts[id][4])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[5]\w Гравитация \r[%i/10]^n^n", g_pts[id][4])	
		
	if(!(get_user_flags(id) & ADMIN_LEVEL_E))	
		len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dZombieStun \r[PREMIUM]^n")
    else if(g_pts[id][5] >= g_lvl[id]/15)
        len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dZombieStun \r[%i/5] \y[L: %i]^n", g_pts[id][5], g_pts[id][5]*15+15)
    else if(g_iToken[id] < 15 || g_pts[id][5] >= 5)
        len += formatex(menu[len], charsmax(menu) - len, "\r[6]\d ZombieStun \r[%i/5] \r[15 Б]^n", g_pts[id][5])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[6]\w ZombieStun \r[%i/5]^n", g_pts[id][5])	
		
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))	
		len += formatex(menu[len], charsmax(menu) - len, "\r[7] \dFatal. Hit Knife \r[ADMIN]^n")
    else if(g_pts[id][6] >= g_lvl[id]/15)
        len += formatex(menu[len], charsmax(menu) - len, "\r[7] \dFatal. Hit Knife \r[%i/5] \y[L: %i]^n", g_pts[id][6], g_pts[id][6]*15+15)
    else if(g_iToken[id] < 15 || g_pts[id][6] >= 5)
        len += formatex(menu[len], charsmax(menu) - len, "\r[7]\d Fatal. Hit Knife \r[%i/5] \r[15 Б]^n", g_pts[id][6])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[7]\w Fatal. Hit Knife \r[%i/5]^n", g_pts[id][6])	
		
	if(!(get_user_flags(id) & ADMIN_LEVEL_D))	
		len += formatex(menu[len], charsmax(menu) - len, "\r[8] \dFatal. Hit \r[BOSS]^n")
    else if(g_pts[id][7] >= g_lvl[id]/15)
        len += formatex(menu[len], charsmax(menu) - len, "\r[8] \dFatal. Hit \r[%i/5] \y[L: %i]^n", g_pts[id][7], g_pts[id][7]*15+15)
    else if(g_iToken[id] < 15 || g_pts[id][7] >= 5)
        len += formatex(menu[len], charsmax(menu) - len, "\r[8]\d Fatal. Hit \r[%i/5] \r[15 Б]^n", g_pts[id][7])
    else
        len += formatex(menu[len], charsmax(menu) - len, "\r[8]\w Fatal. Hit \r[%i/5]^n", g_pts[id][7])	
		
    len += formatex(menu[len], charsmax(menu) - len, "^n\r[9]\w Назад")		

    len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
    
    show_menu(id, KEYSMENU, menu, -1, "Points Menu")
}

public menu_points(id, key)
{
    switch (key)
    {
        case 0: // UP SKILL HP
        {
            if(g_iToken[id] < 15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 15 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][0] >= 30)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            g_iToken[id] -= 15
            set_pev(id, pev_health, pev(id, pev_health) + 15.0)
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04Жизней^x01 до ^x04%i уровня", g_pts[id][0])
            show_points_menu(id)
        }
        case 1: // UP SKILL AP
        {
            if(g_pts[id][1] >= g_lvl[id]/5)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Прокачайтесь до^x04 %i ^x01уровня^x01 , чтобы прокачать скилл ^x04Брони", g_pts[id][1]*5+5)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }		
		
            if(g_iToken[id] < 20)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 20 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][1] >= 20)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            set_pev(id, pev_armorvalue, pev(id, pev_armorvalue) + 5.0)
            g_iToken[id] -= 20
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04Брони^x01 до ^x04%i уровня", g_pts[id][1])
            show_points_menu(id)
        }
        case 2: // UP SKILL DMG
        {
            if(g_pts[id][2] >= g_lvl[id]/10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Прокачайтесь до^x04 %i ^x01уровня чтобы прокачать скилл ^x04Скорости", g_pts[id][2]*10+10)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }		
		
            if(g_iToken[id] < 15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 15 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][2] >= 10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            g_iToken[id] -= 15
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04Скорости^x01 до ^x04%i уровня", g_pts[id][2])
            show_points_menu(id)
        }
        case 3: // UP SKILL DMG
        {
            if(g_pts[id][3] >= g_lvl[id]/10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Прокачайтесь до^x04 %i ^x01уровня чтобы прокачать скилл ^x04Урона", g_pts[id][3]*10+10)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }		
		
            if(g_iToken[id] < 20)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 20 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][3] >= 10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            g_iToken[id] -= 20
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04Урона^x01 до ^x04%i уровня", g_pts[id][3])
            show_points_menu(id)
        }
        case 4: // UP SKILL DMG
        {
            if(g_pts[id][4] >= g_lvl[id]/15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Прокачайтесь до^x04 %i ^x01уровня чтобы прокачать скилл ^x04Гравитации", g_pts[id][4]*15+15)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }		
	
            if(g_iToken[id] < 15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 15 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][4] >= 10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            g_iToken[id] -= 15
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04Гравитации^x01 до ^x04%i уровня", g_pts[id][4])
            show_points_menu(id)
        }
        case 5: // UP SKILL DMG
        {
            if(!(get_user_flags(id) & ADMIN_LEVEL_E))
            {
                zp_colored_print(id, "^x04[ZP]^x01 Только для ^x04PREMIUM ^x01игроков!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
			
            if(g_pts[id][5] >= g_lvl[id]/15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Прокачайтесь до^x04 %i ^x01уровня чтобы прокачать скилл ^x04ZombieStun", g_pts[id][5]*15+15)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
		
            if(g_iToken[id] < 15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 15 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][5] >= 10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            g_iToken[id] -= 15
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04ZombieStun^x01 до ^x04%i уровня", g_pts[id][5])
            show_points_menu(id)
        }
        case 6: // UP SKILL DMG
        {
            if(!(get_user_flags(id) & ADMIN_LEVEL_B))
            {
                zp_colored_print(id, "^x04[ZP]^x01 Только для ^x04 ADMIN ^x01игроков!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
			
            if(g_pts[id][6] >= g_lvl[id]/15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Прокачайтесь до^x04 %i ^x01уровня чтобы прокачать скилл ^x04 Fatal. Hit Knife", g_pts[id][6]*15+15)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
		
            if(g_iToken[id] < 15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 15 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][6] >= 10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            g_iToken[id] -= 15
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04 Fatal. Hit Knife^x01 до ^x04%i уровня", g_pts[id][6])
            show_points_menu(id)
        }
        case 7: // UP SKILL DMG
        {
            if(!(get_user_flags(id) & ADMIN_LEVEL_D))
            {
                zp_colored_print(id, "^x04[ZP]^x01 Только для ^x04 BOSS ^x01игроков!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
			
            if(g_pts[id][7] >= g_lvl[id]/15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Прокачайтесь до^x04 %i ^x01уровня чтобы прокачать скилл ^x04 Fatal. Hit", g_pts[id][7]*15+15)
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
		
            if(g_iToken[id] < 15)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Чтобы прокачать данный скилл, нужно иметь ^x04 15 ^x04болтов!")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            if(g_pts[id][7] >= 10)
            {
                zp_colored_print(id, "^x04[ZP]^x01 Этот скилл прокачан на масимум")
				client_cmd(id, "spk ^"%s^"", SND_MENU_OFF)
                show_points_menu(id)
                return
            }
            
            g_iToken[id] -= 15
            zp_colored_print(id, "^x04[ZP]^x01 Вы подняли скилл ^x04 Fatal. Hit^x01 до ^x04%i уровня", g_pts[id][7])
            show_points_menu(id)
        }
        case 8: show_menu_cabinet(id)
    }    
       g_pts[id][key]++
}

public zp_color_menu(id)
{
	show_colors_menu(id)
}

show_colors_menu(id)
{
	// Player disconnected?
	if (!g_isconnected[id]) return
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wВыбери цвет граба \r[BZ]^n^n")
	
	if(g_adm_Color[id]==0)
		len += formatex(menu[len], charsmax(menu) - len, "\r[1]\y Белый^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[1]\w Белый^n")
	if(g_adm_Color[id]==1)
		len += formatex(menu[len], charsmax(menu) - len, "\r[2]\y Красный^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[2]\w Красный^n")
	if(g_adm_Color[id]==2)
		len += formatex(menu[len], charsmax(menu) - len, "\r[3]\y Зеленый^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[3]\w Зеленый^n")
	if(g_adm_Color[id]==3)
		len += formatex(menu[len], charsmax(menu) - len, "\r[4]\y Синий^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[4]\w Синий^n")
	if(g_adm_Color[id]==4)
		len += formatex(menu[len], charsmax(menu) - len, "\r[5]\y Желтый^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[5]\w Желтый^n")
	if(g_adm_Color[id]==5)
		len += formatex(menu[len], charsmax(menu) - len, "\r[6]\y Сиреневый^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[6]\w Сиреневый^n")
	if(g_adm_Color[id]==6)
		len += formatex(menu[len], charsmax(menu) - len, "\r[7]\y Морской^n")
	else	len += formatex(menu[len], charsmax(menu) - len, "\r[7]\w Морской^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Colors Menu")
}

public menu_colors(id, key)
{
	if (!g_isconnected[id]) return PLUGIN_HANDLED;
	
	if(key==9) return PLUGIN_HANDLED
	
	if(key>6){
		show_colors_menu(id)
		return PLUGIN_HANDLED;
	}
	
	g_adm_Color[id]=key
	grab_set_color(id, g_adm_Color[id])
	show_colors_menu(id)

	return PLUGIN_HANDLED;
}

votes_result(){
	new b = 0, a;
	for (a = 0; a < 2; ++a) {
		if (Votes_mode_CUR[b] < Votes_mode_CUR[a]) {
			b = a;
		}
	}

	switch(b){
		case 0:
		{
			remove_task(TASK_MAKEZOMBIE)
			set_task(2.0 + get_pcvar_float(cvar_warmup), "make_zombie_task", TASK_MAKEZOMBIE)
			
			g_nemesis_mod = 10 
			remove_task(TASK_WARMUP)
			g_warmup=get_pcvar_num(cvar_warmup)+1
			set_task(1.0, "Task_Warmup", TASK_WARMUP)
			
		    for (new id = 1; id <= g_maxplayers; id++)
	        {
		       if (g_isalive[id]) 
		       {
				  set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
		       }
	        }
		}
		case 1:
		{
			remove_task(TASK_MAKEZOMBIE)
			set_task(2.0 + get_pcvar_float(cvar_warmup), "make_zombie_task", TASK_MAKEZOMBIE)
			
			g_survivor_mod = 10
			remove_task(TASK_WARMUP)
			g_warmup=get_pcvar_num(cvar_warmup)+1
			set_task(1.0, "Task_Warmup", TASK_WARMUP)
			
		    for (new id = 1; id <= g_maxplayers; id++)
	        {
		       if (g_isalive[id]) 
		       {
				  set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
		       }
	        }
		}
	}
}

public task_modes_voting(taskid)
{
	time_vote--
	if(!time_vote)
	{
		remove_task(taskid)
		votes_result()
		return
	}
	
	for (new id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id]) 
		{
			 show_menu_1(id)
		}
	}
}

show_menu_1(id)
{	
	static menu[999], len
	len = 0


	if(!Voted_Already[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[ZP]^n\r[ZP] \wВыбор режима \r[ZP]^n\r[ZP] \wОсталось: \r(%d) \wсек. \r[ZP]^n\r[ZP] \wПроголосовало: \y%d/%d \r[ZP]^n^n", time_vote, Votes_mode_ALL, fnGetAlive())
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[ZP]^n\r[ZP] \wВыбор режима \r[ZP]^n\r[ZP] \wОсталось: \r(%d) \wсек. \r[ZP]^n\r[ZP] \wПроголосовало: \y%d/%d \d(Вы в том числе) \r[ZP]^n^n", time_vote, Votes_mode_ALL, fnGetAlive())
	
	if(!Voted_Already[id])
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wДьявол \r(%d%%)^n", Stock_Value(Votes_mode_CUR[0],Votes_mode_ALL))
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wГерой \r(%d%%)^n^n\r!\dПОСЛЕ ГОЛОСОВАНИЯ, ПОЯВИТСЯ МЕНЮ С ОРУЖИЕМ!", Stock_Value(Votes_mode_CUR[1],Votes_mode_ALL))
	}
	else
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dДьявол \r(%d%%)^n", Stock_Value(Votes_mode_CUR[0],Votes_mode_ALL))
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dГерой \r(%d%%)^n^n\r!\dПОСЛЕ ГОЛОСОВАНИЯ, ПОЯВИТСЯ МЕНЮ С ОРУЖИЕМ!", Stock_Value(Votes_mode_CUR[1],Votes_mode_ALL))
	}

	if (pev_valid(id) == PDATA_SAFE) set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Modes Vote Menu")
}

public menu_modes(id, key)
{
	if(time_vote<1) return
	if(key>=2) return;
	if(Voted_Already[id]||key>2){
		show_menu_1(id)
		return
	}
	
	Voted_Already[id]=1
	Votes_mode_CUR[key]++
	new name[32]
	get_user_name(id, name, 31)
	zp_colored_print(0, "^4[ZP] ^3%s ^1проголосовал за %s.", name, Votes_mode_CUR[1] ? "героя" : "дьявола")	
	Votes_mode_ALL++
	show_menu_1(id)
}

stock Stock_Value(iIs, iOf) 
{
	return (iOf != 0) ? floatround(floatmul(float(iIs) / float(iOf), 100.0)) : 0
}

public zp_set_user_admgrab(id, key)
{
	g_adm_Color[id]=key
	grab_set_color(id, g_adm_Color[id])
}

public zp_get_user_admgrab(id)
{
	return g_adm_Color[id]
}