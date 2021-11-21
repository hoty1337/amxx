/* 
	Advanced Experience System
	by serfreeman1337		http://gf.hldm.org/
*/

/*
	StatsX (CSTRIKE)
*/

#include <amxmodx>
#include <csx>
#include <csstats>

//#include <colorchat>
#include <aes_main>

#define PLUGIN "AES: StatsX"
#define VERSION "0.2"
#define AUTHOR "serfreeman1337"

/* - CVARS - */
enum _:cvars {
	CVAR_MOTD_DESC,
	CVAR_ASTATS_DESC,
	CVAR_CHAT_DESC,
	CVAR_SKILL,
	CVAR_CSSTATS,
	CVAR_ASTATS_GLOBAL,
	CVAR_ALIST_CNT
}

new cvar[cvars]

/* - RANDOM STUFF */

// User stats parms id
#define STATS_KILLS             0
#define STATS_DEATHS            1
#define STATS_HS                2
#define STATS_TKS               3
#define STATS_SHOTS             4
#define STATS_HITS              5
#define STATS_DAMAGE            6

#define MAX_TOP			10

/* - SKILL - */

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
	"P"
}

new const g_skill_class[][] = {
	"Lm",
	"L",
	"Lp",
	"Mm",
	"M",
	"Mp",
	"Hm",
	"H",
	"Hp",
	"P"
}

// Global player flags.
new const BODY_PART[8][] =
{
	"WHOLEBODY", 
	"HTML_HEAD", 
	"HTML_CHEST", 
	"HTML_STOMACH", 
	"HTML_LARM", 
	"HTML_RARM", 
	"HTML_LLEG", 
	"HTML_RLEG"
}

new g_skill_opt[sizeof g_skill_letters]
new chatDescCap[10],motdDescCap[10],aStatsDescCap[10]
new useCsstats,useAstatsGlobal

#define BUFF_LEN 1535

new theBuffer[BUFF_LEN + 1] = 0

#define MENU_LEN 512

new g_MenuStatus[33][2]

public SayStatsMe           = 0 // displays user's stats and rank
public SayRankStats         = 0 // displays user's rank stats
public SayRank              = 0 // displays user's rank
public SayTop15             = 0 // displays first 15 players
public SayStatsAll          = 0 // displays all players stats and rank

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say","Say_Catch")
	register_clcmd("say_team","Say_Catch")
	
	/*
	// ����������� /top15 � /rank
	// �����! Motd ���� �� ����� ���������� ������ 1534-� ��������, � ��������� � ��� ������ 192-�.
	// ���� ��� �� ������������ ����� ��� �� ���������, �� ����� ��������� ���������� �������. (��� �� ���������� ������ 10-�� �������)
	//   * - ����
	//   a - ��� (Only /top15)
	//   b - �������
	//   c - ������
	//   d - ���������
	//   e - ���������
	//   f - � ������
	//   g - ��������
	//   h - �������������
	//   i - �����
	//   j - ������ Army Ranks
	*/
	
	cvar[CVAR_MOTD_DESC] = register_cvar("aes_statsx_top","*abcfij")
	cvar[CVAR_CHAT_DESC] = register_cvar("aes_statsx_rank","bcij")
	cvar[CVAR_ASTATS_DESC] = register_cvar("aes_statsx_astats","aj")
	
	// ��������� ������. �������� ����� �� ���������� �������������.
	// ��������: L- L L+ M- M M+ H- H H+ P (Low Middle High Pro)
	cvar[CVAR_SKILL] = register_cvar("aes_statsx_skill","35 40 45 50 55 65 70 75 80 90")
	
	// ������������ ������ ����� � ������ �� ��������� ���������� �� csstats.dat
	// � ������ ���� �� ������� �������� ���� �� AES
	cvar[CVAR_CSSTATS] = register_cvar("aes_statsx_use_csstats","1")
	
	cvar[CVAR_ASTATS_GLOBAL] = register_cvar("aes_statsx_astats_global","1")
	cvar[CVAR_ALIST_CNT] = register_cvar("aes_statsx_alist","10")
	
	// register_dictionary_colored("statsx.txt")
	register_dictionary("statsx_aes.txt")
	
	register_menucmd(register_menuid("Stats Menu"), 1023, "actionStatsMenu")
}

