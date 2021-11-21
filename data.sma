#include <amxmodx>
#include <saytext>

#define PLUGIN "Data"
#define VER "0.1"
#define AUTHOR "7heHex"

#define PATH "addons/amxmodx/configs/data.ini"
#define STARTTIME -1
#define DATA_PREFIX "!gSERVER !t|"
#define MAX_PLAYERS 32

#pragma tabsize 2
#pragma semicolon 1

new g_iUserTimeLeft[MAX_PLAYERS + 1], g_iUserPos[MAX_PLAYERS + 1], g_iTimeConnect[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VER, AUTHOR);
	register_clcmd("say /tm", "ShowData");
}

public client_putinserver(id)
{
	if(file_exists(PATH))
	{
		new szAuthID[32], szName[32], szIp[32];
		get_user_authid(id, szAuthID, charsmax(szAuthID));
		get_user_name(id, szName, charsmax(szName));
		get_user_ip(id, szIp, charsmax(szIp), 1);
		new iFileSize = file_size(PATH, 1) - 1;
		g_iTimeConnect[id] = get_systime(); // запоминаем время подключения
		new szStr[512], iPos = 0, szNameFile[32], szAuthIDFile[32], szIpFile[32], szTime[10], bool:bIsInFile = false;
		while(iPos < iFileSize) // бежим по файлу, в поисках нужного steamID
		{
			new iLen;
			iPos = read_file(PATH, iPos, szStr, charsmax(szStr), iLen); 
			parse(szStr, szNameFile, charsmax(szNameFile), szAuthIDFile, charsmax(szAuthIDFile), szIpFile, charsmax(szIpFile), szTime, charsmax(szTime)); // парсим данные из файла
			if(equal(szAuthIDFile, szAuthID)) // проверяем, нашли нужный или нет
			{
				g_iUserTimeLeft[id] = str_to_num(szTime);
				if(g_iUserTimeLeft[id] > 0) // если оставшееся время больше нуля, то..
				{
					// тут добавляй, что хочешь
				}
				if(iPos == 0)
				{
					g_iUserPos[id] = iFileSize - 1;
				}
				else
				{
					g_iUserPos[id] = iPos - 1;
				}
				bIsInFile = true;
				return PLUGIN_CONTINUE;
			}
		}
		if(!bIsInFile)
		{
			new szStr[512];
			formatex(szStr, charsmax(szStr), "^"%s^" ^"%s^" ^"%s^" %d", szName, szAuthID, szIp, STARTTIME); // формируем строчку
			write_file(PATH, szStr); // добавляем в конец файла данные игрока
			g_iUserPos[id] = iFileSize - 1;
			g_iUserTimeLeft[id] = -1;
		}
	}
	return PLUGIN_CONTINUE;
}

public client_disconnected(id)
{
	if(file_exists(PATH))
	{
		if(g_iUserTimeLeft[id] == -1) // если время у игрока не установлено, то не выполняем дальше
		{
			console_print(0, "if(g_iUserTimeLeft[id] == -1)");
			return PLUGIN_CONTINUE;
		}
		new szStr[512], szNameFile[32], szAuthIDFile[32], szIpFile[32], szTime[10];
		new iLen;
		read_file(PATH, g_iUserPos[id], szStr, charsmax(szStr), iLen);
		parse(szStr, szNameFile, charsmax(szNameFile), szAuthIDFile, charsmax(szAuthIDFile), szIpFile, charsmax(szIpFile), szTime, charsmax(szTime)); // парсим данные из файла
		new iTime = str_to_num(szTime);
		iTime = iTime - (get_systime() - g_iTimeConnect[id]); // получаем новое время
		if(iTime <= 0) // если время стало меньше нуля, то присваиваем -1
		{
			console_print(0, "if(iTime <= 0)");
			iTime = -1;
		}
		new szAuthID[32], szName[32], szIp[32];
		get_user_authid(id, szAuthID, charsmax(szAuthID));
		get_user_name(id, szName, charsmax(szName));
		get_user_ip(id, szIp, charsmax(szIp), 1);
		formatex(szStr, charsmax(szStr), "^"%s^" ^"%s^" ^"%s^" %d", szName, szAuthID, szIp, iTime); // формируем строчку
		if(write_file(PATH, szStr, g_iUserPos[id])) // записываем измененные данные игрока
		{
			console_print(0, "write_file(PATH, %s, g_iUserPos[id])", szStr);
		}
	}
	// сбрасываем значения, чтобы ничего не перепуталось при новом подключении
	g_iUserTimeLeft[id] = 0;
	g_iUserPos[id] = 0;
	g_iTimeConnect[id] = 0;
	return PLUGIN_CONTINUE;
}

public ShowData(id)
{
	UTIL_SayText(id, "!g%s !yОсталось секунд %d", DATA_PREFIX, g_iUserTimeLeft[id]);
	return PLUGIN_HANDLED;
}