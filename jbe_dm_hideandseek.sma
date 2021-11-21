#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>

#pragma semicolon 1

#define SetBit(%0,%1) ((%0) |= (1<<(%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1<<(%1)))
#define IsSetBit(%0,%1) ((%0) & (1<<(%1)))
#define InvertBit(%0,%1) ((%0) ^= (1<<(%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1<<(%1)))

#define lunux_offset_player 5
#define MsgId_CurWeapon 66
#define m_flNextAttack 83
#define MsgId_ScreenFade 98
#define TASK_TIME_HIDE 785689

native jbe_register_day_mode(szLang[32], iBlock, iTime);
native jbe_get_user_team(id);

new g_iDayModeHideAndSeek, bool:g_bDayModeStatus, g_iSyncTimeHide, g_iTimeHideCount, g_iMaxPlayers, HamHook:g_iHamHookForwards[13];
new const g_szHamHookEntityBlock[][] =
{
	"func_vehicle", // Управляемая машина
	"func_tracktrain", // Управляемый поезд
	"func_tank", // Управляемая пушка
	"game_player_hurt", // При активации наносит игроку повреждения
	"func_recharge", // Увеличение запаса бронижелета
	"func_healthcharger", // Увеличение процентов здоровья
	"game_player_equip", // Выдаёт оружие
	"player_weaponstrip", // Забирает всё оружие
	"trigger_hurt", // Наносит игроку повреждения
	"trigger_gravity", // Устанавливает игроку силу гравитации
	"armoury_entity", // Объект лежащий на карте, оружия, броня или гранаты
	"weaponbox", // Оружие выброшенное игроком
	"weapon_shield" // Щит
};

public plugin_precache()
{
	engfunc(EngFunc_PrecacheGeneric, "sound/jb_engine/days_mode/hideandseek/ambience.mp3");
}

public plugin_init()
{
	register_plugin("[JBE_DM] Hide And Seek", "1.1", "Freedo.m");
	new i;
	for(i = 0; i <= 7; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	for(i = 8; i <= 12; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	register_impulse(100, "ClientImpulse100");
	g_iDayModeHideAndSeek = jbe_register_day_mode("JBE_DAY_MODE_HIDE_ADN_SEEK", 0, 180);
	g_iMaxPlayers = get_maxplayers();
	g_iSyncTimeHide = CreateHudSyncObj();
}

public HamHook_EntityBlock() return HAM_SUPERCEDE;
public ClientImpulse100(id)
{
	if(g_bDayModeStatus && jbe_get_user_team(id) == 1) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public jbe_day_mode_start(iDayMode, iAdmin)
{
	if(iDayMode == g_iDayModeHideAndSeek)
	{
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!is_user_alive(i)) continue;
			switch(jbe_get_user_team(i))
			{
				case 1:
				{
					fm_strip_user_weapons(i);
					fm_give_item(i, "weapon_knife");
				}
				case 2:
				{
					fm_strip_user_weapons(i);
					fm_give_item(i, "weapon_knife");
					fm_give_item(i, "weapon_ak47");
					fm_set_user_bpammo(i, CSW_AK47, 250);
					fm_give_item(i, "weapon_m4a1");
					fm_set_user_bpammo(i, CSW_M4A1, 250);
					set_pdata_float(i, m_flNextAttack, 30.0, lunux_offset_player);
					set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
					set_pev(i, pev_takedamage, DAMAGE_NO);
					UTIL_ScreenFade(i, 0, 0, 4, 0, 0, 0, 255, 1);
				}
			}
		}
		client_cmd(0, "mp3 play sound/jb_engine/days_mode/hideandseek/ambience.mp3");
		g_iTimeHideCount = 33;
		jbe_time_hide();
		set_task(1.0, "jbe_time_hide", TASK_TIME_HIDE, _, _, "a", g_iTimeHideCount);
		g_bDayModeStatus = true;
		server_cmd("mp_flashlight 1");
		for(new i; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
	}
}

public jbe_time_hide()
{
	if(--g_iTimeHideCount)
	{
		set_hudmessage(102, 69, 0, -1.0, 0.16, 0, 0.0, 0.9, 0.1, 0.1, -1);
		ShowSyncHudMsg(0, g_iSyncTimeHide, "У заключённых %d секунд^nчтобы спрятаться!", g_iTimeHideCount);
	}
	else
	{
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!is_user_alive(i)) continue;
			if(jbe_get_user_team(i) == 2)
			{
				UTIL_ScreenFade(i, 0, 0, 0, 0, 0, 0, 0, 1);
				set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
			}
		}
		set_lights("b");
	}
}

public jbe_day_mode_ended(iDayMode, iWinTeam)
{
	if(iDayMode == g_iDayModeHideAndSeek)
	{
		client_cmd(0, "mp3 stop");
		if(task_exists(TASK_TIME_HIDE)) remove_task(TASK_TIME_HIDE);
		g_bDayModeStatus = false;
		server_cmd("mp_flashlight 0");
		set_lights("#OFF");
		new i;
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(is_user_alive(i) && jbe_get_user_team(i) == 2)
			{
				if(iWinTeam) fm_strip_user_weapons(i, 1);
				else ExecuteHamB(Ham_Killed, i, i, 0);
			}
		}
	}
}

stock fm_give_item(id, const szItem[])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, szItem));
	if(!pev_valid(iEntity)) return 0;
	new Float:vecOrigin[3];
	pev(id, pev_origin, vecOrigin);
	set_pev(iEntity, pev_origin, vecOrigin);
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

stock fm_set_user_bpammo(id, iWeapon, iAmount)
{
	new iOffset;
	switch(iWeapon)
	{
		case CSW_AWP: iOffset = 377; // ammo_338magnum
		case CSW_SCOUT, CSW_AK47, CSW_G3SG1: iOffset = 378; // ammo_762nato
		case CSW_M249: iOffset = 379; // ammo_556natobox
		case CSW_FAMAS, CSW_M4A1, CSW_AUG, CSW_SG550, CSW_GALI, CSW_SG552: iOffset = 380; // ammo_556nato
		case CSW_M3, CSW_XM1014: iOffset = 381; // ammo_buckshot
		case CSW_USP, CSW_UMP45, CSW_MAC10: iOffset = 382; // ammo_45acp
		case CSW_FIVESEVEN, CSW_P90: iOffset = 383; // ammo_57mm
		case CSW_DEAGLE: iOffset = 384; // ammo_50ae
		case CSW_P228: iOffset = 385; // ammo_357sig
		case CSW_GLOCK18, CSW_MP5NAVY, CSW_TMP, CSW_ELITE: iOffset = 386; // ammo_9mm
		case CSW_FLASHBANG: iOffset = 387;
		case CSW_HEGRENADE: iOffset = 388;
		case CSW_SMOKEGRENADE: iOffset = 389;
		case CSW_C4: iOffset = 390;
		default: return;
	}
	set_pdata_int(id, iOffset, iAmount);
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