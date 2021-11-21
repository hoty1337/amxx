#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < cstrike >
#include < zombieplague >

native zp_get_user_lvl(id) 
native zp_set_user_lvl(id, set)
native zp_get_user_token(id)
native zp_set_user_token(id, set)
native zp_get_user_exp(id) 
native zp_set_user_exp(id, set) 
native zp_buy_random_item(id) 
native zp_give_pipe_bomb(id)
native zp_color_menu(id)

new g_armor_count[33], g_health_count[33], g_money_count[33], g_boss_count[33], g_ruletka_count[33], g_make_count[33], g_pipe_count[33], g_bolts_count[33], g_exp_count[33]
new g_weapon_count[33][3], g_weapon_count2[33][3], g_weapon_count3[33][4]
new g_szPrivilege[33][32], g_szDate[33][32]
new g_szMenu_give[33]

new g_menu_data[33]
#define MENU_PAGE_PLAYERS g_menu_data[id]

#pragma tabsize 0

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_0
const KEYSMENU2 = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_0
public plugin_init() {
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")

	register_menu("ADMIN Menu", KEYSMENU, "menu_admin")
	register_menu("Admin Weapons Menu", KEYSMENU, "menu_gold_weap_admin")
	register_menu("VIP Menu", KEYSMENU, "menu_vip")
	register_menu("Gold Weapons Menu", KEYSMENU, "menu_gold_weap_vip")
	register_menu("BOSS Menu", KEYSMENU, "menu_boss")
	register_menu("Boss Weapons Menu", KEYSMENU, "menu_gold_weap_boss")	
	register_menu("PREMIUM Menu", KEYSMENU, "menu_premium")	
	register_menu("PREMIUM Weapons Menu", KEYSMENU, "menu_gold_weap_prem")		
	register_menu("Give Menu", KEYSMENU2, "menu_give")	
	register_menu("Ruletka Menu", KEYSMENU, "menu_ruletka")
}

public event_round_start()
{
	for (new id = 1; id <= 32; id++) 
	{
		if(is_user_connected(id)){
			if(g_weapon_count[id][0] > 0 ) g_weapon_count[id][0] -= 1
			g_weapon_count2[id][0]=0
			g_weapon_count2[id][1]=0
			g_weapon_count3[id][0]=0
			g_weapon_count3[id][1]=0
			g_weapon_count3[id][2]=0
			g_weapon_count[id][1]=0
			g_armor_count[id]=0
			g_health_count[id]=0
			if(g_pipe_count[id] > 0 ) g_pipe_count[id] -= 1
		}
	}
}

public client_putinserver(id)
{
		if(get_user_flags(id) & ADMIN_SLAY) formatex(g_szPrivilege[id], 31, "Создатель")
		else if(get_user_flags(id) & ADMIN_LEVEL_D) formatex(g_szPrivilege[id], 31, "BOSS")
		else if(get_user_flags(id) & ADMIN_BAN) formatex(g_szPrivilege[id], 31, "ADMIN")
		else if(get_user_flags(id) & ADMIN_LEVEL_G) formatex(g_szPrivilege[id], 31, "PREMIUM")
		else if(get_user_flags(id) & ADMIN_LEVEL_A) formatex(g_szPrivilege[id], 31, "VIP")
		else formatex(g_szPrivilege[id], 31, "Игрок")	
}

public plugin_natives() {
   register_native("show_admin_menu","native_show_admin",1)
   register_native("show_vip_menu","native_show_vip",1)	  
   register_native("show_boss_menu","native_show_boss",1)
   register_native("show_ad_menu1","native_show_ad",1)
   register_native("show_ruletka_menu","native_show_ruletka",1)
   register_native("show_prem_menu","native_show_prem",1)
}

public native_show_admin(id) show_privilege_menu(id)
public native_show_vip(id) show_privilege_menu_vip(id)
public native_show_boss(id) show_privilege_menu_boss(id)
public native_show_prem(id) show_privilege_menu_prem(id)
public native_show_ad(id) show_ad_menu(id)
public native_show_ruletka(id) show_ruletka_menu(id)

