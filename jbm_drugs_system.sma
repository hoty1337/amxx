/* ================================================ 
*		REMAKE 08.07.2016 - Ultimate Drugs System
*		Optimized Code
*
*		By ToJI9IHGaa
*
* ================================================ */

//////////////////////////////
#include	amxmodx			//
#include	amxmisc			//
//#include	jbe_core		//
#include	hamsandwich		//
#include	fakemeta		//
#include	fun				//
#include	cstrike			//
//////////////////////////////


#define		CREATE			"Ultimate Drugs System"
#define		BY				"vk.com/krisiso"
#define		ToJI9IHGaa		"ToJI9IHGaa"

//#pragma 	semicolon 		1

/*===========[ Нативы ]============*/
native jbm_use_drugs_model(id);
native jbm_get_duel_status();
native jbm_get_user_team(id);
native jbm_get_day_mode();
native DrugsSave(id);
/*=================================*/

public jbe_return_drugs_model(pPlayer)
{
	new iActiveItem = get_pdata_cbase(pPlayer, 373);
	if(iActiveItem > 0) ExecuteHamB(Ham_Item_Deploy, iActiveItem);
}

/*=========[ Прочее ]==============*/
#define mPref		"!y[!gDRUGS!y]"
#define MINONLINE 6

#define TASK_DRUGS_1 20001
#define	TASK_DRUGS_2 20002
#define TASK_DRUGS_3 20003
#define TASK_DRUGS_4 20004

enum _:DrugsEffects {
	TASK_GASH_EFFECT = 20111,
	TASK_SPICE_EFFECT,
 	TASK_LSD_EFFECT,
 	TASK_DRUGS_EFFECT,
 	TASK_GER_EFFECT,
 	TASK_PIZDOS
}

enum _:DrugsEffects2 {
	TASK_PEREDOZ = 21004,
	TASK_UNPEREDOZ,
	TASK_FIXSPEED,
	TASK_UNDRUGSEFF,
	TASK_ZEMLETRUS_EFF,
	TASK_SHAKE_EF,
	TASK_UN_SCR_FADE,
	TASK_SPICE_SCR_EF_RAND
}

#define TASK_MINUS_LOMKA 		21001
#define TASK_LOMAET		 		21002
#define TASK_LOMKA				21003

#define DRUGS1_MIN_HP 60
#define DRUGS1_MAX_HP 120

#define DRUGS2_MIN_HP 60
#define DRUGS2_MAX_HP 120

#define DRUGS3_MIN_HP 60
#define DRUGS3_MAX_HP 120

#define DRUGS4_MIN_HP 60
#define DRUGS4_MAX_HP 120

#define LOMKA_START		 3
#define PEREDOZ_START	 6

#define CHAR 32
#define MAX_CHAR 1024

#define LIMITPERROUND 2

/*===========[ Переменные ]=========*/
new g_iDrugs[33][4], g_iUsedDrugs[33][4]; 					// 1 - 
new g_iMt[33][4];						// 1 -
new g_iLomka[33], g_iPeredoz[33];

new g_iPayDrugs[33];
new const g_iNameDrugs[4][] = { "Гашишь", "Спайс", "ЛСД", "Героин" };
new const g_iNameMt[4][] = { "Бумага", "Ложка", "Хим. Смесь", "Семена Конопли" };

new const g_iAllTask[7] = { TASK_LOMAET, TASK_PEREDOZ, TASK_GASH_EFFECT, TASK_SPICE_EFFECT, TASK_LSD_EFFECT,
TASK_DRUGS_EFFECT, TASK_GER_EFFECT };

/*==================================*/

public plugin_init()
{

	register_plugin(	CREATE, BY, ToJI9IHGaa		);
	menu_init();
	register_clcmd("say /drugs", "Show_MenuDrugs");

	RegisterHam(Ham_Spawn, "player", "HamSpawn_Post", true);
	
	register_event( "DeathMsg", "MSG_DeathHook", "a");
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	
}

