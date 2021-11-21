#include <amxmodx>
#include <fakemeta>
#include <sqlx>

#define PLUGIN_NAME		"iHOOK"
#define PLUGIN_AUTHOR	"arttty7"
#define PLUGIN_VERSION	"1.0"

#pragma tabsize 			0
#pragma semicolon 			1

#define NUM_ITEM_PAGE 		7
#define TASK_iHOOK 			423578453

// #define JBE					// Закоментируйте "//", если вам не нужна привязка к JBE (Подходит к: Ar4Mode, UJBL)
#define JBM					// Закоментируйте "//", если вам не нужна привязка к JBM
#define SAVE_HOOK				// Закоментируйте "//", если вам не нужно сохранение

#if defined JBE
	native jbe_is_user_wanted(pPlayer);
	native jbe_get_day_mode();
#endif

#if defined JBM
	native jbm_is_user_wanted(pPlayer);
	native jbm_get_day_mode();
	native jbm_is_gm_myaso();
	native jbm_is_gg();
	native jbm_get_boxing_status();
#endif

enum _:HOOK_SETTINGS
{
	SPRITE,
	SOUND,
	TIP,
	SIZE,
	VIEW,
	SPEED
}

enum _: DATA_FLAGS
{
	FLAG_HOOK[2],
	FLAG_MENU[2],
	FLAG_CONTROLE[2],
	FLAG_MODE[2]
}

enum _:DATA_HOOK
{
	NAME[42],
	FLAG[2],
	FILE[64],
	TYPE[2],
	VALUE
}

enum GLOBAL_SET
{
	GIVE,	
	WANTED	
}

new g_MaxPlayers; 
new g_HookUserSett[33][HOOK_SETTINGS];
new g_PlayerPageMenu[33], g_SettingsMenu[33];
new Array:g_aHook[6], Float:g_vecHookOrigin[33][3];
new g_aSize[HOOK_SETTINGS], g_DataFlag[DATA_FLAGS];
new bool:g_HookUserHave[33], bool:g_ModeHook = true;
new g_PlayersMenu[33][32], g_Hook[GLOBAL_SET];
new g_iPlayerHookCnt[33];

#if defined SAVE_HOOK
	new g_szPlayerSteam[33][34], g_szQuery[512]; 
	new Handle:g_SqlTuple;
	new g_szSaveSqlTable[32];
	new g_szSaveSqlUser[32];
	new g_szSaveSqlPassword[32]; 
	new g_szSaveSqlHost[32];
	new g_szSaveSqlDataBase[32];