public show_privilege_menu(id) {
	static menu[512]
	new len
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wАдмин меню - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yАдмин оружие^n^n")
	
	if(g_armor_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	
	if(g_health_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dВзять жизни \r[+200] \r[%d|1]^n", g_health_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wВзять жизни \r[+200] \r[%d|1]^n", g_health_count[id])
	
	if(g_money_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dВзять аммо \r[+100] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wВзять аммо \r[+100] \r[%d|1]^n", g_money_count[id])	
	
	if(g_bolts_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dВзять болты \r[+4] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wВзять болты \r[+4] \r[%d|1]^n", g_bolts_count[id])	
	
	if(g_exp_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dВзять опыт \r[+2] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wВзять опыт \r[+2] \r[%d|1]^n", g_exp_count[id])	
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "ADMIN Menu")
}

public menu_admin(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>5) return
	
	if(key==0){
		show_gold_weapons_menu_admin(id)
		return
	}
	
	switch(key) {
		case 1: {
			if(g_armor_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu(id)
				return
			}
			new Float:ap
			pev(id, pev_armorvalue, ap)
			
			if(ap >= 300.0){
				client_printcolor(id, "^x04[ZP]^x01 Нельзя взять броню! Лимит брони: ^x04 300")
				return
			}
			
			set_pev(id, pev_armorvalue, ap+100.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Броню!")
			g_armor_count[id]++
			show_privilege_menu(id)
		}
		case 2: {
			if(g_health_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu(id)
				return
			}
			new Float:hp
			pev(id, pev_health, hp)
			set_pev(id, pev_health, hp+200.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Здоровье!")
			g_health_count[id]++
			show_privilege_menu(id)
		}
		case 3: {
			if(g_money_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu(id)
				return
			}
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id)+100)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Аммо!")
			g_money_count[id] += 60
			show_privilege_menu(id)
		}
		case 4: {
			if(g_bolts_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu(id)
				return
			}
			zp_set_user_token(id, zp_get_user_token(id)+4)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Болты!")
			g_bolts_count[id] += 60
			show_privilege_menu(id)
		}
		case 5: {
			if(g_exp_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu(id)
				return
			}
			zp_set_user_exp(id, zp_get_user_exp(id)+2)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Опыт!")
			g_exp_count[id] += 60
			show_privilege_menu(id)
		}
	}
}

show_gold_weapons_menu_admin(id) {
	static menu[512]
	new len
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wАдмин оружие - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	if(g_weapon_count[id][0])
		len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dJetpack \r[%d|5]^n", g_weapon_count[id][0])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yJetpack \r[%d|5]^n", g_weapon_count[id][0])
	
	if(g_weapon_count[id][1])
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dRPG-7 \r[1|1]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \yRPG-7 \r[0|1]^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "Admin Weapons Menu")
}

native give_jet_pack(id)
native boss_give_rpg7(id)

public menu_gold_weap_admin(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>2) return

	if(g_weapon_count[id][key]>=1) {
		client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
		return
	}
	g_weapon_count[id][key] += 5
		
	switch(key) {
		case 0: give_jet_pack(id)
        case 1: boss_give_rpg7(id)
	}
	show_gold_weapons_menu_admin(id)
}

