// Copyright © 2015 Vaqtincha

/*********************** V.I.P Custom Weapons **********************
*
*	Credits:
*	ConnorMcLeod for cstrike_pdatas
*	Numb for plugin "Fast Sniper Switch"
*	SISA for help
*	AlejandroSk for plugin "Golden Ak-47"
*********************************************************************/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME 	"V.I.P Custom AWP"		// don't change this!
#define PLUGIN_VERSION 	"1.0.0"					// version for "V.I.P Custom Weapons" 
#define PLUGIN_AUTHOR 	"Vaqtincha" 			

#define get_weapon_owner(%1)	get_pdata_cbase(%1, m_pPlayer, XO_WEAPON)
#define fm_get_user_money(%1)	get_pdata_int(%1, m_iAccount, XO_PLAYER)

#if AMXX_VERSION_NUM < 183
	#define HasShield(%1)	(get_pdata_int(%1, m_iUserPrefs, XO_PLAYER) & m_bHasShield)
#else
	#define HasShield(%1)	get_pdata_bool(%1, m_bHasShield)
#endif

#define IsPlayer(%1)	( 1 <= (%1) <= giMaxPlayers )
#define MAX_PLAYERS 32

/*-----------------------------------------------------------------*/
#define WP 6597
// Sprite
new m_spriteTexture

new const weapon_name[] = "weapon_awp"
new const ammo_type[] = "338magnum"
new const max_bpammo[] = 30
new const buy_cmd[] = "buy_awp"
new const weapon_id = CSW_AWP

new const V_MODEL[] = "models/v_awp.mdl"	// view weapon model
new const P_MODEL[] = "models/p_awp.mdl"	// player weapon model
new const W_MODEL[] = "models/w_awp.mdl"	// world weapon model
new const W_DEF_MODEL[] = "models/w_awp.mdl"		// default world model

/*-----------------------------------------------------------------*/

new bullets[ 33 ]

static buyaccess
new weapcost, droptype, alw_round_buy, Float:delay
new Float:damage, inbuyzone, buytime, crosshair

new Float:g_GameTime
new bool:g_HasWeap[MAX_PLAYERS + 1] = false
new bool:g_buyzone[MAX_PLAYERS + 1]
new g_bInZoom[MAX_PLAYERS+1]

new giCounter, giMaxPlayers, cvar_goldbullets2

const PRIMARY_WEAPONS_BIT_SUM = 1<<CSW_SCOUT|1<<CSW_XM1014|1<<CSW_MAC10|1<<CSW_AUG|1<<CSW_UMP45
	|1<<CSW_SG550|1<<CSW_GALIL|1<<CSW_FAMAS|1<<CSW_AWP|1<<CSW_MP5NAVY|1<<CSW_M249|1<<CSW_M3
	|1<<CSW_M4A1|1<<CSW_TMP|1<<CSW_G3SG1|1<<CSW_SG552|1<<CSW_AK47|1<<CSW_P90

const SECONDARY_WEAPONS_BIT_SUM = 1<<CSW_P228|1<<CSW_ELITE|1<<CSW_FIVESEVEN|1<<CSW_USP|1<<CSW_GLOCK18|1<<CSW_DEAGLE

	// Offsets
#if AMXX_VERSION_NUM < 183
	const m_bHasShield = 1<<24
	const m_iUserPrefs = 510
#else
	const m_bHasShield = 2043
#endif
const m_pPlayer = 41
const XO_PLAYER = 5
const XO_WEAPON = 4
const m_iId = 43
const m_flDecreaseShotsFired = 76
const m_flNextPrimaryAttack = 46
const m_flNextSecondaryAttack = 47
const m_flNextAttack = 83
const m_pActiveItem = 373
// const m_rgpPlayerItems_wpnbx_slot2 = 36 	// secondary weapon slot
const m_rgpPlayerItems_wpnbx_slot1 = 35 	// primary weapon slot
#if cellbits == 32
	const m_iAccount = 115
#else
	const m_iAccount = 140
