#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <engine>
#include <hamsandwich>
#include <sqlx>
#include <dhudmessage>
#include <cstrike>

#pragma semicolon 1


/*-------------- БАЗА ДАННЫХ --------------*/
//#define IP_LOGER
#if defined IP_LOGER

	#define IP_LOCK		"176.111.61.78:27024" // Здесь писать ип сервера, т.к стоит привязка по ип!
	
#endif

#define BD_HOST		"cs40.csserv.ru" 
#define BD_USER		"27115" 
#define BD_PASS		"J4cFzxxCic2"
#define BD_DATBAS	"27115"

#define BD_TABLE	"admins"

#define ADDON_CREDITS
//#define SOUND_BONUS
/*----------/ Нативы /----------*/
//native ujbl_open_class_ct_menu(id);

//native ujbl_set_user_bonus(id, iNum);
//native ujbl_get_user_bonus(id);

//native ujbl_get_protection_skills(id);
//native ujbl_get_agility_skills(id);
//native ujbl_get_lot_skills(id);

//native jbe_open_skills_menu(id);
//native Open_DrugsMenu(id);
//native ujbl_open_gang_menu(id);

native jbe_roleplay(id);

//native give_buffak(id);
//native give_buffm4(id);

/*===== -> Макросы -> =====*///{

#define TOTAL_PLAYER_LEVELS 	16
#define jbe_is_user_valid(%0) (%0 && %0 <= g_iMaxPlayers)
#define MAX_PLAYERS 32

#define IUSER1_DOOR_KEY 		376027
#define IUSER1_BUYZONE_KEY 		140658
#define IUSER1_FROSTNADE_KEY 	235876

/* -> Бит сумм -> */
#define SetBit(%0,%1) 				(	(%0) |= 	(1 << (%1)))
#define ClearBit(%0,%1) 			(	(%0) &= 	~(1 << (%1)))
#define IsSetBit(%0,%1) 			(	(%0) & 		(1 << (%1)))
#define InvertBit(%0,%1) 			(	(%0) ^= 	(1 << (%1)))
#define IsNotSetBit(%0,%1) 			(	~(%0) & 	(1 << (%1)))

/* -> Оффсеты -> */
#define linux_diff_weapon 			4
#define linux_diff_animating 		4
#define linux_diff_player 			5
#define ACT_RANGE_ATTACK1 			28
#define m_flFrameRate 				36
#define m_flGroundSpeed 			37
#define m_flLastEventCheck 			38
#define m_fSequenceFinished 		39
#define m_fSequenceLoops 			40
#define m_pPlayer 					41
#define m_flNextSecondaryAttack 	47
#define m_iClip 					51
#define m_Activity 					73
#define m_IdealActivity 			74
#define m_LastHitGroup 				75
#define m_flNextAttack 				83
#define m_bloodColor 				89
#define m_iPlayerTeam 				114
#define m_fHasPrimary 				116
#define m_bHasChangeTeamThisRound 	125
#define m_flLastAttackTime 			220
#define m_afButtonPressed 			246
#define m_iHideHUD 					361
#define m_iClientHideHUD 			362
#define m_iSpawnCount 				365
#define m_pActiveItem 				373
#define m_flNextDecalTime 			486
#define g_szModelIndexPlayer 		491

/* -> Задачи -> */
#define TASK_ROUND_END 				210912
#define TASK_CHANGE_MODEL 			310924
#define TASK_SHOW_INFORMER 			510935
#define TASK_FREE_DAY_ENDED 		610946
#define TASK_CHIEF_CHOICE_TIME 		710957
#define TASK_COUNT_DOWN_TIMER 		110968
#define TASK_VOTE_DAY_MODE_TIMER 	510979
#define TASK_RESTART_GAME_TIMER 	210980
#define TASK_DAY_MODE_TIMER 		410991
#define TASK_SHOW_SOCCER_SCORE 		111002
#define TASK_INVISIBLE_HAT 			511014
#define TASK_REMOVE_SYRINGE 		801025
#define TASK_FROSTNADE_DEFROST 		901036
#define TASK_DUEL_COUNT_DOWN 		811041
#define TASK_DUEL_BEAMCYLINDER 		811052
#define TASK_DUEL_TIMER_ATTACK 		911066
#define TASK_HOOK_THINK 			611075
#define TASK_RANK_UPDATE_EXP 		511082
#define TASK_RANK_UPDATE_UNVALID 	411094
#define TASK_RANK_REWARD_EXP 		311101
#define TASK_MEDSIS_HEALTHGIVE 		211114
#define TASK_QUEST					111124

/* -> Индексы сообщений -> */
#define MsgId_CurWeapon 			66
#define MsgId_SayText 				76
#define MsgId_TextMsg 				77
#define MsgId_ResetHUD 				79
#define MsgId_ShowMenu 				96
#define MsgId_ScreenShake 			97
#define MsgId_ScreenFade 			98
#define MsgId_SendAudio 			100
#define MsgId_Money 				102
#define MsgId_StatusText 			106
#define MsgId_VGUIMenu 				114
#define MsgId_ClCorpse 				122
#define MsgId_HudTextArgs 			145

/* -> Индексы моделей -> */
#define PRISONER 	0
#define GUARD 		1
#define CHIEF 		2
#define FOOTBALLER 	3

/* -> Индексы предметов магазина для кваров -> */
#define SHARPENING 			0
#define SCREWDRIVER 		1
#define BALISONG 			2
#define GLOCK18 			3
#define USP 				4
#define DEAGLE 				5
#define LATCHKEY 			6
#define FLASHBANG 			7
#define KOKAIN 				8
#define STIMULATOR 			9
#define FROSTNADE 			10
#define INVISIBLE_HAT 		11
#define ARMOR 				12
#define CLOTHING_GUARD 		13
#define HEGRENADE 			14
#define HING_JUMP 			15
#define FAST_RUN 			16
#define DOUBLE_JUMP 		17
#define RANDOM_GLOW 		18
#define AUTO_BHOP 			19
#define DOUBLE_DAMAGE 		20
#define LOW_GRAVITY 		21
#define CLOSE_CASE 			22
#define FREE_DAY_SHOP 		23
#define RESOLUTION_VOICE 	24
#define TRANSFER_GUARD 		25
#define LOTTERY_TICKET 		26
#define PRANK_PRISONER 		27
#define STIMULATOR_GR 		28
#define RANDOM_GLOW_GR 		29
#define LOTTERY_TICKET_GR 	30
#define KOKAIN_GR 			31
#define DOUBLE_JUMP_GR 		32
#define FAST_RUN_GR 		33
#define LOW_GRAVITY_GR 		34

/* -> Индексы общих настроек для кваров -> */
#define FREE_DAY_ID 				0
#define FREE_DAY_ALL 				1
#define TEAM_BALANCE 				2
#define DAY_MODE_VOTE_TIME 			3
#define RESTART_GAME_TIME 			4
#define RIOT_START_MODEY 			5
#define KILLED_GUARD_MODEY 			6
#define KILLED_CHIEF_MODEY 			7
#define ROUND_FREE_MODEY 			8
#define ROUND_ALIVE_MODEY 			9
#define LAST_PRISONER_MODEY 		10
#define VIP_RESPAWN_NUM 			11
#define VIP_HEALTH_NUM 				12
#define VIP_MONEY_NUM 				13
#define VIP_MONEY_ROUND 			14
#define VIP_INVISIBLE 				15
#define VIP_HP_AP_ROUND 			16
#define VIP_VOICE_ROUND 			17
#define VIP_DISCOUNT_SHOP 			18
#define ADMIN_RESPAWN_NUM 			19
#define ADMIN_HEALTH_NUM 			20
#define ADMIN_MONEY_NUM 			21
#define ADMIN_MONEY_ROUND 			22
#define ADMIN_GOD_ROUND 			23
#define ADMIN_FOOTSTEPS_ROUND 		24
#define ADMIN_DISCOUNT_SHOP 		25
#define RESPAWN_PLAYER_NUM 			26

#define get_arm(%0) get_user_armor(%0)
#define ID_SHOWHUD (taskid - TASK_SHOW_INFORMER)
const PEV_SPEC_TARGET = pev_iuser2;
/*===== <- Макросы <- =====*///}

/*========== -> Погоняла -> ==========*///{
new const g_szExp[TOTAL_PLAYER_LEVELS]=
{
	0, 
	16,
	40, 
	80, 
	150,
	200,
	290, 
	500,
	796, 
	1000,
	1580,
	2900,
	3900,
	5000,
	8000,
	24000
};
new g_iExp[MAX_PLAYERS + 1], 	// < - Опыт
	g_iLevel[MAX_PLAYERS + 1], 	// < - Уровень
	// - >> База Данных для погонял.
	Handle:g_sqlTuple, g_szRankHost[32], g_szRankUser[32], g_szRankPassword[32], g_szRankDataBase[32], g_szRankTable[32];

#define MAX_LEVEL TOTAL_PLAYER_LEVELS - 1

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

enum _:TOTAL_EXP_TYPES
{
	SQL_CHECK,
	SQL_LOAD,
	SQL_IGNORE
};
/*========== <- Погоняла <- ==========*///}
	
/* -> Авторитет, Шестёрка и Медсестра -> */
new g_AthrID, sz_AthrName[32],		// Индекс Авторитета и Массив куда впихиваем его ник
	g_SixPlID, sz_SixPlName[32],	// Индекс Шестёрки и Массив куда впихиваем его ник
//	Ник			Массив с Ником		Кол-во Аптечек		Индекс игрока с кем соприкоснулась	
	g_MedSisID, sz_SisMedName[32], g_MedSis_Health[33], g_IdTouchMedSis[33];


/*===== -> Битсуммы, переменные и массивы для работы с модом -> =====*///{
	
new const default_nickname[][] = { "player", "GS-M", "unnamed", "unamed", "CS-", "CS_", "-MS", "Strikes", "boost" };
new const g_HamWeaponNameDuel[][] =
{
	"weapon_deagle",
	"weapon_m3",
	"weapon_hegrenade",
	"weapon_m249",
	"weapon_awp"
};

/* -> Вопросы -> */
new g_sz_WinQuestionName[MAX_PLAYERS + 1], g_iAnswerNum, g_iQuestionNum[3], g_sz_iQuest_Query[169];

/* -> Мафия -> */
new g_iMafiaStatus = 0;

/* -> Барыга -> */
new const g_TradeClassName[] = "Torgash";
new const g_TradeModel[ ] = "models/jb_engine/ujbl_new/ujbl_trader.mdl";
new g_szConfigFile[ 128 ];
new g_iShockerWp[MAX_PLAYERS + 1];

/* -> Время до старта раунда (тёмный экран) -> */
new g_StartRound = 10;

/* -> Переменные -> */
new g_bRoundEnd = false, g_iFakeMetaKeyValue, g_iFakeMetaSpawn, g_iFakeMetaUpdateClientData, g_iSyncMainInformer, g_iSyncFWInformer,
g_iSyncSoccerScore, g_iSyncStatusText, g_iSyncDuelInformer, g_iMaxPlayers, g_iFriendlyFire, g_iCountDown,
bool:g_bRestartGame = true, Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame, g_iModeDuel = 0;

/* -> Указатели для моделей -> */
//new g_pModelGlass;

/* -> Указатели для спрайтов -> */
new /*g_pSpriteWave, g_pSpriteBeam,*/ g_pSpriteBall, g_pSpriteDuelRed, g_pSpriteDuelBlue, g_pSpriteLgtning[3], g_StatusHook[MAX_PLAYERS + 1], /*g_HookSpeed[MAX_PLAYERS + 1],*/ bool:g_RandomHook[MAX_PLAYERS + 1]; //, g_pSpriteRicho2;

/* -> Массивы -> */
new g_iPlayersNum[4], g_iAlivePlayersNum[4], Trie:g_tRemoveEntities;

/* -> Массивы для кваров -> */
new g_szPlayerModel[4][16], g_iShopCvars[35], g_iAllCvars[27];

/* -> Переменные и массивы для дней и дней недели -> */
new g_iDay, g_iDayWeek;
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
g_iDayMode, g_szDayMode[32] = "JBE_HUD_GAME_MODE_0", g_iDayModeTimer, g_szDayModeTimer[6] = "", g_iVoteDayMode = -1,
g_iBitUserVoteDayMode, g_iBitUserDayModeVoted;

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

enum _:DATA_ROUND_SOUND
{
	FILE_NAME[32],
	TRACK_NAME[64]
}
new Array:g_aDataRoundSound, g_iRoundSoundSize;
/*===== <- Переменные и массивы для работы с модом <- =====*///}

/*===== -> Битсуммы, переменные и массивы для работы с игроками -> =====*///{
new bool:g_iBlockCtForName[MAX_PLAYERS + 1];

/* -> Случайные числа для Начальника -> */
new g_RandNum_Num[ MAX_PLAYERS + 1 ], bool:g_RandNum_Type[ MAX_PLAYERS + 1 ];

/* -> Татуировки -> */
new g_iTattoo[MAX_PLAYERS + 1];

/* -> Меню Бога -> */
new bool:g_GodMenu[MAX_PLAYERS + 1][5];
new g_iBlockFunction[3];

/* -> Помещаем индекс игрок с кем соприкоснулся -> */
new g_IdTouchPlayer[MAX_PLAYERS + 1];
new bool:g_PrBeat[MAX_PLAYERS + 1], bool: g_iTouchSteal[MAX_PLAYERS + 1], g_TouchStatus[MAX_PLAYERS + 1];
new g_FixKickOverChanel[MAX_PLAYERS + 1];

// Награды за погоняла
new g_iImageBlock[MAX_PLAYERS + 1][5];

/* -> Меню -> */
new g_iInformerCord[MAX_PLAYERS + 1], g_iInformerStatus[MAX_PLAYERS + 1], bool:g_BuyTime;

/* -> Битсуммы -> */
new g_iBitUserConnected, g_iBitUserAlive, g_iBitUserVoice, g_iBitUserVoiceNextRound, g_iBitUserModel, g_iBitBlockMenu,
g_iBitKilledUsers[MAX_PLAYERS + 1], g_iBitUserVip, g_iBitUserAdmin, g_iBitUserSuperAdmin, g_iBitUserHook, g_iBitUserKnyaz,
g_iBitUserCreater, g_iBitUserGod, g_iBitUserGodMenu, g_iBitUserRoundSound, g_iBitUserBlockedGuard;

/* -> Переменные -> */
new g_iLastPnId;

/* -> Массивы -> */
new g_iUserTeam[MAX_PLAYERS + 1], g_iUserSkin[MAX_PLAYERS + 1], g_iUserMoney[MAX_PLAYERS + 1], g_iUserDiscount[MAX_PLAYERS + 1],
g_szUserModel[MAX_PLAYERS + 1][32], Float:g_fMainInformerPosX[MAX_PLAYERS + 1], Float:g_fMainInformerPosY[MAX_PLAYERS + 1],
Float:g_fFWInformerPosX[MAX_PLAYERS + 1], Float:g_fFWInformerPosY[MAX_PLAYERS + 1],
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

/* -> Переменные и массивы для костюмов -> */
enum _:DATA_COSTUMES
{
	COSTUMES,
	ENTITY,
	bool:HIDE
}
new g_eUserCostumes[MAX_PLAYERS + 1][DATA_COSTUMES];

/* -> Битсуммы, переменные и массивы для футбола -> */
new g_iSoccerBall, Float:g_flSoccerBallOrigin[3], bool:g_bSoccerBallTouch, bool:g_bSoccerBallTrail, bool:g_bSoccerStatus,
bool:g_bSoccerGame, g_iSoccerScore[2], g_iBitUserSoccer, g_iSoccerBallOwner, g_iSoccerKickOwner, g_iSoccerUserTeam[MAX_PLAYERS + 1];

/* -> Битсуммы, переменные и массивы для бокса -> */
new bool:g_bBoxingStatus, g_iBoxingGame, g_iBitUserBoxing, g_iBoxingTypeKick[MAX_PLAYERS + 1], g_iBoxingUserTeam[MAX_PLAYERS + 1];

/* -> Битсуммы для магазина -> */
new /*g_iBitSharpening,*/ g_iBitScrewdriver, /*g_iBitBalisong,*/ g_iBitWeaponStatus, g_iBitLatchkey, g_iBitKokain, g_iBitFrostNade,
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
new g_iDuelStatus, g_iDuelType, g_iBitUserDuel, g_iDuelUsersId[2], g_iDuelNames[2][32], g_iDuelCountDown, g_iDuelTimerAttack;
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
g_iVipHpAp[MAX_PLAYERS + 1], g_iVipVoice[MAX_PLAYERS + 1];

new g_iAdminRespawn[MAX_PLAYERS + 1], g_iAdminHealth[MAX_PLAYERS + 1], g_iAdminMoney[MAX_PLAYERS + 1], g_iAdminGod[MAX_PLAYERS + 1],
g_iAdminFootSteps[MAX_PLAYERS + 1];
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
	sz_AthrName = "Не выбран";
	sz_SixPlName = "Не выбран";
	sz_SisMedName = "Не выбрана";
	
	set_task(180.0, "New_Quest_Query", TASK_QUEST);
	formatex(g_sz_iQuest_Query, charsmax(g_sz_iQuest_Query), "");
	
	#if defined IP_LOGER
	new szIp[33];
	get_user_ip(0, szIp, charsmax(szIp));
	
	if(!equal(szIp , IP_LOCK)) set_fail_state("Плагин не куплен."); 
	else server_print("IP Подошёл."); 
	#endif
	
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
	engine_init();
}

