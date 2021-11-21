#include <amxmodx>
#include <reapi>
#include <fakemeta_util>

#define PLUGIN_NAME "Show enemies on radar"
#define PLUGIN_VERSION "0.1b"
#define PLUGIN_AUTHOR "Denzer"

const TASK_SHOW_ENEMY_ON_RADAR = 23791;

new g_iHostagePos, g_iHostageK;

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", true);

    g_iHostagePos  = get_user_msgid("HostagePos");
    g_iHostageK    = get_user_msgid("HostageK");
}

public client_disconnected(id)
{
    remove_task(id+TASK_SHOW_ENEMY_ON_RADAR);
}

public CBasePlayer_Spawn_Post(id)
{
    if(!is_user_alive(id))
        return;

    remove_task(id+TASK_SHOW_ENEMY_ON_RADAR);
    set_task(2.0, "task_ShowEnemyOnRadar", id+TASK_SHOW_ENEMY_ON_RADAR, .flags = "b");
}

public task_ShowEnemyOnRadar(id)
{
    id -= TASK_SHOW_ENEMY_ON_RADAR;

    if(!is_user_alive(id))
    {
        remove_task(id+TASK_SHOW_ENEMY_ON_RADAR);
        return;
    }

    if(rg_is_user_blinded(id))
        return;

    new iPlayers[MAX_PLAYERS], iNum;
    get_players(iPlayers, iNum, "ah");

    for(new i; i < iNum; i++)
    {
        new iPlayer = iPlayers[i];

        if(id == iPlayer) continue;

        if(TeamName:get_member(id, m_iTeam) == TeamName:get_member(iPlayer, m_iTeam)) continue;

        new Float:flOriginPlayer[3]; get_entvar(iPlayer, var_origin, flOriginPlayer);

        // fov = 90
        if(fm_is_in_viewcone(id, flOriginPlayer) && fm_is_ent_visible(id, iPlayer))
        {
            for(new j; j < iNum; j++)
            {
                new index = iPlayers[j];

                if(TeamName:get_member(id, m_iTeam) != TeamName:get_member(index, m_iTeam)) continue;

                showEnemyRadar(index, iPlayer, flOriginPlayer);
            }
        }
    }
}

showEnemyRadar(id, i, Float:fOrigin[3])
{
    message_begin(MSG_ONE_UNRELIABLE, g_iHostagePos, {0,0,0}, id);
    write_byte(id);
    write_byte(i);
    write_coord_f(fOrigin[0]);
    write_coord_f(fOrigin[1]);
    write_coord_f(fOrigin[2]);
    message_end();

    message_begin(MSG_ONE_UNRELIABLE, g_iHostageK, {0,0,0}, id);
    write_byte(i);
    message_end();
}

// Vaqtincha
stock bool:rg_is_user_blinded(const player) {
    return bool:(Float:get_member(player, m_blindStartTime) + Float:get_member(player, m_blindFadeTime) >= get_gametime())
}