#include <amxmodx>

#define PLUGIN "Menu"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 4
#pragma semicolon 1

#define MENU_COMMAND "say /menu" // тут напиши команду, по которой будет вызываться меню

#define KEY0 1<<9
#define KEY1 1<<0
#define KEY2 1<<1
#define KEY3 1<<2
#define KEY4 1<<3
#define KEY5 1<<4
#define KEY6 1<<5
#define KEY7 1<<6
#define KEY8 1<<7
#define KEY9 1<<8


public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
    register_menucmd(register_menuid("Show_Menu"), 1023, "Handle_Menu"); // регистрируем меню
    register_clcmd(MENU_COMMAND, "Show_Menu"); // регистрируем команду, по которой откроется меню (ее указывать на 11 строчке)
}

public Show_Menu(id)
{
    new szMenu[512], iKeys = (KEY1|KEY2|KEY3|KEY4|KEY0), iLen = formatex(szMenu, charsmax(szMenu), "Command menu^n"); // добавляем переменные и пишем название меню ( ^n - перенос на новую строку)
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "punct 1^n"); // как будет выглядеть пункт 1
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "punct 2^n"); // как будет выглядеть пункт 2
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "punct 3^n"); // как будет выглядеть пункт 3
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "punct 4^n"); // как будет выглядеть пункт 3
    // чтобы добавить больше пунктов просто копируешь предыдущую строчку с пунктом и меняешь цифру и название пункта (не забудь в Handle_Menu добавить функцию, которая будет выполняться)
	// также, в 34 строку нужно добавить нужную клавишу, там где iKeys = (KEY1|KEY2|KEY3|сюда_добавлять|KEY0)
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^nexit"); // как будет выглядеть пункт 0
    return show_menu(id, iKeys, szMenu, -1, "Show_Menu"); // показываем меню игроку
}

public Handle_Menu(id, iKey) // штука, которая выполняется после нажатия на кнопку в меню
{
    switch((iKey + 1) % 10)
    {
        case 1:
        {
            // тут пиши, что выполнится для первого пункта
			client_cmd(id, "say /111");
        }
        case 2:
        {
			client_cmd(id, "say /222");
            // тут пиши, что выполнится для второго пункта
        }
        case 3:
        {
			client_cmd(id, "say /333");
            // тут пиши, что выполнится для третьего пункта
        }
		case 4:
        {
			client_cmd(id, "say /444");
            // тут пиши, что выполнится для третьего пункта
        }
        // добавлять легко, просто пишешь сюда case и номер клавиши, например 1 или 2

        case 0:
        {
            return PLUGIN_HANDLED;
        }
    }
    return PLUGIN_HANDLED;
}