#include <amxmodx>
#include <amxmisc>

#pragma tabsize 4
#pragma semicolon 1

#define AUTHOR  "7heHex"
#define VER     "0.1"
#define PLUGIN  "NewAdmSystem"

new const szSetInfoPass[] = "_pw" ;
new const szAllFlags[] = "abcdefghijklmnopqrstuvwxyz1234567890";
new szUserFlags[32][36];
new bool:wrongPass[32];
new szPath[64];

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
    new path[64];
    get_configsdir(path, charsmax(path));
    formatex(szPath, charsmax(szPath), "%s/admins.ini", path);
}

public plugin_natives()
{
	register_native("userHasFlag", "userHasFlag");
}

public client_connect(id)
{
	if(file_exists(szPath))
	{
		new iFileSize = file_size(szPath, 1);
		new szStr[512], iPos = 0, szArg1[32], szPass[64], szFlags[64], szAuthFlags[2];
		while(iPos != -1 && iPos < iFileSize)
		{
			new iLen;
			iPos = read_file(szPath, iPos, szStr, charsmax(szStr), iLen);
			iPos = (iPos == 0 ? -1 : iPos);
			if(szStr[0] == ';' || equal(szStr, "")) continue;
            parse(szStr, szArg1, charsmax(szArg1), szPass, charsmax(szPass), szFlags, charsmax(szFlags), szAuthFlags, charsmax(szAuthFlags));
			new bool:bUserInFile = false;
            for(new i; i < charsmax(szAuthFlags); i++)
            {
                if(szAuthFlags[i] == 'a')
                {
            		new szPlayerName[32];
					get_user_name(id, szPlayerName, charsmax(szPlayerName));
					if(equal(szPlayerName, szArg1)) 
					{
						bUserInFile = true;
					}
				}
				else if(szAuthFlags[i] == 'c')
				{
					new szAuthID[64];
					get_user_authid(id, szAuthID, charsmax(szAuthID));
					if(equal(szAuthID, szArg1)) 
					{
						bUserInFile = true;
					}
				}
				else if(szAuthFlags[i] == 'd')
				{
					new szUserIP[64];
					get_user_ip(id, szUserIP, charsmax(szUserIP), 1);
					if(equal(szUserIP, szArg1)) 
					{
						bUserInFile = true;
					}
				}
			}
			if(!bUserInFile) 
			{
				log_error(1337, "not found");
				continue;
			}

			new szUserPass[64];
			get_user_info(id, szSetInfoPass, szUserPass, charsmax(szUserPass));

			if(equal(szPass, szUserPass))
			{
				formatex(szUserFlags[id], charsmax(szAllFlags), "%s", szFlags);
				new defFlags[] = "abcdefghijklmnopqrstuyz";
				for(new i; i < charsmax(defFlags); i++)
				{
					new szTemp[10];
					formatex(szTemp, 1, "%c", defFlags[i]);
					if(strfind(szUserFlags[id], szTemp) != -1)
						set_user_flags(id, (1<<i));
				}
				log_amx("%n has %s", id, szUserFlags[id]);
			}
			else
			{
				for(new j; j < charsmax(szAuthFlags); j++)
				{
					if(szAuthFlags[j] == 'e')
					{
						formatex(szUserFlags[id], charsmax(szAllFlags), "%s", szFlags);
						new defFlags[] = "abcdefghijklmnopqrstuyz";
						for(new i; i < charsmax(defFlags); i++)
						{
							new szTemp[10];
							formatex(szTemp, 1, "%c", defFlags[i]);
							if(strfind(szUserFlags[id], szTemp) != -1)
								set_user_flags(id, (1<<i));
						}
						log_amx("%n has %s", id, szUserFlags[id]);	
						return PLUGIN_CONTINUE;
					}
				}
				wrongPass[id] = true;
			}
		}
	}
	else log_error(1337, "!if(file_exists(szPath))");
	return PLUGIN_CONTINUE;
}

public client_putinserver(id)
{
	if(wrongPass[id])
	{
		wrongPass[id] = false;
		new szName[32]; get_user_name(id, szName, 32);
		log_amx("kick %s", szName);
		server_cmd("kick ^"%s^" ^"Неверный пароль. Используйте setinfo %s <ваш_пароль>, чтобы ввести пароль.^"", szName, szSetInfoPass);
	}
	//log_amx("%s", szUserFlags[id]);
}

public client_disconnected(id)
{
	formatex(szUserFlags[id], charsmax(szAllFlags), "");
}

public userHasFlag(plugin, params)
{
	new id = get_param(1);
	new szFlag[36];
	get_string(2, szFlag, 36);
	if(strfind(szUserFlags[id], szFlag) != -1) 
	{
		return true;
	}
	return false;
}