#endif

public plugin_init()
{
	new mapname[4]
	get_mapname(mapname, charsmax(mapname))
	if(equali(mapname, "de_") || equali(mapname, "cs_"))
	{
		register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
		loadconfig()
		giMaxPlayers = get_maxplayers()
		
		cvar_goldbullets2 = register_cvar("golden_awp_gold_bullets", "1")
		register_event("CurWeapon", "make_tracer", "be", "1=1", "3>0")
		
		register_clcmd( buy_cmd, "GiveWeapon") // don't change this!
		if(inbuyzone) register_event("StatusIcon", "event_buyzone_icon", "b", "2=buyzone")
		// Events
		register_event( "TextMsg", "Event_NewGame", "a", "2=#Game_will_restart_in", "2=#Game_Commencing" )
		register_event ( "HLTV", "Event_NewRound", "a", "1=0", "2=0" )
		register_event("DeathMsg", "Death", "a")
		if(crosshair)
		{
			register_event("SetFOV", "Event_SetFOV", "be")
			register_event("CurWeapon", "Event_CurWeapon", "be", "1=1","2=18")
		}
		register_forward(FM_SetModel, "fw_SetModel")

		RegisterHam(Ham_Item_Deploy, weapon_name, "fw_ItemDeploy_Weap_Post", 1)
		RegisterHam(Ham_Item_AttachToPlayer, weapon_name, "fw_Item_AttachToPlayer_Pre", 0)
		RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Pre", 0)
	}
	else
		pause("a")
}

public loadconfig()
{
	new ConfigFile[64], szMsg[128] 	// "addons/amxmodx/configs/vip_custom.ini" 37
	get_localinfo("amxx_configsdir", ConfigFile, charsmax(ConfigFile))
	add(ConfigFile, charsmax(ConfigFile), "/vip_custom.ini")
	if( !file_exists(ConfigFile) )
	{
		formatex( szMsg, charsmax(szMsg), "%s Config File Not Found!", PLUGIN_NAME )
		set_fail_state(szMsg)
		return
	}
	
	new fp = fopen(ConfigFile, "rt")
	if( fp )
	{
		new Datas[86], Setting[24], Value[15]
		while( !feof(fp) )
		{
			fgets(fp, Datas, charsmax(Datas))
			trim(Datas)
			if(!Datas[0] || Datas[0] == ';' || Datas[0] == '#' || Datas[0] == '/'|| Datas[0] == '[')
			{
				continue
			}
			new Sign[3]
			parse(Datas, Setting, charsmax(Setting), Sign, charsmax(Sign), Value, charsmax(Value))
			if( equali(Setting, "drop_type")){
				droptype = str_to_num(Value)
			}else if( equali(Setting, "awp_damage")){
				damage = str_to_float(Value)
			}else if( equali(Setting, "awp_switch_delay")){
				delay = str_to_float(Value)
			}
		}
		formatex( szMsg, charsmax(szMsg), "%s Config Successfully Loaded!", PLUGIN_NAME )
		server_print(szMsg)
	}
}

public make_tracer(id)
{
	if (get_pcvar_num(cvar_goldbullets2))
	{
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
		new pteam[16]
		
		get_user_team(id, pteam, 15)
		
		if ((bullets[id] > clip) && (wpnid == CSW_AWP) && g_HasWeap[id]) 
		{
			new vec1[3], vec2[3]
			get_user_origin(id, vec1, 1) // origin; your camera point.
			get_user_origin(id, vec2, 4) // termina; where your bullet goes (4 is cs-only)
			
			
			//BEAMENTPOINTS
			message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte (0)     //TE_BEAMENTPOINTS 0
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2])
			write_coord(vec2[0])
			write_coord(vec2[1])
			write_coord(vec2[2])
			write_short( m_spriteTexture )
			write_byte(1) // framestart
			write_byte(5) // framerate
			write_byte(2) // life
			write_byte(10) // width
			write_byte(0) // noise
			write_byte( 255 )     // r, g, b
			write_byte( 215 )       // r, g, b
			write_byte( 0 )       // r, g, b
			write_byte(200) // brightness
			write_byte(150) // speed
			message_end()
		}
	
		bullets[id] = clip
	}
	
}

