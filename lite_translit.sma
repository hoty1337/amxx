// *************************************************************************************//
// Плагин загружен с  www.neugomon.ru                                                   //
// Автор: Neygomon  [ https://neugomon.ru/members/1/ ]                                  //
// Официальная тема поддержки: https://neugomon.ru/threads/110/                         //
// При копировании материала ссылка на сайт www.neugomon.ru ОБЯЗАТЕЛЬНА!                //
// *************************************************************************************//
#include <amxmodx>
#if AMXX_VERSION_NUM < 183 
	#include <colorchat>
#endif
#include <csstatsx_sql>
/*
	Спасибо PRoSToTeM@ за новый способ транслитерации
*/

#define TAGS				// Теги в чате Гл. Админ | Админ | VIP  [ По умолчанию включен ]
#if defined TAGS
#define LT_PREFIXES		// Свои префиксы. Файл addons/amxmodx/configs/lt_prefixes.ini [ По умолчанию выключен ]
#endif
//#define STEAM				// Тег стим игрока [ По умолчанию выключен ]
#define GREEN_MSG			// Зеленый цвет чата админов и випов [ По умолчанию выключен ]
#define AES				// Поддержка системы армейских званий - AES ( http://c-s.net.ua/forum/topic56564.html ) [ По умолчанию выключен ]
#define SKILL
//#define DEF_RUS			// Русский язык по умолчанию [ По умолчанию английский ]
#define GL_ADMIN 	ADMIN_RCON	// Флаг доступа для тега "Гл. Админ" в чате
#define ADMIN 		ADMIN_BAN	// Флаг доступа для тега "Админ" в чате
#define VIP		ADMIN_LEVEL_G	// Флаг доступа для тега "VIP" в чате
#define ANTIFLOOD			// Замена стандартного плагина antiflood.amxx [ По умолчанию выключен ]
#define AD_TIME		0.75		// Время между сообщениями, когда сработает антифлуд система
//#define ADMIN_ALLCHAT			// Показывать весь чат админам [ По умолчанию включен ]
#define DEFAULT_CS_CHAT		// Cтандартный чат кс  [ По умолчанию выключен ]
						//Живые общаются только с живыми, мертвые с мертвыми. Админ видит весь чат если ADMIN_ALLCHAT
#if defined AES
enum _: 
{ 
	AES_ST_EXP, 
	AES_ST_LEVEL, 
	AES_ST_BONUSES, 
	AES_ST_NEXTEXP, 
	AES_ST_END
};
native aes_get_player_stats(id, data[4]);
native aes_get_level_name(lvlnum, level[], len, idLang = 0);

public plugin_natives()
	set_native_filter("native_filter");
	
public native_filter(const name[], index, trap)
	return !trap ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
#endif	

new const g_chConvert[94 * 2 char] = 
{
	0x2100D0AD, 0x2300D0B6, 0x25003F00, 0xD18D2800, 0x29002A00, 0x2B00D0B1, 0x2D00D18E, 0x2E003000,
	0x31003200, 0x33003400, 0x35003600, 0x37003800, 0x3900D096, 0xD0B6D091, 0x3D00D0AE, 0x2C002200,
	0xD0A4D098, 0xD0A1D092, 0xD0A3D090, 0xD09FD0A0, 0xD0A8D09E, 0xD09BD094, 0xD0ACD0A2, 0xD0A9D097,
	0xD099D09A, 0xD0ABD095, 0xD093D09C, 0xD0A6D0A7, 0xD09DD0AF, 0xD1855C00, 0xD18A3A00, 0x5F00D191,
	0xD184D0B8, 0xD181D0B2, 0xD183D0B0, 0xD0BFD180, 0xD188D0BE, 0xD0BBD0B4, 0xD18CD182, 0xD189D0B7,
	0xD0B9D0BA, 0xD18BD0B5, 0xD0B3D0BC, 0xD186D187, 0xD0BDD18F, 0xD0A52F00, 0xD0AAD081
};

new bool:g_bUseRus[33];
#if defined STEAM
new bool:g_bIsSteam[33];
#endif
#if defined LT_PREFIXES
enum _:DATA 
{ 
	TYPE[2], 
	AUTH[32], 
	PREFIX[64] 
};
new Array:g_aData, g_PlayerData[DATA];
new g_szPrefix[33][64];
#endif

