
    #include <amxmodx>
    #include <amxmisc>
	#include <fakemeta_util>
	#include <hl_wpnmod>
	#include < engine >

    #define PLUGIN "Get Order"
	#define VERSION "1.0"
	#define AUTHOR "SF [AdmiN]"
	
	#define ORDER_1			"sprites/SpecialForce/order1.spr"
	#define ORDER_2			"sprites/SpecialForce/take_position.spr"
	#define ORDER_3			"sprites/SpecialForce/grenade_fire.spr"
	#define ORDER_4			"sprites/SpecialForce/sentry.spr"
	//#define ORDER_5			"sprites/SpecialForce/order_folow_me.spr"
	#define ORDER_6			"sprites/SpecialForce/reloading.spr"
    // ls, 			tk, 		fr, 		tr, 		fl, 		rl;
	// entId[0], 	entId[1], 	entId[2], 	entId[3], 	entId[4], 	entId[5]
	enum 
	{
		LS = 0,
		TK,
		FR,
		TR,
		FL,
		RL
	}
	new entId[6];
	new laser;
	new bool:has_order_5[33]
	new esp_colors[3][3] = {{0,255,0},{100,60,60},{60,60,100}}
	
	// ORDER_SOUNDS!!!!!
	new const OrderSounds[][] = {
	"spk SpecialForce/or_attack.wav",
	"spk SpecialForce/or_defense.wav",
	"spk SpecialForce/or_explosion.wav",
	"spk SpecialForce/or_fire.wav",
	"spk SpecialForce/or_turret.wav",
	"spk SpecialForce/or_folow.wav",
	"spk SpecialForce/or_excelent.wav",
	"spk SpecialForce/over.wav",
	"spk SpecialForce/or6_reloading.wav"
	}
	

	public plugin_init()
	{
		register_plugin(PLUGIN, VERSION, AUTHOR)
		
		register_clcmd("give_order_1", "get_order_1")
		register_clcmd("give_order_2", "get_order_2")
		register_clcmd("give_order_3", "get_order_3")
		register_clcmd("give_order_4", "get_order_4")
		register_clcmd("give_order_5", "get_order_5")
		register_clcmd("give_order_6", "get_order_6")
		
		register_clcmd("give_order_ex", "get_order_ex")
		set_task(0.1, "esp_timer", .flags = "b")
       
	}
	
	public plugin_precache()
	{
	
	PRECACHE_SOUND("SpecialForce/or_attack.wav")
	PRECACHE_SOUND("SpecialForce/or_defense.wav")
	PRECACHE_SOUND("SpecialForce/or_explosion.wav")
	PRECACHE_SOUND("SpecialForce/or_fire.wav")
	PRECACHE_SOUND("SpecialForce/or_turret.wav")
	PRECACHE_SOUND("SpecialForce/or_folow.wav")
	PRECACHE_SOUND("SpecialForce/or_excelent.wav")
	PRECACHE_SOUND("SpecialForce/over.wav")
	PRECACHE_SOUND("SpecialForce/or6_reloading.wav")
	
	entId[4] 	= precache_model("sprites/SpecialForce/order_folow_me.spr")
	
	PRECACHE_MODEL( ORDER_1 )
	PRECACHE_MODEL( ORDER_2 )
	PRECACHE_MODEL( ORDER_3 )
	PRECACHE_MODEL( ORDER_4 )
	//PRECACHE_MODEL( ORDER_5 )
	PRECACHE_MODEL( ORDER_6 )

	
	laser = precache_model("sprites/laserbeam.spr")
	}
	
	public get_order_6(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_A ){
	
	new name_or_or6[32]
	get_user_name(id, name_or_or6, 31)
	client_print(0, print_chat, "[ORDER] (%s): Place to reloading", name_or_or6)
	
	if(is_valid_ent(entId[5])) remove_entity(entId[5])
	
	
	
	entId[5] = create_entity("info_target")
	new Float:vecSrc[3],Float:vecAiming[3],Float:vecEnd[3]
	//new spk_order = random_num(2,3);
	
	//entity_set_string(entId[5],EV_SZ_classname,LSPOT_CLASSNAME)
	
	//entity_set_int(entId[5], EV_INT_effects, visible == 1 ? entity_get_int(entId[5], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[5], EV_INT_effects) | EF_NODRAW)
	//entity_get_int(entId[5], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[5], EV_INT_effects) | EF_NODRAW)
	entity_set_int(entId[5],EV_INT_rendermode,kRenderGlow)
	entity_set_int(entId[5],EV_INT_renderfx,kRenderFxNoDissipation) //DALNOST LAZERA
	entity_set_float(entId[5],EV_FL_renderamt,255.0) //Jarkostb
	set_pev(entId[5], pev_scale, 0.5)
	
	entity_set_model(entId[5],ORDER_6)
	
	
	wpnmod_get_gun_position(id,vecSrc)
	fm_get_aim_origin(id,vecAiming)	
	trace_line(id,vecSrc,vecAiming,vecEnd)
	entity_set_origin(entId[5],vecEnd)

	client_cmd(0, "%s" , OrderSounds[8])
	
		
	}else{
	
	client_cmd(id, "spk SpecialForce/aacess.wav")
	client_print(id, print_center, "Only COMMANDERS can issue orders!")
	//set_dhudmessage(255, 60, 0, -1.0, 0.49, 2, 1.0, 2.8, 0.04, 1.0)
	//show_dhudmessage(id, "Отдавать приказы могут только КОМАНДИРЫ!")
	
	

	
	}

	//client_print(id, print_chat, "flags %s", get_user_flags(id))
		
	return	
}
public esp_timer()
{
	static  Float:my_origin[3],  
			Float:target_origin[3], 
			Float:distance, width, 
			Float:v_middle[3],
			Float:v_hitpoint[3], 
			Float:distance_to_hitpoint, 
			Float:scaled_bone_len, 
			Float:v_bone_start[3],
			Float:v_bone_end[3],
			players[32], playersi[32],
			target_team = 2, s, numi, i

	get_players(players, numi, "ach");
	for(--numi; numi>=0; numi--)
    {
		i = playersi[numi]
		
		pev(i, pev_origin, my_origin)
		
		for(new k; k<6; k++)
		{
			s = entId[k];

			pev(s, pev_origin, target_origin);
			distance = vector_distance(my_origin, target_origin);

			subVec(target_origin, my_origin, v_middle)

			engfunc(EngFunc_TraceLine, my_origin, target_origin, 1, -1, 0)
			get_tr2(0, TR_vecEndPos, v_hitpoint)
			
			distance_to_hitpoint = vector_distance(my_origin, v_hitpoint);
			if(distance_to_hitpoint == distance)
			{
				//Линия
				width = distance < 2040.0 ? ((255 - floatround(distance / 8.0)) / 4) : 1
				make_TE_BEAMENTPOINT(i, target_origin, width);
			}
			else
			{
				normalize(v_middle, v_bone_start, distance_to_hitpoint - 10.0);
				addVec(v_bone_start, my_origin); 	// Начальная точка
				v_bone_start[2] += 17.5; 			// Поправка взгляда
				copyVec(v_bone_start, v_bone_end);
				scaled_bone_len = distance_to_hitpoint / distance * 50.0;
				v_bone_end[2] -= scaled_bone_len; // Конечная точка

				width = 1
				
				//Линия с боксом
				if(distance < 2040.0)
					width = (255 - floatround(distance / 8.0)) / 4
				
				make_TE_BEAMENTPOINT(i, v_bone_end, width)
				make_TE_BEAMPOINTS(i, target_team, v_bone_start, v_bone_end, floatround(scaled_bone_len))
			}
		}
    } 
}
	
	
	public get_order_5(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_A ){
	
	if(!has_order_5[id]){
	new name_or_or5[32]
	get_user_name(id, name_or_or5, 31)
	client_print(0, print_chat, "[ORDER] (%s): Everyone go to me!", name_or_or5)
	
	client_cmd(0, "%s" , OrderSounds[5])
	//client_cmd(id, "111")
	stop_sprite_func(id)
	
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_PLAYERATTACHMENT)
	write_byte(id)
	write_coord(50)
	write_short(entId[4])
	write_short(21200)
	message_end()
	
	has_order_5[id] = true	
	}else if(has_order_5[id]){
	stop_sprite_func(id)
	client_cmd(0, "%s" , OrderSounds[7])
	}

	}else{
	
	client_cmd(id, "spk SpecialForce/aacess.wav")
	client_print(id, print_center, "Only COMMANDERS can issue orders!")
	//set_dhudmessage(255, 60, 0, -1.0, 0.49, 2, 1.0, 2.8, 0.04, 1.0)
	//show_dhudmessage(id, "Отдавать приказы могут только КОМАНДИРЫ!")
	
	

	
	}

	//client_print(id, print_chat, "flags %s", get_user_flags(id))
		
	return	PLUGIN_CONTINUE
}
	
	public get_order_4(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_A ){
	
	new name_or_or4[32]
	get_user_name(id, name_or_or4, 31)
	client_print(0, print_chat, "[ORDER] (%s): Install the turret here!", name_or_or4)
	
	if(is_valid_ent(entId[3])) remove_entity(entId[3])
	
	
	
	entId[3] = create_entity("info_target")
	new Float:vecSrc[3],Float:vecAiming[3],Float:vecEnd[3]
	//new spk_order = random_num(2,3);
	
	//entity_set_string(entId[3],EV_SZ_classname,LSPOT_CLASSNAME)
	
	//entity_set_int(entId[3], EV_INT_effects, visible == 1 ? entity_get_int(entId[3], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[3], EV_INT_effects) | EF_NODRAW)
	//entity_get_int(entId[3], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[3], EV_INT_effects) | EF_NODRAW)
	entity_set_int(entId[3],EV_INT_rendermode,kRenderGlow)
	entity_set_int(entId[3],EV_INT_renderfx,kRenderFxNoDissipation) //DALNOST LAZERA
	entity_set_float(entId[3],EV_FL_renderamt,255.0) //Jarkostb
	set_pev(entId[3], pev_scale, 0.5)
	
	entity_set_model(entId[3],ORDER_4)
	
	
	wpnmod_get_gun_position(id,vecSrc)
	fm_get_aim_origin(id,vecAiming)	
	trace_line(id,vecSrc,vecAiming,vecEnd)
	entity_set_origin(entId[3],vecEnd)

	client_cmd(0, "%s" , OrderSounds[4])
	
		
	}else{
	
	client_cmd(id, "spk SpecialForce/aacess.wav")
	client_print(id, print_center, "Only COMMANDERS can issue orders!")
	//set_dhudmessage(255, 60, 0, -1.0, 0.49, 2, 1.0, 2.8, 0.04, 1.0)
	//show_dhudmessage(id, "Отдавать приказы могут только КОМАНДИРЫ!")
	
	

	
	}

	//client_print(id, print_chat, "flags %s", get_user_flags(id))
		
	return	
}
	
	public get_order_3(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_A ){
	
	new name_or_or3[32]
	get_user_name(id, name_or_or3, 31)
	client_print(0, print_chat, "[ORDER] (%s): Blow this position!", name_or_or3)
	
	if(is_valid_ent(entId[2])) remove_entity(entId[2])
	
	
	
	entId[2] = create_entity("info_target")
	new Float:vecSrc[3],Float:vecAiming[3],Float:vecEnd[3]
	new spk_order = random_num(2,3);
	
	//entity_set_string(entId[2],EV_SZ_classname,LSPOT_CLASSNAME)
	
	//entity_set_int(entId[2], EV_INT_effects, visible == 1 ? entity_get_int(entId[2], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[2], EV_INT_effects) | EF_NODRAW)
	//entity_get_int(entId[2], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[2], EV_INT_effects) | EF_NODRAW)
	entity_set_int(entId[2],EV_INT_rendermode,kRenderGlow)
	entity_set_int(entId[2],EV_INT_renderfx,kRenderFxNoDissipation) //DALNOST LAZERA
	entity_set_float(entId[2],EV_FL_renderamt,255.0) //Jarkostb
	set_pev(entId[2], pev_scale, 0.5)
	
	entity_set_model(entId[2],ORDER_3)
	
	
	wpnmod_get_gun_position(id,vecSrc)
	fm_get_aim_origin(id,vecAiming)	
	trace_line(id,vecSrc,vecAiming,vecEnd)
	entity_set_origin(entId[2],vecEnd)

	client_cmd(0, "%s" , OrderSounds[spk_order])
	
		
	}else{
	
	client_cmd(id, "spk SpecialForce/aacess.wav")
	client_print(id, print_center, "Only COMMANDERS can issue orders!")
	//set_dhudmessage(255, 60, 0, -1.0, 0.49, 2, 1.0, 2.8, 0.04, 1.0)
	//show_dhudmessage(id, "Отдавать приказы могут только КОМАНДИРЫ!")
	
	

	
	}

	//client_print(id, print_chat, "flags %s", get_user_flags(id))
		
	return	
}
	
	public get_order_2(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_A ){
	
	new name_or_or2[32]
	get_user_name(id, name_or_or2, 31)
	client_print(0, print_chat, "[ORDER] (%s): Take this position!", name_or_or2)
	
	if(is_valid_ent(entId[1])) remove_entity(entId[1])
	
	
	
	entId[1] = create_entity("info_target")
	new Float:vecSrc[3],Float:vecAiming[3],Float:vecEnd[3]
	//new spk_order = random_num(0,2);
	
	//entity_set_string(entId[1],EV_SZ_classname,LSPOT_CLASSNAME)
	
	//entity_set_int(entId[1], EV_INT_effects, visible == 1 ? entity_get_int(entId[1], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[1], EV_INT_effects) | EF_NODRAW)
	//entity_get_int(entId[1], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[1], EV_INT_effects) | EF_NODRAW)
	entity_set_int(entId[1],EV_INT_rendermode,kRenderGlow)
	entity_set_int(entId[1],EV_INT_renderfx,kRenderFxNoDissipation) //DALNOST LAZERA
	entity_set_float(entId[1],EV_FL_renderamt,255.0) //Jarkostb
	set_pev(entId[1], pev_scale, 0.5)
	
	entity_set_model(entId[1],ORDER_2)
	
	
	wpnmod_get_gun_position(id,vecSrc)
	fm_get_aim_origin(id,vecAiming)	
	trace_line(id,vecSrc,vecAiming,vecEnd)
	entity_set_origin(entId[1],vecEnd)

	client_cmd(0, "%s" , OrderSounds[1])
	
		
	}else{
	
	client_cmd(id, "spk SpecialForce/aacess.wav")
	client_print(id, print_center, "Only COMMANDERS can issue orders!")
	//set_dhudmessage(255, 60, 0, -1.0, 0.49, 2, 1.0, 2.8, 0.04, 1.0)
	//show_dhudmessage(id, "Отдавать приказы могут только КОМАНДИРЫ!")
	
	

	
	}

	//client_print(id, print_chat, "flags %s", get_user_flags(id))
		
	return	
}

	public get_order_1(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_A ){
	
	new name_or_or1[32]
	get_user_name(id, name_or_or1, 31)
	client_print(0, print_chat, "[ORDER] (%s): Attack this position!", name_or_or1)
	
	if(is_valid_ent(entId[0])) remove_entity(entId[0])
	
	
	
	entId[0] = create_entity("info_target")
	new Float:vecSrc[3],Float:vecAiming[3],Float:vecEnd[3]
	//new spk_order = random_num(0,2);
	
	//entity_set_string(entId[0],EV_SZ_classname,LSPOT_CLASSNAME)
	
	//entity_set_int(entId[0], EV_INT_effects, visible == 1 ? entity_get_int(entId[0], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[0], EV_INT_effects) | EF_NODRAW)
	//entity_get_int(entId[0], EV_INT_effects) & ~EF_NODRAW : entity_get_int(entId[0], EV_INT_effects) | EF_NODRAW)
	entity_set_int(entId[0],EV_INT_rendermode,kRenderGlow)
	entity_set_int(entId[0],EV_INT_renderfx,kRenderFxNoDissipation) //DALNOST LAZERA
	entity_set_float(entId[0],EV_FL_renderamt,255.0) //Jarkostb
	set_pev(entId[0], pev_scale, 0.5)
	
	entity_set_model(entId[0],ORDER_1)
	
	
	wpnmod_get_gun_position(id,vecSrc)
	fm_get_aim_origin(id,vecAiming)	
	trace_line(id,vecSrc,vecAiming,vecEnd)
	entity_set_origin(entId[0],vecEnd)

	client_cmd(0, "%s" , OrderSounds[0])
	
		
	}else{
	
	client_cmd(id, "spk SpecialForce/aacess.wav")
	client_print(id, print_center, "Only COMMANDERS can issue orders!")
	//set_dhudmessage(255, 60, 0, -1.0, 0.49, 2, 1.0, 2.8, 0.04, 1.0)
	//show_dhudmessage(id, "Отдавать приказы могут только КОМАНДИРЫ!")
	
	

	
	}

	//client_print(id, print_chat, "flags %s", get_user_flags(id))
		
	return	
}

