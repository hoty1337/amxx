#include <amxmodx>
#include <fakemeta>
#include <saytext>

#define PLUGIN "SkinsSystem"
#define VER "0.1"
#define AUTHOR "7heHex"

#pragma tabsize 2
#pragma semicolon 1

#define PATH "addons/amxmodx/configs/weaponskins.ini"

enum 
{
	WEAPON = 0,
	SPATH
}

new const g_szWeaponName[][] = {"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", 
"weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", 
"weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
"weapon_ak47", "weapon_knife", "weapon_p90"};

new g_szSkins[33][64][64], g_iSkinsCount[33], g_szSkinsName[33][64][64], bool:g_bAllowDrop, g_iMenuPosition[33];

public plugin_init()
{
    register_plugin(PLUGIN, VER, AUTHOR);
	register_cvar("skins_allow_drop", "1");
	g_bAllowDrop = get_pcvar_bool("skins_allow_drop");
	register_menucmd(register_menuid("Show_ChooseSkin"), 1023, "Handle_ChooseSkin");
}

public plugin_precache()
{
	new iStr = file_size(PATH, 1);
	for(new i = 0; i < iStr; i++)
	{
		new szTemp[128], iLen, szAuthId[32], szPathSkin[64];
		read_file(PATH, i, szTemp, charsmax(szTemp), iLen);
		if(iLen == 0 || szTemp[0] == ';') continue;
		parse(szTemp, szAuthId, charsmax(szAuthId), szPathSkin, charsmax(szPathSkin));
        engfunc(EngFunc_PrecacheModel, szPathSkin);
	}
}

public client_putinserver(id)
{
	g_iSkinsCount[id] = 0;
	new iStr = file_size(PATH, 1), szAuthIdT[32];
	get_user_authid(id, szAuthIdT, charsmax(szAuthIdT));
	for(new i = 0; i < iStr; i++)
	{
		new szTemp[128], iLen, szAuthId[32], szPathSkin[64], szSkinName[64];
		read_file(PATH, i, szTemp, charsmax(szTemp), iLen);
		if(iLen == 0 || szTemp[0] == ';') continue;
		parse(szTemp, szAuthId, charsmax(szAuthId), szPathSkin, charsmax(szPathSkin), szSkinName, charsmax(szSkinName));
		if(equal(szAuthIdT, szAuthId))
		{
			g_szSkinsName[id][g_iSkinsCount[id]] = szSkinName;
			g_szSkins[id][g_iSkinsCount[id]++] = szPathSkin;
		}
	}
}
public Cmd_ChooseSkin(id) return Show_ChooseSkin(id, g_iMenuPosition[id] = 0);
public Show_ChooseSkin(id, iPos)
{
	if(iPos < 0) return PLUGIN_HANDLED;
	if(!g_iSkinsCount[id])
	{
		UTIL_SayText(id, "!g[Хикки Задрот] !yУ вас нет скинов.");
		return PLUGIN_HANDLED;
	}
	new iStart, iEnd;
	iStart = iPos * 8;
	iEnd = (iStart + 8 < g_iSkinsCount[id] ? iStart + 8 : g_iSkinsCount[id]);
	new szMenu[512], iKeys = (1<<9), iLen = formatex(szMenu, charsmax(szMenu), "Выбор оружия со скином:^n^n");
	for(new i = iStart; i < iEnd; i++)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[%d] \w%s^n",i+1, g_szSkinsName[id][i]);
		iKeys |= (1<<i);
	}
	if(iEnd < g_iSkinsCount[id])
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[9] \wДалее^n");
		iKeys |= (1<<8);
	}
	else iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n");
	iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[0] \w%s^n", iPos > 0 ? "Назад" : "Выход");

	return show_menu(id, iKeys, szMenu, -1, "Show_ChooseSkin");
}

