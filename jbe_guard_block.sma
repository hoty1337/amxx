#include <amxmodx>
#include <sqlx>

	/* [Макросы | начало] */
#define VERSION "1.0"
#define ACCESS ADMIN_BAN
#define MAXCLIENTS 32
#define cmax(%0) sizeof(%0) - 1
#define is_user_admin(%0) (get_user_flags(%0) > 0 && ~get_user_flags(%0) & ADMIN_USER)

#define TASK_INDEX_MYSQL 28819293

#define SetBit(%0,%1)				((%0) |= (1 << (%1)))
#define ClearBit(%0,%1)				((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1)				((%0) & (1 << (%1)))
#define InvertBit(%0,%1)			((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1)			(~(%0) & (1 << (%1)))

#if AMXX_VERSION_NUM < 183
	#include <colorchat>
	#define client_disconnected client_disconnect
#endif
	/* [Макросы | конец] */
	
	/* [Нативы | начало] */
native jbe_informer_offset_up(id);
native jbe_informer_offset_down(id);
	
native jbe_get_user_team(id);
native jbe_set_user_team(id, iTeam);
	/* [Нативы | конец] */
	
	/* [Переменные | начало] */
new Handle:hSql, Handle:hConnected;
new g_iBitUserBlock;

new uSteamId[33][35], uIpAddress[33][23];
	/* [Переменные | конец] */
	
public plugin_init() {
	register_plugin("JBE Guard block :: MySQL", VERSION, "OverGame");
	
	register_cvar("jbe_sql_hostname1", "185.238.138.30");
	register_cvar("jbe_sql_username1", "sql_1485_free");
	register_cvar("jbe_sql_password1", "TLwGJ1jqtg");
	register_cvar("jbe_sql_database1", "sql_1485_free");
	register_cvar("jbe_sql_prefixes1", "bk_");
	
	register_concmd("block_guard", "ConCmd_SayBlock");
	register_concmd("say /block", "ConCmd_SayBlock");
	register_concmd("say_team /block", "ConCmd_SayBlock");
}

public plugin_cfg() {
	new sPatch[64];
	get_localinfo("amxx_configsdir", sPatch, cmax(sPatch));
	server_cmd("exec %s/jbe_sql_data.cfg", sPatch);
	
	set_task(1.0, "Task_MySQL_Connect", TASK_INDEX_MYSQL);
}

public Task_MySQL_Connect(i_Task) {
	new iErr, sErr[256];
	
	hSql = SQL_MakeDbTuple(UTIL_GetCvarString("jbe_sql_hostname1"), UTIL_GetCvarString("jbe_sql_username1"), UTIL_GetCvarString("jbe_sql_password1"), UTIL_GetCvarString("jbe_sql_database1"));
	
	if((hConnected = SQL_Connect(hSql, iErr, sErr, cmax(sErr))) == Empty_Handle) {
		set_fail_state(sErr);
	}
	else {
		SQL_QueryAndIgnore(hConnected, "set names utf8");
		SQL_Execute((SQL_PrepareQuery(hConnected, "CREATE TABLE IF NOT EXISTS `%slist_blocks` (`id` int(9) NOT NULL AUTO_INCREMENT,`steam_id` varchar(35) NOT NULL,`ip` varchar(32) NOT NULL,PRIMARY KEY (`id`)) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=22;", UTIL_GetCvarString("jbe_sql_prefixes"))));
	}
	
	SQL_FreeHandle(hConnected);
	remove_task(i_Task);
}

public client_putinserver(id) {
	get_user_authid(id, uSteamId[id], cmax(uSteamId[]));
	get_user_ip(id, uIpAddress[id], cmax(uIpAddress[]), 1);
	
	new sQuery[256], iClient[3];
	
	formatex(sQuery, charsmax(sQuery), "SELECT * FROM `%slist_blocks` WHERE (`steam_id` LIKE '%s')",  UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[id]);
	
	iClient[0] = id;
	iClient[1] = 2;
	
	SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
}

public client_disconnected(id) {
	if(IsSetBit(g_iBitUserBlock, id))
		ClearBit(g_iBitUserBlock, id);
}

