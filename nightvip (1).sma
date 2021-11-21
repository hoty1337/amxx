#include <amxmodx>
#include <hamsandwich>

#define PLUGIN "Free VIP"
#define VERSION "0.1"
#define AUTHOR "XTCS"

new g_FreeVip[33];
new g_Time_1, g_Time_2

public plugin_init()
{
register_plugin(PLUGIN, VERSION, AUTHOR)

g_Time_1 = register_cvar("free_vip_time_from", "20")
g_Time_2 = register_cvar("free_vip_time_to", "09")

RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)

}

public fwHamPlayerSpawnPost(id)
{
new szTime[3]
get_time("%H",szTime,2)

new Time_1 = get_pcvar_num(g_Time_1)
new Time_2 = get_pcvar_num(g_Time_2)

new iTime = str_to_num(szTime)
if( 20 <= iTime <= 24 )
{
if( !(get_user_flags(id) & ADMIN_RESERVATION) )
{
remove_user_flags(id, ADMIN_USER);
set_user_flags(id, ADMIN_LEVEL_H);
g_FreeVip[id] = true;
set_hudmessage( 255, 255, 255, -1.0, 0.87, 0, 0.0, 12.0, 0.1, 0.2, -1 );
show_hudmessage ( id, "Теперь у нас ночной вип все с ^n %d:00 to %d:00!", Time_1, Time_2)
}
}
else if( 00 <= iTime <= 09 )
{
if( !(get_user_flags(id) & ADMIN_RESERVATION) )
{
remove_user_flags(id, ADMIN_USER);
set_user_flags(id, ADMIN_LEVEL_H);
g_FreeVip[id] = true;
set_hudmessage( 255, 255, 255, -1.0, 0.87, 0, 0.0, 12.0, 0.1, 0.2, -1 );
show_hudmessage ( id, "Теперь у нас ночной вип все с ^n %d:00 to %d:00!", Time_1, Time_2)
}
}
else if( g_FreeVip[id] )
{
remove_user_flags(id, ADMIN_LEVEL_H);
set_user_flags(id, ADMIN_USER);
g_FreeVip[id] = false;
}
}