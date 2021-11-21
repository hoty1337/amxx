/* AMX Mod X
*   Longjump Player Model for HLDM
*
* (c) Copyright 2010 by KORD_12.7
*
* This file is provided as is (no warranties)
*/
//--------------------------------------------------------------------------------------------------
#include <amxmodx>
#include <fakemeta_util>
#include <amxmisc>
#include <engine>
#include <fun>



#define PLUGIN "Longjump Player Model"
#define VERSION "0.1"
#define AUTHOR "KORD_12.7"

#define MAX_CLIENTS	32
#define DEPLOY_SOUND "items/open_parachute.WAV"
#define PARACHUTE_LEVEL
//--------------------------------------------------------------------------------------------------
new 
const g_lj_model[] = "models/p_parachute.mdl"

new 
g_ClientLJ[MAX_CLIENTS + 1],
g_CvarEnable

new bool:has_parachute[33]
new para_ent[33]
new gCStrike = 0
new pDetach, pFallSpeed, pCost
//new bool:iSaveList=false

//--------------------------------------------------------------------------------------------------
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("ljpm_version", VERSION, FCVAR_SERVER)
	
	register_event("DeathMsg", "fw_Killed", "a")
	register_event("ItemPickup", "fw_Longjump_AddToPlayer", "b", "1&item_longjump")
	//register_clcmd("parachute_is_off", "noit")
	//register_clcmd("say /bbb", "fw_Killed")
	register_impulse(100, "Impulse100");
	
	
	g_CvarEnable = register_cvar("p_parachute", "1")
	//g_MaxPlayers = get_maxplayers()
	
	engfunc(EngFunc_PrecacheModel, g_lj_model)
	
	pFallSpeed = register_cvar("parachute_fallspeed", "100")
	pDetach = register_cvar("parachute_detach", "1")

	if (cstrike_running()) gCStrike = true

	if (gCStrike) {

		pCost = register_cvar("parachute_cost", "1000")

		//register_concmd("amx_parachute", "admin_give_parachute", PARACHUTE_LEVEL, "<nick, #userid or @team>" )
	}
}
public plugin_precache()
{
	precache_model("models/parachute.mdl")
	
	precache_sound(DEPLOY_SOUND)
}
//--------------------------------------------------------------------------------------------------	
public client_disconnect(id)
{
	if(!get_pcvar_num(g_CvarEnable))
		return PLUGIN_CONTINUE
	
	
	RemoveClientLJ(id)
	
	
	return PLUGIN_CONTINUE
}
//--------------------------------------------------------------------------------------------------	
public fw_Killed(id)
{	//client_cmd(id, "parachute_is_off")
	//client_cmd(id, "say /_is_off")
	if(!get_pcvar_num(g_CvarEnable))
		return PLUGIN_CONTINUE
	
	static victim; victim = read_data(2)
	RemoveClientLJ(victim)
	return PLUGIN_CONTINUE
}

stock RemoveClientLJ(id)
{
	if(g_ClientLJ[id] > 0)
	{
		if(is_valid_ent(g_ClientLJ[id]))
		{
			remove_entity(g_ClientLJ[id]);
			//client_cmd(id, "say /off")
			parachute_reset(id)
			set_user_longjump(id,1)
		}
	}
	g_ClientLJ[id] = 0;
}
//--------------------------------------------------------------------------------------------------
public fw_Longjump_AddToPlayer(id)
{
	if(!get_pcvar_num(g_CvarEnable))
		return PLUGIN_CONTINUE
	
	g_ClientLJ[id] = create_entity("info_target");
	
	set_pev(g_ClientLJ[id], pev_movetype, MOVETYPE_FOLLOW)
	set_pev(g_ClientLJ[id], pev_aiment, id)
	set_pev(g_ClientLJ[id], pev_rendermode, kRenderNormal)
	set_pev(g_ClientLJ[id], pev_renderamt, 0.0)
	engfunc(EngFunc_SetModel, g_ClientLJ[id], g_lj_model)
	parachute_Spawn(id)
	set_user_longjump(id,0)
	
	return PLUGIN_CONTINUE
}
//--------------------------------------------------------------------------------------------------
/*public noit(id)
{
	set_user_longjump(id,1) 
	//give_item(id, "item_longjump")
	//new it = get_weaponid("item_longjump")
	//ExecuteHamB(Ham_RemovePlayerItem,id,it)
	//ExecuteHamB(Ham_Item_Kill,it);
	//ham_strip_weapon(id,"item_longjump")
	//client_cmd(id, "say /longoff")
}*/
stock set_user_longjump(iPlayer, _on = 1) {    //force lj to a player, when other methods fail
	if (!is_user_connected(iPlayer))
		return
    
	if (_on)
	{
		set_pdata_int(iPlayer,291,1,5)
		engfunc(EngFunc_SetPhysicsKeyValue, iPlayer, "slj","1")
		
	}
	else
	{
		set_pdata_int(iPlayer,291,1,0)
		engfunc(EngFunc_SetPhysicsKeyValue, iPlayer, "slj","0")
		
	}
	return
} 

public Impulse100(id)
{
	
}
public plugin_natives()
{
	set_module_filter("module_filter")
	set_native_filter("native_filter")
}

