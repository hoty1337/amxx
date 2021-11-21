#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#pragma semicolon 1

#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

#define MsgId_CurWeapon 66
#define MsgId_SayText 76
#define MsgId_ScreenFade 98
#define TASK_REGENERATION_HEALTH 756867
#define TASK_TEAM_SPIRIT 867456
#define jbe_is_user_valid(%0) (%0 && %0 <= g_iMaxPlayers)
#define TASK_AMBIENCE_SOUND 124567

native jbe_register_day_mode(szLang[32], iBlock, iTime);
native jbe_get_user_team(id);
native jbe_set_user_model(id, const szModel[]);

new g_iDayModeSparta, bool:g_bDayModeStatus, g_iMaxPlayers, g_pSpriteWave, g_iCommanderId, g_iBitUserTeamSpirit,
HamHook:g_iHamHookForwards[16];
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
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/sparta/v_sword_shield.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/days_mode/sparta/p_sword_shield.mdl");
	engfunc(EngFunc_PrecacheModel, "models/player/jbe_dm_sparta_b1/jbe_dm_sparta_b1.mdl");
	engfunc(EngFunc_PrecacheSound, "jb_engine/days_mode/sparta/team_spirit.wav");
	engfunc(EngFunc_PrecacheGeneric, "sound/jb_engine/days_mode/sparta/ambience.mp3");
	g_pSpriteWave = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr");
}

