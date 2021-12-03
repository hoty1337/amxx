#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <engine>
#include <jbm_api>

#pragma semicolon 1

#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

#define lunux_offset_player 5
#define MAX_PLAYERS 32
#define MsgId_CurWeapon 66
#define m_flNextAttack 83
#define MsgId_ScreenFade 98
#define BREAK_GLASS 0x01
#define IUSER1_DEATH_TIMER 754645
#define jbm_is_user_valid(%0) (%0 && %0 <= g_iMaxPlayers)
#define TASK_DEATH_TIMER 785689
#define TASK_PROTECTION_TIME 125908
#define FORA_ZEKAM 16
#define TASK_COUNTDOWN 182482

new g_iDayModeRingolevio, g_iBitUserGame, g_iBitUserFrozen, g_iUserTeam[MAX_PLAYERS + 1], g_iUserEntityTimer[MAX_PLAYERS + 1], g_iCountDown,
Float:g_fUserDeathTimer[MAX_PLAYERS + 1], g_iUserLife[MAX_PLAYERS + 1], g_pSpriteFrost, g_pModelFrost, g_iMaxPlayers, 
HamHook:g_iHamHookForwards[15];
new const g_szHamHookEntityBlock[][] =
{
	"func_vehicle", // ����������� ������
	"func_tracktrain", // ����������� �����
	"func_tank", // ����������� �����
	"game_player_hurt", // ��� ��������� ������� ������ �����������
	"func_recharge", // ���������� ������ �����������
	"func_healthcharger", // ���������� ��������� ��������
	"game_player_equip", // ����� ������
	"player_weaponstrip", // �������� �� ������
	"trigger_hurt", // ������� ������ �����������
	"trigger_gravity", // ������������� ������ ���� ����������
	"armoury_entity", // ������ ������� �� �����, ������, ����� ��� �������
	"weaponbox", // ������ ����������� �������
	"weapon_shield" // ���
};

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/ringolevio/p_candy_cane.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/ringolevio/v_candy_cane.mdl");
	g_pSpriteFrost = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/frostgib.spr");
	g_pModelFrost = engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/ringolevio/frostgibs.mdl");
	engfunc(EngFunc_PrecacheSound, "jb_engine/days_mode/ringolevio/defrost_player.wav");
	engfunc(EngFunc_PrecacheSound, "jb_engine/days_mode/ringolevio/freeze_player.wav");
	engfunc(EngFunc_PrecacheGeneric, "sound/jb_engine/days_mode/ringolevio/alko.mp3");
	engfunc(EngFunc_PrecacheModel, "models/rpgrocket.mdl");
}

