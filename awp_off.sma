#include < amxmodx >
#include < cstrike >
#include < hamsandwich >
#include < engine >
#include < fakemeta_util >

#define FLAG ADMIN_BAN
new	
	CT, 
	T, 
	g_maxplayers,
	cvar[4],
	useawp[33], 
	awpbuy[33],
	messages[][] = {
	"!t[!gХикки Задрот!t]", 
	"У вас!g отобрано!t AWP. Причина:!g низкий онлайн.", 
	"У вас!g отобрано!t AWP. Причина:!g превышен лимит.",
	"Вам были!g возвращены!t деньги за AWP."
	}; // !g - зеленый | !t - цвет тимы[Т - красный | КТ - синий] | !y - жёлтый 

public plugin_init()
{
	register_plugin("AWP", "0.1", "Sky_worker");
	
	register_clcmd("menuselect", "ClCmdMenuSelect");
	register_clcmd("awp", "cmdawp");
	register_clcmd("magnum", "cmdawp");
	register_clcmd("cl_rebuy", "autobuy");
	register_clcmd("cl_autobuy", "autobuy");
	register_clcmd("drop", "ClCmdDrop");
	
	register_event("DeathMsg", "Death", "a");
	register_event("WeapPickup", "wp", "b");
	
	register_logevent("round_restart", 2, "1&Restart_Round_");
	register_logevent("round_end", 2, "1=Round_End");
	
	cvar[0] = register_cvar("awp_players_low", "15");	
	cvar[1] = register_cvar("awp_limit", "1");	
	cvar[2] = register_cvar("awp_limit_max", "2");
	cvar[3] = register_cvar("awp_limit_immun", "1"); 	
	
	g_maxplayers = get_maxplayers();
	
	new mapname[32]; get_mapname(mapname, charsmax(mapname));	
	new maps[][] = { "awp_", "aim_" };
	for(new i; i < sizeof maps; i++)
	{
		if(containi(mapname, maps[i]) != -1)
		{
			pause("ad");
			return;
		}
	}
}

public round_restart()
{
	T = 0;
	CT = 0;
	arrayset(useawp, false, sizeof useawp);
	arrayset(awpbuy, false, sizeof awpbuy);
}

public round_end()	
{
	if(get_playersnum() >= get_pcvar_num(cvar[0]))	return;	
	for(new i = 0; i <= g_maxplayers; i++)	if(is_user_alive(i) && useawp[i])	func_awp(i, 1);
}

public cmdawp(id)	awpbuy[id] = true;
public autobuy(id){	awpbuy[id] = true;	remove_task(id+552);	set_task(1.5, "aOff", id + 552);	}
public aOff(taskid)
{
	new id = taskid - 552;	
	if(!useawp[id])	awpbuy[id] = false;
}

public ClCmdMenuSelect(id)
{
	if(!is_user_alive(id) || get_pdata_int(id, 205) != 6)	return PLUGIN_CONTINUE;

	new sSlot[3]; 
	if(read_argv(1, sSlot, charsmax(sSlot)))	return CheckKeys(id, str_to_num(sSlot));
	
	return PLUGIN_CONTINUE;
}

public func_awp(id, type)
{
	if(!is_user_valid(id) || !is_user_alive(id))	return PLUGIN_CONTINUE;
	
	if(get_playersnum() < get_pcvar_num(cvar[0]))
	{
		ShowMsg(id, "%s %s", messages[0], messages[1]);			
			
		set_task(0.1, "drop", id);
		MONEY(id);
	}
	else if(type != 1 && !useawp[id])
	{	
		useawp[id] = true;
		if(get_pcvar_num(cvar[1]) != 1)	return PLUGIN_CONTINUE;		
		
		if(!is_limit_immun(id))
		{
			switch(get_user_team(id))
			{
				case 1:
				{
					if(T < get_pcvar_num(cvar[2]))	T++;	else	LIMIT(id);
				}
				case 2:
				{
					if(CT < get_pcvar_num(cvar[2]))	CT++;	else	LIMIT(id);
				}
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public drop(id)	fm_strip_user_gun(id, CSW_AWP);


public wp(id)	if(pev(id, pev_weapons) & (1 << CSW_AWP))	func_awp(id, 0);

public ClCmdDrop(pPlayer)
{
	if(is_user_alive(pPlayer) && is_user_valid(pPlayer))
	{
		if(read_argc() == 1)
		{
			new pEntity = get_pdata_cbase(pPlayer, 373);
			
			if(!is_valid_ent(pEntity))	return;
			
			if(cs_get_weapon_id(pEntity) == CSW_AWP)
			{
				awpbuy[pPlayer] = false;
				useawp[pPlayer] = false;
				
				if(!is_limit_immun(pPlayer))
				{
					switch(get_user_team(pPlayer))
					{
						case 1:	T--;
						case 2:	CT--;
					}
				}
			}
		}
	}
}

public client_putinserver(id)
{
	awpbuy[id] = false;
	useawp[id] = false;
}

public client_disconnect(id)	deathawp(id);

public Death()
{
	new id = read_data(2);	
	deathawp(id);
}

bool: is_user_valid(id)
{
	if(is_user_bot(id))	return false;	
	if(is_user_hltv(id))	return false;	
	return true;
}

bool: is_limit_immun(id)	
{
	if(get_pcvar_num(cvar[3]) == 1 && get_user_flags(id) & FLAG) return true;
	return false;
}

stock deathawp(id)
{	
	awpbuy[id] = false;
	if(!useawp[id])		return;	
	
	if(!is_limit_immun(id))
	{
		switch(get_user_team(id))
		{
			case 1:	T--;
			case 2:	CT--;
		}	
	}
	useawp[id] = false;
}

stock CheckKeys(id, iKey)
{
	new team = get_user_team(id);
	if(team == 1 && iKey == 5 || team == 2 && iKey == 6)	awpbuy[id] = true;
	
	return PLUGIN_CONTINUE;
}

stock LIMIT(id)
{
	ShowMsg(id, "%s %s", messages[0], messages[2]);
	MONEY(id);
	set_task(0.1, "drop", id);
	
	return PLUGIN_HANDLED;
}

stock MONEY(id)
{
	if(awpbuy[id])
	{
		cs_set_user_money(id, cs_get_user_money(id) + 4750);
		ShowMsg(id, "%s %s", messages[0], messages[3]);
	}
	awpbuy[id] = false;	useawp[id] = false;
}

stock ShowMsg ( const id, const input [ ], any:... )
{
	new count = 1, players [ 32 ]
	static msg [ 188 ]
	vformat ( msg, 187, input, 3 )
	
	replace_all ( msg, 187, "!g", "^4" )
	replace_all ( msg, 187, "!y", "^1" )
	replace_all ( msg, 187, "!t", "^3" )
	
	if ( id ) players [ 0 ] = id; else get_players ( players, count, "ch" )
	{
		for ( new i = 0; i < count; i++ )
		{
			if ( is_user_connected ( players [ i ] ) )
			{
				message_begin ( MSG_ONE_UNRELIABLE, get_user_msgid ( "SayText" ), _, players [ i ] )
				write_byte ( players [ i ] )
				write_string ( msg )
				message_end ( )
			}
		}
	}
}
//Stock's