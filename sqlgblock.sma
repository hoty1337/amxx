#include <amxmodx>
#include <amxmisc>
#include <sqlx>

#define PLUGIN "BlockGuardSQL"
#define VERSION "1.1"
#define AUTHOR "Dimax_Lee & 7heHex"

#define SQL_TABLENAME "jbm_block"
#define FLAG_ADMIN ADMIN_IMMUNITY

/* -> Бит сумм -> */
#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

new g_iListTime[] = { 1800, 7200, 86400, 604800, 0 };

new Handle:MYSQL_Tuple
new g_iMaxPlayers;
new g_iMenuPlayers[MAX_PLAYERS + 1][MAX_PLAYERS], g_iMenuPosition[MAX_PLAYERS + 1], g_iMenuTarget[MAX_PLAYERS + 1];
new g_ActiveMysql, g_iBitUserBlockedGuard
new szPlayerMysql[33]
new UserSteamID[33][34], UserIP[33][64];
new g_iBlockTime[33];

new g_szQuery[512]; 

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_iMaxPlayers = get_maxplayers();
	register_menucmd(register_menuid("Show_ChooseBlockTime"), 1023, "Handle_ChooseBlockTime");
	register_menucmd(register_menuid("Show_BlockedGuardMenu"), 1023, "Handle_BlockedGuardMenu");
}

public plugin_natives()
{
	register_native("is_user_blocked", "is_user_blocked", 1);
	register_native("set_user_block", "set_user_block", 1);   
}

public fbans_sql_connected(Handle:sqlTuple)
{ 
	MYSQL_Tuple = sqlTuple; 
	g_ActiveMysql = true
	for(new i=0;i<33;i++)
	{
		if(is_user_connected(i))
		{
			LoadData(i);
		}
	}
}

public client_connect(id)
{
	szPlayerMysql[id] = false;
	ClearBit(g_iBitUserBlockedGuard, id);
	if(!is_user_bot(id) || !is_user_hltv(id))
	{
		set_task(1.0, "LoadData", id);
	}
}

public client_disconnected(id)
{
	ClearBit(g_iBitUserBlockedGuard, id);
}

Show_ChooseBlockTime(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите время блокировки^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r1\y] \d~ \w30 минут^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r2\y] \d~ \w2 часа^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r3\y] \d~ \w1 день^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r4\y] \d~ \wНеделя^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r5\y] \d~ \wНавсегда^n^n");

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r0\y] \d~ \wВыход");
	show_menu(id, iKeys, szMenu, -1, "Show_ChooseBlockTime");
}

Handle_ChooseBlockTime(id, iKey)
{
	g_iBlockTime[id] = g_iListTime[iKey];
	return Cmd_BlockedGuardMenu(id);
}

Cmd_BlockedGuardMenu(id) return Show_BlockedGuardMenu(id, g_iMenuPosition[id] = 0);
Show_BlockedGuardMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitUserConnected, i) || get_user_flags(i) & FLAG_ADMIN || i == id || IsSetBit(g_iBitUserBlockedGuard, i)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!g[JBM] %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return PLUGIN_HANDLED;
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBM_MENU_BLOCKED_GUARD_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \d- \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[\r9\y] \d- \w%L^n\y[\r0\y] \d- \w%L", id, "JBM_MENU_NEXT", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[\r0\y] \d- \w%L", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_BlockedGuardMenu");
}

public Handle_BlockedGuardMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_BlockedGuardMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_BlockedGuardMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 2) jbm_set_user_team(iTarget, 1);
			SetBit(g_iBitUserBlockedGuard, iTarget);
			set_user_block(iTarget, 1, g_iBlockTime[id]);
			UTIL_SayText(0, "!g[JBM] !t%n !yзаблокировал игроку !t%n !yвход за охрану.", id, iTarget);
		}
	}
	return Show_BlockedGuardMenu(id, g_iMenuPosition[id]);
}

public LoadData(id)
{
	if(!g_ActiveMysql)
		return;
	
	if(!is_user_connected(id))
		return;
	
	new iParams[1]
	iParams[0] = id
	
	get_user_authid(id, UserSteamID[id], charsmax(UserSteamID[]))
	get_user_ip(id, UserIP[id], charsmax(UserIP[]), 1);
	
	formatex(g_szQuery, charsmax(g_szQuery), "SELECT * FROM `%s` WHERE (`%s`.`ip` = '%s')", SQL_TABLENAME, SQL_TABLENAME, UserIP[id])
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Query", g_szQuery, iParams, sizeof iParams)
}

public SQL_Query( iState, Handle: hQuery, szError[], iErrorCode, iParams[], iParamsSize)
{
	switch(iState)
	{
		case TQUERY_CONNECT_FAILED: log_amx("Load - Could not connect to SQL database. [%d] %s", iErrorCode, szError)
		case TQUERY_QUERY_FAILED: log_amx("Load Query failed. [%d] %s", iErrorCode, szError)
	}
	
	new id = iParams[0]
	szPlayerMysql[id] = true
	
	if(SQL_NumResults(hQuery) < 1)
	{
		if(equal(UserSteamID[id], "ID_PENDING"))
			return PLUGIN_HANDLED
		formatex(g_szQuery, charsmax(g_szQuery), "INSERT INTO `%s` (`steamid`, `ip`, `time`, `nick`) VALUES ('%s', '%s', '-1', '%n')", SQL_TABLENAME, UserSteamID[id], UserIP[id], id);
		SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery)
		return PLUGIN_HANDLED;
	}
	else
	{
		new time = get_systime();
		if(SQL_ReadResult(hQuery, 2) > time || SQL_ReadResult(hQuery, 2) == 0)
		{
			SetBit(g_iBitUserBlockedGuard, id);	
		}
	}
	return PLUGIN_HANDLED;
}

public is_user_blocked(id)
{
	if(IsSetBit(g_iBitUserBlockedGuard, id))
		return 1;
	return 0; 
}
public set_user_block(id, flag, time = -1)
{
	if(flag == 0)
		ClearBit(g_iBitUserBlockedGuard, id);
	else	
		SetBit(g_iBitUserBlockedGuard, id);		
	client_save(id, flag, time)
}


public client_save(id,flag,time)
{
	if(!g_ActiveMysql)
		return;

	if(!szPlayerMysql[id])
		return;
	if(flag)
	{
		new blockTime = get_systime() + g_iBlockTime[id];
		formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time` = '%d' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, blockTime, SQL_TABLENAME, UserIP[id])
	}
	else
	{
		formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time` = '-1' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, SQL_TABLENAME, UserIP[id])
	}
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery)
}

public SQL_Thread(iState, Handle: hQuery, szError[], iErrorCode, iParams[], iParamsSize)
{
	if(iState == 0)
		return;
	
	log_amx("SQL Error: %d (%s)", iErrorCode, szError)
}