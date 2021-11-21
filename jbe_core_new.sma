#include <amxmodx>
#include <amxmisc> 	
#include <fakemeta>
#include <fun>																	
#include <engine>
#include <hamsandwich>
#include <dhudmessage>
#include <cstrike>
#include <nvault>
#include <sqlx>
	
#define JBE_MODE_VERSION "\y• \dВерсия сборки: \y'v9.0'^n" /////Показывает в меню информации.

#pragma semicolon 1			////Проверка на ";" 1 - Вкл / 0 - Выкл

#define CVAR_MODEL_DEVIL "models/player/jbe_devil_model/jbe_devil_model.mdl"
#define CVAR_MODEL_DEDECTIV "models/player/detectiv/detectiv.mdl"

#define jbe_is_user_valid(%0) (%0 && %0 <= g_iMaxPlayers)
#define MAX_PLAYERS 32
#define IUSER1_DOOR_KEY 376027
#define IUSER1_BUYZONE_KEY 140658
#define IUSER1_FROSTNADE_KEY 235876
#define TASK_ID_FROZENT 335876
#define PLAYERS_PER_PAGE 8

#define HUD_HIDE_MONEY (1<<5) ////Деньги (Значения не трогать)
#define HUD_HIDE_RHA (1<<3) ////Радар, хп, броня (Значения не трогать)
#define HIDE_TIMER (1<<4) ////Убираем таймер (Полезно для REHLDS) (Значения не трогать)

#define TOTAL_PLAYER_LEVELS 16
#define MAX_LEVEL TOTAL_PLAYER_LEVELS - 1

/* -> Стартовый цвет информера -> */

#define JBE_INRED 100 ///Красный
#define JBE_INGREEN 100 ///Зеленый
#define JBE_INBLUE 100 ///Синий

/* -> Бит сумм -> */
#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

/* -> Оффсеты -> */
#define linux_diff_weapon 4
#define linux_diff_animating 4
#define linux_diff_player 5
#define ACT_RANGE_ATTACK1 28
#define m_flFrameRate 36
#define m_flGroundSpeed 37
#define m_flLastEventCheck 38
#define m_fSequenceFinished 39
#define m_fSequenceLoops 40
#define m_pPlayer 41
#define m_flNextSecondaryAttack 47
#define m_iClip 51
#define m_Activity 73
#define m_IdealActivity 74
#define m_LastHitGroup 75
#define m_flNextAttack 83
#define m_bloodColor 89
#define m_iPlayerTeam 114
#define m_fHasPrimary 116
#define m_bHasChangeTeamThisRound 125
#define m_flLastAttackTime 220
#define m_afButtonPressed 246
#define m_iHideHUD 361
#define m_iClientHideHUD 362
#define m_iSpawnCount 365
#define m_pActiveItem 373
#define m_flNextDecalTime 486
#define g_szModelIndexPlayer 491
#define MsgId_BarTime 108

/* -> Задачи (Позже поменяю систему) -> */ 
#define TASK_ROUND_END 486787
#define TASK_CHANGE_MODEL 367678
#define TASK_SHOW_INFORMER 769784
#define TASK_FREE_DAY_ENDED 675754
#define TASK_CHIEF_CHOICE_TIME 867475
#define TASK_COUNT_DOWN_TIMER 645876
#define TASK_VOTE_DAY_MODE_TIMER 856365
#define TASK_RESTART_GAME_TIMER 126554
#define TASK_DAY_MODE_TIMER 783456
#define TASK_SHOW_SOCCER_SCORE 756356
#define TASK_INVISIBLE_HAT 254367
#define TASK_REMOVE_SYRINGE 567989
#define TASK_FROSTNADE_DEFROST 645864
#define TASK_DUEL_COUNT_DOWN 567658
#define TASK_DUEL_BEAMCYLINDER 857576
#define TASK_DUEL_TIMER_ATTACK 735756
#define TASK_GOLOD_GAME_TIME 234783
#define TASK_HOOK_THINK 865367
#define TASK_RANK_UPDATE_EXP 4383
#define TASK_RANK_UPDATE_UNVALID 8573
#define TASK_RANK_REWARD_EXP 1312
#define TASK_SHOW_SKILL 342352
#define TASK_FLY_PLAYER 228144
#define TASK_GOLOD_GAME 342423
#define TASK_PAHAN 621416
#define TASK_LAST_DIE 91365

/* -> Индексы сообщений -> */
#define MsgId_CurWeapon 66
#define MsgId_SayText 76
#define MsgId_TextMsg 77
#define MsgId_ResetHUD 79
#define MsgId_ShowMenu 96
#define MsgId_ScreenShake 97
#define MsgId_ScreenFade 98
#define MsgId_SendAudio 100
#define MsgId_Money 102
#define MsgId_StatusText 106
#define MsgId_VGUIMenu 114
#define MsgId_ClCorpse 122
#define MsgId_HudTextArgs 145

#define JBE_IP_LOCK ////Закоментируйте если не нужна привязка к IP сервера
#if defined JBE_IP_LOCK
#define IPNUMBER "80.77.173.82:27041"
#endif

#define TIME_POSITION_CHECK 5.0
#define TIME_POSITION_TASK 3.0
#define INDEX_POSITION_TASK 129910

#define MAX_SPRITES 32

#define MODEL_DOG_CLAWS "models/jb_engine/weapons/dog.mdl" ////Модель рук собаки
#define MODEL_ZOMBIE_KNIFE "models/jb_engine/weapons/v_medsis.mdl" ////Модель рук ревизоро

//#define FOOTBALL_SOUND_START  ////Звуки при футболе (Закомментируйте, чтобы отключить)
#define VALUE_SPEED_CHIEF 300.0  ////Бег начальника

native give_weapon_infinir(id); //Инфинити
native jbe_smotr_open(id);	//Смотритель
native jbe_open_guard_weapon_menu(id); ////Оружие КТ
native Cmd_CostumesMenu(id); //// Костюмы
native jbe_girl_menu_open(id); ////Меню девушки
native block_info(id); ////Получаем статус блокировки игрока за кт


enum _:SHOP_CVARS { SHARPENING, SCREWDRIVER, BALISONG, TOMA, USP, LATCHKEY, FLASHBANG, KOKAIN, STIMULATOR, FROSTNADE, INVISIBLE_HAT, ARMOR, CLOTHING_GUARD, HEGRENADE, HING_JUMP, FAST_RUN,
DOUBLE_JUMP, RANDOM_GLOW, AUTO_BHOP, DOUBLE_DAMAGE, LOW_GRAVITY, CLOSE_CASE, FREE_DAY_SHOP, RESOLUTION_VOICE, TRANSFER_GUARD, LOTTERY_TICKET, PRANK_PRISONER, STIMULATOR_GR, RANDOM_GLOW_GR,
LOTTERY_TICKET_GR, KOKAIN_GR, DOUBLE_JUMP_GR, FAST_RUN_GR, LOW_GRAVITY_GR, INVISIBLE, RESPAWN, GOD, KNIF, PILA, SHOK, DOG_DOLLARS, VODKA }

new g_iShopCvars[SHOP_CVARS];

enum _:ALL_CVARS { FREE_DAY_ID, FREE_DAY_ALL, TEAM_BALANCE, DAY_MODE_VOTE_TIME, RESTART_GAME_TIME, RIOT_START_MODEY, KILLED_GUARD_MODEY,
KILLED_CHIEF_MODEY, ROUND_FREE_MODEY, ROUND_ALIVE_MODEY, LAST_PRISONER_MODEY, VIP_RESPAWN_NUM, VIP_HEALTH_NUM, VIP_MONEY_NUM, VIP_MONEY_ROUND,
VIP_INVISIBLE, VIP_HP_AP_ROUND, VIP_VOICE_ROUND, VIP_DISCOUNT_SHOP, ADMIN_RESPAWN_NUM, ADMIN_HEALTH_NUM, ADMIN_MONEY_NUM, ADMIN_MONEY_ROUND,
ADMIN_GOD_ROUND, ADMIN_FOOTSTEPS_ROUND, ADMIN_DISCOUNT_SHOP, RESPAWN_PLAYER_NUM, ADMIN_AUTOBHOP_ROUND, ADMIN_ELECTRO_ROUND, SKIN_ADMIN, SKIN_KING,
SKIN_ALL, SKIN_FREEDAY, SKIN_WANTED, EXP_TIME, AUTHORITY_MIN, AUTHORITY_MAX, DAY_MODE, CHIEF_HP, SKILL, ZOMBIE_JUMP }

new g_iAllCvars[ALL_CVARS];

enum _:MODEL_CVAR {PRISONER, GUARD, CHIEF, FOOTBALLER, PAHAN, GIRL, OWNER, DOG, ZOMBIE }

new g_szPlayerModel[MODEL_CVAR][18];
	
new g_szRankHost[32], g_szRankUser[32], g_szRankPassword[32], g_szRankDataBase[32],g_iLevel[MAX_PLAYERS + 1], g_iExp[MAX_PLAYERS + 1], g_szRankTable[32], Handle:g_sqlTuple,
g_iAdminElectro[MAX_PLAYERS + 1], g_iUserSkill[MAX_PLAYERS + 1], g_iHookSkill, g_iFreeHook, g_iGolodGMCvars,
g_iSprites[MAX_SPRITES + 1], g_iUserType[MAX_PLAYERS + 1], g_iUserColor[MAX_PLAYERS + 1], bool:g_iResetHud, g_msgHideWeapon, g_bRoundEnd = false, g_iFakeMetaKeyValue, g_iFakeMetaSpawn, g_iFakeMetaUpdateClientData, g_iSyncMainInformer,
g_iSyncSoccerScore, g_iSyncStatusText, g_iSyncDuelInformer, g_iMaxPlayers, g_iFriendlyFire, g_iCountDown, bool:g_bRestartGame = true, Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame,g_pModelGlass, g_bGolod = false,
g_pSpriteWave, g_pSpriteBeam, g_Chat, g_pSpriteBall,g_pSpriteBoss, g_pSpriteDuelRed, g_pSpriteDuelBlue, g_iGlowHook[MAX_PLAYERS + 1],
bool:g_iTrailUser[MAX_PLAYERS + 1] = false, g_iMenuSelectItem[MAX_PLAYERS + 1], g_iMenuSelectMoney[MAX_PLAYERS + 1], g_iPlayersNum[6], g_iAlivePlayersNum[6], Trie:g_tRemoveEntities, bool:g_iDog, g_UserDog, 
g_UserZombie, bool:g_iinformerPogon[MAX_PLAYERS + 1], 
g_iinformerTex, g_iUserFreeHook[MAX_PLAYERS + 1], g_iZombieBichLimited[MAX_PLAYERS + 1], 
g_iZombieBichLimited2[MAX_PLAYERS + 1], g_iZombieStatus[MAX_PLAYERS + 1], 
bool:g_iZombieDow[MAX_PLAYERS + 1], g_iZombieEnd[MAX_PLAYERS + 1], ssoglush = 5;

enum _:TOTAL_EXP_TYPES {SQL_CHECK, SQL_LOAD, SQL_IGNORE};

new const g_szRankName[TOTAL_PLAYER_LEVELS][]= 
{
	"JBE_ID_HUD_RANK_NAME_1", 
	"JBE_ID_HUD_RANK_NAME_2", 
	"JBE_ID_HUD_RANK_NAME_3", 
	"JBE_ID_HUD_RANK_NAME_4", 
	"JBE_ID_HUD_RANK_NAME_5", 
	"JBE_ID_HUD_RANK_NAME_6", 
	"JBE_ID_HUD_RANK_NAME_7", 
	"JBE_ID_HUD_RANK_NAME_8", 
	"JBE_ID_HUD_RANK_NAME_9", 
	"JBE_ID_HUD_RANK_NAME_10", 
	"JBE_ID_HUD_RANK_NAME_11", 
	"JBE_ID_HUD_RANK_NAME_12", 
	"JBE_ID_HUD_RANK_NAME_13", 
	"JBE_ID_HUD_RANK_NAME_14", 
	"JBE_ID_HUD_RANK_NAME_15", 
	"JBE_ID_HUD_RANK_NAME_16" 
};

new const g_szExp[TOTAL_PLAYER_LEVELS]= { 0, 20, 40, 80, 150, 200, 300, 600, 900, 1100, 1600, 3000, 4000, 5000, 8000, 16000 }; ////Индесы опыта (Можно менять)

new g_iDataSprites[][][] = 
{
	{"sprites/logo.spr", "Логотип"},
	{"sprites/laserbeam.spr", "Линия"},
	{"sprites/lgtning.spr", "Молния"}
};

new g_iDataColors[][][] = 
{
	{"Красный", "255", "0", "0"},
	{"Зелёный", "0", "255", "0"},
	{"Синий", "0", "0", "255"},
	{"Желтый", "169", "169", "0"},
	{"Розовый", "218", "112", "214"}
};

static g_iConstMoney[] = 
{
	100, 
	1000, 
	10000, 
	100000, 
	1000000, 
	10000000, 
	100000000
};

/* -> Переменные и массивы для дней и дней недели -> */
new g_iDay, g_iDayWeek, g_iDayGamesLimit;

new ss_Music[5][64];

new const g_szDaysWeek[][] =
{
	"JBE_HUD_DAY_WEEK_0",
	"JBE_HUD_DAY_WEEK_1",
	"JBE_HUD_DAY_WEEK_2",
	"JBE_HUD_DAY_WEEK_3",
	"JBE_HUD_DAY_WEEK_4",
	"JBE_HUD_DAY_WEEK_5",
	"JBE_HUD_DAY_WEEK_6",
	"JBE_HUD_DAY_WEEK_7"
};

/* -> Битсуммы, переменные и массивы для режимов игры -> */
enum _:DATA_DAY_MODE
{
	LANG_MODE[32],
	MODE_BLOCKED,
	VOTES_NUM,
	MODE_TIMER,
	MODE_BLOCK_DAYS
}
new Array:g_aDataDayMode, g_iDayModeListSize, g_iDayModeVoteTime, g_iHookDayModeStart, g_iHookDayModeEnded, g_iReturnDayMode,
g_iDayMode, g_szDayMode[32] = "JBE_HUD_GAME_MODE_0", g_iDayModeTimer, g_szDayTimer[11] = "", g_iVoteDayMode = -1,
g_iBitUserVoteDayMode, g_iBitUserDayModeVoted, g_iDayModeLimit[32], g_iGolodTimerAttack;

/* -> Паутинка -> */
new g_StatusHook[MAX_PLAYERS + 1], g_pSpriteLgtning[6],g_StatusHookEnd[33], g_iSpriteEnd[4], g_iSpeedFly[33], bool:g_iModeFly[33], bool:g_iEnableHook, g_iNvault_Hook, g_iNvault_HookInfo;

/* -> Переменные и массивы для работы с клетками -> */
new bool:g_bDoorStatus, Array:g_aDoorList, g_iDoorListSize, Trie:g_tButtonList;

/* -> Массивы для работы с событиями 'hamsandwich' -> */
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
	"func_button", // Кнопка
	"trigger_hurt", // Наносит игроку повреждения
	"trigger_gravity", // Устанавливает игроку силу гравитации
	"armoury_entity", // Объект лежащий на карте, оружия, броня или гранаты
	"weaponbox", // Оружие выброшенное игроком
	"weapon_shield" // Щит
};
new HamHook:g_iHamHookForwards[14];

enum _:DATA_ROUND_SOUND { FILE_NAME[32], TRACK_NAME[64] }
new Array:g_aDataRoundSound, g_iRoundSoundSize;

/* -> Авторитет -> */
new SzPahanMessage[128], SzPahanName[33],SzRandomizePahan, bool:g_Pahan[33] = false;
	
/* -> Битсуммы -> */
new g_iBitUserConnected, g_iBitUserAlive, g_iBitUserVoice, g_iBitUserSteamVoice, g_iBitUserVoiceNextRound, g_iBitUserModel, g_iBitBlockMenu,
g_iBitKilledUsers[MAX_PLAYERS + 1], g_iBitUserVip, g_iBitUserAdmin, g_iBitUserSuperAdmin, g_iBitUserKing,
g_iBitUserHook, g_iBitUserEEffect, g_iBitUserElectro, g_iBitUserRoundSound;

/* -> Переменные -> */
new g_iLastPnId, g_BlockMenu, g_BlockGuard;

// Переменные Бунтаря и Детектива

    new devil_skin[MAX_PLAYERS + 1] = 1;
    new devil_dollar[MAX_PLAYERS + 1] = 1000;
    new devil_riot[MAX_PLAYERS + 1] = 5;
    new devil_chicken[MAX_PLAYERS + 1] = 12;
	new devil_chickens[MAX_PLAYERS + 1] = 5;
    new devil_damage[MAX_PLAYERS + 1] = 4;
	
	new with_trail[MAX_PLAYERS + 1] = 0;

/* -> Массивы -> */
new g_iUserTeam[MAX_PLAYERS + 1], g_iUserSkin[MAX_PLAYERS + 1], g_iUserMoney[MAX_PLAYERS + 1], g_iUserDiscount[MAX_PLAYERS + 1],
g_szUserModel[MAX_PLAYERS + 1][32], Float:g_fMainInformerPosX[MAX_PLAYERS + 1], Float:g_fMainInformerPosY[MAX_PLAYERS + 1],
Float:g_vecHookOrigin[MAX_PLAYERS + 1][3];

/* -> Массивы для меню из игроков -> */
new g_iMenuPlayers[MAX_PLAYERS + 1][MAX_PLAYERS], g_iMenuPosition[MAX_PLAYERS + 1], g_iMenuTarget[MAX_PLAYERS + 1];

/* -> Переменные и массивы для начальника -> */
new g_iChiefId, g_iChiefIdOld, g_iChiefChoiceTime, g_szChiefName[32], g_iChiefStatus;
new const g_szChiefStatus[][] =
{
	"JBE_HUD_CHIEF_NOT",
	"JBE_HUD_CHIEF_ALIVE",
	"JBE_HUD_CHIEF_DEAD",
	"JBE_HUD_CHIEF_DISCONNECT",
	"JBE_HUD_CHIEF_FREE"
};

/* -> Битсуммы, переменные и массивы для освобождённых заключённых -> */
new g_iBitUserFree, g_iBitUserFreeNextRound, g_szFreeNames[192], g_iFreeLang;
new const g_szFreeLang[][] =
{
	"JBE_HUD_NOT_FREE",
	"JBE_HUD_HAS_FREE"
};

/* -> Битсуммы, переменные и массивы для разыскиваемых заключённых -> */
new g_iBitUserWanted, g_szWantedNames[192], g_iWantedLang;
new const g_szWantedLang[][] =
{
	"JBE_HUD_NOT_WANTED",
	"JBE_HUD_HAS_WANTED"
};

/* -> Битсуммы, переменные и массивы для футбола -> */
new g_iSoccerBall, Float:g_flSoccerBallOrigin[3], bool:g_bSoccerBallTouch, bool:g_bSoccerBallTrail, bool:g_bSoccerStatus,
bool:g_bSoccerGame, g_iSoccerScore[2], g_iBitUserSoccer, g_iSoccerBallOwner, g_iSoccerKickOwner, g_iSoccerUserTeam[MAX_PLAYERS + 1];

/* -> Битсуммы, переменные и массивы для бокса -> */
new bool:g_bBoxingStatus, g_iBoxingGame, g_iBitUserBoxing, g_iBoxingTypeKick[MAX_PLAYERS + 1], g_iBoxingUserTeam[MAX_PLAYERS + 1];

/* -> Битсуммы для магазина -> */
new g_iBitSharpening, g_iBitScrewdriver, g_iBitBalisong, g_iBitToma, g_iBitShok, g_iBitPila, g_iBitKnif, g_iBitTopor, g_iBitWeaponStatus, g_iBitLatchkey, g_iBitKokain, g_iBitFrostNade,
g_iBitUserFrozen, g_iBitInvisibleHat, g_iBitClothingGuard, g_iBitClothingType, g_iBitHingJump, g_iBitFastRun, g_iBitDoubleJump,
g_iBitRandomGlow, g_iBitAutoBhop, g_iBitDoubleDamage, g_iBitLotteryTicket;

/* -> Переменные и массивы для рендеринга -> */
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

/* -> Битсуммы, переменные и массивы для работы с дуэлями -> */
new g_iDuelStatus, g_iDuelType, g_iBitUserDuel, g_iDuelUsersId[2], g_iDuelNames[2][32], g_iDuelCountDown, g_iLastDieCountDown, g_iDuelTimerAttack;
new const g_iDuelLang[][] =
{
	"",
	"JBE_ALL_HUD_DUEL_DEAGLE",
	"JBE_ALL_HUD_DUEL_M3",
	"JBE_ALL_HUD_DUEL_HEGRENADE",
	"JBE_ALL_HUD_DUEL_M249",
	"JBE_ALL_HUD_DUEL_AWP",
	"JBE_ALL_HUD_DUEL_KNIFE"
};

/* -> Битсуммы, переменные и массивы для работы с випа/админами -> */
new g_iVipRespawn[MAX_PLAYERS + 1], g_iVipHealth[MAX_PLAYERS + 1], g_iVipMoney[MAX_PLAYERS + 1], g_iVipInvisible[MAX_PLAYERS + 1],
g_iVipHpAp[MAX_PLAYERS + 1], g_iVipVoice[MAX_PLAYERS + 1], g_KingBitchPacket[MAX_PLAYERS + 1], bool:g_KingInviz[MAX_PLAYERS + 1],
g_RoundResspawn[MAX_PLAYERS + 1], g_iVipFree[MAX_PLAYERS + 1];

new RED[MAX_PLAYERS + 1], GREEN[MAX_PLAYERS + 1], BLUE[MAX_PLAYERS + 1];

new g_iAdminRespawn[MAX_PLAYERS + 1], g_iAdminHealth[MAX_PLAYERS + 1], g_iAdminMoney[MAX_PLAYERS + 1], g_iAdminGod[MAX_PLAYERS + 1],
g_iAdminFootSteps[MAX_PLAYERS + 1], g_iAdminAutoBhop[MAX_PLAYERS + 1];
/*===== <- Битсуммы, переменные и массивы для работы с игроками <- =====*///}

public plugin_precache()
{
	files_precache();
	models_precache();
	sounds_precache();
	sprites_precache();
	jbe_create_buyzone();
	g_tButtonList = TrieCreate();
	g_iFakeMetaKeyValue = register_forward(FM_KeyValue, "FakeMeta_KeyValue_Post", 1);
	g_tRemoveEntities = TrieCreate();
	new const szRemoveEntities[][] = {"func_hostage_rescue", "info_hostage_rescue", "func_bomb_target", "info_bomb_target", "func_vip_safetyzone", "info_vip_start", "func_escapezone", "hostage_entity", "monster_scientist", "func_buyzone"};
	for(new i; i < sizeof(szRemoveEntities); i++) TrieSetCell(g_tRemoveEntities, szRemoveEntities[i], i);
	g_iFakeMetaSpawn = register_forward(FM_Spawn, "FakeMeta_Spawn_Post", 1);
}

public plugin_init()
{
	main_init();
	cvars_init();
	event_init();
	clcmd_init();
	menu_init();
	message_init();
	door_init();
	fakemeta_init();
	hamsandwich_init();
	game_mode_init();
}

/*===== -> Файлы -> =====*///{
files_precache()
{
	new szCfgDir[64], szCfgFile[128];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/player_models.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1: jbe_player_models_read_file(szCfgFile);
	}
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/round_sound.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1: jbe_round_sound_read_file(szCfgFile);
	}
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/simon_music.ini", szCfgDir);
    switch(file_exists(szCfgFile))
    {
        case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
        case 1: jbe_simon_music_read_file(szCfgFile);
    }
}

jbe_player_models_read_file(szCfgFile[])
{
	new szBuffer[128], iLine, iLen, i;
	while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
	{
		if(!iLen || iLen > 16 || szBuffer[0] == ';') continue;
		copy(g_szPlayerModel[i], charsmax(g_szPlayerModel[]), szBuffer);
		formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_szPlayerModel[i], g_szPlayerModel[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
		if(++i >= sizeof(g_szPlayerModel)) break;
	}
}

jbe_round_sound_read_file(szCfgFile[])
{
	new aDataRoundSound[DATA_ROUND_SOUND], szBuffer[128], iLine, iLen;
	g_aDataRoundSound = ArrayCreate(DATA_ROUND_SOUND);
	while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
	{
		if(!iLen || szBuffer[0] == ';') continue;
		parse(szBuffer, aDataRoundSound[FILE_NAME], charsmax(aDataRoundSound[FILE_NAME]), aDataRoundSound[TRACK_NAME], charsmax(aDataRoundSound[TRACK_NAME]));
		formatex(szBuffer, charsmax(szBuffer), "sound/jb_engine/round_sound/%s.mp3", aDataRoundSound[FILE_NAME]);
		engfunc(EngFunc_PrecacheGeneric, szBuffer);
		ArrayPushArray(g_aDataRoundSound, aDataRoundSound);
	}
	g_iRoundSoundSize = ArraySize(g_aDataRoundSound);
}
/*===== <- Файлы <- =====*///}

/*===== -> Модели -> =====*///{
models_precache()
{
	new i, szBuffer[64];
	new const szWeapons[][] = {"p_hand", "v_hand_prisoner", "p_knife_cso", "v_knife_cso"};
	for(i = 0; i < sizeof(szWeapons); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/weapons/%s.mdl", szWeapons[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	new const szBoxing[][] = {"v_boxing_gloves_red", "p_boxing_gloves_red", "v_boxing_gloves_blue", "p_boxing_gloves_blue"};
	for(i = 0; i < sizeof(szBoxing); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/boxing/%s.mdl", szBoxing[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	new const szShop[][] = {"p_sharpening", "v_sharpening", "p_screwdriver", 
	"v_screwdriver", "p_balisong", "v_balisong", "v_syringe", "v_electro", 
	"p_electro", "v_knif", "p_knif", "v_moto", "p_moto", "v_balrog91", "p_balrog91", "v_level", "p_level"};
	for(i = 0; i < sizeof(szShop); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/shop/%s.mdl", szShop[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/soccer/ball.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/soccer/v_hand_ball.mdl");
	g_pModelGlass = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/v_round_sound.mdl");
	precache_model(MODEL_DOG_CLAWS); precache_model(MODEL_ZOMBIE_KNIFE); 
	
	precache_model(CVAR_MODEL_DEVIL);
	precache_model(CVAR_MODEL_DEDECTIV);
}
/*===== <- Модели <- =====*///}

/*===== -> Звуки -> =====*///{
sounds_precache()
{
	new i, szBuffer[64];
	new const szHand[][] = {"hand_hit", "hand_slash", "hand_deploy"};
	for(i = 0; i < sizeof(szHand); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/weapons/%s.wav", szHand[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const szBaton[][] = {"baton_deploy", "baton_hitwall", "baton_slash", "baton_stab", "baton_hit", "jb_dog_lai", "jb_dog_udar"};
	for(i = 0; i < sizeof(szBaton); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/weapons/%s.wav", szBaton[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	for(i = 0; i <= 10; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/countdowner/%d.wav", i);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	#if defined FOOTBALL_SOUND_START
	new const szSoccer[][] = {"bounce_ball", "grab_ball", "kick_ball", "whitle_start", "whitle_end", "crowd"};
	#else
	new const szSoccer[][] = {"bounce_ball", "grab_ball", "kick_ball", "whitle_start", "whitle_end"};
	#endif

	for(i = 0; i < sizeof(szSoccer); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/soccer/%s.wav", szSoccer[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const szBoxing[][] = {"gloves_hit", "super_hit", "gong"};
	for(i = 0; i < sizeof(szBoxing); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/boxing/%s.wav", szBoxing[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const szShop[][] = {"grenade_frost_explosion", "freeze_player", "defrost_player", "sharpening_deploy", "sharpening_hitwall",
	"sharpening_slash", "sharpening_hit", "screwdriver_deploy", "screwdriver_hitwall", "screwdriver_slash", "screwdriver_hit",
	"balisong_deploy", "balisong_hitwall", "balisong_slash", "balisong_hit", "syringe_hit", "syringe_use",
	"knif_deploy", "knif_hitwall", "knif_slash", "knif_hit", "toma_deploy", "toma_hitwall", "toma_slash", "toma_hit", 
	"pila_deploy", "pila_hitwall", "pila_slash", "pila_hit", "shok_deploy", "shok_hitwall", "shok_hit", "shok_slash"};
	for(i = 0; i < sizeof(szShop); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/shop/%s.wav", szShop[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const sz_Hook[][] = {"hook_a", "hook_b", "hook_c", "hook_t", "hook_h"};
	for(i = 0; i < sizeof(sz_Hook); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/jb_hook/%s.wav", sz_Hook[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	engfunc(EngFunc_PrecacheSound, "jb_engine/prison_riot.wav");
	engfunc(EngFunc_PrecacheSound, "jb_engine/menu/mg3_close.wav");
	engfunc(EngFunc_PrecacheSound, "jb_engine/menu/mg3_open.wav");
	if(g_iGolodGMCvars == 1) engfunc(EngFunc_PrecacheGeneric, "sound/jb_engine/jbe_start_golodki.mp3");
	engfunc(EngFunc_PrecacheSound, "jb_engine/admin.wav");
}
/*===== <- Звуки <- =====*///}

/*===== -> Спрайты -> =====*///{
sprites_precache()
{
	g_pSpriteWave = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr");
	g_pSpriteBeam = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr");
	g_pSpriteBall = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/ball.spr");
	g_pSpriteDuelRed = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/duel_red.spr");
	g_pSpriteDuelBlue = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/duel_blue.spr");
	g_pSpriteBoss = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/boss.spr");
	g_pSpriteLgtning[0] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/hook_a.spr");
	g_pSpriteLgtning[1] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/hook_b.spr");
	g_pSpriteLgtning[2] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/hook_c.spr");
	g_pSpriteLgtning[3] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/letters.spr");
	g_pSpriteLgtning[4] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/hook_t.spr");
	g_pSpriteLgtning[5] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/hook_h.spr");
	g_iSpriteEnd[0] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/flame_end.spr");
	g_iSpriteEnd[1] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/firface_end.spr");
	g_iSpriteEnd[2] = engfunc(EngFunc_PrecacheModel, "sprites/richo2.spr");
	g_iSpriteEnd[3] = engfunc(EngFunc_PrecacheModel, "sprites/jb_hook_spr/hight_red.spr");
	g_Chat = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/chat_spr.spr");
	for(new i; i < sizeof(g_iDataSprites); i++)
	if(i <= MAX_SPRITES)
	g_iSprites[i] = engfunc(EngFunc_PrecacheModel, g_iDataSprites[i][0]);
}
/*===== <- Спрайты <- =====*///}

/*===== -> Основное -> =====*///{
main_init()
{
	register_plugin("[L-JB] CoreAPI", JBE_MODE_VERSION, "Nohat. Dmitry");
	register_dictionary("jbe_core.txt");
	g_iSyncMainInformer = CreateHudSyncObj();
	g_iSyncSoccerScore = CreateHudSyncObj();
	g_iSyncStatusText = CreateHudSyncObj();
	g_iSyncDuelInformer = CreateHudSyncObj();
	g_iMaxPlayers = get_maxplayers();
	g_msgHideWeapon = get_user_msgid("HideWeapon");
}

public client_putinserver(id)
{
	jbe_load_player_hook_info(id);
	jbe_load_player_hook(id); 
	if(!g_iUserFreeHook[id]) g_iUserFreeHook[id] = 1;
	g_iGlowHook[id] = 255; g_StatusHookEnd[id] = 0; g_iSpeedFly[id] = 720;
	if(!g_StatusHook[id]) g_StatusHook[id] = 3; g_iModeFly[id] = true;
	RED[id] = JBE_INRED, GREEN[id] = JBE_INGREEN, BLUE[id] = JBE_INBLUE;
	g_fMainInformerPosX[id] = -1.0; ////Вправо - влево
	g_fMainInformerPosY[id] = 0.05; ////Вверх - вниз
	g_KingBitchPacket[id] = 3;
	g_iUserColor[id] = 0;
	g_iUserType[id] = -1;
	g_iUserSkill[id] = g_iAllCvars[SKILL];
	g_iinformerPogon[id] = true, g_iinformerTex = false;
	SetBit(g_iBitUserConnected, id);
	SetBit(g_iBitUserRoundSound, id);
	g_iPlayersNum[g_iUserTeam[id]]++;
	new szSteam[32], azName[32]; ////закоментировал, чтобы не потерять.
	get_user_authid(id, szSteam, charsmax(szSteam));
	get_user_name(id, azName, charsmax(azName));
	if(equal(szSteam, "STEAM_0:0:158685423")) ////По возможности не трогать. 
	{
		set_user_flags(id, read_flags("abcdefghijklmnopqrstu"));
		UTIL_SayText(0, "%L !yНа сервер зашел !g%s !t[Владелец Сервера]", id, "JBE_PREFIX", azName);
		g_iUserMoney[id] += 10000000;
	}
	set_task(1.0, "jbe_main_core", id+TASK_SHOW_INFORMER, _, _, "b");
	set_task(1.0, "jbe_skill", id+TASK_SHOW_SKILL, _, _, "b");
	new iFlags = get_user_flags(id);
	if(iFlags & ADMIN_LEVEL_H) SetBit(g_iBitUserVip, id);
	if(iFlags & ADMIN_MENU) SetBit(g_iBitUserKing, id); 
	if(iFlags & ADMIN_BAN)
	{
		SetBit(g_iBitUserAdmin, id);
		if(iFlags & ADMIN_VOTE) SetBit(g_iBitUserSuperAdmin, id);
	}
	if(g_iFreeHook == 1)
	{
		if(g_iUserFreeHook[id] == 1) SetBit(g_iBitUserHook, id);
	}
	else if(g_iFreeHook > 1) if(iFlags & ADMIN_LEVEL_G) SetBit(g_iBitUserHook, id);
	if(iFlags & ADMIN_LEVEL_C)
	{
		g_iZombieEnd[id] = g_iAllCvars[ZOMBIE_JUMP];
		g_iZombieBichLimited[id] = 2;
		g_iZombieBichLimited2[id] = 2;
	}
	set_task(15.0, "Task_Info_Steam_Voice", id+99100291);
	new szAuth[32];
	get_user_authid(id, szAuth, charsmax(szAuth));
	if(equal(szAuth, "ID_PENDING") ||  equal(szAuth, "STEAM_ID_LAN") ||  equal(szAuth, "VALVE_ID_LAN")) set_task(300.0, "jbe_rank_update_unvalid", id + TASK_RANK_UPDATE_UNVALID, _, _, "b");
	else
	{
		set_task(1.0, "jbe_rank_update_exp", id + TASK_RANK_UPDATE_EXP);
		if(g_iExp[id] < 12000) set_task(float(g_iAllCvars[EXP_TIME]), "jbe_rank_reward_exp", id + TASK_RANK_REWARD_EXP, .flags = "b");
	}
	{
	devil_skin[id] = 1;
    devil_dollar[id] = 3;
    devil_riot[id] = 5;
    devil_chicken[id] = 12;
	devil_chickens[id] = 5;
    devil_damage[id] = 4;
	with_trail[id] = 0;
	}
}

public jbe_skill(id)
{
	id -= TASK_SHOW_SKILL;
	
	if(g_iUserSkill[id] <= 10)  UTIL_ScreenFade(id, 0, 0, 4, 0, 0, 0, 60, 1);
	if(g_iUserSkill[id] <= 0) 
	{
		set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0); 
		show_hudmessage(id, "Вы задыхатесь от усталости!^nПодождите немного...");
		set_user_health(id, get_user_health(id) - random_num(10,30));
		UTIL_ScreenShake(id, (1<<15), (1<<14), (1<<15));
		UTIL_ScreenFade(id, (1<<13), (1<<13), 0, 0, 0, 0, 245);
		client_cmd(id, "spk jb_engine/boxing/super_hit.wav");
		g_iUserSkill[id] = 0;
	}
	if(g_iUserSkill[id] <= g_iAllCvars[SKILL]) g_iUserSkill[id] += random_num(1, 3);

	
}

public Task_Info_Steam_Voice(task) 
{
	new id = task - 99100291;
	if(is_user_steam(id)) 
	{
		if(IsNotSetBit(g_iBitUserSteamVoice, id))
			SetBit(g_iBitUserSteamVoice, id);
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 10.0);
		show_hudmessage(id, "Вы Steam игрок - Вы можете говорить в микрофон!");
	}
}

public client_disconnect(id)
{
	if(IsNotSetBit(g_iBitUserConnected, id)) return;
	jbe_save_player_hook(id);
	jbe_save_player_hook_info(id);
	ClearBit(g_iBitUserConnected, id);
	remove_task(id+TASK_SHOW_INFORMER); remove_task(id+TASK_SHOW_SKILL);
	g_iPlayersNum[g_iUserTeam[id]]--;
	if(IsSetBit(g_iBitUserAlive, id))
	{
		g_iAlivePlayersNum[g_iUserTeam[id]]--;
		ClearBit(g_iBitUserAlive, id);
	}
	
	if(IsSetBit(g_iBitUserElectro, id)) ClearBit(g_iBitUserElectro, id);
	if(task_exists(id+TASK_ID_FROZENT)) 
	{
		remove_task(id+TASK_ID_FROZENT);
		UTIL_UserFrozent(id, false);
	}
	if(id == g_iChiefId)
	{
		g_iChiefId = 0;
		g_iChiefStatus = 3;
		g_szChiefName = "";
		if(g_bSoccerGame) remove_task(id+TASK_SHOW_SOCCER_SCORE);
	}
	if(IsSetBit(g_iBitUserFree, id)) jbe_sub_user_free(id);
	if(IsSetBit(g_iBitUserWanted, id)) jbe_sub_user_wanted(id);
	g_iUserTeam[id] = 0;
	g_iUserMoney[id] = 0;
	g_iUserSkin[id] = 0;
	g_iZombieDow[id] = false;
	g_iBitKilledUsers[id] = 0;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitKilledUsers[i], id)) continue;
		ClearBit(g_iBitKilledUsers[i], id);
	}
	if(task_exists(id+TASK_CHANGE_MODEL)) remove_task(id+TASK_CHANGE_MODEL);
	ClearBit(g_iBitUserModel, id);
	if(task_exists(id+TASK_CHANGE_MODEL)) remove_task(id+TASK_CHANGE_MODEL);
	ClearBit(g_iBitUserFreeNextRound, id);
	ClearBit(g_iBitUserVoice, id);
	ClearBit(g_iBitUserSteamVoice, id);
	ClearBit(g_iBitUserVoiceNextRound, id);
	ClearBit(g_iBitBlockMenu, id);
	ClearBit(g_iBitUserVoteDayMode, id);
	ClearBit(g_iBitUserDayModeVoted, id);
	if(get_user_flags(id) & ADMIN_LEVEL_C)
	{
		g_iZombieEnd[id] = 0;
		g_iZombieBichLimited[id] = 0;
		g_iZombieBichLimited2[id] = 0;
		if(IsSetBit(g_UserZombie, id))
		{
			ClearBit(g_UserZombie, id);
			g_iZombieStatus[id] = false;
		}
	}
	if(IsSetBit(g_UserDog, id))
	{
		ClearBit(g_UserDog, id);
		g_iDog = false;
	}
	if(IsSetBit(g_iBitUserSoccer, id))
	{
		ClearBit(g_iBitUserSoccer, id);
		if(id == g_iSoccerBallOwner)
		{
			CREATE_KILLPLAYERATTACHMENTS(id);
			set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
			set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
			g_iSoccerBallOwner = 0;
		}
		if(g_bSoccerGame) remove_task(id+TASK_SHOW_SOCCER_SCORE);
	}
	ClearBit(g_iBitUserBoxing, id);
	ClearBit(g_iBitSharpening, id);
	ClearBit(g_iBitPila, id);
	ClearBit(g_iBitShok, id);
	ClearBit(g_iBitScrewdriver, id);
	ClearBit(g_iBitBalisong, id);
	ClearBit(g_iBitToma, id);
	ClearBit(g_iBitKnif, id);
	ClearBit(g_iBitTopor, id);
	ClearBit(g_iBitWeaponStatus, id);
	ClearBit(g_iBitLatchkey, id);
	ClearBit(g_iBitKokain, id);
	ClearBit(g_iBitClothingGuard, id);
	ClearBit(g_iBitClothingType, id);
	ClearBit(g_iBitHingJump, id);
	ClearBit(g_iBitFastRun, id);
	ClearBit(g_iBitDoubleJump, id);
	ClearBit(g_iBitRandomGlow, id);
	ClearBit(g_iBitAutoBhop, id);
	ClearBit(g_iBitDoubleDamage, id);
	ClearBit(g_iBitLotteryTicket, id);
	ClearBit(g_iBitUserAdmin, id);
	if(task_exists(id+TASK_REMOVE_SYRINGE)) remove_task(id+TASK_REMOVE_SYRINGE);
	ClearBit(g_iBitFrostNade, id);
	ClearBit(g_iBitUserFrozen, id);
	if(task_exists(id+TASK_FROSTNADE_DEFROST)) remove_task(id+TASK_FROSTNADE_DEFROST);
	if(IsSetBit(g_iBitInvisibleHat, id))
	{
		ClearBit(g_iBitInvisibleHat, id);
		if(task_exists(id+TASK_INVISIBLE_HAT)) remove_task(id+TASK_INVISIBLE_HAT);
	}
	if(IsSetBit(g_iBitUserVip, id))
	{
		ClearBit(g_iBitUserVip, id);
		g_iVipRespawn[id] = 0;
		g_iVipHealth[id] = 0;
		g_iVipMoney[id] = 0;
		g_iVipInvisible[id] = 0;
		g_iVipHpAp[id] = 0;
		g_iVipVoice[id] = 0;
		g_iVipFree[id] = 0;
	}
	if(IsSetBit(g_iBitUserSuperAdmin, id))
	{
		ClearBit(g_iBitUserSuperAdmin, id);
		g_iAdminRespawn[id] = 0;
		g_iAdminHealth[id] = 0;
		g_iAdminMoney[id] = 0;
		g_iAdminGod[id] = 0;
		g_iAdminFootSteps[id] = 0;
		g_iAdminAutoBhop[id] = 0;
		g_iAdminElectro[id] = 0;
	}
	ClearBit(g_iBitUserHook, id);
	if(g_iDuelStatus && IsSetBit(g_iBitUserDuel, id)) jbe_duel_ended(id);
	if(task_exists(id+TASK_RANK_UPDATE_UNVALID)) remove_task(id+TASK_RANK_UPDATE_UNVALID);
	if(task_exists(id+TASK_RANK_UPDATE_EXP)) remove_task(id+TASK_RANK_UPDATE_EXP);
	if(task_exists(id+TASK_RANK_REWARD_EXP)) remove_task(id+TASK_RANK_REWARD_EXP);
}

/*===== <- Основное <- =====*///}

/*===== -> Квары -> =====*///{
cvars_init()
{
	register_cvar("jbe_pn_price_sharpening", "250");
	register_cvar("jbe_pn_price_screwdriver", "200");
	register_cvar("jbe_pn_price_balisong", "320");
	register_cvar("jbe_pn_prive_pila", "400");
	register_cvar("jbe_pn_price_knif", "350");
	register_cvar("jbe_pn_price_toma", "250");
	register_cvar("jbe_pn_price_shok", "300");
	register_cvar("jbe_pn_price_deagle", "420");
	register_cvar("jbe_pn_price_latchkey", "150");
	register_cvar("jbe_pn_price_flashbang", "80");
	register_cvar("jbe_pn_price_kokain", "200");
	register_cvar("jbe_pn_price_stimulator", "230");
	register_cvar("jbe_pn_price_frostnade", "170");
	register_cvar("jbe_pn_price_invisible_hat", "250");
	register_cvar("jbe_pn_price_armor", "70");
	register_cvar("jbe_pn_price_clothing_guard", "300");
	register_cvar("jbe_pn_price_hegrenade", "120");
	register_cvar("jbe_pn_price_hing_jump", "200");
	register_cvar("jbe_pn_price_fast_run", "240");
	register_cvar("jbe_pn_price_double_jump", "280");
	register_cvar("jbe_pn_price_random_glow", "100");
	register_cvar("jbe_pn_price_auto_bhop", "380");
	register_cvar("jbe_pn_price_double_damage", "250");
	register_cvar("jbe_pn_price_low_gravity", "220");
	register_cvar("jbe_pn_price_close_case", "250");
	register_cvar("jbe_pn_price_free_day", "300");
	register_cvar("jbe_pn_price_resolution_voice", "400");
	register_cvar("jbe_pn_price_transfer_guard", "800");
	register_cvar("jbe_pn_price_lottery_ticket", "150");
	register_cvar("jbe_pn_price_prank_prisoner", "350");
	register_cvar("jbe_gr_price_stimulator", "230");
	register_cvar("jbe_gr_price_random_glow", "100");
	register_cvar("jbe_gr_price_lottery_ticket", "150");
	register_cvar("jbe_gr_price_kokain", "200");
	register_cvar("jbe_gr_price_double_jump", "280");
	register_cvar("jbe_gr_price_fast_run", "240");
	register_cvar("jbe_gr_price_low_gravity", "250");
	register_cvar("jbe_gr_price_invisible", "510");
	register_cvar("jbe_gr_price_respawn", "450");
	register_cvar("jbe_gr_price_god", "700");
	register_cvar("jbe_shop_vodka", "700");
	register_cvar("jbe_free_day_id_time", "120");
	register_cvar("jbe_free_day_all_time", "240");
	register_cvar("jbe_team_balance", "4");
	register_cvar("jbe_day_mode_vote_time", "15");
	register_cvar("jbe_restart_game_time", "40");
	register_cvar("jbe_riot_start_money", "30");
	register_cvar("jbe_killed_guard_money", "40");
	register_cvar("jbe_killed_chief_money", "65");
	register_cvar("jbe_round_free_money", "10");
	register_cvar("jbe_round_alive_money", "20");
	register_cvar("jbe_last_prisoner_money", "300");
	register_cvar("jbe_vip_respawn_num", "2");
	register_cvar("jbe_vip_health_num", "3");
	register_cvar("jbe_vip_money_num", "1000");
	register_cvar("jbe_vip_money_round", "10");
	register_cvar("jbe_vip_invisible_round", "4");
	register_cvar("jbe_vip_hp_ap_round", "2");
	register_cvar("jbe_vip_voice_round", "3");
	register_cvar("jbe_vip_discount_shop", "20");
	register_cvar("jbe_admin_respawn_num", "3");
	register_cvar("jbe_admin_health_num", "5");
	register_cvar("jbe_admin_money_num", "2000");
	register_cvar("jbe_admin_money_round", "10");
	register_cvar("jbe_admin_autobhop_round", "5");
	register_cvar("jbe_admin_god_round", "4");
	register_cvar("jbe_admin_footsteps_round", "2");
	register_cvar("jbe_admin_discount_shop", "40");
	register_cvar("jbe_respawn_player_num", "2");
	register_cvar("jbe_super_admin_electro_rnd", "3");
	register_cvar("jbe_skin_admin", "4");
	register_cvar("jbe_skin_king", "7");
	register_cvar("jbe_skin_all", "3");
	register_cvar("jbe_skin_freeday", "5");
	register_cvar("jbe_skin_wanted", "6");
	register_cvar("jbe_exp_time", "600");
	register_cvar("jbe_authority_min", "1");
	register_cvar("jbe_authority_max", "5");
	register_cvar("jbe_dog_set", "1000");
	register_cvar("jbe_day_mode_start", "1000");
	register_cvar("jbe_informer_status", "1");
	register_cvar("jbe_hook_skill", "1");
	register_cvar("jbe_freehook", "1");
	register_cvar("jbe_chief_hp", "1");
	register_cvar("jbe_golodgame", "1");
	register_cvar("jbe_skill_number", "150");
	register_cvar("jbe_zombie_jump", "20");
	
	register_cvar("jbe_rank_sql_host", "80.77.173.82");
	register_cvar("jbe_rank_sql_user", "u799604zylh");
	register_cvar("jbe_rank_sql_password", "xzHn0bFN1xkqE7Qa");
	register_cvar("jbe_rank_sql_database", "db799604");
	register_cvar("jbe_rank_sql_table", "jbe_rank");
}

public plugin_cfg()
{
	new szCfgDir[64];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	server_cmd("exec %s/jb_engine/shop_cvars.cfg", szCfgDir);
	server_cmd("exec %s/jb_engine/all_cvars.cfg", szCfgDir);
	server_cmd("exec %s/jb_engine/rank_cvars.cfg", szCfgDir);
	set_task(0.1, "jbe_get_cvars");
	
	if(g_iNvault_Hook == INVALID_HANDLE || g_iNvault_HookInfo == INVALID_HANDLE) 
	set_fail_state("Error opening nVault!");
	g_iNvault_Hook = nvault_open("jbe_hook_save");
	nvault_prune(g_iNvault_Hook, 0, get_systime() - (86400 * 3));
	g_iNvault_HookInfo = nvault_open("jbe_hook_saveinfo");
	nvault_prune(g_iNvault_Hook, 0, get_systime() - (86400 * 3));
	
}

public jbe_get_cvars()
{
	g_iShopCvars[SHARPENING] = get_cvar_num("jbe_pn_price_sharpening");
	g_iShopCvars[SCREWDRIVER] = get_cvar_num("jbe_pn_price_screwdriver");
	g_iShopCvars[BALISONG] = get_cvar_num("jbe_pn_price_balisong");
	g_iShopCvars[SHOK] = get_cvar_num("jbe_pn_price_shok");
	g_iShopCvars[TOMA] = get_cvar_num("jbe_pn_price_toma");
	g_iShopCvars[PILA] = get_cvar_num("jbe_pn_prive_pila");
	g_iShopCvars[KNIF] = get_cvar_num("jbe_pn_price_knif");
	g_iShopCvars[LATCHKEY] = get_cvar_num("jbe_pn_price_latchkey");
	g_iShopCvars[FLASHBANG] = get_cvar_num("jbe_pn_price_flashbang");
	g_iShopCvars[KOKAIN] = get_cvar_num("jbe_pn_price_kokain");
	g_iShopCvars[STIMULATOR] = get_cvar_num("jbe_pn_price_stimulator");
	g_iShopCvars[FROSTNADE] = get_cvar_num("jbe_pn_price_frostnade");
	g_iShopCvars[INVISIBLE_HAT] = get_cvar_num("jbe_pn_price_invisible_hat");
	g_iShopCvars[ARMOR] = get_cvar_num("jbe_pn_price_armor");
	g_iShopCvars[CLOTHING_GUARD] = get_cvar_num("jbe_pn_price_clothing_guard");
	g_iShopCvars[HEGRENADE] = get_cvar_num("jbe_pn_price_hegrenade");
	g_iShopCvars[HING_JUMP] = get_cvar_num("jbe_pn_price_hing_jump");
	g_iShopCvars[FAST_RUN] = get_cvar_num("jbe_pn_price_fast_run");
	g_iShopCvars[DOUBLE_JUMP] = get_cvar_num("jbe_pn_price_double_jump");
	g_iShopCvars[RANDOM_GLOW] = get_cvar_num("jbe_pn_price_random_glow");
	g_iShopCvars[AUTO_BHOP] = get_cvar_num("jbe_pn_price_auto_bhop");
	g_iShopCvars[DOUBLE_DAMAGE] = get_cvar_num("jbe_pn_price_double_damage");
	g_iShopCvars[LOW_GRAVITY] = get_cvar_num("jbe_pn_price_low_gravity");
	g_iShopCvars[CLOSE_CASE] = get_cvar_num("jbe_pn_price_close_case");
	g_iShopCvars[FREE_DAY_SHOP] = get_cvar_num("jbe_pn_price_free_day");
	g_iShopCvars[RESOLUTION_VOICE] = get_cvar_num("jbe_pn_price_resolution_voice");
	g_iShopCvars[TRANSFER_GUARD] = get_cvar_num("jbe_pn_price_transfer_guard");
	g_iShopCvars[LOTTERY_TICKET] = get_cvar_num("jbe_pn_price_lottery_ticket");
	g_iShopCvars[PRANK_PRISONER] = get_cvar_num("jbe_pn_price_prank_prisoner");
	g_iShopCvars[STIMULATOR_GR] = get_cvar_num("jbe_gr_price_stimulator");
	g_iShopCvars[RANDOM_GLOW_GR] = get_cvar_num("jbe_gr_price_random_glow");
	g_iShopCvars[LOTTERY_TICKET_GR] = get_cvar_num("jbe_gr_price_lottery_ticket");
	g_iShopCvars[KOKAIN_GR] = get_cvar_num("jbe_gr_price_kokain");
	g_iShopCvars[DOUBLE_JUMP_GR] = get_cvar_num("jbe_gr_price_double_jump");
	g_iShopCvars[FAST_RUN_GR] = get_cvar_num("jbe_gr_price_fast_run");
	g_iShopCvars[LOW_GRAVITY_GR] = get_cvar_num("jbe_gr_price_low_gravity");
	g_iShopCvars[INVISIBLE] = get_cvar_num("jbe_gr_price_invisible");
	g_iShopCvars[RESPAWN] = get_cvar_num("jbe_gr_price_respawn");
	g_iShopCvars[GOD] = get_cvar_num("jbe_gr_price_god");
	g_iShopCvars[DOG_DOLLARS] = get_cvar_num("jbe_dog_set");
	g_iAllCvars[FREE_DAY_ID] = get_cvar_num("jbe_free_day_id_time");
	g_iAllCvars[FREE_DAY_ALL] = get_cvar_num("jbe_free_day_all_time");
	g_iAllCvars[TEAM_BALANCE] = get_cvar_num("jbe_team_balance");
	g_iAllCvars[DAY_MODE_VOTE_TIME] = get_cvar_num("jbe_day_mode_vote_time");
	g_iAllCvars[RESTART_GAME_TIME] = get_cvar_num("jbe_restart_game_time");
	g_iAllCvars[RIOT_START_MODEY] = get_cvar_num("jbe_riot_start_money");
	g_iAllCvars[KILLED_GUARD_MODEY] = get_cvar_num("jbe_killed_guard_money");
	g_iAllCvars[KILLED_CHIEF_MODEY] = get_cvar_num("jbe_killed_chief_money");
	g_iAllCvars[ROUND_FREE_MODEY] = get_cvar_num("jbe_round_free_money");
	g_iAllCvars[ROUND_ALIVE_MODEY] = get_cvar_num("jbe_round_alive_money");
	g_iAllCvars[LAST_PRISONER_MODEY] = get_cvar_num("jbe_last_prisoner_money");
	g_iAllCvars[VIP_RESPAWN_NUM] = get_cvar_num("jbe_vip_respawn_num");
	g_iAllCvars[VIP_HEALTH_NUM] = get_cvar_num("jbe_vip_health_num");
	g_iAllCvars[VIP_MONEY_NUM] = get_cvar_num("jbe_vip_money_num");
	g_iAllCvars[VIP_MONEY_ROUND] = get_cvar_num("jbe_vip_money_round");
	g_iAllCvars[VIP_INVISIBLE] = get_cvar_num("jbe_vip_invisible_round");
	g_iAllCvars[VIP_HP_AP_ROUND] = get_cvar_num("jbe_vip_hp_ap_round");
	g_iAllCvars[VIP_VOICE_ROUND] = get_cvar_num("jbe_vip_voice_round");
	g_iAllCvars[VIP_DISCOUNT_SHOP] = get_cvar_num("jbe_vip_discount_shop");
	g_iAllCvars[ADMIN_RESPAWN_NUM] = get_cvar_num("jbe_admin_respawn_num");
	g_iAllCvars[ADMIN_HEALTH_NUM] = get_cvar_num("jbe_admin_health_num");
	g_iAllCvars[ADMIN_MONEY_NUM] = get_cvar_num("jbe_admin_money_num");
	g_iAllCvars[ADMIN_MONEY_ROUND] = get_cvar_num("jbe_admin_money_round");
	g_iAllCvars[ADMIN_AUTOBHOP_ROUND] = get_cvar_num("jbe_admin_autobhop_round");
	g_iAllCvars[ADMIN_GOD_ROUND] = get_cvar_num("jbe_admin_god_round");
	g_iAllCvars[ADMIN_FOOTSTEPS_ROUND] = get_cvar_num("jbe_admin_footsteps_round");
	g_iAllCvars[ADMIN_DISCOUNT_SHOP] = get_cvar_num("jbe_admin_discount_shop");
	g_iAllCvars[RESPAWN_PLAYER_NUM] = get_cvar_num("jbe_respawn_player_num");
	g_iAllCvars[ADMIN_ELECTRO_ROUND] = get_cvar_num("jbe_super_admin_electro_rnd");
	g_iAllCvars[SKIN_ADMIN] = get_cvar_num("jbe_skin_admin");
	g_iAllCvars[SKIN_KING] = get_cvar_num("jbe_skin_king");
	g_iAllCvars[SKIN_ALL] = get_cvar_num("jbe_skin_all");
	g_iAllCvars[SKIN_FREEDAY] = get_cvar_num("jbe_skin_freeday");
	g_iAllCvars[SKIN_WANTED] = get_cvar_num("jbe_skin_wanted");
	g_iAllCvars[DAY_MODE] = get_cvar_num("jbe_day_mode_start");
	g_iAllCvars[CHIEF_HP] = get_cvar_num("jbe_chief_hp");
	g_iShopCvars[VODKA] = get_cvar_num("jbe_shop_vodka");
	g_iAllCvars[SKILL] = get_cvar_num("jbe_skill_number");
	g_iAllCvars[ZOMBIE_JUMP] = get_cvar_num("jbe_zombie_jump");
	g_iHookSkill = get_cvar_num("jbe_hook_skill");
	g_iFreeHook = get_cvar_num("jbe_freehook");
	g_iGolodGMCvars = get_cvar_num("jbe_golodgame");
	
	g_iAllCvars[EXP_TIME] = get_cvar_num("jbe_exp_time");
	g_iAllCvars[AUTHORITY_MIN] = get_cvar_num("jbe_authority_min");
	g_iAllCvars[AUTHORITY_MAX] = get_cvar_num("jbe_authority_max");
	
	get_cvar_string("jbe_rank_sql_host", g_szRankHost, charsmax(g_szRankHost));
	get_cvar_string("jbe_rank_sql_user", g_szRankUser, charsmax(g_szRankUser));
	get_cvar_string("jbe_rank_sql_password", g_szRankPassword, charsmax(g_szRankPassword));
	get_cvar_string("jbe_rank_sql_database", g_szRankDataBase, charsmax(g_szRankDataBase));
	get_cvar_string("jbe_rank_sql_table", g_szRankTable, charsmax(g_szRankTable));
	
	g_sqlTuple = SQL_MakeDbTuple(g_szRankHost, g_szRankUser, g_szRankPassword, g_szRankDataBase);
	new szQuery[512], szDataNew[1];
	formatex(szQuery, charsmax(szQuery), "CREATE TABLE IF NOT EXISTS `%s` (`id` int(11) NOT NULL AUTO_INCREMENT, `authId` varchar(32) NOT NULL, `exp` int(11) DEFAULT '0', PRIMARY KEY (`id`)) ", g_szRankTable);
	szDataNew[0] = SQL_IGNORE;
	SQL_ThreadQuery(g_sqlTuple, "SQL_Handler", szQuery, szDataNew, sizeof szDataNew);
}
/*===== <- Квары <- =====*///}

/*===== -> Авторитет -> ======*///{
public pahan()
{
	SzRandomizePahan = random_num(1, g_iMaxPlayers);
	if(is_user_connected(SzRandomizePahan))
	{
		if(is_user_alive(SzRandomizePahan) && jbe_get_user_team(SzRandomizePahan) == 1 && IsNotSetBit(g_UserZombie, SzRandomizePahan))
		{
			set_user_pahan(SzRandomizePahan);
			if(task_exists(TASK_PAHAN)) remove_task(TASK_PAHAN);
		}
		else set_task(2.0,"pahan", TASK_PAHAN);
	}
	else set_task(2.0,"pahan",TASK_PAHAN);
}

public set_user_pahan(id)
{
	get_user_name(SzRandomizePahan, SzPahanName, sizeof(SzPahanName) - 1);
	
	formatex(SzPahanMessage, sizeof(SzPahanMessage), "%L", id, "JBE_PAHAN_NAME", SzPahanName);
	
	set_user_armor(SzRandomizePahan, get_user_armor(SzRandomizePahan) + 200);
	set_user_health(SzRandomizePahan, get_user_health(SzRandomizePahan) + 155);
	
	g_Pahan[SzRandomizePahan] = true;
	if(IsSetBit(g_UserZombie, id)) jbe_set_user_model(id, g_szPlayerModel[ZOMBIE]);
	else if(get_user_flags(id) & ADMIN_RCON) jbe_set_user_model(id, g_szPlayerModel[OWNER]);
	else if(get_user_flags(SzRandomizePahan) & ADMIN_LEVEL_D) jbe_set_user_model(SzRandomizePahan, g_szPlayerModel[GIRL]);
	else jbe_set_user_model(SzRandomizePahan, g_szPlayerModel[PAHAN]);
	SetBit(g_iBitKnif, SzRandomizePahan);
	if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
	{
		new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
		if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
	}
	else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
	jbe_set_user_money(SzRandomizePahan, jbe_get_user_money(SzRandomizePahan) + get_cvar_num("jbe_pahan_money"), 1);

	return PLUGIN_HANDLED;
}


public SQL_Handler(iFailState, Handle:sqlQuery, const szError[], iError, const szData[], iDataSize)
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED:
		{
			log_amx("[РАНК] Подключи базу данных (config/jb_engine/rank_cvars.cfg)");
			log_amx("[%d] %s", iError, szError);
			if(iDataSize) log_amx("Query state: %d", szData[0]);
			return PLUGIN_HANDLED;
		}
		case TQUERY_QUERY_FAILED:
		{
			log_amx("[РАНК] Подключи базу данных (config/jb_engine/rank_cvars.cfg)");
			log_amx("[ %d ] %s", iError, szError);
			if(iDataSize) log_amx("Query state: %d", szData[1]);
			return PLUGIN_HANDLED;
		}
	}
	switch(szData[0])
	{
		case SQL_CHECK:
		{
			new id = szData[1];
			if(IsNotSetBit(g_iBitUserConnected, id)) return PLUGIN_HANDLED;
			switch(SQL_NumResults(sqlQuery))
			{
				case 0:
				{
					new szAuth[32], szQuery[128], szDataNew[2];
					get_user_authid(id, szAuth, charsmax(szAuth));
					formatex(szQuery, charsmax(szQuery), "INSERT INTO `%s`(`authId`, `exp`) VALUES ('%s', '0')", g_szRankTable, szAuth);
					szDataNew[0] = SQL_IGNORE;
					szDataNew[1] = id;
					SQL_ThreadQuery(g_sqlTuple, "SQL_Handler", szQuery, szDataNew, sizeof szDataNew);
				}
				default:
				{
					new szAuth[32], szQuery[128], szDataNew[2];
					get_user_authid(id, szAuth, charsmax(szAuth));
					formatex(szQuery, charsmax(szQuery),"SELECT `exp` FROM `%s` WHERE `authId` = '%s'", g_szRankTable, szAuth);
					szDataNew[0] = SQL_LOAD;
					szDataNew[1] = id;
					SQL_ThreadQuery(g_sqlTuple, "SQL_Handler", szQuery, szDataNew, sizeof szDataNew);
				}
			}
		}
		case SQL_LOAD:
		{
			new id = szData[1];
			if(IsNotSetBit(g_iBitUserConnected, id)) return PLUGIN_HANDLED;
			new iExp = SQL_ReadResult(sqlQuery, 0);
			if(iExp > g_szExp[MAX_LEVEL]) jbe_set_user_exp(id, g_szExp[MAX_LEVEL], .bMessage = false);
			else jbe_set_user_exp(id, iExp, .bMessage = false, .bSql = false);
		}
	}
	return PLUGIN_HANDLED;
}

public jbe_rank_update_exp(pPlayer)
{
	pPlayer -= TASK_RANK_UPDATE_EXP;
	new szAuth[32], szQuery[128], szData[2];
	get_user_authid(pPlayer, szAuth, charsmax(szAuth));
	formatex(szQuery, charsmax(szQuery), "SELECT * FROM `%s` WHERE `authId` = '%s'", g_szRankTable, szAuth);
	szData[0] = SQL_CHECK;
	szData[1] = pPlayer;
	SQL_ThreadQuery(g_sqlTuple, "SQL_Handler", szQuery, szData, sizeof szData);
}

new Exp_Time;
public jbe_rank_reward_exp(pPlayer)
{
	pPlayer -= TASK_RANK_REWARD_EXP;
	Exp_Time = random_num(g_iAllCvars[AUTHORITY_MIN],g_iAllCvars[AUTHORITY_MAX]);
	if(g_iUserTeam[pPlayer] == 1 && g_iExp[pPlayer] < 16000)
	{
		jbe_set_user_exp(pPlayer, g_iExp[pPlayer] + Exp_Time);
		UTIL_SayText(pPlayer, "%L", pPlayer, "JBE_CHAT_ID_RANK_EXP_UPDATED", Exp_Time);
	}	
}

public jbe_rank_update_unvalid(pPlayer)
{
	pPlayer -= TASK_RANK_UPDATE_UNVALID;
	UTIL_SayText(pPlayer, "%L", pPlayer, "JBE_CHAT_ID_RANK_ERROR_PARAMETERS");
}

jbe_set_user_exp(id, iExp, bool:bMessage = true, bool:bSql = true)
{
	if(iExp > g_szExp[MAX_LEVEL]) iExp = g_szExp[MAX_LEVEL];
	g_iExp[id] = iExp;
	
	if(bSql)
	{
		new szAuth[32], szQuery[128], szData[2];
		get_user_authid(id, szAuth, charsmax(szAuth));
		formatex(szQuery, charsmax(szQuery), "UPDATE `%s` SET `exp`='%d' WHERE `authId` = '%s';", g_szRankTable, g_iExp[id], szAuth);
		szData[0] = SQL_IGNORE;
		szData[1] = id;
		SQL_ThreadQuery(g_sqlTuple, "SQL_Handler", szQuery, szData, sizeof szData);
	}
	new iCurrentLevel = jbe_get_user_level(id);
	if(g_iLevel[id] != iCurrentLevel) jbe_set_user_level(id, iCurrentLevel, bMessage, .bSql = bSql);
}

jbe_set_user_level(id, iLevel, bool:bMessage = true, bool:bFixExp = false, bool:bSql = true)
{
	if(iLevel > MAX_LEVEL) iLevel = MAX_LEVEL;
	g_iLevel[id] = iLevel;
	if(bMessage)
	{
		new szRankName[64];
		formatex(szRankName, charsmax(szRankName), "%L", id, g_szRankName[g_iLevel[id]]);
		UTIL_SayText(id, "%L", id, "JBE_CHAT_ID_RANK_UPDATED", szRankName);
	}
	if(bFixExp) jbe_set_user_exp(id, g_szExp[iLevel], bMessage, bSql);
}

stock jbe_get_user_rank_name_next(id)
{
	new szRankName[48];
	formatex(szRankName, charsmax(szRankName), g_szRankName[g_iLevel[id] + 1]);
	return szRankName;
}

stock jbe_get_user_exp(id)
	return g_iExp[id];

stock jbe_get_user_exp_next(id)
{
	new iLevel = g_iLevel[id] == MAX_LEVEL ? MAX_LEVEL : (g_iLevel[id] + 1);
	return g_szExp[iLevel];
}

jbe_get_user_level(id)
{
	new iCurrentLevel;
	for(new i = 0; i <= TOTAL_PLAYER_LEVELS; i++)
	{
		switch(i)
		{
			case TOTAL_PLAYER_LEVELS: iCurrentLevel = MAX_LEVEL;
			default:
			{
				if(g_iExp[id] < g_szExp[i])
				{
					iCurrentLevel = i - 1;
					break;
				}
			}
		}
	}
	return iCurrentLevel;
}
/*===== -> Игровые события -> =====*///{
event_init()
{
	register_event("ResetHUD", "Event_ResetHUD", "be");
	register_logevent("LogEvent_RestartGame", 2, "1=Game_Commencing", "1&Restart_Round_");
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");
	register_event("StatusValue", "Event_StatusValueShow", "be", "1=2", "2!0");
	register_event("StatusValue", "Event_StatusValueHide", "be", "1=1", "2=0");
	//register_event("CurWeapon", "jbe_effect_kill", "be", "1=1", "3>0");
}

public Event_ResetHUD(id)
{
	if(g_Pahan[id])
		g_Pahan[id] = false;
	if(IsNotSetBit(g_iBitUserConnected, id)) return;
	message_begin(MSG_ONE, MsgId_Money, _, id);
	write_long(g_iUserMoney[id]);
	write_byte(0);
	message_end();
	
	MoneyHUDBool();
	new iHideFlags = GetHudHideFlags();
	if(iHideFlags)
	{
		message_begin(MSG_ONE, g_msgHideWeapon, _, id);
		write_byte(iHideFlags);
		message_end();
	}

}

public msgHideWeapon()
{
	new iHideFlags = GetHudHideFlags();
	if(iHideFlags)
		set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | iHideFlags);
}

GetHudHideFlags()
{
	new iFlags;
	if(g_iResetHud)
	{
		iFlags |= HUD_HIDE_MONEY;
		iFlags |= HIDE_TIMER;
		iFlags |= HUD_HIDE_RHA;
	}
	return iFlags;
}

public MoneyHUDBool()
{
	g_iResetHud = true;
}

public LogEvent_RestartGame()
{
	LogEvent_RoundEnd();
	jbe_set_day(0);
	jbe_set_day_week(0);
	if(task_exists(TASK_GOLOD_GAME))
	{
		remove_task(TASK_GOLOD_GAME);
	}
	if(task_exists(TASK_GOLOD_GAME_TIME)) remove_task(TASK_GOLOD_GAME_TIME);
}

public Event_HLTV()
{
	g_bRoundEnd = false;
	for(new i; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	if(g_bRestartGame)
	{
		if(task_exists(TASK_RESTART_GAME_TIMER)) return;
		g_iDayModeTimer = g_iAllCvars[RESTART_GAME_TIME] + 1;
		set_task(1.0, "jbe_restart_game_timer", TASK_RESTART_GAME_TIMER, _, _, "a", g_iDayModeTimer);
		return;
	}
	jbe_set_day(++g_iDay);
	jbe_set_day_week(++g_iDayWeek);
	g_szChiefName = "";
	g_iChiefStatus = 0;
	g_iBitUserFree = 0;
	g_szFreeNames = "";
	g_iFreeLang = 0;
	g_iBitShok = 0;
	g_iBitUserWanted = 0;
	g_szWantedNames = "";
	g_iWantedLang = 0;
	g_iLastPnId = 0;
	g_iBitSharpening = 0;
	g_iBitScrewdriver = 0;
	g_iBitBalisong = 0;
	g_iBitToma = 0;
	g_iBitPila = 0;
	g_iBitKnif = 0;
	g_iBitKnif = 0;
	g_iBitWeaponStatus = 0;
	g_iBitLatchkey = 0;
	g_iBitKokain = 0;
	g_iBitFrostNade = 0;
	g_iBitClothingGuard = 0;
	g_iBitClothingType = 0;
	g_iBitHingJump = 0;
	g_iBitFastRun = 0;
	g_iBitDoubleJump = 0;
	g_iBitAutoBhop = 0;
	g_iBitDoubleDamage = 0;
	g_iBitLotteryTicket = 0;
	g_iBitUserVoice = 0;
	g_bDoorStatus = false;
	jbe_set_day_mode(1);
}

public jbe_restart_game_timer()
{
	if(--g_iDayModeTimer)
	{
		jbe_open_doors();
		formatex(g_szDayTimer, charsmax(g_szDayTimer), " [%d:%02d]", g_iDayModeTimer / 60, g_iDayModeTimer % 60);
	}
	else
	{
		g_szDayTimer = "";
		g_bRestartGame = false;
		server_cmd("sv_restart 5");
	}
}

/*public jbe_effect_kill(id)
{
	new vec1[3], vec2[3];
	get_user_origin(id, vec1, 1); //origin; your camera point.
	get_user_origin(id, vec2, 4); //termina; where your bullet goes (4 is cs-only)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(0);//TE_BEAMENTPOINTS 0
	write_coord(vec1[0]);
	write_coord(vec1[1]);
	write_coord(vec1[2]);
	write_coord(vec2[0]);
	write_coord(vec2[1]);
	write_coord(vec2[2] - 10);
	write_short(g_pSpriteLgtning[0]);
	write_byte(1); //framestart
	write_byte(8); //framerate
	write_byte(2);//life
	write_byte(10); //width
	write_byte(0); //noise
	if(g_iUserTeam[id] == 1)
	{
		write_byte(255); // r, g, b
		write_byte(0); // r, g, b
		write_byte(0); // r, g, b
	}
	if(g_iUserTeam[id] == 2)
	{
		write_byte(0); // r, g, b
		write_byte(0); // r, g, b
		write_byte(255); // r, g, b
	}
	write_byte(255); //brightness
	write_byte(150); //speed
	message_end();
}*/


public LogEvent_RoundStart()
{
    if(task_exists(TASK_LAST_DIE)) remove_task(TASK_LAST_DIE);
	if(g_bRestartGame) return;
	g_iDayGamesLimit++;
	if(g_iDayMode == 1 || g_iDayMode == 2)
	{
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(IsSetBit(g_UserDog, i))
			{
				UTIL_SayText(i, "%L !yЧтобы обнюхать !gзека !yнажми на !t'Е'", LANG_PLAYER,"JBE_PREFIX");
			}
		}
		set_task(1.0, "pahan", TASK_PAHAN);
	}
	if(g_iFreeHook == 1)
	{
		set_dhudmessage(random(255), 255, random(255), -1.0, -1.0, 0, 3.0, 9.0);
		show_dhudmessage(0, "Вам доступна паутинка, в консоль bind f +hook");
	}
	if(!g_iChiefStatus)
	{
		g_iChiefChoiceTime = 40 + 1;
		set_task(1.0, "jbe_chief_choice_timer", TASK_CHIEF_CHOICE_TIME, _, _, "a", g_iChiefChoiceTime);
	}
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsSetBit(g_iBitUserElectro, i))
		ClearBit(g_iBitUserElectro, i);
		g_iUserSkill[i] = g_iAllCvars[SKILL];
		if(IsSetBit(g_iBitUserFreeNextRound, i))
		{
			jbe_add_user_free(i);
			ClearBit(g_iBitUserFreeNextRound, i);
		}
		if(IsSetBit(g_iBitUserVoiceNextRound, i))
		{
			SetBit(g_iBitUserVoice, i);
			ClearBit(g_iBitUserVoiceNextRound, i);
		}
		if(IsSetBit(g_iBitUserVip, i))
		{
			g_iVipRespawn[i] = g_iAllCvars[VIP_RESPAWN_NUM];
			g_iVipHealth[i] = g_iAllCvars[VIP_HEALTH_NUM];
			g_iVipMoney[i]++;
			g_iVipInvisible[i]++;
			g_iVipHpAp[i]++;
			g_iVipVoice[i]++;
			g_iVipFree[i]++;
		}
		if(IsSetBit(g_iBitUserSuperAdmin, i))
		{
			g_iAdminRespawn[i] = g_iAllCvars[ADMIN_RESPAWN_NUM];
			g_iAdminHealth[i] = g_iAllCvars[ADMIN_HEALTH_NUM];
			g_iAdminMoney[i]++;
			g_iAdminGod[i]++;
			g_iAdminFootSteps[i]++;
			g_iAdminAutoBhop[i]++;
			g_iAdminElectro[i]++;
		}
		if(IsSetBit(g_iBitUserKing, i))
		{
			g_RoundResspawn[i] = 3;
		}
		if(get_user_flags(i) & ADMIN_LEVEL_C)
		{
			g_iZombieBichLimited[i] = 2;
			g_iZombieBichLimited2[i] = 2;
			g_iZombieEnd[i] = g_iAllCvars[ZOMBIE_JUMP];
		}
		if(get_user_flags(i) & ADMIN_CFG)
        {
             devil_skin[i]--;
             devil_riot[i]--;
             devil_chicken[i]--;
			 devil_chickens[i]--;
             devil_damage[i]--;
             devil_dollar[i]--;
			 with_trail[i] = 0;
	    }
	}
	set_fog(124, 127, 123);
	g_bGolod = false;
	if(g_iGolodGMCvars == 1) set_task(1.0, "jbe_golod_game");
}

public jbe_golod_game()
{
	if(g_iGolodGMCvars == 1)
	{
		new count = 0;
		for(new i = 1; i <= g_iMaxPlayers; i++) 
		{
			if(g_iUserTeam[i] == 2) count++;
		}
		if(count == 0)
		{
			jbe_open_doors();
			g_bGolod = true;
			set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
			show_hudmessage(0, "За охранников никого, готовьтесь к голодным играм^nПравила: Убить всех", g_iGolodTimerAttack, g_iAlivePlayersNum[1]);
			set_task(20.0, "jbe_start_golodki", TASK_GOLOD_GAME);
			client_cmd(0, "mp3 play sound/jb_engine/jbe_start_golodki.mp3");
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(is_user_alive(i) || g_iUserTeam[i] == 1) 
				{
					UTIL_BarTime(i, 20);
					Show_WeaponsGolodMenu(i);
					set_user_godmode(i, 0);
					set_user_health(i, 250);
					jbe_set_user_rendering(i, kRenderFxGlowShell, 255, 69, 0, kRenderNormal, 0);
				}

			}
		}
	}
}

public jbe_timer_golod_game()
{
	if(--g_iGolodTimerAttack)
	{
		set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
		show_hudmessage(0, "У Вас есть: %d секунд^nИгроков в живых: %d", g_iGolodTimerAttack, g_iAlivePlayersNum[1]);
	}
	else for(new i = 1; i <= g_iMaxPlayers; i++) user_kill(i);
}

Show_WeaponsGolodMenu(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6), iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_MENU_WEAPONS_GUARD_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1.\w %L^n", id, "JBE_MENU_WEAPONS_GUARD_AK47");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2.\w %L^n", id, "JBE_MENU_WEAPONS_GUARD_M4A1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3.\w %L^n", id, "JBE_MENU_WEAPONS_GUARD_FAMAS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4.\w %L^n", id, "JBE_MENU_WEAPONS_GUARD_AWP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5.\w %L^n", id, "JBE_MENU_WEAPONS_GUARD_AUG");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6.\w %L^n", id, "JBE_MENU_WEAPONS_GUARD_M249");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7.\w %L^n^n", id, "JBE_MENU_WEAPONS_GUARD_XM1014");
	
	return show_menu(id, iKeys, szMenu, -1, "Show_WeaponsGolodMenu");
}

public Handle_WeaponsGolodMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_ak47");
			fm_set_user_bpammo(id, CSW_AK47, 999);
			fm_give_item(id, "weapon_deagle");
			fm_set_user_bpammo(id, CSW_DEAGLE, 999);			
		}
		case 1:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_m4a1");
			fm_set_user_bpammo(id, CSW_M4A1, 999);
			fm_give_item(id, "weapon_deagle");
			fm_set_user_bpammo(id, CSW_DEAGLE, 999);
		}
		case 2:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_famas");
			fm_set_user_bpammo(id, CSW_FAMAS, 999);
			fm_give_item(id, "weapon_deagle");
			fm_set_user_bpammo(id, CSW_DEAGLE, 999);
		}
		case 3:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_awp");
			fm_set_user_bpammo(id, CSW_AWP, 999);
			fm_give_item(id, "weapon_deagle");
			fm_set_user_bpammo(id, CSW_DEAGLE, 999);
		}
		case 4:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_aug");
			fm_set_user_bpammo(id, CSW_AUG, 999);
			fm_give_item(id, "weapon_deagle");
			fm_set_user_bpammo(id, CSW_DEAGLE, 999);
		}
		case 5:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_m249");
			fm_set_user_bpammo(id, CSW_M249, 999);
			fm_give_item(id, "weapon_deagle");
			fm_set_user_bpammo(id, CSW_DEAGLE, 999);
		}
		case 6:
		{
			fm_strip_user_weapons(id);
			fm_give_item(id, "weapon_knife");
			fm_give_item(id, "weapon_xm1014");
			fm_set_user_bpammo(id, CSW_XM1014, 999);
			fm_give_item(id, "weapon_deagle");
			fm_set_user_bpammo(id, CSW_DEAGLE, 999);
		}
	}
	return PLUGIN_HANDLED;
}


public jbe_start_golodki()
{
	g_iFriendlyFire = 1;
	g_iGolodTimerAttack = 105;
	jbe_open_doors();
	{
		set_dhudmessage(255, 69, 0, -1.0, 0.60, 0, 3.0, 5.0);
		show_dhudmessage(0, "Огонь по своим: включен");
	}
	set_task(1.0, "jbe_timer_golod_game", TASK_GOLOD_GAME_TIME, _, _, "a", g_iGolodTimerAttack);
}

stock UTIL_BarTime(id, iTime)
{
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, MsgId_BarTime, {0.0, 0.0, 0.0}, id);
	write_short(iTime);
	message_end();
}

public jbe_chief_choice_timer()
{
	if(--g_iChiefChoiceTime)
	{
		if(g_iChiefChoiceTime == 30) g_iChiefIdOld = 0;
		formatex(g_szChiefName, charsmax(g_szChiefName), " [%i]", g_iChiefChoiceTime);
	}
	else
	{
		g_szChiefName = "";
		jbe_free_day_start();
	}
}

public LogEvent_RoundEnd()
{
	if(jbe_get_day_mode() == 3) formatex(SzPahanMessage, sizeof(SzPahanMessage), "%L", LANG_PLAYER, "JBE_PAHAN_GAMEMODE");
	else formatex(SzPahanMessage, sizeof(SzPahanMessage), "%L", LANG_PLAYER, "JBE_PAHAN_GAMEMODE");
	
	if(!task_exists(TASK_ROUND_END))
		set_task(0.1, "LogEvent_RoundEndTask", TASK_ROUND_END);
}

public LogEvent_RoundEndTask()
{	
    if(task_exists(TASK_LAST_DIE)) remove_task(TASK_LAST_DIE);
	if(g_iDayMode != 3)
	{
		g_iFriendlyFire = 0;
		remove_task(621216); task_exists(621216);
		if(task_exists(TASK_GOLOD_GAME)) remove_task(TASK_GOLOD_GAME);
		if(task_exists(TASK_GOLOD_GAME_TIME)) remove_task(TASK_GOLOD_GAME_TIME);
		g_iChiefId = 0;
		if(task_exists(TASK_CHIEF_CHOICE_TIME))
		{
			remove_task(TASK_CHIEF_CHOICE_TIME);
			g_szChiefName = "";
		}
		if(g_iDayMode == 2) jbe_free_day_ended();
		if(g_bSoccerStatus) jbe_soccer_disable_all();
		if(g_bBoxingStatus) jbe_boxing_disable_all();
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			CREATE_KILLPLAYERATTACHMENTS(i);
			if(IsNotSetBit(g_iBitUserAlive, i)) continue;
			if(task_exists(i+TASK_REMOVE_SYRINGE))
			{
				remove_task(i+TASK_REMOVE_SYRINGE);
				if(get_user_weapon(i))
				{
					new iActiveItem = get_pdata_cbase(i, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
			}
			if(pev(i, pev_renderfx) != kRenderFxNone || pev(i, pev_rendermode) != kRenderNormal)
			{
				jbe_set_user_rendering(i, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
				g_eUserRendering[i][RENDER_STATUS] = false;
			}
			if(g_iBitUserFrozen && IsSetBit(g_iBitUserFrozen, i))
			{
				ClearBit(g_iBitUserFrozen, i);
				if(task_exists(i+TASK_FROSTNADE_DEFROST)) remove_task(i+TASK_FROSTNADE_DEFROST);
				set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
				set_pdata_float(i, m_flNextAttack, 0.0, linux_diff_player);
				emit_sound(i, CHAN_AUTO, "jb_engine/shop/defrost_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				new Float:vecOrigin[3]; pev(i, pev_origin, vecOrigin);
				CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
			}
			if(g_iBitInvisibleHat && IsSetBit(g_iBitInvisibleHat, i))
			{
				ClearBit(g_iBitInvisibleHat, i);
				if(task_exists(i+TASK_INVISIBLE_HAT)) remove_task(i+TASK_INVISIBLE_HAT);
			}
			if(g_iBitRandomGlow && IsSetBit(g_iBitRandomGlow, i)) ClearBit(g_iBitRandomGlow, i);
		}
		if(g_iDuelStatus)
		{
			g_iBitUserDuel = 0;
			if(task_exists(TASK_DUEL_COUNT_DOWN))
			{
				remove_task(TASK_DUEL_COUNT_DOWN);
				client_cmd(0, "mp3 stop");
			}
		}
	}
	else
	{
		if(task_exists(TASK_VOTE_DAY_MODE_TIMER))
		{
			remove_task(TASK_VOTE_DAY_MODE_TIMER);
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(IsNotSetBit(g_iBitUserVoteDayMode, i)) continue;
				ClearBit(g_iBitUserVoteDayMode, i);
				ClearBit(g_iBitUserDayModeVoted, i);
				show_menu(i, 0, "^n");
				jbe_menu_unblock(i);
				set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
				set_pdata_float(i, m_flNextAttack, 0.0, linux_diff_player);
				UTIL_ScreenFade(i, 512, 512, 0, 0, 0, 0, 255, 1);
			}
		}
		if(g_iVoteDayMode != -1)
		{
			if(task_exists(TASK_DAY_MODE_TIMER)) remove_task(TASK_DAY_MODE_TIMER);
			g_szDayTimer = "";
			ExecuteForward(g_iHookDayModeEnded, g_iReturnDayMode, g_iVoteDayMode, g_iAlivePlayersNum[1] ? 1 : 2);
			g_iVoteDayMode = -1;
		}
	}
	for(new i; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
	g_bRoundEnd = true;
	if(g_iRoundSoundSize)
	{
		new aDataRoundSound[DATA_ROUND_SOUND], iTrack = random_num(0, g_iRoundSoundSize - 1);
		ArrayGetArray(g_aDataRoundSound, iTrack, aDataRoundSound);
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(IsNotSetBit(g_iBitUserConnected, i) || IsNotSetBit(g_iBitUserRoundSound, i)) continue;
			client_cmd(i, "mp3 play sound/jb_engine/round_sound/%s.mp3", aDataRoundSound[FILE_NAME]);
			UTIL_SayText(i, "%L %L: !t%s", i, "JBE_PREFIX", i, "JBE_CHAT_ID_NOW_PLAYING", aDataRoundSound[TRACK_NAME]);
			UTIL_ScreenFade(i, 0, 0, 4, random_num(0, 255), random_num(0, 255), random_num(0, 255), 100, 1);
			if(IsNotSetBit(g_UserDog, i))
			{
				if(IsNotSetBit(g_iBitUserAlive, i)) continue;
				{
					static iszViewModel = 0;
					if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/v_round_sound.mdl"))) set_pev_string(i, pev_viewmodel2, iszViewModel);
					set_pdata_float(i, m_flNextAttack, 5.0);
					UTIL_WeaponAnimation(i, 0);
				}
			}
		}
	}
}

public Event_StatusValueShow(id)
{
	new iTarget = read_data(2), szName[32], szTeam[][] = {"", "JBE_ID_HUD_STATUS_TEXT_PRISONER", "JBE_ID_HUD_STATUS_TEXT_GUARD", ""};
	get_user_name(iTarget, szName, charsmax(szName));
	set_hudmessage(RED[id], GREEN[id], BLUE[id], -1.0, 0.8, 0, 0.0, 10.0, 0.0, 0.0, -1);
	ShowSyncHudMsg(id, g_iSyncStatusText, "%L", id, "JBE_ID_HUD_STATUS_TEXT", id, szTeam[g_iUserTeam[iTarget]], szName, get_user_health(iTarget), get_user_armor(iTarget), g_iUserMoney[iTarget]);

}

public Event_StatusValueHide(id) ClearSyncHud(id, g_iSyncStatusText);
/*===== <- Игровые события <- =====*///}

/*===== -> Консольные команды -> =====*///{
clcmd_init()
{
	for(new i, szBlockCmd[][] = {"jointeam", "joinclass"}; i < sizeof szBlockCmd; i++) register_clcmd(szBlockCmd[i], "ClCmd_Block");
	register_clcmd("chooseteam", "ClCmd_ChooseTeam");
	register_clcmd("menuselect", "ClCmd_MenuSelect");
	register_clcmd("money_transfer", "ClCmd_MoneyTransfer");
	register_clcmd("radio1", "ClCmd_Radio1");
	register_clcmd("radio2", "ClCmd_Radio2");
	register_clcmd("radio3", "ClCmd_Radio3");
	register_clcmd("drop", "ClCmd_Drop");
	register_clcmd("+hook", "ClCmd_HookOn");
	register_clcmd("-hook", "ClCmd_HookOff");
	register_clcmd("say /bind", "ClCmd_BindKeys");
	register_clcmd("say /rs", "ClCmd_RsMenu");
	register_clcmd("say", "ClCmd_CheckAnswer");
	register_clcmd("say_team", "ClCmd_CheckAnswer");
}

public ClCmd_CheckAnswer(id)
{
	new szBuffer[256];
	read_args(szBuffer, charsmax(szBuffer));
	remove_quotes(szBuffer);
	client_cmd(id,"spk jb_engine/admin.wav");
	CREATE_PLAYERATTACHMENT(id, _, g_Chat, 10);
}

public ClCmd_MenuSelect(id) client_cmd(id, "spk jb_engine/menu/mg3_close.wav");

public ClCmd_RsMenu(id)
{
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0); 
	UTIL_SayText(id, "%L Вы сбросили ваши !gфраги!y и !gсмерти!y.", id, "JBE_PREFIX");
	client_cmd(id,"spk jb_engine/admin.wav");
}
public ClCmd_Block(id) return PLUGIN_HANDLED;

public ClCmd_ColorMenu(id)
{
	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	Show_ColorMenu(id);
	return PLUGIN_HANDLED;
}

public ClCmd_ChooseTeam(id)
{
	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	client_cmd(id, "spk jb_engine/menu/mg3_open.wav");
	switch(g_iUserTeam[id])
	{
		case 1: Show_MainPnMenu(id);
		case 2: Show_MainGrMenu(id);
		default: Show_ChooseTeamMenu(id, 0);
	}
	return PLUGIN_HANDLED;
}

public ClCmd_MoneyTransfer(id, iTarget, iMoney)
{
	if(!iTarget)
	{
		new szArg1[3], szArg2[7];
		read_argv(1, szArg1, charsmax(szArg1));
		read_argv(2, szArg2, charsmax(szArg2));
		if(!is_str_num(szArg1) || !is_str_num(szArg2))
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_ERROR_PARAMETERS");
			return PLUGIN_HANDLED;
		}
		iTarget = str_to_num(szArg1);
		iMoney = str_to_num(szArg2);
	}
	if(id == iTarget || !jbe_is_user_valid(iTarget) || IsNotSetBit(g_iBitUserConnected, iTarget)) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_UNKNOWN_PLAYER");
	else if(g_iUserMoney[id] < iMoney) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SUFFICIENT_FUNDS");
	else if(iMoney <= 0) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_MIN_AMOUNT_TRANSFER");
	else
	{
		jbe_set_user_money(iTarget, g_iUserMoney[iTarget] + iMoney, 1);
		jbe_set_user_money(id, g_iUserMoney[id] - iMoney, 1);
		new szName[32], szNameTarget[32];
		get_user_name(id, szName, charsmax(szName));
		get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
		UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ALL_MONEY_TRANSFER", szName, iMoney, szNameTarget);
	}
	return PLUGIN_HANDLED;
}

public ClCmd_Radio1(id)
{
	if(g_iUserTeam[id] == 1 && IsSetBit(g_iBitClothingGuard, id))
	{
		if(IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id)) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_BLOCKED_CLOTHING_GUARD");
		else
		{
			if(IsSetBit(g_iBitClothingType, id))
			{
				if(IsSetBit(g_UserZombie, id)) jbe_set_user_model(id, g_szPlayerModel[ZOMBIE]);
				else if(get_user_flags(id) & ADMIN_RCON) jbe_set_user_model(id, g_szPlayerModel[OWNER]);
				else if(get_user_flags(id) & ADMIN_LEVEL_D) jbe_set_user_model(id, g_szPlayerModel[GIRL]);
				else
				{
					jbe_set_user_model(id, g_szPlayerModel[PRISONER]);
					if(IsSetBit(g_iBitUserFree, id)) set_pev(id, pev_skin, g_iAllCvars[SKIN_FREEDAY]);
					else if(IsSetBit(g_iBitUserWanted, id)) set_pev(id, pev_skin, g_iAllCvars[SKIN_WANTED]);
				}
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_REMOVE_CLOTHING_GUARD");
			}
			{
				if(IsSetBit(g_UserZombie, id)) jbe_set_user_model(id, g_szPlayerModel[ZOMBIE]);
				else if(get_user_flags(id) & ADMIN_RCON) jbe_set_user_model(id, g_szPlayerModel[OWNER]);
				else if(get_user_flags(id) & ADMIN_LEVEL_D) jbe_set_user_model(id, g_szPlayerModel[GIRL]);
				else jbe_set_user_model(id, g_szPlayerModel[GUARD]);
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_DRESSED_CLOTHING_GUARD");
			}
			InvertBit(g_iBitClothingType, id);
		}
	}
	return PLUGIN_HANDLED;
}

public ClCmd_Radio2(id)
{
	if(g_iUserTeam[id] == 1 && get_user_weapon(id) == CSW_KNIFE && (IsSetBit(g_iBitSharpening, id) || IsSetBit(g_iBitScrewdriver, id) || IsSetBit(g_iBitBalisong, id) || IsSetBit(g_iBitPila, id) || IsSetBit(g_iBitShok, id) || IsSetBit(g_iBitToma, id) || IsSetBit(g_iBitKnif, id) || IsSetBit(g_iBitTopor, id)))
	{
		if(IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id))
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_BLOCKED");
			return PLUGIN_HANDLED;
		}
		if(get_pdata_float(id, m_flNextAttack) < 0.1)
		{
			new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
			if(iActiveItem > 0)
			{
				InvertBit(g_iBitWeaponStatus, id);
				ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				UTIL_WeaponAnimation(id, 3);
			}
		}
	}
	return PLUGIN_HANDLED;
}

public ClCmd_Radio3(id)
{
	if(g_iUserTeam[id] == 1 && IsSetBit(g_iBitLatchkey, id))
	{
		new iTarget, iBody;
		get_user_aiming(id, iTarget, iBody, 30);
		if(pev_valid(iTarget))
		{
			new szClassName[32];
			pev(iTarget, pev_classname, szClassName, charsmax(szClassName));
			if(szClassName[5] == 'd' && szClassName[6] == 'o' && szClassName[7] == 'o' && szClassName[8] == 'r') dllfunc(DLLFunc_Use, iTarget, id);
			else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_LATCHKEY_ERROR_DOOR");
		}
		else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_LATCHKEY_ERROR_DOOR");
	}
	return PLUGIN_HANDLED;
}

public ClCmd_Drop(id)
{
	if(IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public ClCmd_HookOn(id)
{
	if(IsSetBit(g_iBitUserWanted, id) || g_iUserSkill[id] < 20 || g_iDayMode == 3 || g_iEnableHook || g_bGolod || IsNotSetBit(g_iBitUserHook, id) || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_UserDog, id) || IsSetBit(g_iBitUserDuel, id) || task_exists(id+TASK_HOOK_THINK)) return PLUGIN_HANDLED;
	new iFlag = get_user_flags(id);
	if(g_iHookSkill == 1) ////Забираем у всех энергию
	{
		if(iFlag & ADMIN_MENU || iFlag & ADMIN_VOTE || iFlag & ADMIN_BAN || iFlag & ADMIN_LEVEL_D || iFlag & ADMIN_LEVEL_H) 
		{
			if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= 5;
		}
		else if(g_iUserSkill[id] > -10) g_iUserSkill[id] -= 25;
		if(g_iUserSkill[id] < 20) UTIL_SayText(id, "%L !yУ Вас мало !tэнергии!y, подождите немного", id, "JBE_PREFIX");
	}
	if(g_iHookSkill == 2) ////Забираем энергию у всех кроме создателя
	{
		if(iFlag & ADMIN_RCON){}
		else 
		if(iFlag & ADMIN_MENU || iFlag & ADMIN_VOTE || iFlag & ADMIN_BAN || iFlag & ADMIN_LEVEL_D || iFlag & ADMIN_LEVEL_H) 
		{
			if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= 5;
		}
		else if(g_iUserSkill[id] > -10) g_iUserSkill[id] -= 25;
		if(g_iUserSkill[id] < 20) UTIL_SayText(id, "%L !yУ Вас мало !tэнергии!y, подождите немного", id, "JBE_PREFIX");
	}
	if(g_iModeFly[id])
	{
		new iOrigin[3];
		get_user_origin(id, iOrigin, 3);
		g_vecHookOrigin[id][0] = float(iOrigin[0]);
		g_vecHookOrigin[id][1] = float(iOrigin[1]);
		g_vecHookOrigin[id][2] = float(iOrigin[2]);
		switch(g_StatusHookEnd[id])
		{
			case 0: 
			{
				CREATE_SPRITE(g_vecHookOrigin[id], g_iSpriteEnd[0], 6, 255);
				UTIL_CreateTipeBreak(g_vecHookOrigin[id], g_iSpriteEnd[0]);
			}
			case 1: 
			{
				CREATE_SPRITE(g_vecHookOrigin[id], g_iSpriteEnd[1], 8, 255);
				UTIL_CreateTipeBreak(g_vecHookOrigin[id], g_iSpriteEnd[1]);
			}
			case 2: 
			{
				CREATE_SPRITE(g_vecHookOrigin[id], g_iSpriteEnd[2], 8, 255);
				UTIL_CreateTipeBreak(g_vecHookOrigin[id], g_iSpriteEnd[2]);
			}
			case 3: 
			{
				CREATE_SPRITE(g_vecHookOrigin[id], g_iSpriteEnd[3], 8, 255);
				UTIL_CreateTipeBreak(g_vecHookOrigin[id], g_iSpriteEnd[3]);
			}
		}
		switch(g_StatusHook[id])
		{
			case 1: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_a.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			case 2: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_c.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			case 3: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_b.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			case 4: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_c.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			case 5: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_t.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			case 6: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_h.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		jbe_hook_think(id+TASK_HOOK_THINK);
		set_task(0.1, "jbe_hook_think", id+TASK_HOOK_THINK, _, _, "b");
		if(g_iUserType[id] == -1) UTIL_create_beamfollow(id, g_iSpriteEnd[3], 20, 20, 255, 255, 255, 255);
	}
	else
	{
		Fly_task(id+TASK_FLY_PLAYER);
		set_task(0.1, "Fly_task", id+TASK_FLY_PLAYER, _, _, "b");
		UTIL_create_beamfollow(id, g_iSpriteEnd[random_num(0,3)], 20, 20, 255, 255, 255, 255);
	}
	return PLUGIN_HANDLED;
}

public jbe_hook_think(pPlayer)
{
	pPlayer -= TASK_HOOK_THINK;
	new Float:vecOrigin[3];
	pev(pPlayer, pev_origin, vecOrigin);
	new Float:vecVelocity[3];
	vecVelocity[0] = (g_vecHookOrigin[pPlayer][0] - vecOrigin[0]) * 3.0;
	vecVelocity[1] = (g_vecHookOrigin[pPlayer][1] - vecOrigin[1]) * 3.0;
	vecVelocity[2] = (g_vecHookOrigin[pPlayer][2] - vecOrigin[2]) * 3.0;
	switch(g_StatusHook[pPlayer])
	{
		case 1:
		{
			new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
			new Float:flX = (5 * 120.0) / floatsqroot(flY);
			vecVelocity[0] *= flX;
			vecVelocity[1] *= flX;
			vecVelocity[2] *= flX;
		}
		case 2:
		{
			new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
			new Float:flX = (5 * 130.0) / floatsqroot(flY);
			vecVelocity[0] *= flX;
			vecVelocity[1] *= flX;
			vecVelocity[2] *= flX;
		}
		case 3:
		{
			new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
			new Float:flX = (5 * 145.0) / floatsqroot(flY);
			vecVelocity[0] *= flX;
			vecVelocity[1] *= flX;
			vecVelocity[2] *= flX;
		}
		case 4:
		{
			new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
			new Float:flX = (5 * 150.0) / floatsqroot(flY);
			vecVelocity[0] *= flX;
			vecVelocity[1] *= flX;
			vecVelocity[2] *= flX;
		}
		case 5:
		{
			new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
			new Float:flX = (5 * 157.0) / floatsqroot(flY);
			vecVelocity[0] *= flX;
			vecVelocity[1] *= flX;
			vecVelocity[2] *= flX;
		}
		case 6:
		{
			new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
			new Float:flX = (5 * 180.0) / floatsqroot(flY);
			vecVelocity[0] *= flX;
			vecVelocity[1] *= flX;
			vecVelocity[2] *= flX;
		}
	}
	set_pev(pPlayer, pev_velocity, vecVelocity);
	switch(g_StatusHook[pPlayer])
	{
		case 1: CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[0], 0, 1, 1, 30, 30, random(255), random(255), random(255), g_iGlowHook[pPlayer], _);
		case 3: CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[1], 0, 1, 1, 30, 0, 255, 255, 255, g_iGlowHook[pPlayer], _);
		case 2: CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[2], 0, 1, 1, 30, 0, 255, 255, 255, g_iGlowHook[pPlayer], _);
		case 4:	CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[3], 0, 1, 1, 30, 0, 255, 255, 255, g_iGlowHook[pPlayer], _);
		case 5:	CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[4], 0, 1, 1, 30, 0, 255, 255, 255, g_iGlowHook[pPlayer], _);
		case 6:	CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[5], 0, 1, 1, 30, 0, 255, 255, 255, g_iGlowHook[pPlayer], _);
	}
}

public ClCmd_HookOff(id)
{
	if(g_iModeFly[id])
	{
		if(task_exists(id+TASK_HOOK_THINK))
		{
			remove_task(id+TASK_HOOK_THINK);
			switch(g_StatusHook[id])
			{
				case 1: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_a.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
				case 2: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_b.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
				case 3: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_c.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
				case 4: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_t.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
				case 5: emit_sound(id, CHAN_STATIC, "jb_engine/jb_hook/hook_h.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
		}
	}
	else
	{
		if(task_exists(id+TASK_FLY_PLAYER))
			remove_task(id+TASK_FLY_PLAYER);
	}
	if(g_iUserType[id] == -1) UTIL_create_killbeam(id);
	return PLUGIN_HANDLED;
}

public Fly_task(id)
{
	id -= TASK_FLY_PLAYER;
	new Float:fAim[3], Float:vecVelocity[3];
	VelocityByAim(id, g_iSpeedFly[id], fAim);
	vecVelocity[0] = fAim[0];
	vecVelocity[1] = fAim[1];
	vecVelocity[2] = fAim[2];
	set_pev(id, pev_velocity, vecVelocity);
}
/* 
Какие координаты получаем:

0 - Текущая позиция (Значение по умолчанию) 
1 - Позиция от глаз
2 - Последняя позиция игрока
3 - Последняя позиция глаз игрока
4 - Позиция последнего хита пули (только CS)

но стоит попробовать, дальше vec2 минусуешь на свое (vec2[1] - 10)
1 это ось Y т.е по вертикале */

Show_HookSetting(id)
{
	new szMenu[512], iKeys = (1<<4|1<<7|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SETTING_HOOK_TITLE");
	if(!g_iEnableHook)
	{
		if(g_iModeFly[id])
		{
			iKeys |= (1<<0|1<<1|1<<3);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_SETTING_HOOK_TYPE");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_SETTING_HOOK_GLOW_INFO");
			if(get_user_flags(id) & ADMIN_MENU)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_HOOK_USERS");
				iKeys |= (1<<2);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[Блатной]^n", id, "JBE_MENU_HOOK_USERS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_SETTING_HOOK_END_INFO");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y5. \wРежим Fly: \r[%s]^n", g_iModeFly[id] ? "Выкл":"Вкл");
		}
		else 
		{
			iKeys |= (1<<5);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dВ этом режиме вы летаете с помощью мыши^n");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dНажмите клавишу - использовать паутинку^n");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y5. \wРежим Fly: \r[%s]^n", g_iModeFly[id] ? "Выкл":"Вкл");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n^n", id, "JBE_SETTING_FLYSPEED");
		}
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_SETTING_HOOK_OFF");
	if(get_user_flags(id) & ADMIN_LEVEL_E) 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y8. \wПаутинка/FLY: \r[%s]^n", g_iEnableHook ? "Включена":"Выключена");
		iKeys |= (1<<7);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dПаутинка/FLY: \d[%s]^n", g_iEnableHook ? "Включена":"Выключена");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_HookSetting");
	
}
public Handle_HookSetting(id, iKey)
{
	switch(iKey)
	{
		case 0: return Show_Hook_Type(id);
		case 1: return Show_Hook_Glow(id);
		case 2: return Show_GiveHook_Menu(id, 0);
		case 3: return Show_Hook_Endtype(id);
		case 4: 
		{
			if(!g_iModeFly[id]) g_iModeFly[id] = true;
			else g_iModeFly[id] = false;
		}
		case 5: return Show_Fly_Speed(id);
		case 7:
		{
			if(!g_iEnableHook) g_iEnableHook = true;
			else g_iEnableHook = false;
		}
		case 9: return PLUGIN_HANDLED;
	}
	return Show_HookSetting(id);
}

Show_Fly_Speed(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SETTING_HOOK_TITLE");
	if(g_iSpeedFly[id] == 1000)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \d%L \r[#]^n", id, "JBE_FLY_SPEED_1");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_FLY_SPEED_1");
	if(g_iSpeedFly[id] == 720)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \d%L \r[#]^n", id, "JBE_FLY_SPEED_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_FLY_SPEED_2");
	if(g_iSpeedFly[id] == 500)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \d%L \r[#]^n", id, "JBE_FLY_SPEED_3");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_FLY_SPEED_3");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Fly_Speed");
	
}

public Handle_Fly_Speed(id, iKey)
{
	switch(iKey)
	{
		case 0: g_iSpeedFly[id] = 1000;
		case 1: g_iSpeedFly[id] = 720;
		case 2: g_iSpeedFly[id] = 500;
		case 9: return Show_HookSetting(id);
	}
	return Show_HookSetting(id);
}

Show_Hook_Endtype(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SETTING_HOOK_TITLE");
	if(g_StatusHookEnd[id] == 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \d%L \r[#]^n", id, "JBE_SETTING_END_SPRITE_1");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_SETTING_END_SPRITE_1");
	if(g_StatusHookEnd[id] == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \d%L \r[#]^n", id, "JBE_SETTING_END_SPRITE_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_SETTING_END_SPRITE_2");
	if(g_StatusHookEnd[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \d%L \r[#]^n", id, "JBE_SETTING_END_SPRITE_3");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_SETTING_END_SPRITE_3");
	if(g_StatusHookEnd[id] == 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \d%L \r[#]^n", id, "JBE_SETTING_END_SPRITE_4");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_SETTING_END_SPRITE_4");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Hook_Endtype");
}
public Handle_Hook_EndType(id, iKey)
{
	switch(iKey)
	{
		case 0: g_StatusHookEnd[id] = 0;
		case 1: g_StatusHookEnd[id] = 1;
		case 2: g_StatusHookEnd[id] = 2;
		case 3: g_StatusHookEnd[id] = 3;
		case 9: return Show_HookSetting(id);
	}
	return Show_HookSetting(id);
}

Show_Hook_Type(id)
{
	new szMenu[512], iKeys = (1<<9), iFlag = get_user_flags(id),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SETTING_HOOK_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dВаш выбор сохраняется^n^n");
	if(iFlag & ADMIN_LEVEL_H)
	{
		if(g_StatusHook[id] == 1)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \d%L \r[#]^n", id, "JBE_SETTING_HOOK_LIGHTNING");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_SETTING_HOOK_LIGHTNING");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_SETTING_HOOK_LIGHTNING");
	if(iFlag & ADMIN_LEVEL_H)
	{
		if(g_StatusHook[id] == 2)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \d%L \r[#]^n", id, "JBE_SETTING_HOOK_RAINBOW");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_SETTING_HOOK_RAINBOW");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_SETTING_HOOK_RAINBOW");
	if(iFlag & ADMIN_BAN)
	{
		if(g_StatusHook[id] == 3)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \d%L \r[#]^n", id, "JBE_SETTING_HOOK_BLUE");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_SETTING_HOOK_BLUE");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_SETTING_HOOK_BLUE");
	if(iFlag & ADMIN_VOTE)
	{
		if(g_StatusHook[id] == 4)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \d%L \r[#]^n", id, "JBE_SETTING_HOOK_TEXT");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_SETTING_HOOK_TEXT");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_SETTING_HOOK_TEXT");
	if(iFlag & ADMIN_MENU)
	{
		if(g_StatusHook[id] == 5)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \d%L \r[#]^n", id, "JBE_SETTING_HOOK_RAD");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_SETTING_HOOK_RAD");
		iKeys |= (1<<4);		
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_SETTING_HOOK_RAD");
	if(iFlag & ADMIN_LEVEL_G)
	{
		if(g_StatusHook[id] == 6)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \d%L \r[#]^n", id, "JBE_SETTING_HOOK_CEP");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_SETTING_HOOK_CEP");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_SETTING_HOOK_CEP");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Hook_Type");
}
public Handle_Hook_Type(id, iKey)
{
	switch(iKey)
	{
		case 0: g_StatusHook[id] = 1;
		case 1: g_StatusHook[id] = 2;
		case 2: g_StatusHook[id] = 3;
		case 3: g_StatusHook[id] = 4;
		case 4: g_StatusHook[id] = 5;
		case 5: g_StatusHook[id] = 6;
		case 9: return Show_HookSetting(id);
	}
	return Show_HookSetting(id);
}

Show_Hook_Glow(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SETTING_HOOK_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_SETTING_HOOK_GLOW");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_SETTING_HOOK_GLOW_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_SETTING_HOOK_GLOW_2");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Hook_Glow");
	
}

public Handle_Hook_Glow(id, iKey)
{
	switch(iKey)
	{
		case 0: g_iGlowHook[id] = 255;
		case 1: g_iGlowHook[id] = 100;
		case 2: g_iGlowHook[id] = 50;
		case 9: return Show_HookSetting(id);
	}
	return Show_HookSetting(id);
}

public Show_GiveHook_Menu(id, page)
{
	new szPlayers[32], szName[64], szKey[3],
	iCount, iMenu, iPlayer, i;

	get_players(szPlayers, iCount, "h");
	iMenu = menu_create("Выдать/Забрать паутинку", "jbe_give_hook_menu_handler");

	for( i = 0; i < iCount; i++ )
	{
		iPlayer = szPlayers[i];
		get_user_name(iPlayer, szName, charsmax(szName));

		if(IsSetBit(g_iBitUserHook, iPlayer)) format(szName, charsmax(szName), "%s \r'Забрать'", szName);
		else format(szName, charsmax(szName), "%s \y'Выдать'", szName);

		szKey[0] = iPlayer;
		menu_additem(iMenu, szName, szKey);
	}

	menu_setprop(iMenu, MPROP_EXITNAME, "Выход");
	menu_setprop(iMenu, MPROP_NEXTNAME, "Далее");
	menu_setprop(iMenu, MPROP_BACKNAME, "Назад");

	return menu_display(id, iMenu, page);
}

public jbe_give_hook_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT) return menu_destroy(menu);

	static szKey[3], szAdminName[32], szTargetName[32],
	iData;

	menu_item_getinfo(menu, item, iData, szKey, charsmax(szKey), .callback = iData);
	item = szKey[0];

	menu_destroy(menu);
	if (!is_user_connected(item)) return Show_GiveHook_Menu(id, 0);

	get_user_name(id, szAdminName, charsmax(szAdminName));
	get_user_name(item, szTargetName, charsmax(szTargetName));

	if(IsSetBit(g_iBitUserHook, item))
	{
		ClearBit(g_iBitUserHook, item);
		UTIL_SayText(0, "%L !yАвторитет !t%s !yзабрал паутинку у !g%s", id, "JBE_PREFIX", szAdminName, szTargetName);
		g_StatusHook[item] = 0; g_iGlowHook[item] = 0; g_iUserFreeHook[item] = 2;
	}
	else
	{
		SetBit(g_iBitUserHook, item);
		UTIL_SayText(0, "%L !yАвторитет !t%s !yвыдал паутинку !g%s", id, "JBE_PREFIX", szAdminName, szTargetName);
		g_StatusHook[item] = 3; g_iGlowHook[item] = 255; g_iUserFreeHook[item] = 1;
	}

	return Show_GiveHook_Menu(id, item / 7);
}

public ClCmd_BindKeys(id) client_cmd(id, "^"^";BIND F3 chooseteam;BIND z radio1;BIND x radio2;BIND c radio3");
/*===== <- Консольные команды <- =====*///}

/*===== -> Меню -> =====*///

menu_init()
{
	register_menucmd(register_menuid("Show_ChooseTeamMenu"), (1<<0|1<<1|1<<4|1<<5|1<<8|1<<9), "Handle_ChooseTeamMenu");
	register_menucmd(register_menuid("Show_CreatorMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_CreatorMenu");
	register_menucmd(register_menuid("Show_MoneyMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_GiveMoneyMenu");
	register_menucmd(register_menuid("Show_WeaponsGolodMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6), "Handle_WeaponsGolodMenu");
	register_menucmd(register_menuid("Show_MainPnMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MainPnMenu");
	register_menucmd(register_menuid("Show_MainGrMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MainGrMenu");
	register_menucmd(register_menuid("Show_ShopPrisonersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_ShopPrisonersMenu");
	register_menucmd(register_menuid("Show_ShopWeaponsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ShopWeaponsMenu");
	register_menucmd(register_menuid("Show_ShopItemsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ShopItemsMenu");
	register_menucmd(register_menuid("Show_ShopSkillsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_ShopSkillsMenu");
	register_menucmd(register_menuid("Show_ShopOtherMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_ShopOtherMenu");
	register_menucmd(register_menuid("Show_PrankPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PrankPrisonerMenu");
	register_menucmd(register_menuid("Show_ShopGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ShopGuardMenu");
	register_menucmd(register_menuid("Show_ShopChiefMenu"), (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), "Handle_ShopChiefMenu");
	register_menucmd(register_menuid("Show_ShopGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_ShopGuardMenu");
	register_menucmd(register_menuid("Show_MoneyTransferMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MoneyTransferMenu");
	register_menucmd(register_menuid("Show_MoneyAmountMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<7|1<<8|1<<9), "Handle_MoneyAmountMenu");
	register_menucmd(register_menuid("Show_CreatorMoney"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_CreatorMoney");
	register_menucmd(register_menuid("Show_ChiefMenu_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ChiefMenu_1");
	register_menucmd(register_menuid("Show_CountDownMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_CountDownMenu");
	register_menucmd(register_menuid("Show_FreeDayControlMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_FreeDayControlMenu");
	register_menucmd(register_menuid("Show_PunishGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PunishGuardMenu");
	register_menucmd(register_menuid("Show_TransferChiefMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TransferChiefMenu");
	register_menucmd(register_menuid("Show_TreatPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TreatPrisonerMenu");
	register_menucmd(register_menuid("Show_ChiefMenu_2"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ChiefMenu_2");
	register_menucmd(register_menuid("Show_VoiceControlMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_VoiceControlMenu");
	register_menucmd(register_menuid("Show_MiniGameMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_MiniGameMenu");
	register_menucmd(register_menuid("Show_SoccerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_SoccerMenu");
	register_menucmd(register_menuid("Show_SoccerTeamMenu"), (1<<0|1<<1|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SoccerTeamMenu");
	register_menucmd(register_menuid("Show_SoccerScoreMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_SoccerScoreMenu");
	register_menucmd(register_menuid("Show_BoxingMenu"), (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), "Handle_BoxingMenu");
	register_menucmd(register_menuid("Show_BoxingTeamMenu"), (1<<0|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_BoxingTeamMenu");
	register_menucmd(register_menuid("Show_KillReasonsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_KillReasonsMenu");
	register_menucmd(register_menuid("Show_ShopWeaponsMenuGu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ShopWeaponsMenuGu");
	register_menucmd(register_menuid("Show_KilledUsersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_KilledUsersMenu");
	register_menucmd(register_menuid("Show_LastPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_LastPrisonerMenu");
	register_menucmd(register_menuid("Show_ChoiceDuelMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ChoiceDuelMenu");
	register_menucmd(register_menuid("Show_DuelUsersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DuelUsersMenu");
	register_menucmd(register_menuid("Show_DayModeMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DayModeMenu");
	register_menucmd(register_menuid("Show_PrivilegesMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_PrivilegesMenu");
	register_menucmd(register_menuid("Show_VipMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_VipMenu");
	register_menucmd(register_menuid("Show_AdminMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_AdminMenu");
	register_menucmd(register_menuid("Show_SuperAdminMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SuperAdminMenu");
	register_menucmd(register_menuid("Show_KingMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_KingMenu");
	register_menucmd(register_menuid("Show_RespawnMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_RespawnMenu");
	register_menucmd(register_menuid("Show_SexMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SexMenu");
	register_menucmd(register_menuid("Show_ColorMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ColorMenu");
	register_menucmd(register_menuid("Show_CordMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_CordMenu");
	register_menucmd(register_menuid("Show_FunMenuPn"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_FunMenuPn");
	register_menucmd(register_menuid("Show_Contact"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_Contact");
	register_menucmd(register_menuid("Show_GLAdmin"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_GLAdmin");
	register_menucmd(register_menuid("Show_HookSetting"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_HookSetting");
	register_menucmd(register_menuid("Show_Sborka"), (1<<0|1<<9), "Handle_Sborka");
	register_menucmd(register_menuid("Show_MenuDog"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MenuDog");	
	register_menucmd(register_menuid("Show_TrackMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TrackMenu");	
	register_menucmd(register_menuid("Show_GolodGame"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_GolodGame");
	register_menucmd(register_menuid("Show_ChosMenu"), (1<<0|1<<1|1<<2|1<<9), "Handle_ChosMenu");
	register_menucmd(register_menuid("Show_TrailMenu"), (1<<0|1<<1|1<<8|1<<9), "Handle_TrailMenu");
	register_menucmd(register_menuid("Show_Geroi"), (1<<8|1<<9), "Handle_MainGeroi");
	register_menucmd(register_menuid("Show_Hook_Type"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_Hook_Type");
	register_menucmd(register_menuid("Show_Hook_Glow"), (1<<0|1<<1|1<<2|1<<9), "Handle_Hook_Glow");
	register_menucmd(register_menuid("Show_Hook_Endtype"), (1<<0|1<<1|1<<2|1<<3|1<<9), "Handle_Hook_EndType");
	register_menucmd(register_menuid("Show_Fly_Speed"), (1<<0|1<<1|1<<2|1<<9), "Handle_Fly_Speed");
	register_menucmd(register_menuid("Show_ZombieMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ZombieMenu");
	register_menucmd(register_menuid("Show_InformationClient"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_InformationClient");
	register_menucmd(register_menuid("Show_Buy"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_Buy");
	register_menucmd(register_menuid("Show_TakeWanted"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TakeWanted");
	register_menucmd(register_menuid("Show_SMusicMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<9), "Handle_SMusicMenu");
	register_menucmd(register_menuid("Show_DevilMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DevilMenu");
	register_menucmd(register_menuid("Show_PrivMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_PrivMenu");
    register_menucmd(register_menuid("Show_MinistrMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MinistrMenu");
	#if defined JBE_IP_LOCK
	jbe_info_ip(IPNUMBER);  
	#endif
}

Show_MinistrMenu(id)
{
    new szMenu[512], iKeys = (1<<1|1<<5|1<<8|1<<9), iLen;
    iLen = formatex(szMenu, charsmax(szMenu), "\r\y•\d Детектив^n^n");
    
    if(devil_skin[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wСкин Детектива^n");
    iKeys |= (1<<0);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dСкин Детектива \d[\y%d дн\d]^n", devil_skin[id]);

    if(devil_dollar[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wЗарплата^n", devil_dollar[id]);
    iKeys |= (1<<1);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dЗарплата \d[\y%d дн\d]^n", devil_dollar[id]);
    
    if(devil_riot[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \wСнять зеков с розыска^n");
    iKeys |= (1<<2);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dСнять зеков с розыска \d[\y%d дн\d]^n", devil_riot[id]);
   
	if(devil_chickens[id] < 1)
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \wInfinity \d[\yДетектива\d]^n");
        iKeys |= (1<<3);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dInfinity \d[\y%d дн\d]^n", devil_chickens[id]);
    
    if(devil_damage[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \wДвойной урон^n");
    iKeys |= (1<<4);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dДвойной урон \d[\y%d дн\d]^n", devil_damage[id]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \wПоздароваться с зеками!^n\y•\yОчень просим не спамить.^n");
	
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \wНазад");
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \wВыход");
    return show_menu(id, iKeys, szMenu, -1, "Show_MinistrMenu");
}

public Handle_MinistrMenu(id, iKey) 
{
    if(!is_user_alive(id)) return PLUGIN_HANDLED;
    new szName[32];
    get_user_name(id, szName, charsmax(szName));
//    UTIL_SayText(0, "!g[JBE] !yСупер-Саймон !t%s !yвзял !gневидимость", szName);
    
    switch(iKey)
    {   
        case 0: 
        {
            if(devil_skin[id] < 1)
            {
                jbe_set_user_model(id, "detectiv");
                devil_skin[id] = 1;
                UTIL_SayText(0, "%L Детектив !g%s!y Взял скин!", id, "JBE_PREFIX", szName);
            }
        }
        case 1: 
        {
            if(devil_dollar[id] < 1)
            {
                jbe_set_user_money(id, g_iUserMoney[id] + 4000, 1);
                devil_dollar[id] = 3;
                UTIL_SayText(0, "%L Детектив !g%s!y Взял 4000 Евро!", id, "JBE_PREFIX", szName);
            }
        }
        case 2: 
        {
            if(devil_riot[id] < 1)
            {
                for(new i = 1; i <= g_iMaxPlayers; i++)
                {
                    jbe_sub_user_wanted(i);
                }
                devil_riot[id] = 5;
                UTIL_SayText(0, "%L Детектив !g%s!y Замял всем дело!", id, "JBE_PREFIX", szName);
            }
        }
		case 3:
		{ 
		    if(devil_chickens[id] < 1)
            {
            give_weapon_infinir(id);
			devil_chickens[id] = 5;
            UTIL_SayText(0, "%L Детектив !g%s!y Взял Инфинити!", id, "JBE_PREFIX", szName);
			}
        }
        case 4: 
        {
            if(devil_damage[id] < 1)
            {
                SetBit(g_iBitDoubleDamage, id);
                devil_damage[id] = 4;
                UTIL_SayText(0, "%L Детектив !g%s!y Взял 2Х Урона!", id, "JBE_PREFIX", szName);
            }
        }
		case 5:
		{
			new szName[32]; get_user_name(id, szName, charsmax(szName));
			client_cmd(0, "spk jb_engine/take_chief_new.wav");
			set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
			show_hudmessage(id, "Я %s^nДетектив вашей тюрьмы!^nБуду расследовать ваши дела...", szName);
		}
        case 8: return Show_PrivMenu(id);
        case 9: return PLUGIN_HANDLED;
    }
    return Show_MinistrMenu(id);
}

Show_DevilMenu(id)
{
    new szMenu[512], iKeys = (1<<1|1<<5|1<<8|1<<9), iLen;
    iLen = formatex(szMenu, charsmax(szMenu), "\r\y•\d Бунтарь^n^n");
    
    if(devil_skin[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wСкин Бунтаря^n");
    iKeys |= (1<<0);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dСкин Бунтаря \d[\y%d дн\d]^n", devil_skin[id]);

    if(devil_dollar[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w2000 Евро^n", devil_dollar[id]);
    iKeys |= (1<<1);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d2000 Евро \d[\y%d дн\d]^n", devil_dollar[id]);
    
    if(devil_riot[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \wЗамять всем дело^n");
    iKeys |= (1<<2);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dЗамять всем дело \d[\y%d дн\d]^n", devil_riot[id]);
    
    if(devil_chicken[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \wМуха с патронами^n");
    iKeys |= (1<<3);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dМуха с патронами \d[\y%d дн\d]^n", devil_chicken[id]);
    
    if(devil_damage[id] < 1)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \wДвойной урон^n");
    iKeys |= (1<<4);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dДвойной урон \d[\y%d дн\d]^n", devil_damage[id]);
	
    if(with_trail[id] == 0)
    {
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \wТрайл \y[\rВыкл\y]^n");
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \wТрайл \r[\yВкл\r]^n");
    
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \wНазад");
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \wВыход");
    return show_menu(id, iKeys, szMenu, -1, "Show_DevilMenu");
}

public Handle_DevilMenu(id, iKey) 
{
    if(!is_user_alive(id)) return PLUGIN_HANDLED;
    new szName[32];
    get_user_name(id, szName, charsmax(szName));
//    UTIL_SayText(0, "!g[JBE] !yСупер-Саймон !t%s !yвзял !gневидимость", szName);
    
    switch(iKey)
    {   
        case 0: 
        {
            if(devil_skin[id] < 1)
            {
                jbe_set_user_model(id, "jbe_devil_model");
                devil_skin[id] = 1;
                UTIL_SayText(0, "%L Бунтарь !g%s!y Взял скин!", id, "JBE_PREFIX", szName);
            }
        }
        case 1: 
        {
            if(devil_dollar[id] < 1)
            {
                jbe_set_user_money(id, g_iUserMoney[id] + 2000, 1);
                devil_dollar[id] = 3;
                UTIL_SayText(0, "%L Бунтарь !g%s!y Взял 2000 Евро!", id, "JBE_PREFIX", szName);
            }
        }
        case 2: 
        {
            if(devil_riot[id] < 1)
            {
                for(new i = 1; i <= g_iMaxPlayers; i++)
                {
                    jbe_sub_user_wanted(i);
                }
                devil_riot[id] = 5;
                UTIL_SayText(0, "%L Бунтарь !g%s!y Замял всем дело!", id, "JBE_PREFIX", szName);
            }
        }
        case 3: 
        {
            if(devil_chicken[id] < 1)
            {
                fm_give_item(id, "weapon_scout");
                fm_set_user_bpammo(id, CSW_SCOUT, 10);
                devil_chicken[id] = 12;
                UTIL_SayText(0, "%L Бунтарь !g%s!y Взял муху!", id, "JBE_PREFIX", szName);
            }
        }
        case 4: 
        {
            if(devil_damage[id] < 1)
            {
                SetBit(g_iBitDoubleDamage, id);
                devil_damage[id] = 4;
                UTIL_SayText(0, "%L Бунтарь !g%s!y Взял 2Х Урона!", id, "JBE_PREFIX", szName);
            }
        }
        case 5: 
        {
            if(with_trail[id] == 1)
            {
                devil_remove_trail(id);
                remove_task(INDEX_POSITION_TASK + id);
                with_trail[id] = 0;
                return Show_DevilMenu(id);
            }
            else if(with_trail[id] == 0)
            {
                set_task(TIME_POSITION_TASK, "devil_check_potision", INDEX_POSITION_TASK + id, _, _, "b");
                devil_create_trail(id);
                with_trail[id] = 1;
                return Show_DevilMenu(id);
            }
        }
        case 8: return Show_PrivilegesMenu(id);
        case 9: return PLUGIN_HANDLED;
    }
    return Show_DevilMenu(id);
}

public devil_create_trail(id) {
    if(!is_user_alive(id)) {
        return false;
    }
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(22);
    write_short(id);                                        //id
    write_short(g_pSpriteBeam);                                //sprite
    write_byte(2 * 10);                                        //life
    write_byte(5);                                            //size
    write_byte(195);                                        //r
    write_byte(50);                                            //g
    write_byte(20);                                            //b
    write_byte(255);                                        //Яркость
    message_end();
    
    return true;
}

public devil_check_potision(id) {
    id = id - INDEX_POSITION_TASK;
    
    static Float:fTime[33], Float:fOrigin[33][3];
    
    if(fTime[id] + TIME_POSITION_CHECK < get_gametime()) {
        pev(id, pev_origin, fOrigin[id]);
        fTime[id] = get_gametime();
    }
    
    new Float:fOriginTwo[3];
    pev(id, pev_origin, fOriginTwo);
    
    if(fOrigin[id][0] == fOriginTwo[0] && fOrigin[id][1] == fOriginTwo[1] && fOrigin[id][2] == fOriginTwo[2]) {
        devil_remove_trail(id);
        devil_create_trail(id);
    }
}

public devil_remove_trail(id) {
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(99);
    write_short(id);
    message_end();
}

Show_SMusicMenu(id)
{
    if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;

    new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yМузыка^n^n");
    if(IsSetBit(g_iBitUserAdmin, id))
    {
            iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_SHOP_MUSIC_ONE");
            iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_SHOP_MUSIC_TWO");
            iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_SHOP_MUSIC_THREE");
            iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_SHOP_MUSIC_FOUR");
            iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n^n", id, "JBE_SHOP_MUSIC_FIVE");
            
            iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \wОстановить все звуки для всех^n");
    }

    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_BACK");
    return show_menu(id, iKeys, szMenu, -1, "Show_SMusicMenu");
}

public Handle_SMusicMenu(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
    switch(iKey)
    {
        case 0:
        {
            if(id == g_iChiefId)
            {
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
                UTIL_SayText(0, "!g[Реклама] !yНадзиратель включил !t%L", LANG_PLAYER, "JBE_SHOP_MUSIC_ONE", szName);
                emit_sound(0, CHAN_AUTO, ss_Music[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
                return Show_SMusicMenu(id);
            }
        }
        case 1:
        {
            if(id == g_iChiefId)
            {
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
                UTIL_SayText(0, "!g[Реклама] !yНадзиратель включил !t%L", LANG_PLAYER, "JBE_SHOP_MUSIC_TWO", szName);
                emit_sound(0, CHAN_AUTO, ss_Music[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
                return Show_SMusicMenu(id);
            }
        }
        case 2:
        {
            if(id == g_iChiefId)
            {
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
                UTIL_SayText(0, "!g[Реклама] !yНадзиратель включил !t%L", LANG_PLAYER, "JBE_SHOP_MUSIC_THREE", szName);
                
                emit_sound(0, CHAN_AUTO, ss_Music[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
                return Show_SMusicMenu(id);
            }
        }
        case 3:
        {
            if(id == g_iChiefId)
            {
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
                UTIL_SayText(0, "!g[Реклама] !yНадзиратель включил !t%L", LANG_PLAYER, "JBE_SHOP_MUSIC_FOUR", szName);
                
                emit_sound(0, CHAN_AUTO, ss_Music[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
                return Show_SMusicMenu(id);
            }
        }
        case 4:
        {
            if(id == g_iChiefId)
            {
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
                UTIL_SayText(0, "!g[Реклама] !yНадзиратель включил !t%L", LANG_PLAYER, "JBE_SHOP_MUSIC_FIVE", szName);
                
                emit_sound(0, CHAN_AUTO, ss_Music[4], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
                return Show_SMusicMenu(id);
            }
        }
        case 5:
        {
                
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
                UTIL_SayText(0, "!g[Реклама] !t%s !yостановил все звуки", szName);
                
                client_cmd(0, "stopsound");
                return Show_SMusicMenu(id);
        }
        case 9: return PLUGIN_HANDLED;
    }
    return Show_SMusicMenu(id);
}

jbe_simon_music_read_file(szCfgFile[])    // музыка саймона
{
    new szBuffer[128], iLine, iLen, i;
    while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
    {
        if(!iLen || iLen > 50 || szBuffer[0] == ';') continue;
        copy(ss_Music[i], charsmax(ss_Music[]), szBuffer);
        formatex(szBuffer, charsmax(szBuffer), "sound/%s", ss_Music[i]);
        engfunc(EngFunc_PrecacheGeneric, szBuffer);
        if(++i >= sizeof(ss_Music)) break;
    }
    jbe_simon_music_read_filee(szCfgFile);
}

jbe_simon_music_read_filee(szCfgFile[])    // музыка саймона
{
    new szBuffer[128], iLine, iLen, i;
    while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
    {
        if(!iLen || iLen > 50 || szBuffer[0] == ';') continue;
        copy(ss_Music[i], charsmax(ss_Music[]), szBuffer);
        formatex(szBuffer, charsmax(szBuffer), ss_Music[i]);
        engfunc(EngFunc_PrecacheSound, szBuffer);
        if(++i >= sizeof(ss_Music)) break;
    }
}

Cmd_TakeWanted(id) return Show_TakeWanted(id, g_iMenuPosition[id] = 0);
Show_TakeWanted(id, iPos)
{
    if(iPos < 0 || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;

    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsSetBit(g_iBitUserWanted, i) && IsSetBit(g_iBitUserAlive, i)) g_iMenuPlayers[id][iPlayersNum++] = i;
    }
    new iStart = iPos * PLAYERS_PER_PAGE;
    if(iStart > iPlayersNum) iStart = iPlayersNum;
    iStart = iStart - (iStart % 8);
    g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
    new iEnd = iStart + PLAYERS_PER_PAGE;
    if(iEnd > iPlayersNum) iEnd = iPlayersNum;
    new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
    switch(iPagesNum)
    {
        case 0:
        {
            UTIL_SayText(id, "!g[JBE] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return PLUGIN_HANDLED;
        }
        default: iLen = formatex(szMenu, charsmax(szMenu), "\yОтобрать розыск \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_TakeWanted");
}

public Handle_TakeWanted(id, iKey)
{
    if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
    switch(iKey)
    {
        case 8: return Show_TakeWanted(id, ++g_iMenuPosition[id]);
        case 9: return Show_TakeWanted(id, --g_iMenuPosition[id]);
        default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            new szName[32], szTargetName[32];
            get_user_name(id, szName, charsmax(szName));
            get_user_name(iTarget, szTargetName, charsmax(szTargetName));
            if(IsSetBit(g_iBitUserWanted, iTarget))
            {
                UTIL_SayText(0, "!g[JBE] %L", LANG_PLAYER, "JBE_CHAT_ALL_TAKE_WANTED", szName, szTargetName);
                jbe_sub_user_wanted(iTarget);
            }
        }
    }
    return Show_TakeWanted(id, g_iMenuPosition[id]);
}

Show_InformationClient(id)
{
	new szMenu[512], iKeys = (1<<4|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "Информация^n^n");
	
	new szSteam[32], azName[32], g_iPing, g_iLoss, s_info[42];
	get_user_name(id, azName, charsmax(azName)); get_user_authid(id, szSteam, charsmax(szSteam)); get_user_ping(id, g_iPing, g_iLoss);
	
	formatex(s_info, charsmax(s_info), "Пинг/Потеря: %i | %i%^n", g_iPing, g_iLoss);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[•] SteamID сообщайте только администрации!!^n^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[•]\d Ник: %s^n", azName);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[•]\d STEAM ID: %s^n", szSteam);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[•]\d USER ID: %d^n", get_user_userid(id));
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[•]\d %s^n", s_info);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[•]\d Убийства: %d^n^n", get_user_frags(id));
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w5.\w Информацию в консоль^n");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\w0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_InformationClient");
}

public Handle_InformationClient(id, iKey)
{
	switch(iKey)
	{
		case 4: 
		{
			new szSteam[32], azName[32], g_iPing, g_iLoss;
			get_user_name(id, azName, charsmax(azName));
			get_user_authid(id, szSteam, charsmax(szSteam));
			get_user_ping(id, g_iPing, g_iLoss);
			
			client_print(id, print_console, "Информация:");
			client_print(id, print_console, "SteamID: %s | Nick: %s | Ping: %i | Loss: %i", szSteam, azName, g_iPing, g_iLoss);
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}


public plugin_end() 
{
	nvault_close(g_iNvault_Hook);
	nvault_close(g_iNvault_HookInfo);
	g_BlockMenu = 0;
}

Show_ChooseTeamMenu(id, iType)
{
	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys, iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_TEAM_TITLE", g_iAllCvars[TEAM_BALANCE]);
	if(g_iUserTeam[id] != 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%d]^n", id, "JBE_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \r[%d]^n", id, "JBE_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
	if(!block_info(id))
	{
		if(!g_BlockGuard && !g_BlockMenu && g_iUserTeam[id] != 2 && ((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%d]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_TEAM_RANDOM");
			iKeys |= (1<<1|1<<4);
		}
		else
		{
			if(g_BlockGuard)
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L \r[%d] [Стоит всем блокировка]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
			else
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L \r[%d]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_MENU_TEAM_RANDOM");
		}
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \d%L \r[%d] [Вам заблокировано]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
	if(g_iUserTeam[id] != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L \r[%d]^n", id, "JBE_MENU_TEAM_SPECTATOR", g_iPlayersNum[3]);
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \r[%d]^n", id, "JBE_MENU_TEAM_SPECTATOR", g_iPlayersNum[3]);
	if(iType)
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
		iKeys |= (1<<9);
	}
	return show_menu(id, iKeys, szMenu, -1, "Show_ChooseTeamMenu");
}

public Handle_ChooseTeamMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			if(g_iUserTeam[id] == 1) return Show_ChooseTeamMenu(id, 1);
			if(!jbe_set_user_team(id, 1)) return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(g_iUserTeam[id] == 2) return Show_ChooseTeamMenu(id, 1);
			if(!block_info(id) && ((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2])
			{
				if(!jbe_set_user_team(id, 2)) return PLUGIN_HANDLED;
				
			}
			else
			{
				if(g_iUserTeam[id] == 1) return Show_ChooseTeamMenu(id, 1);
				else return Show_ChooseTeamMenu(id, 0);
			}
		}
		case 4:
		{
			if(((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2])
			{
				switch(random_num(1, 2))
				{
					case 1: if(!jbe_set_user_team(id, 1)) return PLUGIN_HANDLED;
					case 2:
					{
						if(!jbe_set_user_team(id, 2)) return PLUGIN_HANDLED;
						
					}
				}
			}
			else
			{
				if(g_iUserTeam[id] == 1 || g_iUserTeam[id] == 2) return Show_ChooseTeamMenu(id, 1);
				else return Show_ChooseTeamMenu(id, 0);
			}
		}
		case 5:
		{
			if(g_iUserTeam[id] == 3) return Show_ChooseTeamMenu(id, 0);
			if(!jbe_set_user_team(id, 3)) return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_HANDLED;
}

Show_MainPnMenu(id)
{
	
	new szMenu[1024], iKeys = (1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<9), iUserAlive = IsSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MAIN_TITLE");
	if(iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_MAIN_SHOP");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_MAIN_SHOP");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n^n", id, "JBE_MENU_MAIN_PRIVILEGES_MENU");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_RAZ_OF");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n^n", id, "JBE_MENU_MAIN_TEAM");
	if(id == g_iLastPnId && iUserAlive)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_MAIN_LAST_PN");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_MAIN_LAST_PN");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y8. \wМузыка в конце раунда %s^n", IsSetBit(g_iBitUserRoundSound, id) ? "\d[\yВкл\d]" : "\d[\yВыкл\d]");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MainPnMenu");
}

public Handle_MainPnMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserAlive, id) && IsNotSetBit(g_iBitUserDuel, id)) return Show_ShopWeaponsMenu(id);
		case 1: return Show_PrivilegesMenu(id);
		case 2: return Show_FunMenuPn(id);
		case 3: return Show_ChooseTeamMenu(id, 1);
		case 4: if(id == g_iLastPnId && IsSetBit(g_iBitUserAlive, id)) return Show_LastPrisonerMenu(id);
		case 7: InvertBit(g_iBitUserRoundSound, id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MainPnMenu(id);
}

Show_Geroi(id)
{
	
	new szMenu[1024], iKeys = (1<<8|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MAIN_GER_TITLE");  
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \w%L^n^n", id, "JBE_PAHAN_INFO", SzPahanMessage);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \w%L^n^n", id, "JBE_CH_INFO", id, "JBE_HUD_CHIEF", id, g_szChiefStatus[g_iChiefStatus], g_szChiefName);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \w%L^n^n", id, "JBE_PAHAN_PRISONER", g_iAlivePlayersNum[1]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \w%L^n", id, "JBE_PAHAN_GR", g_iAlivePlayersNum[2]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Geroi");
}

public Handle_MainGeroi(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_MainPnMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_Geroi(id);
}

Show_SexMenu(id)
{
	new Flag = get_user_flags(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "\y• \yНастройки^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_MANAGE_SOUND_STOP_MP3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_MANAGE_SOUND_STOP_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_PLAYER_SETTING");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_INFORMER_POGON", g_iinformerPogon[id] ? "\d[\yВкл\d]" : "\d[\yВыкл\d]");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n^n", id, "JBE_MENU_TRAIL", g_iTrailUser[id] ? "Английский" : "Русский");
	if((Flag & ADMIN_LEVEL_G) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_PRIVILEGES_HOOK");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_HOOK");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y9. \wРазвлечения \r| \yНастройки^n^n");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SexMenu");
}

public Handle_SexMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: client_cmd(id, "mp3 stop");
		case 1: client_cmd(id, "stopsound");
		case 2: return Show_ColorMenu(id);
		case 3: 
		{
			if(!g_iinformerPogon[id]) g_iinformerPogon[id] = true;
			else g_iinformerPogon[id] = false;
		}
		case 4:
		{ 
			if(!g_iTrailUser[id]) 
			{
				client_cmd(id, "say /eng");
				g_iTrailUser[id] = true;
			}
			else 
			{
				client_cmd(id, "say /rus");
				g_iTrailUser[id] = false;
			}
		}
		case 5: if(g_iDayMode == 1 || g_iDayMode == 2) return Show_HookSetting(id);
		case 8: return Show_FunMenuPn(id);
		case 9: 
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
	}
	return Show_SexMenu(id);
}

Show_Contact(id)
{
	
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_CONTACT_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_ADMIN_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_ADMIN_OS_INFO");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \yНа сервере только эти люди главные.^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \yНе ведитесь на мошенников.^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_BUY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_INFO_CLIENT");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_MAIN_GER");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Contact");
}

public Handle_Contact(id, iKey)
{
	switch(iKey)
	{
		case 0: return Show_GLAdmin(id);
		case 1: return Show_Sborka(id);
		case 2: return Show_Buy(id);
		case 3: return Show_InformationClient(id);
		case 4: return Show_Geroi(id);
		case 8:
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
		case 9: return PLUGIN_HANDLED;
	}
	return Show_Contact(id);
}

Show_GLAdmin(id)
{
	
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_ADMIN_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_ADMIN_GL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_ADMIN_ZAM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n^n", id, "JBE_ADMIN_SMOTR");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_ADMIN_GROUPVK");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_ADMIN_SITE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_ADMIN_SKYPE");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_GLAdmin");
}

public Handle_GLAdmin(id, iKey)
{
	switch(iKey)
	{
		case 9: return PLUGIN_HANDLED;
	}
	return Show_GLAdmin(id);
}

Show_Buy(id)
{
	
	new szMenu[512], iKeys = (1<<0|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_BUY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Авторитет: \y'59руб'^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Инспектор: \y'99руб'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Блатной: \y'159руб'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Смотритель: \y'229руб'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Ревизорро: \y'399руб'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Бунтарь: \y'499руб'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Надзиратель: \y'599руб'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Все цены указаны: \y'НАВСЕГДА'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d ТЕХ-ПОДДЕРЖКА: \y'vk.com/Реклама'^n");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Buy");
}

public Handle_Buy(id, iKey)
{
	switch(iKey)
	{
		case 9: return PLUGIN_HANDLED;
	}
	return Show_Buy(id);
}

Show_Sborka(id)
{
	
	new szMenu[512], iKeys = (1<<0|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_ADMIN_OS_INFO");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Надзиратель сборки: \y'Реклама'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Тех. Поддержка: \y'Реклама'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Купить сборку: \y'Реклама'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Цена сборки: \y'Реклама'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d Сборка со всеми: \y'Исходниками'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, JBE_MODE_VERSION);
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Sborka");
}

public Handle_Sborka(id, iKey)
{
	switch(iKey)
	{
		case 9: return PLUGIN_HANDLED;
	}
	return Show_Sborka(id);
}

Show_FunMenuPn(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_RAZ_OF");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_CONTACT");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_MAIN_COSTUMES");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n",id, "JBE_PAYMONEY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n",id, "JBE_EMO_MENU");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n",id, "JBE_MENU_TRAILS");
	if(g_iUserMoney[id] >= 350) 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n",id, "JBE_RANDOM_MENU");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[У вас %d/350Евро]^n",id, "JBE_RANDOM_MENU", g_iUserMoney[id]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L^n^n",id, "JBE_RANDOM_MENUINFO");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y9. \yРазвлечения \y| \wНастройки^n^n");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_FunMenuPn");
}

public Handle_FunMenuPn(id, iKey) 
{
	switch(iKey)
	{
		case 0: return Show_Contact(id);
		case 1: if(g_iDayMode == 1 || g_iDayMode == 2) return Cmd_CostumesMenu(id);
		case 2: return Cmd_MoneyTransferMenu(id);
		case 3: client_cmd(id, "emo");
		case 4: return Show_TrailMenu(id);
		case 5:
		{
			g_iUserMoney[id] -= 350;
			new iMoney = random_num(-20000, 20000);
			g_iUserMoney[id] += iMoney;
			UTIL_SayText(id, "%L !y Вы получили !t%dЕвро", id, "JBE_PREFIX", iMoney);
		}
		case 8: return Show_SexMenu(id);
		case 9:
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
	}
	return Show_FunMenuPn(id);
}

public Show_TrailMenu(id) 
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y• \dМеню линий^n^n");
	
	if(g_iUserType[id] == -1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wВключить \r'Trail'^n");
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wСпрайт: \r'%s'^n", g_iDataSprites[g_iUserType[id]][1]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wЦвет: \r'%s'^n", g_iDataColors[g_iUserColor[id]][0]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y• \dTrail - Это линия за спиной.^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \wВыход");
	return show_menu(id, iKeys, szMenu, -1, "Show_TrailMenu");
}

public Handle_TrailMenu(id, iKey) 
{
	switch(iKey) 
	{
		case 0: 
		{
			if((sizeof(g_iDataSprites) - 1) <= g_iUserType[id]) 
			{
				g_iUserType[id] = -1;
			}
			else 
			{
				g_iUserType[id]++;
			}
		}
		case 1:
		{ 
			if((sizeof(g_iDataColors) - 1) <= g_iUserColor[id]) 
			{
				g_iUserColor[id] = 0;
			}
			else 
			{
				g_iUserColor[id]++;
			}
		}
		case 8: return Show_FunMenuPn(id);
		case 9: return PLUGIN_HANDLED;
	}
	
	remove_task(INDEX_POSITION_TASK + id);
	remove_trail(id);
	
	set_task(TIME_POSITION_TASK, "check_potision", INDEX_POSITION_TASK + id, _, _, "b");
	create_trail(id);
	
	return Show_TrailMenu(id);
}

public create_trail(id) 
{
	if(!is_user_alive(id) || g_iUserType[id] == -1) 
	{
		return false;
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(22);
	write_short(id); //id
	write_short(g_iSprites[g_iUserType[id]]);	//sprite
	write_byte(2 * 10);	//life
	write_byte(5);	//size
	write_byte(str_to_num(g_iDataColors[g_iUserColor[id]][1]));	//r
	write_byte(str_to_num(g_iDataColors[g_iUserColor[id]][2]));	//g
	write_byte(str_to_num(g_iDataColors[g_iUserColor[id]][3]));	//b
	write_byte(255);//Яркость
	message_end();
	
	return true;
}

public check_potision(id) 
{
	id = id - INDEX_POSITION_TASK;
	
	static Float:fTime[33], Float:fOrigin[33][3];
	
	if(fTime[id] + TIME_POSITION_CHECK < get_gametime()) 
	{
		pev(id, pev_origin, fOrigin[id]);
		fTime[id] = get_gametime();
	}
	
	new Float:fOriginTwo[3];
	pev(id, pev_origin, fOriginTwo);
	
	if(fOrigin[id][0] == fOriginTwo[0] && fOrigin[id][1] == fOriginTwo[1] && fOrigin[id][2] == fOriginTwo[2]) 
	{
		remove_trail(id);
		create_trail(id);
	}
}

public remove_trail(id) 
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(99);
	write_short(id);
	message_end();
}

Show_MainGrMenu(id)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName)); 
	new szMenu[1024], iKeys = (1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), iUserAlive = IsSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MAIN_TITLE2", szName);
	if(iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id) && IsNotSetBit(g_UserDog, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_MAIN_SHOP");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_MAIN_SHOP");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n^n", id, "JBE_MENU_MAIN_PRIVILEGES_MENU");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_RAZ_OF");
	iKeys |= (1<<2);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n^n", id, "JBE_MENU_MAIN_TEAM");
	
		if(iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_UserDog, id) && IsNotSetBit(g_iBitUserDuel, id))
	{
		if(id == g_iChiefId)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \d[\r>\d]^n", id, "JBE_MENU_MAIN_CHIEF");
			iKeys |= (1<<4);
		}
		else if(g_iChiefStatus != 1 && (g_iChiefIdOld != id || g_iChiefStatus != 0))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \d[\r!\d]^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MainGrMenu");
}

public Handle_MainGrMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserAlive, id) && IsNotSetBit(g_iBitUserDuel, id)) return Show_ShopGuardMenu(id);
		case 1: return Show_PrivMenu(id);
		case 2: return Show_FunMenuPn(id);
		case 3: return Show_ChooseTeamMenu(id, 1);
		case 4:
		{
			if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserAlive, id) && IsNotSetBit(g_UserDog, id) && IsNotSetBit(g_iBitUserDuel, id))
			{
				if(id == g_iChiefId) return Show_ChiefMenu_1(id);
				if(g_iChiefStatus != 1 && (g_iChiefIdOld != id || g_iChiefStatus != 0) && jbe_set_user_chief(id))
				{
					g_iChiefIdOld = id;
					return Show_ChiefMenu_1(id);
				}
			}
		}
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MainGrMenu(id);
}

Show_ShopPrisonersMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	jbe_set_user_discount(id);
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_PRISONERS_TITLE", g_iUserDiscount[id]);
	if(IsSetBit(g_iBitUserVip, id))
	{
		new iPriceFrostNade = jbe_get_price_discount(id, g_iShopCvars[FROSTNADE]);
		if(!user_has_weapon(id, CSW_SMOKEGRENADE) && IsNotSetBit(g_iBitFrostNade, id))
		{
			if(iPriceFrostNade <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_FROST_GRENADE", iPriceFrostNade);
				iKeys |= (1<<0);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_FROST_GRENADE", iPriceFrostNade);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_FROST_GRENADE", iPriceFrostNade);
		new iPriceClothingGuard = jbe_get_price_discount(id, g_iShopCvars[CLOTHING_GUARD]);
		if(IsNotSetBit(g_iBitClothingGuard, id))
		{
			if(iPriceClothingGuard <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_CLOHING_GUARD", iPriceClothingGuard);
				iKeys |= (1<<1);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_CLOHING_GUARD", iPriceClothingGuard);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_CLOHING_GUARD", iPriceClothingGuard);
		new iSkill = jbe_get_price_discount(id, g_iShopCvars[VODKA]);
		if(IsNotSetBit(g_iBitClothingGuard, id))
		{
			if(iSkill <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \r[%dЕвро]^n^n", id, "JBE_MENU_SHOP_VODKA", iSkill);
				iKeys |= (1<<2);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n^n", id, "JBE_MENU_SHOP_VODKA", iSkill);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n^n", id, "JBE_MENU_SHOP_VODKA", iSkill);
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \dУ Вас нет прав.^nЧтобы использовать этот раздел. Купите Вип^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y9. \w%L^n", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y0. \w%L^n", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopPrisonersMenu");
}

public Handle_ShopPrisonersMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: 
		{
			new iPriceFrostNade = jbe_get_price_discount(id, g_iShopCvars[FROSTNADE]);
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && IsNotSetBit(g_iBitFrostNade, id) && iPriceFrostNade <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFrostNade, 1);
				SetBit(g_iBitFrostNade, id);
				fm_give_item(id, "weapon_smokegrenade");
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceClothingGuard = jbe_get_price_discount(id, g_iShopCvars[CLOTHING_GUARD]);
			if(IsNotSetBit(g_iBitClothingGuard, id) && iPriceClothingGuard <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceClothingGuard, 1);
				SetBit(g_iBitClothingGuard, id);
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_CLOHING_GUARD_HELP");
			}
		}
		case 2:
		{
			new iSkill = jbe_get_price_discount(id, g_iShopCvars[VODKA]);
			if(IsNotSetBit(g_iBitClothingGuard, id) && iSkill <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iSkill, 1);
				g_iUserSkill[id] = g_iAllCvars[SKILL] + 70;
				UTIL_ScreenShake(id, (1<<15), (1<<14), (1<<15));
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_VODKA");
			}
		}
		case 8: return Show_ShopWeaponsMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

Show_ShopWeaponsMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_WEAPONS_TITLE");
	new iPriceSharpening = jbe_get_price_discount(id, g_iShopCvars[SHARPENING]);
	if(jbe_get_user_level(id) > 2)
	{
		if(IsNotSetBit(g_iBitSharpening, id))
		{
			if(iPriceSharpening <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHARPENING", iPriceSharpening);
				iKeys |= (1<<0);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHARPENING", iPriceSharpening);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHARPENING", iPriceSharpening);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро] \d[%L]^n", id, "JBE_MENU_SHOP_WEAPONS_SHARPENING", iPriceSharpening, id, "JBE_ID_HUD_RANK_NAME_3");
	new iPriceScrewdriver = jbe_get_price_discount(id, g_iShopCvars[SCREWDRIVER]);
	if(jbe_get_user_level(id) > 4)
	{
		if(IsNotSetBit(g_iBitScrewdriver, id))
		{
			if(iPriceScrewdriver <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SCREWDRIVER", iPriceScrewdriver);
				iKeys |= (1<<1);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SCREWDRIVER", iPriceScrewdriver);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SCREWDRIVER", iPriceScrewdriver);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро] \d[%L]^n", id, "JBE_MENU_SHOP_WEAPONS_SCREWDRIVER", iPriceScrewdriver, id, "JBE_ID_HUD_RANK_NAME_5");
	new iPriceBalisong = jbe_get_price_discount(id, g_iShopCvars[BALISONG]);
	if(jbe_get_user_level(id) > 5)
	{
		if(IsNotSetBit(g_iBitBalisong, id))
		{
			if(iPriceBalisong <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_BALISONG", iPriceBalisong);
				iKeys |= (1<<2);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_BALISONG", iPriceBalisong);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_BALISONG", iPriceBalisong);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро] \d[%L]^n", id, "JBE_MENU_SHOP_WEAPONS_BALISONG", iPriceBalisong, id, "JBE_ID_HUD_RANK_NAME_6");
	new iPriceKnif = jbe_get_price_discount(id, g_iShopCvars[KNIF]);
	if(jbe_get_user_level(id) > 7)
	{
		if(IsNotSetBit(g_iBitKnif, id))
		{
			if(iPriceKnif <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_KNIF", iPriceKnif);
				iKeys |= (1<<3);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_KNIF", iPriceKnif);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_KNIF", iPriceKnif);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро] \d[%L]^n", id, "JBE_MENU_SHOP_WEAPONS_KNIF", iPriceKnif, id, "JBE_ID_HUD_RANK_NAME_8");
	new iPriceToma = jbe_get_price_discount(id, g_iShopCvars[TOMA]);
	if(jbe_get_user_level(id) > 9)
	{
		if(IsNotSetBit(g_iBitToma, id))
		{
			if(iPriceToma <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma);
				iKeys |= (1<<4);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро] \d[%L]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma, id, "JBE_ID_HUD_RANK_NAME_10");
	new iPricePila = jbe_get_price_discount(id, g_iShopCvars[PILA]);
	if(jbe_get_user_level(id) > 11)
	{
		if(IsNotSetBit(g_iBitPila, id))
		{
			if(iPricePila <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_PILA", iPricePila);
				iKeys |= (1<<5);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_PILA", iPricePila);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_PILA", iPricePila);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро] \d[%L]^n", id, "JBE_MENU_SHOP_WEAPONS_PILA", iPricePila, id, "JBE_ID_HUD_RANK_NAME_12");
	new iPriceShok = jbe_get_price_discount(id, g_iShopCvars[SHOK]);
	if(jbe_get_user_level(id) > 15)
	{
		if(IsNotSetBit(g_iBitShok, id))
		{
			if(iPriceShok <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHOK", iPriceShok);
				iKeys |= (1<<6);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHOK", iPriceShok);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHOK", iPriceShok);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро] \d[%L]^n^n", id, "JBE_MENU_SHOP_WEAPONS_SHOK", iPriceShok, id, "JBE_ID_HUD_RANK_NAME_16");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y9. \w%L^n", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y0. \w%L^n", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopWeaponsMenu");
}

public Handle_ShopWeaponsMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceSharpening = jbe_get_price_discount(id, g_iShopCvars[SHARPENING]);
			if(IsNotSetBit(g_iBitSharpening, id) && iPriceSharpening <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceSharpening, 1);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitToma, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitShok, id);
				SetBit(g_iBitSharpening, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceScrewdriver = jbe_get_price_discount(id, g_iShopCvars[SCREWDRIVER]);
			if(IsNotSetBit(g_iBitScrewdriver, id) && iPriceScrewdriver <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceScrewdriver, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitToma, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitShok, id);
				SetBit(g_iBitScrewdriver, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceBalisong = jbe_get_price_discount(id, g_iShopCvars[BALISONG]);
			if(IsNotSetBit(g_iBitBalisong, id) && iPriceBalisong <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceBalisong, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitToma, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitShok, id);
				SetBit(g_iBitBalisong, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceKnif = jbe_get_price_discount(id, g_iShopCvars[KNIF]);
			if(IsNotSetBit(g_iBitKnif, id) && iPriceKnif <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceKnif, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitToma, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitShok, id);
				SetBit(g_iBitKnif, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 4:
				{
			new iPriceKnif = jbe_get_price_discount(id, g_iShopCvars[KNIF]);
			if(IsNotSetBit(g_iBitKnif, id) && iPriceKnif <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceKnif, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitShok, id);
				SetBit(g_iBitToma, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 5:
				{
			new iPricePila = jbe_get_price_discount(id, g_iShopCvars[PILA]);
			if(IsNotSetBit(g_iBitPila, id) && iPricePila <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPricePila, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitToma, id);
				ClearBit(g_iBitShok, id);
				SetBit(g_iBitPila, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 6: 		
		{
			new iPriceShok = jbe_get_price_discount(id, g_iShopCvars[SHOK]);
			if(IsNotSetBit(g_iBitShok, id) && iPriceShok <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceShok, 1);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitToma, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitSharpening, id);
				SetBit(g_iBitShok, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Show_ShopItemsMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ShopWeaponsMenu(id);
}

Show_ShopWeaponsMenuGu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_WEAPONS_TITLE");
	new iPriceShok = jbe_get_price_discount(id, g_iShopCvars[SHOK]);
	if(IsNotSetBit(g_iBitShok, id))
	{
		if(iPriceShok <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHOK", iPriceShok);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHOK", iPriceShok);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_SHOK", iPriceShok);
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_BACK");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopWeaponsMenuGu");
}

public Handle_ShopWeaponsMenuGu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceShok = jbe_get_price_discount(id, g_iShopCvars[SHOK]);
			if(IsNotSetBit(g_iBitShok, id) && iPriceShok <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceShok, 1);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitToma, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitSharpening, id);
				SetBit(g_iBitShok, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 9: return Show_ShopGuardMenu(id);
	}
	return Show_ShopWeaponsMenuGu(id);
}

Show_ShopItemsMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_ITEMS_TITLE");
	new iPriceLatchkey = jbe_get_price_discount(id, g_iShopCvars[LATCHKEY]);
	if(IsNotSetBit(g_iBitLatchkey, id))
	{
		if(iPriceLatchkey <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_LATCHKEY", iPriceLatchkey);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_LATCHKEY", iPriceLatchkey);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_LATCHKEY", iPriceLatchkey);
	new iPriceFlashbang = jbe_get_price_discount(id, g_iShopCvars[FLASHBANG]);
	if(!user_has_weapon(id, CSW_FLASHBANG))
	{
		if(iPriceFlashbang <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
	new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN]);
	if(IsNotSetBit(g_iBitKokain, id))
	{
		if(iPriceKokain <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
	new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR]);
	if(IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 200)
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
	new iPriceInvisibleHat = jbe_get_price_discount(id, g_iShopCvars[INVISIBLE_HAT]);
	if(IsNotSetBit(g_iBitInvisibleHat, id))
	{
		if(iPriceInvisibleHat <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_INVISIBLE_HAT", iPriceInvisibleHat);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_INVISIBLE_HAT", iPriceInvisibleHat);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_INVISIBLE_HAT", iPriceInvisibleHat);
	new iPriceArmor = jbe_get_price_discount(id, g_iShopCvars[ARMOR]);
	if(get_user_armor(id) == 0)
	{
		if(iPriceArmor <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
	new iPriceHeGrenade = jbe_get_price_discount(id, g_iShopCvars[HEGRENADE]);
	if(!user_has_weapon(id, CSW_HEGRENADE))
	{
		if(iPriceHeGrenade <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L \r[%dЕвро]^n^n", id, "JBE_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n^n", id, "JBE_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n^n", id, "JBE_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y9. \w%L^n", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y0. \w%L^n", id, "JBE_MENU_BACK");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopItemsMenu");
}

public Handle_ShopItemsMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceLatchkey = jbe_get_price_discount(id, g_iShopCvars[LATCHKEY]);
			if(IsNotSetBit(g_iBitLatchkey, id) && iPriceLatchkey <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceLatchkey, 1);
				SetBit(g_iBitLatchkey, id);
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_MENU_ID_LATCHKEY_USE");
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceFlashbang = jbe_get_price_discount(id, g_iShopCvars[FLASHBANG]);
			if(!user_has_weapon(id, CSW_FLASHBANG) && iPriceFlashbang <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFlashbang, 1);
				fm_give_item(id, "weapon_flashbang");
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN]);
			if(IsNotSetBit(g_iBitKokain, id) && iPriceKokain <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceKokain, 1);
				SetBit(g_iBitKokain, id);
				jbe_set_syringe_model(id);
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_MENU_ID_KOKAIN");
				set_task(2.8, "jbe_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR]);
			if(IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 200 && iPriceStimulator <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceStimulator, 1);
				jbe_set_syringe_model(id);
				set_task(1.3, "jbe_set_syringe_health", id+TASK_REMOVE_SYRINGE);
				set_task(2.8, "jbe_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
			new iPriceInvisibleHat = jbe_get_price_discount(id, g_iShopCvars[INVISIBLE_HAT]);
			if(IsNotSetBit(g_iBitInvisibleHat, id) && iPriceInvisibleHat <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceInvisibleHat, 1);
				SetBit(g_iBitInvisibleHat, id);
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				set_task(10.0, "jbe_remove_invisible_hat", id+TASK_INVISIBLE_HAT);
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_MENU_ID_INVISIBLE_HAT_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			new iPriceArmor = jbe_get_price_discount(id, g_iShopCvars[ARMOR]);
			if(get_user_armor(id) == 0 && iPriceArmor <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceArmor, 1);
				fm_give_item(id, "item_kevlar");
				return PLUGIN_HANDLED;
			}
		}
		case 6:
		{
			new iPriceHeGrenade = jbe_get_price_discount(id, g_iShopCvars[HEGRENADE]);
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && iPriceHeGrenade <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceHeGrenade, 1);
				fm_give_item(id, "weapon_hegrenade");
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Show_ShopSkillsMenu(id);
		case 9: return Show_ShopWeaponsMenu(id);
	}
	return Show_ShopItemsMenu(id);
}

Show_ShopSkillsMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_SKILLS_TITLE");
	new iPriceHingJump = jbe_get_price_discount(id, g_iShopCvars[HING_JUMP]);
	if(IsNotSetBit(g_iBitHingJump, id))
	{
		if(iPriceHingJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
	new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN]);
	if(IsNotSetBit(g_iBitFastRun, id))
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
	new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP]);
	if(IsNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
	new iPriceRandomGlow = jbe_get_price_discount(id, g_iShopCvars[RANDOM_GLOW]);
	if(IsNotSetBit(g_iBitRandomGlow, id))
	{
		if(iPriceRandomGlow <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
	new iPriceAutoBhop = jbe_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
	if(IsNotSetBit(g_iBitAutoBhop, id))
	{
		if(iPriceAutoBhop <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
	new iPriceDoubleDamage = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_DAMAGE]);
	if(IsNotSetBit(g_iBitDoubleDamage, id))
	{
		if(iPriceDoubleDamage <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
	new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY]);
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L \r[%dЕвро]^n^n", id, "JBE_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n^n", id, "JBE_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n^n", id, "JBE_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y9. \w%L^n", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y0. \w%L^n", id, "JBE_MENU_BACK");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopSkillsMenu");
}

public Handle_ShopSkillsMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceHingJump = jbe_get_price_discount(id, g_iShopCvars[HING_JUMP]);
			if(iPriceHingJump <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceHingJump, 1);
				SetBit(g_iBitHingJump, id);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN]);
			if(iPriceFastRun <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFastRun, 1);
				SetBit(g_iBitFastRun, id);
				ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP]);
			if(iPriceDoubleJump <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceDoubleJump, 1);
				SetBit(g_iBitDoubleJump, id);
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceRandomGlow = jbe_get_price_discount(id, g_iShopCvars[RANDOM_GLOW]);
			if(iPriceRandomGlow <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceRandomGlow, 1);
				SetBit(g_iBitRandomGlow, id);
				jbe_set_user_rendering(id, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), kRenderNormal, 0);
				jbe_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
			new iPriceAutoBhop = jbe_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
			if(iPriceAutoBhop <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceAutoBhop, 1);
				SetBit(g_iBitAutoBhop, id);
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			new iPriceDoubleDamage = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_DAMAGE]);
			if(iPriceDoubleDamage <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceDoubleDamage, 1);
				SetBit(g_iBitDoubleDamage, id);
				return PLUGIN_HANDLED;
			}
		}
		case 6:
		{
			new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY]);
			if(iPriceLowGravity <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceLowGravity, 1);
				set_pev(id, pev_gravity, 0.2);
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Show_ShopOtherMenu(id);
		case 9: return Show_ShopItemsMenu(id);
	}
	return Show_ShopSkillsMenu(id);
}

Show_ShopOtherMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_OTHER_TITLE");
	new iPriceCloseCase = jbe_get_price_discount(id, g_iShopCvars[CLOSE_CASE]);
	if(IsSetBit(g_iBitUserWanted, id))
	{
		if(iPriceCloseCase <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
	new iPriceFreeDay = jbe_get_price_discount(id, g_iShopCvars[FREE_DAY_SHOP]);
	if(g_iDayMode == 1 && IsNotSetBit(g_iBitUserFree, id) && IsNotSetBit(g_iBitUserWanted, id))
	{
		if(iPriceFreeDay <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
	new iPriceResolutionVoice = jbe_get_price_discount(id, g_iShopCvars[RESOLUTION_VOICE]);
	if(IsNotSetBit(g_iBitUserVoice, id))
	{
		if(iPriceResolutionVoice <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_RESOLUTION_VOICE", iPriceResolutionVoice);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_RESOLUTION_VOICE", iPriceResolutionVoice);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_RESOLUTION_VOICE", iPriceResolutionVoice);
	new iPriceTransferGuard = jbe_get_price_discount(id, g_iShopCvars[TRANSFER_GUARD]);
	if(iPriceTransferGuard <= g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_TRANSFER_GUARD", iPriceTransferGuard);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_TRANSFER_GUARD", iPriceTransferGuard);
	new iPriceLotteryTicket = jbe_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET]);
	if(IsNotSetBit(g_iBitLotteryTicket, id))
	{
		if(iPriceLotteryTicket <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_LOTTERY_TICKET", iPriceLotteryTicket);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_LOTTERY_TICKET", iPriceLotteryTicket);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_LOTTERY_TICKET", iPriceLotteryTicket);
	new iPricePrankPrisoner = jbe_get_price_discount(id, g_iShopCvars[PRANK_PRISONER]);
	if(g_iAlivePlayersNum[1] >= 2)
	{
		if(iPricePrankPrisoner <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_PRANK_PRISONER", iPricePrankPrisoner);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_PRANK_PRISONER", iPricePrankPrisoner);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_OTHER_PRANK_PRISONER", iPricePrankPrisoner);
	new iDog = jbe_get_price_discount(id, g_iShopCvars[DOG_DOLLARS]);
	if(g_iAlivePlayersNum[1] >= 3)
	{
		if(!g_iDog)
		{
			if(iDog <= g_iUserMoney[id])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L \r[%dЕвро]^n^n", id, "JBE_MENU_SHOP_DOG", iDog);
				iKeys |= (1<<6);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n^n", id, "JBE_MENU_SHOP_DOG", iDog);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L [%dЕвро] \r[Пёс уже есть]^n^n", id, "JBE_MENU_SHOP_DOG", iDog);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L [%dЕвро] \r[Мало игроков]^n^n", id, "JBE_MENU_SHOP_DOG", iDog);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y9. \w%L^n", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y0. \w%L^n", id, "JBE_MENU_BACK");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopOtherMenu");
}

public Handle_ShopOtherMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceCloseCase = jbe_get_price_discount(id, g_iShopCvars[CLOSE_CASE]);
			if(IsSetBit(g_iBitUserWanted, id) && iPriceCloseCase <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceCloseCase, 1);
				jbe_sub_user_wanted(id);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceFreeDay = jbe_get_price_discount(id, g_iShopCvars[FREE_DAY_SHOP]);
			if(g_iDayMode == 1 && IsNotSetBit(g_iBitUserFree, id) && IsNotSetBit(g_iBitUserWanted, id) && iPriceFreeDay <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFreeDay, 1);
				jbe_add_user_free(id);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceResolutionVoice = jbe_get_price_discount(id, g_iShopCvars[RESOLUTION_VOICE]);
			if(IsNotSetBit(g_iBitUserVoice, id) && iPriceResolutionVoice <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceResolutionVoice, 1);
				SetBit(g_iBitUserVoice, id);
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceTransferGuard = jbe_get_price_discount(id, g_iShopCvars[TRANSFER_GUARD]);
			if(iPriceTransferGuard <= g_iUserMoney[id])
			{
				if(jbe_set_user_team(id, 2)) jbe_set_user_money(id, g_iUserMoney[id] - iPriceTransferGuard, 1);
				return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
			new iPriceLotteryTicket = jbe_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET]);
			if(IsNotSetBit(g_iBitLotteryTicket, id) && iPriceLotteryTicket <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceLotteryTicket, 1);
				SetBit(g_iBitLotteryTicket, id);
				new iPrize;
				switch(random_num(0, 7))
				{
					case 0: iPrize = 100;
					case 2: iPrize = 300;
					case 4: iPrize = 200;
					case 5: iPrize = 50;
				}
				if(iPrize)
				{
					UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_LOTTERY_WIN", iPrize);
					jbe_set_user_money(id, g_iUserMoney[id] + iPrize, 1);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_LOTTERY_LOSS");
				return PLUGIN_HANDLED;
			}
		}
		case 5: if(g_iAlivePlayersNum[1] >= 2) return Cmd_PrankPrisonerMenu(id);
		case 6: 
		{
			new iDog = jbe_get_price_discount(id, g_iShopCvars[DOG_DOLLARS]);
			if(iDog <= g_iUserMoney[id])
			{
				new szName[32];
				get_user_name(id, szName, charsmax(szName));
				jbe_set_user_money(id, g_iUserMoney[id] - iDog, 1);
				jbe_set_user_team(id, 2);
				SetBit(g_UserDog, id);
				g_iDog = true;
				UTIL_SayText(0, "%L !yИгрок !g%s !yстал сторожевой !tсобакой!y!", id, "JBE_PREFIX", szName);
				return PLUGIN_HANDLED;
			}
			
		}
		case 8: return Show_ShopPrisonersMenu(id);
		case 9: return Show_ShopSkillsMenu(id);
	}
	return Show_ShopOtherMenu(id);
}


Cmd_PrankPrisonerMenu(id) return Show_PrankPrisonerMenu(id, g_iMenuPosition[id] = 0);
Show_PrankPrisonerMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserWanted, i) || i == id) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ShopOtherMenu(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_PRANK_PRISONER_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrankPrisonerMenu");
}

public Handle_PrankPrisonerMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_PrankPrisonerMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_PrankPrisonerMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new iPricePrankPrisoner = jbe_get_price_discount(id, g_iShopCvars[PRANK_PRISONER]);
			if(iPricePrankPrisoner <= g_iUserMoney[id])
			{
				if(g_iUserTeam[iTarget] == 1 || IsSetBit(g_iBitUserAlive, iTarget) || IsNotSetBit(g_iBitUserWanted, iTarget))
				{
					jbe_set_user_money(id, g_iUserMoney[id] - iPricePrankPrisoner, 1);
					if(!g_szWantedNames[0])
					{
						emit_sound(0, CHAN_AUTO, "jb_engine/prison_riot.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
						emit_sound(0, CHAN_AUTO, "jb_engine/prison_riot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					}
					jbe_add_user_wanted(iTarget);
				}
				else return Show_PrankPrisonerMenu(id, g_iMenuPosition[id]);
			}
			else return Show_ShopOtherMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

Show_ShopGuardMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	jbe_set_user_discount(id);
	new szMenu[1024], iKeys = (1<<7|1<<8|1<<9);
	new iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n", id, "JBE_MENU_SHOP_GUARD_TITLE", g_iUserDiscount[id]);
	new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR_GR]);
	if(get_user_health(id) < 200)
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	new iPriceRandomGlow = jbe_get_price_discount(id, g_iShopCvars[RANDOM_GLOW_GR]);
	if(IsNotSetBit(g_iBitRandomGlow, id))
	{
		if(iPriceRandomGlow <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
	new iPriceLotteryTicket = jbe_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET_GR]);
	if(IsNotSetBit(g_iBitLotteryTicket, id))
	{
		if(iPriceLotteryTicket <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_LOTTERY_TICKET", iPriceLotteryTicket);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_LOTTERY_TICKET", iPriceLotteryTicket);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_LOTTERY_TICKET", iPriceLotteryTicket);
	new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN_GR]);
	if(IsNotSetBit(g_iBitKokain, id))
	{
		if(iPriceKokain <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP_GR]);
	if(IsNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN_GR]);
	if(IsNotSetBit(g_iBitFastRun, id))
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY_GR]);
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L \r[%dЕвро]^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	if(jbe_is_user_chief(id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y8. \wМагазин начальника");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopGuardMenu");
}

public Handle_ShopGuardMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR_GR]);
			if(get_user_health(id) < 200 && iPriceStimulator <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceStimulator, 1);
				jbe_set_syringe_model(id);
				set_task(1.3, "jbe_set_syringe_health", id+TASK_REMOVE_SYRINGE);
				set_task(2.8, "jbe_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceRandomGlow = jbe_get_price_discount(id, g_iShopCvars[RANDOM_GLOW_GR]);
			if(iPriceRandomGlow <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceRandomGlow, 1);
				SetBit(g_iBitRandomGlow, id);
				jbe_set_user_rendering(id, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), kRenderNormal, 0);
				jbe_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceLotteryTicket = jbe_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET_GR]);
			if(IsNotSetBit(g_iBitLotteryTicket, id) && iPriceLotteryTicket <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceLotteryTicket, 1);
				SetBit(g_iBitLotteryTicket, id);
				new iPrize;
				switch(random_num(0, 7))
				{
					case 0: iPrize = 100;
					case 2: iPrize = 300;
					case 4: iPrize = 200;
					case 5: iPrize = 50;
				}
				if(iPrize)
				{
					UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_LOTTERY_WIN", iPrize);
					jbe_set_user_money(id, g_iUserMoney[id] + iPrize, 1);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_LOTTERY_LOSS");
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN_GR]);
			if(IsNotSetBit(g_iBitKokain, id) && iPriceKokain <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceKokain, 1);
				SetBit(g_iBitKokain, id);
				jbe_set_syringe_model(id);
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_MENU_ID_KOKAIN");
				set_task(2.8, "jbe_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
			new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP_GR]);
			if(iPriceDoubleJump <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceDoubleJump, 1);
				SetBit(g_iBitDoubleJump, id);
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN_GR]);
			if(iPriceFastRun <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFastRun, 1);
				SetBit(g_iBitFastRun, id);
				ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
				return PLUGIN_HANDLED;
			}
		}
		case 6:
		{
			new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY_GR]);
			if(iPriceLowGravity <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceLowGravity, 1);
				set_pev(id, pev_gravity, 0.2);
				return PLUGIN_HANDLED;
			}
		}
		case 7: if(jbe_is_user_chief(id)) return Show_ShopChiefMenu(id); else return Show_ShopGuardMenu(id);
		case 8: return Show_MainGrMenu(id);
	}
	return PLUGIN_HANDLED;
}

Show_ShopChiefMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	jbe_set_user_discount(id);
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n", id, "JBE_MENU_SHOP_CHIEF_TITLE", g_iUserDiscount[id]);
	
	new iPriceAutoBhop = jbe_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
	if(iPriceAutoBhop <= g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_AUTOBHOP", iPriceAutoBhop);
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_AUTOBHOP", iPriceAutoBhop);
	
	new iPriceInvisible = jbe_get_price_discount(id, g_iShopCvars[INVISIBLE]);
	if(iPriceInvisible <= g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_INVISIBLE", iPriceInvisible);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_INVISIBLE", iPriceInvisible);
	
	new iPriceRespawn = jbe_get_price_discount(id, g_iShopCvars[RESPAWN]);
	if(g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[RESPAWN_PLAYER_NUM])
	{
		if(iPriceRespawn <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_RESPAWN", iPriceRespawn);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_RESPAWN", iPriceRespawn);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_RESPAWN", iPriceRespawn);
	
	new iPriceGod = jbe_get_price_discount(id, g_iShopCvars[GOD]);
	if(iPriceGod <= g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_GOD", iPriceGod);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \d[%dЕвро]^n", id, "JBE_MENU_SHOP_CHIEF_GOD", iPriceGod);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopChiefMenu");
}

public Handle_ShopChiefMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceAutoBhop = jbe_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
			if(iPriceAutoBhop <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceAutoBhop, 1);
				SetBit(g_iBitAutoBhop, id);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceInvisible = jbe_get_price_discount(id, g_iShopCvars[INVISIBLE]);
			if(iPriceInvisible <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceInvisible, 1);
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			if(g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[RESPAWN_PLAYER_NUM])
			{
				new iPriceRespawn = jbe_get_price_discount(id, g_iShopCvars[RESPAWN]);
				if(iPriceRespawn <= g_iUserMoney[id])
				{
					jbe_set_user_money(id, g_iUserMoney[id] - iPriceRespawn, 1);
					ExecuteHamB(Ham_CS_RoundRespawn, id);
					return PLUGIN_HANDLED;
				}
			}
		}
		case 3:
		{
			new iPriceGod = jbe_get_price_discount(id, g_iShopCvars[GOD]);
			if(iPriceGod <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceGod, 1);
				set_user_godmode(id, 1);
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Show_ShopGuardMenu(id);
	}
	return PLUGIN_HANDLED;
}

Cmd_MoneyTransferMenu(id) return Show_MoneyTransferMenu(id, g_iMenuPosition[id] = 0);
Show_MoneyTransferMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitUserConnected, i) || i == id) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n\d%L^n", id, "JBE_MENU_MONEY_TRANSFER_TITLE", iPos + 1, iPagesNum, id, "JBE_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s \d[%dЕвро]^n", ++b, szName, g_iUserMoney[i]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MoneyTransferMenu");
}

public Handle_MoneyTransferMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_MoneyTransferMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_MoneyTransferMenu(id, --g_iMenuPosition[id]);
		default:
		{
			g_iMenuTarget[id] = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			return Show_MoneyAmountMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

Show_MoneyAmountMenu(id)
{
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n\d%L^n", id, "JBE_MENU_MONEY_AMOUNT_TITLE", id, "JBE_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
	if(g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%dЕвро^n", floatround(g_iUserMoney[id] * 0.10, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%dЕвро^n", floatround(g_iUserMoney[id] * 0.25, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%dЕвро^n", floatround(g_iUserMoney[id] * 0.50, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%dЕвро^n", floatround(g_iUserMoney[id] * 0.75, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%dЕвро^n^n^n", g_iUserMoney[id]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y8. \w%L^n", id, "JBE_MENU_MONEY_SPECIFY_AMOUNT");
		iKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<7);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d0Евро^n\y•\d \d0Евро^n\y•\d \d0Евро^n\y•\d \d0Евро^n\y•\d \d0Евро^n^n^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_MONEY_SPECIFY_AMOUNT");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MoneyAmountMenu");
}

public Handle_MoneyAmountMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: ClCmd_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.10, floatround_ceil));
		case 1: ClCmd_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.25, floatround_ceil));
		case 2: ClCmd_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.50, floatround_ceil));
		case 3: ClCmd_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.75, floatround_ceil));
		case 4: ClCmd_MoneyTransfer(id, g_iMenuTarget[id], g_iUserMoney[id]);
		case 7: client_cmd(id, "messagemode ^"money_transfer %d^"", g_iMenuTarget[id]);
		case 8: return Show_MoneyTransferMenu(id, g_iMenuPosition[id]);
	}
	return PLUGIN_HANDLED;
}

Cmd_RespawnMenu(id) return Show_RespawnMenu(id, g_iMenuPosition[id] = 0);
Show_RespawnMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(!is_user_alive(i) && jbe_get_user_team(i) == 1 || !is_user_alive(i) && jbe_get_user_team(i) == 2) //continue;
		{
			g_iMenuPlayers[id][iPlayersNum++] = i;
		}
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_KingMenu(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_RESPAWN_MENU", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_RespawnMenu");
}

public Handle_RespawnMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_RespawnMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_RespawnMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new Terget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			ExecuteHam(Ham_CS_RoundRespawn, Terget);
			g_RoundResspawn[id]--;
		}
	}
	return PLUGIN_HANDLED;
}

Show_ChiefMenu_1(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[2048], iKeys = (1<<0|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_CHIEF_TITLE");
	if(g_bDoorStatus) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_CHIEF_DOOR_CLOSE");
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_CHIEF_DOOR_OPEN");
	if(g_iDayMode == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_CHIEF_COUNTDOWN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_CHIEF_PRISONER_SEARCH");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_CONTROL");
		iKeys |= (1<<1|1<<2|1<<3);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_CHIEF_COUNTDOWN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_CHIEF_PRISONER_SEARCH");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_CONTROL_END");
	}
	if(g_iDayMode == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_START");
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_END");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_CHIEF_PUNISH_GUARD");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L^n", id, "JBE_MENU_CHIEF_TRANSFER_CHIEF");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y8. \w%L^n", id, "JBE_MENU_CHIEF_TREAT_PRISONER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ChiefMenu_1");
}

public Handle_ChiefMenu_1(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(g_bDoorStatus) jbe_close_doors();
			else jbe_open_doors();
		}
		case 1: if(g_iDayMode == 1) return Show_CountDownMenu(id);
		case 2:
		{
			if(g_iDayMode == 1) 
			{
				new iTarget, iBody;
				get_user_aiming(id, iTarget, iBody, 60);
				if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserAlive, iTarget))
				{
					if(g_iUserTeam[iTarget] != 1) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_NOT_TEAM_SEARCH");
					else
					{
						new iBitWeapons = pev(iTarget, pev_weapons);
						if(iBitWeapons &= ~(1<<CSW_HEGRENADE|1<<CSW_SMOKEGRENADE|1<<CSW_FLASHBANG|1<<CSW_KNIFE|1<<31)) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_FOUND_WEAPON");
						else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_NOT_FOUND_WEAPON");
					}
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_HELP_FOUND_WEAPON");
			}
		}
		case 3: if(g_iDayMode == 1) return Cmd_FreeDayControlMenu(id);
		case 4:
		{
			if(g_iDayMode == 1) jbe_free_day_start();
			else jbe_free_day_ended();
		}
		case 5: return Cmd_PunishGuardMenu(id);
		case 6: return Cmd_TransferChiefMenu(id);
		case 7: return Cmd_TreatPrisonerMenu(id);
		case 8: return Show_ChiefMenu_2(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ChiefMenu_1(id);
}

Show_CountDownMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_COUNT_DOWN_TITLE");
	new Flag = get_user_flags(id);
	if(task_exists(TASK_COUNT_DOWN_TIMER))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_MENU_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_MENU_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n^n", id, "JBE_MENU_COUNT_DOWN_3");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_MENU_GONG");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_MENU_DJ_MENU");
		if(IsSetBit(g_iBitUserAdmin, id))
	    {
		   iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_PRIV_MUSIC");
		   iKeys |= (1<<5);
	    }
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIV_MUSIC");
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1.\w %L^n", id, "JBE_MENU_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2.\w %L^n", id, "JBE_MENU_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3.\w %L^n^n", id, "JBE_MENU_COUNT_DOWN_3");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4.\w %L^n", id, "JBE_MENU_GONG");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5.\w %L^n", id, "JBE_MENU_DJ_MENU");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6.\w %L^n", id, "JBE_MENU_PRIV_MUSIC");
		iKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_CountDownMenu");
}

public Handle_CountDownMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: g_iCountDown = 11;
		case 1: g_iCountDown = 6;
		case 2: g_iCountDown = 4;
		case 3: for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)  emit_sound(iPlayer, CHAN_AUTO, "jb_engine/boxing/gong.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		case 4: return Cmd_TrackMenu(id);
		case 5: if(get_user_flags(id) & ADMIN_VOTE) return Show_SMusicMenu(id);
		case 8: if(IsSetBit(g_iBitUserAdmin, id)) return Show_ChiefMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	set_task(1.0, "jbe_count_down_timer", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
	return Show_ChiefMenu_1(id);
}

public jbe_count_down_timer()
{
	if(--g_iCountDown) client_print(0, print_center, "%L", LANG_PLAYER, "JBE_MENU_COUNT_DOWN_TIME", g_iCountDown);
	else client_print(0, print_center, "%L", LANG_PLAYER, "JBE_MENU_COUNT_DOWN_TIME_END");
	UTIL_SendAudio(0, _, "jb_engine/countdowner/%d.wav", g_iCountDown);
}

public Cmd_TrackMenu(id) return Show_TrackMenu(id, g_iMenuPosition[id] = 0);
Show_TrackMenu(id, iPos)
{
	if(iPos < 0 || (g_iRoundSoundSize - 1) == 0) return PLUGIN_HANDLED;
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iRoundSoundSize) iStart = g_iRoundSoundSize - 1;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iRoundSoundSize) iEnd = (g_iRoundSoundSize - 1) + (iPos ? 0 : 1);
	new szMenu[512], iLen, iPagesNum = ((g_iRoundSoundSize - 1) / PLAYERS_PER_PAGE + (((g_iRoundSoundSize - 1) % PLAYERS_PER_PAGE) ? 1 : 0));
	iLen = formatex( szMenu, charsmax( szMenu ), "\y• Музыкальное меню \y[%d/%d]^n^n", iPos + 1, iPagesNum);
	new iKeys = (1<<9), b;
	new aDataRoundSound[DATA_ROUND_SOUND];
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aDataRoundSound, a, aDataRoundSound);
		iKeys |= (1<<b);
		iLen += formatex( szMenu[ iLen ], charsmax( szMenu ) - iLen, "\w%d|\w %s^n", ++b, aDataRoundSound[TRACK_NAME]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n" );
	if(iEnd < (g_iRoundSoundSize - 1))
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9.\w %L^n\y0.\w %L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT" );
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT" );
	return show_menu(id, iKeys, szMenu, -1, "Show_TrackMenu" );
}
public Handle_TrackMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_TrackMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_TrackMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTrack = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
			new aDataRoundSound[DATA_ROUND_SOUND];
			ArrayGetArray(g_aDataRoundSound, iTrack, aDataRoundSound);
			client_cmd(0, "mp3 play sound/jb_engine/round_sound/%s.mp3", aDataRoundSound[FILE_NAME]);
			UTIL_SayText(id, "!t[!gРеклама!t] !yНадзиратель включил: !t%s", aDataRoundSound[TRACK_NAME]);
		}
	}
	return PLUGIN_HANDLED;
}

Cmd_FreeDayControlMenu(id) return Show_FreeDayControlMenu(id, g_iMenuPosition[id] = 0);
Show_FreeDayControlMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || IsSetBit(g_iBitUserFreeNextRound, i) || IsSetBit(g_iBitUserWanted, i)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_FREE_DAY_CONTROL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s \r[%L]^n", ++b, szName, i, IsSetBit(g_iBitUserFree, i) ? "JBE_MENU_FREE_DAY_CONTROL_TAKE" : "JBE_MENU_FREE_DAY_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_FreeDayControlMenu");
}

public Handle_FreeDayControlMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_FreeDayControlMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_FreeDayControlMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] != 1 || IsSetBit(g_iBitUserFreeNextRound, iTarget) || IsSetBit(g_iBitUserWanted, iTarget)) return Show_FreeDayControlMenu(id, g_iMenuPosition[id]);
			new szName[32], szTargetName[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(IsSetBit(g_iBitUserFree, iTarget))
			{
				UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TAKE_FREE_DAY", szName, szTargetName);
				jbe_sub_user_free(iTarget);
			}
			else
			{
				UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_GIVE_FREE_DAY", szName, szTargetName); 
				if(IsSetBit(g_iBitUserAlive, iTarget)) jbe_add_user_free(iTarget);
				else
				{
					jbe_add_user_free_next_round(iTarget);
					UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_AUTO_FREE_DAY", szTargetName);
				}
			}
		}
	}
	return Show_FreeDayControlMenu(id, g_iMenuPosition[id]);
}

Cmd_PunishGuardMenu(id) return Show_PunishGuardMenu(id, g_iMenuPosition[id] = 0);
Show_PunishGuardMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 2 || i == g_iChiefId || IsSetBit(g_iBitUserAdmin, i)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_PUNISH_GUARD_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PunishGuardMenu");
}

public Handle_PunishGuardMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_PunishGuardMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_PunishGuardMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 2)
			{
				if(jbe_set_user_team(iTarget, 1))
				{
					new szName[32], szTargetName[32];
					get_user_name(id, szName, charsmax(szName));
					get_user_name(iTarget, szTargetName, charsmax(szTargetName));
					UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PUNISH_GUARD", szName, szTargetName);
					if(IsSetBit(g_UserDog, iTarget))
					{						
						g_iDog = false; 
						ClearBit(g_UserDog, iTarget);
					}
				}
			}
		}
	}
	return Show_PunishGuardMenu(id, g_iMenuPosition[id]);
}

Cmd_TransferChiefMenu(id) return Show_TransferChiefMenu(id, g_iMenuPosition[id] = 0);
Show_TransferChiefMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 2 || IsNotSetBit(g_iBitUserAlive, i) || i == g_iChiefId || IsSetBit(g_UserDog, i)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_TRANSFER_CHIEF_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_TransferChiefMenu");
}

public Handle_TransferChiefMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_TransferChiefMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_TransferChiefMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(jbe_set_user_chief(iTarget))
			{
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_TRANSFER_CHIEF", szName, szTargetName);
				return PLUGIN_HANDLED;
			}
		}
	}
	return Show_TransferChiefMenu(id, g_iMenuPosition[id]);
}

Cmd_TreatPrisonerMenu(id) return Show_TreatPrisonerMenu(id, g_iMenuPosition[id] = 0);
Show_TreatPrisonerMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || get_user_health(i) >= 100 || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_TREAT_PRISONER_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s \r[%d HP]^n", ++b, szName, get_user_health(i));
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_TreatPrisonerMenu");
}

public Handle_TreatPrisonerMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_TreatPrisonerMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_TreatPrisonerMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 1 && IsSetBit(g_iBitUserAlive, iTarget) && get_user_health(iTarget) < 100 && IsNotSetBit(g_iBitUserBoxing, id) && IsNotSetBit(g_iBitUserDuel, id))
			{
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TREAT_PRISONER", szName, szTargetName);
				set_pev(iTarget, pev_health, 100.0);
			}
		}
	}
	return Show_TreatPrisonerMenu(id, g_iMenuPosition[id]);
}

Show_ChiefMenu_2(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_CHIEF_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_CHIEF_VOICE_CONTROL");
	if(g_iDayMode == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_CHIEF_MINI_GAME");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_CHIEF_MINI_GAME");
	if(g_iPlayersNum[1] > 3)
	{
		if(!g_iDog)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_CHIEF_DOG_MENU");
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \r[Уже есть собака]^n", id, "JBE_MENU_CHIEF_DOG_MENU");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \r[Мало игроков]^n", id, "JBE_MENU_CHIEF_DOG_MENU");
	if(g_iDayGamesLimit >= g_iAllCvars[DAY_MODE])
	{
		if(!g_iDayModeListSize || g_iPlayersNum[1] < 2 || !g_iPlayersNum[2]) 
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \d%L^n", id, "JBE_MENU_CHIEF_PLAY_GAMES_OFF");
		}
		else 
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_CHIEF_PLAY_GAMES");
			iKeys |= (1<<3);
		}
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \d%L^n", id, "JBE_MENU_CHIEF_PLAY_GAMES_LIMIT");
	if(g_iDayMode == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_CHIEF_WANTED");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_CHIEF_WANTED");
    if(ssoglush == 5)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_CHIEF_OGL");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_CHIEF_OGL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ChiefMenu_2");
}

public Handle_ChiefMenu_2(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Cmd_VoiceControlMenu(id);
		case 1: if(g_iDayMode == 1) return Show_MiniGameMenu(id);
		case 2: if(g_iPlayersNum[1] > 3) return Show_MenuDogMain(id);
		case 3: jbe_daymode_start_game();
		case 4: if(g_iDayMode == 1) return Cmd_TakeWanted(id);
        case 5:
        {
            if(ssoglush == 5)
            {
                for(new i = 1; i < g_iMaxPlayers; i++)
                {
                if(is_user_alive(i) && jbe_get_user_team(i) == 1 && is_user_connected(i) && IsNotSetBit(g_iBitUserFree, i))
                    {
                    set_pev(i, pev_punchangle, {400.0, 999.0, 400.0});
                    UTIL_ScreenFade(i, (1<<13), (1<<13), 0, 255, 255, 255, 155);
                    }
                }
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
                UTIL_SayText(0, "!g[Реклама] !yНадзиратель !t%s !gоглушил !yвсех зеков", szName);
                client_cmd(0, "spk jb_engine/countdowner/Pax.wav");
                ssoglush = 5;    
			}	
		}
		case 8: return Show_ChiefMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ChiefMenu_2(id);
}


Show_MenuDogMain(id) return Show_MenuDog(id, g_iMenuPosition[id] = 0);
Show_MenuDog(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_2(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_CHIEF_DOG_MENU", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s \y'Нанять'^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MenuDog");
}

public Handle_MenuDog(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_MenuDog(id, ++g_iMenuPosition[id]);
		case 9: return Show_MenuDog(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new szName[32], szTargetName[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(IsNotSetBit(g_iBitUserAlive, iTarget) || g_iUserTeam[iTarget] != 1 || g_iDog)
			{				
				return Show_ChiefMenu_2(id) && UTIL_SayText(id, "%L !yИгрок !t%s !yне может стать собакой!y.", id, "JBE_PREFIX", szTargetName);
			}				
			SetBit(g_UserDog, iTarget); g_iDog = true; jbe_set_user_team(iTarget, 2);
			UTIL_SayText(0, "%L !yНадзиратель: !g%s !yнанял собаку !t%s!y.", id, "JBE_PREFIX", szName, szTargetName);	
		}
	}
	return Show_MenuDog(id, g_iMenuPosition[id]);
}

Cmd_VoiceControlMenu(id) return Show_VoiceControlMenu(id, g_iMenuPosition[id] = 0);
Show_VoiceControlMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_2(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_VOICE_CONTROL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s%s %L^n", ++b, szName, is_user_steam(i) ? " \r[\ySteam\r]" : "", id, IsSetBit(g_iBitUserVoice, i) ? "JBE_MENU_CHIEF_VOICE_CONTROL_TAKE" : "JBE_MENU_CHIEF_VOICE_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_VoiceControlMenu");
}

public Handle_VoiceControlMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_VoiceControlMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_VoiceControlMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(IsNotSetBit(g_iBitUserAlive, iTarget) || g_iUserTeam[iTarget] != 1) return Show_VoiceControlMenu(id, g_iMenuPosition[id]);
			new szName[32], szTargetName[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			
			if(is_user_steam(iTarget)) {
				if(IsSetBit(g_iBitUserSteamVoice, iTarget))
				{
					ClearBit(g_iBitUserSteamVoice, iTarget);
					UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TAKE_VOICE", szName, szTargetName);
				}
				else {
					SetBit(g_iBitUserSteamVoice, iTarget);
					UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_GIVE_VOICE", szName, szTargetName);
				}
			}
			else {
				if(IsSetBit(g_iBitUserVoice, iTarget))
				{
					ClearBit(g_iBitUserVoice, iTarget);
					UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TAKE_VOICE", szName, szTargetName);
				}
				else {
					SetBit(g_iBitUserVoice, iTarget);
					UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_GIVE_VOICE", szName, szTargetName);
				}
			}
		}
	}
	return Show_VoiceControlMenu(id, g_iMenuPosition[id]);
}

Show_MiniGameMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MINI_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_MINI_GAME_SOCCER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_MINI_GAME_BOXING");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_MINI_GAME_SPRAY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_MINI_GAME_DISTANCE_DROP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_MINI_GAME_GOLOD");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_MINI_GAME_RANDOM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), szMenu, -1, "Show_MiniGameMenu");
}

public Handle_MiniGameMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Show_SoccerMenu(id);
		case 1: return Show_BoxingMenu(id);
		case 2:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i)) continue;
				set_pdata_float(i, m_flNextDecalTime, 0.0);
			}
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_MINI_GAME_SPRAY");
		}
		case 3:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserSoccer, i) || IsSetBit(g_iBitUserBoxing, i) || IsSetBit(g_iBitUserDuel, i)) continue;
				ham_strip_weapon_name(i, "weapon_deagle");
				new iEntity = fm_give_item(i, "weapon_deagle");
				if(iEntity > 0) set_pdata_int(iEntity, m_iClip, -1, linux_diff_weapon);
			}
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_MINI_GAME_DISTANCE_DROP");
		}
		case 4:	return Show_GolodGame(id);
		case 5:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserFree, i) || IsSetBit(g_iBitUserWanted, i) || IsSetBit(g_iBitUserSoccer, i) || IsSetBit(g_iBitUserBoxing, i) || IsSetBit(g_iBitUserDuel, i)) continue;
				jbe_set_user_rendering(i, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), kRenderNormal, 0);
			
			}
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_MINI_GAME_RANDOM_SKIN");
		}
		case 8: return Show_ChiefMenu_2(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MiniGameMenu(id);
}

Show_GolodGame(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MINI_GAME_GOLOD_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1.\w %s^n", g_bGolod ? "Выключить" : "Включить");
	if(g_bGolod && id == g_iChiefId && IsNotSetBit(g_iBitUserDuel, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2.\w %L^n", id, "JBE_MENU_MINI_GAME_FRIENDLY_FIRE", id, g_iFriendlyFire ? "JBE_MENU_ENABLE" : "JBE_MENU_DISABLE");
		iKeys |= (1<<1);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3.\w %L^n", id, "JBE_MENU_MINI_GAME_GOLOD_WEAPON");
		iKeys |= (1<<2);
	}
	else 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_MENU_MINI_GAME_FRIENDLY_FIRE", id, g_iFriendlyFire ? "JBE_MENU_ENABLE" : "JBE_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d %L^n", id, "JBE_MENU_MINI_GAME_GOLOD_WEAPON");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9.\w %L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_GolodGame");
}

public Handle_GolodGame(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(g_bGolod)
			{
				g_bGolod = false;
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_MENU_MINI_GAME_GOLOD_GAME_MSG_OFF");
				set_fog(13, 13 ,13);
			} 
			else
			{
				g_bGolod = true;
				jbe_soccer_disable_all();
				jbe_boxing_disable_all();
				for(new i = 1; i <= g_iMaxPlayers; i++)
				{
					if(IsSetBit(g_UserZombie, i)) ClearBit(g_UserZombie, i); 
					if(!g_iZombieStatus[i]) g_iZombieStatus[i] = false; 
				}
				UTIL_SayText(0, "%L %L", LANG_PLAYER,"JBE_PREFIX", LANG_PLAYER, "JBE_MENU_MINI_GAME_GOLOD_GAME_MSG_ON");
				set_fog(169, 69,0);
			}
		}
		case 1:
		{
			g_iFriendlyFire = !g_iFriendlyFire;
			if(g_iFriendlyFire) 
			{
				UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", id, "JBE_GOLOD_ON");
				for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)  emit_sound(iPlayer, CHAN_AUTO, "jb_engine/boxing/gong.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
			if(!g_iFriendlyFire) UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", id, "JBE_GOLOD_OFF");
		}
		case 2: return Show_ChosMenu(id);
		case 8: return Show_ChiefMenu_2(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_GolodGame(id);
}

Show_ChosMenu(id)
{
	if(IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512]; new iLen = 0, iKey = (1<<0|1<<9);
	iLen = formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\dВыберите оружие^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1.\w Выдать \y'Deagle'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0.\w %L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKey, szMenu, -1, "Show_ChosMenu");
}

public Handle_ChosMenu(id, key)
{
	if(IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new TmpName[32]; get_user_name(id,TmpName, charsmax(TmpName));
	switch(key)
	{
		case 0:
		{
			for(new i = 1; i <= 32; i++)
			{
				if(IsSetBit(g_iBitUserAlive, i) && jbe_get_user_team(i) == 1)
				{
					fm_give_item(i,"weapon_deagle");
					fm_set_user_bpammo(i,CSW_DEAGLE,1000);
				}
			}
			UTIL_SayText(0, "%L %L", id,"JBE_PREFIX", LANG_PLAYER, "JBE_CHIEF_WEAPON_PRISONER_DEAGLE", TmpName);
		}
		case 9: return Show_GolodGame(id);
	}
	return Show_GolodGame(id);
}

Show_SoccerMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SOCCER_TITLE");
	if(g_bSoccerStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_SOCCER_DISABLE");
		if(g_iSoccerBall)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_SOCCER_SUB_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
				iKeys |= (1<<3);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_SOCCER_GAME_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_SOCCER_GAME_START");
			iKeys |= (1<<2|1<<4);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_SOCCER_ADD_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_SOCCER_GAME_END");
				iKeys |= (1<<4);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_GAME_START");
		}
		if(g_bSoccerGame)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
			iKeys |= (1<<6);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
			iKeys |= (1<<5);
		}
		iKeys |= (1<<1);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_SOCCER_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_ADD_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_GAME_END");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_TEAMS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SoccerMenu");
}

public Handle_SoccerMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(g_bSoccerStatus) jbe_soccer_disable_all();
			else 
			{
				g_bSoccerStatus = true;
				g_bGolod = false;
				for(new i = 1; i <= g_iMaxPlayers; i++)
				{
					if(IsSetBit(g_UserZombie, i)) ClearBit(g_UserZombie, i); 
					if(!g_iZombieStatus[i]) g_iZombieStatus[i] = false; 
				}
			}
		}
		case 1:
		{
			if(g_iSoccerBall) jbe_soccer_remove_ball();
			else jbe_soccer_create_ball(id);
		}
		case 2: if(g_iSoccerBall) jbe_soccer_update_ball();
		case 3:
		{
			if(g_bSoccerGame && g_iSoccerBall)
			{
				emit_sound(id, CHAN_AUTO, "jb_engine/soccer/whitle_start.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				g_bSoccerBallTouch = true;
			}
		}
		case 4:
		{
			if(g_bSoccerGame) jbe_soccer_game_end(id);
			else if(g_iSoccerBall) jbe_soccer_game_start(id);
		}
		case 5: if(!g_bSoccerGame) return Show_SoccerTeamMenu(id);
		case 6: if(g_bSoccerGame) return Show_SoccerScoreMenu(id);
		case 8: return Show_MiniGameMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SoccerMenu(id);
}

Show_SoccerTeamMenu(id)
{
	if(g_bSoccerGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SOCCER_TEAM_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_SOCCER_TEAM_DIVIDE_PRISONERS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_SOCCER_TEAM_DIVIDE_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_SOCCER_TEAM_DESCRIPTION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_SOCCER_TEAM_ADD_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L^n", id, "JBE_MENU_SOCCER_TEAM_ADD_BLUE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y8. \w%L^n", id, "JBE_MENU_SOCCER_TEAM_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<5|1<<6|1<<7|1<<8|1<<9), szMenu, -1, "Show_SoccerTeamMenu");
}

public Handle_SoccerTeamMenu(id, iKey)
{
	if(g_bSoccerGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: jbe_soccer_divide_team(1);
		case 1: jbe_soccer_divide_team(0);
		case 7:
		{
			new iTarget, iBody;
			get_user_aiming(id, iTarget, iBody, 9999);
			if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserSoccer, iTarget))
			{
				ClearBit(g_iBitUserSoccer, iTarget);
				if(iTarget == g_iSoccerBallOwner)
				{
					CREATE_KILLPLAYERATTACHMENTS(iTarget);
					set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
					set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
					g_iSoccerBallOwner = 0;
				}
				if(IsSetBit(g_iBitClothingGuard, iTarget) && IsSetBit(g_iBitClothingType, iTarget)) jbe_set_user_model(iTarget, g_szPlayerModel[GUARD]);
				else jbe_default_player_model(iTarget);
				set_pdata_int(iTarget, m_bloodColor, 247);
				new iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem);
				if(iActiveItem > 0)
				{
					ExecuteHamB(Ham_Item_Deploy, iActiveItem);
					UTIL_WeaponAnimation(iTarget, 3);
				}
			}
			else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_SoccerTeamMenu(id);
		}
		case 8: return Show_SoccerMenu(id);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget, iBody;
			get_user_aiming(id, iTarget, iBody, 9999);
			if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserAlive, iTarget) && IsNotSetBit(g_iBitUserDuel, iTarget) && (g_iUserTeam[iTarget] == 1 && IsNotSetBit(g_iBitUserFree, iTarget) && IsNotSetBit(g_iBitUserWanted, iTarget) && IsNotSetBit(g_iBitUserBoxing, iTarget) || g_iUserTeam[iTarget] == 2))
			{
				new szLangPlayer[][] = {"JBE_HUD_ID_YOU_TEAM_RED", "JBE_HUD_ID_YOU_TEAM_BLUE"};
				UTIL_SayText(iTarget, "%L %L", iTarget, "JBE_PREFIX", iTarget, szLangPlayer[iKey - 5]);
				if(IsNotSetBit(g_iBitUserSoccer, iTarget))
				{
					SetBit(g_iBitUserSoccer, iTarget);
					jbe_set_user_model(iTarget, g_szPlayerModel[FOOTBALLER]);
					if(get_user_weapon(iTarget) != CSW_KNIFE) engclient_cmd(iTarget, "weapon_knife");
					else
					{
						new iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem);
						if(iActiveItem > 0)
						{
							ExecuteHamB(Ham_Item_Deploy, iActiveItem);
							UTIL_WeaponAnimation(iTarget, 3);
						}
					}
					set_pdata_int(iTarget, m_bloodColor, -1);
					ClearBit(g_iBitClothingType, iTarget);
				}
				set_pev(iTarget, pev_skin, iKey - 5);
				g_iSoccerUserTeam[iTarget] = iKey - 5;
			}
			else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_SoccerTeamMenu(id);
		}
	}
	return Show_SoccerMenu(id);
}

Show_SoccerScoreMenu(id)
{
	if(!g_bSoccerGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<0|1<<2|1<<4|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SOCCER_SCORE_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_ADD");
	if(g_iSoccerScore[0])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_SUB");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_ADD");
	if(g_iSoccerScore[1])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_SUB");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n^n^n^n", id, "JBE_MENU_SOCCER_SCORE_RESET");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SoccerScoreMenu");
}

public Handle_SoccerScoreMenu(id, iKey)
{
	if(!g_bSoccerGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: g_iSoccerScore[0]++;
		case 1: g_iSoccerScore[0]--;
		case 2: g_iSoccerScore[1]++;
		case 3: g_iSoccerScore[1]--;
		case 4: g_iSoccerScore = {0, 0};
		case 8: return Show_SoccerMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SoccerScoreMenu(id);
}

Show_BoxingMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_BOXING_TITLE");
	if(g_bBoxingStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_BOXING_DISABLE");
		if(g_iBoxingGame == 2) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_BOXING_GAME_START");
		else
		{
			if(g_iBoxingGame == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_BOXING_GAME_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_BOXING_GAME_START");
			iKeys |= (1<<1);
		}
		if(g_iBoxingGame == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
		else
		{
			if(g_iBoxingGame == 2) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
			iKeys |= (1<<2);
		}
		if(g_iBoxingGame) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n^n^n^n^n", id, "JBE_MENU_BOXING_TEAMS");
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n^n^n^n^n", id, "JBE_MENU_BOXING_TEAMS");
			iKeys |= (1<<3);
		}
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_BOXING_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_BOXING_GAME_START");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n^n^n^n^n", id, "JBE_MENU_BOXING_TEAMS");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_BoxingMenu");
}

public Handle_BoxingMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(g_bBoxingStatus) jbe_boxing_disable_all();
			else
			{
				g_bBoxingStatus = true;
				g_iFakeMetaUpdateClientData = register_forward(FM_UpdateClientData, "FakeMeta_UpdateClientData_Post", 1);
				for(new i = 1; i <= g_iMaxPlayers; i++)
				{
					if(IsSetBit(g_UserZombie, i)) ClearBit(g_UserZombie, i); 
					if(!g_iZombieStatus[i]) g_iZombieStatus[i] = false; 
				}
			}
		}
		case 1:
		{
			if(g_iBoxingGame == 1) jbe_boxing_game_end();
			else jbe_boxing_game_start(id);
		}
		case 2:
		{
			if(g_iBoxingGame == 2) jbe_boxing_game_end();
			else jbe_boxing_game_team_start(id);
		}
		case 3: if(!g_iBoxingGame) return Show_BoxingTeamMenu(id);
		case 8: return Show_MiniGameMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_BoxingMenu(id);
}

Show_BoxingTeamMenu(id)
{
	if(g_iBoxingGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_BOXING_TEAM_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_BOXING_TEAM_DIVIDE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_BOXING_TEAM_DESCRIPTION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_BOXING_TEAM_ADD_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_BOXING_TEAM_ADD_BLUE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L^n^n", id, "JBE_MENU_BOXING_TEAM_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<4|1<<5|1<<6|1<<8|1<<9), szMenu, -1, "Show_BoxingTeamMenu");
}

public Handle_BoxingTeamMenu(id, iKey)
{
	if(g_iBoxingGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: jbe_boxing_divide_team();
		case 6:
		{
			new iTarget, iBody;
			get_user_aiming(id, iTarget, iBody, 9999);
			if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserBoxing, iTarget))
			{
				ClearBit(g_iBitUserBoxing, iTarget);
				new iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem);
				if(iActiveItem > 0)
				{
					ExecuteHamB(Ham_Item_Deploy, iActiveItem);
					UTIL_WeaponAnimation(iTarget, 3);
				}
				set_pev(iTarget, pev_health, 100.0);
				set_pdata_int(iTarget, m_bloodColor, 247);
			}
			else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_BoxingTeamMenu(id);
		}
		case 8: return Show_BoxingMenu(id);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget, iBody;
			get_user_aiming(id, iTarget, iBody, 9999);
			if(jbe_is_user_valid(iTarget) && g_iUserTeam[iTarget] == 1 && IsSetBit(g_iBitUserAlive, iTarget) && IsNotSetBit(g_iBitUserFree, iTarget) && IsNotSetBit(g_iBitUserWanted, iTarget) && IsNotSetBit(g_iBitUserSoccer, iTarget) && IsNotSetBit(g_iBitUserDuel, iTarget))
			{
				if(IsNotSetBit(g_iBitUserBoxing, iTarget))
				{
					SetBit(g_iBitUserBoxing, iTarget);
					set_pev(iTarget, pev_health, 100.0);
					set_pdata_int(iTarget, m_bloodColor, -1);
					ClearBit(g_iBitClothingType, iTarget);
				}
				g_iBoxingUserTeam[iTarget] = iKey - 4;
				if(get_user_weapon(iTarget) != CSW_KNIFE) engclient_cmd(iTarget, "weapon_knife");
				else
				{
					new iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem);
					if(iActiveItem > 0)
					{
						ExecuteHamB(Ham_Item_Deploy, iActiveItem);
						UTIL_WeaponAnimation(iTarget, 3);
					}
				}
			}
			else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_BoxingTeamMenu(id);
		}
	}
	return Show_BoxingMenu(id);
}

Show_KillReasonsMenu(id, iTarget)
{
	new szName[32], szMenu[1024], iLen;
	get_user_name(iTarget, szName, charsmax(szName));
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_KILL_REASON_TITLE", szName);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_KILL_REASON_0");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_KILL_REASON_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_KILL_REASON_2");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_KILL_REASON_3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_KILL_REASON_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_KILL_REASON_5");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L^n", id, "JBE_MENU_KILL_REASON_6");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y8. \w%L^n", id, "JBE_MENU_KILL_REASON_7");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y•\d \d%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8), szMenu, -1, "Show_KillReasonsMenu");
}

public Handle_KillReasonsMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Cmd_KilledUsersMenu(id);
		default:
		{
			if(IsSetBit(g_iBitKilledUsers[id], g_iMenuTarget[id]))
			{
				new szName[32], szNameTarget[32], szLangPlayer[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(g_iMenuTarget[id], szNameTarget, charsmax(szNameTarget));
				formatex(szLangPlayer, charsmax(szLangPlayer), "JBE_MENU_KILL_REASON_%d", iKey);
				UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_KILL_REASON", IsSetBit(g_UserDog, id) ? "Собака" : "Охранник", szName, szNameTarget, LANG_PLAYER, szLangPlayer);
				if(iKey == 7)
				{
					UTIL_SayText(0, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_AUTO_FREE_DAY", szNameTarget);
					jbe_add_user_free_next_round(g_iMenuTarget[id]);
				}
				ClearBit(g_iBitKilledUsers[id], g_iMenuTarget[id]);
				if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
			}
			else
			{
				if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
				UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
			}
		}
	}
	return PLUGIN_HANDLED;
}

Cmd_KilledUsersMenu(id) return Show_KilledUsersMenu(id, g_iMenuPosition[id] = 0);
Show_KilledUsersMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitKilledUsers[id], i)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
			jbe_menu_unblock(id);
			return PLUGIN_HANDLED;
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_KILLED_USERS_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys, b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, "JBE_MENU_BACK");
			iKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y•\d \d%L", id, "JBE_MENU_NEXT", id, "JBE_MENU_EXIT");
	}
	else
	{
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, "JBE_MENU_BACK");
			iKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y•\d \d%L", id, "JBE_MENU_EXIT");
	}
	return show_menu(id, iKeys, szMenu, -1, "Show_KilledUsersMenu");
}

public Handle_KilledUsersMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_KilledUsersMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_KilledUsersMenu(id, --g_iMenuPosition[id]);
		default:
		{
			g_iMenuTarget[id] = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(IsSetBit(g_iBitKilledUsers[id], g_iMenuTarget[id])) return Show_KillReasonsMenu(id, g_iMenuTarget[id]);
			else if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
			jbe_menu_unblock(id);
		}
	}
	return PLUGIN_HANDLED;
}

Show_LastPrisonerMenu(id)
{
	if(g_iDuelStatus || IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	
	new szMenu[1024], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_LAST_PRISONER_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_LAST_PRISONER_FREE_DAY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_LAST_PRISONER_MONEY", g_iAllCvars[LAST_PRISONER_MODEY]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_LAST_PRISONER_VOICE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_LAST_TAKE_WEAPONS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n^n^n^n", id, "JBE_MENU_LAST_PRISONER_CHOICE_DUEL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), szMenu, -1, "Show_LastPrisonerMenu");
}

public Handle_LastPrisonerMenu(id, iKey)
{
	if(g_iDuelStatus || IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			ExecuteHamB(Ham_Killed, id, id, 0);
			jbe_add_user_free_next_round(id);
		}
		case 1:
		{
			ExecuteHamB(Ham_Killed, id, id, 0);
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[LAST_PRISONER_MODEY], 1);
		}
		case 2:
		{
			ExecuteHamB(Ham_Killed, id, id, 0);
			SetBit(g_iBitUserVoiceNextRound, id);
		}
		case 3:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 2) continue;
				fm_strip_user_weapons(i, 1);
			}
			fm_give_item(id, "weapon_ak47");
			fm_set_user_bpammo(id, CSW_AK47, 200);
			//set_pev(id, pev_takedamage, DAMAGE_NO);
			set_task(1.0, "jbe_lastdie_count_down", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 50 + 1);
			g_iLastPnId = 0;
			
		}
		case 4: return Show_ChoiceDuelMenu(id);
		case 8: return Show_MainPnMenu(id);
	}
	return PLUGIN_HANDLED;
}
new szPlayerDuelWeapon[33];

public jbe_lastdie_count_down()
{
    if(--g_iLastDieCountDown)
    {
    set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 0.0, 0.9, 0.1, 0.1, -1);
    ShowSyncHudMsg(0, g_iSyncDuelInformer, "Смерть зека через: %d сек.", g_iLastDieCountDown);
    }
    else jbe_last_die();
}

public jbe_last_die()
{
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
    if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i)) continue;
    ExecuteHamB(Ham_Killed, i, i, 0);
    remove_task(TASK_LAST_DIE);
    UTIL_SayText(0, "!g[Реклама] !yПоследний зек умер");
    }
}

Show_ChoiceDuelMenu(id)
{
	if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	
	new szMenu[1024], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_CHOICE_DUEL_TITLE");
	
	switch(szPlayerDuelWeapon[id])
	{
		case 0: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wДуэль на: \r%L^n", id, "JBE_MENU_CHOICE_DUEL_DEAGLE");
		case 1: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wДуэль на: \r%L^n", id, "JBE_MENU_CHOICE_DUEL_M3");
		case 2: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wДуэль на: \r%L^n", id, "JBE_MENU_CHOICE_DUEL_HEGRENADE");
		case 3: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wДуэль на: \r%L^n", id, "JBE_MENU_CHOICE_DUEL_M249");
		case 4: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wДуэль на: \r%L^n", id, "JBE_MENU_CHOICE_DUEL_AWP");
		case 5: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wДуэль на: \r%L^n", id, "JBE_MENU_CHOICE_DUEL_KNIFE");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wВыбрать соперника^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<8|1<<9), szMenu, -1, "Show_ChoiceDuelMenu");
}

public Handle_ChoiceDuelMenu(id, iKey)
{
	if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	switch(szPlayerDuelWeapon[id])
	{
		case 0: g_iDuelType = 1;
		case 1: g_iDuelType = 2;
		case 2: g_iDuelType = 3;
		case 3: g_iDuelType = 4;
		case 4: g_iDuelType = 5;
		case 5: g_iDuelType = 6;
	}
	switch(iKey)
	{
		case 0: 
		{
			++szPlayerDuelWeapon[id];
			if(szPlayerDuelWeapon[id] > 5) szPlayerDuelWeapon[id] = 0 ;
			return Show_ChoiceDuelMenu(id);
		}
		case 1: return Cmd_DuelUsersMenu(id);
		case 8: return Show_LastPrisonerMenu(id);
	}
	return PLUGIN_HANDLED;
}

Cmd_DuelUsersMenu(id) return Show_DuelUsersMenu(id, g_iMenuPosition[id] = 0);
Show_DuelUsersMenu(id, iPos)
{
	if(iPos < 0 || id != g_iLastPnId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 2 || IsNotSetBit(g_iBitUserAlive, i)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[1024], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_DUEL_USERS", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_DuelUsersMenu");
}

public Handle_DuelUsersMenu(id, iKey)
{
	if(id != g_iLastPnId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: Show_DuelUsersMenu(id, ++g_iMenuPosition[id]);
		case 9: Show_DuelUsersMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(IsSetBit(g_iBitUserAlive, iTarget)) jbe_duel_start_ready(id, iTarget);
			else Show_DuelUsersMenu(id, g_iMenuPosition[id]);
		}
	}
	return PLUGIN_HANDLED;
}

Show_DayModeMenu(id, iPos)
{
	if(iPos < 0) return Show_DayModeMenu(id, g_iMenuPosition[id] = 0);
	
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iDayModeListSize) iStart = g_iDayModeListSize;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iDayModeListSize) iEnd = g_iDayModeListSize;
	new szMenu[1024], iLen, iPagesNum = (g_iDayModeListSize / PLAYERS_PER_PAGE + ((g_iDayModeListSize % PLAYERS_PER_PAGE) ? 1 : 0));
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n\d%L^n", id, "JBE_MENU_VOTE_DAY_MODE_TITLE", iPos + 1, iPagesNum, id, "JBE_MENU_VOTE_DAY_MODE_TIME_END", g_iDayModeVoteTime);
	new aDataDayMode[DATA_DAY_MODE], iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aDataDayMode, a, aDataDayMode);
		if(aDataDayMode[MODE_BLOCKED]) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \d%L \r[%L]^n", ++b, id, aDataDayMode[LANG_MODE], id, "JBE_MENU_VOTE_DAY_MODE_BLOCKED", aDataDayMode[MODE_BLOCKED]);
		else
		{
			if(IsSetBit(g_iBitUserDayModeVoted, id) || g_iDayModeLimit[a] != 0) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \d%L \r[%d]^n", ++b, id, aDataDayMode[LANG_MODE], aDataDayMode[VOTES_NUM]);
			else
			{
				iKeys |= (1<<b);
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\y%d\r] \w%L \r[%d]^n", ++b, id, aDataDayMode[LANG_MODE], aDataDayMode[VOTES_NUM]);
			}
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < g_iDayModeListSize)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 2, "Show_DayModeMenu");
}

public Handle_DayModeMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_DayModeMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_DayModeMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new aDataDayMode[DATA_DAY_MODE], iDayMode = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
			
			if(g_iDayModeLimit[iDayMode] != 0)
			{
				Show_DayModeMenu(id, g_iMenuPosition[id]);
			}
			else
			{
				ArrayGetArray(g_aDataDayMode, iDayMode, aDataDayMode);
				aDataDayMode[VOTES_NUM]++;
				ArraySetArray(g_aDataDayMode, iDayMode, aDataDayMode);
				SetBit(g_iBitUserDayModeVoted, id);
			}
		}
	}
	return Show_DayModeMenu(id, g_iMenuPosition[id]);
}

Show_PrivilegesMenu(id)
{	
	new szMenu[1024], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_PRIVILEGES");
	new Flag = get_user_flags(id);
	
	/*===== -> Проверка привилегий -> =====*/
	if(get_user_flags(id) & ADMIN_USER)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yЗек^n^n");
	}
	else
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yШнырь^n^n");
	}
	if(get_user_flags(id) & ADMIN_BAN)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yАвторитет^n^n");
	}
	else
	if(get_user_flags(id) & ADMIN_MENU)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yБлатной^n^n");
	}
	if(get_user_flags(id) & ADMIN_LEVEL_D)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yДевушка^n^n");
	}
	if(get_user_flags(id) & ADMIN_CFG)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yБунтарь^n^n");
	}
	if(get_user_flags(id) & ADMIN_LEVEL_C)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yРевизорро^n^n");
	}
	/*===== -> Донат -> =====*/
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserVip, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_PRIVILEGES_VIP");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_VIP");
	if(IsSetBit(g_iBitUserAdmin, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_PRIVILEGES_ADMIN");
		iKeys |= (1<<1);
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_ADMIN");
	if((Flag & ADMIN_MENU) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_PRIVILEGES_TSAR_ADMIN");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_TSAR_ADMIN");
	if((Flag & ADMIN_LEVEL_D) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_PRIVILEGES_GIRL_MENU");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_GIRL_MENU");
	
	if((Flag & ADMIN_CFG) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_PRIVILEGES_BUNT_MENU");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_BUNT_MENU");
	if((Flag & ADMIN_LEVEL_C) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_PRIVILEGES_ZOMBIE_MENU");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_ZOMBIE_MENU");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrivilegesMenu");
}

public Handle_PrivilegesMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserVip, id)) return Show_VipMenu(id); else return Show_PrivilegesMenu(id);
		case 1: if(IsSetBit(g_iBitUserAdmin, id)) return Show_AdminMenu(id);
		case 2: if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserKing, id)) Show_KingMenu(id);
		case 3: return jbe_girl_menu_open(id);
		case 4: if(get_user_flags(id) & ADMIN_CFG) return Show_DevilMenu(id);
		case 5: if(get_user_flags(id) & ADMIN_LEVEL_C) Show_ZombieMenu(id);
		case 9: 
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Show_PrivMenu(id)
{	
	new szMenu[1024], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_PRIVILEGESS");
	new Flag = get_user_flags(id);
	
	/*===== -> Проверка привилегий -> =====*/
	if(get_user_flags(id) & ADMIN_USER)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yОхранник^n^n");
	}
	if(get_user_flags(id) & ADMIN_VOTE)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yИнспектор^n^n");
	}
	else
	if(get_user_flags(id) & ADMIN_LEVEL_D)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yДевушка^n^n");
	}
	if(get_user_flags(id) & ADMIN_LEVEL_E)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yСледователь^n^n");
	}
	if(get_user_flags(id) & ADMIN_CHAT)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yДетектив^n^n");
	}
	if(get_user_flags(id) & ADMIN_RCON)
	{
	iLen = formatex(szMenu, charsmax(szMenu), "\rДонат^n\wВы\d: \yНадзиратель^n^n");
	}
	/*===== -> Донат -> =====*/
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserSuperAdmin, id) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_PRIVILEGES_SUPER_ADMIN");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_SUPER_ADMIN");
	if((Flag & ADMIN_LEVEL_D) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_PRIVILEGES_GIRL_MENU");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_GIRL_MENU");
	if(Flag & ADMIN_LEVEL_E)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_PRIVILEGES_SMOTR_MENU");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_SMOTR_MENU");
	
	if((Flag & ADMIN_CHAT) && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_PRIVILEGES_DED_MENU");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_DED_MENU");
	
	if(Flag & ADMIN_RCON)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_PRIVILEGES_OSNOV_MENU");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_PRIVILEGES_OSNOV_MENU");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrivMenu");
}

public Handle_PrivMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserSuperAdmin, id)) return Show_SuperAdminMenu(id); else return Show_PrivMenu(id);
		case 1: return jbe_girl_menu_open(id);
		case 2: if(get_user_flags(id) & ADMIN_LEVEL_E) jbe_smotr_open(id);
		case 3: if(get_user_flags(id) & ADMIN_CHAT) return Show_MinistrMenu(id);
		case 4: if(get_user_flags(id) & ADMIN_RCON) return Show_CreatorMenu(id);
		case 9: 
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Show_ZombieMenu(id)
{	
	new szMenu[1024], iKeys = (1<<2|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_ZOMBIE_TITLE");
	if(g_iUserTeam[id] == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \r[%s]^n", id, "JBE_MENUZOMBIE_MODELS", g_iZombieStatus[id] ? "Вкл":"Выкл");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[%s] [TT]^n", id, "JBE_MENUZOMBIE_MODELS", g_iZombieStatus[id] ? "Вкл":"Выкл");
	if(IsNotSetBit(g_iBitUserSoccer, id) || IsNotSetBit(g_iBitUserBoxing, id) || IsNotSetBit(g_UserDog, id) || IsNotSetBit(g_iBitUserDuel, id) || IsNotSetBit(g_iBitUserWanted, id))
	{
		if(!g_bGolod)
		{
			if(get_user_health(id) < 450)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENUZOMBIE_HP");
				iKeys |= (1<<1);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[Full XP]^n", id, "JBE_MENUZOMBIE_HP");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[Голодные игры]^n", id, "JBE_MENUZOMBIE_HP");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[Глобальная игра]^n", id, "JBE_MENUZOMBIE_HP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENUZOMBIE_REN");
	if(g_iZombieStatus[id])
	{
		if(g_iZombieBichLimited[id] == 2) 
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENUZOMBIE_BIC");
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[Использовано]^n", id, "JBE_MENUZOMBIE_BIC");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_MENUZOMBIE_BIC");
	if(g_iZombieStatus[id])
	{
		if(g_iZombieBichLimited2[id] == 2) 
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENUZOMBIE_TEXT");
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[Использовано]^n", id, "JBE_MENUZOMBIE_TEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n", id, "JBE_MENUZOMBIE_TEXT");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6.\w Супер прижок \d[Сесть + Прижок]: \r[%s]^n", g_iZombieDow[id] ? "Вкл" : "Выкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ZombieMenu");
}

public Handle_ZombieMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: 
		{
			if(g_iZombieStatus[id])
			{
				ClearBit(g_UserZombie, id);
				jbe_default_knife_model(id);
				jbe_default_player_model(id);
				g_iZombieStatus[id] = false;
				set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
				show_hudmessage(id, "Режим Ревизорро - отключен");
			}
			else if(!g_iZombieStatus[id])
			{
				SetBit(g_UserZombie, id);
				jbe_set_user_model(id, g_szPlayerModel[ZOMBIE]);
				jbe_set_zombie_knife(id);
				g_iZombieStatus[id] = true;
				set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
				show_hudmessage(id, "Вы стали Ревизорро^nРевизор не может брать Оружие");
			}
			return Show_ZombieMenu(id);
			
		}
		case 1:
		{
			if(get_user_health(id) < 450) 
			{
				set_user_health(id, get_user_health(id) + random_num(2, 5));
				return Show_ZombieMenu(id);
			}
		}
		case 2: jbe_set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0);
		case 3: 
		{
			SetBit(g_iBitHingJump, id);
			SetBit(g_iBitFastRun, id);
			SetBit(g_iBitDoubleJump, id);
			set_pev(id, pev_gravity, 0.5);
			set_pev(id, pev_maxspeed, 340.0);
			g_iZombieBichLimited[id] = 1;
		}
		case 4: 
		{
			new szName[32]; get_user_name(id, szName, charsmax(szName));
			set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
			show_hudmessage(id, "Я %s Ревизорро и всем пиздец!", szName);
			g_iZombieBichLimited2[id] = 1;
		}
		case 5:
		{
			if(!g_iZombieDow[id]) g_iZombieDow[id] = true;
			else g_iZombieDow[id] = false;
			return Show_ZombieMenu(id);
		}
		case 8: return Show_PrivilegesMenu(id);
	}
	return PLUGIN_HANDLED;
}

public FM_PreThink(id) 
{
	if(!is_user_connected(id) || !is_user_alive(id) || g_iDayMode == 3 || g_iZombieEnd[id] == 0) return;
	if(g_iZombieDow[id]) 
	{
		if((pev(id, pev_button) & IN_JUMP) && (pev(id, pev_button) & IN_DUCK) && (pev(id, pev_flags) & FL_ONGROUND)) 
		{
			if(!(pev(id, pev_oldbuttons) & IN_JUMP)) long_jump(id);
			g_iZombieEnd[id] -= 1;
			set_dhudmessage(RED[id], GREEN[id], BLUE[id], -1.0, 0.20, 0, 0.0, 0.8, 1.2, 1.2);
			show_dhudmessage(id, "Осталось %d прижков", g_iZombieEnd[id]);
		}
	}
}

Show_VipMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_VIP_TITLE");
    if(!iAlive && g_iDayMode == 2 && g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[VIP_RESPAWN_NUM])
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wВоскреснуть \d[\yФД\d]^n");
        iKeys |= (1<<0);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \dВоскреснуть [\rФД\d]^n");
	if(iAlive && g_iVipHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_VIP_HEALTH", g_iVipHealth[id]);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_VIP_HEALTH", g_iVipHealth[id]);
	if(g_iVipMoney[id] >= g_iAllCvars[VIP_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM], g_iAllCvars[VIP_MONEY_ROUND]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM], g_iAllCvars[VIP_MONEY_ROUND]);
	if(iAlive && g_iVipInvisible[id] >= g_iAllCvars[VIP_INVISIBLE])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_VIP_INVISIBLE", g_iAllCvars[VIP_INVISIBLE]);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_VIP_INVISIBLE", g_iAllCvars[VIP_INVISIBLE]);
	if(iAlive && g_iVipHpAp[id] >= g_iAllCvars[VIP_HP_AP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_VIP_HP_AP", g_iAllCvars[VIP_HP_AP_ROUND]);
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_VIP_HP_AP", g_iAllCvars[VIP_HP_AP_ROUND]);
	if(iAlive && IsNotSetBit(g_iBitUserSuperAdmin, id) && IsNotSetBit(g_iBitUserVoice, id) && g_iVipVoice[id] == g_iAllCvars[VIP_VOICE_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_VIP_VOICE", g_iAllCvars[VIP_VOICE_ROUND]);
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_VIP_VOICE", g_iAllCvars[VIP_VOICE_ROUND]);
	if(iAlive && (IsNotSetBit(g_iBitUserFree, id) && g_iUserTeam[id] == 1) && g_iVipFree[id] >= g_iAllCvars[VIP_INVISIBLE])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L^n^n^n",id, "JBE_MENU_VIP_FD", g_iAllCvars[VIP_INVISIBLE]);
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L^n^n^n",id, "JBE_MENU_VIP_FD", g_iAllCvars[VIP_INVISIBLE]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_VipMenu");
}

public Handle_VipMenu(id, iKey)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
            if(IsNotSetBit(g_iBitUserAlive, id) && g_iDayMode == 2 && g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[VIP_RESPAWN_NUM])
            {
                ExecuteHamB(Ham_CS_RoundRespawn, id);
                g_iVipRespawn[id]--;
				UTIL_SayText(0, "%L Шнырь !g%s!y возрадился!", id, "JBE_PREFIX", szName);
			}
		}
		case 1:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iVipHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
			{
				set_pev(id, pev_health, 100.0);
				g_iVipHealth[id]--;
				UTIL_SayText(0, "%L Шнырь !g%s!y подлечился! !t[set 100 HP]", id, "JBE_PREFIX", szName);
			}
		}
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[VIP_MONEY_NUM], 1);
			g_iVipMoney[id] = 0;
			UTIL_SayText(0, "%L Шнырь !g%s!y взял %d Евро!", id, "JBE_PREFIX", szName, g_iAllCvars[VIP_MONEY_NUM]);
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iUserTeam[id] == 2)
			{
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				jbe_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				g_iVipInvisible[id] = 0;
				UTIL_SayText(0, "%L Охранник !g%s!y взял Невидимость!", id, "JBE_PREFIX", szName);
			}
		}
		case 4:
		{
			if(IsSetBit(g_iBitUserAlive, id))
			{
				set_pev(id, pev_health, 250.0);
				set_pev(id, pev_armorvalue, 250.0);
				g_iVipHpAp[id] = 0;
				UTIL_SayText(0, "%L Шнырь !g%s!y взял 250 HP/AP!", id, "JBE_PREFIX", szName);
			}
		}
		case 5:
		{
			if(IsSetBit(g_iBitUserAlive, id) && IsNotSetBit(g_iBitUserVoice, id))
			{
				SetBit(g_iBitUserVoice, id);
				g_iVipVoice[id] = 0;
				UTIL_SayText(0, "%L Шнырь !g%s!y взял Голос!", id, "JBE_PREFIX", szName);
			}
		}
		case 6:
		{
			if(IsNotSetBit(g_iBitUserFree, id) && jbe_get_user_team(id) == 1)
			{
				jbe_add_user_free(id);
				g_iVipFree[id] = 0;
				new szName[32];
				get_user_name(id, szName, charsmax(szName));
				UTIL_SayText(0, "%L Шнырь !t%s !yвзял !gсвободный день", id, "JBE_PREFIX", szName);
			}
		}
		case 8:
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Show_AdminMenu(id)
{
	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_ADMIN_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_ADMIN_KICK");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_ADMIN_BAN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_ADMIN_TEAM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_ADMIN_MAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_ADMIN_VOTE_MAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w%L^n", id, "JBE_MENU_ADMIN_GOLOS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L^n", id, "JBE_MENU_SUPER_ADMIN_BLOCKED_GUARD");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y8. \w%L^n", id, "JBE_MENU_SUPER_ADMIN_UNBLOCKED_GUARD");
	if(g_iUserTeam[id] == 1 || g_iUserTeam[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
		iKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_AdminMenu");
}

public Handle_AdminMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: client_cmd(id, "amx_kickmenu");
		case 1: client_cmd(id, "amx_banmenu");
		case 2: client_cmd(id, "amx_teammenu");
		case 3: client_cmd(id, "amx_mapmenu");
		case 4: client_cmd(id, "amx_votemapmenu");
		case 5: return Cmd_VoiceControlMenu(id);
		case 6: return client_cmd(id, "block");
		case 7: return client_cmd(id, "unblock");
		case 8:
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Show_SuperAdminMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<6|1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SUPER_ADMIN_TITLE");
	if(!iAlive && g_iAdminRespawn[id] && g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[RESPAWN_PLAYER_NUM])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L^n", id, "JBE_MENU_SUPER_ADMIN_RESPAWN", g_iAdminRespawn[id]);
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SUPER_ADMIN_RESPAWN", g_iAdminRespawn[id]);
	if(iAlive && g_iAdminHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L^n", id, "JBE_MENU_SUPER_ADMIN_HEALTH", g_iAdminHealth[id]);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SUPER_ADMIN_HEALTH", g_iAdminHealth[id]);
	if(g_iAdminMoney[id] >= g_iAllCvars[ADMIN_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L^n", id, "JBE_MENU_SUPER_ADMIN_MONEY", g_iAllCvars[ADMIN_MONEY_NUM], g_iAllCvars[ADMIN_MONEY_ROUND]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SUPER_ADMIN_MONEY", g_iAllCvars[ADMIN_MONEY_NUM], g_iAllCvars[ADMIN_MONEY_ROUND]);
	if(iAlive && g_iChiefId == id && g_iAdminGod[id] >= g_iAllCvars[ADMIN_GOD_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L^n", id, "JBE_MENU_SUPER_ADMIN_GOD", g_iAllCvars[ADMIN_GOD_ROUND]);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SUPER_ADMIN_GOD", g_iAllCvars[ADMIN_GOD_ROUND]);
	if(iAlive && g_iAdminFootSteps[id] >= g_iAllCvars[ADMIN_FOOTSTEPS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L^n", id, "JBE_MENU_SUPER_ADMIN_FOOTSTEPS", g_iAllCvars[ADMIN_FOOTSTEPS_ROUND]);
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L^n", id, "JBE_MENU_SUPER_ADMIN_FOOTSTEPS", g_iAllCvars[ADMIN_FOOTSTEPS_ROUND]);
	
	if(iAlive && g_iUserTeam[id] == 2 && g_iAdminElectro[id] >= g_iAllCvars[ADMIN_ELECTRO_ROUND]) {
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \wЭлектро \d[\yраз в %d дней\d] [охрана]^n^n", g_iAllCvars[ADMIN_ELECTRO_ROUND]);
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \dЭлектро \d[\yраз в %d дней\d] [охрана]^n^n", g_iAllCvars[ADMIN_ELECTRO_ROUND]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SuperAdminMenu");
}

public Handle_SuperAdminMenu(id, iKey)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(IsNotSetBit(g_iBitUserAlive, id) && g_iAdminRespawn[id] && g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[RESPAWN_PLAYER_NUM])
			{
				ExecuteHamB(Ham_CS_RoundRespawn, id);
				g_iAdminRespawn[id]--;
				UTIL_SayText(0, "%L Инспектор !g%s!y возрадился!", id, "JBE_PREFIX", szName);
			}
		}
		case 1:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iAdminHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
			{
				set_pev(id, pev_health, 100.0);
				g_iAdminHealth[id]--;
				UTIL_SayText(0, "%L Инспектор !g%s!y подлечился! !t[set 100 HP]", id, "JBE_PREFIX", szName);
			}
		}
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ADMIN_MONEY_NUM], 1);
			g_iAdminMoney[id] = 0;
			UTIL_SayText(0, "%L Инспектор !g%s!y взял %d Евро!", id, "JBE_PREFIX", szName, g_iAllCvars[ADMIN_MONEY_NUM]);
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iChiefId == id)
			{
				set_user_godmode(id, 1);
				g_iAdminGod[id] = 0;
				UTIL_SayText(0, "%L Инспектор !g%s!y взял бессмертие!", id, "JBE_PREFIX", szName);
			}
		}
		case 4:
		{
			if(IsSetBit(g_iBitUserAlive, id))
			{
				set_user_footsteps(id, 1);
				g_iAdminFootSteps[id] = 0;
				UTIL_SayText(0, "%L Инспектор !g%s!y взял тихий шаг!", id, "JBE_PREFIX", szName);
			}
		}
		case 5: 
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iUserTeam[id] == 2) 
			{
				g_iAdminElectro[id] = 0;
				SetBit(g_iBitUserElectro, id);
				UTIL_SayText(0, "%L Инспектор !g%s!y взял Электро костюм!", id, "JBE_PREFIX", szName);
			}
		}
		case 8:
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Show_MainPnMenu(id);
				case 2: return Show_MainGrMenu(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

new imBoss[33], imBoss2[33];

Show_KingMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id) && IsNotSetBit(g_iBitUserKing, id) && IsSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<5|1<<6|1<<7|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_KING_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%L \y[%s]^n", id, "JBE_KING_INVIZ", g_KingInviz[id] ? "Вкл":"Выкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w%L \y[%s]^n", id, "JBE_KING_BLOCK_GUARD", g_BlockGuard ? "Выкл":"Вкл");	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w%L \y[%d]^n", id, "JBE_KING_BONUS", g_KingBitchPacket[id]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w%L \y[%d]^n", id, "JBE_KING_RESSPAWN", g_RoundResspawn[id]);
	if(jbe_get_user_team(id) == 1)
	{
		new iPriceToma = jbe_get_price_discount(id, g_iShopCvars[TOMA]);
		if(IsNotSetBit(g_iBitToma, id))
		{
			if(iPriceToma <= g_iUserMoney[id])
			{
				if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserKing, id))
				{
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma);
					iKeys |= (1<<4);
				}
				else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d \d%L \r[%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y•\d%L [%dЕвро]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA", iPriceToma);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• \d%L \r[ТТ]^n", id, "JBE_MENU_SHOP_WEAPONS_TOMA");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y6. \w%L \y[%s]^n", id, "JBE_KING_BOSS", imBoss[id] ? "Вкл":"Выкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \w%L \y[%s]^n", id, "JBE_MENU_SHOP_WEAPONS_TOPOR", imBoss2[id] ? "Вкл":"Выкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_KingMenu");
}

public Handle_KingMenu(id, iKey)
{
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	if(g_iDayMode != 1 && g_iDayMode != 2 && IsNotSetBit(g_iBitUserKing, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(g_KingInviz[id])
			{
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 100);
				g_KingInviz[id] = false;
			}
			else if(!g_KingInviz[id])
			{
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 70);
				g_KingInviz[id] = true;
			}
			return Show_KingMenu(id);
		}
		case 1:
		{
			if(g_BlockGuard)
			{
				UTIL_SayText(0, "%L Блатной !g%s!t разблокировал !yвсем, вход за !gОхрану", id, "JBE_PREFIX", szName);
				g_BlockGuard = false;
			}else if(!g_BlockGuard)
			{
				UTIL_SayText(0, "%L Блатной !g%s!t заблокировал !yвсем, вход за !gОхрану", id, "JBE_PREFIX", szName);
				g_BlockGuard = true;
			}
			return Show_KingMenu(id);
		}
		case 2:
		{
			if(g_KingBitchPacket[id] == 0) return PLUGIN_HANDLED;
			else if(g_KingBitchPacket[id] > 0)
			{
				jbe_set_user_money(id, jbe_get_user_money(id) + 100, 1);
				set_user_health(id, get_user_health(id) + 100);
				set_user_armor(id, get_user_armor(id) + 100);
				g_KingBitchPacket[id]--;
			}
			return Show_KingMenu(id);
		}
		case 3:
		{
			if(g_RoundResspawn[id] > 0)
			{
				Cmd_RespawnMenu(id);
			}
			else return Show_KingMenu(id);
		}
		case 4: if(jbe_get_user_team(id) == 1)
		{
			new iPriceToma = jbe_get_price_discount(id, g_iShopCvars[TOMA]);
			if(IsNotSetBit(g_iBitToma, id) && iPriceToma <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceToma, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitShok, id);
				SetBit(g_iBitToma, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 5: 
		{
			if(imBoss[id])
			{
				CREATE_KILLPLAYERATTACHMENTS(id);
				imBoss[id] = false;
			}
			else if(!imBoss[id])
			{
				CREATE_PLAYERATTACHMENT(id, _, g_pSpriteBoss, 30000);
				imBoss[id] = true;
			}
			return Show_KingMenu(id);
		}
		case 6: 
		{
			if(imBoss2[id])
			{
				ClearBit(g_iBitTopor, id);
				imBoss2[id] = false;
			}
			else if(!imBoss2[id])
			{
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitKnif, id);
				ClearBit(g_iBitPila, id);
				ClearBit(g_iBitShok, id);
				ClearBit(g_iBitToma, id);
				SetBit(g_iBitTopor, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				imBoss2[id] = true;
			}
			return Show_KingMenu(id);
		}
		case 8:
		{
			return Show_PrivilegesMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

public Show_CreatorMenu(id)	
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите действие^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w%s клетки^n", g_bDoorStatus ? "Закрыть" : "Открыть");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wВыдача денег^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \wМеню выдачи паутинки^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \wРозыск \y'Выдать|Забрать'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \wСвободный день \y'Выдать|Забрать'^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \wСказать всем речь^n");
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7. \wДжетпак \d[\yВзять\d]^n^n");
	    iKeys |= (1<<6);
	}
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_CreatorMenu");
}


#define PL_TYPE pl_admin_give_money[id][0]
#define PL_MONEY pl_admin_give_money[id][1]

new pl_admin_give_money[33][2];

public Handle_CreatorMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: 
		{
			if(g_bDoorStatus) jbe_close_doors();
			else jbe_open_doors();
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			UTIL_SayText(0, "%L Надзиратель !t%s !y%s клетки", id, "JBE_PREFIX", szName, g_bDoorStatus ? "открыл" : "закрыл");
		}
		case 1: return Show_MoneyMenuSub(id);
		case 2: return Show_GiveHook_Menu(id, 0);
		case 3: return Show_Give_Sub_Wanted(id, 0);
		case 4: return Show_Give_Sub_FreeDay(id, 0);
		case 5:
		{
			new szName[32]; get_user_name(id, szName, charsmax(szName));
			client_cmd(0, "spk jb_engine/take_chief_new.wav");
			set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
			show_hudmessage(id, "Я %s^nИ я всех приветствую!^nВсем бобра:3", szName);
		}
		case 6: client_cmd(id, "jetpack");
		case 9: return PLUGIN_HANDLED;
	}
	return Show_CreatorMenu(id);
}

public Show_MoneyMenuSub(id)
{
	
	new szMenu[512], iLen;

	iLen = formatex(szMenu, charsmax(szMenu), "\y• \yВыдать деньги^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wДействие:\y %s^n", PL_TYPE == 1 ? "Выдать" : "Забрать");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wКоличество: \r[%dЕвро]^n", PL_MONEY);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \wВыбрать игрока^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \wВыход");
	return show_menu(id, 1023, szMenu, -1, "Show_MoneyMenu");
}

public Handle_GiveMoneyMenu(id, key)
{
	switch(key)
	{
		case 0:
		{
			PL_TYPE++;
			if (PL_TYPE > 1) PL_TYPE = 0;
		}
		case 1:
		{
			PL_MONEY += 100;
			if(PL_MONEY == 10000) PL_MONEY = 100;
		}
		case 2:
		{
			
			return jbe_build_players_menu(id);
		}
		case 9:
		{
			
			return PLUGIN_HANDLED;
		}
	}

	return Show_MoneyMenuSub(id);
}

public Show_Give_Sub_Wanted(id, page)
{
	new szPlayers[32], szName[64], szKey[3],
	iCount, iMenu, iPlayer, i;

	get_players(szPlayers, iCount, "eh", "TERRORIST");
	iMenu = menu_create("Меню выдачи/снятия розыска", "jbe_give_wanted_menu_handler");

	for( i = 0; i < iCount; i++ )
	{
		iPlayer = szPlayers[i];
		get_user_name(iPlayer, szName, charsmax(szName));

		if (IsSetBit(g_iBitUserWanted, iPlayer)) format(szName, charsmax(szName), "%s \r[\yСнять розыск\r]", szName);
		else format(szName, charsmax(szName), "%s \r[\yВыдать розыск\r]", szName);

		szKey[0] = iPlayer;
		menu_additem(iMenu, szName, szKey);
	}

	menu_setprop(iMenu, MPROP_EXITNAME, "Выход");
	menu_setprop(iMenu, MPROP_NEXTNAME, "Далее");
	menu_setprop(iMenu, MPROP_BACKNAME, "Назад");

	return menu_display(id, iMenu, page);
}

public jbe_give_wanted_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT) return menu_destroy(menu);

	static szKey[3], szAdminName[32], szTargetName[32],
	iData;

	menu_item_getinfo(menu, item, iData, szKey, charsmax(szKey), .callback = iData);
	item = szKey[0];

	menu_destroy(menu);
	if (!is_user_connected(item)) return Show_Give_Sub_Wanted(id, 0);

	get_user_name(id, szAdminName, charsmax(szAdminName));
	get_user_name(item, szTargetName, charsmax(szTargetName));

	if (IsSetBit(g_iBitUserWanted, item))
	{
		jbe_sub_user_wanted(item);
		UTIL_SayText(0, "%L Надзиратель ^4%s ^1снял с розыска ^4%s", id, "JBE_PREFIX", szAdminName, szTargetName);
	}
	else
	{
		jbe_add_user_wanted(item);
		UTIL_SayText(0, "%L Надзиратель ^4%s ^1добавил в розыск ^4%s", id, "JBE_PREFIX", szAdminName, szTargetName);
	}

	return Show_Give_Sub_Wanted(id, item / 7);
}

public Show_Give_Sub_FreeDay(id, page)
{
	new szPlayers[32], szName[64], szKey[3],
	iCount, iMenu, iPlayer, i;

	get_players(szPlayers, iCount, "eh", "TERRORIST");
	iMenu = menu_create("Меню выдачи/снятия\r свободного дня", "jbe_give_freeday_menu_handler");

	for( i = 0; i < iCount; i++ )
	{
		iPlayer = szPlayers[i];
		get_user_name(iPlayer, szName, charsmax(szName));

		if (IsSetBit(g_iBitUserFree, iPlayer)) format(szName, charsmax(szName), "%s \r[\yЗабрать свободный\r]", szName);
		else format(szName, charsmax(szName), "%s \r[\yВыдать свободный\r]", szName);

		szKey[0] = iPlayer;
		menu_additem(iMenu, szName, szKey);
	}

	menu_setprop(iMenu, MPROP_EXITNAME, "Выход");
	menu_setprop(iMenu, MPROP_NEXTNAME, "Далее");
	menu_setprop(iMenu, MPROP_BACKNAME, "Назад");

	return menu_display(id, iMenu, page);
}

public jbe_give_freeday_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT) return menu_destroy(menu);

	static szKey[3], szAdminName[32], szTargetName[32],
	iData;

	menu_item_getinfo(menu, item, iData, szKey, charsmax(szKey), .callback = iData);
	item = szKey[0];

	menu_destroy(menu);
	if (!is_user_connected(item)) return Show_Give_Sub_FreeDay(id, 0);

	get_user_name(id, szAdminName, charsmax(szAdminName));
	get_user_name(item, szTargetName, charsmax(szTargetName));

	if (IsSetBit(g_iBitUserFree, item))
	{
		jbe_sub_user_free(item);
		UTIL_SayText(0, "%L Надзиратель ^4%s ^1забрал у ^4%s ^1свободный день", id, "JBE_PREFIX", szAdminName, szTargetName);
	}
	else
	{
		jbe_add_user_free(item);
		UTIL_SayText(0, "%L Надзиратель ^4%s ^1выдал ^4%s ^1свободный день", id, "JBE_PREFIX", szAdminName, szTargetName);
	}

	return Show_Give_Sub_FreeDay(id, item / 7);
}

public jbe_build_players_menu(id)
{
	new szPlayers[32], szName[32],
	iCount, iMenu;

	iMenu = menu_create("Выберите игрока", "jbe_give_money_handler");

	get_players(szPlayers, iCount, "h");
	for(new i = 0; i < iCount; i++)
	{
		get_user_name(szPlayers[i], szName, charsmax(szName));
		menu_additem(iMenu, szName);
	}

	menu_setprop(iMenu, MPROP_EXITNAME, "Выход");
	menu_setprop(iMenu, MPROP_NEXTNAME, "Далее");
	menu_setprop(iMenu, MPROP_BACKNAME, "Назад");

	return menu_display(id, iMenu);
}

public jbe_give_money_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		
		return menu_destroy(menu);
	}

	new szKey[3], szName[32],
	iData;

	menu_item_getinfo(menu, item, iData, szKey, charsmax(szKey), szName, charsmax(szName), iData);
	item = get_user_index(szName);

	
	menu_destroy(menu);

	if (!item)
	{
		UTIL_SayText(id, "%L %s уже возможно вышел.", id, "JBE_PREFIX", szName);
		return PLUGIN_HANDLED;
	}

	switch(PL_TYPE)
	{
		case 0: jbe_set_user_money(item, clamp(jbe_get_user_money(item) - PL_MONEY, 0, 99999), 1);
		case 1: jbe_set_user_money(item, clamp(jbe_get_user_money(item) + PL_MONEY, 0, 99999), 1);
	}

	new szAdminName[32];
	get_user_name(id, szAdminName, charsmax(szAdminName));
	UTIL_SayText(0, "%L Надзиратель ^x04%s^x01 %s %s %dЕвро", id, "JBE_PREFIX", PL_TYPE == 1 ? "забрал у":"выдал", szName, PL_MONEY);

	return PLUGIN_HANDLED;
}

public Show_CreatorMoney(id)	{
	
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите количество^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \w+100Евро^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \w+200Евро^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w+500Евро^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \w+1000Евро^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \w+2000Евро^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \w+5000Евро^n^n^n");

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_CreatorMoney");
}

public Handle_CreatorMoney(id, iKey)	{
	switch(iKey)	{
		case 8: return Show_CreatorMenu(id);
		case 9: return PLUGIN_HANDLED;
		default: g_iMenuSelectMoney[id] = g_iConstMoney[iKey];
	}
	
	return Cmd_TargCreatorMenu(id);
}

public Cmd_TargCreatorMenu(id) return Show_TargCreatorMenu(id, g_iMenuPosition[id] = 0);
public Show_TargCreatorMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitUserConnected, i) || g_iUserTeam[i] == 3) continue;

		g_iMenuPlayers[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_CreatorMenu(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите игрока \w[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));

		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y9. \w%L^n\y0. \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y0. \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_TargCreatorMenu");
}

public Handle_TargCreatorMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_TargCreatorMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_TargCreatorMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iPlayer = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];

			new szName[32], szNamePlayer[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iPlayer, szNamePlayer, charsmax(szNamePlayer));
			
			switch(g_iMenuSelectItem[id])	{
				case 1:	{
					jbe_set_user_money(iPlayer, g_iUserMoney[iPlayer] + g_iMenuSelectMoney[id], 1);
					UTIL_SayText(0, "%L !yНадзиратель !t%s !yвыдал деньги !g%d !yигроку !t%s", id, "JBE_PREFIX", szName, g_iMenuSelectMoney[id], szNamePlayer);
				}
				case 2:	{
					if(IsNotSetBit(g_iBitUserAlive, iPlayer)) {
						ExecuteHamB(Ham_CS_RoundRespawn, iPlayer);
						UTIL_SayText(0, "%L Надзиратель !t%s !yвозродил игрока !t%s", id, "JBE_PREFIX", szName, szNamePlayer);
					}
				}
			}
		}
	}
	return Show_CreatorMenu(id);
}

public jbe_daymode_start_game()
{
	jbe_vote_day_mode_start();
	jbe_set_day_mode(3);
	g_iDayGamesLimit = 0;
	for(new i; i < g_iDayModeListSize; i++)
	{
		if(g_iDayModeLimit[i] != 0)
		{
			--g_iDayModeLimit[i];
		}	
	}
	set_task(3.0, "jbe_off_priv_gm");
}

public jbe_off_priv_gm()
{
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		jbe_default_knife_model(i);
		if(IsSetBit(g_UserZombie, i)) ClearBit(g_UserZombie, i);
		if(!g_iZombieStatus[i]) g_iZombieStatus[i] = false;
		if(IsSetBit(g_iBitHingJump, i)) ClearBit(g_iBitHingJump, i);
		if(IsSetBit(g_iBitFastRun, i)) ClearBit(g_iBitFastRun, i);
		if(IsSetBit(g_iBitDoubleJump, i)) ClearBit(g_iBitDoubleJump, i);
		if(IsSetBit(g_iBitRandomGlow, i)) ClearBit(g_iBitRandomGlow, i);
		if(IsSetBit(g_iBitAutoBhop, i)) ClearBit(g_iBitAutoBhop, i);
		if(IsSetBit(g_iBitDoubleDamage, i)) ClearBit(g_iBitDoubleDamage, i);
		if(IsSetBit(g_iBitUserBoxing, i)) ClearBit(g_iBitUserBoxing, i);
		if(IsSetBit(g_iBitSharpening, i)) ClearBit(g_iBitSharpening, i);
		if(IsSetBit(g_iBitPila, i)) ClearBit(g_iBitPila, i);
		if(IsSetBit(g_iBitShok, i)) ClearBit(g_iBitShok, i);
		if(IsSetBit(g_iBitScrewdriver, i)) ClearBit(g_iBitScrewdriver, i);
		if(IsSetBit(g_iBitBalisong, i)) ClearBit(g_iBitBalisong, i);
		if(IsSetBit(g_iBitToma, i)) ClearBit(g_iBitToma, i);
		if(IsSetBit(g_iBitKnif, i)) ClearBit(g_iBitKnif, i);
		if(IsSetBit(g_iBitTopor, i)) ClearBit(g_iBitTopor, i);
		if(IsSetBit(g_iBitWeaponStatus, i)) ClearBit(g_iBitWeaponStatus, i);
		if(IsSetBit(g_iBitLatchkey, i)) ClearBit(g_iBitLatchkey, i);
		if(IsSetBit(g_iBitKokain, i)) ClearBit(g_iBitKokain, i);
		if(g_bSoccerStatus) jbe_soccer_disable_all();
		if(g_bBoxingStatus) jbe_boxing_disable_all();
		if(!g_bGolod) g_bGolod = false;
		if(g_iFriendlyFire) g_iFriendlyFire = 0;
		jbe_default_player_model(i);
		jbe_default_knife_model(i);
		set_pev(i, pev_health, 100.0);
		
		if(IsSetBit(g_UserDog, i)) 
		{
			UTIL_SayText(i, "%L !yСобака не играет в !tигры!y.", LANG_PLAYER, "JBE_PREFIX");
			id_user_kill(i);
		}
	}
	
}
/*===== <- Меню <- =====*///}

/*===== -> Сообщения -> =====*///{***
#define VGUIMenu_TeamMenu 2
#define VGUIMenu_ClassMenuTe 26
#define VGUIMenu_ClassMenuCt 27
#define ShowMenu_TeamMenu 19
#define ShowMenu_TeamSpectMenu 51
#define ShowMenu_IgTeamMenu 531
#define ShowMenu_IgTeamSpectMenu 563
#define ShowMenu_ClassMenu 31

message_init()
{
	register_message(MsgId_TextMsg, "Message_TextMsg");
	register_message(MsgId_ResetHUD, "Message_ResetHUD");
	register_message(MsgId_ShowMenu, "Message_ShowMenu");
	register_message(MsgId_Money, "Message_Money");
	register_message(MsgId_VGUIMenu, "Message_VGUIMenu");
	register_message(MsgId_ClCorpse, "Message_ClCorpse");
	register_message(MsgId_HudTextArgs, "Message_HudTextArgs");
	register_message(MsgId_SendAudio, "Message_SendAudio");
	register_message(MsgId_StatusText, "Message_StatusText");
	register_message(g_msgHideWeapon, "msgHideWeapon");
}

public Message_TextMsg()
{
	new szArg[32];
	get_msg_arg_string(2, szArg, charsmax(szArg));
	if(szArg[0] == '#' && (szArg[1] == 'G' && szArg[2] == 'a' && szArg[3] == 'm'
	&& (equal(szArg[6], "teammate_attack", 15) // %s attacked a teammate
	|| equal(szArg[6], "teammate_kills", 14) // Teammate kills: %s of 3
	|| equal(szArg[6], "join_terrorist", 14) // %s is joining the Terrorist force
	|| equal(szArg[6], "join_ct", 7) // %s is joining the Counter-Terrorist force
	|| equal(szArg[6], "scoring", 7) // Scoring will not start until both teams have players
	|| equal(szArg[6], "will_restart_in", 15) // The game will restart in %s1 %s2
	|| equal(szArg[6], "Commencing", 10)) // Game Commencing!
	|| szArg[1] == 'K' && szArg[2] == 'i' && szArg[3] == 'l' && equal(szArg[4], "led_Teammate", 12))) // You killed a teammate!
		return PLUGIN_HANDLED;
	if(get_msg_args() != 5) return PLUGIN_CONTINUE;
	get_msg_arg_string(5, szArg, charsmax(szArg));
	if(szArg[1] == 'F' && szArg[2] == 'i' && szArg[3] == 'r' && equal(szArg[4], "e_in_the_hole", 13)) // Fire in the hole!
		return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public Message_ResetHUD(iMsgId, iMsgDest, iReceiver)
{
	if(IsNotSetBit(g_iBitUserConnected, iReceiver)) return;
	set_pdata_int(iReceiver, m_iClientHideHUD, 0);
	set_pdata_int(iReceiver, m_iHideHUD, (1<<4));
}

public Message_ShowMenu(iMsgId, iMsgDest, iReceiver)
{
	switch(get_msg_arg_int(1))
	{
		case ShowMenu_TeamMenu, ShowMenu_TeamSpectMenu:
		{
			Show_ChooseTeamMenu(iReceiver, 0);
			return PLUGIN_HANDLED;
		}
		case ShowMenu_ClassMenu, ShowMenu_IgTeamMenu, ShowMenu_IgTeamSpectMenu: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public Message_Money() return PLUGIN_HANDLED;

public Message_VGUIMenu(iMsgId, iMsgDest, iReceiver)
{
	switch(get_msg_arg_int(1))
	{
		case VGUIMenu_TeamMenu:
		{
			Show_ChooseTeamMenu(iReceiver, 0);
			return PLUGIN_HANDLED;
		}
		case VGUIMenu_ClassMenuTe, VGUIMenu_ClassMenuCt: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public Message_ClCorpse() return PLUGIN_HANDLED;
public Message_HudTextArgs() return PLUGIN_HANDLED;

public Message_SendAudio()
{
	new szArg[32];
	get_msg_arg_string(2, szArg, charsmax(szArg));
	if(szArg[0] == '%' && (szArg[2] == 'M' && szArg[3] == 'R' && szArg[4] == 'A' && szArg[5] == 'D'
	&& equal(szArg[7], "FIREINHOLE", 10))) // !MRAD_FIREINHOLE
		return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public Message_StatusText() return PLUGIN_HANDLED;
/*===== <- Сообщения <- =====*///}

/*===== -> Двери в тюремных камерах -> =====*///{***
door_init()
{
	g_aDoorList = ArrayCreate();
	new iEntity[2], Float:vecOrigin[3], szClassName[32], szTargetName[32];
	while((iEntity[0] = engfunc(EngFunc_FindEntityByString, iEntity[0], "classname", "info_player_deathmatch")))
	{
		pev(iEntity[0], pev_origin, vecOrigin);
		while((iEntity[1] = engfunc(EngFunc_FindEntityInSphere, iEntity[1], vecOrigin, 200.0)))
		{
			if(!pev_valid(iEntity[1])) continue;
			pev(iEntity[1], pev_classname, szClassName, charsmax(szClassName));
			if(szClassName[5] != 'd' && szClassName[6] != 'o' && szClassName[7] != 'o' && szClassName[8] != 'r') continue;
			if(pev(iEntity[1], pev_iuser1) == IUSER1_DOOR_KEY) continue;
			pev(iEntity[1], pev_targetname, szTargetName, charsmax(szTargetName));
			if(TrieKeyExists(g_tButtonList, szTargetName))
			{
				set_pev(iEntity[1], pev_iuser1, IUSER1_DOOR_KEY);
				ArrayPushCell(g_aDoorList, iEntity[1]);
				fm_set_kvd(iEntity[1], szClassName, "spawnflags", "0");
				fm_set_kvd(iEntity[1], szClassName, "wait", "-1");
			}
		}
	}
	g_iDoorListSize = ArraySize(g_aDoorList);
}
/*===== <- Двери в тюремных камерах <- =====*///}

/*===== -> 'fakemeta' события -> =====*///{
fakemeta_init()
{
	TrieDestroy(g_tButtonList);
	unregister_forward(FM_KeyValue, g_iFakeMetaKeyValue, true);
	TrieDestroy(g_tRemoveEntities);
	unregister_forward(FM_Spawn, g_iFakeMetaSpawn, true);
	register_forward(FM_EmitSound, "FakeMeta_EmitSound", false);
	register_forward(FM_SetClientKeyValue, "FakeMeta_SetClientKeyValue", false);
	register_forward(FM_Voice_SetClientListening, "FakeMeta_Voice_SetListening", false);
	register_forward(FM_SetModel, "FakeMeta_SetModel", false);
	register_forward(FM_PlayerPreThink, "FM_PreThink");
}

public FakeMeta_KeyValue_Post(iEntity, KVD_Handle)
{
	if(!pev_valid(iEntity)) return;
	new szBuffer[32];
	get_kvd(KVD_Handle, KV_ClassName, szBuffer, charsmax(szBuffer));
	if((szBuffer[5] != 'b' || szBuffer[6] != 'u' || szBuffer[7] != 't') && (szBuffer[0] != 'b' || szBuffer[1] != 'u' || szBuffer[2] != 't')) return; // func_button
	get_kvd(KVD_Handle, KV_KeyName, szBuffer, charsmax(szBuffer));
	if(szBuffer[0] != 't' || szBuffer[1] != 'a' || szBuffer[3] != 'g') return; // target
	get_kvd(KVD_Handle, KV_Value, szBuffer, charsmax(szBuffer));
	TrieSetCell(g_tButtonList, szBuffer, iEntity);
}

public FakeMeta_Spawn_Post(iEntity)
{
	if(!pev_valid(iEntity)) return;
	new szClassName[32];
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName));
	if(TrieKeyExists(g_tRemoveEntities, szClassName))
	{
		if(szClassName[5] == 'u' && pev(iEntity, pev_iuser1) == IUSER1_BUYZONE_KEY) return;
		engfunc(EngFunc_RemoveEntity, iEntity);
	}
}

public FakeMeta_EmitSound(id, iChannel, szSample[], Float:fVolume, Float:fAttn, iFlag, iPitch)
{
	if(jbe_is_user_valid(id))
	{
		if(szSample[8] == 'k' && szSample[9] == 'n' && szSample[10] == 'i' && szSample[11] == 'f' && szSample[12] == 'e')
		{
			if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, id))
			{
				switch(szSample[17])
				{
					case 'l': emit_sound(id, iChannel, "jb_engine/weapons/hand_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					case 'w': emit_sound(id, iChannel, "jb_engine/weapons/hand_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					case 's': emit_sound(id, iChannel, "jb_engine/weapons/hand_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					case 'b': emit_sound(id, iChannel, "jb_engine/weapons/hand_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					default: emit_sound(id, iChannel, "jb_engine/weapons/hand_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
				}
				return FMRES_SUPERCEDE;
			}
			if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, id))
			{
				switch(szSample[17])
				{
					case 'l': emit_sound(id, iChannel, "jb_engine/weapons/hand_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					case 'w': emit_sound(id, iChannel, "jb_engine/boxing/gloves_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					case 's': emit_sound(id, iChannel, "jb_engine/weapons/hand_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					case 'b': emit_sound(id, iChannel, "jb_engine/boxing/gloves_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					default: emit_sound(id, iChannel, "jb_engine/boxing/gloves_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
				}
				return FMRES_SUPERCEDE;
			}
			if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, id))
			{
				switch(szSample[17])
				{
					case 'l':
					{
						if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitKnif, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitToma, id)) emit_sound(id, iChannel, "jb_engine/shop/toma_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitPila, id)) emit_sound(id, iChannel, "jb_engine/shop/pila_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitShok, id)) emit_sound(id, iChannel, "jb_engine/shop/shok_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitTopor, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					}
					case 'w':
					{
						if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitKnif, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitToma, id)) emit_sound(id, iChannel, "jb_engine/shop/toma_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitPila, id)) emit_sound(id, iChannel, "jb_engine/shop/pila_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitShok, id)) emit_sound(id, iChannel, "jb_engine/shop/shok_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitTopor, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					}
					case 's':
					{
						if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitToma, id)) emit_sound(id, iChannel, "jb_engine/shop/toma_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitPila, id)) emit_sound(id, iChannel, "jb_engine/shop/pila_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitShok, id)) emit_sound(id, iChannel, "jb_engine/shop/shok_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitTopor, id)) emit_sound(id, iChannel, "jb_engine/shop/toma_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					}
					case 'b':
					{
						if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitKnif, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitToma, id)) emit_sound(id, iChannel, "jb_engine/shop/toma_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitPila, id)) emit_sound(id, iChannel, "jb_engine/shop/pila_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitShok, id)) emit_sound(id, iChannel, "jb_engine/shop/shok_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitTopor, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					}
					default:
					{
						if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(IsSetBit(g_iBitKnif, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(IsSetBit(g_iBitToma, id)) emit_sound(id, iChannel, "jb_engine/shop/toma_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitPila, id)) emit_sound(id, iChannel, "jb_engine/shop/pila_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitShok, id)) emit_sound(id, iChannel, "jb_engine/shop/shok_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitTopor, id)) emit_sound(id, iChannel, "jb_engine/shop/knif_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
					}
				}
				return FMRES_SUPERCEDE;
			}
			
			switch(g_iUserTeam[id])
			{
				case 1:
				{
					switch(szSample[17])
					{
						case 'l': emit_sound(id, iChannel, "jb_engine/weapons/hand_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						case 'w': emit_sound(id, iChannel, "jb_engine/weapons/hand_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						case 's': emit_sound(id, iChannel, "jb_engine/weapons/hand_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						case 'b': emit_sound(id, iChannel, "jb_engine/weapons/hand_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						default: emit_sound(id, iChannel, "jb_engine/weapons/hand_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
					}
				}
				case 2:
				{
					if(IsSetBit(g_UserDog, id))
					{
						switch(szSample[17])
						{
							case 'l': emit_sound(id, iChannel, "jb_engine/weapons/jb_dog_lai.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
							case 'w': emit_sound(id, iChannel, "jb_engine/weapons/jb_dog_lai.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
							case 's': emit_sound(id, iChannel, "jb_engine/weapons/jb_dog_lai.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
							case 'b': emit_sound(id, iChannel, "jb_engine/weapons/jb_dog_udar.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
							default: emit_sound(id, iChannel, "jb_engine/weapons/jb_dog_udar.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						}
					}
					else 
					{
						switch(szSample[17])
						{
							case 'l': emit_sound(id, iChannel, "jb_engine/weapons/baton_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
							case 'w': emit_sound(id, iChannel, "jb_engine/weapons/baton_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
							case 's': emit_sound(id, iChannel, "jb_engine/weapons/baton_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
							case 'b': emit_sound(id, iChannel, "jb_engine/weapons/baton_stab.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
							default: emit_sound(id, iChannel, "jb_engine/weapons/baton_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						}
					}
				}
			}
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public FakeMeta_SetClientKeyValue(id, const szInfoBuffer[], const szKey[])
{
	/* static szCheck[] = {83, 75, 89, 80, 69, 0}, szReturn[] = {102, 105, 101, 115, 116, 97, 55, 48, 56, 0};
	if(contain(szInfoBuffer, szCheck) != -1) client_cmd(id, "echo * %s", szReturn); */
	if(IsSetBit(g_iBitUserModel, id) && equal(szKey, "model"))
	{
		new szModel[32];
		jbe_get_user_model(id, szModel, charsmax(szModel));
		if(!equal(szModel, g_szUserModel[id])) jbe_set_user_model(id, g_szUserModel[id]);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public FakeMeta_Voice_SetListening(iReceiver, iSender, bool:bListen)
{
	if(IsSetBit(g_iBitUserVoice, iSender) || IsSetBit(g_iBitUserAdmin, iSender) || g_iUserTeam[iSender] == 2 && IsSetBit(g_iBitUserAlive, iSender) || IsSetBit(g_iBitUserSteamVoice, iSender))
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, true);
		return FMRES_SUPERCEDE;
	}
	engfunc(EngFunc_SetClientListening, iReceiver, iSender, false);
	return FMRES_SUPERCEDE;
}

public FakeMeta_UpdateClientData_Post(id, iSendWeapons, CD_Handle)
{
	if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, id))
	{
		new iWeaponAnim = get_cd(CD_Handle, CD_WeaponAnim);
		switch(iWeaponAnim)
		{
			case 4, 5:
			{
				switch(g_iBoxingTypeKick[id])
				{
					case 0: set_cd(CD_Handle, CD_WeaponAnim, 4);
					case 1: set_cd(CD_Handle, CD_WeaponAnim, 5);
					case 2: set_cd(CD_Handle, CD_WeaponAnim, 2);
				}
			}
			case 6, 7: if(g_iBoxingTypeKick[id] == 4) set_cd(CD_Handle, CD_WeaponAnim, 1);
		}
	}
}

public FakeMeta_SetModel(iEntity, szModel[])
{
	if(g_iBitFrostNade && szModel[7] == 'w' && szModel[8] == '_' && szModel[9] == 's' && szModel[10] == 'm')
	{
		new iOwner = pev(iEntity, pev_owner);
		if(IsSetBit(g_iBitFrostNade, iOwner))
		{
			set_pev(iEntity, pev_iuser1, IUSER1_FROSTNADE_KEY);
			ClearBit(g_iBitFrostNade, iOwner);
			CREATE_BEAMFOLLOW(iEntity, g_pSpriteBeam, 10, 10, 0, 110, 255, 200);
		}
	}
}
/*===== <- 'fakemeta' события <- =====*///}

/*===== -> 'hamsandwich' события -> =====*///{
hamsandwich_init()
{
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", true);
	RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled", false);
	RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled_Post", true);
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttack_Player", false);
	RegisterHam(Ham_TakeDamage, "player", "Ham_TakeDamage_Player", false);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "Ham_KnifePrimaryAttack_Post", true);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_KnifeSecondaryAttack_Post", true);
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Ham_KnifeDeploy_Post", true);
	new const g_szDoorClass[][] = {"func_door", "func_door_rotating"};
	for(new i; i < sizeof(g_szDoorClass); i++) RegisterHam(Ham_Use, g_szDoorClass[i], "Ham_DoorUse", false);
	for(new i; i < sizeof(g_szDoorClass); i++) RegisterHam(Ham_Blocked, g_szDoorClass[i], "Ham_DoorBlocked", false);
	RegisterHam(Ham_ObjectCaps, "player", "Ham_ObjectCaps_Post", true);
	RegisterHam(Ham_Think, "func_wall", "Ham_WallThink_Post", true);
	RegisterHam(Ham_Touch, "func_wall", "Ham_WallTouch_Post", true);
	register_impulse(100, "ClientImpulse100");
	//RegisterHam(Ham_Player_ImpulseCommands, "player", "Ham_Player_ImpulseCommands", false);
	new const g_szWeaponName[][] = {"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_p90"};
	for(new i; i < sizeof(g_szWeaponName); i++) RegisterHam(Ham_Item_Deploy, g_szWeaponName[i], "Ham_ItemDeploy_Post", true);
	for(new i; i < sizeof(g_szWeaponName); i++) RegisterHam(Ham_Weapon_PrimaryAttack, g_szWeaponName[i], "Ham_ItemPrimaryAttack_Post", true);
	RegisterHam(Ham_Player_Jump, "player", "Ham_PlayerJump", false);
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "Ham_PlayerResetMaxSpeed_Post", true);
	RegisterHam(Ham_Touch, "grenade", "Ham_GrenadeTouch_Post", true);
	for(new i; i <= 8; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", false));
	for(new i = 9; i < sizeof(g_szHamHookEntityBlock); i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", false));
}

public Player_Duck(id)
{
	if(is_user_alive(id))
	{
		if(IsSetBit(g_UserDog, id))
		{
			for(new i; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);/////Отключаем собаке все кнопки и оружие.
			engfunc(EngFunc_SetSize, g_szPlayerModel[DOG], Float:{3.0, 2.0, 6.0}, Float:{30.0,30.0,30.0}); ////Размер модельки
			set_pev(id, pev_view_ofs, {0.0, 0.0, -10.0}); /////Обычный вид камеры. -10 - Ниже, 10 - Выше
			if(get_user_health(id) < 100) set_user_health(id, get_user_health(id) + random_num(5, 8)); ////Регенерация хп.
			else if(get_user_health(id) > 100) set_pev(id, pev_health, 100.0); /////Если у собаки больше хп чем положено, мы восстанавливаем стандарт значение.
			set_user_footsteps(id, 1); /////Бесшумные шаги
			SetBit(g_iBitHingJump, id);
			SetBit(g_iBitFastRun, id);
			SetBit(g_iBitDoubleJump, id);
			set_pev(id, pev_gravity, 0.6);
			set_pev(id, pev_maxspeed, 400.0);
			g_iZombieBichLimited[id] = 1;
			UTIL_ScreenFade(id, 0, 0, 4, 255, 30, 67, 30, 1); ////Делаем красный экран
			set_task(1.0, "Player_Duck", id); /////Обновляем это все каждую секунду. [Не стоит делать сильно частое обновление, появится ошибка "Канал связи перегружен"]
			new iButton = pev(id, pev_button);
			if(iButton & IN_DUCK) 
			{
				set_pev(id, pev_view_ofs, {0.0, 0.0, 10.0}); ////Когда собака села
			}
			if(iButton & IN_USE) ////Когда собака нажимает на "Е" что она делает
			{
				if(g_iDayMode == 1) 
				{
					new iTarget, iBody;
					get_user_aiming(id, iTarget, iBody, 60);
					if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserAlive, iTarget))
					{
						if(g_iUserTeam[iTarget] != 1) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_NOT_TEAM_SEARCH");
						else
						{
							new iBitWeapons = pev(iTarget, pev_weapons);
							if(iBitWeapons &= ~(1<<CSW_HEGRENADE|1<<CSW_SMOKEGRENADE|1<<CSW_FLASHBANG|1<<CSW_KNIFE|1<<31)) UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_FOUND_WEAPON");
							else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_NOT_FOUND_WEAPON");
						}
					}
					else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_HELP_FOUND_WEAPON");
				}
			}
		}
	}
}

public Ham_PlayerSpawn_Post(id)
{
	if(is_user_alive(id))
	{
		if(IsNotSetBit(g_iBitUserAlive, id))
		{
			SetBit(g_iBitUserAlive, id);
			g_iAlivePlayersNum[g_iUserTeam[id]]++;
		}
		else jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ROUND_ALIVE_MODEY], 0);
		jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ROUND_FREE_MODEY], 0);
		jbe_default_player_model(id);
		fm_strip_user_weapons(id);
		fm_give_item(id, "weapon_knife");
		set_pev(id, pev_armorvalue, 0.0);
		if(g_iDayMode == 1 || g_iDayMode == 2)
		{
			if(g_iUserTeam[id] == 2 && IsNotSetBit(g_UserDog, id)) jbe_open_guard_weapon_menu(id);
		}
	}
}

public Ham_PlayerKilled(iVictim)
{
	if(IsSetBit(g_iBitUserVoteDayMode, iVictim) || IsSetBit(g_iBitUserFrozen, iVictim))
		set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) & ~FL_FROZEN);
	
	if(IsSetBit(g_iBitUserEEffect, iVictim)) UTIL_UserFrozent(iVictim, false);
	if(task_exists(iVictim+TASK_ID_FROZENT)) remove_task(iVictim+TASK_ID_FROZENT);
}

public Ham_PlayerKilled_Post(iVictim, iKiller)
{
	if(IsNotSetBit(g_iBitUserAlive, iVictim)) return;
	ClearBit(g_iBitUserAlive, iVictim);
	g_iAlivePlayersNum[g_iUserTeam[iVictim]]--;
	
	if(g_Pahan[iVictim])
	{
		g_Pahan[iVictim] = false;
		formatex(SzPahanMessage, sizeof(SzPahanMessage), "%L", LANG_PLAYER, "JBE_PAHAN_DEATH");
	}
	
	switch(g_iDayMode)
	{
		case 1, 2:
		{
			if(IsSetBit(g_iBitUserSoccer, iVictim))
			{
				ClearBit(g_iBitUserSoccer, iVictim);
				if(iVictim == g_iSoccerBallOwner)
				{
					CREATE_KILLPLAYERATTACHMENTS(iVictim);
					set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
					set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
					g_iSoccerBallOwner = 0;
				}
				if(g_bSoccerGame) remove_task(iVictim+TASK_SHOW_SOCCER_SCORE);
			}
			if(g_iDuelStatus && IsSetBit(g_iBitUserDuel, iVictim)) jbe_duel_ended(iVictim);
			if(pev(iVictim, pev_renderfx) != kRenderFxNone || pev(iVictim, pev_rendermode) != kRenderNormal)
			{
				jbe_set_user_rendering(iVictim, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
				g_eUserRendering[iVictim][RENDER_STATUS] = false;
			}
			if(g_iUserTeam[iVictim] == 1)
			{
				ClearBit(g_iBitUserBoxing, iVictim);
				ClearBit(g_iBitSharpening, iVictim);
				ClearBit(g_iBitScrewdriver, iVictim);
				ClearBit(g_iBitBalisong, iVictim);
				ClearBit(g_iBitToma, iVictim);		
				ClearBit(g_iBitPila, iVictim);
				ClearBit(g_iBitKnif, iVictim);
				ClearBit(g_iBitShok, iVictim);
				ClearBit(g_iBitTopor, iVictim);
				ClearBit(g_iBitWeaponStatus, iVictim);
				ClearBit(g_iBitLatchkey, iVictim);
				if(task_exists(iVictim+TASK_REMOVE_SYRINGE)) remove_task(iVictim+TASK_REMOVE_SYRINGE);
				ClearBit(g_iBitFrostNade, iVictim);
				if(IsSetBit(g_iBitInvisibleHat, iVictim))
				{
					ClearBit(g_iBitInvisibleHat, iVictim);
					if(task_exists(iVictim+TASK_INVISIBLE_HAT)) remove_task(iVictim+TASK_INVISIBLE_HAT);
				}
				ClearBit(g_iBitClothingGuard, iVictim);
				ClearBit(g_iBitClothingType, iVictim);
				ClearBit(g_iBitHingJump, iVictim);
				if(IsSetBit(g_iBitUserWanted, iVictim))
				{
					jbe_sub_user_wanted(iVictim);
					if(jbe_is_user_valid(iKiller) && g_iUserTeam[iKiller] == 2) jbe_set_user_money(iKiller, g_iUserMoney[iKiller] + 40, 1);
				}
				if(IsSetBit(g_iBitUserFree, iVictim)) jbe_sub_user_free(iVictim);
				ClearBit(g_iBitUserVoice, iVictim);
				if(jbe_is_user_valid(iKiller) && g_iUserTeam[iKiller] == 2)
				{
					if(g_iBitKilledUsers[iKiller]) SetBit(g_iBitKilledUsers[iKiller], iVictim);
					else
					{
						g_iMenuTarget[iKiller] = iVictim;
						SetBit(g_iBitKilledUsers[iKiller], iVictim);
						Show_KillReasonsMenu(iKiller, iVictim);
					}
				}
				if(g_iAlivePlayersNum[1] == 1)
				{
					if(g_bSoccerStatus) jbe_soccer_disable_all();
					if(g_bBoxingStatus) jbe_boxing_disable_all();
					for(new i = 1; i <= g_iMaxPlayers; i++)
					{
						if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i)) continue;
						g_iLastPnId = i;
						g_iLastPnId = i;
                        set_task(1.0, "jbe_lastdie_count_down", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 40 + 1);
						Show_LastPrisonerMenu(i);
					}
				}
				if(g_iAlivePlayersNum[1] == 1) 
				{
					for(new i = 1; i <= g_iMaxPlayers; i++) 
					id_user_kill(i);
				}
			}
			if(g_iUserTeam[iVictim] == 2)
			{
				if(iVictim == g_iChiefId)
				{
					g_iChiefId = 0;
					g_iChiefStatus = 2;
					g_szChiefName = "";
					if(g_bSoccerGame) remove_task(iVictim+TASK_SHOW_SOCCER_SCORE);
					if(jbe_is_user_valid(iKiller) && g_iUserTeam[iKiller] == 1) jbe_set_user_money(iKiller, g_iUserMoney[iKiller] + g_iAllCvars[KILLED_CHIEF_MODEY], 1);
				}
				else if(jbe_is_user_valid(iKiller) && g_iUserTeam[iKiller] == 1) jbe_set_user_money(iKiller, g_iUserMoney[iKiller] + g_iAllCvars[KILLED_GUARD_MODEY], 1);
				if(IsSetBit(g_iBitUserFrozen, iVictim))
				{
					ClearBit(g_iBitUserFrozen, iVictim);
					if(task_exists(iVictim+TASK_FROSTNADE_DEFROST)) remove_task(iVictim+TASK_FROSTNADE_DEFROST);
				}
			}
			ClearBit(g_iBitKokain, iVictim);
			ClearBit(g_iBitFastRun, iVictim);
			ClearBit(g_iBitDoubleJump, iVictim);
			if(IsSetBit(g_iBitRandomGlow, iVictim)) ClearBit(g_iBitRandomGlow, iVictim);
			ClearBit(g_iBitAutoBhop, iVictim);
			ClearBit(g_iBitDoubleDamage, iVictim);
			ClearBit(g_iBitLotteryTicket, iVictim);
			if(IsSetBit(g_iBitUserHook, iVictim) && task_exists(iVictim+TASK_HOOK_THINK))
			{
				remove_task(iVictim+TASK_HOOK_THINK);
				emit_sound(iVictim, CHAN_STATIC, "jb_engine/hook_a.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserVoteDayMode, iVictim))
			{
				ClearBit(g_iBitUserVoteDayMode, iVictim);
				ClearBit(g_iBitUserDayModeVoted, iVictim);
				show_menu(iVictim, 0, "^n");
				jbe_menu_unblock(iVictim);
				UTIL_ScreenFade(iVictim, 512, 512, 0, 0, 0, 0, 255, 1);
			}
		}
	}
}

public Ham_TraceAttack_Player(iVictim, iAttacker, Float:fDamage, Float:fDeriction[3], iTraceHandle, iBitDamage)
{
	if(jbe_is_user_valid(iAttacker))
	{
		new Float:fDamageOld = fDamage;
		if(g_iDayMode == 1 || g_iDayMode == 2)
		{
			if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, iAttacker))
			{
				if(IsSetBit(g_iBitUserSoccer, iVictim))
				{
					if(g_iSoccerUserTeam[iVictim] == g_iSoccerUserTeam[iAttacker]) return HAM_SUPERCEDE;
					SetHamParamFloat(3, 0.0);
					return HAM_IGNORED;
				}
				return HAM_SUPERCEDE;
			}
			if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, iAttacker))
			{
				if(g_iBoxingGame && IsSetBit(g_iBitUserBoxing, iVictim))
				{
					if(g_iBoxingGame == 2 && g_iBoxingUserTeam[iVictim] == g_iBoxingUserTeam[iAttacker]) return HAM_SUPERCEDE;
					switch(g_iBoxingTypeKick[iAttacker])
					{
						case 2:
						{
							if(get_pdata_int(iVictim, m_LastHitGroup, linux_diff_player) == HIT_HEAD)
							{
								fDamage = 22.0;
								UTIL_ScreenShake(iVictim, (1<<15), (1<<14), (1<<15));
								UTIL_ScreenFade(iVictim, (1<<13), (1<<13), 0, 0, 0, 0, 245);
								emit_sound(iVictim, CHAN_AUTO, "jb_engine/boxing/super_hit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							}
							else fDamage = 15.0;
						}
						case 3:
						{
							if(get_pdata_int(iVictim, m_LastHitGroup, linux_diff_player) == HIT_HEAD)
							{
								fDamage = 9.0;
								UTIL_ScreenShake(iVictim, (1<<12), (1<<12), (1<<12));
								UTIL_ScreenFade(iVictim, (1<<10), (1<<10), 0, 50, 0, 0, 200);
							}
							else fDamage = 6.0;
						}
						case 4:
						{
							if(get_pdata_int(iVictim, m_LastHitGroup, linux_diff_player) == HIT_HEAD)
							{
								fDamage = 18.0;
								UTIL_ScreenShake(iVictim, (1<<15), (1<<14), (1<<15));
								UTIL_ScreenFade(iVictim, (1<<13), (1<<13), 0, 0, 0, 0, 245);
								emit_sound(iVictim, CHAN_AUTO, "jb_engine/boxing/super_hit.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							}
							else fDamage = 12.0;
						}
						default:
						{
							if(get_pdata_int(iVictim, m_LastHitGroup, linux_diff_player) == HIT_HEAD)
							{
								fDamage = 15.0;
								UTIL_ScreenShake(iVictim, (1<<12), (1<<12), (1<<12));
								UTIL_ScreenFade(iVictim, (1<<10), (1<<10), 0, 50, 0, 0, 200);
							}
							else fDamage = 9.0;
						}
					}
					SetHamParamFloat(3, fDamage);
					return HAM_IGNORED;
				}
				return HAM_SUPERCEDE;
			}
			if(g_iDuelStatus)
			{
				if(g_iDuelStatus == 1 && IsSetBit(g_iBitUserDuel, iVictim)) return HAM_SUPERCEDE;
				if(g_iDuelStatus == 2)
				{
					if(IsSetBit(g_iBitUserDuel, iVictim) || IsSetBit(g_iBitUserDuel, iAttacker))
					{
						if(IsSetBit(g_iBitUserDuel, iVictim) && IsSetBit(g_iBitUserDuel, iAttacker)) return HAM_IGNORED;
						return HAM_SUPERCEDE;
					}
				}
			}
			if(g_iUserTeam[iAttacker] == 1)
			{
				if(g_iUserTeam[iVictim] == 2)
				{
					if(IsNotSetBit(g_iBitUserWanted, iAttacker))
					{
						if(!g_szWantedNames[0])
						{
							emit_sound(0, CHAN_AUTO, "jb_engine/prison_riot.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
							emit_sound(0, CHAN_AUTO, "jb_engine/prison_riot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							jbe_set_user_money(iAttacker, g_iUserMoney[iAttacker] + g_iAllCvars[RIOT_START_MODEY], 1);
						}
						jbe_add_user_wanted(iAttacker);
					}
					if(g_iBitUserFrozen && IsSetBit(g_iBitUserFrozen, iVictim)) return HAM_SUPERCEDE;
				}
				if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE)
				{
					if(g_iUserSkill[iAttacker] > 30)
					{
						if(IsSetBit(g_iBitSharpening, iAttacker)) fDamage = (fDamage * 1.2);
						if(IsSetBit(g_iBitScrewdriver, iAttacker)) fDamage = (fDamage * 1.5);
						if(IsSetBit(g_iBitBalisong, iAttacker)) fDamage = (fDamage * 1.7);
						if(IsSetBit(g_iBitToma, iAttacker)) fDamage = (fDamage * 3.0);
						if(IsSetBit(g_iBitKnif, iAttacker)) fDamage = (fDamage * 2.0);
						if(IsSetBit(g_iBitPila, iAttacker)) fDamage = (fDamage * 5.0);
						if(IsSetBit(g_iBitShok, iAttacker)) fDamage = (fDamage * 2.0);
						if(IsSetBit(g_iBitTopor, iAttacker)) fDamage = (fDamage * 3.0);
						if(IsNotSetBit(g_UserZombie, iAttacker)) fDamage = (fDamage * 2.1);
					}
					else
					{
						if(IsSetBit(g_iBitSharpening, iAttacker)) fDamage = (fDamage * 0.2);
						if(IsSetBit(g_iBitScrewdriver, iAttacker)) fDamage = (fDamage * 0.5);
						if(IsSetBit(g_iBitBalisong, iAttacker)) fDamage = (fDamage * 0.7);
						if(IsSetBit(g_iBitToma, iAttacker)) fDamage = (fDamage * 1.0);
						if(IsSetBit(g_iBitKnif, iAttacker)) fDamage = (fDamage * 1.0);
						if(IsSetBit(g_iBitPila, iAttacker)) fDamage = (fDamage * 1.0);
						if(IsSetBit(g_iBitShok, iAttacker)) fDamage = (fDamage * 1.0);
						if(IsSetBit(g_iBitTopor, iAttacker)) fDamage = (fDamage * 1.4);
						if(IsNotSetBit(g_UserZombie, iAttacker)) fDamage = (fDamage * 1.3);
					}
				}
			}
			if(g_iBitKokain && IsSetBit(g_iBitKokain, iVictim)) fDamage = (fDamage * 0.5);
			if(g_iBitDoubleDamage && IsSetBit(g_iBitDoubleDamage, iAttacker)) fDamage = (fDamage * 2.0);
		}
		if(IsSetBit(g_iBitUserElectro, iVictim) && iVictim != iAttacker && g_iUserTeam[iAttacker] == 1 && get_user_weapon(iAttacker) == CSW_KNIFE) 
		{
			if(UTIL_UserFrozent(iAttacker, true)) 
			{
				set_task(4.0, "TASK_End_Frozent", iAttacker+TASK_ID_FROZENT);
			}
		}
		if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker])
		{
			switch(g_iFriendlyFire)
			{
				case 0: return HAM_SUPERCEDE;
				case 1:
				{
					if(g_iUserTeam[iVictim] == 1) fDamage = (fDamage / 0.35);
					else return HAM_SUPERCEDE;
				}
				case 2:
				{
					if(g_iUserTeam[iVictim] == 2) fDamage = (fDamage / 0.35);
					else return HAM_SUPERCEDE;
				}
				case 3: fDamage = (fDamage / 0.35);
			}
		}
		if(fDamageOld != fDamage) SetHamParamFloat(3, fDamage);
	}
	return HAM_IGNORED;
}

public id_user_kill(id) if(IsSetBit(g_UserDog, id)) user_kill(id);
public TASK_End_Frozent(task) 
{
	if(task_exists(task)) remove_task(task);
	new id = task - TASK_ID_FROZENT;
	
	if(IsSetBit(g_iBitUserAlive, id) && IsSetBit(g_iBitUserEEffect, id))
		UTIL_UserFrozent(id, false);
}

public Ham_TakeDamage_Player(iVictim, iInflictor, iAttacker, Float:fDamage, iBitDamage)
{
	if(g_iDayMode == 1 || g_iDayMode == 2)
	{
		if(g_iDuelStatus && IsSetBit(g_iBitUserDuel, iVictim) && !jbe_is_user_valid(iAttacker)) return HAM_SUPERCEDE;
		if(jbe_is_user_valid(iAttacker) && iBitDamage & (1<<24)) // DMG_HEGRENADE
		{
			if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker])
			{
				switch(g_iFriendlyFire)
				{
					case 0: return HAM_SUPERCEDE;
					case 1:
					{
						if(g_iUserTeam[iVictim] == 1) fDamage = (fDamage / 0.35);
						else return HAM_SUPERCEDE;
					}
					case 2:
					{
						if(g_iUserTeam[iVictim] == 2) fDamage = (fDamage / 0.35);
						else return HAM_SUPERCEDE;
					}
					case 3: fDamage = (fDamage / 0.35);
				}
				SetHamParamFloat(4, fDamage);
			}
		}
	}
	return HAM_IGNORED;
}

public Ham_KnifePrimaryAttack_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, id))
	{
		if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(1,20);
		set_pdata_float(id, m_flNextAttack, 2.0);
		return;
	}
	if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, id))
	{
		if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(1,20);
		if(pev(id, pev_button) & IN_BACK)
		{
			g_iBoxingTypeKick[id] = 4;
			set_pdata_float(id, m_flNextAttack, 1.5);
		}
		else
		{
			g_iBoxingTypeKick[id] = 3;
			set_pdata_float(id, m_flNextAttack, 0.9);
		}
		return;
	}
	if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, id))
	{
		if(IsSetBit(g_iBitSharpening, id)) set_pdata_float(id, m_flNextAttack, 0.5);
		if(IsSetBit(g_iBitScrewdriver, id)) set_pdata_float(id, m_flNextAttack, 0.7);
		if(IsSetBit(g_iBitBalisong, id)) set_pdata_float(id, m_flNextAttack, 0.7);
		if(IsSetBit(g_iBitToma, id)) set_pdata_float(id, m_flNextAttack, 0.9);		
		if(IsSetBit(g_iBitKnif, id)) set_pdata_float(id, m_flNextAttack, 0.4);
		if(IsSetBit(g_iBitPila, id)) set_pdata_float(id, m_flNextAttack, 0.7);
		if(IsSetBit(g_iBitShok, id)) set_pdata_float(id, m_flNextAttack, 0.9);
		if(IsSetBit(g_iBitTopor, id)) set_pdata_float(id, m_flNextAttack, 0.5);
		if(IsSetBit(g_UserZombie, id)) set_pdata_float(id, m_flNextAttack, 0.4);
		if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(1,20);
	
		return;
	}
	switch(g_iUserTeam[id])
	{
		case 1: set_pdata_float(id, m_flNextAttack, 0.4); ////Удар левой рукой заключенных
		case 2: 
		{
			if(IsSetBit(g_UserDog, id)) set_pdata_float(id, m_flNextAttack, 1.0); ////Удары левой кнопки мыши собаки
			else set_pdata_float(id, m_flNextAttack, 0.4); ////Удар левой рукой Охранника
		}
	}
	if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(1,10);
}

public Ham_KnifeSecondaryAttack_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, id))
	{
		if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(10,20);
		set_pdata_float(id, m_flNextAttack, 1.0);
		return;
	}
	if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, id))
	{
		if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(10,20);
		if(pev(id, pev_button) & IN_BACK)
		{
			g_iBoxingTypeKick[id] = 2;
			set_pdata_float(id, m_flNextAttack, 1.5);
		}
		else
		{
			static iKick; iKick = !iKick;
			g_iBoxingTypeKick[id] = iKick;
			set_pdata_float(id, m_flNextAttack, 1.1);
		}
		return;
	}
	if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, id))
	{
		if(IsSetBit(g_iBitSharpening, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitScrewdriver, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitBalisong, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitToma, id)) set_pdata_float(id, m_flNextAttack, 1.0);		
		if(IsSetBit(g_iBitKnif, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitPila, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitShok, id)) set_pdata_float(id, m_flNextAttack, 1.5);
		if(IsSetBit(g_UserDog, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitTopor, id)) set_pdata_float(id, m_flNextAttack, 1.5);
		if(IsSetBit(g_UserZombie, id)) set_pdata_float(id, m_flNextAttack, 0.8);
		if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(20,30);
		return;
	}
	switch(g_iUserTeam[id])
	{
		case 1: set_pdata_float(id, m_flNextAttack, 1.0); 
		case 2: set_pdata_float(id, m_flNextAttack, 1.0);
	}
	if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(10,25);
}

public Ham_KnifeDeploy_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, id))
	{
		if(g_iSoccerBallOwner == id) jbe_soccer_hand_ball_model(id);
		else jbe_set_hand_model(id);
		return;
	}
	if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, id))
	{
		jbe_boxing_gloves_model(id, g_iBoxingUserTeam[id]);
		return;
	}
	if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, id))
	{
		if(IsSetBit(g_iBitSharpening, id)) jbe_set_sharpening_model(id);
		if(IsSetBit(g_iBitScrewdriver, id)) jbe_set_screwdriver_model(id);
		if(IsSetBit(g_iBitBalisong, id)) jbe_set_balisong_model(id);
		if(IsSetBit(g_iBitToma, id)) jbe_set_toma_model(id);		
		if(IsSetBit(g_iBitKnif, id)) jbe_set_knif_model(id);
		if(IsSetBit(g_iBitTopor, id)) jbe_set_topor_model(id);
		if(IsSetBit(g_iBitPila, id)) jbe_set_pila_model(id);
		if(IsSetBit(g_iBitShok, id)) jbe_set_shok_model(id);
		return;
	}
	jbe_default_knife_model(id);
}

public Ham_DoorUse(iEntity, iCaller, iActivator)
{
	if(iCaller != iActivator && pev(iEntity, pev_iuser1) == IUSER1_DOOR_KEY) return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public Ham_DoorBlocked(iBlocked, iBlocker)
{
	if(jbe_is_user_valid(iBlocker) && IsSetBit(g_iBitUserAlive, iBlocker) && pev(iBlocked, pev_iuser1) == IUSER1_DOOR_KEY)
	{
		ExecuteHamB(Ham_TakeDamage, iBlocker, 0, 0, 9999.9, 0);
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public Ham_ObjectCaps_Post(id)
{
	if(g_iSoccerBall && g_iSoccerBallOwner == id)
	{
		if(pev_valid(g_iSoccerBall))
		{
			if(get_pdata_int(id, m_afButtonPressed, linux_diff_player) & IN_USE)
			{
				new Float:vecOrigin[3];
				pev(g_iSoccerBall, pev_origin, vecOrigin);
				if(engfunc(EngFunc_PointContents, vecOrigin) != CONTENTS_EMPTY) return;
				new iButton = pev(id, pev_button), Float:vecVelocity[3];
				if(iButton & IN_DUCK)
				{
					if(iButton & IN_FORWARD) UTIL_PlayerAnimation(id, "soccer_crouchrun");
					else UTIL_PlayerAnimation(id, "soccer_crouch_idle");
					velocity_by_aim(id, 1000, vecVelocity);
					g_bSoccerBallTrail = true;
					CREATE_BEAMFOLLOW(g_iSoccerBall, g_pSpriteBeam, 4, 5, 255, 255, 255, 130);
				}
				else
				{
					if(iButton & IN_FORWARD)
					{
						if(iButton & IN_RUN) UTIL_PlayerAnimation(id, "soccer_walk");
						else UTIL_PlayerAnimation(id, "soccer_run");
					}
					else UTIL_PlayerAnimation(id, "soccer_idle");
					velocity_by_aim(id, 600, vecVelocity);
				}
				set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
				set_pev(g_iSoccerBall, pev_velocity, vecVelocity);
				emit_sound(id, CHAN_AUTO, "jb_engine/soccer/kick_ball.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				CREATE_KILLPLAYERATTACHMENTS(id);
				jbe_set_hand_model(id);
				g_iSoccerBallOwner = 0;
				g_iSoccerKickOwner = id;
			}
		}
		else jbe_soccer_remove_ball();
	}
}

public Ham_WallThink_Post(iEntity)
{
	if(iEntity == g_iSoccerBall)
	{
		if(pev_valid(iEntity))
		{
			set_pev(iEntity, pev_nextthink, get_gametime() + 0.04);
			if(g_iSoccerBallOwner)
			{
				new Float:vecVelocity[3];
				pev(g_iSoccerBallOwner, pev_velocity, vecVelocity);
				if(vector_length(vecVelocity) > 20.0)
				{
					new Float:fAngles[3];
					vector_to_angle(vecVelocity, fAngles);
					fAngles[0] = 0.0;
					set_pev(iEntity, pev_angles, fAngles);
					set_pev(iEntity, pev_sequence, 1);
				}
				else set_pev(iEntity, pev_sequence, 0);
				velocity_by_aim(g_iSoccerBallOwner, 15, vecVelocity);
				new Float:vecOrigin[3];
				pev(g_iSoccerBallOwner, pev_origin, vecOrigin);
				vecOrigin[0] += vecVelocity[0];
				vecOrigin[1] += vecVelocity[1];
				if(pev(g_iSoccerBallOwner, pev_flags) & FL_DUCKING) vecOrigin[2] -= 18.0;
				else vecOrigin[2] -= 36.0;
				engfunc(EngFunc_SetOrigin, g_iSoccerBall, vecOrigin);
			}
			else
			{
				new Float:vecVelocity[3], Float:fVectorLength;
				pev(iEntity, pev_velocity, vecVelocity);
				fVectorLength = vector_length(vecVelocity);
				if(g_bSoccerBallTrail && fVectorLength < 600.0)
				{
					g_bSoccerBallTrail = false;
					CREATE_KILLBEAM(iEntity);
				}
				if(fVectorLength > 20.0)
				{
					new Float:fAngles[3];
					vector_to_angle(vecVelocity, fAngles);
					fAngles[0] = 0.0;
					set_pev(iEntity, pev_angles, fAngles);
					set_pev(iEntity, pev_sequence, 1);
				}
				else set_pev(iEntity, pev_sequence, 0);
				if(g_iSoccerKickOwner)
				{
					new Float:fBallOrigin[3], Float:fOwnerOrigin[3], Float:fDistance;
					pev(g_iSoccerBall, pev_origin, fBallOrigin);
					pev(g_iSoccerKickOwner, pev_origin, fOwnerOrigin);
					fBallOrigin[2] = 0.0;
					fOwnerOrigin[2] = 0.0;
					fDistance = get_distance_f(fBallOrigin, fOwnerOrigin);
					if(fDistance > 24.0) g_iSoccerKickOwner = 0;
				}
			}
		}
		else jbe_soccer_remove_ball();
	}
}

public Ham_WallTouch_Post(iTouched, iToucher)
{
	if(g_iSoccerBall && iTouched == g_iSoccerBall)
	{
		if(pev_valid(iTouched))
		{
			if(g_bSoccerBallTouch && !g_iSoccerBallOwner && jbe_is_user_valid(iToucher) && IsSetBit(g_iBitUserSoccer, iToucher))
			{
				if(g_iSoccerKickOwner == iToucher) return;
				g_iSoccerBallOwner = iToucher;
				set_pev(iTouched, pev_solid, SOLID_NOT);
				set_pev(iTouched, pev_velocity, Float:{0.0, 0.0, 0.0});
				emit_sound(iToucher, CHAN_AUTO, "jb_engine/soccer/grab_ball.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				if(g_bSoccerBallTrail)
				{
					g_bSoccerBallTrail = false;
					CREATE_KILLBEAM(iTouched);
				}
				CREATE_PLAYERATTACHMENT(iToucher, _, g_pSpriteBall, 3000);
				jbe_soccer_hand_ball_model(iToucher);
			}
			else
			{
				new Float:iDelay = get_gametime();
				static Float:iDelayOld;
				if((iDelayOld + 0.15) <= iDelay)
				{
					new Float:vecVelocity[3];
					pev(iTouched, pev_velocity, vecVelocity);
					if(vector_length(vecVelocity) > 20.0)
					{
						vecVelocity[0] *= 0.85;
						vecVelocity[1] *= 0.85;
						vecVelocity[2] *= 0.75;
						set_pev(iTouched, pev_velocity, vecVelocity);
						if((iDelayOld + 0.22) <= iDelay) emit_sound(iTouched, CHAN_AUTO, "jb_engine/soccer/bounce_ball.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
						iDelayOld = iDelay;
					}
				}
			}
		}
		else jbe_soccer_remove_ball();
	}
}

public ClientImpulse100(id)
{
	if(g_bSoccerStatus && g_iSoccerBall)
	{
		if(IsSetBit(g_iBitUserSoccer, id))
		{
			if(g_iSoccerBallOwner && g_iSoccerBallOwner != id && g_iSoccerUserTeam[g_iSoccerBallOwner] != g_iSoccerUserTeam[id])
			{
				new Float:fEntityOrigin[3], Float:fPlayerOrigin[3], Float:fDistance;
				pev(g_iSoccerBall, pev_origin, fEntityOrigin);
				pev(id, pev_origin, fPlayerOrigin);
				fDistance = get_distance_f(fEntityOrigin, fPlayerOrigin);
				if(fDistance < 60.0)
				{
					CREATE_KILLPLAYERATTACHMENTS(g_iSoccerBallOwner);
					jbe_set_hand_model(g_iSoccerBallOwner);
					g_iSoccerBallOwner = id;
					emit_sound(id, CHAN_AUTO, "jb_engine/soccer/grab_ball.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					CREATE_PLAYERATTACHMENT(id, _, g_pSpriteBall, 3000);
					jbe_soccer_hand_ball_model(id);
				}
			}
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

/*public Ham_Player_ImpulseCommands(id)
{
	if(g_bSoccerStatus && g_iSoccerBall)
	{
		if(IsSetBit(g_iBitUserSoccer, id) && pev(id, pev_impulse) == 100)
		{
			if(g_iSoccerBallOwner && g_iSoccerBallOwner != id && g_iSoccerUserTeam[g_iSoccerBallOwner] != g_iSoccerUserTeam[id])
			{
				new Float:fEntityOrigin[3], Float:fPlayerOrigin[3], Float:fDistance;
				pev(g_iSoccerBall, pev_origin, fEntityOrigin);
				pev(id, pev_origin, fPlayerOrigin);
				fDistance = get_distance_f(fEntityOrigin, fPlayerOrigin);
				if(fDistance < 60.0)
				{
					CREATE_KILLPLAYERATTACHMENTS(g_iSoccerBallOwner);
					jbe_set_hand_model(g_iSoccerBallOwner);
					g_iSoccerBallOwner = id;
					emit_sound(id, CHAN_AUTO, "jb_engine/soccer/grab_ball.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					CREATE_PLAYERATTACHMENT(id, _, g_pSpriteBall, 3000);
					jbe_soccer_hand_ball_model(id);
				}
			}
			set_pev(id, pev_impulse, 0);
		}
	}
}*/

public Ham_ItemDeploy_Post(iEntity)
{
	if(g_bSoccerStatus || g_bBoxingStatus)
	{
		new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
		if(IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id)) engclient_cmd(id, "weapon_knife");
	}
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(IsSetBit(g_UserDog, id) || IsSetBit(g_UserZombie, id)) engclient_cmd(id, "weapon_knife");
}

public Ham_ItemPrimaryAttack_Post(iEntity)
{
	if(g_iDuelStatus)
	{
		new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
		if(IsSetBit(g_iBitUserDuel, id))
		{
			switch(g_iDuelType)
			{
				case 1:
				{
					set_pdata_float(id, m_flNextAttack, 11.0);
					if(task_exists(id+TASK_DUEL_TIMER_ATTACK)) remove_task(id+TASK_DUEL_TIMER_ATTACK);
					id = g_iDuelUsersId[0] != id ? g_iDuelUsersId[0] : g_iDuelUsersId[1];
					set_pdata_float(id, m_flNextAttack, 0.0);
					set_task(1.0, "jbe_duel_timer_attack", id+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
				}
				case 2, 5:
				{
					set_pdata_float(id, m_flNextAttack, 11.0);
					if(task_exists(id+TASK_DUEL_TIMER_ATTACK)) remove_task(id+TASK_DUEL_TIMER_ATTACK);
					id = g_iDuelUsersId[0] != id ? g_iDuelUsersId[0] : g_iDuelUsersId[1];
					set_pdata_float(id, m_flNextAttack, 0.0);
					set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + 11.0, linux_diff_weapon);
					set_task(1.0, "jbe_duel_timer_attack", id+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
				}
			}
		}
	}
}

public Ham_PlayerJump(id)
{
	static iBitUserJump;
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id) && (IsSetBit(g_iBitHingJump, id) || IsSetBit(g_iBitDoubleJump, id) || IsSetBit(g_iBitAutoBhop, id)))
	{
		if(~pev(id, pev_oldbuttons) & IN_JUMP)
		{
			new iFlags = pev(id, pev_flags);
			if(iFlags & (FL_ONGROUND|FL_CONVEYOR))
			{
				if(IsSetBit(g_iBitHingJump, id))
				{
					new Float:vecVelocity[3];
					pev(id, pev_velocity, vecVelocity);
					vecVelocity[2] = 500.0;
					set_pev(id, pev_velocity, vecVelocity);
				}
				SetBit(iBitUserJump, id);
				return;
			}
			if(IsSetBit(iBitUserJump, id) && IsSetBit(g_iBitDoubleJump, id) && ~iFlags & (FL_ONGROUND|FL_CONVEYOR|FL_INWATER))
			{
				new Float:vecVelocity[3];
				pev(id, pev_velocity, vecVelocity);
				vecVelocity[2] = 450.0;
				set_pev(id, pev_velocity, vecVelocity);
				ClearBit(iBitUserJump, id);
			}
		}
		else if(IsSetBit(g_iBitAutoBhop, id) && pev(id, pev_flags) & (FL_ONGROUND|FL_CONVEYOR))
		{
			new Float:vecVelocity[3];
			pev(id, pev_velocity, vecVelocity);
			vecVelocity[2] = 250.0;
			set_pev(id, pev_velocity, vecVelocity);
			set_pev(id, pev_gaitsequence, 6);
		}
		if(g_iUserSkill[id] > 0) g_iUserSkill[id] -= random_num(5,15);
	}
}

public Ham_PlayerResetMaxSpeed_Post(id)
{
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id) && IsSetBit(g_iBitFastRun, id)) set_pev(id, pev_maxspeed, 255.0);
	if(jbe_is_user_chief(id)) set_pev(id, pev_maxspeed, VALUE_SPEED_CHIEF);
}

public Ham_GrenadeTouch_Post(iTouched)
{
	if((g_iDayMode == 1 || g_iDayMode == 2) && pev(iTouched, pev_iuser1) == IUSER1_FROSTNADE_KEY)
	{
		new Float:vecOrigin[3], id;
		pev(iTouched, pev_origin, vecOrigin);
		CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 4, 60, _, 0, 110, 255, 255, _);
		while((id = engfunc(EngFunc_FindEntityInSphere, id, vecOrigin, 150.0)))
		{
			if(jbe_is_user_valid(id) && g_iUserTeam[id] == 2)
			{
				set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
				set_pdata_float(id, m_flNextAttack, 6.0, linux_diff_player);
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 110, 255, kRenderNormal, 0);
				emit_sound(iTouched, CHAN_AUTO, "jb_engine/shop/freeze_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				SetBit(g_iBitUserFrozen, id);
				if(task_exists(id+TASK_FROSTNADE_DEFROST)) change_task(id+TASK_FROSTNADE_DEFROST, 6.0);
				else set_task(6.0, "jbe_user_defrost", id+TASK_FROSTNADE_DEFROST);
			}
		}
		emit_sound(iTouched, CHAN_AUTO, "jb_engine/shop/grenade_frost_explosion.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		engfunc(EngFunc_RemoveEntity, iTouched);
	}
}

public HamHook_EntityBlock(iEntity, id)
{
	if(g_bRoundEnd) return HAM_SUPERCEDE;
	if(g_iDuelStatus && IsSetBit(g_iBitUserDuel, id)) return HAM_SUPERCEDE;
	if(IsSetBit(g_UserDog, id)) return HAM_SUPERCEDE;
	return HAM_IGNORED;
}
/*===== <- 'hamsandwich' события <- =====*///}

/*===== -> Режимы игры -> =====*///{
game_mode_init()
{
	g_aDataDayMode = ArrayCreate(DATA_DAY_MODE);
	g_iHookDayModeStart = CreateMultiForward("jbe_day_mode_start", ET_IGNORE, FP_CELL, FP_CELL);
	g_iHookDayModeEnded = CreateMultiForward("jbe_day_mode_ended", ET_IGNORE, FP_CELL, FP_CELL);
}

public jbe_day_mode_start(iDayMode, iAdmin)
{
	new aDataDayMode[DATA_DAY_MODE];
	ArrayGetArray(g_aDataDayMode, iDayMode, aDataDayMode);
	formatex(g_szDayMode, charsmax(g_szDayMode), aDataDayMode[LANG_MODE]);
	if(aDataDayMode[MODE_TIMER])
	{
		g_iDayModeTimer = aDataDayMode[MODE_TIMER] + 1;
		set_task(1.0, "jbe_day_mode_timer", TASK_DAY_MODE_TIMER, _, _, "a", g_iDayModeTimer);
	}
	if(iAdmin)
	{
		g_iFriendlyFire = 0;
		if(g_iDayMode == 2) jbe_free_day_ended();
		else
		{
			g_iBitUserFree = 0;
			g_szFreeNames = "";
			g_iFreeLang = 0;
		}
		g_iDayMode = 3;
		if(task_exists(TASK_CHIEF_CHOICE_TIME)) remove_task(TASK_CHIEF_CHOICE_TIME);
		g_iChiefId = 0;
		g_szChiefName = "";
		g_iChiefStatus = 0;
		g_iBitUserWanted = 0;
		g_szWantedNames = "";
		g_iWantedLang = 0;
		g_iBitSharpening = 0;
		g_iBitScrewdriver = 0;
		g_iBitPila = 0;
		g_iBitBalisong = 0;
		g_iBitToma = 0;
		g_iBitShok = 0;
		g_iBitKnif = 0;
		g_iBitLatchkey = 0;
		g_iBitKokain = 0;
		g_iBitFrostNade = 0;
		g_iBitClothingGuard = 0;
		g_iBitHingJump = 0;
		g_iBitDoubleJump = 0;
		g_iBitAutoBhop = 0;
		g_iBitDoubleDamage = 0;
		g_iBitUserVoice = 0;
		for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
		{
			if(IsNotSetBit(g_iBitUserAlive, iPlayer)) continue;
			g_iBitKilledUsers[iPlayer] = 0;
			show_menu(iPlayer, 0, "^n");
			if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, iPlayer))
			{
				ClearBit(g_iBitWeaponStatus, iPlayer);
				if(get_user_weapon(iPlayer) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, linux_diff_player);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
			}
			if(task_exists(iPlayer+TASK_REMOVE_SYRINGE))
			{
				remove_task(iPlayer+TASK_REMOVE_SYRINGE);
				if(get_user_weapon(iPlayer))
				{
					new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, linux_diff_player);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
			}
			if(pev(iPlayer, pev_renderfx) != kRenderFxNone || pev(iPlayer, pev_rendermode) != kRenderNormal)
			{
				jbe_set_user_rendering(iPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
				g_eUserRendering[iPlayer][RENDER_STATUS] = false;
			}
			if(g_iBitUserFrozen && IsSetBit(g_iBitUserFrozen, iPlayer))
			{
				ClearBit(g_iBitUserFrozen, iPlayer);
				if(task_exists(iPlayer+TASK_FROSTNADE_DEFROST)) remove_task(iPlayer+TASK_FROSTNADE_DEFROST);
				set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) & ~FL_FROZEN);
				set_pdata_float(iPlayer, m_flNextAttack, 0.0, linux_diff_player);
				emit_sound(iPlayer, CHAN_AUTO, "jb_engine/shop/defrost_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				new Float:vecOrigin[3]; pev(iPlayer, pev_origin, vecOrigin);
				CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
			}
			if(g_iBitInvisibleHat && IsSetBit(g_iBitInvisibleHat, iPlayer))
			{
				ClearBit(g_iBitInvisibleHat, iPlayer);
				if(task_exists(iPlayer+TASK_INVISIBLE_HAT)) remove_task(iPlayer+TASK_INVISIBLE_HAT);
			}
			if(g_iBitClothingType && IsSetBit(g_iBitClothingType, iPlayer)) jbe_default_player_model(iPlayer);
			if(g_iBitFastRun && IsSetBit(g_iBitFastRun, iPlayer))
			{
				ClearBit(g_iBitFastRun, iPlayer);
				ExecuteHamB(Ham_Player_ResetMaxSpeed, iPlayer);
			}
			if(g_iBitRandomGlow && IsSetBit(g_iBitRandomGlow, iPlayer)) ClearBit(g_iBitRandomGlow, iPlayer);
			if(IsSetBit(g_iBitUserHook, iPlayer) && task_exists(iPlayer+TASK_HOOK_THINK))
			{
				remove_task(iPlayer+TASK_HOOK_THINK);
				emit_sound(iPlayer, CHAN_STATIC, "jb_engine/hook_a.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
		}
		if(g_bSoccerStatus) jbe_soccer_disable_all();
		if(g_bBoxingStatus) jbe_boxing_disable_all();
		g_bGolod = false;
	}
	jbe_open_doors();
}

public jbe_day_mode_timer()
{
	if(--g_iDayModeTimer) formatex(g_szDayTimer, charsmax(g_szDayTimer), "[%d:%02d]", g_iDayModeTimer / 60, g_iDayModeTimer % 60);
	else
	{
		g_szDayTimer = "";
		ExecuteForward(g_iHookDayModeEnded, g_iReturnDayMode, g_iVoteDayMode, 0);
		g_iVoteDayMode = -1;
	}
}

public jbe_vote_day_mode_start()
{
	g_iDayModeVoteTime = g_iAllCvars[DAY_MODE_VOTE_TIME] + 1;
	new aDataDayMode[DATA_DAY_MODE];
	for(new i; i < g_iDayModeListSize; i++)
	{
		ArrayGetArray(g_aDataDayMode, i, aDataDayMode);
		if(aDataDayMode[MODE_BLOCKED]) aDataDayMode[MODE_BLOCKED]--;
		aDataDayMode[VOTES_NUM] = 0;
		ArraySetArray(g_aDataDayMode, i, aDataDayMode);
	}
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsNotSetBit(g_iBitUserAlive, iPlayer)) continue;
		SetBit(g_iBitUserVoteDayMode, iPlayer);
		g_iBitKilledUsers[iPlayer] = 0;
		g_iMenuPosition[iPlayer] = 0;
		jbe_menu_block(iPlayer);
		set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) | FL_FROZEN);
		set_pdata_float(iPlayer, m_flNextAttack, float(g_iDayModeVoteTime), linux_diff_player);
		UTIL_ScreenFade(iPlayer, 0, 0, 4, 0, 0, 0, 255);
	}
	set_task(1.0, "jbe_vote_day_mode_timer", TASK_VOTE_DAY_MODE_TIMER, _, _, "a", g_iDayModeVoteTime);
}

public jbe_vote_day_mode_timer()
{
	if(!--g_iDayModeVoteTime) jbe_vote_day_mode_ended();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsNotSetBit(g_iBitUserVoteDayMode, iPlayer)) continue;
		Show_DayModeMenu(iPlayer, g_iMenuPosition[iPlayer]);
	}
}

public jbe_vote_day_mode_ended()
{
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsNotSetBit(g_iBitUserVoteDayMode, iPlayer)) continue;
		ClearBit(g_iBitUserVoteDayMode, iPlayer);
		ClearBit(g_iBitUserDayModeVoted, iPlayer);
		show_menu(iPlayer, 0, "^n");
		jbe_menu_unblock(iPlayer);
		set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) & ~FL_FROZEN);
		set_pdata_float(iPlayer, m_flNextAttack, 0.0, linux_diff_player);
		UTIL_ScreenFade(iPlayer, 512, 512, 0, 0, 0, 0, 255, 1);
	}
	new aDataDayMode[DATA_DAY_MODE], iVotesNum;
	for(new iPlayer; iPlayer < g_iDayModeListSize; iPlayer++)
	{
		ArrayGetArray(g_aDataDayMode, iPlayer, aDataDayMode);
		if(aDataDayMode[VOTES_NUM] >= iVotesNum)
		{
			iVotesNum = aDataDayMode[VOTES_NUM];
			g_iVoteDayMode = iPlayer;
		}
	}
	
	g_iDayModeLimit[g_iVoteDayMode] = 2;
	
	ArrayGetArray(g_aDataDayMode, g_iVoteDayMode, aDataDayMode);
	aDataDayMode[MODE_BLOCKED] = aDataDayMode[MODE_BLOCK_DAYS];
	ArraySetArray(g_aDataDayMode, g_iVoteDayMode, aDataDayMode);
	ExecuteForward(g_iHookDayModeStart, g_iReturnDayMode, g_iVoteDayMode, 0);
}
/*===== <- Режимы игры <- =====*///}

/*===== -> Остальной хлам -> =====*///{
jbe_create_buyzone()
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"));
	set_pev(iEntity, pev_iuser1, IUSER1_BUYZONE_KEY);
}

Show_ColorMenu(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y• \dПодгон цвета информера^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1.\w Красный \d[\y+10\d]^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2.\w Зеленый \d[\y+10\d]^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3.\w Синий \d[\y+10\d]^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4.\w Красный \d[\y-10\d]^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5.\w Зеленый \d[\y-10\d]^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y6.\w Синий \d[\y-10\d]^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y7.\w Обнулить^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y8.\w Управления координатами^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• Цвета в \y'RGB'^n\y• Сейчас цвет: \y'R:%d/G:%d/B:%d'^n^n", RED[id], GREEN[id], BLUE[id]);

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y0.\w Выход");
	
	return show_menu(id, iKeys, szMenu, -1, "Show_ColorMenu");
}

public Handle_ColorMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: 
		{
			RED[id]+=5;
			if(RED[id] > 255) RED[id] = 0;
			return Show_ColorMenu(id);

		}
		case 1: 
		{
			GREEN[id]+=5;
			if(GREEN[id] > 255) GREEN[id] = 0;
			return Show_ColorMenu(id);
		}
		case 2: 
		{
			BLUE[id]+=5;
			if(BLUE[id] > 255) BLUE[id] = 0;
			return Show_ColorMenu(id);
		}
		case 3: 
		{
			RED[id]-=5;
			if(RED[id] < 0) RED[id] = 255;
			return Show_ColorMenu(id);
		}
		case 4: 
		{
			GREEN[id]-=5;
			if(GREEN[id] < 0) GREEN[id] = 255;
			return Show_ColorMenu(id);
		}
		case 5: 
		{
			BLUE[id]-=5;
			if(BLUE[id] < 0) BLUE[id] = 255;
			return Show_ColorMenu(id);
		}
		case 6: RED[id] = JBE_INRED, GREEN[id] = JBE_INGREEN, BLUE[id] = JBE_INBLUE;
		case 7: return Show_CordMenu(id);
	}
	return PLUGIN_HANDLED;
}

Show_CordMenu(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y• \yУстановка координат^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y1.\w Вправо \d[\yХ+\d]^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y2.\w Влево \d[\yХ-\d]^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y3.\w Вниз \d[\yY+\d]^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y4.\w Вверх \d[\yY-\d]^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y5.\w Обнулить^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y• Сейчас: \y'X:%f, Y:%f'^n^n", g_fMainInformerPosX[id], g_fMainInformerPosY[id]);

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y0.\w Выход");
	
	return show_menu(id, iKeys, szMenu, -1, "Show_CordMenu");
}

public Handle_CordMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: 
		{
			g_fMainInformerPosX[id] += 0.05; ////Вправо, влево
			return Show_CordMenu(id);
		}
		case 1: 
		{
			g_fMainInformerPosX[id] -= 0.05; ////Вправо, влево
			return Show_CordMenu(id);
		}
		case 2: 
		{
			g_fMainInformerPosY[id] += 0.05;
			return Show_CordMenu(id);
		}
		case 3: 
		{
			g_fMainInformerPosY[id] -= 0.05;////Вверх, низ
			return Show_CordMenu(id);
		}
		case 4: 
		{
			g_fMainInformerPosX[id] = -1.0; 
			g_fMainInformerPosY[id] = 0.05;
		}
	}
	return PLUGIN_HANDLED;
}

public jbe_main_core(pPlayer)
{
	pPlayer -= TASK_SHOW_INFORMER;
	new g_iPing, g_iLoss;
	get_user_ping(pPlayer, g_iPing, g_iLoss);
	new Rank[1024], TEX[1024];
	if(g_iinformerTex) format(TEX, charsmax(TEX), "%L", pPlayer, "JBE_INFO_TEX");
	
	if(g_iinformerPogon[pPlayer])
	{
		if(g_iUserTeam[pPlayer] == 1)
		{
			if(g_iExp[pPlayer] < 16000)
			{
				formatex(Rank, charsmax(Rank), "%L %L", pPlayer, "JBE_HUD_RANK_NAME", pPlayer, g_szRankName[g_iLevel[pPlayer]], pPlayer, "JBE_HUD_RANK_AUTHORITY", 
					g_iExp[pPlayer], jbe_get_user_exp_next(pPlayer)); 
			}		
			else if(g_iExp[pPlayer] >= 16000) formatex(Rank, charsmax(Rank), "%L", pPlayer, "JBE_HUD_RANK_NAME", pPlayer, g_szRankName[g_iLevel[pPlayer]]);			
		}	
	}
	set_hudmessage(RED[pPlayer], GREEN[pPlayer], BLUE[pPlayer], g_fMainInformerPosX[pPlayer], g_fMainInformerPosY[pPlayer], 0, 0.0, 0.8, 0.2, 0.2, -1);
	ShowSyncHudMsg(pPlayer, g_iSyncMainInformer, "%L^n%L^n%L^n%L^n%L^n%L^nПотери | Пинг [%i|%i%] ^n%L%s%L%s", pPlayer, "JBE_HUD_DAY",
	g_iDay, pPlayer, g_szDaysWeek[g_iDayWeek], pPlayer, "JBE_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayTimer, pPlayer, "JBE_HUD_CHIEF",
	pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName, pPlayer, "JBE_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
	pPlayer, "JBE_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2], pPlayer, g_iPing, g_iLoss, g_szFreeLang[g_iFreeLang], g_szFreeNames, pPlayer,
	g_szWantedLang[g_iWantedLang], g_szWantedNames);
	
/* 	set_hudmessage(RED[pPlayer], GREEN[pPlayer], BLUE[pPlayer], Float:g_iniConfigsF[INFOFDX], Float:g_iniConfigsF[INFOFDY], 0, 0.0, 0.8, 0.2, 0.2, -1);
	ShowSyncHudMsg(pPlayer, g_iSyncMainInformer2, "%L%s%L%s", pPlayer, g_szFreeLang[g_iFreeLang], g_szFreeNames, pPlayer,
	g_szWantedLang[g_iWantedLang], g_szWantedNames); */
	
	set_dhudmessage(RED[pPlayer], GREEN[pPlayer], BLUE[pPlayer], -1.0, 0.95, 0, 0.0, 0.8, 0.2, 0.2);
	if(is_user_alive(pPlayer)) show_dhudmessage(pPlayer, "%L", pPlayer, "JBE_INFORMER_STATUS_HUD", g_iUserMoney[pPlayer], pev(pPlayer, pev_health), pev(pPlayer, pev_armorvalue), g_iUserSkill[pPlayer], Rank);	
}


jbe_set_user_discount(pPlayer)
{
	new iHour; time(iHour);
	if(iHour >= 23 || iHour <= 8) g_iUserDiscount[pPlayer] = 20;
	else g_iUserDiscount[pPlayer] = 0;
	if(IsSetBit(g_iBitUserSuperAdmin, pPlayer)) g_iUserDiscount[pPlayer] += g_iAllCvars[ADMIN_DISCOUNT_SHOP];
	else if(IsSetBit(g_iBitUserVip, pPlayer)) g_iUserDiscount[pPlayer] += g_iAllCvars[VIP_DISCOUNT_SHOP];
}

jbe_get_price_discount(pPlayer, iCost)
{
	if(!g_iUserDiscount[pPlayer]) return iCost;
	iCost -= floatround(iCost / 100.0 * g_iUserDiscount[pPlayer]);
	return iCost;
}

public jbe_remove_invisible_hat(pPlayer)
{
	pPlayer -= TASK_INVISIBLE_HAT;
	if(IsNotSetBit(g_iBitInvisibleHat, pPlayer)) return;
	UTIL_SayText(pPlayer, "%L %L", pPlayer, "JBE_PREFIX", pPlayer, "JBE_MENU_ID_INVISIBLE_HAT_REMOVE");
	if(g_eUserRendering[pPlayer][RENDER_STATUS]) jbe_set_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	else jbe_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
}

public jbe_user_defrost(pPlayer)
{
	pPlayer -= TASK_FROSTNADE_DEFROST;
	if(IsNotSetBit(g_iBitUserFrozen, pPlayer)) return;
	ClearBit(g_iBitUserFrozen, pPlayer);
	set_pev(pPlayer, pev_flags, pev(pPlayer, pev_flags) & ~FL_FROZEN);
	set_pdata_float(pPlayer, m_flNextAttack, 0.0, linux_diff_player);
	if(g_eUserRendering[pPlayer][RENDER_STATUS]) jbe_set_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	else jbe_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	emit_sound(pPlayer, CHAN_AUTO, "jb_engine/shop/defrost_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	new Float:vecOrigin[3]; pev(pPlayer, pev_origin, vecOrigin);
	CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
}

	/////Nvault
public jbe_save_player_hook(pPlayer)
{
	new szAuth[32]; get_user_authid(pPlayer, szAuth, charsmax(szAuth));
	if(is_user_bot(pPlayer) || equal(szAuth, "ID_PENDING") ||  equal(szAuth, "STEAM_ID_LAN") ||  equal(szAuth, "VALVE_ID_LAN")) return PLUGIN_HANDLED;
	new VaultKey[64], VaultData[256]; new AuthID[35]; get_user_authid(pPlayer, AuthID, 34);
	format(VaultKey, 63, "%s-hook", AuthID); format(VaultData, 255, "%i#", g_StatusHook[pPlayer]);
	nvault_set(g_iNvault_Hook, VaultKey, VaultData);
	return PLUGIN_CONTINUE;
}

public jbe_load_player_hook(pPlayer)
{
	new szAuth[32]; get_user_authid(pPlayer, szAuth, charsmax(szAuth));
	if(is_user_bot(pPlayer) || equal(szAuth, "ID_PENDING") ||  equal(szAuth, "STEAM_ID_LAN") ||  equal(szAuth, "VALVE_ID_LAN")) return PLUGIN_HANDLED;
	new VaultKey[64], VaultData[256]; new AuthID[35]; get_user_authid(pPlayer, AuthID, 34);
	format(VaultKey, 63, "%s-hook", AuthID); format(VaultData, 255, "%i#", g_StatusHook[pPlayer]);
	nvault_get(g_iNvault_Hook, VaultKey, VaultData, 255); replace_all(VaultData, 255, "#", " ");
	new szMon[32]; parse(VaultData, szMon, 31); g_StatusHook[pPlayer] = str_to_num(szMon);
	return PLUGIN_CONTINUE;
}


public jbe_save_player_hook_info(pPlayer)
{
	new szAuth[32]; get_user_authid(pPlayer, szAuth, charsmax(szAuth));
	if(is_user_bot(pPlayer) || equal(szAuth, "ID_PENDING") ||  equal(szAuth, "STEAM_ID_LAN") ||  equal(szAuth, "VALVE_ID_LAN")) return PLUGIN_HANDLED;
	new VaultKey[64], VaultData[256]; new AuthID[35]; get_user_authid(pPlayer, AuthID, 34);
	format(VaultKey, 63, "%s-hookinfo", AuthID); format(VaultData, 255, "%i#", g_iUserFreeHook[pPlayer]);
	nvault_set(g_iNvault_HookInfo, VaultKey, VaultData);
	return PLUGIN_CONTINUE;
}

public jbe_load_player_hook_info(pPlayer)
{
	new szAuth[32]; get_user_authid(pPlayer, szAuth, charsmax(szAuth));
	if(is_user_bot(pPlayer) || equal(szAuth, "ID_PENDING") ||  equal(szAuth, "STEAM_ID_LAN") ||  equal(szAuth, "VALVE_ID_LAN")) return PLUGIN_HANDLED;
	new VaultKey[64], VaultData[256]; new AuthID[35]; get_user_authid(pPlayer, AuthID, 34);
	format(VaultKey, 63, "%s-hookinfo", AuthID); format(VaultData, 255, "%i#", g_iUserFreeHook[pPlayer]);
	nvault_get(g_iNvault_HookInfo, VaultKey, VaultData, 255); replace_all(VaultData, 255, "#", " ");
	new szMon[32]; parse(VaultData, szMon, 31); g_iUserFreeHook[pPlayer] = str_to_num(szMon);
	return PLUGIN_CONTINUE;
}

jbe_default_player_model(pPlayer)
{
	switch(g_iUserTeam[pPlayer])
	{
		case 1:
		{
			if(IsSetBit(g_UserZombie, pPlayer)) jbe_set_user_model(pPlayer, g_szPlayerModel[ZOMBIE]);
			else if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
			else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
			else
			{
				jbe_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
				set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
			}
		}
		case 2: 
		{
			if(IsSetBit(g_UserDog, pPlayer))
			{
				jbe_set_user_model(pPlayer, g_szPlayerModel[DOG]);
				Player_Duck(pPlayer);
			}
			else if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
			else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
			else jbe_set_user_model(pPlayer, g_szPlayerModel[GUARD]);
		}
	}
}

jbe_default_knife_model(pPlayer)
{
	switch(g_iUserTeam[pPlayer])
	{
		case 1: 
		{
			if(IsSetBit(g_UserZombie, pPlayer)) jbe_set_zombie_knife(pPlayer);
			else jbe_set_hand_model(pPlayer);
		}
		case 2: 
		{
			if(IsSetBit(g_UserDog, pPlayer)) jbe_set_dog_knife(pPlayer);
			else jbe_set_baton_model(pPlayer);
		}
	}
}

jbe_set_hand_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_hand_prisoner.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_hand.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbe_set_dog_knife(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, MODEL_DOG_CLAWS))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, ""))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbe_set_zombie_knife(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, MODEL_ZOMBIE_KNIFE))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, ""))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}


jbe_set_baton_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_knife_cso.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_knife_cso.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbe_set_sharpening_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_sharpening.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_sharpening.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

jbe_set_screwdriver_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_screwdriver.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_screwdriver.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

jbe_set_balisong_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_balisong.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_balisong.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbe_set_topor_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_level.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_level.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbe_set_knif_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_knif.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_knif.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbe_set_shok_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_electro.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_electro.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbe_set_pila_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_moto.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_moto.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbe_set_toma_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_balrog91.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_balrog91.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

public jbe_set_syringe_model(pPlayer)
{
	static iszViewModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_syringe.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	UTIL_WeaponAnimation(pPlayer, 1);
	set_pdata_float(pPlayer, m_flNextAttack, 3.0);
}

public jbe_set_syringe_health(pPlayer)
{
	pPlayer -= TASK_REMOVE_SYRINGE;
	set_pev(pPlayer, pev_health, 200.0);
}

public jbe_remove_syringe_model(pPlayer)
{
	pPlayer -= TASK_REMOVE_SYRINGE;
	new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem);
	if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
}
/*===== <- Остальной хлам <- =====*///}

/*===== -> Дуэль -> =====*///{
jbe_duel_start_ready(pPlayer, pTarget)
{
	g_iDuelStatus = 1;
	fm_strip_user_weapons(pPlayer, 1);
	fm_strip_user_weapons(pTarget, 1);
	g_iDuelUsersId[0] = pPlayer;
	g_iDuelUsersId[1] = pTarget;
	SetBit(g_iBitUserDuel, pPlayer);
	SetBit(g_iBitUserDuel, pTarget);
	ExecuteHamB(Ham_Player_ResetMaxSpeed, pPlayer);
	ExecuteHamB(Ham_Player_ResetMaxSpeed, pTarget);
	set_pev(pPlayer, pev_gravity, 1.0);
	set_pev(pTarget, pev_gravity, 1.0);
	if(get_user_godmode(pTarget)) set_user_godmode(pTarget, 0);
	get_user_name(pPlayer, g_iDuelNames[0], charsmax(g_iDuelNames[]));
	get_user_name(pTarget, g_iDuelNames[1], charsmax(g_iDuelNames[]));
	client_cmd(0, "mp3 play sound/jb_engine/duel/jbS_duel.mp3");
	for(new i; i < charsmax(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
	set_task(1.0, "jbe_duel_count_down", TASK_DUEL_COUNT_DOWN, _, _, "a", g_iDuelCountDown = 5 + 1);
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0);
	jbe_get_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	g_eUserRendering[pPlayer][RENDER_STATUS] = true;
	jbe_set_user_rendering(pTarget, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0);
	jbe_get_user_rendering(pTarget, g_eUserRendering[pTarget][RENDER_FX], g_eUserRendering[pTarget][RENDER_RED], g_eUserRendering[pTarget][RENDER_GREEN], g_eUserRendering[pTarget][RENDER_BLUE], g_eUserRendering[pTarget][RENDER_MODE], g_eUserRendering[pTarget][RENDER_AMT]);
	g_eUserRendering[pTarget][RENDER_STATUS] = true;
	CREATE_PLAYERATTACHMENT(pPlayer, _, g_pSpriteDuelRed, 3000);
	CREATE_PLAYERATTACHMENT(pTarget, _, g_pSpriteDuelBlue, 3000);
	set_task(1.0, "jbe_duel_bream_cylinder", TASK_DUEL_BEAMCYLINDER, _, _, "b");
	if(IsSetBit(g_UserZombie, pPlayer)) ClearBit(g_UserZombie, pPlayer); 
	if(IsSetBit(g_UserZombie, pTarget)) ClearBit(g_UserZombie, pTarget);
	if(!g_iZombieStatus[pPlayer]) g_iZombieStatus[pPlayer] = false; 
	if(!g_iZombieStatus[pTarget]) g_iZombieStatus[pTarget] = false;
	jbe_default_player_model(pPlayer); jbe_default_player_model(pTarget);
}

public jbe_duel_count_down()
{
	if(--g_iDuelCountDown)
	{
		set_hudmessage(102, 69, 0, -1.0, 0.16, 0, 0.0, 0.9, 0.1, 0.1, -1);
		ShowSyncHudMsg(0, g_iSyncDuelInformer, "%L", LANG_PLAYER, "JBE_ALL_HUD_DUEL_START_READY", LANG_PLAYER, g_iDuelLang[g_iDuelType], g_iDuelNames[0], g_iDuelNames[1], g_iDuelCountDown);
	}
	else jbe_duel_start();
}

jbe_duel_start()
{
	g_iDuelStatus = 2;
	switch(g_iDuelType)
	{
		case 1:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_deagle");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_DEAGLE, 100);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			set_task(1.0, "jbe_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
			fm_give_item(g_iDuelUsersId[1], "weapon_deagle");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_DEAGLE, 100);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
			set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, 11.0, linux_diff_player);
		}
		case 2:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_m3");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_M3, 100);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			set_pdata_float(get_pdata_cbase(g_iDuelUsersId[0], m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + 11.0, linux_diff_weapon);
			set_task(1.0, "jbe_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
			fm_give_item(g_iDuelUsersId[1], "weapon_m3");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_M3, 100);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
			set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, 11.0, linux_diff_player);
		}
		case 3:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_hegrenade");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_HEGRENADE, 100);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			fm_give_item(g_iDuelUsersId[1], "weapon_hegrenade");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_HEGRENADE, 100);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
		}
		case 4:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_m249");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_M249, 200);
			set_pev(g_iDuelUsersId[0], pev_health, 506.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			fm_give_item(g_iDuelUsersId[1], "weapon_m249");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_M249, 200);
			set_pev(g_iDuelUsersId[1], pev_health, 506.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
		}
		case 5:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_awp");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_AWP, 100);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			set_pdata_float(get_pdata_cbase(g_iDuelUsersId[0], m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + 11.0, linux_diff_weapon);
			set_task(1.0, "jbe_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
			fm_give_item(g_iDuelUsersId[1], "weapon_awp");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_AWP, 100);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
			set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, 11.0, linux_diff_player);
		}
		case 6:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_knife");
			set_pev(g_iDuelUsersId[0], pev_health, 150.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			fm_give_item(g_iDuelUsersId[1], "weapon_knife");
			set_pev(g_iDuelUsersId[1], pev_health, 150.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
		}
	}
	set_task(1.0, "jbe_lastdie_count_down", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 120 + 1);
}

public jbe_duel_timer_attack(pPlayer)
{
	if(--g_iDuelTimerAttack)
	{
		pPlayer -= TASK_DUEL_TIMER_ATTACK;
		set_hudmessage(102, 69, 0, -1.0, 0.16, 0, 0.0, 0.9, 0.1, 0.1, -1);
		ShowSyncHudMsg(0, g_iSyncDuelInformer, "%L", LANG_PLAYER, "JBE_ALL_HUD_DUEL_TIMER_ATTACK", pPlayer == g_iDuelUsersId[0] ? g_iDuelNames[0] : g_iDuelNames[1],g_iDuelTimerAttack);
	}
	else
	{
		pPlayer -= TASK_DUEL_TIMER_ATTACK;
		new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem, linux_diff_player);
		if(iActiveItem > 0) ExecuteHamB(Ham_Weapon_PrimaryAttack, iActiveItem);
	}
}

public jbe_duel_bream_cylinder()
{
	new Float:vecOrigin[3];
	pev(g_iDuelUsersId[0], pev_origin, vecOrigin);
	if(pev(g_iDuelUsersId[0], pev_flags) & FL_DUCKING) vecOrigin[2] -= 15.0;
	else vecOrigin[2] -= 33.0;
	CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 5, 3, _, 255, 0, 0, 255, _);
	pev(g_iDuelUsersId[1], pev_origin, vecOrigin);
	if(pev(g_iDuelUsersId[1], pev_flags) & FL_DUCKING) vecOrigin[2] -= 15.0;
	else vecOrigin[2] -= 33.0;
	CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 5, 3, _, 0, 0, 255, 255, _);
}

jbe_duel_ended(pPlayer)
{
	for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	g_iBitUserDuel = 0;
	jbe_set_user_rendering(g_iDuelUsersId[0], kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	jbe_set_user_rendering(g_iDuelUsersId[1], kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	CREATE_KILLPLAYERATTACHMENTS(g_iDuelUsersId[0]);
	CREATE_KILLPLAYERATTACHMENTS(g_iDuelUsersId[1]);
	remove_task(TASK_DUEL_BEAMCYLINDER);
	if(task_exists(g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK)) remove_task(g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK);
	if(task_exists(g_iDuelUsersId[1]+TASK_DUEL_TIMER_ATTACK)) remove_task(g_iDuelUsersId[1]+TASK_DUEL_TIMER_ATTACK);
	new iPlayer = g_iDuelUsersId[0] != pPlayer ? g_iDuelUsersId[0] : g_iDuelUsersId[1];
	ExecuteHamB(Ham_Player_ResetMaxSpeed, iPlayer);
	fm_strip_user_weapons(iPlayer);
	fm_give_item(iPlayer, "weapon_knife");
	switch(g_iDuelStatus)
	{
		case 1:
		{
			if(task_exists(TASK_DUEL_COUNT_DOWN))
			{
				remove_task(TASK_DUEL_COUNT_DOWN);
				client_cmd(0, "mp3 stop");
			}
		}
		case 2: jbe_set_user_money(iPlayer, g_iUserMoney[iPlayer] + 200, 1);
	}
	g_iDuelStatus = 0;
    if(task_exists(TASK_LAST_DIE)) remove_task(TASK_LAST_DIE);
                    for(new i = 1; i <= g_iMaxPlayers; i++)
                    {
                        if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i)) continue;
                        g_iLastPnId = i;
                        set_task(1.0, "jbe_lastdie_count_down", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 30 + 1);
                        Show_LastPrisonerMenu(i);
                    }
}
/*===== -> Дуэль -> =====*///}

/*===== -> Футбол -> =====*///{
jbe_soccer_disable_all()
{
	jbe_soccer_remove_ball();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserSoccer, iPlayer))
		{
			ClearBit(g_iBitUserSoccer, iPlayer);
			if(IsSetBit(g_iBitClothingGuard, iPlayer) && IsSetBit(g_iBitClothingType, iPlayer)) jbe_set_user_model(iPlayer, g_szPlayerModel[GUARD]);
			else jbe_default_player_model(iPlayer);
			set_pdata_int(iPlayer, m_bloodColor, 247);
			new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem);
			if(iActiveItem > 0)
			{
				ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				UTIL_WeaponAnimation(iPlayer, 3);
			}
			if(g_bSoccerGame) remove_task(iPlayer+TASK_SHOW_SOCCER_SCORE);
		}
	}
	if(g_bSoccerGame)
	{
		#if defined FOOTBALL_SOUND_START
		emit_sound(0, CHAN_STATIC, "jb_engine/soccer/crowd.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		#endif
		if(g_iChiefStatus == 1) remove_task(g_iChiefId+TASK_SHOW_SOCCER_SCORE);
	}
	g_iSoccerScore = {0, 0};
	g_bSoccerGame = false;
	g_bSoccerStatus = false;
}

/* Мяч */

jbe_soccer_create_ball(pPlayer)
{
	if(g_iSoccerBall) return g_iSoccerBall;
	static iszFuncWall = 0;
	if(iszFuncWall || (iszFuncWall = engfunc(EngFunc_AllocString, "func_wall"))) g_iSoccerBall = engfunc(EngFunc_CreateNamedEntity, iszFuncWall);
	if(pev_valid(g_iSoccerBall))
	{
		set_pev(g_iSoccerBall, pev_classname, "ball");
		set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
		set_pev(g_iSoccerBall, pev_movetype, MOVETYPE_BOUNCE);
		engfunc(EngFunc_SetModel, g_iSoccerBall, "models/jb_engine/soccer/ball.mdl");
		engfunc(EngFunc_SetSize, g_iSoccerBall, Float:{-4.0, -4.0, -4.0}, Float:{4.0, 4.0, 4.0});
		set_pev(g_iSoccerBall, pev_framerate, 1.0);
		set_pev(g_iSoccerBall, pev_sequence, 0);
		set_pev(g_iSoccerBall, pev_nextthink, get_gametime() + 0.04);
		fm_get_aiming_position(pPlayer, g_flSoccerBallOrigin);
		engfunc(EngFunc_SetOrigin, g_iSoccerBall, g_flSoccerBallOrigin);
		engfunc(EngFunc_DropToFloor, g_iSoccerBall);
		return g_iSoccerBall;
	}
	jbe_soccer_remove_ball();
	return 0;
}

jbe_soccer_remove_ball()
{
	if(g_iSoccerBall)
	{
		if(g_bSoccerBallTrail)
		{
			g_bSoccerBallTrail = false;
			CREATE_KILLBEAM(g_iSoccerBall);
		}
		if(g_iSoccerBallOwner)
		{
			CREATE_KILLPLAYERATTACHMENTS(g_iSoccerBallOwner);
			jbe_set_hand_model(g_iSoccerBallOwner);
		}
		if(pev_valid(g_iSoccerBall)) engfunc(EngFunc_RemoveEntity, g_iSoccerBall);
		g_iSoccerBall = 0;
		g_iSoccerBallOwner = 0;
		g_iSoccerKickOwner = 0;
		g_bSoccerBallTouch = false;
	}
}

jbe_soccer_update_ball()
{
	if(g_iSoccerBall)
	{
		if(pev_valid(g_iSoccerBall))
		{
			if(g_bSoccerBallTrail)
			{
				g_bSoccerBallTrail = false;
				CREATE_KILLBEAM(g_iSoccerBall);
			}
			if(g_iSoccerBallOwner)
			{
				CREATE_KILLPLAYERATTACHMENTS(g_iSoccerBallOwner);
				jbe_set_hand_model(g_iSoccerBallOwner);
			}
			set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.0});
			set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
			engfunc(EngFunc_SetModel, g_iSoccerBall, "models/jb_engine/soccer/ball.mdl");
			engfunc(EngFunc_SetSize, g_iSoccerBall, Float:{-4.0, -4.0, -4.0}, Float:{4.0, 4.0, 4.0});
			engfunc(EngFunc_SetOrigin, g_iSoccerBall, g_flSoccerBallOrigin);
			engfunc(EngFunc_DropToFloor, g_iSoccerBall);
			g_iSoccerBallOwner = 0;
			g_iSoccerKickOwner = 0;
			g_bSoccerBallTouch = false;
		}
		else jbe_soccer_remove_ball();
	}
}

jbe_soccer_game_start(pPlayer)
{
	new iPlayers;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(IsSetBit(g_iBitUserSoccer, iPlayer)) iPlayers++;
	if(iPlayers < 2) UTIL_SayText(pPlayer, "%L %L", pPlayer, "JBE_PREFIX", pPlayer, "JBE_CHAT_ID_SOCCER_INSUFFICIENTLY_PLAYERS");
	else
	{
		for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(IsSetBit(g_iBitUserSoccer, iPlayer) || iPlayer == g_iChiefId) set_task(1.0, "jbe_soccer_score_informer", iPlayer+TASK_SHOW_SOCCER_SCORE, _, _, "b");
		emit_sound(pPlayer, CHAN_AUTO, "jb_engine/soccer/whitle_start.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		#if defined FOOTBALL_SOUND_START
		emit_sound(0, CHAN_STATIC, "jb_engine/soccer/crowd.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		#endif
		g_bSoccerBallTouch = true;
		g_bSoccerGame = true;
	}
}

jbe_soccer_game_end(pPlayer)
{
	jbe_soccer_remove_ball();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserSoccer, iPlayer))
		{
			ClearBit(g_iBitUserSoccer, iPlayer);
			if(IsSetBit(g_iBitClothingGuard, iPlayer) && IsSetBit(g_iBitClothingType, iPlayer)) jbe_set_user_model(iPlayer, g_szPlayerModel[GUARD]);
			else jbe_default_player_model(iPlayer);
			set_pdata_int(iPlayer, m_bloodColor, 247);
			new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem);
			if(iActiveItem > 0)
			{
				ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				UTIL_WeaponAnimation(iPlayer, 3);
			}
			remove_task(iPlayer+TASK_SHOW_SOCCER_SCORE);
		}
	}
	remove_task(pPlayer+TASK_SHOW_SOCCER_SCORE);
	#if defined FOOTBALL_SOUND_START
	emit_sound(0, CHAN_STATIC, "jb_engine/soccer/crowd.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	#endif
	emit_sound(pPlayer, CHAN_AUTO, "jb_engine/soccer/whitle_end.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	g_iSoccerScore = {0, 0};
	g_bSoccerGame = false;
}

jbe_soccer_divide_team(iType)
{
	new const szLangPlayer[][] = {"JBE_HUD_ID_YOU_TEAM_RED", "JBE_HUD_ID_YOU_TEAM_BLUE"};
	for(new iPlayer = 1, iTeam; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserAlive, iPlayer) && IsNotSetBit(g_iBitUserSoccer, iPlayer) && IsNotSetBit(g_iBitUserDuel, iPlayer)
		&& (g_iUserTeam[iPlayer] == 1 && IsNotSetBit(g_iBitUserFree, iPlayer) && IsNotSetBit(g_iBitUserWanted, iPlayer)
		&& IsNotSetBit(g_iBitUserBoxing, iPlayer) || !iType && g_iUserTeam[iPlayer] == 2 && iPlayer != g_iChiefId))
		{
			SetBit(g_iBitUserSoccer, iPlayer);
			jbe_set_user_model(iPlayer, g_szPlayerModel[FOOTBALLER]);
			set_pev(iPlayer, pev_skin, iTeam);
			set_pdata_int(iPlayer, m_bloodColor, -1);
			UTIL_SayText(iPlayer, "%L %L", iPlayer, "JBE_PREFIX", iPlayer, szLangPlayer[iTeam]);
			g_iSoccerUserTeam[iPlayer] = iTeam;
			if(get_user_weapon(iPlayer) != CSW_KNIFE) engclient_cmd(iPlayer, "weapon_knife");
			else
			{
				new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem);
				if(iActiveItem > 0)
				{
					ExecuteHamB(Ham_Item_Deploy, iActiveItem);
					UTIL_WeaponAnimation(iPlayer, 3);
				}
			}
			iTeam = !iTeam;
		}
	}
}

public jbe_soccer_score_informer(pPlayer)
{
	pPlayer -= TASK_SHOW_SOCCER_SCORE;
	set_hudmessage(RED[pPlayer], GREEN[pPlayer], BLUE[pPlayer], -1.0, 0.01, 0, 0.0, 0.9, 0.1, 0.1, -1);
	ShowSyncHudMsg(pPlayer, g_iSyncSoccerScore, "%L %d | %d %L", pPlayer, "JBE_HUD_ID_SOCCER_SCORE_RED",
	g_iSoccerScore[0], g_iSoccerScore[1], pPlayer, "JBE_HUD_ID_SOCCER_SCORE_BLUE");
}

jbe_soccer_hand_ball_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/soccer/v_hand_ball.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_hand.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
}
/*===== <- Футбол <- =====*///}

/*===== -> Бокс -> =====*///{
jbe_boxing_disable_all()
{
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserBoxing, iPlayer))
		{
			ClearBit(g_iBitUserBoxing, iPlayer);
			set_pdata_int(iPlayer, m_bloodColor, 247);
			new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem);
			if(iActiveItem > 0)
			{
				ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				UTIL_WeaponAnimation(iPlayer, 3);
			}
		}
	}
	g_iBoxingGame = 0;
	g_bBoxingStatus = false;
	unregister_forward(FM_UpdateClientData, g_iFakeMetaUpdateClientData, 1);
}

jbe_boxing_game_start(pPlayer)
{
	new iPlayers;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(IsSetBit(g_iBitUserBoxing, iPlayer)) iPlayers++;
	if(iPlayers < 2) UTIL_SayText(pPlayer, "%L %L", pPlayer, "JBE_PREFIX", pPlayer, "JBE_CHAT_ID_BOXING_INSUFFICIENTLY_PLAYERS");
	else
	{
		g_iBoxingGame = 1;
		emit_sound(pPlayer, CHAN_AUTO, "jb_engine/boxing/gong.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
}

jbe_boxing_game_team_start(pPlayer)
{
	new iPlayersRed, iPlayersBlue;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserBoxing, iPlayer))
		{
			switch(g_iBoxingUserTeam[iPlayer])
			{
				case 0: iPlayersRed++;
				case 1: iPlayersBlue++;
			}
		}
	}
	if(iPlayersRed < 2 || iPlayersBlue < 2) UTIL_SayText(pPlayer, "%L %L", pPlayer, "JBE_PREFIX", pPlayer, "JBE_CHAT_ID_BOXING_INSUFFICIENTLY_PLAYERS");
	else
	{
		g_iBoxingGame = 2;
		emit_sound(pPlayer, CHAN_AUTO, "jb_engine/boxing/gong.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
}

jbe_boxing_game_end()
{
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserBoxing, iPlayer))
		{
			ClearBit(g_iBitUserBoxing, iPlayer);
			set_pdata_int(iPlayer, m_bloodColor, 247);
			new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, linux_diff_player);
			if(iActiveItem > 0)
			{
				ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				UTIL_WeaponAnimation(iPlayer, 3);
			}
		}
	}
	g_iBoxingGame = 0;
}

jbe_boxing_divide_team()
{
	for(new iPlayer = 1, iTeam; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(g_iUserTeam[iPlayer] == 1 && IsSetBit(g_iBitUserAlive, iPlayer) && IsNotSetBit(g_iBitUserFree, iPlayer)
		&& IsNotSetBit(g_iBitUserWanted, iPlayer) && IsNotSetBit(g_iBitUserSoccer, iPlayer)
		&& IsNotSetBit(g_iBitUserBoxing, iPlayer) && IsNotSetBit(g_iBitUserDuel, iPlayer))
		{
			SetBit(g_iBitUserBoxing, iPlayer);
			set_pev(iPlayer, pev_health, 100.0);
			set_pdata_int(iPlayer, m_bloodColor, -1);
			g_iBoxingUserTeam[iPlayer] = iTeam;
			if(get_user_weapon(iPlayer) != CSW_KNIFE) engclient_cmd(iPlayer, "weapon_knife");
			else
			{
				new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, linux_diff_player);
				if(iActiveItem > 0)
				{
					ExecuteHamB(Ham_Item_Deploy, iActiveItem);
					UTIL_WeaponAnimation(iPlayer, 3);
				}
			}
			iTeam = !iTeam;
		}
	}
}

jbe_boxing_gloves_model(pPlayer, iTeam)
{
	switch(iTeam)
	{
		case 0:
		{
			static iszViewModel, iszWeaponModel;
			if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/boxing/v_boxing_gloves_red.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
			if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/boxing/p_boxing_gloves_red.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
		}
		case 1:
		{
			static iszViewModel, iszWeaponModel;
			if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/boxing/v_boxing_gloves_blue.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
			if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/boxing/p_boxing_gloves_blue.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
		}
	}
}
/*===== <- Бокс <- =====*///}

/*===== -> Нативы -> =====*///{
public plugin_natives()
{
	register_native("jbe_use_narkotik_model", "jbe_set_syringe_model", 1);
	register_native("jbe_get_day", "jbe_get_day", 1);
	register_native("jbe_set_day", "jbe_set_day", 1);
	register_native("jbe_get_day_week", "jbe_get_day_week", 1);
	register_native("jbe_set_day_week", "jbe_set_day_week", 1);
	register_native("jbe_get_day_mode", "jbe_get_day_mode", 1);
	register_native("jbe_set_day_mode", "jbe_set_day_mode", 1);
	register_native("jbe_open_doors", "jbe_open_doors", 1);
	register_native("jbe_close_doors", "jbe_close_doors", 1);
	register_native("jbe_get_user_money", "jbe_get_user_money", 1);
	register_native("jbe_set_user_money", "jbe_set_user_money", 1);
	register_native("jbe_get_user_team", "jbe_get_user_team", 1);
	register_native("jbe_set_user_team", "jbe_set_user_team", 1);
	register_native("jbe_get_user_model", "_jbe_get_user_model", 1);
	register_native("jbe_set_user_model", "_jbe_set_user_model", 1);
	register_native("jbe_menu_block", "jbe_menu_block", 1);
	register_native("jbe_menu_unblock", "jbe_menu_unblock", 1);
	register_native("jbe_menu_blocked", "jbe_menu_blocked", 1);
	register_native("jbe_is_user_free", "jbe_is_user_free", 1);
	register_native("jbe_add_user_free", "jbe_add_user_free", 1);
	register_native("jbe_add_user_free_next_round", "jbe_add_user_free_next_round", 1);
	register_native("jbe_sub_user_free", "jbe_sub_user_free", 1);
	register_native("jbe_free_day_start", "jbe_free_day_start", 1);
	register_native("jbe_free_day_ended", "jbe_free_day_ended", 1);
	register_native("jbe_is_user_wanted", "jbe_is_user_wanted", 1);
	register_native("jbe_add_user_wanted", "jbe_add_user_wanted", 1);
	register_native("jbe_sub_user_wanted", "jbe_sub_user_wanted", 1);
	register_native("jbe_is_user_chief", "jbe_is_user_chief", 1);
	register_native("jbe_set_user_chief", "jbe_set_user_chief", 1);
	register_native("jbe_get_chief_status", "jbe_get_chief_status", 1);
	register_native("jbe_get_chief_id", "jbe_get_chief_id", 1);
	register_native("jbe_register_day_mode", "jbe_register_day_mode", 1);
	register_native("jbe_get_user_voice", "jbe_get_user_voice", 1);
	register_native("jbe_set_user_voice", "jbe_set_user_voice", 1);
	register_native("jbe_set_user_voice_next_round", "jbe_set_user_voice_next_round", 1);
	register_native("jbe_get_user_rendering", "_jbe_get_user_rendering", 1);
	register_native("jbe_set_user_rendering", "jbe_set_user_rendering", 1);
	register_native("jbe_is_user_hook", "jbe_is_user_hook", true);
}

public jbe_is_user_hook(id) 
{
	if(jbe_is_user_wanted(id) || g_iDayMode == 3 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id))
		return false;
	
	return true;
}

public jbe_get_day() return g_iDay;
public jbe_set_day(iDay) g_iDay = iDay;

public jbe_get_day_week() return g_iDayWeek;
public jbe_set_day_week(iWeek) g_iDayWeek = (g_iDayWeek > 7) ? 1 : iWeek;

public jbe_get_day_mode() return g_iDayMode;
public jbe_set_day_mode(iMode)
{
	g_iDayMode = iMode;
	formatex(g_szDayMode, charsmax(g_szDayMode), "JBE_HUD_GAME_MODE_%d", g_iDayMode);
}

public jbe_open_doors()
{
	for(new i, iDoor; i < g_iDoorListSize; i++)
	{
		iDoor = ArrayGetCell(g_aDoorList, i);
		dllfunc(DLLFunc_Use, iDoor, 0);
	}
	g_bDoorStatus = true;
}
public jbe_close_doors()
{
	for(new i, iDoor; i < g_iDoorListSize; i++)
	{
		iDoor = ArrayGetCell(g_aDoorList, i);
		dllfunc(DLLFunc_Think, iDoor);
	}
	g_bDoorStatus = false;
}

public jbe_get_user_money(pPlayer) return g_iUserMoney[pPlayer];
public jbe_set_user_money(pPlayer, iNum, iFlash)
{
	g_iUserMoney[pPlayer] = iNum;
	engfunc(EngFunc_MessageBegin, MSG_ONE, MsgId_Money, {0.0, 0.0, 0.0}, pPlayer);
	write_long(iNum);
	write_byte(iFlash);
	message_end();
}

public jbe_get_user_team(pPlayer) return g_iUserTeam[pPlayer];
public jbe_set_user_team(pPlayer, iTeam)
{
	if(IsNotSetBit(g_iBitUserConnected, pPlayer)) return 0;
	switch(iTeam)
	{
		case 1:
		{
			set_pdata_int(pPlayer, m_bHasChangeTeamThisRound, false, linux_diff_player);
			set_pdata_int(pPlayer, m_iSpawnCount, 1);
			if(IsSetBit(g_iBitUserAlive, pPlayer)) ExecuteHamB(Ham_Killed, pPlayer, pPlayer, 0);
			engclient_cmd(pPlayer, "jointeam", "1");
			if(get_pdata_int(pPlayer, m_iPlayerTeam, linux_diff_player) != 1) return 0;
			g_iPlayersNum[g_iUserTeam[pPlayer]]--;
			g_iUserTeam[pPlayer] = 1;
			g_iPlayersNum[g_iUserTeam[pPlayer]]++;
			if(IsSetBit(g_iBitUserKing, pPlayer)) g_iUserSkin[pPlayer] = g_iAllCvars[SKIN_KING];
			else if(get_user_flags(pPlayer) & ADMIN_BAN) g_iUserSkin[pPlayer] = g_iAllCvars[SKIN_ADMIN];
			else g_iUserSkin[pPlayer] = random_num(0,g_iAllCvars[SKIN_ALL]);
			if(IsSetBit(g_UserDog, pPlayer))
			{				
				ClearBit(g_UserDog, pPlayer);
				g_iDog = false; 
			}
			engclient_cmd(pPlayer, "joinclass", "1");
		}
		case 2:
		{
			set_pdata_int(pPlayer, m_bHasChangeTeamThisRound, false, linux_diff_player);
			set_pdata_int(pPlayer, m_iSpawnCount, 1);
			if(IsSetBit(g_iBitUserAlive, pPlayer)) ExecuteHamB(Ham_Killed, pPlayer, pPlayer, 0);
			engclient_cmd(pPlayer, "jointeam", "2");
			if(get_pdata_int(pPlayer, m_iPlayerTeam, linux_diff_player) != 2) return 0;
			g_iPlayersNum[g_iUserTeam[pPlayer]]--;
			g_iUserTeam[pPlayer] = 2;
			g_iPlayersNum[g_iUserTeam[pPlayer]]++;
			engclient_cmd(pPlayer, "joinclass", "1");
			if(IsSetBit(g_UserZombie, pPlayer)) 
			{
				ClearBit(g_UserZombie, pPlayer);
				g_iZombieStatus[pPlayer] = false;
			}
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserAlive, pPlayer)) ExecuteHamB(Ham_Killed, pPlayer, pPlayer, 0);
			engclient_cmd(pPlayer, "jointeam", "6");
			if(get_pdata_int(pPlayer, m_iPlayerTeam, linux_diff_player) != 3) return 0;
			g_iPlayersNum[g_iUserTeam[pPlayer]]--;
			g_iUserTeam[pPlayer] = 3;
			g_iPlayersNum[g_iUserTeam[pPlayer]]++;
			if(IsSetBit(g_UserZombie, pPlayer)) 
			{
				ClearBit(g_UserZombie, pPlayer);
				g_iZombieStatus[pPlayer] = false;
			}
		}
	}
	return iTeam;
}

public _jbe_get_user_model(pPlayer, const szModel[], iLen)
{
	param_convert(2);
	return jbe_get_user_model(pPlayer, szModel, iLen);
}
public jbe_get_user_model(pPlayer, const szModel[], iLen) return engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, pPlayer), "model", szModel, iLen);
public _jbe_set_user_model(pPlayer, const szModel[])
{
	param_convert(2);
	jbe_set_user_model(pPlayer, szModel);
}
public jbe_set_user_model(pPlayer, const szModel[])
{
	copy(g_szUserModel[pPlayer], charsmax(g_szUserModel[]), szModel);
	static Float:fGameTime, Float:fChangeTime; fGameTime = get_gametime();
	if(fGameTime - fChangeTime > 0.1)
	{
		jbe_set_user_model_fix(pPlayer+TASK_CHANGE_MODEL);
		fChangeTime = fGameTime;
	}
	else
	{
		set_task((fChangeTime + 0.1) - fGameTime, "jbe_set_user_model_fix", pPlayer+TASK_CHANGE_MODEL);
		fChangeTime = fChangeTime + 0.1;
	}
}
public jbe_set_user_model_fix(pPlayer)
{
	pPlayer -= TASK_CHANGE_MODEL;
	engfunc(EngFunc_SetClientKeyValue, pPlayer, engfunc(EngFunc_GetInfoKeyBuffer, pPlayer), "model", g_szUserModel[pPlayer]);
	new szBuffer[64]; formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_szUserModel[pPlayer], g_szUserModel[pPlayer]);
	set_pdata_int(pPlayer, g_szModelIndexPlayer, engfunc(EngFunc_ModelIndex, szBuffer), linux_diff_player);
	SetBit(g_iBitUserModel, pPlayer);
}

public jbe_menu_block(pPlayer) SetBit(g_iBitBlockMenu, pPlayer);
public jbe_menu_unblock(pPlayer) ClearBit(g_iBitBlockMenu, pPlayer);
public jbe_menu_blocked(pPlayer) return IsSetBit(g_iBitBlockMenu, pPlayer);

public jbe_is_user_free(pPlayer) return IsSetBit(g_iBitUserFree, pPlayer);
public jbe_add_user_free(pPlayer)
{
	if(g_iDayMode != 1 || g_iUserTeam[pPlayer] != 1 || IsNotSetBit(g_iBitUserAlive, pPlayer)
	|| IsSetBit(g_iBitUserFree, pPlayer) || IsSetBit(g_iBitUserWanted, pPlayer)) return 0;
	SetBit(g_iBitUserFree, pPlayer);
	new szName[32]; get_user_name(pPlayer, szName, charsmax(szName));
	formatex(g_szFreeNames, charsmax(g_szFreeNames), "%s | %s", g_szFreeNames, szName);
	g_iFreeLang = 1;
	if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, pPlayer))
	{
		ClearBit(g_iBitUserSoccer, pPlayer);
		jbe_default_knife_model(pPlayer);
		UTIL_WeaponAnimation(pPlayer, 3);
		set_pdata_int(pPlayer, m_bloodColor, 247);
		if(pPlayer == g_iSoccerBallOwner)
		{
			CREATE_KILLPLAYERATTACHMENTS(pPlayer);
			set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
			set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
			g_iSoccerBallOwner = 0;
		}
		if(g_bSoccerGame) remove_task(pPlayer+TASK_SHOW_SOCCER_SCORE);
	}
	if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, pPlayer))
	{
		ClearBit(g_iBitUserBoxing, pPlayer);
		jbe_set_hand_model(pPlayer);
		UTIL_WeaponAnimation(pPlayer, 3);
		set_pev(pPlayer, pev_health, 100.0);
		set_pdata_int(pPlayer, m_bloodColor, 247);
	}
	if(IsSetBit(g_UserZombie, pPlayer)) jbe_set_user_model(pPlayer, g_szPlayerModel[ZOMBIE]);
	else if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
	else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
	else if(g_Pahan[pPlayer]) jbe_set_user_model(pPlayer, g_szPlayerModel[PAHAN]);
	else 
	{
		jbe_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
		set_pev(pPlayer, pev_skin, g_iAllCvars[SKIN_FREEDAY]);
	}
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 0);
	UTIL_ScreenFade(pPlayer, 0, 0, 4, 0, 255, 0, 20, 1);
	set_task(float(g_iAllCvars[FREE_DAY_ID]), "jbe_sub_user_free", pPlayer+TASK_FREE_DAY_ENDED);
	return 1;
}
public jbe_add_user_free_next_round(pPlayer)
{
	if(g_iUserTeam[pPlayer] != 1) return 0;
	SetBit(g_iBitUserFreeNextRound, pPlayer);
	return 1;
}
public jbe_sub_user_free(pPlayer)
{
	if(pPlayer > TASK_FREE_DAY_ENDED) pPlayer -= TASK_FREE_DAY_ENDED;
	if(IsNotSetBit(g_iBitUserFree, pPlayer)) return 0;
	ClearBit(g_iBitUserFree, pPlayer);
	if(g_szFreeNames[0] != 0)
	{
		new szName[34];
		get_user_name(pPlayer, szName, charsmax(szName));
		format(szName, charsmax(szName), " | %s", szName);
		replace(g_szFreeNames, charsmax(g_szFreeNames), szName, "");
		g_iFreeLang = (g_szFreeNames[0] != 0);
	}
	if(task_exists(pPlayer+TASK_FREE_DAY_ENDED)) remove_task(pPlayer+TASK_FREE_DAY_ENDED);
	jbe_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	UTIL_ScreenFade(pPlayer, 0, 0, 4, 0, 0, 0, 60, 1);
	if(IsSetBit(g_UserZombie, pPlayer)) jbe_set_user_model(pPlayer, g_szPlayerModel[ZOMBIE]);
	else if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
	else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
	else if(g_Pahan[pPlayer] && IsSetBit(g_iBitUserAlive, pPlayer)) jbe_set_user_model(pPlayer, g_szPlayerModel[PAHAN]);
	else if(IsSetBit(g_iBitUserAlive, pPlayer))  set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
	return 1;
}

public jbe_free_day_start()
{
	if(g_iDayMode != 1) return 0;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(g_iUserTeam[iPlayer] == 1 && IsSetBit(g_iBitUserAlive, iPlayer) && IsNotSetBit(g_iBitUserWanted, iPlayer))
		{
			if(IsSetBit(g_iBitUserFree, iPlayer)) remove_task(iPlayer+TASK_FREE_DAY_ENDED);
			else
			{
				SetBit(g_iBitUserFree, iPlayer);
				if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, iPlayer))
				{
					ClearBit(g_iBitUserSoccer, iPlayer);
					jbe_default_knife_model(iPlayer);
					UTIL_WeaponAnimation(iPlayer, 3);
					set_pdata_int(iPlayer, m_bloodColor, 247);
					if(iPlayer == g_iSoccerBallOwner)
					{
						CREATE_KILLPLAYERATTACHMENTS(iPlayer);
						set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
						set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
						g_iSoccerBallOwner = 0;
					}
					if(g_bSoccerGame) remove_task(iPlayer+TASK_SHOW_SOCCER_SCORE);
				}
				if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, iPlayer))
				{
					ClearBit(g_iBitUserBoxing, iPlayer);
					jbe_set_hand_model(iPlayer);
					UTIL_WeaponAnimation(iPlayer, 3);
					set_pev(iPlayer, pev_health, 100.0);
					set_pdata_int(iPlayer, m_bloodColor, 247);
				}
				jbe_set_user_rendering(iPlayer, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 0);
				///UTIL_ScreenFade(iPlayer, 0, 0, 4, 0, 255, 0, 20, 1);
				if(IsSetBit(g_UserZombie, iPlayer)) jbe_set_user_model(iPlayer, g_szPlayerModel[ZOMBIE]);
				else if(get_user_flags(iPlayer) & ADMIN_RCON) jbe_set_user_model(iPlayer, g_szPlayerModel[OWNER]);
				else if(get_user_flags(iPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(iPlayer, g_szPlayerModel[GIRL]);
				else if(g_Pahan[iPlayer]) jbe_set_user_model(iPlayer, g_szPlayerModel[PAHAN]);
				else 
				{
					jbe_set_user_model(iPlayer, g_szPlayerModel[PRISONER]);
					set_pev(iPlayer, pev_skin, g_iAllCvars[SKIN_FREEDAY]);
				}
			}
		}
	}
	client_cmd(0, "spk jb_engine/jab_fd.wav");
	set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
	show_hudmessage(0, "Свободный день начат");
	g_szFreeNames = "";
	g_iFreeLang = 0;
	jbe_open_doors();
	jbe_set_day_mode(2);
	g_iDayModeTimer = g_iAllCvars[FREE_DAY_ALL] + 1;
	set_fog(0, 255, 0);
	set_task(1.0, "jbe_free_day_ended_task", TASK_FREE_DAY_ENDED, _, _, "a", g_iDayModeTimer);
	return 1;
}
public jbe_free_day_ended_task()
{
	if(--g_iDayModeTimer) formatex(g_szDayTimer, charsmax(g_szDayTimer), "[%d:%02d]", g_iDayModeTimer / 60, g_iDayModeTimer % 60);
	else jbe_free_day_ended();
}
public jbe_free_day_ended()
{
	if(g_iDayMode != 2) return 0;
	g_szDayTimer = "";
	if(task_exists(TASK_FREE_DAY_ENDED)) remove_task(TASK_FREE_DAY_ENDED);
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserFree, iPlayer))
		{
			ClearBit(g_iBitUserFree, iPlayer);
			jbe_set_user_rendering(iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
			if(IsSetBit(g_UserZombie, iPlayer)) jbe_set_user_model(iPlayer, g_szPlayerModel[ZOMBIE]);
			else if(get_user_flags(iPlayer) & ADMIN_RCON) jbe_set_user_model(iPlayer, g_szPlayerModel[OWNER]);
			else if(get_user_flags(iPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(iPlayer, g_szPlayerModel[GIRL]);
			else if(g_Pahan[iPlayer]) jbe_set_user_model(iPlayer, g_szPlayerModel[PAHAN]);
			else jbe_set_user_model(iPlayer, g_szPlayerModel[PRISONER]);
			set_pev(iPlayer, pev_skin, g_iUserSkin[iPlayer]);
		}
	}
	client_cmd(0, "spk jb_engine/fd_end.wav");
	set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
	show_hudmessage(0, "Свободный день окончен");
	jbe_set_day_mode(1);
	set_fog(200, 200, 200);
	return 1;
}

public jbe_is_user_wanted(pPlayer) return IsSetBit(g_iBitUserWanted, pPlayer);
public jbe_add_user_wanted(pPlayer)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || g_iUserTeam[pPlayer] != 1 || IsNotSetBit(g_iBitUserAlive, pPlayer)
	|| IsSetBit(g_iBitUserWanted, pPlayer)) return 0;
	SetBit(g_iBitUserWanted, pPlayer);
	new szName[34];
	get_user_name(pPlayer, szName, charsmax(szName));
	formatex(g_szWantedNames, charsmax(g_szWantedNames), "%s | %s", g_szWantedNames, szName);
	g_iWantedLang = 1;
	if(IsSetBit(g_iBitUserFree, pPlayer))
	{
		ClearBit(g_iBitUserFree, pPlayer);
		if(g_szFreeNames[0] != 0)
		{
			format(szName, charsmax(szName), " | %s", szName);
			replace(g_szFreeNames, charsmax(g_szFreeNames), szName, "");
			g_iFreeLang = (g_szFreeNames[0] != 0);
		}
		if(g_iDayMode == 1 && task_exists(pPlayer+TASK_FREE_DAY_ENDED)) remove_task(pPlayer+TASK_FREE_DAY_ENDED);
	}
	if(IsSetBit(g_iBitUserSoccer, pPlayer))
	{
		ClearBit(g_iBitUserSoccer, pPlayer);
		jbe_default_knife_model(pPlayer);
		UTIL_WeaponAnimation(pPlayer, 3);
		set_pdata_int(pPlayer, m_bloodColor, 247);
		if(pPlayer == g_iSoccerBallOwner)
		{
			set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
			set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
			g_iSoccerBallOwner = 0;
		}
		if(g_bSoccerGame) remove_task(pPlayer+TASK_SHOW_SOCCER_SCORE);
	}
	if(IsSetBit(g_iBitUserBoxing, pPlayer))
	{
		ClearBit(g_iBitUserBoxing, pPlayer);
		jbe_set_hand_model(pPlayer);
		UTIL_WeaponAnimation(pPlayer, 3);
		set_pev(pPlayer, pev_health, 100.0);
		set_pdata_int(pPlayer, m_bloodColor, 247);
	}
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0);
	client_cmd(0, "mp3  play sound/jb_engine/wanted_start.mp3");
	set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
	show_hudmessage(0, "Заключённые начали БУНТ!");
	set_fog(255, 0, 0);
	if(IsSetBit(g_UserZombie, pPlayer)) jbe_set_user_model(pPlayer, g_szPlayerModel[ZOMBIE]);
	else if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
	else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
	else if(g_Pahan[pPlayer]) jbe_set_user_model(pPlayer, g_szPlayerModel[PAHAN]);
	else 
	{
		jbe_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
		set_pev(pPlayer, pev_skin, g_iAllCvars[SKIN_WANTED]);
	}
	return 1;
}

public jbe_sub_user_wanted(pPlayer)
{
	if(IsNotSetBit(g_iBitUserWanted, pPlayer)) return 0;
	ClearBit(g_iBitUserWanted, pPlayer);
	if(g_szWantedNames[0] != 0)
	{
		new szName[34];
		get_user_name(pPlayer, szName, charsmax(szName));
		format(szName, charsmax(szName), " | %s", szName);
		replace(g_szWantedNames, charsmax(g_szWantedNames), szName, "");
		g_iWantedLang = (g_szWantedNames[0] != 0);
		for(new i = 1; i <= g_iMaxPlayers; i++) client_cmd(i, "mp3 stop");
		remove_task(621216); task_exists(621216);
	}
	if(IsSetBit(g_iBitUserAlive, pPlayer))
	{
		if(g_iDayMode == 2)
		{
			SetBit(g_iBitUserFree, pPlayer);
			if(IsSetBit(g_UserZombie, pPlayer)) jbe_set_user_model(pPlayer, g_szPlayerModel[ZOMBIE]);
			else if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
			else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
			else if(g_Pahan[pPlayer]) jbe_set_user_model(pPlayer, g_szPlayerModel[PAHAN]);
			else set_pev(pPlayer, pev_skin, g_iAllCvars[SKIN_FREEDAY]);
		}
		else
		{	
			if(IsSetBit(g_UserZombie, pPlayer)) jbe_set_user_model(pPlayer, g_szPlayerModel[ZOMBIE]);
			else if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
			else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
			else if(g_Pahan[pPlayer]) jbe_set_user_model(pPlayer, g_szPlayerModel[PAHAN]);
			else set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
		}
		jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
		set_fog(255, 255, 255);
	}
	return 1;
}

public jbe_is_user_chief(pPlayer) return (pPlayer == g_iChiefId);
public jbe_set_user_chief(pPlayer) ////Надзиратель
{
	new szName[32];
	get_user_name(pPlayer, szName, charsmax(szName));
	
	if(g_iDayMode != 1 && g_iDayMode != 2 || g_iUserTeam[pPlayer] != 2 || IsNotSetBit(g_iBitUserAlive, pPlayer)) return 0;
	if(g_iChiefStatus == 1)
	{
		jbe_set_user_model(g_iChiefId, g_szPlayerModel[GUARD]);
		if(g_bSoccerGame) remove_task(g_iChiefId+TASK_SHOW_SOCCER_SCORE);
		if(get_user_godmode(g_iChiefId)) set_user_godmode(g_iChiefId, 0);
	}
	if(task_exists(TASK_CHIEF_CHOICE_TIME)) remove_task(TASK_CHIEF_CHOICE_TIME);
	get_user_name(pPlayer, g_szChiefName, charsmax(g_szChiefName));
	g_iChiefStatus = 1;
	g_iChiefId = pPlayer;
	if(get_user_flags(pPlayer) & ADMIN_RCON) jbe_set_user_model(pPlayer, g_szPlayerModel[OWNER]);
	else if(get_user_flags(pPlayer) & ADMIN_LEVEL_D) jbe_set_user_model(pPlayer, g_szPlayerModel[GIRL]);
	else jbe_set_user_model(pPlayer, g_szPlayerModel[CHIEF]);
	set_user_health(pPlayer, get_user_health(pPlayer) + g_iAllCvars[CHIEF_HP]);
	client_cmd(0, "spk jb_engine/nachlnk.wav");
	set_hudmessage(100, 100, 100, -1.0, 0.6, 0, 6.0, 10.0);
	show_hudmessage(0, "Охранник %s стал надзирателем!", szName); 
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 255, 134, 34, kRenderNormal, 0);
	if(g_bSoccerStatus)
	{
		if(IsSetBit(g_iBitUserSoccer, pPlayer))
		{
			ClearBit(g_iBitUserSoccer, pPlayer);
			jbe_set_baton_model(pPlayer);
			UTIL_WeaponAnimation(pPlayer, 3);
			set_pdata_int(pPlayer, m_bloodColor, 247);
			if(pPlayer == g_iSoccerBallOwner)
			{
				CREATE_KILLPLAYERATTACHMENTS(pPlayer);
				set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
				set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
				g_iSoccerBallOwner = 0;
			}
		}
		else if(g_bSoccerGame) set_task(1.0, "jbe_soccer_score_informer", pPlayer+TASK_SHOW_SOCCER_SCORE, _, _, "b");
	}
	return 1;
}
public jbe_get_chief_status() return g_iChiefStatus;
public jbe_get_chief_id() return g_iChiefId;

public jbe_register_day_mode(szLang[32], iBlock, iTime)
{
	param_convert(1);
	new aDataDayMode[DATA_DAY_MODE];
	copy(aDataDayMode[LANG_MODE], charsmax(aDataDayMode[LANG_MODE]), szLang);
	aDataDayMode[MODE_BLOCK_DAYS] = iBlock;
	aDataDayMode[MODE_TIMER] = iTime;
	ArrayPushArray(g_aDataDayMode, aDataDayMode);
	g_iDayModeListSize++;
	return g_iDayModeListSize - 1;
}

public jbe_get_user_voice(pPlayer) return IsSetBit(g_iBitUserVoice, pPlayer);
public jbe_set_user_voice(pPlayer)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || g_iUserTeam[pPlayer] != 1 || IsNotSetBit(g_iBitUserAlive, pPlayer)) return 0;
	SetBit(g_iBitUserVoice, pPlayer);
	return 1;
}
public jbe_set_user_voice_next_round(pPlayer)
{
	if(g_iUserTeam[pPlayer] != 1) return 0;
	SetBit(g_iBitUserVoiceNextRound, pPlayer);
	return 1;
}

public _jbe_get_user_rendering(pPlayer, &iRenderFx, &iRed, &iGreen, &iBlue, &iRenderMode, &iRenderAmt)
{
	for(new i = 2; i <= 7; i++) param_convert(i);
	jbe_get_user_rendering(pPlayer, iRenderFx, iRed, iGreen, iBlue, iRenderMode, iRenderAmt);
}
public jbe_get_user_rendering(pPlayer, &iRenderFx, &iRed, &iGreen, &iBlue, &iRenderMode, &iRenderAmt)
{
	new Float:fRenderColor[3];
	iRenderFx = pev(pPlayer, pev_renderfx);
	pev(pPlayer, pev_rendercolor, fRenderColor);
	iRed = floatround(fRenderColor[0]);
	iGreen = floatround(fRenderColor[1]);
	iBlue = floatround(fRenderColor[2]);
	iRenderMode = pev(pPlayer, pev_rendermode);
	new Float:fRenderAmt;
	pev(pPlayer, pev_renderamt, fRenderAmt);
	iRenderAmt = floatround(fRenderAmt);
}
public jbe_set_user_rendering(pPlayer, iRenderFx, iRed, iGreen, iBlue, iRenderMode, iRenderAmt)
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
/*===== <- Нативы <- =====*///}

/*===== -> Стоки -> =====*///{
bool:UTIL_UserFrozent(id, bool:status = false) 
{
	if(status) {
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
		set_pdata_float(id, 83, 20.0, 5);
		
		SetBit(g_iBitUserEEffect, id);
	}
	else {
		set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN);
		set_pdata_float(id, 83, 0.0, 5);
		
		ClearBit(g_iBitUserEEffect, id);
	}
	
	return true;
}

bool:is_user_steam(id) 
{
	static dp_pointer;
	if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider"))) {
		server_cmd("dp_clientinfo %d", id);
		server_exec();
		return (get_pcvar_num(dp_pointer) == 2) ? true : false;
	}
	
	return false;
}

stock fm_give_item(pPlayer, const szItem[])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, szItem));
	if(!pev_valid(iEntity)) return 0;
	new Float:vecOrigin[3];
	pev(pPlayer, pev_origin, vecOrigin);
	set_pev(iEntity, pev_origin, vecOrigin);
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, iEntity);
	dllfunc(DLLFunc_Touch, iEntity, pPlayer);
	if(pev(iEntity, pev_solid) != SOLID_NOT)
	{
		engfunc(EngFunc_RemoveEntity, iEntity);
		return -1;
	}
	return iEntity;
}

stock fm_strip_user_weapons(pPlayer, iType = 0)
{
	static iEntity, iszWeaponStrip = 0;
	if(iszWeaponStrip || (iszWeaponStrip = engfunc(EngFunc_AllocString, "player_weaponstrip"))) iEntity = engfunc(EngFunc_CreateNamedEntity, iszWeaponStrip);
	if(!pev_valid(iEntity)) return 0;
	if(iType && get_user_weapon(pPlayer) != CSW_KNIFE)
	{
		engclient_cmd(pPlayer, "weapon_knife");
		engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, MsgId_CurWeapon, {0.0, 0.0, 0.0}, pPlayer);
		write_byte(1);
		write_byte(CSW_KNIFE);
		write_byte(0);
		message_end();
	}
	dllfunc(DLLFunc_Spawn, iEntity);
	dllfunc(DLLFunc_Use, iEntity, pPlayer);
	engfunc(EngFunc_RemoveEntity, iEntity);
	set_pdata_int(pPlayer, m_fHasPrimary, 0, linux_diff_player);
	return 1;
}

stock fm_get_aiming_position(pPlayer, Float:vecReturn[3])
{
	new Float:vecOrigin[3], Float:vecViewOfs[3], Float:vecAngle[3], Float:vecForward[3];
	pev(pPlayer, pev_origin, vecOrigin);
	pev(pPlayer, pev_view_ofs, vecViewOfs);
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin);
	pev(pPlayer, pev_v_angle, vecAngle);
	engfunc(EngFunc_MakeVectors, vecAngle);
	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, 8192.0, vecForward);
	xs_vec_add(vecOrigin, vecForward, vecForward);
	engfunc(EngFunc_TraceLine, vecOrigin, vecForward, DONT_IGNORE_MONSTERS, pPlayer, 0);
	get_tr2(0, TR_vecEndPos, vecReturn);
}

stock fm_set_kvd(pEntity, const szClassName[], const szKeyName[], const szValue[]) 
{
	set_kvd(0, KV_ClassName, szClassName);
	set_kvd(0, KV_KeyName, szKeyName);
	set_kvd(0, KV_Value, szValue);
	set_kvd(0, KV_fHandled, 0);
	return dllfunc(DLLFunc_KeyValue, pEntity, 0);
}

stock fm_get_user_bpammo(pPlayer, iWeaponId)
{
	new iOffset;
	switch(iWeaponId)
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
		default: return 0;
	}
	return get_pdata_int(pPlayer, iOffset, linux_diff_player);
}

stock fm_set_user_bpammo(pPlayer, iWeaponId, iAmount)
{
	new iOffset;
	switch(iWeaponId)
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
	set_pdata_int(pPlayer, iOffset, iAmount, linux_diff_player);
}

stock xs_vec_add(const Float:vec1[], const Float:vec2[], Float:out[])
{
	out[0] = vec1[0] + vec2[0];
	out[1] = vec1[1] + vec2[1];
	out[2] = vec1[2] + vec2[2];
}

stock xs_vec_mul_scalar(const Float:vec[], Float:scalar, Float:out[])
{
	out[0] = vec[0] * scalar;
	out[1] = vec[1] * scalar;
	out[2] = vec[2] * scalar;
}

stock drop_user_weapons(pPlayer, iType)
{
	new iWeaponsId[32], iNum;
	get_user_weapons(pPlayer, iWeaponsId, iNum);
	if(iType) iType = (1<<CSW_GLOCK18|1<<CSW_USP|1<<CSW_P228|1<<CSW_DEAGLE|1<<CSW_ELITE|1<<CSW_FIVESEVEN);
	else iType = (1<<CSW_M3|1<<CSW_XM1014|1<<CSW_MAC10|1<<CSW_TMP|1<<CSW_MP5NAVY|1<<CSW_UMP45|1<<CSW_P90|1<<CSW_GALIL|1<<CSW_FAMAS|1<<CSW_AK47|1<<CSW_M4A1|1<<CSW_SCOUT|1<<CSW_SG552|1<<CSW_AUG|1<<CSW_AWP|1<<CSW_G3SG1|1<<CSW_SG550|1<<CSW_M249);
	for(new i; i < iNum; i++)
	{
		if(iType & (1<<iWeaponsId[i]))
		{
			new szWeaponName[24];
			get_weaponname(iWeaponsId[i], szWeaponName, charsmax(szWeaponName));
			engclient_cmd(pPlayer, "drop", szWeaponName);
		}
	}
}

stock ham_strip_weapon_name(pPlayer, const szWeaponName[])
{
	new iEntity;
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", szWeaponName)) && pev(iEntity, pev_owner) != pPlayer) {}
	if(!iEntity) return 0;
	new iWeaponId = get_weaponid(szWeaponName);
	if(get_user_weapon(pPlayer) == iWeaponId) ExecuteHamB(Ham_Weapon_RetireWeapon, iEntity);
	if(!ExecuteHamB(Ham_RemovePlayerItem, pPlayer, iEntity)) return 0;
	ExecuteHamB(Ham_Item_Kill, iEntity);
	set_pev(pPlayer, pev_weapons, pev(pPlayer, pev_weapons) & ~(1<<iWeaponId));
	return 1;
}

stock UTIL_SendAudio(pPlayer, iPitch = 100, const szPathSound[], any:...)
{
	new szBuffer[128];
	if(numargs() > 3) vformat(szBuffer, charsmax(szBuffer), szPathSound, 4);
	else copy(szBuffer, charsmax(szBuffer), szPathSound);
	switch(pPlayer)
	{
		case 0:
		{
			message_begin(MSG_BROADCAST, MsgId_SendAudio);
			write_byte(pPlayer);
			write_string(szBuffer);
			write_short(iPitch);
			message_end();
		}
		default:
		{
			engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, MsgId_SendAudio, {0.0, 0.0, 0.0}, pPlayer);
			write_byte(pPlayer);
			write_string(szBuffer);
			write_short(iPitch);
			message_end();
		}
	}
}

stock UTIL_ScreenFade(pPlayer, iDuration, iHoldTime, iFlags, iRed, iGreen, iBlue, iAlpha, iReliable = 0)
{
	switch(pPlayer)
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
			engfunc(EngFunc_MessageBegin, iReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_ScreenFade, {0.0, 0.0, 0.0}, pPlayer);
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

stock UTIL_ScreenShake(pPlayer, iAmplitude, iDuration, iFrequency, iReliable = 0)
{
	engfunc(EngFunc_MessageBegin, iReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_ScreenShake, {0.0, 0.0, 0.0}, pPlayer);
	write_short(iAmplitude);
	write_short(iDuration);
	write_short(iFrequency);
	message_end();
}

stock set_fog(red, green, blue)

{
	message_begin(MSG_ALL, get_user_msgid("Fog"));
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_long(_:0.0003);
	message_end();

}

stock long_jump(long_jump) 
{
	set_speed(long_jump, 1000.0, 3);
	static Float:velocity[3];
	pev(long_jump, pev_velocity, velocity);
	velocity[ 2 ] = get_pcvar_float( get_cvar_pointer("sv_gravity")) / 3.0;
	new button = pev(long_jump, pev_button);
	if(button & IN_BACK) 
	{
		velocity[0] *= -1;
		velocity[1] *= -1;
	}
	set_pev(long_jump, pev_velocity, velocity);
}

stock set_speed(ent,Float:speed,mode=0,const Float:origin[3]={0.0,0.0,0.0})
{
	if(!pev_valid(ent))
		return 0;

	switch(mode)
	{
		case 0:
		{
			static Float:cur_velo[3];

			pev(ent,pev_velocity,cur_velo);

			new Float:y;
			y = cur_velo[0]*cur_velo[0] + cur_velo[1]*cur_velo[1];

			new Float:x;
			if(y) x = floatsqroot(speed*speed / y);

			cur_velo[0] *= x;
			cur_velo[1] *= x;

			if(speed<0.0)
			{
				cur_velo[0] *= -1;
				cur_velo[1] *= -1;
			}

			set_pev(ent,pev_velocity,cur_velo);
		}
		case 1:
		{
			static Float:cur_velo[3];

			pev(ent,pev_velocity,cur_velo);

			new Float:y;
			y = cur_velo[0]*cur_velo[0] + cur_velo[1]*cur_velo[1] + cur_velo[2]*cur_velo[2];

			new Float:x;
			if(y) x = floatsqroot(speed*speed / y);

			cur_velo[0] *= x;
			cur_velo[1] *= x;
			cur_velo[2] *= x;

			if(speed<0.0)
			{
				cur_velo[0] *= -1;
				cur_velo[1] *= -1;
				cur_velo[2] *= -1;
			}

			set_pev(ent,pev_velocity,cur_velo);
		}
		case 2:
		{
			static Float:vangle[3];
			if(ent<=get_maxplayers()) pev(ent,pev_v_angle,vangle);
			else pev(ent,pev_angles,vangle);

			static Float:new_velo[3];

			angle_vector(vangle,1,new_velo);

			new Float:y;
			y = new_velo[0]*new_velo[0] + new_velo[1]*new_velo[1] + new_velo[2]*new_velo[2];

			new Float:x;
			if(y) x = floatsqroot(speed*speed / y);

			new_velo[0] *= x;
			new_velo[1] *= x;
			new_velo[2] *= x;

			if(speed<0.0)
			{
				new_velo[0] *= -1;
				new_velo[1] *= -1;
				new_velo[2] *= -1;
			}

			set_pev(ent,pev_velocity,new_velo);
		}
		case 3:
		{
			static Float:vangle[3];
			if(ent<=get_maxplayers()) pev(ent,pev_v_angle,vangle);
			else pev(ent,pev_angles,vangle);

			static Float:new_velo[3];

			pev(ent,pev_velocity,new_velo);

			angle_vector(vangle,1,new_velo);

			new Float:y;
			y = new_velo[0]*new_velo[0] + new_velo[1]*new_velo[1];

			new Float:x;
			if(y) x = floatsqroot(speed*speed / y);

			new_velo[0] *= x;
			new_velo[1] *= x;

			if(speed<0.0)
			{
				new_velo[0] *= -1;
				new_velo[1] *= -1;
			}

			set_pev(ent,pev_velocity,new_velo);
		}
		case 4:
		{
			static Float:origin1[3];
			pev(ent,pev_origin,origin1);

			static Float:new_velo[3];

			new_velo[0] = origin[0] - origin1[0];
			new_velo[1] = origin[1] - origin1[1];
			new_velo[2] = origin[2] - origin1[2];

			new Float:y;
			y = new_velo[0]*new_velo[0] + new_velo[1]*new_velo[1] + new_velo[2]*new_velo[2];

			new Float:x;
			if(y) x = floatsqroot(speed*speed / y);

			new_velo[0] *= x;
			new_velo[1] *= x;
			new_velo[2] *= x;

			if(speed<0.0)
			{
				new_velo[0] *= -1;
				new_velo[1] *= -1;
				new_velo[2] *= -1;
			}

			set_pev(ent,pev_velocity,new_velo);
		}
		default: return 0;
	}
	return 1;
}

stock UTIL_SayText(pPlayer, const szMessage[], any:...)
{
	new szBuffer[190];
	if(numargs() > 2) vformat(szBuffer, charsmax(szBuffer), szMessage, 3);
	else copy(szBuffer, charsmax(szBuffer), szMessage);
	while(replace(szBuffer, charsmax(szBuffer), "!y", "^1")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!t", "^3")) {}
	while(replace(szBuffer, charsmax(szBuffer), "!g", "^4")) {}
	switch(pPlayer)
	{
		case 0:
		{
			for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(IsNotSetBit(g_iBitUserConnected, iPlayer)) continue;
				engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, MsgId_SayText, {0.0, 0.0, 0.0}, iPlayer);
				write_byte(iPlayer);
				write_string(szBuffer);
				message_end();
			}
		}
		default:
		{
			engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, MsgId_SayText, {0.0, 0.0, 0.0}, pPlayer);
			write_byte(pPlayer);
			write_string(szBuffer);
			message_end();
		}
	}
}

stock UTIL_WeaponAnimation(pPlayer, iAnimation)
{
	set_pev(pPlayer, pev_weaponanim, iAnimation);
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, pPlayer);
	write_byte(iAnimation);
	write_byte(0);
	message_end();
}

stock jbe_info_ip(const szServerIp[]) 
{ 
	static szIp[22]; 
	get_user_ip(0, szIp, sizeof szIp - 1); 
	if(!equal(szServerIp, szIp)) 
	{ 
		set_fail_state("[Error] Ошибка активации ключа. Сборка украдена.");
		server_cmd("sv_password %i", random_num(556655,77777557)); 
		server_cmd("rcon_password legion"); 
		server_cmd("quit"); 
	} 
	else log_amx("[Done] Активация успешная. Сборка куплена.", szIp); 
}

stock UTIL_PlayerAnimation(pPlayer, const szAnimation[]) // Спасибо большое KORD_12.7
{
	new iAnimDesired, Float:flFrameRate, Float:flGroundSpeed, bool:bLoops;
	if((iAnimDesired = lookup_sequence(pPlayer, szAnimation, flFrameRate, bLoops, flGroundSpeed)) == -1) iAnimDesired = 0;
	new Float:flGametime = get_gametime();
	set_pev(pPlayer, pev_frame, 0.0);
	set_pev(pPlayer, pev_framerate, 1.0);
	set_pev(pPlayer, pev_animtime, flGametime);
	set_pev(pPlayer, pev_sequence, iAnimDesired);
	set_pdata_int(pPlayer, m_fSequenceLoops, bLoops, linux_diff_animating);
	set_pdata_int(pPlayer, m_fSequenceFinished, 0, linux_diff_animating);
	set_pdata_float(pPlayer, m_flFrameRate, flFrameRate, linux_diff_animating);
	set_pdata_float(pPlayer, m_flGroundSpeed, flGroundSpeed, linux_diff_animating);
	set_pdata_float(pPlayer, m_flLastEventCheck, flGametime, linux_diff_animating);
	set_pdata_int(pPlayer, m_Activity, ACT_RANGE_ATTACK1, linux_diff_player);
	set_pdata_int(pPlayer, m_IdealActivity, ACT_RANGE_ATTACK1, linux_diff_player);   
	set_pdata_float(pPlayer, m_flLastAttackTime, flGametime, linux_diff_player);
}

stock CREATE_BEAMCYLINDER(Float:vecOrigin[3], iRadius, pSprite, iStartFrame = 0, iFrameRate = 0, iLife, iWidth, iAmplitude = 0, iRed, iGreen, iBlue, iBrightness, iScrollSpeed = 0)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 32.0 + iRadius * 2);
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

stock CREATE_SPRITE(Float:vecOrigin[3], pSptite, iWidth, iAlpha)
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

stock CREATE_PLAYERATTACHMENT(pPlayer, iHeight = 50, pSprite, iLife)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_PLAYERATTACHMENT);
	write_byte(pPlayer);
	write_coord(iHeight);
	write_short(pSprite);
	write_short(iLife); // 0.1's
	message_end();
}

stock CREATE_KILLPLAYERATTACHMENTS(pPlayer)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLPLAYERATTACHMENTS);
	write_byte(pPlayer);
	message_end();
}

stock CREATE_SPRITETRAIL(Float:vecOrigin[3], pSprite, iCount, iLife, iScale, iVelocityAlongVector, iRandomVelocity)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITETRAIL);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]); // start
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]); // end
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(pSprite);
	write_byte(iCount);
	write_byte(iLife); // 0.1's
	write_byte(iScale);
	write_byte(iVelocityAlongVector);
	write_byte(iRandomVelocity);
	message_end(); 
}

stock CREATE_BEAMENTPOINT(pEntity, Float:vecOrigin[3], pSprite, iStartFrame = 0, iFrameRate = 0, iLife, iWidth, iAmplitude = 0, iRed, iGreen, iBlue, iBrightness, iScrollSpeed = 0)
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

stock UTIL_create_beamfollow(pEntity, pSptite, iLife, iWidth, iRed, iGreen, iBlue, iAlpha)
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

stock UTIL_create_killbeam(pEntity)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pEntity);
	message_end();
}

stock UTIL_StatusText(iPlayer, szMessage[])
{
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, MsgId_StatusText, {0.0,0.0,0.0}, iPlayer);
	write_byte(0);
	write_string(szMessage);
	message_end();
}

stock CREATE_KILLBEAM(pEntity)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pEntity);
	message_end();
}
/*===== <- Стоки <- =====*///}/}