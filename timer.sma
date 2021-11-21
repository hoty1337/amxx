#include <amxmodx>
#include <dhudmessage>

#define PLUGIN "Timer"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2
#pragma semicolon 1

#define TASKID 127341
#define START_TIME 180

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
    set_task(1.0, "Show_Timer", TASKID, _,_, "b");
}

new g_iTimer;
public Show_Timer()
{
    if(g_iTimer == 0)
    {
        g_iTimer = START_TIME;
    }
    new szStr[64], iRed, iGreen, iBlue;
    --g_iTimer;
    if(g_iTimer / 60 >= 2)
    {
        iRed = 0, iGreen = 255, iBlue = 0;
        szStr = "All good";
    }
    else if(g_iTimer / 60 >= 1)
    {
        iRed = 255, iGreen = 255, iBlue = 0;
        szStr = "Warning";
    }
    else if(g_iTimer / 60 >= 0) 
    {
        iRed = 255, iGreen = 0, iBlue = 0;
        szStr = "Danger"; 
    }
    set_dhudmessage(iRed, iGreen, iBlue, -1.0, 0.05, 0, 0.0, 1.0, 0.0, 0.0);
    show_dhudmessage(0, "%s %dm. %dsec.", szStr, g_iTimer / 60, g_iTimer % 60);
}