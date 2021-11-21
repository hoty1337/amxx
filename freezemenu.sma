#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <saytext>

#define PLUGIN  "FreezeMenu"
#define VER     "0.1"
#define AUTHOR  "7heHex"

#define MAX_PLAYERS 32
#define PLAYERS_PER_PAGE 8
#define m_flNextAttack 83
#define linux_diff_player 5
#define TASK_ROUND_END 486787

#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

#pragma tabsize 2
#pragma semicolon 1

enum _:DATA_RENDERING
{
	RENDER_STATUS,
	RENDER_FX,
	RENDER_RED,
	RENDER_GREEN,
	RENDER_BLUE,
	RENDER_MODE,
	RENDER_AMT
}

new g_eUserRendering[MAX_PLAYERS + 1][DATA_RENDERING];
new g_iMaxPlayers;
new g_iMenuPlayers[MAX_PLAYERS + 1][MAX_PLAYERS], g_iMenuPosition[MAX_PLAYERS + 1];
new g_iBitUserFrozen;
new g_pModelGlass;

public plugin_init()
{
	register_plugin(PLUGIN, VER, AUTHOR);
	register_menucmd(register_menuid("Show_FreezeMenu"), 1023, "Handle_FreezeMenu");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");

	register_clcmd("freezemenu", "Cmd_FreezeMenu");
	g_iMaxPlayers = get_maxplayers();
}

public plugin_precache()
{
	g_pModelGlass = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl");
	engfunc(EngFunc_PrecacheSound, "freeze/freeze_player.wav");
	engfunc(EngFunc_PrecacheSound, "freeze/defrost_player.wav");
}

public LogEvent_RoundEnd()
{
	if(!task_exists(TASK_ROUND_END))
		set_task(0.1, "LogEvent_RoundEndTask", TASK_ROUND_END);
}

public LogEvent_RoundEndTask()
{
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(!is_user_connected(i)) continue;
		if(pev(i, pev_renderfx) != kRenderFxNone || pev(i, pev_rendermode) != kRenderNormal)
		{
			pub_set_user_rendering(i, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
		}
		if(g_iBitUserFrozen && IsSetBit(g_iBitUserFrozen, i))
		{
			ClearBit(g_iBitUserFrozen, i);
			set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
			set_pdata_float(i, m_flNextAttack, 0.0, linux_diff_player);
			emit_sound(i, CHAN_AUTO, "freeze/defrost_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			new Float:vecOrigin[3]; pev(i, pev_origin, vecOrigin);
			CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
		}
	}
}

public Cmd_FreezeMenu(id) return Show_FreezeMenu(id, g_iMenuPosition[id] = 0);
public Show_FreezeMenu(id, iPos)
{
	if(iPos < 0 || !(get_user_flags(id) & ADMIN_SLAY)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(!is_user_connected(i) || !is_user_alive(i) || i == id || get_user_flags(i) & ADMIN_IMMUNITY) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * (PLAYERS_PER_PAGE);
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / (PLAYERS_PER_PAGE);
	new iEnd = iStart + (PLAYERS_PER_PAGE);
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / (PLAYERS_PER_PAGE) + ((iPlayersNum % (PLAYERS_PER_PAGE)) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!g[SERVER] !yПодходящих игроков не найдено.");
			return PLUGIN_HANDLED;
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\yМеню заморозки \w[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		if(IsSetBit(g_iBitUserFrozen, i)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r%d\y] \d- \w%s \r[\yЗаморожен\r]^n", ++b, szName);
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r%d\y] \d- \w%s \r[\yРазморожен\r]^n", ++b, szName);
	}
	for(new i = b; i < (PLAYERS_PER_PAGE); i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[\r9\y] \d- \wДалее^n\y[\r0\y] \d- \w%s", iPos ? "Назад" : "Выход");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[\r0\y] \d- \w%s", iPos ? "Назад" : "Выход");
	return show_menu(id, iKeys, szMenu, -1, "Show_FreezeMenu");
}

public Handle_FreezeMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_FreezeMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_FreezeMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * (PLAYERS_PER_PAGE) + iKey];
			new name[32], targetName[32];
			get_user_name(id, name, 31);
			get_user_name(iTarget, targetName, 31);
			InvertBit(g_iBitUserFrozen, iTarget);
			if(IsSetBit(g_iBitUserFrozen, iTarget))
			{
				set_pev(iTarget, pev_flags, pev(iTarget, pev_flags) | FL_FROZEN);
				set_pdata_float(iTarget, m_flNextAttack, 6.0, linux_diff_player);
				pub_set_user_rendering(iTarget, kRenderFxGlowShell, 0, 110, 255, kRenderNormal, 0);
				emit_sound(iTarget, CHAN_AUTO, "freeze/freeze_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				set_pev(iTarget, pev_flags, pev(iTarget, pev_flags) & ~FL_FROZEN);
				set_pdata_float(iTarget, m_flNextAttack, 0.0, linux_diff_player);
				if(g_eUserRendering[iTarget][RENDER_STATUS]) pub_set_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
				else pub_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
				emit_sound(iTarget, CHAN_AUTO, "freeze/defrost_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				new Float:vecOrigin[3]; pev(iTarget, pev_origin, vecOrigin);
				CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
			}
			UTIL_SayText(0, "!g[SERVER] !yИгрок !g%s !y%s игрока !t%s!y.", name, (IsSetBit(g_iBitUserFrozen, iTarget) ? "заморозил" : "разморозил"), targetName);
		}
	}
	return Show_FreezeMenu(id, g_iMenuPosition[id]);
}

public pub_set_user_rendering(pPlayer, iRenderFx, iRed, iGreen, iBlue, iRenderMode, iRenderAmt)
{
	new Float:flRenderColor[3];
	flRenderColor[0] = float(iRed);
	flRenderColor[1] = float(iGreen);
	flRenderColor[2] = float(iBlue);
	set_pev(pPlayer, pev_renderfx, iRenderFx);
	set_pev(pPlayer, pev_rendercolor, flRenderColor);
	set_pev(pPlayer, pev_rendermode, iRenderMode);
	set_pev(pPlayer, pev_renderamt, float(iRenderAmt));
}

stock CREATE_BREAKMODEL(Float:vecOrigin[3], Float:vecSize[3] = {16.0, 16.0, 16.0}, Float:vecVelocity[3] = {25.0, 25.0, 25.0}, iRandomVelocity, pModel, iCount, iLife, iFlags)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BREAKMODEL);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 24);
	engfunc(EngFunc_WriteCoord, vecSize[0]);
	engfunc(EngFunc_WriteCoord, vecSize[1]);
	engfunc(EngFunc_WriteCoord, vecSize[2]);
	engfunc(EngFunc_WriteCoord, vecVelocity[0]);
	engfunc(EngFunc_WriteCoord, vecVelocity[1]);
	engfunc(EngFunc_WriteCoord, vecVelocity[2]);
	write_byte(iRandomVelocity);
	write_short(pModel);
	write_byte(iCount); // 0.1's
	write_byte(iLife); // 0.1's
	write_byte(iFlags); // BREAK_GLASS 0x01, BREAK_METAL 0x02, BREAK_FLESH 0x04, BREAK_WOOD 0x08
	message_end();
}