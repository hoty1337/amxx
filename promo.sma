#include <amxmodx>
#include <saytext>

#define PLUGIN "PromoCodes"
#define VER "0.2"
#define AUTHOR "7heHex"

#pragma tabsize 2
#pragma semicolon 1

#define PATH 		"addons/amxmodx/configs/promo.ini"
#define PATH_PRIV	"addons/amxmodx/configs/users.ini"
#define PATH_MODEL	"addons/amxmodx/configs/models.ini"

#define FLAGS_VIP	"t"
#define FLAGS_SVIP	"te"
#define FLAGS_ADMIN	"cdefjgtum"

public plugin_init()
{
	register_plugin(PLUGIN, VER, AUTHOR);
	register_clcmd("say /promo", "activatePromo");
	register_clcmd("code", "ClCmd_Promo");
}

public activatePromo(id)
{
	client_cmd(id, "messagemode code");
}

public ClCmd_Promo(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		UTIL_SayText(id, "!gХикки Задрот !t| !yУ вас уже имеется привилегия.");
		return PLUGIN_HANDLED;
	}
	new szCode[32], iStr;
	read_argv(1, szCode, charsmax(szCode));
	iStr = file_size(PATH, 1);
	for(new i = 0; i < iStr; i++)
	{
		new szTemp[128], iLen, szCodeTemp[32], szPriv[33], szDate[32], szFlags[32], szTEModel[32], szCTModel[32];
		read_file(PATH, i, szTemp, charsmax(szTemp), iLen);
		if(iLen == 0 || szTemp[0] == ';') continue;
		parse(szTemp, szCodeTemp, charsmax(szCodeTemp), szPriv, charsmax(szPriv), szDate, charsmax(szDate), szTEModel, charsmax(szTEModel), szCTModel, charsmax(szCTModel));
		if(equal(szCode, szCodeTemp))
		{
			switch(szPriv[0])
			{
				case 'v':
				{
					szFlags = FLAGS_VIP;
					UTIL_SayText(id, "!gХикки Задрот !t| !yВы успешно активировали промокод и получили !gVIP!y!");
				}
				case 's':
				{
					szFlags = FLAGS_SVIP;
					UTIL_SayText(id, "!gХикки Задрот !t| !yВы успешно активировали промокод и получили !gSUPERVIP!y!");
				}
				case 'a':
				{
					szFlags = FLAGS_ADMIN;
					UTIL_SayText(id, "!gХикки Задрот !t| !yВы успешно активировали промокод и получили !gADMIN!y!");
				}
			}
			// "STEAM_0:0:103158126" "" "еpt" "ce" "STEAM_0:0:103158126" "lifetime" //ТЕСТ ПЛАГИНОВ
			new szStr[256], szAuthId[32], szTime[32], szDateTime[32];
			get_user_authid(id, szAuthId, charsmax(szAuthId));
			get_time("%H:%M:%S", szTime, charsmax(szTime));
			formatex(szDateTime, charsmax(szDateTime), "%s - %s", szDate, szTime);
			formatex(szStr, charsmax(szStr), "^"%s^" ^"^" ^"%s^" ^"ce^" ^"%s^" ^"%s^" // активировал код", szAuthId, szFlags, szAuthId, szDateTime);
			write_file(PATH_PRIV, szStr, -1);
			if(!equali(szTEModel, "") && !equali(szCTModel, ""))
			{
				formatex(szStr, charsmax(szStr), "^"%s^" ^"%s^" ^"%s^" // активировал код", szAuthId, szTEModel, szCTModel);
				write_file(PATH_MODEL, szStr, -1);
			}
			write_file(PATH, "", i);
			return PLUGIN_HANDLED;
		}
	}
	UTIL_SayText(id, "!gХикки Задрот !t| !yВы ввели неверный промокод.");
	return PLUGIN_HANDLED;
}
