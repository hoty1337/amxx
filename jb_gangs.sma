/* Режим разработчик и логирование, отключите если вам это не нужно */
#define DEBUG_LOG

//достаточно вставить данный инклуд в плагинах чат менеджера
//										Плагин Chat Manager. Автор: Mistrick
/*
				public jb_gang_prefix(player, GangName[])
				{
					if(g_sPlayerPrefix[player][0])
						return;

					if(GangName[0])
					{
						formatex(g_sPlayerPrefix[player], charsmax(g_sPlayerPrefix[]), "^1[^4%s^1]", GangName);
						g_bCustomPrefix[player] = true;
					}
				}


//										Плагин Lite Translit. Автор: neygomon
				public jb_gang_prefix(id, GangName[])
				{
					if(g_szPrefix[id][0])
						return PLUGIN_HANDLED

					if(GangName[0] && GangName[0] != '0')
						return formatex(g_szPrefix[id], charsmax(g_szPrefix[]), "^1[^4%s^1]", GangName);

					return g_szPrefix[id][0] = 0;
				}
*/

/* Includes */
	
	#include < amxmodx >
	#include < amxmisc >
	#include < cstrike >
	#include < hamsandwich >
	#include < sqlx >
	#include < fun >
	#include < saytext >

/* Defines */

	#define ADMIN_CREATE	ADMIN_LEVEL_B
	#define TASK_PREFIX_LOAD	37568
	
	#define FormatMain(%0) iLen = formatex(szMenu, charsmax(szMenu), %0)
	#define FormatItem(%0) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, %0)

	const MAX_BUFFER_LENGTH =      2047;
	new g_sBuffer3[MAX_BUFFER_LENGTH + 1]
	
/* Можете личный шаблон поставить пройдитесь по поиску - Cmd_Top10 и найдете строку где можно менять*/

	#define STATSX_SHELL_DESIGN0_STYLE "<meta charset=UTF-8><style type=^"text/css^">table{color:#fff;}th{color:#e41032;}th,td{text-align:left;width:200px;}.p{text-align:right;width:45px;padding-right:15px;}</style>"
	#define STATSX_SHELL_DESIGN1_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#112233;font-family:Arial}th{background:#558866;color:#FFF;padding:10px 2px;text-align:left}td{padding:4px 3px}table{background:#EEEECC;font-size:12px;font-family:Arial}h2,h3{color:#FFF;font-family:Verdana}#c{background:#E2E2BC}img{height:10px;background:#09F;margin:0 3px}#r{height:10px;background:#B6423C}#clr{background:none;color:#FFF;font-size:20px}</style>"
	#define STATSX_SHELL_DESIGN2_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{font-family:Arial}th{background:#575757;color:#FFF;padding:5px;border-bottom:2px #BCE27F solid;text-align:left}td{padding:3px;border-bottom:1px #E7F0D0 solid}table{color:#3C9B4A;background:#FFF;font-size:5px}h2,h3{color:#333;font-family:Verdana}#c{background:#F0F7E2}img{height:20px;background:#62B054;margin:0 3px}#r{height:30px;background:#717171}#clr{background:none;color:#575757;font-size:20px}</style>"
	#define STATSX_SHELL_DESIGN3_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#E6E6E6;font-family:Verdana}th{background:#F5F5F5;color:#A70000;padding:6px;text-align:left}td{padding:2px 6px}table{color:#333;background:#E6E6E6;font-size:10px;font-family:Georgia;border:2px solid #D9D9D9}h2,h3{color:#333;}#c{background:#FFF}img{height:10px;background:#14CC00;margin:0 3px}#r{height:10px;background:#CC8A00}#clr{background:none;color:#A70000;font-size:20px;border:0}</style>"
	#define STATSX_SHELL_DESIGN4_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#E8EEF7;margin:2px;font-family:Tahoma}th{color:#0000CC;padding:3px}tr{text-align:left;background:#E8EEF7}td{padding:3px}table{background:#CCC;font-size:11px}h2,h3{font-family:Verdana}img{height:10px;background:#09F;margin:0 3px}#r{height:10px;background:#B6423C}#clr{background:none;color:#000;font-size:20px}</style>"
	#define STATSX_SHELL_DESIGN5_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#555;font-family:Arial}th{border-left:1px solid #ADADAD;border-top:1px solid #ADADAD}table{background:#3C3C3C;font-size:11px;color:#FFF;border-right:1px solid #ADADAD;border-bottom:1px solid #ADADAD;padding:3px}h2,h3{color:#FFF}#c{background:#FF9B00;color:#000}img{height:10px;background:#00E930;margin:0 3px}#r{height:10px;background:#B6423C}#clr{background:none;color:#FFF;font-size:20px;border:0}</style>"
	#define STATSX_SHELL_DESIGN6_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#FFF;font-family:Tahoma}th{background:#303B4A;color:#FFF}table{padding:6px 2px;background:#EFF1F3;font-size:12px;color:#222;border:1px solid #CCC}h2,h3{color:#222}#c{background:#E9EBEE}img{height:7px;background:#F8931F;margin:0 3px}#r{height:7px;background:#D2232A}#clr{background:none;color:#303B4A;font-size:20px;border:0}</style>"
	#define STATSX_SHELL_DESIGN7_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#FFF;font-family:Verdana}th{background:#2E2E2E;color:#FFF;text-align:left}table{padding:6px 2px;background:#FFF;font-size:11px;color:#333;border:1px solid #CCC}h2,h3{color:#333}#c{background:#F0F0F0}img{height:7px;background:#444;margin:0 3px}#r{height:7px;background:#999}#clr{background:none;color:#2E2E2E;font-size:20px;border:0}</style>"
	#define STATSX_SHELL_DESIGN8_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#242424;margin:20px;font-family:Tahoma}th{background:#2F3034;color:#BDB670;text-align:left} table{padding:4px;background:#4A4945;font-size:10px;color:#FFF}h2,h3{color:#D2D1CF}#c{background:#3B3C37}img{height:12px;background:#99CC00;margin:0 3px}#r{height:12px;background:#999900}#clr{background:none;color:#FFF;font-size:20px}</style>"
	#define STATSX_SHELL_DESIGN9_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#FFF;font-family:Tahoma}th{background:#056B9E;color:#FFF;padding:3px;text-align:left;border-top:4px solid #3986AC}td{padding:2px 6px}table{color:#006699;background:#FFF;font-size:12px;border:2px solid #006699}h2,h3{color:#F69F1C;}#c{background:#EFEFEF}img{height:5px;background:#1578D3;margin:0 3px}#r{height:5px;background:#F49F1E}#clr{background:none;color:#056B9E;font-size:20px;border:0}</style>"
	#define STATSX_SHELL_DESIGN10_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#4C5844;font-family:Tahoma}th{background:#1E1E1E;color:#C0C0C0;padding:2px;text-align:left;}td{padding:2px 15px}table{color:#AAC0AA;background:#424242;font-size:13px}h2,h3{color:#C2C2C2;font-family:Tahoma}#c{background:#323232}img{height:3px;background:#B4DA45;margin:0 3px}#r{height:3px;background:#6F9FC8}#clr{background:none;color:#FFF;font-size:20px}</style>"
	#define STATSX_SHELL_DESIGN11_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#F2F2F2;font-family:Arial}th{background:#175D8B;color:#FFF;padding:7px;text-align:left}td{padding:3px;border-bottom:1px #BFBDBD solid}table{color:#153B7C;background:#F4F4F4;font-size:11px;border:1px solid #BFBDBD}h2,h3{color:#153B7C}#c{background:#ECECEC}img{height:8px;background:#54D143;margin:0 3px}#r{height:8px;background:#C80B0F}#clr{background:none;color:#175D8B;font-size:20px;border:0}</style>"
	#define STATSX_SHELL_DESIGN12_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#283136;font-family:Arial}th{background:#323B40;color:#6ED5FF;padding:10px 2px;text-align:left}td{padding:4px 3px;border-bottom:1px solid #DCDCDC}table{background:#EDF1F2;font-size:10px;border:2px solid #505A62}h2,h3{color:#FFF}img{height:10px;background:#A7CC00;margin:0 3px}#r{height:10px;background:#CC3D00}#clr{background:none;color:#6ED5FF;font-size:20px;border:0}</style>"
	#define STATSX_SHELL_DESIGN13_STYLE "<meta charset=UTF-8><style type=^"text/css^">body{background:#220000;font-family:Tahoma}th{background:#3E0909;color:#FFF;padding:5px 2px;text-align:left;border-bottom:1px solid #DEDEDE}td{padding:2px 2px;}table{background:#FFF;font-size:11px;border:1px solid #791616}h2,h3{color:#FFF}#c{background:#F4F4F4;color:#7B0000}img{height:7px;background:#a00000;margin:0 3px}#r{height:7px;background:#181818}#clr{background:none;color:#CFCFCF;font-size:20px;border:0}</style>"