public LogEvent_RoundStart()
{
	for(new i = 1; i < get_maxplayers(); i++)
	{
		if(!is_user_connected(i)) continue;
		for(new j = TASK_GASH_EFFECT; j < TASK_GASH_EFFECT + DrugsEffects; j++)
		{
			if(task_exists(i + j))
			{
				remove_task(i + j);
			}
		}
		for(new j = TASK_PEREDOZ; j < TASK_PEREDOZ + DrugsEffects2; j++)
		{
			if(task_exists(i + j))
			{
				remove_task(i + j);
			}
		}
		UTIL_ScreenFade(i, 0, 0, 0, 0, 0, 0, 0, 1);
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SetFOV"), _, i);
		write_byte(0);
		message_end();
	}
}

public MSG_DeathHook()
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	if(!is_user_connected(iVictim)) return PLUGIN_HANDLED;
	for(new i; i <= 6; i++) remove_task(iVictim + g_iAllTask[i]);
	if(!is_user_connected(iVictim) || iVictim == 0 || jbm_get_user_team(iVictim) != 2) return PLUGIN_HANDLED;
	new Name_Victim[CHAR]; get_user_name(iVictim, Name_Victim, charsmax(Name_Victim));
	if(get_playersnum() < MINONLINE) return PLUGIN_HANDLED;
	new iRandom[3];
	iRandom[0] = random_num(1, 3);
	iRandom[1] = random_num(0, 3);
	iRandom[2] = random_num(1, 5);
	switch(iRandom[0])
	{
		case 1:
		{
			chat(iKiller, "%s Вы получили !t%d шт. !g%s!y за убийство !g%s", mPref, iRandom[2], g_iNameMt[iRandom[1]], Name_Victim);
			g_iMt[iKiller][iRandom[1]] += iRandom[2];
		}
		//case 2:
		//{
		//	chat(iKiller, "%s Вы получили !t%d шт. !g%s!y за убийство !g%s", mPref, iRandom[2], g_iNameDrugs[iRandom[1]], Name_Victim);
		//	g_iDrugs[iKiller][iRandom[1]] += iRandom[2];
		//}
	}
	return PLUGIN_HANDLED;
}

public HamSpawn_Post(id)
{
	if(!is_user_connected(id)) return;
	for(new i; i < 4; i++) g_iUsedDrugs[id][i] = 0;
	if(get_playersnum() < MINONLINE) return;
	new iRandom[3];
	iRandom[0] = random_num(1, 3);
	iRandom[1] = random_num(0, 3);
	iRandom[2] = random_num(1, 3);
	switch(iRandom[0])
	{
		case 1:
		{
			chat(id, "%s Проснувшись, Вы нашли на полу !t%d шт. !g%s!y", mPref, iRandom[2], g_iNameMt[iRandom[1]]);
			g_iMt[id][iRandom[1]] += iRandom[2];
			DrugsSave(id);
		}
	}
}


/* =============================
	Инит Менюх
=============================== */

menu_init()
{
	register_menucmd(register_menuid("Show_MenuDrugs"), 1023, "Handle_MenuDrugs");
	register_menucmd(register_menuid("Show_MenuInv"), 1023, "Handle_MenuInv");
	register_menucmd(register_menuid("Show_MenuPay"), 1023, "Handle_MenuPay");
	register_menucmd(register_menuid("Show_MenuCraft"), 1023, "Handle_MenuCraft");
}

/* =============================
	Нативы
=============================== */

public plugin_natives()
{
	register_native("Open_DrugsMenu", "Show_MenuDrugs", 1);
	
	register_native("jbm_get_drugs", "jbm_get_drugs", 1);
	register_native("jbm_set_drugs", "jbm_set_drugs", 1);
	
	register_native("jbm_get_material", "jbm_get_material", 1);
	register_native("jbm_set_material", "jbm_set_material", 1);
}

public jbm_get_drugs(id, iDrugs)			// 1 - "Гашишь", 2 - "Спайс", 3 - "ЛСД", 4 - "Героин"
{
	iDrugs -= 1;
	if(iDrugs < 0 || iDrugs > 3) return PLUGIN_HANDLED;
	return g_iDrugs[id][iDrugs];
}
public jbm_set_drugs(id, iDrugs, iNum)
{
	iDrugs -= 1;
	if(iDrugs < 0 || iDrugs > 3) return PLUGIN_HANDLED;
	g_iDrugs[id][iDrugs] = iNum;
	return PLUGIN_HANDLED;
}
public jbm_get_material(id, iMaterial)		// 1 - "Бумага", 2 - "Ложка", 3 - "Хим Смесь", 4 - "Семена"
{
	iMaterial -= 1;
	if(iMaterial < 0 || iMaterial > 3) return PLUGIN_HANDLED;
	return g_iMt[id][iMaterial];
}
public jbm_set_material(id, iMaterial, iNum)
{
	iMaterial -= 1;
	if(iMaterial < 0 || iMaterial > 3) return PLUGIN_HANDLED;
	g_iMt[id][iMaterial] = iNum;
	return PLUGIN_HANDLED;
}

