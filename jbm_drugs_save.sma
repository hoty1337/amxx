#include amxmodx
#include nvault
#include sqlx

#define NVAULT_NAME		"DrugsSave"
#define SQL_TABLENAME "jbm_drugs"
#define TASK_LOADDATA 127381

#define CHAR 32
#define MAX_PLAYER 32

native jbm_get_drugs(id, iDrugs);				// 1 - "??????", 2 - "?????", 3 - "???", 4 - "??????"
native jbm_set_drugs(id, iDrugs, iNum);

native jbm_get_material(id, iMaterial);			// 1 - "??????", 2 - "?????", 3 - "??? ?????", 4 - "??????"
native jbm_set_material(id, iMaterial, iNum);

new UserSteamID[33][34], g_ActiveMysql, szPlayerMysql[33], g_szQuery[512], Handle:MYSQL_Tuple;

public plugin_init()
{
	register_plugin("Drugs Save", "0.1", "7heHex");
}

public fbans_sql_connected(Handle:sqlTuple)
{ 
	MYSQL_Tuple = sqlTuple; 
	new err, error[256];
	SQL_Connect(MYSQL_Tuple, err, error, charsmax(error))
	g_ActiveMysql = true
	SQL_SetCharset(MYSQL_Tuple, "utf8");
	formatex(g_szQuery, charsmax(g_szQuery), "CREATE TABLE IF NOT EXISTS `%s` (`id` int(11) not null, `steamid` text not null,\
	 `drug1` int(11) not null default '0', `drug2` int(11) not null default '0', `drug3` int(11) not null default '0', `drug4` int(11) not null default '0',\
	 `mat1` int(11) not null default '0', `mat2` int(11) not null default '0', `mat3` int(11) not null default '0', `mat4` int(11) not null default '0');\
		COLLATE='utf8_general_ci',\
		ENGINE=InnoDB;", SQL_TABLENAME);
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery);
}

public client_connect(id)
{
	szPlayerMysql[id] = false;
	if(!is_user_bot(id) || !is_user_hltv(id))
	{
		set_task(1.0, "LoadData", id + TASK_LOADDATA);
	}
}

public LoadData(idx)
{
	if(!g_ActiveMysql)
		return;
	new id = idx - TASK_LOADDATA;
	if(!is_user_connected(id) && !is_user_connecting(id))
		return;
	
	new iParams[1]
	iParams[0] = id
	
	get_user_authid(id, UserSteamID[id], 34);
	
	formatex(g_szQuery, charsmax(g_szQuery), "SELECT * FROM `%s` WHERE (`%s`.`steamid` = '%s')", SQL_TABLENAME, SQL_TABLENAME, UserSteamID[id])
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Query", g_szQuery, iParams, sizeof iParams)
}

public SQL_Query( iState, Handle: hQuery, szError[], iErrorCode, iParams[], iParamsSize)
{
	switch(iState)
	{
		case TQUERY_CONNECT_FAILED: log_amx("Load - Could not connect to SQL database. [%d] %s", iErrorCode, szError)
		case TQUERY_QUERY_FAILED: log_amx("Load Query failed. [%d] %s", iErrorCode, szError)
	}
	
	new id = iParams[0]
	szPlayerMysql[id] = true
	
	if(SQL_NumResults(hQuery) < 1)
	{
		if(equal(UserSteamID[id], "ID_PENDING"))
			return PLUGIN_HANDLED
		formatex(g_szQuery, charsmax(g_szQuery), "INSERT INTO `%s` (`steamid`, `drug1`, `drug2`, `drug3`, `drug4`, `mat1`, `mat2`, `mat3`, `mat4`) VALUES ('%s', '0', '0', '0', '0', '0', '0', '0', '0')", SQL_TABLENAME, UserSteamID[id]);
		SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery)
		return PLUGIN_HANDLED;
	}
	else
	{
		for(new i = 1; i <= 4; i++) jbm_set_drugs(id, i, SQL_ReadResult(hQuery, i + 1));
		for(new i = 1; i <= 4; i++) jbm_set_material(id, i, SQL_ReadResult(hQuery, i + 5));
	}
	return PLUGIN_HANDLED;
}

public client_disconnected(id)
{
	client_save(id);
}

public plugin_natives()
{
	register_native("DrugsSave", "client_save", 1);
}

public client_save(id)
{
	if(!g_ActiveMysql)
		return;

	if(!szPlayerMysql[id])
		return;

	formatex(g_szQuery, charsmax(g_szQuery), "UPDATE `%s` SET `drug1` = '%d', `drug2` = '%d', `drug3` = '%d', `drug4` = '%d',\
	`mat1` = '%d', `mat2` = '%d', `mat3` = '%d', `mat4` = '%d' WHERE `%s`.`steamid` = '%s';", SQL_TABLENAME, 
	jbm_get_drugs(id, 1), jbm_get_drugs(id, 2), jbm_get_drugs(id, 3), jbm_get_drugs(id, 4), 
	jbm_get_material(id, 1), jbm_get_material(id, 2), jbm_get_material(id, 3), jbm_get_material(id, 4), SQL_TABLENAME, UserSteamID[id])
	
	SQL_ThreadQuery(MYSQL_Tuple, "SQL_Thread", g_szQuery)
}

public SQL_Thread(iState, Handle: hQuery, szError[], iErrorCode, iParams[], iParamsSize)
{
	if(iState == 0)
		return;
	
	log_amx("SQL Error: %d (%s)", iErrorCode, szError)
}