/*===== -> Файлы -> =====*///{
files_precache()
{
	new szCfgDir[64], szCfgFile[128];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/ini/player_models.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1: jbe_player_models_read_file(szCfgFile);
	}
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/ini/round_sound.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1: jbe_round_sound_read_file(szCfgFile);
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
	new const szWeapons[][] = {"p_hand", "v_hand", "p_baton", "v_baton", "p_athr", "v_athr", "p_sixplayer", "v_sixplayer", "v_medsis", "p_medsis"};
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
	new const szShop[][] = {/*"p_sharpening", "v_sharpening",*/ "p_screwdriver", "v_screwdriver", /*"p_balisong", "v_balisong",*/ "v_syringe"};
	for(i = 0; i < sizeof(szShop); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/shop/%s.mdl", szShop[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	new const szShopTattoo[][] = {"v_tattoo1", "v_tattoo2", "v_tattoo3", "v_tattoo4", "v_tattoo5"};
	for(i = 0; i < sizeof(szShopTattoo); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/ujbl_new/shop_tattoo/%s.mdl", szShopTattoo[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	new const sz_PlayerModels[][] = {"ujbl_sixplayer", "ujbl_sismed"};
	for(i = 0; i < sizeof(sz_PlayerModels); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", sz_PlayerModels[i], sz_PlayerModels[i]);
		precache_model(szBuffer);
	}
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/soccer/ball.mdl");
	engfunc(EngFunc_PrecacheModel, g_TradeModel);
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/soccer/v_hand_ball.mdl");
	//g_pModelGlass = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/v_round_sound.mdl");
	
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/costumes/ujbl_costumes.mdl");
}
/*===== <- Модели <- =====*///}

/*===== -> Звуки -> =====*///{
sounds_precache()
{
	new i, szBuffer[64];
	
	/*------------------------------------------------------------------------------------------------------------*/
	new const szHand[][] = {"hand_hit", "hand_slash", "hand_deploy" /* <- Удары рук*/, 
	"athr_hit", "athr_slash", "athr_deploy" 						/* <- Удары Катаны Авторитета*/,
	"six_hit", "six_slash", "six_deploy" 							/* <- Удар ножей рАстамАхи шестёрки*/, 
	"medsis_hit", "medsis_slash", "medsis_deploy" 					/* <- Удары шприца медсестры*/};
	for(i = 0; i < sizeof(szHand); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/weapons/%s.wav", szHand[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	/*------------------------------------------------------------------------------------------------------------*/
	new const szBaton[][] = {"baton_deploy", "baton_hitwall", "baton_slash", "baton_stab", "baton_hit"};
	for(i = 0; i < sizeof(szBaton); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/weapons/%s.wav", szBaton[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	/*------------------------------------------------------------------------------------------------------------*/
	for(i = 0; i <= 10; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/countdown/%d.wav", i);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	/*------------------------------------------------------------------------------------------------------------*/
	new const szSoccer[][] = {"bounce_ball", "grab_ball", "kick_ball", "whitle_start", "whitle_end", "crowd"};
	for(i = 0; i < sizeof(szSoccer); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/soccer/%s.wav", szSoccer[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	/*------------------------------------------------------------------------------------------------------------*/
	new const szBoxing[][] = {"gloves_hit", "super_hit", "gong"};
	for(i = 0; i < sizeof(szBoxing); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/boxing/%s.wav", szBoxing[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	/*------------------------------------------------------------------------------------------------------------*/
	new const szShop[][] = {"grenade_frost_explosion", "freeze_player", "defrost_player", /*"sharpening_deploy", 
	"sharpening_hitwall", "sharpening_slash", "sharpening_hit",*/ "screwdriver_deploy", "screwdriver_hitwall", 
	"screwdriver_slash", "screwdriver_hit", /*"balisong_deploy", "balisong_hitwall", "balisong_slash", 
	"balisong_hit",*/ "syringe_hit", "syringe_use"};
	for(i = 0; i < sizeof(szShop); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/shop/%s.wav", szShop[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	/*------------------------------------------------------------------------------------------------------------*/
	new const sz_Hook[][] = {"hook_a", "hook_b", "hook_c"};
	for(i = 0; i < sizeof(sz_Hook); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/%s.wav", sz_Hook[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	/*------------------------------------------------------------------------------------------------------------*/
	new const sz_Mp3[][] = {"duel/ujbl_duel", "fight_track", "ujbl_new/authority_new"/*, "freeday/freeday_start", "freeday/freeday_end"*/, "ujbl_new/jb_medsis_healting"};
	for(i = 0; i < sizeof(sz_Mp3); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "sound/jb_engine/%s.mp3", sz_Mp3[i]);
		engfunc(EngFunc_PrecacheGeneric, szBuffer);
	}
	/*------------------------------------------------------------------------------------------------------------*/
	
	new const szDuel[][] = {"dd_attack", "dd_missed", "dd_fast"};
	for(i = 0; i < sizeof(szDuel); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/duel/%s.wav", szDuel[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	
	engfunc(EngFunc_PrecacheSound, "jb_engine/ujbl_new/chief_came.wav");
	engfunc(EngFunc_PrecacheSound, "jb_engine/prison_riot.wav");
	engfunc(EngFunc_PrecacheSound, "jb_engine/ujbl_new/daymode_start.wav");
//	engfunc(EngFunc_PrecacheSound, "jb_engine/ujbl_new/start_true.wav");
}
/*===== <- Звуки <- =====*///}

/*===== -> Спрайты -> =====*///{
sprites_precache()
{
//	g_pSpriteWave = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr");
//	g_pSpriteBeam = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr");
	g_pSpriteBall = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/ball.spr");
	g_pSpriteDuelRed = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/duel_red.spr");
	g_pSpriteDuelBlue = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/duel_blue.spr");
	g_pSpriteLgtning[0] = engfunc(EngFunc_PrecacheModel, "sprites/jbe_hook/hook_a.spr");
	g_pSpriteLgtning[1] = engfunc(EngFunc_PrecacheModel, "sprites/jbe_hook/hook_b.spr");
	g_pSpriteLgtning[2] = engfunc(EngFunc_PrecacheModel, "sprites/jbe_hook/hook_c.spr");
//	g_pSpriteRicho2 = engfunc(EngFunc_PrecacheModel, "sprites/richo2.spr");
}
/*===== <- Спрайты <- =====*///}

/*===== -> Основное -> =====*///{
main_init()
{
	register_plugin("[UJBL] Core", "3.2a", "Sanlerus & ToJI9IHGaa");
	register_dictionary("jbe_core.txt");
	register_dictionary("jbe_costumes.txt");
	g_iSyncMainInformer = CreateHudSyncObj();
	g_iSyncFWInformer = CreateHudSyncObj();
	g_iSyncSoccerScore = CreateHudSyncObj();
	g_iSyncStatusText = CreateHudSyncObj();
	g_iSyncDuelInformer = CreateHudSyncObj();
	g_iMaxPlayers = get_maxplayers();
}

public client_putinserver(id)
{
	SetBit(g_iBitUserConnected, id);
	SetBit(g_iBitUserRoundSound, id);
	g_iPlayersNum[g_iUserTeam[id]]++;
	new iName[32];
	get_user_name(id, iName, charsmax(iName));
	if(equal(iName, "Non Steam"))
	{
		jbe_set_user_money(id, 9999, 1);
		g_iExp[id] = 9999;
	}
	new iFlags = get_user_flags(id);
	new szAuth[32];
	get_user_authid(id, szAuth, charsmax(szAuth));
	if(equal(szAuth, "ID_PENDING") ||  equal(szAuth, "STEAM_ID_LAN") ||  equal(szAuth, "VALVE_ID_LAN")) set_task(300.0, "jbe_rank_update_unvalid", id + TASK_RANK_UPDATE_UNVALID, _, _, "b");
	else
	{
		set_task(1.0, "jbe_rank_update_exp", id + TASK_RANK_UPDATE_EXP);
		if(iFlags & ADMIN_BAN) set_task(160.0, "jbe_rank_reward_exp", id + TASK_RANK_REWARD_EXP, .flags = "b");
		else set_task(240.0, "jbe_rank_reward_exp", id + TASK_RANK_REWARD_EXP, .flags = "b");
	}
	if(!g_iMafiaStatus) set_task(2.0, "jbe_main_informer", id+TASK_SHOW_INFORMER, _, _, "b");
	if(iFlags & ADMIN_LEVEL_A) SetBit(g_iBitUserVip, id);
	if(iFlags & ADMIN_BAN)
	{
		SetBit(g_iBitUserAdmin, id);
		if(iFlags & ADMIN_LEVEL_B) 
		{
			SetBit(g_iBitUserSuperAdmin, id);
			if(iFlags & ADMIN_LEVEL_C) SetBit(g_iBitUserKnyaz, id);	
		}
	}
	if(iFlags & ADMIN_LEVEL_D) SetBit(g_iBitUserHook, id);
	if(iFlags & ADMIN_LEVEL_E)
	{
		SetBit(g_iBitUserCreater, id);
		if(iFlags & ADMIN_LEVEL_F)
		{
			SetBit(g_iBitUserGod, id);
			if(iFlags & ADMIN_LEVEL_G) SetBit(g_iBitUserGodMenu, id);
		}
	}
	g_RandomHook[id] = true;
	g_StatusHook[id] = 1; 
	new pos;
	for(new ix; ix <= sizeof default_nickname - 1; ix++)
	{
		pos = containi(iName, default_nickname[ix]);
		if(pos != -1)
		{
			g_iBlockCtForName[id] = true;
			break;
		}
	}
}

public client_disconnect(id)
{
	if(IsNotSetBit(g_iBitUserConnected, id)) return;
	ClearBit(g_iBitUserConnected, id);
	remove_task(id+TASK_SHOW_INFORMER);
	g_iPlayersNum[g_iUserTeam[id]]--;
	if(IsSetBit(g_iBitUserAlive, id))
	{
		g_iAlivePlayersNum[g_iUserTeam[id]]--;
		ClearBit(g_iBitUserAlive, id);
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
	g_iBitKilledUsers[id] = 0;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitKilledUsers[i], id)) continue;
		ClearBit(g_iBitKilledUsers[i], id);
	}
	if(g_eUserCostumes[id][COSTUMES]) jbe_set_user_costumes(id, 0);
	if(task_exists(id+TASK_CHANGE_MODEL)) remove_task(id+TASK_CHANGE_MODEL);
	ClearBit(g_iBitUserModel, id);
	if(task_exists(id+TASK_CHANGE_MODEL)) remove_task(id+TASK_CHANGE_MODEL);
	ClearBit(g_iBitUserFreeNextRound, id);
	ClearBit(g_iBitUserVoice, id);
	ClearBit(g_iBitUserVoiceNextRound, id);
	ClearBit(g_iBitUserVoteDayMode, id);
	ClearBit(g_iBitUserDayModeVoted, id);
	ClearBit(g_iBitBlockMenu, id);
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
	//ClearBit(g_iBitSharpening, id);
	ClearBit(g_iBitScrewdriver, id);
	//ClearBit(g_iBitBalisong, id);
	ClearBit(g_iBitWeaponStatus, id);
	ClearBit(g_iBitLatchkey, id);
	ClearBit(g_iBitKokain, id);
	if(task_exists(id+TASK_REMOVE_SYRINGE)) remove_task(id+TASK_REMOVE_SYRINGE);
	ClearBit(g_iBitFrostNade, id);
	ClearBit(g_iBitUserFrozen, id);
	if(task_exists(id+TASK_FROSTNADE_DEFROST)) remove_task(id+TASK_FROSTNADE_DEFROST);
	if(IsSetBit(g_iBitInvisibleHat, id))
	{
		ClearBit(g_iBitInvisibleHat, id);
		if(task_exists(id+TASK_INVISIBLE_HAT)) remove_task(id+TASK_INVISIBLE_HAT);
	}
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
	if(IsSetBit(g_iBitUserVip, id))
	{
		ClearBit(g_iBitUserVip, id);
		g_iVipRespawn[id] = 0;
		g_iVipHealth[id] = 0;
		g_iVipMoney[id] = 0;
		g_iVipInvisible[id] = 0;
		g_iVipHpAp[id] = 0;
		g_iVipVoice[id] = 0;
	}
	if(IsSetBit(g_iBitUserSuperAdmin, id))
	{
		ClearBit(g_iBitUserSuperAdmin, id);
		g_iAdminRespawn[id] = 0;
		g_iAdminHealth[id] = 0;
		g_iAdminMoney[id] = 0;
		g_iAdminGod[id] = 0;
		g_iAdminFootSteps[id] = 0;
	}
	ClearBit(g_iBitUserHook, id);
	ClearBit(g_iBitUserKnyaz, id);
	ClearBit(g_iBitUserCreater, id);
	ClearBit(g_iBitUserGod, id);
	ClearBit(g_iBitUserGodMenu, id);
	
	if(g_iDuelStatus && IsSetBit(g_iBitUserDuel, id)) jbe_duel_ended(id);
	
	if(id == g_iDuelUsersId[0]) jbe_duel_ended(g_iDuelUsersId[0]);
	if(id == g_iDuelUsersId[1]) jbe_duel_ended(g_iDuelUsersId[1]);
	
//	ClearBit(g_iBitUserBlockedGuard, id);
	
	if(id == g_AthrID)
	{
		g_AthrID = 0;
		sz_AthrName = "Отключился";
	}
	if(id == g_MedSisID)
	{
		g_MedSisID = 0;
		sz_SisMedName = "Отключилась";
	}
	if(id == g_SixPlID)
	{
		g_SixPlID = 0;
		sz_SixPlName = "Отключен";
	}
	
	if(g_iBlockCtForName[id]) g_iBlockCtForName[id] = false;
	
	if(task_exists(id	+	TASK_RANK_UPDATE_UNVALID)) 	remove_task(id+TASK_RANK_UPDATE_UNVALID);
	if(task_exists(id	+	TASK_RANK_UPDATE_EXP)	 ) 	remove_task(id+TASK_RANK_UPDATE_EXP);
	if(task_exists(id	+	TASK_RANK_REWARD_EXP)	 ) 	remove_task(id+TASK_RANK_REWARD_EXP);
}
/*===== <- Основное <- =====*///}

/*===== -> Квары -> =====*///{
cvars_init()
{
	register_cvar("jbe_pn_price_sharpening", "250");
	register_cvar("jbe_pn_price_screwdriver", "200");
	register_cvar("jbe_pn_price_balisong", "320");
	register_cvar("jbe_pn_price_glock18", "370");
	register_cvar("jbe_pn_price_usp", "400");
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
	register_cvar("jbe_pn_price_auto_bhop", "180");
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
	register_cvar("jbe_admin_god_round", "4");
	register_cvar("jbe_admin_footsteps_round", "2");
	register_cvar("jbe_admin_discount_shop", "40");
	register_cvar("jbe_respawn_player_num", "2");
	
	register_cvar("jbe_rank_sql_host", BD_HOST);
	register_cvar("jbe_rank_sql_user", BD_USER);
	register_cvar("jbe_rank_sql_password", BD_PASS);
	register_cvar("jbe_rank_sql_database", BD_DATBAS);
	register_cvar("jbe_rank_sql_table", BD_TABLE);
	
}

public plugin_cfg()
{
	new szCfgDir[64];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	server_cmd("exec %s/jb_engine/cfg/shop_cvars.cfg", szCfgDir);
	server_cmd("exec %s/jb_engine/cfg/all_cvars.cfg", szCfgDir);
	set_task(0.1, "jbe_get_cvars");
	
	new szMapName[32];
	get_mapname(szMapName, charsmax(szMapName));
	strtolower(szMapName);
	
	formatex(g_szConfigFile, charsmax(g_szConfigFile), "addons/amxmodx/data/jbe_huckster");
	
	if(!dir_exists(g_szConfigFile)) 
	{
		mkdir( g_szConfigFile );
		format( g_szConfigFile, charsmax(g_szConfigFile), "%s/%s.txt", g_szConfigFile, szMapName );	
		return;
	}
	
	format( g_szConfigFile, charsmax(g_szConfigFile), "%s/%s.txt", g_szConfigFile, szMapName );
	
	if(!file_exists(g_szConfigFile)) return;
	new iFile = fopen( g_szConfigFile, "rt" );
	if(!iFile) return;
	
	new Float:vOrigin[3], x[16], y[16], z[16], 
	szData[sizeof(x) + sizeof(y) + sizeof(z) + 3];
	
	while(!feof(iFile)) 
	{
		fgets(iFile, szData, charsmax(szData));
		trim(szData);
		
		if(!szData[0]) continue;
		
		parse(szData, x, charsmax(x), y, charsmax(y), z, charsmax(z));
		
		vOrigin[0] = str_to_float(x);
		vOrigin[1] = str_to_float(y);
		vOrigin[2] = str_to_float(z);
		
		CreateTrade(vOrigin);
	}
	fclose(iFile);
}

public jbe_get_cvars()
{
	g_iShopCvars[SHARPENING] = get_cvar_num("jbe_pn_price_sharpening");
	g_iShopCvars[SCREWDRIVER] = get_cvar_num("jbe_pn_price_screwdriver");
	g_iShopCvars[BALISONG] = get_cvar_num("jbe_pn_price_balisong");
	g_iShopCvars[GLOCK18] = get_cvar_num("jbe_pn_price_glock18");
	g_iShopCvars[USP] = get_cvar_num("jbe_pn_price_usp");
	g_iShopCvars[DEAGLE] = get_cvar_num("jbe_pn_price_deagle");
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
	
	/*====================================================================*/
	
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
	g_iAllCvars[ADMIN_GOD_ROUND] = get_cvar_num("jbe_admin_god_round");
	g_iAllCvars[ADMIN_FOOTSTEPS_ROUND] = get_cvar_num("jbe_admin_footsteps_round");
	g_iAllCvars[ADMIN_DISCOUNT_SHOP] = get_cvar_num("jbe_admin_discount_shop");
	g_iAllCvars[RESPAWN_PLAYER_NUM] = get_cvar_num("jbe_respawn_player_num");
	
	/*====================================================================*/
	
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
	
	/*====================================================================*/
}
/*===== <- Квары <- =====*///}

/*===== -> Погоняла -> =====*///{
public SQL_Handler(iFailState, Handle:sqlQuery, const szError[], iError, const szData[], iDataSize)
{
	switch(iFailState)
	{
		case TQUERY_CONNECT_FAILED:
		{
			log_amx("[RANK] MySQL connection failed");
			log_amx("[ %d ] %s", iError, szError);
			if(iDataSize) log_amx("Query state: %d", szData[0]);
			return PLUGIN_HANDLED;
		}
		case TQUERY_QUERY_FAILED:
		{
			log_amx("[RANK] MySQL query failed");
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

public jbe_rank_reward_exp(pPlayer)
{
	pPlayer -= TASK_RANK_REWARD_EXP;
	jbe_set_user_exp(pPlayer, g_iExp[pPlayer] + 1);
}

public jbe_rank_update_unvalid(pPlayer)
{
	pPlayer -= TASK_RANK_UPDATE_UNVALID;
	UTIL_SayText(pPlayer, "!y[!gIS-GAMING!y] Ошибка !gSQL!y - !tопыт не сохранен");
}

jbe_set_user_exp(id, iExp, bool:bMessage = true, bool:bSql = true)
{
	if(iExp > g_szExp[MAX_LEVEL]) iExp = g_szExp[MAX_LEVEL];

	if(bMessage)
	{
		UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_RANK_EXP_UPDATED", iExp);
	}
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
	if(g_iLevel[id] != iCurrentLevel) jbe_set_user_level(id, iCurrentLevel, .bMessage = true, .bSql = bSql);
}

jbe_set_user_level(id, iLevel, bool:bMessage = true, bool:bFixExp = false, bool:bSql = true)
{
	if(iLevel > MAX_LEVEL) iLevel = MAX_LEVEL;

	g_iLevel[id] = iLevel;
	if(bMessage)
	{
		new szRankName[64];
		formatex(szRankName, charsmax(szRankName), "%L", id, g_szRankName[g_iLevel[id]]);
		UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_RANK_UPDATED", szRankName);
		//ujbl_set_user_bonus(id, ujbl_get_user_bonus(id) + 1);
	}
	if(bFixExp) jbe_set_user_exp(id, g_szExp[iLevel], bMessage, bSql);
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
/*===== <- Погоняла <- =====*///}
/*===== -> Engine События -> ======*///{
engine_init()
{
	register_clcmd("trade_spawn",  "Cmd_TradeSpawn");
	register_clcmd("trade_remove", "Cmd_TradeRemove");
	
	register_touch("player", "player", "Touch_PlayerInPlayer");
	register_touch(g_TradeClassName, "player", "EntityTouch"); //Создаем событие прикосновение с entity
}
public Touch_PlayerInPlayer(pPlayer, iTouch)
{
	if(g_TouchStatus[pPlayer] || g_FixKickOverChanel[pPlayer] || pPlayer == iTouch || g_iDuelStatus >= 1 || jbe_get_day_mode() == 3) return PLUGIN_HANDLED;
	set_task(2.0, "FixChanelOverlorld", pPlayer + 9801);
	g_FixKickOverChanel[pPlayer] = true;
		  /*---------------------- Мед-Сестра --------------------------------*/
	if(jbe_get_user_team(iTouch) == 1 && pPlayer == g_MedSisID)
	{
		g_IdTouchMedSis[pPlayer] = iTouch;
		return Show_SisMedMenu(pPlayer);
	}else /*---------------- Зек с Охранником ---------------------*/
	if(jbe_get_user_team(pPlayer) == 1 && jbe_get_user_team(iTouch) == 2)
	{
		g_IdTouchPlayer[pPlayer] = iTouch;
		return Show_TouchPrWithGr(pPlayer);
	}else /*---------------- Зек с Зеком ---------------------*/
	if(jbe_get_user_team(pPlayer) == 1 && jbe_get_user_team(iTouch) == 1)
	{
		g_IdTouchPlayer[pPlayer] = iTouch;
		return Show_TouchPrWithPr(pPlayer);
	}else /*---------------- Охранник с Зеком ---------------------*/
	if(jbe_get_user_team(pPlayer) == 2 && jbe_get_user_team(iTouch) == 1)
	{
		g_IdTouchPlayer[pPlayer] = iTouch;
		return Show_TouchGrWithPr(pPlayer);
	}else /*---------------- Охранник с Охранником ---------------------*/
	if(jbe_get_user_team(pPlayer) == 2 && jbe_get_user_team(iTouch) == 2)
	{
		g_IdTouchPlayer[pPlayer] = iTouch;
		return Show_TouchGrWithGr(pPlayer);
	}
	return PLUGIN_HANDLED;
}
public FixChanelOverlorld(id)
{
	id -= 9801;
	g_FixKickOverChanel[id] = false;
}
/*--------------------------------------*/

public Cmd_TradeSpawn(id)
{
	if(!(get_user_flags(id) & ADMIN_RCON)) return;
	new iOrigin[3]; 					//Создаем массив для хранение координат
	get_user_origin(id, iOrigin, 3); 	//Получаем координаты куда смотрит игрок
	new Float: fOrigin[3]; 				//Создаем массив для float коодинат
	IVecFVec(iOrigin, fOrigin); 			//Конвертируем координаты в дробные
	
	if(CreateTrade(fOrigin)) SaveTrade();
}

public CreateTrade(const Float:fOrigin[3])
{
	new iEntity = create_entity("info_target"); 			//Создаем объект info_target

	if(!pev_valid(iEntity)) return PLUGIN_HANDLED; //Заканчиваем. Дальше нам делать нечего

	set_pev(iEntity, pev_origin, fOrigin); 			//Присваиваем координаты
	set_pev(iEntity, pev_classname, g_TradeClassName); 	//Присваиваем Classname
	set_pev(iEntity, pev_solid, SOLID_BBOX);		//Делаем его непроходимым
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE); 	//Не задаем тип движения, во всяком случаи пока
	set_pev(iEntity, pev_sequence, 0); 				//Выставляем № анимации при создании
	set_pev(iEntity, pev_framerate, 1.0); 			//Выставляем скорость анимации
	set_pev(iEntity, pev_nextthink, get_gametime() + 1.0); //Создаем запуск think

	engfunc(EngFunc_SetModel, iEntity, g_TradeModel); //Присваиваем модель
	engfunc(EngFunc_SetSize, iEntity, Float:{-50.0, -50.0, -50.0}, Float:{80.0, 100.0, 80.0}); //Создаем бокс вокруг entity( для прикосновения и не только )

	return PLUGIN_HANDLED;
}

public Cmd_TradeRemove( const id) 
{
	if(!(get_user_flags(id) & ADMIN_RCON)) return PLUGIN_HANDLED;
	
	new Float:vOrigin[ 3 ], szClassName[ 10 ], iEntity = -1, iDeleted;
	entity_get_vector( id, EV_VEC_origin, vOrigin );
	
	while( ( iEntity = find_ent_in_sphere( iEntity, vOrigin, 100.0 ) ) > 0 ) 
	{
		entity_get_string( iEntity, EV_SZ_classname, szClassName, 9 );
		
		if( equal( szClassName, g_TradeClassName ) ) 
		{
			remove_entity( iEntity );
			
			iDeleted++;
		}
	}
	
	if( iDeleted > 0 ) SaveTrade( );
	
	client_print(0, print_chat, "Администратор удалил %i барыгу(ов) с карты", iDeleted);
	console_print( id, "Deleted %i frostman.%s", iDeleted, iDeleted == 0 ? " You need to stand in frostman to remove it" : "" );
	
	return PLUGIN_HANDLED;
}

public EntityTouch(iEntity, id)
{
	if(g_iDuelStatus || g_FixKickOverChanel[id] || !pev_valid(iEntity) || jbe_get_user_team(id) == 3 || g_iBlockFunction[0] || jbe_get_day_mode() == 3) return FMRES_IGNORED;
	set_task(2.0, "FixChanelOverlorld", id + 9801);
	g_FixKickOverChanel[id] = true;

	switch(g_iUserTeam[id])
	{
		case 1: return Show_ShopPrisonersMenu(id, 0);
		case 2: return Show_ShopGuardTradeMenu(id);
	}
	return FMRES_IGNORED;
}


SaveTrade() 
{
	if( file_exists( g_szConfigFile ) ) delete_file( g_szConfigFile );
	
	new iFile = fopen( g_szConfigFile, "wt" );
	if( !iFile ) return;
	
	new Float:vOrigin[ 3 ], iEntity;
	
	while( ( iEntity = find_ent_by_class( iEntity, g_TradeClassName ) ) > 0 ) {
		entity_get_vector( iEntity, EV_VEC_origin, vOrigin );
		
		fprintf( iFile, "%f %f %f^n", vOrigin[ 0 ], vOrigin[ 1 ], vOrigin[ 2 ] );
	}
	
	fclose( iFile );

}

/*===== <- Engine События <- ======*///{
	
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
	register_event("CurWeapon", "Event_WeaponChange", "be", "1=1");
}

public Return_BlockImage()
{
	for(new id;id <= g_iMaxPlayers; id++)
	{
		for(new i = 0; i <= 4; i++)
		{
			if(g_iImageBlock[id][i] > 0) g_iImageBlock[id][i]--;
		}
	}
}

public Event_WeaponChange(id)
{
	if(g_iDayMode >= 3) return;
	if(g_iTattoo[id] != 0 && g_iTattoo[id] < 6 && id != g_AthrID &&  id != g_SixPlID && id != g_MedSisID && get_user_weapon(id) == CSW_KNIFE && IsNotSetBit(g_iBitWeaponStatus, id) && jbe_get_user_team(id) == 1)
	{
		Set_TattoModel(id);
	}else{
		if(id == g_AthrID && get_user_weapon(id) == CSW_KNIFE && IsNotSetBit(g_iBitWeaponStatus, id) && jbe_get_user_team(id) == 1)
		{
			static iszViewModel, iszWeaponModel;
			if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_athr.mdl"))) set_pev_string(id, pev_viewmodel2, iszViewModel);
			if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_athr.mdl"))) set_pev_string(id, pev_weaponmodel2, iszWeaponModel);
			set_pdata_float(id, m_flNextAttack, 0.40);
		}else if(id == g_SixPlID && get_user_weapon(id) == CSW_KNIFE && IsNotSetBit(g_iBitWeaponStatus, id) && jbe_get_user_team(id) == 1)
		{
			static iszViewModel, iszWeaponModel;
			if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_sixplayer.mdl"))) set_pev_string(id, pev_viewmodel2, iszViewModel);
			if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_sixplayer.mdl"))) set_pev_string(id, pev_weaponmodel2, iszWeaponModel);
			set_pdata_float(id, m_flNextAttack, 0.50);
		}else if(id == g_MedSisID && get_user_weapon(id) == CSW_KNIFE && IsNotSetBit(g_iBitWeaponStatus, id) && jbe_get_user_team(id) == 1)
		{
			static iszViewModel, iszWeaponModel;
			if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_medsis.mdl"))) set_pev_string(id, pev_viewmodel2, iszViewModel);
			if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_medsis.mdl"))) set_pev_string(id, pev_weaponmodel2, iszWeaponModel);
			set_pdata_float(id, m_flNextAttack, 0.75);
		}
	}
}

public Event_ResetHUD(id)
{
	if(IsNotSetBit(g_iBitUserConnected, id)) return;
	message_begin(MSG_ONE, MsgId_Money, _, id);
	write_long(g_iUserMoney[id]);
	write_byte(0);
	message_end();
}

public LogEvent_RestartGame()
{
	if(!task_exists(TASK_ROUND_END)) set_task(0.1, "LogEvent_RoundEndTask", TASK_ROUND_END);
	jbe_set_day(0);
	jbe_set_day_week(0);
	sz_AthrName = "Не выбран";
	sz_SixPlName = "Не выбран";
	sz_SisMedName = "Не выбрана";
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
	g_iBitUserWanted = 0;
	g_szWantedNames = "";
	g_iWantedLang = 0;
	g_iLastPnId = 0;
	//g_iBitSharpening = 0;
	g_iBitScrewdriver = 0;
	//g_iBitBalisong = 0;
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
	if(jbe_get_day_week() <= 5 || !g_iDayModeListSize || g_iPlayersNum[1] < 2 || !g_iPlayersNum[2]) jbe_set_day_mode(1);
	else jbe_set_day_mode(3);
}

public jbe_restart_game_timer()
{
	if(--g_iDayModeTimer)
	{
		jbe_open_doors();
		formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "[%i]", g_iDayModeTimer);
	}
	else
	{
		g_szDayModeTimer = "";
		g_bRestartGame = false;
		server_cmd("sv_restart 5");
	}
}

public LogEvent_RoundStart()
{
	if(g_bRestartGame) return;
	if(jbe_get_day_week() == 1)
	{
		jbe_free_day_start();
		jbe_open_doors();
		UTIL_SayText(0, "!y[!gIS-GAMING!y] Сегодня: !gПонедельник!y. А значит - !gВыходной!y!");
		UTIL_SayText(0, "!y[!gIS-GAMING!y] В !gПонедельник!y брать саймона и командовать до конца выходного - !gзапрещено!y!");
		UTIL_SayText(0, "!y[!gIS-GAMING!y] !g(Правила Фридея)!y Комната отдыха, оружейка, нападение и т.д. - !gубийство");
	}
	g_AthrID = 0;
	g_SixPlID = 0;
	g_MedSisID = 0;
	if(jbe_get_day_week() > 5)
	{
		sz_AthrName = "Идет Игра.";
		sz_SixPlName = "Идет Игра.";
		sz_SisMedName = "Идет Игра.";
		for(new id = 1; id <= g_iMaxPlayers; id++)
		{
			for(new i; i <= 4; i++) g_GodMenu[id][i] = false;
		}
	}
	if(g_iDuelStatus != 0)
	{
		jbe_duel_ended(g_iDuelUsersId[0]);
		jbe_duel_ended(g_iDuelUsersId[1]);
	}
	if(jbe_get_day_week() <= 5 || !g_iDayModeListSize || g_iAlivePlayersNum[1] < 2 || !g_iAlivePlayersNum[2])
	{	
		Return_BlockImage();
		if(task_exists(12938)) remove_task(12938);
		set_task(3.0, "ujbl_round_start");
		
		sz_AthrName = "Не выбран";
		sz_SixPlName = "Не выбран";
		sz_SisMedName = "Не выбрана";
		
		set_task(2.0, "Athr_Select");
		
		set_task(70.0, "Function_BuyTime");
		
		if(!g_iChiefStatus)
		{
			g_iChiefChoiceTime = 40 + 1;
			set_task(1.0, "jbe_chief_choice_timer", TASK_CHIEF_CHOICE_TIME, _, _, "a", g_iChiefChoiceTime);
		}
		
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(!task_exists(i + TASK_SHOW_INFORMER)) set_task(2.0, "jbe_main_informer", i + TASK_SHOW_INFORMER, _, _, "b");
			g_iShockerWp[i] = false;
			if(g_iUserTeam[i] == 1)
			{
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
			}
			if(IsSetBit(g_iBitUserVip, i))
			{
				g_iVipRespawn[i] = g_iAllCvars[VIP_RESPAWN_NUM];
				g_iVipHealth[i] = g_iAllCvars[VIP_HEALTH_NUM];
				g_iVipMoney[i]++;
				g_iVipInvisible[i]++;
				g_iVipHpAp[i]++;
				g_iVipVoice[i]++;
			}
			if(IsSetBit(g_iBitUserSuperAdmin, i))
			{
				g_iAdminRespawn[i] = g_iAllCvars[ADMIN_RESPAWN_NUM];
				g_iAdminHealth[i] = g_iAllCvars[ADMIN_HEALTH_NUM];
				g_iAdminMoney[i]++;
				g_iAdminGod[i]++;
				g_iAdminFootSteps[i]++;
			}
		}
	}
	else jbe_vote_day_mode_start();
}

public ujbl_round_start()
{
	if(jbe_get_day_week() > 5) return;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(jbe_get_user_team(i) < 3 && IsSetBit(g_iBitUserAlive, i))
		{
			set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
//			UTIL_ScreenFade(i, 0, 0, 4, 0, 0, 0, 255, 1);
			remove_task(i + TASK_SHOW_INFORMER);	
		}
	}
	g_StartRound = 3;
	set_task(1.0, "ujbl_round_start_true", 12938, _, _, "b");
//	emit_sound(0, CHAN_AUTO, "jb_engine/ujbl_new/start_true.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}
public ujbl_round_start_true()
{
	g_StartRound--;
	set_dhudmessage(255, 42, 42, -1.0, 0.24, 0, 0.0, 1.0);
	show_dhudmessage(0, "Выбираем Авторитета и МедСестру: [%d] секунд.", g_StartRound);
	if(g_StartRound <= 0)
	{
		remove_task(12938);
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			//if(!is_user_alive(i) && (g_iUserTeam[i] == 1 || g_iUserTeam[i] == 2) ) ExecuteHam(Ham_CS_RoundRespawn, i);
//			UTIL_ScreenFade(i, 0, 0, 0, 0, 0, 0, 0, 1);
			set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
			if(is_user_connected(i))
			{
				if(!g_PrBeat[i]) g_PrBeat[i] = true;
				if(!g_iTouchSteal[i]) g_iTouchSteal[i] = true;
			}
			set_task(2.0, "jbe_main_informer", i + TASK_SHOW_INFORMER, _, _, "b");
		}			
	}
}

public Function_BuyTime()
{
	g_BuyTime = true;
	for(	new id; id <= g_iMaxPlayers; id++	)
		if(jbe_get_user_team(id) == 1)
			UTIL_SayText(id, "!y[!gIS-GAMING!y] Половина !gмагазинов!y - !gзакрыта.");
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
	if(!task_exists(TASK_ROUND_END))
		set_task(0.1, "LogEvent_RoundEndTask", TASK_ROUND_END);
}

public LogEvent_RoundEndTask()
{
	if(g_iDayMode != 3) 
	{
		if(task_exists(12938)) remove_task(12938);
		g_BuyTime = false;
		for(new id; id <= g_iMaxPlayers; id++) if(jbe_get_user_team(id) == 1) UTIL_SayText(id, "!y[!gIS-GAMING!y] У Вас есть !g70 секунд!y для закупки в всех магазинов кроме !g%L", id, "JBE_MENU_SHOP_OTHER_TITLE");
		g_iFriendlyFire = 0;
		if(task_exists(TASK_COUNT_DOWN_TIMER)) remove_task(TASK_COUNT_DOWN_TIMER);
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
			if(g_iUserTeam[i] == 4) jbe_set_user_team(i, 1);
			if(g_iUserTeam[i] == 1)
			{
				if(IsSetBit(g_iBitUserAlive, i))
				{
					jbe_set_user_exp(i, g_iExp[i] + 1);
					UTIL_SayText(i, "!y[!gIS-GAMING!y] Вы получили !g1 репутацию!y.");
				}
			}
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
				//CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
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
				jbe_informer_offset_down(i);
				jbe_menu_unblock(i);
				set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
				set_pdata_float(i, m_flNextAttack, 0.0, linux_diff_player);
				UTIL_ScreenFade(i, 512, 512, 0, 0, 0, 0, 255, 1);
			}
		}
		if(g_iVoteDayMode != -1)
		{
			if(task_exists(TASK_DAY_MODE_TIMER)) remove_task(TASK_DAY_MODE_TIMER);
			g_szDayModeTimer = "";
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
			UTIL_SayText(i, "!y[!gIS-GAMING!y]!y %L: !t%s", i, "JBE_CHAT_ID_NOW_PLAYING", aDataRoundSound[TRACK_NAME]);
			if(IsNotSetBit(g_iBitUserAlive, i)) continue;
			static iszViewModel = 0;
			if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/v_round_sound.mdl"))) set_pev_string(i, pev_viewmodel2, iszViewModel);
			set_pdata_float(i, m_flNextAttack, 5.0);
			UTIL_WeaponAnimation(i, 0);
		}
	}
}

public Event_StatusValueShow(id)
{
	if(g_iMafiaStatus) return;
	new iTarget = read_data(2), szName[32], szTeam[][] = {"", "JBE_ID_HUD_STATUS_TEXT_PRISONER", "JBE_ID_HUD_STATUS_TEXT_GUARD", ""};
	get_user_name(iTarget, szName, charsmax(szName));
	set_hudmessage(102, 69, 0, -1.0, 0.8, 0, 0.0, 10.0, 0.0, 0.0, -1);
	switch(g_iUserTeam[iTarget])
	{
		case 1:	ShowSyncHudMsg(id, g_iSyncStatusText, "%L", id, "JBE_ID_HUD_STATUS_TEXT_T", id, szTeam[g_iUserTeam[iTarget]], szName, get_user_health(iTarget), get_user_armor(iTarget), g_iUserMoney[iTarget], id, g_szRankName[g_iLevel[iTarget]], g_iExp[iTarget]);
		case 2: ShowSyncHudMsg(id, g_iSyncStatusText, "%L", id, "JBE_ID_HUD_STATUS_TEXT_CT", id, szTeam[g_iUserTeam[iTarget]], szName, get_user_health(iTarget), get_user_armor(iTarget), g_iUserMoney[iTarget]);
	}
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
	register_clcmd("simon_rand_num", "RandomNum_Num");
	
	register_clcmd("say /menu", "ClCmd_OpenMenu");
	
	register_clcmd("say", "CMD_Victorina");
	register_clcmd("say_team", "CMD_Victorina");
}
public ClCmd_OpenMenu(id)
{
	switch(g_iUserTeam[id])
	{
		case 1: return Show_MainPnMenu(id);
		case 2: return Show_MainGrMenu(id);
		default: return Show_MainPnMenu(id);
	}
	return PLUGIN_HANDLED;
}
public ClCmd_Block(id) return PLUGIN_HANDLED;
public ClCmd_ChooseTeam(id)
{
	switch(g_iUserTeam[id])
	{
		case 1: Show_MainPnMenu(id);
		case 2: Show_MainGrMenu(id);
		default: Show_ChooseTeamMenu(id, 0);
	}
	return PLUGIN_HANDLED;
}
public ClCmd_MenuSelect(id)
{
	client_cmd(id, "spk buttons/blip1.wav");
	jbe_informer_offset_down(id);
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
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_ERROR_PARAMETERS");
			return PLUGIN_HANDLED;
		}
		iTarget = str_to_num(szArg1);
		iMoney = str_to_num(szArg2);
	}
	if(id == iTarget || !jbe_is_user_valid(iTarget) || IsNotSetBit(g_iBitUserConnected, iTarget)) UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_UNKNOWN_PLAYER");
	else if(g_iUserMoney[id] < iMoney) UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_SUFFICIENT_FUNDS");
	else if(iMoney <= 0) UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_MIN_AMOUNT_TRANSFER");
	else
	{
		jbe_set_user_money(iTarget, g_iUserMoney[iTarget] + iMoney, 1);
		jbe_set_user_money(id, g_iUserMoney[id] - iMoney, 1);
		new szName[32], szNameTarget[32];
		get_user_name(id, szName, charsmax(szName));
		get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
		UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ALL_MONEY_TRANSFER", szName, iMoney, szNameTarget);
	}
	return PLUGIN_HANDLED;
}

public ClCmd_Radio1(id)
{
	if(g_iUserTeam[id] == 1 && IsSetBit(g_iBitClothingGuard, id))
	{
		if(IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id)) UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_BLOCKED_CLOTHING_GUARD");
		else
		{
			if(IsSetBit(g_iBitClothingType, id))
			{
				jbe_set_user_model(id, g_szPlayerModel[PRISONER]);
				if(IsSetBit(g_iBitUserFree, id)) set_pev(id, pev_skin, 5);
				else if(IsSetBit(g_iBitUserWanted, id)) set_pev(id, pev_skin, 6);
				else set_pev(id, pev_skin, g_iUserSkin[id]);
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_REMOVE_CLOTHING_GUARD");
			}
			else
			{
				jbe_set_user_model(id, g_szPlayerModel[GUARD]);
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_DRESSED_CLOTHING_GUARD");
			}
			InvertBit(g_iBitClothingType, id);
		}
	}
	return PLUGIN_HANDLED;
}

