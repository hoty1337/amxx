#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

// Original Model: https://cs-amba.ru/news/novaja_model_jolki_s_podarkami_dlja_cs_1_6/2016-12-12-2859

//#define ZP_MOD_SUPPORT // Поддержка ZP Мода. Закомментируйте, если не нужно
// #define DHUD_MESSAGE_SUPPORT // Дхуд при выдаче подарка. Закомментируйте, если вам нужно сообщение в чате
#define ADMIN_FLAG_SUPPORT ADMIN_RCON // Только админ может использовать меню управления ёлкой? Закомментируйте, если не нужно

// [ Setting's ]
#define FOLDER_PATH_SPAWNS			"addons/amxmodx/configs/tree_spawns/" // Папка для записи файлов с координатами
#define FOLDER_PATH_ITEM			"addons/amxmodx/configs/tree_items" // Папка для записи файлов с координатами
#define FILE_FORMAT 				".ini" // Формат файлов. Default: .ini

#define ENTITY_CLASSNAME 			"ent_tree" // Класснейм ёлки
#define ENTITY_MODEL				"models/m0rt3m/xmas2017wd.mdl" // Модель ёлки
#define ENTITY_RADIUS				270.0 // Радиус ( вокруг ) от ёлки в котором будет работать зона для выдачи подарков
#define ENTITY_DISTANCE				210.0 // Дистанция ( прямо от ёлки к игроку ) от ёлки в которой будет происходить выдача подарков
#define ENTITY_ORIGIN_UP			15.0 // Насколько поднимать вверх модель. Закомментируйте, если не нужно

// Закомментируйте, если не нужно
#define ENTITY_SAVE_MESSAGE			"!y[!gЁлка!y] Успешно сохранена! Координаты:!g %.2f!y |!g %.2f!y |!g %.2f" // Сообщение о сохранении ёлки с коордами.
// Спецификатор %s - Включена/Выключена
#define ENTITY_WORK_ON				"!y[!gЁлка!y] Успешно!g %s!" // Сообщение о включении/выключении ёлки. Закомментируйте, если не нужно

#define MESSAGE_TO_SEND 			"Подойдите поближе чтобы получить подарок!" // Сообщение чтобы игрок подошёл поближе к ёлке
#define MESSAGE_TIME_TO_SEND		1.5 // Время через которое отправится новое сообщение чтобы игрок подошёл поближе к ёлке

#define BLOCK_ENTITY_ROUNDS			-1 // Через сколько раундов можно будет брать подарок заново. -1 - через карту. 0 - нет блока
#define BLOCK_ENTITY_TIME			1.5 // Время через которое отправится новое сообщение о блокировке по раундам/на карту
#define MESSAGE_BLOCK_ENTITY_MAP	"Приходи на следующей неделе!" // Сообщение если игрок получил уже получил подарок и ему осталось ждать одну карту
// Спецификатор %d - кол-во раундов
#define MESSAGE_BLOCK_ENTITY_RND	"Приходи через %d раунда(-ов)!" // Сообщение если игрок получил уже получил подарок и ему осталось ждать пару раундов
#if defined DHUD_MESSAGE_SUPPORT
	// Спецификатор %s - название вещи
	#define DHUD_MESSAGE 			"Вам выпал подарок: %s" // Дхуд-Сообщение когда игроку выпала вещь

	#define DHUD_COLOR_R			0 // Цвет Red по системе цветов RGB
	#define DHUD_COLOR_G 			196 // Цвет Green по системе цветов RGB
	#define DHUD_COLOR_B			255 // Цвет Blue по системе цетов RGB

	#define DHUD_POS_X				-1.0 // Позиция худа горизонтально
	#define DHUD_POS_Y				0.27 // Позиция худа вертикально

	#define DHUD_HOLD_TIME			3.5 // Сколько времени Дхуд будет виден на экране
#else
	// Спецификатор %s - название вещи
	#define MESSAGE_ITEM_GIVE_PLAYER	"!y[!gПодарки!y] Вам попался подарок:!g %s" // Сообщение когда игроку выпала вещь
#endif
//

// [ Offset's ]
#define linux_diff_player			5

#define m_iAccount					115
//

// [ MsgId's ]
#define MsgId_SayText 				76
#define MsgId_Money					102
#define MsgId_BarTime				108
//

// [ Task's ]
#define TASK_GIVE_PLAYER_ITEM		512312
//ц

#if defined ZP_MOD_SUPPORT
	#tryinclude <zombieplague>
#endif

#if defined DHUD_MESSAGE_SUPPORT
	#tryinclude <dhudmessage>
#endif

