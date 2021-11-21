#include <amxmodx>

new const START = 20;
new const FINISH = 12;

new const FLAGS = ADMIN_LEVEL_H;

new g_DefaultFlag;

public plugin_init() {
	register_plugin("Night VIP", "0.1", "F@nt0M");
}

public plugin_cfg() {
	new cvar = get_cvar_pointer("amx_default_access");
	if (cvar) {
		new flags[32];
		get_pcvar_string(cvar, flags, charsmax(flags));
		g_DefaultFlag = read_flags(flags);
	}
}

public client_putinserver(id) {
	if (checkTime() && (get_user_flags(id) & FLAGS) != FLAGS) {
		if (g_DefaultFlag) {
			remove_user_flags(id, g_DefaultFlag);
			set_user_flags(id, FLAGS);
		}
	}
}

bool:checkTime() {
	new hour;
	time(hour);

	return (START <= hour || hour <= FINISH) ? true : false;
}