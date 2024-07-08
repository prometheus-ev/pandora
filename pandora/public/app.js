/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ 501:
/***/ (function(module, exports, __webpack_require__) {

/* module decorator */ module = __webpack_require__.nmd(module);
var __WEBPACK_AMD_DEFINE_RESULT__;/*! https://mths.be/base64 v1.0.0 by @mathias | MIT license */
;(function(root) {

	// Detect free variables `exports`.
	var freeExports =  true && exports;

	// Detect free variable `module`.
	var freeModule =  true && module &&
		module.exports == freeExports && module;

	// Detect free variable `global`, from Node.js or Browserified code, and use
	// it as `root`.
	var freeGlobal = typeof __webpack_require__.g == 'object' && __webpack_require__.g;
	if (freeGlobal.global === freeGlobal || freeGlobal.window === freeGlobal) {
		root = freeGlobal;
	}

	/*--------------------------------------------------------------------------*/

	var InvalidCharacterError = function(message) {
		this.message = message;
	};
	InvalidCharacterError.prototype = new Error;
	InvalidCharacterError.prototype.name = 'InvalidCharacterError';

	var error = function(message) {
		// Note: the error messages used throughout this file match those used by
		// the native `atob`/`btoa` implementation in Chromium.
		throw new InvalidCharacterError(message);
	};

	var TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	// http://whatwg.org/html/common-microsyntaxes.html#space-character
	var REGEX_SPACE_CHARACTERS = /[\t\n\f\r ]/g;

	// `decode` is designed to be fully compatible with `atob` as described in the
	// HTML Standard. http://whatwg.org/html/webappapis.html#dom-windowbase64-atob
	// The optimized base64-decoding algorithm used is based on @atk’s excellent
	// implementation. https://gist.github.com/atk/1020396
	var decode = function(input) {
		input = String(input)
			.replace(REGEX_SPACE_CHARACTERS, '');
		var length = input.length;
		if (length % 4 == 0) {
			input = input.replace(/==?$/, '');
			length = input.length;
		}
		if (
			length % 4 == 1 ||
			// http://whatwg.org/C#alphanumeric-ascii-characters
			/[^+a-zA-Z0-9/]/.test(input)
		) {
			error(
				'Invalid character: the string to be decoded is not correctly encoded.'
			);
		}
		var bitCounter = 0;
		var bitStorage;
		var buffer;
		var output = '';
		var position = -1;
		while (++position < length) {
			buffer = TABLE.indexOf(input.charAt(position));
			bitStorage = bitCounter % 4 ? bitStorage * 64 + buffer : buffer;
			// Unless this is the first of a group of 4 characters…
			if (bitCounter++ % 4) {
				// …convert the first 8 bits to a single ASCII character.
				output += String.fromCharCode(
					0xFF & bitStorage >> (-2 * bitCounter & 6)
				);
			}
		}
		return output;
	};

	// `encode` is designed to be fully compatible with `btoa` as described in the
	// HTML Standard: http://whatwg.org/html/webappapis.html#dom-windowbase64-btoa
	var encode = function(input) {
		input = String(input);
		if (/[^\0-\xFF]/.test(input)) {
			// Note: no need to special-case astral symbols here, as surrogates are
			// matched, and the input is supposed to only contain ASCII anyway.
			error(
				'The string to be encoded contains characters outside of the ' +
				'Latin1 range.'
			);
		}
		var padding = input.length % 3;
		var output = '';
		var position = -1;
		var a;
		var b;
		var c;
		var buffer;
		// Make sure any padding is handled outside of the loop.
		var length = input.length - padding;

		while (++position < length) {
			// Read three bytes, i.e. 24 bits.
			a = input.charCodeAt(position) << 16;
			b = input.charCodeAt(++position) << 8;
			c = input.charCodeAt(++position);
			buffer = a + b + c;
			// Turn the 24 bits into four chunks of 6 bits each, and append the
			// matching character for each of them to the output.
			output += (
				TABLE.charAt(buffer >> 18 & 0x3F) +
				TABLE.charAt(buffer >> 12 & 0x3F) +
				TABLE.charAt(buffer >> 6 & 0x3F) +
				TABLE.charAt(buffer & 0x3F)
			);
		}

		if (padding == 2) {
			a = input.charCodeAt(position) << 8;
			b = input.charCodeAt(++position);
			buffer = a + b;
			output += (
				TABLE.charAt(buffer >> 10) +
				TABLE.charAt((buffer >> 4) & 0x3F) +
				TABLE.charAt((buffer << 2) & 0x3F) +
				'='
			);
		} else if (padding == 1) {
			buffer = input.charCodeAt(position);
			output += (
				TABLE.charAt(buffer >> 2) +
				TABLE.charAt((buffer << 4) & 0x3F) +
				'=='
			);
		}

		return output;
	};

	var base64 = {
		'encode': encode,
		'decode': decode,
		'version': '1.0.0'
	};

	// Some AMD build optimizers, like r.js, check for specific condition patterns
	// like the following:
	if (
		true
	) {
		!(__WEBPACK_AMD_DEFINE_RESULT__ = (function() {
			return base64;
		}).call(exports, __webpack_require__, exports, module),
		__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
	}	else { var key; }

}(this));


/***/ }),

/***/ 1:
/***/ ((module) => {

//
// strftime
// github.com/samsonjs/strftime
// @_sjs
//
// Copyright 2010 - 2021 Sami Samhuri <sami@samhuri.net>
//
// MIT License
// http://sjs.mit-license.org
//

; (function () {

    var Locales = {
        de_DE: {
            identifier: 'de-DE',
            days: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'],
            shortDays: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
            months: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
            shortMonths: ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d.%m.%Y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        en_CA: {
            identifier: 'en-CA',
            days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
            shortDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
            shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            ordinalSuffixes: [
                'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th',
                'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th',
                'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th',
                'st'
            ],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d/%m/%y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%r',
                x: '%D'
            }
        },

        en_US: {
            identifier: 'en-US',
            days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
            shortDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
            shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            ordinalSuffixes: [
                'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th',
                'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th',
                'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th',
                'st'
            ],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%m/%d/%y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%r',
                x: '%D'
            }
        },

        es_MX: {
            identifier: 'es-MX',
            days: ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'],
            shortDays: ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'],
            months: ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'],
            shortMonths: ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d/%m/%Y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        fr_FR: {
            identifier: 'fr-FR',
            days: ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'],
            shortDays: ['dim.', 'lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.'],
            months: ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'],
            shortMonths: ['janv.', 'févr.', 'mars', 'avril', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d/%m/%Y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        it_IT: {
            identifier: 'it-IT',
            days: ['domenica', 'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato'],
            shortDays: ['dom', 'lun', 'mar', 'mer', 'gio', 'ven', 'sab'],
            months: ['gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'],
            shortMonths: ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d/%m/%Y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        nl_NL: {
            identifier: 'nl-NL',
            days: ['zondag', 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag'],
            shortDays: ['zo', 'ma', 'di', 'wo', 'do', 'vr', 'za'],
            months: ['januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december'],
            shortMonths: ['jan', 'feb', 'mrt', 'apr', 'mei', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d-%m-%y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        pt_BR: {
            identifier: 'pt-BR',
            days: ['domingo', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'],
            shortDays: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
            months: ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'],
            shortMonths: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d-%m-%Y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        ru_RU: {
            identifier: 'ru-RU',
            days: ['Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'],
            shortDays: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'],
            months: ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'],
            shortMonths: ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'],
            AM: 'AM',
            PM: 'PM',
            am: 'am',
            pm: 'pm',
            formats: {
                c: '%a %d %b %Y %X',
                D: '%d.%m.%y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        tr_TR: {
            identifier: 'tr-TR',
            days: ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'],
            shortDays: ['Paz', 'Pzt', 'Sal', 'Çrş', 'Prş', 'Cum', 'Cts'],
            months: ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'],
            shortMonths: ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'],
            AM: 'ÖÖ',
            PM: 'ÖS',
            am: 'ÖÖ',
            pm: 'ÖS',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d-%m-%Y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%T',
                x: '%D'
            }
        },

        // By michaeljayt<michaeljayt@gmail.com>
        // https://github.com/michaeljayt/strftime/commit/bcb4c12743811d51e568175aa7bff3fd2a77cef3
        zh_CN: {
            identifier: 'zh-CN',
            days: ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'],
            shortDays: ['日', '一', '二', '三', '四', '五', '六'],
            months: ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'],
            shortMonths: ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'],
            AM: '上午',
            PM: '下午',
            am: '上午',
            pm: '下午',
            formats: {
                c: '%a %d %b %Y %X %Z',
                D: '%d/%m/%y',
                F: '%Y-%m-%d',
                R: '%H:%M',
                r: '%I:%M:%S %p',
                T: '%H:%M:%S',
                v: '%e-%b-%Y',
                X: '%r',
                x: '%D'
            }
        }
    };

    var DefaultLocale = Locales['en_US'],
        defaultStrftime = new Strftime(DefaultLocale, 0, false),
        isCommonJS = "object" !== 'undefined',
        namespace;

    // CommonJS / Node module
    if (isCommonJS) {
        namespace = module.exports = defaultStrftime;
    }
    // Browsers and other environments
    else {
        // Get the global object. Works in ES3, ES5, and ES5 strict mode.
        namespace = (function () { return this || (1, eval)('this'); }());
        namespace.strftime = defaultStrftime;
    }

    // Polyfill Date.now for old browsers.
    if (typeof Date.now !== 'function') {
        Date.now = function () {
            return +new Date();
        };
    }

    function Strftime(locale, customTimezoneOffset, useUtcTimezone) {
        var _locale = locale || DefaultLocale,
            _customTimezoneOffset = customTimezoneOffset || 0,
            _useUtcBasedDate = useUtcTimezone || false,

            // we store unix timestamp value here to not create new Date() each iteration (each millisecond)
            // Date.now() is 2 times faster than new Date()
            // while millisecond precise is enough here
            // this could be very helpful when strftime triggered a lot of times one by one
            _cachedDateTimestamp = 0,
            _cachedDate;

        function _strftime(format, date) {
            var timestamp;

            if (!date) {
                var currentTimestamp = Date.now();
                if (currentTimestamp > _cachedDateTimestamp) {
                    _cachedDateTimestamp = currentTimestamp;
                    _cachedDate = new Date(_cachedDateTimestamp);

                    timestamp = _cachedDateTimestamp;

                    if (_useUtcBasedDate) {
                        // how to avoid duplication of date instantiation for utc here?
                        // we tied to getTimezoneOffset of the current date
                        _cachedDate = new Date(_cachedDateTimestamp + getTimestampToUtcOffsetFor(_cachedDate) + _customTimezoneOffset);
                    }
                }
                else {
                    timestamp = _cachedDateTimestamp;
                }
                date = _cachedDate;
            }
            else {
                timestamp = date.getTime();

                if (_useUtcBasedDate) {
                    var utcOffset = getTimestampToUtcOffsetFor(date);
                    date = new Date(timestamp + utcOffset + _customTimezoneOffset);
                    // If we've crossed a DST boundary with this calculation we need to
                    // adjust the new date accordingly or it will be off by an hour in UTC.
                    if (getTimestampToUtcOffsetFor(date) !== utcOffset) {
                        var newUTCOffset = getTimestampToUtcOffsetFor(date);
                        date = new Date(timestamp + newUTCOffset + _customTimezoneOffset);
                    }
                }
            }

            return _processFormat(format, date, _locale, timestamp);
        }

        function _processFormat(format, date, locale, timestamp) {
            var resultString = '',
                padding = null,
                isInScope = false,
                length = format.length,
                extendedTZ = false;

            for (var i = 0; i < length; i++) {

                var currentCharCode = format.charCodeAt(i);

                if (isInScope === true) {
                    // '-'
                    if (currentCharCode === 45) {
                        padding = '';
                        continue;
                    }
                    // '_'
                    else if (currentCharCode === 95) {
                        padding = ' ';
                        continue;
                    }
                    // '0'
                    else if (currentCharCode === 48) {
                        padding = '0';
                        continue;
                    }
                    // ':'
                    else if (currentCharCode === 58) {
                        if (extendedTZ) {
                            warn("[WARNING] detected use of unsupported %:: or %::: modifiers to strftime");
                        }
                        extendedTZ = true;
                        continue;
                    }

                    switch (currentCharCode) {

                        // Examples for new Date(0) in GMT

                        // '%'
                        // case '%':
                        case 37:
                            resultString += '%';
                            break;

                        // 'Thursday'
                        // case 'A':
                        case 65:
                            resultString += locale.days[date.getDay()];
                            break;

                        // 'January'
                        // case 'B':
                        case 66:
                            resultString += locale.months[date.getMonth()];
                            break;

                        // '19'
                        // case 'C':
                        case 67:
                            resultString += padTill2(Math.floor(date.getFullYear() / 100), padding);
                            break;

                        // '01/01/70'
                        // case 'D':
                        case 68:
                            resultString += _processFormat(locale.formats.D, date, locale, timestamp);
                            break;

                        // '1970-01-01'
                        // case 'F':
                        case 70:
                            resultString += _processFormat(locale.formats.F, date, locale, timestamp);
                            break;

                        // '00'
                        // case 'H':
                        case 72:
                            resultString += padTill2(date.getHours(), padding);
                            break;

                        // '12'
                        // case 'I':
                        case 73:
                            resultString += padTill2(hours12(date.getHours()), padding);
                            break;

                        // '000'
                        // case 'L':
                        case 76:
                            resultString += padTill3(Math.floor(timestamp % 1000));
                            break;

                        // '00'
                        // case 'M':
                        case 77:
                            resultString += padTill2(date.getMinutes(), padding);
                            break;

                        // 'am'
                        // case 'P':
                        case 80:
                            resultString += date.getHours() < 12 ? locale.am : locale.pm;
                            break;

                        // '00:00'
                        // case 'R':
                        case 82:
                            resultString += _processFormat(locale.formats.R, date, locale, timestamp);
                            break;

                        // '00'
                        // case 'S':
                        case 83:
                            resultString += padTill2(date.getSeconds(), padding);
                            break;

                        // '00:00:00'
                        // case 'T':
                        case 84:
                            resultString += _processFormat(locale.formats.T, date, locale, timestamp);
                            break;

                        // '00'
                        // case 'U':
                        case 85:
                            resultString += padTill2(weekNumber(date, 'sunday'), padding);
                            break;

                        // '00'
                        // case 'W':
                        case 87:
                            resultString += padTill2(weekNumber(date, 'monday'), padding);
                            break;

                        // '16:00:00'
                        // case 'X':
                        case 88:
                            resultString += _processFormat(locale.formats.X, date, locale, timestamp);
                            break;

                        // '1970'
                        // case 'Y':
                        case 89:
                            resultString += date.getFullYear();
                            break;

                        // 'GMT'
                        // case 'Z':
                        case 90:
                            if (_useUtcBasedDate && _customTimezoneOffset === 0) {
                                resultString += "GMT";
                            }
                            else {
                                var tzName = getTimezoneName(date);
                                resultString += tzName || '';
                            }
                            break;

                        // 'Thu'
                        // case 'a':
                        case 97:
                            resultString += locale.shortDays[date.getDay()];
                            break;

                        // 'Jan'
                        // case 'b':
                        case 98:
                            resultString += locale.shortMonths[date.getMonth()];
                            break;

                        // ''
                        // case 'c':
                        case 99:
                            resultString += _processFormat(locale.formats.c, date, locale, timestamp);
                            break;

                        // '01'
                        // case 'd':
                        case 100:
                            resultString += padTill2(date.getDate(), padding);
                            break;

                        // ' 1'
                        // case 'e':
                        case 101:
                            resultString += padTill2(date.getDate(), padding == null ? ' ' : padding);
                            break;

                        // 'Jan'
                        // case 'h':
                        case 104:
                            resultString += locale.shortMonths[date.getMonth()];
                            break;

                        // '000'
                        // case 'j':
                        case 106:
                            var y = new Date(date.getFullYear(), 0, 1);
                            var day = Math.ceil((date.getTime() - y.getTime()) / (1000 * 60 * 60 * 24));
                            resultString += padTill3(day);
                            break;

                        // ' 0'
                        // case 'k':
                        case 107:
                            resultString += padTill2(date.getHours(), padding == null ? ' ' : padding);
                            break;

                        // '12'
                        // case 'l':
                        case 108:
                            resultString += padTill2(hours12(date.getHours()), padding == null ? ' ' : padding);
                            break;

                        // '01'
                        // case 'm':
                        case 109:
                            resultString += padTill2(date.getMonth() + 1, padding);
                            break;

                        // '\n'
                        // case 'n':
                        case 110:
                            resultString += '\n';
                            break;

                        // '1st'
                        // case 'o':
                        case 111:
                            // Try to use an ordinal suffix from the locale, but fall back to using the old
                            // function for compatibility with old locales that lack them.
                            var day = date.getDate();
                            if (locale.ordinalSuffixes) {
                                resultString += String(day) + (locale.ordinalSuffixes[day - 1] || ordinal(day));
                            }
                            else {
                                resultString += String(day) + ordinal(day);
                            }
                            break;

                        // 'AM'
                        // case 'p':
                        case 112:
                            resultString += date.getHours() < 12 ? locale.AM : locale.PM;
                            break;

                        // '12:00:00 AM'
                        // case 'r':
                        case 114:
                            resultString += _processFormat(locale.formats.r, date, locale, timestamp);
                            break;

                        // '0'
                        // case 's':
                        case 115:
                            resultString += Math.floor(timestamp / 1000);
                            break;

                        // '\t'
                        // case 't':
                        case 116:
                            resultString += '\t';
                            break;

                        // '4'
                        // case 'u':
                        case 117:
                            var day = date.getDay();
                            resultString += day === 0 ? 7 : day;
                            break; // 1 - 7, Monday is first day of the week

                        // ' 1-Jan-1970'
                        // case 'v':
                        case 118:
                            resultString += _processFormat(locale.formats.v, date, locale, timestamp);
                            break;

                        // '4'
                        // case 'w':
                        case 119:
                            resultString += date.getDay();
                            break; // 0 - 6, Sunday is first day of the week

                        // '12/31/69'
                        // case 'x':
                        case 120:
                            resultString += _processFormat(locale.formats.x, date, locale, timestamp);
                            break;

                        // '70'
                        // case 'y':
                        case 121:
                            resultString += padTill2(date.getFullYear() % 100, padding);
                            break;

                        // '+0000'
                        // case 'z':
                        case 122:
                            if (_useUtcBasedDate && _customTimezoneOffset === 0) {
                                resultString += extendedTZ ? "+00:00" : "+0000";
                            }
                            else {
                                var off;
                                if (_customTimezoneOffset !== 0) {
                                    off = _customTimezoneOffset / (60 * 1000);
                                }
                                else {
                                    off = -date.getTimezoneOffset();
                                }
                                var sign = off < 0 ? '-' : '+';
                                var sep = extendedTZ ? ':' : '';
                                var hours = Math.floor(Math.abs(off / 60));
                                var mins = Math.abs(off % 60);
                                resultString += sign + padTill2(hours) + sep + padTill2(mins);
                            }
                            break;

                        default:
                            if (isInScope) {
                                resultString += '%';
                            }
                            resultString += format[i];
                            break;
                    }

                    padding = null;
                    isInScope = false;
                    continue;
                }

                // '%'
                if (currentCharCode === 37) {
                    isInScope = true;
                    continue;
                }

                resultString += format[i];
            }

            return resultString;
        }

        var strftime = _strftime;

        strftime.localize = function (locale) {
            return new Strftime(locale || _locale, _customTimezoneOffset, _useUtcBasedDate);
        };

        strftime.localizeByIdentifier = function (localeIdentifier) {
            var locale = Locales[localeIdentifier];
            if (!locale) {
                warn('[WARNING] No locale found with identifier "' + localeIdentifier + '".');
                return strftime;
            }
            return strftime.localize(locale);
        };

        strftime.timezone = function (timezone) {
            var customTimezoneOffset = _customTimezoneOffset;
            var useUtcBasedDate = _useUtcBasedDate;

            var timezoneType = typeof timezone;
            if (timezoneType === 'number' || timezoneType === 'string') {
                useUtcBasedDate = true;

                // ISO 8601 format timezone string, [-+]HHMM
                if (timezoneType === 'string') {
                    var sign = timezone[0] === '-' ? -1 : 1,
                        hours = parseInt(timezone.slice(1, 3), 10),
                        minutes = parseInt(timezone.slice(3, 5), 10);

                    customTimezoneOffset = sign * ((60 * hours) + minutes) * 60 * 1000;
                    // in minutes: 420
                }
                else if (timezoneType === 'number') {
                    customTimezoneOffset = timezone * 60 * 1000;
                }
            }

            return new Strftime(_locale, customTimezoneOffset, useUtcBasedDate);
        };

        strftime.utc = function () {
            return new Strftime(_locale, _customTimezoneOffset, true);
        };

        return strftime;
    }

    function padTill2(numberToPad, paddingChar) {
        if (paddingChar === '' || numberToPad > 9) {
            return '' + numberToPad;
        }
        if (paddingChar == null) {
            paddingChar = '0';
        }
        return paddingChar + numberToPad;
    }

    function padTill3(numberToPad) {
        if (numberToPad > 99) {
            return numberToPad;
        }
        if (numberToPad > 9) {
            return '0' + numberToPad;
        }
        return '00' + numberToPad;
    }

    function hours12(hour) {
        if (hour === 0) {
            return 12;
        }
        else if (hour > 12) {
            return hour - 12;
        }
        return hour;
    }

    // firstWeekday: 'sunday' or 'monday', default is 'sunday'
    //
    // Pilfered & ported from Ruby's strftime implementation.
    function weekNumber(date, firstWeekday) {
        firstWeekday = firstWeekday || 'sunday';

        // This works by shifting the weekday back by one day if we
        // are treating Monday as the first day of the week.
        var weekday = date.getDay();
        if (firstWeekday === 'monday') {
            if (weekday === 0) // Sunday
                weekday = 6;
            else
                weekday--;
        }

        var firstDayOfYearUtc = Date.UTC(date.getFullYear(), 0, 1),
            dateUtc = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()),
            yday = Math.floor((dateUtc - firstDayOfYearUtc) / 86400000),
            weekNum = (yday + 7 - weekday) / 7;

        return Math.floor(weekNum);
    }

    // Get the ordinal suffix for a number: st, nd, rd, or th
    function ordinal(number) {
        var i = number % 10;
        var ii = number % 100;

        if ((ii >= 11 && ii <= 13) || i === 0 || i >= 4) {
            return 'th';
        }
        switch (i) {
            case 1: return 'st';
            case 2: return 'nd';
            case 3: return 'rd';
        }
    }

    function getTimestampToUtcOffsetFor(date) {
        return (date.getTimezoneOffset() || 0) * 60000;
    }

    // Tries to get a short timezone name using Date.toLocaleString, falling back on the platform default
    // using Date.toString if necessary.
    function getTimezoneName(date, localeIdentifier) {
        return getShortTimezoneName(date, localeIdentifier) || getDefaultTimezoneName(date);
    }

    // Unfortunately this returns GMT+2 when running with `TZ=Europe/Amsterdam node test.js` so it's not
    // perfect.
    function getShortTimezoneName(date, localeIdentifier) {
        if (localeIdentifier == null) return null;

        var tzString = date
            .toLocaleString(localeIdentifier, { timeZoneName: 'short' })
            .match(/\s([\w]+)$/);
        return tzString && tzString[1];
    }

    // This varies by platform so it's not an ideal way to get the time zone name. On most platforms it's
    // a short name but in Node v10+ and Chrome 66+ it's a long name now. Prefer getShortTimezoneName(date)
    // where possible.
    function getDefaultTimezoneName(date) {
        var tzString = date.toString().match(/\(([\w\s]+)\)/);
        return tzString && tzString[1];
    }

    function warn(message) {
        if (typeof console !== 'undefined' && typeof console.warn == 'function') {
            console.warn(message)
        }
    }

}());


/***/ }),

/***/ 458:
/***/ ((__unused_webpack_module, exports) => {

/*! https://mths.be/utf8js v3.0.0 by @mathias */
;(function(root) {

	var stringFromCharCode = String.fromCharCode;

	// Taken from https://mths.be/punycode
	function ucs2decode(string) {
		var output = [];
		var counter = 0;
		var length = string.length;
		var value;
		var extra;
		while (counter < length) {
			value = string.charCodeAt(counter++);
			if (value >= 0xD800 && value <= 0xDBFF && counter < length) {
				// high surrogate, and there is a next character
				extra = string.charCodeAt(counter++);
				if ((extra & 0xFC00) == 0xDC00) { // low surrogate
					output.push(((value & 0x3FF) << 10) + (extra & 0x3FF) + 0x10000);
				} else {
					// unmatched surrogate; only append this code unit, in case the next
					// code unit is the high surrogate of a surrogate pair
					output.push(value);
					counter--;
				}
			} else {
				output.push(value);
			}
		}
		return output;
	}

	// Taken from https://mths.be/punycode
	function ucs2encode(array) {
		var length = array.length;
		var index = -1;
		var value;
		var output = '';
		while (++index < length) {
			value = array[index];
			if (value > 0xFFFF) {
				value -= 0x10000;
				output += stringFromCharCode(value >>> 10 & 0x3FF | 0xD800);
				value = 0xDC00 | value & 0x3FF;
			}
			output += stringFromCharCode(value);
		}
		return output;
	}

	function checkScalarValue(codePoint) {
		if (codePoint >= 0xD800 && codePoint <= 0xDFFF) {
			throw Error(
				'Lone surrogate U+' + codePoint.toString(16).toUpperCase() +
				' is not a scalar value'
			);
		}
	}
	/*--------------------------------------------------------------------------*/

	function createByte(codePoint, shift) {
		return stringFromCharCode(((codePoint >> shift) & 0x3F) | 0x80);
	}

	function encodeCodePoint(codePoint) {
		if ((codePoint & 0xFFFFFF80) == 0) { // 1-byte sequence
			return stringFromCharCode(codePoint);
		}
		var symbol = '';
		if ((codePoint & 0xFFFFF800) == 0) { // 2-byte sequence
			symbol = stringFromCharCode(((codePoint >> 6) & 0x1F) | 0xC0);
		}
		else if ((codePoint & 0xFFFF0000) == 0) { // 3-byte sequence
			checkScalarValue(codePoint);
			symbol = stringFromCharCode(((codePoint >> 12) & 0x0F) | 0xE0);
			symbol += createByte(codePoint, 6);
		}
		else if ((codePoint & 0xFFE00000) == 0) { // 4-byte sequence
			symbol = stringFromCharCode(((codePoint >> 18) & 0x07) | 0xF0);
			symbol += createByte(codePoint, 12);
			symbol += createByte(codePoint, 6);
		}
		symbol += stringFromCharCode((codePoint & 0x3F) | 0x80);
		return symbol;
	}

	function utf8encode(string) {
		var codePoints = ucs2decode(string);
		var length = codePoints.length;
		var index = -1;
		var codePoint;
		var byteString = '';
		while (++index < length) {
			codePoint = codePoints[index];
			byteString += encodeCodePoint(codePoint);
		}
		return byteString;
	}

	/*--------------------------------------------------------------------------*/

	function readContinuationByte() {
		if (byteIndex >= byteCount) {
			throw Error('Invalid byte index');
		}

		var continuationByte = byteArray[byteIndex] & 0xFF;
		byteIndex++;

		if ((continuationByte & 0xC0) == 0x80) {
			return continuationByte & 0x3F;
		}

		// If we end up here, it’s not a continuation byte
		throw Error('Invalid continuation byte');
	}

	function decodeSymbol() {
		var byte1;
		var byte2;
		var byte3;
		var byte4;
		var codePoint;

		if (byteIndex > byteCount) {
			throw Error('Invalid byte index');
		}

		if (byteIndex == byteCount) {
			return false;
		}

		// Read first byte
		byte1 = byteArray[byteIndex] & 0xFF;
		byteIndex++;

		// 1-byte sequence (no continuation bytes)
		if ((byte1 & 0x80) == 0) {
			return byte1;
		}

		// 2-byte sequence
		if ((byte1 & 0xE0) == 0xC0) {
			byte2 = readContinuationByte();
			codePoint = ((byte1 & 0x1F) << 6) | byte2;
			if (codePoint >= 0x80) {
				return codePoint;
			} else {
				throw Error('Invalid continuation byte');
			}
		}

		// 3-byte sequence (may include unpaired surrogates)
		if ((byte1 & 0xF0) == 0xE0) {
			byte2 = readContinuationByte();
			byte3 = readContinuationByte();
			codePoint = ((byte1 & 0x0F) << 12) | (byte2 << 6) | byte3;
			if (codePoint >= 0x0800) {
				checkScalarValue(codePoint);
				return codePoint;
			} else {
				throw Error('Invalid continuation byte');
			}
		}

		// 4-byte sequence
		if ((byte1 & 0xF8) == 0xF0) {
			byte2 = readContinuationByte();
			byte3 = readContinuationByte();
			byte4 = readContinuationByte();
			codePoint = ((byte1 & 0x07) << 0x12) | (byte2 << 0x0C) |
				(byte3 << 0x06) | byte4;
			if (codePoint >= 0x010000 && codePoint <= 0x10FFFF) {
				return codePoint;
			}
		}

		throw Error('Invalid UTF-8 detected');
	}

	var byteArray;
	var byteCount;
	var byteIndex;
	function utf8decode(byteString) {
		byteArray = ucs2decode(byteString);
		byteCount = byteArray.length;
		byteIndex = 0;
		var codePoints = [];
		var tmp;
		while ((tmp = decodeSymbol()) !== false) {
			codePoints.push(tmp);
		}
		return ucs2encode(codePoints);
	}

	/*--------------------------------------------------------------------------*/

	root.version = '3.0.0';
	root.encode = utf8encode;
	root.decode = utf8decode;

}( false ? 0 : exports));


/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			id: moduleId,
/******/ 			loaded: false,
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/global */
/******/ 	(() => {
/******/ 		__webpack_require__.g = (function() {
/******/ 			if (typeof globalThis === 'object') return globalThis;
/******/ 			try {
/******/ 				return this || new Function('return this')();
/******/ 			} catch (e) {
/******/ 				if (typeof window === 'object') return window;
/******/ 			}
/******/ 		})();
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/node module decorator */
/******/ 	(() => {
/******/ 		__webpack_require__.nmd = (module) => {
/******/ 			module.paths = [];
/******/ 			if (!module.children) module.children = [];
/******/ 			return module;
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be in strict mode.
(() => {
"use strict";

// NAMESPACE OBJECT: ./node_modules/riot/esm/riot.js
var riot_namespaceObject = {};
__webpack_require__.r(riot_namespaceObject);
__webpack_require__.d(riot_namespaceObject, {
  "__": () => (__),
  "component": () => (component),
  "install": () => (install),
  "mount": () => (mount),
  "pure": () => (pure),
  "register": () => (register),
  "uninstall": () => (uninstall),
  "unmount": () => (unmount),
  "unregister": () => (unregister),
  "version": () => (version),
  "withTypes": () => (withTypes)
});

// EXTERNAL MODULE: ./node_modules/base-64/base64.js
var base64 = __webpack_require__(501);
// EXTERNAL MODULE: ./node_modules/utf8/utf8.js
var utf8_utf8 = __webpack_require__(458);
;// CONCATENATED MODULE: ./node_modules/@wendig/lib/src/util.js



function shorten(str, n = 30) {
  if (str && str.length > n) {
    return str.substr(0, n - 1) + '…'
  }
  else {
    return str
  }
}

function inGroupsOf(perRow, array, dummy = undefined) {
  if (perRow < 1) {
    throw `perRow has to be greater than 0 (${perRow})`
  }

  let result = []
  let current = []
  for (const i of array) {
    if (current.length == perRow) {
      result.push(current)
      current = []
    }

    current.push(i)
  }
  if (current.length > 0) {
    if (dummy !== undefined) {
      while (current.length < perRow) {
        current.push(dummy)
      }
    }

    result.push(current)
  }

  return result
}

function capitalize(string) {
  if (typeof string != 'string') {
    return string
  }

  return string.charAt(0).toUpperCase() + string.slice(1)
}

function compact(object, deep = false) {
  let result = {...object}
  for (const [k, v] of Object.entries(object)) {
    if (v === null || v === undefined)  {
      delete result[k]
    } else {
      if (deep && typeof v === 'object') {
        result[k] = compact(v)
      }
    }
  }
  return result
}

function toPage(value) {
  if (typeof value == 'string') {return parseInt(value, 10)}

  return 1
}

function toBase64(string) {
  if (typeof atob !== 'undefined') {
    return btoa(string)
  } else {
    return Buffer.from(string, 'utf-8').toString('base64')
  }
}

function fromBase64(string) {
  if (typeof btoa !== 'undefined') {
    return atob(string)
  } else {
    return Buffer.from(string, 'base64').toString('utf-8')
  }
}

class VwUnit {
  setup() {
    window.addEventListener('resize', this.recalculate)
    this.recalculate()
  }

  recalculate() {
    let vw = document.documentElement.clientWidth / 100;
    console.log(`detected usable page width of ${vw}px`)
    document.documentElement.style.setProperty('--vw', `${vw}px`);
  }
}

const fold = (str) => {
  if (str == undefined) {return str}

  return str.toString().trim().toLowerCase().
    replaceAll(/[äáàâå]/g, 'a').
    replaceAll(/[öóòôðø]/g, 'o').
    replaceAll(/[iíìî]/g, 'i').
    replaceAll(/[ëéèê]/g, 'e').
    replaceAll(/[üúùû]/g, 'u').
    replaceAll(/[ÿ]/g, 'y').
    replaceAll(/[ćč]/g, 'c').
    replaceAll(/[ł]/g, 'l').
    replaceAll(/[śš]/g, 's').
    replaceAll(/[ż]/g, 'z').
    replaceAll(/æ/g, 'ae').
    replaceAll(/ß/g, 'ss').
    replaceAll(/ł/g, 'l')

}

const regEscape = (str) => {
  return str.toString().
    replaceAll(/\./g, "\\.").
    replaceAll(/\$/g, "\\$").
    replaceAll(/\^/g, "\\^").
    replaceAll(/\(/g, "\\(").
    replaceAll(/\)/g, "\\)")
}

const camelToSnakeCase = (str) => {
  if (typeof str != 'string') {
    return str
  }

  return str.replaceAll(/([A-Z])/g, (m) => '_' + m.toLowerCase(m))
}

const transformKeys = (obj, f) => {
  const result = {}
  for (const [k, v] of Object.entries(obj)) {
    result[f(k)] = v
  }
  return result
}

const printElement = (element, {css, print=true} = {}) => {
  const w = window.open('', 'PRINT', 'height=800,width=1024')
  const html = `
    <html>
      <head>
        <meta charset="utf-8" />
        <title>${document.title}</title>
        <style>${css}</style>
      </head>
      <body>${element.innerHTML}</body>
    </html>
  `
  w.document.write(html)
  w.document.close()

  w.addEventListener('afterprint', (event) => {
    // we use a timeout here because firefox tries to close the window before
    // the print dialog is removed which fails to close the window
    w.setTimeout(() => w.close(), 1)
  })
  if (print) {w.print()}
}

const dataUri = (data, contentType = 'text/plain') => {
  const u = utf8.encode(data)
  const b64 = Base64.encode(u)
  return `data:${contentType};base64,${b64}`
}

const download = (data, {contentType='text/plain', filename='data.txt'}) => {
  const uri = dataUri(data, contentType)
  const a = document.createElement('a')
  a.download = filename
  a.setAttribute('href', uri)

  document.documentElement.append(a)
  a.click()
}

const sortBy = (array, f) => {
  return [...array].sort((a, b) => {
    const af = f(a)
    const bf = f(b)

    if (af > bf) return 1
    if (af < bf) return -1

    return 0
  })
}

function parents(element, selector) {
  if (element.matches(selector)) {
    return element
  }

  if (element.parentElement == null) {
    return null
  }

  return parents(element.parentElement, selector)
}

function util_fetchWorker(url) {
  return fetch(url).then(r => r.text()).then(src => {
    const blob = new Blob([src], {type: 'application/javascript'})
    const url = URL.createObjectURL(blob);
    return new Worker(url)
  })
}

function dashToCamel(str) {
  return str.replaceAll(/\-(.)/g, (m) => m[1].toUpperCase())
}

function range(limits) {
  const [from, to] = limits
  if (to < from) return []


  const result = new Array(to - from + 1)
  return Array.from(result, (e, i) => i + from)
}

function mapTo(value, fromRange, toRange=[0.0, 1.0]) {
  let result = value - fromRange[0]
  result /= fromRange[1] - fromRange[0]
  result *= toRange[1] - toRange[0]
  return result + toRange[0]
}

function clamp(value, range=[0.0, 1.0]) {
  return Math.min(Math.max(value, range[0]), range[1])
}

function randomString(length, characters=null) {
  const pool = characters || [
    'abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    '0123456789'
  ].join('')

  let result = []
  for (let i = 0; i < length; i++) {
    const index = Math.floor(Math.random() * pool.length)
    result.push(pool[index])
  }
  return result.join('')
}

const delay = (f, ms) => {
  let timeout = null

  const future = (resolve, ...args) => {
    const result = f(...args)
    resolve(result)
  }

  const handler = (...args) => {
    if (timeout) {
      window.clearTimeout(timeout)
    }

    return new Promise((resolve, reject) => {
      timeout = window.setTimeout(future, ms, resolve, ...args)
    })
  }

  return handler
}

const highlight = (str, term) => {
  if (!str) return null
  if (!term) return str

  const folded = fold(str)
  const regex = new RegExp(fold(term), 'g')

  const matches = [...folded.matchAll(regex)].reverse()

  let result = `${str}`
  for (const m of matches) {
    const length = m[0].length
    const index =  m.index

    const prefix = result.slice(0, index)
    const highlight = result.slice(index, index + length)
    const suffix = result.slice(index + length)

    console.log(str, term, prefix, highlight, suffix, index, length, m)
    
    result = `${prefix}<mark>${highlight}</mark>${suffix}`
  }

  return result
}

const wrapTextWith = (node, pattern, element='mark', attribs={}) => {
  if (node.nodeType == Node.TEXT_NODE) {
    // we use the reversed list of matches so that earlier matches don't
    // influence later ones
    const matches = [...node.nodeValue.matchAll(pattern)].reverse()

    for (const m of matches) {
      const subject = node.splitText(m.index)
      const right = subject.splitText(m[0].length)

      const e = document.createElement(element)
      for (const [k, v] of Object.entries(attribs)) e.setAttribute(k, v)
      subject.replaceWith(e)
      e.append(subject)
    }
  } else {
    // we generate a static list of nodes so that replacements aren't iterated
    // on
    const nodes = [...node.childNodes]

    for (const n of nodes) {
      wrapTextWith(n, pattern, element, attribs)
    }
  }
}



;// CONCATENATED MODULE: ./node_modules/@wendig/lib/src/url.js


let forceFragment = true
let nullFragment = '!'

class url_Url {
  constructor(data) {
    const defaults = {
      protocol: 'http',
      port: 80,
      path: '',
      params: {},
      hashPath: '',
      hashParams: {}
    }

    this.data = {...defaults, ...compact(data)}
  }

  static setForceFragment(activate=true, suffix='!') {
    forceFragment = activate
    nullFragment = suffix
  }


  // getters

  protocol() {
    return this.data['protocol']
  }

  host() {
    return this.data['host']
  }

  port() {
    return this.data['port']
  }

  path() {
    return this.data['path']
  }

  params() {
    return this.data['params']
  }

  hashPath() {
    return this.data['hashPath']
  }

  hashParams({decode=true, parseIntList=null} = {}) {
    const result = {...this.data['hashParams']}

    if (decode) {
      for (const [k, v] of Object.entries(result)) {
        result[k] = decodeURIComponent(result[k])
      }
    }

    if (parseIntList) {
      for (const key of parseIntList) {
        if (result.hasOwnProperty(key)) {
          result[key] = parseInt(result[key])
        }
      }
    }

    return result
  }

  pack() {
    const data = this.params()[url_Url.packParam]

    if (data) {
      return JSON.parse(fromBase64(data))
    } else {
      return null
    }
  }

  hashPack() {
    const data = this.hashParams()[url_Url.packParam]

    if (data) {
      return JSON.parse(fromBase64(data))
    } else {
      return null
    }
  }


  // setters

  setProtocol(value) {
    this.data['protocol'] = value
    return this
  }

  setHost(value) {
    this.data['host'] = value
    return this
  }

  setPort(value) {
    this.data['port'] = value
    return this
  }

  setPath(value) {
    this.data['path'] = value
    return this
  }

  setParams(value) {
    this.data['params'] = value
    return this
  }

  setHashPath(value) {
    this.data['hashPath'] = value
    return this
  }

  setHashParams(value) {
    this.data['hashParams'] = value
    return this
  }

  updateParams(values) {
    for (const [k, v] of Object.entries(values)) {
      if (v === null) {
        delete this.data['params'][k]
      } else {
        this.data['params'][k] = v
      }
    }

    return this
  }

  updateHashParams(values) {
    for (const [k, v] of Object.entries(values)) {
      if (v === null) {
        delete this.data['hashParams'][k]
      } else {
        this.data['hashParams'][k] = v
      }
    }

    return this
  }

  setPack(data) {
    if (data === null || data === undefined) {
      delete this.data['params'][url_Url.packParam]
    } else {
      this.data['params'][url_Url.packParam] = toBase64(JSON.stringify(data))
    }

    return this
  }

  setHashPack(data) {
    if (data === null || data === undefined) {
      delete this.data['hashParams'][url_Url.packParam]
    } else {
      this.data['hashParams'][url_Url.packParam] = toBase64(JSON.stringify(data))
    }

    return this
  }

  apply(replace=false) {
    if (typeof window === 'undefined') {return undefined}
    if (document.location.href === this.url()) {return this}

    if (replace) {
      document.location.replace(this.url())
    } else {
      document.location.href = this.url()
    }

    return this
  }

  replaceState() {
    if (typeof window === 'undefined') {return undefined}

    history.replaceState(null, '', this.url())
  
    return this
  }


  // to string

  escape(str) {
    return encodeURIComponent(str)
  }

  formatPort() {
    const isHttp80 = (this.data['protocol'] === 'http' && this.data['port'] === 80)
    const isHttps443 = (this.data['protocol'] === 'https' && this.data['port'] === 443)

    return (isHttp80 || isHttps443) ? '' : `:${this.data['port']}`
  }

  origin() {
    if (!this.data['protocol'] || !this.data['host'] || !this.data['port']) {
      return ''
    }

    return `${this.data['protocol']}://${this.data['host']}${this.formatPort()}`
  }

  formatQuery(params) {
    if (Object.keys(params).length === 0) {return ''}

    return '?' + Object.
      entries(params).
      map(i => `${i[0]}=${this.escape(i[1])}`).
      join('&')
  }

  formatHash() {
    if (this.hashPath() === '' && Object.keys(this.hashParams()).length === 0) {
      return forceFragment ? `#${nullFragment}` : ''
    }

    const query = this.formatQuery(this.hashParams())
    return `#${this.hashPath()}${query}`
  }

  resource() {
    const query = this.formatQuery(this.params())
    return `${this.path()}${query}${this.formatHash()}`
  }

  url() {
    return `${this.origin()}${this.resource()}`
  }


  // parse

  static parseQuery(string) {
    if (!string) {return {}}

    let result = {}
    for (const pair of string.split('&')) {
      const [k, v] = pair.split('=')
      result[k] = v
    }
    return result
  }

  static portFor(protocol) {
    return {
      'http': 80,
      'https': 443,
      'mysql': 3306
    }[protocol]
  }

  static parse(string) {
    const [nohash, hash] = string.split('#')
    const [noquery, query] = nohash.split('?')
    const [protocol, noproto] = noquery.split('://')
    const [nopath, path] = noproto.match(/^([^\/]+)(.*)$/).slice(1)
    const [host, port] = nopath.split(':')

    const [hashPath, hashQuery] = (hash ? hash.split('?') : [])

    const params = this.parseQuery(query)
    const hashParams = this.parseQuery(hashQuery)

    return new url_Url({
      protocol: protocol,
      host: host,
      port: (port ? parseInt(port) : this.portFor(protocol)),
      path: path,
      params: params,
      hashPath: hashPath == nullFragment ? '' : hashPath,
      hashParams: hashParams
    })
  }

  static current() {
    if (typeof window === 'undefined') {return undefined}
      
    return url_Url.parse(window.document.location.href)
  }
}

url_Url.packParam = 'p'

/* harmony default export */ const url = ((/* unused pure expression or super */ null && (url_Url)));

;// CONCATENATED MODULE: ./node_modules/@wendig/lib/src/urlSearch.js


const defaultGetParams = () => {
  const url = Url.current()
  return url.hashParams()
}

class UrlSearch {
  constructor(component, getParams = null) {
    this.cmp = component
    this.getParams = getParams || defaultGetParams
  }

  setup() {
    this.cmp.state = this.cmp.state || {}
    this.cmp.state['criteria'] = {}

    this.cmp.onDelayedInput = (values) => this.onDelayedInput(values)
    this.cmp.onInput = (values) => this.onInput(values)
    this.onUrlChanged = this.onUrlChanged.bind(this)

    window.addEventListener('hashchange', this.onUrlChanged)
    this.onUrlChanged()
  }

  teardown() {
    window.removeEventListener('hasnchange', this.onUrlChanged)
  }

  onInput(values) {
    for (const k of Object.keys(values)) {
      if (!['page', 'per_page', 'perPage'].includes(k)) {
        values['page'] = null
      }
    }
    
    this.updateCriteriaState(values)
    this.cmp.update()

    const url = Url.current()
    url.updateHashParams(values)
    url.apply()
  }

  onUrlChanged(event) {
    const p = this.getParams()

    this.updateCriteriaState(p, true)
    if (event) {this.cmp.update()}

    this.cmp.onSearch(p)
  }

  onDelayedInput(values) {
    if (this.timeout) {
      window.clearTimeout(this.timeout)
      this.timeout = null
    }

    const handler = () => this.onInput(values)
    this.timeout = window.setTimeout(handler, 300)
  }

  updateCriteriaState(values, reset = false) {
    if (reset) this.cmp.state.criteria = {}

    for (const [k, v] of Object.entries(values)) {
      if (v == null) {
        delete this.cmp.state.criteria[k]
      } else {
        this.cmp.state.criteria[k] = v
      }
    }
  }
}

;// CONCATENATED MODULE: ./node_modules/@wendig/lib/src/search.js



class Search {
  constructor(workerUrl) {
    this.workerUrl = workerUrl
    this.messageId = 10000
    this.resolveMap = {}
    this.initWorker()
  }

  initWorker() {
    this.initPromise = this.initPromise || (
      this.useFetchForWorker() ?
      this.fetchWorker() :
      this.instantiateWorker()
    )

    console.log('worker promise: ', this.initPromise)

    return this.initPromise
  }

  useFetchForWorker() {
    const cu = Url.current()
    const wu = Url.parse(this.workerUrl)

    return cu.origin() != wu.origin()
  }

  fetchWorker() {
    return fetchWorker(this.workerUrl).then(worker => {
      worker.onmessage = event => this.onResponse(event)
      this.worker = worker
      return this.worker
    })
  }

  instantiateWorker() {
    return new Promise((resolve, reject) => {
      this.worker = new Worker(this.workerUrl)
      this.worker.onmessage = event => this.onResponse(event)
      resolve(this.worker)
    })
  }

  onResponse(event) {
    const data = event.data

    const resolve = this.resolveMap[data.messageId]
    if (resolve) {
      delete this.resolveMap[data.messageId]
      resolve(data)
    }
  }

  query(criteria) {
    return this.postMessage({action: 'query', criteria})
  }

  ready() {
    return this.postMessage({action: 'counts'})
  }

  postMessage(data) {
    return this.initPromise.then(() => {
      const newId = this.messageId
      this.messageId += 1

      const promise = new Promise((resolve, reject) => {
        this.resolveMap[newId] = resolve

        data.messageId = newId
        this.worker.postMessage(data)
      })

      return promise
    })
  }
}

;// CONCATENATED MODULE: ./node_modules/@wendig/lib/src/i18n.js
class I18n {
  constructor() {
    this.locale = 'en'
    this.translations = null
    this.fallbacks = []

    this.fetch = this.fetch.bind(this)
    this.setLocale = this.setLocale.bind(this)
    this.setFallbacks = this.setFallbacks.bind(this)
    this.translate = this.translate.bind(this)
    this.localize = this.localize.bind(this)
    this.translatedCounter = this.translatedCounter.bind(this)
  }

  fetch(url) {
    return fetch(url).
      then(r => r.json()).
      then(data => this.translations = data)
  }

  setLocale(newLocale) {
    this.locale = newLocale
  }

  setFallbacks(fallbacks) {
    this.fallbacks = fallbacks
  }

  lookup(key) {
    const sets = (
      Array.isArray(this.translations) ?
      this.translations :
      [this.translations]
    )

    for (const set of sets) {
      const candidate = set[this.locale][key]
      if (candidate) {return candidate}
    }
  }

  translate(key, opts = {}) {
    if (!this.translations) {
      return "TRANSLATIONS NOT LOADED"
    }

    try {
      let result = this.lookup(key)

      for (const [k, v] of Object.entries(opts)) {
        const regex = new RegExp(`\\%\\{${k}\\}`, 'g')
        console.log(typeof result)
        result = result.replaceAll(regex, v)
      }

      return result
    } catch(e) {
      console.warn(e)
      return `not found: '${this.locale}:${key}'`
    }
  }

  translatedCounter(amount, singular, plural) {
    if (amount == 1) {
      return `${amount} ${this.translate(singular)}`
    } else {
      return `${amount} ${this.translate(plural)}`
    }
  }

  localize(object) {
    if (typeof object == 'object') {
      const json = JSON.stringify(object)
      const locales = [this.locale, ...this.fallbacks]
      for (const l of locales) {
        const result = object[l]
        if (result) {
          return result
        }
      }

      return `NO TRANSLATION FOR locale ${this.locale} for ${json}`
    }

    return object
  }
}

const i18n = new I18n()



;// CONCATENATED MODULE: ./node_modules/@wendig/lib/src/riotPlugins.js



let DCIP = null

function site() {
  if (typeof document == 'undefined') return null

  const e = document.querySelector('title')
  if (!e) return null

  return e.textContent
}

const getParent = (component) => {
  let element = component.root
  while (element = element.parentNode) {
    if (element[DCIP]) {
      return element[DCIP]
    }
  }

  return null
}

class RiotPlugins {
  static setup(riot) {
    DCIP = riot.__.globals['DOM_COMPONENT_INSTANCE_PROPERTY']
  }

  static parent(component) {
    const {onBeforeMount, onBeforeUnmount} = component

    component.onBeforeMount = (props, state) => {
      const parent = getParent(component)
      
      if (parent) {
        parent.tags = parent.tags || {}
        parent.tags[component.name] = parent.tags[component.name] || []
        parent.tags[component.name].push(component)
      }

      onBeforeMount.apply(component, [props, state])
    }

    component.onBeforeUnmount = (props, state) => {
      const parent = getParent(component)

      if (parent) {
        const arr = parent.tags[component.name]
        if (arr) {
          const index = arr.indexOf(component)
          arr.splice(index, 1)
          if (!arr.length) {
            delete parent.tags[component.name]
          }
        }
      }

      onBeforeUnmount.apply(component, [props, state])
    }

    return component
  }

  static i18n(component) {
    const {onBeforeMount} = component

    component.onBeforeMount = (props, state) => {
      component.t = i18n.translate
      component.l = i18n.localize
      component.cap = capitalize
      component.tCounter = i18n.translatedCounter

      onBeforeMount.apply(component, [props, state])
    }
  }

  static setTitle(component) {
    const {onBeforeMount, onBeforeUpdate, onBeforeUnmount} = component
    let current = site()

    component.onBeforeMount = (props, state) => {
      const e = document.querySelector('title')

      if (typeof component.title == 'function') {
        if (component.title()) {
          const replace = component.props.replaceTitle
          if (replace) e.textContent = component.title()
          else e.textContent = `${current} - ${component.title()}`
        }
      }

      onBeforeMount.apply(component, [props, state])
    }

    component.onBeforeUpdate = (props, state) => {
      const e = document.querySelector('title')

      if (typeof component.title == 'function') {
        if (component.title()) {
          const replace = component.props.replaceTitle
          if (replace) e.textContent = component.title()
          else e.textContent = `${current} - ${component.title()}`
        }
      }

      onBeforeUpdate.apply(component, [props, state])
    }

    component.onBeforeUnmount = (props, state) => {
      const e = document.querySelector('title')

      if (typeof component.title == 'function') {
        const replace = component.props.replaceTitle
        if (current) {
          e.textContent = current
        }
      }

      onBeforeUnmount.apply(component, [props, state])
    }
  }

}

/* harmony default export */ const riotPlugins = (RiotPlugins);

;// CONCATENATED MODULE: ./node_modules/@wendig/lib/src/bus.js
class AppEvent extends Event {
  constructor(typeArg, data = null) {
    super(typeArg)
    this.data = data
  }
}

class Bus extends EventTarget {
  constructor() {
    super()

    this.data = {}
  }

  emit(name, data) {
    const event = new AppEvent(name, data)
    this.dispatchEvent(event)
  }
}

const bus = new Bus()

function BusRiotPlugin(component) {
  const {onBeforeMount, onBeforeUnmount} = component

  component.onBeforeMount = (props, state) => {
    component.bus = bus
    component.handlers = []

    onBeforeMount.apply(component, [props, state])
  }

  component.on = (event, handler) => {
    component.handlers.push([event, handler])
    bus.addEventListener(event, handler)
  }

  component.onBeforeUnmount = (props, state) => {
    for (const [e, h] of component.handlers) {
      bus.removeEventListener(e, h)
    }

    onBeforeUnmount.apply(component, [props, state])
  }
}


;// CONCATENATED MODULE: ./node_modules/@wendig/lib/main.js









const main_VwUnit = VwUnit



;// CONCATENATED MODULE: ./app/assets/js/lib/util.js


const util_clamp = (value, min, max) => {
  let result = Math.min(value, max)
  return Math.max(result, min)
}

const util_delay = (f, ms) => {
  let timeout = null

  const future = (resolve, ...args) => {
    const result = f(...args)
    resolve(result)
  }

  const handler = (...args) => {
    if (timeout) {
      window.clearTimeout(timeout)
    }

    return new Promise((resolve, reject) => {
      timeout = window.setTimeout(future, ms, resolve, ...args)
    })
  }

  return handler
}

let requests = 0
let csrfToken = null
const request = (url, init = {}) => {
  init['method'] = init['method'] || 'get'
  init['headers'] = init['headers'] || {}
  init['headers']['content-type'] = 'application/json'

  const method = init['method'].toLowerCase()
  if (!['get', 'head', 'options'].includes(method)) {
    if (!csrfToken) {
      const csrf = document.querySelector("meta[name='csrf-token']")
      csrfToken = csrf.getAttribute('content')
    }
    init['headers']['X-CSRF-Token'] = csrfToken
  }

  if (init['body']) {
    if (init['headers']['content-type'] == 'application/json') {
      if (!isString(init['body'])) {
        init['body'] = JSON.stringify(init['body'])
      }
    }
  }

  requests += 1
  const promise = fetch(url, init).then(r => r.json())
  bus.emit('loading-state-change', {count: requests})
  promise.then(data => {
    requests -= 1
    bus.emit('loading-state-change', {count: requests})
  })

  return promise
}

const locale = () => {
  const url = document.location.href
  const m = url.match(/\/(en|de)\//)
  return !!m ? m[1] : 'de'
}

const isString = (value) => {
  return typeof value == 'string' || value instanceof String
}



;// CONCATENATED MODULE: ./app/assets/js/lib/i18n.js



window.i18n = i18n

i18n.translations = {}

function flatten(tree, prefix = '') {
  let result = {}

  for (const [k, v] of Object.entries(tree)) {
    if (v.constructor && v.constructor.name == 'Object') {
      Object.assign(result, flatten(v, `${prefix}${k}.`))
    } else {
      result[`${prefix}${k}`] = v
    }
  }

  return result
}

/* harmony default export */ function lib_i18n() {
  const promise = request('/api/json/translations')

  promise.then((data) => {
    let t = {
      'en': {},
      'de': {}
    }

    // legacy data, using as is
    Object.assign(t['de'], data['legacy'])

    // legacy data, self-reference and use for en as well
    const en = Object.fromEntries(Object.entries(data['legacy']).map(([k, v]) => [k, k]))
    Object.assign(t['en'], en)

    // rails style data
    Object.assign(t['de'], flatten(data['rails']['de']))
    Object.assign(t['en'], flatten(data['rails']['en']))

    i18n.translations = t

    const locale = document.location.href.match(/\/(en|de)($|\/)/)[1]
    i18n.setLocale(locale)

    console.log('translations loaded')
  })

  return promise
}

;// CONCATENATED MODULE: ./node_modules/@riotjs/util/binding-types.js
const EACH = 0
const IF = 1
const SIMPLE = 2
const TAG = 3
const SLOT = 4

/* harmony default export */ const binding_types = ({
  EACH,
  IF,
  SIMPLE,
  TAG,
  SLOT
});
;// CONCATENATED MODULE: ./node_modules/@riotjs/util/checks.js
/**
 * Quick type checking
 * @param   {*} element - anything
 * @param   {string} type - type definition
 * @returns {boolean} true if the type corresponds
 */
function checkType(element, type) {
  return typeof element === type
}

/**
 * Check if an element is part of an svg
 * @param   {HTMLElement}  el - element to check
 * @returns {boolean} true if we are in an svg context
 */
function isSvg(el) {
  const owner = el.ownerSVGElement

  return !!owner || owner === null
}

/**
 * Check if an element is a template tag
 * @param   {HTMLElement}  el - element to check
 * @returns {boolean} true if it's a <template>
 */
function isTemplate(el) {
  return el.tagName.toLowerCase() === 'template'
}

/**
 * Check that will be passed if its argument is a function
 * @param   {*} value - value to check
 * @returns {boolean} - true if the value is a function
 */
function isFunction(value) {
  return checkType(value, 'function')
}

/**
 * Check if a value is a Boolean
 * @param   {*}  value - anything
 * @returns {boolean} true only for the value is a boolean
 */
function isBoolean(value) {
  return checkType(value, 'boolean')
}

/**
 * Check if a value is an Object
 * @param   {*}  value - anything
 * @returns {boolean} true only for the value is an object
 */
function isObject(value) {
  return !isNil(value) && value.constructor === Object
}

/**
 * Check if a value is null or undefined
 * @param   {*}  value - anything
 * @returns {boolean} true only for the 'undefined' and 'null' types
 */
function isNil(value) {
  return value === null || value === undefined
}

/**
 * Detect node js environements
 * @returns {boolean} true if the runtime is node
 */
function isNode() {
  return typeof process !== 'undefined'
}

;// CONCATENATED MODULE: ./node_modules/@riotjs/util/constants.js
// Riot.js constants that can be used accross more modules

const
  COMPONENTS_IMPLEMENTATION_MAP = new Map(),
  DOM_COMPONENT_INSTANCE_PROPERTY = Symbol('riot-component'),
  PLUGINS_SET = new Set(),
  IS_DIRECTIVE = 'is',
  VALUE_ATTRIBUTE = 'value',
  MOUNT_METHOD_KEY = 'mount',
  UPDATE_METHOD_KEY = 'update',
  UNMOUNT_METHOD_KEY = 'unmount',
  SHOULD_UPDATE_KEY = 'shouldUpdate',
  ON_BEFORE_MOUNT_KEY = 'onBeforeMount',
  ON_MOUNTED_KEY = 'onMounted',
  ON_BEFORE_UPDATE_KEY = 'onBeforeUpdate',
  ON_UPDATED_KEY = 'onUpdated',
  ON_BEFORE_UNMOUNT_KEY = 'onBeforeUnmount',
  ON_UNMOUNTED_KEY = 'onUnmounted',
  PROPS_KEY = 'props',
  STATE_KEY = 'state',
  SLOTS_KEY = 'slots',
  ROOT_KEY = 'root',
  IS_PURE_SYMBOL = Symbol('pure'),
  IS_COMPONENT_UPDATING = Symbol('is_updating'),
  PARENT_KEY_SYMBOL = Symbol('parent'),
  ATTRIBUTES_KEY_SYMBOL = Symbol('attributes'),
  TEMPLATE_KEY_SYMBOL = Symbol('template')

;// CONCATENATED MODULE: ./node_modules/@riotjs/util/strings.js
/**
 * Convert a string from camel case to dash-case
 * @param   {string} string - probably a component tag name
 * @returns {string} component name normalized
 */
function camelToDashCase(string) {
  return string.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
}

/**
 * Convert a string containing dashes to camel case
 * @param   {string} string - input string
 * @returns {string} my-string -> myString
 */
function dashToCamelCase(string) {
  return string.replace(/-(\w)/g, (_, c) => c.toUpperCase())
}
;// CONCATENATED MODULE: ./node_modules/@riotjs/util/dom.js


/**
 * Get all the element attributes as object
 * @param   {HTMLElement} element - DOM node we want to parse
 * @returns {Object} all the attributes found as a key value pairs
 */
function DOMattributesToObject(element) {
  return Array.from(element.attributes).reduce((acc, attribute) => {
    acc[dashToCamelCase(attribute.name)] = attribute.value
    return acc
  }, {})
}

/**
 * Move all the child nodes from a source tag to another
 * @param   {HTMLElement} source - source node
 * @param   {HTMLElement} target - target node
 * @returns {undefined} it's a void method ¯\_(ツ)_/¯
 */

// Ignore this helper because it's needed only for svg tags
function moveChildren(source, target) {
  target.replaceChildren(...source.childNodes)
}

/**
 * Remove the child nodes from any DOM node
 * @param   {HTMLElement} node - target node
 * @returns {undefined}
 */
function cleanNode(node) {
  // eslint-disable-next-line fp/no-loops
  while (node.firstChild) node.removeChild(node.firstChild)
}

/**
 * Clear multiple children in a node
 * @param   {HTMLElement[]} children - direct children nodes
 * @returns {undefined}
 */
function clearChildren(children) {
  // eslint-disable-next-line fp/no-loops,fp/no-let
  for (let i = 0;i < children.length; i++) removeChild(children[i])
}


/**
 * Remove a node
 * @param {HTMLElement}node - node to remove
 * @returns {undefined}
 */
const removeChild = node => node && node.parentNode && node.parentNode.removeChild(node)

/**
 * Insert before a node
 * @param {HTMLElement} newNode - node to insert
 * @param {HTMLElement} refNode - ref child
 * @returns {undefined}
 */
const insertBefore = (newNode, refNode) => refNode && refNode.parentNode && refNode.parentNode.insertBefore(newNode, refNode)

/**
 * Replace a node
 * @param {HTMLElement} newNode - new node to add to the DOM
 * @param {HTMLElement} replaced - node to replace
 * @returns {undefined}
 */
const replaceChild = (newNode, replaced) => replaced && replaced.parentNode && replaced.parentNode.replaceChild(newNode, replaced)

;// CONCATENATED MODULE: ./node_modules/@riotjs/util/expression-types.js
const ATTRIBUTE = 0
const EVENT = 1
const TEXT = 2
const VALUE = 3

/* harmony default export */ const expression_types = ({
  ATTRIBUTE,
  EVENT,
  TEXT,
  VALUE
});
;// CONCATENATED MODULE: ./node_modules/@riotjs/util/functions.js


// does simply nothing
function noop() {
  return this
}

/**
 * Autobind the methods of a source object to itself
 * @param   {Object} source - probably a riot tag instance
 * @param   {Array<string>} methods - list of the methods to autobind
 * @returns {Object} the original object received
 */
function autobindMethods(source, methods) {
  methods.forEach(method => {
    source[method] = source[method].bind(source)
  })

  return source
}

/**
 * Call the first argument received only if it's a function otherwise return it as it is
 * @param   {*} source - anything
 * @returns {*} anything
 */
function callOrAssign(source) {
  return isFunction(source) ? (source.prototype && source.prototype.constructor ?
    new source() : source()
  ) : source
}

;// CONCATENATED MODULE: ./node_modules/@riotjs/util/misc.js



/**
 * Throw an error with a descriptive message
 * @param   { string } message - error message
 * @returns { undefined } hoppla.. at this point the program should stop working
 */
function panic(message) {
  throw new Error(message)
}
/**
 * Returns the memoized (cached) function.
 * // borrowed from https://www.30secondsofcode.org/js/s/memoize
 * @param {Function} fn - function to memoize
 * @returns {Function} memoize function
 */
function memoize(fn) {
  const cache = new Map()
  const cached = val => {
    return cache.has(val) ? cache.get(val) : cache.set(val, fn.call(this, val)) && cache.get(val)
  }
  cached.cache = cache
  return cached
}

/**
 * Evaluate a list of attribute expressions
 * @param   {Array} attributes - attribute expressions generated by the riot compiler
 * @returns {Object} key value pairs with the result of the computation
 */
function evaluateAttributeExpressions(attributes) {
  return attributes.reduce((acc, attribute) => {
    const {value, type} = attribute

    switch (true) {
    // spread attribute
    case !attribute.name && type === ATTRIBUTE:
      return {
        ...acc,
        ...value
      }
    // value attribute
    case type === VALUE:
      acc.value = attribute.value
      break
    // normal attributes
    default:
      acc[dashToCamelCase(attribute.name)] = attribute.value
    }

    return acc
  }, {})
}

;// CONCATENATED MODULE: ./node_modules/@riotjs/util/objects.js

/**
 * Helper function to set an immutable property
 * @param   {Object} source - object where the new property will be set
 * @param   {string} key - object key where the new property will be stored
 * @param   {*} value - value of the new property
 * @param   {Object} options - set the propery overriding the default options
 * @returns {Object} - the original object modified
 */
function defineProperty(source, key, value, options = {}) {
  /* eslint-disable fp/no-mutating-methods */
  Object.defineProperty(source, key, {
    value,
    enumerable: false,
    writable: false,
    configurable: true,
    ...options
  })
  /* eslint-enable fp/no-mutating-methods */

  return source
}

/**
 * Define multiple properties on a target object
 * @param   {Object} source - object where the new properties will be set
 * @param   {Object} properties - object containing as key pair the key + value properties
 * @param   {Object} options - set the propery overriding the default options
 * @returns {Object} the original object modified
 */
function defineProperties(source, properties, options) {
  Object.entries(properties).forEach(([key, value]) => {
    defineProperty(source, key, value, options)
  })

  return source
}

/**
 * Define default properties if they don't exist on the source object
 * @param   {Object} source - object that will receive the default properties
 * @param   {Object} defaults - object containing additional optional keys
 * @returns {Object} the original object received enhanced
 */
function defineDefaults(source, defaults) {
  Object.entries(defaults).forEach(([key, value]) => {
    if (!source[key]) source[key] = value
  })

  return source
}

/**
 * Simple clone deep function, do not use it for classes or recursive objects!
 * @param   {*} source - possibily an object to clone
 * @returns {*} the object we wanted to clone
 */
function cloneDeep(source) {
  return JSON.parse(JSON.stringify(source))
}

;// CONCATENATED MODULE: ./node_modules/@riotjs/util/index.js










;// CONCATENATED MODULE: ./node_modules/riot/esm/core/pure-component-api.js
/* Riot WIP, @license MIT */


const PURE_COMPONENT_API = Object.freeze({
  [MOUNT_METHOD_KEY]: noop,
  [UPDATE_METHOD_KEY]: noop,
  [UNMOUNT_METHOD_KEY]: noop
});



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/mocked-template-interface.js
/* Riot WIP, @license MIT */



const MOCKED_TEMPLATE_INTERFACE = Object.assign({}, PURE_COMPONENT_API, {
  clone: noop,
  createDOM: noop
});



;// CONCATENATED MODULE: ./node_modules/@riotjs/dom-bindings/dist/esm.dom-bindings.js










const HEAD_SYMBOL = Symbol();
const TAIL_SYMBOL = Symbol();

/**
 * Create the <template> fragments text nodes
 * @return {Object} {{head: Text, tail: Text}}
 */
function createHeadTailPlaceholders() {
  const head = document.createTextNode('');
  const tail = document.createTextNode('');

  head[HEAD_SYMBOL] = true;
  tail[TAIL_SYMBOL] = true;

  return {head, tail}
}

/**
 * Create the template meta object in case of <template> fragments
 * @param   {TemplateChunk} componentTemplate - template chunk object
 * @returns {Object} the meta property that will be passed to the mount function of the TemplateChunk
 */
function createTemplateMeta(componentTemplate) {
  const fragment = componentTemplate.dom.cloneNode(true);
  const {head, tail} = createHeadTailPlaceholders();

  return {
    avoidDOMInjection: true,
    fragment,
    head,
    tail,
    children: [head, ...Array.from(fragment.childNodes), tail]
  }
}

/**
 * ISC License
 *
 * Copyright (c) 2020, Andrea Giammarchi, @WebReflection
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
 * OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

// fork of https://github.com/WebReflection/udomdiff version 1.1.0
// due to https://github.com/WebReflection/udomdiff/pull/2
/* eslint-disable */

/**
 * @param {Node[]} a The list of current/live children
 * @param {Node[]} b The list of future children
 * @param {(entry: Node, action: number) => Node} get
 * The callback invoked per each entry related DOM operation.
 * @param {Node} [before] The optional node used as anchor to insert before.
 * @returns {Node[]} The same list of future children.
 */
const udomdiff = (a, b, get, before) => {
  const bLength = b.length;
  let aEnd = a.length;
  let bEnd = bLength;
  let aStart = 0;
  let bStart = 0;
  let map = null;
  while (aStart < aEnd || bStart < bEnd) {
    // append head, tail, or nodes in between: fast path
    if (aEnd === aStart) {
      // we could be in a situation where the rest of nodes that
      // need to be added are not at the end, and in such case
      // the node to `insertBefore`, if the index is more than 0
      // must be retrieved, otherwise it's gonna be the first item.
      const node = bEnd < bLength ?
        (bStart ?
          (get(b[bStart - 1], -0).nextSibling) :
          get(b[bEnd - bStart], 0)) :
        before;
      while (bStart < bEnd)
        insertBefore(get(b[bStart++], 1), node);
    }
    // remove head or tail: fast path
    else if (bEnd === bStart) {
      while (aStart < aEnd) {
        // remove the node only if it's unknown or not live
        if (!map || !map.has(a[aStart]))
          removeChild(get(a[aStart], -1));
        aStart++;
      }
    }
    // same node: fast path
    else if (a[aStart] === b[bStart]) {
      aStart++;
      bStart++;
    }
    // same tail: fast path
    else if (a[aEnd - 1] === b[bEnd - 1]) {
      aEnd--;
      bEnd--;
    }
    // The once here single last swap "fast path" has been removed in v1.1.0
    // https://github.com/WebReflection/udomdiff/blob/single-final-swap/esm/index.js#L69-L85
    // reverse swap: also fast path
    else if (
      a[aStart] === b[bEnd - 1] &&
      b[bStart] === a[aEnd - 1]
    ) {
      // this is a "shrink" operation that could happen in these cases:
      // [1, 2, 3, 4, 5]
      // [1, 4, 3, 2, 5]
      // or asymmetric too
      // [1, 2, 3, 4, 5]
      // [1, 2, 3, 5, 6, 4]
      const node = get(a[--aEnd], -1).nextSibling;
      insertBefore(
        get(b[bStart++], 1),
        get(a[aStart++], -1).nextSibling
      );
      insertBefore(get(b[--bEnd], 1), node);
      // mark the future index as identical (yeah, it's dirty, but cheap 👍)
      // The main reason to do this, is that when a[aEnd] will be reached,
      // the loop will likely be on the fast path, as identical to b[bEnd].
      // In the best case scenario, the next loop will skip the tail,
      // but in the worst one, this node will be considered as already
      // processed, bailing out pretty quickly from the map index check
      a[aEnd] = b[bEnd];
    }
    // map based fallback, "slow" path
    else {
      // the map requires an O(bEnd - bStart) operation once
      // to store all future nodes indexes for later purposes.
      // In the worst case scenario, this is a full O(N) cost,
      // and such scenario happens at least when all nodes are different,
      // but also if both first and last items of the lists are different
      if (!map) {
        map = new Map;
        let i = bStart;
        while (i < bEnd)
          map.set(b[i], i++);
      }
      // if it's a future node, hence it needs some handling
      if (map.has(a[aStart])) {
        // grab the index of such node, 'cause it might have been processed
        const index = map.get(a[aStart]);
        // if it's not already processed, look on demand for the next LCS
        if (bStart < index && index < bEnd) {
          let i = aStart;
          // counts the amount of nodes that are the same in the future
          let sequence = 1;
          while (++i < aEnd && i < bEnd && map.get(a[i]) === (index + sequence))
            sequence++;
          // effort decision here: if the sequence is longer than replaces
          // needed to reach such sequence, which would brings again this loop
          // to the fast path, prepend the difference before a sequence,
          // and move only the future list index forward, so that aStart
          // and bStart will be aligned again, hence on the fast path.
          // An example considering aStart and bStart are both 0:
          // a: [1, 2, 3, 4]
          // b: [7, 1, 2, 3, 6]
          // this would place 7 before 1 and, from that time on, 1, 2, and 3
          // will be processed at zero cost
          if (sequence > (index - bStart)) {
            const node = get(a[aStart], 0);
            while (bStart < index)
              insertBefore(get(b[bStart++], 1), node);
          }
          // if the effort wasn't good enough, fallback to a replace,
          // moving both source and target indexes forward, hoping that some
          // similar node will be found later on, to go back to the fast path
          else {
            replaceChild(
              get(b[bStart++], 1),
              get(a[aStart++], -1)
            );
          }
        }
        // otherwise move the source forward, 'cause there's nothing to do
        else
          aStart++;
      }
      // this node has no meaning in the future list, so it's more than safe
      // to remove it, and check the next live node out instead, meaning
      // that only the live list index should be forwarded
      else
        removeChild(get(a[aStart++], -1));
    }
  }
  return b;
};

const UNMOUNT_SCOPE = Symbol('unmount');

const EachBinding = {
  // dynamic binding properties
  // childrenMap: null,
  // node: null,
  // root: null,
  // condition: null,
  // evaluate: null,
  // template: null,
  // isTemplateTag: false,
  nodes: [],
  // getKey: null,
  // indexName: null,
  // itemName: null,
  // afterPlaceholder: null,
  // placeholder: null,

  // API methods
  mount(scope, parentScope) {
    return this.update(scope, parentScope)
  },
  update(scope, parentScope) {
    const {placeholder, nodes, childrenMap} = this;
    const collection = scope === UNMOUNT_SCOPE ? null : this.evaluate(scope);
    const items = collection ? Array.from(collection) : [];

    // prepare the diffing
    const {
      newChildrenMap,
      batches,
      futureNodes
    } = createPatch(items, scope, parentScope, this);

    // patch the DOM only if there are new nodes
    udomdiff(
      nodes,
      futureNodes,
      patch(
        Array.from(childrenMap.values()),
        parentScope
      ),
      placeholder
    );

    // trigger the mounts and the updates
    batches.forEach(fn => fn());

    // update the children map
    this.childrenMap = newChildrenMap;
    this.nodes = futureNodes;

    return this
  },
  unmount(scope, parentScope) {
    this.update(UNMOUNT_SCOPE, parentScope);

    return this
  }
};

/**
 * Patch the DOM while diffing
 * @param   {any[]} redundant - list of all the children (template, nodes, context) added via each
 * @param   {*} parentScope - scope of the parent template
 * @returns {Function} patch function used by domdiff
 */
function patch(redundant, parentScope) {
  return (item, info) => {
    if (info < 0) {
      // get the last element added to the childrenMap saved previously
      const element = redundant[redundant.length - 1];

      if (element) {
        // get the nodes and the template in stored in the last child of the childrenMap
        const {template, nodes, context} = element;
        // remove the last node (notice <template> tags might have more children nodes)
        nodes.pop();

        // notice that we pass null as last argument because
        // the root node and its children will be removed by domdiff
        if (!nodes.length) {
          // we have cleared all the children nodes and we can unmount this template
          redundant.pop();
          template.unmount(context, parentScope, null);
        }
      }
    }

    return item
  }
}

/**
 * Check whether a template must be filtered from a loop
 * @param   {Function} condition - filter function
 * @param   {Object} context - argument passed to the filter function
 * @returns {boolean} true if this item should be skipped
 */
function mustFilterItem(condition, context) {
  return condition ? !condition(context) : false
}

/**
 * Extend the scope of the looped template
 * @param   {Object} scope - current template scope
 * @param   {Object} options - options
 * @param   {string} options.itemName - key to identify the looped item in the new context
 * @param   {string} options.indexName - key to identify the index of the looped item
 * @param   {number} options.index - current index
 * @param   {*} options.item - collection item looped
 * @returns {Object} enhanced scope object
 */
function extendScope(scope, {itemName, indexName, index, item}) {
  defineProperty(scope, itemName, item);
  if (indexName) defineProperty(scope, indexName, index);

  return scope
}

/**
 * Loop the current template items
 * @param   {Array} items - expression collection value
 * @param   {*} scope - template scope
 * @param   {*} parentScope - scope of the parent template
 * @param   {EachBinding} binding - each binding object instance
 * @returns {Object} data
 * @returns {Map} data.newChildrenMap - a Map containing the new children template structure
 * @returns {Array} data.batches - array containing the template lifecycle functions to trigger
 * @returns {Array} data.futureNodes - array containing the nodes we need to diff
 */
function createPatch(items, scope, parentScope, binding) {
  const {condition, template, childrenMap, itemName, getKey, indexName, root, isTemplateTag} = binding;
  const newChildrenMap = new Map();
  const batches = [];
  const futureNodes = [];

  items.forEach((item, index) => {
    const context = extendScope(Object.create(scope), {itemName, indexName, index, item});
    const key = getKey ? getKey(context) : index;
    const oldItem = childrenMap.get(key);
    const nodes = [];

    if (mustFilterItem(condition, context)) {
      return
    }

    const mustMount = !oldItem;
    const componentTemplate = oldItem ? oldItem.template : template.clone();
    const el = componentTemplate.el || root.cloneNode();
    const meta = isTemplateTag && mustMount ? createTemplateMeta(componentTemplate) : componentTemplate.meta;

    if (mustMount) {
      batches.push(() => componentTemplate.mount(el, context, parentScope, meta));
    } else {
      batches.push(() => componentTemplate.update(context, parentScope));
    }

    // create the collection of nodes to update or to add
    // in case of template tags we need to add all its children nodes
    if (isTemplateTag) {
      nodes.push(...meta.children);
    } else {
      nodes.push(el);
    }

    // delete the old item from the children map
    childrenMap.delete(key);
    futureNodes.push(...nodes);

    // update the children map
    newChildrenMap.set(key, {
      nodes,
      template: componentTemplate,
      context,
      index
    });
  });

  return {
    newChildrenMap,
    batches,
    futureNodes
  }
}

function create$6(node, {evaluate, condition, itemName, indexName, getKey, template}) {
  const placeholder = document.createTextNode('');
  const root = node.cloneNode();

  insertBefore(placeholder,  node);
  removeChild(node);

  return {
    ...EachBinding,
    childrenMap: new Map(),
    node,
    root,
    condition,
    evaluate,
    isTemplateTag: isTemplate(root),
    template: template.createDOM(node),
    getKey,
    indexName,
    itemName,
    placeholder
  }
}

/**
 * Binding responsible for the `if` directive
 */
const IfBinding = {
  // dynamic binding properties
  // node: null,
  // evaluate: null,
  // isTemplateTag: false,
  // placeholder: null,
  // template: null,

  // API methods
  mount(scope, parentScope) {
    return this.update(scope, parentScope)
  },
  update(scope, parentScope) {
    const value = !!this.evaluate(scope);
    const mustMount = !this.value && value;
    const mustUnmount = this.value && !value;
    const mount = () => {
      const pristine = this.node.cloneNode();

      insertBefore(pristine, this.placeholder);
      this.template = this.template.clone();
      this.template.mount(pristine, scope, parentScope);
    };

    switch (true) {
    case mustMount:
      mount();
      break
    case mustUnmount:
      this.unmount(scope);
      break
    default:
      if (value) this.template.update(scope, parentScope);
    }

    this.value = value;

    return this
  },
  unmount(scope, parentScope) {
    this.template.unmount(scope, parentScope, true);

    return this
  }
};

function create$5(node, { evaluate, template }) {
  const placeholder = document.createTextNode('');

  insertBefore(placeholder, node);
  removeChild(node);

  return {
    ...IfBinding,
    node,
    evaluate,
    placeholder,
    template: template.createDOM(node)
  }
}

const ElementProto = typeof Element === 'undefined' ? {} : Element.prototype;
const isNativeHtmlProperty = memoize(name => ElementProto.hasOwnProperty(name) ); // eslint-disable-line

/**
 * Add all the attributes provided
 * @param   {HTMLElement} node - target node
 * @param   {Object} attributes - object containing the attributes names and values
 * @returns {undefined} sorry it's a void function :(
 */
function setAllAttributes(node, attributes) {
  Object
    .entries(attributes)
    .forEach(([name, value]) => attributeExpression(node, { name }, value));
}

/**
 * Remove all the attributes provided
 * @param   {HTMLElement} node - target node
 * @param   {Object} newAttributes - object containing all the new attribute names
 * @param   {Object} oldAttributes - object containing all the old attribute names
 * @returns {undefined} sorry it's a void function :(
 */
function removeAllAttributes(node, newAttributes, oldAttributes) {
  const newKeys = newAttributes ? Object.keys(newAttributes) : [];

  Object
    .keys(oldAttributes)
    .filter(name => !newKeys.includes(name))
    .forEach(attribute => node.removeAttribute(attribute));
}

/**
 * Check whether the attribute value can be rendered
 * @param {*} value - expression value
 * @returns {boolean} true if we can render this attribute value
 */
function canRenderAttribute(value) {
  return value === true || ['string', 'number'].includes(typeof value)
}

/**
 * Check whether the attribute should be removed
 * @param {*} value - expression value
 * @returns {boolean} boolean - true if the attribute can be removed}
 */
function shouldRemoveAttribute(value) {
  return !value && value !== 0
}

/**
 * This methods handles the DOM attributes updates
 * @param   {HTMLElement} node - target node
 * @param   {Object} expression - expression object
 * @param   {string} expression.name - attribute name
 * @param   {*} value - new expression value
 * @param   {*} oldValue - the old expression cached value
 * @returns {undefined}
 */
function attributeExpression(node, { name }, value, oldValue) {
  // is it a spread operator? {...attributes}
  if (!name) {
    if (oldValue) {
      // remove all the old attributes
      removeAllAttributes(node, value, oldValue);
    }

    // is the value still truthy?
    if (value) {
      setAllAttributes(node, value);
    }

    return
  }

  // handle boolean attributes
  if (
    !isNativeHtmlProperty(name) && (
      isBoolean(value) ||
      isObject(value) ||
      isFunction(value)
    )
  ) {
    node[name] = value;
  }

  if (shouldRemoveAttribute(value)) {
    node.removeAttribute(name);
  } else if (canRenderAttribute(value)) {
    node.setAttribute(name, normalizeValue(name, value));
  }
}

/**
 * Get the value as string
 * @param   {string} name - attribute name
 * @param   {*} value - user input value
 * @returns {string} input value as string
 */
function normalizeValue(name, value) {
  // be sure that expressions like selected={ true } will be always rendered as selected='selected'
  return (value === true) ? name : value
}

const RE_EVENTS_PREFIX = /^on/;

const getCallbackAndOptions = value => Array.isArray(value) ? value : [value, false];

// see also https://medium.com/@WebReflection/dom-handleevent-a-cross-platform-standard-since-year-2000-5bf17287fd38
const EventListener = {
  handleEvent(event) {
    this[event.type](event);
  }
};
const ListenersWeakMap = new WeakMap();

const createListener = node => {
  const listener = Object.create(EventListener);
  ListenersWeakMap.set(node, listener);
  return listener
};

/**
 * Set a new event listener
 * @param   {HTMLElement} node - target node
 * @param   {Object} expression - expression object
 * @param   {string} expression.name - event name
 * @param   {*} value - new expression value
 * @returns {value} the callback just received
 */
function eventExpression(node, { name }, value) {
  const normalizedEventName = name.replace(RE_EVENTS_PREFIX, '');
  const eventListener = ListenersWeakMap.get(node) || createListener(node);
  const [callback, options] = getCallbackAndOptions(value);
  const handler = eventListener[normalizedEventName];
  const mustRemoveEvent = handler && !callback;
  const mustAddEvent = callback && !handler;

  if (mustRemoveEvent) {
    node.removeEventListener(normalizedEventName, eventListener);
  }

  if (mustAddEvent) {
    node.addEventListener(normalizedEventName, eventListener, options);
  }

  eventListener[normalizedEventName] = callback;
}

/**
 * Normalize the user value in order to render a empty string in case of falsy values
 * @param   {*} value - user input value
 * @returns {string} hopefully a string
 */
function normalizeStringValue(value) {
  return isNil(value) ? '' : value
}

/**
 * Get the the target text node to update or create one from of a comment node
 * @param   {HTMLElement} node - any html element containing childNodes
 * @param   {number} childNodeIndex - index of the text node in the childNodes list
 * @returns {Text} the text node to update
 */
const getTextNode = (node, childNodeIndex) => {
  const target = node.childNodes[childNodeIndex];

  if (target.nodeType === Node.COMMENT_NODE) {
    const textNode = document.createTextNode('');
    node.replaceChild(textNode, target);

    return textNode
  }

  return target
};

/**
 * This methods handles a simple text expression update
 * @param   {HTMLElement} node - target node
 * @param   {Object} data - expression object
 * @param   {*} value - new expression value
 * @returns {undefined}
 */
function textExpression(node, data, value) {
  node.data = normalizeStringValue(value);
}

/**
 * This methods handles the input fileds value updates
 * @param   {HTMLElement} node - target node
 * @param   {Object} expression - expression object
 * @param   {*} value - new expression value
 * @returns {undefined}
 */
function valueExpression(node, expression, value) {
  node.value = normalizeStringValue(value);
}

const expressions = {
  [ATTRIBUTE]: attributeExpression,
  [EVENT]: eventExpression,
  [TEXT]: textExpression,
  [VALUE]: valueExpression
};

const Expression = {
  // Static props
  // node: null,
  // value: null,

  // API methods
  /**
   * Mount the expression evaluating its initial value
   * @param   {*} scope - argument passed to the expression to evaluate its current values
   * @returns {Expression} self
   */
  mount(scope) {
    // hopefully a pure function
    this.value = this.evaluate(scope);

    // IO() DOM updates
    apply(this, this.value);

    return this
  },
  /**
   * Update the expression if its value changed
   * @param   {*} scope - argument passed to the expression to evaluate its current values
   * @returns {Expression} self
   */
  update(scope) {
    // pure function
    const value = this.evaluate(scope);

    if (this.value !== value) {
      // IO() DOM updates
      apply(this, value);
      this.value = value;
    }

    return this
  },
  /**
   * Expression teardown method
   * @returns {Expression} self
   */
  unmount() {
    // unmount only the event handling expressions
    if (this.type === EVENT) apply(this, null);

    return this
  }
};

/**
 * IO() function to handle the DOM updates
 * @param {Expression} expression - expression object
 * @param {*} value - current expression value
 * @returns {undefined}
 */
function apply(expression, value) {
  return expressions[expression.type](expression.node, expression, value, expression.value)
}

function create$4(node, data) {
  return {
    ...Expression,
    ...data,
    node: data.type === TEXT ?
      getTextNode(node, data.childNodeIndex) :
      node
  }
}

/**
 * Create a flat object having as keys a list of methods that if dispatched will propagate
 * on the whole collection
 * @param   {Array} collection - collection to iterate
 * @param   {Array<string>} methods - methods to execute on each item of the collection
 * @param   {*} context - context returned by the new methods created
 * @returns {Object} a new object to simplify the the nested methods dispatching
 */
function flattenCollectionMethods(collection, methods, context) {
  return methods.reduce((acc, method) => {
    return {
      ...acc,
      [method]: (scope) => {
        return collection.map(item => item[method](scope)) && context
      }
    }
  }, {})
}

function create$3(node, { expressions }) {
  return {
    ...flattenCollectionMethods(
      expressions.map(expression => create$4(node, expression)),
      ['mount', 'update', 'unmount']
    )
  }
}

function extendParentScope(attributes, scope, parentScope) {
  if (!attributes || !attributes.length) return parentScope

  const expressions = attributes.map(attr => ({
    ...attr,
    value: attr.evaluate(scope)
  }));

  return Object.assign(
    Object.create(parentScope || null),
    evaluateAttributeExpressions(expressions)
  )
}

// this function is only meant to fix an edge case
// https://github.com/riot/riot/issues/2842
const getRealParent = (scope, parentScope) => scope[PARENT_KEY_SYMBOL] || parentScope;

const SlotBinding = {
  // dynamic binding properties
  // node: null,
  // name: null,
  attributes: [],
  // template: null,

  getTemplateScope(scope, parentScope) {
    return extendParentScope(this.attributes, scope, parentScope)
  },

  // API methods
  mount(scope, parentScope) {
    const templateData = scope.slots ? scope.slots.find(({id}) => id === this.name) : false;
    const {parentNode} = this.node;
    const realParent = getRealParent(scope, parentScope);

    this.template = templateData && create(
      templateData.html,
      templateData.bindings
    ).createDOM(parentNode);

    if (this.template) {
      cleanNode(this.node);
      this.template.mount(this.node, this.getTemplateScope(scope, realParent), realParent);
      this.template.children = Array.from(this.node.childNodes);
    }

    moveSlotInnerContent(this.node);
    removeChild(this.node);

    return this
  },
  update(scope, parentScope) {
    if (this.template) {
      const realParent = getRealParent(scope, parentScope);
      this.template.update(this.getTemplateScope(scope, realParent), realParent);
    }

    return this
  },
  unmount(scope, parentScope, mustRemoveRoot) {
    if (this.template) {
      this.template.unmount(this.getTemplateScope(scope, parentScope), null, mustRemoveRoot);
    }

    return this
  }
};

/**
 * Move the inner content of the slots outside of them
 * @param   {HTMLElement} slot - slot node
 * @returns {undefined} it's a void method ¯\_(ツ)_/¯
 */
function moveSlotInnerContent(slot) {
  const child = slot && slot.firstChild;

  if (!child) return

  insertBefore(child, slot);
  moveSlotInnerContent(slot);
}

/**
 * Create a single slot binding
 * @param   {HTMLElement} node - slot node
 * @param   {string} name - slot id
 * @param   {AttributeExpressionData[]} attributes - slot attributes
 * @returns {Object} Slot binding object
 */
function createSlot(node, { name, attributes }) {
  return {
    ...SlotBinding,
    attributes,
    node,
    name
  }
}

/**
 * Create a new tag object if it was registered before, otherwise fallback to the simple
 * template chunk
 * @param   {Function} component - component factory function
 * @param   {Array<Object>} slots - array containing the slots markup
 * @param   {Array} attributes - dynamic attributes that will be received by the tag element
 * @returns {TagImplementation|TemplateChunk} a tag implementation or a template chunk as fallback
 */
function getTag(component, slots = [], attributes = []) {
  // if this tag was registered before we will return its implementation
  if (component) {
    return component({slots, attributes})
  }

  // otherwise we return a template chunk
  return create(slotsToMarkup(slots), [
    ...slotBindings(slots), {
      // the attributes should be registered as binding
      // if we fallback to a normal template chunk
      expressions: attributes.map(attr => {
        return {
          type: ATTRIBUTE,
          ...attr
        }
      })
    }
  ])
}


/**
 * Merge all the slots bindings into a single array
 * @param   {Array<Object>} slots - slots collection
 * @returns {Array<Bindings>} flatten bindings array
 */
function slotBindings(slots) {
  return slots.reduce((acc, {bindings}) => acc.concat(bindings), [])
}

/**
 * Merge all the slots together in a single markup string
 * @param   {Array<Object>} slots - slots collection
 * @returns {string} markup of all the slots in a single string
 */
function slotsToMarkup(slots) {
  return slots.reduce((acc, slot) => {
    return acc + slot.html
  }, '')
}


const TagBinding = {
  // dynamic binding properties
  // node: null,
  // evaluate: null,
  // name: null,
  // slots: null,
  // tag: null,
  // attributes: null,
  // getComponent: null,

  mount(scope) {
    return this.update(scope)
  },
  update(scope, parentScope) {
    const name = this.evaluate(scope);

    // simple update
    if (name && name === this.name) {
      this.tag.update(scope);
    } else {
      // unmount the old tag if it exists
      this.unmount(scope, parentScope, true);

      // mount the new tag
      this.name = name;
      this.tag = getTag(this.getComponent(name), this.slots, this.attributes);
      this.tag.mount(this.node, scope);
    }

    return this
  },
  unmount(scope, parentScope, keepRootTag) {
    if (this.tag) {
      // keep the root tag
      this.tag.unmount(keepRootTag);
    }

    return this
  }
};

function create$2(node, {evaluate, getComponent, slots, attributes}) {
  return {
    ...TagBinding,
    node,
    evaluate,
    slots,
    attributes,
    getComponent
  }
}

const bindings = {
  [IF]: create$5,
  [SIMPLE]: create$3,
  [EACH]: create$6,
  [TAG]: create$2,
  [SLOT]: createSlot
};

/**
 * Text expressions in a template tag will get childNodeIndex value normalized
 * depending on the position of the <template> tag offset
 * @param   {Expression[]} expressions - riot expressions array
 * @param   {number} textExpressionsOffset - offset of the <template> tag
 * @returns {Expression[]} expressions containing the text expressions normalized
 */
function fixTextExpressionsOffset(expressions, textExpressionsOffset) {
  return expressions.map(e => e.type === TEXT ? {
    ...e,
    childNodeIndex: e.childNodeIndex + textExpressionsOffset
  } : e)
}

/**
 * Bind a new expression object to a DOM node
 * @param   {HTMLElement} root - DOM node where to bind the expression
 * @param   {TagBindingData} binding - binding data
 * @param   {number|null} templateTagOffset - if it's defined we need to fix the text expressions childNodeIndex offset
 * @returns {Binding} Binding object
 */
function create$1(root, binding, templateTagOffset) {
  const { selector, type, redundantAttribute, expressions } = binding;
  // find the node to apply the bindings
  const node = selector ? root.querySelector(selector) : root;

  // remove eventually additional attributes created only to select this node
  if (redundantAttribute) node.removeAttribute(redundantAttribute);
  const bindingExpressions = expressions || [];

  // init the binding
  return (bindings[type] || bindings[SIMPLE])(
    node,
    {
      ...binding,
      expressions: templateTagOffset && !selector ?
        fixTextExpressionsOffset(bindingExpressions, templateTagOffset) :
        bindingExpressions
    }
  )
}

// in this case a simple innerHTML is enough
function createHTMLTree(html, root) {
  const template = isTemplate(root) ? root : document.createElement('template');
  template.innerHTML = html;
  return template.content
}

// for svg nodes we need a bit more work
function createSVGTree(html, container) {
  // create the SVGNode
  const svgNode = container.ownerDocument.importNode(
    new window.DOMParser()
      .parseFromString(
        `<svg xmlns="http://www.w3.org/2000/svg">${html}</svg>`,
        'application/xml'
      )
      .documentElement,
    true
  );

  return svgNode
}

/**
 * Create the DOM that will be injected
 * @param {Object} root - DOM node to find out the context where the fragment will be created
 * @param   {string} html - DOM to create as string
 * @returns {HTMLDocumentFragment|HTMLElement} a new html fragment
 */
function createDOMTree(root, html) {
  if (isSvg(root)) return createSVGTree(html, root)

  return createHTMLTree(html, root)
}

/**
 * Inject the DOM tree into a target node
 * @param   {HTMLElement} el - target element
 * @param   {DocumentFragment|SVGElement} dom - dom tree to inject
 * @returns {undefined}
 */
function injectDOM(el, dom) {
  switch (true) {
  case isSvg(el):
    moveChildren(dom, el);
    break
  case isTemplate(el):
    el.parentNode.replaceChild(dom, el);
    break
  default:
    el.appendChild(dom);
  }
}

/**
 * Create the Template DOM skeleton
 * @param   {HTMLElement} el - root node where the DOM will be injected
 * @param   {string|HTMLElement} html - HTML markup or HTMLElement that will be injected into the root node
 * @returns {?DocumentFragment} fragment that will be injected into the root node
 */
function createTemplateDOM(el, html) {
  return html && (typeof html === 'string' ?
    createDOMTree(el, html) :
    html)
}

/**
 * Get the offset of the <template> tag
 * @param {HTMLElement} parentNode - template tag parent node
 * @param {HTMLElement} el - the template tag we want to render
 * @param   {Object} meta - meta properties needed to handle the <template> tags in loops
 * @returns {number} offset of the <template> tag calculated from its siblings DOM nodes
 */
function getTemplateTagOffset(parentNode, el, meta) {
  const siblings = Array.from(parentNode.childNodes);

  return Math.max(
    siblings.indexOf(el),
    siblings.indexOf(meta.head) + 1,
    0
  )
}

/**
 * Template Chunk model
 * @type {Object}
 */
const TemplateChunk = {
  // Static props
  // bindings: null,
  // bindingsData: null,
  // html: null,
  // isTemplateTag: false,
  // fragment: null,
  // children: null,
  // dom: null,
  // el: null,

  /**
   * Create the template DOM structure that will be cloned on each mount
   * @param   {HTMLElement} el - the root node
   * @returns {TemplateChunk} self
   */
  createDOM(el) {
    // make sure that the DOM gets created before cloning the template
    this.dom = this.dom || createTemplateDOM(el, this.html) || document.createDocumentFragment();

    return this
  },

  // API methods
  /**
   * Attach the template to a DOM node
   * @param   {HTMLElement} el - target DOM node
   * @param   {*} scope - template data
   * @param   {*} parentScope - scope of the parent template tag
   * @param   {Object} meta - meta properties needed to handle the <template> tags in loops
   * @returns {TemplateChunk} self
   */
  mount(el, scope, parentScope, meta = {}) {
    if (!el) panic('Please provide DOM node to mount properly your template');

    if (this.el) this.unmount(scope);

    // <template> tags require a bit more work
    // the template fragment might be already created via meta outside of this call
    const {fragment, children, avoidDOMInjection} = meta;
    // <template> bindings of course can not have a root element
    // so we check the parent node to set the query selector bindings
    const {parentNode} = children ? children[0] : el;
    const isTemplateTag = isTemplate(el);
    const templateTagOffset = isTemplateTag ? getTemplateTagOffset(parentNode, el, meta) : null;

    // create the DOM if it wasn't created before
    this.createDOM(el);

    // create the DOM of this template cloning the original DOM structure stored in this instance
    // notice that if a documentFragment was passed (via meta) we will use it instead
    const cloneNode = fragment || this.dom.cloneNode(true);

    // store root node
    // notice that for template tags the root note will be the parent tag
    this.el = isTemplateTag ? parentNode : el;

    // create the children array only for the <template> fragments
    this.children = isTemplateTag ? children || Array.from(cloneNode.childNodes) : null;

    // inject the DOM into the el only if a fragment is available
    if (!avoidDOMInjection && cloneNode) injectDOM(el, cloneNode);

    // create the bindings
    this.bindings = this.bindingsData.map(binding => create$1(
      this.el,
      binding,
      templateTagOffset
    ));
    this.bindings.forEach(b => b.mount(scope, parentScope));

    // store the template meta properties
    this.meta = meta;

    return this
  },

  /**
   * Update the template with fresh data
   * @param   {*} scope - template data
   * @param   {*} parentScope - scope of the parent template tag
   * @returns {TemplateChunk} self
   */
  update(scope, parentScope) {
    this.bindings.forEach(b => b.update(scope, parentScope));

    return this
  },

  /**
   * Remove the template from the node where it was initially mounted
   * @param   {*} scope - template data
   * @param   {*} parentScope - scope of the parent template tag
   * @param   {boolean|null} mustRemoveRoot - if true remove the root element,
   * if false or undefined clean the root tag content, if null don't touch the DOM
   * @returns {TemplateChunk} self
   */
  unmount(scope, parentScope, mustRemoveRoot = false) {
    const el = this.el;

    if (!el) {
      return this
    }

    this.bindings.forEach(b => b.unmount(scope, parentScope, mustRemoveRoot));

    switch (true) {
    // pure components should handle the DOM unmount updates by themselves
    // for mustRemoveRoot === null don't touch the DOM
    case (el[IS_PURE_SYMBOL] || mustRemoveRoot === null):
      break

    // if children are declared, clear them
    // applicable for <template> and <slot/> bindings
    case Array.isArray(this.children):
      clearChildren(this.children);
      break

    // clean the node children only
    case !mustRemoveRoot:
      cleanNode(el);
      break

    // remove the root node only if the mustRemoveRoot is truly
    case !!mustRemoveRoot:
      removeChild(el);
      break
    }

    this.el = null;

    return this
  },

  /**
   * Clone the template chunk
   * @returns {TemplateChunk} a clone of this object resetting the this.el property
   */
  clone() {
    return {
      ...this,
      meta: {},
      el: null
    }
  }
};


/**
 * Create a template chunk wiring also the bindings
 * @param   {string|HTMLElement} html - template string
 * @param   {BindingData[]} bindings - bindings collection
 * @returns {TemplateChunk} a new TemplateChunk copy
 */
function create(html, bindings = []) {
  return {
    ...TemplateChunk,
    html,
    bindingsData: bindings
  }
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/create-children-components-object.js
/* Riot WIP, @license MIT */



/**
 * Create the subcomponents that can be included inside a tag in runtime
 * @param   {Object} components - components imported in runtime
 * @returns {Object} all the components transformed into Riot.Component factory functions
 */

function createChildrenComponentsObject(components) {
  if (components === void 0) {
    components = {};
  }

  return Object.entries(callOrAssign(components)).reduce((acc, _ref) => {
    let [key, value] = _ref;
    acc[camelToDashCase(key)] = createComponentFromWrapper(value);
    return acc;
  }, {});
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/component-template-factory.js
/* Riot WIP, @license MIT */





/**
 * Factory function to create the component templates only once
 * @param   {Function} template - component template creation function
 * @param   {RiotComponentWrapper} componentWrapper - riot compiler generated object
 * @returns {TemplateChunk} template chunk object
 */

function componentTemplateFactory(template$1, componentWrapper) {
  const components = createChildrenComponentsObject(componentWrapper.exports ? componentWrapper.exports.components : {});
  return template$1(create, expression_types, binding_types, name => {
    // improve support for recursive components
    if (name === componentWrapper.name) return memoizedCreateComponentFromWrapper(componentWrapper); // return the registered components

    return components[name] || COMPONENTS_IMPLEMENTATION_MAP.get(name);
  });
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/bind-dom-node-to-component-instance.js
/* Riot WIP, @license MIT */


/**
 * Bind a DOM node to its component object
 * @param   {HTMLElement} node - html node mounted
 * @param   {Object} component - Riot.js component object
 * @returns {Object} the component object received as second argument
 */

const bindDOMNodeToComponentInstance = (node, component) => node[DOM_COMPONENT_INSTANCE_PROPERTY] = component;



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/create-core-api-methods.js
/* Riot WIP, @license MIT */


/**
 * Wrap the Riot.js core API methods using a mapping function
 * @param   {Function} mapFunction - lifting function
 * @returns {Object} an object having the { mount, update, unmount } functions
 */

function createCoreAPIMethods(mapFunction) {
  return [MOUNT_METHOD_KEY, UPDATE_METHOD_KEY, UNMOUNT_METHOD_KEY].reduce((acc, method) => {
    acc[method] = mapFunction(method);
    return acc;
  }, {});
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/create-pure-component.js
/* Riot WIP, @license MIT */





/**
 * Create a pure component
 * @param   {Function} pureFactoryFunction - pure component factory function
 * @param   {Array} options.slots - component slots
 * @param   {Array} options.attributes - component attributes
 * @param   {Array} options.template - template factory function
 * @param   {Array} options.template - template factory function
 * @param   {any} options.props - initial component properties
 * @returns {Object} pure component object
 */

function createPureComponent(pureFactoryFunction, _ref) {
  let {
    slots,
    attributes,
    props,
    css,
    template
  } = _ref;
  if (template) panic('Pure components can not have html');
  if (css) panic('Pure components do not have css');
  const component = defineDefaults(pureFactoryFunction({
    slots,
    attributes,
    props
  }), PURE_COMPONENT_API);
  return createCoreAPIMethods(method => function () {
    for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
      args[_key] = arguments[_key];
    }

    // intercept the mount calls to bind the DOM node to the pure object created
    // see also https://github.com/riot/riot/issues/2806
    if (method === MOUNT_METHOD_KEY) {
      const [element] = args; // mark this node as pure element

      defineProperty(element, IS_PURE_SYMBOL, true);
      bindDOMNodeToComponentInstance(element, component);
    }

    component[method](...args);
    return component;
  });
}



;// CONCATENATED MODULE: ./node_modules/bianco.dom-to-array/index.next.js
/**
 * Converts any DOM node/s to a loopable array
 * @param   { HTMLElement|NodeList } els - single html element or a node list
 * @returns { Array } always a loopable object
 */
function domToArray(els) {
  // can this object be already looped?
  if (!Array.isArray(els)) {
    // is it a node list?
    if (
      /^\[object (HTMLCollection|NodeList|Object)\]$/
        .test(Object.prototype.toString.call(els))
        && typeof els.length === 'number'
    )
      return Array.from(els)
    else
      // if it's a single node
      // it will be returned as "array" with one single entry
      return [els]
  }
  // this object could be looped out of the box
  return els
}
;// CONCATENATED MODULE: ./node_modules/bianco.query/index.next.js


/**
 * Simple helper to find DOM nodes returning them as array like loopable object
 * @param   { string|DOMNodeList } selector - either the query or the DOM nodes to arraify
 * @param   { HTMLElement }        scope      - context defining where the query will search for the DOM nodes
 * @returns { Array } DOM nodes found as array
 */
function $(selector, scope) {
  return domToArray(typeof selector === 'string' ?
    (scope || document).querySelectorAll(selector) :
    selector
  )
}

;// CONCATENATED MODULE: ./node_modules/riot/esm/core/component-dom-selectors.js
/* Riot WIP, @license MIT */


const COMPONENT_DOM_SELECTORS = Object.freeze({
  // component helpers
  $(selector) {
    return $(selector, this.root)[0];
  },

  $$(selector) {
    return $(selector, this.root);
  }

});



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/component-lifecycle-methods.js
/* Riot WIP, @license MIT */


const COMPONENT_LIFECYCLE_METHODS = Object.freeze({
  [SHOULD_UPDATE_KEY]: noop,
  [ON_BEFORE_MOUNT_KEY]: noop,
  [ON_MOUNTED_KEY]: noop,
  [ON_BEFORE_UPDATE_KEY]: noop,
  [ON_UPDATED_KEY]: noop,
  [ON_BEFORE_UNMOUNT_KEY]: noop,
  [ON_UNMOUNTED_KEY]: noop
});



;// CONCATENATED MODULE: ./node_modules/bianco.attr/index.next.js


/**
 * Normalize the return values, in case of a single value we avoid to return an array
 * @param   { Array } values - list of values we want to return
 * @returns { Array|string|boolean } either the whole list of values or the single one found
 * @private
 */
const normalize = values => values.length === 1 ? values[0] : values

/**
 * Parse all the nodes received to get/remove/check their attributes
 * @param   { HTMLElement|NodeList|Array } els    - DOM node/s to parse
 * @param   { string|Array }               name   - name or list of attributes
 * @param   { string }                     method - method that will be used to parse the attributes
 * @returns { Array|string } result of the parsing in a list or a single value
 * @private
 */
function parseNodes(els, name, method) {
  const names = typeof name === 'string' ? [name] : name
  return normalize(domToArray(els).map(el => {
    return normalize(names.map(n => el[method](n)))
  }))
}

/**
 * Set any attribute on a single or a list of DOM nodes
 * @param   { HTMLElement|NodeList|Array } els   - DOM node/s to parse
 * @param   { string|Object }              name  - either the name of the attribute to set
 *                                                 or a list of properties as object key - value
 * @param   { string }                     value - the new value of the attribute (optional)
 * @returns { HTMLElement|NodeList|Array } the original array of elements passed to this function
 *
 * @example
 *
 * import { set } from 'bianco.attr'
 *
 * const img = document.createElement('img')
 *
 * set(img, 'width', 100)
 *
 * // or also
 * set(img, {
 *   width: 300,
 *   height: 300
 * })
 *
 */
function set(els, name, value) {
  const attrs = typeof name === 'object' ? name : { [name]: value }
  const props = Object.keys(attrs)

  domToArray(els).forEach(el => {
    props.forEach(prop => el.setAttribute(prop, attrs[prop]))
  })
  return els
}

/**
 * Get any attribute from a single or a list of DOM nodes
 * @param   { HTMLElement|NodeList|Array } els   - DOM node/s to parse
 * @param   { string|Array }               name  - name or list of attributes to get
 * @returns { Array|string } list of the attributes found
 *
 * @example
 *
 * import { get } from 'bianco.attr'
 *
 * const img = document.createElement('img')
 *
 * get(img, 'width') // => '200'
 *
 * // or also
 * get(img, ['width', 'height']) // => ['200', '300']
 *
 * // or also
 * get([img1, img2], ['width', 'height']) // => [['200', '300'], ['500', '200']]
 */
function get(els, name) {
  return parseNodes(els, name, 'getAttribute')
}

/**
 * Remove any attribute from a single or a list of DOM nodes
 * @param   { HTMLElement|NodeList|Array } els   - DOM node/s to parse
 * @param   { string|Array }               name  - name or list of attributes to remove
 * @returns { HTMLElement|NodeList|Array } the original array of elements passed to this function
 *
 * @example
 *
 * import { remove } from 'bianco.attr'
 *
 * remove(img, 'width') // remove the width attribute
 *
 * // or also
 * remove(img, ['width', 'height']) // remove the width and the height attribute
 *
 * // or also
 * remove([img1, img2], ['width', 'height']) // remove the width and the height attribute from both images
 */
function remove(els, name) {
  return parseNodes(els, name, 'removeAttribute')
}

/**
 * Set any attribute on a single or a list of DOM nodes
 * @param   { HTMLElement|NodeList|Array } els   - DOM node/s to parse
 * @param   { string|Array }               name  - name or list of attributes to detect
 * @returns { boolean|Array } true or false or an array of boolean values
 * @example
 *
 * import { has } from 'bianco.attr'
 *
 * has(img, 'width') // false
 *
 * // or also
 * has(img, ['width', 'height']) // => [false, false]
 *
 * // or also
 * has([img1, img2], ['width', 'height']) // => [[false, false], [false, false]]
 */
function has(els, name) {
  return parseNodes(els, name, 'hasAttribute')
}

/* harmony default export */ const index_next = ({
  get,
  set,
  remove,
  has
});
;// CONCATENATED MODULE: ./node_modules/riot/esm/core/css-manager.js
/* Riot WIP, @license MIT */



const CSS_BY_NAME = new Map();
const STYLE_NODE_SELECTOR = 'style[riot]'; // memoized curried function

const getStyleNode = (style => {
  return () => {
    // lazy evaluation:
    // if this function was already called before
    // we return its cached result
    if (style) return style; // create a new style element or use an existing one
    // and cache it internally

    style = $(STYLE_NODE_SELECTOR)[0] || document.createElement('style');
    set(style, 'type', 'text/css');
    /* istanbul ignore next */

    if (!style.parentNode) document.head.appendChild(style);
    return style;
  };
})();
/**
 * Object that will be used to inject and manage the css of every tag instance
 */


const cssManager = {
  CSS_BY_NAME,

  /**
   * Save a tag style to be later injected into DOM
   * @param { string } name - if it's passed we will map the css to a tagname
   * @param { string } css - css string
   * @returns {Object} self
   */
  add(name, css) {
    if (!CSS_BY_NAME.has(name)) {
      CSS_BY_NAME.set(name, css);
      this.inject();
    }

    return this;
  },

  /**
   * Inject all previously saved tag styles into DOM
   * innerHTML seems slow: http://jsperf.com/riot-insert-style
   * @returns {Object} self
   */
  inject() {
    getStyleNode().innerHTML = [...CSS_BY_NAME.values()].join('\n');
    return this;
  },

  /**
   * Remove a tag style from the DOM
   * @param {string} name a registered tagname
   * @returns {Object} self
   */
  remove(name) {
    if (CSS_BY_NAME.has(name)) {
      CSS_BY_NAME.delete(name);
      this.inject();
    }

    return this;
  }

};



;// CONCATENATED MODULE: ./node_modules/curri/index.next.js
/**
 * Function to curry any javascript method
 * @param   {Function}  fn - the target function we want to curry
 * @param   {...[args]} acc - initial arguments
 * @returns {Function|*} it will return a function until the target function
 *                       will receive all of its arguments
 */
function curry(fn, ...acc) {
  return (...args) => {
    args = [...acc, ...args]

    return args.length < fn.length ?
      curry(fn, ...args) :
      fn(...args)
  }
}
;// CONCATENATED MODULE: ./node_modules/riot/esm/utils/dom.js
/* Riot WIP, @license MIT */



/**
 * Get the tag name of any DOM node
 * @param   {HTMLElement} element - DOM node we want to inspect
 * @returns {string} name to identify this dom node in riot
 */

function getName(element) {
  return get(element, IS_DIRECTIVE) || element.tagName.toLowerCase();
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/add-css-hook.js
/* Riot WIP, @license MIT */




/**
 * Add eventually the "is" attribute to link this DOM node to its css
 * @param {HTMLElement} element - target root node
 * @param {string} name - name of the component mounted
 * @returns {undefined} it's a void function
 */

function addCssHook(element, name) {
  if (getName(element) !== name) {
    set(element, IS_DIRECTIVE, name);
  }
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/compute-component-state.js
/* Riot WIP, @license MIT */


/**
 * Compute the component current state merging it with its previous state
 * @param   {Object} oldState - previous state object
 * @param   {Object} newState - new state given to the `update` call
 * @returns {Object} new object state
 */

function computeComponentState(oldState, newState) {
  return Object.assign({}, oldState, callOrAssign(newState));
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/compute-initial-props.js
/* Riot WIP, @license MIT */


/**
 * Evaluate the component properties either from its real attributes or from its initial user properties
 * @param   {HTMLElement} element - component root
 * @param   {Object}  initialProps - initial props
 * @returns {Object} component props key value pairs
 */

function computeInitialProps(element, initialProps) {
  if (initialProps === void 0) {
    initialProps = {};
  }

  return Object.assign({}, DOMattributesToObject(element), callOrAssign(initialProps));
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/create-attribute-bindings.js
/* Riot WIP, @license MIT */



/**
 * Create the bindings to update the component attributes
 * @param   {HTMLElement} node - node where we will bind the expressions
 * @param   {Array} attributes - list of attribute bindings
 * @returns {TemplateChunk} - template bindings object
 */

function createAttributeBindings(node, attributes) {
  if (attributes === void 0) {
    attributes = [];
  }

  const expressions = attributes.map(a => create$4(node, a));
  const binding = {};
  return Object.assign(binding, Object.assign({
    expressions
  }, createCoreAPIMethods(method => scope => {
    expressions.forEach(e => e[method](scope));
    return binding;
  })));
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/run-plugins.js
/* Riot WIP, @license MIT */


/**
 * Run the component instance through all the plugins set by the user
 * @param   {Object} component - component instance
 * @returns {Object} the component enhanced by the plugins
 */

function runPlugins(component) {
  return [...PLUGINS_SET].reduce((c, fn) => fn(c) || c, component);
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/manage-component-lifecycle.js
/* Riot WIP, @license MIT */








/**
 * Component creation factory function that will enhance the user provided API
 * @param   {Object} component - a component implementation previously defined
 * @param   {Array} options.slots - component slots generated via riot compiler
 * @param   {Array} options.attributes - attribute expressions generated via riot compiler
 * @returns {Riot.Component} a riot component instance
 */

function manageComponentLifecycle(component, _ref) {
  let {
    slots,
    attributes,
    props
  } = _ref;
  return autobindMethods(runPlugins(defineProperties(isObject(component) ? Object.create(component) : component, {
    mount(element, state, parentScope) {
      if (state === void 0) {
        state = {};
      }

      // any element mounted passing through this function can't be a pure component
      defineProperty(element, IS_PURE_SYMBOL, false);
      this[PARENT_KEY_SYMBOL] = parentScope;
      this[ATTRIBUTES_KEY_SYMBOL] = createAttributeBindings(element, attributes).mount(parentScope);
      defineProperty(this, PROPS_KEY, Object.freeze(Object.assign({}, computeInitialProps(element, props), evaluateAttributeExpressions(this[ATTRIBUTES_KEY_SYMBOL].expressions))));
      this[STATE_KEY] = computeComponentState(this[STATE_KEY], state);
      this[TEMPLATE_KEY_SYMBOL] = this.template.createDOM(element).clone(); // link this object to the DOM node

      bindDOMNodeToComponentInstance(element, this); // add eventually the 'is' attribute

      component.name && addCssHook(element, component.name); // define the root element

      defineProperty(this, ROOT_KEY, element); // define the slots array

      defineProperty(this, SLOTS_KEY, slots); // before mount lifecycle event

      this[ON_BEFORE_MOUNT_KEY](this[PROPS_KEY], this[STATE_KEY]); // mount the template

      this[TEMPLATE_KEY_SYMBOL].mount(element, this, parentScope);
      this[ON_MOUNTED_KEY](this[PROPS_KEY], this[STATE_KEY]);
      return this;
    },

    update(state, parentScope) {
      if (state === void 0) {
        state = {};
      }

      if (parentScope) {
        this[PARENT_KEY_SYMBOL] = parentScope;
        this[ATTRIBUTES_KEY_SYMBOL].update(parentScope);
      }

      const newProps = evaluateAttributeExpressions(this[ATTRIBUTES_KEY_SYMBOL].expressions);
      if (this[SHOULD_UPDATE_KEY](newProps, this[PROPS_KEY]) === false) return;
      defineProperty(this, PROPS_KEY, Object.freeze(Object.assign({}, this[PROPS_KEY], newProps)));
      this[STATE_KEY] = computeComponentState(this[STATE_KEY], state);
      this[ON_BEFORE_UPDATE_KEY](this[PROPS_KEY], this[STATE_KEY]); // avoiding recursive updates
      // see also https://github.com/riot/riot/issues/2895

      if (!this[IS_COMPONENT_UPDATING]) {
        this[IS_COMPONENT_UPDATING] = true;
        this[TEMPLATE_KEY_SYMBOL].update(this, this[PARENT_KEY_SYMBOL]);
      }

      this[ON_UPDATED_KEY](this[PROPS_KEY], this[STATE_KEY]);
      this[IS_COMPONENT_UPDATING] = false;
      return this;
    },

    unmount(preserveRoot) {
      this[ON_BEFORE_UNMOUNT_KEY](this[PROPS_KEY], this[STATE_KEY]);
      this[ATTRIBUTES_KEY_SYMBOL].unmount(); // if the preserveRoot is null the template html will be left untouched
      // in that case the DOM cleanup will happen differently from a parent node

      this[TEMPLATE_KEY_SYMBOL].unmount(this, this[PARENT_KEY_SYMBOL], preserveRoot === null ? null : !preserveRoot);
      this[ON_UNMOUNTED_KEY](this[PROPS_KEY], this[STATE_KEY]);
      return this;
    }

  })), Object.keys(component).filter(prop => isFunction(component[prop])));
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/instantiate-component.js
/* Riot WIP, @license MIT */







/**
 * Component definition function
 * @param   {Object} implementation - the component implementation will be generated via compiler
 * @param   {Object} component - the component initial properties
 * @returns {Object} a new component implementation object
 */

function instantiateComponent(_ref) {
  let {
    css,
    template,
    componentAPI,
    name
  } = _ref;
  // add the component css into the DOM
  if (css && name) cssManager.add(name, css);
  return curry(manageComponentLifecycle)(defineProperties( // set the component defaults without overriding the original component API
  defineDefaults(componentAPI, Object.assign({}, COMPONENT_LIFECYCLE_METHODS, {
    [PROPS_KEY]: {},
    [STATE_KEY]: {}
  })), Object.assign({
    // defined during the component creation
    [SLOTS_KEY]: null,
    [ROOT_KEY]: null
  }, COMPONENT_DOM_SELECTORS, {
    name,
    css,
    template
  })));
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/create-component-from-wrapper.js
/* Riot WIP, @license MIT */






/**
 * Create the component interface needed for the @riotjs/dom-bindings tag bindings
 * @param   {RiotComponentWrapper} componentWrapper - riot compiler generated object
 * @param   {string} componentWrapper.css - component css
 * @param   {Function} componentWrapper.template - function that will return the dom-bindings template function
 * @param   {Object} componentWrapper.exports - component interface
 * @param   {string} componentWrapper.name - component name
 * @returns {Object} component like interface
 */

function createComponentFromWrapper(componentWrapper) {
  const {
    css,
    template,
    exports,
    name
  } = componentWrapper;
  const templateFn = template ? componentTemplateFactory(template, componentWrapper) : MOCKED_TEMPLATE_INTERFACE;
  return _ref => {
    let {
      slots,
      attributes,
      props
    } = _ref;
    // pure components rendering will be managed by the end user
    if (exports && exports[IS_PURE_SYMBOL]) return createPureComponent(exports, {
      slots,
      attributes,
      props,
      css,
      template
    });
    const componentAPI = callOrAssign(exports) || {};
    const component = instantiateComponent({
      css,
      template: templateFn,
      componentAPI,
      name
    })({
      slots,
      attributes,
      props
    }); // notice that for the components created via tag binding
    // we need to invert the mount (state/parentScope) arguments
    // the template bindings will only forward the parentScope updates
    // and never deal with the component state

    return {
      mount(element, parentScope, state) {
        return component.mount(element, state, parentScope);
      },

      update(parentScope, state) {
        return component.update(state, parentScope);
      },

      unmount(preserveRoot) {
        return component.unmount(preserveRoot);
      }

    };
  };
}
/**
 * Performance optimization for the recursive components
 * @param  {RiotComponentWrapper} componentWrapper - riot compiler generated object
 * @returns {Object} component like interface
 */

const memoizedCreateComponentFromWrapper = memoize(createComponentFromWrapper);



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/register.js
/* Riot WIP, @license MIT */



/**
 * Register a custom tag by name
 * @param   {string} name - component name
 * @param   {Object} implementation - tag implementation
 * @returns {Map} map containing all the components implementations
 */

function register(name, _ref) {
  let {
    css,
    template,
    exports
  } = _ref;
  if (COMPONENTS_IMPLEMENTATION_MAP.has(name)) panic(`The component "${name}" was already registered`);
  COMPONENTS_IMPLEMENTATION_MAP.set(name, createComponentFromWrapper({
    name,
    css,
    template,
    exports
  }));
  return COMPONENTS_IMPLEMENTATION_MAP;
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/unregister.js
/* Riot WIP, @license MIT */



/**
 * Unregister a riot web component
 * @param   {string} name - component name
 * @returns {Map} map containing all the components implementations
 */

function unregister(name) {
  if (!COMPONENTS_IMPLEMENTATION_MAP.has(name)) panic(`The component "${name}" was never registered`);
  COMPONENTS_IMPLEMENTATION_MAP["delete"](name);
  cssManager.remove(name);
  return COMPONENTS_IMPLEMENTATION_MAP;
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/core/mount-component.js
/* Riot WIP, @license MIT */



/**
 * Component initialization function starting from a DOM node
 * @param   {HTMLElement} element - element to upgrade
 * @param   {Object} initialProps - initial component properties
 * @param   {string} componentName - component id
 * @param   {Array} slots - component slots
 * @returns {Object} a new component instance bound to a DOM node
 */

function mountComponent(element, initialProps, componentName, slots) {
  const name = componentName || getName(element);
  if (!COMPONENTS_IMPLEMENTATION_MAP.has(name)) panic(`The component named "${name}" was never registered`);
  const component = COMPONENTS_IMPLEMENTATION_MAP.get(name)({
    props: initialProps,
    slots
  });
  return component.mount(element);
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/mount.js
/* Riot WIP, @license MIT */



/**
 * Mounting function that will work only for the components that were globally registered
 * @param   {string|HTMLElement} selector - query for the selection or a DOM element
 * @param   {Object} initialProps - the initial component properties
 * @param   {string} name - optional component name
 * @returns {Array} list of riot components
 */

function mount(selector, initialProps, name) {
  return $(selector).map(element => mountComponent(element, initialProps, name));
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/unmount.js
/* Riot WIP, @license MIT */



/**
 * Sweet unmounting helper function for the DOM node mounted manually by the user
 * @param   {string|HTMLElement} selector - query for the selection or a DOM element
 * @param   {boolean|null} keepRootElement - if true keep the root element
 * @returns {Array} list of nodes unmounted
 */

function unmount(selector, keepRootElement) {
  return $(selector).map(element => {
    if (element[DOM_COMPONENT_INSTANCE_PROPERTY]) {
      element[DOM_COMPONENT_INSTANCE_PROPERTY].unmount(keepRootElement);
    }

    return element;
  });
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/install.js
/* Riot WIP, @license MIT */


/**
 * Define a riot plugin
 * @param   {Function} plugin - function that will receive all the components created
 * @returns {Set} the set containing all the plugins installed
 */

function install(plugin) {
  if (!isFunction(plugin)) panic('Plugins must be of type function');
  if (PLUGINS_SET.has(plugin)) panic('This plugin was already installed');
  PLUGINS_SET.add(plugin);
  return PLUGINS_SET;
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/uninstall.js
/* Riot WIP, @license MIT */


/**
 * Uninstall a riot plugin
 * @param   {Function} plugin - plugin previously installed
 * @returns {Set} the set containing all the plugins installed
 */

function uninstall(plugin) {
  if (!PLUGINS_SET.has(plugin)) panic('This plugin was never installed');
  PLUGINS_SET["delete"](plugin);
  return PLUGINS_SET;
}



;// CONCATENATED MODULE: ./node_modules/cumpa/index.next.js
/**
 * Similar to compose but performs from left-to-right function composition.<br/>
 * {@link https://30secondsofcode.org/function#composeright see also}
 * @param   {...[function]} fns) - list of unary function
 * @returns {*} result of the computation
 */
const composeRight = (...fns) => compose(...fns.reverse())

/**
 * Performs right-to-left function composition.<br/>
 * Use Array.prototype.reduce() to perform right-to-left function composition.<br/>
 * The last (rightmost) function can accept one or more arguments; the remaining functions must be unary.<br/>
 * {@link https://30secondsofcode.org/function#compose original source code}
 * @param   {...[function]} fns) - list of unary function
 * @returns {*} result of the computation
 */
function compose(...fns) {
  return fns.reduce((f, g) => (...args) => f(g(...args)))
}
;// CONCATENATED MODULE: ./node_modules/riot/esm/api/component.js
/* Riot WIP, @license MIT */



/**
 * Helper method to create component without relying on the registered ones
 * @param   {Object} implementation - component implementation
 * @returns {Function} function that will allow you to mount a riot component on a DOM node
 */

function component(implementation) {
  return function (el, props, _temp) {
    let {
      slots,
      attributes,
      parentScope
    } = _temp === void 0 ? {} : _temp;
    return compose(c => c.mount(el, parentScope), c => c({
      props,
      slots,
      attributes
    }), createComponentFromWrapper)(implementation);
  };
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/pure.js
/* Riot WIP, @license MIT */


/**
 * Lift a riot component Interface into a pure riot object
 * @param   {Function} func - RiotPureComponent factory function
 * @returns {Function} the lifted original function received as argument
 */

function pure(func) {
  if (!isFunction(func)) panic('riot.pure accepts only arguments of type "function"');
  func[IS_PURE_SYMBOL] = true;
  return func;
}



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/with-types.js
/* Riot WIP, @license MIT */
/**
 * no-op function needed to add the proper types to your component via typescript
 * @param {Function|Object} component - component default export
 * @returns {Function|Object} returns exactly what it has received
 */

/* istanbul ignore next */
const withTypes = component => component;



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/version.js
/* Riot WIP, @license MIT */
/** @type {string} current riot version */
const version = 'WIP';



;// CONCATENATED MODULE: ./node_modules/riot/esm/api/__.js
/* Riot WIP, @license MIT */




const __ = {
  cssManager: cssManager,
  DOMBindings: {
    template: create,
    createBinding: create$1,
    createExpression: create$4,
    bindingTypes: binding_types,
    expressionTypes: expression_types
  },
  globals: {
    DOM_COMPONENT_INSTANCE_PROPERTY: DOM_COMPONENT_INSTANCE_PROPERTY,
    PARENT_KEY_SYMBOL: PARENT_KEY_SYMBOL
  }
};



;// CONCATENATED MODULE: ./node_modules/riot/esm/riot.js
/* Riot WIP, @license MIT */












;// CONCATENATED MODULE: ./app/assets/js/components/offensive_language.riot
function _createForOfIteratorHelper(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (!it) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = it.call(o); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }
function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }
function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
/* harmony default export */ const offensive_language = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      _classCallCheck(this, exports);
    }
    _createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount(props, state) {
        var _this = this;
        this.toggle = this.toggle.bind(this);
        state.revealed = props.revealed == 'true';
        state.content = this.root.textContent;
        var _iterator = _createForOfIteratorHelper(this.root.childNodes),
          _step;
        try {
          for (_iterator.s(); !(_step = _iterator.n()).done;) {
            var n = _step.value;
            this.root.removeChild(n);
          }
        } catch (err) {
          _iterator.e(err);
        } finally {
          _iterator.f();
        }
        this.on('ol.toggle', function (event) {
          return _this.toggle(event.data.reveal);
        });
      }
    }, {
      key: "showModal",
      value: function showModal(event) {
        event.preventDefault();
        this.bus.emit('ol.modal', {
          toggle: this.toggle,
          current: this.state.revealed
        });
      }
    }, {
      key: "toggle",
      value: function toggle(newState) {
        this.update({
          revealed: newState
        });
      }
    }, {
      key: "noParentHover",
      value: function noParentHover(event, activate) {
        var parent = this.root.parentElement;
        var tn = parent.tagName;
        if (tn == 'A') {
          var f = activate ? 'add' : 'remove';
          parent.classList[f]('text-decoration-none');
        }
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<span expr70="expr70"> <a expr71="expr71" href="#">*</a></span><template expr72="expr72"></template><a expr73="expr73" href="#"><span expr74="expr74"> </span></a>', [{
      redundantAttribute: 'expr70',
      selector: '[expr70]',
      expressions: [{
        type: expressionTypes.TEXT,
        childNodeIndex: 0,
        evaluate: function evaluate(_scope) {
          return _scope.state.content;
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return ['original ', _scope.state.revealed ? 'd-inline' : 'd-none'].join('');
        }
      }]
    }, {
      redundantAttribute: 'expr71',
      selector: '[expr71]',
      expressions: [{
        type: expressionTypes.EVENT,
        name: 'onclick',
        evaluate: function evaluate(_scope) {
          return function (event) {
            return _scope.showModal(event);
          };
        }
      }]
    }, {
      type: bindingTypes.IF,
      evaluate: function evaluate(_scope) {
        return !_scope.state.revealed;
      },
      redundantAttribute: 'expr72',
      selector: '[expr72]',
      template: _template(' ', [{
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.props.replacement[0];
          }
        }]
      }])
    }, {
      redundantAttribute: 'expr73',
      selector: '[expr73]',
      expressions: [{
        type: expressionTypes.EVENT,
        name: 'onclick',
        evaluate: function evaluate(_scope) {
          return function (event) {
            return _scope.showModal(event);
          };
        }
      }, {
        type: expressionTypes.EVENT,
        name: 'onmouseover',
        evaluate: function evaluate(_scope) {
          return function (event) {
            return _scope.noParentHover(event, true);
          };
        }
      }, {
        type: expressionTypes.EVENT,
        name: 'onmouseout',
        evaluate: function evaluate(_scope) {
          return function (event) {
            return _scope.noParentHover(event, false);
          };
        }
      }]
    }, {
      redundantAttribute: 'expr74',
      selector: '[expr74]',
      expressions: [{
        type: expressionTypes.TEXT,
        childNodeIndex: 0,
        evaluate: function evaluate(_scope) {
          return _scope.props.replacement.slice(1);
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return ['replacement ', _scope.state.revealed ? 'd-none' : 'd-inline'].join('');
        }
      }]
    }]);
  },
  name: 'pm-offensive-language'
});
;// CONCATENATED MODULE: ./app/assets/js/lib/offensive_language.js
// TODO https://github.com/LeonieWeissweiler/CISTEM





register('pm-ol', offensive_language)

let jobs = []

let pageStorage = {'ol.revealed': false}

const revealed = () => {
  // return sessionStorage.getItem('ol.revealed') == 'true'
  return pageStorage['ol.revealed']
}

const toggle = (newValue) => {
  // sessionStorage.setItem('ol.revealed', newValue)
  pageStorage['ol.revealed'] = newValue
}

// wrap a regex pattern in tokenizing lookbehind and lookahead
const asToken = (pattern) => {
  const d = /^|[\s"';,\.]+|$/
  const c = /[^\s"';,\.]*/
  const str = `(?<=${d.source})${c.source}${pattern.source}${c.source}(?=${d.source})`
  return new RegExp(str, pattern.flags)
}

const replacements = [
  {pattern: asToken(/Zigeuner(?:in|innen|s)?/), replacement: 'Z***'},
  {pattern: asToken(/Mohr(?:in|innen|s|en)?/i), replacement: 'M***'},
  {pattern: asToken(/Neger(?:in|innen|s)?/i), replacement: 'N***'},
  {pattern: asToken(/Indianer(?:in|innen|s)?/i), replacement: 'I***'}
]

const replace = () => {
  for (const {type, node, m, replacement} of jobs) {
    if (type == 'text') {
      // split the text node apart
      let after = node.splitText(m.index)
      let before = node
      let tmp = after.splitText(m[0].length)
      let swap = after
      after = tmp

      // ... and replace the matched part
      const widget = document.createElement('pm-ol')
      widget.setAttribute('replacement', replacement)
      widget.setAttribute('revealed', revealed())
      swap.parentNode.replaceChild(widget, swap)
      widget.append(swap)

      mount(widget)
    }

    if (type == 'title') {
      const original = node.getAttribute('title')
      node.setAttribute('title', replacement)

      console.log(original, replacement)
      const handler = () => {
        const revealed = pageStorage['ol.revealed']

        node.setAttribute('title', revealed ? original : replacement)
      }

      bus.addEventListener('ol.toggle', handler)
      handler()
    }
  }
}

const offensive_language_process = (node) => {
  if (node.nodeType == Node.TEXT_NODE) {
    for (const r of replacements) {
      const m = node.data.match(r.pattern)
      if (m) {
        jobs.push({node, m, replacement: r.replacement, type: 'text'})
      }
    }
  }

  if (node.nodeType == Node.ELEMENT_NODE) {
    const title = node.getAttribute('title')

    if (title) {
      for (const r of replacements) {
        const m = title.match(r.pattern)
        if (m) {
          jobs.push({node, m, replacement: r.replacement, type: 'title'})
        }
      }
    }
  }
}

const idempotencyFilter = {
  acceptNode: (node) => {
    if (node.nodeType == Node.ELEMENT_NODE) {
      if (node.tagName == 'PM-OL') {
        return NodeFilter.FILTER_REJECT
      }

      return NodeFilter.FILTER_ACCEPT
    }

    return NodeFilter.FILTER_ACCEPT
  }
}

const setup = (selector) => {
  bus.addEventListener('ol.toggle', event => toggle(event.data.reveal))

  const startedAt = new Date()

  jobs = []
  const regions = document.querySelectorAll(selector)
  for (const region of regions) {
    const walker = document.createTreeWalker(
      region,
      NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT,
      idempotencyFilter
    )
    while (walker.nextNode()) {
      const node = walker.currentNode
      offensive_language_process(node)
    }
  }
  replace()

  const doneAt = new Date()
  // console.log(`finished offensive language setup in ${doneAt - startedAt}ms`)

  document.body.classList.remove('d-none')
}



;// CONCATENATED MODULE: ./app/assets/js/components/raw.riot
function raw_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function raw_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function raw_createClass(Constructor, protoProps, staticProps) { if (protoProps) raw_defineProperties(Constructor.prototype, protoProps); if (staticProps) raw_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
/* harmony default export */ const raw = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      raw_classCallCheck(this, exports);
    }
    raw_createClass(exports, [{
      key: "setInnerHTML",
      value: function setInnerHTML() {
        this.root.innerHTML = this.props.html;
      }
    }, {
      key: "onMounted",
      value: function onMounted() {
        this.setInnerHTML();
      }
    }, {
      key: "onUpdated",
      value: function onUpdated() {
        this.setInnerHTML();
      }
    }]);
    return exports;
  }(),
  template: null,
  name: 'raw'
});
;// CONCATENATED MODULE: ./app/assets/js/components/live_search.riot
var _class;
function live_search_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function live_search_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function live_search_createClass(Constructor, protoProps, staticProps) { if (protoProps) live_search_defineProperties(Constructor.prototype, protoProps); if (staticProps) live_search_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }


/* harmony default export */ const live_search = ({
  css: null,
  exports: (_class = /*#__PURE__*/function () {
    function exports() {
      live_search_classCallCheck(this, exports);
      this.lookup = this.lookup.bind(this);
      this.onKeyUp = this.onKeyUp.bind(this);
      this.nosuggest = this.nosuggest.bind(this);
      this.onFocus = this.onFocus.bind(this);
      this.preventClose = this.preventClose.bind(this);
      this.applySelection = this.applySelection.bind(this);
      this.select = this.select.bind(this);
      this.noselect = this.noselect.bind(this);
      this.delayedLookup = util_delay(this.lookup, 500);
    }
    live_search_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount(props) {
        if (!props.lookup) {
          throw "please provide a lookup function";
        }
        this.state = {
          label: props.label || '',
          value: props.value || '',
          suggestions: [],
          selection: -1,
          currentLine: -1,
          close: true,
          currentTerm: ''
        };
      }
    }, {
      key: "onChange",
      value: function onChange(event) {
        var label = event.target.value;
        this.update({
          label: label,
          value: ''
        });
        this.delayedLookup(label);
      }
    }, {
      key: "onKeyUp",
      value: function onKeyUp(event) {
        switch (event.code) {
          case 'ArrowDown':
            this.select(this.state.selection + 1);
            break;
          case 'ArrowUp':
            this.select(this.state.selection - 1);
            break;
          case 'Escape':
            this.nosuggest();
            break;
          case 'Enter':
            event.preventDefault();
            this.applySelection();
            break;
          default:
            this.onChange(event);
            break;
        }
      }
    }, {
      key: "onFocus",
      value: function onFocus(event) {
        if (this.props.triggerOnFocus) {
          var term = this.state.label;
          if (term || this.props.triggerIfEmpty) {
            this.lookup(term);
          }
        }
      }
    }, {
      key: "preventClose",
      value: function preventClose() {
        this.state.close = false;
      }
    }, {
      key: "enableClose",
      value: function enableClose() {
        this.state.close = true;
      }
    }, {
      key: "applySelection",
      value: function applySelection(event) {
        this.enableClose();
        var selection = this.state.selection;
        if (selection != -1) {
          var item = this.state.suggestions[selection];
          this.update({
            label: this.applySuggestToLabel(item),
            value: item.value,
            selection: -1,
            suggestions: []
          });
        }
      }
    }, {
      key: "applySuggestToLabel",
      value: function applySuggestToLabel(item) {
        var def = function def(item) {
          return item.value;
        };
        var func = this.props.applySuggestToLabel || def;
        return func(item);
      }
    }, {
      key: "renderSuggestion",
      value: function renderSuggestion(item) {
        var def = function def(item) {
          return item.label;
        };
        var func = this.props.renderSuggestion || def;
        return func(item);
      }
    }, {
      key: "select",
      value: function select(item) {
        var selection = this.state.selection;
        var count = this.state.suggestions.length;
        var newSelection = -1;
        if (count > 0) {
          newSelection = util_clamp(item, 0, count - 1);
        }
        this.update({
          selection: newSelection
        });
      }
    }, {
      key: "noselect",
      value: function noselect(event) {
        this.update({
          selection: -1
        });
      }
    }, {
      key: "nosuggest",
      value: function nosuggest(event) {
        if (this.state.close == false) {
          return;
        }
        this.update({
          suggestions: [],
          selection: -1
        });
      }
    }, {
      key: "lookup",
      value: function lookup(term) {
        var _this = this;
        this.notify('onLoading');
        if (this.state.stop) {
          return;
        }
        if (this.state.currentTerm == term) {
          return;
        } else {
          this.update({
            currentTerm: term
          });
        }
        this.props.lookup(term).then(function (data) {
          _this.update({
            suggestions: data
          });
          _this.notify('onLoadingComplete');
        });
      }
    }, {
      key: "notify",
      value: function notify(handlerName) {
        var handler = this.props[handlerName];
        if (handler) {
          handler();
        }
      }
    }, {
      key: "setOverflow",
      value: function setOverflow(value) {
        this.update({
          overflowY: value
        });
      }
    }, {
      key: "input",
      value: function input() {
        this.root.querySelector("input[name='".concat(this.props.name, ".label']"));
      }
    }, {
      key: "offsetWidth",
      value: function offsetWidth() {
        if (this.input()) {
          return this.input().offsetWidth;
        }
      }
    }, {
      key: "overflowY",
      value: function overflowY() {
        return this.state.overflowY || 'hidden';
      }
    }]);
    return exports;
  }(), _defineProperty(_class, "components", {
    'raw': raw
  }), _class),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<input expr0="expr0" type="text" autocomplete="off" spellcheck="false"/><input expr1="expr1" type="hidden"/><ul expr2="expr2"><li expr3="expr3"></li></ul>', [{
      redundantAttribute: 'expr0',
      selector: '[expr0]',
      expressions: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'id',
        evaluate: function evaluate(_scope) {
          return [_scope.props.name, '.label'].join('');
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'name',
        evaluate: function evaluate(_scope) {
          return [_scope.props.name, '.label'].join('');
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return ['form-control ', _scope.state.value ? 'is-valid' : ''].join('');
        }
      }, {
        type: expressionTypes.EVENT,
        name: 'onkeyup',
        evaluate: function evaluate(_scope) {
          return _scope.onKeyUp;
        }
      }, {
        type: expressionTypes.EVENT,
        name: 'onblur',
        evaluate: function evaluate(_scope) {
          return _scope.nosuggest;
        }
      }, {
        type: expressionTypes.EVENT,
        name: 'onfocus',
        evaluate: function evaluate(_scope) {
          return _scope.onFocus;
        }
      }, {
        type: expressionTypes.VALUE,
        evaluate: function evaluate(_scope) {
          return _scope.state.label;
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'disabled',
        evaluate: function evaluate(_scope) {
          return _scope.props.disabled;
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'placeholder',
        evaluate: function evaluate(_scope) {
          return _scope.props.placeholder || "Start typing ...";
        }
      }]
    }, {
      redundantAttribute: 'expr1',
      selector: '[expr1]',
      expressions: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'name',
        evaluate: function evaluate(_scope) {
          return _scope.props.name;
        }
      }, {
        type: expressionTypes.VALUE,
        evaluate: function evaluate(_scope) {
          return _scope.state.value;
        }
      }]
    }, {
      redundantAttribute: 'expr2',
      selector: '[expr2]',
      expressions: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'style',
        evaluate: function evaluate(_scope) {
          return ['min-width: ', _scope.offsetWidth(), '; overflow-y: ', _scope.overflowY()].join('');
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return ['bg-dark list-unstyled ', _scope.state.suggestions.length == 0 ? '' : 'show'].join('');
        }
      }, {
        type: expressionTypes.EVENT,
        name: 'ontransitionend',
        evaluate: function evaluate(_scope) {
          return function (event) {
            return _scope.setOverflow('auto');
          };
        }
      }]
    }, {
      type: bindingTypes.EACH,
      getKey: function getKey(_scope) {
        return _scope.i[0];
      },
      condition: null,
      template: _template('<template expr4="expr4"></template><raw expr6="expr6"></raw>', [{
        expressions: [{
          type: expressionTypes.ATTRIBUTE,
          name: 'class',
          evaluate: function evaluate(_scope) {
            return _scope.i[0] == _scope.state.selection ? 'selected' : '';
          }
        }, {
          type: expressionTypes.EVENT,
          name: 'onmousedown',
          evaluate: function evaluate(_scope) {
            return _scope.preventClose;
          }
        }, {
          type: expressionTypes.EVENT,
          name: 'onclick',
          evaluate: function evaluate(_scope) {
            return _scope.applySelection;
          }
        }, {
          type: expressionTypes.EVENT,
          name: 'onmouseenter',
          evaluate: function evaluate(_scope) {
            return function () {
              return _scope.select(_scope.i[0]);
            };
          }
        }, {
          type: expressionTypes.EVENT,
          name: 'onmouseleave',
          evaluate: function evaluate(_scope) {
            return _scope.noselect;
          }
        }]
      }, {
        type: bindingTypes.IF,
        evaluate: function evaluate(_scope) {
          return _scope.i[1].icon;
        },
        redundantAttribute: 'expr4',
        selector: '[expr4]',
        template: _template('<img expr5="expr5"/>', [{
          redundantAttribute: 'expr5',
          selector: '[expr5]',
          expressions: [{
            type: expressionTypes.ATTRIBUTE,
            name: 'src',
            evaluate: function evaluate(_scope) {
              return _scope.i[1].icon;
            }
          }]
        }])
      }, {
        type: bindingTypes.TAG,
        getComponent: getComponent,
        evaluate: function evaluate(_scope) {
          return 'raw';
        },
        slots: [],
        attributes: [{
          type: expressionTypes.ATTRIBUTE,
          name: 'html',
          evaluate: function evaluate(_scope) {
            return _scope.renderSuggestion(_scope.i[1]);
          }
        }],
        redundantAttribute: 'expr6',
        selector: '[expr6]'
      }]),
      redundantAttribute: 'expr3',
      selector: '[expr3]',
      itemName: 'i',
      indexName: null,
      evaluate: function evaluate(_scope) {
        return Object.entries(_scope.state.suggestions);
      }
    }]);
  },
  name: 'live-search'
});
;// CONCATENATED MODULE: ./app/assets/js/components/loading_indicator.riot
function loading_indicator_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function loading_indicator_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function loading_indicator_createClass(Constructor, protoProps, staticProps) { if (protoProps) loading_indicator_defineProperties(Constructor.prototype, protoProps); if (staticProps) loading_indicator_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
/* harmony default export */ const loading_indicator = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      loading_indicator_classCallCheck(this, exports);
    }
    loading_indicator_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount() {
        this.onLoadingStateChange = this.onLoadingStateChange.bind(this);
        this.state = {
          count: 0
        };
        this.on('loading-state-change', this.onLoadingStateChange);
      }
    }, {
      key: "onLoadingStateChange",
      value: function onLoadingStateChange(event) {
        this.update({
          count: event.data.count
        });
      }
    }, {
      key: "active",
      value: function active() {
        return this.state.count > 0;
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<div expr14="expr14"><div></div><div></div><div></div><div></div></div>', [{
      redundantAttribute: 'expr14',
      selector: '[expr14]',
      expressions: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return ['lds-ellipsis ', _scope.active() ? '' : 'd-none'].join('');
        }
      }]
    }]);
  },
  name: 'pm-loading-indicator'
});
;// CONCATENATED MODULE: ./app/assets/js/components/modal.riot
function modal_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function modal_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function modal_createClass(Constructor, protoProps, staticProps) { if (protoProps) modal_defineProperties(Constructor.prototype, protoProps); if (staticProps) modal_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
/* harmony default export */ const modal = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      modal_classCallCheck(this, exports);
    }
    modal_createClass(exports, [{
      key: "close",
      value: function close() {
        if (this.props.close) {
          this.props.close();
        }
      }
    }, {
      key: "classes",
      value: function classes() {
        return this.props.open ? 'open' : '';
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<div expr51="expr51" class="backdrop"></div><div class="content"><slot expr52="expr52"></slot></div>', [{
      expressions: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return _scope.classes();
        }
      }]
    }, {
      redundantAttribute: 'expr51',
      selector: '[expr51]',
      expressions: [{
        type: expressionTypes.EVENT,
        name: 'onclick',
        evaluate: function evaluate(_scope) {
          return function (event) {
            return _scope.close();
          };
        }
      }]
    }, {
      type: bindingTypes.SLOT,
      attributes: [],
      name: 'default',
      redundantAttribute: 'expr52',
      selector: '[expr52]'
    }]);
  },
  name: 'pm-modal'
});
;// CONCATENATED MODULE: ./app/assets/js/components/ol_modal.riot
function ol_modal_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function ol_modal_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function ol_modal_createClass(Constructor, protoProps, staticProps) { if (protoProps) ol_modal_defineProperties(Constructor.prototype, protoProps); if (staticProps) ol_modal_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }

/* harmony default export */ const ol_modal = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      ol_modal_classCallCheck(this, exports);
    }
    ol_modal_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount() {
        this.launch = this.launch.bind(this);
        this.state = {
          open: false
        };
        this.on('ol.modal', this.launch);
      }
    }, {
      key: "launch",
      value: function launch(event) {
        this.update({
          open: true,
          toggle: event.data.toggle,
          current: event.data.current
        });
      }
    }, {
      key: "toggle",
      value: function toggle(reveal, event) {
        if (event) {
          event.preventDefault();
        }
        this.state.toggle(reveal);
        this.close();
      }
    }, {
      key: "toggleAll",
      value: function toggleAll(reveal, event) {
        if (event) {
          event.preventDefault();
        }
        this.bus.emit('ol.toggle', {
          reveal: reveal
        });
        this.close();
      }
    }, {
      key: "close",
      value: function close(event) {
        if (event) {
          event.preventDefault();
        }
        this.update({
          open: false
        });
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<div expr53="expr53" is="pm-modal"></div>', [{
      type: bindingTypes.TAG,
      getComponent: getComponent,
      evaluate: function evaluate(_scope) {
        return 'pm-modal';
      },
      slots: [{
        id: 'default',
        html: '<div class="d-flex flex-column justify-content-between p-4 border-box"><p expr54="expr54"> </p><div class="d-flex justify-content-end"><button expr55="expr55" class="ms-2 p-1"> </button><template expr56="expr56"></template><template expr59="expr59"></template></div></div>',
        bindings: [{
          redundantAttribute: 'expr54',
          selector: '[expr54]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.t('messages.offensive');
            }
          }]
        }, {
          redundantAttribute: 'expr55',
          selector: '[expr55]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.cap(_scope.t('Cancel'));
            }
          }, {
            type: expressionTypes.EVENT,
            name: 'onclick',
            evaluate: function evaluate(_scope) {
              return function (event) {
                return _scope.close(event);
              };
            }
          }]
        }, {
          type: bindingTypes.IF,
          evaluate: function evaluate(_scope) {
            return !_scope.state.current;
          },
          redundantAttribute: 'expr56',
          selector: '[expr56]',
          template: _template('<button expr57="expr57" class="ms-2 p-1"> </button><button expr58="expr58" class="ms-2 p-1"> </button>', [{
            redundantAttribute: 'expr57',
            selector: '[expr57]',
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 0,
              evaluate: function evaluate(_scope) {
                return _scope.cap(_scope.t('verbs.display'));
              }
            }, {
              type: expressionTypes.EVENT,
              name: 'onclick',
              evaluate: function evaluate(_scope) {
                return function (event) {
                  return _scope.toggle(true, event);
                };
              }
            }]
          }, {
            redundantAttribute: 'expr58',
            selector: '[expr58]',
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 0,
              evaluate: function evaluate(_scope) {
                return _scope.cap(_scope.t('verbs.display_all'));
              }
            }, {
              type: expressionTypes.EVENT,
              name: 'onclick',
              evaluate: function evaluate(_scope) {
                return function (event) {
                  return _scope.toggleAll(true, event);
                };
              }
            }]
          }])
        }, {
          type: bindingTypes.IF,
          evaluate: function evaluate(_scope) {
            return _scope.state.current;
          },
          redundantAttribute: 'expr59',
          selector: '[expr59]',
          template: _template('<button expr60="expr60" class="ms-2 p-1"> </button><button expr61="expr61" class="ms-2 p-1"> </button>', [{
            redundantAttribute: 'expr60',
            selector: '[expr60]',
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 0,
              evaluate: function evaluate(_scope) {
                return _scope.cap(_scope.t('verbs.hide'));
              }
            }, {
              type: expressionTypes.EVENT,
              name: 'onclick',
              evaluate: function evaluate(_scope) {
                return function (event) {
                  return _scope.toggle(false, event);
                };
              }
            }]
          }, {
            redundantAttribute: 'expr61',
            selector: '[expr61]',
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 0,
              evaluate: function evaluate(_scope) {
                return _scope.cap(_scope.t('verbs.hide_all'));
              }
            }, {
              type: expressionTypes.EVENT,
              name: 'onclick',
              evaluate: function evaluate(_scope) {
                return function (event) {
                  return _scope.toggleAll(false, event);
                };
              }
            }]
          }])
        }]
      }],
      attributes: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'open',
        evaluate: function evaluate(_scope) {
          return _scope.state.open;
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'close',
        evaluate: function evaluate(_scope) {
          return function () {
            return _scope.close();
          };
        }
      }],
      redundantAttribute: 'expr53',
      selector: '[expr53]'
    }]);
  },
  name: 'pm-ol-modal'
});
;// CONCATENATED MODULE: ./app/assets/js/components/size_indicator.riot
function size_indicator_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function size_indicator_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function size_indicator_createClass(Constructor, protoProps, staticProps) { if (protoProps) size_indicator_defineProperties(Constructor.prototype, protoProps); if (staticProps) size_indicator_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
/* harmony default export */ const size_indicator = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      size_indicator_classCallCheck(this, exports);
    }
    size_indicator_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount(props, state) {
        var limit = 560.0;
        state.refWidth = parseInt(props.refWidth, 10);
        state.refHeight = parseInt(props.refHeight, 10);
        state.artWidth = parseInt(props.artWidth, 10);
        state.artHeight = parseInt(props.artHeight, 10);
        state.max = parseInt(props.max, 10);
        state.rect = [this.project(state.artHeight), this.project(state.artWidth)];
        state.factor = 1.0;
        if (state.rect[0] * state.factor > limit) {
          state.factor *= limit / state.rect[0];
        }
        if (state.rect[1] * state.factor > limit) {
          state.factor *= limit / state.rect[1];
        }
        var img = this.image();
        if (img) {
          img.addEventListener('load', this.update);
        }
      }
    }, {
      key: "enabled",
      value: function enabled() {
        // return false

        var m = this.state.max;
        var w = this.state.artWidth;
        var h = this.state.artHeight;
        // console.log(m, w, h)

        if (!w || !h) {
          return false;
        }
        if (m && (w > m || h > m)) {
          return false;
        }
        return true;
      }
    }, {
      key: "project",
      value: function project(length) {
        var cm = 150 / this.state.refHeight;
        return cm * length;
      }
    }, {
      key: "personHeight",
      value: function personHeight() {
        return this.project(150) * this.state.factor;
      }
    }, {
      key: "offset",
      value: function offset() {
        var result = this.rect()[1] - this.personHeight() + 2;
        return result < 0 ? 0 : result;
      }
    }, {
      key: "rect",
      value: function rect() {
        var result = [this.state.rect[0] * this.state.factor, this.state.rect[1] * this.state.factor];
        if (!this.imgMatchesDims()) result.reverse();
        return result;
      }
    }, {
      key: "artWidth",
      value: function artWidth() {
        return this.imgMatchesDims() ? this.state.artWidth : this.state.artHeight;
      }
    }, {
      key: "artHeight",
      value: function artHeight() {
        return this.imgMatchesDims() ? this.state.artHeight : this.state.artWidth;
      }
    }, {
      key: "imgMatchesDims",
      value: function imgMatchesDims() {
        var o = this.orientation();
        if (o == 'landscape' && this.state.rect[0] > this.state.rect[1]) return false;
        if (o == 'portrait' && this.state.rect[0] < this.state.rect[1]) return false;
        return true;
      }
    }, {
      key: "orientation",
      value: function orientation() {
        var img = this.image();
        if (!img) return null;
        return img.offsetWidth > img.offsetHeight ? 'landscape' : 'portrait';
      }
    }, {
      key: "image",
      value: function image() {
        var selector = this.props.imageSelector;
        if (selector) {
          return document.querySelector(selector);
        }
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<div expr7="expr7" class="d-flex py-4 pe-4"></div><template expr13="expr13"></template>', [{
      type: bindingTypes.IF,
      evaluate: function evaluate(_scope) {
        return _scope.enabled();
      },
      redundantAttribute: 'expr7',
      selector: '[expr7]',
      template: _template('<div expr8="expr8" class="ref d-flex justify-content-stretch"><div expr9="expr9" class="align-self-center"> </div><svg xmlns="http://www.w3.org/2000/svg" class="me-2" width="20px" viewBox="0 0 20 150"><defs><marker id="triangle" viewBox="0 0 10 10" refX="1" refY="5" markerUnits="strokeWidth" markerWidth="10" markerHeight="10" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" fill="#aaaaaa"/></marker></defs><line x1="10" y1="5" x2="10" y2="145" stroke="white" stroke-width="0.5" marker-start="url(#triangle)" marker-end="url(#triangle)"/></svg><img src="/images/image/size_indicator.png"/></div><div class="ms-4"><div expr10="expr10" class="artwork d-flex justify-content-center align-items-center mb-2"></div><div expr11="expr11"> </div><div expr12="expr12" class="text-muted"> </div></div>', [{
        redundantAttribute: 'expr8',
        selector: '[expr8]',
        expressions: [{
          type: expressionTypes.ATTRIBUTE,
          name: 'style',
          evaluate: function evaluate(_scope) {
            return ['height: ', _scope.personHeight(), 'px; margin-top: ', _scope.offset(), 'px'].join('');
          }
        }]
      }, {
        redundantAttribute: 'expr9',
        selector: '[expr9]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return [_scope.state.refHeight, ' cm'].join('');
          }
        }]
      }, {
        redundantAttribute: 'expr10',
        selector: '[expr10]',
        expressions: [{
          type: expressionTypes.ATTRIBUTE,
          name: 'style',
          evaluate: function evaluate(_scope) {
            return ['width: ', _scope.rect()[1], 'px; height: ', _scope.rect()[0], 'px'].join('');
          }
        }]
      }, {
        redundantAttribute: 'expr11',
        selector: '[expr11]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return [_scope.artHeight(), ' cm × ', _scope.artWidth(), ' cm'].join('');
          }
        }]
      }, {
        redundantAttribute: 'expr12',
        selector: '[expr12]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return [_scope.props.unparsed].join('');
          }
        }]
      }])
    }, {
      type: bindingTypes.IF,
      evaluate: function evaluate(_scope) {
        return !_scope.enabled();
      },
      redundantAttribute: 'expr13',
      selector: '[expr13]',
      template: _template(' ', [{
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.props.unparsed;
          }
        }]
      }])
    }]);
  },
  name: 'pm-size-indicator'
});
;// CONCATENATED MODULE: ./app/assets/js/components/wd_modal.riot
function wd_modal_createForOfIteratorHelper(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (!it) { if (Array.isArray(o) || (it = wd_modal_unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = it.call(o); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }
function wd_modal_unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return wd_modal_arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return wd_modal_arrayLikeToArray(o, minLen); }
function wd_modal_arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }
function ownKeys(object, enumerableOnly) { var keys = Object.keys(object); if (Object.getOwnPropertySymbols) { var symbols = Object.getOwnPropertySymbols(object); enumerableOnly && (symbols = symbols.filter(function (sym) { return Object.getOwnPropertyDescriptor(object, sym).enumerable; })), keys.push.apply(keys, symbols); } return keys; }
function _objectSpread(target) { for (var i = 1; i < arguments.length; i++) { var source = null != arguments[i] ? arguments[i] : {}; i % 2 ? ownKeys(Object(source), !0).forEach(function (key) { wd_modal_defineProperty(target, key, source[key]); }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)) : ownKeys(Object(source)).forEach(function (key) { Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key)); }); } return target; }
function wd_modal_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }
function wd_modal_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function wd_modal_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function wd_modal_createClass(Constructor, protoProps, staticProps) { if (protoProps) wd_modal_defineProperties(Constructor.prototype, protoProps); if (staticProps) wd_modal_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }

/* harmony default export */ const wd_modal = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      wd_modal_classCallCheck(this, exports);
    }
    wd_modal_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount() {
        this.launch = this.launch.bind(this);
        this.lookup = this.lookup.bind(this);
        this.state = {
          open: false
        };
        this.on('wd.modal', this.launch);
      }
    }, {
      key: "launch",
      value: function launch(event) {
        // console.log(event)

        this.update(_objectSpread({
          open: true
        }, event.data));
      }
    }, {
      key: "lookup",
      value: function lookup(term) {
        var _this = this;
        this.update({
          active: true
        });
        var url = "/en/wikidata?term=".concat(term);
        return request(url).then(function (data) {
          // console.log(data)

          var results = [];
          var _iterator = wd_modal_createForOfIteratorHelper(data.search),
            _step;
          try {
            for (_iterator.s(); !(_step = _iterator.n()).done;) {
              var r = _step.value;
              if (!r.display || !r.display.label) {
                console.log('wikidata entry has no label:', r);
                continue;
              }
              var item = {
                label: r.display.label.value,
                value: r.id,
                data: r
              };
              if (r.display.description) {
                item['description'] = r.display.description.value;
              }
              results.push(item);
            }
          } catch (err) {
            _iterator.e(err);
          } finally {
            _iterator.f();
          }
          _this.update({
            active: false
          });
          return results;
        });
      }
    }, {
      key: "save",
      value: function save(event) {
        var _this2 = this;
        event.preventDefault();
        var newValue = this.root.querySelector('input').value;
        var url = ['/api/json/user_metadata', this.state.pid, this.state.field].join('/');
        if (!newValue || newValue.match(/^\s*$/)) {
          return;
        }
        var promise = request(url, {
          method: 'PATCH',
          body: JSON.stringify({
            value: newValue,
            position: this.state.position
          })
        });
        promise.then(function (data) {
          var n = _this2.state.notifyNewValue;
          if (n) n(newValue);
          _this2.close();
        });
      }
    }, {
      key: "remove",
      value: function remove(event) {
        var _this3 = this;
        event.preventDefault();
        var url = ['/api/json/user_metadata', this.state.pid, this.state.field].join('/');
        var promise = request(url, {
          method: 'PATCH',
          body: JSON.stringify({
            value: null,
            position: this.state.position
          })
        });
        promise.then(function (data) {
          var n = _this3.state.notifyNewValue;
          if (n) n(null);
          _this3.close();
        });
      }
    }, {
      key: "renderSuggestion",
      value: function renderSuggestion(item) {
        return "".concat(item.label, "<small class=\"d-block fw-normal\">").concat(item.description || '', "</small>");
      }
    }, {
      key: "onKeyDown",
      value: function onKeyDown(event) {
        if (event.key == 'Escape') {
          this.close();
        }
      }
    }, {
      key: "close",
      value: function close(event) {
        if (event) event.preventDefault();
        this.update({
          open: false
        });
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<div expr15="expr15" is="pm-modal"></div>', [{
      expressions: [{
        type: expressionTypes.EVENT,
        name: 'onkeydown',
        evaluate: function evaluate(_scope) {
          return function (event) {
            return _scope.onKeyDown(event);
          };
        }
      }]
    }, {
      type: bindingTypes.TAG,
      getComponent: getComponent,
      evaluate: function evaluate(_scope) {
        return 'pm-modal';
      },
      slots: [{
        id: 'default',
        html: '<div expr16="expr16" class="d-flex flex-column justify-content-between p-4 border-box"> <div class="d-flex"><pm-live-search expr17="expr17" class="mt-3 my-3" name="wikidata_id"></pm-live-search><pm-loading-indicator expr18="expr18"></pm-loading-indicator></div><div class="d-flex justify-content-end"><button expr19="expr19" class="ms-2 p-1"> </button><button expr20="expr20" class="ms-2 p-1"> </button><button expr21="expr21" class="ms-2 p-1"> </button></div></div>',
        bindings: [{
          redundantAttribute: 'expr16',
          selector: '[expr16]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return [_scope.t('messages.wikidata_editor')].join('');
            }
          }]
        }, {
          type: bindingTypes.IF,
          evaluate: function evaluate(_scope) {
            return _scope.state.open;
          },
          redundantAttribute: 'expr17',
          selector: '[expr17]',
          template: _template(null, [{
            type: bindingTypes.TAG,
            getComponent: getComponent,
            evaluate: function evaluate(_scope) {
              return 'pm-live-search';
            },
            slots: [],
            attributes: [{
              type: expressionTypes.ATTRIBUTE,
              name: 'label',
              evaluate: function evaluate(_scope) {
                return _scope.state.value;
              }
            }, {
              type: expressionTypes.ATTRIBUTE,
              name: 'value',
              evaluate: function evaluate(_scope) {
                return _scope.state.value;
              }
            }, {
              type: expressionTypes.ATTRIBUTE,
              name: 'lookup',
              evaluate: function evaluate(_scope) {
                return _scope.lookup;
              }
            }, {
              type: expressionTypes.ATTRIBUTE,
              name: 'render-suggestion',
              evaluate: function evaluate(_scope) {
                return _scope.renderSuggestion;
              }
            }, {
              type: expressionTypes.ATTRIBUTE,
              name: 'placeholder',
              evaluate: function evaluate(_scope) {
                return _scope.t('messages.start_typing');
              }
            }]
          }])
        }, {
          type: bindingTypes.TAG,
          getComponent: getComponent,
          evaluate: function evaluate(_scope) {
            return 'pm-loading-indicator';
          },
          slots: [],
          attributes: [],
          redundantAttribute: 'expr18',
          selector: '[expr18]'
        }, {
          redundantAttribute: 'expr19',
          selector: '[expr19]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.cap(_scope.t('verbs.save'));
            }
          }, {
            type: expressionTypes.EVENT,
            name: 'onclick',
            evaluate: function evaluate(_scope) {
              return function (event) {
                return _scope.save(event);
              };
            }
          }]
        }, {
          redundantAttribute: 'expr20',
          selector: '[expr20]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.cap(_scope.t('verbs.delete'));
            }
          }, {
            type: expressionTypes.EVENT,
            name: 'onclick',
            evaluate: function evaluate(_scope) {
              return function (event) {
                return _scope.remove(event);
              };
            }
          }]
        }, {
          redundantAttribute: 'expr21',
          selector: '[expr21]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.cap(_scope.t('verbs.cancel'));
            }
          }, {
            type: expressionTypes.EVENT,
            name: 'onclick',
            evaluate: function evaluate(_scope) {
              return function (event) {
                return _scope.close(event);
              };
            }
          }]
        }]
      }],
      attributes: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'open',
        evaluate: function evaluate(_scope) {
          return _scope.state.open;
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'close',
        evaluate: function evaluate(_scope) {
          return function () {
            return _scope.close();
          };
        }
      }],
      redundantAttribute: 'expr15',
      selector: '[expr15]'
    }]);
  },
  name: 'pm-wd-modal'
});
;// CONCATENATED MODULE: ./app/assets/js/components/wikidata_widget.riot
function wikidata_widget_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function wikidata_widget_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function wikidata_widget_createClass(Constructor, protoProps, staticProps) { if (protoProps) wikidata_widget_defineProperties(Constructor.prototype, protoProps); if (staticProps) wikidata_widget_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }

/* harmony default export */ const wikidata_widget = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      wikidata_widget_classCallCheck(this, exports);
    }
    wikidata_widget_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount(props, state) {
        // console.log(props)

        this.state = {
          value: props.value,
          editing: false
        };
      }
    }, {
      key: "edit",
      value: function edit(event) {
        var _this = this;
        if (event) event.preventDefault();
        this.bus.emit('wd.modal', {
          pid: this.props.pid,
          field: this.props.field,
          position: this.props.position,
          value: this.state.value,
          notifyNewValue: function notifyNewValue(newValue) {
            return _this.update({
              value: newValue
            });
          }
        });
      }
    }, {
      key: "advancedSearchUrl",
      value: function advancedSearchUrl() {
        var base = "/".concat(locale(), "/searches/advanced");
        return "".concat(base, "?search_field[0]=all&search_value[0]=").concat(this.state.value);
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<template expr62="expr62"></template>', [{
      expressions: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return ['ms-5 ', _scope.state.editing ? 'editing' : '', ' ', _scope.props["class"]].join('');
        }
      }]
    }, {
      type: bindingTypes.IF,
      evaluate: function evaluate(_scope) {
        return !_scope.state.editing;
      },
      redundantAttribute: 'expr62',
      selector: '[expr62]',
      template: _template('<template expr63="expr63"></template><template expr68="expr68"></template>', [{
        type: bindingTypes.IF,
        evaluate: function evaluate(_scope) {
          return _scope.state.value;
        },
        redundantAttribute: 'expr63',
        selector: '[expr63]',
        template: _template('<a expr64="expr64"> </a>\n      (<a expr65="expr65" target="_blank" rel="noopener">Wikidata\n        <img src="/images/icon/arrow-up-right-from-square-solid.png"/></a>)\n      <a expr66="expr66" href="#"></a>', [{
          redundantAttribute: 'expr64',
          selector: '[expr64]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.state.value;
            }
          }, {
            type: expressionTypes.ATTRIBUTE,
            name: 'href',
            evaluate: function evaluate(_scope) {
              return _scope.advancedSearchUrl();
            }
          }, {
            type: expressionTypes.ATTRIBUTE,
            name: 'title',
            evaluate: function evaluate(_scope) {
              return _scope.t('verbs.search_in_prometheus');
            }
          }]
        }, {
          redundantAttribute: 'expr65',
          selector: '[expr65]',
          expressions: [{
            type: expressionTypes.ATTRIBUTE,
            name: 'href',
            evaluate: function evaluate(_scope) {
              return ['https://www.wikidata.org/wiki/', _scope.state.value].join('');
            }
          }, {
            type: expressionTypes.ATTRIBUTE,
            name: 'title',
            evaluate: function evaluate(_scope) {
              return _scope.t('to_wikidata_item');
            }
          }]
        }, {
          type: bindingTypes.IF,
          evaluate: function evaluate(_scope) {
            return _scope.props.allowEdit == 'true';
          },
          redundantAttribute: 'expr66',
          selector: '[expr66]',
          template: _template('<img expr67="expr67" src="/images/icon/edit.gif"/>', [{
            expressions: [{
              type: expressionTypes.EVENT,
              name: 'onclick',
              evaluate: function evaluate(_scope) {
                return function (event) {
                  return _scope.edit(event);
                };
              }
            }, {
              type: expressionTypes.ATTRIBUTE,
              name: 'title',
              evaluate: function evaluate(_scope) {
                return _scope.t('verbs.edit');
              }
            }]
          }, {
            type: bindingTypes.IF,
            evaluate: function evaluate(_scope) {
              return _scope.state.value;
            },
            redundantAttribute: 'expr67',
            selector: '[expr67]',
            template: _template(null, [])
          }])
        }])
      }, {
        type: bindingTypes.IF,
        evaluate: function evaluate(_scope) {
          return !_scope.state.value;
        },
        redundantAttribute: 'expr68',
        selector: '[expr68]',
        template: _template('<a expr69="expr69" href="#"></a>', [{
          type: bindingTypes.IF,
          evaluate: function evaluate(_scope) {
            return _scope.props.allowEdit == 'true';
          },
          redundantAttribute: 'expr69',
          selector: '[expr69]',
          template: _template(' <img class="d-inline-block ms-1" src="/images/icon/edit.gif"/>', [{
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 0,
              evaluate: function evaluate(_scope) {
                return [_scope.t('verbs.add_a_wikidata_id')].join('');
              }
            }, {
              type: expressionTypes.EVENT,
              name: 'onclick',
              evaluate: function evaluate(_scope) {
                return function (event) {
                  return _scope.edit(event);
                };
              }
            }, {
              type: expressionTypes.ATTRIBUTE,
              name: 'title',
              evaluate: function evaluate(_scope) {
                return _scope.t('verbs.edit');
              }
            }]
          }])
        }])
      }])
    }]);
  },
  name: 'wikidata-widget'
});
// EXTERNAL MODULE: ./node_modules/strftime/strftime.js
var strftime = __webpack_require__(1);
var strftime_default = /*#__PURE__*/__webpack_require__.n(strftime);
;// CONCATENATED MODULE: ./app/assets/js/components/indexing/result_modal.riot
function result_modal_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function result_modal_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function result_modal_createClass(Constructor, protoProps, staticProps) { if (protoProps) result_modal_defineProperties(Constructor.prototype, protoProps); if (staticProps) result_modal_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
/* harmony default export */ const result_modal = ({
  css: null,
  exports: /*#__PURE__*/function () {
    function exports() {
      result_modal_classCallCheck(this, exports);
    }
    result_modal_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount() {
        this.launch = this.launch.bind(this);
        this.state = {
          open: false
        };
        this.on('i.modal', this.launch);
      }
    }, {
      key: "launch",
      value: function launch(event) {
        this.update({
          open: true,
          toggle: event.data.toggle,
          current: event.data.current,
          data: event.data.result
        });
      }
    }, {
      key: "toggle",
      value: function toggle(reveal, event) {
        if (event) {
          event.preventDefault();
        }
        this.state.toggle(reveal);
        this.close();
      }
    }, {
      key: "toggleAll",
      value: function toggleAll(reveal, event) {
        if (event) {
          event.preventDefault();
        }
        this.bus.emit('i.toggle', {
          reveal: reveal
        });
        this.close();
      }
    }, {
      key: "close",
      value: function close(event) {
        if (event) {
          event.preventDefault();
        }
        this.update({
          open: false
        });
      }
    }]);
    return exports;
  }(),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<div expr75="expr75" is="pm-modal"></div>', [{
      type: bindingTypes.TAG,
      getComponent: getComponent,
      evaluate: function evaluate(_scope) {
        return 'pm-modal';
      },
      slots: [{
        id: 'default',
        html: '<pre expr76="expr76"> </pre>',
        bindings: [{
          redundantAttribute: 'expr76',
          selector: '[expr76]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return [JSON.stringify(_scope.state.data, null, 2)].join('');
            }
          }]
        }]
      }],
      attributes: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'open',
        evaluate: function evaluate(_scope) {
          return _scope.state.open;
        }
      }, {
        type: expressionTypes.ATTRIBUTE,
        name: 'close',
        evaluate: function evaluate(_scope) {
          return function () {
            return _scope.close();
          };
        }
      }],
      redundantAttribute: 'expr75',
      selector: '[expr75]'
    }]);
  },
  name: 'ir-modal'
});
;// CONCATENATED MODULE: ./app/assets/js/components/indexing_page.riot
var indexing_page_class;
function indexing_page_createForOfIteratorHelper(o, allowArrayLike) { var it = typeof Symbol !== "undefined" && o[Symbol.iterator] || o["@@iterator"]; if (!it) { if (Array.isArray(o) || (it = indexing_page_unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = it.call(o); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }
function indexing_page_unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return indexing_page_arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return indexing_page_arrayLikeToArray(o, minLen); }
function indexing_page_arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }
function indexing_page_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
function indexing_page_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
function indexing_page_createClass(Constructor, protoProps, staticProps) { if (protoProps) indexing_page_defineProperties(Constructor.prototype, protoProps); if (staticProps) indexing_page_defineProperties(Constructor, staticProps); Object.defineProperty(Constructor, "prototype", { writable: false }); return Constructor; }
function indexing_page_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }



var tmpResults = [];
/* harmony default export */ const indexing_page = ({
  css: null,
  exports: (indexing_page_class = /*#__PURE__*/function () {
    function exports() {
      indexing_page_classCallCheck(this, exports);
      this.locale = locale;
      this.fetchSamples = this.fetchSamples.bind(this);
    }
    indexing_page_createClass(exports, [{
      key: "onBeforeMount",
      value: function onBeforeMount(props, state) {
        var _this = this;
        state['imageUrls'] = {};
        request('/api/json/source/list?per_page=max').then(function (data) {
          // console.log(data)
          _this.update({
            sources: data
          });
        });
        request('/api/json/indexing/results').then(function (data) {
          // console.log(data)
          _this.update({
            results: data
          });
        });
        request('/api/json/indexing/counts').then(function (data) {
          // console.log(data)
          _this.update({
            counts: data
          });
        });
        this.fetchSamples();
      }
    }, {
      key: "fetchSamples",
      value: function fetchSamples() {
        var _this2 = this;
        var page = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 1;
        var params = ['search_field[0]=all', 'search_value[0]=*', 'sample=1', 'sample_size=5', 'per_page=max', "page=".concat(page)].join('&');
        return request("/api/json/search/advanced_search?".concat(params)).then(function (data) {
          // console.log(data)

          tmpResults = tmpResults.concat(data);
          if (data.length > 0) {
            _this2.fetchSamples(page + 1);
          } else {
            // console.log(tmpResults, 'XXX')
            var samples = {};
            var _iterator = indexing_page_createForOfIteratorHelper(tmpResults),
              _step;
            try {
              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                var sample = _step.value;
                var name = sample.pid.split('-')[0];
                samples[name] = samples[name] || [];
                samples[name].push(sample);
              }
            } catch (err) {
              _iterator.e(err);
            } finally {
              _iterator.f();
            }
            var _params = ["pids=".concat(tmpResults.map(function (s) {
              return s.pid;
            }).join(','))].join('&');
            var p = {
              pids: tmpResults.map(function (s) {
                return s.pid;
              })
            };
            request("/api/json/indexing/image_urls", {
              method: 'POST',
              body: p
            }).then(function (data) {
              // console.log(data)

              _this2.update({
                imageUrls: data
              });
            });
            tmpResults = [];
            _this2.update({
              samples: samples
            });
          }
        });
      }
    }, {
      key: "openResult",
      value: function openResult(source, result, event) {
        event.preventDefault();
        this.bus.emit('i.modal', {
          source: source,
          result: result
        });
      }
    }, {
      key: "resultsFor",
      value: function resultsFor(name) {
        var results = this.state['results'] || {};
        return results[name] || [];
      }
    }, {
      key: "countsFor",
      value: function countsFor(name) {
        var counts = this.state['counts'] || {};
        return counts[name];
      }
    }, {
      key: "samplesFor",
      value: function samplesFor(name) {
        var samples = this.state['samples'] || {};
        return samples[name];
      }
    }, {
      key: "countClassesFor",
      value: function countClassesFor(source) {
        var counts = this.countsFor(source.name);
        if (!counts) return 'error';
        if (counts['records'] != source.record_count) return 'warn';
        return '';
      }
    }, {
      key: "formatCounts",
      value: function formatCounts(counts) {
        if (!counts) return 'no index';
        return "records: ".concat(counts['records'], ", objects: ").concat(counts['objects']);
      }
    }, {
      key: "formatTs",
      value: function formatTs(ts) {
        var date = new Date(ts * 1000);
        return strftime_default()('%Y-%m-%d %H:%H:%S', date);
      }
    }, {
      key: "formatOa",
      value: function formatOa(value) {
        var map = {
          'Open access': 'yes',
          'Non-Open access': 'no'
        };
        return map[value] || value;
      }
    }, {
      key: "formatKind",
      value: function formatKind(value) {
        return value.split(' ')[0].toLowerCase();
      }
    }, {
      key: "loaded",
      value: function loaded() {
        return !!this.state['sources'] && !!this.state['results'] && !!this.state['counts'] && !!this.state['imageUrls'] && !!this.state['samples'];
      }
    }]);
    return exports;
  }(), indexing_page_defineProperty(indexing_page_class, "components", {
    'ir-modal': result_modal
  }), indexing_page_class),
  template: function template(_template, expressionTypes, bindingTypes, getComponent) {
    return _template('<div expr23="expr23" is="pm-loading-indicator"></div><h1 expr24="expr24"> </h1><h2 expr25="expr25"> </h2><table expr26="expr26"></table><div expr50="expr50" is="ir-modal"></div>', [{
      expressions: [{
        type: expressionTypes.ATTRIBUTE,
        name: 'class',
        evaluate: function evaluate(_scope) {
          return 'm-5';
        }
      }]
    }, {
      type: bindingTypes.TAG,
      getComponent: getComponent,
      evaluate: function evaluate(_scope) {
        return 'pm-loading-indicator';
      },
      slots: [],
      attributes: [],
      redundantAttribute: 'expr23',
      selector: '[expr23]'
    }, {
      redundantAttribute: 'expr24',
      selector: '[expr24]',
      expressions: [{
        type: expressionTypes.TEXT,
        childNodeIndex: 0,
        evaluate: function evaluate(_scope) {
          return _scope.t('pages.indexing_status');
        }
      }]
    }, {
      redundantAttribute: 'expr25',
      selector: '[expr25]',
      expressions: [{
        type: expressionTypes.TEXT,
        childNodeIndex: 0,
        evaluate: function evaluate(_scope) {
          return _scope.t('Sources');
        }
      }]
    }, {
      type: bindingTypes.IF,
      evaluate: function evaluate(_scope) {
        return _scope.loaded();
      },
      redundantAttribute: 'expr26',
      selector: '[expr26]',
      template: _template('<thead><tr><th expr27="expr27" colspan="4" class="text-center border-bottom pe-0"> </th><th expr28="expr28" colspan="1" class="text-center border-bottom pe-0"> </th><th expr29="expr29" colspan="1" class="text-center border-bottom pe-0"> </th><th expr30="expr30" colspan="1" class="text-center border-bottom pe-0"> </th></tr><tr><th expr31="expr31"> </th><th expr32="expr32"> </th><th expr33="expr33"> </th><th expr34="expr34" class="text-end pe-0"> </th><th expr35="expr35" class="ps-1"> </th><th expr36="expr36"> </th><th expr37="expr37"> </th></tr></thead><tbody><tr expr38="expr38"></tr></tbody>', [{
        redundantAttribute: 'expr27',
        selector: '[expr27]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.models.source.one'));
          }
        }]
      }, {
        redundantAttribute: 'expr28',
        selector: '[expr28]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('elasticsearch'));
          }
        }]
      }, {
        redundantAttribute: 'expr29',
        selector: '[expr29]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('indexer'));
          }
        }]
      }, {
        redundantAttribute: 'expr30',
        selector: '[expr30]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('rack_images'));
          }
        }]
      }, {
        redundantAttribute: 'expr31',
        selector: '[expr31]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.attributes.source.name'));
          }
        }]
      }, {
        redundantAttribute: 'expr32',
        selector: '[expr32]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.attributes.source.kind'));
          }
        }]
      }, {
        redundantAttribute: 'expr33',
        selector: '[expr33]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.attributes.source.open_access'));
          }
        }]
      }, {
        redundantAttribute: 'expr34',
        selector: '[expr34]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.attributes.source.record_count'));
          }
        }]
      }, {
        redundantAttribute: 'expr35',
        selector: '[expr35]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.attributes.source.counts'));
          }
        }]
      }, {
        redundantAttribute: 'expr36',
        selector: '[expr36]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.attributes.source.indexings'));
          }
        }]
      }, {
        redundantAttribute: 'expr37',
        selector: '[expr37]',
        expressions: [{
          type: expressionTypes.TEXT,
          childNodeIndex: 0,
          evaluate: function evaluate(_scope) {
            return _scope.cap(_scope.t('activerecord.attributes.source.samples'));
          }
        }]
      }, {
        type: bindingTypes.EACH,
        getKey: null,
        condition: null,
        template: _template('<td><a expr39="expr39" target="_blank"> </a></td><td expr40="expr40"> </td><td expr41="expr41"> </td><td expr42="expr42" class="text-end pe-0"> </td><td class="ps-1"><div expr43="expr43"><template expr44="expr44"></template><template expr46="expr46"></template></div></td><td class="text-nowrap"><div expr47="expr47" class="result"></div></td><td><div class="samples"><img expr49="expr49"/></div></td>', [{
          redundantAttribute: 'expr39',
          selector: '[expr39]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.source.name;
            }
          }, {
            type: expressionTypes.ATTRIBUTE,
            name: 'href',
            evaluate: function evaluate(_scope) {
              return ['/', _scope.locale(), '/sources/', _scope.source.name].join('');
            }
          }]
        }, {
          redundantAttribute: 'expr40',
          selector: '[expr40]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.formatKind(_scope.source.kind);
            }
          }]
        }, {
          redundantAttribute: 'expr41',
          selector: '[expr41]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return _scope.formatOa(_scope.source.open_access);
            }
          }]
        }, {
          redundantAttribute: 'expr42',
          selector: '[expr42]',
          expressions: [{
            type: expressionTypes.TEXT,
            childNodeIndex: 0,
            evaluate: function evaluate(_scope) {
              return [_scope.source.record_count].join('');
            }
          }]
        }, {
          redundantAttribute: 'expr43',
          selector: '[expr43]',
          expressions: [{
            type: expressionTypes.ATTRIBUTE,
            name: 'class',
            evaluate: function evaluate(_scope) {
              return ['elastic-counts text-nowrap ', _scope.countClassesFor(_scope.source)].join('');
            }
          }]
        }, {
          type: bindingTypes.IF,
          evaluate: function evaluate(_scope) {
            return _scope.countsFor(_scope.source.name);
          },
          redundantAttribute: 'expr44',
          selector: '[expr44]',
          template: _template('\n              records:\n              <a expr45="expr45" target="_blank"> </a> ', [{
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 2,
              evaluate: function evaluate(_scope) {
                return [',\n              objects: ', _scope.countsFor(_scope.source.name)['objects']].join('');
              }
            }]
          }, {
            redundantAttribute: 'expr45',
            selector: '[expr45]',
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 0,
              evaluate: function evaluate(_scope) {
                return _scope.countsFor(_scope.source.name)['records'];
              }
            }, {
              type: expressionTypes.ATTRIBUTE,
              name: 'href',
              evaluate: function evaluate(_scope) {
                return ['/', _scope.locale(), '/searches/advanced?indices[', _scope.source.name, ']=true&search_field[]=all&search_value[]=*'].join('');
              }
            }]
          }])
        }, {
          type: bindingTypes.IF,
          evaluate: function evaluate(_scope) {
            return !_scope.countsFor(_scope.source.name);
          },
          redundantAttribute: 'expr46',
          selector: '[expr46]',
          template: _template('\n              no index\n            ', [])
        }, {
          type: bindingTypes.EACH,
          getKey: null,
          condition: null,
          template: _template('<a expr48="expr48" href="#"> </a>', [{
            redundantAttribute: 'expr48',
            selector: '[expr48]',
            expressions: [{
              type: expressionTypes.TEXT,
              childNodeIndex: 0,
              evaluate: function evaluate(_scope) {
                return [_scope.formatTs(_scope.result.started_at)].join('');
              }
            }, {
              type: expressionTypes.EVENT,
              name: 'onclick',
              evaluate: function evaluate(_scope) {
                return function (event) {
                  return _scope.openResult(_scope.source, _scope.result, event);
                };
              }
            }]
          }]),
          redundantAttribute: 'expr47',
          selector: '[expr47]',
          itemName: 'result',
          indexName: null,
          evaluate: function evaluate(_scope) {
            return _scope.resultsFor(_scope.source.name);
          }
        }, {
          type: bindingTypes.EACH,
          getKey: null,
          condition: null,
          template: _template(null, [{
            expressions: [{
              type: expressionTypes.ATTRIBUTE,
              name: 'src',
              evaluate: function evaluate(_scope) {
                return _scope.state.imageUrls[_scope.sample.pid];
              }
            }]
          }]),
          redundantAttribute: 'expr49',
          selector: '[expr49]',
          itemName: 'sample',
          indexName: null,
          evaluate: function evaluate(_scope) {
            return _scope.samplesFor(_scope.source.name);
          }
        }]),
        redundantAttribute: 'expr38',
        selector: '[expr38]',
        itemName: 'source',
        indexName: null,
        evaluate: function evaluate(_scope) {
          return _scope.state.sources;
        }
      }])
    }, {
      type: bindingTypes.TAG,
      getComponent: getComponent,
      evaluate: function evaluate(_scope) {
        return 'ir-modal';
      },
      slots: [],
      attributes: [],
      redundantAttribute: 'expr50',
      selector: '[expr50]'
    }]);
  },
  name: 'indexing-page'
});
;// CONCATENATED MODULE: ./app/assets/app.js







// import Confirm from './js/components/confirm.riot'









riotPlugins.setup(riot_namespaceObject)
install(riotPlugins.i18n)
install(BusRiotPlugin)

// riot.register('pm-confirm', Confirm)
register('pm-live-search', live_search)
register('pm-loading-indicator', loading_indicator)
register('pm-modal', modal)
register('pm-ol-modal', ol_modal)
register('pm-size-indicator', size_indicator)
register('pm-wd-modal', wd_modal)
register('pm-wikidata-widget', wikidata_widget)
register('pm-indexing-page', indexing_page)

lib_i18n().then((data) => {
  mount('[is]')
  console.log('components mounted')

  const olClasses = [
    '.title-field',
    '.description-field',
    '.keyword-field',
    '.keywords-field',
    '.keyword_artigo-field',
    'div.image'
  ]
  setup(olClasses.join(', '))
  console.log('offensive language component initialized')
})

})();

/******/ })()
;