public module_filter(const module[])
{
	if (!cstrike_running() && equali(module, "cstrike")) {
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public native_filter(const name[], index, trap)
{
	if (!trap) return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}

public death_event()
{
	new id = read_data(2)
	parachute_reset(id)
}

public parachute_reset(id)
{
	if(para_ent[id] > 0) {
		if (is_valid_ent(para_ent[id])) {
			remove_entity(para_ent[id])
		}
	}

	if (is_user_alive(id)) set_user_gravity(id, 1.0)

	has_parachute[id] = false
	para_ent[id] = 0
	
	//client_cmd(id, "say /parachute_reset")
}

public parachute_Spawn(id)
{	 
	if(para_ent[id] > 0) {
		remove_entity(para_ent[id])
		set_user_gravity(id, 1.0)
		para_ent[id] = 0
	}
	
	if (!gCStrike || get_pcvar_num(pCost) <= 0) {
		has_parachute[id] = true
		//set_view(id, CAMERA_3RDPERSON)
	}
	//set_task ( 0.1, "noit")
	//noit(id)
	
}

public HandleSay(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE

	//new args[128]
	//read_args(args, 127)
	//remove_quotes(args)


	
	//client_cmd(id, "say /HandleSay")
	return PLUGIN_CONTINUE
}
public client_PreThink(id)
{
	//parachute.mdl animation information
	//0 - deploy - 84 frames
	//1 - idle - 39 frames
	//2 - detach - 29 frames

	//if (!get_pcvar_num(pEnabled)) return
	if (!is_user_alive(id) || !has_parachute[id]) return

	new Float:fallspeed = get_pcvar_float(pFallSpeed) * -1.0
	new Float:frame

	new button = get_user_button(id)
	new flags = get_entity_flags(id)

	if (para_ent[id] > 0 && (flags & FL_ONGROUND)) {
		if (get_pcvar_num(pDetach)) {

			if (get_user_gravity(id) == 0.1) set_user_gravity(id, 1.0)

			if (entity_get_int(para_ent[id],EV_INT_sequence) != 2) {
				entity_set_int(para_ent[id], EV_INT_sequence, 2)
				entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
				entity_set_float(para_ent[id], EV_FL_frame, 0.0)
				entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
				entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
				entity_set_float(para_ent[id], EV_FL_framerate, 0.0)
				return
			}

			frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 2.0
			entity_set_float(para_ent[id],EV_FL_fuser1,frame)
			entity_set_float(para_ent[id],EV_FL_frame,frame)

			if (frame > 254.0) {
				remove_entity(para_ent[id])
				para_ent[id] = 0
			}
		}
		else {
			remove_entity(para_ent[id])
			set_user_gravity(id, 1.0)
			para_ent[id] = 0
		}

		return
	}
	
	if(para_ent[id] > 0  && entity_get_int(para_ent[id],EV_INT_sequence) != 2){	
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		
		entity_set_int(id, EV_INT_sequence, 3)
		entity_set_int(id, EV_INT_gaitsequence, 1)
		entity_set_float(id, EV_FL_frame, 1.0)
		entity_set_float(id, EV_FL_framerate, 1.0)
		set_user_gravity(id, 0.1)

		velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
		entity_set_vector(id, EV_VEC_velocity, velocity)

		if (entity_get_int(para_ent[id],EV_INT_sequence) == 0) {
			frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 1.0
			entity_set_float(para_ent[id],EV_FL_fuser1,frame)
			entity_set_float(para_ent[id],EV_FL_frame,frame)

			if (frame > 100.0) {
				entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
				entity_set_float(para_ent[id], EV_FL_framerate, 0.4)
				entity_set_int(para_ent[id], EV_INT_sequence, 1)
				entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
				entity_set_float(para_ent[id], EV_FL_frame, 0.0)
				entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
			}
		}
	}

	if (button & IN_USE) {

		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)

		if (velocity[2] < 0.0) {

			if(para_ent[id] <= 0) {
				para_ent[id] = create_entity("info_target")
				if(para_ent[id] > 0) {
					entity_set_string(para_ent[id],EV_SZ_classname,"parachute")
					entity_set_edict(para_ent[id], EV_ENT_aiment, id)
					entity_set_edict(para_ent[id], EV_ENT_owner, id)
					entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW)
					entity_set_model(para_ent[id], "models/parachute.mdl")
					entity_set_int(para_ent[id], EV_INT_sequence, 0)
					entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
					entity_set_float(para_ent[id], EV_FL_frame, 0.0)
					entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
					
					emit_sound(id,CHAN_STATIC,DEPLOY_SOUND,VOL_NORM,ATTN_NORM,0,PITCH_NORM)
				}
			}

			if (para_ent[id] > 0) {

				entity_set_int(id, EV_INT_sequence, 3)
				entity_set_int(id, EV_INT_gaitsequence, 1)
				entity_set_float(id, EV_FL_frame, 1.0)
				entity_set_float(id, EV_FL_framerate, 1.0)
				set_user_gravity(id, 0.1)

				velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
				entity_set_vector(id, EV_VEC_velocity, velocity)

				if (entity_get_int(para_ent[id],EV_INT_sequence) == 0) {

					frame = entity_get_float(para_ent[id],EV_FL_fuser1) + 1.0
					entity_set_float(para_ent[id],EV_FL_fuser1,frame)
					entity_set_float(para_ent[id],EV_FL_frame,frame)

					if (frame > 100.0) {
						entity_set_float(para_ent[id], EV_FL_animtime, 0.0)
						entity_set_float(para_ent[id], EV_FL_framerate, 0.4)
						entity_set_int(para_ent[id], EV_INT_sequence, 1)
						entity_set_int(para_ent[id], EV_INT_gaitsequence, 1)
						entity_set_float(para_ent[id], EV_FL_frame, 0.0)
						entity_set_float(para_ent[id], EV_FL_fuser1, 0.0)
						//client_cmd(id, "say /off")
					}
				}
			}
		}
		else if (para_ent[id] > 0) {
			remove_entity(para_ent[id])
			set_user_gravity(id, 1.0)
			para_ent[id] = 0
		}
	}
	//client_cmd(id, "say /client_PreThink")
}