/* =============================
	Главное Меню Наркотиков
=============================== */

public Show_MenuDrugs(id)
{	
	if( !is_user_alive(id) )
	{
		chat(id, "%s Доступно только для !gЖивых.", mPref);
		return PLUGIN_HANDLED;
	}
	else if( jbm_get_day_mode() == 3 )
	{
		chat(id, "%s В !gигровые дни!y - !tDrugs !gнедоступно.", mPref);
		return PLUGIN_HANDLED;
	}
	else if( jbm_get_user_team(id) > 2 )
	{
		chat(id, "%s !tСпектаторам !gнельзя открывать !yсистему наркотиков.", mPref);
		return PLUGIN_HANDLED;
	}
	else if( jbm_get_duel_status() != 0 )
	{
		chat(id, "%s Во время дуэли нельзя !gоткрывать данное меню", mPref);
		return PLUGIN_HANDLED;
	}
	
	
	static menu[MAX_CHAR], len; len = 0;
	
	new iKeys = (1<<0|1<<1|1<<2|1<<9);
	
	len = formatex(menu[len], charsmax(menu) - len, "\yМеню Наркотиков^n^n");
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wИнвентарь^n" );
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wСварить \rНаркотик^n" );
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wПередать \rНаркотики^n^n" );
	if(get_user_flags(id) & ADMIN_RCON)
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r[5]\w Взять \r100 всех материалов.^n^n" );
		iKeys |= (1<<4);
	}	
	len += formatex(menu[len], charsmax(menu) - len, "\y[0]\w Выход^n^n");
	
	return show_menu(id, iKeys, menu, -1, "Show_MenuDrugs");	
}

public Handle_MenuDrugs(id, iKey)
{
	switch(iKey)
	{
		case 0: Show_MenuInv(id);
		case 1: Show_MenuCraft(id);
		case 2: Show_MenuPay(id);
		case 4: 
		{
			for(new i = 0; i <= 3; i++)
			{
				g_iDrugs[id][i] = 100;
				g_iMt[id][i] = 100;
			}
		}
		case 9: return;
	}	
}

/* =========================================
	Инвентарь и использование Наркотиков
============================================ */
public Show_MenuInv(id)
{
	static menu[MAX_CHAR], len; len = 0;
	
	new iKeys = (1<<9);
	
	new pl_Drugs = g_iDrugs[id][0] + g_iDrugs[id][1] + g_iDrugs[id][2] + g_iDrugs[id][3];
	
	for(new i; i <= 3; i++)
	{
		if(g_iDrugs[id][i] >= 1 && g_iUsedDrugs[id][i] < LIMITPERROUND) iKeys |= (1<<i);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "\yИнвентарь^n\wВсего наркотиков: \r[%d]^n^n", pl_Drugs);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] %sИспользовать \rГашишь \y[%d] %s^n", (g_iDrugs[id][0] >= 1 && !g_iUsedDrugs[id][0]) ? "\w":"\d", g_iDrugs[id][0], g_iUsedDrugs[id][0] ? "\d[использовано]" : "" );
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] %sИспользовать \rСпайс \y[%d] %s^n", (g_iDrugs[id][1] >= 1 && !g_iUsedDrugs[id][1]) ? "\w":"\d", g_iDrugs[id][1], g_iUsedDrugs[id][1] ? "\d[использовано]" : ""  );
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] %sИспользовать \rЛСД \y[%d] %s^n", (g_iDrugs[id][2] >= 1 && !g_iUsedDrugs[id][2]) ? "\w":"\d", g_iDrugs[id][2], g_iUsedDrugs[id][2] ? "\d[использовано]" : ""  );
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] %sИспользовать \rГероин \y[%d] %s^n^n", (g_iDrugs[id][3] >= 1 && !g_iUsedDrugs[id][3]) ? "\w":"\d", g_iDrugs[id][3], g_iUsedDrugs[id][3] ? "\d[использовано]" : ""  );

	len += formatex(menu[len], charsmax(menu) - len, "\y[0]\w Назад^n^n");
	
	return show_menu(id, iKeys, menu, -1, "Show_MenuInv");	
}

