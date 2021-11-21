#include <amxmodx>
#include <saytext>

#define PLUGIN "Menu"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2
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
    register_clcmd(MENU_COMMAND, "Show_Menu"); // регистрируем команду, по которой откроется меню (ее указывать на 10 строчке)
}

public Show_Menu(id)
{
    new szMenu[512], iKeys = (KEY0|KEY1|KEY2|KEY3), iLen = formatex(szMenu, charsmax(szMenu), "\yМеню сервера^n^n"); // добавляем переменные и пишем название меню
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[1] \wПункт1^n"); // как будет выглядеть пункт 1
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[2] \wПункт2^n"); // как будет выглядеть пункт 2
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[3] \wПункт3^n"); // как будет выглядеть пункт 3
    // чтобы добавить больше пунктов просто копируешь предыдущую строчку с пунктом и меняешь цифру и название пункта (не забудь в Handle_Menu добавить функцию, которая будет выполняться)

    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\y[0] \wВыход^n"); // как будет выглядеть пункт 0
    return show_menu(id, iKeys, szMenu, -1, "Show_Menu"); // показываем меню игроку
}

public Handle_Menu(id, iKey) // штука, которая выполняется после нажатия на кнопку в меню
{
    switch(iKey)
    {
        case KEY1:
        {
            UTIL_SayText(id, "1 punkt");
            // тут пиши, что выполнится для первого пункта
        }
        case KEY2:
        {
            UTIL_SayText(id, "2 punkt");
            // тут пиши, что выполнится для второго пункта
        }
        case KEY3:
        {
            UTIL_SayText(id, "3 punkt");
            // тут пиши, что выполнится для третьего пункта
        }
        // добавлять легко, просто пишешь сюда case и название клавиши, которая в дефайне

        case KEY0:
        {
            UTIL_SayText(id, "0 punkt");
            return PLUGIN_HANDLED;
        }
    }
    return PLUGIN_HANDLED;
}