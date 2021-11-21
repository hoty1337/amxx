#include <amxmodx>
#include <saytext>
#include <fun>
#include <cstrike>

#define PLUGIN "Menu"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2
#pragma semicolon 1

#define MENU_VIP_FLAG ADMIN_LEVEL_A				// флаг випа
#define MENU_GROUP_VK "vk.com/goodgame16"	// группа вк

#define INFO_PRICE_VIP 50			// цена месяц вип
#define INFO_PRICE_ADMIN 100	// цена месяц админ
#define INFO_GLADMIN "dikiy"
// #define INFO_ZAMESTITEL "ник_зама" 	// раскомментировать, если есть зам
// #define INFO_SMOTRITEL "ник смотра"		// раскомментировать, если есть смотр

public plugin_init()
{
	register_plugin(PLUGIN, VER, AUTHOR);
	register_menucmd(register_menuid("Show_Menu"), 1023, "Handle_Menu");
	register_menucmd(register_menuid("Show_Info"), 1023, "Handle_Info");
	register_clcmd("say /menu", "Show_Menu");
	register_clcmd("say /rs", "ResetScore");
}

public ResetScore(id)
{
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);
	UTIL_SayText(id, "!gSERVER !t| !yВы успешно обнулили свой счёт!");
	client_cmd(id, "spk fvox/bell.wav");
}

public Show_Info(id)
{
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yИнформация^n^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \rЦ\yены:^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \wVIP - %d руб/мес^n", INFO_PRICE_VIP);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \wADMIN - %d руб/мес^n", INFO_PRICE_ADMIN);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \rК\yонтакты:^n");
	#if defined INFO_GLADMIN
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \rГл. Админ: %s^n", INFO_GLADMIN);
	#endif
	#if defined INFO_ZAMESTITEL
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \rЗам.: %s^n", INFO_ZAMESTITEL);
	#endif
	#if defined INFO_SMOTRITEL
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \rСмотр.: %s^n", INFO_SMOTRITEL);
	#endif
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d// \rГруппа VK: %s^n", MENU_GROUP_VK);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0] \d- \wВыход^n");
	return show_menu(id, iKeys, szMenu, -1, "Show_Info");
}

public Handle_Info(id, iKey)
{
	switch(iKey)
	{
		case 9:
		{
			return PLUGIN_HANDLED;
		}
		default:
		{
			UTIL_SayText(id, "!gSERVER !t| !yГруппа вк: %s", MENU_GROUP_VK);
		}
	}
	return Show_Info(id);
}

public Show_Menu(id)
{
	new szIp[32];
	get_user_ip(0, szIp, charsmax(szIp));
	new szMenu[512], iKeys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "\yГлавное меню^nIP: %s^n^n", szIp);
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1] \d- \wОбнулить счёт^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2] \d- \wСменить карту^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3] \d- \wЗаглушить игрока^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[4] \d- \wЗабанить игрока^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[5] \d- \wИнформация^n");
	if(get_user_flags(id) & MENU_VIP_FLAG)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6] \d- \rVIP \wменю^n");
		iKeys |= (1<<5);
	}
	else 
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[6] \d- VIP меню^n");
	}
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\d%s^n\y[0] \d- \wВыход^n", MENU_GROUP_VK);
	return show_menu(id, iKeys, szMenu, -1, "Show_Menu");
}

public Handle_Menu(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			ResetScore(id);
		}
		case 1:
		{
			client_cmd(id, "say /rtv");
		}
		case 2:
		{
			client_cmd(id, "say /mute");
		}
		case 3:
		{
			client_cmd(id, "say /voteban");
		}
		case 4:
		{
			return Show_Info(id);
		}
		case 5:
		{
			client_cmd(id, "say /vipmenu");
		}
		case 9:
		{
			return PLUGIN_HANDLED;
		}
	}
	return Show_Menu(id);
}