public Handle_MenuInv(id, iKey)
{
	if(iKey <= 3)
	{
		if(g_iUsedDrugs[id][iKey]) return Show_MenuInv(id);
		jbm_use_drugs_model(id);
		plus_lomka(id);
		g_iDrugs[id][iKey]--;
		g_iUsedDrugs[id][iKey]++;
		plus_peredoz(id);
		DrugsSave(id);
	}
	switch(iKey)
	{
		case 0: set_task(4.0, "use_drugs_1", id + TASK_DRUGS_1);
		case 1: set_task(4.0, "use_drugs_2", id + TASK_DRUGS_2);
		case 2: set_task(4.0, "use_drugs_3", id + TASK_DRUGS_3);
		case 3: set_task(4.0, "use_drugs_4", id + TASK_DRUGS_4);
		case 9: return Show_MenuDrugs(id);
	}
	set_task(60.0, "Minus_Lomka", id + TASK_MINUS_LOMKA, "b");	
	return Show_MenuInv(id);
}
/* =============================
	Меню Крафта Наркотиков
=============================== */

public Show_MenuCraft(id)
{
	static menu[MAX_CHAR], len; len = 0;
	new iKeys = (1<<9);
	new bool:bool_key[33][4];
	
	if(g_iMt[id][0] >= 1 && g_iMt[id][1] >= 1 && g_iMt[id][3] >= 2)
	{
		bool_key[id][0] = true;
		iKeys |= (1<<0);
	}
	if(g_iMt[id][0] >= 2 && g_iMt[id][1] >= 2 && g_iMt[id][2] >= 3 && g_iMt[id][3] >= 2) 
	{	
		bool_key[id][1] = true;
		iKeys |= (1<<1);
	}
	if(g_iMt[id][0] >= 3 && g_iMt[id][1] >= 1 && g_iMt[id][2] >= 3 && g_iMt[id][3] >= 2)
	{
		bool_key[id][2] = true;
		iKeys |= (1<<2);
	}
	if(g_iMt[id][0] >= 4 && g_iMt[id][1] >= 3 && g_iMt[id][2] >= 4 && g_iMt[id][3] >= 2) 
	{	
		bool_key[id][3] = true;
		iKeys |= (1<<3);
	}
	
	len = formatex(menu[len], charsmax(menu) - len, "^t^t\yBreaking Bad^n^n");
	
	len += formatex(menu[len], charsmax(menu) - len, "\dБумага:\r %d^n", g_iMt[id][0]);
	len += formatex(menu[len], charsmax(menu) - len, "\dЛожка:\r %d^n", g_iMt[id][1]);
	len += formatex(menu[len], charsmax(menu) - len, "\dХим. Смесь:\r %d^n", g_iMt[id][2]);
	len += formatex(menu[len], charsmax(menu) - len, "\dСемена К.:\r %d^n^n", g_iMt[id][3]);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] %sВысушить \yGash \d[Б:1|Л:1|Х:0|С:2]\R\y[%d]^n", bool_key[id][0] ? "\w":"\d", g_iDrugs[id][0]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] %sВымочить \yСпайс \d[Б:2|Л:2|Х:3|С:2]\R\y[%d]^n", bool_key[id][1] ? "\w":"\d", g_iDrugs[id][1]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] %sСинтезировать \yLSD \d[Б:3|Л:1|Х:3|С:2]\R\y[%d]^n", bool_key[id][2] ? "\w":"\d", g_iDrugs[id][2]);
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] %sСинтезировать \yГероин \d[Б:4|Л:3|Х:4|С:2]\R\y[%d]^n^n", bool_key[id][3] ? "\w":"\d", g_iDrugs[id][3]);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[0]\w Назад^n");
	return show_menu(id, iKeys, menu, -1, "Show_MenuCraft");
}