public ClCmd_Radio2(id)
{
	if(g_iUserTeam[id] == 1 && get_user_weapon(id) == CSW_KNIFE && (/*IsSetBit(g_iBitSharpening, id) ||*/ IsSetBit(g_iBitScrewdriver, id) /*|| IsSetBit(g_iBitBalisong, id)*/))
	{
		if(IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id))
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_SHOP_WEAPON_BLOCKED");
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
			else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_LATCHKEY_ERROR_DOOR");
		}
		else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_LATCHKEY_ERROR_DOOR");
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
	if( IsSetBit(g_iBitUserWanted, id) || g_iDayMode == 3 || IsNotSetBit(g_iBitUserHook, id) || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id) || task_exists(id+TASK_HOOK_THINK)) return PLUGIN_HANDLED;
	new iOrigin[3];
	get_user_origin(id, iOrigin, 3);
	g_vecHookOrigin[id][0] = float(iOrigin[0]);
	g_vecHookOrigin[id][1] = float(iOrigin[1]);
	g_vecHookOrigin[id][2] = float(iOrigin[2]);
	//CREATE_SPRITE(g_vecHookOrigin[id], g_pSpriteRicho2, 10, 255);
	
	if(g_RandomHook[id])
	{
		if(IsSetBit(g_iBitUserGod, id)) g_StatusHook[id] = random_num(1, 3);
		else if(IsSetBit(g_iBitUserKnyaz, id)) g_StatusHook[id] = random_num(1, 2);
		else g_StatusHook[id] = 1;
	}
	
	switch(g_StatusHook[id])
	{
		case 1: emit_sound(id, CHAN_STATIC, "jb_engine/hook_a.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		case 3: emit_sound(id, CHAN_STATIC, "jb_engine/hook_b.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		case 2: emit_sound(id, CHAN_STATIC, "jb_engine/hook_c.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	
	jbe_hook_think(id+TASK_HOOK_THINK);
	set_task(0.1, "jbe_hook_think", id+TASK_HOOK_THINK, _, _, "b");
	return PLUGIN_HANDLED;
}

public ClCmd_HookOff(id)
{
	if(task_exists(id+TASK_HOOK_THINK))
	{
		remove_task(id+TASK_HOOK_THINK);
		switch(g_StatusHook[id])
		{
			case 1: emit_sound(id, CHAN_STATIC, "jb_engine/hook_a.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			case 2: emit_sound(id, CHAN_STATIC, "jb_engine/hook_b.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			case 3: emit_sound(id, CHAN_STATIC, "jb_engine/hook_c.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		}
	}
	return PLUGIN_HANDLED;
}

public ClCmd_BindKeys(id) client_cmd(id, "^"^";BIND F3 chooseteam;BIND z radio1;BIND x radio2;BIND c radio3");
/*===== <- Консольные команды <- =====*///}

/*===== -> Меню -> =====*///{
#define PLAYERS_PER_PAGE 8

menu_init()
{
	register_menucmd(register_menuid("Show_ChooseTeamMenu"), (1<<0|1<<1|1<<4|1<<5|1<<8|1<<9), "Handle_ChooseTeamMenu");

	register_menucmd(register_menuid("Show_SkinMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4), "Handle_SkinMenu");
	
	register_menucmd(register_menuid("Show_WeaponsGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_WeaponsGuardMenu");
	
	register_menucmd(register_menuid("Show_MainPnMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_MainPnMenu");
	register_menucmd(register_menuid("Show_MainGrMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_MainGrMenu");
	
	register_menucmd(register_menuid("Show_SettingMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_SettingMenu");
	register_menucmd(register_menuid("Show_HookSetting"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), "Handle_HookSetting");
	
	register_menucmd(register_menuid("Show_OfficeMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_OfficeMenu");
	
	register_menucmd(register_menuid("Show_PrivilegeMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_PrivilegeMenu");
	
	register_menucmd(register_menuid("Show_SixPlayerList"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SixPlayerList");
	
	register_menucmd(register_menuid("Show_SisMedMenu"), (1<<0|1<<1|1<<9), "Handle_SisMedMenu");
	
	register_menucmd(register_menuid("Show_ImageMenu"), (1<<0|1<<1|1<<9), "Handle_ImageMenu");
	
	/*-------/ Соприкасание /-------*/
	register_menucmd(register_menuid("Show_TouchGrWithGr"), (1<<0|1<<1|1<<9), "Handle_TouchedGrWitchGr"); // CT - CT
	register_menucmd(register_menuid("Show_TouchGrWithPr"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), "Handle_TouchedGrWitchPr"); // CT - T
	
	register_menucmd(register_menuid("Show_TouchPrWithGr"), (1<<0|1<<1|1<<2|1<<9), "Handle_TouchedPrWitchGr"); // T - CT
	register_menucmd(register_menuid("Show_TouchPrWithPr"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), "Handle_ToucedPrWitchPr"); // T - T
	
	register_menucmd(register_menuid("Show_ShopGuardTradeMenu"), (1<<0|1<<1|1<<2|1<<9), "Handle_ShopGuardTradeMenu");
	register_menucmd(register_menuid("Show_ShopTattooMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<9), "Handle_ShopTattooMenu");
	
	register_menucmd(register_menuid("Show_ShopPrisonersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_ShopPrisonersMenu");
	register_menucmd(register_menuid("Show_ShopWeaponsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<9), "Handle_ShopWeaponsMenu");
	register_menucmd(register_menuid("Show_ShopItemsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ShopItemsMenu");
	register_menucmd(register_menuid("Show_ShopSkillsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_ShopSkillsMenu");
	register_menucmd(register_menuid("Show_ShopOtherMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<9), "Handle_ShopOtherMenu");
	register_menucmd(register_menuid("Show_PrankPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PrankPrisonerMenu");
	register_menucmd(register_menuid("Show_ShopGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_ShopGuardMenu");
	register_menucmd(register_menuid("Show_MoneyTransferMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MoneyTransferMenu");
	register_menucmd(register_menuid("Show_MoneyAmountMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<7|1<<8|1<<9), "Handle_MoneyAmountMenu");
	
//	register_menucmd(register_menuid("Show_HatsMenu"), (1<<0|1<<1|1<<9), "Handle_HatsMenu");
	register_menucmd(register_menuid("Show_CostumesMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_CostumesMenu");
//	register_menucmd(register_menuid("Show_VipCostumesMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_VipCostumesMenu");
	
	register_menucmd(register_menuid("Show_ChiefMenu_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ChiefMenu_1");
	register_menucmd(register_menuid("Show_CountDownMenu"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_CountDownMenu");
	register_menucmd(register_menuid("Show_FreeDayControlMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_FreeDayControlMenu");
	register_menucmd(register_menuid("Show_PunishGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PunishGuardMenu");
	register_menucmd(register_menuid("Show_TransferChiefMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TransferChiefMenu");
	register_menucmd(register_menuid("Show_TreatPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TreatPrisonerMenu");
	register_menucmd(register_menuid("Show_ChiefMenu_2"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ChiefMenu_2");
	register_menucmd(register_menuid("Show_VoiceControlMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_VoiceControlMenu");
	register_menucmd(register_menuid("Show_PrisonersDivideColorMenu"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_PrisonersDivideColorMenu");
	register_menucmd(register_menuid("Show_MiniGameMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_MiniGameMenu");
	register_menucmd(register_menuid("Show_ChiefGameMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ChiefGameMenu");
	register_menucmd(register_menuid("Show_ChiefWeaponsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ChiefWeaponsMenu");
	register_menucmd(register_menuid("Show_RandomChiefNum"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_RandomNum");
	register_menucmd(register_menuid("Show_SoccerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_SoccerMenu");
	register_menucmd(register_menuid("Show_SoccerTeamMenu"), (1<<0|1<<1|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SoccerTeamMenu");
	register_menucmd(register_menuid("Show_SoccerScoreMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_SoccerScoreMenu");
	register_menucmd(register_menuid("Show_BoxingMenu"), (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), "Handle_BoxingMenu");
	register_menucmd(register_menuid("Show_BoxingTeamMenu"), (1<<0|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_BoxingTeamMenu");
	register_menucmd(register_menuid("Show_KillReasonsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_KillReasonsMenu");
	register_menucmd(register_menuid("Show_KilledUsersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_KilledUsersMenu");
	register_menucmd(register_menuid("Show_LastPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_LastPrisonerMenu");
	register_menucmd(register_menuid("Show_ChoiceDuelMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ChoiceDuelMenu");
	register_menucmd(register_menuid("Show_DuelUsersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DuelUsersMenu");
	register_menucmd(register_menuid("Show_DayModeMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DayModeMenu");
	register_menucmd(register_menuid("Show_VipMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_VipMenu");
	register_menucmd(register_menuid("Show_AdminMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_AdminMenu");
	register_menucmd(register_menuid("Show_SuperAdminMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_SuperAdminMenu");
	register_menucmd(register_menuid("Show_GodMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_GodMenu");
	register_menucmd(register_menuid("Show_BlockedGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_BlockedGuardMenu");
	register_menucmd(register_menuid("Show_BlockMenuFunction"), (1<<0|1<<1|1<<2|1<<9), "Handle_BlockMenuFunc");
	register_menucmd(register_menuid("Show_ManageSoundMenu"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_ManageSoundMenu");
}
Show_ImageMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[1024], iKeys = (1<<0|1<<1|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\yМеню Репутации^nВаш опыт: \r[%d]^n^n", g_iExp[id]);

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ %s%L \d", (g_iExp[id] < 1000 || g_iImageBlock[id][3] != 0)?"\d":"\w", id, "JBE_IMAGE_GLOCK18");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%s", (g_iExp[id] < 1000) ? " [Нужно больше 1000 EXP]^n":"^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ %s%L \d", (g_iExp[id] < 400 || g_iImageBlock[id][4] != 0)?"\d":"\w", id, "JBE_IMAGE_HEALTH");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%s", (g_iExp[id] < 400) ? " [Нужно больше 400 EXP]^n":"^n");

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ImageMenu");
}

public Handle_ImageMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			if(g_iExp[id] < 1000) { UTIL_SayText(id, "!y[!gIS-GAMING!y] У Вас нету !tзнакомых!y для мутки !gигрушки!"); return PLUGIN_HANDLED; }
			if(g_iImageBlock[id][3] == 0)
			{
				g_iImageBlock[id][3] = 6;
				fm_give_item(id, "weapon_glock18");
			}else UTIL_SayText(id, "!y[!gIS-GAMING!y] У !tбратков !gзакончился !tGlock!y, жди !g%d !tдней", g_iImageBlock[id][3]);
		}
		case 1:
		{
			if(g_iExp[id] < 500) { UTIL_SayText(id, "!y[!gIS-GAMING!y] У тя нету !gтортика!t!!"); return PLUGIN_HANDLED; }
			if(g_iImageBlock[id][4] == 0)
			{
				g_iImageBlock[id][4] = 3;
				set_user_health(id, get_user_health(id) + 255);
			}else UTIL_SayText(id, "!y[!gIS-GAMING!y] У тя !tзакончился !gторт!y, жди !g%d !tдней", g_iImageBlock[id][4]);
		}
		case 9: return PLUGIN_HANDLED;
	}
	g_IdTouchPlayer[id] = 0;
	return Show_ImageMenu(id);
}
Show_TouchPrWithGr(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<2|1<<9), pName[32]; get_user_name(g_IdTouchPlayer[id], pName, charsmax(pName));
	
	new iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_TOUCH",
	jbe_get_user_team(g_IdTouchPlayer[id]) == 1 ? "Заключенный":"Охранник", pName);

	if(g_iTouchSteal[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_STEAL_MONEY");
		iKeys |= (1<<0);
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n", id, "JBE_STEAL_MONEY");
	
	if(user_has_weapon(g_IdTouchPlayer[id], CSW_DEAGLE)|| user_has_weapon(g_IdTouchPlayer[id], CSW_USP)|| user_has_weapon(g_IdTouchPlayer[id], CSW_GLOCK18))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_STEAL_PISTOL");
		iKeys |= (1<<1);
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [У игрока нету пистолета]^n", id, "JBE_STEAL_PISTOL");
	
	if(g_IdTouchPlayer[id] == g_iChiefId)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ %s%L", (g_iExp[id] < 400 || g_iImageBlock[id][0] != 0)?"\d":"\w", id, "JBE_IMAGE_FREEDAY");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%s", (g_iExp[id] < 400) ? " [Нужно больше 400 EXP]^n":"^n");
	}else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ %s%L", (g_iExp[id] < 200 || g_iImageBlock[id][1] != 0)?"\d":"\w", id, "JBE_IMAGE_STEAM_GRENADES");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%s", (g_iExp[id] < 200) ? " [Нужно больше 200 EXP]^n":"^n");
	}
		
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 1, "Show_TouchPrWithGr");
}
public Handle_TouchedPrWitchGr(id, iKey)
{
	new pName[33], tName[33];
	get_user_name(g_IdTouchPlayer[id], tName, charsmax(tName));
	get_user_name(id, pName, charsmax(pName));
	switch(iKey)
	{
		case 0:
		{
			g_iTouchSteal[id] = false;
			new iMoney = jbe_get_user_money(g_IdTouchPlayer[id]) / 10;
			new iRandom = random_num(1, 2);
			switch(iRandom)
			{
				case 1:
				{
					jbe_set_user_money(id, jbe_get_user_money(id) + iMoney, 1);
					jbe_set_user_money(g_IdTouchPlayer[id], jbe_get_user_money(g_IdTouchPlayer[id]) - iMoney, 1);
					UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы стащили у !g%s!y !t%d$", tName, iMoney);
					UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Кто-то стащил у Вас !g%d$", iMoney);
				}
				case 2:
				{
					UTIL_SayText(0, "!y[!gIS-GAMING!y] Заключенный !g%s!y попытался стащить деньги у охранника !g%s!y - !tнеудачно", pName, tName);
					jbe_add_user_wanted(id);
				}
			}
		}
		case 1:
		{
			new iRandom = random_num(1, 2);
			switch(iRandom)
			{
				case 1:
				{
					if(user_has_weapon(g_IdTouchPlayer[id], CSW_DEAGLE)) 
					{
						ham_strip_weapon(g_IdTouchPlayer[id], "weapon_deagle");
						give_item(id, "weapon_deagle");
					}
					else if(user_has_weapon(g_IdTouchPlayer[id], CSW_GLOCK18)) 
					{
						ham_strip_weapon(g_IdTouchPlayer[id], "weapon_glock18");
						give_item(id, "weapon_glock18");
					}
					else if(user_has_weapon(g_IdTouchPlayer[id], CSW_USP))
					{
						ham_strip_weapon(g_IdTouchPlayer[id], "weapon_usp");
						give_item(id, "weapon_usp");
					}
				}
				case 2:
				{
					UTIL_SayText(0, "!y[!gIS-GAMING!y] Заключенный !g%s!y попытался стащить пистолет у охранника !g%s!y - !tнеудачно", pName, tName);
					jbe_add_user_wanted(id);
				}
			}
		}
		case 2:
		{
			if(g_IdTouchPlayer[id] == g_iChiefId)
			{
				if(g_iExp[id] < 400) { UTIL_SayText(id, "!y[!gIS-GAMING!y] Те !gнавешают!y, олень!"); return PLUGIN_HANDLED; }
				if(g_iImageBlock[id][0] == 0)
				{
					g_iImageBlock[id][0] = 5;
					jbe_add_user_free(id);
				}else UTIL_SayText(id, "!y[!IS-GAMING!y] !gСаймон !tне разрешает !yвыдавать Вам !gвыходной !y, приходи через !g%d !tдней", g_iImageBlock[id][0]);
			}else{
				if(g_iExp[id] < 240) { UTIL_SayText(id, "!y[!gIS-GAMING!y] !gМал!y еще, иди гуляй!"); return PLUGIN_HANDLED; }
				if(get_user_weapon(g_IdTouchPlayer[id]) == CSW_SMOKEGRENADE || get_user_weapon(g_IdTouchPlayer[id]) == CSW_HEGRENADE || get_user_weapon(g_IdTouchPlayer[id]) == CSW_FLASHBANG)
				{
					if(g_iImageBlock[id][1] == 0)
					{
						g_iImageBlock[id][1] = 3;
						fm_give_item(id, "weapon_smokegrenade");
						fm_give_item(id, "weapon_hegrenade");
						fm_give_item(id, "weapon_flashbang");
					}else UTIL_SayText(id, "!y[!gIS-GAMING!y] Ты уже тырил у !tохраны !tгранаты!y, жди !g%d !tдней", g_iImageBlock[id][1]);
				}else  UTIL_SayText(id, "!y[!gIS-GAMING!y] У !tохранника !y[!gзакончились!y|!gнету ни одной!y] !tгранаты");
			}
		}
		case 9: return PLUGIN_HANDLED;
	}
	g_IdTouchPlayer[id] = 0;
	return PLUGIN_HANDLED;
}
Show_TouchPrWithPr(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), pName[32]; get_user_name(g_IdTouchPlayer[id], pName, charsmax(pName));
	
	new iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_TOUCH",
	jbe_get_user_team(g_IdTouchPlayer[id]) == 1 ? "Заключенный":"Охранник", pName);

	if(g_PrBeat[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_BEAT");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Вы уже дрались]^n", id, "JBE_BEAT");
	
	if(IsSetBit(g_iBitWeaponStatus, g_IdTouchPlayer[id]) || 
	IsSetBit(g_iBitScrewdriver, g_IdTouchPlayer[id])) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [У игрока уже есть оружие]^n", id, "JBE_GIVE_WEAPON");
	else if(IsNotSetBit(g_iBitWeaponStatus, id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [У вас нету оружия](Если есть возьми в руку)^n", id, "JBE_GIVE_WEAPON");
	else if(IsNotSetBit(g_iBitWeaponStatus, g_IdTouchPlayer[id] ) &&  IsSetBit(g_iBitWeaponStatus, id) &&
	(IsSetBit(g_iBitScrewdriver, g_IdTouchPlayer[id])) )
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_GIVE_WEAPON");
		iKeys |= (1<<1);
	}
	if(g_iExp[id] > g_iExp[ g_IdTouchPlayer[id] ])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ %s%L^n", (g_iImageBlock[id][0] != 0)?"\d":"\w", id, "JBE_IMAGE_PRESANUT");
		iKeys |= (1<<2);
	}
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 1, "Show_TouchPrWithPr");
}
public Handle_ToucedPrWitchPr(id, iKey)
{
	new pName[33], tName[33];
	get_user_name(g_IdTouchPlayer[id], tName, charsmax(tName));
	get_user_name(id, pName, charsmax(pName));
	switch(iKey)
	{
		case 0:
		{
			new Am_Win[33][2];	// 1 - Атакующий, 2 - защитник ( g_IdTouchPlayer[id] )
			new iRand = random_num(1, 2);
			switch(iRand)
			{
				case 1: Am_Win[id][0]++;
				case 2: Am_Win[id][1]++;
			}
			
			//if(ujbl_get_protection_skills(id) > ujbl_get_protection_skills(g_IdTouchPlayer[id])) Am_Win[id][0]++;
			//else if(ujbl_get_protection_skills(id) < ujbl_get_protection_skills(g_IdTouchPlayer[id])) Am_Win[id][1]++;
			
			//if(ujbl_get_agility_skills(id) > ujbl_get_agility_skills(g_IdTouchPlayer[id])) Am_Win[id][0]++;
			//else if(ujbl_get_agility_skills(id) < ujbl_get_agility_skills(g_IdTouchPlayer[id])) Am_Win[id][1]++;
			
			//if(ujbl_get_lot_skills(id) > ujbl_get_lot_skills(g_IdTouchPlayer[id])) Am_Win[id][0]++;
			//else if(ujbl_get_lot_skills(id) < ujbl_get_lot_skills(g_IdTouchPlayer[id])) Am_Win[id][1]++;
			
			client_cmd(id, "mp3 play sound/jb_engine/fight_track.mp3");
			client_cmd(g_IdTouchPlayer[id], "mp3 play sound/jb_engine/fight_track.mp3");
			
			g_PrBeat[id] = false;
			
			if(Am_Win[id][0] == Am_Win[id][1])
			{
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы подрались с !g%s!y. !gНичья!y. Сумма ваших скиллов: !t%d|%d", tName, Am_Win[id][0], Am_Win[id][1]);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] На Вас напал !g%s!y. !gНичья!y. Сумма ваших скиллов: !t%d|%d", pName, Am_Win[id][1], Am_Win[id][0]);
				return PLUGIN_HANDLED;
			}else if(Am_Win[id][0] > Am_Win[id][1])
			{
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы избили !g%s!y и отобрали у него всякий хлам. !gПобеда!y. Сумма ваших скиллов: !t%d|%d", tName, Am_Win[id][0], Am_Win[id][1]);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Вас избил !g%s!y и отобрал у вас всякий хлам. !gПроигрыш!y. Сумма ваших скиллов: !t%d|%d", pName, Am_Win[id][1], Am_Win[id][0]);
				
				new iMoney = g_iUserMoney[g_IdTouchPlayer[id]] / 10;
				g_iUserMoney[g_IdTouchPlayer[id]] -= iMoney;
				g_iUserMoney[id] += iMoney;
				
				new iArm = get_arm(g_IdTouchPlayer[id]) / 10;
				set_user_armor(id, get_arm(id) + iArm);
				set_user_armor(g_IdTouchPlayer[id], get_arm(g_IdTouchPlayer[id]) - iArm);
				
				if(get_user_health(g_IdTouchPlayer[id]) >= 20) set_user_health(g_IdTouchPlayer[id], get_user_health(g_IdTouchPlayer[id]) - 20);
				else set_user_health(g_IdTouchPlayer[id], 5);
				
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы отобрали у !tзащищающего: !g%d$ !yи !g%d брони", iMoney, iArm);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] у Вас отобрал !tатакующий: !g%d$ !yи !g%d брони", iMoney, iArm);
				
				return PLUGIN_HANDLED;
			}else if(Am_Win[id][0] < Am_Win[id][1])
			{
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы попытались избить !g%s!y но проиграли. !gПроигрыш!y. Сумма ваших скиллов: !t%d|%d", tName, Am_Win[id][0], Am_Win[id][1]);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Вас попытался избить !g%s!y вы ему навешали. !gПобеда!y. Сумма ваших скиллов: !t%d|%d", pName, Am_Win[id][1], Am_Win[id][0]);
				
				new iMoney = g_iUserMoney[id] / 10;
				g_iUserMoney[g_IdTouchPlayer[id]] += iMoney;
				g_iUserMoney[id] -= iMoney;
				
				new iArm = get_arm(id) / 10;
				set_user_armor(id, get_arm(id) - iArm);
				set_user_armor(g_IdTouchPlayer[id], get_arm(g_IdTouchPlayer[id]) + iArm);
				
				if(get_user_health(id) >= 20) set_user_health(id, get_user_health(id) - 20);
				else set_user_health(id, 5);
				
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Вы отобрали у !tнападающего: !g%d$ !yи !g%d брони", iMoney, iArm);
				UTIL_SayText(id, "!y[!gIS-GAMING!y] у Вас отобрал !tзащитник: !g%d$ !yи !g%d брони", iMoney, iArm);
				
				return PLUGIN_HANDLED;
			}
			
		}
		case 1:
		{	
			/*
			new YouWeapon[33];
			
			if(IsSetBit(g_iBitSharpening, id)) YouWeapon[id] = 0;
			else if(IsSetBit(g_iBitScrewdriver, id)) YouWeapon[id] = 1;
			else if(IsSetBit(g_iBitBalisong, id)) YouWeapon[id] = 2;
			else return PLUGIN_HANDLED;
			
			for(new iii; iii <= 2; iii++) ClearBit(CheckWeapon(iii), id);
			SetBit(CheckWeapon(YouWeapon[id]), g_IdTouchPlayer[id]);
			UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Игрок !g%s!y передал вам !gОружие.", pName);
			
			if(IsSetBit(g_iBitWeaponStatus, g_IdTouchPlayer[id]) && get_user_weapon(g_IdTouchPlayer[id]) == CSW_KNIFE)
			{												
				new iActiveItem = get_pdata_cbase(g_IdTouchPlayer[id], m_pActiveItem);
				if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
			}
			else UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] %L", g_IdTouchPlayer[id], "JBE_CHAT_ID_SHOP_WEAPON_HELP");	
			*/
			/*if(IsSetBit(g_iBitSharpening, id)) 
			{
				ClearBit(g_iBitSharpening, id);
				SetBit(g_iBitSharpening, g_IdTouchPlayer[id]);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Игрок !g%s!y передал вам !gЗаточку.", pName);
				if(IsSetBit(g_iBitWeaponStatus, g_IdTouchPlayer[id]) && get_user_weapon(g_IdTouchPlayer[id]) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(g_IdTouchPlayer[id], m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] %L", g_IdTouchPlayer[id], "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				jbe_set_hand_model(id);
			}else */
			if(IsSetBit(g_iBitScrewdriver, id)) 
			{
				ClearBit(g_iBitScrewdriver, id);
				SetBit(g_iBitScrewdriver, g_IdTouchPlayer[id]);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Игрок !g%s!y передал вам !gОтвертку.", pName);
				if(IsSetBit(g_iBitWeaponStatus, g_IdTouchPlayer[id]) && get_user_weapon(g_IdTouchPlayer[id]) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(g_IdTouchPlayer[id], m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] %L", g_IdTouchPlayer[id], "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				jbe_set_hand_model(id);
			}/*else
			if(IsSetBit(g_iBitBalisong, id)) 
			{
				ClearBit(g_iBitBalisong, id);
				SetBit(g_iBitBalisong, g_IdTouchPlayer[id]);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] Игрок !g%s!y передал вам !gОтвертку.", pName);
				if(IsSetBit(g_iBitWeaponStatus, g_IdTouchPlayer[id]) && get_user_weapon(g_IdTouchPlayer[id]) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(g_IdTouchPlayer[id], m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] %L", g_IdTouchPlayer[id], "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				jbe_set_hand_model(id);
			}*/
		}
		case 2:
		{
			if(g_iImageBlock[id][2] == 0)
			{
				g_iImageBlock[id][2] = 4;
				
				client_cmd(id, "mp3 play sound/jb_engine/fight_track.mp3");
				client_cmd(g_IdTouchPlayer[id], "mp3 play sound/jb_engine/fight_track.mp3");
				
				new tMoney = g_iUserMoney[ g_IdTouchPlayer[id] ] / 10;
				g_iUserMoney[id] += tMoney;
				g_iUserMoney[g_IdTouchPlayer[id]] -= tMoney;
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы пресанули !g%s!y на !t[%d]!y из-за того вы  !g%L!y а он !g%L", tName, tMoney, id, g_szRankName[g_iLevel[id]], id, g_szRankName[g_iLevel[g_IdTouchPlayer[id]]]);
				UTIL_SayText(g_IdTouchPlayer[id], "!y[!gIS-GAMING!y] !g%s!y пресанул Вас на бабло !t[%d]!y из-за того что он !g%L!y а Вы !g%L", pName, tMoney, id, g_szRankName[g_iLevel[id]], id, g_szRankName[g_iLevel[g_IdTouchPlayer[id]]]);
			}else UTIL_SayText(id, "!y[!gIS-GAMING!y] Ты уже кого-то !gмутузил!y, жди !g%d !tдней", g_iImageBlock[id][2]);
		}
		case 9: return PLUGIN_HANDLED;
	}
	g_IdTouchPlayer[id] = 0;
	return PLUGIN_HANDLED;
}

Show_TouchGrWithGr(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<9), pName[32]; get_user_name(g_IdTouchPlayer[id], pName, charsmax(pName));
	
	new iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_TOUCH",
	jbe_get_user_team(g_IdTouchPlayer[id]) == 1 ? "Заключенный":"Охранник", pName);

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_PAY_AMMO");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ %s%L^n^n", get_arm(id) >= 10 ? "\w":"\d", id, "JBE_PAY_ARMOR");
	
	if(get_arm(id) >= 10) iKeys |= (1<<1);

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 1, "Show_TouchGrWithGr");
}
public Handle_TouchedGrWitchGr(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			new iWeapon[2], weapon_name[24][2];	// [0] - Соприкоснувшийся, [1] - к кому игрок соприкоснулся
			iWeapon[0] = get_user_weapon(id), 
			iWeapon[1] = get_user_weapon(g_IdTouchPlayer[id]), 
			get_weaponname(iWeapon[0], weapon_name[0], 24);
			get_weaponname(iWeapon[1], weapon_name[1], 24);
			new ammo[2], clip[2];
			get_user_ammo(id, iWeapon[0], clip[0], ammo[0]);
			get_user_ammo(g_IdTouchPlayer[id], iWeapon[1], clip[1], ammo[1]);
			if(ammo[0] >= 10 && get_user_weapon(g_IdTouchPlayer[id]) != CSW_KNIFE)
			{
				cs_set_user_bpammo(id, get_user_weapon(id), ammo[0] - 10);
				cs_set_user_bpammo(g_IdTouchPlayer[id], get_user_weapon(g_IdTouchPlayer[id]), ammo[1] + 10);
			}else return Show_TouchGrWithGr(id);
		}
		case 1:
		{
			new p_Armor = get_arm(id), t_Armor = get_arm(g_IdTouchPlayer[id]);
			set_user_armor(id, p_Armor - 10);
			set_user_armor(g_IdTouchPlayer[id], t_Armor + 10);
		}
		case 9: return PLUGIN_HANDLED;
	}
	g_IdTouchPlayer[id] = 0;
	return PLUGIN_HANDLED;
}
Show_TouchGrWithPr(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), pName[32]; get_user_name(g_IdTouchPlayer[id], pName, charsmax(pName));
	
	new iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_TOUCH",
	jbe_get_user_team(g_IdTouchPlayer[id]) == 1 ? "Заключенный":"Охранник", pName);

	if(g_iShockerWp[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_BASH");
		iKeys |= (1<<0);
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \d[\wУ вас нету шокера, купите его у барыге\d]^n", id, "JBE_BASH");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ %s%L^n^n", get_arm(g_IdTouchPlayer[id]) >= 10 ? "\w":"\d", id, "JBE_ARMOR_PICKUP");
	
	if(get_arm(g_IdTouchPlayer[id]) >= 10) iKeys |= (1<<1);

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 1, "Show_TouchGrWithPr");
}
public Handle_TouchedGrWitchPr(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			if(!g_iShockerWp[id]) return PLUGIN_HANDLED;
			set_pev(g_IdTouchPlayer[id], pev_punchangle, { 100.0, 200.0, 400.0 });
			set_pev(g_IdTouchPlayer[id], pev_flags, pev(g_IdTouchPlayer[id], pev_flags) | FL_FROZEN);
			set_task(2.0, "UnFreezie_TouchPlayer", g_IdTouchPlayer[id] + 901512);
		}
		case 1:
		{
			new pName[33], tName[33];
			get_user_name(g_IdTouchPlayer[id], tName, charsmax(tName));
			get_user_name(id, pName, charsmax(pName));
			new p_Armor = get_arm(id), t_Armor = get_arm(g_IdTouchPlayer[id]);
			set_user_armor(id, p_Armor + 10);
			set_user_armor(g_IdTouchPlayer[id], t_Armor - 10);
			UTIL_SayText(0, "!y[!gIS-GAMING!y] Охранник !g%s!y забрал 10 ед. брони у заключенного !g%s", pName, tName);
		}
		case 9: return PLUGIN_HANDLED;
	}
	g_IdTouchPlayer[id] = 0;
	return PLUGIN_HANDLED;
}
public UnFreezie_TouchPlayer(i)
{
	i -= 901512;
	set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
}

Show_SisMedMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<9), pName[32]; get_user_name(g_IdTouchMedSis[id], pName, charsmax(pName));
	new iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MEDSIS_TITLE", pName, get_user_health(g_IdTouchMedSis[id]), g_MedSis_Health[id]);

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_MEDSIS_INHEALTH");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ %s%L^n^n", (g_MedSis_Health[id] > 0) ? "\w":"\d", id, "JBE_MENU_MEDSIS_HEALTH", g_MedSis_Health[id]);
	if(g_MedSis_Health[id] > 0) iKeys |= (1<<1);

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 1, "Show_SisMedMenu");
}
public Handle_SisMedMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: set_user_health(g_IdTouchMedSis[id], get_user_health(g_IdTouchMedSis[id]) + 1);
		case 1: 
		{
			remove_task(id + TASK_MEDSIS_HEALTHGIVE);
			new pName[32]; get_user_name(g_IdTouchMedSis[id], pName, charsmax(pName));
			g_MedSis_Health[id]--;
			set_user_health(g_IdTouchMedSis[id], get_user_health(g_IdTouchMedSis[id]) + 100);
			UTIL_SayText(0, "!y[!gIS-GAMING!y]!y Мед-сестра вылечила !g%s!y.", pName);
			
//			client_cmd(g_IdTouchMedSis[id], "mp3 play sound/jb_engine/ujbl_new/jb_medsis_healting.mp3");
			
			UTIL_SayText(id, "!y[!gIS-GAMING!y] Ваша !gАптечка!y будет восстановлена через !g1 минуту.");
			if(task_exists(id + TASK_MEDSIS_HEALTHGIVE)) remove_task(id + TASK_MEDSIS_HEALTHGIVE);
			set_task(60.0, "F_iMsPack", id + TASK_MEDSIS_HEALTHGIVE);
		}
	}
	g_IdTouchMedSis[id] = 0;
}

Open_SixPlayerList(id) return Show_SixPlayerList(id, g_iMenuPosition[id] = 0);
Show_SixPlayerList(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] == 1 && IsSetBit(g_iBitUserConnected, i) && i != g_AthrID && i != g_MedSisID && IsSetBit(g_iBitUserAlive, i))
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
			UTIL_SayText(id, "!y[!gIS-GAMING!y]!y %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_SIXPLAYER_LIST", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SixPlayerList");
}

public Handle_SixPlayerList(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_SixPlayerList(id, ++g_iMenuPosition[id]);
		case 9: return Show_SixPlayerList(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			get_user_name(iTarget, sz_SixPlName, charsmax(sz_SixPlName));
			set_user_sixplayer(iTarget);
			g_SixPlID = iTarget;
			UTIL_SayText(0, "!y[!gIS-GAMING!y] !yБлатной !g%s!y выбрал себе !gШесняря!y - !t%s", sz_AthrName, sz_SixPlName);
		}
	}
	return PLUGIN_HANDLED;
}

Show_PrivilegeMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MAIN_TITLE");

	if(!g_iBlockFunction[1] && (g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserVip, id) && g_iDuelStatus == 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_MAIN_VIP");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n", id, "JBE_MENU_MAIN_VIP");
	if(IsSetBit(g_iBitUserAdmin, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_MAIN_ADMIN");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_MAIN_ADMIN");
	if(!g_iBlockFunction[1] && (g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserSuperAdmin, id) && g_iDuelStatus == 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_MAIN_SUPER_ADMIN");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_MAIN_SUPER_ADMIN");

	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserGodMenu, id) && g_iDuelStatus == 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_MAIN_GODMENU");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_MAIN_GODMENU");

	if(g_iBlockFunction[1]) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\dВнимание!^nСтоит глобальная блокировка привилегий!^nПросите ГодМенюшника включить!^n");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrivilegeMenu");
}

public Handle_PrivilegeMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == 1 || g_iDayMode == 2)) return Show_VipMenu(id);
		case 1: return Show_AdminMenu(id);
		case 2: if((g_iDayMode == 1 || g_iDayMode == 2)) return Show_SuperAdminMenu(id);	
		case 3: if((g_iDayMode == 1 || g_iDayMode == 2)) return Show_GodMenu(id);
		case 9: return PLUGIN_HANDLED;		
	}
	return PLUGIN_HANDLED;
}

Show_ChooseTeamMenu(id, iType)
{
//	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys, iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n", id, "JBE_MENU_TEAM_TITLE", g_iAllCvars[TEAM_BALANCE]);
	if(g_iUserTeam[id] != 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \r[%d]^n", id, "JBE_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \r[%d]^n", id, "JBE_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
	
	if(!g_iBlockFunction[2])
	{
		if(!g_iBlockCtForName[id])
		{
			if(IsNotSetBit(g_iBitUserBlockedGuard, id) && g_iUserTeam[id] != 2 && ((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \r[%d]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_TEAM_RANDOM");
				iKeys |= (1<<1|1<<4);
			}
			else
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \r[%d]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L^n", id, "JBE_MENU_TEAM_RANDOM");
			}
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\wУ Вас стандартный ник! Доступ за КТ - закрыт^nПожалуйста, смените его и перезайдите^n\y[2]\r ~ \d%L \r[%d]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L^n", id, "JBE_MENU_TEAM_RANDOM");
		}
	}
	else 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \r[%d] \d[\wСтоит глобальная блокировка\d]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L \d[\wСтоит глобальная блокировка\d]^n", id, "JBE_MENU_TEAM_RANDOM");
	}
	
	if(g_iUserTeam[id] != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n^n^n^n", id, "JBE_MENU_TEAM_SPECTATOR");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L^n^n^n^n^n", id, "JBE_MENU_TEAM_SPECTATOR");
	if(iType)
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
			if(IsNotSetBit(g_iBitUserBlockedGuard, id) && ((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2])
			{
				if(!jbe_set_user_team(id, 2)) return PLUGIN_HANDLED;
				jbe_informer_offset_down(id);
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
						jbe_informer_offset_down(id);
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

Show_ShopTattooMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SHOPTATTOO_MENU_TITLE");
	
	if(g_iTattoo[id] != 1)
	{
		if(g_iExp[id] >= 100) 
		{
			if(g_iUserMoney[id] >= 300)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \wНабить \r%L^n", id, "JBE_SHOPTATTOO_TATTOO_1");	
				iKeys |= (1<<0);
			}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Мало денег][300+]^n", id, "JBE_SHOPTATTOO_TATTOO_1");
		}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Мало Опыта][100+]^n", id, "JBE_SHOPTATTOO_TATTOO_1");	
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Уже активна]^n", id, "JBE_SHOPTATTOO_TATTOO_1");

	if(g_iTattoo[id] != 2)
	{
		if(g_iExp[id] >= 200) 
		{
			if(g_iUserMoney[id] >= 400)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \wНабить \r%L^n", id, "JBE_SHOPTATTOO_TATTOO_2");	
				iKeys |= (1<<1);
			}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [Мало денег][400+]^n", id, "JBE_SHOPTATTOO_TATTOO_2");
		}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [Мало Опыта][200+]^n", id, "JBE_SHOPTATTOO_TATTOO_2");	
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [Уже активна]^n", id, "JBE_SHOPTATTOO_TATTOO_2");

	if(g_iTattoo[id] != 3)
	{
		if(g_iExp[id] >= 300) 
		{
			if(g_iUserMoney[id] >= 500)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \wНабить \r%L^n", id, "JBE_SHOPTATTOO_TATTOO_3");	
				iKeys |= (1<<2);
			}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [Мало денег][500+]^n", id, "JBE_SHOPTATTOO_TATTOO_3");
		}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [Мало Опыта][300+]^n", id, "JBE_SHOPTATTOO_TATTOO_3");	
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [Уже активна]^n", id, "JBE_SHOPTATTOO_TATTOO_3");

	if(g_iTattoo[id] != 4)
	{
		if(g_iExp[id] >= 500) 
		{
			if(g_iUserMoney[id] >= 1000)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \wНабить \r%L^n", id, "JBE_SHOPTATTOO_TATTOO_4");	
				iKeys |= (1<<3);
			}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L [Мало денег][1000+]^n", id, "JBE_SHOPTATTOO_TATTOO_4");
		}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L [Мало Опыта][500+]^n", id, "JBE_SHOPTATTOO_TATTOO_4");	
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L [Уже активна]^n", id, "JBE_SHOPTATTOO_TATTOO_4");

	if(g_iTattoo[id] != 5)
	{
		if(IsSetBit(g_iBitUserSuperAdmin, id))
		{
			if(g_iUserMoney[id] >= 2000)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \wНабить \r%L^n^n", id, "JBE_SHOPTATTOO_TATTOO_5");	
				iKeys |= (1<<4);
			}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [Мало денег][2000+]^n^n", id, "JBE_SHOPTATTOO_TATTOO_5");
		}else{
			if(g_iExp[id] >= 1000) 
			{
				if(g_iUserMoney[id] >= 2000)
				{
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \wНабить \r%L^n^n", id, "JBE_SHOPTATTOO_TATTOO_5");	
					iKeys |= (1<<4);
				}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [Мало денег][2000+]^n^n", id, "JBE_SHOPTATTOO_TATTOO_5");
			}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [Мало Опыта][1000+]^n^n", id, "JBE_SHOPTATTOO_TATTOO_5");	
		}
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [Уже активна]^n^n", id, "JBE_SHOPTATTOO_TATTOO_5");

	if(g_iTattoo[id] != 0)
	{
		if(g_iUserMoney[id] >= 100)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \r%L^n^n", id, "JBE_SHOPTATTOO_TATTOO_6");	
			iKeys |= (1<<5);
		}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L [Мало денег][100+]^n^n", id, "JBE_SHOPTATTOO_TATTOO_6");
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L [Нету татуировки]^n^n", id, "JBE_SHOPTATTOO_TATTOO_6");

	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \d%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopTattooMenu");
}

public Handle_ShopTattooMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			jbe_set_user_money(id, g_iUserMoney[id] - 300, 1);
			g_iTattoo[id] = 1;
		}
		case 1:
		{
			jbe_set_user_money(id, g_iUserMoney[id] - 400, 1);
			g_iTattoo[id] = 2;
		}
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] - 500, 1);
			g_iTattoo[id] = 3;
		}
		case 3:
		{
			jbe_set_user_money(id, g_iUserMoney[id] - 1000, 1);
			g_iTattoo[id] = 4;
		}
		case 4:
		{
			jbe_set_user_money(id, g_iUserMoney[id] - 2000, 1);
			g_iTattoo[id] = 5;
		}
		case 5:
		{
			jbe_set_user_money(id, g_iUserMoney[id] - 100, 1);
			g_iTattoo[id] = 0;
		}
		case 9: return PLUGIN_HANDLED;
	}
	if(iKey < 5 && id != g_AthrID &&  id != g_SixPlID && id != g_MedSisID && get_user_weapon(id) == CSW_KNIFE && IsNotSetBit(g_iBitWeaponStatus, id) && jbe_get_user_team(id) == 1) Set_TattoModel(id);
	return PLUGIN_HANDLED;
}

public Set_TattoModel(id)
{
	if(g_iTattoo[id] == 0 || g_iTattoo[id] > 5) return PLUGIN_HANDLED;
	new szModels[64];
	format(szModels, charsmax(szModels), "models/jb_engine/ujbl_new/shop_tattoo/v_tattoo%d.mdl", g_iTattoo[id]);
	new iszViewModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, szModels))) set_pev_string(id, pev_viewmodel2, iszViewModel);
	set_pdata_float(id, m_flNextAttack, 0.75);
	return PLUGIN_HANDLED;
}

Show_ShopGuardTradeMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_GUARD_SHOP_TRADE_TITLE");
	
	if(!g_iShockerWp[id])
	{
		if(jbe_get_user_money(id) >= 60)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \d[60$]^n^n", id, "JBE_GUARD_SHOP_TRADE_SHOCKER");
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Недостаточно денег]^n^n", id, "JBE_GUARD_SHOP_TRADE_SHOCKER");
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [У Вас уже есть Шокер денег]^n^n", id, "JBE_GUARD_SHOP_TRADE_SHOCKER");

	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \d%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 1, "Show_ShopGuardTradeMenu");
}

public Handle_ShopGuardTradeMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			jbe_set_user_money(id, jbe_get_user_money(id) - 60, 1);
			g_iShockerWp[id] = true;
			UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы купили !gШокер-Дубинку !t(Новая технология)");
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

Show_SkinMenu(id)
{
	jbe_informer_offset_up(id);
	jbe_menu_block(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SKIN_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SKIN_ORANGE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SKIN_GRAY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_SKIN_YELLOW");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_SKIN_BLUE");
	if(IsSetBit(g_iBitUserAdmin, id))
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L", id, "JBE_MENU_SKIN_BLACK");
		iKeys |= (1<<4);
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L", id, "JBE_MENU_SKIN_BLACK");
	return show_menu(id, iKeys, szMenu, -1, "Show_SkinMenu");
}

public Handle_SkinMenu(id, iKey)
{
	g_iUserSkin[id] = iKey;
	engclient_cmd(id, "joinclass", "1");
	jbe_menu_unblock(id);
}
public GiveRandomCTweapon(id)
{
	id -= 98708;
	Handle_WeaponsGuardMenu(id, 1);
}

//native jbe_give_brickpeacev(id);
Show_WeaponsGuardMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_WEAPONS_GUARD_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1] \w%L^n", id, "JBE_MENU_WEAPONS_GUARD_AK47");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2] \w%L^n", id, "JBE_MENU_WEAPONS_GUARD_M4A1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3] \w%L^n", id, "JBE_MENU_WEAPONS_GUARD_AWP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4] \w%L^n^n", id, "JBE_MENU_WEAPONS_GUARD_XM1014");
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5] \wM4A1 | Lego \y[\rВип\y]^n");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5] \dM4A1 | Lego \y[\rВип\\y]^n");
	if(get_user_flags(id) & ADMIN_BAN)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6] \wM4A1 | DarKing \y[\rАдмин\y]^n");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6] \dM4A1 | DarKing \y[\rАдмин\y]^n");
	if(get_user_flags(id) & ADMIN_LEVEL_G)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7] \wAk-47 | Paladin \y[\rСупер Админ\y]^n");
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7] \dAk-47 | Paladin \y[\rСупер Админ\y]^n");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_WeaponsGuardMenu");
}

public Handle_WeaponsGuardMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || iKey == 9)
	{
		if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new const szWeaponName[][] = {"weapon_ak47", "weapon_m4a1", "weapon_awp", "weapon_xm1014", "weapon_deagle"};
	new const iWeaponId[] = {CSW_AK47, CSW_M4A1, CSW_AWP, CSW_XM1014, CSW_DEAGLE};
	
	
	if(iKey == 4)
	{
		fm_strip_user_weapons(id);
		fm_give_item(id, "item_kevlar");
		fm_give_item(id, "weapon_knife");
		//jbe_give_brickpeacev(id);
		fm_give_item(id, "weapon_deagle");
		fm_give_item(id, szWeaponName[4]);
		fm_set_user_bpammo(id, iWeaponId[4], 250);
		return PLUGIN_HANDLED;
	}
	
	if(iKey == 5)
	{
		fm_strip_user_weapons(id);
		fm_give_item(id, "item_kevlar");
		fm_give_item(id, "weapon_knife");
		//give_buffm4(id);
		fm_give_item(id, "weapon_deagle");
		fm_give_item(id, szWeaponName[4]);
		fm_set_user_bpammo(id, iWeaponId[4], 250);
		return PLUGIN_HANDLED;
	}
	
	if(iKey == 6)
	{
		fm_strip_user_weapons(id);
		fm_give_item(id, "item_kevlar");
		fm_give_item(id, "weapon_knife");
		//give_buffak(id);
		fm_give_item(id, "weapon_deagle");
		fm_give_item(id, szWeaponName[4]);
		fm_set_user_bpammo(id, iWeaponId[4], 250);
		return PLUGIN_HANDLED;
	}
	
	drop_user_weapons(id, 0);
	fm_give_item(id, szWeaponName[iKey]);
	fm_set_user_bpammo(id, iWeaponId[iKey], 250);
	drop_user_weapons(id, 1);
	fm_give_item(id, szWeaponName[4]);
	fm_set_user_bpammo(id, iWeaponId[4], 250);
	fm_give_item(id, "item_kevlar");
	if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
	return PLUGIN_HANDLED;
}

Show_MainPnMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[1024], iKeys = (1<<1|1<<2|1<<4|1<<5|1<<9), iUserAlive = IsSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MAIN_TITLE");
	
	if(!g_iBlockFunction[0])
	{
		if(iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_MAIN_SHOP");
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n", id, "JBE_MENU_MAIN_SHOP");
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Стоит Глобальная Блокировка]^n", id, "JBE_MENU_MAIN_SHOP");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n\y[3]\r ~ \w%L^n^n", id, "JBE_SETTING_MENU_TITLE", id, "JBE_OFFICE_MENU_TITLE");
	
	if(id == g_iLastPnId && iUserAlive)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_MAIN_LAST_PN");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_MAIN_LAST_PN");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n", id, "JBE_MENU_MAIN_TEAM");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n", id, "JBE_MENU_MAIN_PRIVILEGE");
	
	if(g_iDayMode != 1)
	{
		iKeys |= (1<<6);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n", id, "JBE_MENU_MAIN_OPEN_DOORS");
	}
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MainPnMenu");
}

public Handle_MainPnMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserAlive, id) && IsNotSetBit(g_iBitUserDuel, id)) return Show_ShopPrisonersMenu(id, 1);
		case 1: return Show_SettingMenu(id);
		case 2: return Show_OfficeMenu(id);
		case 3: if(id == g_iLastPnId && IsSetBit(g_iBitUserAlive, id)) return Show_LastPrisonerMenu(id);
		case 4: return Show_ChooseTeamMenu(id, 1);
		case 5: return Show_PrivilegeMenu(id);
		case 6: jbe_open_doors();
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MainPnMenu(id);
}

