#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fun>
#include <cstrike>
#include <engine>

#define PLUGIN  "funmenu"
#define VERSION "1.0"
#define AUTHOR  "vinstoN"

#define ADMIN_ACCESS ADMIN_PASSWORD


new bool:bhopactive[33] = false;
new g_menu;
new g_page[33] = 0;
new g_iRespawn[33], g_iMoney[33], g_iHealth[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_dictionary("funmenu.txt");

	register_clcmd("funmenu", "giveMenu");
	register_clcmd("live_menu", "liveMenu");

	register_clcmd("health_menu", "healthMenu");
	register_clcmd("bunnyhop_menu", "bunnyhopMenu");

	register_clcmd("money_menu", "moneyMenu");


	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1);
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");

}

public Event_HLTV()
{
	for(new i=1;i<=get_maxplayers();i++)
	{
		g_iRespawn[i]++;
		g_iMoney[i] = 3;
		g_iHealth[i] = 1;
	}
}

public plugin_end()
{
	menu_destroy(g_menu);
}


public fwHamPlayerSpawnPost(id)
{
	if (is_user_alive(id))
	{

		bhopactive[id] = false;
	}
}

public client_PreThink(id)
{

	entity_set_float(id, EV_FL_fuser2, 0.0);

	if (entity_get_int(id, EV_INT_button) & 2) {
		if(bhopactive[id] == true)
		{
			new flags = entity_get_int(id, EV_INT_flags);

			if (flags & FL_WATERJUMP)
			return PLUGIN_CONTINUE;
			if ( entity_get_int(id, EV_INT_waterlevel) >= 2 )
			return PLUGIN_CONTINUE;
			if ( !(flags & FL_ONGROUND) )
			return PLUGIN_CONTINUE;

			new Float:velocity[3];
			entity_get_vector(id, EV_VEC_velocity, velocity);
			velocity[2] += 250.0;
			entity_set_vector(id, EV_VEC_velocity, velocity);
			entity_set_int(id, EV_INT_gaitsequence, 6);
		}
	}
	return PLUGIN_CONTINUE;
}


public client_putinserver(id)
{
	g_iRespawn[id] = 0;
	g_iHealth[id] = 1;
	g_iMoney[id] = 3;
	bhopactive[id] = false;

}

