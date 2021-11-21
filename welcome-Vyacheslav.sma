#include <amxmodx>
#include <saytext>

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
    if(get_user_flags(id) & ADMIN_IMMUNITY)
        log_amx("get_user_flags a");
    if(userHasFlag(id, "a"))
        log_amx("userhasflag a");
}