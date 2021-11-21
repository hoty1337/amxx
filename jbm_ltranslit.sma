#include <amxmodx>
#include <fakemeta>
#include <jbm_api>
#if AMXX_VERSION_NUM < 183 
	#include <colorchat>
#endif

#define ADMIN_GREEN_CHAT		// Зеленый чат для админоа
#define FIX_CRASH			// Костыль от падения сервера с ошибкой о превышении 192 байтов. Дак вот, включать ТОЛЬКО если сервер падает.

#define SetBit(%0,%1) 	((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))

new g_iBitIgnorePlayer, g_iBitTranslate, g_iBitFlagPrefix, g_iBitCustomPrefix;
new const g_chConvert[94 * 2 char] =
{
	0x2100D0AD, 0x2300D0B6, 0x25003F00, 0xD18D2800, 0x29002A00, 0x2B00D0B1, 
	0x2D00D18E, 0x2E003000, 0x31003200, 0x33003400, 0x35003600, 0x37003800, 
	0x3900D096, 0xD0B6D091, 0x3D00D0AE, 0x2C002200, 0xD0A4D098, 0xD0A1D092, 
	0xD0A3D090, 0xD09FD0A0, 0xD0A8D09E, 0xD09BD094, 0xD0ACD0A2, 0xD0A9D097, 
	0xD099D09A, 0xD0ABD095, 0xD093D09C, 0xD0A6D0A7, 0xD09DD0AF, 0xD1855C00, 
	0xD18A3A00, 0x5F00D191, 0xD184D0B8, 0xD181D0B2, 0xD183D0B0, 0xD0BFD180, 
	0xD188D0BE, 0xD0BBD0B4, 0xD18CD182, 0xD189D0B7, 0xD0B9D0BA, 0xD18BD0B5, 
	0xD0B3D0BC, 0xD186D187, 0xD0BDD18F, 0xD0A52F00, 0xD0AAD081
};

#define PREFIX_MAX_LENGHT 64
#define COLOR_BUFFER 6
#define FILE_PREFIXES "jb_mode/player_prefixes.ini"

enum _:FLAG_PREFIX_INFO
{
	m_Flag,
	m_Prefix[PREFIX_MAX_LENGHT]
};

new g_PlayerPrefix[33][PREFIX_MAX_LENGHT], g_szForcePrefix[33][PREFIX_MAX_LENGHT];
new Trie:g_tSteamPrefixes, g_iTrieSteamSize;
new Trie:g_tNamePrefixes, g_iTrieNameSize;
new Array:g_aFlagPrefixes, g_iArrayFlagSize;

public plugin_init()
{
	register_plugin("[JBM] LTranslit", "4.0", "neygomon");
	
	register_clcmd("say /rus", 	"LangRus");
	register_clcmd("say /eng", 	"LangEng");
	register_clcmd("say",	 	"Say_Handler");
	register_clcmd("say_team", 	"SayTeam_Handler");
}

public plugin_cfg()
{
	new szDir[128]; get_localinfo("amxx_configsdir", szDir, charsmax(szDir));
	new szFile[128]; formatex(szFile, charsmax(szFile), "%s/%s", szDir, FILE_PREFIXES);
	if(!file_exists(szFile))
	{
		log_amx("[LT] Prefixes file doesn't exist!");
		return;
	}
	g_tSteamPrefixes = TrieCreate(); 
	g_tNamePrefixes = TrieCreate();
	g_aFlagPrefixes = ArrayCreate(FLAG_PREFIX_INFO);
	new file = fopen(szFile, "rt");
	if(file)
	{
		new szText[128], szType[6], szAuth[32], szPrefix[PREFIX_MAX_LENGHT + COLOR_BUFFER], eFlagPrefix[FLAG_PREFIX_INFO], szDate[16];
		new g_iData[12], szReplaceText[64]; get_time("%d%m%Y", g_iData, charsmax(g_iData));
		new iLine;
		while(!feof(file))
		{
			iLine++;
			fgets(file, szText, charsmax(szText));
			parse(szText, szType, charsmax(szType), szAuth, charsmax(szAuth), szPrefix, charsmax(szPrefix), szDate, charsmax(szDate));
			if(!szType[0] || szType[0] == ';' || !szAuth[0] || !szPrefix[0]) continue;
			trim(szDate);
			replace_all(szDate, charsmax(szDate), "/", "");
			if(equal(g_iData, szDate))
			{
				formatex(szReplaceText, charsmax(szReplaceText), ";^"%s^" ^"%s^" ^"%s^" ^"Окончено^"", szType, szAuth, szPrefix);
				write_file(szFile, szReplaceText, iLine - 1);
				szDate = "";
				continue;
			}
			replace_color_tag(szPrefix);
			switch(szType[0])
			{
				case 's'://steam
				{
					TrieSetString(g_tSteamPrefixes, szAuth, szPrefix);
					g_iTrieSteamSize++;
				}
				case 'n'://name
				{
					TrieSetString(g_tNamePrefixes, szAuth, szPrefix);
					g_iTrieNameSize++;
				}
				case 'f'://flag
				{
					eFlagPrefix[m_Flag] = read_flags(szAuth);
					copy(eFlagPrefix[m_Prefix], charsmax(eFlagPrefix[m_Prefix]), szPrefix);
					ArrayPushArray(g_aFlagPrefixes, eFlagPrefix);
					g_iArrayFlagSize++;
				}
			}
		}
		fclose(file);
	}
}