show_privilege_menu_prem(id) {
	static menu[512]
	new len
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПремиум меню - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yПремиум оружие^n^n")
	
	if(g_armor_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	
	if(g_health_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dВзять жизни \r[+100] \r[%d|1]^n", g_health_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wВзять жизни \r[+100] \r[%d|1]^n", g_health_count[id])
	
	if(g_money_count[id]>=5)
		len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dВзять аммо \r[+75 Аммо] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wВзять аммо \r[+75 Аммо] \r[%d|1]^n", g_money_count[id])
	
	if(g_bolts_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dВзять болты \r[+3] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wВзять болты \r[+3] \r[%d|1]^n", g_bolts_count[id])	
	
	if(g_make_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dСтать Героем \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wСтать \yГероем^n")	

	if(g_make_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[7] \dCтать Дьяволом \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[7] \wСтать \yДьволом^n")	

	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "PREMIUM Menu")
}

public menu_premium(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>7) return
	
	if(key==0){
		show_gold_weapons_menu_prem(id)
		return
	}
	
	switch(key) {
		case 1: {
			if(g_armor_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_prem(id)
				return
			}
			new Float:ap
			pev(id, pev_armorvalue, ap)
			
			if(ap >= 300.0){
				client_printcolor(id, "^x04[ZP]^x01 Нельзя взять броню! Лимит брони: ^x04 300")
				return
			}			
			
			set_pev(id, pev_armorvalue, ap+100.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Броню!")
			g_armor_count[id]++
			show_privilege_menu_prem(id)
		}
		case 2: {
			if(g_health_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_prem(id)
				return
			}
			new Float:hp
			pev(id, pev_health, hp)
			set_pev(id, pev_health, hp+100.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Здоровье!")
			g_health_count[id]++
			show_privilege_menu_prem(id)
		}
		case 3: {
			if(g_money_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_prem(id)
				return
			}
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id)+75)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Аммо!")
			g_money_count[id] +=60
			show_privilege_menu_prem(id)
		}
		case 4: {
			if(g_bolts_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_prem(id)
				return
			}
			zp_set_user_token(id, zp_get_user_token(id)+3)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Болты!")
			g_bolts_count[id] += 60
			show_privilege_menu_prem(id)
		}
		case 5: {
			if(g_make_count[id] || zp_has_round_started()) {
				client_printcolor(id, "^x04[ZP]^x01 Лимит или раунд уже начался!")
				show_privilege_menu_prem(id)
				return
			}
			new name[64]
	        get_user_name(id, name, 64)
			zp_make_user_survivor(id)
			client_printcolor(0, "^x04[ZP]^x01 VIP ^x04 %s ^x01превратился в ^x04Героя!", name)
			g_make_count[id] += 60
		}
		case 6: {
			if(g_make_count[id] || zp_has_round_started()) {
				client_printcolor(id, "^x04[ZP]^x01 Лимит или раунд уже начался!")
				show_privilege_menu_prem(id)
				return
			}
			new name[64]
	        get_user_name(id, name, 64)
			zp_make_user_nemesis(id)
			client_printcolor(0, "^x04[ZP]^x01 VIP ^x04 %s ^x01превратился в ^x04Дьявола!", name)
			g_make_count[id] += 60
		}
	}
}

show_gold_weapons_menu_prem(id) {
	static menu[512]
	new len
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПремиум оружие - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	if(g_weapon_count2[id][0])
		len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dM32 \r[%d|1]^n", g_weapon_count2[id][0])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yM32 \r[%d|1]^n", g_weapon_count2[id][0])
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "PREMIUM Weapons Menu")
}

native zp_give_m32(id)

public menu_gold_weap_prem(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>2) return

	if(g_weapon_count2[id][key]>=1) {
		client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
		return
	}
	g_weapon_count2[id][key]++
		
	switch(key) {
		case 0: zp_give_m32(id)
	}
	show_gold_weapons_menu_prem(id)
}

show_privilege_menu_vip(id) {
	static menu[512]
	new len
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wВип меню - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yЗолотое оружие^n^n")
	
	if(g_armor_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	
	if(g_health_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dВзять жизни \r[+100] \r[%d|1]^n", g_health_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wВзять жизни \r[+100] \r[%d|1]^n", g_health_count[id])
	
	if(g_money_count[id]>=5)
		len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dВзять аммо \r[+50 Аммо] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wВзять аммо \r[+50 Аммо] \r[%d|1]^n", g_money_count[id])
	
	if(g_bolts_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dВзять болты \r[+2] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wВзять болты \r[+2] \r[%d|1]^n", g_bolts_count[id])	

	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "VIP Menu")
}

public menu_vip(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>4) return
	
	if(key==0){
		show_gold_weapons_menu_vip(id)
		return
	}
	
	switch(key) {
		case 1: {
			if(g_armor_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_vip(id)
				return
			}
			new Float:ap
			pev(id, pev_armorvalue, ap)
			
			if(ap >= 300.0){
				client_printcolor(id, "^x04[ZP]^x01 Нельзя взять броню! Лимит брони: ^x04 300")
				return
			}			
			
			set_pev(id, pev_armorvalue, ap+100.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Броню!")
			g_armor_count[id]++
			show_privilege_menu_vip(id)
		}
		case 2: {
			if(g_health_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_vip(id)
				return
			}
			new Float:hp
			pev(id, pev_health, hp)
			set_pev(id, pev_health, hp+100.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Здоровье!")
			g_health_count[id]++
			show_privilege_menu_vip(id)
		}
		case 3: {
			if(g_money_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_vip(id)
				return
			}
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id)+50)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Аммо!")
			g_money_count[id] +=60
			show_privilege_menu_vip(id)
		}
		case 4: {
			if(g_bolts_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_vip(id)
				return
			}
			zp_set_user_token(id, zp_get_user_token(id)+2)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Болты!")
			g_bolts_count[id] += 60
			show_privilege_menu_vip(id)
		}
	}
}