public plugin_precache()
{
	precache_model(V_MODEL)
	precache_model(P_MODEL)
	precache_model(W_MODEL)
	m_spriteTexture = precache_model("sprites/dot.spr")
}

public event_buyzone_icon(id)
{
	g_buyzone[id] = bool:read_data(1)
}

public client_putinserver(id)
{
	g_HasWeap[id] = false
}

public client_disconnect(id)
{
	g_HasWeap[id] = false
	if(inbuyzone)
	{
		g_buyzone[id] = false
	}
}

public Event_NewGame()
{
	giCounter = 0
	new iPlayers[32], iNum
	get_players(iPlayers, iNum )
	for ( --iNum; iNum >= 0; --iNum )
	{
		g_HasWeap[iPlayers[iNum]] = false
	}
}

public Event_NewRound()
{
	giCounter++
	if(buytime)
	{
		g_GameTime = get_gametime()
	}
}

public Death()
{
	g_HasWeap[read_data(2)] = false
}

public Event_SetFOV( id )
{
	g_bInZoom[id] = ( 0 < read_data(1) < 55 )
}

public Event_CurWeapon(id)
{
	if(!g_bInZoom[id] && g_HasWeap[id])
	{
		message_begin(MSG_ONE, get_user_msgid("Crosshair"), _, id)
		write_byte(1)
		message_end()
	}
}

public buyCMD(id)
{
	if(!is_user_alive(id))
	{
		client_print(id, print_center, "%L", LANG_SERVER,"ONLY_ALIVE")
		return PLUGIN_HANDLED
	}
	// Check if the player is in the buyzone
	if(inbuyzone)
	{
		if(!g_buyzone[id])
		{
			client_print(id, print_center, "%L", LANG_SERVER,"OUTSIDE_BUYZONE")
			return PLUGIN_HANDLED
		}
	}
	// Check buying time
	if(buytime)
	{
		new Float:buytime = get_cvar_float("mp_buytime") * 60.0
		new Float:timepassed = get_gametime() - g_GameTime

		if(floatcmp(timepassed , buytime) == 1)
		{
			client_print(id, print_center, "%L", LANG_SERVER,"SECONDS_HAVE_PASSED",buytime)
			return PLUGIN_HANDLED
		}
	}
	if(giCounter < alw_round_buy)
	{
		client_print(id, print_center, "%L", LANG_SERVER,"NOT_AVAILABLE")
		return PLUGIN_HANDLED
	}
	if(!(get_user_flags(id) & buyaccess ))
	{
		client_print(id, print_center, "%L", LANG_SERVER,"NO_ACC_CMD")
		return PLUGIN_HANDLED
	}
	if(fm_get_user_money(id) < weapcost )
	{
		client_print(id, print_center, "%L", LANG_SERVER,"INSUFFICIENT_FUNDS")
		return PLUGIN_HANDLED
	}
	else{
		fm_set_user_money(id, fm_get_user_money(id) - weapcost , 1)
		GiveWeapon(id)
	}
	return PLUGIN_CONTINUE
}

public GiveWeapon(id)
{	
	drop_weapons(id, 1)
	g_HasWeap[id] = true
	fm_give_item(id, weapon_name)
	ExecuteHamB(Ham_GiveAmmo, id, max_bpammo, ammo_type, max_bpammo)
	engclient_cmd(id, weapon_name)
}

