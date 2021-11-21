#include <amxmodx>
#include <fakemeta>
#include <engine>

#define PLUGIN 	"Weather"
#define VER 	"0.1"
#define AUTHOR 	"7heHex"

#pragma tabsize 2
#pragma semicolon 1

#define PATH "addons/amxmodx/configs/weather.cfg"

new g_SkyName, START, FINISH, SKYNAME[32], SKYNAME_NIGHT[32], bool:g_bRain, bool:g_bSnow;

public plugin_init()
{
	register_plugin(PLUGIN, VER, AUTHOR);
}

public client_putinserver(id)
{
	if(g_bRain)
	{
		set_task(1.0, "playSoundRain", 1284717 + id);
		set_task(51.0, "playSoundRain", 1284717 + id, _, _, "b");
	}
}

public playSoundRain(idx)
{
	new id = idx - 1284717;
	emit_sound(id, 0, "ambience/rain.wav", 0.5, ATTN_NORM, 0, PITCH_NORM);
}

public client_disconnect(id)
{
	remove_task(1284717 + id);
}

public plugin_precache()
{
	new iStr = file_size(PATH, 1);
	for(new i = 0; i < iStr; i++)
	{
		new szTemp[128], iLen, szSetting[32], szStr[32];
		read_file(PATH, i, szTemp, charsmax(szTemp), iLen);
		if(iLen == 0 || szTemp[0] == ';') continue;
		parse(szTemp, szSetting, charsmax(szSetting), szStr, charsmax(szStr));
		if(equali(szSetting, "WEATHER:"))
		{
			if(equali(szStr, "snow"))
			{
				engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"));
				g_bSnow = true;
			}
			if(equali(szStr, "rain"))
			{
				precache_sound("ambience/rain.wav");
				engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"));
				g_bRain = true;
			}
		}
		if(equali(szSetting, "TIME_START_DAY:"))
		{
			FINISH = str_to_num(szStr);
		}
		if(equali(szSetting, "TIME_START_NIGHT:"))
		{
			START = str_to_num(szStr);
		}
		if(equali(szSetting, "SKY_DAY:"))
		{
			SKYNAME = szStr;
		}
		if(equali(szSetting, "SKY_NIGHT:"))
		{
			SKYNAME_NIGHT = szStr;
		}
	}
	new const SKYNAME_POSTFIXES[][] = {"bk", "dn", "ft", "lf", "rt", "up"};
	new Buffer[96], iHour;
	time(iHour);
	for(new i; i < sizeof SKYNAME_POSTFIXES; i++) {
		formatex(Buffer, charsmax(Buffer), "gfx/env/%s%s.tga", (START <= iHour <= FINISH ? SKYNAME_NIGHT : SKYNAME), SKYNAME_POSTFIXES[i]);
		if(!file_exists(Buffer)) {
			format(Buffer, charsmax(Buffer), "File ^"%s^" not found", Buffer);
			set_fail_state(Buffer);
		}
		precache_generic(Buffer);
	}
	g_SkyName = get_cvar_pointer("sv_skyname");
	if(START <= iHour || iHour <= FINISH)
	{
		set_pcvar_string(g_SkyName, SKYNAME_NIGHT);
		set_lights("g");
	}
	else 
	{
		set_pcvar_string(g_SkyName, SKYNAME);
		set_lights("#OFF");
	}
}