native jbm_set_user_money(id, iMoney, iFlash);
native jbm_get_user_money(id);


/* Constants */

	new const g_szVersion[ ] = "2.0.0";

	enum _:GangInfo
	{
		Trie:GangMembers,
		GangName[ 64 ],
		GangHP,
		GangStealing,
		GangGravity,
		GangDamage,
		GangStamina,
		GangWeaponDrop,
		GangKills,
		NumMembers,
		ComFundLimit
	};
		
	enum
	{
		VALUE_HP,
		VALUE_STEALING,
		VALUE_GRAVITY,
		VALUE_DAMAGE,
		VALUE_STAMINA,
		VALUE_WEAPONDROP,
		VALUE_KILLS
	}

	enum
	{
		STATUS_NONE,
		STATUS_MEMBER,
		STATUS_ADMIN,
		STATUS_LEADER
	};

	new const g_szGangValues[ ][ ] = 
	{
		"HP",
		"Stealing",
		"Gravity",
		"Damage",
		"Stamina",
		"WeaponDrop",
		"Kills",
		"ComFundLimit"
	};
	enum _:SQLVaultEntryEx
	{
		SQLVEx_Key1[64],
		SQLVEx_Key2[64],
		SQLVEx_Data[512],
		SQLVEx_TimeStamp
	};

	new const g_szPrefix[ ] = "^04[Gang System]^01";
	
	

/* Tries */

	new Trie:g_tGangNames;
	new Trie:g_tGangValues;

/* Vault */


/* Arrays */

	new Array:g_aGangs;

/* Pcvars */

	new g_iFwdPrefix;
	new g_pCreateCost;
	new g_pFee;

	new g_pHealthCost;
	new g_pStealingCost;
	new g_pGravityCost;
	new g_pDamageCost;
	new g_pStaminaCost;
	new g_pWeaponDropCost;
	new g_pComFundCost;

	new g_pHealthMax;
	new g_pStealingMax;
	new g_pGravityMax;
	new g_pDamageMax;
	new g_pStaminaMax;
	new g_pWeaponDropMax;
	new g_pComFundMax;

	new g_pHealthPerLevel;
	new g_pStealingPerLevel;
	new g_pGravityPerLevel;
	new g_pDamagePerLevel;
	new g_pStaminaPerLevel;
	new g_pWeaponDropPerLevel;

	new g_pPointsPerKill;
	new g_pHeadshotBonus;

	new g_pMaxMembers;
	new g_pAdminCreate;
	new g_pChangeGangName;
	new g_pPrefixGang;

/* Integers */

	new g_iGang[ 33 ];
	new g_iPoints[ 4096 ];
	
	enum _: eServerCvars
	{
		iDBHostname[64],
		iDBDateBase[64],
		iDBUserName[64],
		iDBPassword[64],
		iDBPrefix_Gang_Main[64],
		iDBPrefix_Gang_Points[64],
		iDBPrefix_Gang_Ex[64]
	};
	
	new g_eCacheCvars[eServerCvars];

	new Handle:g_hDBSaveOther;
	const QUERY_LENGTH =	1472	// размер переменной sql запроса
	new bool:g_iSql;

	enum _:EXT_DATA_STRUCT {
		EXT_DATA__SQL,
		EXT_DATA__USERID,
		EXT_DATA__INDEX
	}

	enum _:sql_que_type	// тип sql запроса
	{
		SQL_IGNORE,
		SQL_LOAD,
		SQL_MAINCONNECT,
		SQL_LOADGANG
	}
	
#include < jb_gangs_inc >

public plugin_init()
{
	register_plugin( "Jailbreak Gang System Remake", g_szVersion, "H3avY Ra1n | ReMake by DalgaPups" );
	
	
	g_aGangs 				= ArrayCreate( GangInfo );
	register_clcmd("amount", "ClCmd_MoneyTransfer");

	g_tGangValues 			= TrieCreate();
	g_tGangNames 			= TrieCreate();
	

	g_pFee					= register_cvar( "jb_gang_fee", 		"10" );

	g_pCreateCost			= register_cvar( "jb_gang_cost", 		"50" );
	g_pHealthCost			= register_cvar( "jb_health_cost", 		"1" );
	g_pStealingCost 		= register_cvar( "jb_stealing_cost", 	"1" );
	g_pGravityCost			= register_cvar( "jb_gravity_cost", 	"1" );
	g_pDamageCost			= register_cvar( "jb_damage_cost", 		"1" );
	g_pStaminaCost			= register_cvar( "jb_stamina_cost", 	"1" );
	g_pWeaponDropCost		= register_cvar( "jb_weapondrop_cost", 	"1" );
	g_pComFundCost			= register_cvar( "jb_comfund_cost", 	"1" );

	g_pHealthMax			= register_cvar( "jb_health_max", 		"10" );
	g_pStealingMax			= register_cvar( "jb_stealing_max", 	"10" );
	g_pGravityMax			= register_cvar( "jb_gravity_max", 		"10" ); // Max * Gravity Per Level must be LESS than 800
	g_pDamageMax			= register_cvar( "jb_damage_max", 		"10" );
	g_pStaminaMax			= register_cvar( "jb_stamina_max", 		"10" );
	g_pWeaponDropMax		= register_cvar( "jb_weapondrop_max", 	"10" );
	g_pComFundMax			= register_cvar( "jb_comfund_max", 		"10" );

	g_pHealthPerLevel		= register_cvar( "jb_health_per", 		"10" 	);
	g_pStealingPerLevel		= register_cvar("jb_stealing_per", "0.05")
	
	g_pGravityPerLevel		= register_cvar( "jb_gravity_per", 		"50" 	);
	g_pDamagePerLevel		= register_cvar( "jb_damage_per", 		"3" 	);
	g_pStaminaPerLevel		= register_cvar( "jb_stamina_per", 		"3" 	);
	g_pWeaponDropPerLevel 	= register_cvar( "jb_weapondrop_per", 	"1" 	);

	g_pPointsPerKill		= register_cvar( "jb_points_per_kill",	"3" );
	g_pHeadshotBonus		= register_cvar( "jb_headshot_bonus",	"2" );
	
	g_pMaxMembers			= register_cvar( "jb_max_members",		"10" );
	g_pAdminCreate			= register_cvar( "jb_admin_create", 	"0" ); // Admins can create gangs without points
	g_pChangeGangName		= register_cvar( "jb_change_gangname_cost", 	"0" ); // Admins can create gangs without points
	g_pPrefixGang			= register_cvar( "jb_gang_prefix_status", 	"1" ); // Admins can create gangs without points
	
	register_cvar("jb_gangs_database_hostname", 			"146.255.193.26");
	register_cvar("jb_gangs_database_username", 			"u926009sipp");
	register_cvar("jb_gangs_database_password", 			"jNurEsGcqXYlkife");
	register_cvar("jb_gangs_database_datebase", 			"db926009");
	register_cvar("jb_gangs_database_pre_gang_main",		"jb_gang_main");
	register_cvar("jb_gangs_database_pre_gang_player",		"jb_gang_player");
	register_cvar("jb_gangs_database_pre_gang_ex",			"jb_gang_ex");
	
	register_cvar( "jb_gang_version", g_szVersion, FCVAR_SPONLY | FCVAR_SERVER );
	
	register_menu( "Gang Menu", 1023, "GangMenu_Handler" );
	register_menu( "Skills Menu", 1023, "SkillsMenu_Handler" );
	
	for( new i = 0; i < sizeof g_szGangValues; i++ )
	{
		TrieSetCell( g_tGangValues, g_szGangValues[ i ], i );
	}

	RegisterHam( Ham_Spawn, "player", "Ham_PlayerSpawn_Post", 1 );
	RegisterHam( Ham_TakeDamage, "player", "Ham_TakeDamage_Pre", 0 );
	RegisterHam( Ham_TakeDamage, "player", "Ham_TakeDamage_Post", 1 );
	RegisterHam( Ham_Item_PreFrame, "player", "Ham_PlayerResetSpeedPost", 1);
	
	register_event( "DeathMsg", "Event_DeathMsg", "a" );
			
	register_clcmd( "say /gang", "Cmd_Gang" );
	register_clcmd( "gang_name", "Cmd_CreateGang" );
	register_clcmd( "change_gangname", "Cmd_ChangeNameGang" );
	register_menu( "Show_CommonFund", 1023, "Handle_CommonFund" );
	
	g_iFwdPrefix = CreateMultiForward("jb_gang_prefix", ET_CONTINUE, FP_CELL, FP_STRING) ;
	
#if defined DEBUG_LOG
	register_clcmd( "points", "Cmd_points" );
#endif

}

