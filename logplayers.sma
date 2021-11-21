#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#define AUTHOR "7heHex"
#define VER "0.1"
#define PLUGIN "LogPlayers"

new g_szPath[64], bool:g_bUserInFile[33];

#pragma tabsize 4
#pragma semicolon 1

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
    new szConfigsDir[64];
    get_configsdir(szConfigsDir, charsmax(szConfigsDir));
    formatex(g_szPath, charsmax(g_szPath), "%s/players.ini");
    fopen(g_szPath, "a");
	RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", true);
}

public client_connect(id)
{
    new iFileSize = file_size(g_szPath, 1);
    new iPos = 0, szAuthID[32];
    get_user_authid(id, szAuthID, charsmax(szAuthID));
    g_bUserInFile[id] = false;
    while(iPos != -1 && iPos < iFileSize)
    {
        new iLen, szStr[32];
        iPos = read_file(g_szPath, iPos, szStr, charsmax(szStr), iLen);
        iPos = (iPos == 0 ? -1 : iPos);
        if(szStr[0] == ';' || equal(szStr, "")) continue;
        if(equal(szStr, szAuthID))
        {
            // нашли чела, который уже был на этой карте
            g_bUserInFile[id] = true;
            break;
        }
    }
    if(!g_bUserInFile[id])
    {
        write_file(g_szPath, szAuthID);
    }
}

public Ham_PlayerSpawn_Post(id)
{
    if(g_bUserInFile[id])
    {
        // что будет выполняться, если чел уже был на карте
    }
    else 
    {
        // что будет выполняться, если чел НЕ был на карте
    }
}

public plugin_end()
{
    delete_file(g_szPath);
}