Show_OfficeMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<1|1<<4|1<<5|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_OFFICE_MENU_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ %s%L^n", (iAlive && jbe_get_day_mode() != 3) ? "\w":"\d", id, "JBE_OFFICE_KEY_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n^n", id, "JBE_OFFICE_KEY_2");

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ %s%L^n", (iAlive && jbe_get_day_mode() != 3 && g_iUserTeam[id] == 1) ? "\w":"\d", id, "JBE_OFFICE_KEY_3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ %s%L^n", (iAlive && jbe_get_day_mode() != 3 && g_iUserTeam[id] == 1) ? "\w":"\d", id, "JBE_OFFICE_KEY_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ %s%L^n^n", (iAlive && jbe_get_day_mode() != 3 && g_iUserTeam[id] == 1) ? "\w":"\d", id, "JBE_OFFICE_KEY_5");
	
	
	if(iAlive && jbe_get_day_mode() != 3) iKeys |= (1<<0|1<<6);
	if(iAlive && jbe_get_day_mode() != 3 && g_iUserTeam[id] == 1) iKeys |= (1<<2|1<<3);
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_OfficeMenu");
	
}
public Handle_OfficeMenu(id, iKey)
{
	switch(iKey)
	{
		//case 0: ujbl_open_gang_menu(id);
		case 1: Show_ImageMenu(id);
		//case 2: jbe_open_skills_menu(id);
		//case 3: Open_DrugsMenu(id);
		case 4: return jbe_roleplay(id);
	}
	return PLUGIN_HANDLED;
}

