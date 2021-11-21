#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
//#include <zombieplague>

#define IsCustomItem(%1) (get_pdata_int(%1, m_iId, linux_diff_weapon) == CSW_KNIFE)
#define IsUserHasJanus9(%1) Get_Bit(gl_iBitUserHasJanus9, %1)
#define getJanusSlashTimes(%1) (get_pdata_int(%1, m_iSlashTimes, linux_diff_weapon))
#define getJanusMode(%1) (get_pdata_int(%1, m_iHasJanusMode, linux_diff_weapon))
#define IsValidPlayer(%0) (%0 && %0 <= 32)	

native jbm_is_friendlyfire();
native jbm_is_user_duel(id);
native jbm_get_user_team(id);
native jbm_is_box();
native addWanted(iVictim, iAttacker);

#define m_iAttackType m_iGlock18ShotsFired // Attack type (slash / stab)
#define m_iSlashTimes m_iWeaponState // Slash times
#define m_iHasJanusMode m_iFamasShotsFired // Has JANUS mode
#define m_flResetModel m_flNextReload // Reset p_ mode model
#define pev_janustime pev_fuser4 // Time of JANUS mode

#define Get_Bit(%1,%2) ((%1 & (1 << (%2 & 31))) ? 1 : 0)
#define Set_Bit(%1,%2) %1 |= (1 << (%2 & 31))
#define Reset_Bit(%1,%2) %1 &= ~(1 << (%2 & 31))
#define Invert_Bit(%1,%2) ((%1) ^= (1 << (%2)))

#define PDATA_SAFE 2
#define OBS_IN_EYE 4
#define DONT_BLEED -1
#define ACT_RANGE_ATTACK1 28

// Linux extra offsets
#define linux_diff_animating 4
#define linux_diff_weapon 4
#define linux_diff_player 5

// CBaseAnimating
#define m_flFrameRate 36
#define m_flGroundSpeed 37
#define m_flLastEventCheck 38
#define m_fSequenceFinished 39
#define m_fSequenceLoops 40

// CBasePlayerItem
#define m_pPlayer 41
#define m_iId 43

// CBasePlayerWeapon
#define m_flNextPrimaryAttack 46
#define m_flNextSecondaryAttack 47
#define m_flTimeWeaponIdle 48
#define m_iGlock18ShotsFired 70
#define m_iFamasShotsFired 72
#define m_iWeaponState 74
#define m_flNextReload 75

// CBaseMonster
#define m_Activity 73
#define m_IdealActivity 74
#define m_LastHitGroup 75
#define m_flNextAttack 83

// CBasePlayer
#define m_iPlayerTeam 114
#define m_flLastAttackTime 220
#define m_pActiveItem 373
#define m_szAnimExtention 492

#define JANUS9_ANIM_IDLE_TIME 51/30.0
#define JANUS9_ANIM_END_S_TIME 8/30.0
#define JANUS9_ANIM_SLASH1_TIME 43/30.0
#define JANUS9_ANIM_DRAW_TIME 31/30.0
#define JANUS9_ANIM_STAB_TIME 55/30.0

enum _: eAnimList
{
	JANUS9_ANIM_IDLE_A = 0,
	JANUS9_ANIM_IDLE_S,
	JANUS9_ANIM_END_S,
	JANUS9_ANIM_SLASH1_A,
	JANUS9_ANIM_SLASH1_TO_S,
	JANUS9_ANIM_SLASH1_S,
	JANUS9_ANIM_SLASH2_A,
	JANUS9_ANIM_SLASH2_TO_S,
	JANUS9_ANIM_SLASH2_S,
	JANUS9_ANIM_DRAW_A,
	JANUS9_ANIM_DRAW_S,
	JANUS9_ANIM_STAB1,
	JANUS9_ANIM_STAB2
};

enum _: eHitResultList
{
	SLASH_HIT_NONE = 0,
	SLASH_HIT_WORLD,
	SLASH_HIT_ENTITY
};