public plugin_init()
{
	register_plugin("[JBE_DM] Sparta", "1.1", "Freedo.m");
	new i;
	for(i = 0; i <= 7; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	for(i = 8; i <= 12; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	DisableHamForward(g_iHamHookForwards[13] = RegisterHam(Ham_Touch, "weapon_shield", "HamHook_Touch_Shield_Post", 1));
	DisableHamForward(g_iHamHookForwards[14] = RegisterHam(Ham_Killed, "player", "HamHook_Killed_Player_Post", 1));
	DisableHamForward(g_iHamHookForwards[15] = RegisterHam(Ham_TakeDamage, "player", "HamHook_TakeDamage_Player_Pre", 0));
	register_clcmd("drop", "ClCmd_Drop");
	g_iDayModeSparta = jbe_register_day_mode("JBE_DAY_MODE_SPARTA", 0, 120);
	g_iMaxPlayers = get_maxplayers();
}

public client_disconnect(id)
{
	if(g_iCommanderId == id)
	{
		if(task_exists(TASK_TEAM_SPIRIT))
		{
			remove_task(TASK_TEAM_SPIRIT);
			emit_sound(g_iCommanderId, CHAN_STATIC, "jb_engine/days_mode/sparta/team_spirit.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(IsSetBit(g_iBitUserTeamSpirit, i))
				{
					ClearBit(g_iBitUserTeamSpirit, i);
					fm_set_user_rendering(i, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
					UTIL_ScreenFade(i, 0, 0, 0, 0, 0, 0, 0, 1);
				}
			}
		}
		g_iCommanderId = 0;
	}
}

public HamHook_EntityBlock() return HAM_SUPERCEDE;
public HamHook_Touch_Shield_Post(iEntity) set_pev(iEntity, pev_nextthink, get_gametime());
public HamHook_Killed_Player_Post(iVictim)
{
	if(jbe_get_user_team(iVictim) == 1)
	{
		if(g_iCommanderId == iVictim)
		{
			g_iCommanderId = 0;
			fm_set_user_rendering(iVictim, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
			UTIL_ScreenFade(iVictim, 0, 0, 0, 0, 0, 0, 0, 1);
		}
		if(IsSetBit(g_iBitUserTeamSpirit, iVictim))
		{
			ClearBit(g_iBitUserTeamSpirit, iVictim);
			fm_set_user_rendering(iVictim, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
			UTIL_ScreenFade(iVictim, 0, 0, 0, 0, 0, 0, 0, 1);
		}
	}
}

public HamHook_TakeDamage_Player_Pre(iVictim, iInflictor, iAttacker, Float:flDamage, iBitDamage)
{
	if(jbe_is_user_valid(iAttacker) && jbe_get_user_team(iVictim) == 2)
	{
		if(IsSetBit(g_iBitUserTeamSpirit, iAttacker)) SetHamParamFloat(4, flDamage * 4);
		else SetHamParamFloat(4, flDamage * 2);
	}
}

public ClCmd_Drop(id)
{
	if(g_bDayModeStatus)
	{
		if(g_iCommanderId == id && !task_exists(TASK_TEAM_SPIRIT))
		{
			new Float:fOrigin[3], Float:fOrigin2[3], Float:fDistance;
			pev(g_iCommanderId, pev_origin, fOrigin);
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iCommanderId != i && is_user_alive(i) && jbe_get_user_team(i) == 1)
				{
					pev(i, pev_origin, fOrigin2);
					fDistance = get_distance_f(fOrigin, fOrigin2);
					if(fDistance < 250.0)
					{
						SetBit(g_iBitUserTeamSpirit, i);
						fm_set_user_rendering(i, kRenderFxGlowShell, 212.0, 175.0, 55.0, kRenderNormal, 0.0);
						UTIL_ScreenFade(i, 0, 0, 4, 212, 175, 55, 100, 1);
					}
				}
			}
			CREATE_BEAMCYLINDER(fOrigin, 250, g_pSpriteWave, _, _, 5, 100, _, 212, 175, 55, 255, _);
			emit_sound(id, CHAN_STATIC, "jb_engine/days_mode/sparta/team_spirit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			set_task(11.0, "jbe_dm_team_spirit", TASK_TEAM_SPIRIT);
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public jbe_dm_team_spirit()
{
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsSetBit(g_iBitUserTeamSpirit, i))
		{
			ClearBit(g_iBitUserTeamSpirit, i);
			fm_set_user_rendering(i, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
			UTIL_ScreenFade(i, 0, 0, 0, 0, 0, 0, 0, 1);
		}
	}
}

public jbe_day_mode_start(iDayMode, iAdmin)
{
	if(iDayMode == g_iDayModeSparta)
	{
		new iPlayers[32], iNum, i;
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!is_user_alive(i)) continue;
			switch(jbe_get_user_team(i))
			{
				case 1:
				{
					jbe_set_user_model(i, "jbe_dm_sparta_b1");
					fm_strip_user_weapons(i);
					fm_give_item(i, "weapon_knife");
					fm_give_item(i, "weapon_shield");
					static iszViewModel, iszWeaponModel;
					if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/days_mode/sparta/v_sword_shield.mdl"))) set_pev_string(i, pev_viewmodel2, iszViewModel);
					if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/days_mode/sparta/p_sword_shield.mdl"))) set_pev_string(i, pev_weaponmodel2, iszWeaponModel);
					fm_give_item(i, "item_assaultsuit");
					set_pev(i, pev_health, 120.0);
					iPlayers[iNum++] = i;
					UTIL_SayText(i, "!g[JBE]!y Держитесь вместе с командующим чтобы усилить свои способности.");
				}
				case 2:
				{
					fm_strip_user_weapons(i);
					fm_give_item(i, "weapon_awp");
					fm_set_user_bpammo(i, CSW_AWP, 250);
					fm_give_item(i, "weapon_deagle");
					fm_set_user_bpammo(i, CSW_DEAGLE, 250);
					fm_give_item(i, "item_assaultsuit");
					set_pev(i, pev_health, 100.0);
				}
			}
		}
		g_iCommanderId = iPlayers[random_num(0, iNum - 1)];
		set_pev(g_iCommanderId, pev_health, 250.0);
		fm_set_user_rendering(g_iCommanderId, kRenderFxGlowShell, 255.0, 0.0, 0.0, kRenderNormal, 0.0);
		UTIL_ScreenFade(g_iCommanderId, 0, 0, 4, 255, 0, 0, 100, 1);
		UTIL_SayText(g_iCommanderId, "!g[JBE]!y Вы были выбраны !tкомандиром!y, нажимайте кнопку !g'G'!y чтобы поднять командный дух.");
		set_task(1.0, "jbe_dm_regeneration_health", TASK_REGENERATION_HEALTH, _, _, "b");
		client_cmd(0, "mp3 play sound/jb_engine/days_mode/sparta/ambience.mp3");
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
		g_bDayModeStatus = true;
	}
}

public jbe_day_mode_ended(iDayMode, iWinTeam)
{
	if(iDayMode == g_iDayModeSparta)
	{
		new i, iEntity;
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
		for(i = 1; i <= g_iMaxPlayers; i++)
		{
			if(is_user_alive(i))
			{
				switch(jbe_get_user_team(i))
				{
					case 1:
					{
						if(!iWinTeam) ExecuteHamB(Ham_Killed, i, i, 0);
						else fm_strip_user_weapons(i, 1);
						if(g_iCommanderId == i || IsSetBit(g_iBitUserTeamSpirit, i))
						{
							ClearBit(g_iBitUserTeamSpirit, i);
							fm_set_user_rendering(i, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
							UTIL_ScreenFade(i, 0, 0, 0, 0, 0, 0, 0, 1);
						}
					}
					case 2: fm_strip_user_weapons(i, 1);
				}
			}
		}
		remove_task(TASK_REGENERATION_HEALTH);
		if(task_exists(TASK_TEAM_SPIRIT))
		{
			remove_task(TASK_TEAM_SPIRIT);
			emit_sound(g_iCommanderId, CHAN_STATIC, "jb_engine/days_mode/sparta/team_spirit.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		}
		client_cmd(0, "mp3 stop");
		while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", "weapon_shield")))
		{
			if(!pev_valid(iEntity)) continue;
			if(jbe_is_user_valid(pev(iEntity, pev_owner))) set_pev(iEntity, pev_flags, pev(iEntity, pev_flags) | FL_KILLME);
		}
		g_bDayModeStatus = false;
	}
}

public jbe_dm_regeneration_health()
{
	new Float:fOrigin[3], Float:fOrigin2[3], Float:fDistance;
	if(g_iCommanderId) pev(g_iCommanderId, pev_origin, fOrigin);
	for(new i = 1, iHealth; i <= g_iMaxPlayers; i++)
	{
		if(g_iCommanderId != i && is_user_alive(i) && jbe_get_user_team(i) == 1)
		{
			if(g_iCommanderId)
			{
				pev(i, pev_origin, fOrigin2);
				fDistance = get_distance_f(fOrigin, fOrigin2);
				if(fDistance < 400.0)
				{
					iHealth = get_user_health(i);
					if(iHealth < 150)
					{
						iHealth += 5;
						if(IsSetBit(g_iBitUserTeamSpirit, i)) iHealth += 5;
						if(iHealth > 150) iHealth = 150;
						set_pev(i, pev_health, float(iHealth));
					}
				}
				else
				{
					iHealth = get_user_health(i);
					if(iHealth > 1) set_pev(i, pev_health, iHealth - 1.0);
					else ExecuteHamB(Ham_Killed, i, i, 0);
				}
			}
			else
			{
				iHealth = get_user_health(i);
				if(iHealth > 1) set_pev(i, pev_health, iHealth - 1.0);
				else ExecuteHamB(Ham_Killed, i, i, 0);
			}
		}
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
	static iszWeaponStrip;
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
	switch(id)
	{
		case 0:
		{
			message_begin(iReliable ? MSG_ALL : MSG_BROADCAST, MsgId_ScreenFade);
			write_short(iDuration);
			write_short(iHoldTime);
			write_short(iFlags);
			write_byte(iRed);
			write_byte(iGreen);
			write_byte(iBlue);
			write_byte(iAlpha);
			message_end();
		}
		default:
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
	}
}

stock CREATE_BEAMCYLINDER(Float:fOrigin[3], iRadius, pSprite, iStartFrame = 0, iFrameRate = 0, iLife, iWidth, iAmplitude = 0, iRed, iGreen, iBlue, iBrightness, iScrollSpeed = 0)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2]);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2] + 16.0 + iRadius * 2);
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