public get_order_ex(id) {
	if(get_user_flags(id) & ADMIN_LEVEL_A ){
	
	client_cmd(0, "%s" , OrderSounds[6])
	
	new name_or_ex[32]
	get_user_name(id, name_or_ex, 31)
	client_print(0, print_chat, "[ORDER] (%s): Well done!", name_or_ex)

	if(entId[0] != -1 && is_valid_ent(entId[0])) {
	remove_entity(entId[0]);
	entId[0] = -1;
	}
	if(entId[1] != -1 && is_valid_ent(entId[1])) {
	remove_entity(entId[1]);
	entId[1] = -1;
	}
	if(entId[2] != -1 && is_valid_ent(entId[2])) {
	remove_entity(entId[2]);
	entId[2] = -1;
	}
	if(entId[3] != -1 && is_valid_ent(entId[3])) {
	remove_entity(entId[3]);
	entId[3] = -1;
	}
	if(entId[5] != -1 && is_valid_ent(entId[5])) {
	remove_entity(entId[5]);
	entId[5] = -1;
	}
	//stop_sprite_func(id)
	
	}else{
	
	client_cmd(id, "spk SpecialForce/aacess.wav")
	client_print(id, print_center, "Only COMMANDERS can issue orders!")
	//set_dhudmessage(255, 60, 0, -1.0, 0.49, 2, 1.0, 2.8, 0.04, 1.0)
	//show_dhudmessage(id, "Отдавать приказы могут только КОМАНДИРЫ!")
	
	

	
	}

	//client_print(id, print_chat, "flags %s", get_user_flags(id))
		
	return	entId[0], entId[1], entId[2], entId[3], entId[5]
}

