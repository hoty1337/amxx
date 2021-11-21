#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>

#pragma tabsize 0

#define PLUGIN 	"[JBS] Grab + Menu"
#define VERSION	"3.0"
#define AUTHOR	"Edit By NiKiTa"

#define ADMIN 		ADMIN_LEVEL_H

#define GRAB_MENU 				//Закомментируйте, если вам не нужно Граб Меню.
//#define GRAB_COLOR				//Закомментируйте, если вам не нужнен Цвет Граба.

#define JB_PREFIX	"!y[!gKnife DM!y]"

#define TSK_CHKE 50

new client_data[33][4]
#define GRABBED  0
#define GRABBER  1
#define GRAB_LEN 2
#define FLAGS    3
#define m_flNextAttack 83

#define CDF_IN_PUSH   (1<<0)
#define CDF_IN_PULL   (1<<1)
#define CDF_NO_CHOKE  (1<<2)

//native jbe_get_day_week();
//native jbe_get_day_mode();
//native jbe_informer_offset_up(id);
//native jbe_informer_offset_down(id);
//native jbe_is_user_wanted(id);
//native jbe_is_user_free(id);
//native jbe_sub_user_wanted(id);
//native jbe_add_user_wanted(id);
//native jbe_sub_user_free(id);
//native jbe_add_user_free(id);

enum
{
	r = 0.0,
	g = 255.0,
	b = 255.0,

	a = 200.0
};

new iPlayerType[33][2], bool:g_Freez[33];
new p_enabled, p_players_only
new p_throw_force, p_min_dist, p_speed, p_grab_force
new p_choke_time, p_choke_dmg, p_auto_choke
new p_glow
new speed_off[33]
new g_short
new model_gibs
new MAXPLAYERS
new SVC_SCREENSHAKE, SVC_SCREENFADE, WTF_DAMAGE

new color1[33],color2[33],color3[33];

new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

public plugin_init( )
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("CurWeapon", "CurrentWeapon", "be", "1=1")
	RegisterHam(Ham_Spawn, "player", "SpawnPlayer")
	
	register_dictionary("jbe_core.txt")

	p_enabled = register_cvar( "gp_enabled", "1" )
	p_players_only = register_cvar( "gp_players_only", "0" )
	
	p_min_dist = register_cvar ( "gp_min_dist", "90" )
	p_throw_force = register_cvar( "gp_throw_force", "1500" )
	p_grab_force = register_cvar( "gp_grab_force", "8" )
	p_speed = register_cvar( "gp_speed", "5" )
	
	p_choke_time = register_cvar( "gp_choke_time", "1.5" )
	p_choke_dmg = register_cvar( "gp_choke_dmg", "5" )
	p_auto_choke = register_cvar( "gp_auto_choke", "1" )
	
	p_glow = register_cvar( "gp_glow", "1" )
	
	//register_clcmd( "amx_grab", "force_grab", ADMIN, "Grab client & teleport to you." )
	register_clcmd( "+grab", "grab", ADMIN, "bind a key to +grab" )
	register_clcmd( "-grab", "unset_grabbed" )
	
	register_clcmd( "+push", "push", ADMIN, "bind a key to +push" )
	register_clcmd( "-push", "push" )
	register_clcmd( "+pull", "pull", ADMIN, "bind a key to +pull" )
	register_clcmd( "-pull", "pull" )
	register_clcmd( "push", "push2" )
	register_clcmd( "pull", "pull2" )
	
	register_clcmd( "drop" ,"throw" )
	
	register_menu("Menu 1", keys, "func_menu") 
	register_menu("Menu 2", keys, "func1_menu") 
	//register_concmd("dgrabmenu", "grab_menu")
	register_clcmd("grabcolor", "GrabMenu")
	
	
	register_event( "DeathMsg", "DeathMsg", "a" )
	
	register_forward( FM_PlayerPreThink, "fm_player_prethink" )
	
	MAXPLAYERS = get_maxplayers()
	
	SVC_SCREENFADE = get_user_msgid( "ScreenFade" )
	SVC_SCREENSHAKE = get_user_msgid( "ScreenShake" )
	WTF_DAMAGE = get_user_msgid( "Damage" )
}