show_gold_weapons_menu_vip(id) {
	static menu[512]
	new len
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wВип оружие - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	if(g_weapon_count2[id][0])
		len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dЗолотой AK47 \r[%d|1]^n", g_weapon_count2[id][0])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yЗолотой AK47 \r[%d|1]^n", g_weapon_count2[id][0])
		
	if(g_weapon_count2[id][1])
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dЗолотая M4A1 \r[%d|1]^n", g_weapon_count2[id][1])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \yЗолотая M4A1 \r[%d|1]^n", g_weapon_count2[id][1])
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "Gold Weapons Menu")
}

native vip_give_ak47g(id)
native vip_give_m4a1g(id)

public menu_gold_weap_vip(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>3) return

	if(g_weapon_count2[id][key]>=1) {
		client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
		return
	}
	g_weapon_count2[id][key]++
		
	switch(key) {
		case 0: vip_give_ak47g(id)
		case 1: vip_give_m4a1g(id)
	}
	show_gold_weapons_menu_vip(id)
}

public show_privilege_menu_boss(id) {
	static menu[512]
	new len
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wБосс меню - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yБосс оружие^n^n")
	
	if(g_armor_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wВзять броню \r[+100] \r[%d|1]^n", g_armor_count[id])
	
	if(g_health_count[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dВзять жизни \r[+200] \r[%d|1]^n", g_health_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wВзять жизни \r[+200] \r[%d|1]^n", g_health_count[id])
	
	if(g_money_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[4] \dВзять аммо \r[+150 Аммо] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wВзять аммо \r[+150 Аммо] \r[%d|1]^n", g_money_count[id])
	
	if(g_bolts_count[id]>=60)
		len += formatex(menu[len], charsmax(menu) - len, "\r[5] \dВзять болты \r[+5] \r[Лимит]^n")
	else len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wВзять болты \r[+5] \r[%d|1]^n", g_bolts_count[id])	
	
	if(g_pipe_count[id]>=10)
		len += formatex(menu[len], charsmax(menu) - len, "\r[6] \dВзять Гр. Молния \r[%d|10]^n", g_pipe_count[id])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wВзять Гр. \yМолния \r[%d|10]^n", g_pipe_count[id])
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \wВыбрать цвет граба^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "BOSS Menu")
}

public menu_boss(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>7) return
	
	if(key==0){
		show_gold_weapons_menu_boss(id)
		return
	}
	
	switch(key) {
		case 1: {
			if(g_armor_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_boss(id)
				return
			}
			new Float:ap
			pev(id, pev_armorvalue, ap)
			
			if(ap >= 300.0){
				client_printcolor(id, "^x04[ZP]^x01 Нельзя взять броню! Лимит брони: ^x04 300")
				return
			}			
			
			set_pev(id, pev_armorvalue, ap+100.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Броню!")
			g_armor_count[id]++
			show_privilege_menu_boss(id)
		}
		case 2: {
			if(g_health_count[id])  {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_boss(id)
				return
			}
			new Float:hp
			pev(id, pev_health, hp)
			set_pev(id, pev_health, hp+200.0)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Здоровье!")
			g_health_count[id]++
			show_privilege_menu_boss(id)
		}
		case 3: {
			if(g_money_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_boss(id)
				return
			}
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id)+ 150)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Аммо!")
			g_money_count[id] +=60
			show_privilege_menu_boss(id)
		}
		case 4: {
			if(g_bolts_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_boss(id)
				return
			}
			zp_set_user_token(id, zp_get_user_token(id)+5)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Болты!")
			g_bolts_count[id] += 60
			show_privilege_menu_boss(id)
		}
		case 5: {
			if(g_pipe_count[id]) {
				client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
				show_privilege_menu_boss(id)
				return
			}
			zp_give_pipe_bomb(id)
			client_printcolor(id, "^x04[ZP]^x01 Вы взяли - ^x04Гр. Молния!")
			g_pipe_count[id] +=10
			show_privilege_menu_boss(id)
		}
		case 6: zp_color_menu(id)
	}
}

