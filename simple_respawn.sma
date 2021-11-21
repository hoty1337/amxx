/**
*	Simple respawn with progress bar
*
*	Home post:
*	  http://c-s.net.ua/forum/index.php?act=findpost&pid=648790
*	
*	Last update:
*	  8/25/2014
*
*	Credits:
*	- ConnorMcLeod for code that forces spawning of newly connected players
*
*	Attention!
*	  Plugin is intended to be used only on servers where players are allowed to choose appearance except for CSDM mod!
*/

/*	Copyright 2014  Safety1st

	Simple Respawn is free software;
	you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>

#define PLUGIN "Simple Respawn"
#define VERSION "0.6"
#define AUTHOR "fl0wer / Safety1st"

/*------------------ EDIT ME ------------------*/
#define RESPAWN_DELAY     5     // delay before respawn
#define SHOW_BAR                // comment to disable HUD progress bar
#define MAX_PLAYERS       32
/*------ NOTHING TO EDIT BELOW THIS POINT ------*/

#if defined SHOW_BAR
new gMsgBarTime
#endif

new HamHook:g_iHhCBasePlayerPreThink

const m_iJoinedState = 121
const m_iMenu = 205
const MENU_CHOOSEAPPEARANCE = 3
const STATE_JOINED = 0
const STATE_PICKINGCLASS = 4
const PDATA_SAFE = 2

new giExecuteFwd
enum {
	PLAYER_SPAWN,
	PLAYER_RESPAWN
}

new Float:gflNextAllowedTime[MAX_PLAYERS + 1]

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR )
	register_dictionary( "simple_respawn.txt" )

	RegisterHam( Ham_Killed, "player", "OnCBasePlayer_Killed_Post", .Post = 1 )
	DisableHamForward( g_iHhCBasePlayerPreThink = RegisterHam( Ham_Player_PreThink, "player", "OnCBasePlayer_PreThink_Post", .Post = 1 ) )

#if defined SHOW_BAR
	gMsgBarTime = get_user_msgid( "BarTime" )
#endif

	register_clcmd( "chooseteam", "ClCmd_ChooseTeam_Cmd" )
	register_clcmd( "menuselect", "ClCmd_MenuSelect_JoinClass" )
	register_clcmd( "joinclass", "ClCmd_MenuSelect_JoinClass" )
}

public OnCBasePlayer_Killed_Post(id) {
	set_task( RESPAWN_DELAY.0, "Respawn", id )

#if defined SHOW_BAR
	message_begin( MSG_ONE_UNRELIABLE, gMsgBarTime, _, id )
	write_short( RESPAWN_DELAY )
	message_end()
#endif

	client_print( id, print_center, "%L", id, "RESPAWN_MSG", RESPAWN_DELAY )
}

public Respawn(id) {
	switch( cs_get_user_team(id) ) {
		case CS_TEAM_T, CS_TEAM_CT : {
			if( !is_user_alive(id) )
				ExecuteHam( Ham_CS_RoundRespawn, id )
		}
	}
}

public client_disconnect(id)
	remove_task(id)

public ClCmd_ChooseTeam_Cmd(id) {
	if( is_user_alive(id) )
		// as a simple solution: 1st invoke could be useless for a player who wants to join to Spectators
		return

	// avoiding abusing
	new Float:flTime = get_gametime()
	if( gflNextAllowedTime[id] > flTime )
		return

	// intentionally allow unlimited team change for dead players because of infinity round
	if( pev_valid(id) == PDATA_SAFE ) {
		// thx to ConnorMcLeod
#if AMXX_VERSION_NUM < 183
		const m_bools125 = 125
		const m_bHasChangeTeamThisRound = (1<<8)
		set_pdata_int( id, m_bools125, get_pdata_int( id, m_bools125 ) & ~m_bHasChangeTeamThisRound )
#else
		const m_bHasChangeTeamThisRound = 501	// bool m_bTeamChanged
		set_pdata_bool( id, m_bHasChangeTeamThisRound, false )
#endif

		gflNextAllowedTime[id] = flTime + RESPAWN_DELAY.0
	}
}

public ClCmd_MenuSelect_JoinClass(id) {
	if( pev_valid(id) == PDATA_SAFE && get_pdata_int( id, m_iMenu ) == MENU_CHOOSEAPPEARANCE ) {
		switch( get_pdata_int( id, m_iJoinedState ) ) { 	// that check is mandatory for safety
			case STATE_PICKINGCLASS : {
				// player is entering to a game for the first time
				giExecuteFwd = PLAYER_SPAWN
			}
			case STATE_JOINED : {
				if( task_exists(id) ) {
					// no need to respawn here; it also avoids abusing
					return
				}
				giExecuteFwd = PLAYER_RESPAWN
			}
		}
		EnableHamForward( g_iHhCBasePlayerPreThink )
	}
}

public OnCBasePlayer_PreThink_Post(id) {
	DisableHamForward( g_iHhCBasePlayerPreThink )
	if( !is_user_alive(id) )
		giExecuteFwd == PLAYER_SPAWN ? fm_cs_user_spawn(id) : ExecuteHam( Ham_CS_RoundRespawn, id )
}

/* code from base fakemeta_util.inc is used since even
   ExecuteHamB( Ham_Spawn, id ) is not noticed by other plugins */
fm_cs_user_spawn(index) {
	set_pev( index, pev_deadflag, DEAD_RESPAWNABLE )
	dllfunc( DLLFunc_Spawn, index )
	set_pev( index, pev_iuser1, 0 ) 	// OBS_NONE; to remove 'Free Chase Cam' hint
}