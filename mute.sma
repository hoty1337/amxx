#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <saytext>
#include <cstrike>
#include 		fakemeta

#define PLUGIN "MuteIP"
#define VERSION "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2

#define SQL_TABLENAME "jbm_mute"
#define FLAG_ADMIN ADMIN_IMMUNITY
#define TASK_LOADDATA 124428

/* -> Бит сумм -> */
#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

const PLAYERS_PER_PAGE = 7;
new Handle:MYSQL_Tuple;
new g_iMenuPosition[MAX_PLAYERS + 1], g_iUserID[MAX_PLAYERS + 1][MAX_PLAYERS + 1];
new g_ActiveMysql, szPlayerMysql[33], UserSteamID[33][34], UserIP[33][64], UserName[33][32], g_szQuery[512];
new bool:g_iMuteList[33][33], g_iUserVoiceTime[33], g_iUserChatTime[33], g_iType[33], g_iBitUserVoiceMuted, g_iBitUserChatMuted, g_iNextSorry[33];

const g_iMaxPlayers = 32;
new g_iListTime[] = { 1800, 7200, 86400, 604800, 0 };
new g_iMuteTime[33];

native jbm_is_user_chief(iPlayer);

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say", "checkSay");
	register_clcmd("say_team", "checkSay");
	register_clcmd("say /sorry", "cmdSorry");
	register_menucmd(register_menuid("Show_MuteMenu"), 1023, "Handle_MuteMenu");
	register_menucmd(register_menuid("Show_IndMuteMenu"), 1023, "Handle_IndMuteMenu");
	register_menucmd(register_menuid("Show_ChooseTime"), 1023, "Handle_ChooseTime");
	register_forward(FM_Voice_SetClientListening, "FakeMeta_Voice_SetListening", false);
}

public plugin_natives()
{
	register_native("is_user_muted", "is_user_muted", 1); 
	register_native("is_user_chat_muted", "is_user_chat_muted", 1); 
	register_native("Open_MuteMenu", "Cmd_IndMuteMenu", 1);
	register_native("Open_ChooseTime", "Open_ChooseTime", 1);
	register_native("Open_VMuteMenu", "Open_VMuteMenu", 1);
	register_native("Open_CMuteMenu", "Open_CMuteMenu", 1);
}

native jbm_get_user_donate(id);

public cmdSorry(id)
{
	if(IsNotSetBit(g_iBitUserChatMuted, id))
	{
		UTIL_SayText(id, "!y[!gJBM!y] Вы и так не в муте, за что просить прощение? :D");
		return PLUGIN_HANDLED;
	}
	new iTime = get_systime();
	if(g_iNextSorry[id] > iTime)
	{
		UTIL_SayText(id, "!y[!gJBM!y] Вы уже недавно просили прощение. Подождите еще !t%d сек.", g_iNextSorry[id] - iTime);
		return PLUGIN_HANDLED;
	}
	for(new i; i <= g_iMaxPlayers; i++)
	{
		if(is_user_connected(i) && jbm_get_user_donate(i) & (1<<3))
		{
			UTIL_SayText(i, "!y[!gJBM!y] Игрок !t%n !yпросит, чтобы его размутили.", id);
		}
	}
	g_iNextSorry[id] = iTime + 600;
	return PLUGIN_HANDLED;
}

