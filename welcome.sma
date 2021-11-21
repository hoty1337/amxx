#include <amxmodx>

#define PLUGIN "test"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2
#pragma semicolon 1

native userHasFlag(id, szFlag[]);

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
}

public client_putinserver(id)
{
    userHasFlag(id, "0");
    userHasFlag(id, "1");
    userHasFlag(id, "2");
    userHasFlag(id, "3");
    userHasFlag(id, "4");
    userHasFlag(id, "5");
    userHasFlag(id, "6");
    userHasFlag(id, "7");
    userHasFlag(id, "8");
    userHasFlag(id, "9");
}