#endif	

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_dictionary("iHOOK/iHOOK.txt");
	g_MaxPlayers = get_maxplayers();
	
	register_clcmd("+rope", "iHook_On");
	register_clcmd("-rope", "iHook_Off");
	register_clcmd("+hook", "iHook_On");
	register_clcmd("-hook", "iHook_Off");
	register_clcmd("say /hook", "iHook_Menu");
	
	register_menucmd(register_menuid("Show_iHookMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<9), "Handle_iHookMenu");
	register_menucmd(register_menuid("Show_SettingsHookMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SettingsHookMenu");
	register_menucmd(register_menuid("Show_ControleHookMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ControleHookMenu");
}

public client_putinserver(id) 
{
#if defined SAVE_HOOK	
	if(get_user_flags(id) & read_flags(g_DataFlag[FLAG_MENU]) || !g_DataFlag[FLAG_MENU])
	{
		new iParams[1];
		iParams[0] = id;
		get_user_authid(id, g_szPlayerSteam[id], charsmax(g_szPlayerSteam[]));
		format(g_szQuery, charsmax(g_szQuery), "SELECT * FROM `%s` WHERE (`%s`.`STEAM_ID` = '%s')", g_szSaveSqlTable, g_szSaveSqlTable, g_szPlayerSteam[id]);
		SQL_ThreadQuery(g_SqlTuple, "SQL_QueryConnection", g_szQuery, iParams, sizeof iParams);
	}
#endif	
	if(get_user_flags(id) & read_flags(g_DataFlag[FLAG_HOOK]) || !g_DataFlag[FLAG_HOOK])
		g_HookUserHave[id] = true;
	g_iPlayerHookCnt[id] = 0;
}

public client_disconnected(id)
{
#if defined SAVE_HOOK
	if(get_user_flags(id) & read_flags(g_DataFlag[FLAG_MENU]) || !g_DataFlag[FLAG_MENU])
	{
		formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `SPRITE` = '%d', `SOUND` = '%d', `TIP` = '%d', `SIZE` = '%d', `VIEW` = '%d', `SPEED` = '%d' WHERE `%s`.`STEAM_ID` = '%s';", 
		g_szSaveSqlTable, g_HookUserSett[id][SPRITE], g_HookUserSett[id][SOUND], g_HookUserSett[id][TIP], g_HookUserSett[id][SIZE], g_HookUserSett[id][VIEW], g_HookUserSett[id][SPEED], g_szSaveSqlTable, g_szPlayerSteam[id]);
		SQL_ThreadQuery(g_SqlTuple, "ThreadQueryHandler", g_szQuery);
	}	
#endif	
	for(new i; i < HOOK_SETTINGS; i++)
		g_HookUserSett[id][i] = 0;
	
	g_PlayerPageMenu[id] = 0;
	g_SettingsMenu[id] = 0;
	for(new i; i < 3; i++)
		g_vecHookOrigin[id][i] = 0.0;
	
	if(task_exists(id+TASK_iHOOK))
		remove_task(id+TASK_iHOOK);
	
	if(g_HookUserHave[id])
		g_HookUserHave[id] = false;
#if defined SAVE_HOOK	
	g_szPlayerSteam[id] = "";
#endif		
	g_iPlayerHookCnt[id] = 0;
}

public iHook_Menu(id)
{
	if(get_user_flags(id) & read_flags(g_DataFlag[FLAG_MENU]) || !g_DataFlag[FLAG_MENU]) return Show_iHookMenu(id);
	UTIL_SendText(id, "%L", LANG_SERVER, "iHOOK_CHAT_YOU_NOT_HAVE_FLAG_MENU");
	return PLUGIN_HANDLED;
}	
Show_iHookMenu(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<9), iLen, aData[HOOK_SETTINGS][DATA_HOOK];
	for(new i; i < HOOK_SETTINGS; i++)
		ArrayGetArray(g_aHook[i], g_HookUserSett[id][i], aData[i]);

	iLen = formatex(szMenu, charsmax(szMenu), "%L", id, "iHOOK_MENU_HOOK_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_HOOK_SPRITES", aData[SPRITE][NAME]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_HOOK_SOUNDS", aData[SOUND][NAME]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_HOOK_TIPS", aData[TIP][NAME]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_HOOK_SIZE", aData[SIZE][NAME]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_HOOK_VIEW", aData[VIEW][NAME]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_HOOK_SPEED", aData[SPEED][NAME]);
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_HOOK_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_iHookMenu");
}

public Handle_iHookMenu(id, iKey)
{
	switch(iKey)
	{
		case 9: return PLUGIN_HANDLED;
		default: 
		{
			g_SettingsMenu[id] = iKey;
			return Clcmd_SettingsHookMenu(id);
		}	
	}
	return Show_iHookMenu(id);
}

public Clcmd_SettingsHookMenu(id) return Show_SettingsHookMenu(id, g_SettingsMenu[id], g_PlayerPageMenu[id] = 0);
Show_SettingsHookMenu(id, iType, iPos)
{
	if(iPos < 0)
		return Show_iHookMenu(id);
	
	new const szMenuHookSettingsTitle[][] =
	{
		"iHOOK_MENU_SETTINGS_SPRITE",
		"iHOOK_MENU_SETTINGS_SOUND",
		"iHOOK_MENU_SETTINGS_TIP",
		"iHOOK_MENU_SETTINGS_SIZE",
		"iHOOK_MENU_SETTINGS_VIEW",
		"iHOOK_MENU_SETTINGS_SPEED"
	};
	
	new iStart = iPos * NUM_ITEM_PAGE;
	new iListSize = g_aSize[iType] <= NUM_ITEM_PAGE ? g_aSize[iType] - 1 : g_aSize[iType];
	if(iStart > iListSize) iStart = iListSize;
	iStart = iStart - (iStart % NUM_ITEM_PAGE);
	g_PlayerPageMenu[id] = iStart / NUM_ITEM_PAGE;
	new iEnd = iStart + NUM_ITEM_PAGE;
	if(iEnd > iListSize) iEnd = iListSize + (iPos ? 0 : 1);
	new szMenu[512], iLen, iPagesNum = (iListSize / NUM_ITEM_PAGE + ((iListSize % NUM_ITEM_PAGE) ? 1 : 0));
	iLen = formatex(szMenu, charsmax(szMenu), "%L", id, szMenuHookSettingsTitle[iType], iPos + 1, iPagesNum);
	new iKeys = (1<<7|1<<9), b, aDataHook[DATA_HOOK];
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aHook[iType], a, aDataHook);
		if(~get_user_flags(id) & read_flags(aDataHook[FLAG]))
			++b, iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_NO_FLAGS", aDataHook[NAME]);
		else if(g_HookUserSett[id][iType] == a)
			++b, iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_ON", aDataHook[NAME]);
		else 
		{
			iKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_KEY", ++b, aDataHook[NAME]);
		}
	}
	for(new i = b; i < NUM_ITEM_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, iPos ? "iHOOK_MENU_BACK" : "iHOOK_MENU_BACK_MENU");
	if(iEnd < iListSize)
	{
		iKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_NEXT_CLOSE");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SettingsHookMenu");
}