//// Основное
public plugin_natives() register_native("jbm_get_lang", "_jbm_get_lang", 1);
public _jbm_get_lang(id) return IsSetBit(g_iBitTranslate, id);
public client_putinserver(id)
{
	if(is_user_hltv(id) || is_user_bot(id)) {
		SetBit(g_iBitIgnorePlayer, id);
		return;
	}
	if(!is_user_steam(id)) SetBit(g_iBitTranslate, id);
	
	g_PlayerPrefix[id] = "";
	g_szForcePrefix[id] = "";
	ClearBit(g_iBitFlagPrefix, id);
	ClearBit(g_iBitCustomPrefix, id);
	
	new szSteam[32]; get_user_authid(id, szSteam, charsmax(szSteam));
	if(g_iTrieSteamSize && TrieKeyExists(g_tSteamPrefixes, szSteam)) {
		SetBit(g_iBitCustomPrefix, id);
		TrieGetString(g_tSteamPrefixes, szSteam, g_PlayerPrefix[id], charsmax(g_PlayerPrefix[]));
	}
}
public client_disconnected(id) ClearBit(g_iBitIgnorePlayer, id), ClearBit(g_iBitTranslate, id);
public LangRus(id)
{
	if(is_user_steam(id)) return;
	if(!IsSetBit(g_iBitTranslate, id)) {
		SetBit(g_iBitTranslate, id);
		client_print(id, print_chat, "*** [LT] Русский чат активирован! ***")
		client_cmd(id, "spk buttons/blip1.wav");
	} else client_print(id, print_chat, "*** [LT] Русский чат УЖЕ активирован! ***")
}
public LangEng(id)
{
	if(is_user_steam(id)) return;
	if(IsSetBit(g_iBitTranslate, id)){
		ClearBit(g_iBitTranslate, id);
		client_print(id, print_chat, "*** [LT] Английский чат активирован! ***")
		client_cmd(id, "spk buttons/blip1.wav");
	} else client_print(id, print_chat, "*** [LT] Английский чат УЖЕ активирован! ***")
}
public Say_Handler(id) return FormatMsg(id, false)
public SayTeam_Handler(id) return FormatMsg(id, true)
public FormatMsg(id, bool:is_say_team)
{
	if(IsSetBit(g_iBitIgnorePlayer, id)) return PLUGIN_CONTINUE
	new szName[32];
	new szMessage[500], szMsg[charsmax(szMessage) * 2 + 1], nLen;
	new iLen, szFormatTags[190];
	new iByteLimit; iByteLimit = 180;
	
	get_user_name(id, szName, charsmax(szName));
	new idTeam = jbm_get_user_team(id);
	switch(jbm_get_user_team(id))
	{
		case 1: iLen = formatex(szFormatTags, charsmax(szFormatTags), "%s%s", jbm_is_user_alive(id) ? "^1" : "^1*^3Dead^1* ", is_say_team ? "^1[^3TT^1] " : "");
		case 2: iLen = formatex(szFormatTags, charsmax(szFormatTags), "%s%s", jbm_is_user_alive(id) ? "^1" : "^1*^3Dead^1* ", is_say_team ? "^1[^3CT^1] " : "");
		default: iLen = formatex(szFormatTags, charsmax(szFormatTags), "^1*^3Spec^1* ");
	}
	if(g_iArrayFlagSize){
		new eFlagPrefix[FLAG_PREFIX_INFO]
		for(new i; i < g_iArrayFlagSize; i++){
			ArrayGetArray(g_aFlagPrefixes, i, eFlagPrefix);
			if(check_flags(get_user_flags(id), eFlagPrefix[m_Flag])){
				SetBit(g_iBitFlagPrefix, id);
				copy(g_szForcePrefix[id], charsmax(g_szForcePrefix[]), eFlagPrefix[m_Prefix]);
				break;
			}
		}
	}
	if(!IsSetBit(g_iBitCustomPrefix, id)){
		if(g_iTrieNameSize && TrieKeyExists(g_tNamePrefixes, szName)){
			SetBit(g_iBitCustomPrefix, id);
			TrieGetString(g_tNamePrefixes, szName, g_PlayerPrefix[id], charsmax(g_PlayerPrefix[]));
		}
	}
	if(IsSetBit(g_iBitFlagPrefix, id)) iLen += formatex(szFormatTags[iLen], charsmax(szFormatTags) - iLen, "^1[^4%s^1] ", g_szForcePrefix[id]);
	if(IsSetBit(g_iBitCustomPrefix, id)) iLen += formatex(szFormatTags[iLen], charsmax(szFormatTags) - iLen, "^1[^4%s^1] ", g_PlayerPrefix[id]);

#if defined ADMIN_GREEN_CHAT
	iLen += formatex(szFormatTags[iLen], charsmax(szFormatTags) - iLen, "^3%s^1: %s", szName, get_user_flags(id) & ADMIN_LEVEL_C ? "^4" : "");
#else
	iLen += formatex(szFormatTags[iLen], charsmax(szFormatTags) - iLen, "^3%s^1: ", szName);
#endif
	read_args(szMessage, charsmax(szMessage));
	remove_quotes(szMessage);
	if(!szMessage[0] || szMessage[0] == '/') return PLUGIN_HANDLED;  // блочим пустую мессагу и слеш в чате
	if(IsSetBit(g_iBitTranslate, id)){
		for(new n = 0; szMessage[n] != EOS; n++){
			if( '!' <= szMessage[n] <= '~' ){
				szMsg[nLen++] = g_chConvert{(szMessage[n] - '!') * 2};
				if(g_chConvert{(szMessage[n] - '!') * 2 + 1} != EOS ) szMsg[nLen++] = g_chConvert{(szMessage[n] - '!') * 2 + 1};
			}
			else szMsg[nLen++] = szMessage[n];
		}
		szMsg[nLen] = EOS;
	}
	else szMsg = szMessage;

	while(iLen + strlen(szMsg) > 180) szMsg[iByteLimit -= 10] = 0;
	iLen += formatex(szFormatTags[iLen], charsmax(szFormatTags) - iLen, "%s", szMsg);
	
#if defined FIX_CRASH
	if(strlen(szFormatTags) + strlen(szMsg) >= 190){
		client_print(id, print_center, "*** Ваше сообщение слишком длинное ***");
		return PLUGIN_HANDLED;
	}
#endif
	new players[32], pcount; get_players(players, pcount, "c")
	switch(is_say_team){
		case 0:{
			for(new i; i < pcount; i++)
			{
				SendMsgChat(players[i], idTeam, szFormatTags);
				new szCurrentTime[32];
				get_time("%X", szCurrentTime, charsmax(szCurrentTime));
				console_print(players[i], "[%s] %s: %s", szCurrentTime, szName, szMsg);
			}
		}
		case 1:{
			//if(get_user_flags(id) & ADMIN_RCON || (iTeam == get_user_team(players[i]) && iAlive == is_user_alive(players[i])));
			for(new i; i < pcount; i++){
				if(jbm_get_user_team(id) == jbm_get_user_team(players[i]))
				{	
					SendMsgChat(players[i], idTeam, szFormatTags);
					new szCurrentTime[32];
					get_time("%X", szCurrentTime, charsmax(szCurrentTime));
					console_print(players[i], "[TEAM CHAT] [%s] %s: %s", szCurrentTime, szName, szMsg);
				}
			}
		}
	}
	return PLUGIN_HANDLED;
}

