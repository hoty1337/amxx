new MaxClients;
new String:NULL_STRING[4];
new Float:NULL_VECTOR[3];
new Handle:g_hDBTuple;
new g_szQuery[2048];
public plugin_init()
{
	register_plugin("Teeest", "0.1", "7heHex");
	register_clcmd("say 228", "ClCmd_TestConnection", -1, 212, -1, MaxClients);
	return 0;
}

public fbans_sql_connected(Handle:sqlTuple)
{
	g_hDBTuple = sqlTuple;
	return 0;
}

public ClCmd_TestConnection(id)
{
	formatex(g_szQuery, 2047, "INSERT INTO `jbm_block_1` (`steamid`, `ip`, `time`, `nick`) VALUES ('xyu' ,'228.228', '-1' ,'xyuxyu')");
	SQL_ThreadQuery(g_hDBTuple, "ThreadQueryHandler", g_szQuery, 8892, MaxClients);
	return 0;
}

public ThreadQueryHandler(iState, Handle:hQuery, szError[], iError, iParams[], iParamsSize)
{
	if (iState)
	{
		log_amx("SQL Error: %d (%s)", iError, szError);
		return 0;
	}
	return 0;
}

