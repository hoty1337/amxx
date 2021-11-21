/* ----------------------------------------------------------------------------   

	Сделано специально для RAGASHOP.
	Еще больше плагинов тут - vk.com/ragashop
	Связь с автором - vk.com/felhalas
	
	Плагин: Наручники для JailBreak
	Описание: Сковывает руки арестанту что не позволяет ему использовать оружие.
	
   ---------------------------------------------------------------------------- */

new const PVA[][]					= { "[RAGASHOP] JailBreak Cuff", "0.0.2", "Ragamafona" };

#define JB_TAG::					jbm		// Префикс мода для разных сборок (jbe,jbm,jbs и тд)

const CUFF_DISTANCE					= 150;	// Дистанция для сковывания арестанта в наручи
const CUFF_MAX_COUNT				= 5;

new const MODEL_CUFF_V[] 			= "models/ragashop/v_cuff.mdl";
new const MODEL_CUFF_P[] 			= "models/ragashop/p_cuff.mdl";

/* ---------------------------------------------------------------------------- */

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

#define rs_is_user_chief 			JB_TAG::_is_user_chief
#define rs_get_user_team 			JB_TAG::_get_user_team

native rs_is_user_chief( pPlayer );
native rs_get_user_team( pPlayer );

/* ---------------------------------------------------------------------------- */

#define IsValidItem(%0)				(%0 > 0 && pev_valid(%0) == pdata_safe)
#define Menu_SetMenuName(%0) 		iLen = formatex(strMenu, charsmax(strMenu), %0)
#define Menu_AddMenuStr(%0) 		iLen += formatex(strMenu[iLen], charsmax(strMenu) - iLen, %0)

/* ---------------------------------------------------------------------------- */

new bool: g_bPlayerCuffed[ 33 ];
new g_iPlayersCuffed;

const pdata_safe = 2;
const m_pPlayer = 41;
const m_iId = 43;
const m_pActiveItem = 373;
const offset_linux_weapon = 4;
const offset_linux_player = 5;

/* ---------------------------------------------------------------------------- */

public plugin_init()	{
	
	register_plugin( PVA[ 0 ], PVA[ 1 ], PVA[ 2 ] );
	
	register_dictionary( "rs_jail_cuff.txt" );
	
	new const strWeaponName[][] = 
	{
		"weapon_knife",
		"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_mac10", "weapon_aug", 
		"weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
		"weapon_galil", "weapon_famas", "weapon_usp", "weapon_flashbang","weapon_glock18", "weapon_awp", 
		"weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", 
		"weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_p90"
	};

	for( new iCase = 0 ; iCase < sizeof( strWeaponName ) ; iCase++ ) 
		RegisterHam( Ham_Item_Deploy, strWeaponName[ iCase ], "CWeapon__Deploy_Post", .Post = true );
	
	RegisterHam( Ham_Killed, "player", "CPlayer__Killed_Post", .Post = true );
	register_event( "HLTV", "CEvent__RoundStart", "a", "1=0", "2=0" );
	
	register_clcmd( "say /cuff", "Open_MenuCuff" );
	register_menucmd( register_menuid( "OpenMenu_Cuff" ), (1<<0|1<<9), "CloseMenu_Cuff" ); 
}

public plugin_precache()	{
	
	precache_model( MODEL_CUFF_V );
	precache_model( MODEL_CUFF_P );
}

/* ---------------------------------------------------------------------------- */

public Open_MenuCuff( pPlayer )	{
	
	if( !is_user_alive( pPlayer ) )
		return PLUGIN_HANDLED;
	
	if( !rs_is_user_chief( pPlayer ) )
	{
		UTIL_SendChat( pPlayer, "%L", pPlayer, "RS_CHAT_ONLY_CHIEF" );
		return PLUGIN_HANDLED;
	}
	
	new strMenu[ 256 ], Menu_SetMenuName( "%L^n", pPlayer, "RS_MENU_TITLE" );
	
	if( g_iPlayersCuffed > 0 )
		Menu_AddMenuStr( "%L^n", pPlayer, "RS_MENU_CUFF_COUNT", g_iPlayersCuffed );
	
	Menu_AddMenuStr( "^n%L^n", pPlayer, "RS_MENU_CUFF_SET" );
	Menu_AddMenuStr( "%L^n^n", pPlayer, "RS_MENU_CUFF_SET_INFO" );
	
	Menu_AddMenuStr( "%L^n", pPlayer, "RS_MENU_EXIT" );
	
	return show_menu( pPlayer, (1<<0|1<<9), strMenu, -1, "OpenMenu_Cuff" );
}