public plugin_init()
{
	register_plugin("[JailMode] Ringolevio", "1.2", "Freedo.m");
	new i;
	for(i = 0; i <= 7; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	for(i = 8; i <= 12; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	DisableHamForward(g_iHamHookForwards[13] = RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttack_Pre", 0));
	DisableHamForward(g_iHamHookForwards[14] = RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled_Post", 1));
	g_iDayModeRingolevio = jbm_register_day_mode("JBM_DAY_MODE_RINGOLEVIO", 1, 234);
	g_iMaxPlayers = get_maxplayers();
}

public client_disconnect(id)
{
	if(IsSetBit(g_iBitUserFrozen, id))
	{
		ClearBit(g_iBitUserFrozen, id);
		if(pev_valid(g_iUserEntityTimer[id])) set_pev(g_iUserEntityTimer[id], pev_flags, pev(g_iUserEntityTimer[id], pev_flags) | FL_KILLME);
	}
	ClearBit(g_iBitUserGame, id);
}

public HamHook_EntityBlock() return HAM_SUPERCEDE;
public Ham_TraceAttack_Pre(iVictim, iAttacker, Float:fDamage, Float:vecDeriction[3], iTrace, iBitDamage)
{
	if(IsSetBit(g_iBitUserGame, iAttacker) && jbm_is_user_valid(iAttacker))
	{
		switch(jbm_get_user_team(iAttacker))
		{
			case 1: if(IsSetBit(g_iBitUserFrozen, iVictim) && jbm_get_user_team(iVictim) == 1) jbm_dm_user_defrost(iVictim, iAttacker);
			case 2: if(IsNotSetBit(g_iBitUserFrozen, iVictim) && jbm_get_user_team(iVictim) == 1 && !task_exists(iVictim+TASK_PROTECTION_TIME)) jbm_dm_user_freeze(iVictim, iAttacker);
			default: return HAM_SUPERCEDE;
		}
	}
	return HAM_SUPERCEDE;
}
public Ham_PlayerKilled_Post(iVictim) ClearBit(g_iBitUserGame, iVictim);

jbm_dm_user_defrost(iVictim, iAttacker)
{
	if(task_exists(iVictim+TASK_DEATH_TIMER)) remove_task(iVictim+TASK_DEATH_TIMER);
	ClearBit(g_iBitUserFrozen, iVictim);
	set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) & ~FL_FROZEN);
	set_pdata_float(iVictim, m_flNextAttack, 0.0, lunux_offset_player);
	fm_set_user_rendering(iVictim, kRenderFxGlowShell, 255.0, 0.0, 0.0, kRenderNormal, 0.0);
	set_task(3.0, "jbm_dm_protection_time", iVictim+TASK_PROTECTION_TIME);
	UTIL_ScreenFade(iVictim, (1<<10), (1<<10), 0, 32, 164, 241, 200, 1);
	new Float:fOrigin[3];
	pev(iVictim, pev_origin, fOrigin);
	CREATE_BREAKMODEL(fOrigin, _, _, 10, g_pModelFrost, 10, 25, BREAK_GLASS);
	emit_sound(iVictim, CHAN_AUTO, "jb_engine/days_mode/ringolevio/defrost_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	if(pev_valid(g_iUserEntityTimer[iVictim])) set_pev(g_iUserEntityTimer[iVictim], pev_flags, pev(g_iUserEntityTimer[iVictim], pev_flags) | FL_KILLME);
	if(iAttacker) g_iUserLife[iAttacker]++;
}

public jbm_dm_protection_time(id)
{
	id -= TASK_PROTECTION_TIME;
	if(IsSetBit(g_iBitUserGame, id)) fm_set_user_rendering(id, kRenderFxNone, 255.0, 0.0, 0.0, kRenderNormal, 0.0);
}

jbm_dm_user_freeze(iVictim, iAttacker)
{
	if(--g_iUserLife[iVictim])
	{
		SetBit(g_iBitUserFrozen, iVictim);
		set_pdata_float(iVictim, m_flNextAttack, 20.0, lunux_offset_player);
		fm_set_user_rendering(iVictim, kRenderFxGlowShell, 32.0, 164.0, 241.0, kRenderNormal, 0.0);
		UTIL_ScreenFade(iVictim, 0, 0, 4, 32, 164, 241, 200);
		new Float:vecOrigin[3];
		pev(iVictim, pev_origin, vecOrigin);
		set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) | FL_FROZEN);
		set_pev(iVictim, pev_origin, vecOrigin);
		vecOrigin[2] += 15.0;
		CREATE_SPRITETRAIL(vecOrigin, g_pSpriteFrost, 30, 20, 2, 20, 10);
		g_fUserDeathTimer[iVictim] = 20.0;
		emit_sound(iVictim, CHAN_AUTO, "jb_engine/days_mode/ringolevio/freeze_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		new iArg[1]; iArg[0] = iAttacker;
		set_task(1.0, "jbm_dm_user_death_timer", iVictim+TASK_DEATH_TIMER, iArg, sizeof(iArg), "a", 20); 
	}
	else ExecuteHamB(Ham_Killed, iVictim, iAttacker, 2);
}

public jbm_dm_user_death_timer(const iAttacker[], iVictim)
{
	iVictim -= TASK_DEATH_TIMER;
	if(!is_user_alive(iVictim) || IsNotSetBit(g_iBitUserFrozen, iVictim) && task_exists(iVictim+TASK_DEATH_TIMER))
	{
		ClearBit(g_iBitUserFrozen, iVictim);
		set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) & ~FL_FROZEN);
		fm_set_user_rendering(iVictim, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
		UTIL_ScreenFade(iVictim, (1<<10), (1<<10), 0, 32, 164, 241, 200, 1);
		remove_task(iVictim+TASK_DEATH_TIMER);
		return;
	}
	if(g_fUserDeathTimer[iVictim] -= 1.0) return;
	ClearBit(g_iBitUserFrozen, iVictim);
	set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) & ~FL_FROZEN);
	fm_set_user_rendering(iVictim, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
	UTIL_ScreenFade(iVictim, (1<<10), (1<<10), 0, 32, 164, 241, 200, 1);
	ExecuteHamB(Ham_Killed, iVictim, iAttacker[0], 2);
	if(pev_valid(g_iUserEntityTimer[iVictim])) set_pev(g_iUserEntityTimer[iVictim], pev_flags, pev(g_iUserEntityTimer[iVictim], pev_flags) | FL_KILLME);
}

