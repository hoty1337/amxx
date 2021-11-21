#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <jbm_api>

#pragma semicolon 1

#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

#define MsgId_CurWeapon 66
#define MsgId_WeaponList 78
#define MsgId_ScreenFade 98
#define TASK_COUNTDOWN	123851

#define jbm_is_user_valid(%0) (%0 && %0 <= g_iMaxPlayers)

#define FORA_ZEKAM	16

new g_iCountDown;
new g_iDayModeBirthday; 
new g_iMaxPlayers; 
new g_pCakeIndex; 
new g_pDecalIndex[4];
new g_iFakeMetaSetModel; 
new HamHook:g_iHamHookForwards[14]; 
new g_pSpriteBeam;
new const g_szHamHookEntityBlock[][] =
{
	"func_vehicle", 		// ����������� ������
	"func_tracktrain",		// ����������� �����
	"func_tank",			// ����������� �����
	"game_player_hurt",		// ��� ��������� ������� ������ �����������
	"func_recharge",		// ���������� ������ �����������
	"func_healthcharger",	// ���������� ��������� ��������
	"game_player_equip",	// ����� ������
	"player_weaponstrip",	// �������� �� ������
	"trigger_hurt",			// ������� ������ �����������
	"trigger_gravity",		// ������������� ������ ���� ����������
	"armoury_entity",		// ������ ������� �� �����, ������, ����� ��� �������
	"weaponbox",			// ������ ����������� �������
	"weapon_shield"			// ���
};

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/birthday/p_cake.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/birthday/v_cake.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/birthday/w_cake.mdl");

	g_pCakeIndex = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/cake_explosion.spr");
	engfunc(EngFunc_PrecacheSound, "jb_engine/days_mode/birthday/cake_explosion.wav");
	engfunc(EngFunc_PrecacheGeneric, "sound/jb_engine/days_mode/birthday/jovids.mp3");
	engfunc(EngFunc_PrecacheGeneric, "sprites/jb_engine/wpn_cake.spr");
	engfunc(EngFunc_PrecacheGeneric, "sprites/jbm_dm_wpn_cake.txt");
	g_pSpriteBeam = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr");
	g_pDecalIndex[0] = engfunc(EngFunc_DecalIndex,"{blood1");
	g_pDecalIndex[1] = engfunc(EngFunc_DecalIndex,"{blood2");
	g_pDecalIndex[2] = engfunc(EngFunc_DecalIndex,"{blood3");
	g_pDecalIndex[3] = engfunc(EngFunc_DecalIndex,"{blood4");
}

