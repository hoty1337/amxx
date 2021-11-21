#include 						<amxmodx>
#include 						<hamsandwich>
#include 						<fakemeta>
#include 						<fun>
#include 						<fvault>

#define PLUGIN 					"[ALL] Color Bubble Grab"
#define AUTHOR					"Edit By HOBOSTI & KOTOKU"
#define VERSION					"1.0"

#define BIT_ADD(%0,%1)			(%0 |= (1  <<  (%1 & 31)))
#define is_user_valid(%0) 		(0 < %0 <= g_iMaxPlayers) // Проверка на валидность игрока
#pragma semicolon 				1

#define FLAG 					ADMIN_LEVEL_F // флаг Граба: r
#define FVAULT_NAME				"COLOR_BUBBLE"

// Grab Class
enum _:DATA_GRAB { GRABBED = 0, GRABBER, GRAB_LEN, FLAGS };
new pClientData[33][DATA_GRAB];
new Array:g_iBubbleEntity;
new g_pModelBubble;
new g_iMaxPlayers;

// Client Class
new g_iColorBubble[33];				// Цвет пузыря

public plugin_precache()
	g_pModelBubble = engfunc(EngFunc_PrecacheModel, "models/color_bubble/color_bubble.mdl");

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	// Команды
	register_clcmd("+grab", 			"Command_Grab");
	register_clcmd("-grab", 			"Command_UnGrab");
	register_clcmd("+push", 			"Command_Push");
	register_clcmd("-push", 			"Command_Push");
	register_clcmd("+pull", 			"Command_Pull");
	register_clcmd("-pull",				"Command_Pull");
	register_clcmd("drop",				"Command_Drop");
	register_clcmd("color_bubble",		"Show_ColorBubble");
	
	// События
	RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled_Post", 1);
	register_forward(FM_PlayerPreThink, "FakeMeta_PreThink");
	
	// Работа с меню
	register_menucmd(register_menuid("Show_ColorBubble"), 1023, "Handle_ColorBubble");

	// Получаем данные
	g_iMaxPlayers = get_maxplayers();
	
	// Создаем Array для Энтити
	g_iBubbleEntity = ArrayCreate();
}

public client_putinserver(id)
{
	//g_iColorBubble[id] = 0;
	if(!is_user_hltv(id) && !is_user_bot(id))
		LoadColor(id);
}

LoadColor(id)
{
	// Создаем массив для вычисления нашего STEAM ID.
    new iAuth[35]; get_user_authid(id, iAuth, sizeof(iAuth) - 1);
	
	// Создаем массив для получения данных из файла
    new iData[16];
	
	// fvault_get_data(Имя файла, откуда все берем (FVAULT_NAME), Наш ключ, в нашем случае STEAM ID (iAuth), Наше хранилище, если есть данные ебашим (iData), размер массива);
	
	// Прверяем есть ли данные, если есть завозим сюда.
    if(fvault_get_data(FVAULT_NAME, iAuth, iData, sizeof(iData) - 1)) g_iColorBubble[id] = str_to_num(iData);
    else g_iColorBubble[id] = 0;
}

public client_disconnect(id)
{
	SaveColor(id);
	if(pClientData[id][GRABBED]) 		Command_UnGrab(id);
	else if(pClientData[id][GRABBER]) 	Command_UnGrab(pClientData[id][GRABBER]);
}

SaveColor(id)
{
	// Создаем массив для храения нашего STEAM ID.
    new iAuth[35];
    get_user_authid(id, iAuth, sizeof(iAuth) - 1);
    
	// Создаем массив для хранения нашего бабла, и преобразуем g_iColorBubble из числа в строку (Так надо нахуй).
    new iData[16];
    num_to_str(g_iColorBubble[id], iData, sizeof(iData) - 1);
    
	// fvault_set_data(Имя файла, куда всё сохраняем (FVAULT_NAME), Ключ по чему будет сохранаять STEAM ID (iAuth), Данные для установки в iData (iData));
	
	// Сохраняем наш опыт.
    fvault_set_data(FVAULT_NAME, iAuth, iData);
}