public giveMenu(id)
{
	if (get_user_flags(id) & ADMIN_ACCESS)
	{
		g_menu = menu_create("\w[\yFUN меню\w]^nДоступ: \yСоздатель", "give_menu");
		new szRespawn[64], szHealth[64], szMoney[64];
		formatex(szRespawn, charsmax(szRespawn), "Воскресить игрока [%d]", (g_iRespawn[id] < 0 ? 0 : 1));
		formatex(szHealth, charsmax(szHealth), "Выдать здоровье [%d]", g_iHealth[id]);
		formatex(szMoney, charsmax(szMoney), "Выдать деньги [%d]", g_iMoney[id]);

		menu_additem(g_menu, szRespawn, "1");

		menu_additem(g_menu, szHealth, "2");
		menu_additem(g_menu, "Выдать B-HOP", "3");

		menu_additem(g_menu, szMoney, "4");

		menu_setprop(g_menu, MPROP_EXITNAME, "Выйти");
		menu_setprop(g_menu, MPROP_NEXTNAME, "Далее");
		menu_setprop(g_menu, MPROP_BACKNAME, "Назад");
		menu_display(id, g_menu, g_page[id]);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public give_menu(id, menu, key)
{
	new imenu = menu;
	player_menu_info(id, imenu, imenu, g_page[id]);
	new access = 0;
	new callback = 0;
	new data[6];
	new name[64];
	new item = 0;
	menu_item_getinfo(menu, key, access, data, charsmax(data), name, charsmax(name), callback);
	item = str_to_num(data);
	switch (item)
	{
		case 1:
		{
			liveMenu(id, 0);
		}

		case 2:
		{
			healthMenu(id, 0);
		}
		case 3:
		{
			bunnyhopMenu(id, 0);
		}

		case 4:
		{
			moneyMenu(id, 0);
		}

	}
}

public liveMenu(id, page)
{
	if (get_user_flags(id) & ADMIN_ACCESS)
	{
		if(g_iRespawn[id] < 0) return PLUGIN_HANDLED;
		new menu = menu_create("\w[\yВоскресить\w] Выбери игрока:", "live_menu");
		menu_setprop(menu, MPROP_EXITNAME, "Выйти");
		menu_setprop(menu, MPROP_NEXTNAME, "Далее");
		menu_setprop(menu, MPROP_BACKNAME, "Назад");
		new players[32];
		new pnum = 0;
		new tempid = 0;
		new szName[32];
		new szTempid[10];
		get_players(players, pnum, "ch");
		new i = 0;
		while (i < pnum)
		{
			tempid = players[i];
			if (!is_user_alive(tempid))
			{
				get_user_name(tempid, szName, 31);
				num_to_str(tempid, szTempid, 9);
				menu_additem(menu, szName, szTempid);
			}
			i++;
		}
		page = page>menu_pages(menu)?menu_pages(menu)-1:page;
		if (!menu_items(menu))
		{
			menu_display(id, g_menu, g_page[id]);
			client_print(id,print_chat, "%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_EMPTY");
			menu_destroy(menu);
		}
		else menu_display(id, menu, page);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public live_menu(id, menu, key)
{
	if (key == MENU_EXIT)
	{
		menu_destroy(menu);
		menu_display(id, g_menu, g_page[id]);
		return;
	}
	new data[6];
	new name[64];
	new playername[33];
	new playername2[33];
	new access = 0;
	new callback = 0;
	menu_item_getinfo(menu, key, access, data, charsmax(data), name, charsmax(name), callback);
	new tempid = str_to_num(data);
	get_user_name(id, playername, 32);
	get_user_name(tempid, playername2, 32);
	ExecuteHamB(Ham_CS_RoundRespawn, tempid);
	if(is_user_alive(tempid))
	{
		client_print(0, print_chat,"%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_LIVE", playername, playername2);
		g_iRespawn[id] = -2;
	}
	new imenu = menu;
	new page;
	player_menu_info(id, imenu, imenu, page);
	liveMenu(id, page);
	menu_destroy(menu);
}


public healthMenu(id, page)
{
	if (get_user_flags(id) & ADMIN_ACCESS)
	{
		if(g_iHealth[id] <= 0) return PLUGIN_HANDLED;
		new menu = menu_create("\w[\yЗдоровье\w] Выбери игрока:", "health_menu");
		menu_setprop(menu, MPROP_EXITNAME, "Выйти");
		menu_setprop(menu, MPROP_NEXTNAME, "Далее");
		menu_setprop(menu, MPROP_BACKNAME, "Назад");
		new players[32];
		new pnum = 0;
		new tempid = 0;
		new szName[32];
		new szTempid[10];
		get_players(players, pnum, "ch");
		new i = 0;
		while (i < pnum)
		{
			tempid = players[i];
			if (is_user_alive(tempid))
			{
				get_user_name(tempid, szName, 31);
				num_to_str(tempid, szTempid, 9);
				menu_additem(menu, szName, szTempid);
			}
			i++;
		}
		page = page>menu_pages(menu)?menu_pages(menu)-1:page;
		if (!menu_items(menu))
		{
			menu_display(id, g_menu, g_page[id]);
			client_print(id, print_chat,"%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_EMPTY");
			menu_destroy(menu);
		}
		else menu_display(id, menu, page);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public health_menu(id, menu, key)
{
	if (key == MENU_EXIT)
	{
		menu_destroy(menu);
		menu_display(id, g_menu, g_page[id]);
		return;
	}
	new data[6];
	new name[64];
	new playername[33];
	new playername2[33];
	new access = 0;
	new callback = 0;
	menu_item_getinfo(menu, key, access, data, charsmax(data), name, charsmax(name), callback);
	new tempid = str_to_num(data);
	get_user_name(id, playername, 32);
	get_user_name(tempid, playername2, 32);
	set_user_health(tempid, 100);
	g_iHealth[id]--;
	menu_display(id, g_menu, g_page[id]);
	client_print(0,print_chat, "%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_HEALTH", playername, playername2);
	new imenu = menu;
	new page;
	player_menu_info(id, imenu, imenu, page);
	healthMenu(id, page);
	menu_destroy(menu);
}

public bunnyhopMenu(id, page)
{
	if (get_user_flags(id) & ADMIN_ACCESS)
	{
		new menu = menu_create("\w[\yB-HOP\w] Выбери игрока:", "bunnyhop_menu");
		menu_setprop(menu, MPROP_EXITNAME, "Выйти");
		menu_setprop(menu, MPROP_NEXTNAME, "Далее");
		menu_setprop(menu, MPROP_BACKNAME, "Назад");
		new players[32];
		new pnum = 0;
		new tempid = 0;
		new szName[32];
		new szTempid[10];
		get_players(players, pnum, "ch");
		new i = 0;
		while (i < pnum)
		{
			tempid = players[i];
			if (is_user_alive(tempid))
			{
				get_user_name(tempid, szName, 31);
				num_to_str(tempid, szTempid, 9);
				menu_additem(menu, szName, szTempid);
			}
			i++;
		}
		page = page>menu_pages(menu)?menu_pages(menu)-1:page;
		if (!menu_items(menu))
		{
			menu_display(id, g_menu, g_page[id]);
			client_print(id, print_chat,"%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_EMPTY");
			menu_destroy(menu);
		}
		else menu_display(id, menu, page);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public bunnyhop_menu(id, menu, key)
{
	if (key == MENU_EXIT)
	{
		menu_destroy(menu);
		menu_display(id, g_menu, g_page[id]);
		return;
	}
	new data[6];
	new name[64];
	new playername[33];
	new playername2[33];
	new access = 0;
	new callback = 0;
	menu_item_getinfo(menu, key, access, data, charsmax(data), name, charsmax(name), callback);
	new tempid = str_to_num(data);
	get_user_name(id, playername, 32);
	get_user_name(tempid, playername2, 32);
	bhopactive[id] = true;
	menu_display(id, g_menu, g_page[id]);
	client_print(0,print_chat, "%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_BUNNYHOP", playername, playername2);
	new imenu = menu;
	new page;
	player_menu_info(id, imenu, imenu, page);
	bunnyhopMenu(id, page);
	menu_destroy(menu);
}


public moneyMenu(id, page)
{
	if (get_user_flags(id) & ADMIN_ACCESS)
	{		
		if(g_iMoney[id] <= 0) return PLUGIN_HANDLED;
		new menu = menu_create("\w[\yДеньги\w] Выбери игрока: ", "money_menu");
		menu_setprop(menu, MPROP_EXITNAME, "Выйти");
		menu_setprop(menu, MPROP_NEXTNAME, "Далее");
		menu_setprop(menu, MPROP_BACKNAME, "Назад");
		new players[32];
		new pnum = 0;
		new tempid = 0;
		new szName[32];
		new szTempid[10];
		get_players(players, pnum, "ch");
		new i = 0;
		while (i < pnum)
		{
			tempid = players[i];
			get_user_name(tempid, szName, 31);
			num_to_str(tempid, szTempid, 9);
			menu_additem(menu, szName, szTempid);
			i++;
		}
		page = page>menu_pages(menu)?menu_pages(menu)-1:page;
		if (!menu_items(menu))
		{
			menu_display(id, g_menu, g_page[id]);
			client_print(id, print_chat,"%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_EMPTY");
			menu_destroy(menu);
		}
		else menu_display(id, menu, page);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public money_menu(id, menu, key)
{
	if (key == MENU_EXIT)
	{
		menu_destroy(menu);
		menu_display(id, g_menu, g_page[id]);
		return;
	}
	new data[6];
	new name[64];
	new playername[33];
	new playername2[33];
	new access = 0;
	new callback = 0;
	menu_item_getinfo(menu, key, access, data, charsmax(data), name, charsmax(name), callback);
	new tempid = str_to_num(data);
	get_user_name(id, playername, 32);
	get_user_name(tempid, playername2, 32);

	cs_set_user_money(tempid, cs_get_user_money(tempid) + 7000);
	g_iMoney[id]--;
	menu_display(id, g_menu, g_page[id]);
	client_print(0,print_chat, "%L %L", LANG_PLAYER, "NEW_GIVE_TAG", LANG_PLAYER, "NEW_GIVE_MONEY", playername, 7000, playername2);
	new imenu = menu;
	new page;
	player_menu_info(id, imenu, imenu, page);
	moneyMenu(id, page);
	menu_destroy(menu);
}

