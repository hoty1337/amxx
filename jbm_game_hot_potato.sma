#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <jbm_api>

#pragma semicolon 1

/*===== -> Макросы -> =====*///{

/* -> Бит сумм -> */
#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

/* -> Оффсеты и другое -> */
#define jbm_is_user_valid(%0) (%0 && %0 <= g_iMaxPlayers)
#define MAX_PLAYERS 32

/* -> Индексы сообщений -> */
#define MsgId_SayText 76
#define MsgId_CurWeapon 66
#define MsgId_ScreenFade 98

/* -> Оффсеты -> */
#define lunux_offset_player 5
#define m_flNextAttack 83

/* -> Таск -> */
#define TASK_DEATH_TIMER 1337
#define TASK_USER_LIGHT 123724

/*===== -> Битсуммы, переменные и массивы для работы с игрой -> =====*///}

new g_iDayModePotato;
//new g_pSprite;
new g_iBitUserGame;
new g_iBitUserPotato;
new g_iDeathTimer;
new g_iMaxPlayers;
new g_iSyncTimer;
new HamHook:g_iHamHookForwards[15];
new szNamePotato[32];
new const g_szHamHookEntityBlock[][] =
{
	"func_vehicle", 		// Управляемая машина
	"func_tracktrain", 		// Управляемый поезд
	"func_tank", 			// Управляемая пушка
	"game_player_hurt", 	// При активации наносит игроку повреждения
	"func_recharge", 		// Увеличение запаса бронижелета
	"func_healthcharger", 	// Увеличение процентов здоровья
	"game_player_equip",	// Выдаёт оружие
	"player_weaponstrip",	// Забирает всё оружие
	"trigger_hurt", 		// Наносит игроку повреждения
	"trigger_gravity", 		// Устанавливает игроку силу гравитации
	"armoury_entity", 		// Объект лежащий на карте, оружия, броня или гранаты
	"weaponbox", 			// Оружие выброшенное игроком
	"weapon_shield" 		// Щит
};

/*===== <- Битсуммы, переменные и массивы для работы с игрой <- =====*///}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheGeneric, "sound/jb_engine/days_mode/hot_potato/unopot.mp3");
}

