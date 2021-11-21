/*
Created by Notepad++ [charset: UTF-8 (without BOM)] [unknown chars Language: Russian]

Autor:	Mr_ILYAS

Skype:	ilyas355
ICQ:	444889194

------------------------------------------------------------ Changelog: -----------------------------------------------------------------------------
1.0:
Первый релиз.

1.1:
1)	Добавлено логирование в отдельный файл (в отдельную папку).
	Добавлены новые квары: log_hide_msg, log_ignore_msg, log_console_cmd_from_chat, которые влияют на количество логируемого текста.

	Теперь можно спокойно зайти в папку и просматривать сообщения не только текущего дня. Ведь для каждого календарного числа создаётся свой файл.

2)	Исправлено отображение чата в консоли. Добавлено время каждого сообщения.

3)	Теперь звуки можно отключить из использования плагином. Достаточно закомментировать специально созданные для этого дефы.


1.2:
1)	Добавлены новые звуки.
	(Звук при: сообщении своей команде, сообщении в админском чате, приватном сообщении, а также звук "ошибки" (т.е. нарушения правил).
	На каждый звук там несколько вариантов. Используйте какие из предложенных понравятся.

	Созданы дефы для их включения/отключения.

2)	Изменён порядок блоков кода. Это сделано для корректного вывода (или блокировки) текста в чат.

3)	Добавлено логирование в файл действий администратора, связанных с блокировкой/разблокировкой чата игрокам.

4)	Теперь в консоли игрока будет логироваться только текст игроков, а не как раньше. Благодаря ново добавленному четвертому параметру типа boolean,
	который отвечает за логирование только нужного текста (речь о функции writeMessage).
	Хотя Вы можете настроить себе сами как надо. Например, сообщение о блокировке/разблокировке чата тоже идёт в логирование в консоль игроку (однократно).
	
5)	Добавлена защита от рекламы ip адресов. Добавлено их логирование в консоль и в файл.
	В добавок присутствующие администраторы будут оповещены в админском чате о нарушителе.

6)	Путь до папки с логами можно теперь выбрать самостоятельно, указав тут.

7)	Добавлен квар all_chat, который влияет на видимость чата. Подробности в функции plugin_init()

8)	Меню приватных сообщений можно открыть теперь командой в чате /pm. Также добавлена краткая форма консольного варианта - тоже pm.

Ну и в общем бегло пробежался по коду и исправил мелкие недочёты.

1.2a:
1)	Добавлен новый квар translit_on для того, чтобы устанавливать язык по умолчания при заходе на сервер.

2)	Убран баг, который мешает функционированию плагина, если превышен лимит MAX_PREFIXS, MAX_DONT_TRANSLIT и MAX_IGNORE_MSG.

1.2b:
1) Исправлены мелкие недочёты в алгоритмах.

2) Убран баг с символами %z, %s и пр., вызывающие зависание.
------------------------------------------------------------------------------------------------------------------------------------------------------
*/
#include <amxmisc>
#include <regex>

#define ADMIN_ACCESS			ADMIN_CVAR				//Главный доступ (возможность посылать команды от имени сервера, цвет и имя в сообщении завясит от amx_namecolor и amx_textcolor, доступ к их изменению) (по умолчанию флаг g).
#define ADMIN__ADMIN			ADMIN_RESERVATION		//Возможность общаться в админском чате, и блокировать чат игрокам (по умолчанию флаг b).
#define ADMIN_LISTEN			ADMIN_LEVEL_G			//Видимость всего чата (в том числе и скрытых сообщений) (по умолчанию флаг s).

#define MAX_PREFIXS				60						//Установите максимальное число префиксов, которое может взять плагин из файла.
#define MAX_IGNORE_MSG			60						//Установите максимальное число загруженных слов из файла для запрета в чате.
#define MAX_DONT_TRANSLIT		60						//Установите максимальное число загруженных слов из файла, которые не будут переводиться транслитом.

//Можно закомментировть ниже идущие строки, если какой-либо звук не нужен.
#define CHAT_SOUND_SEND_MSG								//Использовать звук при отправке обычного сообщения.
#define CHAT_SOUND_READ_MSG								//Использовать звук при появлении обычного сообщения. Это касается как своей команды (say_team), так и общего (say).
#define PRIVATE_CHAT_SOUND								//Использовать звук при получении приватного сообщения.
#define TRANSLIT_SOUND									//Использовать звук при смене языка.
#define ERROR_SOUND										//Использовать звук ошибки (при флуде или когда игрок рекламирует ip).
#define ADMIN_CHAT_SOUND								//Использовать звук сообщения в админский чат.

//Далее указываются адреса файлов звука в формате .wav (относительно папки sound).
//Указывать файлы без расширения.
#define SEND_MSG_SOUND			"misc/send_msg4"		//Звук отправки сообщения в общий чат.
#define READ_MSG_SOUND			"misc/read_msg3"		//Звук чтения сообщений от общего чата (от say).
#define READ_TEAM_MSG_SOUND		"misc/read_team_msg4"	//Звук чтения сообщений своей команды (от say_team).
#define PRIVATE_MSG_SOUND		"misc/private_msg1"		//Звук чтения приватных сообщений.
#define TRANSLIT_MSG_SOUND		"misc/translit"			//Звук при смене языка.
#define ERROR_MSG_SOUND			"misc/chat_error2"		//Звук при флуде а также рекламе ip.
#define ADMIN_CHAT_MSG_SOUND	"misc/admin_chat_msg2"	//Звук чтения сообщений админского чата.

#define LOGS_DIR	"addons/amxmodx/configs/Chat__logs"		//Путь для сохранения папки и файлов с логами. Если папки (или пути до нее) не существует, сервер создаст сам (её путь).

static message[192],ignore_msg[MAX_IGNORE_MSG+2][191],dont_translit[MAX_DONT_TRANSLIT+2][191],str_ip[162],teamInfo,maxPlayers,admin_listen_look_hide_msg,hide_commands,translit_on,name_color,text_color,log_hide_msg,log_ignore_msg,log_console_cmd_from_chat,all_chat,stringName[191],stringText[191],prefix[100],not_found_char[191],text_data[11],flood_warning[33]={0,...},dont_flood_time;
static bool:rus_eng[33]={false,...},bool:translit=true,bool:gag[33]={false,...},bool:snd_play[33]={true,...};
static gag_page[33]={0,...},private_player[33]={0,...},source_private_player[33]={0,...};
static Float:flood_time[33]={0.0,...},Float:old_time[33]={0.0,...};
static max_ignore_msg=0,max_dont_translit=0;