public plugin_init()
{
	register_plugin("[JailMode] Birth Day", "1.1", "Freedo.m");
	new i;
	for(i = 0; i <= 7; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	for(i = 8; i <= 12; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	DisableHamForward(g_iHamHookForwards[13] = RegisterHam(Ham_Touch, "grenade", "HamHook_Touch_Grenade_Post", 1));
	register_clcmd("jbm_dm_wpn_cake", "ClCmd_WpnCake");
	g_iDayModeBirthday = jbm_register_day_mode("JBM_DAY_MODE_BIRTHDAY", 1, 182);
	g_iMaxPlayers = get_maxplayers();
}

public HamHook_EntityBlock() return HAM_SUPERCEDE;
public HamHook_Touch_Grenade_Post(iTouched, iToucher)
{
	if(!pev_valid(iTouched)) return;
	new Float:vecOrigin[3];
	pev(iTouched, pev_origin, vecOrigin);
	if(pev_valid(iToucher) == 2)
	{
		new iOwner = pev(iTouched, pev_owner);
		if(jbm_is_user_valid(iToucher))
		{
			if(jbm_get_user_team(iToucher) == 1) ExecuteHamB(Ham_TakeDamage, iToucher, iOwner, iOwner, 50.0, DMG_SONIC);
			UTIL_ScreenFade(iToucher, (1<<12), (1<<12), 0, 24, 10, 10, 250);
		}
		else ExecuteHamB(Ham_TakeDamage, iToucher, iOwner, iOwner, 50.0, DMG_SONIC);
	}
	else CREATE_WORLDDECAL(vecOrigin, g_pDecalIndex[random_num(0, 3)]);
	CREATE_SPRITE(vecOrigin, g_pCakeIndex, 15, 255);
	emit_sound(iTouched, CHAN_AUTO, "jb_engine/days_mode/birthday/cake_explosion.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	set_pev(iTouched, pev_flags, pev(iTouched, pev_flags) | FL_KILLME);
	CREATE_KILLBEAM(iTouched);
}

public ClCmd_WpnCake(id)
{
	engclient_cmd(id, "weapon_smokegrenade");
	return PLUGIN_HANDLED;
}

public jbm_day_mode_start(iDayMode, iAdmin)
{
	if(iDayMode == g_iDayModeBirthday)
	{
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!is_user_alive(i)) continue;
			switch(jbm_get_user_team(i))
			{
				case 1:
				{
					fm_strip_user_weapons(i, 1);
					set_pev(i, pev_gravity, 0.5);
				}
				case 2:
				{
					fm_strip_user_weapons(i);
					fm_give_item(i, "weapon_smokegrenade");
					fm_set_user_bpammo(i, CSW_SMOKEGRENADE, 200);
					message_begin(MSG_ONE, MsgId_WeaponList, _, i);
					write_string("jbm_dm_wpn_cake");
					write_byte(13);
					write_byte(1);
					write_byte(-1);
					write_byte(-1);
					write_byte(3);
					write_byte(3);
					write_byte(9);
					write_byte(24);
					message_end();
					static iszViewModel, iszWeaponModel;
					if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/days_mode/birthday/v_cake.mdl"))) set_pev_string(i, pev_viewmodel2, iszViewModel);
					if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/days_mode/birthday/p_cake.mdl"))) set_pev_string(i, pev_weaponmodel2, iszWeaponModel);
					UTIL_ScreenFade(i, 0, 0, 4, 0, 0, 0, 255);
					set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
				}
			}
		}
		client_cmd(0, "mp3 play sound/jb_engine/days_mode/birthday/jovids.mp3");
		for(new i; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
		g_iFakeMetaSetModel = register_forward(FM_SetModel, "FakeMeta_SetModel_Post", 1);
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

public FakeMeta_SetModel_Post(iEntity, const szModel[])
{
	if(szModel[7] == 'w' && szModel[8] == '_' && szModel[9] == 's' && szModel[10] == 'm')
	{
		engfunc(EngFunc_SetModel, iEntity, "models/jb_engine/days_mode/birthday/w_cake.mdl");
		new Float:vecVelocity[3];
		pev(iEntity, pev_velocity, vecVelocity);
		xs_vec_mul_scalar(vecVelocity, 1.5, vecVelocity);
		set_pev(iEntity, pev_velocity, vecVelocity);
		engfunc(EngFunc_SetSize, iEntity, Float:{-5.0, -5.0, -5.0}, Float:{5.0, 5.0, 5.0});
		CREATE_BEAMFOLLOW(iEntity, g_pSpriteBeam, 4, 5, random(255), random(255), random(255), 130);
	}
}

public jbm_day_mode_ended(iDayMode, iWinTeam)
{
	if(iDayMode == g_iDayModeBirthday)
	{
		client_cmd(0, "mp3 stop");
		new i, iEntity, iOwner;
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
		unregister_forward(FM_SetModel, g_iFakeMetaSetModel, 1);
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(is_user_alive(i) && jbm_get_user_team(i) == 2)
			{
				if(iWinTeam) fm_strip_user_weapons(i, 1);
				else ExecuteHamB(Ham_Killed, i, i, 0);
			}
		}
		while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "grenade")))
		{
			if(!pev_valid(iEntity)) continue;
			iOwner = pev(iEntity, pev_owner);
			if(jbm_is_user_valid(iOwner)) set_pev(iEntity, pev_flags, pev(iEntity, pev_flags) | FL_KILLME);
		}
	}
}

stock CREATE_SPRITE(Float:vecOrigin[3], pSptite, iWidth, iBrightness)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(pSptite);
	write_byte(iWidth);
	write_byte(iBrightness);
	message_end();
}

stock CREATE_WORLDDECAL(Float:vecOrigin[3], pDecal)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_byte(pDecal);
	message_end();
}

stock UTIL_ScreenFade(id, iDuration, iHoldTime, iFlags, iRed, iGreen, iBlue, iAlpha)
{
	message_begin(MSG_ONE_UNRELIABLE, MsgId_ScreenFade, _, id);
	write_short(iDuration);
	write_short(iHoldTime);
	write_short(iFlags);
	write_byte(iRed);
	write_byte(iGreen);
	write_byte(iBlue);
	write_byte(iAlpha);
	message_end();
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

stock CREATE_BEAMFOLLOW(pEntity, pSptite, iLife, iWidth, iRed, iGreen, iBlue, iAlpha)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(pEntity);
	write_short(pSptite);
	write_byte(iLife); // 0.1's
	write_byte(iWidth);
	write_byte(iRed);
	write_byte(iGreen);
	write_byte(iBlue);
	write_byte(iAlpha);
	message_end();
}

stock CREATE_KILLBEAM(pEntity)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pEntity);
	message_end();
}