public SQL_Handler(iFailState, Handle:iQuery, szError[], iError, szData[], iDataLen) {
	switch(iFailState) {
		case TQUERY_CONNECT_FAILED: return log_amx("No connect database: %s", szError);
		case TQUERY_QUERY_FAILED: return log_amx("Query error: %s", szError);
	}
	
	new id = szData[0], iType = szData[1];
	
	/* [SELECT * FROM `users` WHERE (`users`.`steam_id` = '%s')] */
	/* [INSERT INTO `users` (`steam_id`, `level`, `exp`) VALUES ('%s', '0', '0');] */
	
	switch(iType) {
		case 1: {
			if(SQL_NumResults(iQuery)) {
				SetBit(g_iBitUserBlock, id);
			}
			else {
				new szName[33], sQuery[148], iClient[2];
				get_user_name(id, szName, charsmax(szName));
				
				iClient[0] = id;
				iClient[1] = 0;
				
				formatex(sQuery, charsmax(sQuery), "INSERT INTO `%slist_blocks` (`steam_id`, `ip`) VALUES ('%s', '%s')", UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[id], uIpAddress[id]);
				
				SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
			}
		}
		case 2: {
			if(SQL_NumResults(iQuery)) {
				SetBit(g_iBitUserBlock, id);
			}
		}
	}
	
	return true;
}

public ConCmd_SayBlock(id) {
	if(get_user_flags(id) & ACCESS) {
		return Open_BlockMenu(id);
	}
	
	client_print_color(id, print_team_grey, "^04[БЛОК] ^01У вас недостаточно прав!");
	return PLUGIN_HANDLED;
}

public Open_BlockMenu(id) {
	new sTemp[10], sDataString[128], iMenu = menu_create("Блокировка охраны", "Close_BlockMenu");
	
	jbe_informer_offset_up(id);
	
	for(new i = 1; i <= MAXCLIENTS; i++) {
		if(!is_user_connected(i) || i == id || is_user_admin(i))
			continue;
		
		get_user_name(i, sDataString, cmax(sDataString));
		
		num_to_str(i, sTemp, cmax(sTemp));
		formatex(sDataString, cmax(sDataString), "%s%s\R%s", sDataString, IsSetBit(g_iBitUserBlock, i) ? "\r*" : "", (jbe_get_user_team(i) == 2) ? "\yGUARD" : "\rPRISON");
		menu_additem(iMenu, sDataString, sTemp);
	}
	
	return menu_display(id, iMenu, 0);
}

public Close_BlockMenu(id, iMenu, aItem) {
	jbe_informer_offset_down(id);
	
	new sData[30], sName[64], iAccess, iCallBack;
	menu_item_getinfo(iMenu, aItem, iAccess, sData, cmax(sData), sName, cmax(sName), iCallBack);
	
	new iPlayer = str_to_num(sData);
	if(0 < iPlayer <= MAXCLIENTS) {
		new sQuery[256], iClient[3];
		
		if(IsNotSetBit(g_iBitUserBlock, iPlayer)) {
			SetBit(g_iBitUserBlock, iPlayer);
			
			formatex(sQuery, charsmax(sQuery), "SELECT * FROM `%slist_blocks` WHERE `steam_id` LIKE '%s'",  UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[iPlayer]);
			
			iClient[0] = iPlayer;
			iClient[1] = 1;
			
			SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
		}
		else {
			ClearBit(g_iBitUserBlock, iPlayer);
			
			formatex(sQuery, charsmax(sQuery), "DELETE FROM `%slist_blocks` WHERE `%slist_blocks`.`steam_id`='%s'", UTIL_GetCvarString("jbe_sql_prefixes"), UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[iPlayer]);
			
			iClient[0] = iPlayer;
			iClient[1] = 0;
			
			SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
		}
		
		new sNickname[33], sTargetName[33];
		get_user_name(id, sNickname, cmax(sNickname));
		get_user_name(iPlayer, sTargetName, cmax(sTargetName));
		
		if(jbe_get_user_team(iPlayer) == 2)
			jbe_set_user_team(iPlayer, 1);
		
		client_print_color(0, print_team_grey, "^04[БЛОК] ^03[%s] ^01%s вход за охрану для ^03[%s]^0!", sNickname, IsSetBit(g_iBitUserBlock, iPlayer) ? "заблокировал" : "разблокировал", sTargetName);
		
		log_to_file("/addons/amxmodx/logs/blocks.txt", "^n^n[BLOCK SYSTEM BY OVERGAME]^nАдминистратор [%s]^nНарушитель [%s]^nСтатус: %s", sNickname, sTargetName, IsSetBit(g_iBitUserBlock, iPlayer) ? "заблокирован" : "разблокирован");
	}
	
	return PLUGIN_HANDLED;
}

public plugin_natives() 
	register_native("jbe_is_gblock", "jbe_is_gblock", true);

public jbe_is_gblock(id)
	return IsSetBit(g_iBitUserBlock, id);

stock UTIL_GetCvarString(const s_String[]) {
	new sDataString[128];
	get_cvar_string(s_String, sDataString, cmax(sDataString));
	
	return sDataString;
}