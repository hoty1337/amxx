#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#if AMXX_VERSION_NUM < 183
#include <colorchat>
#endif	

// #### Конфигурационные defines ####
#define VIP_ACCESS ADMIN_LEVEL_H			// Флаг доступа VIP (по дефолту флаг "t" ADMIN_LEVEL_H)
#define CHATTAG "^3[^4VIP-ZADROT^3]^4" 		// Префикс перед сообщениями || ^1 - желтый ^3 - цвет команды ^4 - зеленый
#define VIPROUND 3							// C какого раунда можно открыть вип меню
#define AWPM249RND 4						// С какого раунда доступны AWP и пулемет

#define ADDHP_HS 15							// Кол-во HP за убийство в голову
#define ADDHP 10					    	// Кол-во HP за убийство в тело
#define MAXHP 100							// Максимальное количество HP

// #define AUTOVIPMENU							// Автоматически открывать в начале рануда Вип меню (выключено по дефолту)
#define VIPAUTODEAGLE						// В начале каждого раунда давать Дигл
#define VIPAUTOGRENADE						// Давать в начале каждого раунда гранаты
#define VIPTAB								// Показывать статус VIP в таблице на tab
// #### Конфигурационные defines ####

#define is_user_vip(%0) (get_user_flags(%0) & VIP_ACCESS)

new g_roundCount;

new bool:iUseWeapon[33], bool:bDefuse, bool:g_iBlockBonus;

new const PRIMARY_WEAPONS_BITSUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);
new const SECONDARY_WEAPONS_BITSUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE);

new bool:iUserVip[33];

new g_iHudSyncMsg;

public plugin_init()
{
	register_plugin("VIPka", "1.34", "neygomon");
	
	register_event("TextMsg", "eRestart", "a", "2&#Game_C", "2&#Game_w");
	register_event("Damage","eventDamage","b","2!0","3=0","4!0");
	register_event("DeathMsg","eventDeathMsg","a","1>0");
	register_event("HLTV","eRoundStart","a","1=0","2=0");

	#if defined VIPTAB
	if(!engfunc(EngFunc_FindEntityByString,FM_NULLENT,"classname","func_vip_safetyzone"))
		register_message(get_user_msgid("ScoreAttrib"),"MessageScoreAttrib");
	#endif
	if(engfunc(EngFunc_FindEntityByString,FM_NULLENT,"classname","func_bomb_target")) 
		bDefuse = true;
		
	RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1);
	
	register_clcmd("say /vipmenu", "CmdMenu");
	register_clcmd("vipmenu", "CmdMenu");
	register_clcmd("say", "hook_say");
	register_clcmd("say_team", "hook_say");
	
	register_menucmd(register_menuid("Vip Menu"), MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5, "handler");
	
	new iMap_Name[32], iMap_Prefix[][] = { "awp_", "aim_", "35hp" };
	get_mapname(iMap_Name, charsmax(iMap_Name))
	for(new i; i < sizeof iMap_Prefix; i++)
	{
		if(containi(iMap_Name, iMap_Prefix[i]) != -1)
			g_iBlockBonus = true
	}
	 
	g_iHudSyncMsg = CreateHudSyncObj();
}	

public client_putinserver(id) 
{
	if(!is_user_vip(id)) return;
	static name[32]; get_user_name(id, name, charsmax(name));
	client_print_color(0, 0, "%s На сервер зашёл ^3VIP клиент ^1%s", CHATTAG, name);
}
	
public eRestart()
	g_roundCount = 0;

public eRoundStart()
{
	g_roundCount++;
	
	arrayset(iUseWeapon, false, 33);
}

public eventDamage(id)
{
	static attID; attID = get_user_attacker(id);	
	if(is_user_connected(attID) && iUserVip[attID])
	{	
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1);
		ShowSyncHudMsg(attID, g_iHudSyncMsg, "%i^n", read_data(2));
	}
}

public eventDeathMsg()
{
	static	killerID; killerID = read_data(1);
	if(iUserVip[killerID])
	{
		static	killer_HP, addHP;
		killer_HP = get_user_health(killerID);
		addHP = ((read_data(3) == 1)) ? ADDHP_HS : ADDHP;
		fm_set_user_health(killerID, ((killer_HP += addHP) > MAXHP)? MAXHP : killer_HP);
		set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 1.0, 1.0, 0.1, 0.1, -1);
		ShowSyncHudMsg(killerID, g_iHudSyncMsg, "Добавлено +%d HP", addHP);
	}
}

public Player_Spawn(id)
{
	if(g_iBlockBonus || !is_user_alive(id)) return 0;
	
	if(is_user_vip(id)) iUserVip[id] = true;
	else return iUserVip[id] = false;
	
	#if defined VIPAUTOGRENADE
	fm_give_item(id, "weapon_hegrenade");
	fm_give_item(id, "weapon_flashbang");
	fm_give_item(id, "weapon_smokegrenade");
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
	#endif
	#if defined VIPAUTODEAGLE
	give_item_ex(id,"weapon_deagle",35,1)
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	#endif
	cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM);
	if(bDefuse && cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_defuse(id, 1);
		
	#if defined AUTOVIPMENU
	return CmdMenu(id);
	#else
	return 0;
	#endif
}