public plugin_cfg(){
	new levelString[36],stPos,ePos,rawPoint[20],cnt
	
	get_pcvar_string(cvar[CVAR_MOTD_DESC],motdDescCap,9)
	trim(motdDescCap)
	
	get_pcvar_string(cvar[CVAR_CHAT_DESC],chatDescCap,9)
	trim(chatDescCap)
	
	get_pcvar_string(cvar[CVAR_ASTATS_DESC],aStatsDescCap,9)
	trim(aStatsDescCap)
	
	get_pcvar_string(cvar[CVAR_SKILL],levelString,35)
	
	// ������ �������� ��� ������
	do {
		ePos = strfind(levelString[stPos]," ")
		
		formatex(rawPoint,ePos,levelString[stPos])
		g_skill_opt[cnt] = str_to_num(rawPoint)
		
		stPos += ePos + 1
		
		cnt++
		
		// narkoman wole suka
		if(cnt > sizeof g_skill_letters - 1)
			break
	} while (ePos != -1)
	
	useCsstats = get_pcvar_num(cvar[CVAR_CSSTATS])
	useAstatsGlobal = get_pcvar_num(cvar[CVAR_ASTATS_GLOBAL])
}

// ����� ��������� ����
public Say_Catch(id){
	new msg[191]
	read_args(msg,190)
	
	trim(msg)
	remove_quotes(msg)

	if(msg[0] == '/'){
		if(!strcmp(msg[1],"rank",1))
			return RankSay(id)
		if(containi(msg[1],"top") == 0){
			replace(msg,190,"/top","")
			
			return SayTop(id,str_to_num(msg))
		}
		if(!strcmp(msg[1],"rankstats",1))
			return RankStatsSay(id,id)
			
		if(!strcmp(msg[1],"statsme",1))
			return StatsMeSay(id,id)
			
		if(!strcmp(msg[1],"stats",1)){
			arrayset(g_MenuStatus[id],0,2)
			return ShowStatsMenu(id,0)
		}
		
		if(!strcmp(msg[1],"astats",1)){
			return ShowAStats(id)
		}
		
		if(!strcmp(msg[1],"alist",1)){
			return ShowAList(id)
		}
	}
	
	return PLUGIN_CONTINUE
}

public RankSay(id){
	if(!SayRank){
		client_print_color(id,0,"%L %L",id,"STATS_TAG", id,"DISABLED_MSG")
		
		return PLUGIN_HANDLED
	}
	
	new message[191],len,rank,stats[8],bh[8]
	
	len += formatex(message[len],190 - len,"%L ",id,"STATS_TAG")
	
	rank = get_user_stats(id,stats,bh)
	
	len += formatex(message[len],190 - len,"%L ",id,"AES_YOUR_RANK_IS",rank,get_statsnum())
	
	parse_rank_desc(id,message,190,len,stats)
	
	client_print_color(id,print_team_default,message)
	
	return PLUGIN_HANDLED
}