public Handle_SettingsHookMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Show_SettingsHookMenu(id, g_SettingsMenu[id], --g_PlayerPageMenu[id]);
		case 8: return Show_SettingsHookMenu(id, g_SettingsMenu[id], ++g_PlayerPageMenu[id]);
		case 9: return PLUGIN_HANDLED;
		default: g_HookUserSett[id][g_SettingsMenu[id]] = g_PlayerPageMenu[id] * NUM_ITEM_PAGE + iKey;
	}
	return Show_SettingsHookMenu(id, g_SettingsMenu[id], g_PlayerPageMenu[id]);
}

public Clcmd_ControleHookMenu(id) return Show_ControleHookMenu(id, g_PlayerPageMenu[id] = 0);
Show_ControleHookMenu(id, iPos)
{
	if(iPos < 0 || ~get_user_flags(id) & read_flags(g_DataFlag[FLAG_CONTROLE])) 
		return Show_iHookMenu(id);
	
	new iPlayersNum;
	for(new i = 1; i <= g_MaxPlayers; i++)
	{
		if(!is_user_connected(i) || get_user_team(i) != 1 && get_user_team(i) != 2) 
			continue;
		
		g_PlayersMenu[id][iPlayersNum++] = i;
	}
	new iStart = iPos * NUM_ITEM_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % NUM_ITEM_PAGE);
	g_PlayerPageMenu[id] = iStart / NUM_ITEM_PAGE;
	new iEnd = iStart + NUM_ITEM_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / NUM_ITEM_PAGE + ((iPlayersNum % NUM_ITEM_PAGE) ? 1 : 0));
	iLen = formatex(szMenu, charsmax(szMenu), "%L", id, "iHOOK_MENU_HOOK_CONTROLE_TITLE", iPos + 1, iPagesNum);
	new szName[32], i, iKeys = (1<<7|1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_PlayersMenu[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", i, g_HookUserHave[i] ? "iHOOK_PLAYER_HOOK_TAKE" : "iHOOK_PLAYER_HOOK_GIVE", ++b, szName);
	}
	for(new i = b; i < NUM_ITEM_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, iPos ? "iHOOK_MENU_BACK" : "iHOOK_MENU_BACK_MENU");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_NEXT_CLOSE");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L", id, "iHOOK_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ControleHookMenu");
}

