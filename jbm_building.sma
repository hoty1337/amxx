#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

new String:serverIPS = "95.181.152.161:27015";
new String:VERSION = "1.5";
new szBlockName[10][10] =
{
		"1223",
		"1224",
		"1225",
		"1226",
		"1227",
		"1228",
		"1229",
		"1230",
		"1231",
		"1232"
}
new g_iBlock[33];
new g_iMaxBlocks;
new bool:g_iDestruction;
new Mdl[34] =
{
	109, 111, 100, 101, 108, 115, 47, 106, 98, 95, 101, 110, 103, 105, 110, 101, 47, 98, 108, 111, 99, 107, 115, 47, 98, 108, 78, 105, 107, 46, 109, 100, 108, 0
};

public __fatal_ham_error(Ham:id, HamError:err, reason[])
{
	new func = get_func_id("HamFilter", -1);
	new bool:fail = 1;
	new var1;
	if (func != -1 && callfunc_begin_i(func, -1) == 1)
	{
		callfunc_push_int(id);
		callfunc_push_int(err);
		callfunc_push_str(reason, "HamFilter");
		if (callfunc_end() == 1)
		{
			fail = false;
		}
	}
	if (fail)
	{
		set_fail_state(reason);
	}
	return 0;
}

public plugin_init()
{
	new sIp[33];
	register_plugin("JBM Building | Remake", VERSION, "NikLaus");
	register_menucmd(register_menuid("Open_Building"), 1023, "Close_Building");
	register_clcmd("minecraft", "Building_Ent", -1, 1360, -1);
	RegisterHam(9, "func_breakable", "Block_TakeDamage", 1);
	RegisterHam(9, "func_breakable", "Block_TakeDamagePre");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");
	return 0;
}

public plugin_precache()
{
	engfunc("HamFilter", "models/jb_engine/blocks/blNik.mdl");
	return 0;
}

public client_disconnect(id)
{
	g_iBlock[id] = 0;
	return 0;
}

public Building_Ent(id)
{
	if (is_user_alive(id))
	{
		new var1;
		if (jbm_is_user_chief(id) || get_user_flags(id) & 1)
		{
			Open_Building(id);
		}
	}
	return 1;
}

public Create_Block(id)
{
	new Float:aOrigin[3] = 0.0;
	new Float:bOrigin[3] = 0.0;
	new Float:cOrigin[3] = 0.0;
	new iGetBody;
	new iGetEntity;
	get_user_aiming(id, iGetEntity, iGetBody, 9999);
	fm_get_aiming_position(id, aOrigin);
	new iEntity = create_entity("func_breakable");
	if (!pev_valid(iEntity))
	{
		return 1;
	}
	set_pev(iEntity, 1, "block");
	engfunc(2, iEntity, Mdl);
	engfunc(5, iEntity, 1992, 2004);
	set_pev(iEntity, 71, g_iBlock[id]);
	set_pev(iEntity, 70, 3);
	set_pev(iEntity, 69, 5);
	set_pev(iEntity, 41, 1065353216);
	set_pev(iEntity, 43, 1073741824);
	if (isBlock(iGetEntity))
	{
		new iAxis;
		pev(iGetEntity, 118, bOrigin);
		new i;
		while (i < 3)
		{
			if (bOrigin[i] > aOrigin[i])
			{
				cOrigin[i] = floatsub(bOrigin[i], aOrigin[i]);
			}
			else
			{
				cOrigin[i] = floatsub(aOrigin[i], bOrigin[i]);
			}
			i++;
		}
		new var1;
		if (cOrigin[2] > 4.2E-44 || cOrigin[2] < 1.4E-45)
		{
			iAxis = 2;
		}
		else
		{
			if (cOrigin[0] > cOrigin[1])
			{
				iAxis = 0;
			}
			iAxis = 1;
		}
		if (aOrigin[iAxis] > bOrigin[iAxis])
		{
			new var2 = bOrigin[iAxis];
			var2 = var2[30];
		}
		else
		{
			bOrigin[iAxis] -= 30;
		}
		set_pev(iEntity, 118, bOrigin);
	}
	else
	{
		set_pev(iEntity, 118, aOrigin);
	}
	return 1;
}

public Delete_Block(id)
{
	new iBody;
	new iEntity;
	static iOrigin[3];
	static Float:Origin[3];
	get_user_origin(id, iOrigin, "");
	IVecFVec(iOrigin, Origin);
	get_user_aiming(id, iEntity, iBody, 9999);
	if (isBlock(iEntity))
	{
		if (0 < g_iMaxBlocks)
		{
			g_iMaxBlocks -= 1;
			remove_entity(iEntity);
		}
		return 1;
	}
	return 1;
}

