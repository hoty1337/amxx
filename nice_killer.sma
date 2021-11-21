/**
*	Modified by Safety1st
*	  8/17/2014
*
*	Home post:
*	  http://c-s.net.ua/forum/index.php?act=findpost&pid=610190
*
*	Changes are:
*	- a lot corrections to get nice plugin
*	- multilingual support
*	- added support for Russian words endings 
*
*	Notes:
*	- each headshot is counted even if it didn't lead to death
*	- self damage/kills, C4 damage and other world damage are ignored
*
*	Credits:
*	- Subb98 for some info about Ham_TakeDamage forward
*/

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

/*---------------EDIT ME------------------*/
//#define IGNORE_TEAM_DAMAGE	// uncomment this on servers where friendly fire is ON
#define MAX_PLAYERS 32
/*----------------------------------------*/

enum _:score {
	frags,
	Float:dmg,
	hs
}

new niceP[MAX_PLAYERS + 1][score]

new hudsync

new maxplayers

enum _:Types { word_frag, word_hs }

#define m_iTeam 114
#define fm_cs_get_user_team_index(%1)	get_pdata_int( %1, m_iTeam )

public plugin_init() {
	register_plugin( "Nice Killer", "1.6", "Got Milk? / HoHoL / Safety1st" )
	register_dictionary( "nice_killer.txt" )

	RegisterHam( Ham_TakeDamage, "player", "hook_TakeDamage_Post", .Post = 1 )
	register_event( "DeathMsg", "Event_DeathMessage", "a", "1!0" )	// killed by player ('1')
	register_logevent( "event_round_end", 2, "1=Round_End" )
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" )

	hudsync = CreateHudSyncObj()

	maxplayers = get_maxplayers()
}

public event_round_end()
	// delay is needed to count last round kill
	set_task( 1.0, "GetTheBest" )

public GetTheBest() {
	new iPlayers[32], iPlayersNum, player
	new pfrags, Float:pdamage, tmpf, Float:tmpd, tmpid
	get_players( iPlayers, iPlayersNum, "h" )	// except HLTV

	for( new i; i < iPlayersNum; i++ ) {
		player = iPlayers[i]
		pfrags = niceP[player][frags]

		if( pfrags < tmpf )
			continue

		pdamage = niceP[player][dmg]
		if ( pfrags > tmpf || pdamage > tmpd ) {
			tmpid = player
			tmpf = pfrags
			tmpd = pdamage
		}
	}

	if( tmpf ) {
		// there is a winner
		static name[32], wordfrag[20], wordhs[40], msg[192]
		get_user_name( tmpid, name, charsmax(name) )
		set_hudmessage( random(200) + 25, random(200) + 25, random(200) + 25, -1.0, 0.17, 0, 5.0 )	// 5.0 is max possible holdtime
		for( new i = 1; i <= maxplayers; i++ ) {
			if( !is_user_connected(i) )
				continue

			CreateWord( i, word_frag, tmpf, wordfrag, charsmax(wordfrag) )
			CreateWord( i, word_hs, niceP[tmpid][hs], wordhs, charsmax(wordhs) )
			formatex( msg, charsmax(msg), "%L", i, "NC_MESSAGE",
			name, wordfrag, wordhs, floatround(tmpd) /* it's better to round float than ignore decimal part */ )

			ShowSyncHudMsg(i, hudsync, msg)
		}
	}
}

CreateWord( id, type, value, word[], len = 0 ) {
	enum _:Count { alone, afew, many }
	static szWord[Types][Count][] = { 
		{ "NC_WORD_KILL_1", "NC_WORD_KILL_2_4", "NC_WORD_KILL_S" },
		{   "NC_WORD_HS_1",   "NC_WORD_HS_2_4",   "NC_WORD_HS_S" }
	}

	new iLen = formatex( word, len, "%d ", value )
	switch( value ) {
		case 1, 21, 31, 41, 51, 61, 71, 81, 91 :
			formatex( word[iLen], len - iLen, "%L", id, szWord[type][alone] )
		case 2..4, 22..24, 32..34, 42..44, 52..54, 62..64, 72..74, 82..84, 92..94 :
			formatex( word[iLen], len - iLen, "%L", id, szWord[type][afew] )
		default :
			formatex( word[iLen], len - iLen, "%L", id, szWord[type][many] )
	}
}

public hook_TakeDamage_Post( victim, inflictor, attacker, Float:damage, damagebits ) {
#if !defined DMG_GRENADE
	// for compatibility with old AMXX
	#define DMG_GRENADE (1<<24) 	// hit by HE grenade
#endif

	if( !attacker || attacker > maxplayers || victim == attacker /* ignore self-damage */ )
		return HAM_IGNORED

	// forward is fired even if mp_friendlyfire = 0
	if( fm_cs_get_user_team_index(victim) == fm_cs_get_user_team_index(attacker) )
		// ignore team damage
		return HAM_IGNORED

	if( inflictor == attacker || damagebits & DMG_GRENADE ) {
		niceP[attacker][dmg] += damage

		#define m_LastHitGroup 75
		if( get_pdata_int( victim, m_LastHitGroup ) == HIT_HEAD )
			niceP[attacker][hs]++
	}

	return HAM_IGNORED
}

public Event_DeathMessage() {
	#define KillerID 1
	#define VictimID 2

	static iKiller, iVictim
	iKiller = read_data(KillerID)
	iVictim = read_data(VictimID)

	if( iKiller != iVictim /* except suicides; BTW death due to amx_slay is a suicide too */ ) {
#if defined IGNORE_TEAM_DAMAGE
		if( fm_cs_get_user_team_index(iKiller) == fm_cs_get_user_team_index(iVictim) )
			// ignore TKs
			return
#endif
		niceP[iKiller][frags]++
	}
}

public event_round_start() {
	for( new i = 1; i <= maxplayers; i++ )
		arrayset( niceP[i], 0, score )
}

public client_disconnect(id)
	arrayset( niceP[id], 0, score ) 