public plugin_init()
{
	register_plugin("[JailMode] Hot Potato", "1.1", "AlexandrFiner");
	new i;
	for(i = 0; i <= 7; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	for(i = 8; i <= 12; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	DisableHamForward(g_iHamHookForwards[13] = RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttack_Pre", 0));
	DisableHamForward(g_iHamHookForwards[14] = RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled_Post", 1));
	g_iSyncTimer = CreateHudSyncObj();
	g_iDayModePotato = jbm_register_day_mode("JBM_DAY_MODE_HOT_POTATO", 1, 234);
	g_iMaxPlayers = get_maxplayers();
}

public client_disconnected(id)
{
	if(IsSetBit(g_iBitUserPotato, id))
	{
		ClearBit(g_iBitUserPotato, id);
		fm_set_user_rendering(id, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
		UTIL_ScreenFade(id, 0, 0, 0, 0, 0, 0, 0, 1);
		remove_task(TASK_DEATH_TIMER);
		remove_task(id + TASK_USER_LIGHT);
		new players[32], iNum; 
		get_players(players, iNum, "aceh", "CT");
		if(iNum > 0)
			set_task(1.0, "jbm_potato_new");
	}
	ClearBit(g_iBitUserGame, id);
}

/*===== -> 'hamsandwich' события -> =====*///{

public HamHook_EntityBlock() return HAM_SUPERCEDE;
public Ham_TraceAttack_Pre(iVictim, iAttacker, Float:fDamage, Float:vecDeriction[3], iTrace, iBitDamage)
{
	if(IsSetBit(g_iBitUserGame, iAttacker) && jbm_is_user_valid(iAttacker) && IsSetBit(g_iBitUserPotato, iAttacker))
	{
		ClearBit(g_iBitUserPotato, iAttacker);
		remove_task(iAttacker + TASK_USER_LIGHT);
		//fm_set_user_rendering(iAttacker, kRenderFxGlowShell, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
		UTIL_ScreenFade(iAttacker, 0, 0, 0, 0, 0, 0, 0, 1);
		set_pev(iAttacker, pev_maxspeed, 380.0);
		
		SetBit(g_iBitUserPotato, iVictim);
		set_task(0.1, "lightning", iVictim + TASK_USER_LIGHT, _, _, "b");
		//fm_set_user_rendering(iVictim, kRenderFxGlowShell, 255.0, 0.0, 0.0, kRenderNormal, 0.0);
		UTIL_ScreenFade(iVictim, 0, 0, 4, 255, 0, 0, 100, 1);
		set_pev(iVictim, pev_maxspeed, 450.0);
		get_user_name(iVictim, szNamePotato, charsmax(szNamePotato));
				
		user_slap(iVictim, 0, 1);
	}
	return HAM_SUPERCEDE;
}
public Ham_PlayerKilled_Post(iVictim) 
{
	ClearBit(g_iBitUserGame, iVictim);
	remove_task(iVictim + TASK_USER_LIGHT);
	fm_set_user_rendering(iVictim, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
	UTIL_ScreenFade(iVictim, 0, 0, 0, 0, 0, 0, 0, 1);
}

/*===== <- 'hamsandwich' события <- =====*///}

/*===== -> Игровой процесс -> =====*///{
/* -> Начало игры -> */
public jbm_day_mode_start(iDayMode, iAdmin)
{
	if(iDayMode == g_iDayModePotato)
	{
		new iPlayers[32], iNum, i, g_iKartowka;
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!jbm_is_user_alive(i)) continue;
			SetBit(g_iBitUserGame, i);
			fm_strip_user_weapons(i);
			fm_give_item(i, "weapon_knife");
			set_pev(i, pev_gravity, 0.3);
			set_pev(i, pev_maxspeed, 380.0);
			iPlayers[iNum++] = i;
		}
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
		
		/* Выбор игрока */
		g_iKartowka = iPlayers[random_num(0, iNum - 1)];
		
		get_user_name(g_iKartowka, szNamePotato, charsmax(szNamePotato));
		
		UTIL_ScreenFade(g_iKartowka, 0, 0, 4, 255, 0, 0, 100, 1);
		//fm_set_user_rendering(g_iKartowka, kRenderFxNone, 255.0, 0.0, 0.0, kRenderNormal, 0.0);
		UTIL_SayText(g_iKartowka, "!y[!gJBM!y] У Вас !tкартошка!y! Скорей !gкого-то !yударьте!");
		set_task(0.1, "lightning", g_iKartowka + TASK_USER_LIGHT, _, _, "b");
		SetBit(g_iBitUserPotato, g_iKartowka);
		g_iDeathTimer = 20;
		set_task(1.0, "jbm_kartowka_informer", TASK_DEATH_TIMER, _, _, "a", g_iDeathTimer);
		client_cmd(0, "mp3 play sound/jb_engine/days_mode/hot_potato/unopot.mp3");
	}
}

/* -> Конец игры -> */
public jbm_day_mode_ended(iDayMode)
{
	if(iDayMode == g_iDayModePotato)
	{
		if(task_exists(TASK_DEATH_TIMER)) remove_task(TASK_DEATH_TIMER);
		new i;
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(IsSetBit(g_iBitUserGame, i) && jbm_is_user_alive(i) && jbm_is_user_valid(i))
			{
				fm_strip_user_weapons(i, 1);
				if(IsSetBit(g_iBitUserPotato, i)) 
				{
					ClearBit(g_iBitUserPotato, i);
					remove_task(i + TASK_USER_LIGHT);
				}
			}
		}
		g_iBitUserGame = 0;
		g_iBitUserPotato = 0;
		client_cmd(0, "mp3 stop");
	}
}

/* -> Таймер -> */
public jbm_kartowka_informer()
{
	if(!--g_iDeathTimer) jbm_potato_new();
	for(new pPlayer = 1; pPlayer <= g_iMaxPlayers; pPlayer++)
	{
		set_hudmessage(102, 69, 0, -1.0, 0.3, 0, 0.0, 0.9, 0.1, 0.1, -1);
		ShowSyncHudMsg(pPlayer, g_iSyncTimer, "Картошка взорвется через: %d^nКартошка у игрока: %s", g_iDeathTimer, szNamePotato);
	}
}

/* -> Выбор нового игрока -> */
public jbm_potato_new()
{
	new players[32], iNum; 
	get_players(players, iNum, "aceh", "CT");
	if(!iNum) return;
	iNum = 0;
	new iPlayers[32], i, g_iKartowka;
	for(i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsSetBit(g_iBitUserPotato, i)) 
		{
			ExecuteHamB(Ham_Killed, i, i, 0);
			ClearBit(g_iBitUserPotato, i);
			remove_task(i + TASK_USER_LIGHT);
		}
		if(!jbm_is_user_alive(i) || IsSetBit(g_iBitUserPotato, i)) continue;
		iPlayers[iNum++] = i;
	}
	g_iKartowka = iPlayers[random_num(0, iNum - 1)];
	get_user_name(g_iKartowka, szNamePotato, charsmax(szNamePotato));
	UTIL_ScreenFade(g_iKartowka, 0, 0, 4, 255, 0, 0, 100, 1);
	//fm_set_user_rendering(g_iKartowka, kRenderFxGlowShell, 255.0, 0.0, 0.0, kRenderNormal, 0.0);
	set_task(0.1, "lightning", g_iKartowka + TASK_USER_LIGHT, _, _, "b");
	UTIL_SayText(g_iKartowka, "!y[!gJBM!y] У Вас !tкартошка!y! Скорей !gкого-то !yударьте!");
	SetBit(g_iBitUserPotato, g_iKartowka);
	g_iDeathTimer = 10;
	set_task(1.0, "jbm_kartowka_informer", TASK_DEATH_TIMER, _, _, "a", g_iDeathTimer);
	set_pev(i, pev_maxspeed, 450.0);
}

/*===== <- Игровой процесс <- =====*///}

/*===== -> Стоки -> =====*///{
	
public lightning(idx)
{
	new id = idx - TASK_USER_LIGHT;
	new Float:fOrigin[3], origin[3];
	get_user_origin(id, origin);
	IVecFVec(origin, fOrigin);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_DLIGHT); // 27;
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_byte(15); // radius
	write_byte(255); // Red
	write_byte(10); // Green
	write_byte(10); // Blue
	write_byte(2); // life
	write_byte(0); // decay rate
	message_end();
}

stock fm_give_item(id, const szItem[])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, szItem));
	if(!pev_valid(iEntity)) return 0;
	new Float:fOrigin[3];
	pev(id, pev_origin, fOrigin);
	set_pev(iEntity, pev_origin, fOrigin);
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, iEntity);
	new iSolid = pev(iEntity, pev_solid);
	dllfunc(DLLFunc_Touch, iEntity, id);
	if(pev(iEntity, pev_solid) == iSolid)
	{
		engfunc(EngFunc_RemoveEntity, iEntity);
		return -1;
	}
	return iEntity;
}