public Delete_AllBlock(id)
{
	if (0 < g_iMaxBlocks)
	{
		new iEntity = -1;
		new szClassname[6] = {98,108,111,99,107,0};
		while ((iEntity = engfunc(12, iEntity, "classname", szClassname)))
		{
			g_iMaxBlocks = 0;
			remove_entity(iEntity);
		}
	}
	return 0;
}

public Block_TakeDamagePre(iEntity, iInflictor, iAttacker, Float:fDamage, DamageBits)
{
	if (!pev_valid(iEntity))
	{
		return 1;
	}
	new szClassname[32];
	pev(iEntity, 1, szClassname, 31);
	if (equal(szClassname, "block", "HamFilter"))
	{
		new var1;
		if (!is_user_connected(iAttacker) || 1 > iAttacker > 32 || !g_iDestruction)
		{
			return 4;
		}
	}
	return 1;
}

public Block_TakeDamage(iEntity, iInflictor, iAttacker, Float:fDamage, DamageBits)
{
	if (!pev_valid(iEntity))
	{
		return 1;
	}
	new szClassname[32];
	pev(iEntity, 1, szClassname, 31);
	if (equal(szClassname, "block", "HamFilter"))
	{
		new var1;
		if (!is_user_connected(iAttacker) || 1 > iAttacker > 32 || !g_iDestruction)
		{
			return 4;
		}
		if (pev(iEntity, 41) <= 0)
		{
			set_pev(iEntity, 84, pev(iEntity, 84) | 1073741824);
			g_iMaxBlocks -= 1;
		}
	}
	return 1;
}

public LogEvent_RoundEnd()
{
	if (0 < g_iMaxBlocks)
	{
		new iEntity = -1;
		new szClassname[6] = {98,108,111,99,107,0};
		while ((iEntity = engfunc(12, iEntity, "classname", szClassname)))
		{
			g_iMaxBlocks = 0;
			remove_entity(iEntity);
		}
	}
	return 0;
}

Open_Building(id)
{
	new szMenu[512];
	new iKeys = 541;
	new iLen = formatex(szMenu, 511, "\wМеню блоков\nУстановлено блоков: [\r%d\w|\r%d\w]\n\n", g_iMaxBlocks, 180);
	iLen = formatex(szMenu[iLen], 511 - iLen, "\r[1] \wВыбранный блок: \r%s\n", szBlockName[g_iBlock[id]]) + iLen;
	if (g_iMaxBlocks < 180)
	{
		iLen = formatex(szMenu[iLen], 511 - iLen, "\r[2] \wУстановить блок\n\n") + iLen;
		iKeys |= 2;
	}
	else
	{
		iLen = formatex(szMenu[iLen], 511 - iLen, "\r[2] \dУстановлено лимит блоков\n\n") + iLen;
	}
	iLen = formatex(szMenu[iLen], 511 - iLen, "\r[3] \wУдалить блок\n") + iLen;
	iLen = formatex(szMenu[iLen], 511 - iLen, "\r[4] \wУдалить все блоки\n") + iLen;
	new var1;
	if (g_iDestruction)
	{
		var1 = 3556;
	}
	else
	{
		var1 = 3624;
	}
	iLen = formatex(szMenu[iLen], 511 - iLen, "\r[5] \wУрон по блокам: %s\n\n", var1) + iLen;
	formatex(szMenu[iLen], 511 - iLen, "\n\r[0] \wВыйти");
	return show_menu(id, iKeys, szMenu, -1, "Open_Building");
}

public Close_Building(id, iKey)
{
	switch (iKey)
	{
		case 0:
		{
			if (9 > g_iBlock[id])
			{
				g_iBlock[id]++;
			}
			else
			{
				g_iBlock[id] = 0;
			}
		}
		case 1:
		{
			Create_Block(id);
			g_iMaxBlocks += 1;
		}
		case 2:
		{
			Delete_Block(id);
		}
		case 3:
		{
			Delete_AllBlock(id);
		}
		case 4:
		{
			g_iDestruction = !g_iDestruction;
		}
		case 9:
		{
			return 1;
		}
		default:
		{
		}
	}
	return Open_Building(id);
}

bool:isBlock(iEntity)
{
	if (is_valid_ent(iEntity))
	{
		new szClassname[32];
		entity_get_string(iEntity, "HamFilter", szClassname, 32);
		if (equal(szClassname, "block", "HamFilter"))
		{
			return true;
		}
	}
	return false;
}