public Cmd_points(pId)
{
	g_iPoints[ g_iGang[pId] ] = 250;

}

public client_disconnected( id )
{
	
	new szAuthID[35];
	get_user_authid(id, szAuthID, charsmax(szAuthID));
	
	if(g_iSql)
	{
		new query[QUERY_LENGTH];
	
		formatex(query,charsmax(query), "UPDATE `%s` \
				SET `data` = '%d' , `timestamp` = %d , `permanent` = 0 WHERE `key` = '%s';",\
				g_eCacheCvars[iDBPrefix_Gang_Points], g_iPoints[ g_iGang[id] ], get_systime(), g_iGang[ id ]);
				
		SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);
	}
	g_iGang[ id ] = -1;
	
	if(task_exists(id + TASK_PREFIX_LOAD)) remove_task(id + TASK_PREFIX_LOAD);
}

public client_putinserver( id )
{
	g_iGang[ id ] = -1;
	
	if(g_iSql)
	{
		new szAuthID[ 35 ];
		get_user_authid( id, szAuthID, charsmax( szAuthID ) );
		
		new query[QUERY_LENGTH];

		formatex(query,charsmax(query),  "SELECT * FROM %s WHERE `key` = '%s'", g_eCacheCvars[iDBPrefix_Gang_Points], g_iGang[ id ]);
		
		new sData[EXT_DATA_STRUCT];
		
		sData[EXT_DATA__SQL] = SQL_LOAD;
		sData[EXT_DATA__INDEX] = id;
		sData[EXT_DATA__USERID] = get_user_userid(id);
		SQL_ThreadQuery(g_hDBSaveOther, "selectQueryHandler", query, sData, sizeof sData);
	}
}

public plugin_end()
{
	new aData[ GangInfo ];
	new query[QUERY_LENGTH];
	for( new i = 0; i < ArraySize( g_aGangs ); i++ )
	{
		ArrayGetArray( g_aGangs, i, aData );
		
		
		formatex(query,charsmax(query),"\
		UPDATE `%s` SET \
		\
		`HP` = '%d',\
		`Stealing` = '%d',\
		`Gravity` = '%d',\
		`Stamina` = '%d',\
		`WeaponDrop` = '%d',\
		`Damage` = '%d',\
		`Kills` = '%d'\
		`ComFundLimit` = '%d'\
		\
		WHERE `GangName` = '%s'", 
		g_eCacheCvars[iDBPrefix_Gang_Main],
		
		aData[ GangHP ],
		aData[ GangStealing ],
		aData[ GangGravity ],
		aData[ GangStamina ],
		aData[ GangWeaponDrop ],
		aData[ GangDamage ],
		aData[ GangKills ],
		aData[ ComFundLimit ],
		
		aData[ GangName ] );

		SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);	
	}
	
	
	//ArrayDestroy(g_aGangs);
	if(g_hDBSaveOther != Empty_Handle) SQL_FreeHandle(g_hDBSaveOther);
	DestroyForward(g_iFwdPrefix);

	
}

public Ham_PlayerSpawn_Post( id )
{
	if( !is_user_alive( id ) || cs_get_user_team( id ) != CS_TEAM_T )
		return HAM_IGNORED;
		
	if( g_iGang[ id ] == -1 )
	{
		return HAM_IGNORED;
	}
		
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
	
	new iHealth = 100 + aData[ GangHP ] * get_pcvar_num( g_pHealthPerLevel );
	set_user_health( id, iHealth );
	
	new iGravity = 800 - ( get_pcvar_num( g_pGravityPerLevel ) * aData[ GangGravity ] );
	set_user_gravity( id, float( iGravity ) / 800.0 );
		
	return HAM_IGNORED;
}

public Ham_TakeDamage_Pre( iVictim, iInflictor, iAttacker, Float:flDamage, iBits )
{
	if( !is_user_alive( iAttacker ) || cs_get_user_team( iAttacker ) != CS_TEAM_T )
		return HAM_IGNORED;
		
	if( g_iGang[ iAttacker ] == -1 )
		return HAM_IGNORED;
	
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ iAttacker ], aData );
	
	SetHamParamFloat( 4, flDamage + ( get_pcvar_num( g_pDamagePerLevel ) * ( aData[ GangDamage ] ) ) );
	
	return HAM_IGNORED;
}

public Ham_TakeDamage_Post( iVictim, iInflictor, iAttacker, Float:flDamage, iBits )
{
	if( !is_user_alive( iAttacker ) || g_iGang[ iAttacker ] == -1 || get_user_weapon( iAttacker ) != CSW_KNIFE || cs_get_user_team( iAttacker ) != CS_TEAM_T  )
	{
		return HAM_IGNORED;
	}
	
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ iAttacker ], aData );
	
	new iChance = aData[ GangWeaponDrop ] * get_pcvar_num( g_pWeaponDropPerLevel );
	
	if( iChance == 0 )
		return HAM_IGNORED;
	
	new bool:bDrop = ( random_num( 1, 100 ) <= iChance );
	
	if( bDrop )
		client_cmd( iVictim, "drop" );
	
	return HAM_IGNORED;
}

public Ham_PlayerResetSpeedPost( id )
{
	if( g_iGang[ id ] == -1 || !is_user_alive( id ) || cs_get_user_team( id ) != CS_TEAM_T )
	{
		return HAM_IGNORED;
	}
	
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
	
	if( aData[ GangStamina ] > 0 && get_user_maxspeed( id ) > 1.0 )
		set_user_maxspeed( id, 250.0 + ( aData[ GangStamina ] * get_pcvar_num( g_pStaminaPerLevel ) ) );
		
	return HAM_IGNORED;
}

public Event_DeathMsg()
{
	new iKiller = read_data( 1 );
	new iVictim = read_data( 2 );
	
	if( !is_user_alive( iKiller ) || cs_get_user_team( iVictim ) != CS_TEAM_CT || cs_get_user_team( iKiller ) != CS_TEAM_T )
		return PLUGIN_CONTINUE;
	
	new iTotal = get_pcvar_num( g_pPointsPerKill ) + ( bool:read_data( 3 ) ? get_pcvar_num( g_pHeadshotBonus ) : 0 );
	
	if( g_iGang[ iKiller ] > -1 )
	{
		new aData[ GangInfo ];
		ArrayGetArray( g_aGangs, g_iGang[ iKiller ], aData );
		aData[ GangKills ]++;
		ArraySetArray( g_aGangs, g_iGang[ iKiller ], aData );
		
		iTotal += iTotal * ( aData[ GangStealing ] * get_pcvar_float(g_pStealingPerLevel)  );
	}
	
	//g_iPoints[ iKiller ] += iTotal;
	
	return PLUGIN_CONTINUE;
}

public Cmd_Gang( id )
{
	
	static szMenu[ 512 ], iLen, aData[ GangInfo ], iKeys, iStatus;
	
	iKeys = MENU_KEY_0 | MENU_KEY_4;
	
	iStatus = getStatus( id, g_iGang[ id ] );
	
	if( g_iGang[ id ] > -1 )
	{
		ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
		FormatMain("\yМеню банды^n\wТекущая банда:\y %s^n", aData[ GangName ] );
		FormatItem("\yДенег в общаке: \w%i^n^n", g_iPoints[ g_iGang[id] ] );  // ИСПРАВИТЬ
		FormatItem("\r1. \dСоздать Банду [$%i]^n", get_pcvar_num( g_pCreateCost ) );
	}
	
	else
	{
		FormatMain("\yМеню банды^n\wТекущая банда:\r Нету^n" );
		FormatItem("\r1. \wСоздать Банду [$%i]^n", get_pcvar_num( g_pCreateCost ) );
		
		iKeys |= MENU_KEY_1;
	}
	
	
	if( iStatus > STATUS_MEMBER && g_iGang[ id ] > -1 && get_pcvar_num( g_pMaxMembers ) > aData[ NumMembers ] )
	{
		FormatItem("\r2. \wПригласить игрока^n" );
		iKeys |= MENU_KEY_2;
	}
	else
		FormatItem("\r2. \dПригласить игрока^n" );
	
	if( g_iGang[ id ] > -1 )
	{
		FormatItem("\r3. \wСкиллы^n" );
		iKeys |= MENU_KEY_3;
	}
	
	else
		FormatItem("\r3. \dСкиллы^n" );
		
	FormatItem("\r4. \wTop-10^n" );
	
	if( g_iGang[ id ] > -1 )
	{
		FormatItem("\r5. \wВыйти с банды^n" );
		iKeys |= MENU_KEY_5;
	}
	
	else
		FormatItem("\r5. \dВыйти с банды^n" );
	
	
	if( iStatus > STATUS_MEMBER )
	{
		FormatItem("\r6. \wПУ Банды^n" );
		iKeys |= MENU_KEY_6;
	}
	
	else
		FormatItem("\r6. \dПУ Банды^n" );
	
	if( g_iGang[ id ] > -1 )
	{
		FormatItem("\r7. \wОнлайн игроки банды^n" );
		iKeys |= MENU_KEY_7;
	}
		
	else
		FormatItem("\r7. \dОнлайн игроки банды^n" );
	
	if( g_iGang[ id ] > -1 )
	{
		FormatItem("\r8. \wОбщак^n" );
		iKeys |= MENU_KEY_8;
	}
		
	else
		FormatItem("\r8. \dОбщак^n" ); 
	FormatItem("^n\r0. \wВыход" );
	
	show_menu( id, iKeys, szMenu, -1, "Gang Menu" );
	
	return PLUGIN_CONTINUE;
}