public Command_Grab(id)
{
	if(~get_user_flags(id) & FLAG)
	{
		UTIL_SayText(id, "!y[!gError!y] У вас недостаточно прав для использования !tGRAB");
		return PLUGIN_HANDLED;
	}
	if(!pClientData[id][GRABBED]) pClientData[id][GRABBED] = -1;
	return PLUGIN_HANDLED;
}

public Command_UnGrab(id)
{
	new iTarget = pClientData[id][GRABBED];
	if(iTarget > 0 && pev_valid(iTarget))
	{
		if(is_user_valid(iTarget))
		{
			ADD_BUBBLE(iTarget, id, false);
			pClientData[iTarget][GRABBER] = 0;
			show_menu(id, 0, "^n");
		}
		else ADD_BUBBLE(iTarget, id, false);
	}
	pClientData[id][GRABBED] = 0;
	return PLUGIN_HANDLED;
}

public Command_Push(id)
{
	pClientData[id][FLAGS] ^= (1<<0);
	return PLUGIN_HANDLED;
}

public Command_Pull(id)
{
	pClientData[id][FLAGS] ^= (1<<1);
	return PLUGIN_HANDLED;
}

public Command_Drop(id)
{
	if(pClientData[id][GRABBED] > 0)
	{
		set_pev(pClientData[id][GRABBED], pev_velocity, vel_by_aim(id, 1500));
		Command_UnGrab(id);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public Ham_PlayerKilled_Post(iVictim)
{
	if(pClientData[iVictim][GRABBED]) Command_UnGrab(iVictim);
	else if(pClientData[iVictim][GRABBER]) Command_UnGrab(pClientData[iVictim][GRABBER]);
}

public FakeMeta_PreThink(id)
{
	new iTarget;
	iTarget = pClientData[id][GRABBED];
	if(pClientData[id][GRABBED] == -1)
	{
		new Float:orig[3], Float:ret[3];
		get_view_pos(id, orig);
		ret = vel_by_aim(id, 9999);
		ret[0] += orig[0];
		ret[1] += orig[1];
		ret[2] += orig[2];
		iTarget = traceline(orig, ret, id, ret);
		if(is_user_valid(iTarget) && is_user_alive(iTarget))
		{
			if(IsGrabbed(iTarget, id)) return FMRES_IGNORED;
			set_grabbed(id, iTarget);
		}
		else
		{
			new iMoveType;
			if(iTarget && pev_valid(iTarget))
			{
				iMoveType = pev(iTarget, pev_movetype);
				if(!(iMoveType == MOVETYPE_WALK || iMoveType == MOVETYPE_STEP || iMoveType == MOVETYPE_TOSS)) { return FMRES_IGNORED; }
			}
			else
			{
				iTarget = 0;
				new iEnt = engfunc(EngFunc_FindEntityInSphere, -1, ret, 12.0);
				while(!iTarget && iEnt > 0)
				{
					iMoveType = pev(iEnt, pev_movetype);
					if((iMoveType == MOVETYPE_WALK || iMoveType == MOVETYPE_STEP || iMoveType == MOVETYPE_TOSS) && iEnt != id) { iTarget = iEnt; }
					iEnt = engfunc(EngFunc_FindEntityInSphere, iEnt, ret, 12.0);
				}
			}	
			if(iTarget)
			{
				if(IsGrabbed(iTarget, id)) return FMRES_IGNORED;
				set_grabbed(id, iTarget);
			}
		}
	}
	
	// Длинна
	if(iTarget > 0)
	{
		if(!pev_valid(iTarget) || (pev(iTarget, pev_health) < 1 && pev(iTarget, pev_max_health)))
		{
			Command_UnGrab(id);
			return FMRES_IGNORED;
		}
		
		if(iTarget > g_iMaxPlayers) 
			grab_think(id);
	}
	
	iTarget = pClientData[id][GRABBER];
	if(iTarget > 0) grab_think(iTarget);
	
	return FMRES_IGNORED;
}

public set_grabbed(id, iTarget)
{
	// Дистанция между игроками
	pClientData[id][FLAGS] = 0;
	pClientData[id][GRABBED] = iTarget;
	new Float:torig[3], Float:orig[3];
	pev(iTarget, pev_origin, torig);
	pev(id, pev_origin, orig);
	pClientData[id][GRAB_LEN] = floatround(get_distance_f(torig, orig));
	if(pClientData[id][GRAB_LEN] < 90) pClientData[id][GRAB_LEN] = 90;
	
	// Установка шарика (пузыря)
	ADD_BUBBLE(iTarget, id, true);
	
	// Уведамление в чат
	new szName[32]; get_user_name(id, szName, charsmax(szName));
	if(is_user_valid(iTarget))
	{
		new szName2[32];
		get_user_name(iTarget, szName2, charsmax(szName2));
		pClientData[iTarget][GRABBER] = id;
		UTIL_SayText(0, "!y[!gGRAB!y] !yИгрок !t%s !yвзял грабом !t%s", szName, szName2);
		// Переход в меню для игрока -> ... (Show_PlayerMenu(id))
	}
	else UTIL_SayText(0, "!y[!gGRAB!y] !yИгрок !t%s !yвзял грабом !tоружие", szName);
	return PLUGIN_HANDLED;
}

public grab_think(id)
{
	new iTarget = pClientData[id][GRABBED];
	if(pev(iTarget, pev_movetype) == MOVETYPE_FLY && !(pev(iTarget, pev_button) & IN_JUMP)) client_cmd(iTarget, "+jump;wait;-jump");
	new Float:tmpvec[3], Float:tmpvec2[3], Float:torig[3], Float:tvel[3];
	
	get_view_pos(id, tmpvec);
	
	tmpvec2 = vel_by_aim(id, pClientData[id][GRAB_LEN]);
	
	torig = get_target_origin_f(iTarget);
	
	tvel[0] = ((tmpvec[0] + tmpvec2[0]) - torig[0]) * 8;
	tvel[1] = ((tmpvec[1] + tmpvec2[1]) - torig[1]) * 8;
	tvel[2] = ((tmpvec[2] + tmpvec2[2]) - torig[2]) * 8;
	
	set_pev(iTarget, pev_velocity, tvel);
}

public ADD_BUBBLE(id, iGrabber, bool:bUsed)
{
	switch(bUsed)
	{
		case true:
		{
			new Entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
			if(pev_valid(Entity) == 2)
			{
				set_pev(Entity, pev_movetype, MOVETYPE_FOLLOW);
				set_pev(Entity, pev_aiment, id);
				
				// Model
				set_pev(Entity, pev_modelindex, g_pModelBubble);
				
				// SubModel
				set_pev(Entity, pev_body, is_user_alive(id) ? 0 : 1);
				
				// Skin
				set_pev(Entity, pev_skin, g_iColorBubble[iGrabber]);
				
				set_pev(Entity, pev_sequence, 0);
				set_pev(Entity, pev_animtime, get_gametime());
				set_pev(Entity, pev_framerate, 1.5);	
				
				set_pev(Entity, pev_iuser1, id);
				ArrayPushCell(g_iBubbleEntity, Entity);
				return 1;
			}
			return 0;
		}
		case false:
		{
			new Entity;
			for(new i = 0; i < ArraySize(g_iBubbleEntity); i++)
			{
				Entity = ArrayGetCell(g_iBubbleEntity, i);
				if(pev_valid(Entity) == 2)
				{
					if(pev(Entity, pev_iuser1) == id)
					{
						engfunc(EngFunc_RemoveEntity, Entity);
						ArrayDeleteItem(g_iBubbleEntity, i);
						return 1;
					}
				}
			}
		}
	}
	return 0;
}

// Место для меню ->
public Show_ColorBubble(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "\r[Color Bubble] \yЦвет пузыря^n^n");
	
	if(g_iColorBubble[id] != 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w1\d] \wБелый^n");
		BIT_ADD(iKeys, 0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dБелый^n");
	
	if(g_iColorBubble[id] != 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w2\d] \wЗеленый^n");
		BIT_ADD(iKeys, 1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dЗеленый^n");
	
	if(g_iColorBubble[id] != 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w3\d] \wКрасный^n");
		BIT_ADD(iKeys, 2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dКрасный^n");
	
	if(g_iColorBubble[id] != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w4\d] \wЖелтый^n");
		BIT_ADD(iKeys, 3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dЖелтый^n");
	
	if(g_iColorBubble[id] != 4)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w5\d] \wОранжевый^n");
		BIT_ADD(iKeys, 4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dОранжевый^n");
	
	if(g_iColorBubble[id] != 5)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w6\d] \wГолубой^n");
		BIT_ADD(iKeys, 5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dГолубой^n");
	
	if(g_iColorBubble[id] != 6)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w7\d] \wСиний^n");
		BIT_ADD(iKeys, 6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dСиний^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\d[\w0\d] \wВыход");
	return show_menu(id, iKeys, szMenu, -1, "Show_ColorBubble");
}

public Handle_ColorBubble(id, iKey)
{
	if(iKey == 9) 
		return 1;
	
	if(g_iColorBubble[id] != iKey) g_iColorBubble[id] = iKey;
	return Show_ColorBubble(id);
}

stock IsGrabbed(iTarget, iPlayer)
{
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{	
		if(pClientData[i][GRABBED] == iTarget)
		{
			new szName[32];
			get_user_name(iTarget, szName, charsmax(szName));
			UTIL_SayText(iPlayer, "!y[!gGRAB!y] Данного игрока !t%s !yуже держат!", szName);
			Command_UnGrab(iPlayer);
			return 1;
		}
	}
	return 0;
}

stock Float:get_target_origin_f(id)
{
	new Float:orig[3];
	pev(id, pev_origin, orig);
	if(id > g_iMaxPlayers)
	{
		new Float:mins[3], Float:maxs[3];
		pev(id, pev_mins, mins);
		pev(id, pev_maxs, maxs);
		
		if(!mins[2]) orig[2] += maxs[2] / 2;
	}
	return orig;
}

stock traceline(const Float:vStart[3], const Float:vEnd[3], const pIgnore, Float:vHitPos[3])
{
	engfunc(EngFunc_TraceLine, vStart, vEnd, 0, pIgnore, 0);
	get_tr2(0, TR_vecEndPos, vHitPos);
	return get_tr2(0, TR_pHit);
}

stock get_view_pos(const id, Float:vViewPos[3])
{
	new Float:vOfs[3];
	pev(id, pev_origin, vViewPos);
	pev(id, pev_view_ofs, vOfs);	
	
	vViewPos[0] += vOfs[0];
	vViewPos[1] += vOfs[1];
	vViewPos[2] += vOfs[2];
}

stock Float:vel_by_aim(id, iSpeed = 1)
{
	new Float:v1[3], Float:vBlah[3];
	pev(id, pev_v_angle, v1);
	engfunc(EngFunc_AngleVectors, v1, v1, vBlah, vBlah);
	
	v1[0] *= iSpeed;
	v1[1] *= iSpeed;
	v1[2] *= iSpeed;

	return v1;
}

stock UTIL_SayText(id, const szMessage[], any:...)
{
	new szBuffer[190];
	if(numargs() > 2) vformat(szBuffer, charsmax(szBuffer), szMessage, 3);
	else copy(szBuffer, charsmax(szBuffer), szMessage);
	while(replace(szBuffer, charsmax(szBuffer), "!y", "^1")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!t", "^3")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!g", "^4")) {}
	switch(id)
	{
		case 0:
		{
			for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(!is_user_connected(iPlayer)) continue;
				engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, 76, {0.0, 0.0, 0.0}, iPlayer);
				write_byte(iPlayer);
				write_string(szBuffer);
				message_end();
			}
		}
		default:
		{
			engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, 76, {0.0, 0.0, 0.0}, id);
			write_byte(id);
			write_string(szBuffer);
			message_end();
		}
	}
}