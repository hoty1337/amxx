#include <amxmodx>
#include <sqlx>

native zp_set_user_admgrab(id, set)
native zp_get_user_admgrab(id)

native zp_get_character(id)
native zp_set_character(id, set)

#define DB_HOST "185.238.138.30" //хост
#define DB_USER "sql_1485_free" //пользователь
#define DB_PASSWORD "TLwGJ1jqtg" //пароль
#define DB_NAME "sql_1485_free" //имя базы

new Handle:g_hDBHandle, Handle:g_hDBInfo
public plugin_init()  DBConnect()
 
public client_disconnect(id) if(!is_user_bot(id)) UpdateDB(id)

public load_sql(id)
{
	new ID[32], NAME[32], IP[32]
	get_user_authid(id, ID, charsmax(ID));
	get_user_ip(id, IP, charsmax(IP));
	get_user_name(id, NAME, charsmax(NAME));
	
	replace(NAME, 31, "'", "")
	
	new Handle:hQuery = SQL_PrepareQuery(g_hDBHandle, "SELECT `Grab`, `Character` FROM adm_data2 WHERE steamid = '%s'", ID);
		
	if (!SQL_Execute(hQuery)) 
	{
		new Error[192];
		SQL_QueryError(hQuery, Error, charsmax(Error))
		set_fail_state(Error)
		SQL_FreeHandle(hQuery)
		return;
	}
		
	if (!SQL_NumResults(hQuery)) 
	{
		natives_call(id)
		
		SQL_FreeHandle(hQuery);
			
		new ip[16];
		get_user_ip(id, ip, charsmax(ip), 1);
		hQuery = SQL_PrepareQuery(g_hDBHandle, "INSERT INTO `adm_data2` (`name`, `steamid`, `ip`, `Grab`, `Character` ) VALUES ('%s', '%s', '%s', '%d', '%d')", NAME, ID, IP, 1, 2);
		if (!SQL_Execute(hQuery)) 
		{
			server_print("Error due registering user!");
		}
		SQL_FreeHandle(hQuery)
		
		return;
	}
	
	new Character = SQL_ReadResult(hQuery, 1);
	
	if(Character == 4 && !(get_user_flags(id) & ADMIN_LEVEL_H)) Character = 1
	else if(Character == 5 && !(get_user_flags(id) & ADMIN_LEVEL_B)) Character = 1
	else if(Character == 6 && !(get_user_flags(id) & ADMIN_LEVEL_D)) Character = 1
    else Character == 1	
	
	natives_call(id, SQL_ReadResult(hQuery, 0))
	SQL_FreeHandle(hQuery);
}

DBConnect()
{
	new Error[128], errno;
	g_hDBInfo = SQL_MakeDbTuple(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME)
	g_hDBHandle = SQL_Connect(g_hDBInfo, errno, Error, charsmax(Error));
	SQL_FreeHandle(g_hDBInfo)
	if (g_hDBHandle == Empty_Handle){
		set_fail_state(Error)
		return
	}
	
	new Handle:ResultT
	
	ResultT=SQL_PrepareQuery(g_hDBHandle, "CREATE TABLE IF NOT EXISTS `adm_data2` (`name` VARCHAR(35) NOT NULL default '', 	`steamid` VARCHAR(25) NOT NULL default '', `ip` VARCHAR(20) NOT NULL default '', `Grab` INT(6) NOT NULL, `Character` INT(7) NOT NULL )")
	
	if(!SQL_Execute(ResultT)){
		SQL_QueryError(ResultT,Error,127)
		SQL_FreeHandle(ResultT)
		set_fail_state(Error)
		return
	}
	SQL_FreeHandle(ResultT)
}

public plugin_end() 
{
	for (new id = 1; id <= 32; id++) 
	{
		if(is_user_connected(id) && !is_user_bot(id))
		{
			UpdateDB(id)
		}
	}
	
	SQL_FreeHandle(g_hDBHandle)
}

stock UpdateDB(id)
{
	new NAME[32]
	get_user_authid(id, NAME, charsmax(NAME));
	
	replace(NAME, 31, "'", "")
	
	new Handle:hQuery = SQL_PrepareQuery(g_hDBHandle, "UPDATE `adm_data2` SET `Grab`=%i, `Character`=%i WHERE `steamid` = '%s'", zp_get_user_admgrab(id), zp_get_character(id), NAME);
	
	if (!SQL_Execute(hQuery))
	{
		new Error[192];
		SQL_QueryError(hQuery, Error, charsmax(Error));
	}
	SQL_FreeHandle(hQuery);
}

stock natives_call(id, Grab=1,Character=0)
{
	zp_set_user_admgrab(id, Grab)
	zp_set_character(id, Character)
}