show_gold_weapons_menu_boss(id) {
	static menu[512]
	new len
	
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wБосс оружие - \r[M]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wПривилегия: \r[%s]^n^n", g_szPrivilege[id])
		
	if(g_weapon_count3[id][0])
		len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dVulcanus-7 \r[%d|1]^n", g_weapon_count3[id][0])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[1] \yVulcanus-7 \r[%d|1]^n", g_weapon_count3[id][0])
		
	if(g_weapon_count3[id][1])
		len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dAK-47 Paladin \r[%d|1]^n", g_weapon_count3[id][1])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \yAK-47 Paladin \r[%d|1]^n", g_weapon_count3[id][1])
		
	if(g_weapon_count3[id][2])
		len += formatex(menu[len], charsmax(menu) - len, "\r[3] \dSuper Vulcan \r[%d|1]^n", g_weapon_count3[id][2])
	else len += formatex(menu[len], charsmax(menu) - len, "\r[3] \ySuper vulcan \r[%d|1]^n", g_weapon_count3[id][2])
	
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU, menu, -1, "Boss Weapons Menu")
}

native boss_give_vulcanus7(id)
native give_ak47_paladin(id)
native boss_give_gatling(id)

public menu_gold_weap_boss(id, key) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	if(key>3) return

	if(g_weapon_count3[id][key]>=1) {
		client_printcolor(id, "^x04[ZP]^x01 Вы исчерпали лимит на данный предмет!")
		return
	}
	g_weapon_count3[id][key]++
		
	switch(key) {
		case 0: boss_give_vulcanus7(id)
		case 1: give_ak47_paladin(id)
		case 2: boss_give_gatling(id)
	}
	show_gold_weapons_menu_boss(id)
}

show_ruletka_menu(id) {
	if (!is_user_connected(id)) return
	if(zp_get_user_zombie(id)||zp_get_user_survivor(id)) return
	
	static menu[512]
	new len
	
 len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r[BZ]^n\r[ZP] \wРулетка \r[BZ]^n^n\yИнформация:^n\dБонус можно взять 1 раз за карту!^nВ бонусе может попасться VIP и аммо!^n^n")
	
	if(g_ruletka_count[id]>=60)	
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \dПолучить бонус \r[Взят]^n") 
	else len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wПолучить бонус \r[*]^n") 
	
	if(g_ruletka_count[id]>=60)
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \dПолучить PREMIUM \r[Взят]^n^n")
    else len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wПолучить PREMIUM^n^n")
    
    len += formatex(menu[len], charsmax(menu) - len, "\r[0] \wВыход")
	
	show_menu(id, KEYSMENU2, menu, -1, "Ruletka Menu")
}

public menu_ruletka(id, key) 
{
	if (!is_user_connected(id)) return
	static name[32]
	get_user_name(id, name, charsmax(name))
	
	switch(key) 
	{
		case 0:{
		  if(g_ruletka_count[id]) {
			client_printcolor(id, "^x04[ZP]^x01 Лимит! ^x04Только один раз за карту.")
			show_ruletka_menu(id)
			return
			}

		  g_ruletka_count[id] += 60	
		  if(random_num(0,5)==3) {
		    new num=random_num(15,45)
		    zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id)+num)
			client_printcolor(id, "^x04[ZP]^x01 Вы выиграли ^x04(%d) ^x01Аммо!", num)
            } else {
       		client_printcolor(id, "^x04[ZP]^x01 Вы проиграли!")	
		  }
		}
		case 1: {
		  if(g_ruletka_count[id]) {
			client_printcolor(id, "^x04[ZP]^x01 Лимит! ^x04Только один раз за карту.")
			show_ruletka_menu(id)
			return
			}
		
		 if ((get_user_flags(id) & ADMIN_LEVEL_H) == ADMIN_LEVEL_B) {
            client_printcolor(0, "^x04[ZP]^x01 У вас уже есть привилегия!") 
			return
         }
			
			g_ruletka_count[id]+=60
            if(random_num(0,9)==3){ 
              new numn = read_flags("astq") 
              set_user_flags(id, numn) 
              client_printcolor(0, "^x04[ZP]^x01 Везунчик ^x04%s^x01 выйграл^x04 Премиум ^x01на карту! ^x04В Бонус меню!", name) 
              }else{ 
              client_printcolor(id, "^x04[ZP]^x01 Вы проиграли") 
             }
	  }
	}
}

