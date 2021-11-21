#include <amxmodx>
#include <amxmisc>
#include <saytext>

#pragma tabsize 4
#pragma semicolon 1

#define AUTHOR  "7heHex"
#define VER     "0.1"
#define PLUGIN  "[ZP] Give Bonus"

#define FLAG "0"
#define PLAYERS_PER_PAGE 7

new g_iMaxPlayers, g_iChosenPlayer[33], g_iUserID[33][33], g_iMenuPosition[33];
native userHasFlag(id, szFlag[]);

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
    
	register_menucmd(register_menuid("Open_BonusMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Close_BonusMenu");
	register_menucmd(register_menuid("Open_ChooseBonusMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Close_ChooseBonusMenu");
}

Open_BonusMenu(id, iPos)
{
	if(iPos < 0 || !userHasFlag(id, FLAG)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
        if(!is_user_connected(i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gZP!y]!y Нет подходящих игроков");
			return PLUGIN_HANDLED;
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "Меню выдачи бонусов^n^n");
		default: iLen = formatex(szMenu, charsmax(szMenu), "Меню выдачи бонусов \r[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[8] \wНазад", id);
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[8] \dНазад", id);

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9] \wДалее");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9] \dДалее");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0] \wВыход");
	
	return show_menu(id, iBitKeys, szMenu, -1, "Open_BonusMenu");
}

public Close_BonusMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_BonusMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_BonusMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
            
		}
	}
	return Open_BonusMenu(id, g_iMenuPosition[id]);
}