new const g_skill_letters[][] = {
	"L-",
	"L",
	"L+",
	"M-",
	"M",
	"M+",
	"H-",
	"H",
	"H+",
	"P-",
	"P",
	"P+",
	"G"
}
new Float:g_skill_opt[sizeof g_skill_letters]

new g_cvar_skill

#define	GetBit(%1,%2)		(%1 & (1 << (%2 & 31)))
#define	SetBit(%1,%2)		%1 |= (1 << (%2 & 31))
#define	ResetBit(%1,%2)		%1 &= ~(1 << (%2 & 31))
#if defined ADMIN_ALLCHAT
new g_bitAdmin;
#endif
new g_bitAlive;

public plugin_init()
{
#define VERSION "2.8"
	register_plugin("Lite Translit", VERSION, "neygomon");
	register_cvar("lt_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	
	register_clcmd("say /rus", "LangCtrlRus");
	register_clcmd("say /eng", "LangCtrlEng");
	
	register_clcmd("say", "HandlerSay");
	register_clcmd("say_team", "HandlerSayTeam");
	
	
	register_event("ResetHUD", "eResetHUD", "be");
	register_event("DeathMsg", "eDeathMsg", "a", "1>0");
	g_cvar_skill = register_cvar("aes_statsx_skill","60.0 75.0 85.0 100.0 115.0 130.0 140.0 150.0 165.0 180.0 195.0 210.0");
}

#if defined LT_PREFIXES
public plugin_cfg()
{
	new levelString[512], stPos, ePos, rawPoint[20], cnt
	get_pcvar_string(g_cvar_skill, levelString, charsmax(levelString))
	
	// парсер значений для скилла
	do {
		ePos = strfind(levelString[stPos], " ")
		
		formatex(rawPoint, ePos, levelString[stPos])
		g_skill_opt[cnt] = str_to_float(rawPoint)
		
		stPos += ePos + 1
		
		cnt++
		
		// narkoman wole suka
		if(cnt > charsmax(g_skill_letters))
			break
	} while (ePos != -1)
	
	g_aData = ArrayCreate(DATA);

	new buff[256], fp = fopen("addons/amxmodx/configs/lt_prefixes.ini", "rt");
	if(!fp) return set_fail_state("File ^"addons/amxmodx/configs/lt_prefixes.ini^" not found");

	while(!feof(fp))
	{
		fgets(fp, buff, charsmax(buff));
		if(buff[0] && buff[0] != ';' && parse(buff, g_PlayerData[TYPE], charsmax(g_PlayerData[TYPE]), g_PlayerData[AUTH], charsmax(g_PlayerData[AUTH]), g_PlayerData[PREFIX], charsmax(g_PlayerData[PREFIX])))
			ArrayPushArray(g_aData, g_PlayerData);
	}
	return fclose(fp);
	
}
#endif
public client_putinserver(id)
{
#if defined LT_PREFIXES
	SearchClient(id);
#endif	
#if defined DEF_RUS
	g_bUseRus[id] = true;
#else
	g_bUseRus[id] = false;
#endif
#if defined STEAM
	g_bIsSteam[id] = is_user_steam(id) ? true : false;
#endif
#if defined ADMIN_ALLCHAT
	if(get_user_flags(id) & ADMIN_CHAT) SetBit(g_bitAdmin, id);
	else ResetBit(g_bitAdmin, id);
#endif
}

public client_disconnected(id) 	ResetBit(g_bitAlive, id);
public eResetHUD(id) 		SetBit(g_bitAlive, id);
public eDeathMsg() 		ResetBit(g_bitAlive, read_data(2));	

public HandlerSay(id) return FormatMsg(id, false);
public HandlerSayTeam(id) return FormatMsg(id, true);

public LangCtrlRus(id)
{
	if(g_bUseRus[id])
		client_print(id, print_chat, "*** [LT] Русский язык УЖЕ включен! ***");
	else 
	{
		client_print(id, print_chat, "*** [LT] Русский язык активирован! ***");
		g_bUseRus[id] = true;
		client_cmd(id, "spk buttons/blip1.wav");
	}
}

public LangCtrlEng(id)
{
	if(!g_bUseRus[id])
		client_print(id, print_chat, "*** [LT] Английский язык УЖЕ включен! ***");
	else
	{
		client_print(id, print_chat, "*** [LT] Английский язык активирован! ***");
		g_bUseRus[id] = false;
		client_cmd(id, "spk buttons/blip1.wav");
	}
} 

FormatMsg(id, bool:IsTeam)
{
#define MAX_BYTES 180
	static sMessage[MAX_BYTES], sConvertStr[charsmax(sMessage) * 2 + 1]; 
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage); trim(sMessage);

	if(sMessage[0] == EOS || sMessage[0] == '/')
		return PLUGIN_HANDLED_MAIN;
#if defined ANTIFLOOD
	static Float:fTimeFlood[33], Float:fGameTime, iFloodWarn[33];
		
	if(fTimeFlood[id] > (fGameTime = get_gametime()))
	{
		if(++iFloodWarn[id] > 2)
		{			
			client_print(id, print_chat, "*** [LT] Прекратите флудить! ***");
			fTimeFlood[id] = fGameTime + AD_TIME + 3.0;
			return PLUGIN_HANDLED;
		}
	}
	else if(iFloodWarn[id]) iFloodWarn[id]--;
	fTimeFlood[id] = fGameTime + AD_TIME;
#endif
	static iLen, sTags[MAX_BYTES], idTeam, sTeam[16];
	idTeam  = get_user_team(id, sTeam, charsmax(sTeam));

	switch(idTeam)
	{
		case 1: iLen = formatex(sTags, charsmax(sTags), "%s%s", GetBit(g_bitAlive, id) ? "^1" : "^1*^3Мертвый^1* ", IsTeam ? "^1[^3TT^1]" : "");
		case 2: iLen = formatex(sTags, charsmax(sTags), "%s%s", GetBit(g_bitAlive, id) ? "^1" : "^1*^3Мертвый^1* ", IsTeam ? "^1[^3CT^1]" : "");
		default:iLen = formatex(sTags, charsmax(sTags), "^1*^3Spec^1* ");
	}
#if defined GREEN_MSG || (defined TAGS && !defined LT_PREFIXES)
	static IsAccess; IsAccess = CheckFlags(id);
#endif	
#if defined AES
	static AESLvl[33][64], aStats[AES_ST_END];
	aes_get_player_stats(id, aStats); aes_get_level_name(aStats[AES_ST_LEVEL], AESLvl[id], charsmax(AESLvl[]), LANG_SERVER);
	iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, "^4[%s] ", AESLvl[id]);