public GangMenu_Handler( id, iKey )
{
	switch( ( iKey + 1 ) % 10 )
	{
		case 0: return PLUGIN_HANDLED;
		
		case 1: 
		{
			if( get_pcvar_num( g_pAdminCreate ) && get_user_flags( id ) & ADMIN_CREATE )
			{
				client_cmd( id, "messagemode gang_name" );
			}
			
			else if( jbm_get_user_money(id) < get_pcvar_num( g_pCreateCost ) )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для создание банды!", g_szPrefix );
				return PLUGIN_HANDLED;
			}
			
			else
				client_cmd( id, "messagemode gang_name" );
		}
		
		case 2:
		{
			ShowInviteMenu( id );
		}
		
		case 3:
		{
			ShowSkillsMenu( id );
		}
		
		case 4:
		{
			Cmd_Top10( id );
		}
		
		case 5:
		{
			ShowLeaveConfirmMenu( id );
		}
		
		case 6:
		{
			ShowLeaderMenu( id );
		}
		
		case 7:
		{
			ShowMembersMenu( id );
		}
		case 8:
		{
			Show_CommonFund(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public Show_CommonFund(id)
{
	if(g_iGang[id] < 0)
	{
		return Cmd_Gang(id);
	}
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\wМеню общака^n\dВсего в общаке: $%d/$%d^n^n", g_iPoints[ g_iGang[id] ], aData[ComFundLimit] * 100000);
	new pFee = get_pcvar_num(g_pFee);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1] \wПоложить в общак \r[%d проц. комиссия]^n", pFee);
	iKeys |= (1<<0);

	if(getStatus( id, g_iGang[ id ] ) >= STATUS_ADMIN)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2] \wВзять деньги с общака \r[%d проц. комиссия]^n", pFee);
		iKeys |= (1<<1);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3] \wПрокачать банду^n");
		iKeys |= (1<<2);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2] \dВзять деньги с общака \r[Админ]^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3] \dПрокачать банду \r[Админ]^n");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0] \wВыход^n");
	// ArraySetArray( g_aGangs, g_iGang[ id ], aData );
	return show_menu(id, iKeys, szMenu, -1, "Show_CommonFund");
}

public Handle_CommonFund(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			client_cmd(id, "messagemode ^"amount 1^"");
		}
		case 1:
		{
			client_cmd(id, "messagemode ^"amount 0^"");
		}
		case 2:
		{
			ShowSkillsMenu(id);
		}
		case 9:
		{
			Cmd_Gang(id);
		}
	}
	return PLUGIN_HANDLED;
}

public ClCmd_MoneyTransfer(id, isSend, iMoney)
{
	if(g_iGang[id] < 0)
	{
		return Show_CommonFund(id);
	}
	new szArg1[3], szArg2[11];
	read_argv(1, szArg1, charsmax(szArg1));
	read_argv(2, szArg2, charsmax(szArg2));
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
	if(!is_str_num(szArg1) || !is_str_num(szArg2))
	{
		UTIL_SayText(id, "!g[JBM] !yНеверная сумма.");
		return PLUGIN_HANDLED;
	}
	isSend = str_to_num(szArg1);
	iMoney = str_to_num(szArg2);
	new Float:pFee = 1 - get_pcvar_num(g_pFee) / 100.0;
	new startMoney = iMoney;
	iMoney = floatround(iMoney * pFee, floatround_ceil);
	new iPlayerMoney = jbm_get_user_money(id);
	if(isSend)
	{
		if (iPlayerMoney < iMoney) UTIL_SayText(id, "!g[JBM] !yНедостаточно средств.");
		else if (iMoney <= 0 || aData[ComFundLimit] * 100000 < g_iPoints[g_iGang[id]] + iMoney) UTIL_SayText(id, "!g[JBM] !yНеверная сумма.");
		else
		{
			jbm_set_user_money(id, iPlayerMoney - startMoney, 1);
			g_iPoints[ g_iGang[id] ] += iMoney;
			// aData[GangMoney] += iMoney;
		}
	}
	else
	{
		if (g_iPoints[ g_iGang[id] ] < iMoney) UTIL_SayText(id, "!g[JBM] !yНедостаточно средств.");
		else if (iMoney <= 0) UTIL_SayText(id, "!g[JBM] !yНеверная сумма.");
		else
		{
			jbm_set_user_money(id, iPlayerMoney + iMoney, 1);
			g_iPoints[ g_iGang[id] ] -= iMoney;
			// aData[GangMoney] -= startMoney;
		}
	}
	return Show_CommonFund(id);
}

