#include <amxmodx>
#include <saytext>
#include <sqlx>

#define PLUGIN "Teeest"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2
#pragma semicolon 1

new Handle:g_hDBTuple;

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
    register_clcmd("say 228", "ClCmd_TestConnection");
}

public fbans_sql_connected(Handle:sqlTuple)
{ 
	g_hDBTuple = sqlTuple; 
}

new g_szQuery[2048];

public ClCmd_TestConnection(id)
{
    formatex(g_szQuery, charsmax(g_szQuery), "INSERT INTO `jbm_block_1` (`steamid`, `ip`, `time`, `nick`) VALUES ('xyu' ,'228.228', '-1' ,'xyuxyu')");
    SQL_ThreadQuery(g_hDBTuple, "ThreadQueryHandler", g_szQuery);
}

public ThreadQueryHandler(iState, Handle:hQuery, szError[], iError, iParams[], iParamsSize) 
{
	if(iState == 0)
	    return;
	log_amx("SQL Error: %d (%s)", iError, szError);
}