public client_putinserver(id)
{
	color1[id] = 7, color2[id] = 85, color3[id] = 255;
}

public GrabMenu(id)
{
	new name[32]
	get_user_name(id, name, 31)
	new szMenu[1024], iLen;
	iLen = 0
	iLen = formatex(szMenu[iLen], charsmax(szMenu), "%L \yВыбор цвета граба^n^n", id, "JBE_MENU_NOTHING");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСлучайный^n", id, "JBE_KEY_1")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wОранжевый^n", id, "JBE_KEY_2")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСиний^n", id, "JBE_KEY_3")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wКрасный^n", id, "JBE_KEY_4")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wЗеленый^n", id, "JBE_KEY_5")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wЖёлтый^n", id, "JBE_KEY_6")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wФиолетовый^n", id, "JBE_KEY_7")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wБелый^n", id, "JBE_KEY_8")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wПрозрачный^n^n", id, "JBE_KEY_9")
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wВыход^n", id, "JBE_KEY_0")
	
	show_menu(id, keys, szMenu, -1, "Menu 1")
	return PLUGIN_HANDLED
}

public func_menu(id, key)
{
	switch(key)
	{
		case 0:
		{
			color1[id] = random_num(50, 254), color2[id] = random_num(30, 200), color3[id] = random_num(90, 254);
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tслучайный", JB_PREFIX, color1[id], color2[id], color3[id]);
		}
		case 1:
		{
			color1[id] = 110, color2[id] = 70, color3[id] = 0;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tоранжевый", JB_PREFIX);
		}
		case 2:
		{
			color1[id] = 7, color2[id] = 85, color3[id] = 255;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tсиний", JB_PREFIX);
		}
		case 3:
		{
			color1[id] = 255, color2[id] = 3, color3[id] = 23;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tкрасный", JB_PREFIX);
		}
		case 4:
		{
			color1[id] = 5, color2[id] = 255, color3[id] = 99;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tзеленый", JB_PREFIX);
		}
		case 5:
		{
			color1[id] = 255, color2[id] = 255, color3[id] = 6;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tжёлтый", JB_PREFIX);
		}
		case 6:
		{
			color1[id] = 133, color2[id] = 10, color3[id] = 220;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tфиолетовый", JB_PREFIX);
		}
		case 7:
		{
			color1[id] = 255, color2[id] = 255, color3[id] = 255;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tбелый", JB_PREFIX);
		}
		case 8:
		{
			color1[id] = 0, color2[id] = 0, color3[id] = 0;
			UTIL_SayText(id, "%s !yВы изменили цвет граба на !tпрозрачный", JB_PREFIX);
		}
		case 9:return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public plugin_precache( )
{
	precache_sound("player/PL_PAIN2.WAV");
	//engfunc(EngFunc_PrecacheModel, "models/jbs_grab/v_grab.mdl");
}

public fm_player_prethink( id )
{
	new target
	//Search for a target
	if ( client_data[id][GRABBED] == -1 )
	{
		new Float:orig[3], Float:ret[3]
		get_view_pos( id, orig )
		ret = vel_by_aim( id, 9999 )
		
		ret[0] += orig[0]
		ret[1] += orig[1]
		ret[2] += orig[2]
		
		target = traceline( orig, ret, id, ret )
		
		if( 0 < target <= MAXPLAYERS )
		{
			if( is_grabbed( target, id ) ) return FMRES_IGNORED

			set_grabbed( id, target )
		}
		else if( !get_pcvar_num( p_players_only ) )
		{
			new movetype
			if( target && pev_valid( target ) )
			{
				movetype = pev( target, pev_movetype )
				if( !( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS ) )
					return FMRES_IGNORED
			}
			else
			{
				target = 0
				new ent = engfunc( EngFunc_FindEntityInSphere, -1, ret, 12.0 )
				while( !target && ent > 0 )
				{
					movetype = pev( ent, pev_movetype )
					if( ( movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS )
							&& ent != id  )
						target = ent
					ent = engfunc( EngFunc_FindEntityInSphere, ent, ret, 12.0 )
				}
			}
			if( target )
			{
				if( is_grabbed( target, id ) )
					return FMRES_IGNORED
				set_grabbed( id, target )
			}
		}
	}
	
	target = client_data[id][GRABBED]
	//If they've grabbed something
	if( target > 0 )
	{
		if( !pev_valid( target ) || ( pev( target, pev_health ) < 1 && pev( target, pev_max_health ) ) )
		{
			unset_grabbed( id )
			return FMRES_IGNORED
		}
		 
		//Use key choke
		if( pev( id, pev_button ) & IN_USE )
			do_choke( id )
		
		//Push and pull
		new cdf = client_data[id][FLAGS]
		if ( cdf & CDF_IN_PULL )
			do_pull( id )
		else if ( cdf & CDF_IN_PUSH )
			do_push( id )
		
		if( target > MAXPLAYERS ) grab_think( id )
	}
	//If they're grabbed
	target = client_data[id][GRABBER]
	if( target > 0 ) grab_think( target )
	
	return FMRES_IGNORED
}

public jbe_set_hand_model(pPlayer)
{
	static iszViewModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jbs_grab/v_grab.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
}

public grab_think( id ) //id of the grabber
{
	new target = client_data[id][GRABBED]
	
	//Keep grabbed clients from sticking to ladders
	if( pev( target, pev_movetype ) == MOVETYPE_FLY && !(pev( target, pev_button ) & IN_JUMP ) ) client_cmd( target, "+jump;wait;-jump" )
	
	//Move targeted client
	new Float:tmpvec[3], Float:tmpvec2[3], Float:torig[3], Float:tvel[3]
	
	get_view_pos( id, tmpvec )
	
	tmpvec2 = vel_by_aim( id, client_data[id][GRAB_LEN] )
	
	torig = get_target_origin_f( target )
	
	new force = get_pcvar_num( p_grab_force )
	
	tvel[0] = ( ( tmpvec[0] + tmpvec2[0] ) - torig[0] ) * force
	tvel[1] = ( ( tmpvec[1] + tmpvec2[1] ) - torig[1] ) * force
	tvel[2] = ( ( tmpvec[2] + tmpvec2[2] ) - torig[2] ) * force
	
	set_pev( target, pev_velocity, tvel )
}

stock Float:get_target_origin_f( id )
{
	new Float:orig[3]
	pev( id, pev_origin, orig )
	
	//If grabbed is not a player, move origin to center
	if( id > MAXPLAYERS )
	{
		new Float:mins[3], Float:maxs[3]
		pev( id, pev_mins, mins )
		pev( id, pev_maxs, maxs )
		
		if( !mins[2] ) orig[2] += maxs[2] / 2
	}
	
	return orig
}

public grab( id, level, cid )
{
	if(!is_user_alive(id) && !(get_user_flags(id) & ADMIN_RCON)) return PLUGIN_HANDLED;
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		if ( !client_data[id][GRABBED] ) 
			client_data[id][GRABBED] = -1	
	}
	else if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		if ( !client_data[id][GRABBED] && !is_user_alive(id)) 
			client_data[id][GRABBED] = -1	
	}
	
	return PLUGIN_HANDLED
}