public stop_sprite_func(id)
{	
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_KILLPLAYERATTACHMENTS)
	write_byte(id)
	message_end()	
	
	has_order_5[id] = false	
	return PLUGIN_CONTINUE
}

normalize(Float:Vec[3],Float:Ret[3],Float:multiplier)
{
    new Float:len = vector_distance(Vec, Float:{0.0, 0.0, 0.0});
    copyVec(Vec,Ret)
    Ret[0] /= len; Ret[0] *= multiplier;
    Ret[1] /= len; Ret[1] *= multiplier;
    Ret[2] /= len; Ret[2] *= multiplier;
}

copyVec(Float:Vec[3],Float:Ret[3])
{
    Ret[0] = Vec[0]
    Ret[1] = Vec[1]
    Ret[2] = Vec[2]
}

subVec(Float:Vec1[3],Float:Vec2[3],Float:Ret[3])
{
    Ret[0]=Vec1[0]-Vec2[0]
    Ret[1]=Vec1[1]-Vec2[1]
    Ret[2]=Vec1[2]-Vec2[2]
}

addVec(Float:Vec1[3],Float:Vec2[3])
{
    Vec1[0] += Vec2[0]
    Vec1[1] += Vec2[1]
    Vec1[2] += Vec2[2]
}

make_TE_BEAMPOINTS(id, color, Float:Vec1[3], Float:Vec2[3], width) // Игрок	
{
    message_begin(MSG_ONE_UNRELIABLE ,SVC_TEMPENTITY,{0,0,0},id)
    write_byte(0)
    write_coord(floatround(Vec1[0]))
    write_coord(floatround(Vec1[1]))
    write_coord(floatround(Vec1[2]))
    write_coord(floatround(Vec2[0]))
    write_coord(floatround(Vec2[1]))
    write_coord(floatround(Vec2[2]))
    write_short(laser)
    write_byte(1)
    write_byte(1)
    write_byte(1)
    write_byte(width)
    write_byte(0)
    write_byte(esp_colors[color][0])
    write_byte(esp_colors[color][1])
    write_byte(esp_colors[color][2])
    write_byte(150)
    write_byte(0)
    message_end()
}

make_TE_BEAMENTPOINT(id,Float:target_origin[3],width) // Линия	
{
    message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,{0,0,0},id)
    write_byte(1)
    write_short(id)
    write_coord(floatround(target_origin[0]))
    write_coord(floatround(target_origin[1]))
    write_coord(floatround(target_origin[2]))
    write_short(laser)
    write_byte(1)        
    write_byte(1)
    write_byte(1)
    write_byte(width)
    write_byte(0)
    write_byte(random_num(50,255))
    write_byte(random_num(50,255))
    write_byte(random_num(50,255))
    write_byte(255)
    write_byte(0)
    message_end()
}