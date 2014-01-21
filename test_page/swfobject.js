/*!	SWFObject v2.2 <http://code.google.com/p/swfobject/>
	выпускается по лицензии MIT <http://www.opensource.org/licenses/mit-license.php>
*/

var swfobject = function() {

	var UNDEF = "undefined",
		OBJECT = "object",
		SHOCKWAVE_FLASH = "Shockwave Flash",
		SHOCKWAVE_FLASH_AX = "ShockwaveFlash.ShockwaveFlash",
		FLASH_MIME_TYPE = "application/x-shockwave-flash",
		EXPRESS_INSTALL_ID = "SWFObjectExprInst",
		ON_READY_STATE_CHANGE = "onreadystatechange",

		win = window,
		doc = document,
		nav = navigator,

		plugin = false,
		domLoadFnArr = [main],
		regObjArr = [],
		objIdArr = [],
		listenersArr = [],
		storedAltContent,
		storedAltContentId,
		storedCallbackFn,
		storedCallbackObj,
		isDomLoaded = false,
		isExpressInstallActive = false,
		dynamicStylesheet,
		dynamicStylesheetMedia,
		autoHideShow = true,

	/* Централизованная функция для определения возможностей обозревателя
		- Определение параметра user-agent используется, когда других вариантов нет
		- Выполняется непосредственно, повышая производительность
	*/
	ua = function() {
		var w3cdom = typeof doc.getElementById != UNDEF && typeof doc.getElementsByTagName != UNDEF && typeof doc.createElement != UNDEF,
			u = nav.userAgent.toLowerCase(),
			p = nav.platform.toLowerCase(),
			windows = p ? /win/.test(p) : /win/.test(u),
			mac = p ? /mac/.test(p) : /mac/.test(u),
			webkit = /webkit/.test(u) ? parseFloat(u.replace(/^.*webkit\/(\d+(\.\d+)?).*$/, "$1")) : false, // возвращает версию webkit или ошибку, если webkit отсутствует
			ie = !+"\v1", // определение возможности основано на решении Андреа Джаммарки (Andrea Giammarchi): http://webreflection.blogspot.com/2009/01/32-bytes-to-know-if-your-browser-is-ie.html
			playerVersion = [0,0,0],
			d = null;
		if (typeof nav.plugins != UNDEF && typeof nav.plugins[SHOCKWAVE_FLASH] == OBJECT) {
			d = nav.plugins[SHOCKWAVE_FLASH].description;
			if (d && !(typeof nav.mimeTypes != UNDEF && nav.mimeTypes[FLASH_MIME_TYPE] && !nav.mimeTypes[FLASH_MIME_TYPE].enabledPlugin)) { // navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin определяет, включена или нет поддержка подключаемых модулей в Safari 3+
				plugin = true;
				ie = false; // определение каскадных возможностей для Internet Explorer
				d = d.replace(/^.*\s+(\S+\s+\S+$)/, "$1");
				playerVersion[0] = parseInt(d.replace(/^(.*)\..*$/, "$1"), 10);
				playerVersion[1] = parseInt(d.replace(/^.*\.(.*)\s.*$/, "$1"), 10);
				playerVersion[2] = /[a-zA-Z]/.test(d) ? parseInt(d.replace(/^.*[a-zA-Z]+(.*)$/, "$1"), 10) : 0;
			}
		}
		else if (typeof win.ActiveXObject != UNDEF) {
			try {
				var a = new ActiveXObject(SHOCKWAVE_FLASH_AX);
				if (a) { // если ActiveX отключен, то "a" примет значение null
					d = a.GetVariable("$version");
					if (d) {
						ie = true; // определение каскадных возможностей для Internet Explorer
						d = d.split(" ")[1].split(",");
						playerVersion = [parseInt(d[0], 10), parseInt(d[1], 10), parseInt(d[2], 10)];
					}
				}
			}
			catch(e) {}
		}
		return { w3:w3cdom, pv:playerVersion, wk:webkit, ie:ie, win:windows, mac:mac };
	}(),

	/* Мультибраузерное событие onDomLoad
		- Событие произойдет, как только завершится загрузка DOM веб-страницы
		- В основе решения проблемы с Internet Explorer лежит идея Диего Перини (Diego Perini): http://javascript.nwbox.com/IEContentLoaded/
		- Постоянная проверка события onload служит в качестве защиты от сбоев
	*/
	onDomLoad = function() {
		if (!ua.w3) { return; }
		if ((typeof doc.readyState != UNDEF && doc.readyState == "complete") || (typeof doc.readyState == UNDEF && (doc.getElementsByTagName("body")[0] || doc.body))) { // функция выполняется после загрузки страницы, т.е. после динамической вставки сценария
			callDomLoadFunctions();
		}
		if (!isDomLoaded) {
			if (typeof doc.addEventListener != UNDEF) {
				doc.addEventListener("DOMContentLoaded", callDomLoadFunctions, false);
			}
			if (ua.ie && ua.win) {
				doc.attachEvent(ON_READY_STATE_CHANGE, function() {
					if (doc.readyState == "complete") {
						doc.detachEvent(ON_READY_STATE_CHANGE, arguments.callee);
						callDomLoadFunctions();
					}
				});
				if (win == top) { // если не внутри iframe
					(function(){
						if (isDomLoaded) { return; }
						try {
							doc.documentElement.doScroll("left");
						}
						catch(e) {
							setTimeout(arguments.callee, 0);
							return;
						}
						callDomLoadFunctions();
					})();
				}
			}
			if (ua.wk) {
				(function(){
					if (isDomLoaded) { return; }
					if (!/loaded|complete/.test(doc.readyState)) {
						setTimeout(arguments.callee, 0);
						return;
					}
					callDomLoadFunctions();
				})();
			}
			addLoadEvent(callDomLoadFunctions);
		}
	}();

	function callDomLoadFunctions() {
		if (isDomLoaded) { return; }
		try { // проверяем, действительно ли можно добавлять/удалять элементы в/из DOM; слишком ранее срабатывание не требуется
			var t = doc.getElementsByTagName("body")[0].appendChild(createElement("span"));
			t.parentNode.removeChild(t);
		}
		catch (e) { return; }
		isDomLoaded = true;
		var dl = domLoadFnArr.length;
		for (var i = 0; i < dl; i++) {
			domLoadFnArr[i]();
		}
	}

	function addDomLoadEvent(fn) {
		if (isDomLoaded) {
			fn();
		}
		else {
			domLoadFnArr[domLoadFnArr.length] = fn; // Метод Array.push() доступен только в IE5.5+
		}
	}

	/* Кросс-браузерная проверка onload
		- На основе решения Джеймса Эдвардса James Edwards): http://brothercake.com/site/resources/scripts/onload/
		- Событие случается после загрузки веб-страницы и всех ее ресурсов
	 */
	function addLoadEvent(fn) {
		if (typeof win.addEventListener != UNDEF) {
			win.addEventListener("load", fn, false);
		}
		else if (typeof doc.addEventListener != UNDEF) {
			doc.addEventListener("load", fn, false);
		}
		else if (typeof win.attachEvent != UNDEF) {
			addListener(win, "onload", fn);
		}
		else if (typeof win.onload == "function") {
			var fnOld = win.onload;
			win.onload = function() {
				fnOld();
				fn();
			};
		}
		else {
			win.onload = fn;
		}
	}

	/* Основная функция
		- Предпочтение отдается выполнению onDomLoad, в противном случае — onload (для защиты от сбоев)
	*/
	function main() {
		if (plugin) {
			testPlayerVersion();
		}
		else {
			matchVersions();
		}
	}

	/* Определение версии Flash Player в обозревателях, отличных от Internet Explorer
		- Определение версии подключаемого модуля с помощью тега object является более точным, чем при использовании описаний элементов коллекции подключаемых модулей.
		  а. Можно определить номер выпуска и сборки.
		  б. Исключение неверных описаний, содержащихся в измененных установщиках Adobe.
		  в. Исключение неверных описаний, связанных с наличием в массиве подключаемого модуля нескольких записей Flash Player, из-за ошибок обозревателя в процессе импорта.
		- Минус этого метода заключается в том, то он зависит от доступности DOM, в то время как коллекция подключаемых модулей доступна сразу.
	*/
	function testPlayerVersion() {
		var b = doc.getElementsByTagName("body")[0];
		var o = createElement(OBJECT);
		o.setAttribute("type", FLASH_MIME_TYPE);
		var t = b.appendChild(o);
		if (t) {
			var counter = 0;
			(function(){
				if (typeof t.GetVariable != UNDEF) {
					var d = t.GetVariable("$version");
					if (d) {
						d = d.split(" ")[1].split(",");
						ua.pv = [parseInt(d[0], 10), parseInt(d[1], 10), parseInt(d[2], 10)];
					}
				}
				else if (counter < 10) {
					counter++;
					setTimeout(arguments.callee, 10);
					return;
				}
				b.removeChild(o);
				t = null;
				matchVersions();
			})();
		}
		else {
			matchVersions();
		}
	}

	/* Сопоставление версии Flash Player и SWF; только для статической публикации
	*/
	function matchVersions() {
		var rl = regObjArr.length;
		if (rl > 0) {
			for (var i = 0; i < rl; i++) { // для каждого зарегистрированного элемента объекта
				var id = regObjArr[i].id;
				var cb = regObjArr[i].callbackFn;
				var cbObj = {success:false, id:id};
				if (ua.pv[0] > 0) {
					var obj = getElementById(id);
					if (obj) {
						if (hasPlayerVersion(regObjArr[i].swfVersion) && !(ua.wk && ua.wk < 312)) { // версия Flash Player >= версия опубликованного файла SWF: ура, совпало!
							setVisibility(id, true);
							if (cb) {
								cbObj.success = true;
								cbObj.ref = getObjectById(id);
								cb(cbObj);
							}
						}
						else if (regObjArr[i].expressInstall && canExpressInstall()) { // показать диалоговое окно экспресс-установщика Adobe при наличии соответствующей поддержки, а также если задано автором веб-страницы
							var att = {};
							att.data = regObjArr[i].expressInstall;
							att.width = obj.getAttribute("width") || "0";
							att.height = obj.getAttribute("height") || "0";
							if (obj.getAttribute("class")) { att.styleclass = obj.getAttribute("class"); }
							if (obj.getAttribute("align")) { att.align = obj.getAttribute("align"); }
							// синтаксический анализ пар имя-значение элемента param HTML-тега object
							var par = {};
							var p = obj.getElementsByTagName("param");
							var pl = p.length;
							for (var j = 0; j < pl; j++) {
								if (p[j].getAttribute("name").toLowerCase() != "movie") {
									par[p[j].getAttribute("name")] = p[j].getAttribute("value");
								}
							}
							showExpressInstall(att, par, id, cb);
						}
						else { // несовпадение версий Flash Player и SWF или используется более старая версия механизма Webkit, который пропускает вложенные элементы param HTML-тега object: замена содержимого SWF на аналогичное
							displayAltContent(obj);
							if (cb) { cb(cbObj); }
						}
					}
				}
				else {	// если Flash Player не установлен или невозможно определить его версию, то в работу включается HTML-тег object (отображается SWF или альтернативное содержимое)
					setVisibility(id, true);
					if (cb) {
						var o = getObjectById(id); // проверка на наличие HTML-тега object
						if (o && typeof o.SetVariable != UNDEF) {
							cbObj.success = true;
							cbObj.ref = o;
						}
						cb(cbObj);
					}
				}
			}
		}
	}

	function getObjectById(objectIdStr) {
		var r = null;
		var o = getElementById(objectIdStr);
		if (o && o.nodeName == "OBJECT") {
			if (typeof o.SetVariable != UNDEF) {
				r = o;
			}
			else {
				var n = o.getElementsByTagName(OBJECT)[0];
				if (n) {
					r = n;
				}
			}
		}
		return r;
	}

	/* Требования для экспресс-установщика Adobe
		- одновременно активным может быть только один экземпляр
		- Flash Player версии 6.0.65 или новее
		- только для Win/Mac OS
		- механизм Webkit версии 312 или новее
	*/
	function canExpressInstall() {
		return !isExpressInstallActive && hasPlayerVersion("6.0.65") && (ua.win || ua.mac) && !(ua.wk && ua.wk < 312);
	}

	/* Отображение диалогового окна экспресс-установщика Adobe
		- Ссылка: http://www.adobe.com/go/flashpro_player_express_install_ru
	*/
	function showExpressInstall(att, par, replaceElemIdStr, callbackFn) {
		isExpressInstallActive = true;
		storedCallbackFn = callbackFn || null;
		storedCallbackObj = {success:false, id:replaceElemIdStr};
		var obj = getElementById(replaceElemIdStr);
		if (obj) {
			if (obj.nodeName == "OBJECT") { // статическая публикация
				storedAltContent = abstractAltContent(obj);
				storedAltContentId = null;
			}
			else { // динамическая публикация
				storedAltContent = obj;
				storedAltContentId = replaceElemIdStr;
			}
			att.id = EXPRESS_INSTALL_ID;
			if (typeof att.width == UNDEF || (!/%$/.test(att.width) && parseInt(att.width, 10) < 310)) { att.width = "310"; }
			if (typeof att.height == UNDEF || (!/%$/.test(att.height) && parseInt(att.height, 10) < 137)) { att.height = "137"; }
			doc.title = doc.title.slice(0, 47) + " - Flash Player Installation";
			var pt = ua.ie && ua.win ? "ActiveX" : "PlugIn",
				fv = "MMredirectURL=" + win.location.toString().replace(/&/g,"%26") + "&MMplayerType=" + pt + "&MMdoctitle=" + doc.title;
			if (typeof par.flashvars != UNDEF) {
				par.flashvars += "&" + fv;
			}
			else {
				par.flashvars = fv;
			}
			// только для IE: во время загрузки SWF (и ОТСУТСТВИЯ данного файла в кэше) дождитесь, пока элемент readyState тега object примет значение 4; затем его можно удалить
			// без изменения ссылок загрузки обозревателя корректно отменить загрузку файла SWF нельзя, obj.onreadystatechange также не работает
			if (ua.ie && ua.win && obj.readyState != 4) {
				var newObj = createElement("div");
				replaceElemIdStr += "SWFObjectNew";
				newObj.setAttribute("id", replaceElemIdStr);
				obj.parentNode.insertBefore(newObj, obj); // вставьте тег div, который будет заменен на тег object, загружающий expressinstall.swf
				obj.style.display = "none";
				(function(){
					if (obj.readyState == 4) {
						obj.parentNode.removeChild(obj);
					}
					else {
						setTimeout(arguments.callee, 10);
					}
				})();
			}
			createSWF(att, par, replaceElemIdStr);
		}
	}

	/* Функции, используемые для извлечения и отображения альтернативного содержимого
	*/
	function displayAltContent(obj) {
		if (ua.ie && ua.win && obj.readyState != 4) {
			// только для IE: во время загрузки SWF (и ОТСУТСТВИЯ данного файла в кэше) дождитесь, пока элемент readyState тега object примет значение 4; затем его можно удалить
			// без изменения ссылок загрузки обозревателя корректно отменить загрузку файла SWF нельзя, obj.onreadystatechange также не работает
			var el = createElement("div");
			obj.parentNode.insertBefore(el, obj); // вставьте тег div, который будет заменен на другое содержимое
			el.parentNode.replaceChild(abstractAltContent(obj), el);
			obj.style.display = "none";
			(function(){
				if (obj.readyState == 4) {
					obj.parentNode.removeChild(obj);
				}
				else {
					setTimeout(arguments.callee, 10);
				}
			})();
		}
		else {
			obj.parentNode.replaceChild(abstractAltContent(obj), obj);
		}
	}

	function abstractAltContent(obj) {
		var ac = createElement("div");
		if (ua.win && ua.ie) {
			ac.innerHTML = obj.innerHTML;
		}
		else {
			var nestedObj = obj.getElementsByTagName(OBJECT)[0];
			if (nestedObj) {
				var c = nestedObj.childNodes;
				if (c) {
					var cl = c.length;
					for (var i = 0; i < cl; i++) {
						if (!(c[i].nodeType == 1 && c[i].nodeName == "PARAM") && !(c[i].nodeType == 8)) {
							ac.appendChild(c[i].cloneNode(true));
						}
					}
				}
			}
		}
		return ac;
	}

	/* Мультибраузерное динамическое создание SWF
	*/
	function createSWF(attObj, parObj, id) {
		var r, el = getElementById(id);
		if (ua.wk && ua.wk < 312) { return r; }
		if (el) {
			if (typeof attObj.id == UNDEF) { // если в теге object отсутствует селектор id, то значение id берется из альтернативного содержимого
				attObj.id = id;
			}
			if (ua.ie && ua.win) { // Internet Explorer + объект элемента HTML + методы W3C DOM не могут работать вместе: необходимо вернуться к outerHTML
				var att = "";
				for (var i in attObj) {
					if (attObj[i] != Object.prototype[i]) { // фильтрация дополнений прототипа из других потенциальных библиотек
						if (i.toLowerCase() == "data") {
							parObj.movie = attObj[i];
						}
						else if (i.toLowerCase() == "styleclass") { // class является зарезервированным ключевым словом ECMA4
							att += ' class="' + attObj[i] + '"';
						}
						else if (i.toLowerCase() != "classid") {
							att += ' ' + i + '="' + attObj[i] + '"';
						}
					}
				}
				var par = "";
				for (var j in parObj) {
					if (parObj[j] != Object.prototype[j]) { // фильтрация дополнений прототипа из других потенциальных библиотек
						par += '<param name="' + j + '" value="' + parObj[j] + '" />';
					}
				}
				el.outerHTML = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"' + att + '>' + par + '</object>';
				objIdArr[objIdArr.length] = attObj.id; // хранится для устранения "утечек" объекта при выгрузке (только для динамической публикации)
				r = getElementById(attObj.id);
			}
			else { // проверенные обозреватели
				var o = createElement(OBJECT);
				o.setAttribute("type", FLASH_MIME_TYPE);
				for (var m in attObj) {
					if (attObj[m] != Object.prototype[m]) { // фильтрация дополнений прототипа из других потенциальных библиотек
						if (m.toLowerCase() == "styleclass") { // class является зарезервированным ключевым словом ECMA4
							o.setAttribute("class", attObj[m]);
						}
						else if (m.toLowerCase() != "classid") { // фильтрация определенного атрибута IE
							o.setAttribute(m, attObj[m]);
						}
					}
				}
				for (var n in parObj) {
					if (parObj[n] != Object.prototype[n] && n.toLowerCase() != "movie") { // фильтрация дополнений прототипа из других потенциальных библиотек и определенного элемента param обозревателя IE
						createObjParam(o, n, parObj[n]);
					}
				}
				el.parentNode.replaceChild(o, el);
				r = o;
			}
		}
		return r;
	}

	function createObjParam(el, pName, pValue) {
		var p = createElement("param");
		p.setAttribute("name", pName);
		p.setAttribute("value", pValue);
		el.appendChild(p);
	}

	/* Мультибраузерное удаление SWF
		- Особенно необходимо для безопасного и полного удаления SWF в Internet Explorer
	*/
	function removeSWF(id) {
		var obj = getElementById(id);
		if (obj && obj.nodeName == "OBJECT") {
			if (ua.ie && ua.win) {
				obj.style.display = "none";
				(function(){
					if (obj.readyState == 4) {
						removeObjectInIE(id);
					}
					else {
						setTimeout(arguments.callee, 10);
					}
				})();
			}
			else {
				obj.parentNode.removeChild(obj);
			}
		}
	}

	function removeObjectInIE(id) {
		var obj = getElementById(id);
		if (obj) {
			for (var i in obj) {
				if (typeof obj[i] == "function") {
					obj[i] = null;
				}
			}
			obj.parentNode.removeChild(obj);
		}
	}

	/* Функции, используемые для оптимизации сжатия JavaScript
	*/
	function getElementById(id) {
		var el = null;
		try {
			el = doc.getElementById(id);
		}
		catch (e) {}
		return el;
	}

	function createElement(el) {
		return doc.createElement(el);
	}

	/* Обновленная функция attachEvent для Internet Explorer
		- Хранит данные attachEvent в массиве, поэтому при выгрузке можно вызвать функцию detachEvent, позволяющую избежать утечек памяти
	*/
	function addListener(target, eventType, fn) {
		target.attachEvent(eventType, fn);
		listenersArr[listenersArr.length] = [target, eventType, fn];
	}

	/* Сопоставление версии Flash Player и содержимого SWF
	*/
	function hasPlayerVersion(rv) {
		var pv = ua.pv, v = rv.split(".");
		v[0] = parseInt(v[0], 10);
		v[1] = parseInt(v[1], 10) || 0; // поддерживает краткое представление, например "9" вместо "9.0.0"
		v[2] = parseInt(v[2], 10) || 0;
		return (pv[0] > v[0] || (pv[0] == v[0] && pv[1] > v[1]) || (pv[0] == v[0] && pv[1] == v[1] && pv[2] >= v[2])) ? true : false;
	}

	/* Мультибраузерное динамическое создание CSS
		- Основано на решении Бобби ван дер Слуис (Bobby van der Sluis): http://www.bobbyvandersluis.com/articles/dynamicCSS.php
	*/
	function createCSS(sel, decl, media, newStyle) {
		if (ua.ie && ua.mac) { return; }
		var h = doc.getElementsByTagName("head")[0];
		if (!h) { return; } // а также для работы со страницами HTML, в которых отсутствует элемент head
		var m = (media && typeof media == "string") ? media : "screen";
		if (newStyle) {
			dynamicStylesheet = null;
			dynamicStylesheetMedia = null;
		}
		if (!dynamicStylesheet || dynamicStylesheetMedia != m) {
			// создание динамической таблицы стилей + получение глобальной ссылки на нее
			var s = createElement("style");
			s.setAttribute("type", "text/css");
			s.setAttribute("media", m);
			dynamicStylesheet = h.appendChild(s);
			if (ua.ie && ua.win && typeof doc.styleSheets != UNDEF && doc.styleSheets.length > 0) {
				dynamicStylesheet = doc.styleSheets[doc.styleSheets.length - 1];
			}
			dynamicStylesheetMedia = m;
		}
		// добавление правила стиля
		if (ua.ie && ua.win) {
			if (dynamicStylesheet && typeof dynamicStylesheet.addRule == OBJECT) {
				dynamicStylesheet.addRule(sel, decl);
			}
		}
		else {
			if (dynamicStylesheet && typeof doc.createTextNode != UNDEF) {
				dynamicStylesheet.appendChild(doc.createTextNode(sel + " {" + decl + "}"));
			}
		}
	}

	function setVisibility(id, isVisible) {
		if (!autoHideShow) { return; }
		var v = isVisible ? "visible" : "hidden";
		if (isDomLoaded && getElementById(id)) {
			getElementById(id).style.visibility = v;
		}
		else {
			createCSS("#" + id, "visibility:" + v);
		}
	}

	/* Фильтр, используемый для защиты от атак XSS
	*/
	function urlEncodeIfNecessary(s) {
		var regex = /[\\\"<>\.;]/;
		var hasBadChars = regex.exec(s) != null;
		return hasBadChars && typeof encodeURIComponent != UNDEF ? encodeURIComponent(s) : s;
	}

	/* Освобождение свободной памяти для устранения утечек памяти, связанных с закрытиями, для исправления зависших аудио/видео потоков и принудительного отключения открытых сокетов/NetConnection (только для Internet Explorer)
	*/
	var cleanup = function() {
		if (ua.ie && ua.win) {
			window.attachEvent("onunload", function() {
				// удаление прослушивателей для устранения утечек памяти
				var ll = listenersArr.length;
				for (var i = 0; i < ll; i++) {
					listenersArr[i][0].detachEvent(listenersArr[i][1], listenersArr[i][2]);
				}
				// очистка динамически внедренных объектов для исправления зависших аудио/видеопотоков и принудительного отключения открытых сокетов/NetConnection
				var il = objIdArr.length;
				for (var j = 0; j < il; j++) {
					removeSWF(objIdArr[j]);
				}
				// очистка основных закрытий библиотеки для устранения утечек памяти
				for (var k in ua) {
					ua[k] = null;
				}
				ua = null;
				for (var l in swfobject) {
					swfobject[l] = null;
				}
				swfobject = null;
			});
		}
	}();

	return {
		/* Общедоступный API
			- Ссылка: http://code.google.com/p/swfobject/wiki/documentation
		*/
		registerObject: function(objectIdStr, swfVersionStr, xiSwfUrlStr, callbackFn) {
			if (ua.w3 && objectIdStr && swfVersionStr) {
				var regObj = {};
				regObj.id = objectIdStr;
				regObj.swfVersion = swfVersionStr;
				regObj.expressInstall = xiSwfUrlStr;
				regObj.callbackFn = callbackFn;
				regObjArr[regObjArr.length] = regObj;
				setVisibility(objectIdStr, false);
			}
			else if (callbackFn) {
				callbackFn({success:false, id:objectIdStr});
			}
		},

		getObjectById: function(objectIdStr) {
			if (ua.w3) {
				return getObjectById(objectIdStr);
			}
		},

		embedSWF: function(swfUrlStr, replaceElemIdStr, widthStr, heightStr, swfVersionStr, xiSwfUrlStr, flashvarsObj, parObj, attObj, callbackFn) {
			var callbackObj = {success:false, id:replaceElemIdStr};
			if (ua.w3 && !(ua.wk && ua.wk < 312) && swfUrlStr && replaceElemIdStr && widthStr && heightStr && swfVersionStr) {
				setVisibility(replaceElemIdStr, false);
				addDomLoadEvent(function() {
					widthStr += ""; // автоматическое преобразование в тип данных string
					heightStr += "";
					var att = {};
					if (attObj && typeof attObj === OBJECT) {
						for (var i in attObj) { // копирование объекта во избежание использования ссылок, так как создатели веб-страниц часто повторно используют attObj для нескольких SWF
							att[i] = attObj[i];
						}
					}
					att.data = swfUrlStr;
					att.width = widthStr;
					att.height = heightStr;
					var par = {};
					if (parObj && typeof parObj === OBJECT) {
						for (var j in parObj) { // копирование объекта во избежание использования ссылок, так как создатели веб-страниц часто повторно используют parObj для нескольких SWF
							par[j] = parObj[j];
						}
					}
					if (flashvarsObj && typeof flashvarsObj === OBJECT) {
						for (var k in flashvarsObj) { // копирование объекта во избежание использования ссылок, так как создатели веб-страниц часто повторно используют flashvarsObj для нескольких SWF
							if (typeof par.flashvars != UNDEF) {
								par.flashvars += "&" + k + "=" + flashvarsObj[k];
							}
							else {
								par.flashvars = k + "=" + flashvarsObj[k];
							}
						}
					}
					if (hasPlayerVersion(swfVersionStr)) { // создание SWF
						var obj = createSWF(att, par, replaceElemIdStr);
						if (att.id == replaceElemIdStr) {
							setVisibility(replaceElemIdStr, true);
						}
						callbackObj.success = true;
						callbackObj.ref = obj;
					}
					else if (xiSwfUrlStr && canExpressInstall()) { // отображение экспресс-установщика Adobe
						att.data = xiSwfUrlStr;
						showExpressInstall(att, par, replaceElemIdStr, callbackFn);
						return;
					}
					else { // отображение альтернативного содержимого
						setVisibility(replaceElemIdStr, true);
					}
					if (callbackFn) { callbackFn(callbackObj); }
				});
			}
			else if (callbackFn) { callbackFn(callbackObj);	}
		},

		switchOffAutoHideShow: function() {
			autoHideShow = false;
		},

		ua: ua,

		getFlashPlayerVersion: function() {
			return { major:ua.pv[0], minor:ua.pv[1], release:ua.pv[2] };
		},

		hasFlashPlayerVersion: hasPlayerVersion,

		createSWF: function(attObj, parObj, replaceElemIdStr) {
			if (ua.w3) {
				return createSWF(attObj, parObj, replaceElemIdStr);
			}
			else {
				return undefined;
			}
		},

		showExpressInstall: function(att, par, replaceElemIdStr, callbackFn) {
			if (ua.w3 && canExpressInstall()) {
				showExpressInstall(att, par, replaceElemIdStr, callbackFn);
			}
		},

		removeSWF: function(objElemIdStr) {
			if (ua.w3) {
				removeSWF(objElemIdStr);
			}
		},

		createCSS: function(selStr, declStr, mediaStr, newStyleBoolean) {
			if (ua.w3) {
				createCSS(selStr, declStr, mediaStr, newStyleBoolean);
			}
		},

		addDomLoadEvent: addDomLoadEvent,

		addLoadEvent: addLoadEvent,

		getQueryParamValue: function(param) {
			var q = doc.location.search || doc.location.hash;
			if (q) {
				if (/\?/.test(q)) { q = q.split("?")[1]; } // удаление вопросительного знака
				if (param == null) {
					return urlEncodeIfNecessary(q);
				}
				var pairs = q.split("&");
				for (var i = 0; i < pairs.length; i++) {
					if (pairs[i].substring(0, pairs[i].indexOf("=")) == param) {
						return urlEncodeIfNecessary(pairs[i].substring((pairs[i].indexOf("=") + 1)));
					}
				}
			}
			return "";
		},

		// Только для внутреннего использования
		expressInstallCallback: function() {
			if (isExpressInstallActive) {
				var obj = getElementById(EXPRESS_INSTALL_ID);
				if (obj && storedAltContent) {
					obj.parentNode.replaceChild(storedAltContent, obj);
					if (storedAltContentId) {
						setVisibility(storedAltContentId, true);
						if (ua.ie && ua.win) { storedAltContent.style.display = "block"; }
					}
					if (storedCallbackFn) { storedCallbackFn(storedCallbackObj); }
				}
				isExpressInstallActive = false;
			}
		}
	};
}();