public SpawnPlayer(id)
	speed_off[id] = false

public CurrentWeapon(id)
{
	if(speed_off[id])
		set_pev(id, pev_maxspeed, 00000.0)
}

public grab_menu(id)
{
	new name[32]
	new target = client_data[id][GRABBED]
	new szMenu[1024], iLen;
	new iKeys;
	new health = get_user_health(target);
	if(target && is_user_alive(target))
	{
		get_user_name(target, name, charsmax(name))
	}
	iLen = 0
	iLen = formatex(szMenu[iLen], charsmax(szMenu), "%L \wТы взял %s ^n\yВыбери действие:^n^n", id, "JBE_MENU_NOTHING", name);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wЗабрать оружие^n", id, "JBE_KEY_1");
	iKeys |= (1<<0);
	
	if(health < 100)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wПодлечить \r[%d хп]^n", id, "JBE_KEY_2", health);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \dПодлечить \r[%d хп]^n", id, "JBE_KEY_NOT", health);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wКрутануть экран^n", id, "JBE_KEY_3");
	iKeys |= (1<<2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wПеревести за: \r[%s]^n", id, "JBE_KEY_4", cs_get_user_team(target) == 1 ? "CT" : "TT");
	iKeys |= (1<<3);
		//if(cs_get_user_team(target) == 1)
		//{
		//	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wРозыск: \r[%s]^n", id, "JBE_KEY_5", jbe_is_user_wanted(target) ? "Забрать" : "Выдать");
		//	iKeys |= (1<<4);
		//}
		//else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \dРозыск: \r[%s]^n", id, "JBE_KEY_NOT", jbe_is_user_wanted(target) ? "Забрать" : "Выдать");

		//if(cs_get_user_team(target) == 1)
		//{
		//	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСвободный день: \r[%s]^n", id, "JBE_KEY_6", jbe_is_user_free(target) ? "Забрать" : "Выдать");
		//	iKeys |= (1<<5);
		//}
		//else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \dСвободный день: \r[%s]^n", id, "JBE_KEY_NOT", jbe_is_user_free(target) ? "Забрать" : "Выдать");
		
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wИгрок: \r[%s]^n", id, "JBE_KEY_5", !g_Freez[target] ? "Заморозить" : "Разморозить");
		iKeys |= (1<<4);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wБесмертие: \r[%s]^n", id, "JBE_KEY_6", get_user_godmode(target) ? "Забрать" : "Выдать");
		iKeys |= (1<<5);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wУбить игрока^n", id, "JBE_KEY_7");
	iKeys |= (1<<6);
	
	show_menu(id, iKeys, szMenu, -1, "Menu 2")
	return PLUGIN_HANDLED
}