// ������������ ��������� /rank
parse_rank_desc(id,msg[],maxlen,len,stats[8]){
	new cnt,theChar[4]
	
	// ��������� �� �����
	for(new i ; i < strlen(chatDescCap) ; ++i){
		theChar[0] = chatDescCap[i]	// �� ������ �������� �� ��������
		
		// ���� ��� ������ ��������, �� ������ � ������ ������, ����� ������� � ��������
		if(cnt != strlen(chatDescCap))
			len += formatex(msg[len],maxlen - len,cnt <= 0 ? "(" : ", ")
		
		// ��������� � ��������� ���������� � �����. � �������
		switch(theChar[0]){
			case 'a':{ // ������
				}
			case 'b':{ // ��������
				len += formatex(msg[len],maxlen - len,"%L ^3%d^1",id,"KILLS",stats[0])
			}
			case 'c':{ // ������
				len += formatex(msg[len],maxlen - len,"%L ^3%d^1",id,"DEATHS",stats[1])
			}
			case 'd':{ // ���������
				len += formatex(msg[len],maxlen - len,"%L ^3%d^1",id,"HITS",stats[5])
			}
			case 'e':{ // ��������
				len += formatex(msg[len],maxlen - len,"%L ^3%d^1",id,"SHOTS",stats[4])
			}
			case 'f':{ // �������
				len += formatex(msg[len],maxlen - len,"%L ^3%d^1",id,"STATS_HS",stats[2])
			}
			case 'g':{ // ��������
				len += formatex(msg[len],maxlen - len,"%L ^3%.2f^1",id,"ACC",accuracy(stats))
			}
			case 'h':{ // �������������
				len += formatex(msg[len],maxlen - len,"%L ^3%d^1",id,"EFF",effec(stats))
			}
			case 'i':{ // �����
				new sk = floatround(effec(stats))
				len += formatex(msg[len],maxlen - len,"%L ^3%s^1",id,"STATS_SKILL",sk)
				
			}
			case 'j':{ // ���� � ����
				new aStats[AES_ST_END],level[42],lev
				
				if(aes_get_player_stats(id,aStats)){
					aes_get_level_name(aStats[AES_ST_LEVEL],level,31,id)
					lev = strlen(level)
					lev += formatex(level[lev],41-lev,"(%d)",aStats[AES_ST_EXP])
				}
				else	// ��� �����
					formatex(level,31,"^4---^1")
				
				len += formatex(msg[len],maxlen - len,"%L ^3%s^1",id,"STATS_RANK",level)
			}
		}
		
		theChar[0] = 0
		cnt ++
	}
	
	// ��������� �� ��������� �������, ���� ���� ����������� ����������
	if(cnt)
		len += formatex(msg[len],maxlen - len,")")
}

// ������������ ���� /rankstats
// id - ���� ����������
// stId - ���� ����������
public RankStatsSay(id,stId){
	if(!SayRankStats){
		client_print_color(id,0,"%L %L",id,"STATS_TAG", id,"DISABLED_MSG")
		
		return PLUGIN_HANDLED
	}
	
	new len,stats[8],aStats[AES_ST_END],bh[8],tt[64]
	new name[32],skilll[32],levelName[42]
	
	theBuffer[0] = 0
	
	formatex(tt,63,"%L",id,"RANKSTATS_TITLE")
	
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_META")
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_STYLE")
	
	new rank = get_user_stats(stId,stats,bh)
	
	new rt = get_skill(stats,skilll,31)
	formatex(skilll,31,"%L",id,"HTML_SKILL_VALUE",g_skill_class[rt])
	
	if(id == stId)
		formatex(name,31,"%L",id,"HTML_YOU")
	else{
		get_user_name(stId,name,31)
		formatex(levelName,31," ^"%s^"",name)
		add(tt,63,levelName)
	}
	
	aes_get_player_stats(stId,aStats)
	aes_get_level_name(aStats[AES_ST_LEVEL],levelName,41,id)
	
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_RANKSTATS_BODY",
		id,"HTML_RANK_IS",name,rank,get_statsnum())
	
	// vot eto formatirovanie
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_RANKSTATS_HEADER",
		id,"HTML_KILLS",stats[STATS_KILLS],stats[STATS_HS],
		id,"HTML_DEATHS",stats[STATS_DEATHS],
		id,"HTML_HITS",stats[STATS_HITS],
		id,"HTML_SHOTS",stats[STATS_SHOTS],
		id,"HTML_DMG",stats[STATS_DAMAGE],
		id,"HTML_ACC",accuracy(stats),
		id,"HTML_EFF",effec(stats),
		id,"HTML_SKILL",skilll,
		id,"HTML_ARMYRANKS",levelName,aStats[AES_ST_EXP])
		
	len += formatex(theBuffer[len],1536-len,"%L",id,"HTML_RANKSTATS_HITS")
		
	new theSwitcher
		
	for (new i = 1; i < 8; i++)
	{
		len += formatex(theBuffer[len],BUFF_LEN-len,"%L",
			id,"HTML_RANKSTATS_HITSTABLE",
			theSwitcher ? " class=b" : "",
			id,BODY_PART[i],bh[i])
			
		theSwitcher = theSwitcher ? false : true
	}
	
	// mne tak nadoel etot kod :(
	for(new i = 0 ; i < 2; ++i){
		len += formatex(theBuffer[len],BUFF_LEN-len,"%L",
			id,"HTML_RANKSTATS_BLANK",
			theSwitcher ? " class=b" : "")
			
		theSwitcher = theSwitcher ? false : true
	}
	
	show_motd(id,theBuffer,tt)
	
	return PLUGIN_HANDLED
}

