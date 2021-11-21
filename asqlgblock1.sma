#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <saytext>
#include <cstrike>

#define PLUGIN "BlockGuardSQL"
#define VERSION "2.0"
#define AUTHOR "Dimax_Lee & 7heHex"

#pragma tabsize 2

#define SQL_TABLENAME "jbm_block"
#define FLAG_ADMIN ADMIN_IMMUNITY

/* -> Бит сумм -> */
#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

const PLAYERS_PER_PAGE = 7;
new Handle:MYSQL_Tuple;
new g_iMenuPlayersTime[MAX_PLAYERS + 1][64][32], g_iMenuPosition[MAX_PLAYERS + 1];
new g_iMenuPlayersIp[MAX_PLAYERS + 1][64][32];
new g_iMenuPlayersName[MAX_PLAYERS + 1][64][32];
new g_ActiveMysql, g_iBitUserBlockedGuard;
new szPlayerMysql[33]
new UserSteamID[33][34], UserIP[33][64];

new g_szQuery[512], Handle:SQL_Connection ; 

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_menucmd(register_menuid("Show_UnBlockMenu"), 1023, "Handle_UnBlockMenu");
}

native jbm_set_user_team(iPlayer, iTeam);

public plugin_natives()
{
	register_native("is_user_blocked", "is_user_blocked", 1);
	register_native("set_user_block", "set_user_block", 1);   
	register_native("Open_UnBlockMenu", "Cmd_UnBlockMenu", 1);
}

public fbans_sql_connected(Handle:sqlTuple)
{ 
	MYSQL_Tuple = sqlTuple; 
	new err, error[256];
	SQL_Connection = SQL_Connect(MYSQL_Tuple, err, error, charsmax(error))
	g_ActiveMysql = true
	formatex(g_szQuery, charsmax(g_szQuery), "CREATE TABLE IF NOT EXISTS `%s` (`steamid` text not null, `ip` text not null, `time` int(11) not null default '-1', `nick` tinytext not null);", SQL_TABLENAME);
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery);
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

public LoadData(id)
{
	if(!g_ActiveMysql)
		return;
	
	if(!is_user_connected(id) && !is_user_connecting(id))
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
public set_user_block(id, flag, time, szIp[32])
{
	if(flag == 0)
		ClearBit(g_iBitUserBlockedGuard, id);
	else	
		SetBit(g_iBitUserBlockedGuard, id);		
	client_save(id, flag, time, szIp)
}

native jbm_open_predatormenu(id);

public Cmd_UnBlockMenu(id) return Show_UnBlockMenu(id, g_iMenuPosition[id] = 0);
public Show_UnBlockMenu(id, iPos)
{
	if(iPos < 0) return jbm_open_predatormenu(id);
	new iPlayersNum;
	new Handle:query = SQL_PrepareQuery(SQL_Connection,"SELECT * FROM `%s`", SQL_TABLENAME);
  if(!SQL_Execute(query))
	{
		UTIL_SayText(0, "SQL_Execute не выполнился %s", query);
	}

  while(SQL_MoreResults(query))
	{
    new szName[32], szIp[32], iTime; 
		SQL_ReadResult			(query, 1, szIp, charsmax(szIp));
		iTime = SQL_ReadResult	(query, 2);
		if(iTime == -1 || (get_systime() > iTime && iTime != 0))
		{
      SQL_NextRow(query);
			continue;
		}
    SQL_ReadResult			(query, 3, szName, charsmax(szName));
		g_iMenuPlayersIp[id][iPlayersNum] = szIp;
		g_iMenuPlayersName[id][iPlayersNum] = szName;
		new szTimeLeft[32];
		if(iTime != 0)
		{
			new iTimeLeft = iTime - get_systime(), szTime[10];
			if(iTimeLeft > 60)
			{
				iTimeLeft /= 60;
				szTime = "мин.";
				if(iTimeLeft > 60)
				{
					iTimeLeft /= 60;
					szTime = "ч.";
					if(iTimeLeft > 24)
					{
						iTimeLeft /= 24;
						szTime = "д.";
					}
				}
			}
			else 
			{
				iTimeLeft = 1;
				szTime = "мин.";
			}
			formatex(szTimeLeft, charsmax(szTimeLeft), "\r[\y%d %s\r]", iTimeLeft, szTime);
		}
		else
		{
			new iRand = random_num(5, 10);
			formatex(szTimeLeft, charsmax(szTimeLeft), "\r[\y%d веков\r]", iRand);
		}
		g_iMenuPlayersTime[id][iPlayersNum] = szTimeLeft;
		iPlayersNum++;
    SQL_NextRow(query);
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
			return jbm_open_predatormenu(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wКого разблокировать? \w[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], szTime[32], iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		szName = g_iMenuPlayersName[id][a];
		szTime = g_iMenuPlayersTime[id][a];
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \d- \w%s %s^n", ++b, szName, szTime);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[\r9\y] \d- \w%L^n\y[\r0\y] \d- \w%L", id, "JBM_MENU_NEXT", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[\r0\y] \d- \w%L", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_UnBlockMenu");
}

public Handle_UnBlockMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_UnBlockMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_UnBlockMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new szIp[32], szName[32];
			szIp = g_iMenuPlayersIp[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			szName = g_iMenuPlayersName[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			set_user_block(id, 0, -1, szIp);
			new iPlayers[MAX_PLAYERS], iNum, szPlayerIp[32];
			get_players(iPlayers, iNum, "ch");
			for(new i = 1; i <= iNum; i++)
			{
				get_user_ip(i, szPlayerIp, charsmax(szPlayerIp), 1);
				if(equali(szIp, szPlayerIp))
				{
					ClearBit(g_iBitUserBlockedGuard, i);
					UTIL_SayText(0, "!g[JBM] !t%n !yразблокировал игроку !t%n !yвход за охрану.", id, i);
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

public client_save(id,flag,time, szIp[32])
{
	if(!g_ActiveMysql)
		return;

	if(!szPlayerMysql[id])
		return;
	if(flag)
	{
		new blockTime = (time == 0 ? 0 : (get_systime() + time));
		formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time` = '%d', `nick` = '%n' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, blockTime, id, SQL_TABLENAME, UserIP[id])
	}
	else
	{
		formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time` = '-1' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, SQL_TABLENAME, szIp);
		Show_UnBlockMenu(id, g_iMenuPosition[id]);
	}
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery)
}

public SQL_Thread(iState, Handle: hQuery, szError[], iErrorCode, iParams[], iParamsSize)
{
	if(iState == 0)
		return;
	
	log_amx("SQL Error: %d (%s)", iErrorCode, szError)
}