new g_iEntTree, Float: g_flOriginTree[3], Float: g_flAnglesTree[3];
new g_szCfgSpawnFile[128], g_szCfgItemsFile[128];
new g_iBlockedEntity[33];
new g_iMaxPlayers;
new bool: g_bUseTree;

new Array: g_aItemName, Array: g_aItemCodeName, Array: g_aItemAmmo;

native jbm_get_user_money(pPlayer);
native jbm_set_user_money(pPlayer, iNum, iFlash);
native jbm_get_day_mode();
native jbm_is_gg();
native jbm_is_user_duel(pPlayer);

public plugin_natives()
{
	register_native("xmas_tree_count", "xmas_tree_count", 1);
}

public xmas_tree_count(pPlayer, iNum)
{
	if(!is_user_connected(pPlayer)) return 0;
	g_iBlockedEntity[pPlayer] = iNum;
	return 1;
}

// [ Main ]
public plugin_precache()
	engfunc(EngFunc_PrecacheModel, ENTITY_MODEL);

public plugin_init()
{
	register_plugin("[AMXX] Christmas Tree", "0.0.1", "m0rt3m");

	register_logevent("LogEvent__RoundStarted", 2, "1=Round_Start");

	RegisterHam(Ham_Think, "info_target", "HamHook__EntityThink_Post", 1);

	register_menucmd(register_menuid("Show__TreeMenu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), "Handle__TreeMenu");

	register_clcmd("say /treemenu", "Show__TreeMenu");

	g_iMaxPlayers = get_maxplayers();
}

public plugin_cfg()
{
	new szCfgDir[64];
	get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));

	new szMapName[32];
	get_mapname(szMapName, charsmax(szMapName));
	add(g_szCfgSpawnFile, charsmax(g_szCfgSpawnFile), FOLDER_PATH_SPAWNS);
	add(g_szCfgSpawnFile, charsmax(g_szCfgSpawnFile), szMapName);
	add(g_szCfgSpawnFile, charsmax(g_szCfgSpawnFile), FILE_FORMAT);

	add(g_szCfgItemsFile, charsmax(g_szCfgItemsFile), FOLDER_PATH_ITEM);
	add(g_szCfgItemsFile, charsmax(g_szCfgItemsFile), FILE_FORMAT);

	load_spawns();
	load_items();
}

public LogEvent__RoundStarted()
{
	for(new pPlayer = 1; pPlayer <= g_iMaxPlayers; pPlayer++)
	{
		Remove__ItemTask(pPlayer);
	}
}

public HamHook__EntityThink_Post(iEntity)
{
	if(iEntity == g_iEntTree)
	{
		if(pev_valid(iEntity))
		{
			static Float: flLastMessageTime[33], Float: flLastMessageRounds[33];
			new pId, Float: flOrigin[3], Float: flGameTime = get_gametime();
			pev(g_iEntTree, pev_origin, flOrigin);
			set_pev(iEntity, pev_nextthink, get_gametime() + 0.1);
			while((pId = engfunc(EngFunc_FindEntityInSphere, pId, flOrigin, ENTITY_RADIUS)))
			{
				if(g_bUseTree)
				{
					Remove__ItemTask(pId);
					return;
				}

				if(!is_user_alive(pId))
				{
					Remove__ItemTask(pId);
					return;
				}

				#if defined ZP_MOD_SUPPORT
					if(zp_get_user_zombie(pId) || zp_get_user_survivor(pId))
						return;
				#endif

				if(!is_visible_ignore_players(iEntity, pId))
				{
					Remove__ItemTask(pId);
					return;
				}

				if(g_iBlockedEntity[pId] < 1)
				{
					if(flLastMessageRounds[pId] < flGameTime)
					{
						flLastMessageRounds[pId] = flGameTime + BLOCK_ENTITY_TIME;
						client_print(pId, print_center, MESSAGE_BLOCK_ENTITY_MAP);
					}
					return;
				}

				new Float: flVictimOrigin[3];
				pev(pId, pev_origin, flVictimOrigin);
				if(jbm_get_day_mode() > 2 || jbm_is_gg() || jbm_is_user_duel(pId)) return;
				if(get_distance_f(flOrigin, flVictimOrigin) <= ENTITY_DISTANCE)
				{
					if(!task_exists(pId + TASK_GIVE_PLAYER_ITEM))
					{
						Message__BarTime(pId, 5);

						new iParm[2];
						iParm[0] = pId, iParm[1] = random_num(0, ArraySize(g_aItemName) - 1);
						set_task(5.0, "Item__GiveToPlayer", pId + TASK_GIVE_PLAYER_ITEM, iParm, 2);

						client_print(pId, print_center, "");
					}
				}
				else
				{
					Remove__ItemTask(pId);
					if(flLastMessageTime[pId] < flGameTime)
					{
						flLastMessageTime[pId] = flGameTime + MESSAGE_TIME_TO_SEND;
						client_print(pId, print_center, MESSAGE_TO_SEND);
					}
				}
			}
		}
	}
}