get_skill(stats[8],skill[],skilllen,&skillexp = 0){
	new sk = floatround(effec(stats))
	
	for(new i;i < sizeof g_skill_opt;++i){
		if(g_skill_opt[i] > sk || i == sizeof g_skill_opt - 1){
			copy(skill,skilllen,g_skill_letters[i])
			return i
		}
	}
	
	return 0
}

// ������������ ���� /top
// � Pos ����������� � ����� ������� ��������
public SayTop(id,Pos){
	if(!SayTop15){
		client_print_color(id,0,"%L %L",id,"STATS_TAG", id,"DISABLED_MSG")
		
		return PLUGIN_HANDLED
	}
	
	if(Pos == 15 || Pos <= 0)
		Pos = 10
		
	theBuffer[0] = 0
	
	new len,tt[64]
	formatex(tt,63,"%L",id,"HTML_PLAYER_TOP")
	
	//len += formatex(buffer[len],1535 - len,"<html><head>")
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L%L",id,"HTML_META",id,"HTML_STYLE")
	//len += formatex(buffer[len],1535 - len,"</head><body>")
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_TOP_BODY",id,"HTML_PLAYER_TOP")
	
	len += parse_top_desc_header(id,theBuffer,BUFF_LEN,len,false)
	
	new name[32],uid[36],stats[8],bh[8]
	
	new size = min(get_statsnum(),Pos)
	new i
	
	new Array:uids = ArrayCreate(36)
	new Array:ustats = ArrayCreate(8)
	new Array:names = ArrayCreate(32)
	new Array:poss = ArrayCreate(1)
	
	// ���� ��� ������ �� ����� ������� �������� 4�� ������������ ��������
	// ������� AES � ������ ������� �� ������� ���
	
	new rank,lst
	
	for(i = size - MAX_TOP < 0 ? 0 : size - MAX_TOP; i < size ; i++){
		rank = get_stats(i,stats,bh,name,31,uid,35)
		
		ArrayPushCell(poss,rank ? rank : lst + 1)
		ArrayPushString(uids,uid)
		ArrayPushString(names,name)
		ArrayPushArray(ustats,stats)
		
		lst = rank
	}
	
	len = parse_top_desc_body(id,theBuffer,BUFF_LEN,len,uids,ustats,names,poss,false)
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_CLOSE")

	//len += formatex(buffer[len],1562 - len,"</body></html")
	
	show_motd(id,theBuffer,tt)
	
	return PLUGIN_HANDLED
}