//// Нативы

stock SendMsgChat(player, team, msg[])
{
	switch(team)
	{
		case 1: client_print_color(player, print_team_red, msg);
		case 2: client_print_color(player, print_team_blue, msg);
		default:client_print_color(player, print_team_grey, msg);
	}
}

replace_color_tag(string[])
{
	new len = 0;
	for (new i; string[i] != EOS; i++)
	{
		if (string[i] == '!')
		{
			switch (string[++i])
			{
				case 'd': string[len++] = 1;
				case 't': string[len++] = 3;
				case 'g': string[len++] = 4;
				case EOS: break;
				default: string[len++] = string[i];
			}
		}
		else string[len++] = string[i];
	}
	string[len] = EOS;
}

stock check_flags(flags, need_flags) return ((flags &= need_flags) == need_flags) ? 1 : 0;
	
stock bool:is_user_steam(id)
{
	static dp_pointer;
	if(dp_pointer || (dp_pointer = get_cvar_pointer("dp_r_id_provider")))
	{
		server_cmd("dp_clientinfo %d", id);
		server_exec();
		return (get_pcvar_num(dp_pointer) == 2) ? true : false;
	} return false;
}

public jb_gang_prefix(id, GangName[])
{
	if(g_PlayerPrefix[id][0])
		return PLUGIN_HANDLED

	if(GangName[0] && GangName[0] != '0')
		return formatex(g_PlayerPrefix[id], charsmax(g_PlayerPrefix[]), "^1[^4%s^1]", GangName);

	return g_PlayerPrefix[id][0] = 0;
}