stock fm_strip_user_weapons(id, iType = 0)
{
	new iEntity;
	static iszWeaponStrip = 0;
	if(iszWeaponStrip || (iszWeaponStrip = engfunc(EngFunc_AllocString, "player_weaponstrip"))) iEntity = engfunc(EngFunc_CreateNamedEntity, iszWeaponStrip);
	if(!pev_valid(iEntity)) return 0;
	if(iType && get_user_weapon(id) != CSW_KNIFE)
	{
		engclient_cmd(id, "weapon_knife");
		message_begin(MSG_ONE_UNRELIABLE, MsgId_CurWeapon, _, id);
		write_byte(1);
		write_byte(CSW_KNIFE);
		write_byte(0);
		message_end();
	}
	dllfunc(DLLFunc_Spawn, iEntity);
	dllfunc(DLLFunc_Use, iEntity, id);
	engfunc(EngFunc_RemoveEntity, iEntity);
	return 1;
}

stock fm_set_user_rendering(id, iRenderFx, Float:flRed, Float:flGreen, Float:flBlue, iRenderMode,  Float:flRenderAmt)
{
	new Float:fRenderColor[3];
	fRenderColor[0] = flRed;
	fRenderColor[1] = flGreen;
	fRenderColor[2] = flBlue;
	set_pev(id, pev_renderfx, iRenderFx);
	set_pev(id, pev_rendercolor, fRenderColor);
	set_pev(id, pev_rendermode, iRenderMode);
	set_pev(id, pev_renderamt, flRenderAmt);
}

stock UTIL_ScreenFade(id, iDuration, iHoldTime, iFlags, iRed, iGreen, iBlue, iAlpha, iReliable = 0)
{
	message_begin(iReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_ScreenFade, _, id);
	write_short(iDuration);
	write_short(iHoldTime);
	write_short(iFlags);
	write_byte(iRed);
	write_byte(iGreen);
	write_byte(iBlue);
	write_byte(iAlpha);
	message_end();
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
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(!is_user_connected(i)) continue;
				message_begin(MSG_ONE_UNRELIABLE, MsgId_SayText, _, i);
				write_byte(i);
				write_string(szBuffer);
				message_end();
			}
		}
		default:
		{
			message_begin(MSG_ONE_UNRELIABLE, MsgId_SayText, _, id);
			write_byte(id);
			write_string(szBuffer);
			message_end();
		}
	}
}