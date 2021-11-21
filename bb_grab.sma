#include amxmodx
#include fakemeta_util
#include fun
#include fvault

#define SetBit(%0,%1) ((%0) |= (1 << (%1)))
#define ClearBit(%0,%1) ((%0) &= ~(1 << (%1)))
#define IsSetBit(%0,%1) ((%0) & (1 << (%1)))
#define InvertBit(%0,%1) ((%0) ^= (1 << (%1)))
#define IsNotSetBit(%0,%1) (~(%0) & (1 << (%1)))

#define is_user_grab(%0) (get_user_flags(id) & ADMIN_BAN)
#define BUBBLE_MODEL 	"models/objects/color_bubble.mdl"
#define FVAULT_NAME_COLOR		"COLOR_BUBBLE"
#define FVAULT_NAME_BUBBLE		"BUBBLE_BUBBLE"
#define FVAULT_NAME_LIGHT		"BUBBLE_LIGHT"

native jbm_add_user_free(id);
native jbm_sub_user_free(id);
native jbm_set_user_team(id, iTeam);
native jbm_is_user_free(id);
native jbm_reset_abil(pPlayer);
native jbm_add_user_wanted(pPlayer);
native jbm_sub_user_wanted(pPlayer);
native jbm_is_user_wanted(pPlayer);
native jbm_is_gg();
native stopAnim(id);

new g_iBitUserFrozen, g_iColorBubble[33], g_iBitBubble, g_iBitBubbleLight;

enum _:DATA_PLAYER {
	bool:ACTS, TARGET, GRABBED, GRABBER, FLAGS, GRAB_LEN, BB_INDEX
};

new g_iPlayers[33][DATA_PLAYER], g_iMaxPlayers, i_Sprite[5], bool:g_bIsGrabbed[33];

public plugin_precache() {
	engfunc(EngFunc_PrecacheModel, BUBBLE_MODEL);
}

