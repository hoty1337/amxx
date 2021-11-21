#include <amxmodx>
#include <amxmisc>
#include <grip>


#define SLEEP_TIME          // закоментируйте если вам не нужен ночной режим, когда сообщения не будут приходить

#if defined SLEEP_TIME
const g_Start_Time = 00       // Время начала ночного режима
const g_End_Time = 10         // Время конца ночного режима
#endif


new const DELAY = 25;   // Анти-спам в секундах. 
new const g_URL[] = "https://api.vk.com/method/messages.send?chat_id=1&v=5.37&access_token=b8f233049e3fbaa790e00617f5920db3680ce9b6cbe032499912d8783e8d2f4e22c5dfa9b2aa0ec8e0b39&message=";

new Float:g_flNextTime[33];

new bool:g_bConfirm[33];

public plugin_init() {
	register_plugin("vkontakte MSG", "1.2.0", "ex3m777");
	register_clcmd("say /vk","message");
	register_clcmd("say_team /vk", "message");
	register_clcmd("vk","CommandMessage");
	register_menucmd(register_menuid("Show_MenuConfirm"), 1023, "Handle_MenuConfirm");
}


public HandleRequest() {
    new GripResponseState:responseState = grip_get_response_state();
    if (responseState == GripResponseStateError) {
        return;
    }

    new GripHTTPStatus:status = grip_get_response_status_code();
    if (status != GripHTTPStatusCreated) {
        return;
    }
}

public Show_MenuConfirm(id)
{
    new szMenu[512], iKeys = (1<<0|1<<1|1<<9), iLen = formatex(szMenu, charsmax(szMenu), "На сервере присутствует админ,^nвы \yуверены\w, что хотите отправить сообщение?^n^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r1\y] \d- \wДа, написать.^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\y[\r2\y] \d- \wНет, обращусь к админу.^n");
    iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n^n\y[\r0\y] \d- \wВыход^n");

    return show_menu(id, iKeys, szMenu, -1, "Show_MenuConfirm");
}

public Handle_MenuConfirm(id, iKey)
{
    switch(iKey)
    {
        case 0:
        {
            g_bConfirm[id] = true;
            return message(id);
        }
        case 1:
        {
            g_bConfirm[id] = false;
            client_print_color(id, print_team_default, "^1[^4Инфо^1] ^1Вы отменили действие.");
        }
        case 9:
        {
            g_bConfirm[id] = false;
        }
    }
    return PLUGIN_HANDLED;
}

public client_putinserver(id)
{
    g_bConfirm[id] = false;
}

public message(id) {
    #if defined SLEEP_TIME
    static CurHour; time(CurHour);
    if(g_Start_Time <= CurHour && CurHour < g_End_Time) {
        client_print_color(id, print_team_default, "^1[^4Инфо^1] ^1Админ сейчас спит.");
        return PLUGIN_HANDLED;
    }
    #endif

    if(g_flNextTime[id] > get_gametime()) {
        client_print_color(id, print_team_default, "^1[^4Инфо^1] ^1Вы слишком часто отправляете сообщения.");
        return PLUGIN_HANDLED;
    }
    if(!g_bConfirm[id])
    {
        new bool:bAdmOnline = false;
        for(new i = 1 ; i <= get_maxplayers(); i++)
        {
            if(!is_user_connected(i)) continue;
            if(get_user_flags(i) & ADMIN_BAN)
            {
                bAdmOnline = true;
            }
        }
        if(bAdmOnline)
        {
            return Show_MenuConfirm(id);
        }
    }
    client_cmd(id,"messagemode vk");
    client_print_color(id, print_team_default, "^1[^4Инфо^1] ^1Введите сообщение и нажмите ^4Enter.");
    g_bConfirm[id] = false;

    g_flNextTime[id] = get_gametime() + DELAY;
    return PLUGIN_CONTINUE;

}


public CommandMessage(id) {
    new Args[256], text[512]
    read_args(Args, charsmax(Args));
    remove_quotes(Args);

    if(strlen(Args) < 1) {
        return;
    }

    new GripBody:body = grip_body_from_string("{^"title^": ^"foo^", ^"body^": ^"bar^", ^"userId^": 1}");
    new GripRequestOptions:options = grip_create_default_options();
    grip_options_add_header(options, "Content-Type", "application/json");
    grip_options_add_header(options, "User-Agent", "Grip");

    formatex(text, charsmax(text), "%s%n: %s", g_URL, id, Args);

    grip_request(text,  body, GripRequestTypePost, "HandleRequest", options);
    grip_destroy_body(body);
    grip_destroy_options(options);
    client_print_color(id, print_team_default, "^1[^4Инфо^1] ^1Ваше сообщение отправлено!");

    static sAuth[25];
    get_user_authid(id, sAuth, charsmax(sAuth));

    log_to_file("vk.log", "Игрок [%n] [%s] отправил сообщение: %s", id, sAuth, Args);
}