public jbm_day_mode_start(iDayMode, iAdmin)
{
	if(iDayMode == g_iDayModeRingolevio)
	{
		new i;
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!is_user_alive(i)) continue;
			SetBit(g_iBitUserGame, i);
			fm_strip_user_weapons(i);
			fm_give_item(i, "weapon_knife");
			set_pev(i, pev_gravity, 0.3);
			switch(jbm_get_user_team(i))
			{
				case 1:
				{
					g_iUserTeam[i] = 1;
					set_pev(i, pev_maxspeed, 380.0);
					g_iUserLife[i] = 2;
				}
				case 2:
				{
					g_iUserTeam[i] = 2;
					static iszViewModel, iszWeaponModel;
					if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/days_mode/ringolevio/v_candy_cane.mdl"))) set_pev_string(i, pev_viewmodel2, iszViewModel);
					if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/days_mode/ringolevio/p_candy_cane.mdl"))) set_pev_string(i, pev_weaponmodel2, iszWeaponModel);
					set_pev(i, pev_maxspeed, 400.0);
					UTIL_ScreenFade(i, 0, 0, 4, 0, 0, 0, 255);
					set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
				}
			}
		}
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
		client_cmd(0, "mp3 play sound/jb_engine/days_mode/ringolevio/alko.mp3");
		g_iCountDown = FORA_ZEKAM;
		set_task(1.0, "countDown", TASK_COUNTDOWN, _, _, "a", FORA_ZEKAM);
	}
}

public countDown()
{
	if(--g_iCountDown)
	{
		set_hudmessage(random_num(100, 255), random_num(100, 255), random_num(100, 255), -1.0, 0.35, 0, 0.0, 0.75, 0.1, 0.1);
		show_hudmessage(0, "У заключенных есть %d сек. чтобы разбежаться",g_iCountDown);
	}
	else
	{
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!is_user_alive(i)) continue;
			if(jbm_get_user_team(i) == 2)
			{
				UTIL_ScreenFade(i, 0, 0, 4, 0, 0, 0, 0);
				set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
				set_hudmessage(random_num(100, 255), random_num(100, 255), random_num(100, 255), -1.0, 0.35, 0, 0.0, 0.75, 0.1, 0.1);
				show_hudmessage(0, "ПОГНАЛИ!!!");
			}
		}
	}
}

public jbm_day_mode_ended(iDayMode, iWinTeam)
{
	if(iDayMode == g_iDayModeRingolevio)
	{
		new i;
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(IsSetBit(g_iBitUserGame, i))
			{
				switch(jbm_get_user_team(i))
				{
					case 1:
					{
						fm_strip_user_weapons(i, 1);
						if(IsSetBit(g_iBitUserFrozen, i)) jbm_dm_user_defrost(i, 0);
					}
					case 2:
					{
						if(iWinTeam) fm_strip_user_weapons(i, 1);
						else ExecuteHamB(Ham_Killed, i, i, 0);
					}
				}
			}
		}
		g_iBitUserGame = 0;
		g_iBitUserFrozen = 0;
		client_cmd(0, "mp3 stop");
	}
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

stock CREATE_SPRITETRAIL(const Float:fOrigin[3], pSprite, iCount, iLife, iScale, iVelocityAlongVector, iRandomVelocity)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITETRAIL);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2]);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2]);
	write_short(pSprite);
	write_byte(iCount);
	write_byte(iLife); // 0.1's
	write_byte(iScale);
	write_byte(iVelocityAlongVector);
	write_byte(iRandomVelocity);
	message_end(); 
}

stock CREATE_BREAKMODEL(const Float:fOrigin[3], Float:fSize[3] = {16.0, 16.0, 16.0}, Float:fVelocity[3] = {25.0, 25.0, 25.0}, iRandomVelocity, pModel, iCount, iLife, iFlags)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BREAKMODEL);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2] + 24);
	engfunc(EngFunc_WriteCoord, fSize[0]);
	engfunc(EngFunc_WriteCoord, fSize[1]);
	engfunc(EngFunc_WriteCoord, fSize[2]);
	engfunc(EngFunc_WriteCoord, fVelocity[0]);
	engfunc(EngFunc_WriteCoord, fVelocity[1]);
	engfunc(EngFunc_WriteCoord, fVelocity[2]);
	write_byte(iRandomVelocity);
	write_short(pModel);
	write_byte(iCount); // 0.1's
	write_byte(iLife); // 0.1's
	write_byte(iFlags);
	message_end();
}