public plugin_init() {
	register_plugin("JBM Bubble Grab", "2.0", "OverGame");
	
	register_event("DeathMsg", "event_deathmsg", "a", "1>0");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");
	
	register_forward(FM_PlayerPreThink, "Fakemeta_PreThink", false);
	register_menucmd(register_menuid("Bubble_Menu"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_Bubble_Menu");
	register_menucmd(register_menuid("Show_ColorBubble"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_ColorBubble");
	
	register_clcmd("+grab", "ClCmd_GrabOn");
	register_clcmd("-grab", "ClCmd_GrabOff");
	register_clcmd("drop", "ClCmd_GrabThrow");
	register_clcmd("say /mmm", "Show_ColorBubble");
	
	g_iMaxPlayers = get_maxplayers();
	
	for(new i = 1; i <= g_iMaxPlayers; i++)
		g_iPlayers[i][BB_INDEX] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
}

public event_deathmsg(i_Victim) {
	i_Victim = read_data(2);
	
	if(IsSetBit(g_iBitUserFrozen, i_Victim))
		UTIL_UserFrozent(i_Victim);
	
	return PLUGIN_CONTINUE;
}

public LogEvent_RoundEnd() {
	for(new id = 1; id <= g_iMaxPlayers; id++) {
		if(is_user_alive(id) && IsSetBit(g_iBitUserFrozen, id)) {
			UTIL_UserFrozent(id);
		}
	}
}

LoadColor(id)
{
    new iAuth[35]; get_user_authid(id, iAuth, sizeof(iAuth) - 1);
    new iDataColor[16], iDataBubble[16], iDataBubbleLight[16];
    if(fvault_get_data(FVAULT_NAME_COLOR, iAuth, iDataColor, sizeof(iDataColor) - 1)) g_iColorBubble[id] = str_to_num(iDataColor);
    else g_iColorBubble[id] = 1;
    if(fvault_get_data(FVAULT_NAME_BUBBLE, iAuth, iDataBubble, sizeof(iDataBubble) - 1)) 
	{
		if(str_to_num(iDataBubble)) SetBit(g_iBitBubble, id);
		else ClearBit(g_iBitBubble, id);
	}
	else SetBit(g_iBitBubble, id);
    if(fvault_get_data(FVAULT_NAME_LIGHT, iAuth, iDataBubbleLight, sizeof(iDataBubbleLight) - 1))
	{
		if(str_to_num(iDataBubble)) SetBit(g_iBitBubbleLight, id);
		else ClearBit(g_iBitBubbleLight, id);
	}
	else SetBit(g_iBitBubbleLight, id);
}

SaveColor(id)
{
    new iAuth[35];
    get_user_authid(id, iAuth, sizeof(iAuth) - 1);
    new iDataColor[16], iDataBubble[16], iDataBubbleLight[16];
    num_to_str(g_iColorBubble[id], iDataColor, sizeof(iDataColor) - 1);
    fvault_set_data(FVAULT_NAME_COLOR, iAuth, iDataColor);
    num_to_str(IsSetBit(g_iBitBubble, id), iDataBubble, sizeof(iDataBubble) - 1);
    fvault_set_data(FVAULT_NAME_BUBBLE, iAuth, iDataBubble);
    num_to_str(IsSetBit(g_iBitBubbleLight, id), iDataBubbleLight, sizeof(iDataBubbleLight) - 1);
    fvault_set_data(FVAULT_NAME_LIGHT, iAuth, iDataBubbleLight);
}

public client_putinserver(id) {
	g_bIsGrabbed[id] = false;
	if(pev_valid(g_iPlayers[id][BB_INDEX])) {
		engfunc(EngFunc_SetModel, g_iPlayers[id][BB_INDEX], BUBBLE_MODEL);
		LoadColor(id);
		set_pev(g_iPlayers[id][BB_INDEX], pev_movetype, MOVETYPE_FOLLOW);
		set_pev(g_iPlayers[id][BB_INDEX], pev_aiment, id);
		set_pev(g_iPlayers[id][BB_INDEX], pev_owner, id);
		
		fm_set_entity_visibility(g_iPlayers[id][BB_INDEX], false);
	}
}

public client_disconnected(id) {
	if(IsSetBit(g_iBitUserFrozen, id))
		UTIL_UserFrozent(id);
	g_bIsGrabbed[id] = false;
	SaveColor(id);

	ClCmd_GrabOff(id);
}

public Fakemeta_PreThink(id) {
	new target;
	if(g_iPlayers[id][GRABBED] == -1) {
		new Float:orig[3], Float:ret[3];
		get_view_pos(id, orig);
		ret = vel_by_aim(id, 9999);

		ret[0] += orig[0];
		ret[1] += orig[1];
		ret[2] += orig[2];
		
		target = traceline(orig, ret, id, ret);
		if(0 < target <= g_iMaxPlayers) {
			if(is_grabbed(target, id)) return FMRES_IGNORED;
			set_grabbed(id, target);
		}
		else {
			new movetype;
			if(target && pev_valid(target)) {
				movetype = pev(target, pev_movetype);
				
				if(!(movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS))
					return FMRES_IGNORED;
			}
			else {
				target = 0;
				new ent = engfunc(EngFunc_FindEntityInSphere, -1, ret, 12.0);
				
				while(!target && ent > 0) {
					movetype = pev(ent, pev_movetype);
					if((movetype == MOVETYPE_WALK || movetype == MOVETYPE_STEP || movetype == MOVETYPE_TOSS) && ent != id )
						target = ent;
					
					ent = engfunc(EngFunc_FindEntityInSphere, ent, ret, 12.0);
				}
			}
			if(target) {
				if(is_grabbed(target, id)) return FMRES_IGNORED;
				set_grabbed(id, target);
			}
		}
	}

	target = g_iPlayers[id][GRABBED];
	if(target > 0) {
		if(!pev_valid(target) || (pev( target, pev_health) < 1 && pev(target, pev_max_health))) {
			unset_grabbed(id);
			return FMRES_IGNORED;
		}
		
		if(pev(id, pev_button) & IN_USE) {
			if(g_iPlayers[id][GRAB_LEN] > 90) {
				g_iPlayers[id][GRAB_LEN] -= 5;
				if(g_iPlayers[id][GRAB_LEN] < 90) g_iPlayers[id][GRAB_LEN] = 90;
				g_iPlayers[id][GRAB_LEN] = g_iPlayers[id][GRAB_LEN];
			}
		}

		if(target > g_iMaxPlayers) grab_think(id);
	}
	
	target = g_iPlayers[id][GRABBER];
	if(target > 0) grab_think(target);

	return FMRES_IGNORED;
}

public grab_think(id) {
	new target = g_iPlayers[id][GRABBED];
	if(pev(target, pev_movetype) == MOVETYPE_FLY && !(pev(target, pev_button) & IN_JUMP)) client_cmd(target, "+jump;wait;-jump");
	
	new Float:tmpvec[3], Float:tmpvec2[3], Float:torig[3], Float:tvel[3];
	get_view_pos(id, tmpvec);
	tmpvec2 = vel_by_aim(id, g_iPlayers[id][GRAB_LEN]);
	
	torig = get_target_origin_f(target);
	
	new force = 8;
	
	tvel[0] = ((tmpvec[0] + tmpvec2[0]) - torig[0]) * force;
	tvel[1] = ((tmpvec[1] + tmpvec2[1]) - torig[1]) * force;
	tvel[2] = ((tmpvec[2] + tmpvec2[2]) - torig[2]) * force;
	
	if(g_iPlayers[id][ACTS]) {
		if(is_user_connected(id)) {
			set_pdata_float(id, 83, 1.0);
		}
		
		static Float:fTime[33];
		
		if(fTime[id] + 2.0 < get_gametime()) {
			fTime[id] = get_gametime();
			
			// jbm_informer_offset_up(id);
			
			if(target > 0 && target <= 32) 
			{
				new origin[3];
				get_user_origin(target, origin, 0);
				
				message_begin(MSG_ALL, SVC_TEMPENTITY, {0, 0, 0}, target);
				write_byte(TE_SPRITETRAIL);
				write_coord(origin[0]);
				write_coord(origin[1]);
				write_coord(origin[2] + 20);
				write_coord(origin[0]);
				write_coord(origin[1]);
				write_coord(origin[2] + 40);
				write_short(i_Sprite[random_num(0, 4)]);
				write_byte(40);
				write_byte(20);
				write_byte(1);
				write_byte(20);
				write_byte(15);
				message_end();
			}
		}
	}
	
	set_pev(target, pev_velocity, tvel);
}

public Show_ColorBubble(id)
{
	new szMenu[512], iKeys = (1<<0|1<<9), iLen;
	iLen = formatex(szMenu, charsmax(szMenu), "\r[JBM] \yНастройка Grab'a^n^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w1\d] \wШар \r[\y%s\r]^n", IsSetBit(g_iBitBubble, id) ? "Вкл" : "Выкл");/////////////////////////
	if(IsSetBit(g_iBitBubble, id))
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w2\d] \wПодсветка шара \r[\y%s\r]^n", IsSetBit(g_iBitBubbleLight, id) ? "Вкл" : "Выкл");
		iKeys |= (1<<1);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dПодсветка шара \r[\y%s\r]^n", IsSetBit(g_iBitBubbleLight, id) ? "Вкл" : "Выкл");
	if(g_iColorBubble[id] != 0)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w3\d] \wБелый^n");
		iKeys |= (1<<2);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dБелый^n");
	
	if(g_iColorBubble[id] != 1)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w4\d] \wЗелёный^n");
		iKeys |= (1<<3);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dЗелёный^n");
	
	if(g_iColorBubble[id] != 2)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w5\d] \wКрасный^n");
		iKeys |= (1<<4);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dКрасный^n");
	
	if(g_iColorBubble[id] != 3)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w6\d] \wЖёлтый^n");
		iKeys |= (1<<5);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dЖёлтый^n");
	
	if(g_iColorBubble[id] != 4)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w7\d] \wОранжевый^n");
		iKeys |= (1<<6);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dОранжевый^n");
	
	if(g_iColorBubble[id] != 5)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w8\d] \wГолубой^n");
		iKeys |= (1<<7);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dГолубой^n");
	
	if(g_iColorBubble[id] != 6)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\w9\d] \wСиний^n");
		iKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\d[\r#\d] \dСиний^n");
	
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\d[\w0\d] \wВыход");
	return show_menu(id, iKeys, szMenu, -1, "Show_ColorBubble");
}

