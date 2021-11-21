﻿/*//#include <amxmodx>*/
#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#define PLUGIN "Player Animations Menu"
#define VERSION "0.1.1"
#define AUTHOR "code PomanoB and translite ScrooleR"

#define ANIM_MODEL "models/anim.mdl"

enum _:PLAYER_DATA
{
   ENT_CAM,
   ENT_MODEL,
   ENT_ANIM,
   ANIM_PLAYING
}

enum _:SEQ_DESC
{
   MODEL[64],
   SEQ_LABEL[33],
   SEQ_FPS,
   SEQ_FRAMES,
   SEQ_FRAMERATE
}

new g_allocString

new g_playerData[33][PLAYER_DATA]

new Array:g_animData

new g_animMenu

new g_cvarAccessFlag

public plugin_init() 
{
   register_plugin(PLUGIN, VERSION, AUTHOR)
   
   register_clcmd("say /dance", "cmdAnim")

   register_forward(FM_CmdStart, "fwdCmdStart", 1)
   
   RegisterHam(Ham_Killed, "player", "fwdPlayerKilled", 1)

   g_allocString = engfunc(EngFunc_AllocString, "info_target")
   
   g_animData = ArrayCreate(SEQ_DESC)
   
   g_animMenu = menu_create("\yМеню танцев", "animMenuHandler")
   
   g_cvarAccessFlag = register_cvar("anim_menu_access_flag", "")
   
   loadModel(ANIM_MODEL)
}

public plugin_precache()
{
   precache_model(ANIM_MODEL)
}

public plugin_end()
{
   ArrayDestroy(g_animData)
}

public loadModel(model[])
{
   new file = fopen(model, "rt")
   new numseq, seqindex, i, Float:framerate
   
   new seqDesc[SEQ_DESC]
   
   fseek(file, 164, SEEK_SET)
   fread(file, numseq, BLOCK_INT)
   fread(file, seqindex, BLOCK_INT)
   
   for(i = 0; i < numseq; i++)
   {
      fseek(file, seqindex + 176*i, SEEK_SET)
      fread_blocks(file, seqDesc[SEQ_LABEL], 32, BLOCK_CHAR)
      
      fread(file, seqDesc[SEQ_FPS], BLOCK_INT)
   
      fseek(file, 20, SEEK_CUR)
      fread(file, seqDesc[SEQ_FRAMES], BLOCK_INT)
      
      framerate = 256.0 * Float:seqDesc[SEQ_FPS] / (seqDesc[SEQ_FRAMES] - 1)
      
      seqDesc[SEQ_FRAMERATE] = _:framerate
      
      ArrayPushArray(g_animData, seqDesc)
      
      menu_additem(g_animMenu, seqDesc[SEQ_LABEL], "")
   }
   
   fclose(file)
}

public client_putinserver(id)
{
   if (!g_playerData[id][ENT_MODEL])
      createPlayerEnt(id)
}

public client_disconnect(id)
{
   stopAnim(id)
}

public createPlayerEnt(id)
{
   new ent = engfunc(EngFunc_CreateNamedEntity, g_allocString)
   set_pev(ent, pev_rendermode, kRenderTransAdd)
   set_pev(ent, pev_renderamt, 0.0)
   set_pev(ent, pev_owner, id)
   engfunc(EngFunc_SetModel, ent, ANIM_MODEL)
   
   g_playerData[id][ENT_CAM] = ent
   
   ent= engfunc(EngFunc_CreateNamedEntity, g_allocString)
   engfunc(EngFunc_SetModel, ent, ANIM_MODEL)
   set_pev(ent, pev_movetype, MOVETYPE_FLY)
   set_pev(ent, pev_controller_1, 63.75)
   
   g_playerData[id][ENT_ANIM] = ent
   
   ent= engfunc(EngFunc_CreateNamedEntity, g_allocString)
   set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
   set_pev(ent, pev_aiment, g_playerData[id][ENT_ANIM])
   set_pev(ent, pev_effects, EF_NODRAW)
   
   g_playerData[id][ENT_MODEL] = ent
}

public cmdAnim(id)
{
   new access[32], flag
   get_pcvar_string(g_cvarAccessFlag, access, 31)
   flag = read_flags(access)
   
   if (!flag || (get_user_flags(id)&flag))
      menu_display(id, g_animMenu)
   else
      client_print(id, print_chat, "У вас нет прав!")
}