// ��������� ������ ������� � ������� ��� ���� �������
parse_top_desc_body(id,buff[],maxlen,len,Array:uids,Array:ustats,Array:names,Array:pos,bool:isAstats){
	new tmp[256],len2,tmp2[96],name[32],stats[8],bh[8],st[AES_ST_END],theChar[4],rank,bool:theSwitcher
	
	new Array:aStats,players[32],pCount
	
	if(!isAstats){
		aStats = aes_get_stats(uids)
		pCount = ArraySize(names)
	}
	else{
		get_players(players,pCount)
		SortCustom1D(players,pCount,"AStats_Sort_Function",players,pCount)
	}
	
	// ��������� �������� ���������� ��� ������������ ������
	// ������ ������ � ���������� ����������� ����������� ��� ������������ ������
	if(aStats != Invalid_Array && ArraySize(aStats) < ArraySize(names) && !isAstats){
		ArrayDestroy(aStats)
		
		aStats = Invalid_Array
	}
	
	for(new i;i < pCount ;++i){
		arrayset(st,-1,AES_ST_END)

		if(!isAstats){
			ArrayGetString(names,i,name,31)
			ArrayGetArray(ustats,i,stats)
			rank = ArrayGetCell(pos,i)
		}else{
			get_user_name(players[i],name,31)
			rank = useAstatsGlobal ? get_user_stats(players[i],stats,bh) : get_user_wstats(players[i],0,stats,bh)
			aes_get_player_stats(players[i],st)
		}
		
		if(!isAstats && aStats != Invalid_Array)
			ArrayGetArray(aStats,i,st)
			
		new fCnt = isAstats != true ? strlen(motdDescCap) : strlen(aStatsDescCap)
		
		for(new z = 0; z < fCnt ; ++z){
			tmp2[0] = 0
			theChar[0] = isAstats != true ? motdDescCap[z] : aStatsDescCap[z]
			
			switch(theChar[0]){
				case '*':{
					formatex(tmp2,31,"%d",rank)
				}
				case 'a':{
					if(!isAstats)
						ArrayGetString(names,i,tmp2,31)
					else
						copy(tmp2,95,name)
					
					replace_all(tmp2,95,"<","&lt")
					replace_all(tmp2,95,">","&gt")
				}
				case 'b':{
					formatex(tmp2,31,"%d",stats[STATS_KILLS])
				}
				case 'c':{
					formatex(tmp2,31,"%d",stats[STATS_DEATHS])
				}
				case 'd':{
					formatex(tmp2,31,"%d",stats[STATS_HITS])
				}
				case 'e':{
					formatex(tmp2,31,"%d",stats[STATS_SHOTS])
				}
				case 'f':{
					formatex(tmp2,31,"%d",stats[STATS_HS])
				}
				case 'g':{
					formatex(tmp2,31,"%.2f%%",accuracy(stats))
				}
				case 'h':{
					formatex(tmp2,31,"%.2f%%",effec(stats))
				}
				case 'i':{
					new rt = get_skill(stats,tmp2,31)
					formatex(tmp2,31,"%L",id,"HTML_SKILL_VALUE",g_skill_class[rt])
				}
				case 'j':{
					new lvl[64]
					
					// ���������� ���������� �� csstats.dat
					if(st[AES_ST_EXP] < 0){
						if(useCsstats){
							new stats2[4]
							
							if(!isAstats)
								get_stats2(rank - 1,stats2)
							else
								get_user_stats2(players[i],stats2)
							
							st[AES_ST_EXP] = aes_get_exp_for_stats(stats,stats2)
							st[AES_ST_LEVEL] = aes_get_level_for_exp(st[AES_ST_EXP])
						}else
							st[AES_ST_LEVEL] = -1
						
					}
					
					if(st[AES_ST_LEVEL] > -1){
						aes_get_level_name(st[AES_ST_LEVEL],tmp2,95,id)
						formatex(lvl,63,"%s (%d)",tmp2,st[AES_ST_EXP])
					}else
						formatex(lvl,63,"%L",id,"HTML_NOT_TRACKED")

					len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_BODY_CELL",lvl)
					
					tmp2[0] = 0
					theChar[0] = 0
					
					continue
				}
			}
			
			// ������� ����������������� ������
			len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_BODY_CELL",tmp2)
			
			tmp2[0] = 0
			theChar[0] = 0
		}
		
		len2 = 0
		len += formatex(buff[len],maxlen-len,"%L",id,"HTML_BODY_ROW",theSwitcher ? " class=b" : " class=q",tmp)

		theSwitcher = theSwitcher ? false : true
	}

	if(!isAstats){
		ArrayDestroy(ustats)
		ArrayDestroy(names)
		ArrayDestroy(pos)
	
		if(aStats != Invalid_Array)
			ArrayDestroy(aStats)
	}
	
	return len
}