native jbm_open_bossmenu(pPlayer);

public Handle_ColorBubble(id, iKey)
{
	switch(iKey)
	{
		case 0:
		{
			InvertBit(g_iBitBubble, id);
			UTIL_SayText(id, "!g[JBM] !yВы %s шар.", IsSetBit(g_iBitBubble, id) ? "включили" : "отключили");
		}
		case 1:
		{
			InvertBit(g_iBitBubbleLight, id);
			UTIL_SayText(id, "!g[JBM] !yВы %s свечение шара.", IsSetBit(g_iBitBubbleLight, id) ? "включили" : "отключили");
		}
		case 9: return jbm_open_bossmenu(id);
		default: g_iColorBubble[id] = iKey - 2;
	}
	SaveColor(id);
	return Show_ColorBubble(id);
}

public Bubble_Menu(id, target)
{
	if(!g_iPlayers[id][ACTS]) return PLUGIN_HANDLED;
	new sMenu[512], iKeys, iLen;
	
	if(target > 0 && target <= 32) 
	{
		iKeys = (1<<1|1<<2|1<<3|1<<5|1<<7|1<<8|1<<9);
		
		new sTargetName[33];
		get_user_name(target, sTargetName, charsmax(sTargetName));
		iLen = formatex(sMenu, charsmax(sMenu), "\yМеню граба^n\yВы взяли \r%s^n^n", sTargetName);
		
		if(!(get_user_flags(target) & ADMIN_IMMUNITY))
		{
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[1] \wКикнуть^n");
			iKeys |= (1<<0);
		}
		else iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[1] \dКикнуть^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[2] \wУбить^n");
		
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[3] \w%s^n", IsSetBit(g_iBitUserFrozen, target) ? "Разморозить" : "Заморозить");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[4] \wОбнулить способности^n");
		if(!(get_user_flags(target) & ADMIN_IMMUNITY))
		{
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[5] \wПеревести за %s^n", (get_user_team(target) == 1) ? "охрану" : "заключённых");
			iKeys |= (1<<4);
		}
		else iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[5] \dПеревести за %s^n", (get_user_team(target) == 1) ? "охрану" : "заключённых");
		
		if(get_user_health(target) < 100)
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[6] \wВылечить^n");
		else
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[6] \dВылечить^n");
		
		if(get_user_team(target) == 1 && !jbm_is_gg()) 
		{
			iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[7] \w%s розыск^n", jbm_is_user_wanted(target) ? "Забрать" : "Выдать");
			iKeys |= (1<<6);
		}
		else iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "^n^n");
		
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[8] \wЗабрать оружие^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[9] \wЗакопать^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[0] \wОткопать^n");
	}
	else 
	{
		iKeys = (1<<0);
		iLen = formatex(sMenu, charsmax(sMenu), "\yМеню граба^n\yВы взяли оружие^n^n");
		iLen += formatex(sMenu[iLen], charsmax(sMenu) - iLen, "\r[1] \wУдалить^n");
	}
	
	return show_menu(id, iKeys, sMenu, -1, "Bubble_Menu");
}

