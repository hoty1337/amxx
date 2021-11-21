#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <color>
#include <zombieplague>

native zp_get_user_lvl(id)

#define TASK_STUN 6675
#define ID_STUN (taskid - TASK_STUN)
#pragma tabsize 0
#define is_user_valid(%1) (1 <= %1 <= get_maxplayers())

// Menu keys
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_0

enum
{
	GERRARD,
	SAS,
	SPETSNAZ,
	HUNTER,
	DARTHVADER,
	KENJY,
	BLACKGUARD,
	HATSUNE,
}

new const CHARACTER[][] =
{
	"Gerrard",
	"Sas",
	"Spetsnaz",
	"Hunter",
	"Raf Simons",
	"Kenjy",
	"SpetsnaZ",
	"Black Guard"
}

new g_szPrivilege[33][32]
new g_ZombieStun[33], info_target
new Float:g_temp_speed[33], g_spr_trapped
new g_iCharacter[33]
new g_modelindex_man;

new bool:g_bChoosed[33] = false;

public plugin_init()
{
	register_plugin("hum class", "Live", "unknown")
	
	register_event("HLTV", "EventHLTV", "a", "1=0", "2=0")
	info_target = engfunc(EngFunc_AllocString, "info_target")
	
	register_menu("Human class", KEYSMENU, "menu_humclass")

	RegisterHam(Ham_Spawn, 		"player", "HookHam_SpawnPlayer", .Post=true)
	RegisterHam(Ham_TakeDamage, "player", "HookHam_TakeDamage", .Post=false)
	RegisterHam(Ham_Player_PreThink, "player", "HookHam_Player_PreThink")
	RegisterHam(Ham_Killed, "player", "HookHam_Killed", .Post=true)
		
	register_think("ef_lethal", "delete")
}

public delete(ent)if(pev_valid(ent))engfunc(EngFunc_RemoveEntity, ent)

public plugin_precache()
{
	g_spr_trapped = precache_model("sprites/bz_sprite/slowed.spr")
	precache_model("sprites/bz_sprite/normal_kill.spr")
	precache_model("sprites/bz_sprite/knife_kill.spr")
	
	g_modelindex_man = engfunc(EngFunc_PrecacheModel, "models/player/bz_submodel228/bz_submodel228.mdl")

	precache_sound("BZ_sound/PossessionMissileHit1.wav")
}

public plugin_natives()
{
	register_native("zp_get_character", "native_get_character", 1)
	register_native("zp_set_character", "native_set_character", 1)
	register_native("zp_get_character_choosed", "native_get_character_choosed", 1)
	register_native("humanclass_open", "Assault_Main", 1)
}

public EventHLTV()
{	
	for(new id = 1; id <= get_maxplayers(); id++)
	{
		if(is_user_connected(id)) 
		{
			ResetValue(id);
			g_bChoosed[id] = false
		}
	}
}

public client_disconnect(id)
{
	ResetValue(id)
}

public zp_user_humanized_post(id)
{
	ResetValue(id)
}

public zp_user_infected_post(id)
{
	ResetValue(id)
}

public HookHam_SpawnPlayer(id)
{
	if(!is_user_connected(id))
		return;
	
	if(!is_user_alive(id))
		return;
	
	if(zp_get_user_zombie(id))
		return;	
        	
	new body
	body = g_iCharacter[id]
	set_pev(id, pev_body, body)
}