public func1_menu(id, key)
{
	new tg = client_data[id][GRABBED]
	new pName[32], tName[32]
	get_user_name(id, pName, charsmax(tName));
	get_user_name(tg, tName, charsmax(tName));
	if(iPlayerType[id][0] == 1) if(!is_user_alive(tg) || !is_user_connected(tg)) return PLUGIN_HANDLED;
	switch(key)
	{
		case 0:
		{
			fm_strip_user_weapons(tg);
			fm_give_item(tg, "weapon_knife");
			UTIL_SayText(0, "%s !g%s!y забрал всё оружие у !t%s!y.", JB_PREFIX, pName, tName);
		}
		case 1:
		{
			set_pev(tg, pev_health, 100.0);
			UTIL_SayText(0, "%s !g%s!y вылечил !t%s!y.", JB_PREFIX, pName, tName);
		}
		case 2: 
		{
			set_pev(tg, pev_punchangle, { 400.0, 999.0, 400.0 })
			UTIL_SayText(0, "%s !g%s!y закрутил экран !t%s!y", JB_PREFIX, pName, tName);
		}
		case 3:
		{
            switch(cs_get_user_team(tg))
            {
				case 1:
				{
					cs_set_user_team(tg, 2);
					UTIL_SayText(0, "%s !g%s!y перевёл !t%s!y за !tохрану!y", JB_PREFIX, pName, tName);
				}
				default: 
				{
					cs_set_user_team(tg, 1);
					UTIL_SayText(0, "%s !g%s!y перевёл !t%s!y за !tзаключённых!y.", JB_PREFIX, pName, tName);
				}
            }
		}
		//case 4:
		//{
       //     if(jbe_is_user_wanted(tg))
       //     {
		//		jbe_sub_user_wanted(tg)
		//		UTIL_SayText(0, "%s !g%s!y забрал розыск !t%s!y", JB_PREFIX, pName, tName);
       //     }
		//	else
        //    {
		//		jbe_add_user_wanted(tg);
		//		UTIL_SayText(0, "%s !g%s!y выдал розыск !t%s!y", JB_PREFIX, pName, tName);
       //     }
	//	}
	//	case 5: 
	//	{
       //     if(jbe_is_user_free(tg))
      ///      {
	//			jbe_sub_user_free(tg)
		//		UTIL_SayText(0, "%s !g%s!y забрал свободный день у !t%s!y.", JB_PREFIX, pName, tName);
       //     }
		//	else
      //      {
	//			jbe_add_user_free(tg);
		//		UTIL_SayText(0, "%s !g%s!y выдал свободный день !t%s!y.", JB_PREFIX, pName, tName);
      //      }
	//	}
		case 4: 
		{
			switch(g_Freez[tg])
			{
				case false:
				{
					g_Freez[tg] = true;
					set_pev(tg, pev_flags, pev(tg, pev_flags) | FL_FROZEN);
					UTIL_SayText(0, "%s !g%s!y заморозил !g%s!y", JB_PREFIX, pName, tName);
				}
				case true:
				{
					g_Freez[tg] = false;
					set_pev(tg, pev_flags, pev(tg, pev_flags) & ~FL_FROZEN);
					UTIL_SayText(0, "%s !g%s!y разморозил !g%s!y", JB_PREFIX, pName, tName);
				}
			}
		}
		case 5:
		{
			if(get_user_godmode(tg))
			{
				set_user_godmode(tg, 0);
				UTIL_SayText(0, "%s !g%s!y забрал Бесмертие у !g%s!y", JB_PREFIX, pName, tName);
			}
			else
			{
				set_user_godmode(tg, 1);
				UTIL_SayText(0, "%s !g%s!y дал Бесмертие у !g%s!y", JB_PREFIX, pName, tName);
			}
		}
		case 6:
		{
			if(is_user_alive(tg))
			{
				ExecuteHamB(Ham_Killed, tg, id, 2);
				UTIL_SayText(0, "%s !g%s !tубил игрока !g%s", JB_PREFIX, pName, tName);
			}
		}
	}
	return PLUGIN_HANDLED;
}

