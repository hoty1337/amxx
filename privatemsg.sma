#include <amxmodx>
#include <saytext>
#include <regex>
#include <fvault>

#define PLUGIN "PM"
#define VER "0.1"
#define AUTHOR "7heHex"

#define FVAULT_PM	"PRIVATE_MSG"
#define PLAYERS_PER_PAGE 7
#define PATTERN_IP "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

#pragma tabsize 2
#pragma semicolon 1

#define setBit(%0,%1)				((%0)	|=	(1 << (%1))  )
#define clearBit(%0,%1)				((%0)	&=	~(1 << (%1)) )
#define isSetBit(%0,%1)				((%0)	&	(1 << (%1))  )
#define invertBit(%0,%1)			((%0)	^=	(1 << (%1))  )
#define isNotSetBit(%0,%1)			(~(%0)	&	(1 << (%1))  )

new g_iMenuPosition[33], g_iUserID[MAX_PLAYERS + 1][MAX_PLAYERS], Regex:xResult, g_iMaxPlayers, xReturnValue, xError[64],
g_iBitUserPM, bool:g_bVisibleAdm;

public plugin_init()
{
	register_plugin(PLUGIN, VER, AUTHOR);
	register_clcmd("say /pm", "ClCmd_ChoosePlayer");
	register_clcmd("privatemsg", "Command_PrivateMsg");
	register_menucmd(register_menuid("Show_PlayerMenu"), 1023, "Handle_PlayerMenu");
	g_iMaxPlayers = get_maxplayers();
}

public client_putinserver(id)
{
	LoadData(id);
}

public client_disconnected(id)
{
	SaveData(id);
}

LoadData(id)
{
	new iAuth[35]; get_user_authid(id, iAuth, sizeof(iAuth) - 1);
	new iData[10];
	if(fvault_get_data(FVAULT_PM, iAuth, iData, sizeof(iData) - 1)) 
	{
		if(str_to_num(iData)) setBit(g_iBitUserPM, id);
		else clearBit(g_iBitUserPM, id);
	}
	else setBit(g_iBitUserPM, id);
}

SaveData(id)
{
    new iAuth[35];
    get_user_authid(id, iAuth, sizeof(iAuth) - 1);
    new iData[10];
    num_to_str(isSetBit(g_iBitUserPM, id), iData, sizeof(iData) - 1);
    fvault_set_data(FVAULT_PM, iAuth, iData);
}

public plugin_natives()
{
	register_native("pm_set_visible_adm", "pm_set_visible_adm", 1);
	register_native("pm_is_visible_adm", "pm_is_visible_adm", 1);
}

public pm_set_visible_adm(bool:bFlag)
{
	g_bVisibleAdm = bFlag;
}

public pm_is_visible_adm()
{
	return g_bVisibleAdm;
}

native jbm_is_user_chief(pPlayer);
native is_user_chat_muted(id);

public ClCmd_ChoosePlayer(id) return Show_PlayerMenu(id, g_iMenuPosition[id] = 0);
public Show_PlayerMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	if(is_user_chat_muted(id))
	{
		UTIL_SayText(id, "!t[ЛС] !yВы были замучены. Чтобы попросить !tразмут !yнапишите в чат !g/sorry");
		return PLUGIN_HANDLED;
	}
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(!is_user_connected(i) || i == id || (isNotSetBit(g_iBitUserPM, i) && !jbm_is_user_chief(id))) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	/*switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!g[JBM] %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return PLUGIN_HANDLED;
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\r[JBM] \yВыберите игрока \w[%d|%d]^n^n", iPos + 1, iPagesNum);
	}*/
	iLen = formatex(szMenu, charsmax(szMenu), "\r[JBM] \yВыберите игрока \w[%d|%d]^n^n", iPos + 1, iPagesNum);
	new i, iKeys = (1<<7|1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r%d\y] \d- \w%n^n", ++b, i);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r8\y] \d- \wЛичные сообщения \r[\y%s\r]^n", (isSetBit(g_iBitUserPM, id) ? "Вкл" : "Выкл"));
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[\r9\y] \d- \w%L^n\y[\r0\y] \d- \w%L", id, "JBM_MENU_NEXT", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[\r0\y] \d- \w%L", id, iPos ? "JBM_MENU_BACK" : "JBM_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PlayerMenu");
}

public Handle_PlayerMenu(id, iKey)
{
	switch (iKey)
	{
		case 7:
		{
			invertBit(g_iBitUserPM, id);
			UTIL_SayText(id, "!t[ЛС] !yВы %s личные сообщения.", isSetBit(g_iBitUserPM, id) ? "включили" : "отключили");
			SaveData(id);
			return Show_PlayerMenu(id, g_iMenuPosition[id]);
		}
		case 8: return Show_PlayerMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_PlayerMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			client_cmd(id, "messagemode ^"privatemsg %d^"", iTarget);
		}
	}
	return PLUGIN_HANDLED;
}

public Command_PrivateMsg(id, iTarget)
{
	new szArg1[3], szArg2[64];
	read_argv(1, szArg1, charsmax(szArg1));
	read_argv(2, szArg2, charsmax(szArg2));
	if(!is_str_num(szArg1))
	{
		UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_ERROR_PARAMETERS");
		return PLUGIN_HANDLED;
	}
	iTarget = str_to_num(szArg1);
	xResult = regex_match(szArg2, PATTERN_IP, xReturnValue, xError, 63);
	if(xResult)
	{
		UTIL_SayText(id, "!t[ЛС] !yIP адреса отправлять !gЗАПРЕЩЕНО!y!");
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!is_user_connected(i)) continue;
			if(get_user_flags(i) & ADMIN_IMMUNITY)
			{
				UTIL_SayText(i, "!t[ЛС] !yИгрок !g%n !yпопытался отправить IP в личном сообщении.", id);
			}
		}
		return PLUGIN_HANDLED;
	}
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(!is_user_connected(i)) continue;
		if((get_user_flags(i) & ADMIN_IMMUNITY && g_bVisibleAdm) || i == id || i == iTarget)
		{
			UTIL_SayText(i, "!y[!g%n!t->!g%n!y]: %s", id, iTarget, szArg2);
		}
	}
	return PLUGIN_HANDLED;
}