public Cmd_CreateGang( id )
{
	new bool:bAdmin = false;
	
	if( get_pcvar_num( g_pAdminCreate ) && get_user_flags( id ) & ADMIN_CREATE )
	{
		bAdmin = true;
	}
	
	else if( jbm_get_user_money(id) < get_pcvar_num( g_pCreateCost ) )
	{
		client_print_color( id, 0, "%s У вас недостаточно денег для создание банды.", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	else if( g_iGang[ id ] > -1 )
	{
		client_print_color( id, 0, "%s Вы не сможете создать еще одну банду!", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	new szArgs[ 60 ];
	read_args( szArgs, charsmax( szArgs ) );
	
	remove_quotes( szArgs );
	
	if( TrieKeyExists( g_tGangNames, szArgs ) )
	{
		client_print_color( id, 0, "%s Данное название банды уже существует.", g_szPrefix );
		Cmd_Gang( id );
		return PLUGIN_HANDLED;
	}
	
	new aData[ GangInfo ];
	
	aData[ GangName ] 		= szArgs;
	aData[ GangHP ] 		= 0;
	aData[ GangStealing ] 	= 0;
	aData[ GangGravity ] 	= 0;
	aData[ GangStamina ] 	= 0;
	aData[ GangWeaponDrop ] = 0;
	aData[ GangDamage ] 	= 0;
	aData[ NumMembers ] 	= 0;
	aData[ ComFundLimit ]	= 1;
	aData[ GangMembers ] 	= _:TrieCreate();
	
	ArrayPushArray( g_aGangs, aData );
	
	if( !bAdmin )
		jbm_set_user_money(id, jbm_get_user_money(id) - get_pcvar_num( g_pCreateCost ), 1);	// g_iPoints[ id ] -= get_pcvar_num( g_pCreateCost );
	
	set_user_gang( id, ArraySize( g_aGangs ) - 1, STATUS_LEADER );
	
	
	new query[QUERY_LENGTH];
	formatex(query,charsmax(query), 
		"INSERT INTO %s \
		(`GangName`, `HP`, `Stealing`, `Gravity`, `Stamina`, `WeaponDrop`, `Damage`, `Kills`, `ComFundLimit`) \
		VALUES ('%s', '0', '0', '0', '0', '0', '0', '0', '1')",
		g_eCacheCvars[iDBPrefix_Gang_Main], szArgs);
	
	SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);
	
	client_print_color( id, 0, "%s Вы успешно создали банду: '^03%s^01'.", g_szPrefix, szArgs );
	
	return PLUGIN_HANDLED;
}

public Cmd_ChangeNameGang( id )
{
	
	new szArgs[ 60 ];
	read_args( szArgs, charsmax( szArgs ) );
	
	remove_quotes( szArgs );
	
	if( TrieKeyExists( g_tGangNames, szArgs ) )
	{
		client_print_color( id, 0, "%s Данное название банды уже существует.", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	new iStatus = getStatus( id, g_iGang[ id ] );
	
	if( iStatus != STATUS_LEADER )
	{
		client_print_color( id, 0, "%s Вы не лидер для выполнение этого функции.", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pChangeGangName );
			
	if( iRemaining < 0 )
	{
		client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	new query[QUERY_LENGTH];
	
	new sData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ id ], sData );
	

	formatex(query,charsmax(query), "UPDATE `%s` SET `GangName` = '%s' WHERE `GangName` = '%s'", g_eCacheCvars[iDBPrefix_Gang_Main], szArgs, sData[ GangName ]);
	SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);
	
	formatex(query,charsmax(query), "UPDATE `%s` SET `key2` = '%s' WHERE `key2` = '%s'", g_eCacheCvars[iDBPrefix_Gang_Ex], szArgs, sData[ GangName ]);
	SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);
	
	
	
	new aData[ GangInfo ];
	for( new i = 0; i < ArraySize( g_aGangs ); i++ )
	{
		ArrayGetArray( g_aGangs, i, aData );
		
		if(equal(aData[GangName], sData[GangName]))
		{
			aData[ GangName ] 		= szArgs;
			
			ArraySetArray( g_aGangs, i, aData );
		}
	}
	
	client_print_color( id, 0, "%s Вы успешно поменяли название банды.", g_szPrefix );
	return PLUGIN_HANDLED;
}

public ShowInviteMenu( id )
{	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	new szInfo[ 6 ], hMenu;
	hMenu = menu_create( "Кого пригласить?:", "InviteMenu_Handler" );
	new szName[ 32 ];
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		
		if( iPlayer == id || g_iGang[ iPlayer ] == g_iGang[ id ] || cs_get_user_team( iPlayer ) != CS_TEAM_T )
			continue;
			
		get_user_name( iPlayer, szName, charsmax( szName ) );
		
		num_to_str( iPlayer, szInfo, charsmax( szInfo ) );
		
		menu_additem( hMenu, szName, szInfo );
	}
		
	menu_display( id, hMenu, 0 );
}

public InviteMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		Cmd_Gang( id );
		return PLUGIN_HANDLED;
	}
	
	new szData[ 6 ], iAccess, hCallback, szName[ 32 ];
	menu_item_getinfo( hMenu, iItem, iAccess, szData, 5, szName, 31, hCallback );
	
	new iPlayer = str_to_num( szData );

	if( !is_user_connected( iPlayer ) )
		return PLUGIN_HANDLED;
		
	ShowInviteConfirmMenu( id, iPlayer );

	client_print_color( id, 0, "%s Вы успешно отправили запрос %s присоединиться к вашей банде.", g_szPrefix, szName );
	
	Cmd_Gang( id );
	return PLUGIN_HANDLED;
}

public ShowInviteConfirmMenu( id, iPlayer )
{
	new szName[ 32 ];
	get_user_name( id, szName, charsmax( szName ) );
	
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
	
	new szMenuTitle[ 128 ];
	formatex( szMenuTitle, charsmax( szMenuTitle ), "%s приглашает вас в банду %s", szName, aData[ GangName ] );
	new hMenu = menu_create( szMenuTitle, "InviteConfirmMenu_Handler" );
	
	new szInfo[ 6 ];
	num_to_str( g_iGang[ id ], szInfo, 5 );
	
	menu_additem( hMenu, "Принять приглашение", szInfo );
	menu_additem( hMenu, "Отклонить приглашение", "-1" );
	
	menu_display( iPlayer, hMenu, 0 );	
}

public InviteConfirmMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
		return PLUGIN_HANDLED;
	
	new szData[ 6 ], iAccess, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess, szData, 5, _, _, hCallback );
	
	new iGang = str_to_num( szData );
	
	if( iGang == -1 )
		return PLUGIN_HANDLED;
	
	if( getStatus( id, g_iGang[ id ] ) == STATUS_LEADER )
	{
		client_print_color( id, 0, "%s Вы не сможете выйти с банды, т.к. вы лидер данной банды.", g_szPrefix );
		return PLUGIN_HANDLED;
	}
	
	set_user_gang( id, iGang );
	
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, iGang, aData );
	
	client_print_color( id, 0, "%s Вы успешно присоединились к банде ^03%s^01.", g_szPrefix, aData[ GangName ] );
	
	return PLUGIN_HANDLED;
}
	

public ShowSkillsMenu( id )
{	
	static szMenu[ 512 ], iLen, iKeys, aData[ GangInfo ];
	
	if( !iKeys )
	{
		iKeys = MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_0;
	}
	
	ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
	
	
	FormatMain("\yСкилл Прокачка^n^n" );
	FormatItem("\r1. \wЗдоровье [\rCost: \y$%i\w] \y[Level:%i/%i]^n", get_pcvar_num( g_pHealthCost ), aData[ GangHP ], get_pcvar_num( g_pHealthMax ) );
	FormatItem("\r2. \wКража денег [\rCost: \y$%i\w] \y[Level:%i/%i]^n", get_pcvar_num( g_pStealingCost ), aData[ GangStealing ], get_pcvar_num( g_pStealingMax ) );
	FormatItem("\r3. \wГравитация [\rCost: \y$%i\w] \y[Level:%i/%i]^n", get_pcvar_num( g_pGravityCost ), aData[ GangGravity ], get_pcvar_num( g_pGravityMax ) );
	FormatItem("\r4. \wПрибавка урона [\rCost: \y$%i\w] \y[Level:%i/%i]^n", get_pcvar_num( g_pDamageCost ), aData[ GangDamage ], get_pcvar_num( g_pDamageMax ) );
	FormatItem("\r5. \wДроп оружие Охраны [\rCost: \y$%i\w] \y[Level:%i/%i]^n", get_pcvar_num( g_pWeaponDropCost ), aData[ GangWeaponDrop ], get_pcvar_num( g_pWeaponDropMax ) );
	FormatItem("\r6. \wСкорость [\rCost: \y$%i\w] \y[Level:%i/%i]^n", get_pcvar_num( g_pStaminaCost ), aData[ GangStamina ], get_pcvar_num( g_pStaminaMax ) );
	FormatItem("\r7. \wВместимость общака [\rCost: \y$%i\w] \y[Level:%i/%i]^n", get_pcvar_num( g_pComFundCost ), aData[ ComFundLimit ], get_pcvar_num( g_pComFundMax ) ); // ИСПРАВИТь
	
	FormatItem("^n\r0. \wВыход" );
	
	show_menu( id, iKeys, szMenu, -1, "Skills Menu" );
}