public Handle_Bubble_Menu(id, i_Key) {
	new sTargetName[33], sNickname[33];
	new iTarget = g_iPlayers[id][GRABBED];
	if(!pev_valid(iTarget)) return PLUGIN_HANDLED;
	
	get_user_name(id, sNickname, charsmax(sNickname));
	get_user_name(iTarget, sTargetName, charsmax(sTargetName));
	
	switch(i_Key) {
		case 0: {
			if(iTarget > 0 && iTarget <= 32) { 
				server_cmd("kick #%d ^"Вас кикнул грабом %s^"", get_user_userid(iTarget), sNickname);
				UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !yкикнул игрока !t%s", sNickname, sTargetName);
			}
			else {
				unset_grabbed(id);
				fm_remove_entity(iTarget);
				UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !yудалил оружие.", sNickname);
			}
		}
		case 1: {
			fm_user_kill(iTarget);
			
			UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !yубил игрока !t%s", sNickname, sTargetName);
		}
		case 2: {
			UTIL_UserFrozent(iTarget, IsSetBit(g_iBitUserFrozen, iTarget) ? false : true);
			UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !y%s игрока !t%s", sNickname, IsSetBit(g_iBitUserFrozen, iTarget) ? "заморозил" : "разморозил", sTargetName);
		}
		case 3: {
			// jbm_user_zeroize(id);
			if(jbm_reset_abil(iTarget))
				UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !yсбросил способности игрока !t%s", sNickname, sTargetName);
		}
		case 4: {
			switch(get_user_team(iTarget)) {
				case 2: jbm_set_user_team(iTarget, 1);
				default: jbm_set_user_team(iTarget, 2);
			}
			
			UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !yсменил команду игрока !t%s", sNickname, sTargetName);
		}
		case 5: {
			if(get_user_health(iTarget) < 100)
				fm_set_user_health(iTarget, 100);
			
			UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !yвылечил игрока !t%s", sNickname, sTargetName);
		}
		case 6: 
		{
			if(jbm_is_gg()) return Bubble_Menu(id, iTarget);
			if(jbm_is_user_wanted(iTarget))
			{
				jbm_sub_user_wanted(iTarget);
			}
			else 
			{
				jbm_add_user_wanted(iTarget);
			}
			UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !y%s розыск у !t%s", sNickname, jbm_is_user_wanted(iTarget) ? "дал" : "забрал", sTargetName);
		}
		case 7:
		{
			fm_strip_user_weapons(iTarget)
			fm_give_item(iTarget, "weapon_knife")
			UTIL_SayText(0, "!y[!gGRAB!y] Администратор !t%s !yзабрал оружие у игрока !t%s", sNickname, sTargetName);
		}
		case 8:
		{
			if(iTarget && is_user_alive(iTarget))
			{
				new playername[33], playername2[33]
				get_user_name(id, playername, 32)
				get_user_name(iTarget, playername2, 32)
				UTIL_SayText(0, "!y[!gGRAB!y] Администратор !g%s !yзакопал игрока !t%s",playername, playername2)
				Bury(iTarget)
			}
		}
		case 9:
		{
			new playername[33], playername2[33]
			get_user_name(id, playername, 32)
			get_user_name(iTarget, playername2, 32)
			UTIL_SayText(0, "!y[!gGRAB!y] Администратор !g%s !yоткопал игрока !t%s",playername, playername2)         
			Bury_off(iTarget)
		}
	}
	
	return Bubble_Menu(id, iTarget);
}

