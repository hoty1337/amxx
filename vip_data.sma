#include <amxmodx>
#include <saytext>

#define PLUGIN "Data"
#define VER "0.3"
#define AUTHOR "7heHex"

#define PATH "addons/amxmodx/configs/vip_data_2.ini"
#define STARTTIME -1
#define DATA_PREFIX "!gSERVER !t|"
#define MAX_PLAYERS 32

#pragma tabsize 2
#pragma semicolon 1

new g_szFlags[] = {"abcdefghijklmnopqrstuz"};

new bool:g_bUserHasFlag[MAX_PLAYERS + 1][22], g_iUserNum[MAX_PLAYERS + 1], g_iUserTimeLeft[MAX_PLAYERS + 1][22], g_iUserBalance[MAX_PLAYERS + 1], name_clscaner[MAX_PLAYERS + 1], steam_clscaner[MAX_PLAYERS + 1], g_iTimeConnect[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VER, AUTHOR);
	register_clcmd("say /mytime", "ShowData");
	register_clcmd("say /hello", "ClScaner");
	register_clcmd("say /flag", "checkFlags");
}

public ClScaner(id)
{
	
	get_user_name(id, name_clscaner, MAX_PLAYERS);
	get_user_authid(id, steam_clscaner, MAX_PLAYERS);
	
	server_print ("[CL_SCANER] (  %s  ): %s", name_clscaner, steam_clscaner);
	
	return PLUGIN_CONTINUE;
}

public addMoney(id, iMoney)
{
	new iFileSize = file_size(PATH, 1) - 1, iPos = 0;
	while(iPos < iFileSize) // бежим по файлу, в поисках нужного steamID
	{
		new iLen, szStr[512], szNum[10], szNameFile[32], szAuthIDFile[32], szIpFile[32], szCost[10], szUserTimeLeft[22][10];
		iPos = read_file(PATH, iPos, szStr, charsmax(szStr), iLen);
		if(szStr[0] == ';') continue;
		parse(szStr, szNum, 10, szNameFile, charsmax(szNameFile), szAuthIDFile, charsmax(szAuthIDFile), szIpFile, charsmax(szIpFile), szCost, charsmax(szCost), szUserTimeLeft[0], 10, szUserTimeLeft[1], 10,
			szUserTimeLeft[2], 10, szUserTimeLeft[3], 10, szUserTimeLeft[4], 10, szUserTimeLeft[5], 10, szUserTimeLeft[6], 10, szUserTimeLeft[7], 10, szUserTimeLeft[8], 10,
			szUserTimeLeft[9], 10, szUserTimeLeft[10], 10, szUserTimeLeft[11], 10, szUserTimeLeft[12], 10, szUserTimeLeft[13], 10, szUserTimeLeft[14], 10, szUserTimeLeft[15], 10,
			szUserTimeLeft[16], 10, szUserTimeLeft[17], 10, szUserTimeLeft[18], 10, szUserTimeLeft[19], 10, szUserTimeLeft[20], 10, szUserTimeLeft[21], 10);
		if(id == str_to_num(szNum))
		{
			new tMoney = max(0, str_to_num(szCost) + iMoney);
			formatex(szStr, charsmax(szStr), "%s ^"%s^" ^"%s^" ^"%s^" %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", szNum, szNameFile, szAuthIDFile, szIpFile, tMoney, g_iUserTimeLeft[id][0], g_iUserTimeLeft[id][1],
			g_iUserTimeLeft[id][2], g_iUserTimeLeft[id][3], g_iUserTimeLeft[id][4], g_iUserTimeLeft[id][5], g_iUserTimeLeft[id][6], g_iUserTimeLeft[id][7], g_iUserTimeLeft[id][8],
			g_iUserTimeLeft[id][9], g_iUserTimeLeft[id][10], g_iUserTimeLeft[id][11], g_iUserTimeLeft[id][12], g_iUserTimeLeft[id][13], g_iUserTimeLeft[id][14], g_iUserTimeLeft[id][15],
			g_iUserTimeLeft[id][16], g_iUserTimeLeft[id][17], g_iUserTimeLeft[id][18], g_iUserTimeLeft[id][19], g_iUserTimeLeft[id][20], g_iUserTimeLeft[id][21]); // формируем строчку
			if(iPos == 0) iPos = iFileSize;
			write_file(PATH, szStr, iPos - 1);
			return true;
		}
	}
	return false;
}

