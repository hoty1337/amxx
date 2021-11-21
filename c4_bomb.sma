/* 
	Portable bomba Gun
	by serfreeman1337	http://gf.hldm.org/
*/

#include <amxmodx>
#include <hl_wpnmod>
#include < engine >

//new hl_Cannons,create_gun
new bomb
new g_iTimer

#define TASKID 122441

#define WPN_NAME "weapon_turret52"
#define WPN_HUD_SLOT 5
#define WPN_HUD_POS 5
#define WPN_AMMO1 "turrets"
#define WPN_AMMO1MAX 1
#define START_TIME 5
#define PING 1.0

#define W_MODEL "models/c4_bomb/w_c4.mdl"
#define V_MODEL "models/c4_bomb/v_c4.mdl"
#define P_MODEL "models/c4_bomb/p_c4.mdl"

#define HUD_SPR "sprites/obsidional_turret.spr"
#define HUD_TXT "sprites/weapon_turret52.txt"

#define Offset_flPlaceTime	Offset_flPumpTime

enum _:ANIMA {
	IDLE,
	DRAW,
	SET
}

public plugin_precache(){
	PRECACHE_MODEL(W_MODEL)
	PRECACHE_MODEL(V_MODEL)
	PRECACHE_MODEL(P_MODEL)
	
	PRECACHE_GENERIC(HUD_SPR)
	PRECACHE_GENERIC(HUD_TXT)
	
	PRECACHE_SOUND("turret/fights-77.wav")
}

public plugin_init(){
	register_plugin("Siege bomba Gun","RUSSIA","serfreeman1337")
	

	
	//create_gun = get_func_id("create_cannon",hl_Cannons)
	
	new bomba = wpnmod_register_weapon(WPN_NAME,WPN_HUD_SLOT,WPN_HUD_POS,WPN_AMMO1,WPN_AMMO1MAX,"",-1,-1,ITEM_FLAG_EXHAUSTIBLE |  ITEM_FLAG_LIMITINWORLD,0)
	
	wpnmod_register_weapon_forward(bomba,Fwd_Wpn_Spawn,"DS_Spawn")
	wpnmod_register_weapon_forward(bomba,Fwd_Wpn_Deploy,"DS_Deploy")
	wpnmod_register_weapon_forward(bomba,Fwd_Wpn_Holster,"DS_Holster")
	wpnmod_register_weapon_forward(bomba,Fwd_Wpn_PrimaryAttack,"DS_Place")
	wpnmod_register_weapon_forward(bomba,Fwd_Wpn_Idle,"DS_Idle")
}

public DS_Spawn(ent){
	wpnmod_set_offset_int(ent,Offset_iDefaultAmmo,WPN_AMMO1MAX)
	SET_MODEL(ent,W_MODEL)
}

public DS_Deploy(ent,player){
	return wpnmod_default_deploy(ent,V_MODEL,P_MODEL,DRAW,"egon")
}

public DS_Place(ent,player,clip,ammo){
	if(ammo <= 0)
		return

	set_pev(player,pev_maxspeed,-90.0)
	set_pev(player,pev_velocity,Float:{0.0,0.0,0.0})
	
	new Float:placeTime = wpnmod_get_offset_float(ent,Offset_flPlaceTime)
	
	if(!placeTime)	
		wpnmod_send_weapon_anim(ent,SET)
		
	if(placeTime >= 2.0){
		//callfunc_begin_i(create_gun,hl_Cannons)
		//callfunc_push_int(player)
		//callfunc_push_int(0)
		
		DS_BombsSpawn(player)
		
		//client_cmd(player, "say /000")
		
			wpnmod_set_player_ammo(player,WPN_AMMO1,ammo - 1)
		
		Reset_Place(ent,player)
		wpnmod_set_offset_float(ent,Offset_flPlaceTime,0.0)
	}else
		wpnmod_set_offset_float(ent,Offset_flPlaceTime,placeTime + 0.1)

	wpnmod_set_offset_float(ent,Offset_flNextPrimaryAttack,0.1)
	wpnmod_set_offset_float(ent,Offset_flNextSecondaryAttack,0.2)
	wpnmod_set_offset_float(ent,Offset_flTimeWeaponIdle,0.15)
}

public DS_BombsSpawn(player){

	
	bomb = create_entity("info_target")
	new orig[3],Float:origin[3]
	get_user_origin(player,orig,0)
	//float(origin_bomb[3])
	
	origin[0] = float(orig[0])
	origin[1] = float(orig[1])
	//origin[2] = float(orig[2] - 36)
	origin[2] = pev(player, pev_flags) & FL_DUCKING ? float(orig[2] - 18) : float(orig[2] - 36)	
	
	entity_set_model(bomb,W_MODEL)
	entity_set_origin(bomb,origin)
	g_iTimer = -1
	new Float:iArgs[5];
	iArgs[0] = player; iArgs[1] = bomb; 
	iArgs[2] = origin[0]; iArgs[3] = origin[1]; iArgs[4] = origin[2];
	DS_BombsTimer(iArgs, TASKID+player);
	
	
	return 

}

public DS_BombsTimer(iArgs[], idx) {
	new player, bomb, origin[3];
	if(iArgs[0] > 0)
	{
		player = iArgs[0]; bomb = iArgs[1];
		origin[0] = iArgs[2]; origin[1] = iArgs[3]; origin[2] = iArgs[4];
	}
	else return;
	if(g_iTimer == -1)
    {
        g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 9)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/nine.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);	
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 8)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/eight.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 7)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/seven.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 6)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/six.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 5)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/five.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 4)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/four.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 3)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/three.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 2)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/two.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 1)
    {
		emit_sound(bomb, CHAN_ITEM, "fvox/one.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		set_task(PING, "DS_BombsTimer", idx, iArgs, sizeof iArgs);
    }
	if(g_iTimer == 0)
    {
		//emit_sound(bomb, CHAN_ITEM, "fvox/two.wav", 0.6, ATTN_NORM, 0, PITCH_NORM);
		//set_task(0.9465, "DS_BombsTimer", TASKID, _,_, "b");
        //g_iTimer = START_TIME;
		client_cmd(player, "say !BOOM!")
		remove_task(idx)
		
		if(bomb != -1 && is_valid_ent(bomb)) {
			remove_entity(bomb);
			bomb = -1;
		}
			
    }



	
	//g_iTimer = START_TIME
	--g_iTimer
	
	return 

}

public DS_Idle(ent,player){
	if(!wpnmod_get_offset_float(ent,Offset_flTimeWeaponIdle))
		return
		
	if(wpnmod_get_offset_float(ent,Offset_flPlaceTime)){
		wpnmod_send_weapon_anim(ent,DRAW)
		//server_print("RESET ON %.2f",wpnmod_get_offset_float(ent,Offset_flPlaceTime))
		Reset_Place(ent,player)
		wpnmod_set_offset_float(ent,Offset_flPlaceTime,0.0)
	}
}

public DS_Holster(ent,player){
	if(wpnmod_get_offset_float(ent,Offset_flPlaceTime)){
		Reset_Place(ent,player)
		wpnmod_set_offset_float(ent,Offset_flPlaceTime,0.0)
	}
}

public Reset_Place(ent,player){
	//server_print("RESET MAXSPEED FOR %d",player)
	set_pev(player,pev_maxspeed,155.0)
}