public Handle_MenuCraft(id, iKey)
{
	new szRandomsize = random_num(1,2);
	switch(iKey)
	{
		case 0:
		{
			g_iMt[id][0]--;
			g_iMt[id][1]--;
			g_iMt[id][3] -= 2;
			if(szRandomsize == 1)
			{
				g_iDrugs[id][0]++;
				chat(id, "%s Вы успешно высушили !gGash", mPref);
			}else chat(id, "%s Что-то пошло не так, !tу вас не получилось сделать !gнаркотик.", mPref);
			DrugsSave(id);
		}
		case 1:
		{
			g_iMt[id][0] -= 2;
			g_iMt[id][1] -= 2;
			g_iMt[id][2] -= 3;
			g_iMt[id][3] -= 2;
			if(szRandomsize == 1)
			{
				g_iDrugs[id][1]++;
				chat(id, "%s Вы успешно вымочили !gСпайс", mPref);
			}else chat(id, "%s Что-то пошло не так, !tу вас не получилось сделать !gнаркотик.", mPref);
			DrugsSave(id);
		}
		case 2:
		{
			g_iMt[id][0] -= 3;
			g_iMt[id][1] -= 1;
			g_iMt[id][2] -= 3;
			g_iMt[id][3] -= 2;
			if(szRandomsize == 1)
			{
				g_iDrugs[id][2]++;
				chat(id, "%s Вы успешно синтезировали !gЛСД", mPref);
			}else chat(id, "%s Что-то пошло не так, !tу вас не получилось сделать !gнаркотик.", mPref);
			DrugsSave(id);
		}
		case 3:
		{
			g_iMt[id][0] -= 4;
			g_iMt[id][1] -= 3;
			g_iMt[id][2] -= 4;
			g_iMt[id][3] -= 2;
			if(szRandomsize == 1)
			{
				g_iDrugs[id][3]++;
				chat(id, "%s Вы успешно синтезировали !gГероин", mPref);
			}else chat(id, "%s Что-то пошло не так, !tу вас не получилось сделать !gнаркотик.", mPref);
			DrugsSave(id);
		}
		case 9: return Show_MenuDrugs(id);
	}
	return Show_MenuCraft(id);
}

/* =============================
	Меню Передачи наркотиков
=============================== */

public Show_MenuPay(id)
{
	static menu[MAX_CHAR], len; len = 0;
	
	new iKeys = (1<<9);
	
	new pl_Drugs = g_iDrugs[id][0] + g_iDrugs[id][1] + g_iDrugs[id][2] + g_iDrugs[id][3];
	
	for(new i; i <= 3; i++)
	{
		if(g_iDrugs[id][i] >= 1) iKeys |= (1<<i);
	}
	len = formatex(menu[len], charsmax(menu) - len, "\yПередача Наркоты^n\wВсего наркотиков: \r[%d]^n^n", pl_Drugs);
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] %sПередать \rГашишь \R\y[%d]^n", (g_iDrugs[id][0] >= 1) ? "\w":"\d", g_iDrugs[id][0] );
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] %sПередать \rСпайс \R\y[%d]^n", (g_iDrugs[id][1] >= 1) ? "\w":"\d", g_iDrugs[id][1] );
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] %sПередать \rЛСД \R\y[%d]^n", (g_iDrugs[id][2] >= 1) ? "\w":"\d", g_iDrugs[id][2] );
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] %sПередать \rГероин \R\y[%d]^n^n", (g_iDrugs[id][3] >= 1) ? "\w":"\d", g_iDrugs[id][3] );

	len += formatex(menu[len], charsmax(menu) - len, "\y[0]\w Назад^n^n");
	
	return show_menu(id, iKeys, menu, -1, "Show_MenuPay");	
}

public Handle_MenuPay(id, iKey)
{
	if(iKey == 9) return Show_MenuDrugs(id);
	g_iPayDrugs[id] = iKey;
	pay_drugs(id);
	return PLUGIN_CONTINUE;
}

/* =============================
	Передача Наркотиков
=============================== */

