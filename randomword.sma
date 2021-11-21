#include <amxmodx>
#include <saytext>

#define PLUGIN "RandomWord"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2
#pragma semicolon 1

#define PATH        "addons/amxmodx/configs/random_word.ini"
#define TASKID      21736241
#define INTERVAL    20.0

new g_iFileSize;

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
    set_task(INTERVAL, "Say_RandomWord", TASKID, _,_, "b");
    g_iFileSize = file_size(PATH, 1) - 1;
}

public Say_RandomWord()
{
    new szStr[512], iRandom, iLen;
    iRandom = random_num(0, g_iFileSize);
    read_file(PATH, iRandom, szStr, charsmax(szStr), iLen);
    UTIL_SayText(0, "%s", szStr);
}