public buyFlag(id, szFlag, iMoney, iTime)
{
	for(new i; i < charsmax(g_szFlags); i++)
	{
		if(g_szFlags[i] == szFlag && g_iUserBalance[id] >= iMoney)
		{
			g_iUserTimeLeft[id][i] += iTime;
			g_iUserBalance[id] -= iMoney;
			return true;
		}
	}
	return false;
}

public checkFlags(id)
{
	/*new szStr[32], iLen;
	for(new i = 1; i < (1<<charsmax(g_szFlags)); i*=2)
	{
		if(get_user_flags(id) & i)
		{
			iLen += formatex(szStr[iLen], charsmax(szStr) - iLen, "%c",  g_szFlags[i]);
		}
	}
	console_print(0, "Your flags is %s", szStr);
	return PLUGIN_HANDLED;*/
	console_print(0, "[LOG] %d", get_user_flags(id));
}

public client_connect(id)
{
	if(file_exists(PATH))
	{
		new szAuthID[32], szName[32], szIp[32], szCost[10];
		get_user_authid(id, szAuthID, charsmax(szAuthID));
		get_user_name(id, szName, charsmax(szName));
		get_user_ip(id, szIp, charsmax(szIp), 1);
		new iFileSize = file_size(PATH, 1) - 1;
		g_iTimeConnect[id] = get_systime(); // запоминаем время подключения
		new szStr[512], iPos = 0, szNameFile[32], szAuthIDFile[32], szIpFile[32], bool:bIsInFile = false, szUserTimeLeft[22][10], szNum[10];
		server_print("[DEBUG] if(file_exists(PATH))_start_7");
		while(iPos < iFileSize) // бежим по файлу, в поисках нужного steamID
		{
			new iLen;
			iPos = read_file(PATH, iPos, szStr, charsmax(szStr), iLen);
			if(szStr[0] == ';') continue;
			parse(szStr, szNum, 10, szNameFile, charsmax(szNameFile), szAuthIDFile, charsmax(szAuthIDFile), szIpFile, charsmax(szIpFile), szCost, charsmax(szCost), szUserTimeLeft[0], 10, szUserTimeLeft[1], 10,
			szUserTimeLeft[2], 10, szUserTimeLeft[3], 10, szUserTimeLeft[4], 10, szUserTimeLeft[5], 10, szUserTimeLeft[6], 10, szUserTimeLeft[7], 10, szUserTimeLeft[8], 10,
			szUserTimeLeft[9], 10, szUserTimeLeft[10], 10, szUserTimeLeft[11], 10, szUserTimeLeft[12], 10, szUserTimeLeft[13], 10, szUserTimeLeft[14], 10, szUserTimeLeft[15], 10,
			szUserTimeLeft[16], 10, szUserTimeLeft[17], 10, szUserTimeLeft[18], 10, szUserTimeLeft[19], 10, szUserTimeLeft[20], 10, szUserTimeLeft[21], 10);

			if(equal(szAuthIDFile, szAuthID)) // проверяем, нашли нужный или нет
			{
				g_iUserBalance[id] = str_to_num(szCost);
				for(new i; i < charsmax(g_szFlags); i++)
				{
					g_iUserTimeLeft[id][i] = str_to_num(szUserTimeLeft[i]);
					g_iUserNum[id] = str_to_num(szNum);
					if(g_iUserTimeLeft[id][i] > 0)
					{
						new szName[32]; get_user_name(id, szName, charsmax(szName));
						g_bUserHasFlag[id][i] = true;
						new szFlag[1]; szFlag[0] = g_szFlags[i];
						remove_user_flags(id, read_flags(g_szFlags));
						if(!(get_user_flags(id) & read_flags("t")))
							set_user_flags(id, read_flags("t"));
						console_print(0, "[LOG] Setting flag %s to %s %s", szFlag, szName, (get_user_flags(id) & read_flags(szFlag) ? "YES" : "NO"));
					}
				}
				/*if(iPos == 0)
				{
					g_iUserPos[id] = iFileSize - 1;
				}
				else
				{
					g_iUserPos[id] = iPos - 1;
				}*/
				bIsInFile = true;
				return PLUGIN_CONTINUE;
			}
		}
		if(!bIsInFile)
		{
			new szStr[512];
			formatex(szStr, charsmax(szStr), "%d ^"%s^" ^"%s^" ^"%s^" 0 %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", iFileSize, szName, szAuthID, szIp, STARTTIME, STARTTIME, STARTTIME, STARTTIME,
			 STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME, STARTTIME); // формируем строчку
			write_file(PATH, szStr); // добавляем в конец файла данные игрока
			//g_iUserPos[id] = iFileSize - 1;
			g_iUserNum[id] = iFileSize;
			for(new i = 0; i < charsmax(g_szFlags); i++)
				g_iUserTimeLeft[id][i] = STARTTIME;
			return PLUGIN_CONTINUE;
		}
	}
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	if(file_exists(PATH))
	{
		new szStr[512];
		//new iLen;
		//read_file(PATH, g_iUserPos[id], szStr, charsmax(szStr), iLen);
		for(new i; i < charsmax(g_szFlags); i++)
		{
			if(g_bUserHasFlag[id][i])
			{
				g_bUserHasFlag[id][i] = false;
				g_iUserTimeLeft[id][i] = max(0, g_iUserTimeLeft[id][i] - (get_systime() - g_iTimeConnect[id]));
			}
		}
		new szAuthID[32], szName[32], szIp[32];
		get_user_authid(id, szAuthID, charsmax(szAuthID));
		get_user_name(id, szName, charsmax(szName));
		get_user_ip(id, szIp, charsmax(szIp), 1);
		formatex(szStr, charsmax(szStr), "%d ^"%s^" ^"%s^" ^"%s^" %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",  g_iUserNum[id], szName, szAuthID, szIp, g_iUserBalance[id], g_iUserTimeLeft[id][0], g_iUserTimeLeft[id][1],
			g_iUserTimeLeft[id][2], g_iUserTimeLeft[id][3], g_iUserTimeLeft[id][4], g_iUserTimeLeft[id][5], g_iUserTimeLeft[id][6], g_iUserTimeLeft[id][7], g_iUserTimeLeft[id][8],
			g_iUserTimeLeft[id][9], g_iUserTimeLeft[id][10], g_iUserTimeLeft[id][11], g_iUserTimeLeft[id][12], g_iUserTimeLeft[id][13], g_iUserTimeLeft[id][14], g_iUserTimeLeft[id][15],
			g_iUserTimeLeft[id][16], g_iUserTimeLeft[id][17], g_iUserTimeLeft[id][18], g_iUserTimeLeft[id][19], g_iUserTimeLeft[id][20], g_iUserTimeLeft[id][21]); // формируем строчку
		write_file(PATH, szStr, g_iUserNum[id]); // записываем измененные данные игрока
	}
	// сбрасываем значения, чтобы ничего не перепуталось при новом подключении
	for(new i; i < charsmax(g_szFlags); i++)
	{
		g_iUserTimeLeft[id][i] = 0;
	}
	g_iUserBalance[id] = 0;
	g_iTimeConnect[id] = 0;
	return PLUGIN_CONTINUE;
}

public ShowData(id)
{
	UTIL_SayText(id, "!g%s !yОсталось секунд %d", DATA_PREFIX, g_iUserTimeLeft[id]);
	return PLUGIN_HANDLED;
}