// ��������� ��������� ������� ��� ���� �������
parse_top_desc_header(id,buff[],maxlen,len,bool:isAstats){
	new tmp[256],len2,theChar[4],lCnt
	
	lCnt = isAstats != true ? strlen(motdDescCap) : strlen(aStatsDescCap)
	
	for(new i ; i < lCnt ; ++i){
		theChar[0] = isAstats != true ? motdDescCap[i] : aStatsDescCap[i]
		
		switch(theChar[0]){
			case '*':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_POS")
			}
			case 'a':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_PLAYER")
			}
			case 'b':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_KILLS")
			}
			case 'c':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_DEATHS")
			}
			case 'd':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_HITS")
			}
			case 'e':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_SHOTS")
			}
			case 'f':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_HS")
			}
			case 'g':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_ACC")
			}
			case 'h':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_EFF")
			}
			case 'i':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_SKILL")
			}
			case 'j':{
				len2 += formatex(tmp[len2],255-len2,"%L",id,"HTML_HEADER_CELL","",id,"HTML_ARMYRANKS")
			}
		}
		
		theChar[0] = 0
	}
	
	return formatex(buff[len],maxlen-len,"%L",id,"HTML_TOP_HEADER_ROW",tmp)
}

// ������ ��������� �� �����
// ������� /statsme

// id - ���� ����������
// stId - ���� ����������
public StatsMeSay(id,stId){
	if(!SayStatsMe){
		client_print_color(id,0,"%L %L",id,"STATS_TAG", id,"DISABLED_MSG")
		
		return PLUGIN_HANDLED
	}
	
	new len,stats[8],bh[8],wpnId,wpnName[32],tt[64]
	
	formatex(tt,63,"%L",id,"STATS_TITLE")
	
	if(id != stId){
		new name[32],nameQ[34]
		get_user_name(stId,name,31)
		
		formatex(nameQ,33," ^"%s^"",name)
		
		add(tt,63,nameQ)
	}
	
	theBuffer[0] = 0
	
	get_user_wstats(stId,0,stats,bh)
	
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L%L",id,"HTML_META",id,"HTML_STYLE")
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_STATS_BODY")
	
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_STATS_HEADER1",
		id,"HTML_KILLS",stats[STATS_KILLS],
		id,"HTML_HS",stats[STATS_HS],
		id,"HTML_DEATHS",stats[STATS_DEATHS],
		id,"HTML_HITS",stats[STATS_HITS],
		id,"HTML_SHOTS",stats[STATS_SHOTS],
		id,"HTML_DMG",stats[STATS_DAMAGE],
		id,"HTML_ACC",accuracy(stats),
		id,"HTML_EFF",effec(stats))
		
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_STATS_HEADER2",
		id,"HTML_WEAPON",
		id,"HTML_KILLS",
		id,"HTML_DEATHS",
		id,"HTML_HITS",
		id,"HTML_SHOTS",
		id,"HTML_DMG",
		id,"HTML_ACC")
		
	new theTrigger
		
	for (wpnId = 1; wpnId < xmod_get_maxweapons() && BUFF_LEN-len > 0 ; wpnId++)
	{
		if (get_user_wstats(stId, wpnId, stats,bh))
		{
			xmod_get_wpnname(wpnId,wpnName,31)
			
			len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_STATS_TABLE",
				theTrigger ? " class=b" : " class=q",
				wpnName,
				stats[STATS_KILLS],
				stats[STATS_DEATHS],
				stats[STATS_HITS],
				stats[STATS_SHOTS],
				stats[STATS_DAMAGE],
				accuracy(stats))
				
			theTrigger = theTrigger ? false : true
		}
	}
		
	len += formatex(theBuffer[len],BUFF_LEN-len,"%L",id,"HTML_CLOSE")
		
	show_motd(id,theBuffer,tt)
	
	return PLUGIN_HANDLED
}

public plugin_natives()
{
	register_native("get_skilll", "get_skilll", 1);
}

public get_skilll(id, szBuffer[])
{
	new stats[8],bh[8], szSkill[10], szStr[10], fStats = effec(stats);
	get_skill(stats, szSkill, charsmax(szSkill));
	get_user_stats(id,stats,bh)
	formatex(szStr, charsmax(szStr), "%s %f", szSkill, fStats);
	copy(szBuffer, charsmax(szBuffer), szStr);
}