public HookHam_TakeDamage(victim, weapon, attacker, Float:damage, damagebits) 
{
	if (!is_user_alive(victim) || !is_user_alive(attacker))
		return HAM_IGNORED
		
	if (victim == attacker)
		return HAM_IGNORED
	
	if(zp_get_user_zombie(attacker) || zp_get_user_nemesis(attacker) || zp_get_user_survivor(attacker))
		return HAM_IGNORED;
	
	if(zp_get_user_first_zombie(victim))
		return HAM_IGNORED

	if((g_iCharacter[attacker] == SAS)
	&& (get_user_weapon(attacker) == CSW_MAC10 || get_user_weapon(attacker) == CSW_AUG || get_user_weapon(attacker) == CSW_UMP45
	|| get_user_weapon(attacker) == CSW_GALIL || get_user_weapon(attacker) == CSW_SG552 || get_user_weapon(attacker) == CSW_FAMAS
	|| get_user_weapon(attacker) == CSW_MP5NAVY || get_user_weapon(attacker) == CSW_M4A1 || get_user_weapon(attacker) == CSW_TMP
	|| get_user_weapon(attacker) == CSW_AK47 || get_user_weapon(attacker) == CSW_P90))
		SetHamParamFloat(4, damage + ( damage * 0.15 ))
	else if(g_iCharacter[attacker] == SPETSNAZ
	&& (get_user_weapon(attacker) == CSW_SG550 
	|| get_user_weapon(attacker) == CSW_SCOUT 
	|| get_user_weapon(attacker) == CSW_AWP 
	|| get_user_weapon(attacker) == CSW_G3SG1))
		SetHamParamFloat(4, damage + ( damage * 0.15 ))
	else if(g_iCharacter[attacker] == HUNTER
	&& (get_user_weapon(attacker) == CSW_M3
	|| get_user_weapon(attacker) == CSW_XM1014))
		SetHamParamFloat(4, damage + ( damage * 0.15 ))
	else if(g_iCharacter[attacker] == HUNTER
	&& (get_user_weapon(attacker) == CSW_M249))
		SetHamParamFloat(4, damage + ( damage * 0.15 ))

	if(g_iCharacter[attacker] == KENJY && g_iCharacter[attacker] == DARTHVADER && zp_get_user_zombie(victim) && !zp_get_user_nemesis(victim))
	{
		if(g_ZombieStun[victim])
			return HAM_HANDLED;
		
		new g_Chance[33];
		
		g_Chance[attacker] = random_num(0, 150)
		if(g_Chance[attacker] < 1)
		{
			Function_ZombieStun(victim)
			emit_sound(victim, CHAN_AUTO, "BZ_sound/PossessionMissileHit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_task(3.0, "Reset_ZombieStun", victim+TASK_STUN)
		}
	}
		
	if(g_iCharacter[attacker] == BLACKGUARD && zp_get_user_zombie(victim) && !zp_get_user_nemesis(victim))
	{
		new g_Chance[33];
		
		g_Chance[attacker] = random_num(0, 250)
		if(g_Chance[attacker] < 1)
		{
			ExecuteHamB(Ham_Killed, victim, attacker, 2)
			
			static Float:Origin[3]
			pev(victim,pev_origin,Origin);Origin[2]=Origin[2]+90.0
	
			Lethal_Sprite(0, Origin)	
		}
	}
		
	if(g_iCharacter[attacker] == HATSUNE && zp_get_user_zombie(victim) && !zp_get_user_nemesis(victim))
	{
		new g_Chance[33];
		new g_Chance2[33];
		
		g_Chance[attacker] = random_num(0, 250)
		g_Chance2[attacker] = random_num(0, 250)
		if(g_Chance[attacker] < 1)
		{
			ExecuteHamB(Ham_Killed, victim, attacker, 2)
			
			static Float:Origin[3]
			pev(victim,pev_origin,Origin);
			Origin[2] = Origin[2] + 90.0
	
			Lethal_Sprite(0, Origin)	
		}
		if(g_Chance2[attacker] < 1)
		{
			Function_ZombieStun(victim)
			emit_sound(victim, CHAN_AUTO, "BZ_sound/PossessionMissileHit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_task(3.0, "Reset_ZombieStun", victim+TASK_STUN)
		}		
	}	

	if((g_iCharacter[attacker] == KENJY) && zp_get_user_zombie(victim) && !zp_get_user_nemesis(victim))
	{
		if(get_user_weapon(attacker) != CSW_KNIFE)
			return HAM_IGNORED;
				
		new g_Chance[33];
		
		g_Chance[attacker] = random_num(0, 150)
		if(g_Chance[attacker] < 1)
		{
			ExecuteHamB(Ham_Killed, victim, attacker, 2)
			
			static Float:Origin[3]
			pev(victim,pev_origin,Origin); 
			Origin[2] = Origin[2] + 90.0
	
			Lethal_Sprite(1, Origin)	
		}
	}	
		
	return HAM_HANDLED
}

public HookHam_Killed(victim, attacker, shouldgib)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim))
		return HAM_IGNORED;
	
	if(zp_get_user_zombie(attacker) || zp_get_user_nemesis(attacker) || zp_get_user_survivor(attacker))
		return HAM_IGNORED;
	
	if(g_iCharacter[attacker])
		return HAM_IGNORED;

	if(zp_get_user_first_zombie(victim))
		return HAM_IGNORED
	
	if(get_pdata_int(victim, 75, 5) == HIT_HEAD)
	{
		switch(random_num(0, 5))
		{
			case 3:
			{
               return HAM_IGNORED;
			}
		}
	}
	
	return HAM_HANDLED;
}


/* MAY SKILL - STUN */
public Function_ZombieStun(id)
{
	g_ZombieStun[id] = 1
	pev(id, pev_maxspeed, g_temp_speed[id])
	set_pev(id, pev_maxspeed, 70.0)
	
	CreateSlowSprites(id)
	
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id)
	write_short(0)
	write_short(0)
	write_short(0x0004)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(50)
	message_end()
}

