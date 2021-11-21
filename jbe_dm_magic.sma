#include <amxmodx>
#include <xs>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
//#include <jbe_core> 
                     
#define PLUGIN    "MAGIC DAY"
#define VERSION    "2.0"
#define AUTHOR     "Smoo[Ok]e"

#define MsgId_ScreenFade 98
#define TASK_TIME_HIDE 785689

#define DAMAGE     60.0
#define DAMAGE_MULTI 2.0

native jbm_get_user_team(pPlayer);
native jbm_register_day_mode(szLang[32], iBlock, iTime);
native jbm_get_user_money(pPlayer);
native jbm_set_user_model(pPlayer, const szModel[]);
native jbm_set_user_money(pPlayer, iNum, iFlash);
native jbm_set_user_rendering(pPlayer, iRenderFx, iRed, iGreen, iBlue, iRenderMode, iRenderAmt);

enum _:CVARS { PRISONER_HEALTH, GUARD_HEALTH, DEMENTOR_HEALTH_2_PLAYERS, DEMENTOR_HEALTH_10_PLAYERS, DEMENTOR_HEALTH_18_PLAYERS, HITSD, KILLER_MONEY, TIME_HIDE }
new g_iAllCvars[CVARS];

new const snd_hit[][]     =     { "jb_engine/days_mode/magic/knife_hit1.wav" }
new const snd_fire[][]    =     { "jb_engine/days_mode/magic/chill.wav" }

new Float:g_flLastFireTime[33], g_HasRifle[33], g_iSyncTimeHide, g_iTimeHideCount, g_iMaxPlayers, g_sprBeam, g_sprExp, g_sprBlood, 
sprite_ability, g_iDayModeGG, HamHook:g_iHamHookForwards[14], /*g_pSpriteWave,*/ g_iMainDementor;
new const g_szHamHookEntityBlock[][] =
{
    "func_vehicle", // Управляемая машина
    "func_tracktrain", // Управляемый поезд
    "func_tank", // Управляемая пушка
    "game_player_hurt", // При активации наносит игроку повреждения
    "func_recharge", // Увеличение запаса бронижелета
    "func_healthcharger", // Увеличение процентов здоровья
    "game_player_equip", // Выдаёт оружие
    "player_weaponstrip", // Забирает всё оружие
    "trigger_hurt", // Наносит игроку повреждения
    "trigger_gravity", // Устанавливает игроку силу гравитации
    "armoury_entity", // Объект лежащий на карте, оружия, броня или гранаты
    "weaponbox", // Оружие выброшенное игроком/
    "weapon_shield" // Щит
};

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    new i;
    for(i = 0; i <= 7; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Use, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
    for(i = 8; i <= 12; i++) DisableHamForward(g_iHamHookForwards[i] = RegisterHam(Ham_Touch, g_szHamHookEntityBlock[i], "HamHook_EntityBlock", 0));
    DisableHamForward(g_iHamHookForwards[13] = RegisterHam(Ham_Killed, "player", "HamHook_Killed_Player_Post", 1));
    register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
    register_event("CurWeapon", "event_CurWeapon", "b", "1=1")
    register_forward(FM_CmdStart, "fw_CmdStart")
    register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
    RegisterHam(Ham_Item_Deploy, "weapon_knife", "fw_Deploy_Post", 1)
    RegisterHam(Ham_Item_AddToPlayer, "weapon_knife", "fw_AddToPlayer")
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "SecondaryAttack_Pre", 0)
    g_iDayModeGG = jbm_register_day_mode("JBE_DAY_MODE_MAGIC", 0, 200);
    g_iSyncTimeHide = CreateHudSyncObj();
    g_iMaxPlayers = get_maxplayers();
    
    register_cvar("jbe_prisoner_health_magic", "100");
    register_cvar("jbe_guard_health_magic", "350");
    register_cvar("jbe_guard_hide_time_magic", "15");
    
    register_cvar("jbe_dementor_health_2", "400");
    register_cvar("jbe_dementor_health_10", "700");
    register_cvar("jbe_dementor_health_18", "1100");
    register_cvar("jbe_dementor_kill_money", "60");
    
    register_cvar("jbe_next_attack_magic", "");
}