// ������������ ���� ��� ��������� ���������� �������
public ShowStatsMenu(id,page){
	if(!SayStatsAll){
		client_print_color(id,0,"%L %L",id,"STATS_TAG", id,"DISABLED_MSG")
		
		return PLUGIN_HANDLED
	}
	
	new menuKeys,menuText[512],menuLen
	new tName[42],players[32],pCount
	
	get_players(players,pCount)
	
	new maxPages = ((pCount - 1) / 7) + 1 // ������� ����. ���-�� �������
	
	// ���������� � ������, ���� ����� �������� �� ����������
	if(page > maxPages)
		page = 0

	// ��������� ������ ������ �������� ��������
	new usrIndex = (7 * page)
	
	menuLen += formatex(menuText[menuLen],MENU_LEN - 1 - menuLen,"%L %L\R\y%d/%d^n",
		id,"MENU_TAG",id,"MENU_TITLE",page + 1,maxPages)
	
	// ��������� ������� � ����
	while(usrIndex < pCount){
		get_user_name(players[usrIndex],tName,31)
		menuKeys |= (1 << usrIndex % 7)
		
		menuLen += formatex(menuText[menuLen],MENU_LEN - 1 - menuLen,"^n\r%d.\w %s",
			(usrIndex % 7) + 1,tName)
		
		usrIndex ++
		
		// �������� ����������
		// ���� ������ �������� ��� ���������
		if(!(usrIndex % 7))
			break
	}
	
	// ������� ��������� ����������
	menuLen += formatex(menuText[menuLen],MENU_LEN - 1 - menuLen,"^n^n\r%d.\w %L",8,id,g_MenuStatus[id][0] ? "MENU_RANK" : "MENU_STATS")
	menuKeys |= MENU_KEY_8
	
	if(!(usrIndex % 7)){
		menuLen += formatex(menuText[menuLen],MENU_LEN - 1 - menuLen,"^n^n\r%d.\w %L",9,id,"MORE")
		menuKeys |= MENU_KEY_9
	}
	
	if((7 * page)){
		menuLen += formatex(menuText[menuLen],MENU_LEN - 1 - menuLen,"^n^n\r%d.\w %L",0,id,"BACK")
		menuKeys |= MENU_KEY_0
	}else{
		menuLen += formatex(menuText[menuLen],MENU_LEN - 1 - menuLen,"^n^n\r%d.\w %L",0,id,"EXIT")
		menuKeys |= MENU_KEY_0
	}
			
	
	show_menu(id,menuKeys,menuText,-1,"Stats Menu")
	
	return PLUGIN_HANDLED
}

public actionStatsMenu(id,key){
	switch(key){
		case 0..6:{
			new usrIndex = key + (7 * g_MenuStatus[id][1]) + 1
			
			if(!is_user_connected(id)){
				ShowStatsMenu(id,g_MenuStatus[id][1])
				
				return PLUGIN_HANDLED
			}
				
			g_MenuStatus[id][0] ? RankStatsSay(id,usrIndex) : StatsMeSay(id,usrIndex)
			
			ShowStatsMenu(id,g_MenuStatus[id][1])
		}
		case 7:{
			g_MenuStatus[id][0] = g_MenuStatus[id][0] ? 0 : 1
			ShowStatsMenu(id,g_MenuStatus[id][1])
		}
		case 8:{
			g_MenuStatus[id][1] ++
			ShowStatsMenu(id,g_MenuStatus[id][1])
		}
		case 9:{
			if(g_MenuStatus[id][1]){
				g_MenuStatus[id][1] --
				ShowStatsMenu(id,g_MenuStatus[id][1])
			}
		}
	}
	
	return PLUGIN_HANDLED
}