public throw( id )
{
	new target = client_data[id][GRABBED]
	if( target > 0 )
	{
		set_pev( target, pev_velocity, vel_by_aim( id, get_pcvar_num(p_throw_force) ) )
		unset_grabbed( id )
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public unset_grabbed( id )
{
	new target = client_data[id][GRABBED]
	if( target > 0 && pev_valid( target ) )
	{
		set_pev( target, pev_renderfx, kRenderFxNone )
		set_pev( target, pev_rendercolor, {255.0, 255.0, 255.0} )
		set_pev( target, pev_rendermode, kRenderNormal )
		set_pev( target, pev_renderamt, 16.0 )
		
		if( 0 < target <= MAXPLAYERS )
			client_data[target][GRABBER] = 0
	}
	show_menu(id, 0, "^n", 1)
	client_data[id][GRABBED] = 0
}

//Grabs onto someone
public set_grabbed( id, target )
{
	#if defined JBE_ON
	if(jbe_get_day_week() > 5) return 1;
	#endif
	if(!(get_user_flags(id) & ADMIN_LEVEL_H))return 1;
	if( get_pcvar_num( p_glow ) )
	{
		new Float:color[3]
		color[0] = float(color1[id]);
		color[1] = float(color2[id]);
		color[2] = float(color3[id]);
		set_pev( target, pev_renderfx, kRenderFxGlowShell )
		set_pev( target, pev_rendercolor, color )
		set_pev( target, pev_rendermode, kRenderTransColor )
		set_pev( target, pev_renderamt, a )
	}
	
	if( 0 < target <= MAXPLAYERS )
		client_data[target][GRABBER] = id
	client_data[id][FLAGS] = 0
	client_data[id][GRABBED] = target
	new name[33], name2[33]
	get_user_name(id, name, 32) 
	get_user_name(target, name2, 32)
	if(get_user_team(target)==1 || get_user_team(target)==2)
	{		
		UTIL_SayText(target, "%s !yАдминистратор !t%s !yвзял вас !gграбом", JB_PREFIX, name)		
		UTIL_SayText(id, "%s !yВы взяли !gГрабом !yигрока !t%s", JB_PREFIX, name2)
		grab_eff(target)
		#if defined GRAB_MENU
		grab_menu(id)
		#endif
		#if defined GRAB_COLOR
		GrabMenu(id)
		#endif
	}
	else
	{
		UTIL_SayText(id, "%s !yВы взяли !gГрабом !tОружие", JB_PREFIX)
		UTIL_SayText(0, "%s !yАдминистратор !t%s !yвзял !gграбом !tОружие", JB_PREFIX, name)	
	}
	new Float:torig[3], Float:orig[3]
	pev( target, pev_origin, torig )
	pev( id, pev_origin, orig )
	client_data[id][GRAB_LEN] = floatround( get_distance_f( torig, orig ) )
	if( client_data[id][GRAB_LEN] < get_pcvar_num( p_min_dist ) ) client_data[id][GRAB_LEN] = get_pcvar_num( p_min_dist )

	return 1;
}	

public grab_eff(target)
{
    new origin[3]
   
    get_user_origin(target,origin)
   
    message_begin(MSG_ALL,SVC_TEMPENTITY,{0,0,0},target)
    write_byte(TE_SPRITETRAIL) //Спрайт захвата
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2]+20)
    write_coord(origin[0])
    write_coord(origin[1])
    write_coord(origin[2]+80)
    write_short(g_short)
    write_byte(20)
    write_byte(20)
    write_byte(4)
    write_byte(20)
    write_byte(10)
    message_end()
}