public Handle_ControleHookMenu(id, iKey)
{
	if(~get_user_flags(id) & read_flags(g_DataFlag[FLAG_CONTROLE])) 
		return Show_iHookMenu(id);
	
	switch(iKey)
	{
		case 7: return Show_ControleHookMenu(id, --g_PlayerPageMenu[id]);
		case 8: return Show_ControleHookMenu(id, ++g_PlayerPageMenu[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_PlayersMenu[id][g_PlayerPageMenu[id] * NUM_ITEM_PAGE + iKey];
			if(get_user_team(iTarget) == 1 || get_user_team(iTarget) == 2)
			{
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				
				UTIL_SendText(0, "%L", LANG_SERVER, g_HookUserHave[iTarget] ? "iHOOK_CHAT_HOOK_PLAYER_TAKE" : "iHOOK_CHAT_HOOK_PLAYER_GIVE", szName, szTargetName);
				g_HookUserHave[iTarget] = !g_HookUserHave[iTarget];
				
				if(g_Hook[GIVE])
					for(new i; i < HOOK_SETTINGS; i++)
						g_HookUserSett[iTarget][i] = g_HookUserSett[id][i];
			}
		}
	}
	return Show_ControleHookMenu(id, g_PlayerPageMenu[id]);
}

public iHook_On(id)
{
	if(!g_HookUserHave[id] && g_iPlayerHookCnt[id] == 0)
	{
		UTIL_SendText(id, "%L", LANG_SERVER, "iHOOK_CHAT_YOU_NOT_HAVE_FLAG_HOOK");
		return PLUGIN_HANDLED;
	}
	else if(!g_ModeHook)
	{
		UTIL_SendText(id, "%L", id, "iHOOK_CHAT_HOOK_MODE_NOT_WORK");
		return PLUGIN_HANDLED;
	}
	
#if defined JBE
	if(jbe_is_user_wanted(id) && g_Hook[WANTED] || is_wanted_players() && !g_Hook[WANTED] || jbe_get_day_mode() == 3)
		return PLUGIN_HANDLED;
#endif
	
#if defined JBM
	if(jbm_is_user_wanted(id) && g_Hook[WANTED] || is_wanted_players() && !g_Hook[WANTED] || jbm_get_day_mode() == 3 || jbm_is_gm_myaso() || jbm_get_boxing_status() || jbm_is_gg())
		return PLUGIN_HANDLED;
#endif	
	
	if(!is_user_alive(id) || task_exists(id+TASK_iHOOK)) 
		return PLUGIN_HANDLED;
	
	new iOrigin[3], aDataSound[DATA_HOOK], aDataTip[DATA_HOOK];
	ArrayGetArray(g_aHook[1], g_HookUserSett[id][SOUND], aDataSound);
	ArrayGetArray(g_aHook[2], g_HookUserSett[id][TIP], aDataTip);
	get_user_origin(id, iOrigin, 3);
	g_vecHookOrigin[id][0] = float(iOrigin[0]);
	g_vecHookOrigin[id][1] = float(iOrigin[1]);
	g_vecHookOrigin[id][2] = float(iOrigin[2]);
	if(str_to_num(aDataTip[TYPE]) > 0)
		UTIL_CreateTipeNormal(g_vecHookOrigin[id], aDataTip[VALUE], 10, 255);
	else 
		UTIL_CreateTipeBreak(g_vecHookOrigin[id], aDataTip[VALUE]);
	
	emit_sound(id, CHAN_STATIC, aDataSound[FILE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	iHook_task(id+TASK_iHOOK);
	if(g_iPlayerHookCnt[id] > 0) UTIL_SendText(id, "!g[JBM] !yУ вас осталось !t%d !yпаутинок.", --g_iPlayerHookCnt[id]);
	set_task(0.1, "iHook_task", id+TASK_iHOOK, _, _, "b");
	return PLUGIN_HANDLED;
}

public iHook_task(id)
{
	id -= TASK_iHOOK;
	
#if defined JBE
	if(jbe_is_user_wanted(id))
		remove_task(id+TASK_iHOOK);
#endif		
	
#if defined JBM
	if(jbm_is_user_wanted(id))
		remove_task(id+TASK_iHOOK);
#endif	
	
	new Float:vecOrigin[3], Float:vecVelocity[3], Float:flY, Float:flX;
	pev(id, pev_origin, vecOrigin);
	vecVelocity[0] = (g_vecHookOrigin[id][0] - vecOrigin[0]) * 3.0;
	vecVelocity[1] = (g_vecHookOrigin[id][1] - vecOrigin[1]) * 3.0;
	vecVelocity[2] = (g_vecHookOrigin[id][2] - vecOrigin[2]) * 3.0;
	
	new aDataSpeed[DATA_HOOK], aDataSize[DATA_HOOK], aDataView[DATA_HOOK], aDataSprite[DATA_HOOK];
	ArrayGetArray(g_aHook[0], g_HookUserSett[id][SPRITE], aDataSprite);
	ArrayGetArray(g_aHook[3], g_HookUserSett[id][SIZE], aDataSize);
	ArrayGetArray(g_aHook[4], g_HookUserSett[id][VIEW], aDataView);
	ArrayGetArray(g_aHook[5], g_HookUserSett[id][SPEED], aDataSpeed);
	
	flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
	flX = (5 * float(aDataSpeed[VALUE])) / floatsqroot(flY);
	
	vecVelocity[0] *= flX;
	vecVelocity[1] *= flX;
	vecVelocity[2] *= flX;
	set_pev(id, pev_velocity, vecVelocity);
	
	UTIL_CreateHook(id, g_vecHookOrigin[id], aDataSprite[VALUE], 0, 1, 1, aDataSize[VALUE], aDataView[VALUE], 255, 255, 255, 210, _);
}

public iHook_Off(id)
{
	if(task_exists(id+TASK_iHOOK))
	{
		new aDataSound[DATA_HOOK];
		ArrayGetArray(g_aHook[1], g_HookUserSett[id][SOUND], aDataSound);
		remove_task(id+TASK_iHOOK);
		emit_sound(id, CHAN_STATIC, aDataSound[FILE], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	}
	return PLUGIN_HANDLED;
}

public plugin_cfg()
{
	new szCfgDir[64], szCfgFile[128];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	formatex(szCfgFile, charsmax(szCfgFile), "%s/iHOOK/hook_config.ini", szCfgDir);
	if(!file_exists(szCfgFile))
	{
		new szError[256];
		formatex(szError, charsmax(szError), "[iHOOK] Невозможно запустить сервер. Отсутсвует файл: %s!", szCfgFile);
		set_fail_state(szError);
		return;
	}
	new szBuffer[512], szKey[64], szValue[64], iSection;
	new aDataSprite[DATA_HOOK], aDataSound[DATA_HOOK], aDataTip[DATA_HOOK], aDataSize[DATA_HOOK], aDataView[DATA_HOOK], aDataSpeed[DATA_HOOK];
	new iFile = fopen(szCfgFile, "rt");
	
	for(new i; i < HOOK_SETTINGS; i++)
		g_aHook[i] = ArrayCreate(DATA_HOOK);
	
	while(!feof(iFile))
	{
		fgets(iFile, szBuffer, charsmax(szBuffer));
		if(szBuffer[0] == ';' || szBuffer[0] == '{' || szBuffer[0] == '}' || szBuffer[0] == '/' || szBuffer[0] == '@' || szBuffer[0] == '#')
			continue;
		
		if(szBuffer[0] == '[')
		{
			iSection++;
			continue;
		}
		switch(iSection)
		{
			case 1:
			{
				parse(szBuffer, szKey, charsmax(szKey), szValue, charsmax(szValue));
				trim(szKey);
				trim(szValue);
				if(equal(szKey, "FLAG_HOOK")) 			copy(g_DataFlag[FLAG_HOOK], 	charsmax(g_DataFlag[FLAG_HOOK]), 		szValue);
				else if(equal(szKey, "FLAG_MENU")) 		copy(g_DataFlag[FLAG_MENU], 	charsmax(g_DataFlag[FLAG_MENU]), 		szValue);
				else if(equal(szKey, "FLAG_CONTROLE")) 	copy(g_DataFlag[FLAG_CONTROLE], charsmax(g_DataFlag[FLAG_CONTROLE]), 	szValue);
				else if(equal(szKey, "FLAG_MODE")) 		copy(g_DataFlag[FLAG_MODE], 	charsmax(g_DataFlag[FLAG_MODE]), 		szValue);
				else if(equal(szKey, "WANTED_HOOK")) 	g_Hook[WANTED]					= str_to_num(szValue);
				else if(equal(szKey, "HOOK_GIVE")) 		g_Hook[GIVE]					= str_to_num(szValue);
			#if defined SAVE_HOOK
				else if(equal(szKey, "HOST"))			copy(g_szSaveSqlHost, 		charsmax(g_szSaveSqlHost), 			szValue);
				else if(equal(szKey, "USER")) 			copy(g_szSaveSqlUser, 		charsmax(g_szSaveSqlUser), 			szValue);
				else if(equal(szKey, "PASSWORD"))		copy(g_szSaveSqlPassword, 	charsmax(g_szSaveSqlPassword), 		szValue);
				else if(equal(szKey, "DATABASE"))		copy(g_szSaveSqlDataBase, 	charsmax(g_szSaveSqlDataBase), 		szValue);
				else if(equal(szKey, "TABLE"))			copy(g_szSaveSqlTable, 		charsmax(g_szSaveSqlTable), 		szValue);
			#endif
			}
			case 2: 
			{
				if(parse(szBuffer, aDataSprite[NAME], charsmax(aDataSprite[NAME]), aDataSprite[FILE], charsmax(aDataSprite[FILE]), aDataSprite[FLAG], charsmax(aDataSprite[FLAG])))
				{
					if(aDataSprite[FILE])
					{
						aDataSprite[VALUE] = engfunc(EngFunc_PrecacheModel, aDataSprite[FILE]);
						ArrayPushArray(g_aHook[0], aDataSprite);	
					}
				}
			}
			case 3: 
			{
				if(parse(szBuffer, aDataSound[NAME], charsmax(aDataSound[NAME]), aDataSound[FILE], charsmax(aDataSound[FILE]), aDataSound[FLAG], charsmax(aDataSound[FLAG])))
				{
					if(aDataSound[FILE])
					{
						engfunc(EngFunc_PrecacheSound, aDataSound[FILE]);
						ArrayPushArray(g_aHook[1], aDataSound);
					}
				}	
			}
			case 4:
			{
				if(parse(szBuffer, aDataTip[NAME], charsmax(aDataTip[NAME]), aDataTip[FILE], charsmax(aDataTip[FILE]), aDataTip[FLAG], charsmax(aDataTip[FLAG]), aDataTip[TYPE], charsmax(aDataTip[TYPE])))
				{
					if(aDataTip[FILE])
					{
						aDataTip[VALUE] = engfunc(EngFunc_PrecacheModel, aDataTip[FILE]);
						ArrayPushArray(g_aHook[2], aDataTip);	
					}
				}
			}
			case 5:
			{
				if(parse(szBuffer, aDataSize[NAME], charsmax(aDataSize[NAME]), szValue, charsmax(szValue), aDataSize[FLAG], charsmax(aDataSize[FLAG])))
				{
					aDataSize[VALUE] = str_to_num(szValue);
					ArrayPushArray(g_aHook[3], aDataSize);
				}
			}
			case 6:
			{
				if(parse(szBuffer, aDataView[NAME], charsmax(aDataView[NAME]), szValue, charsmax(szValue), aDataView[FLAG], charsmax(aDataView[FLAG])))
				{
					aDataView[VALUE] = str_to_num(szValue);
					ArrayPushArray(g_aHook[4], aDataView);
				}
			}
			case 7:
			{
				if(parse(szBuffer, aDataSpeed[NAME], charsmax(aDataSpeed[NAME]), szValue, charsmax(szValue), aDataSpeed[FLAG], charsmax(aDataSpeed[FLAG])))
				{
					aDataSpeed[VALUE] = str_to_num(szValue);
					ArrayPushArray(g_aHook[5], aDataSpeed);
				}
			}
		}	
	}
	fclose(iFile);
	for(new i; i < HOOK_SETTINGS; i++)
		g_aSize[i] = ArraySize(g_aHook[i]);	
	
//#if defined SAVE_HOOK	
	//iHook_SqlLoad();
//#endif	
}

#if defined SAVE_HOOK
public fbans_sql_connected(Handle:sqlTuple)
{ 
	g_SqlTuple = sqlTuple; 
	SQL_SetCharset(g_SqlTuple, "utf8");
}

//public iHook_SqlLoad()
//{
	//new iErrorCode, szText[512];
	//g_SqlTuple 		= SQL_MakeDbTuple(g_szSaveSqlHost, g_szSaveSqlUser, g_szSaveSqlPassword, g_szSaveSqlDataBase);
	//g_SqlConnection = SQL_Connect(g_SqlTuple, iErrorCode, szText, charsmax(szText));

	//new Handle:hQueries;
	//format(g_szQuery, charsmax(g_szQuery), "CREATE TABLE IF NOT EXISTS `%s` (`id` INT(11) NOT NULL AUTO_INCREMENT, `STEAM_ID` VARCHAR(34) NOT NULL COLLATE 'utf8_unicode_ci', `SPRITE` INT NOT NULL, `SOUND` INT NOT NULL, `TIP` INT NOT NULL, `SIZE` INT NOT NULL, `VIEW` INT NOT NULL, `SPEED` INT NOT NULL, PRIMARY KEY (`id`)) COLLATE = 'utf8_unicode_ci' ENGINE = InnoDB;", g_szSaveSqlTable);
	//hQueries = SQL_PrepareQuery(g_SqlConnection, g_szQuery);
	//if(!SQL_Execute(hQueries)) 
	//{
	//	SQL_QueryError(hQueries, szText, charsmax(szText));
	//	log_amx("%s", szText);
	//}
	//SQL_FreeHandle(hQueries);
//}	

//public plugin_end() 
//{
	//if(g_SqlTuple) 
	//	SQL_FreeHandle(g_SqlTuple);
	
	//if(g_SqlConnection) 
		//SQL_FreeHandle(g_SqlConnection);
	
//	return 0;
//}	

public SQL_QueryConnection(iState, Handle:hQuery, const szError[], iErrorCode, const szData[], iDataSize)
{
	if(iState == TQUERY_CONNECT_FAILED || iState == TQUERY_QUERY_FAILED)
	{
		log_amx("[iHOOK] MySQL connection failed");
		log_amx("[iHOOK] ERROR %d | %s", iErrorCode, szError);
		if(iDataSize) log_amx("Query state: %d", szData[iState == TQUERY_CONNECT_FAILED ? 0 : 1]);
		return PLUGIN_HANDLED;
	}
	new id = szData[0];
	if(SQL_NumResults(hQuery) < 1)
	{
		if(equal(g_szPlayerSteam[id], "ID_PENDING"))
			return PLUGIN_HANDLED;
		
		format(g_szQuery, charsmax(g_szQuery), "INSERT INTO `%s` (`STEAM_ID`, `SPRITE`, `SOUND`, `TIP`, `SIZE`, `VIEW`, `SPEED`) VALUES ('%s', '0', '0', '0', '0', '0', '0');", g_szSaveSqlTable, g_szPlayerSteam[id]);
		SQL_ThreadQuery(g_SqlTuple, "ThreadQueryHandler", g_szQuery);
		return PLUGIN_HANDLED;
	}
	else
	{
		new const szDataSave[][] = { "SPRITE", "SOUND", "TIP", "SIZE", "VIEW", "SPEED" };
		for(new i, iNum; i < HOOK_SETTINGS; i++)
		{
			iNum = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, szDataSave[i]));
			g_HookUserSett[id][i] = (iNum <= g_aSize[i]) ? iNum : 0;
		}	
	}
	return PLUGIN_HANDLED;
}

public ThreadQueryHandler(iState, Handle: hQuery, szError[], iErrorCode, iParams[], iParamsSize)
{
	if(iState == 0)
		return;
	
	log_amx("SQL Error: %d (%s)", iErrorCode, szError);
}
#endif	

public plugin_natives()
{
	register_native("native_iHOOK_menu", "iHook_Menu", 1);
	register_native("native_iHOOK_get_hook_sett", "native_iHOOK_get_hook_sett", 1);
	register_native("native_iHOOK_get_hook_have", "native_iHOOK_get_hook_have", 1);
	register_native("give_hook", "test_cmd", 1);
	register_native("reset_hook", "test_reset", 1);
	register_native("hook_mod_on", "on_mod", 1);
	register_native("hook_mod_off", "off_mod", 1);
	register_native("give_hook_cnt", "give_hook_cnt", 1);
}

public give_hook_cnt(id, iCount)
{
	g_iPlayerHookCnt[id] += iCount;
}

public on_mod(id)
{
	g_ModeHook = true;
}

public off_mod(id)
{
	g_ModeHook = false;
}

public test_cmd(id)
{
	g_HookUserHave[id] = true;
}

public test_reset(id)
{
	g_HookUserHave[id] = false;
}

public native_iHOOK_get_hook_sett(id, iType) return g_HookUserSett[id][iType];
public bool:native_iHOOK_get_hook_have(id) return g_HookUserHave[id];

#if defined JBE	
stock is_wanted_players()
{
	new bool:iWanted;
	for(new iPlayer = 1; iPlayer <= g_MaxPlayers; iPlayer++)
	{	
		if(!jbe_is_user_wanted(iPlayer))
			continue;
		
		iWanted = true;
		break;
	}
	return iWanted;
}
#endif

#if defined JBM
stock is_wanted_players()
{
	new bool:iWanted;
	for(new iPlayer = 1; iPlayer <= g_MaxPlayers; iPlayer++)
	{	
		if(!jbm_is_user_wanted(iPlayer))
			continue;
		
		iWanted = true;
		break;
	}
	return iWanted;
}
#endif

stock UTIL_CreateTipeBreak(Float:vecOrigin[3], pModel)
{
	engfunc(EngFunc_MessageBegin, MSG_ALL, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITETRAIL);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 25);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 80);
	write_short(pModel);	
	write_byte(25);	// Колличество
	write_byte(20);	// Время
	write_byte(2);
	write_byte(20);	// Какой разброс
	write_byte(8);	// На сколько сильно подлетает
	message_end();
}

