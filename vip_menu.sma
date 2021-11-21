// *************************************************************************************//
// Плагин загружен с  www.neugomon.ru                                                   //
// Автор: Neygomon                                                                      //
// При копировании материала ссылка на сайт www.neugomon.ru ОБЯЗАТЕЛЬНА!                //
// *************************************************************************************//

#include <amxmodx>
enum _:DATA { Name[64], Cmd[32], Flags }

#define ADMIN_LOADER        // Выводить срок до конца админки с Admin Loader by Neugomon
new g_szDefaultItems[][DATA] =    // Стандартные пункты в меню | { "название пункта", "команда", "флаг доступа" }
{
	{ "\r[\yВыбор Оружие\r]",             "say /choosemenu",     ADMIN_LEVEL_H },
    { "\r[\yМеню скинов\r]",            "say /vip",         ADMIN_LEVEL_H },
    { "\r[\yЗаморозить Игрока\r]",             "freezemenu",     ADMIN_SLAY },
	{ "\r[\yНаписать Л|С\r]",             "say /pm",     ADMIN_SLAY },
	{ "\r[\yУдарить/Убить\r]",         "amx_slapmenu",     ADMIN_SLAY },
	{ "\r[\yВыбор команды игрока\r]",             "amx_teammenu",     ADMIN_SLAY },
	{ "\r[\yВставить Кляп\r]",            "amx_gagmenu",      ADMIN_SLAY }
    
}

new g_iNumItems;
new g_szMenuData[128][DATA];
new g_iMenuPage[33];
#if defined ADMIN_LOADER
	native admin_expired(index);
#endif	
public plugin_init()
{
	register_plugin("Menus Front-End", "1.5", "neugomon");
	
	register_clcmd("say /menuvip", 		"clcmdAdminMenu", ADMIN_LEVEL_H);
	register_srvcmd("amx_menuvip", 	"SrvAddMenuItems");
	
	register_menucmd(register_menuid("AMX Menu"), 1023, "amxx_handler");
	
	MenuDefaultLoad();
}

public clcmdAdminMenu(id, flags)
{
	if(get_user_flags(id) & flags)
	{
		g_iMenuPage[id] = 0;
		BuildMenu(id, g_iMenuPage[id]);
	}	
	else	console_print(id, "* Вы не имеете доступа к этой команде");
	return PLUGIN_HANDLED;
}

public SrvAddMenuItems()
{
	if(read_argc() >= 3)
	{
		new ItemName[64], ItemCmd[32], ItemFlags[30];
		read_argv(1, ItemName, charsmax(ItemName));
		read_argv(2, ItemCmd, charsmax(ItemCmd));
		read_argv(3, ItemFlags, charsmax(ItemFlags));
		
		copy(g_szMenuData[g_iNumItems][Name], 	charsmax(g_szMenuData[][Name]), ItemName);
		copy(g_szMenuData[g_iNumItems][Cmd], 	charsmax(g_szMenuData[][Cmd]), 	ItemCmd);
		g_szMenuData[g_iNumItems][Flags] = 	read_flags(ItemFlags);
		g_iNumItems++;
	}
	else	server_print("[Menus Front-End by Neugomon] Item not added! Syntax: ^"Item name^" ^"Item command^" ^"Item access^"");
	return PLUGIN_HANDLED;
}

MenuDefaultLoad()
{
	for(new i; i < sizeof g_szDefaultItems; i++)
	{
		copy(g_szMenuData[g_iNumItems][Name], 	charsmax(g_szMenuData[][Name]), g_szDefaultItems[i][Name]);
		copy(g_szMenuData[g_iNumItems][Cmd],  	charsmax(g_szMenuData[][Cmd]),  g_szDefaultItems[i][Cmd]);
		g_szMenuData[g_iNumItems][Flags] = 	g_szDefaultItems[i][Flags];
		g_iNumItems++;
	}
}

BuildMenu(id, pos)
{
	new szMenu[512];
	new len
	new start 	= pos * 8;
	new end 	= start + 8;
	new keys	= MENU_KEY_0;
	
	if(start >= g_iNumItems)
		start = pos = g_iMenuPage[id] = 0;
	if(g_iNumItems == 9 || end > g_iNumItems)
		end = g_iNumItems;	
#if defined ADMIN_LOADER
	new exp = admin_expired(id);
	if(exp > 0)
	{
		new systime = get_systime();
		if(exp - systime > 0)
		{
			if((exp - systime) / 86400 > 0)
				len = formatex(szMenu, charsmax(szMenu), "\rVip | \wХики Задротa^n\ \rНаш Сайт | \wmyhostin.ru^n\ \rНаш ip | \w37.230.210.155:27777^n\ \rДо окончание Осталось\r%d \wдней^n^n", ((exp - systime) / 86400));
			else	len = formatex(szMenu, charsmax(szMenu), "\rVip | \wХики Задротa^n\ \rНаш Сайт | \wmyhostin.ru^n\ \rДо окончание Осталось Последний \wдень^n^n");
		}
	}
	else if(exp == 0)	len = formatex(szMenu, charsmax(szMenu), "\rVip | \wХики Задротa^n\ \rНаш Сайт | \wmyhostin.ru^n\ \rНаш ip | \w37.230.210.155:27777^n\rПрава \yне ограничены^n^n");
#else
	len = formatex(szMenu, charsmax(szMenu), "\rСкины^n\wВыберите действие^n^n");
#endif
	for(new i = start, flags = get_user_flags(id), a; i < end; i++)
	{
		if(flags & g_szMenuData[i][Flags])
		{
			keys |= (1 << a);
			len += formatex(szMenu[len], charsmax(szMenu) - len, "\r%d. \w%s^n", ++a, g_szMenuData[i][Name]);
		}
		else	
		{
			new szTempStr[64];
			copy(szTempStr, charsmax(szTempStr), g_szMenuData[i][Name]);
			replace_all(szTempStr, charsmax(szTempStr), "\y", "");
			replace_all(szTempStr, charsmax(szTempStr), "\r", "");
			len += formatex(szMenu[len], charsmax(szMenu) - len, "\r%d. \d%s^n", ++a, szTempStr);
		}
	}	
	
	if(end != g_iNumItems)
	{
		formatex(szMenu[len], charsmax(szMenu) - len, "^n\r9. \yДалее^n\r0. \r%s", pos ? "Назад" : "Выход");
		keys |= MENU_KEY_9;
	}
	else formatex(szMenu[len], charsmax(szMenu) - len, "^n\r0. \r%s", pos ? "Назад" : "Выход");
	
	return show_menu(id, keys, szMenu, -1, "AMX Menu");
}

public amxx_handler(id, key)
{
	switch(key)
	{
		case 9: if(g_iMenuPage[id]) BuildMenu(id, --g_iMenuPage[id]);
		default:
		{
			if(key == 8 && g_iNumItems > 9)
				BuildMenu(id, ++g_iMenuPage[id]);
			else
			{
				new pos = g_iMenuPage[id] * 8 + key;
				if(g_szMenuData[pos][Cmd][0] == 's' && g_szMenuData[pos][Cmd][1] == 'v' && g_szMenuData[pos][Cmd][2] == '_')
					server_cmd(g_szMenuData[pos][Cmd]);
				else 	client_cmd(id, g_szMenuData[pos][Cmd]);
			}
		}
	}	
	return PLUGIN_HANDLED;
}