public CloseMenu_Cuff( pPlayer, iKey )	{
	
	if( !is_user_alive( pPlayer ) )
		return PLUGIN_HANDLED;
	
	if( !rs_is_user_chief( pPlayer ) )
	{
		UTIL_SendChat( pPlayer, "%L", pPlayer, "RS_CHAT_ONLY_CHIEF" );
		return PLUGIN_HANDLED;
	}
	
	if( iKey == 9 )
		return PLUGIN_HANDLED;
	
	new iTarget; get_user_aiming( pPlayer, iTarget, _, CUFF_DISTANCE );
	
	if( !is_user_alive( iTarget ) || rs_get_user_team( iTarget ) != 1 )
		return Open_MenuCuff( pPlayer );
	
	if( g_bPlayerCuffed[ iTarget ] )
	{
		g_iPlayersCuffed--;
		g_bPlayerCuffed[ iTarget ] = false;
		
		new iItem; iItem = get_pdata_cbase( iTarget, m_pActiveItem, offset_linux_player );
		
		if( IsValidItem( iItem ) ) 
			ExecuteHamB( Ham_Item_Deploy, iItem );
	}
	else
	{
		if( g_iPlayersCuffed >= CUFF_MAX_COUNT )
		{
			UTIL_SendChat( pPlayer, "%L", pPlayer, "RS_CHAT_CUFF_LIMIT" );
			return Open_MenuCuff( pPlayer );
		}
		
		g_iPlayersCuffed++;
		g_bPlayerCuffed[ iTarget ] = true;
		
		new iItem; iItem = get_pdata_cbase( iTarget, m_pActiveItem, offset_linux_player );
		
		if( IsValidItem( iItem ) ) 
		{
			if( get_pdata_int( iItem, m_iId, offset_linux_weapon ) == CSW_KNIFE )
				ExecuteHamB( Ham_Item_Deploy, iItem );
			else
				engclient_cmd( iTarget, "weapon_knife" );
		}
	}
	
	new strName[ 2 ][ 32 ];
	get_user_name( pPlayer, strName[ 0 ], charsmax( strName[] ) );
	get_user_name( iTarget, strName[ 1 ], charsmax( strName[] ) );
	
	//
	//	LANG_PLAYER - был найден баг что игрокам выводилось сообщение не с выбранным ими языком.
	//
	//	UTIL_SendChat( 0, "%L", LANG_PLAYER, "RS_CHAT_CUFF_SET", strName[ 0 ], LANG_PLAYER, g_bPlayerCuffed[ iTarget ] ? "RS_CHAT_CUFF_ADD" : "RS_CHAT_CUFF_DEL", strName[ 1 ] );
	//
	
	new aPlayers[ 32 ], iPlayersCount, iPlayer;
	get_players( aPlayers, iPlayersCount, "ch" );
	
	for( --iPlayersCount ; iPlayersCount >= 0 ; iPlayersCount-- )
	{
		iPlayer = aPlayers[ iPlayersCount ];
		
		UTIL_SendChat( iPlayer, "%L", iPlayer, "RS_CHAT_CUFF_SET", strName[ 0 ], iPlayer, g_bPlayerCuffed[ iTarget ] ? "RS_CHAT_CUFF_ADD" : "RS_CHAT_CUFF_DEL", strName[ 1 ] );
	}
	
	return Open_MenuCuff( pPlayer );
}

public CWeapon__Deploy_Post( iItem )	{
	
	new pPlayer; pPlayer = get_pdata_cbase( iItem, m_pPlayer, offset_linux_weapon );
	
	if( g_bPlayerCuffed[ pPlayer ] )
	{
		if( get_pdata_int( iItem, m_iId, offset_linux_weapon ) != CSW_KNIFE )
			engclient_cmd( pPlayer, "weapon_knife" );
		else
		{
			set_pev( pPlayer, pev_viewmodel2, MODEL_CUFF_V );
			set_pev( pPlayer, pev_weaponmodel2, MODEL_CUFF_P );
		}
	}
}

public client_disconnect( pPlayer )
	CPlayer__Killed_Post( pPlayer );

public CPlayer__Killed_Post( pVictim )	{
	
	new iPlayers[32], iCount;
	get_players(iPlayers, iCount, "aceh", "TERRORIST");
	if(iCount == 1) 
	{
		if( g_bPlayerCuffed[ iPlayers[0] ] )
		{
			g_iPlayersCuffed--;
			g_bPlayerCuffed[ iPlayers[0] ] = false;
		}
	}
	if( g_bPlayerCuffed[ pVictim ] )
	{
		g_iPlayersCuffed--;
		g_bPlayerCuffed[ pVictim ] = false;
	}
}

public CEvent__RoundStart()		{
	
	g_iPlayersCuffed = 0;
	arrayset( g_bPlayerCuffed, false, sizeof( g_bPlayerCuffed ) );
}

stock UTIL_SendChat( pPlayer, const strText[], any:... ) {

	new aPlayers[ MAX_PLAYERS ], iPlayersCount; iPlayersCount = 1;
	new strMessage[ 188 ]; vformat( strMessage, charsmax( strMessage ), strText, 3 );
	
	static iMsg_SayText; 
	
	if( !iMsg_SayText ) 
		iMsg_SayText = get_user_msgid( "SayText" );
	
	replace_all( strMessage, charsmax( strMessage ), "!g", "^4" );
	replace_all( strMessage, charsmax( strMessage ), "!y", "^1" );
	replace_all( strMessage, charsmax( strMessage ), "!t", "^3" );
	
	if( pPlayer ) aPlayers[ 0 ] = pPlayer; else get_players( aPlayers, iPlayersCount, "ch");
	{
		for( --iPlayersCount ; iPlayersCount >= 0 ; iPlayersCount-- )
		{
			pPlayer = aPlayers[ iPlayersCount ];
			
			if( is_user_connected( pPlayer ) ) //lol
			{
				message_begin( MSG_ONE_UNRELIABLE, iMsg_SayText, _, pPlayer );
				write_byte( pPlayer );
				write_string( strMessage );
				message_end();
			}
		}
	}
}

/* ----------------------------------------------------------------------------   

	Сделано специально для RAGASHOP.
	Еще больше плагинов тут - vk.com/ragashop
	Связь с автором - vk.com/felhalas
	
	Плагин: Наручники для JailBreak
	Описание: Сковывает руки арестанту что не позволяет ему использовать оружие.
	
   ---------------------------------------------------------------------------- */