public pay_drugs(id)
{
	new szDrugsName[CHAR];
	formatex(szDrugsName, charsmax(szDrugsName), "Кому передать \r%s\w?", g_iNameDrugs[g_iPayDrugs[id]]);
	new i_Menu = menu_create(szDrugsName, "Handle_PayDrugs");

	new s_Players[32], 
		i_Num, 
		i_Player, 
		msg[222];
		
	new s_Name[CHAR], 
		s_Player[10];
		
	get_players(s_Players, i_Num);
	for (new i; i < i_Num; i++)
	{ 
		i_Player = s_Players[i];
		get_user_name(i_Player, s_Name, charsmax(s_Name));
		num_to_str(i_Player, s_Player, charsmax(s_Player));
		if(is_user_alive(i_Player))
		{
			formatex(msg, charsmax(msg), "\y%s \R\d[\r%d\d]", s_Name, g_iDrugs[i_Player][g_iPayDrugs[id]]);
			menu_additem(i_Menu, msg, s_Player, 0);
		}
		menu_setprop(i_Menu, MPROP_NEXTNAME, "Дальше");
		menu_setprop(i_Menu, MPROP_BACKNAME, "Назад");
		menu_setprop(i_Menu, MPROP_EXITNAME, "Выйти");
	}
	menu_display(id, i_Menu, 0);
}