#endif
#if defined STEAM
	if(g_bIsSteam[id])
		iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, "^1[^4Steam^1] ");
#endif

#if defined SKILL
	new skill[3]
	statsx_get_user_skill_name(id, skill, charsmax(skill))

	iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, "^1[^4%s^1]", skill)

#endif

#if defined TAGS	
	#if defined LT_PREFIXES
	if(g_szPrefix[id][0])
	{
		replace_all(g_szPrefix[id], charsmax(g_szPrefix[]), "!n", "^1");
		replace_all(g_szPrefix[id], charsmax(g_szPrefix[]), "!t", "^3");
		replace_all(g_szPrefix[id], charsmax(g_szPrefix[]), "!g", "^4");
		iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, "%s ", g_szPrefix[id]);
	}	
	#else
	static const szAdminPrefix[][] = { "", "^1[^4Гл. Админ^1] ", "^1[^4Админ^1] ", "^1[^4VIP^1] " };
	iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, "%s", szAdminPrefix[IsAccess]);
	#endif
#endif	
	static sName[32];
	get_user_name(id, sName, charsmax(sName));
#if defined GREEN_MSG
	iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, "^3%s^1 :  %s", sName, IsAccess ? "^4" : "");
#else
	iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, "^3%s^1 :  ", sName);