Show_SettingMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<4|1<<5|1<<6|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SETTING_MENU_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \r[%s]^n", id, "JBE_SETTING_MENU_CORD_INF", g_iInformerCord[id] ? "Правый Угол":"Левый Угол");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \r[%s]^n", id, "JBE_SETTING_MENU_VALID_INF", g_iInformerStatus[id] ? "Выключен":"Включен");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_MAIN_MONEY_TRANSFER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ %s%L^n^n", (jbe_get_day_mode() == 3 || g_bRestartGame) ? "\d":"\w", id, "JBE_MENU_MAIN_COSTUMES");
	if(jbe_get_day_mode() != 3 && !g_bRestartGame) iKeys |= (1<<3);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_MAIN_MANAGE_SOUND");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L \d[\r%s\d]^n", id, "JBE_MENU_MAIN_TOUCH", !g_TouchStatus[id] ? "Открывать при косании":"Не открывать при косании");
	
	if(IsSetBit(g_iBitUserHook, id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n", id, "JBE_MENU_MAIN_MANAGE_HOOK");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SettingMenu");
	
}
public Handle_SettingMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			switch(g_iInformerCord[id])
			{
				case true: g_iInformerCord[id] = false;
				case false: g_iInformerCord[id] = true;
			}
			return Show_SettingMenu(id);
		}
		case 1:
		{
			switch(g_iInformerStatus[id])
			{
				case true: g_iInformerStatus[id] = false;
				case false: g_iInformerStatus[id] = true;
			}
			jbe_status_informer_valid(id);
			return Show_SettingMenu(id);
		}
		case 2: return Cmd_MoneyTransferMenu(id);
		case 3: return Cmd_CostumesMenu(id);
		case 4: return Show_ManageSoundMenu(id);
		case 5:
		{
			switch(g_TouchStatus[id])
			{
				case true: g_TouchStatus[id] = false;
				case false: g_TouchStatus[id] = true;
			}
			return Show_SettingMenu(id);
		}
		case 6: return Show_HookSetting(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SettingMenu(id);
}
Show_HookSetting(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_SETTING_HOOK_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L%s^n^n", id, "JBE_SETTING_HOOK_RANDOM_HOOK", g_RandomHook[id] ? " \y[Выбран]":"");
	
	iKeys |= (1<<1);
	
	if(g_RandomHook[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_SETTING_HOOK_LIGHTNING");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_SETTING_HOOK_RAINBOW");	
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_SETTING_HOOK_BLUE");	
		
		if(IsSetBit(g_iBitUserGod, id)) iKeys |= (1<<2);
		if(IsSetBit(g_iBitUserKnyaz, id)) iKeys |= (1<<3);
	}else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L%s^n", id, "JBE_SETTING_HOOK_LIGHTNING", g_StatusHook[id] == 1 ? " \y[Выбран]":"");
	
		if(IsSetBit(g_iBitUserKnyaz, id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L%s^n", id, "JBE_SETTING_HOOK_RAINBOW", g_StatusHook[id] == 2 ? " \y[Выбран]":"");	
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L%s^n", id, "JBE_SETTING_HOOK_RAINBOW", g_StatusHook[id] == 2 ? " \y[Выбран]":"");	
		
		if(IsSetBit(g_iBitUserGod, id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L%s^n", id, "JBE_SETTING_HOOK_BLUE", g_StatusHook[id] == 3 ? " \y[Выбран]":"");
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L%s^n", id, "JBE_SETTING_HOOK_BLUE", g_StatusHook[id] == 3 ? " \y[Выбран]":"");
	
		if(IsSetBit(g_iBitUserGod, id)) iKeys |= (1<<2);
		if(IsSetBit(g_iBitUserKnyaz, id)) iKeys |= (1<<3);
	}
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_HookSetting");
	
}
public Handle_HookSetting(id, iKey)
{
	switch(iKey)
	{
		case 0: g_RandomHook[id] = true;
		case 1: 
		{
			g_StatusHook[id] = 1;
			g_RandomHook[id] = false;
		}
		case 2: 
		{
			g_StatusHook[id] = 2;
			g_RandomHook[id] = false;
		}
		case 3: 
		{
			g_StatusHook[id] = 3;
			g_RandomHook[id] = false;
		}
		case 9: return PLUGIN_HANDLED;
	}
	return Show_HookSetting(id);
}

stock jbe_status_informer_valid(id)
{
	if(g_iMafiaStatus) return;
	switch(g_iInformerStatus[id])
	{
		case true: remove_task(id + TASK_SHOW_INFORMER);
		case false: set_task(2.0, "jbe_main_informer", id+TASK_SHOW_INFORMER, _, _, "b");	
	}
}

Show_MainGrMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[1024], iKeys = (1<<1|1<<2|1<<4|1<<5|1<<9), iUserAlive = IsSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MAIN_TITLE");
	
	if(!g_iBlockFunction[0])
	{
		if(iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id))
		{
			if(!jbe_all_users_wanted())
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_MAIN_SHOP");
				iKeys |= (1<<0);
			}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Есть бунтующие люди]^n", id, "JBE_MENU_MAIN_SHOP");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n^n", id, "JBE_MENU_MAIN_SHOP");
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Стоит Глобальная Блокировка]^n", id, "JBE_MENU_MAIN_SHOP");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n\y[3]\r ~ \w%L^n^n", id, "JBE_SETTING_MENU_TITLE", id, "JBE_OFFICE_MENU_TITLE");
	
	if(iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		if(id == g_iChiefId)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_MAIN_CHIEF");
			iKeys |= (1<<3);
		}
		else if(g_iChiefStatus != 1 && (g_iChiefIdOld != id || g_iChiefStatus != 0))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n", id, "JBE_MENU_MAIN_TEAM");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n", id, "JBE_MENU_MAIN_PRIVILEGE");
	
	if(g_iDayMode != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n^n", id, "JBE_MENU_MAIN_CLASS_CT");
		iKeys |= (1<<6);
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\w ~ \w%L^n^n", id, "JBE_MENU_MAIN_CLASS_CT");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MainGrMenu");
}

public Handle_MainGrMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: return Show_ShopGuardMenu(id);		
		case 1: return Show_SettingMenu(id);
		case 2: return Show_OfficeMenu(id);
		case 3: 
		{
			if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserAlive, id))
			{
				if(id == g_iChiefId) return Show_ChiefMenu_1(id);
				if(g_iChiefStatus != 1 && (g_iChiefIdOld != id || g_iChiefStatus != 0) && jbe_set_user_chief(id))
				{
					g_iChiefIdOld = id;
					return Show_ChiefMenu_1(id);
				}
			}
		}
		case 4: return Show_ChooseTeamMenu(id, 1);
		case 5: return Show_PrivilegeMenu(id);
		case 6: 
		{
			//ujbl_open_class_ct_menu(id);
			return PLUGIN_HANDLED;
		}
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MainGrMenu(id);
}

Show_ShopPrisonersMenu(id, iType)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	jbe_set_user_discount(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n", id, "JBE_MENU_SHOP_PRISONERS_TITLE", g_iUserDiscount[id]), iKeys = (1<<3|1<<9);
	
	if(iType)
	{
		if(g_BuyTime)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [\rЗакрыт\d]^n", id, "JBE_MENU_SHOP_PRISONERS_WEAPONS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [\rЗакрыт\d]^n", id, "JBE_MENU_SHOP_PRISONERS_ITEMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [\rЗакрыт\d]^n", id, "JBE_MENU_SHOP_PRISONERS_SKILLS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_OTHER");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [\rЗакрыт\d]^n^n^n^n", id, "JBE_MENU_SHOP_PRISONERS_SHOPTATTOO");
		}else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_WEAPONS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_ITEMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_SKILLS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_OTHER");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n^n^n", id, "JBE_MENU_SHOP_PRISONERS_SHOPTATTOO");
			iKeys |= (1<<0|1<<1|1<<2|1<<4);
		}
	}else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_WEAPONS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_ITEMS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_SKILLS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_SHOP_PRISONERS_OTHER");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n^n^n", id, "JBE_MENU_SHOP_PRISONERS_SHOPTATTOO");
		iKeys |= (1<<0|1<<1|1<<2|1<<4);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	if(!iType) return show_menu(id, iKeys, szMenu, 1, "Show_ShopPrisonersMenu");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopPrisonersMenu");
}

public Handle_ShopPrisonersMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Show_ShopWeaponsMenu(id);
		case 1: return Show_ShopItemsMenu(id);
		case 2: return Show_ShopSkillsMenu(id);
		case 3: return Show_ShopOtherMenu(id);
		case 4: return Show_ShopTattooMenu(id);
		case 8: return Show_MainPnMenu(id);
	}
	return PLUGIN_HANDLED;
}

Show_ShopWeaponsMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_WEAPONS_TITLE");
	/*new iPriceSharpening = jbe_get_price_discount(id, g_iShopCvars[SHARPENING]);
	if(IsNotSetBit(g_iBitSharpening, id))
	{
		if(iPriceSharpening <= g_iUserMoney[id] && jbe_get_user_level(id) >= 1)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \R\y~ %d$^n", id, "JBE_MENU_SHOP_WEAPONS_SHARPENING", iPriceSharpening);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \R\r%d$\d|\y2 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_SHARPENING", iPriceSharpening);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \R\r%d$\d|\y2 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_SHARPENING", iPriceSharpening);
	*/
	
	new iPriceScrewdriver = jbe_get_price_discount(id, g_iShopCvars[SCREWDRIVER]);
	if(IsNotSetBit(g_iBitScrewdriver, id))
	{
		if(iPriceScrewdriver <= g_iUserMoney[id] && jbe_get_user_level(id) >= 3)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \R\y~ %d$^n", id, "JBE_MENU_SHOP_WEAPONS_SCREWDRIVER", iPriceScrewdriver);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \R\r%d$\d|\y4 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_SCREWDRIVER", iPriceScrewdriver);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \R%d$|\y4 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_SCREWDRIVER", iPriceScrewdriver);
	/*new iPriceBalisong = jbe_get_price_discount(id, g_iShopCvars[BALISONG]);
	if(IsNotSetBit(g_iBitBalisong, id))
	{
		if(iPriceBalisong <= g_iUserMoney[id] && jbe_get_user_level(id) >= 5)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \R\y~ %d$^n", id, "JBE_MENU_SHOP_WEAPONS_BALISONG", iPriceBalisong);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \R\r%d$\d|\y6 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_BALISONG", iPriceBalisong);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \R%d$|\y6 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_BALISONG", iPriceBalisong);
	*/
	new iPriceGlock18 = jbe_get_price_discount(id, g_iShopCvars[GLOCK18]);
	if(!user_has_weapon(id, CSW_GLOCK18))
	{
		if(iPriceGlock18 <= g_iUserMoney[id] && jbe_get_user_level(id) >= 7)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \R\y~ %d$^n", id, "JBE_MENU_SHOP_WEAPONS_GLOCK18", iPriceGlock18);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \R\r%d$\d|\y8 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_GLOCK18", iPriceGlock18);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \R%d$|\y8 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_GLOCK18", iPriceGlock18);
	new iPriceUsp = jbe_get_price_discount(id, g_iShopCvars[USP]);
	if(!user_has_weapon(id, CSW_USP))
	{
		if(iPriceUsp <= g_iUserMoney[id] && jbe_get_user_level(id) >= 8)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \R\y~ %d$^n", id, "JBE_MENU_SHOP_WEAPONS_USP", iPriceUsp);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \R\r%d$\d|\y9 ур.^n", id, "JBE_MENU_SHOP_WEAPONS_USP", iPriceUsp);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \R%d$|\y9^n", id, "JBE_MENU_SHOP_WEAPONS_USP", iPriceUsp);
	new iPriceDeagle = jbe_get_price_discount(id, g_iShopCvars[DEAGLE]);
	if(!user_has_weapon(id, CSW_DEAGLE))
	{
		if(iPriceDeagle <= g_iUserMoney[id] && jbe_get_user_level(id) >= 9)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L \R\y~ %d$^n^n^n^n", id, "JBE_MENU_SHOP_WEAPONS_DEAGLE", iPriceDeagle);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L \R\r%d$\d|\y10 ур.^n^n^n^n", id, "JBE_MENU_SHOP_WEAPONS_DEAGLE", iPriceDeagle);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L \R%d$|\y10 ур.^n^n^n^n", id, "JBE_MENU_SHOP_WEAPONS_DEAGLE", iPriceDeagle);
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_BACK");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopWeaponsMenu");
}

public Handle_ShopWeaponsMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		/*case 0:
		{
			new iPriceSharpening = jbe_get_price_discount(id, g_iShopCvars[SHARPENING]);
			if(IsNotSetBit(g_iBitSharpening, id) && iPriceSharpening <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceSharpening, 1);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitBalisong, id);
				SetBit(g_iBitSharpening, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}*/
		case 0:
		{
			new iPriceScrewdriver = jbe_get_price_discount(id, g_iShopCvars[SCREWDRIVER]);
			if(IsNotSetBit(g_iBitScrewdriver, id) && iPriceScrewdriver <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceScrewdriver, 1);
				//ClearBit(g_iBitSharpening, id);
				//ClearBit(g_iBitBalisong, id);
				SetBit(g_iBitScrewdriver, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}
		/*case 2:
		{
			new iPriceBalisong = jbe_get_price_discount(id, g_iShopCvars[BALISONG]);
			if(IsNotSetBit(g_iBitBalisong, id) && iPriceBalisong <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceBalisong, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitScrewdriver, id);
				SetBit(g_iBitBalisong, id);
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
				return PLUGIN_HANDLED;
			}
		}*/
		case 1:
		{
			new iPriceGlock18 = jbe_get_price_discount(id, g_iShopCvars[GLOCK18]);
			if(!user_has_weapon(id, CSW_GLOCK18) && iPriceGlock18 <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceGlock18, 1);
				drop_user_weapons(id, 1);
				fm_give_item(id, "weapon_glock18");
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceUsp = jbe_get_price_discount(id, g_iShopCvars[USP]);
			if(!user_has_weapon(id, CSW_USP) && iPriceUsp <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceUsp, 1);
				drop_user_weapons(id, 1);
				fm_give_item(id, "weapon_usp");
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceDeagle = jbe_get_price_discount(id, g_iShopCvars[DEAGLE]);
			if(!user_has_weapon(id, CSW_DEAGLE) && iPriceDeagle <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceDeagle, 1);
				drop_user_weapons(id, 1);
				fm_give_item(id, "weapon_deagle");
				return PLUGIN_HANDLED;
			}
		}
		case 9: return Show_ShopPrisonersMenu(id, 1);
	}
	return Show_ShopWeaponsMenu(id);
}

Show_ShopItemsMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_ITEMS_TITLE");
	new iPriceLatchkey = jbe_get_price_discount(id, g_iShopCvars[LATCHKEY]);
	if(IsNotSetBit(g_iBitLatchkey, id))
	{
		if(iPriceLatchkey <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_LATCHKEY", iPriceLatchkey);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_LATCHKEY", iPriceLatchkey);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_ITEMS_LATCHKEY", iPriceLatchkey);
	new iPriceFlashbang = jbe_get_price_discount(id, g_iShopCvars[FLASHBANG]);
	if(!user_has_weapon(id, CSW_FLASHBANG))
	{
		if(iPriceFlashbang <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
	new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN]);
	if(IsNotSetBit(g_iBitKokain, id))
	{
		if(iPriceKokain <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
	new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR]);
	if(IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 200)
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
	new iPriceFrostNade = jbe_get_price_discount(id, g_iShopCvars[FROSTNADE]);
	if(!user_has_weapon(id, CSW_SMOKEGRENADE) && IsNotSetBit(g_iBitFrostNade, id))
	{
		if(iPriceFrostNade <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_FROST_GRENADE", iPriceFrostNade);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_FROST_GRENADE", iPriceFrostNade);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_ITEMS_FROST_GRENADE", iPriceFrostNade);
	new iPriceInvisibleHat = jbe_get_price_discount(id, g_iShopCvars[INVISIBLE_HAT]);
	if(IsNotSetBit(g_iBitInvisibleHat, id))
	{
		if(iPriceInvisibleHat <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_INVISIBLE_HAT", iPriceInvisibleHat);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_INVISIBLE_HAT", iPriceInvisibleHat);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_ITEMS_INVISIBLE_HAT", iPriceInvisibleHat);
	new iPriceArmor = jbe_get_price_discount(id, g_iShopCvars[ARMOR]);
	if(get_user_armor(id) == 0)
	{
		if(iPriceArmor <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
	new iPriceClothingGuard = jbe_get_price_discount(id, g_iShopCvars[CLOTHING_GUARD]);
	if(IsNotSetBit(g_iBitClothingGuard, id))
	{
		if(iPriceClothingGuard <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_CLOHING_GUARD", iPriceClothingGuard);
			iKeys |= (1<<7);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_CLOHING_GUARD", iPriceClothingGuard);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_CLOHING_GUARD", iPriceClothingGuard);
	new iPriceHeGrenade = jbe_get_price_discount(id, g_iShopCvars[HEGRENADE]);
	if(!user_has_weapon(id, CSW_HEGRENADE))
	{
		if(iPriceHeGrenade <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[9]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
			iKeys |= (1<<8);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[9]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[9]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_BACK");
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
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_MENU_ID_LATCHKEY_USE");
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
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_MENU_ID_KOKAIN");
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
			new iPriceFrostNade = jbe_get_price_discount(id, g_iShopCvars[FROSTNADE]);
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && IsNotSetBit(g_iBitFrostNade, id) && iPriceFrostNade <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFrostNade, 1);
				SetBit(g_iBitFrostNade, id);
				fm_give_item(id, "weapon_smokegrenade");
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			new iPriceInvisibleHat = jbe_get_price_discount(id, g_iShopCvars[INVISIBLE_HAT]);
			if(IsNotSetBit(g_iBitInvisibleHat, id) && iPriceInvisibleHat <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceInvisibleHat, 1);
				SetBit(g_iBitInvisibleHat, id);
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
//				if(g_eUserCostumes[id][COSTUMES]) jbe_hide_user_costumes(id);
				set_task(10.0, "jbe_remove_invisible_hat", id+TASK_INVISIBLE_HAT);
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_MENU_ID_INVISIBLE_HAT_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 6:
		{
			new iPriceArmor = jbe_get_price_discount(id, g_iShopCvars[ARMOR]);
			if(get_user_armor(id) == 0 && iPriceArmor <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceArmor, 1);
				fm_give_item(id, "item_kevlar");
				return PLUGIN_HANDLED;
			}
		}
		case 7:
		{
			new iPriceClothingGuard = jbe_get_price_discount(id, g_iShopCvars[CLOTHING_GUARD]);
			if(IsNotSetBit(g_iBitClothingGuard, id) && iPriceClothingGuard <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceClothingGuard, 1);
				SetBit(g_iBitClothingGuard, id);
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_CLOHING_GUARD_HELP");
			}
		}
		case 8:
		{
			new iPriceHeGrenade = jbe_get_price_discount(id, g_iShopCvars[HEGRENADE]);
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && iPriceHeGrenade <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceHeGrenade, 1);
				fm_give_item(id, "weapon_hegrenade");
				return PLUGIN_HANDLED;
			}
		}
		case 9: return Show_ShopPrisonersMenu(id, 1);
	}
	return Show_ShopItemsMenu(id);
}

Show_ShopSkillsMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_SKILLS_TITLE");
	new iPriceHingJump = jbe_get_price_discount(id, g_iShopCvars[HING_JUMP]);
	if(IsNotSetBit(g_iBitHingJump, id))
	{
		if(iPriceHingJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
	new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN]);
	if(IsNotSetBit(g_iBitFastRun, id))
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
	new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP]);
	if(IsNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
	new iPriceRandomGlow = jbe_get_price_discount(id, g_iShopCvars[RANDOM_GLOW]);
	if(IsNotSetBit(g_iBitRandomGlow, id))
	{
		if(iPriceRandomGlow <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
	new iPriceAutoBhop = jbe_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
	if(IsNotSetBit(g_iBitAutoBhop, id))
	{
		if(iPriceAutoBhop <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
	new iPriceDoubleDamage = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_DAMAGE]);
	if(IsNotSetBit(g_iBitDoubleDamage, id))
	{
		if(iPriceDoubleDamage <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
	new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY]);
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L \y[%d$]^n^n^n", id, "JBE_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L \r[%d$]^n^n^n", id, "JBE_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L [%d$]^n^n^n", id, "JBE_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_BACK");
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
		case 9: return Show_ShopPrisonersMenu(id, 1);
	}
	return Show_ShopSkillsMenu(id);
}

Show_ShopOtherMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SHOP_OTHER_TITLE");
	new iPriceCloseCase = jbe_get_price_discount(id, g_iShopCvars[CLOSE_CASE]);
	if(IsSetBit(g_iBitUserWanted, id))
	{
		if(iPriceCloseCase <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
	new iPriceFreeDay = jbe_get_price_discount(id, g_iShopCvars[FREE_DAY_SHOP]);
	if(g_iDayMode == 1 && IsNotSetBit(g_iBitUserFree, id) && IsNotSetBit(g_iBitUserWanted, id))
	{
		if(iPriceFreeDay <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
	new iPriceResolutionVoice = jbe_get_price_discount(id, g_iShopCvars[RESOLUTION_VOICE]);
	if(IsNotSetBit(g_iBitUserVoice, id))
	{
		if(iPriceResolutionVoice <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_OTHER_RESOLUTION_VOICE", iPriceResolutionVoice);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_OTHER_RESOLUTION_VOICE", iPriceResolutionVoice);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_OTHER_RESOLUTION_VOICE", iPriceResolutionVoice);
	new iPriceTransferGuard = jbe_get_price_discount(id, g_iShopCvars[TRANSFER_GUARD]);
	if(iPriceTransferGuard <= g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_OTHER_TRANSFER_GUARD", iPriceTransferGuard);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_OTHER_TRANSFER_GUARD", iPriceTransferGuard);
	new iPriceLotteryTicket = jbe_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET]);
	if(IsNotSetBit(g_iBitLotteryTicket, id))
	{
		if(iPriceLotteryTicket <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_OTHER_LOTTERY_TICKET", iPriceLotteryTicket);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_OTHER_LOTTERY_TICKET", iPriceLotteryTicket);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_OTHER_LOTTERY_TICKET", iPriceLotteryTicket);
	new iPricePrankPrisoner = jbe_get_price_discount(id, g_iShopCvars[PRANK_PRISONER]);
	if(g_iAlivePlayersNum[1] >= 2)
	{
		if(iPricePrankPrisoner <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L \y[%d$]^n^n^n^n", id, "JBE_MENU_SHOP_OTHER_PRANK_PRISONER", iPricePrankPrisoner);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L \r[%d$]^n^n^n^n", id, "JBE_MENU_SHOP_OTHER_PRANK_PRISONER", iPricePrankPrisoner);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L [%d$]^n^n^n^n", id, "JBE_MENU_SHOP_OTHER_PRANK_PRISONER", iPricePrankPrisoner);
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_BACK");
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
					UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_LOTTERY_WIN", iPrize);
					jbe_set_user_money(id, g_iUserMoney[id] + iPrize, 1);
				}
				else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_LOTTERY_LOSS");
				return PLUGIN_HANDLED;
			}
		}
		case 5: if(g_iAlivePlayersNum[1] >= 2) return Cmd_PrankPrisonerMenu(id);
		case 9: return Show_ShopPrisonersMenu(id, 1);
	}
	return Show_ShopOtherMenu(id);
}

Cmd_PrankPrisonerMenu(id) return Show_PrankPrisonerMenu(id, g_iMenuPosition[id] = 0);
Show_PrankPrisonerMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
	jbe_informer_offset_up(id);
	jbe_set_user_discount(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n", id, "JBE_MENU_SHOP_GUARD_TITLE", g_iUserDiscount[id]);
	new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR_GR]);
	if(get_user_health(id) < 200)
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	new iPriceRandomGlow = jbe_get_price_discount(id, g_iShopCvars[RANDOM_GLOW_GR]);
	if(IsNotSetBit(g_iBitRandomGlow, id))
	{
		if(iPriceRandomGlow <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
	new iPriceLotteryTicket = jbe_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET_GR]);
	if(IsNotSetBit(g_iBitLotteryTicket, id))
	{
		if(iPriceLotteryTicket <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_GUARD_LOTTERY_TICKET", iPriceLotteryTicket);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_GUARD_LOTTERY_TICKET", iPriceLotteryTicket);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_GUARD_LOTTERY_TICKET", iPriceLotteryTicket);
	new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN_GR]);
	if(IsNotSetBit(g_iBitKokain, id))
	{
		if(iPriceKokain <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP_GR]);
	if(IsNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN_GR]);
	if(IsNotSetBit(g_iBitFastRun, id))
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L \y[%d$]^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L \r[%d$]^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L [%d$]^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY_GR]);
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L \y[%d$]^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L \r[%d$]^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L [%d$]^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
					UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_LOTTERY_WIN", iPrize);
					jbe_set_user_money(id, g_iUserMoney[id] + iPrize, 1);
				}
				else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_LOTTERY_LOSS");
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
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_MENU_ID_KOKAIN");
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
		case 8: return Show_MainGrMenu(id);
	}
	return PLUGIN_HANDLED;
}

Cmd_MoneyTransferMenu(id) return Show_MoneyTransferMenu(id, g_iMenuPosition[id] = 0);
Show_MoneyTransferMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s \r[%d$]^n", ++b, szName, g_iUserMoney[i]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n\d%L^n", id, "JBE_MENU_MONEY_AMOUNT_TITLE", id, "JBE_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
	if(g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%d$^n", floatround(g_iUserMoney[id] * 0.10, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%d$^n", floatround(g_iUserMoney[id] * 0.25, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%d$^n", floatround(g_iUserMoney[id] * 0.50, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%d$^n", floatround(g_iUserMoney[id] * 0.75, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%d$^n^n^n", g_iUserMoney[id]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \w%L^n", id, "JBE_MENU_MONEY_SPECIFY_AMOUNT");
		iKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<7);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d0$^n\y[2]\r ~ \d0$^n\y[3]\r ~ \d0$^n\y[4]\r ~ \d0$^n\y[5]\r ~ \d0$^n^n^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \d%L^n", id, "JBE_MENU_MONEY_SPECIFY_AMOUNT");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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

Cmd_CostumesMenu(id) return Show_CostumesMenu(id, g_iMenuPosition[id] = 0);
Show_CostumesMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iStart = iPos * PLAYERS_PER_PAGE, g_iCostumesListSize = 27;
	if(iStart > g_iCostumesListSize) iStart = g_iCostumesListSize;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iCostumesListSize) iEnd = g_iCostumesListSize + (iPos ? 0 : 1);
	new szMenu[512], iLen, iPagesNum = (g_iCostumesListSize / PLAYERS_PER_PAGE + ((g_iCostumesListSize % PLAYERS_PER_PAGE) ? 1 : 0));
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_COSTUMES_TITLE", iPos + 1, iPagesNum);
	new szLangPlayer[32], iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		formatex(szLangPlayer, charsmax(szLangPlayer), "JBE_MENU_COSTUMES_%d", a);
		if(g_eUserCostumes[id][COSTUMES] != a)
		{
			iKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%L^n", ++b, id, szLangPlayer);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \d%L^n", ++b, id, szLangPlayer);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < g_iCostumesListSize)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_CostumesMenu");
}

public Handle_CostumesMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_CostumesMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_CostumesMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iCostumes = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
			jbe_set_user_costumes(id, iCostumes);
		}
	}
	return PLUGIN_HANDLED;
}

Show_ChiefMenu_1(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<4|1<<6|1<<7|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_CHIEF_TITLE");
	if(g_bDoorStatus) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_DOOR_CLOSE");
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_DOOR_OPEN");
	if(g_iDayMode == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_COUNTDOWN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_PRISONER_SEARCH");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_CONTROL");
		iKeys |= (1<<1|1<<2|1<<3);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_CHIEF_COUNTDOWN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_CHIEF_PRISONER_SEARCH");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_CONTROL");
	}
	if(g_iDayMode == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_START");
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_END");
	if(jbe_get_user_lvl(id) >= 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_PUNISH_GUARD");
		iKeys |= (1<<5);
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L [Ваш игровой лвл мал]^n", id, "JBE_MENU_CHIEF_PUNISH_GUARD");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_TRANSFER_CHIEF");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_TREAT_PRISONER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
					if(g_iUserTeam[iTarget] != 1) UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_NOT_TEAM_SEARCH");
					else
					{
						new iBitWeapons = pev(iTarget, pev_weapons);
						if(iBitWeapons &= ~(1<<CSW_HEGRENADE|1<<CSW_SMOKEGRENADE|1<<CSW_FLASHBANG|1<<CSW_KNIFE|1<<31)) UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_FOUND_WEAPON");
						else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_NOT_FOUND_WEAPON");
					}
				}
				else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_HELP_FOUND_WEAPON");
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
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_COUNT_DOWN_TITLE");
	if(task_exists(TASK_COUNT_DOWN_TIMER))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n", id, "JBE_MENU_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n^n^n^n^n^n", id, "JBE_MENU_COUNT_DOWN_3");
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n^n^n^n^n^n", id, "JBE_MENU_COUNT_DOWN_3");
		iKeys |= (1<<0|1<<1|1<<2);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
		case 8: return Show_ChiefMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	set_task(1.0, "jbe_count_down_timer", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
	return Show_ChiefMenu_1(id);
}

public jbe_count_down_timer()
{
	if(--g_iCountDown) client_print(0, print_center, "%L", LANG_PLAYER, "JBE_MENU_COUNT_DOWN_TIME", g_iCountDown);
	else client_print(0, print_center, "%L", LANG_PLAYER, "JBE_MENU_COUNT_DOWN_TIME_END");
	UTIL_SendAudio(0, _, "jb_engine/countdown/%d.wav", g_iCountDown);
}

Cmd_FreeDayControlMenu(id) return Show_FreeDayControlMenu(id, g_iMenuPosition[id] = 0);
Show_FreeDayControlMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s \r[%L]^n", ++b, szName, i, IsSetBit(g_iBitUserFree, i) ? "JBE_MENU_FREE_DAY_CONTROL_TAKE" : "JBE_MENU_FREE_DAY_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
				UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TAKE_FREE_DAY", szName, szTargetName);
				jbe_sub_user_free(iTarget);
			}
			else
			{
				UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_GIVE_FREE_DAY", szName, szTargetName);
				if(IsSetBit(g_iBitUserAlive, iTarget)) jbe_add_user_free(iTarget);
				else
				{
					jbe_add_user_free_next_round(iTarget);
					UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_AUTO_FREE_DAY", szTargetName);
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
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
					UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_PUNISH_GUARD", szName, szTargetName);
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
	jbe_informer_offset_up(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 2 || IsNotSetBit(g_iBitUserAlive, i) || i == g_iChiefId) continue;
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
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
				CREATE_KILLBEAM(id);
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_TRANSFER_CHIEF", szName, szTargetName);
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
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s \r[%d HP]^n", ++b, szName, get_user_health(i));
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
				UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TREAT_PRISONER", szName, szTargetName);
				set_pev(iTarget, pev_health, 100.0);
			}
		}
	}
	return Show_TreatPrisonerMenu(id, g_iMenuPosition[id]);
}