public plugin_precache()
{
    static i
    new szBuffer[64];
    new const szMagic[][] = {"p_magic", "v_magic"};
    for(i = 0; i < sizeof(szMagic); i++)
    {                                    
        formatex(szBuffer, charsmax(szBuffer), "models/jb_engine/days_mode/magic/%s.mdl", szMagic[i]);
        engfunc(EngFunc_PrecacheModel, szBuffer);
    }                                 
    g_sprBlood = precache_model("models/jb_engine/days_mode/magic/blood.spr")
    g_sprBeam = precache_model("models/jb_engine/days_mode/magic/lgtning.spr")
    g_sprExp = precache_model("models/jb_engine/days_mode/magic/deimosexp.spr")
    sprite_ability = precache_model("models/jb_engine/days_mode/magic/green.spr")
    //g_pSpriteWave = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr");
    
    for(i = 0; i < sizeof snd_fire; i++)
        precache_sound(snd_fire[i])                

    for(i = 0; i < sizeof snd_hit; i++)                                       
        precache_sound(snd_hit[i])              
                                        
    //engfunc(EngFunc_PrecacheModel, "models/player/jbe_classes15/jbe_classes15.mdl");    
    engfunc(EngFunc_PrecacheModel, "models/player/dementrisa/dementrisa.mdl");    
}
                                                 
public plugin_cfg()
{
    new szCfgDir[64];
    get_localinfo("amxx_configsdir", szCfgDir, charsmax(szCfgDir));
    set_task(0.1, "jbe_cvars");
}

public jbe_cvars()
{
    g_iAllCvars[PRISONER_HEALTH] = get_cvar_num("jbe_prisoner_health_magic");
    g_iAllCvars[GUARD_HEALTH] = get_cvar_num("jbe_guard_health_magic");
    g_iAllCvars[DEMENTOR_HEALTH_2_PLAYERS] = get_cvar_num("jbe_dementor_health_2");
    g_iAllCvars[DEMENTOR_HEALTH_10_PLAYERS] = get_cvar_num("jbe_dementor_health_10");
    g_iAllCvars[DEMENTOR_HEALTH_18_PLAYERS] = get_cvar_num("jbe_dementor_health_18");
    g_iAllCvars[KILLER_MONEY] = get_cvar_num("jbe_dementor_kill_money");
    g_iAllCvars[HITSD] = get_cvar_num("jbe_next_attack_magic");
    g_iAllCvars[TIME_HIDE] = get_cvar_num("jbe_guard_hide_time_magic");
}