public Tree__Create(pPlayer, Float: flOrigin[3], Float: flAngles[3])
{
	if(g_iEntTree) return 0;
	static iszInfoTarget = 0;
	if(iszInfoTarget || (iszInfoTarget = engfunc(EngFunc_AllocString, "info_target"))) g_iEntTree = engfunc(EngFunc_CreateNamedEntity, iszInfoTarget);
	if(pev_valid(g_iEntTree))
	{
		set_pev(g_iEntTree, pev_classname, ENTITY_CLASSNAME);
		set_pev(g_iEntTree, pev_solid, SOLID_BBOX);
		set_pev(g_iEntTree, pev_movetype, MOVETYPE_NONE);
		set_pev(g_iEntTree, pev_angles, flAngles);
		if(pPlayer) set_pev(g_iEntTree, pev_owner, pPlayer);
		set_pev(g_iEntTree, pev_nextthink, get_gametime() + 0.1);

		engfunc(EngFunc_SetModel, g_iEntTree, ENTITY_MODEL);
		engfunc(EngFunc_SetSize, g_iEntTree, Float:{-16.74, -16.74, -33.49}, Float:{16.74, 16.74, 33.49});
		engfunc(EngFunc_SetOrigin, g_iEntTree, flOrigin);
	}
	return 0;
}

public Show__TreeMenu(iPlayer)
{
	if(!is_user_alive(iPlayer)) 
		return PLUGIN_HANDLED;

	#if defined ADMIN_FLAG_SUPPORT
		if(~get_user_flags(iPlayer) & ADMIN_FLAG_SUPPORT)
			return PLUGIN_HANDLED;
	#endif
	
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yМеню управления ёлкой^n^n");

	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r1\y] \wСоздать ёлку^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r2\y] \wУдалить ёлку^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r3\y] \wПовернуть ёлку^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r4\y] \wСохранить ёлку^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r5\y] \w%s ёлку^n^n^n", g_bUseTree ? "Включить" : "Выключить");

	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[\r0\y] \wВыход");
	return show_menu(iPlayer, iKeys, szMenu, -1, "Show__TreeMenu");
}

public Handle__TreeMenu(iPlayer, iKey)
{
	if(!is_user_alive(iPlayer) || iKey == 9)
		return PLUGIN_HANDLED;

	#if defined ADMIN_FLAG_SUPPORT
		if(~get_user_flags(iPlayer) & ADMIN_FLAG_SUPPORT)
			return PLUGIN_HANDLED;
	#endif

	switch(iKey)
	{
		case 0:
		{
			if(g_iEntTree) 
			{
				client_print(iPlayer, print_center, "Ёлка уже была создана!");
				return Show__TreeMenu(iPlayer);
			}
			if(fm_is_aiming_at_sky(iPlayer))
			{
				client_print(iPlayer, print_center, "Нельзя поставить ёлку в небе");
				return Show__TreeMenu(iPlayer);
			}
			fm_get_aiming_position(iPlayer, g_flOriginTree);

			#if defined ENTITY_ORIGIN_UP
				g_flOriginTree[2] += ENTITY_ORIGIN_UP;
			#endif
			Tree__Create(iPlayer, g_flOriginTree, g_flAnglesTree);	
		}
		case 1:
		{
			if(!file_exists(g_szCfgSpawnFile)) 
				fopen(g_szCfgSpawnFile, "a");

			if(pev_valid(g_iEntTree))
			{
				set_pev(g_iEntTree, pev_flags, FL_KILLME);
				g_iEntTree = 0;
			}
			if(g_flOriginTree[0] != 0.0 && g_flOriginTree[1] != 0.0 && g_flOriginTree[2] != 0.0)
			{
				for(new i = 0; i < 3; i++)
				{
					g_flOriginTree[i] = 0.0;
					g_flAnglesTree[i] = 0.0;
				}
				Ini__WriteCoordinates(g_flOriginTree, 0);
				Ini__WriteCoordinates(g_flAnglesTree, 0);
			}
		}
		case 2:
		{
			pev(g_iEntTree, pev_angles, g_flAnglesTree);

			if(g_flAnglesTree[1] == 270) 
				g_flAnglesTree[1] = 0.0;
			else
				g_flAnglesTree[1] += 90.0;

			set_pev(g_iEntTree, pev_angles, g_flAnglesTree);
		}
		case 3: 
		{
			if(!file_exists(g_szCfgSpawnFile)) 
				fopen(g_szCfgSpawnFile, "a");

			Ini__WriteCoordinates(g_flOriginTree, 0);
			Ini__WriteCoordinates(g_flAnglesTree, 1);

			#if defined ENTITY_SAVE_MESSAGE
				UTIL_SayText(iPlayer, ENTITY_SAVE_MESSAGE, g_flOriginTree[0], g_flOriginTree[1], g_flOriginTree[2]);
			#endif
		}
		case 4:
		{
			g_bUseTree = !g_bUseTree;

			#if defined ENTITY_WORK_ON
				UTIL_SayText(iPlayer, ENTITY_WORK_ON, g_bUseTree ? "выключена" : "включена");
			#endif
		}
	}
	return Show__TreeMenu(iPlayer);
}

