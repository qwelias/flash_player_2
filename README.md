# Проигрыватель видео-файлов сайта AYYO

## Настройка проигрывателя
Для корректного функционирования проигрывателя, основанного на open-source коде от компании Adobe OSMF необходимо задать определенное количество переменных, которые стновятся доступными приложению посредством `flash vars`.

Субтитры по сути являются подключаемым компонентом к проигрывателю. Для того, чтобы осуществить корректную работу компонента, необходимо указать его в качестве списке `plugins`, который является частью `flash vars`.

Рассмотрим на примере публикации проигрывателя посредством `swfobject.js`:
```js
<script type="text/javascript">
var swfVersionStr = "11";
var xiSwfUrlStr = "";

var flashvars = {
	token:"begintokensessionid%3Dyb0y6wl9ki2yqlat57ulosv55bpbe9zn%2Ccontentid%3D185%2Ccountrycode%3Dru%2Cclientkey%3D6f17269e454fbbd63a1e3e9727ac89%3ASvbwhROcR1JZE6PJUJ03cAg-Qb4endtoken",
	url:"http://cdn.ayyo.ru/u23/64/f6/71a40a8b-fba7-45d4-bd1c-7893d56ebcda_ru_en.f4m",
	screenshot:"https%3A%2F%2Fmedia.ayyo.ru%2Fmovies%2F185%2Fvideo_poster%2F850x477.jpg",
	player_type:"movie",
	assets:'{"name":"arialFontFamily","url":"./assets/fonts/arial.swf","type":"font"}',
	plugins:'{"url":"file:///Users/zaynutdinov/Documents/Projects/Private/AyyoPlayer/bin/plugins/SubtitlesPlugin.swf", "config":"http://cdn.ayyo.ru/u22/ec/96/VForVendetta-Feat-PAL-16x9-2.35_Russian.srt"}',
	tooltip_play_button:"Смотреть",
	tooltip_pause_button:"Пауза",
	tooltip_license_icon:"У вас осталось N часов, чтобы посмотреть фильм",
	tooltip_timer:"Посмотреть сколько осталось",
	tooltip_timer_reverse:"Посмотреть продолжительность",
	tooltip_HQ_icon_on:"Включить отличное качество",
	tooltip_HQ_icon_off:"Включить стандартное качество",
	tooltip_sound_icon_on:"Включить звук",
	tooltip_sound_icon_off:"Выключить звук",
	tooltip_fullscreen:"Развернуть на весь экран",
	tooltip_unfullscreen:"Свернуть",
};

var params = {};
params.bgcolor = "#000000";
params.wmode = "direct";
params.allowscriptaccess = "sameDomain";
params.allowFullScreenInteractive = "true";
var attributes = {};
attributes.id = "ayyoPlayerMovie";
attributes.name = "ayyoPlayerMovie";
swfobject.createCSS("html", "height:100%; background-color: #000000;");
swfobject.createCSS("body", "margin:0; padding:0; overflow:hidden; height:100%;");
swfobject.embedSWF("AyyoPlayer-v2.0.0b1.swf", "flashContent", "852", "480",  swfVersionStr, xiSwfUrlStr, flashvars, params, attributes);
</script>
```
Из данного примера видно, что проигрывателю передается token (`token`), ссылка на проигрываемый контент (`url`), ссылка на скриншот контента (`screenshot`), тип проигрывателя (`player_type`, может быть `trailer`, `movie`), список ассетов (`assets`, в нашем случае шрифт, которым отображаются подсказки и субтитры), список подключаемых модулей (`plugins`, в нашем случае модуль субтитров) и ряд подсказок.

## Что нового?
В новой версии все параметры асболютно те же самые, что были и раньше (обратная приемственность), но добавились новые, поскольку необходимо обеспечить новый функционал. В нашем случае (build v2.01b) это `assets` и `plugins`.
+ `assets` хранит в себе список ассетов: шрифты, изображения, swf-ролики;
+ `plugins` содержит список подключаемых модулей.

## Assets
Для загрузки всех необходимых ассетов (в нашем конкретном случае шрифт) в приложении существует менеджер ассетов, который грузит все необходимое до запуска приложения. `AssetManager` поддерживает следующие типы:
- font;
- bitmap;
- swf.

`assets:'{"name":"<UNIQUE_ASSET_NAME>","url":"<ASSET_URL>","type":"<ASSET_TYPE>"}'`

### Давате рассмотрим на примере.
`assets:'{"name":"arialFontFamily","url":"./assets/fonts/arial.swf","type":"font"}'`
Что значит, проигрывателю необходимо загрузить ассет типа `font`, который находится по адресу `./assets/fonts/arial.swf` с именем `arialFontFamily`.

## Plugins
Для загрузки всех необходимых модключаемых модулей в приложении существует менеджер модулей, который грузит и инициализирует модули до старта приложения. Чтобы инициализация `PluginsManager` прошла успешно, нужно соблюсти следующие правила в формировании перемнной `plugins`:
+ указать ссылку на модуль;
+ указать ссылку на конфигурацию модуля.

`plugins:'{"url":"<PLUGIN_URL>", "config":"<PLUGIN_CONFIG_URL>"}',`

### Давайте рассмотрим на примере.
`plugins:'{"url":"file:///Users/zaynutdinov/Documents/Projects/Private/AyyoPlayer/bin/plugins/SubtitlesPlugin.swf", "config":"http://cdn.ayyo.ru/u22/ec/96/VForVendetta-Feat-PAL-16x9-2.35_Russian.srt"}'`
Что значит, проигрывателю необходимо загрузить плагин по адресу `file:///Users/zaynutdinov/Documents/Projects/Private/AyyoPlayer/bin/plugins/SubtitlesPlugin.swf`, передав ему в качестве ссылки на конфигурационный файл значение `http://cdn.ayyo.ru/u22/ec/96/VForVendetta-Feat-PAL-16x9-2.35_Russian.srt`.
