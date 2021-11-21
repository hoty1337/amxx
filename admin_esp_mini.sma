#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN 			"Admin ESP"
#define VERSION 		"0.2"
#define AUTHOR 			"Kost & miRror"

#define OFFSET_TEAM		114

new bool:alive[33],
	bool:fperson[33],
	bool:admin_options[33]
	
new team_colors[3][3] = {{255,0,0},{255,0,0},{255,0,0}}
new esp_colors[3][3] = {{0,255,0},{100,60,60},{60,60,100}}

new laser

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say /esp", "esp_toggle")

	register_event("TextMsg", "spec_mode", "b", "2&#Spec_Mode")

	RegisterHam(Ham_Spawn, "player", "fw_Spawn", 1)
	RegisterHam(Ham_Killed, "player", "fw_Killed", 1)
	
	set_task(0.1, "esp_timer", .flags = "b")
}

public plugin_precache()
{
    laser = precache_model("sprites/laserbeam.spr")
}

public client_putinserver(id)
{
	fperson[id] 	  = false
	alive[id] 		  = false
	admin_options[id] = true;
}

public client_disconnect(id)
{
	alive[id] 		  = false
}

public fw_Killed(victim)
{
	alive[victim] = false
}

public fw_Spawn(id)
{    
	if(is_user_alive(id))
		alive[id] = true
}

public esp_toggle(id)
{
    if (get_user_flags(id) & ADMIN_MENU)
	{
		admin_options[id] = !admin_options[id]
		
		client_print(id, print_chat, "[Админ ЕСП] %s", admin_options[id] ? "Включен" : "Выключен")		
	} else 
		client_print(id, print_chat, "[Админ ЕСП] Вы не имеете доступа к данной команде")		
}

public spec_mode(id)
{
	new specMode[12]

	read_data(2, specMode, charsmax(specMode))

	fperson[id]= bool:equal(specMode,"#Spec_Mode4");
}

public esp_timer()
{
	static  Float:my_origin[3],  
			Float:target_origin[3], 
			Float:distance,// width, 
			Float:v_middle[3],
			Float:v_hitpoint[3], 
			Float:distance_to_hitpoint, 
			Float:scaled_bone_len, 
			Float:v_bone_start[3],
			Float:v_bone_end[3],
			players[32], playersi[32],
			my_team, target_team, spec_id, num, s, numi, i

	get_players(playersi, numi, "bch")

	for(--numi; numi>=0; numi--)
    {
		i = playersi[numi]
		
		spec_id = pev(i, pev_iuser2)
		
		if (!(get_user_flags(i) & ADMIN_MENU) || !fperson[i] /*|| get_user_team(i) != 3*/ || !spec_id || !alive[spec_id])
			continue
		
		pev(i, pev_origin, my_origin)
		my_team = get_pdata_int(spec_id, OFFSET_TEAM)	
		
		target_team = my_team == 2 ? 1 : 2
		
		get_players(players, num, "ache", target_team==2 ? "CT" : "TERRORIST")
		
		for(--num; num>=0; num--)
		{
			s = players[num]

			pev(s, pev_origin, target_origin);
			distance = vector_distance(my_origin, target_origin);

			subVec(target_origin, my_origin, v_middle)

			engfunc(EngFunc_TraceLine, my_origin, target_origin, 1, -1, 0)
			get_tr2(0, TR_vecEndPos, v_hitpoint)
			
			distance_to_hitpoint = vector_distance(my_origin, v_hitpoint);
			if(distance_to_hitpoint == distance)
			{
				//Линия
				//width = distance < 2040.0 ? ((255 - floatround(distance / 8.0)) / 4) : 1
				//make_TE_BEAMENTPOINT(i, target_origin, width, target_team);
			}
			else
			{
				normalize(v_middle, v_bone_start, distance_to_hitpoint - 10.0);
				addVec(v_bone_start, my_origin); 	// Начальная точка
				v_bone_start[2] += 17.5; 			// Поправка взгляда
				copyVec(v_bone_start, v_bone_end);
				scaled_bone_len = distance_to_hitpoint / distance * 50.0;
				v_bone_end[2] -= scaled_bone_len; // Конечная точка

				//width = 1
				
				//Линия с боксом
				//if(distance < 2040.0)
					//width = (255 - floatround(distance / 8.0)) / 4
				
				//make_TE_BEAMENTPOINT(i, v_bone_end, width, target_team)
				make_TE_BEAMPOINTS(i, target_team, v_bone_start, v_bone_end, floatround(scaled_bone_len))
			}
		}
    } 
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
    write_byte(width*30)
    write_byte(0)
    write_byte(team_colors[color][0])
    write_byte(team_colors[color][1])
    write_byte(team_colors[color][2])
    write_byte(150)
    write_byte(0)
    message_end()
}

/*make_TE_BEAMENTPOINT(id,Float:target_origin[3],width,target_team) // Линия	
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
    write_byte(team_colors[target_team][0])
    write_byte(team_colors[target_team][1])
    write_byte(team_colors[target_team][2])
    write_byte(255)
    write_byte(0)
    message_end()
}*/