public HamHook_EntityBlock() return HAM_SUPERCEDE;
public HamHook_Killed_Player_Post(iVictim, iKiller)
{
    if(g_iMainDementor == iVictim && is_user_connected(iKiller) && jbm_get_user_team(iKiller) == 1)
    {
        g_iMainDementor = 0;
        jbm_set_user_rendering(iVictim, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
        //jbm_day_mode_ended(g_iDayModeGG, 1);
        
        new g_iUserMoney = jbm_get_user_money(iKiller), szKiller[32]; get_user_name(iKiller, szKiller, charsmax(szKiller));
        jbm_set_user_money(iKiller, g_iUserMoney + g_iAllCvars[KILLER_MONEY], 1);
        ChatColor(0, "!g[Magic] !yВолшебник !t%s !yубил !gглавного дементора!y. И получил !t$%d", szKiller, g_iAllCvars[KILLER_MONEY]);
    }
    g_HasRifle[iVictim] = false
}

public jbm_day_mode_start(iDayMode, iAdmin)
{
    if(iDayMode == g_iDayModeGG)
    {
		client_cmd(0, "mp3 play sound/jb_engine/days_mode/magic/harry-potter2.mp3");
        new i;
        for(i = 0; i <= get_maxplayers(); i++)
        {
            if(!is_user_alive(i)) continue;
            if(jbm_get_user_team(i) == 1)
            {
                //jbe_set_user_model(i, "jbe_magic_tt2");
                fm_strip_user_weapons(i); 
                set_pdata_int(i, 116, 0);  
                set_pev(i, pev_maxspeed, 240.0);
                set_pev(i, pev_health, float(g_iAllCvars[PRISONER_HEALTH]));
                fm_give_item(i, "weapon_knife");
                client_cmd(i, "impulse 100");
                set_pev(i, pev_flags, pev(i, pev_flags) | FL_FROZEN);
                UTIL_ScreenFade(i, 0, 0, 4, 0, 0, 0, 255, 1);        
            } 
            else if(jbm_get_user_team(i) == 2)
            {
                //jbe_set_user_model(i, "jbe_classes15");
                //set_pev(i, pev_body, 5);
                fm_strip_user_weapons(i);
                set_pev(i, pev_health, float(g_iAllCvars[GUARD_HEALTH]));
                set_pev(i, pev_maxspeed, 280.0);
                set_pev(i, pev_gravity, 0.6);
                jbm_give_dementor();
            }
        }
        for(i = 0; i < sizeof(g_iHamHookForwards); i++) EnableHamForward(g_iHamHookForwards[i]);
        g_iTimeHideCount = g_iAllCvars[TIME_HIDE]; jbe_time_hide(); set_lights("c");
        set_task(1.0, "jbe_time_hide", TASK_TIME_HIDE, _, _, "a", g_iTimeHideCount);
    }
}

public jbm_give_dementor()
{
    if(g_iMainDementor == 0)
    {
        new Players[32], num;
        get_players(Players, num, "aeh", "CT");
        if(num)
        {
            new id = Players[random(num)];
            if(is_user_alive(id))
            {
                g_iMainDementor = id;
                jbm_set_user_model(id, "dementrisa");
                if(2 <= AlivePlayerTeam(1) < 10) set_pev(id, pev_health, float(g_iAllCvars[DEMENTOR_HEALTH_2_PLAYERS]));
                else if(10 <= AlivePlayerTeam(1) < 18) set_pev(id, pev_health, float(g_iAllCvars[DEMENTOR_HEALTH_10_PLAYERS]));
                else if(AlivePlayerTeam(1) >= 18) set_pev(id, pev_health, float(g_iAllCvars[DEMENTOR_HEALTH_10_PLAYERS]));
                //jbm_set_user_rendering(id, kRenderFxGlowShell, 54, 54, 54, kRenderNormal, 0); 
                ChatColor(0, "!g[Magic] !yИгрок !t%n !yбыл выбран !gглавным дементором!y.", id);
            }
        }
    }

}

public jbe_time_hide()
{
    if(--g_iTimeHideCount)
    {
        set_hudmessage(255, 255, 255, -1.0, 0.16, 0, 0.0, 0.9, 0.1, 0.1, -1);
        ShowSyncHudMsg(0, g_iSyncTimeHide, "У охраны осталось [%d] секунд.", g_iTimeHideCount);
    }
    else
    {
        for(new i = 1; i <= g_iMaxPlayers; i++)
        {
            if(!is_user_alive(i)) continue;
            if(jbm_get_user_team(i) == 1)
            {
                UTIL_ScreenFade(i, 0, 0, 0, 0, 0, 0, 0, 1);
                set_pev(i, pev_flags, pev(i, pev_flags) & ~FL_FROZEN);
            }
            give_rifle(i);
        }
    }
}

public jbm_day_mode_ended(iDayMode, iWinTeam)
{
    if(iDayMode == g_iDayModeGG)
    {
		client_cmd(0, "mp3 stop");
        new i;
        if(task_exists(TASK_TIME_HIDE)) remove_task(TASK_TIME_HIDE);
        set_lights("#OFF");
        for(i = 0; i < sizeof(g_iHamHookForwards); i++) DisableHamForward(g_iHamHookForwards[i]);
        for(i = 1; i <= get_maxplayers(); i++)
        {
            if(is_user_alive(i))
            {
                switch(jbm_get_user_team(i))
                {
                    case 1:
                    {
                        if(iWinTeam) fm_strip_user_weapons(i, 1);
                        else ExecuteHamB(Ham_Killed, i, i, 0);
                    }
                    case 2: fm_strip_user_weapons(i, 1);
                }
                jbm_set_user_rendering(i, kRenderFxNone, 0, 0, 0, kRenderNormal, 0);
                g_iMainDementor = 0;
            }
        }
    }
}

public event_CurWeapon(id)
{
    if(!is_user_alive(id)) return
    if(!g_HasRifle[id] || get_user_weapon(id) != CSW_KNIFE) return    
    set_pev(id, pev_viewmodel2, "models/jb_engine/days_mode/magic/v_magic.mdl")
    set_pev(id, pev_weaponmodel2, "models/jb_engine/days_mode/magic/p_magic.mdl")
}

public Event_NewRound()
{
    for (new i = 1; i <= get_maxplayers(); i++)
    {
        if(!is_user_connected(i)) continue
        g_HasRifle[i] = false
    }
}

public SecondaryAttack_Pre(Weapon)
{
    new Player = get_pdata_cbase(Weapon, 41, 4)
    if(!is_user_alive(Player)) return HAM_IGNORED
    if(g_HasRifle[Player]) return HAM_SUPERCEDE
    return HAM_HANDLED;
}

public give_rifle(id)
{
    if(!is_user_alive(id)) return
    g_HasRifle[id] = true
    fm_give_item(id, "weapon_knife")    
    engclient_cmd(id, "weapon_knife")
    if(get_user_weapon(id) == CSW_KNIFE)
    {
        set_pev(id, pev_viewmodel2,  "models/jb_engine/days_mode/magic/v_magic.mdl")
        set_pev(id, pev_weaponmodel2, "models/jb_engine/days_mode/magic/p_magic.mdl")
        set_wpnanim(id, 3)
    }
}

public fw_CmdStart(id, handle, seed)
{
    if(!is_user_alive(id)) return FMRES_IGNORED
    if(!g_HasRifle[id]) return FMRES_IGNORED        
    if(get_user_weapon(id) != CSW_KNIFE) return FMRES_IGNORED    
    static iButton
    iButton = get_uc(handle, UC_Buttons)
    if(iButton & IN_ATTACK)
    {
        set_uc(handle, UC_Buttons, iButton & ~IN_ATTACK)
        static Float:flCurTime
        flCurTime = halflife_time()
        if(flCurTime - g_flLastFireTime[id] < 1.8) return FMRES_IGNORED    
        static iWpnID
        iWpnID = get_pdata_cbase(id, 373, 5)
        if(iWpnID != -1)
        {
            set_pdata_float(iWpnID, 46, 1.8, 4);
            set_pdata_float(iWpnID, 47, 1.8, 4);
            set_pdata_float(iWpnID, 48, 1.8, 4);
        }
        g_flLastFireTime[id] = flCurTime
        primary_attack(id)
        make_punch(id, 50)
        return FMRES_IGNORED
    }
    return FMRES_IGNORED
}

public fw_UpdateClientData_Post(id, sendweapons, handle)
{
    if(!is_user_alive(id)) return FMRES_IGNORED    
    if(!g_HasRifle[id]) return FMRES_IGNORED    
    if(get_user_weapon(id) != CSW_KNIFE) return FMRES_IGNORED    
    set_cd(handle, CD_flNextAttack, halflife_time() + 0.001)
    return FMRES_HANDLED
}

public fw_Deploy_Post(wpn)
{
    static id
    id = fm_cs_get_weapon_ent_owner(wpn)
    if(is_user_connected(id) && g_HasRifle[id])
    {
        set_pev(id, pev_viewmodel2,  "models/jb_engine/days_mode/magic/v_magic.mdl")
        set_pev(id, pev_weaponmodel2, "models/jb_engine/days_mode/magic/p_magic.mdl")
        set_wpnanim(id, 3)
    }
    return HAM_IGNORED
}

public fw_AddToPlayer(wpn, id)
{
    if(!is_valid_ent(wpn) || is_user_connected(id) || entity_get_int(wpn, EV_INT_impulse) != 2816) return HAM_IGNORED
    g_HasRifle[id] = true
    entity_set_int(wpn, EV_INT_impulse, 0)
    return HAM_IGNORED
}

public primary_attack(id)
{
    set_wpnanim(id, 5)
    entity_set_vector(id, EV_VEC_punchangle, Float:{ -1.5, 0.0, 0.0 })
    emit_sound(id, CHAN_WEAPON, snd_fire[random_num(0, sizeof snd_fire - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    static iTarget, iBody, iEndOrigin[3]
    get_user_origin(id, iEndOrigin, 3)
    fire_effects(id, iEndOrigin)
    get_user_aiming(id, iTarget, iBody)
    new iEnt = create_entity("info_target")
    static Float:flOrigin[3]
    IVecFVec(iEndOrigin, flOrigin)
    entity_set_origin(iEnt, flOrigin)
    remove_entity(iEnt)
    if(is_user_alive(iTarget) && (jbm_get_user_team(iTarget) != jbm_get_user_team(id)))
    {
        if(0.4 > 0.0)
        {
            static Float:flVelocity[3]
            get_user_velocity(iTarget, flVelocity)
            xs_vec_mul_scalar(flVelocity, 0.4, flVelocity)
            set_user_velocity(iTarget, flVelocity)    
            new iHp = pev(iTarget, pev_health)
            new Float:iDamage, iBloodScale
            if(iBody == HIT_HEAD)
            {
                iDamage = DAMAGE*DAMAGE_MULTI
                iBloodScale = 25
            }
            else
            {
                iDamage = DAMAGE
                iBloodScale = 10
            }
            if(iHp > iDamage) 
            {
                make_blood(iTarget, iBloodScale)
                set_pev(iTarget, pev_health, iHp-iDamage)
                damage_effects(iTarget)
            }
            else if(iHp <= iDamage)
            {
                balls_effects(iTarget)
                ExecuteHamB(Ham_Killed, iTarget, id, 2)
            }
        }
    }
    else emit_sound(id, CHAN_WEAPON, snd_hit[random_num(0, sizeof snd_hit - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public client_putinserver(id) g_HasRifle[id] = false
public client_disconnected(id)
{
    if(g_iMainDementor == id) g_iMainDementor = 0;
    g_HasRifle[id] = false
}

stock fire_effects(id, iEndOrigin[3])
{
    UTIL_PlayWeaponAnimation(id, 5)
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte (TE_BEAMENTPOINT)
    write_short(id | 0x1000)
    write_coord(iEndOrigin[0])      // Конец луча: x
    write_coord(iEndOrigin[1])      // Конец луча: y
    write_coord(iEndOrigin[2])      // Конец луча: z
    write_short(g_sprBeam)
    write_byte(0)
    write_byte(1)
    write_byte(1)
    write_byte(20)
    write_byte(7)
    switch(random(5))
    {
        case 0:
        {
            write_byte(255);
            write_byte(0);
            write_byte(0);
        }
         
        case 1:
        {
            write_byte(0);
            write_byte(255);
            write_byte(0)
        }
         
        case 2:
        {
            write_byte(0);
            write_byte(0);  
            write_byte(255);
        }
        case 3:
        {
            write_byte(255);
            write_byte(0);  
            write_byte(255);
        }
        case 4:
        {
            write_byte(0);
            write_byte(255);  
            write_byte(255);
        }
        case 5:
        {
            write_byte(255);
            write_byte(255);  
            write_byte(0);
        }
    }
    write_byte(1000)
    write_byte(0)
    message_end()
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(3)
    write_coord(iEndOrigin[0])
    write_coord(iEndOrigin[1])
    write_coord(iEndOrigin[2])
    write_short(g_sprExp)
    write_byte(10)
    write_byte(15)
    write_byte(4)
    message_end()
}

stock balls_effects(index)
{
    static Float:flOrigin[3]
    pev(index, pev_origin, flOrigin)
            
    message_begin (MSG_BROADCAST,SVC_TEMPENTITY)
    write_byte( TE_SPRITETRAIL ) // Throws a shower of sprites or models
    engfunc(EngFunc_WriteCoord, flOrigin[ 0 ]) // start pos
    engfunc(EngFunc_WriteCoord, flOrigin[ 1 ])
    engfunc(EngFunc_WriteCoord, flOrigin[ 2 ] + 200.0)
    engfunc(EngFunc_WriteCoord, flOrigin[ 0 ]) // velocity
    engfunc(EngFunc_WriteCoord, flOrigin[ 1 ])
    engfunc(EngFunc_WriteCoord, flOrigin[ 2 ] + 20.0)
    write_short(sprite_ability) // spr
    write_byte(15) // (count)
    write_byte(random_num(27,30)) // (life in 0.1's)
    write_byte(2) // byte (scale in 0.1's)
    write_byte(random_num(30,70)) // (velocity along vector in 10's)
    write_byte(40) // (randomness of velocity in 10's)
    message_end()
}

stock damage_effects(id)
{
    message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Damage"), _, id)
    write_byte(0)
    write_byte(0)
    write_long(DMG_NERVEGAS)
    write_coord(0) 
    write_coord(0)
    write_coord(0)
    message_end()
    
    message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
    write_short(1<<13)
    write_short(1<<14)
    write_short(0x0000)
    write_byte(255)
    write_byte(0)
    write_byte(255)
    write_byte(100) 
    message_end()
        
    message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, id)
    write_short(0xFFFF)
    write_short(1<<13)
    write_short(0xFFFF) 
    message_end()

    static Float:flOrigin[3]
    pev(id, pev_origin, flOrigin)

    message_begin (MSG_BROADCAST,SVC_TEMPENTITY)
    write_byte( TE_SPRITETRAIL ) // Throws a shower of sprites or models
    engfunc(EngFunc_WriteCoord, flOrigin[ 0 ]) // start pos
    engfunc(EngFunc_WriteCoord, flOrigin[ 1 ])
    engfunc(EngFunc_WriteCoord, flOrigin[ 2 ] + 200.0)
    engfunc(EngFunc_WriteCoord, flOrigin[ 0 ]) // velocity
    engfunc(EngFunc_WriteCoord, flOrigin[ 1 ])
    engfunc(EngFunc_WriteCoord, flOrigin[ 2 ] + 20.0)
    write_short(sprite_ability) // spr
    write_byte(15) // (count)
    write_byte(random_num(27,30)) // (life in 0.1's)
    write_byte(2) // byte (scale in 0.1's)
    write_byte(random_num(30,70)) // (velocity along vector in 10's)
    write_byte(40) // (randomness of velocity in 10's)
    message_end()
}

stock make_blood(id, scale)
{
    new Float:iVictimOrigin[3]
    pev(id, pev_origin, iVictimOrigin)
    
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
    write_byte(115)
    write_coord(floatround(iVictimOrigin[0]+random_num(-20,20))) 
    write_coord(floatround(iVictimOrigin[1]+random_num(-20,20))) 
    write_coord(floatround(iVictimOrigin[2]+random_num(-20,20))) 
    write_short(g_sprBlood)
    write_short(g_sprBlood) 
    write_byte(248) 
    write_byte(scale) 
    message_end()
}

stock set_wpnanim(id, anim)
{
    entity_set_int(id, EV_INT_weaponanim, anim)
    message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
    write_byte(anim)
    write_byte(entity_get_int(id, EV_INT_body))
    message_end()
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
    set_pev(Player, pev_weaponanim, Sequence)
    
    message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
    write_byte(Sequence)
    write_byte(0)
    message_end()
}

stock AlivePlayerTeam(const iTeam = 1)
{
    new iCount = 0;  
    for(new i = 1; i <= 32; i++) if(is_user_alive(i) && jbm_get_user_team(i) == iTeam) iCount++;                 
    return iCount;
}

stock make_punch(id, velamount) 
{
    static Float:flNewVelocity[3], Float:flCurrentVelocity[3]
    velocity_by_aim(id, -velamount, flNewVelocity)
    get_user_velocity(id, flCurrentVelocity)
    xs_vec_add(flNewVelocity, flCurrentVelocity, flNewVelocity)
    set_user_velocity(id, flNewVelocity)    
}

stock fm_give_item(index, const item[])
{
    if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
        return 0
    new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
    if (!pev_valid(ent))
        return 0
    new Float:origin[3];
    pev(index, pev_origin, origin)
    set_pev(ent, pev_origin, origin)
    set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
    dllfunc(DLLFunc_Spawn, ent)
    new save = pev(ent, pev_solid)
    dllfunc(DLLFunc_Touch, ent, index)
    if(pev(ent, pev_solid) != save)
        return ent
    engfunc(EngFunc_RemoveEntity, ent)
    return -1
}

stock fm_cs_get_weapon_ent_owner(ent) 
{
    if (pev_valid(ent) != 2)
        return -1
    return get_pdata_cbase(ent, 41, 4)
}

stock fm_strip_user_weapons(id, iType = 0)
{
    new iEntity; static iszWeaponStrip;
    if(iszWeaponStrip || (iszWeaponStrip = engfunc(EngFunc_AllocString, "player_weaponstrip"))) iEntity = engfunc(EngFunc_CreateNamedEntity, iszWeaponStrip);
    if(!pev_valid(iEntity)) return 0;
    if(iType && get_user_weapon(id) != CSW_KNIFE)
    {
        engclient_cmd(id, "weapon_knife");
        message_begin(MSG_ONE_UNRELIABLE, 66, _, id);
        write_byte(1);
        write_byte(CSW_KNIFE);
        write_byte(0);
        message_end();
    }
    dllfunc(DLLFunc_Spawn, iEntity);
    dllfunc(DLLFunc_Use, iEntity, id);
    engfunc(EngFunc_RemoveEntity, iEntity);
    return 1;
}

stock PlayerHp_Ga(hp) 
{
    new Count, Hp
    for(new id = 1; id <= get_maxplayers(); id++)
        if(is_user_connected(id) && jbm_get_user_team(id) == 1 && !is_user_bot(id))
            Count++    
    Hp = hp * Count
    return Hp
}

stock UTIL_ScreenFade(id, iDuration, iHoldTime, iFlags, iRed, iGreen, iBlue, iAlpha, iReliable = 0)
{
    message_begin(iReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_ScreenFade, _, id);
    write_short(iDuration);
    write_short(iHoldTime);
    write_short(iFlags);
    write_byte(iRed);
    write_byte(iGreen);
    write_byte(iBlue);
    write_byte(iAlpha);
    message_end();
}

stock ChatColor(const id, const input[], any:...)
{
    new count = 1, players[32], msg[191]; vformat(msg, 190, input, 3)
    replace_all(msg, 190, "!g", "^4")
    replace_all(msg, 190, "!y", "^1")
    replace_all(msg, 190, "!t", "^3")
    if(id)players[0] = id; else get_players(players, count, "ch")
    {
        for(new i = 0; i < count; i++)
        {
            if(is_user_connected(players[i]))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
                write_byte(players[i])
                write_string(msg)
                message_end()
            }
        }
    }
}