public Reset_ZombieStun(taskid)
{
	UnFreezePlayer(ID_STUN)
}

UnFreezePlayer(id)
{
	g_ZombieStun[id] = 0
	
	set_pev(id, pev_maxspeed, g_temp_speed[id])
	RemoveSlowSprites(id)
	
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id)
	write_short(1<<12)
	write_short(0)
	write_short(0x0000)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(50)
	message_end()
}

CreateSlowSprites(id)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_PLAYERATTACHMENT)
	write_byte(id)
	write_coord(35)
	write_short(g_spr_trapped)
	write_short(999)
	message_end()
}

RemoveSlowSprites(id)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_KILLPLAYERATTACHMENTS)
	write_byte(id)
	message_end()
}

ResetValue(id)
{
	if(g_ZombieStun[id]) 
		RemoveSlowSprites(id);
	
	g_ZombieStun[id] = 0

	remove_task(id+TASK_STUN)
}

public HookHam_Player_PreThink(id)
{
	if(!is_user_alive(id) && !zp_get_user_zombie(id)) return HAM_IGNORED

	if(g_ZombieStun[id])
	{
		set_pev(id, pev_maxspeed, 70.0)
	}

	return HAM_IGNORED	
}

/* ASSAULT MAIN MENU */
public Assault_Main(id)
{
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
	
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	
	if(zp_has_round_started())
		return PLUGIN_HANDLED;
	
	if(g_bChoosed[id])
		return PLUGIN_HANDLED;
	
	if(zp_get_user_zombie(id) || zp_get_user_nemesis(id))
		return PLUGIN_HANDLED;
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wВыбери класс человека \r[BZ]^n\r[ZP] \wВаш класс: \r%s^n^n", CHARACTER[g_iCharacter[id]])
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wGerrard^n")
	
	if(zp_get_user_lvl(id) >= 15)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wSas^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dSas \r[L: 15]^n")
	
	if(zp_get_user_lvl(id) >= 25)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wNano^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dNano \r[L: 25]^n")
	
	if(zp_get_user_lvl(id) >= 35)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wHunter^n^n")	
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dHunter \r[L: 35]^n^n")	
	
	if(get_user_flags(id) & ADMIN_LEVEL_H)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \yRaf Simons^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dRaf Simons \r(VIP)^n")	
	
	if(get_user_flags(id) & ADMIN_LEVEL_E)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[6] \yKenjy^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dKenjy \r(PREMIUM)^n")

	if(get_user_flags(id) & ADMIN_LEVEL_B)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \ySpetsnaZ^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[7] \dSpetsnaZ \r(ADMIN)^n")
	
	if(get_user_flags(id) & ADMIN_LEVEL_D)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[8] \yBlack Guard^n^n")
    else len += formatex(menu[len], charsmax(menu) - len, "\r[8] \dBlack Guard \r(BOSS)^n^n")	
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[0]\w Выход")
	
	show_menu(id, KEYSMENU, menu, -1, "Human class")
    return PLUGIN_HANDLED;	
}