// ���������� ������� �������
public ShowAStats(id){
	theBuffer[0] = 0
	
	new len,tt[64]
	formatex(tt,63,"%L",id,"THE_STATS")
	
	//len += formatex(buffer[len],1535 - len,"<html><head>")
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L%L",id,"HTML_META",id,"HTML_STYLE")
	//len += formatex(buffer[len],1535 - len,"</head><body>")
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_TOP_BODY",id,"THE_STATS")
	
	len += parse_top_desc_header(id,theBuffer,BUFF_LEN,len,true)
	
	len = parse_top_desc_body(id,theBuffer,BUFF_LEN,len,Invalid_Array,Invalid_Array,Invalid_Array,Invalid_Array,true)
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_CLOSE")

	//len += formatex(buffer[len],1562 - len,"</body></html")
	
	show_motd(id,theBuffer,tt)
	
	return PLUGIN_HANDLED
}

public AStats_Sort_Function(elem1,elem2){
	new st1[AES_ST_END],st2[AES_ST_END]
	
	aes_get_player_stats(elem1,st1)
	aes_get_player_stats(elem2,st2)
	
	if(st1[AES_ST_EXP] > st2[AES_ST_EXP])
		return -1
	else if(st1[AES_ST_EXP] < st2[AES_ST_EXP])
		return 1
		
	return 0
}

// �������� �� ������� ������
public ShowAList(id){
	theBuffer[0] = 0
	
	new len,len2,tt[64],buff[BUFF_LEN]
	formatex(tt,63,"%L",id,"THE_RANKS")
	
	//len += formatex(buffer[len],1535 - len,"<html><head>")
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L%L",id,"HTML_META",id,"HTML_STYLE")
	//len += formatex(buffer[len],1535 - len,"</head><body>")
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_TOP_BODY",id,"THE_RANKS")
	
	new aStats[AES_ST_END],levelName[64],bool:theSwitcher
	
	aes_get_player_stats(id,aStats)
	
	new stPos = max(0,aStats[AES_ST_LEVEL] - (get_pcvar_num(cvar[CVAR_ALIST_CNT])/2))
	new enPos = max(10,aStats[AES_ST_LEVEL] + (get_pcvar_num(cvar[CVAR_ALIST_CNT])/2))
	
	enPos = min(enPos,aes_get_max_level())
	
	len2 += formatex(buff[len2],BUFF_LEN-len2,"%L",id,"HTML_HEADER_CELL","",id,"STATS_RANK")
	len2 += formatex(buff[len2],BUFF_LEN-len2,"%L",id,"HTML_HEADER_CELL","",id,"STATS_EXP")
	
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_TOP_HEADER_ROW",buff)
	
	buff[0] = 0
	len2 = 0
	
	for(new i = stPos; i < enPos ; ++i){
		aes_get_level_name(i,levelName,63,id)
		
		len2 += formatex(buff[len2],BUFF_LEN - len2,"%L",id,"HTML_BODY_CELL",levelName)
		
		if(!i)
			num_to_str(0,levelName,63)
		else
			num_to_str(aes_get_exp_to_next_level(i - 1),levelName,63)
		
		len2 += formatex(buff[len2],BUFF_LEN - len2,"%L",id,"HTML_BODY_CELL",levelName)
		
		if(i != aStats[AES_ST_LEVEL])
			len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_BODY_ROW",theSwitcher ? " class=b" : " class=q",buff)
		else
			len += formatex(theBuffer[len],BUFF_LEN - len,"<u>%L</u>",id,"HTML_BODY_ROW",theSwitcher ? " class=b style=^"text-decoration: underline;^"" : " class=q style=^"text-decoration: underline;^"",buff)
		
		theSwitcher = theSwitcher ? false : true
		
		buff[0] = 0
		len2 = 0
	}
	
	len += formatex(theBuffer[len],BUFF_LEN - len,"%L",id,"HTML_CLOSE")

	show_motd(id,theBuffer,tt)
	
	return PLUGIN_HANDLED
}

// Stats formulas
Float:accuracy(izStats[8])
{
	if (!izStats[STATS_SHOTS])
		return (0.0)
	
	return (100.0 * float(izStats[STATS_HITS]) / float(izStats[STATS_SHOTS]))
}

Float:effec(izStats[8])
{
	if (!izStats[STATS_KILLS])
		return (0.0)
	
	return (100.0 * float(izStats[STATS_KILLS]) / float(izStats[STATS_KILLS] + izStats[STATS_DEATHS]))
}