enum _: eAttackType
{
	STATE_NONE = 0,
	STATE_SLASH,
	STATE_STAB
};

#define JANUS9_WEAPON_REFERENCE "weapon_knife"
#define JANUS9_ANIM_EXTENSION "knife" // CSO: tomahawk
#define JANUS9_ANIM_EXTENSION_B "knife" // CSO: skullaxe

#define JANUS9_MODEL_VIEW "models/x/v_janus9.mdl"
#define JANUS9_MODEL_PLAYER_A "models/x/p_janus9_a.mdl"

#define JANUS9_NEXT_ATTACK 0.55 // Next time for slashes
#define JANUS9_STAB_HIT_REGISTER 8/30.0 // Time for hit in STAB
#define JANUS9_ACTIVE_TIME 3.0 // Active time for JANUS mode

// Slash
#define JANUS9_SLASH_DAMAGE 30.0
#define JANUS9_SLASH_DISTANCE 100.0

new Float: flAngles_Slash[] = { 0.0, 2.5, -2.5, 5.0, -5.0, 7.5, -7.5 };
new Float: flAnglesUp_Slash[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

// Stab
#define JANUS9_STAB_DAMAGE 90.0
#define JANUS9_STAB_DISTANCE 150.0

new Float: flAngles_Stab[] = { 0.0, -2.5, 2.5, -5.0, 5.0, -7.5, 7.5, -10.0, 10.0, -12.5, 12.5, -15.0, 15.0, -17.5, 17.5, -20.0, 2.0 };
new Float: flAnglesUp_Stab[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

new const JANUS9_SOUNDS[][] =
{
	"weapons/janus9_hit1.wav", // 0 - Hit
	"weapons/janus9_hit2.wav", // 1 - Hit B
	"weapons/janus9_stone1.wav", // 2 - Wall
	"weapons/janus9_stone2.wav", // 3 - Wall
	"weapons/janus9_slash1.wav", // 4 - Miss A
	"weapons/janus9_slash2_signal.wav", // 5 - Miss B
	"weapons/janus9_draw.wav", // 6 - Draw
	"weapons/janus9_endsignal.wav" // 7 - End signal
};

new gl_iBitUserHasJanus9,
	
	gl_iszModelIndexBloodSpray,
	gl_iszModelIndexBloodDrop;

	//gl_iItemID;

public plugin_init()
{
	// Twitch: https://www.twitch.tv/t3rkecorejz1337
	// VK Group: https://vk.com/t3_plugins
	// VK Page: https://vk.com/just_terke
	register_plugin("[ZP] Knife: JANUS-9",	"2019 | 26.02.2019", "xyUnicorn (t3rkecorejz)");

	register_forward(FM_UpdateClientData, 	"FM_Hook_UpdateClientData_Post", true);

	RegisterHam(Ham_Item_PostFrame, 		JANUS9_WEAPON_REFERENCE, "CKnife__PostFrame_Pre", false);
	RegisterHam(Ham_Item_Holster, 			JANUS9_WEAPON_REFERENCE, "CKnife__Holster_Post", true);
	RegisterHam(Ham_Item_Deploy, 			JANUS9_WEAPON_REFERENCE, "CKnife__Deploy_Post", true);
	RegisterHam(Ham_Weapon_WeaponIdle, 		JANUS9_WEAPON_REFERENCE, "CKnife__Idle_Pre", false);
	RegisterHam(Ham_Weapon_PrimaryAttack, 	JANUS9_WEAPON_REFERENCE, "CKnife__PrimaryAttack_Pre", false);
	RegisterHam(Ham_Weapon_SecondaryAttack,	JANUS9_WEAPON_REFERENCE, "CKnife__SecondaryAttack_Pre", false);

	//gl_iItemID = zp_register_extra_item("JANUS-IX \d(Melee)", 20, ZP_TEAM_HUMAN);
}

public plugin_precache()
{
	// Sounds
	for(new i = 0; i < sizeof JANUS9_SOUNDS; i++)
		engfunc(EngFunc_PrecacheSound, JANUS9_SOUNDS[i]);

	// Models
	engfunc(EngFunc_PrecacheModel, JANUS9_MODEL_VIEW);
	engfunc(EngFunc_PrecacheModel, JANUS9_MODEL_PLAYER_A);

	// Model Index
	gl_iszModelIndexBloodSpray = engfunc(EngFunc_PrecacheModel, "sprites/bloodspray.spr");
	gl_iszModelIndexBloodDrop = engfunc(EngFunc_PrecacheModel, "sprites/blood.spr");
}

public plugin_natives()
{
	register_native("zp_user_has_janus9", "Command__GetJanus9", 1);
	register_native("zp_give_user_janus9", "Command__GiveJanus9", 1);
	register_native("zp_delete_user_janus9", "Command__DelJanus9", 1);
}

public Command__GetJanus9(iPlayer) return IsUserHasJanus9(iPlayer);
public Command__GiveJanus9(iPlayer)
{
	Set_Bit(gl_iBitUserHasJanus9, iPlayer);

	new iItem = get_pdata_cbase(iPlayer, m_pActiveItem, linux_diff_player);
	if(is_user_alive(iPlayer) && get_pdata_int(iItem, m_iId, linux_diff_weapon) == CSW_KNIFE)
	{
		if(pev_valid(iItem) == PDATA_SAFE)
			ExecuteHamB(Ham_Item_Deploy, iItem);
	}
}
public Command__DelJanus9(iPlayer) return Reset_Bit(gl_iBitUserHasJanus9, iPlayer);

/* [ Fakemeta ] */
public FM_Hook_UpdateClientData_Post(iPlayer, SendWeapons, CD_Handle)
{
	if(!is_user_alive(iPlayer)) return;
	if(!IsUserHasJanus9(iPlayer)) return;

	static iItem; iItem = get_pdata_cbase(iPlayer, m_pActiveItem, linux_diff_player);
	if(pev_valid(iItem) != PDATA_SAFE || !IsCustomItem(iItem)) return;

	set_cd(CD_Handle, CD_flNextAttack, get_gametime() + 0.001);
}

/* [ HamSandwich ] */
public CKnife__PostFrame_Pre(iItem)
{
	new iPlayer = get_pdata_cbase(iItem, m_pPlayer, linux_diff_weapon);
	if(!IsUserHasJanus9(iPlayer) ) return HAM_IGNORED;

	static Float: flGameTime; flGameTime = get_gametime();
	static Float: flActiveTime; pev(iItem, pev_janustime, flActiveTime);
	static Float: flResetModel; flResetModel = get_pdata_float(iItem, m_flResetModel, linux_diff_weapon);
	static iAttackType; iAttackType = get_pdata_int(iItem, m_iAttackType, linux_diff_weapon)

	// Reset JANUS mode (if not used JANUS mode)
	if(getJanusMode(iItem) && flActiveTime < flGameTime)
	{
		set_pdata_int(iItem, m_iHasJanusMode, 0, linux_diff_weapon);
		set_pdata_int(iItem, m_iSlashTimes, 0, linux_diff_weapon);

		UTIL_SendWeaponAnim(iPlayer, JANUS9_ANIM_END_S);
		emit_sound(iPlayer, CHAN_ITEM, JANUS9_SOUNDS[7], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

		set_pdata_float(iPlayer, m_flNextAttack, JANUS9_ANIM_END_S_TIME, linux_diff_player);
		set_pdata_float(iItem, m_flNextPrimaryAttack, JANUS9_ANIM_END_S_TIME, linux_diff_weapon);
		set_pdata_float(iItem, m_flNextSecondaryAttack, JANUS9_ANIM_END_S_TIME, linux_diff_weapon);
		set_pdata_float(iItem, m_flTimeWeaponIdle, JANUS9_ANIM_END_S_TIME, linux_diff_weapon);
	}

	// STAB attack
	if(iAttackType == STATE_STAB)
	{
		// Register hit
		{
			UTIL_FakeTraceLine(iPlayer, 1, 5, JANUS9_STAB_DISTANCE, JANUS9_STAB_DAMAGE, flAngles_Stab, flAnglesUp_Stab, sizeof flAngles_Stab);
		}

		// Reset p_ model after STAB attack
		if(flResetModel <= flGameTime && flResetModel != 0.0)
		{
			set_pev(iPlayer, pev_weaponmodel2, JANUS9_MODEL_PLAYER_A);
			set_pdata_float(iItem, m_flResetModel, 0.0, linux_diff_weapon);
		}
	}

	if(iAttackType != STATE_NONE)
	{
		set_pdata_int(iItem, m_iAttackType, STATE_NONE, linux_diff_weapon);
	}

	return HAM_IGNORED;
}

public CKnife__Holster_Post(iItem)
{
	new iPlayer = get_pdata_cbase(iItem, m_pPlayer, linux_diff_weapon);
	if(!IsUserHasJanus9(iPlayer)) return;

	set_pdata_int(iItem, m_iAttackType, STATE_NONE, linux_diff_weapon);
	set_pdata_float(iItem, m_flResetModel, 0.0, linux_diff_weapon);
}

public CKnife__Deploy_Post(iItem)
{
	new iPlayer = get_pdata_cbase(iItem, m_pPlayer, linux_diff_weapon);
	if(!IsUserHasJanus9(iPlayer)) return;

	set_pev(iPlayer, pev_viewmodel2, JANUS9_MODEL_VIEW);
	set_pev(iPlayer, pev_weaponmodel2, JANUS9_MODEL_PLAYER_A);

	UTIL_SendWeaponAnim(iPlayer, getJanusMode(iItem) ? JANUS9_ANIM_DRAW_S : JANUS9_ANIM_DRAW_A);
	emit_sound(iPlayer, CHAN_ITEM, JANUS9_SOUNDS[6], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	set_pdata_float(iItem, m_flTimeWeaponIdle, JANUS9_ANIM_DRAW_TIME, linux_diff_weapon);
	set_pdata_float(iPlayer, m_flNextAttack, JANUS9_ANIM_DRAW_TIME, linux_diff_player);
	set_pdata_string(iPlayer, m_szAnimExtention * 4, JANUS9_ANIM_EXTENSION, -1, linux_diff_player * linux_diff_animating);
}

public CKnife__Idle_Pre(iItem)
{
	if(get_pdata_float(iItem, m_flTimeWeaponIdle, linux_diff_weapon) > 0.0) return HAM_IGNORED;

	new iPlayer = get_pdata_cbase(iItem, m_pPlayer, linux_diff_weapon);
	if(!IsUserHasJanus9(iPlayer)) return HAM_IGNORED;

	UTIL_SendWeaponAnim(iPlayer, getJanusMode(iItem) ? JANUS9_ANIM_IDLE_S : JANUS9_ANIM_IDLE_A);
	set_pdata_float(iItem, m_flTimeWeaponIdle, JANUS9_ANIM_IDLE_TIME, linux_diff_weapon);

	return HAM_SUPERCEDE;
}

new iAnim;
public CKnife__PrimaryAttack_Pre(iItem)
{
	new iPlayer = get_pdata_cbase(iItem, m_pPlayer, linux_diff_weapon);
	if(!IsUserHasJanus9(iPlayer)) return HAM_IGNORED;

	set_pdata_int(iItem, m_iSlashTimes, getJanusSlashTimes(iItem) + 1, linux_diff_weapon);
	iAnim = !iAnim;

	if(getJanusSlashTimes(iItem) >= 2)
	{
		if(getJanusMode(iItem))
		{
			UTIL_SendWeaponAnim(iPlayer, JANUS9_ANIM_SLASH1_S + (iAnim ? 3 : 0));
		}
		else
		{
			UTIL_SendWeaponAnim(iPlayer, JANUS9_ANIM_SLASH1_TO_S + (iAnim ? 3 : 0));
			set_pdata_int(iItem, m_iHasJanusMode, 1, linux_diff_weapon);
		}

		set_pev(iItem, pev_janustime, get_gametime() + JANUS9_ACTIVE_TIME);
	}
	else
	{
		UTIL_SendWeaponAnim(iPlayer, JANUS9_ANIM_SLASH1_A + (iAnim ? 3 : 0));
	}

	UTIL_FakeTraceLine(iPlayer, 0, iAnim ? 4 : 5, JANUS9_SLASH_DISTANCE, JANUS9_SLASH_DAMAGE, flAngles_Slash, flAnglesUp_Slash, sizeof flAngles_Slash);
	
	// Player animation
	static szAnimation[64];
	formatex(szAnimation, charsmax(szAnimation), pev(iPlayer, pev_flags) & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", JANUS9_ANIM_EXTENSION);
	UTIL_PlayerAnimation(iPlayer, szAnimation);

	set_pdata_int(iItem, m_iAttackType, STATE_SLASH, linux_diff_weapon);
	set_pdata_float(iPlayer, m_flNextAttack, JANUS9_NEXT_ATTACK, linux_diff_player);
	set_pdata_float(iItem, m_flNextPrimaryAttack, JANUS9_NEXT_ATTACK, linux_diff_weapon);
	set_pdata_float(iItem, m_flNextSecondaryAttack, JANUS9_NEXT_ATTACK, linux_diff_weapon);
	set_pdata_float(iItem, m_flTimeWeaponIdle, JANUS9_ANIM_SLASH1_TIME, linux_diff_weapon);

	return HAM_SUPERCEDE;
}

public CKnife__SecondaryAttack_Pre(iItem)
{
	new iPlayer = get_pdata_cbase(iItem, m_pPlayer, linux_diff_weapon);
	if(!IsUserHasJanus9(iPlayer)) return HAM_IGNORED;
	if(!getJanusMode(iItem) || getJanusSlashTimes(iItem) < 2) return HAM_SUPERCEDE;

	set_pdata_int(iItem, m_iSlashTimes, 0, linux_diff_weapon);
	set_pdata_int(iItem, m_iHasJanusMode, 0, linux_diff_weapon);

	UTIL_SendWeaponAnim(iPlayer, random_num(JANUS9_ANIM_STAB1, JANUS9_ANIM_STAB2));

	// Player animation
	static szAnimation[64];
	formatex(szAnimation, charsmax(szAnimation), pev(iPlayer, pev_flags) & FL_DUCKING ? "crouch_shoot_%s" : "ref_shoot_%s", JANUS9_ANIM_EXTENSION_B);
	UTIL_PlayerAnimation(iPlayer, szAnimation);

	set_pdata_int(iItem, m_iAttackType, STATE_STAB, linux_diff_weapon);
	set_pdata_float(iItem, m_flResetModel, JANUS9_ANIM_STAB_TIME + get_gametime(), linux_diff_weapon);

	set_pdata_float(iPlayer, m_flNextAttack, JANUS9_STAB_HIT_REGISTER, linux_diff_player);
	set_pdata_float(iItem, m_flNextPrimaryAttack, JANUS9_ANIM_STAB_TIME, linux_diff_weapon);
	set_pdata_float(iItem, m_flNextSecondaryAttack, JANUS9_ANIM_STAB_TIME, linux_diff_weapon);
	set_pdata_float(iItem, m_flTimeWeaponIdle, JANUS9_ANIM_STAB_TIME, linux_diff_weapon);

	return HAM_SUPERCEDE;
}

/* [ Stocks ] */
stock UTIL_SendWeaponAnim(iPlayer, iAnim)
{
	set_pev(iPlayer, pev_weaponanim, iAnim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, iPlayer);
	write_byte(iAnim);
	write_byte(0);
	message_end();
}

stock UTIL_PlayerAnimation(iPlayer, szAnim[])
{
	new iAnimDesired, Float: flFrameRate, Float: flGroundSpeed, bool: bLoops;
		
	if((iAnimDesired = lookup_sequence(iPlayer, szAnim, flFrameRate, bLoops, flGroundSpeed)) == -1)
		iAnimDesired = 0;
	
	new Float: flGameTime = get_gametime();

	set_pev(iPlayer, pev_frame, 0.0);
	set_pev(iPlayer, pev_framerate, 1.0);
	set_pev(iPlayer, pev_animtime, flGameTime);
	set_pev(iPlayer, pev_sequence, iAnimDesired);
	
	set_pdata_int(iPlayer, m_fSequenceLoops, bLoops, linux_diff_animating);
	set_pdata_int(iPlayer, m_fSequenceFinished, 0, linux_diff_animating);
	
	set_pdata_float(iPlayer, m_flFrameRate, flFrameRate, linux_diff_animating);
	set_pdata_float(iPlayer, m_flGroundSpeed, flGroundSpeed, linux_diff_animating);
	set_pdata_float(iPlayer, m_flLastEventCheck, flGameTime , linux_diff_animating);
	
	set_pdata_int(iPlayer, m_Activity, ACT_RANGE_ATTACK1, linux_diff_player);
	set_pdata_int(iPlayer, m_IdealActivity, ACT_RANGE_ATTACK1, linux_diff_player);
	set_pdata_float(iPlayer, m_flLastAttackTime, flGameTime , linux_diff_player);
}

stock UTIL_FakeTraceLine(iPlayer, iHitSound, iSlashSound, Float: flDistance, Float: flDamage, Float: flSendAngles[], Float: flSendAnglesUp[], iSendAngles)
{
	new Float: flOrigin[3], Float: flAngle[3], Float: flEnd[3], Float: flViewOfs[3];
	new Float: flForw[3], Float: flUp[3], Float: flRight[3];

	pev(iPlayer, pev_origin, flOrigin);
	pev(iPlayer, pev_view_ofs, flViewOfs);

	flOrigin[0] += flViewOfs[0];
	flOrigin[1] += flViewOfs[1];
	flOrigin[2] += flViewOfs[2];
			
	pev(iPlayer, pev_v_angle, flAngle);
	engfunc(EngFunc_AngleVectors, flAngle, flForw, flRight, flUp);

	new iTrace = create_tr2();

	new Float: flTan;
	new Float: flMul;

	static Float: flFraction, pHit;
	static pHitEntity; pHitEntity = SLASH_HIT_NONE;
	static iHitResult; iHitResult = SLASH_HIT_NONE;

	for(new i; i < iSendAngles; i++)
	{
		flTan = floattan(flSendAngles[i], degrees);

		flEnd[0] = (flForw[0] * flDistance) + (flRight[0] * flTan * flDistance) + flUp[0] * flSendAnglesUp[i];
		flEnd[1] = (flForw[1] * flDistance) + (flRight[1] * flTan * flDistance) + flUp[1] * flSendAnglesUp[i];
		flEnd[2] = (flForw[2] * flDistance) + (flRight[2] * flTan * flDistance) + flUp[2] * flSendAnglesUp[i];
			
		flMul = (flDistance/vector_length(flEnd));
		flEnd[0] *= flMul;
		flEnd[1] *= flMul;
		flEnd[2] *= flMul;

		flEnd[0] = flEnd[0] + flOrigin[0];
		flEnd[1] = flEnd[1] + flOrigin[1];
		flEnd[2] = flEnd[2] + flOrigin[2];

		engfunc(EngFunc_TraceLine, flOrigin, flEnd, DONT_IGNORE_MONSTERS, iPlayer, iTrace);
		get_tr2(iTrace, TR_flFraction, flFraction);

		if(flFraction == 1.0)
		{
			engfunc(EngFunc_TraceHull, flOrigin, flEnd, HULL_HEAD, iPlayer, iTrace);
			get_tr2(iTrace, TR_flFraction, flFraction);
		
			engfunc(EngFunc_TraceLine, flOrigin, flEnd, DONT_IGNORE_MONSTERS, iPlayer, iTrace);
			pHit = get_tr2(iTrace, TR_pHit);
		}
		else
		{
			pHit = get_tr2(iTrace, TR_pHit);
		}

		if(flFraction != 1.0)
		{
			if(!iHitResult) iHitResult = SLASH_HIT_WORLD;
		}

		if(pHit > 0 && pHitEntity != pHit)
		{
			if(pev(pHit, pev_solid) == SOLID_BSP && !(pev(pHit, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY))
			{
				ExecuteHamB(Ham_TakeDamage, pHit, iPlayer, iPlayer, flDamage, DMG_NEVERGIB | DMG_CLUB);
			}
			else
			{
				UTIL_FakeTraceAttack(pHit, iPlayer, flDamage, flForw, iTrace, DMG_NEVERGIB | DMG_CLUB);
			}

			iHitResult = SLASH_HIT_ENTITY;
			pHitEntity = pHit;
		}
	}

	switch(iHitResult)
	{
		case SLASH_HIT_NONE: emit_sound(iPlayer, CHAN_WEAPON, JANUS9_SOUNDS[iSlashSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		case SLASH_HIT_WORLD: emit_sound(iPlayer, CHAN_WEAPON, JANUS9_SOUNDS[random_num(2, 3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		case SLASH_HIT_ENTITY: emit_sound(iPlayer, CHAN_WEAPON, JANUS9_SOUNDS[iHitSound], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
}

stock UTIL_FakeTraceAttack(iVictim, iAttacker, Float: flDamage, Float: vecDirection[3], iTrace, ibitsDamageBits)
{
	static Float: flTakeDamage; pev(iVictim, pev_takedamage, flTakeDamage);
	if(flTakeDamage == DAMAGE_NO || is_user_connected(iVictim) && (jbm_is_user_duel(iVictim) || (jbm_get_user_team(iVictim) == jbm_get_user_team(iAttacker) && !jbm_is_friendlyfire() && !jbm_is_box()))) 
		return 0;

	if(IsValidPlayer(iVictim) && jbm_get_user_team(iVictim) == 2 && jbm_get_user_team(iAttacker) == 1)
	{
		addWanted(iVictim, iAttacker);
	}
	if(!(is_user_alive(iVictim))) return 0;

	static iHitgroup; iHitgroup = get_tr2(iTrace, TR_iHitgroup);
	static Float: vecEndPos[3]; get_tr2(iTrace, TR_vecEndPos, vecEndPos);
	
	set_pdata_int(iVictim, m_LastHitGroup, iHitgroup, linux_diff_player);

	switch(iHitgroup) 
	{
		case HIT_HEAD:                  flDamage *= 3.0;
		case HIT_LEFTARM, HIT_RIGHTARM: flDamage *= 0.75;
		case HIT_LEFTLEG, HIT_RIGHTLEG: flDamage *= 0.75;
		case HIT_STOMACH:               flDamage *= 1.5;
	}
	
	ExecuteHamB(Ham_TakeDamage, iVictim, iAttacker, iAttacker, flDamage, ibitsDamageBits);

	return 1;
}

public UTIL_BloodDrips(Float:vecOrigin[3], iColor, iAmount)
{
	if(iAmount > 255) iAmount = 255;
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BLOODSPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(gl_iszModelIndexBloodSpray);
	write_short(gl_iszModelIndexBloodDrop);
	write_byte(iColor);
	write_byte(min(max(3, iAmount / 10), 16));
	message_end();
}