public grab_eff_zd(id, target)
{
    new origin[3]
    get_user_origin(id, origin, 3)

    message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
    write_byte(TE_BREAKMODEL); // TE_
    write_coord(origin[0]); // X
    write_coord(origin[1]); // Y
    write_coord(origin[2] + 24); // Z
    write_coord(16); // size X
    write_coord(16); // size Y
    write_coord(16); // size Z
    write_coord(random_num(-50,50)); // velocity X
    write_coord(random_num(-50,50)); // velocity Y
    write_coord(25); // velocity Z
    write_byte(10); // random velocity
    write_short(model_gibs); // sprite
    write_byte(9); // count
    write_byte(20); // life
    write_byte(0x08); // flags
    message_end();    
}
	
public push(id)
{
	client_data[id][FLAGS] ^= CDF_IN_PUSH
	return PLUGIN_HANDLED
}

public pull(id)
{
	client_data[id][FLAGS] ^= CDF_IN_PULL
	return PLUGIN_HANDLED
}

public push2 (id)
{
	if( client_data[id][GRABBED] > 0)
	{
		do_push(id)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public pull2( id )
{
	if( client_data[id][GRABBED] > 0 )
	{
		do_pull( id )
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public do_push( id )
	if( client_data[id][GRAB_LEN] < 9999 )
		client_data[id][GRAB_LEN] += get_pcvar_num( p_speed )

public do_pull( id )
{
	new mindist = get_pcvar_num( p_min_dist )
	new len = client_data[id][GRAB_LEN]
	
	if( len > mindist )
	{
		len -= get_pcvar_num( p_speed )
		if( len < mindist ) len = mindist
		client_data[id][GRAB_LEN] = len
	}
	else if( get_pcvar_num( p_auto_choke ) )
		do_choke( id )
}

public do_choke( id )
{
	new target = client_data[id][GRABBED]
	if( client_data[id][FLAGS] & CDF_NO_CHOKE || id == target || target > MAXPLAYERS) return
	
	new dmg = get_pcvar_num( p_choke_dmg )
	new vec[3]
	FVecIVec( get_target_origin_f( target ), vec )
	
	message_begin( MSG_ONE, SVC_SCREENSHAKE, _, target )
	write_short( 999999 ) //amount
	write_short( 9999 ) //duration
	write_short( 999 ) //frequency
	message_end( )
	
	message_begin( MSG_ONE, SVC_SCREENFADE, _, target )
	write_short( 9999 ) //duration
	write_short( 100 ) //hold
	write_short( SF_FADE_MODULATE ) //flags
	write_byte( 200 ) //r
	write_byte( 0 ) //g
	write_byte( 0 ) //b
	write_byte( 200 ) //a
	message_end( )
	
	message_begin( MSG_ONE, WTF_DAMAGE, _, target )
	write_byte( 0 ) //damage armor
	write_byte( dmg ) //damage health
	write_long( DMG_CRUSH ) //damage type
	write_coord( vec[0] ) //origin[x]
	write_coord( vec[1] ) //origin[y]
	write_coord( vec[2] ) //origin[z]
	message_end( )
		
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BLOODSTREAM )
	write_coord( vec[0] ) //pos.x
	write_coord( vec[1] ) //pos.y
	write_coord( vec[2] + 15 ) //pos.z
	write_coord( random_num( 0, 255 ) ) //vec.x
	write_coord( random_num( 0, 255 ) ) //vec.y
	write_coord( random_num( 0, 255 ) ) //vec.z
	write_byte( 70 ) //col index
	write_byte( random_num( 50, 250 ) ) //speed
	message_end( )
	
	new health = pev( target, pev_health ) - dmg
	set_pev( target, pev_health, float( health ) )
	if( health < 1 ) dllfunc( DLLFunc_ClientKill, target )
	
	emit_sound( target, CHAN_BODY, "player/PL_PAIN2.WAV", VOL_NORM, ATTN_NORM, 0, PITCH_NORM )
	
	client_data[id][FLAGS] ^= CDF_NO_CHOKE
	set_task( get_pcvar_float( p_choke_time ), "clear_no_choke", TSK_CHKE + id )
}

public clear_no_choke( tskid )
{
	new id = tskid - TSK_CHKE
	client_data[id][FLAGS] ^= CDF_NO_CHOKE
}

//Grabs the client and teleports them to the admin
public force_grab(id, level, cid)
{
	if( !cmd_access( id, level, cid, 1 ) || !get_pcvar_num( p_enabled ) ) return PLUGIN_HANDLED

	new arg[33]
	read_argv( 1, arg, 32 )

	new targetid = cmd_target( id, arg, 1 )
	
	if( is_grabbed( targetid, id ) ) return PLUGIN_HANDLED
	if( !is_user_alive( targetid ) )
	{
		return PLUGIN_HANDLED
	}
	
	//Safe to tp target to aim spot?
	new Float:tmpvec[3], Float:orig[3], Float:torig[3], Float:trace_ret[3]
	new bool:safe = false, i
	
	get_view_pos( id, orig )
	tmpvec = vel_by_aim( id, get_pcvar_num( p_min_dist ) )
	
	for( new j = 1; j < 11 && !safe; j++ )
	{
		torig[0] = orig[0] + tmpvec[i] * j
		torig[1] = orig[1] + tmpvec[i] * j
		torig[2] = orig[2] + tmpvec[i] * j
		
		traceline( tmpvec, torig, id, trace_ret )
		
		if( get_distance_f( trace_ret, torig ) ) break
		
		engfunc( EngFunc_TraceHull, torig, torig, 0, HULL_HUMAN, 0, 0 )
		if ( !get_tr2( 0, TR_StartSolid ) && !get_tr2( 0, TR_AllSolid ) && get_tr2( 0, TR_InOpen ) )
			safe = true
	}
	
	//Still not safe? Then find another safe spot somewhere around the grabber
	pev( id, pev_origin, orig )
	new try[3]
	orig[2] += 2
	while( try[2] < 3 && !safe )
	{
		for( i = 0; i < 3; i++ )
			switch( try[i] )
			{
				case 0 : torig[i] = orig[i] + ( i == 2 ? 80 : 40 )
				case 1 : torig[i] = orig[i]
				case 2 : torig[i] = orig[i] - ( i == 2 ? 80 : 40 )
			}
		
		traceline( tmpvec, torig, id, trace_ret )
		
		engfunc( EngFunc_TraceHull, torig, torig, 0, HULL_HUMAN, 0, 0 )
		if ( !get_tr2( 0, TR_StartSolid ) && !get_tr2( 0, TR_AllSolid ) && get_tr2( 0, TR_InOpen )
				&& !get_distance_f( trace_ret, torig ) ) safe = true
		
		try[0]++
		if( try[0] == 3 )
		{
			try[0] = 0
			try[1]++
			if( try[1] == 3 )
			{
				try[1] = 0
				try[2]++
			}
		}
	}
	
	if( safe )
	{
		set_pev( targetid, pev_origin, torig )
		set_grabbed( id, targetid )
	}

	return PLUGIN_HANDLED
}

public is_grabbed( target, grabber )
{
	for( new i = 1; i <= MAXPLAYERS; i++ )
		if( client_data[i][GRABBED] == target )
		{
			unset_grabbed( grabber )
			return true
		}
	return false
}

public DeathMsg( )
	kill_grab( read_data( 2 ) )

public client_disconnect( id )
{
	kill_grab( id )
	speed_off[id] = false
	return PLUGIN_CONTINUE
}

public kill_grab( id )
{
	//If given client has grabbed, or has a grabber, unset it
	if( client_data[id][GRABBED] )
		unset_grabbed( id )
	else if( client_data[id][GRABBER] )
		unset_grabbed( client_data[id][GRABBER] )
}

stock traceline( const Float:vStart[3], const Float:vEnd[3], const pIgnore, Float:vHitPos[3] )
{
	engfunc( EngFunc_TraceLine, vStart, vEnd, 0, pIgnore, 0 )
	get_tr2( 0, TR_vecEndPos, vHitPos )
	return get_tr2( 0, TR_pHit )
}

stock get_view_pos( const id, Float:vViewPos[3] )
{
	new Float:vOfs[3]
	pev( id, pev_origin, vViewPos )
	pev( id, pev_view_ofs, vOfs )		
	
	vViewPos[0] += vOfs[0]
	vViewPos[1] += vOfs[1]
	vViewPos[2] += vOfs[2]
}

stock Float:vel_by_aim( id, speed = 1 )
{
	new Float:v1[3], Float:vBlah[3]
	pev( id, pev_v_angle, v1 )
	engfunc( EngFunc_AngleVectors, v1, v1, vBlah, vBlah )
	
	v1[0] *= speed
	v1[1] *= speed
	v1[2] *= speed
	
	return v1
}

stock fm_give_item(pPlayer, const szItem[])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, szItem));
	if(!pev_valid(iEntity)) return 0;
	new Float:vecOrigin[3];
	pev(pPlayer, pev_origin, vecOrigin);
	set_pev(iEntity, pev_origin, vecOrigin);
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, iEntity);
	dllfunc(DLLFunc_Touch, iEntity, pPlayer);
	if(pev(iEntity, pev_solid) != SOLID_NOT)
	{
		engfunc(EngFunc_RemoveEntity, iEntity);
		return -1;
	}
	return iEntity;
}