public Handle_PayDrugs(id, menu, item)
{
    if (item == MENU_EXIT)
    {
	   menu_destroy(menu);
	   return PLUGIN_HANDLED;
    }
    new s_Data[6], 
		s_Name[64], 
		i_Access, 
		i_Callback;
		
    menu_item_getinfo(menu, item, i_Access, s_Data, charsmax(s_Data), s_Name, charsmax(s_Name), i_Callback);
	
    new i_Player = str_to_num(s_Data);
    new name[CHAR], name2[CHAR];
    get_user_name(id, name, 31);
    get_user_name(i_Player, name2, 31);
    if(id == i_Player) pay_drugs(id);
    else
    {
		g_iDrugs[i_Player][g_iPayDrugs[id]] += 1;
		g_iDrugs[id][g_iPayDrugs[id]] -= 1;
		chat(0, "%s Игрок !g%s!y передал 1 штуку !g%s!y: !t%s", mPref, name, name2, g_iNameDrugs[g_iPayDrugs[id]]);
		DrugsSave(id);
		Show_MenuPay(id);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
/* =============================
	Использование Наркотиков
=============================== */
public UnScrEffectS(id)
{
	id -= TASK_UN_SCR_FADE;
	UTIL_ScreenFade(id, 0, 0, 0, 0, 0, 0, 0, 1);
}
public UnDrugs_Effect(id)
{
	id -= TASK_DRUGS_EFFECT;
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SetFOV"), _, id);
	write_byte(0);
	message_end();
}

public Effect_DrugsView(id)
{
	id -= TASK_PIZDOS;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SetFOV"), _, id);
	write_byte(170);
	message_end();
}
public Player_SetShake(pId)
{
	if( !is_user_alive(pId) || jbm_get_day_mode() == 3 || jbm_get_user_team(pId) > 2 || jbm_get_duel_status() != 0 ) return;
	message_begin(MSG_ONE_UNRELIABLE, 97, _, pId);
	write_short(1<<14);
	write_short(1<<14);
	write_short(1<<14);
	message_end();
	
	set_task(2.5, "Task_PlayerShake", pId + TASK_SHAKE_EF, _, _, "b");
}

public Task_PlayerShake(pId)
{
	pId -= TASK_SHAKE_EF;
	if( !is_user_alive(pId) || jbm_get_day_mode() == 3 || jbm_get_user_team(pId) > 2 || jbm_get_duel_status() != 0 ) return;
	message_begin(MSG_ONE_UNRELIABLE, 97, _, pId);
	write_short(1<<14);
	write_short(1<<14);
	write_short(1<<14);
	message_end();
}

///////////////////////////////////////////
public use_drugs_1(id)
{
	id -= TASK_DRUGS_1;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	jbe_return_drugs_model(id);
	set_user_health(id, get_user_health(id) + random_num(DRUGS1_MIN_HP, DRUGS1_MAX_HP));
	set_task(3.0, "Gash_Effect", id + TASK_GASH_EFFECT, _,_, "a", random_num(7,10));
	set_task(20.0, "UnScrEffectS", id + TASK_UN_SCR_FADE);
	if(g_iLomka[id] >= LOMKA_START) remove_task(id + TASK_LOMAET);
}

public Gash_Effect(id)
{
	id -= TASK_GASH_EFFECT;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	set_pev(id, pev_punchangle, { 350.0, 500.0, 200.0 });
	UTIL_ScreenFade(id, 0, 0, 4, 255, 0, 0, 100, 1);	
}
///////////////////////////////////////////
public use_drugs_2(id)
{
	id -= TASK_DRUGS_2;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	jbe_return_drugs_model(id);
	set_user_health(id, get_user_health(id) + random_num(DRUGS2_MIN_HP, DRUGS2_MAX_HP));
	set_task(5.0, "Spice_Effect", id + TASK_SPICE_EFFECT, _,_, "a", random_num(7,14));
	set_task(20.0, "UnScrEffectS", id + TASK_UN_SCR_FADE);
	if(g_iLomka[id] >= LOMKA_START)remove_task(id + TASK_LOMAET);
}

public Spice_Effect(id)
{
	id -= TASK_SPICE_EFFECT;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	set_pev(id, pev_punchangle, { 550.0, 600.0, 300.0 });
	set_task(1.0, "Spice_ClScr", id + TASK_SPICE_SCR_EF_RAND, _, _, "a", 4);
}
public Spice_ClScr(id)
{
	id -= TASK_SPICE_SCR_EF_RAND;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	UTIL_ScreenFade(id, 4, 0, 4, random(255), random(255), random(255), 100, 0);
}
///////////////////////////////////////////
public use_drugs_3(id)
{
	id -= TASK_DRUGS_3;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	jbe_return_drugs_model(id);
	set_task(20.0, "UnScrEffectS", id + TASK_UN_SCR_FADE);
	set_user_health(id, get_user_health(id) + random_num(DRUGS3_MIN_HP, DRUGS3_MAX_HP));
	set_task(1.0, "LSD_Effect", id + TASK_LSD_EFFECT, _,_,"a", random_num(7,12));
	set_task(20.0, "UnDrugs_Effect", id + TASK_DRUGS_EFFECT);
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SetFOV"), _, id);
	write_byte(170);
	message_end();
	
	if(g_iLomka[id] >= LOMKA_START)remove_task(id + TASK_LOMAET);
}

public LSD_Effect(id)
{
	id -= TASK_LSD_EFFECT;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	UTIL_ScreenFade(id, 0, 0, 4, 255, 0, 0, 100, 1);	
	set_pev(id, pev_punchangle, { 700.0, 700.0, 400.0 });
}
///////////////////////////////////////////

public use_drugs_4(id)
{
	id -= TASK_DRUGS_4;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	jbe_return_drugs_model(id);
	set_user_health(id, get_user_health(id) + random_num(DRUGS4_MIN_HP, DRUGS4_MAX_HP));
	new iCount = random_num(3,4)
	set_task(4.0, "Ger_Effect", id + TASK_GER_EFFECT, _,_, "a", iCount);
	set_task(iCount * 4.0, "UnScrEffectS", id + TASK_UN_SCR_FADE);
	pizdos(id);
	Player_SetShake(id);
	set_task(15.0, "UnZemletrusEff", id + TASK_ZEMLETRUS_EFF);
	if(g_iLomka[id] >= LOMKA_START) remove_task(id + TASK_LOMAET);
}
public UnZemletrusEff(id)
{
	id -= TASK_ZEMLETRUS_EFF;
	remove_task(id + TASK_SHAKE_EF);
}
public Ger_Effect(id)
{
	id -= TASK_LSD_EFFECT;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	UTIL_ScreenFade(id, 0, 0, 4, 255, 0, 0, 100, 1);
	set_pev(id, pev_punchangle, { 900.0, 900.0, 600.0 });
}

public pizdos(id)
{
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	set_task(3.0, "ToGoUnDr_Eff", id + TASK_UNDRUGSEFF);
	set_task(3.0, "Effect_DrugsView", id + TASK_PIZDOS, _,_,"a", 4);
}
public ToGoUnDr_Eff(id)
{
	id -= TASK_UNDRUGSEFF;
	set_task(3.0, "UnDrugs_Effect", id + TASK_DRUGS_EFFECT, _,_,"a", 5);
	UTIL_ScreenFade(id, 4, 0, 4, random(255), random(255), random(255), 100, 0);
}
/* =============================
	Ломка
=============================== */

public Minus_Lomka(id)
{
	id -= TASK_MINUS_LOMKA;
	if(g_iLomka[id] > 0) g_iLomka[id]--;
	if(g_iPeredoz[id] > 0)g_iPeredoz[id]--;
}

public plus_lomka(id)
{
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	g_iLomka[id]++;
	if(g_iLomka[id] >= LOMKA_START)
	{
		remove_task(id + TASK_MINUS_LOMKA);
		remove_task(id + TASK_LOMKA);
		set_task(120.0, "Func_Lomka", id + TASK_LOMKA, _,_,"b");
	}
}

public plus_peredoz(id)
{
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	g_iPeredoz[id]++;
	if(g_iPeredoz[id] >= PEREDOZ_START)
	{
		g_iPeredoz[id] = 0;
		Func_Peredoz(id);
	}
}

public Func_Peredoz(id)
{
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	drop_user_weapons(id, 0);
	drop_user_weapons(id, 1);
	set_user_maxspeed(id, 0.0);
	set_task(1.0, "FixSpeed", id + TASK_FIXSPEED, _, _, "b");
	set_task(4.0, "Peredoz_Func", id + TASK_PEREDOZ, _,_,"b");
	set_task(10.0, "UnPeredoz", id + TASK_UNPEREDOZ);
}
public FixSpeed(id)
{
	id -= TASK_FIXSPEED;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	if(task_exists(id + TASK_PEREDOZ)) set_user_maxspeed(id, 0.0);
	else remove_task(id + TASK_FIXSPEED);
}
public UnPeredoz(id)
{
	id -= TASK_UNPEREDOZ;
	remove_task(id + TASK_PEREDOZ);
}

public Peredoz_Func(id)
{
	id -= TASK_PEREDOZ;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	if(get_user_health(id) >= 5) set_user_health(id, get_user_health(id) - random_num(5, 10));
	else user_kill(id);
	UTIL_ScreenFade(id, 0, 0, 4, 255, 0, 0, 100, 1);
	set_pev(id, pev_punchangle, { 700.0, 700.0, 400.0 });	
}

public Func_Lomka(id)
{
	id -= TASK_LOMKA;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	chat(id, "%s У вас !gломка!!y Примите !gнаркотики", mPref);
	set_task(3.0, "Lomaet_pzd", id + TASK_LOMAET, _,_,"b");
}

public Lomaet_pzd(id)
{
	id -= TASK_LOMAET;
	if( !is_user_alive(id) || jbm_get_day_mode() == 3 || jbm_get_user_team(id) > 2 || jbm_get_duel_status() != 0 ) return;
	if(get_user_health(id) != 1) set_user_health(id, get_user_health(id) - 1);
	UTIL_ScreenFade(id, 4, 0, 4, 255, 0, 0, 100, 0);	
	set_pev(id, pev_punchangle, { 10.0, 20.0, 40.0 });
}

/* =============================
	Стоки Функций
=============================== */

stock chat(const id, const input[], any:...)
{
	new count = 1, players[32], msg[191]; vformat(msg, 190, input, 3)
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	if(id)players[0] = id; else get_players(players, count, "ch")
	{
		for(new i = 0; i < count; i++)
		{
			if(is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i])
				write_string(msg)
				message_end()
			}
		}
	}
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
BloodEffect(origin[3])
{
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
	
	write_byte(TE_BLOODSTREAM);
	
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2] + 30);
	write_coord(random_num(-20, 20));
	write_coord(random_num(-20, 20));
	write_coord(random_num(50, 300));
	write_byte(70);
	write_byte(random_num(100, 200));
	message_end();
	return PLUGIN_HANDLED;
}

stock UTIL_ScreenFade(pPlayer, iDuration, iHoldTime, iFlags, iRed, iGreen, iBlue, iAlpha, iReliable = 0)
{
	switch(pPlayer)
	{
		case 0:
		{
			message_begin(iReliable ? MSG_ALL : MSG_BROADCAST, 98);
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
			engfunc(EngFunc_MessageBegin, iReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, 98, {0.0, 0.0, 0.0}, pPlayer);
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
	new CoordOrigin[3];
	get_user_origin(pPlayer, CoordOrigin);
	return BloodEffect(CoordOrigin);
}
