// |-- Специально для vk.com/ragashop
// |-- Автор идеи игры: Dorus


#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include < reapi >

#pragma semicolon 1

#define SetBit(%0,%1) 			((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) 		((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) 		((%0) & (1 << (%1)))
#define InvertBit(%0,%1) 		((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) 		(~(%0) & (1 << (%1)))

const MsgId_CurWeapon 				= 66;
const MsgId_SayText 				= 76;
const MsgId_ScreenFade 				= 98;
const m_flNextAttack 				= 83;
const TASK_DEAD_SKILL				= 142567;

native jbm_register_day_mode(szLang[32], iBlock, iTime);
native jbm_get_user_team(id);
native jbm_set_user_model(id, const szModel[]);
native jbm_is_user_connected(id);

enum _:DATA_GAME
{
	HEALTH_TT, 
	TIME_EXPLODE_TT, 
	RELOAD_CT
}

new g_iGameParam[DATA_GAME], g_iDaySuicide, bool:g_bDayModeStatus, g_iMaxPlayers, /*g_iSyncHud,*/ g_pSpriteWave, g_pSpriteExplode, g_iBitUserDead,  HamHook:g_iHamHookForwards[15];
new const g_szHamHookEntityBlock[][] = {
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

public plugin_precache() {
	engfunc(EngFunc_PrecacheModel, "models/player/jbr_dm_suicide/jbr_dm_suicide.mdl");
	engfunc(EngFunc_PrecacheSound, "jb_red/Games/Suicide/allah-akbar.wav");
	//engfunc(EngFunc_PrecacheSound, "jb_red/Games/Suicide/taser_shoot.wav");
	g_pSpriteWave = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr");
	g_pSpriteExplode = engfunc(EngFunc_PrecacheModel, "sprites/dexplo.spr");
}

public plugin_init() {
	register_plugin("[JBR GAME] Dead", "2.0", "Ragamafona");
	new i;
	for(i = 0; i <= 7; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	for(i = 8; i <= 12; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
	DisableHamForward(g_iHamHookForwards[13] = RegisterHam(Ham_Weapon_PrimaryAttack ,"weapon_deagle","Ham_PrimaryAttack_Deagle"));
	DisableHamForward(g_iHamHookForwards[14] = RegisterHam(Ham_Killed, "player", "Ham_Killed_Player", true));
	register_clcmd("drop", "ClCmd_Drop");
	
	g_iDaySuicide = jbm_register_day_mode("JBR_DAY_MODE_DEAD", 3, 160);
	g_iMaxPlayers = get_member_game(m_nMaxPlayers);
	//g_iSyncHud = CreateHudSyncObj();
	
	// >>>>>>>>>>[ Регистрируем квары  ]<<<<<<<<<<
	register_cvar("suicide_health_tt", "1");
	register_cvar("suicide_boomtime_tt", "10");
	register_cvar("suicide_reload_ct", "10");
}

public plugin_cfg() {
	// >>>>>>>>>>[ Получаем значения кваров  ]<<<<<<<<<<
	server_cmd("exec addons/amxmodx/configs/jbr_mode/cfg/game_config.cfg");
	g_iGameParam[HEALTH_TT] 			= get_cvar_num("suicide_health_tt");
	g_iGameParam[TIME_EXPLODE_TT] 		= get_cvar_num("suicide_boomtime_tt");
	g_iGameParam[RELOAD_CT] 			= get_cvar_num("suicide_reload_ct");
}

public ClCmd_Drop(id) {
	if( g_bDayModeStatus )
	{
		if(IsNotSetBit(g_iBitUserDead, id) && is_user_alive(id)) 
		{
			set_task(float(g_iGameParam[TIME_EXPLODE_TT]), "Function_Suicide", id + TASK_DEAD_SKILL );
			fm_set_user_rendering(id, kRenderFxGlowShell, 255.0, 0.0, 0.0, kRenderNormal, 0.0); 
			emit_sound(id, CHAN_AUTO, "jb_red/Games/Suicide/allah-akbar.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			UTIL_BarTime(id, g_iGameParam[TIME_EXPLODE_TT]);
			SetBit(g_iBitUserDead, id);
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public HamHook_EntityBlock() return HAM_SUPERCEDE;
public Ham_PrimaryAttack_Deagle(iWeapon) 
{
	static id; id = get_member( iWeapon, m_pPlayer );
	//emit_sound( id, CHAN_WEAPON, "jb_red/Games/Suicide/taser_shoot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	set_member( id, m_flNextAttack, float( g_iGameParam[ RELOAD_CT ] ) );
	UTIL_BarTime( id, ( g_iGameParam[ RELOAD_CT ] + 2 ) );
	
	return PLUGIN_HANDLED;
}
public Ham_Killed_Player(iVictim) {
	if( jbm_get_user_team( iVictim ) == 1 )
	{
		remove_task( iVictim + TASK_DEAD_SKILL );
		fm_set_user_rendering( iVictim, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0 );
	}
}

public jbm_day_mode_start(iDayMode, iAdmin) {
	if(iDayMode == g_iDaySuicide) {
		new i;
		for(i = 1; i <= g_iMaxPlayers; i++) {
			if(!is_user_connected(i) || !is_user_alive(i)) continue;
			switch(jbm_get_user_team(i)) {
				case 1: 
				{
					jbm_set_user_model(i, "jbr_dm_suicide");
					ClearBit(g_iBitUserDead, i);
					rg_remove_all_items(i);
					if(g_iGameParam[HEALTH_TT]) set_entvar(i, var_health, float(g_iGameParam[HEALTH_TT]));

					set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 0.0, 15.0, 1.0, 1.0);
					show_dhudmessage(i, "• < Подсказка > •^nСпособность [Взорвать себя (G)].^nВзорвитесь возле охраны чтобы убить её!");
				}
				case 2:
				 {
					SetBit(g_iBitUserDead, i);
					rg_remove_all_items(i);
					rg_give_item(i, "weapon_deagle");
					rg_set_user_bpammo(i, WEAPON_DEAGLE, 250);
				}
			}
		}
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
		g_bDayModeStatus = true;
	}
}

public jbm_day_mode_ended(iDayMode, iWinTeam) {
	if(iDayMode == g_iDaySuicide) {
		new i;
		for(i = 0; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
		for(i = 1; i <= g_iMaxPlayers; i++) {
			if(is_user_connected(i) && is_user_alive(i)) {
				remove_task(i+TASK_DEAD_SKILL);
				ClearBit(g_iBitUserDead, i);
				switch(jbm_get_user_team(i)) {
					case 1: {
						if(!iWinTeam) ExecuteHamB(Ham_Killed, i, i, 0);
						else fm_set_user_rendering(i, kRenderFxNone, 0.0, 0.0, 0.0, kRenderNormal, 0.0);
					}
					case 2:{
						rg_remove_all_items(i);
					}
				}
			}
		}
		client_cmd(0, "mp3 stop");
		g_bDayModeStatus = false;
	}
}

public Function_Suicide( pPlayer )	{
	remove_task( pPlayer );
	pPlayer -= TASK_DEAD_SKILL;
	
	static Float:fOrigin[ 3 ]; get_entvar( pPlayer, var_origin, fOrigin );
	
	new iVictim = -1;
	while( ( iVictim = find_ent_in_sphere( iVictim, fOrigin, 150.0 ) ) != 0 )
	{
		if( !is_user_alive( iVictim ) || jbm_get_user_team( iVictim ) != 2 )
			continue;
		
		ExecuteHamB( Ham_TakeDamage, iVictim, pPlayer, pPlayer, 999.0, DMG_SONIC );
	}
	
	if( get_entvar( pPlayer, var_flags ) & FL_DUCKING ) 
		fOrigin[ 2 ] -= 15.0;
	else 
		fOrigin[ 2 ] -= 33.0;
	
	CREATE_BEAMCYLINDER( fOrigin, 150, g_pSpriteWave, _, _, 10, 80, 140, 255, 255, 0, 255, _ );
	RM_CreateExplode( fOrigin, g_pSpriteExplode, 10, 10, 0, 0 );
	user_kill( pPlayer );
}

stock RM_CreateExplode(Float:fOrigin[3], pSprite, iScale, iFrameRate = 0, iFlags = 0, iReliable = 0) {    
	message_begin(iReliable ? MSG_ALL : MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, fOrigin[0]);
	engfunc(EngFunc_WriteCoord, fOrigin[1]);
	engfunc(EngFunc_WriteCoord, fOrigin[2]); 
	write_short(pSprite);
	write_byte(iScale);
	write_byte(iFrameRate);
	write_byte(iFlags);
	message_end();
}

stock fm_set_user_rendering(id, iRenderFx, Float:flRed, Float:flGreen, Float:flBlue, iRenderMode,  Float:flRenderAmt) {
	new Float:fRenderColor[3];
	fRenderColor[0] = flRed;
	fRenderColor[1] = flGreen;
	fRenderColor[2] = flBlue;
	set_entvar(id, var_renderfx, iRenderFx);
	set_entvar(id, var_rendercolor, fRenderColor);
	set_entvar(id, var_rendermode, iRenderMode);
	set_entvar(id, var_renderamt, flRenderAmt);
}

stock CREATE_BEAMCYLINDER(Float:fOrigin[3], iRadius, pSprite, iStartFrame = 0, iFrameRate = 0, iLife, iWidth, iAmplitude = 0, iRed, iGreen, iBlue, iBrightness, iScrollSpeed = 0) {
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

stock UTIL_BarTime( pPlayer, iTime ) {
	engfunc( EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, 108, { 0.0, 0.0, 0.0 }, pPlayer );
	write_short( iTime );
	message_end();
}