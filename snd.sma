#include <amxmodx>
#include <fakemeta>
#include <cstrike>

new const PL_NAME[] 	= "Grenade"
new const PL_VERSION[] 	= "1.0"
new const PL_AUTHOR[] 	= "NewGame_PL & 7heHex"

/* Указываем пути расположения присваиваемых звуков */

new HE_GRENADE[][]		= { "NewGrenade/1he.wav", "NewGrenade/2he.wav", "NewGrenade/3he.wav", "NewGrenade/4he.wav", "NewGrenade/5he.wav" }	// Звук броска осколоной гранаты
new FLASH_GRENADE[][]	= { "NewGrenade/1flash.wav", "NewGrenade/2flash.wav", "NewGrenade/3flash.wav", "NewGrenade/4flash.wav", "NewGrenade/5flash.wav" }	// Звук броска световой гранаты
new SMOKE_GRENADE[][]	= { "NewGrenade/1smoke.wav", "NewGrenade/2smoke.wav", "NewGrenade/3smoke.wav", "NewGrenade/4smoke.wav", "NewGrenade/5smoke..wav" }		// Звук броска дымовой гранаты
//new MENU_BLOCK[]		= "CSGOGrenade/voice_input.wav"		// Звук отсутствия доступа к меню

new g_pCvar;

enum _:CvarBits (<<=1) {
    BLOCK_RADIO = 1,
    BLOCK_MSG
};

/* Регистрируем плагин и все остальное для функционала */

public plugin_init(){
    register_plugin(PL_AUTHOR, PL_NAME, PL_VERSION)
	g_pCvar = register_cvar("sv_fith_block", "3")
    register_message(get_user_msgid("SendAudio"), "MessageSendAudio")
}

/* Присваиваем звуки для плагина */

public plugin_precache(){
	for(new i; i < 5; i++)
	{
		precache_sound(HE_GRENADE[i]);
		precache_sound(FLASH_GRENADE[i]);
		precache_sound(SMOKE_GRENADE[i]);
	}
}

public MessageSendAudio()	// Функция блокирует отправление радиокоманды при броске гранаты по стандарту
    return IsBlocked(BLOCK_RADIO) ? GetReturnValue(2, "%!MRAD_FIREINHOLE") : PLUGIN_CONTINUE;

GetReturnValue(const iParam, const szString[]){
    new szTemp[18];
    get_msg_arg_string( iParam, szTemp, 17 );
    
    return (equal(szTemp, szString)) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}
bool:IsBlocked( const iType )
    return bool:(get_pcvar_num(g_pCvar) & iType);

public grenade_throw(iPlayer, iGrenade, iGrenadeType)			// Заменяем звуки на бросок гранат
{
    if (!is_user_connected(iPlayer))		// Проверяем игрока на подключение к серверу
	return 0;

    if (iGrenadeType == CSW_HEGRENADE)	// Осколочная граната
	{	
		emit_sound(iPlayer, CHAN_AUTO, HE_GRENADE[random_num(0, 4)], 1.0, ATTN_NORM, 0, PITCH_NORM)		// Новый звук броска
	}
    if (iGrenadeType == CSW_FLASHBANG){	// Световая граната
		emit_sound(iPlayer, CHAN_AUTO, FLASH_GRENADE[random_num(0, 4)], 1.0, ATTN_NORM, 0, PITCH_NORM)		// Новый звук броска
	}
    if (iGrenadeType == CSW_SMOKEGRENADE){	// Дымовая граната
		emit_sound(iPlayer, CHAN_AUTO, SMOKE_GRENADE[random_num(0, 4)], 1.0, ATTN_NORM, 0, PITCH_NORM)		// Новый звук броска
	}
}