public Bury(target)
{
	if(is_user_alive(target))
	{
		new origin[3]
		get_user_origin(target, origin)
		origin[2] -= 30
		set_user_origin(target, origin)
	}
}

public Bury_off(target)
{   
	set_dhudmessage(255, 0, 0, -1.0, 0.20, 0, 0.1, 3.0, 0.1, 2.0)
	show_dhudmessage(target, "ВАС ОТКОПАЛИ")
	
	if(is_user_alive(target))
	{
		new origin[3]
		get_user_origin(target, origin)
		origin[2] += 30
		set_user_origin(target, origin)
	}
}   

public ClCmd_GrabOn(id) {
	if(is_user_grab(id)) if(!g_iPlayers[id][GRABBED]) g_iPlayers[id][GRABBED] = -1;
	return PLUGIN_HANDLED;
}

public ClCmd_GrabOff(id) {
	if(is_user_grab(id) && is_user_alive(id) && g_iPlayers[id][GRABBED]) {
		set_pdata_float(id, 83, 0.0, 5);
	}

	unset_grabbed(id);
	return PLUGIN_HANDLED;
}

public ClCmd_GrabThrow(id) {
	new target = g_iPlayers[id][GRABBED];
	if(target > 0) {
		set_pev(target, pev_velocity, vel_by_aim(id, 1500));
		unset_grabbed(id);

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

stock set_grabbed(id, target) {
	fm_set_rendering(target, kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), _, 5);
	
	if(0 < target <= g_iMaxPlayers)
	{ 
		if(is_user_alive(target)) stopAnim(target);
		g_iPlayers[target][GRABBER] = id;
	}
	g_iPlayers[id][FLAGS] = 0;
	g_iPlayers[id][GRABBED] = target;
	if(1 <= target <= 32) g_bIsGrabbed[target] = true;
	
	new Float:torig[3], Float:orig[3];
	pev(target, pev_origin, torig);
	pev(id, pev_origin, orig);

	g_iPlayers[id][GRAB_LEN] = floatround(get_distance_f(torig, orig));
	if(g_iPlayers[id][GRAB_LEN] < 90) g_iPlayers[id][GRAB_LEN] = 90;
	
	g_iPlayers[id][ACTS] = true;
	
	new szName[32], szNameT[32]; get_user_name(id, szName, charsmax(szName)); get_user_name(target, szNameT, charsmax(szNameT));
	if(target > 0 && target <= 32) {
		if(pev_valid(g_iPlayers[target][BB_INDEX]) && IsSetBit(g_iBitBubble, id)) {
			set_pev(g_iPlayers[target][BB_INDEX], pev_skin, g_iColorBubble[id]);
			fm_set_entity_visibility(g_iPlayers[target][BB_INDEX], true);
			if(IsSetBit(g_iBitBubbleLight, id)) fm_set_rendering(g_iPlayers[target][BB_INDEX], kRenderFxGlowShell, random_num(0, 255), random_num(0, 255), random_num(0, 255), _, 5);
			else fm_set_rendering(g_iPlayers[target][BB_INDEX], kRenderNormal, 0, 0, 0, _, 5);
		}
		
		
		UTIL_SayText(0, "!g[JBM]!y Админ !g%s !yвзял грабом !g%s", szName, szNameT);
		Bubble_Menu(id, target);
	}
	else
	{
		UTIL_SayText(0, "!g[JBM]!y Админ !g%s !yвзял грабом !gоружие", szName);
		Bubble_Menu(id, -1);
	}
}

stock unset_grabbed(id) {
	new target = g_iPlayers[id][GRABBED];
	if(target > 0 && pev_valid(target)) {
		fm_set_rendering(target, kRenderFxNone, 255, 255, 255, kRenderNormal, 16);
		
		if(target > 0 && target <= 32 && pev_valid(g_iPlayers[target][BB_INDEX])) {
			fm_set_entity_visibility(g_iPlayers[target][BB_INDEX], false);
		}
		
		show_menu(id, 0, "^n");
		
		if(is_user_connected(id) && g_iPlayers[id][ACTS]) {
			set_pdata_float(id, 83, 0.0);
			
			
			// jbm_informer_offset_down(id);
		
			
			g_iPlayers[id][ACTS] = false;
		}
		
		if(0 < target <= g_iMaxPlayers) {
			g_iPlayers[target][GRABBER] = 0;
			g_bIsGrabbed[target] = false;
		}
	}
	
	g_iPlayers[id][GRABBED] = 0;
}

stock traceline(Float:vStart[3], Float:vEnd[3], pIgnore, Float:vHitPos[3]) {
	engfunc(EngFunc_TraceLine, vStart, vEnd, 0, pIgnore, 0);
	get_tr2(0, TR_vecEndPos, vHitPos);
	return get_tr2(0, TR_pHit);
}

stock Float:get_target_origin_f(id) {
	new Float:orig[3];
	pev(id, pev_origin, orig);
	
	if(id > g_iMaxPlayers)
	{
		new Float:mins[3], Float:maxs[3];
		pev(id, pev_mins, mins);
		pev(id, pev_maxs, maxs);
		
		if(!mins[2]) orig[2] += maxs[2] / 2;
	}
	
	return orig;
}

stock get_view_pos(id, Float:vViewPos[3]) {
	new Float:vOfs[3];
	pev(id, pev_origin, vViewPos);
	pev(id, pev_view_ofs, vOfs);
	
	vViewPos[0] += vOfs[0];
	vViewPos[1] += vOfs[1];
	vViewPos[2] += vOfs[2];
}

stock is_grabbed(target, grabber) {
	for(new i = 1; i <= g_iMaxPlayers; i++) if(g_iPlayers[i][GRABBED] == target) {
		unset_grabbed(grabber);
		return true;
	}

	return false;
}

bool:UTIL_UserFrozent(id, bool:status = false) {	
	if(status) {
		if(!is_user_alive(id))
			return false;
		
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN);
		set_pdata_float(id, 83, 20.0, 5);
		
		if(IsNotSetBit(g_iBitUserFrozen, id))
			SetBit(g_iBitUserFrozen, id);
		
		new iEntity;
		
		if(pev_valid((iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))))) {
			new Float:fOrigin[3];
			pev(id, pev_origin, fOrigin);
			
			fOrigin[0] -= 7.0;
			fOrigin[2] -= 40.0;
			
			set_pev(iEntity, pev_origin, fOrigin);
			set_pev(iEntity, pev_movetype, MOVETYPE_NONE);
			set_pev(iEntity, pev_owner, id);
			set_pev(id, pev_iuser2, iEntity);
		}
		
		// emit_sound(id, CHAN_AUTO, "days_mode/ringolevio/freeze_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	else {
		set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN);
		set_pdata_float(id, 83, 0.0, 5);
		
		if(IsSetBit(g_iBitUserFrozen, id))
			ClearBit(g_iBitUserFrozen, id);
		
		if(pev_valid(pev(id, pev_iuser2))) {
			fm_remove_entity(pev(id, pev_iuser2));
		}
		
		// emit_sound(id, CHAN_AUTO, "days_mode/ringolevio/defrost_player.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}
	
	return true;
}

stock Float:vel_by_aim(id, speed = 1) {
	new Float:v1[3], Float:vBlah[3];
	pev(id, pev_v_angle, v1);
	engfunc(EngFunc_AngleVectors, v1, v1, vBlah, vBlah);
	
	v1[0] *= speed;
	v1[1] *= speed;
	v1[2] *= speed;
	
	return v1;
}

stock UTIL_SayText(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
    
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
    
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}