public checkSay(id)
{	
	static sMessage[180]; 
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage); trim(sMessage);
	if(sMessage[0] != '/' && IsSetBit(g_iBitUserChatMuted, id)) 
	{
		UTIL_SayText(id, "!y[!gJBM!y] Вы были замучены и не можете писать в чат.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public Open_VMuteMenu(id)
{
	g_iType[id] = 1;
	return Show_ChooseTime(id);
}

public Open_CMuteMenu(id)
{
	g_iType[id] = 0;
	return Show_ChooseTime(id);
}

public Open_ChooseTime(id)
{
	return Show_ChooseTime(id);
}

public fbans_sql_connected(Handle:sqlTuple)
{ 
	MYSQL_Tuple = sqlTuple; 
	new err, error[256];
	SQL_Connect(MYSQL_Tuple, err, error, charsmax(error))
	g_ActiveMysql = true
	SQL_SetCharset(MYSQL_Tuple, "utf8");
	formatex(g_szQuery, charsmax(g_szQuery), "CREATE TABLE IF NOT EXISTS `%s` (`steamid` text not null, `ip` text not null, `time` int(11) not null default '-1', `nick` tinytext not null, `time2` int(11) not null default '-1');\
		COLLATE='utf8_general_ci',\
		ENGINE=InnoDB;", SQL_TABLENAME);
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery);
}

public client_connect(id)
{
	szPlayerMysql[id] = false;
	ClearBit(g_iBitUserVoiceMuted, id);
	ClearBit(g_iBitUserChatMuted, id);
	if(!is_user_bot(id) || !is_user_hltv(id))
	{
		set_task(1.0, "LoadData", id + TASK_LOADDATA);
	}
}

public client_disconnected(id)
{
	ClearBit(g_iBitUserVoiceMuted, id);
	ClearBit(g_iBitUserChatMuted, id);
	g_iNextSorry[id] = 0;
	for(new i; i<33; i++) g_iMuteList[id][i] = false;
	g_iUserVoiceTime[id] = -1;
	g_iUserChatTime[id] = -1;
}

public FakeMeta_Voice_SetListening(iReceiver, iSender, bool:bListen)
{
	if(!jbm_is_user_chief(iSender) && (IsSetBit(g_iBitUserVoiceMuted, iSender) || g_iMuteList[iReceiver][iSender]))
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, false);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public LoadData(idx)
{
	if(!g_ActiveMysql)
		return;
	new id = idx - TASK_LOADDATA;
	if(!is_user_connected(id) && !is_user_connecting(id))
		return;
	
	new iParams[1]
	iParams[0] = id
	
	get_user_authid(id, UserSteamID[id], 34);
	get_user_ip(id, UserIP[id], 64, 1);
	get_user_name(id, UserName[id], 32);
	
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
		formatex(g_szQuery, charsmax(g_szQuery), "INSERT INTO `%s` (`steamid`, `ip`, `time`, `nick`, `time2`) VALUES ('%s', '%s', '-1', '%s', '-1')", SQL_TABLENAME, UserSteamID[id], UserIP[id], UserName[id]);
		SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery)
		return PLUGIN_HANDLED;
	}
	else
	{
		new time = get_systime();
		if(SQL_ReadResult(hQuery, 2) > time || SQL_ReadResult(hQuery, 2) == 0)
		{
			SetBit(g_iBitUserVoiceMuted, id);
			g_iUserVoiceTime[id] = SQL_ReadResult(hQuery, 2);
		}
		if(SQL_ReadResult(hQuery, 4) > time || SQL_ReadResult(hQuery, 4) == 0)
		{
			SetBit(g_iBitUserChatMuted, id);
			g_iUserChatTime[id] = SQL_ReadResult(hQuery, 4);
		}
	}
	return PLUGIN_HANDLED;
}

public is_user_muted(id)
{
	if(IsSetBit(g_iBitUserVoiceMuted, id))
		return 1;
	return 0; 
}

public is_user_chat_muted(id)
{
	if(IsSetBit(g_iBitUserChatMuted, id))
		return 1;
	return 0; 
}

public set_user_mute(id, flag, time, iAdmin)
{
	g_iUserVoiceTime[id] = (time > 0 ? get_systime() + time : 0);
	if(flag == 0)
		ClearBit(g_iBitUserVoiceMuted, id);
	else	
		SetBit(g_iBitUserVoiceMuted, id);		
	client_save(id, flag, time, 1, iAdmin);
}
public set_user_mute_chat(id, flag, time, iAdmin)
{
	g_iUserChatTime[id] = (time > 0 ? get_systime() + time : 0);
	if(flag == 0)
		ClearBit(g_iBitUserChatMuted, id);
	else	
		SetBit(g_iBitUserChatMuted, id);		
	client_save(id, flag, time, 0, iAdmin);
}

public Show_ChooseTime(id)
{
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите время мута^n\wДля %s чата^n", (g_iType[id] ? "голосового" : "текстового"));
	for(new i; i < charsmax(g_iListTime); i++)
	{
		new szTime[32]; SecToNormalTime(g_iListTime[i], szTime, charsmax(szTime));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r%d\y] \d~ \w%s^n", i + 1, szTime);
		iKeys |= (1<<i);
	}
	for(new i; i < 10 - charsmax(g_iListTime); i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r0\y] \d~ \wВыход");
	return show_menu(id, iKeys, szMenu, -1, "Show_ChooseTime");
}

public Handle_ChooseTime(id, iKey)
{
	if(iKey == 9)
	{
		return PLUGIN_HANDLED;
	}
	g_iMuteTime[id] = g_iListTime[iKey];
	Cmd_MuteMenu(id);
	return PLUGIN_HANDLED;
}

const PLAYERS_PER_PAGE_2 = 8;

