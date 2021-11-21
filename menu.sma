#include <amxmodx>
#include <amxmisc>
//#include <dhudmessage>

#define PLUGIN  "Menu"
#define VERSION "1.0"
#define AUTHOR  "alseegame"

new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
new cvar_showhudmsg

public plugin_init()
{
     register_plugin(PLUGIN, VERSION, AUTHOR)
     register_menu("Menu 1", keys, "func_menu") 
     register_concmd("menu", "Server_Menu")
     register_concmd("chooseteam", "Server_Menu")

     cvar_showhudmsg = register_cvar("show_hudmsg", "1");            //1 - on                0 - off
}

public client_authorized(id)
{
     client_cmd(id, "bind ^"M^" ^"menu^"")
}

public client_putinserver(id)
{
        if(get_pcvar_num(cvar_showhudmsg))
                set_task(1.0, "task_hudmsg", id, _, _, "b")
}

public task_hudmsg(id)
{
        set_hudmessage(0, 255, 0, 0.75, 0.0, 0, 6.0, 12.0)
        show_hudmessage(id, "Меню Сервера На букву M")
}

public Server_Menu(id)
{
     new name[32]
     get_user_name(id, name, 31)
     static menu[650], iLen
     iLen = 0
     iLen = formatex(menu[iLen], charsmax(menu) - iLen, "\yГлавное\w Меню\r alseegame\w*\d ©^n\wСтраница\r [\yВ\r]\wК:\r vk.com/o.lubenskaya^n")
     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\w[1]. \r[\yМагазин\r]\d?^n")
     keys |= MENU_KEY_1

     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\w[2]. \r[\yСменить карту\r]\d?^n")
     keys |= MENU_KEY_2

     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\w[3]. \r[\yМеню Шапок\r]\d?^n")
     keys |= MENU_KEY_3

     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\w[4]. \r[\yМеню Ножей\r]\d?^n")
     keys |= MENU_KEY_4

     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\w[5]. \r[\y!FREE!Trail\r]\d?^n")
     keys |= MENU_KEY_5

     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\w[6]. \r[\yBOSS МЕНЮ\r]\d?^n")
     keys |= MENU_KEY_6

     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\w[7]. \r[\yПОВЕЛИТЕЛЬ МЕНЮ\r]\d?^n^n")
     keys |= MENU_KEY_7

     iLen += formatex(menu[iLen], charsmax(menu) - iLen, "\r[0]. [\yExit\r]^n")
     keys |= MENU_KEY_0

     show_menu(id, keys, menu, -1, "Menu 1")
     return PLUGIN_HANDLED
}

public func_menu(id, key)
{
     switch(key)
     {
          case 0: client_cmd(id, "say /magazine")
          case 1: client_cmd(id, "say /rtv")
          case 2: client_cmd(id, "say /hats")
          case 3: client_cmd(id, "say /knife")
          case 4: client_cmd(id, "say /trail")
          case 5: client_cmd(id, "say /bossmenu") 
          case 6: client_cmd(id, "say /povelitelmenu")
     }
     return PLUGIN_HANDLED
}