Show_ChiefMenu_2(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<4|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_CHIEF_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_VOICE_CONTROL");
	if(g_iDayMode == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_PRISONERS_DIVIDE_COLOR");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_MINI_GAME");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n^n", id, "JBE_MENU_CHIEF_GAME_TITLE");
		iKeys |= (1<<1|1<<2|1<<3);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_CHIEF_PRISONERS_DIVIDE_COLOR");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_CHIEF_MINI_GAME");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n^n", id, "JBE_MENU_CHIEF_GAME_TITLE");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_CREATE_TRAIL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n", id, "JBE_MENU_CHIEF_DELETE_TRAIL");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ChiefMenu_2");
}

public Handle_ChiefMenu_2(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Cmd_VoiceControlMenu(id);
		case 1: if(g_iDayMode == 1) return Show_PrisonersDivideColorMenu(id);
		case 2: if(g_iDayMode == 1) return Show_MiniGameMenu(id);
		case 3: if(g_iDayMode == 1) return Show_ChiefGameMenu(id);
		case 4:
		{
			CREATE_KILLBEAM(id);
			CREATE_BEAMFOLLOW(id, g_pSpriteLgtning[random_num(0, 2)], 100, 3, random_num(100, 255), random_num(100, 255), random_num(100, 255), 1000);
		}
		case 5: CREATE_KILLBEAM(id);
		case 8: return Show_ChiefMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ChiefMenu_2(id);
}

Cmd_VoiceControlMenu(id) return Show_VoiceControlMenu(id, g_iMenuPosition[id] = 0);
Show_VoiceControlMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s %L^n", ++b, szName, id, IsSetBit(g_iBitUserVoice, i) ? "JBE_MENU_CHIEF_VOICE_CONTROL_TAKE" : "JBE_MENU_CHIEF_VOICE_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_VoiceControlMenu");
}

public Handle_VoiceControlMenu(id, iKey)
{
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
			if(IsSetBit(g_iBitUserVoice, iTarget))
			{
				ClearBit(g_iBitUserVoice, iTarget);
				UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TAKE_VOICE", szName, szTargetName);
			}
			else
			{
				SetBit(g_iBitUserVoice, iTarget);
				UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_GIVE_VOICE", szName, szTargetName);
			}
		}
	}
	return Show_VoiceControlMenu(id, g_iMenuPosition[id]);
}

Show_PrisonersDivideColorMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_PRISONERS_DIVIDE_COLOR_TITLE");
	if(g_iAlivePlayersNum[1] >= 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_PRISONERS_DIVIDE_COLOR_2");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n", id, "JBE_MENU_PRISONERS_DIVIDE_COLOR_2");
	if(g_iAlivePlayersNum[1] >= 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_PRISONERS_DIVIDE_COLOR_3");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_PRISONERS_DIVIDE_COLOR_3");
	if(g_iAlivePlayersNum[1] >= 4)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n^n^n^n^n^n", id, "JBE_MENU_PRISONERS_DIVIDE_COLOR_4");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n^n^n^n^n^n", id, "JBE_MENU_PRISONERS_DIVIDE_COLOR_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrisonersDivideColorMenu");
}

public Handle_PrisonersDivideColorMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Show_ChiefMenu_2(id);
		case 9: return PLUGIN_HANDLED;
		default: jbe_prisoners_divide_color(iKey + 2);
	}
	return Show_ChiefMenu_2(id);
}

Show_MiniGameMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MINI_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_MINI_GAME_SOCCER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_MINI_GAME_BOXING");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_MINI_GAME_SPRAY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_MINI_GAME_DISTANCE_DROP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L \r[%L]^n", id, "JBE_MENU_MINI_GAME_FRIENDLY_FIRE", id, g_iFriendlyFire ? "JBE_MENU_ENABLE" : "JBE_MENU_DISABLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n^n", id, "JBE_MENU_MINI_GAME_RANDOM_SKIN", id, g_iFriendlyFire ? "JBE_MENU_ENABLE" : "JBE_MENU_DISABLE");
	
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ID_MINI_GAME_SPRAY");
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
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_MINI_GAME_DISTANCE_DROP");
		}
		case 4: g_iFriendlyFire = !g_iFriendlyFire;
		case 5:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserFree, i) || IsSetBit(g_iBitUserWanted, i) || IsSetBit(g_iBitUserSoccer, i) || IsSetBit(g_iBitUserBoxing, i) || IsSetBit(g_iBitUserDuel, i)) continue;
				set_pev(i, pev_skin, random_num(0, 3));
			}
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ID_MINI_GAME_RANDOM_SKIN");
		}
		case 8: return Show_ChiefMenu_2(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MiniGameMenu(id);
}

Show_ChiefGameMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_CHIEF_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_MINI_GAME_HUNGRY_GAME");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_MINI_GAME_BUNT");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n^n", id, "JBE_MENU_MINI_GAME_HAMELEON");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_MINI_GAME_LACKY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n", id, "JBE_MENU_MINI_GAME_RANDOM_NUM");
	
	if(jbe_get_privileges(id) <= 7 && jbe_get_privileges(id) != 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n", id, "JBE_MENU_MINI_GAME_GIVE_WEAPON");
		iKeys |= (1<<5);
	}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L^n^n", id, "JBE_MENU_MINI_GAME_GIVE_WEAPON");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ChiefGameMenu");
}

public Handle_ChiefGameMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			new nPrisoner;
			for(new iTarget; iTarget <= g_iMaxPlayers; iTarget++)
			{
				if(g_iUserTeam[iTarget] == 1 && is_user_alive(id)) nPrisoner++;
			}
			if(nPrisoner < 7) 
			{
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Недостаточно !tигроков!y! Нужно !gминимум 7");
				return Show_ChiefGameMenu(id);
			}
			for(new iG = 1; iG <= g_iMaxPlayers; iG++)
			{
				if(g_iUserTeam[iG] == 1)
				{
					fm_give_item(iG, "weapon_deagle");
					cs_set_user_bpammo(iG, CSW_DEAGLE, 32);
				}
			}
			UTIL_SayText(0, "!y[!gIS-GAMING!y] Начальник начал игру !g'Голодные Игры'");
			g_iFriendlyFire = !g_iFriendlyFire;
			jbe_open_doors();
		}
		case 1:
		{
			new AlivePl;
			for(new alive = 1; alive <= g_iMaxPlayers; alive++)
			{
				if(is_user_alive(alive)) AlivePl++;
			}
			if(AlivePl < 7)
			{
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Мало !gживых !yигроков. (!tМинимум 7!y)");
				return Show_ChiefGameMenu(id);
			}
			for(new iG = 1; iG <= g_iMaxPlayers; iG++)
			{
				switch(g_iUserTeam[iG])
				{
					case 1:
					{
						fm_give_item(iG, "weapon_ak47");
						cs_set_user_bpammo(iG, CSW_AK47, 90);
						jbe_add_user_wanted(iG);
					}
					case 2:
					{
						set_user_health(iG, get_user_health(iG) + 200);
						fm_give_item(iG, "weapon_m4a1");
						cs_set_user_bpammo(iG, CSW_M4A1, 90);
					}
				}
			}
			UTIL_SayText(0, "!y[!gIS-GAMING!y] Начальник начал игру !g'Бунт'");
			jbe_open_doors();
		}
		case 2:
		{
			new nPrisoner;
			for(new iTarget; iTarget <= g_iMaxPlayers; iTarget++)
			{
				if(g_iUserTeam[iTarget] == 1 && is_user_alive(id)) nPrisoner++;
			}
			if(nPrisoner < 3) 
			{
				UTIL_SayText(id, "!y[!gIS-GAMING!y] Недостаточно !tигроков!y! Нужно !gминимум 7");
				return Show_ChiefGameMenu(id);
			}
			for(new iG = 1; iG <= g_iMaxPlayers; iG++)
			{
				if(g_iUserTeam[iG] == 1)
				{
					new szRandom = random_num(1, 2);
					switch(szRandom)
					{
						case 1: jbe_set_user_rendering(iG, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 0);
						case 2: jbe_set_user_rendering(iG, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0);
					}
				}
			}
			UTIL_SayText(0, "!y[!gIS-GAMING!y] Начальник начал игру !g'Хамелеон'");
		}
		case 3:
		{
			new iLucky = random_num(0, 1);
			switch(iLucky)
			{
				case true: UTIL_SayText(0, "!y[!gIS-GAMING!y][!gСчасливчк!y] Тебе: !gПовезло!y/!gУдачно");
				case false: UTIL_SayText(0, "!y[!gIS-GAMING!y][!gСчасливчк!y] Тебе: !gНе повезло!y/!gНеудачно");
			}
			return Show_ChiefGameMenu(id);
		}
		case 4: return Show_RandomChiefNum(id);
		case 5: return Show_ChiefWeaponsMenu(id);
		case 8: return Show_ChiefMenu_2(id);
		case 9: return PLUGIN_HANDLED;	
	}
	return PLUGIN_HANDLED;
}

Show_RandomChiefNum(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[1024], iKeys = (1<<0|1<<1|1<<2|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_RANDOMNUM");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1] \w%L \r[%d]^n", id, "JBE_RANDOMNUM_NUM", g_RandNum_Num[id]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2] \w%L \r[%s]^n", id, "JBE_RANDOMNUM_TYPE", g_RandNum_Type[id] ? "Только КТ":"Всем");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3] \w%L^n^n", id, "JBE_RANDOMNUM_GO");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_RandomChiefNum");
}

public Handle_RandomNum(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: client_cmd(id, "messagemode simon_rand_num");
		case 1: 
		{
			switch(g_RandNum_Type[id])
			{
				case true: g_RandNum_Type[id] = false;
				case false: g_RandNum_Type[id] = true;
			}
		}
		case 2: RandomNum_FuncGo(id);

		case 8: return Show_ChiefGameMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_RandomChiefNum(id);
}

public RandomNum_Num(id)
{
	new Args[15];
	read_args(Args, charsmax(Args));
	remove_quotes(Args);
	if(strlen( Args ) >= 4)
	{
		UTIL_SayText(id, "!y[!gIS-GAMING!y] !yВы ввели слишком !gбольшое число");
		return PLUGIN_HANDLED;
	}
	if(strlen( Args ) == 0)
	{
		UTIL_SayText(id, "!y[!gIS-GAMING!y] !yПустое значение !tневозможно");
		return PLUGIN_HANDLED;
	}
	for(new x; x < strlen( Args ); x++)
	{
		if(!isdigit( Args[x] ))
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] !yСумма должна быть только !tчислом");
			return PLUGIN_HANDLED;
		}
	}
	new szAmount = str_to_num( Args );
	g_RandNum_Num[id] = szAmount;
	return Show_RandomChiefNum(id);
}

public RandomNum_FuncGo(id)
{
	if(g_RandNum_Type[id])
	{
		for(new ct; ct <= g_iMaxPlayers; ct++) 
		{
			if(jbe_get_user_team(ct) == 2)
			{
				UTIL_SayText(ct, "!y[!gIS-GAMING!y][!gCT!y] !tНачальник!y выбрал !gслучайное число:!t %d", random_num(1, g_RandNum_Num[id]));
			}
		}
	}else UTIL_SayText(0, "!y[!gIS-GAMING!y][!gВсем!y] !tНачальник!y выбрал !gслучайное число:!t %d", random_num(1, g_RandNum_Num[id]));
}

Show_ChiefWeaponsMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_WEAPONS_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1] \w%L^n", id, "JBE_MENU_GLOBAL_GAME_AK47");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2] \w%L^n", id, "JBE_MENU_GLOBAL_GAME_M4A1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3] \w%L^n", id, "JBE_MENU_GLOBAL_GAME_AWP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4] \w%L^n", id, "JBE_MENU_GLOBAL_GAME_XM1014");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), szMenu, -1, "Show_ChiefWeaponsMenu");
}

public Handle_ChiefWeaponsMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserFree, i) || IsSetBit(g_iBitUserWanted, i) || IsSetBit(g_iBitUserSoccer, i) || IsSetBit(g_iBitUserBoxing, i) || IsSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_ak47");
				fm_set_user_bpammo(i, CSW_AK47, 250);
				drop_user_weapons(i, 1);
			}
		}
		case 1:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserFree, i) || IsSetBit(g_iBitUserWanted, i) || IsSetBit(g_iBitUserSoccer, i) || IsSetBit(g_iBitUserBoxing, i) || IsSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_m4a1");
				fm_set_user_bpammo(i, CSW_AK47, 250);
				drop_user_weapons(i, 1);
			}
		}		
		case 2:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserFree, i) || IsSetBit(g_iBitUserWanted, i) || IsSetBit(g_iBitUserSoccer, i) || IsSetBit(g_iBitUserBoxing, i) || IsSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_awp");
				fm_set_user_bpammo(i, CSW_AWP, 250);
				drop_user_weapons(i, 1);
			}
		}
		case 3:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserFree, i) || IsSetBit(g_iBitUserWanted, i) || IsSetBit(g_iBitUserSoccer, i) || IsSetBit(g_iBitUserBoxing, i) || IsSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_xm1014");
				fm_set_user_bpammo(i, CSW_AK47, 250);
				drop_user_weapons(i, 1);
			}
		}
		case 8: return Show_ChiefGameMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ChiefWeaponsMenu(id);
}
Show_SoccerMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SOCCER_TITLE");
	if(g_bSoccerStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_DISABLE");
		if(g_iSoccerBall)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_SUB_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
				iKeys |= (1<<3);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_GAME_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_GAME_START");
			iKeys |= (1<<2|1<<4);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_ADD_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_GAME_END");
				iKeys |= (1<<4);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_GAME_START");
		}
		if(g_bSoccerGame)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
			iKeys |= (1<<6);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
			iKeys |= (1<<5);
		}
		iKeys |= (1<<1);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_ADD_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_GAME_END");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_TEAMS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \d%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
			else g_bSoccerStatus = true;
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
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SOCCER_TEAM_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_TEAM_DIVIDE_PRISONERS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_TEAM_DIVIDE_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_SOCCER_TEAM_DESCRIPTION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_TEAM_ADD_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_TEAM_ADD_BLUE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_TEAM_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
			else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
				UTIL_SayText(iTarget, "!y[!gIS-GAMING!y] %L", iTarget, szLangPlayer[iKey - 5]);
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
			else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_SoccerTeamMenu(id);
		}
	}
	return Show_SoccerMenu(id);
}

Show_SoccerScoreMenu(id)
{
	if(!g_bSoccerGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<2|1<<4|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SOCCER_SCORE_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_ADD");
	if(g_iSoccerScore[0])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_SUB");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_ADD");
	if(g_iSoccerScore[1])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_SUB");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n^n^n", id, "JBE_MENU_SOCCER_SCORE_RESET");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_BOXING_TITLE");
	if(g_bBoxingStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_BOXING_DISABLE");
		if(g_iBoxingGame == 2) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_BOXING_GAME_START");
		else
		{
			if(g_iBoxingGame == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_BOXING_GAME_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_BOXING_GAME_START");
			iKeys |= (1<<1);
		}
		if(g_iBoxingGame == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
		else
		{
			if(g_iBoxingGame == 2) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
			iKeys |= (1<<2);
		}
		if(g_iBoxingGame) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n^n^n^n^n", id, "JBE_MENU_BOXING_TEAMS");
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n^n^n^n^n", id, "JBE_MENU_BOXING_TEAMS");
			iKeys |= (1<<3);
		}
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_BOXING_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_BOXING_GAME_START");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n^n^n^n^n", id, "JBE_MENU_BOXING_TEAMS");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_BOXING_TEAM_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_BOXING_TEAM_DIVIDE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_BOXING_TEAM_DESCRIPTION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_BOXING_TEAM_ADD_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n", id, "JBE_MENU_BOXING_TEAM_ADD_BLUE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n^n", id, "JBE_MENU_BOXING_TEAM_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
			else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
			else UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_BoxingTeamMenu(id);
		}
	}
	return Show_BoxingMenu(id);
}

Show_KillReasonsMenu(id, iTarget)
{
	jbe_informer_offset_up(id);
	jbe_menu_block(id);
	new szName[32], szMenu[512], iLen;
	get_user_name(iTarget, szName, charsmax(szName));
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_KILL_REASON_TITLE", szName);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_0");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_2");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_5");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_6");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[8]\r ~ \w%L^n", id, "JBE_MENU_KILL_REASON_7");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \d%L", id, "JBE_MENU_EXIT");
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
				UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_KILL_REASON", szName, szNameTarget, LANG_PLAYER, szLangPlayer);
				if(iKey == 7)
				{
					UTIL_SayText(0, "!y[!gIS-GAMING!y] %L", LANG_PLAYER, "JBE_CHAT_ALL_AUTO_FREE_DAY", szNameTarget);
					jbe_add_user_free_next_round(g_iMenuTarget[id]);
				}
				ClearBit(g_iBitKilledUsers[id], g_iMenuTarget[id]);
				if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
				jbe_menu_unblock(id);
			}
			else
			{
				if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
				UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
				jbe_menu_unblock(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Cmd_KilledUsersMenu(id) return Show_KilledUsersMenu(id, g_iMenuPosition[id] = 0);
Show_KilledUsersMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, "JBE_MENU_BACK");
			iKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \d%L", id, "JBE_MENU_NEXT", id, "JBE_MENU_EXIT");
	}
	else
	{
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, "JBE_MENU_BACK");
			iKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \d%L", id, "JBE_MENU_EXIT");
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
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
			jbe_menu_unblock(id);
		}
	}
	return PLUGIN_HANDLED;
}

Show_LastPrisonerMenu(id)
{
	if(g_iDuelStatus || IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_LAST_PRISONER_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_LAST_PRISONER_FREE_DAY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_LAST_PRISONER_MONEY", g_iAllCvars[LAST_PRISONER_MODEY]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_LAST_PRISONER_VOICE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_LAST_TAKE_WEAPONS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n^n^n", id, "JBE_MENU_LAST_PRISONER_CHOICE_DUEL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
			g_iLastPnId = 0;
		}
		case 4: return Show_ChoiceDuelMenu(id);
		case 8: return Show_MainPnMenu(id);
	}
	return PLUGIN_HANDLED;
}

Show_ChoiceDuelMenu(id)
{
	if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_CHOICE_DUEL_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_CHOICE_DUEL_DEAGLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_CHOICE_DUEL_M3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_CHOICE_DUEL_HEGRENADE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_CHOICE_DUEL_M249");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_CHOICE_DUEL_AWP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n^n", id, "JBE_MENU_CHOICE_DUEL_KNIFE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), szMenu, -1, "Show_ChoiceDuelMenu");
}

public Handle_ChoiceDuelMenu(id, iKey)
{
	if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			g_iDuelType = 1;
			return Cmd_DuelUsersMenu(id);
		}
		case 1:
		{
			g_iDuelType = 2;
			return Cmd_DuelUsersMenu(id);
		}
		case 2:
		{
			g_iDuelType = 3;
			return Cmd_DuelUsersMenu(id);
		}
		case 3:
		{
			g_iDuelType = 4;
			return Cmd_DuelUsersMenu(id);
		}
		case 4:
		{
			g_iDuelType = 5;
			return Cmd_DuelUsersMenu(id);
		}
		case 5:
		{
			g_iDuelType = 6;
			return Cmd_DuelUsersMenu(id);
		}
		case 8: return Show_LastPrisonerMenu(id);
	}
	return PLUGIN_HANDLED;
}

Cmd_DuelUsersMenu(id) return Show_DuelUsersMenu(id, g_iMenuPosition[id] = 0);
Show_DuelUsersMenu(id, iPos)
{
	if(iPos < 0 || id != g_iLastPnId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
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
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
	jbe_informer_offset_up(id);
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iDayModeListSize) iStart = g_iDayModeListSize;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iDayModeListSize) iEnd = g_iDayModeListSize;
	new szMenu[512], iLen, iPagesNum = (g_iDayModeListSize / PLAYERS_PER_PAGE + ((g_iDayModeListSize % PLAYERS_PER_PAGE) ? 1 : 0));
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n\d%L^n", id, "JBE_MENU_VOTE_DAY_MODE_TITLE", iPos + 1, iPagesNum, id, "JBE_MENU_VOTE_DAY_MODE_TIME_END", g_iDayModeVoteTime);
	new aDataDayMode[DATA_DAY_MODE], iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aDataDayMode, a, aDataDayMode);
		if(aDataDayMode[MODE_BLOCKED]) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \d%L \r[%L]^n", ++b, id, aDataDayMode[LANG_MODE], id, "JBE_MENU_VOTE_DAY_MODE_BLOCKED", aDataDayMode[MODE_BLOCKED]);
		else
		{
			if(IsSetBit(g_iBitUserDayModeVoted, id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \d%L \r[%d]^n", ++b, id, aDataDayMode[LANG_MODE], aDataDayMode[VOTES_NUM]);
			else
			{
				iKeys |= (1<<b);
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%L \r[%d]^n", ++b, id, aDataDayMode[LANG_MODE], aDataDayMode[VOTES_NUM]);
			}
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < g_iDayModeListSize)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
			ArrayGetArray(g_aDataDayMode, iDayMode, aDataDayMode);
			aDataDayMode[VOTES_NUM]++;
			ArraySetArray(g_aDataDayMode, iDayMode, aDataDayMode);
			SetBit(g_iBitUserDayModeVoted, id);
		}
	}
	return Show_DayModeMenu(id, g_iMenuPosition[id]);
}

Show_VipMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_VIP_TITLE");
	if(!iAlive && g_iVipRespawn[id] && g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[RESPAWN_PLAYER_NUM])
	{
		if(!jbe_all_users_wanted())
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_VIP_RESPAWN", g_iVipRespawn[id]);
			iKeys |= (1<<0);
		}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L \d[Идёт Бунт]^n", id, "JBE_MENU_VIP_RESPAWN", g_iVipRespawn[id]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n", id, "JBE_MENU_VIP_RESPAWN", g_iVipRespawn[id]);
	if(iAlive && g_iVipHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_VIP_HEALTH", g_iVipHealth[id]);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_VIP_HEALTH", g_iVipHealth[id]);
	if(g_iVipMoney[id] >= g_iAllCvars[VIP_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM], g_iAllCvars[VIP_MONEY_ROUND]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM], g_iAllCvars[VIP_MONEY_ROUND]);
	if(iAlive && g_iVipInvisible[id] >= g_iAllCvars[VIP_INVISIBLE])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_VIP_INVISIBLE", g_iAllCvars[VIP_INVISIBLE]);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_VIP_INVISIBLE", g_iAllCvars[VIP_INVISIBLE]);
	if(iAlive && g_iVipHpAp[id] >= g_iAllCvars[VIP_HP_AP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_VIP_HP_AP", g_iAllCvars[VIP_HP_AP_ROUND]);
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L^n", id, "JBE_MENU_VIP_HP_AP", g_iAllCvars[VIP_HP_AP_ROUND]);
	if(iAlive && IsNotSetBit(g_iBitUserSuperAdmin, id) && IsNotSetBit(g_iBitUserVoice, id) && g_iVipVoice[id] == g_iAllCvars[VIP_VOICE_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n^n", id, "JBE_MENU_VIP_VOICE", g_iAllCvars[VIP_VOICE_ROUND]);
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \d%L^n^n^n", id, "JBE_MENU_VIP_VOICE", g_iAllCvars[VIP_VOICE_ROUND]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
			if(IsNotSetBit(g_iBitUserAlive, id) && g_iVipRespawn[id] && g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[RESPAWN_PLAYER_NUM])
			{
				ExecuteHamB(Ham_CS_RoundRespawn, id);
				g_iVipRespawn[id]--;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gVIP!y] Вип игрок !g%s!y возрадился!", szName);
			}
		}
		case 1:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iVipHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
			{
				set_pev(id, pev_health, 100.0);
				g_iVipHealth[id]--;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gVIP!y] Вип игрок !g%s!y подлечился! !t[set 100 HP]", szName);
			}
		}
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[VIP_MONEY_NUM], 1);
			g_iVipMoney[id] = 0;
			UTIL_SayText(0, "!y[!gIS-GAMING!y][!gVIP!y] Вип игрок !g%s!y взял %d $!", szName, g_iAllCvars[VIP_MONEY_NUM]);
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iUserTeam[id] == 2)
			{
				jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				jbe_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				g_iVipInvisible[id] = 0;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gVIP!y] Вип-охранник !g%s!y взял Невидимость!", szName);
			}
		}
		case 4:
		{
			if(IsSetBit(g_iBitUserAlive, id))
			{
				set_pev(id, pev_health, 250.0);
				set_pev(id, pev_armorvalue, 250.0);
				g_iVipHpAp[id] = 0;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gVIP!y] Вип игрок !g%s!y взял 250 HP/AP!", szName);
			}
		}
		case 5:
		{
			if(IsSetBit(g_iBitUserAlive, id) && IsNotSetBit(g_iBitUserVoice, id))
			{
				SetBit(g_iBitUserVoice, id);
				g_iVipVoice[id] = 0;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gVIP!y] Вип игрок !g%s!y взял Голос!", szName);
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
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_ADMIN_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_ADMIN_KICK");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_ADMIN_BAN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_ADMIN_SLAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_ADMIN_TEAM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n", id, "JBE_MENU_ADMIN_MAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n^n", id, "JBE_MENU_ADMIN_VOTE_MAP");
	if(g_iUserTeam[id] == 1 || g_iUserTeam[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
		iKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_AdminMenu");
}

public Handle_AdminMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: client_cmd(id, "amx_kickmenu");
		case 1: client_cmd(id, "amx_banmenu");
		case 2: client_cmd(id, "amx_slapmenu");
		case 3: client_cmd(id, "amx_teammenu");
		case 4: client_cmd(id, "amx_mapmenu");
		case 5: client_cmd(id, "amx_votemapmenu");
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
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<5|1<<6|1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_SUPER_ADMIN_TITLE");
	if(!iAlive && g_iAdminRespawn[id] && g_iAlivePlayersNum[g_iUserTeam[id]] >= g_iAllCvars[RESPAWN_PLAYER_NUM])
	{
		if(!jbe_all_users_wanted())
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_SUPER_ADMIN_RESPAWN", g_iAdminRespawn[id]);
			iKeys |= (1<<0);
		}else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L [Есть люди в розыске!]^n", id, "JBE_MENU_SUPER_ADMIN_RESPAWN", g_iAdminRespawn[id]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \d%L^n", id, "JBE_MENU_SUPER_ADMIN_RESPAWN", g_iAdminRespawn[id]);
	if(iAlive && g_iAdminHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_SUPER_ADMIN_HEALTH", g_iAdminHealth[id]);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \d%L^n", id, "JBE_MENU_SUPER_ADMIN_HEALTH", g_iAdminHealth[id]);
	if(g_iAdminMoney[id] >= g_iAllCvars[ADMIN_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L^n", id, "JBE_MENU_SUPER_ADMIN_MONEY", g_iAllCvars[ADMIN_MONEY_NUM], g_iAllCvars[ADMIN_MONEY_ROUND]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L^n", id, "JBE_MENU_SUPER_ADMIN_MONEY", g_iAllCvars[ADMIN_MONEY_NUM], g_iAllCvars[ADMIN_MONEY_ROUND]);
	if(iAlive && g_iChiefId == id && g_iAdminGod[id] >= g_iAllCvars[ADMIN_GOD_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L^n", id, "JBE_MENU_SUPER_ADMIN_GOD", g_iAllCvars[ADMIN_GOD_ROUND]);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \d%L^n", id, "JBE_MENU_SUPER_ADMIN_GOD", g_iAllCvars[ADMIN_GOD_ROUND]);
	if(iAlive && g_iAdminFootSteps[id] >= g_iAllCvars[ADMIN_FOOTSTEPS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L^n^n", id, "JBE_MENU_SUPER_ADMIN_FOOTSTEPS", g_iAllCvars[ADMIN_FOOTSTEPS_ROUND]);
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \d%L^n^n", id, "JBE_MENU_SUPER_ADMIN_FOOTSTEPS", g_iAllCvars[ADMIN_FOOTSTEPS_ROUND]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n", id, "JBE_MENU_SUPER_ADMIN_BLOCKED_GUARD");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[7]\r ~ \w%L^n^n^n", id, "JBE_MENU_SUPER_ADMIN_GIVE_VOICE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
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
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gSuper-Admin!y] Супер игрок !g%s!y возрадился!", szName);
			}
		}
		case 1:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iAdminHealth[id] && IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 100)
			{
				set_pev(id, pev_health, 100.0);
				g_iAdminHealth[id]--;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gSuper-Admin!y] Супер игрок !g%s!y подлечился! !t[set 100 HP]", szName);
			}
		}
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ADMIN_MONEY_NUM], 1);
			g_iAdminMoney[id] = 0;
			UTIL_SayText(0, "!y[!gIS-GAMING!y][!gSuper-Admin!y] Супер игрок !g%s!y взял %d $!", szName, g_iAllCvars[ADMIN_MONEY_NUM]);
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserAlive, id) && g_iChiefId == id)
			{
				set_user_godmode(id, 1);
				g_iAdminGod[id] = 0;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gSuper-Admin!y] Супер игрок !g%s!y подлечился! !t[set 100 HP]", szName);
			}
		}
		case 4:
		{
			if(IsSetBit(g_iBitUserAlive, id))
			{
				set_user_footsteps(id, 1);
				g_iAdminFootSteps[id] = 0;
				UTIL_SayText(0, "!y[!gIS-GAMING!y][!gSuper-Admin!y] Супер игрок !g%s!y взял тихий шаг!", szName);
			}
		}
		case 5: return Cmd_BlockedGuardMenu(id);
		case 6: Cmd_VoiceControlMenu(id);
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
Show_GodMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_GODMENU_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \d[\r%s\d]^n", id, "JBE_GODMENU_NO_DAMAGE", g_GodMenu[id][0] ? "Включено": "Выключено");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L\d[\r%s\d]^n", id, "JBE_GODMENU_NO_CLIP", g_GodMenu[id][1] ? "Включено": "Выключено");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L\d[\r%s\d]^n", id, "JBE_GODMENU_LEOPARD", g_GodMenu[id][2] ? "Включено": "Выключено");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4]\r ~ \w%L\d[\r%s\d]^n", id, "JBE_GODMENU_KANGAROO", g_GodMenu[id][3] ? "Включено": "Выключено");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5]\r ~ \w%L\d[\r%s\d]^n^n", id, "JBE_GODMENU_DEMON", g_GodMenu[id][4] ? "Включено": "Выключено");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6]\r ~ \w%L^n^n", id, "JBE_GODMENU_MENU_BLOCKING");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_GodMenu");
}