public Cmd_IndMuteMenu(id) return Show_IndMuteMenu(id, g_iMenuPosition[id] = 0);
public Show_IndMuteMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(!is_user_connected(i) || IsSetBit(g_iBitUserVoiceMuted, i) || i == id) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE_2;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE_2;
	new iEnd = iStart + PLAYERS_PER_PAGE_2;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE_2 + ((iPlayersNum % PLAYERS_PER_PAGE_2) ? 1 : 0));
	new szTimeV[13], szTimeC[13], szWarnV[24], szWarnC[24]; 
	if(g_iUserVoiceTime[id] - get_systime() > 0) SecToNormalTime(g_iUserVoiceTime[id] - get_systime(), szTimeV, charsmax(szTimeV));
	else copy(szTimeV, charsmax(szTimeV), "");
	formatex(szWarnV, charsmax(szWarnV), "Voice mute %s^n", szTimeV);
	if(g_iUserChatTime[id] - get_systime() > 0) SecToNormalTime(g_iUserChatTime[id] - get_systime(), szTimeC, charsmax(szTimeC));
	else copy(szTimeC, charsmax(szTimeC), "");
	formatex(szWarnC, charsmax(szWarnC), "Chat mute %s^n", szTimeC);

	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!g[JBM] %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return PLUGIN_HANDLED;
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\r%s%s\yМеню мута \w[%d|%d]^n\dНе слышите только вы^n", (!equal(szTimeV, "") ? szWarnV : ""), (!equal(szTimeC, "") ? szWarnC : ""), iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \d- \w%s %s^n", ++b, szName, (g_iMuteList[id][i] ? "\r[Размут.]" : "\y[Замут.]"));
	}
	for(new i = b; i < PLAYERS_PER_PAGE_2; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[\r9\y] \d- \w%L^n\y[\r0\y] \d- \w%L", id, "JBM_MENU_NEXT", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[\r0\y] \d- \w%L", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_IndMuteMenu");
}

public Handle_IndMuteMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_IndMuteMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_IndMuteMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE_2 + iKey];
			g_iMuteList[id][iTarget] = !g_iMuteList[id][iTarget];
			UTIL_SayText(id, "!g[JBM] !tВы !y%sмутили игрока !t%n!y.", (g_iMuteList[id][iTarget] ? "за" : "раз"), iTarget);
		}
	}
	return Show_IndMuteMenu(id, g_iMenuPosition[id]);
}

public Cmd_MuteMenu(id) return Show_MuteMenu(id, g_iMenuPosition[id] = 0);
public Show_MuteMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(!is_user_connected(i) /*|| i == id */|| (get_user_flags(i) & ADMIN_IMMUNITY && !(get_user_flags(id) & ADMIN_RCON))) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE_2;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE_2;
	new iEnd = iStart + PLAYERS_PER_PAGE_2;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE_2 + ((iPlayersNum % PLAYERS_PER_PAGE_2) ? 1 : 0));
	new szTimeV[13], szTimeC[13], szWarnV[24], szWarnC[24]; 
	if(g_iUserVoiceTime[id] - get_systime() > 0) SecToNormalTime(g_iUserVoiceTime[id] - get_systime(), szTimeV, charsmax(szTimeV));
	else copy(szTimeV, charsmax(szTimeV), "");
	formatex(szWarnV, charsmax(szWarnV), "Voice mute %s^n", szTimeV);
	if(g_iUserChatTime[id] - get_systime() > 0) SecToNormalTime(g_iUserChatTime[id] - get_systime(), szTimeC, charsmax(szTimeC));
	else copy(szTimeC, charsmax(szTimeC), "");
	formatex(szWarnC, charsmax(szWarnC), "Chat mute %s^n", szTimeC);
	switch(iPagesNum)
	{
		//case 0:
		//{
		//	UTIL_SayText(id, "!g[JBM] %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		///	return PLUGIN_HANDLED;
		//}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\r%s%s\yМеню мута \w[%d|%d]^n\d%s чат^n", (!equal(szTimeV, "") ? szWarnV : ""), (!equal(szTimeC, "") ? szWarnC : ""),  iPos + 1, iPagesNum, (g_iType[id] ? "голосовой" : "текстовый"));
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		new szTimeLeft[32], iTime = (g_iType[id] ? g_iUserVoiceTime[i] : g_iUserChatTime[i]) - get_systime();
		if(iTime <= 0)
		{
			if(g_iType[id] && g_iUserVoiceTime[i] != 0)
			{
				ClearBit(g_iBitUserVoiceMuted, i);
				g_iUserVoiceTime[i] = -1;
			}
			if(!g_iType[id] && g_iUserChatTime[i] != 0)
			{
				ClearBit(g_iBitUserChatMuted, i);
				g_iUserChatTime[i] = -1;
			}
		}
		if(g_iType[id] && IsSetBit(g_iBitUserVoiceMuted, i) || !g_iType[id] && IsSetBit(g_iBitUserChatMuted, i))
		{
			SecToNormalTime(iTime, szTimeLeft, charsmax(szTimeLeft));
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \d- \w%s \r[%s]^n", ++b, szName, szTimeLeft);
		}
		else 
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \d- \w%s^n", ++b, szName);
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE_2; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[\r9\y] \d- \w%L^n\y[\r0\y] \d- \w%L", id, "JBM_MENU_NEXT", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[\r0\y] \d- \w%L", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MuteMenu");
}