public hook_say(id)
{
	static szMsg[128]; read_args(szMsg, 127); remove_quotes(szMsg);

	if(szMsg[0] != '/') return 0;

	static const szChoosedWP[][] = { "/ak47", "/m4a1", "/famas", "/awp", "/b51" };
	for(new a; a < sizeof szChoosedWP; a++)
	{
		if(!strcmp(szMsg, szChoosedWP[a]))
		{
			if(!is_allow_use(id)) break;
			if(a > 2 && g_roundCount < AWPM249RND) 
				return client_print_color(id, 0, "%s Данное оружие доступно только с^3 %d ^4раунда!", CHATTAG, AWPM249RND);
			return handler(id, a);
		}
	}
	return 0;
}	

public CmdMenu(id)
{
	if(!is_allow_use(id)) return 0;
	
	static szMenu[512], iLen, iKey;

	iKey = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3;
	iLen = formatex(szMenu, 511, "\rVip | \wХики Задротa^n\ \rНаш Сайт | \wmyhostin.ru^n\ \rНаш ip | \w37.230.210.155:27777^n^n\y1. \rВзять | AK47^n\y2. \rВзять | M4A1^n\y3. \rВзять | Famas^n");

	if(g_roundCount < AWPM249RND) 
		iLen += formatex(szMenu[iLen], 511 - iLen, "\y4. \dВзять | AWP \r[c %d раунда]^n\y5. \dВзять | Пулемет \r[c %d раунда]^n^n", AWPM249RND, AWPM249RND);
	else
	{
		iKey |= MENU_KEY_4|MENU_KEY_5;
		iLen += formatex(szMenu[iLen], 511 - iLen, "\y4. \rВзять AWP^n\y5. \rВзять Пулемет^n^n");
	}
	formatex(szMenu[iLen], 511 - iLen, "\y0. \wВыход");
	set_pdata_int(id, 205, 0);
	return show_menu(id, iKey, szMenu, -1, "Vip Menu");
}

public handler(id, iKey)
{
	if(iKey > 4 || iUseWeapon[id]) return 0;
	
	static const szChoosedBP[] = { 90, 90, 90, 30, 250 };
	static const szChoosedWP[][] = { "weapon_ak47", "weapon_m4a1", "weapon_famas", "weapon_awp", "weapon_m249" };

	iUseWeapon[id] = true;

	return give_item_ex(id, szChoosedWP[iKey], szChoosedBP[iKey], 1);
}

stock give_item_ex(id,currWeaponName[],ammoAmount,dropFlag=0)
{
	static	weaponsList[32], weaponName[32], weaponsNum, currWeaponID;		
	currWeaponID = get_weaponid(currWeaponName);
	if(dropFlag)
	{	
		weaponsNum = 0;
		get_user_weapons(id,weaponsList,weaponsNum);
		for (new i;i < weaponsNum;i++)
		{
			if(((1 << currWeaponID) & PRIMARY_WEAPONS_BITSUM && (1 << weaponsList[i]) & PRIMARY_WEAPONS_BITSUM) | ((1 << currWeaponID) & SECONDARY_WEAPONS_BITSUM && (1 << weaponsList[i]) & SECONDARY_WEAPONS_BITSUM))
			{
				get_weaponname(weaponsList[i],weaponName,charsmax(weaponName));
				engclient_cmd(id,"drop",weaponName);
			}
		}
	}
	fm_give_item(id,currWeaponName);
	cs_set_user_bpammo(id,currWeaponID,ammoAmount);
	return 1;
}

bool:is_allow_use(id)
{
	if(!iUserVip[id])
	{
		client_print_color(id, 0, "%s ^3Только с Вип привилегие ^4могут пользоваться Вип меню от Хакки Задрот Задрот!", CHATTAG);
		return false;
	}
	if(!is_user_alive(id))
	{
		client_print_color(id, 0, "%s Для использования данной команды вы должны быть ^3живы^4!", CHATTAG);
		return false;
	}
	if(!g_roundCount)
	{
		client_print_color(id, 0, "%s Использование Вип меню от Хакки Задрот в первом раунде. ^3Запрещено!", CHATTAG);
		return false;
	}
	if(iUseWeapon[id])
	{
		client_print_color(id, 0, "%s Вы ^3уже брали ^4оружие в этом раунде!", CHATTAG);
		return false;
	}
	if(g_roundCount < VIPROUND)
	{
		client_print_color(id, 0, "%s Оружия доступны только с^3 %d ^1раунда!", CHATTAG, VIPROUND);
		return false;
	}
	return true;
}

#if defined VIPTAB
public MessageScoreAttrib(iMsgId, iDest, iReceiver)
{
	if(is_user_vip(get_msg_arg_int(1)) && !get_msg_arg_int(2))
		set_msg_arg_int(2, ARG_BYTE, 4);
}
#endif