public Item__GiveToPlayer(iParm[])
{
	new pPlayer, iCellId;
	pPlayer = iParm[0], iCellId = iParm[1];
	new szItemName[128], szItemChatName[128], iAmmoAmount;

	#if defined ZP_MOD_SUPPORT
		if(zp_get_user_zombie(pPlayer) || zp_get_user_survivor(pPlayer))
			return;
	#endif

	ArrayGetString(g_aItemName, iCellId, szItemChatName, charsmax(szItemChatName));
	ArrayGetString(g_aItemCodeName, iCellId, szItemName, charsmax(szItemName));
	iAmmoAmount = ArrayGetCell(g_aItemAmmo, iCellId)

	if(equali(szItemName, "weapon_", 7))
	{
		drop_user_weapons(pPlayer, 0);
		fm_give_item(pPlayer, szItemName);
		fm_set_user_bpammo(pPlayer, get_weaponid(szItemName), iAmmoAmount);
	}
	else if(equali(szItemName, "health"))
		set_pev(pPlayer, pev_health, pev(pPlayer, pev_health) + float(iAmmoAmount));
	else if(equali(szItemName, "armor"))
		set_pev(pPlayer, pev_armorvalue, pev(pPlayer, pev_armorvalue) + float(iAmmoAmount));
	#if defined ZP_MOD_SUPPORT
	else if(equali(szItemName, "ammo"))
		zp_set_user_ammo_packs(pPlayer, zp_get_user_ammo_packs(pPlayer) + iAmmoAmount);
	else 
		zp_force_buy_extra_item(pPlayer, zp_get_extra_item_id(szItemName), 1);
	#else
	else if(equali(szItemName, "money"))
		jbm_set_user_money(pPlayer, jbm_get_user_money(pPlayer) + iAmmoAmount, 1);
	#endif

	g_iBlockedEntity[pPlayer]--;

	#if defined DHUD_MESSAGE_SUPPORT
		set_dhudmessage(DHUD_COLOR_R, DHUD_COLOR_G, DHUD_COLOR_B, DHUD_POS_X, DHUD_POS_Y, 0, 0.0, DHUD_HOLD_TIME, 0.2, 0.7);
		show_dhudmessage(pPlayer, DHUD_MESSAGE, szItemChatName);
	#else
		UTIL_SayText(pPlayer, MESSAGE_ITEM_GIVE_PLAYER, szItemChatName);
	#endif
}
//

// [ Other ]
public client_disconnect(iPlayer) remove_task(iPlayer+TASK_GIVE_PLAYER_ITEM);
public zp_user_infected_pre(iPlayer, iInfector, iNemesis)
{
	remove_task(iPlayer+TASK_GIVE_PLAYER_ITEM);
	Message__BarTime(iPlayer, 0);
}
public zp_user_humanized_pre(iPlayer, iSurvivor) 
{
	remove_task(iPlayer+TASK_GIVE_PLAYER_ITEM);
	Message__BarTime(iPlayer, 0);
}