native jbm_get_user_team(id);
native jbm_set_user_team(id, iTeam);

public Handle_MuteMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_MuteMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_MuteMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE_2 + iKey];
			if(g_iType[id])
			{
				if(IsNotSetBit(g_iBitUserVoiceMuted, iTarget))
				{
					set_user_mute(iTarget, 1, g_iMuteTime[id], id);
					new szTimeLeft[32];
					SecToNormalTime(g_iMuteTime[id], szTimeLeft, charsmax(szTimeLeft));
					if(jbm_get_user_team(iTarget) == 2 && jbm_set_user_team(iTarget, 1))
					{
						UTIL_SayText(iTarget, "!g[JBM] !yВы были автоматически переведены из-за того, что вас !tзамутили!y.");
					}
					UTIL_SayText(0, "!g[JBM] !t%n !yзамутил игрока !t%n !yна %s", id, iTarget, szTimeLeft);
				}
				else 
				{
					ClearBit(g_iBitUserVoiceMuted, iTarget);
					set_user_mute(iTarget, 0, -1, id);
					UTIL_SayText(0, "!g[JBM] !t%n !yразмутил игрока !t%n!y.", id, iTarget);
				}
			}
			else 
			{
				if(IsNotSetBit(g_iBitUserChatMuted, iTarget))
				{
					set_user_mute_chat(iTarget, 1, g_iMuteTime[id], id);
					new szTimeLeft[32];
					SecToNormalTime(g_iMuteTime[id], szTimeLeft, charsmax(szTimeLeft));
					UTIL_SayText(0, "!g[JBM] !t%n !yзапретил писать игроку !t%n !yна %s", id, iTarget, szTimeLeft);
				}
				else 
				{
					ClearBit(g_iBitUserChatMuted, iTarget);
					set_user_mute_chat(iTarget, 0, -1, id);
					UTIL_SayText(0, "!g[JBM] !t%n !yразрешил писать игроку !t%n!y.", id, iTarget);
				}
			}
		}
	}
	return Show_MuteMenu(id, g_iMenuPosition[id]);
}

public client_save(id,flag,time, iType, iAdmin)
{
	if(!g_ActiveMysql)
		return;

	if(!szPlayerMysql[id])
		return;
	if(iType)
	{
		if(flag)
		{
			new blockTime = (time == 0 ? 0 : (get_systime() + time));
			formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time` = '%d', `nick` = '%n', `admin` = '%n' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, blockTime, id, iAdmin, SQL_TABLENAME, UserIP[id])
		}
		else
		{
			formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time` = '-1' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, SQL_TABLENAME, UserIP[id]);
		}
	}
	else 
	{
		if(flag)
		{
			new blockTime = (time == 0 ? 0 : (get_systime() + time));
			formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time2` = '%d', `nick` = '%n', `admin2` = '%n' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, blockTime, id, iAdmin, SQL_TABLENAME, UserIP[id])
		}
		else
		{
			formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `time2` = '-1' WHERE `%s`.`ip` = '%s';", SQL_TABLENAME, SQL_TABLENAME, UserIP[id]);
		}
	}
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery)
}

public SQL_Thread(iState, Handle: hQuery, szError[], iErrorCode, iParams[], iParamsSize)
{
	if(iState == 0)
		return;
	
	log_amx("SQL Error: %d (%s)", iErrorCode, szError)
}

stock SecToNormalTime(iTime, szCopyTo[], iLen)
{
	new iTimeLeft = iTime, szTimeLeft[32], szTime[10];
	if(iTimeLeft != 0)
	{
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
	}
	else
	{
		new iRand = random_num(5, 10);
		formatex(szTimeLeft, charsmax(szTimeLeft), "!g%d веков", iRand);
	}
	formatex(szTimeLeft, charsmax(szTimeLeft), "%d %s", iTimeLeft, szTime);
	copy(szCopyTo, iLen, szTimeLeft);
}