stock UTIL_CreateTipeNormal(Float:vecOrigin[3], pSptite, iWidth, iAlpha)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(pSptite);
	write_byte(iWidth);
	write_byte(iAlpha);
	message_end();
}

stock UTIL_CreateHook(pEntity, Float:vecOrigin[3], pSprite, iStartFrame = 0, iFrameRate = 0, iLife, iWidth, iAmplitude = 0, iRed, iGreen, iBlue, iBrightness, iScrollSpeed = 0)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT);
	write_short(pEntity);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(pSprite);
	write_byte(iStartFrame);
	write_byte(iFrameRate); // 0.1's
	write_byte(iLife); // 0.1's
	write_byte(iWidth);
	write_byte(iAmplitude); // 0.01's
	write_byte(iRed);
	write_byte(iGreen);
	write_byte(iBlue);
	write_byte(iBrightness);
	write_byte(iScrollSpeed); // 0.1's
	message_end();
}

stock UTIL_SendText(pPlayer, const szMessage[], any:...)
{
	new szBuffer[190];
	if(numargs() > 2) 
		vformat(szBuffer, charsmax(szBuffer), szMessage, 3);
	else 
		copy(szBuffer, charsmax(szBuffer), szMessage);
	while(replace(szBuffer, charsmax(szBuffer), "!y", "^1")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!t", "^3")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!g", "^4")) {}
	switch(pPlayer)
	{
		case 0:
		{
			for(new iPlayer = 1; iPlayer <= g_MaxPlayers; iPlayer++)
			{
				if(!is_user_connected(iPlayer)) 
					continue;
				
				engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, 76, {0.0, 0.0, 0.0}, iPlayer);
				write_byte(iPlayer);
				write_string(szBuffer);
				message_end();
			}
		}
		default:
		{
			engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, 76, {0.0, 0.0, 0.0}, pPlayer);
			write_byte(pPlayer);
			write_string(szBuffer);
			message_end();
		}
	}
}