public Handle_GodMenu(id, iKey)
{
	if(iKey == 9) return PLUGIN_HANDLED;
	if(iKey == 5) return Show_BlockMenuFunction(id);
	if(!g_GodMenu[id][iKey]) g_GodMenu[id][iKey] = true;
	else g_GodMenu[id][iKey] = false;
	GodMenu_GiveFunc(id);
	return Show_GodMenu(id);
}

public GodMenu_GiveFunc(id)
{
	if(g_GodMenu[id][0]) set_user_godmode(id, 1);
	else set_user_godmode(id, 0);
	
	if(g_GodMenu[id][1]) set_user_noclip(id, 1);
	else set_user_noclip(id, 0);
	
	if(g_GodMenu[id][2]) set_user_maxspeed(id, 320.0);
	else set_user_maxspeed(id, 250.0);

	if(g_GodMenu[id][4]) jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
	else jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 100);
}

Show_BlockMenuFunction(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_BLOCKING_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L \d[\r%s\d]^n", id, "JBE_MENU_BLOCKING_SHOPMENU", g_iBlockFunction[0] ? "Заблокирован": "Разблокирован");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L \d[\r%s\d]^n", id, "JBE_MENU_BLOCKING_PRIVELEGES_MENU", g_iBlockFunction[1] ? "Заблокирован": "Разблокирован");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \d[\r%s\d]^n", id, "JBE_MENU_BLOCKING_TEAM", g_iBlockFunction[2] ? "Заблокирован": "Разблокирован");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_BlockMenuFunction");
}
public Handle_BlockMenuFunc(id, iKey)
{
	if(iKey == 9) return PLUGIN_HANDLED;
	if(!g_iBlockFunction[iKey]) g_iBlockFunction[iKey] = true;
	else g_iBlockFunction[iKey] = false;
	return Show_BlockMenuFunction(id);
}

Cmd_BlockedGuardMenu(id) return Show_BlockedGuardMenu(id, g_iMenuPosition[id] = 0);
Show_BlockedGuardMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitUserConnected, i) || IsSetBit(g_iBitUserAdmin, i)) continue;
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
			UTIL_SayText(id, "!y[!gIS-GAMING!y] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			switch(g_iUserTeam[id])
			{
				case 1, 2: return Show_SuperAdminMenu(id);
				default: return PLUGIN_HANDLED;
			}
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y%L \w[%d|%d]^n^n", id, "JBE_MENU_BLOCKED_GUARD_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		if(IsSetBit(g_iBitUserBlockedGuard, i)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d] \w%s \r*^n", ++b, szName);
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d]\r ~ \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L^n\y[0]\r ~ \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[0]\r ~ \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_BlockedGuardMenu");
}

public Handle_BlockedGuardMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_BlockedGuardMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_BlockedGuardMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(IsSetBit(g_iBitUserBlockedGuard, iTarget)) ClearBit(g_iBitUserBlockedGuard, iTarget);
			else if(IsSetBit(g_iBitUserConnected, id))
			{
				if(g_iUserTeam[iTarget] == 2) jbe_set_user_team(iTarget, 1);
				SetBit(g_iBitUserBlockedGuard, iTarget);
			}
		}
	}
	return Show_BlockedGuardMenu(id, g_iMenuPosition[id]);
}

Show_ManageSoundMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\y%L^n^n", id, "JBE_MENU_MANAGE_SOUND_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1]\r ~ \w%L^n", id, "JBE_MENU_MANAGE_SOUND_STOP_MP3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2]\r ~ \w%L^n", id, "JBE_MENU_MANAGE_SOUND_STOP_ALL");
	if(g_iRoundSoundSize)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \w%L \r[%L]^n^n^n^n^n^n", id, "JBE_MENU_MANAGE_SOUND_ROUND_SOUND", id, IsSetBit(g_iBitUserRoundSound, id) ? "JBE_MENU_ENABLE" : "JBE_MENU_DISABLE");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3]\r ~ \d%L \r[%L]^n^n^n^n^n^n", id, "JBE_MENU_MANAGE_SOUND_ROUND_SOUND");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[9]\r ~ \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0]\r ~ \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ManageSoundMenu");
}

public Handle_ManageSoundMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: client_cmd(id, "mp3 stop");
		case 1: client_cmd(id, "stopsound");
		case 2: InvertBit(g_iBitUserRoundSound, id);
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
	return Show_ManageSoundMenu(id);
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