stock fm_strip_user_weapons(pPlayer, iType = 0)
{
	static iEntity, iszWeaponStrip = 0;
	if(iszWeaponStrip || (iszWeaponStrip = engfunc(EngFunc_AllocString, "player_weaponstrip"))) iEntity = engfunc(EngFunc_CreateNamedEntity, iszWeaponStrip);
	if(!pev_valid(iEntity)) return 0;
	if(iType && get_user_weapon(pPlayer) != CSW_KNIFE)
	{
		engclient_cmd(pPlayer, "weapon_knife");
		engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, 66, {0.0, 0.0, 0.0}, pPlayer);
		write_byte(1);
		write_byte(CSW_KNIFE);
		write_byte(0);
		message_end();
	}
	dllfunc(DLLFunc_Spawn, iEntity);
	dllfunc(DLLFunc_Use, iEntity, pPlayer);
	engfunc(EngFunc_RemoveEntity, iEntity);
	set_pdata_int(pPlayer, 116, 0, 5);
	return 1;
}

stock UTIL_WeaponAnimation(pPlayer, iAnimation)
{
	set_pev(pPlayer, pev_weaponanim, iAnimation);
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, pPlayer);
	write_byte(iAnimation);
	write_byte(0);
	message_end();
}

stock UTIL_SayText(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
    
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
    
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