public fw_ItemDeploy_Weap_Post(ent)
{
	new iPlayer = get_weapon_owner(ent)
	if(iPlayer > 0 && g_HasWeap[iPlayer])
	{
		set_pev(iPlayer, pev_viewmodel2, V_MODEL)
		set_pev(iPlayer, pev_weaponmodel2, P_MODEL)
		
		// code "Fast Sniper Switch" by Numb
		if( ent!=get_pdata_cbase(iPlayer, m_pActiveItem, XO_PLAYER)
		|| get_pdata_float( ent, m_flDecreaseShotsFired, XO_WEAPON)!=get_gametime())
		return HAM_IGNORED
		
		get_pdata_int(ent, m_iId, XO_WEAPON) == weapon_id
		
		set_pdata_float(ent, m_flNextPrimaryAttack, delay, XO_WEAPON)
		set_pdata_float(ent, m_flNextSecondaryAttack, delay, XO_WEAPON)
		set_pdata_float(iPlayer, m_flNextAttack, delay, XO_PLAYER)
	}
	return HAM_IGNORED
}

public fw_Item_AttachToPlayer_Pre(ent, id)
{
	if ( pev (ent, pev_impulse)==WP)
		g_HasWeap[id] = true
	
	if(	get_pdata_cbase(id, m_pActiveItem) != ent)
	{
		return HAM_IGNORED
	}
	fw_ItemDeploy_Weap_Post(ent)
	return HAM_IGNORED
}

public fw_SetModel(ent, model[])
{
	new id = pev (ent, pev_owner)
	if( pev_valid(ent))
	{
		if( equal(model, W_DEF_MODEL))
		{
			new weapon = get_pdata_cbase(ent, m_rgpPlayerItems_wpnbx_slot1, XO_WEAPON)
			if(weapon > 0 && pev(weapon, pev_impulse)==WP)
			{
				g_HasWeap[id] = false
				engfunc(EngFunc_SetModel, ent, W_MODEL )
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}

public fw_TakeDamage_Pre(victim, inflictor, attacker, Float:fdamage, damage_bits)
{
	if(!(damage_bits & DMG_BULLET)||!IsPlayer(attacker)|| get_user_weapon(attacker) != weapon_id)
		return HAM_IGNORED

	if(g_HasWeap[attacker] && attacker == inflictor )
	{
		SetHamParamFloat(4, fdamage * damage)
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

//================================ STOCKS ==============================//

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)

	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		if((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM || HasShield(id)))
		|| (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			static wname[32]
			get_weaponname(weaponid, wname, charsmax(wname))
			switch(droptype)
			{
				case 0: ham_strip_weapon(id, wname)
				case 1: engclient_cmd(id, "drop", wname)			
			}
		}
	}
}

stock fm_give_item(index, const item[]) 
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5))
		return 0
	
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent))
		return 0

	new Float:origin[3]
	pev(index, pev_origin, origin)
	set_pev(ent, pev_origin, origin)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	set_pev(ent, pev_impulse, WP)
	dllfunc(DLLFunc_Spawn, ent)

	new save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, index)
	if (pev(ent, pev_solid) != save)
		return ent

	engfunc(EngFunc_RemoveEntity, ent)
	
	return -1
}

stock ham_strip_weapon(id,weapon[])
{
	if(!equal(weapon,"weapon_",7)) return 0
	
	new wId = get_weaponid(weapon)
	if(!wId) return 0
	
	new wEnt
	while((wEnt = engfunc(EngFunc_FindEntityByString, wEnt, "classname", weapon)) && pev(wEnt, pev_owner) != id) {}
	if(!wEnt) return 0
	
	new iTmp
	if(get_user_weapon(id, iTmp, iTmp) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon, wEnt)
	
	if(!ExecuteHamB(Ham_RemovePlayerItem, id, any:wEnt)) return 0
	
	ExecuteHamB(Ham_Item_Kill, wEnt)
	set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1<<wId))
	
	return 1
}

stock fm_set_user_money(client, money, flash=1)
{
	set_pdata_int(client, m_iAccount, money, XO_PLAYER)
	
	static Money
	if( Money || (Money = get_user_msgid("Money")) )
	{
		emessage_begin(MSG_ONE_UNRELIABLE, Money, _, client)
		ewrite_long(money)
		ewrite_byte(flash ? 1 : 0)
		emessage_end()
	}
}