#endif 
	if(g_bUseRus[id])
	{
		new nLen;
		for(new n; sMessage[n] != EOS; n++)
		{
			if('!' <= sMessage[n] <= '~')
			{
				sConvertStr[nLen++] = g_chConvert{(sMessage[n] - '!') * 2};
				if(g_chConvert{(sMessage[n] - '!') * 2 + 1} != EOS)
					sConvertStr[nLen++] = g_chConvert{(sMessage[n] - '!') * 2 + 1};
			} 
			else sConvertStr[nLen++] = sMessage[n];
		}
		sConvertStr[nLen] = EOS;
	} 
	else sConvertStr = sMessage;
	
	static iByteLimit; iByteLimit = MAX_BYTES;
	while(iLen + strlen(sConvertStr) > MAX_BYTES)
		sConvertStr[iByteLimit -= 10] = 0;
	
	iLen += formatex(sTags[iLen], charsmax(sTags) - iLen, sConvertStr);
	
	static players[32], pcount; get_players(players, pcount, "c");
	switch(IsTeam)
	{
		case true:
		{
			for(new i; i <= get_maxplayers(); i++)
			{
				if(!is_user_connected(i)) continue;
#if defined ADMIN_ALLCHAT				
				if(GetBit(g_bitAdmin, i) || (GetBit(g_bitAlive, id) == GetBit(g_bitAlive, i) && idTeam == get_user_team(i)))
#else
				if((GetBit(g_bitAlive, id) == GetBit(g_bitAlive, i)) && idTeam == get_user_team(i))
#endif
					SendMsgChat(i, idTeam, sTags);
			}								
		}
		case false:
		{	
			for(new i; i <= get_maxplayers(); i++)
			{
				if(!is_user_connected(i)) continue;
#if defined DEFAULT_CS_CHAT			
	#if defined ADMIN_ALLCHAT			
				if(GetBit(g_bitAdmin, i) || GetBit(g_bitAlive, id) == GetBit(g_bitAlive, i))
	#else
				if(GetBit(g_bitAlive, id) == GetBit(g_bitAlive, i))
	#endif				
					SendMsgChat(i, idTeam, sTags);
#else
				SendMsgChat(i, idTeam, sTags);
#endif	
			}
		}

	}
	static sAuthId[25]; get_user_authid(id, sAuthId, charsmax(sAuthId));
	log_message("^"%s<%d><%s><%s>^" %s ^"%s^"", sName, get_user_userid(id), sAuthId, sTeam, IsTeam ? "say_team" : "say" , sConvertStr);	
	return PLUGIN_HANDLED;
}

stock SendMsgChat(player, team, msg[])
{
	switch(team)
	{
		case 1: client_print_color(player, print_team_red, msg);
		case 2: client_print_color(player, print_team_blue, msg);
		default:client_print_color(player, print_team_grey, msg);
	}
}

stock SearchClient(const id)
{
	for(new i; i < ArraySize(g_aData); i++)
	{
		ArrayGetArray(g_aData, i, g_PlayerData);
		switch(g_PlayerData[TYPE])
		{
			case 'f': 
			{
				if(get_user_flags(id) & read_flags(g_PlayerData[AUTH]))
					return copy(g_szPrefix[id], charsmax(g_szPrefix[]), g_PlayerData[PREFIX]);
			}	
			case 'i': 
			{
				static sIP[16]; get_user_ip(id, sIP, charsmax(sIP), 1);
				if(!strcmp(g_PlayerData[AUTH], sIP)) 
					return copy(g_szPrefix[id], charsmax(g_szPrefix[]), g_PlayerData[PREFIX]);
			}		
			case 's': 
			{
				static sAuthid[25]; get_user_authid(id, sAuthid, charsmax(sAuthid));
				if(!strcmp(g_PlayerData[AUTH], sAuthid)) 
					return copy(g_szPrefix[id], charsmax(g_szPrefix[]), g_PlayerData[PREFIX]);
			}		
		}
	}
	return g_szPrefix[id][0] = 0;
}

stock CheckFlags(id)
{
	static iFlags; iFlags = get_user_flags(id);
	if(iFlags & GL_ADMIN) 	return 1;
	else if(iFlags & ADMIN) return 2;
	else if(iFlags & VIP) 	return 3;
	return 0;
}

stock bool:is_user_steam(id)
{
	static dp_pointer;
	if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
	{
		server_cmd("dp_clientinfo %d", id);
		server_exec();
		return (get_pcvar_num(dp_pointer) == 2) ? true : false;
	}
	return false;
}

statsx_get_user_skill_name(id, name[], len)
{
	new Float:skill
	get_user_skill(id, skill)
	
	new skill_id = statsx_get_skill_id(skill)
	copy(name, len, g_skill_letters[skill_id])
}

statsx_get_skill_id(Float:skill)
{
	for(new i = 0; i < sizeof(g_skill_opt); i++)
	{
		if(skill < g_skill_opt[i])
			return i
	}
	return charsmax(g_skill_opt)
}