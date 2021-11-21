#include <amxmodx>

#define PLUGIN "Server_menu"
#define VERSION "1.0"
#define AUTHOR "click"
new menu

public plugin_init()
{
register_plugin(PLUGIN, VERSION, AUTHOR)
menu = menu_create("\rХикки Задрот | \yCounter-Strike^n\rНаш Сайт \w@ | \ywww.myhostin.ru^n\rIp: \y37.230.210.155:27777  ^n","func_menu");
menu_additem( menu, "\r[\yОбнулить Счет\r]")
menu_additem( menu, "\r[\yТОп15\r] ")
menu_additem( menu, "\r[\yЗаткнуть Игрока\r]") 
menu_additem( menu, "\r[\yНоминировать Карту\r]")
menu_additem( menu, "\r[\yНаписать Л|С\r]")
menu_addblank(menu, 0)
menu_additem( menu, "\y[\rСкин|Меню\y]")
menu_additem( menu, "\y[\rАдмин|Меню\y]") //
menu_additem( menu, "\y[\rМеню при возрождении\y]") //

// menu_setprop( menu, MPROP_NEXTNAME, "Дальше")
// menu_setprop( menu, MPROP_BACKNAME, "Назад")
menu_setprop( menu, MPROP_EXITNAME, "Выход")

register_clcmd("nightvision","go_menu");
register_clcmd("say /menu","go_menu");
}

public client_authorized(id)
{
client_cmd(id, "bind ^"F3^" ^"Menu^"")
}

public func_menu(id, menu, key)
{
key++
if(key==1) client_cmd(id, "say /rs")
if(key==2) client_cmd(id, "say /top")
if(key==3) client_cmd(id, "say /mute")
if(key==4) client_cmd(id, "say /maps")
if(key==5) client_cmd(id, "say /pm")
if(key==6) client_cmd(id, "say /vip")
if(key==7) client_cmd(id, "amxmodmenu")
if(key==8) client_cmd(id, "say /choosemenu")
}

public go_menu(id)
{
menu_display(id,menu)

return PLUGIN_HANDLED
}