public menu_humclass(id, key)
{		
	switch (key)
	{		
		case 0: 
		{
			g_iCharacter[id] = GERRARD
			Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gGerrard")
			Color(id, print_chat, "!g[ZP]!y Способности: !gнет способностей")
			zp_override_user_model(id, "bz_submodel228")
		    set_pev(id, pev_body, 1)
			g_bChoosed[id] = true
			return PLUGIN_HANDLED
		}
		case 1: 
		{
		    if(zp_get_user_lvl(id) >= 15){
			   g_iCharacter[id] = SAS
			   Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gSAS")
			   Color(id, print_chat, "!g[ZP]!y Способности: !gАвтомат DMG++")
			   zp_override_user_model(id, "bz_submodel228")
		       set_pev(id, pev_body, 2)
			   g_bChoosed[id] = true
			}else{ 
			Assault_Main(id)
			Color(id, print_chat, "!g[ZP]!y Данный класс доступен с !g15 !yуровня!") 
			}
		}
		case 2: 
		{
		    if(zp_get_user_lvl(id) >= 25){
			g_iCharacter[id] = SPETSNAZ
			Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gNano")
			Color(id, print_chat, "!g[ZP]!y Способности: !gСнайперки DMG++")
			zp_override_user_model(id, "bz_submodel228")
		    set_pev(id, pev_body, 3)
			g_bChoosed[id] = true
			}else{ 
			Assault_Main(id)
			Color(id, print_chat, "!g[ZP]!y Данный класс доступен с !g25 !yуровня!") 
			}
		}
		case 3: 
		{
			if(zp_get_user_lvl(id) >= 35){
			g_iCharacter[id] = HUNTER
			Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gHunter")
			Color(id, print_chat, "!g[ZP]!y Способности: !gShotgun DMG++ !y| !gПулеметы DMG++")
			zp_override_user_model(id, "bz_submodel228")
		    set_pev(id, pev_body, 4)
			g_bChoosed[id] = true
			}else{ 
			Assault_Main(id)
			Color(id, print_chat, "!g[ZP]!y Данный класс доступен с !g35 !yуровня!") 
			}
		}
		case 4: 
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				g_iCharacter[id] = DARTHVADER
			    Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gRaf Simons")
				Color(id, print_chat, "!g[ZP]!y Способности: !gЗамедление зомби")
			    zp_override_user_model(id, "bz_submodel228")
		        set_pev(id, pev_body, 5)
				g_bChoosed[id] = true
			}else{
			    Assault_Main(id)
				Color(id, print_chat, "!g[ZP]!y У вас нету !g VIP!y прав, напишите в VK: !g vk.com/darkshowy")
			}
		}		
		case 5: 
		{
			if(get_user_flags(id) & ADMIN_LEVEL_E)
			{
				g_iCharacter[id] = KENJY
			    Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gKenjy")
				Color(id, print_chat, "!g[ZP]!y Способности: !gЗамедление зомби !y| !gКрит урон с ножа")
			    zp_override_user_model(id, "bz_submodel228")
		        set_pev(id, pev_body, 6)
				g_bChoosed[id] = true
			}else{
			    Assault_Main(id)
				Color(id, print_chat, "!g[ZP]!y У вас нету !g PREMIUM!y прав, напишите в VK: !g vk.com/darkshowy")
			}
		}
		case 6: 
		{
			if(get_user_flags(id) & ADMIN_LEVEL_B)
			{
			   g_iCharacter[id] = BLACKGUARD
			
			   Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gSpetsnaZ")
			   Color(id, print_chat, "!g[ZP]!y Способности: !gКритический удар")
			   zp_override_user_model(id, "bz_submodel228")
		       set_pev(id, pev_body, 7)
			   g_bChoosed[id] = true
			}else{
			    Assault_Main(id)
				Color(id, print_chat, "!g[ZP]!y У вас нету !g ADMIN!y прав, напишите в VK: !g vk.com/darkshowy")
			}
		}	
		case 7: 
		{
			if(get_user_flags(id) & ADMIN_LEVEL_D)
			{
			  g_iCharacter[id] = HATSUNE
			  Color(id, print_chat, "!g[ZP]!y Вы выбрали персонажа: !gBlack Guard")
			  Color(id, print_chat, "!g[ZP]!y Способности: !gКритический удар !y| !gЗамедление")
			  zp_override_user_model(id, "bz_submodel228")
		      set_pev(id, pev_body, 8)
			  g_bChoosed[id] = true
			}else{
			    Assault_Main(id)
				Color(id, print_chat, "!g[ZP]!y У вас нету !g BOSS!y прав, напишите в VK: !g vk.com/darkshowy")
			}
		}
	}	
	
	ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, 373))
	
	fm_cs_set_user_model_index(id, g_modelindex_man)
	
	return PLUGIN_HANDLED	
}

/* NATIVES */
public native_get_character(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_iCharacter[id];
}

public native_set_character(id, classid)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	g_iCharacter[id] = classid
	return true;
}

public native_get_character_choosed(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_bChoosed[id];
}

stock Lethal_Sprite(type, Float:Origin[3])
{
	new ient = engfunc(EngFunc_CreateNamedEntity, info_target)
	
	switch(type)
	{
		case 0: engfunc(EngFunc_SetModel, ient, "sprites/bz_sprite/normal_kill.spr")
		case 1: engfunc(EngFunc_SetModel, ient, "sprites/bz_sprite/knife_kill.spr")
	}
	set_pev(ient, pev_classname, "ef_lethal")
	set_pev(ient, pev_movetype, MOVETYPE_NOCLIP)
	set_pev(ient, pev_gravity, 0.0001)
	set_pev(ient, pev_solid, SOLID_TRIGGER)
	set_pev(ient, pev_rendermode, kRenderTransAdd)
	set_pev(ient, pev_renderamt, 250.0)
	set_pev(ient, pev_nextthink, get_gametime() + 3.0)
	set_pev(ient, pev_origin, Origin)
	set_pev(ient, pev_scale, 0.4)
	set_pev(ient, pev_framerate, 0.0)
	return ient
}

stock fm_cs_set_user_model_index(id, value)
{
	if (!value) 
		return;
	
	set_pdata_int(id, 491, value, 5)
}