// [ Load Cfg ]
load_spawns()
{
	new szBuffer[256], iLine, iLen, iOrigin[3][12], iAngles[3][12], iFile = fopen(g_szCfgSpawnFile, "r");

	if(!iFile)
		return;

	while(read_file(g_szCfgSpawnFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
	{
		if(!iLen || szBuffer[0] == ';') continue;

		if(iLine == 1)
		{
			parse(szBuffer, iOrigin[0], charsmax(iOrigin[]), iOrigin[1], charsmax(iOrigin[]), iOrigin[2], charsmax(iOrigin[]));

			g_flOriginTree[0] = str_to_float(iOrigin[0]);
			g_flOriginTree[1] = str_to_float(iOrigin[1]);
			g_flOriginTree[2] = str_to_float(iOrigin[2]);
		}
		else if(iLine == 2)
		{
			parse(szBuffer, iAngles[0], charsmax(iAngles[]), iAngles[1], charsmax(iAngles[]), iAngles[2], charsmax(iAngles[]));

			g_flAnglesTree[0] = str_to_float(iAngles[0]);
			g_flAnglesTree[1] = str_to_float(iAngles[1]);
			g_flAnglesTree[2] = str_to_float(iAngles[2]);
		}
	}
	fclose(iFile);

	if(g_flOriginTree[0] != 0.0 && g_flOriginTree[1] != 0.0 && g_flOriginTree[2] != 0.0)
		Tree__Create(0, g_flOriginTree, g_flAnglesTree);
}

load_items()
{
	new szBuffer[256], iLine, iLen, iszString[2][128], iCell[8], iFile = fopen(g_szCfgItemsFile, "r");

	g_aItemName = ArrayCreate(64);
	g_aItemCodeName = ArrayCreate(64);
	g_aItemAmmo = ArrayCreate();

	if(!iFile)
	{
		static szReason[128];
		formatex(szReason, charsmax(szReason), "File ^"%s^" not found!", g_szCfgItemsFile);
		set_fail_state(szReason);
	}

	while(read_file(g_szCfgItemsFile, iLine++, szBuffer, charsmax(szBuffer), iLen))
	{
		if(!iLen || szBuffer[0] == ';' || szBuffer[0] == '[') continue;

		parse(szBuffer, iszString[0], charsmax(iszString[]), iszString[1], charsmax(iszString[]), iCell, charsmax(iCell));

		ArrayPushString(g_aItemName, iszString[0]);
		ArrayPushString(g_aItemCodeName, iszString[1]);
		ArrayPushCell(g_aItemAmmo, str_to_num(iCell));
	}
}
//

// [ Stock's ]
stock Ini__WriteCoordinates(Float: flCoord[3], iLine)
{
	new szBuffer[64];
	formatex(szBuffer, charsmax(szBuffer), "%.2f %.2f %.2f", flCoord[0], flCoord[1], flCoord[2]);
	write_file(g_szCfgSpawnFile, szBuffer, iLine);
}

stock Remove__ItemTask(pPlayer)
{
	if(task_exists(pPlayer+TASK_GIVE_PLAYER_ITEM))
	{
		remove_task(pPlayer+TASK_GIVE_PLAYER_ITEM);
		Message__BarTime(pPlayer, 0);
	}

	return 1;
}

stock Message__BarTime(pPlayer, iScale) 
{
	message_begin(MSG_ONE, MsgId_BarTime, _, pPlayer)
	write_short(iScale)
	message_end()
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

stock bool: fm_is_aiming_at_sky(pPlayer)
{
    new Float: flOrigin[3];
    fm_get_aiming_position(pPlayer, flOrigin);

    return engfunc(EngFunc_PointContents, flOrigin) == CONTENTS_SKY;
}

stock bool: is_visible_ignore_players(pPlayer, pEntity)
{
	static Float: flStart[3]; pev(pPlayer, pev_origin, flStart);
	static Float: flEnd[3]; pev(pEntity, pev_origin, flEnd);
	
	engfunc(EngFunc_TraceLine, flStart, flEnd, DONT_IGNORE_MONSTERS, pPlayer, 0);

	static pHit; pHit = get_tr2(0, TR_pHit);

	if(!pev_valid(pHit)) 
		return false;

	static bool: bRet; 
	bRet = false;

	if(is_user_alive(pHit)) 
		return true;
	else if(pev(pHit, pev_enemy) == 88) 
		bRet = is_visible_ignore_players(pHit, pEntity);

	return bRet;
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
	set_pdata_int(pPlayer, iOffset, iAmount, 5);
}

#if !defined ZP_MOD_SUPPORT
	public fm_get_user_money(pPlayer) 
		return get_pdata_int(pPlayer, m_iAccount, linux_diff_player);

	public fm_set_user_money(pPlayer, iNum, iFlash)
	{
		set_pdata_int(pPlayer, m_iAccount, iNum);

		engfunc(EngFunc_MessageBegin, MSG_ONE, MsgId_Money, {0.0, 0.0, 0.0}, pPlayer);
		write_long(iNum);
		write_byte(iFlash);
		message_end();
	}
#endif

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
				if(!is_user_connected(iPlayer)) continue;
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
//