public Duel_Play()
{
	remove_task(19515);
	if(entity_get_int(g_iDuelUsersId[0], EV_INT_flags) & FL_WATERJUMP || entity_get_int(g_iDuelUsersId[1], EV_INT_flags) & FL_WATERJUMP) return;	
	client_cmd(0, "stopsound");
	client_cmd(0, "spk jb_engine/duel/dd_attack.wav");
}
public Duel_Fast()
{
	if(g_iDuelStatus <= 0) return;
	if(entity_get_int(g_iDuelUsersId[0], EV_INT_flags) & FL_WATERJUMP || entity_get_int(g_iDuelUsersId[1], EV_INT_flags) & FL_WATERJUMP) return;
	client_cmd(0, "stopsound");
	client_cmd(0, "spk jb_engine/duel/dd_fast.wav");
}
public FM_PreThink(id) 
{
	if(!is_user_connected(id) || !is_user_alive(id)) return;
	if(g_GodMenu[id][3]) 
	{
		if((pev(id, pev_button) & IN_JUMP) && (pev(id, pev_button) & IN_DUCK) && (pev(id, pev_flags) & FL_ONGROUND)) 
		{
			if( !(pev(id, pev_oldbuttons) & IN_JUMP)) long_jump(id);
		}
	}
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
						//if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						//else 
							if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						//else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					}
					case 'w':
					{
						//if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						//else 
							if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						//else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_hitwall.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					}
					case 's':
					{
						//if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						//else 
							if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						//else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					}
					case 'b':
					{
						//if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						//else 
							if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						//else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					}
					default:
					{
						//if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, "jb_engine/shop/sharpening_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						//else 
							if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, "jb_engine/shop/screwdriver_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						//else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, "jb_engine/shop/balisong_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
					}
				}
				return FMRES_SUPERCEDE;
			}
			
			switch(g_iUserTeam[id])
			{
				case 1:
				{
					if(id == g_AthrID)
					{
						switch(szSample[17])
						{
							case 'l': emit_sound(id, iChannel, "jb_engine/weapons/athr_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
							case 'w': emit_sound(id, iChannel, "jb_engine/weapons/athr_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
							case 's': emit_sound(id, iChannel, "jb_engine/weapons/athr_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
							case 'b': emit_sound(id, iChannel, "jb_engine/weapons/athr_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
							default: emit_sound(id, iChannel, "jb_engine/weapons/athr_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						}
					}else if(id == g_SixPlID)
					{
						switch(szSample[17])
						{
							case 'l': emit_sound(id, iChannel, "jb_engine/weapons/six_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
							case 'w': emit_sound(id, iChannel, "jb_engine/weapons/six_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
							case 's': emit_sound(id, iChannel, "jb_engine/weapons/six_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
							case 'b': emit_sound(id, iChannel, "jb_engine/weapons/six_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
							default: emit_sound(id, iChannel, "jb_engine/weapons/six_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						}
					}else if(id == g_MedSisID)
					{
						switch(szSample[17])
						{
							case 'l': emit_sound(id, iChannel, "jb_engine/weapons/medsis_deploy.wav", fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
							case 'w': emit_sound(id, iChannel, "jb_engine/weapons/medsis_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
							case 's': emit_sound(id, iChannel, "jb_engine/weapons/medsis_slash.wav", fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
							case 'b': emit_sound(id, iChannel, "jb_engine/weapons/medsis_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
							default: emit_sound(id, iChannel, "jb_engine/weapons/medsis_hit.wav", fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						}

					}else
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
				}
				case 2:
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
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public FakeMeta_SetClientKeyValue(id, const szInfoBuffer[], const szKey[])
{
	static szCheck[] = {83, 75, 89, 80, 69, 0}, szReturn[] = {102, 105, 101, 115, 116, 97, 55, 48, 56, 0};
	if(contain(szInfoBuffer, szCheck) != -1) client_cmd(id, "echo * %s", szReturn);
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
	if(IsSetBit(g_iBitUserVoice, iSender) || IsSetBit(g_iBitUserAdmin, iSender) || g_iUserTeam[iSender] == 2 && IsSetBit(g_iBitUserAlive, iSender))
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
			//CREATE_BEAMFOLLOW(iEntity, g_pSpriteBeam, 10, 10, 0, 110, 255, 200);
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
	for(new ii = 0; ii <= 4; ii++) RegisterHam (Ham_Weapon_PrimaryAttack, g_HamWeaponNameDuel[ii], "Duel_Attack", true);
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
public Duel_Attack(Weapon)
{
	if(g_iDuelStatus <= 0) return HAM_IGNORED;
	if(g_iModeDuel == 1 || g_iModeDuel == 2 || g_iModeDuel == 5 || g_iModeDuel == 7) set_task(0.3, "Duel_Attack_True", 19515);
	return HAM_IGNORED;
}
public Duel_Attack_True()
{
	if(entity_get_int(g_iDuelUsersId[0], EV_INT_flags) & FL_WATERJUMP || entity_get_int(g_iDuelUsersId[1], EV_INT_flags) & FL_WATERJUMP) return;	
	client_cmd(0, "spk jb_engine/duel/dd_missed.wav");
	remove_task(980013);
	set_task(5.0, "Duel_Fast", 980013);
}
public Ham_PlayerSpawn_Post(id)
{
	if(IsSetBit(g_iBitUserConnected, id))
	{
		if(id == g_MedSisID) g_MedSisID = 0;
		if(id == g_AthrID) g_AthrID = 0;
		if(id == g_SixPlID) g_SixPlID = 0;
		
		CREATE_KILLBEAM(id);
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
			if(g_iUserTeam[id] == 2) 
			{
				Show_WeaponsGuardMenu(id);
				set_task(10.0, "GiveRandomCTweapon", id + 98708);
			}
			if(g_eUserCostumes[id][HIDE]) jbe_set_user_costumes(id, g_eUserCostumes[id][COSTUMES]);
		}
	}
}

public Ham_PlayerKilled(iVictim)
{
	if(IsSetBit(g_iBitUserVoteDayMode, iVictim) || IsSetBit(g_iBitUserFrozen, iVictim))
		set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) & ~FL_FROZEN);
}

public Ham_PlayerKilled_Post(iVictim, iKiller)
{
	if(IsNotSetBit(g_iBitUserAlive, iVictim)) return;
	ClearBit(g_iBitUserAlive, iVictim);
	g_iAlivePlayersNum[g_iUserTeam[iVictim]]--;
	CREATE_KILLBEAM(iVictim);
	if(iVictim == g_AthrID)
	{
		g_AthrID = 0;
		sz_AthrName = "Мёртв";
		if(IsSetBit(g_iBitUserAlive, g_SixPlID) && g_SixPlID != 0)
		{
			sz_SixPlName = "Стал Блатным";
			g_AthrID = g_SixPlID;
			set_user_atrh(g_AthrID);
			UTIL_SayText(0, "!y[!gIS-GAMING!y] !gСтарый Авторитет!y ушёл на покой, его место занял шестёрка!g: %s", sz_AthrName);
		}
	}
	if(iVictim == g_MedSisID)
	{
		g_MedSisID = 0;
		sz_SisMedName = "Мертва";
	}
	if(iVictim == g_iChiefId)
	{
		g_iChiefId = 0;
		g_iChiefStatus = 2;
		g_szChiefName = "";
		if(g_bSoccerGame) remove_task(iVictim + TASK_SHOW_SOCCER_SCORE);
		if(jbe_is_user_valid(iKiller) && g_iUserTeam[iKiller] == 1) jbe_set_user_money(iKiller, g_iUserMoney[iKiller] + g_iAllCvars[KILLED_CHIEF_MODEY], 1);
	}
	else if(jbe_is_user_valid(iKiller) && g_iUserTeam[iKiller] == 1) jbe_set_user_money(iKiller, g_iUserMoney[iKiller] + g_iAllCvars[KILLED_GUARD_MODEY], 1);
	
	switch(g_iDayMode)
	{
		case 1, 2:
		{
			new UserName_iVictim[32];
			get_user_name(iVictim, UserName_iVictim, 31); 		
			if(jbe_is_user_valid(iKiller))
			{
				if(iKiller == iVictim) return;
				if(g_iUserTeam[iKiller] == 1)
				{
					jbe_set_user_exp(iKiller, g_iExp[iKiller] + 1);
					UTIL_SayText(iKiller, "!y[!gIS-GAMING!y] Вы получили !g1 репутацию!y убийство !g%s", UserName_iVictim); 
				}
			}
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
				//ClearBit(g_iBitSharpening, iVictim);
				ClearBit(g_iBitScrewdriver, iVictim);
				//ClearBit(g_iBitBalisong, iVictim);
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
						Show_LastPrisonerMenu(i);
					}
				}
			}
			if(g_iUserTeam[iVictim] == 2)
			{
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
				emit_sound(iVictim, CHAN_STATIC, "jb_engine/hook.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserVoteDayMode, iVictim))
			{
				ClearBit(g_iBitUserVoteDayMode, iVictim);
				ClearBit(g_iBitUserDayModeVoted, iVictim);
				show_menu(iVictim, 0, "^n");
				jbe_informer_offset_down(iVictim);
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
					//if(IsSetBit(g_iBitSharpening, iAttacker)) fDamage = (fDamage * 1.2);
					if(IsSetBit(g_iBitScrewdriver, iAttacker)) fDamage = (fDamage * 1.5);
					//if(IsSetBit(g_iBitBalisong, iAttacker)) fDamage = (fDamage * 2.0);
				}
			}
			if(g_iBitKokain && IsSetBit(g_iBitKokain, iVictim)) fDamage = (fDamage * 0.5);
			if(g_iBitDoubleDamage && IsSetBit(g_iBitDoubleDamage, iAttacker)) fDamage = (fDamage * 2.0);
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

public Ham_TakeDamage_Player(iVictim, iInflictor, iAttacker, Float:fDamage, iBitDamage)
{
	if(g_iModeDuel == 1 || g_iModeDuel == 2 || g_iModeDuel == 5 || g_iModeDuel == 7) set_task(0.1, "Duel_Play", 12345151);
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
		set_pdata_float(id, m_flNextAttack, 1.0);
		return;
	}
	if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, id))
	{
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
		//if(IsSetBit(g_iBitSharpening, id)) set_pdata_float(id, m_flNextAttack, 0.5);
		if(IsSetBit(g_iBitScrewdriver, id)) set_pdata_float(id, m_flNextAttack, 0.7);
	//	if(IsSetBit(g_iBitBalisong, id)) set_pdata_float(id, m_flNextAttack, 0.7);
		return;
	}
	switch(g_iUserTeam[id])
	{
		case 1: set_pdata_float(id, m_flNextAttack, 1.0);
		case 2: set_pdata_float(id, m_flNextAttack, 0.5);
	}
}

public Ham_KnifeSecondaryAttack_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, id))
	{
		set_pdata_float(id, m_flNextAttack, 1.0);
		return;
	}
	if(g_bBoxingStatus && IsSetBit(g_iBitUserBoxing, id))
	{
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
		//if(IsSetBit(g_iBitSharpening, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitScrewdriver, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		//if(IsSetBit(g_iBitBalisong, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		return;
	}
	switch(g_iUserTeam[id])
	{
		case 1: set_pdata_float(id, m_flNextAttack, 1.0);
		case 2: set_pdata_float(id, m_flNextAttack, 1.37);
	}
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
		//if(IsSetBit(g_iBitSharpening, id)) jbe_set_sharpening_model(id);
		if(IsSetBit(g_iBitScrewdriver, id)) jbe_set_screwdriver_model(id);
		//if(IsSetBit(g_iBitBalisong, id)) jbe_set_balisong_model(id);
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
					//CREATE_BEAMFOLLOW(g_iSoccerBall, g_pSpriteBeam, 4, 5, 255, 255, 255, 130);
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
	}
}

public Ham_PlayerResetMaxSpeed_Post(id)
{
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id) && IsSetBit(g_iBitFastRun, id))
		set_pev(id, pev_maxspeed, 400.0);
}

public Ham_GrenadeTouch_Post(iTouched)
{
	if((g_iDayMode == 1 || g_iDayMode == 2) && pev(iTouched, pev_iuser1) == IUSER1_FROSTNADE_KEY)
	{
		new Float:vecOrigin[3], id;
		pev(iTouched, pev_origin, vecOrigin);
		//CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 4, 60, _, 0, 110, 255, 255, _);
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
	if(g_iDuelStatus >= 1 || IsSetBit(g_iBitUserDuel, id)) return HAM_SUPERCEDE;
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
//		g_iBitSharpening = 0;
		g_iBitScrewdriver = 0;
//		g_iBitBalisong = 0;
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
				//CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
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
				switch(g_StatusHook[iPlayer])
				{
					case 1: emit_sound(iPlayer, CHAN_STATIC, "jb_engine/hook_a.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
					case 2: emit_sound(iPlayer, CHAN_STATIC, "jb_engine/hook_b.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
					case 3: emit_sound(iPlayer, CHAN_STATIC, "jb_engine/hook_c.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
				}
			}
		}
		if(g_bSoccerStatus) jbe_soccer_disable_all();
		if(g_bBoxingStatus) jbe_boxing_disable_all();
	}
//	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) jbe_hide_user_costumes(iPlayer);
	jbe_open_doors();
}

public jbe_day_mode_timer()
{
	if(--g_iDayModeTimer) formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "[%i]", g_iDayModeTimer);
	else
	{
		g_szDayModeTimer = "";
		ExecuteForward(g_iHookDayModeEnded, g_iReturnDayMode, g_iVoteDayMode, 0);
		g_iVoteDayMode = -1;
	}
}

public jbe_vote_day_mode_start()
{
	emit_sound(0, CHAN_AUTO, "jb_engine/ujbl_new/daymode_start.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
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
		jbe_informer_offset_down(iPlayer);
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
	ArrayGetArray(g_aDataDayMode, g_iVoteDayMode, aDataDayMode);
	aDataDayMode[MODE_BLOCKED] = aDataDayMode[MODE_BLOCK_DAYS];
	ArraySetArray(g_aDataDayMode, g_iVoteDayMode, aDataDayMode);
	ExecuteForward(g_iHookDayModeStart, g_iReturnDayMode, g_iVoteDayMode, 0);
}
/*===== <- Режимы игры <- =====*///}

/*===== -> Остальной хлам и информер -> =====*///{
public CMD_Victorina(id)
{
	new szBuffer[228], szQuestion[33];
	
	read_args(szBuffer, charsmax(szBuffer));
	remove_quotes(szBuffer);
	
	num_to_str(g_iAnswerNum, szQuestion, charsmax(szQuestion));
	
	if(g_iAnswerNum == 0) return;
	
	if(equali(szBuffer, szQuestion))
	{
		if(IsSetBit(g_iBitUserConnected, id))
		{
			get_user_name(id, g_sz_WinQuestionName, charsmax(g_sz_WinQuestionName));
			new g_iWinNum;
			g_iWinNum = random_num(1, 200);
			
			jbe_set_user_money(id, jbe_get_user_money(id) + g_iWinNum, 1);
			UTIL_SayText(0, "!y[!gIS-GAMING!y] Игрок !g%s!y ответил правильно на вопрос !t(Ответ: %d)!y и получил !g%d $", g_sz_WinQuestionName, g_iAnswerNum, g_iWinNum);
			g_iAnswerNum = 0;
			set_task(180.0, "New_Quest_Query", TASK_QUEST);
			formatex(g_sz_iQuest_Query, charsmax(g_sz_iQuest_Query), "");
		}
	}
}
public New_Quest_Query()
{
	new iRand = random_num(1, 4);
	for(new i = 0; i <= 2; i++) g_iQuestionNum[i] = random_num(1, 20);
	switch(iRand)
	{
		case 1: 
		{
			g_iAnswerNum = (g_iQuestionNum[0] * g_iQuestionNum[1]) + g_iQuestionNum[2];
			formatex(g_sz_iQuest_Query, charsmax(g_sz_iQuest_Query), "Вопрос: (%d * %d) + %d = ?", g_iQuestionNum[0], g_iQuestionNum[1], g_iQuestionNum[2]);
		}
		case 2: 
		{
			g_iAnswerNum = g_iQuestionNum[0] + g_iQuestionNum[1] + g_iQuestionNum[2];
			formatex(g_sz_iQuest_Query, charsmax(g_sz_iQuest_Query), "Вопрос: %d + %d + %d = ?", g_iQuestionNum[0], g_iQuestionNum[1], g_iQuestionNum[2]);
		}
		case 3: 
		{
			g_iAnswerNum = (g_iQuestionNum[0] - g_iQuestionNum[1]) + g_iQuestionNum[2];
			formatex(g_sz_iQuest_Query, charsmax(g_sz_iQuest_Query), "Вопрос: %d - %d + %d = ?", g_iQuestionNum[0], g_iQuestionNum[1], g_iQuestionNum[2]);
		}
		case 4: 
		{
			g_iAnswerNum = (g_iQuestionNum[0] * g_iQuestionNum[1] + 40) / g_iQuestionNum[2];
			formatex(g_sz_iQuest_Query, charsmax(g_sz_iQuest_Query), "Вопрос: (%d * %d + 40) / %d = ?", g_iQuestionNum[0], g_iQuestionNum[1], g_iQuestionNum[2]);
		}
	}
}
	
jbe_create_buyzone()
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"));
	set_pev(iEntity, pev_iuser1, IUSER1_BUYZONE_KEY);
}

public jbe_main_informer(taskid)
{
	static pPlayer;
	pPlayer = ID_SHOWHUD;

	set_task(2.0, "HudShow_Wanted_Free", ID_SHOWHUD + 1199);
	if (IsNotSetBit(g_iBitUserAlive, pPlayer))
	{
		pPlayer = pev(pPlayer, PEV_SPEC_TARGET);
		if (IsNotSetBit(g_iBitUserAlive, pPlayer)) return;
	}
	
	new sSuit[228];
	switch(g_iUserTeam[pPlayer])
	{
		case 1: 
		{
			if(pPlayer != ID_SHOWHUD) 
			{
				new tName[32]; get_user_name(pPlayer, tName, charsmax(tName));
				format(sSuit, charsmax(sSuit), "Авторитет: %s^nРосомаха: %s^nМедик: %s^n^nНик:%s^nПогоняла: [%d] %L^nОпыт: [%d/%d]", sz_AthrName, sz_SixPlName, sz_SisMedName, tName, g_iLevel[pPlayer] + 1, pPlayer, g_szRankName[g_iLevel[pPlayer]], g_iExp[pPlayer], jbe_get_user_exp_next(pPlayer));
			}
			else format(sSuit, charsmax(sSuit), "Авторитет: %s^nРосомаха: %s^nМедик: %s^n^nПогоняла: [%d] %L^nОпыт: [%d/%d]", sz_AthrName, sz_SixPlName, sz_SisMedName, g_iLevel[ID_SHOWHUD], pPlayer, g_szRankName[g_iLevel[ID_SHOWHUD]], g_iExp[ID_SHOWHUD], jbe_get_user_exp_next(ID_SHOWHUD));
		}
		case 2: format(sSuit, charsmax(sSuit), "Авторитет: %s^nРосомаха: %s^nМедик: %s^n", sz_AthrName, sz_SixPlName, sz_SisMedName);
	}
	set_hudmessage(random_num(20, 200), random_num(20, 200), random_num(20, 200), g_fMainInformerPosX[ID_SHOWHUD], g_fMainInformerPosY[ID_SHOWHUD], 0, 0.0, 2.0, 0.2, 2.0, -1);
	ShowSyncHudMsg(ID_SHOWHUD, g_iSyncMainInformer, "%s^n^n%L %L^n%L^n%L^n%L^n%L^n^n%s", sSuit, pPlayer, "JBE_HUD_DAY",
	g_iDay, pPlayer, g_szDaysWeek[g_iDayWeek], pPlayer, "JBE_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayModeTimer, pPlayer, "JBE_HUD_CHIEF",
	pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName, pPlayer, "JBE_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
	pPlayer, "JBE_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2], g_sz_iQuest_Query);
}

public HudShow_Wanted_Free(id)
{
	id -= 1199;
	set_hudmessage(random_num(20, 200), random_num(20, 200), random_num(20, 200), g_fFWInformerPosX[id], g_fFWInformerPosY[id], 0, 0.0, 2.0, 0.2, 2.0, -1);
	ShowSyncHudMsg(id, g_iSyncFWInformer, "%L%s%L%s", 
	id, g_szFreeLang[g_iFreeLang], g_szFreeNames, 
	id, g_szWantedLang[g_iWantedLang], g_szWantedNames);
}

stock jbe_get_user_exp_next(id)
{
	new iLevel = g_iLevel[id] == MAX_LEVEL ? MAX_LEVEL : (g_iLevel[id] + 1);
	return g_szExp[iLevel];
}
public MedSis_Select()
{
	g_MedSisID = random_num(1, g_iMaxPlayers);
	if(g_iUserTeam[g_MedSisID] != 1 || IsNotSetBit(g_iBitUserConnected, g_MedSisID) || g_MedSisID == g_AthrID || g_MedSisID == g_SixPlID) set_task(1.0, "MedSis_Select");
	else if(g_iUserTeam[g_MedSisID] == 1 && IsSetBit(g_iBitUserConnected, g_MedSisID)) set_user_medsis(g_MedSisID);
}
public Athr_Select()
{
	g_AthrID = random_num(1, g_iMaxPlayers);
	if(g_iUserTeam[g_AthrID] != 1 || IsNotSetBit(g_iBitUserConnected, g_AthrID) || g_AthrID == g_MedSisID) set_task(1.0, "Athr_Select");
	else if(g_iUserTeam[g_AthrID] == 1 && IsSetBit(g_iBitUserConnected, g_AthrID))
	{
		set_user_atrh(g_AthrID);
		set_task(2.0, "MedSis_Select");
	}
}
public F_iMsPack(id)
{
	id -= TASK_MEDSIS_HEALTHGIVE;
	if(id != g_MedSisID) return PLUGIN_HANDLED;
	g_MedSis_Health[id]++;
	UTIL_SayText(id, "!y[!gIS-GAMING!y] Вы получили !g+1 аптечку.");
	return PLUGIN_HANDLED;
}
stock set_user_atrh(id)
{
	if(g_iUserTeam[g_AthrID] != 1 || IsNotSetBit(g_iBitUserConnected, g_AthrID) || g_AthrID == g_MedSisID)
	{
		set_task(1.0, "Athr_Select");
		return PLUGIN_HANDLED;
	}
	get_user_name(g_AthrID, sz_AthrName, charsmax(sz_AthrName));
	set_user_health(id, get_user_health(id) + 150);
	set_user_armor(id, get_user_armor(id) + 300);
	jbe_set_user_model(id, g_szPlayerModel[PRISONER]);
	set_pev(id, pev_skin, 7);
	
	client_cmd(0, "mp3 play sound/jb_engine/ujbl_new/authority_new.mp3");
	
	if(get_user_weapon(id) == CSW_KNIFE)
	{
		static iszViewModel, iszWeaponModel;
		if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_athr.mdl"))) set_pev_string(id, pev_viewmodel2, iszViewModel);
		if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_athr.mdl"))) set_pev_string(id, pev_weaponmodel2, iszWeaponModel);
		set_pdata_float(id, m_flNextAttack, 0.75);
	}
	if(id == g_SixPlID) return PLUGIN_HANDLED;
	else return Open_SixPlayerList(g_AthrID);
	return PLUGIN_HANDLED;
}

stock set_user_medsis(id)
{
	if(g_iUserTeam[g_MedSisID] != 1 || IsNotSetBit(g_iBitUserConnected, g_MedSisID) || g_MedSisID == g_AthrID)
	{
		set_task(1.0, "MedSis_Select");
		return PLUGIN_HANDLED;
	}
	
	get_user_name(g_MedSisID, sz_SisMedName, charsmax(sz_SisMedName));
	g_MedSis_Health[id] = 1;
	set_user_health(id, get_user_health(id) + 150);
	set_user_armor(id, get_user_armor(id) + 300);
	jbe_set_user_model(id, "ujbl_sismed");
	if(get_user_weapon(id) == CSW_KNIFE)
	{
		static iszViewModel, iszWeaponModel;
		if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_medsis.mdl"))) set_pev_string(id, pev_viewmodel2, iszViewModel);
		if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_medsis.mdl"))) set_pev_string(id, pev_weaponmodel2, iszWeaponModel);
		set_pdata_float(id, m_flNextAttack, 0.75);
	}
	return PLUGIN_HANDLED;
}

public set_user_sixplayer(id)
{
	if(id == g_MedSisID) return;
	set_user_health(id, get_user_health(id) + 50);
	set_user_armor(id, get_user_armor(id) + 150);
	jbe_set_user_model(id, "ujbl_sixplayer");
	if(get_user_weapon(id) == CSW_KNIFE)
	{
		static iszViewModel, iszWeaponModel;
		if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_sixplayer.mdl"))) set_pev_string(id, pev_viewmodel2, iszViewModel);
		if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_sixplayer.mdl"))) set_pev_string(id, pev_weaponmodel2, iszWeaponModel);
		set_pdata_float(id, m_flNextAttack, 0.75);
	}
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
	UTIL_SayText(pPlayer, "!y[!gIS-GAMING!y] %L", pPlayer, "JBE_MENU_ID_INVISIBLE_HAT_REMOVE");
	if(g_eUserRendering[pPlayer][RENDER_STATUS]) jbe_set_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	else jbe_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	if(g_eUserCostumes[pPlayer][HIDE]) jbe_set_user_costumes(pPlayer, g_eUserCostumes[pPlayer][COSTUMES]);
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
	//CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
}

jbe_default_player_model(pPlayer)
{
	switch(g_iUserTeam[pPlayer])
	{
		case 1:
		{
			jbe_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
			set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
		}
		case 2: jbe_set_user_model(pPlayer, g_szPlayerModel[GUARD]);
	}
}

jbe_default_knife_model(pPlayer)
{
	switch(g_iUserTeam[pPlayer])
	{
		case 1: jbe_set_hand_model(pPlayer);
		case 2: jbe_set_baton_model(pPlayer);
	}
}

jbe_set_hand_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_hand.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_hand.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbe_set_baton_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/v_baton.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/weapons/p_baton.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

/*jbe_set_sharpening_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_sharpening.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_sharpening.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}*/

jbe_set_screwdriver_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_screwdriver.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_screwdriver.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

/*jbe_set_balisong_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/v_balisong.mdl"))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, "models/jb_engine/shop/p_balisong.mdl"))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}*/

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

public jbe_hook_think(pPlayer)
{
	pPlayer -= TASK_HOOK_THINK;
	new Float:vecOrigin[3];
	pev(pPlayer, pev_origin, vecOrigin);
	new Float:vecVelocity[3];
	vecVelocity[0] = (g_vecHookOrigin[pPlayer][0] - vecOrigin[0]) * 3.0;
	vecVelocity[1] = (g_vecHookOrigin[pPlayer][1] - vecOrigin[1]) * 3.0;
	vecVelocity[2] = (g_vecHookOrigin[pPlayer][2] - vecOrigin[2]) * 3.0;
	
	new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
	new Float:flX = (5 * 120.0) / floatsqroot(flY);
	
	vecVelocity[0] *= flX;
	vecVelocity[1] *= flX;
	vecVelocity[2] *= flX;
	
	set_pev(pPlayer, pev_velocity, vecVelocity);
	switch(g_StatusHook[pPlayer])
	{
		case 1: CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[0], 0, 1, 1, /*g_HookSpeed[pPlayer]*/ 60 , 30, random_num(30,255), random_num(30,255), random_num(30,255), 200, _);
		case 3: CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[1], 0, 1, 1, /*g_HookSpeed[pPlayer]*/ 60, 0, 255, 255, 255, 200, _);
		case 2: CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning[2], 0, 1, 1, /*g_HookSpeed[pPlayer]*/ 60, 0, 255, 255, 255, 200, _);
	}
}
/*===== <- Остальной хлам <- =====*///}

/*===== -> Дуэль -> =====*///{
jbe_duel_start_ready(pPlayer, pTarget)
{
	g_iDuelStatus = 1;
	for(new i; i <= 4; i++) g_GodMenu[pPlayer][i] = false;
	for(new i; i <= 4; i++) g_GodMenu[pTarget][i] = false;
	for(new idd; idd <= g_iMaxPlayers; idd++)
	{
		if(g_iUserTeam[idd] == 2 )
		{
			for(new iii; iii <= 1; iii++)
			{
				drop_user_weapons(idd, iii);
			}
		}
	}
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
	
	client_cmd(0, "mp3 play sound/jb_engine/duel/ujbl_duel.mp3");
	
	for(new i; i < charsmax(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
	set_task(1.0, "jbe_duel_count_down", TASK_DUEL_COUNT_DOWN, _, _, "a", g_iDuelCountDown = 20 + 1);
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0);
	jbe_get_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	g_eUserRendering[pPlayer][RENDER_STATUS] = true;
	jbe_set_user_rendering(pTarget, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0);
	jbe_get_user_rendering(pTarget, g_eUserRendering[pTarget][RENDER_FX], g_eUserRendering[pTarget][RENDER_RED], g_eUserRendering[pTarget][RENDER_GREEN], g_eUserRendering[pTarget][RENDER_BLUE], g_eUserRendering[pTarget][RENDER_MODE], g_eUserRendering[pTarget][RENDER_AMT]);
	g_eUserRendering[pTarget][RENDER_STATUS] = true;
	CREATE_PLAYERATTACHMENT(pPlayer, _, g_pSpriteDuelRed, 3000);
	CREATE_PLAYERATTACHMENT(pTarget, _, g_pSpriteDuelBlue, 3000);
	set_task(1.0, "jbe_duel_bream_cylinder", TASK_DUEL_BEAMCYLINDER, _, _, "b");
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
			g_iModeDuel = 1;
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
			g_iModeDuel = 2;
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
			g_iModeDuel = 3;
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
			g_iModeDuel = 4;
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
			g_iModeDuel = 5;
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
			g_iModeDuel = 6;
			fm_give_item(g_iDuelUsersId[0], "weapon_knife");
			set_pev(g_iDuelUsersId[0], pev_health, 150.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			fm_give_item(g_iDuelUsersId[1], "weapon_knife");
			set_pev(g_iDuelUsersId[1], pev_health, 150.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
		}
	}
	for(new ii = 0; ii <= 1; ii++)
	{
		set_user_maxspeed(g_iDuelUsersId[ii], 220.0);
		set_user_gravity(g_iDuelUsersId[ii], 1.0);
	}
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
	//CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 5, 3, _, 255, 0, 0, 255, _);
	pev(g_iDuelUsersId[1], pev_origin, vecOrigin);
	if(pev(g_iDuelUsersId[1], pev_flags) & FL_DUCKING) vecOrigin[2] -= 15.0;
	else vecOrigin[2] -= 33.0;
	//CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 5, 3, _, 0, 0, 255, 255, _);
}

jbe_duel_ended(pPlayer)
{
	for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	g_iBitUserDuel = 0;
	g_iModeDuel = 0;
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
		emit_sound(0, CHAN_STATIC, "jb_engine/soccer/crowd.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		if(g_iChiefStatus == 1) remove_task(g_iChiefId+TASK_SHOW_SOCCER_SCORE);
	}
	g_iSoccerScore = {0, 0};
	g_bSoccerGame = false;
	g_bSoccerStatus = false;
}

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
	if(iPlayers < 2) UTIL_SayText(pPlayer, "!y[!gIS-GAMING!y] %L", pPlayer, "JBE_CHAT_ID_SOCCER_INSUFFICIENTLY_PLAYERS");
	else
	{
		for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(IsSetBit(g_iBitUserSoccer, iPlayer) || iPlayer == g_iChiefId) set_task(1.0, "jbe_soccer_score_informer", iPlayer+TASK_SHOW_SOCCER_SCORE, _, _, "b");
		emit_sound(pPlayer, CHAN_AUTO, "jb_engine/soccer/whitle_start.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		emit_sound(0, CHAN_STATIC, "jb_engine/soccer/crowd.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
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
	emit_sound(0, CHAN_STATIC, "jb_engine/soccer/crowd.wav", VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
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
			UTIL_SayText(iPlayer, "!y[!gIS-GAMING!y] %L", iPlayer, szLangPlayer[iTeam]);
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
	set_hudmessage(102, 69, 0, -1.0, 0.01, 0, 0.0, 0.9, 0.1, 0.1, -1);
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
	if(iPlayers < 2) UTIL_SayText(pPlayer, "!y[!gIS-GAMING!y] %L", pPlayer, "JBE_CHAT_ID_BOXING_INSUFFICIENTLY_PLAYERS");
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
	if(iPlayersRed < 2 || iPlayersBlue < 2) UTIL_SayText(pPlayer, "!y[!gIS-GAMING!y] %L", pPlayer, "JBE_CHAT_ID_BOXING_INSUFFICIENTLY_PLAYERS");
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
	#if defined ADDON_CREDITS
	register_native("jbe_setbit_vip", "jbe_setbit_vip", 1);
	register_native("jbe_setbit_hook", "jbe_setbit_hook", 1);
	register_native("jbe_set_user_exp_rank", "jbe_set_user_exp_rank", 1);
	#endif
	register_native("jbe_get_privileges", "jbe_get_privileges", 1);
	
	register_native("jbe_mafia_start", "jbe_mafia_start", 1);
	register_native("jbe_mafia_end", "jbe_mafia_end", 1);
	
	register_native("jbe_get_user_lvl_rank", "jbe_get_user_lvl", 1);
	
	register_native("jbe_get_status_duel", "jbe_get_status_duel", 1);
	register_native("jbe_get_mode_duel", "jbe_get_mode_duel", 1);
	
	register_native("jbe_use_drugs_model", "jbe_set_syringe_model", 1);
	register_native("jbe_return_drugs_model", "jbe_remove_syringe_model", 1);
	
	register_native("jbe_all_users_wanted", "jbe_all_users_wanted", 1);
	register_native("jbe_all_users_freeday", "jbe_all_users_freeday", 1);
	
	register_native("jbe_get_day", "jbe_get_day", 1);
	
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
	register_native("jbe_informer_offset_up", "jbe_informer_offset_up", 1);
	register_native("jbe_informer_offset_down", "jbe_informer_offset_down", 1);
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
	register_native("jbe_set_user_costumes", "jbe_set_user_costumes", 1);
	register_native("jbe_hide_user_costumes", "jbe_hide_user_costumes", 1);
	register_native("jbe_prisoners_divide_color", "jbe_prisoners_divide_color", 1);
	register_native("jbe_register_day_mode", "jbe_register_day_mode", 1);
	register_native("jbe_get_user_voice", "jbe_get_user_voice", 1);
	register_native("jbe_set_user_voice", "jbe_set_user_voice", 1);
	register_native("jbe_set_user_voice_next_round", "jbe_set_user_voice_next_round", 1);
	register_native("jbe_get_user_rendering", "_jbe_get_user_rendering", 1);
	register_native("jbe_set_user_rendering", "jbe_set_user_rendering", 1);
}
#if defined ADDON_CREDITS
public jbe_setbit_vip(id)
{
	if(IsSetBit(g_iBitUserVip, id)) return;
	else SetBit(g_iBitUserVip, id);
	return;
}
public jbe_setbit_hook(id)
{
	if(IsSetBit(g_iBitUserHook, id)) return;
	else SetBit(g_iBitUserHook, id);
	return;
}
public jbe_set_user_exp_rank(id, iExp, iType)
{
	switch(iType)
	{
		case 0: jbe_set_user_exp(id, g_iExp[id] + iExp);
		case 1: jbe_set_user_exp(id, g_iExp[id] - iExp);
		default: jbe_set_user_exp(id, g_iExp[id] + iExp);
	}
}
#endif
public jbe_all_users_wanted()
{
	if(g_szWantedNames[0] <= 0) return false;
	return true;
}
public jbe_all_users_freeday()
{
	if(g_szFreeNames[0] <= 0) return false;
	return true;
}
public jbe_get_privileges(id)
{
	if(IsSetBit(g_iBitUserGodMenu , id)) return 1;
	else if(IsSetBit(g_iBitUserGod , id)) return 2;
	else if(IsSetBit(g_iBitUserCreater , id)) return 3;
	else if(IsSetBit(g_iBitUserKnyaz , id)) return 4;
	else if(IsSetBit(g_iBitUserSuperAdmin , id)) return 5;
	else if(IsSetBit(g_iBitUserAdmin , id)) return 6;
	else if(IsSetBit(g_iBitUserVip, id)) return 7;
	else return 0;
	return 0;
}

public jbe_get_mode_duel() return g_iModeDuel;
public jbe_get_user_lvl(id) return g_iLevel[id];

public jbe_mafia_start()
{
	g_iMafiaStatus = 1;
	for(new id; id <= g_iMaxPlayers; id++)
	{
		remove_task(id + TASK_SHOW_INFORMER);
		if(jbe_get_user_team(id) == 1)
		{
			set_user_maxspeed(id, 320.0);
			set_user_gravity(id, 1.0);
			set_user_health(id, 100);
			set_user_armor(id, 100);
		}
	}
	if(is_user_alive(g_iChiefId) && g_iChiefId != 0) set_user_godmode(g_iChiefId, 1);
}

public jbe_mafia_end()
{
	g_iMafiaStatus = 0;
	if(is_user_alive(g_iChiefId) && g_iChiefId != 0) set_user_godmode(g_iChiefId, 0);
	
	for(new id; id <= g_iMaxPlayers; id++)
	{
		set_task(2.0, "jbe_main_informer", id+TASK_SHOW_INFORMER, _, _, "b");
	}
}

public jbe_get_status_duel() return g_iDuelStatus;

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
			Show_SkinMenu(pPlayer);
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
		}
		case 3:
		{
			if(IsSetBit(g_iBitUserAlive, pPlayer)) ExecuteHamB(Ham_Killed, pPlayer, pPlayer, 0);
			engclient_cmd(pPlayer, "jointeam", "6");
			if(get_pdata_int(pPlayer, m_iPlayerTeam, linux_diff_player) != 3) return 0;
			g_iPlayersNum[g_iUserTeam[pPlayer]]--;
			g_iUserTeam[pPlayer] = 3;
			g_iPlayersNum[g_iUserTeam[pPlayer]]++;
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

public jbe_informer_offset_up(pPlayer)
{
	switch(g_iInformerCord[pPlayer])
	{
		case true:
		{
			g_fMainInformerPosX[pPlayer] = 0.6;
			g_fMainInformerPosY[pPlayer] = 0.01;
			g_fFWInformerPosX[pPlayer] = 0.15;
			g_fFWInformerPosY[pPlayer] = 0.01;
		}
		case false:
		{
			g_fMainInformerPosX[pPlayer] = 0.15;
			g_fMainInformerPosY[pPlayer] = 0.01;
			g_fFWInformerPosX[pPlayer] = 0.6;
			g_fFWInformerPosY[pPlayer] = 0.01;
		}
	}
}
public jbe_informer_offset_down(pPlayer)
{
	switch(g_iInformerCord[pPlayer])
	{
		case true:
		{
			g_fMainInformerPosX[pPlayer] = 0.6;
			g_fMainInformerPosY[pPlayer] = 0.18;
			g_fFWInformerPosX[pPlayer] = 0.15;
			g_fFWInformerPosY[pPlayer] = 0.18;
		}
		case false:
		{
			g_fMainInformerPosX[pPlayer] = 0.15;
			g_fMainInformerPosY[pPlayer] = 0.18;
			g_fFWInformerPosX[pPlayer] = 0.6;
			g_fFWInformerPosY[pPlayer] = 0.18;
		}
	}
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
	formatex(g_szFreeNames, charsmax(g_szFreeNames), "%s^n%s", g_szFreeNames, szName);
	g_iFreeLang = 1;
	if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, pPlayer))
	{
		ClearBit(g_iBitUserSoccer, pPlayer);
		jbe_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
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
	set_pev(pPlayer, pev_skin, 5);
	set_rendering(pPlayer, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 4);
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
		format(szName, charsmax(szName), "^n%s", szName);
		replace(g_szFreeNames, charsmax(g_szFreeNames), szName, "");
		g_iFreeLang = (g_szFreeNames[0] != 0);
	}
	if(task_exists(pPlayer+TASK_FREE_DAY_ENDED)) remove_task(pPlayer+TASK_FREE_DAY_ENDED);
	if(IsSetBit(g_iBitUserAlive, pPlayer))
	{
		if(pPlayer == g_AthrID) set_pev(pPlayer, pev_skin, 7);
		else if(pPlayer == g_SixPlID) set_pev(pPlayer, pev_skin, 8);
		else set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
	}
	jbe_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	return 1;
}

public jbe_free_day_start()
{
	if(g_iDayMode != 1) return 0;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		
		//client_cmd(iPlayer, "mp3 play sound/jb_engine/freeday/freeday_start.mp3");
		
		if(g_iUserTeam[iPlayer] == 1 && IsSetBit(g_iBitUserAlive, iPlayer) && IsNotSetBit(g_iBitUserWanted, iPlayer))
		{
			if(IsSetBit(g_iBitUserFree, iPlayer)) remove_task(iPlayer+TASK_FREE_DAY_ENDED);
			else
			{
				SetBit(g_iBitUserFree, iPlayer);
				if(g_bSoccerStatus && IsSetBit(g_iBitUserSoccer, iPlayer))
				{
					ClearBit(g_iBitUserSoccer, iPlayer);
					jbe_set_user_model(iPlayer, g_szPlayerModel[PRISONER]);
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
				set_pev(iPlayer, pev_skin, 5);
			}
		}
	}
	g_szFreeNames = "";
	g_iFreeLang = 0;
	jbe_open_doors();
	jbe_set_day_mode(2);
	g_iDayModeTimer = g_iAllCvars[FREE_DAY_ALL] + 1;
	set_task(1.0, "jbe_free_day_ended_task", TASK_FREE_DAY_ENDED, _, _, "a", g_iDayModeTimer);
	return 1;
}
public jbe_free_day_ended_task()
{
	if(--g_iDayModeTimer) formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "[%i]", g_iDayModeTimer);
	else jbe_free_day_ended();
}
public jbe_free_day_ended()
{
	if(g_iDayMode != 2) return 0;
	g_szDayModeTimer = "";
	if(task_exists(TASK_FREE_DAY_ENDED)) remove_task(TASK_FREE_DAY_ENDED);
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		
		//client_cmd(iPlayer, "mp3 play sound/jb_engine/freeday/freeday_end.mp3");
		
		if(IsSetBit(g_iBitUserFree, iPlayer))
		{
			ClearBit(g_iBitUserFree, iPlayer);
			if(iPlayer == g_AthrID) set_pev(iPlayer, pev_skin, 7);
			else if(iPlayer == g_SixPlID) set_pev(iPlayer, pev_skin, 8);
			else set_pev(iPlayer, pev_skin, g_iUserSkin[iPlayer]);
		}
	}
	jbe_set_day_mode(1);
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
	formatex(g_szWantedNames, charsmax(g_szWantedNames), "%s^n%s", g_szWantedNames, szName);
	g_iWantedLang = 1;
	if(IsSetBit(g_iBitUserFree, pPlayer))
	{
		ClearBit(g_iBitUserFree, pPlayer);
		if(g_szFreeNames[0] != 0)
		{
			format(szName, charsmax(szName), "^n%s", szName);
			replace(g_szFreeNames, charsmax(g_szFreeNames), szName, "");
			g_iFreeLang = (g_szFreeNames[0] != 0);
		}
		if(g_iDayMode == 1 && task_exists(pPlayer+TASK_FREE_DAY_ENDED)) remove_task(pPlayer+TASK_FREE_DAY_ENDED);
	}
	if(IsSetBit(g_iBitUserSoccer, pPlayer))
	{
		ClearBit(g_iBitUserSoccer, pPlayer);
		jbe_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
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
	if(IsSetBit(g_iBitUserBoxing, pPlayer))
	{
		ClearBit(g_iBitUserBoxing, pPlayer);
		jbe_set_hand_model(pPlayer);
		UTIL_WeaponAnimation(pPlayer, 3);
		set_pev(pPlayer, pev_health, 100.0);
		set_pdata_int(pPlayer, m_bloodColor, 247);
	}
	set_pev(pPlayer, pev_skin, 6);
	set_rendering(pPlayer, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 4);
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
		format(szName, charsmax(szName), "^n%s", szName);
		replace(g_szWantedNames, charsmax(g_szWantedNames), szName, "");
		g_iWantedLang = (g_szWantedNames[0] != 0);
	}
	if(IsSetBit(g_iBitUserAlive, pPlayer))
	{
		if(g_iDayMode == 2)
		{
			SetBit(g_iBitUserFree, pPlayer);
			set_pev(pPlayer, pev_skin, 5);
		}
		else
		{
			if(pPlayer == g_AthrID) set_pev(pPlayer, pev_skin, 7);
			else if(pPlayer == g_SixPlID) set_pev(pPlayer, pev_skin, 8);
			else set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
		}
	}
	jbe_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	return 1;
}

public jbe_is_user_chief(pPlayer) return (pPlayer == g_iChiefId);
public jbe_set_user_chief(pPlayer)
{
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
	jbe_set_user_model(pPlayer, g_szPlayerModel[CHIEF]);
	emit_sound(0, CHAN_AUTO, "jb_engine/ujbl_new/chief_came.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	CREATE_BEAMFOLLOW(pPlayer, g_pSpriteLgtning[0], 100, 3, random_num(100, 255), random_num(100, 255), random_num(100, 255), 1000);
	UTIL_SayText(pPlayer, "!y[!gIS-GAMING!y] Чтобы выключить трайл: !gПостойте на месте до 1й минуты !yили !gчерез меню саймона.");
	set_user_health(pPlayer, get_user_health(pPlayer) + 150);
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

public jbe_set_user_costumes(pPlayer, iCostumes)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return 0;
	if(iCostumes)
	{
		if(!g_eUserCostumes[pPlayer][ENTITY])
		{
			static iszFuncWall = 0;
			if(iszFuncWall || (iszFuncWall = engfunc(EngFunc_AllocString, "func_wall"))) g_eUserCostumes[pPlayer][ENTITY] = engfunc(EngFunc_CreateNamedEntity, iszFuncWall);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_movetype, MOVETYPE_FOLLOW);
			engfunc(EngFunc_SetModel, g_eUserCostumes[pPlayer][ENTITY], "models/jb_engine/costumes/ujbl_costumes.mdl");
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_aiment, pPlayer);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_body, iCostumes - 1);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_sequence, 0);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_animtime, get_gametime());
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_framerate, 1.0);
			set_rendering(g_eUserCostumes[pPlayer][ENTITY], kRenderFxGlowShell, random_num(0,255), random_num(0,255), random_num(0,255), kRenderNormal, 4);
		}
		else set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_body, iCostumes - 1);			
		g_eUserCostumes[pPlayer][HIDE] = false;
		g_eUserCostumes[pPlayer][COSTUMES] = iCostumes;
		return 1;
	}
	else if(g_eUserCostumes[pPlayer][COSTUMES])
	{
		if(g_eUserCostumes[pPlayer][ENTITY]) engfunc(EngFunc_RemoveEntity, g_eUserCostumes[pPlayer][ENTITY]);
		g_eUserCostumes[pPlayer][ENTITY] = 0;
		g_eUserCostumes[pPlayer][HIDE] = false;
		g_eUserCostumes[pPlayer][COSTUMES] = 0;
		return 1;
	}
	return 0;
}

public jbe_hide_user_costumes(pPlayer)
{
	if(g_eUserCostumes[pPlayer][ENTITY])
	{
		engfunc(EngFunc_RemoveEntity, g_eUserCostumes[pPlayer][ENTITY]);
		g_eUserCostumes[pPlayer][ENTITY] = 0;
		g_eUserCostumes[pPlayer][HIDE] = true;
		return 1;
	}
	return 0;
}

public jbe_prisoners_divide_color(iTeam)
{
	if(g_iDayMode != 1 || g_iAlivePlayersNum[1] < 2 || iTeam < 2 || iTeam > 4) return 0;
	new const szLangPlayer[][] = {"JBE_HUD_ID_YOU_TEAM_ORANGE", "JBE_HUD_ID_YOU_TEAM_GRAY", "JBE_HUD_ID_YOU_TEAM_YELLOW", "JBE_HUD_ID_YOU_TEAM_BLUE"};
	for(new iPlayer = 1, iColor; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(g_iUserTeam[iPlayer] != 1 || IsNotSetBit(g_iBitUserAlive, iPlayer) || IsSetBit(g_iBitUserFree, iPlayer)
		|| IsSetBit(g_iBitUserWanted, iPlayer) || IsSetBit(g_iBitUserSoccer, iPlayer) || IsSetBit(g_iBitUserBoxing, iPlayer)
		|| IsSetBit(g_iBitUserDuel, iPlayer)) continue;
		UTIL_SayText(iPlayer, "!y[!gIS-GAMING!y] %L", iPlayer, szLangPlayer[iColor]);
		set_pev(iPlayer, pev_skin, iColor);
		if(++iColor >= iTeam) iColor = 0;
	}
	return 1;
}

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

stock long_jump(long_jump) 
{
	set_speed( long_jump, 1000.0, 3 );
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

stock CREATE_KILLBEAM(pEntity)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pEntity);
	message_end();
}

stock ham_strip_weapon(id,weapon[])
{
	if(!equal(weapon,"weapon_",7)) return 0;
 
	new wId = get_weaponid(weapon);
	if(!wId) return 0;

	new wEnt;
	while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) 
	{
		
	}
	if(!wEnt) return 0;

	if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);

	if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) return 0;
	ExecuteHamB(Ham_Item_Kill,wEnt);

	set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId));
	 
	return 1;
}
/*===== <- Стоки <- =====*///}