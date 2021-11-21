#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include <saytext>
#include <engine>

#define PLUGIN "Player Animations Menu"
#define VERSION "0.1.1"
#define AUTHOR "code PomanoB and translite ScrooleR"

#define ANIM_MODEL "models/anim.mdl"

native jbm_get_day_mode();

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

new g_vecPosition[33][3]

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
   
   g_animMenu = menu_create("Анимации", "animMenuHandler")
   
   g_cvarAccessFlag = register_cvar("anim_access_flag", "m")
   register_forward(FM_PlayerPreThink, "Fakemeta_PreThink", false);
   
   loadModel(ANIM_MODEL)
}

public Fakemeta_PreThink(id)
{
   if(!g_playerData[id][ANIM_PLAYING]) return HAM_IGNORED;
   new vecOrig[3];
   get_user_origin(id, vecOrig);
   if(vecOrig[0] != g_vecPosition[id][0] || vecOrig[1] != g_vecPosition[id][1] || vecOrig[2] != g_vecPosition[id][2])
   {
      if(is_user_connected(id) && is_user_alive(id))
      stopAnim(id);
   }
   return HAM_IGNORED;
}

public plugin_precache()
{
   precache_model(ANIM_MODEL)
   precache_model("models/rpgrocket.mdl");
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
      menu_setprop(g_animMenu, MPROP_BACKNAME, "Назад");
      menu_setprop(g_animMenu, MPROP_NEXTNAME, "Далее");
      menu_setprop(g_animMenu, MPROP_EXITNAME, "Выход");
      menu_setprop(g_animMenu, MPROP_TITLE, "\yМеню анимаций");
   }
   
   fclose(file)
}

public client_putinserver(id)
{
   if (!g_playerData[id][ENT_MODEL])
      createPlayerEnt(id)
}

public client_disconnected(id)
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

public plugin_natives()
{
   register_native("stopAnim", "stopAnim", 1);
}

public cmdAnim(id)
{
   new access[32], flag
   get_pcvar_string(g_cvarAccessFlag, access, 31)
   flag = read_flags(access)
   
   if(jbm_get_day_mode() != 2)
   {
      UTIL_SayText(id, "!y[!gJBM!y] Меню анимаций доступно только во время !tсвободного дня!y.");
      return PLUGIN_HANDLED;
   }
   if (!flag || (get_user_flags(id)&flag))
      menu_display(id, g_animMenu)
   else
      UTIL_SayText(id, "!y[!gJBM!y] Для того, чтобы использовать анимации, вам нужен !tVIP+!y.");
   return PLUGIN_CONTINUE;
}

public startAnim(id, anim)
{
   new seqDesc[SEQ_DESC]
   ArrayGetArray(g_animData, anim, seqDesc)
   
   new ent = g_playerData[id][ENT_ANIM]
   new modelEnt = g_playerData[id][ENT_MODEL]
   set_pev(ent, pev_framerate, 1.0)
   set_pev(ent, pev_sequence, anim)
   set_pev(ent, pev_gaitsequence, anim)
   
   new Float:origin[3], Float:mins[3]
   pev(id, pev_origin, origin)
   pev(id, pev_mins, mins)

   get_user_origin(id, g_vecPosition[id]);
   
   mins[0] = origin[0]
   mins[1] = origin[1]
   mins[2] += origin[2]
   set_pev(ent, pev_origin, mins)
   
   set_pev(modelEnt, pev_effects, 0)
   new model[64]
   get_user_info(id, "model", model, 63)
   format(model, 63, "models/player/%s/%s.mdl", model, model)
   engfunc(EngFunc_SetModel, modelEnt, model)
   
   set_pev(modelEnt, pev_body, pev(id, pev_body))
   set_pev(modelEnt, pev_skin, pev(id, pev_skin))
   
   set_pev(ent, pev_controller_0, 128)
   set_pev(ent, pev_controller_1, 128)
   
   pev(id, pev_angles, mins)
   mins[0] = 0.0
   set_pev(ent, pev_angles, mins)
   set_pev(ent, pev_v_angle, mins)
   
   set_view(id,CAMERA_3RDPERSON);
   g_playerData[id][ANIM_PLAYING] = 1
   
   set_pev(id, pev_effects, EF_NODRAW)
   client_cmd(id, "stopsound");
}

public stopAnim(id)
{
   if(!is_user_connected(id)) return;
   set_pev(g_playerData[id][ENT_MODEL], pev_effects, EF_NODRAW)
   g_playerData[id][ANIM_PLAYING] = 0
   set_pev(id, pev_effects, 0)
   
   set_view(id,CAMERA_NONE);
   client_cmd(id, "stopsound");
}

public animMenuHandler(id, menu, item)
{
   if(item == MENU_EXIT)
      return PLUGIN_HANDLED
   
   new access[32], flag
   get_pcvar_string(g_cvarAccessFlag, access, 31)
   flag = read_flags(access)
   
   if(jbm_get_day_mode() != 2)
   {
      UTIL_SayText(id, "!y[!gJBM!y] Меню анимаций доступно только во время !tсвободного дня!y.");
      return PLUGIN_HANDLED;
   }

   if (flag && !(get_user_flags(id)&flag))
   {
      UTIL_SayText(id, "!y[!gJBM!y] Для того, чтобы использовать анимации, вам нужен !tVIP+!y.");
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
public fwdPlayerKilled(id)
{
   stopAnim(id)   
}