show_ad_menu(id) {
	if (!is_user_connected(id) || !(get_user_flags(id) & ADMIN_SLAY)) return
	
	static menu[512]
	new len
	len += formatex(menu[len], charsmax(menu) - len, "\r[ZP] \wДавний \yАпокалипсис \r| \wЯдерное меню \r[BZ]^n^n\yВыдать:^n")
		
	len += formatex(menu[len], charsmax(menu) - len, "\r[1] \wАммо \r(500)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[2] \wУровень \r(1)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[3] \wБолты \r(50)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[4] \wОпыт \r(10)^n^n\yЗабрать:^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[5] \wАммо \r(500)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[6] \wУровень \r(1)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[7] \wБолты \r(10)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r[8] \wОпыт \r(10)^n")
		
	len += formatex(menu[len], charsmax(menu) - len, "^n\r[0]\w Выход")
	
	set_pdata_int(id, 205, 0)
	show_menu(id, KEYSMENU2, menu, -1, "Give Menu")
}

public menu_give(id, key) 
{
	if (!is_user_connected(id) || !(get_user_flags(id) & ADMIN_SLAY)) return
	switch(key) 
	{
		case 0:{
		  g_szMenu_give[id]=0
		  show_menu_player_list(id)
		}
		case 1: {
			g_szMenu_give[id]=1
			show_menu_player_list(id)
		}
		case 2: {
			g_szMenu_give[id]=2
			show_menu_player_list(id)
		}
		case 3: {
			g_szMenu_give[id]=3
			show_menu_player_list(id)
		}
		case 4: {
			g_szMenu_give[id]=4
			show_menu_player_list(id)
		}
		case 5: {
			g_szMenu_give[id]=5
			show_menu_player_list(id)
		}
		case 6: {
			g_szMenu_give[id]=6
			show_menu_player_list(id)
		}
		case 7: {
			g_szMenu_give[id]=7
			show_menu_player_list(id)
		}
	}
}