public startAnim(id, anim)
{
   new seqDesc[SEQ_DESC]
   ArrayGetArray(g_animData, anim, seqDesc)
   
   new ent = g_playerData[id][ENT_ANIM]
   new modelEnt = g_playerData[id][ENT_MODEL]
//   set_pev(ent, pev_framerate, seqDesc[SEQ_FRAMERATE])
   set_pev(ent, pev_framerate, 1.0)
//   set_pev(ent, pev_animtime, (seqDesc[SEQ_FRAMES] - 1)/seqDesc[SEQ_FPS])
   set_pev(ent, pev_sequence, anim)
   set_pev(ent, pev_gaitsequence, anim)
   
   new Float:origin[3], Float:mins[3]
   pev(id, pev_origin, origin)
   pev(id, pev_mins, mins)
   
   mins[0] = origin[0]
   mins[1] = origin[1]
   mins[2] += origin[2]
   set_pev(ent, pev_origin, mins)
   
   set_pev(modelEnt, pev_effects, 0)
   new model[64]
   get_user_info(id, "model", model, 63)
   format(model, 63, "models/player/ujbm_v1/ujbm_v1.mdl", model, model)
   engfunc(EngFunc_SetModel, modelEnt, model)
   
   set_pev(modelEnt, pev_body, pev(id, pev_body))
   set_pev(modelEnt, pev_skin, pev(id, pev_skin))
   
   set_pev(ent, pev_controller_0, 128)
   set_pev(ent, pev_controller_1, 128)
   
   pev(id, pev_angles, mins)
   mins[0] = 0.0
   set_pev(ent, pev_angles, mins)
   set_pev(ent, pev_v_angle, mins)
   
   engfunc(EngFunc_SetView, id, g_playerData[id][ENT_CAM])
   g_playerData[id][ANIM_PLAYING] = 1
   
   set_pev(id, pev_effects, EF_NODRAW)
   
}

public stopAnim(id)
{
   set_pev(g_playerData[id][ENT_MODEL], pev_effects, EF_NODRAW)
   g_playerData[id][ANIM_PLAYING] = 0
   set_pev(id, pev_effects, 0)
   
   engfunc(EngFunc_SetView, id, id)
}

public animMenuHandler(id, menu, item)
{
   if(item == MENU_EXIT)
      return PLUGIN_HANDLED
   
   new access[32], flag
   get_pcvar_string(g_cvarAccessFlag, access, 31)
   flag = read_flags(access)
   
   if (flag && !(get_user_flags(id)&flag))
   {
      client_print(id, print_chat, "У вас нет прав!")
      return PLUGIN_HANDLED
   }
   
   if (!(pev(id, pev_flags)&FL_ONGROUND))
   {
      client_print(id, print_chat, "Вы должны быть на земле!")
      return PLUGIN_HANDLED
   }
   
   startAnim(id, item)
   
   menu_display(id, g_animMenu, floatround(item/7.0, floatround_floor))
   
   return PLUGIN_HANDLED
}

public fwdCmdStart(id, uc, randseed)
{
   if (is_user_alive(id) && g_playerData[id][ANIM_PLAYING])
   {
      if (!get_uc(uc, UC_Buttons))
      {
         static Float:fOrigin[3], Float:fAngle[3], Float:origin[3]
         pev( id, pev_origin, origin )
         pev(id, pev_view_ofs, fOrigin)
         xs_vec_add(origin, fOrigin, origin)
         xs_vec_copy(origin, fOrigin)
         pev(id, pev_v_angle, fAngle)
      
         static Float:fVBack[3]
         angle_vector(fAngle, ANGLEVECTOR_FORWARD, fVBack)
      
         fOrigin[2] += 20.0
         
         fOrigin[0] += (-fVBack[0] * 150.0)
         fOrigin[1] += (-fVBack[1] * 150.0)
         fOrigin[2] += (-fVBack[2] * 150.0)
         
         static tr
         tr = 0
         engfunc(EngFunc_TraceLine, origin, fOrigin, IGNORE_MONSTERS, id, tr)
         get_tr2(tr, TR_vecEndPos, fOrigin)
         free_tr2(tr)
      
         engfunc(EngFunc_SetOrigin, g_playerData[id][ENT_CAM], fOrigin)
         set_pev(g_playerData[id][ENT_CAM], pev_angles, fAngle)
      }
      else
         stopAnim(id)
   }
}

public fwdPlayerKilled(id)
{
   stopAnim(id)   
}