public SkillsMenu_Handler( id, iKey )
{
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
	
	switch( ( iKey + 1 ) % 10 )
	{
		case 0: 
		{
			Cmd_Gang( id );
			return PLUGIN_HANDLED;
		}
		
		case 1:
		{
			if( aData[ GangHP ] == get_pcvar_num( g_pHealthMax ) )
			{
				client_print_color( id, 0, "%s Ваша банда уже на максимальном уровне для этого навыка.", g_szPrefix  );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pHealthCost );
			
			if( iRemaining < 0 )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			aData[ GangHP ]++;
			
			g_iPoints[ g_iGang[id] ] = iRemaining;
		}
		
		case 2:
		{
			if( aData[ GangStealing ] == get_pcvar_num( g_pStealingMax ) )
			{
				client_print_color( id, 0, "%s Ваша банда уже на максимальном уровне для этого навыка.", g_szPrefix  );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pStealingCost );
			
			if( iRemaining < 0 )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			aData[ GangStealing ]++;
			
			g_iPoints[ g_iGang[id] ] = iRemaining;
		}
		
		case 3:
		{
			if( aData[ GangGravity ] == get_pcvar_num( g_pGravityMax ) )
			{
				client_print_color( id, 0, "%s Ваша банда уже на максимальном уровне для этого навыка.", g_szPrefix  );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pGravityCost );
			
			if( iRemaining < 0 )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			aData[ GangGravity ]++;
			
			g_iPoints[ g_iGang[id] ] = iRemaining;
		}
		
		case 4:
		{
			if( aData[ GangDamage ] == get_pcvar_num( g_pDamageMax ) )
			{
				client_print_color( id, 0, "%s Ваша банда уже на максимальном уровне для этого навыка.", g_szPrefix  );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pDamageCost );
			
			if( iRemaining < 0 )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			aData[ GangDamage ]++;
			
			g_iPoints[ g_iGang[id] ] = iRemaining;
		}
		
		case 5:
		{
			if( aData[ GangWeaponDrop ] == get_pcvar_num( g_pWeaponDropMax ) )
			{
				client_print_color( id, 0, "%s Ваша банда уже на максимальном уровне для этого навыка.", g_szPrefix  );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pWeaponDropCost );
			
			if( iRemaining < 0 )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			aData[ GangWeaponDrop ]++;
			
			g_iPoints[ g_iGang[id] ] = iRemaining;
		}
		
		case 6:
		{
			if( aData[ GangStamina ] == get_pcvar_num( g_pStaminaMax ) )
			{
				client_print_color( id, 0, "%s Ваша банда уже на максимальном уровне для этого навыка.", g_szPrefix  );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pStaminaCost );
			
			if( iRemaining < 0 )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			aData[ GangStamina ]++;
			
			g_iPoints[ g_iGang[id] ] = iRemaining;
		}

		case 7:
		{
			if( aData[ ComFundLimit ] == get_pcvar_num( g_pComFundMax ) )
			{
				client_print_color( id, 0, "%s Ваша банда уже на максимальном уровне для этого навыка.", g_szPrefix  );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = g_iPoints[ g_iGang[id] ] - get_pcvar_num( g_pComFundCost );
			
			if( iRemaining < 0 )
			{
				client_print_color( id, 0, "%s У вас недостаточно денег для этого.", g_szPrefix );
				ShowSkillsMenu( id );
				return PLUGIN_HANDLED;
			}
			
			aData[ ComFundLimit ]++;
			
			g_iPoints[ g_iGang[id] ] = iRemaining;
		}
	}
	
	ArraySetArray( g_aGangs, g_iGang[ id ], aData );
	
	new iPlayers[ 32 ], iNum, iPlayer;
	new szName[ 32 ];
	get_user_name(id, szName, charsmax(szName));
	
	get_players( iPlayers, iNum );
	
	for( new i = 0; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( iPlayer == id || g_iGang[ iPlayer ] != g_iGang[ id ] )
			continue;
			
		client_print_color( iPlayer, 0, "%s ^03%s ^01только что улучшил один из навыков вашей банды.", g_szPrefix, szName );
	}
	
	client_print_color( id, 0, "%s Вы успешно обновили свою банду.", g_szPrefix );
	
	ShowSkillsMenu( id );
	
	return PLUGIN_HANDLED;
}
		
	
public Cmd_Top10( id )
{
	new iSize = ArraySize( g_aGangs );
	
	new iOrder[ 100 ][ 2 ];
	
	new aData[ GangInfo ];
	
	for( new i = 0; i < iSize; i++ )
	{
		ArrayGetArray( g_aGangs, i, aData );
		
		iOrder[ i ][ 0 ] = i;
		iOrder[ i ][ 1 ] = aData[ GangKills ];
	}
	
	SortCustom2D( iOrder, iSize, "Top10_Sort" );
	
	new iLen;
	iLen = format( g_sBuffer3[iLen], MAX_BUFFER_LENGTH, STATSX_SHELL_DESIGN9_STYLE ) // ТУТ МЕНЯЕМ ШАБЛОН НА СВОЙ
	iLen += format( g_sBuffer3[iLen],MAX_BUFFER_LENGTH - iLen, "<body bgcolor=#000000><table border=1 cellspacing=0 cellpadding=3px><tr><th class=p>#<td class=p><th>Банда<th>Киллы<th>Здв<th>Кража<th>Грв<th>Скр<th>Дроп<th>Урн" )   

	for( new i = 0; i < min( 10, iSize ); i++ )
	{
		ArrayGetArray( g_aGangs, iOrder[ i ][ 0 ], aData );
		
		iLen += format( g_sBuffer3[iLen], MAX_BUFFER_LENGTH - iLen, "<tr><td class=p>%d<td class=p><td>%s<td>%d<td>%d<td>%d<td>%d<td>%d<td>%d<td>%d", i + 1, aData[ GangName ], 
		aData[ GangKills ], aData[ GangHP ], aData[ GangStealing ], aData[ GangGravity ], aData[ GangStamina], aData[ GangWeaponDrop ], aData[ GangDamage ])
	}
	show_motd( id, g_sBuffer3, "Gang Top 10" );
}

public Top10_Sort( const iElement1[ ], const iElement2[ ], const iArray[ ], szData[], iSize ) 
{
	if( iElement1[ 1 ] > iElement2[ 1 ] )
		return -1;
	
	else if( iElement1[ 1 ] < iElement2[ 1 ] )
		return 1;
	
	return 0;
}

public ShowLeaveConfirmMenu( id )
{
	new hMenu = menu_create( "Вы уверены, что хотите покинуть?", "LeaveConfirmMenu_Handler" );
	menu_additem( hMenu, "Да", "0" );
	menu_additem( hMenu, "Нет", "1" );
	
	menu_display( id, hMenu, 0 );
}

public LeaveConfirmMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
		return PLUGIN_HANDLED;
	
	new szData[ 6 ], iAccess, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess, szData, 5, _, _, hCallback );
	
	switch( str_to_num( szData ) )
	{
		case 0: 
		{
			if( getStatus( id, g_iGang[ id ] ) == STATUS_LEADER )
			{
				client_print_color( id, 0, "%s Вы должны передать лидерство, прежде чем покинуть эту банду.", g_szPrefix );
				Cmd_Gang( id );
				
				return PLUGIN_HANDLED;
			}
			
			client_print_color( id, 0, "%s Вы успешно покинули свою банду.", g_szPrefix );
			set_user_gang( id, -1 );
			Cmd_Gang( id );
		}
		
		case 1: Cmd_Gang( id );
	}
	
	return PLUGIN_HANDLED;
}

public ShowLeaderMenu( id )
{
	new hMenu = menu_create( "Gang Leader Menu", "LeaderMenu_Handler" );
	
	new iStatus = getStatus( id, g_iGang[ id ] );
	
	if( iStatus == STATUS_LEADER )
	{
		new szMenu[512];
		formatex( szMenu, charsmax( szMenu ), "Поменять название банды - \r$%d", get_pcvar_num( g_pChangeGangName ));
		
		menu_additem( hMenu, "Расформировать банду", "0" );
		menu_additem( hMenu, "Передать лидерство", "1" );
		menu_additem( hMenu, "Выдать админку", "2" );
		menu_additem( hMenu, "Забрать админку", "3" );
		menu_additem( hMenu, szMenu, "4" );
		menu_additem( hMenu, "Кикнуть игрока с банды", "5" );
	}
	
	menu_display( id, hMenu, 0 );
}

public LeaderMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		Cmd_Gang( id );
		return PLUGIN_HANDLED;
	}
	
	new iAccess, hCallback, szData[ 6 ];
	menu_item_getinfo( hMenu, iItem, iAccess, szData, 5, _, _, hCallback );
	
	switch( str_to_num( szData ) )
	{
		case 0:
		{
			ShowDisbandConfirmMenu( id );
		}
		
		case 1:
		{
			ShowTransferMenu( id );
		}
		
		case 2:
		{
			ShowAddAdminMenu( id );
		}
		
		case 3:
		{
			ShowRemoveAdminMenu( id );
		}
		case 4:
		{
			client_print_color( id, 0, "%s Стоимость смены названия: - ^03$%d", g_szPrefix , get_pcvar_num( g_pChangeGangName ));
			client_cmd( id, "messagemode change_gangname" );
		}
		
		case 5:
		{
			ShowKickMenu( id );
		}
		
		
		
		
		
	}
	
	return PLUGIN_HANDLED;
}

public ShowDisbandConfirmMenu( id )
{
	new hMenu = menu_create( "Вы уверены, что хотите распустить банду?", "DisbandConfirmMenu_Handler" );
	menu_additem( hMenu, "Да, Распустить банду", "0" );
	menu_additem( hMenu, "Нет, Не распускать банду", "1" );
	
	menu_display( id, hMenu, 0 );
}

public DisbandConfirmMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
		return PLUGIN_HANDLED;
	
	new szData[ 6 ], iAccess, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess, szData, 5, _, _, hCallback );
	
	switch( str_to_num( szData ) )
	{
		case 0: 
		{
			
			client_print_color( id, 0, "%s Вы успешно расформировали свою банду.", g_szPrefix );
			
			new iPlayers[ 32 ], iNum;
			
			get_players( iPlayers, iNum );
			
			new iPlayer;
			
			for( new i = 0; i < iNum; i++ )
			{
				iPlayer = iPlayers[ i ];
				
				if( iPlayer == id )
					continue;
				
				if( g_iGang[ id ] != g_iGang[ iPlayer ] )
					continue;

				client_print_color( iPlayer, 0, "%s Ваша банда была распущена лидером.", g_szPrefix );
				set_user_gang( iPlayer, -1 );
			}
			
			new iGang = g_iGang[ id ];
			
			set_user_gang( id, -1 );
			
			ArrayDeleteItem( g_aGangs, iGang );

			Cmd_Gang( id );
		}
		
		case 1: Cmd_Gang( id );
	}
	
	return PLUGIN_HANDLED;
}

public ShowTransferMenu( id )
{
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum, "e", "TERRORIST" );
	
	new hMenu = menu_create( "Передача лидерства:", "TransferMenu_Handler" );
	new szName[ 32 ], szData[ 6 ];
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ iPlayer ] != g_iGang[ id ] || id == iPlayer )
			continue;
			
		get_user_name( iPlayer, szName, charsmax( szName ) );
		num_to_str( iPlayer, szData, charsmax( szData ) );
		
		menu_additem( hMenu, szName, szData );
	}
	
	menu_display( id, hMenu, 0 );
}

public TransferMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		ShowLeaderMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iAccess, hCallback, szData[ 6 ], szName[ 32 ];
	
	menu_item_getinfo( hMenu, iItem, iAccess, szData, 5, szName, charsmax( szName ), hCallback );
	
	new iPlayer = str_to_num( szData );
	
	if( !is_user_connected( iPlayer ) )
	{
		client_print_color( id, 0, "%s Этого игрока больше нет в сети", g_szPrefix );
		ShowTransferMenu( id );
		return PLUGIN_HANDLED;
	}
	
	set_user_gang( iPlayer, g_iGang[ id ], STATUS_LEADER );
	set_user_gang( id, g_iGang[ id ], STATUS_ADMIN );
	
	Cmd_Gang( id );
	
	new iPlayers[ 32 ], iNum, iTemp;
	get_players( iPlayers, iNum );

	for( new i = 0; i < iNum; i++ )
	{
		iTemp = iPlayers[ i ];
		
		if( iTemp == iPlayer )
		{
			client_print_color( iTemp, 0, "%s Вы новый лидер своей банды.", g_szPrefix );
			continue;
		}
		
		else if( g_iGang[ iTemp ] != g_iGang[ id ] )
			continue;
		
		client_print_color( iTemp, 0, "%s ^03%s^01 новый лидер вашей банды.", g_szPrefix, szName );
	}
	
	return PLUGIN_HANDLED;
}


public ShowKickMenu( id )
{
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	new hMenu = menu_create( "Кикнуть с банды:", "KickMenu_Handler" );
	new szName[ 32 ], szData[ 6 ];
	
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ iPlayer ] != g_iGang[ id ] || id == iPlayer )
			continue;
			
		get_user_name( iPlayer, szName, charsmax( szName ) );
		num_to_str( iPlayer, szData, charsmax( szData ) );
		
		menu_additem( hMenu, szName, szData );
	}
	
	menu_display( id, hMenu, 0 );
}

public KickMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		ShowLeaderMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iAccess, hCallback, szData[ 6 ], szName[ 32 ];
	
	menu_item_getinfo( hMenu, iItem, iAccess, szData, 5, szName, charsmax( szName ), hCallback );
	
	new iPlayer = str_to_num( szData );
	
	if( !is_user_connected( iPlayer ) )
	{
		client_print_color( id, 0, "%s Этого игрока больше нет в сети", g_szPrefix );
		ShowTransferMenu( id );
		return PLUGIN_HANDLED;
	}
	
	set_user_gang( iPlayer, -1 );
	
	Cmd_Gang( id );
	
	new iPlayers[ 32 ], iNum, iTemp;
	get_players( iPlayers, iNum );
	
	for( new i = 0; i < iNum; i++ )
	{
		iTemp = iPlayers[ i ];
		
		if( iTemp == iPlayer || g_iGang[ iTemp ] != g_iGang[ id ] )
			continue;
		
		client_print_color( iTemp, 0, "%s ^03%s^01 был выгнан из банды.", g_szPrefix, szName );
	}
	
	client_print_color( iPlayer, 0, "%s Вас выгнали из вашей банды.", g_szPrefix, szName );
	
	return PLUGIN_HANDLED;
}

public ChangeName_Handler( id )
{
	if( g_iGang[ id ] == -1 || getStatus( id, g_iGang[ id ] ) == STATUS_MEMBER )
	{
		return;
	}
	
	new iGang = g_iGang[ id ];
	
	new szArgs[ 64 ];
	read_args( szArgs, charsmax( szArgs ) );
	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	new bool:bInGang[ 33 ];
	new iStatus[ 33 ];
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ id ] != g_iGang[ iPlayer ] )
			continue;
	
		bInGang[ iPlayer ] = true;
		iStatus[ iPlayer ] = getStatus( id, iGang );
		
		set_user_gang( iPlayer, -1 );
	}
	
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, iGang, aData );
	
	aData[ GangName ] = szArgs;
	
	ArraySetArray( g_aGangs, iGang, aData );
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( !bInGang[ iPlayer ] )
			continue;
		
		set_user_gang( iPlayer, iGang, iStatus[ id ] );
	}
}
	
public ShowAddAdminMenu( id )
{
	new iPlayers[ 32 ], iNum;
	new szName[ 32 ], szData[ 6 ];
	new hMenu = menu_create( "Выберите игрока для повышения:", "AddAdminMenu_Handler" );
	
	get_players( iPlayers, iNum );
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ id ] != g_iGang[ iPlayer ] || getStatus( iPlayer, g_iGang[ iPlayer ] ) > STATUS_MEMBER )
			continue;
		
		get_user_name( iPlayer, szName, charsmax( szName ) );
		
		num_to_str( iPlayer, szData, charsmax( szData ) );
		
		menu_additem( hMenu, szName, szData );
	}
	
	menu_display( id, hMenu, 0 );
}

public AddAdminMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( hMenu );
		ShowLeaderMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iAccess, hCallback, szData[ 6 ], szName[ 32 ];
	
	menu_item_getinfo( hMenu, iItem, iAccess, szData, charsmax( szData ), szName, charsmax( szName ), hCallback );
	
	new iChosen = str_to_num( szData );
	
	if( !is_user_connected( iChosen ) )
	{
		menu_destroy( hMenu );
		ShowLeaderMenu( id );
		return PLUGIN_HANDLED;
	}
	
	set_user_gang( iChosen, g_iGang[ id ], STATUS_LEADER );
	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ iPlayer ] != g_iGang[ id ] || iPlayer == iChosen )
			continue;
		
		client_print_color( iPlayer, 0, "%s ^03%s ^01был повышен до администратора вашей банды.", g_szPrefix, szName );
	}
	
	client_print_color( iChosen, 0, "%s ^01Вы были повышены до администратора вашей банды.", g_szPrefix );
	
	menu_destroy( hMenu );
	return PLUGIN_HANDLED;
}

public ShowRemoveAdminMenu( id )
{
	new iPlayers[ 32 ], iNum;
	new szName[ 32 ], szData[ 6 ];
	new hMenu = menu_create( "Выберите игрока для понижение:", "RemoveAdminMenu_Handler" );
	
	get_players( iPlayers, iNum );
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ id ] != g_iGang[ iPlayer ] || getStatus( iPlayer, g_iGang[ iPlayer ] ) != STATUS_ADMIN )
			continue;
		
		get_user_name( iPlayer, szName, charsmax( szName ) );
		
		num_to_str( iPlayer, szData, charsmax( szData ) );
		
		menu_additem( hMenu, szName, szData );
	}
	
	menu_display( id, hMenu, 0 );
}

public RemoveAdminMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( hMenu );
		ShowLeaderMenu( id );
		return PLUGIN_HANDLED;
	}
	
	new iAccess, hCallback, szData[ 6 ], szName[ 32 ];
	
	menu_item_getinfo( hMenu, iItem, iAccess, szData, charsmax( szData ), szName, charsmax( szName ), hCallback );
	
	new iChosen = str_to_num( szData );
	
	if( !is_user_connected( iChosen ) )
	{
		menu_destroy( hMenu );
		ShowLeaderMenu( id );
		return PLUGIN_HANDLED;
	}
	
	set_user_gang( iChosen, g_iGang[ id ], STATUS_MEMBER );
	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ iPlayer ] != g_iGang[ id ] || iPlayer == iChosen )
			continue;
		
		client_print_color( iPlayer, 0, "%s ^03%s ^01был понижен в должности от администратора вашей банды.", g_szPrefix, szName );
	}
	
	client_print_color( iChosen, 0, "%s ^01Вы были понижены в должности от администратора вашей банды.", g_szPrefix );
	
	menu_destroy( hMenu );
	return PLUGIN_HANDLED;
}
	