show_menu_player_list(id)
{
	static menu[512], player_name[32]
	new menuid, player, buffer[2]
	
	// Title
	switch(g_szMenu_give[id])
	{
		case 0: formatex(menu, charsmax(menu), "\r[ZP]\w Выдача аммо \r[BZ]^n")
		case 1: formatex(menu, charsmax(menu), "\r[ZP]\w Выдача уровня \r[BZ]^n")
		case 2: formatex(menu, charsmax(menu), "\r[ZP]\w Выдача болтов \r[BZ]^n")
		case 3: formatex(menu, charsmax(menu), "\r[ZP]\w Выдача опыта \r[BZ]^n")
		case 4: formatex(menu, charsmax(menu), "\r[ZP]\w Забрать аммо \r[BZ]^n")
		case 5: formatex(menu, charsmax(menu), "\r[ZP]\w Забрать уровень \r[BZ]^n")
		case 6: formatex(menu, charsmax(menu), "\r[ZP]\w Забрать болты \r[BZ]^n")
		case 7: formatex(menu, charsmax(menu), "\r[ZP]\w Забрать опыт \r[BZ]^n")
		case 8: formatex(menu, charsmax(menu), "\r[ZP]\w Раздача аммо \r[BZ]^n")
	}
	menuid = menu_create(menu, "menu_player_list")
	
	// Player List
	for (player = 0; player <= 32; player++)
	{
		// Skip if not connected
		if (!is_user_connected(player))
			continue;
		
		// Get player's name
		get_user_name(player, player_name, charsmax(player_name))
		
		// Format text depending on the action to take	
		switch(g_szMenu_give[id])
		{
		   case 0: formatex(menu, charsmax(menu), "%s \r[%d аммо]", player_name, zp_get_user_ammo_packs(player))
		   case 1: formatex(menu, charsmax(menu), "%s \r[L: %d]", player_name, zp_get_user_lvl(player))
		   case 2: formatex(menu, charsmax(menu), "%s \r[Б: %d]", player_name, zp_get_user_token(player))
		   case 3: formatex(menu, charsmax(menu), "%s \r[EXP: %d]", player_name, zp_get_user_exp(player))
		   case 4: formatex(menu, charsmax(menu), "%s \r[%d аммо]", player_name, zp_get_user_ammo_packs(player))
		   case 5: formatex(menu, charsmax(menu), "%s \r[L: %d]", player_name, zp_get_user_lvl(player))
		   case 6: formatex(menu, charsmax(menu), "%s \r[Б: %d]", player_name, zp_get_user_token(player))
		   case 7: formatex(menu, charsmax(menu), "%s \r[EXP: %d]", player_name, zp_get_user_exp(player))
		   case 8: formatex(menu, charsmax(menu), "%s \r[%d аммо]", player_name, zp_get_user_ammo_packs(player))
		}
		
		// Add player
		buffer[0] = player
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_PLAYERS = min(MENU_PAGE_PLAYERS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	set_pdata_int(id, 205, 0)
	menu_display(id, menuid, MENU_PAGE_PLAYERS)
}

public menu_player_list(id, menuid, item)
{
	// Menu was closed
	if (item == MENU_EXIT)
	{
		MENU_PAGE_PLAYERS = 0
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	MENU_PAGE_PLAYERS = item / 7
	
	// Retrieve player id
	new buffer[2], dummy, player
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	player = buffer[0]
	
	// Make sure it's still connected
	if (is_user_connected(player))
	{
		new name[32], name2[32]
		get_user_name(player, name, 31)
		get_user_name(player, name2, 31)
		switch(g_szMenu_give[id])
		{
			case 0: {			   
				 zp_set_user_ammo_packs(player, zp_get_user_ammo_packs(player)+500)
				client_printcolor(id, "^x04[ZP]^x01 Вы выдали ^x04 500 ^x01аммо - игроку ^x04%s", name)
			}
			case 1: {
				zp_set_user_lvl(player, zp_get_user_lvl(player)+1)
				client_printcolor(id, "^x04[ZP]^x01 Вы выдали ^x04 1 ^x01уровень - игроку ^x04%s", name)
			}
			case 2: {
				zp_set_user_token(player, zp_get_user_token(player)+50)
				client_printcolor(id, "^x04[ZP]^x01 Вы выдали ^x04 50 ^x01болтов - игроку ^x04%s", name)
			}
			case 3: {
				zp_set_user_exp(player, zp_get_user_exp(player)+10)
				client_printcolor(id, "^x04[ZP]^x01 Вы выдали ^x04 10 ^x01опыта - игроку ^x04%s", name)
			}
			case 4: {
				zp_set_user_ammo_packs(player, zp_get_user_ammo_packs(player)-500)
				client_printcolor(id, "^x04[ZP]^x01 Вы забрали ^x04 500 ^x01аммо у игрока - ^x04%s", name)
			}
			case 5: {
				zp_set_user_lvl(player, zp_get_user_lvl(player)-1)
				client_printcolor(id, "^x04[ZP]^x01 Вы забрали ^x04 1 ^x01уровень у игрока - ^x04%s", name)
			}
			case 6: {
				zp_set_user_token(player, zp_get_user_token(player)-2)
				client_printcolor(id, "^x04[ZP]^x01 Вы забрали ^x04 10 ^x01болтов у игрока - ^x04%s", name)
			}
			case 7: {
				zp_set_user_exp(player, zp_get_user_exp(player)-10)
				client_printcolor(id, "^x04[ZP]^x01 Вы забрали ^x04 10 ^x01опыта у игрока - ^x04%s", name)
			}
		}	
	} 
	
	show_menu_player_list(id)
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

stock client_printcolor(const pPlayer, const input[], any:...) 
{
	static szMsg[191]
	vformat(szMsg, charsmax(szMsg), input, 3)
	
	if(pPlayer) {
		message_begin(MSG_ONE_UNRELIABLE, 76, _, pPlayer) 
		write_byte(pPlayer) 
		write_string(szMsg) 
		message_end()
	} else {
		static player
		for (player = 1; player <= 32; player++) {
			if (!is_user_connected(player)) continue;
			
			message_begin(MSG_ONE_UNRELIABLE, 76, _, player) 
			write_byte(player) 
			write_string(szMsg) 
			message_end()
		}
	}
}