public Handle_ChooseSkin(id, iKey)
{
	switch(iKey)
	{
		case 8: return Show_ChooseSkin(id, ++g_iMenuPosition[id]);
		case 9: return Show_ChooseSkin(id, --g_iMenuPosition[id]);
		default:
		{
			new iNum = g_iMenuPosition[id] * 8 + iKey;
			for(new i = 3; i < sizeof g_szWeaponName; i++)
			{
				new szWeaponName[16], temp[10];
				split(g_szWeaponName[i], temp, 10, szWeaponName, 16, "_");
				if(containi(g_szSkins[id][iNum], "ak47")) 
				{
					fm_give_item(id, "weapon_ak47")
					fm_set_user_bpammo(id, CSW_AK47, 90);
				}
				else if(containi(g_szSkins[id][iNum], "m4a1"))
				{
					fm_give_item(id, "weapon_m4a1");
					fm_set_user_bpammo(id, CSW_M4A1, 90);
				}
				else if(containi(g_szSkins[id][iNum], "deagle"))
				{
					fm_give_item(id, "weapon_deagle");
					fm_set_user_bpammo(id, CSW_DEAGLE, 35);
				}
				else if(containi(g_szSkins[id][iNum], "awp"))
				{
					fm_give_item(id, "weapon_awp");
					fm_set_user_bpammo(id, CSW_AWP, 30);
				}
				else if(containi(g_szSkins[id][iNum], "famas"))
				{
					fm_give_item(id, "weapon_famas");
					fm_set_user_bpammo(id, CSW_FAMAS, 90);
				}
			}
		}
	}
}

public client_disconnect(id)
{
	for(new i = 0; i < g_iSkinsCount[id]; i++)
	{
		g_szSkinsName[id][i] = NULL_STRING;
		g_szSkins[id][i] = NULL_STRING;
	}
	g_iSkinsCount[id] = 0;
}

stock fm_give_item(pPlayer, const szItem[])
{
	if(!is_user_alive(pPlayer))
		return 0;
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, szItem));
	if(!pev_valid(iEntity)) return 0;
	new Float:vecOrigin[3];
	pev(pPlayer, pev_origin, vecOrigin);
	set_pev(iEntity, pev_origin, vecOrigin);
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, iEntity);
	dllfunc(DLLFunc_Touch, iEntity, pPlayer);
	if(pev(iEntity, pev_solid) != SOLID_NOT)
	{
		engfunc(EngFunc_RemoveEntity, iEntity);
		return -1;
	}
	return iEntity;
}

stock fm_set_user_bpammo(pPlayer, iWeaponId, iAmount)
{
	if(!is_user_alive(pPlayer))
		return 0;
	
	new iOffset;
	switch(iWeaponId)
	{
		case CSW_AWP: iOffset = 377; // ammo_338magnum
		case CSW_SCOUT, CSW_AK47, CSW_G3SG1: iOffset = 378; // ammo_762nato
		case CSW_M249: iOffset = 379; // ammo_556natobox
		case CSW_FAMAS, CSW_M4A1, CSW_AUG, CSW_SG550, CSW_GALI, CSW_SG552: iOffset = 380; // ammo_556nato
		case CSW_M3, CSW_XM1014: iOffset = 381; // ammo_buckshot
		case CSW_USP, CSW_UMP45, CSW_MAC10: iOffset = 382; // ammo_45acp
		case CSW_FIVESEVEN, CSW_P90: iOffset = 383; // ammo_57mm
		case CSW_DEAGLE: iOffset = 384; // ammo_50ae
		case CSW_P228: iOffset = 385; // ammo_357sig
		case CSW_GLOCK18, CSW_MP5NAVY, CSW_TMP, CSW_ELITE: iOffset = 386; // ammo_9mm
		case CSW_FLASHBANG: iOffset = 387;
		case CSW_HEGRENADE: iOffset = 388;
		case CSW_SMOKEGRENADE: iOffset = 389;
		case CSW_C4: iOffset = 390;
		default: return 0;
	}
	set_pdata_int(pPlayer, iOffset, iAmount, linux_diff_player);
	return 1;
}