public ShowMembersMenu( id )
{
	new szName[ 64 ], iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	new hMenu = menu_create( "Онлайн член банды:", "MemberMenu_Handler" );
	
	for( new i = 0, iPlayer; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		
		if( g_iGang[ id ] != g_iGang[ iPlayer ] )
			continue;
		
		get_user_name( iPlayer, szName, charsmax( szName ) );
		
		switch( getStatus( iPlayer, g_iGang[ id ] ) )
		{
			case STATUS_MEMBER:
			{
				add( szName, charsmax( szName ), " \r[Участник]" );
			}
			
			case STATUS_ADMIN:
			{
				add( szName, charsmax( szName ), " \r[Админ]" );
			}
			
			case STATUS_LEADER:
			{
				add( szName, charsmax( szName ), " \r[Лидер]" );
			}
		}

		menu_additem( hMenu, szName );
	}
	
	menu_display( id, hMenu, 0 );
}

public MemberMenu_Handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( hMenu );
		Cmd_Gang( id );
		return PLUGIN_HANDLED;
	}
	
	menu_destroy( hMenu );
	
	ShowMembersMenu( id )
	return PLUGIN_HANDLED;
}

// Credits to Tirant from zombie mod and xOR from xRedirect


	
	

set_user_gang( id, iGang, iStatus=STATUS_MEMBER )
{
	new szAuthID[ 35 ];
	get_user_authid( id, szAuthID, charsmax( szAuthID ) );

	new aData[ GangInfo ];
	
	if( g_iGang[ id ] > -1 )
	{
		ArrayGetArray( g_aGangs, g_iGang[ id ], aData );
		TrieDeleteKey( aData[ GangMembers ], szAuthID );
		aData[ NumMembers ]--;
		ArraySetArray( g_aGangs, g_iGang[ id ], aData );
		
		sqlv_remove_ex(szAuthID, aData[GangName] );
	}

	if( iGang > -1 )
	{
		ArrayGetArray( g_aGangs, iGang, aData );
		TrieSetCell( aData[ GangMembers ], szAuthID, iStatus );
		aData[ NumMembers ]++;
		ArraySetArray( g_aGangs, iGang, aData );
		
		sqlv_set_num_ex(szAuthID, aData[ GangName ], iStatus );		
	}

	g_iGang[ id ] = iGang;
	
	return 1;
}
	
get_user_gang( id )
{
	new szAuthID[ 35 ];
	get_user_authid( id, szAuthID, charsmax( szAuthID ) );
	
	new aData[ GangInfo ];
	
	for( new i = 0; i < ArraySize( g_aGangs ); i++ )
	{
		ArrayGetArray( g_aGangs, i, aData );
		
		if( TrieKeyExists( aData[ GangMembers ], szAuthID ) )
			return i;
	}
	
	return -1;
}
			
getStatus( id, iGang )
{
	if( !is_user_connected( id ) || iGang == -1 )
		return STATUS_NONE;
		
	new aData[ GangInfo ];
	ArrayGetArray( g_aGangs, iGang, aData );
	
	new szAuthID[ 35 ];
	get_user_authid( id, szAuthID, charsmax( szAuthID ) );
	
	new iStatus;
	TrieGetCell( aData[ GangMembers ], szAuthID, iStatus );
	
	#if defined DEBUG_LOG
	server_print("%d | %s", iStatus, iStatus);
	#endif
	return iStatus;
}

public plugin_cfg()
{
	new szCfgDir[64];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	server_cmd("exec %s/jb_gangs.cfg", szCfgDir);


	get_cvar_string("jb_gangs_database_hostname", 			g_eCacheCvars[iDBHostname], 					charsmax(g_eCacheCvars[iDBHostname]));
	get_cvar_string("jb_gangs_database_username", 			g_eCacheCvars[iDBUserName], 					charsmax(g_eCacheCvars[iDBUserName]));
	get_cvar_string("jb_gangs_database_password", 			g_eCacheCvars[iDBPassword], 					charsmax(g_eCacheCvars[iDBPassword]));
	get_cvar_string("jb_gangs_database_datebase", 			g_eCacheCvars[iDBDateBase], 					charsmax(g_eCacheCvars[iDBDateBase]));
	get_cvar_string("jb_gangs_database_pre_gang_main",		g_eCacheCvars[iDBPrefix_Gang_Main], 			charsmax(g_eCacheCvars[iDBPrefix_Gang_Main]));
	get_cvar_string("jb_gangs_database_pre_gang_player",	g_eCacheCvars[iDBPrefix_Gang_Points], 			charsmax(g_eCacheCvars[iDBPrefix_Gang_Points]));
	get_cvar_string("jb_gangs_database_pre_gang_ex",		g_eCacheCvars[iDBPrefix_Gang_Ex], 				charsmax(g_eCacheCvars[iDBPrefix_Gang_Ex]));

	
	
	g_hDBSaveOther = SQL_MakeDbTuple
	(
		g_eCacheCvars[iDBHostname], 
        g_eCacheCvars[iDBUserName], 
        g_eCacheCvars[iDBPassword],
        g_eCacheCvars[iDBDateBase],
        10
    );
	
	new error[128], errnum
	new	Handle:g_MysqlConnect = SQL_Connect(g_hDBSaveOther, errnum, error, charsmax(error))

	if(g_MysqlConnect == Empty_Handle)
	{
		new szText[128];
		formatex(szText, charsmax(szText), "%s", error);
		log_to_file("mysqlt.log", "[IMBA] MYSQL ERROR: #%d", errnum);
		log_to_file("mysqlt.log", "[IMBA] %s", szText);
		return;
	}
	
	SQL_FreeHandle(g_MysqlConnect);

	new query[QUERY_LENGTH];
	
	SQL_SetCharset(g_hDBSaveOther, "utf8");
	
	
	formatex(query, charsmax(query),"CREATE TABLE IF NOT EXISTS `%s`\
	(\
		`id`			int(11) NOT NULL AUTO_INCREMENT,\
		`GangName`   	varchar(35) NOT NULL,\
		\
		`HP` 			int(11) NOT NULL, \
		`Stealing` 		int(11) NOT NULL, \
		\
		`Gravity` 		int(11) NOT NULL, \
		`Stamina` 		int(11) NOT NULL, \
		\
		`WeaponDrop` 	int(11) NOT NULL, \
		`Damage` 		int(11) NOT NULL, \
		\
		`Kills` 		int(11) NOT NULL, \
		\
		`ComFundLimit`	int(11) NOT NULL, \
		\
		PRIMARY KEY (id)\
	)\
		COLLATE='utf8_general_ci',\
		ENGINE=InnoDB;", g_eCacheCvars[iDBPrefix_Gang_Main]);

	SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);
	
	formatex(query, charsmax(query),"CREATE TABLE IF NOT EXISTS `%s`\
	(\
		`id`			int(11) NOT NULL AUTO_INCREMENT,\
		`key`   		VARCHAR(64) NOT NULL,\
		\
		`data` 			int(11) NOT NULL, \
		`timestamp` 	int(11) NOT NULL, \
		\
		`permanent` 	int(11) NOT NULL, \
		PRIMARY KEY (`id`)\
	)\
		COLLATE='utf8_general_ci',\
		ENGINE=InnoDB;", g_eCacheCvars[iDBPrefix_Gang_Points]);

	SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);
	
	formatex(query, charsmax(query),"CREATE TABLE IF NOT EXISTS `%s`\
	(\
		`id`			int(11) NOT NULL AUTO_INCREMENT,\
		`key1`   		VARCHAR(64) NOT NULL,\
		`key2` 			VARCHAR(64) NOT NULL, \
		\
		`data` 			VARCHAR(512) NOT NULL, \
		\
		`timestamp` 	int(11) NOT NULL, \
		`permanent` 	int(11) NOT NULL, \
		\
		PRIMARY KEY (`id`)\
	)\
		COLLATE='utf8_general_ci',\
		ENGINE=InnoDB;", g_eCacheCvars[iDBPrefix_Gang_Ex]);

	SQL_ThreadQuery(g_hDBSaveOther, "IgnoreHandle", query);
	
	set_task(1.0, "ConnectDBDate");

}

































































//Remake Plugin by DalgaPups VK: /takeshev