#include 		amxmodx			// Главный модуль

#include 		fakemeta		// Форварды, engfunc и другое
#include 		fun				// Бесшумные шаги и бессмертие
#include 		engine			// Работа с Enity и другое
#include 		hamsandwich		// События HamSandWich
#include 		sqlx			// Работа с базами данных SqlX
#include		cstrike

//native give_hook(id);
//native reset_hook(id);
//native hook_mod_on(id);
//native hook_mod_off(id);

// Оформление кода
#pragma semicolon 1

#define VERSION "10.1" // Версия сборки
#define LAST_UPD "17/09/2020"

/*-> Settings FOR DEVELOPERS ->*/

//#define OLD_WEAPON_SYSTEM							// Старое меню оружия, freedo.m like this. 
#define SPEED_HOOK 120.0							// Скорость хука (Указывать обязательно не целым числом!!!)
#define BLOCK_DONATE_GLOBALGAMES					// Заблокировать привилегии для всех, кроме ведущего, во время глобальных игр
#define REGAME_GAMEMODE								// Защита от повторных игр в выходные
#define INFORMATION_MODE							// Ссылка на мою страницу в информации
#define SAVE_BLOCK_IP_ON_MAP						// Блокировка входа за КТ на карту
#define SKINS_DATA									// Устанавливаем модель игроку по файлу

//#define DEBUG										// Режим для AlexandrFiner`а
//#define DEBUG_LEVEL								// Оффаем выключение мода из-за ошибок
//#define INFO_MOTD									// Если у вас есть мотд окно (шаблон есть в арихве), то можете использовать motd

// Главное: Привязка //

// Главное: Привязка и последнее обновление //

/*[Не изменять]*/
#define IsValidPlayer(%0) (%0 && %0 <= g_iMaxPlayers)			// Проверка на валидность игрока
const IUSER1_DOOR_KEY 		= 376027;								// Двери
const IUSER1_BUYZONE_KEY 	= 140658;								// Бай зона
const IUSER1_FROSTNADE_KEY 	= 235876;								// Для гранаты заморозки

/*[Работа с битами]*/
#define setBit(%0,%1)				((%0)	|=	(1 << (%1))  )
#define clearBit(%0,%1)				((%0)	&=	~(1 << (%1)) )
#define isSetBit(%0,%1)				((%0)	&	(1 << (%1))  )
#define invertBit(%0,%1)			((%0)	^=	(1 << (%1))  )
#define isNotSetBit(%0,%1)			(~(%0)	&	(1 << (%1))  )

/* > Битсуммы, переменные и массивы для работы с игроками > *///{

enum {
    SCOREATTRIB_ARG_PLAYERID = 1,
    SCOREATTRIB_ARG_FLAGS
};

enum (<<=1) {
    SCOREATTRIB_FLAG_NONE = 0,
    SCOREATTRIB_FLAG_DEAD = 1,
    SCOREATTRIB_FLAG_BOMB,
    SCOREATTRIB_FLAG_VIP
};

/*[TASK]*/
enum _:(+= 100)
{
	TASK_GIVE_EXP = 250000,
	TASK_ROUND_END,
	TASK_ROUND_END_FADE,
	TASK_CHANGE_MODEL,
	TASK_SHOW_INFORMER,
	TASK_SHOW_DEAD_INFORMER,
	TASK_FREE_DAY_ENDED,
	TASK_CHIEF_CHOICE_TIME,
	TASK_COUNT_DOWN_TIMER,
	TASK_VOTE_DAY_MODE_TIMER,
	TASK_RESTART_GAME_TIMER,
	TASK_DAY_MODE_TIMER,
	TASK_SHOW_SOCCER_SCORE,
	TASK_REMOVE_SYRINGE,
	TASK_REMOVE_ANIMATE,
	TASK_FROSTNADE_DEFROST,
	TASK_INVISIBLE_HAT,
	TASK_DUEL_COUNT_DOWN,
	TASK_SHOW_MONEY_BET,
	TASK_DUEL_BEAMCYLINDER,
	TASK_DUEL_TIMER_ATTACK,
	TASK_HOOK_THINK,
	TASK_SHOW_ROLE_GG,
	TASK_DAY_VOTE_MAFIA,
	TASK_PLAYER_BURN,
	TASK_TRAIL,
	TASK_STEAL_MONEY,
	TASK_FLY_PLAYER
}

/*[OFFSET]*/
const linux_diff_weapon         = 4;
const linux_diff_animating      = 4;
const linux_diff_player         = 5;
const ACT_RANGE_ATTACK1         = 28;
const m_flFrameRate             = 36;
const m_flGroundSpeed           = 37;
const m_flLastEventCheck        = 38;
const m_fSequenceFinished       = 39;
const m_fSequenceLoops          = 40;
const m_pPlayer                 = 41;
const m_flNextSecondaryAttack   = 47;
const m_iClip                   = 51;
const m_Activity                = 73;
const m_IdealActivity           = 74;
const m_LastHitGroup            = 75;
const m_flNextAttack            = 83;
const m_bloodColor              = 89;
const m_iPlayerTeam             = 114;
const m_fHasPrimary             = 116;
const m_bHasChangeTeamThisRound = 125;
const m_flLastAttackTime        = 220;
const m_afButtonPressed         = 246;
const m_iFov					= 363;
const m_iSpawnCount             = 365;
const m_pActiveItem             = 373;
const m_flNextDecalTime         = 486;
const g_szModelIndexPlayer      = 491;

/*[INDEX MsgID]*/

	const MsgId_VoiceMask		= 64;
	const MsgId_ReqState		= 65;
	const MsgId_CurWeapon 		= 66;
	const MsgId_Geiger			= 67;
	const MsgId_Flashlight		= 68;
	const MsgId_FlashBat		= 69;
	const MsgId_Health			= 70;
	const MsgId_Damage			= 71;
	const MsgId_Battery			= 72;
	const MsgId_Train			= 73;
	const MsgId_HudTextPro		= 74;
	const MsgId_HudText			= 75;
	const MsgId_SayText			= 76;
	const MsgId_TextMsg			= 77;
	const MsgId_WeaponList		= 78;
	const MsgId_ResetHUD		= 79;
	const MsgId_InitHUD			= 80;
	const MsgId_ViewMode		= 81;
	const MsgId_GameTitle		= 82;
	const MsgId_DeathMsg		= 83;
	const MsgId_ScoreAttrib		= 84;
	const MsgId_ScoreInfo		= 85;
	const MsgId_TeamInfo		= 86;
	const MsgId_TeamScore		= 87;
	const MsgId_GameMode		= 88;
	const MsgId_MOTD			= 89;
	const MsgId_ServerName		= 90;
	const MsgId_AmmoPickup		= 91;
	const MsgId_WeapPickup		= 92;
	const MsgId_ItemPickup		= 93;
	const MsgId_HideWeapon		= 94;
	const MsgId_SetFOV			= 95;
	const MsgId_ShowMenu		= 96;
	const MsgId_ScreenShake		= 97;
	const MsgId_ScreenFade		= 98;
	const MsgId_AmmoX			= 99;
	const MsgId_SendAudio		= 100;
	const MsgId_RoundTime		= 101;
	const MsgId_Money			= 102;
	const MsgId_ArmorType		= 103;
	const MsgId_BlinkAcct		= 104;
	const MsgId_StatusValue		= 105;
	const MsgId_StatusText		= 106;
	const MsgId_StatusIcon		= 107;
	const MsgId_BarTime			= 108;
	const MsgId_ReloadSound		= 109;
	const MsgId_Crosshair		= 110;
	const MsgId_NVGToggle		= 111;
	const MsgId_Radar			= 112;
	const MsgId_Spectator		= 113;
	const MsgId_VGUIMenu		= 114;
	const MsgId_TutorText		= 115;
	const MsgId_TutorLine		= 116;
	const MsgId_TutorState		= 117;
	const MsgId_TutorClose		= 118;
	const MsgId_AllowSpec		= 119;
	const MsgId_BombDrop		= 120;
	const MsgId_BombPickup		= 121;
	const MsgId_ClCorpse		= 122;
	const MsgId_HostagePos		= 123;
	const MsgId_HostageK		= 124;
	const MsgId_HLTV			= 125;
	const MsgId_SpecHealth		= 126;
	const MsgId_ForceCam		= 127;
	const MsgId_ADStop			= 128;
	const MsgId_ReceiveW		= 129;
	const MsgId_CZCareer		= 130;
	const MsgId_CZCareerHUD		= 131;
	const MsgId_ShadowIdx		= 132;
	const MsgId_TaskTime		= 133;
	const MsgId_Scenario		= 134;
	const MsgId_BotVoice		= 135;
	const MsgId_BuyClose		= 136;
	const MsgId_SpecHealth2		= 137;
	const MsgId_BarTime2		= 138;
	const MsgId_ItemStatus		= 139;
	const MsgId_Location		= 140;
	const MsgId_BotProgress		= 141;
	const MsgId_Brass			= 142;
	const MsgId_Fog				= 143;
	const MsgId_ShowTimer		= 144;
	const MsgId_HudTextArgs		= 145;

/*[CVARS]*/

// Общие квары
enum _:CVARS_ALL
{
	MONEY_STEAL,
	MONEY_STEAL_TIME,
	SHOOT_BUTTON,
	INFORMER_COLOR,
	FREE_DAY_ID,
	FREE_DAY_ALL,
	TEAM_BALANCE,
	DAY_MODE_VOTE_TIME,
	RESTART_GAME_TIME,
	WANTED_GRENADE_DAMAGE,
	RIOT_START_MONEY,
	KILLED_GUARD_MONEY,
	KILLED_CHIEF_MONEY,
	ROUND_FREE_MONEY,
	LAST_PRISONER_MONEY,
	RESPAWN_PLAYER_NUM_T,
	RESPAWN_PLAYER_NUM_CT,
	VIP_RESPAWN_NUM,
	VIP_MONEY_NUM,
	VIP_MONEY_ROUND,
	VIP_HP_AP_ROUND,
	VIP_VOICE_ROUND,
	VIP_FREE_DAY_ROUND,
	VIP_INVISIBLE,
	VIP_GRANATE,
	VIP_SPEED_GRAVITY,
	VIP_DISCOUNT_SHOP,
	ULTRA_VIP_RESPAWN_NUM,
	ULTRA_VIP_RESPAWN_PLAYER_NUM,
	ULTRA_VIP_MONEY_NUM,
	ULTRA_VIP_MONEY_ROUND,
	ULTRA_VIP_DAMAGE_ROUND,
	ULTRA_VIP_BHOP_ROUND,
	ULTRA_VIP_GLOW_ROUND,
	ULTRA_VIP_CLOSE_CASE_ROUND,
	ULTRA_VIP_DOUBLE_JUMP_ROUND,
	ADMIN_MONEY_NUM,
	ADMIN_MONEY_ROUND,
	ADMIN_FOOTSTEPS_ROUND,
	ADMIN_GOD_ROUND,
	ADMIN_ULTRA_BHOP,
	PREDATOR_HEAL_NUM,
	PREDATOR_INVISIBLE_ROUND,
	PREDATOR_WEAPON_ROUND,
	PREDATOR_THEFT_ROUND,
	BOSS_HOOK,
	BOSS_DISCOUNT_SHOP,
	ANIME_HP_AP_ROUND,
	ANIME_DEAGLE_ROUND,
	ANIME_NOJ_ROUND,
	ANIME_MODEL_ROUND
}
new g_iAllCvars[CVARS_ALL];

// Квары магазина
enum _:CVARS_SHOP
{
	KATANA,
	MACHETE,
	CHAINSAW,
	FLASHBANG,
	KOKAIN,
	STIMULATOR,
	FROSTNADE,
	FROSTNADE_LIMIT,
	ARMOR,
	HEGRENADE,
	HING_JUMP,
	FAST_RUN,
	DOUBLE_JUMP,
	RANDOM_GLOW,
	AUTO_BHOP,
	DOUBLE_DAMAGE,
	LOW_GRAVITY,
	CLOSE_CASE,
	FREE_DAY_SHOP,
	LOTTERY_TICKET,
	LOTTERY_LIMIT,
	LOTTERY_CHANCE,
	LOTTERY_FACTOR,
	PRANK_PRISONER,
	PRANK_LIMIT,
	VIP_GUARD_MODEL,
	VIP_INVISIBLE_HAT,
	VIP_LATCHKEY,
	VIP_DEAGLE,
	STIMULATOR_GR,
	RANDOM_GLOW_GR,
	LOTTERY_TICKET_GR,
	KOKAIN_GR,
	DOUBLE_JUMP_GR,
	FAST_RUN_GR,
	LOW_GRAVITY_GR,
	GOD_CHIEF,
	INVISIBLE_CHIEF,
	FOOTSTEPS_CHIEF,
	ORDER_ROUNDSOUND
}
new g_iShopCvars[CVARS_SHOP];

// Для инофрмера
new g_iColorInformer[3];

// Квары LVL системы
enum _:CVARS_LVL
{
	TIME_EXP,
	EXP_NEED,
	MONEY_BONUS,
	HEALTH_BONUS,
	PLAYERS_NEED,
	MAX_LEVEL_TIME
}
new g_iLevelCvars[CVARS_LVL];

/*[HUD MSG]*/
// Мессаджи
new g_iSyncMainInformer; 
new g_iSyncMainDeadInformer;
new g_iSyncSoccerScore; 
new g_iSyncStatusText;
new g_iSyncHudInfo; 
new g_iSyncDuelInformer; 
new g_iSyncGlobalGame;

/*[MODELS/SPRITE/SOUND and other]*/

// Модели
new g_pModelGlass;
new g_pModelDirt;

// Спрайты
new g_pSpriteWave; 
new g_pSpriteBeam; 
new g_pSpriteBall;
new g_pSpriteDuelRed;
new g_pSpriteDuelBlue;
new g_pSpriteLgtning;
//new g_pSpriteRicho2;
new g_pSpriteSmoke;
new g_pSpriteFlash;

/*[DOORS]*/

// Работа с дверями
new bool:g_bDoorStatus;
new Array:g_aDoorList; 
new g_iDoorListSize; 
new Trie:g_tButtonList;

/*[FakeMeta And HamSandWich]*/

// Удаление BuyZone, установка плента и другое
new Trie:g_tRemoveEntities;

// События HamSandWich
static const g_szHamHookEntityBlock[][] =
{
	"func_vehicle", 		// Управляемая машина
	"func_tracktrain", 		// Управляемый поезд
	"func_tank", 			// Управляемая пушка
	"game_player_hurt", 	// При активации наносит игроку повреждения
	"func_recharge",		// Увеличение запаса бронижелета
	"func_healthcharger", 	// Увеличение процентов здоровья
	"game_player_equip", 	// Выдаёт оружие
	"player_weaponstrip", 	// Забирает всё оружие
	"func_button", 			// Кнопка
	"trigger_hurt",			// Наносит игроку повреждения
	"trigger_gravity", 		// Устанавливает игроку силу гравитации
	"armoury_entity", 		// Объект лежащий на карте, оружия, броня или гранаты
	"weaponbox", 			// Оружие выброшенное игроком
	"weapon_shield" 		// Щит
};
new HamHook:g_iHamHookForwards[14];
new HamHook:g_iHamHookForwardsDjihad;

// Другое FakeMeta
new g_iFakeMetaKeyValue; 
new g_iFakeMetaSpawn;

// Другое HamSandWich
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

/* -> Остальное -> */
new g_iSpeedFly[33],  bool:g_iModeFly[33], g_bHookStatus, g_iTimeFire[MAX_PLAYERS + 1];

/*[Переменные, массивы и дургое]*/

// Конец раунда
new g_bRoundEnd = false;
enum _:DATA_ROUND_SOUND
{
	FILE_NAME[64],
	TRACK_NAME[64]
}
new Array:g_aDataRoundSound;
new g_iRoundSoundSize;
new iRoundSound = -1;

// Музыка для ACP и глобалок
enum _:DATA_MUSIC
{
	FILE_DIR[64],
	MUSIC_NAME[64]
}
new Array:g_aDataMusicList;
new g_iListMusicSize;

// Начало игры (рестарт)
new bool:g_bRestartGame = true;

// Магазин
new g_iFrostNade[MAX_PLAYERS + 1];
new g_iLotteryPlayer[MAX_PLAYERS + 1]; 
new g_iPrank;

// Работа с костюмами

//# Загрузка модели

enum _:DATA_COSTUMES_PRECACHE
{
	MODEL_NAME[32],
	SUB_MODEL[4],
	NAME_COSTUME[64],
	FLAG_COSTUME[2],
	WARNING_MSG[32]
}
enum _:DATA_COSTUMES
{
	COSTUMES,
	ENTITY,
	bool:HIDE
}
new Array:g_aCostumesList;
new g_iCostumesListSize;
new g_eUserCostumes[MAX_PLAYERS + 1][DATA_COSTUMES];

// Работа с личными моделями
#if defined SKINS_DATA
enum _:DATA_MODEL_SKIN
{
	TYPE_AUTH[4],
	USER_INFO[64],
	MODEL_USER[64],
	DAY_LEFT[16]
}
new Array:g_aModelUserData;
new g_iModelUserData;
new g_iPlayerSkin[MAX_PLAYERS + 1][64];

new g_iBitUserCostumModel;
#endif

// Свечение
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

// Построение меню из игроков
new g_iUserID[MAX_PLAYERS + 1][MAX_PLAYERS];			// Игроки в меню
new g_iMenuPosition[MAX_PLAYERS + 1]; 					// Страница в меню
new g_iMenuTarget[MAX_PLAYERS + 1]; 					// Игрок, которого выбрали
new g_iMenuType[MAX_PLAYERS + 1];						// Тип задачи
new g_iMenuArg[MAX_PLAYERS + 1];						// Значения для некоторых меню
new Float:g_fMenuArg[MAX_PLAYERS + 1];					// Значения для некоторых меню (float)

/*[GAME MODES]*/

// День недели и день по счету
new g_iDay, g_iDayWeek;
static const g_szDaysWeek[][] =
{
	"JBM_HUD_DAY_WEEK_0",
	"JBM_HUD_DAY_WEEK_1",
	"JBM_HUD_DAY_WEEK_2",
	"JBM_HUD_DAY_WEEK_3",
	"JBM_HUD_DAY_WEEK_4",
	"JBM_HUD_DAY_WEEK_5",
	"JBM_HUD_DAY_WEEK_6",
	"JBM_HUD_DAY_WEEK_7"
};

// Режим игры
enum _:DATA_DAY_MODE
{
	LANG_MODE[32],
	MODE_BLOCKED,
	VOTES_NUM,
	MODE_TIMER,
	MODE_BLOCK_DAYS
}
new Array:g_aDataDayMode; 
new g_iDayModeListSize;
new g_iDayModeVoteTime;
enum _:DAY_MODE_STATUS { DAY_MODE_START, DAY_MODE_END }
new g_iHookDayMode[DAY_MODE_STATUS];
new g_iReturnDayMode;

enum _:DAY_MODE_TYPE { DAYMODE_STANDART = 1, DAYMODE_FREE, DAYMODE_GAMES };
new g_iDayMode;
new g_szDayMode[32] = "JBM_HUD_GAME_MODE_0";
new g_iDayModeTimer;
new g_szDayModeTimer[8] = ""; 
new g_iGameMode = -1;
#if defined REGAME_GAMEMODE
new g_iLastDayMode;
#endif
new g_iBitUserVoteDayMode; 
new g_szRestartText[1024];

/*[Работа с игроком]*/

// Самое основное		****
new g_iMaxPlayers;				// Кол-во слотов
new g_iPlayersNum[4]; 			// Количество игроков за ту или иную команду (используется с запасом под подсчет зрителей)
new g_iAlivePlayersNum[4];		// Количество живых игроков за ту или иную комманду (используется с запасом под подсчет зрителей)

// Модель игроков
new g_szUserModel[MAX_PLAYERS + 1][32];

// Тоже очень важная дичь
new g_iUserTeam[MAX_PLAYERS + 1]; 					// Даем моду понять, в какой сейчас команде находится игрок
new g_iUserMoney[MAX_PLAYERS + 1]; 					// Получаем количество денег, сделано для бессконечного количества денег (ранее был лимит 16000$).
new g_iUserDiscount[MAX_PLAYERS + 1];				// Скидка в магазине для игрока (персональная для каждого)
new Float:g_vecHookOrigin[MAX_PLAYERS + 1][3];		// Получаем данные о том, куда сейчас смотрит игрок
new Float:g_fUserSpeed[MAX_PLAYERS + 1];					// Скорость игрока

// Начальник
new g_iChiefId; 
new g_iChiefIdOld; 
new g_iChiefChoiceTime; 
new g_szChiefName[32]; 
new g_iChiefStatus;
static const g_szChiefStatus[][] =
{
	"JBM_HUD_CHIEF_NOT",
	"JBM_HUD_CHIEF_ALIVE",
	"JBM_HUD_CHIEF_DEAD",
	"JBM_HUD_CHIEF_DISCONNECT"
};

// Розыск
new g_iBitUserWanted; 
new g_szWantedNames[192];
new g_iWantedCount;

// Свободный зек
new g_iBitUserFree;
new g_iBitUserFreeNextRound;
new g_iFreeLang;
new g_iFreeTimeID[MAX_PLAYERS + 1];
new g_iFreeCount;

// Последний зек
new g_iLastPnId;

// Дуэль
new g_iDuelStatus; 
new g_iDuelType;
new g_iBitUserDuel;
new g_iDuelUsersId[2];
new g_iDuelNames[2][32]; 
new g_iDuelCountDown;
new g_iDuelTimerAttack;
new g_iDuelTimeToAttack;
new g_iDuelPrize;
new g_iDuelPrizeId;
new g_iDuelTypeFair;
static const g_szDuelLang[][] =
{
	"",
	"JBM_ALL_HUD_DUEL_DEAGLE",
	"JBM_ALL_HUD_DUEL_M3",
	"JBM_ALL_HUD_DUEL_HEGRENADE",
	"JBM_ALL_HUD_DUEL_M249",
	"JBM_ALL_HUD_DUEL_AWP",
	"JBM_ALL_HUD_DUEL_KNIFE"
};
static const g_szDuelPrizeLang[][] =
{
	"JBM_DUEL_PRIZE_NONE",
	"JBM_DUEL_PRIZE_FREEDAY",
	"JBM_DUEL_PRIZE_VOICE"
};
new g_iTimeAttack[] = { 5, 10 };

// Ставки
new g_iUserBet[MAX_PLAYERS + 1];
new g_iUserBetId[MAX_PLAYERS + 1];
new g_iBitUserBet;
new g_iCountMoney[2];

// Trail
enum _:TRAIL_DATA
{
	SPRITE,
	COLOR,
	BRIGHTNESS,
	WIDTH
};
new aDataTrail[MAX_PLAYERS + 1][TRAIL_DATA];
new g_iTimer[MAX_PLAYERS + 1];
new g_iPlayerPosition[MAX_PLAYERS + 1][3];

new g_iSpriteNum;
new g_iSpriteText[99][32]; 
new g_iSpriteFile[99];

new g_iColorNum;
new g_iColorText[99][32];
new g_iColorPrecache[99][4];

new g_iBrightness[] = { 100, 90, 80, 70, 60, 50, 40, 30, 20, 10 };
new g_iWidth[] =  {	100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 150, 130, 110};

// Блокировка входа за охрану
#if defined SAVE_BLOCK_IP_ON_MAP
new Trie:g_iBlockListOnMap;
#endif

/*[Битсуммы]*/

// Общее
new g_iBitUserConnected;					// Подключенный игрок 
new g_iBitUserAlive; 						// Живой
new g_iBitUserVoice;						// Имеет голос за зеков на рнд
new g_iBitUserVoiceNextRound;				// Получит голос за зеков на рнд в следующем раунде
new g_iBitUserModel; 						// фикс модели
new g_iBitBlockMenu;						// Блокировка меню
new g_iBitKilledUsers[MAX_PLAYERS + 1];	// Бит убитого игрока охранной (личный)
new g_iBitUserRoundSound;					// Музыка в конце раунда (вкл/выкл)
new g_iBitUserRoundEndEffects; 			// Эффекты в конце раунда
new g_iBitUserBlockedGuard; 				// Блокировка входа за охрану
new g_iBitSoundMenu;						// Звуки кнопок в меню

// Привилегии
new g_iBitUserBuyVoice; 					// Голос навсегда
new g_iBitUserVip;						// Вип
new g_iBitUserUltraVip; 					// Супер Вип
new g_iBitUserAdmin; 						// Админ
new g_iBitUserPredator; 					// Хищник
new g_iBitUserBoss;						// Босс
new g_iBitUserHook;						// Паутинка
new g_iBitUserHookTime;					// Паутинка, которую выдал босс
new g_iBitUserAC;
new g_iBitUserTrail;						// Траил за игроком
new g_iBitUserAnime;						// Аниме

// Магазин
new g_iBitKatana;							// Катана
new g_iBitMachete;						// Мачете
new g_iBitChainsaw;						// Бензопила
new g_iBitPerc;                         // Перчатки
new g_iBitWeaponStatus; 					// Имеется ли у игрока какое-то оружие
new g_iBitKokain;							// Кокаин
new g_iBitFrostNade;						// Граната заморозка
new g_iBitUserFrozen; 					// Проверка, заморожен ли игрок
new g_iBitHingJump; 						// Высокий прыжок
new g_iBitDoubleJump;						// Двойной прыжок
new g_iBitRandomGlow;						// Случайное свечение
new g_iBitAutoBhop;						// Автораспрыжка
new g_iBitBoostBhop;						// Быстрый распрыг (только для привилегии)
new g_iBitDoubleDamage;					// Двойной урон
new g_iBitGuardModel;						// Модель охраны
new g_iBitInvisibleHat;					// Шапка-невидимка
new g_iBitLatchkey;						// Отмычка

/*[Игры для начальника]*/

// Мини игры
new g_iLastUse[MAX_PLAYERS + 1];			// Когда последний раз использовали "Выдать зекам диглы" и "Включить музыку" в битве за джихад
new g_iCountDown; 						// Обратный отсчет
new bool:g_bGlobalGame;					// Проверка, идет ли сейчас глобальная игра

new g_iSoccerBall;						// Мяч
new Float:g_flSoccerBallOrigin[3];		// Направление мяча
new bool:g_bSoccerBallTouch; 				// Кто коснулся мяча
new bool:g_bSoccerBallTrail;				// Линия за мячом
new g_iSoccerBallSpeed = 1000; 			// Скорость мяча
new bool:g_bSoccerStatus;					// Включен ли режим футбола
new bool:g_bSoccerGame;					// Идет ли матч
new g_iSoccerScore[2];					// Счет 
new g_iBitUserSoccer;						// Играет ли игрок в футбол
new g_iSoccerBallOwner; 					// У кого сейчас мяч
new g_iSoccerKickOwner; 					// Кто пнул мяч
new g_iSoccerUserTeam[MAX_PLAYERS + 1];	// Проверка, в какой команде игрок

new g_bBoxingStatus;						// Включен ли бокс
new g_iFriendlyFire;
new g_iMoreDamageHE;						// Статус урона
new g_iDamageHe[] = { 1, 3, 6, 0 };
static const g_szDamageHe[][]=
{
	"JBM_BOX_DAMAGE_STANDART",
	"JBM_BOX_DAMAGE_X3",
	"JBM_BOX_DAMAGE_X6",
	"JBM_BOX_DAMAGE_NONE"
};
static const g_szMiniGame[2][]=
{
	"JBM_MINI_GAME_NONE",
	"JBM_MINI_GAME_BOX"
};


/* [Глобальные игры] */

// Глобальные игры
// Мафия
#define NONE 		0
#define STANDART 	1
#define MAFIA 		2
#define COMISAR 	3
#define DOCTOR 		4
#define SHLUHA 		5 
#define MANYAK		6

new g_iGlobalGame;
new g_iMafiaChat;
new g_DayMafia, g_KomDay, g_DocDay, g_ManDay, g_ShlDay;
new g_iMafiaNight;
new g_iUserRoleMafia[MAX_PLAYERS + 1];
new g_iMafiaTime;
new g_iBitUserPlayerMafia; 
new g_iBitUserVoteMafia;
new g_iVoteMafia[MAX_PLAYERS + 1];
static const g_szMafiaRoleName[][]=
{
	"JBM_ROLE_NOT_CHOOSED",
	"JBM_ROLE_STANDART",
	"JBM_ROLE_MAFIA",
	"JBM_ROLE_COMISAR",
	"JBM_ROLE_DOCTOR",
	"JBM_ROLE_SHLUHA",
	"JBM_ROLE_MANYAK"
};

// Битва за джихад
new g_iUserRoleDjixad[MAX_PLAYERS + 1]; 
new g_iBitUserBury;
new g_iBitUserBurn;
new g_iLastInvis[MAX_PLAYERS + 1];
static const g_szDjixadRoleName[13][]=
{
	"JBM_ROLE_NOT_CHOOSED",
	"JBM_ROLE_KAMPER",
	"JBM_ROLE_DJABBA",
	"JBM_ROLE_MARSIANIN",
	"JBM_ROLE_GLISTA",
	"JBM_ROLE_SPY",
	"JBM_ROLE_KONTRABANDIST",
	"JBM_ROLE_OMONOVEC",
	"JBM_ROLE_ALTAIR",
	"JBM_ROLE_FEYA",
	"JBM_ROLE_DIGGER",
	"JBM_ROLE_XOXOL",
	"JBM_ROLE_SHAHID"
};

/*[Привилегии]*/

// VIP
enum _:DATA_VIP
{
	RESPAWN_VIP = 0,
	MONEY_VIP,
	HPAP,
	VOICE,
	INVISIBLE,
	GRANATE,
	SPEED_GRAVITY
};
new g_iVipData[MAX_PLAYERS + 1][DATA_VIP];

// Аниме
enum _:DATA_ANIME
{
	HP = 0,
	DEAGLE,
	NOJ,
	MODEL
};
new g_iAnimeData[MAX_PLAYERS + 1][DATA_ANIME];

// Супер вип
enum _:DATA_ULTRAVIP
{
	RESPAWN_UVIP = 0,
	RESPAWN_UVIP_PLAYER,
	MONEY_UVIP,
	DAMAGE_UVIP,
	BHOP_UVIP,
	GLOW_UVIP,
	CLOSE_CASE_UVIP,
	DOUBLE_JUMP_UVIP
};
new g_iUltraVipData[MAX_PLAYERS + 1][DATA_ULTRAVIP];

// Админ
enum _:DATA_ADMIN
{
	MONEY,
	FOOTSTEPS,
	GOD,
	ULTRA_BHOP
};
new g_iAdminData[MAX_PLAYERS + 1][DATA_ADMIN];

// Хищник
enum _:DATA_PREDATOR
{
	HEAL = 0,
	INVISIBLE,
	WEAPON,
	THEFT 
};
new g_iPredatorData[MAX_PLAYERS + 1][DATA_PREDATOR];

// Босс
new g_iBossHook;				// Подсчет выдачи паутинки для босса (для ограничения)
new bool:g_iBlockBoss[3]; 			// Блокировка входа за охрану | магазина для зеков | Блокировка всем паутинки
enum _:TYPE_BOOST
{
	MONEY_BOOST,
	EXP_BOOST
};
new bool:g_bBossBoostData[MAX_PLAYERS + 1][TYPE_BOOST];

/* < Битсуммы, переменные и массивы для работы с игроками < *///}

/* > LVL система > *///{
	
#define TOTAL_PLAYER_LEVELS 14
#define MAX_LEVEL TOTAL_PLAYER_LEVELS - 1
static const g_szExp[TOTAL_PLAYER_LEVELS]=
{
	0, 			// 1  Уровень
	50, 		// 2  Уровень
	100, 		// 3  Уровень
	150, 		// 4  Уровень
	250, 		// 5  Уровень
	350, 		// 6  Уровень
	500, 		// 7  Уровень
	650, 		// 8  Уровень
	1000, 		// 9  Уровень
	2000, 		// 10 Уровень
	3500, 		// 11 Уровень
	5000, 		// 12 Уровень
	8000, 		// 13 Уровень
	10000 		// 14 Уровень
};	
static const g_szRankName[TOTAL_PLAYER_LEVELS][]=
{
	"JBM_ID_HUD_RANK_NAME_1",
	"JBM_ID_HUD_RANK_NAME_2",
	"JBM_ID_HUD_RANK_NAME_3",
	"JBM_ID_HUD_RANK_NAME_4",
	"JBM_ID_HUD_RANK_NAME_5",
	"JBM_ID_HUD_RANK_NAME_6",
	"JBM_ID_HUD_RANK_NAME_7",
	"JBM_ID_HUD_RANK_NAME_8",
	"JBM_ID_HUD_RANK_NAME_9",
	"JBM_ID_HUD_RANK_NAME_10",
	"JBM_ID_HUD_RANK_NAME_11",
	"JBM_ID_HUD_RANK_NAME_12",
	"JBM_ID_HUD_RANK_NAME_13",
	"JBM_ID_HUD_RANK_NAME_14"
};

new g_szRankHost[32];
new g_szRankUser[32];
new g_szRankPassword[32]; 
new g_szRankDataBase[32];
new g_szRankTable[32];

new g_szQuery[2048] , g_szSteamID[MAX_PLAYERS + 1][34];
new Handle:g_hDBTuple, Handle:g_hConnect;
// Lvl TIME
new g_iLevel[MAX_PLAYERS + 1][2], g_iExpTime[MAX_PLAYERS + 1];
// Lvl KILLS
new g_iExpName[MAX_PLAYERS + 1];
public SQL_QueryConnection(iState, Handle:hQuery, szError[], iErrcode, iParams[] , iParamsSize) 
{
	switch(iState) 
	{
		case TQUERY_CONNECT_FAILED: log_amx ( "Load - Could not connect to SQL database. [%d] %s" , iErrcode , szError );
		case TQUERY_QUERY_FAILED: log_amx ( "Load Query failed. [%d] %s" , iErrcode , szError );
	}
	new pPlayer = iParams[0];
	if(SQL_NumResults(hQuery) < 1) 
	{
		if(equal(g_szSteamID[pPlayer], "ID_PENDING"))
		return PLUGIN_HANDLED;
		g_iLevel[pPlayer][0] = 1; 
		g_iExpTime[pPlayer] = 0;
		g_iLevel[pPlayer][1] = 0;
		g_iExpName[pPlayer] = 0;
		format
		(
			g_szQuery, charsmax(g_szQuery),
			
			"INSERT INTO `%s`(`SteamID`, `level_time`, `time`, `level_kills`, `kills`) VALUES ('%s' ,'%i' ,'%i', '%i' ,'%i');",
			g_szRankTable, g_szSteamID[pPlayer], 
			g_iLevel[pPlayer][0], g_iExpTime[pPlayer], 
			g_iLevel[pPlayer][1], g_iExpName[pPlayer]
		);
		SQL_ThreadQuery(g_hDBTuple, "ThreadQueryHandler", g_szQuery);
		return PLUGIN_HANDLED;
	}
	else 
	{
		g_iLevel[pPlayer][0] = SQL_ReadResult(hQuery, 1);
		g_iExpTime[pPlayer] = SQL_ReadResult(hQuery, 2);
		g_iLevel[pPlayer][1] = SQL_ReadResult(hQuery, 3);
		g_iExpName[pPlayer] = SQL_ReadResult(hQuery, 4);
	}
	return PLUGIN_HANDLED;
}

public ThreadQueryHandler(iState, Handle:hQuery, szError[], iError, iParams[], iParamsSize) 
{
	if(iState == 0)
	return;
	log_amx("SQL Error: %d (%s)", iError, szError);
}

public jbm_rank_reward_exp()
{
	for(new pPlayer = 1; pPlayer <= g_iMaxPlayers; pPlayer++)
	{
		if(isSetBit(g_iBitUserConnected, pPlayer) && (g_iUserTeam[pPlayer] == 1 || g_iUserTeam[pPlayer] == 2) && g_iLevel[pPlayer][0] < g_iLevelCvars[MAX_LEVEL_TIME]) 
		{
			if(g_bBossBoostData[pPlayer][EXP_BOOST]) g_iExpTime[pPlayer]++;
			jbm_set_user_exp(pPlayer, g_iExpTime[pPlayer] + 1, 1);
		}
	}
}

/* < LVL система < *///}

/* > Файлы > *///{
public plugin_precache()
{
		// Настройка через файлы //
	LOAD_CONFIGURATION();
	LOAD_FILES();

		// Удаялем мусор и многое другое //
	
	// create_buyzone //
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"));
	set_pev(iEntity, pev_iuser1, IUSER1_BUYZONE_KEY);
	
	g_iFakeMetaSpawn 		= register_forward(FM_Spawn, 	"FakeMeta_Spawn_Post", 1);
	g_iFakeMetaKeyValue 	= register_forward(FM_KeyValue, "FakeMeta_KeyValue_Post", 1);
	g_tButtonList 			= TrieCreate();
	g_tRemoveEntities 		= TrieCreate();
	new const szRemoveEntities[][] = 
	{
		"func_hostage_rescue", 
		"info_hostage_rescue", 
		"func_bomb_target", 
		"info_bomb_target", 
		"func_vip_safetyzone", 
		"info_vip_start", 
		"func_escapezone", 
		"hostage_entity", 
		"monster_scientist", 
		"func_buyzone"
	};
	for(new i; i < sizeof(szRemoveEntities); i++) 
		TrieSetCell(g_tRemoveEntities, szRemoveEntities[i], i);
}	

// Секции
enum
{
	SELECT_MAIN = 1,
	SELECT_ACCESS_FLAGS,
	SELECT_PRISON,
	SELECT_GUARD
};
	
// Флаги
enum
{
	VOICE = 0,
	HOOK,
	VIP_MENU,
	ULTRA_VIP,
	ADMIN,
	PREDATOR,
	AMXMODMENU,
	BOSS,
	ACP,
	TRAIL,
	ANIME,
	MAX_ACCESS_FLAGS
};

// Заключенные
enum
{
	MDL_PR = 0,
	HAND_PR,
	MDL_FB
};

// Охранники
enum
{
	MDL_GR = 0,
	HEALTH_GUARD,
	MDL_CHIEF,
	HEALTH_CHIEF,
	HAND_GR
};

new g_iFlagAccess[MAX_ACCESS_FLAGS];

// Модели
enum _:PLAYER_MODELS
{
	PRISONER,
	FOOTBALLER,
	GUARD,
	CHIEF,
	MDLANIME
}
new g_szPlayerModel[PLAYER_MODELS][32];

enum _:PLAYER_HAND
{
	PRISONER_P,
	PRISONER_V,
	GUARD_P,
	GUARD_V
}
new g_szPlayerHand[PLAYER_HAND][128];

// Храним инфу
enum _:PLAYER_PARAMS
{
	COUNT_SKIN,
	FD_SKIN,
	WANTED_SKIN,
	GR_HP,
	CHIEF_HP
}
new g_iPlayersParams[PLAYER_PARAMS];

enum
{
	SELECT_SOUNDS = 1,
	SELECT_MODELS,
	SELECT_SPRITES
};

enum _:MAX_SOUNDS 
{ 
	HAND_HIT,
	HAND_SLASH,
	HAND_DEPLOY,
	BATON_HIT,
	BATON_HITWALL,
	BATON_SLASH,
	BATON_STAB,
	BATON_DEPLOY,
	BOUNCE_BALL, 
	GRAB_BALL,
	KICK_BALL,
	WHITLE_START,
	WHITLE_END,
	GRENADE_FROST_EXPLOSION,
	FREEZE_PLAYER,
	DEFROST_PLAYER,
	CHAINSAW_DEPLOY,
	CHAINSAW_HIT,
	CHAINSAW_SLASH,
	CHAINSAW_STAB,
	CHAINSAW_HITWALL,
	KATANA_DEPLOY,
	KATANA_HITWALL,
	KATANA_SLASH,
	KATANA_HIT,
	KATANA_STAB,
	MACHETE_DEPLOY,
	MACHETE_HIT,
	MACHETE_HITWALL,
	MACHETE_SLASH,
	MACHETE_STAB,
	PERC_DEPLOY,
	PERC_HIT,
	PERC_SLASH,
	PERC_STAB,
	PERC_HITWALL,
	MENU_SOUND,
	GONG_BOXING,
	HOOK_GIVE,
	WANTED_START,
	USE_HOOK,
	RANK_UP,
	RESPAWN_SOUND,
	DJUMP_SOUND,
	DUEL_READY
}
new g_szSounds[MAX_SOUNDS][64];

enum _:MAX_MODELS 
{ 
	P_CHAINSAW,
	V_CHAINSAW,
	P_KATANA,
	V_KATANA,
	P_MACHETE,
	V_MACHETE,
	V_SYRINGE,
	BALL,
	V_HAND_BALL,
	P_PERC,
	V_PERC
}
new g_szModels[MAX_MODELS][64];

enum _:MAX_SPRITES { SPRITE_BALL, SPRITE_DUEL_RED, SPRITE_DUEL_BLUE }
new g_szSprites[MAX_SPRITES][64];

LOAD_CONFIGURATION()
{
	new szCfgDir[64], szCfgFile[128];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	
// CONFIG.INI
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_mode/config.ini", szCfgDir);
	if(!file_exists(szCfgFile))
	{
		new szError[100];
		formatex(szError, charsmax(szError), "[JBM] Отсутсвтует: %s!", szCfgFile);
		set_fail_state(szError);
		return;
	}
	new szBuffer[128], szKey[64], szValue[960], iSectrion;
	new iFile = fopen(szCfgFile, "rt");
	while(iFile && !feof(iFile))
	{
		fgets(iFile, szBuffer, charsmax(szBuffer));
		replace(szBuffer, charsmax(szBuffer), "^n", "");
		if(!szBuffer[0] || szBuffer[0] == ';' || szBuffer[0] == '{' || szBuffer[0] == '}' || szBuffer[0] == '#') continue;
		if(szBuffer[0] == '[')
		{
			iSectrion++;
			continue;
		}
		parse(szBuffer, szKey, charsmax(szKey), szValue, charsmax(szValue));
		trim(szKey);
		trim(szValue);
		switch (iSectrion)
		{
			case SELECT_MAIN:
			{
				formatex(g_szRestartText, charsmax(g_szRestartText), "%s^n%s", g_szRestartText, szBuffer);
			}
			case SELECT_ACCESS_FLAGS:
			{
				if(equal(szKey, "VOICE")) 				g_iFlagAccess[VOICE] 		= read_flags(szValue);
				else if(equal(szKey, "HOOK"))			g_iFlagAccess[HOOK] 		= read_flags(szValue);
				else if(equal(szKey, "VIP_MENU"))		g_iFlagAccess[VIP_MENU] 	= read_flags(szValue);
				else if(equal(szKey, "ULTRA_VIP"))		g_iFlagAccess[ULTRA_VIP] 	= read_flags(szValue);
				else if(equal(szKey, "ADMIN"))			g_iFlagAccess[ADMIN] 		= read_flags(szValue);
				else if(equal(szKey, "PREDATOR"))		g_iFlagAccess[PREDATOR] 	= read_flags(szValue);
				else if(equal(szKey, "BOSS"))			g_iFlagAccess[BOSS] 		= read_flags(szValue);
				else if(equal(szKey, "ACP"))			g_iFlagAccess[ACP] 			= read_flags(szValue);
				else if(equal(szKey, "TRAIL"))			g_iFlagAccess[TRAIL] 		= read_flags(szValue);
				else if(equal(szKey, "ANIME"))			g_iFlagAccess[ANIME] 		= read_flags(szValue);
			}
			case SELECT_PRISON:
			{
				if(equal(szKey, "MDL_PR"))				copy(g_szPlayerModel[PRISONER], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "COUNT_SKIN"))		g_iPlayersParams[COUNT_SKIN] 		= str_to_num(szValue);
				else if(equal(szKey, "FD_SKIN"))		g_iPlayersParams[FD_SKIN] 			= str_to_num(szValue);
				else if(equal(szKey, "WANTED_SKIN"))	g_iPlayersParams[WANTED_SKIN] 		= str_to_num(szValue);
				else if(equal(szKey, "P_HAND_PR")) 		copy(g_szPlayerHand[PRISONER_P], 	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "V_HAND_PR")) 		copy(g_szPlayerHand[PRISONER_V], 	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "MDL_FB")) 		copy(g_szPlayerModel[FOOTBALLER], 	charsmax(g_szPlayerModel[]), szValue);
			}
			case SELECT_GUARD:
			{
				if(equal(szKey, "MDL_ANIME"))			copy(g_szPlayerModel[MDLANIME], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "MDL_GUARD"))			copy(g_szPlayerModel[GUARD], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "HEALTH_GUARD")) 	g_iPlayersParams[GR_HP] 		= str_to_num(szValue);
				else if(equal(szKey, "MDL_CHIEF"))		copy(g_szPlayerModel[CHIEF], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "HEALTH_CHIEF")) 	g_iPlayersParams[CHIEF_HP] 		= str_to_num(szValue);
				else if(equal(szKey, "P_HAND_GR")) 		copy(g_szPlayerHand[GUARD_P],	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "V_HAND_GR")) 		copy(g_szPlayerHand[GUARD_V],	charsmax(g_szPlayerHand[]), szValue);
			}
		}
	}
	fclose(iFile);
	
// PRECACHE.INI
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_mode/precache.ini", szCfgDir);
	if(!file_exists(szCfgFile))
	{
		new szError[100];
		formatex(szError, charsmax(szError), "[JBM] Отсутсвтует: %s!", szCfgFile);
		set_fail_state(szError);
		return;
	}
	iSectrion = 0;
	iFile = fopen(szCfgFile, "rt");
	while(iFile && !feof(iFile))
	{
		fgets(iFile, szBuffer, charsmax(szBuffer));
		replace(szBuffer, charsmax(szBuffer), "^n", "");
		if(!szBuffer[0] || szBuffer[0] == ';' || szBuffer[0] == '{' || szBuffer[0] == '}' || szBuffer[0] == '#') continue;
		if(szBuffer[0] == '[')
		{
			iSectrion++;
			continue;
		}
		parse(szBuffer, szKey, charsmax(szKey), szValue, charsmax(szValue));
		trim(szKey);
		trim(szValue);
		switch(iSectrion)
		{
			case SELECT_SOUNDS:
			{
				if(equal(szKey, "HAND_HIT"))						formatex(g_szSounds[HAND_HIT], 					charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "HAND_SLASH"))					formatex(g_szSounds[HAND_SLASH], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "HAND_DEPLOY"))				formatex(g_szSounds[HAND_DEPLOY], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BATON_HIT"))					formatex(g_szSounds[BATON_HIT], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BATON_HITWALL")) 				formatex(g_szSounds[BATON_HITWALL], 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BATON_SLASH")) 				formatex(g_szSounds[BATON_SLASH], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BATON_STAB")) 				formatex(g_szSounds[BATON_STAB], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BATON_DEPLOY")) 				formatex(g_szSounds[BATON_DEPLOY], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BOUNCE_BALL")) 				formatex(g_szSounds[BOUNCE_BALL],		 		charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "GRAB_BALL")) 					formatex(g_szSounds[GRAB_BALL],		 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "KICK_BALL")) 					formatex(g_szSounds[KICK_BALL], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "WHITLE_START")) 				formatex(g_szSounds[WHITLE_START], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "WHITLE_END")) 				formatex(g_szSounds[WHITLE_END], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "GRENADE_FROST_EXPLOSION")) 	formatex(g_szSounds[GRENADE_FROST_EXPLOSION], 	charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "FREEZE_PLAYER"))				formatex(g_szSounds[FREEZE_PLAYER], 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "DEFROST_PLAYER")) 			formatex(g_szSounds[DEFROST_PLAYER], 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "CHAINSAW_DEPLOY")) 			formatex(g_szSounds[CHAINSAW_DEPLOY], 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "CHAINSAW_HIT")) 				formatex(g_szSounds[CHAINSAW_HIT], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "CHAINSAW_SLASH"))				formatex(g_szSounds[CHAINSAW_SLASH], 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "CHAINSAW_STAB"))				formatex(g_szSounds[CHAINSAW_STAB], 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "CHAINSAW_HITWALL"))			formatex(g_szSounds[CHAINSAW_HITWALL],			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "KATANA_DEPLOY"))				formatex(g_szSounds[KATANA_DEPLOY],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "KATANA_HITWALL"))				formatex(g_szSounds[KATANA_HITWALL],			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "KATANA_SLASH"))				formatex(g_szSounds[KATANA_SLASH],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "KATANA_HIT"))					formatex(g_szSounds[KATANA_HIT],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "KATANA_STAB"))				formatex(g_szSounds[KATANA_STAB],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "MACHETE_DEPLOY"))				formatex(g_szSounds[MACHETE_DEPLOY],			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "MACHETE_HIT"))				formatex(g_szSounds[MACHETE_HIT],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "MACHETE_HITWALL"))			formatex(g_szSounds[MACHETE_HITWALL],			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "MACHETE_SLASH"))				formatex(g_szSounds[MACHETE_SLASH],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "MACHETE_STAB"))				formatex(g_szSounds[MACHETE_STAB],				charsmax(g_szSounds[]), szValue);
	            else if(equal(szKey, "PERC_DEPLOY")) 			    formatex(g_szSounds[PERC_DEPLOY], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "PERC_HIT")) 			    	formatex(g_szSounds[PERC_HIT], 				    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "PERC_SLASH"))				    formatex(g_szSounds[PERC_SLASH], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "PERC_STAB"))			     	formatex(g_szSounds[PERC_STAB], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "PERC_HITWALL"))			    formatex(g_szSounds[PERC_HITWALL],			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "MENU_SOUND"))					formatex(g_szSounds[MENU_SOUND],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "GONG_BOXING"))				formatex(g_szSounds[GONG_BOXING],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "HOOK_GIVE"))					formatex(g_szSounds[HOOK_GIVE],					charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "WANTED_START"))				formatex(g_szSounds[WANTED_START],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "USE_HOOK"))					formatex(g_szSounds[USE_HOOK],					charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "RANK_UP"))					formatex(g_szSounds[RANK_UP],					charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "RESPAWN_SOUND"))				formatex(g_szSounds[RESPAWN_SOUND],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "DJUMP_SOUND"))				formatex(g_szSounds[DJUMP_SOUND],				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "DUEL_READY"))					formatex(g_szSounds[DUEL_READY],				charsmax(g_szSounds[]), szValue);
			}
			case SELECT_MODELS:
			{
				if(equal(szKey, "P_CHAINSAW"))						formatex(g_szModels[P_CHAINSAW],				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_CHAINSAW"))					formatex(g_szModels[V_CHAINSAW], 				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "P_KATANA"))					formatex(g_szModels[P_KATANA], 					charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_KATANA"))					formatex(g_szModels[V_KATANA], 					charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "P_MACHETE")) 					formatex(g_szModels[P_MACHETE], 				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_MACHETE"))					formatex(g_szModels[V_MACHETE], 				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_SYRINGE"))					formatex(g_szModels[V_SYRINGE], 				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "BALL"))						formatex(g_szModels[BALL],		 				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_HAND_BALL"))				formatex(g_szModels[V_HAND_BALL], 				charsmax(g_szModels[]), szValue);
			   	else if(equal(szKey, "P_PERC"))						formatex(g_szModels[P_PERC],		 		    charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_PERC"))				        formatex(g_szModels[V_PERC], 				    charsmax(g_szModels[]), szValue);
			}
			case SELECT_SPRITES:
			{
				if(equal(szKey, "SPRITE_BALL"))						formatex(g_szSprites[SPRITE_BALL],				charsmax(g_szSprites[]), szValue);
				else if(equal(szKey, "SPRITE_DUEL_RED"))			formatex(g_szSprites[SPRITE_DUEL_RED], 			charsmax(g_szSprites[]), szValue);
				else if(equal(szKey, "SPRITE_DUEL_BLUE"))			formatex(g_szSprites[SPRITE_DUEL_BLUE], 		charsmax(g_szSprites[]), szValue);
			}
		}
	}	
	fclose(iFile);

	PRECACHE_MODELS();
	PRECACHE_SOUNDS();
	PRECACHE_SPRITES();
}

LOAD_FILES()
{
	new szCfgDir[64], szCfgFile[128];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	
// Музыка в конце раунда
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_mode/round_sound.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_mode/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1:
		{
			new aDataRoundSound[DATA_ROUND_SOUND], szBuffer[128], iLine, iLen;
			g_aDataRoundSound = ArrayCreate(DATA_ROUND_SOUND);
			while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
			{
				if(!iLen || szBuffer[0] == ';') continue;
				parse
				(
					szBuffer, 
					aDataRoundSound[FILE_NAME], charsmax(aDataRoundSound[FILE_NAME]), 
					aDataRoundSound[TRACK_NAME], charsmax(aDataRoundSound[TRACK_NAME])
				);
				formatex(szBuffer, charsmax(szBuffer), "%s.mp3", aDataRoundSound[FILE_NAME]);
				engfunc(EngFunc_PrecacheGeneric, szBuffer);
				ArrayPushArray(g_aDataRoundSound, aDataRoundSound);
			}
			g_iRoundSoundSize = ArraySize(g_aDataRoundSound);
		}
	}
	
// Музыка для меню
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_mode/music_list.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_mode/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1:
		{
			new aDataMusic[DATA_MUSIC], szBuffer[128], iLine, iLen;
			g_aDataMusicList = ArrayCreate(DATA_MUSIC);
			while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
			{
				if(!iLen || szBuffer[0] == ';') continue;
				parse
				(
					szBuffer, 
					aDataMusic[FILE_DIR], charsmax(aDataMusic[FILE_DIR]), 
					aDataMusic[MUSIC_NAME], charsmax(aDataMusic[MUSIC_NAME])
				);
				formatex(szBuffer, charsmax(szBuffer), "%s.mp3", aDataMusic[FILE_DIR]);
				engfunc(EngFunc_PrecacheGeneric, szBuffer);
				ArrayPushArray(g_aDataMusicList, aDataMusic);
			}
			g_iListMusicSize = ArraySize(g_aDataMusicList);
		}
	}

// Костюмчики
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_mode/costumes_list.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_mode/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1:
		{
			new aDataCostumesRead[DATA_COSTUMES_PRECACHE], szBuffer[256], iLine, iLen;
			g_aCostumesList = ArrayCreate(DATA_COSTUMES_PRECACHE);
			while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
			{
				if(!iLen || szBuffer[0] == ';') continue;
				parse
				(
					szBuffer, 
					aDataCostumesRead[MODEL_NAME], 		charsmax(aDataCostumesRead[MODEL_NAME]), 
					aDataCostumesRead[SUB_MODEL], 		charsmax(aDataCostumesRead[SUB_MODEL]),
					aDataCostumesRead[NAME_COSTUME],	charsmax(aDataCostumesRead[NAME_COSTUME]),
					aDataCostumesRead[FLAG_COSTUME],	charsmax(aDataCostumesRead[FLAG_COSTUME]),
					aDataCostumesRead[WARNING_MSG],		charsmax(aDataCostumesRead[WARNING_MSG])
				);
				format(szBuffer, charsmax(szBuffer), "models/jb_engine/costumes/%s.mdl", aDataCostumesRead[MODEL_NAME]);
				if(file_exists(szBuffer)) engfunc(EngFunc_PrecacheModel, szBuffer);
				ArrayPushArray(g_aCostumesList, aDataCostumesRead);
			}
			g_iCostumesListSize = ArraySize(g_aCostumesList);
		}
	}
	
// Модели зеков по NICK | STEAM ID
#if defined SKINS_DATA
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_mode/users_models.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_mode/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1:
		{
			new aDataModelUserData[DATA_MODEL_SKIN], szBuffer[256], iLine, iLen;
			new iData[12], szText[64]; get_time("%d%m%Y", iData, charsmax(iData));
			g_aModelUserData = ArrayCreate(DATA_MODEL_SKIN);
			while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
			{
				if(!iLen || szBuffer[0] == ';') continue;
				parse
				(
					szBuffer, 
					aDataModelUserData[TYPE_AUTH],				charsmax(aDataModelUserData[TYPE_AUTH]), 
					aDataModelUserData[USER_INFO],				charsmax(aDataModelUserData[USER_INFO]),
					aDataModelUserData[MODEL_USER],				charsmax(aDataModelUserData[MODEL_USER]),
					aDataModelUserData[DAY_LEFT],				charsmax(aDataModelUserData[DAY_LEFT])
				);
				trim(aDataModelUserData[DAY_LEFT]);
				replace_all(aDataModelUserData[DAY_LEFT], charsmax(aDataModelUserData[DAY_LEFT]), "/", "");
				if(equal(iData, aDataModelUserData[DAY_LEFT]))
				{
					formatex(szText, charsmax(szText), ";^"%s^" ^"%s^" ^"%s^" ^"Окончено^"", aDataModelUserData[TYPE_AUTH],  aDataModelUserData[USER_INFO], aDataModelUserData[MODEL_USER]);
					write_file(szCfgFile, szText, iLine - 1);
					continue;
				}
				format(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", aDataModelUserData[MODEL_USER], aDataModelUserData[MODEL_USER]);
				if(file_exists(szBuffer)) engfunc(EngFunc_PrecacheModel, szBuffer);
				ArrayPushArray(g_aModelUserData, aDataModelUserData);
			}
			g_iModelUserData = ArraySize(g_aModelUserData);
		}
	}
#endif
}

/* < Файлы < *///}

/* > Модели > *///{
PRECACHE_MODELS()
{
	g_pModelGlass = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl");
	g_pModelDirt = engfunc(EngFunc_PrecacheModel, "models/rockgibs.mdl");
	
// Мазаин
	engfunc(EngFunc_PrecacheModel, g_szModels[P_CHAINSAW]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_CHAINSAW]);
	engfunc(EngFunc_PrecacheModel, g_szModels[P_KATANA]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_KATANA]);
	engfunc(EngFunc_PrecacheModel, g_szModels[P_MACHETE]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_MACHETE]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_SYRINGE]);
	engfunc(EngFunc_PrecacheModel, g_szModels[P_PERC]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_PERC]);
	
// Футбол
	engfunc(EngFunc_PrecacheModel, g_szModels[BALL]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_HAND_BALL]);
	
// Анимация
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/weapons/v_animation.mdl");

// Руки 
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[PRISONER_P]);
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[PRISONER_V]);
	
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[GUARD_P]);
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[GUARD_V]);
	
// Модели игроков
	for(new i = 0, szBuffer[64]; i < PLAYER_MODELS; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_szPlayerModel[i], g_szPlayerModel[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
}
/* < Модели < *///}

/* > Звуки > *///{
PRECACHE_SOUNDS()
{
// Удары от рук
	engfunc(EngFunc_PrecacheSound, g_szSounds[HAND_HIT]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[HAND_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[HAND_DEPLOY]);
	
// Удары от палки
	engfunc(EngFunc_PrecacheSound, g_szSounds[BATON_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BATON_HIT]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BATON_HITWALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BATON_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BATON_STAB]);
	
// Отсчет в меню начальника
	for(new i = 0, szBuffer[64]; i <= 10; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/countdown/%d.wav", i);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	
// Футбол
	engfunc(EngFunc_PrecacheSound, g_szSounds[BOUNCE_BALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[GRAB_BALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[KICK_BALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[WHITLE_START]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[WHITLE_END]);
	
// Магазин
	engfunc(EngFunc_PrecacheSound, g_szSounds[GRENADE_FROST_EXPLOSION]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[FREEZE_PLAYER]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[DEFROST_PLAYER]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CHAINSAW_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CHAINSAW_HIT]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CHAINSAW_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CHAINSAW_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CHAINSAW_HITWALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[KATANA_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[KATANA_HIT]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[KATANA_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[KATANA_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[KATANA_HITWALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_HIT]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_HITWALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[PERC_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[PERC_HIT]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[PERC_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[PERC_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[PERC_HITWALL]);
	
// Другие WAV звуки
	engfunc(EngFunc_PrecacheSound, "ambience/flameburst1.wav");
	engfunc(EngFunc_PrecacheSound, "scientist/scream07.wav");

	engfunc(EngFunc_PrecacheSound, g_szSounds[MENU_SOUND]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[GONG_BOXING]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[HOOK_GIVE]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[WANTED_START]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[USE_HOOK]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[RANK_UP]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[RESPAWN_SOUND]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[DJUMP_SOUND]);
	
// Другие mp3 звуки
	engfunc(EngFunc_PrecacheGeneric, g_szSounds[DUEL_READY]);
}
/* < Звуки < *///}

/* > Спрайты > *///{ 
PRECACHE_SPRITES()
{
	g_pSpriteWave		= engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr");
	g_pSpriteBeam		= engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr");
	g_pSpriteBall		= engfunc(EngFunc_PrecacheModel, g_szSprites[SPRITE_BALL]);
	g_pSpriteDuelRed	= engfunc(EngFunc_PrecacheModel, g_szSprites[SPRITE_DUEL_RED]);
	g_pSpriteDuelBlue	= engfunc(EngFunc_PrecacheModel, g_szSprites[SPRITE_DUEL_BLUE]);
	g_pSpriteLgtning	= engfunc(EngFunc_PrecacheModel, "sprites/lgtning.spr");
	g_pSpriteSmoke		= engfunc(EngFunc_PrecacheModel, "sprites/smokepuff.spr");
	g_pSpriteFlash		= engfunc(EngFunc_PrecacheModel, "sprites/muzzleflash.spr");
}
/* < Спрайты < *///}

/* > Основное > *///{

INIT_MAIN()
{
// Ланги
	register_dictionary("jb_mode/JBM_CORE.txt");
	register_dictionary("jb_mode/JBM_CONTACT.txt");
// Севим инфу
#if defined SAVE_BLOCK_IP_ON_MAP
	g_iBlockListOnMap = TrieCreate();
#endif
	
// Мессаджи hud
	g_iSyncMainInformer 		= CreateHudSyncObj();
	g_iSyncMainDeadInformer		= CreateHudSyncObj();
	g_iSyncSoccerScore 			= CreateHudSyncObj();
	g_iSyncStatusText			= CreateHudSyncObj();
	g_iSyncHudInfo				= CreateHudSyncObj();
	g_iSyncDuelInformer			= CreateHudSyncObj();
	g_iSyncGlobalGame			= CreateHudSyncObj();

	g_iMaxPlayers = get_maxplayers();
}

public client_putinserver(id)
{
	setBit(g_iBitUserConnected, id);
	setBit(g_iBitUserRoundSound, id);
	setBit(g_iBitUserRoundEndEffects, id);
	setBit(g_iBitSoundMenu, id);
	g_iPlayersNum[g_iUserTeam[id]]++;
	set_task(1.0, "jbm_main_informer", id+TASK_SHOW_INFORMER, _, _, "b");
	set_task(1.0, "jbm_main_dead_informer", id+TASK_SHOW_DEAD_INFORMER, _, _, "b");
	new iFlags = get_user_flags(id);
	if(iFlags & g_iFlagAccess[VOICE])		setBit(g_iBitUserBuyVoice, id);
	if(iFlags & g_iFlagAccess[HOOK])		setBit(g_iBitUserHook, id);
	if(iFlags & g_iFlagAccess[VIP_MENU])	setBit(g_iBitUserVip, id);
	if(iFlags & g_iFlagAccess[ULTRA_VIP])	setBit(g_iBitUserUltraVip, id);
	if(iFlags & g_iFlagAccess[ADMIN])		setBit(g_iBitUserAdmin, id);
	if(iFlags & g_iFlagAccess[PREDATOR])    setBit(g_iBitUserPredator, id);
	if(iFlags & g_iFlagAccess[BOSS])		setBit(g_iBitUserBoss, id);
	if(iFlags & g_iFlagAccess[ACP])			setBit(g_iBitUserAC, id);
	if(iFlags & g_iFlagAccess[TRAIL])		setBit(g_iBitUserTrail, id);
	if(iFlags & g_iFlagAccess[ANIME])	    setBit(g_iBitUserAnime, id);
	
	g_iModeFly[id] = true;
	g_iSpeedFly[id] = 720;
	
	// Lvl System
	new iParams[1]; iParams[0] = id;
	get_user_authid(id, g_szSteamID[id], charsmax(g_szSteamID[]));
	format(g_szQuery, charsmax(g_szQuery), "SELECT * FROM `%s` WHERE (`%s`.`SteamID` = '%s')", g_szRankTable, g_szRankTable, g_szSteamID[id]);
	SQL_ThreadQuery(g_hDBTuple, "SQL_QueryConnection", g_szQuery, iParams, sizeof iParams);
	
	// Блокировка входа за охрану
#if defined SAVE_BLOCK_IP_ON_MAP
	new szIp[22];
	get_user_ip(id, szIp, charsmax(szIp), 1);
	if(TrieKeyExists(g_iBlockListOnMap, szIp)) 
		setBit(g_iBitUserBlockedGuard, id);
#endif

#if defined SKINS_DATA 

// ChatManager MISTRIK
	g_iPlayerSkin[id] = "";
	for(new UserMdel; UserMdel < g_iModelUserData; UserMdel++)
	{
		new aDataModelUserData[DATA_MODEL_SKIN];
		ArrayGetArray(g_aModelUserData, UserMdel, aDataModelUserData);
		switch(aDataModelUserData[TYPE_AUTH])
		{
			case 'n':
			{
				new szName[32];
				get_user_name(id, szName, charsmax(szName));
				if(equal(aDataModelUserData[USER_INFO], szName))
				{
					setBit(g_iBitUserCostumModel, id);
					copy(g_iPlayerSkin[id], charsmax(g_iPlayerSkin[]), aDataModelUserData[MODEL_USER]);
					break;
				}
			}
			case 's':
			{
				new g_szSteamID[37]; 
				get_user_authid(id, g_szSteamID, charsmax(g_szSteamID));
				if(equal(aDataModelUserData[USER_INFO], g_szSteamID))
				{
					setBit(g_iBitUserCostumModel, id);
					copy(g_iPlayerSkin[id], charsmax(g_iPlayerSkin[]), aDataModelUserData[MODEL_USER]);
					break;
				}
			}
			case 'i':
			{
				new szIp[26]; 
				get_user_ip(id, szIp, charsmax(szIp), 1);
				if(equal(aDataModelUserData[USER_INFO], szIp)) 
				{
					setBit(g_iBitUserCostumModel, id);
					copy(g_iPlayerSkin[id], charsmax(g_iPlayerSkin[]), aDataModelUserData[MODEL_USER]);
					break;
				}
			}
			case 'f':
			{
				if(get_user_flags(id) & read_flags(aDataModelUserData[USER_INFO])) 
				{
					setBit(g_iBitUserCostumModel, id);
					copy(g_iPlayerSkin[id], charsmax(g_iPlayerSkin[]), aDataModelUserData[MODEL_USER]);
					break;
				}
			}
		}
	}
#endif
}

public client_disconnected(id)
{
	if(isNotSetBit(g_iBitUserConnected, id)) return;
// Таски
	clearBit(g_iBitUserConnected, id);
	if(task_exists(id+TASK_SHOW_INFORMER))		remove_task(id+TASK_SHOW_INFORMER);
	if(task_exists(id+TASK_SHOW_DEAD_INFORMER))	remove_task(id+TASK_SHOW_DEAD_INFORMER);
	if(task_exists(id+TASK_STEAL_MONEY))			remove_task(id+TASK_STEAL_MONEY);
	g_iPlayersNum[g_iUserTeam[id]]--;
	if(isSetBit(g_iBitUserAlive, id))
	{
		g_iAlivePlayersNum[g_iUserTeam[id]]--;
		clearBit(g_iBitUserAlive, id);
	}
	if(id == g_iChiefId)
	{
		g_iChiefId = 0;
		g_iChiefStatus = 3;
		g_szChiefName = "";
		if(g_bSoccerGame) remove_task(id+TASK_SHOW_SOCCER_SCORE);
		if(g_iGlobalGame == 1) jbm_mafia_disable();
		if(g_iGlobalGame == 2) jbm_djixad_disable();
	}
	if(isSetBit(g_iBitUserFree, id)) jbm_sub_user_free(id);
	if(isSetBit(g_iBitUserWanted, id)) jbm_sub_user_wanted(id);
	g_iUserTeam[id] = 0;
	g_iUserMoney[id] = 0;
	g_iBitKilledUsers[id] = 0;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitKilledUsers[i], id)) continue;
		clearBit(g_iBitKilledUsers[i], id);
	}
	if(g_eUserCostumes[id][COSTUMES]) jbm_set_user_costumes(id, 0);
	if(task_exists(id+TASK_CHANGE_MODEL))	remove_task(id+TASK_CHANGE_MODEL);
	clearBit(g_iBitUserModel, id);
	clearBit(g_iBitUserFreeNextRound, id);
	clearBit(g_iBitUserVoice, id);
	clearBit(g_iBitUserVoiceNextRound, id);
	clearBit(g_iBitBlockMenu, id);
	clearBit(g_iBitUserVoteDayMode, id);
	if(isSetBit(g_iBitUserSoccer, id))
	{
		clearBit(g_iBitUserSoccer, id);
		if(id == g_iSoccerBallOwner)
		{
			CREATE_KILLPLAYERATTACHMENTS(id);
			set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
			set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
			g_iSoccerBallOwner = 0;
		}
		if(g_bSoccerGame) remove_task(id+TASK_SHOW_SOCCER_SCORE);
	}

// Магазин
	clearBit(g_iBitKatana, id);
	clearBit(g_iBitMachete, id);
	clearBit(g_iBitChainsaw, id);
	clearBit(g_iBitPerc, id);
	clearBit(g_iBitWeaponStatus, id);
	clearBit(g_iBitKokain, id);
	if(task_exists(id+TASK_REMOVE_SYRINGE))		remove_task(id+TASK_REMOVE_SYRINGE);
	if(task_exists(id+TASK_REMOVE_ANIMATE))		remove_task(id+TASK_REMOVE_ANIMATE);
	clearBit(g_iBitFrostNade, id);
	clearBit(g_iBitUserFrozen, id);
	if(task_exists(id+TASK_FROSTNADE_DEFROST)) 	remove_task(id+TASK_FROSTNADE_DEFROST);
	clearBit(g_iBitHingJump, id);
	g_fUserSpeed[id] = 0.0;
	clearBit(g_iBitDoubleJump, id);
	clearBit(g_iBitRandomGlow, id);
	clearBit(g_iBitAutoBhop, id);
	clearBit(g_iBitDoubleDamage, id);
	g_iFrostNade[id] = 0;
	g_iLotteryPlayer[id] = 0;
	g_iSpeedFly[id] = 0;
	g_iModeFly[id] = false;
	clearBit(g_iBitGuardModel, id);
	if(isSetBit(g_iBitInvisibleHat, id))
	{
		clearBit(g_iBitInvisibleHat, id);
		if(task_exists(id+TASK_INVISIBLE_HAT)) 	remove_task(id+TASK_INVISIBLE_HAT);
	}
	clearBit(g_iBitLatchkey, id);
	
// Голос
	clearBit(g_iBitUserBuyVoice, id);

// Хук
	clearBit(g_iBitUserHook, id);
	if(task_exists(TASK_HOOK_THINK+id)) remove_task(TASK_HOOK_THINK+id);
// Випка
	if(isSetBit(g_iBitUserVip, id))
	{
		clearBit(g_iBitUserVip, id);
		for(new i = 0; i < DATA_VIP; i++)
			g_iVipData[id][i] = 0;
	}
	
// Аниме
	if(isSetBit(g_iBitUserAnime, id))
	{
		clearBit(g_iBitUserAnime, id);
		for(new i = 0; i < DATA_ANIME; i++)
			g_iAnimeData[id][i] = 0;
	}
// Ультра вип
	if(isSetBit(g_iBitUserUltraVip,id))
	{
		clearBit(g_iBitUserUltraVip, id);
		for(new i = 0; i < DATA_ULTRAVIP; i++)
			g_iUltraVipData[id][i] = 0;
	}
	
// Админ
	if(isSetBit(g_iBitUserAdmin, id))
	{
		clearBit(g_iBitUserAdmin, id);
		clearBit(g_iBitBoostBhop, id);
		for(new i = 0; i < DATA_ADMIN; i++)
			g_iAdminData[id][i] = 0;
	}
	
// Хищник
	if(isSetBit(g_iBitUserPredator, id))
	{
		clearBit(g_iBitUserPredator, id);
		for(new i = 0; i < DATA_PREDATOR; i++)
			g_iPredatorData[id][i] = 0;
	}
	
// Босс
	if(isSetBit(g_iBitUserBoss, id))
	{
		clearBit(g_iBitUserBoss, id);
		for(new i = 0; i < TYPE_BOOST; i++)
			g_bBossBoostData[id][i] = false;
	}
	if(isSetBit(g_iBitUserHookTime, id))
	{
		clearBit(g_iBitUserHookTime, id);
		g_iBossHook--;
	}
	
// Панель создателя
	clearBit(g_iBitUserAC, id);
	
// Траил
	if(isSetBit(g_iBitUserTrail, id))
	{
		clearBit(g_iBitUserTrail, id);
		aDataTrail[id][SPRITE] = 0;
		aDataTrail[id][COLOR] = 0;
		aDataTrail[id][BRIGHTNESS] = 0;
		aDataTrail[id][WIDTH] = 0;
	}
	if(task_exists(TASK_TRAIL+id)) remove_task(TASK_TRAIL+id);
	
// Модель для зека
	#if defined SKINS_DATA
	clearBit(g_iBitUserCostumModel, id);
	#endif
	
	if(g_iDuelStatus && isSetBit(g_iBitUserDuel, id)) jbm_duel_ended(id);
	
	#if defined SAVE_BLOCK_IP_ON_MAP
	if(isSetBit(g_iBitUserBlockedGuard, id))
	{
		clearBit(g_iBitUserBlockedGuard, id);
		new szIp[22];
		get_user_ip(id, szIp, charsmax(szIp), 1);
		if(!TrieKeyExists(g_iBlockListOnMap, szIp)) TrieSetCell(g_iBlockListOnMap, szIp, 1);
	}
	#else
	clearBit(g_iBitUserBlockedGuard, id);
	#endif
	
	g_iUserBet[id] = 0;
	g_iUserBetId[id] = 0;
	clearBit(g_iBitUserBet, id);
	if(task_exists(id+TASK_SHOW_MONEY_BET)) remove_task(id+TASK_SHOW_MONEY_BET);
	
	// Lvl System
	format(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `level_time` = '%i', `time` = '%i', `level_kills` = '%i', `kills` = '%i'  WHERE `%s`.`SteamID` = '%s';", g_szRankTable, g_iLevel[id][0], g_iExpTime[id], g_iLevel[id][1], g_iExpName[id], g_szRankTable, g_szSteamID[id]);
	SQL_ThreadQuery(g_hDBTuple, "ThreadQueryHandler", g_szQuery);
	g_iLevel[id][0] = 1;
	g_iExpTime[id] = 0;
	g_iLevel[id][1] = 0;
	g_iExpName[id] = 0;
	g_bHookStatus = false;

// Глобальные игры
	// Джихад
	if(isSetBit(g_iBitUserBurn, id))	UTIL_RemoveBurn(id);
}
/* < Основное < *///}

/* > Квары > *///{
INIT_CVARS()
{
// ALL CVARS
	register_cvar("jbm_money_steal", 				"1");
	register_cvar("jbm_money_steal_time", 			"10");
	register_cvar("jbm_shoot_button", 				"1");
	register_cvar("jbm_informer_color", 			"102 69 0");
	register_cvar("jbm_free_day_id_time", 			"120");
	register_cvar("jbm_free_day_all_time", 			"240");
	register_cvar("jbm_team_balance", 				"4");
	register_cvar("jbm_day_mode_vote_time", 		"10");
	register_cvar("jbm_restart_game_time", 			"40");
	register_cvar("jbm_grenade_damage_wanted", 		"0");
	register_cvar("jbm_riot_start_money",			"150");
	register_cvar("jbm_killed_guard_money",			"400");
	register_cvar("jbm_killed_chief_money",			"700");
	register_cvar("jbm_round_free_money",			"100");
	register_cvar("jbm_last_prisoner_money",		"4000");
	
// Donate CVARS
	register_cvar("jbm_respawn_player_num_t",		"4");
	register_cvar("jbm_respawn_player_num_ct",		"2");
	
// VIP CVARS
	register_cvar("jbm_vip_respawn_num",			"3");
	register_cvar("jbm_vip_money_num",				"2000");
	register_cvar("jbm_vip_money_round",			"3");
	register_cvar("jbm_vip_hp_ap_round",			"4");
	register_cvar("jbm_vip_voice_round",			"3");
	register_cvar("jbm_vip_invisible_round",		"4");
	register_cvar("jbm_vip_granate_round",			"4");
	register_cvar("jbm_vip_speed_gravity_round",	"2");
	register_cvar("jbm_vip_discount_shop",			"10");

// Super-VIP CVARS
	register_cvar("jbm_ultra_vip_respawn_num",		"3");
	register_cvar("jbm_ultra_vip_respawn_player_num","1");
	register_cvar("jbm_ultra_vip_money_num",		"2000");
	register_cvar("jbm_ultra_vip_money_round",		"3");
	register_cvar("jbm_ultra_vip_damage_round",		"2");
	register_cvar("jbm_ultra_vip_bhop_round",		"2");
	register_cvar("jbm_ultra_vip_glow_round", 		"2");
	register_cvar("jbm_ultra_vip_close_case", 		"5");
	register_cvar("jbm_ultra_vip_double_jump",		"5");
	
// Admin CVARS
	register_cvar("jbm_admin_money_num",			"5000");
	register_cvar("jbm_admin_money_round",			"5");
	register_cvar("jbm_admin_god_round",			"4");
	register_cvar("jbm_admin_footsteps_round",		"5");
	register_cvar("jbm_admin_bhop_boost", 			"3");
	
// Predator CVARS
	register_cvar("jbm_predator_heal_num", 			"3");
	register_cvar("jbm_predator_invisible_round", 	"5");
	register_cvar("jbm_predator_weapon_round",		"3");
	register_cvar("jbm_predator_theft_round", 		"5");

// Boss CVARS
	register_cvar("jbm_boss_hook_give",				"5");
	register_cvar("jbm_boss_discount_shop",			"15");
	
// Anime CVARS
    register_cvar("jbm_anime_hp_ap_round",	        "1");
	register_cvar("jbm_anime_deagle_round",	        "5");
	register_cvar("jbm_anime_noj_round",	        "10");
	register_cvar("jbm_anime_model_round",       	"4");
	
// SHOP CVARS
	register_cvar("jbm_pn_price_katana",			"2500");
	register_cvar("jbm_pn_price_machete",			"3000");
	register_cvar("jbm_pn_price_chainsaw",			"4000");
	register_cvar("jbm_pn_price_flashbang",			"1500");
	register_cvar("jbm_pn_price_kokain",			"1337");
	register_cvar("jbm_pn_price_stimulator",		"1000");
	register_cvar("jbm_pn_price_frostnade",			"1000");
	register_cvar("jbm_pn_frostnade_limit",			"2");
	register_cvar("jbm_pn_price_armor",				"500");
	register_cvar("jbm_pn_price_hegrenade", 		"1000");
	register_cvar("jbm_pn_price_hing_jump",			"2000");
	register_cvar("jbm_pn_price_fast_run",			"2000");
	register_cvar("jbm_pn_price_double_jump",		"1250");
	register_cvar("jbm_pn_price_random_glow",		"300");
	register_cvar("jbm_pn_price_auto_bhop", 		"3000");
	register_cvar("jbm_pn_price_double_damage", 	"5000");
	register_cvar("jbm_pn_price_low_gravity", 		"6000");
	register_cvar("jbm_pn_price_close_case", 		"10000");
	register_cvar("jbm_pn_price_free_day", 			"6000");
	register_cvar("jbm_pn_price_lottery_ticket", 	"1000");
	register_cvar("jbm_pn_lottery_limit", 			"3");
	register_cvar("jbm_pn_lottery_chance", 			"25");
	register_cvar("jbm_pn_lottery_factor", 			"2");
	register_cvar("jbm_pn_price_prank_prisoner",	"2500");
	register_cvar("jbm_pn_prank_limit", 			"2");
	register_cvar("jbm_pn_vip_guard_model", 		"10000");
	register_cvar("jbm_pn_vip_invisible_hat", 		"12000");
	register_cvar("jbm_pn_vip_latchkey", 			"15000");
	register_cvar("jbm_pn_vip_deagle", 				"17000");
	register_cvar("jbm_gr_price_stimulator", 		"1000");
	register_cvar("jbm_gr_price_random_glow", 		"300");
	register_cvar("jbm_gr_price_lottery_ticket", 	"1000");
	register_cvar("jbm_gr_price_kokain", 			"1337");
	register_cvar("jbm_gr_price_double_jump", 		"1200");
	register_cvar("jbm_gr_price_fast_run", 			"1800");
	register_cvar("jbm_gr_price_low_gravity", 		"5000");
	
	register_cvar("jbm_chief_price_god", 			"20000");
	register_cvar("jbm_chief_price_invisible", 		"15000");
	register_cvar("jbm_chief_price_footsteps", 		"10000");
	register_cvar("jbm_all_order_roundsound", 		"3000");
	
// Connect SQLX
	register_cvar("jbm_sql_host",					"");
	register_cvar("jbm_sql_user",					"");
	register_cvar("jbm_sql_password", 				"");
	register_cvar("jbm_sql_database", 				"");
	register_cvar("jbm_sql_table", 					"");
	register_cvar("jbm_rank_time",					"240");
	register_cvar("jbm_rank_exp_need",				"50");
	register_cvar("jbm_rank_money_bonus",			"5");
	register_cvar("jbm_rank_health_bonus",			"5");
	register_cvar("jbm_rank_players_need",			"8");
	register_cvar("jbm_rank_max_level",				"1000");
}

public plugin_init()
{
	register_plugin("[JBM] CORE", VERSION, "AlexandrFiner");
	INIT_MAIN();			// Main INIT
	INIT_CVARS();			// Cvars INIT
	INIT_EVENT();			// Events INIT
	INIT_CMDS();			// Commans INIT
	INIT_MENU();			// Menus INIT
	INIT_MESSAGE();			// Messages INIT
	INIT_DOOR();			// Door INIT
	INIT_FAKEMETA();		// Fakemeta INIT
	INIT_HAMSANDWICH();		// Hamsandwich INIT
	INIT_GAMEMODE();		// Gamemodes INIT
}

public plugin_end()
{
#if defined SAVE_BLOCK_IP_ON_MAP
	TrieDestroy(g_iBlockListOnMap);
#endif

	// Lvl System
	if(g_hDBTuple) SQL_FreeHandle(g_hDBTuple);
	if(g_hConnect) SQL_FreeHandle(g_hConnect);
	return;
}

public plugin_cfg()
{
// Trail
	new szCfgDir[64], szCfgFile[128];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_mode/trail_settings.ini", szCfgDir);
	if(!file_exists(szCfgFile))
	{
		new error[100];
		formatex(error, charsmax(error), "[JBM] Отсутсвтует: %s!", szCfgFile);
		set_fail_state(error);
		return;
	}
	new szBuffer[128], section;
	new file = fopen(szCfgFile, "rt");
	while(file && !feof(file))
	{
		fgets(file, szBuffer, charsmax(szBuffer));
		replace(szBuffer, charsmax(szBuffer), "^n", "");
		if(!szBuffer[0] || szBuffer[0] == ';' || szBuffer[0] == '{' || szBuffer[0] == '}' || szBuffer[0] == '#') continue;
		if(szBuffer[0] == '[')
		{
			section++;
			continue;
		}
		switch (section)
		{
			case 1:
			{
				if(szBuffer[0] && szBuffer[0] != ';' && szBuffer[0] != '[')
				{
					new szParseText[32], szParseSprite[64];
					parse(szBuffer, szParseText, charsmax(szParseText), szParseSprite, charsmax(szParseSprite));
					if(!szParseText[0]) continue;
					g_iSpriteText[g_iSpriteNum] = szParseText;
					g_iSpriteFile[g_iSpriteNum] = engfunc(EngFunc_PrecacheModel, szParseSprite);
					g_iSpriteNum++;
				}
			}
			case 2:
			{
				if(szBuffer[0] && szBuffer[0] != ';')
				{
					new szParseText[32], szParseColor[64];
					new szParseR[4], szParseG[4], szParseB[4];
					parse(szBuffer, szParseText, charsmax(szParseText), szParseColor, charsmax(szParseColor));
					if(!szParseText[0]) continue;
					parse(szParseColor, szParseR, charsmax(szParseR), szParseG, charsmax(szParseG), szParseB, charsmax(szParseB));
					g_iColorText[g_iColorNum] = szParseText;
					g_iColorPrecache[g_iColorNum][0] = str_to_num(szParseR);
					g_iColorPrecache[g_iColorNum][1] = str_to_num(szParseG);
					g_iColorPrecache[g_iColorNum][2] = str_to_num(szParseB);
					g_iColorNum++;
				}
			}
		}
	}
	fclose(file);
	
// CFG Cvars
	
	server_cmd("exec %s/jb_mode/cvars/all_cvars.cfg", szCfgDir);
	server_cmd("exec %s/jb_mode/cvars/lvl_cvars.cfg", szCfgDir);
	set_task(0.1, "jbm_get_cvars");
}

public jbm_get_cvars()
{
	server_cmd("sv_voicecodec voice_speex");
	set_cvar_num("mp_flashlight", 		1);
	set_cvar_num("mp_friendlyfire", 	1);
	set_cvar_num("mp_tkpunish", 		0);
	set_cvar_num("mp_autokick", 		0);
	set_cvar_num("mp_freezetime", 		0);
	set_cvar_num("mp_limitteams", 		0);
	set_cvar_num("mp_playerid",			0);
	set_cvar_num("decalfrequency", 		60);
	set_cvar_num("mp_autoteambalance",	0);
	set_cvar_num("mp_roundtime", 		9);
	set_cvar_num("sv_voiceenable", 		1);
	set_cvar_num("sv_alltalk", 			1);
	set_cvar_num("sv_voicequality", 	5);
	set_cvar_num("sv_maxspeed", 		1000);
		
	g_iAllCvars[MONEY_STEAL]		= get_cvar_num("jbm_money_steal");
	g_iAllCvars[MONEY_STEAL_TIME]	= get_cvar_num("jbm_money_steal_time");
	g_iAllCvars[SHOOT_BUTTON] 		= get_cvar_num("jbm_shoot_button");
// 	Ебашим информер в массив
	new szBuffer[16], szArg[4], szArg2[4], szArg3[4];
	get_cvar_string("jbm_informer_color", szBuffer, charsmax(szBuffer));
	parse(szBuffer, szArg, charsmax(szArg), szArg2, charsmax(szArg2), szArg3, charsmax(szArg3));
	g_iColorInformer[0] = str_to_num(szArg);
	g_iColorInformer[1] = str_to_num(szArg2);
	g_iColorInformer[2] = str_to_num(szArg3);
// 	Ебашим информер в массив
	g_iAllCvars[FREE_DAY_ID]					= get_cvar_num("jbm_free_day_id_time");
	g_iAllCvars[FREE_DAY_ALL] 					= get_cvar_num("jbm_free_day_all_time");
	g_iAllCvars[TEAM_BALANCE] 					= get_cvar_num("jbm_team_balance");
	g_iAllCvars[DAY_MODE_VOTE_TIME]				= get_cvar_num("jbm_day_mode_vote_time");
	g_iAllCvars[RESTART_GAME_TIME]				= get_cvar_num("jbm_restart_game_time");
	g_iAllCvars[WANTED_GRENADE_DAMAGE] 			= get_cvar_num("jbm_grenade_damage_wanted");
	g_iAllCvars[RIOT_START_MONEY]				= get_cvar_num("jbm_riot_start_money");
	g_iAllCvars[KILLED_GUARD_MONEY]				= get_cvar_num("jbm_killed_guard_money");
	g_iAllCvars[KILLED_CHIEF_MONEY] 			= get_cvar_num("jbm_killed_chief_money");
	g_iAllCvars[ROUND_FREE_MONEY] 				= get_cvar_num("jbm_round_free_money");
	
	g_iAllCvars[LAST_PRISONER_MONEY] 			= get_cvar_num("jbm_last_prisoner_money");
	g_iAllCvars[RESPAWN_PLAYER_NUM_T] 			= get_cvar_num("jbm_respawn_player_num_t");
	g_iAllCvars[RESPAWN_PLAYER_NUM_CT] 			= get_cvar_num("jbm_respawn_player_num_ct");
	
	g_iAllCvars[VIP_RESPAWN_NUM] 				= get_cvar_num("jbm_vip_respawn_num");
	g_iAllCvars[VIP_MONEY_NUM] 					= get_cvar_num("jbm_vip_money_num");
	g_iAllCvars[VIP_MONEY_ROUND] 				= get_cvar_num("jbm_vip_money_round");
	g_iAllCvars[VIP_HP_AP_ROUND] 				= get_cvar_num("jbm_vip_hp_ap_round");
	g_iAllCvars[VIP_VOICE_ROUND] 				= get_cvar_num("jbm_vip_voice_round");
	g_iAllCvars[VIP_INVISIBLE] 					= get_cvar_num("jbm_vip_invisible_round");
	g_iAllCvars[VIP_GRANATE] 					= get_cvar_num("jbm_vip_granate_round");
	g_iAllCvars[VIP_SPEED_GRAVITY] 				= get_cvar_num("jbm_vip_speed_gravity_round");
	g_iAllCvars[VIP_DISCOUNT_SHOP] 				= get_cvar_num("jbm_vip_discount_shop");
	
	g_iAllCvars[ULTRA_VIP_RESPAWN_NUM] 			= get_cvar_num("jbm_ultra_vip_respawn_num");
	g_iAllCvars[ULTRA_VIP_RESPAWN_PLAYER_NUM] 	= get_cvar_num("jbm_ultra_vip_respawn_player_num");
	g_iAllCvars[ULTRA_VIP_MONEY_NUM] 			= get_cvar_num("jbm_ultra_vip_money_num");
	g_iAllCvars[ULTRA_VIP_MONEY_ROUND] 			= get_cvar_num("jbm_ultra_vip_money_round");
	g_iAllCvars[ULTRA_VIP_DAMAGE_ROUND] 		= get_cvar_num("jbm_ultra_vip_damage_round");
	g_iAllCvars[ULTRA_VIP_BHOP_ROUND] 			= get_cvar_num("jbm_ultra_vip_bhop_round");
	g_iAllCvars[ULTRA_VIP_GLOW_ROUND] 			= get_cvar_num("jbm_ultra_vip_glow_round");
	g_iAllCvars[ULTRA_VIP_CLOSE_CASE_ROUND]		= get_cvar_num("jbm_ultra_vip_close_case");
	g_iAllCvars[ULTRA_VIP_DOUBLE_JUMP_ROUND] 	= get_cvar_num("jbm_ultra_vip_double_jump");

	g_iAllCvars[ADMIN_MONEY_NUM] 				= get_cvar_num("jbm_admin_money_num");
	g_iAllCvars[ADMIN_MONEY_ROUND] 				= get_cvar_num("jbm_admin_money_round");
	g_iAllCvars[ADMIN_FOOTSTEPS_ROUND] 			= get_cvar_num("jbm_admin_footsteps_round");
	g_iAllCvars[ADMIN_GOD_ROUND] 				= get_cvar_num("jbm_admin_god_round");
	g_iAllCvars[ADMIN_ULTRA_BHOP] 				= get_cvar_num("jbm_admin_bhop_boost");

	g_iAllCvars[PREDATOR_HEAL_NUM] 				= get_cvar_num("jbm_predator_heal_num");
	g_iAllCvars[PREDATOR_INVISIBLE_ROUND] 		= get_cvar_num("jbm_predator_invisible_round");
	g_iAllCvars[PREDATOR_WEAPON_ROUND] 			= get_cvar_num("jbm_predator_weapon_round");
	g_iAllCvars[PREDATOR_THEFT_ROUND] 			= get_cvar_num("jbm_predator_theft_round");
	
	g_iAllCvars[BOSS_HOOK]						= get_cvar_num("jbm_boss_hook_give");
	g_iAllCvars[BOSS_DISCOUNT_SHOP] 			= get_cvar_num("jbm_boss_discount_shop");
	
	g_iAllCvars[ANIME_HP_AP_ROUND] 				= get_cvar_num("jbm_anime_hp_ap_round");
	g_iAllCvars[ANIME_DEAGLE_ROUND] 			= get_cvar_num("jbm_anime_deagle_round");
	g_iAllCvars[ANIME_NOJ_ROUND] 			    = get_cvar_num("jbm_anime_noj_round");
	g_iAllCvars[ANIME_MODEL_ROUND] 			    = get_cvar_num("jbm_anime_model_round");	

// Shop
	g_iShopCvars[KATANA] 			= get_cvar_num("jbm_pn_price_katana");
	g_iShopCvars[MACHETE] 			= get_cvar_num("jbm_pn_price_machete");
	g_iShopCvars[CHAINSAW] 			= get_cvar_num("jbm_pn_price_chainsaw");
	g_iShopCvars[FLASHBANG] 		= get_cvar_num("jbm_pn_price_flashbang");
	g_iShopCvars[KOKAIN] 			= get_cvar_num("jbm_pn_price_kokain");
	g_iShopCvars[STIMULATOR] 		= get_cvar_num("jbm_pn_price_stimulator");
	g_iShopCvars[FROSTNADE] 		= get_cvar_num("jbm_pn_price_frostnade");
	g_iShopCvars[FROSTNADE_LIMIT] 	= get_cvar_num("jbm_pn_frostnade_limit");
	g_iShopCvars[ARMOR] 			= get_cvar_num("jbm_pn_price_armor");
	g_iShopCvars[HEGRENADE] 		= get_cvar_num("jbm_pn_price_hegrenade");
	g_iShopCvars[HING_JUMP] 		= get_cvar_num("jbm_pn_price_hing_jump");
	g_iShopCvars[FAST_RUN]			= get_cvar_num("jbm_pn_price_fast_run");
	g_iShopCvars[DOUBLE_JUMP] 		= get_cvar_num("jbm_pn_price_double_jump");
	g_iShopCvars[RANDOM_GLOW] 		= get_cvar_num("jbm_pn_price_random_glow");
	g_iShopCvars[AUTO_BHOP] 		= get_cvar_num("jbm_pn_price_auto_bhop");
	g_iShopCvars[DOUBLE_DAMAGE] 	= get_cvar_num("jbm_pn_price_double_damage");
	g_iShopCvars[LOW_GRAVITY] 		= get_cvar_num("jbm_pn_price_low_gravity");
	g_iShopCvars[CLOSE_CASE] 		= get_cvar_num("jbm_pn_price_close_case");
	g_iShopCvars[FREE_DAY_SHOP] 	= get_cvar_num("jbm_pn_price_free_day");
	g_iShopCvars[LOTTERY_TICKET] 	= get_cvar_num("jbm_pn_price_lottery_ticket");
	g_iShopCvars[LOTTERY_LIMIT] 	= get_cvar_num("jbm_pn_lottery_limit");
	g_iShopCvars[LOTTERY_CHANCE] 	= get_cvar_num("jbm_pn_lottery_chance");
	g_iShopCvars[LOTTERY_FACTOR] 	= get_cvar_num("jbm_pn_lottery_factor");
	g_iShopCvars[PRANK_PRISONER] 	= get_cvar_num("jbm_pn_price_prank_prisoner");
	g_iShopCvars[PRANK_LIMIT] 		= get_cvar_num("jbm_pn_prank_limit");
	g_iShopCvars[VIP_GUARD_MODEL] 	= get_cvar_num("jbm_pn_vip_guard_model");
	g_iShopCvars[VIP_INVISIBLE_HAT] = get_cvar_num("jbm_pn_vip_invisible_hat");
	g_iShopCvars[VIP_LATCHKEY] 		= get_cvar_num("jbm_pn_vip_latchkey");
	g_iShopCvars[VIP_DEAGLE] 		= get_cvar_num("jbm_pn_vip_deagle");
	g_iShopCvars[STIMULATOR_GR] 	= get_cvar_num("jbm_gr_price_stimulator");
	g_iShopCvars[RANDOM_GLOW_GR] 	= get_cvar_num("jbm_gr_price_random_glow");
	g_iShopCvars[LOTTERY_TICKET_GR] = get_cvar_num("jbm_gr_price_lottery_ticket");
	g_iShopCvars[KOKAIN_GR] 		= get_cvar_num("jbm_gr_price_kokain");
	g_iShopCvars[DOUBLE_JUMP_GR] 	= get_cvar_num("jbm_gr_price_double_jump");
	g_iShopCvars[FAST_RUN_GR] 		= get_cvar_num("jbm_gr_price_fast_run");
	g_iShopCvars[LOW_GRAVITY_GR] 	= get_cvar_num("jbm_gr_price_low_gravity");
	g_iShopCvars[GOD_CHIEF] 		= get_cvar_num("jbm_chief_price_god");
	g_iShopCvars[INVISIBLE_CHIEF] 	= get_cvar_num("jbm_chief_price_invisible");
	g_iShopCvars[FOOTSTEPS_CHIEF] 	= get_cvar_num("jbm_chief_price_footsteps");
	g_iShopCvars[ORDER_ROUNDSOUND]	= get_cvar_num("jbm_all_order_roundsound");
	
// Lvl System

	g_iLevelCvars[TIME_EXP] 					= get_cvar_num("jbm_rank_time");
	g_iLevelCvars[EXP_NEED] 					= get_cvar_num("jbm_rank_exp_need");
	g_iLevelCvars[MONEY_BONUS] 					= get_cvar_num("jbm_rank_money_bonus");
	g_iLevelCvars[HEALTH_BONUS] 				= get_cvar_num("jbm_rank_health_bonus");
	g_iLevelCvars[PLAYERS_NEED] 				= get_cvar_num("jbm_rank_players_need");
	g_iLevelCvars[MAX_LEVEL_TIME]				= get_cvar_num("jbm_rank_max_level");
	
	get_cvar_string("jbm_sql_host", 		g_szRankHost, 		charsmax(g_szRankHost));
	get_cvar_string("jbm_sql_user",			g_szRankUser, 		charsmax(g_szRankUser));
	get_cvar_string("jbm_sql_password",		g_szRankPassword, 	charsmax(g_szRankPassword));
	get_cvar_string("jbm_sql_database",		g_szRankDataBase, 	charsmax(g_szRankDataBase));
	get_cvar_string("jbm_sql_table", 		g_szRankTable, 		charsmax(g_szRankTable));
	
	new szError[512], iErrorCode;
	g_hDBTuple = SQL_MakeDbTuple(g_szRankHost, g_szRankUser, g_szRankPassword, g_szRankDataBase);
	g_hConnect = SQL_Connect(g_hDBTuple, iErrorCode, szError, charsmax(szError));
	
	new Handle:Queries;
	new Query[1024];
	format(Query, 1023, "CREATE TABLE IF NOT EXISTS `%s` (SteamID VARCHAR(40) CHARACTER SET cp1250 COLLATE cp1250_general_ci NOT NULL, level_time INT NOT NULL, time INT NOT NULL, level_kills INT NOT NULL, kills INT NOT NULL, PRIMARY KEY (SteamID))", g_szRankTable);
	Queries = SQL_PrepareQuery(g_hConnect, Query);
	if(!SQL_Execute(Queries)) 
	{
		SQL_QueryError(Queries, szError, charsmax(szError));
		log_amx("%s", szError);
	}
	SQL_FreeHandle(Queries);
	set_task(float(g_iLevelCvars[TIME_EXP]), "jbm_rank_reward_exp", TASK_GIVE_EXP, _, _, "b"); 
}
/* < Квары < *///}

/* > Игровые события > *///{
INIT_EVENT()
{
	register_event("ResetHUD", "Event_ResetHUD", "be");
	register_logevent("LogEvent_RestartGame", 2, "1=Game_Commencing", "1&Restart_Round_");
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");
	register_event("StatusValue", "Event_StatusValueShow", "be", "1=2", "2!0");
	register_event("StatusValue", "Event_StatusValueHide", "be", "1=1", "2=0");
}

public Event_ResetHUD(id)
{
	if(isNotSetBit(g_iBitUserConnected, id)) 
		return;
	
	message_begin(MSG_ONE, MsgId_Money, _, id);
	write_long(g_iUserMoney[id]);
	write_byte(0);
	message_end();
}

public LogEvent_RestartGame()
{
	LogEvent_RoundEnd();
	jbm_set_day(0);
	jbm_set_day_week(0);
}

public Event_HLTV()
{
	g_bRoundEnd = false;
	for(new i; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	if(g_bRestartGame)
	{
		if(task_exists(TASK_RESTART_GAME_TIMER)) 
			return;
		
		g_iDayModeTimer = g_iAllCvars[RESTART_GAME_TIME] + 1;
		set_task(1.0, "jbm_restart_game_timer", TASK_RESTART_GAME_TIMER, _, _, "a", g_iDayModeTimer);
		return;
	}
	jbm_set_day(++g_iDay);
	jbm_set_day_week(++g_iDayWeek);
	g_szChiefName = "";
	g_iDuelUsersId[0] = 0;
	g_iDuelUsersId[1] = 0;
	g_iDuelType = 0;
	g_iChiefStatus = 0;
	g_iBitUserFree = 0;
	g_iFreeCount = 0;
	g_iFreeLang = 0;
	g_iBitUserWanted = 0;
	g_szWantedNames = "";
	g_iWantedCount = 0;
	g_iLastPnId = 0;
	g_iBitKatana = 0;
	g_iBitMachete = 0;
	g_iBitChainsaw = 0;
	g_iBitPerc = 0;
	g_iBitWeaponStatus = 0;
	g_iBitKokain = 0;
	g_iBitFrostNade = 0;
	g_iBitHingJump = 0;
	g_iBitDoubleJump = 0;
	g_iBitAutoBhop = 0;
	g_iBitBoostBhop = 0;
	g_iBitDoubleDamage = 0;
	g_iBitGuardModel = 0;
	g_iBitLatchkey = 0;
	g_iBitUserVoice = 0;
	g_iPrank = 0;
	g_iBlockBoss[2] = false;
	g_bDoorStatus = false;
	g_bGlobalGame = false;
#if defined DEBUG
	if(jbm_get_day_week() <= 5 || !g_iDayModeListSize) jbm_set_day_mode(1);
#else
	if(jbm_get_day_week() <= 5 || !g_iDayModeListSize || g_iPlayersNum[1] < 2 || !g_iPlayersNum[2]) jbm_set_day_mode(1);
#endif // _DEBUG
	else jbm_set_day_mode(3);
}

public jbm_restart_game_timer()
{
	if(--g_iDayModeTimer)
	{
		jbm_open_doors();
		formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "[%s]", UTIL_FixTime(g_iDayModeTimer));
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
#if defined DEBUG
	if(jbm_get_day_week() <= 5 || !g_iDayModeListSize)
#else
	if(jbm_get_day_week() <= 5 || !g_iDayModeListSize || g_iAlivePlayersNum[1] < 2 || !g_iAlivePlayersNum[2])
#endif // _DEBUG
	{
		if(!g_iChiefStatus)
		{
			g_iChiefChoiceTime = 40 + 1;
			set_task(1.0, "jbm_chief_choice_timer", TASK_CHIEF_CHOICE_TIME, _, _, "a", g_iChiefChoiceTime);
		}
		DisableHamForward(g_iHamHookForwardsDjihad);
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(isNotSetBit(g_iBitUserConnected, i))
				continue;
			
			if(g_iUserTeam[i] == 1)
			{
				if(isSetBit(g_iBitUserFreeNextRound, i))
				{
					jbm_add_user_free(i);
					clearBit(g_iBitUserFreeNextRound, i);
				}
				if(isSetBit(g_iBitUserVoiceNextRound, i))
				{
					setBit(g_iBitUserVoice, i);
					clearBit(g_iBitUserVoiceNextRound, i);
				}
			}
			if(isSetBit(g_iBitUserVip, i))
			{
				g_iVipData[i][RESPAWN_VIP] = g_iAllCvars[VIP_RESPAWN_NUM];
				for(new item = 1; item < DATA_VIP; item++)
					g_iVipData[i][item]++;
			}
			if(isSetBit(g_iBitUserAnime, i))
			{
				for(new item = 0; item < DATA_ANIME; item++)
					g_iAnimeData[i][item]++;
			}
			if(isSetBit(g_iBitUserUltraVip, i))
			{
			
				g_iUltraVipData[i][RESPAWN_UVIP] = g_iAllCvars[ULTRA_VIP_RESPAWN_NUM];
				g_iUltraVipData[i][RESPAWN_UVIP_PLAYER] = g_iAllCvars[ULTRA_VIP_RESPAWN_PLAYER_NUM];
				for(new item = 2; item < DATA_ULTRAVIP; item++)
					g_iUltraVipData[i][item]++;
			}
			if(isSetBit(g_iBitUserAdmin, i))
			{
				for(new item = 0; item < DATA_ADMIN; item++)
					g_iAdminData[i][item]++;
			}
			if(isSetBit(g_iBitUserPredator, i))
			{
				g_iPredatorData[i][HEAL] = g_iAllCvars[PREDATOR_HEAL_NUM];
				for(new item = 1; item < DATA_PREDATOR; item++)
					g_iPredatorData[i][item]++;
			}
			g_iFrostNade[i] = 0;
			g_iLotteryPlayer[i] = 0;
		}
	}
	else jbm_vote_day_mode_start();
}

public jbm_chief_choice_timer()
{
	if(--g_iChiefChoiceTime)
	{
		if(g_iChiefChoiceTime == 35) g_iChiefIdOld = 0;
		formatex(g_szChiefName, charsmax(g_szChiefName), " [%s]", UTIL_FixTime(g_iChiefChoiceTime));
	}
	else
	{
		g_szChiefName = "";
		jbm_free_day_start();
	}
}

public LogEvent_RoundEnd()
{
	if(!task_exists(TASK_ROUND_END))
		set_task(0.1, "LogEvent_RoundEndTask", TASK_ROUND_END);
}

public LogEvent_RoundEndTask()
{
	if(g_iDayMode != DAYMODE_GAMES)
	{
		g_bBoxingStatus = 0;
		g_iFriendlyFire = 0;
		g_iMoreDamageHE = 0;
		if(task_exists(TASK_COUNT_DOWN_TIMER)) remove_task(TASK_COUNT_DOWN_TIMER);
		g_iChiefId = 0;
		if(task_exists(TASK_CHIEF_CHOICE_TIME))
		{
			remove_task(TASK_CHIEF_CHOICE_TIME);
			g_szChiefName = "";
		}
		if(g_iDayMode == DAYMODE_FREE) jbm_free_day_ended();
		if(g_bSoccerStatus) jbm_soccer_disable_all();
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(isNotSetBit(g_iBitUserConnected, i))
				continue;
			
			if(isNotSetBit(g_iBitUserAlive, i)) 
				continue;
			
			g_fUserSpeed[i] = 0.0;
			if(task_exists(i+TASK_REMOVE_SYRINGE))
			{
				remove_task(i+TASK_REMOVE_SYRINGE);
				if(get_user_weapon(i))
				{
					new iActiveItem = get_pdata_cbase(i, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
			}
			if(task_exists(i+TASK_REMOVE_ANIMATE))
			{
				remove_task(i+TASK_REMOVE_ANIMATE);
				if(get_user_weapon(i))
				{
					new iActiveItem = get_pdata_cbase(i, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
			}
			if(pev(i, pev_renderfx) != kRenderFxNone || pev(i, pev_rendermode) != kRenderNormal)
			{
				jbm_set_user_rendering(i, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
				g_eUserRendering[i][RENDER_STATUS] = false;
			}
			if(g_iBitUserFrozen && isSetBit(g_iBitUserFrozen, i))
			{
				clearBit(g_iBitUserFrozen, i);
				if(task_exists(i+TASK_FROSTNADE_DEFROST)) remove_task(i+TASK_FROSTNADE_DEFROST);
				set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
				set_pdata_float(i, m_flNextAttack, 0.0, linux_diff_player);
				emit_sound(i, CHAN_AUTO, g_szSounds[DEFROST_PLAYER], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				new Float:vecOrigin[3]; pev(i, pev_origin, vecOrigin);
				CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
			}
			if(g_iBitRandomGlow && isSetBit(g_iBitRandomGlow, i)) clearBit(g_iBitRandomGlow, i);
			
			// Глобалки 
			if(isSetBit(g_iBitUserBurn, i))	UTIL_RemoveBurn(i);
		}
		if(g_iDuelStatus)
			jbm_duel_ended(g_iDuelUsersId[0]);
	}
	else
	{
		if(task_exists(TASK_VOTE_DAY_MODE_TIMER))
		{
			remove_task(TASK_VOTE_DAY_MODE_TIMER);
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(isNotSetBit(g_iBitUserVoteDayMode, i)) continue;
				clearBit(g_iBitUserVoteDayMode, i);
				jbm_menu_unblock(i);
				set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
				set_pdata_float(i, m_flNextAttack, 0.0, linux_diff_player);
				UTIL_ScreenFade(i, 512, 512, 0, 0, 0, 0, 255, 1);
			}
		}
		if(g_iGameMode != -1)
		{
			if(task_exists(TASK_DAY_MODE_TIMER)) remove_task(TASK_DAY_MODE_TIMER);
			g_szDayModeTimer = "";
			ExecuteForward(g_iHookDayMode[DAY_MODE_END], g_iReturnDayMode, g_iGameMode, g_iAlivePlayersNum[1] ? 1 : 2);
			g_iGameMode = -1;
		}
	}
	for(new i; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
	g_bRoundEnd = true;
	if(g_iRoundSoundSize && !g_bRestartGame)
	{
		new aDataRoundSound[DATA_ROUND_SOUND], iTrack = random_num(0, g_iRoundSoundSize - 1);
		if(iRoundSound != -1) ArrayGetArray(g_aDataRoundSound, iRoundSound, aDataRoundSound);
		else ArrayGetArray(g_aDataRoundSound, iTrack, aDataRoundSound);
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			if(isSetBit(g_iBitUserConnected, i) && isSetBit(g_iBitUserRoundSound, i))
			{
				client_cmd(i, "mp3 play ^"%s.mp3^"", aDataRoundSound[FILE_NAME]);
				UTIL_SayText(i, "!y[!gJBM!y]!y!y %L: !t%s", i, "JBM_CHAT_ID_NOW_PLAYING", aDataRoundSound[TRACK_NAME]);
			}
			
			if(isSetBit(g_iBitUserConnected, i) && isSetBit(g_iBitUserRoundEndEffects, i))
			{
				if(task_exists(i+TASK_ROUND_END_FADE)) remove_task(i+TASK_ROUND_END_FADE);
				set_task(0.10, "CREATE_SCREENFADE", i+TASK_ROUND_END_FADE);
				set_task(1.10, "CREATE_SCREENFADE", i+TASK_ROUND_END_FADE);
				set_task(2.10, "CREATE_SCREENFADE", i+TASK_ROUND_END_FADE);
				set_task(3.10, "CREATE_SCREENFADE", i+TASK_ROUND_END_FADE);
				set_task(4.10, "CREATE_SCREENFADE", i+TASK_ROUND_END_FADE);
			}
		}
		iRoundSound = -1;
	}
} 

public CREATE_SCREENFADE(pPlayer)
{
	pPlayer -= TASK_ROUND_END_FADE;
	message_begin(MSG_ONE, MsgId_ScreenFade, {0,0,0}, pPlayer);
	write_short(8192);
	write_short(2048);
	write_short(0);
	write_byte(random_num(20, 255));
	write_byte(random_num(20, 255));
	write_byte(random_num(20, 255));
	write_byte(128);
	message_end();
}

public Event_StatusValueShow(id)
{
	new iTarget = read_data(2);
	new szTeam[][] = 
	{
		"JBM_ID_HUD_STATUS_TEXT_UNSIGNED", 
		"JBM_ID_HUD_STATUS_TEXT_PRISONER", 
		"JBM_ID_HUD_STATUS_TEXT_GUARD", 
		"JBM_ID_HUD_STATUS_TEXT_UNSIGNED"
	};
	new szName[32];
	get_user_name(iTarget, szName, charsmax(szName));
	if(g_iGlobalGame && g_iChiefId == id)
	{
		set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.8, 0, 0.0, 10.0, 0.0, 0.0, -1);
		ShowSyncHudMsg(id, g_iSyncStatusText, "%L^n%L^n%L", id, "JBM_ID_HUD_STATUS_TEXT", id, szTeam[g_iUserTeam[iTarget]], szName, get_user_health(iTarget), get_user_armor(iTarget), g_iUserMoney[iTarget], id, "JBM_ID_HUD_STATUS_LEVEL", g_iLevel[iTarget][0], g_iExpTime[iTarget], g_iLevelCvars[EXP_NEED],id, g_szRankName[g_iLevel[iTarget][1]], id, "JBM_ID_HUD_STATUS_ROLE", id, g_iGlobalGame == 1 ? g_szMafiaRoleName[g_iUserRoleMafia[iTarget]] : g_szDjixadRoleName[g_iUserRoleDjixad[iTarget]]);
	}
	else
	{
		set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.8, 0, 0.0, 10.0, 0.0, 0.0, -1);
		ShowSyncHudMsg(id, g_iSyncStatusText, "%L^n%L", id, "JBM_ID_HUD_STATUS_TEXT", id, szTeam[g_iUserTeam[iTarget]], szName, get_user_health(iTarget), get_user_armor(iTarget), g_iUserMoney[iTarget], id, "JBM_ID_HUD_STATUS_LEVEL", g_iLevel[iTarget][0], g_iExpTime[iTarget], g_iLevelCvars[EXP_NEED],id, g_szRankName[g_iLevel[iTarget][1]]);
	}

	if(g_iAllCvars[MONEY_STEAL] && IsValidPlayer(iTarget) && isSetBit(g_iBitUserAlive, iTarget) && get_user_button(id) & IN_USE)
	{
		if(g_iUserTeam[id] == 1 && g_iUserTeam[id] == g_iUserTeam[iTarget] && !task_exists(id+TASK_STEAL_MONEY))
		{
			UTIL_BarTime(id, g_iAllCvars[MONEY_STEAL_TIME]);
			new iArg[1]; iArg[0] = iTarget;
			set_task(float(g_iAllCvars[MONEY_STEAL_TIME]), "jbm_steal_user_money", id+TASK_STEAL_MONEY, iArg, sizeof(iArg)); 
		}
	}
}

public jbm_steal_user_money(const iTarget[], pPlayer)
{
	pPlayer -= TASK_STEAL_MONEY;
	if(isSetBit(g_iBitUserAlive, iTarget[0]))
	{
		new szName[2][32]; get_user_name(pPlayer, szName[0], charsmax(szName[])); get_user_name(iTarget[0], szName[1], charsmax(szName[])); 
		if(g_iLevel[iTarget[0]][1] >= g_iLevel[pPlayer][1]) { UTIL_SayText(pPlayer, "!y[!gJBM!y] Погоняло игрока !t%s !yбольше вашего или такое же.", szName[1]); return PLUGIN_HANDLED; }
		new iStealMoney = floatround(g_iUserMoney[iTarget[0]] * 0.10, floatround_ceil);
		jbm_set_user_money(iTarget[0], g_iUserMoney[iTarget[0]] - iStealMoney, 1);
		jbm_set_user_money(pPlayer, g_iUserMoney[pPlayer] + iStealMoney, 1);
		UTIL_SayText(0, "!y[!gJBM!y] Воришка !t%s !yобчистил корманы !g%s !yна !t%d$!y.", szName[0], szName[1], iStealMoney);
	}
	return PLUGIN_HANDLED;
}

public Event_StatusValueHide(id) 
{
	if(task_exists(id+TASK_STEAL_MONEY)) { UTIL_BarTime(id, 0); remove_task(id+TASK_STEAL_MONEY); }
	ClearSyncHud(id, g_iSyncStatusText);
}

/* < Игровые события < *///}

/* > Консольные команды > *///{
INIT_CMDS()
{
	for(new i, szBlockCmd[][] = { "jointeam", "joinclass", "radio1", "radio2" }; i < sizeof szBlockCmd; i++) register_clcmd(szBlockCmd[i], "Command_Block");

	register_clcmd("radio3", 			"Command_Radio3");
	register_clcmd("amxmodmenu", 		"Command_AmxModMenu");
	register_clcmd("chooseteam", 		"Command_ChooseTeam");
	register_clcmd("menuselect", 		"Command_MenuSelect");
	register_clcmd("money_transfer", 	"Command_MoneyTransfer");
	register_clcmd("bet_money", 		"Command_BetMoneySet");
	register_clcmd("countdown_choose", 	"Command_CountdownTime");
	register_clcmd("drop", 				"Command_Drop");
	register_clcmd("say", 				"Command_HookSay");
	register_clcmd("say_team", 			"Command_HookSay");
	register_clcmd("set_user_level",	"Command_SetLevel");
	register_clcmd("set_user_money",	"Command_SetMoney");
	register_clcmd("set_user_arg",		"Command_SetArg");
	register_clcmd("+fly",              "Command_FlyOn");
	register_clcmd("-fly",              "Command_FlyOff");
}

public Command_Block(id) return PLUGIN_HANDLED;

public Command_Radio3(id)
{
	if(g_iUserTeam[id] == 1 && isSetBit(g_iBitLatchkey, id))
	{
		new iTarget, iBody;
		get_user_aiming(id, iTarget, iBody, 30);
		if(pev_valid(iTarget))
		{
			new szClassName[32];
			pev(iTarget, pev_classname, szClassName, charsmax(szClassName));
			if(szClassName[5] == 'd' && szClassName[6] == 'o' && szClassName[7] == 'o' && szClassName[8] == 'r') dllfunc(DLLFunc_Use, iTarget, id);
			else UTIL_SayText(id, "!y[!gJBM!y] %L", id, "JBM_CHAT_ID_LATCHKEY_ERROR_DOOR");
		}
		else UTIL_SayText(id, "!y[!gJBM!y] %L", id, "JBM_CHAT_ID_LATCHKEY_ERROR_DOOR");
	}
	return PLUGIN_HANDLED;
}

public Command_AmxModMenu(id) 
{
	if(isSetBit(g_iBitUserAdmin, id)) return Open_AmxModMenu(id);
	return PLUGIN_HANDLED;
}

public Command_ChooseTeam(id)
{
	if(jbm_menu_blocked(id)) return PLUGIN_HANDLED;
	switch(g_iUserTeam[id])
	{
		case 1: Open_MainPnMenu(id);
		case 2: 
		{
			if(g_iBitKilledUsers[id]) return Open_KilledUsersMenu(id, g_iMenuPosition[id] = 0);
			Open_MainGrMenu(id);
		}
		default: Open_ChooseTeamMenu(id);
	}
	return PLUGIN_HANDLED;
}

public Command_MenuSelect(id) 
{
	if(isSetBit(g_iBitSoundMenu, id)) client_cmd(id, "spk ^"%s^"", g_szSounds[MENU_SOUND]);
}

public Command_MoneyTransfer(id, iTarget, iMoney)
{
	if(!iTarget)
	{
		new szArg1[3], szArg2[7];
		read_argv(1, szArg1, charsmax(szArg1));
		read_argv(2, szArg2, charsmax(szArg2));
		if(!is_str_num(szArg1) || !is_str_num(szArg2))
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_ERROR_PARAMETERS");
			return PLUGIN_HANDLED;
		}
		iTarget = str_to_num(szArg1);
		iMoney = str_to_num(szArg2);
	}
	if(id == iTarget || !IsValidPlayer(iTarget) || isNotSetBit(g_iBitUserConnected, iTarget)) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_UNKNOWN_PLAYER");
	else if(g_iUserMoney[id] < iMoney) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_SUFFICIENT_FUNDS");
	else if(iMoney <= 0) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_MIN_AMOUNT_TRANSFER");
	else
	{
		jbm_set_user_money(iTarget, g_iUserMoney[iTarget] + iMoney, 1);
		jbm_set_user_money(id, g_iUserMoney[id] - iMoney, 1);
		new szName[32], szNameTarget[32];
		get_user_name(id, szName, charsmax(szName));
		get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
		UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_MONEY_TRANSFER", szName, iMoney, szNameTarget);
	}
	return PLUGIN_HANDLED;
}

public Command_BetMoneySet(id, iMoney)
{
	if(isSetBit(g_iBitUserBet, id) || !g_iDuelStatus) return PLUGIN_HANDLED;
	new szArg[7];
	read_argv(1, szArg, charsmax(szArg));
	if(!is_str_num(szArg))
	{
		UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_ERROR_PARAMETERS");
		return PLUGIN_HANDLED;
	}
	iMoney = str_to_num(szArg);
	
	if(g_iUserMoney[id] < iMoney) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_SUFFICIENT_FUNDS");
	else if(iMoney <= 0) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_MIN_AMOUNT_BET");
	else 
	{
		g_iUserBet[id] = iMoney;
		return Open_BetMenu(id);
	}
	return PLUGIN_HANDLED;
}

public Command_CountdownTime(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id) || task_exists(TASK_COUNT_DOWN_TIMER)) return PLUGIN_HANDLED;
	new szArg[4];
	read_argv(1, szArg, charsmax(szArg));
	if(!is_str_num(szArg))
	{
		UTIL_SayText(id, "!y[!gJBM!y]!y Это должно быть число!");
		return Open_ChiefSoundMenu(id);
	}
	else if(str_to_num(szArg) <= 0) UTIL_SayText(id, "!y[!gJBM!y]!y Таймер не может быть меньше !t0");
	else
	{
		client_cmd(0, "stopsound");
		g_iCountDown = str_to_num(szArg) + 1;
		set_task(1.0, "jbm_count_down_timer", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
	}
	return PLUGIN_HANDLED;
}

public Command_Drop(id)
{
	if(isNotSetBit(g_iBitUserDuel, id) && g_iUserRoleDjixad[id] == 5 && g_iGlobalGame == 2 && !task_exists(TASK_INVISIBLE_HAT+id) && g_iLastInvis[id] <= get_systime())
	{
		g_iLastInvis[id] = get_systime(30);
		setBit(g_iBitInvisibleHat, id);
		UTIL_SayText(id, "!y[!gJBM!y] Невидимость активирована. У вас есть 10 секунд.");
		jbm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
		set_task(10.0, "jbm_remove_invisible_hat", id+TASK_INVISIBLE_HAT);
		return PLUGIN_HANDLED;
	}
	if(isSetBit(g_iBitUserDuel, id) || (g_iGlobalGame && id != g_iChiefId)) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

native jbm_get_lang(id);
public Command_HookSay(id)
{
	new szBuffer[256];
	read_args(szBuffer, charsmax(szBuffer));
	remove_quotes(szBuffer);
	if(g_iGlobalGame == 1)
	{
		if(equal(szBuffer, "/", 1) || g_iUserTeam[id] == 2) return PLUGIN_CONTINUE;
		if(g_iUserRoleMafia[id] == MAFIA && equal(szBuffer, "!", 1))
		{
			new szName[32], szTranslitedText[128];
			if(jbm_get_lang(id))
			{
				jbm_translate(szTranslitedText, charsmax(szTranslitedText), szBuffer);
				copy(szBuffer, charsmax(szBuffer), szTranslitedText);
			}
			get_user_name(id, szName, charsmax(szName));
			for(new i = 1; i <= g_iMaxPlayers; i++) if(g_iUserRoleMafia[i] == MAFIA || i == g_iChiefId) UTIL_SayText(i, "!y[!gCHAT MAFIA!y] | !t%s !y: !g%s", szName, szBuffer);
			return PLUGIN_HANDLED;
		}
		else if(g_iUserRoleMafia[id] != MAFIA && equal(szBuffer, "!", 1))
		{
			UTIL_SayText(id, "!y[!gMAFIA!y]!y Вы не имеете доступа к данному чату.");
			return PLUGIN_HANDLED;
		}
		if(isSetBit(g_iBitUserAlive, id) && equal(szBuffer, "*", 1))
		{
			new szName[32], szTranslitedText[128];
			if(jbm_get_lang(id))
			{
				jbm_translate(szTranslitedText, charsmax(szTranslitedText), szBuffer);
				copy(szBuffer, charsmax(szBuffer), szTranslitedText);
			}
			get_user_name(id, szName, charsmax(szName));
			UTIL_SayText(id, "!g[!yРоль: %L!g] !y| !t%s !y: %s", id, g_szMafiaRoleName[g_iUserRoleMafia[id]], szName, szBuffer);
			UTIL_SayText(g_iChiefId, "!g[!yРоль: %L!g] !y| !t%s !y: %s", LANG_MODE, g_szMafiaRoleName[g_iUserRoleMafia[id]], szName, szBuffer);
			return PLUGIN_HANDLED;
		}
		if(!g_iMafiaChat) 
		{
			UTIL_SayText(id, "!y[!gMAFIA!y]!y Чат не доступен.");
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

public Command_SetLevel(id, iTarget, iLevel)
{
	if(isNotSetBit(g_iBitUserAC, id)) return PLUGIN_HANDLED;
	if(!iTarget)
	{
		new szArg1[3], szArg2[7];
		read_argv(1, szArg1, charsmax(szArg1));
		read_argv(2, szArg2, charsmax(szArg2));
		if(!is_str_num(szArg1) || !is_str_num(szArg2))
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_ERROR_PARAMETERS");
			return PLUGIN_HANDLED;
		}
		iTarget = str_to_num(szArg1);
		iLevel = str_to_num(szArg2);
	}
	if(!IsValidPlayer(iTarget) || isNotSetBit(g_iBitUserConnected, iTarget)) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_UNKNOWN_PLAYER");
	else if(iLevel <= 0) UTIL_SayText(id, "!y[!gJBM!y]!y Уровень должен быть не отрицательым.");
	else
	{
		jbm_set_user_level(iTarget, iLevel, 0);
		new szName[32], szNameTarget[32];
		get_user_name(id, szName, charsmax(szName));
		get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
		UTIL_SayText(0, "!y[!gJBM!y]!y !g%s !yустановил игроку !t%s !y уровень: !g%d!y.", szName, szNameTarget, iLevel);
	}
	return PLUGIN_HANDLED;
}

public Command_SetMoney(id, iTarget, iMoney)
{
	if(isNotSetBit(g_iBitUserAC, id)) return PLUGIN_HANDLED;
	if(!iTarget)
	{
		new szArg1[3], szArg2[7];
		read_argv(1, szArg1, charsmax(szArg1));
		read_argv(2, szArg2, charsmax(szArg2));
		if(!is_str_num(szArg1) || !is_str_num(szArg2))
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_ERROR_PARAMETERS");
			return PLUGIN_HANDLED;
		}
		iTarget = str_to_num(szArg1);
		iMoney = str_to_num(szArg2);
	}
	if(!IsValidPlayer(iTarget) || isNotSetBit(g_iBitUserConnected, iTarget)) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_UNKNOWN_PLAYER");
	else if(iMoney <= 0) UTIL_SayText(id, "!y[!gJBM!y]!y Баланс должен быть не отрицательым.");
	else
	{
		jbm_set_user_money(iTarget, iMoney, 0);
		new szName[32], szNameTarget[32];
		get_user_name(id, szName, charsmax(szName));
		get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
		UTIL_SayText(0, "!y[!gJBM!y]!y !g%s !yустановил игроку !t%s !y баланс: !g%d!y.", szName, szNameTarget, iMoney);
	}
	return PLUGIN_HANDLED;
}

public Command_SetArg(id, iHealth)
{
	if(isNotSetBit(g_iBitUserAC, id)) return PLUGIN_HANDLED;
	new szArg[6]; read_argv(1, szArg, charsmax(szArg));
	if(!is_str_num(szArg))
	{
		UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_ERROR_PARAMETERS");
		return PLUGIN_HANDLED;
	}
	iHealth = str_to_num(szArg);
	g_iMenuArg[id] = iHealth;
	if(g_iMenuArg[id] > 0) return Open_WhoGetIt(id);
	return PLUGIN_HANDLED;
}

public Command_FlyOn(id)
{
	if(isNotSetBit(g_iBitUserAnime, id))
	{
		UTIL_SayText(id, "!y[!gError!y] У вас недостаточно прав для использования !tFLY");
		return PLUGIN_HANDLED;
	}
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	
	if(g_bHookStatus || g_iDayMode == DAYMODE_GAMES || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserWanted, id) || isSetBit(g_iBitUserSoccer, id) || isSetBit(g_iBitUserDuel, id) || task_exists(id+TASK_HOOK_THINK)) 
	{	
	    UTIL_SayText(id, "!y[!gError!y] В данный момент недоступен !tFLY");
		return PLUGIN_HANDLED;
	}
	if(g_iModeFly[id]) ///Проверка на режим FLY 
	{
		Fly_task(id+TASK_FLY_PLAYER);
	    set_task(0.1, "Fly_task", id+TASK_FLY_PLAYER, _, _, "b");
		emit_sound(id, CHAN_STATIC, g_szSounds[DJUMP_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	return PLUGIN_HANDLED;
}

public Command_FlyOff(id)
{
    if(g_iModeFly[id])
	{
	    if(task_exists(id+TASK_FLY_PLAYER))
	    remove_task(id+TASK_FLY_PLAYER);
	}
	UTIL_create_killbeam(id);
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

/* < Консольные команды < *///}

/* > Меню > *///{
const PLAYERS_PER_PAGE = 7;
#define REG_MENU(%0,%1,%2) register_menucmd(register_menuid(%0), (%2), %1)

INIT_MENU()
{
	REG_MENU("Open_ChooseTeamMenu",				"Close_ChooseTeamMenu",				(1<<0|1<<1|1<<5|1<<8|1<<9));
#if defined OLD_WEAPON_SYSTEM
	REG_MENU("Open_GuardWeaponsMenu",			"Close_GuardWeaponsMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
#endif
	REG_MENU("Open_MainPnMenu",					"Close_MainPnMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_MainGrMenu",					"Close_MainGrMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ShopPrisonersMenu_1", 		"Close_ShopPrisonersMenu_1",		(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ShopPrisonersMenu_2", 		"Close_ShopPrisonersMenu_2",		(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ShopPrisonersMenu_3", 		"Close_ShopPrisonersMenu_3",		(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ShopPrisonersMenu_4", 		"Close_ShopPrisonersMenu_4",		(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ShopPrisonersMenu_VIP", 		"Close_ShopPrisonersMenu_VIP",		(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_PrankPrisonerMenu",			"Close_PrankPrisonerMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ShopGuardMenu_1",			"Close_ShopGuardMenu_1",			(1<<0|1<<1|1<<2|1<<8|1<<9));
	REG_MENU("Open_ShopGuardMenu_2",			"Close_ShopGuardMenu_2",			(1<<0|1<<1|1<<2|1<<3|1<<8|1<<9));
	REG_MENU("Open_ShopChiefMenu",				"Close_ShopChiefMenu",				(1<<0|1<<1|1<<2|1<<3|1<<8|1<<9));
	REG_MENU("Open_MoneyTransferMenu",			"Close_MoneyTransferMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_MoneyAmountMenu",			"Close_MoneyAmountMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_CostumesMenu",				"Close_CostumesMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_CheckGuardMenu",				"Close_CheckGuardMenu",				(1<<0|1<<1));
	REG_MENU("Open_ChiefMenu",					"Close_ChiefMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_PunishGuardMenu",			"Close_PunishGuardMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_TransferChiefMenu",			"Close_TransferChiefMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ChiefSoundMenu",				"Close_ChiefSoundMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_MiniGameMenu",				"Close_MiniGameMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_GlobalGameMenu",				"Close_GlobalGameMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9));
	REG_MENU("Open_WeaponsMenu",				"Close_WeaponsMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_TeamMenu",					"Close_TeamMenu",					(1<<0|1<<1|1<<2|1<<3|1<<8|1<<9));
	REG_MENU("Open_SoccerMenu",					"Close_SoccerMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_SoccerTeamMenu", 			"Close_SoccerTeamMenu",				(1<<0|1<<1|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_SoccerScoreMenu", 			"Close_SoccerScoreMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9));
	REG_MENU("Open_SoccerBallSpeedMenu",		"Close_SoccerBallSpeedMenu",		(1<<0|1<<1|1<<2|1<<3|1<<8|1<<9));
	REG_MENU("Open_SmotrGlobalMenu",			"Close_SmotrGlobalMenu",			(1<<0|1<<1|1<<8|1<<9));
	REG_MENU("Open_MafiaMenu", 					"Close_MafiaMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_MafiaRoleMenu", 				"Close_MafiaRoleMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_GiveRoleMafia", 				"Close_GiveRoleMafia",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_VoteMafia", 					"Close_VoteMafia",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Show_MafiaTimer", 				"Handle_MafiaTimer",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_DjixadMenu", 				"Close_DjixadMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9));
	REG_MENU("Open_DjixadRoleMenu_1", 			"Close_DjixadRoleMenu_1",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_DjixadRoleMenu_2", 			"Close_DjixadRoleMenu_2",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9));
	REG_MENU("Open_GiveRoleDjixad", 			"Close_GiveRoleDjixad",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_BuryPlayerDjixad", 			"Close_BuryPlayerDjixad",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_BurnPlayerDjixad", 			"Close_BurnPlayerDjixad",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ChiefTwoMenu", 				"Close_ChiefTwoMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9));
	REG_MENU("Open_FreeDayControlMenu", 		"Close_FreeDayControlMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_VoiceControlMenu", 			"Close_VoiceControlMenu",			(1<<0|1<<1|1<<2|1<<8|1<<9));
	REG_MENU("Open_VoiceControlIdMenu", 		"Close_VoiceControlIdMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_TakeWantedMenu", 			"Close_TakeWantedMenu",				(1<<0|1<<1|1<<8|1<<9));
	REG_MENU("Open_TakeWantedIdMenu", 			"Close_TakeWantedIdMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_TreatPrisonerMenu", 			"Close_TreatPrisonerMenu",			(1<<0|1<<1|1<<2|1<<8|1<<9));
	REG_MENU("Open_TreatPrisonerIdMenu", 		"Close_TreatPrisonerIdMenu",		(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_PrisonersDivideColorMenu",	"Close_PrisonersDivideColorMenu",	(1<<0|1<<1|1<<2|1<<8|1<<9));
	REG_MENU("Open_DuelPnMenu",					"Close_DuelPnMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ChooseDuelPnMenu",			"Close_ChooseDuelPnMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_KillReasonsMenu", 			"Close_KillReasonsMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_KilledUsersMenu", 			"Close_KilledUsersMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_LastPrisonerMenu", 			"Close_LastPrisonerMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_ChoiceDuelPrizeWinner",		"Close_ChooseDuelPrizeWinner",		(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_DuelMenu", 					"Close_DuelMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_ChoiceDuelMenu", 			"Close_ChoiceDuelMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_DuelUsersMenu", 				"Close_DuelUsersMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_BetMenu", 					"Close_BetMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<9));
	REG_MENU("Open_ManageMenu", 				"Close_ManageMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9));
	REG_MENU("Open_OrderSoundMenu", 			"Close_OrderSoundMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_FunMenu",					"Close_FunMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_AnimationMenu",				"Close_AnimationMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9));
	REG_MENU("Open_DonateMenu", 				"Close_DonateMenu", 				1023);
	REG_MENU("Open_VipMenu", 					"Close_VipMenu", 					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9));
	REG_MENU("Open_UltraVipMenu", 				"Close_UltraVipMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_UVRespawnMenu", 				"Close_UVRespawnMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_AdminMenu", 					"Close_AdminMenu", 					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_AmxModMenu", 				"Close_AmxModMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_BlockedGuardMenu",			"Close_BlockedGuardMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_RespawnPlayerMenu",			"Close_RespawnPlayerMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_PredatorMenu",				"Close_PredatorMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9));
	REG_MENU("Open_PredatorVoiceControlMenu",	"Close_PredatorVoiceControlMenu",	(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_BossMenu",					"Close_BossMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9));
	REG_MENU("Open_HookControlMenu",			"Close_HookControlMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_ACPMenu",					"Close_ACPMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_AnimeMenu",					"Close_AnimeMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_DayMenu",					"Close_DayMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_StartGameMenu",				"Close_StartGameMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_MusicMenu",					"Close_MusicMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_GiveLevelMenu",				"Close_GiveLevelMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_GiveMoneyMenu",				"Close_GiveMoneyMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_TypeGravityMenu",			"Close_TypeGravityMenu",			(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_TypeSpeedMenu",				"Close_TypeSpeedMenu",				(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_WhoGetIt",					"Close_WhoGetIt",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_GiveIdMenu",					"Close_GiveIdMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9));
	REG_MENU("Open_TrailMenu",					"Close_TrailMenu",					(1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9));
#if !defined INFO_MOTD
	REG_MENU("Open_InfoMenu",					"Close_InfoMenu",					(1<<8|1<<9));
#endif
}

Open_ChooseTeamMenu(id)
{
	if(jbm_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n", id, "JBM_MENU_TEAM_TITLE", g_iAllCvars[TEAM_BALANCE]);
	if(g_iUserTeam[id] != 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
	if((isNotSetBit(g_iBitUserBlockedGuard, id) && g_iUserTeam[id] != 2 && ((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2] && !g_iBlockBoss[0]))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 2, id, "JBM_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %s^n^n", id, "JBM_KEY", 2, id, "JBM_MENU_TEAM_GUARDS", g_iPlayersNum[2], isSetBit(g_iBitUserBlockedGuard, id) ? "\r[\d Блокировка \r]" : "");
	if(g_iUserTeam[id] != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n^n^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_TEAM_SPECTATOR");
		iBitKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n^n^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_TEAM_SPECTATOR");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ChooseTeamMenu");
}

public Close_ChooseTeamMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			if(g_iUserTeam[id] == 1) { return Open_ChooseTeamMenu(id); }
			if(!jbm_set_user_team(id, 1)) 
			{
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			if(g_iUserTeam[id] == 2) { return Open_ChooseTeamMenu(id); }
			if(isNotSetBit(g_iBitUserBlockedGuard, id) && ((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2])
			{
				if(!jbm_set_user_team(id, 2)) { return PLUGIN_HANDLED; }
			}
			else { return Open_ChooseTeamMenu(id); }
		}
		case 5:
		{
			if(g_iUserTeam[id] == 3)		{ return Open_ChooseTeamMenu(id); }
			if(!jbm_set_user_team(id, 3))	{ return PLUGIN_HANDLED; }
		}
	}
	return PLUGIN_HANDLED;
}

#if defined OLD_WEAPON_SYSTEM
Open_GuardWeaponsMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512];
	iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<9),	// Это не быдло-код, а запска
	iLen = formatex(szMenu[iLen], charsmax(szMenu), "\y[\dJBM\y] \wМеню выбора оружия^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wAK-47^n", id, "JBM_KEY", 1);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wM4A1^n", id, "JBM_KEY", 2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wAWP^n", id, "JBM_KEY", 3);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wXM1014^n^n", id, "JBM_KEY", 4);
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_GuardWeaponsMenu");
}

public Close_GuardWeaponsMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || iKey == 9 || g_iUserTeam[id] != 2 || isNotSetBit(g_iBitUserAlive, id)) { return PLUGIN_HANDLED; }
	drop_user_weapons(id, 1); drop_user_weapons(id, 0);
	switch(iKey)
	{
		default:
		{
			new const szWeaponName[][] = {"weapon_ak47", "weapon_m4a1", "weapon_awp", "weapon_xm1014", "weapon_deagle"};
			new const iWeaponId[] = {CSW_AK47, CSW_M4A1, CSW_AWP, CSW_XM1014, CSW_DEAGLE};
			fm_give_item(id, szWeaponName[iKey]);
			fm_set_user_bpammo(id, iWeaponId[iKey], 250);
			fm_give_item(id, szWeaponName[4]);
			fm_set_user_bpammo(id, iWeaponId[4], 250);
		}
	}
	fm_give_item(id, "item_kevlar");
	return PLUGIN_HANDLED;
}
#endif

Open_MainPnMenu(id)
{
	new szMenu[512], iBitKeys = (1<<1|1<<4|1<<5|1<<6|1<<7|1<<9), iUserAlive = isSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_MAIN_TITLE");
	if(iUserAlive && (g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isNotSetBit(g_iBitUserDuel, id) || g_iGlobalGame)
	{
		if(!g_iBlockBoss[1])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAIN_SHOP");
			iBitKeys |= (1<<0);
		} 
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAIN_SHOP", id, "JBM_MENU_NOT_AVAILABLE");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAIN_SHOP", id, "JBM_MENU_NOT_AVAILABLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_MAIN_MONEY_TRANSFER");
	if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && g_iCostumesListSize && isNotSetBit(g_iBitUserDuel, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MAIN_COSTUMES");
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MAIN_COSTUMES");
	
	if(id == g_iLastPnId && iUserAlive)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAIN_LAST_PN");
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAIN_LAST_PN");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_MAIN_TEAM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_MAIN_MANAGE_SOUND");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_MAIN_OTHER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_MAIN_FUN");
	if(~jbm_get_user_donate(id) & (1<<0))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \r%L^n", id, "JBM_KEY", 9, id, "JBM_MENU_MAIN_DONATE");
		iBitKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 9, id, "JBM_MENU_MAIN_DONATE");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MainPnMenu");
}

public Close_MainPnMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitUserDuel, id) && !g_iGlobalGame) return Open_ShopPrisonersMenu_1(id);
		case 1: return Open_MoneyTransferMenu(id, g_iMenuPosition[id] = 0);
		case 2: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) return Open_CostumesMenu(id, g_iMenuPosition[id] = 0);
		case 3: if(id == g_iLastPnId && isSetBit(g_iBitUserAlive, id)) return Open_LastPrisonerMenu(id);
		case 4: return Open_ChooseTeamMenu(id);
		case 5: return Open_ManageMenu(id);
		case 6: return Open_InfoMenu(id);
		case 7: return Open_FunMenu(id);
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_MainPnMenu(id);
}

Open_MainGrMenu(id)
{
	new szMenu[512], iBitKeys = (1<<1|1<<4|1<<5|1<<6|1<<7|1<<9), iUserAlive = isSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_MAIN_TITLE");
	if(iUserAlive && (g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isNotSetBit(g_iBitUserDuel, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAIN_SHOP");
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAIN_SHOP", id, "JBM_MENU_NOT_AVAILABLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_MAIN_MONEY_TRANSFER");
	if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && g_iCostumesListSize && isNotSetBit(g_iBitUserDuel, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MAIN_COSTUMES");
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MAIN_COSTUMES");
	if(iUserAlive && (g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE))
	{
		if(id == g_iChiefId)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAIN_CHIEF");
			iBitKeys |= (1<<3);
		}
		else if(g_iChiefStatus != 1 && (g_iChiefIdOld != id || g_iChiefStatus != 0) && isNotSetBit(g_iBitUserDuel, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAIN_TAKE_CHIEF");
			iBitKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAIN_TAKE_CHIEF");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAIN_TAKE_CHIEF");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_MAIN_TEAM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_MAIN_MANAGE_SOUND");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_MAIN_OTHER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_MAIN_FUN");
	if(~jbm_get_user_donate(id) & (1<<0))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \r%L^n", id, "JBM_KEY", 9, id, "JBM_MENU_MAIN_DONATE");
		iBitKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 9, id, "JBM_MENU_MAIN_DONATE");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MainGrMenu");
}

public Close_MainGrMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitUserDuel, id)) return Open_ShopGuardMenu_1(id);
		case 1: return Open_MoneyTransferMenu(id, g_iMenuPosition[id] = 0);
		case 2: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) return Open_CostumesMenu(id, g_iMenuPosition[id] = 0);
		case 3:
		{
			if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isSetBit(g_iBitUserAlive, id))
			{
				if(id == g_iChiefId) return Open_ChiefMenu(id);
				if(g_iChiefStatus != 1 && (g_iChiefIdOld != id || g_iChiefStatus != 0) && jbm_set_user_chief(id) && isNotSetBit(g_iBitUserDuel, id))
				{
					if(jbm_get_players_count(0, 2) >= g_iLevelCvars[PLAYERS_NEED]) g_iExpName[id] += 2;
					g_iChiefIdOld = id;
					set_pev(id, pev_health, float(g_iPlayersParams[CHIEF_HP]));
					if(g_iPlayersNum[2] >= 2) return Open_CheckGuardMenu(id);
					else return Open_ChiefMenu(id);
				}
			}
		}
		case 4: return Open_ChooseTeamMenu(id);
		case 5: return Open_ManageMenu(id);
		case 6: return Open_InfoMenu(id);
		case 7: return Open_FunMenu(id);
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_MainGrMenu(id);
}

Open_ShopPrisonersMenu_1(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	jbm_set_user_discount(id);
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_PRISONERS_TITLE", id, "JBM_MENU_SHOP_PRISONERS_WEAPONS", g_iUserMoney[id], g_iUserDiscount[id]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
	
	new iPriceKatana = jbm_get_price_discount(id, g_iShopCvars[KATANA]);
	if(isNotSetBit(g_iBitKatana, id))
	{
		if(iPriceKatana <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_WEAPONS_KATANA", iPriceKatana);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_WEAPONS_KATANA", iPriceKatana);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_WEAPONS_KATANA", iPriceKatana);
	new iPriceMachete = jbm_get_price_discount(id, g_iShopCvars[MACHETE]);
	if(isNotSetBit(g_iBitMachete, id))
	{
		if(iPriceMachete <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_WEAPONS_MACHETE", iPriceMachete);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_WEAPONS_MACHETE", iPriceMachete);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_WEAPONS_MACHETE", iPriceMachete);
	new iPriceChainsaw = jbm_get_price_discount(id, g_iShopCvars[CHAINSAW]);
	if(isNotSetBit(g_iBitChainsaw, id))
	{
		if(iPriceChainsaw <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_WEAPONS_CHAINSAW", iPriceChainsaw);
			iBitKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_WEAPONS_CHAINSAW", iPriceChainsaw);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_WEAPONS_CHAINSAW", iPriceChainsaw);

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \r%L \w| \d%L \w| \d%L \w| \d%L \w| \y*%L*", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_PRISONERS_WEAPONS", id, "JBM_MENU_SHOP_PRISONERS_ITEMS", id, "JBM_MENU_SHOP_PRISONERS_SKILLS", id, "JBM_MENU_SHOP_PRISONERS_OTHER", id, "JBM_MENU_SHOP_PRISONERS_VIP");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopPrisonersMenu_1");
}

public Close_ShopPrisonersMenu_1(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceKatana = jbm_get_price_discount(id, g_iShopCvars[KATANA]);
			if(isNotSetBit(g_iBitKatana, id) && iPriceKatana <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceKatana, 1);
				clearBit(g_iBitMachete, id);
				clearBit(g_iBitChainsaw, id);
				clearBit(g_iBitPerc, id);
				setBit(g_iBitKatana, id);
				setBit(g_iBitWeaponStatus, id);
				if(get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0)
					{
						ExecuteHamB(Ham_Item_Deploy, iActiveItem);
						UTIL_WeaponAnimation(id, 3);
					}
				}
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceMachete = jbm_get_price_discount(id, g_iShopCvars[MACHETE]);
			if(isNotSetBit(g_iBitMachete, id) && iPriceMachete <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceMachete, 1);
				clearBit(g_iBitKatana, id);
				clearBit(g_iBitChainsaw, id);
				clearBit(g_iBitPerc, id);
				setBit(g_iBitMachete, id);
				setBit(g_iBitWeaponStatus, id);
				if(get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0)
					{
						ExecuteHamB(Ham_Item_Deploy, iActiveItem);
						UTIL_WeaponAnimation(id, 3);
					}
				}
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceChainsaw = jbm_get_price_discount(id, g_iShopCvars[CHAINSAW]);
			if(isNotSetBit(g_iBitChainsaw, id) && iPriceChainsaw <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceChainsaw, 1);
				clearBit(g_iBitKatana, id);
				clearBit(g_iBitMachete, id);
				clearBit(g_iBitPerc, id);
				setBit(g_iBitChainsaw, id);
				setBit(g_iBitWeaponStatus, id);
				if(get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0)
					{
						ExecuteHamB(Ham_Item_Deploy, iActiveItem);
						UTIL_WeaponAnimation(id, 3);
					}
				}
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Open_ShopPrisonersMenu_2(id);
		case 9: return Open_MainPnMenu(id);
	}
	return Open_ShopPrisonersMenu_1(id);
}

Open_ShopPrisonersMenu_2(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_PRISONERS_TITLE", id, "JBM_MENU_SHOP_PRISONERS_ITEMS", g_iUserMoney[id], g_iUserDiscount[id]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
	
	new iPriceFlashbang = jbm_get_price_discount(id, g_iShopCvars[FLASHBANG]);
	if(!user_has_weapon(id, CSW_FLASHBANG))
	{
		if(iPriceFlashbang <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_ITEMS_FLASHBANG", iPriceFlashbang);
	new iPriceKokain = jbm_get_price_discount(id, g_iShopCvars[KOKAIN]);
	if(isNotSetBit(g_iBitKokain, id))
	{
		if(iPriceKokain <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_ITEMS_KOKAIN", iPriceKokain);
	new iPriceStimulator = jbm_get_price_discount(id, g_iShopCvars[STIMULATOR]);
	if(get_user_health(id) < 200 && !task_exists(id+TASK_REMOVE_SYRINGE))
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
			iBitKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_ITEMS_STIMULATOR", iPriceStimulator);
	new iPriceArmor = jbm_get_price_discount(id, g_iShopCvars[ARMOR]);
	if(get_user_armor(id) == 0)
	{
		if(iPriceArmor <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
			iBitKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_ITEMS_ARMOR", iPriceArmor);
	new iPriceHeGrenade = jbm_get_price_discount(id, g_iShopCvars[HEGRENADE]);
	if(!user_has_weapon(id, CSW_HEGRENADE))
	{
		if(iPriceHeGrenade <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 5, id, "JBM_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
			iBitKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 5, id, "JBM_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 5, id, "JBM_MENU_SHOP_SKILLS_HEGRENADE", iPriceHeGrenade);
	new iPriceFrostNade = jbm_get_price_discount(id, g_iShopCvars[FROSTNADE]);
	if(!user_has_weapon(id, CSW_SMOKEGRENADE) && isNotSetBit(g_iBitFrostNade, id) && g_iFrostNade[id] != g_iShopCvars[FROSTNADE_LIMIT])
	{
		if(iPriceFrostNade <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \d[%d/%d] \y\R%d$^n^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_SHOP_ITEMS_FROST_GRENADE", g_iFrostNade[id], g_iShopCvars[FROSTNADE_LIMIT], iPriceFrostNade);
			iBitKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L [%d/%d] \R%d$^n^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_SHOP_ITEMS_FROST_GRENADE", g_iFrostNade[id], g_iShopCvars[FROSTNADE_LIMIT], iPriceFrostNade);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L [%d/%d] \R%d$^n^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_SHOP_ITEMS_FROST_GRENADE", g_iFrostNade[id], g_iShopCvars[FROSTNADE_LIMIT], iPriceFrostNade);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L \w| \r%L \w| \d%L \w| \d%L \w| \y*%L*", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_PRISONERS_WEAPONS", id, "JBM_MENU_SHOP_PRISONERS_ITEMS", id, "JBM_MENU_SHOP_PRISONERS_SKILLS", id, "JBM_MENU_SHOP_PRISONERS_OTHER", id, "JBM_MENU_SHOP_PRISONERS_VIP");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopPrisonersMenu_2");
}

public Close_ShopPrisonersMenu_2(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceFlashbang = jbm_get_price_discount(id, g_iShopCvars[FLASHBANG]);
			if(!user_has_weapon(id, CSW_FLASHBANG) && iPriceFlashbang <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceFlashbang, 1);
				fm_give_item(id, "weapon_flashbang");
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceKokain = jbm_get_price_discount(id, g_iShopCvars[KOKAIN]);
			if(isNotSetBit(g_iBitKokain, id) && iPriceKokain <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceKokain, 1);
				setBit(g_iBitKokain, id);
				jbm_set_syringe_model(id);
				UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_MENU_ID_KOKAIN");
				set_task(2.8, "jbm_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceStimulator = jbm_get_price_discount(id, g_iShopCvars[STIMULATOR]);
			if(get_user_health(id) < 200 && iPriceStimulator <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceStimulator, 1);
				jbm_set_syringe_model(id);
				set_task(1.3, "jbm_set_syringe_health", id+TASK_REMOVE_SYRINGE);
				set_task(2.8, "jbm_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceArmor = jbm_get_price_discount(id, g_iShopCvars[ARMOR]);
			if(get_user_armor(id) == 0 && iPriceArmor <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceArmor, 1);
				fm_give_item(id, "item_kevlar");
				return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
			new iPriceHeGrenade = jbm_get_price_discount(id, g_iShopCvars[HEGRENADE]);
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && iPriceHeGrenade <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceHeGrenade, 1);
				fm_give_item(id, "weapon_hegrenade");
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			new iPriceFrostNade = jbm_get_price_discount(id, g_iShopCvars[FROSTNADE]);
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && isNotSetBit(g_iBitFrostNade, id) && iPriceFrostNade <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceFrostNade, 1);
				setBit(g_iBitFrostNade, id);
				fm_give_item(id, "weapon_smokegrenade");
				g_iFrostNade[id]++;
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Open_ShopPrisonersMenu_3(id);
		case 9: return Open_MainPnMenu(id);
	}
	return Open_ShopPrisonersMenu_2(id);
}

Open_ShopPrisonersMenu_3(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_PRISONERS_TITLE", id, "JBM_MENU_SHOP_PRISONERS_SKILLS", g_iUserMoney[id], g_iUserDiscount[id]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
	
	new iPriceHingJump = jbm_get_price_discount(id, g_iShopCvars[HING_JUMP]);
	if(isNotSetBit(g_iBitHingJump, id))
	{
		if(iPriceHingJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_SKILLS_HING_JUMP", iPriceHingJump);
	new iPriceFastRun = jbm_get_price_discount(id, g_iShopCvars[FAST_RUN]);
	if(g_fUserSpeed[id] != 400.0)
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_SKILLS_FAST_RUN", iPriceFastRun);
	new iPriceRandomGlow = jbm_get_price_discount(id, g_iShopCvars[RANDOM_GLOW]);
	if(isNotSetBit(g_iBitRandomGlow, id))
	{
		if(iPriceRandomGlow <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
			iBitKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_SKILLS_RANDOM_GLOW", iPriceRandomGlow);
	new iPriceDoubleDamage = jbm_get_price_discount(id, g_iShopCvars[DOUBLE_DAMAGE]);
	if(isNotSetBit(g_iBitDoubleDamage, id))
	{
		if(iPriceDoubleDamage <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
			iBitKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_SKILLS_DOUBLE_DAMAGE", iPriceDoubleDamage);
	new iPriceLowGravity = jbm_get_price_discount(id, g_iShopCvars[LOW_GRAVITY]);
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 5, id, "JBM_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
			iBitKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 5, id, "JBM_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 5, id, "JBM_MENU_SHOP_SKILLS_LOW_GRAVITY", iPriceLowGravity);
	new iPriceDoubleJump = jbm_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP]);
	if(isNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 6, id, "JBM_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
			iBitKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 6, id, "JBM_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 6, id, "JBM_MENU_SHOP_SKILLS_DOUBLE_JUMP", iPriceDoubleJump);
	new iPriceAutoBhop = jbm_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
	if(isNotSetBit(g_iBitAutoBhop, id))
	{
		if(iPriceAutoBhop <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n^n", id, "JBM_KEY", 7, id, "JBM_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
			iBitKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n", id, "JBM_KEY", 7, id, "JBM_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n", id, "JBM_KEY", 7, id, "JBM_MENU_SHOP_SKILLS_AUTO_BHOP", iPriceAutoBhop);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L \w| \d%L \w| \r%L \w| \d%L \w| \y*%L*", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_PRISONERS_WEAPONS", id, "JBM_MENU_SHOP_PRISONERS_ITEMS", id, "JBM_MENU_SHOP_PRISONERS_SKILLS", id, "JBM_MENU_SHOP_PRISONERS_OTHER", id, "JBM_MENU_SHOP_PRISONERS_VIP");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopPrisonersMenu_3");
}

public Close_ShopPrisonersMenu_3(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceHingJump = jbm_get_price_discount(id, g_iShopCvars[HING_JUMP]);
			if(iPriceHingJump <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceHingJump, 1);
				setBit(g_iBitHingJump, id);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceFastRun = jbm_get_price_discount(id, g_iShopCvars[FAST_RUN]);
			if(iPriceFastRun <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceFastRun, 1);
				g_fUserSpeed[id] = 400.0; 
				ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceRandomGlow = jbm_get_price_discount(id, g_iShopCvars[RANDOM_GLOW]);
			if(iPriceRandomGlow <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceRandomGlow, 1);
				setBit(g_iBitRandomGlow, id);
				jbm_set_user_rendering(id, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), kRenderNormal, 0);
				jbm_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceDoubleDamage = jbm_get_price_discount(id, g_iShopCvars[DOUBLE_DAMAGE]);
			if(iPriceDoubleDamage <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceDoubleDamage, 1);
				setBit(g_iBitDoubleDamage, id);
				return PLUGIN_HANDLED;
			}
		}
		case 4:
		{
			new iPriceLowGravity = jbm_get_price_discount(id, g_iShopCvars[LOW_GRAVITY]);
			if(iPriceLowGravity <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceLowGravity, 1);
				set_pev(id, pev_gravity, 0.5);
				return PLUGIN_HANDLED;
			}
		}
		case 5:
		{
			new iPriceDoubleJump = jbm_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP]);
			if(iPriceDoubleJump <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceDoubleJump, 1);
				setBit(g_iBitDoubleJump, id);
				return PLUGIN_HANDLED;
			}
		}
		case 6:
		{
			new iPriceAutoBhop = jbm_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
			if(iPriceAutoBhop <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceAutoBhop, 1);
				setBit(g_iBitAutoBhop, id);
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Open_ShopPrisonersMenu_4(id);
		case 9: return Open_MainPnMenu(id);
	}
	return Open_ShopPrisonersMenu_3(id);
}

Open_ShopPrisonersMenu_4(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_PRISONERS_TITLE", id, "JBM_MENU_SHOP_PRISONERS_OTHER", g_iUserMoney[id], g_iUserDiscount[id]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
	
	new iPriceCloseCase = jbm_get_price_discount(id, g_iShopCvars[CLOSE_CASE]);
	if(isSetBit(g_iBitUserWanted, id))
	{
		if(iPriceCloseCase <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_OTHER_CLOSE_CASE", iPriceCloseCase);
	new iPriceFreeDay = jbm_get_price_discount(id, g_iShopCvars[FREE_DAY_SHOP]);
	if(g_iDayMode == DAYMODE_STANDART && isNotSetBit(g_iBitUserFree, id) && isNotSetBit(g_iBitUserWanted, id))
	{
		if(iPriceFreeDay <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_OTHER_FREE_DAY", iPriceFreeDay);
	new iPriceLotteryTicket = jbm_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET]);
	if(g_iLotteryPlayer[id] != g_iShopCvars[LOTTERY_LIMIT])
	{
		if(iPriceLotteryTicket <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \d[%d/%d] \y\R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_OTHER_LOTTERY_TICKET", g_iShopCvars[LOTTERY_CHANCE], g_iLotteryPlayer[id], g_iShopCvars[LOTTERY_LIMIT], iPriceLotteryTicket);
			iBitKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d[%d/%d] \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_OTHER_LOTTERY_TICKET", g_iShopCvars[LOTTERY_CHANCE], g_iLotteryPlayer[id], g_iShopCvars[LOTTERY_LIMIT], iPriceLotteryTicket);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d[%d/%d] \d\R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_OTHER_LOTTERY_TICKET", g_iShopCvars[LOTTERY_CHANCE], g_iLotteryPlayer[id], g_iShopCvars[LOTTERY_LIMIT], iPriceLotteryTicket);
	new iPricePrankPrisoner = jbm_get_price_discount(id, g_iShopCvars[PRANK_PRISONER]);
	if(g_iAlivePlayersNum[1] >= 2 && g_iPrank != g_iShopCvars[PRANK_LIMIT])
	{
		if(iPricePrankPrisoner <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \d[%d/%d] \R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_OTHER_PRANK_PRISONER", g_iPrank, g_iShopCvars[PRANK_LIMIT], iPricePrankPrisoner);
			iBitKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d[%d/%d] \R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_OTHER_PRANK_PRISONER", g_iPrank, g_iShopCvars[PRANK_LIMIT], iPricePrankPrisoner);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d[%d/%d] \d\R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_OTHER_PRANK_PRISONER", g_iPrank, g_iShopCvars[PRANK_LIMIT], iPricePrankPrisoner);
	
	//iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L \w| \d%L \w| \d%L \w| \r%L", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_PRISONERS_WEAPONS", id, "JBM_MENU_SHOP_PRISONERS_ITEMS", id, "JBM_MENU_SHOP_PRISONERS_SKILLS", id, "JBM_MENU_SHOP_PRISONERS_OTHER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L \w| \d%L \w| \d%L \w| \r%L \w| \y*%L*", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_PRISONERS_WEAPONS", id, "JBM_MENU_SHOP_PRISONERS_ITEMS", id, "JBM_MENU_SHOP_PRISONERS_SKILLS", id, "JBM_MENU_SHOP_PRISONERS_OTHER", id, "JBM_MENU_SHOP_PRISONERS_VIP");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopPrisonersMenu_4");
}

public Close_ShopPrisonersMenu_4(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceCloseCase = jbm_get_price_discount(id, g_iShopCvars[CLOSE_CASE]);
			if(isSetBit(g_iBitUserWanted, id) && iPriceCloseCase <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceCloseCase, 1);
				jbm_sub_user_wanted(id);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceFreeDay = jbm_get_price_discount(id, g_iShopCvars[FREE_DAY_SHOP]);
			if(g_iDayMode == DAYMODE_STANDART && isNotSetBit(g_iBitUserFree, id) && isNotSetBit(g_iBitUserWanted, id) && iPriceFreeDay <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceFreeDay, 1);
				jbm_add_user_free(id);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceLotteryTicket = jbm_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET]);
			if(iPriceLotteryTicket <= g_iUserMoney[id])
			{
				g_iLotteryPlayer[id]++;
				new iPrize = random_num(0, 100), iChance = g_iShopCvars[LOTTERY_CHANCE];
				if(iPrize <= iChance)
				{
					UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_LOTTERY_WIN", (g_iShopCvars[LOTTERY_TICKET] * g_iShopCvars[LOTTERY_FACTOR]));
					jbm_set_user_money(id, g_iUserMoney[id] + (g_iShopCvars[LOTTERY_TICKET] * g_iShopCvars[LOTTERY_FACTOR]), 1);
				}
				else 
				{
					UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_LOTTERY_LOSS");
					jbm_set_user_money(id, g_iUserMoney[id] - iPriceLotteryTicket, 1);
				}
				return PLUGIN_HANDLED;
			}
		}
		case 3: if(g_iAlivePlayersNum[1] >= 2 && g_iPrank != 2) return Open_PrankPrisonerMenu(id, g_iMenuPosition[id] = 0);
		case 8: return Open_ShopPrisonersMenu_VIP(id);
		case 9: return Open_MainPnMenu(id);
	}
	return Open_ShopPrisonersMenu_4(id);
}

Open_PrankPrisonerMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserWanted, i) || i == id) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ShopPrisonersMenu_4(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_PRANK_PRISONER_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_PRANK_PRISONER_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_PrankPrisonerMenu");
}

public Close_PrankPrisonerMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Open_PrankPrisonerMenu(id, ++g_iMenuPosition[id]);
		case 9: return Open_PrankPrisonerMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new iPricePrankPrisoner = jbm_get_price_discount(id, g_iShopCvars[PRANK_PRISONER]);
			if(iPricePrankPrisoner <= g_iUserMoney[id] && g_iPrank != 2)
			{
				if(g_iUserTeam[iTarget] == 1 || isSetBit(g_iBitUserAlive, iTarget) || isNotSetBit(g_iBitUserWanted, iTarget))
				{
					jbm_set_user_money(id, g_iUserMoney[id] - iPricePrankPrisoner, 1);
					if(!g_szWantedNames[0])
					{
						emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
						emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					}
					new szName[2][32];
					get_user_name(id, szName[0], charsmax(szName[]));
					get_user_name(iTarget, szName[1], charsmax(szName[]));
					jbm_add_user_wanted(iTarget);
					g_iPrank++;
					UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PRANK_PRISONER", szName[0], szName[1]);
				}
				else return Open_PrankPrisonerMenu(id, g_iMenuPosition[id]);
			}
			else return Open_ShopPrisonersMenu_4(id);
		}
	}
	return PLUGIN_HANDLED;
}

Open_ShopPrisonersMenu_VIP(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_PRISONERS_TITLE", id, "JBM_MENU_SHOP_PRISONERS_VIP", g_iUserMoney[id], g_iUserDiscount[id]);
	
	if(isNotSetBit(g_iBitUserVip, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r%L^n", id, "JBM_MENU_SHOP_VIP_HANT_ACCESS");
		
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_VIP_GUARD_MODEL", g_iShopCvars[VIP_GUARD_MODEL]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_VIP_INVISIBLE_HAT", g_iShopCvars[VIP_INVISIBLE_HAT]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_VIP_LATCHKEY", g_iShopCvars[VIP_LATCHKEY]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_VIP_DEAGLE", g_iShopCvars[VIP_DEAGLE]);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
		
		new iPriceGuardModel = jbm_get_price_discount(id, g_iShopCvars[VIP_GUARD_MODEL]);
		if(g_iUserMoney[id] >= iPriceGuardModel && isNotSetBit(g_iBitGuardModel, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_VIP_GUARD_MODEL", iPriceGuardModel);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_VIP_GUARD_MODEL", iPriceGuardModel);
		new iPriceInvisibleHat = jbm_get_price_discount(id, g_iShopCvars[VIP_INVISIBLE_HAT]);
		if(g_iUserMoney[id] >= iPriceInvisibleHat && isNotSetBit(g_iBitInvisibleHat, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_VIP_INVISIBLE_HAT", iPriceInvisibleHat);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_VIP_INVISIBLE_HAT", iPriceInvisibleHat);
		new iPriceLatchkey = jbm_get_price_discount(id, g_iShopCvars[VIP_LATCHKEY]);
		if(g_iDoorListSize > 1)
		{
			if(g_iUserMoney[id] >= iPriceLatchkey)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_VIP_LATCHKEY", iPriceLatchkey);
				iBitKeys |= (1<<2);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_VIP_LATCHKEY", iPriceLatchkey);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r*Недоступно на этой карте* \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_VIP_LATCHKEY", iPriceLatchkey);
		new iPriceVipDeagle = jbm_get_price_discount(id, g_iShopCvars[VIP_DEAGLE]);
		if(!user_has_weapon(id, CSW_DEAGLE))
		{
			if(g_iUserMoney[id] >= iPriceVipDeagle)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_VIP_DEAGLE", iPriceVipDeagle);
				iBitKeys |= (1<<3);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_VIP_DEAGLE", iPriceVipDeagle);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d\R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_VIP_DEAGLE", iPriceVipDeagle);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L \w| \d%L \w| \d%L \w| \d%L \w| \r*%L*", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_PRISONERS_WEAPONS", id, "JBM_MENU_SHOP_PRISONERS_ITEMS", id, "JBM_MENU_SHOP_PRISONERS_SKILLS", id, "JBM_MENU_SHOP_PRISONERS_OTHER", id, "JBM_MENU_SHOP_PRISONERS_VIP");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopPrisonersMenu_VIP");
}

public Close_ShopPrisonersMenu_VIP(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || g_iGlobalGame) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceGuardModel = jbm_get_price_discount(id, g_iShopCvars[VIP_GUARD_MODEL]);
			if(isNotSetBit(g_iBitGuardModel, id) && iPriceGuardModel <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceGuardModel, 1);
				jbm_set_user_model(id, g_szPlayerModel[GUARD]);
				UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_MENU_ID_GUARD_MODEL");
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceInvisibleHat = jbm_get_price_discount(id, g_iShopCvars[VIP_INVISIBLE_HAT]);
			if(isNotSetBit(g_iBitInvisibleHat, id) && iPriceInvisibleHat <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceInvisibleHat, 1);
				setBit(g_iBitInvisibleHat, id);
				jbm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				if(g_eUserCostumes[id][COSTUMES]) jbm_hide_user_costumes(id);
				set_task(10.0, "jbm_remove_invisible_hat", id+TASK_INVISIBLE_HAT);
				UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_MENU_ID_INVISIBLE_HAT_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceLatchkey = jbm_get_price_discount(id, g_iShopCvars[VIP_LATCHKEY]);
			if(isNotSetBit(g_iBitLatchkey, id) && iPriceLatchkey <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceLatchkey, 1);
				setBit(g_iBitLatchkey, id);
				UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_LATCHKEY_HELP");
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceVipDeagle = jbm_get_price_discount(id, g_iShopCvars[VIP_DEAGLE]);
			if(!user_has_weapon(id, CSW_DEAGLE) && iPriceVipDeagle <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceVipDeagle, 1);
				drop_user_weapons(id, 1);
				fm_give_item(id, "weapon_deagle");
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Open_ShopPrisonersMenu_1(id);
		case 9: return Open_MainPnMenu(id);
	}
	return Open_ShopPrisonersMenu_VIP(id);
}

Open_ShopGuardMenu_1(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_GUARD_TITLE", id, "JBM_MENU_SHOP_GUARD_ITEMS", g_iUserMoney[id], g_iUserDiscount[id]);
	jbm_set_user_discount(id);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
	
	new iPriceStimulator = jbm_get_price_discount(id, g_iShopCvars[STIMULATOR_GR]);
	if(get_user_health(id) < 200)
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	new iPriceLotteryTicket = jbm_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET_GR]);
	if(g_iLotteryPlayer[id] != g_iShopCvars[LOTTERY_LIMIT])
	{
		if(iPriceLotteryTicket <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \d[%d/%d] \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_GUARD_LOTTERY_TICKET", g_iShopCvars[LOTTERY_CHANCE], g_iLotteryPlayer[id], g_iShopCvars[LOTTERY_LIMIT], iPriceLotteryTicket);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \d[%d/%d] \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_GUARD_LOTTERY_TICKET", g_iShopCvars[LOTTERY_CHANCE], g_iLotteryPlayer[id], g_iShopCvars[LOTTERY_LIMIT], iPriceLotteryTicket);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L [%d/%d] \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_GUARD_LOTTERY_TICKET", g_iShopCvars[LOTTERY_CHANCE], g_iLotteryPlayer[id], g_iShopCvars[LOTTERY_LIMIT], iPriceLotteryTicket);
	new iPriceKokain = jbm_get_price_discount(id, g_iShopCvars[KOKAIN_GR]);
	if(isNotSetBit(g_iBitKokain, id))
	{
		if(iPriceKokain <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
			iBitKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \r%L \w| \d%L \w| \y%L", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_GUARD_ITEMS", id, "JBM_MENU_SHOP_GUARD_SKILLS", id, "JBM_MENU_SHOP_GUARD_CHIEF");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopGuardMenu_1");
}

public Close_ShopGuardMenu_1(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceStimulator = jbm_get_price_discount(id, g_iShopCvars[STIMULATOR_GR]);
			if(get_user_health(id) < 200 && iPriceStimulator <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceStimulator, 1);
				jbm_set_syringe_model(id);
				set_task(1.3, "jbm_set_syringe_health", id+TASK_REMOVE_SYRINGE);
				set_task(2.8, "jbm_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceLotteryTicket = jbm_get_price_discount(id, g_iShopCvars[LOTTERY_TICKET]);
			if(iPriceLotteryTicket <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceLotteryTicket, 1);
				g_iLotteryPlayer[id]++;
				new iPrize = random_num(0, 100), iChance = g_iShopCvars[LOTTERY_CHANCE];
				if(iPrize <= iChance)
				{
					UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_LOTTERY_WIN", (g_iShopCvars[LOTTERY_TICKET] * g_iShopCvars[LOTTERY_FACTOR]));
					jbm_set_user_money(id, g_iUserMoney[id] + (g_iShopCvars[LOTTERY_TICKET] * g_iShopCvars[LOTTERY_FACTOR]), 1);
				}
				else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_LOTTERY_LOSS");
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceKokain = jbm_get_price_discount(id, g_iShopCvars[KOKAIN_GR]);
			if(isNotSetBit(g_iBitKokain, id) && iPriceKokain <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceKokain, 1);
				setBit(g_iBitKokain, id);
				jbm_set_syringe_model(id);
				UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_MENU_ID_KOKAIN");
				set_task(2.8, "jbm_remove_syringe_model", id+TASK_REMOVE_SYRINGE);
				return PLUGIN_HANDLED;
			}
		}
		
		case 8: return Open_ShopGuardMenu_2(id);
	}
	return Open_MainGrMenu(id);
}

Open_ShopGuardMenu_2(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_GUARD_TITLE", id, "JBM_MENU_SHOP_GUARD_SKILLS", g_iUserMoney[id], g_iUserDiscount[id]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
	
	new iPriceRandomGlow = jbm_get_price_discount(id, g_iShopCvars[RANDOM_GLOW_GR]);
	if(isNotSetBit(g_iBitRandomGlow, id))
	{
		if(iPriceRandomGlow <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_GUARD_RANDOM_GLOW", iPriceRandomGlow);
	new iPriceDoubleJump = jbm_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP_GR]);
	if(isNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	new iPriceFastRun = jbm_get_price_discount(id, g_iShopCvars[FAST_RUN_GR]);
	if(g_fUserSpeed[id] != 400.0)
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
			iBitKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	new iPriceLowGravity = jbm_get_price_discount(id, g_iShopCvars[LOW_GRAVITY_GR]);
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
			iBitKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L \w| \r%L \w| \y%L", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_GUARD_ITEMS", id, "JBM_MENU_SHOP_GUARD_SKILLS", id, "JBM_MENU_SHOP_GUARD_CHIEF");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopGuardMenu_2");
}

public Close_ShopGuardMenu_2(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceRandomGlow = jbm_get_price_discount(id, g_iShopCvars[RANDOM_GLOW_GR]);
			if(iPriceRandomGlow <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceRandomGlow, 1);
				setBit(g_iBitRandomGlow, id);
				jbm_set_user_rendering(id, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), kRenderNormal, 0);
				jbm_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceDoubleJump = jbm_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP_GR]);
			if(iPriceDoubleJump <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceDoubleJump, 1);
				setBit(g_iBitDoubleJump, id);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceFastRun = jbm_get_price_discount(id, g_iShopCvars[FAST_RUN_GR]);
			if(iPriceFastRun <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceFastRun, 1);
				g_fUserSpeed[id] = 400.0;
				ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
				return PLUGIN_HANDLED;
			}
		}
		case 3:
		{
			new iPriceLowGravity = jbm_get_price_discount(id, g_iShopCvars[LOW_GRAVITY_GR]);
			if(iPriceLowGravity <= g_iUserMoney[id])
			{
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceLowGravity, 1);
				set_pev(id, pev_gravity, 0.5);
				return PLUGIN_HANDLED;
			}
		}
		case 8: 
		{
			if(id != g_iChiefId) return Open_ShopGuardMenu_1(id);
			else return Open_ShopChiefMenu(id);
		}
	}
	return Open_MainGrMenu(id);
}

Open_ShopChiefMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || id != g_iChiefId) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SHOP_GUARD_TITLE", id, "JBM_MENU_SHOP_GUARD_CHIEF", g_iUserMoney[id], g_iUserDiscount[id]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r\RЦены^n");
	
	new iPriceGod = jbm_get_price_discount(id, g_iShopCvars[GOD_CHIEF]);
	if(!get_user_godmode(id))
	{
		if(iPriceGod <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_CHIEF_GOD", iPriceGod);
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_CHIEF_GOD", iPriceGod);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 1, id, "JBM_MENU_SHOP_CHIEF_GOD", iPriceGod);
	new iPriceInvisible = jbm_get_price_discount(id, g_iShopCvars[INVISIBLE_CHIEF]);
	if(!g_eUserRendering[id][RENDER_STATUS])
	{
		if(iPriceInvisible <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_CHIEF_INVISIBLE", iPriceInvisible);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_CHIEF_INVISIBLE", iPriceInvisible);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n", id, "JBM_KEY", 2, id, "JBM_MENU_SHOP_CHIEF_INVISIBLE", iPriceInvisible);
	new iPriceFootsteps = jbm_get_price_discount(id, g_iShopCvars[FOOTSTEPS_CHIEF]);
	if(!get_user_footsteps(id))
	{
		if(iPriceFootsteps <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \y\R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_CHIEF_FOOTSTEPS", iPriceFootsteps);
			iBitKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_CHIEF_FOOTSTEPS", iPriceFootsteps);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \R%d$^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_SHOP_CHIEF_FOOTSTEPS", iPriceFootsteps);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L \w| \d%L \w| \r%L", id, "JBM_KEY", 9, id, "JBM_MENU_SHOP_GUARD_ITEMS", id, "JBM_MENU_SHOP_GUARD_SKILLS", id, "JBM_MENU_SHOP_GUARD_CHIEF");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ShopChiefMenu");
}

public Close_ShopChiefMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id) || id != g_iChiefId) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceGod = jbm_get_price_discount(id, g_iShopCvars[GOD_CHIEF]);
			if(iPriceGod <= g_iUserMoney[id])
			{
				new szChief[32];
				get_user_name(id, szChief, charsmax(szChief));
				
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceGod, 1);
				set_user_godmode(id, 1);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_CHIEF_BUY_GOD", szChief);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			new iPriceInvisible = jbm_get_price_discount(id, g_iShopCvars[INVISIBLE_CHIEF]);
			if(iPriceInvisible <= g_iUserMoney[id])
			{
				new szChief[32];
				get_user_name(id, szChief, charsmax(szChief));
				
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceInvisible, 1);
				jbm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				jbm_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_CHIEF_BUY_INVISIBLE", szChief);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			new iPriceFootsteps = jbm_get_price_discount(id, g_iShopCvars[FOOTSTEPS_CHIEF]);
			if(iPriceFootsteps <= g_iUserMoney[id])
			{
				new szChief[32];
				get_user_name(id, szChief, charsmax(szChief));
			
				jbm_set_user_money(id, g_iUserMoney[id] - iPriceFootsteps, 1);
				set_user_footsteps(id, 1);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_CHIEF_BUY_FOOTSTEPS", szChief);
				return PLUGIN_HANDLED;
			}
		}
		case 8: return Open_ShopGuardMenu_1(id);
	}
	return Open_MainGrMenu(id);
}

Open_MoneyTransferMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserConnected, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ChiefMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n\d%L^n^n", id, "JBM_MENU_MONEY_TRANSFER_TITLE", id, "JBM_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n\d%L^n^n", id, "JBM_MENU_MONEY_TRANSFER_TITLE", iPos + 1, iPagesNum, id, "JBM_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		if(i != id)
		{
			iBitKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \r[%d$]^n", id, "JBM_KEY", ++b, szName, g_iUserMoney[i]);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s \r[%d$]^n", id, "JBM_KEY", ++b, szName, g_iUserMoney[i]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MoneyTransferMenu");
}

public Close_MoneyTransferMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_MoneyTransferMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_MoneyTransferMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			g_iMenuTarget[id] = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			return Open_MoneyAmountMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

Open_MoneyAmountMenu(id)
{
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n\d%L^n^n", id, "JBM_MENU_MONEY_AMOUNT_TITLE", id, "JBM_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
	if(g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 1, floatround(g_iUserMoney[id] * 0.10, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 2, floatround(g_iUserMoney[id] * 0.25, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 3, floatround(g_iUserMoney[id] * 0.50, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 4, floatround(g_iUserMoney[id] * 0.75, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n^n", id, "JBM_KEY", 5, g_iUserMoney[id]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_MONEY_SPECIFY_AMOUNT");
		iBitKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d0$^n%L \d0$^n%L \d0$^n%L \d0$^n%L \d0$^n^n", id, "JBM_KEY", 1, id, "JBM_KEY", 2, id, "JBM_KEY", 3, id, "JBM_KEY", 4, id, "JBM_KEY", 5);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_MONEY_SPECIFY_AMOUNT");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MoneyAmountMenu");
}

public Close_MoneyAmountMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: Command_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.10, floatround_ceil));
		case 1: Command_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.25, floatround_ceil));
		case 2: Command_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.50, floatround_ceil));
		case 3: Command_MoneyTransfer(id, g_iMenuTarget[id], floatround(g_iUserMoney[id] * 0.75, floatround_ceil));
		case 4: Command_MoneyTransfer(id, g_iMenuTarget[id], g_iUserMoney[id]);
		case 5: client_cmd(id, "messagemode ^"money_transfer %d^"", g_iMenuTarget[id]);
		case 8: return Open_MoneyTransferMenu(id, g_iMenuPosition[id]);
	}
	return PLUGIN_HANDLED;
}

Open_CostumesMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iCostumesListSize) iStart = g_iCostumesListSize;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	//if(iEnd > g_iCostumesListSize) iEnd = g_iCostumesListSize + (iPos ? 0 : 1);
	if(iEnd > g_iCostumesListSize) iEnd = g_iCostumesListSize;
	new szMenu[512], iLen, iPagesNum = (g_iCostumesListSize / PLAYERS_PER_PAGE + ((g_iCostumesListSize % PLAYERS_PER_PAGE) ? 1 : 0));
	new aDataCostumes[DATA_COSTUMES_PRECACHE];
	if(g_eUserCostumes[id][COSTUMES]) 
	{
		ArrayGetArray(g_aCostumesList, g_eUserCostumes[id][COSTUMES], aDataCostumes);
		iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n\dНа вас сейчас: %s^n^n", id, "JBM_MENU_COSTUMES_TITLE", iPos + 1, iPagesNum, aDataCostumes[NAME_COSTUME]);
	}
	else iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n\dНа вас сейчас: Нет шапки^n^n", id, "JBM_MENU_COSTUMES_TITLE", iPos + 1, iPagesNum);
	new iBitKeys = (1<<9), b;
	new iFlags = get_user_flags(id);
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aCostumesList, a, aDataCostumes);
		
		if(aDataCostumes[FLAG_COSTUME])
		{
			if(iFlags & read_flags(aDataCostumes[FLAG_COSTUME]))
			{
				if(g_eUserCostumes[id][COSTUMES] != a)
				{
					iBitKeys |= (1<<b);
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, aDataCostumes[NAME_COSTUME]);
				}
				else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s^n", id, "JBM_KEY", ++b, aDataCostumes[NAME_COSTUME]);
			}
			//else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s %s %d \r%s^n", id, "JBM_KEY", ++b, aDataCostumes[FLAG_COSTUME], read_flags(aDataCostumes[FLAG_COSTUME]), aDataCostumes[NAME_COSTUME], aDataCostumes[WARNING_MSG]);
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s \r%s^n", id, "JBM_KEY", ++b, aDataCostumes[NAME_COSTUME], aDataCostumes[WARNING_MSG]);
		}
		else
		{
			if(g_eUserCostumes[id][COSTUMES] != a)
			{
				iBitKeys |= (1<<b);
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, aDataCostumes[NAME_COSTUME]);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s^n", id, "JBM_KEY", ++b, aDataCostumes[NAME_COSTUME]);
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_CostumesMenu");
}

public Close_CostumesMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_CostumesMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_CostumesMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iCostumes = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
			jbm_set_user_costumes(id, iCostumes);
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_HANDLED;
}

Open_CheckGuardMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_CHECK_GUARD_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \r%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_CHECK_GUARD_YES");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L", id, "JBM_KEY", 2, id, "JBM_MENU_CHECK_GUARD_NO");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_CheckGuardMenu");
}

public Close_CheckGuardMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Open_PunishGuardMenu(id, g_iMenuPosition[id] = 0);
		case 1: return Open_ChiefMenu(id);
	}
	return PLUGIN_HANDLED;
}

Open_ChiefMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<7|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_CHIEF_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 1, id, g_bDoorStatus ? "JBM_MENU_CHIEF_DOOR_CLOSE" : "JBM_MENU_CHIEF_DOOR_OPEN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, g_iDayMode == DAYMODE_STANDART ? "JBM_MENU_CHIEF_FREE_DAY_START" : "JBM_MENU_CHIEF_FREE_DAY_END");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_CHIEF_PUNISH_GUARD");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_CHIEF_TRANSFER_CHIEF");
	if(g_iDayMode == DAYMODE_STANDART)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_CHIEF_CHIEF_SOUND");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_CHIEF_MINI_GAME");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_CHIEF_GLOBAL_GAME");
		iBitKeys |= (1<<4|1<<5|1<<6);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_CHIEF_CHIEF_SOUND");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_CHIEF_MINI_GAME");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_CHIEF_GLOBAL_GAME");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_CHIEF_GLOBAL_GAME_SMOTR");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ChiefMenu");
}

public Close_ChiefMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			if(g_bDoorStatus) 
			{
				jbm_close_doors();
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_DOOR_CLOSE", szName);
			}
			else 
			{
				jbm_open_doors();
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_DOOR_OPEN", szName);
			}
		}
		case 1:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			if(g_iDayMode == DAYMODE_STANDART) 
			{
				jbm_free_day_start();
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_FD_START", szName);
			}
			else 
			{
				jbm_free_day_ended();
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_FD_STOP", szName);
			}
		}
		case 2: return Open_PunishGuardMenu(id, g_iMenuPosition[id] = 0);
		case 3: return Open_TransferChiefMenu(id, g_iMenuPosition[id] = 0);
		case 4: if(g_iDayMode == DAYMODE_STANDART) return Open_ChiefSoundMenu(id);
		case 5: if(g_iDayMode == DAYMODE_STANDART) return Open_MiniGameMenu(id);
		case 6: if(g_iDayMode == DAYMODE_STANDART) return Open_GlobalGameMenu(id);
		case 7: return Open_SmotrGlobalMenu(id);
		case 8: return Open_ChiefTwoMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_ChiefMenu(id);
}

Open_PunishGuardMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 2 || i == g_iChiefId || isSetBit(g_iBitUserAdmin, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ChiefMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_PUNISH_GUARD_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_PUNISH_GUARD_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s %s^n", id, "JBM_KEY", ++b, szName, isSetBit(g_iBitUserAlive, i) ? "" : "\r[Мертв]");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_PunishGuardMenu");
}

public Close_PunishGuardMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_PunishGuardMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_PunishGuardMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 2)
			{
				fm_strip_user_weapons(iTarget, 1);
				if(jbm_set_user_team(iTarget, 1))
				{
					new szName[32], szTargetName[32];
					get_user_name(id, szName, charsmax(szName));
					get_user_name(iTarget, szTargetName, charsmax(szTargetName));
					UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_PUNISH_GUARD", szName, szTargetName);
				}
			}
		}
	}
	return Open_PunishGuardMenu(id, g_iMenuPosition[id]);
}

Open_TransferChiefMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 2 || isNotSetBit(g_iBitUserAlive, i) || i == g_iChiefId || isSetBit(g_iBitUserDuel, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ChiefMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_TRANSFER_CHIEF_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_TRANSFER_CHIEF_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_TransferChiefMenu");
}

public Close_TransferChiefMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_TransferChiefMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_TransferChiefMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(jbm_set_user_chief(iTarget) && isNotSetBit(g_iBitUserDuel, iTarget))
			{
				if(jbm_get_players_count(0, 2) >= g_iLevelCvars[PLAYERS_NEED]) { if(g_iExpName[id]) g_iExpName[id]--; }
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_TRANSFER_CHIEF", szName, szTargetName);
				return PLUGIN_HANDLED;
			}
		}
	}
	return Open_TransferChiefMenu(id, g_iMenuPosition[id]);
}

Open_ChiefSoundMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_CHIEF_SOUND_TITLE");
	if(task_exists(TASK_COUNT_DOWN_TIMER))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_3");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_MY_TIME");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 5, id, "JBM_MENU_CHIEF_SOUND_GONG");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \r%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_CHIEF_SOUND_STOP_SOUND");
		iBitKeys |= (1<<5);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_3");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_CHIEF_SOUND_COUNT_DOWN_MY_TIME");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 5, id, "JBM_MENU_CHIEF_SOUND_GONG");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_CHIEF_SOUND_STOP_SOUND");
		iBitKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ChiefSoundMenu");
}

public Close_ChiefSoundMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: 
		{
			if(task_exists(TASK_COUNT_DOWN_TIMER)) return Open_ChiefSoundMenu(id);
			client_cmd(0, "stopsound");
			g_iCountDown = 11;
			set_task(1.0, "jbm_count_down_timer", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
		}
		case 1: 
		{
			if(task_exists(TASK_COUNT_DOWN_TIMER)) return Open_ChiefSoundMenu(id);
			client_cmd(0, "stopsound");
			g_iCountDown = 6;
			set_task(1.0, "jbm_count_down_timer", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
		}
		case 2: 
		{
			if(task_exists(TASK_COUNT_DOWN_TIMER)) return Open_ChiefSoundMenu(id);
			client_cmd(0, "stopsound");
			g_iCountDown = 4;
			set_task(1.0, "jbm_count_down_timer", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
		}
		case 3: client_cmd(id, "messagemode ^"countdown_choose^"");
		case 4: emit_sound(id, CHAN_AUTO, "jb_engine/countdown/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		case 5: if(task_exists(TASK_COUNT_DOWN_TIMER)) remove_task(TASK_COUNT_DOWN_TIMER);
		case 8: return Open_ChiefMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_ChiefSoundMenu(id);
}

public jbm_count_down_timer()
{
	if(--g_iCountDown) client_print(0, print_center, "%L", LANG_PLAYER, "JBM_MENU_COUNT_DOWN_TIME", g_iCountDown);
	else client_print(0, print_center, "%L", LANG_PLAYER, "JBM_MENU_COUNT_DOWN_TIME_END");
	if(g_iCountDown <= 10) UTIL_SendAudio(0, _, "jb_engine/countdown/%d.wav", g_iCountDown);
}

Open_MiniGameMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<5|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_MINI_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_MINI_GAME_SOCCER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_MINI_GAME_SPRAY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MINI_GAME_DISTANCE_DROP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 4, id, "JBM_MENU_MINI_GAME_BOXING", id, g_bBoxingStatus ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
	if(g_bBoxingStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_MINI_GAME_MORE_DAMAGE_HE", id, g_szDamageHe[g_iMoreDamageHE]);
		iBitKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_MINI_GAME_MORE_DAMAGE_HE", id, g_szDamageHe[g_iMoreDamageHE]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_MINI_GAME_RANDOM_SKIN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MiniGameMenu");
}

public Close_MiniGameMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Open_SoccerMenu(id);
		case 1:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i)) continue;
				set_pdata_float(i, m_flNextDecalTime, 0.0);
			}
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ID_MINI_GAME_SPRAY");
		}
		case 2:
		{
			if(g_iLastUse[id] > get_systime())
			{
				UTIL_SayText(id, "!y[!gJBM!y]!y Вы сможете выдать диглы через: !t%d сек", g_iLastUse[id] - get_systime());
				return Open_MiniGameMenu(id);
			} 
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				ham_strip_weapon_name(i, "weapon_deagle");
				new iEntity = fm_give_item(i, "weapon_deagle");
				if(iEntity > 0) set_pdata_int(iEntity, m_iClip, -1, linux_diff_weapon);
			}
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_MINI_GAME_DISTANCE_DROP");
			g_iLastUse[id] = get_systime(30);
		}
		case 3: 
		{
			if(g_iAlivePlayersNum[1] <= 1)
			{
				UTIL_SayText(id, "!y[!gJBM!y] !y%L", id, "JBM_CHAT_ID_BOXING_INSUFFICIENTLY_PLAYERS");
				return Open_MiniGameMenu(id);
			}
			
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			if(!g_bBoxingStatus)
			{
				for(new i = 1; i <= g_iMaxPlayers; i++)
				{
					if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
					set_pev(i, pev_health, 100.0);
				}
				g_bBoxingStatus = true;
				emit_sound(id, CHAN_AUTO, g_szSounds[GONG_BOXING], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_BOX_ENABLE", szName);
			}
			else
			{
				g_bBoxingStatus = false;
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_BOX_DISABLE", szName);
			}
		}
		case 4: 
		{
			if(g_iMoreDamageHE == charsmax(g_iDamageHe)) g_iMoreDamageHE = 0;
			else g_iMoreDamageHE++;
		}
		case 5:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserFree, i) || isSetBit(g_iBitUserWanted, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				set_pev(i, pev_skin, random_num(0, g_iPlayersParams[COUNT_SKIN]));
			}
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ID_MINI_GAME_RANDOM_SKIN");
		}
		case 8: return Open_ChiefMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_MiniGameMenu(id);
}

Open_SoccerMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SOCCER_TITLE");
	if(g_bSoccerStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_SOCCER_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_SOCCER_BALL_SPEED");
		if(g_iSoccerBall)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_SOCCER_SUB_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_SOCCER_UPDATE_BALL");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_SOCCER_WHISTLE");
				iBitKeys |= (1<<4);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_SOCCER_GAME_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_SOCCER_GAME_START");
			iBitKeys |= (1<<3|1<<5);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_SOCCER_ADD_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_SOCCER_UPDATE_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_SOCCER_GAME_END");
				iBitKeys |= (1<<5);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_SOCCER_GAME_START");
		}
		if(g_bSoccerGame)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 8, id, "JBM_MENU_SOCCER_SCORE");
			iBitKeys |= (1<<7);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 8, id, "JBM_MENU_SOCCER_SCORE");
			iBitKeys |= (1<<6);
		}
		iBitKeys |= (1<<1|1<<2);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_SOCCER_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_SOCCER_BALL_SPEED");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_SOCCER_ADD_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_SOCCER_UPDATE_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_SOCCER_WHISTLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_SOCCER_GAME_END");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_SOCCER_TEAMS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 8, id, "JBM_MENU_SOCCER_SCORE");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_SoccerMenu");
}

public Close_SoccerMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(g_bSoccerStatus) jbm_soccer_disable_all();
			else g_bSoccerStatus = true;
		}
		case 1: return Open_SoccerBallSpeedMenu(id);
		case 2:
		{
			if(g_iSoccerBall) jbm_soccer_remove_ball();
			else jbm_soccer_create_ball(id);
		}
		case 3: if(g_iSoccerBall) jbm_soccer_update_ball();
		case 4:
		{
			if(g_bSoccerGame && g_iSoccerBall)
			{
				emit_sound(id, CHAN_AUTO, g_szSounds[WHITLE_START], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				g_bSoccerBallTouch = true;
			}
		}
		case 5:
		{
			if(g_bSoccerGame) jbm_soccer_game_end(id);
			else if(g_iSoccerBall) jbm_soccer_game_start(id);
		}
		case 6: if(!g_bSoccerGame) return Open_SoccerTeamMenu(id);
		case 7: if(g_bSoccerGame) return Open_SoccerScoreMenu(id);
		case 8: return Open_MiniGameMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_SoccerMenu(id);
}

Open_SoccerTeamMenu(id)
{
	if(g_bSoccerGame || g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SOCCER_TEAM_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_SOCCER_TEAM_DIVIDE_PRISONERS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_SOCCER_TEAM_DIVIDE_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBM_MENU_SOCCER_TEAM_DESCRIPTION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_SOCCER_TEAM_ADD_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_SOCCER_TEAM_ADD_BLUE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_SOCCER_TEAM_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<5|1<<6|1<<7|1<<8|1<<9), szMenu, -1, "Open_SoccerTeamMenu");
}

public Close_SoccerTeamMenu(id, iKey)
{
	if(g_bSoccerGame || g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: jbm_soccer_divide_team(1);
		case 1: jbm_soccer_divide_team(0);
		case 7:
		{
			new iTarget, iBody;
			get_user_aiming(id, iTarget, iBody, 9999);
			if(IsValidPlayer(iTarget) && isSetBit(g_iBitUserSoccer, iTarget))
			{
				clearBit(g_iBitUserSoccer, iTarget);
				if(iTarget == g_iSoccerBallOwner)
				{
					CREATE_KILLPLAYERATTACHMENTS(iTarget);
					set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
					set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
					g_iSoccerBallOwner = 0;
				}
				else jbm_default_player_model(iTarget);
				set_pdata_int(iTarget, m_bloodColor, 247);
				new iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem);
				if(iActiveItem > 0)
				{
					ExecuteHamB(Ham_Item_Deploy, iActiveItem);
					UTIL_WeaponAnimation(iTarget, 3);
				}
			}
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_SoccerTeamMenu(id);
		}
		case 8: return Open_SoccerMenu(id);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget, iBody;
			get_user_aiming(id, iTarget, iBody, 9999);
			if(IsValidPlayer(iTarget) && isSetBit(g_iBitUserAlive, iTarget) && isNotSetBit(g_iBitUserDuel, iTarget) && (g_iUserTeam[iTarget] == 1 && isNotSetBit(g_iBitUserFree, iTarget) && isNotSetBit(g_iBitUserWanted, iTarget) || g_iUserTeam[iTarget] == 2))
			{
				new szLangPlayer[][] = {"JBM_HUD_ID_YOU_TEAM_RED", "JBM_HUD_ID_YOU_TEAM_BLUE"};
				UTIL_SayText(iTarget, "!y[!gJBM!y]!y %L", iTarget, szLangPlayer[iKey - 5]);
				if(isNotSetBit(g_iBitUserSoccer, iTarget))
				{
					setBit(g_iBitUserSoccer, iTarget);
					jbm_set_user_model(iTarget, g_szPlayerModel[FOOTBALLER]);
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
				}
				set_pev(iTarget, pev_skin, iKey - 5);
				g_iSoccerUserTeam[iTarget] = iKey - 5;
			}
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_SoccerTeamMenu(id);
		}
	}
	return Open_SoccerMenu(id);
}

Open_SoccerScoreMenu(id)
{
	if(!g_bSoccerGame || g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<2|1<<4|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SOCCER_SCORE_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_SOCCER_SCORE_RED_ADD");
	if(g_iSoccerScore[0])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_SOCCER_SCORE_RED_SUB");
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_SOCCER_SCORE_RED_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_SOCCER_SCORE_BLUE_ADD");
	if(g_iSoccerScore[1])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_SOCCER_SCORE_BLUE_SUB");
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_SOCCER_SCORE_BLUE_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n^n^n", id, "JBM_KEY", 5, id, "JBM_MENU_SOCCER_SCORE_RESET");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_SoccerScoreMenu");
}

public Close_SoccerScoreMenu(id, iKey)
{
	if(!g_bSoccerGame || g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: g_iSoccerScore[0]++;
		case 1: g_iSoccerScore[0]--;
		case 2: g_iSoccerScore[1]++;
		case 3: g_iSoccerScore[1]--;
		case 4: g_iSoccerScore = {0, 0};
		case 8: return Open_SoccerMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_SoccerScoreMenu(id);
}

Open_SoccerBallSpeedMenu(id)
{
	if(!g_bSoccerStatus || g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\yВыбор скорости мяча^n^n");
	if(g_iSoccerBallSpeed != 1000)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_SOCCER_BALL_SPEED_DEFAULT");
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r(%L)^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_SOCCER_BALL_SPEED_DEFAULT", id, "JBM_MENU_SOCCER_BALL_SPEED_CURRENT");
	if(g_iSoccerBallSpeed != 500)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_SOCCER_BALL_SPEED_MINIMAL");
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r(%L)^n", id, "JBM_KEY", 2, id, "JBM_MENU_SOCCER_BALL_SPEED_MINIMAL", id, "JBM_MENU_SOCCER_BALL_SPEED_CURRENT");
	if(g_iSoccerBallSpeed != 1500)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_SOCCER_BALL_SPEED_HIGH");
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r(%L)^n", id, "JBM_KEY", 3, id, "JBM_MENU_SOCCER_BALL_SPEED_HIGH", id, "JBM_MENU_SOCCER_BALL_SPEED_CURRENT");
	if(g_iSoccerBallSpeed != 2000)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_SOCCER_BALL_SPEED_ULTRA_HIGH");
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r(%L)^n", id, "JBM_KEY", 4, id, "JBM_MENU_SOCCER_BALL_SPEED_ULTRA_HIGH", id, "JBM_MENU_SOCCER_BALL_SPEED_CURRENT");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_SoccerBallSpeedMenu");
}

public Close_SoccerBallSpeedMenu(id, iKey)
{
	if(!g_bSoccerStatus || g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: g_iSoccerBallSpeed = 1000;
		case 1: g_iSoccerBallSpeed = 500;
		case 2: g_iSoccerBallSpeed = 1500;
		case 3: g_iSoccerBallSpeed = 2000;
		case 8: return Open_SoccerMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_SoccerBallSpeedMenu(id);
}

Open_GlobalGameMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<5|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_GLOBAL_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_GLOBAL_GAME_WEAPONS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 2, id, "JBM_MENU_GLOBAL_GAME_TEAM");
	if(!g_bGlobalGame && g_iAlivePlayersNum[1] >= 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_GLOBAL_GAME_BYNT");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_GLOBAL_GAME_MYASO");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n^n", id, "JBM_KEY", 5, id, "JBM_MENU_GLOBAL_GAME_HUNGER_GAMES");
		iBitKeys |= (1<<2|1<<3|1<<4);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_GLOBAL_GAME_BYNT");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_GLOBAL_GAME_MYASO");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n^n", id, "JBM_KEY", 5, id, "JBM_MENU_GLOBAL_GAME_HUNGER_GAMES");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_GlobalGameMenu");
}

public Close_GlobalGameMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Open_WeaponsMenu(id);
		case 1: return Open_TeamMenu(id);
		case 2:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			
			set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.6, 0, 0.0, 6.0, 0.0, 0.0, -1);
			ShowSyncHudMsg(0, g_iSyncGlobalGame, "%L", LANG_MODE, "JBM_HUD_CHIEF_GG_BYNT", szName);
			g_bGlobalGame = true;
			jbm_open_doors();
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserFree, i) || isSetBit(g_iBitUserWanted, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_ak47");
				fm_set_user_bpammo(i, CSW_AK47, 250);
				drop_user_weapons(i, 1);
			}
			emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			formatex(g_szDayMode, charsmax(g_szDayMode), "JBM_HUD_GAME_MODE_BYNT");
		}
		case 3:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			
			set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.6, 0, 0.0, 6.0, 0.0, 0.0, -1);
			ShowSyncHudMsg(0, g_iSyncGlobalGame, "%L", LANG_MODE, "JBM_HUD_CHIEF_GG_MYASO", szName);
			g_bGlobalGame = true;
			g_bBoxingStatus = true;
			g_iFriendlyFire = true;
			jbm_open_doors();
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserFree, i) || isSetBit(g_iBitUserWanted, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_ak47");
				fm_set_user_bpammo(i, CSW_AK47, 250);
				drop_user_weapons(i, 1);
			}
			
			formatex(g_szDayMode, charsmax(g_szDayMode), "JBM_HUD_GAME_MODE_MYASO");
		}
		case 4:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
				
			set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.6, 0, 0.0, 6.0, 0.0, 0.0, -1);
			ShowSyncHudMsg(0, g_iSyncGlobalGame, "%L", LANG_MODE, "JBM_HUD_CHIEF_GG_HG", szName);
			g_bGlobalGame = true;
			jbm_open_doors();
			g_iCountDown = 11;
			set_task(1.0, "jbm_hg_start", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
			
			formatex(g_szDayMode, charsmax(g_szDayMode), "JBM_HUD_GAME_MODE_HG");
		}
		case 8: return Open_ChiefMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_GlobalGameMenu(id);
}

public jbm_hg_start()
{
	if(--g_iCountDown) client_print(0, print_center, "%L", LANG_PLAYER, "JBM_MENU_COUNT_DOWN_TIME", g_iCountDown);
	else
	{
		client_print(0, print_center, "%L", LANG_PLAYER, "JBM_MENU_COUNT_DOWN_TIME_END");
		g_bBoxingStatus = true;
		UTIL_SendAudio(0, _, "jb_engine/countdown/%d.wav", g_iCountDown);
	}
	UTIL_SendAudio(0, _, "jb_engine/countdown/%d.wav", g_iCountDown);
}

Open_WeaponsMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_WEAPONS_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_GLOBAL_GAME_AK47");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_GLOBAL_GAME_M4A1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_GLOBAL_GAME_AWP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_GLOBAL_GAME_XM1014");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), szMenu, -1, "Open_WeaponsMenu");
}

public Close_WeaponsMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserFree, i) || isSetBit(g_iBitUserWanted, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_ak47");
				fm_set_user_bpammo(i, CSW_AK47, 250);
			}
		}
		case 1:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserFree, i) || isSetBit(g_iBitUserWanted, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_m4a1");
				fm_set_user_bpammo(i, CSW_AK47, 250);
			}
		}		
		case 2:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserFree, i) || isSetBit(g_iBitUserWanted, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_awp");
				fm_set_user_bpammo(i, CSW_AWP, 250);
			}
		}
		case 3:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || isSetBit(g_iBitUserFree, i) || isSetBit(g_iBitUserWanted, i) || isSetBit(g_iBitUserSoccer, i) || isSetBit(g_iBitUserDuel, i)) continue;
				fm_give_item(i, "weapon_xm1014");
				fm_set_user_bpammo(i, CSW_AK47, 250);
			}
		}
		case 8: return Open_GlobalGameMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_WeaponsMenu(id);
}

Open_TeamMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_TEAM_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_GLOBAL_GAME_TEAM_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_GLOBAL_GAME_TEAM_2");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_GLOBAL_GAME_TEAM_3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_GLOBAL_GAME_TEAM_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), szMenu, -1, "Open_TeamMenu");
}

public Close_TeamMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(g_iDayMode == DAYMODE_STANDART) 
			{
				new iTarget, iBody;
				get_user_aiming(id, iTarget, iBody, 60);
				if(IsValidPlayer(iTarget) && isSetBit(g_iBitUserAlive, iTarget) && isNotSetBit(g_iBitUserFree, iTarget) && isNotSetBit(g_iBitUserWanted, iTarget))
				{
					if(g_iUserTeam[iTarget] != 1) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_NOT_TEAM");
					else
					{
						set_pev(iTarget, pev_skin, 0);
						UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_TEAM_TARGET_2");
					}
				}
			}
		}
		case 1:
		{
			if(g_iDayMode == DAYMODE_STANDART) 
			{
				new iTarget, iBody;
				get_user_aiming(id, iTarget, iBody, 60);
				if(IsValidPlayer(iTarget) && isSetBit(g_iBitUserAlive, iTarget) && isNotSetBit(g_iBitUserFree, iTarget) && isNotSetBit(g_iBitUserWanted, iTarget))
				{
					if(g_iUserTeam[iTarget] != 1) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_NOT_TEAM");
					else
					{
						set_pev(iTarget, pev_skin, 1);
						UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_TEAM_TARGET_2");
					}
				}
			}
		}
		case 2:
		{
			if(g_iDayMode == DAYMODE_STANDART) 
			{
				new iTarget, iBody;
				get_user_aiming(id, iTarget, iBody, 60);
				if(IsValidPlayer(iTarget) && isSetBit(g_iBitUserAlive, iTarget) && isNotSetBit(g_iBitUserFree, iTarget) && isNotSetBit(g_iBitUserWanted, iTarget))
				{
					if(g_iUserTeam[iTarget] != 1) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_NOT_TEAM");
					else
					{
						set_pev(iTarget, pev_skin, 2);
						UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_TEAM_TARGET_3");
					}
				}
			}
		}
		case 3:
		{
			if(g_iDayMode == DAYMODE_STANDART) 
			{
				new iTarget, iBody;
				get_user_aiming(id, iTarget, iBody, 60);
				if(IsValidPlayer(iTarget) && isSetBit(g_iBitUserAlive, iTarget) && isNotSetBit(g_iBitUserFree, iTarget) && isNotSetBit(g_iBitUserWanted, iTarget))
				{
					if(g_iUserTeam[iTarget] != 1) UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_NOT_TEAM");
					else
					{
						set_pev(iTarget, pev_skin, 3);
						UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_TEAM_TARGET_4");
					}
				}
			}
		}
		case 8: return Open_GlobalGameMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_TeamMenu(id);
}

Open_SmotrGlobalMenu(id)
{
	if(isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_GLOBAL_GAME_SMOTR_TITLE");
	if(g_iDayMode == DAYMODE_STANDART && get_user_flags(id) & ADMIN_IMMUNITY)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_GLOBAL_GAME_SMOTR_MAFIA");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_GLOBAL_GAME_SMOTR_DJIXAD");
		iBitKeys |= (1<<0|1<<1);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_GLOBAL_GAME_SMOTR_MAFIA");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_GLOBAL_GAME_SMOTR_DJIXAD");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_SmotrGlobalMenu");
}

public Close_SmotrGlobalMenu(id, iBitKeys)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iBitKeys)
	{
		case 0: return Open_MafiaMenu(id);
		case 1: return Open_DjixadMenu(id);
		case 8: return Open_ChiefMenu(id);
	}
	return PLUGIN_HANDLED;
}

Open_MafiaMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_MAFIA_TITLE");

	if(g_iGlobalGame == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAFIA_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, g_bDoorStatus ? "JBM_MENU_CHIEF_DOOR_CLOSE" : "JBM_MENU_CHIEF_DOOR_OPEN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MAFIA_GIVE_ROLE");
		if(task_exists(TASK_DAY_VOTE_MAFIA)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[Запущено]^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAFIA_START_VOTE");
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAFIA_START_VOTE");
			iBitKeys |= (1<<3);
		}
		
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 5, id, "JBM_MENU_MAFIA_CHAT", id, g_iMafiaChat ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 6, id, "JBM_MENU_MAFIA_NIGHT", id, g_iMafiaNight ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_MAFIA_GIVE_MIC");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_MAFIA_TAKE_MIC");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 9, id, "JBM_MENU_MAFIA_BOXING", id, g_bBoxingStatus ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iBitKeys |= (1<<0|1<<1|1<<2|1<<4|1<<5|1<<6|1<<7|1<<8);
	}
	else
	{
		if(!g_iGlobalGame)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAFIA_ENABLE");
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_MAFIA_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, g_bDoorStatus ? "JBM_MENU_CHIEF_DOOR_CLOSE" : "JBM_MENU_CHIEF_DOOR_OPEN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MAFIA_GIVE_ROLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_MAFIA_START_VOTE");
		
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 5, id, "JBM_MENU_MAFIA_CHAT", id, g_iMafiaChat ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 6, id, "JBM_MENU_MAFIA_NIGHT", id, g_iMafiaNight ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_MAFIA_GIVE_MIC");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_MAFIA_TAKE_MIC");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 9, id, "JBM_MENU_MAFIA_BOXING", id, g_bBoxingStatus ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
	}
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MafiaMenu");
}

public Close_MafiaMenu(id, iBitKeys)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iBitKeys)
	{
		case 0:
		{
			if(g_iGlobalGame == 1)
			{
				set_user_godmode(id, 0);
				jbm_mafia_disable();
				return PLUGIN_HANDLED;
			}
			else if(!g_iGlobalGame) jbm_mafia_game_start(id); set_user_godmode(id, 1); for(new i; i < charsmax(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
		}
		case 1:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			if(g_bDoorStatus) 
			{
				jbm_close_doors();
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_DOOR_CLOSE", szName);
			}
			else 
			{
				jbm_open_doors();
				set_hudmessage(100, 100, 100, -1.0, 0.8, 0, 0.0, 0.8, 0.2, 0.2, -1);
				ShowSyncHudMsg(0, g_iSyncHudInfo, "%L", LANG_PLAYER, "JBM_ALL_HUD_DOOR_OPEN", szName);
			}
		}
		case 2: return Open_MafiaRoleMenu(id);
		case 3: jbm_vote_choose_mafia_start();
		case 4:
		{
			g_iMafiaChat = !g_iMafiaChat;
			switch(g_iMafiaChat)
			{
				case false: UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_DISABLE_CHAT");
				case true: UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_ENABLE_CHAT");
			}
		}
		case 5: 
		{
			return Show_MafiaTimer(id);
			/*g_iMafiaNight = !g_iMafiaNight;
			switch(g_iMafiaNight)
			{
				case false: for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(isSetBit(g_iBitUserAlive, iPlayer) && g_iUserTeam[iPlayer] == 1) UTIL_ScreenFade(iPlayer, 512, 512, 0, 0, 0, 0, 255, 1);
				case true: for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(isSetBit(g_iBitUserAlive, iPlayer) && g_iUserTeam[iPlayer] == 1) UTIL_ScreenFade(iPlayer, 0, 0, 4, 0, 0, 0, 255);
			}*/
		}
		case 6:
		{
			new szName[32], iPlayer, iCount;
			for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iUserTeam[iPlayer] == 1 && isNotSetBit(g_iBitUserVoice, iPlayer) && isNotSetBit(g_iBitUserBuyVoice, iPlayer) && isSetBit(g_iBitUserAlive, iPlayer))
				{
					iCount++;
					setBit(g_iBitUserVoice, iPlayer);
				}
			}
			if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_GIVE_VOICE_ALL", szName, iCount);
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		}
		case 7: 
		{
			new szName[32], iPlayer, iCount;
			for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iUserTeam[iPlayer] == 1 && isSetBit(g_iBitUserVoice, iPlayer) && isNotSetBit(g_iBitUserBuyVoice, iPlayer) && isSetBit(g_iBitUserAlive, iPlayer))
				{
					iCount++;
					clearBit(g_iBitUserVoice, iPlayer);
				}
			}
			if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_TAKE_VOICE_ALL", szName, iCount);
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		}
		case 8: g_bBoxingStatus = !g_bBoxingStatus;
		case 9: return PLUGIN_HANDLED;
	}
	return Open_MafiaMenu(id);
}

Show_MafiaTimer(id)
{
    new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yРежим времени:^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wГлобальная ночь: \r%s^n", g_iMafiaNight ? "Вкл" : "Выкл");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wМафия: \r%s^n", g_DayMafia ? "Ночь" : "День");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wКомиссар: \r%s^n", g_KomDay ? "Ночь" : "День");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wДоктор: \r%s^n", g_DocDay ? "Ночь" : "День");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wМаньяк: \r%s^n", g_ManDay ? "Ночь" : "День");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wШлюха: \r%s^n^n^n", g_ShlDay ? "Ночь" : "День");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[9] \w%L^n", id, "JBE_MENU_BACK");
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[0] \w%L", id, "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_MafiaTimer");  
}

public Handle_MafiaTimer(id, iKey)
{
    switch(iKey)
    {
    case 0:
        {
            if(!g_iMafiaNight) 
            {
                g_iMafiaNight = 1;
                g_DayMafia = 1;
                g_KomDay = 1;
                g_DocDay = 1;
                g_ManDay = 1;
                g_ShlDay = 1;
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                   // g_MafiaVote[i] = 0;
                   // g_KomVote[i] = 0;
                   // g_DoctorVote[i] = 0;
                   // g_ManyakVote[i] = 0;
                   // g_ShluxaVote[i] = 0;
                  //  g_PlayerVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1])
                    {
                        BlackFade(i, 1);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Наступила ночь, все засыпают.");
                Show_MafiaTimer(id);
            }
            else
            {
                g_iMafiaNight = 0;
                g_DayMafia = 0;
                g_KomDay = 0;
                g_DocDay = 0;
                g_ManDay = 0;
                g_ShlDay = 0;
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1])
                    {
                        BlackFade(i, 0);                             
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Наступил день, все просыпаются.");
                //Show_ResultVote(id, g_iMenuPosition[id]);
            }
        }
    case 1:
        {
            if(!g_DayMafia) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == MAFIA)
                    {
                        BlackFade(i, 1);
                        g_DayMafia = 1;    
                        set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Мафия засыпает...");
                Show_MafiaTimer(id);
            }
            else
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == MAFIA)
                    {
                        BlackFade(i, 0);
                        g_DayMafia = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
              // Cmd_VoteDay(id);
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Мафия просыпается...");
            }
        }
    case 2:
        {
            if(!g_KomDay) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {                        
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == COMISAR)
                    {
                        BlackFade(i, 1);
                        g_KomDay = 1;
                        set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Комиссар засыпает...");
                Show_MafiaTimer(id); 
            }
            else
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == COMISAR)
                    {
                        BlackFade(i, 0);
                        g_KomDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Комиссар просыпается...");
                //Cmd_VoteDay(id);
            }
        }
    case 3:
        {
            if(!g_DocDay) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == DOCTOR)
                    {
                        BlackFade(i, 1);
                        g_DocDay = 1;    
                        set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Доктор засыпает...");
                Show_MafiaTimer(id); 
            }
            else
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    //g_DoctorVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == DOCTOR)
                    {
                        BlackFade(i, 0);
                        g_DocDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Доктор просыпается.");
               // Cmd_VoteDay(id); 
            }
        }
    case 4:
        {
            if(!g_ManDay) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == MANYAK)
                    {
                        BlackFade(i, 1);
                        g_ManDay = 1;
                        set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);            
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Маньяк засыпает...");
                Show_MafiaTimer(id); 
            }
            else
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    //g_ManyakVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == MANYAK)
                    {
                        BlackFade(i, 0);
                        g_ManDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Маньяк просыпается...");
               // Cmd_VoteDay(id); 
            }
        }
    case 5:
        {
            if(!g_ShlDay) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == SHLUHA)
                    {
                        BlackFade(i, 1);
                        g_ShlDay = 1;    
                        set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Ночная бабочка засыпает...");
                Show_MafiaTimer(id); 
            }
            else
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    //g_ShluxaVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_iUserRoleMafia[i] == SHLUHA)
                    {
                        BlackFade(i, 0);
                        g_ShlDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Ночная бабочка просыпается...");
               // Cmd_VoteDay(id);
            }
        }
    case 8: Open_MafiaMenu(id);
    }
    return PLUGIN_HANDLED;
}

stock BlackFade(id, Type)
{
    if(Type == 0)
    {
        message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id);
        write_short(1 << 12);
        write_short(1 << 9);
        write_short(1 << 0);
        write_byte(0);
        write_byte(0);
        write_byte(0);
        write_byte(0);
        message_end();
    }
    else if(Type == 1)
    {
        message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id);
        write_short(1 << 0);
        write_short(1 << 0);
        write_short(1 << 2);
        write_byte(0);
        write_byte(0);
        write_byte(0);
        write_byte(255);
        message_end();
    }
}

Open_MafiaRoleMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame != 1) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\yВыдача ролей^n^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wНет роли^n", id, "JBM_KEY", 1);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wМирный житель^n", id, "JBM_KEY", 2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wМафия^n", id, "JBM_KEY", 3);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wКомисар^n", id, "JBM_KEY", 4);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wДоктор^n", id, "JBM_KEY", 5);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wНочная бабочка^n^n^n^n", id, "JBM_KEY", 6);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MafiaRoleMenu");
}

public Close_MafiaRoleMenu(id, iBitKeys)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame != 1) return PLUGIN_HANDLED;
	switch(iBitKeys)
	{
		case 0: return Open_GiveRoleMafia(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 0, "Забрать роль");
		case 1: return Open_GiveRoleMafia(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 1, "Мирный житель");
		case 2: return Open_GiveRoleMafia(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 2, "Мафия");
		case 3: return Open_GiveRoleMafia(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 3, "Комисар");
		case 4: return Open_GiveRoleMafia(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 4, "Доктор");
		case 5: return Open_GiveRoleMafia(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 5, "Ночная бабочка");
		case 6: return Open_GiveRoleMafia(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 6, "Маньяк");
		case 8: return Open_MafiaMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_MafiaMenu(id);
}

Open_GiveRoleMafia(id, iPos, iRole, title[32])
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || g_iGlobalGame != 1 || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum, g_iMenuTitle[32];
	copy(g_iMenuTitle, charsmax(g_iMenuTitle), title);
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_MafiaRoleMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%s^n^n", g_iMenuTitle);
		default: iLen = formatex(szMenu, charsmax(szMenu), "%s \r[%d|%d]^n^n", g_iMenuTitle, iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		if(g_iUserRoleMafia[i] == iRole) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s^n", id, "JBM_KEY", ++b, szName);
		else
		{
			iBitKeys |= (1<<b);
			if(g_iUserRoleMafia[i] != 0) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[%L]^n", id, "JBM_KEY", ++b, szName, id, g_szMafiaRoleName[g_iUserRoleMafia[i]]);
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_GiveRoleMafia");
}

public Close_GiveRoleMafia(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_GiveRoleMafia(id, --g_iMenuPosition[id], g_iMenuType[id], "Выдача ролей");
		case 8: return Open_GiveRoleMafia(id, ++g_iMenuPosition[id], g_iMenuType[id], "Выдача ролей");
		case 9: return Open_MafiaRoleMenu(id);
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * 7 + iKey];
			if(isNotSetBit(g_iBitUserAlive, iTarget) && g_iUserRoleMafia[iTarget] == g_iMenuType[id]) Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Выдать роль");
			switch(g_iMenuType[id])
			{
				case 0: 
				{
					g_iUserRoleMafia[iTarget] = NONE;
					return Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Забрать роль");
				}
				case 1:  
				{	
					g_iUserRoleMafia[iTarget] = STANDART;
					return Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Мирный житель");
				}
				case 2:
				{
					g_iUserRoleMafia[iTarget] = MAFIA;
					return Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Мафия");
				}
				case 3: 
				{
					g_iUserRoleMafia[iTarget] = COMISAR;
					return Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Комисар");
				}
				case 4: 
				{
					g_iUserRoleMafia[iTarget] = DOCTOR;
					return Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Доктор");
				}
				case 5: 
				{
					g_iUserRoleMafia[iTarget] = SHLUHA;
					return Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Ночная бабочка");
				}
				case 6: 
				{
					g_iUserRoleMafia[iTarget] = MANYAK;
					return Open_GiveRoleMafia(id, g_iMenuPosition[id], g_iMenuType[id], "Маньяк");
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_DjixadMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_DJIXAD_TITLE");

	if(g_iGlobalGame == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DJIXAD_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_DJIXAD_GIVE_ROLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DJIXAD_DAMAGE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_DJIXAD_MUSIC");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DJIXAD_DIGGER_CONTROL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_DJIXAD_SHAHID_CONTROL");
		iBitKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5);
	} 
	else 
	{
		if(!g_iGlobalGame)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DJIXAD_ENABLE");
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DJIXAD_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_DJIXAD_GIVE_ROLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DJIXAD_DAMAGE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_DJIXAD_MUSIC");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DJIXAD_DIGGER_CONTROL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_DJIXAD_SHAHID_CONTROL");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DjixadMenu");
}

public Close_DjixadMenu(id, iBitKeys)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iBitKeys)
	{
		case 0: 
		{
			if(g_iGlobalGame == 2)
			{
				set_user_godmode(id, 0);
				jbm_djixad_disable();
				return PLUGIN_HANDLED;
			}
			else if(!g_iGlobalGame && g_iDayMode == DAYMODE_STANDART) 
			{
				for(new i; i < charsmax(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
				EnableHamForward(g_iHamHookForwardsDjihad);
				formatex(g_szDayMode, charsmax(g_szDayMode), "JBM_HUD_GAME_MODE_DJIXAD");
				g_iGlobalGame = 2;
				set_user_godmode(id, 1);
				for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
				{
					if(g_iUserTeam[iPlayer] != 1 || isNotSetBit(g_iBitUserAlive, iPlayer)) continue;
					g_iUserRoleDjixad[iPlayer] = 0;
					clearBit(g_iBitUserBury, iPlayer);
					set_task(1.0, "jbm_show_role_informer", iPlayer+TASK_SHOW_ROLE_GG, _, _, "b");
				}
			}
		}
		case 1: return Open_DjixadRoleMenu_1(id);
		case 2: 
		{
			switch(g_bBoxingStatus)
			{
				case false:
				{
					g_bBoxingStatus = true;
					UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_DJIXAD_BOX_ENABLE");
				}
				case true:
				{
					UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_DJIXAD_BOX_ALREADY_ENABLE");
				}
			}
		}
		case 3: return Open_MusicMenu(id, g_iMenuPosition[id] = 0);
		case 4: return Open_BuryPlayerDjixad(id, g_iMenuPosition[id] = 0);
		case 5: return Open_BurnPlayerDjixad(id, g_iMenuPosition[id] = 0);
		case 8: return Open_ChiefMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_DjixadMenu(id);
}

Open_DjixadRoleMenu_1(id)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame != 2) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wВыдача ролей \r[1|2]^n^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wЗабрать роль^n^n", id, "JBM_KEY", 1);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wКэмпер^n", id, "JBM_KEY", 2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wДжабба^n", id, "JBM_KEY", 3);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wМарсианин^n", id, "JBM_KEY", 4);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wГлиста^n", id, "JBM_KEY", 5);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wШпион^n", id, "JBM_KEY", 6);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wКонтрабандист^n", id, "JBM_KEY", 7);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wОмоновец^n", id, "JBM_KEY", 8);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DjixadRoleMenu_1");
}

public Close_DjixadRoleMenu_1(id, iBitKeys)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame != 2) return PLUGIN_HANDLED;
	switch(iBitKeys)
	{
		case 0: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 0, "Забрать роль");
		case 1: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 1, "Кэмпер");
		case 2: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 2, "Джабба");
		case 3: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 3, "Марсианин");
		case 4: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 4, "Глиста");
		case 5: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 5, "Шпион");
		case 6: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 6, "Контрабандист");
		case 7: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 7, "Омоновец");
		case 8: return Open_DjixadRoleMenu_2(id);
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

Open_DjixadRoleMenu_2(id)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame != 2) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wВыдача ролей \r[2|2]^n^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wАльтаир^n", id, "JBM_KEY", 1);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wФея^n", id, "JBM_KEY", 2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wКопатель^n", id, "JBM_KEY", 3);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wХохол^n", id, "JBM_KEY", 4);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wШахид^n^n^n^n", id, "JBM_KEY", 5);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DjixadRoleMenu_2");
}

public Close_DjixadRoleMenu_2(id, iBitKeys)
{
	if(g_iDayMode != DAYMODE_STANDART || isNotSetBit(g_iBitUserAlive, id) || g_iGlobalGame != 2) return PLUGIN_HANDLED;
	switch(iBitKeys)
	{
		case 0: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 8, "Альтаир");
		case 1: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 9, "Фея");
		case 2: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 10, "Копатель");
		case 3: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 11, "Хохол");
		case 4: return Open_GiveRoleDjixad(id, g_iMenuPosition[id] = 0, g_iMenuType[id] = 12, "Шахид");
		case 8: return Open_DjixadRoleMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_DjixadMenu(id);
}

Open_GiveRoleDjixad(id, iPos, iRole, title[32])
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || g_iGlobalGame != 2 || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum, g_iMenuTitle[32];
	copy(g_iMenuTitle, charsmax(g_iMenuTitle), title);
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_DjixadMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \w%s^n^n", g_iMenuTitle);
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \w%s \r[%d|%d]^n^n", g_iMenuTitle, iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		if(g_iUserRoleDjixad[i] == iRole) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s^n", id, "JBM_KEY", ++b, szName);
		else
		{
			iBitKeys |= (1<<b);
			if(g_iUserRoleDjixad[i] != 0) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \r(%L)^n", id, "JBM_KEY", ++b, szName, id, g_szDjixadRoleName[g_iUserRoleDjixad[i]]);
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_GiveRoleDjixad");
}

public Close_GiveRoleDjixad(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_GiveRoleDjixad(id, --g_iMenuPosition[id], g_iMenuType[id], "Выдача ролей");
		case 8: return Open_GiveRoleDjixad(id, ++g_iMenuPosition[id], g_iMenuType[id], "Выдача ролей");
		case 9: return Open_DjixadRoleMenu_1(id);
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isNotSetBit(g_iBitUserAlive, iTarget) && g_iUserRoleDjixad[iTarget] == g_iMenuType[id]) Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id], "Выдать роль");
			switch(g_iMenuType[id])
			{
				case 0:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 100.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					g_iUserRoleDjixad[iTarget] = 0;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 0, "Забрать роль");
				}
				case 1:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 1000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_awp");
					fm_give_item(iTarget, "weapon_usp");
					fm_give_item(iTarget, "weapon_knife");
					fm_set_user_bpammo(iTarget, CSW_AWP, 1000);
					fm_set_user_bpammo(iTarget, CSW_USP, 1000);
					g_iUserRoleDjixad[iTarget] = 1;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_KAMPER");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 1, "Кэмпер");
				}
				case 2:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 5000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_m249");
					fm_give_item(iTarget, "weapon_deagle");
					fm_give_item(iTarget, "weapon_knife");
					fm_set_user_bpammo(iTarget, CSW_M249, 1000);
					fm_set_user_bpammo(iTarget, CSW_DEAGLE, 1000);
					g_iUserRoleDjixad[iTarget] = 2;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 50.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_DJABBA");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 2, "Джабба");
				}
				case 3:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 300.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_usp");
					fm_give_item(iTarget, "weapon_knife");
					fm_set_user_bpammo(iTarget, CSW_USP, 1000);
					g_iUserRoleDjixad[iTarget] = 3;
					jbm_set_user_rendering(iTarget, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 10);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 500.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_MARSIANIN");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 3, "Марсианин");
				}
				case 4:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 1000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_glock18");
					fm_give_item(iTarget, "weapon_m3");
					fm_give_item(iTarget, "weapon_xm1014");
					fm_set_user_bpammo(iTarget, CSW_GLOCK18, 1000);
					fm_set_user_bpammo(iTarget, CSW_M3, 1000);
					fm_set_user_bpammo(iTarget, CSW_XM1014, 1000);
					g_iUserRoleDjixad[iTarget] = 4;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 1000.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_GLISTA");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 4, "Глиста");
				}
				case 5:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 1);
					set_pev(iTarget, pev_health, 800.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_usp");
					fm_set_user_bpammo(iTarget, CSW_USP, 1000);
					g_iUserRoleDjixad[iTarget] = 5;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 600.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_SPY");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 5, "Шпион");
				}
				case 6:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 1000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_elite");
					fm_give_item(iTarget, "weapon_scout");
					fm_give_item(iTarget, "weapon_mp5navy");
					fm_give_item(iTarget, "weapon_tmp");
					fm_give_item(iTarget, "weapon_mac10");
					fm_set_user_bpammo(iTarget, CSW_ELITE, 1000);
					fm_set_user_bpammo(iTarget, CSW_SCOUT, 1000);
					fm_set_user_bpammo(iTarget, CSW_MP5NAVY, 1000);
					fm_set_user_bpammo(iTarget, CSW_TMP, 1000);
					fm_set_user_bpammo(iTarget, CSW_MAC10, 1000);
					g_iUserRoleDjixad[iTarget] = 6;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_KONTRABANDIST");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 6, "Контрабандист");
				}
				case 7:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 2000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "item_kevlar");
					fm_give_item(iTarget, "weapon_deagle");
					fm_set_user_bpammo(iTarget, CSW_DEAGLE, 1000);
					g_iUserRoleDjixad[iTarget] = 7;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_OMONOVEC");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 7, "Омоновец");
				}
				case 8:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 1000.0);
					set_pev(iTarget, pev_gravity, 0.4);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_ak47");
					fm_give_item(iTarget, "weapon_elite");
					fm_set_user_bpammo(iTarget, CSW_AK47, 1000);
					fm_set_user_bpammo(iTarget, CSW_ELITE, 1000);
					g_iUserRoleDjixad[iTarget] = 8;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_ALTAIR");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 8, "Альтаир");
				}
				case 9:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 1000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_deagle");
					fm_give_item(iTarget, "weapon_g3sg1");
					fm_set_user_bpammo(iTarget, CSW_DEAGLE, 1000);
					fm_set_user_bpammo(iTarget, CSW_G3SG1, 1000);
					g_iUserRoleDjixad[iTarget] = 9;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_FEYA");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 9, "Фея");
				}
				case 10:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 10000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_g3sg1");
					fm_give_item(iTarget, "weapon_elite");
					fm_set_user_bpammo(iTarget, CSW_G3SG1, 1000);
					fm_set_user_bpammo(iTarget, CSW_ELITE, 1000);
					g_iUserRoleDjixad[iTarget] = 10;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_DIGGER");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 10, "Копатель");
				}
				case 11:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 1000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_m4a1");
					fm_give_item(iTarget, "weapon_deagle");
					fm_set_user_bpammo(iTarget, CSW_M4A1, 1000);
					fm_set_user_bpammo(iTarget, CSW_DEAGLE, 1000);
					g_iUserRoleDjixad[iTarget] = 11;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_XOXOL");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 11, "Хохол");
				}
				case 12:
				{
					set_pdata_int(iTarget, m_iFov, 90, linux_diff_player);
					jbm_hide_user_costumes(iTarget);
					strip_user_weapons(iTarget);
					set_user_footsteps(iTarget, 0);
					set_pev(iTarget, pev_health, 7000.0);
					set_pev(iTarget, pev_gravity, 1.0);
					fm_strip_user_weapons(iTarget, 1);
					fm_give_item(iTarget, "weapon_knife");
					fm_give_item(iTarget, "weapon_glock18");
					fm_give_item(iTarget, "weapon_mac10");
					fm_set_user_bpammo(iTarget, CSW_GLOCK18, 1000);
					fm_set_user_bpammo(iTarget, CSW_MAC10, 1000);
					g_iUserRoleDjixad[iTarget] = 12;
					jbm_set_user_rendering(iTarget, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
					jbm_get_user_rendering(iTarget, g_eUserRendering[iTarget][RENDER_FX], g_eUserRendering[iTarget][RENDER_RED], g_eUserRendering[iTarget][RENDER_GREEN], g_eUserRendering[iTarget][RENDER_BLUE], g_eUserRendering[iTarget][RENDER_MODE], g_eUserRendering[iTarget][RENDER_AMT]);
					g_eUserRendering[iTarget][RENDER_STATUS] = true;
					g_fUserSpeed[iTarget] = 0.0;
					ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
					UTIL_SayText(iTarget, "!y[!gJBM!y] %L", LANG_PLAYER, "JBM_ID_CHAT_GIVEN_ROLE", LANG_PLAYER, "JBM_ROLE_SHAHID");
					return Open_GiveRoleDjixad(id, g_iMenuPosition[id], g_iMenuType[id] = 12, "Шахид");
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_BuryPlayerDjixad(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || g_iGlobalGame != 2 || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || g_iUserRoleDjixad[i] != 10) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_DjixadMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "\yУправление копателями^n^n");
		default: iLen = formatex(szMenu, charsmax(szMenu), "\yУправление копателями \r[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));

		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[%s]^n", id, "JBM_KEY", ++b, szName, isSetBit(g_iBitUserBury, i) ? "Откопать" : "Закапать");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_BuryPlayerDjixad");
}

public Close_BuryPlayerDjixad(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_BuryPlayerDjixad(id, --g_iMenuPosition[id]);
		case 8: return Open_BuryPlayerDjixad(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] != 1 || isNotSetBit(g_iBitUserAlive, iTarget) || g_iUserRoleDjixad[iTarget] != 10) return Open_BuryPlayerDjixad(id, g_iMenuPosition[id]);
			
			new szNameChief[32], szNameTarget[32];
			get_user_name(id, szNameChief, charsmax(szNameChief));
			get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
			if(isNotSetBit(g_iBitUserBury, iTarget))
			{	
				setBit(g_iBitUserBury, iTarget);
				new Float:vecOrigin[3];
				pev(iTarget, pev_origin, vecOrigin);
						
				vecOrigin[2] -= 30.0;
					
				set_pev(iTarget, pev_origin, vecOrigin);
					
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY); 
				write_byte(TE_BREAKMODEL);
				write_coord(floatround(vecOrigin[0]));
				write_coord(floatround(vecOrigin[1]));
				write_coord(floatround(vecOrigin[2]) + 24);
				write_coord(16);
				write_coord(16);
				write_coord(16);
				write_coord(random_num(-50,50));
				write_coord(random_num(-50,50));
				write_coord(25);
				write_byte(10);
				write_short(g_pModelDirt);
				write_byte(9);
				write_byte(20);
				write_byte(0x08);
				message_end();
				
				UTIL_SayText(0, "!y[!gJBM!y] Ведущий !t%s !yзакапал копателя !g%s", szNameChief, szNameTarget);
				return Open_BuryPlayerDjixad(id, g_iMenuPosition[id]);
				
			}
			else
			{
				clearBit(g_iBitUserBury, iTarget);
				new Float:vecOrigin[3];
				pev(iTarget, pev_origin, vecOrigin);
				vecOrigin[2] += 30.0;
				set_pev(iTarget, pev_origin, vecOrigin);
					
				UTIL_SayText(0, "!y[!gJBM!y] Ведущий !t%s !yоткапал копателя !g%s", szNameChief, szNameTarget);
				return Open_BuryPlayerDjixad(id, g_iMenuPosition[id]);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_BurnPlayerDjixad(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || g_iGlobalGame != 2 || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || g_iUserRoleDjixad[i] != 12) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_DjixadMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "\yУправление шахидами^n^n");
		default: iLen = formatex(szMenu, charsmax(szMenu), "\yУправление шахидами \r[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));

		if(isNotSetBit(g_iBitUserBurn, i))
		{
			iBitKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[Поджечь]^n", id, "JBM_KEY", ++b, szName);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s^n", id, "JBM_KEY", ++b, szName);
	
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_BurnPlayerDjixad");
}

public Close_BurnPlayerDjixad(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_BurnPlayerDjixad(id, --g_iMenuPosition[id]);
		case 8: return Open_BurnPlayerDjixad(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] != 1 || isNotSetBit(g_iBitUserAlive, iTarget) || g_iUserRoleDjixad[iTarget] != 12) return Open_BurnPlayerDjixad(id, g_iMenuPosition[id]);
			
			new szNameChief[32], szNameTarget[32];
			get_user_name(id, szNameChief, charsmax(szNameChief));
			get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
			if(isNotSetBit(g_iBitUserBurn, iTarget))
			{
				UTIL_SetBurn(iTarget, 0);
				UTIL_SayText(0, "!y[!gJBM!y] Ведущий !t%s !yподжег шахида !g%s", szNameChief, szNameTarget);
				return Open_BurnPlayerDjixad(id, g_iMenuPosition[id]);
			}
			else
			{
				UTIL_RemoveBurn(iTarget);
				UTIL_SayText(0, "!y[!gJBM!y] Ведущий !t%s !yпотушил шахида !g%s", szNameChief, szNameTarget);
				return Open_BurnPlayerDjixad(id, g_iMenuPosition[id]);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_ChiefTwoMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<1|1<<2|1<<3|1<<4|1<<6|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_CHIEF_TWO_TITLE");
	if(g_iDayMode == DAYMODE_STANDART)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_CHIEF_FREE_DAY_CONTROL");
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_CHIEF_FREE_DAY_CONTROL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_CHIEF_VOICE_CONTROL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_CHIEF_WANTED_TAKE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_CHIEF_TREAT_PRISONER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_CHIEF_PRISONERS_DIVIDE_COLOR");
	if(g_iAlivePlayersNum[1] >= 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_CHIEF_PRISONERS_DUEL");
		iBitKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_CHIEF_PRISONERS_DUEL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wБлоки Minecraft^n^n", id, "JBM_KEY", 7, id);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ChiefTwoMenu");
}

public Close_ChiefTwoMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: if(g_iDayMode == DAYMODE_STANDART) return Open_FreeDayControlMenu(id, g_iMenuPosition[id] = 0);
		case 1: return Open_VoiceControlMenu(id);
		case 2: return Open_TakeWantedMenu(id);
		case 3: return Open_TreatPrisonerMenu(id);
		case 4: return Open_PrisonersDivideColorMenu(id);
		case 5: if(g_iAlivePlayersNum[1] >= 2) return Open_DuelPnMenu(id);
		case 6: client_cmd(id,"minecraft");
		case 8: return Open_ChiefMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_ChiefTwoMenu(id);
}

Open_FreeDayControlMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isSetBit(g_iBitUserFreeNextRound, i) || isSetBit(g_iBitUserWanted, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ChiefTwoMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_FREE_DAY_CONTROL_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_FREE_DAY_CONTROL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[%L]^n", id, "JBM_KEY", ++b, szName, i, isSetBit(g_iBitUserFree, i) ? "JBM_MENU_FREE_DAY_CONTROL_TAKE" : "JBM_MENU_FREE_DAY_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_FreeDayControlMenu");
}

public Close_FreeDayControlMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_FreeDayControlMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_FreeDayControlMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] != 1 || isSetBit(g_iBitUserFreeNextRound, iTarget) || isSetBit(g_iBitUserWanted, iTarget)) return Open_FreeDayControlMenu(id, g_iMenuPosition[id]);
			new szName[32], szTargetName[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(isSetBit(g_iBitUserFree, iTarget))
			{
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_CHIEF_TAKE_FREE_DAY", szName, szTargetName);
				jbm_sub_user_free(iTarget);
			}
			else
			{
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_CHIEF_GIVE_FREE_DAY", szName, szTargetName);
				if(isSetBit(g_iBitUserAlive, iTarget)) jbm_add_user_free(iTarget);
				else
				{
					jbm_add_user_free_next_round(iTarget);
					UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_AUTO_FREE_DAY", szTargetName);
				}
			}
		}
	}
	return Open_FreeDayControlMenu(id, g_iMenuPosition[id]);
}

Open_VoiceControlMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_VOICE_CONTROL_PRISONER_MENU_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_VOICE_CONTROL_PRISONER_MENU_GIVE_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_VOICE_CONTROL_PRISONER_MENU_TAKE_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_VOICE_CONTROL_PRISONER_MENU_ID");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<8|1<<9), szMenu, -1, "Open_VoiceControlMenu");
}

public Close_VoiceControlMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szName[32], iPlayer, iCount;
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iUserTeam[iPlayer] == 1 && isNotSetBit(g_iBitUserVoice, iPlayer) && isNotSetBit(g_iBitUserBuyVoice, iPlayer) && isSetBit(g_iBitUserAlive, iPlayer))
				{
					iCount++;
					setBit(g_iBitUserVoice, iPlayer);
				}
			}
			if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_GIVE_VOICE_ALL", szName, iCount);
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		}
		case 1:
		{
			for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iUserTeam[iPlayer] == 1 && isSetBit(g_iBitUserVoice, iPlayer) && isNotSetBit(g_iBitUserBuyVoice, iPlayer) && isSetBit(g_iBitUserAlive, iPlayer))
				{
					iCount++;
					clearBit(g_iBitUserVoice, iPlayer);
				}
			}
			if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_TAKE_VOICE_ALL", szName, iCount);
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		}
		case 2: return Open_VoiceControlIdMenu(id, g_iMenuPosition[id] = 0);
		case 8: return Open_ChiefTwoMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_VoiceControlMenu(id);
}

Open_VoiceControlIdMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || isSetBit(g_iBitUserBuyVoice, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_VoiceControlMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_VOICE_CONTROL_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_VOICE_CONTROL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[%L]^n", id, "JBM_KEY", ++b, szName, id, isSetBit(g_iBitUserVoice, i) ? "JBM_MENU_CHIEF_VOICE_CONTROL_TAKE" : "JBM_MENU_CHIEF_VOICE_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_VoiceControlIdMenu");
}

public Close_VoiceControlIdMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_VoiceControlIdMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_VoiceControlIdMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isNotSetBit(g_iBitUserAlive, iTarget) || g_iUserTeam[iTarget] != 1) return Open_VoiceControlIdMenu(id, g_iMenuPosition[id]);
			new szName[32], szTargetName[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(isSetBit(g_iBitUserVoice, iTarget))
			{
				clearBit(g_iBitUserVoice, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_CHIEF_TAKE_VOICE", szName, szTargetName);
			}
			else
			{
				setBit(g_iBitUserVoice, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_CHIEF_GIVE_VOICE", szName, szTargetName);
			}
		}
	}
	return Open_VoiceControlIdMenu(id, g_iMenuPosition[id]);
}

Open_TakeWantedMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_TAKE_WANTED_PRISONER_MENU_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_TAKE_WANTED_PRISONER_MENU_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_TAKE_WANTED_PRISONER_MENU_ID");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<8|1<<9), szMenu, -1, "Open_TakeWantedMenu");
}

public Close_TakeWantedMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szName[32], iPlayer, iCount;
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iUserTeam[iPlayer] == 1 && isSetBit(g_iBitUserWanted, iPlayer))
				{
					iCount++;
					jbm_sub_user_wanted(iPlayer);
				}
			}
			if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_TAKE_WANTED_ALL", szName, iCount);
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		}
		case 1: return Open_TakeWantedIdMenu(id, g_iMenuPosition[id] = 0);
		case 8: return Open_ChiefTwoMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_TakeWantedMenu(id);
}

Open_TakeWantedIdMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserWanted, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_TakeWantedMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_WANTED_CONTROL_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_WANTED_CONTROL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_TakeWantedIdMenu");
}

public Close_TakeWantedIdMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_TakeWantedIdMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_TakeWantedIdMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isNotSetBit(g_iBitUserAlive, iTarget) || g_iUserTeam[iTarget] != 1 || isNotSetBit(g_iBitUserWanted, iTarget)) return Open_TakeWantedIdMenu(id, g_iMenuPosition[id]);
			new szName[32], szTargetName[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(isSetBit(g_iBitUserWanted, iTarget))
			{
				jbm_sub_user_wanted(iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_CHIEF_TAKE_WANTED", szName, szTargetName);
			}
		}
	}
	return Open_TakeWantedIdMenu(id, g_iMenuPosition[id]);
}

Open_TreatPrisonerMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_TREAT_PRISONER_MENU_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_TREAT_PRISONER_MENU_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_TREAT_PRISONER_MENU_WITHOUT_WANTED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_TREAT_PRISONER_MENU_ID");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<8|1<<9), szMenu, -1, "Open_TreatPrisonerMenu");
}

public Close_TreatPrisonerMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szName[32], iPlayer, iCount;
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iUserTeam[iPlayer] == 1 && isSetBit(g_iBitUserAlive, iPlayer) && isNotSetBit(g_iBitUserSoccer, iPlayer)
				&& isNotSetBit(g_iBitUserDuel, iPlayer) && get_user_health(iPlayer) < 100)
				{
					iCount++;
					set_pev(iPlayer, pev_health, 100.0);
				}
			}
			if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_TREAT_PRISONER_ALL", szName, iCount);
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		}
		case 1:
		{
			for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iUserTeam[iPlayer] == 1 && isSetBit(g_iBitUserAlive, iPlayer) && isNotSetBit(g_iBitUserSoccer, iPlayer)
				&& isNotSetBit(g_iBitUserDuel, iPlayer) && isNotSetBit(g_iBitUserWanted, iPlayer) && get_user_health(iPlayer) < 100)
				{
					iCount++;
					set_pev(iPlayer, pev_health, 100.0);
				}
			}
			if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_CHIEF_TREAT_PRISONER_WITHOUT_WANTED", szName, iCount);
			else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
		}
		case 2: return Open_TreatPrisonerIdMenu(id, g_iMenuPosition[id] = 0);
		case 8: return Open_ChiefTwoMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_TreatPrisonerMenu(id);
}

Open_TreatPrisonerIdMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || get_user_health(i) >= 100 || isSetBit(g_iBitUserDuel, id)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_TreatPrisonerMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_TREAT_PRISONER_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_TREAT_PRISONER_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[%d HP]^n", id, "JBM_KEY", ++b, szName, get_user_health(i));
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_TreatPrisonerIdMenu");
}

public Close_TreatPrisonerIdMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_TreatPrisonerIdMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_TreatPrisonerIdMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 1 && isSetBit(g_iBitUserAlive, iTarget) && get_user_health(iTarget) < 100 && isNotSetBit(g_iBitUserDuel, id))
			{
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_CHIEF_TREAT_PRISONER", szName, szTargetName);
				set_pev(iTarget, pev_health, 100.0);
			}
		}
	}
	return Open_TreatPrisonerIdMenu(id, g_iMenuPosition[id]);
}

Open_PrisonersDivideColorMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_PRISONERS_DIVIDE_COLOR_TITLE");
	if(g_iAlivePlayersNum[1] >= 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_PRISONERS_DIVIDE_COLOR_2");
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_PRISONERS_DIVIDE_COLOR_2");
	if(g_iAlivePlayersNum[1] >= 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_PRISONERS_DIVIDE_COLOR_3");
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_PRISONERS_DIVIDE_COLOR_3");
	if(g_iAlivePlayersNum[1] >= 4)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_PRISONERS_DIVIDE_COLOR_4");
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n^n^n^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_PRISONERS_DIVIDE_COLOR_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_PrisonersDivideColorMenu");
}

public Close_PrisonersDivideColorMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: return Open_ChiefTwoMenu(id);
		case 9: return PLUGIN_HANDLED;
		default: jbm_prisoners_divide_color(iKey + 2);
	}
	return Open_PrisonersDivideColorMenu(id);
}

Open_DuelPnMenu(id)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_PN_DUEL_TITLE");
	new szName[2][32];
	if(g_iDuelUsersId[0] && isSetBit(g_iBitUserAlive, g_iDuelUsersId[0])) 
	{
		get_user_name(g_iDuelUsersId[0], szName[0], charsmax(szName[]));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_PN_DUEL_FIRST", szName[0]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_PN_DUEL_FIRST_2");
	
	if(g_iDuelUsersId[1] && isSetBit(g_iBitUserAlive, g_iDuelUsersId[1])) 
	{
		get_user_name(g_iDuelUsersId[1], szName[1], charsmax(szName[]));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 2, id, "JBM_MENU_PN_DUEL_SECOND", szName[1]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 2, id, "JBM_MENU_PN_DUEL_SECOND_2");
	if(g_iDuelType) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_PN_DUEL_WEAPON", id, g_szDuelLang[g_iDuelType]);
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_PN_DUEL_WEAPON_2");
	if(isSetBit(g_iBitUserAlive, g_iDuelUsersId[0]) && isSetBit(g_iBitUserAlive, g_iDuelUsersId[1]) && g_iDuelType && !g_iDuelStatus && g_iDuelType != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_PN_DUEL_START");
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_PN_DUEL_START");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DuelPnMenu");
}

public Close_DuelPnMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: { g_iMenuType[id] = 0; return Open_ChooseDuelPnMenu(id, g_iMenuPosition[id] = 0); }
		case 1: { g_iMenuType[id] = 1; return Open_ChooseDuelPnMenu(id, g_iMenuPosition[id] = 0); }
		case 2:
		{
			if(g_iDuelStatus) { UTIL_SayText(id, "!y[!gJBM!y] В данный момент идет дуэль."); }
			else
			{
				if(g_iDuelType == 6) g_iDuelType = 0;
				else g_iDuelType++;
			}
		}
		case 3:
		{
			if(isSetBit(g_iBitUserAlive, g_iDuelUsersId[0]) && isSetBit(g_iBitUserAlive, g_iDuelUsersId[1]) && g_iDuelType && !g_iDuelStatus && g_iDuelType != 3)
			{
				g_iDuelTypeFair = 1;
				g_iDuelTimeToAttack = 1;
				g_iDuelPrize = 0;
				jbm_duel_start_ready(g_iDuelUsersId[0], g_iDuelUsersId[1]);
			}
		}
		case 8: return Open_ChiefTwoMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_DuelPnMenu(id);
}

Open_ChooseDuelPnMenu(id, iPos)
{
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i) || g_iDuelUsersId[0] == i || g_iDuelUsersId[1] == i) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_DuelPnMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_PN_DUEL_CHOOSE_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_PN_DUEL_CHOOSE_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ChooseDuelPnMenu");
}

public Close_ChooseDuelPnMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || id != g_iChiefId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_ChooseDuelPnMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_ChooseDuelPnMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			if(g_iDuelStatus) 
				return Open_DuelPnMenu(id);
			
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 1 && isSetBit(g_iBitUserAlive, iTarget))
				g_iDuelUsersId[g_iMenuType[id]] = iTarget;
			return Open_DuelPnMenu(id);
		}
	}
	return Open_TreatPrisonerIdMenu(id, g_iMenuPosition[id]);
}

Open_KillReasonsMenu(id, iTarget)
{
	new szName[32], szMenu[512], iLen;
	get_user_name(iTarget, szName, charsmax(szName));
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_KILL_REASON_TITLE", szName);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_KILL_REASON_0");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_KILL_REASON_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_KILL_REASON_2");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_KILL_REASON_3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_KILL_REASON_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_KILL_REASON_5");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_KILL_REASON_6");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_KILL_REASON_7");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8), szMenu, -1, "Open_KillReasonsMenu");
}

public Close_KillReasonsMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Open_KilledUsersMenu(id, g_iMenuPosition[id] = 0);
		default:
		{
			if(isSetBit(g_iBitKilledUsers[id], g_iMenuTarget[id]))
			{
				new szName[32], szNameTarget[32], szLangPlayer[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(g_iMenuTarget[id], szNameTarget, charsmax(szNameTarget));
				formatex(szLangPlayer, charsmax(szLangPlayer), "JBM_MENU_KILL_REASON_%d", iKey);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_KILL_REASON", szName, szNameTarget, LANG_PLAYER, szLangPlayer);
				if(iKey == 7)
				{
					UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_AUTO_FREE_DAY", szNameTarget);
					jbm_add_user_free_next_round(g_iMenuTarget[id]);
				}
				clearBit(g_iBitKilledUsers[id], g_iMenuTarget[id]);
				if(g_iBitKilledUsers[id]) return Open_KilledUsersMenu(id, g_iMenuPosition[id] = 0);
			}
			else
			{
				if(g_iBitKilledUsers[id]) return Open_KilledUsersMenu(id, g_iMenuPosition[id] = 0);
				UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_KILLED_USER_DISCONNECT");
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_KilledUsersMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitKilledUsers[id], i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_KILLED_USER_DISCONNECT");
			jbm_menu_unblock(id);
			return PLUGIN_HANDLED;
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_KILLED_USERS_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_KILLED_USERS_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys, b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iBitKeys |= (1<<8);
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT", id, "JBM_KEY", 0, id, "JBM_MENU_BACK");
			iBitKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	}
	else
	{
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_BACK");
			iBitKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n%L \d%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	}
	return show_menu(id, iBitKeys, szMenu, -1, "Open_KilledUsersMenu");
}

public Close_KilledUsersMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_KilledUsersMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_KilledUsersMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			g_iMenuTarget[id] = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isSetBit(g_iBitKilledUsers[id], g_iMenuTarget[id])) return Open_KillReasonsMenu(id, g_iMenuTarget[id]);
			else if(g_iBitKilledUsers[id]) return Open_KilledUsersMenu(id, g_iMenuPosition[id] = 0);
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_KILLED_USER_DISCONNECT");
			jbm_menu_unblock(id);
		}
	}
	return PLUGIN_HANDLED;
}

Open_LastPrisonerMenu(id)
{
	if(g_iDuelStatus || isNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_LAST_PRISONER_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_LAST_PRISONER_FREE_DAY");
	if(isNotSetBit(g_iBitUserBuyVoice, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_LAST_PRISONER_VOICE");
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_LAST_PRISONER_VOICE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 3, id, "JBM_MENU_LAST_PRISONER_MONEY", g_iAllCvars[LAST_PRISONER_MONEY]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L^n", id, "JBM_MENU_LAST_PRISONER_DUEL_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_LAST_PRISONER_DUEL_PRIZE", id, g_szDuelPrizeLang[g_iDuelPrize]);
	if(g_iDuelPrizeId == id) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_LAST_PRISONER_PRIZE_ID");
	else 
	{
		new szName[32]; get_user_name(g_iDuelPrizeId, szName, charsmax(szName));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_LAST_PRISONER_PRIZE_ID_2", szName);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_LAST_PRISONER_DUEL");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_LastPrisonerMenu");
}

public Close_LastPrisonerMenu(id, iKey)
{
	if(g_iDuelStatus || isNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			ExecuteHamB(Ham_Killed, id, id, 0);
			jbm_add_user_free_next_round(id);
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			ExecuteHamB(Ham_Killed, id, id, 0);
			setBit(g_iBitUserVoiceNextRound, id);
			return PLUGIN_HANDLED;
		}
		case 2:
		{
			ExecuteHamB(Ham_Killed, id, id, 0);
			jbm_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[LAST_PRISONER_MONEY], 1);
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			if(g_iDuelPrize == charsmax(g_szDuelPrizeLang)) g_iDuelPrize = 0;
			else g_iDuelPrize++;
		}
		case 4: return Open_ChoiceDuelPrizeWinner(id, g_iMenuPosition[id] = 0);
		case 5: return Open_DuelMenu(id);
		case 8: return Open_MainPnMenu(id);
	}
	return Open_LastPrisonerMenu(id);
}

Open_ChoiceDuelPrizeWinner(id, iPos)
{
	if(id != g_iLastPnId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	if(iPos < 0) return Open_LastPrisonerMenu(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserConnected, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_LastPrisonerMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_DUEL_PRIZE_ID_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_DUEL_PRIZE_ID_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<7|1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		if(i == g_iDuelPrizeId) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s \y[Выбран]^n", id, "JBM_KEY", ++b, szName);
		else
		{
			iBitKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s %s^n", id, "JBM_KEY", ++b, szName, i == id ? "\rЭто вы" : "");
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ChoiceDuelPrizeWinner");
}

public Close_ChooseDuelPrizeWinner(id, iKey)
{
	if(id != g_iLastPnId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_ChoiceDuelPrizeWinner(id, --g_iMenuPosition[id]);
		case 8: return Open_ChoiceDuelPrizeWinner(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 1 && isSetBit(g_iBitUserConnected, iTarget))
			{
				g_iDuelPrizeId = iTarget;
				return Open_LastPrisonerMenu(id);
			}
		}
	}
	return Open_ChoiceDuelPrizeWinner(id, g_iMenuPosition[id] = 0);
}

Open_DuelMenu(id)
{
	if(isNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<3|1<<4|1<<8|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_DUEL_SETTINGS_TITLE", id, g_szDuelPrizeLang[g_iDuelPrize]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DUEL_SETTINGS_TYPE", g_iDuelTypeFair ? "Честная" : "Не честная");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_DUEL_SETTINGS_WEAPON", id, g_szDuelLang[g_iDuelType]);
	if(g_iDuelTypeFair)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DUEL_SETTINGS_TIME", g_iTimeAttack[g_iDuelTimeToAttack]);
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DUEL_SETTINGS_TIME_2");
	if(isSetBit(g_iBitUserAlive, g_iDuelUsersId[1]) && g_iUserTeam[g_iDuelUsersId[1]] == 2) 
	{
		new szName[32]; get_user_name(g_iDuelUsersId[1], szName, charsmax(szName));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_DUEL_SETTINGS_VERSUS", szName);
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_DUEL_SETTINGS_VERSUS_2");
	if(g_iDuelType && isSetBit(g_iBitUserAlive, g_iDuelUsersId[1]))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DUEL_SETTINGS_START");
		iBitKeys |= (1<<5);
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DUEL_SETTINGS_START");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DuelMenu");
}

public Close_DuelMenu(id, iKey)
{
	if(isNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: g_iDuelTypeFair = !g_iDuelTypeFair;
		case 1: return Open_ChoiceDuelMenu(id);
		case 2:
		{
			if(g_iDuelTimeToAttack == charsmax(g_iTimeAttack)) g_iDuelTimeToAttack = 0;
			else g_iDuelTimeToAttack++;
		}
		case 3: return Open_DuelUsersMenu(id, g_iMenuPosition[id] = 0);
		case 4:
		{
			if(isSetBit(g_iBitUserAlive, g_iDuelUsersId[1]) && g_iUserTeam[g_iDuelUsersId[1]] == 2)
			{
				jbm_duel_start_ready(id, g_iDuelUsersId[1]);
				return PLUGIN_HANDLED;
			}
			else UTIL_SayText(id, "!y[!gJBM!y] Игрок для дуэли мертв или вышел из игры.");
		}
		case 8: return Open_LastPrisonerMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_DuelMenu(id);
}

Open_ChoiceDuelMenu(id)
{
	if(isNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	new szMenu[512], 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_CHOICE_DUEL_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_CHOICE_DUEL_DEAGLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_CHOICE_DUEL_M3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_CHOICE_DUEL_HEGRENADE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_CHOICE_DUEL_M249");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_CHOICE_DUEL_AWP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_CHOICE_DUEL_KNIFE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), szMenu, -1, "Open_ChoiceDuelMenu");
}

public Close_ChoiceDuelMenu(id, iKey)
{
	if(isNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: g_iDuelType = 1;
		case 1: g_iDuelType = 2;
		case 2: g_iDuelType = 3;
		case 3: g_iDuelType = 4;
		case 4: g_iDuelType = 5;
		case 5: g_iDuelType = 6;
		case 9: return PLUGIN_HANDLED;
	}
	return Open_DuelMenu(id);
}

Open_DuelUsersMenu(id, iPos)
{
	if(iPos < 0 || id != g_iLastPnId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 2 || isNotSetBit(g_iBitUserAlive, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ChiefMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_DUEL_USERS");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_DUEL_USERS", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DuelUsersMenu");
}

public Close_DuelUsersMenu(id, iKey)
{
	if(id != g_iLastPnId || isNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_DuelUsersMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_DuelUsersMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isSetBit(g_iBitUserAlive, iTarget)) { g_iDuelUsersId[1] = iTarget; return Open_DuelMenu(id); }
			else Open_DuelUsersMenu(id, g_iMenuPosition[id]);
		}
	}
	return PLUGIN_HANDLED;
}

Open_BetMenu(id)
{
	if(isSetBit(g_iBitUserBet, id) || !g_iDuelStatus) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n%L^n\w%L^n^n", id, "JBM_MENU_BET_TITLE", id, "JBM_MENU_BET_YOU_AMOUNT", g_iUserMoney[id], id, "JBM_MENU_BET_YOU_BET", g_iUserBet[id]);
	if(g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 1, floatround(g_iUserMoney[id] * 0.10, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 2, floatround(g_iUserMoney[id] * 0.25, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 3, floatround(g_iUserMoney[id] * 0.50, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 4, floatround(g_iUserMoney[id] * 0.75, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%d$^n", id, "JBM_KEY", 5, g_iUserMoney[id]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_BET_SPECIFY_AMOUNT");
		iBitKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d0$^n%L \d0$^n%L \d0$^n%L \d0$^n%L \d0$^n", id, "JBM_KEY", 1, id, "JBM_KEY", 2, id, "JBM_KEY", 3, id, "JBM_KEY", 4, id, "JBM_KEY", 5);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_BET_SPECIFY_AMOUNT");
	}
	
	if(g_iUserBet[id] != 0 && g_iUserBetId[id] == 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_BET_ON", g_iDuelNames[0]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 8, id, "JBM_MENU_BET_ON", g_iDuelNames[1]);
		iBitKeys |= (1<<6|1<<7);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_BET_ON", g_iDuelNames[0]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 8, id, "JBM_MENU_BET_ON", g_iDuelNames[1]);
	}
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L", id, "JBM_MENU_BET_TIME", g_iDuelCountDown);
	return show_menu(id, iBitKeys, szMenu, 1, "Open_BetMenu");
}

public Close_BetMenu(id, iKey)
{
	if(isSetBit(g_iBitUserBet, id) || !g_iDuelStatus) return PLUGIN_HANDLED;
	new szName[32];
	switch(iKey)
	{
		case 0: g_iUserBet[id] = floatround(g_iUserMoney[id] * 0.10, floatround_ceil);
		case 1: g_iUserBet[id] = floatround(g_iUserMoney[id] * 0.25, floatround_ceil);
		case 2: g_iUserBet[id] = floatround(g_iUserMoney[id] * 0.50, floatround_ceil);
		case 3: g_iUserBet[id] = floatround(g_iUserMoney[id] * 0.75, floatround_ceil);
		case 4: g_iUserBet[id] = g_iUserMoney[id];
		case 5: client_cmd(id, "messagemode ^"bet_money^"");
		case 6:
		{
			if(g_iUserMoney[id] >= g_iUserBet[id])
			{
				get_user_name(id, szName, charsmax(szName)); 
				jbm_set_user_money(id, g_iUserMoney[id] - g_iUserBet[id], 0);
				g_iCountMoney[0] = g_iCountMoney[0] + g_iUserBet[id];
				g_iUserBetId[id] = g_iDuelUsersId[0];
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_ALL_CHAT_BET", szName, g_iUserBet[id], g_iDuelNames[0]);
				setBit(g_iBitUserBet, id);
				return PLUGIN_HANDLED;
			} 
			else g_iUserBet[id] = 0;
		}
		case 7:
		{
			if(g_iUserMoney[id] >= g_iUserBet[id])
			{
				get_user_name(id, szName, charsmax(szName)); 
				jbm_set_user_money(id, g_iUserMoney[id] - g_iUserBet[id], 0);
				g_iCountMoney[1] = g_iCountMoney[1] + g_iUserBet[id];
				g_iUserBetId[id] = g_iDuelUsersId[1];
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_ALL_CHAT_BET", szName, g_iUserBet[id], g_iDuelNames[1]);
				setBit(g_iBitUserBet, id);
				return PLUGIN_HANDLED;
			} 
			else g_iUserBet[id] = 0;
		}
		case 9:
		{
			setBit(g_iBitUserBet, id);
			return PLUGIN_HANDLED;
		}
	}
	return Open_BetMenu(id);
}

Open_ManageMenu(id)
{
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<5|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_MANAGE_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_MANAGE_STOP_MP3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_MANAGE_STOP_ALL");
	if(g_iRoundSoundSize)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MANAGE_ROUND_SOUND", id, isSetBit(g_iBitUserRoundSound, id) ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 4, id, "JBM_MENU_MANAGE_ROUND_END_EFFECTS", id, isSetBit(g_iBitUserRoundEndEffects, id) ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L \r[ \y%d$ \r]^n", id, "JBM_KEY", 5, id, "JBM_MENU_MANAGE_ORDER_SOUND", g_iShopCvars[ORDER_ROUNDSOUND]);
		iBitKeys |= (1<<2|1<<3|1<<4);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 3, id, "JBM_MENU_MANAGE_ROUND_SOUND", id, isSetBit(g_iBitUserRoundSound, id) ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 4, id, "JBM_MENU_MANAGE_ROUND_END_EFFECTS", id, isSetBit(g_iBitUserRoundEndEffects, id) ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[ \y%d$ \r]^n", id, "JBM_KEY", 5, id, "JBM_MENU_MANAGE_ORDER_SOUND", g_iShopCvars[ORDER_ROUNDSOUND]);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 6, id, "JBM_MENU_MANAGE_SOUND_MENU", id, isSetBit(g_iBitSoundMenu, id) ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ManageMenu");
}

public Close_ManageMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: client_cmd(id, "mp3 stop");
		case 1: client_cmd(id, "stopsound");
		case 2: invertBit(g_iBitUserRoundSound, id);
		case 3: invertBit(g_iBitUserRoundEndEffects, id);
		case 4: return Open_OrderSoundMenu(id, g_iMenuPosition[id] = 0);
		case 5: invertBit(g_iBitSoundMenu, id);
		case 8:
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Open_MainPnMenu(id);
				case 2: return Open_MainGrMenu(id);
			}
		}
		case 9: return PLUGIN_HANDLED;
	}
	return Open_ManageMenu(id);
}

Open_OrderSoundMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iRoundSoundSize) iStart = g_iRoundSoundSize;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iRoundSoundSize) iEnd = g_iRoundSoundSize + (iPos ? 0 : 1);
	new szMenu[512], iLen, iPagesNum = (g_iRoundSoundSize / PLAYERS_PER_PAGE + ((g_iRoundSoundSize % PLAYERS_PER_PAGE) ? 1 : 0));
	new iBitKeys = (1<<9), b, aDataRoundSound[DATA_ROUND_SOUND];
	if(iRoundSound == -1) { iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n\d%L^n^n", id, "JBM_MENU_ORDER_SOUND_TITLE", iPos + 1, iPagesNum, id, "JBM_MENU_ORDER_SOUND_COST_TITLE", g_iShopCvars[ORDER_ROUNDSOUND]); }
	else 
	{
		ArrayGetArray(g_aDataRoundSound, iRoundSound, aDataRoundSound);
		iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n\d%L^n^n", id, "JBM_MENU_ORDER_SOUND_TITLE", iPos + 1, iPagesNum, id, "JBM_MENU_ORDER_SOUND_ALREADY_TITLE", aDataRoundSound[TRACK_NAME]);
	}
	for(new a = iStart; a < iEnd; a++)
	{
		new aDataRoundSound[DATA_ROUND_SOUND];
		ArrayGetArray(g_aDataRoundSound, a, aDataRoundSound);
		if(iRoundSound == -1 && g_iUserMoney[id] >= g_iShopCvars[ORDER_ROUNDSOUND])
		{
			iBitKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, aDataRoundSound[TRACK_NAME]);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s^n", id, "JBM_KEY", ++b, aDataRoundSound[TRACK_NAME]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
 
	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_OrderSoundMenu");
}

public Close_OrderSoundMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_OrderSoundMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_OrderSoundMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			if(g_iUserMoney[id] >= g_iShopCvars[ORDER_ROUNDSOUND])
			{
				new szName[32], aDataRoundSound[DATA_ROUND_SOUND];
				get_user_name(id, szName, charsmax(szName));
				iRoundSound = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
				jbm_set_user_money(id, g_iUserMoney[id] - g_iShopCvars[ORDER_ROUNDSOUND], 1);
				ArrayGetArray(g_aDataRoundSound, iRoundSound, aDataRoundSound);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ALL_OREDER_SOUND", szName, aDataRoundSound[TRACK_NAME]);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_FunMenu(id)
{
	new szMenu[512], iBitKeys = (1<<1|1<<2|1<<3|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_FUN_TITLE");
	
	if(isSetBit(g_iBitUserAlive, id) && (g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_FUN_ANIMATION");
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_FUN_ANIMATION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wМеню банд^n^n", id, "JBM_KEY", 2, id);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wКвесты^n^n", id, "JBM_KEY", 3, id);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_FunMenu");
}

public Close_FunMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: return Open_AnimationMenu(id);
		case 1: client_cmd(id,"say /gang");
		case 2: client_cmd(id, "quests");
		case 8: 
		{
			switch(g_iUserTeam[id])
			{
				case 1: return Open_MainPnMenu(id);
				case 2: return Open_MainGrMenu(id);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_AnimationMenu(id)
{
	if(isNotSetBit(g_iBitUserAlive, id) || (g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_ANIMATION_TITLE");
	
	if(task_exists(id+TASK_REMOVE_ANIMATE))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ANIMATION_HI");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ANIMATION_PROVOKE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ANIMATION_JOY");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ANIMATION_ANGRY");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_ANIMATION_DANCE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_ANIMATION_STRENGTH");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_ANIMATION_UPDATE_MENU");
		iBitKeys |= (1<<6);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ANIMATION_HI");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ANIMATION_PROVOKE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ANIMATION_JOY");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ANIMATION_ANGRY");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_ANIMATION_DANCE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_ANIMATION_STRENGTH");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_ANIMATION_UPDATE_MENU");
		iBitKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5);
	}
	 
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_AnimationMenu");
}

public Close_AnimationMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: 
		{
			if(isNotSetBit(g_iBitUserAlive, id) || task_exists(id+TASK_REMOVE_ANIMATE)) return Open_AnimationMenu(id);
			
			UTIL_PlayerAnimation(id, "animation_1");
			engclient_cmd(id, "weapon_knife");
			set_pev(id, pev_viewmodel2, "models/jb_engine/weapons/v_animation.mdl");
			UTIL_WeaponAnimation(id, 0);
			set_task(3.0, "jbm_remove_animate", id+TASK_REMOVE_ANIMATE);
			set_pdata_float(id, m_flNextAttack, 3.0);
			new KnifeEnt = fm_get_user_weapon_entity(id, CSW_KNIFE);
			if(pev_valid(KnifeEnt)) set_pdata_float(KnifeEnt, 48, 3.0, 4);
		}
		case 1: 
		{
			if(isNotSetBit(g_iBitUserAlive, id) || task_exists(id+TASK_REMOVE_ANIMATE)) return Open_AnimationMenu(id);
			
			UTIL_PlayerAnimation(id, "animation_4");
			engclient_cmd(id, "weapon_knife");
			set_pev(id, pev_viewmodel2, "models/jb_engine/weapons/v_animation.mdl");
			UTIL_WeaponAnimation(id, 1);
			set_task(7.0, "jbm_remove_animate", id+TASK_REMOVE_ANIMATE);
			set_pdata_float(id, m_flNextAttack, 7.0);
			new KnifeEnt = fm_get_user_weapon_entity(id, CSW_KNIFE);
			if(pev_valid(KnifeEnt)) set_pdata_float(KnifeEnt, 48, 7.0, 4);
		}
		case 2: 
		{
			if(isNotSetBit(g_iBitUserAlive, id) || task_exists(id+TASK_REMOVE_ANIMATE)) return Open_AnimationMenu(id);
			
			UTIL_PlayerAnimation(id, "animation_2");
			engclient_cmd(id, "weapon_knife");
			set_pev(id, pev_viewmodel2, "models/jb_engine/weapons/v_animation.mdl");
			UTIL_WeaponAnimation(id, 2);
			set_task(4.5, "jbm_remove_animate", id+TASK_REMOVE_ANIMATE);
			set_pdata_float(id, m_flNextAttack, 4.5);
			new KnifeEnt = fm_get_user_weapon_entity(id, CSW_KNIFE);
			if(pev_valid(KnifeEnt)) set_pdata_float(KnifeEnt, 48, 4.5, 4);
		}
		case 3: 
		{
			if(isNotSetBit(g_iBitUserAlive, id) || task_exists(id+TASK_REMOVE_ANIMATE)) return Open_AnimationMenu(id);
			
			UTIL_PlayerAnimation(id, "animation_3");
			engclient_cmd(id, "weapon_knife");
			set_pev(id, pev_viewmodel2, "models/jb_engine/weapons/v_animation.mdl");
			UTIL_WeaponAnimation(id, 3);
			set_task(3.8, "jbm_remove_animate", id+TASK_REMOVE_ANIMATE);
			set_pdata_float(id, m_flNextAttack, 3.8);
			new KnifeEnt = fm_get_user_weapon_entity(id, CSW_KNIFE);
			if(pev_valid(KnifeEnt)) set_pdata_float(KnifeEnt, 48, 3.8, 4);
		}
		case 4: 
		{
			if(isNotSetBit(g_iBitUserAlive, id) || task_exists(id+TASK_REMOVE_ANIMATE)) return Open_AnimationMenu(id);
			
			UTIL_PlayerAnimation(id, "animation_5");
			engclient_cmd(id, "weapon_knife");
			set_pev(id, pev_viewmodel2, "models/jb_engine/weapons/v_animation.mdl");
			UTIL_WeaponAnimation(id, 4);
			set_task(6.7, "jbm_remove_animate", id+TASK_REMOVE_ANIMATE);
			set_pdata_float(id, m_flNextAttack, 6.7);
			new KnifeEnt = fm_get_user_weapon_entity(id, CSW_KNIFE);
			if(pev_valid(KnifeEnt)) set_pdata_float(KnifeEnt, 48, 6.7, 4);
		}
		case 5: 
		{
			if(isNotSetBit(g_iBitUserAlive, id) || task_exists(id+TASK_REMOVE_ANIMATE)) return Open_AnimationMenu(id);
		
			UTIL_PlayerAnimation(id, "animation_6");
			engclient_cmd(id, "weapon_knife");
			set_pev(id, pev_viewmodel2, "models/jb_engine/weapons/v_animation.mdl");
			UTIL_WeaponAnimation(id, 5);
			set_task(3.0, "jbm_remove_animate", id+TASK_REMOVE_ANIMATE);
			set_pdata_float(id, m_flNextAttack, 3.0);
			new KnifeEnt = fm_get_user_weapon_entity(id, CSW_KNIFE);
			if(pev_valid(KnifeEnt)) set_pdata_float(KnifeEnt, 48, 3.0, 4);
		}
		case 6: return Open_AnimationMenu(id);
		case 8: return Open_FunMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_AnimationMenu(id);
}

Open_DonateMenu(id)
{
	new szMenu[512], iBitKeys = (1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_DONATE_TITLE");
	
	
	if(isSetBit(g_iBitUserVip, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DONATE_VIP_MENU");
			iBitKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DONATE_VIP_MENU_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DONATE_VIP_MENU_3");
	
	if(isSetBit(g_iBitUserUltraVip, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_DONATE_ULTRA_VIP_MENU");
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_DONATE_ULTRA_VIP_MENU_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_DONATE_ULTRA_VIP_MENU_3");
	
	
	if(isSetBit(g_iBitUserAdmin, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DONATE_ADMIN_MENU"); 
		}
		else 
		{ 
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \y%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DONATE_ADMIN_MENU_2"); 
		}
		
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DONATE_ADMIN_MENU_3");
	
	
	if(isSetBit(g_iBitUserPredator, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_DONATE_PREDATOR_MENU");
			iBitKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_DONATE_PREDATOR_MENU_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_DONATE_PREDATOR_MENU_3");
	
	if(isSetBit(g_iBitUserBoss, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DONATE_BOSS_MENU");
			iBitKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DONATE_BOSS_MENU_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DONATE_BOSS_MENU_3");
	
	if(isSetBit(g_iBitUserAnime, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_DONATE_ANIME_MENU");
			iBitKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_DONATE_ANIME_MENU_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_DONATE_ANIME_MENU_3");
	
	if(isSetBit(g_iBitUserAC, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 7, id, "JBM_MENU_DONATE_ACP_MENU");
			iBitKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 7, id, "JBM_MENU_DONATE_ACP_MENU_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 7, id, "JBM_MENU_DONATE_ACP_MENU_3");
		
	if(isSetBit(g_iBitUserTrail, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_DONATE_TRAIL");
			iBitKeys |= (1<<7);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_DONATE_TRAIL_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_DONATE_TRAIL_3");
	if(isSetBit(g_iBitUserHook, id))
	{
		if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) || (g_iGlobalGame && g_iChiefId == id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 9, id, "JBM_MENU_DONATE_HOOK_MENU");
			iBitKeys |= (1<<8);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 9, id, "JBM_MENU_DONATE_HOOK_MENU_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 9, id, "JBM_MENU_DONATE_HOOK_MENU_3");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DonateMenu");
}

public Close_DonateMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_VipMenu(id);
		case 1: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_UltraVipMenu(id);
		case 2: 
		{
			if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_AdminMenu(id);
			else return Open_AmxModMenu(id);
		}
		case 3: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_PredatorMenu(id);
		case 4: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_BossMenu(id);
		case 5: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_AnimeMenu(id);
		case 6: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_ACPMenu(id);
		case 7: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return Open_TrailMenu(id);
		case 8: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id)) return client_cmd(id, "say /hook");
	}
	return PLUGIN_HANDLED;
}

Open_VipMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || jbm_menu_blocked(id) || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), iAlive = isSetBit(g_iBitUserAlive, id), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_VIP_TITLE");
	if(g_iVipData[id][RESPAWN_VIP] && (g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isNotSetBit(g_iBitUserAlive, id))
	{
		if(!g_szWantedNames[0])
		{
			if(g_iUserTeam[id] == 1)
			{
				if(g_iAlivePlayersNum[1] >= g_iAllCvars[RESPAWN_PLAYER_NUM_T])
				{
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_VIP_RESPAWN", g_iVipData[id][RESPAWN_VIP]);
					iBitKeys |= (1<<0);
				} 
				else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[TT <= %d]^n", id, "JBM_KEY", 1, id, "JBM_MENU_VIP_RESPAWN", g_iVipData[id][RESPAWN_VIP], g_iAllCvars[RESPAWN_PLAYER_NUM_T] - 1);
			}
			else if(g_iUserTeam[id] == 2)
			{
				if(g_iAlivePlayersNum[2] >= g_iAllCvars[RESPAWN_PLAYER_NUM_CT])
				{
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_VIP_RESPAWN", g_iVipData[id][RESPAWN_VIP]);
					iBitKeys |= (1<<0);
				} 
				else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[CT <= %d]^n", id, "JBM_KEY", 1, id, "JBM_MENU_VIP_RESPAWN", g_iVipData[id][RESPAWN_VIP], g_iAllCvars[RESPAWN_PLAYER_NUM_CT] - 1);
			}
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[Розыск]^n", id, "JBM_KEY", 1, id, "JBM_MENU_VIP_RESPAWN", g_iVipData[id][RESPAWN_VIP]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_VIP_RESPAWN", g_iVipData[id][RESPAWN_VIP]);
	
	if(g_iVipData[id][MONEY_VIP] >= g_iAllCvars[VIP_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM], g_iAllCvars[VIP_MONEY_ROUND]);
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM], g_iAllCvars[VIP_MONEY_ROUND]);
	
	if(iAlive && g_iVipData[id][HPAP] >= g_iAllCvars[VIP_HP_AP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_VIP_HP_AP", g_iAllCvars[VIP_HP_AP_ROUND]);
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_VIP_HP_AP", g_iAllCvars[VIP_HP_AP_ROUND]);
	if(iAlive && isNotSetBit(g_iBitUserVoice, id) && isNotSetBit(g_iBitUserBuyVoice, id) && g_iVipData[id][VOICE] == g_iAllCvars[VIP_VOICE_ROUND] && g_iUserTeam[id] == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_VIP_VOICE", g_iAllCvars[VIP_VOICE_ROUND]);
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_VIP_VOICE", g_iAllCvars[VIP_VOICE_ROUND]);
	if(iAlive && g_iVipData[id][INVISIBLE] >= g_iAllCvars[VIP_INVISIBLE] && g_iUserTeam[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_VIP_INVISIBLE", g_iAllCvars[VIP_INVISIBLE]);
		iBitKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_VIP_INVISIBLE", g_iAllCvars[VIP_INVISIBLE]);
	
	if(iAlive && g_iVipData[id][GRANATE] >= g_iAllCvars[VIP_GRANATE] && g_iUserTeam[id] == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_VIP_GRANATE", g_iAllCvars[VIP_GRANATE]);
		iBitKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_VIP_GRANATE", g_iAllCvars[VIP_GRANATE]);
	if(iAlive && g_iVipData[id][SPEED_GRAVITY] >= g_iAllCvars[VIP_SPEED_GRAVITY])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_VIP_SPEED_GRAVITY", g_iAllCvars[VIP_SPEED_GRAVITY]);
		iBitKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_VIP_SPEED_GRAVITY", g_iAllCvars[VIP_SPEED_GRAVITY]);

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_VipMenu");
}

public Close_VipMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			if(isNotSetBit(g_iBitUserAlive, id) && g_iVipData[id][RESPAWN_VIP] && (g_iUserTeam[id] == 1 && g_iAlivePlayersNum[1] >= g_iAllCvars[RESPAWN_PLAYER_NUM_T] || g_iUserTeam[id] == 2 && g_iAlivePlayersNum[2] >= g_iAllCvars[RESPAWN_PLAYER_NUM_CT]))
			{
				ExecuteHamB(Ham_CS_RoundRespawn, id);
				g_iVipData[id][RESPAWN_VIP]--;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_VIP_RESPAWN", szName);
				emit_sound(id, CHAN_AUTO, g_szSounds[RESPAWN_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 1: 
		{
			jbm_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[VIP_MONEY_NUM], 1);
			g_iVipData[id][MONEY_VIP] = 0;
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_VIP_MONEY", szName, g_iAllCvars[VIP_MONEY_NUM]);
		}
		case 2:
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
				set_pev(id, pev_health, 150.0);
				set_pev(id, pev_armorvalue, 150.0);
				g_iVipData[id][HPAP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_VIP_HP_AP", szName);
			}
		}
		case 3:
		{
			if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitUserVoice, id))
			{
				setBit(g_iBitUserVoice, id);
				g_iVipData[id][VOICE] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_VIP_VOICE", szName);
			}
		}
		case 4:
		{
			if(isSetBit(g_iBitUserAlive, id) && g_iUserTeam[id] == 2)
			{
				jbm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
				jbm_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				g_iVipData[id][INVISIBLE] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_VIP_INVISIBLE", szName);
			}
		}
		case 5: 
		{
			if(isSetBit(g_iBitUserAlive, id) && g_iUserTeam[id] == 1)
			{
				if(!user_has_weapon(id, CSW_FLASHBANG)) 	fm_give_item(id, "weapon_flashbang");
				if(!user_has_weapon(id, CSW_HEGRENADE)) 	fm_give_item(id, "weapon_hegrenade");
				if(!user_has_weapon(id, CSW_SMOKEGRENADE)) 	fm_give_item(id, "weapon_smokegrenade");
				g_iVipData[id][GRANATE] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_VIP_GRANATE", szName);
			}
		}
		case 6: 
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
				set_pev(id, pev_gravity, 0.5);
				g_fUserSpeed[id] = 400.0;
				ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
				g_iVipData[id][SPEED_GRAVITY] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_VIP_SPEED_GRAVITY", szName);
			}
		}
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_VipMenu(id);
}

Open_AnimeMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || jbm_menu_blocked(id) || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<4|1<<5|1<<8|1<<9), iAlive = isSetBit(g_iBitUserAlive, id), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_ANIME_TITLE");
	
	if(iAlive && g_iAnimeData[id][HP] >= g_iAllCvars[ANIME_HP_AP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ANIME_HP_AP", g_iAllCvars[ANIME_HP_AP_ROUND]);
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ANIME_HP_AP", g_iAllCvars[ANIME_HP_AP_ROUND]);
	
	if(iAlive && g_iAnimeData[id][DEAGLE] >= g_iAllCvars[ANIME_DEAGLE_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ANIME_DEAGLE", g_iAllCvars[ANIME_DEAGLE_ROUND]);
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ANIME_DEAGLE", g_iAllCvars[ANIME_DEAGLE_ROUND]);
	if(iAlive && g_iAnimeData[id][NOJ] >= g_iAllCvars[ANIME_NOJ_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ANIME_NOJ", g_iAllCvars[ANIME_NOJ_ROUND]);
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ANIME_NOJ", g_iAllCvars[ANIME_NOJ_ROUND]);
	if(iAlive && g_iAnimeData[id][MODEL] >= g_iAllCvars[ANIME_MODEL_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ANIME_MODEL", g_iAllCvars[ANIME_MODEL_ROUND]);
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ANIME_MODEL", g_iAllCvars[ANIME_MODEL_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wПолёт: %s^n", g_bHookStatus ? "\rЗапрещён" : "\yРазрешён");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 6, id, "JBM_MENU_ANIME_DARK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_AnimeMenu");
}

public Close_AnimeMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
				set_pev(id, pev_health, 255.0);
				set_pev(id, pev_armorvalue, 255.0);
				g_iAnimeData[id][HP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ANIME_HP", szName);
			}
		}
		case 1:
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
				drop_user_weapons(id, 1);
				fm_give_item(id, "weapon_deagle");
				g_iAnimeData[id][DEAGLE] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ANIME_DEAGLE", szName);
			}
		}
		case 2:
		{
		    if(isSetBit(g_iBitUserAlive, id))
			{
				clearBit(g_iBitKatana, id);
				clearBit(g_iBitMachete, id);
				clearBit(g_iBitChainsaw, id);
				setBit(g_iBitPerc, id);
				setBit(g_iBitWeaponStatus, id);
				if(get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0)
					{
						ExecuteHamB(Ham_Item_Deploy, iActiveItem);
						UTIL_WeaponAnimation(id, 3);
					}
				}
				g_iAnimeData[id][NOJ] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ANIME_NOJ", szName);
			}
		}
		case 3:
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
                jbm_set_user_model(id, g_szPlayerModel[MDLANIME]);
                g_iAnimeData[id][MODEL] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ANIME_MODEL", szName);
			}
		}
		case 4:
		{
			if(!g_bHookStatus)
			{
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ANIME_FLY_OFF", szName);
				g_bHookStatus = true;
			}
			else 
			{
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ANIME_FLY_ON", szName);
				g_bHookStatus = false;
			}
		}
		case 5: return Open_DayMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_AnimeMenu(id);
}

Open_DayMenu(id)
{
    if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || isNotSetBit(g_iBitUserAlive, id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_DEMON_DAY_TITLE");
    {
		   iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_DAY_1");
           iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_DAY_2");
	       iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_DAY_3");
	       iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_DAY_4");
	       iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_DAY_5");
	       iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_DAY_6");
    }
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L\w %L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L\w %L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_DayMenu");
}

public Close_DayMenu(id, iKey)
{
	new szName[32]; get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			set_lights("a");
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_LIGHT_1", szName);
		}
		case 1:
		{
			set_lights("b");
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_LIGHT_2", szName);
		}
		case 2:
		{
			set_lights("d");
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_LIGHT_3", szName);
		}
		case 3:
		{
			set_lights("g");
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_LIGHT_4", szName);
		}
		case 4:
		{
			set_lights("z");
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_LIGHT_5", szName);
		}
		case 5:
		{
			set_lights("#OFF");
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_LIGHT_6", szName);
		}
		case 8: return Open_AnimeMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_DayMenu(id);
}

Open_UltraVipMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || jbm_menu_blocked(id) || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_ULTRA_VIP_TITLE");
	
	if(g_iUltraVipData[id][RESPAWN_UVIP] && isNotSetBit(g_iBitUserAlive, id))
	{
		if(!g_szWantedNames[0])
		{
			if(g_iUserTeam[id] == 1)
			{
				if(g_iAlivePlayersNum[1] >= g_iAllCvars[RESPAWN_PLAYER_NUM_T])
				{
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ULTRA_VIP_RESPAWN", g_iUltraVipData[id][RESPAWN_UVIP]);
					iBitKeys |= (1<<0);
				} 
				else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[TT <= %d]^n", id, "JBM_KEY", 1, id, "JBM_MENU_ULTRA_VIP_RESPAWN", g_iUltraVipData[id][RESPAWN_UVIP], g_iAllCvars[RESPAWN_PLAYER_NUM_T] - 1);
			}
			else if(g_iUserTeam[id] == 2)
			{
				if(g_iAlivePlayersNum[2] >= g_iAllCvars[RESPAWN_PLAYER_NUM_CT])
				{
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ULTRA_VIP_RESPAWN", g_iUltraVipData[id][RESPAWN_UVIP]);
					iBitKeys |= (1<<0);
				} 
				else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[CT <= %d]^n", id, "JBM_KEY", 1, id, "JBM_MENU_ULTRA_VIP_RESPAWN", g_iUltraVipData[id][RESPAWN_UVIP], g_iAllCvars[RESPAWN_PLAYER_NUM_CT] - 1);
			}
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[Розыск]^n", id, "JBM_KEY", 1, id, "JBM_MENU_ULTRA_VIP_RESPAWN", g_iUltraVipData[id][RESPAWN_UVIP]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ULTRA_VIP_RESPAWN", g_iUltraVipData[id][RESPAWN_UVIP]);
	
	if(g_iUltraVipData[id][RESPAWN_UVIP_PLAYER])
	{
		if(!g_szWantedNames[0])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ULTRA_VIP_RESPAWN_PLAYER", g_iUltraVipData[id][RESPAWN_UVIP_PLAYER]);
			iBitKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[Розыск]^n", id, "JBM_KEY", 2, id, "JBM_MENU_ULTRA_VIP_RESPAWN_PLAYER", g_iUltraVipData[id][RESPAWN_UVIP_PLAYER]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ULTRA_VIP_RESPAWN_PLAYER", g_iUltraVipData[id][RESPAWN_UVIP_PLAYER]);
	
	if(g_iUltraVipData[id][MONEY_UVIP] >= g_iAllCvars[ULTRA_VIP_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ULTRA_VIP_MONEY", g_iAllCvars[ULTRA_VIP_MONEY_NUM], g_iAllCvars[ULTRA_VIP_MONEY_ROUND]);
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ULTRA_VIP_MONEY", g_iAllCvars[ULTRA_VIP_MONEY_NUM], g_iAllCvars[ULTRA_VIP_MONEY_ROUND]);
	
	if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitDoubleDamage, id) && g_iUltraVipData[id][DAMAGE_UVIP] >= g_iAllCvars[ULTRA_VIP_DAMAGE_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ULTRA_VIP_DAMAGE", g_iAllCvars[ULTRA_VIP_DAMAGE_ROUND]);
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ULTRA_VIP_DAMAGE", g_iAllCvars[ULTRA_VIP_DAMAGE_ROUND]);
	
	if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitAutoBhop, id) && g_iUltraVipData[id][BHOP_UVIP] >= g_iAllCvars[ULTRA_VIP_BHOP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_ULTRA_VIP_BHOP", g_iAllCvars[ULTRA_VIP_BHOP_ROUND]);
		iBitKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_ULTRA_VIP_BHOP", g_iAllCvars[ULTRA_VIP_BHOP_ROUND]);
	
	if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitRandomGlow, id) && g_iUltraVipData[id][GLOW_UVIP] >= g_iAllCvars[ULTRA_VIP_GLOW_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_ULTRA_VIP_GLOW", g_iAllCvars[ULTRA_VIP_GLOW_ROUND]);
		iBitKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_ULTRA_VIP_GLOW", g_iAllCvars[ULTRA_VIP_GLOW_ROUND]);
	
	if(isSetBit(g_iBitUserWanted, id) && g_iUltraVipData[id][CLOSE_CASE_UVIP] >= g_iAllCvars[ULTRA_VIP_CLOSE_CASE_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_ULTRA_VIP_CLOSE_CASE", g_iAllCvars[ULTRA_VIP_GLOW_ROUND]);
		iBitKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_ULTRA_VIP_CLOSE_CASE", g_iAllCvars[ULTRA_VIP_GLOW_ROUND]);
	
	if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitDoubleJump, id) && g_iUltraVipData[id][DOUBLE_JUMP_UVIP] >= g_iAllCvars[ULTRA_VIP_DOUBLE_JUMP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_ULTRA_VIP_DOUBLE_JUMP", g_iAllCvars[ULTRA_VIP_DOUBLE_JUMP_ROUND]);
		iBitKeys |= (1<<7);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_ULTRA_VIP_DOUBLE_JUMP", g_iAllCvars[ULTRA_VIP_DOUBLE_JUMP_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_UltraVipMenu");
}

public Close_UltraVipMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			if(isNotSetBit(g_iBitUserAlive, id) && g_iUltraVipData[id][RESPAWN_UVIP] && (g_iUserTeam[id] == 1 && g_iAlivePlayersNum[1] >= g_iAllCvars[RESPAWN_PLAYER_NUM_T] || g_iUserTeam[id] == 2 && g_iAlivePlayersNum[2] >= g_iAllCvars[RESPAWN_PLAYER_NUM_CT]))
			{
				ExecuteHamB(Ham_CS_RoundRespawn, id);
				g_iUltraVipData[id][RESPAWN_UVIP]--;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ULTRA_VIP_RESPAWN", szName);
				emit_sound(id, CHAN_AUTO, g_szSounds[RESPAWN_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 1: if(g_iUltraVipData[id][RESPAWN_UVIP_PLAYER] && !g_szWantedNames[0]) return Open_UVRespawnMenu(id, g_iMenuPosition[id] = 0);
		case 2: 
		{
			jbm_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ULTRA_VIP_MONEY_NUM], 1);
			g_iUltraVipData[id][MONEY_UVIP] = 0;
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ULTRA_VIP_MONEY", szName, g_iAllCvars[ULTRA_VIP_MONEY_NUM]);
		}
		case 3:
		{
			if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitDoubleDamage, id) && g_iUltraVipData[id][DAMAGE_UVIP] >= g_iAllCvars[ULTRA_VIP_DAMAGE_ROUND])
			{
				setBit(g_iBitDoubleDamage, id);
				g_iUltraVipData[id][DAMAGE_UVIP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ULTRA_VIP_DAMAGE", szName);
			}
		}
		case 4:
		{
			if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitAutoBhop, id) && g_iUltraVipData[id][BHOP_UVIP] >= g_iAllCvars[ULTRA_VIP_BHOP_ROUND])
			{
				setBit(g_iBitAutoBhop, id);
				g_iUltraVipData[id][BHOP_UVIP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ULTRA_VIP_BHOP", szName);
			}
		}
		case 5:
		{
			if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitRandomGlow, id))
			{
				setBit(g_iBitRandomGlow, id);
				jbm_set_user_rendering(id, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), kRenderNormal, 0);
				jbm_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				g_iUltraVipData[id][GLOW_UVIP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ULTRA_VIP_GLOW", szName);
			}
		}
		case 6:
		{
			if(isSetBit(g_iBitUserWanted, id))
			{
				jbm_sub_user_wanted(id);
				g_iUltraVipData[id][CLOSE_CASE_UVIP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ULTRA_VIP_CLOSE_CASE", szName);
			}
		}
		case 7:
		{
			if(isSetBit(g_iBitUserAlive, id) && isNotSetBit(g_iBitDoubleJump, id))
			{
				setBit(g_iBitDoubleJump, id);
				g_iUltraVipData[id][DOUBLE_JUMP_UVIP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ULTRA_VIP_DOUBLE_JUMP", szName);
			}
		}
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_UltraVipMenu(id);
}

Open_UVRespawnMenu(id, iPos)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(iPos < 0 || (g_iGlobalGame && g_iChiefId != id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isSetBit(g_iBitUserAlive, i) 
		|| isNotSetBit(g_iBitUserConnected, i) 
		|| i == id
		|| (g_iUserTeam[i] != 1 && g_iUserTeam[i] != 2) 
		|| (g_iAlivePlayersNum[1] < g_iAllCvars[RESPAWN_PLAYER_NUM_T] && g_iUserTeam[i] == 1) 
		|| (g_iAlivePlayersNum[2] < g_iAllCvars[RESPAWN_PLAYER_NUM_CT] && g_iUserTeam[i] == 2)) continue;
		
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_UltraVipMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SPAWN_PLAYER_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_SPAWN_PLAYER_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_UVRespawnMenu");
}

public Close_UVRespawnMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	switch(iKey)
	{
		case 7: return Open_UVRespawnMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_UVRespawnMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isNotSetBit(g_iBitUserAlive, iTarget))
			{
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				
				g_iUltraVipData[id][RESPAWN_UVIP_PLAYER]--;
				ExecuteHamB(Ham_CS_RoundRespawn, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_ID_CHAT_SPAWN_PLAYER_ULTRA_VIP", szName, szTargetName);
				emit_sound(id, CHAN_AUTO, g_szSounds[RESPAWN_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
	}
	return PLUGIN_HANDLED;
}

Open_AdminMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { return Open_AmxModMenu(id); }
#endif
	if(isSetBit(g_iBitUserDuel, id)) { return Open_AmxModMenu(id); }
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || jbm_menu_blocked(id) || (g_iGlobalGame && g_iChiefId != id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<8|1<<9), iAlive = isSetBit(g_iBitUserAlive, id), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_ADMIN_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \y%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_ADMIN_AMXMODMENU");
	if(!g_szWantedNames[0])
	{
		if(g_iAlivePlayersNum[1] > 1)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ADMIN_RESPAWN_PLAYER");
			iBitKeys |= (1<<1);
			if(g_iAlivePlayersNum[1] >= g_iAllCvars[RESPAWN_PLAYER_NUM_T])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ADMIN_RESPAWN_PR");
				iBitKeys |= (1<<2);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[TT <= %d]^n", id, "JBM_KEY", 3, id, "JBM_MENU_ADMIN_RESPAWN_PR", g_iAllCvars[RESPAWN_PLAYER_NUM_T] - 1);
			if(g_iAlivePlayersNum[2] >= g_iAllCvars[RESPAWN_PLAYER_NUM_CT])
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ADMIN_RESPAWN_CT");
				iBitKeys |= (1<<3);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L \r[CT <= %d]^n", id, "JBM_KEY", 4, id, "JBM_MENU_ADMIN_RESPAWN_CT", g_iAllCvars[RESPAWN_PLAYER_NUM_CT] - 1);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ADMIN_RESPAWN_PLAYER");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ADMIN_RESPAWN_PR");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ADMIN_RESPAWN_CT");
		}
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ADMIN_RESPAWN_PLAYER");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ADMIN_RESPAWN_PR");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ADMIN_RESPAWN_CT");
	}
	if(g_iAdminData[id][MONEY] >= g_iAllCvars[ADMIN_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_ADMIN_MONEY", g_iAllCvars[ADMIN_MONEY_NUM], g_iAllCvars[ADMIN_MONEY_ROUND]);
		iBitKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_ADMIN_MONEY", g_iAllCvars[ADMIN_MONEY_NUM], g_iAllCvars[ADMIN_MONEY_ROUND]);
	if(iAlive && g_iAdminData[id][FOOTSTEPS] >= g_iAllCvars[ADMIN_FOOTSTEPS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_ADMIN_FOOTSTEPS", g_iAllCvars[ADMIN_FOOTSTEPS_ROUND]);
		iBitKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_ADMIN_FOOTSTEPS", g_iAllCvars[ADMIN_FOOTSTEPS_ROUND]);
	if(iAlive && g_iChiefId == id && g_iAdminData[id][GOD] >= g_iAllCvars[ADMIN_GOD_ROUND] && !get_user_godmode(id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_ADMIN_GOD", g_iAllCvars[ADMIN_GOD_ROUND]);
		iBitKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_ADMIN_GOD", g_iAllCvars[ADMIN_GOD_ROUND]);
	if(iAlive && g_iAdminData[id][ULTRA_BHOP] >= g_iAllCvars[ADMIN_ULTRA_BHOP])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_ADMIN_ULTRA_BHOP", g_iAllCvars[ADMIN_ULTRA_BHOP]);
		iBitKeys |= (1<<7);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_ADMIN_ULTRA_BHOP", g_iAllCvars[ADMIN_ULTRA_BHOP]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_AdminMenu");
}

public Close_AdminMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { return Open_AmxModMenu(id); }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0: return Open_AmxModMenu(id);
		case 1: if(!g_szWantedNames[0]) return Open_RespawnPlayerMenu(id, g_iMenuPosition[id] = 0);
		case 2:
		{
			if(!g_szWantedNames[0] && g_iAlivePlayersNum[1] >= g_iAllCvars[RESPAWN_PLAYER_NUM_T])
			{
				if(g_iAlivePlayersNum[1] != g_iPlayersNum[1])
				{
					for(new i = 1; i <= g_iMaxPlayers; i++) 
					{
						if((isSetBit(g_iBitUserConnected, i)) && isNotSetBit(g_iBitUserAlive, i) && g_iUserTeam[i] == 1)
						{
							ExecuteHamB(Ham_CS_RoundRespawn, i);
							emit_sound(i, CHAN_AUTO, g_szSounds[RESPAWN_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
						}
					}
					UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ID_CHAT_RESPAWN_PN", szName);
				}
				else UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			}
			return PLUGIN_HANDLED;
		}
		case 3:
		{
			if(!g_szWantedNames[0] && g_iAlivePlayersNum[2] >= g_iAllCvars[RESPAWN_PLAYER_NUM_CT])
			{
				if(g_iAlivePlayersNum[2] != g_iPlayersNum[2])
				{
					for(new i = 1; i <= g_iMaxPlayers; i++) 
					{
						if((isSetBit(g_iBitUserConnected, i)) && isNotSetBit(g_iBitUserAlive, i) && g_iUserTeam[i] == 2)
						{
							ExecuteHamB(Ham_CS_RoundRespawn, i);
							emit_sound(i, CHAN_AUTO, g_szSounds[RESPAWN_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
						}
					}
					UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ID_CHAT_RESPAWN_CT", szName);
				}
				else UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			}
			return PLUGIN_HANDLED;
		}
		case 4:
		{
			jbm_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ADMIN_MONEY_NUM], 1);
			g_iAdminData[id][MONEY] = 0;
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ADMIN_MONEY", szName, g_iAllCvars[ADMIN_MONEY_NUM]);
		}
		case 5:
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
				set_user_footsteps(id, 1);
				g_iAdminData[id][FOOTSTEPS] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ADMIN_FOOTSTEPS", szName);
			}
		}
		case 6:
		{
			if(isSetBit(g_iBitUserAlive, id) && g_iChiefId == id)
			{
				set_user_godmode(id, 1);
				g_iAdminData[id][GOD] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ADMIN_GOD", szName);
			}
		}
		case 7:
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
				setBit(g_iBitAutoBhop, id);
				setBit(g_iBitBoostBhop, id);
				g_iAdminData[id][ULTRA_BHOP] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_ADMIN_ULTRA_BHOP", szName);
			}
		}
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_AdminMenu(id);
}

Open_AmxModMenu(id)
{
	if(jbm_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_AMXMODMENU_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_AMXMODMENU_KICK");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_AMXMODMENU_BAN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_AMXMODMENU_SLAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_AMXMODMENU_TEAM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_AMXMODMENU_MAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_AMXMODMENU_VOTE_MAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_AMXMODMENU_BLOCKED_GUARD");
	if(g_iUserTeam[id] == 1 || g_iUserTeam[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
		iBitKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_AmxModMenu");
}

public Close_AmxModMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: client_cmd(id, "amx_kickmenu");
		case 1: client_cmd(id, "amx_banmenu");
		case 2: client_cmd(id, "amx_slapmenu");
		case 3: client_cmd(id, "amx_teammenu");
		case 4: client_cmd(id, "amx_mapmenu");
		case 5: client_cmd(id, "amx_votemapmenu");
		case 6: return Open_BlockedGuardMenu(id, g_iMenuPosition[id] = 0);
		case 8: return Open_DonateMenu(id);
	}
	return PLUGIN_HANDLED;
}

Open_BlockedGuardMenu(id, iPos)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserConnected, i) || isSetBit(g_iBitUserAdmin, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			switch(g_iUserTeam[id])
			{
				case 1, 2: return Open_AmxModMenu(id);
				default: return PLUGIN_HANDLED;
			}
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_BLOCKED_GUARD_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_BLOCKED_GUARD_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		if(isSetBit(g_iBitUserBlockedGuard, i))  
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \r*\dblocked\r*^n", id, "JBM_KEY", ++b, szName);
		else 
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_BlockedGuardMenu");
}

public Close_BlockedGuardMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	switch(iKey)
	{
		case 7: return Open_BlockedGuardMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_BlockedGuardMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new szName[32], szTargetName[32];
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(isSetBit(g_iBitUserBlockedGuard, iTarget)) 
			{
				#if defined SAVE_BLOCK_IP_ON_MAP
				new szIp[22];
				get_user_ip(id, szIp, charsmax(szIp), 1);
				if(TrieKeyExists(g_iBlockListOnMap, szIp)) TrieDeleteKey(g_iBlockListOnMap, szIp);
				#endif
				clearBit(g_iBitUserBlockedGuard, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_ADMIN_TAKE_BLOCK", szName, szTargetName);
			}
			else if(isSetBit(g_iBitUserConnected, iTarget))
			{
				if(g_iUserTeam[iTarget] == 2) jbm_set_user_team(iTarget, 1);
				setBit(g_iBitUserBlockedGuard, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_ADMIN_GIVE_BLOCK", szName, szTargetName);
			}
		}
	}
	return Open_BlockedGuardMenu(id, g_iMenuPosition[id]);
}

Open_RespawnPlayerMenu(id, iPos)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(iPos < 0 || (g_iGlobalGame && g_iChiefId != id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isSetBit(g_iBitUserAlive, i)
		|| isNotSetBit(g_iBitUserConnected, i)
		|| i == id
		|| (g_iUserTeam[i] != 1 && g_iUserTeam[i] != 2)
		|| (g_iAlivePlayersNum[1] < g_iAllCvars[RESPAWN_PLAYER_NUM_T] && g_iUserTeam[i] == 1)
		|| (g_iAlivePlayersNum[2] < g_iAllCvars[RESPAWN_PLAYER_NUM_CT] && g_iUserTeam[i] == 2)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_AdminMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SPAWN_PLAYER_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_SPAWN_PLAYER_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	
	return show_menu(id, iBitKeys, szMenu, -1, "Open_RespawnPlayerMenu");
}

public Close_RespawnPlayerMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	switch(iKey)
	{
		case 7: return Open_RespawnPlayerMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_RespawnPlayerMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isNotSetBit(g_iBitUserAlive, iTarget))
			{
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
		
				ExecuteHamB(Ham_CS_RoundRespawn, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_ID_CHAT_SPAWN_PLAYER", szName, szTargetName);
				emit_sound(id, CHAN_AUTO, g_szSounds[RESPAWN_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
	}
	return Open_RespawnPlayerMenu(id, g_iMenuPosition[id]);
}

Open_PredatorMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || jbm_menu_blocked(id) || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_PREDATOR_TITLE");
	if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_PREDATOR_VOICE_CONTROL");
		iBitKeys |= (1<<0);
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 1, id, "JBM_MENU_PREDATOR_VOICE_CONTROL");
	
	if(isSetBit(g_iBitUserAlive, id) && g_iPredatorData[id][HEAL] && get_user_health(id) < 100)
	{ 
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_PREDATOR_HEAL", g_iPredatorData[id][HEAL]);
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_PREDATOR_HEAL", g_iPredatorData[id][HEAL]);
		
	if(isSetBit(g_iBitUserAlive, id) && g_iPredatorData[id][1] >= g_iAllCvars[PREDATOR_INVISIBLE_ROUND])
	{ 
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_PREDATOR_INVISIBLE", g_iAllCvars[PREDATOR_INVISIBLE_ROUND]);
		iBitKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_PREDATOR_INVISIBLE", g_iAllCvars[PREDATOR_INVISIBLE_ROUND]);
	
	if(isSetBit(g_iBitUserAlive, id) && g_iPredatorData[id][WEAPON] >= g_iAllCvars[PREDATOR_WEAPON_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_PREDATOR_WEAPON", g_iAllCvars[PREDATOR_WEAPON_ROUND]);
		iBitKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_PREDATOR_WEAPON", g_iAllCvars[PREDATOR_WEAPON_ROUND]);
	
	
	if(isSetBit(g_iBitUserAlive, id) && g_iPredatorData[id][THEFT] >= g_iAllCvars[PREDATOR_THEFT_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n^n", id, "JBM_KEY", 5, id, "JBM_MENU_PREDATOR_THEAF", g_iAllCvars[PREDATOR_THEFT_ROUND]);
		iBitKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n^n", id, "JBM_KEY", 5, id, "JBM_MENU_PREDATOR_THEAF", g_iAllCvars[PREDATOR_THEFT_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_PredatorMenu");
}

public Close_PredatorMenu(id, iKey)
{ 
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || (g_iGlobalGame && g_iChiefId != id) || isSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0: if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) return Open_PredatorVoiceControlMenu(id, g_iMenuPosition[id] = 0);
		case 1:
		{
			if(isSetBit(g_iBitUserAlive, id) && g_iPredatorData[id][HEAL] && get_user_health(id) < 100)
			{
				set_pev(id, pev_health, 100.0);
				g_iPredatorData[id][HEAL]--;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_HEALTH", szName);
			}
		}
		case 2:
		{
			if(isSetBit(g_iBitUserAlive, id) && g_iPredatorData[id][1] >= g_iAllCvars[PREDATOR_INVISIBLE_ROUND])
			{
				jbm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 50);
				jbm_get_user_rendering(id, g_eUserRendering[id][RENDER_FX], g_eUserRendering[id][RENDER_RED], g_eUserRendering[id][RENDER_GREEN], g_eUserRendering[id][RENDER_BLUE], g_eUserRendering[id][RENDER_MODE], g_eUserRendering[id][RENDER_AMT]);
				g_eUserRendering[id][RENDER_STATUS] = true;
				g_iPredatorData[id][1] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_INVISIBLE", szName);
			}
		}
		case 3:
		{
			if(isSetBit(g_iBitUserAlive, id) && g_iPredatorData[id][WEAPON] >= g_iAllCvars[PREDATOR_WEAPON_ROUND])
			{
				g_iPredatorData[id][WEAPON] = 0;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_WEAPON", szName);
				switch(random_num(0, 2))
				{
					case 0:
					{
						if(isNotSetBit(g_iBitChainsaw, id))
						{
							setBit(g_iBitChainsaw, id);
							clearBit(g_iBitKatana, id);
							clearBit(g_iBitMachete, id);
							clearBit(g_iBitPerc, id);
							setBit(g_iBitWeaponStatus, id);
							if(get_user_weapon(id) == CSW_KNIFE)
							{
								new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
								if(iActiveItem > 0)
								{
									ExecuteHamB(Ham_Item_Deploy, iActiveItem);
									UTIL_WeaponAnimation(id, 3);
								}
							}
							UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_WEAPON_1");
						}
						else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_WEAPON_1_ERR");
					}
					case 1:
					{
						if(isNotSetBit(g_iBitMachete, id))
						{
							setBit(g_iBitMachete, id);
							clearBit(g_iBitKatana, id);
							clearBit(g_iBitChainsaw, id);
							clearBit(g_iBitPerc, id);
							setBit(g_iBitWeaponStatus, id);
							if(get_user_weapon(id) == CSW_KNIFE)
							{
								new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
								if(iActiveItem > 0)
								{
									ExecuteHamB(Ham_Item_Deploy, iActiveItem);
									UTIL_WeaponAnimation(id, 3);
								}
							}
							UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_WEAPON_2");
						}
						else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_WEAPON_2_ERR");
					}
					case 2:
					{
						if(isNotSetBit(g_iBitKatana, id))
						{
							setBit(g_iBitKatana, id);
							clearBit(g_iBitMachete, id);
							clearBit(g_iBitChainsaw, id);
							clearBit(g_iBitPerc, id);
							setBit(g_iBitWeaponStatus, id);
							if(get_user_weapon(id) == CSW_KNIFE)
							{
								new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
								if(iActiveItem > 0)
								{
									ExecuteHamB(Ham_Item_Deploy, iActiveItem);
									UTIL_WeaponAnimation(id, 3);
								}
							}
							UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_WEAPON_3");
						}
						else UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_WEAPON_3_ERR");
					}
				}
			}
		}
		case 4:
		{
			if(isSetBit(g_iBitUserAlive, id))
			{
				new iPlayer, iCount, iMoney = random_num(1, 300);
				for(iPlayer = 1, iCount = 0; iPlayer <= g_iMaxPlayers; iPlayer++)
				{
					if(g_iUserTeam[iPlayer] == 1 && jbm_get_user_money(iPlayer) >= iMoney && iPlayer != id)
					{
						iCount++;
						jbm_set_user_money(iPlayer, g_iUserMoney[iPlayer] - iMoney, 1);
						jbm_set_user_money(id, g_iUserMoney[id] + iMoney, 1);
					}
				}
				if(iCount != 0) UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_PREDATOR_THEFT", szName, iMoney);
				else UTIL_SayText(0, "!y[!gJBM!y]!y %L", "JBM_ALL_CHAT_PREDATOR_THEFT_ERR");
				g_iPredatorData[id][THEFT] = 0;
			}
		}
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_PredatorMenu(id);
}

Open_PredatorVoiceControlMenu(id, iPos)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(iPos < 0 || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || isSetBit(g_iBitUserBuyVoice, i) || isSetBit(g_iBitUserAdmin, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_PredatorMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_VOICE_CONTROL_PREDATOR_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_VOICE_CONTROL_PREDATOR_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[%L]^n", id, "JBM_KEY", ++b, szName, id, isSetBit(g_iBitUserVoice, i) ? "JBM_MENU_PREDATOR_VOICE_CONTROL_TAKE" : "JBM_MENU_PREDATOR_VOICE_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_PredatorVoiceControlMenu");
}

public Close_PredatorVoiceControlMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_PredatorVoiceControlMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_PredatorVoiceControlMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isNotSetBit(g_iBitUserAlive, iTarget) || g_iUserTeam[iTarget] != 1) return Open_PredatorVoiceControlMenu(id, g_iMenuPosition[id]);
			new szName[32], szTargetName[32];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(isSetBit(g_iBitUserVoice, iTarget))
			{
				clearBit(g_iBitUserVoice, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_PREDATOR_TAKE_VOICE", szName, szTargetName);
			}
			else
			{
				setBit(g_iBitUserVoice, iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_CHAT_ALL_PREDATOR_GIVE_VOICE", szName, szTargetName);
			}
		}
	}
	return Open_PredatorVoiceControlMenu(id, g_iMenuPosition[id]);
}

Open_BossMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || jbm_menu_blocked(id) || (g_iGlobalGame && g_iChiefId != id)) return PLUGIN_HANDLED;
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_BOSS_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_BOSS_HOOK_CONTROL", g_iBossHook, g_iAllCvars[BOSS_HOOK]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 2, id, "JBM_MENU_BOSS_SHOP", id, g_iBlockBoss[1] ? "JBM_MENU_CLOSE" : "JBM_MENU_OPEN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 3, id, "JBM_MENU_BOSS_BLOCK", id, g_iBlockBoss[0] ? "JBM_MENU_CLOSE" : "JBM_MENU_OPEN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n^n", id, "JBM_KEY", 4, id, "JBM_MENU_BOSS_HOOK", id, g_iBlockBoss[2] ? "JBM_MENU_DISABLE" : "JBM_MENU_ENABLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 5, id, "JBM_MENU_BOSS_BOOST_EXP", id, g_bBossBoostData[id][EXP_BOOST] ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 6, id, "JBM_MENU_BOSS_BOOST_MONEY", id, g_bBossBoostData[id][MONEY_BOOST] ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_BossMenu");
}

public Close_BossMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	switch(iKey)
	{
		case 0: return Open_HookControlMenu(id, g_iMenuPosition[id] = 0);
		case 1:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			if(!g_iBlockBoss[1])
			{
				g_iBlockBoss[1] = true;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_BOSS_SHOP_OFF", szName);
			}
			else 
			{
				g_iBlockBoss[1] = false;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_BOSS_SHOP_ON", szName);
			}
		}
		case 2:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			if(!g_iBlockBoss[0]) 
			{
				g_iBlockBoss[0] = true;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_BOSS_CT_CLOSE", szName);
			}
			else 
			{
				g_iBlockBoss[0] = false;
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_BOSS_CT_OPEN", szName);
			}
		}
		case 3:
		{
			new szName[32];
			get_user_name(id, szName, charsmax(szName));
			if(!g_iBlockBoss[2])
			{
				g_iBlockBoss[2] = true;
				//hook_mod_off(id);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_BOSS_OFF_HOOK", szName);
			}
			else 
			{
				g_iBlockBoss[2] = false;
				//hook_mod_on(id);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_BOSS_ON_HOOK", szName);
			}
		}
		case 4: g_bBossBoostData[id][EXP_BOOST] = !g_bBossBoostData[id][EXP_BOOST];
		case 5: g_bBossBoostData[id][MONEY_BOOST] = !g_bBossBoostData[id][MONEY_BOOST];
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_BossMenu(id);
}

Open_HookControlMenu(id, iPos)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserConnected, i) || isSetBit(g_iBitUserHook, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			switch(g_iUserTeam[id])
			{
				case 1, 2: return Open_BossMenu(id);
				default: return PLUGIN_HANDLED;
			}
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_HOOK_CONTROL_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_HOOK_CONTROL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		if(g_iBossHook < g_iAllCvars[BOSS_HOOK] || (g_iBossHook == g_iAllCvars[BOSS_HOOK] && isSetBit(g_iBitUserHookTime, i)))
		{
			iBitKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y[%L]^n", id, "JBM_KEY", ++b, szName, id, isSetBit(g_iBitUserHookTime, i) ? "JBM_MENU_BOSS_HOOK_CONTROL_TAKE" : "JBM_MENU_BOSS_HOOK_CONTROL_GIVE");
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s \y[%L]^n", id, "JBM_KEY", ++b, szName, id, isSetBit(g_iBitUserHookTime, i) ? "JBM_MENU_BOSS_HOOK_CONTROL_TAKE" : "JBM_MENU_BOSS_HOOK_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_HookControlMenu");
}

public Close_HookControlMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	switch(iKey)
	{
		case 7: return Open_HookControlMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_HookControlMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new szName[32], szTarget[32];
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			get_user_name(id, szName, charsmax(szName));
			get_user_name(iTarget, szTarget, charsmax(szTarget));
			if(isSetBit(g_iBitUserHookTime, iTarget) && isSetBit(g_iBitUserConnected, iTarget)) clearBit(g_iBitUserHookTime, iTarget), /*reset_hook(iTarget),*/ g_iBossHook--;
			else if(isNotSetBit(g_iBitUserHookTime, id) && g_iBossHook < g_iAllCvars[BOSS_HOOK] && isSetBit(g_iBitUserConnected, iTarget))
			{
				setBit(g_iBitUserHookTime, iTarget);
				//give_hook(iTarget);
				UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ALL_CHAT_BOSS_HOOK_CONTROL_GIVE", szName, szTarget);
				emit_sound(0, CHAN_AUTO, g_szSounds[HOOK_GIVE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				g_iBossHook++;
			}
		}
	}
	return Open_HookControlMenu(id, g_iMenuPosition[id]);
}

Open_ACPMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	new szMenu[512], iBitKeys = (1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_ACP_TITLE");
	
	if(g_iDayModeListSize && !g_iDuelStatus && g_iDayMode != DAYMODE_GAMES)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ACP_START_GAME");
		iBitKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 1, id, "JBM_MENU_ACP_START_GAME");
	
	if(g_iListMusicSize)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ACP_START_MUSIC");
		iBitKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_ACP_START_MUSIC");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_ACP_START_LEVEL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_ACP_START_MONEY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_ACP_START_HEALTH");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 6, id, "JBM_MENU_ACP_START_ARMOR");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 7, id, "JBM_MENU_ACP_START_GRAVITY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 8, id, "JBM_MENU_ACP_START_SPEED");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_ACPMenu");
}

public Close_ACPMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(jbm_get_day_mode() != 1 && jbm_get_day_mode() != 2) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Open_StartGameMenu(id, g_iMenuPosition[id] = 0);
		case 1: return Open_MusicMenu(id, g_iMenuPosition[id] = 0);
		case 2: return Open_GiveLevelMenu(id, g_iMenuPosition[id] = 0);
		case 3: return Open_GiveMoneyMenu(id, g_iMenuPosition[id] = 0);
		case 4: { client_cmd(id, "messagemode ^"set_user_arg^""); UTIL_SayText(id, "!y[!gJBM!y] %L", id, "JBM_ID_CHAT_ENTER_HEALTH"); g_iMenuType[id] = 0; }
		case 5: { client_cmd(id, "messagemode ^"set_user_arg^""); UTIL_SayText(id, "!y[!gJBM!y] %L", id, "JBM_ID_CHAT_ENTER_ARMOR"); g_iMenuType[id] = 1; }
		case 6: { g_iMenuType[id] = 2; return Open_TypeGravityMenu(id); }
		case 7: { g_iMenuType[id] = 3; return Open_TypeSpeedMenu(id); }
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_ACPMenu(id);
}

Open_StartGameMenu(id, iPos)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(iPos < 0) return PLUGIN_HANDLED;

	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iDayModeListSize) iStart = g_iDayModeListSize;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iDayModeListSize) iEnd = g_iDayModeListSize;
	
	new szMenu[512];
	new iPagesNum = (g_iDayModeListSize / PLAYERS_PER_PAGE + ((g_iDayModeListSize % PLAYERS_PER_PAGE) ? 1 : 0));
	new iLen;
	
	switch(iPagesNum)
	{
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_START_GAME_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_START_GAME_TITLE", iPos + 1, iPagesNum);
	}
	new aDataDayMode[DATA_DAY_MODE], iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aDataDayMode, a, aDataDayMode);
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", ++b, id, aDataDayMode[LANG_MODE]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_StartGameMenu");
}

public Close_StartGameMenu(id, iKey)
{
	if(g_iDayMode == DAYMODE_GAMES)
	{
		UTIL_SayText(id, "!y[!gJBM!y] !yВ данный момент уже идут игры!.");
		return PLUGIN_HANDLED;
	}
	if(g_iDuelStatus)
	{
		UTIL_SayText(id, "!y[!gJBM!y] !yВ данный момент идет дуэль!.");
		return PLUGIN_HANDLED;
	}
	switch(iKey)
	{
		case 7: return Open_StartGameMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_StartGameMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			if(g_iAlivePlayersNum[1] < 2 || !g_iAlivePlayersNum[2])
			{
				UTIL_SayText(id, "!y[!gJBM!y] !yДля запуска нужно !tне менее 2 зеков!y и минимум !t1 охранник!y.");
				return PLUGIN_HANDLED;
			}
	
			new aDataDayMode[DATA_DAY_MODE]; 
			g_iGameMode = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
			ArrayGetArray(g_aDataDayMode, g_iGameMode, aDataDayMode);
			ExecuteForward(g_iHookDayMode[DAY_MODE_START], g_iReturnDayMode, g_iGameMode, 0);
			jbm_restore_game();
			new szName[32]; get_user_name(id, szName, charsmax(szName));
			UTIL_SayText(0, "!y[!gJBM!y] %L", id, "JBM_ID_CHAT_START_GAME", szName, LANG_PLAYER, aDataDayMode[LANG_MODE]);
			return PLUGIN_HANDLED;
		}
	}
	return Open_StartGameMenu(id, g_iMenuPosition[id]);
}

Open_MusicMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iListMusicSize) iStart = g_iListMusicSize;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iListMusicSize) iEnd = g_iListMusicSize + (iPos ? 1 : 0);
	new szMenu[512], iLen, iPagesNum = (g_iListMusicSize / PLAYERS_PER_PAGE + ((g_iListMusicSize % PLAYERS_PER_PAGE) ? 1 : 0));
	new iBitKeys = (1<<9), b;
	iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wЗапуск музыки \r[%d|%d]^n^n", iPos + 1, iPagesNum);
	for(new a = iStart; a < iEnd; a++)
	{
		new aDataMusic[DATA_MUSIC];
		ArrayGetArray(g_aDataMusicList, a, aDataMusic);
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, aDataMusic[MUSIC_NAME]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_MusicMenu");
}

public Close_MusicMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_MusicMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_MusicMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new szName[32], aDataMusic[DATA_MUSIC];
			get_user_name(id, szName, charsmax(szName));
			new iTrack = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
			ArrayGetArray(g_aDataMusicList, iTrack, aDataMusic);
			set_hudmessage(0, 255, 0, -1.0, 0.4, 0, 0.0, 6.0, 0.5, 0.5); 
			show_hudmessage(0, "%s включил песню: ^n%s", szName, aDataMusic[MUSIC_NAME]);
			client_cmd(0, "mp3 play %s.mp3", aDataMusic[FILE_DIR]);
		}
	}
	return PLUGIN_HANDLED;
}

Open_GiveLevelMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserConnected, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ACPMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_SET_LEVEL_TITLE");
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n^n", id, "JBM_MENU_SET_LEVEL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y%d LVL %s^n", id, "JBM_KEY", ++b, szName, g_iLevel[i][0], i == id ? "\rЭто вы" : "");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	
	return show_menu(id, iBitKeys, szMenu, -1, "Open_GiveLevelMenu");
}

public Close_GiveLevelMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_GiveLevelMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_GiveLevelMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			g_iMenuTarget[id] = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new szName[32]; get_user_name(g_iMenuTarget[id], szName, charsmax(szName));
			UTIL_SayText(id, "!y[!gJBM!y] !yВведите уровень для игрока !t%s!y.", szName);
			client_cmd(id, "messagemode ^"set_user_level %d^"", g_iMenuTarget[id]);
			return Open_GiveLevelMenu(id, g_iMenuPosition[id]);
		}
	}
	return PLUGIN_HANDLED;
}

Open_GiveMoneyMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserConnected, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ACPMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wУстановка баланс игроку^n^n");
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wУстановка баланс игроку \r[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s \y%d$ %s^n", id, "JBM_KEY", ++b, szName, g_iUserMoney[i], i == id ? "\rЭто вы" : "");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_GiveMoneyMenu");
}

public Close_GiveMoneyMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_GiveMoneyMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_GiveMoneyMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			g_iMenuTarget[id] = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new szName[32]; get_user_name(g_iMenuTarget[id], szName, charsmax(szName));
			UTIL_SayText(id, "!y[!gJBM!y] !yВведите баланс для игрока !t%s!y.", szName);
			client_cmd(id, "messagemode ^"set_user_money %d^"", g_iMenuTarget[id]);
			return Open_GiveMoneyMenu(id, g_iMenuPosition[id]);
		}
	}
	return PLUGIN_HANDLED;
}

Open_TypeGravityMenu(id)
{
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wСила гравитации^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wОчень слабая \r---^n", id, "JBM_KEY", 1);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСлабая \r+--^n", id, "JBM_KEY", 2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСтандартная \r++-^n", id, "JBM_KEY", 3);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСильная \r+++^n", id, "JBM_KEY", 4);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_TypeGravityMenu");
}

public Close_TypeGravityMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: { g_fMenuArg[id] = 0.2; Open_WhoGetIt(id); }
		case 1: { g_fMenuArg[id] = 0.5; Open_WhoGetIt(id); }
		case 2: { g_fMenuArg[id] = 1.0; Open_WhoGetIt(id); }
		case 3: { g_fMenuArg[id] = 1.5; Open_WhoGetIt(id); }
		case 8: return Open_ACPMenu(id);
	}
	return PLUGIN_HANDLED;
}

Open_TypeSpeedMenu(id)
{
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wСкорость игрока^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСлабая \r---^n", id, "JBM_KEY", 1);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСтандартная \r+--^n", id, "JBM_KEY", 2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wСильная \r++-^n", id, "JBM_KEY", 3);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wОчень сильная \r+++^n", id, "JBM_KEY", 4);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_TypeSpeedMenu");
}

public Close_TypeSpeedMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: { g_fMenuArg[id] = 50.0; Open_WhoGetIt(id); }
		case 1: { g_fMenuArg[id] = 270.0; Open_WhoGetIt(id); }
		case 2: { g_fMenuArg[id] = 500.0; Open_WhoGetIt(id); }
		case 3: { g_fMenuArg[id] = 1000.0; Open_WhoGetIt(id); }
		case 8: return Open_ACPMenu(id);
	}
	return PLUGIN_HANDLED;
}

Open_WhoGetIt(id)
{
	new szMenu[512], iBitKeys = (1<<0|1<<1|1<<2|1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wКому выдать^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wВыдать \rзекам^n", id, "JBM_KEY", 1);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wВыдать \rохранникам^n^n", id, "JBM_KEY", 2);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \wВыдать \rконкретному игроку^n", id, "JBM_KEY", 3);
	iLen += formatex(szMenu[iLen], charsmax(szMenu)	- iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_WhoGetIt");
}

public Close_WhoGetIt(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++) 
			{
				if(isSetBit(g_iBitUserAlive, i) && g_iUserTeam[i] == 1 && isNotSetBit(g_iBitUserDuel, i))
				{
					switch(g_iMenuType[id])
					{
						case 0: set_pev(i, pev_health, float(g_iMenuArg[id]));
						case 1: set_pev(i, pev_armorvalue, float(g_iMenuArg[id]));
						case 2: set_pev(i, pev_gravity, g_fMenuArg[id]);
						case 3: { g_fUserSpeed[i] = g_fMenuArg[id]; ExecuteHamB(Ham_Player_ResetMaxSpeed, i); }
					}
				}
			}
			new szName[32]; get_user_name(id, szName, charsmax(szName));
			switch(g_iMenuType[id])
			{
				case 0: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yустановил всем заключенным !g%d!yHP.", szName, g_iMenuArg[id]);
				case 1: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yустановил всем заключенным !g%d!yAP.", szName, g_iMenuArg[id]);
				case 2: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yизменил гравитацию всем заключенным", szName);
				case 3: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yизменил скорость всем заключенным", szName);
			}
			g_iMenuArg[id] = 0;
		}
		case 1:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++) 
			{
				if(isSetBit(g_iBitUserAlive, i) && g_iUserTeam[i] == 2 && isNotSetBit(g_iBitUserDuel, i))
				{
					switch(g_iMenuType[id])
					{
						case 0: set_pev(i, pev_health, float(g_iMenuArg[id]));
						case 1: set_pev(i, pev_armorvalue, float(g_iMenuArg[id]));
						case 2: set_pev(i, pev_gravity, g_fMenuArg[id]);
						case 3: { g_fUserSpeed[i] = g_fMenuArg[id]; ExecuteHamB(Ham_Player_ResetMaxSpeed, i); }
					}
				}
			}
			new szName[32]; get_user_name(id, szName, charsmax(szName));
			switch(g_iMenuType[id])
			{
				case 0: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yустановил всем охранникам !g%d!yHP.", szName, g_iMenuArg[id]);
				case 1: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yустановил всем охранникам !g%d!yAP.", szName, g_iMenuArg[id]);
				case 2: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yизменил гравитацию всем охранникам", szName);
				case 3: UTIL_SayText(0, "!y[!gJBM!y] !t%s !yизменил скорость всем охранникам", szName);
			}
			g_iMenuArg[id] = 0;
		}
		case 2: return Open_GiveIdMenu(id, g_iMenuPosition[id] = 0);
		case 8: return Open_ACPMenu(id);
	}
	return PLUGIN_HANDLED;
}

Open_GiveIdMenu(id, iPos)
{
	if(iPos < 0) return Open_WhoGetIt(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserAlive, i)) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			return Open_ACPMenu(id);
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wВыбор игрока^n^n");
		default: iLen = formatex(szMenu, charsmax(szMenu), "\y[\dJBM\y] \wВыбор игрока \r[%d|%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iBitKeys = (1<<7|1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		iBitKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s %s^n", id, "JBM_KEY", ++b, szName, i == id ? "\rЭто вы" : "");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_GiveIdMenu");
}

public Close_GiveIdMenu(id, iKey)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 7: return Open_GiveIdMenu(id, --g_iMenuPosition[id]);
		case 8: return Open_GiveIdMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(isSetBit(g_iBitUserDuel, iTarget)) { UTIL_SayText(id, "!y[!gJBM!y] !yИгрок играет в дуэль"); return Open_ACPMenu(id); }
			new szName[2][32]; get_user_name(id, szName[0], charsmax(szName[]));
			get_user_name(iTarget, szName[1], charsmax(szName[]));
			
			switch(g_iMenuType[id])
			{
				case 0: { UTIL_SayText(id, "!y[!gJBM!y] !t%s !yустановил игроку !g%s !t%d!yHP.", szName[0], szName[1], g_iMenuArg[id]); set_pev(iTarget, pev_health, float(g_iMenuArg[id])); }
				case 1: { UTIL_SayText(id, "!y[!gJBM!y] !t%s !yустановил игроку !g%s !t%d!yAP.", szName[0], szName[1], g_iMenuArg[id]); set_pev(iTarget, pev_armorvalue, float(g_iMenuArg[id])); }
				case 2: { UTIL_SayText(id, "!y[!gJBM!y] !t%s !yизменил игроку !g%s !yсилу гравитации.", szName[0], szName[1]); set_pev(iTarget, pev_gravity, g_fMenuArg[id]); }
				case 3: { UTIL_SayText(id, "!y[!gJBM!y] !t%s !yизменил игроку !g%s !yскорость.", szName[0], szName[1]); g_fUserSpeed[iTarget] = g_fMenuArg[id]; ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget); }
			}
			return Open_GiveIdMenu(id, g_iMenuPosition[id]);
		}
	}
	return PLUGIN_HANDLED;
}

Open_TrailMenu(id)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBM_MENU_TRAIL_TITLE");
	if(jbm_is_user_alive(id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L %L^n", id, "JBM_KEY", 1, id, "JBM_MENU_TRAIL_ENABLE_DISABLE", id, task_exists(TASK_TRAIL+id) ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_TRAIL_SPRITE", g_iSpriteText[aDataTrail[id][SPRITE]]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_TRAIL_COLOR", g_iColorText[aDataTrail[id][COLOR]]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_TRAIL_BRITHNESS", g_iBrightness[aDataTrail[id][BRIGHTNESS]]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_TRAIL_WIDTH", g_iWidth[aDataTrail[id][WIDTH]]);
		iBitKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L %L^n", id, "JBM_KEY", 1, id, "JBM_MENU_TRAIL_ENABLE_DISABLE", id, task_exists(TASK_TRAIL+id) ? "JBM_MENU_ENABLE" : "JBM_MENU_DISABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 2, id, "JBM_MENU_TRAIL_SPRITE", g_iSpriteText[aDataTrail[id][SPRITE]]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 3, id, "JBM_MENU_TRAIL_COLOR", g_iColorText[aDataTrail[id][COLOR]]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 4, id, "JBM_MENU_TRAIL_BRITHNESS", g_iBrightness[aDataTrail[id][BRIGHTNESS]]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%L^n", id, "JBM_KEY", 5, id, "JBM_MENU_TRAIL_WIDTH", g_iWidth[aDataTrail[id][WIDTH]]);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_TrailMenu");
}

public Close_TrailMenu(id, iKey)
{
#if defined BLOCK_DONATE_GLOBALGAMES
	if(g_iGlobalGame && g_iChiefId != id) { UTIL_SayText(id, "!y[!gJBM!y] Недоступно во время глобальных игр."); return PLUGIN_HANDLED; }
#endif
	if(jbm_get_day_mode() != 1 && jbm_get_day_mode() != 2) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			if(!jbm_is_user_alive(id)) return PLUGIN_HANDLED;
			switch(task_exists(TASK_TRAIL+id))
			{
				case false:
				{
					UTIL_RemoveTrail_TASK(id);
					get_user_origin(id, g_iPlayerPosition[id]);
					set_task(0.2, "CheckPosition", TASK_TRAIL+id, "", 0, "b");
					UTIL_CreateTrail(id);
				}
				case true:
				{
					UTIL_RemoveTrail_TASK(id);
				}
			}
		}
		case 1:
		{
			if(!jbm_is_user_alive(id)) return PLUGIN_HANDLED;
			++aDataTrail[id][SPRITE];
			if(aDataTrail[id][SPRITE] == g_iSpriteNum) aDataTrail[id][SPRITE] = 0;
		// Обновим наш траил
			if(task_exists(TASK_TRAIL+id))
			{
				UTIL_RemoveTrail_TASK(id);
				get_user_origin(id, g_iPlayerPosition[id]);
				set_task(0.2, "CheckPosition", TASK_TRAIL+id, "", 0, "b");
				UTIL_CreateTrail(id);
			}
		}
		case 2:
		{
			if(!jbm_is_user_alive(id)) return PLUGIN_HANDLED;
			++aDataTrail[id][COLOR];
			if(aDataTrail[id][COLOR] == g_iColorNum) aDataTrail[id][COLOR] = 0;
		// Обновим наш траил
			if(task_exists(TASK_TRAIL+id))
			{
				UTIL_RemoveTrail_TASK(id);
				get_user_origin(id, g_iPlayerPosition[id]);
				set_task(0.2, "CheckPosition", TASK_TRAIL+id, "", 0, "b");
				UTIL_CreateTrail(id);
			}
		}
		case 3:
		{
			if(!jbm_is_user_alive(id)) return PLUGIN_HANDLED;
			if(aDataTrail[id][BRIGHTNESS] == charsmax(g_iBrightness)) aDataTrail[id][BRIGHTNESS] = 0;
			else aDataTrail[id][BRIGHTNESS]++;
		// Обновим наш траил
			if(task_exists(TASK_TRAIL+id))
			{
				UTIL_RemoveTrail_TASK(id);
				get_user_origin(id, g_iPlayerPosition[id]);
				set_task(0.2, "CheckPosition", TASK_TRAIL+id, "", 0, "b");
				UTIL_CreateTrail(id);
			}
		}
		case 4:
		{
			if(!jbm_is_user_alive(id)) return PLUGIN_HANDLED;
			if(aDataTrail[id][WIDTH] == charsmax(g_iWidth)) aDataTrail[id][WIDTH] = 0;
			else aDataTrail[id][WIDTH]++;
		// Обновим наш траил
			if(task_exists(TASK_TRAIL+id))
			{
				UTIL_RemoveTrail_TASK(id);
				get_user_origin(id, g_iPlayerPosition[id]);
				set_task(0.2, "CheckPosition", TASK_TRAIL+id, "", 0, "b");
				UTIL_CreateTrail(id);
			}
		}
		case 8: return Open_DonateMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Open_TrailMenu(id);
}

public CheckPosition(taskid) 
{
	new iOrigin[3], pPlayer = taskid - TASK_TRAIL;
	if(g_iUserTeam[pPlayer] != 1 && g_iUserTeam[pPlayer] != 2) 
	{
		UTIL_RemoveTrail_MSG(pPlayer);
		return;
	}
	get_user_origin(pPlayer, iOrigin);
	if(iOrigin[0] != g_iPlayerPosition[pPlayer][0] || iOrigin[1] != g_iPlayerPosition[pPlayer][1] || iOrigin[2] != g_iPlayerPosition[pPlayer][2]) 
	{
		if(get_distance(iOrigin, g_iPlayerPosition[pPlayer]) > 300 || g_iTimer[pPlayer] >= 10) 
		{
			UTIL_RemoveTrail_MSG(pPlayer);
			UTIL_CreateTrail(pPlayer);
		}
		g_iPlayerPosition[pPlayer][0] = iOrigin[0];
		g_iPlayerPosition[pPlayer][1] = iOrigin[1];
		g_iPlayerPosition[pPlayer][2] = iOrigin[2];
		g_iTimer[pPlayer] = 0;
	} 
	else if (g_iTimer[pPlayer] < 10) g_iTimer[pPlayer]++;
}

Open_InfoMenu(id)
{
	new szMenu[512], iBitKeys = (1<<8|1<<9), 
	iLen = formatex(szMenu, charsmax(szMenu), "%L^n\d%L^n^n", id, "JBM_MENU_INFO_TITLE", id, "JBM_MENU_INFO_VK");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L^n^n", id, "JBM_MENU_INFO");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_InfoMenu");
}

public Close_InfoMenu(id, iKey)
{
	if(iKey == 8)
	{
		switch(g_iUserTeam[id])
		{
			case 1: return Open_MainPnMenu(id);
			case 2: return Open_MainGrMenu(id);
		}
	}
	return PLUGIN_HANDLED;
}

/* < Меню < *///}

/* > Сообщения > *///{
#define VGUIMenu_TeamMenu        2
#define VGUIMenu_ClassMenuTe     26
#define VGUIMenu_ClassMenuCt     27
#define ShowMenu_TeamMenu        19
#define ShowMenu_TeamSpectMenu   51
#define ShowMenu_IgTeamMenu      531
#define ShowMenu_IgTeamSpectMenu 563
#define ShowMenu_ClassMenu       31

INIT_MESSAGE()
{
// Заблокированные сообщения, чтоб не мешали :)
	register_message(MsgId_ClCorpse,		"Message_Blocked");
	register_message(MsgId_HudTextArgs,		"Message_Blocked");
	register_message(MsgId_TextMsg,			"Message_Blocked");
	register_message(MsgId_Money,			"Message_Blocked");
	//register_message(MsgId_Health,		"Message_Blocked");
	register_message(MsgId_StatusText,		"Message_Blocked");
	
// Другое
	register_message(MsgId_ShowMenu,		"Message_ShowMenu");
	register_message(MsgId_VGUIMenu,		"Message_VGUIMenu");
	register_message(MsgId_SendAudio,		"Message_SendAudio");
	register_message(MsgId_ScoreAttrib,		"Message_ScoreBoard");
}

public Message_Blocked()
	return PLUGIN_HANDLED;

public Message_ShowMenu(iMsgId, iMsgDest, iReceiver)
{
	switch(get_msg_arg_int(1))
	{
		case ShowMenu_TeamMenu, ShowMenu_TeamSpectMenu:
		{
			Open_ChooseTeamMenu(iReceiver);
			return PLUGIN_HANDLED;
		}
		case ShowMenu_ClassMenu, ShowMenu_IgTeamMenu, ShowMenu_IgTeamSpectMenu: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public Message_VGUIMenu(iMsgId, iMsgDest, iReceiver)
{
	switch(get_msg_arg_int(1))
	{
		case VGUIMenu_TeamMenu:
		{
			Open_ChooseTeamMenu(iReceiver);
			return PLUGIN_HANDLED;
		}
		case VGUIMenu_ClassMenuTe, VGUIMenu_ClassMenuCt: return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
	
public Message_SendAudio()
{
	new szArg[32];
	get_msg_arg_string(2, szArg, charsmax(szArg));
	if
	(
		szArg[0] == '%' 
		&& (szArg[2] == 'M' && szArg[3] == 'R' && szArg[4] == 'A' && szArg[5] == 'D'
		&& equal(szArg[7], "FIREINHOLE", 10))
	) { return PLUGIN_HANDLED; }
	return PLUGIN_CONTINUE;
}

public Message_ScoreBoard(iMsgId, iMsgDest, iReceiver)
{
	if(get_msg_arg_int(2) || isNotSetBit(g_iBitUserVip, get_msg_arg_int(1)))
		return;
	
	set_msg_arg_int(2, ARG_BYTE, (1<<2));
}

/* < Сообщения < *///}

/* > Двери в тюремных камерах > *///{

INIT_DOOR()
{
	g_aDoorList = ArrayCreate();
	new iEntity[2], Float:vecOrigin[3], szClassName[32], szTargetName[32];
	while((iEntity[0] = engfunc(EngFunc_FindEntityByString, iEntity[0], "classname", "info_player_deathmatch")))
	{
		pev(iEntity[0], pev_origin, vecOrigin);
		while((iEntity[1] = engfunc(EngFunc_FindEntityInSphere, iEntity[1], vecOrigin, 200.0)))
		{
			if(!pev_valid(iEntity[1])) 
				continue;
			
			pev(iEntity[1], pev_classname, szClassName, charsmax(szClassName));
			if(szClassName[5] != 'd' && szClassName[6] != 'o' && szClassName[7] != 'o' && szClassName[8] != 'r') 
				continue;
			
			if(pev(iEntity[1], pev_iuser1) == IUSER1_DOOR_KEY) 
				continue;
			
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

/* < Двери в тюремных камерах < *///}

/* > 'fakemeta' события > *///{
INIT_FAKEMETA()
{
	TrieDestroy(g_tButtonList);
	unregister_forward(FM_KeyValue, g_iFakeMetaKeyValue, true);
	TrieDestroy(g_tRemoveEntities);
	unregister_forward(FM_Spawn, g_iFakeMetaSpawn, true);
	register_forward(FM_EmitSound, "FakeMeta_EmitSound", false);
	register_forward(FM_SetClientKeyValue, "FakeMeta_SetClientKeyValue", false);
	register_forward(FM_Voice_SetClientListening, "FakeMeta_Voice_SetListening", false);
	register_forward(FM_SetModel, "FakeMeta_SetModel", false);
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
	if(IsValidPlayer(id))
	{
		if(szSample[8] == 'k' && szSample[9] == 'n' && szSample[10] == 'i' && szSample[11] == 'f' && szSample[12] == 'e')
		{
			if(g_bSoccerStatus && isSetBit(g_iBitUserSoccer, id))
			{
				switch(szSample[17])
				{
					case 'l': emit_sound(id, iChannel, g_szSounds[HAND_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					case 'w': emit_sound(id, iChannel, g_szSounds[HAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					case 's': emit_sound(id, iChannel, g_szSounds[HAND_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					case 'b': emit_sound(id, iChannel, g_szSounds[HAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					default: emit_sound(id, iChannel, g_szSounds[HAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
				}
				return FMRES_SUPERCEDE;
			}
			if(g_iBitWeaponStatus && isSetBit(g_iBitWeaponStatus, id) && isNotSetBit(g_iBitUserDuel, id))
			{
				switch(szSample[17])
				{
					case 'l':
					{
						if(isSetBit(g_iBitKatana, id)) emit_sound(id, iChannel, g_szSounds[KATANA_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(isSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(isSetBit(g_iBitChainsaw, id)) emit_sound(id, iChannel, g_szSounds[CHAINSAW_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					    else if(isSetBit(g_iBitPerc, id)) emit_sound(id, iChannel, g_szSounds[PERC_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					}
					case 'w':
					{
						if(isSetBit(g_iBitKatana, id)) emit_sound(id, iChannel, g_szSounds[KATANA_HITWALL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(isSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_HITWALL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(isSetBit(g_iBitChainsaw, id)) emit_sound(id, iChannel, g_szSounds[CHAINSAW_HITWALL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(isSetBit(g_iBitPerc, id)) emit_sound(id, iChannel, g_szSounds[PERC_HITWALL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					}
					case 's':
					{
						if(isSetBit(g_iBitKatana, id)) emit_sound(id, iChannel, g_szSounds[KATANA_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(isSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(isSetBit(g_iBitChainsaw, id)) emit_sound(id, iChannel, g_szSounds[CHAINSAW_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(isSetBit(g_iBitPerc, id)) emit_sound(id, iChannel, g_szSounds[PERC_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					}
					case 'b':
					{
						if(isSetBit(g_iBitKatana, id)) emit_sound(id, iChannel, g_szSounds[KATANA_STAB], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(isSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_HIT], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(isSetBit(g_iBitChainsaw, id)) emit_sound(id, iChannel, g_szSounds[CHAINSAW_STAB], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					    else if(isSetBit(g_iBitPerc, id)) emit_sound(id, iChannel, g_szSounds[PERC_STAB], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					}
					default:
					{
						if(isSetBit(g_iBitKatana, id)) emit_sound(id, iChannel, g_szSounds[KATANA_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(isSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(isSetBit(g_iBitChainsaw, id)) emit_sound(id, iChannel, g_szSounds[CHAINSAW_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(isSetBit(g_iBitPerc, id)) emit_sound(id, iChannel, g_szSounds[PERC_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
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
						case 'l': emit_sound(id, iChannel, g_szSounds[HAND_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						case 'w': emit_sound(id, iChannel, g_szSounds[HAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						case 's': emit_sound(id, iChannel, g_szSounds[HAND_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						case 'b': emit_sound(id, iChannel, g_szSounds[HAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						default: emit_sound(id, iChannel, g_szSounds[HAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
					}
				}
				case 2:
				{
					switch(szSample[17])
					{
						case 'l': emit_sound(id, iChannel, g_szSounds[BATON_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						case 'w': emit_sound(id, iChannel, g_szSounds[BATON_HITWALL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						case 's': emit_sound(id, iChannel, g_szSounds[BATON_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						case 'b': emit_sound(id, iChannel, g_szSounds[BATON_STAB], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						default: emit_sound(id, iChannel, g_szSounds[BATON_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
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
	if(isSetBit(g_iBitUserModel, id) && equal(szKey, "model"))
	{
		new szModel[32];
		jbm_get_user_model(id, szModel, charsmax(szModel));
		if(!equal(szModel, g_szUserModel[id])) jbm_set_user_model(id, g_szUserModel[id]);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public FakeMeta_Voice_SetListening(iReceiver, iSender, bool:bListen)
{
	if(isSetBit(g_iBitUserVoice, iSender) || isSetBit(g_iBitUserAdmin, iSender) || isSetBit(g_iBitUserBuyVoice, iSender) || (g_iUserTeam[iSender] == 2 && isSetBit(g_iBitUserAlive, iSender)))
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, true);
		return FMRES_SUPERCEDE;
	}
	engfunc(EngFunc_SetClientListening, iReceiver, iSender, false);
	return FMRES_SUPERCEDE;
}

public FakeMeta_SetModel(iEntity, szModel[])
{
	if(g_iBitFrostNade && szModel[7] == 'w' && szModel[8] == '_' && szModel[9] == 's' && szModel[10] == 'm')
	{
		new iOwner = pev(iEntity, pev_owner);
		if(isSetBit(g_iBitFrostNade, iOwner))
		{
			set_pev(iEntity, pev_iuser1, IUSER1_FROSTNADE_KEY);
			clearBit(g_iBitFrostNade, iOwner);
			CREATE_BEAMFOLLOW(iEntity, g_pSpriteBeam, 10, 10, 0, 110, 255, 200);
		}
	}
}

/* < 'fakemeta' события < *///}

/* > 'hamsandwich' события > *///{
INIT_HAMSANDWICH()
{
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", true);
	RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled", false);
	RegisterHam(Ham_Killed, "player", "Ham_PlayerKilled_Post", true);
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttack_Player", false);
	RegisterHam(Ham_TraceAttack, "func_button", "Ham_TraceAttack_Button", false);
	RegisterHam(Ham_TakeDamage, "player", "Ham_TakeDamage_Player", false);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "Ham_KnifePrimaryAttack_Post", true);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_KnifeSecondaryAttack_Post", true);
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Ham_KnifeDeploy_Post", true);
	
	new const g_szDoorClass[][] = 
	{
		"func_door", 
		"func_door_rotating"
	};
	for(new i; i < sizeof(g_szDoorClass); i++)
	{
		RegisterHam(Ham_Use, g_szDoorClass[i], "Ham_DoorUse", false);
	}
	for(new i; i < sizeof(g_szDoorClass); i++) 
	{
		RegisterHam(Ham_Blocked, g_szDoorClass[i], "Ham_DoorBlocked", false);
	}
	
	RegisterHam(Ham_ObjectCaps, "player", "Ham_ObjectCaps_Post", true);
	RegisterHam(Ham_Think, "func_wall", "Ham_WallThink_Post", true);
	RegisterHam(Ham_Touch, "func_wall", "Ham_WallTouch_Post", true);
	register_impulse(100, "ClientImpulse100");
	
	DisableHamForward(g_iHamHookForwardsDjihad = RegisterHam(Ham_Touch, "player", "Ham_PlayerTouch", false));
	
	new const g_szWeaponName[][] = 
	{
		"weapon_p228",		"weapon_scout",			"weapon_hegrenade",	"weapon_xm1014",	"weapon_c4",	"weapon_mac10", 
		"weapon_aug",		"weapon_smokegrenade",	"weapon_elite",		"weapon_fiveseven",	"weapon_ump45",	"weapon_sg550",    
		"weapon_galil",		"weapon_famas",			"weapon_usp",		"weapon_glock18",	"weapon_awp",	"weapon_mp5navy",  
		"weapon_m249",		"weapon_m3",			"weapon_m4a1",		"weapon_tmp",		"weapon_g3sg1",	"weapon_flashbang",
		"weapon_deagle",	"weapon_sg552",			"weapon_ak47",		"weapon_p90"
	};
	for(new i; i < sizeof(g_szWeaponName); i++) 
	{
		RegisterHam(Ham_Item_Deploy, g_szWeaponName[i], "Ham_ItemDeploy_Post", true);
	}
	for(new i; i < sizeof(g_szWeaponName); i++) 
	{
		RegisterHam(Ham_Weapon_PrimaryAttack, g_szWeaponName[i], "Ham_ItemPrimaryAttack_Post", true);
	}
	
	RegisterHam(Ham_Player_Jump, "player", "Ham_PlayerJump", false);
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "Ham_PlayerResetMaxSpeed_Post", true);
	RegisterHam(Ham_Touch, "grenade", "Ham_GrenadeTouch_Post", true);
	
	for(new i; i <= 8; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", false));
	for(new i = 9; i < sizeof(g_szHamHookEntityBlock); i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", false));
}

#if !defined OLD_WEAPON_SYSTEM
native jbm_open_guard_weapon_menu(pPlayer);
#endif
public Ham_PlayerSpawn_Post(pPlayer)
{
	if(isNotSetBit(g_iBitUserConnected, pPlayer)) 
		return;
	
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
	{
		setBit(g_iBitUserAlive, pPlayer);
		g_iAlivePlayersNum[g_iUserTeam[pPlayer]]++;
		remove_task(pPlayer+TASK_SHOW_DEAD_INFORMER);
	}
	if(task_exists(TASK_TRAIL+pPlayer)) { remove_task(TASK_TRAIL+pPlayer); }
	jbm_default_player_model(pPlayer);
	if(!g_bRestartGame && g_iDayWeek > 0 && g_iDayWeek != 6 && g_iDayWeek != 7)
	{
		if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE)
		{
			if(g_iUserTeam[pPlayer] == 2) { jbm_open_guard_weapon_menu(pPlayer); }
			if(g_iUserTeam[pPlayer] == 2 && g_iPlayersParams[GR_HP] > 0) { set_pev(pPlayer, pev_health, float(g_iPlayersParams[GR_HP]) + float(g_iLevel[pPlayer][1] * g_iLevelCvars[HEALTH_BONUS])); }
			if(g_iUserTeam[pPlayer] == 1 && g_iDayMode == DAYMODE_FREE) 
			{
				setBit(g_iBitUserFree, pPlayer); 
				set_pev(pPlayer, pev_skin, g_iPlayersParams[FD_SKIN]);
			}
			if(g_eUserCostumes[pPlayer][HIDE]) { jbm_set_user_costumes(pPlayer, g_eUserCostumes[pPlayer][COSTUMES]); }
		}
		jbm_set_user_money(pPlayer, g_iUserMoney[pPlayer] + (g_iLevel[pPlayer][0] * g_iLevelCvars[MONEY_BONUS]), 0);
		jbm_set_user_money(pPlayer, g_iUserMoney[pPlayer] + g_iAllCvars[ROUND_FREE_MONEY], 0);
		if(g_bBossBoostData[pPlayer][MONEY_BOOST]) jbm_set_user_money(pPlayer, g_iUserMoney[pPlayer] + g_iAllCvars[ROUND_FREE_MONEY], 0);
	}
	fm_strip_user_weapons(pPlayer);
	fm_give_item(pPlayer, "weapon_knife");
	set_pev(pPlayer, pev_armorvalue, 0.0);
		
	if(g_iGlobalGame == 1) { g_iUserRoleMafia[pPlayer] = 0; set_task(1.0, "jbm_show_role_informer", pPlayer+TASK_SHOW_ROLE_GG, _, _, "b"); }
	else if(g_iGlobalGame == 2)
	{
		g_iUserRoleDjixad[pPlayer] = 0;
		clearBit(g_iBitUserBury, pPlayer);
		set_task(1.0, "jbm_show_role_informer", pPlayer+TASK_SHOW_ROLE_GG, _, _, "b");
	}
}

public Ham_PlayerKilled(iVictim)
{
	if(isSetBit(g_iBitUserVoteDayMode, iVictim) || isSetBit(g_iBitUserFrozen, iVictim))
		set_pev(iVictim, pev_flags, pev(iVictim, pev_flags) & ~FL_FROZEN);
}

public Ham_PlayerKilled_Post(iVictim, iKiller)
{
	if(isNotSetBit(g_iBitUserAlive, iVictim)) 
		return;
	
	new bool:bValidKilled = IsValidPlayer(iKiller);
	clearBit(g_iBitUserAlive, iVictim);
	g_iAlivePlayersNum[g_iUserTeam[iVictim]]--;
	ClearSyncHud(iVictim, g_iSyncStatusText);
	set_task(1.0, "jbm_main_dead_informer", iVictim+TASK_SHOW_DEAD_INFORMER, _, _, "b");
	if(task_exists(TASK_TRAIL+iVictim)) remove_task(TASK_TRAIL+iVictim);
	switch(g_iDayMode)
	{
		case DAYMODE_STANDART..DAYMODE_FREE:
		{
			if(isSetBit(g_iBitUserSoccer, iVictim))
			{
				clearBit(g_iBitUserSoccer, iVictim);
				if(iVictim == g_iSoccerBallOwner)
				{
					CREATE_KILLPLAYERATTACHMENTS(iVictim);
					set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
					set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.1});
					g_iSoccerBallOwner = 0;
				}
				if(g_bSoccerGame) remove_task(iVictim+TASK_SHOW_SOCCER_SCORE);
			}
			if(g_iDuelStatus && isSetBit(g_iBitUserDuel, iVictim)) jbm_duel_ended(iVictim);
			if(pev(iVictim, pev_renderfx) != kRenderFxNone || pev(iVictim, pev_rendermode) != kRenderNormal)
			{
				jbm_set_user_rendering(iVictim, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
				g_eUserRendering[iVictim][RENDER_STATUS] = false;
			}
			if(g_iUserTeam[iVictim] == 1)
			{
				if(g_iGlobalGame)
				{
					new szName[32]; get_user_name(iVictim, szName, charsmax(szName));
					if(g_iGlobalGame == 1) {
						set_hudmessage(255, 0, 0, -1.0,  0.7, 0, 0.0, 5.0, 0.2, 0.2, -1); 
						ShowSyncHudMsg(0, g_iSyncHudInfo, "%s был в роли: %L", szName, g_szMafiaRoleName[g_iUserRoleMafia[iVictim]]); 
					}
					if(g_iGlobalGame == 1 || g_iGlobalGame == 2) {
						if(task_exists(iVictim+TASK_SHOW_ROLE_GG)) 
							remove_task(iVictim+TASK_SHOW_ROLE_GG);
					}
				}
				if(isSetBit(g_iBitUserBurn, iVictim)) UTIL_RemoveBurn(iVictim);
				clearBit(g_iBitKatana, iVictim);
				clearBit(g_iBitMachete, iVictim);
				clearBit(g_iBitChainsaw, iVictim);
				clearBit(g_iBitPerc, iVictim);
				clearBit(g_iBitWeaponStatus, iVictim);
				if(task_exists(iVictim+TASK_REMOVE_SYRINGE)) remove_task(iVictim+TASK_REMOVE_SYRINGE);
				if(task_exists(iVictim+TASK_REMOVE_ANIMATE)) remove_task(iVictim+TASK_REMOVE_ANIMATE);
				clearBit(g_iBitFrostNade, iVictim);
				clearBit(g_iBitHingJump, iVictim);
				if(isSetBit(g_iBitInvisibleHat, iVictim))
				{
					clearBit(g_iBitInvisibleHat, iVictim);
					if(task_exists(iVictim+TASK_INVISIBLE_HAT)) remove_task(iVictim+TASK_INVISIBLE_HAT);
				}
				if(isSetBit(g_iBitUserWanted, iVictim)) jbm_sub_user_wanted(iVictim);
				if(isSetBit(g_iBitUserFree, iVictim)) jbm_sub_user_free(iVictim);
				clearBit(g_iBitUserVoice, iVictim);
				if(bValidKilled && g_iUserTeam[iKiller] == 2)
				{
					if(g_iBitKilledUsers[iKiller]) 
						setBit(g_iBitKilledUsers[iKiller], iVictim);
					else
					{
						g_iMenuTarget[iKiller] = iVictim;
						setBit(g_iBitKilledUsers[iKiller], iVictim);
						Open_KillReasonsMenu(iKiller, iVictim);
					}
				}
				if(g_iAlivePlayersNum[1] == 1 && !g_iGlobalGame)
				{
					if(g_bSoccerStatus) jbm_soccer_disable_all();
					if(g_bBoxingStatus) g_bBoxingStatus = false;
					if(g_iFriendlyFire) g_iFriendlyFire = false;
					if(!g_iGlobalGame)
					{
						for(new i = 1; i <= g_iMaxPlayers; i++)
						{
							if(isNotSetBit(g_iBitUserConnected, i))
								continue;
							
							if(g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserAlive, i)) continue;
							g_iLastPnId = i;
							Open_LastPrisonerMenu(i);
						}
						g_iDuelPrizeId = g_iLastPnId;
						g_iDuelTypeFair = 1;
						g_iDuelType = 1;
						g_iDuelTimeToAttack = 0;
						g_iDuelPrize = 0;
						set_lights("#OFF");
					}
				}
				if(g_iAlivePlayersNum[1] == 0)
				{
					if(g_iGlobalGame == 1) jbm_mafia_disable();
					if(g_iGlobalGame == 2) jbm_djixad_disable();
				}
			}
			if(g_iUserTeam[iVictim] == 2)
			{
				if(bValidKilled && iVictim != iKiller && g_iLevel[iKiller][1] < MAX_LEVEL && jbm_get_players_count(0, 2) >= g_iLevelCvars[PLAYERS_NEED])
				{
					if(jbm_is_user_chief(iVictim)) g_iExpName[iKiller] += 4;
					else g_iExpName[iKiller] += 2;
				}
				
				if(iVictim == g_iChiefId)
				{
					g_iChiefId = 0;
					g_iChiefStatus = 2;
					g_szChiefName = "";
					if(g_bSoccerGame) 
					remove_task(iVictim+TASK_SHOW_SOCCER_SCORE);
					
					if(g_iGlobalGame == 1) 
					{
						for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
						UTIL_SayText(0, "!y[!gMAFIA!y] Мафия окончена.");
						g_iGlobalGame = 0;
						g_iMafiaChat = false;
						g_iMafiaNight = false;
						for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
						{
							if(g_iMafiaNight) UTIL_ScreenFade(iPlayer, 512, 512, 0, 0, 0, 0, 255, 1);
							if(task_exists(TASK_DAY_VOTE_MAFIA))
							{
								remove_task(TASK_DAY_VOTE_MAFIA);
								show_menu(iPlayer, 0, "^n");
							}
							g_iVoteMafia[iPlayer] = 0;
							g_iUserRoleMafia[iPlayer] = 0;
							if(task_exists(iPlayer+TASK_SHOW_ROLE_GG)) remove_task(iPlayer+TASK_SHOW_ROLE_GG);
						}
					}
					
					if(g_iGlobalGame == 2)
					{
						for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
						DisableHamForward(g_iHamHookForwardsDjihad);
						UTIL_SayText(0, "!y[!gБитва за джихад!y] Джихад окончен.");
						g_iGlobalGame = 0;
						for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
						{
							g_iUserRoleDjixad[iPlayer] = 0;
							clearBit(g_iBitUserBury, iPlayer);
							if(task_exists(iPlayer+TASK_SHOW_ROLE_GG)) remove_task(iPlayer+TASK_SHOW_ROLE_GG);
						}
					}
					if(bValidKilled && g_iUserTeam[iKiller] == 1) 
						jbm_set_user_money(iKiller, g_iUserMoney[iKiller] + g_iAllCvars[KILLED_CHIEF_MONEY], 1);
				}
				else if(bValidKilled && g_iUserTeam[iKiller] == 1) 
					jbm_set_user_money(iKiller, g_iUserMoney[iKiller] + g_iAllCvars[KILLED_GUARD_MONEY], 1);
				
				if(isSetBit(g_iBitUserFrozen, iVictim))
				{
					clearBit(g_iBitUserFrozen, iVictim);
					if(task_exists(iVictim+TASK_FROSTNADE_DEFROST)) remove_task(iVictim+TASK_FROSTNADE_DEFROST);
				}
			}
			clearBit(g_iBitKokain, iVictim);
			g_fUserSpeed[iVictim] = 0.0;
			clearBit(g_iBitDoubleJump, iVictim);
			clearBit(g_iBitRandomGlow, iVictim);
			clearBit(g_iBitAutoBhop, iVictim);
			clearBit(g_iBitBoostBhop, iVictim);
			clearBit(g_iBitDoubleDamage, iVictim);
			clearBit(g_iBitGuardModel, iVictim);
			clearBit(g_iBitLatchkey, iVictim);
			// if(isSetBit(g_iBitUserHook, iVictim) && task_exists(iVictim+TASK_HOOK_THINK))
			//{
			remove_task(iVictim+TASK_HOOK_THINK);
			//	emit_sound(iVictim, CHAN_STATIC, g_szSounds[USE_HOOK], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			//}
		    if(isSetBit(g_iBitUserAnime, iVictim) || task_exists(iVictim+TASK_FLY_PLAYER))
			{
				remove_task(iVictim+TASK_FLY_PLAYER);
				emit_sound(iVictim, CHAN_STATIC, g_szSounds[DJUMP_SOUND], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
		}
		case DAYMODE_GAMES:
		{
			if(isSetBit(g_iBitUserVoteDayMode, iVictim))
			{
				clearBit(g_iBitUserVoteDayMode, iVictim);
				jbm_menu_unblock(iVictim);
				UTIL_ScreenFade(iVictim, 512, 512, 0, 0, 0, 0, 255, 1);
			}
		}
	}
}

public Ham_TraceAttack_Player(iVictim, iAttacker, Float:fDamage, Float:fDeriction[3], iTraceHandle, iBitDamage)
{
	if(IsValidPlayer(iAttacker))
	{
		new Float:fDamageOld = fDamage;
		if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE)
		{
			if(g_bSoccerStatus && isSetBit(g_iBitUserSoccer, iAttacker))
			{
				if(isSetBit(g_iBitUserSoccer, iVictim))
				{
					if(g_iSoccerUserTeam[iVictim] == g_iSoccerUserTeam[iAttacker]) return HAM_SUPERCEDE;
					SetHamParamFloat(3, 0.0);
					return HAM_IGNORED;
				}
				return HAM_SUPERCEDE;
			}
			
			if(g_iDuelStatus)
			{
				if(g_iDuelStatus == 1 && isSetBit(g_iBitUserDuel, iVictim)) return HAM_SUPERCEDE;
				if(g_iDuelStatus == 2)
				{
					if(isSetBit(g_iBitUserDuel, iVictim) || isSetBit(g_iBitUserDuel, iAttacker))
					{
						if(isSetBit(g_iBitUserDuel, iVictim) && isSetBit(g_iBitUserDuel, iAttacker)) return HAM_IGNORED;
						return HAM_SUPERCEDE;
					}
				}
			}
			
			if(isSetBit(g_iBitPerc, iAttacker) && !g_iGlobalGame && IsValidPlayer(iVictim) && isSetBit(g_iBitUserConnected, iVictim) && isNotSetBit(g_iBitUserBurn, iVictim) && get_user_weapon(iAttacker) == CSW_KNIFE && (cs_get_user_team(iAttacker) != cs_get_user_team(iVictim)))  
			{
				UTIL_SetBurn(iVictim, 3);
			}

			if(g_iUserTeam[iAttacker] == 1 && !g_iGlobalGame)
			{
				if(g_iUserTeam[iVictim] == 2)
				{
					if(isNotSetBit(g_iBitUserWanted, iAttacker))
					{
						if(!g_szWantedNames[0])
						{
							emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
							emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							jbm_set_user_money(iAttacker, g_iUserMoney[iAttacker] + g_iAllCvars[RIOT_START_MONEY], 1);
						}
						jbm_add_user_wanted(iAttacker);
						if(jbm_get_players_count(0, 2) >= g_iLevelCvars[PLAYERS_NEED]) g_iExpName[iAttacker]++;
					}
					if(g_iBitUserFrozen && isSetBit(g_iBitUserFrozen, iVictim)) return HAM_SUPERCEDE;
				}
				if(g_iBitWeaponStatus && isSetBit(g_iBitWeaponStatus, iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE)
				{
					if(isSetBit(g_iBitKatana, iAttacker)) fDamage = (fDamage * 1.2);
					if(isSetBit(g_iBitMachete, iAttacker)) fDamage = (fDamage * 1.3);
					if(isSetBit(g_iBitChainsaw, iAttacker)) fDamage = (fDamage * 1.7);
					if(isSetBit(g_iBitPerc, iAttacker)) fDamage = (fDamage * 1.9);
				}
			}
			if(!g_iGlobalGame)
			{
				if(g_iBitKokain && isSetBit(g_iBitKokain, iVictim)) fDamage = (fDamage * 0.5);
				if(g_iBitDoubleDamage && isSetBit(g_iBitDoubleDamage, iAttacker)) fDamage = (fDamage * 2.0);
			} 
			else if(iAttacker == g_iChiefId) fDamage = (fDamage * 2.0);
		}
	
		if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker] && g_bBoxingStatus != 0 && g_iUserTeam[iAttacker] == 1 && g_iGlobalGame) 
			{ if(g_iUserRoleDjixad[iAttacker] == 7) fDamage = (fDamage * 2.0); }
		else if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker] && g_bBoxingStatus != 0 && g_iFriendlyFire != 0 && !g_iGlobalGame)
			{ if(iBitDamage & (1<<24)) fDamage = (fDamage / 2.0); else fDamage = (fDamage / 0.35); }
		else if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker] && g_bBoxingStatus != 0 && g_iUserTeam[iAttacker] == 1 && !g_iGlobalGame)
			{ if(iBitDamage & (1<<24)) fDamage = (fDamage / 2.0); else fDamage = (fDamage / 0.35); }
		
		else if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker]) return HAM_SUPERCEDE;
		if(fDamageOld != fDamage) SetHamParamFloat(3, fDamage);
	}
	return HAM_IGNORED;
}

public Ham_TraceAttack_Button(iButton, iAttacker)
{
	if(
		g_iAllCvars[SHOOT_BUTTON] && 
		(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && 
		IsValidPlayer(iAttacker) && 
		pev_valid(iButton) && 
		g_iUserTeam[iAttacker] == 2 && 
		isSetBit(g_iBitUserAlive, iAttacker) && 
		isNotSetBit(g_iBitUserDuel, iAttacker)
	)
	{
		ExecuteHamB(Ham_Use, iButton, iAttacker, 0, 2, 1.0);
		entity_set_float(iButton, EV_FL_frame, 0.0);
	}
	return HAM_IGNORED;
}

public Ham_TakeDamage_Player(iVictim, iInflictor, iAttacker, Float:fDamage, iBitDamage) 
{ 
	if(isNotSetBit(g_iBitUserConnected, iVictim)) return HAM_SUPERCEDE; 
	if(isNotSetBit(g_iBitUserAlive, iVictim)) return HAM_SUPERCEDE; 

	if( IsValidPlayer(iAttacker) && g_iDayMode == DAYMODE_GAMES && g_iUserTeam[iVictim] == g_iUserTeam[iAttacker] && iBitDamage & (1<<24)) { return HAM_SUPERCEDE; }
	if(g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) 
	{ 
		if(g_iDuelStatus && isSetBit(g_iBitUserDuel, iVictim) && !IsValidPlayer(iAttacker)) { return HAM_SUPERCEDE; } 
		if(g_iDuelStatus && isSetBit(g_iBitUserDuel, iAttacker) && isNotSetBit(g_iBitUserDuel, iVictim) && IsValidPlayer(iAttacker)) { return HAM_SUPERCEDE; } 
		
		if(IsValidPlayer(iAttacker) && iBitDamage & (1<<24) && !g_iGlobalGame) 
		{ 
			if(isNotSetBit(g_iBitUserWanted, iAttacker) && g_iUserTeam[iAttacker] == 1 && g_iUserTeam[iVictim] == 2 && isNotSetBit(g_iBitUserDuel, iAttacker) && g_iAllCvars[WANTED_GRENADE_DAMAGE]) 
			{ 
				if(!g_szWantedNames[0]) 
				{ 
					emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM); 
					emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, 0, PITCH_NORM); 
					jbm_set_user_money(iAttacker, g_iUserMoney[iAttacker] + g_iAllCvars[RIOT_START_MONEY], 1); 
				} 
				jbm_add_user_wanted(iAttacker); 
				//if(jbm_get_players_count(0, 2) >= g_iLevelCvars[PLAYERS_NEED]) g_iExpName[iAttacker]++; 
			} 

			if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker] && g_iUserTeam[iVictim] == 1 && (g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && g_bBoxingStatus == 1) { SetHamParamFloat(4, fDamage * g_iDamageHe[g_iMoreDamageHE]); } 
			else if(g_iUserTeam[iVictim] == g_iUserTeam[iAttacker] || iVictim == iAttacker) { return HAM_SUPERCEDE; }
		} 
	} 
	return HAM_IGNORED; 
}

public Ham_KnifePrimaryAttack_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(g_bSoccerStatus && isSetBit(g_iBitUserSoccer, id))
	{
		set_pdata_float(id, m_flNextAttack, 1.0);
		return;
	}
	if(g_iBitWeaponStatus && isSetBit(g_iBitWeaponStatus, id) && isNotSetBit(g_iBitUserDuel, id))
	{
		if(isSetBit(g_iBitKatana, id)) set_pdata_float(id, m_flNextAttack, 0.6);
		if(isSetBit(g_iBitMachete, id)) set_pdata_float(id, m_flNextAttack, 0.7);
		if(isSetBit(g_iBitChainsaw, id)) set_pdata_float(id, m_flNextAttack, 0.8);
		if(isSetBit(g_iBitPerc, id)) set_pdata_float(id, m_flNextAttack, 0.5);
		return;
	}
	/*
	switch(g_iUserTeam[id])
	{
		case 1: set_pdata_float(id, m_flNextAttack, 0.5);
		case 2: set_pdata_float(id, m_flNextAttack, 0.5);
	}
	*/
}

public Ham_KnifeSecondaryAttack_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(g_bSoccerStatus && isSetBit(g_iBitUserSoccer, id))
	{
		set_pdata_float(id, m_flNextAttack, 1.0);
		return;
	}
	if(g_iBitWeaponStatus && isSetBit(g_iBitWeaponStatus, id) && isNotSetBit(g_iBitUserDuel, id))
	{
		if(isSetBit(g_iBitKatana, id)) 
		{
			set_pdata_float(id, m_flNextAttack, 1.2);
		}
		if(isSetBit(g_iBitMachete, id)) 
		{
			set_pdata_float(id, m_flNextAttack, 1.3);
		}
		if(isSetBit(g_iBitChainsaw, id)) 
		{
			set_pdata_float(id, m_flNextAttack, 1.4);
		}
	    if(isSetBit(g_iBitPerc, id)) 
		{
			set_pdata_float(id, m_flNextAttack, 1.2);
		}
		return;
	}
	/*
	switch(g_iUserTeam[id])
	{
		case 1: set_pdata_float(id, m_flNextAttack, 1.0);
		case 2: set_pdata_float(id, m_flNextAttack, 1.0);
	}
	*/
}

public Ham_KnifeDeploy_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(g_bSoccerStatus && isSetBit(g_iBitUserSoccer, id))
	{
		if(g_iSoccerBallOwner == id) jbm_soccer_hand_ball_model(id);
		else jbm_set_hand_model(id);
		return;
	}
	if(g_iBitWeaponStatus && isSetBit(g_iBitWeaponStatus, id) && isNotSetBit(g_iBitUserDuel, id))
	{
		if(isSetBit(g_iBitKatana, id)) jbm_set_katana_model(id);
		if(isSetBit(g_iBitMachete, id)) jbm_set_machete_model(id);
		if(isSetBit(g_iBitChainsaw, id)) jbm_set_chainsaw_model(id);
		if(isSetBit(g_iBitPerc, id)) jbm_set_perc_model(id);
		return;
	}
	jbm_default_knife_model(id);
}

public Ham_DoorUse(iEntity, iCaller, iActivator)
{
	if(iCaller != iActivator && pev(iEntity, pev_iuser1) == IUSER1_DOOR_KEY) return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public Ham_DoorBlocked(iBlocked, iBlocker)
{
	if(IsValidPlayer(iBlocker) && isSetBit(g_iBitUserAlive, iBlocker) && pev(iBlocked, pev_iuser1) == IUSER1_DOOR_KEY)
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
					velocity_by_aim(id, g_iSoccerBallSpeed, vecVelocity);
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
					velocity_by_aim(id, g_iSoccerBallSpeed / 2, vecVelocity);
				}
				set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
				set_pev(g_iSoccerBall, pev_velocity, vecVelocity);
				emit_sound(id, CHAN_AUTO, g_szSounds[KICK_BALL], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				CREATE_KILLPLAYERATTACHMENTS(id);
				jbm_set_hand_model(id);
				g_iSoccerBallOwner = 0;
				g_iSoccerKickOwner = id;
			}
		}
		else jbm_soccer_remove_ball();
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
		else jbm_soccer_remove_ball();
	}
}

public Ham_WallTouch_Post(iTouched, iToucher)
{
	if(g_iSoccerBall && iTouched == g_iSoccerBall)
	{
		if(pev_valid(iTouched))
		{
			if(g_bSoccerBallTouch && !g_iSoccerBallOwner && IsValidPlayer(iToucher) && isSetBit(g_iBitUserSoccer, iToucher))
			{
				if(g_iSoccerKickOwner == iToucher) return;
				g_iSoccerBallOwner = iToucher;
				set_pev(iTouched, pev_solid, SOLID_NOT);
				set_pev(iTouched, pev_velocity, Float:{0.0, 0.0, 0.0});
				emit_sound(iToucher, CHAN_AUTO, g_szSounds[GRAB_BALL], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				if(g_bSoccerBallTrail)
				{
					g_bSoccerBallTrail = false;
					CREATE_KILLBEAM(iTouched);
				}
				CREATE_PLAYERATTACHMENT(iToucher, _, g_pSpriteBall, 3000);
				jbm_soccer_hand_ball_model(iToucher);
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
						if((iDelayOld + 0.22) <= iDelay) emit_sound(iTouched, CHAN_AUTO, g_szSounds[BOUNCE_BALL], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
						iDelayOld = iDelay;
					}
				}
			}
		}
		else jbm_soccer_remove_ball();
	}
}

public ClientImpulse100(id)
{
	if(g_bSoccerStatus && g_iSoccerBall)
	{
		if(isSetBit(g_iBitUserSoccer, id))
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
					jbm_set_hand_model(g_iSoccerBallOwner);
					g_iSoccerBallOwner = id;
					emit_sound(id, CHAN_AUTO, g_szSounds[GRAB_BALL], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					CREATE_PLAYERATTACHMENT(id, _, g_pSpriteBall, 3000);
					jbm_soccer_hand_ball_model(id);
				}
			}
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

public Ham_PlayerTouch(pPlayer, iTouch)
{
	if(isNotSetBit(g_iBitUserConnected, pPlayer) || !pev_valid(iTouch)) 
		return HAM_IGNORED;
	
	if(pPlayer == iTouch) 
		return HAM_IGNORED;

	if(g_iGlobalGame == 2)
	{
		if(IsValidPlayer(iTouch) && g_iUserTeam[iTouch] == 1 && g_iUserTeam[pPlayer] == 1 && isSetBit(g_iBitUserConnected, iTouch) && isNotSetBit(g_iBitUserBurn, iTouch) && isSetBit(g_iBitUserBurn, pPlayer)) 
		{
			new szNamePlayer[32], szNameTouch[32];
			get_user_name(pPlayer, szNamePlayer, charsmax(szNamePlayer));
			get_user_name(iTouch, szNameTouch, charsmax(szNameTouch));
			emit_sound(iTouch, CHAN_ITEM, "scientist/scream07.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
			UTIL_SetBurn(iTouch, 0);
			UTIL_SayText(0, "!y[!gJBM!y] Игрок !t%s !yподжег игрока !g%s", szNamePlayer, szNameTouch);
		}
	}
	else if(g_iGlobalGame == 0)
	{
		if(IsValidPlayer(iTouch) && isSetBit(g_iBitUserConnected, iTouch) && isNotSetBit(g_iBitUserBurn, iTouch) && isSetBit(g_iBitUserBurn, pPlayer)) 
		{
			new szNamePlayer[32], szNameTouch[32];
			get_user_name(pPlayer, szNamePlayer, charsmax(szNamePlayer));
			get_user_name(iTouch, szNameTouch, charsmax(szNameTouch));
			emit_sound(iTouch, CHAN_ITEM, "scientist/scream07.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
			UTIL_SetBurn(iTouch, 2);
		}
	}
	return HAM_IGNORED;
}

public Ham_ItemDeploy_Post(iEntity)
{
	if(g_bSoccerStatus)
	{
		new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
		if(isSetBit(g_iBitUserSoccer, id)) engclient_cmd(id, "weapon_knife");
	}
}

public Ham_ItemPrimaryAttack_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	
	if(g_iGlobalGame == 2 &&  (g_iUserRoleDjixad[id] == 3 || g_iUserRoleDjixad[id] == 6 || g_iUserRoleDjixad[id] == 12))
	{
		new iMaxClip;
		switch(get_pdata_int(iEntity, 43, 4))
		{
			case CSW_P228: 			iMaxClip = 13;
			case CSW_SCOUT: 		iMaxClip = 10;
			case CSW_HEGRENADE: 	iMaxClip = 0;
			case CSW_XM1014: 		iMaxClip = 7;
			case CSW_C4: 			iMaxClip = 0;
			case CSW_MAC10: 		iMaxClip = 30;
			case CSW_AUG: 			iMaxClip = 30;
			case CSW_SMOKEGRENADE:	iMaxClip = 0;
			case CSW_ELITE: 		iMaxClip = 30;
			case CSW_FIVESEVEN: 	iMaxClip = 20;
			case CSW_UMP45: 		iMaxClip = 25;
			case CSW_SG550: 		iMaxClip = 30;
			case CSW_GALI: 			iMaxClip = 35;
			case CSW_FAMAS: 		iMaxClip = 25;
			case CSW_USP: 			iMaxClip = 12;
			case CSW_GLOCK18: 		iMaxClip = 20;
			case CSW_AWP: 			iMaxClip = 10;
			case CSW_MP5NAVY: 		iMaxClip = 30;
			case CSW_M249: 			iMaxClip = 100;
			case CSW_M3: 			iMaxClip = 8;
			case CSW_M4A1: 			iMaxClip = 30;
			case CSW_TMP: 			iMaxClip = 30;
			case CSW_G3SG1: 		iMaxClip = 20;
			case CSW_FLASHBANG: 	iMaxClip = 0;
			case CSW_DEAGLE: 		iMaxClip = 7;
			case CSW_SG552: 		iMaxClip = 30;
			case CSW_AK47: 			iMaxClip = 30;
			case CSW_P90: 			iMaxClip = 50;
		}
		
		if(get_pdata_int(iEntity, m_iClip, 4) != iMaxClip)
		{
			set_pdata_int(iEntity, m_iClip, iMaxClip, 4);
		}
	}
	
	if(g_iDuelStatus && g_iDuelTypeFair)
	{
		if(isSetBit(g_iBitUserDuel, id))
		{
			switch(g_iDuelType)
			{
				case 1:
				{
					set_pdata_float(id, m_flNextAttack, float(g_iTimeAttack[g_iDuelTimeToAttack] + 1));
					if(task_exists(id+TASK_DUEL_TIMER_ATTACK)) remove_task(id+TASK_DUEL_TIMER_ATTACK);
					id = g_iDuelUsersId[0] != id ? g_iDuelUsersId[0] : g_iDuelUsersId[1];
					set_pdata_float(id, m_flNextAttack, 0.0);
					set_task(1.0, "jbm_duel_timer_attack", id+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = g_iTimeAttack[g_iDuelTimeToAttack] + 1);
				}
				case 2, 5:
				{
					set_pdata_float(id, m_flNextAttack, float(g_iTimeAttack[g_iDuelTimeToAttack] + 1));
					if(task_exists(id+TASK_DUEL_TIMER_ATTACK)) remove_task(id+TASK_DUEL_TIMER_ATTACK);
					id = g_iDuelUsersId[0] != id ? g_iDuelUsersId[0] : g_iDuelUsersId[1];
					set_pdata_float(id, m_flNextAttack, 0.0);
					set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + float(g_iTimeAttack[g_iDuelTimeToAttack] + 1), linux_diff_weapon);
					set_task(1.0, "jbm_duel_timer_attack", id+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = g_iTimeAttack[g_iDuelTimeToAttack] + 1);
				}
			}
		}
	}
}

public Ham_PlayerJump(id)
{
	static iBitUserJump;
	if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isNotSetBit(g_iBitUserDuel, id) && (isSetBit(g_iBitHingJump, id) || isSetBit(g_iBitDoubleJump, id) || isSetBit(g_iBitAutoBhop, id)))
	{
		if(~pev(id, pev_oldbuttons) & IN_JUMP)
		{
			new iFlags = pev(id, pev_flags);
			if(iFlags & (FL_ONGROUND|FL_CONVEYOR))
			{
				if(isSetBit(g_iBitHingJump, id))
				{
					new Float:vecVelocity[3];
					pev(id, pev_velocity, vecVelocity);
					vecVelocity[2] = 350.0;
					set_pev(id, pev_velocity, vecVelocity);
				}
				setBit(iBitUserJump, id);
				return;
			}
			if(isSetBit(iBitUserJump, id) && isSetBit(g_iBitDoubleJump, id) && ~iFlags & (FL_ONGROUND|FL_CONVEYOR|FL_INWATER))
			{
				new Float:vecVelocity[3];
				pev(id, pev_velocity, vecVelocity);
				vecVelocity[2] = 250.0;
				set_pev(id, pev_velocity, vecVelocity);
				emit_sound(id, CHAN_AUTO, g_szSounds[DJUMP_SOUND], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				clearBit(iBitUserJump, id);
			}
		}
		else if(isSetBit(g_iBitAutoBhop, id) && pev(id, pev_flags) & (FL_ONGROUND|FL_CONVEYOR))
		{
			new Float:vecVelocity[3];
			pev(id, pev_velocity, vecVelocity);
			if(isSetBit(g_iBitBoostBhop, id))
			{
				vecVelocity[0] *= 1.20;
				vecVelocity[1] *= 1.20;
			}
			vecVelocity[2] = 250.0;
			set_pev(id, pev_velocity, vecVelocity);
			set_pev(id, pev_gaitsequence, 6);
		}
	}
}

public Ham_PlayerResetMaxSpeed_Post(id)
{
	if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && isNotSetBit(g_iBitUserDuel, id) && g_fUserSpeed[id])
		set_pev(id, pev_maxspeed, g_fUserSpeed[id]);
}

public Ham_GrenadeTouch_Post(iTouched)
{
	if((g_iDayMode == DAYMODE_STANDART || g_iDayMode == DAYMODE_FREE) && pev(iTouched, pev_iuser1) == IUSER1_FROSTNADE_KEY)
	{
		new Float:vecOrigin[3], id;
		pev(iTouched, pev_origin, vecOrigin);
		CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 4, 60, _, 0, 110, 255, 255, _);
		while((id = engfunc(EngFunc_FindEntityInSphere, id, vecOrigin, 150.0)))
		{
			if(IsValidPlayer(id) && g_iUserTeam[id] == 2)
			{
				set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
				set_pdata_float(id, m_flNextAttack, 6.0, linux_diff_player);
				jbm_set_user_rendering(id, kRenderFxGlowShell, 0, 110, 255, kRenderNormal, 0);
				emit_sound(iTouched, CHAN_AUTO, g_szSounds[FREEZE_PLAYER], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				setBit(g_iBitUserFrozen, id);
				if(task_exists(id+TASK_FROSTNADE_DEFROST)) change_task(id+TASK_FROSTNADE_DEFROST, 6.0);
				else set_task(6.0, "jbm_user_defrost", id+TASK_FROSTNADE_DEFROST);
			}
		}
		emit_sound(iTouched, CHAN_AUTO, g_szSounds[GRENADE_FROST_EXPLOSION], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		engfunc(EngFunc_RemoveEntity, iTouched);
	}
}

public HamHook_EntityBlock(iEntity, id)
{
	if(g_bRoundEnd || g_iDuelStatus || isSetBit(g_iBitUserDuel, id) || (g_iGlobalGame && id != g_iChiefId)) 
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

/* < 'hamsandwich' события < *///}

/* > Режимы игры > *///{
INIT_GAMEMODE()
{
	if(!g_aDataDayMode) { g_aDataDayMode = ArrayCreate(DATA_DAY_MODE); }
	g_iHookDayMode[DAY_MODE_START] = CreateMultiForward("jbm_day_mode_start", ET_IGNORE, FP_CELL, FP_CELL);
	g_iHookDayMode[DAY_MODE_END] = CreateMultiForward("jbm_day_mode_ended", ET_IGNORE, FP_CELL, FP_CELL);
}

public jbm_day_mode_start(iDayMode, iAdmin)
{
	new aDataDayMode[DATA_DAY_MODE];
	ArrayGetArray(g_aDataDayMode, iDayMode, aDataDayMode);
	formatex(g_szDayMode, charsmax(g_szDayMode), aDataDayMode[LANG_MODE]);
	if(aDataDayMode[MODE_TIMER])
	{
		g_iDayModeTimer = aDataDayMode[MODE_TIMER] + 1;
		if(task_exists(TASK_DAY_MODE_TIMER)) remove_task(TASK_DAY_MODE_TIMER);
		set_task(1.0, "jbm_day_mode_timer", TASK_DAY_MODE_TIMER, _, _, "a", g_iDayModeTimer);
	}
	if(iAdmin) jbm_restore_game();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) jbm_hide_user_costumes(iPlayer);
	jbm_open_doors();
}

jbm_restore_game()
{
	g_bBoxingStatus = 0;
	g_iFriendlyFire = 0;
	g_iMoreDamageHE = 0;
	if(g_iDayMode == DAYMODE_FREE) jbm_free_day_ended();
	else
	{
		g_iBitUserFree = 0;
		g_iFreeLang = 0;
		g_iFreeCount = 0;
	}
	g_iDayMode = DAYMODE_GAMES;
	if(task_exists(TASK_CHIEF_CHOICE_TIME)) remove_task(TASK_CHIEF_CHOICE_TIME);
	g_iChiefId = 0;
	g_szChiefName = "";
	g_iChiefStatus = 0;
	g_iBitUserWanted = 0;
	g_szWantedNames = "";
	g_iWantedCount = 0;
	g_iBitChainsaw = 0;
	g_iBitPerc = 0;
	g_iBitKatana = 0;
	g_iBitMachete = 0;
	g_iBitKokain = 0;
	g_iBitFrostNade = 0;
	g_iBitHingJump = 0;
	g_iBitDoubleJump = 0;
	g_iBitAutoBhop = 0;
	g_iBitDoubleDamage = 0;
	g_iBitUserVoice = 0;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isNotSetBit(g_iBitUserAlive, iPlayer)) continue;
		g_iBitKilledUsers[iPlayer] = 0;
		show_menu(iPlayer, 0, "^n");
		if(g_iBitWeaponStatus && isSetBit(g_iBitWeaponStatus, iPlayer))
		{
			clearBit(g_iBitWeaponStatus, iPlayer);
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
		if(task_exists(iPlayer+TASK_REMOVE_ANIMATE))
		{
			remove_task(iPlayer+TASK_REMOVE_ANIMATE);
			if(get_user_weapon(iPlayer))
			{
				new iActiveItem = get_pdata_cbase(iPlayer, m_pActiveItem, linux_diff_player);
				if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
			}
		}
		if(pev(iPlayer, pev_renderfx) != kRenderFxNone || pev(iPlayer, pev_rendermode) != kRenderNormal)
		{
			jbm_set_user_rendering(iPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
			g_eUserRendering[iPlayer][RENDER_STATUS] = false;
		}
		if(g_iBitUserFrozen && isSetBit(g_iBitUserFrozen, iPlayer))
		{
			clearBit(g_iBitUserFrozen, iPlayer);
			if(task_exists(iPlayer+TASK_FROSTNADE_DEFROST)) remove_task(iPlayer+TASK_FROSTNADE_DEFROST);
			set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) & ~FL_FROZEN);
			set_pdata_float(iPlayer, m_flNextAttack, 0.0, linux_diff_player);
			emit_sound(iPlayer, CHAN_AUTO, g_szSounds[DEFROST_PLAYER], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			new Float:vecOrigin[3]; pev(iPlayer, pev_origin, vecOrigin);
			CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
		}
		if(g_fUserSpeed[iPlayer])
		{
			g_fUserSpeed[iPlayer] = 0.0;
			ExecuteHamB(Ham_Player_ResetMaxSpeed, iPlayer);
		}
		if(g_iBitRandomGlow && isSetBit(g_iBitRandomGlow, iPlayer)) clearBit(g_iBitRandomGlow, iPlayer);
		if(g_iBitInvisibleHat && isSetBit(g_iBitInvisibleHat, iPlayer))
		{
			clearBit(g_iBitInvisibleHat, iPlayer);
			if(task_exists(iPlayer+TASK_INVISIBLE_HAT)) remove_task(iPlayer+TASK_INVISIBLE_HAT);
		}
		if(isSetBit(g_iBitUserHook, iPlayer) && task_exists(iPlayer+TASK_HOOK_THINK))
		{
			remove_task(iPlayer+TASK_HOOK_THINK);
			emit_sound(iPlayer, CHAN_STATIC, g_szSounds[USE_HOOK], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
		}
	}
	if(g_bSoccerStatus) jbm_soccer_disable_all();
}

public jbm_day_mode_timer()
{
	if(--g_iDayModeTimer) formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "[%s]", UTIL_FixTime(g_iDayModeTimer));
	else
	{
		g_szDayModeTimer = "";
		ExecuteForward(g_iHookDayMode[DAY_MODE_END], g_iReturnDayMode, g_iGameMode, 0);
		g_iGameMode = -1;
	}
}

public jbm_vote_day_mode_start()
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
		if(isNotSetBit(g_iBitUserAlive, iPlayer)) continue;
		setBit(g_iBitUserVoteDayMode, iPlayer);
		g_iBitKilledUsers[iPlayer] = 0;
		//g_iMenuPosition[iPlayer] = 0;
		//jbm_menu_block(iPlayer);
		set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) | FL_FROZEN);
		set_pdata_float(iPlayer, m_flNextAttack, float(g_iDayModeVoteTime), linux_diff_player);
		UTIL_ScreenFade(iPlayer, 0, 0, 4, 0, 0, 0, 255);
	}
	set_task(1.0, "jbm_vote_day_mode_timer", TASK_VOTE_DAY_MODE_TIMER, _, _, "a", g_iDayModeVoteTime);
}

public jbm_vote_day_mode_timer()
{
	if(!--g_iDayModeVoteTime) jbm_vote_day_mode_ended();
	switch(g_iDayModeVoteTime)
	{
		case 0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30:
		{
			set_hudmessage(255, 255, 255, -1.0, 0.4, 0, 0.0, 1.0, 0.1, 0.2); 
			show_hudmessage(0, "Загрузка игры...");
		}
		case 1, 4, 7, 10, 13, 16, 19, 22, 25, 28:
		{
			set_hudmessage(255, 255, 255, -1.0, 0.4, 0, 0.0, 1.0, 0.1, 0.2); 
			show_hudmessage(0, "Загрузка игры..");
		}
		case 2, 5, 8, 11, 14, 17, 20, 23, 26, 29:
		{
			set_hudmessage(255, 255, 255, -1.0, 0.4, 0, 0.0, 1.0, 0.1, 0.2); 
			show_hudmessage(0, "Загрузка игры.");
		}
		default:
		{
			set_hudmessage(255, 255, 255, -1.0, 0.4, 0, 0.0, 1.0, 0.1, 0.2); 
			show_hudmessage(0, "Приятной игры!");
		}
	}
}

public jbm_vote_day_mode_ended()
{
	new aDataDayMode[DATA_DAY_MODE]; g_iGameMode = random_num(0, g_iDayModeListSize - 1);
#if defined REGAME_GAMEMODE
	if(g_iLastDayMode == g_iGameMode && g_iDayModeListSize > 1) 
	{
		jbm_vote_day_mode_ended(); 
		return PLUGIN_HANDLED;
	}
#endif
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isNotSetBit(g_iBitUserVoteDayMode, iPlayer)) continue;
		clearBit(g_iBitUserVoteDayMode, iPlayer);
		jbm_menu_unblock(iPlayer);
		set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) & ~FL_FROZEN);
		set_pdata_float(iPlayer, m_flNextAttack, 0.0, linux_diff_player);
		UTIL_ScreenFade(iPlayer, 512, 512, 0, 0, 0, 0, 255, 1);
	}
#if defined REGAME_GAMEMODE
	g_iLastDayMode = g_iGameMode;
#endif
	ArrayGetArray(g_aDataDayMode, g_iGameMode, aDataDayMode);
	ExecuteForward(g_iHookDayMode[DAY_MODE_START], g_iReturnDayMode, g_iGameMode, 0);
	return PLUGIN_HANDLED;
}
/* < Режимы игры < *///}

/* > Остальной хлам > *///{

public jbm_main_informer(pPlayer)
{
	pPlayer -= TASK_SHOW_INFORMER;
	{
		if(!g_bRestartGame)
		{
			if(g_iExpName[pPlayer] >= g_szExp[g_iLevel[pPlayer][1] + 1])
			{
				g_iLevel[pPlayer][1]++;
				g_iExpName[pPlayer] = 0;
				new szName[32];
				get_user_name(pPlayer, szName, charsmax(szName)); 
				UTIL_SayText(pPlayer, "!y[!gJBM!y]!y %L", pPlayer, "JBM_ID_CHAT_NEW_RANK_NAME", szName, pPlayer, g_szRankName[g_iLevel[pPlayer][1]]);
			}			
			new szBuffer[128];
			
			if(g_iUserTeam[pPlayer] == 2)
				formatex(szBuffer, charsmax(szBuffer), "Погоняло: %L + %d HP | Очки: %d/%d", pPlayer, g_szRankName[g_iLevel[pPlayer][1]], g_iLevel[pPlayer][1] * g_iLevelCvars[HEALTH_BONUS], g_iExpName[pPlayer], g_szExp[g_iLevel[pPlayer][1] + 1]);
			else
				formatex(szBuffer, charsmax(szBuffer), "Погоняло: %L | Очки: %d/%d", pPlayer, g_szRankName[g_iLevel[pPlayer][1]], g_iExpName[pPlayer], g_szExp[g_iLevel[pPlayer][1] + 1]);
			
			new szText[2][256];
			
			if(g_iFreeLang && g_iFreeCount) { format(szText[0], charsmax(szText[]), "%s", jbm_get_free_day()); }
			else { format(szText[0], charsmax(szText[]), ""); }
			
			if(g_iWantedCount) { format(szText[1], charsmax(szText[]), "%L%s", LANG_PLAYER, "JBM_HUD_HAS_WANTED", g_iWantedCount, g_szWantedNames); }
			else { format(szText[1], charsmax(szText[]), ""); }
			
			set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], 0.7, 0.20, 0, 0.0, 0.8, 0.2, 0.2, -1);
			ShowSyncHudMsg
			(
				/*
				//pPlayer, g_iSyncMainInformer, "%L^n%L %L^n%L^n%L^n%L^n^n%L | %L^n%L^n%L%L%s%s", 
				pPlayer, g_iSyncMainInformer, "%L^n%L %L^n%L^n%L^n%L^n^n%L | %L^n%L%s%s", 
				pPlayer, "JBM_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayModeTimer, 
				pPlayer, "JBM_HUD_DAY", g_iDay, pPlayer, g_szDaysWeek[g_iDayWeek], 
				pPlayer, "JBM_HUD_CHIEF", pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName,
				pPlayer, "JBM_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
				pPlayer, "JBM_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2],
				
				pPlayer, "JBM_HUD_RANK_LEVEL", g_iLevel[pPlayer][0], pPlayer, "JBM_HUD_RANK_EXP_TIME", g_iExpTime[pPlayer], g_iLevelCvars[EXP_NEED],
				//pPlayer, "JBM_HUD_RANK_NAME", pPlayer, g_szRankName[g_iLevel[pPlayer][1]], pPlayer, "JBM_HUD_RANK_EXP_KILLS", g_iExpName[pPlayer], g_szExp[g_iLevel[pPlayer][1] + 1],

				pPlayer, g_szMiniGame[g_bBoxingStatus],

				szText[0],
				szText[1]
				*/
				pPlayer, g_iSyncMainInformer, "%s^n^n%L | %L^n^n%L^n%L %L^n%L^n%L^n%L^n%L%s%s", 
				szBuffer,
				pPlayer, "JBM_HUD_RANK_LEVEL", g_iLevel[pPlayer][0], pPlayer, "JBM_HUD_RANK_EXP_TIME", g_iExpTime[pPlayer], g_iLevelCvars[EXP_NEED],
				pPlayer, "JBM_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayModeTimer, 
				pPlayer, "JBM_HUD_DAY", g_iDay, pPlayer, g_szDaysWeek[g_iDayWeek], 
				pPlayer, "JBM_HUD_CHIEF", pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName,
				pPlayer, "JBM_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
				pPlayer, "JBM_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2],

				pPlayer, g_szMiniGame[g_bBoxingStatus],

				szText[0],
				szText[1]

			);
		}
		else
		{
			set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], 0.7, 0.20, 0, 0.0, 0.8, 0.2, 0.2, -1);
			ShowSyncHudMsg
			(
				pPlayer, g_iSyncMainInformer, "%L^n%L %L^n%s", 
				pPlayer, "JBM_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayModeTimer, 
				pPlayer, "JBM_HUD_DAY", g_iDay, pPlayer, g_szDaysWeek[g_iDayWeek], 
				g_szRestartText
			);
		}
	}
}

public jbm_main_dead_informer(pPlayer)
{
	pPlayer -= TASK_SHOW_DEAD_INFORMER;
	{
		new pTarget = pev(pPlayer, pev_iuser2), szName[32];
		if(isNotSetBit(g_iBitUserAlive, pTarget) || !IsValidPlayer(pTarget)) return;
		get_user_name(pTarget, szName, charsmax(szName));
		set_hudmessage(100, 100, 100, -1.0, 0.72, 0, 0.0, 0.8, 0.2, 0.2, -1);
		ShowSyncHudMsg
		(
			pPlayer, g_iSyncMainDeadInformer, "%L", pPlayer, "JBM_ID_HUD_STATUS_TEXT_DEAD",
			szName, get_user_health(pTarget), get_user_armor(pTarget), g_iUserMoney[pTarget], g_iLevel[pTarget][0], g_iExpTime[pTarget], g_iLevelCvars[EXP_NEED],pPlayer, g_szRankName[g_iLevel[pTarget][1]]
		);
	}
}

jbm_set_user_discount(pPlayer)
{
	new iHour; time(iHour);
	if(iHour >= 23 || iHour <= 8) g_iUserDiscount[pPlayer] = 10;
	else g_iUserDiscount[pPlayer] = 0;
	if(isSetBit(g_iBitUserBoss, pPlayer)) g_iUserDiscount[pPlayer] = g_iAllCvars[BOSS_DISCOUNT_SHOP];
	else if(isSetBit(g_iBitUserVip, pPlayer)) g_iUserDiscount[pPlayer] = g_iAllCvars[VIP_DISCOUNT_SHOP];
}

jbm_get_price_discount(pPlayer, iCost)
{
	if(!g_iUserDiscount[pPlayer]) return iCost;
	iCost -= floatround(iCost / 100.0 * g_iUserDiscount[pPlayer]);
	return iCost;
}

public jbm_remove_invisible_hat(pPlayer)
{
	pPlayer -= TASK_INVISIBLE_HAT;
	if(isNotSetBit(g_iBitInvisibleHat, pPlayer)) return;
	UTIL_SayText(pPlayer, "!y[!gJBM!y]!y %L", pPlayer, "JBM_MENU_ID_INVISIBLE_HAT_REMOVE");
	if(g_eUserRendering[pPlayer][RENDER_STATUS]) jbm_set_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	else jbm_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	if(g_eUserCostumes[pPlayer][HIDE]) jbm_set_user_costumes(pPlayer, g_eUserCostumes[pPlayer][COSTUMES]);
}

public jbm_user_defrost(pPlayer)
{
	pPlayer -= TASK_FROSTNADE_DEFROST;
	if(isNotSetBit(g_iBitUserFrozen, pPlayer)) return;
	clearBit(g_iBitUserFrozen, pPlayer);
	set_pev(pPlayer, pev_flags, pev(pPlayer, pev_flags) & ~FL_FROZEN);
	set_pdata_float(pPlayer, m_flNextAttack, 0.0, linux_diff_player);
	if(g_eUserRendering[pPlayer][RENDER_STATUS]) jbm_set_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	else jbm_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	emit_sound(pPlayer, CHAN_AUTO, g_szSounds[DEFROST_PLAYER], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	new Float:vecOrigin[3]; pev(pPlayer, pev_origin, vecOrigin);
	CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
}

jbm_default_player_model(pPlayer)
{
	#if defined SKINS_DATA
	switch(g_iUserTeam[pPlayer])
	{
		case 1: 
		{
			if(isSetBit(g_iBitUserCostumModel, pPlayer)) jbm_set_user_model(pPlayer, g_iPlayerSkin[pPlayer]);
			else jbm_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
			
			set_pev(pPlayer, pev_skin, random_num(0, g_iPlayersParams[COUNT_SKIN]));
		}
		case 2: jbm_set_user_model(pPlayer, g_szPlayerModel[GUARD]);
	}
	#else
	switch(g_iUserTeam[pPlayer])
	{
		case 1:
		{
			jbm_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
			set_pev(pPlayer, pev_skin, random_num(0, g_iPlayersParams[COUNT_SKIN]));
		}
		case 2: jbm_set_user_model(pPlayer, g_szPlayerModel[GUARD]);
	}
	#endif
}

jbm_default_knife_model(pPlayer)
{
	switch(g_iUserTeam[pPlayer])
	{
		case 1: jbm_set_hand_model(pPlayer);
		case 2: jbm_set_baton_model(pPlayer);
	}
}

jbm_set_hand_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szPlayerHand[PRISONER_V]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szPlayerHand[PRISONER_P]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	//set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbm_set_baton_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szPlayerHand[GUARD_V]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szPlayerHand[GUARD_P]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	//set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbm_set_machete_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_MACHETE]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_MACHETE]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

jbm_set_katana_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_KATANA]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_KATANA]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbm_set_chainsaw_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_CHAINSAW]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_CHAINSAW]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

jbm_set_perc_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_PERC]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_PERC]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

jbm_set_syringe_model(pPlayer)
{
	static iszViewModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_SYRINGE]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	UTIL_WeaponAnimation(pPlayer, 1);
	set_pdata_float(pPlayer, m_flNextAttack, 3.0);
}

public jbm_set_syringe_health(pPlayer)
{
	pPlayer -= TASK_REMOVE_SYRINGE;
	set_pev(pPlayer, pev_health, 200.0);
}

public jbm_remove_syringe_model(pPlayer)
{
	pPlayer -= TASK_REMOVE_SYRINGE;
	new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem);
	if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
}

public jbm_remove_animate(pPlayer)
{
	pPlayer -= TASK_REMOVE_ANIMATE;
	new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem);
	if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
}

public jbm_hook_think(pPlayer)
{
	pPlayer -= TASK_HOOK_THINK;
	new Float:vecOrigin[3];
	pev(pPlayer, pev_origin, vecOrigin);
	new Float:vecVelocity[3];
	vecVelocity[0] = (g_vecHookOrigin[pPlayer][0] - vecOrigin[0]) * 3.0;
	vecVelocity[1] = (g_vecHookOrigin[pPlayer][1] - vecOrigin[1]) * 3.0;
	vecVelocity[2] = (g_vecHookOrigin[pPlayer][2] - vecOrigin[2]) * 3.0;
	
	new Float:flY = vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2];
	new Float:flX = (5 * SPEED_HOOK) / floatsqroot(flY);
	
	vecVelocity[0] *= flX;
	vecVelocity[1] *= flX;
	vecVelocity[2] *= flX;
	
	set_pev(pPlayer, pev_velocity, vecVelocity);
	CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_pSpriteLgtning, 0, 1, 1, 50, 50, random(255), random(255), random(255), 180, _);
}
/* < Остальной хлам < *///}

/* > Дуэль > *///{
jbm_duel_start_ready(pPlayer, pTarget)
{
	jbm_open_doors();
	g_iDuelStatus = 1;
	fm_strip_user_weapons(pPlayer, 1);
	fm_strip_user_weapons(pTarget, 1);
	g_iDuelUsersId[0] = pPlayer;
	jbm_hide_user_costumes(pPlayer);
	jbm_hide_user_costumes(pTarget);
	setBit(g_iBitUserDuel, pPlayer);
	setBit(g_iBitUserDuel, pTarget);
	ExecuteHamB(Ham_Player_ResetMaxSpeed, pPlayer);
	ExecuteHamB(Ham_Player_ResetMaxSpeed, pTarget);
	set_pev(pPlayer, pev_gravity, 1.0);
	set_pev(pTarget, pev_gravity, 1.0);
	if(get_user_godmode(pTarget)) set_user_godmode(pTarget, 0);
	get_user_name(pPlayer, g_iDuelNames[0], charsmax(g_iDuelNames[]));
	get_user_name(pTarget, g_iDuelNames[1], charsmax(g_iDuelNames[]));
	for(new i; i < charsmax(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
	if(g_iAlivePlayersNum[2] == 1)
	{
		set_task(1.0, "jbm_duel_count_down", TASK_DUEL_COUNT_DOWN, _, _, "a", g_iDuelCountDown = 20 + 1);
		client_cmd(0, "mp3 play ^"%s^"", g_szSounds[DUEL_READY]);
		g_iCountMoney[0] = 0;
		g_iCountMoney[1] = 0;
		for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
		{
			if(isNotSetBit(g_iBitUserConnected, iPlayer) || isSetBit(g_iBitUserAlive, iPlayer)) continue;
			set_task(1.0, "jbm_show_money_bet", iPlayer+TASK_SHOW_MONEY_BET, _, _, "b");
		}
	}
	else set_task(1.0, "jbm_duel_count_down", TASK_DUEL_COUNT_DOWN, _, _, "a", g_iDuelCountDown = 3 + 1);
	jbm_set_user_rendering(pPlayer, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0);
	jbm_get_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	g_eUserRendering[pPlayer][RENDER_STATUS] = true;
	jbm_set_user_rendering(pTarget, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0);
	jbm_get_user_rendering(pTarget, g_eUserRendering[pTarget][RENDER_FX], g_eUserRendering[pTarget][RENDER_RED], g_eUserRendering[pTarget][RENDER_GREEN], g_eUserRendering[pTarget][RENDER_BLUE], g_eUserRendering[pTarget][RENDER_MODE], g_eUserRendering[pTarget][RENDER_AMT]);
	g_eUserRendering[pTarget][RENDER_STATUS] = true;
	CREATE_PLAYERATTACHMENT(pPlayer, _, g_pSpriteDuelRed, 3000);
	CREATE_PLAYERATTACHMENT(pTarget, _, g_pSpriteDuelBlue, 3000);
	set_task(1.0, "jbm_duel_bream_cylinder", TASK_DUEL_BEAMCYLINDER, _, _, "b");
	g_bGlobalGame = false;
}

public jbm_duel_count_down()
{
	if(--g_iDuelCountDown)
	{
		set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.3, 0, 0.0, 0.9, 0.1, 0.1, -1);
		//ShowSyncHudMsg(0, g_iSyncDuelInformer, "%L", LANG_PLAYER, "JBM_ALL_HUD_DUEL_START_READY", LANG_PLAYER, g_szDuelLang[g_iDuelType], g_iDuelNames[0], g_iDuelNames[1], g_iDuelCountDown);
		//ShowSyncHudMsg(0, g_iSyncDuelInformer, "Дуэль началась, до начала: %d!^nОружие: %L^nТип: %s^nПриз: %L^n%s VS %s", g_iDuelCountDown, LANG_PLAYER, g_szDuelLang[g_iDuelType], g_iDuelTypeFair ? "Честная" : "Не честная", g_iDuelNames[0], g_iDuelNames[1], LANG_PLAYER, g_szDuelPrizeLang[g_iDuelPrize]);
		if(g_iDuelPrize) ShowSyncHudMsg(0, g_iSyncDuelInformer, "%s VS %s^nДо начала дуэли: %d!^n%L^nТип: %s^nПриз: %L", g_iDuelNames[0], g_iDuelNames[1], g_iDuelCountDown, LANG_PLAYER, g_szDuelLang[g_iDuelType], g_iDuelTypeFair ? "Честная" : "Не честная", LANG_PLAYER, g_szDuelPrizeLang[g_iDuelPrize]);
		else ShowSyncHudMsg(0, g_iSyncDuelInformer, "%s VS %s^nДо начала дуэли: %d!^n%L^nТип: %s", g_iDuelNames[0], g_iDuelNames[1], g_iDuelCountDown, LANG_PLAYER, g_szDuelLang[g_iDuelType], g_iDuelTypeFair ? "Честная" : "Не честная");
		if(g_iAlivePlayersNum[2] == 1)
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{ 
				if(isSetBit(g_iBitUserDuel, i) || g_iUserMoney[i] < 500 || g_iUserTeam[i] != 1 || isSetBit(g_iBitUserBet, i)) continue;
				Open_BetMenu(i);
			}
		}
	}
	else
	{
		if(g_iAlivePlayersNum[2] == 1)
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(isSetBit(g_iBitUserDuel, i) || g_iUserTeam[i] != 1 || isNotSetBit(g_iBitUserConnected, i)) continue;
				jbm_menu_unblock(i);
				show_menu(i, 0, "^n");
			}
		}
		jbm_duel_start();
	}
}

public jbm_show_money_bet(pPlayer)
{
	pPlayer -= TASK_SHOW_MONEY_BET;
	new szName[2][32];
	get_user_name(g_iDuelUsersId[0], szName[0], charsmax(szName[]));
	get_user_name(g_iDuelUsersId[1], szName[1], charsmax(szName[]));
	
	set_hudmessage(0, 255, 0, -1.0, 0.1, 0, 0.1, 1.0, 0.1, 0.2); 
	show_hudmessage(pPlayer, "%s - %d$ | %d$ - %s", szName[0], g_iCountMoney[0], g_iCountMoney[1], szName[1]);
}

jbm_duel_start()
{
	g_iDuelStatus = 2;
	switch(g_iDuelType)
	{
		case 1:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_deagle");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_DEAGLE, 9999);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			if(g_iDuelTypeFair) set_task(1.0, "jbm_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = g_iTimeAttack[g_iDuelTimeToAttack] + 1);
			fm_give_item(g_iDuelUsersId[1], "weapon_deagle");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_DEAGLE, 9999);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
			if(g_iDuelTypeFair) set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, float(g_iTimeAttack[g_iDuelTimeToAttack] + 1), linux_diff_player);
		}
		case 2:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_m3");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_M3, 9999);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			if(g_iDuelTypeFair)
			{
				set_pdata_float(get_pdata_cbase(g_iDuelUsersId[0], m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + float(g_iTimeAttack[g_iDuelTimeToAttack] + 1), linux_diff_weapon);
				set_task(1.0, "jbm_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = g_iTimeAttack[g_iDuelTimeToAttack] + 1);
			}
			fm_give_item(g_iDuelUsersId[1], "weapon_m3");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_M3, 9999);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
			if(g_iDuelTypeFair) set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, float(g_iTimeAttack[g_iDuelTimeToAttack] + 1), linux_diff_player);
		}
		case 3:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_hegrenade");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_HEGRENADE, 9999);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			fm_give_item(g_iDuelUsersId[1], "weapon_hegrenade");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_HEGRENADE, 9999);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
		}
		case 4:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_m249");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_M249, 9999);
			set_pev(g_iDuelUsersId[0], pev_health, 506.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			fm_give_item(g_iDuelUsersId[1], "weapon_m249");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_M249, 9999);
			set_pev(g_iDuelUsersId[1], pev_health, 506.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
		}
		case 5:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_awp");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_AWP, 9999);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			if(g_iDuelTypeFair)
			{
				set_pdata_float(get_pdata_cbase(g_iDuelUsersId[0], m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + float(g_iTimeAttack[g_iDuelTimeToAttack] + 1), linux_diff_weapon);
				set_task(1.0, "jbm_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = g_iTimeAttack[g_iDuelTimeToAttack] + 1);
			}
			fm_give_item(g_iDuelUsersId[1], "weapon_awp");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_AWP, 9999);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
			if(g_iDuelTypeFair) set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, float(g_iTimeAttack[g_iDuelTimeToAttack] + 1), linux_diff_player);
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
}

public jbm_duel_timer_attack(pPlayer)
{
	if(--g_iDuelTimerAttack)
	{
		pPlayer -= TASK_DUEL_TIMER_ATTACK;
		set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.16, 0, 0.0, 0.9, 0.1, 0.1, -1);
		ShowSyncHudMsg(0, g_iSyncDuelInformer, "%L", LANG_PLAYER, "JBM_ALL_HUD_DUEL_TIMER_ATTACK", pPlayer == g_iDuelUsersId[0] ? g_iDuelNames[0] : g_iDuelNames[1],g_iDuelTimerAttack);
	}
	else
	{
		pPlayer -= TASK_DUEL_TIMER_ATTACK;
		new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem, linux_diff_player);
		if(iActiveItem > 0) 
			ExecuteHamB(Ham_Weapon_PrimaryAttack, iActiveItem);
	}
}

public jbm_duel_bream_cylinder()
{
	new Float:vecOrigin[3];
// duelist
	pev(g_iDuelUsersId[0], pev_origin, vecOrigin);
	if(pev(g_iDuelUsersId[0], pev_flags) & FL_DUCKING) vecOrigin[2] -= 15.0;
	else vecOrigin[2] -= 33.0;
	CREATE_BEAMCYLINDER(vecOrigin, 150 , g_pSpriteWave, _, _, 5, 9, _, 255, 0, 0, 255, _);
// duelist
	pev(g_iDuelUsersId[1], pev_origin, vecOrigin);
	if(pev(g_iDuelUsersId[1], pev_flags) & FL_DUCKING) vecOrigin[2] -= 15.0;
	else vecOrigin[2] -= 33.0;
	CREATE_BEAMCYLINDER(vecOrigin, 150 , g_pSpriteWave, _, _, 5, 9, _, 0, 0, 255, 255, _);
}

jbm_duel_ended(pPlayer)
{
	for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	g_iBitUserDuel = 0;
	jbm_set_user_rendering(g_iDuelUsersId[0], kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	jbm_set_user_rendering(g_iDuelUsersId[1], kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	CREATE_KILLPLAYERATTACHMENTS(g_iDuelUsersId[0]);
	CREATE_KILLPLAYERATTACHMENTS(g_iDuelUsersId[1]);
	remove_task(TASK_DUEL_BEAMCYLINDER);
	if(task_exists(g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK)) remove_task(g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK);
	if(task_exists(g_iDuelUsersId[1]+TASK_DUEL_TIMER_ATTACK)) remove_task(g_iDuelUsersId[1]+TASK_DUEL_TIMER_ATTACK);
	new iPlayer = g_iDuelUsersId[0] != pPlayer ? g_iDuelUsersId[0] : g_iDuelUsersId[1];
	if(isSetBit(g_iBitUserAlive, iPlayer))
	{
		if(jbm_get_players_count(0, 2) >= g_iLevelCvars[PLAYERS_NEED]) g_iExpName[iPlayer]++;
		ExecuteHamB(Ham_Player_ResetMaxSpeed, iPlayer);
		fm_strip_user_weapons(iPlayer);
		fm_give_item(iPlayer, "weapon_knife");
	}
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
		case 2: 
		{
			if(isSetBit(g_iBitUserAlive, iPlayer) && g_iDuelPrize)
			{
				new szName[32]; get_user_name(iPlayer, szName, charsmax(szName));
				new iPrize = random_num(1, g_iAllCvars[LAST_PRISONER_MONEY]);
				
				if(g_iUserTeam[iPlayer] == 2)
				{
					UTIL_SayText(0, "!y[!gJBM!y] Игрок !t%s !yза победу в дуэли получает !g%d!y$.", szName, iPrize);
					jbm_set_user_money(iPlayer, g_iUserMoney[iPlayer] + iPrize, 1);
				}
				else if(g_iUserTeam[iPlayer] == 1)
				{
					if(isNotSetBit(g_iBitUserConnected, g_iDuelPrizeId))
						return;
					
					if(g_iUserTeam[g_iDuelPrizeId] == 1)
					{
						switch(g_iDuelPrize)
						{
							case 1:
							{
								setBit(g_iBitUserFreeNextRound, g_iDuelPrizeId);
								get_user_name(g_iDuelPrizeId, szName, charsmax(szName));
								UTIL_SayText(0, "!y[!gJBM!y] Игрок !t%s !yполучит !gсвободный день !yв следующем раунде.", szName, iPrize);
							}
							case 2: 
							{
								setBit(g_iBitUserVoiceNextRound, g_iDuelPrizeId);
								get_user_name(g_iDuelPrizeId, szName, charsmax(szName));
								UTIL_SayText(0, "!y[!gJBM!y] Игрок !t%s !yполучит !tголос !yв следующем раунде.", szName, iPrize);
							}
						}
					}
				}
			}
		}
	}
	g_iDuelStatus = 0;

	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(task_exists(i+TASK_SHOW_MONEY_BET)) remove_task(i+TASK_SHOW_MONEY_BET);
		clearBit(g_iBitUserBet, i);
		if(g_iUserBetId[i] != 0)
		{
			if(g_iUserBetId[i] != iPlayer) 
			{
				UTIL_SayText(i, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_ID_CHAT_BET_LOSE");
				g_iUserBet[i] = 0;
				g_iUserBetId[i] = 0;
			}
			else if(g_iUserBetId[i] == iPlayer) 
			{
				jbm_set_user_money(i, g_iUserMoney[i] + g_iUserBet[i] * 2, 0);
				UTIL_SayText(i, "!y[!gJBM!y]!y %L", LANG_PLAYER, "JBM_ID_CHAT_BET_WIN", g_iUserBet[i]);
				g_iUserBet[i] = 0;
				g_iUserBetId[i] = 0;
			}
		}
	}
}
/* < Дуэль < *///}

/* > Футбол > *///{
jbm_soccer_disable_all()
{
	jbm_soccer_remove_ball();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isSetBit(g_iBitUserSoccer, iPlayer))
		{
			clearBit(g_iBitUserSoccer, iPlayer);
			jbm_default_player_model(iPlayer);
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
		if(g_iChiefStatus == 1) remove_task(g_iChiefId+TASK_SHOW_SOCCER_SCORE);
	}
	g_iSoccerScore = {0, 0};
	g_bSoccerGame = false;
	g_bSoccerStatus = false;
	g_iSoccerBallSpeed = 1000;
}

jbm_soccer_create_ball(pPlayer)
{
	if(g_iSoccerBall) return g_iSoccerBall;
	static iszFuncWall = 0;
	if(iszFuncWall || (iszFuncWall = engfunc(EngFunc_AllocString, "func_wall"))) g_iSoccerBall = engfunc(EngFunc_CreateNamedEntity, iszFuncWall);
	if(pev_valid(g_iSoccerBall))
	{
		jbm_set_user_rendering(g_iSoccerBall, kRenderFxGlowShell, random_num(0,255), random_num(0,255), random_num(0,255), kRenderNormal, 4);
		set_pev(g_iSoccerBall, pev_classname, "ball");
		set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
		set_pev(g_iSoccerBall, pev_movetype, MOVETYPE_BOUNCE);
		engfunc(EngFunc_SetModel, g_iSoccerBall, g_szModels[BALL]);
		engfunc(EngFunc_SetSize, g_iSoccerBall, Float:{-4.0, -4.0, -4.0}, Float:{4.0, 4.0, 4.0});
		set_pev(g_iSoccerBall, pev_framerate, 1.0);
		set_pev(g_iSoccerBall, pev_sequence, 0);
		set_pev(g_iSoccerBall, pev_nextthink, get_gametime() + 0.04);
		fm_get_aiming_position(pPlayer, g_flSoccerBallOrigin);
		engfunc(EngFunc_SetOrigin, g_iSoccerBall, g_flSoccerBallOrigin);
		engfunc(EngFunc_DropToFloor, g_iSoccerBall);
		return g_iSoccerBall;
	}
	jbm_soccer_remove_ball();
	return 0;
}

jbm_soccer_remove_ball()
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
			jbm_set_hand_model(g_iSoccerBallOwner);
		}
		if(pev_valid(g_iSoccerBall)) engfunc(EngFunc_RemoveEntity, g_iSoccerBall);
		g_iSoccerBall = 0;
		g_iSoccerBallOwner = 0;
		g_iSoccerKickOwner = 0;
		g_bSoccerBallTouch = false;
	}
}

jbm_soccer_update_ball()
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
				jbm_set_hand_model(g_iSoccerBallOwner);
			}
			set_pev(g_iSoccerBall, pev_velocity, {0.0, 0.0, 0.0});
			set_pev(g_iSoccerBall, pev_solid, SOLID_TRIGGER);
			engfunc(EngFunc_SetModel, g_iSoccerBall, g_szModels[BALL]);
			engfunc(EngFunc_SetSize, g_iSoccerBall, Float:{-4.0, -4.0, -4.0}, Float:{4.0, 4.0, 4.0});
			engfunc(EngFunc_SetOrigin, g_iSoccerBall, g_flSoccerBallOrigin);
			engfunc(EngFunc_DropToFloor, g_iSoccerBall);
			g_iSoccerBallOwner = 0;
			g_iSoccerKickOwner = 0;
			g_bSoccerBallTouch = false;
		}
		else jbm_soccer_remove_ball();
	}
}

jbm_soccer_game_start(pPlayer)
{
	new iPlayers;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(isSetBit(g_iBitUserSoccer, iPlayer)) iPlayers++;
	if(iPlayers < 2) UTIL_SayText(pPlayer, "!y[!gJBM!y]!y %L", pPlayer, "JBM_CHAT_ID_SOCCER_INSUFFICIENTLY_PLAYERS");
	else
	{
		for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(isSetBit(g_iBitUserSoccer, iPlayer) || iPlayer == g_iChiefId) set_task(1.0, "jbm_soccer_score_informer", iPlayer+TASK_SHOW_SOCCER_SCORE, _, _, "b");
		emit_sound(pPlayer, CHAN_AUTO, g_szSounds[WHITLE_START], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		g_bSoccerBallTouch = true;
		g_bSoccerGame = true;
	}
}

jbm_soccer_game_end(pPlayer)
{
	jbm_soccer_remove_ball();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isSetBit(g_iBitUserSoccer, iPlayer))
		{
			clearBit(g_iBitUserSoccer, iPlayer);
			jbm_default_player_model(iPlayer);
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
	emit_sound(pPlayer, CHAN_AUTO, g_szSounds[WHITLE_END], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	g_iSoccerScore = {0, 0};
	g_bSoccerGame = false;
}

jbm_soccer_divide_team(iType)
{
	new const szLangPlayer[][] = {"JBM_HUD_ID_YOU_TEAM_RED", "JBM_HUD_ID_YOU_TEAM_BLUE"};
	for(new iPlayer = 1, iTeam; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isSetBit(g_iBitUserAlive, iPlayer) && isNotSetBit(g_iBitUserSoccer, iPlayer) && isNotSetBit(g_iBitUserDuel, iPlayer)
		&& (g_iUserTeam[iPlayer] == 1 && isNotSetBit(g_iBitUserFree, iPlayer) && isNotSetBit(g_iBitUserWanted, iPlayer)
		|| !iType && g_iUserTeam[iPlayer] == 2 && iPlayer != g_iChiefId))
		{
			setBit(g_iBitUserSoccer, iPlayer);
			jbm_set_user_model(iPlayer, g_szPlayerModel[FOOTBALLER]);
			set_pev(iPlayer, pev_skin, iTeam);
			set_pdata_int(iPlayer, m_bloodColor, -1);
			UTIL_SayText(iPlayer, "!y[!gJBM!y]!y %L", iPlayer, szLangPlayer[iTeam]);
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

public jbm_soccer_score_informer(pPlayer)
{
	pPlayer -= TASK_SHOW_SOCCER_SCORE;
	set_hudmessage(g_iColorInformer[0], g_iColorInformer[1], g_iColorInformer[2], -1.0, 0.01, 0, 0.0, 0.9, 0.1, 0.1, -1);
	ShowSyncHudMsg(pPlayer, g_iSyncSoccerScore, "%L %d | %d %L", pPlayer, "JBM_HUD_ID_SOCCER_SCORE_RED",
	g_iSoccerScore[0], g_iSoccerScore[1], pPlayer, "JBM_HUD_ID_SOCCER_SCORE_BLUE");
}

jbm_soccer_hand_ball_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_HAND_BALL]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szPlayerHand[PRISONER_P]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
}
/* < Футбол < *///}

/* > Мафия > *///{

jbm_mafia_game_start(pPlayer)
{
	new iPlayers;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) if(isSetBit(g_iBitUserAlive, iPlayer) && g_iUserTeam[iPlayer] == 1) iPlayers++;
	if(iPlayers < 0) UTIL_SayText(pPlayer, "!y[!gJBM!y]!y Для игры нужно минимум 7 игроков");
	else
	{
		formatex(g_szDayMode, charsmax(g_szDayMode), "JBM_HUD_GAME_MODE_MAFIA");
		g_iGlobalGame = 1;
		g_iMafiaChat = false;
		g_iMafiaNight = false;
		for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
		{
			if(isNotSetBit(g_iBitUserAlive, iPlayer) || g_iUserTeam[iPlayer] != 1) continue;
			g_iUserRoleMafia[iPlayer] = 0;
			set_task(1.0, "jbm_show_role_informer", iPlayer+TASK_SHOW_ROLE_GG, _, _, "b");
		}
	}
}

public jbm_show_role_informer(pPlayer)
{
	pPlayer -= TASK_SHOW_ROLE_GG;
	set_hudmessage(255, 255, 255, -1.0, 0.3, 0, 0.1, 1.0, 0.1, 0.2); 
	if(g_iGlobalGame == 1) show_hudmessage(pPlayer, "%L", pPlayer, "JBM_DHUD_YOUR_ROLE", pPlayer, g_szMafiaRoleName[g_iUserRoleMafia[pPlayer]]);
	else if(g_iGlobalGame == 2) show_hudmessage(pPlayer, "%L", pPlayer, "JBM_DHUD_YOUR_ROLE", pPlayer, g_szDjixadRoleName[g_iUserRoleDjixad[pPlayer]]);
}

public jbm_vote_choose_mafia_start()
{
	g_iMafiaTime = 15;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		g_iVoteMafia[iPlayer] = 0;
		if(isNotSetBit(g_iBitUserAlive, iPlayer) || g_iUserTeam[iPlayer] != 1) continue;
		setBit(g_iBitUserPlayerMafia, iPlayer);
		g_iMenuPosition[iPlayer] = 0;
	}
	set_task(1.0, "jbm_vote_mafia_timer", TASK_DAY_VOTE_MAFIA, _, _, "a", g_iMafiaTime);
}

public jbm_vote_mafia_timer()
{
	if(!--g_iMafiaTime) jbm_vote_mafia_end();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isNotSetBit(g_iBitUserPlayerMafia, iPlayer)) continue;
		Open_VoteMafia(iPlayer, g_iMenuPosition[iPlayer]);
	}
}

Open_VoteMafia(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(isNotSetBit(g_iBitUserConnected, i) || isNotSetBit(g_iBitUserAlive, i) || isNotSetBit(g_iBitUserPlayerMafia, i) || i == id) continue;
		g_iUserID[id][iPlayersNum++] = i;
	}
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > iPlayersNum) iStart = iPlayersNum;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > iPlayersNum) iEnd = iPlayersNum;
	new szMenu[512], iLen, iPagesNum = (iPlayersNum / PLAYERS_PER_PAGE + ((iPlayersNum % PLAYERS_PER_PAGE) ? 1 : 0));
	switch(iPagesNum)
	{
		case 0:
		{
			UTIL_SayText(id, "!y[!gJBM!y]!y %L", id, "JBM_CHAT_ID_PLAYERS_NOT_VALID");
			jbm_mafia_disable();
		}
		case 1: iLen = formatex(szMenu, charsmax(szMenu), "%L^n\d%L^n", id, "JBM_MENU_VOTE_MAFIA_TITLE", id, "JBM_MENU_VOTE_MAFIA_TIME_TITLE", g_iMafiaTime);
		default: iLen = formatex(szMenu, charsmax(szMenu), "%L \r[%d|%d]^n\d%L^n", id, "JBM_MENU_VOTE_MAFIA_TITLE", iPos + 1, iPagesNum, id, "JBM_MENU_VOTE_MAFIA_TIME_TITLE", g_iMafiaTime);
	}
	new szName[32], i, iBitKeys, b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iUserID[id][a];
		get_user_name(i, szName, charsmax(szName));
		if(isSetBit(g_iBitUserVoteMafia, id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \d%s \r[%d]^n", id, "JBM_KEY", ++b, szName, g_iVoteMafia[i]);
		else
		{
			iBitKeys |= (1<<b);
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "%L \w%s^n", id, "JBM_KEY", ++b, szName);
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iBitKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 8, id, "JBM_MENU_BACK");

	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iBitKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \w%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n%L \d%L", id, "JBM_KEY", 9, id, "JBM_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n%L \d%L", id, "JBM_KEY", 0, id, "JBM_MENU_EXIT");
	return show_menu(id, iBitKeys, szMenu, -1, "Open_VoteMafia");
}

public Close_VoteMafia(id, iKey)
{
	switch(iKey)
	{
		case 7: return Open_VoteMafia(id, --g_iMenuPosition[id]);
		case 8: return Open_VoteMafia(id, ++g_iMenuPosition[id]);
		default:
		{
			new szName[32], szNameTarget[32], iTarget = g_iUserID[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(g_iUserTeam[iTarget] == 1 && isSetBit(g_iBitUserAlive, iTarget))
			{
				setBit(g_iBitUserVoteMafia, id);
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
				g_iVoteMafia[iTarget]++;
				UTIL_SayText(0, "!y[!gMAFIA!y]!y %L", id, "JBM_ID_CHAT_VOTE_MAFIA", szName, szNameTarget, g_iVoteMafia[iTarget]);
			}
		}
	}
	return Open_VoteMafia(id, g_iMenuPosition[id]);
}

public jbm_vote_mafia_end()
{
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isNotSetBit(g_iBitUserPlayerMafia, iPlayer)) continue;
		clearBit(g_iBitUserPlayerMafia, iPlayer);
		clearBit(g_iBitUserVoteMafia, iPlayer);
		show_menu(iPlayer, 0, "^n");
	}
	new iVotesNum, szName[32], id;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(g_iVoteMafia[iPlayer] >= iVotesNum)
		{
			iVotesNum = g_iVoteMafia[iPlayer];
			id = iPlayer;
		}
		g_iVoteMafia[iPlayer] = 0;
	}
	get_user_name(id, szName, charsmax(szName));
	UTIL_SayText(0, "!y[!gJBM!y]!y %L", id, "JBM_ID_CHAT_VOTE_MAFIA_MORE", szName, iVotesNum);
}

jbm_mafia_disable()
{
	for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	UTIL_SayText(0, "!y[!gMAFIA!y] Мафия окончена. Через 5 секунд произойдет рестарт");
	g_iGlobalGame = 0;
	g_iMafiaChat = false;
	g_iMafiaNight = false;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(g_iMafiaNight) UTIL_ScreenFade(iPlayer, 512, 512, 0, 0, 0, 0, 255, 1);
		if(task_exists(TASK_DAY_VOTE_MAFIA))
		{
			remove_task(TASK_DAY_VOTE_MAFIA);
			show_menu(iPlayer, 0, "^n");
		}
		g_iVoteMafia[iPlayer] = 0;
		g_iUserRoleMafia[iPlayer] = 0;
		if(task_exists(iPlayer+TASK_SHOW_ROLE_GG)) remove_task(iPlayer+TASK_SHOW_ROLE_GG);
	}
	server_cmd("sv_restart 5");
}

/* < Мафия < *///}

/* > Битва за джихад > *///{

jbm_djixad_disable()
{
	for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	DisableHamForward(g_iHamHookForwardsDjihad);
	UTIL_SayText(0, "!y[!gБитва за джихад!y] Джихад окончен. Через 5 секунд произойдет рестарт");
	g_iGlobalGame = 0;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		g_iUserRoleDjixad[iPlayer] = 0;
		clearBit(g_iBitUserBury, iPlayer);
		if(task_exists(iPlayer+TASK_SHOW_ROLE_GG)) remove_task(iPlayer+TASK_SHOW_ROLE_GG);
	}
	server_cmd("sv_restart 5");
}

/* < Битва за джихад < *///}

/* > Нативы > *///{
public plugin_natives()
{
	register_native("jbm_get_day", 						"jbm_get_day", 1);
	register_native("jbm_set_day", 						"jbm_set_day", 1);
	register_native("jbm_get_day_week", 				"jbm_get_day_week", 1);
	register_native("jbm_set_day_week", 				"jbm_set_day_week", 1);
	register_native("jbm_get_day_mode", 				"jbm_get_day_mode", 1);
	register_native("jbm_set_day_mode",					"jbm_set_day_mode", 1);
	register_native("jbm_open_doors", 					"jbm_open_doors", 1);
	register_native("jbm_close_doors", 					"jbm_close_doors", 1);
	register_native("jbm_get_user_money", 				"jbm_get_user_money", 1);
	register_native("jbm_set_user_money", 				"jbm_set_user_money", 1);
	register_native("jbm_get_user_team", 				"jbm_get_user_team", 1);
	register_native("jbm_set_user_team", 				"jbm_set_user_team", 1);
	register_native("jbm_get_user_model", 				"_jbm_get_user_model", 1);
	register_native("jbm_set_user_model", 				"_jbm_set_user_model", 1);
	register_native("jbm_menu_block", 					"jbm_menu_block", 1);
	register_native("jbm_menu_unblock", 				"jbm_menu_unblock", 1);
	register_native("jbm_menu_blocked", 				"jbm_menu_blocked", 1);
	register_native("jbm_is_user_free", 				"jbm_is_user_free", 1);
	register_native("jbm_add_user_free", 				"jbm_add_user_free", 1);
	register_native("jbm_add_user_free_next_round", 	"jbm_add_user_free_next_round", 1);
	register_native("jbm_sub_user_free", 				"jbm_sub_user_free", 1);
	register_native("jbm_free_day_start", 				"jbm_free_day_start", 1);
	register_native("jbm_free_day_ended", 				"jbm_free_day_ended", 1);
	register_native("jbm_is_user_wanted", 				"jbm_is_user_wanted", 1);
	register_native("jbm_add_user_wanted", 				"jbm_add_user_wanted", 1);
	register_native("jbm_sub_user_wanted", 				"jbm_sub_user_wanted", 1);
	register_native("jbm_is_user_chief", 				"jbm_is_user_chief", 1);
	register_native("jbm_set_user_chief", 				"jbm_set_user_chief", 1);
	register_native("jbm_get_chief_status", 			"jbm_get_chief_status", 1);
	register_native("jbm_get_chief_id", 				"jbm_get_chief_id", 1);
	register_native("jbm_set_user_costumes", 			"jbm_set_user_costumes", 1);
	register_native("jbm_hide_user_costumes", 			"jbm_hide_user_costumes", 1);
	register_native("jbm_prisoners_divide_color", 		"jbm_prisoners_divide_color", 1);
	register_native("jbm_register_day_mode", 			"jbm_register_day_mode", 1);
	register_native("jbm_get_user_voice", 				"jbm_get_user_voice", 1);
	register_native("jbm_set_user_voice", 				"jbm_set_user_voice", 1);
	register_native("jbm_sub_user_voice", 				"jbm_sub_user_voice", 1);
	register_native("jbm_set_user_voice_next_round", 	"jbm_set_user_voice_next_round", 1);
	register_native("jbm_get_user_rendering", 			"_jbm_get_user_rendering", 1);
	register_native("jbm_set_user_rendering", 			"jbm_set_user_rendering", 1);
	register_native("jbm_restoring_user_rendering",		"jbm_restoring_user_rendering", 1);
	register_native("jbm_is_user_alive",				"jbm_is_user_alive", 1);
	register_native("jbm_is_user_connected",			"jbm_is_user_connected", 1);
	register_native("jbm_is_user_duel",					"jbm_is_user_duel", 1);
	register_native("jbm_get_duel_status",				"jbm_get_duel_status", 1);
	register_native("jbm_get_user_level",				"jbm_get_user_level", 1);
	register_native("jbm_get_user_level_rank",			"jbm_get_user_level_rank", 1);
	register_native("jbm_set_user_level",				"jbm_set_user_level", 1);
	register_native("jbm_get_user_exp",					"jbm_get_user_exp", 1);
	register_native("jbm_set_user_exp",					"jbm_set_user_exp", 1);
	register_native("jbm_set_boxing_status",			"jbm_set_boxing_status", 1);
	register_native("jbm_get_user_donate",				"jbm_get_user_donate", 1);
	register_native("jbm_get_players_count",			"jbm_get_players_count", 1);
}

public jbm_get_day() 
{
	return g_iDay;
}

public jbm_set_day(iDay) 
{
	g_iDay = iDay;
}

public jbm_get_day_week() 
{
	return g_iDayWeek;
}

public jbm_set_day_week(iWeek) 
{
	g_iDayWeek = (g_iDayWeek > 7) ? 1 : iWeek;
}
	
public jbm_get_day_mode() 
{
	return g_iDayMode;
}

public jbm_set_day_mode(iMode)
{
	g_iDayMode = iMode;
	formatex(g_szDayMode, charsmax(g_szDayMode), "JBM_HUD_GAME_MODE_%d", g_iDayMode);
}

public jbm_open_doors()
{
	for(new i, iDoor; i < g_iDoorListSize; i++)
	{
		iDoor = ArrayGetCell(g_aDoorList, i);
		dllfunc(DLLFunc_Use, iDoor, 0);
	}
	g_bDoorStatus = true;
}

public jbm_close_doors()
{
	for(new i, iDoor; i < g_iDoorListSize; i++)
	{
		iDoor = ArrayGetCell(g_aDoorList, i);
		dllfunc(DLLFunc_Think, iDoor);
	}
	g_bDoorStatus = false;
}

public jbm_get_user_money(pPlayer) 
{
	return g_iUserMoney[pPlayer];
}

public jbm_set_user_money(pPlayer, iNum, iFlash)
{
	if(isNotSetBit(g_iBitUserConnected, pPlayer))
		return 0;
	
	g_iUserMoney[pPlayer] = iNum;
	engfunc(EngFunc_MessageBegin, MSG_ONE, MsgId_Money, {0.0, 0.0, 0.0}, pPlayer);
	write_long(iNum);
	write_byte(iFlash);
	message_end();
	return 1;
}

public jbm_get_user_team(pPlayer) 
{
	return g_iUserTeam[pPlayer];
}

public jbm_set_user_team(pPlayer, iTeam)
{
	if(isNotSetBit(g_iBitUserConnected, pPlayer)) 
		return 0;
	
	switch(iTeam)
	{
		case 1:
		{
			set_pdata_int(pPlayer, m_bHasChangeTeamThisRound, false, linux_diff_player);
			set_pdata_int(pPlayer, m_iSpawnCount, 1);
			if(isSetBit(g_iBitUserAlive, pPlayer)) 
				ExecuteHamB(Ham_Killed, pPlayer, pPlayer, 0);
			
			engclient_cmd(pPlayer, "jointeam", "1");
			if(get_pdata_int(pPlayer, m_iPlayerTeam, linux_diff_player) != 1) 
				return 0;
			g_iPlayersNum[g_iUserTeam[pPlayer]]--;
			g_iUserTeam[pPlayer] = 1;
			g_iPlayersNum[g_iUserTeam[pPlayer]]++;
			engclient_cmd(pPlayer, "joinclass", "1");
		}
		case 2:
		{
			set_pdata_int(pPlayer, m_bHasChangeTeamThisRound, false, linux_diff_player);
			set_pdata_int(pPlayer, m_iSpawnCount, 1);
			if(isSetBit(g_iBitUserAlive, pPlayer)) 
				ExecuteHamB(Ham_Killed, pPlayer, pPlayer, 0);
			engclient_cmd(pPlayer, "jointeam", "2");
			if(get_pdata_int(pPlayer, m_iPlayerTeam, linux_diff_player) != 2) 
				return 0;
			g_iPlayersNum[g_iUserTeam[pPlayer]]--;
			g_iUserTeam[pPlayer] = 2;
			g_iPlayersNum[g_iUserTeam[pPlayer]]++;
			engclient_cmd(pPlayer, "joinclass", "1");
		}
		case 3:
		{
			if(isSetBit(g_iBitUserAlive, pPlayer)) ExecuteHamB(Ham_Killed, pPlayer, pPlayer, 0);
			engclient_cmd(pPlayer, "jointeam", "6");
			if(get_pdata_int(pPlayer, m_iPlayerTeam, linux_diff_player) != 3) 
				return 0;
			g_iPlayersNum[g_iUserTeam[pPlayer]]--;
			g_iUserTeam[pPlayer] = 3;
			g_iPlayersNum[g_iUserTeam[pPlayer]]++;
		}
	}
	return iTeam;
}

public _jbm_get_user_model(pPlayer, const szModel[], iLen)
{
	param_convert(2);
	return jbm_get_user_model(pPlayer, szModel, iLen);
}

public jbm_get_user_model(pPlayer, const szModel[], iLen) 
{
	return engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, pPlayer), "model", szModel, iLen);
}

public _jbm_set_user_model(pPlayer, const szModel[])
{
	param_convert(2);
	if(equal(g_szUserModel[pPlayer], szModel)) 
		return;
		
	jbm_set_user_model(pPlayer, szModel);
}

public jbm_set_user_model(pPlayer, const szModel[])
{
	copy(g_szUserModel[pPlayer], charsmax(g_szUserModel[]), szModel);
	static Float:fGameTime, Float:fChangeTime; fGameTime = get_gametime();
	if(fGameTime - fChangeTime > 0.1)
	{
		jbm_set_user_model_fix(pPlayer+TASK_CHANGE_MODEL);
		fChangeTime = fGameTime;
	}
	else
	{
		set_task((fChangeTime + 0.1) - fGameTime, "jbm_set_user_model_fix", pPlayer+TASK_CHANGE_MODEL);
		fChangeTime = fChangeTime + 0.1;
	}
}

public jbm_set_user_model_fix(pPlayer)
{
	pPlayer -= TASK_CHANGE_MODEL;
	engfunc(EngFunc_SetClientKeyValue, pPlayer, engfunc(EngFunc_GetInfoKeyBuffer, pPlayer), "model", g_szUserModel[pPlayer]);
	new szBuffer[64]; formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_szUserModel[pPlayer], g_szUserModel[pPlayer]);
	set_pdata_int(pPlayer, g_szModelIndexPlayer, engfunc(EngFunc_ModelIndex, szBuffer), linux_diff_player);
	setBit(g_iBitUserModel, pPlayer);
}

public jbm_menu_block(pPlayer) 
{
	setBit(g_iBitBlockMenu, pPlayer);
}

public jbm_menu_unblock(pPlayer) 
{
	clearBit(g_iBitBlockMenu, pPlayer);
}

public jbm_menu_blocked(pPlayer) 
{
	return isSetBit(g_iBitBlockMenu, pPlayer);
}

public jbm_is_user_free(pPlayer) 
{
	return isSetBit(g_iBitUserFree, pPlayer);
}

public jbm_add_user_free(pPlayer)
{
	if(g_iDayMode != DAYMODE_STANDART || g_iUserTeam[pPlayer] != 1 || isNotSetBit(g_iBitUserAlive, pPlayer) || isSetBit(g_iBitUserFree, pPlayer) || isSetBit(g_iBitUserWanted, pPlayer)) return 0;
	setBit(g_iBitUserFree, pPlayer);
	g_iFreeCount++;
	new szName[32]; get_user_name(pPlayer, szName, charsmax(szName));
	g_iFreeLang = 1;
	if(g_bSoccerStatus && isSetBit(g_iBitUserSoccer, pPlayer))
	{
		clearBit(g_iBitUserSoccer, pPlayer);
		jbm_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
		jbm_default_knife_model(pPlayer);
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
	set_pev(pPlayer, pev_skin, g_iPlayersParams[FD_SKIN]);
	g_iFreeTimeID[pPlayer] = g_iAllCvars[FREE_DAY_ID];
	set_task(1.0, "jbm_free_day_timer", pPlayer+TASK_FREE_DAY_ENDED, _, _, "a", g_iFreeTimeID[pPlayer]);
	return 1;
}

public jbm_free_day_timer(pPlayer)
{
	pPlayer -= TASK_FREE_DAY_ENDED;
	if(!--g_iFreeTimeID[pPlayer]) jbm_sub_user_free(pPlayer);
}
public jbm_add_user_free_next_round(pPlayer)
{
	if(g_iUserTeam[pPlayer] != 1) return 0;
	setBit(g_iBitUserFreeNextRound, pPlayer);
	return 1;
}
public jbm_sub_user_free(pPlayer)
{
	if(pPlayer > TASK_FREE_DAY_ENDED) pPlayer -= TASK_FREE_DAY_ENDED;
	if(isNotSetBit(g_iBitUserFree, pPlayer)) return 0;
	clearBit(g_iBitUserFree, pPlayer);
	if(task_exists(pPlayer+TASK_FREE_DAY_ENDED)) 
	{
		remove_task(pPlayer+TASK_FREE_DAY_ENDED);
		g_iFreeCount--;
	}
	if(isSetBit(g_iBitUserAlive, pPlayer)) set_pev(pPlayer, pev_skin, random_num(0, g_iPlayersParams[COUNT_SKIN]));
	return 1;
}

public jbm_free_day_start()
{
	if(g_iDayMode != DAYMODE_STANDART) return 0;
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(g_iUserTeam[iPlayer] == 1 && isSetBit(g_iBitUserAlive, iPlayer) && isNotSetBit(g_iBitUserWanted, iPlayer))
		{
			if(isSetBit(g_iBitUserFree, iPlayer)) remove_task(iPlayer+TASK_FREE_DAY_ENDED);
			else
			{
				setBit(g_iBitUserFree, iPlayer);
				if(g_bSoccerStatus && isSetBit(g_iBitUserSoccer, iPlayer))
				{
					clearBit(g_iBitUserSoccer, iPlayer);
					jbm_set_user_model(iPlayer, g_szPlayerModel[PRISONER]);
					jbm_default_knife_model(iPlayer);
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
				set_pev(iPlayer, pev_skin, g_iPlayersParams[FD_SKIN]);
			}
		}
	}
	g_iFreeLang = 0;
	g_iFreeCount = 0;
	jbm_open_doors();
	jbm_set_day_mode(2);
	g_iDayModeTimer = g_iAllCvars[FREE_DAY_ALL] + 1;
	set_task(1.0, "jbm_free_day_ended_task", TASK_FREE_DAY_ENDED, _, _, "a", g_iDayModeTimer);
	return 1;
}
public jbm_free_day_ended_task()
{
	if(--g_iDayModeTimer) formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "[%s]", UTIL_FixTime(g_iDayModeTimer));
	else jbm_free_day_ended();
}
public jbm_free_day_ended()
{
	if(g_iDayMode != DAYMODE_FREE) return 0;
	g_szDayModeTimer = "";
	if(task_exists(TASK_FREE_DAY_ENDED)) remove_task(TASK_FREE_DAY_ENDED);
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(isSetBit(g_iBitUserFree, iPlayer))
		{
			clearBit(g_iBitUserFree, iPlayer);
			set_pev(iPlayer, pev_skin, random_num(0, g_iPlayersParams[COUNT_SKIN]));
		}
	}
	jbm_set_day_mode(1);
	return 1;
}

public jbm_is_user_wanted(pPlayer) return isSetBit(g_iBitUserWanted, pPlayer);
public jbm_add_user_wanted(pPlayer)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || g_iUserTeam[pPlayer] != 1 || isNotSetBit(g_iBitUserAlive, pPlayer)
	|| isSetBit(g_iBitUserWanted, pPlayer)) return 0;
	setBit(g_iBitUserWanted, pPlayer);
	new szName[34];
	get_user_name(pPlayer, szName, charsmax(szName));
	formatex(g_szWantedNames, charsmax(g_szWantedNames), "%s^n%s", g_szWantedNames, szName);
	g_iWantedCount++;
	if(isSetBit(g_iBitUserFree, pPlayer))
	{
		clearBit(g_iBitUserFree, pPlayer);
		if(g_iDayMode == DAYMODE_STANDART && task_exists(pPlayer+TASK_FREE_DAY_ENDED)) remove_task(pPlayer+TASK_FREE_DAY_ENDED); g_iFreeCount--;
	}
	if(isSetBit(g_iBitUserSoccer, pPlayer))
	{
		clearBit(g_iBitUserSoccer, pPlayer);
		jbm_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
		jbm_default_knife_model(pPlayer);
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
	set_pev(pPlayer, pev_skin, g_iPlayersParams[WANTED_SKIN]);
	return 1;
}
public jbm_sub_user_wanted(pPlayer)
{
	if(isNotSetBit(g_iBitUserWanted, pPlayer)) return 0;
	emit_sound(0, CHAN_AUTO, g_szSounds[WANTED_START], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	clearBit(g_iBitUserWanted, pPlayer);
	g_iWantedCount--;
	if(g_szWantedNames[0] != 0)
	{
		new szName[34];
		get_user_name(pPlayer, szName, charsmax(szName));
		format(szName, charsmax(szName), "^n%s", szName);
		replace(g_szWantedNames, charsmax(g_szWantedNames), szName, "");
	}
	if(isSetBit(g_iBitUserAlive, pPlayer))
	{
		if(g_iDayMode == DAYMODE_FREE)
		{
			setBit(g_iBitUserFree, pPlayer);
			set_pev(pPlayer, pev_skin, g_iPlayersParams[FD_SKIN]);
		}
		else set_pev(pPlayer, pev_skin, random_num(0, g_iPlayersParams[COUNT_SKIN]));
	}
	return 1;
}

public jbm_is_user_chief(pPlayer) return (pPlayer == g_iChiefId);
public jbm_set_user_chief(pPlayer)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || g_iUserTeam[pPlayer] != 2 || isNotSetBit(g_iBitUserAlive, pPlayer)) return 0;
	if(g_iChiefStatus == 1)
	{
		jbm_set_user_model(g_iChiefId, g_szPlayerModel[GUARD]);
		if(g_bSoccerGame) remove_task(g_iChiefId+TASK_SHOW_SOCCER_SCORE);
		if(get_user_godmode(g_iChiefId)) set_user_godmode(g_iChiefId, 0);
	}
	if(task_exists(TASK_CHIEF_CHOICE_TIME)) remove_task(TASK_CHIEF_CHOICE_TIME);
	get_user_name(pPlayer, g_szChiefName, charsmax(g_szChiefName));
	g_iChiefStatus = 1;
	g_iChiefIdOld = pPlayer;
	g_iChiefId = pPlayer;
	jbm_set_user_model(pPlayer, g_szPlayerModel[CHIEF]);
	if(g_bSoccerStatus)
	{
		if(isSetBit(g_iBitUserSoccer, pPlayer))
		{
			clearBit(g_iBitUserSoccer, pPlayer);
			jbm_set_baton_model(pPlayer);
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
		else if(g_bSoccerGame) set_task(1.0, "jbm_soccer_score_informer", pPlayer+TASK_SHOW_SOCCER_SCORE, _, _, "b");
	}
	return 1;
}
public jbm_get_chief_status() 
{
	return g_iChiefStatus;
}
public jbm_get_chief_id() 
{
	return g_iChiefId;
}
public jbm_set_user_costumes(pPlayer, iCostumes)
{
	if(!g_iCostumesListSize || g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || iCostumes > g_iCostumesListSize) 
		return 0;
	
	if(iCostumes)
	{
		new aDataCostumes[DATA_COSTUMES_PRECACHE];
		ArrayGetArray(g_aCostumesList, iCostumes, aDataCostumes);
		if(!g_eUserCostumes[pPlayer][ENTITY])
		{
			static iszFuncWall = 0;
			if(iszFuncWall || (iszFuncWall = engfunc(EngFunc_AllocString, "func_wall"))) g_eUserCostumes[pPlayer][ENTITY] = engfunc(EngFunc_CreateNamedEntity, iszFuncWall);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_movetype, MOVETYPE_FOLLOW);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_aiment, pPlayer);
			new szBuffer[128];
			format(szBuffer, charsmax(szBuffer), "models/jb_engine/costumes/%s.mdl", aDataCostumes[MODEL_NAME]);
			engfunc(EngFunc_SetModel, g_eUserCostumes[pPlayer][ENTITY], szBuffer);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_body, str_to_num(aDataCostumes[SUB_MODEL]));
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_sequence, 0);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_animtime, get_gametime());
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_framerate, 1.0);
		}
		else 
		{
			new szBuffer[128];
			format(szBuffer, charsmax(szBuffer), "models/jb_engine/costumes/%s.mdl", aDataCostumes[MODEL_NAME]);
			engfunc(EngFunc_SetModel, g_eUserCostumes[pPlayer][ENTITY], szBuffer);
			set_pev(g_eUserCostumes[pPlayer][ENTITY], pev_body, str_to_num(aDataCostumes[SUB_MODEL]));
		}
		g_eUserCostumes[pPlayer][HIDE] = false;
		g_eUserCostumes[pPlayer][COSTUMES] = iCostumes;
		UTIL_SayText(pPlayer, "!y[!gJBM!y]!y Выбрана шапка: !g%s", aDataCostumes[NAME_COSTUME]);
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

public jbm_hide_user_costumes(pPlayer)
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

public jbm_prisoners_divide_color(iTeam)
{
	if(g_iDayMode != DAYMODE_STANDART || g_iAlivePlayersNum[1] < 2 || iTeam < 2 || iTeam > 4) return 0;
	new const szLangPlayer[][] = {"JBM_HUD_ID_YOU_TEAM_ORANGE", "JBM_HUD_ID_YOU_TEAM_GRAY", "JBM_HUD_ID_YOU_TEAM_YELLOW", "JBM_HUD_ID_YOU_TEAM_BLUE"};
	for(new iPlayer = 1, iColor; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(g_iUserTeam[iPlayer] != 1 || isNotSetBit(g_iBitUserAlive, iPlayer) || isSetBit(g_iBitUserFree, iPlayer)
		|| isSetBit(g_iBitUserWanted, iPlayer) || isSetBit(g_iBitUserSoccer, iPlayer)
		|| isSetBit(g_iBitUserDuel, iPlayer)) continue;
		UTIL_SayText(iPlayer, "!y[!gJBM!y]!y %L", iPlayer, szLangPlayer[iColor]);
		set_pev(iPlayer, pev_skin, iColor);
		if(++iColor >= iTeam) iColor = 0;
	}
	return 1;
}

public jbm_register_day_mode(szLang[32], iBlock, iTime)
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

public jbm_get_user_voice(pPlayer) return isSetBit(g_iBitUserVoice, pPlayer);
public jbm_set_user_voice(pPlayer)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || g_iUserTeam[pPlayer] != 1 || isNotSetBit(g_iBitUserAlive, pPlayer)) return 0;
	setBit(g_iBitUserVoice, pPlayer);
	return 1;
}
public jbm_sub_user_voice(pPlayer)
{
	if(g_iDayMode != DAYMODE_STANDART && g_iDayMode != DAYMODE_FREE || g_iUserTeam[pPlayer] != 1 || isNotSetBit(g_iBitUserVoice, pPlayer)) return 0;
	clearBit(g_iBitUserVoice, pPlayer);
	return 1;
}

public jbm_set_user_voice_next_round(pPlayer)
{
	if(g_iUserTeam[pPlayer] != 1) return 0;
	setBit(g_iBitUserVoiceNextRound, pPlayer);
	return 1;
}

public _jbm_get_user_rendering(pPlayer, &iRenderFx, &iRed, &iGreen, &iBlue, &iRenderMode, &iRenderAmt)
{
	for(new i = 2; i <= 7; i++) param_convert(i);
	jbm_get_user_rendering(pPlayer, iRenderFx, iRed, iGreen, iBlue, iRenderMode, iRenderAmt);
}
public jbm_get_user_rendering(pPlayer, &iRenderFx, &iRed, &iGreen, &iBlue, &iRenderMode, &iRenderAmt)
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
public jbm_set_user_rendering(pPlayer, iRenderFx, iRed, iGreen, iBlue, iRenderMode, iRenderAmt)
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
public jbm_restoring_user_rendering(pPlayer)
{
	if(isNotSetBit(g_iBitUserAlive, pPlayer)) return 0;
	if(g_eUserRendering[pPlayer][RENDER_STATUS]) 
	{
		jbm_set_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	}
	else jbm_set_user_rendering(pPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	return 1;
}

public jbm_is_user_alive(pPlayer) 
{
	return isSetBit(g_iBitUserAlive, pPlayer);
}

public jbm_is_user_connected(pPlayer) 
{
	return isSetBit(g_iBitUserConnected, pPlayer);
}

public jbm_is_user_duel(pPlayer) 
{
	return isSetBit(g_iBitUserDuel, pPlayer);
}

public jbm_get_duel_status() 
{
	return g_iDuelStatus;
}

public jbm_get_user_level(pPlayer)
{
	return g_iLevel[pPlayer][0];
}

public jbm_get_user_level_rank(pPlayer) 
{
	return g_iLevel[pPlayer][1];
}

public jbm_set_user_level(pPlayer, iLevel, iInfo)
{
	g_iLevel[pPlayer][0] = iLevel;
	if(iInfo)
	{
		new szName[32];
		get_user_name(pPlayer, szName, charsmax(szName)); 
		UTIL_SayText(0, "!y[!gJBM!y]!y %L", pPlayer, "JBM_ID_CHAT_NEW_LEVEL", szName, g_iLevel[pPlayer][0]);
		UTIL_ScreenFade(pPlayer, 512, 2014, 0, 100, 200, 0, 75);
		client_cmd(pPlayer, "spk ^"%s^"", g_szSounds[RANK_UP]);
	}
}

public jbm_get_user_exp(pPlayer)
{
	return g_iExpTime[pPlayer];
}

public jbm_set_user_exp(pPlayer, iExp, iInfo)
{
	g_iExpTime[pPlayer] = iExp;
	if(g_iExpTime[pPlayer] >= g_iLevelCvars[EXP_NEED])
	{
		g_iLevel[pPlayer][0]++;
		g_iExpTime[pPlayer] = 0;
		if(iInfo)
		{
			new szName[32];
			get_user_name(pPlayer, szName, charsmax(szName)); 
			UTIL_SayText(0, "!y[!gJBM!y]!y %L", pPlayer, "JBM_ID_CHAT_NEW_LEVEL", szName, g_iLevel[pPlayer][0]);
			UTIL_ScreenFade(pPlayer, 512, 2014, 0, 100, 200, 0, 75);
			client_cmd(pPlayer, "spk ^"%s^"", g_szSounds[RANK_UP]);
		}
	}
}


public jbm_set_boxing_status(iStatus)
{
	g_bBoxingStatus = iStatus;
}

public jbm_get_user_donate(pPlayer) // Большое спасибо Толе (UJBL_Core)
{
	new iBit;
	if(isSetBit(g_iBitUserVip, pPlayer)) 		{ iBit |= (1<<1); }
	if(isSetBit(g_iBitUserUltraVip, pPlayer))	{ iBit |= (1<<2); }
	if(isSetBit(g_iBitUserAdmin, pPlayer))		{ iBit |= (1<<3); }
	if(isSetBit(g_iBitUserPredator, pPlayer))	{ iBit |= (1<<4); }
	if(isSetBit(g_iBitUserBoss, pPlayer))		{ iBit |= (1<<5); }
	if(isSetBit(g_iBitUserTrail, pPlayer))		{ iBit |= (1<<6); }
	if(isSetBit(g_iBitUserAnime, pPlayer)) 		{ iBit |= (1<<7); }
	if(!iBit) iBit = (1<<0);
	return iBit;
}

public jbm_get_players_count(iTeam, iStatus)
{
	switch(iStatus)
	{
		case 0: return g_iPlayersNum[iTeam];
		case 1: return g_iAlivePlayersNum[iTeam];
		case 2: return (g_iPlayersNum[1]+g_iPlayersNum[2]);
	}
	return 0;
}

/* < Нативы < *///}

/* > Стоки > *///{

stock UTIL_RemoveTrail_TASK(pPlayer) 
{
	if(task_exists(pPlayer+TASK_TRAIL)) remove_task(pPlayer+TASK_TRAIL);
	UTIL_RemoveTrail_MSG(pPlayer);
}

stock UTIL_RemoveTrail_MSG(pPlayer) 
{
	g_iTimer[pPlayer] = 0;
	
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(99);
	write_short(pPlayer);
	message_end();
	return 1;
}


stock UTIL_CreateTrail(pPlayer)
{
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(22);
	write_short(pPlayer);
	write_short(g_iSpriteFile[aDataTrail[pPlayer][SPRITE]]);
	write_byte(20);
	write_byte(g_iWidth[aDataTrail[pPlayer][WIDTH]] / 4);
	write_byte(g_iColorPrecache[aDataTrail[pPlayer][COLOR]][0]);
	write_byte(g_iColorPrecache[aDataTrail[pPlayer][COLOR]][1]);
	write_byte(g_iColorPrecache[aDataTrail[pPlayer][COLOR]][2]);
	write_byte(g_iBrightness[aDataTrail[pPlayer][BRIGHTNESS]]);
	message_end();
	return 1;

}
	
stock fm_give_item(pPlayer, const szItem[])
{
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
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
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
	static iEntity, iszWeaponStrip = 0;
	if(iszWeaponStrip || (iszWeaponStrip = engfunc(EngFunc_AllocString, "player_weaponstrip"))) iEntity = engfunc(EngFunc_CreateNamedEntity, iszWeaponStrip);
	
	if(!pev_valid(iEntity)) 
		return 0;
		
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
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
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
	return 1;
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
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
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
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
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
	set_pdata_int(pPlayer, iOffset, iAmount, linux_diff_player);
	return 1;
}

stock fm_get_user_weapon_entity(pPlayer, iWeaponId = 0) 
{
	new iWeapon = iWeaponId, iAmount, iAmmo;
	if(!iWeapon && !(iWeapon = get_user_weapon(pPlayer, iAmount, iAmmo)))
		return 0;
	
	new szWeaponName[32];
	get_weaponname(iWeapon, szWeaponName, charsmax(szWeaponName));

	return fm_find_ent_by_owner(-1, szWeaponName, pPlayer);
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) 
{
	new strtype[11] = "classname", iEnt = index;
	switch (jghgtype) 
	{
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}
	while ((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, strtype, classname)) && pev(iEnt, pev_owner) != owner) {}
	return iEnt;
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
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
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
	return 1;
}

stock ham_strip_weapon_name(pPlayer, const szWeaponName[])
{
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
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
				if(isNotSetBit(g_iBitUserConnected, iPlayer)) continue;
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

stock UTIL_FixTime(&iTimer)
{
	if(iTimer > 3600) iTimer = 3600;
	new szTime[7]; if(iTimer < 1) add(szTime, charsmax(szTime), "00:00");
	else
	{
		new iMin = floatround(iTimer / 60.0, floatround_floor); new iSec = iTimer - (iMin * 60);
		formatex(szTime, charsmax(szTime), "%s%d:%s%d", iMin > 9 ? "" : "0", iMin, iSec > 9 ? "" : "0", iSec);
	}
	return szTime;
}

stock UTIL_WeaponAnimation(pPlayer, iAnimation)
{
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
	set_pev(pPlayer, pev_weaponanim, iAnimation);
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0.0, 0.0, 0.0}, pPlayer);
	write_byte(iAnimation);
	write_byte(0);
	message_end();
	return 1;
}

// KORD_12.7 - автор кода
stock UTIL_PlayerAnimation(pPlayer, const szAnimation[])
{
	if(isNotSetBit(g_iBitUserAlive, pPlayer))
		return 0;
	
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
	return 1;
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

stock UTIL_create_killbeam(pEntity)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pEntity);
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
	if(isNotSetBit(g_iBitUserAlive, pPlayer)) 
		return 0;
	
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_PLAYERATTACHMENT);
	write_byte(pPlayer);
	write_coord(iHeight);
	write_short(pSprite);
	write_short(iLife); // 0.1's
	message_end();
	return 1;
}

stock CREATE_KILLPLAYERATTACHMENTS(pPlayer)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLPLAYERATTACHMENTS);
	write_byte(pPlayer);
	message_end();
}

stock CREATE_BEAMENTPOINT(pEntity, Float:vecOrigin[3], pSprite, iStartFrame = 0, iFrameRate = 0, iLife, iWidth, iAmplitude = 0, iRed, iGreen, iBlue, iBrightness, iScrollSpeed = 0)
{
	if(isNotSetBit(g_iBitUserAlive, pEntity)) 
		return 0;
	
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
	return 1;
}

stock CREATE_KILLBEAM(pEntity)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pEntity);
	message_end();
}

stock jbm_translate(string[], size, source[])
{
	static const table[][] =
	{
		"Э", "#", ";", "%", "?", "э", "(", ")", "*", "+", "б", "-", "ю", ".", "0", "1", "2", "3", "4",
		"5", "6", "7", "8", "9", "Ж", "ж", "Б", "=", "Ю", ",", "^"", "Ф", "И", "С", "В", "У", "А", "П",
		"Р", "Ш", "О", "Л", "Д", "Ь", "Т", "Щ", "З", "Й", "К", "Ы", "Е", "Г", "М", "Ц", "Ч", "Н", "Я",
		"х", "\", "ъ", ":", "_", "ё", "ф", "и", "с", "в", "у", "а", "п", "р", "ш", "о", "л", "д", "ь",
		"т", "щ", "з", "й", "к", "ы", "е", "г", "м", "ц", "ч", "н", "я", "Х", "/", "Ъ", "Ё"
	};
	
	new len = 0;
	for (new i = 0; source[i] != EOS && len < size; i++)
	{
		new ch = source[i];
		
		if ('"' <= ch <= '~')
		{
			ch -= '"';
			string[len++] = table[ch][0];
			if (table[ch][1] != EOS)
			{
				string[len++] = table[ch][1];
			}
		}
		else
		{
			string[len++] = ch;
		}
	}
	string[len] = EOS;
	
	return len;
}

stock jbm_get_free_day()
{
 	new iLen = 0, szText[512], szFormat[512], g_szFreeNames[256];
  	iLen = strlen(szText);
  	for(new i = 1; i <= g_iMaxPlayers; i++)
  	{
		if(isNotSetBit(g_iBitUserFree, i)) continue;

		new szName[32];
		get_user_name(i, szName, charsmax(szName));
		iLen += copy(szText[iLen], charsmax(szText) - iLen, "^n");
		formatex(szFormat, charsmax(szFormat), "%L", LANG_PLAYER, "JBM_HUD_STING_FREE", szName, g_iFreeTimeID[i]);
		iLen += copy(szText[iLen], charsmax(szText) - iLen, szFormat);
	}
	if(g_iFreeLang) formatex(g_szFreeNames, charsmax(g_szFreeNames), "%L%s", LANG_PLAYER, "JBM_HUD_HAS_FREE", g_iFreeCount, szText);
	return g_szFreeNames;
}

stock UTIL_SetBurn(pPlayer, iTimeBurn)
{
	setBit(g_iBitUserBurn, pPlayer);
	
	EnableHamForward(g_iHamHookForwardsDjihad);
	if(iTimeBurn)
	{
		set_task(1.0, "Task_PlayerFlame", pPlayer+TASK_PLAYER_BURN, _, _, "a", iTimeBurn + 1);
		g_iTimeFire[pPlayer] = iTimeBurn;
	}
	else
	{
		set_task(1.0, "Task_PlayerFlame", pPlayer+TASK_PLAYER_BURN, _, _, "b");
		g_iTimeFire[pPlayer] = 72318;
	}
}

public Task_PlayerFlame(pPlayer)
{
	pPlayer -= TASK_PLAYER_BURN;
	if(isNotSetBit(g_iBitUserBurn, pPlayer))
	{
		if(task_exists(pPlayer + TASK_PLAYER_BURN)) { remove_task(pPlayer + TASK_PLAYER_BURN); }
		return;
	}
	if(g_iTimeFire[pPlayer]--)
	{
		new vecOrigin[3];
		get_user_origin(pPlayer, vecOrigin);
		
		new iFlags = pev(pPlayer, pev_flags);

		// Fire slow down
		if(iFlags & FL_ONGROUND)
		{
			new Float:vecVelocity[3];
			pev(pPlayer, pev_velocity, vecVelocity);
			xs_vec_mul_scalar(vecVelocity, 0.5, vecVelocity);
			set_pev(pPlayer, pev_velocity, vecVelocity);
		}
		
		emit_sound(pPlayer, CHAN_ITEM, "ambience/flameburst1.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		new iHealth = get_user_health(pPlayer);
		switch(iHealth)
		{
			case 1..5:
			{
				clearBit(g_iBitUserBury, pPlayer);
				if(task_exists(pPlayer + TASK_PLAYER_BURN))
				{
					remove_task(pPlayer + TASK_PLAYER_BURN);
				}
				return;
			}
			default:
			{
				message_begin(MSG_ONE_UNRELIABLE, MsgId_Damage, _, pPlayer);
				write_byte(0); // damage save
				write_byte(0); // damage take
				write_long(5); // damage type
				write_coord(0); // x
				write_coord(0); // y
				write_coord(0); // z
				message_end();
					
				if(g_iGlobalGame == 2)
				{ 
					set_pev(pPlayer, pev_health, get_user_health(pPlayer) - 5.0);
				}
				else if(!g_iGlobalGame)
				{
					set_pev(pPlayer, pev_health, get_user_health(pPlayer) - 3.0);
				}
			}
		}
	
		// Flame sprite
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_SPRITE);
		write_coord(vecOrigin[0]);
		write_coord(vecOrigin[1]);
		write_coord(vecOrigin[2]);
		write_short(g_pSpriteFlash);
		write_byte(20);
		write_byte(200);
		message_end();
		
		message_begin(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
		write_byte(TE_SPRITE); // TE id
		write_coord(vecOrigin[0]); // x
		write_coord(vecOrigin[1]); // y
		write_coord(vecOrigin[2]); // z
		write_short(g_pSpriteSmoke); // sprite
		write_byte(20); // scale
		write_byte(100); // brightness
		message_end();
	}
	else
	{
		if(task_exists(pPlayer + TASK_PLAYER_BURN)) { remove_task(pPlayer + TASK_PLAYER_BURN); }
		clearBit(g_iBitUserBurn, pPlayer);
		UTIL_SayText(0, "%n потушился", pPlayer);
		return;
	}
}

stock UTIL_RemoveBurn(pPlayer)
{
	clearBit(g_iBitUserBurn, pPlayer);
	if(task_exists(pPlayer + TASK_PLAYER_BURN)) remove_task(pPlayer + TASK_PLAYER_BURN);
	
	if(isNotSetBit(g_iBitUserAlive, pPlayer)) 
		return 0;
	
	new vecOrigin[3];
	get_user_origin(pPlayer, vecOrigin);
	return 1;
}

stock UTIL_BarTime(pPlayer, iTime)
{
	engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, MsgId_BarTime, {0.0, 0.0, 0.0}, pPlayer);
	write_short(iTime);
	message_end();
}

/* < Стоки < *///}