static trans_eng[][]={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","{","}",":",'"',"<",">","~","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","[","]",";","'",",",".","`","?","/","@","$","^^","&","|"};
static trans_rus[][]={"Ф","И","С","В","У","А","П","Р","Ш","О","Л","Д","Ь","Т","Щ","З","Й","К","Ы","Е","Г","М","Ц","Ч","Н","Я","Х","Ъ","ж","Э","Б","Ю","Ё","ф","и","с","в","у","а","п","р","ш","о","л","д","ь","т","щ","з","й","к","ы","е","г","м","ц","ч","н","я","х","ъ","ж","э","б","ю","ё",",",".","'",";", ":","?","/"};
static chars_ip [][]={".",",","/","?"," ",":"}; //Символы (англ. раскладки), которые могут использоваться в качестве разделителя между цифрами в рекламе ip. Можете добавить еще что-нибудь через запятую в кавычках, как предыдущие символы.
//На рус. выглядят так: "ю" "б" "." "," " " "ж"

#define LEFT_SLASH	'\'
#define MAX_CLR		10
static msgChannel;
static Color[MAX_CLR][]={"Белый","Красный","Залёный","Синий","Жёлтый","Пурпурный","Голубой","Оранжевый","Океан","Коричневый"};
static Values[MAX_CLR][]={{255,255,255},{255,0,0},{0,255,0},{0,0,255},{255,255,0},{255,0,255},{0,255,255},{227,96,8},{45,89,116},{103,44,38}};
static Float:Pos[4][]={{0.0,0.0},{0.05,0.55},{-1.0,0.2},{-1.0,0.7}};
static hud_msg[33][192],hud_msg_col_settings[33][3],Float:hud_msg_pos_settings[33][2];
static str_txt[64],file,text[191],prefixs[131][MAX_PREFIXS+2],this_flag[MAX_PREFIXS+2];
static Regex:is_ip;
public plugin_init(){
	register_plugin("Chat Manager","1.2b","Mr_ILYAS");
	teamInfo=get_user_msgid("TeamInfo");
	maxPlayers=get_maxplayers();

	hide_commands=register_cvar("hide_commands","1");							//Скрывать ли команды написанные через правый слеш "/" : 0 - нет; 1 - скрывать.
	admin_listen_look_hide_msg=register_cvar("admin_listen_look_hide_msg","1");	//Для ADMIN_LISTEN: 1 - показывать команды через "/" ; 2 - показывать 1 + показ ignore_msg; 3 - только ignore_msg; 0 - ни то, ни другое.
	translit_on=register_cvar("translit_on","0");								//Язык по умолчанию: 0 - англ.; 1 - рус.

	//Следующие две переменные относятся к главному администратору, указанному в ADMIN_ACCESS
	text_color=register_cvar("text_color","3");									//3 - Серый (цвет текста).
	name_color=register_cvar("name_color","2");									//2 - Зелёный (цвет ника).

	log_hide_msg=register_cvar("log_hide_msg","0");								//1 - логировать в файл скрытые сообщения. 0 - нет.
	log_ignore_msg=register_cvar("log_ignore_msg","1");							//1 - логировать в файл вырезанные сообщения. 0 - нет.
	log_console_cmd_from_chat=register_cvar("log_console_cmd_from_chat","2");	//2 - логировать в файл все команды, посланные через чат (1 или 2 левых слеша); 1 - только серверные (только когда 2 левых слеша); 0 - нет.

	//Следующий квар (all_chat) влияет на видимость чата. На игрока с доступом ADMIN_LISTEN никак не влияет, ибо он всё равно видит всё.
	//Уловные обозначения: знак --> означает "видит" (слева от него отправитель, справа получатель).
	all_chat=register_cvar("all_chat","4");	//1: [живого --> живой], [мёртвого --> мёртвый];  2: как в 1 пункте, только в добавок еще [админа --> живой и мёртвый];  3: то же самое, что 1, в добавок [мёртвого --> живой];  4: то же самое, что 3, но в добавок [админа --> живой и мёртвый];  5: без ограничений.
	dont_flood_time=register_cvar("dont_flood_time","1.0");						//Допустимое время между сообщениями (сек.). Начинает реагировать c третьего сообщения подряд.
	
	register_concmd("amx_namecolor","set_name_color",ADMIN_ACCESS," <1...6>");
	register_concmd("amx_textcolor","set_msg_color",ADMIN_ACCESS," <1...5>");
	register_clcmd("say","hook_say");
	register_clcmd("say_team","hook_teamsay");
	#if defined CHAT_SOUND_SEND_MSG || defined CHAT_SOUND_READ_MSG
	register_clcmd("soff","func_off_s",0," - Звук чата выкл.");
	register_clcmd("son","func_on_s",0," - Звук чата вкл.");
	#endif

	register_clcmd("private_msg","run_private_msg_menu",0," - открыть меню приватных сообщений");
	register_clcmd("pm","run_private_msg_menu",0," - открыть меню приватных сообщений");

	register_clcmd("private_message","show_private_msg");

	register_clcmd("amx_gag","run_gag",ADMIN__ADMIN," <nik | #userid> - заблокировать чат (либо, если без параметров, открыть меню запрета чата)");
	register_clcmd("amx_ungag","run_gag",ADMIN__ADMIN," <nik | #userid> - разблокировать чат (либо, если без параметров, открыть меню запрета чата)");

	register_concmd("reload_files","reload_files",ADMIN_ACCESS," - Перезагрузить файлы плагина Chat_Manager.amxx");
	register_concmd("rf","reload_files",ADMIN_ACCESS," - Перезагрузить файлы плагина Chat_Manager.amxx"); //Чтобы не перезагружать сервер (например если поменяли префиксы), то достаточно этих команд.

	mkdir(LOGS_DIR);
	load_f();
	get_time("%d-%m-%Y",text_data,10);
	format(str_txt,63,"%s/Data__%s.txt",LOGS_DIR,text_data);
	get_time("%H:%M:%S",text_data,10);
	get_mapname(text,31);
	format(message,191,"[%s] ----------------------- Загружена карта: %s -----------------------",text_data,text); //При чтении логов будет ясно на какой карте был тот-или иной диалог.
	write_file(str_txt,message,-1);
	return PLUGIN_CONTINUE;
}
public plugin_modules()require_module("regex");
public client_disconnect(id)snd_play[id]=true;
public client_putinserver(id){
	new str[20];
	get_user_info(id,"_translit",str,sizeof(str)-1);
	if(get_pcvar_num(translit_on))rus_eng[id]=true;
	else rus_eng[id]=false;
	if(equal(str,"rus"))rus_eng[id]=true;
	if(equal(str,"eng"))rus_eng[id]=false;
	if(!(get_user_flags(id)&ADMIN_ACCESS))check_join_command(id);
	get_user_info(id,"_ginfo",str,sizeof(str)-1);
	if(equal(str,"true"))gag[id]=true;
	else gag[id]=false;
	snd_play[id]=true;
}
public check_join_command(id){
	if(get_user_team(id)!=1 && get_user_team(id)!=2){
		if(id)set_task(2.0,"check_join_command",id);
		return PLUGIN_CONTINUE;
	}else set_task(30.0,"show_translit_msg",id);
	return PLUGIN_CONTINUE;
}
public show_translit_msg(id){
	writeMessage(id," ",0,false); //Предпоследний параметр (где 0 стоит) влияет на цвет после тега ^x03. Если вместо нуля будет:  1- то красный; 2-синий; 3-серый; 4-цвет команды; 0-по умолчанию (если тег ^x03 не используется).
	writeMessage(id,"^x03Для перевода чата на    ^x01русский   ^x03пиши ^x04/rus",3,false); //Например в этих двух сообщениях будет использован серый цвет.
	writeMessage(id,"^x03Для перевода чата на  ^x01английский ^x03пиши ^x04/eng",3,false);  //Для того, чтобы указать цвет команды конкретного игрока (номер 1, 2 или 3), есть функция get_color_num(id).
	writeMessage(id," ",0,false); //Если тег ^x03 не используется, лучше поставить 0. Так мы избвимся от лишних действий внутри функции.
}
public translit_text(text[192]){
	new new_text[192],one_char[192],i=0,len;
	new bool:no_translate=false,bool:end_translit=true;
	len=strlen(text);
	add(text,190," ");
	for(i=0;i<len;i++){
		if(no_translate==true){
			if(equal(text[i],"|",1)){
				if(text[i+1]=='|'){
					add(new_text,191,"|");
					i++;
				}else no_translate=false;
			}else{
				copy(one_char,191,text[i]);
				one_char[1]=0;
				add(new_text,191,one_char);
			}
		}else{
			if(equal(text[i],"|",1)){
				if(text[i+1]=='|'){
					add(new_text,191,"|");
					i++;
				}else no_translate=true;
			}else{
				end_translit=true;
				for(new j=0;j<73;j++){
					if(equal(text[i],trans_eng[j],1)){
						if(j==68)add(new_text,191,"''"); //Обычные кавычки приводят к обрезке текста. Поэтому используются двойные апострофы, похожие на кавычки.
						else add(new_text,191,trans_rus[j]);
						j=73;
						end_translit=false; //Конец транслита (конец массива trans_eng) не был достигнут, так как нашёлся символ из массива для замены.
					}
				}
				if(end_translit){ //Если не найден символ в массиве trans_eng, то этот символ добавляется без перевода на русский, то есть как он есть (обычно это цифры).
					format(not_found_char,191,"%s",text[i]);
					not_found_char[1]=0;
					add(new_text,191,not_found_char);
				}
			}
		}
	}
	copy(text,191,new_text);
}
public gag_menu(id,page){
	new gag_name[32],gag_pl[32],gag_item[100],gag_num,gag_cmd[5],i,gag_menu;
	gag_menu=menu_create("\wЗапретить чат игроку:\y","gag_menu_actions");
	get_players(gag_pl,gag_num,"c");
	for(i=0;i<gag_num;i++){
		if(gag_pl[i]==id)continue;
		if(get_user_flags(i)&ADMIN__ADMIN)continue;
		get_user_name(gag_pl[i],gag_name,31);
		formatex(gag_cmd,4,"%i",gag_pl[i]);
		formatex(gag_item,99,"%s %s",gag_name,gag[i+1]?"\rвкл":"\yвыкл");
		menu_additem(gag_menu,gag_item,gag_cmd);
	}
	if(i==1){
		menu_destroy(gag_menu);
		writeMessage(id," ",0,false); //false или true влияет на дополнительное логирование в консоль игроку (см. внутри функции writeMessage).
		writeMessage(id,"Нет реальных игроков.",0,false);
		writeMessage(id," ",0,false);
		return PLUGIN_HANDLED;
	}else{
		page=gag_page[id];
		menu_display(id,gag_menu,page);
	}
	return PLUGIN_HANDLED;
}
public run_gag(id){
	if(!(get_user_flags(id)&ADMIN__ADMIN))return PLUGIN_HANDLED;
	new Arg[32],name[32],name_admin[32];
	read_argv(0,Arg,sizeof(Arg)-1);
	if(equal(Arg,"amx_gag")){
		read_argv(1,Arg,sizeof(Arg)-1);
		if(!equal(Arg,"")){
			new Target_gag;
			Target_gag=cmd_target(id,Arg,CMDTARGET_ALLOW_SELF);
			if(Target_gag){
				gag[Target_gag]=true;
				client_cmd(Target_gag,"setinfo _ginfo true");
				writeMessage(id,		"^x03                                                              Чат заблокирован",1,false);
				writeMessage(Target_gag,"^x03                                                              Чат заблокирован",1,false);
				writeMessage(Target_gag,"^x03                                                              Чат заблокирован",1,false);
				writeMessage(Target_gag,"^x03                                                              Чат заблокирован",1,false);
				writeMessage(Target_gag,"^x03                                                              Чат заблокирован",1,false);
				writeMessage(Target_gag,"^x03                                                              Чат заблокирован",1,true);
				get_user_name(Target_gag,name,31);
				get_user_name(id,name_admin,31);
				log_str("[amx_gag] Администратор  %s  заблокировал чат игроку  %s",name_admin,name);
			}
			return PLUGIN_HANDLED;
		}
		gag_menu(id,0);
	}else if(equal(Arg,"amx_ungag")){
		read_argv(1,Arg,sizeof(Arg)-1);
		if(!equal(Arg,"")){
			new Target_gag;
			Target_gag=cmd_target(id,Arg,CMDTARGET_ALLOW_SELF);
			if(Target_gag){
				gag[Target_gag]=false;
				client_cmd(Target_gag,"setinfo _ginfo false");
				writeMessage(id,		"^x04                                                             Чат разблокирован",0,false);
				writeMessage(Target_gag,"^x04                                                             Чат разблокирован",0,false);
				writeMessage(Target_gag,"^x04                                                             Чат разблокирован",0,false);
				writeMessage(Target_gag,"^x04                                                             Чат разблокирован",0,false);
				writeMessage(Target_gag,"^x04                                                             Чат разблокирован",0,false);
				writeMessage(Target_gag,"^x04                                                             Чат разблокирован",0,true);
				get_user_name(Target_gag,name,31);
				get_user_name(id,name_admin,31);
				log_str("[amx_ungag] Администратор  %s  разблокировал чат игроку  %s",name_admin,name);
			}
			return PLUGIN_HANDLED;
		}
		gag_menu(id,0);
	}
	return PLUGIN_HANDLED;
}
public gag_menu_actions(id,gag_menu,gag_item){
	if(gag_item==MENU_EXIT){
		menu_destroy(gag_menu);
		return PLUGIN_HANDLED;
	}
	new gag_data[32],gag_iName[64],gag_ADMIN,gag_callback,gag_id,name[32],name_admin[32],txt[191];
	menu_item_getinfo(gag_menu,gag_item,gag_ADMIN,gag_data,31,gag_iName,63,gag_callback);
	gag_id=str_to_num(gag_data);
	if(gag_item<7)gag_page[id]=0;
	else if(gag_item<14)gag_page[id]=1;
	else if(gag_item<21)gag_page[id]=2;
	else if(gag_item<28)gag_page[id]=3;
	else gag_page[id]=4;
	if(gag[gag_id]==true){
		gag[gag_id]=false;
		get_user_name(gag_id,name,31);
		get_user_name(id,name_admin,31);
		format(txt,190,"^x01                                  %s                       ^x04Чат разблокирован",name);
		writeMessage(id,txt,0,false);
		client_cmd(gag_id,"setinfo _ginfo false");
		log_str("[amx_ungag menu] Администратор  %s  разблокировал чат игроку  %s",name_admin,name);
	}else{
		gag[gag_id]=true;
		get_user_name(gag_id,name,31);
		get_user_name(id,name_admin,31);
		format(txt,190,"^x01                                  %s                       ^x03Чат  заблокирован",name);
		writeMessage(id,txt,1,false);
		client_cmd(gag_id,"setinfo _ginfo true");
		log_str("[amx_gag menu] Администратор  %s  заблокировал чат игроку  %s",name_admin,name);
	}
	set_task(0.0,"gag_menu",id);
	return PLUGIN_HANDLED;
}
public run_private_msg_menu(id)private_msg_menu(id,0);
public private_msg_menu(id,page){
	new pl_name[32],pl[32],private_item[100],private_num,private_cmd[5],i,private_menu;
	private_menu=menu_create("Отравить сообщение игроку:\w","private_msg_menu_actions");
	get_players(pl,private_num,"c");
	for(i=0;i<private_num;i++){
		if(is_user_connected(pl[i])){
			if(pl[i]==id)continue;
			get_user_name(pl[i],pl_name,31);
			formatex(private_cmd,4,"%i",pl[i]);
			formatex(private_item,99,"%s",pl_name);
			menu_additem(private_menu,private_item,private_cmd);
		}else continue;
	}
	if(i==1){
		menu_destroy(private_menu);
		writeMessage(id," ",0,false);
		writeMessage(id,"Некому отправить приватное сообщение.",0,false);
		writeMessage(id," ",0,false);
		return PLUGIN_HANDLED;
	}else{
		menu_display(id,private_menu,page);
	}
	return PLUGIN_HANDLED;
}
public private_msg_menu_actions(id,menu,item){
	if(item==MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[32],iName[64],ADMIN,callback;
	menu_item_getinfo(menu,item,ADMIN,data,31,iName,63,callback);
	private_player[id]=str_to_num(data);
	client_cmd(id,"messagemode private_message");
	writeMessage(id," ",0,false);
	writeMessage(id,"^x01Чтобы написать ему еще раз (не открывая заного меню), начните текст в чате так: ^x04#^x03и Ваш текст",4,false);
	writeMessage(id," ",0,false);
	return PLUGIN_HANDLED;
}
public show_private_msg(id){
	new private_text[192],str[192],private_prefix1[100],private_prefix2[100],private_txt[192],private_name1[32],private_name2[32],bool:what_gag=false;
	get_user_info(id,"_ginfo",str,sizeof(str)-1);
	if(equal(str,"true")||gag[id]==true){
		what_gag=true;
		gag[id]=true;
		client_cmd(id,"setinfo _ginfo true");
		writeMessage(id,"[Чат заблокирован]",0,false);
	}
	read_args(private_text,sizeof(private_text)-1);
	remove_quotes(private_text);
	if(equal(private_text,""))return PLUGIN_HANDLED;
	if(private_text[0]=='#'){
		private_player[id]=source_private_player[id];
		format(private_text,191,private_text[1]);
	}
	if(is_user_connected(private_player[id])){
		get_user_info(id,"_translit",str,sizeof(str)-1);
		if((equal(str,"rus")||rus_eng[id]==true)&&(!equal(str,"eng")))translit_text(private_text);
		if(is_user_alive(id)){
			private_prefix1="^x01";
			if(private_text[0]!='!'){
				for(new i=1;i<=MAX_PREFIXS;i++){
					if(get_user_flags(id)&this_flag[i]){
						format(private_prefix1,99,"^x01(^x03%s^x01)",prefixs[i]);
						break;
					}
				}
			}
		}else{
			private_prefix1="^x04*^x01Мёртв^x04* ^x01";
			if(private_text[0]!='!'){
				for(new i=1;i<=MAX_PREFIXS;i++){
					if(get_user_flags(id)&this_flag[i]){
						format(private_prefix1,99,"^x04*^x01Мёртв^x04* ^x01(^x03%s^x01)",prefixs[i]);
						break;
					}
				}
			}
		}
		get_user_name(id,private_name1,31);
		format(private_txt,192,"^x04[^x01Приватное сообщение^x04]^x01 %s %s: ^x01%s",private_prefix1,private_name1,private_text);
		if(what_gag==false){
			writeMessage(private_player[id]," ",0,false);
			writeMessage(private_player[id],"^x01Чтобы ответить, начните текст так: ^x04##^x03и Ваш текст",4,false);
			writeMessage(private_player[id],private_txt,get_color_num(id),true);
			#if defined PRIVATE_CHAT_SOUND
			client_cmd(private_player[id],"spk %s",PRIVATE_MSG_SOUND);
			#endif
			source_private_player[private_player[id]]=id;
		}
		private_prefix2="^x01";
		for(new i=1;i<=MAX_PREFIXS;i++){
			if(get_user_flags(private_player[id])&this_flag[i]){
				format(private_prefix2,99,"^x01(^x03%s^x01)",prefixs[i]);
				break;
			}
		}
		get_user_name(private_player[id],private_name2,31);
		format(private_txt,192,"^x04[^x01Сообщение игроку^x04]^x01 %s ^x03%s^x01: ^x01%s",private_prefix2,private_name2,private_text);
		if(what_gag==false)writeMessage(id,private_txt,get_color_num(private_player[id]),true);
		get_user_name(id,private_name1,31);
		switch(get_color_num(id)){
			case 1:format(private_name1,31,"(te) %s",private_name1);
			case 2:format(private_name1,31,"(ct) %s",private_name1);
			case 3:format(private_name1,31,"(spec) %s",private_name1);
			case 0:format(private_name1,31,"(spec) %s",private_name1);
		}
		for(new i=1;i<=32;i++){
			if((is_user_connected(i))&&((get_user_flags(i)&ADMIN_LISTEN)&&i!=id)){
				if(what_gag==false && i!=private_player[id]){
					format(private_txt,192,"^x04[private] ^x01%s игроку ^x03%s %s: %s",private_name1,private_prefix2,private_name2,private_text);
					writeMessage(i,private_txt,get_color_num(private_player[id]),true);
				}else if(what_gag==true){
					format(private_txt,192,"^x04[blocked] ^x01%s игроку ^x03%s %s: %s",private_name1,private_prefix2,private_name2,private_text);
					writeMessage(i,private_txt,get_color_num(private_player[id]),true);
				}
			}
		}
		get_user_name(private_player[id],private_name2,31);
		switch(get_color_num(private_player[id])){
			case 1:format(private_name2,31,"(te) %s",private_name2);
			case 2:format(private_name2,31,"(ct) %s",private_name2);
			case 3:format(private_name2,31,"(spec) %s",private_name2);
			case 0:format(private_name2,31,"(spec) %s",private_name2);
		}
		if(what_gag==false)format(private_txt,192,"    [приватное сообщение] - %s %s  игроку  %s %s:^n      %s",private_prefix1,private_name1,private_prefix2,private_name2,private_text);
		else format(private_txt,192,"    Заблокировано [приватное сообщение] - %s %s  игроку  %s %s:^n      %s",private_prefix1,private_name1,private_prefix2,private_name2,private_text);
		server_print(" ");
		log_str("%s",private_txt);
		server_print(" ");
	}else{
		writeMessage(id," ",0,false);
		writeMessage(id,"                                                  Игрок не найден",0,false);
		writeMessage(id," ",0,false);
	}
	return PLUGIN_HANDLED;
}
public hud_by_@(id){
	set_hudmessage(hud_msg_col_settings[id][0],hud_msg_col_settings[id][1],hud_msg_col_settings[id][2],hud_msg_pos_settings[id][0],hud_msg_pos_settings[id][1],0,_,0.5,_,_,-1);
	show_hudmessage(0,"%s",hud_msg[id]);
}
public after_ip_actions(id,arg_message[],arg_name[]){
	new ip_message[192],name[32],str[20];
	format(ip_message,191,"%s",arg_message);
	format(name,31,"%s",arg_name);
	get_user_info(id,"_translit",str,sizeof(str)-1);
	if(equal(str,"rus")||(rus_eng[id]==true&&(!equal(str,"eng"))))translit_text(ip_message);
	for(new i=1;i<=MAX_PREFIXS;i++){
		if(get_user_flags(id)&this_flag[i]){
			format(prefix,99,"(%s)",prefixs[i]);
			break;
		}
	}
	writeMessage(id,"^x03Запрещено анонсировать ip адреса.",1,true);
	#if defined ERROR_SOUND
	client_cmd(id,"spk %s",ERROR_MSG_SOUND);
	#endif
	log_str("[Попытка анонсировать ip]  Игроком  %s %s: %s",prefix,name,ip_message);
	for(new i=1;i<=32;i++)if(is_user_connected(i)&&(i!=id)&&(get_user_flags(i)&ADMIN__ADMIN)){
		format(ip_message,191,"^x03[^x01Админский чат^x03]^x01:  Попытка анонсировать ^x03ip ^x01игроком ^x04%s",name);
		writeMessage(i,ip_message,1,true);
		#if defined ADMIN_CHAT_SOUND
		client_cmd(i,"spk %s",ADMIN_CHAT_MSG_SOUND);
		#endif
	}
}
public show_translit_eng(id){
	writeMessage(id," ",0,false);
	writeMessage(id,"^x03Включен ^x04английский ^x03чат. Для перевода на ^x01русский ^x03пиши ^x04/rus",3,false);
	#if defined TRANSLIT_SOUND
	client_cmd(id,"spk %s",TRANSLIT_MSG_SOUND);
	#endif
}
public show_translit_rus(id){
	writeMessage(id," ",0,false);
	writeMessage(id,"^x03Включен ^x04русский ^x03чат. Для перевода на ^x01английский ^x03пиши ^x04/eng",3,false);
	writeMessage(id,"^x03Буква ^x01ж^x03 пишется через ^x04ВЕРХНИЙ ^x03регистр (т.е. заглавной буквой).",3,false); //Неисправимый баг. ";" воспринимается как ","
	#if defined TRANSLIT_SOUND
	client_cmd(id,"spk %s",TRANSLIT_MSG_SOUND);
	#endif
}
public hook_say(id){
	read_args(message,191);
	remove_quotes(message);
	replace_all(message,sizeof(message)-1,"%S","");
	replace_all(message,sizeof(message)-1,"%s","");
	replace_all(message,sizeof(message)-1,"%Z","");
	replace_all(message,sizeof(message)-1,"%z","");
	if(equal(message,""))return PLUGIN_HANDLED;
	flood_time[id]=get_gametime();
	if(flood_time[id]-old_time[id]<get_pcvar_float(dont_flood_time)){
		flood_warning[id]++;
		if(flood_warning[id]>1){
			old_time[id]=flood_time[id]+2.0;
			writeMessage(id,"^x03Вы отправляете сообщения слишком быстро.",1,false);
			#if defined ERROR_SOUND
			client_cmd(id,"spk %s",ERROR_MSG_SOUND);
			#endif
			return PLUGIN_HANDLED_MAIN;
		}
	}else flood_warning[id]=0;
	old_time[id]=flood_time[id];
	new name[32],str[20],integer;
	get_user_name(id,name,31);
	for(new num_ip=0;num_ip<sizeof(chars_ip);num_ip++){
		format(str_ip,161,"(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\%s(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\%s(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\%s(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)",chars_ip[num_ip],chars_ip[num_ip],chars_ip[num_ip]);
		is_ip=regex_match(message,str_ip,integer,str_txt,63);
		if(is_ip){
			if(!(get_user_flags(id)&ADMIN_ACCESS)){
				after_ip_actions(id,message,name);
				regex_free(is_ip);
				return PLUGIN_HANDLED_MAIN;
			}
		}
	}
	if(max_ignore_msg){
		for(integer=1;integer<=max_ignore_msg;integer++){
			if(equal(message,ignore_msg[integer],strlen(ignore_msg[integer]))){
				if(get_pcvar_num(admin_listen_look_hide_msg)>1){
					for(new i=1;i<=32;i++){
						if(is_user_connected(i)&&(get_user_flags(i)&ADMIN_LISTEN)&&i!=id){
							new text[192];
							format(text,191,"^x03%s^x01: %s",name,message);
							writeMessage(i,text,get_color_num(id),true);
						}
					}
				}
				if(get_pcvar_num(log_ignore_msg))log_str("    [Вырезанный текст] %s: %s",name,message);
				else log_amx("    [Вырезанный текст] %s: %s",name,message);
				return PLUGIN_HANDLED_MAIN;
			}
		}
	}
	translit=true;
	if(message[0]=='/'){ //Блокировка сообщений, если текст начат с этого (P.S. они блокируются только для данного плагина).
		translit=false;
		if(get_pcvar_num(hide_commands)){
			if(get_pcvar_num(log_hide_msg))log_str("    [Скрытый текст] %s: %s",name,message);
			else log_amx("    [Скрытый текст] %s: %s",name,message);
			if(0<get_pcvar_num(admin_listen_look_hide_msg)<3){
				for(new i=1;i<=32;i++){
					if(is_user_connected(i)&&(get_user_flags(i)&ADMIN_LISTEN)&&i!=id){
						new text[192];
						format(text,191,"^x03%s^x01: %s",name,message);
						writeMessage(i,text,get_color_num(id),true);
					}
				}
			}
		}
		if(equal(message[1],"rus")){
			rus_eng[id]=true;
			client_cmd(id,"setinfo _translit rus");
			set_task(0.1,"show_translit_rus",id);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}else if(equal(message[1],"eng")){
			rus_eng[id]=false;
			client_cmd(id,"setinfo _translit eng");
			set_task(0.1,"show_translit_eng",id);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}else if(equal(message[1],"pm")){
			run_private_msg_menu(id);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}
		#if defined CHAT_SOUND_SEND_MSG || defined CHAT_SOUND_READ_MSG
		else if(equal(message[1],"soff")){
			snd_play[id]=false;
			client_cmd(id,"setinfo _s_chat off");
			writeMessage(id," ",0,false);
			writeMessage(id,"^x03Звук чата ^x04отключен",3,false);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}else if(equal(message[1],"son")){
			snd_play[id]=true;
			client_cmd(id,"setinfo _s_chat on");
			client_cmd(id,"spk %s",SEND_MSG_SOUND);
			writeMessage(id," ",0,false);
			writeMessage(id,"^x03Звук чата ^x04включен",3,false);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}
		#endif
		if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
	}
	if(message[0]==LEFT_SLASH){ //Можно посылать команды через чат, если начать текст с символа "\".
		if(message[1]==LEFT_SLASH && get_user_flags(id)&(ADMIN_ACCESS|ADMIN_LEVEL_G)){ //Если иметь доступ, то можно посылать команду через сервер, начав текст с "\\".
			client_cmd(id,"echo %s",message[2]);
			client_print(id,print_chat,"[Команда серверу]: %s",message[2]);
			server_cmd(message[2]);
			if(get_pcvar_num(log_console_cmd_from_chat))log_str("[Команда серверу через чат] %s: <%s>",name,message[2]);
		}else{
			client_print(id,print_chat,"[Команда в консоль]: %s",message[1]);
			client_cmd(id,message[1]);
			if(get_pcvar_num(log_console_cmd_from_chat)==2)log_str("[Команда через чат] %s: <%s>",name,message[1]);
			else log_amx("[Команда через чат] %s: <%s>",name,message[1]);
			for(new i=1;i<=32;i++){
				if((is_user_connected(i)&&(get_user_flags(i)&ADMIN_LISTEN))&&i!=id){
					new text[192];
					format(text,191,"^x03%s^x01: %s",name,message);
					writeMessage(i,text,get_color_num(id),true);
				}
			}
		}
		return PLUGIN_HANDLED_MAIN;
	}
	get_user_info(id,"_ginfo",str,sizeof(str)-1);
	if(equal(str,"true")||gag[id]==true){
		writeMessage(id,"[Чат заблокирован]",0,false);
		gag[id]=true;
		client_cmd(id,"setinfo _ginfo true");
		return PLUGIN_HANDLED_MAIN;
	}
	if(message[0]=='#'){
		client_cmd(id,"private_message ^"%s^"",message[1]);
		return PLUGIN_HANDLED_MAIN;
	}
	if(message[0]=='@'&&(get_user_flags(id)&ADMIN_RESERVATION)){
		new said[6],ii=0;
		read_argv(1,said,5);
		while(said[ii]=='@')ii++;
		if(!(!ii||ii>3)){
			new a=0;
			switch(said[ii]){case 'r':a=1;case 'g':a=2;case 'b':a=3;case 'y':a=4;case 'p':a=5;case 'c':a=6;case 'o':a=7;}
			new n,s=ii;
			if(a){n++;s++;}
			while(said[s]&&isspace(said[s])){n++;s++;}
			format(message,190,"%s",message[ii+n]);
			get_user_info(id,"_translit",str,sizeof(str)-1);
			if(equal(str,"rus")||(rus_eng[id]==true&&(!equal(str,"eng"))))translit_text(message);
			log_str("[Сообщение на экран] %s: ^"%s^" (цвет ^"%s^")",name,message,Color[a]);
			if(++msgChannel>6||msgChannel<3)msgChannel=3;
			new Float:verpos=Pos[ii][1]+float(msgChannel)/35.0;
			format(hud_msg[id],191,"%s :   %s",name,message);
			hud_msg_col_settings[id][0]=Values[a][0];
			hud_msg_col_settings[id][1]=Values[a][1];
			hud_msg_col_settings[id][2]=Values[a][2];
			hud_msg_pos_settings[id][0]=Pos[ii][0];
			hud_msg_pos_settings[id][1]=verpos;
			set_hudmessage(Values[a][0],Values[a][1],Values[a][2],Pos[ii][0],verpos,0,_,0.5,_,_,-1);
			show_hudmessage(0,"%s",hud_msg[id]);
			client_print(0,print_notify,"%s",hud_msg[id]);
			set_task(0.5,"hud_by_@",id,_,_,"a",20); //Поскольку сообщение быстро исчезает (из-за сторонних плагинов), то сделан показ (с обновлением) с периодом в 0.5 сек. в течении 10 секунд.
			return PLUGIN_HANDLED_MAIN;
		}
	}
	if(max_dont_translit){
		for(integer=1;integer<=max_dont_translit;integer++){
			if(equal(message,dont_translit[integer],strlen(dont_translit[integer]))){
				translit=false;
				break;
			}
		}
	}
	get_user_info(id,"_translit",str,sizeof(str)-1);
	if(translit==true)if((equal(str,"rus")||(rus_eng[id]==true &&(!equal(str,"eng")))))translit_text(message);
	translit=true;
	new IsUserAlive;
	if(is_user_alive(id)){
		IsUserAlive=1;
		prefix="^x01";
		if(message[0]!='!'){
			for(new i=1;i<=MAX_PREFIXS;i++){
				if(get_user_flags(id)&this_flag[i]){
					format(prefix,99,"^x01[^x03%s^x01] ",prefixs[i]);
					break;
				}
			}
		}
	}else{
		IsUserAlive=0;
		prefix="^x01*Мёртв* ";
		if(message[0]!='!'){
			for(new i=1;i<=MAX_PREFIXS;i++){
				if(get_user_flags(id)&this_flag[i]){
					format(prefix,99,"^x04*^x01Мёртв^x04* ^x01[^x03%s^x01] ",prefixs[i]);
					break;
				}
			}
		}
	}
	new color;
	if(get_user_flags(id)&ADMIN_ACCESS&&message[0]!='!'){
		switch(get_pcvar_num(name_color)){
			case 1:format(stringName,191,"%s^x01%s",prefix,name);
			case 2:format(stringName,191,"%s^x04%s",prefix,name);
			case 3:{color=3;format(stringName,191,"%s^x03%s",prefix,name);}
			case 4:{color=2;format(stringName,191,"%s^x03%s",prefix,name);}
			case 5:{color=1;format(stringName,191,"%s^x03%s",prefix,name);}
			case 6:{color=get_color_num(id);format(stringName,191,"%s^x03%s",prefix,name);}
		}
		switch (get_pcvar_num(text_color)){
			case 1:format(stringText,191,"^x01%s",message);
			case 2:format(stringText,191,"^x04%s",message);
			case 3:{color=3;format(stringText,191,"^x03%s",message);}
			case 4:{color=2;format(stringText,191,"^x03%s",message);}
			case 5:{color=1;format(stringText,191,"^x03%s",message);}
		}
	}else{
		color=get_color_num(id);
		if(message[0]=='!'){
			format(stringName,191,"%s^x03%s",prefix,name);
			format(stringText,191,"%s",message[1]);
		}else{
			format(stringName,191,"%s^x03%s",prefix,name);
			format(stringText,191,"%s",message);
		}
	}
	format(message,191,"%s^x01:  %s",stringName,stringText);
	sendMessage(color,IsUserAlive,id);
	return PLUGIN_HANDLED_MAIN;
}
public hook_teamsay(id){
	read_args(message,191);
	remove_quotes(message);
	replace_all(message,sizeof(message)-1,"%S","");
	replace_all(message,sizeof(message)-1,"%s","");
	replace_all(message,sizeof(message)-1,"%Z","");
	replace_all(message,sizeof(message)-1,"%z","");
	if(equal(message,""))return PLUGIN_HANDLED;
	flood_time[id]=get_gametime();
	if(flood_time[id]-old_time[id]<get_pcvar_float(dont_flood_time)){
		flood_warning[id]++;
		if(flood_warning[id]>1){
			old_time[id]=flood_time[id]+2.0;
			writeMessage(id,"^x03Вы отправляете сообщения слишком быстро.",1,false);
			#if defined ERROR_SOUND
			client_cmd(id,"spk %s",ERROR_MSG_SOUND);
			#endif
			return PLUGIN_HANDLED_MAIN;
		}
	}else flood_warning[id]=0;
	old_time[id]=flood_time[id];
	new name[32],str[20],team_color[10],integer;
	get_user_team(id,team_color,9);
	get_user_name(id,name,31);
	for(new num_ip=0;num_ip<sizeof(chars_ip);num_ip++){
		format(str_ip,161,"(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\%s(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\%s(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\%s(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)",chars_ip[num_ip],chars_ip[num_ip],chars_ip[num_ip]);
		is_ip=regex_match(message,str_ip,integer,str_txt,63);
		if(is_ip){
			if(!(get_user_flags(id)&ADMIN_ACCESS)){
				after_ip_actions(id,message,name);
				regex_free(is_ip);
				return PLUGIN_HANDLED_MAIN;
			}
		}
	}
	if(max_ignore_msg){
		for(integer=1;integer<=max_ignore_msg;integer++){
			if(equal(message,ignore_msg[integer],strlen(ignore_msg[integer]))){
				if(get_pcvar_num(admin_listen_look_hide_msg)>1){
					for(new i=1;i<=32;i++){
						if(is_user_connected(i)&&(get_user_flags(i)&ADMIN_LISTEN)&&i!=id){
							new text[192];
							format(text,191,"(team) ^x03%s^x01: %s",name,message);
							writeMessage(i,text,get_color_num(id),true);
						}
					}
				}
				if(get_pcvar_num(log_ignore_msg))log_str("    [Вырезанный текст] %s: %s",name,message);
				else log_amx("    [Вырезанный текст] %s: %s",name,message);
				return PLUGIN_HANDLED_MAIN;
			}
		}
	}
	translit=true;
	if(message[0]=='/'){ //Блокировка сообщений, если текст начат с этого (P.S. они блокируются только для данного плагина).
		translit=false;
		if(get_pcvar_num(hide_commands)){
			if(get_pcvar_num(log_hide_msg))log_str("    [Скрытый текст] %s: %s",name,message);
			else log_amx("    [Скрытый текст] %s: %s",name,message);
			if(0<get_pcvar_num(admin_listen_look_hide_msg)<3){
				for(new i=1;i<=32;i++){
					if(is_user_connected(i)&&(get_user_flags(i)&ADMIN_LISTEN)){
						new text[192];
						format(text,191,"(team) ^x03%s^x01: %s",name,message);
						writeMessage(i,text,get_color_num(id),true);
					}
				}
			}
		}
		if(equal(message[1],"rus")){
			rus_eng[id]=true;
			client_cmd(id,"setinfo _translit rus");
			set_task(0.1,"show_translit_rus",id);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}else if(equal(message[1],"eng")){
			rus_eng[id]=false;
			client_cmd(id,"setinfo _translit eng");
			set_task(0.1,"show_translit_eng",id);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}else if(equal(message[1],"pm")){
			run_private_msg_menu(id);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}
		#if defined CHAT_SOUND_SEND_MSG || defined CHAT_SOUND_READ_MSG
		else if(equal(message[1],"soff")){
			snd_play[id]=false;
			client_cmd(id,"setinfo _s_chat off");
			writeMessage(id," ",0,false);
			writeMessage(id,"^x03Звук чата ^x04отключен",3,false);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}else if(equal(message[1],"son")){
			snd_play[id]=true;
			client_cmd(id,"setinfo _s_chat on");
			client_cmd(id,"spk %s",SEND_MSG_SOUND);
			writeMessage(id," ",0,false);
			writeMessage(id,"^x03Звук чата ^x04включен",3,false);
			if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
		}
		#endif
		if(get_pcvar_num(hide_commands))return PLUGIN_HANDLED_MAIN;
	}
	if(message[0]==LEFT_SLASH){
		if(message[1]==LEFT_SLASH && get_user_flags(id)&(ADMIN_ACCESS|ADMIN_LEVEL_G)){ //Если иметь доступ, то можно посылать команду через сервер, начав текст с "\\".
			client_cmd(id,"echo %s",message[2]);
			client_print(id,print_chat,"[Команда серверу]: %s",message[2]);
			server_cmd(message[2]);
			if(get_pcvar_num(log_console_cmd_from_chat))log_str("[Команда серверу через чат] %s: <%s>",name,message[2]);
		}else{
			client_print(id,print_chat,"[Команда в консоль]: %s",message[1]);
			client_cmd(id,message[1]);
			if(get_pcvar_num(log_console_cmd_from_chat)==2)log_str("[Команда через чат] %s: <%s>",name,message[1]);
			else log_amx("[Команда через чат] %s: <%s>",name,message[1]);
			for(new i=1;i<=32;i++){
				if(is_user_connected(i)&&(get_user_flags(i)&ADMIN_LISTEN)&&i!=id){
					new text[192];
					format(text,191,"^x03%s^x01: %s",name,message);
					writeMessage(i,text,get_color_num(id),true);
				}
			}
		}
		return PLUGIN_HANDLED_MAIN;
	}
	get_user_info(id,"_ginfo",str,sizeof(str)-1);
	if(equal(str,"true")||gag[id]==true){
		writeMessage(id,"[Чат заблокирован]",0,false);
		gag[id]=true;
		client_cmd(id,"setinfo _ginfo true");
		return PLUGIN_HANDLED_MAIN;
	}
	if(message[0]=='#'){
		client_cmd(id,"private_message ^"%s^"",message[1]);
		return PLUGIN_HANDLED_MAIN;
	}
	if(message[0]=='@'){
		new bool:inkognito;
		if(message[1]==0)return PLUGIN_HANDLED_MAIN;
		else if(message[1]=='!')inkognito=true;
		get_user_info(id,"_translit",str,sizeof(str)-1);
		if(translit==true){
			if((equal(str,"rus")||(rus_eng[id]==true &&(!equal(str,"eng"))))){
				translit_text(message);
				format(message,191,"%s",message[1]); //Если язык русский, убирает первый апостроф, полученный в результате замены кавычек в функции translit_text.
			}
		}
		format(message,191,"%s",message[1]); //Убирает кавычку (если язык английский) или второй апостроф (если язык был русский).
		new msg[192];
		if(inkognito){
			format(msg,191,"^x04[^x01Отправлено админам^x04] ^x03!^x01: %s",message[1]);
			writeMessage(id,msg,1,true);
			format(msg,191,"^x04[^x01Админский чат^x04]^x03 %s:^x01 %s",name,message[1]);
		}else{
			format(msg,191,"^x04[^x01Отправлено админам^x04]^x01: %s",message);
			writeMessage(id,msg,0,false);
			format(msg,191,"^x04[^x01Админский чат^x04]^x03 %s:^x01 %s",name,message);
			for(new i=1;i<=MAX_PREFIXS;i++){
				if(get_user_flags(id)&this_flag[i]){
					format(msg,191,"^x04[^x01Админский чат^x04] ^x01(^x03%s^x01) ^x04%s^x01: %s",prefixs[i],name,message);
					break;
				}
			}
		}
		for(new i=1;i<=32;i++)if(is_user_connected(i)&&(i!=id)&&(get_user_flags(i)&ADMIN__ADMIN)){
			writeMessage(i,msg,get_color_num(id),true);
			#if defined ADMIN_CHAT_SOUND
			client_cmd(i,"spk %s",ADMIN_CHAT_MSG_SOUND);
			#endif
		}
		log_str("%s",msg);
		return PLUGIN_HANDLED_MAIN;
	}
	if(max_dont_translit){
		for(integer=1;integer<=max_dont_translit;integer++){
			if(equal(message,dont_translit[integer],strlen(dont_translit[integer]))){
				translit=false;
				break;
			}
		}
	}
	get_user_info(id,"_translit",str,sizeof(str)-1);
	if(translit==true)if((equal(str,"rus")||(rus_eng[id]==true &&(!equal(str,"eng")))))translit_text(message);
	translit=true;
	new IsUserAlive,playerTeam;
	if(equal(team_color,"T",1))playerTeam=1;
	else if(equal(team_color,"C",1))playerTeam=2;
	else playerTeam=3;
	get_user_name(id,name,31);
	switch(playerTeam){
		case 1:{
			if(is_user_alive(id)){
				IsUserAlive=1;
				prefix="^x01(Террам) ";
				if(message[0]!='!'){
					for(new i=1;i<=MAX_PREFIXS;i++){
						if(get_user_flags(id)&this_flag[i]){
							format(prefix,99,"^x01(Террам) [^x03%s^x01]",prefixs[i]);
							break;
						}
					}
				}
			}else{
				IsUserAlive=0;
				prefix="^x01(Террам) *Мёртв*";
				if(message[0]!='!'){
					for(new i=1;i<=MAX_PREFIXS;i++){
						if(get_user_flags(id)&this_flag[i]){
							format(prefix,99,"^x01(Террам) ^x04*^x01Мёртв^x04* ^x01[^x03%s^x01]",prefixs[i]);
							break;
						}
					}
				}
			}
		}case 2:{
			if(is_user_alive(id)){
				IsUserAlive=1;
				prefix="^x01(Ментам) ";
				if(message[0]!='!'){
					for(new i=1;i<=MAX_PREFIXS;i++){
						if(get_user_flags(id)&this_flag[i]){
							format(prefix,99,"^x01(Ментам) [^x03%s^x01]",prefixs[i]);
							break;
						}
					}
				}
			}else{
				IsUserAlive=0;
				prefix="^x01(Ментам) *Мёртв*";
				if(message[0]!='!'){
					for(new i=1;i<=MAX_PREFIXS;i++){
						if(get_user_flags(id)&this_flag[i]){
							format(prefix,99,"^x01(Ментам) ^x04*^x01Мёртв^x04* ^x01[^x03%s^x01]",prefixs[i]);
							break;
						}
					}
				}
			}
		}case 3:{
			if(is_user_alive(id)){
				IsUserAlive=1;
				prefix="^x01(Наблюдателям) ";
				if(message[0]!='!'){
					for(new i=1;i<=MAX_PREFIXS;i++){
						if(get_user_flags(id)&this_flag[i]){
							format(prefix,99,"^x01(Наблюдателям) [^x03%s^x01]",prefixs[i]);
							break;
						}
					}
				}
			}else{
				IsUserAlive=0;
				prefix="^x01(Наблюдателям) *Мёртв*";
				if(message[0]!='!'){
					for(new i=1;i<=MAX_PREFIXS;i++){
						if(get_user_flags(id)&this_flag[i]){
							format(prefix,99,"^x01(Наблюдателям)  ^x04*^x01Мёртв^x04* ^x01[^x03%s^x01]",prefixs[i]);
							break;
						}
					}
				}
			}
		}
	}
	new color;
	if(get_user_flags(id)&ADMIN_ACCESS&&message[0]!='!'){
		switch(get_pcvar_num(name_color)){
			case 1:format(stringName,191,"%s ^x01%s",prefix,name);
			case 2:format(stringName,191,"%s ^x04%s",prefix,name);
			case 3:{color=3;format(stringName,191,"%s ^x03%s",prefix,name);}
			case 4:{color=2;format(stringName,191,"%s ^x03%s",prefix,name);}
			case 5:{color=1;format(stringName,191,"%s ^x03%s",prefix,name);}
			case 6:{color=get_color_num(id);format(stringName,191,"%s ^x03%s",prefix,name);}
		}
		switch(get_pcvar_num(text_color)){
			case 1:format(stringText,191,"^x01%s",message);
			case 2:format(stringText,191,"^x04%s",message);
			case 3:{color=3;format(stringText,191,"^x03%s",message);}
			case 4:{color=2;format(stringText,191,"^x03%s",message);}
			case 5:{color=1;format(stringText,191,"^x03%s",message);}
		}
	}else{
		color=get_color_num(id);
		if(message[0]=='!'){
			format(stringName,191,"%s ^x03%s",prefix,name);
			format(stringText,191,"%s",message[1]);
		}else{
			format(stringName,191,"%s ^x03%s",prefix,name);
			format(stringText,191,"%s",message);
		}
	}
	format(message,191,"%s^x01:  %s",stringName,stringText);
	sendTeamMessage(color,IsUserAlive,playerTeam,id);
	return PLUGIN_HANDLED_MAIN;
}
public set_msg_color(id,level,cid){
	if(!cmd_access(id,level,cid,2))return PLUGIN_HANDLED;
	new arg[1],newColor;
	read_argv(1,arg,1);
	newColor=str_to_num(arg);
	if(newColor>0&&newColor<6){
		set_cvar_num("amx_textcolor",newColor);
		set_pcvar_num(text_color,newColor);
		new N_Color;
		N_Color=get_pcvar_num(name_color);
		if(N_Color!=1&&((newColor==3&&N_Color!=3)||(newColor==4&&N_Color!=4)||(newColor==5&&N_Color!=5))){
			set_cvar_num("amx_namecolor",2);
			set_pcvar_num(name_color,2);
		}
	}
	return PLUGIN_HANDLED;
}
public set_name_color(id,level,cid){
	if(!cmd_access(id,level,cid,2))return PLUGIN_HANDLED;
	new arg[1],newColor;
	read_argv(1,arg,1);
	newColor=str_to_num(arg);
	if(newColor>0&&newColor<7){
		set_cvar_num("amx_namecolor",newColor);
		set_pcvar_num(name_color,newColor);
		new M_Color;
		M_Color=get_pcvar_num(text_color);
		if((M_Color!=1&&((newColor==3&&M_Color!=3)||(newColor==4&&M_Color!=4)||(newColor==5&&M_Color!= 5)))||get_pcvar_num(name_color)==6){
			set_cvar_num("amx_textcolor",2);
			set_pcvar_num(text_color,2);
		}
	}
	return PLUGIN_HANDLED;
}
public sendMessage(color,IsUserAlive,id){
	#if defined CHAT_SOUND_SEND_MSG || defined CHAT_SOUND_READ_MSG
	new user_info[20];
	#endif
	log_str("%s",message);
	#if defined CHAT_SOUND_SEND_MSG
	get_user_info(id,"_s_chat",user_info,sizeof(user_info)-1);
	if(equal(user_info,"on")||snd_play[id]==true)client_cmd(id,"spk %s",SEND_MSG_SOUND);
	#endif
	writeMessage(id,message,color,true);
	switch(get_pcvar_num(all_chat)){
		case 1:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(id==player)continue;
				if((IsUserAlive==is_user_alive(player))||get_user_flags(player)&ADMIN_LISTEN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_MSG_SOUND);
					#endif
				}
			}
		}
		case 2:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(id==player)continue;
				if((IsUserAlive==is_user_alive(player))||get_user_flags(player)&ADMIN_LISTEN||get_user_flags(id)&ADMIN__ADMIN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_MSG_SOUND);
					#endif
				}
			}
		}
		case 3:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(id==player)continue;
				if((!(IsUserAlive<is_user_alive(player)))||get_user_flags(player)&ADMIN_LISTEN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_MSG_SOUND);
					#endif
				}
			}
		}
		case 4:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(id==player)continue;
				if((!(IsUserAlive<is_user_alive(player)))||get_user_flags(player)&ADMIN_LISTEN||get_user_flags(id)&ADMIN__ADMIN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_MSG_SOUND);
					#endif
				}
			}
		}
		case 5:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(id==player)continue;
				writeMessage(player,message,color,true);
				#if defined CHAT_SOUND_READ_MSG
				get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
				if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_MSG_SOUND);
				#endif
			}
		}
	}
	return PLUGIN_HANDLED;
}
public sendTeamMessage(color,IsUserAlive,playerTeam,id){
	#if defined CHAT_SOUND_SEND_MSG || defined CHAT_SOUND_READ_MSG
	new user_info[20];
	#endif
	log_str("%s",message);
	#if defined CHAT_SOUND_SEND_MSG
	get_user_info(id,"_s_chat",user_info,sizeof(user_info)-1);
	if(equal(user_info,"on")||snd_play[id]==true)client_cmd(id,"spk %s",SEND_MSG_SOUND);
	#endif
	writeMessage(id,message,color,true);
	switch(get_pcvar_num(all_chat)){
		case 1:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(!(get_user_team(player)==playerTeam||get_user_flags(player)&ADMIN_LISTEN))continue;
				if(id==player)continue;
				if((IsUserAlive==is_user_alive(player))||get_user_flags(player)&ADMIN_LISTEN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_TEAM_MSG_SOUND);
					#endif
				}
			}
		}
		case 2:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(!(get_user_team(player)==playerTeam||get_user_flags(player)&ADMIN_LISTEN))continue;
				if(id==player)continue;
				if((IsUserAlive==is_user_alive(player))||get_user_flags(player)&ADMIN_LISTEN||get_user_flags(id)&ADMIN__ADMIN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_TEAM_MSG_SOUND);
					#endif
				}
			}
		}
		case 3:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(!(get_user_team(player)==playerTeam||get_user_flags(player)&ADMIN_LISTEN))continue;
				if(id==player)continue;
				if((!(IsUserAlive<is_user_alive(player)))||get_user_flags(player)&ADMIN_LISTEN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_TEAM_MSG_SOUND);
					#endif
				}
			}
		}
		case 4:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(!(get_user_team(player)==playerTeam||get_user_flags(player)&ADMIN_LISTEN))continue;
				if(id==player)continue;
				if((!(IsUserAlive<is_user_alive(player)))||get_user_flags(player)&ADMIN_LISTEN||get_user_flags(id)&ADMIN__ADMIN){
					writeMessage(player,message,color,true);
					#if defined CHAT_SOUND_READ_MSG
					get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
					if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_TEAM_MSG_SOUND);
					#endif
				}
			}
		}
		case 5:{
			for(new player=1;player<=maxPlayers;player++){
				if(!is_user_connected(player))continue;
				if(!(get_user_team(player)==playerTeam||get_user_flags(player)&ADMIN_LISTEN))continue;
				if(id==player)continue;
				writeMessage(player,message,color,true);
				#if defined CHAT_SOUND_READ_MSG
				get_user_info(player,"_s_chat",user_info,sizeof(user_info)-1);
				if(player!=id)if(equal(user_info,"on")||snd_play[player]==true)client_cmd(player,"spk %s",READ_TEAM_MSG_SOUND);
				#endif
			}
		}
	}
	return PLUGIN_HANDLED;
}
public get_color_num(id){
	new team[10];
	get_user_team(id,team,9);
	if(equal(team,"T",1))return 1;
	else if(equal(team,"C",1))return 2;
	else if(equal(team,"S",1))return 3;
	return 3;
}
public log_str(txt[],any:...){
	new logmsg[192],logname[64];
	vformat(logmsg,191,txt,2);
	replace_all(logmsg,191,"^x03","");
	replace_all(logmsg,191,"^x04","");
	replace_all(logmsg,191,"^x01","");
	log_amx("%s",logmsg);
	get_time("%d-%m-%Y",text_data,10);
	format(logname,63,"%s/Data__%s.txt",LOGS_DIR,text_data);
	get_time("%H:%M:%S",text_data,10);
	format(logmsg,191,"[%s] %s",text_data,logmsg);
	write_file(logname,logmsg,-1);
}
public writeMessage(player,message[],TextColor,bool:log_con){
	static bool:saytext_used;
	static sayText;
	new strtext[190],color_of_team[10],old_team_info[10],time[20];
	if(log_con){
		format_time(time,sizeof(time)-1,"[%H:%M:%S]");
		client_print(player,print_console," ");
		client_print(player,print_console,"============================================");
		client_print(player,print_console,"%s",time);
		client_print(player,print_console,"%s",message);
		client_print(player,print_console,"============================================");
		client_print(player,print_console," ");
	}
	format(strtext,189,"%s",message);
	get_user_team(player,old_team_info,9);
	if(!saytext_used){
		sayText=get_user_msgid("SayText");
		saytext_used=true;
	}
	switch(TextColor){
		case 0:{									//Без указания цвета. Избавляет (благодаря return) от некоторых лишних действий, идущих после закрытия switch.
			message_begin(MSG_ONE,sayText,_,player);
			write_byte(player);
			write_string(strtext);
			message_end();
			saytext_used=false;
			return;
		}
		case 1:color_of_team="TERRORIST";			//Красный.
		case 2:color_of_team="CT";					//Синий.
		case 3:color_of_team="SPECTATOR";			//Серый.
		case 4:color_of_team=old_team_info;			//Цвет команды.
		//В итоге цвет после тега ^x03 будет зависить от выше написанного, а именно от цвета команды.
		//Для зелёного (для тега ^x04) цвет команды не важен. Зелёный - он и в Африке зелёный...
		//Аналогично и со стандартным (по умолчанию жёлтым) цветом (тегом ^x01).
		//Поэтому можно ставить смело ноль в writeMessage, если НЕ использован в сообщении тег ^x03.
	}
	//Смена цвета команды.
	message_begin(MSG_ONE,teamInfo,_,player);
	write_byte(player);
	write_string(color_of_team);
	message_end();
	//Посылка сообщения на экран с цветом (от тега ^x03), зависящим от цвета команды.
	message_begin(MSG_ONE,sayText,_,player);
	write_byte(player);
	write_string(strtext);
	message_end();
	//Смена цвета команды обратно.
	message_begin(MSG_ONE,teamInfo,_,player);
	write_byte(player);
	write_string(old_team_info);
	message_end();
	saytext_used=false;
}
#if defined CHAT_SOUND_SEND_MSG || defined CHAT_SOUND_READ_MSG
public func_off_s(id){
	writeMessage(id," ",0,false);
	writeMessage(id,"^x03Звук чата ^x04отключен",3,false);
	writeMessage(id," ",0,false);
	snd_play[id]=false;
}
public func_on_s(id){
	writeMessage(id," ",0,false);
	writeMessage(id,"^x03Звук чата ^x04включен",3,false);
	writeMessage(id," ",0,false);
	snd_play[id]=true;
}
#endif
public reload_files(id,level,cid){
	if(!cmd_access(id,level,cid,1,false))return PLUGIN_HANDLED;
	load_f();
	return PLUGIN_HANDLED;
}
public load_f(){
	if(!file_exists("addons/amxmodx/configs/prefixs.ini"))log_amx("Не найден файл ^"addons/amxmodx/configs/prefixs.ini^"");
	else load_prefixs("addons/amxmodx/configs/prefixs.ini");
	if(!file_exists("addons/amxmodx/configs/dont_translit.ini")){
		max_dont_translit=0;
		log_amx("Не найден файл ^"addons/amxmodx/configs/dont_translit.ini^"");
	}else load_dont_translit("addons/amxmodx/configs/dont_translit.ini");
	if(!file_exists("addons/amxmodx/configs/ignore_msg.ini")){
		max_ignore_msg=0;
		log_amx("Не найден файл ^"addons/amxmodx/configs/ignore_msg.ini^"");
	}else load_ignore_msg("addons/amxmodx/configs/ignore_msg.ini");
}
public load_prefixs(file_dir[]){
	new i=1,chars_prefixs_flags[24];
	file=fopen(file_dir,"r");
	while(!feof(file)){
		text[0]='^0';
		fgets(file,text,sizeof(text)-1);
		if(!text[0]||text[0]==';'||text[0]=='/')continue;
		if(text[0]=='"'){
			if(parse(text,prefixs[i],sizeof(prefixs)-1,chars_prefixs_flags,sizeof(chars_prefixs_flags)-1)!=2)continue;
			if(contain(prefixs[i],"!t")||contain(prefixs[i],"!g")||contain(prefixs[i],"!n")){
				replace_all(prefixs[i],120,"!t","^x03");
				replace_all(prefixs[i],120,"!n","^x01");
				replace_all(prefixs[i],120,"!g","^x04");
			}
			this_flag[i]=read_flags(chars_prefixs_flags);
			i++;
			if(i==MAX_PREFIXS)break;
		}
	}
	fclose(file);
}
public load_dont_translit(file_dir[]){
	file=fopen(file_dir,"r");
	max_dont_translit=1;
	while(!feof(file)){
		text[0]='^0';
		fgets(file,text,sizeof(text)-1);
		if(!text[0]||text[0]==';'||text[0]=='/')continue;
		if(text[0]=='"'){
			parse(text,dont_translit[max_dont_translit],sizeof(dont_translit)-1);
			max_dont_translit++;
			if(max_dont_translit==MAX_DONT_TRANSLIT)break;
		}
	}
	fclose(file);
}
public load_ignore_msg(file_dir[]){
	file=fopen(file_dir,"r");
	max_ignore_msg=1;
	while(!feof(file)){
		text[0]='^0';
		fgets(file,text,sizeof(text)-1);
		if(!text[0]||text[0]==';'||text[0]=='/')continue;
		if(text[0]=='"'){
			parse(text,ignore_msg[max_ignore_msg],sizeof(ignore_msg)-1);
			max_ignore_msg++;
			if(max_ignore_msg==MAX_IGNORE_MSG)break;
		}
	}
	fclose(file);
}
public plugin_precache(){
	new snd[64];
	#if defined TRANSLIT_SOUND
	format(snd,63,"sound/%s.wav",TRANSLIT_MSG_SOUND);
	precache_generic(snd);
	#endif
	#if defined CHAT_SOUND_SEND_MSG
	format(snd,63,"sound/%s.wav",SEND_MSG_SOUND);
	precache_generic(snd);
	#endif
	#if defined CHAT_SOUND_READ_MSG
	format(snd,63,"sound/%s.wav",READ_MSG_SOUND);
	precache_generic(snd);
	format(snd,63,"sound/%s.wav",READ_TEAM_MSG_SOUND);
	precache_generic(snd);
	#endif
	#if defined PRIVATE_CHAT_SOUND
	format(snd,63,"sound/%s.wav",PRIVATE_MSG_SOUND);
	precache_generic(snd);
	#endif
	#if defined ADMIN_CHAT_SOUND
	format(snd,63,"sound/%s.wav",ADMIN_CHAT_MSG_SOUND);
	precache_generic(snd);
	#endif
	#if defined ERROR_SOUND
	format(snd,63,"sound/%s.wav",ERROR_MSG_SOUND);
	precache_generic(snd);
	#endif
}