#include <amxmodx>
#include <sqlx>

native zp_set_user_ammo_packs(id, set)
native zp_set_user_lvl(id, set)
native zp_set_user_exp(id, set)
native zp_set_user_pts(id, set, pts)
native zp_set_user_token(id, set)

native zp_get_user_ammo_packs(id)
native zp_get_user_lvl(id)
native zp_get_user_exp(id)
native zp_get_user_pts(id, pts)
native zp_get_user_token(id)

#define DB_HOST "185.238.138.30" //хост
#define DB_USER "sql_1485_free" //пользователь
#define DB_PASSWORD "TLwGJ1jqtg" //пароль
#define DB_NAME "sql_1485_free" //имя базы

new Handle:g_hDBHandle, Handle:g_hDBInfo

public plugin_init() DBConnect()

public client_putinserver(id) load_sql(id)

public client_disconnect(id) UpdateDB(id)

public load_sql(id)
{
	new ID[32], NAME[32], IP[32]
	get_user_authid(id, ID, charsmax(ID));
	get_user_ip(id, IP, charsmax(IP));
	get_user_name(id, NAME, charsmax(NAME));
	
	replace(NAME, 31, "'", "")
	
	new Handle:hQuery = SQL_PrepareQuery(g_hDBHandle, "SELECT `A`, `T`, `L`, `E`, `P0`, `P1`, `P2`, `P3`, `P4`, `P5`, `P6`, `P7` FROM sql_bzshka WHERE steamid = '%s'", ID);
		
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
		hQuery = SQL_PrepareQuery(g_hDBHandle, "INSERT INTO `sql_bzshka` (`name`, `steamid`, `ip`, `A`, `T`, `L`, `E`, `P0`, `P1`, `P2`, `P3`, `P4`, `P5`, `P6`, `P7` ) VALUES ('%s', '%s', '%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d')", NAME, ID, IP, 100, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		if (!SQL_Execute(hQuery)) 
		{
			server_print("Error due registering user!");
		}
		SQL_FreeHandle(hQuery)
		
		return;
	}
	
	natives_call(id, SQL_ReadResult(hQuery, 0), SQL_ReadResult(hQuery, 1), SQL_ReadResult(hQuery, 2), SQL_ReadResult(hQuery, 3), SQL_ReadResult(hQuery, 4), SQL_ReadResult(hQuery, 5), SQL_ReadResult(hQuery, 6), SQL_ReadResult(hQuery, 7), SQL_ReadResult(hQuery, 8), SQL_ReadResult(hQuery, 9), SQL_ReadResult(hQuery, 10), SQL_ReadResult(hQuery, 11))
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
	
	ResultT=SQL_PrepareQuery(g_hDBHandle, "CREATE TABLE IF NOT EXISTS `sql_bzshka` (`name` VARCHAR(35) NOT NULL default '',  `steamid` VARCHAR(25) NOT NULL default '', `ip` VARCHAR(20) NOT NULL default '', `A` INT(6) NOT NULL, `T` INT(6) NOT NULL, `L` INT(6) NOT NULL, `E` INT(6) NOT NULL, `P0` INT(6) NOT NULL, `P1` INT(6) NOT NULL, `P2` INT(6) NOT NULL, `P3` INT(6) NOT NULL, `P4` INT(6) NOT NULL, `P5` INT(6) NOT NULL, `P6` INT(6) NOT NULL, `P7` INT(6) NOT NULL)")
	
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
	
	new Handle:hQuery = SQL_PrepareQuery(g_hDBHandle, "UPDATE `sql_bzshka` SET `A`=%i, `T`=%i, `L`=%i, `E`=%i, `P0`=%i, `P1`=%i, `P2`=%i, `P3`=%i, `P4`=%i, `P5`=%i, `P6`=%i, `P7`=%i WHERE `steamid` = '%s'", zp_get_user_ammo_packs(id), zp_get_user_token(id), zp_get_user_lvl(id), zp_get_user_exp(id), zp_get_user_pts(id, 0), zp_get_user_pts(id, 1), zp_get_user_pts(id, 2), zp_get_user_pts(id, 3), zp_get_user_pts(id, 4), zp_get_user_pts(id, 5), zp_get_user_pts(id, 6), zp_get_user_pts(id, 7), NAME)
	
	if (!SQL_Execute(hQuery))
	{
		new Error[192];
		SQL_QueryError(hQuery, Error, charsmax(Error));
	}
	SQL_FreeHandle(hQuery);
}

stock natives_call(id, A=100, T=0, L=1, E=0, P0=0, P1=0, P2=0, P3=0, P4=0, P5=0, P6=0, P7=0)
{
    zp_set_user_ammo_packs(id, A)
	zp_set_user_token(id, T)
	zp_set_user_lvl(id, L)
	zp_set_user_exp(id, E)
	
	zp_set_user_pts(id, 0, P0)
	zp_set_user_pts(id, 1, P1)
	zp_set_user_pts(id, 2, P2)
	zp_set_user_pts(id, 3, P3)
	zp_set_user_pts(id, 4, P4)
	zp_set_user_pts(id, 5, P5)
	zp_set_user_pts(id, 6, P6)
	zp_set_user_pts(id, 7, P7)
}

