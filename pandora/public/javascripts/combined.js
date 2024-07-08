/*! (c) Andrea Giammarchi - ISC */
var self = this || {};
try {
  !function (t, n) {
    if (new t("q=%2B").get("q") !== n || new t({
      q: n
    }).get("q") !== n || new t([["q", n]]).get("q") !== n || "q=%0A" !== new t("q=\n").toString() || "q=+%26" !== new t({
      q: " &"
    }).toString()) throw t;
    self.URLSearchParams = t;
  }(URLSearchParams, "+");
} catch (t) {
  !function (t, a, o) {
    "use strict";

    var u = t.create,
      h = t.defineProperty,
      n = /[!'\(\)~]|%20|%00/g,
      e = /\+/g,
      r = {
        "!": "%21",
        "'": "%27",
        "(": "%28",
        ")": "%29",
        "~": "%7E",
        "%20": "+",
        "%00": "\0"
      },
      i = {
        append: function (t, n) {
          l(this._ungap, t, n);
        },
        delete: function (t) {
          delete this._ungap[t];
        },
        get: function (t) {
          return this.has(t) ? this._ungap[t][0] : null;
        },
        getAll: function (t) {
          return this.has(t) ? this._ungap[t].slice(0) : [];
        },
        has: function (t) {
          return t in this._ungap;
        },
        set: function (t, n) {
          this._ungap[t] = [a(n)];
        },
        forEach: function (n, e) {
          var r = this;
          for (var i in r._ungap) r._ungap[i].forEach(t, i);
          function t(t) {
            n.call(e, t, a(i), r);
          }
        },
        toJSON: function () {
          return {};
        },
        toString: function () {
          var t = [];
          for (var n in this._ungap) for (var e = g(n), r = 0, i = this._ungap[n]; r < i.length; r++) t.push(e + "=" + g(i[r]));
          return t.join("&");
        }
      };
    for (var s in i) h(c.prototype, s, {
      configurable: !0,
      writable: !0,
      value: i[s]
    });
    function c(t) {
      var n = u(null);
      switch (h(this, "_ungap", {
        value: n
      }), !0) {
        case !t:
          break;
        case "string" == typeof t:
          "?" === t.charAt(0) && (t = t.slice(1));
          for (var e = t.split("&"), r = 0, i = e.length; r < i; r++) {
            var a = (s = e[r]).indexOf("=");
            -1 < a ? l(n, p(s.slice(0, a)), p(s.slice(a + 1))) : s.length && l(n, p(s), "");
          }
          break;
        case o(t):
          for (r = 0, i = t.length; r < i; r++) {
            var s;
            l(n, (s = t[r])[0], s[1]);
          }
          break;
        case "forEach" in t:
          t.forEach(f, n);
          break;
        default:
          for (var c in t) l(n, c, t[c]);
      }
    }
    function f(t, n) {
      l(this, n, t);
    }
    function l(t, n, e) {
      var r = o(e) ? e.join(",") : e;
      n in t ? t[n].push(r) : t[n] = [r];
    }
    function p(t) {
      return decodeURIComponent(t.replace(e, " "));
    }
    function g(t) {
      return encodeURIComponent(t).replace(n, v);
    }
    function v(t) {
      return r[t];
    }
    self.URLSearchParams = c;
  }(Object, String, Array.isArray);
}
!function (l) {
  var r = !1;
  try {
    r = !!Symbol.iterator;
  } catch (t) {}
  function t(t, n) {
    var e = [];
    return t.forEach(n, e), r ? e[Symbol.iterator]() : {
      next: function () {
        var t = e.shift();
        return {
          done: void 0 === t,
          value: t
        };
      }
    };
  }
  "forEach" in l || (l.forEach = function (e, r) {
    var i = this,
      t = Object.create(null);
    this.toString().replace(/=[\s\S]*?(?:&|$)/g, "=").split("=").forEach(function (n) {
      !n.length || n in t || (t[n] = i.getAll(n)).forEach(function (t) {
        e.call(r, t, n, i);
      });
    });
  }), "keys" in l || (l.keys = function () {
    return t(this, function (t, n) {
      this.push(n);
    });
  }), "values" in l || (l.values = function () {
    return t(this, function (t, n) {
      this.push(t);
    });
  }), "entries" in l || (l.entries = function () {
    return t(this, function (t, n) {
      this.push([n, t]);
    });
  }), !r || Symbol.iterator in l || (l[Symbol.iterator] = l.entries), "sort" in l || (l.sort = function () {
    for (var t, n, e, r = this.entries(), i = r.next(), a = i.done, s = [], c = Object.create(null); !a;) n = (e = i.value)[0], s.push(n), n in c || (c[n] = []), c[n].push(e[1]), a = (i = r.next()).done;
    for (s.sort(), t = 0; t < s.length; t++) this.delete(s[t]);
    for (t = 0; t < s.length; t++) n = s[t], this.append(n, c[n].shift());
  }), function (c) {
    var o = c.defineProperty,
      u = c.getOwnPropertyDescriptor,
      h = function (t) {
        var n = t.append;
        t.append = l.append, URLSearchParams.call(t, t._usp.search.slice(1)), t.append = n;
      },
      f = function (t, n) {
        if (!(t instanceof n)) throw new TypeError("'searchParams' accessed on an object that does not implement interface " + n.name);
      },
      t = function (n) {
        var e,
          r,
          t = n.prototype,
          i = u(t, "searchParams"),
          a = u(t, "href"),
          s = u(t, "search");
        !i && s && s.set && (r = function (e) {
          function r(t, n) {
            l.append.call(this, t, n), t = this.toString(), e.set.call(this._usp, t ? "?" + t : "");
          }
          function i(t) {
            l.delete.call(this, t), t = this.toString(), e.set.call(this._usp, t ? "?" + t : "");
          }
          function a(t, n) {
            l.set.call(this, t, n), t = this.toString(), e.set.call(this._usp, t ? "?" + t : "");
          }
          return function (t, n) {
            return t.append = r, t.delete = i, t.set = a, o(t, "_usp", {
              configurable: !0,
              writable: !0,
              value: n
            });
          };
        }(s), e = function (t, n) {
          return o(t, "_searchParams", {
            configurable: !0,
            writable: !0,
            value: r(n, t)
          }), n;
        }, c.defineProperties(t, {
          href: {
            get: function () {
              return a.get.call(this);
            },
            set: function (t) {
              var n = this._searchParams;
              a.set.call(this, t), n && h(n);
            }
          },
          search: {
            get: function () {
              return s.get.call(this);
            },
            set: function (t) {
              var n = this._searchParams;
              s.set.call(this, t), n && h(n);
            }
          },
          searchParams: {
            get: function () {
              return f(this, n), this._searchParams || e(this, new URLSearchParams(this.search.slice(1)));
            },
            set: function (t) {
              f(this, n), e(this, t);
            }
          }
        }));
      };
    try {
      t(HTMLAnchorElement), /^function|object$/.test(typeof URL) && URL.prototype && t(URL);
    } catch (t) {}
  }(Object);
}(self.URLSearchParams.prototype, Object);
/*  Prototype JavaScript framework, version 1.7.3
 *  (c) 2005-2010 Sam Stephenson
 *
 *  Prototype is freely distributable under the terms of an MIT-style license.
 *  For details, see the Prototype web site: http://www.prototypejs.org/
 *
 *--------------------------------------------------------------------------*/

var Prototype = {
  Version: '1.7.3',
  Browser: function () {
    var ua = navigator.userAgent;
    var isOpera = Object.prototype.toString.call(window.opera) == '[object Opera]';
    return {
      IE: !!window.attachEvent && !isOpera,
      Opera: isOpera,
      WebKit: ua.indexOf('AppleWebKit/') > -1,
      Gecko: ua.indexOf('Gecko') > -1 && ua.indexOf('KHTML') === -1,
      MobileSafari: /Apple.*Mobile/.test(ua)
    };
  }(),
  BrowserFeatures: {
    XPath: !!document.evaluate,
    SelectorsAPI: !!document.querySelector,
    ElementExtensions: function () {
      var constructor = window.Element || window.HTMLElement;
      return !!(constructor && constructor.prototype);
    }(),
    SpecificElementExtensions: function () {
      if (typeof window.HTMLDivElement !== 'undefined') return true;
      var div = document.createElement('div'),
        form = document.createElement('form'),
        isSupported = false;
      if (div['__proto__'] && div['__proto__'] !== form['__proto__']) {
        isSupported = true;
      }
      div = form = null;
      return isSupported;
    }()
  },
  ScriptFragment: '<script[^>]*>([\\S\\s]*?)<\/script\\s*>',
  JSONFilter: /^\/\*-secure-([\s\S]*)\*\/\s*$/,
  emptyFunction: function () {},
  K: function (x) {
    return x;
  }
};
if (Prototype.Browser.MobileSafari) Prototype.BrowserFeatures.SpecificElementExtensions = false;
/* Based on Alex Arnell's inheritance implementation. */

var Class = function () {
  var IS_DONTENUM_BUGGY = function () {
    for (var p in {
      toString: 1
    }) {
      if (p === 'toString') return false;
    }
    return true;
  }();
  function subclass() {}
  ;
  function create() {
    var parent = null,
      properties = $A(arguments);
    if (Object.isFunction(properties[0])) parent = properties.shift();
    function klass() {
      this.initialize.apply(this, arguments);
    }
    Object.extend(klass, Class.Methods);
    klass.superclass = parent;
    klass.subclasses = [];
    if (parent) {
      subclass.prototype = parent.prototype;
      klass.prototype = new subclass();
      parent.subclasses.push(klass);
    }
    for (var i = 0, length = properties.length; i < length; i++) klass.addMethods(properties[i]);
    if (!klass.prototype.initialize) klass.prototype.initialize = Prototype.emptyFunction;
    klass.prototype.constructor = klass;
    return klass;
  }
  function addMethods(source) {
    var ancestor = this.superclass && this.superclass.prototype,
      properties = Object.keys(source);
    if (IS_DONTENUM_BUGGY) {
      if (source.toString != Object.prototype.toString) properties.push("toString");
      if (source.valueOf != Object.prototype.valueOf) properties.push("valueOf");
    }
    for (var i = 0, length = properties.length; i < length; i++) {
      var property = properties[i],
        value = source[property];
      if (ancestor && Object.isFunction(value) && value.argumentNames()[0] == "$super") {
        var method = value;
        value = function (m) {
          return function () {
            return ancestor[m].apply(this, arguments);
          };
        }(property).wrap(method);
        value.valueOf = function (method) {
          return function () {
            return method.valueOf.call(method);
          };
        }(method);
        value.toString = function (method) {
          return function () {
            return method.toString.call(method);
          };
        }(method);
      }
      this.prototype[property] = value;
    }
    return this;
  }
  return {
    create: create,
    Methods: {
      addMethods: addMethods
    }
  };
}();
(function () {
  var _toString = Object.prototype.toString,
    _hasOwnProperty = Object.prototype.hasOwnProperty,
    NULL_TYPE = 'Null',
    UNDEFINED_TYPE = 'Undefined',
    BOOLEAN_TYPE = 'Boolean',
    NUMBER_TYPE = 'Number',
    STRING_TYPE = 'String',
    OBJECT_TYPE = 'Object',
    FUNCTION_CLASS = '[object Function]',
    BOOLEAN_CLASS = '[object Boolean]',
    NUMBER_CLASS = '[object Number]',
    STRING_CLASS = '[object String]',
    ARRAY_CLASS = '[object Array]',
    DATE_CLASS = '[object Date]',
    NATIVE_JSON_STRINGIFY_SUPPORT = window.JSON && typeof JSON.stringify === 'function' && JSON.stringify(0) === '0' && typeof JSON.stringify(Prototype.K) === 'undefined';
  var DONT_ENUMS = ['toString', 'toLocaleString', 'valueOf', 'hasOwnProperty', 'isPrototypeOf', 'propertyIsEnumerable', 'constructor'];
  var IS_DONTENUM_BUGGY = function () {
    for (var p in {
      toString: 1
    }) {
      if (p === 'toString') return false;
    }
    return true;
  }();
  function Type(o) {
    switch (o) {
      case null:
        return NULL_TYPE;
      case void 0:
        return UNDEFINED_TYPE;
    }
    var type = typeof o;
    switch (type) {
      case 'boolean':
        return BOOLEAN_TYPE;
      case 'number':
        return NUMBER_TYPE;
      case 'string':
        return STRING_TYPE;
    }
    return OBJECT_TYPE;
  }
  function extend(destination, source) {
    for (var property in source) destination[property] = source[property];
    return destination;
  }
  function inspect(object) {
    try {
      if (isUndefined(object)) return 'undefined';
      if (object === null) return 'null';
      return object.inspect ? object.inspect() : String(object);
    } catch (e) {
      if (e instanceof RangeError) return '...';
      throw e;
    }
  }
  function toJSON(value) {
    return Str('', {
      '': value
    }, []);
  }
  function Str(key, holder, stack) {
    var value = holder[key];
    if (Type(value) === OBJECT_TYPE && typeof value.toJSON === 'function') {
      value = value.toJSON(key);
    }
    var _class = _toString.call(value);
    switch (_class) {
      case NUMBER_CLASS:
      case BOOLEAN_CLASS:
      case STRING_CLASS:
        value = value.valueOf();
    }
    switch (value) {
      case null:
        return 'null';
      case true:
        return 'true';
      case false:
        return 'false';
    }
    var type = typeof value;
    switch (type) {
      case 'string':
        return value.inspect(true);
      case 'number':
        return isFinite(value) ? String(value) : 'null';
      case 'object':
        for (var i = 0, length = stack.length; i < length; i++) {
          if (stack[i] === value) {
            throw new TypeError("Cyclic reference to '" + value + "' in object");
          }
        }
        stack.push(value);
        var partial = [];
        if (_class === ARRAY_CLASS) {
          for (var i = 0, length = value.length; i < length; i++) {
            var str = Str(i, value, stack);
            partial.push(typeof str === 'undefined' ? 'null' : str);
          }
          partial = '[' + partial.join(',') + ']';
        } else {
          var keys = Object.keys(value);
          for (var i = 0, length = keys.length; i < length; i++) {
            var key = keys[i],
              str = Str(key, value, stack);
            if (typeof str !== "undefined") {
              partial.push(key.inspect(true) + ':' + str);
            }
          }
          partial = '{' + partial.join(',') + '}';
        }
        stack.pop();
        return partial;
    }
  }
  function stringify(object) {
    return JSON.stringify(object);
  }
  function toQueryString(object) {
    return $H(object).toQueryString();
  }
  function toHTML(object) {
    return object && object.toHTML ? object.toHTML() : String.interpret(object);
  }
  function keys(object) {
    if (Type(object) !== OBJECT_TYPE) {
      throw new TypeError();
    }
    var results = [];
    for (var property in object) {
      if (_hasOwnProperty.call(object, property)) results.push(property);
    }
    if (IS_DONTENUM_BUGGY) {
      for (var i = 0; property = DONT_ENUMS[i]; i++) {
        if (_hasOwnProperty.call(object, property)) results.push(property);
      }
    }
    return results;
  }
  function values(object) {
    var results = [];
    for (var property in object) results.push(object[property]);
    return results;
  }
  function clone(object) {
    return extend({}, object);
  }
  function isElement(object) {
    return !!(object && object.nodeType == 1);
  }
  function isArray(object) {
    return _toString.call(object) === ARRAY_CLASS;
  }
  var hasNativeIsArray = typeof Array.isArray == 'function' && Array.isArray([]) && !Array.isArray({});
  if (hasNativeIsArray) {
    isArray = Array.isArray;
  }
  function isHash(object) {
    return object instanceof Hash;
  }
  function isFunction(object) {
    return _toString.call(object) === FUNCTION_CLASS;
  }
  function isString(object) {
    return _toString.call(object) === STRING_CLASS;
  }
  function isNumber(object) {
    return _toString.call(object) === NUMBER_CLASS;
  }
  function isDate(object) {
    return _toString.call(object) === DATE_CLASS;
  }
  function isUndefined(object) {
    return typeof object === "undefined";
  }
  extend(Object, {
    extend: extend,
    inspect: inspect,
    toJSON: NATIVE_JSON_STRINGIFY_SUPPORT ? stringify : toJSON,
    toQueryString: toQueryString,
    toHTML: toHTML,
    keys: Object.keys || keys,
    values: values,
    clone: clone,
    isElement: isElement,
    isArray: isArray,
    isHash: isHash,
    isFunction: isFunction,
    isString: isString,
    isNumber: isNumber,
    isDate: isDate,
    isUndefined: isUndefined
  });
})();
Object.extend(Function.prototype, function () {
  var slice = Array.prototype.slice;
  function update(array, args) {
    var arrayLength = array.length,
      length = args.length;
    while (length--) array[arrayLength + length] = args[length];
    return array;
  }
  function merge(array, args) {
    array = slice.call(array, 0);
    return update(array, args);
  }
  function argumentNames() {
    var names = this.toString().match(/^[\s\(]*function[^(]*\(([^)]*)\)/)[1].replace(/\/\/.*?[\r\n]|\/\*(?:.|[\r\n])*?\*\//g, '').replace(/\s+/g, '').split(',');
    return names.length == 1 && !names[0] ? [] : names;
  }
  function bind(context) {
    if (arguments.length < 2 && Object.isUndefined(arguments[0])) return this;
    if (!Object.isFunction(this)) throw new TypeError("The object is not callable.");
    var nop = function () {};
    var __method = this,
      args = slice.call(arguments, 1);
    var bound = function () {
      var a = merge(args, arguments);
      var c = this instanceof bound ? this : context;
      return __method.apply(c, a);
    };
    nop.prototype = this.prototype;
    bound.prototype = new nop();
    return bound;
  }
  function bindAsEventListener(context) {
    var __method = this,
      args = slice.call(arguments, 1);
    return function (event) {
      var a = update([event || window.event], args);
      return __method.apply(context, a);
    };
  }
  function curry() {
    if (!arguments.length) return this;
    var __method = this,
      args = slice.call(arguments, 0);
    return function () {
      var a = merge(args, arguments);
      return __method.apply(this, a);
    };
  }
  function delay(timeout) {
    var __method = this,
      args = slice.call(arguments, 1);
    timeout = timeout * 1000;
    return window.setTimeout(function () {
      return __method.apply(__method, args);
    }, timeout);
  }
  function defer() {
    var args = update([0.01], arguments);
    return this.delay.apply(this, args);
  }
  function wrap(wrapper) {
    var __method = this;
    return function () {
      var a = update([__method.bind(this)], arguments);
      return wrapper.apply(this, a);
    };
  }
  function methodize() {
    if (this._methodized) return this._methodized;
    var __method = this;
    return this._methodized = function () {
      var a = update([this], arguments);
      return __method.apply(null, a);
    };
  }
  var extensions = {
    argumentNames: argumentNames,
    bindAsEventListener: bindAsEventListener,
    curry: curry,
    delay: delay,
    defer: defer,
    wrap: wrap,
    methodize: methodize
  };
  if (!Function.prototype.bind) extensions.bind = bind;
  return extensions;
}());
(function (proto) {
  function toISOString() {
    return this.getUTCFullYear() + '-' + (this.getUTCMonth() + 1).toPaddedString(2) + '-' + this.getUTCDate().toPaddedString(2) + 'T' + this.getUTCHours().toPaddedString(2) + ':' + this.getUTCMinutes().toPaddedString(2) + ':' + this.getUTCSeconds().toPaddedString(2) + 'Z';
  }
  function toJSON() {
    return this.toISOString();
  }
  if (!proto.toISOString) proto.toISOString = toISOString;
  if (!proto.toJSON) proto.toJSON = toJSON;
})(Date.prototype);
RegExp.prototype.match = RegExp.prototype.test;
RegExp.escape = function (str) {
  return String(str).replace(/([.*+?^=!:${}()|[\]\/\\])/g, '\\$1');
};
var PeriodicalExecuter = Class.create({
  initialize: function (callback, frequency) {
    this.callback = callback;
    this.frequency = frequency;
    this.currentlyExecuting = false;
    this.registerCallback();
  },
  registerCallback: function () {
    this.timer = setInterval(this.onTimerEvent.bind(this), this.frequency * 1000);
  },
  execute: function () {
    this.callback(this);
  },
  stop: function () {
    if (!this.timer) return;
    clearInterval(this.timer);
    this.timer = null;
  },
  onTimerEvent: function () {
    if (!this.currentlyExecuting) {
      try {
        this.currentlyExecuting = true;
        this.execute();
        this.currentlyExecuting = false;
      } catch (e) {
        this.currentlyExecuting = false;
        throw e;
      }
    }
  }
});
Object.extend(String, {
  interpret: function (value) {
    return value == null ? '' : String(value);
  },
  specialChar: {
    '\b': '\\b',
    '\t': '\\t',
    '\n': '\\n',
    '\f': '\\f',
    '\r': '\\r',
    '\\': '\\\\'
  }
});
Object.extend(String.prototype, function () {
  var NATIVE_JSON_PARSE_SUPPORT = window.JSON && typeof JSON.parse === 'function' && JSON.parse('{"test": true}').test;
  function prepareReplacement(replacement) {
    if (Object.isFunction(replacement)) return replacement;
    var template = new Template(replacement);
    return function (match) {
      return template.evaluate(match);
    };
  }
  function isNonEmptyRegExp(regexp) {
    return regexp.source && regexp.source !== '(?:)';
  }
  function gsub(pattern, replacement) {
    var result = '',
      source = this,
      match;
    replacement = prepareReplacement(replacement);
    if (Object.isString(pattern)) pattern = RegExp.escape(pattern);
    if (!(pattern.length || isNonEmptyRegExp(pattern))) {
      replacement = replacement('');
      return replacement + source.split('').join(replacement) + replacement;
    }
    while (source.length > 0) {
      match = source.match(pattern);
      if (match && match[0].length > 0) {
        result += source.slice(0, match.index);
        result += String.interpret(replacement(match));
        source = source.slice(match.index + match[0].length);
      } else {
        result += source, source = '';
      }
    }
    return result;
  }
  function sub(pattern, replacement, count) {
    replacement = prepareReplacement(replacement);
    count = Object.isUndefined(count) ? 1 : count;
    return this.gsub(pattern, function (match) {
      if (--count < 0) return match[0];
      return replacement(match);
    });
  }
  function scan(pattern, iterator) {
    this.gsub(pattern, iterator);
    return String(this);
  }
  function truncate(length, truncation) {
    length = length || 30;
    truncation = Object.isUndefined(truncation) ? '...' : truncation;
    return this.length > length ? this.slice(0, length - truncation.length) + truncation : String(this);
  }
  function strip() {
    return this.replace(/^\s+/, '').replace(/\s+$/, '');
  }
  function stripTags() {
    return this.replace(/<\w+(\s+("[^"]*"|'[^']*'|[^>])+)?(\/)?>|<\/\w+>/gi, '');
  }
  function stripScripts() {
    return this.replace(new RegExp(Prototype.ScriptFragment, 'img'), '');
  }
  function extractScripts() {
    var matchAll = new RegExp(Prototype.ScriptFragment, 'img'),
      matchOne = new RegExp(Prototype.ScriptFragment, 'im');
    return (this.match(matchAll) || []).map(function (scriptTag) {
      return (scriptTag.match(matchOne) || ['', ''])[1];
    });
  }
  function evalScripts() {
    return this.extractScripts().map(function (script) {
      return eval(script);
    });
  }
  function escapeHTML() {
    return this.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }
  function unescapeHTML() {
    return this.stripTags().replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
  }
  function toQueryParams(separator) {
    var match = this.strip().match(/([^?#]*)(#.*)?$/);
    if (!match) return {};
    return match[1].split(separator || '&').inject({}, function (hash, pair) {
      if ((pair = pair.split('='))[0]) {
        var key = decodeURIComponent(pair.shift()),
          value = pair.length > 1 ? pair.join('=') : pair[0];
        if (value != undefined) {
          value = value.gsub('+', ' ');
          value = decodeURIComponent(value);
        }
        if (key in hash) {
          if (!Object.isArray(hash[key])) hash[key] = [hash[key]];
          hash[key].push(value);
        } else hash[key] = value;
      }
      return hash;
    });
  }
  function toArray() {
    return this.split('');
  }
  function succ() {
    return this.slice(0, this.length - 1) + String.fromCharCode(this.charCodeAt(this.length - 1) + 1);
  }
  function times(count) {
    return count < 1 ? '' : new Array(count + 1).join(this);
  }
  function camelize() {
    return this.replace(/-+(.)?/g, function (match, chr) {
      return chr ? chr.toUpperCase() : '';
    });
  }
  function capitalize() {
    return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase();
  }
  function underscore() {
    return this.replace(/::/g, '/').replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2').replace(/([a-z\d])([A-Z])/g, '$1_$2').replace(/-/g, '_').toLowerCase();
  }
  function dasherize() {
    return this.replace(/_/g, '-');
  }
  function inspect(useDoubleQuotes) {
    var escapedString = this.replace(/[\x00-\x1f\\]/g, function (character) {
      if (character in String.specialChar) {
        return String.specialChar[character];
      }
      return '\\u00' + character.charCodeAt().toPaddedString(2, 16);
    });
    if (useDoubleQuotes) return '"' + escapedString.replace(/"/g, '\\"') + '"';
    return "'" + escapedString.replace(/'/g, '\\\'') + "'";
  }
  function unfilterJSON(filter) {
    return this.replace(filter || Prototype.JSONFilter, '$1');
  }
  function isJSON() {
    var str = this;
    if (str.blank()) return false;
    str = str.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@');
    str = str.replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']');
    str = str.replace(/(?:^|:|,)(?:\s*\[)+/g, '');
    return /^[\],:{}\s]*$/.test(str);
  }
  function evalJSON(sanitize) {
    var json = this.unfilterJSON(),
      cx = /[\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff\u0000]/g;
    if (cx.test(json)) {
      json = json.replace(cx, function (a) {
        return '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
      });
    }
    try {
      if (!sanitize || json.isJSON()) return eval('(' + json + ')');
    } catch (e) {}
    throw new SyntaxError('Badly formed JSON string: ' + this.inspect());
  }
  function parseJSON() {
    var json = this.unfilterJSON();
    return JSON.parse(json);
  }
  function include(pattern) {
    return this.indexOf(pattern) > -1;
  }
  function startsWith(pattern, position) {
    position = Object.isNumber(position) ? position : 0;
    return this.lastIndexOf(pattern, position) === position;
  }
  function endsWith(pattern, position) {
    pattern = String(pattern);
    position = Object.isNumber(position) ? position : this.length;
    if (position < 0) position = 0;
    if (position > this.length) position = this.length;
    var d = position - pattern.length;
    return d >= 0 && this.indexOf(pattern, d) === d;
  }
  function empty() {
    return this == '';
  }
  function blank() {
    return /^\s*$/.test(this);
  }
  function interpolate(object, pattern) {
    return new Template(this, pattern).evaluate(object);
  }
  return {
    gsub: gsub,
    sub: sub,
    scan: scan,
    truncate: truncate,
    strip: String.prototype.trim || strip,
    stripTags: stripTags,
    stripScripts: stripScripts,
    extractScripts: extractScripts,
    evalScripts: evalScripts,
    escapeHTML: escapeHTML,
    unescapeHTML: unescapeHTML,
    toQueryParams: toQueryParams,
    parseQuery: toQueryParams,
    toArray: toArray,
    succ: succ,
    times: times,
    camelize: camelize,
    capitalize: capitalize,
    underscore: underscore,
    dasherize: dasherize,
    inspect: inspect,
    unfilterJSON: unfilterJSON,
    isJSON: isJSON,
    evalJSON: NATIVE_JSON_PARSE_SUPPORT ? parseJSON : evalJSON,
    include: include,
    startsWith: String.prototype.startsWith || startsWith,
    endsWith: String.prototype.endsWith || endsWith,
    empty: empty,
    blank: blank,
    interpolate: interpolate
  };
}());
var Template = Class.create({
  initialize: function (template, pattern) {
    this.template = template.toString();
    this.pattern = pattern || Template.Pattern;
  },
  evaluate: function (object) {
    if (object && Object.isFunction(object.toTemplateReplacements)) object = object.toTemplateReplacements();
    return this.template.gsub(this.pattern, function (match) {
      if (object == null) return match[1] + '';
      var before = match[1] || '';
      if (before == '\\') return match[2];
      var ctx = object,
        expr = match[3],
        pattern = /^([^.[]+|\[((?:.*?[^\\])?)\])(\.|\[|$)/;
      match = pattern.exec(expr);
      if (match == null) return before;
      while (match != null) {
        var comp = match[1].startsWith('[') ? match[2].replace(/\\\\]/g, ']') : match[1];
        ctx = ctx[comp];
        if (null == ctx || '' == match[3]) break;
        expr = expr.substring('[' == match[3] ? match[1].length : match[0].length);
        match = pattern.exec(expr);
      }
      return before + String.interpret(ctx);
    });
  }
});
Template.Pattern = /(^|.|\r|\n)(#\{(.*?)\})/;
var $break = {};
var Enumerable = function () {
  function each(iterator, context) {
    try {
      this._each(iterator, context);
    } catch (e) {
      if (e != $break) throw e;
    }
    return this;
  }
  function eachSlice(number, iterator, context) {
    var index = -number,
      slices = [],
      array = this.toArray();
    if (number < 1) return array;
    while ((index += number) < array.length) slices.push(array.slice(index, index + number));
    return slices.collect(iterator, context);
  }
  function all(iterator, context) {
    iterator = iterator || Prototype.K;
    var result = true;
    this.each(function (value, index) {
      result = result && !!iterator.call(context, value, index, this);
      if (!result) throw $break;
    }, this);
    return result;
  }
  function any(iterator, context) {
    iterator = iterator || Prototype.K;
    var result = false;
    this.each(function (value, index) {
      if (result = !!iterator.call(context, value, index, this)) throw $break;
    }, this);
    return result;
  }
  function collect(iterator, context) {
    iterator = iterator || Prototype.K;
    var results = [];
    this.each(function (value, index) {
      results.push(iterator.call(context, value, index, this));
    }, this);
    return results;
  }
  function detect(iterator, context) {
    var result;
    this.each(function (value, index) {
      if (iterator.call(context, value, index, this)) {
        result = value;
        throw $break;
      }
    }, this);
    return result;
  }
  function findAll(iterator, context) {
    var results = [];
    this.each(function (value, index) {
      if (iterator.call(context, value, index, this)) results.push(value);
    }, this);
    return results;
  }
  function grep(filter, iterator, context) {
    iterator = iterator || Prototype.K;
    var results = [];
    if (Object.isString(filter)) filter = new RegExp(RegExp.escape(filter));
    this.each(function (value, index) {
      if (filter.match(value)) results.push(iterator.call(context, value, index, this));
    }, this);
    return results;
  }
  function include(object) {
    if (Object.isFunction(this.indexOf) && this.indexOf(object) != -1) return true;
    var found = false;
    this.each(function (value) {
      if (value == object) {
        found = true;
        throw $break;
      }
    });
    return found;
  }
  function inGroupsOf(number, fillWith) {
    fillWith = Object.isUndefined(fillWith) ? null : fillWith;
    return this.eachSlice(number, function (slice) {
      while (slice.length < number) slice.push(fillWith);
      return slice;
    });
  }
  function inject(memo, iterator, context) {
    this.each(function (value, index) {
      memo = iterator.call(context, memo, value, index, this);
    }, this);
    return memo;
  }
  function invoke(method) {
    var args = $A(arguments).slice(1);
    return this.map(function (value) {
      return value[method].apply(value, args);
    });
  }
  function max(iterator, context) {
    iterator = iterator || Prototype.K;
    var result;
    this.each(function (value, index) {
      value = iterator.call(context, value, index, this);
      if (result == null || value >= result) result = value;
    }, this);
    return result;
  }
  function min(iterator, context) {
    iterator = iterator || Prototype.K;
    var result;
    this.each(function (value, index) {
      value = iterator.call(context, value, index, this);
      if (result == null || value < result) result = value;
    }, this);
    return result;
  }
  function partition(iterator, context) {
    iterator = iterator || Prototype.K;
    var trues = [],
      falses = [];
    this.each(function (value, index) {
      (iterator.call(context, value, index, this) ? trues : falses).push(value);
    }, this);
    return [trues, falses];
  }
  function pluck(property) {
    var results = [];
    this.each(function (value) {
      results.push(value[property]);
    });
    return results;
  }
  function reject(iterator, context) {
    var results = [];
    this.each(function (value, index) {
      if (!iterator.call(context, value, index, this)) results.push(value);
    }, this);
    return results;
  }
  function sortBy(iterator, context) {
    return this.map(function (value, index) {
      return {
        value: value,
        criteria: iterator.call(context, value, index, this)
      };
    }, this).sort(function (left, right) {
      var a = left.criteria,
        b = right.criteria;
      return a < b ? -1 : a > b ? 1 : 0;
    }).pluck('value');
  }
  function toArray() {
    return this.map();
  }
  function zip() {
    var iterator = Prototype.K,
      args = $A(arguments);
    if (Object.isFunction(args.last())) iterator = args.pop();
    var collections = [this].concat(args).map($A);
    return this.map(function (value, index) {
      return iterator(collections.pluck(index));
    });
  }
  function size() {
    return this.toArray().length;
  }
  function inspect() {
    return '#<Enumerable:' + this.toArray().inspect() + '>';
  }
  return {
    each: each,
    eachSlice: eachSlice,
    all: all,
    every: all,
    any: any,
    some: any,
    collect: collect,
    map: collect,
    detect: detect,
    findAll: findAll,
    select: findAll,
    filter: findAll,
    grep: grep,
    include: include,
    member: include,
    inGroupsOf: inGroupsOf,
    inject: inject,
    invoke: invoke,
    max: max,
    min: min,
    partition: partition,
    pluck: pluck,
    reject: reject,
    sortBy: sortBy,
    toArray: toArray,
    entries: toArray,
    zip: zip,
    size: size,
    inspect: inspect,
    find: detect
  };
}();
function $A(iterable) {
  if (!iterable) return [];
  if ('toArray' in Object(iterable)) return iterable.toArray();
  var length = iterable.length || 0,
    results = new Array(length);
  while (length--) results[length] = iterable[length];
  return results;
}
function $w(string) {
  if (!Object.isString(string)) return [];
  string = string.strip();
  return string ? string.split(/\s+/) : [];
}
Array.from = $A;
(function () {
  var arrayProto = Array.prototype,
    slice = arrayProto.slice,
    _each = arrayProto.forEach; // use native browser JS 1.6 implementation if available

  function each(iterator, context) {
    for (var i = 0, length = this.length >>> 0; i < length; i++) {
      if (i in this) iterator.call(context, this[i], i, this);
    }
  }
  if (!_each) _each = each;
  function clear() {
    this.length = 0;
    return this;
  }
  function first() {
    return this[0];
  }
  function last() {
    return this[this.length - 1];
  }
  function compact() {
    return this.select(function (value) {
      return value != null;
    });
  }
  function flatten() {
    return this.inject([], function (array, value) {
      if (Object.isArray(value)) return array.concat(value.flatten());
      array.push(value);
      return array;
    });
  }
  function without() {
    var values = slice.call(arguments, 0);
    return this.select(function (value) {
      return !values.include(value);
    });
  }
  function reverse(inline) {
    return (inline === false ? this.toArray() : this)._reverse();
  }
  function uniq(sorted) {
    return this.inject([], function (array, value, index) {
      if (0 == index || (sorted ? array.last() != value : !array.include(value))) array.push(value);
      return array;
    });
  }
  function intersect(array) {
    return this.uniq().findAll(function (item) {
      return array.indexOf(item) !== -1;
    });
  }
  function clone() {
    return slice.call(this, 0);
  }
  function size() {
    return this.length;
  }
  function inspect() {
    return '[' + this.map(Object.inspect).join(', ') + ']';
  }
  function indexOf(item, i) {
    if (this == null) throw new TypeError();
    var array = Object(this),
      length = array.length >>> 0;
    if (length === 0) return -1;
    i = Number(i);
    if (isNaN(i)) {
      i = 0;
    } else if (i !== 0 && isFinite(i)) {
      i = (i > 0 ? 1 : -1) * Math.floor(Math.abs(i));
    }
    if (i > length) return -1;
    var k = i >= 0 ? i : Math.max(length - Math.abs(i), 0);
    for (; k < length; k++) if (k in array && array[k] === item) return k;
    return -1;
  }
  function lastIndexOf(item, i) {
    if (this == null) throw new TypeError();
    var array = Object(this),
      length = array.length >>> 0;
    if (length === 0) return -1;
    if (!Object.isUndefined(i)) {
      i = Number(i);
      if (isNaN(i)) {
        i = 0;
      } else if (i !== 0 && isFinite(i)) {
        i = (i > 0 ? 1 : -1) * Math.floor(Math.abs(i));
      }
    } else {
      i = length;
    }
    var k = i >= 0 ? Math.min(i, length - 1) : length - Math.abs(i);
    for (; k >= 0; k--) if (k in array && array[k] === item) return k;
    return -1;
  }
  function concat(_) {
    var array = [],
      items = slice.call(arguments, 0),
      item,
      n = 0;
    items.unshift(this);
    for (var i = 0, length = items.length; i < length; i++) {
      item = items[i];
      if (Object.isArray(item) && !('callee' in item)) {
        for (var j = 0, arrayLength = item.length; j < arrayLength; j++) {
          if (j in item) array[n] = item[j];
          n++;
        }
      } else {
        array[n++] = item;
      }
    }
    array.length = n;
    return array;
  }
  function wrapNative(method) {
    return function () {
      if (arguments.length === 0) {
        return method.call(this, Prototype.K);
      } else if (arguments[0] === undefined) {
        var args = slice.call(arguments, 1);
        args.unshift(Prototype.K);
        return method.apply(this, args);
      } else {
        return method.apply(this, arguments);
      }
    };
  }
  function map(iterator) {
    if (this == null) throw new TypeError();
    iterator = iterator || Prototype.K;
    var object = Object(this);
    var results = [],
      context = arguments[1],
      n = 0;
    for (var i = 0, length = object.length >>> 0; i < length; i++) {
      if (i in object) {
        results[n] = iterator.call(context, object[i], i, object);
      }
      n++;
    }
    results.length = n;
    return results;
  }
  if (arrayProto.map) {
    map = wrapNative(Array.prototype.map);
  }
  function filter(iterator) {
    if (this == null || !Object.isFunction(iterator)) throw new TypeError();
    var object = Object(this);
    var results = [],
      context = arguments[1],
      value;
    for (var i = 0, length = object.length >>> 0; i < length; i++) {
      if (i in object) {
        value = object[i];
        if (iterator.call(context, value, i, object)) {
          results.push(value);
        }
      }
    }
    return results;
  }
  if (arrayProto.filter) {
    filter = Array.prototype.filter;
  }
  function some(iterator) {
    if (this == null) throw new TypeError();
    iterator = iterator || Prototype.K;
    var context = arguments[1];
    var object = Object(this);
    for (var i = 0, length = object.length >>> 0; i < length; i++) {
      if (i in object && iterator.call(context, object[i], i, object)) {
        return true;
      }
    }
    return false;
  }
  if (arrayProto.some) {
    some = wrapNative(Array.prototype.some);
  }
  function every(iterator) {
    if (this == null) throw new TypeError();
    iterator = iterator || Prototype.K;
    var context = arguments[1];
    var object = Object(this);
    for (var i = 0, length = object.length >>> 0; i < length; i++) {
      if (i in object && !iterator.call(context, object[i], i, object)) {
        return false;
      }
    }
    return true;
  }
  if (arrayProto.every) {
    every = wrapNative(Array.prototype.every);
  }
  Object.extend(arrayProto, Enumerable);
  if (arrayProto.entries === Enumerable.entries) {
    delete arrayProto.entries;
  }
  if (!arrayProto._reverse) arrayProto._reverse = arrayProto.reverse;
  Object.extend(arrayProto, {
    _each: _each,
    map: map,
    collect: map,
    select: filter,
    filter: filter,
    findAll: filter,
    some: some,
    any: some,
    every: every,
    all: every,
    clear: clear,
    first: first,
    last: last,
    compact: compact,
    flatten: flatten,
    without: without,
    reverse: reverse,
    uniq: uniq,
    intersect: intersect,
    clone: clone,
    toArray: clone,
    size: size,
    inspect: inspect
  });
  var CONCAT_ARGUMENTS_BUGGY = function () {
    return [].concat(arguments)[0][0] !== 1;
  }(1, 2);
  if (CONCAT_ARGUMENTS_BUGGY) arrayProto.concat = concat;
  if (!arrayProto.indexOf) arrayProto.indexOf = indexOf;
  if (!arrayProto.lastIndexOf) arrayProto.lastIndexOf = lastIndexOf;
})();
function $H(object) {
  return new Hash(object);
}
;
var Hash = Class.create(Enumerable, function () {
  function initialize(object) {
    this._object = Object.isHash(object) ? object.toObject() : Object.clone(object);
  }
  function _each(iterator, context) {
    var i = 0;
    for (var key in this._object) {
      var value = this._object[key],
        pair = [key, value];
      pair.key = key;
      pair.value = value;
      iterator.call(context, pair, i);
      i++;
    }
  }
  function set(key, value) {
    return this._object[key] = value;
  }
  function get(key) {
    if (this._object[key] !== Object.prototype[key]) return this._object[key];
  }
  function unset(key) {
    var value = this._object[key];
    delete this._object[key];
    return value;
  }
  function toObject() {
    return Object.clone(this._object);
  }
  function keys() {
    return this.pluck('key');
  }
  function values() {
    return this.pluck('value');
  }
  function index(value) {
    var match = this.detect(function (pair) {
      return pair.value === value;
    });
    return match && match.key;
  }
  function merge(object) {
    return this.clone().update(object);
  }
  function update(object) {
    return new Hash(object).inject(this, function (result, pair) {
      result.set(pair.key, pair.value);
      return result;
    });
  }
  function toQueryPair(key, value) {
    if (Object.isUndefined(value)) return key;
    value = String.interpret(value);
    value = value.gsub(/(\r)?\n/, '\r\n');
    value = encodeURIComponent(value);
    value = value.gsub(/%20/, '+');
    return key + '=' + value;
  }
  function toQueryString() {
    return this.inject([], function (results, pair) {
      var key = encodeURIComponent(pair.key),
        values = pair.value;
      if (values && typeof values == 'object') {
        if (Object.isArray(values)) {
          var queryValues = [];
          for (var i = 0, len = values.length, value; i < len; i++) {
            value = values[i];
            queryValues.push(toQueryPair(key, value));
          }
          return results.concat(queryValues);
        }
      } else results.push(toQueryPair(key, values));
      return results;
    }).join('&');
  }
  function inspect() {
    return '#<Hash:{' + this.map(function (pair) {
      return pair.map(Object.inspect).join(': ');
    }).join(', ') + '}>';
  }
  function clone() {
    return new Hash(this);
  }
  return {
    initialize: initialize,
    _each: _each,
    set: set,
    get: get,
    unset: unset,
    toObject: toObject,
    toTemplateReplacements: toObject,
    keys: keys,
    values: values,
    index: index,
    merge: merge,
    update: update,
    toQueryString: toQueryString,
    inspect: inspect,
    toJSON: toObject,
    clone: clone
  };
}());
Hash.from = $H;
Object.extend(Number.prototype, function () {
  function toColorPart() {
    return this.toPaddedString(2, 16);
  }
  function succ() {
    return this + 1;
  }
  function times(iterator, context) {
    $R(0, this, true).each(iterator, context);
    return this;
  }
  function toPaddedString(length, radix) {
    var string = this.toString(radix || 10);
    return '0'.times(length - string.length) + string;
  }
  function abs() {
    return Math.abs(this);
  }
  function round() {
    return Math.round(this);
  }
  function ceil() {
    return Math.ceil(this);
  }
  function floor() {
    return Math.floor(this);
  }
  return {
    toColorPart: toColorPart,
    succ: succ,
    times: times,
    toPaddedString: toPaddedString,
    abs: abs,
    round: round,
    ceil: ceil,
    floor: floor
  };
}());
function $R(start, end, exclusive) {
  return new ObjectRange(start, end, exclusive);
}
var ObjectRange = Class.create(Enumerable, function () {
  function initialize(start, end, exclusive) {
    this.start = start;
    this.end = end;
    this.exclusive = exclusive;
  }
  function _each(iterator, context) {
    var value = this.start,
      i;
    for (i = 0; this.include(value); i++) {
      iterator.call(context, value, i);
      value = value.succ();
    }
  }
  function include(value) {
    if (value < this.start) return false;
    if (this.exclusive) return value < this.end;
    return value <= this.end;
  }
  return {
    initialize: initialize,
    _each: _each,
    include: include
  };
}());
var Abstract = {};
var Try = {
  these: function () {
    var returnValue;
    for (var i = 0, length = arguments.length; i < length; i++) {
      var lambda = arguments[i];
      try {
        returnValue = lambda();
        break;
      } catch (e) {}
    }
    return returnValue;
  }
};
var Ajax = {
  getTransport: function () {
    return Try.these(function () {
      return new XMLHttpRequest();
    }, function () {
      return new ActiveXObject('Msxml2.XMLHTTP');
    }, function () {
      return new ActiveXObject('Microsoft.XMLHTTP');
    }) || false;
  },
  activeRequestCount: 0
};
Ajax.Responders = {
  responders: [],
  _each: function (iterator, context) {
    this.responders._each(iterator, context);
  },
  register: function (responder) {
    if (!this.include(responder)) this.responders.push(responder);
  },
  unregister: function (responder) {
    this.responders = this.responders.without(responder);
  },
  dispatch: function (callback, request, transport, json) {
    this.each(function (responder) {
      if (Object.isFunction(responder[callback])) {
        try {
          responder[callback].apply(responder, [request, transport, json]);
        } catch (e) {}
      }
    });
  }
};
Object.extend(Ajax.Responders, Enumerable);
Ajax.Responders.register({
  onCreate: function () {
    Ajax.activeRequestCount++;
  },
  onComplete: function () {
    Ajax.activeRequestCount--;
  }
});
Ajax.Base = Class.create({
  initialize: function (options) {
    this.options = {
      method: 'post',
      asynchronous: true,
      contentType: 'application/x-www-form-urlencoded',
      encoding: 'UTF-8',
      parameters: '',
      evalJSON: true,
      evalJS: true
    };
    Object.extend(this.options, options || {});
    this.options.method = this.options.method.toLowerCase();
    if (Object.isHash(this.options.parameters)) this.options.parameters = this.options.parameters.toObject();
  }
});
Ajax.Request = Class.create(Ajax.Base, {
  _complete: false,
  initialize: function ($super, url, options) {
    $super(options);
    this.transport = Ajax.getTransport();
    this.request(url);
  },
  request: function (url) {
    this.url = url;
    this.method = this.options.method;
    var params = Object.isString(this.options.parameters) ? this.options.parameters : Object.toQueryString(this.options.parameters);
    if (!['get', 'post'].include(this.method)) {
      params += (params ? '&' : '') + "_method=" + this.method;
      this.method = 'post';
    }
    if (params && this.method === 'get') {
      this.url += (this.url.include('?') ? '&' : '?') + params;
    }
    this.parameters = params.toQueryParams();
    try {
      var response = new Ajax.Response(this);
      if (this.options.onCreate) this.options.onCreate(response);
      Ajax.Responders.dispatch('onCreate', this, response);
      this.transport.open(this.method.toUpperCase(), this.url, this.options.asynchronous);
      if (this.options.asynchronous) this.respondToReadyState.bind(this).defer(1);
      this.transport.onreadystatechange = this.onStateChange.bind(this);
      this.setRequestHeaders();
      this.body = this.method == 'post' ? this.options.postBody || params : null;
      this.transport.send(this.body);

      /* Force Firefox to handle ready state 4 for synchronous requests */
      if (!this.options.asynchronous && this.transport.overrideMimeType) this.onStateChange();
    } catch (e) {
      this.dispatchException(e);
    }
  },
  onStateChange: function () {
    var readyState = this.transport.readyState;
    if (readyState > 1 && !(readyState == 4 && this._complete)) this.respondToReadyState(this.transport.readyState);
  },
  setRequestHeaders: function () {
    var headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'X-Prototype-Version': Prototype.Version,
      'Accept': 'text/javascript, text/html, application/xml, text/xml, */*'
    };
    if (this.method == 'post') {
      headers['Content-type'] = this.options.contentType + (this.options.encoding ? '; charset=' + this.options.encoding : '');

      /* Force "Connection: close" for older Mozilla browsers to work
       * around a bug where XMLHttpRequest sends an incorrect
       * Content-length header. See Mozilla Bugzilla #246651.
       */
      if (this.transport.overrideMimeType && (navigator.userAgent.match(/Gecko\/(\d{4})/) || [0, 2005])[1] < 2005) headers['Connection'] = 'close';
    }
    if (typeof this.options.requestHeaders == 'object') {
      var extras = this.options.requestHeaders;
      if (Object.isFunction(extras.push)) for (var i = 0, length = extras.length; i < length; i += 2) headers[extras[i]] = extras[i + 1];else $H(extras).each(function (pair) {
        headers[pair.key] = pair.value;
      });
    }
    for (var name in headers) if (headers[name] != null) this.transport.setRequestHeader(name, headers[name]);
  },
  success: function () {
    var status = this.getStatus();
    return !status || status >= 200 && status < 300 || status == 304;
  },
  getStatus: function () {
    try {
      if (this.transport.status === 1223) return 204;
      return this.transport.status || 0;
    } catch (e) {
      return 0;
    }
  },
  respondToReadyState: function (readyState) {
    var state = Ajax.Request.Events[readyState],
      response = new Ajax.Response(this);
    if (state == 'Complete') {
      try {
        this._complete = true;
        (this.options['on' + response.status] || this.options['on' + (this.success() ? 'Success' : 'Failure')] || Prototype.emptyFunction)(response, response.headerJSON);
      } catch (e) {
        this.dispatchException(e);
      }
      var contentType = response.getHeader('Content-type');
      if (this.options.evalJS == 'force' || this.options.evalJS && this.isSameOrigin() && contentType && contentType.match(/^\s*(text|application)\/(x-)?(java|ecma)script(;.*)?\s*$/i)) this.evalResponse();
    }
    try {
      (this.options['on' + state] || Prototype.emptyFunction)(response, response.headerJSON);
      Ajax.Responders.dispatch('on' + state, this, response, response.headerJSON);
    } catch (e) {
      this.dispatchException(e);
    }
    if (state == 'Complete') {
      this.transport.onreadystatechange = Prototype.emptyFunction;
    }
  },
  isSameOrigin: function () {
    var m = this.url.match(/^\s*https?:\/\/[^\/]*/);
    return !m || m[0] == '#{protocol}//#{domain}#{port}'.interpolate({
      protocol: location.protocol,
      domain: document.domain,
      port: location.port ? ':' + location.port : ''
    });
  },
  getHeader: function (name) {
    try {
      return this.transport.getResponseHeader(name) || null;
    } catch (e) {
      return null;
    }
  },
  evalResponse: function () {
    try {
      return eval((this.transport.responseText || '').unfilterJSON());
    } catch (e) {
      this.dispatchException(e);
    }
  },
  dispatchException: function (exception) {
    (this.options.onException || Prototype.emptyFunction)(this, exception);
    Ajax.Responders.dispatch('onException', this, exception);
  }
});
Ajax.Request.Events = ['Uninitialized', 'Loading', 'Loaded', 'Interactive', 'Complete'];
Ajax.Response = Class.create({
  initialize: function (request) {
    this.request = request;
    var transport = this.transport = request.transport,
      readyState = this.readyState = transport.readyState;
    if (readyState > 2 && !Prototype.Browser.IE || readyState == 4) {
      this.status = this.getStatus();
      this.statusText = this.getStatusText();
      this.responseText = String.interpret(transport.responseText);
      this.headerJSON = this._getHeaderJSON();
    }
    if (readyState == 4) {
      var xml = transport.responseXML;
      this.responseXML = Object.isUndefined(xml) ? null : xml;
      this.responseJSON = this._getResponseJSON();
    }
  },
  status: 0,
  statusText: '',
  getStatus: Ajax.Request.prototype.getStatus,
  getStatusText: function () {
    try {
      return this.transport.statusText || '';
    } catch (e) {
      return '';
    }
  },
  getHeader: Ajax.Request.prototype.getHeader,
  getAllHeaders: function () {
    try {
      return this.getAllResponseHeaders();
    } catch (e) {
      return null;
    }
  },
  getResponseHeader: function (name) {
    return this.transport.getResponseHeader(name);
  },
  getAllResponseHeaders: function () {
    return this.transport.getAllResponseHeaders();
  },
  _getHeaderJSON: function () {
    var json = this.getHeader('X-JSON');
    if (!json) return null;
    try {
      json = decodeURIComponent(escape(json));
    } catch (e) {}
    try {
      return json.evalJSON(this.request.options.sanitizeJSON || !this.request.isSameOrigin());
    } catch (e) {
      this.request.dispatchException(e);
    }
  },
  _getResponseJSON: function () {
    var options = this.request.options;
    if (!options.evalJSON || options.evalJSON != 'force' && !(this.getHeader('Content-type') || '').include('application/json') || this.responseText.blank()) return null;
    try {
      return this.responseText.evalJSON(options.sanitizeJSON || !this.request.isSameOrigin());
    } catch (e) {
      this.request.dispatchException(e);
    }
  }
});
Ajax.Updater = Class.create(Ajax.Request, {
  initialize: function ($super, container, url, options) {
    this.container = {
      success: container.success || container,
      failure: container.failure || (container.success ? null : container)
    };
    options = Object.clone(options);
    var onComplete = options.onComplete;
    options.onComplete = function (response, json) {
      this.updateContent(response.responseText);
      if (Object.isFunction(onComplete)) onComplete(response, json);
    }.bind(this);
    $super(url, options);
  },
  updateContent: function (responseText) {
    var receiver = this.container[this.success() ? 'success' : 'failure'],
      options = this.options;
    if (!options.evalScripts) responseText = responseText.stripScripts();
    if (receiver = $(receiver)) {
      if (options.insertion) {
        if (Object.isString(options.insertion)) {
          var insertion = {};
          insertion[options.insertion] = responseText;
          receiver.insert(insertion);
        } else options.insertion(receiver, responseText);
      } else receiver.update(responseText);
    }
  }
});
Ajax.PeriodicalUpdater = Class.create(Ajax.Base, {
  initialize: function ($super, container, url, options) {
    $super(options);
    this.onComplete = this.options.onComplete;
    this.frequency = this.options.frequency || 2;
    this.decay = this.options.decay || 1;
    this.updater = {};
    this.container = container;
    this.url = url;
    this.start();
  },
  start: function () {
    this.options.onComplete = this.updateComplete.bind(this);
    this.onTimerEvent();
  },
  stop: function () {
    this.updater.options.onComplete = undefined;
    clearTimeout(this.timer);
    (this.onComplete || Prototype.emptyFunction).apply(this, arguments);
  },
  updateComplete: function (response) {
    if (this.options.decay) {
      this.decay = response.responseText == this.lastText ? this.decay * this.options.decay : 1;
      this.lastText = response.responseText;
    }
    this.timer = this.onTimerEvent.bind(this).delay(this.decay * this.frequency);
  },
  onTimerEvent: function () {
    this.updater = new Ajax.Updater(this.container, this.url, this.options);
  }
});
(function (GLOBAL) {
  var UNDEFINED;
  var SLICE = Array.prototype.slice;
  var DIV = document.createElement('div');
  function $(element) {
    if (arguments.length > 1) {
      for (var i = 0, elements = [], length = arguments.length; i < length; i++) elements.push($(arguments[i]));
      return elements;
    }
    if (Object.isString(element)) element = document.getElementById(element);
    return Element.extend(element);
  }
  GLOBAL.$ = $;
  if (!GLOBAL.Node) GLOBAL.Node = {};
  if (!GLOBAL.Node.ELEMENT_NODE) {
    Object.extend(GLOBAL.Node, {
      ELEMENT_NODE: 1,
      ATTRIBUTE_NODE: 2,
      TEXT_NODE: 3,
      CDATA_SECTION_NODE: 4,
      ENTITY_REFERENCE_NODE: 5,
      ENTITY_NODE: 6,
      PROCESSING_INSTRUCTION_NODE: 7,
      COMMENT_NODE: 8,
      DOCUMENT_NODE: 9,
      DOCUMENT_TYPE_NODE: 10,
      DOCUMENT_FRAGMENT_NODE: 11,
      NOTATION_NODE: 12
    });
  }
  var ELEMENT_CACHE = {};
  function shouldUseCreationCache(tagName, attributes) {
    if (tagName === 'select') return false;
    if ('type' in attributes) return false;
    return true;
  }
  var HAS_EXTENDED_CREATE_ELEMENT_SYNTAX = function () {
    try {
      var el = document.createElement('<input name="x">');
      return el.tagName.toLowerCase() === 'input' && el.name === 'x';
    } catch (err) {
      return false;
    }
  }();
  var oldElement = GLOBAL.Element;
  function Element(tagName, attributes) {
    attributes = attributes || {};
    tagName = tagName.toLowerCase();
    if (HAS_EXTENDED_CREATE_ELEMENT_SYNTAX && attributes.name) {
      tagName = '<' + tagName + ' name="' + attributes.name + '">';
      delete attributes.name;
      return Element.writeAttribute(document.createElement(tagName), attributes);
    }
    if (!ELEMENT_CACHE[tagName]) ELEMENT_CACHE[tagName] = Element.extend(document.createElement(tagName));
    var node = shouldUseCreationCache(tagName, attributes) ? ELEMENT_CACHE[tagName].cloneNode(false) : document.createElement(tagName);
    return Element.writeAttribute(node, attributes);
  }
  GLOBAL.Element = Element;
  Object.extend(GLOBAL.Element, oldElement || {});
  if (oldElement) GLOBAL.Element.prototype = oldElement.prototype;
  Element.Methods = {
    ByTag: {},
    Simulated: {}
  };
  var methods = {};
  var INSPECT_ATTRIBUTES = {
    id: 'id',
    className: 'class'
  };
  function inspect(element) {
    element = $(element);
    var result = '<' + element.tagName.toLowerCase();
    var attribute, value;
    for (var property in INSPECT_ATTRIBUTES) {
      attribute = INSPECT_ATTRIBUTES[property];
      value = (element[property] || '').toString();
      if (value) result += ' ' + attribute + '=' + value.inspect(true);
    }
    return result + '>';
  }
  methods.inspect = inspect;
  function visible(element) {
    return $(element).getStyle('display') !== 'none';
  }
  function toggle(element, bool) {
    element = $(element);
    if (typeof bool !== 'boolean') bool = !Element.visible(element);
    Element[bool ? 'show' : 'hide'](element);
    return element;
  }
  function hide(element) {
    element = $(element);
    element.style.display = 'none';
    return element;
  }
  function show(element) {
    element = $(element);
    element.style.display = '';
    return element;
  }
  Object.extend(methods, {
    visible: visible,
    toggle: toggle,
    hide: hide,
    show: show
  });
  function remove(element) {
    element = $(element);
    element.parentNode.removeChild(element);
    return element;
  }
  var SELECT_ELEMENT_INNERHTML_BUGGY = function () {
    var el = document.createElement("select"),
      isBuggy = true;
    el.innerHTML = "<option value=\"test\">test</option>";
    if (el.options && el.options[0]) {
      isBuggy = el.options[0].nodeName.toUpperCase() !== "OPTION";
    }
    el = null;
    return isBuggy;
  }();
  var TABLE_ELEMENT_INNERHTML_BUGGY = function () {
    try {
      var el = document.createElement("table");
      if (el && el.tBodies) {
        el.innerHTML = "<tbody><tr><td>test</td></tr></tbody>";
        var isBuggy = typeof el.tBodies[0] == "undefined";
        el = null;
        return isBuggy;
      }
    } catch (e) {
      return true;
    }
  }();
  var LINK_ELEMENT_INNERHTML_BUGGY = function () {
    try {
      var el = document.createElement('div');
      el.innerHTML = "<link />";
      var isBuggy = el.childNodes.length === 0;
      el = null;
      return isBuggy;
    } catch (e) {
      return true;
    }
  }();
  var ANY_INNERHTML_BUGGY = SELECT_ELEMENT_INNERHTML_BUGGY || TABLE_ELEMENT_INNERHTML_BUGGY || LINK_ELEMENT_INNERHTML_BUGGY;
  var SCRIPT_ELEMENT_REJECTS_TEXTNODE_APPENDING = function () {
    var s = document.createElement("script"),
      isBuggy = false;
    try {
      s.appendChild(document.createTextNode(""));
      isBuggy = !s.firstChild || s.firstChild && s.firstChild.nodeType !== 3;
    } catch (e) {
      isBuggy = true;
    }
    s = null;
    return isBuggy;
  }();
  function update(element, content) {
    element = $(element);
    var descendants = element.getElementsByTagName('*'),
      i = descendants.length;
    while (i--) purgeElement(descendants[i]);
    if (content && content.toElement) content = content.toElement();
    if (Object.isElement(content)) return element.update().insert(content);
    content = Object.toHTML(content);
    var tagName = element.tagName.toUpperCase();
    if (tagName === 'SCRIPT' && SCRIPT_ELEMENT_REJECTS_TEXTNODE_APPENDING) {
      element.text = content;
      return element;
    }
    if (ANY_INNERHTML_BUGGY) {
      if (tagName in INSERTION_TRANSLATIONS.tags) {
        while (element.firstChild) element.removeChild(element.firstChild);
        var nodes = getContentFromAnonymousElement(tagName, content.stripScripts());
        for (var i = 0, node; node = nodes[i]; i++) element.appendChild(node);
      } else if (LINK_ELEMENT_INNERHTML_BUGGY && Object.isString(content) && content.indexOf('<link') > -1) {
        while (element.firstChild) element.removeChild(element.firstChild);
        var nodes = getContentFromAnonymousElement(tagName, content.stripScripts(), true);
        for (var i = 0, node; node = nodes[i]; i++) element.appendChild(node);
      } else {
        element.innerHTML = content.stripScripts();
      }
    } else {
      element.innerHTML = content.stripScripts();
    }
    content.evalScripts.bind(content).defer();
    return element;
  }
  function replace(element, content) {
    element = $(element);
    if (content && content.toElement) {
      content = content.toElement();
    } else if (!Object.isElement(content)) {
      content = Object.toHTML(content);
      var range = element.ownerDocument.createRange();
      range.selectNode(element);
      content.evalScripts.bind(content).defer();
      content = range.createContextualFragment(content.stripScripts());
    }
    element.parentNode.replaceChild(content, element);
    return element;
  }
  var INSERTION_TRANSLATIONS = {
    before: function (element, node) {
      element.parentNode.insertBefore(node, element);
    },
    top: function (element, node) {
      element.insertBefore(node, element.firstChild);
    },
    bottom: function (element, node) {
      element.appendChild(node);
    },
    after: function (element, node) {
      element.parentNode.insertBefore(node, element.nextSibling);
    },
    tags: {
      TABLE: ['<table>', '</table>', 1],
      TBODY: ['<table><tbody>', '</tbody></table>', 2],
      TR: ['<table><tbody><tr>', '</tr></tbody></table>', 3],
      TD: ['<table><tbody><tr><td>', '</td></tr></tbody></table>', 4],
      SELECT: ['<select>', '</select>', 1]
    }
  };
  var tags = INSERTION_TRANSLATIONS.tags;
  Object.extend(tags, {
    THEAD: tags.TBODY,
    TFOOT: tags.TBODY,
    TH: tags.TD
  });
  function replace_IE(element, content) {
    element = $(element);
    if (content && content.toElement) content = content.toElement();
    if (Object.isElement(content)) {
      element.parentNode.replaceChild(content, element);
      return element;
    }
    content = Object.toHTML(content);
    var parent = element.parentNode,
      tagName = parent.tagName.toUpperCase();
    if (tagName in INSERTION_TRANSLATIONS.tags) {
      var nextSibling = Element.next(element);
      var fragments = getContentFromAnonymousElement(tagName, content.stripScripts());
      parent.removeChild(element);
      var iterator;
      if (nextSibling) iterator = function (node) {
        parent.insertBefore(node, nextSibling);
      };else iterator = function (node) {
        parent.appendChild(node);
      };
      fragments.each(iterator);
    } else {
      element.outerHTML = content.stripScripts();
    }
    content.evalScripts.bind(content).defer();
    return element;
  }
  if ('outerHTML' in document.documentElement) replace = replace_IE;
  function isContent(content) {
    if (Object.isUndefined(content) || content === null) return false;
    if (Object.isString(content) || Object.isNumber(content)) return true;
    if (Object.isElement(content)) return true;
    if (content.toElement || content.toHTML) return true;
    return false;
  }
  function insertContentAt(element, content, position) {
    position = position.toLowerCase();
    var method = INSERTION_TRANSLATIONS[position];
    if (content && content.toElement) content = content.toElement();
    if (Object.isElement(content)) {
      method(element, content);
      return element;
    }
    content = Object.toHTML(content);
    var tagName = (position === 'before' || position === 'after' ? element.parentNode : element).tagName.toUpperCase();
    var childNodes = getContentFromAnonymousElement(tagName, content.stripScripts());
    if (position === 'top' || position === 'after') childNodes.reverse();
    for (var i = 0, node; node = childNodes[i]; i++) method(element, node);
    content.evalScripts.bind(content).defer();
  }
  function insert(element, insertions) {
    element = $(element);
    if (isContent(insertions)) insertions = {
      bottom: insertions
    };
    for (var position in insertions) insertContentAt(element, insertions[position], position);
    return element;
  }
  function wrap(element, wrapper, attributes) {
    element = $(element);
    if (Object.isElement(wrapper)) {
      $(wrapper).writeAttribute(attributes || {});
    } else if (Object.isString(wrapper)) {
      wrapper = new Element(wrapper, attributes);
    } else {
      wrapper = new Element('div', wrapper);
    }
    if (element.parentNode) element.parentNode.replaceChild(wrapper, element);
    wrapper.appendChild(element);
    return wrapper;
  }
  function cleanWhitespace(element) {
    element = $(element);
    var node = element.firstChild;
    while (node) {
      var nextNode = node.nextSibling;
      if (node.nodeType === Node.TEXT_NODE && !/\S/.test(node.nodeValue)) element.removeChild(node);
      node = nextNode;
    }
    return element;
  }
  function empty(element) {
    return $(element).innerHTML.blank();
  }
  function getContentFromAnonymousElement(tagName, html, force) {
    var t = INSERTION_TRANSLATIONS.tags[tagName],
      div = DIV;
    var workaround = !!t;
    if (!workaround && force) {
      workaround = true;
      t = ['', '', 0];
    }
    if (workaround) {
      div.innerHTML = '&#160;' + t[0] + html + t[1];
      div.removeChild(div.firstChild);
      for (var i = t[2]; i--;) div = div.firstChild;
    } else {
      div.innerHTML = html;
    }
    return $A(div.childNodes);
  }
  function clone(element, deep) {
    if (!(element = $(element))) return;
    var clone = element.cloneNode(deep);
    if (!HAS_UNIQUE_ID_PROPERTY) {
      clone._prototypeUID = UNDEFINED;
      if (deep) {
        var descendants = Element.select(clone, '*'),
          i = descendants.length;
        while (i--) descendants[i]._prototypeUID = UNDEFINED;
      }
    }
    return Element.extend(clone);
  }
  function purgeElement(element) {
    var uid = getUniqueElementID(element);
    if (uid) {
      Element.stopObserving(element);
      if (!HAS_UNIQUE_ID_PROPERTY) element._prototypeUID = UNDEFINED;
      delete Element.Storage[uid];
    }
  }
  function purgeCollection(elements) {
    var i = elements.length;
    while (i--) purgeElement(elements[i]);
  }
  function purgeCollection_IE(elements) {
    var i = elements.length,
      element,
      uid;
    while (i--) {
      element = elements[i];
      uid = getUniqueElementID(element);
      delete Element.Storage[uid];
      delete Event.cache[uid];
    }
  }
  if (HAS_UNIQUE_ID_PROPERTY) {
    purgeCollection = purgeCollection_IE;
  }
  function purge(element) {
    if (!(element = $(element))) return;
    purgeElement(element);
    var descendants = element.getElementsByTagName('*'),
      i = descendants.length;
    while (i--) purgeElement(descendants[i]);
    return null;
  }
  Object.extend(methods, {
    remove: remove,
    update: update,
    replace: replace,
    insert: insert,
    wrap: wrap,
    cleanWhitespace: cleanWhitespace,
    empty: empty,
    clone: clone,
    purge: purge
  });
  function recursivelyCollect(element, property, maximumLength) {
    element = $(element);
    maximumLength = maximumLength || -1;
    var elements = [];
    while (element = element[property]) {
      if (element.nodeType === Node.ELEMENT_NODE) elements.push(Element.extend(element));
      if (elements.length === maximumLength) break;
    }
    return elements;
  }
  function ancestors(element) {
    return recursivelyCollect(element, 'parentNode');
  }
  function descendants(element) {
    return Element.select(element, '*');
  }
  function firstDescendant(element) {
    element = $(element).firstChild;
    while (element && element.nodeType !== Node.ELEMENT_NODE) element = element.nextSibling;
    return $(element);
  }
  function immediateDescendants(element) {
    var results = [],
      child = $(element).firstChild;
    while (child) {
      if (child.nodeType === Node.ELEMENT_NODE) results.push(Element.extend(child));
      child = child.nextSibling;
    }
    return results;
  }
  function previousSiblings(element) {
    return recursivelyCollect(element, 'previousSibling');
  }
  function nextSiblings(element) {
    return recursivelyCollect(element, 'nextSibling');
  }
  function siblings(element) {
    element = $(element);
    var previous = previousSiblings(element),
      next = nextSiblings(element);
    return previous.reverse().concat(next);
  }
  function match(element, selector) {
    element = $(element);
    if (Object.isString(selector)) return Prototype.Selector.match(element, selector);
    return selector.match(element);
  }
  function _recursivelyFind(element, property, expression, index) {
    element = $(element), expression = expression || 0, index = index || 0;
    if (Object.isNumber(expression)) {
      index = expression, expression = null;
    }
    while (element = element[property]) {
      if (element.nodeType !== 1) continue;
      if (expression && !Prototype.Selector.match(element, expression)) continue;
      if (--index >= 0) continue;
      return Element.extend(element);
    }
  }
  function up(element, expression, index) {
    element = $(element);
    if (arguments.length === 1) return $(element.parentNode);
    return _recursivelyFind(element, 'parentNode', expression, index);
  }
  function down(element, expression, index) {
    if (arguments.length === 1) return firstDescendant(element);
    element = $(element), expression = expression || 0, index = index || 0;
    if (Object.isNumber(expression)) index = expression, expression = '*';
    var node = Prototype.Selector.select(expression, element)[index];
    return Element.extend(node);
  }
  function previous(element, expression, index) {
    return _recursivelyFind(element, 'previousSibling', expression, index);
  }
  function next(element, expression, index) {
    return _recursivelyFind(element, 'nextSibling', expression, index);
  }
  function select(element) {
    element = $(element);
    var expressions = SLICE.call(arguments, 1).join(', ');
    return Prototype.Selector.select(expressions, element);
  }
  function adjacent(element) {
    element = $(element);
    var expressions = SLICE.call(arguments, 1).join(', ');
    var siblings = Element.siblings(element),
      results = [];
    for (var i = 0, sibling; sibling = siblings[i]; i++) {
      if (Prototype.Selector.match(sibling, expressions)) results.push(sibling);
    }
    return results;
  }
  function descendantOf_DOM(element, ancestor) {
    element = $(element), ancestor = $(ancestor);
    if (!element || !ancestor) return false;
    while (element = element.parentNode) if (element === ancestor) return true;
    return false;
  }
  function descendantOf_contains(element, ancestor) {
    element = $(element), ancestor = $(ancestor);
    if (!element || !ancestor) return false;
    if (!ancestor.contains) return descendantOf_DOM(element, ancestor);
    return ancestor.contains(element) && ancestor !== element;
  }
  function descendantOf_compareDocumentPosition(element, ancestor) {
    element = $(element), ancestor = $(ancestor);
    if (!element || !ancestor) return false;
    return (element.compareDocumentPosition(ancestor) & 8) === 8;
  }
  var descendantOf;
  if (DIV.compareDocumentPosition) {
    descendantOf = descendantOf_compareDocumentPosition;
  } else if (DIV.contains) {
    descendantOf = descendantOf_contains;
  } else {
    descendantOf = descendantOf_DOM;
  }
  Object.extend(methods, {
    recursivelyCollect: recursivelyCollect,
    ancestors: ancestors,
    descendants: descendants,
    firstDescendant: firstDescendant,
    immediateDescendants: immediateDescendants,
    previousSiblings: previousSiblings,
    nextSiblings: nextSiblings,
    siblings: siblings,
    match: match,
    up: up,
    down: down,
    previous: previous,
    next: next,
    select: select,
    adjacent: adjacent,
    descendantOf: descendantOf,
    getElementsBySelector: select,
    childElements: immediateDescendants
  });
  var idCounter = 1;
  function identify(element) {
    element = $(element);
    var id = Element.readAttribute(element, 'id');
    if (id) return id;
    do {
      id = 'anonymous_element_' + idCounter++;
    } while ($(id));
    Element.writeAttribute(element, 'id', id);
    return id;
  }
  function readAttribute(element, name) {
    return $(element).getAttribute(name);
  }
  function readAttribute_IE(element, name) {
    element = $(element);
    var table = ATTRIBUTE_TRANSLATIONS.read;
    if (table.values[name]) return table.values[name](element, name);
    if (table.names[name]) name = table.names[name];
    if (name.include(':')) {
      if (!element.attributes || !element.attributes[name]) return null;
      return element.attributes[name].value;
    }
    return element.getAttribute(name);
  }
  function readAttribute_Opera(element, name) {
    if (name === 'title') return element.title;
    return element.getAttribute(name);
  }
  var PROBLEMATIC_ATTRIBUTE_READING = function () {
    DIV.setAttribute('onclick', []);
    var value = DIV.getAttribute('onclick');
    var isFunction = Object.isArray(value);
    DIV.removeAttribute('onclick');
    return isFunction;
  }();
  if (PROBLEMATIC_ATTRIBUTE_READING) {
    readAttribute = readAttribute_IE;
  } else if (Prototype.Browser.Opera) {
    readAttribute = readAttribute_Opera;
  }
  function writeAttribute(element, name, value) {
    element = $(element);
    var attributes = {},
      table = ATTRIBUTE_TRANSLATIONS.write;
    if (typeof name === 'object') {
      attributes = name;
    } else {
      attributes[name] = Object.isUndefined(value) ? true : value;
    }
    for (var attr in attributes) {
      name = table.names[attr] || attr;
      value = attributes[attr];
      if (table.values[attr]) {
        value = table.values[attr](element, value);
        if (Object.isUndefined(value)) continue;
      }
      if (value === false || value === null) element.removeAttribute(name);else if (value === true) element.setAttribute(name, name);else element.setAttribute(name, value);
    }
    return element;
  }
  var PROBLEMATIC_HAS_ATTRIBUTE_WITH_CHECKBOXES = function () {
    if (!HAS_EXTENDED_CREATE_ELEMENT_SYNTAX) {
      return false;
    }
    var checkbox = document.createElement('<input type="checkbox">');
    checkbox.checked = true;
    var node = checkbox.getAttributeNode('checked');
    return !node || !node.specified;
  }();
  function hasAttribute(element, attribute) {
    attribute = ATTRIBUTE_TRANSLATIONS.has[attribute] || attribute;
    var node = $(element).getAttributeNode(attribute);
    return !!(node && node.specified);
  }
  function hasAttribute_IE(element, attribute) {
    if (attribute === 'checked') {
      return element.checked;
    }
    return hasAttribute(element, attribute);
  }
  GLOBAL.Element.Methods.Simulated.hasAttribute = PROBLEMATIC_HAS_ATTRIBUTE_WITH_CHECKBOXES ? hasAttribute_IE : hasAttribute;
  function classNames(element) {
    return new Element.ClassNames(element);
  }
  var regExpCache = {};
  function getRegExpForClassName(className) {
    if (regExpCache[className]) return regExpCache[className];
    var re = new RegExp("(^|\\s+)" + className + "(\\s+|$)");
    regExpCache[className] = re;
    return re;
  }
  function hasClassName(element, className) {
    if (!(element = $(element))) return;
    var elementClassName = element.className;
    if (elementClassName.length === 0) return false;
    if (elementClassName === className) return true;
    return getRegExpForClassName(className).test(elementClassName);
  }
  function addClassName(element, className) {
    if (!(element = $(element))) return;
    if (!hasClassName(element, className)) element.className += (element.className ? ' ' : '') + className;
    return element;
  }
  function removeClassName(element, className) {
    if (!(element = $(element))) return;
    element.className = element.className.replace(getRegExpForClassName(className), ' ').strip();
    return element;
  }
  function toggleClassName(element, className, bool) {
    if (!(element = $(element))) return;
    if (Object.isUndefined(bool)) bool = !hasClassName(element, className);
    var method = Element[bool ? 'addClassName' : 'removeClassName'];
    return method(element, className);
  }
  var ATTRIBUTE_TRANSLATIONS = {};
  var classProp = 'className',
    forProp = 'for';
  DIV.setAttribute(classProp, 'x');
  if (DIV.className !== 'x') {
    DIV.setAttribute('class', 'x');
    if (DIV.className === 'x') classProp = 'class';
  }
  var LABEL = document.createElement('label');
  LABEL.setAttribute(forProp, 'x');
  if (LABEL.htmlFor !== 'x') {
    LABEL.setAttribute('htmlFor', 'x');
    if (LABEL.htmlFor === 'x') forProp = 'htmlFor';
  }
  LABEL = null;
  function _getAttr(element, attribute) {
    return element.getAttribute(attribute);
  }
  function _getAttr2(element, attribute) {
    return element.getAttribute(attribute, 2);
  }
  function _getAttrNode(element, attribute) {
    var node = element.getAttributeNode(attribute);
    return node ? node.value : '';
  }
  function _getFlag(element, attribute) {
    return $(element).hasAttribute(attribute) ? attribute : null;
  }
  DIV.onclick = Prototype.emptyFunction;
  var onclickValue = DIV.getAttribute('onclick');
  var _getEv;
  if (String(onclickValue).indexOf('{') > -1) {
    _getEv = function (element, attribute) {
      var value = element.getAttribute(attribute);
      if (!value) return null;
      value = value.toString();
      value = value.split('{')[1];
      value = value.split('}')[0];
      return value.strip();
    };
  } else if (onclickValue === '') {
    _getEv = function (element, attribute) {
      var value = element.getAttribute(attribute);
      if (!value) return null;
      return value.strip();
    };
  }
  ATTRIBUTE_TRANSLATIONS.read = {
    names: {
      'class': classProp,
      'className': classProp,
      'for': forProp,
      'htmlFor': forProp
    },
    values: {
      style: function (element) {
        return element.style.cssText.toLowerCase();
      },
      title: function (element) {
        return element.title;
      }
    }
  };
  ATTRIBUTE_TRANSLATIONS.write = {
    names: {
      className: 'class',
      htmlFor: 'for',
      cellpadding: 'cellPadding',
      cellspacing: 'cellSpacing'
    },
    values: {
      checked: function (element, value) {
        value = !!value;
        element.checked = value;
        return value ? 'checked' : null;
      },
      style: function (element, value) {
        element.style.cssText = value ? value : '';
      }
    }
  };
  ATTRIBUTE_TRANSLATIONS.has = {
    names: {}
  };
  Object.extend(ATTRIBUTE_TRANSLATIONS.write.names, ATTRIBUTE_TRANSLATIONS.read.names);
  var CAMEL_CASED_ATTRIBUTE_NAMES = $w('colSpan rowSpan vAlign dateTime ' + 'accessKey tabIndex encType maxLength readOnly longDesc frameBorder');
  for (var i = 0, attr; attr = CAMEL_CASED_ATTRIBUTE_NAMES[i]; i++) {
    ATTRIBUTE_TRANSLATIONS.write.names[attr.toLowerCase()] = attr;
    ATTRIBUTE_TRANSLATIONS.has.names[attr.toLowerCase()] = attr;
  }
  Object.extend(ATTRIBUTE_TRANSLATIONS.read.values, {
    href: _getAttr2,
    src: _getAttr2,
    type: _getAttr,
    action: _getAttrNode,
    disabled: _getFlag,
    checked: _getFlag,
    readonly: _getFlag,
    multiple: _getFlag,
    onload: _getEv,
    onunload: _getEv,
    onclick: _getEv,
    ondblclick: _getEv,
    onmousedown: _getEv,
    onmouseup: _getEv,
    onmouseover: _getEv,
    onmousemove: _getEv,
    onmouseout: _getEv,
    onfocus: _getEv,
    onblur: _getEv,
    onkeypress: _getEv,
    onkeydown: _getEv,
    onkeyup: _getEv,
    onsubmit: _getEv,
    onreset: _getEv,
    onselect: _getEv,
    onchange: _getEv
  });
  Object.extend(methods, {
    identify: identify,
    readAttribute: readAttribute,
    writeAttribute: writeAttribute,
    classNames: classNames,
    hasClassName: hasClassName,
    addClassName: addClassName,
    removeClassName: removeClassName,
    toggleClassName: toggleClassName
  });
  function normalizeStyleName(style) {
    if (style === 'float' || style === 'styleFloat') return 'cssFloat';
    return style.camelize();
  }
  function normalizeStyleName_IE(style) {
    if (style === 'float' || style === 'cssFloat') return 'styleFloat';
    return style.camelize();
  }
  function setStyle(element, styles) {
    element = $(element);
    var elementStyle = element.style,
      match;
    if (Object.isString(styles)) {
      elementStyle.cssText += ';' + styles;
      if (styles.include('opacity')) {
        var opacity = styles.match(/opacity:\s*(\d?\.?\d*)/)[1];
        Element.setOpacity(element, opacity);
      }
      return element;
    }
    for (var property in styles) {
      if (property === 'opacity') {
        Element.setOpacity(element, styles[property]);
      } else {
        var value = styles[property];
        if (property === 'float' || property === 'cssFloat') {
          property = Object.isUndefined(elementStyle.styleFloat) ? 'cssFloat' : 'styleFloat';
        }
        elementStyle[property] = value;
      }
    }
    return element;
  }
  function getStyle(element, style) {
    element = $(element);
    style = normalizeStyleName(style);
    var value = element.style[style];
    if (!value || value === 'auto') {
      var css = document.defaultView.getComputedStyle(element, null);
      value = css ? css[style] : null;
    }
    if (style === 'opacity') return value ? parseFloat(value) : 1.0;
    return value === 'auto' ? null : value;
  }
  function getStyle_Opera(element, style) {
    switch (style) {
      case 'height':
      case 'width':
        if (!Element.visible(element)) return null;
        var dim = parseInt(getStyle(element, style), 10);
        if (dim !== element['offset' + style.capitalize()]) return dim + 'px';
        return Element.measure(element, style);
      default:
        return getStyle(element, style);
    }
  }
  function getStyle_IE(element, style) {
    element = $(element);
    style = normalizeStyleName_IE(style);
    var value = element.style[style];
    if (!value && element.currentStyle) {
      value = element.currentStyle[style];
    }
    if (style === 'opacity') {
      if (!STANDARD_CSS_OPACITY_SUPPORTED) return getOpacity_IE(element);else return value ? parseFloat(value) : 1.0;
    }
    if (value === 'auto') {
      if ((style === 'width' || style === 'height') && Element.visible(element)) return Element.measure(element, style) + 'px';
      return null;
    }
    return value;
  }
  function stripAlphaFromFilter_IE(filter) {
    return (filter || '').replace(/alpha\([^\)]*\)/gi, '');
  }
  function hasLayout_IE(element) {
    if (!element.currentStyle || !element.currentStyle.hasLayout) element.style.zoom = 1;
    return element;
  }
  var STANDARD_CSS_OPACITY_SUPPORTED = function () {
    DIV.style.cssText = "opacity:.55";
    return /^0.55/.test(DIV.style.opacity);
  }();
  function setOpacity(element, value) {
    element = $(element);
    if (value == 1 || value === '') value = '';else if (value < 0.00001) value = 0;
    element.style.opacity = value;
    return element;
  }
  function setOpacity_IE(element, value) {
    if (STANDARD_CSS_OPACITY_SUPPORTED) return setOpacity(element, value);
    element = hasLayout_IE($(element));
    var filter = Element.getStyle(element, 'filter'),
      style = element.style;
    if (value == 1 || value === '') {
      filter = stripAlphaFromFilter_IE(filter);
      if (filter) style.filter = filter;else style.removeAttribute('filter');
      return element;
    }
    if (value < 0.00001) value = 0;
    style.filter = stripAlphaFromFilter_IE(filter) + ' alpha(opacity=' + value * 100 + ')';
    return element;
  }
  function getOpacity(element) {
    return Element.getStyle(element, 'opacity');
  }
  function getOpacity_IE(element) {
    if (STANDARD_CSS_OPACITY_SUPPORTED) return getOpacity(element);
    var filter = Element.getStyle(element, 'filter');
    if (filter.length === 0) return 1.0;
    var match = (filter || '').match(/alpha\(opacity=(.*)\)/i);
    if (match && match[1]) return parseFloat(match[1]) / 100;
    return 1.0;
  }
  Object.extend(methods, {
    setStyle: setStyle,
    getStyle: getStyle,
    setOpacity: setOpacity,
    getOpacity: getOpacity
  });
  if ('styleFloat' in DIV.style) {
    methods.getStyle = getStyle_IE;
    methods.setOpacity = setOpacity_IE;
    methods.getOpacity = getOpacity_IE;
  }
  var UID = 0;
  GLOBAL.Element.Storage = {
    UID: 1
  };
  function getUniqueElementID(element) {
    if (element === window) return 0;
    if (typeof element._prototypeUID === 'undefined') element._prototypeUID = Element.Storage.UID++;
    return element._prototypeUID;
  }
  function getUniqueElementID_IE(element) {
    if (element === window) return 0;
    if (element == document) return 1;
    return element.uniqueID;
  }
  var HAS_UNIQUE_ID_PROPERTY = ('uniqueID' in DIV);
  if (HAS_UNIQUE_ID_PROPERTY) getUniqueElementID = getUniqueElementID_IE;
  function getStorage(element) {
    if (!(element = $(element))) return;
    var uid = getUniqueElementID(element);
    if (!Element.Storage[uid]) Element.Storage[uid] = $H();
    return Element.Storage[uid];
  }
  function store(element, key, value) {
    if (!(element = $(element))) return;
    var storage = getStorage(element);
    if (arguments.length === 2) {
      storage.update(key);
    } else {
      storage.set(key, value);
    }
    return element;
  }
  function retrieve(element, key, defaultValue) {
    if (!(element = $(element))) return;
    var storage = getStorage(element),
      value = storage.get(key);
    if (Object.isUndefined(value)) {
      storage.set(key, defaultValue);
      value = defaultValue;
    }
    return value;
  }
  Object.extend(methods, {
    getStorage: getStorage,
    store: store,
    retrieve: retrieve
  });
  var Methods = {},
    ByTag = Element.Methods.ByTag,
    F = Prototype.BrowserFeatures;
  if (!F.ElementExtensions && '__proto__' in DIV) {
    GLOBAL.HTMLElement = {};
    GLOBAL.HTMLElement.prototype = DIV['__proto__'];
    F.ElementExtensions = true;
  }
  function checkElementPrototypeDeficiency(tagName) {
    if (typeof window.Element === 'undefined') return false;
    if (!HAS_EXTENDED_CREATE_ELEMENT_SYNTAX) return false;
    var proto = window.Element.prototype;
    if (proto) {
      var id = '_' + (Math.random() + '').slice(2),
        el = document.createElement(tagName);
      proto[id] = 'x';
      var isBuggy = el[id] !== 'x';
      delete proto[id];
      el = null;
      return isBuggy;
    }
    return false;
  }
  var HTMLOBJECTELEMENT_PROTOTYPE_BUGGY = checkElementPrototypeDeficiency('object');
  function extendElementWith(element, methods) {
    for (var property in methods) {
      var value = methods[property];
      if (Object.isFunction(value) && !(property in element)) element[property] = value.methodize();
    }
  }
  var EXTENDED = {};
  function elementIsExtended(element) {
    var uid = getUniqueElementID(element);
    return uid in EXTENDED;
  }
  function extend(element) {
    if (!element || elementIsExtended(element)) return element;
    if (element.nodeType !== Node.ELEMENT_NODE || element == window) return element;
    var methods = Object.clone(Methods),
      tagName = element.tagName.toUpperCase();
    if (ByTag[tagName]) Object.extend(methods, ByTag[tagName]);
    extendElementWith(element, methods);
    EXTENDED[getUniqueElementID(element)] = true;
    return element;
  }
  function extend_IE8(element) {
    if (!element || elementIsExtended(element)) return element;
    var t = element.tagName;
    if (t && /^(?:object|applet|embed)$/i.test(t)) {
      extendElementWith(element, Element.Methods);
      extendElementWith(element, Element.Methods.Simulated);
      extendElementWith(element, Element.Methods.ByTag[t.toUpperCase()]);
    }
    return element;
  }
  if (F.SpecificElementExtensions) {
    extend = HTMLOBJECTELEMENT_PROTOTYPE_BUGGY ? extend_IE8 : Prototype.K;
  }
  function addMethodsToTagName(tagName, methods) {
    tagName = tagName.toUpperCase();
    if (!ByTag[tagName]) ByTag[tagName] = {};
    Object.extend(ByTag[tagName], methods);
  }
  function mergeMethods(destination, methods, onlyIfAbsent) {
    if (Object.isUndefined(onlyIfAbsent)) onlyIfAbsent = false;
    for (var property in methods) {
      var value = methods[property];
      if (!Object.isFunction(value)) continue;
      if (!onlyIfAbsent || !(property in destination)) destination[property] = value.methodize();
    }
  }
  function findDOMClass(tagName) {
    var klass;
    var trans = {
      "OPTGROUP": "OptGroup",
      "TEXTAREA": "TextArea",
      "P": "Paragraph",
      "FIELDSET": "FieldSet",
      "UL": "UList",
      "OL": "OList",
      "DL": "DList",
      "DIR": "Directory",
      "H1": "Heading",
      "H2": "Heading",
      "H3": "Heading",
      "H4": "Heading",
      "H5": "Heading",
      "H6": "Heading",
      "Q": "Quote",
      "INS": "Mod",
      "DEL": "Mod",
      "A": "Anchor",
      "IMG": "Image",
      "CAPTION": "TableCaption",
      "COL": "TableCol",
      "COLGROUP": "TableCol",
      "THEAD": "TableSection",
      "TFOOT": "TableSection",
      "TBODY": "TableSection",
      "TR": "TableRow",
      "TH": "TableCell",
      "TD": "TableCell",
      "FRAMESET": "FrameSet",
      "IFRAME": "IFrame"
    };
    if (trans[tagName]) klass = 'HTML' + trans[tagName] + 'Element';
    if (window[klass]) return window[klass];
    klass = 'HTML' + tagName + 'Element';
    if (window[klass]) return window[klass];
    klass = 'HTML' + tagName.capitalize() + 'Element';
    if (window[klass]) return window[klass];
    var element = document.createElement(tagName),
      proto = element['__proto__'] || element.constructor.prototype;
    element = null;
    return proto;
  }
  function addMethods(methods) {
    if (arguments.length === 0) addFormMethods();
    if (arguments.length === 2) {
      var tagName = methods;
      methods = arguments[1];
    }
    if (!tagName) {
      Object.extend(Element.Methods, methods || {});
    } else {
      if (Object.isArray(tagName)) {
        for (var i = 0, tag; tag = tagName[i]; i++) addMethodsToTagName(tag, methods);
      } else {
        addMethodsToTagName(tagName, methods);
      }
    }
    var ELEMENT_PROTOTYPE = window.HTMLElement ? HTMLElement.prototype : Element.prototype;
    if (F.ElementExtensions) {
      mergeMethods(ELEMENT_PROTOTYPE, Element.Methods);
      mergeMethods(ELEMENT_PROTOTYPE, Element.Methods.Simulated, true);
    }
    if (F.SpecificElementExtensions) {
      for (var tag in Element.Methods.ByTag) {
        var klass = findDOMClass(tag);
        if (Object.isUndefined(klass)) continue;
        mergeMethods(klass.prototype, ByTag[tag]);
      }
    }
    Object.extend(Element, Element.Methods);
    Object.extend(Element, Element.Methods.Simulated);
    delete Element.ByTag;
    delete Element.Simulated;
    Element.extend.refresh();
    ELEMENT_CACHE = {};
  }
  Object.extend(GLOBAL.Element, {
    extend: extend,
    addMethods: addMethods
  });
  if (extend === Prototype.K) {
    GLOBAL.Element.extend.refresh = Prototype.emptyFunction;
  } else {
    GLOBAL.Element.extend.refresh = function () {
      if (Prototype.BrowserFeatures.ElementExtensions) return;
      Object.extend(Methods, Element.Methods);
      Object.extend(Methods, Element.Methods.Simulated);
      EXTENDED = {};
    };
  }
  function addFormMethods() {
    Object.extend(Form, Form.Methods);
    Object.extend(Form.Element, Form.Element.Methods);
    Object.extend(Element.Methods.ByTag, {
      "FORM": Object.clone(Form.Methods),
      "INPUT": Object.clone(Form.Element.Methods),
      "SELECT": Object.clone(Form.Element.Methods),
      "TEXTAREA": Object.clone(Form.Element.Methods),
      "BUTTON": Object.clone(Form.Element.Methods)
    });
  }
  Element.addMethods(methods);
  function destroyCache_IE() {
    DIV = null;
    ELEMENT_CACHE = null;
  }
  if (window.attachEvent) window.attachEvent('onunload', destroyCache_IE);
})(this);
(function () {
  function toDecimal(pctString) {
    var match = pctString.match(/^(\d+)%?$/i);
    if (!match) return null;
    return Number(match[1]) / 100;
  }
  function getRawStyle(element, style) {
    element = $(element);
    var value = element.style[style];
    if (!value || value === 'auto') {
      var css = document.defaultView.getComputedStyle(element, null);
      value = css ? css[style] : null;
    }
    if (style === 'opacity') return value ? parseFloat(value) : 1.0;
    return value === 'auto' ? null : value;
  }
  function getRawStyle_IE(element, style) {
    var value = element.style[style];
    if (!value && element.currentStyle) {
      value = element.currentStyle[style];
    }
    return value;
  }
  function getContentWidth(element, context) {
    var boxWidth = element.offsetWidth;
    var bl = getPixelValue(element, 'borderLeftWidth', context) || 0;
    var br = getPixelValue(element, 'borderRightWidth', context) || 0;
    var pl = getPixelValue(element, 'paddingLeft', context) || 0;
    var pr = getPixelValue(element, 'paddingRight', context) || 0;
    return boxWidth - bl - br - pl - pr;
  }
  if (!Object.isUndefined(document.documentElement.currentStyle) && !Prototype.Browser.Opera) {
    getRawStyle = getRawStyle_IE;
  }
  function getPixelValue(value, property, context) {
    var element = null;
    if (Object.isElement(value)) {
      element = value;
      value = getRawStyle(element, property);
    }
    if (value === null || Object.isUndefined(value)) {
      return null;
    }
    if (/^(?:-)?\d+(\.\d+)?(px)?$/i.test(value)) {
      return window.parseFloat(value);
    }
    var isPercentage = value.include('%'),
      isViewport = context === document.viewport;
    if (/\d/.test(value) && element && element.runtimeStyle && !(isPercentage && isViewport)) {
      var style = element.style.left,
        rStyle = element.runtimeStyle.left;
      element.runtimeStyle.left = element.currentStyle.left;
      element.style.left = value || 0;
      value = element.style.pixelLeft;
      element.style.left = style;
      element.runtimeStyle.left = rStyle;
      return value;
    }
    if (element && isPercentage) {
      context = context || element.parentNode;
      var decimal = toDecimal(value),
        whole = null;
      var isHorizontal = property.include('left') || property.include('right') || property.include('width');
      var isVertical = property.include('top') || property.include('bottom') || property.include('height');
      if (context === document.viewport) {
        if (isHorizontal) {
          whole = document.viewport.getWidth();
        } else if (isVertical) {
          whole = document.viewport.getHeight();
        }
      } else {
        if (isHorizontal) {
          whole = $(context).measure('width');
        } else if (isVertical) {
          whole = $(context).measure('height');
        }
      }
      return whole === null ? 0 : whole * decimal;
    }
    return 0;
  }
  function toCSSPixels(number) {
    if (Object.isString(number) && number.endsWith('px')) return number;
    return number + 'px';
  }
  function isDisplayed(element) {
    while (element && element.parentNode) {
      var display = element.getStyle('display');
      if (display === 'none') {
        return false;
      }
      element = $(element.parentNode);
    }
    return true;
  }
  var hasLayout = Prototype.K;
  if ('currentStyle' in document.documentElement) {
    hasLayout = function (element) {
      if (!element.currentStyle.hasLayout) {
        element.style.zoom = 1;
      }
      return element;
    };
  }
  function cssNameFor(key) {
    if (key.include('border')) key = key + '-width';
    return key.camelize();
  }
  Element.Layout = Class.create(Hash, {
    initialize: function ($super, element, preCompute) {
      $super();
      this.element = $(element);
      Element.Layout.PROPERTIES.each(function (property) {
        this._set(property, null);
      }, this);
      if (preCompute) {
        this._preComputing = true;
        this._begin();
        Element.Layout.PROPERTIES.each(this._compute, this);
        this._end();
        this._preComputing = false;
      }
    },
    _set: function (property, value) {
      return Hash.prototype.set.call(this, property, value);
    },
    set: function (property, value) {
      throw "Properties of Element.Layout are read-only.";
    },
    get: function ($super, property) {
      var value = $super(property);
      return value === null ? this._compute(property) : value;
    },
    _begin: function () {
      if (this._isPrepared()) return;
      var element = this.element;
      if (isDisplayed(element)) {
        this._setPrepared(true);
        return;
      }
      var originalStyles = {
        position: element.style.position || '',
        width: element.style.width || '',
        visibility: element.style.visibility || '',
        display: element.style.display || ''
      };
      element.store('prototype_original_styles', originalStyles);
      var position = getRawStyle(element, 'position'),
        width = element.offsetWidth;
      if (width === 0 || width === null) {
        element.style.display = 'block';
        width = element.offsetWidth;
      }
      var context = position === 'fixed' ? document.viewport : element.parentNode;
      var tempStyles = {
        visibility: 'hidden',
        display: 'block'
      };
      if (position !== 'fixed') tempStyles.position = 'absolute';
      element.setStyle(tempStyles);
      var positionedWidth = element.offsetWidth,
        newWidth;
      if (width && positionedWidth === width) {
        newWidth = getContentWidth(element, context);
      } else if (position === 'absolute' || position === 'fixed') {
        newWidth = getContentWidth(element, context);
      } else {
        var parent = element.parentNode,
          pLayout = $(parent).getLayout();
        newWidth = pLayout.get('width') - this.get('margin-left') - this.get('border-left') - this.get('padding-left') - this.get('padding-right') - this.get('border-right') - this.get('margin-right');
      }
      element.setStyle({
        width: newWidth + 'px'
      });
      this._setPrepared(true);
    },
    _end: function () {
      var element = this.element;
      var originalStyles = element.retrieve('prototype_original_styles');
      element.store('prototype_original_styles', null);
      element.setStyle(originalStyles);
      this._setPrepared(false);
    },
    _compute: function (property) {
      var COMPUTATIONS = Element.Layout.COMPUTATIONS;
      if (!(property in COMPUTATIONS)) {
        throw "Property not found.";
      }
      return this._set(property, COMPUTATIONS[property].call(this, this.element));
    },
    _isPrepared: function () {
      return this.element.retrieve('prototype_element_layout_prepared', false);
    },
    _setPrepared: function (bool) {
      return this.element.store('prototype_element_layout_prepared', bool);
    },
    toObject: function () {
      var args = $A(arguments);
      var keys = args.length === 0 ? Element.Layout.PROPERTIES : args.join(' ').split(' ');
      var obj = {};
      keys.each(function (key) {
        if (!Element.Layout.PROPERTIES.include(key)) return;
        var value = this.get(key);
        if (value != null) obj[key] = value;
      }, this);
      return obj;
    },
    toHash: function () {
      var obj = this.toObject.apply(this, arguments);
      return new Hash(obj);
    },
    toCSS: function () {
      var args = $A(arguments);
      var keys = args.length === 0 ? Element.Layout.PROPERTIES : args.join(' ').split(' ');
      var css = {};
      keys.each(function (key) {
        if (!Element.Layout.PROPERTIES.include(key)) return;
        if (Element.Layout.COMPOSITE_PROPERTIES.include(key)) return;
        var value = this.get(key);
        if (value != null) css[cssNameFor(key)] = value + 'px';
      }, this);
      return css;
    },
    inspect: function () {
      return "#<Element.Layout>";
    }
  });
  Object.extend(Element.Layout, {
    PROPERTIES: $w('height width top left right bottom border-left border-right border-top border-bottom padding-left padding-right padding-top padding-bottom margin-top margin-bottom margin-left margin-right padding-box-width padding-box-height border-box-width border-box-height margin-box-width margin-box-height'),
    COMPOSITE_PROPERTIES: $w('padding-box-width padding-box-height margin-box-width margin-box-height border-box-width border-box-height'),
    COMPUTATIONS: {
      'height': function (element) {
        if (!this._preComputing) this._begin();
        var bHeight = this.get('border-box-height');
        if (bHeight <= 0) {
          if (!this._preComputing) this._end();
          return 0;
        }
        var bTop = this.get('border-top'),
          bBottom = this.get('border-bottom');
        var pTop = this.get('padding-top'),
          pBottom = this.get('padding-bottom');
        if (!this._preComputing) this._end();
        return bHeight - bTop - bBottom - pTop - pBottom;
      },
      'width': function (element) {
        if (!this._preComputing) this._begin();
        var bWidth = this.get('border-box-width');
        if (bWidth <= 0) {
          if (!this._preComputing) this._end();
          return 0;
        }
        var bLeft = this.get('border-left'),
          bRight = this.get('border-right');
        var pLeft = this.get('padding-left'),
          pRight = this.get('padding-right');
        if (!this._preComputing) this._end();
        return bWidth - bLeft - bRight - pLeft - pRight;
      },
      'padding-box-height': function (element) {
        var height = this.get('height'),
          pTop = this.get('padding-top'),
          pBottom = this.get('padding-bottom');
        return height + pTop + pBottom;
      },
      'padding-box-width': function (element) {
        var width = this.get('width'),
          pLeft = this.get('padding-left'),
          pRight = this.get('padding-right');
        return width + pLeft + pRight;
      },
      'border-box-height': function (element) {
        if (!this._preComputing) this._begin();
        var height = element.offsetHeight;
        if (!this._preComputing) this._end();
        return height;
      },
      'border-box-width': function (element) {
        if (!this._preComputing) this._begin();
        var width = element.offsetWidth;
        if (!this._preComputing) this._end();
        return width;
      },
      'margin-box-height': function (element) {
        var bHeight = this.get('border-box-height'),
          mTop = this.get('margin-top'),
          mBottom = this.get('margin-bottom');
        if (bHeight <= 0) return 0;
        return bHeight + mTop + mBottom;
      },
      'margin-box-width': function (element) {
        var bWidth = this.get('border-box-width'),
          mLeft = this.get('margin-left'),
          mRight = this.get('margin-right');
        if (bWidth <= 0) return 0;
        return bWidth + mLeft + mRight;
      },
      'top': function (element) {
        var offset = element.positionedOffset();
        return offset.top;
      },
      'bottom': function (element) {
        var offset = element.positionedOffset(),
          parent = element.getOffsetParent(),
          pHeight = parent.measure('height');
        var mHeight = this.get('border-box-height');
        return pHeight - mHeight - offset.top;
      },
      'left': function (element) {
        var offset = element.positionedOffset();
        return offset.left;
      },
      'right': function (element) {
        var offset = element.positionedOffset(),
          parent = element.getOffsetParent(),
          pWidth = parent.measure('width');
        var mWidth = this.get('border-box-width');
        return pWidth - mWidth - offset.left;
      },
      'padding-top': function (element) {
        return getPixelValue(element, 'paddingTop');
      },
      'padding-bottom': function (element) {
        return getPixelValue(element, 'paddingBottom');
      },
      'padding-left': function (element) {
        return getPixelValue(element, 'paddingLeft');
      },
      'padding-right': function (element) {
        return getPixelValue(element, 'paddingRight');
      },
      'border-top': function (element) {
        return getPixelValue(element, 'borderTopWidth');
      },
      'border-bottom': function (element) {
        return getPixelValue(element, 'borderBottomWidth');
      },
      'border-left': function (element) {
        return getPixelValue(element, 'borderLeftWidth');
      },
      'border-right': function (element) {
        return getPixelValue(element, 'borderRightWidth');
      },
      'margin-top': function (element) {
        return getPixelValue(element, 'marginTop');
      },
      'margin-bottom': function (element) {
        return getPixelValue(element, 'marginBottom');
      },
      'margin-left': function (element) {
        return getPixelValue(element, 'marginLeft');
      },
      'margin-right': function (element) {
        return getPixelValue(element, 'marginRight');
      }
    }
  });
  if ('getBoundingClientRect' in document.documentElement) {
    Object.extend(Element.Layout.COMPUTATIONS, {
      'right': function (element) {
        var parent = hasLayout(element.getOffsetParent());
        var rect = element.getBoundingClientRect(),
          pRect = parent.getBoundingClientRect();
        return (pRect.right - rect.right).round();
      },
      'bottom': function (element) {
        var parent = hasLayout(element.getOffsetParent());
        var rect = element.getBoundingClientRect(),
          pRect = parent.getBoundingClientRect();
        return (pRect.bottom - rect.bottom).round();
      }
    });
  }
  Element.Offset = Class.create({
    initialize: function (left, top) {
      this.left = left.round();
      this.top = top.round();
      this[0] = this.left;
      this[1] = this.top;
    },
    relativeTo: function (offset) {
      return new Element.Offset(this.left - offset.left, this.top - offset.top);
    },
    inspect: function () {
      return "#<Element.Offset left: #{left} top: #{top}>".interpolate(this);
    },
    toString: function () {
      return "[#{left}, #{top}]".interpolate(this);
    },
    toArray: function () {
      return [this.left, this.top];
    }
  });
  function getLayout(element, preCompute) {
    return new Element.Layout(element, preCompute);
  }
  function measure(element, property) {
    return $(element).getLayout().get(property);
  }
  function getHeight(element) {
    return Element.getDimensions(element).height;
  }
  function getWidth(element) {
    return Element.getDimensions(element).width;
  }
  function getDimensions(element) {
    element = $(element);
    var display = Element.getStyle(element, 'display');
    if (display && display !== 'none') {
      return {
        width: element.offsetWidth,
        height: element.offsetHeight
      };
    }
    var style = element.style;
    var originalStyles = {
      visibility: style.visibility,
      position: style.position,
      display: style.display
    };
    var newStyles = {
      visibility: 'hidden',
      display: 'block'
    };
    if (originalStyles.position !== 'fixed') newStyles.position = 'absolute';
    Element.setStyle(element, newStyles);
    var dimensions = {
      width: element.offsetWidth,
      height: element.offsetHeight
    };
    Element.setStyle(element, originalStyles);
    return dimensions;
  }
  function getOffsetParent(element) {
    element = $(element);
    function selfOrBody(element) {
      return isHtml(element) ? $(document.body) : $(element);
    }
    if (isDocument(element) || isDetached(element) || isBody(element) || isHtml(element)) return $(document.body);
    var isInline = Element.getStyle(element, 'display') === 'inline';
    if (!isInline && element.offsetParent) return selfOrBody(element.offsetParent);
    while ((element = element.parentNode) && element !== document.body) {
      if (Element.getStyle(element, 'position') !== 'static') {
        return selfOrBody(element);
      }
    }
    return $(document.body);
  }
  function cumulativeOffset(element) {
    element = $(element);
    var valueT = 0,
      valueL = 0;
    if (element.parentNode) {
      do {
        valueT += element.offsetTop || 0;
        valueL += element.offsetLeft || 0;
        element = element.offsetParent;
      } while (element);
    }
    return new Element.Offset(valueL, valueT);
  }
  function positionedOffset(element) {
    element = $(element);
    var layout = element.getLayout();
    var valueT = 0,
      valueL = 0;
    do {
      valueT += element.offsetTop || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
      if (element) {
        if (isBody(element)) break;
        var p = Element.getStyle(element, 'position');
        if (p !== 'static') break;
      }
    } while (element);
    valueL -= layout.get('margin-left');
    valueT -= layout.get('margin-top');
    return new Element.Offset(valueL, valueT);
  }
  function cumulativeScrollOffset(element) {
    var valueT = 0,
      valueL = 0;
    do {
      if (element === document.body) {
        var bodyScrollNode = document.documentElement || document.body.parentNode || document.body;
        valueT += !Object.isUndefined(window.pageYOffset) ? window.pageYOffset : bodyScrollNode.scrollTop || 0;
        valueL += !Object.isUndefined(window.pageXOffset) ? window.pageXOffset : bodyScrollNode.scrollLeft || 0;
        break;
      } else {
        valueT += element.scrollTop || 0;
        valueL += element.scrollLeft || 0;
        element = element.parentNode;
      }
    } while (element);
    return new Element.Offset(valueL, valueT);
  }
  function viewportOffset(forElement) {
    var valueT = 0,
      valueL = 0,
      docBody = document.body;
    forElement = $(forElement);
    var element = forElement;
    do {
      valueT += element.offsetTop || 0;
      valueL += element.offsetLeft || 0;
      if (element.offsetParent == docBody && Element.getStyle(element, 'position') == 'absolute') break;
    } while (element = element.offsetParent);
    element = forElement;
    do {
      if (element != docBody) {
        valueT -= element.scrollTop || 0;
        valueL -= element.scrollLeft || 0;
      }
    } while (element = element.parentNode);
    return new Element.Offset(valueL, valueT);
  }
  function absolutize(element) {
    element = $(element);
    if (Element.getStyle(element, 'position') === 'absolute') {
      return element;
    }
    var offsetParent = getOffsetParent(element);
    var eOffset = element.viewportOffset(),
      pOffset = offsetParent.viewportOffset();
    var offset = eOffset.relativeTo(pOffset);
    var layout = element.getLayout();
    element.store('prototype_absolutize_original_styles', {
      position: element.getStyle('position'),
      left: element.getStyle('left'),
      top: element.getStyle('top'),
      width: element.getStyle('width'),
      height: element.getStyle('height')
    });
    element.setStyle({
      position: 'absolute',
      top: offset.top + 'px',
      left: offset.left + 'px',
      width: layout.get('width') + 'px',
      height: layout.get('height') + 'px'
    });
    return element;
  }
  function relativize(element) {
    element = $(element);
    if (Element.getStyle(element, 'position') === 'relative') {
      return element;
    }
    var originalStyles = element.retrieve('prototype_absolutize_original_styles');
    if (originalStyles) element.setStyle(originalStyles);
    return element;
  }
  function scrollTo(element) {
    element = $(element);
    var pos = Element.cumulativeOffset(element);
    window.scrollTo(pos.left, pos.top);
    return element;
  }
  function makePositioned(element) {
    element = $(element);
    var position = Element.getStyle(element, 'position'),
      styles = {};
    if (position === 'static' || !position) {
      styles.position = 'relative';
      if (Prototype.Browser.Opera) {
        styles.top = 0;
        styles.left = 0;
      }
      Element.setStyle(element, styles);
      Element.store(element, 'prototype_made_positioned', true);
    }
    return element;
  }
  function undoPositioned(element) {
    element = $(element);
    var storage = Element.getStorage(element),
      madePositioned = storage.get('prototype_made_positioned');
    if (madePositioned) {
      storage.unset('prototype_made_positioned');
      Element.setStyle(element, {
        position: '',
        top: '',
        bottom: '',
        left: '',
        right: ''
      });
    }
    return element;
  }
  function makeClipping(element) {
    element = $(element);
    var storage = Element.getStorage(element),
      madeClipping = storage.get('prototype_made_clipping');
    if (Object.isUndefined(madeClipping)) {
      var overflow = Element.getStyle(element, 'overflow');
      storage.set('prototype_made_clipping', overflow);
      if (overflow !== 'hidden') element.style.overflow = 'hidden';
    }
    return element;
  }
  function undoClipping(element) {
    element = $(element);
    var storage = Element.getStorage(element),
      overflow = storage.get('prototype_made_clipping');
    if (!Object.isUndefined(overflow)) {
      storage.unset('prototype_made_clipping');
      element.style.overflow = overflow || '';
    }
    return element;
  }
  function clonePosition(element, source, options) {
    options = Object.extend({
      setLeft: true,
      setTop: true,
      setWidth: true,
      setHeight: true,
      offsetTop: 0,
      offsetLeft: 0
    }, options || {});
    var docEl = document.documentElement;
    source = $(source);
    element = $(element);
    var p,
      delta,
      layout,
      styles = {};
    if (options.setLeft || options.setTop) {
      p = Element.viewportOffset(source);
      delta = [0, 0];
      if (Element.getStyle(element, 'position') === 'absolute') {
        var parent = Element.getOffsetParent(element);
        if (parent !== document.body) delta = Element.viewportOffset(parent);
      }
    }
    function pageScrollXY() {
      var x = 0,
        y = 0;
      if (Object.isNumber(window.pageXOffset)) {
        x = window.pageXOffset;
        y = window.pageYOffset;
      } else if (document.body && (document.body.scrollLeft || document.body.scrollTop)) {
        x = document.body.scrollLeft;
        y = document.body.scrollTop;
      } else if (docEl && (docEl.scrollLeft || docEl.scrollTop)) {
        x = docEl.scrollLeft;
        y = docEl.scrollTop;
      }
      return {
        x: x,
        y: y
      };
    }
    var pageXY = pageScrollXY();
    if (options.setWidth || options.setHeight) {
      layout = Element.getLayout(source);
    }
    if (options.setLeft) styles.left = p[0] + pageXY.x - delta[0] + options.offsetLeft + 'px';
    if (options.setTop) styles.top = p[1] + pageXY.y - delta[1] + options.offsetTop + 'px';
    var currentLayout = element.getLayout();
    if (options.setWidth) {
      styles.width = layout.get('width') + 'px';
    }
    if (options.setHeight) {
      styles.height = layout.get('height') + 'px';
    }
    return Element.setStyle(element, styles);
  }
  if (Prototype.Browser.IE) {
    getOffsetParent = getOffsetParent.wrap(function (proceed, element) {
      element = $(element);
      if (isDocument(element) || isDetached(element) || isBody(element) || isHtml(element)) return $(document.body);
      var position = element.getStyle('position');
      if (position !== 'static') return proceed(element);
      element.setStyle({
        position: 'relative'
      });
      var value = proceed(element);
      element.setStyle({
        position: position
      });
      return value;
    });
    positionedOffset = positionedOffset.wrap(function (proceed, element) {
      element = $(element);
      if (!element.parentNode) return new Element.Offset(0, 0);
      var position = element.getStyle('position');
      if (position !== 'static') return proceed(element);
      var offsetParent = element.getOffsetParent();
      if (offsetParent && offsetParent.getStyle('position') === 'fixed') hasLayout(offsetParent);
      element.setStyle({
        position: 'relative'
      });
      var value = proceed(element);
      element.setStyle({
        position: position
      });
      return value;
    });
  } else if (Prototype.Browser.Webkit) {
    cumulativeOffset = function (element) {
      element = $(element);
      var valueT = 0,
        valueL = 0;
      do {
        valueT += element.offsetTop || 0;
        valueL += element.offsetLeft || 0;
        if (element.offsetParent == document.body) {
          if (Element.getStyle(element, 'position') == 'absolute') break;
        }
        element = element.offsetParent;
      } while (element);
      return new Element.Offset(valueL, valueT);
    };
  }
  Element.addMethods({
    getLayout: getLayout,
    measure: measure,
    getWidth: getWidth,
    getHeight: getHeight,
    getDimensions: getDimensions,
    getOffsetParent: getOffsetParent,
    cumulativeOffset: cumulativeOffset,
    positionedOffset: positionedOffset,
    cumulativeScrollOffset: cumulativeScrollOffset,
    viewportOffset: viewportOffset,
    absolutize: absolutize,
    relativize: relativize,
    scrollTo: scrollTo,
    makePositioned: makePositioned,
    undoPositioned: undoPositioned,
    makeClipping: makeClipping,
    undoClipping: undoClipping,
    clonePosition: clonePosition
  });
  function isBody(element) {
    return element.nodeName.toUpperCase() === 'BODY';
  }
  function isHtml(element) {
    return element.nodeName.toUpperCase() === 'HTML';
  }
  function isDocument(element) {
    return element.nodeType === Node.DOCUMENT_NODE;
  }
  function isDetached(element) {
    return element !== document.body && !Element.descendantOf(element, document.body);
  }
  if ('getBoundingClientRect' in document.documentElement) {
    Element.addMethods({
      viewportOffset: function (element) {
        element = $(element);
        if (isDetached(element)) return new Element.Offset(0, 0);
        var rect = element.getBoundingClientRect(),
          docEl = document.documentElement;
        return new Element.Offset(rect.left - docEl.clientLeft, rect.top - docEl.clientTop);
      }
    });
  }
})();
(function () {
  var IS_OLD_OPERA = Prototype.Browser.Opera && window.parseFloat(window.opera.version()) < 9.5;
  var ROOT = null;
  function getRootElement() {
    if (ROOT) return ROOT;
    ROOT = IS_OLD_OPERA ? document.body : document.documentElement;
    return ROOT;
  }
  function getDimensions() {
    return {
      width: this.getWidth(),
      height: this.getHeight()
    };
  }
  function getWidth() {
    return getRootElement().clientWidth;
  }
  function getHeight() {
    return getRootElement().clientHeight;
  }
  function getScrollOffsets() {
    var x = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft;
    var y = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop;
    return new Element.Offset(x, y);
  }
  document.viewport = {
    getDimensions: getDimensions,
    getWidth: getWidth,
    getHeight: getHeight,
    getScrollOffsets: getScrollOffsets
  };
})();
window.$$ = function () {
  var expression = $A(arguments).join(', ');
  return Prototype.Selector.select(expression, document);
};
Prototype.Selector = function () {
  function select() {
    throw new Error('Method "Prototype.Selector.select" must be defined.');
  }
  function match() {
    throw new Error('Method "Prototype.Selector.match" must be defined.');
  }
  function find(elements, expression, index) {
    index = index || 0;
    var match = Prototype.Selector.match,
      length = elements.length,
      matchIndex = 0,
      i;
    for (i = 0; i < length; i++) {
      if (match(elements[i], expression) && index == matchIndex++) {
        return Element.extend(elements[i]);
      }
    }
  }
  function extendElements(elements) {
    for (var i = 0, length = elements.length; i < length; i++) {
      Element.extend(elements[i]);
    }
    return elements;
  }
  var K = Prototype.K;
  return {
    select: select,
    match: match,
    find: find,
    extendElements: Element.extend === K ? K : extendElements,
    extendElement: Element.extend
  };
}();
Prototype._original_property = window.Sizzle;
;
(function () {
  function fakeDefine(fn) {
    Prototype._actual_sizzle = fn();
  }
  fakeDefine.amd = true;
  if (typeof define !== 'undefined' && define.amd) {
    Prototype._original_define = define;
    Prototype._actual_sizzle = null;
    window.define = fakeDefine;
  }
})();

/*!
 * Sizzle CSS Selector Engine v1.10.18
 * http://sizzlejs.com/
 *
 * Copyright 2013 jQuery Foundation, Inc. and other contributors
 * Released under the MIT license
 * http://jquery.org/license
 *
 * Date: 2014-02-05
 */
(function (window) {
  var i,
    support,
    Expr,
    getText,
    isXML,
    compile,
    select,
    outermostContext,
    sortInput,
    hasDuplicate,
    setDocument,
    document,
    docElem,
    documentIsHTML,
    rbuggyQSA,
    rbuggyMatches,
    matches,
    contains,
    expando = "sizzle" + -new Date(),
    preferredDoc = window.document,
    dirruns = 0,
    done = 0,
    classCache = createCache(),
    tokenCache = createCache(),
    compilerCache = createCache(),
    sortOrder = function (a, b) {
      if (a === b) {
        hasDuplicate = true;
      }
      return 0;
    },
    strundefined = typeof undefined,
    MAX_NEGATIVE = 1 << 31,
    hasOwn = {}.hasOwnProperty,
    arr = [],
    pop = arr.pop,
    push_native = arr.push,
    push = arr.push,
    slice = arr.slice,
    indexOf = arr.indexOf || function (elem) {
      var i = 0,
        len = this.length;
      for (; i < len; i++) {
        if (this[i] === elem) {
          return i;
        }
      }
      return -1;
    },
    booleans = "checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped",
    whitespace = "[\\x20\\t\\r\\n\\f]",
    characterEncoding = "(?:\\\\.|[\\w-]|[^\\x00-\\xa0])+",
    identifier = characterEncoding.replace("w", "w#"),
    attributes = "\\[" + whitespace + "*(" + characterEncoding + ")" + whitespace + "*(?:([*^$|!~]?=)" + whitespace + "*(?:(['\"])((?:\\\\.|[^\\\\])*?)\\3|(" + identifier + ")|)|)" + whitespace + "*\\]",
    pseudos = ":(" + characterEncoding + ")(?:\\(((['\"])((?:\\\\.|[^\\\\])*?)\\3|((?:\\\\.|[^\\\\()[\\]]|" + attributes.replace(3, 8) + ")*)|.*)\\)|)",
    rtrim = new RegExp("^" + whitespace + "+|((?:^|[^\\\\])(?:\\\\.)*)" + whitespace + "+$", "g"),
    rcomma = new RegExp("^" + whitespace + "*," + whitespace + "*"),
    rcombinators = new RegExp("^" + whitespace + "*([>+~]|" + whitespace + ")" + whitespace + "*"),
    rattributeQuotes = new RegExp("=" + whitespace + "*([^\\]'\"]*?)" + whitespace + "*\\]", "g"),
    rpseudo = new RegExp(pseudos),
    ridentifier = new RegExp("^" + identifier + "$"),
    matchExpr = {
      "ID": new RegExp("^#(" + characterEncoding + ")"),
      "CLASS": new RegExp("^\\.(" + characterEncoding + ")"),
      "TAG": new RegExp("^(" + characterEncoding.replace("w", "w*") + ")"),
      "ATTR": new RegExp("^" + attributes),
      "PSEUDO": new RegExp("^" + pseudos),
      "CHILD": new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\(" + whitespace + "*(even|odd|(([+-]|)(\\d*)n|)" + whitespace + "*(?:([+-]|)" + whitespace + "*(\\d+)|))" + whitespace + "*\\)|)", "i"),
      "bool": new RegExp("^(?:" + booleans + ")$", "i"),
      "needsContext": new RegExp("^" + whitespace + "*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\(" + whitespace + "*((?:-\\d)?\\d*)" + whitespace + "*\\)|)(?=[^-]|$)", "i")
    },
    rinputs = /^(?:input|select|textarea|button)$/i,
    rheader = /^h\d$/i,
    rnative = /^[^{]+\{\s*\[native \w/,
    rquickExpr = /^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,
    rsibling = /[+~]/,
    rescape = /'|\\/g,
    runescape = new RegExp("\\\\([\\da-f]{1,6}" + whitespace + "?|(" + whitespace + ")|.)", "ig"),
    funescape = function (_, escaped, escapedWhitespace) {
      var high = "0x" + escaped - 0x10000;
      return high !== high || escapedWhitespace ? escaped : high < 0 ? String.fromCharCode(high + 0x10000) : String.fromCharCode(high >> 10 | 0xD800, high & 0x3FF | 0xDC00);
    };
  try {
    push.apply(arr = slice.call(preferredDoc.childNodes), preferredDoc.childNodes);
    arr[preferredDoc.childNodes.length].nodeType;
  } catch (e) {
    push = {
      apply: arr.length ? function (target, els) {
        push_native.apply(target, slice.call(els));
      } : function (target, els) {
        var j = target.length,
          i = 0;
        while (target[j++] = els[i++]) {}
        target.length = j - 1;
      }
    };
  }
  function Sizzle(selector, context, results, seed) {
    var match, elem, m, nodeType, i, groups, old, nid, newContext, newSelector;
    if ((context ? context.ownerDocument || context : preferredDoc) !== document) {
      setDocument(context);
    }
    context = context || document;
    results = results || [];
    if (!selector || typeof selector !== "string") {
      return results;
    }
    if ((nodeType = context.nodeType) !== 1 && nodeType !== 9) {
      return [];
    }
    if (documentIsHTML && !seed) {
      if (match = rquickExpr.exec(selector)) {
        if (m = match[1]) {
          if (nodeType === 9) {
            elem = context.getElementById(m);
            if (elem && elem.parentNode) {
              if (elem.id === m) {
                results.push(elem);
                return results;
              }
            } else {
              return results;
            }
          } else {
            if (context.ownerDocument && (elem = context.ownerDocument.getElementById(m)) && contains(context, elem) && elem.id === m) {
              results.push(elem);
              return results;
            }
          }
        } else if (match[2]) {
          push.apply(results, context.getElementsByTagName(selector));
          return results;
        } else if ((m = match[3]) && support.getElementsByClassName && context.getElementsByClassName) {
          push.apply(results, context.getElementsByClassName(m));
          return results;
        }
      }
      if (support.qsa && (!rbuggyQSA || !rbuggyQSA.test(selector))) {
        nid = old = expando;
        newContext = context;
        newSelector = nodeType === 9 && selector;
        if (nodeType === 1 && context.nodeName.toLowerCase() !== "object") {
          groups = tokenize(selector);
          if (old = context.getAttribute("id")) {
            nid = old.replace(rescape, "\\$&");
          } else {
            context.setAttribute("id", nid);
          }
          nid = "[id='" + nid + "'] ";
          i = groups.length;
          while (i--) {
            groups[i] = nid + toSelector(groups[i]);
          }
          newContext = rsibling.test(selector) && testContext(context.parentNode) || context;
          newSelector = groups.join(",");
        }
        if (newSelector) {
          try {
            push.apply(results, newContext.querySelectorAll(newSelector));
            return results;
          } catch (qsaError) {} finally {
            if (!old) {
              context.removeAttribute("id");
            }
          }
        }
      }
    }
    return select(selector.replace(rtrim, "$1"), context, results, seed);
  }

  /**
   * Create key-value caches of limited size
   * @returns {Function(string, Object)} Returns the Object data after storing it on itself with
   *	property name the (space-suffixed) string and (if the cache is larger than Expr.cacheLength)
   *	deleting the oldest entry
   */
  function createCache() {
    var keys = [];
    function cache(key, value) {
      if (keys.push(key + " ") > Expr.cacheLength) {
        delete cache[keys.shift()];
      }
      return cache[key + " "] = value;
    }
    return cache;
  }

  /**
   * Mark a function for special use by Sizzle
   * @param {Function} fn The function to mark
   */
  function markFunction(fn) {
    fn[expando] = true;
    return fn;
  }

  /**
   * Support testing using an element
   * @param {Function} fn Passed the created div and expects a boolean result
   */
  function assert(fn) {
    var div = document.createElement("div");
    try {
      return !!fn(div);
    } catch (e) {
      return false;
    } finally {
      if (div.parentNode) {
        div.parentNode.removeChild(div);
      }
      div = null;
    }
  }

  /**
   * Adds the same handler for all of the specified attrs
   * @param {String} attrs Pipe-separated list of attributes
   * @param {Function} handler The method that will be applied
   */
  function addHandle(attrs, handler) {
    var arr = attrs.split("|"),
      i = attrs.length;
    while (i--) {
      Expr.attrHandle[arr[i]] = handler;
    }
  }

  /**
   * Checks document order of two siblings
   * @param {Element} a
   * @param {Element} b
   * @returns {Number} Returns less than 0 if a precedes b, greater than 0 if a follows b
   */
  function siblingCheck(a, b) {
    var cur = b && a,
      diff = cur && a.nodeType === 1 && b.nodeType === 1 && (~b.sourceIndex || MAX_NEGATIVE) - (~a.sourceIndex || MAX_NEGATIVE);
    if (diff) {
      return diff;
    }
    if (cur) {
      while (cur = cur.nextSibling) {
        if (cur === b) {
          return -1;
        }
      }
    }
    return a ? 1 : -1;
  }

  /**
   * Returns a function to use in pseudos for input types
   * @param {String} type
   */
  function createInputPseudo(type) {
    return function (elem) {
      var name = elem.nodeName.toLowerCase();
      return name === "input" && elem.type === type;
    };
  }

  /**
   * Returns a function to use in pseudos for buttons
   * @param {String} type
   */
  function createButtonPseudo(type) {
    return function (elem) {
      var name = elem.nodeName.toLowerCase();
      return (name === "input" || name === "button") && elem.type === type;
    };
  }

  /**
   * Returns a function to use in pseudos for positionals
   * @param {Function} fn
   */
  function createPositionalPseudo(fn) {
    return markFunction(function (argument) {
      argument = +argument;
      return markFunction(function (seed, matches) {
        var j,
          matchIndexes = fn([], seed.length, argument),
          i = matchIndexes.length;
        while (i--) {
          if (seed[j = matchIndexes[i]]) {
            seed[j] = !(matches[j] = seed[j]);
          }
        }
      });
    });
  }

  /**
   * Checks a node for validity as a Sizzle context
   * @param {Element|Object=} context
   * @returns {Element|Object|Boolean} The input node if acceptable, otherwise a falsy value
   */
  function testContext(context) {
    return context && typeof context.getElementsByTagName !== strundefined && context;
  }
  support = Sizzle.support = {};

  /**
   * Detects XML nodes
   * @param {Element|Object} elem An element or a document
   * @returns {Boolean} True iff elem is a non-HTML XML node
   */
  isXML = Sizzle.isXML = function (elem) {
    var documentElement = elem && (elem.ownerDocument || elem).documentElement;
    return documentElement ? documentElement.nodeName !== "HTML" : false;
  };

  /**
   * Sets document-related variables once based on the current document
   * @param {Element|Object} [doc] An element or document object to use to set the document
   * @returns {Object} Returns the current document
   */
  setDocument = Sizzle.setDocument = function (node) {
    var hasCompare,
      doc = node ? node.ownerDocument || node : preferredDoc,
      parent = doc.defaultView;
    if (doc === document || doc.nodeType !== 9 || !doc.documentElement) {
      return document;
    }
    document = doc;
    docElem = doc.documentElement;
    documentIsHTML = !isXML(doc);
    if (parent && parent !== parent.top) {
      if (parent.addEventListener) {
        parent.addEventListener("unload", function () {
          setDocument();
        }, false);
      } else if (parent.attachEvent) {
        parent.attachEvent("onunload", function () {
          setDocument();
        });
      }
    }

    /* Attributes
    ---------------------------------------------------------------------- */

    support.attributes = assert(function (div) {
      div.className = "i";
      return !div.getAttribute("className");
    });

    /* getElement(s)By*
    ---------------------------------------------------------------------- */

    support.getElementsByTagName = assert(function (div) {
      div.appendChild(doc.createComment(""));
      return !div.getElementsByTagName("*").length;
    });
    support.getElementsByClassName = rnative.test(doc.getElementsByClassName) && assert(function (div) {
      div.innerHTML = "<div class='a'></div><div class='a i'></div>";
      div.firstChild.className = "i";
      return div.getElementsByClassName("i").length === 2;
    });
    support.getById = assert(function (div) {
      docElem.appendChild(div).id = expando;
      return !doc.getElementsByName || !doc.getElementsByName(expando).length;
    });
    if (support.getById) {
      Expr.find["ID"] = function (id, context) {
        if (typeof context.getElementById !== strundefined && documentIsHTML) {
          var m = context.getElementById(id);
          return m && m.parentNode ? [m] : [];
        }
      };
      Expr.filter["ID"] = function (id) {
        var attrId = id.replace(runescape, funescape);
        return function (elem) {
          return elem.getAttribute("id") === attrId;
        };
      };
    } else {
      delete Expr.find["ID"];
      Expr.filter["ID"] = function (id) {
        var attrId = id.replace(runescape, funescape);
        return function (elem) {
          var node = typeof elem.getAttributeNode !== strundefined && elem.getAttributeNode("id");
          return node && node.value === attrId;
        };
      };
    }
    Expr.find["TAG"] = support.getElementsByTagName ? function (tag, context) {
      if (typeof context.getElementsByTagName !== strundefined) {
        return context.getElementsByTagName(tag);
      }
    } : function (tag, context) {
      var elem,
        tmp = [],
        i = 0,
        results = context.getElementsByTagName(tag);
      if (tag === "*") {
        while (elem = results[i++]) {
          if (elem.nodeType === 1) {
            tmp.push(elem);
          }
        }
        return tmp;
      }
      return results;
    };
    Expr.find["CLASS"] = support.getElementsByClassName && function (className, context) {
      if (typeof context.getElementsByClassName !== strundefined && documentIsHTML) {
        return context.getElementsByClassName(className);
      }
    };

    /* QSA/matchesSelector
    ---------------------------------------------------------------------- */

    rbuggyMatches = [];
    rbuggyQSA = [];
    if (support.qsa = rnative.test(doc.querySelectorAll)) {
      assert(function (div) {
        div.innerHTML = "<select t=''><option selected=''></option></select>";
        if (div.querySelectorAll("[t^='']").length) {
          rbuggyQSA.push("[*^$]=" + whitespace + "*(?:''|\"\")");
        }
        if (!div.querySelectorAll("[selected]").length) {
          rbuggyQSA.push("\\[" + whitespace + "*(?:value|" + booleans + ")");
        }
        if (!div.querySelectorAll(":checked").length) {
          rbuggyQSA.push(":checked");
        }
      });
      assert(function (div) {
        var input = doc.createElement("input");
        input.setAttribute("type", "hidden");
        div.appendChild(input).setAttribute("name", "D");
        if (div.querySelectorAll("[name=d]").length) {
          rbuggyQSA.push("name" + whitespace + "*[*^$|!~]?=");
        }
        if (!div.querySelectorAll(":enabled").length) {
          rbuggyQSA.push(":enabled", ":disabled");
        }
        div.querySelectorAll("*,:x");
        rbuggyQSA.push(",.*:");
      });
    }
    if (support.matchesSelector = rnative.test(matches = docElem.webkitMatchesSelector || docElem.mozMatchesSelector || docElem.oMatchesSelector || docElem.msMatchesSelector)) {
      assert(function (div) {
        support.disconnectedMatch = matches.call(div, "div");
        matches.call(div, "[s!='']:x");
        rbuggyMatches.push("!=", pseudos);
      });
    }
    rbuggyQSA = rbuggyQSA.length && new RegExp(rbuggyQSA.join("|"));
    rbuggyMatches = rbuggyMatches.length && new RegExp(rbuggyMatches.join("|"));

    /* Contains
    ---------------------------------------------------------------------- */
    hasCompare = rnative.test(docElem.compareDocumentPosition);
    contains = hasCompare || rnative.test(docElem.contains) ? function (a, b) {
      var adown = a.nodeType === 9 ? a.documentElement : a,
        bup = b && b.parentNode;
      return a === bup || !!(bup && bup.nodeType === 1 && (adown.contains ? adown.contains(bup) : a.compareDocumentPosition && a.compareDocumentPosition(bup) & 16));
    } : function (a, b) {
      if (b) {
        while (b = b.parentNode) {
          if (b === a) {
            return true;
          }
        }
      }
      return false;
    };

    /* Sorting
    ---------------------------------------------------------------------- */

    sortOrder = hasCompare ? function (a, b) {
      if (a === b) {
        hasDuplicate = true;
        return 0;
      }
      var compare = !a.compareDocumentPosition - !b.compareDocumentPosition;
      if (compare) {
        return compare;
      }
      compare = (a.ownerDocument || a) === (b.ownerDocument || b) ? a.compareDocumentPosition(b) : 1;
      if (compare & 1 || !support.sortDetached && b.compareDocumentPosition(a) === compare) {
        if (a === doc || a.ownerDocument === preferredDoc && contains(preferredDoc, a)) {
          return -1;
        }
        if (b === doc || b.ownerDocument === preferredDoc && contains(preferredDoc, b)) {
          return 1;
        }
        return sortInput ? indexOf.call(sortInput, a) - indexOf.call(sortInput, b) : 0;
      }
      return compare & 4 ? -1 : 1;
    } : function (a, b) {
      if (a === b) {
        hasDuplicate = true;
        return 0;
      }
      var cur,
        i = 0,
        aup = a.parentNode,
        bup = b.parentNode,
        ap = [a],
        bp = [b];
      if (!aup || !bup) {
        return a === doc ? -1 : b === doc ? 1 : aup ? -1 : bup ? 1 : sortInput ? indexOf.call(sortInput, a) - indexOf.call(sortInput, b) : 0;
      } else if (aup === bup) {
        return siblingCheck(a, b);
      }
      cur = a;
      while (cur = cur.parentNode) {
        ap.unshift(cur);
      }
      cur = b;
      while (cur = cur.parentNode) {
        bp.unshift(cur);
      }
      while (ap[i] === bp[i]) {
        i++;
      }
      return i ? siblingCheck(ap[i], bp[i]) : ap[i] === preferredDoc ? -1 : bp[i] === preferredDoc ? 1 : 0;
    };
    return doc;
  };
  Sizzle.matches = function (expr, elements) {
    return Sizzle(expr, null, null, elements);
  };
  Sizzle.matchesSelector = function (elem, expr) {
    if ((elem.ownerDocument || elem) !== document) {
      setDocument(elem);
    }
    expr = expr.replace(rattributeQuotes, "='$1']");
    if (support.matchesSelector && documentIsHTML && (!rbuggyMatches || !rbuggyMatches.test(expr)) && (!rbuggyQSA || !rbuggyQSA.test(expr))) {
      try {
        var ret = matches.call(elem, expr);
        if (ret || support.disconnectedMatch || elem.document && elem.document.nodeType !== 11) {
          return ret;
        }
      } catch (e) {}
    }
    return Sizzle(expr, document, null, [elem]).length > 0;
  };
  Sizzle.contains = function (context, elem) {
    if ((context.ownerDocument || context) !== document) {
      setDocument(context);
    }
    return contains(context, elem);
  };
  Sizzle.attr = function (elem, name) {
    if ((elem.ownerDocument || elem) !== document) {
      setDocument(elem);
    }
    var fn = Expr.attrHandle[name.toLowerCase()],
      val = fn && hasOwn.call(Expr.attrHandle, name.toLowerCase()) ? fn(elem, name, !documentIsHTML) : undefined;
    return val !== undefined ? val : support.attributes || !documentIsHTML ? elem.getAttribute(name) : (val = elem.getAttributeNode(name)) && val.specified ? val.value : null;
  };
  Sizzle.error = function (msg) {
    throw new Error("Syntax error, unrecognized expression: " + msg);
  };

  /**
   * Document sorting and removing duplicates
   * @param {ArrayLike} results
   */
  Sizzle.uniqueSort = function (results) {
    var elem,
      duplicates = [],
      j = 0,
      i = 0;
    hasDuplicate = !support.detectDuplicates;
    sortInput = !support.sortStable && results.slice(0);
    results.sort(sortOrder);
    if (hasDuplicate) {
      while (elem = results[i++]) {
        if (elem === results[i]) {
          j = duplicates.push(i);
        }
      }
      while (j--) {
        results.splice(duplicates[j], 1);
      }
    }
    sortInput = null;
    return results;
  };

  /**
   * Utility function for retrieving the text value of an array of DOM nodes
   * @param {Array|Element} elem
   */
  getText = Sizzle.getText = function (elem) {
    var node,
      ret = "",
      i = 0,
      nodeType = elem.nodeType;
    if (!nodeType) {
      while (node = elem[i++]) {
        ret += getText(node);
      }
    } else if (nodeType === 1 || nodeType === 9 || nodeType === 11) {
      if (typeof elem.textContent === "string") {
        return elem.textContent;
      } else {
        for (elem = elem.firstChild; elem; elem = elem.nextSibling) {
          ret += getText(elem);
        }
      }
    } else if (nodeType === 3 || nodeType === 4) {
      return elem.nodeValue;
    }
    return ret;
  };
  Expr = Sizzle.selectors = {
    cacheLength: 50,
    createPseudo: markFunction,
    match: matchExpr,
    attrHandle: {},
    find: {},
    relative: {
      ">": {
        dir: "parentNode",
        first: true
      },
      " ": {
        dir: "parentNode"
      },
      "+": {
        dir: "previousSibling",
        first: true
      },
      "~": {
        dir: "previousSibling"
      }
    },
    preFilter: {
      "ATTR": function (match) {
        match[1] = match[1].replace(runescape, funescape);
        match[3] = (match[4] || match[5] || "").replace(runescape, funescape);
        if (match[2] === "~=") {
          match[3] = " " + match[3] + " ";
        }
        return match.slice(0, 4);
      },
      "CHILD": function (match) {
        /* matches from matchExpr["CHILD"]
        	1 type (only|nth|...)
        	2 what (child|of-type)
        	3 argument (even|odd|\d*|\d*n([+-]\d+)?|...)
        	4 xn-component of xn+y argument ([+-]?\d*n|)
        	5 sign of xn-component
        	6 x of xn-component
        	7 sign of y-component
        	8 y of y-component
        */
        match[1] = match[1].toLowerCase();
        if (match[1].slice(0, 3) === "nth") {
          if (!match[3]) {
            Sizzle.error(match[0]);
          }
          match[4] = +(match[4] ? match[5] + (match[6] || 1) : 2 * (match[3] === "even" || match[3] === "odd"));
          match[5] = +(match[7] + match[8] || match[3] === "odd");
        } else if (match[3]) {
          Sizzle.error(match[0]);
        }
        return match;
      },
      "PSEUDO": function (match) {
        var excess,
          unquoted = !match[5] && match[2];
        if (matchExpr["CHILD"].test(match[0])) {
          return null;
        }
        if (match[3] && match[4] !== undefined) {
          match[2] = match[4];
        } else if (unquoted && rpseudo.test(unquoted) && (excess = tokenize(unquoted, true)) && (excess = unquoted.indexOf(")", unquoted.length - excess) - unquoted.length)) {
          match[0] = match[0].slice(0, excess);
          match[2] = unquoted.slice(0, excess);
        }
        return match.slice(0, 3);
      }
    },
    filter: {
      "TAG": function (nodeNameSelector) {
        var nodeName = nodeNameSelector.replace(runescape, funescape).toLowerCase();
        return nodeNameSelector === "*" ? function () {
          return true;
        } : function (elem) {
          return elem.nodeName && elem.nodeName.toLowerCase() === nodeName;
        };
      },
      "CLASS": function (className) {
        var pattern = classCache[className + " "];
        return pattern || (pattern = new RegExp("(^|" + whitespace + ")" + className + "(" + whitespace + "|$)")) && classCache(className, function (elem) {
          return pattern.test(typeof elem.className === "string" && elem.className || typeof elem.getAttribute !== strundefined && elem.getAttribute("class") || "");
        });
      },
      "ATTR": function (name, operator, check) {
        return function (elem) {
          var result = Sizzle.attr(elem, name);
          if (result == null) {
            return operator === "!=";
          }
          if (!operator) {
            return true;
          }
          result += "";
          return operator === "=" ? result === check : operator === "!=" ? result !== check : operator === "^=" ? check && result.indexOf(check) === 0 : operator === "*=" ? check && result.indexOf(check) > -1 : operator === "$=" ? check && result.slice(-check.length) === check : operator === "~=" ? (" " + result + " ").indexOf(check) > -1 : operator === "|=" ? result === check || result.slice(0, check.length + 1) === check + "-" : false;
        };
      },
      "CHILD": function (type, what, argument, first, last) {
        var simple = type.slice(0, 3) !== "nth",
          forward = type.slice(-4) !== "last",
          ofType = what === "of-type";
        return first === 1 && last === 0 ? function (elem) {
          return !!elem.parentNode;
        } : function (elem, context, xml) {
          var cache,
            outerCache,
            node,
            diff,
            nodeIndex,
            start,
            dir = simple !== forward ? "nextSibling" : "previousSibling",
            parent = elem.parentNode,
            name = ofType && elem.nodeName.toLowerCase(),
            useCache = !xml && !ofType;
          if (parent) {
            if (simple) {
              while (dir) {
                node = elem;
                while (node = node[dir]) {
                  if (ofType ? node.nodeName.toLowerCase() === name : node.nodeType === 1) {
                    return false;
                  }
                }
                start = dir = type === "only" && !start && "nextSibling";
              }
              return true;
            }
            start = [forward ? parent.firstChild : parent.lastChild];
            if (forward && useCache) {
              outerCache = parent[expando] || (parent[expando] = {});
              cache = outerCache[type] || [];
              nodeIndex = cache[0] === dirruns && cache[1];
              diff = cache[0] === dirruns && cache[2];
              node = nodeIndex && parent.childNodes[nodeIndex];
              while (node = ++nodeIndex && node && node[dir] || (diff = nodeIndex = 0) || start.pop()) {
                if (node.nodeType === 1 && ++diff && node === elem) {
                  outerCache[type] = [dirruns, nodeIndex, diff];
                  break;
                }
              }
            } else if (useCache && (cache = (elem[expando] || (elem[expando] = {}))[type]) && cache[0] === dirruns) {
              diff = cache[1];
            } else {
              while (node = ++nodeIndex && node && node[dir] || (diff = nodeIndex = 0) || start.pop()) {
                if ((ofType ? node.nodeName.toLowerCase() === name : node.nodeType === 1) && ++diff) {
                  if (useCache) {
                    (node[expando] || (node[expando] = {}))[type] = [dirruns, diff];
                  }
                  if (node === elem) {
                    break;
                  }
                }
              }
            }
            diff -= last;
            return diff === first || diff % first === 0 && diff / first >= 0;
          }
        };
      },
      "PSEUDO": function (pseudo, argument) {
        var args,
          fn = Expr.pseudos[pseudo] || Expr.setFilters[pseudo.toLowerCase()] || Sizzle.error("unsupported pseudo: " + pseudo);
        if (fn[expando]) {
          return fn(argument);
        }
        if (fn.length > 1) {
          args = [pseudo, pseudo, "", argument];
          return Expr.setFilters.hasOwnProperty(pseudo.toLowerCase()) ? markFunction(function (seed, matches) {
            var idx,
              matched = fn(seed, argument),
              i = matched.length;
            while (i--) {
              idx = indexOf.call(seed, matched[i]);
              seed[idx] = !(matches[idx] = matched[i]);
            }
          }) : function (elem) {
            return fn(elem, 0, args);
          };
        }
        return fn;
      }
    },
    pseudos: {
      "not": markFunction(function (selector) {
        var input = [],
          results = [],
          matcher = compile(selector.replace(rtrim, "$1"));
        return matcher[expando] ? markFunction(function (seed, matches, context, xml) {
          var elem,
            unmatched = matcher(seed, null, xml, []),
            i = seed.length;
          while (i--) {
            if (elem = unmatched[i]) {
              seed[i] = !(matches[i] = elem);
            }
          }
        }) : function (elem, context, xml) {
          input[0] = elem;
          matcher(input, null, xml, results);
          return !results.pop();
        };
      }),
      "has": markFunction(function (selector) {
        return function (elem) {
          return Sizzle(selector, elem).length > 0;
        };
      }),
      "contains": markFunction(function (text) {
        return function (elem) {
          return (elem.textContent || elem.innerText || getText(elem)).indexOf(text) > -1;
        };
      }),
      "lang": markFunction(function (lang) {
        if (!ridentifier.test(lang || "")) {
          Sizzle.error("unsupported lang: " + lang);
        }
        lang = lang.replace(runescape, funescape).toLowerCase();
        return function (elem) {
          var elemLang;
          do {
            if (elemLang = documentIsHTML ? elem.lang : elem.getAttribute("xml:lang") || elem.getAttribute("lang")) {
              elemLang = elemLang.toLowerCase();
              return elemLang === lang || elemLang.indexOf(lang + "-") === 0;
            }
          } while ((elem = elem.parentNode) && elem.nodeType === 1);
          return false;
        };
      }),
      "target": function (elem) {
        var hash = window.location && window.location.hash;
        return hash && hash.slice(1) === elem.id;
      },
      "root": function (elem) {
        return elem === docElem;
      },
      "focus": function (elem) {
        return elem === document.activeElement && (!document.hasFocus || document.hasFocus()) && !!(elem.type || elem.href || ~elem.tabIndex);
      },
      "enabled": function (elem) {
        return elem.disabled === false;
      },
      "disabled": function (elem) {
        return elem.disabled === true;
      },
      "checked": function (elem) {
        var nodeName = elem.nodeName.toLowerCase();
        return nodeName === "input" && !!elem.checked || nodeName === "option" && !!elem.selected;
      },
      "selected": function (elem) {
        if (elem.parentNode) {
          elem.parentNode.selectedIndex;
        }
        return elem.selected === true;
      },
      "empty": function (elem) {
        for (elem = elem.firstChild; elem; elem = elem.nextSibling) {
          if (elem.nodeType < 6) {
            return false;
          }
        }
        return true;
      },
      "parent": function (elem) {
        return !Expr.pseudos["empty"](elem);
      },
      "header": function (elem) {
        return rheader.test(elem.nodeName);
      },
      "input": function (elem) {
        return rinputs.test(elem.nodeName);
      },
      "button": function (elem) {
        var name = elem.nodeName.toLowerCase();
        return name === "input" && elem.type === "button" || name === "button";
      },
      "text": function (elem) {
        var attr;
        return elem.nodeName.toLowerCase() === "input" && elem.type === "text" && ((attr = elem.getAttribute("type")) == null || attr.toLowerCase() === "text");
      },
      "first": createPositionalPseudo(function () {
        return [0];
      }),
      "last": createPositionalPseudo(function (matchIndexes, length) {
        return [length - 1];
      }),
      "eq": createPositionalPseudo(function (matchIndexes, length, argument) {
        return [argument < 0 ? argument + length : argument];
      }),
      "even": createPositionalPseudo(function (matchIndexes, length) {
        var i = 0;
        for (; i < length; i += 2) {
          matchIndexes.push(i);
        }
        return matchIndexes;
      }),
      "odd": createPositionalPseudo(function (matchIndexes, length) {
        var i = 1;
        for (; i < length; i += 2) {
          matchIndexes.push(i);
        }
        return matchIndexes;
      }),
      "lt": createPositionalPseudo(function (matchIndexes, length, argument) {
        var i = argument < 0 ? argument + length : argument;
        for (; --i >= 0;) {
          matchIndexes.push(i);
        }
        return matchIndexes;
      }),
      "gt": createPositionalPseudo(function (matchIndexes, length, argument) {
        var i = argument < 0 ? argument + length : argument;
        for (; ++i < length;) {
          matchIndexes.push(i);
        }
        return matchIndexes;
      })
    }
  };
  Expr.pseudos["nth"] = Expr.pseudos["eq"];
  for (i in {
    radio: true,
    checkbox: true,
    file: true,
    password: true,
    image: true
  }) {
    Expr.pseudos[i] = createInputPseudo(i);
  }
  for (i in {
    submit: true,
    reset: true
  }) {
    Expr.pseudos[i] = createButtonPseudo(i);
  }
  function setFilters() {}
  setFilters.prototype = Expr.filters = Expr.pseudos;
  Expr.setFilters = new setFilters();
  function tokenize(selector, parseOnly) {
    var matched,
      match,
      tokens,
      type,
      soFar,
      groups,
      preFilters,
      cached = tokenCache[selector + " "];
    if (cached) {
      return parseOnly ? 0 : cached.slice(0);
    }
    soFar = selector;
    groups = [];
    preFilters = Expr.preFilter;
    while (soFar) {
      if (!matched || (match = rcomma.exec(soFar))) {
        if (match) {
          soFar = soFar.slice(match[0].length) || soFar;
        }
        groups.push(tokens = []);
      }
      matched = false;
      if (match = rcombinators.exec(soFar)) {
        matched = match.shift();
        tokens.push({
          value: matched,
          type: match[0].replace(rtrim, " ")
        });
        soFar = soFar.slice(matched.length);
      }
      for (type in Expr.filter) {
        if ((match = matchExpr[type].exec(soFar)) && (!preFilters[type] || (match = preFilters[type](match)))) {
          matched = match.shift();
          tokens.push({
            value: matched,
            type: type,
            matches: match
          });
          soFar = soFar.slice(matched.length);
        }
      }
      if (!matched) {
        break;
      }
    }
    return parseOnly ? soFar.length : soFar ? Sizzle.error(selector) : tokenCache(selector, groups).slice(0);
  }
  function toSelector(tokens) {
    var i = 0,
      len = tokens.length,
      selector = "";
    for (; i < len; i++) {
      selector += tokens[i].value;
    }
    return selector;
  }
  function addCombinator(matcher, combinator, base) {
    var dir = combinator.dir,
      checkNonElements = base && dir === "parentNode",
      doneName = done++;
    return combinator.first ? function (elem, context, xml) {
      while (elem = elem[dir]) {
        if (elem.nodeType === 1 || checkNonElements) {
          return matcher(elem, context, xml);
        }
      }
    } : function (elem, context, xml) {
      var oldCache,
        outerCache,
        newCache = [dirruns, doneName];
      if (xml) {
        while (elem = elem[dir]) {
          if (elem.nodeType === 1 || checkNonElements) {
            if (matcher(elem, context, xml)) {
              return true;
            }
          }
        }
      } else {
        while (elem = elem[dir]) {
          if (elem.nodeType === 1 || checkNonElements) {
            outerCache = elem[expando] || (elem[expando] = {});
            if ((oldCache = outerCache[dir]) && oldCache[0] === dirruns && oldCache[1] === doneName) {
              return newCache[2] = oldCache[2];
            } else {
              outerCache[dir] = newCache;
              if (newCache[2] = matcher(elem, context, xml)) {
                return true;
              }
            }
          }
        }
      }
    };
  }
  function elementMatcher(matchers) {
    return matchers.length > 1 ? function (elem, context, xml) {
      var i = matchers.length;
      while (i--) {
        if (!matchers[i](elem, context, xml)) {
          return false;
        }
      }
      return true;
    } : matchers[0];
  }
  function multipleContexts(selector, contexts, results) {
    var i = 0,
      len = contexts.length;
    for (; i < len; i++) {
      Sizzle(selector, contexts[i], results);
    }
    return results;
  }
  function condense(unmatched, map, filter, context, xml) {
    var elem,
      newUnmatched = [],
      i = 0,
      len = unmatched.length,
      mapped = map != null;
    for (; i < len; i++) {
      if (elem = unmatched[i]) {
        if (!filter || filter(elem, context, xml)) {
          newUnmatched.push(elem);
          if (mapped) {
            map.push(i);
          }
        }
      }
    }
    return newUnmatched;
  }
  function setMatcher(preFilter, selector, matcher, postFilter, postFinder, postSelector) {
    if (postFilter && !postFilter[expando]) {
      postFilter = setMatcher(postFilter);
    }
    if (postFinder && !postFinder[expando]) {
      postFinder = setMatcher(postFinder, postSelector);
    }
    return markFunction(function (seed, results, context, xml) {
      var temp,
        i,
        elem,
        preMap = [],
        postMap = [],
        preexisting = results.length,
        elems = seed || multipleContexts(selector || "*", context.nodeType ? [context] : context, []),
        matcherIn = preFilter && (seed || !selector) ? condense(elems, preMap, preFilter, context, xml) : elems,
        matcherOut = matcher ? postFinder || (seed ? preFilter : preexisting || postFilter) ? [] : results : matcherIn;
      if (matcher) {
        matcher(matcherIn, matcherOut, context, xml);
      }
      if (postFilter) {
        temp = condense(matcherOut, postMap);
        postFilter(temp, [], context, xml);
        i = temp.length;
        while (i--) {
          if (elem = temp[i]) {
            matcherOut[postMap[i]] = !(matcherIn[postMap[i]] = elem);
          }
        }
      }
      if (seed) {
        if (postFinder || preFilter) {
          if (postFinder) {
            temp = [];
            i = matcherOut.length;
            while (i--) {
              if (elem = matcherOut[i]) {
                temp.push(matcherIn[i] = elem);
              }
            }
            postFinder(null, matcherOut = [], temp, xml);
          }
          i = matcherOut.length;
          while (i--) {
            if ((elem = matcherOut[i]) && (temp = postFinder ? indexOf.call(seed, elem) : preMap[i]) > -1) {
              seed[temp] = !(results[temp] = elem);
            }
          }
        }
      } else {
        matcherOut = condense(matcherOut === results ? matcherOut.splice(preexisting, matcherOut.length) : matcherOut);
        if (postFinder) {
          postFinder(null, results, matcherOut, xml);
        } else {
          push.apply(results, matcherOut);
        }
      }
    });
  }
  function matcherFromTokens(tokens) {
    var checkContext,
      matcher,
      j,
      len = tokens.length,
      leadingRelative = Expr.relative[tokens[0].type],
      implicitRelative = leadingRelative || Expr.relative[" "],
      i = leadingRelative ? 1 : 0,
      matchContext = addCombinator(function (elem) {
        return elem === checkContext;
      }, implicitRelative, true),
      matchAnyContext = addCombinator(function (elem) {
        return indexOf.call(checkContext, elem) > -1;
      }, implicitRelative, true),
      matchers = [function (elem, context, xml) {
        return !leadingRelative && (xml || context !== outermostContext) || ((checkContext = context).nodeType ? matchContext(elem, context, xml) : matchAnyContext(elem, context, xml));
      }];
    for (; i < len; i++) {
      if (matcher = Expr.relative[tokens[i].type]) {
        matchers = [addCombinator(elementMatcher(matchers), matcher)];
      } else {
        matcher = Expr.filter[tokens[i].type].apply(null, tokens[i].matches);
        if (matcher[expando]) {
          j = ++i;
          for (; j < len; j++) {
            if (Expr.relative[tokens[j].type]) {
              break;
            }
          }
          return setMatcher(i > 1 && elementMatcher(matchers), i > 1 && toSelector(tokens.slice(0, i - 1).concat({
            value: tokens[i - 2].type === " " ? "*" : ""
          })).replace(rtrim, "$1"), matcher, i < j && matcherFromTokens(tokens.slice(i, j)), j < len && matcherFromTokens(tokens = tokens.slice(j)), j < len && toSelector(tokens));
        }
        matchers.push(matcher);
      }
    }
    return elementMatcher(matchers);
  }
  function matcherFromGroupMatchers(elementMatchers, setMatchers) {
    var bySet = setMatchers.length > 0,
      byElement = elementMatchers.length > 0,
      superMatcher = function (seed, context, xml, results, outermost) {
        var elem,
          j,
          matcher,
          matchedCount = 0,
          i = "0",
          unmatched = seed && [],
          setMatched = [],
          contextBackup = outermostContext,
          elems = seed || byElement && Expr.find["TAG"]("*", outermost),
          dirrunsUnique = dirruns += contextBackup == null ? 1 : Math.random() || 0.1,
          len = elems.length;
        if (outermost) {
          outermostContext = context !== document && context;
        }
        for (; i !== len && (elem = elems[i]) != null; i++) {
          if (byElement && elem) {
            j = 0;
            while (matcher = elementMatchers[j++]) {
              if (matcher(elem, context, xml)) {
                results.push(elem);
                break;
              }
            }
            if (outermost) {
              dirruns = dirrunsUnique;
            }
          }
          if (bySet) {
            if (elem = !matcher && elem) {
              matchedCount--;
            }
            if (seed) {
              unmatched.push(elem);
            }
          }
        }
        matchedCount += i;
        if (bySet && i !== matchedCount) {
          j = 0;
          while (matcher = setMatchers[j++]) {
            matcher(unmatched, setMatched, context, xml);
          }
          if (seed) {
            if (matchedCount > 0) {
              while (i--) {
                if (!(unmatched[i] || setMatched[i])) {
                  setMatched[i] = pop.call(results);
                }
              }
            }
            setMatched = condense(setMatched);
          }
          push.apply(results, setMatched);
          if (outermost && !seed && setMatched.length > 0 && matchedCount + setMatchers.length > 1) {
            Sizzle.uniqueSort(results);
          }
        }
        if (outermost) {
          dirruns = dirrunsUnique;
          outermostContext = contextBackup;
        }
        return unmatched;
      };
    return bySet ? markFunction(superMatcher) : superMatcher;
  }
  compile = Sizzle.compile = function (selector, match /* Internal Use Only */) {
    var i,
      setMatchers = [],
      elementMatchers = [],
      cached = compilerCache[selector + " "];
    if (!cached) {
      if (!match) {
        match = tokenize(selector);
      }
      i = match.length;
      while (i--) {
        cached = matcherFromTokens(match[i]);
        if (cached[expando]) {
          setMatchers.push(cached);
        } else {
          elementMatchers.push(cached);
        }
      }
      cached = compilerCache(selector, matcherFromGroupMatchers(elementMatchers, setMatchers));
      cached.selector = selector;
    }
    return cached;
  };

  /**
   * A low-level selection function that works with Sizzle's compiled
   *  selector functions
   * @param {String|Function} selector A selector or a pre-compiled
   *  selector function built with Sizzle.compile
   * @param {Element} context
   * @param {Array} [results]
   * @param {Array} [seed] A set of elements to match against
   */
  select = Sizzle.select = function (selector, context, results, seed) {
    var i,
      tokens,
      token,
      type,
      find,
      compiled = typeof selector === "function" && selector,
      match = !seed && tokenize(selector = compiled.selector || selector);
    results = results || [];
    if (match.length === 1) {
      tokens = match[0] = match[0].slice(0);
      if (tokens.length > 2 && (token = tokens[0]).type === "ID" && support.getById && context.nodeType === 9 && documentIsHTML && Expr.relative[tokens[1].type]) {
        context = (Expr.find["ID"](token.matches[0].replace(runescape, funescape), context) || [])[0];
        if (!context) {
          return results;
        } else if (compiled) {
          context = context.parentNode;
        }
        selector = selector.slice(tokens.shift().value.length);
      }
      i = matchExpr["needsContext"].test(selector) ? 0 : tokens.length;
      while (i--) {
        token = tokens[i];
        if (Expr.relative[type = token.type]) {
          break;
        }
        if (find = Expr.find[type]) {
          if (seed = find(token.matches[0].replace(runescape, funescape), rsibling.test(tokens[0].type) && testContext(context.parentNode) || context)) {
            tokens.splice(i, 1);
            selector = seed.length && toSelector(tokens);
            if (!selector) {
              push.apply(results, seed);
              return results;
            }
            break;
          }
        }
      }
    }
    (compiled || compile(selector, match))(seed, context, !documentIsHTML, results, rsibling.test(selector) && testContext(context.parentNode) || context);
    return results;
  };
  support.sortStable = expando.split("").sort(sortOrder).join("") === expando;
  support.detectDuplicates = !!hasDuplicate;
  setDocument();
  support.sortDetached = assert(function (div1) {
    return div1.compareDocumentPosition(document.createElement("div")) & 1;
  });
  if (!assert(function (div) {
    div.innerHTML = "<a href='#'></a>";
    return div.firstChild.getAttribute("href") === "#";
  })) {
    addHandle("type|href|height|width", function (elem, name, isXML) {
      if (!isXML) {
        return elem.getAttribute(name, name.toLowerCase() === "type" ? 1 : 2);
      }
    });
  }
  if (!support.attributes || !assert(function (div) {
    div.innerHTML = "<input/>";
    div.firstChild.setAttribute("value", "");
    return div.firstChild.getAttribute("value") === "";
  })) {
    addHandle("value", function (elem, name, isXML) {
      if (!isXML && elem.nodeName.toLowerCase() === "input") {
        return elem.defaultValue;
      }
    });
  }
  if (!assert(function (div) {
    return div.getAttribute("disabled") == null;
  })) {
    addHandle(booleans, function (elem, name, isXML) {
      var val;
      if (!isXML) {
        return elem[name] === true ? name.toLowerCase() : (val = elem.getAttributeNode(name)) && val.specified ? val.value : null;
      }
    });
  }
  if (typeof define === "function" && define.amd) {
    define(function () {
      return Sizzle;
    });
  } else if (typeof module !== "undefined" && module.exports) {
    module.exports = Sizzle;
  } else {
    window.Sizzle = Sizzle;
  }
})(window);
;
(function () {
  if (typeof Sizzle !== 'undefined') {
    return;
  }
  if (typeof define !== 'undefined' && define.amd) {
    window.Sizzle = Prototype._actual_sizzle;
    window.define = Prototype._original_define;
    delete Prototype._actual_sizzle;
    delete Prototype._original_define;
  } else if (typeof module !== 'undefined' && module.exports) {
    window.Sizzle = module.exports;
    module.exports = {};
  }
})();
;
(function (engine) {
  var extendElements = Prototype.Selector.extendElements;
  function select(selector, scope) {
    return extendElements(engine(selector, scope || document));
  }
  function match(element, selector) {
    return engine.matches(selector, [element]).length == 1;
  }
  Prototype.Selector.engine = engine;
  Prototype.Selector.select = select;
  Prototype.Selector.match = match;
})(Sizzle);
window.Sizzle = Prototype._original_property;
delete Prototype._original_property;
var Form = {
  reset: function (form) {
    form = $(form);
    form.reset();
    return form;
  },
  serializeElements: function (elements, options) {
    if (typeof options != 'object') options = {
      hash: !!options
    };else if (Object.isUndefined(options.hash)) options.hash = true;
    var key,
      value,
      submitted = false,
      submit = options.submit,
      accumulator,
      initial;
    if (options.hash) {
      initial = {};
      accumulator = function (result, key, value) {
        if (key in result) {
          if (!Object.isArray(result[key])) result[key] = [result[key]];
          result[key] = result[key].concat(value);
        } else result[key] = value;
        return result;
      };
    } else {
      initial = '';
      accumulator = function (result, key, values) {
        if (!Object.isArray(values)) {
          values = [values];
        }
        if (!values.length) {
          return result;
        }
        var encodedKey = encodeURIComponent(key).gsub(/%20/, '+');
        return result + (result ? "&" : "") + values.map(function (value) {
          value = value.gsub(/(\r)?\n/, '\r\n');
          value = encodeURIComponent(value);
          value = value.gsub(/%20/, '+');
          return encodedKey + "=" + value;
        }).join("&");
      };
    }
    return elements.inject(initial, function (result, element) {
      if (!element.disabled && element.name) {
        key = element.name;
        value = $(element).getValue();
        if (value != null && element.type != 'file' && (element.type != 'submit' || !submitted && submit !== false && (!submit || key == submit) && (submitted = true))) {
          result = accumulator(result, key, value);
        }
      }
      return result;
    });
  }
};
Form.Methods = {
  serialize: function (form, options) {
    return Form.serializeElements(Form.getElements(form), options);
  },
  getElements: function (form) {
    var elements = $(form).getElementsByTagName('*');
    var element,
      results = [],
      serializers = Form.Element.Serializers;
    for (var i = 0; element = elements[i]; i++) {
      if (serializers[element.tagName.toLowerCase()]) results.push(Element.extend(element));
    }
    return results;
  },
  getInputs: function (form, typeName, name) {
    form = $(form);
    var inputs = form.getElementsByTagName('input');
    if (!typeName && !name) return $A(inputs).map(Element.extend);
    for (var i = 0, matchingInputs = [], length = inputs.length; i < length; i++) {
      var input = inputs[i];
      if (typeName && input.type != typeName || name && input.name != name) continue;
      matchingInputs.push(Element.extend(input));
    }
    return matchingInputs;
  },
  disable: function (form) {
    form = $(form);
    Form.getElements(form).invoke('disable');
    return form;
  },
  enable: function (form) {
    form = $(form);
    Form.getElements(form).invoke('enable');
    return form;
  },
  findFirstElement: function (form) {
    var elements = $(form).getElements().findAll(function (element) {
      return 'hidden' != element.type && !element.disabled;
    });
    var firstByIndex = elements.findAll(function (element) {
      return element.hasAttribute('tabIndex') && element.tabIndex >= 0;
    }).sortBy(function (element) {
      return element.tabIndex;
    }).first();
    return firstByIndex ? firstByIndex : elements.find(function (element) {
      return /^(?:input|select|textarea)$/i.test(element.tagName);
    });
  },
  focusFirstElement: function (form) {
    form = $(form);
    var element = form.findFirstElement();
    if (element) element.activate();
    return form;
  },
  request: function (form, options) {
    form = $(form), options = Object.clone(options || {});
    var params = options.parameters,
      action = form.readAttribute('action') || '';
    if (action.blank()) action = window.location.href;
    options.parameters = form.serialize(true);
    if (params) {
      if (Object.isString(params)) params = params.toQueryParams();
      Object.extend(options.parameters, params);
    }
    if (form.hasAttribute('method') && !options.method) options.method = form.method;
    return new Ajax.Request(action, options);
  }
};

/*--------------------------------------------------------------------------*/

Form.Element = {
  focus: function (element) {
    $(element).focus();
    return element;
  },
  select: function (element) {
    $(element).select();
    return element;
  }
};
Form.Element.Methods = {
  serialize: function (element) {
    element = $(element);
    if (!element.disabled && element.name) {
      var value = element.getValue();
      if (value != undefined) {
        var pair = {};
        pair[element.name] = value;
        return Object.toQueryString(pair);
      }
    }
    return '';
  },
  getValue: function (element) {
    element = $(element);
    var method = element.tagName.toLowerCase();
    return Form.Element.Serializers[method](element);
  },
  setValue: function (element, value) {
    element = $(element);
    var method = element.tagName.toLowerCase();
    Form.Element.Serializers[method](element, value);
    return element;
  },
  clear: function (element) {
    $(element).value = '';
    return element;
  },
  present: function (element) {
    return $(element).value != '';
  },
  activate: function (element) {
    element = $(element);
    try {
      element.focus();
      if (element.select && (element.tagName.toLowerCase() != 'input' || !/^(?:button|reset|submit)$/i.test(element.type))) element.select();
    } catch (e) {}
    return element;
  },
  disable: function (element) {
    element = $(element);
    element.disabled = true;
    return element;
  },
  enable: function (element) {
    element = $(element);
    element.disabled = false;
    return element;
  }
};

/*--------------------------------------------------------------------------*/

var Field = Form.Element;
var $F = Form.Element.Methods.getValue;

/*--------------------------------------------------------------------------*/

Form.Element.Serializers = function () {
  function input(element, value) {
    switch (element.type.toLowerCase()) {
      case 'checkbox':
      case 'radio':
        return inputSelector(element, value);
      default:
        return valueSelector(element, value);
    }
  }
  function inputSelector(element, value) {
    if (Object.isUndefined(value)) return element.checked ? element.value : null;else element.checked = !!value;
  }
  function valueSelector(element, value) {
    if (Object.isUndefined(value)) return element.value;else element.value = value;
  }
  function select(element, value) {
    if (Object.isUndefined(value)) return (element.type === 'select-one' ? selectOne : selectMany)(element);
    var opt,
      currentValue,
      single = !Object.isArray(value);
    for (var i = 0, length = element.length; i < length; i++) {
      opt = element.options[i];
      currentValue = this.optionValue(opt);
      if (single) {
        if (currentValue == value) {
          opt.selected = true;
          return;
        }
      } else opt.selected = value.include(currentValue);
    }
  }
  function selectOne(element) {
    var index = element.selectedIndex;
    return index >= 0 ? optionValue(element.options[index]) : null;
  }
  function selectMany(element) {
    var values,
      length = element.length;
    if (!length) return null;
    for (var i = 0, values = []; i < length; i++) {
      var opt = element.options[i];
      if (opt.selected) values.push(optionValue(opt));
    }
    return values;
  }
  function optionValue(opt) {
    return Element.hasAttribute(opt, 'value') ? opt.value : opt.text;
  }
  return {
    input: input,
    inputSelector: inputSelector,
    textarea: valueSelector,
    select: select,
    selectOne: selectOne,
    selectMany: selectMany,
    optionValue: optionValue,
    button: valueSelector
  };
}();

/*--------------------------------------------------------------------------*/

Abstract.TimedObserver = Class.create(PeriodicalExecuter, {
  initialize: function ($super, element, frequency, callback) {
    $super(callback, frequency);
    this.element = $(element);
    this.lastValue = this.getValue();
  },
  execute: function () {
    var value = this.getValue();
    if (Object.isString(this.lastValue) && Object.isString(value) ? this.lastValue != value : String(this.lastValue) != String(value)) {
      this.callback(this.element, value);
      this.lastValue = value;
    }
  }
});
Form.Element.Observer = Class.create(Abstract.TimedObserver, {
  getValue: function () {
    return Form.Element.getValue(this.element);
  }
});
Form.Observer = Class.create(Abstract.TimedObserver, {
  getValue: function () {
    return Form.serialize(this.element);
  }
});

/*--------------------------------------------------------------------------*/

Abstract.EventObserver = Class.create({
  initialize: function (element, callback) {
    this.element = $(element);
    this.callback = callback;
    this.lastValue = this.getValue();
    if (this.element.tagName.toLowerCase() == 'form') this.registerFormCallbacks();else this.registerCallback(this.element);
  },
  onElementEvent: function () {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(this.element, value);
      this.lastValue = value;
    }
  },
  registerFormCallbacks: function () {
    Form.getElements(this.element).each(this.registerCallback, this);
  },
  registerCallback: function (element) {
    if (element.type) {
      switch (element.type.toLowerCase()) {
        case 'checkbox':
        case 'radio':
          Event.observe(element, 'click', this.onElementEvent.bind(this));
          break;
        default:
          Event.observe(element, 'change', this.onElementEvent.bind(this));
          break;
      }
    }
  }
});
Form.Element.EventObserver = Class.create(Abstract.EventObserver, {
  getValue: function () {
    return Form.Element.getValue(this.element);
  }
});
Form.EventObserver = Class.create(Abstract.EventObserver, {
  getValue: function () {
    return Form.serialize(this.element);
  }
});
(function (GLOBAL) {
  var DIV = document.createElement('div');
  var docEl = document.documentElement;
  var MOUSEENTER_MOUSELEAVE_EVENTS_SUPPORTED = 'onmouseenter' in docEl && 'onmouseleave' in docEl;
  var Event = {
    KEY_BACKSPACE: 8,
    KEY_TAB: 9,
    KEY_RETURN: 13,
    KEY_ESC: 27,
    KEY_LEFT: 37,
    KEY_UP: 38,
    KEY_RIGHT: 39,
    KEY_DOWN: 40,
    KEY_DELETE: 46,
    KEY_HOME: 36,
    KEY_END: 35,
    KEY_PAGEUP: 33,
    KEY_PAGEDOWN: 34,
    KEY_INSERT: 45
  };
  var isIELegacyEvent = function (event) {
    return false;
  };
  if (window.attachEvent) {
    if (window.addEventListener) {
      isIELegacyEvent = function (event) {
        return !(event instanceof window.Event);
      };
    } else {
      isIELegacyEvent = function (event) {
        return true;
      };
    }
  }
  var _isButton;
  function _isButtonForDOMEvents(event, code) {
    return event.which ? event.which === code + 1 : event.button === code;
  }
  var legacyButtonMap = {
    0: 1,
    1: 4,
    2: 2
  };
  function _isButtonForLegacyEvents(event, code) {
    return event.button === legacyButtonMap[code];
  }
  function _isButtonForWebKit(event, code) {
    switch (code) {
      case 0:
        return event.which == 1 && !event.metaKey;
      case 1:
        return event.which == 2 || event.which == 1 && event.metaKey;
      case 2:
        return event.which == 3;
      default:
        return false;
    }
  }
  if (window.attachEvent) {
    if (!window.addEventListener) {
      _isButton = _isButtonForLegacyEvents;
    } else {
      _isButton = function (event, code) {
        return isIELegacyEvent(event) ? _isButtonForLegacyEvents(event, code) : _isButtonForDOMEvents(event, code);
      };
    }
  } else if (Prototype.Browser.WebKit) {
    _isButton = _isButtonForWebKit;
  } else {
    _isButton = _isButtonForDOMEvents;
  }
  function isLeftClick(event) {
    return _isButton(event, 0);
  }
  function isMiddleClick(event) {
    return _isButton(event, 1);
  }
  function isRightClick(event) {
    return _isButton(event, 2);
  }
  function element(event) {
    return Element.extend(_element(event));
  }
  function _element(event) {
    event = Event.extend(event);
    var node = event.target,
      type = event.type,
      currentTarget = event.currentTarget;
    if (currentTarget && currentTarget.tagName) {
      if (type === 'load' || type === 'error' || type === 'click' && currentTarget.tagName.toLowerCase() === 'input' && currentTarget.type === 'radio') node = currentTarget;
    }
    return node.nodeType == Node.TEXT_NODE ? node.parentNode : node;
  }
  function findElement(event, expression) {
    var element = _element(event),
      selector = Prototype.Selector;
    if (!expression) return Element.extend(element);
    while (element) {
      if (Object.isElement(element) && selector.match(element, expression)) return Element.extend(element);
      element = element.parentNode;
    }
  }
  function pointer(event) {
    return {
      x: pointerX(event),
      y: pointerY(event)
    };
  }
  function pointerX(event) {
    var docElement = document.documentElement,
      body = document.body || {
        scrollLeft: 0
      };
    return event.pageX || event.clientX + (docElement.scrollLeft || body.scrollLeft) - (docElement.clientLeft || 0);
  }
  function pointerY(event) {
    var docElement = document.documentElement,
      body = document.body || {
        scrollTop: 0
      };
    return event.pageY || event.clientY + (docElement.scrollTop || body.scrollTop) - (docElement.clientTop || 0);
  }
  function stop(event) {
    Event.extend(event);
    event.preventDefault();
    event.stopPropagation();
    event.stopped = true;
  }
  Event.Methods = {
    isLeftClick: isLeftClick,
    isMiddleClick: isMiddleClick,
    isRightClick: isRightClick,
    element: element,
    findElement: findElement,
    pointer: pointer,
    pointerX: pointerX,
    pointerY: pointerY,
    stop: stop
  };
  var methods = Object.keys(Event.Methods).inject({}, function (m, name) {
    m[name] = Event.Methods[name].methodize();
    return m;
  });
  if (window.attachEvent) {
    function _relatedTarget(event) {
      var element;
      switch (event.type) {
        case 'mouseover':
        case 'mouseenter':
          element = event.fromElement;
          break;
        case 'mouseout':
        case 'mouseleave':
          element = event.toElement;
          break;
        default:
          return null;
      }
      return Element.extend(element);
    }
    var additionalMethods = {
      stopPropagation: function () {
        this.cancelBubble = true;
      },
      preventDefault: function () {
        this.returnValue = false;
      },
      inspect: function () {
        return '[object Event]';
      }
    };
    Event.extend = function (event, element) {
      if (!event) return false;
      if (!isIELegacyEvent(event)) return event;
      if (event._extendedByPrototype) return event;
      event._extendedByPrototype = Prototype.emptyFunction;
      var pointer = Event.pointer(event);
      Object.extend(event, {
        target: event.srcElement || element,
        relatedTarget: _relatedTarget(event),
        pageX: pointer.x,
        pageY: pointer.y
      });
      Object.extend(event, methods);
      Object.extend(event, additionalMethods);
      return event;
    };
  } else {
    Event.extend = Prototype.K;
  }
  if (window.addEventListener) {
    Event.prototype = window.Event.prototype || document.createEvent('HTMLEvents').__proto__;
    Object.extend(Event.prototype, methods);
  }
  var EVENT_TRANSLATIONS = {
    mouseenter: 'mouseover',
    mouseleave: 'mouseout'
  };
  function getDOMEventName(eventName) {
    return EVENT_TRANSLATIONS[eventName] || eventName;
  }
  if (MOUSEENTER_MOUSELEAVE_EVENTS_SUPPORTED) getDOMEventName = Prototype.K;
  function getUniqueElementID(element) {
    if (element === window) return 0;
    if (typeof element._prototypeUID === 'undefined') element._prototypeUID = Element.Storage.UID++;
    return element._prototypeUID;
  }
  function getUniqueElementID_IE(element) {
    if (element === window) return 0;
    if (element == document) return 1;
    return element.uniqueID;
  }
  if ('uniqueID' in DIV) getUniqueElementID = getUniqueElementID_IE;
  function isCustomEvent(eventName) {
    return eventName.include(':');
  }
  Event._isCustomEvent = isCustomEvent;
  function getOrCreateRegistryFor(element, uid) {
    var CACHE = GLOBAL.Event.cache;
    if (Object.isUndefined(uid)) uid = getUniqueElementID(element);
    if (!CACHE[uid]) CACHE[uid] = {
      element: element
    };
    return CACHE[uid];
  }
  function destroyRegistryForElement(element, uid) {
    if (Object.isUndefined(uid)) uid = getUniqueElementID(element);
    delete GLOBAL.Event.cache[uid];
  }
  function register(element, eventName, handler) {
    var registry = getOrCreateRegistryFor(element);
    if (!registry[eventName]) registry[eventName] = [];
    var entries = registry[eventName];
    var i = entries.length;
    while (i--) if (entries[i].handler === handler) return null;
    var uid = getUniqueElementID(element);
    var responder = GLOBAL.Event._createResponder(uid, eventName, handler);
    var entry = {
      responder: responder,
      handler: handler
    };
    entries.push(entry);
    return entry;
  }
  function unregister(element, eventName, handler) {
    var registry = getOrCreateRegistryFor(element);
    var entries = registry[eventName] || [];
    var i = entries.length,
      entry;
    while (i--) {
      if (entries[i].handler === handler) {
        entry = entries[i];
        break;
      }
    }
    if (entry) {
      var index = entries.indexOf(entry);
      entries.splice(index, 1);
    }
    if (entries.length === 0) {
      delete registry[eventName];
      if (Object.keys(registry).length === 1 && 'element' in registry) destroyRegistryForElement(element);
    }
    return entry;
  }
  function observe(element, eventName, handler) {
    element = $(element);
    var entry = register(element, eventName, handler);
    if (entry === null) return element;
    var responder = entry.responder;
    if (isCustomEvent(eventName)) observeCustomEvent(element, eventName, responder);else observeStandardEvent(element, eventName, responder);
    return element;
  }
  function observeStandardEvent(element, eventName, responder) {
    var actualEventName = getDOMEventName(eventName);
    if (element.addEventListener) {
      element.addEventListener(actualEventName, responder, false);
    } else {
      element.attachEvent('on' + actualEventName, responder);
    }
  }
  function observeCustomEvent(element, eventName, responder) {
    if (element.addEventListener) {
      element.addEventListener('dataavailable', responder, false);
    } else {
      element.attachEvent('ondataavailable', responder);
      element.attachEvent('onlosecapture', responder);
    }
  }
  function stopObserving(element, eventName, handler) {
    element = $(element);
    var handlerGiven = !Object.isUndefined(handler),
      eventNameGiven = !Object.isUndefined(eventName);
    if (!eventNameGiven && !handlerGiven) {
      stopObservingElement(element);
      return element;
    }
    if (!handlerGiven) {
      stopObservingEventName(element, eventName);
      return element;
    }
    var entry = unregister(element, eventName, handler);
    if (!entry) return element;
    removeEvent(element, eventName, entry.responder);
    return element;
  }
  function stopObservingStandardEvent(element, eventName, responder) {
    var actualEventName = getDOMEventName(eventName);
    if (element.removeEventListener) {
      element.removeEventListener(actualEventName, responder, false);
    } else {
      element.detachEvent('on' + actualEventName, responder);
    }
  }
  function stopObservingCustomEvent(element, eventName, responder) {
    if (element.removeEventListener) {
      element.removeEventListener('dataavailable', responder, false);
    } else {
      element.detachEvent('ondataavailable', responder);
      element.detachEvent('onlosecapture', responder);
    }
  }
  function stopObservingElement(element) {
    var uid = getUniqueElementID(element),
      registry = GLOBAL.Event.cache[uid];
    if (!registry) return;
    destroyRegistryForElement(element, uid);
    var entries, i;
    for (var eventName in registry) {
      if (eventName === 'element') continue;
      entries = registry[eventName];
      i = entries.length;
      while (i--) removeEvent(element, eventName, entries[i].responder);
    }
  }
  function stopObservingEventName(element, eventName) {
    var registry = getOrCreateRegistryFor(element);
    var entries = registry[eventName];
    if (entries) {
      delete registry[eventName];
    }
    entries = entries || [];
    var i = entries.length;
    while (i--) removeEvent(element, eventName, entries[i].responder);
    for (var name in registry) {
      if (name === 'element') continue;
      return; // There is another registered event
    }

    destroyRegistryForElement(element);
  }
  function removeEvent(element, eventName, handler) {
    if (isCustomEvent(eventName)) stopObservingCustomEvent(element, eventName, handler);else stopObservingStandardEvent(element, eventName, handler);
  }
  function getFireTarget(element) {
    if (element !== document) return element;
    if (document.createEvent && !element.dispatchEvent) return document.documentElement;
    return element;
  }
  function fire(element, eventName, memo, bubble) {
    element = getFireTarget($(element));
    if (Object.isUndefined(bubble)) bubble = true;
    memo = memo || {};
    var event = fireEvent(element, eventName, memo, bubble);
    return Event.extend(event);
  }
  function fireEvent_DOM(element, eventName, memo, bubble) {
    var event = document.createEvent('HTMLEvents');
    event.initEvent('dataavailable', bubble, true);
    event.eventName = eventName;
    event.memo = memo;
    element.dispatchEvent(event);
    return event;
  }
  function fireEvent_IE(element, eventName, memo, bubble) {
    var event = document.createEventObject();
    event.eventType = bubble ? 'ondataavailable' : 'onlosecapture';
    event.eventName = eventName;
    event.memo = memo;
    element.fireEvent(event.eventType, event);
    return event;
  }
  var fireEvent = document.createEvent ? fireEvent_DOM : fireEvent_IE;
  Event.Handler = Class.create({
    initialize: function (element, eventName, selector, callback) {
      this.element = $(element);
      this.eventName = eventName;
      this.selector = selector;
      this.callback = callback;
      this.handler = this.handleEvent.bind(this);
    },
    start: function () {
      Event.observe(this.element, this.eventName, this.handler);
      return this;
    },
    stop: function () {
      Event.stopObserving(this.element, this.eventName, this.handler);
      return this;
    },
    handleEvent: function (event) {
      var element = Event.findElement(event, this.selector);
      if (element) this.callback.call(this.element, event, element);
    }
  });
  function on(element, eventName, selector, callback) {
    element = $(element);
    if (Object.isFunction(selector) && Object.isUndefined(callback)) {
      callback = selector, selector = null;
    }
    return new Event.Handler(element, eventName, selector, callback).start();
  }
  Object.extend(Event, Event.Methods);
  Object.extend(Event, {
    fire: fire,
    observe: observe,
    stopObserving: stopObserving,
    on: on
  });
  Element.addMethods({
    fire: fire,
    observe: observe,
    stopObserving: stopObserving,
    on: on
  });
  Object.extend(document, {
    fire: fire.methodize(),
    observe: observe.methodize(),
    stopObserving: stopObserving.methodize(),
    on: on.methodize(),
    loaded: false
  });
  if (GLOBAL.Event) Object.extend(window.Event, Event);else GLOBAL.Event = Event;
  GLOBAL.Event.cache = {};
  function destroyCache_IE() {
    GLOBAL.Event.cache = null;
  }
  if (window.attachEvent) window.attachEvent('onunload', destroyCache_IE);
  DIV = null;
  docEl = null;
})(this);
(function (GLOBAL) {
  /* Code for creating leak-free event responders is based on work by
   John-David Dalton. */

  var docEl = document.documentElement;
  var MOUSEENTER_MOUSELEAVE_EVENTS_SUPPORTED = 'onmouseenter' in docEl && 'onmouseleave' in docEl;
  function isSimulatedMouseEnterLeaveEvent(eventName) {
    return !MOUSEENTER_MOUSELEAVE_EVENTS_SUPPORTED && (eventName === 'mouseenter' || eventName === 'mouseleave');
  }
  function createResponder(uid, eventName, handler) {
    if (Event._isCustomEvent(eventName)) return createResponderForCustomEvent(uid, eventName, handler);
    if (isSimulatedMouseEnterLeaveEvent(eventName)) return createMouseEnterLeaveResponder(uid, eventName, handler);
    return function (event) {
      if (!Event.cache) return;
      var element = Event.cache[uid].element;
      Event.extend(event, element);
      handler.call(element, event);
    };
  }
  function createResponderForCustomEvent(uid, eventName, handler) {
    return function (event) {
      var cache = Event.cache[uid];
      var element = cache && cache.element;
      if (Object.isUndefined(event.eventName)) return false;
      if (event.eventName !== eventName) return false;
      Event.extend(event, element);
      handler.call(element, event);
    };
  }
  function createMouseEnterLeaveResponder(uid, eventName, handler) {
    return function (event) {
      var element = Event.cache[uid].element;
      Event.extend(event, element);
      var parent = event.relatedTarget;
      while (parent && parent !== element) {
        try {
          parent = parent.parentNode;
        } catch (e) {
          parent = element;
        }
      }
      if (parent === element) return;
      handler.call(element, event);
    };
  }
  GLOBAL.Event._createResponder = createResponder;
  docEl = null;
})(this);
(function (GLOBAL) {
  /* Support for the DOMContentLoaded event is based on work by Dan Webb,
     Matthias Miller, Dean Edwards, John Resig, and Diego Perini. */

  var TIMER;
  function fireContentLoadedEvent() {
    if (document.loaded) return;
    if (TIMER) window.clearTimeout(TIMER);
    document.loaded = true;
    document.fire('dom:loaded');
  }
  function checkReadyState() {
    if (document.readyState === 'complete') {
      document.detachEvent('onreadystatechange', checkReadyState);
      fireContentLoadedEvent();
    }
  }
  function pollDoScroll() {
    try {
      document.documentElement.doScroll('left');
    } catch (e) {
      TIMER = pollDoScroll.defer();
      return;
    }
    fireContentLoadedEvent();
  }
  if (document.readyState === 'complete') {
    fireContentLoadedEvent();
    return;
  }
  if (document.addEventListener) {
    document.addEventListener('DOMContentLoaded', fireContentLoadedEvent, false);
  } else {
    document.attachEvent('onreadystatechange', checkReadyState);
    if (window == top) TIMER = pollDoScroll.defer();
  }
  Event.observe(window, 'load', fireContentLoadedEvent);
})(this);
Element.addMethods();
/*------------------------------- DEPRECATED -------------------------------*/

Hash.toQueryString = Object.toQueryString;
var Toggle = {
  display: Element.toggle
};
Element.addMethods({
  childOf: Element.Methods.descendantOf
});
var Insertion = {
  Before: function (element, content) {
    return Element.insert(element, {
      before: content
    });
  },
  Top: function (element, content) {
    return Element.insert(element, {
      top: content
    });
  },
  Bottom: function (element, content) {
    return Element.insert(element, {
      bottom: content
    });
  },
  After: function (element, content) {
    return Element.insert(element, {
      after: content
    });
  }
};
var $continue = new Error('"throw $continue" is deprecated, use "return" instead');
var Position = {
  includeScrollOffsets: false,
  prepare: function () {
    this.deltaX = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft || 0;
    this.deltaY = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
  },
  within: function (element, x, y) {
    if (this.includeScrollOffsets) return this.withinIncludingScrolloffsets(element, x, y);
    this.xcomp = x;
    this.ycomp = y;
    this.offset = Element.cumulativeOffset(element);
    return y >= this.offset[1] && y < this.offset[1] + element.offsetHeight && x >= this.offset[0] && x < this.offset[0] + element.offsetWidth;
  },
  withinIncludingScrolloffsets: function (element, x, y) {
    var offsetcache = Element.cumulativeScrollOffset(element);
    this.xcomp = x + offsetcache[0] - this.deltaX;
    this.ycomp = y + offsetcache[1] - this.deltaY;
    this.offset = Element.cumulativeOffset(element);
    return this.ycomp >= this.offset[1] && this.ycomp < this.offset[1] + element.offsetHeight && this.xcomp >= this.offset[0] && this.xcomp < this.offset[0] + element.offsetWidth;
  },
  overlap: function (mode, element) {
    if (!mode) return 0;
    if (mode == 'vertical') return (this.offset[1] + element.offsetHeight - this.ycomp) / element.offsetHeight;
    if (mode == 'horizontal') return (this.offset[0] + element.offsetWidth - this.xcomp) / element.offsetWidth;
  },
  cumulativeOffset: Element.Methods.cumulativeOffset,
  positionedOffset: Element.Methods.positionedOffset,
  absolutize: function (element) {
    Position.prepare();
    return Element.absolutize(element);
  },
  relativize: function (element) {
    Position.prepare();
    return Element.relativize(element);
  },
  realOffset: Element.Methods.cumulativeScrollOffset,
  offsetParent: Element.Methods.getOffsetParent,
  page: Element.Methods.viewportOffset,
  clone: function (source, target, options) {
    options = options || {};
    return Element.clonePosition(target, source, options);
  }
};

/*--------------------------------------------------------------------------*/

if (!document.getElementsByClassName) document.getElementsByClassName = function (instanceMethods) {
  function iter(name) {
    return name.blank() ? null : "[contains(concat(' ', @class, ' '), ' " + name + " ')]";
  }
  instanceMethods.getElementsByClassName = Prototype.BrowserFeatures.XPath ? function (element, className) {
    className = className.toString().strip();
    var cond = /\s/.test(className) ? $w(className).map(iter).join('') : iter(className);
    return cond ? document._getElementsByXPath('.//*' + cond, element) : [];
  } : function (element, className) {
    className = className.toString().strip();
    var elements = [],
      classNames = /\s/.test(className) ? $w(className) : null;
    if (!classNames && !className) return elements;
    var nodes = $(element).getElementsByTagName('*');
    className = ' ' + className + ' ';
    for (var i = 0, child, cn; child = nodes[i]; i++) {
      if (child.className && (cn = ' ' + child.className + ' ') && (cn.include(className) || classNames && classNames.all(function (name) {
        return !name.toString().blank() && cn.include(' ' + name + ' ');
      }))) elements.push(Element.extend(child));
    }
    return elements;
  };
  return function (className, parentElement) {
    return $(parentElement || document.body).getElementsByClassName(className);
  };
}(Element.Methods);

/*--------------------------------------------------------------------------*/

Element.ClassNames = Class.create();
Element.ClassNames.prototype = {
  initialize: function (element) {
    this.element = $(element);
  },
  _each: function (iterator, context) {
    this.element.className.split(/\s+/).select(function (name) {
      return name.length > 0;
    })._each(iterator, context);
  },
  set: function (className) {
    this.element.className = className;
  },
  add: function (classNameToAdd) {
    if (this.include(classNameToAdd)) return;
    this.set($A(this).concat(classNameToAdd).join(' '));
  },
  remove: function (classNameToRemove) {
    if (!this.include(classNameToRemove)) return;
    this.set($A(this).without(classNameToRemove).join(' '));
  },
  toString: function () {
    return $A(this).join(' ');
  }
};
Object.extend(Element.ClassNames.prototype, Enumerable);

/*--------------------------------------------------------------------------*/

(function () {
  window.Selector = Class.create({
    initialize: function (expression) {
      this.expression = expression.strip();
    },
    findElements: function (rootElement) {
      return Prototype.Selector.select(this.expression, rootElement);
    },
    match: function (element) {
      return Prototype.Selector.match(element, this.expression);
    },
    toString: function () {
      return this.expression;
    },
    inspect: function () {
      return "#<Selector: " + this.expression + ">";
    }
  });
  Object.extend(Selector, {
    matchElements: function (elements, expression) {
      var match = Prototype.Selector.match,
        results = [];
      for (var i = 0, length = elements.length; i < length; i++) {
        var element = elements[i];
        if (match(element, expression)) {
          results.push(Element.extend(element));
        }
      }
      return results;
    },
    findElement: function (elements, expression, index) {
      index = index || 0;
      var matchIndex = 0,
        element;
      for (var i = 0, length = elements.length; i < length; i++) {
        element = elements[i];
        if (Prototype.Selector.match(element, expression) && index === matchIndex++) {
          return Element.extend(element);
        }
      }
    },
    findChildElements: function (element, expressions) {
      var selector = expressions.toArray().join(', ');
      return Prototype.Selector.select(selector, element || document);
    }
  });
})();
/**
 * This plugin adds the ability for you to show the natural browser feedback (e.g. spinning logo) whenever you perform an Ajax.Request
 *
 * @requires Prototype version 1.6
 * @author releasedj
 * @see http://www.loajax.com
 * @see http://webreflection.blogspot.com/2007/06/simple-settimeout-setinterval-extra.html for IE setTimeout hack
 */

/*@cc_on
(function(f){
 window.setTimeout =f(window.setTimeout);
})(function(f){return function(c,t){var a=[].slice.call(arguments,2);return f(function(){c.apply(this,a)},t)}});
@*/

if (parseFloat(Prototype.Version) >= 1.6) {
  /*
   * Extend prototype to get the versino of the browser we're using
   */
  Object.extend(Prototype, {
    getBrowserVersion: function () {
      var re = Prototype.Browser.IE ? /MSIE ([0-9\.]+)/m : Prototype.Browser.Opera ? /Opera\/([0-9\.]+)/m : Prototype.Browser.WebKit ? /Version\/([0-9\.]+)/m : Prototype.Browser.Gecko ? /Gecko\/[0-9]+\s[A-Za-z]+\/([0-9\.]+)/m : null;
      var match = re && navigator.userAgent.match(re);
      return match ? parseFloat(match[1]) : 0.00;
    }
  });
  Object.extend(Prototype.Browser, {
    Version: Prototype.getBrowserVersion()
  });
  var loajaxStarted = false;
  var loajaxVersion = '1.0.0a1';
  Loajax = Class.create({
    initialize: function (request) {
      this.request = request;
    },
    start: function () {
      if (loajaxStarted || this._ignore()) {
        return;
      }
      if (Ajax.activeRequestCount == 1) {
        this._createIframe();
      }
    },
    stop: function () {
      if (!loajaxStarted || this._ignore()) {
        return;
      }
      if (Ajax.activeRequestCount === 0) {
        window.setTimeout(function (lo) {
          lo._stop();
        }, 50, this); // avoids IE race condition where Ajax call is cached
      }
    },

    _stop: function () {
      var frame_name = this._getFrameName();
      if (!$(frame_name)) {
        return;
      }
      if (window.stop) {
        frames[frame_name].stop();
      } else if (document.execCommand) {
        frames[frame_name].document.execCommand("Stop");
      }
      $(frame_name).remove();
      loajaxStarted = false;
    },
    _createIframe: function () {
      var frame_name = this._getFrameName();
      var frame_src = this._getFrameSrc();
      iframe = new Element('iframe', {
        'name': frame_name,
        'id': frame_name
      }).setStyle({
        display: 'none'
      });
      Element.insert(document.body, {
        top: iframe
      });
      if (this.request.options.loajaxTimeout) {
        frame_src += frame_src.include('?') ? '&' : '?';
        frame_src += 't=' + this.request.options.loajaxTimeout;
      }
      $(frame_name).src = frame_src;
      loajaxStarted = true;
    },
    _getFrameName: function () {
      return this.request.options.loajaxIframe || "loajax_iframe";
    },
    _getFrameSrc: function () {
      // REWRITE: we are readin this from the env instead
      // return (this.request.options.loajax || "http://prometheus-bildarchiv.de/loajax-sleep.php");
      var defaultUrl = $$('meta[name=pm-home-url]')[0].getAttribute('value');
      return this.request.options.loajax || defaultUrl;
    },
    _ignore: function () {
      return !(Prototype.Browser.IE || Prototype.Browser.Gecko || Prototype.Browser.WebKit || Prototype.Browser.Opera && Prototype.Browser.Version >= 9.0);
    }
  });
  Ajax.Responders.register({
    onCreate: function (req) {
      // loajax = new Loajax(req);
      // loajax.start();
    },
    onComplete: function (req) {
      // loajax = new Loajax(req);
      // loajax.stop();
    }
  });
}
// script.aculo.us effects.js v1.9.0, Thu Dec 23 16:54:48 -0500 2010

// Copyright (c) 2005-2010 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
// Contributors:
//  Justin Palmer (http://encytemedia.com/)
//  Mark Pilgrim (http://diveintomark.org/)
//  Martin Bialasinki
//
// script.aculo.us is freely distributable under the terms of an MIT-style license.
// For details, see the script.aculo.us web site: http://script.aculo.us/

// converts rgb() and #xxx to #xxxxxx format,
// returns self (or first argument) if not convertable
String.prototype.parseColor = function () {
  var color = '#';
  if (this.slice(0, 4) == 'rgb(') {
    var cols = this.slice(4, this.length - 1).split(',');
    var i = 0;
    do {
      color += parseInt(cols[i]).toColorPart();
    } while (++i < 3);
  } else {
    if (this.slice(0, 1) == '#') {
      if (this.length == 4) for (var i = 1; i < 4; i++) color += (this.charAt(i) + this.charAt(i)).toLowerCase();
      if (this.length == 7) color = this.toLowerCase();
    }
  }
  return color.length == 7 ? color : arguments[0] || this;
};

/*--------------------------------------------------------------------------*/

Element.collectTextNodes = function (element) {
  return $A($(element).childNodes).collect(function (node) {
    return node.nodeType == 3 ? node.nodeValue : node.hasChildNodes() ? Element.collectTextNodes(node) : '';
  }).flatten().join('');
};
Element.collectTextNodesIgnoreClass = function (element, className) {
  return $A($(element).childNodes).collect(function (node) {
    return node.nodeType == 3 ? node.nodeValue : node.hasChildNodes() && !Element.hasClassName(node, className) ? Element.collectTextNodesIgnoreClass(node, className) : '';
  }).flatten().join('');
};
Element.setContentZoom = function (element, percent) {
  element = $(element);
  element.setStyle({
    fontSize: percent / 100 + 'em'
  });
  if (Prototype.Browser.WebKit) window.scrollBy(0, 0);
  return element;
};
Element.getInlineOpacity = function (element) {
  return $(element).style.opacity || '';
};
Element.forceRerendering = function (element) {
  try {
    element = $(element);
    var n = document.createTextNode(' ');
    element.appendChild(n);
    element.removeChild(n);
  } catch (e) {}
};

/*--------------------------------------------------------------------------*/

var Effect = {
  _elementDoesNotExistError: {
    name: 'ElementDoesNotExistError',
    message: 'The specified DOM element does not exist, but is required for this effect to operate'
  },
  Transitions: {
    linear: Prototype.K,
    sinoidal: function (pos) {
      return -Math.cos(pos * Math.PI) / 2 + .5;
    },
    reverse: function (pos) {
      return 1 - pos;
    },
    flicker: function (pos) {
      var pos = -Math.cos(pos * Math.PI) / 4 + .75 + Math.random() / 4;
      return pos > 1 ? 1 : pos;
    },
    wobble: function (pos) {
      return -Math.cos(pos * Math.PI * (9 * pos)) / 2 + .5;
    },
    pulse: function (pos, pulses) {
      return -Math.cos(pos * ((pulses || 5) - .5) * 2 * Math.PI) / 2 + .5;
    },
    spring: function (pos) {
      return 1 - Math.cos(pos * 4.5 * Math.PI) * Math.exp(-pos * 6);
    },
    none: function (pos) {
      return 0;
    },
    full: function (pos) {
      return 1;
    }
  },
  DefaultOptions: {
    duration: 1.0,
    // seconds
    fps: 100,
    // 100= assume 66fps max.
    sync: false,
    // true for combining
    from: 0.0,
    to: 1.0,
    delay: 0.0,
    queue: 'parallel'
  },
  tagifyText: function (element) {
    var tagifyStyle = 'position:relative';
    if (Prototype.Browser.IE) tagifyStyle += ';zoom:1';
    element = $(element);
    $A(element.childNodes).each(function (child) {
      if (child.nodeType == 3) {
        child.nodeValue.toArray().each(function (character) {
          element.insertBefore(new Element('span', {
            style: tagifyStyle
          }).update(character == ' ' ? String.fromCharCode(160) : character), child);
        });
        Element.remove(child);
      }
    });
  },
  multiple: function (element, effect) {
    var elements;
    if ((typeof element == 'object' || Object.isFunction(element)) && element.length) elements = element;else elements = $(element).childNodes;
    var options = Object.extend({
      speed: 0.1,
      delay: 0.0
    }, arguments[2] || {});
    var masterDelay = options.delay;
    $A(elements).each(function (element, index) {
      new effect(element, Object.extend(options, {
        delay: index * options.speed + masterDelay
      }));
    });
  },
  PAIRS: {
    'slide': ['SlideDown', 'SlideUp'],
    'blind': ['BlindDown', 'BlindUp'],
    'appear': ['Appear', 'Fade']
  },
  toggle: function (element, effect, options) {
    element = $(element);
    effect = (effect || 'appear').toLowerCase();
    return Effect[Effect.PAIRS[effect][element.visible() ? 1 : 0]](element, Object.extend({
      queue: {
        position: 'end',
        scope: element.id || 'global',
        limit: 1
      }
    }, options || {}));
  }
};
Effect.DefaultOptions.transition = Effect.Transitions.sinoidal;

/* ------------- core effects ------------- */

Effect.ScopedQueue = Class.create(Enumerable, {
  initialize: function () {
    this.effects = [];
    this.interval = null;
  },
  _each: function (iterator) {
    this.effects._each(iterator);
  },
  add: function (effect) {
    var timestamp = new Date().getTime();
    var position = Object.isString(effect.options.queue) ? effect.options.queue : effect.options.queue.position;
    switch (position) {
      case 'front':
        // move unstarted effects after this effect
        this.effects.findAll(function (e) {
          return e.state == 'idle';
        }).each(function (e) {
          e.startOn += effect.finishOn;
          e.finishOn += effect.finishOn;
        });
        break;
      case 'with-last':
        timestamp = this.effects.pluck('startOn').max() || timestamp;
        break;
      case 'end':
        // start effect after last queued effect has finished
        timestamp = this.effects.pluck('finishOn').max() || timestamp;
        break;
    }
    effect.startOn += timestamp;
    effect.finishOn += timestamp;
    if (!effect.options.queue.limit || this.effects.length < effect.options.queue.limit) this.effects.push(effect);
    if (!this.interval) this.interval = setInterval(this.loop.bind(this), 15);
  },
  remove: function (effect) {
    this.effects = this.effects.reject(function (e) {
      return e == effect;
    });
    if (this.effects.length == 0) {
      clearInterval(this.interval);
      this.interval = null;
    }
  },
  loop: function () {
    var timePos = new Date().getTime();
    for (var i = 0, len = this.effects.length; i < len; i++) this.effects[i] && this.effects[i].loop(timePos);
  }
});
Effect.Queues = {
  instances: $H(),
  get: function (queueName) {
    if (!Object.isString(queueName)) return queueName;
    return this.instances.get(queueName) || this.instances.set(queueName, new Effect.ScopedQueue());
  }
};
Effect.Queue = Effect.Queues.get('global');
Effect.Base = Class.create({
  position: null,
  start: function (options) {
    if (options && options.transition === false) options.transition = Effect.Transitions.linear;
    this.options = Object.extend(Object.extend({}, Effect.DefaultOptions), options || {});
    this.currentFrame = 0;
    this.state = 'idle';
    this.startOn = this.options.delay * 1000;
    this.finishOn = this.startOn + this.options.duration * 1000;
    this.fromToDelta = this.options.to - this.options.from;
    this.totalTime = this.finishOn - this.startOn;
    this.totalFrames = this.options.fps * this.options.duration;
    this.render = function () {
      function dispatch(effect, eventName) {
        if (effect.options[eventName + 'Internal']) effect.options[eventName + 'Internal'](effect);
        if (effect.options[eventName]) effect.options[eventName](effect);
      }
      return function (pos) {
        if (this.state === "idle") {
          this.state = "running";
          dispatch(this, 'beforeSetup');
          if (this.setup) this.setup();
          dispatch(this, 'afterSetup');
        }
        if (this.state === "running") {
          pos = this.options.transition(pos) * this.fromToDelta + this.options.from;
          this.position = pos;
          dispatch(this, 'beforeUpdate');
          if (this.update) this.update(pos);
          dispatch(this, 'afterUpdate');
        }
      };
    }();
    this.event('beforeStart');
    if (!this.options.sync) Effect.Queues.get(Object.isString(this.options.queue) ? 'global' : this.options.queue.scope).add(this);
  },
  loop: function (timePos) {
    if (timePos >= this.startOn) {
      if (timePos >= this.finishOn) {
        this.render(1.0);
        this.cancel();
        this.event('beforeFinish');
        if (this.finish) this.finish();
        this.event('afterFinish');
        return;
      }
      var pos = (timePos - this.startOn) / this.totalTime,
        frame = (pos * this.totalFrames).round();
      if (frame > this.currentFrame) {
        this.render(pos);
        this.currentFrame = frame;
      }
    }
  },
  cancel: function () {
    if (!this.options.sync) Effect.Queues.get(Object.isString(this.options.queue) ? 'global' : this.options.queue.scope).remove(this);
    this.state = 'finished';
  },
  event: function (eventName) {
    if (this.options[eventName + 'Internal']) this.options[eventName + 'Internal'](this);
    if (this.options[eventName]) this.options[eventName](this);
  },
  inspect: function () {
    var data = $H();
    for (property in this) if (!Object.isFunction(this[property])) data.set(property, this[property]);
    return '#<Effect:' + data.inspect() + ',options:' + $H(this.options).inspect() + '>';
  }
});
Effect.Parallel = Class.create(Effect.Base, {
  initialize: function (effects) {
    this.effects = effects || [];
    this.start(arguments[1]);
  },
  update: function (position) {
    this.effects.invoke('render', position);
  },
  finish: function (position) {
    this.effects.each(function (effect) {
      effect.render(1.0);
      effect.cancel();
      effect.event('beforeFinish');
      if (effect.finish) effect.finish(position);
      effect.event('afterFinish');
    });
  }
});
Effect.Tween = Class.create(Effect.Base, {
  initialize: function (object, from, to) {
    object = Object.isString(object) ? $(object) : object;
    var args = $A(arguments),
      method = args.last(),
      options = args.length == 5 ? args[3] : null;
    this.method = Object.isFunction(method) ? method.bind(object) : Object.isFunction(object[method]) ? object[method].bind(object) : function (value) {
      object[method] = value;
    };
    this.start(Object.extend({
      from: from,
      to: to
    }, options || {}));
  },
  update: function (position) {
    this.method(position);
  }
});
Effect.Event = Class.create(Effect.Base, {
  initialize: function () {
    this.start(Object.extend({
      duration: 0
    }, arguments[0] || {}));
  },
  update: Prototype.emptyFunction
});
Effect.Opacity = Class.create(Effect.Base, {
  initialize: function (element) {
    this.element = $(element);
    if (!this.element) throw Effect._elementDoesNotExistError;
    // make this work on IE on elements without 'layout'
    if (Prototype.Browser.IE && !this.element.currentStyle.hasLayout) this.element.setStyle({
      zoom: 1
    });
    var options = Object.extend({
      from: this.element.getOpacity() || 0.0,
      to: 1.0
    }, arguments[1] || {});
    this.start(options);
  },
  update: function (position) {
    this.element.setOpacity(position);
  }
});
Effect.Move = Class.create(Effect.Base, {
  initialize: function (element) {
    this.element = $(element);
    if (!this.element) throw Effect._elementDoesNotExistError;
    var options = Object.extend({
      x: 0,
      y: 0,
      mode: 'relative'
    }, arguments[1] || {});
    this.start(options);
  },
  setup: function () {
    this.element.makePositioned();
    this.originalLeft = parseFloat(this.element.getStyle('left') || '0');
    this.originalTop = parseFloat(this.element.getStyle('top') || '0');
    if (this.options.mode == 'absolute') {
      this.options.x = this.options.x - this.originalLeft;
      this.options.y = this.options.y - this.originalTop;
    }
  },
  update: function (position) {
    this.element.setStyle({
      left: (this.options.x * position + this.originalLeft).round() + 'px',
      top: (this.options.y * position + this.originalTop).round() + 'px'
    });
  }
});

// for backwards compatibility
Effect.MoveBy = function (element, toTop, toLeft) {
  return new Effect.Move(element, Object.extend({
    x: toLeft,
    y: toTop
  }, arguments[3] || {}));
};
Effect.Scale = Class.create(Effect.Base, {
  initialize: function (element, percent) {
    this.element = $(element);
    if (!this.element) throw Effect._elementDoesNotExistError;
    var options = Object.extend({
      scaleX: true,
      scaleY: true,
      scaleContent: true,
      scaleFromCenter: false,
      scaleMode: 'box',
      // 'box' or 'contents' or { } with provided values
      scaleFrom: 100.0,
      scaleTo: percent
    }, arguments[2] || {});
    this.start(options);
  },
  setup: function () {
    this.restoreAfterFinish = this.options.restoreAfterFinish || false;
    this.elementPositioning = this.element.getStyle('position');
    this.originalStyle = {};
    ['top', 'left', 'width', 'height', 'fontSize'].each(function (k) {
      this.originalStyle[k] = this.element.style[k];
    }.bind(this));
    this.originalTop = this.element.offsetTop;
    this.originalLeft = this.element.offsetLeft;
    var fontSize = this.element.getStyle('font-size') || '100%';
    ['em', 'px', '%', 'pt'].each(function (fontSizeType) {
      if (fontSize.indexOf(fontSizeType) > 0) {
        this.fontSize = parseFloat(fontSize);
        this.fontSizeType = fontSizeType;
      }
    }.bind(this));
    this.factor = (this.options.scaleTo - this.options.scaleFrom) / 100;
    this.dims = null;
    if (this.options.scaleMode == 'box') this.dims = [this.element.offsetHeight, this.element.offsetWidth];
    if (/^content/.test(this.options.scaleMode)) this.dims = [this.element.scrollHeight, this.element.scrollWidth];
    if (!this.dims) this.dims = [this.options.scaleMode.originalHeight, this.options.scaleMode.originalWidth];
  },
  update: function (position) {
    var currentScale = this.options.scaleFrom / 100.0 + this.factor * position;
    if (this.options.scaleContent && this.fontSize) this.element.setStyle({
      fontSize: this.fontSize * currentScale + this.fontSizeType
    });
    this.setDimensions(this.dims[0] * currentScale, this.dims[1] * currentScale);
  },
  finish: function (position) {
    if (this.restoreAfterFinish) this.element.setStyle(this.originalStyle);
  },
  setDimensions: function (height, width) {
    var d = {};
    if (this.options.scaleX) d.width = width.round() + 'px';
    if (this.options.scaleY) d.height = height.round() + 'px';
    if (this.options.scaleFromCenter) {
      var topd = (height - this.dims[0]) / 2;
      var leftd = (width - this.dims[1]) / 2;
      if (this.elementPositioning == 'absolute') {
        if (this.options.scaleY) d.top = this.originalTop - topd + 'px';
        if (this.options.scaleX) d.left = this.originalLeft - leftd + 'px';
      } else {
        if (this.options.scaleY) d.top = -topd + 'px';
        if (this.options.scaleX) d.left = -leftd + 'px';
      }
    }
    this.element.setStyle(d);
  }
});
Effect.Highlight = Class.create(Effect.Base, {
  initialize: function (element) {
    this.element = $(element);
    if (!this.element) throw Effect._elementDoesNotExistError;
    var options = Object.extend({
      startcolor: '#ffff99'
    }, arguments[1] || {});
    this.start(options);
  },
  setup: function () {
    // Prevent executing on elements not in the layout flow
    if (this.element.getStyle('display') == 'none') {
      this.cancel();
      return;
    }
    // Disable background image during the effect
    this.oldStyle = {};
    if (!this.options.keepBackgroundImage) {
      this.oldStyle.backgroundImage = this.element.getStyle('background-image');
      this.element.setStyle({
        backgroundImage: 'none'
      });
    }
    if (!this.options.endcolor) this.options.endcolor = this.element.getStyle('background-color').parseColor('#ffffff');
    if (!this.options.restorecolor) this.options.restorecolor = this.element.getStyle('background-color');
    // init color calculations
    this._base = $R(0, 2).map(function (i) {
      return parseInt(this.options.startcolor.slice(i * 2 + 1, i * 2 + 3), 16);
    }.bind(this));
    this._delta = $R(0, 2).map(function (i) {
      return parseInt(this.options.endcolor.slice(i * 2 + 1, i * 2 + 3), 16) - this._base[i];
    }.bind(this));
  },
  update: function (position) {
    this.element.setStyle({
      backgroundColor: $R(0, 2).inject('#', function (m, v, i) {
        return m + (this._base[i] + this._delta[i] * position).round().toColorPart();
      }.bind(this))
    });
  },
  finish: function () {
    this.element.setStyle(Object.extend(this.oldStyle, {
      backgroundColor: this.options.restorecolor
    }));
  }
});
Effect.ScrollTo = function (element) {
  var options = arguments[1] || {},
    scrollOffsets = document.viewport.getScrollOffsets(),
    elementOffsets = $(element).cumulativeOffset();
  if (options.offset) elementOffsets[1] += options.offset;
  return new Effect.Tween(null, scrollOffsets.top, elementOffsets[1], options, function (p) {
    scrollTo(scrollOffsets.left, p.round());
  });
};

/* ------------- combination effects ------------- */

Effect.Fade = function (element) {
  element = $(element);
  var oldOpacity = element.getInlineOpacity();
  var options = Object.extend({
    from: element.getOpacity() || 1.0,
    to: 0.0,
    afterFinishInternal: function (effect) {
      if (effect.options.to != 0) return;
      effect.element.hide().setStyle({
        opacity: oldOpacity
      });
    }
  }, arguments[1] || {});
  return new Effect.Opacity(element, options);
};
Effect.Appear = function (element) {
  element = $(element);
  var options = Object.extend({
    from: element.getStyle('display') == 'none' ? 0.0 : element.getOpacity() || 0.0,
    to: 1.0,
    // force Safari to render floated elements properly
    afterFinishInternal: function (effect) {
      effect.element.forceRerendering();
    },
    beforeSetup: function (effect) {
      effect.element.setOpacity(effect.options.from).show();
    }
  }, arguments[1] || {});
  return new Effect.Opacity(element, options);
};
Effect.Puff = function (element) {
  element = $(element);
  var oldStyle = {
    opacity: element.getInlineOpacity(),
    position: element.getStyle('position'),
    top: element.style.top,
    left: element.style.left,
    width: element.style.width,
    height: element.style.height
  };
  return new Effect.Parallel([new Effect.Scale(element, 200, {
    sync: true,
    scaleFromCenter: true,
    scaleContent: true,
    restoreAfterFinish: true
  }), new Effect.Opacity(element, {
    sync: true,
    to: 0.0
  })], Object.extend({
    duration: 1.0,
    beforeSetupInternal: function (effect) {
      Position.absolutize(effect.effects[0].element);
    },
    afterFinishInternal: function (effect) {
      effect.effects[0].element.hide().setStyle(oldStyle);
    }
  }, arguments[1] || {}));
};
Effect.BlindUp = function (element) {
  element = $(element);
  element.makeClipping();
  return new Effect.Scale(element, 0, Object.extend({
    scaleContent: false,
    scaleX: false,
    restoreAfterFinish: true,
    afterFinishInternal: function (effect) {
      effect.element.hide().undoClipping();
    }
  }, arguments[1] || {}));
};
Effect.BlindDown = function (element) {
  element = $(element);
  var elementDimensions = element.getDimensions();
  return new Effect.Scale(element, 100, Object.extend({
    scaleContent: false,
    scaleX: false,
    scaleFrom: 0,
    scaleMode: {
      originalHeight: elementDimensions.height,
      originalWidth: elementDimensions.width
    },
    restoreAfterFinish: true,
    afterSetup: function (effect) {
      effect.element.makeClipping().setStyle({
        height: '0px'
      }).show();
    },
    afterFinishInternal: function (effect) {
      effect.element.undoClipping();
    }
  }, arguments[1] || {}));
};
Effect.SwitchOff = function (element) {
  element = $(element);
  var oldOpacity = element.getInlineOpacity();
  return new Effect.Appear(element, Object.extend({
    duration: 0.4,
    from: 0,
    transition: Effect.Transitions.flicker,
    afterFinishInternal: function (effect) {
      new Effect.Scale(effect.element, 1, {
        duration: 0.3,
        scaleFromCenter: true,
        scaleX: false,
        scaleContent: false,
        restoreAfterFinish: true,
        beforeSetup: function (effect) {
          effect.element.makePositioned().makeClipping();
        },
        afterFinishInternal: function (effect) {
          effect.element.hide().undoClipping().undoPositioned().setStyle({
            opacity: oldOpacity
          });
        }
      });
    }
  }, arguments[1] || {}));
};
Effect.DropOut = function (element) {
  element = $(element);
  var oldStyle = {
    top: element.getStyle('top'),
    left: element.getStyle('left'),
    opacity: element.getInlineOpacity()
  };
  return new Effect.Parallel([new Effect.Move(element, {
    x: 0,
    y: 100,
    sync: true
  }), new Effect.Opacity(element, {
    sync: true,
    to: 0.0
  })], Object.extend({
    duration: 0.5,
    beforeSetup: function (effect) {
      effect.effects[0].element.makePositioned();
    },
    afterFinishInternal: function (effect) {
      effect.effects[0].element.hide().undoPositioned().setStyle(oldStyle);
    }
  }, arguments[1] || {}));
};
Effect.Shake = function (element) {
  element = $(element);
  var options = Object.extend({
    distance: 20,
    duration: 0.5
  }, arguments[1] || {});
  var distance = parseFloat(options.distance);
  var split = parseFloat(options.duration) / 10.0;
  var oldStyle = {
    top: element.getStyle('top'),
    left: element.getStyle('left')
  };
  return new Effect.Move(element, {
    x: distance,
    y: 0,
    duration: split,
    afterFinishInternal: function (effect) {
      new Effect.Move(effect.element, {
        x: -distance * 2,
        y: 0,
        duration: split * 2,
        afterFinishInternal: function (effect) {
          new Effect.Move(effect.element, {
            x: distance * 2,
            y: 0,
            duration: split * 2,
            afterFinishInternal: function (effect) {
              new Effect.Move(effect.element, {
                x: -distance * 2,
                y: 0,
                duration: split * 2,
                afterFinishInternal: function (effect) {
                  new Effect.Move(effect.element, {
                    x: distance * 2,
                    y: 0,
                    duration: split * 2,
                    afterFinishInternal: function (effect) {
                      new Effect.Move(effect.element, {
                        x: -distance,
                        y: 0,
                        duration: split,
                        afterFinishInternal: function (effect) {
                          effect.element.undoPositioned().setStyle(oldStyle);
                        }
                      });
                    }
                  });
                }
              });
            }
          });
        }
      });
    }
  });
};
Effect.SlideDown = function (element) {
  element = $(element).cleanWhitespace();
  // SlideDown need to have the content of the element wrapped in a container element with fixed height!
  var oldInnerBottom = element.down().getStyle('bottom');
  var elementDimensions = element.getDimensions();
  return new Effect.Scale(element, 100, Object.extend({
    scaleContent: false,
    scaleX: false,
    scaleFrom: window.opera ? 0 : 1,
    scaleMode: {
      originalHeight: elementDimensions.height,
      originalWidth: elementDimensions.width
    },
    restoreAfterFinish: true,
    afterSetup: function (effect) {
      effect.element.makePositioned();
      effect.element.down().makePositioned();
      if (window.opera) effect.element.setStyle({
        top: ''
      });
      effect.element.makeClipping().setStyle({
        height: '0px'
      }).show();
    },
    afterUpdateInternal: function (effect) {
      effect.element.down().setStyle({
        bottom: effect.dims[0] - effect.element.clientHeight + 'px'
      });
    },
    afterFinishInternal: function (effect) {
      effect.element.undoClipping().undoPositioned();
      effect.element.down().undoPositioned().setStyle({
        bottom: oldInnerBottom
      });
    }
  }, arguments[1] || {}));
};
Effect.SlideUp = function (element) {
  element = $(element).cleanWhitespace();
  var oldInnerBottom = element.down().getStyle('bottom');
  var elementDimensions = element.getDimensions();
  return new Effect.Scale(element, window.opera ? 0 : 1, Object.extend({
    scaleContent: false,
    scaleX: false,
    scaleMode: 'box',
    scaleFrom: 100,
    scaleMode: {
      originalHeight: elementDimensions.height,
      originalWidth: elementDimensions.width
    },
    restoreAfterFinish: true,
    afterSetup: function (effect) {
      effect.element.makePositioned();
      effect.element.down().makePositioned();
      if (window.opera) effect.element.setStyle({
        top: ''
      });
      effect.element.makeClipping().show();
    },
    afterUpdateInternal: function (effect) {
      effect.element.down().setStyle({
        bottom: effect.dims[0] - effect.element.clientHeight + 'px'
      });
    },
    afterFinishInternal: function (effect) {
      effect.element.hide().undoClipping().undoPositioned();
      effect.element.down().undoPositioned().setStyle({
        bottom: oldInnerBottom
      });
    }
  }, arguments[1] || {}));
};

// Bug in opera makes the TD containing this element expand for a instance after finish
Effect.Squish = function (element) {
  return new Effect.Scale(element, window.opera ? 1 : 0, {
    restoreAfterFinish: true,
    beforeSetup: function (effect) {
      effect.element.makeClipping();
    },
    afterFinishInternal: function (effect) {
      effect.element.hide().undoClipping();
    }
  });
};
Effect.Grow = function (element) {
  element = $(element);
  var options = Object.extend({
    direction: 'center',
    moveTransition: Effect.Transitions.sinoidal,
    scaleTransition: Effect.Transitions.sinoidal,
    opacityTransition: Effect.Transitions.full
  }, arguments[1] || {});
  var oldStyle = {
    top: element.style.top,
    left: element.style.left,
    height: element.style.height,
    width: element.style.width,
    opacity: element.getInlineOpacity()
  };
  var dims = element.getDimensions();
  var initialMoveX, initialMoveY;
  var moveX, moveY;
  switch (options.direction) {
    case 'top-left':
      initialMoveX = initialMoveY = moveX = moveY = 0;
      break;
    case 'top-right':
      initialMoveX = dims.width;
      initialMoveY = moveY = 0;
      moveX = -dims.width;
      break;
    case 'bottom-left':
      initialMoveX = moveX = 0;
      initialMoveY = dims.height;
      moveY = -dims.height;
      break;
    case 'bottom-right':
      initialMoveX = dims.width;
      initialMoveY = dims.height;
      moveX = -dims.width;
      moveY = -dims.height;
      break;
    case 'center':
      initialMoveX = dims.width / 2;
      initialMoveY = dims.height / 2;
      moveX = -dims.width / 2;
      moveY = -dims.height / 2;
      break;
  }
  return new Effect.Move(element, {
    x: initialMoveX,
    y: initialMoveY,
    duration: 0.01,
    beforeSetup: function (effect) {
      effect.element.hide().makeClipping().makePositioned();
    },
    afterFinishInternal: function (effect) {
      new Effect.Parallel([new Effect.Opacity(effect.element, {
        sync: true,
        to: 1.0,
        from: 0.0,
        transition: options.opacityTransition
      }), new Effect.Move(effect.element, {
        x: moveX,
        y: moveY,
        sync: true,
        transition: options.moveTransition
      }), new Effect.Scale(effect.element, 100, {
        scaleMode: {
          originalHeight: dims.height,
          originalWidth: dims.width
        },
        sync: true,
        scaleFrom: window.opera ? 1 : 0,
        transition: options.scaleTransition,
        restoreAfterFinish: true
      })], Object.extend({
        beforeSetup: function (effect) {
          effect.effects[0].element.setStyle({
            height: '0px'
          }).show();
        },
        afterFinishInternal: function (effect) {
          effect.effects[0].element.undoClipping().undoPositioned().setStyle(oldStyle);
        }
      }, options));
    }
  });
};
Effect.Shrink = function (element) {
  element = $(element);
  var options = Object.extend({
    direction: 'center',
    moveTransition: Effect.Transitions.sinoidal,
    scaleTransition: Effect.Transitions.sinoidal,
    opacityTransition: Effect.Transitions.none
  }, arguments[1] || {});
  var oldStyle = {
    top: element.style.top,
    left: element.style.left,
    height: element.style.height,
    width: element.style.width,
    opacity: element.getInlineOpacity()
  };
  var dims = element.getDimensions();
  var moveX, moveY;
  switch (options.direction) {
    case 'top-left':
      moveX = moveY = 0;
      break;
    case 'top-right':
      moveX = dims.width;
      moveY = 0;
      break;
    case 'bottom-left':
      moveX = 0;
      moveY = dims.height;
      break;
    case 'bottom-right':
      moveX = dims.width;
      moveY = dims.height;
      break;
    case 'center':
      moveX = dims.width / 2;
      moveY = dims.height / 2;
      break;
  }
  return new Effect.Parallel([new Effect.Opacity(element, {
    sync: true,
    to: 0.0,
    from: 1.0,
    transition: options.opacityTransition
  }), new Effect.Scale(element, window.opera ? 1 : 0, {
    sync: true,
    transition: options.scaleTransition,
    restoreAfterFinish: true
  }), new Effect.Move(element, {
    x: moveX,
    y: moveY,
    sync: true,
    transition: options.moveTransition
  })], Object.extend({
    beforeStartInternal: function (effect) {
      effect.effects[0].element.makePositioned().makeClipping();
    },
    afterFinishInternal: function (effect) {
      effect.effects[0].element.hide().undoClipping().undoPositioned().setStyle(oldStyle);
    }
  }, options));
};
Effect.Pulsate = function (element) {
  element = $(element);
  var options = arguments[1] || {},
    oldOpacity = element.getInlineOpacity(),
    transition = options.transition || Effect.Transitions.linear,
    reverser = function (pos) {
      return 1 - transition(-Math.cos(pos * (options.pulses || 5) * 2 * Math.PI) / 2 + .5);
    };
  return new Effect.Opacity(element, Object.extend(Object.extend({
    duration: 2.0,
    from: 0,
    afterFinishInternal: function (effect) {
      effect.element.setStyle({
        opacity: oldOpacity
      });
    }
  }, options), {
    transition: reverser
  }));
};
Effect.Fold = function (element) {
  element = $(element);
  var oldStyle = {
    top: element.style.top,
    left: element.style.left,
    width: element.style.width,
    height: element.style.height
  };
  element.makeClipping();
  return new Effect.Scale(element, 5, Object.extend({
    scaleContent: false,
    scaleX: false,
    afterFinishInternal: function (effect) {
      new Effect.Scale(element, 1, {
        scaleContent: false,
        scaleY: false,
        afterFinishInternal: function (effect) {
          effect.element.hide().undoClipping().setStyle(oldStyle);
        }
      });
    }
  }, arguments[1] || {}));
};
Effect.Morph = Class.create(Effect.Base, {
  initialize: function (element) {
    this.element = $(element);
    if (!this.element) throw Effect._elementDoesNotExistError;
    var options = Object.extend({
      style: {}
    }, arguments[1] || {});
    if (!Object.isString(options.style)) this.style = $H(options.style);else {
      if (options.style.include(':')) this.style = options.style.parseStyle();else {
        this.element.addClassName(options.style);
        this.style = $H(this.element.getStyles());
        this.element.removeClassName(options.style);
        var css = this.element.getStyles();
        this.style = this.style.reject(function (style) {
          return style.value == css[style.key];
        });
        options.afterFinishInternal = function (effect) {
          effect.element.addClassName(effect.options.style);
          effect.transforms.each(function (transform) {
            effect.element.style[transform.style] = '';
          });
        };
      }
    }
    this.start(options);
  },
  setup: function () {
    function parseColor(color) {
      if (!color || ['rgba(0, 0, 0, 0)', 'transparent'].include(color)) color = '#ffffff';
      color = color.parseColor();
      return $R(0, 2).map(function (i) {
        return parseInt(color.slice(i * 2 + 1, i * 2 + 3), 16);
      });
    }
    this.transforms = this.style.map(function (pair) {
      var property = pair[0],
        value = pair[1],
        unit = null;
      if (value.parseColor('#zzzzzz') != '#zzzzzz') {
        value = value.parseColor();
        unit = 'color';
      } else if (property == 'opacity') {
        value = parseFloat(value);
        if (Prototype.Browser.IE && !this.element.currentStyle.hasLayout) this.element.setStyle({
          zoom: 1
        });
      } else if (Element.CSS_LENGTH.test(value)) {
        var components = value.match(/^([\+\-]?[0-9\.]+)(.*)$/);
        value = parseFloat(components[1]);
        unit = components.length == 3 ? components[2] : null;
      }
      var originalValue = this.element.getStyle(property);
      return {
        style: property.camelize(),
        originalValue: unit == 'color' ? parseColor(originalValue) : parseFloat(originalValue || 0),
        targetValue: unit == 'color' ? parseColor(value) : value,
        unit: unit
      };
    }.bind(this)).reject(function (transform) {
      return transform.originalValue == transform.targetValue || transform.unit != 'color' && (isNaN(transform.originalValue) || isNaN(transform.targetValue));
    });
  },
  update: function (position) {
    var style = {},
      transform,
      i = this.transforms.length;
    while (i--) style[(transform = this.transforms[i]).style] = transform.unit == 'color' ? '#' + Math.round(transform.originalValue[0] + (transform.targetValue[0] - transform.originalValue[0]) * position).toColorPart() + Math.round(transform.originalValue[1] + (transform.targetValue[1] - transform.originalValue[1]) * position).toColorPart() + Math.round(transform.originalValue[2] + (transform.targetValue[2] - transform.originalValue[2]) * position).toColorPart() : (transform.originalValue + (transform.targetValue - transform.originalValue) * position).toFixed(3) + (transform.unit === null ? '' : transform.unit);
    this.element.setStyle(style, true);
  }
});
Effect.Transform = Class.create({
  initialize: function (tracks) {
    this.tracks = [];
    this.options = arguments[1] || {};
    this.addTracks(tracks);
  },
  addTracks: function (tracks) {
    tracks.each(function (track) {
      track = $H(track);
      var data = track.values().first();
      this.tracks.push($H({
        ids: track.keys().first(),
        effect: Effect.Morph,
        options: {
          style: data
        }
      }));
    }.bind(this));
    return this;
  },
  play: function () {
    return new Effect.Parallel(this.tracks.map(function (track) {
      var ids = track.get('ids'),
        effect = track.get('effect'),
        options = track.get('options');
      var elements = [$(ids) || $$(ids)].flatten();
      return elements.map(function (e) {
        return new effect(e, Object.extend({
          sync: true
        }, options));
      });
    }).flatten(), this.options);
  }
});
Element.CSS_PROPERTIES = $w('backgroundColor backgroundPosition borderBottomColor borderBottomStyle ' + 'borderBottomWidth borderLeftColor borderLeftStyle borderLeftWidth ' + 'borderRightColor borderRightStyle borderRightWidth borderSpacing ' + 'borderTopColor borderTopStyle borderTopWidth bottom clip color ' + 'fontSize fontWeight height left letterSpacing lineHeight ' + 'marginBottom marginLeft marginRight marginTop markerOffset maxHeight ' + 'maxWidth minHeight minWidth opacity outlineColor outlineOffset ' + 'outlineWidth paddingBottom paddingLeft paddingRight paddingTop ' + 'right textIndent top width wordSpacing zIndex');
Element.CSS_LENGTH = /^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/;
String.__parseStyleElement = document.createElement('div');
String.prototype.parseStyle = function () {
  var style,
    styleRules = $H();
  if (Prototype.Browser.WebKit) style = new Element('div', {
    style: this
  }).style;else {
    String.__parseStyleElement.innerHTML = '<div style="' + this + '"></div>';
    style = String.__parseStyleElement.childNodes[0].style;
  }
  Element.CSS_PROPERTIES.each(function (property) {
    if (style[property]) styleRules.set(property, style[property]);
  });
  if (Prototype.Browser.IE && this.include('opacity')) styleRules.set('opacity', this.match(/opacity:\s*((?:0|1)?(?:\.\d*)?)/)[1]);
  return styleRules;
};
if (document.defaultView && document.defaultView.getComputedStyle) {
  Element.getStyles = function (element) {
    var css = document.defaultView.getComputedStyle($(element), null);
    return Element.CSS_PROPERTIES.inject({}, function (styles, property) {
      styles[property] = css[property];
      return styles;
    });
  };
} else {
  Element.getStyles = function (element) {
    element = $(element);
    var css = element.currentStyle,
      styles;
    styles = Element.CSS_PROPERTIES.inject({}, function (results, property) {
      results[property] = css[property];
      return results;
    });
    if (!styles.opacity) styles.opacity = element.getOpacity();
    return styles;
  };
}
Effect.Methods = {
  morph: function (element, style) {
    element = $(element);
    new Effect.Morph(element, Object.extend({
      style: style
    }, arguments[2] || {}));
    return element;
  },
  visualEffect: function (element, effect, options) {
    element = $(element);
    var s = effect.dasherize().camelize(),
      klass = s.charAt(0).toUpperCase() + s.substring(1);
    new Effect[klass](element, options);
    return element;
  },
  highlight: function (element, options) {
    element = $(element);
    new Effect.Highlight(element, options);
    return element;
  }
};
$w('fade appear grow shrink fold blindUp blindDown slideUp slideDown ' + 'pulsate shake puff squish switchOff dropOut').each(function (effect) {
  Effect.Methods[effect] = function (element, options) {
    element = $(element);
    Effect[effect.charAt(0).toUpperCase() + effect.substring(1)](element, options);
    return element;
  };
});
$w('getInlineOpacity forceRerendering setContentZoom collectTextNodes collectTextNodesIgnoreClass getStyles').each(function (f) {
  Effect.Methods[f] = Element[f];
});
Element.addMethods(Effect.Methods);
// script.aculo.us controls.js v1.9.0, Thu Dec 23 16:54:48 -0500 2010

// Copyright (c) 2005-2010 Thomas Fuchs (http://script.aculo.us, http://mir.aculo.us)
//           (c) 2005-2010 Ivan Krstic (http://blogs.law.harvard.edu/ivan)
//           (c) 2005-2010 Jon Tirsen (http://www.tirsen.com)
// Contributors:
//  Richard Livsey
//  Rahul Bhargava
//  Rob Wills
//
// script.aculo.us is freely distributable under the terms of an MIT-style license.
// For details, see the script.aculo.us web site: http://script.aculo.us/

// Autocompleter.Base handles all the autocompletion functionality
// that's independent of the data source for autocompletion. This
// includes drawing the autocompletion menu, observing keyboard
// and mouse events, and similar.
//
// Specific autocompleters need to provide, at the very least,
// a getUpdatedChoices function that will be invoked every time
// the text inside the monitored textbox changes. This method
// should get the text for which to provide autocompletion by
// invoking this.getToken(), NOT by directly accessing
// this.element.value. This is to allow incremental tokenized
// autocompletion. Specific auto-completion logic (AJAX, etc)
// belongs in getUpdatedChoices.
//
// Tokenized incremental autocompletion is enabled automatically
// when an autocompleter is instantiated with the 'tokens' option
// in the options parameter, e.g.:
// new Ajax.Autocompleter('id','upd', '/url/', { tokens: ',' });
// will incrementally autocomplete with a comma as the token.
// Additionally, ',' in the above example can be replaced with
// a token array, e.g. { tokens: [',', '\n'] } which
// enables autocompletion on multiple tokens. This is most
// useful when one of the tokens is \n (a newline), as it
// allows smart autocompletion after linebreaks.

if (typeof Effect == 'undefined') throw "controls.js requires including script.aculo.us' effects.js library";
var Autocompleter = {};
Autocompleter.Base = Class.create({
  baseInitialize: function (element, update, options) {
    element = $(element);
    this.element = element;
    this.update = $(update);
    this.hasFocus = false;
    this.changed = false;
    this.active = false;
    this.startIndex = options.suggest ? -1 : 0;
    this.index = this.startIndex;
    this.entryCount = 0;
    this.oldElementValue = this.element.value;
    if (this.setOptions) this.setOptions(options);else this.options = options || {};
    this.options.paramName = this.options.paramName || this.element.name;
    this.options.tokens = this.options.tokens || [];
    this.options.frequency = this.options.frequency || 0.4;
    this.options.minChars = this.options.minChars || 1;
    this.options.onShow = this.options.onShow || function (element, update) {
      // console.log(element, update, element.offsetHeight)
      if (!update.style.position || update.style.position == 'absolute') {
        update.style.position = 'absolute';
        Position.clone(element, update, {
          setHeight: false,
          offsetTop: element.height
        });
      }
      Effect.Appear(update, {
        duration: 0.15
      });
    };
    this.options.onHide = this.options.onHide || function (element, update) {
      new Effect.Fade(update, {
        duration: 0.15
      });
    };
    if (typeof this.options.tokens == 'string') this.options.tokens = new Array(this.options.tokens);
    // Force carriage returns as token delimiters anyway
    if (!this.options.tokens.include('\n')) this.options.tokens.push('\n');
    this.observer = null;
    this.element.setAttribute('autocomplete', 'off');
    Element.hide(this.update);
    Event.observe(this.element, 'blur', this.onBlur.bindAsEventListener(this));
    Event.observe(this.element, 'keydown', this.onKeyPress.bindAsEventListener(this));
  },
  show: function () {
    if (Element.getStyle(this.update, 'display') == 'none') this.options.onShow(this.element, this.update);
    if (!this.iefix && Prototype.Browser.IE && Element.getStyle(this.update, 'position') == 'absolute') {
      new Insertion.After(this.update, '<iframe id="' + this.update.id + '_iefix" ' + 'style="display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" ' + 'src="javascript:false;" frameborder="0" scrolling="no"></iframe>');
      this.iefix = $(this.update.id + '_iefix');
    }
    if (this.iefix) setTimeout(this.fixIEOverlapping.bind(this), 50);
  },
  fixIEOverlapping: function () {
    Position.clone(this.update, this.iefix, {
      setTop: !this.update.style.height
    });
    this.iefix.style.zIndex = 1;
    this.update.style.zIndex = 2;
    Element.show(this.iefix);
  },
  hide: function () {
    this.stopIndicator();
    if (Element.getStyle(this.update, 'display') != 'none') this.options.onHide(this.element, this.update);
    if (this.iefix) Element.hide(this.iefix);
  },
  startIndicator: function () {
    if (this.options.indicator) Element.show(this.options.indicator);
  },
  stopIndicator: function () {
    if (this.options.indicator) Element.hide(this.options.indicator);
  },
  onKeyPress: function (event) {
    if (this.active) switch (event.keyCode) {
      case Event.KEY_TAB:
      case Event.KEY_RETURN:
        this.selectEntry();
        if (this.index < 0) {
          this.hide();
          this.active = false;
          return;
        }
        Event.stop(event);
      case Event.KEY_ESC:
        this.hide();
        this.active = false;
        Event.stop(event);
        return;
      case Event.KEY_LEFT:
      case Event.KEY_RIGHT:
        return;
      case Event.KEY_UP:
        this.markPrevious();
        this.render();
        Event.stop(event);
        return;
      case Event.KEY_DOWN:
        this.markNext();
        this.render();
        Event.stop(event);
        return;
    } else if (event.keyCode == Event.KEY_TAB || event.keyCode == Event.KEY_RETURN || Prototype.Browser.WebKit > 0 && event.keyCode == 0) return;
    this.changed = true;
    this.hasFocus = true;
    if (this.observer) clearTimeout(this.observer);
    this.observer = setTimeout(this.onObserverEvent.bind(this), this.options.frequency * 1000);
  },
  activate: function () {
    this.changed = false;
    this.hasFocus = true;
    this.getUpdatedChoices();
  },
  onHover: function (event) {
    var element = Event.findElement(event, 'LI');
    if (this.index != element.autocompleteIndex) {
      this.index = element.autocompleteIndex;
      this.render();
    }
    Event.stop(event);
  },
  onClick: function (event) {
    var element = Event.findElement(event, 'LI');
    this.index = element.autocompleteIndex;
    this.selectEntry();
    this.hide();
  },
  onBlur: function (event) {
    // needed to make click events working
    setTimeout(this.hide.bind(this), 250);
    this.hasFocus = false;
    this.active = false;
  },
  render: function () {
    if (this.entryCount > 0) {
      for (var i = 0; i < this.entryCount; i++) this.index == i ? Element.addClassName(this.getEntry(i), "selected") : Element.removeClassName(this.getEntry(i), "selected");
      if (this.hasFocus) {
        this.show();
        this.active = true;
      }
    } else {
      this.active = false;
      this.hide();
    }
  },
  markPrevious: function () {
    if (this.index > 0) this.index--;else this.index = this.entryCount - 1;
    this.getEntry(this.index).scrollIntoView(true);
  },
  markNext: function () {
    if (this.index < this.entryCount - 1) this.index++;else this.index = 0;
    this.getEntry(this.index).scrollIntoView(false);
  },
  getEntry: function (index) {
    return this.update.firstChild.childNodes[index];
  },
  getCurrentEntry: function () {
    return this.getEntry(this.index);
  },
  selectEntry: function () {
    this.active = false;
    if (this.index >= 0) this.updateElement(this.getCurrentEntry());
  },
  updateElement: function (selectedElement) {
    if (this.options.updateElement) {
      this.options.updateElement(selectedElement);
      return;
    }
    var value = '';
    if (this.options.select) {
      var nodes = $(selectedElement).select('.' + this.options.select) || [];
      if (nodes.length > 0) value = Element.collectTextNodes(nodes[0], this.options.select);
    } else value = Element.collectTextNodesIgnoreClass(selectedElement, 'informal');
    var bounds = this.getTokenBounds();
    if (bounds[0] != -1) {
      var newValue = this.element.value.substr(0, bounds[0]);
      var whitespace = this.element.value.substr(bounds[0]).match(/^\s+/);
      if (whitespace) newValue += whitespace[0];
      this.element.value = newValue + value + this.element.value.substr(bounds[1]);
    } else {
      this.element.value = value;
    }
    this.oldElementValue = this.element.value;
    this.element.focus();
    if (this.options.afterUpdateElement) this.options.afterUpdateElement(this.element, selectedElement);
  },
  updateChoices: function (choices) {
    if (!this.changed && this.hasFocus) {
      this.update.innerHTML = choices;
      Element.cleanWhitespace(this.update);
      Element.cleanWhitespace(this.update.down());
      if (this.update.firstChild && this.update.down().childNodes) {
        this.entryCount = this.update.down().childNodes.length;
        for (var i = 0; i < this.entryCount; i++) {
          var entry = this.getEntry(i);
          entry.autocompleteIndex = i;
          this.addObservers(entry);
        }
      } else {
        this.entryCount = 0;
      }
      this.stopIndicator();
      this.index = this.startIndex;
      if (this.entryCount == 1 && this.options.autoSelect) {
        this.selectEntry();
        this.hide();
      } else {
        this.render();
      }
    }
  },
  addObservers: function (element) {
    Event.observe(element, "mouseover", this.onHover.bindAsEventListener(this));
    Event.observe(element, "click", this.onClick.bindAsEventListener(this));
  },
  onObserverEvent: function () {
    this.changed = false;
    this.tokenBounds = null;
    if (this.getToken().length >= this.options.minChars) {
      this.getUpdatedChoices();
    } else {
      this.active = false;
      this.hide();
    }
    this.oldElementValue = this.element.value;
  },
  getToken: function () {
    var bounds = this.getTokenBounds();
    return this.element.value.substring(bounds[0], bounds[1]).strip();
  },
  getTokenBounds: function () {
    if (null != this.tokenBounds) return this.tokenBounds;
    var value = this.element.value;
    if (value.strip().empty()) return [-1, 0];
    var diff = arguments.callee.getFirstDifferencePos(value, this.oldElementValue);
    var offset = diff == this.oldElementValue.length ? 1 : 0;
    var prevTokenPos = -1,
      nextTokenPos = value.length;
    var tp;
    for (var index = 0, l = this.options.tokens.length; index < l; ++index) {
      tp = value.lastIndexOf(this.options.tokens[index], diff + offset - 1);
      if (tp > prevTokenPos) prevTokenPos = tp;
      tp = value.indexOf(this.options.tokens[index], diff + offset);
      if (-1 != tp && tp < nextTokenPos) nextTokenPos = tp;
    }
    return this.tokenBounds = [prevTokenPos + 1, nextTokenPos];
  }
});
Autocompleter.Base.prototype.getTokenBounds.getFirstDifferencePos = function (newS, oldS) {
  var boundary = Math.min(newS.length, oldS.length);
  for (var index = 0; index < boundary; ++index) if (newS[index] != oldS[index]) return index;
  return boundary;
};
Ajax.Autocompleter = Class.create(Autocompleter.Base, {
  initialize: function (element, update, url, options) {
    this.baseInitialize(element, update, options);
    this.options.asynchronous = true;
    this.options.onComplete = this.onComplete.bind(this);
    this.options.defaultParams = this.options.parameters || null;
    this.url = url;
  },
  getUpdatedChoices: function () {
    this.startIndicator();
    var entry = encodeURIComponent(this.options.paramName) + '=' + encodeURIComponent(this.getToken());
    this.options.parameters = this.options.callback ? this.options.callback(this.element, entry) : entry;
    if (this.options.defaultParams) this.options.parameters += '&' + this.options.defaultParams;

    // REWRITE: adds CSRF token and handle response content
    var meta = document.querySelector('meta[name=csrf-token]');
    if (meta) {
      this.options.requestHeaders = {
        'X-CSRF-Token': meta.content
      };
    }
    new Ajax.Request(this.url, this.options);
  },
  onComplete: function (request) {
    this.updateChoices(request.responseText);
  }
});

// The local array autocompleter. Used when you'd prefer to
// inject an array of autocompletion options into the page, rather
// than sending out Ajax queries, which can be quite slow sometimes.
//
// The constructor takes four parameters. The first two are, as usual,
// the id of the monitored textbox, and id of the autocompletion menu.
// The third is the array you want to autocomplete from, and the fourth
// is the options block.
//
// Extra local autocompletion options:
// - choices - How many autocompletion choices to offer
//
// - partialSearch - If false, the autocompleter will match entered
//                    text only at the beginning of strings in the
//                    autocomplete array. Defaults to true, which will
//                    match text at the beginning of any *word* in the
//                    strings in the autocomplete array. If you want to
//                    search anywhere in the string, additionally set
//                    the option fullSearch to true (default: off).
//
// - fullSsearch - Search anywhere in autocomplete array strings.
//
// - partialChars - How many characters to enter before triggering
//                   a partial match (unlike minChars, which defines
//                   how many characters are required to do any match
//                   at all). Defaults to 2.
//
// - ignoreCase - Whether to ignore case when autocompleting.
//                 Defaults to true.
//
// It's possible to pass in a custom function as the 'selector'
// option, if you prefer to write your own autocompletion logic.
// In that case, the other options above will not apply unless
// you support them.

Autocompleter.Local = Class.create(Autocompleter.Base, {
  initialize: function (element, update, array, options) {
    this.baseInitialize(element, update, options);
    this.options.array = array;
  },
  getUpdatedChoices: function () {
    this.updateChoices(this.options.selector(this));
  },
  setOptions: function (options) {
    this.options = Object.extend({
      choices: 10,
      partialSearch: true,
      partialChars: 2,
      ignoreCase: true,
      fullSearch: false,
      selector: function (instance) {
        var ret = []; // Beginning matches
        var partial = []; // Inside matches
        var entry = instance.getToken();
        var count = 0;
        for (var i = 0; i < instance.options.array.length && ret.length < instance.options.choices; i++) {
          var elem = instance.options.array[i];
          var foundPos = instance.options.ignoreCase ? elem.toLowerCase().indexOf(entry.toLowerCase()) : elem.indexOf(entry);
          while (foundPos != -1) {
            if (foundPos == 0 && elem.length != entry.length) {
              ret.push("<li><strong>" + elem.substr(0, entry.length) + "</strong>" + elem.substr(entry.length) + "</li>");
              break;
            } else if (entry.length >= instance.options.partialChars && instance.options.partialSearch && foundPos != -1) {
              if (instance.options.fullSearch || /\s/.test(elem.substr(foundPos - 1, 1))) {
                partial.push("<li>" + elem.substr(0, foundPos) + "<strong>" + elem.substr(foundPos, entry.length) + "</strong>" + elem.substr(foundPos + entry.length) + "</li>");
                break;
              }
            }
            foundPos = instance.options.ignoreCase ? elem.toLowerCase().indexOf(entry.toLowerCase(), foundPos + 1) : elem.indexOf(entry, foundPos + 1);
          }
        }
        if (partial.length) ret = ret.concat(partial.slice(0, instance.options.choices - ret.length));
        return "<ul>" + ret.join('') + "</ul>";
      }
    }, options || {});
  }
});

// AJAX in-place editor and collection editor
// Full rewrite by Christophe Porteneuve <tdd@tddsworld.com> (April 2007).

// Use this if you notice weird scrolling problems on some browsers,
// the DOM might be a bit confused when this gets called so do this
// waits 1 ms (with setTimeout) until it does the activation
Field.scrollFreeActivate = function (field) {
  setTimeout(function () {
    Field.activate(field);
  }, 1);
};
Ajax.InPlaceEditor = Class.create({
  initialize: function (element, url, options) {
    this.url = url;
    this.element = element = $(element);
    this.prepareOptions();
    this._controls = {};
    arguments.callee.dealWithDeprecatedOptions(options); // DEPRECATION LAYER!!!
    Object.extend(this.options, options || {});
    if (!this.options.formId && this.element.id) {
      this.options.formId = this.element.id + '-inplaceeditor';
      if ($(this.options.formId)) this.options.formId = '';
    }
    if (this.options.externalControl) this.options.externalControl = $(this.options.externalControl);
    if (!this.options.externalControl) this.options.externalControlOnly = false;
    this._originalBackground = this.element.getStyle('background-color') || 'transparent';
    this.element.title = this.options.clickToEditText;
    this._boundCancelHandler = this.handleFormCancellation.bind(this);
    this._boundComplete = (this.options.onComplete || Prototype.emptyFunction).bind(this);
    this._boundFailureHandler = this.handleAJAXFailure.bind(this);
    this._boundSubmitHandler = this.handleFormSubmission.bind(this);
    this._boundWrapperHandler = this.wrapUp.bind(this);
    this.registerListeners();
  },
  checkForEscapeOrReturn: function (e) {
    if (!this._editing || e.ctrlKey || e.altKey || e.shiftKey) return;
    if (Event.KEY_ESC == e.keyCode) this.handleFormCancellation(e);else if (Event.KEY_RETURN == e.keyCode) this.handleFormSubmission(e);
  },
  createControl: function (mode, handler, extraClasses) {
    var control = this.options[mode + 'Control'];
    var text = this.options[mode + 'Text'];
    if ('button' == control) {
      var btn = document.createElement('input');
      btn.type = 'submit';
      btn.value = text;
      btn.className = 'editor_' + mode + '_button';
      if ('cancel' == mode) btn.onclick = this._boundCancelHandler;
      this._form.appendChild(btn);
      this._controls[mode] = btn;
    } else if ('link' == control) {
      var link = document.createElement('a');
      link.href = '#';
      link.appendChild(document.createTextNode(text));
      link.onclick = 'cancel' == mode ? this._boundCancelHandler : this._boundSubmitHandler;
      link.className = 'editor_' + mode + '_link';
      if (extraClasses) link.className += ' ' + extraClasses;
      this._form.appendChild(link);
      this._controls[mode] = link;
    }
  },
  createEditField: function () {
    var text = this.options.loadTextURL ? this.options.loadingText : this.getText();
    var fld;
    if (1 >= this.options.rows && !/\r|\n/.test(this.getText())) {
      fld = document.createElement('input');
      fld.type = 'text';
      var size = this.options.size || this.options.cols || 0;
      if (0 < size) fld.size = size;
    } else {
      fld = document.createElement('textarea');
      fld.rows = 1 >= this.options.rows ? this.options.autoRows : this.options.rows;
      fld.cols = this.options.cols || 40;
    }
    fld.name = this.options.paramName;
    fld.value = text; // No HTML breaks conversion anymore
    fld.className = 'editor_field';
    if (this.options.submitOnBlur) fld.onblur = this._boundSubmitHandler;
    this._controls.editor = fld;
    if (this.options.loadTextURL) this.loadExternalText();
    this._form.appendChild(this._controls.editor);
  },
  createForm: function () {
    var ipe = this;
    function addText(mode, condition) {
      var text = ipe.options['text' + mode + 'Controls'];
      if (!text || condition === false) return;
      ipe._form.appendChild(document.createTextNode(text));
    }
    ;
    this._form = $(document.createElement('form'));
    this._form.id = this.options.formId;
    this._form.addClassName(this.options.formClassName);
    this._form.onsubmit = this._boundSubmitHandler;
    this.createEditField();
    if ('textarea' == this._controls.editor.tagName.toLowerCase()) this._form.appendChild(document.createElement('br'));
    if (this.options.onFormCustomization) this.options.onFormCustomization(this, this._form);
    addText('Before', this.options.okControl || this.options.cancelControl);
    this.createControl('ok', this._boundSubmitHandler);
    addText('Between', this.options.okControl && this.options.cancelControl);
    this.createControl('cancel', this._boundCancelHandler, 'editor_cancel');
    addText('After', this.options.okControl || this.options.cancelControl);
  },
  destroy: function () {
    if (this._oldInnerHTML) this.element.innerHTML = this._oldInnerHTML;
    this.leaveEditMode();
    this.unregisterListeners();
  },
  enterEditMode: function (e) {
    if (this._saving || this._editing) return;
    this._editing = true;
    this.triggerCallback('onEnterEditMode');
    if (this.options.externalControl) this.options.externalControl.hide();
    if (this.options.elementHideClass) this.element.addClassName(this.options.elementHideClass);else this.element.hide();
    this.createForm();
    this.element.parentNode.insertBefore(this._form, this.element);
    if (!this.options.loadTextURL) this.postProcessEditField();
    if (e) Event.stop(e);
  },
  enterHover: function (e) {
    if (this.options.hoverClassName) this.element.addClassName(this.options.hoverClassName);
    if (this._saving) return;
    this.triggerCallback('onEnterHover');
  },
  getText: function () {
    return this.element.innerHTML.unescapeHTML();
  },
  handleAJAXFailure: function (transport) {
    this.triggerCallback('onFailure', transport);
    if (this._oldInnerHTML) {
      this.element.innerHTML = this._oldInnerHTML;
      this._oldInnerHTML = null;
    }
  },
  handleFormCancellation: function (e) {
    this.wrapUp();
    if (e) Event.stop(e);
  },
  handleFormSubmission: function (e) {
    var form = this._form;
    var value = $F(this._controls.editor);
    this.prepareSubmission();
    var params = this.options.callback(form, value) || '';
    if (Object.isString(params)) params = params.toQueryParams();
    params.editorId = this.element.id;
    // REWRITE: add CSRF token
    var element = null;
    if (element = document.querySelector('meta[name=csrf-token]')) {
      params.authenticity_token = element.content;
    }
    if (this.options.htmlResponse) {
      var options = Object.extend({
        evalScripts: true
      }, this.options.ajaxOptions);
      Object.extend(options, {
        parameters: params,
        onComplete: this._boundWrapperHandler,
        onFailure: this._boundFailureHandler
      });
      new Ajax.Updater({
        success: this.element
      }, this.url, options);
    } else {
      var options = Object.extend({
        method: 'get'
      }, this.options.ajaxOptions);
      Object.extend(options, {
        parameters: params,
        onComplete: this._boundWrapperHandler,
        onFailure: this._boundFailureHandler
      });
      new Ajax.Request(this.url, options);
    }
    if (e) Event.stop(e);
  },
  leaveEditMode: function () {
    this.element.removeClassName(this.options.savingClassName);
    this.removeForm();
    this.leaveHover();
    this.element.style.backgroundColor = this._originalBackground;
    if (this.options.elementHideClass) this.element.removeClassName(this.options.elementHideClass);else this.element.show();
    if (this.options.externalControl) this.options.externalControl.show();
    this._saving = false;
    this._editing = false;
    this._oldInnerHTML = null;
    this.triggerCallback('onLeaveEditMode');
  },
  leaveHover: function (e) {
    if (this.options.hoverClassName) this.element.removeClassName(this.options.hoverClassName);
    if (this._saving) return;
    this.triggerCallback('onLeaveHover');
  },
  loadExternalText: function () {
    this._form.addClassName(this.options.loadingClassName);
    this._controls.editor.disabled = true;
    var options = Object.extend({
      method: 'get'
    }, this.options.ajaxOptions);
    Object.extend(options, {
      parameters: 'editorId=' + encodeURIComponent(this.element.id),
      onComplete: Prototype.emptyFunction,
      onSuccess: function (transport) {
        this._form.removeClassName(this.options.loadingClassName);
        var text = transport.responseText;
        if (this.options.stripLoadedTextTags) text = text.stripTags();
        this._controls.editor.value = text;
        this._controls.editor.disabled = false;
        this.postProcessEditField();
      }.bind(this),
      onFailure: this._boundFailureHandler
    });
    new Ajax.Request(this.options.loadTextURL, options);
  },
  postProcessEditField: function () {
    var fpc = this.options.fieldPostCreation;
    if (fpc) $(this._controls.editor)['focus' == fpc ? 'focus' : 'activate']();
  },
  prepareOptions: function () {
    this.options = Object.clone(Ajax.InPlaceEditor.DefaultOptions);
    Object.extend(this.options, Ajax.InPlaceEditor.DefaultCallbacks);
    [this._extraDefaultOptions].flatten().compact().each(function (defs) {
      Object.extend(this.options, defs);
    }.bind(this));
  },
  prepareSubmission: function () {
    this._saving = true;
    this.removeForm();
    this.leaveHover();
    this.showSaving();
  },
  registerListeners: function () {
    this._listeners = {};
    var listener;
    $H(Ajax.InPlaceEditor.Listeners).each(function (pair) {
      listener = this[pair.value].bind(this);
      this._listeners[pair.key] = listener;
      if (!this.options.externalControlOnly) this.element.observe(pair.key, listener);
      if (this.options.externalControl) this.options.externalControl.observe(pair.key, listener);
    }.bind(this));
  },
  removeForm: function () {
    if (!this._form) return;
    this._form.remove();
    this._form = null;
    this._controls = {};
  },
  showSaving: function () {
    this._oldInnerHTML = this.element.innerHTML;
    this.element.innerHTML = this.options.savingText;
    this.element.addClassName(this.options.savingClassName);
    this.element.style.backgroundColor = this._originalBackground;
    this.element.show();
  },
  triggerCallback: function (cbName, arg) {
    if ('function' == typeof this.options[cbName]) {
      this.options[cbName](this, arg);
    }
  },
  unregisterListeners: function () {
    $H(this._listeners).each(function (pair) {
      if (!this.options.externalControlOnly) this.element.stopObserving(pair.key, pair.value);
      if (this.options.externalControl) this.options.externalControl.stopObserving(pair.key, pair.value);
    }.bind(this));
  },
  wrapUp: function (transport) {
    this.leaveEditMode();
    // Can't use triggerCallback due to backward compatibility: requires
    // binding + direct element
    this._boundComplete(transport, this.element);
  }
});
Object.extend(Ajax.InPlaceEditor.prototype, {
  dispose: Ajax.InPlaceEditor.prototype.destroy
});
Ajax.InPlaceCollectionEditor = Class.create(Ajax.InPlaceEditor, {
  initialize: function ($super, element, url, options) {
    this._extraDefaultOptions = Ajax.InPlaceCollectionEditor.DefaultOptions;
    $super(element, url, options);
  },
  createEditField: function () {
    var list = document.createElement('select');
    list.name = this.options.paramName;
    list.size = 1;
    this._controls.editor = list;
    this._collection = this.options.collection || [];
    if (this.options.loadCollectionURL) this.loadCollection();else this.checkForExternalText();
    this._form.appendChild(this._controls.editor);
  },
  loadCollection: function () {
    this._form.addClassName(this.options.loadingClassName);
    this.showLoadingText(this.options.loadingCollectionText);
    var options = Object.extend({
      method: 'get'
    }, this.options.ajaxOptions);
    Object.extend(options, {
      parameters: 'editorId=' + encodeURIComponent(this.element.id),
      onComplete: Prototype.emptyFunction,
      onSuccess: function (transport) {
        var js = transport.responseText.strip();
        if (!/^\[.*\]$/.test(js))
          // TODO: improve sanity check
          throw 'Server returned an invalid collection representation.';
        this._collection = eval(js);
        this.checkForExternalText();
      }.bind(this),
      onFailure: this.onFailure
    });
    new Ajax.Request(this.options.loadCollectionURL, options);
  },
  showLoadingText: function (text) {
    this._controls.editor.disabled = true;
    var tempOption = this._controls.editor.firstChild;
    if (!tempOption) {
      tempOption = document.createElement('option');
      tempOption.value = '';
      this._controls.editor.appendChild(tempOption);
      tempOption.selected = true;
    }
    tempOption.update((text || '').stripScripts().stripTags());
  },
  checkForExternalText: function () {
    this._text = this.getText();
    if (this.options.loadTextURL) this.loadExternalText();else this.buildOptionList();
  },
  loadExternalText: function () {
    this.showLoadingText(this.options.loadingText);
    var options = Object.extend({
      method: 'get'
    }, this.options.ajaxOptions);
    Object.extend(options, {
      parameters: 'editorId=' + encodeURIComponent(this.element.id),
      onComplete: Prototype.emptyFunction,
      onSuccess: function (transport) {
        this._text = transport.responseText.strip();
        this.buildOptionList();
      }.bind(this),
      onFailure: this.onFailure
    });
    new Ajax.Request(this.options.loadTextURL, options);
  },
  buildOptionList: function () {
    this._form.removeClassName(this.options.loadingClassName);
    this._collection = this._collection.map(function (entry) {
      return 2 === entry.length ? entry : [entry, entry].flatten();
    });
    var marker = 'value' in this.options ? this.options.value : this._text;
    var textFound = this._collection.any(function (entry) {
      return entry[0] == marker;
    }.bind(this));
    this._controls.editor.update('');
    var option;
    this._collection.each(function (entry, index) {
      option = document.createElement('option');
      option.value = entry[0];
      option.selected = textFound ? entry[0] == marker : 0 == index;
      option.appendChild(document.createTextNode(entry[1]));
      this._controls.editor.appendChild(option);
    }.bind(this));
    this._controls.editor.disabled = false;
    Field.scrollFreeActivate(this._controls.editor);
  }
});

//**** DEPRECATION LAYER FOR InPlace[Collection]Editor! ****
//**** This only  exists for a while,  in order to  let ****
//**** users adapt to  the new API.  Read up on the new ****
//**** API and convert your code to it ASAP!            ****

Ajax.InPlaceEditor.prototype.initialize.dealWithDeprecatedOptions = function (options) {
  if (!options) return;
  function fallback(name, expr) {
    if (name in options || expr === undefined) return;
    options[name] = expr;
  }
  ;
  fallback('cancelControl', options.cancelLink ? 'link' : options.cancelButton ? 'button' : options.cancelLink == options.cancelButton == false ? false : undefined);
  fallback('okControl', options.okLink ? 'link' : options.okButton ? 'button' : options.okLink == options.okButton == false ? false : undefined);
  fallback('highlightColor', options.highlightcolor);
  fallback('highlightEndColor', options.highlightendcolor);
};
Object.extend(Ajax.InPlaceEditor, {
  DefaultOptions: {
    ajaxOptions: {},
    autoRows: 3,
    // Use when multi-line w/ rows == 1
    cancelControl: 'link',
    // 'link'|'button'|false
    cancelText: 'cancel',
    clickToEditText: 'Click to edit',
    externalControl: null,
    // id|elt
    externalControlOnly: false,
    fieldPostCreation: 'activate',
    // 'activate'|'focus'|false
    formClassName: 'inplaceeditor-form',
    formId: null,
    // id|elt
    highlightColor: '#ffff99',
    highlightEndColor: '#ffffff',
    hoverClassName: '',
    htmlResponse: true,
    loadingClassName: 'inplaceeditor-loading',
    loadingText: 'Loading...',
    okControl: 'button',
    // 'link'|'button'|false
    okText: 'ok',
    paramName: 'value',
    rows: 1,
    // If 1 and multi-line, uses autoRows
    savingClassName: 'inplaceeditor-saving',
    savingText: 'Saving...',
    size: 0,
    stripLoadedTextTags: false,
    submitOnBlur: false,
    textAfterControls: '',
    textBeforeControls: '',
    textBetweenControls: '',
    elementHideClass: ''
  },
  DefaultCallbacks: {
    callback: function (form) {
      return Form.serialize(form);
    },
    onComplete: function (transport, element) {
      // For backward compatibility, this one is bound to the IPE, and passes
      // the element directly.  It was too often customized, so we don't break it.
      new Effect.Highlight(element, {
        startcolor: this.options.highlightColor,
        keepBackgroundImage: true
      });
    },
    onEnterEditMode: null,
    onEnterHover: function (ipe) {
      ipe.element.style.backgroundColor = ipe.options.highlightColor;
      if (ipe._effect) ipe._effect.cancel();
    },
    onFailure: function (transport, ipe) {
      alert('Error communication with the server: ' + transport.responseText.stripTags());
    },
    onFormCustomization: null,
    // Takes the IPE and its generated form, after editor, before controls.
    onLeaveEditMode: null,
    onLeaveHover: function (ipe) {
      ipe._effect = new Effect.Highlight(ipe.element, {
        startcolor: ipe.options.highlightColor,
        endcolor: ipe.options.highlightEndColor,
        restorecolor: ipe._originalBackground,
        keepBackgroundImage: true
      });
    }
  },
  Listeners: {
    click: 'enterEditMode',
    keydown: 'checkForEscapeOrReturn',
    mouseover: 'enterHover',
    mouseout: 'leaveHover'
  }
});
Ajax.InPlaceCollectionEditor.DefaultOptions = {
  loadingCollectionText: 'Loading options...'
};

// Delayed observer, like Form.Element.Observer,
// but waits for delay after last key input
// Ideal for live-search fields

Form.Element.DelayedObserver = Class.create({
  initialize: function (element, delay, callback) {
    this.delay = delay || 0.5;
    this.element = $(element);
    this.callback = callback;
    this.timer = null;
    this.lastValue = $F(this.element);
    Event.observe(this.element, 'keyup', this.delayedListener.bindAsEventListener(this));
  },
  delayedListener: function (event) {
    if (this.lastValue == $F(this.element)) return;
    if (this.timer) clearTimeout(this.timer);
    this.timer = setTimeout(this.onTimerEvent.bind(this), this.delay * 1000);
    this.lastValue = $F(this.element);
  },
  onTimerEvent: function () {
    this.timer = null;
    this.callback(this.element, $F(this.element));
  }
});
/*
 Leaflet, a JavaScript library for mobile-friendly interactive maps. http://leafletjs.com
 (c) 2010-2013, Vladimir Agafonkin
 (c) 2010-2011, CloudMade
*/
!function (t, e, i) {
  var n = t.L,
    o = {};
  o.version = "0.7.7", "object" == typeof module && "object" == typeof module.exports ? module.exports = o : "function" == typeof define && define.amd && define(o), o.noConflict = function () {
    return t.L = n, this;
  }, t.L = o, o.Util = {
    extend: function (t) {
      var e,
        i,
        n,
        o,
        s = Array.prototype.slice.call(arguments, 1);
      for (i = 0, n = s.length; n > i; i++) {
        o = s[i] || {};
        for (e in o) o.hasOwnProperty(e) && (t[e] = o[e]);
      }
      return t;
    },
    bind: function (t, e) {
      var i = arguments.length > 2 ? Array.prototype.slice.call(arguments, 2) : null;
      return function () {
        return t.apply(e, i || arguments);
      };
    },
    stamp: function () {
      var t = 0,
        e = "_leaflet_id";
      return function (i) {
        return i[e] = i[e] || ++t, i[e];
      };
    }(),
    invokeEach: function (t, e, i) {
      var n, o;
      if ("object" == typeof t) {
        o = Array.prototype.slice.call(arguments, 3);
        for (n in t) e.apply(i, [n, t[n]].concat(o));
        return !0;
      }
      return !1;
    },
    limitExecByInterval: function (t, e, i) {
      var n, o;
      return function s() {
        var a = arguments;
        return n ? void (o = !0) : (n = !0, setTimeout(function () {
          n = !1, o && (s.apply(i, a), o = !1);
        }, e), void t.apply(i, a));
      };
    },
    falseFn: function () {
      return !1;
    },
    formatNum: function (t, e) {
      var i = Math.pow(10, e || 5);
      return Math.round(t * i) / i;
    },
    trim: function (t) {
      return t.trim ? t.trim() : t.replace(/^\s+|\s+$/g, "");
    },
    splitWords: function (t) {
      return o.Util.trim(t).split(/\s+/);
    },
    setOptions: function (t, e) {
      return t.options = o.extend({}, t.options, e), t.options;
    },
    getParamString: function (t, e, i) {
      var n = [];
      for (var o in t) n.push(encodeURIComponent(i ? o.toUpperCase() : o) + "=" + encodeURIComponent(t[o]));
      return (e && -1 !== e.indexOf("?") ? "&" : "?") + n.join("&");
    },
    template: function (t, e) {
      return t.replace(/\{ *([\w_]+) *\}/g, function (t, n) {
        var o = e[n];
        if (o === i) throw new Error("No value provided for variable " + t);
        return "function" == typeof o && (o = o(e)), o;
      });
    },
    isArray: Array.isArray || function (t) {
      return "[object Array]" === Object.prototype.toString.call(t);
    },
    emptyImageUrl: "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs="
  }, function () {
    function e(e) {
      var i,
        n,
        o = ["webkit", "moz", "o", "ms"];
      for (i = 0; i < o.length && !n; i++) n = t[o[i] + e];
      return n;
    }
    function i(e) {
      var i = +new Date(),
        o = Math.max(0, 16 - (i - n));
      return n = i + o, t.setTimeout(e, o);
    }
    var n = 0,
      s = t.requestAnimationFrame || e("RequestAnimationFrame") || i,
      a = t.cancelAnimationFrame || e("CancelAnimationFrame") || e("CancelRequestAnimationFrame") || function (e) {
        t.clearTimeout(e);
      };
    o.Util.requestAnimFrame = function (e, n, a, r) {
      return e = o.bind(e, n), a && s === i ? void e() : s.call(t, e, r);
    }, o.Util.cancelAnimFrame = function (e) {
      e && a.call(t, e);
    };
  }(), o.extend = o.Util.extend, o.bind = o.Util.bind, o.stamp = o.Util.stamp, o.setOptions = o.Util.setOptions, o.Class = function () {}, o.Class.extend = function (t) {
    var e = function () {
        this.initialize && this.initialize.apply(this, arguments), this._initHooks && this.callInitHooks();
      },
      i = function () {};
    i.prototype = this.prototype;
    var n = new i();
    n.constructor = e, e.prototype = n;
    for (var s in this) this.hasOwnProperty(s) && "prototype" !== s && (e[s] = this[s]);
    t.statics && (o.extend(e, t.statics), delete t.statics), t.includes && (o.Util.extend.apply(null, [n].concat(t.includes)), delete t.includes), t.options && n.options && (t.options = o.extend({}, n.options, t.options)), o.extend(n, t), n._initHooks = [];
    var a = this;
    return e.__super__ = a.prototype, n.callInitHooks = function () {
      if (!this._initHooksCalled) {
        a.prototype.callInitHooks && a.prototype.callInitHooks.call(this), this._initHooksCalled = !0;
        for (var t = 0, e = n._initHooks.length; e > t; t++) n._initHooks[t].call(this);
      }
    }, e;
  }, o.Class.include = function (t) {
    o.extend(this.prototype, t);
  }, o.Class.mergeOptions = function (t) {
    o.extend(this.prototype.options, t);
  }, o.Class.addInitHook = function (t) {
    var e = Array.prototype.slice.call(arguments, 1),
      i = "function" == typeof t ? t : function () {
        this[t].apply(this, e);
      };
    this.prototype._initHooks = this.prototype._initHooks || [], this.prototype._initHooks.push(i);
  };
  var s = "_leaflet_events";
  o.Mixin = {}, o.Mixin.Events = {
    addEventListener: function (t, e, i) {
      if (o.Util.invokeEach(t, this.addEventListener, this, e, i)) return this;
      var n,
        a,
        r,
        h,
        l,
        u,
        c,
        d = this[s] = this[s] || {},
        p = i && i !== this && o.stamp(i);
      for (t = o.Util.splitWords(t), n = 0, a = t.length; a > n; n++) r = {
        action: e,
        context: i || this
      }, h = t[n], p ? (l = h + "_idx", u = l + "_len", c = d[l] = d[l] || {}, c[p] || (c[p] = [], d[u] = (d[u] || 0) + 1), c[p].push(r)) : (d[h] = d[h] || [], d[h].push(r));
      return this;
    },
    hasEventListeners: function (t) {
      var e = this[s];
      return !!e && (t in e && e[t].length > 0 || t + "_idx" in e && e[t + "_idx_len"] > 0);
    },
    removeEventListener: function (t, e, i) {
      if (!this[s]) return this;
      if (!t) return this.clearAllEventListeners();
      if (o.Util.invokeEach(t, this.removeEventListener, this, e, i)) return this;
      var n,
        a,
        r,
        h,
        l,
        u,
        c,
        d,
        p,
        _ = this[s],
        m = i && i !== this && o.stamp(i);
      for (t = o.Util.splitWords(t), n = 0, a = t.length; a > n; n++) if (r = t[n], u = r + "_idx", c = u + "_len", d = _[u], e) {
        if (h = m && d ? d[m] : _[r]) {
          for (l = h.length - 1; l >= 0; l--) h[l].action !== e || i && h[l].context !== i || (p = h.splice(l, 1), p[0].action = o.Util.falseFn);
          i && d && 0 === h.length && (delete d[m], _[c]--);
        }
      } else delete _[r], delete _[u], delete _[c];
      return this;
    },
    clearAllEventListeners: function () {
      return delete this[s], this;
    },
    fireEvent: function (t, e) {
      if (!this.hasEventListeners(t)) return this;
      var i,
        n,
        a,
        r,
        h,
        l = o.Util.extend({}, e, {
          type: t,
          target: this
        }),
        u = this[s];
      if (u[t]) for (i = u[t].slice(), n = 0, a = i.length; a > n; n++) i[n].action.call(i[n].context, l);
      r = u[t + "_idx"];
      for (h in r) if (i = r[h].slice()) for (n = 0, a = i.length; a > n; n++) i[n].action.call(i[n].context, l);
      return this;
    },
    addOneTimeEventListener: function (t, e, i) {
      if (o.Util.invokeEach(t, this.addOneTimeEventListener, this, e, i)) return this;
      var n = o.bind(function () {
        this.removeEventListener(t, e, i).removeEventListener(t, n, i);
      }, this);
      return this.addEventListener(t, e, i).addEventListener(t, n, i);
    }
  }, o.Mixin.Events.on = o.Mixin.Events.addEventListener, o.Mixin.Events.off = o.Mixin.Events.removeEventListener, o.Mixin.Events.once = o.Mixin.Events.addOneTimeEventListener, o.Mixin.Events.fire = o.Mixin.Events.fireEvent, function () {
    var n = ("ActiveXObject" in t),
      s = n && !e.addEventListener,
      a = navigator.userAgent.toLowerCase(),
      r = -1 !== a.indexOf("webkit"),
      h = -1 !== a.indexOf("chrome"),
      l = -1 !== a.indexOf("phantom"),
      u = -1 !== a.indexOf("android"),
      c = -1 !== a.search("android [23]"),
      d = -1 !== a.indexOf("gecko"),
      p = typeof orientation != i + "",
      _ = !t.PointerEvent && t.MSPointerEvent,
      m = t.PointerEvent && t.navigator.pointerEnabled || _,
      f = "devicePixelRatio" in t && t.devicePixelRatio > 1 || "matchMedia" in t && t.matchMedia("(min-resolution:144dpi)") && t.matchMedia("(min-resolution:144dpi)").matches,
      g = e.documentElement,
      v = n && "transition" in g.style,
      y = "WebKitCSSMatrix" in t && "m11" in new t.WebKitCSSMatrix() && !c,
      P = ("MozPerspective" in g.style),
      L = ("OTransition" in g.style),
      x = !t.L_DISABLE_3D && (v || y || P || L) && !l,
      w = !t.L_NO_TOUCH && !l && (m || "ontouchstart" in t || t.DocumentTouch && e instanceof t.DocumentTouch);
    o.Browser = {
      ie: n,
      ielt9: s,
      webkit: r,
      gecko: d && !r && !t.opera && !n,
      android: u,
      android23: c,
      chrome: h,
      ie3d: v,
      webkit3d: y,
      gecko3d: P,
      opera3d: L,
      any3d: x,
      mobile: p,
      mobileWebkit: p && r,
      mobileWebkit3d: p && y,
      mobileOpera: p && t.opera,
      touch: w,
      msPointer: _,
      pointer: m,
      retina: f
    };
  }(), o.Point = function (t, e, i) {
    this.x = i ? Math.round(t) : t, this.y = i ? Math.round(e) : e;
  }, o.Point.prototype = {
    clone: function () {
      return new o.Point(this.x, this.y);
    },
    add: function (t) {
      return this.clone()._add(o.point(t));
    },
    _add: function (t) {
      return this.x += t.x, this.y += t.y, this;
    },
    subtract: function (t) {
      return this.clone()._subtract(o.point(t));
    },
    _subtract: function (t) {
      return this.x -= t.x, this.y -= t.y, this;
    },
    divideBy: function (t) {
      return this.clone()._divideBy(t);
    },
    _divideBy: function (t) {
      return this.x /= t, this.y /= t, this;
    },
    multiplyBy: function (t) {
      return this.clone()._multiplyBy(t);
    },
    _multiplyBy: function (t) {
      return this.x *= t, this.y *= t, this;
    },
    round: function () {
      return this.clone()._round();
    },
    _round: function () {
      return this.x = Math.round(this.x), this.y = Math.round(this.y), this;
    },
    floor: function () {
      return this.clone()._floor();
    },
    _floor: function () {
      return this.x = Math.floor(this.x), this.y = Math.floor(this.y), this;
    },
    distanceTo: function (t) {
      t = o.point(t);
      var e = t.x - this.x,
        i = t.y - this.y;
      return Math.sqrt(e * e + i * i);
    },
    equals: function (t) {
      return t = o.point(t), t.x === this.x && t.y === this.y;
    },
    contains: function (t) {
      return t = o.point(t), Math.abs(t.x) <= Math.abs(this.x) && Math.abs(t.y) <= Math.abs(this.y);
    },
    toString: function () {
      return "Point(" + o.Util.formatNum(this.x) + ", " + o.Util.formatNum(this.y) + ")";
    }
  }, o.point = function (t, e, n) {
    return t instanceof o.Point ? t : o.Util.isArray(t) ? new o.Point(t[0], t[1]) : t === i || null === t ? t : new o.Point(t, e, n);
  }, o.Bounds = function (t, e) {
    if (t) for (var i = e ? [t, e] : t, n = 0, o = i.length; o > n; n++) this.extend(i[n]);
  }, o.Bounds.prototype = {
    extend: function (t) {
      return t = o.point(t), this.min || this.max ? (this.min.x = Math.min(t.x, this.min.x), this.max.x = Math.max(t.x, this.max.x), this.min.y = Math.min(t.y, this.min.y), this.max.y = Math.max(t.y, this.max.y)) : (this.min = t.clone(), this.max = t.clone()), this;
    },
    getCenter: function (t) {
      return new o.Point((this.min.x + this.max.x) / 2, (this.min.y + this.max.y) / 2, t);
    },
    getBottomLeft: function () {
      return new o.Point(this.min.x, this.max.y);
    },
    getTopRight: function () {
      return new o.Point(this.max.x, this.min.y);
    },
    getSize: function () {
      return this.max.subtract(this.min);
    },
    contains: function (t) {
      var e, i;
      return t = "number" == typeof t[0] || t instanceof o.Point ? o.point(t) : o.bounds(t), t instanceof o.Bounds ? (e = t.min, i = t.max) : e = i = t, e.x >= this.min.x && i.x <= this.max.x && e.y >= this.min.y && i.y <= this.max.y;
    },
    intersects: function (t) {
      t = o.bounds(t);
      var e = this.min,
        i = this.max,
        n = t.min,
        s = t.max,
        a = s.x >= e.x && n.x <= i.x,
        r = s.y >= e.y && n.y <= i.y;
      return a && r;
    },
    isValid: function () {
      return !(!this.min || !this.max);
    }
  }, o.bounds = function (t, e) {
    return !t || t instanceof o.Bounds ? t : new o.Bounds(t, e);
  }, o.Transformation = function (t, e, i, n) {
    this._a = t, this._b = e, this._c = i, this._d = n;
  }, o.Transformation.prototype = {
    transform: function (t, e) {
      return this._transform(t.clone(), e);
    },
    _transform: function (t, e) {
      return e = e || 1, t.x = e * (this._a * t.x + this._b), t.y = e * (this._c * t.y + this._d), t;
    },
    untransform: function (t, e) {
      return e = e || 1, new o.Point((t.x / e - this._b) / this._a, (t.y / e - this._d) / this._c);
    }
  }, o.DomUtil = {
    get: function (t) {
      return "string" == typeof t ? e.getElementById(t) : t;
    },
    getStyle: function (t, i) {
      var n = t.style[i];
      if (!n && t.currentStyle && (n = t.currentStyle[i]), (!n || "auto" === n) && e.defaultView) {
        var o = e.defaultView.getComputedStyle(t, null);
        n = o ? o[i] : null;
      }
      return "auto" === n ? null : n;
    },
    getViewportOffset: function (t) {
      var i,
        n = 0,
        s = 0,
        a = t,
        r = e.body,
        h = e.documentElement;
      do {
        if (n += a.offsetTop || 0, s += a.offsetLeft || 0, n += parseInt(o.DomUtil.getStyle(a, "borderTopWidth"), 10) || 0, s += parseInt(o.DomUtil.getStyle(a, "borderLeftWidth"), 10) || 0, i = o.DomUtil.getStyle(a, "position"), a.offsetParent === r && "absolute" === i) break;
        if ("fixed" === i) {
          n += r.scrollTop || h.scrollTop || 0, s += r.scrollLeft || h.scrollLeft || 0;
          break;
        }
        if ("relative" === i && !a.offsetLeft) {
          var l = o.DomUtil.getStyle(a, "width"),
            u = o.DomUtil.getStyle(a, "max-width"),
            c = a.getBoundingClientRect();
          ("none" !== l || "none" !== u) && (s += c.left + a.clientLeft), n += c.top + (r.scrollTop || h.scrollTop || 0);
          break;
        }
        a = a.offsetParent;
      } while (a);
      a = t;
      do {
        if (a === r) break;
        n -= a.scrollTop || 0, s -= a.scrollLeft || 0, a = a.parentNode;
      } while (a);
      return new o.Point(s, n);
    },
    documentIsLtr: function () {
      return o.DomUtil._docIsLtrCached || (o.DomUtil._docIsLtrCached = !0, o.DomUtil._docIsLtr = "ltr" === o.DomUtil.getStyle(e.body, "direction")), o.DomUtil._docIsLtr;
    },
    create: function (t, i, n) {
      var o = e.createElement(t);
      return o.className = i, n && n.appendChild(o), o;
    },
    hasClass: function (t, e) {
      if (t.classList !== i) return t.classList.contains(e);
      var n = o.DomUtil._getClass(t);
      return n.length > 0 && new RegExp("(^|\\s)" + e + "(\\s|$)").test(n);
    },
    addClass: function (t, e) {
      if (t.classList !== i) for (var n = o.Util.splitWords(e), s = 0, a = n.length; a > s; s++) t.classList.add(n[s]);else if (!o.DomUtil.hasClass(t, e)) {
        var r = o.DomUtil._getClass(t);
        o.DomUtil._setClass(t, (r ? r + " " : "") + e);
      }
    },
    removeClass: function (t, e) {
      t.classList !== i ? t.classList.remove(e) : o.DomUtil._setClass(t, o.Util.trim((" " + o.DomUtil._getClass(t) + " ").replace(" " + e + " ", " ")));
    },
    _setClass: function (t, e) {
      t.className.baseVal === i ? t.className = e : t.className.baseVal = e;
    },
    _getClass: function (t) {
      return t.className.baseVal === i ? t.className : t.className.baseVal;
    },
    setOpacity: function (t, e) {
      if ("opacity" in t.style) t.style.opacity = e;else if ("filter" in t.style) {
        var i = !1,
          n = "DXImageTransform.Microsoft.Alpha";
        try {
          i = t.filters.item(n);
        } catch (o) {
          if (1 === e) return;
        }
        e = Math.round(100 * e), i ? (i.Enabled = 100 !== e, i.Opacity = e) : t.style.filter += " progid:" + n + "(opacity=" + e + ")";
      }
    },
    testProp: function (t) {
      for (var i = e.documentElement.style, n = 0; n < t.length; n++) if (t[n] in i) return t[n];
      return !1;
    },
    getTranslateString: function (t) {
      var e = o.Browser.webkit3d,
        i = "translate" + (e ? "3d" : "") + "(",
        n = (e ? ",0" : "") + ")";
      return i + t.x + "px," + t.y + "px" + n;
    },
    getScaleString: function (t, e) {
      var i = o.DomUtil.getTranslateString(e.add(e.multiplyBy(-1 * t))),
        n = " scale(" + t + ") ";
      return i + n;
    },
    setPosition: function (t, e, i) {
      t._leaflet_pos = e, !i && o.Browser.any3d ? t.style[o.DomUtil.TRANSFORM] = o.DomUtil.getTranslateString(e) : (t.style.left = e.x + "px", t.style.top = e.y + "px");
    },
    getPosition: function (t) {
      return t._leaflet_pos;
    }
  }, o.DomUtil.TRANSFORM = o.DomUtil.testProp(["transform", "WebkitTransform", "OTransform", "MozTransform", "msTransform"]), o.DomUtil.TRANSITION = o.DomUtil.testProp(["webkitTransition", "transition", "OTransition", "MozTransition", "msTransition"]), o.DomUtil.TRANSITION_END = "webkitTransition" === o.DomUtil.TRANSITION || "OTransition" === o.DomUtil.TRANSITION ? o.DomUtil.TRANSITION + "End" : "transitionend", function () {
    if ("onselectstart" in e) o.extend(o.DomUtil, {
      disableTextSelection: function () {
        o.DomEvent.on(t, "selectstart", o.DomEvent.preventDefault);
      },
      enableTextSelection: function () {
        o.DomEvent.off(t, "selectstart", o.DomEvent.preventDefault);
      }
    });else {
      var i = o.DomUtil.testProp(["userSelect", "WebkitUserSelect", "OUserSelect", "MozUserSelect", "msUserSelect"]);
      o.extend(o.DomUtil, {
        disableTextSelection: function () {
          if (i) {
            var t = e.documentElement.style;
            this._userSelect = t[i], t[i] = "none";
          }
        },
        enableTextSelection: function () {
          i && (e.documentElement.style[i] = this._userSelect, delete this._userSelect);
        }
      });
    }
    o.extend(o.DomUtil, {
      disableImageDrag: function () {
        o.DomEvent.on(t, "dragstart", o.DomEvent.preventDefault);
      },
      enableImageDrag: function () {
        o.DomEvent.off(t, "dragstart", o.DomEvent.preventDefault);
      }
    });
  }(), o.LatLng = function (t, e, n) {
    if (t = parseFloat(t), e = parseFloat(e), isNaN(t) || isNaN(e)) throw new Error("Invalid LatLng object: (" + t + ", " + e + ")");
    this.lat = t, this.lng = e, n !== i && (this.alt = parseFloat(n));
  }, o.extend(o.LatLng, {
    DEG_TO_RAD: Math.PI / 180,
    RAD_TO_DEG: 180 / Math.PI,
    MAX_MARGIN: 1e-9
  }), o.LatLng.prototype = {
    equals: function (t) {
      if (!t) return !1;
      t = o.latLng(t);
      var e = Math.max(Math.abs(this.lat - t.lat), Math.abs(this.lng - t.lng));
      return e <= o.LatLng.MAX_MARGIN;
    },
    toString: function (t) {
      return "LatLng(" + o.Util.formatNum(this.lat, t) + ", " + o.Util.formatNum(this.lng, t) + ")";
    },
    distanceTo: function (t) {
      t = o.latLng(t);
      var e = 6378137,
        i = o.LatLng.DEG_TO_RAD,
        n = (t.lat - this.lat) * i,
        s = (t.lng - this.lng) * i,
        a = this.lat * i,
        r = t.lat * i,
        h = Math.sin(n / 2),
        l = Math.sin(s / 2),
        u = h * h + l * l * Math.cos(a) * Math.cos(r);
      return 2 * e * Math.atan2(Math.sqrt(u), Math.sqrt(1 - u));
    },
    wrap: function (t, e) {
      var i = this.lng;
      return t = t || -180, e = e || 180, i = (i + e) % (e - t) + (t > i || i === e ? e : t), new o.LatLng(this.lat, i);
    }
  }, o.latLng = function (t, e) {
    return t instanceof o.LatLng ? t : o.Util.isArray(t) ? "number" == typeof t[0] || "string" == typeof t[0] ? new o.LatLng(t[0], t[1], t[2]) : null : t === i || null === t ? t : "object" == typeof t && "lat" in t ? new o.LatLng(t.lat, "lng" in t ? t.lng : t.lon) : e === i ? null : new o.LatLng(t, e);
  }, o.LatLngBounds = function (t, e) {
    if (t) for (var i = e ? [t, e] : t, n = 0, o = i.length; o > n; n++) this.extend(i[n]);
  }, o.LatLngBounds.prototype = {
    extend: function (t) {
      if (!t) return this;
      var e = o.latLng(t);
      return t = null !== e ? e : o.latLngBounds(t), t instanceof o.LatLng ? this._southWest || this._northEast ? (this._southWest.lat = Math.min(t.lat, this._southWest.lat), this._southWest.lng = Math.min(t.lng, this._southWest.lng), this._northEast.lat = Math.max(t.lat, this._northEast.lat), this._northEast.lng = Math.max(t.lng, this._northEast.lng)) : (this._southWest = new o.LatLng(t.lat, t.lng), this._northEast = new o.LatLng(t.lat, t.lng)) : t instanceof o.LatLngBounds && (this.extend(t._southWest), this.extend(t._northEast)), this;
    },
    pad: function (t) {
      var e = this._southWest,
        i = this._northEast,
        n = Math.abs(e.lat - i.lat) * t,
        s = Math.abs(e.lng - i.lng) * t;
      return new o.LatLngBounds(new o.LatLng(e.lat - n, e.lng - s), new o.LatLng(i.lat + n, i.lng + s));
    },
    getCenter: function () {
      return new o.LatLng((this._southWest.lat + this._northEast.lat) / 2, (this._southWest.lng + this._northEast.lng) / 2);
    },
    getSouthWest: function () {
      return this._southWest;
    },
    getNorthEast: function () {
      return this._northEast;
    },
    getNorthWest: function () {
      return new o.LatLng(this.getNorth(), this.getWest());
    },
    getSouthEast: function () {
      return new o.LatLng(this.getSouth(), this.getEast());
    },
    getWest: function () {
      return this._southWest.lng;
    },
    getSouth: function () {
      return this._southWest.lat;
    },
    getEast: function () {
      return this._northEast.lng;
    },
    getNorth: function () {
      return this._northEast.lat;
    },
    contains: function (t) {
      t = "number" == typeof t[0] || t instanceof o.LatLng ? o.latLng(t) : o.latLngBounds(t);
      var e,
        i,
        n = this._southWest,
        s = this._northEast;
      return t instanceof o.LatLngBounds ? (e = t.getSouthWest(), i = t.getNorthEast()) : e = i = t, e.lat >= n.lat && i.lat <= s.lat && e.lng >= n.lng && i.lng <= s.lng;
    },
    intersects: function (t) {
      t = o.latLngBounds(t);
      var e = this._southWest,
        i = this._northEast,
        n = t.getSouthWest(),
        s = t.getNorthEast(),
        a = s.lat >= e.lat && n.lat <= i.lat,
        r = s.lng >= e.lng && n.lng <= i.lng;
      return a && r;
    },
    toBBoxString: function () {
      return [this.getWest(), this.getSouth(), this.getEast(), this.getNorth()].join(",");
    },
    equals: function (t) {
      return t ? (t = o.latLngBounds(t), this._southWest.equals(t.getSouthWest()) && this._northEast.equals(t.getNorthEast())) : !1;
    },
    isValid: function () {
      return !(!this._southWest || !this._northEast);
    }
  }, o.latLngBounds = function (t, e) {
    return !t || t instanceof o.LatLngBounds ? t : new o.LatLngBounds(t, e);
  }, o.Projection = {}, o.Projection.SphericalMercator = {
    MAX_LATITUDE: 85.0511287798,
    project: function (t) {
      var e = o.LatLng.DEG_TO_RAD,
        i = this.MAX_LATITUDE,
        n = Math.max(Math.min(i, t.lat), -i),
        s = t.lng * e,
        a = n * e;
      return a = Math.log(Math.tan(Math.PI / 4 + a / 2)), new o.Point(s, a);
    },
    unproject: function (t) {
      var e = o.LatLng.RAD_TO_DEG,
        i = t.x * e,
        n = (2 * Math.atan(Math.exp(t.y)) - Math.PI / 2) * e;
      return new o.LatLng(n, i);
    }
  }, o.Projection.LonLat = {
    project: function (t) {
      return new o.Point(t.lng, t.lat);
    },
    unproject: function (t) {
      return new o.LatLng(t.y, t.x);
    }
  }, o.CRS = {
    latLngToPoint: function (t, e) {
      var i = this.projection.project(t),
        n = this.scale(e);
      return this.transformation._transform(i, n);
    },
    pointToLatLng: function (t, e) {
      var i = this.scale(e),
        n = this.transformation.untransform(t, i);
      return this.projection.unproject(n);
    },
    project: function (t) {
      return this.projection.project(t);
    },
    scale: function (t) {
      return 256 * Math.pow(2, t);
    },
    getSize: function (t) {
      var e = this.scale(t);
      return o.point(e, e);
    }
  }, o.CRS.Simple = o.extend({}, o.CRS, {
    projection: o.Projection.LonLat,
    transformation: new o.Transformation(1, 0, -1, 0),
    scale: function (t) {
      return Math.pow(2, t);
    }
  }), o.CRS.EPSG3857 = o.extend({}, o.CRS, {
    code: "EPSG:3857",
    projection: o.Projection.SphericalMercator,
    transformation: new o.Transformation(.5 / Math.PI, .5, -.5 / Math.PI, .5),
    project: function (t) {
      var e = this.projection.project(t),
        i = 6378137;
      return e.multiplyBy(i);
    }
  }), o.CRS.EPSG900913 = o.extend({}, o.CRS.EPSG3857, {
    code: "EPSG:900913"
  }), o.CRS.EPSG4326 = o.extend({}, o.CRS, {
    code: "EPSG:4326",
    projection: o.Projection.LonLat,
    transformation: new o.Transformation(1 / 360, .5, -1 / 360, .5)
  }), o.Map = o.Class.extend({
    includes: o.Mixin.Events,
    options: {
      crs: o.CRS.EPSG3857,
      fadeAnimation: o.DomUtil.TRANSITION && !o.Browser.android23,
      trackResize: !0,
      markerZoomAnimation: o.DomUtil.TRANSITION && o.Browser.any3d
    },
    initialize: function (t, e) {
      e = o.setOptions(this, e), this._initContainer(t), this._initLayout(), this._onResize = o.bind(this._onResize, this), this._initEvents(), e.maxBounds && this.setMaxBounds(e.maxBounds), e.center && e.zoom !== i && this.setView(o.latLng(e.center), e.zoom, {
        reset: !0
      }), this._handlers = [], this._layers = {}, this._zoomBoundLayers = {}, this._tileLayersNum = 0, this.callInitHooks(), this._addLayers(e.layers);
    },
    setView: function (t, e) {
      return e = e === i ? this.getZoom() : e, this._resetView(o.latLng(t), this._limitZoom(e)), this;
    },
    setZoom: function (t, e) {
      return this._loaded ? this.setView(this.getCenter(), t, {
        zoom: e
      }) : (this._zoom = this._limitZoom(t), this);
    },
    zoomIn: function (t, e) {
      return this.setZoom(this._zoom + (t || 1), e);
    },
    zoomOut: function (t, e) {
      return this.setZoom(this._zoom - (t || 1), e);
    },
    setZoomAround: function (t, e, i) {
      var n = this.getZoomScale(e),
        s = this.getSize().divideBy(2),
        a = t instanceof o.Point ? t : this.latLngToContainerPoint(t),
        r = a.subtract(s).multiplyBy(1 - 1 / n),
        h = this.containerPointToLatLng(s.add(r));
      return this.setView(h, e, {
        zoom: i
      });
    },
    fitBounds: function (t, e) {
      e = e || {}, t = t.getBounds ? t.getBounds() : o.latLngBounds(t);
      var i = o.point(e.paddingTopLeft || e.padding || [0, 0]),
        n = o.point(e.paddingBottomRight || e.padding || [0, 0]),
        s = this.getBoundsZoom(t, !1, i.add(n));
      s = e.maxZoom ? Math.min(e.maxZoom, s) : s;
      var a = n.subtract(i).divideBy(2),
        r = this.project(t.getSouthWest(), s),
        h = this.project(t.getNorthEast(), s),
        l = this.unproject(r.add(h).divideBy(2).add(a), s);
      return this.setView(l, s, e);
    },
    fitWorld: function (t) {
      return this.fitBounds([[-90, -180], [90, 180]], t);
    },
    panTo: function (t, e) {
      return this.setView(t, this._zoom, {
        pan: e
      });
    },
    panBy: function (t) {
      return this.fire("movestart"), this._rawPanBy(o.point(t)), this.fire("move"), this.fire("moveend");
    },
    setMaxBounds: function (t) {
      return t = o.latLngBounds(t), this.options.maxBounds = t, t ? (this._loaded && this._panInsideMaxBounds(), this.on("moveend", this._panInsideMaxBounds, this)) : this.off("moveend", this._panInsideMaxBounds, this);
    },
    panInsideBounds: function (t, e) {
      var i = this.getCenter(),
        n = this._limitCenter(i, this._zoom, t);
      return i.equals(n) ? this : this.panTo(n, e);
    },
    addLayer: function (t) {
      var e = o.stamp(t);
      return this._layers[e] ? this : (this._layers[e] = t, !t.options || isNaN(t.options.maxZoom) && isNaN(t.options.minZoom) || (this._zoomBoundLayers[e] = t, this._updateZoomLevels()), this.options.zoomAnimation && o.TileLayer && t instanceof o.TileLayer && (this._tileLayersNum++, this._tileLayersToLoad++, t.on("load", this._onTileLayerLoad, this)), this._loaded && this._layerAdd(t), this);
    },
    removeLayer: function (t) {
      var e = o.stamp(t);
      return this._layers[e] ? (this._loaded && t.onRemove(this), delete this._layers[e], this._loaded && this.fire("layerremove", {
        layer: t
      }), this._zoomBoundLayers[e] && (delete this._zoomBoundLayers[e], this._updateZoomLevels()), this.options.zoomAnimation && o.TileLayer && t instanceof o.TileLayer && (this._tileLayersNum--, this._tileLayersToLoad--, t.off("load", this._onTileLayerLoad, this)), this) : this;
    },
    hasLayer: function (t) {
      return t ? o.stamp(t) in this._layers : !1;
    },
    eachLayer: function (t, e) {
      for (var i in this._layers) t.call(e, this._layers[i]);
      return this;
    },
    invalidateSize: function (t) {
      if (!this._loaded) return this;
      t = o.extend({
        animate: !1,
        pan: !0
      }, t === !0 ? {
        animate: !0
      } : t);
      var e = this.getSize();
      this._sizeChanged = !0, this._initialCenter = null;
      var i = this.getSize(),
        n = e.divideBy(2).round(),
        s = i.divideBy(2).round(),
        a = n.subtract(s);
      return a.x || a.y ? (t.animate && t.pan ? this.panBy(a) : (t.pan && this._rawPanBy(a), this.fire("move"), t.debounceMoveend ? (clearTimeout(this._sizeTimer), this._sizeTimer = setTimeout(o.bind(this.fire, this, "moveend"), 200)) : this.fire("moveend")), this.fire("resize", {
        oldSize: e,
        newSize: i
      })) : this;
    },
    addHandler: function (t, e) {
      if (!e) return this;
      var i = this[t] = new e(this);
      return this._handlers.push(i), this.options[t] && i.enable(), this;
    },
    remove: function () {
      this._loaded && this.fire("unload"), this._initEvents("off");
      try {
        delete this._container._leaflet;
      } catch (t) {
        this._container._leaflet = i;
      }
      return this._clearPanes(), this._clearControlPos && this._clearControlPos(), this._clearHandlers(), this;
    },
    getCenter: function () {
      return this._checkIfLoaded(), this._initialCenter && !this._moved() ? this._initialCenter : this.layerPointToLatLng(this._getCenterLayerPoint());
    },
    getZoom: function () {
      return this._zoom;
    },
    getBounds: function () {
      var t = this.getPixelBounds(),
        e = this.unproject(t.getBottomLeft()),
        i = this.unproject(t.getTopRight());
      return new o.LatLngBounds(e, i);
    },
    getMinZoom: function () {
      return this.options.minZoom === i ? this._layersMinZoom === i ? 0 : this._layersMinZoom : this.options.minZoom;
    },
    getMaxZoom: function () {
      return this.options.maxZoom === i ? this._layersMaxZoom === i ? 1 / 0 : this._layersMaxZoom : this.options.maxZoom;
    },
    getBoundsZoom: function (t, e, i) {
      t = o.latLngBounds(t);
      var n,
        s = this.getMinZoom() - (e ? 1 : 0),
        a = this.getMaxZoom(),
        r = this.getSize(),
        h = t.getNorthWest(),
        l = t.getSouthEast(),
        u = !0;
      i = o.point(i || [0, 0]);
      do s++, n = this.project(l, s).subtract(this.project(h, s)).add(i), u = e ? n.x < r.x || n.y < r.y : r.contains(n); while (u && a >= s);
      return u && e ? null : e ? s : s - 1;
    },
    getSize: function () {
      return (!this._size || this._sizeChanged) && (this._size = new o.Point(this._container.clientWidth, this._container.clientHeight), this._sizeChanged = !1), this._size.clone();
    },
    getPixelBounds: function () {
      var t = this._getTopLeftPoint();
      return new o.Bounds(t, t.add(this.getSize()));
    },
    getPixelOrigin: function () {
      return this._checkIfLoaded(), this._initialTopLeftPoint;
    },
    getPanes: function () {
      return this._panes;
    },
    getContainer: function () {
      return this._container;
    },
    getZoomScale: function (t) {
      var e = this.options.crs;
      return e.scale(t) / e.scale(this._zoom);
    },
    getScaleZoom: function (t) {
      return this._zoom + Math.log(t) / Math.LN2;
    },
    project: function (t, e) {
      return e = e === i ? this._zoom : e, this.options.crs.latLngToPoint(o.latLng(t), e);
    },
    unproject: function (t, e) {
      return e = e === i ? this._zoom : e, this.options.crs.pointToLatLng(o.point(t), e);
    },
    layerPointToLatLng: function (t) {
      var e = o.point(t).add(this.getPixelOrigin());
      return this.unproject(e);
    },
    latLngToLayerPoint: function (t) {
      var e = this.project(o.latLng(t))._round();
      return e._subtract(this.getPixelOrigin());
    },
    containerPointToLayerPoint: function (t) {
      return o.point(t).subtract(this._getMapPanePos());
    },
    layerPointToContainerPoint: function (t) {
      return o.point(t).add(this._getMapPanePos());
    },
    containerPointToLatLng: function (t) {
      var e = this.containerPointToLayerPoint(o.point(t));
      return this.layerPointToLatLng(e);
    },
    latLngToContainerPoint: function (t) {
      return this.layerPointToContainerPoint(this.latLngToLayerPoint(o.latLng(t)));
    },
    mouseEventToContainerPoint: function (t) {
      return o.DomEvent.getMousePosition(t, this._container);
    },
    mouseEventToLayerPoint: function (t) {
      return this.containerPointToLayerPoint(this.mouseEventToContainerPoint(t));
    },
    mouseEventToLatLng: function (t) {
      return this.layerPointToLatLng(this.mouseEventToLayerPoint(t));
    },
    _initContainer: function (t) {
      var e = this._container = o.DomUtil.get(t);
      if (!e) throw new Error("Map container not found.");
      if (e._leaflet) throw new Error("Map container is already initialized.");
      e._leaflet = !0;
    },
    _initLayout: function () {
      var t = this._container;
      o.DomUtil.addClass(t, "leaflet-container" + (o.Browser.touch ? " leaflet-touch" : "") + (o.Browser.retina ? " leaflet-retina" : "") + (o.Browser.ielt9 ? " leaflet-oldie" : "") + (this.options.fadeAnimation ? " leaflet-fade-anim" : ""));
      var e = o.DomUtil.getStyle(t, "position");
      "absolute" !== e && "relative" !== e && "fixed" !== e && (t.style.position = "relative"), this._initPanes(), this._initControlPos && this._initControlPos();
    },
    _initPanes: function () {
      var t = this._panes = {};
      this._mapPane = t.mapPane = this._createPane("leaflet-map-pane", this._container), this._tilePane = t.tilePane = this._createPane("leaflet-tile-pane", this._mapPane), t.objectsPane = this._createPane("leaflet-objects-pane", this._mapPane), t.shadowPane = this._createPane("leaflet-shadow-pane"), t.overlayPane = this._createPane("leaflet-overlay-pane"), t.markerPane = this._createPane("leaflet-marker-pane"), t.popupPane = this._createPane("leaflet-popup-pane");
      var e = " leaflet-zoom-hide";
      this.options.markerZoomAnimation || (o.DomUtil.addClass(t.markerPane, e), o.DomUtil.addClass(t.shadowPane, e), o.DomUtil.addClass(t.popupPane, e));
    },
    _createPane: function (t, e) {
      return o.DomUtil.create("div", t, e || this._panes.objectsPane);
    },
    _clearPanes: function () {
      this._container.removeChild(this._mapPane);
    },
    _addLayers: function (t) {
      t = t ? o.Util.isArray(t) ? t : [t] : [];
      for (var e = 0, i = t.length; i > e; e++) this.addLayer(t[e]);
    },
    _resetView: function (t, e, i, n) {
      var s = this._zoom !== e;
      n || (this.fire("movestart"), s && this.fire("zoomstart")), this._zoom = e, this._initialCenter = t, this._initialTopLeftPoint = this._getNewTopLeftPoint(t), i ? this._initialTopLeftPoint._add(this._getMapPanePos()) : o.DomUtil.setPosition(this._mapPane, new o.Point(0, 0)), this._tileLayersToLoad = this._tileLayersNum;
      var a = !this._loaded;
      this._loaded = !0, this.fire("viewreset", {
        hard: !i
      }), a && (this.fire("load"), this.eachLayer(this._layerAdd, this)), this.fire("move"), (s || n) && this.fire("zoomend"), this.fire("moveend", {
        hard: !i
      });
    },
    _rawPanBy: function (t) {
      o.DomUtil.setPosition(this._mapPane, this._getMapPanePos().subtract(t));
    },
    _getZoomSpan: function () {
      return this.getMaxZoom() - this.getMinZoom();
    },
    _updateZoomLevels: function () {
      var t,
        e = 1 / 0,
        n = -(1 / 0),
        o = this._getZoomSpan();
      for (t in this._zoomBoundLayers) {
        var s = this._zoomBoundLayers[t];
        isNaN(s.options.minZoom) || (e = Math.min(e, s.options.minZoom)), isNaN(s.options.maxZoom) || (n = Math.max(n, s.options.maxZoom));
      }
      t === i ? this._layersMaxZoom = this._layersMinZoom = i : (this._layersMaxZoom = n, this._layersMinZoom = e), o !== this._getZoomSpan() && this.fire("zoomlevelschange");
    },
    _panInsideMaxBounds: function () {
      this.panInsideBounds(this.options.maxBounds);
    },
    _checkIfLoaded: function () {
      if (!this._loaded) throw new Error("Set map center and zoom first.");
    },
    _initEvents: function (e) {
      if (o.DomEvent) {
        e = e || "on", o.DomEvent[e](this._container, "click", this._onMouseClick, this);
        var i,
          n,
          s = ["dblclick", "mousedown", "mouseup", "mouseenter", "mouseleave", "mousemove", "contextmenu"];
        for (i = 0, n = s.length; n > i; i++) o.DomEvent[e](this._container, s[i], this._fireMouseEvent, this);
        this.options.trackResize && o.DomEvent[e](t, "resize", this._onResize, this);
      }
    },
    _onResize: function () {
      o.Util.cancelAnimFrame(this._resizeRequest), this._resizeRequest = o.Util.requestAnimFrame(function () {
        this.invalidateSize({
          debounceMoveend: !0
        });
      }, this, !1, this._container);
    },
    _onMouseClick: function (t) {
      !this._loaded || !t._simulated && (this.dragging && this.dragging.moved() || this.boxZoom && this.boxZoom.moved()) || o.DomEvent._skipped(t) || (this.fire("preclick"), this._fireMouseEvent(t));
    },
    _fireMouseEvent: function (t) {
      if (this._loaded && !o.DomEvent._skipped(t)) {
        var e = t.type;
        if (e = "mouseenter" === e ? "mouseover" : "mouseleave" === e ? "mouseout" : e, this.hasEventListeners(e)) {
          "contextmenu" === e && o.DomEvent.preventDefault(t);
          var i = this.mouseEventToContainerPoint(t),
            n = this.containerPointToLayerPoint(i),
            s = this.layerPointToLatLng(n);
          this.fire(e, {
            latlng: s,
            layerPoint: n,
            containerPoint: i,
            originalEvent: t
          });
        }
      }
    },
    _onTileLayerLoad: function () {
      this._tileLayersToLoad--, this._tileLayersNum && !this._tileLayersToLoad && this.fire("tilelayersload");
    },
    _clearHandlers: function () {
      for (var t = 0, e = this._handlers.length; e > t; t++) this._handlers[t].disable();
    },
    whenReady: function (t, e) {
      return this._loaded ? t.call(e || this, this) : this.on("load", t, e), this;
    },
    _layerAdd: function (t) {
      t.onAdd(this), this.fire("layeradd", {
        layer: t
      });
    },
    _getMapPanePos: function () {
      return o.DomUtil.getPosition(this._mapPane);
    },
    _moved: function () {
      var t = this._getMapPanePos();
      return t && !t.equals([0, 0]);
    },
    _getTopLeftPoint: function () {
      return this.getPixelOrigin().subtract(this._getMapPanePos());
    },
    _getNewTopLeftPoint: function (t, e) {
      var i = this.getSize()._divideBy(2);
      return this.project(t, e)._subtract(i)._round();
    },
    _latLngToNewLayerPoint: function (t, e, i) {
      var n = this._getNewTopLeftPoint(i, e).add(this._getMapPanePos());
      return this.project(t, e)._subtract(n);
    },
    _getCenterLayerPoint: function () {
      return this.containerPointToLayerPoint(this.getSize()._divideBy(2));
    },
    _getCenterOffset: function (t) {
      return this.latLngToLayerPoint(t).subtract(this._getCenterLayerPoint());
    },
    _limitCenter: function (t, e, i) {
      if (!i) return t;
      var n = this.project(t, e),
        s = this.getSize().divideBy(2),
        a = new o.Bounds(n.subtract(s), n.add(s)),
        r = this._getBoundsOffset(a, i, e);
      return this.unproject(n.add(r), e);
    },
    _limitOffset: function (t, e) {
      if (!e) return t;
      var i = this.getPixelBounds(),
        n = new o.Bounds(i.min.add(t), i.max.add(t));
      return t.add(this._getBoundsOffset(n, e));
    },
    _getBoundsOffset: function (t, e, i) {
      var n = this.project(e.getNorthWest(), i).subtract(t.min),
        s = this.project(e.getSouthEast(), i).subtract(t.max),
        a = this._rebound(n.x, -s.x),
        r = this._rebound(n.y, -s.y);
      return new o.Point(a, r);
    },
    _rebound: function (t, e) {
      return t + e > 0 ? Math.round(t - e) / 2 : Math.max(0, Math.ceil(t)) - Math.max(0, Math.floor(e));
    },
    _limitZoom: function (t) {
      var e = this.getMinZoom(),
        i = this.getMaxZoom();
      return Math.max(e, Math.min(i, t));
    }
  }), o.map = function (t, e) {
    return new o.Map(t, e);
  }, o.Projection.Mercator = {
    MAX_LATITUDE: 85.0840591556,
    R_MINOR: 6356752.314245179,
    R_MAJOR: 6378137,
    project: function (t) {
      var e = o.LatLng.DEG_TO_RAD,
        i = this.MAX_LATITUDE,
        n = Math.max(Math.min(i, t.lat), -i),
        s = this.R_MAJOR,
        a = this.R_MINOR,
        r = t.lng * e * s,
        h = n * e,
        l = a / s,
        u = Math.sqrt(1 - l * l),
        c = u * Math.sin(h);
      c = Math.pow((1 - c) / (1 + c), .5 * u);
      var d = Math.tan(.5 * (.5 * Math.PI - h)) / c;
      return h = -s * Math.log(d), new o.Point(r, h);
    },
    unproject: function (t) {
      for (var e, i = o.LatLng.RAD_TO_DEG, n = this.R_MAJOR, s = this.R_MINOR, a = t.x * i / n, r = s / n, h = Math.sqrt(1 - r * r), l = Math.exp(-t.y / n), u = Math.PI / 2 - 2 * Math.atan(l), c = 15, d = 1e-7, p = c, _ = .1; Math.abs(_) > d && --p > 0;) e = h * Math.sin(u), _ = Math.PI / 2 - 2 * Math.atan(l * Math.pow((1 - e) / (1 + e), .5 * h)) - u, u += _;
      return new o.LatLng(u * i, a);
    }
  }, o.CRS.EPSG3395 = o.extend({}, o.CRS, {
    code: "EPSG:3395",
    projection: o.Projection.Mercator,
    transformation: function () {
      var t = o.Projection.Mercator,
        e = t.R_MAJOR,
        i = .5 / (Math.PI * e);
      return new o.Transformation(i, .5, -i, .5);
    }()
  }), o.TileLayer = o.Class.extend({
    includes: o.Mixin.Events,
    options: {
      minZoom: 0,
      maxZoom: 18,
      tileSize: 256,
      subdomains: "abc",
      errorTileUrl: "",
      attribution: "",
      zoomOffset: 0,
      opacity: 1,
      unloadInvisibleTiles: o.Browser.mobile,
      updateWhenIdle: o.Browser.mobile
    },
    initialize: function (t, e) {
      e = o.setOptions(this, e), e.detectRetina && o.Browser.retina && e.maxZoom > 0 && (e.tileSize = Math.floor(e.tileSize / 2), e.zoomOffset++, e.minZoom > 0 && e.minZoom--, this.options.maxZoom--), e.bounds && (e.bounds = o.latLngBounds(e.bounds)), this._url = t;
      var i = this.options.subdomains;
      "string" == typeof i && (this.options.subdomains = i.split(""));
    },
    onAdd: function (t) {
      this._map = t, this._animated = t._zoomAnimated, this._initContainer(), t.on({
        viewreset: this._reset,
        moveend: this._update
      }, this), this._animated && t.on({
        zoomanim: this._animateZoom,
        zoomend: this._endZoomAnim
      }, this), this.options.updateWhenIdle || (this._limitedUpdate = o.Util.limitExecByInterval(this._update, 150, this), t.on("move", this._limitedUpdate, this)), this._reset(), this._update();
    },
    addTo: function (t) {
      return t.addLayer(this), this;
    },
    onRemove: function (t) {
      this._container.parentNode.removeChild(this._container), t.off({
        viewreset: this._reset,
        moveend: this._update
      }, this), this._animated && t.off({
        zoomanim: this._animateZoom,
        zoomend: this._endZoomAnim
      }, this), this.options.updateWhenIdle || t.off("move", this._limitedUpdate, this), this._container = null, this._map = null;
    },
    bringToFront: function () {
      var t = this._map._panes.tilePane;
      return this._container && (t.appendChild(this._container), this._setAutoZIndex(t, Math.max)), this;
    },
    bringToBack: function () {
      var t = this._map._panes.tilePane;
      return this._container && (t.insertBefore(this._container, t.firstChild), this._setAutoZIndex(t, Math.min)), this;
    },
    getAttribution: function () {
      return this.options.attribution;
    },
    getContainer: function () {
      return this._container;
    },
    setOpacity: function (t) {
      return this.options.opacity = t, this._map && this._updateOpacity(), this;
    },
    setZIndex: function (t) {
      return this.options.zIndex = t, this._updateZIndex(), this;
    },
    setUrl: function (t, e) {
      return this._url = t, e || this.redraw(), this;
    },
    redraw: function () {
      return this._map && (this._reset({
        hard: !0
      }), this._update()), this;
    },
    _updateZIndex: function () {
      this._container && this.options.zIndex !== i && (this._container.style.zIndex = this.options.zIndex);
    },
    _setAutoZIndex: function (t, e) {
      var i,
        n,
        o,
        s = t.children,
        a = -e(1 / 0, -(1 / 0));
      for (n = 0, o = s.length; o > n; n++) s[n] !== this._container && (i = parseInt(s[n].style.zIndex, 10), isNaN(i) || (a = e(a, i)));
      this.options.zIndex = this._container.style.zIndex = (isFinite(a) ? a : 0) + e(1, -1);
    },
    _updateOpacity: function () {
      var t,
        e = this._tiles;
      if (o.Browser.ielt9) for (t in e) o.DomUtil.setOpacity(e[t], this.options.opacity);else o.DomUtil.setOpacity(this._container, this.options.opacity);
    },
    _initContainer: function () {
      var t = this._map._panes.tilePane;
      if (!this._container) {
        if (this._container = o.DomUtil.create("div", "leaflet-layer"), this._updateZIndex(), this._animated) {
          var e = "leaflet-tile-container";
          this._bgBuffer = o.DomUtil.create("div", e, this._container), this._tileContainer = o.DomUtil.create("div", e, this._container);
        } else this._tileContainer = this._container;
        t.appendChild(this._container), this.options.opacity < 1 && this._updateOpacity();
      }
    },
    _reset: function (t) {
      for (var e in this._tiles) this.fire("tileunload", {
        tile: this._tiles[e]
      });
      this._tiles = {}, this._tilesToLoad = 0, this.options.reuseTiles && (this._unusedTiles = []), this._tileContainer.innerHTML = "", this._animated && t && t.hard && this._clearBgBuffer(), this._initContainer();
    },
    _getTileSize: function () {
      var t = this._map,
        e = t.getZoom() + this.options.zoomOffset,
        i = this.options.maxNativeZoom,
        n = this.options.tileSize;
      return i && e > i && (n = Math.round(t.getZoomScale(e) / t.getZoomScale(i) * n)), n;
    },
    _update: function () {
      if (this._map) {
        var t = this._map,
          e = t.getPixelBounds(),
          i = t.getZoom(),
          n = this._getTileSize();
        if (!(i > this.options.maxZoom || i < this.options.minZoom)) {
          var s = o.bounds(e.min.divideBy(n)._floor(), e.max.divideBy(n)._floor());
          this._addTilesFromCenterOut(s), (this.options.unloadInvisibleTiles || this.options.reuseTiles) && this._removeOtherTiles(s);
        }
      }
    },
    _addTilesFromCenterOut: function (t) {
      var i,
        n,
        s,
        a = [],
        r = t.getCenter();
      for (i = t.min.y; i <= t.max.y; i++) for (n = t.min.x; n <= t.max.x; n++) s = new o.Point(n, i), this._tileShouldBeLoaded(s) && a.push(s);
      var h = a.length;
      if (0 !== h) {
        a.sort(function (t, e) {
          return t.distanceTo(r) - e.distanceTo(r);
        });
        var l = e.createDocumentFragment();
        for (this._tilesToLoad || this.fire("loading"), this._tilesToLoad += h, n = 0; h > n; n++) this._addTile(a[n], l);
        this._tileContainer.appendChild(l);
      }
    },
    _tileShouldBeLoaded: function (t) {
      if (t.x + ":" + t.y in this._tiles) return !1;
      var e = this.options;
      if (!e.continuousWorld) {
        var i = this._getWrapTileNum();
        if (e.noWrap && (t.x < 0 || t.x >= i.x) || t.y < 0 || t.y >= i.y) return !1;
      }
      if (e.bounds) {
        var n = this._getTileSize(),
          o = t.multiplyBy(n),
          s = o.add([n, n]),
          a = this._map.unproject(o),
          r = this._map.unproject(s);
        if (e.continuousWorld || e.noWrap || (a = a.wrap(), r = r.wrap()), !e.bounds.intersects([a, r])) return !1;
      }
      return !0;
    },
    _removeOtherTiles: function (t) {
      var e, i, n, o;
      for (o in this._tiles) e = o.split(":"), i = parseInt(e[0], 10), n = parseInt(e[1], 10), (i < t.min.x || i > t.max.x || n < t.min.y || n > t.max.y) && this._removeTile(o);
    },
    _removeTile: function (t) {
      var e = this._tiles[t];
      this.fire("tileunload", {
        tile: e,
        url: e.src
      }), this.options.reuseTiles ? (o.DomUtil.removeClass(e, "leaflet-tile-loaded"), this._unusedTiles.push(e)) : e.parentNode === this._tileContainer && this._tileContainer.removeChild(e), o.Browser.android || (e.onload = null, e.src = o.Util.emptyImageUrl), delete this._tiles[t];
    },
    _addTile: function (t, e) {
      var i = this._getTilePos(t),
        n = this._getTile();
      o.DomUtil.setPosition(n, i, o.Browser.chrome), this._tiles[t.x + ":" + t.y] = n, this._loadTile(n, t), n.parentNode !== this._tileContainer && e.appendChild(n);
    },
    _getZoomForUrl: function () {
      var t = this.options,
        e = this._map.getZoom();
      return t.zoomReverse && (e = t.maxZoom - e), e += t.zoomOffset, t.maxNativeZoom ? Math.min(e, t.maxNativeZoom) : e;
    },
    _getTilePos: function (t) {
      var e = this._map.getPixelOrigin(),
        i = this._getTileSize();
      return t.multiplyBy(i).subtract(e);
    },
    getTileUrl: function (t) {
      return o.Util.template(this._url, o.extend({
        s: this._getSubdomain(t),
        z: t.z,
        x: t.x,
        y: t.y
      }, this.options));
    },
    _getWrapTileNum: function () {
      var t = this._map.options.crs,
        e = t.getSize(this._map.getZoom());
      return e.divideBy(this._getTileSize())._floor();
    },
    _adjustTilePoint: function (t) {
      var e = this._getWrapTileNum();
      this.options.continuousWorld || this.options.noWrap || (t.x = (t.x % e.x + e.x) % e.x), this.options.tms && (t.y = e.y - t.y - 1), t.z = this._getZoomForUrl();
    },
    _getSubdomain: function (t) {
      var e = Math.abs(t.x + t.y) % this.options.subdomains.length;
      return this.options.subdomains[e];
    },
    _getTile: function () {
      if (this.options.reuseTiles && this._unusedTiles.length > 0) {
        var t = this._unusedTiles.pop();
        return this._resetTile(t), t;
      }
      return this._createTile();
    },
    _resetTile: function () {},
    _createTile: function () {
      var t = o.DomUtil.create("img", "leaflet-tile");
      return t.style.width = t.style.height = this._getTileSize() + "px", t.galleryimg = "no", t.onselectstart = t.onmousemove = o.Util.falseFn, o.Browser.ielt9 && this.options.opacity !== i && o.DomUtil.setOpacity(t, this.options.opacity), o.Browser.mobileWebkit3d && (t.style.WebkitBackfaceVisibility = "hidden"), t;
    },
    _loadTile: function (t, e) {
      t._layer = this, t.onload = this._tileOnLoad, t.onerror = this._tileOnError, this._adjustTilePoint(e), t.src = this.getTileUrl(e), this.fire("tileloadstart", {
        tile: t,
        url: t.src
      });
    },
    _tileLoaded: function () {
      this._tilesToLoad--, this._animated && o.DomUtil.addClass(this._tileContainer, "leaflet-zoom-animated"), this._tilesToLoad || (this.fire("load"), this._animated && (clearTimeout(this._clearBgBufferTimer), this._clearBgBufferTimer = setTimeout(o.bind(this._clearBgBuffer, this), 500)));
    },
    _tileOnLoad: function () {
      var t = this._layer;
      this.src !== o.Util.emptyImageUrl && (o.DomUtil.addClass(this, "leaflet-tile-loaded"), t.fire("tileload", {
        tile: this,
        url: this.src
      })), t._tileLoaded();
    },
    _tileOnError: function () {
      var t = this._layer;
      t.fire("tileerror", {
        tile: this,
        url: this.src
      });
      var e = t.options.errorTileUrl;
      e && (this.src = e), t._tileLoaded();
    }
  }), o.tileLayer = function (t, e) {
    return new o.TileLayer(t, e);
  }, o.TileLayer.WMS = o.TileLayer.extend({
    defaultWmsParams: {
      service: "WMS",
      request: "GetMap",
      version: "1.1.1",
      layers: "",
      styles: "",
      format: "image/jpeg",
      transparent: !1
    },
    initialize: function (t, e) {
      this._url = t;
      var i = o.extend({}, this.defaultWmsParams),
        n = e.tileSize || this.options.tileSize;
      e.detectRetina && o.Browser.retina ? i.width = i.height = 2 * n : i.width = i.height = n;
      for (var s in e) this.options.hasOwnProperty(s) || "crs" === s || (i[s] = e[s]);
      this.wmsParams = i, o.setOptions(this, e);
    },
    onAdd: function (t) {
      this._crs = this.options.crs || t.options.crs, this._wmsVersion = parseFloat(this.wmsParams.version);
      var e = this._wmsVersion >= 1.3 ? "crs" : "srs";
      this.wmsParams[e] = this._crs.code, o.TileLayer.prototype.onAdd.call(this, t);
    },
    getTileUrl: function (t) {
      var e = this._map,
        i = this.options.tileSize,
        n = t.multiplyBy(i),
        s = n.add([i, i]),
        a = this._crs.project(e.unproject(n, t.z)),
        r = this._crs.project(e.unproject(s, t.z)),
        h = this._wmsVersion >= 1.3 && this._crs === o.CRS.EPSG4326 ? [r.y, a.x, a.y, r.x].join(",") : [a.x, r.y, r.x, a.y].join(","),
        l = o.Util.template(this._url, {
          s: this._getSubdomain(t)
        });
      return l + o.Util.getParamString(this.wmsParams, l, !0) + "&BBOX=" + h;
    },
    setParams: function (t, e) {
      return o.extend(this.wmsParams, t), e || this.redraw(), this;
    }
  }), o.tileLayer.wms = function (t, e) {
    return new o.TileLayer.WMS(t, e);
  }, o.TileLayer.Canvas = o.TileLayer.extend({
    options: {
      async: !1
    },
    initialize: function (t) {
      o.setOptions(this, t);
    },
    redraw: function () {
      this._map && (this._reset({
        hard: !0
      }), this._update());
      for (var t in this._tiles) this._redrawTile(this._tiles[t]);
      return this;
    },
    _redrawTile: function (t) {
      this.drawTile(t, t._tilePoint, this._map._zoom);
    },
    _createTile: function () {
      var t = o.DomUtil.create("canvas", "leaflet-tile");
      return t.width = t.height = this.options.tileSize, t.onselectstart = t.onmousemove = o.Util.falseFn, t;
    },
    _loadTile: function (t, e) {
      t._layer = this, t._tilePoint = e, this._redrawTile(t), this.options.async || this.tileDrawn(t);
    },
    drawTile: function () {},
    tileDrawn: function (t) {
      this._tileOnLoad.call(t);
    }
  }), o.tileLayer.canvas = function (t) {
    return new o.TileLayer.Canvas(t);
  }, o.ImageOverlay = o.Class.extend({
    includes: o.Mixin.Events,
    options: {
      opacity: 1
    },
    initialize: function (t, e, i) {
      this._url = t, this._bounds = o.latLngBounds(e), o.setOptions(this, i);
    },
    onAdd: function (t) {
      this._map = t, this._image || this._initImage(), t._panes.overlayPane.appendChild(this._image), t.on("viewreset", this._reset, this), t.options.zoomAnimation && o.Browser.any3d && t.on("zoomanim", this._animateZoom, this), this._reset();
    },
    onRemove: function (t) {
      t.getPanes().overlayPane.removeChild(this._image), t.off("viewreset", this._reset, this), t.options.zoomAnimation && t.off("zoomanim", this._animateZoom, this);
    },
    addTo: function (t) {
      return t.addLayer(this), this;
    },
    setOpacity: function (t) {
      return this.options.opacity = t, this._updateOpacity(), this;
    },
    bringToFront: function () {
      return this._image && this._map._panes.overlayPane.appendChild(this._image), this;
    },
    bringToBack: function () {
      var t = this._map._panes.overlayPane;
      return this._image && t.insertBefore(this._image, t.firstChild), this;
    },
    setUrl: function (t) {
      this._url = t, this._image.src = this._url;
    },
    getAttribution: function () {
      return this.options.attribution;
    },
    _initImage: function () {
      this._image = o.DomUtil.create("img", "leaflet-image-layer"), this._map.options.zoomAnimation && o.Browser.any3d ? o.DomUtil.addClass(this._image, "leaflet-zoom-animated") : o.DomUtil.addClass(this._image, "leaflet-zoom-hide"), this._updateOpacity(), o.extend(this._image, {
        galleryimg: "no",
        onselectstart: o.Util.falseFn,
        onmousemove: o.Util.falseFn,
        onload: o.bind(this._onImageLoad, this),
        src: this._url
      });
    },
    _animateZoom: function (t) {
      var e = this._map,
        i = this._image,
        n = e.getZoomScale(t.zoom),
        s = this._bounds.getNorthWest(),
        a = this._bounds.getSouthEast(),
        r = e._latLngToNewLayerPoint(s, t.zoom, t.center),
        h = e._latLngToNewLayerPoint(a, t.zoom, t.center)._subtract(r),
        l = r._add(h._multiplyBy(.5 * (1 - 1 / n)));
      i.style[o.DomUtil.TRANSFORM] = o.DomUtil.getTranslateString(l) + " scale(" + n + ") ";
    },
    _reset: function () {
      var t = this._image,
        e = this._map.latLngToLayerPoint(this._bounds.getNorthWest()),
        i = this._map.latLngToLayerPoint(this._bounds.getSouthEast())._subtract(e);
      o.DomUtil.setPosition(t, e), t.style.width = i.x + "px", t.style.height = i.y + "px";
    },
    _onImageLoad: function () {
      this.fire("load");
    },
    _updateOpacity: function () {
      o.DomUtil.setOpacity(this._image, this.options.opacity);
    }
  }), o.imageOverlay = function (t, e, i) {
    return new o.ImageOverlay(t, e, i);
  }, o.Icon = o.Class.extend({
    options: {
      className: ""
    },
    initialize: function (t) {
      o.setOptions(this, t);
    },
    createIcon: function (t) {
      return this._createIcon("icon", t);
    },
    createShadow: function (t) {
      return this._createIcon("shadow", t);
    },
    _createIcon: function (t, e) {
      var i = this._getIconUrl(t);
      if (!i) {
        if ("icon" === t) throw new Error("iconUrl not set in Icon options (see the docs).");
        return null;
      }
      var n;
      return n = e && "IMG" === e.tagName ? this._createImg(i, e) : this._createImg(i), this._setIconStyles(n, t), n;
    },
    _setIconStyles: function (t, e) {
      var i,
        n = this.options,
        s = o.point(n[e + "Size"]);
      i = "shadow" === e ? o.point(n.shadowAnchor || n.iconAnchor) : o.point(n.iconAnchor), !i && s && (i = s.divideBy(2, !0)), t.className = "leaflet-marker-" + e + " " + n.className, i && (t.style.marginLeft = -i.x + "px", t.style.marginTop = -i.y + "px"), s && (t.style.width = s.x + "px", t.style.height = s.y + "px");
    },
    _createImg: function (t, i) {
      return i = i || e.createElement("img"), i.src = t, i;
    },
    _getIconUrl: function (t) {
      return o.Browser.retina && this.options[t + "RetinaUrl"] ? this.options[t + "RetinaUrl"] : this.options[t + "Url"];
    }
  }), o.icon = function (t) {
    return new o.Icon(t);
  }, o.Icon.Default = o.Icon.extend({
    options: {
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    },
    _getIconUrl: function (t) {
      var e = t + "Url";
      if (this.options[e]) return this.options[e];
      o.Browser.retina && "icon" === t && (t += "-2x");
      var i = o.Icon.Default.imagePath;
      if (!i) throw new Error("Couldn't autodetect L.Icon.Default.imagePath, set it manually.");
      return i + "/marker-" + t + ".png";
    }
  }), o.Icon.Default.imagePath = function () {
    var t,
      i,
      n,
      o,
      s,
      a = e.getElementsByTagName("script"),
      r = /[\/^]leaflet[\-\._]?([\w\-\._]*)\.js\??/;
    for (t = 0, i = a.length; i > t; t++) if (n = a[t].src, o = n.match(r)) return s = n.split(r)[0], (s ? s + "/" : "") + "images";
  }(), o.Marker = o.Class.extend({
    includes: o.Mixin.Events,
    options: {
      icon: new o.Icon.Default(),
      title: "",
      alt: "",
      clickable: !0,
      draggable: !1,
      keyboard: !0,
      zIndexOffset: 0,
      opacity: 1,
      riseOnHover: !1,
      riseOffset: 250
    },
    initialize: function (t, e) {
      o.setOptions(this, e), this._latlng = o.latLng(t);
    },
    onAdd: function (t) {
      this._map = t, t.on("viewreset", this.update, this), this._initIcon(), this.update(), this.fire("add"), t.options.zoomAnimation && t.options.markerZoomAnimation && t.on("zoomanim", this._animateZoom, this);
    },
    addTo: function (t) {
      return t.addLayer(this), this;
    },
    onRemove: function (t) {
      this.dragging && this.dragging.disable(), this._removeIcon(), this._removeShadow(), this.fire("remove"), t.off({
        viewreset: this.update,
        zoomanim: this._animateZoom
      }, this), this._map = null;
    },
    getLatLng: function () {
      return this._latlng;
    },
    setLatLng: function (t) {
      return this._latlng = o.latLng(t), this.update(), this.fire("move", {
        latlng: this._latlng
      });
    },
    setZIndexOffset: function (t) {
      return this.options.zIndexOffset = t, this.update(), this;
    },
    setIcon: function (t) {
      return this.options.icon = t, this._map && (this._initIcon(), this.update()), this._popup && this.bindPopup(this._popup), this;
    },
    update: function () {
      return this._icon && this._setPos(this._map.latLngToLayerPoint(this._latlng).round()), this;
    },
    _initIcon: function () {
      var t = this.options,
        e = this._map,
        i = e.options.zoomAnimation && e.options.markerZoomAnimation,
        n = i ? "leaflet-zoom-animated" : "leaflet-zoom-hide",
        s = t.icon.createIcon(this._icon),
        a = !1;
      s !== this._icon && (this._icon && this._removeIcon(), a = !0, t.title && (s.title = t.title), t.alt && (s.alt = t.alt)), o.DomUtil.addClass(s, n), t.keyboard && (s.tabIndex = "0"), this._icon = s, this._initInteraction(), t.riseOnHover && o.DomEvent.on(s, "mouseover", this._bringToFront, this).on(s, "mouseout", this._resetZIndex, this);
      var r = t.icon.createShadow(this._shadow),
        h = !1;
      r !== this._shadow && (this._removeShadow(), h = !0), r && o.DomUtil.addClass(r, n), this._shadow = r, t.opacity < 1 && this._updateOpacity();
      var l = this._map._panes;
      a && l.markerPane.appendChild(this._icon), r && h && l.shadowPane.appendChild(this._shadow);
    },
    _removeIcon: function () {
      this.options.riseOnHover && o.DomEvent.off(this._icon, "mouseover", this._bringToFront).off(this._icon, "mouseout", this._resetZIndex), this._map._panes.markerPane.removeChild(this._icon), this._icon = null;
    },
    _removeShadow: function () {
      this._shadow && this._map._panes.shadowPane.removeChild(this._shadow), this._shadow = null;
    },
    _setPos: function (t) {
      o.DomUtil.setPosition(this._icon, t), this._shadow && o.DomUtil.setPosition(this._shadow, t), this._zIndex = t.y + this.options.zIndexOffset, this._resetZIndex();
    },
    _updateZIndex: function (t) {
      this._icon.style.zIndex = this._zIndex + t;
    },
    _animateZoom: function (t) {
      var e = this._map._latLngToNewLayerPoint(this._latlng, t.zoom, t.center).round();
      this._setPos(e);
    },
    _initInteraction: function () {
      if (this.options.clickable) {
        var t = this._icon,
          e = ["dblclick", "mousedown", "mouseover", "mouseout", "contextmenu"];
        o.DomUtil.addClass(t, "leaflet-clickable"), o.DomEvent.on(t, "click", this._onMouseClick, this), o.DomEvent.on(t, "keypress", this._onKeyPress, this);
        for (var i = 0; i < e.length; i++) o.DomEvent.on(t, e[i], this._fireMouseEvent, this);
        o.Handler.MarkerDrag && (this.dragging = new o.Handler.MarkerDrag(this), this.options.draggable && this.dragging.enable());
      }
    },
    _onMouseClick: function (t) {
      var e = this.dragging && this.dragging.moved();
      (this.hasEventListeners(t.type) || e) && o.DomEvent.stopPropagation(t), e || (this.dragging && this.dragging._enabled || !this._map.dragging || !this._map.dragging.moved()) && this.fire(t.type, {
        originalEvent: t,
        latlng: this._latlng
      });
    },
    _onKeyPress: function (t) {
      13 === t.keyCode && this.fire("click", {
        originalEvent: t,
        latlng: this._latlng
      });
    },
    _fireMouseEvent: function (t) {
      this.fire(t.type, {
        originalEvent: t,
        latlng: this._latlng
      }), "contextmenu" === t.type && this.hasEventListeners(t.type) && o.DomEvent.preventDefault(t), "mousedown" !== t.type ? o.DomEvent.stopPropagation(t) : o.DomEvent.preventDefault(t);
    },
    setOpacity: function (t) {
      return this.options.opacity = t, this._map && this._updateOpacity(), this;
    },
    _updateOpacity: function () {
      o.DomUtil.setOpacity(this._icon, this.options.opacity), this._shadow && o.DomUtil.setOpacity(this._shadow, this.options.opacity);
    },
    _bringToFront: function () {
      this._updateZIndex(this.options.riseOffset);
    },
    _resetZIndex: function () {
      this._updateZIndex(0);
    }
  }), o.marker = function (t, e) {
    return new o.Marker(t, e);
  }, o.DivIcon = o.Icon.extend({
    options: {
      iconSize: [12, 12],
      className: "leaflet-div-icon",
      html: !1
    },
    createIcon: function (t) {
      var i = t && "DIV" === t.tagName ? t : e.createElement("div"),
        n = this.options;
      return n.html !== !1 ? i.innerHTML = n.html : i.innerHTML = "", n.bgPos && (i.style.backgroundPosition = -n.bgPos.x + "px " + -n.bgPos.y + "px"), this._setIconStyles(i, "icon"), i;
    },
    createShadow: function () {
      return null;
    }
  }), o.divIcon = function (t) {
    return new o.DivIcon(t);
  }, o.Map.mergeOptions({
    closePopupOnClick: !0
  }), o.Popup = o.Class.extend({
    includes: o.Mixin.Events,
    options: {
      minWidth: 50,
      maxWidth: 300,
      autoPan: !0,
      closeButton: !0,
      offset: [0, 7],
      autoPanPadding: [5, 5],
      keepInView: !1,
      className: "",
      zoomAnimation: !0
    },
    initialize: function (t, e) {
      o.setOptions(this, t), this._source = e, this._animated = o.Browser.any3d && this.options.zoomAnimation, this._isOpen = !1;
    },
    onAdd: function (t) {
      this._map = t, this._container || this._initLayout();
      var e = t.options.fadeAnimation;
      e && o.DomUtil.setOpacity(this._container, 0), t._panes.popupPane.appendChild(this._container), t.on(this._getEvents(), this), this.update(), e && o.DomUtil.setOpacity(this._container, 1), this.fire("open"), t.fire("popupopen", {
        popup: this
      }), this._source && this._source.fire("popupopen", {
        popup: this
      });
    },
    addTo: function (t) {
      return t.addLayer(this), this;
    },
    openOn: function (t) {
      return t.openPopup(this), this;
    },
    onRemove: function (t) {
      t._panes.popupPane.removeChild(this._container), o.Util.falseFn(this._container.offsetWidth), t.off(this._getEvents(), this), t.options.fadeAnimation && o.DomUtil.setOpacity(this._container, 0), this._map = null, this.fire("close"), t.fire("popupclose", {
        popup: this
      }), this._source && this._source.fire("popupclose", {
        popup: this
      });
    },
    getLatLng: function () {
      return this._latlng;
    },
    setLatLng: function (t) {
      return this._latlng = o.latLng(t), this._map && (this._updatePosition(), this._adjustPan()), this;
    },
    getContent: function () {
      return this._content;
    },
    setContent: function (t) {
      return this._content = t, this.update(), this;
    },
    update: function () {
      this._map && (this._container.style.visibility = "hidden", this._updateContent(), this._updateLayout(), this._updatePosition(), this._container.style.visibility = "", this._adjustPan());
    },
    _getEvents: function () {
      var t = {
        viewreset: this._updatePosition
      };
      return this._animated && (t.zoomanim = this._zoomAnimation), ("closeOnClick" in this.options ? this.options.closeOnClick : this._map.options.closePopupOnClick) && (t.preclick = this._close), this.options.keepInView && (t.moveend = this._adjustPan), t;
    },
    _close: function () {
      this._map && this._map.closePopup(this);
    },
    _initLayout: function () {
      var t,
        e = "leaflet-popup",
        i = e + " " + this.options.className + " leaflet-zoom-" + (this._animated ? "animated" : "hide"),
        n = this._container = o.DomUtil.create("div", i);
      this.options.closeButton && (t = this._closeButton = o.DomUtil.create("a", e + "-close-button", n), t.href = "#close", t.innerHTML = "&#215;", o.DomEvent.disableClickPropagation(t), o.DomEvent.on(t, "click", this._onCloseButtonClick, this));
      var s = this._wrapper = o.DomUtil.create("div", e + "-content-wrapper", n);
      o.DomEvent.disableClickPropagation(s), this._contentNode = o.DomUtil.create("div", e + "-content", s), o.DomEvent.disableScrollPropagation(this._contentNode), o.DomEvent.on(s, "contextmenu", o.DomEvent.stopPropagation), this._tipContainer = o.DomUtil.create("div", e + "-tip-container", n), this._tip = o.DomUtil.create("div", e + "-tip", this._tipContainer);
    },
    _updateContent: function () {
      if (this._content) {
        if ("string" == typeof this._content) this._contentNode.innerHTML = this._content;else {
          for (; this._contentNode.hasChildNodes();) this._contentNode.removeChild(this._contentNode.firstChild);
          this._contentNode.appendChild(this._content);
        }
        this.fire("contentupdate");
      }
    },
    _updateLayout: function () {
      var t = this._contentNode,
        e = t.style;
      e.width = "", e.whiteSpace = "nowrap";
      var i = t.offsetWidth;
      i = Math.min(i, this.options.maxWidth), i = Math.max(i, this.options.minWidth), e.width = i + 1 + "px", e.whiteSpace = "", e.height = "";
      var n = t.offsetHeight,
        s = this.options.maxHeight,
        a = "leaflet-popup-scrolled";
      s && n > s ? (e.height = s + "px", o.DomUtil.addClass(t, a)) : o.DomUtil.removeClass(t, a), this._containerWidth = this._container.offsetWidth;
    },
    _updatePosition: function () {
      if (this._map) {
        var t = this._map.latLngToLayerPoint(this._latlng),
          e = this._animated,
          i = o.point(this.options.offset);
        e && o.DomUtil.setPosition(this._container, t), this._containerBottom = -i.y - (e ? 0 : t.y), this._containerLeft = -Math.round(this._containerWidth / 2) + i.x + (e ? 0 : t.x), this._container.style.bottom = this._containerBottom + "px", this._container.style.left = this._containerLeft + "px";
      }
    },
    _zoomAnimation: function (t) {
      var e = this._map._latLngToNewLayerPoint(this._latlng, t.zoom, t.center);
      o.DomUtil.setPosition(this._container, e);
    },
    _adjustPan: function () {
      if (this.options.autoPan) {
        var t = this._map,
          e = this._container.offsetHeight,
          i = this._containerWidth,
          n = new o.Point(this._containerLeft, -e - this._containerBottom);
        this._animated && n._add(o.DomUtil.getPosition(this._container));
        var s = t.layerPointToContainerPoint(n),
          a = o.point(this.options.autoPanPadding),
          r = o.point(this.options.autoPanPaddingTopLeft || a),
          h = o.point(this.options.autoPanPaddingBottomRight || a),
          l = t.getSize(),
          u = 0,
          c = 0;
        s.x + i + h.x > l.x && (u = s.x + i - l.x + h.x), s.x - u - r.x < 0 && (u = s.x - r.x), s.y + e + h.y > l.y && (c = s.y + e - l.y + h.y), s.y - c - r.y < 0 && (c = s.y - r.y), (u || c) && t.fire("autopanstart").panBy([u, c]);
      }
    },
    _onCloseButtonClick: function (t) {
      this._close(), o.DomEvent.stop(t);
    }
  }), o.popup = function (t, e) {
    return new o.Popup(t, e);
  }, o.Map.include({
    openPopup: function (t, e, i) {
      if (this.closePopup(), !(t instanceof o.Popup)) {
        var n = t;
        t = new o.Popup(i).setLatLng(e).setContent(n);
      }
      return t._isOpen = !0, this._popup = t, this.addLayer(t);
    },
    closePopup: function (t) {
      return t && t !== this._popup || (t = this._popup, this._popup = null), t && (this.removeLayer(t), t._isOpen = !1), this;
    }
  }), o.Marker.include({
    openPopup: function () {
      return this._popup && this._map && !this._map.hasLayer(this._popup) && (this._popup.setLatLng(this._latlng), this._map.openPopup(this._popup)), this;
    },
    closePopup: function () {
      return this._popup && this._popup._close(), this;
    },
    togglePopup: function () {
      return this._popup && (this._popup._isOpen ? this.closePopup() : this.openPopup()), this;
    },
    bindPopup: function (t, e) {
      var i = o.point(this.options.icon.options.popupAnchor || [0, 0]);
      return i = i.add(o.Popup.prototype.options.offset), e && e.offset && (i = i.add(e.offset)), e = o.extend({
        offset: i
      }, e), this._popupHandlersAdded || (this.on("click", this.togglePopup, this).on("remove", this.closePopup, this).on("move", this._movePopup, this), this._popupHandlersAdded = !0), t instanceof o.Popup ? (o.setOptions(t, e), this._popup = t, t._source = this) : this._popup = new o.Popup(e, this).setContent(t), this;
    },
    setPopupContent: function (t) {
      return this._popup && this._popup.setContent(t), this;
    },
    unbindPopup: function () {
      return this._popup && (this._popup = null, this.off("click", this.togglePopup, this).off("remove", this.closePopup, this).off("move", this._movePopup, this), this._popupHandlersAdded = !1), this;
    },
    getPopup: function () {
      return this._popup;
    },
    _movePopup: function (t) {
      this._popup.setLatLng(t.latlng);
    }
  }), o.LayerGroup = o.Class.extend({
    initialize: function (t) {
      this._layers = {};
      var e, i;
      if (t) for (e = 0, i = t.length; i > e; e++) this.addLayer(t[e]);
    },
    addLayer: function (t) {
      var e = this.getLayerId(t);
      return this._layers[e] = t, this._map && this._map.addLayer(t), this;
    },
    removeLayer: function (t) {
      var e = t in this._layers ? t : this.getLayerId(t);
      return this._map && this._layers[e] && this._map.removeLayer(this._layers[e]), delete this._layers[e], this;
    },
    hasLayer: function (t) {
      return t ? t in this._layers || this.getLayerId(t) in this._layers : !1;
    },
    clearLayers: function () {
      return this.eachLayer(this.removeLayer, this), this;
    },
    invoke: function (t) {
      var e,
        i,
        n = Array.prototype.slice.call(arguments, 1);
      for (e in this._layers) i = this._layers[e], i[t] && i[t].apply(i, n);
      return this;
    },
    onAdd: function (t) {
      this._map = t, this.eachLayer(t.addLayer, t);
    },
    onRemove: function (t) {
      this.eachLayer(t.removeLayer, t), this._map = null;
    },
    addTo: function (t) {
      return t.addLayer(this), this;
    },
    eachLayer: function (t, e) {
      for (var i in this._layers) t.call(e, this._layers[i]);
      return this;
    },
    getLayer: function (t) {
      return this._layers[t];
    },
    getLayers: function () {
      var t = [];
      for (var e in this._layers) t.push(this._layers[e]);
      return t;
    },
    setZIndex: function (t) {
      return this.invoke("setZIndex", t);
    },
    getLayerId: function (t) {
      return o.stamp(t);
    }
  }), o.layerGroup = function (t) {
    return new o.LayerGroup(t);
  }, o.FeatureGroup = o.LayerGroup.extend({
    includes: o.Mixin.Events,
    statics: {
      EVENTS: "click dblclick mouseover mouseout mousemove contextmenu popupopen popupclose"
    },
    addLayer: function (t) {
      return this.hasLayer(t) ? this : ("on" in t && t.on(o.FeatureGroup.EVENTS, this._propagateEvent, this), o.LayerGroup.prototype.addLayer.call(this, t), this._popupContent && t.bindPopup && t.bindPopup(this._popupContent, this._popupOptions), this.fire("layeradd", {
        layer: t
      }));
    },
    removeLayer: function (t) {
      return this.hasLayer(t) ? (t in this._layers && (t = this._layers[t]), "off" in t && t.off(o.FeatureGroup.EVENTS, this._propagateEvent, this), o.LayerGroup.prototype.removeLayer.call(this, t), this._popupContent && this.invoke("unbindPopup"), this.fire("layerremove", {
        layer: t
      })) : this;
    },
    bindPopup: function (t, e) {
      return this._popupContent = t, this._popupOptions = e, this.invoke("bindPopup", t, e);
    },
    openPopup: function (t) {
      for (var e in this._layers) {
        this._layers[e].openPopup(t);
        break;
      }
      return this;
    },
    setStyle: function (t) {
      return this.invoke("setStyle", t);
    },
    bringToFront: function () {
      return this.invoke("bringToFront");
    },
    bringToBack: function () {
      return this.invoke("bringToBack");
    },
    getBounds: function () {
      var t = new o.LatLngBounds();
      return this.eachLayer(function (e) {
        t.extend(e instanceof o.Marker ? e.getLatLng() : e.getBounds());
      }), t;
    },
    _propagateEvent: function (t) {
      t = o.extend({
        layer: t.target,
        target: this
      }, t), this.fire(t.type, t);
    }
  }), o.featureGroup = function (t) {
    return new o.FeatureGroup(t);
  }, o.Path = o.Class.extend({
    includes: [o.Mixin.Events],
    statics: {
      CLIP_PADDING: function () {
        var e = o.Browser.mobile ? 1280 : 2e3,
          i = (e / Math.max(t.outerWidth, t.outerHeight) - 1) / 2;
        return Math.max(0, Math.min(.5, i));
      }()
    },
    options: {
      stroke: !0,
      color: "#0033ff",
      dashArray: null,
      lineCap: null,
      lineJoin: null,
      weight: 5,
      opacity: .5,
      fill: !1,
      fillColor: null,
      fillOpacity: .2,
      clickable: !0
    },
    initialize: function (t) {
      o.setOptions(this, t);
    },
    onAdd: function (t) {
      this._map = t, this._container || (this._initElements(), this._initEvents()), this.projectLatlngs(), this._updatePath(), this._container && this._map._pathRoot.appendChild(this._container), this.fire("add"), t.on({
        viewreset: this.projectLatlngs,
        moveend: this._updatePath
      }, this);
    },
    addTo: function (t) {
      return t.addLayer(this), this;
    },
    onRemove: function (t) {
      t._pathRoot.removeChild(this._container), this.fire("remove"), this._map = null, o.Browser.vml && (this._container = null, this._stroke = null, this._fill = null), t.off({
        viewreset: this.projectLatlngs,
        moveend: this._updatePath
      }, this);
    },
    projectLatlngs: function () {},
    setStyle: function (t) {
      return o.setOptions(this, t), this._container && this._updateStyle(), this;
    },
    redraw: function () {
      return this._map && (this.projectLatlngs(), this._updatePath()), this;
    }
  }), o.Map.include({
    _updatePathViewport: function () {
      var t = o.Path.CLIP_PADDING,
        e = this.getSize(),
        i = o.DomUtil.getPosition(this._mapPane),
        n = i.multiplyBy(-1)._subtract(e.multiplyBy(t)._round()),
        s = n.add(e.multiplyBy(1 + 2 * t)._round());
      this._pathViewport = new o.Bounds(n, s);
    }
  }), o.Path.SVG_NS = "http://www.w3.org/2000/svg", o.Browser.svg = !(!e.createElementNS || !e.createElementNS(o.Path.SVG_NS, "svg").createSVGRect), o.Path = o.Path.extend({
    statics: {
      SVG: o.Browser.svg
    },
    bringToFront: function () {
      var t = this._map._pathRoot,
        e = this._container;
      return e && t.lastChild !== e && t.appendChild(e), this;
    },
    bringToBack: function () {
      var t = this._map._pathRoot,
        e = this._container,
        i = t.firstChild;
      return e && i !== e && t.insertBefore(e, i), this;
    },
    getPathString: function () {},
    _createElement: function (t) {
      return e.createElementNS(o.Path.SVG_NS, t);
    },
    _initElements: function () {
      this._map._initPathRoot(), this._initPath(), this._initStyle();
    },
    _initPath: function () {
      this._container = this._createElement("g"), this._path = this._createElement("path"), this.options.className && o.DomUtil.addClass(this._path, this.options.className), this._container.appendChild(this._path);
    },
    _initStyle: function () {
      this.options.stroke && (this._path.setAttribute("stroke-linejoin", "round"), this._path.setAttribute("stroke-linecap", "round")), this.options.fill && this._path.setAttribute("fill-rule", "evenodd"), this.options.pointerEvents && this._path.setAttribute("pointer-events", this.options.pointerEvents), this.options.clickable || this.options.pointerEvents || this._path.setAttribute("pointer-events", "none"), this._updateStyle();
    },
    _updateStyle: function () {
      this.options.stroke ? (this._path.setAttribute("stroke", this.options.color), this._path.setAttribute("stroke-opacity", this.options.opacity), this._path.setAttribute("stroke-width", this.options.weight), this.options.dashArray ? this._path.setAttribute("stroke-dasharray", this.options.dashArray) : this._path.removeAttribute("stroke-dasharray"), this.options.lineCap && this._path.setAttribute("stroke-linecap", this.options.lineCap), this.options.lineJoin && this._path.setAttribute("stroke-linejoin", this.options.lineJoin)) : this._path.setAttribute("stroke", "none"), this.options.fill ? (this._path.setAttribute("fill", this.options.fillColor || this.options.color), this._path.setAttribute("fill-opacity", this.options.fillOpacity)) : this._path.setAttribute("fill", "none");
    },
    _updatePath: function () {
      var t = this.getPathString();
      t || (t = "M0 0"), this._path.setAttribute("d", t);
    },
    _initEvents: function () {
      if (this.options.clickable) {
        (o.Browser.svg || !o.Browser.vml) && o.DomUtil.addClass(this._path, "leaflet-clickable"), o.DomEvent.on(this._container, "click", this._onMouseClick, this);
        for (var t = ["dblclick", "mousedown", "mouseover", "mouseout", "mousemove", "contextmenu"], e = 0; e < t.length; e++) o.DomEvent.on(this._container, t[e], this._fireMouseEvent, this);
      }
    },
    _onMouseClick: function (t) {
      this._map.dragging && this._map.dragging.moved() || this._fireMouseEvent(t);
    },
    _fireMouseEvent: function (t) {
      if (this._map && this.hasEventListeners(t.type)) {
        var e = this._map,
          i = e.mouseEventToContainerPoint(t),
          n = e.containerPointToLayerPoint(i),
          s = e.layerPointToLatLng(n);
        this.fire(t.type, {
          latlng: s,
          layerPoint: n,
          containerPoint: i,
          originalEvent: t
        }), "contextmenu" === t.type && o.DomEvent.preventDefault(t), "mousemove" !== t.type && o.DomEvent.stopPropagation(t);
      }
    }
  }), o.Map.include({
    _initPathRoot: function () {
      this._pathRoot || (this._pathRoot = o.Path.prototype._createElement("svg"), this._panes.overlayPane.appendChild(this._pathRoot), this.options.zoomAnimation && o.Browser.any3d ? (o.DomUtil.addClass(this._pathRoot, "leaflet-zoom-animated"), this.on({
        zoomanim: this._animatePathZoom,
        zoomend: this._endPathZoom
      })) : o.DomUtil.addClass(this._pathRoot, "leaflet-zoom-hide"), this.on("moveend", this._updateSvgViewport), this._updateSvgViewport());
    },
    _animatePathZoom: function (t) {
      var e = this.getZoomScale(t.zoom),
        i = this._getCenterOffset(t.center)._multiplyBy(-e)._add(this._pathViewport.min);
      this._pathRoot.style[o.DomUtil.TRANSFORM] = o.DomUtil.getTranslateString(i) + " scale(" + e + ") ", this._pathZooming = !0;
    },
    _endPathZoom: function () {
      this._pathZooming = !1;
    },
    _updateSvgViewport: function () {
      if (!this._pathZooming) {
        this._updatePathViewport();
        var t = this._pathViewport,
          e = t.min,
          i = t.max,
          n = i.x - e.x,
          s = i.y - e.y,
          a = this._pathRoot,
          r = this._panes.overlayPane;
        o.Browser.mobileWebkit && r.removeChild(a), o.DomUtil.setPosition(a, e), a.setAttribute("width", n), a.setAttribute("height", s), a.setAttribute("viewBox", [e.x, e.y, n, s].join(" ")), o.Browser.mobileWebkit && r.appendChild(a);
      }
    }
  }), o.Path.include({
    bindPopup: function (t, e) {
      return t instanceof o.Popup ? this._popup = t : ((!this._popup || e) && (this._popup = new o.Popup(e, this)), this._popup.setContent(t)), this._popupHandlersAdded || (this.on("click", this._openPopup, this).on("remove", this.closePopup, this), this._popupHandlersAdded = !0), this;
    },
    unbindPopup: function () {
      return this._popup && (this._popup = null, this.off("click", this._openPopup).off("remove", this.closePopup), this._popupHandlersAdded = !1), this;
    },
    openPopup: function (t) {
      return this._popup && (t = t || this._latlng || this._latlngs[Math.floor(this._latlngs.length / 2)], this._openPopup({
        latlng: t
      })), this;
    },
    closePopup: function () {
      return this._popup && this._popup._close(), this;
    },
    _openPopup: function (t) {
      this._popup.setLatLng(t.latlng), this._map.openPopup(this._popup);
    }
  }), o.Browser.vml = !o.Browser.svg && function () {
    try {
      var t = e.createElement("div");
      t.innerHTML = '<v:shape adj="1"/>';
      var i = t.firstChild;
      return i.style.behavior = "url(#default#VML)", i && "object" == typeof i.adj;
    } catch (n) {
      return !1;
    }
  }(), o.Path = o.Browser.svg || !o.Browser.vml ? o.Path : o.Path.extend({
    statics: {
      VML: !0,
      CLIP_PADDING: .02
    },
    _createElement: function () {
      try {
        return e.namespaces.add("lvml", "urn:schemas-microsoft-com:vml"), function (t) {
          return e.createElement("<lvml:" + t + ' class="lvml">');
        };
      } catch (t) {
        return function (t) {
          return e.createElement("<" + t + ' xmlns="urn:schemas-microsoft.com:vml" class="lvml">');
        };
      }
    }(),
    _initPath: function () {
      var t = this._container = this._createElement("shape");
      o.DomUtil.addClass(t, "leaflet-vml-shape" + (this.options.className ? " " + this.options.className : "")), this.options.clickable && o.DomUtil.addClass(t, "leaflet-clickable"), t.coordsize = "1 1", this._path = this._createElement("path"), t.appendChild(this._path), this._map._pathRoot.appendChild(t);
    },
    _initStyle: function () {
      this._updateStyle();
    },
    _updateStyle: function () {
      var t = this._stroke,
        e = this._fill,
        i = this.options,
        n = this._container;
      n.stroked = i.stroke, n.filled = i.fill, i.stroke ? (t || (t = this._stroke = this._createElement("stroke"), t.endcap = "round", n.appendChild(t)), t.weight = i.weight + "px", t.color = i.color, t.opacity = i.opacity, i.dashArray ? t.dashStyle = o.Util.isArray(i.dashArray) ? i.dashArray.join(" ") : i.dashArray.replace(/( *, *)/g, " ") : t.dashStyle = "", i.lineCap && (t.endcap = i.lineCap.replace("butt", "flat")), i.lineJoin && (t.joinstyle = i.lineJoin)) : t && (n.removeChild(t), this._stroke = null), i.fill ? (e || (e = this._fill = this._createElement("fill"), n.appendChild(e)), e.color = i.fillColor || i.color, e.opacity = i.fillOpacity) : e && (n.removeChild(e), this._fill = null);
    },
    _updatePath: function () {
      var t = this._container.style;
      t.display = "none", this._path.v = this.getPathString() + " ", t.display = "";
    }
  }), o.Map.include(o.Browser.svg || !o.Browser.vml ? {} : {
    _initPathRoot: function () {
      if (!this._pathRoot) {
        var t = this._pathRoot = e.createElement("div");
        t.className = "leaflet-vml-container", this._panes.overlayPane.appendChild(t), this.on("moveend", this._updatePathViewport), this._updatePathViewport();
      }
    }
  }), o.Browser.canvas = function () {
    return !!e.createElement("canvas").getContext;
  }(), o.Path = o.Path.SVG && !t.L_PREFER_CANVAS || !o.Browser.canvas ? o.Path : o.Path.extend({
    statics: {
      CANVAS: !0,
      SVG: !1
    },
    redraw: function () {
      return this._map && (this.projectLatlngs(), this._requestUpdate()), this;
    },
    setStyle: function (t) {
      return o.setOptions(this, t), this._map && (this._updateStyle(), this._requestUpdate()), this;
    },
    onRemove: function (t) {
      t.off("viewreset", this.projectLatlngs, this).off("moveend", this._updatePath, this), this.options.clickable && (this._map.off("click", this._onClick, this), this._map.off("mousemove", this._onMouseMove, this)), this._requestUpdate(), this.fire("remove"), this._map = null;
    },
    _requestUpdate: function () {
      this._map && !o.Path._updateRequest && (o.Path._updateRequest = o.Util.requestAnimFrame(this._fireMapMoveEnd, this._map));
    },
    _fireMapMoveEnd: function () {
      o.Path._updateRequest = null, this.fire("moveend");
    },
    _initElements: function () {
      this._map._initPathRoot(), this._ctx = this._map._canvasCtx;
    },
    _updateStyle: function () {
      var t = this.options;
      t.stroke && (this._ctx.lineWidth = t.weight, this._ctx.strokeStyle = t.color), t.fill && (this._ctx.fillStyle = t.fillColor || t.color), t.lineCap && (this._ctx.lineCap = t.lineCap), t.lineJoin && (this._ctx.lineJoin = t.lineJoin);
    },
    _drawPath: function () {
      var t, e, i, n, s, a;
      for (this._ctx.beginPath(), t = 0, i = this._parts.length; i > t; t++) {
        for (e = 0, n = this._parts[t].length; n > e; e++) s = this._parts[t][e], a = (0 === e ? "move" : "line") + "To", this._ctx[a](s.x, s.y);
        this instanceof o.Polygon && this._ctx.closePath();
      }
    },
    _checkIfEmpty: function () {
      return !this._parts.length;
    },
    _updatePath: function () {
      if (!this._checkIfEmpty()) {
        var t = this._ctx,
          e = this.options;
        this._drawPath(), t.save(), this._updateStyle(), e.fill && (t.globalAlpha = e.fillOpacity, t.fill(e.fillRule || "evenodd")), e.stroke && (t.globalAlpha = e.opacity, t.stroke()), t.restore();
      }
    },
    _initEvents: function () {
      this.options.clickable && (this._map.on("mousemove", this._onMouseMove, this), this._map.on("click dblclick contextmenu", this._fireMouseEvent, this));
    },
    _fireMouseEvent: function (t) {
      this._containsPoint(t.layerPoint) && this.fire(t.type, t);
    },
    _onMouseMove: function (t) {
      this._map && !this._map._animatingZoom && (this._containsPoint(t.layerPoint) ? (this._ctx.canvas.style.cursor = "pointer", this._mouseInside = !0, this.fire("mouseover", t)) : this._mouseInside && (this._ctx.canvas.style.cursor = "", this._mouseInside = !1, this.fire("mouseout", t)));
    }
  }), o.Map.include(o.Path.SVG && !t.L_PREFER_CANVAS || !o.Browser.canvas ? {} : {
    _initPathRoot: function () {
      var t,
        i = this._pathRoot;
      i || (i = this._pathRoot = e.createElement("canvas"), i.style.position = "absolute", t = this._canvasCtx = i.getContext("2d"), t.lineCap = "round", t.lineJoin = "round", this._panes.overlayPane.appendChild(i), this.options.zoomAnimation && (this._pathRoot.className = "leaflet-zoom-animated", this.on("zoomanim", this._animatePathZoom), this.on("zoomend", this._endPathZoom)), this.on("moveend", this._updateCanvasViewport), this._updateCanvasViewport());
    },
    _updateCanvasViewport: function () {
      if (!this._pathZooming) {
        this._updatePathViewport();
        var t = this._pathViewport,
          e = t.min,
          i = t.max.subtract(e),
          n = this._pathRoot;
        o.DomUtil.setPosition(n, e), n.width = i.x, n.height = i.y, n.getContext("2d").translate(-e.x, -e.y);
      }
    }
  }), o.LineUtil = {
    simplify: function (t, e) {
      if (!e || !t.length) return t.slice();
      var i = e * e;
      return t = this._reducePoints(t, i), t = this._simplifyDP(t, i);
    },
    pointToSegmentDistance: function (t, e, i) {
      return Math.sqrt(this._sqClosestPointOnSegment(t, e, i, !0));
    },
    closestPointOnSegment: function (t, e, i) {
      return this._sqClosestPointOnSegment(t, e, i);
    },
    _simplifyDP: function (t, e) {
      var n = t.length,
        o = typeof Uint8Array != i + "" ? Uint8Array : Array,
        s = new o(n);
      s[0] = s[n - 1] = 1, this._simplifyDPStep(t, s, e, 0, n - 1);
      var a,
        r = [];
      for (a = 0; n > a; a++) s[a] && r.push(t[a]);
      return r;
    },
    _simplifyDPStep: function (t, e, i, n, o) {
      var s,
        a,
        r,
        h = 0;
      for (a = n + 1; o - 1 >= a; a++) r = this._sqClosestPointOnSegment(t[a], t[n], t[o], !0), r > h && (s = a, h = r);
      h > i && (e[s] = 1, this._simplifyDPStep(t, e, i, n, s), this._simplifyDPStep(t, e, i, s, o));
    },
    _reducePoints: function (t, e) {
      for (var i = [t[0]], n = 1, o = 0, s = t.length; s > n; n++) this._sqDist(t[n], t[o]) > e && (i.push(t[n]), o = n);
      return s - 1 > o && i.push(t[s - 1]), i;
    },
    clipSegment: function (t, e, i, n) {
      var o,
        s,
        a,
        r = n ? this._lastCode : this._getBitCode(t, i),
        h = this._getBitCode(e, i);
      for (this._lastCode = h;;) {
        if (!(r | h)) return [t, e];
        if (r & h) return !1;
        o = r || h, s = this._getEdgeIntersection(t, e, o, i), a = this._getBitCode(s, i), o === r ? (t = s, r = a) : (e = s, h = a);
      }
    },
    _getEdgeIntersection: function (t, e, i, n) {
      var s = e.x - t.x,
        a = e.y - t.y,
        r = n.min,
        h = n.max;
      return 8 & i ? new o.Point(t.x + s * (h.y - t.y) / a, h.y) : 4 & i ? new o.Point(t.x + s * (r.y - t.y) / a, r.y) : 2 & i ? new o.Point(h.x, t.y + a * (h.x - t.x) / s) : 1 & i ? new o.Point(r.x, t.y + a * (r.x - t.x) / s) : void 0;
    },
    _getBitCode: function (t, e) {
      var i = 0;
      return t.x < e.min.x ? i |= 1 : t.x > e.max.x && (i |= 2), t.y < e.min.y ? i |= 4 : t.y > e.max.y && (i |= 8), i;
    },
    _sqDist: function (t, e) {
      var i = e.x - t.x,
        n = e.y - t.y;
      return i * i + n * n;
    },
    _sqClosestPointOnSegment: function (t, e, i, n) {
      var s,
        a = e.x,
        r = e.y,
        h = i.x - a,
        l = i.y - r,
        u = h * h + l * l;
      return u > 0 && (s = ((t.x - a) * h + (t.y - r) * l) / u, s > 1 ? (a = i.x, r = i.y) : s > 0 && (a += h * s, r += l * s)), h = t.x - a, l = t.y - r, n ? h * h + l * l : new o.Point(a, r);
    }
  }, o.Polyline = o.Path.extend({
    initialize: function (t, e) {
      o.Path.prototype.initialize.call(this, e), this._latlngs = this._convertLatLngs(t);
    },
    options: {
      smoothFactor: 1,
      noClip: !1
    },
    projectLatlngs: function () {
      this._originalPoints = [];
      for (var t = 0, e = this._latlngs.length; e > t; t++) this._originalPoints[t] = this._map.latLngToLayerPoint(this._latlngs[t]);
    },
    getPathString: function () {
      for (var t = 0, e = this._parts.length, i = ""; e > t; t++) i += this._getPathPartStr(this._parts[t]);
      return i;
    },
    getLatLngs: function () {
      return this._latlngs;
    },
    setLatLngs: function (t) {
      return this._latlngs = this._convertLatLngs(t), this.redraw();
    },
    addLatLng: function (t) {
      return this._latlngs.push(o.latLng(t)), this.redraw();
    },
    spliceLatLngs: function () {
      var t = [].splice.apply(this._latlngs, arguments);
      return this._convertLatLngs(this._latlngs, !0), this.redraw(), t;
    },
    closestLayerPoint: function (t) {
      for (var e, i, n = 1 / 0, s = this._parts, a = null, r = 0, h = s.length; h > r; r++) for (var l = s[r], u = 1, c = l.length; c > u; u++) {
        e = l[u - 1], i = l[u];
        var d = o.LineUtil._sqClosestPointOnSegment(t, e, i, !0);
        n > d && (n = d, a = o.LineUtil._sqClosestPointOnSegment(t, e, i));
      }
      return a && (a.distance = Math.sqrt(n)), a;
    },
    getBounds: function () {
      return new o.LatLngBounds(this.getLatLngs());
    },
    _convertLatLngs: function (t, e) {
      var i,
        n,
        s = e ? t : [];
      for (i = 0, n = t.length; n > i; i++) {
        if (o.Util.isArray(t[i]) && "number" != typeof t[i][0]) return;
        s[i] = o.latLng(t[i]);
      }
      return s;
    },
    _initEvents: function () {
      o.Path.prototype._initEvents.call(this);
    },
    _getPathPartStr: function (t) {
      for (var e, i = o.Path.VML, n = 0, s = t.length, a = ""; s > n; n++) e = t[n], i && e._round(), a += (n ? "L" : "M") + e.x + " " + e.y;
      return a;
    },
    _clipPoints: function () {
      var t,
        e,
        i,
        n = this._originalPoints,
        s = n.length;
      if (this.options.noClip) return void (this._parts = [n]);
      this._parts = [];
      var a = this._parts,
        r = this._map._pathViewport,
        h = o.LineUtil;
      for (t = 0, e = 0; s - 1 > t; t++) i = h.clipSegment(n[t], n[t + 1], r, t), i && (a[e] = a[e] || [], a[e].push(i[0]), (i[1] !== n[t + 1] || t === s - 2) && (a[e].push(i[1]), e++));
    },
    _simplifyPoints: function () {
      for (var t = this._parts, e = o.LineUtil, i = 0, n = t.length; n > i; i++) t[i] = e.simplify(t[i], this.options.smoothFactor);
    },
    _updatePath: function () {
      this._map && (this._clipPoints(), this._simplifyPoints(), o.Path.prototype._updatePath.call(this));
    }
  }), o.polyline = function (t, e) {
    return new o.Polyline(t, e);
  }, o.PolyUtil = {}, o.PolyUtil.clipPolygon = function (t, e) {
    var i,
      n,
      s,
      a,
      r,
      h,
      l,
      u,
      c,
      d = [1, 4, 2, 8],
      p = o.LineUtil;
    for (n = 0, l = t.length; l > n; n++) t[n]._code = p._getBitCode(t[n], e);
    for (a = 0; 4 > a; a++) {
      for (u = d[a], i = [], n = 0, l = t.length, s = l - 1; l > n; s = n++) r = t[n], h = t[s], r._code & u ? h._code & u || (c = p._getEdgeIntersection(h, r, u, e), c._code = p._getBitCode(c, e), i.push(c)) : (h._code & u && (c = p._getEdgeIntersection(h, r, u, e), c._code = p._getBitCode(c, e), i.push(c)), i.push(r));
      t = i;
    }
    return t;
  }, o.Polygon = o.Polyline.extend({
    options: {
      fill: !0
    },
    initialize: function (t, e) {
      o.Polyline.prototype.initialize.call(this, t, e), this._initWithHoles(t);
    },
    _initWithHoles: function (t) {
      var e, i, n;
      if (t && o.Util.isArray(t[0]) && "number" != typeof t[0][0]) for (this._latlngs = this._convertLatLngs(t[0]), this._holes = t.slice(1), e = 0, i = this._holes.length; i > e; e++) n = this._holes[e] = this._convertLatLngs(this._holes[e]), n[0].equals(n[n.length - 1]) && n.pop();
      t = this._latlngs, t.length >= 2 && t[0].equals(t[t.length - 1]) && t.pop();
    },
    projectLatlngs: function () {
      if (o.Polyline.prototype.projectLatlngs.call(this), this._holePoints = [], this._holes) {
        var t, e, i, n;
        for (t = 0, i = this._holes.length; i > t; t++) for (this._holePoints[t] = [], e = 0, n = this._holes[t].length; n > e; e++) this._holePoints[t][e] = this._map.latLngToLayerPoint(this._holes[t][e]);
      }
    },
    setLatLngs: function (t) {
      return t && o.Util.isArray(t[0]) && "number" != typeof t[0][0] ? (this._initWithHoles(t), this.redraw()) : o.Polyline.prototype.setLatLngs.call(this, t);
    },
    _clipPoints: function () {
      var t = this._originalPoints,
        e = [];
      if (this._parts = [t].concat(this._holePoints), !this.options.noClip) {
        for (var i = 0, n = this._parts.length; n > i; i++) {
          var s = o.PolyUtil.clipPolygon(this._parts[i], this._map._pathViewport);
          s.length && e.push(s);
        }
        this._parts = e;
      }
    },
    _getPathPartStr: function (t) {
      var e = o.Polyline.prototype._getPathPartStr.call(this, t);
      return e + (o.Browser.svg ? "z" : "x");
    }
  }), o.polygon = function (t, e) {
    return new o.Polygon(t, e);
  }, function () {
    function t(t) {
      return o.FeatureGroup.extend({
        initialize: function (t, e) {
          this._layers = {}, this._options = e, this.setLatLngs(t);
        },
        setLatLngs: function (e) {
          var i = 0,
            n = e.length;
          for (this.eachLayer(function (t) {
            n > i ? t.setLatLngs(e[i++]) : this.removeLayer(t);
          }, this); n > i;) this.addLayer(new t(e[i++], this._options));
          return this;
        },
        getLatLngs: function () {
          var t = [];
          return this.eachLayer(function (e) {
            t.push(e.getLatLngs());
          }), t;
        }
      });
    }
    o.MultiPolyline = t(o.Polyline), o.MultiPolygon = t(o.Polygon), o.multiPolyline = function (t, e) {
      return new o.MultiPolyline(t, e);
    }, o.multiPolygon = function (t, e) {
      return new o.MultiPolygon(t, e);
    };
  }(), o.Rectangle = o.Polygon.extend({
    initialize: function (t, e) {
      o.Polygon.prototype.initialize.call(this, this._boundsToLatLngs(t), e);
    },
    setBounds: function (t) {
      this.setLatLngs(this._boundsToLatLngs(t));
    },
    _boundsToLatLngs: function (t) {
      return t = o.latLngBounds(t), [t.getSouthWest(), t.getNorthWest(), t.getNorthEast(), t.getSouthEast()];
    }
  }), o.rectangle = function (t, e) {
    return new o.Rectangle(t, e);
  }, o.Circle = o.Path.extend({
    initialize: function (t, e, i) {
      o.Path.prototype.initialize.call(this, i), this._latlng = o.latLng(t), this._mRadius = e;
    },
    options: {
      fill: !0
    },
    setLatLng: function (t) {
      return this._latlng = o.latLng(t), this.redraw();
    },
    setRadius: function (t) {
      return this._mRadius = t, this.redraw();
    },
    projectLatlngs: function () {
      var t = this._getLngRadius(),
        e = this._latlng,
        i = this._map.latLngToLayerPoint([e.lat, e.lng - t]);
      this._point = this._map.latLngToLayerPoint(e), this._radius = Math.max(this._point.x - i.x, 1);
    },
    getBounds: function () {
      var t = this._getLngRadius(),
        e = this._mRadius / 40075017 * 360,
        i = this._latlng;
      return new o.LatLngBounds([i.lat - e, i.lng - t], [i.lat + e, i.lng + t]);
    },
    getLatLng: function () {
      return this._latlng;
    },
    getPathString: function () {
      var t = this._point,
        e = this._radius;
      return this._checkIfEmpty() ? "" : o.Browser.svg ? "M" + t.x + "," + (t.y - e) + "A" + e + "," + e + ",0,1,1," + (t.x - .1) + "," + (t.y - e) + " z" : (t._round(), e = Math.round(e), "AL " + t.x + "," + t.y + " " + e + "," + e + " 0,23592600");
    },
    getRadius: function () {
      return this._mRadius;
    },
    _getLatRadius: function () {
      return this._mRadius / 40075017 * 360;
    },
    _getLngRadius: function () {
      return this._getLatRadius() / Math.cos(o.LatLng.DEG_TO_RAD * this._latlng.lat);
    },
    _checkIfEmpty: function () {
      if (!this._map) return !1;
      var t = this._map._pathViewport,
        e = this._radius,
        i = this._point;
      return i.x - e > t.max.x || i.y - e > t.max.y || i.x + e < t.min.x || i.y + e < t.min.y;
    }
  }), o.circle = function (t, e, i) {
    return new o.Circle(t, e, i);
  }, o.CircleMarker = o.Circle.extend({
    options: {
      radius: 10,
      weight: 2
    },
    initialize: function (t, e) {
      o.Circle.prototype.initialize.call(this, t, null, e), this._radius = this.options.radius;
    },
    projectLatlngs: function () {
      this._point = this._map.latLngToLayerPoint(this._latlng);
    },
    _updateStyle: function () {
      o.Circle.prototype._updateStyle.call(this), this.setRadius(this.options.radius);
    },
    setLatLng: function (t) {
      return o.Circle.prototype.setLatLng.call(this, t), this._popup && this._popup._isOpen && this._popup.setLatLng(t), this;
    },
    setRadius: function (t) {
      return this.options.radius = this._radius = t, this.redraw();
    },
    getRadius: function () {
      return this._radius;
    }
  }), o.circleMarker = function (t, e) {
    return new o.CircleMarker(t, e);
  }, o.Polyline.include(o.Path.CANVAS ? {
    _containsPoint: function (t, e) {
      var i,
        n,
        s,
        a,
        r,
        h,
        l,
        u = this.options.weight / 2;
      for (o.Browser.touch && (u += 10), i = 0, a = this._parts.length; a > i; i++) for (l = this._parts[i], n = 0, r = l.length, s = r - 1; r > n; s = n++) if ((e || 0 !== n) && (h = o.LineUtil.pointToSegmentDistance(t, l[s], l[n]), u >= h)) return !0;
      return !1;
    }
  } : {}), o.Polygon.include(o.Path.CANVAS ? {
    _containsPoint: function (t) {
      var e,
        i,
        n,
        s,
        a,
        r,
        h,
        l,
        u = !1;
      if (o.Polyline.prototype._containsPoint.call(this, t, !0)) return !0;
      for (s = 0, h = this._parts.length; h > s; s++) for (e = this._parts[s], a = 0, l = e.length, r = l - 1; l > a; r = a++) i = e[a], n = e[r], i.y > t.y != n.y > t.y && t.x < (n.x - i.x) * (t.y - i.y) / (n.y - i.y) + i.x && (u = !u);
      return u;
    }
  } : {}), o.Circle.include(o.Path.CANVAS ? {
    _drawPath: function () {
      var t = this._point;
      this._ctx.beginPath(), this._ctx.arc(t.x, t.y, this._radius, 0, 2 * Math.PI, !1);
    },
    _containsPoint: function (t) {
      var e = this._point,
        i = this.options.stroke ? this.options.weight / 2 : 0;
      return t.distanceTo(e) <= this._radius + i;
    }
  } : {}), o.CircleMarker.include(o.Path.CANVAS ? {
    _updateStyle: function () {
      o.Path.prototype._updateStyle.call(this);
    }
  } : {}), o.GeoJSON = o.FeatureGroup.extend({
    initialize: function (t, e) {
      o.setOptions(this, e), this._layers = {}, t && this.addData(t);
    },
    addData: function (t) {
      var e,
        i,
        n,
        s = o.Util.isArray(t) ? t : t.features;
      if (s) {
        for (e = 0, i = s.length; i > e; e++) n = s[e], (n.geometries || n.geometry || n.features || n.coordinates) && this.addData(s[e]);
        return this;
      }
      var a = this.options;
      if (!a.filter || a.filter(t)) {
        var r = o.GeoJSON.geometryToLayer(t, a.pointToLayer, a.coordsToLatLng, a);
        return r.feature = o.GeoJSON.asFeature(t), r.defaultOptions = r.options, this.resetStyle(r), a.onEachFeature && a.onEachFeature(t, r), this.addLayer(r);
      }
    },
    resetStyle: function (t) {
      var e = this.options.style;
      e && (o.Util.extend(t.options, t.defaultOptions), this._setLayerStyle(t, e));
    },
    setStyle: function (t) {
      this.eachLayer(function (e) {
        this._setLayerStyle(e, t);
      }, this);
    },
    _setLayerStyle: function (t, e) {
      "function" == typeof e && (e = e(t.feature)), t.setStyle && t.setStyle(e);
    }
  }), o.extend(o.GeoJSON, {
    geometryToLayer: function (t, e, i, n) {
      var s,
        a,
        r,
        h,
        l = "Feature" === t.type ? t.geometry : t,
        u = l.coordinates,
        c = [];
      switch (i = i || this.coordsToLatLng, l.type) {
        case "Point":
          return s = i(u), e ? e(t, s) : new o.Marker(s);
        case "MultiPoint":
          for (r = 0, h = u.length; h > r; r++) s = i(u[r]), c.push(e ? e(t, s) : new o.Marker(s));
          return new o.FeatureGroup(c);
        case "LineString":
          return a = this.coordsToLatLngs(u, 0, i), new o.Polyline(a, n);
        case "Polygon":
          if (2 === u.length && !u[1].length) throw new Error("Invalid GeoJSON object.");
          return a = this.coordsToLatLngs(u, 1, i), new o.Polygon(a, n);
        case "MultiLineString":
          return a = this.coordsToLatLngs(u, 1, i), new o.MultiPolyline(a, n);
        case "MultiPolygon":
          return a = this.coordsToLatLngs(u, 2, i), new o.MultiPolygon(a, n);
        case "GeometryCollection":
          for (r = 0, h = l.geometries.length; h > r; r++) c.push(this.geometryToLayer({
            geometry: l.geometries[r],
            type: "Feature",
            properties: t.properties
          }, e, i, n));
          return new o.FeatureGroup(c);
        default:
          throw new Error("Invalid GeoJSON object.");
      }
    },
    coordsToLatLng: function (t) {
      return new o.LatLng(t[1], t[0], t[2]);
    },
    coordsToLatLngs: function (t, e, i) {
      var n,
        o,
        s,
        a = [];
      for (o = 0, s = t.length; s > o; o++) n = e ? this.coordsToLatLngs(t[o], e - 1, i) : (i || this.coordsToLatLng)(t[o]), a.push(n);
      return a;
    },
    latLngToCoords: function (t) {
      var e = [t.lng, t.lat];
      return t.alt !== i && e.push(t.alt), e;
    },
    latLngsToCoords: function (t) {
      for (var e = [], i = 0, n = t.length; n > i; i++) e.push(o.GeoJSON.latLngToCoords(t[i]));
      return e;
    },
    getFeature: function (t, e) {
      return t.feature ? o.extend({}, t.feature, {
        geometry: e
      }) : o.GeoJSON.asFeature(e);
    },
    asFeature: function (t) {
      return "Feature" === t.type ? t : {
        type: "Feature",
        properties: {},
        geometry: t
      };
    }
  });
  var a = {
    toGeoJSON: function () {
      return o.GeoJSON.getFeature(this, {
        type: "Point",
        coordinates: o.GeoJSON.latLngToCoords(this.getLatLng())
      });
    }
  };
  o.Marker.include(a), o.Circle.include(a), o.CircleMarker.include(a), o.Polyline.include({
    toGeoJSON: function () {
      return o.GeoJSON.getFeature(this, {
        type: "LineString",
        coordinates: o.GeoJSON.latLngsToCoords(this.getLatLngs())
      });
    }
  }), o.Polygon.include({
    toGeoJSON: function () {
      var t,
        e,
        i,
        n = [o.GeoJSON.latLngsToCoords(this.getLatLngs())];
      if (n[0].push(n[0][0]), this._holes) for (t = 0, e = this._holes.length; e > t; t++) i = o.GeoJSON.latLngsToCoords(this._holes[t]), i.push(i[0]), n.push(i);
      return o.GeoJSON.getFeature(this, {
        type: "Polygon",
        coordinates: n
      });
    }
  }), function () {
    function t(t) {
      return function () {
        var e = [];
        return this.eachLayer(function (t) {
          e.push(t.toGeoJSON().geometry.coordinates);
        }), o.GeoJSON.getFeature(this, {
          type: t,
          coordinates: e
        });
      };
    }
    o.MultiPolyline.include({
      toGeoJSON: t("MultiLineString")
    }), o.MultiPolygon.include({
      toGeoJSON: t("MultiPolygon")
    }), o.LayerGroup.include({
      toGeoJSON: function () {
        var e,
          i = this.feature && this.feature.geometry,
          n = [];
        if (i && "MultiPoint" === i.type) return t("MultiPoint").call(this);
        var s = i && "GeometryCollection" === i.type;
        return this.eachLayer(function (t) {
          t.toGeoJSON && (e = t.toGeoJSON(), n.push(s ? e.geometry : o.GeoJSON.asFeature(e)));
        }), s ? o.GeoJSON.getFeature(this, {
          geometries: n,
          type: "GeometryCollection"
        }) : {
          type: "FeatureCollection",
          features: n
        };
      }
    });
  }(), o.geoJson = function (t, e) {
    return new o.GeoJSON(t, e);
  }, o.DomEvent = {
    addListener: function (t, e, i, n) {
      var s,
        a,
        r,
        h = o.stamp(i),
        l = "_leaflet_" + e + h;
      return t[l] ? this : (s = function (e) {
        return i.call(n || t, e || o.DomEvent._getEvent());
      }, o.Browser.pointer && 0 === e.indexOf("touch") ? this.addPointerListener(t, e, s, h) : (o.Browser.touch && "dblclick" === e && this.addDoubleTapListener && this.addDoubleTapListener(t, s, h), "addEventListener" in t ? "mousewheel" === e ? (t.addEventListener("DOMMouseScroll", s, !1), t.addEventListener(e, s, !1)) : "mouseenter" === e || "mouseleave" === e ? (a = s, r = "mouseenter" === e ? "mouseover" : "mouseout", s = function (e) {
        return o.DomEvent._checkMouse(t, e) ? a(e) : void 0;
      }, t.addEventListener(r, s, !1)) : "click" === e && o.Browser.android ? (a = s, s = function (t) {
        return o.DomEvent._filterClick(t, a);
      }, t.addEventListener(e, s, !1)) : t.addEventListener(e, s, !1) : "attachEvent" in t && t.attachEvent("on" + e, s), t[l] = s, this));
    },
    removeListener: function (t, e, i) {
      var n = o.stamp(i),
        s = "_leaflet_" + e + n,
        a = t[s];
      return a ? (o.Browser.pointer && 0 === e.indexOf("touch") ? this.removePointerListener(t, e, n) : o.Browser.touch && "dblclick" === e && this.removeDoubleTapListener ? this.removeDoubleTapListener(t, n) : "removeEventListener" in t ? "mousewheel" === e ? (t.removeEventListener("DOMMouseScroll", a, !1), t.removeEventListener(e, a, !1)) : "mouseenter" === e || "mouseleave" === e ? t.removeEventListener("mouseenter" === e ? "mouseover" : "mouseout", a, !1) : t.removeEventListener(e, a, !1) : "detachEvent" in t && t.detachEvent("on" + e, a), t[s] = null, this) : this;
    },
    stopPropagation: function (t) {
      return t.stopPropagation ? t.stopPropagation() : t.cancelBubble = !0, o.DomEvent._skipped(t), this;
    },
    disableScrollPropagation: function (t) {
      var e = o.DomEvent.stopPropagation;
      return o.DomEvent.on(t, "mousewheel", e).on(t, "MozMousePixelScroll", e);
    },
    disableClickPropagation: function (t) {
      for (var e = o.DomEvent.stopPropagation, i = o.Draggable.START.length - 1; i >= 0; i--) o.DomEvent.on(t, o.Draggable.START[i], e);
      return o.DomEvent.on(t, "click", o.DomEvent._fakeStop).on(t, "dblclick", e);
    },
    preventDefault: function (t) {
      return t.preventDefault ? t.preventDefault() : t.returnValue = !1, this;
    },
    stop: function (t) {
      return o.DomEvent.preventDefault(t).stopPropagation(t);
    },
    getMousePosition: function (t, e) {
      if (!e) return new o.Point(t.clientX, t.clientY);
      var i = e.getBoundingClientRect();
      return new o.Point(t.clientX - i.left - e.clientLeft, t.clientY - i.top - e.clientTop);
    },
    getWheelDelta: function (t) {
      var e = 0;
      return t.wheelDelta && (e = t.wheelDelta / 120), t.detail && (e = -t.detail / 3), e;
    },
    _skipEvents: {},
    _fakeStop: function (t) {
      o.DomEvent._skipEvents[t.type] = !0;
    },
    _skipped: function (t) {
      var e = this._skipEvents[t.type];
      return this._skipEvents[t.type] = !1, e;
    },
    _checkMouse: function (t, e) {
      var i = e.relatedTarget;
      if (!i) return !0;
      try {
        for (; i && i !== t;) i = i.parentNode;
      } catch (n) {
        return !1;
      }
      return i !== t;
    },
    _getEvent: function () {
      var e = t.event;
      if (!e) for (var i = arguments.callee.caller; i && (e = i.arguments[0], !e || t.Event !== e.constructor);) i = i.caller;
      return e;
    },
    _filterClick: function (t, e) {
      var i = t.timeStamp || t.originalEvent.timeStamp,
        n = o.DomEvent._lastClick && i - o.DomEvent._lastClick;
      return n && n > 100 && 500 > n || t.target._simulatedClick && !t._simulated ? void o.DomEvent.stop(t) : (o.DomEvent._lastClick = i, e(t));
    }
  }, o.DomEvent.on = o.DomEvent.addListener, o.DomEvent.off = o.DomEvent.removeListener, o.Draggable = o.Class.extend({
    includes: o.Mixin.Events,
    statics: {
      START: o.Browser.touch ? ["touchstart", "mousedown"] : ["mousedown"],
      END: {
        mousedown: "mouseup",
        touchstart: "touchend",
        pointerdown: "touchend",
        MSPointerDown: "touchend"
      },
      MOVE: {
        mousedown: "mousemove",
        touchstart: "touchmove",
        pointerdown: "touchmove",
        MSPointerDown: "touchmove"
      }
    },
    initialize: function (t, e) {
      this._element = t, this._dragStartTarget = e || t;
    },
    enable: function () {
      if (!this._enabled) {
        for (var t = o.Draggable.START.length - 1; t >= 0; t--) o.DomEvent.on(this._dragStartTarget, o.Draggable.START[t], this._onDown, this);
        this._enabled = !0;
      }
    },
    disable: function () {
      if (this._enabled) {
        for (var t = o.Draggable.START.length - 1; t >= 0; t--) o.DomEvent.off(this._dragStartTarget, o.Draggable.START[t], this._onDown, this);
        this._enabled = !1, this._moved = !1;
      }
    },
    _onDown: function (t) {
      if (this._moved = !1, !t.shiftKey && (1 === t.which || 1 === t.button || t.touches) && (o.DomEvent.stopPropagation(t), !o.Draggable._disabled && (o.DomUtil.disableImageDrag(), o.DomUtil.disableTextSelection(), !this._moving))) {
        var i = t.touches ? t.touches[0] : t;
        this._startPoint = new o.Point(i.clientX, i.clientY), this._startPos = this._newPos = o.DomUtil.getPosition(this._element), o.DomEvent.on(e, o.Draggable.MOVE[t.type], this._onMove, this).on(e, o.Draggable.END[t.type], this._onUp, this);
      }
    },
    _onMove: function (t) {
      if (t.touches && t.touches.length > 1) return void (this._moved = !0);
      var i = t.touches && 1 === t.touches.length ? t.touches[0] : t,
        n = new o.Point(i.clientX, i.clientY),
        s = n.subtract(this._startPoint);
      (s.x || s.y) && (o.Browser.touch && Math.abs(s.x) + Math.abs(s.y) < 3 || (o.DomEvent.preventDefault(t), this._moved || (this.fire("dragstart"), this._moved = !0, this._startPos = o.DomUtil.getPosition(this._element).subtract(s), o.DomUtil.addClass(e.body, "leaflet-dragging"), this._lastTarget = t.target || t.srcElement, o.DomUtil.addClass(this._lastTarget, "leaflet-drag-target")), this._newPos = this._startPos.add(s), this._moving = !0, o.Util.cancelAnimFrame(this._animRequest), this._animRequest = o.Util.requestAnimFrame(this._updatePosition, this, !0, this._dragStartTarget)));
    },
    _updatePosition: function () {
      this.fire("predrag"), o.DomUtil.setPosition(this._element, this._newPos), this.fire("drag");
    },
    _onUp: function () {
      o.DomUtil.removeClass(e.body, "leaflet-dragging"), this._lastTarget && (o.DomUtil.removeClass(this._lastTarget, "leaflet-drag-target"), this._lastTarget = null);
      for (var t in o.Draggable.MOVE) o.DomEvent.off(e, o.Draggable.MOVE[t], this._onMove).off(e, o.Draggable.END[t], this._onUp);
      o.DomUtil.enableImageDrag(), o.DomUtil.enableTextSelection(), this._moved && this._moving && (o.Util.cancelAnimFrame(this._animRequest), this.fire("dragend", {
        distance: this._newPos.distanceTo(this._startPos)
      })), this._moving = !1;
    }
  }), o.Handler = o.Class.extend({
    initialize: function (t) {
      this._map = t;
    },
    enable: function () {
      this._enabled || (this._enabled = !0, this.addHooks());
    },
    disable: function () {
      this._enabled && (this._enabled = !1, this.removeHooks());
    },
    enabled: function () {
      return !!this._enabled;
    }
  }), o.Map.mergeOptions({
    dragging: !0,
    inertia: !o.Browser.android23,
    inertiaDeceleration: 3400,
    inertiaMaxSpeed: 1 / 0,
    inertiaThreshold: o.Browser.touch ? 32 : 18,
    easeLinearity: .25,
    worldCopyJump: !1
  }), o.Map.Drag = o.Handler.extend({
    addHooks: function () {
      if (!this._draggable) {
        var t = this._map;
        this._draggable = new o.Draggable(t._mapPane, t._container), this._draggable.on({
          dragstart: this._onDragStart,
          drag: this._onDrag,
          dragend: this._onDragEnd
        }, this), t.options.worldCopyJump && (this._draggable.on("predrag", this._onPreDrag, this), t.on("viewreset", this._onViewReset, this), t.whenReady(this._onViewReset, this));
      }
      this._draggable.enable();
    },
    removeHooks: function () {
      this._draggable.disable();
    },
    moved: function () {
      return this._draggable && this._draggable._moved;
    },
    _onDragStart: function () {
      var t = this._map;
      t._panAnim && t._panAnim.stop(), t.fire("movestart").fire("dragstart"), t.options.inertia && (this._positions = [], this._times = []);
    },
    _onDrag: function () {
      if (this._map.options.inertia) {
        var t = this._lastTime = +new Date(),
          e = this._lastPos = this._draggable._newPos;
        this._positions.push(e), this._times.push(t), t - this._times[0] > 200 && (this._positions.shift(), this._times.shift());
      }
      this._map.fire("move").fire("drag");
    },
    _onViewReset: function () {
      var t = this._map.getSize()._divideBy(2),
        e = this._map.latLngToLayerPoint([0, 0]);
      this._initialWorldOffset = e.subtract(t).x, this._worldWidth = this._map.project([0, 180]).x;
    },
    _onPreDrag: function () {
      var t = this._worldWidth,
        e = Math.round(t / 2),
        i = this._initialWorldOffset,
        n = this._draggable._newPos.x,
        o = (n - e + i) % t + e - i,
        s = (n + e + i) % t - e - i,
        a = Math.abs(o + i) < Math.abs(s + i) ? o : s;
      this._draggable._newPos.x = a;
    },
    _onDragEnd: function (t) {
      var e = this._map,
        i = e.options,
        n = +new Date() - this._lastTime,
        s = !i.inertia || n > i.inertiaThreshold || !this._positions[0];
      if (e.fire("dragend", t), s) e.fire("moveend");else {
        var a = this._lastPos.subtract(this._positions[0]),
          r = (this._lastTime + n - this._times[0]) / 1e3,
          h = i.easeLinearity,
          l = a.multiplyBy(h / r),
          u = l.distanceTo([0, 0]),
          c = Math.min(i.inertiaMaxSpeed, u),
          d = l.multiplyBy(c / u),
          p = c / (i.inertiaDeceleration * h),
          _ = d.multiplyBy(-p / 2).round();
        _.x && _.y ? (_ = e._limitOffset(_, e.options.maxBounds), o.Util.requestAnimFrame(function () {
          e.panBy(_, {
            duration: p,
            easeLinearity: h,
            noMoveStart: !0
          });
        })) : e.fire("moveend");
      }
    }
  }), o.Map.addInitHook("addHandler", "dragging", o.Map.Drag), o.Map.mergeOptions({
    doubleClickZoom: !0
  }), o.Map.DoubleClickZoom = o.Handler.extend({
    addHooks: function () {
      this._map.on("dblclick", this._onDoubleClick, this);
    },
    removeHooks: function () {
      this._map.off("dblclick", this._onDoubleClick, this);
    },
    _onDoubleClick: function (t) {
      var e = this._map,
        i = e.getZoom() + (t.originalEvent.shiftKey ? -1 : 1);
      "center" === e.options.doubleClickZoom ? e.setZoom(i) : e.setZoomAround(t.containerPoint, i);
    }
  }), o.Map.addInitHook("addHandler", "doubleClickZoom", o.Map.DoubleClickZoom), o.Map.mergeOptions({
    scrollWheelZoom: !0
  }), o.Map.ScrollWheelZoom = o.Handler.extend({
    addHooks: function () {
      o.DomEvent.on(this._map._container, "mousewheel", this._onWheelScroll, this), o.DomEvent.on(this._map._container, "MozMousePixelScroll", o.DomEvent.preventDefault), this._delta = 0;
    },
    removeHooks: function () {
      o.DomEvent.off(this._map._container, "mousewheel", this._onWheelScroll), o.DomEvent.off(this._map._container, "MozMousePixelScroll", o.DomEvent.preventDefault);
    },
    _onWheelScroll: function (t) {
      var e = o.DomEvent.getWheelDelta(t);
      this._delta += e, this._lastMousePos = this._map.mouseEventToContainerPoint(t), this._startTime || (this._startTime = +new Date());
      var i = Math.max(40 - (+new Date() - this._startTime), 0);
      clearTimeout(this._timer), this._timer = setTimeout(o.bind(this._performZoom, this), i), o.DomEvent.preventDefault(t), o.DomEvent.stopPropagation(t);
    },
    _performZoom: function () {
      var t = this._map,
        e = this._delta,
        i = t.getZoom();
      e = e > 0 ? Math.ceil(e) : Math.floor(e), e = Math.max(Math.min(e, 4), -4), e = t._limitZoom(i + e) - i, this._delta = 0, this._startTime = null, e && ("center" === t.options.scrollWheelZoom ? t.setZoom(i + e) : t.setZoomAround(this._lastMousePos, i + e));
    }
  }), o.Map.addInitHook("addHandler", "scrollWheelZoom", o.Map.ScrollWheelZoom), o.extend(o.DomEvent, {
    _touchstart: o.Browser.msPointer ? "MSPointerDown" : o.Browser.pointer ? "pointerdown" : "touchstart",
    _touchend: o.Browser.msPointer ? "MSPointerUp" : o.Browser.pointer ? "pointerup" : "touchend",
    addDoubleTapListener: function (t, i, n) {
      function s(t) {
        var e;
        if (o.Browser.pointer ? (_.push(t.pointerId), e = _.length) : e = t.touches.length, !(e > 1)) {
          var i = Date.now(),
            n = i - (r || i);
          h = t.touches ? t.touches[0] : t, l = n > 0 && u >= n, r = i;
        }
      }
      function a(t) {
        if (o.Browser.pointer) {
          var e = _.indexOf(t.pointerId);
          if (-1 === e) return;
          _.splice(e, 1);
        }
        if (l) {
          if (o.Browser.pointer) {
            var n,
              s = {};
            for (var a in h) n = h[a], "function" == typeof n ? s[a] = n.bind(h) : s[a] = n;
            h = s;
          }
          h.type = "dblclick", i(h), r = null;
        }
      }
      var r,
        h,
        l = !1,
        u = 250,
        c = "_leaflet_",
        d = this._touchstart,
        p = this._touchend,
        _ = [];
      t[c + d + n] = s, t[c + p + n] = a;
      var m = o.Browser.pointer ? e.documentElement : t;
      return t.addEventListener(d, s, !1), m.addEventListener(p, a, !1), o.Browser.pointer && m.addEventListener(o.DomEvent.POINTER_CANCEL, a, !1), this;
    },
    removeDoubleTapListener: function (t, i) {
      var n = "_leaflet_";
      return t.removeEventListener(this._touchstart, t[n + this._touchstart + i], !1), (o.Browser.pointer ? e.documentElement : t).removeEventListener(this._touchend, t[n + this._touchend + i], !1), o.Browser.pointer && e.documentElement.removeEventListener(o.DomEvent.POINTER_CANCEL, t[n + this._touchend + i], !1), this;
    }
  }), o.extend(o.DomEvent, {
    POINTER_DOWN: o.Browser.msPointer ? "MSPointerDown" : "pointerdown",
    POINTER_MOVE: o.Browser.msPointer ? "MSPointerMove" : "pointermove",
    POINTER_UP: o.Browser.msPointer ? "MSPointerUp" : "pointerup",
    POINTER_CANCEL: o.Browser.msPointer ? "MSPointerCancel" : "pointercancel",
    _pointers: [],
    _pointerDocumentListener: !1,
    addPointerListener: function (t, e, i, n) {
      switch (e) {
        case "touchstart":
          return this.addPointerListenerStart(t, e, i, n);
        case "touchend":
          return this.addPointerListenerEnd(t, e, i, n);
        case "touchmove":
          return this.addPointerListenerMove(t, e, i, n);
        default:
          throw "Unknown touch event type";
      }
    },
    addPointerListenerStart: function (t, i, n, s) {
      var a = "_leaflet_",
        r = this._pointers,
        h = function (t) {
          "mouse" !== t.pointerType && t.pointerType !== t.MSPOINTER_TYPE_MOUSE && o.DomEvent.preventDefault(t);
          for (var e = !1, i = 0; i < r.length; i++) if (r[i].pointerId === t.pointerId) {
            e = !0;
            break;
          }
          e || r.push(t), t.touches = r.slice(), t.changedTouches = [t], n(t);
        };
      if (t[a + "touchstart" + s] = h, t.addEventListener(this.POINTER_DOWN, h, !1), !this._pointerDocumentListener) {
        var l = function (t) {
          for (var e = 0; e < r.length; e++) if (r[e].pointerId === t.pointerId) {
            r.splice(e, 1);
            break;
          }
        };
        e.documentElement.addEventListener(this.POINTER_UP, l, !1), e.documentElement.addEventListener(this.POINTER_CANCEL, l, !1), this._pointerDocumentListener = !0;
      }
      return this;
    },
    addPointerListenerMove: function (t, e, i, n) {
      function o(t) {
        if (t.pointerType !== t.MSPOINTER_TYPE_MOUSE && "mouse" !== t.pointerType || 0 !== t.buttons) {
          for (var e = 0; e < a.length; e++) if (a[e].pointerId === t.pointerId) {
            a[e] = t;
            break;
          }
          t.touches = a.slice(), t.changedTouches = [t], i(t);
        }
      }
      var s = "_leaflet_",
        a = this._pointers;
      return t[s + "touchmove" + n] = o, t.addEventListener(this.POINTER_MOVE, o, !1), this;
    },
    addPointerListenerEnd: function (t, e, i, n) {
      var o = "_leaflet_",
        s = this._pointers,
        a = function (t) {
          for (var e = 0; e < s.length; e++) if (s[e].pointerId === t.pointerId) {
            s.splice(e, 1);
            break;
          }
          t.touches = s.slice(), t.changedTouches = [t], i(t);
        };
      return t[o + "touchend" + n] = a, t.addEventListener(this.POINTER_UP, a, !1), t.addEventListener(this.POINTER_CANCEL, a, !1), this;
    },
    removePointerListener: function (t, e, i) {
      var n = "_leaflet_",
        o = t[n + e + i];
      switch (e) {
        case "touchstart":
          t.removeEventListener(this.POINTER_DOWN, o, !1);
          break;
        case "touchmove":
          t.removeEventListener(this.POINTER_MOVE, o, !1);
          break;
        case "touchend":
          t.removeEventListener(this.POINTER_UP, o, !1), t.removeEventListener(this.POINTER_CANCEL, o, !1);
      }
      return this;
    }
  }), o.Map.mergeOptions({
    touchZoom: o.Browser.touch && !o.Browser.android23,
    bounceAtZoomLimits: !0
  }), o.Map.TouchZoom = o.Handler.extend({
    addHooks: function () {
      o.DomEvent.on(this._map._container, "touchstart", this._onTouchStart, this);
    },
    removeHooks: function () {
      o.DomEvent.off(this._map._container, "touchstart", this._onTouchStart, this);
    },
    _onTouchStart: function (t) {
      var i = this._map;
      if (t.touches && 2 === t.touches.length && !i._animatingZoom && !this._zooming) {
        var n = i.mouseEventToLayerPoint(t.touches[0]),
          s = i.mouseEventToLayerPoint(t.touches[1]),
          a = i._getCenterLayerPoint();
        this._startCenter = n.add(s)._divideBy(2), this._startDist = n.distanceTo(s), this._moved = !1, this._zooming = !0, this._centerOffset = a.subtract(this._startCenter), i._panAnim && i._panAnim.stop(), o.DomEvent.on(e, "touchmove", this._onTouchMove, this).on(e, "touchend", this._onTouchEnd, this), o.DomEvent.preventDefault(t);
      }
    },
    _onTouchMove: function (t) {
      var e = this._map;
      if (t.touches && 2 === t.touches.length && this._zooming) {
        var i = e.mouseEventToLayerPoint(t.touches[0]),
          n = e.mouseEventToLayerPoint(t.touches[1]);
        this._scale = i.distanceTo(n) / this._startDist, this._delta = i._add(n)._divideBy(2)._subtract(this._startCenter), 1 !== this._scale && (e.options.bounceAtZoomLimits || !(e.getZoom() === e.getMinZoom() && this._scale < 1 || e.getZoom() === e.getMaxZoom() && this._scale > 1)) && (this._moved || (o.DomUtil.addClass(e._mapPane, "leaflet-touching"), e.fire("movestart").fire("zoomstart"), this._moved = !0), o.Util.cancelAnimFrame(this._animRequest), this._animRequest = o.Util.requestAnimFrame(this._updateOnMove, this, !0, this._map._container), o.DomEvent.preventDefault(t));
      }
    },
    _updateOnMove: function () {
      var t = this._map,
        e = this._getScaleOrigin(),
        i = t.layerPointToLatLng(e),
        n = t.getScaleZoom(this._scale);
      t._animateZoom(i, n, this._startCenter, this._scale, this._delta, !1, !0);
    },
    _onTouchEnd: function () {
      if (!this._moved || !this._zooming) return void (this._zooming = !1);
      var t = this._map;
      this._zooming = !1, o.DomUtil.removeClass(t._mapPane, "leaflet-touching"), o.Util.cancelAnimFrame(this._animRequest), o.DomEvent.off(e, "touchmove", this._onTouchMove).off(e, "touchend", this._onTouchEnd);
      var i = this._getScaleOrigin(),
        n = t.layerPointToLatLng(i),
        s = t.getZoom(),
        a = t.getScaleZoom(this._scale) - s,
        r = a > 0 ? Math.ceil(a) : Math.floor(a),
        h = t._limitZoom(s + r),
        l = t.getZoomScale(h) / this._scale;
      t._animateZoom(n, h, i, l);
    },
    _getScaleOrigin: function () {
      var t = this._centerOffset.subtract(this._delta).divideBy(this._scale);
      return this._startCenter.add(t);
    }
  }), o.Map.addInitHook("addHandler", "touchZoom", o.Map.TouchZoom), o.Map.mergeOptions({
    tap: !0,
    tapTolerance: 15
  }), o.Map.Tap = o.Handler.extend({
    addHooks: function () {
      o.DomEvent.on(this._map._container, "touchstart", this._onDown, this);
    },
    removeHooks: function () {
      o.DomEvent.off(this._map._container, "touchstart", this._onDown, this);
    },
    _onDown: function (t) {
      if (t.touches) {
        if (o.DomEvent.preventDefault(t), this._fireClick = !0, t.touches.length > 1) return this._fireClick = !1, void clearTimeout(this._holdTimeout);
        var i = t.touches[0],
          n = i.target;
        this._startPos = this._newPos = new o.Point(i.clientX, i.clientY), n.tagName && "a" === n.tagName.toLowerCase() && o.DomUtil.addClass(n, "leaflet-active"), this._holdTimeout = setTimeout(o.bind(function () {
          this._isTapValid() && (this._fireClick = !1, this._onUp(), this._simulateEvent("contextmenu", i));
        }, this), 1e3), o.DomEvent.on(e, "touchmove", this._onMove, this).on(e, "touchend", this._onUp, this);
      }
    },
    _onUp: function (t) {
      if (clearTimeout(this._holdTimeout), o.DomEvent.off(e, "touchmove", this._onMove, this).off(e, "touchend", this._onUp, this), this._fireClick && t && t.changedTouches) {
        var i = t.changedTouches[0],
          n = i.target;
        n && n.tagName && "a" === n.tagName.toLowerCase() && o.DomUtil.removeClass(n, "leaflet-active"), this._isTapValid() && this._simulateEvent("click", i);
      }
    },
    _isTapValid: function () {
      return this._newPos.distanceTo(this._startPos) <= this._map.options.tapTolerance;
    },
    _onMove: function (t) {
      var e = t.touches[0];
      this._newPos = new o.Point(e.clientX, e.clientY);
    },
    _simulateEvent: function (i, n) {
      var o = e.createEvent("MouseEvents");
      o._simulated = !0, n.target._simulatedClick = !0, o.initMouseEvent(i, !0, !0, t, 1, n.screenX, n.screenY, n.clientX, n.clientY, !1, !1, !1, !1, 0, null), n.target.dispatchEvent(o);
    }
  }), o.Browser.touch && !o.Browser.pointer && o.Map.addInitHook("addHandler", "tap", o.Map.Tap), o.Map.mergeOptions({
    boxZoom: !0
  }), o.Map.BoxZoom = o.Handler.extend({
    initialize: function (t) {
      this._map = t, this._container = t._container, this._pane = t._panes.overlayPane, this._moved = !1;
    },
    addHooks: function () {
      o.DomEvent.on(this._container, "mousedown", this._onMouseDown, this);
    },
    removeHooks: function () {
      o.DomEvent.off(this._container, "mousedown", this._onMouseDown), this._moved = !1;
    },
    moved: function () {
      return this._moved;
    },
    _onMouseDown: function (t) {
      return this._moved = !1, !t.shiftKey || 1 !== t.which && 1 !== t.button ? !1 : (o.DomUtil.disableTextSelection(), o.DomUtil.disableImageDrag(), this._startLayerPoint = this._map.mouseEventToLayerPoint(t), void o.DomEvent.on(e, "mousemove", this._onMouseMove, this).on(e, "mouseup", this._onMouseUp, this).on(e, "keydown", this._onKeyDown, this));
    },
    _onMouseMove: function (t) {
      this._moved || (this._box = o.DomUtil.create("div", "leaflet-zoom-box", this._pane), o.DomUtil.setPosition(this._box, this._startLayerPoint), this._container.style.cursor = "crosshair", this._map.fire("boxzoomstart"));
      var e = this._startLayerPoint,
        i = this._box,
        n = this._map.mouseEventToLayerPoint(t),
        s = n.subtract(e),
        a = new o.Point(Math.min(n.x, e.x), Math.min(n.y, e.y));
      o.DomUtil.setPosition(i, a), this._moved = !0, i.style.width = Math.max(0, Math.abs(s.x) - 4) + "px", i.style.height = Math.max(0, Math.abs(s.y) - 4) + "px";
    },
    _finish: function () {
      this._moved && (this._pane.removeChild(this._box), this._container.style.cursor = ""), o.DomUtil.enableTextSelection(), o.DomUtil.enableImageDrag(), o.DomEvent.off(e, "mousemove", this._onMouseMove).off(e, "mouseup", this._onMouseUp).off(e, "keydown", this._onKeyDown);
    },
    _onMouseUp: function (t) {
      this._finish();
      var e = this._map,
        i = e.mouseEventToLayerPoint(t);
      if (!this._startLayerPoint.equals(i)) {
        var n = new o.LatLngBounds(e.layerPointToLatLng(this._startLayerPoint), e.layerPointToLatLng(i));
        e.fitBounds(n), e.fire("boxzoomend", {
          boxZoomBounds: n
        });
      }
    },
    _onKeyDown: function (t) {
      27 === t.keyCode && this._finish();
    }
  }), o.Map.addInitHook("addHandler", "boxZoom", o.Map.BoxZoom), o.Map.mergeOptions({
    keyboard: !0,
    keyboardPanOffset: 80,
    keyboardZoomOffset: 1
  }), o.Map.Keyboard = o.Handler.extend({
    keyCodes: {
      left: [37],
      right: [39],
      down: [40],
      up: [38],
      zoomIn: [187, 107, 61, 171],
      zoomOut: [189, 109, 173]
    },
    initialize: function (t) {
      this._map = t, this._setPanOffset(t.options.keyboardPanOffset), this._setZoomOffset(t.options.keyboardZoomOffset);
    },
    addHooks: function () {
      var t = this._map._container;
      -1 === t.tabIndex && (t.tabIndex = "0"), o.DomEvent.on(t, "focus", this._onFocus, this).on(t, "blur", this._onBlur, this).on(t, "mousedown", this._onMouseDown, this), this._map.on("focus", this._addHooks, this).on("blur", this._removeHooks, this);
    },
    removeHooks: function () {
      this._removeHooks();
      var t = this._map._container;
      o.DomEvent.off(t, "focus", this._onFocus, this).off(t, "blur", this._onBlur, this).off(t, "mousedown", this._onMouseDown, this), this._map.off("focus", this._addHooks, this).off("blur", this._removeHooks, this);
    },
    _onMouseDown: function () {
      if (!this._focused) {
        var i = e.body,
          n = e.documentElement,
          o = i.scrollTop || n.scrollTop,
          s = i.scrollLeft || n.scrollLeft;
        this._map._container.focus(), t.scrollTo(s, o);
      }
    },
    _onFocus: function () {
      this._focused = !0, this._map.fire("focus");
    },
    _onBlur: function () {
      this._focused = !1, this._map.fire("blur");
    },
    _setPanOffset: function (t) {
      var e,
        i,
        n = this._panKeys = {},
        o = this.keyCodes;
      for (e = 0, i = o.left.length; i > e; e++) n[o.left[e]] = [-1 * t, 0];
      for (e = 0, i = o.right.length; i > e; e++) n[o.right[e]] = [t, 0];
      for (e = 0, i = o.down.length; i > e; e++) n[o.down[e]] = [0, t];
      for (e = 0, i = o.up.length; i > e; e++) n[o.up[e]] = [0, -1 * t];
    },
    _setZoomOffset: function (t) {
      var e,
        i,
        n = this._zoomKeys = {},
        o = this.keyCodes;
      for (e = 0, i = o.zoomIn.length; i > e; e++) n[o.zoomIn[e]] = t;
      for (e = 0, i = o.zoomOut.length; i > e; e++) n[o.zoomOut[e]] = -t;
    },
    _addHooks: function () {
      o.DomEvent.on(e, "keydown", this._onKeyDown, this);
    },
    _removeHooks: function () {
      o.DomEvent.off(e, "keydown", this._onKeyDown, this);
    },
    _onKeyDown: function (t) {
      var e = t.keyCode,
        i = this._map;
      if (e in this._panKeys) {
        if (i._panAnim && i._panAnim._inProgress) return;
        i.panBy(this._panKeys[e]), i.options.maxBounds && i.panInsideBounds(i.options.maxBounds);
      } else {
        if (!(e in this._zoomKeys)) return;
        i.setZoom(i.getZoom() + this._zoomKeys[e]);
      }
      o.DomEvent.stop(t);
    }
  }), o.Map.addInitHook("addHandler", "keyboard", o.Map.Keyboard), o.Handler.MarkerDrag = o.Handler.extend({
    initialize: function (t) {
      this._marker = t;
    },
    addHooks: function () {
      var t = this._marker._icon;
      this._draggable || (this._draggable = new o.Draggable(t, t)), this._draggable.on("dragstart", this._onDragStart, this).on("drag", this._onDrag, this).on("dragend", this._onDragEnd, this), this._draggable.enable(), o.DomUtil.addClass(this._marker._icon, "leaflet-marker-draggable");
    },
    removeHooks: function () {
      this._draggable.off("dragstart", this._onDragStart, this).off("drag", this._onDrag, this).off("dragend", this._onDragEnd, this), this._draggable.disable(), o.DomUtil.removeClass(this._marker._icon, "leaflet-marker-draggable");
    },
    moved: function () {
      return this._draggable && this._draggable._moved;
    },
    _onDragStart: function () {
      this._marker.closePopup().fire("movestart").fire("dragstart");
    },
    _onDrag: function () {
      var t = this._marker,
        e = t._shadow,
        i = o.DomUtil.getPosition(t._icon),
        n = t._map.layerPointToLatLng(i);
      e && o.DomUtil.setPosition(e, i), t._latlng = n, t.fire("move", {
        latlng: n
      }).fire("drag");
    },
    _onDragEnd: function (t) {
      this._marker.fire("moveend").fire("dragend", t);
    }
  }), o.Control = o.Class.extend({
    options: {
      position: "topright"
    },
    initialize: function (t) {
      o.setOptions(this, t);
    },
    getPosition: function () {
      return this.options.position;
    },
    setPosition: function (t) {
      var e = this._map;
      return e && e.removeControl(this), this.options.position = t, e && e.addControl(this), this;
    },
    getContainer: function () {
      return this._container;
    },
    addTo: function (t) {
      this._map = t;
      var e = this._container = this.onAdd(t),
        i = this.getPosition(),
        n = t._controlCorners[i];
      return o.DomUtil.addClass(e, "leaflet-control"), -1 !== i.indexOf("bottom") ? n.insertBefore(e, n.firstChild) : n.appendChild(e), this;
    },
    removeFrom: function (t) {
      var e = this.getPosition(),
        i = t._controlCorners[e];
      return i.removeChild(this._container), this._map = null, this.onRemove && this.onRemove(t), this;
    },
    _refocusOnMap: function () {
      this._map && this._map.getContainer().focus();
    }
  }), o.control = function (t) {
    return new o.Control(t);
  }, o.Map.include({
    addControl: function (t) {
      return t.addTo(this), this;
    },
    removeControl: function (t) {
      return t.removeFrom(this), this;
    },
    _initControlPos: function () {
      function t(t, s) {
        var a = i + t + " " + i + s;
        e[t + s] = o.DomUtil.create("div", a, n);
      }
      var e = this._controlCorners = {},
        i = "leaflet-",
        n = this._controlContainer = o.DomUtil.create("div", i + "control-container", this._container);
      t("top", "left"), t("top", "right"), t("bottom", "left"), t("bottom", "right");
    },
    _clearControlPos: function () {
      this._container.removeChild(this._controlContainer);
    }
  }), o.Control.Zoom = o.Control.extend({
    options: {
      position: "topleft",
      zoomInText: "+",
      zoomInTitle: "Zoom in",
      zoomOutText: "-",
      zoomOutTitle: "Zoom out"
    },
    onAdd: function (t) {
      var e = "leaflet-control-zoom",
        i = o.DomUtil.create("div", e + " leaflet-bar");
      return this._map = t, this._zoomInButton = this._createButton(this.options.zoomInText, this.options.zoomInTitle, e + "-in", i, this._zoomIn, this), this._zoomOutButton = this._createButton(this.options.zoomOutText, this.options.zoomOutTitle, e + "-out", i, this._zoomOut, this), this._updateDisabled(), t.on("zoomend zoomlevelschange", this._updateDisabled, this), i;
    },
    onRemove: function (t) {
      t.off("zoomend zoomlevelschange", this._updateDisabled, this);
    },
    _zoomIn: function (t) {
      this._map.zoomIn(t.shiftKey ? 3 : 1);
    },
    _zoomOut: function (t) {
      this._map.zoomOut(t.shiftKey ? 3 : 1);
    },
    _createButton: function (t, e, i, n, s, a) {
      var r = o.DomUtil.create("a", i, n);
      r.innerHTML = t, r.href = "#", r.title = e;
      var h = o.DomEvent.stopPropagation;
      return o.DomEvent.on(r, "click", h).on(r, "mousedown", h).on(r, "dblclick", h).on(r, "click", o.DomEvent.preventDefault).on(r, "click", s, a).on(r, "click", this._refocusOnMap, a), r;
    },
    _updateDisabled: function () {
      var t = this._map,
        e = "leaflet-disabled";
      o.DomUtil.removeClass(this._zoomInButton, e), o.DomUtil.removeClass(this._zoomOutButton, e), t._zoom === t.getMinZoom() && o.DomUtil.addClass(this._zoomOutButton, e), t._zoom === t.getMaxZoom() && o.DomUtil.addClass(this._zoomInButton, e);
    }
  }), o.Map.mergeOptions({
    zoomControl: !0
  }), o.Map.addInitHook(function () {
    this.options.zoomControl && (this.zoomControl = new o.Control.Zoom(), this.addControl(this.zoomControl));
  }), o.control.zoom = function (t) {
    return new o.Control.Zoom(t);
  }, o.Control.Attribution = o.Control.extend({
    options: {
      position: "bottomright",
      prefix: '<a href="http://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>'
    },
    initialize: function (t) {
      o.setOptions(this, t), this._attributions = {};
    },
    onAdd: function (t) {
      this._container = o.DomUtil.create("div", "leaflet-control-attribution"), o.DomEvent.disableClickPropagation(this._container);
      for (var e in t._layers) t._layers[e].getAttribution && this.addAttribution(t._layers[e].getAttribution());
      return t.on("layeradd", this._onLayerAdd, this).on("layerremove", this._onLayerRemove, this), this._update(), this._container;
    },
    onRemove: function (t) {
      t.off("layeradd", this._onLayerAdd).off("layerremove", this._onLayerRemove);
    },
    setPrefix: function (t) {
      return this.options.prefix = t, this._update(), this;
    },
    addAttribution: function (t) {
      return t ? (this._attributions[t] || (this._attributions[t] = 0), this._attributions[t]++, this._update(), this) : void 0;
    },
    removeAttribution: function (t) {
      return t ? (this._attributions[t] && (this._attributions[t]--, this._update()), this) : void 0;
    },
    _update: function () {
      if (this._map) {
        var t = [];
        for (var e in this._attributions) this._attributions[e] && t.push(e);
        var i = [];
        this.options.prefix && i.push(this.options.prefix), t.length && i.push(t.join(", ")), this._container.innerHTML = i.join(" | ");
      }
    },
    _onLayerAdd: function (t) {
      t.layer.getAttribution && this.addAttribution(t.layer.getAttribution());
    },
    _onLayerRemove: function (t) {
      t.layer.getAttribution && this.removeAttribution(t.layer.getAttribution());
    }
  }), o.Map.mergeOptions({
    attributionControl: !0
  }), o.Map.addInitHook(function () {
    this.options.attributionControl && (this.attributionControl = new o.Control.Attribution().addTo(this));
  }), o.control.attribution = function (t) {
    return new o.Control.Attribution(t);
  }, o.Control.Scale = o.Control.extend({
    options: {
      position: "bottomleft",
      maxWidth: 100,
      metric: !0,
      imperial: !0,
      updateWhenIdle: !1
    },
    onAdd: function (t) {
      this._map = t;
      var e = "leaflet-control-scale",
        i = o.DomUtil.create("div", e),
        n = this.options;
      return this._addScales(n, e, i), t.on(n.updateWhenIdle ? "moveend" : "move", this._update, this), t.whenReady(this._update, this), i;
    },
    onRemove: function (t) {
      t.off(this.options.updateWhenIdle ? "moveend" : "move", this._update, this);
    },
    _addScales: function (t, e, i) {
      t.metric && (this._mScale = o.DomUtil.create("div", e + "-line", i)), t.imperial && (this._iScale = o.DomUtil.create("div", e + "-line", i));
    },
    _update: function () {
      var t = this._map.getBounds(),
        e = t.getCenter().lat,
        i = 6378137 * Math.PI * Math.cos(e * Math.PI / 180),
        n = i * (t.getNorthEast().lng - t.getSouthWest().lng) / 180,
        o = this._map.getSize(),
        s = this.options,
        a = 0;
      o.x > 0 && (a = n * (s.maxWidth / o.x)), this._updateScales(s, a);
    },
    _updateScales: function (t, e) {
      t.metric && e && this._updateMetric(e), t.imperial && e && this._updateImperial(e);
    },
    _updateMetric: function (t) {
      var e = this._getRoundNum(t);
      this._mScale.style.width = this._getScaleWidth(e / t) + "px", this._mScale.innerHTML = 1e3 > e ? e + " m" : e / 1e3 + " km";
    },
    _updateImperial: function (t) {
      var e,
        i,
        n,
        o = 3.2808399 * t,
        s = this._iScale;
      o > 5280 ? (e = o / 5280, i = this._getRoundNum(e), s.style.width = this._getScaleWidth(i / e) + "px", s.innerHTML = i + " mi") : (n = this._getRoundNum(o), s.style.width = this._getScaleWidth(n / o) + "px", s.innerHTML = n + " ft");
    },
    _getScaleWidth: function (t) {
      return Math.round(this.options.maxWidth * t) - 10;
    },
    _getRoundNum: function (t) {
      var e = Math.pow(10, (Math.floor(t) + "").length - 1),
        i = t / e;
      return i = i >= 10 ? 10 : i >= 5 ? 5 : i >= 3 ? 3 : i >= 2 ? 2 : 1, e * i;
    }
  }), o.control.scale = function (t) {
    return new o.Control.Scale(t);
  }, o.Control.Layers = o.Control.extend({
    options: {
      collapsed: !0,
      position: "topright",
      autoZIndex: !0
    },
    initialize: function (t, e, i) {
      o.setOptions(this, i), this._layers = {}, this._lastZIndex = 0, this._handlingClick = !1;
      for (var n in t) this._addLayer(t[n], n);
      for (n in e) this._addLayer(e[n], n, !0);
    },
    onAdd: function (t) {
      return this._initLayout(), this._update(), t.on("layeradd", this._onLayerChange, this).on("layerremove", this._onLayerChange, this), this._container;
    },
    onRemove: function (t) {
      t.off("layeradd", this._onLayerChange, this).off("layerremove", this._onLayerChange, this);
    },
    addBaseLayer: function (t, e) {
      return this._addLayer(t, e), this._update(), this;
    },
    addOverlay: function (t, e) {
      return this._addLayer(t, e, !0), this._update(), this;
    },
    removeLayer: function (t) {
      var e = o.stamp(t);
      return delete this._layers[e], this._update(), this;
    },
    _initLayout: function () {
      var t = "leaflet-control-layers",
        e = this._container = o.DomUtil.create("div", t);
      e.setAttribute("aria-haspopup", !0), o.Browser.touch ? o.DomEvent.on(e, "click", o.DomEvent.stopPropagation) : o.DomEvent.disableClickPropagation(e).disableScrollPropagation(e);
      var i = this._form = o.DomUtil.create("form", t + "-list");
      if (this.options.collapsed) {
        o.Browser.android || o.DomEvent.on(e, "mouseover", this._expand, this).on(e, "mouseout", this._collapse, this);
        var n = this._layersLink = o.DomUtil.create("a", t + "-toggle", e);
        n.href = "#", n.title = "Layers", o.Browser.touch ? o.DomEvent.on(n, "click", o.DomEvent.stop).on(n, "click", this._expand, this) : o.DomEvent.on(n, "focus", this._expand, this), o.DomEvent.on(i, "click", function () {
          setTimeout(o.bind(this._onInputClick, this), 0);
        }, this), this._map.on("click", this._collapse, this);
      } else this._expand();
      this._baseLayersList = o.DomUtil.create("div", t + "-base", i), this._separator = o.DomUtil.create("div", t + "-separator", i), this._overlaysList = o.DomUtil.create("div", t + "-overlays", i), e.appendChild(i);
    },
    _addLayer: function (t, e, i) {
      var n = o.stamp(t);
      this._layers[n] = {
        layer: t,
        name: e,
        overlay: i
      }, this.options.autoZIndex && t.setZIndex && (this._lastZIndex++, t.setZIndex(this._lastZIndex));
    },
    _update: function () {
      if (this._container) {
        this._baseLayersList.innerHTML = "", this._overlaysList.innerHTML = "";
        var t,
          e,
          i = !1,
          n = !1;
        for (t in this._layers) e = this._layers[t], this._addItem(e), n = n || e.overlay, i = i || !e.overlay;
        this._separator.style.display = n && i ? "" : "none";
      }
    },
    _onLayerChange: function (t) {
      var e = this._layers[o.stamp(t.layer)];
      if (e) {
        this._handlingClick || this._update();
        var i = e.overlay ? "layeradd" === t.type ? "overlayadd" : "overlayremove" : "layeradd" === t.type ? "baselayerchange" : null;
        i && this._map.fire(i, e);
      }
    },
    _createRadioElement: function (t, i) {
      var n = '<input type="radio" class="leaflet-control-layers-selector" name="' + t + '"';
      i && (n += ' checked="checked"'), n += "/>";
      var o = e.createElement("div");
      return o.innerHTML = n, o.firstChild;
    },
    _addItem: function (t) {
      var i,
        n = e.createElement("label"),
        s = this._map.hasLayer(t.layer);
      t.overlay ? (i = e.createElement("input"), i.type = "checkbox", i.className = "leaflet-control-layers-selector", i.defaultChecked = s) : i = this._createRadioElement("leaflet-base-layers", s), i.layerId = o.stamp(t.layer), o.DomEvent.on(i, "click", this._onInputClick, this);
      var a = e.createElement("span");
      a.innerHTML = " " + t.name, n.appendChild(i), n.appendChild(a);
      var r = t.overlay ? this._overlaysList : this._baseLayersList;
      return r.appendChild(n), n;
    },
    _onInputClick: function () {
      var t,
        e,
        i,
        n = this._form.getElementsByTagName("input"),
        o = n.length;
      for (this._handlingClick = !0, t = 0; o > t; t++) e = n[t], i = this._layers[e.layerId], e.checked && !this._map.hasLayer(i.layer) ? this._map.addLayer(i.layer) : !e.checked && this._map.hasLayer(i.layer) && this._map.removeLayer(i.layer);
      this._handlingClick = !1, this._refocusOnMap();
    },
    _expand: function () {
      o.DomUtil.addClass(this._container, "leaflet-control-layers-expanded");
    },
    _collapse: function () {
      this._container.className = this._container.className.replace(" leaflet-control-layers-expanded", "");
    }
  }), o.control.layers = function (t, e, i) {
    return new o.Control.Layers(t, e, i);
  }, o.PosAnimation = o.Class.extend({
    includes: o.Mixin.Events,
    run: function (t, e, i, n) {
      this.stop(), this._el = t, this._inProgress = !0, this._newPos = e, this.fire("start"), t.style[o.DomUtil.TRANSITION] = "all " + (i || .25) + "s cubic-bezier(0,0," + (n || .5) + ",1)", o.DomEvent.on(t, o.DomUtil.TRANSITION_END, this._onTransitionEnd, this), o.DomUtil.setPosition(t, e), o.Util.falseFn(t.offsetWidth), this._stepTimer = setInterval(o.bind(this._onStep, this), 50);
    },
    stop: function () {
      this._inProgress && (o.DomUtil.setPosition(this._el, this._getPos()), this._onTransitionEnd(), o.Util.falseFn(this._el.offsetWidth));
    },
    _onStep: function () {
      var t = this._getPos();
      return t ? (this._el._leaflet_pos = t, void this.fire("step")) : void this._onTransitionEnd();
    },
    _transformRe: /([-+]?(?:\d*\.)?\d+)\D*, ([-+]?(?:\d*\.)?\d+)\D*\)/,
    _getPos: function () {
      var e,
        i,
        n,
        s = this._el,
        a = t.getComputedStyle(s);
      if (o.Browser.any3d) {
        if (n = a[o.DomUtil.TRANSFORM].match(this._transformRe), !n) return;
        e = parseFloat(n[1]), i = parseFloat(n[2]);
      } else e = parseFloat(a.left), i = parseFloat(a.top);
      return new o.Point(e, i, !0);
    },
    _onTransitionEnd: function () {
      o.DomEvent.off(this._el, o.DomUtil.TRANSITION_END, this._onTransitionEnd, this), this._inProgress && (this._inProgress = !1, this._el.style[o.DomUtil.TRANSITION] = "", this._el._leaflet_pos = this._newPos, clearInterval(this._stepTimer), this.fire("step").fire("end"));
    }
  }), o.Map.include({
    setView: function (t, e, n) {
      if (e = e === i ? this._zoom : this._limitZoom(e), t = this._limitCenter(o.latLng(t), e, this.options.maxBounds), n = n || {}, this._panAnim && this._panAnim.stop(), this._loaded && !n.reset && n !== !0) {
        n.animate !== i && (n.zoom = o.extend({
          animate: n.animate
        }, n.zoom), n.pan = o.extend({
          animate: n.animate
        }, n.pan));
        var s = this._zoom !== e ? this._tryAnimatedZoom && this._tryAnimatedZoom(t, e, n.zoom) : this._tryAnimatedPan(t, n.pan);
        if (s) return clearTimeout(this._sizeTimer), this;
      }
      return this._resetView(t, e), this;
    },
    panBy: function (t, e) {
      if (t = o.point(t).round(), e = e || {}, !t.x && !t.y) return this;
      if (this._panAnim || (this._panAnim = new o.PosAnimation(), this._panAnim.on({
        step: this._onPanTransitionStep,
        end: this._onPanTransitionEnd
      }, this)), e.noMoveStart || this.fire("movestart"), e.animate !== !1) {
        o.DomUtil.addClass(this._mapPane, "leaflet-pan-anim");
        var i = this._getMapPanePos().subtract(t);
        this._panAnim.run(this._mapPane, i, e.duration || .25, e.easeLinearity);
      } else this._rawPanBy(t), this.fire("move").fire("moveend");
      return this;
    },
    _onPanTransitionStep: function () {
      this.fire("move");
    },
    _onPanTransitionEnd: function () {
      o.DomUtil.removeClass(this._mapPane, "leaflet-pan-anim"), this.fire("moveend");
    },
    _tryAnimatedPan: function (t, e) {
      var i = this._getCenterOffset(t)._floor();
      return (e && e.animate) === !0 || this.getSize().contains(i) ? (this.panBy(i, e), !0) : !1;
    }
  }), o.PosAnimation = o.DomUtil.TRANSITION ? o.PosAnimation : o.PosAnimation.extend({
    run: function (t, e, i, n) {
      this.stop(), this._el = t, this._inProgress = !0, this._duration = i || .25, this._easeOutPower = 1 / Math.max(n || .5, .2), this._startPos = o.DomUtil.getPosition(t), this._offset = e.subtract(this._startPos), this._startTime = +new Date(), this.fire("start"), this._animate();
    },
    stop: function () {
      this._inProgress && (this._step(), this._complete());
    },
    _animate: function () {
      this._animId = o.Util.requestAnimFrame(this._animate, this), this._step();
    },
    _step: function () {
      var t = +new Date() - this._startTime,
        e = 1e3 * this._duration;
      e > t ? this._runFrame(this._easeOut(t / e)) : (this._runFrame(1), this._complete());
    },
    _runFrame: function (t) {
      var e = this._startPos.add(this._offset.multiplyBy(t));
      o.DomUtil.setPosition(this._el, e), this.fire("step");
    },
    _complete: function () {
      o.Util.cancelAnimFrame(this._animId), this._inProgress = !1, this.fire("end");
    },
    _easeOut: function (t) {
      return 1 - Math.pow(1 - t, this._easeOutPower);
    }
  }), o.Map.mergeOptions({
    zoomAnimation: !0,
    zoomAnimationThreshold: 4
  }), o.DomUtil.TRANSITION && o.Map.addInitHook(function () {
    this._zoomAnimated = this.options.zoomAnimation && o.DomUtil.TRANSITION && o.Browser.any3d && !o.Browser.android23 && !o.Browser.mobileOpera, this._zoomAnimated && o.DomEvent.on(this._mapPane, o.DomUtil.TRANSITION_END, this._catchTransitionEnd, this);
  }), o.Map.include(o.DomUtil.TRANSITION ? {
    _catchTransitionEnd: function (t) {
      this._animatingZoom && t.propertyName.indexOf("transform") >= 0 && this._onZoomTransitionEnd();
    },
    _nothingToAnimate: function () {
      return !this._container.getElementsByClassName("leaflet-zoom-animated").length;
    },
    _tryAnimatedZoom: function (t, e, i) {
      if (this._animatingZoom) return !0;
      if (i = i || {}, !this._zoomAnimated || i.animate === !1 || this._nothingToAnimate() || Math.abs(e - this._zoom) > this.options.zoomAnimationThreshold) return !1;
      var n = this.getZoomScale(e),
        o = this._getCenterOffset(t)._divideBy(1 - 1 / n),
        s = this._getCenterLayerPoint()._add(o);
      return i.animate === !0 || this.getSize().contains(o) ? (this.fire("movestart").fire("zoomstart"), this._animateZoom(t, e, s, n, null, !0), !0) : !1;
    },
    _animateZoom: function (t, e, i, n, s, a, r) {
      r || (this._animatingZoom = !0), o.DomUtil.addClass(this._mapPane, "leaflet-zoom-anim"), this._animateToCenter = t, this._animateToZoom = e, o.Draggable && (o.Draggable._disabled = !0), o.Util.requestAnimFrame(function () {
        this.fire("zoomanim", {
          center: t,
          zoom: e,
          origin: i,
          scale: n,
          delta: s,
          backwards: a
        }), setTimeout(o.bind(this._onZoomTransitionEnd, this), 250);
      }, this);
    },
    _onZoomTransitionEnd: function () {
      this._animatingZoom && (this._animatingZoom = !1, o.DomUtil.removeClass(this._mapPane, "leaflet-zoom-anim"), o.Util.requestAnimFrame(function () {
        this._resetView(this._animateToCenter, this._animateToZoom, !0, !0), o.Draggable && (o.Draggable._disabled = !1);
      }, this));
    }
  } : {}), o.TileLayer.include({
    _animateZoom: function (t) {
      this._animating || (this._animating = !0, this._prepareBgBuffer());
      var e = this._bgBuffer,
        i = o.DomUtil.TRANSFORM,
        n = t.delta ? o.DomUtil.getTranslateString(t.delta) : e.style[i],
        s = o.DomUtil.getScaleString(t.scale, t.origin);
      e.style[i] = t.backwards ? s + " " + n : n + " " + s;
    },
    _endZoomAnim: function () {
      var t = this._tileContainer,
        e = this._bgBuffer;
      t.style.visibility = "", t.parentNode.appendChild(t), o.Util.falseFn(e.offsetWidth);
      var i = this._map.getZoom();
      (i > this.options.maxZoom || i < this.options.minZoom) && this._clearBgBuffer(), this._animating = !1;
    },
    _clearBgBuffer: function () {
      var t = this._map;
      !t || t._animatingZoom || t.touchZoom._zooming || (this._bgBuffer.innerHTML = "", this._bgBuffer.style[o.DomUtil.TRANSFORM] = "");
    },
    _prepareBgBuffer: function () {
      var t = this._tileContainer,
        e = this._bgBuffer,
        i = this._getLoadedTilesPercentage(e),
        n = this._getLoadedTilesPercentage(t);
      return e && i > .5 && .5 > n ? (t.style.visibility = "hidden", void this._stopLoadingImages(t)) : (e.style.visibility = "hidden", e.style[o.DomUtil.TRANSFORM] = "", this._tileContainer = e, e = this._bgBuffer = t, this._stopLoadingImages(e), void clearTimeout(this._clearBgBufferTimer));
    },
    _getLoadedTilesPercentage: function (t) {
      var e,
        i,
        n = t.getElementsByTagName("img"),
        o = 0;
      for (e = 0, i = n.length; i > e; e++) n[e].complete && o++;
      return o / i;
    },
    _stopLoadingImages: function (t) {
      var e,
        i,
        n,
        s = Array.prototype.slice.call(t.getElementsByTagName("img"));
      for (e = 0, i = s.length; i > e; e++) n = s[e], n.complete || (n.onload = o.Util.falseFn, n.onerror = o.Util.falseFn, n.src = o.Util.emptyImageUrl, n.parentNode.removeChild(n));
    }
  }), o.Map.include({
    _defaultLocateOptions: {
      watch: !1,
      setView: !1,
      maxZoom: 1 / 0,
      timeout: 1e4,
      maximumAge: 0,
      enableHighAccuracy: !1
    },
    locate: function (t) {
      if (t = this._locateOptions = o.extend(this._defaultLocateOptions, t), !navigator.geolocation) return this._handleGeolocationError({
        code: 0,
        message: "Geolocation not supported."
      }), this;
      var e = o.bind(this._handleGeolocationResponse, this),
        i = o.bind(this._handleGeolocationError, this);
      return t.watch ? this._locationWatchId = navigator.geolocation.watchPosition(e, i, t) : navigator.geolocation.getCurrentPosition(e, i, t), this;
    },
    stopLocate: function () {
      return navigator.geolocation && navigator.geolocation.clearWatch(this._locationWatchId), this._locateOptions && (this._locateOptions.setView = !1), this;
    },
    _handleGeolocationError: function (t) {
      var e = t.code,
        i = t.message || (1 === e ? "permission denied" : 2 === e ? "position unavailable" : "timeout");
      this._locateOptions.setView && !this._loaded && this.fitWorld(), this.fire("locationerror", {
        code: e,
        message: "Geolocation error: " + i + "."
      });
    },
    _handleGeolocationResponse: function (t) {
      var e = t.coords.latitude,
        i = t.coords.longitude,
        n = new o.LatLng(e, i),
        s = 180 * t.coords.accuracy / 40075017,
        a = s / Math.cos(o.LatLng.DEG_TO_RAD * e),
        r = o.latLngBounds([e - s, i - a], [e + s, i + a]),
        h = this._locateOptions;
      if (h.setView) {
        var l = Math.min(this.getBoundsZoom(r), h.maxZoom);
        this.setView(n, l);
      }
      var u = {
        latlng: n,
        bounds: r,
        timestamp: t.timestamp
      };
      for (var c in t.coords) "number" == typeof t.coords[c] && (u[c] = t.coords[c]);
      this.fire("locationfound", u);
    }
  });
}(window, document);
/*! jQuery v3.3.1 | (c) JS Foundation and other contributors | jquery.org/license */
!function (e, t) {
  "use strict";

  "object" == typeof module && "object" == typeof module.exports ? module.exports = e.document ? t(e, !0) : function (e) {
    if (!e.document) throw new Error("jQuery requires a window with a document");
    return t(e);
  } : t(e);
}("undefined" != typeof window ? window : this, function (e, t) {
  "use strict";

  var n = [],
    r = e.document,
    i = Object.getPrototypeOf,
    o = n.slice,
    a = n.concat,
    s = n.push,
    u = n.indexOf,
    l = {},
    c = l.toString,
    f = l.hasOwnProperty,
    p = f.toString,
    d = p.call(Object),
    h = {},
    g = function e(t) {
      return "function" == typeof t && "number" != typeof t.nodeType;
    },
    y = function e(t) {
      return null != t && t === t.window;
    },
    v = {
      type: !0,
      src: !0,
      noModule: !0
    };
  function m(e, t, n) {
    var i,
      o = (t = t || r).createElement("script");
    if (o.text = e, n) for (i in v) n[i] && (o[i] = n[i]);
    t.head.appendChild(o).parentNode.removeChild(o);
  }
  function x(e) {
    return null == e ? e + "" : "object" == typeof e || "function" == typeof e ? l[c.call(e)] || "object" : typeof e;
  }
  var b = "3.3.1",
    w = function (e, t) {
      return new w.fn.init(e, t);
    },
    T = /^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g;
  w.fn = w.prototype = {
    jquery: "3.3.1",
    constructor: w,
    length: 0,
    toArray: function () {
      return o.call(this);
    },
    get: function (e) {
      return null == e ? o.call(this) : e < 0 ? this[e + this.length] : this[e];
    },
    pushStack: function (e) {
      var t = w.merge(this.constructor(), e);
      return t.prevObject = this, t;
    },
    each: function (e) {
      return w.each(this, e);
    },
    map: function (e) {
      return this.pushStack(w.map(this, function (t, n) {
        return e.call(t, n, t);
      }));
    },
    slice: function () {
      return this.pushStack(o.apply(this, arguments));
    },
    first: function () {
      return this.eq(0);
    },
    last: function () {
      return this.eq(-1);
    },
    eq: function (e) {
      var t = this.length,
        n = +e + (e < 0 ? t : 0);
      return this.pushStack(n >= 0 && n < t ? [this[n]] : []);
    },
    end: function () {
      return this.prevObject || this.constructor();
    },
    push: s,
    sort: n.sort,
    splice: n.splice
  }, w.extend = w.fn.extend = function () {
    var e,
      t,
      n,
      r,
      i,
      o,
      a = arguments[0] || {},
      s = 1,
      u = arguments.length,
      l = !1;
    for ("boolean" == typeof a && (l = a, a = arguments[s] || {}, s++), "object" == typeof a || g(a) || (a = {}), s === u && (a = this, s--); s < u; s++) if (null != (e = arguments[s])) for (t in e) n = a[t], a !== (r = e[t]) && (l && r && (w.isPlainObject(r) || (i = Array.isArray(r))) ? (i ? (i = !1, o = n && Array.isArray(n) ? n : []) : o = n && w.isPlainObject(n) ? n : {}, a[t] = w.extend(l, o, r)) : void 0 !== r && (a[t] = r));
    return a;
  }, w.extend({
    expando: "jQuery" + ("3.3.1" + Math.random()).replace(/\D/g, ""),
    isReady: !0,
    error: function (e) {
      throw new Error(e);
    },
    noop: function () {},
    isPlainObject: function (e) {
      var t, n;
      return !(!e || "[object Object]" !== c.call(e)) && (!(t = i(e)) || "function" == typeof (n = f.call(t, "constructor") && t.constructor) && p.call(n) === d);
    },
    isEmptyObject: function (e) {
      var t;
      for (t in e) return !1;
      return !0;
    },
    globalEval: function (e) {
      m(e);
    },
    each: function (e, t) {
      var n,
        r = 0;
      if (C(e)) {
        for (n = e.length; r < n; r++) if (!1 === t.call(e[r], r, e[r])) break;
      } else for (r in e) if (!1 === t.call(e[r], r, e[r])) break;
      return e;
    },
    trim: function (e) {
      return null == e ? "" : (e + "").replace(T, "");
    },
    makeArray: function (e, t) {
      var n = t || [];
      return null != e && (C(Object(e)) ? w.merge(n, "string" == typeof e ? [e] : e) : s.call(n, e)), n;
    },
    inArray: function (e, t, n) {
      return null == t ? -1 : u.call(t, e, n);
    },
    merge: function (e, t) {
      for (var n = +t.length, r = 0, i = e.length; r < n; r++) e[i++] = t[r];
      return e.length = i, e;
    },
    grep: function (e, t, n) {
      for (var r, i = [], o = 0, a = e.length, s = !n; o < a; o++) (r = !t(e[o], o)) !== s && i.push(e[o]);
      return i;
    },
    map: function (e, t, n) {
      var r,
        i,
        o = 0,
        s = [];
      if (C(e)) for (r = e.length; o < r; o++) null != (i = t(e[o], o, n)) && s.push(i);else for (o in e) null != (i = t(e[o], o, n)) && s.push(i);
      return a.apply([], s);
    },
    guid: 1,
    support: h
  }), "function" == typeof Symbol && (w.fn[Symbol.iterator] = n[Symbol.iterator]), w.each("Boolean Number String Function Array Date RegExp Object Error Symbol".split(" "), function (e, t) {
    l["[object " + t + "]"] = t.toLowerCase();
  });
  function C(e) {
    var t = !!e && "length" in e && e.length,
      n = x(e);
    return !g(e) && !y(e) && ("array" === n || 0 === t || "number" == typeof t && t > 0 && t - 1 in e);
  }
  var E = function (e) {
    var t,
      n,
      r,
      i,
      o,
      a,
      s,
      u,
      l,
      c,
      f,
      p,
      d,
      h,
      g,
      y,
      v,
      m,
      x,
      b = "sizzle" + 1 * new Date(),
      w = e.document,
      T = 0,
      C = 0,
      E = ae(),
      k = ae(),
      S = ae(),
      D = function (e, t) {
        return e === t && (f = !0), 0;
      },
      N = {}.hasOwnProperty,
      A = [],
      j = A.pop,
      q = A.push,
      L = A.push,
      H = A.slice,
      O = function (e, t) {
        for (var n = 0, r = e.length; n < r; n++) if (e[n] === t) return n;
        return -1;
      },
      P = "checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped",
      M = "[\\x20\\t\\r\\n\\f]",
      R = "(?:\\\\.|[\\w-]|[^\0-\\xa0])+",
      I = "\\[" + M + "*(" + R + ")(?:" + M + "*([*^$|!~]?=)" + M + "*(?:'((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\"|(" + R + "))|)" + M + "*\\]",
      W = ":(" + R + ")(?:\\((('((?:\\\\.|[^\\\\'])*)'|\"((?:\\\\.|[^\\\\\"])*)\")|((?:\\\\.|[^\\\\()[\\]]|" + I + ")*)|.*)\\)|)",
      $ = new RegExp(M + "+", "g"),
      B = new RegExp("^" + M + "+|((?:^|[^\\\\])(?:\\\\.)*)" + M + "+$", "g"),
      F = new RegExp("^" + M + "*," + M + "*"),
      _ = new RegExp("^" + M + "*([>+~]|" + M + ")" + M + "*"),
      z = new RegExp("=" + M + "*([^\\]'\"]*?)" + M + "*\\]", "g"),
      X = new RegExp(W),
      U = new RegExp("^" + R + "$"),
      V = {
        ID: new RegExp("^#(" + R + ")"),
        CLASS: new RegExp("^\\.(" + R + ")"),
        TAG: new RegExp("^(" + R + "|[*])"),
        ATTR: new RegExp("^" + I),
        PSEUDO: new RegExp("^" + W),
        CHILD: new RegExp("^:(only|first|last|nth|nth-last)-(child|of-type)(?:\\(" + M + "*(even|odd|(([+-]|)(\\d*)n|)" + M + "*(?:([+-]|)" + M + "*(\\d+)|))" + M + "*\\)|)", "i"),
        bool: new RegExp("^(?:" + P + ")$", "i"),
        needsContext: new RegExp("^" + M + "*[>+~]|:(even|odd|eq|gt|lt|nth|first|last)(?:\\(" + M + "*((?:-\\d)?\\d*)" + M + "*\\)|)(?=[^-]|$)", "i")
      },
      G = /^(?:input|select|textarea|button)$/i,
      Y = /^h\d$/i,
      Q = /^[^{]+\{\s*\[native \w/,
      J = /^(?:#([\w-]+)|(\w+)|\.([\w-]+))$/,
      K = /[+~]/,
      Z = new RegExp("\\\\([\\da-f]{1,6}" + M + "?|(" + M + ")|.)", "ig"),
      ee = function (e, t, n) {
        var r = "0x" + t - 65536;
        return r !== r || n ? t : r < 0 ? String.fromCharCode(r + 65536) : String.fromCharCode(r >> 10 | 55296, 1023 & r | 56320);
      },
      te = /([\0-\x1f\x7f]|^-?\d)|^-$|[^\0-\x1f\x7f-\uFFFF\w-]/g,
      ne = function (e, t) {
        return t ? "\0" === e ? "\ufffd" : e.slice(0, -1) + "\\" + e.charCodeAt(e.length - 1).toString(16) + " " : "\\" + e;
      },
      re = function () {
        p();
      },
      ie = me(function (e) {
        return !0 === e.disabled && ("form" in e || "label" in e);
      }, {
        dir: "parentNode",
        next: "legend"
      });
    try {
      L.apply(A = H.call(w.childNodes), w.childNodes), A[w.childNodes.length].nodeType;
    } catch (e) {
      L = {
        apply: A.length ? function (e, t) {
          q.apply(e, H.call(t));
        } : function (e, t) {
          var n = e.length,
            r = 0;
          while (e[n++] = t[r++]);
          e.length = n - 1;
        }
      };
    }
    function oe(e, t, r, i) {
      var o,
        s,
        l,
        c,
        f,
        h,
        v,
        m = t && t.ownerDocument,
        T = t ? t.nodeType : 9;
      if (r = r || [], "string" != typeof e || !e || 1 !== T && 9 !== T && 11 !== T) return r;
      if (!i && ((t ? t.ownerDocument || t : w) !== d && p(t), t = t || d, g)) {
        if (11 !== T && (f = J.exec(e))) if (o = f[1]) {
          if (9 === T) {
            if (!(l = t.getElementById(o))) return r;
            if (l.id === o) return r.push(l), r;
          } else if (m && (l = m.getElementById(o)) && x(t, l) && l.id === o) return r.push(l), r;
        } else {
          if (f[2]) return L.apply(r, t.getElementsByTagName(e)), r;
          if ((o = f[3]) && n.getElementsByClassName && t.getElementsByClassName) return L.apply(r, t.getElementsByClassName(o)), r;
        }
        if (n.qsa && !S[e + " "] && (!y || !y.test(e))) {
          if (1 !== T) m = t, v = e;else if ("object" !== t.nodeName.toLowerCase()) {
            (c = t.getAttribute("id")) ? c = c.replace(te, ne) : t.setAttribute("id", c = b), s = (h = a(e)).length;
            while (s--) h[s] = "#" + c + " " + ve(h[s]);
            v = h.join(","), m = K.test(e) && ge(t.parentNode) || t;
          }
          if (v) try {
            return L.apply(r, m.querySelectorAll(v)), r;
          } catch (e) {} finally {
            c === b && t.removeAttribute("id");
          }
        }
      }
      return u(e.replace(B, "$1"), t, r, i);
    }
    function ae() {
      var e = [];
      function t(n, i) {
        return e.push(n + " ") > r.cacheLength && delete t[e.shift()], t[n + " "] = i;
      }
      return t;
    }
    function se(e) {
      return e[b] = !0, e;
    }
    function ue(e) {
      var t = d.createElement("fieldset");
      try {
        return !!e(t);
      } catch (e) {
        return !1;
      } finally {
        t.parentNode && t.parentNode.removeChild(t), t = null;
      }
    }
    function le(e, t) {
      var n = e.split("|"),
        i = n.length;
      while (i--) r.attrHandle[n[i]] = t;
    }
    function ce(e, t) {
      var n = t && e,
        r = n && 1 === e.nodeType && 1 === t.nodeType && e.sourceIndex - t.sourceIndex;
      if (r) return r;
      if (n) while (n = n.nextSibling) if (n === t) return -1;
      return e ? 1 : -1;
    }
    function fe(e) {
      return function (t) {
        return "input" === t.nodeName.toLowerCase() && t.type === e;
      };
    }
    function pe(e) {
      return function (t) {
        var n = t.nodeName.toLowerCase();
        return ("input" === n || "button" === n) && t.type === e;
      };
    }
    function de(e) {
      return function (t) {
        return "form" in t ? t.parentNode && !1 === t.disabled ? "label" in t ? "label" in t.parentNode ? t.parentNode.disabled === e : t.disabled === e : t.isDisabled === e || t.isDisabled !== !e && ie(t) === e : t.disabled === e : "label" in t && t.disabled === e;
      };
    }
    function he(e) {
      return se(function (t) {
        return t = +t, se(function (n, r) {
          var i,
            o = e([], n.length, t),
            a = o.length;
          while (a--) n[i = o[a]] && (n[i] = !(r[i] = n[i]));
        });
      });
    }
    function ge(e) {
      return e && "undefined" != typeof e.getElementsByTagName && e;
    }
    n = oe.support = {}, o = oe.isXML = function (e) {
      var t = e && (e.ownerDocument || e).documentElement;
      return !!t && "HTML" !== t.nodeName;
    }, p = oe.setDocument = function (e) {
      var t,
        i,
        a = e ? e.ownerDocument || e : w;
      return a !== d && 9 === a.nodeType && a.documentElement ? (d = a, h = d.documentElement, g = !o(d), w !== d && (i = d.defaultView) && i.top !== i && (i.addEventListener ? i.addEventListener("unload", re, !1) : i.attachEvent && i.attachEvent("onunload", re)), n.attributes = ue(function (e) {
        return e.className = "i", !e.getAttribute("className");
      }), n.getElementsByTagName = ue(function (e) {
        return e.appendChild(d.createComment("")), !e.getElementsByTagName("*").length;
      }), n.getElementsByClassName = Q.test(d.getElementsByClassName), n.getById = ue(function (e) {
        return h.appendChild(e).id = b, !d.getElementsByName || !d.getElementsByName(b).length;
      }), n.getById ? (r.filter.ID = function (e) {
        var t = e.replace(Z, ee);
        return function (e) {
          return e.getAttribute("id") === t;
        };
      }, r.find.ID = function (e, t) {
        if ("undefined" != typeof t.getElementById && g) {
          var n = t.getElementById(e);
          return n ? [n] : [];
        }
      }) : (r.filter.ID = function (e) {
        var t = e.replace(Z, ee);
        return function (e) {
          var n = "undefined" != typeof e.getAttributeNode && e.getAttributeNode("id");
          return n && n.value === t;
        };
      }, r.find.ID = function (e, t) {
        if ("undefined" != typeof t.getElementById && g) {
          var n,
            r,
            i,
            o = t.getElementById(e);
          if (o) {
            if ((n = o.getAttributeNode("id")) && n.value === e) return [o];
            i = t.getElementsByName(e), r = 0;
            while (o = i[r++]) if ((n = o.getAttributeNode("id")) && n.value === e) return [o];
          }
          return [];
        }
      }), r.find.TAG = n.getElementsByTagName ? function (e, t) {
        return "undefined" != typeof t.getElementsByTagName ? t.getElementsByTagName(e) : n.qsa ? t.querySelectorAll(e) : void 0;
      } : function (e, t) {
        var n,
          r = [],
          i = 0,
          o = t.getElementsByTagName(e);
        if ("*" === e) {
          while (n = o[i++]) 1 === n.nodeType && r.push(n);
          return r;
        }
        return o;
      }, r.find.CLASS = n.getElementsByClassName && function (e, t) {
        if ("undefined" != typeof t.getElementsByClassName && g) return t.getElementsByClassName(e);
      }, v = [], y = [], (n.qsa = Q.test(d.querySelectorAll)) && (ue(function (e) {
        h.appendChild(e).innerHTML = "<a id='" + b + "'></a><select id='" + b + "-\r\\' msallowcapture=''><option selected=''></option></select>", e.querySelectorAll("[msallowcapture^='']").length && y.push("[*^$]=" + M + "*(?:''|\"\")"), e.querySelectorAll("[selected]").length || y.push("\\[" + M + "*(?:value|" + P + ")"), e.querySelectorAll("[id~=" + b + "-]").length || y.push("~="), e.querySelectorAll(":checked").length || y.push(":checked"), e.querySelectorAll("a#" + b + "+*").length || y.push(".#.+[+~]");
      }), ue(function (e) {
        e.innerHTML = "<a href='' disabled='disabled'></a><select disabled='disabled'><option/></select>";
        var t = d.createElement("input");
        t.setAttribute("type", "hidden"), e.appendChild(t).setAttribute("name", "D"), e.querySelectorAll("[name=d]").length && y.push("name" + M + "*[*^$|!~]?="), 2 !== e.querySelectorAll(":enabled").length && y.push(":enabled", ":disabled"), h.appendChild(e).disabled = !0, 2 !== e.querySelectorAll(":disabled").length && y.push(":enabled", ":disabled"), e.querySelectorAll("*,:x"), y.push(",.*:");
      })), (n.matchesSelector = Q.test(m = h.matches || h.webkitMatchesSelector || h.mozMatchesSelector || h.oMatchesSelector || h.msMatchesSelector)) && ue(function (e) {
        n.disconnectedMatch = m.call(e, "*"), m.call(e, "[s!='']:x"), v.push("!=", W);
      }), y = y.length && new RegExp(y.join("|")), v = v.length && new RegExp(v.join("|")), t = Q.test(h.compareDocumentPosition), x = t || Q.test(h.contains) ? function (e, t) {
        var n = 9 === e.nodeType ? e.documentElement : e,
          r = t && t.parentNode;
        return e === r || !(!r || 1 !== r.nodeType || !(n.contains ? n.contains(r) : e.compareDocumentPosition && 16 & e.compareDocumentPosition(r)));
      } : function (e, t) {
        if (t) while (t = t.parentNode) if (t === e) return !0;
        return !1;
      }, D = t ? function (e, t) {
        if (e === t) return f = !0, 0;
        var r = !e.compareDocumentPosition - !t.compareDocumentPosition;
        return r || (1 & (r = (e.ownerDocument || e) === (t.ownerDocument || t) ? e.compareDocumentPosition(t) : 1) || !n.sortDetached && t.compareDocumentPosition(e) === r ? e === d || e.ownerDocument === w && x(w, e) ? -1 : t === d || t.ownerDocument === w && x(w, t) ? 1 : c ? O(c, e) - O(c, t) : 0 : 4 & r ? -1 : 1);
      } : function (e, t) {
        if (e === t) return f = !0, 0;
        var n,
          r = 0,
          i = e.parentNode,
          o = t.parentNode,
          a = [e],
          s = [t];
        if (!i || !o) return e === d ? -1 : t === d ? 1 : i ? -1 : o ? 1 : c ? O(c, e) - O(c, t) : 0;
        if (i === o) return ce(e, t);
        n = e;
        while (n = n.parentNode) a.unshift(n);
        n = t;
        while (n = n.parentNode) s.unshift(n);
        while (a[r] === s[r]) r++;
        return r ? ce(a[r], s[r]) : a[r] === w ? -1 : s[r] === w ? 1 : 0;
      }, d) : d;
    }, oe.matches = function (e, t) {
      return oe(e, null, null, t);
    }, oe.matchesSelector = function (e, t) {
      if ((e.ownerDocument || e) !== d && p(e), t = t.replace(z, "='$1']"), n.matchesSelector && g && !S[t + " "] && (!v || !v.test(t)) && (!y || !y.test(t))) try {
        var r = m.call(e, t);
        if (r || n.disconnectedMatch || e.document && 11 !== e.document.nodeType) return r;
      } catch (e) {}
      return oe(t, d, null, [e]).length > 0;
    }, oe.contains = function (e, t) {
      return (e.ownerDocument || e) !== d && p(e), x(e, t);
    }, oe.attr = function (e, t) {
      (e.ownerDocument || e) !== d && p(e);
      var i = r.attrHandle[t.toLowerCase()],
        o = i && N.call(r.attrHandle, t.toLowerCase()) ? i(e, t, !g) : void 0;
      return void 0 !== o ? o : n.attributes || !g ? e.getAttribute(t) : (o = e.getAttributeNode(t)) && o.specified ? o.value : null;
    }, oe.escape = function (e) {
      return (e + "").replace(te, ne);
    }, oe.error = function (e) {
      throw new Error("Syntax error, unrecognized expression: " + e);
    }, oe.uniqueSort = function (e) {
      var t,
        r = [],
        i = 0,
        o = 0;
      if (f = !n.detectDuplicates, c = !n.sortStable && e.slice(0), e.sort(D), f) {
        while (t = e[o++]) t === e[o] && (i = r.push(o));
        while (i--) e.splice(r[i], 1);
      }
      return c = null, e;
    }, i = oe.getText = function (e) {
      var t,
        n = "",
        r = 0,
        o = e.nodeType;
      if (o) {
        if (1 === o || 9 === o || 11 === o) {
          if ("string" == typeof e.textContent) return e.textContent;
          for (e = e.firstChild; e; e = e.nextSibling) n += i(e);
        } else if (3 === o || 4 === o) return e.nodeValue;
      } else while (t = e[r++]) n += i(t);
      return n;
    }, (r = oe.selectors = {
      cacheLength: 50,
      createPseudo: se,
      match: V,
      attrHandle: {},
      find: {},
      relative: {
        ">": {
          dir: "parentNode",
          first: !0
        },
        " ": {
          dir: "parentNode"
        },
        "+": {
          dir: "previousSibling",
          first: !0
        },
        "~": {
          dir: "previousSibling"
        }
      },
      preFilter: {
        ATTR: function (e) {
          return e[1] = e[1].replace(Z, ee), e[3] = (e[3] || e[4] || e[5] || "").replace(Z, ee), "~=" === e[2] && (e[3] = " " + e[3] + " "), e.slice(0, 4);
        },
        CHILD: function (e) {
          return e[1] = e[1].toLowerCase(), "nth" === e[1].slice(0, 3) ? (e[3] || oe.error(e[0]), e[4] = +(e[4] ? e[5] + (e[6] || 1) : 2 * ("even" === e[3] || "odd" === e[3])), e[5] = +(e[7] + e[8] || "odd" === e[3])) : e[3] && oe.error(e[0]), e;
        },
        PSEUDO: function (e) {
          var t,
            n = !e[6] && e[2];
          return V.CHILD.test(e[0]) ? null : (e[3] ? e[2] = e[4] || e[5] || "" : n && X.test(n) && (t = a(n, !0)) && (t = n.indexOf(")", n.length - t) - n.length) && (e[0] = e[0].slice(0, t), e[2] = n.slice(0, t)), e.slice(0, 3));
        }
      },
      filter: {
        TAG: function (e) {
          var t = e.replace(Z, ee).toLowerCase();
          return "*" === e ? function () {
            return !0;
          } : function (e) {
            return e.nodeName && e.nodeName.toLowerCase() === t;
          };
        },
        CLASS: function (e) {
          var t = E[e + " "];
          return t || (t = new RegExp("(^|" + M + ")" + e + "(" + M + "|$)")) && E(e, function (e) {
            return t.test("string" == typeof e.className && e.className || "undefined" != typeof e.getAttribute && e.getAttribute("class") || "");
          });
        },
        ATTR: function (e, t, n) {
          return function (r) {
            var i = oe.attr(r, e);
            return null == i ? "!=" === t : !t || (i += "", "=" === t ? i === n : "!=" === t ? i !== n : "^=" === t ? n && 0 === i.indexOf(n) : "*=" === t ? n && i.indexOf(n) > -1 : "$=" === t ? n && i.slice(-n.length) === n : "~=" === t ? (" " + i.replace($, " ") + " ").indexOf(n) > -1 : "|=" === t && (i === n || i.slice(0, n.length + 1) === n + "-"));
          };
        },
        CHILD: function (e, t, n, r, i) {
          var o = "nth" !== e.slice(0, 3),
            a = "last" !== e.slice(-4),
            s = "of-type" === t;
          return 1 === r && 0 === i ? function (e) {
            return !!e.parentNode;
          } : function (t, n, u) {
            var l,
              c,
              f,
              p,
              d,
              h,
              g = o !== a ? "nextSibling" : "previousSibling",
              y = t.parentNode,
              v = s && t.nodeName.toLowerCase(),
              m = !u && !s,
              x = !1;
            if (y) {
              if (o) {
                while (g) {
                  p = t;
                  while (p = p[g]) if (s ? p.nodeName.toLowerCase() === v : 1 === p.nodeType) return !1;
                  h = g = "only" === e && !h && "nextSibling";
                }
                return !0;
              }
              if (h = [a ? y.firstChild : y.lastChild], a && m) {
                x = (d = (l = (c = (f = (p = y)[b] || (p[b] = {}))[p.uniqueID] || (f[p.uniqueID] = {}))[e] || [])[0] === T && l[1]) && l[2], p = d && y.childNodes[d];
                while (p = ++d && p && p[g] || (x = d = 0) || h.pop()) if (1 === p.nodeType && ++x && p === t) {
                  c[e] = [T, d, x];
                  break;
                }
              } else if (m && (x = d = (l = (c = (f = (p = t)[b] || (p[b] = {}))[p.uniqueID] || (f[p.uniqueID] = {}))[e] || [])[0] === T && l[1]), !1 === x) while (p = ++d && p && p[g] || (x = d = 0) || h.pop()) if ((s ? p.nodeName.toLowerCase() === v : 1 === p.nodeType) && ++x && (m && ((c = (f = p[b] || (p[b] = {}))[p.uniqueID] || (f[p.uniqueID] = {}))[e] = [T, x]), p === t)) break;
              return (x -= i) === r || x % r == 0 && x / r >= 0;
            }
          };
        },
        PSEUDO: function (e, t) {
          var n,
            i = r.pseudos[e] || r.setFilters[e.toLowerCase()] || oe.error("unsupported pseudo: " + e);
          return i[b] ? i(t) : i.length > 1 ? (n = [e, e, "", t], r.setFilters.hasOwnProperty(e.toLowerCase()) ? se(function (e, n) {
            var r,
              o = i(e, t),
              a = o.length;
            while (a--) e[r = O(e, o[a])] = !(n[r] = o[a]);
          }) : function (e) {
            return i(e, 0, n);
          }) : i;
        }
      },
      pseudos: {
        not: se(function (e) {
          var t = [],
            n = [],
            r = s(e.replace(B, "$1"));
          return r[b] ? se(function (e, t, n, i) {
            var o,
              a = r(e, null, i, []),
              s = e.length;
            while (s--) (o = a[s]) && (e[s] = !(t[s] = o));
          }) : function (e, i, o) {
            return t[0] = e, r(t, null, o, n), t[0] = null, !n.pop();
          };
        }),
        has: se(function (e) {
          return function (t) {
            return oe(e, t).length > 0;
          };
        }),
        contains: se(function (e) {
          return e = e.replace(Z, ee), function (t) {
            return (t.textContent || t.innerText || i(t)).indexOf(e) > -1;
          };
        }),
        lang: se(function (e) {
          return U.test(e || "") || oe.error("unsupported lang: " + e), e = e.replace(Z, ee).toLowerCase(), function (t) {
            var n;
            do {
              if (n = g ? t.lang : t.getAttribute("xml:lang") || t.getAttribute("lang")) return (n = n.toLowerCase()) === e || 0 === n.indexOf(e + "-");
            } while ((t = t.parentNode) && 1 === t.nodeType);
            return !1;
          };
        }),
        target: function (t) {
          var n = e.location && e.location.hash;
          return n && n.slice(1) === t.id;
        },
        root: function (e) {
          return e === h;
        },
        focus: function (e) {
          return e === d.activeElement && (!d.hasFocus || d.hasFocus()) && !!(e.type || e.href || ~e.tabIndex);
        },
        enabled: de(!1),
        disabled: de(!0),
        checked: function (e) {
          var t = e.nodeName.toLowerCase();
          return "input" === t && !!e.checked || "option" === t && !!e.selected;
        },
        selected: function (e) {
          return e.parentNode && e.parentNode.selectedIndex, !0 === e.selected;
        },
        empty: function (e) {
          for (e = e.firstChild; e; e = e.nextSibling) if (e.nodeType < 6) return !1;
          return !0;
        },
        parent: function (e) {
          return !r.pseudos.empty(e);
        },
        header: function (e) {
          return Y.test(e.nodeName);
        },
        input: function (e) {
          return G.test(e.nodeName);
        },
        button: function (e) {
          var t = e.nodeName.toLowerCase();
          return "input" === t && "button" === e.type || "button" === t;
        },
        text: function (e) {
          var t;
          return "input" === e.nodeName.toLowerCase() && "text" === e.type && (null == (t = e.getAttribute("type")) || "text" === t.toLowerCase());
        },
        first: he(function () {
          return [0];
        }),
        last: he(function (e, t) {
          return [t - 1];
        }),
        eq: he(function (e, t, n) {
          return [n < 0 ? n + t : n];
        }),
        even: he(function (e, t) {
          for (var n = 0; n < t; n += 2) e.push(n);
          return e;
        }),
        odd: he(function (e, t) {
          for (var n = 1; n < t; n += 2) e.push(n);
          return e;
        }),
        lt: he(function (e, t, n) {
          for (var r = n < 0 ? n + t : n; --r >= 0;) e.push(r);
          return e;
        }),
        gt: he(function (e, t, n) {
          for (var r = n < 0 ? n + t : n; ++r < t;) e.push(r);
          return e;
        })
      }
    }).pseudos.nth = r.pseudos.eq;
    for (t in {
      radio: !0,
      checkbox: !0,
      file: !0,
      password: !0,
      image: !0
    }) r.pseudos[t] = fe(t);
    for (t in {
      submit: !0,
      reset: !0
    }) r.pseudos[t] = pe(t);
    function ye() {}
    ye.prototype = r.filters = r.pseudos, r.setFilters = new ye(), a = oe.tokenize = function (e, t) {
      var n,
        i,
        o,
        a,
        s,
        u,
        l,
        c = k[e + " "];
      if (c) return t ? 0 : c.slice(0);
      s = e, u = [], l = r.preFilter;
      while (s) {
        n && !(i = F.exec(s)) || (i && (s = s.slice(i[0].length) || s), u.push(o = [])), n = !1, (i = _.exec(s)) && (n = i.shift(), o.push({
          value: n,
          type: i[0].replace(B, " ")
        }), s = s.slice(n.length));
        for (a in r.filter) !(i = V[a].exec(s)) || l[a] && !(i = l[a](i)) || (n = i.shift(), o.push({
          value: n,
          type: a,
          matches: i
        }), s = s.slice(n.length));
        if (!n) break;
      }
      return t ? s.length : s ? oe.error(e) : k(e, u).slice(0);
    };
    function ve(e) {
      for (var t = 0, n = e.length, r = ""; t < n; t++) r += e[t].value;
      return r;
    }
    function me(e, t, n) {
      var r = t.dir,
        i = t.next,
        o = i || r,
        a = n && "parentNode" === o,
        s = C++;
      return t.first ? function (t, n, i) {
        while (t = t[r]) if (1 === t.nodeType || a) return e(t, n, i);
        return !1;
      } : function (t, n, u) {
        var l,
          c,
          f,
          p = [T, s];
        if (u) {
          while (t = t[r]) if ((1 === t.nodeType || a) && e(t, n, u)) return !0;
        } else while (t = t[r]) if (1 === t.nodeType || a) if (f = t[b] || (t[b] = {}), c = f[t.uniqueID] || (f[t.uniqueID] = {}), i && i === t.nodeName.toLowerCase()) t = t[r] || t;else {
          if ((l = c[o]) && l[0] === T && l[1] === s) return p[2] = l[2];
          if (c[o] = p, p[2] = e(t, n, u)) return !0;
        }
        return !1;
      };
    }
    function xe(e) {
      return e.length > 1 ? function (t, n, r) {
        var i = e.length;
        while (i--) if (!e[i](t, n, r)) return !1;
        return !0;
      } : e[0];
    }
    function be(e, t, n) {
      for (var r = 0, i = t.length; r < i; r++) oe(e, t[r], n);
      return n;
    }
    function we(e, t, n, r, i) {
      for (var o, a = [], s = 0, u = e.length, l = null != t; s < u; s++) (o = e[s]) && (n && !n(o, r, i) || (a.push(o), l && t.push(s)));
      return a;
    }
    function Te(e, t, n, r, i, o) {
      return r && !r[b] && (r = Te(r)), i && !i[b] && (i = Te(i, o)), se(function (o, a, s, u) {
        var l,
          c,
          f,
          p = [],
          d = [],
          h = a.length,
          g = o || be(t || "*", s.nodeType ? [s] : s, []),
          y = !e || !o && t ? g : we(g, p, e, s, u),
          v = n ? i || (o ? e : h || r) ? [] : a : y;
        if (n && n(y, v, s, u), r) {
          l = we(v, d), r(l, [], s, u), c = l.length;
          while (c--) (f = l[c]) && (v[d[c]] = !(y[d[c]] = f));
        }
        if (o) {
          if (i || e) {
            if (i) {
              l = [], c = v.length;
              while (c--) (f = v[c]) && l.push(y[c] = f);
              i(null, v = [], l, u);
            }
            c = v.length;
            while (c--) (f = v[c]) && (l = i ? O(o, f) : p[c]) > -1 && (o[l] = !(a[l] = f));
          }
        } else v = we(v === a ? v.splice(h, v.length) : v), i ? i(null, a, v, u) : L.apply(a, v);
      });
    }
    function Ce(e) {
      for (var t, n, i, o = e.length, a = r.relative[e[0].type], s = a || r.relative[" "], u = a ? 1 : 0, c = me(function (e) {
          return e === t;
        }, s, !0), f = me(function (e) {
          return O(t, e) > -1;
        }, s, !0), p = [function (e, n, r) {
          var i = !a && (r || n !== l) || ((t = n).nodeType ? c(e, n, r) : f(e, n, r));
          return t = null, i;
        }]; u < o; u++) if (n = r.relative[e[u].type]) p = [me(xe(p), n)];else {
        if ((n = r.filter[e[u].type].apply(null, e[u].matches))[b]) {
          for (i = ++u; i < o; i++) if (r.relative[e[i].type]) break;
          return Te(u > 1 && xe(p), u > 1 && ve(e.slice(0, u - 1).concat({
            value: " " === e[u - 2].type ? "*" : ""
          })).replace(B, "$1"), n, u < i && Ce(e.slice(u, i)), i < o && Ce(e = e.slice(i)), i < o && ve(e));
        }
        p.push(n);
      }
      return xe(p);
    }
    function Ee(e, t) {
      var n = t.length > 0,
        i = e.length > 0,
        o = function (o, a, s, u, c) {
          var f,
            h,
            y,
            v = 0,
            m = "0",
            x = o && [],
            b = [],
            w = l,
            C = o || i && r.find.TAG("*", c),
            E = T += null == w ? 1 : Math.random() || .1,
            k = C.length;
          for (c && (l = a === d || a || c); m !== k && null != (f = C[m]); m++) {
            if (i && f) {
              h = 0, a || f.ownerDocument === d || (p(f), s = !g);
              while (y = e[h++]) if (y(f, a || d, s)) {
                u.push(f);
                break;
              }
              c && (T = E);
            }
            n && ((f = !y && f) && v--, o && x.push(f));
          }
          if (v += m, n && m !== v) {
            h = 0;
            while (y = t[h++]) y(x, b, a, s);
            if (o) {
              if (v > 0) while (m--) x[m] || b[m] || (b[m] = j.call(u));
              b = we(b);
            }
            L.apply(u, b), c && !o && b.length > 0 && v + t.length > 1 && oe.uniqueSort(u);
          }
          return c && (T = E, l = w), x;
        };
      return n ? se(o) : o;
    }
    return s = oe.compile = function (e, t) {
      var n,
        r = [],
        i = [],
        o = S[e + " "];
      if (!o) {
        t || (t = a(e)), n = t.length;
        while (n--) (o = Ce(t[n]))[b] ? r.push(o) : i.push(o);
        (o = S(e, Ee(i, r))).selector = e;
      }
      return o;
    }, u = oe.select = function (e, t, n, i) {
      var o,
        u,
        l,
        c,
        f,
        p = "function" == typeof e && e,
        d = !i && a(e = p.selector || e);
      if (n = n || [], 1 === d.length) {
        if ((u = d[0] = d[0].slice(0)).length > 2 && "ID" === (l = u[0]).type && 9 === t.nodeType && g && r.relative[u[1].type]) {
          if (!(t = (r.find.ID(l.matches[0].replace(Z, ee), t) || [])[0])) return n;
          p && (t = t.parentNode), e = e.slice(u.shift().value.length);
        }
        o = V.needsContext.test(e) ? 0 : u.length;
        while (o--) {
          if (l = u[o], r.relative[c = l.type]) break;
          if ((f = r.find[c]) && (i = f(l.matches[0].replace(Z, ee), K.test(u[0].type) && ge(t.parentNode) || t))) {
            if (u.splice(o, 1), !(e = i.length && ve(u))) return L.apply(n, i), n;
            break;
          }
        }
      }
      return (p || s(e, d))(i, t, !g, n, !t || K.test(e) && ge(t.parentNode) || t), n;
    }, n.sortStable = b.split("").sort(D).join("") === b, n.detectDuplicates = !!f, p(), n.sortDetached = ue(function (e) {
      return 1 & e.compareDocumentPosition(d.createElement("fieldset"));
    }), ue(function (e) {
      return e.innerHTML = "<a href='#'></a>", "#" === e.firstChild.getAttribute("href");
    }) || le("type|href|height|width", function (e, t, n) {
      if (!n) return e.getAttribute(t, "type" === t.toLowerCase() ? 1 : 2);
    }), n.attributes && ue(function (e) {
      return e.innerHTML = "<input/>", e.firstChild.setAttribute("value", ""), "" === e.firstChild.getAttribute("value");
    }) || le("value", function (e, t, n) {
      if (!n && "input" === e.nodeName.toLowerCase()) return e.defaultValue;
    }), ue(function (e) {
      return null == e.getAttribute("disabled");
    }) || le(P, function (e, t, n) {
      var r;
      if (!n) return !0 === e[t] ? t.toLowerCase() : (r = e.getAttributeNode(t)) && r.specified ? r.value : null;
    }), oe;
  }(e);
  w.find = E, w.expr = E.selectors, w.expr[":"] = w.expr.pseudos, w.uniqueSort = w.unique = E.uniqueSort, w.text = E.getText, w.isXMLDoc = E.isXML, w.contains = E.contains, w.escapeSelector = E.escape;
  var k = function (e, t, n) {
      var r = [],
        i = void 0 !== n;
      while ((e = e[t]) && 9 !== e.nodeType) if (1 === e.nodeType) {
        if (i && w(e).is(n)) break;
        r.push(e);
      }
      return r;
    },
    S = function (e, t) {
      for (var n = []; e; e = e.nextSibling) 1 === e.nodeType && e !== t && n.push(e);
      return n;
    },
    D = w.expr.match.needsContext;
  function N(e, t) {
    return e.nodeName && e.nodeName.toLowerCase() === t.toLowerCase();
  }
  var A = /^<([a-z][^\/\0>:\x20\t\r\n\f]*)[\x20\t\r\n\f]*\/?>(?:<\/\1>|)$/i;
  function j(e, t, n) {
    return g(t) ? w.grep(e, function (e, r) {
      return !!t.call(e, r, e) !== n;
    }) : t.nodeType ? w.grep(e, function (e) {
      return e === t !== n;
    }) : "string" != typeof t ? w.grep(e, function (e) {
      return u.call(t, e) > -1 !== n;
    }) : w.filter(t, e, n);
  }
  w.filter = function (e, t, n) {
    var r = t[0];
    return n && (e = ":not(" + e + ")"), 1 === t.length && 1 === r.nodeType ? w.find.matchesSelector(r, e) ? [r] : [] : w.find.matches(e, w.grep(t, function (e) {
      return 1 === e.nodeType;
    }));
  }, w.fn.extend({
    find: function (e) {
      var t,
        n,
        r = this.length,
        i = this;
      if ("string" != typeof e) return this.pushStack(w(e).filter(function () {
        for (t = 0; t < r; t++) if (w.contains(i[t], this)) return !0;
      }));
      for (n = this.pushStack([]), t = 0; t < r; t++) w.find(e, i[t], n);
      return r > 1 ? w.uniqueSort(n) : n;
    },
    filter: function (e) {
      return this.pushStack(j(this, e || [], !1));
    },
    not: function (e) {
      return this.pushStack(j(this, e || [], !0));
    },
    is: function (e) {
      return !!j(this, "string" == typeof e && D.test(e) ? w(e) : e || [], !1).length;
    }
  });
  var q,
    L = /^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]+))$/;
  (w.fn.init = function (e, t, n) {
    var i, o;
    if (!e) return this;
    if (n = n || q, "string" == typeof e) {
      if (!(i = "<" === e[0] && ">" === e[e.length - 1] && e.length >= 3 ? [null, e, null] : L.exec(e)) || !i[1] && t) return !t || t.jquery ? (t || n).find(e) : this.constructor(t).find(e);
      if (i[1]) {
        if (t = t instanceof w ? t[0] : t, w.merge(this, w.parseHTML(i[1], t && t.nodeType ? t.ownerDocument || t : r, !0)), A.test(i[1]) && w.isPlainObject(t)) for (i in t) g(this[i]) ? this[i](t[i]) : this.attr(i, t[i]);
        return this;
      }
      return (o = r.getElementById(i[2])) && (this[0] = o, this.length = 1), this;
    }
    return e.nodeType ? (this[0] = e, this.length = 1, this) : g(e) ? void 0 !== n.ready ? n.ready(e) : e(w) : w.makeArray(e, this);
  }).prototype = w.fn, q = w(r);
  var H = /^(?:parents|prev(?:Until|All))/,
    O = {
      children: !0,
      contents: !0,
      next: !0,
      prev: !0
    };
  w.fn.extend({
    has: function (e) {
      var t = w(e, this),
        n = t.length;
      return this.filter(function () {
        for (var e = 0; e < n; e++) if (w.contains(this, t[e])) return !0;
      });
    },
    closest: function (e, t) {
      var n,
        r = 0,
        i = this.length,
        o = [],
        a = "string" != typeof e && w(e);
      if (!D.test(e)) for (; r < i; r++) for (n = this[r]; n && n !== t; n = n.parentNode) if (n.nodeType < 11 && (a ? a.index(n) > -1 : 1 === n.nodeType && w.find.matchesSelector(n, e))) {
        o.push(n);
        break;
      }
      return this.pushStack(o.length > 1 ? w.uniqueSort(o) : o);
    },
    index: function (e) {
      return e ? "string" == typeof e ? u.call(w(e), this[0]) : u.call(this, e.jquery ? e[0] : e) : this[0] && this[0].parentNode ? this.first().prevAll().length : -1;
    },
    add: function (e, t) {
      return this.pushStack(w.uniqueSort(w.merge(this.get(), w(e, t))));
    },
    addBack: function (e) {
      return this.add(null == e ? this.prevObject : this.prevObject.filter(e));
    }
  });
  function P(e, t) {
    while ((e = e[t]) && 1 !== e.nodeType);
    return e;
  }
  w.each({
    parent: function (e) {
      var t = e.parentNode;
      return t && 11 !== t.nodeType ? t : null;
    },
    parents: function (e) {
      return k(e, "parentNode");
    },
    parentsUntil: function (e, t, n) {
      return k(e, "parentNode", n);
    },
    next: function (e) {
      return P(e, "nextSibling");
    },
    prev: function (e) {
      return P(e, "previousSibling");
    },
    nextAll: function (e) {
      return k(e, "nextSibling");
    },
    prevAll: function (e) {
      return k(e, "previousSibling");
    },
    nextUntil: function (e, t, n) {
      return k(e, "nextSibling", n);
    },
    prevUntil: function (e, t, n) {
      return k(e, "previousSibling", n);
    },
    siblings: function (e) {
      return S((e.parentNode || {}).firstChild, e);
    },
    children: function (e) {
      return S(e.firstChild);
    },
    contents: function (e) {
      return N(e, "iframe") ? e.contentDocument : (N(e, "template") && (e = e.content || e), w.merge([], e.childNodes));
    }
  }, function (e, t) {
    w.fn[e] = function (n, r) {
      var i = w.map(this, t, n);
      return "Until" !== e.slice(-5) && (r = n), r && "string" == typeof r && (i = w.filter(r, i)), this.length > 1 && (O[e] || w.uniqueSort(i), H.test(e) && i.reverse()), this.pushStack(i);
    };
  });
  var M = /[^\x20\t\r\n\f]+/g;
  function R(e) {
    var t = {};
    return w.each(e.match(M) || [], function (e, n) {
      t[n] = !0;
    }), t;
  }
  w.Callbacks = function (e) {
    e = "string" == typeof e ? R(e) : w.extend({}, e);
    var t,
      n,
      r,
      i,
      o = [],
      a = [],
      s = -1,
      u = function () {
        for (i = i || e.once, r = t = !0; a.length; s = -1) {
          n = a.shift();
          while (++s < o.length) !1 === o[s].apply(n[0], n[1]) && e.stopOnFalse && (s = o.length, n = !1);
        }
        e.memory || (n = !1), t = !1, i && (o = n ? [] : "");
      },
      l = {
        add: function () {
          return o && (n && !t && (s = o.length - 1, a.push(n)), function t(n) {
            w.each(n, function (n, r) {
              g(r) ? e.unique && l.has(r) || o.push(r) : r && r.length && "string" !== x(r) && t(r);
            });
          }(arguments), n && !t && u()), this;
        },
        remove: function () {
          return w.each(arguments, function (e, t) {
            var n;
            while ((n = w.inArray(t, o, n)) > -1) o.splice(n, 1), n <= s && s--;
          }), this;
        },
        has: function (e) {
          return e ? w.inArray(e, o) > -1 : o.length > 0;
        },
        empty: function () {
          return o && (o = []), this;
        },
        disable: function () {
          return i = a = [], o = n = "", this;
        },
        disabled: function () {
          return !o;
        },
        lock: function () {
          return i = a = [], n || t || (o = n = ""), this;
        },
        locked: function () {
          return !!i;
        },
        fireWith: function (e, n) {
          return i || (n = [e, (n = n || []).slice ? n.slice() : n], a.push(n), t || u()), this;
        },
        fire: function () {
          return l.fireWith(this, arguments), this;
        },
        fired: function () {
          return !!r;
        }
      };
    return l;
  };
  function I(e) {
    return e;
  }
  function W(e) {
    throw e;
  }
  function $(e, t, n, r) {
    var i;
    try {
      e && g(i = e.promise) ? i.call(e).done(t).fail(n) : e && g(i = e.then) ? i.call(e, t, n) : t.apply(void 0, [e].slice(r));
    } catch (e) {
      n.apply(void 0, [e]);
    }
  }
  w.extend({
    Deferred: function (t) {
      var n = [["notify", "progress", w.Callbacks("memory"), w.Callbacks("memory"), 2], ["resolve", "done", w.Callbacks("once memory"), w.Callbacks("once memory"), 0, "resolved"], ["reject", "fail", w.Callbacks("once memory"), w.Callbacks("once memory"), 1, "rejected"]],
        r = "pending",
        i = {
          state: function () {
            return r;
          },
          always: function () {
            return o.done(arguments).fail(arguments), this;
          },
          "catch": function (e) {
            return i.then(null, e);
          },
          pipe: function () {
            var e = arguments;
            return w.Deferred(function (t) {
              w.each(n, function (n, r) {
                var i = g(e[r[4]]) && e[r[4]];
                o[r[1]](function () {
                  var e = i && i.apply(this, arguments);
                  e && g(e.promise) ? e.promise().progress(t.notify).done(t.resolve).fail(t.reject) : t[r[0] + "With"](this, i ? [e] : arguments);
                });
              }), e = null;
            }).promise();
          },
          then: function (t, r, i) {
            var o = 0;
            function a(t, n, r, i) {
              return function () {
                var s = this,
                  u = arguments,
                  l = function () {
                    var e, l;
                    if (!(t < o)) {
                      if ((e = r.apply(s, u)) === n.promise()) throw new TypeError("Thenable self-resolution");
                      l = e && ("object" == typeof e || "function" == typeof e) && e.then, g(l) ? i ? l.call(e, a(o, n, I, i), a(o, n, W, i)) : (o++, l.call(e, a(o, n, I, i), a(o, n, W, i), a(o, n, I, n.notifyWith))) : (r !== I && (s = void 0, u = [e]), (i || n.resolveWith)(s, u));
                    }
                  },
                  c = i ? l : function () {
                    try {
                      l();
                    } catch (e) {
                      w.Deferred.exceptionHook && w.Deferred.exceptionHook(e, c.stackTrace), t + 1 >= o && (r !== W && (s = void 0, u = [e]), n.rejectWith(s, u));
                    }
                  };
                t ? c() : (w.Deferred.getStackHook && (c.stackTrace = w.Deferred.getStackHook()), e.setTimeout(c));
              };
            }
            return w.Deferred(function (e) {
              n[0][3].add(a(0, e, g(i) ? i : I, e.notifyWith)), n[1][3].add(a(0, e, g(t) ? t : I)), n[2][3].add(a(0, e, g(r) ? r : W));
            }).promise();
          },
          promise: function (e) {
            return null != e ? w.extend(e, i) : i;
          }
        },
        o = {};
      return w.each(n, function (e, t) {
        var a = t[2],
          s = t[5];
        i[t[1]] = a.add, s && a.add(function () {
          r = s;
        }, n[3 - e][2].disable, n[3 - e][3].disable, n[0][2].lock, n[0][3].lock), a.add(t[3].fire), o[t[0]] = function () {
          return o[t[0] + "With"](this === o ? void 0 : this, arguments), this;
        }, o[t[0] + "With"] = a.fireWith;
      }), i.promise(o), t && t.call(o, o), o;
    },
    when: function (e) {
      var t = arguments.length,
        n = t,
        r = Array(n),
        i = o.call(arguments),
        a = w.Deferred(),
        s = function (e) {
          return function (n) {
            r[e] = this, i[e] = arguments.length > 1 ? o.call(arguments) : n, --t || a.resolveWith(r, i);
          };
        };
      if (t <= 1 && ($(e, a.done(s(n)).resolve, a.reject, !t), "pending" === a.state() || g(i[n] && i[n].then))) return a.then();
      while (n--) $(i[n], s(n), a.reject);
      return a.promise();
    }
  });
  var B = /^(Eval|Internal|Range|Reference|Syntax|Type|URI)Error$/;
  w.Deferred.exceptionHook = function (t, n) {
    e.console && e.console.warn && t && B.test(t.name) && e.console.warn("jQuery.Deferred exception: " + t.message, t.stack, n);
  }, w.readyException = function (t) {
    e.setTimeout(function () {
      throw t;
    });
  };
  var F = w.Deferred();
  w.fn.ready = function (e) {
    return F.then(e)["catch"](function (e) {
      w.readyException(e);
    }), this;
  }, w.extend({
    isReady: !1,
    readyWait: 1,
    ready: function (e) {
      (!0 === e ? --w.readyWait : w.isReady) || (w.isReady = !0, !0 !== e && --w.readyWait > 0 || F.resolveWith(r, [w]));
    }
  }), w.ready.then = F.then;
  function _() {
    r.removeEventListener("DOMContentLoaded", _), e.removeEventListener("load", _), w.ready();
  }
  "complete" === r.readyState || "loading" !== r.readyState && !r.documentElement.doScroll ? e.setTimeout(w.ready) : (r.addEventListener("DOMContentLoaded", _), e.addEventListener("load", _));
  var z = function (e, t, n, r, i, o, a) {
      var s = 0,
        u = e.length,
        l = null == n;
      if ("object" === x(n)) {
        i = !0;
        for (s in n) z(e, t, s, n[s], !0, o, a);
      } else if (void 0 !== r && (i = !0, g(r) || (a = !0), l && (a ? (t.call(e, r), t = null) : (l = t, t = function (e, t, n) {
        return l.call(w(e), n);
      })), t)) for (; s < u; s++) t(e[s], n, a ? r : r.call(e[s], s, t(e[s], n)));
      return i ? e : l ? t.call(e) : u ? t(e[0], n) : o;
    },
    X = /^-ms-/,
    U = /-([a-z])/g;
  function V(e, t) {
    return t.toUpperCase();
  }
  function G(e) {
    return e.replace(X, "ms-").replace(U, V);
  }
  var Y = function (e) {
    return 1 === e.nodeType || 9 === e.nodeType || !+e.nodeType;
  };
  function Q() {
    this.expando = w.expando + Q.uid++;
  }
  Q.uid = 1, Q.prototype = {
    cache: function (e) {
      var t = e[this.expando];
      return t || (t = {}, Y(e) && (e.nodeType ? e[this.expando] = t : Object.defineProperty(e, this.expando, {
        value: t,
        configurable: !0
      }))), t;
    },
    set: function (e, t, n) {
      var r,
        i = this.cache(e);
      if ("string" == typeof t) i[G(t)] = n;else for (r in t) i[G(r)] = t[r];
      return i;
    },
    get: function (e, t) {
      return void 0 === t ? this.cache(e) : e[this.expando] && e[this.expando][G(t)];
    },
    access: function (e, t, n) {
      return void 0 === t || t && "string" == typeof t && void 0 === n ? this.get(e, t) : (this.set(e, t, n), void 0 !== n ? n : t);
    },
    remove: function (e, t) {
      var n,
        r = e[this.expando];
      if (void 0 !== r) {
        if (void 0 !== t) {
          n = (t = Array.isArray(t) ? t.map(G) : (t = G(t)) in r ? [t] : t.match(M) || []).length;
          while (n--) delete r[t[n]];
        }
        (void 0 === t || w.isEmptyObject(r)) && (e.nodeType ? e[this.expando] = void 0 : delete e[this.expando]);
      }
    },
    hasData: function (e) {
      var t = e[this.expando];
      return void 0 !== t && !w.isEmptyObject(t);
    }
  };
  var J = new Q(),
    K = new Q(),
    Z = /^(?:\{[\w\W]*\}|\[[\w\W]*\])$/,
    ee = /[A-Z]/g;
  function te(e) {
    return "true" === e || "false" !== e && ("null" === e ? null : e === +e + "" ? +e : Z.test(e) ? JSON.parse(e) : e);
  }
  function ne(e, t, n) {
    var r;
    if (void 0 === n && 1 === e.nodeType) if (r = "data-" + t.replace(ee, "-$&").toLowerCase(), "string" == typeof (n = e.getAttribute(r))) {
      try {
        n = te(n);
      } catch (e) {}
      K.set(e, t, n);
    } else n = void 0;
    return n;
  }
  w.extend({
    hasData: function (e) {
      return K.hasData(e) || J.hasData(e);
    },
    data: function (e, t, n) {
      return K.access(e, t, n);
    },
    removeData: function (e, t) {
      K.remove(e, t);
    },
    _data: function (e, t, n) {
      return J.access(e, t, n);
    },
    _removeData: function (e, t) {
      J.remove(e, t);
    }
  }), w.fn.extend({
    data: function (e, t) {
      var n,
        r,
        i,
        o = this[0],
        a = o && o.attributes;
      if (void 0 === e) {
        if (this.length && (i = K.get(o), 1 === o.nodeType && !J.get(o, "hasDataAttrs"))) {
          n = a.length;
          while (n--) a[n] && 0 === (r = a[n].name).indexOf("data-") && (r = G(r.slice(5)), ne(o, r, i[r]));
          J.set(o, "hasDataAttrs", !0);
        }
        return i;
      }
      return "object" == typeof e ? this.each(function () {
        K.set(this, e);
      }) : z(this, function (t) {
        var n;
        if (o && void 0 === t) {
          if (void 0 !== (n = K.get(o, e))) return n;
          if (void 0 !== (n = ne(o, e))) return n;
        } else this.each(function () {
          K.set(this, e, t);
        });
      }, null, t, arguments.length > 1, null, !0);
    },
    removeData: function (e) {
      return this.each(function () {
        K.remove(this, e);
      });
    }
  }), w.extend({
    queue: function (e, t, n) {
      var r;
      if (e) return t = (t || "fx") + "queue", r = J.get(e, t), n && (!r || Array.isArray(n) ? r = J.access(e, t, w.makeArray(n)) : r.push(n)), r || [];
    },
    dequeue: function (e, t) {
      t = t || "fx";
      var n = w.queue(e, t),
        r = n.length,
        i = n.shift(),
        o = w._queueHooks(e, t),
        a = function () {
          w.dequeue(e, t);
        };
      "inprogress" === i && (i = n.shift(), r--), i && ("fx" === t && n.unshift("inprogress"), delete o.stop, i.call(e, a, o)), !r && o && o.empty.fire();
    },
    _queueHooks: function (e, t) {
      var n = t + "queueHooks";
      return J.get(e, n) || J.access(e, n, {
        empty: w.Callbacks("once memory").add(function () {
          J.remove(e, [t + "queue", n]);
        })
      });
    }
  }), w.fn.extend({
    queue: function (e, t) {
      var n = 2;
      return "string" != typeof e && (t = e, e = "fx", n--), arguments.length < n ? w.queue(this[0], e) : void 0 === t ? this : this.each(function () {
        var n = w.queue(this, e, t);
        w._queueHooks(this, e), "fx" === e && "inprogress" !== n[0] && w.dequeue(this, e);
      });
    },
    dequeue: function (e) {
      return this.each(function () {
        w.dequeue(this, e);
      });
    },
    clearQueue: function (e) {
      return this.queue(e || "fx", []);
    },
    promise: function (e, t) {
      var n,
        r = 1,
        i = w.Deferred(),
        o = this,
        a = this.length,
        s = function () {
          --r || i.resolveWith(o, [o]);
        };
      "string" != typeof e && (t = e, e = void 0), e = e || "fx";
      while (a--) (n = J.get(o[a], e + "queueHooks")) && n.empty && (r++, n.empty.add(s));
      return s(), i.promise(t);
    }
  });
  var re = /[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,
    ie = new RegExp("^(?:([+-])=|)(" + re + ")([a-z%]*)$", "i"),
    oe = ["Top", "Right", "Bottom", "Left"],
    ae = function (e, t) {
      return "none" === (e = t || e).style.display || "" === e.style.display && w.contains(e.ownerDocument, e) && "none" === w.css(e, "display");
    },
    se = function (e, t, n, r) {
      var i,
        o,
        a = {};
      for (o in t) a[o] = e.style[o], e.style[o] = t[o];
      i = n.apply(e, r || []);
      for (o in t) e.style[o] = a[o];
      return i;
    };
  function ue(e, t, n, r) {
    var i,
      o,
      a = 20,
      s = r ? function () {
        return r.cur();
      } : function () {
        return w.css(e, t, "");
      },
      u = s(),
      l = n && n[3] || (w.cssNumber[t] ? "" : "px"),
      c = (w.cssNumber[t] || "px" !== l && +u) && ie.exec(w.css(e, t));
    if (c && c[3] !== l) {
      u /= 2, l = l || c[3], c = +u || 1;
      while (a--) w.style(e, t, c + l), (1 - o) * (1 - (o = s() / u || .5)) <= 0 && (a = 0), c /= o;
      c *= 2, w.style(e, t, c + l), n = n || [];
    }
    return n && (c = +c || +u || 0, i = n[1] ? c + (n[1] + 1) * n[2] : +n[2], r && (r.unit = l, r.start = c, r.end = i)), i;
  }
  var le = {};
  function ce(e) {
    var t,
      n = e.ownerDocument,
      r = e.nodeName,
      i = le[r];
    return i || (t = n.body.appendChild(n.createElement(r)), i = w.css(t, "display"), t.parentNode.removeChild(t), "none" === i && (i = "block"), le[r] = i, i);
  }
  function fe(e, t) {
    for (var n, r, i = [], o = 0, a = e.length; o < a; o++) (r = e[o]).style && (n = r.style.display, t ? ("none" === n && (i[o] = J.get(r, "display") || null, i[o] || (r.style.display = "")), "" === r.style.display && ae(r) && (i[o] = ce(r))) : "none" !== n && (i[o] = "none", J.set(r, "display", n)));
    for (o = 0; o < a; o++) null != i[o] && (e[o].style.display = i[o]);
    return e;
  }
  w.fn.extend({
    show: function () {
      return fe(this, !0);
    },
    hide: function () {
      return fe(this);
    },
    toggle: function (e) {
      return "boolean" == typeof e ? e ? this.show() : this.hide() : this.each(function () {
        ae(this) ? w(this).show() : w(this).hide();
      });
    }
  });
  var pe = /^(?:checkbox|radio)$/i,
    de = /<([a-z][^\/\0>\x20\t\r\n\f]+)/i,
    he = /^$|^module$|\/(?:java|ecma)script/i,
    ge = {
      option: [1, "<select multiple='multiple'>", "</select>"],
      thead: [1, "<table>", "</table>"],
      col: [2, "<table><colgroup>", "</colgroup></table>"],
      tr: [2, "<table><tbody>", "</tbody></table>"],
      td: [3, "<table><tbody><tr>", "</tr></tbody></table>"],
      _default: [0, "", ""]
    };
  ge.optgroup = ge.option, ge.tbody = ge.tfoot = ge.colgroup = ge.caption = ge.thead, ge.th = ge.td;
  function ye(e, t) {
    var n;
    return n = "undefined" != typeof e.getElementsByTagName ? e.getElementsByTagName(t || "*") : "undefined" != typeof e.querySelectorAll ? e.querySelectorAll(t || "*") : [], void 0 === t || t && N(e, t) ? w.merge([e], n) : n;
  }
  function ve(e, t) {
    for (var n = 0, r = e.length; n < r; n++) J.set(e[n], "globalEval", !t || J.get(t[n], "globalEval"));
  }
  var me = /<|&#?\w+;/;
  function xe(e, t, n, r, i) {
    for (var o, a, s, u, l, c, f = t.createDocumentFragment(), p = [], d = 0, h = e.length; d < h; d++) if ((o = e[d]) || 0 === o) if ("object" === x(o)) w.merge(p, o.nodeType ? [o] : o);else if (me.test(o)) {
      a = a || f.appendChild(t.createElement("div")), s = (de.exec(o) || ["", ""])[1].toLowerCase(), u = ge[s] || ge._default, a.innerHTML = u[1] + w.htmlPrefilter(o) + u[2], c = u[0];
      while (c--) a = a.lastChild;
      w.merge(p, a.childNodes), (a = f.firstChild).textContent = "";
    } else p.push(t.createTextNode(o));
    f.textContent = "", d = 0;
    while (o = p[d++]) if (r && w.inArray(o, r) > -1) i && i.push(o);else if (l = w.contains(o.ownerDocument, o), a = ye(f.appendChild(o), "script"), l && ve(a), n) {
      c = 0;
      while (o = a[c++]) he.test(o.type || "") && n.push(o);
    }
    return f;
  }
  !function () {
    var e = r.createDocumentFragment().appendChild(r.createElement("div")),
      t = r.createElement("input");
    t.setAttribute("type", "radio"), t.setAttribute("checked", "checked"), t.setAttribute("name", "t"), e.appendChild(t), h.checkClone = e.cloneNode(!0).cloneNode(!0).lastChild.checked, e.innerHTML = "<textarea>x</textarea>", h.noCloneChecked = !!e.cloneNode(!0).lastChild.defaultValue;
  }();
  var be = r.documentElement,
    we = /^key/,
    Te = /^(?:mouse|pointer|contextmenu|drag|drop)|click/,
    Ce = /^([^.]*)(?:\.(.+)|)/;
  function Ee() {
    return !0;
  }
  function ke() {
    return !1;
  }
  function Se() {
    try {
      return r.activeElement;
    } catch (e) {}
  }
  function De(e, t, n, r, i, o) {
    var a, s;
    if ("object" == typeof t) {
      "string" != typeof n && (r = r || n, n = void 0);
      for (s in t) De(e, s, n, r, t[s], o);
      return e;
    }
    if (null == r && null == i ? (i = n, r = n = void 0) : null == i && ("string" == typeof n ? (i = r, r = void 0) : (i = r, r = n, n = void 0)), !1 === i) i = ke;else if (!i) return e;
    return 1 === o && (a = i, (i = function (e) {
      return w().off(e), a.apply(this, arguments);
    }).guid = a.guid || (a.guid = w.guid++)), e.each(function () {
      w.event.add(this, t, i, r, n);
    });
  }
  w.event = {
    global: {},
    add: function (e, t, n, r, i) {
      var o,
        a,
        s,
        u,
        l,
        c,
        f,
        p,
        d,
        h,
        g,
        y = J.get(e);
      if (y) {
        n.handler && (n = (o = n).handler, i = o.selector), i && w.find.matchesSelector(be, i), n.guid || (n.guid = w.guid++), (u = y.events) || (u = y.events = {}), (a = y.handle) || (a = y.handle = function (t) {
          return "undefined" != typeof w && w.event.triggered !== t.type ? w.event.dispatch.apply(e, arguments) : void 0;
        }), l = (t = (t || "").match(M) || [""]).length;
        while (l--) d = g = (s = Ce.exec(t[l]) || [])[1], h = (s[2] || "").split(".").sort(), d && (f = w.event.special[d] || {}, d = (i ? f.delegateType : f.bindType) || d, f = w.event.special[d] || {}, c = w.extend({
          type: d,
          origType: g,
          data: r,
          handler: n,
          guid: n.guid,
          selector: i,
          needsContext: i && w.expr.match.needsContext.test(i),
          namespace: h.join(".")
        }, o), (p = u[d]) || ((p = u[d] = []).delegateCount = 0, f.setup && !1 !== f.setup.call(e, r, h, a) || e.addEventListener && e.addEventListener(d, a)), f.add && (f.add.call(e, c), c.handler.guid || (c.handler.guid = n.guid)), i ? p.splice(p.delegateCount++, 0, c) : p.push(c), w.event.global[d] = !0);
      }
    },
    remove: function (e, t, n, r, i) {
      var o,
        a,
        s,
        u,
        l,
        c,
        f,
        p,
        d,
        h,
        g,
        y = J.hasData(e) && J.get(e);
      if (y && (u = y.events)) {
        l = (t = (t || "").match(M) || [""]).length;
        while (l--) if (s = Ce.exec(t[l]) || [], d = g = s[1], h = (s[2] || "").split(".").sort(), d) {
          f = w.event.special[d] || {}, p = u[d = (r ? f.delegateType : f.bindType) || d] || [], s = s[2] && new RegExp("(^|\\.)" + h.join("\\.(?:.*\\.|)") + "(\\.|$)"), a = o = p.length;
          while (o--) c = p[o], !i && g !== c.origType || n && n.guid !== c.guid || s && !s.test(c.namespace) || r && r !== c.selector && ("**" !== r || !c.selector) || (p.splice(o, 1), c.selector && p.delegateCount--, f.remove && f.remove.call(e, c));
          a && !p.length && (f.teardown && !1 !== f.teardown.call(e, h, y.handle) || w.removeEvent(e, d, y.handle), delete u[d]);
        } else for (d in u) w.event.remove(e, d + t[l], n, r, !0);
        w.isEmptyObject(u) && J.remove(e, "handle events");
      }
    },
    dispatch: function (e) {
      var t = w.event.fix(e),
        n,
        r,
        i,
        o,
        a,
        s,
        u = new Array(arguments.length),
        l = (J.get(this, "events") || {})[t.type] || [],
        c = w.event.special[t.type] || {};
      for (u[0] = t, n = 1; n < arguments.length; n++) u[n] = arguments[n];
      if (t.delegateTarget = this, !c.preDispatch || !1 !== c.preDispatch.call(this, t)) {
        s = w.event.handlers.call(this, t, l), n = 0;
        while ((o = s[n++]) && !t.isPropagationStopped()) {
          t.currentTarget = o.elem, r = 0;
          while ((a = o.handlers[r++]) && !t.isImmediatePropagationStopped()) t.rnamespace && !t.rnamespace.test(a.namespace) || (t.handleObj = a, t.data = a.data, void 0 !== (i = ((w.event.special[a.origType] || {}).handle || a.handler).apply(o.elem, u)) && !1 === (t.result = i) && (t.preventDefault(), t.stopPropagation()));
        }
        return c.postDispatch && c.postDispatch.call(this, t), t.result;
      }
    },
    handlers: function (e, t) {
      var n,
        r,
        i,
        o,
        a,
        s = [],
        u = t.delegateCount,
        l = e.target;
      if (u && l.nodeType && !("click" === e.type && e.button >= 1)) for (; l !== this; l = l.parentNode || this) if (1 === l.nodeType && ("click" !== e.type || !0 !== l.disabled)) {
        for (o = [], a = {}, n = 0; n < u; n++) void 0 === a[i = (r = t[n]).selector + " "] && (a[i] = r.needsContext ? w(i, this).index(l) > -1 : w.find(i, this, null, [l]).length), a[i] && o.push(r);
        o.length && s.push({
          elem: l,
          handlers: o
        });
      }
      return l = this, u < t.length && s.push({
        elem: l,
        handlers: t.slice(u)
      }), s;
    },
    addProp: function (e, t) {
      Object.defineProperty(w.Event.prototype, e, {
        enumerable: !0,
        configurable: !0,
        get: g(t) ? function () {
          if (this.originalEvent) return t(this.originalEvent);
        } : function () {
          if (this.originalEvent) return this.originalEvent[e];
        },
        set: function (t) {
          Object.defineProperty(this, e, {
            enumerable: !0,
            configurable: !0,
            writable: !0,
            value: t
          });
        }
      });
    },
    fix: function (e) {
      return e[w.expando] ? e : new w.Event(e);
    },
    special: {
      load: {
        noBubble: !0
      },
      focus: {
        trigger: function () {
          if (this !== Se() && this.focus) return this.focus(), !1;
        },
        delegateType: "focusin"
      },
      blur: {
        trigger: function () {
          if (this === Se() && this.blur) return this.blur(), !1;
        },
        delegateType: "focusout"
      },
      click: {
        trigger: function () {
          if ("checkbox" === this.type && this.click && N(this, "input")) return this.click(), !1;
        },
        _default: function (e) {
          return N(e.target, "a");
        }
      },
      beforeunload: {
        postDispatch: function (e) {
          void 0 !== e.result && e.originalEvent && (e.originalEvent.returnValue = e.result);
        }
      }
    }
  }, w.removeEvent = function (e, t, n) {
    e.removeEventListener && e.removeEventListener(t, n);
  }, w.Event = function (e, t) {
    if (!(this instanceof w.Event)) return new w.Event(e, t);
    e && e.type ? (this.originalEvent = e, this.type = e.type, this.isDefaultPrevented = e.defaultPrevented || void 0 === e.defaultPrevented && !1 === e.returnValue ? Ee : ke, this.target = e.target && 3 === e.target.nodeType ? e.target.parentNode : e.target, this.currentTarget = e.currentTarget, this.relatedTarget = e.relatedTarget) : this.type = e, t && w.extend(this, t), this.timeStamp = e && e.timeStamp || Date.now(), this[w.expando] = !0;
  }, w.Event.prototype = {
    constructor: w.Event,
    isDefaultPrevented: ke,
    isPropagationStopped: ke,
    isImmediatePropagationStopped: ke,
    isSimulated: !1,
    preventDefault: function () {
      var e = this.originalEvent;
      this.isDefaultPrevented = Ee, e && !this.isSimulated && e.preventDefault();
    },
    stopPropagation: function () {
      var e = this.originalEvent;
      this.isPropagationStopped = Ee, e && !this.isSimulated && e.stopPropagation();
    },
    stopImmediatePropagation: function () {
      var e = this.originalEvent;
      this.isImmediatePropagationStopped = Ee, e && !this.isSimulated && e.stopImmediatePropagation(), this.stopPropagation();
    }
  }, w.each({
    altKey: !0,
    bubbles: !0,
    cancelable: !0,
    changedTouches: !0,
    ctrlKey: !0,
    detail: !0,
    eventPhase: !0,
    metaKey: !0,
    pageX: !0,
    pageY: !0,
    shiftKey: !0,
    view: !0,
    "char": !0,
    charCode: !0,
    key: !0,
    keyCode: !0,
    button: !0,
    buttons: !0,
    clientX: !0,
    clientY: !0,
    offsetX: !0,
    offsetY: !0,
    pointerId: !0,
    pointerType: !0,
    screenX: !0,
    screenY: !0,
    targetTouches: !0,
    toElement: !0,
    touches: !0,
    which: function (e) {
      var t = e.button;
      return null == e.which && we.test(e.type) ? null != e.charCode ? e.charCode : e.keyCode : !e.which && void 0 !== t && Te.test(e.type) ? 1 & t ? 1 : 2 & t ? 3 : 4 & t ? 2 : 0 : e.which;
    }
  }, w.event.addProp), w.each({
    mouseenter: "mouseover",
    mouseleave: "mouseout",
    pointerenter: "pointerover",
    pointerleave: "pointerout"
  }, function (e, t) {
    w.event.special[e] = {
      delegateType: t,
      bindType: t,
      handle: function (e) {
        var n,
          r = this,
          i = e.relatedTarget,
          o = e.handleObj;
        return i && (i === r || w.contains(r, i)) || (e.type = o.origType, n = o.handler.apply(this, arguments), e.type = t), n;
      }
    };
  }), w.fn.extend({
    on: function (e, t, n, r) {
      return De(this, e, t, n, r);
    },
    one: function (e, t, n, r) {
      return De(this, e, t, n, r, 1);
    },
    off: function (e, t, n) {
      var r, i;
      if (e && e.preventDefault && e.handleObj) return r = e.handleObj, w(e.delegateTarget).off(r.namespace ? r.origType + "." + r.namespace : r.origType, r.selector, r.handler), this;
      if ("object" == typeof e) {
        for (i in e) this.off(i, t, e[i]);
        return this;
      }
      return !1 !== t && "function" != typeof t || (n = t, t = void 0), !1 === n && (n = ke), this.each(function () {
        w.event.remove(this, e, n, t);
      });
    }
  });
  var Ne = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([a-z][^\/\0>\x20\t\r\n\f]*)[^>]*)\/>/gi,
    Ae = /<script|<style|<link/i,
    je = /checked\s*(?:[^=]|=\s*.checked.)/i,
    qe = /^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g;
  function Le(e, t) {
    return N(e, "table") && N(11 !== t.nodeType ? t : t.firstChild, "tr") ? w(e).children("tbody")[0] || e : e;
  }
  function He(e) {
    return e.type = (null !== e.getAttribute("type")) + "/" + e.type, e;
  }
  function Oe(e) {
    return "true/" === (e.type || "").slice(0, 5) ? e.type = e.type.slice(5) : e.removeAttribute("type"), e;
  }
  function Pe(e, t) {
    var n, r, i, o, a, s, u, l;
    if (1 === t.nodeType) {
      if (J.hasData(e) && (o = J.access(e), a = J.set(t, o), l = o.events)) {
        delete a.handle, a.events = {};
        for (i in l) for (n = 0, r = l[i].length; n < r; n++) w.event.add(t, i, l[i][n]);
      }
      K.hasData(e) && (s = K.access(e), u = w.extend({}, s), K.set(t, u));
    }
  }
  function Me(e, t) {
    var n = t.nodeName.toLowerCase();
    "input" === n && pe.test(e.type) ? t.checked = e.checked : "input" !== n && "textarea" !== n || (t.defaultValue = e.defaultValue);
  }
  function Re(e, t, n, r) {
    t = a.apply([], t);
    var i,
      o,
      s,
      u,
      l,
      c,
      f = 0,
      p = e.length,
      d = p - 1,
      y = t[0],
      v = g(y);
    if (v || p > 1 && "string" == typeof y && !h.checkClone && je.test(y)) return e.each(function (i) {
      var o = e.eq(i);
      v && (t[0] = y.call(this, i, o.html())), Re(o, t, n, r);
    });
    if (p && (i = xe(t, e[0].ownerDocument, !1, e, r), o = i.firstChild, 1 === i.childNodes.length && (i = o), o || r)) {
      for (u = (s = w.map(ye(i, "script"), He)).length; f < p; f++) l = i, f !== d && (l = w.clone(l, !0, !0), u && w.merge(s, ye(l, "script"))), n.call(e[f], l, f);
      if (u) for (c = s[s.length - 1].ownerDocument, w.map(s, Oe), f = 0; f < u; f++) l = s[f], he.test(l.type || "") && !J.access(l, "globalEval") && w.contains(c, l) && (l.src && "module" !== (l.type || "").toLowerCase() ? w._evalUrl && w._evalUrl(l.src) : m(l.textContent.replace(qe, ""), c, l));
    }
    return e;
  }
  function Ie(e, t, n) {
    for (var r, i = t ? w.filter(t, e) : e, o = 0; null != (r = i[o]); o++) n || 1 !== r.nodeType || w.cleanData(ye(r)), r.parentNode && (n && w.contains(r.ownerDocument, r) && ve(ye(r, "script")), r.parentNode.removeChild(r));
    return e;
  }
  w.extend({
    htmlPrefilter: function (e) {
      return e.replace(Ne, "<$1></$2>");
    },
    clone: function (e, t, n) {
      var r,
        i,
        o,
        a,
        s = e.cloneNode(!0),
        u = w.contains(e.ownerDocument, e);
      if (!(h.noCloneChecked || 1 !== e.nodeType && 11 !== e.nodeType || w.isXMLDoc(e))) for (a = ye(s), r = 0, i = (o = ye(e)).length; r < i; r++) Me(o[r], a[r]);
      if (t) if (n) for (o = o || ye(e), a = a || ye(s), r = 0, i = o.length; r < i; r++) Pe(o[r], a[r]);else Pe(e, s);
      return (a = ye(s, "script")).length > 0 && ve(a, !u && ye(e, "script")), s;
    },
    cleanData: function (e) {
      for (var t, n, r, i = w.event.special, o = 0; void 0 !== (n = e[o]); o++) if (Y(n)) {
        if (t = n[J.expando]) {
          if (t.events) for (r in t.events) i[r] ? w.event.remove(n, r) : w.removeEvent(n, r, t.handle);
          n[J.expando] = void 0;
        }
        n[K.expando] && (n[K.expando] = void 0);
      }
    }
  }), w.fn.extend({
    detach: function (e) {
      return Ie(this, e, !0);
    },
    remove: function (e) {
      return Ie(this, e);
    },
    text: function (e) {
      return z(this, function (e) {
        return void 0 === e ? w.text(this) : this.empty().each(function () {
          1 !== this.nodeType && 11 !== this.nodeType && 9 !== this.nodeType || (this.textContent = e);
        });
      }, null, e, arguments.length);
    },
    append: function () {
      return Re(this, arguments, function (e) {
        1 !== this.nodeType && 11 !== this.nodeType && 9 !== this.nodeType || Le(this, e).appendChild(e);
      });
    },
    prepend: function () {
      return Re(this, arguments, function (e) {
        if (1 === this.nodeType || 11 === this.nodeType || 9 === this.nodeType) {
          var t = Le(this, e);
          t.insertBefore(e, t.firstChild);
        }
      });
    },
    before: function () {
      return Re(this, arguments, function (e) {
        this.parentNode && this.parentNode.insertBefore(e, this);
      });
    },
    after: function () {
      return Re(this, arguments, function (e) {
        this.parentNode && this.parentNode.insertBefore(e, this.nextSibling);
      });
    },
    empty: function () {
      for (var e, t = 0; null != (e = this[t]); t++) 1 === e.nodeType && (w.cleanData(ye(e, !1)), e.textContent = "");
      return this;
    },
    clone: function (e, t) {
      return e = null != e && e, t = null == t ? e : t, this.map(function () {
        return w.clone(this, e, t);
      });
    },
    html: function (e) {
      return z(this, function (e) {
        var t = this[0] || {},
          n = 0,
          r = this.length;
        if (void 0 === e && 1 === t.nodeType) return t.innerHTML;
        if ("string" == typeof e && !Ae.test(e) && !ge[(de.exec(e) || ["", ""])[1].toLowerCase()]) {
          e = w.htmlPrefilter(e);
          try {
            for (; n < r; n++) 1 === (t = this[n] || {}).nodeType && (w.cleanData(ye(t, !1)), t.innerHTML = e);
            t = 0;
          } catch (e) {}
        }
        t && this.empty().append(e);
      }, null, e, arguments.length);
    },
    replaceWith: function () {
      var e = [];
      return Re(this, arguments, function (t) {
        var n = this.parentNode;
        w.inArray(this, e) < 0 && (w.cleanData(ye(this)), n && n.replaceChild(t, this));
      }, e);
    }
  }), w.each({
    appendTo: "append",
    prependTo: "prepend",
    insertBefore: "before",
    insertAfter: "after",
    replaceAll: "replaceWith"
  }, function (e, t) {
    w.fn[e] = function (e) {
      for (var n, r = [], i = w(e), o = i.length - 1, a = 0; a <= o; a++) n = a === o ? this : this.clone(!0), w(i[a])[t](n), s.apply(r, n.get());
      return this.pushStack(r);
    };
  });
  var We = new RegExp("^(" + re + ")(?!px)[a-z%]+$", "i"),
    $e = function (t) {
      var n = t.ownerDocument.defaultView;
      return n && n.opener || (n = e), n.getComputedStyle(t);
    },
    Be = new RegExp(oe.join("|"), "i");
  !function () {
    function t() {
      if (c) {
        l.style.cssText = "position:absolute;left:-11111px;width:60px;margin-top:1px;padding:0;border:0", c.style.cssText = "position:relative;display:block;box-sizing:border-box;overflow:scroll;margin:auto;border:1px;padding:1px;width:60%;top:1%", be.appendChild(l).appendChild(c);
        var t = e.getComputedStyle(c);
        i = "1%" !== t.top, u = 12 === n(t.marginLeft), c.style.right = "60%", s = 36 === n(t.right), o = 36 === n(t.width), c.style.position = "absolute", a = 36 === c.offsetWidth || "absolute", be.removeChild(l), c = null;
      }
    }
    function n(e) {
      return Math.round(parseFloat(e));
    }
    var i,
      o,
      a,
      s,
      u,
      l = r.createElement("div"),
      c = r.createElement("div");
    c.style && (c.style.backgroundClip = "content-box", c.cloneNode(!0).style.backgroundClip = "", h.clearCloneStyle = "content-box" === c.style.backgroundClip, w.extend(h, {
      boxSizingReliable: function () {
        return t(), o;
      },
      pixelBoxStyles: function () {
        return t(), s;
      },
      pixelPosition: function () {
        return t(), i;
      },
      reliableMarginLeft: function () {
        return t(), u;
      },
      scrollboxSize: function () {
        return t(), a;
      }
    }));
  }();
  function Fe(e, t, n) {
    var r,
      i,
      o,
      a,
      s = e.style;
    return (n = n || $e(e)) && ("" !== (a = n.getPropertyValue(t) || n[t]) || w.contains(e.ownerDocument, e) || (a = w.style(e, t)), !h.pixelBoxStyles() && We.test(a) && Be.test(t) && (r = s.width, i = s.minWidth, o = s.maxWidth, s.minWidth = s.maxWidth = s.width = a, a = n.width, s.width = r, s.minWidth = i, s.maxWidth = o)), void 0 !== a ? a + "" : a;
  }
  function _e(e, t) {
    return {
      get: function () {
        if (!e()) return (this.get = t).apply(this, arguments);
        delete this.get;
      }
    };
  }
  var ze = /^(none|table(?!-c[ea]).+)/,
    Xe = /^--/,
    Ue = {
      position: "absolute",
      visibility: "hidden",
      display: "block"
    },
    Ve = {
      letterSpacing: "0",
      fontWeight: "400"
    },
    Ge = ["Webkit", "Moz", "ms"],
    Ye = r.createElement("div").style;
  function Qe(e) {
    if (e in Ye) return e;
    var t = e[0].toUpperCase() + e.slice(1),
      n = Ge.length;
    while (n--) if ((e = Ge[n] + t) in Ye) return e;
  }
  function Je(e) {
    var t = w.cssProps[e];
    return t || (t = w.cssProps[e] = Qe(e) || e), t;
  }
  function Ke(e, t, n) {
    var r = ie.exec(t);
    return r ? Math.max(0, r[2] - (n || 0)) + (r[3] || "px") : t;
  }
  function Ze(e, t, n, r, i, o) {
    var a = "width" === t ? 1 : 0,
      s = 0,
      u = 0;
    if (n === (r ? "border" : "content")) return 0;
    for (; a < 4; a += 2) "margin" === n && (u += w.css(e, n + oe[a], !0, i)), r ? ("content" === n && (u -= w.css(e, "padding" + oe[a], !0, i)), "margin" !== n && (u -= w.css(e, "border" + oe[a] + "Width", !0, i))) : (u += w.css(e, "padding" + oe[a], !0, i), "padding" !== n ? u += w.css(e, "border" + oe[a] + "Width", !0, i) : s += w.css(e, "border" + oe[a] + "Width", !0, i));
    return !r && o >= 0 && (u += Math.max(0, Math.ceil(e["offset" + t[0].toUpperCase() + t.slice(1)] - o - u - s - .5))), u;
  }
  function et(e, t, n) {
    var r = $e(e),
      i = Fe(e, t, r),
      o = "border-box" === w.css(e, "boxSizing", !1, r),
      a = o;
    if (We.test(i)) {
      if (!n) return i;
      i = "auto";
    }
    return a = a && (h.boxSizingReliable() || i === e.style[t]), ("auto" === i || !parseFloat(i) && "inline" === w.css(e, "display", !1, r)) && (i = e["offset" + t[0].toUpperCase() + t.slice(1)], a = !0), (i = parseFloat(i) || 0) + Ze(e, t, n || (o ? "border" : "content"), a, r, i) + "px";
  }
  w.extend({
    cssHooks: {
      opacity: {
        get: function (e, t) {
          if (t) {
            var n = Fe(e, "opacity");
            return "" === n ? "1" : n;
          }
        }
      }
    },
    cssNumber: {
      animationIterationCount: !0,
      columnCount: !0,
      fillOpacity: !0,
      flexGrow: !0,
      flexShrink: !0,
      fontWeight: !0,
      lineHeight: !0,
      opacity: !0,
      order: !0,
      orphans: !0,
      widows: !0,
      zIndex: !0,
      zoom: !0
    },
    cssProps: {},
    style: function (e, t, n, r) {
      if (e && 3 !== e.nodeType && 8 !== e.nodeType && e.style) {
        var i,
          o,
          a,
          s = G(t),
          u = Xe.test(t),
          l = e.style;
        if (u || (t = Je(s)), a = w.cssHooks[t] || w.cssHooks[s], void 0 === n) return a && "get" in a && void 0 !== (i = a.get(e, !1, r)) ? i : l[t];
        "string" == (o = typeof n) && (i = ie.exec(n)) && i[1] && (n = ue(e, t, i), o = "number"), null != n && n === n && ("number" === o && (n += i && i[3] || (w.cssNumber[s] ? "" : "px")), h.clearCloneStyle || "" !== n || 0 !== t.indexOf("background") || (l[t] = "inherit"), a && "set" in a && void 0 === (n = a.set(e, n, r)) || (u ? l.setProperty(t, n) : l[t] = n));
      }
    },
    css: function (e, t, n, r) {
      var i,
        o,
        a,
        s = G(t);
      return Xe.test(t) || (t = Je(s)), (a = w.cssHooks[t] || w.cssHooks[s]) && "get" in a && (i = a.get(e, !0, n)), void 0 === i && (i = Fe(e, t, r)), "normal" === i && t in Ve && (i = Ve[t]), "" === n || n ? (o = parseFloat(i), !0 === n || isFinite(o) ? o || 0 : i) : i;
    }
  }), w.each(["height", "width"], function (e, t) {
    w.cssHooks[t] = {
      get: function (e, n, r) {
        if (n) return !ze.test(w.css(e, "display")) || e.getClientRects().length && e.getBoundingClientRect().width ? et(e, t, r) : se(e, Ue, function () {
          return et(e, t, r);
        });
      },
      set: function (e, n, r) {
        var i,
          o = $e(e),
          a = "border-box" === w.css(e, "boxSizing", !1, o),
          s = r && Ze(e, t, r, a, o);
        return a && h.scrollboxSize() === o.position && (s -= Math.ceil(e["offset" + t[0].toUpperCase() + t.slice(1)] - parseFloat(o[t]) - Ze(e, t, "border", !1, o) - .5)), s && (i = ie.exec(n)) && "px" !== (i[3] || "px") && (e.style[t] = n, n = w.css(e, t)), Ke(e, n, s);
      }
    };
  }), w.cssHooks.marginLeft = _e(h.reliableMarginLeft, function (e, t) {
    if (t) return (parseFloat(Fe(e, "marginLeft")) || e.getBoundingClientRect().left - se(e, {
      marginLeft: 0
    }, function () {
      return e.getBoundingClientRect().left;
    })) + "px";
  }), w.each({
    margin: "",
    padding: "",
    border: "Width"
  }, function (e, t) {
    w.cssHooks[e + t] = {
      expand: function (n) {
        for (var r = 0, i = {}, o = "string" == typeof n ? n.split(" ") : [n]; r < 4; r++) i[e + oe[r] + t] = o[r] || o[r - 2] || o[0];
        return i;
      }
    }, "margin" !== e && (w.cssHooks[e + t].set = Ke);
  }), w.fn.extend({
    css: function (e, t) {
      return z(this, function (e, t, n) {
        var r,
          i,
          o = {},
          a = 0;
        if (Array.isArray(t)) {
          for (r = $e(e), i = t.length; a < i; a++) o[t[a]] = w.css(e, t[a], !1, r);
          return o;
        }
        return void 0 !== n ? w.style(e, t, n) : w.css(e, t);
      }, e, t, arguments.length > 1);
    }
  });
  function tt(e, t, n, r, i) {
    return new tt.prototype.init(e, t, n, r, i);
  }
  w.Tween = tt, tt.prototype = {
    constructor: tt,
    init: function (e, t, n, r, i, o) {
      this.elem = e, this.prop = n, this.easing = i || w.easing._default, this.options = t, this.start = this.now = this.cur(), this.end = r, this.unit = o || (w.cssNumber[n] ? "" : "px");
    },
    cur: function () {
      var e = tt.propHooks[this.prop];
      return e && e.get ? e.get(this) : tt.propHooks._default.get(this);
    },
    run: function (e) {
      var t,
        n = tt.propHooks[this.prop];
      return this.options.duration ? this.pos = t = w.easing[this.easing](e, this.options.duration * e, 0, 1, this.options.duration) : this.pos = t = e, this.now = (this.end - this.start) * t + this.start, this.options.step && this.options.step.call(this.elem, this.now, this), n && n.set ? n.set(this) : tt.propHooks._default.set(this), this;
    }
  }, tt.prototype.init.prototype = tt.prototype, tt.propHooks = {
    _default: {
      get: function (e) {
        var t;
        return 1 !== e.elem.nodeType || null != e.elem[e.prop] && null == e.elem.style[e.prop] ? e.elem[e.prop] : (t = w.css(e.elem, e.prop, "")) && "auto" !== t ? t : 0;
      },
      set: function (e) {
        w.fx.step[e.prop] ? w.fx.step[e.prop](e) : 1 !== e.elem.nodeType || null == e.elem.style[w.cssProps[e.prop]] && !w.cssHooks[e.prop] ? e.elem[e.prop] = e.now : w.style(e.elem, e.prop, e.now + e.unit);
      }
    }
  }, tt.propHooks.scrollTop = tt.propHooks.scrollLeft = {
    set: function (e) {
      e.elem.nodeType && e.elem.parentNode && (e.elem[e.prop] = e.now);
    }
  }, w.easing = {
    linear: function (e) {
      return e;
    },
    swing: function (e) {
      return .5 - Math.cos(e * Math.PI) / 2;
    },
    _default: "swing"
  }, w.fx = tt.prototype.init, w.fx.step = {};
  var nt,
    rt,
    it = /^(?:toggle|show|hide)$/,
    ot = /queueHooks$/;
  function at() {
    rt && (!1 === r.hidden && e.requestAnimationFrame ? e.requestAnimationFrame(at) : e.setTimeout(at, w.fx.interval), w.fx.tick());
  }
  function st() {
    return e.setTimeout(function () {
      nt = void 0;
    }), nt = Date.now();
  }
  function ut(e, t) {
    var n,
      r = 0,
      i = {
        height: e
      };
    for (t = t ? 1 : 0; r < 4; r += 2 - t) i["margin" + (n = oe[r])] = i["padding" + n] = e;
    return t && (i.opacity = i.width = e), i;
  }
  function lt(e, t, n) {
    for (var r, i = (pt.tweeners[t] || []).concat(pt.tweeners["*"]), o = 0, a = i.length; o < a; o++) if (r = i[o].call(n, t, e)) return r;
  }
  function ct(e, t, n) {
    var r,
      i,
      o,
      a,
      s,
      u,
      l,
      c,
      f = "width" in t || "height" in t,
      p = this,
      d = {},
      h = e.style,
      g = e.nodeType && ae(e),
      y = J.get(e, "fxshow");
    n.queue || (null == (a = w._queueHooks(e, "fx")).unqueued && (a.unqueued = 0, s = a.empty.fire, a.empty.fire = function () {
      a.unqueued || s();
    }), a.unqueued++, p.always(function () {
      p.always(function () {
        a.unqueued--, w.queue(e, "fx").length || a.empty.fire();
      });
    }));
    for (r in t) if (i = t[r], it.test(i)) {
      if (delete t[r], o = o || "toggle" === i, i === (g ? "hide" : "show")) {
        if ("show" !== i || !y || void 0 === y[r]) continue;
        g = !0;
      }
      d[r] = y && y[r] || w.style(e, r);
    }
    if ((u = !w.isEmptyObject(t)) || !w.isEmptyObject(d)) {
      f && 1 === e.nodeType && (n.overflow = [h.overflow, h.overflowX, h.overflowY], null == (l = y && y.display) && (l = J.get(e, "display")), "none" === (c = w.css(e, "display")) && (l ? c = l : (fe([e], !0), l = e.style.display || l, c = w.css(e, "display"), fe([e]))), ("inline" === c || "inline-block" === c && null != l) && "none" === w.css(e, "float") && (u || (p.done(function () {
        h.display = l;
      }), null == l && (c = h.display, l = "none" === c ? "" : c)), h.display = "inline-block")), n.overflow && (h.overflow = "hidden", p.always(function () {
        h.overflow = n.overflow[0], h.overflowX = n.overflow[1], h.overflowY = n.overflow[2];
      })), u = !1;
      for (r in d) u || (y ? "hidden" in y && (g = y.hidden) : y = J.access(e, "fxshow", {
        display: l
      }), o && (y.hidden = !g), g && fe([e], !0), p.done(function () {
        g || fe([e]), J.remove(e, "fxshow");
        for (r in d) w.style(e, r, d[r]);
      })), u = lt(g ? y[r] : 0, r, p), r in y || (y[r] = u.start, g && (u.end = u.start, u.start = 0));
    }
  }
  function ft(e, t) {
    var n, r, i, o, a;
    for (n in e) if (r = G(n), i = t[r], o = e[n], Array.isArray(o) && (i = o[1], o = e[n] = o[0]), n !== r && (e[r] = o, delete e[n]), (a = w.cssHooks[r]) && "expand" in a) {
      o = a.expand(o), delete e[r];
      for (n in o) n in e || (e[n] = o[n], t[n] = i);
    } else t[r] = i;
  }
  function pt(e, t, n) {
    var r,
      i,
      o = 0,
      a = pt.prefilters.length,
      s = w.Deferred().always(function () {
        delete u.elem;
      }),
      u = function () {
        if (i) return !1;
        for (var t = nt || st(), n = Math.max(0, l.startTime + l.duration - t), r = 1 - (n / l.duration || 0), o = 0, a = l.tweens.length; o < a; o++) l.tweens[o].run(r);
        return s.notifyWith(e, [l, r, n]), r < 1 && a ? n : (a || s.notifyWith(e, [l, 1, 0]), s.resolveWith(e, [l]), !1);
      },
      l = s.promise({
        elem: e,
        props: w.extend({}, t),
        opts: w.extend(!0, {
          specialEasing: {},
          easing: w.easing._default
        }, n),
        originalProperties: t,
        originalOptions: n,
        startTime: nt || st(),
        duration: n.duration,
        tweens: [],
        createTween: function (t, n) {
          var r = w.Tween(e, l.opts, t, n, l.opts.specialEasing[t] || l.opts.easing);
          return l.tweens.push(r), r;
        },
        stop: function (t) {
          var n = 0,
            r = t ? l.tweens.length : 0;
          if (i) return this;
          for (i = !0; n < r; n++) l.tweens[n].run(1);
          return t ? (s.notifyWith(e, [l, 1, 0]), s.resolveWith(e, [l, t])) : s.rejectWith(e, [l, t]), this;
        }
      }),
      c = l.props;
    for (ft(c, l.opts.specialEasing); o < a; o++) if (r = pt.prefilters[o].call(l, e, c, l.opts)) return g(r.stop) && (w._queueHooks(l.elem, l.opts.queue).stop = r.stop.bind(r)), r;
    return w.map(c, lt, l), g(l.opts.start) && l.opts.start.call(e, l), l.progress(l.opts.progress).done(l.opts.done, l.opts.complete).fail(l.opts.fail).always(l.opts.always), w.fx.timer(w.extend(u, {
      elem: e,
      anim: l,
      queue: l.opts.queue
    })), l;
  }
  w.Animation = w.extend(pt, {
    tweeners: {
      "*": [function (e, t) {
        var n = this.createTween(e, t);
        return ue(n.elem, e, ie.exec(t), n), n;
      }]
    },
    tweener: function (e, t) {
      g(e) ? (t = e, e = ["*"]) : e = e.match(M);
      for (var n, r = 0, i = e.length; r < i; r++) n = e[r], pt.tweeners[n] = pt.tweeners[n] || [], pt.tweeners[n].unshift(t);
    },
    prefilters: [ct],
    prefilter: function (e, t) {
      t ? pt.prefilters.unshift(e) : pt.prefilters.push(e);
    }
  }), w.speed = function (e, t, n) {
    var r = e && "object" == typeof e ? w.extend({}, e) : {
      complete: n || !n && t || g(e) && e,
      duration: e,
      easing: n && t || t && !g(t) && t
    };
    return w.fx.off ? r.duration = 0 : "number" != typeof r.duration && (r.duration in w.fx.speeds ? r.duration = w.fx.speeds[r.duration] : r.duration = w.fx.speeds._default), null != r.queue && !0 !== r.queue || (r.queue = "fx"), r.old = r.complete, r.complete = function () {
      g(r.old) && r.old.call(this), r.queue && w.dequeue(this, r.queue);
    }, r;
  }, w.fn.extend({
    fadeTo: function (e, t, n, r) {
      return this.filter(ae).css("opacity", 0).show().end().animate({
        opacity: t
      }, e, n, r);
    },
    animate: function (e, t, n, r) {
      var i = w.isEmptyObject(e),
        o = w.speed(t, n, r),
        a = function () {
          var t = pt(this, w.extend({}, e), o);
          (i || J.get(this, "finish")) && t.stop(!0);
        };
      return a.finish = a, i || !1 === o.queue ? this.each(a) : this.queue(o.queue, a);
    },
    stop: function (e, t, n) {
      var r = function (e) {
        var t = e.stop;
        delete e.stop, t(n);
      };
      return "string" != typeof e && (n = t, t = e, e = void 0), t && !1 !== e && this.queue(e || "fx", []), this.each(function () {
        var t = !0,
          i = null != e && e + "queueHooks",
          o = w.timers,
          a = J.get(this);
        if (i) a[i] && a[i].stop && r(a[i]);else for (i in a) a[i] && a[i].stop && ot.test(i) && r(a[i]);
        for (i = o.length; i--;) o[i].elem !== this || null != e && o[i].queue !== e || (o[i].anim.stop(n), t = !1, o.splice(i, 1));
        !t && n || w.dequeue(this, e);
      });
    },
    finish: function (e) {
      return !1 !== e && (e = e || "fx"), this.each(function () {
        var t,
          n = J.get(this),
          r = n[e + "queue"],
          i = n[e + "queueHooks"],
          o = w.timers,
          a = r ? r.length : 0;
        for (n.finish = !0, w.queue(this, e, []), i && i.stop && i.stop.call(this, !0), t = o.length; t--;) o[t].elem === this && o[t].queue === e && (o[t].anim.stop(!0), o.splice(t, 1));
        for (t = 0; t < a; t++) r[t] && r[t].finish && r[t].finish.call(this);
        delete n.finish;
      });
    }
  }), w.each(["toggle", "show", "hide"], function (e, t) {
    var n = w.fn[t];
    w.fn[t] = function (e, r, i) {
      return null == e || "boolean" == typeof e ? n.apply(this, arguments) : this.animate(ut(t, !0), e, r, i);
    };
  }), w.each({
    slideDown: ut("show"),
    slideUp: ut("hide"),
    slideToggle: ut("toggle"),
    fadeIn: {
      opacity: "show"
    },
    fadeOut: {
      opacity: "hide"
    },
    fadeToggle: {
      opacity: "toggle"
    }
  }, function (e, t) {
    w.fn[e] = function (e, n, r) {
      return this.animate(t, e, n, r);
    };
  }), w.timers = [], w.fx.tick = function () {
    var e,
      t = 0,
      n = w.timers;
    for (nt = Date.now(); t < n.length; t++) (e = n[t])() || n[t] !== e || n.splice(t--, 1);
    n.length || w.fx.stop(), nt = void 0;
  }, w.fx.timer = function (e) {
    w.timers.push(e), w.fx.start();
  }, w.fx.interval = 13, w.fx.start = function () {
    rt || (rt = !0, at());
  }, w.fx.stop = function () {
    rt = null;
  }, w.fx.speeds = {
    slow: 600,
    fast: 200,
    _default: 400
  }, w.fn.delay = function (t, n) {
    return t = w.fx ? w.fx.speeds[t] || t : t, n = n || "fx", this.queue(n, function (n, r) {
      var i = e.setTimeout(n, t);
      r.stop = function () {
        e.clearTimeout(i);
      };
    });
  }, function () {
    var e = r.createElement("input"),
      t = r.createElement("select").appendChild(r.createElement("option"));
    e.type = "checkbox", h.checkOn = "" !== e.value, h.optSelected = t.selected, (e = r.createElement("input")).value = "t", e.type = "radio", h.radioValue = "t" === e.value;
  }();
  var dt,
    ht = w.expr.attrHandle;
  w.fn.extend({
    attr: function (e, t) {
      return z(this, w.attr, e, t, arguments.length > 1);
    },
    removeAttr: function (e) {
      return this.each(function () {
        w.removeAttr(this, e);
      });
    }
  }), w.extend({
    attr: function (e, t, n) {
      var r,
        i,
        o = e.nodeType;
      if (3 !== o && 8 !== o && 2 !== o) return "undefined" == typeof e.getAttribute ? w.prop(e, t, n) : (1 === o && w.isXMLDoc(e) || (i = w.attrHooks[t.toLowerCase()] || (w.expr.match.bool.test(t) ? dt : void 0)), void 0 !== n ? null === n ? void w.removeAttr(e, t) : i && "set" in i && void 0 !== (r = i.set(e, n, t)) ? r : (e.setAttribute(t, n + ""), n) : i && "get" in i && null !== (r = i.get(e, t)) ? r : null == (r = w.find.attr(e, t)) ? void 0 : r);
    },
    attrHooks: {
      type: {
        set: function (e, t) {
          if (!h.radioValue && "radio" === t && N(e, "input")) {
            var n = e.value;
            return e.setAttribute("type", t), n && (e.value = n), t;
          }
        }
      }
    },
    removeAttr: function (e, t) {
      var n,
        r = 0,
        i = t && t.match(M);
      if (i && 1 === e.nodeType) while (n = i[r++]) e.removeAttribute(n);
    }
  }), dt = {
    set: function (e, t, n) {
      return !1 === t ? w.removeAttr(e, n) : e.setAttribute(n, n), n;
    }
  }, w.each(w.expr.match.bool.source.match(/\w+/g), function (e, t) {
    var n = ht[t] || w.find.attr;
    ht[t] = function (e, t, r) {
      var i,
        o,
        a = t.toLowerCase();
      return r || (o = ht[a], ht[a] = i, i = null != n(e, t, r) ? a : null, ht[a] = o), i;
    };
  });
  var gt = /^(?:input|select|textarea|button)$/i,
    yt = /^(?:a|area)$/i;
  w.fn.extend({
    prop: function (e, t) {
      return z(this, w.prop, e, t, arguments.length > 1);
    },
    removeProp: function (e) {
      return this.each(function () {
        delete this[w.propFix[e] || e];
      });
    }
  }), w.extend({
    prop: function (e, t, n) {
      var r,
        i,
        o = e.nodeType;
      if (3 !== o && 8 !== o && 2 !== o) return 1 === o && w.isXMLDoc(e) || (t = w.propFix[t] || t, i = w.propHooks[t]), void 0 !== n ? i && "set" in i && void 0 !== (r = i.set(e, n, t)) ? r : e[t] = n : i && "get" in i && null !== (r = i.get(e, t)) ? r : e[t];
    },
    propHooks: {
      tabIndex: {
        get: function (e) {
          var t = w.find.attr(e, "tabindex");
          return t ? parseInt(t, 10) : gt.test(e.nodeName) || yt.test(e.nodeName) && e.href ? 0 : -1;
        }
      }
    },
    propFix: {
      "for": "htmlFor",
      "class": "className"
    }
  }), h.optSelected || (w.propHooks.selected = {
    get: function (e) {
      var t = e.parentNode;
      return t && t.parentNode && t.parentNode.selectedIndex, null;
    },
    set: function (e) {
      var t = e.parentNode;
      t && (t.selectedIndex, t.parentNode && t.parentNode.selectedIndex);
    }
  }), w.each(["tabIndex", "readOnly", "maxLength", "cellSpacing", "cellPadding", "rowSpan", "colSpan", "useMap", "frameBorder", "contentEditable"], function () {
    w.propFix[this.toLowerCase()] = this;
  });
  function vt(e) {
    return (e.match(M) || []).join(" ");
  }
  function mt(e) {
    return e.getAttribute && e.getAttribute("class") || "";
  }
  function xt(e) {
    return Array.isArray(e) ? e : "string" == typeof e ? e.match(M) || [] : [];
  }
  w.fn.extend({
    addClass: function (e) {
      var t,
        n,
        r,
        i,
        o,
        a,
        s,
        u = 0;
      if (g(e)) return this.each(function (t) {
        w(this).addClass(e.call(this, t, mt(this)));
      });
      if ((t = xt(e)).length) while (n = this[u++]) if (i = mt(n), r = 1 === n.nodeType && " " + vt(i) + " ") {
        a = 0;
        while (o = t[a++]) r.indexOf(" " + o + " ") < 0 && (r += o + " ");
        i !== (s = vt(r)) && n.setAttribute("class", s);
      }
      return this;
    },
    removeClass: function (e) {
      var t,
        n,
        r,
        i,
        o,
        a,
        s,
        u = 0;
      if (g(e)) return this.each(function (t) {
        w(this).removeClass(e.call(this, t, mt(this)));
      });
      if (!arguments.length) return this.attr("class", "");
      if ((t = xt(e)).length) while (n = this[u++]) if (i = mt(n), r = 1 === n.nodeType && " " + vt(i) + " ") {
        a = 0;
        while (o = t[a++]) while (r.indexOf(" " + o + " ") > -1) r = r.replace(" " + o + " ", " ");
        i !== (s = vt(r)) && n.setAttribute("class", s);
      }
      return this;
    },
    toggleClass: function (e, t) {
      var n = typeof e,
        r = "string" === n || Array.isArray(e);
      return "boolean" == typeof t && r ? t ? this.addClass(e) : this.removeClass(e) : g(e) ? this.each(function (n) {
        w(this).toggleClass(e.call(this, n, mt(this), t), t);
      }) : this.each(function () {
        var t, i, o, a;
        if (r) {
          i = 0, o = w(this), a = xt(e);
          while (t = a[i++]) o.hasClass(t) ? o.removeClass(t) : o.addClass(t);
        } else void 0 !== e && "boolean" !== n || ((t = mt(this)) && J.set(this, "__className__", t), this.setAttribute && this.setAttribute("class", t || !1 === e ? "" : J.get(this, "__className__") || ""));
      });
    },
    hasClass: function (e) {
      var t,
        n,
        r = 0;
      t = " " + e + " ";
      while (n = this[r++]) if (1 === n.nodeType && (" " + vt(mt(n)) + " ").indexOf(t) > -1) return !0;
      return !1;
    }
  });
  var bt = /\r/g;
  w.fn.extend({
    val: function (e) {
      var t,
        n,
        r,
        i = this[0];
      {
        if (arguments.length) return r = g(e), this.each(function (n) {
          var i;
          1 === this.nodeType && (null == (i = r ? e.call(this, n, w(this).val()) : e) ? i = "" : "number" == typeof i ? i += "" : Array.isArray(i) && (i = w.map(i, function (e) {
            return null == e ? "" : e + "";
          })), (t = w.valHooks[this.type] || w.valHooks[this.nodeName.toLowerCase()]) && "set" in t && void 0 !== t.set(this, i, "value") || (this.value = i));
        });
        if (i) return (t = w.valHooks[i.type] || w.valHooks[i.nodeName.toLowerCase()]) && "get" in t && void 0 !== (n = t.get(i, "value")) ? n : "string" == typeof (n = i.value) ? n.replace(bt, "") : null == n ? "" : n;
      }
    }
  }), w.extend({
    valHooks: {
      option: {
        get: function (e) {
          var t = w.find.attr(e, "value");
          return null != t ? t : vt(w.text(e));
        }
      },
      select: {
        get: function (e) {
          var t,
            n,
            r,
            i = e.options,
            o = e.selectedIndex,
            a = "select-one" === e.type,
            s = a ? null : [],
            u = a ? o + 1 : i.length;
          for (r = o < 0 ? u : a ? o : 0; r < u; r++) if (((n = i[r]).selected || r === o) && !n.disabled && (!n.parentNode.disabled || !N(n.parentNode, "optgroup"))) {
            if (t = w(n).val(), a) return t;
            s.push(t);
          }
          return s;
        },
        set: function (e, t) {
          var n,
            r,
            i = e.options,
            o = w.makeArray(t),
            a = i.length;
          while (a--) ((r = i[a]).selected = w.inArray(w.valHooks.option.get(r), o) > -1) && (n = !0);
          return n || (e.selectedIndex = -1), o;
        }
      }
    }
  }), w.each(["radio", "checkbox"], function () {
    w.valHooks[this] = {
      set: function (e, t) {
        if (Array.isArray(t)) return e.checked = w.inArray(w(e).val(), t) > -1;
      }
    }, h.checkOn || (w.valHooks[this].get = function (e) {
      return null === e.getAttribute("value") ? "on" : e.value;
    });
  }), h.focusin = "onfocusin" in e;
  var wt = /^(?:focusinfocus|focusoutblur)$/,
    Tt = function (e) {
      e.stopPropagation();
    };
  w.extend(w.event, {
    trigger: function (t, n, i, o) {
      var a,
        s,
        u,
        l,
        c,
        p,
        d,
        h,
        v = [i || r],
        m = f.call(t, "type") ? t.type : t,
        x = f.call(t, "namespace") ? t.namespace.split(".") : [];
      if (s = h = u = i = i || r, 3 !== i.nodeType && 8 !== i.nodeType && !wt.test(m + w.event.triggered) && (m.indexOf(".") > -1 && (m = (x = m.split(".")).shift(), x.sort()), c = m.indexOf(":") < 0 && "on" + m, t = t[w.expando] ? t : new w.Event(m, "object" == typeof t && t), t.isTrigger = o ? 2 : 3, t.namespace = x.join("."), t.rnamespace = t.namespace ? new RegExp("(^|\\.)" + x.join("\\.(?:.*\\.|)") + "(\\.|$)") : null, t.result = void 0, t.target || (t.target = i), n = null == n ? [t] : w.makeArray(n, [t]), d = w.event.special[m] || {}, o || !d.trigger || !1 !== d.trigger.apply(i, n))) {
        if (!o && !d.noBubble && !y(i)) {
          for (l = d.delegateType || m, wt.test(l + m) || (s = s.parentNode); s; s = s.parentNode) v.push(s), u = s;
          u === (i.ownerDocument || r) && v.push(u.defaultView || u.parentWindow || e);
        }
        a = 0;
        while ((s = v[a++]) && !t.isPropagationStopped()) h = s, t.type = a > 1 ? l : d.bindType || m, (p = (J.get(s, "events") || {})[t.type] && J.get(s, "handle")) && p.apply(s, n), (p = c && s[c]) && p.apply && Y(s) && (t.result = p.apply(s, n), !1 === t.result && t.preventDefault());
        return t.type = m, o || t.isDefaultPrevented() || d._default && !1 !== d._default.apply(v.pop(), n) || !Y(i) || c && g(i[m]) && !y(i) && ((u = i[c]) && (i[c] = null), w.event.triggered = m, t.isPropagationStopped() && h.addEventListener(m, Tt), i[m](), t.isPropagationStopped() && h.removeEventListener(m, Tt), w.event.triggered = void 0, u && (i[c] = u)), t.result;
      }
    },
    simulate: function (e, t, n) {
      var r = w.extend(new w.Event(), n, {
        type: e,
        isSimulated: !0
      });
      w.event.trigger(r, null, t);
    }
  }), w.fn.extend({
    trigger: function (e, t) {
      return this.each(function () {
        w.event.trigger(e, t, this);
      });
    },
    triggerHandler: function (e, t) {
      var n = this[0];
      if (n) return w.event.trigger(e, t, n, !0);
    }
  }), h.focusin || w.each({
    focus: "focusin",
    blur: "focusout"
  }, function (e, t) {
    var n = function (e) {
      w.event.simulate(t, e.target, w.event.fix(e));
    };
    w.event.special[t] = {
      setup: function () {
        var r = this.ownerDocument || this,
          i = J.access(r, t);
        i || r.addEventListener(e, n, !0), J.access(r, t, (i || 0) + 1);
      },
      teardown: function () {
        var r = this.ownerDocument || this,
          i = J.access(r, t) - 1;
        i ? J.access(r, t, i) : (r.removeEventListener(e, n, !0), J.remove(r, t));
      }
    };
  });
  var Ct = e.location,
    Et = Date.now(),
    kt = /\?/;
  w.parseXML = function (t) {
    var n;
    if (!t || "string" != typeof t) return null;
    try {
      n = new e.DOMParser().parseFromString(t, "text/xml");
    } catch (e) {
      n = void 0;
    }
    return n && !n.getElementsByTagName("parsererror").length || w.error("Invalid XML: " + t), n;
  };
  var St = /\[\]$/,
    Dt = /\r?\n/g,
    Nt = /^(?:submit|button|image|reset|file)$/i,
    At = /^(?:input|select|textarea|keygen)/i;
  function jt(e, t, n, r) {
    var i;
    if (Array.isArray(t)) w.each(t, function (t, i) {
      n || St.test(e) ? r(e, i) : jt(e + "[" + ("object" == typeof i && null != i ? t : "") + "]", i, n, r);
    });else if (n || "object" !== x(t)) r(e, t);else for (i in t) jt(e + "[" + i + "]", t[i], n, r);
  }
  w.param = function (e, t) {
    var n,
      r = [],
      i = function (e, t) {
        var n = g(t) ? t() : t;
        r[r.length] = encodeURIComponent(e) + "=" + encodeURIComponent(null == n ? "" : n);
      };
    if (Array.isArray(e) || e.jquery && !w.isPlainObject(e)) w.each(e, function () {
      i(this.name, this.value);
    });else for (n in e) jt(n, e[n], t, i);
    return r.join("&");
  }, w.fn.extend({
    serialize: function () {
      return w.param(this.serializeArray());
    },
    serializeArray: function () {
      return this.map(function () {
        var e = w.prop(this, "elements");
        return e ? w.makeArray(e) : this;
      }).filter(function () {
        var e = this.type;
        return this.name && !w(this).is(":disabled") && At.test(this.nodeName) && !Nt.test(e) && (this.checked || !pe.test(e));
      }).map(function (e, t) {
        var n = w(this).val();
        return null == n ? null : Array.isArray(n) ? w.map(n, function (e) {
          return {
            name: t.name,
            value: e.replace(Dt, "\r\n")
          };
        }) : {
          name: t.name,
          value: n.replace(Dt, "\r\n")
        };
      }).get();
    }
  });
  var qt = /%20/g,
    Lt = /#.*$/,
    Ht = /([?&])_=[^&]*/,
    Ot = /^(.*?):[ \t]*([^\r\n]*)$/gm,
    Pt = /^(?:about|app|app-storage|.+-extension|file|res|widget):$/,
    Mt = /^(?:GET|HEAD)$/,
    Rt = /^\/\//,
    It = {},
    Wt = {},
    $t = "*/".concat("*"),
    Bt = r.createElement("a");
  Bt.href = Ct.href;
  function Ft(e) {
    return function (t, n) {
      "string" != typeof t && (n = t, t = "*");
      var r,
        i = 0,
        o = t.toLowerCase().match(M) || [];
      if (g(n)) while (r = o[i++]) "+" === r[0] ? (r = r.slice(1) || "*", (e[r] = e[r] || []).unshift(n)) : (e[r] = e[r] || []).push(n);
    };
  }
  function _t(e, t, n, r) {
    var i = {},
      o = e === Wt;
    function a(s) {
      var u;
      return i[s] = !0, w.each(e[s] || [], function (e, s) {
        var l = s(t, n, r);
        return "string" != typeof l || o || i[l] ? o ? !(u = l) : void 0 : (t.dataTypes.unshift(l), a(l), !1);
      }), u;
    }
    return a(t.dataTypes[0]) || !i["*"] && a("*");
  }
  function zt(e, t) {
    var n,
      r,
      i = w.ajaxSettings.flatOptions || {};
    for (n in t) void 0 !== t[n] && ((i[n] ? e : r || (r = {}))[n] = t[n]);
    return r && w.extend(!0, e, r), e;
  }
  function Xt(e, t, n) {
    var r,
      i,
      o,
      a,
      s = e.contents,
      u = e.dataTypes;
    while ("*" === u[0]) u.shift(), void 0 === r && (r = e.mimeType || t.getResponseHeader("Content-Type"));
    if (r) for (i in s) if (s[i] && s[i].test(r)) {
      u.unshift(i);
      break;
    }
    if (u[0] in n) o = u[0];else {
      for (i in n) {
        if (!u[0] || e.converters[i + " " + u[0]]) {
          o = i;
          break;
        }
        a || (a = i);
      }
      o = o || a;
    }
    if (o) return o !== u[0] && u.unshift(o), n[o];
  }
  function Ut(e, t, n, r) {
    var i,
      o,
      a,
      s,
      u,
      l = {},
      c = e.dataTypes.slice();
    if (c[1]) for (a in e.converters) l[a.toLowerCase()] = e.converters[a];
    o = c.shift();
    while (o) if (e.responseFields[o] && (n[e.responseFields[o]] = t), !u && r && e.dataFilter && (t = e.dataFilter(t, e.dataType)), u = o, o = c.shift()) if ("*" === o) o = u;else if ("*" !== u && u !== o) {
      if (!(a = l[u + " " + o] || l["* " + o])) for (i in l) if ((s = i.split(" "))[1] === o && (a = l[u + " " + s[0]] || l["* " + s[0]])) {
        !0 === a ? a = l[i] : !0 !== l[i] && (o = s[0], c.unshift(s[1]));
        break;
      }
      if (!0 !== a) if (a && e["throws"]) t = a(t);else try {
        t = a(t);
      } catch (e) {
        return {
          state: "parsererror",
          error: a ? e : "No conversion from " + u + " to " + o
        };
      }
    }
    return {
      state: "success",
      data: t
    };
  }
  w.extend({
    active: 0,
    lastModified: {},
    etag: {},
    ajaxSettings: {
      url: Ct.href,
      type: "GET",
      isLocal: Pt.test(Ct.protocol),
      global: !0,
      processData: !0,
      async: !0,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      accepts: {
        "*": $t,
        text: "text/plain",
        html: "text/html",
        xml: "application/xml, text/xml",
        json: "application/json, text/javascript"
      },
      contents: {
        xml: /\bxml\b/,
        html: /\bhtml/,
        json: /\bjson\b/
      },
      responseFields: {
        xml: "responseXML",
        text: "responseText",
        json: "responseJSON"
      },
      converters: {
        "* text": String,
        "text html": !0,
        "text json": JSON.parse,
        "text xml": w.parseXML
      },
      flatOptions: {
        url: !0,
        context: !0
      }
    },
    ajaxSetup: function (e, t) {
      return t ? zt(zt(e, w.ajaxSettings), t) : zt(w.ajaxSettings, e);
    },
    ajaxPrefilter: Ft(It),
    ajaxTransport: Ft(Wt),
    ajax: function (t, n) {
      "object" == typeof t && (n = t, t = void 0), n = n || {};
      var i,
        o,
        a,
        s,
        u,
        l,
        c,
        f,
        p,
        d,
        h = w.ajaxSetup({}, n),
        g = h.context || h,
        y = h.context && (g.nodeType || g.jquery) ? w(g) : w.event,
        v = w.Deferred(),
        m = w.Callbacks("once memory"),
        x = h.statusCode || {},
        b = {},
        T = {},
        C = "canceled",
        E = {
          readyState: 0,
          getResponseHeader: function (e) {
            var t;
            if (c) {
              if (!s) {
                s = {};
                while (t = Ot.exec(a)) s[t[1].toLowerCase()] = t[2];
              }
              t = s[e.toLowerCase()];
            }
            return null == t ? null : t;
          },
          getAllResponseHeaders: function () {
            return c ? a : null;
          },
          setRequestHeader: function (e, t) {
            return null == c && (e = T[e.toLowerCase()] = T[e.toLowerCase()] || e, b[e] = t), this;
          },
          overrideMimeType: function (e) {
            return null == c && (h.mimeType = e), this;
          },
          statusCode: function (e) {
            var t;
            if (e) if (c) E.always(e[E.status]);else for (t in e) x[t] = [x[t], e[t]];
            return this;
          },
          abort: function (e) {
            var t = e || C;
            return i && i.abort(t), k(0, t), this;
          }
        };
      if (v.promise(E), h.url = ((t || h.url || Ct.href) + "").replace(Rt, Ct.protocol + "//"), h.type = n.method || n.type || h.method || h.type, h.dataTypes = (h.dataType || "*").toLowerCase().match(M) || [""], null == h.crossDomain) {
        l = r.createElement("a");
        try {
          l.href = h.url, l.href = l.href, h.crossDomain = Bt.protocol + "//" + Bt.host != l.protocol + "//" + l.host;
        } catch (e) {
          h.crossDomain = !0;
        }
      }
      if (h.data && h.processData && "string" != typeof h.data && (h.data = w.param(h.data, h.traditional)), _t(It, h, n, E), c) return E;
      (f = w.event && h.global) && 0 == w.active++ && w.event.trigger("ajaxStart"), h.type = h.type.toUpperCase(), h.hasContent = !Mt.test(h.type), o = h.url.replace(Lt, ""), h.hasContent ? h.data && h.processData && 0 === (h.contentType || "").indexOf("application/x-www-form-urlencoded") && (h.data = h.data.replace(qt, "+")) : (d = h.url.slice(o.length), h.data && (h.processData || "string" == typeof h.data) && (o += (kt.test(o) ? "&" : "?") + h.data, delete h.data), !1 === h.cache && (o = o.replace(Ht, "$1"), d = (kt.test(o) ? "&" : "?") + "_=" + Et++ + d), h.url = o + d), h.ifModified && (w.lastModified[o] && E.setRequestHeader("If-Modified-Since", w.lastModified[o]), w.etag[o] && E.setRequestHeader("If-None-Match", w.etag[o])), (h.data && h.hasContent && !1 !== h.contentType || n.contentType) && E.setRequestHeader("Content-Type", h.contentType), E.setRequestHeader("Accept", h.dataTypes[0] && h.accepts[h.dataTypes[0]] ? h.accepts[h.dataTypes[0]] + ("*" !== h.dataTypes[0] ? ", " + $t + "; q=0.01" : "") : h.accepts["*"]);
      for (p in h.headers) E.setRequestHeader(p, h.headers[p]);
      if (h.beforeSend && (!1 === h.beforeSend.call(g, E, h) || c)) return E.abort();
      if (C = "abort", m.add(h.complete), E.done(h.success), E.fail(h.error), i = _t(Wt, h, n, E)) {
        if (E.readyState = 1, f && y.trigger("ajaxSend", [E, h]), c) return E;
        h.async && h.timeout > 0 && (u = e.setTimeout(function () {
          E.abort("timeout");
        }, h.timeout));
        try {
          c = !1, i.send(b, k);
        } catch (e) {
          if (c) throw e;
          k(-1, e);
        }
      } else k(-1, "No Transport");
      function k(t, n, r, s) {
        var l,
          p,
          d,
          b,
          T,
          C = n;
        c || (c = !0, u && e.clearTimeout(u), i = void 0, a = s || "", E.readyState = t > 0 ? 4 : 0, l = t >= 200 && t < 300 || 304 === t, r && (b = Xt(h, E, r)), b = Ut(h, b, E, l), l ? (h.ifModified && ((T = E.getResponseHeader("Last-Modified")) && (w.lastModified[o] = T), (T = E.getResponseHeader("etag")) && (w.etag[o] = T)), 204 === t || "HEAD" === h.type ? C = "nocontent" : 304 === t ? C = "notmodified" : (C = b.state, p = b.data, l = !(d = b.error))) : (d = C, !t && C || (C = "error", t < 0 && (t = 0))), E.status = t, E.statusText = (n || C) + "", l ? v.resolveWith(g, [p, C, E]) : v.rejectWith(g, [E, C, d]), E.statusCode(x), x = void 0, f && y.trigger(l ? "ajaxSuccess" : "ajaxError", [E, h, l ? p : d]), m.fireWith(g, [E, C]), f && (y.trigger("ajaxComplete", [E, h]), --w.active || w.event.trigger("ajaxStop")));
      }
      return E;
    },
    getJSON: function (e, t, n) {
      return w.get(e, t, n, "json");
    },
    getScript: function (e, t) {
      return w.get(e, void 0, t, "script");
    }
  }), w.each(["get", "post"], function (e, t) {
    w[t] = function (e, n, r, i) {
      return g(n) && (i = i || r, r = n, n = void 0), w.ajax(w.extend({
        url: e,
        type: t,
        dataType: i,
        data: n,
        success: r
      }, w.isPlainObject(e) && e));
    };
  }), w._evalUrl = function (e) {
    return w.ajax({
      url: e,
      type: "GET",
      dataType: "script",
      cache: !0,
      async: !1,
      global: !1,
      "throws": !0
    });
  }, w.fn.extend({
    wrapAll: function (e) {
      var t;
      return this[0] && (g(e) && (e = e.call(this[0])), t = w(e, this[0].ownerDocument).eq(0).clone(!0), this[0].parentNode && t.insertBefore(this[0]), t.map(function () {
        var e = this;
        while (e.firstElementChild) e = e.firstElementChild;
        return e;
      }).append(this)), this;
    },
    wrapInner: function (e) {
      return g(e) ? this.each(function (t) {
        w(this).wrapInner(e.call(this, t));
      }) : this.each(function () {
        var t = w(this),
          n = t.contents();
        n.length ? n.wrapAll(e) : t.append(e);
      });
    },
    wrap: function (e) {
      var t = g(e);
      return this.each(function (n) {
        w(this).wrapAll(t ? e.call(this, n) : e);
      });
    },
    unwrap: function (e) {
      return this.parent(e).not("body").each(function () {
        w(this).replaceWith(this.childNodes);
      }), this;
    }
  }), w.expr.pseudos.hidden = function (e) {
    return !w.expr.pseudos.visible(e);
  }, w.expr.pseudos.visible = function (e) {
    return !!(e.offsetWidth || e.offsetHeight || e.getClientRects().length);
  }, w.ajaxSettings.xhr = function () {
    try {
      return new e.XMLHttpRequest();
    } catch (e) {}
  };
  var Vt = {
      0: 200,
      1223: 204
    },
    Gt = w.ajaxSettings.xhr();
  h.cors = !!Gt && "withCredentials" in Gt, h.ajax = Gt = !!Gt, w.ajaxTransport(function (t) {
    var n, r;
    if (h.cors || Gt && !t.crossDomain) return {
      send: function (i, o) {
        var a,
          s = t.xhr();
        if (s.open(t.type, t.url, t.async, t.username, t.password), t.xhrFields) for (a in t.xhrFields) s[a] = t.xhrFields[a];
        t.mimeType && s.overrideMimeType && s.overrideMimeType(t.mimeType), t.crossDomain || i["X-Requested-With"] || (i["X-Requested-With"] = "XMLHttpRequest");
        for (a in i) s.setRequestHeader(a, i[a]);
        n = function (e) {
          return function () {
            n && (n = r = s.onload = s.onerror = s.onabort = s.ontimeout = s.onreadystatechange = null, "abort" === e ? s.abort() : "error" === e ? "number" != typeof s.status ? o(0, "error") : o(s.status, s.statusText) : o(Vt[s.status] || s.status, s.statusText, "text" !== (s.responseType || "text") || "string" != typeof s.responseText ? {
              binary: s.response
            } : {
              text: s.responseText
            }, s.getAllResponseHeaders()));
          };
        }, s.onload = n(), r = s.onerror = s.ontimeout = n("error"), void 0 !== s.onabort ? s.onabort = r : s.onreadystatechange = function () {
          4 === s.readyState && e.setTimeout(function () {
            n && r();
          });
        }, n = n("abort");
        try {
          s.send(t.hasContent && t.data || null);
        } catch (e) {
          if (n) throw e;
        }
      },
      abort: function () {
        n && n();
      }
    };
  }), w.ajaxPrefilter(function (e) {
    e.crossDomain && (e.contents.script = !1);
  }), w.ajaxSetup({
    accepts: {
      script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"
    },
    contents: {
      script: /\b(?:java|ecma)script\b/
    },
    converters: {
      "text script": function (e) {
        return w.globalEval(e), e;
      }
    }
  }), w.ajaxPrefilter("script", function (e) {
    void 0 === e.cache && (e.cache = !1), e.crossDomain && (e.type = "GET");
  }), w.ajaxTransport("script", function (e) {
    if (e.crossDomain) {
      var t, n;
      return {
        send: function (i, o) {
          t = w("<script>").prop({
            charset: e.scriptCharset,
            src: e.url
          }).on("load error", n = function (e) {
            t.remove(), n = null, e && o("error" === e.type ? 404 : 200, e.type);
          }), r.head.appendChild(t[0]);
        },
        abort: function () {
          n && n();
        }
      };
    }
  });
  var Yt = [],
    Qt = /(=)\?(?=&|$)|\?\?/;
  w.ajaxSetup({
    jsonp: "callback",
    jsonpCallback: function () {
      var e = Yt.pop() || w.expando + "_" + Et++;
      return this[e] = !0, e;
    }
  }), w.ajaxPrefilter("json jsonp", function (t, n, r) {
    var i,
      o,
      a,
      s = !1 !== t.jsonp && (Qt.test(t.url) ? "url" : "string" == typeof t.data && 0 === (t.contentType || "").indexOf("application/x-www-form-urlencoded") && Qt.test(t.data) && "data");
    if (s || "jsonp" === t.dataTypes[0]) return i = t.jsonpCallback = g(t.jsonpCallback) ? t.jsonpCallback() : t.jsonpCallback, s ? t[s] = t[s].replace(Qt, "$1" + i) : !1 !== t.jsonp && (t.url += (kt.test(t.url) ? "&" : "?") + t.jsonp + "=" + i), t.converters["script json"] = function () {
      return a || w.error(i + " was not called"), a[0];
    }, t.dataTypes[0] = "json", o = e[i], e[i] = function () {
      a = arguments;
    }, r.always(function () {
      void 0 === o ? w(e).removeProp(i) : e[i] = o, t[i] && (t.jsonpCallback = n.jsonpCallback, Yt.push(i)), a && g(o) && o(a[0]), a = o = void 0;
    }), "script";
  }), h.createHTMLDocument = function () {
    var e = r.implementation.createHTMLDocument("").body;
    return e.innerHTML = "<form></form><form></form>", 2 === e.childNodes.length;
  }(), w.parseHTML = function (e, t, n) {
    if ("string" != typeof e) return [];
    "boolean" == typeof t && (n = t, t = !1);
    var i, o, a;
    return t || (h.createHTMLDocument ? ((i = (t = r.implementation.createHTMLDocument("")).createElement("base")).href = r.location.href, t.head.appendChild(i)) : t = r), o = A.exec(e), a = !n && [], o ? [t.createElement(o[1])] : (o = xe([e], t, a), a && a.length && w(a).remove(), w.merge([], o.childNodes));
  }, w.fn.load = function (e, t, n) {
    var r,
      i,
      o,
      a = this,
      s = e.indexOf(" ");
    return s > -1 && (r = vt(e.slice(s)), e = e.slice(0, s)), g(t) ? (n = t, t = void 0) : t && "object" == typeof t && (i = "POST"), a.length > 0 && w.ajax({
      url: e,
      type: i || "GET",
      dataType: "html",
      data: t
    }).done(function (e) {
      o = arguments, a.html(r ? w("<div>").append(w.parseHTML(e)).find(r) : e);
    }).always(n && function (e, t) {
      a.each(function () {
        n.apply(this, o || [e.responseText, t, e]);
      });
    }), this;
  }, w.each(["ajaxStart", "ajaxStop", "ajaxComplete", "ajaxError", "ajaxSuccess", "ajaxSend"], function (e, t) {
    w.fn[t] = function (e) {
      return this.on(t, e);
    };
  }), w.expr.pseudos.animated = function (e) {
    return w.grep(w.timers, function (t) {
      return e === t.elem;
    }).length;
  }, w.offset = {
    setOffset: function (e, t, n) {
      var r,
        i,
        o,
        a,
        s,
        u,
        l,
        c = w.css(e, "position"),
        f = w(e),
        p = {};
      "static" === c && (e.style.position = "relative"), s = f.offset(), o = w.css(e, "top"), u = w.css(e, "left"), (l = ("absolute" === c || "fixed" === c) && (o + u).indexOf("auto") > -1) ? (a = (r = f.position()).top, i = r.left) : (a = parseFloat(o) || 0, i = parseFloat(u) || 0), g(t) && (t = t.call(e, n, w.extend({}, s))), null != t.top && (p.top = t.top - s.top + a), null != t.left && (p.left = t.left - s.left + i), "using" in t ? t.using.call(e, p) : f.css(p);
    }
  }, w.fn.extend({
    offset: function (e) {
      if (arguments.length) return void 0 === e ? this : this.each(function (t) {
        w.offset.setOffset(this, e, t);
      });
      var t,
        n,
        r = this[0];
      if (r) return r.getClientRects().length ? (t = r.getBoundingClientRect(), n = r.ownerDocument.defaultView, {
        top: t.top + n.pageYOffset,
        left: t.left + n.pageXOffset
      }) : {
        top: 0,
        left: 0
      };
    },
    position: function () {
      if (this[0]) {
        var e,
          t,
          n,
          r = this[0],
          i = {
            top: 0,
            left: 0
          };
        if ("fixed" === w.css(r, "position")) t = r.getBoundingClientRect();else {
          t = this.offset(), n = r.ownerDocument, e = r.offsetParent || n.documentElement;
          while (e && (e === n.body || e === n.documentElement) && "static" === w.css(e, "position")) e = e.parentNode;
          e && e !== r && 1 === e.nodeType && ((i = w(e).offset()).top += w.css(e, "borderTopWidth", !0), i.left += w.css(e, "borderLeftWidth", !0));
        }
        return {
          top: t.top - i.top - w.css(r, "marginTop", !0),
          left: t.left - i.left - w.css(r, "marginLeft", !0)
        };
      }
    },
    offsetParent: function () {
      return this.map(function () {
        var e = this.offsetParent;
        while (e && "static" === w.css(e, "position")) e = e.offsetParent;
        return e || be;
      });
    }
  }), w.each({
    scrollLeft: "pageXOffset",
    scrollTop: "pageYOffset"
  }, function (e, t) {
    var n = "pageYOffset" === t;
    w.fn[e] = function (r) {
      return z(this, function (e, r, i) {
        var o;
        if (y(e) ? o = e : 9 === e.nodeType && (o = e.defaultView), void 0 === i) return o ? o[t] : e[r];
        o ? o.scrollTo(n ? o.pageXOffset : i, n ? i : o.pageYOffset) : e[r] = i;
      }, e, r, arguments.length);
    };
  }), w.each(["top", "left"], function (e, t) {
    w.cssHooks[t] = _e(h.pixelPosition, function (e, n) {
      if (n) return n = Fe(e, t), We.test(n) ? w(e).position()[t] + "px" : n;
    });
  }), w.each({
    Height: "height",
    Width: "width"
  }, function (e, t) {
    w.each({
      padding: "inner" + e,
      content: t,
      "": "outer" + e
    }, function (n, r) {
      w.fn[r] = function (i, o) {
        var a = arguments.length && (n || "boolean" != typeof i),
          s = n || (!0 === i || !0 === o ? "margin" : "border");
        return z(this, function (t, n, i) {
          var o;
          return y(t) ? 0 === r.indexOf("outer") ? t["inner" + e] : t.document.documentElement["client" + e] : 9 === t.nodeType ? (o = t.documentElement, Math.max(t.body["scroll" + e], o["scroll" + e], t.body["offset" + e], o["offset" + e], o["client" + e])) : void 0 === i ? w.css(t, n, s) : w.style(t, n, i, s);
        }, t, a ? i : void 0, a);
      };
    });
  }), w.each("blur focus focusin focusout resize scroll click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup contextmenu".split(" "), function (e, t) {
    w.fn[t] = function (e, n) {
      return arguments.length > 0 ? this.on(t, null, e, n) : this.trigger(t);
    };
  }), w.fn.extend({
    hover: function (e, t) {
      return this.mouseenter(e).mouseleave(t || e);
    }
  }), w.fn.extend({
    bind: function (e, t, n) {
      return this.on(e, null, t, n);
    },
    unbind: function (e, t) {
      return this.off(e, null, t);
    },
    delegate: function (e, t, n, r) {
      return this.on(t, e, n, r);
    },
    undelegate: function (e, t, n) {
      return 1 === arguments.length ? this.off(e, "**") : this.off(t, e || "**", n);
    }
  }), w.proxy = function (e, t) {
    var n, r, i;
    if ("string" == typeof t && (n = e[t], t = e, e = n), g(e)) return r = o.call(arguments, 2), i = function () {
      return e.apply(t || this, r.concat(o.call(arguments)));
    }, i.guid = e.guid = e.guid || w.guid++, i;
  }, w.holdReady = function (e) {
    e ? w.readyWait++ : w.ready(!0);
  }, w.isArray = Array.isArray, w.parseJSON = JSON.parse, w.nodeName = N, w.isFunction = g, w.isWindow = y, w.camelCase = G, w.type = x, w.now = Date.now, w.isNumeric = function (e) {
    var t = w.type(e);
    return ("number" === t || "string" === t) && !isNaN(e - parseFloat(e));
  }, "function" == typeof define && define.amd && define("jquery", [], function () {
    return w;
  });
  var Jt = e.jQuery,
    Kt = e.$;
  return w.noConflict = function (t) {
    return e.$ === w && (e.$ = Kt), t && e.jQuery === w && (e.jQuery = Jt), w;
  }, t || (e.jQuery = e.$ = w), w;
});
jQuery.noConflict();
/*! jQuery UI - v1.12.1 - 2021-05-21
* http://jqueryui.com
* Includes: widget.js, data.js, scroll-parent.js, widgets/sortable.js, widgets/mouse.js
* Copyright jQuery Foundation and other contributors; Licensed MIT */

(function (factory) {
  if (typeof define === "function" && define.amd) {
    // AMD. Register as an anonymous module.
    define(["jquery"], factory);
  } else {
    // Browser globals
    factory(jQuery);
  }
})(function ($) {
  $.ui = $.ui || {};
  var version = $.ui.version = "1.12.1";

  /*!
   * jQuery UI Widget 1.12.1
   * http://jqueryui.com
   *
   * Copyright jQuery Foundation and other contributors
   * Released under the MIT license.
   * http://jquery.org/license
   */

  //>>label: Widget
  //>>group: Core
  //>>description: Provides a factory for creating stateful widgets with a common API.
  //>>docs: http://api.jqueryui.com/jQuery.widget/
  //>>demos: http://jqueryui.com/widget/

  var widgetUuid = 0;
  var widgetSlice = Array.prototype.slice;
  $.cleanData = function (orig) {
    return function (elems) {
      var events, elem, i;
      for (i = 0; (elem = elems[i]) != null; i++) {
        try {
          // Only trigger remove when necessary to save time
          events = $._data(elem, "events");
          if (events && events.remove) {
            $(elem).triggerHandler("remove");
          }

          // Http://bugs.jquery.com/ticket/8235
        } catch (e) {}
      }
      orig(elems);
    };
  }($.cleanData);
  $.widget = function (name, base, prototype) {
    var existingConstructor, constructor, basePrototype;

    // ProxiedPrototype allows the provided prototype to remain unmodified
    // so that it can be used as a mixin for multiple widgets (#8876)
    var proxiedPrototype = {};
    var namespace = name.split(".")[0];
    name = name.split(".")[1];
    var fullName = namespace + "-" + name;
    if (!prototype) {
      prototype = base;
      base = $.Widget;
    }
    if ($.isArray(prototype)) {
      prototype = $.extend.apply(null, [{}].concat(prototype));
    }

    // Create selector for plugin
    $.expr[":"][fullName.toLowerCase()] = function (elem) {
      return !!$.data(elem, fullName);
    };
    $[namespace] = $[namespace] || {};
    existingConstructor = $[namespace][name];
    constructor = $[namespace][name] = function (options, element) {
      // Allow instantiation without "new" keyword
      if (!this._createWidget) {
        return new constructor(options, element);
      }

      // Allow instantiation without initializing for simple inheritance
      // must use "new" keyword (the code above always passes args)
      if (arguments.length) {
        this._createWidget(options, element);
      }
    };

    // Extend with the existing constructor to carry over any static properties
    $.extend(constructor, existingConstructor, {
      version: prototype.version,
      // Copy the object used to create the prototype in case we need to
      // redefine the widget later
      _proto: $.extend({}, prototype),
      // Track widgets that inherit from this widget in case this widget is
      // redefined after a widget inherits from it
      _childConstructors: []
    });
    basePrototype = new base();

    // We need to make the options hash a property directly on the new instance
    // otherwise we'll modify the options hash on the prototype that we're
    // inheriting from
    basePrototype.options = $.widget.extend({}, basePrototype.options);
    $.each(prototype, function (prop, value) {
      if (!$.isFunction(value)) {
        proxiedPrototype[prop] = value;
        return;
      }
      proxiedPrototype[prop] = function () {
        function _super() {
          return base.prototype[prop].apply(this, arguments);
        }
        function _superApply(args) {
          return base.prototype[prop].apply(this, args);
        }
        return function () {
          var __super = this._super;
          var __superApply = this._superApply;
          var returnValue;
          this._super = _super;
          this._superApply = _superApply;
          returnValue = value.apply(this, arguments);
          this._super = __super;
          this._superApply = __superApply;
          return returnValue;
        };
      }();
    });
    constructor.prototype = $.widget.extend(basePrototype, {
      // TODO: remove support for widgetEventPrefix
      // always use the name + a colon as the prefix, e.g., draggable:start
      // don't prefix for widgets that aren't DOM-based
      widgetEventPrefix: existingConstructor ? basePrototype.widgetEventPrefix || name : name
    }, proxiedPrototype, {
      constructor: constructor,
      namespace: namespace,
      widgetName: name,
      widgetFullName: fullName
    });

    // If this widget is being redefined then we need to find all widgets that
    // are inheriting from it and redefine all of them so that they inherit from
    // the new version of this widget. We're essentially trying to replace one
    // level in the prototype chain.
    if (existingConstructor) {
      $.each(existingConstructor._childConstructors, function (i, child) {
        var childPrototype = child.prototype;

        // Redefine the child widget using the same prototype that was
        // originally used, but inherit from the new version of the base
        $.widget(childPrototype.namespace + "." + childPrototype.widgetName, constructor, child._proto);
      });

      // Remove the list of existing child constructors from the old constructor
      // so the old child constructors can be garbage collected
      delete existingConstructor._childConstructors;
    } else {
      base._childConstructors.push(constructor);
    }
    $.widget.bridge(name, constructor);
    return constructor;
  };
  $.widget.extend = function (target) {
    var input = widgetSlice.call(arguments, 1);
    var inputIndex = 0;
    var inputLength = input.length;
    var key;
    var value;
    for (; inputIndex < inputLength; inputIndex++) {
      for (key in input[inputIndex]) {
        value = input[inputIndex][key];
        if (input[inputIndex].hasOwnProperty(key) && value !== undefined) {
          // Clone objects
          if ($.isPlainObject(value)) {
            target[key] = $.isPlainObject(target[key]) ? $.widget.extend({}, target[key], value) :
            // Don't extend strings, arrays, etc. with objects
            $.widget.extend({}, value);

            // Copy everything else by reference
          } else {
            target[key] = value;
          }
        }
      }
    }
    return target;
  };
  $.widget.bridge = function (name, object) {
    var fullName = object.prototype.widgetFullName || name;
    $.fn[name] = function (options) {
      var isMethodCall = typeof options === "string";
      var args = widgetSlice.call(arguments, 1);
      var returnValue = this;
      if (isMethodCall) {
        // If this is an empty collection, we need to have the instance method
        // return undefined instead of the jQuery instance
        if (!this.length && options === "instance") {
          returnValue = undefined;
        } else {
          this.each(function () {
            var methodValue;
            var instance = $.data(this, fullName);
            if (options === "instance") {
              returnValue = instance;
              return false;
            }
            if (!instance) {
              return $.error("cannot call methods on " + name + " prior to initialization; " + "attempted to call method '" + options + "'");
            }
            if (!$.isFunction(instance[options]) || options.charAt(0) === "_") {
              return $.error("no such method '" + options + "' for " + name + " widget instance");
            }
            methodValue = instance[options].apply(instance, args);
            if (methodValue !== instance && methodValue !== undefined) {
              returnValue = methodValue && methodValue.jquery ? returnValue.pushStack(methodValue.get()) : methodValue;
              return false;
            }
          });
        }
      } else {
        // Allow multiple hashes to be passed on init
        if (args.length) {
          options = $.widget.extend.apply(null, [options].concat(args));
        }
        this.each(function () {
          var instance = $.data(this, fullName);
          if (instance) {
            instance.option(options || {});
            if (instance._init) {
              instance._init();
            }
          } else {
            $.data(this, fullName, new object(options, this));
          }
        });
      }
      return returnValue;
    };
  };
  $.Widget = function /* options, element */ () {};
  $.Widget._childConstructors = [];
  $.Widget.prototype = {
    widgetName: "widget",
    widgetEventPrefix: "",
    defaultElement: "<div>",
    options: {
      classes: {},
      disabled: false,
      // Callbacks
      create: null
    },
    _createWidget: function (options, element) {
      element = $(element || this.defaultElement || this)[0];
      this.element = $(element);
      this.uuid = widgetUuid++;
      this.eventNamespace = "." + this.widgetName + this.uuid;
      this.bindings = $();
      this.hoverable = $();
      this.focusable = $();
      this.classesElementLookup = {};
      if (element !== this) {
        $.data(element, this.widgetFullName, this);
        this._on(true, this.element, {
          remove: function (event) {
            if (event.target === element) {
              this.destroy();
            }
          }
        });
        this.document = $(element.style ?
        // Element within the document
        element.ownerDocument :
        // Element is window or document
        element.document || element);
        this.window = $(this.document[0].defaultView || this.document[0].parentWindow);
      }
      this.options = $.widget.extend({}, this.options, this._getCreateOptions(), options);
      this._create();
      if (this.options.disabled) {
        this._setOptionDisabled(this.options.disabled);
      }
      this._trigger("create", null, this._getCreateEventData());
      this._init();
    },
    _getCreateOptions: function () {
      return {};
    },
    _getCreateEventData: $.noop,
    _create: $.noop,
    _init: $.noop,
    destroy: function () {
      var that = this;
      this._destroy();
      $.each(this.classesElementLookup, function (key, value) {
        that._removeClass(value, key);
      });

      // We can probably remove the unbind calls in 2.0
      // all event bindings should go through this._on()
      this.element.off(this.eventNamespace).removeData(this.widgetFullName);
      this.widget().off(this.eventNamespace).removeAttr("aria-disabled");

      // Clean up events and states
      this.bindings.off(this.eventNamespace);
    },
    _destroy: $.noop,
    widget: function () {
      return this.element;
    },
    option: function (key, value) {
      var options = key;
      var parts;
      var curOption;
      var i;
      if (arguments.length === 0) {
        // Don't return a reference to the internal hash
        return $.widget.extend({}, this.options);
      }
      if (typeof key === "string") {
        // Handle nested keys, e.g., "foo.bar" => { foo: { bar: ___ } }
        options = {};
        parts = key.split(".");
        key = parts.shift();
        if (parts.length) {
          curOption = options[key] = $.widget.extend({}, this.options[key]);
          for (i = 0; i < parts.length - 1; i++) {
            curOption[parts[i]] = curOption[parts[i]] || {};
            curOption = curOption[parts[i]];
          }
          key = parts.pop();
          if (arguments.length === 1) {
            return curOption[key] === undefined ? null : curOption[key];
          }
          curOption[key] = value;
        } else {
          if (arguments.length === 1) {
            return this.options[key] === undefined ? null : this.options[key];
          }
          options[key] = value;
        }
      }
      this._setOptions(options);
      return this;
    },
    _setOptions: function (options) {
      var key;
      for (key in options) {
        this._setOption(key, options[key]);
      }
      return this;
    },
    _setOption: function (key, value) {
      if (key === "classes") {
        this._setOptionClasses(value);
      }
      this.options[key] = value;
      if (key === "disabled") {
        this._setOptionDisabled(value);
      }
      return this;
    },
    _setOptionClasses: function (value) {
      var classKey, elements, currentElements;
      for (classKey in value) {
        currentElements = this.classesElementLookup[classKey];
        if (value[classKey] === this.options.classes[classKey] || !currentElements || !currentElements.length) {
          continue;
        }

        // We are doing this to create a new jQuery object because the _removeClass() call
        // on the next line is going to destroy the reference to the current elements being
        // tracked. We need to save a copy of this collection so that we can add the new classes
        // below.
        elements = $(currentElements.get());
        this._removeClass(currentElements, classKey);

        // We don't use _addClass() here, because that uses this.options.classes
        // for generating the string of classes. We want to use the value passed in from
        // _setOption(), this is the new value of the classes option which was passed to
        // _setOption(). We pass this value directly to _classes().
        elements.addClass(this._classes({
          element: elements,
          keys: classKey,
          classes: value,
          add: true
        }));
      }
    },
    _setOptionDisabled: function (value) {
      this._toggleClass(this.widget(), this.widgetFullName + "-disabled", null, !!value);

      // If the widget is becoming disabled, then nothing is interactive
      if (value) {
        this._removeClass(this.hoverable, null, "ui-state-hover");
        this._removeClass(this.focusable, null, "ui-state-focus");
      }
    },
    enable: function () {
      return this._setOptions({
        disabled: false
      });
    },
    disable: function () {
      return this._setOptions({
        disabled: true
      });
    },
    _classes: function (options) {
      var full = [];
      var that = this;
      options = $.extend({
        element: this.element,
        classes: this.options.classes || {}
      }, options);
      function processClassString(classes, checkOption) {
        var current, i;
        for (i = 0; i < classes.length; i++) {
          current = that.classesElementLookup[classes[i]] || $();
          if (options.add) {
            current = $($.unique(current.get().concat(options.element.get())));
          } else {
            current = $(current.not(options.element).get());
          }
          that.classesElementLookup[classes[i]] = current;
          full.push(classes[i]);
          if (checkOption && options.classes[classes[i]]) {
            full.push(options.classes[classes[i]]);
          }
        }
      }
      this._on(options.element, {
        "remove": "_untrackClassesElement"
      });
      if (options.keys) {
        processClassString(options.keys.match(/\S+/g) || [], true);
      }
      if (options.extra) {
        processClassString(options.extra.match(/\S+/g) || []);
      }
      return full.join(" ");
    },
    _untrackClassesElement: function (event) {
      var that = this;
      $.each(that.classesElementLookup, function (key, value) {
        if ($.inArray(event.target, value) !== -1) {
          that.classesElementLookup[key] = $(value.not(event.target).get());
        }
      });
    },
    _removeClass: function (element, keys, extra) {
      return this._toggleClass(element, keys, extra, false);
    },
    _addClass: function (element, keys, extra) {
      return this._toggleClass(element, keys, extra, true);
    },
    _toggleClass: function (element, keys, extra, add) {
      add = typeof add === "boolean" ? add : extra;
      var shift = typeof element === "string" || element === null,
        options = {
          extra: shift ? keys : extra,
          keys: shift ? element : keys,
          element: shift ? this.element : element,
          add: add
        };
      options.element.toggleClass(this._classes(options), add);
      return this;
    },
    _on: function (suppressDisabledCheck, element, handlers) {
      var delegateElement;
      var instance = this;

      // No suppressDisabledCheck flag, shuffle arguments
      if (typeof suppressDisabledCheck !== "boolean") {
        handlers = element;
        element = suppressDisabledCheck;
        suppressDisabledCheck = false;
      }

      // No element argument, shuffle and use this.element
      if (!handlers) {
        handlers = element;
        element = this.element;
        delegateElement = this.widget();
      } else {
        element = delegateElement = $(element);
        this.bindings = this.bindings.add(element);
      }
      $.each(handlers, function (event, handler) {
        function handlerProxy() {
          // Allow widgets to customize the disabled handling
          // - disabled as an array instead of boolean
          // - disabled class as method for disabling individual parts
          if (!suppressDisabledCheck && (instance.options.disabled === true || $(this).hasClass("ui-state-disabled"))) {
            return;
          }
          return (typeof handler === "string" ? instance[handler] : handler).apply(instance, arguments);
        }

        // Copy the guid so direct unbinding works
        if (typeof handler !== "string") {
          handlerProxy.guid = handler.guid = handler.guid || handlerProxy.guid || $.guid++;
        }
        var match = event.match(/^([\w:-]*)\s*(.*)$/);
        var eventName = match[1] + instance.eventNamespace;
        var selector = match[2];
        if (selector) {
          delegateElement.on(eventName, selector, handlerProxy);
        } else {
          element.on(eventName, handlerProxy);
        }
      });
    },
    _off: function (element, eventName) {
      eventName = (eventName || "").split(" ").join(this.eventNamespace + " ") + this.eventNamespace;
      element.off(eventName).off(eventName);

      // Clear the stack to avoid memory leaks (#10056)
      this.bindings = $(this.bindings.not(element).get());
      this.focusable = $(this.focusable.not(element).get());
      this.hoverable = $(this.hoverable.not(element).get());
    },
    _delay: function (handler, delay) {
      function handlerProxy() {
        return (typeof handler === "string" ? instance[handler] : handler).apply(instance, arguments);
      }
      var instance = this;
      return setTimeout(handlerProxy, delay || 0);
    },
    _hoverable: function (element) {
      this.hoverable = this.hoverable.add(element);
      this._on(element, {
        mouseenter: function (event) {
          this._addClass($(event.currentTarget), null, "ui-state-hover");
        },
        mouseleave: function (event) {
          this._removeClass($(event.currentTarget), null, "ui-state-hover");
        }
      });
    },
    _focusable: function (element) {
      this.focusable = this.focusable.add(element);
      this._on(element, {
        focusin: function (event) {
          this._addClass($(event.currentTarget), null, "ui-state-focus");
        },
        focusout: function (event) {
          this._removeClass($(event.currentTarget), null, "ui-state-focus");
        }
      });
    },
    _trigger: function (type, event, data) {
      var prop, orig;
      var callback = this.options[type];
      data = data || {};
      event = $.Event(event);
      event.type = (type === this.widgetEventPrefix ? type : this.widgetEventPrefix + type).toLowerCase();

      // The original event may come from any element
      // so we need to reset the target on the new event
      event.target = this.element[0];

      // Copy original event properties over to the new event
      orig = event.originalEvent;
      if (orig) {
        for (prop in orig) {
          if (!(prop in event)) {
            event[prop] = orig[prop];
          }
        }
      }
      this.element.trigger(event, data);
      return !($.isFunction(callback) && callback.apply(this.element[0], [event].concat(data)) === false || event.isDefaultPrevented());
    }
  };
  $.each({
    show: "fadeIn",
    hide: "fadeOut"
  }, function (method, defaultEffect) {
    $.Widget.prototype["_" + method] = function (element, options, callback) {
      if (typeof options === "string") {
        options = {
          effect: options
        };
      }
      var hasOptions;
      var effectName = !options ? method : options === true || typeof options === "number" ? defaultEffect : options.effect || defaultEffect;
      options = options || {};
      if (typeof options === "number") {
        options = {
          duration: options
        };
      }
      hasOptions = !$.isEmptyObject(options);
      options.complete = callback;
      if (options.delay) {
        element.delay(options.delay);
      }
      if (hasOptions && $.effects && $.effects.effect[effectName]) {
        element[method](options);
      } else if (effectName !== method && element[effectName]) {
        element[effectName](options.duration, options.easing, callback);
      } else {
        element.queue(function (next) {
          $(this)[method]();
          if (callback) {
            callback.call(element[0]);
          }
          next();
        });
      }
    };
  });
  var widget = $.widget;

  /*!
   * jQuery UI :data 1.12.1
   * http://jqueryui.com
   *
   * Copyright jQuery Foundation and other contributors
   * Released under the MIT license.
   * http://jquery.org/license
   */

  //>>label: :data Selector
  //>>group: Core
  //>>description: Selects elements which have data stored under the specified key.
  //>>docs: http://api.jqueryui.com/data-selector/

  var data = $.extend($.expr[":"], {
    data: $.expr.createPseudo ? $.expr.createPseudo(function (dataName) {
      return function (elem) {
        return !!$.data(elem, dataName);
      };
    }) :
    // Support: jQuery <1.8
    function (elem, i, match) {
      return !!$.data(elem, match[3]);
    }
  });

  /*!
   * jQuery UI Scroll Parent 1.12.1
   * http://jqueryui.com
   *
   * Copyright jQuery Foundation and other contributors
   * Released under the MIT license.
   * http://jquery.org/license
   */

  //>>label: scrollParent
  //>>group: Core
  //>>description: Get the closest ancestor element that is scrollable.
  //>>docs: http://api.jqueryui.com/scrollParent/

  var scrollParent = $.fn.scrollParent = function (includeHidden) {
    var position = this.css("position"),
      excludeStaticParent = position === "absolute",
      overflowRegex = includeHidden ? /(auto|scroll|hidden)/ : /(auto|scroll)/,
      scrollParent = this.parents().filter(function () {
        var parent = $(this);
        if (excludeStaticParent && parent.css("position") === "static") {
          return false;
        }
        return overflowRegex.test(parent.css("overflow") + parent.css("overflow-y") + parent.css("overflow-x"));
      }).eq(0);
    return position === "fixed" || !scrollParent.length ? $(this[0].ownerDocument || document) : scrollParent;
  };

  // This file is deprecated
  var ie = $.ui.ie = !!/msie [\w.]+/.exec(navigator.userAgent.toLowerCase());

  /*!
   * jQuery UI Mouse 1.12.1
   * http://jqueryui.com
   *
   * Copyright jQuery Foundation and other contributors
   * Released under the MIT license.
   * http://jquery.org/license
   */

  //>>label: Mouse
  //>>group: Widgets
  //>>description: Abstracts mouse-based interactions to assist in creating certain widgets.
  //>>docs: http://api.jqueryui.com/mouse/

  var mouseHandled = false;
  $(document).on("mouseup", function () {
    mouseHandled = false;
  });
  var widgetsMouse = $.widget("ui.mouse", {
    version: "1.12.1",
    options: {
      cancel: "input, textarea, button, select, option",
      distance: 1,
      delay: 0
    },
    _mouseInit: function () {
      var that = this;
      this.element.on("mousedown." + this.widgetName, function (event) {
        return that._mouseDown(event);
      }).on("click." + this.widgetName, function (event) {
        if (true === $.data(event.target, that.widgetName + ".preventClickEvent")) {
          $.removeData(event.target, that.widgetName + ".preventClickEvent");
          event.stopImmediatePropagation();
          return false;
        }
      });
      this.started = false;
    },
    // TODO: make sure destroying one instance of mouse doesn't mess with
    // other instances of mouse
    _mouseDestroy: function () {
      this.element.off("." + this.widgetName);
      if (this._mouseMoveDelegate) {
        this.document.off("mousemove." + this.widgetName, this._mouseMoveDelegate).off("mouseup." + this.widgetName, this._mouseUpDelegate);
      }
    },
    _mouseDown: function (event) {
      // don't let more than one widget handle mouseStart
      if (mouseHandled) {
        return;
      }
      this._mouseMoved = false;

      // We may have missed mouseup (out of window)
      this._mouseStarted && this._mouseUp(event);
      this._mouseDownEvent = event;
      var that = this,
        btnIsLeft = event.which === 1,
        // event.target.nodeName works around a bug in IE 8 with
        // disabled inputs (#7620)
        elIsCancel = typeof this.options.cancel === "string" && event.target.nodeName ? $(event.target).closest(this.options.cancel).length : false;
      if (!btnIsLeft || elIsCancel || !this._mouseCapture(event)) {
        return true;
      }
      this.mouseDelayMet = !this.options.delay;
      if (!this.mouseDelayMet) {
        this._mouseDelayTimer = setTimeout(function () {
          that.mouseDelayMet = true;
        }, this.options.delay);
      }
      if (this._mouseDistanceMet(event) && this._mouseDelayMet(event)) {
        this._mouseStarted = this._mouseStart(event) !== false;
        if (!this._mouseStarted) {
          event.preventDefault();
          return true;
        }
      }

      // Click event may never have fired (Gecko & Opera)
      if (true === $.data(event.target, this.widgetName + ".preventClickEvent")) {
        $.removeData(event.target, this.widgetName + ".preventClickEvent");
      }

      // These delegates are required to keep context
      this._mouseMoveDelegate = function (event) {
        return that._mouseMove(event);
      };
      this._mouseUpDelegate = function (event) {
        return that._mouseUp(event);
      };
      this.document.on("mousemove." + this.widgetName, this._mouseMoveDelegate).on("mouseup." + this.widgetName, this._mouseUpDelegate);
      event.preventDefault();
      mouseHandled = true;
      return true;
    },
    _mouseMove: function (event) {
      // Only check for mouseups outside the document if you've moved inside the document
      // at least once. This prevents the firing of mouseup in the case of IE<9, which will
      // fire a mousemove event if content is placed under the cursor. See #7778
      // Support: IE <9
      if (this._mouseMoved) {
        // IE mouseup check - mouseup happened when mouse was out of window
        if ($.ui.ie && (!document.documentMode || document.documentMode < 9) && !event.button) {
          return this._mouseUp(event);

          // Iframe mouseup check - mouseup occurred in another document
        } else if (!event.which) {
          // Support: Safari <=8 - 9
          // Safari sets which to 0 if you press any of the following keys
          // during a drag (#14461)
          if (event.originalEvent.altKey || event.originalEvent.ctrlKey || event.originalEvent.metaKey || event.originalEvent.shiftKey) {
            this.ignoreMissingWhich = true;
          } else if (!this.ignoreMissingWhich) {
            return this._mouseUp(event);
          }
        }
      }
      if (event.which || event.button) {
        this._mouseMoved = true;
      }
      if (this._mouseStarted) {
        this._mouseDrag(event);
        return event.preventDefault();
      }
      if (this._mouseDistanceMet(event) && this._mouseDelayMet(event)) {
        this._mouseStarted = this._mouseStart(this._mouseDownEvent, event) !== false;
        this._mouseStarted ? this._mouseDrag(event) : this._mouseUp(event);
      }
      return !this._mouseStarted;
    },
    _mouseUp: function (event) {
      this.document.off("mousemove." + this.widgetName, this._mouseMoveDelegate).off("mouseup." + this.widgetName, this._mouseUpDelegate);
      if (this._mouseStarted) {
        this._mouseStarted = false;
        if (event.target === this._mouseDownEvent.target) {
          $.data(event.target, this.widgetName + ".preventClickEvent", true);
        }
        this._mouseStop(event);
      }
      if (this._mouseDelayTimer) {
        clearTimeout(this._mouseDelayTimer);
        delete this._mouseDelayTimer;
      }
      this.ignoreMissingWhich = false;
      mouseHandled = false;
      event.preventDefault();
    },
    _mouseDistanceMet: function (event) {
      return Math.max(Math.abs(this._mouseDownEvent.pageX - event.pageX), Math.abs(this._mouseDownEvent.pageY - event.pageY)) >= this.options.distance;
    },
    _mouseDelayMet: function /* event */
    () {
      return this.mouseDelayMet;
    },
    // These are placeholder methods, to be overriden by extending plugin
    _mouseStart: function /* event */ () {},
    _mouseDrag: function /* event */ () {},
    _mouseStop: function /* event */ () {},
    _mouseCapture: function /* event */ () {
      return true;
    }
  });

  /*!
   * jQuery UI Sortable 1.12.1
   * http://jqueryui.com
   *
   * Copyright jQuery Foundation and other contributors
   * Released under the MIT license.
   * http://jquery.org/license
   */

  //>>label: Sortable
  //>>group: Interactions
  //>>description: Enables items in a list to be sorted using the mouse.
  //>>docs: http://api.jqueryui.com/sortable/
  //>>demos: http://jqueryui.com/sortable/
  //>>css.structure: ../../themes/base/sortable.css

  var widgetsSortable = $.widget("ui.sortable", $.ui.mouse, {
    version: "1.12.1",
    widgetEventPrefix: "sort",
    ready: false,
    options: {
      appendTo: "parent",
      axis: false,
      connectWith: false,
      containment: false,
      cursor: "auto",
      cursorAt: false,
      dropOnEmpty: true,
      forcePlaceholderSize: false,
      forceHelperSize: false,
      grid: false,
      handle: false,
      helper: "original",
      items: "> *",
      opacity: false,
      placeholder: false,
      revert: false,
      scroll: true,
      scrollSensitivity: 20,
      scrollSpeed: 20,
      scope: "default",
      tolerance: "intersect",
      zIndex: 1000,
      // Callbacks
      activate: null,
      beforeStop: null,
      change: null,
      deactivate: null,
      out: null,
      over: null,
      receive: null,
      remove: null,
      sort: null,
      start: null,
      stop: null,
      update: null
    },
    _isOverAxis: function (x, reference, size) {
      return x >= reference && x < reference + size;
    },
    _isFloating: function (item) {
      return /left|right/.test(item.css("float")) || /inline|table-cell/.test(item.css("display"));
    },
    _create: function () {
      this.containerCache = {};
      this._addClass("ui-sortable");

      //Get the items
      this.refresh();

      //Let's determine the parent's offset
      this.offset = this.element.offset();

      //Initialize mouse events for interaction
      this._mouseInit();
      this._setHandleClassName();

      //We're ready to go
      this.ready = true;
    },
    _setOption: function (key, value) {
      this._super(key, value);
      if (key === "handle") {
        this._setHandleClassName();
      }
    },
    _setHandleClassName: function () {
      var that = this;
      this._removeClass(this.element.find(".ui-sortable-handle"), "ui-sortable-handle");
      $.each(this.items, function () {
        that._addClass(this.instance.options.handle ? this.item.find(this.instance.options.handle) : this.item, "ui-sortable-handle");
      });
    },
    _destroy: function () {
      this._mouseDestroy();
      for (var i = this.items.length - 1; i >= 0; i--) {
        this.items[i].item.removeData(this.widgetName + "-item");
      }
      return this;
    },
    _mouseCapture: function (event, overrideHandle) {
      var currentItem = null,
        validHandle = false,
        that = this;
      if (this.reverting) {
        return false;
      }
      if (this.options.disabled || this.options.type === "static") {
        return false;
      }

      //We have to refresh the items data once first
      this._refreshItems(event);

      //Find out if the clicked node (or one of its parents) is a actual item in this.items
      $(event.target).parents().each(function () {
        if ($.data(this, that.widgetName + "-item") === that) {
          currentItem = $(this);
          return false;
        }
      });
      if ($.data(event.target, that.widgetName + "-item") === that) {
        currentItem = $(event.target);
      }
      if (!currentItem) {
        return false;
      }
      if (this.options.handle && !overrideHandle) {
        $(this.options.handle, currentItem).find("*").addBack().each(function () {
          if (this === event.target) {
            validHandle = true;
          }
        });
        if (!validHandle) {
          return false;
        }
      }
      this.currentItem = currentItem;
      this._removeCurrentsFromItems();
      return true;
    },
    _mouseStart: function (event, overrideHandle, noActivation) {
      var i,
        body,
        o = this.options;
      this.currentContainer = this;

      //We only need to call refreshPositions, because the refreshItems call has been moved to
      // mouseCapture
      this.refreshPositions();

      //Create and append the visible helper
      this.helper = this._createHelper(event);

      //Cache the helper size
      this._cacheHelperProportions();

      /*
       * - Position generation -
       * This block generates everything position related - it's the core of draggables.
       */

      //Cache the margins of the original element
      this._cacheMargins();

      //Get the next scrolling parent
      this.scrollParent = this.helper.scrollParent();

      //The element's absolute position on the page minus margins
      this.offset = this.currentItem.offset();
      this.offset = {
        top: this.offset.top - this.margins.top,
        left: this.offset.left - this.margins.left
      };
      $.extend(this.offset, {
        click: {
          //Where the click happened, relative to the element
          left: event.pageX - this.offset.left,
          top: event.pageY - this.offset.top
        },
        parent: this._getParentOffset(),
        // This is a relative to absolute position minus the actual position calculation -
        // only used for relative positioned helper
        relative: this._getRelativeOffset()
      });

      // Only after we got the offset, we can change the helper's position to absolute
      // TODO: Still need to figure out a way to make relative sorting possible
      this.helper.css("position", "absolute");
      this.cssPosition = this.helper.css("position");

      //Generate the original position
      this.originalPosition = this._generatePosition(event);
      this.originalPageX = event.pageX;
      this.originalPageY = event.pageY;

      //Adjust the mouse offset relative to the helper if "cursorAt" is supplied
      o.cursorAt && this._adjustOffsetFromHelper(o.cursorAt);

      //Cache the former DOM position
      this.domPosition = {
        prev: this.currentItem.prev()[0],
        parent: this.currentItem.parent()[0]
      };

      // If the helper is not the original, hide the original so it's not playing any role during
      // the drag, won't cause anything bad this way
      if (this.helper[0] !== this.currentItem[0]) {
        this.currentItem.hide();
      }

      //Create the placeholder
      this._createPlaceholder();

      //Set a containment if given in the options
      if (o.containment) {
        this._setContainment();
      }
      if (o.cursor && o.cursor !== "auto") {
        // cursor option
        body = this.document.find("body");

        // Support: IE
        this.storedCursor = body.css("cursor");
        body.css("cursor", o.cursor);
        this.storedStylesheet = $("<style>*{ cursor: " + o.cursor + " !important; }</style>").appendTo(body);
      }
      if (o.opacity) {
        // opacity option
        if (this.helper.css("opacity")) {
          this._storedOpacity = this.helper.css("opacity");
        }
        this.helper.css("opacity", o.opacity);
      }
      if (o.zIndex) {
        // zIndex option
        if (this.helper.css("zIndex")) {
          this._storedZIndex = this.helper.css("zIndex");
        }
        this.helper.css("zIndex", o.zIndex);
      }

      //Prepare scrolling
      if (this.scrollParent[0] !== this.document[0] && this.scrollParent[0].tagName !== "HTML") {
        this.overflowOffset = this.scrollParent.offset();
      }

      //Call callbacks
      this._trigger("start", event, this._uiHash());

      //Recache the helper size
      if (!this._preserveHelperProportions) {
        this._cacheHelperProportions();
      }

      //Post "activate" events to possible containers
      if (!noActivation) {
        for (i = this.containers.length - 1; i >= 0; i--) {
          this.containers[i]._trigger("activate", event, this._uiHash(this));
        }
      }

      //Prepare possible droppables
      if ($.ui.ddmanager) {
        $.ui.ddmanager.current = this;
      }
      if ($.ui.ddmanager && !o.dropBehaviour) {
        $.ui.ddmanager.prepareOffsets(this, event);
      }
      this.dragging = true;
      this._addClass(this.helper, "ui-sortable-helper");

      // Execute the drag once - this causes the helper not to be visiblebefore getting its
      // correct position
      this._mouseDrag(event);
      return true;
    },
    _mouseDrag: function (event) {
      var i,
        item,
        itemElement,
        intersection,
        o = this.options,
        scrolled = false;

      //Compute the helpers position
      this.position = this._generatePosition(event);
      this.positionAbs = this._convertPositionTo("absolute");
      if (!this.lastPositionAbs) {
        this.lastPositionAbs = this.positionAbs;
      }

      //Do scrolling
      if (this.options.scroll) {
        if (this.scrollParent[0] !== this.document[0] && this.scrollParent[0].tagName !== "HTML") {
          if (this.overflowOffset.top + this.scrollParent[0].offsetHeight - event.pageY < o.scrollSensitivity) {
            this.scrollParent[0].scrollTop = scrolled = this.scrollParent[0].scrollTop + o.scrollSpeed;
          } else if (event.pageY - this.overflowOffset.top < o.scrollSensitivity) {
            this.scrollParent[0].scrollTop = scrolled = this.scrollParent[0].scrollTop - o.scrollSpeed;
          }
          if (this.overflowOffset.left + this.scrollParent[0].offsetWidth - event.pageX < o.scrollSensitivity) {
            this.scrollParent[0].scrollLeft = scrolled = this.scrollParent[0].scrollLeft + o.scrollSpeed;
          } else if (event.pageX - this.overflowOffset.left < o.scrollSensitivity) {
            this.scrollParent[0].scrollLeft = scrolled = this.scrollParent[0].scrollLeft - o.scrollSpeed;
          }
        } else {
          if (event.pageY - this.document.scrollTop() < o.scrollSensitivity) {
            scrolled = this.document.scrollTop(this.document.scrollTop() - o.scrollSpeed);
          } else if (this.window.height() - (event.pageY - this.document.scrollTop()) < o.scrollSensitivity) {
            scrolled = this.document.scrollTop(this.document.scrollTop() + o.scrollSpeed);
          }
          if (event.pageX - this.document.scrollLeft() < o.scrollSensitivity) {
            scrolled = this.document.scrollLeft(this.document.scrollLeft() - o.scrollSpeed);
          } else if (this.window.width() - (event.pageX - this.document.scrollLeft()) < o.scrollSensitivity) {
            scrolled = this.document.scrollLeft(this.document.scrollLeft() + o.scrollSpeed);
          }
        }
        if (scrolled !== false && $.ui.ddmanager && !o.dropBehaviour) {
          $.ui.ddmanager.prepareOffsets(this, event);
        }
      }

      //Regenerate the absolute position used for position checks
      this.positionAbs = this._convertPositionTo("absolute");

      //Set the helper position
      if (!this.options.axis || this.options.axis !== "y") {
        this.helper[0].style.left = this.position.left + "px";
      }
      if (!this.options.axis || this.options.axis !== "x") {
        this.helper[0].style.top = this.position.top + "px";
      }

      //Rearrange
      for (i = this.items.length - 1; i >= 0; i--) {
        //Cache variables and intersection, continue if no intersection
        item = this.items[i];
        itemElement = item.item[0];
        intersection = this._intersectsWithPointer(item);
        if (!intersection) {
          continue;
        }

        // Only put the placeholder inside the current Container, skip all
        // items from other containers. This works because when moving
        // an item from one container to another the
        // currentContainer is switched before the placeholder is moved.
        //
        // Without this, moving items in "sub-sortables" can cause
        // the placeholder to jitter between the outer and inner container.
        if (item.instance !== this.currentContainer) {
          continue;
        }

        // Cannot intersect with itself
        // no useless actions that have been done before
        // no action if the item moved is the parent of the item checked
        if (itemElement !== this.currentItem[0] && this.placeholder[intersection === 1 ? "next" : "prev"]()[0] !== itemElement && !$.contains(this.placeholder[0], itemElement) && (this.options.type === "semi-dynamic" ? !$.contains(this.element[0], itemElement) : true)) {
          this.direction = intersection === 1 ? "down" : "up";
          if (this.options.tolerance === "pointer" || this._intersectsWithSides(item)) {
            this._rearrange(event, item);
          } else {
            break;
          }
          this._trigger("change", event, this._uiHash());
          break;
        }
      }

      //Post events to containers
      this._contactContainers(event);

      //Interconnect with droppables
      if ($.ui.ddmanager) {
        $.ui.ddmanager.drag(this, event);
      }

      //Call callbacks
      this._trigger("sort", event, this._uiHash());
      this.lastPositionAbs = this.positionAbs;
      return false;
    },
    _mouseStop: function (event, noPropagation) {
      if (!event) {
        return;
      }

      //If we are using droppables, inform the manager about the drop
      if ($.ui.ddmanager && !this.options.dropBehaviour) {
        $.ui.ddmanager.drop(this, event);
      }
      if (this.options.revert) {
        var that = this,
          cur = this.placeholder.offset(),
          axis = this.options.axis,
          animation = {};
        if (!axis || axis === "x") {
          animation.left = cur.left - this.offset.parent.left - this.margins.left + (this.offsetParent[0] === this.document[0].body ? 0 : this.offsetParent[0].scrollLeft);
        }
        if (!axis || axis === "y") {
          animation.top = cur.top - this.offset.parent.top - this.margins.top + (this.offsetParent[0] === this.document[0].body ? 0 : this.offsetParent[0].scrollTop);
        }
        this.reverting = true;
        $(this.helper).animate(animation, parseInt(this.options.revert, 10) || 500, function () {
          that._clear(event);
        });
      } else {
        this._clear(event, noPropagation);
      }
      return false;
    },
    cancel: function () {
      if (this.dragging) {
        this._mouseUp(new $.Event("mouseup", {
          target: null
        }));
        if (this.options.helper === "original") {
          this.currentItem.css(this._storedCSS);
          this._removeClass(this.currentItem, "ui-sortable-helper");
        } else {
          this.currentItem.show();
        }

        //Post deactivating events to containers
        for (var i = this.containers.length - 1; i >= 0; i--) {
          this.containers[i]._trigger("deactivate", null, this._uiHash(this));
          if (this.containers[i].containerCache.over) {
            this.containers[i]._trigger("out", null, this._uiHash(this));
            this.containers[i].containerCache.over = 0;
          }
        }
      }
      if (this.placeholder) {
        //$(this.placeholder[0]).remove(); would have been the jQuery way - unfortunately,
        // it unbinds ALL events from the original node!
        if (this.placeholder[0].parentNode) {
          this.placeholder[0].parentNode.removeChild(this.placeholder[0]);
        }
        if (this.options.helper !== "original" && this.helper && this.helper[0].parentNode) {
          this.helper.remove();
        }
        $.extend(this, {
          helper: null,
          dragging: false,
          reverting: false,
          _noFinalSort: null
        });
        if (this.domPosition.prev) {
          $(this.domPosition.prev).after(this.currentItem);
        } else {
          $(this.domPosition.parent).prepend(this.currentItem);
        }
      }
      return this;
    },
    serialize: function (o) {
      var items = this._getItemsAsjQuery(o && o.connected),
        str = [];
      o = o || {};
      $(items).each(function () {
        var res = ($(o.item || this).attr(o.attribute || "id") || "").match(o.expression || /(.+)[\-=_](.+)/);
        if (res) {
          str.push((o.key || res[1] + "[]") + "=" + (o.key && o.expression ? res[1] : res[2]));
        }
      });
      if (!str.length && o.key) {
        str.push(o.key + "=");
      }
      return str.join("&");
    },
    toArray: function (o) {
      var items = this._getItemsAsjQuery(o && o.connected),
        ret = [];
      o = o || {};
      items.each(function () {
        ret.push($(o.item || this).attr(o.attribute || "id") || "");
      });
      return ret;
    },
    /* Be careful with the following core functions */
    _intersectsWith: function (item) {
      var x1 = this.positionAbs.left,
        x2 = x1 + this.helperProportions.width,
        y1 = this.positionAbs.top,
        y2 = y1 + this.helperProportions.height,
        l = item.left,
        r = l + item.width,
        t = item.top,
        b = t + item.height,
        dyClick = this.offset.click.top,
        dxClick = this.offset.click.left,
        isOverElementHeight = this.options.axis === "x" || y1 + dyClick > t && y1 + dyClick < b,
        isOverElementWidth = this.options.axis === "y" || x1 + dxClick > l && x1 + dxClick < r,
        isOverElement = isOverElementHeight && isOverElementWidth;
      if (this.options.tolerance === "pointer" || this.options.forcePointerForContainers || this.options.tolerance !== "pointer" && this.helperProportions[this.floating ? "width" : "height"] > item[this.floating ? "width" : "height"]) {
        return isOverElement;
      } else {
        return l < x1 + this.helperProportions.width / 2 &&
        // Right Half
        x2 - this.helperProportions.width / 2 < r &&
        // Left Half
        t < y1 + this.helperProportions.height / 2 &&
        // Bottom Half
        y2 - this.helperProportions.height / 2 < b; // Top Half
      }
    },

    _intersectsWithPointer: function (item) {
      var verticalDirection,
        horizontalDirection,
        isOverElementHeight = this.options.axis === "x" || this._isOverAxis(this.positionAbs.top + this.offset.click.top, item.top, item.height),
        isOverElementWidth = this.options.axis === "y" || this._isOverAxis(this.positionAbs.left + this.offset.click.left, item.left, item.width),
        isOverElement = isOverElementHeight && isOverElementWidth;
      if (!isOverElement) {
        return false;
      }
      verticalDirection = this._getDragVerticalDirection();
      horizontalDirection = this._getDragHorizontalDirection();
      return this.floating ? horizontalDirection === "right" || verticalDirection === "down" ? 2 : 1 : verticalDirection && (verticalDirection === "down" ? 2 : 1);
    },
    _intersectsWithSides: function (item) {
      var isOverBottomHalf = this._isOverAxis(this.positionAbs.top + this.offset.click.top, item.top + item.height / 2, item.height),
        isOverRightHalf = this._isOverAxis(this.positionAbs.left + this.offset.click.left, item.left + item.width / 2, item.width),
        verticalDirection = this._getDragVerticalDirection(),
        horizontalDirection = this._getDragHorizontalDirection();
      if (this.floating && horizontalDirection) {
        return horizontalDirection === "right" && isOverRightHalf || horizontalDirection === "left" && !isOverRightHalf;
      } else {
        return verticalDirection && (verticalDirection === "down" && isOverBottomHalf || verticalDirection === "up" && !isOverBottomHalf);
      }
    },
    _getDragVerticalDirection: function () {
      var delta = this.positionAbs.top - this.lastPositionAbs.top;
      return delta !== 0 && (delta > 0 ? "down" : "up");
    },
    _getDragHorizontalDirection: function () {
      var delta = this.positionAbs.left - this.lastPositionAbs.left;
      return delta !== 0 && (delta > 0 ? "right" : "left");
    },
    refresh: function (event) {
      this._refreshItems(event);
      this._setHandleClassName();
      this.refreshPositions();
      return this;
    },
    _connectWith: function () {
      var options = this.options;
      return options.connectWith.constructor === String ? [options.connectWith] : options.connectWith;
    },
    _getItemsAsjQuery: function (connected) {
      var i,
        j,
        cur,
        inst,
        items = [],
        queries = [],
        connectWith = this._connectWith();
      if (connectWith && connected) {
        for (i = connectWith.length - 1; i >= 0; i--) {
          cur = $(connectWith[i], this.document[0]);
          for (j = cur.length - 1; j >= 0; j--) {
            inst = $.data(cur[j], this.widgetFullName);
            if (inst && inst !== this && !inst.options.disabled) {
              queries.push([$.isFunction(inst.options.items) ? inst.options.items.call(inst.element) : $(inst.options.items, inst.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"), inst]);
            }
          }
        }
      }
      queries.push([$.isFunction(this.options.items) ? this.options.items.call(this.element, null, {
        options: this.options,
        item: this.currentItem
      }) : $(this.options.items, this.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"), this]);
      function addItems() {
        items.push(this);
      }
      for (i = queries.length - 1; i >= 0; i--) {
        queries[i][0].each(addItems);
      }
      return $(items);
    },
    _removeCurrentsFromItems: function () {
      var list = this.currentItem.find(":data(" + this.widgetName + "-item)");
      this.items = $.grep(this.items, function (item) {
        for (var j = 0; j < list.length; j++) {
          if (list[j] === item.item[0]) {
            return false;
          }
        }
        return true;
      });
    },
    _refreshItems: function (event) {
      this.items = [];
      this.containers = [this];
      var i,
        j,
        cur,
        inst,
        targetData,
        _queries,
        item,
        queriesLength,
        items = this.items,
        queries = [[$.isFunction(this.options.items) ? this.options.items.call(this.element[0], event, {
          item: this.currentItem
        }) : $(this.options.items, this.element), this]],
        connectWith = this._connectWith();

      //Shouldn't be run the first time through due to massive slow-down
      if (connectWith && this.ready) {
        for (i = connectWith.length - 1; i >= 0; i--) {
          cur = $(connectWith[i], this.document[0]);
          for (j = cur.length - 1; j >= 0; j--) {
            inst = $.data(cur[j], this.widgetFullName);
            if (inst && inst !== this && !inst.options.disabled) {
              queries.push([$.isFunction(inst.options.items) ? inst.options.items.call(inst.element[0], event, {
                item: this.currentItem
              }) : $(inst.options.items, inst.element), inst]);
              this.containers.push(inst);
            }
          }
        }
      }
      for (i = queries.length - 1; i >= 0; i--) {
        targetData = queries[i][1];
        _queries = queries[i][0];
        for (j = 0, queriesLength = _queries.length; j < queriesLength; j++) {
          item = $(_queries[j]);

          // Data for target checking (mouse manager)
          item.data(this.widgetName + "-item", targetData);
          items.push({
            item: item,
            instance: targetData,
            width: 0,
            height: 0,
            left: 0,
            top: 0
          });
        }
      }
    },
    refreshPositions: function (fast) {
      // Determine whether items are being displayed horizontally
      this.floating = this.items.length ? this.options.axis === "x" || this._isFloating(this.items[0].item) : false;

      //This has to be redone because due to the item being moved out/into the offsetParent,
      // the offsetParent's position will change
      if (this.offsetParent && this.helper) {
        this.offset.parent = this._getParentOffset();
      }
      var i, item, t, p;
      for (i = this.items.length - 1; i >= 0; i--) {
        item = this.items[i];

        //We ignore calculating positions of all connected containers when we're not over them
        if (item.instance !== this.currentContainer && this.currentContainer && item.item[0] !== this.currentItem[0]) {
          continue;
        }
        t = this.options.toleranceElement ? $(this.options.toleranceElement, item.item) : item.item;
        if (!fast) {
          item.width = t.outerWidth();
          item.height = t.outerHeight();
        }
        p = t.offset();
        item.left = p.left;
        item.top = p.top;
      }
      if (this.options.custom && this.options.custom.refreshContainers) {
        this.options.custom.refreshContainers.call(this);
      } else {
        for (i = this.containers.length - 1; i >= 0; i--) {
          p = this.containers[i].element.offset();
          this.containers[i].containerCache.left = p.left;
          this.containers[i].containerCache.top = p.top;
          this.containers[i].containerCache.width = this.containers[i].element.outerWidth();
          this.containers[i].containerCache.height = this.containers[i].element.outerHeight();
        }
      }
      return this;
    },
    _createPlaceholder: function (that) {
      that = that || this;
      var className,
        o = that.options;
      if (!o.placeholder || o.placeholder.constructor === String) {
        className = o.placeholder;
        o.placeholder = {
          element: function () {
            var nodeName = that.currentItem[0].nodeName.toLowerCase(),
              element = $("<" + nodeName + ">", that.document[0]);
            that._addClass(element, "ui-sortable-placeholder", className || that.currentItem[0].className)._removeClass(element, "ui-sortable-helper");
            if (nodeName === "tbody") {
              that._createTrPlaceholder(that.currentItem.find("tr").eq(0), $("<tr>", that.document[0]).appendTo(element));
            } else if (nodeName === "tr") {
              that._createTrPlaceholder(that.currentItem, element);
            } else if (nodeName === "img") {
              element.attr("src", that.currentItem.attr("src"));
            }
            if (!className) {
              element.css("visibility", "hidden");
            }
            return element;
          },
          update: function (container, p) {
            // 1. If a className is set as 'placeholder option, we don't force sizes -
            // the class is responsible for that
            // 2. The option 'forcePlaceholderSize can be enabled to force it even if a
            // class name is specified
            if (className && !o.forcePlaceholderSize) {
              return;
            }

            //If the element doesn't have a actual height by itself (without styles coming
            // from a stylesheet), it receives the inline height from the dragged item
            if (!p.height()) {
              p.height(that.currentItem.innerHeight() - parseInt(that.currentItem.css("paddingTop") || 0, 10) - parseInt(that.currentItem.css("paddingBottom") || 0, 10));
            }
            if (!p.width()) {
              p.width(that.currentItem.innerWidth() - parseInt(that.currentItem.css("paddingLeft") || 0, 10) - parseInt(that.currentItem.css("paddingRight") || 0, 10));
            }
          }
        };
      }

      //Create the placeholder
      that.placeholder = $(o.placeholder.element.call(that.element, that.currentItem));

      //Append it after the actual current item
      that.currentItem.after(that.placeholder);

      //Update the size of the placeholder (TODO: Logic to fuzzy, see line 316/317)
      o.placeholder.update(that, that.placeholder);
    },
    _createTrPlaceholder: function (sourceTr, targetTr) {
      var that = this;
      sourceTr.children().each(function () {
        $("<td>&#160;</td>", that.document[0]).attr("colspan", $(this).attr("colspan") || 1).appendTo(targetTr);
      });
    },
    _contactContainers: function (event) {
      var i,
        j,
        dist,
        itemWithLeastDistance,
        posProperty,
        sizeProperty,
        cur,
        nearBottom,
        floating,
        axis,
        innermostContainer = null,
        innermostIndex = null;

      // Get innermost container that intersects with item
      for (i = this.containers.length - 1; i >= 0; i--) {
        // Never consider a container that's located within the item itself
        if ($.contains(this.currentItem[0], this.containers[i].element[0])) {
          continue;
        }
        if (this._intersectsWith(this.containers[i].containerCache)) {
          // If we've already found a container and it's more "inner" than this, then continue
          if (innermostContainer && $.contains(this.containers[i].element[0], innermostContainer.element[0])) {
            continue;
          }
          innermostContainer = this.containers[i];
          innermostIndex = i;
        } else {
          // container doesn't intersect. trigger "out" event if necessary
          if (this.containers[i].containerCache.over) {
            this.containers[i]._trigger("out", event, this._uiHash(this));
            this.containers[i].containerCache.over = 0;
          }
        }
      }

      // If no intersecting containers found, return
      if (!innermostContainer) {
        return;
      }

      // Move the item into the container if it's not there already
      if (this.containers.length === 1) {
        if (!this.containers[innermostIndex].containerCache.over) {
          this.containers[innermostIndex]._trigger("over", event, this._uiHash(this));
          this.containers[innermostIndex].containerCache.over = 1;
        }
      } else {
        // When entering a new container, we will find the item with the least distance and
        // append our item near it
        dist = 10000;
        itemWithLeastDistance = null;
        floating = innermostContainer.floating || this._isFloating(this.currentItem);
        posProperty = floating ? "left" : "top";
        sizeProperty = floating ? "width" : "height";
        axis = floating ? "pageX" : "pageY";
        for (j = this.items.length - 1; j >= 0; j--) {
          if (!$.contains(this.containers[innermostIndex].element[0], this.items[j].item[0])) {
            continue;
          }
          if (this.items[j].item[0] === this.currentItem[0]) {
            continue;
          }
          cur = this.items[j].item.offset()[posProperty];
          nearBottom = false;
          if (event[axis] - cur > this.items[j][sizeProperty] / 2) {
            nearBottom = true;
          }
          if (Math.abs(event[axis] - cur) < dist) {
            dist = Math.abs(event[axis] - cur);
            itemWithLeastDistance = this.items[j];
            this.direction = nearBottom ? "up" : "down";
          }
        }

        //Check if dropOnEmpty is enabled
        if (!itemWithLeastDistance && !this.options.dropOnEmpty) {
          return;
        }
        if (this.currentContainer === this.containers[innermostIndex]) {
          if (!this.currentContainer.containerCache.over) {
            this.containers[innermostIndex]._trigger("over", event, this._uiHash());
            this.currentContainer.containerCache.over = 1;
          }
          return;
        }
        itemWithLeastDistance ? this._rearrange(event, itemWithLeastDistance, null, true) : this._rearrange(event, null, this.containers[innermostIndex].element, true);
        this._trigger("change", event, this._uiHash());
        this.containers[innermostIndex]._trigger("change", event, this._uiHash(this));
        this.currentContainer = this.containers[innermostIndex];

        //Update the placeholder
        this.options.placeholder.update(this.currentContainer, this.placeholder);
        this.containers[innermostIndex]._trigger("over", event, this._uiHash(this));
        this.containers[innermostIndex].containerCache.over = 1;
      }
    },
    _createHelper: function (event) {
      var o = this.options,
        helper = $.isFunction(o.helper) ? $(o.helper.apply(this.element[0], [event, this.currentItem])) : o.helper === "clone" ? this.currentItem.clone() : this.currentItem;

      //Add the helper to the DOM if that didn't happen already
      if (!helper.parents("body").length) {
        $(o.appendTo !== "parent" ? o.appendTo : this.currentItem[0].parentNode)[0].appendChild(helper[0]);
      }
      if (helper[0] === this.currentItem[0]) {
        this._storedCSS = {
          width: this.currentItem[0].style.width,
          height: this.currentItem[0].style.height,
          position: this.currentItem.css("position"),
          top: this.currentItem.css("top"),
          left: this.currentItem.css("left")
        };
      }
      if (!helper[0].style.width || o.forceHelperSize) {
        helper.width(this.currentItem.width());
      }
      if (!helper[0].style.height || o.forceHelperSize) {
        helper.height(this.currentItem.height());
      }
      return helper;
    },
    _adjustOffsetFromHelper: function (obj) {
      if (typeof obj === "string") {
        obj = obj.split(" ");
      }
      if ($.isArray(obj)) {
        obj = {
          left: +obj[0],
          top: +obj[1] || 0
        };
      }
      if ("left" in obj) {
        this.offset.click.left = obj.left + this.margins.left;
      }
      if ("right" in obj) {
        this.offset.click.left = this.helperProportions.width - obj.right + this.margins.left;
      }
      if ("top" in obj) {
        this.offset.click.top = obj.top + this.margins.top;
      }
      if ("bottom" in obj) {
        this.offset.click.top = this.helperProportions.height - obj.bottom + this.margins.top;
      }
    },
    _getParentOffset: function () {
      //Get the offsetParent and cache its position
      this.offsetParent = this.helper.offsetParent();
      var po = this.offsetParent.offset();

      // This is a special case where we need to modify a offset calculated on start, since the
      // following happened:
      // 1. The position of the helper is absolute, so it's position is calculated based on the
      // next positioned parent
      // 2. The actual offset parent is a child of the scroll parent, and the scroll parent isn't
      // the document, which means that the scroll is included in the initial calculation of the
      // offset of the parent, and never recalculated upon drag
      if (this.cssPosition === "absolute" && this.scrollParent[0] !== this.document[0] && $.contains(this.scrollParent[0], this.offsetParent[0])) {
        po.left += this.scrollParent.scrollLeft();
        po.top += this.scrollParent.scrollTop();
      }

      // This needs to be actually done for all browsers, since pageX/pageY includes this
      // information with an ugly IE fix
      if (this.offsetParent[0] === this.document[0].body || this.offsetParent[0].tagName && this.offsetParent[0].tagName.toLowerCase() === "html" && $.ui.ie) {
        po = {
          top: 0,
          left: 0
        };
      }
      return {
        top: po.top + (parseInt(this.offsetParent.css("borderTopWidth"), 10) || 0),
        left: po.left + (parseInt(this.offsetParent.css("borderLeftWidth"), 10) || 0)
      };
    },
    _getRelativeOffset: function () {
      if (this.cssPosition === "relative") {
        var p = this.currentItem.position();
        return {
          top: p.top - (parseInt(this.helper.css("top"), 10) || 0) + this.scrollParent.scrollTop(),
          left: p.left - (parseInt(this.helper.css("left"), 10) || 0) + this.scrollParent.scrollLeft()
        };
      } else {
        return {
          top: 0,
          left: 0
        };
      }
    },
    _cacheMargins: function () {
      this.margins = {
        left: parseInt(this.currentItem.css("marginLeft"), 10) || 0,
        top: parseInt(this.currentItem.css("marginTop"), 10) || 0
      };
    },
    _cacheHelperProportions: function () {
      this.helperProportions = {
        width: this.helper.outerWidth(),
        height: this.helper.outerHeight()
      };
    },
    _setContainment: function () {
      var ce,
        co,
        over,
        o = this.options;
      if (o.containment === "parent") {
        o.containment = this.helper[0].parentNode;
      }
      if (o.containment === "document" || o.containment === "window") {
        this.containment = [0 - this.offset.relative.left - this.offset.parent.left, 0 - this.offset.relative.top - this.offset.parent.top, o.containment === "document" ? this.document.width() : this.window.width() - this.helperProportions.width - this.margins.left, (o.containment === "document" ? this.document.height() || document.body.parentNode.scrollHeight : this.window.height() || this.document[0].body.parentNode.scrollHeight) - this.helperProportions.height - this.margins.top];
      }
      if (!/^(document|window|parent)$/.test(o.containment)) {
        ce = $(o.containment)[0];
        co = $(o.containment).offset();
        over = $(ce).css("overflow") !== "hidden";
        this.containment = [co.left + (parseInt($(ce).css("borderLeftWidth"), 10) || 0) + (parseInt($(ce).css("paddingLeft"), 10) || 0) - this.margins.left, co.top + (parseInt($(ce).css("borderTopWidth"), 10) || 0) + (parseInt($(ce).css("paddingTop"), 10) || 0) - this.margins.top, co.left + (over ? Math.max(ce.scrollWidth, ce.offsetWidth) : ce.offsetWidth) - (parseInt($(ce).css("borderLeftWidth"), 10) || 0) - (parseInt($(ce).css("paddingRight"), 10) || 0) - this.helperProportions.width - this.margins.left, co.top + (over ? Math.max(ce.scrollHeight, ce.offsetHeight) : ce.offsetHeight) - (parseInt($(ce).css("borderTopWidth"), 10) || 0) - (parseInt($(ce).css("paddingBottom"), 10) || 0) - this.helperProportions.height - this.margins.top];
      }
    },
    _convertPositionTo: function (d, pos) {
      if (!pos) {
        pos = this.position;
      }
      var mod = d === "absolute" ? 1 : -1,
        scroll = this.cssPosition === "absolute" && !(this.scrollParent[0] !== this.document[0] && $.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent,
        scrollIsRootNode = /(html|body)/i.test(scroll[0].tagName);
      return {
        top:
        // The absolute mouse position
        pos.top +
        // Only for relative positioned nodes: Relative offset from element to offset parent
        this.offset.relative.top * mod +
        // The offsetParent's offset without borders (offset + border)
        this.offset.parent.top * mod - (this.cssPosition === "fixed" ? -this.scrollParent.scrollTop() : scrollIsRootNode ? 0 : scroll.scrollTop()) * mod,
        left:
        // The absolute mouse position
        pos.left +
        // Only for relative positioned nodes: Relative offset from element to offset parent
        this.offset.relative.left * mod +
        // The offsetParent's offset without borders (offset + border)
        this.offset.parent.left * mod - (this.cssPosition === "fixed" ? -this.scrollParent.scrollLeft() : scrollIsRootNode ? 0 : scroll.scrollLeft()) * mod
      };
    },
    _generatePosition: function (event) {
      var top,
        left,
        o = this.options,
        pageX = event.pageX,
        pageY = event.pageY,
        scroll = this.cssPosition === "absolute" && !(this.scrollParent[0] !== this.document[0] && $.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent,
        scrollIsRootNode = /(html|body)/i.test(scroll[0].tagName);

      // This is another very weird special case that only happens for relative elements:
      // 1. If the css position is relative
      // 2. and the scroll parent is the document or similar to the offset parent
      // we have to refresh the relative offset during the scroll so there are no jumps
      if (this.cssPosition === "relative" && !(this.scrollParent[0] !== this.document[0] && this.scrollParent[0] !== this.offsetParent[0])) {
        this.offset.relative = this._getRelativeOffset();
      }

      /*
       * - Position constraining -
       * Constrain the position to a mix of grid, containment.
       */

      if (this.originalPosition) {
        //If we are not dragging yet, we won't check for options

        if (this.containment) {
          if (event.pageX - this.offset.click.left < this.containment[0]) {
            pageX = this.containment[0] + this.offset.click.left;
          }
          if (event.pageY - this.offset.click.top < this.containment[1]) {
            pageY = this.containment[1] + this.offset.click.top;
          }
          if (event.pageX - this.offset.click.left > this.containment[2]) {
            pageX = this.containment[2] + this.offset.click.left;
          }
          if (event.pageY - this.offset.click.top > this.containment[3]) {
            pageY = this.containment[3] + this.offset.click.top;
          }
        }
        if (o.grid) {
          top = this.originalPageY + Math.round((pageY - this.originalPageY) / o.grid[1]) * o.grid[1];
          pageY = this.containment ? top - this.offset.click.top >= this.containment[1] && top - this.offset.click.top <= this.containment[3] ? top : top - this.offset.click.top >= this.containment[1] ? top - o.grid[1] : top + o.grid[1] : top;
          left = this.originalPageX + Math.round((pageX - this.originalPageX) / o.grid[0]) * o.grid[0];
          pageX = this.containment ? left - this.offset.click.left >= this.containment[0] && left - this.offset.click.left <= this.containment[2] ? left : left - this.offset.click.left >= this.containment[0] ? left - o.grid[0] : left + o.grid[0] : left;
        }
      }
      return {
        top:
        // The absolute mouse position
        pageY -
        // Click offset (relative to the element)
        this.offset.click.top -
        // Only for relative positioned nodes: Relative offset from element to offset parent
        this.offset.relative.top -
        // The offsetParent's offset without borders (offset + border)
        this.offset.parent.top + (this.cssPosition === "fixed" ? -this.scrollParent.scrollTop() : scrollIsRootNode ? 0 : scroll.scrollTop()),
        left:
        // The absolute mouse position
        pageX -
        // Click offset (relative to the element)
        this.offset.click.left -
        // Only for relative positioned nodes: Relative offset from element to offset parent
        this.offset.relative.left -
        // The offsetParent's offset without borders (offset + border)
        this.offset.parent.left + (this.cssPosition === "fixed" ? -this.scrollParent.scrollLeft() : scrollIsRootNode ? 0 : scroll.scrollLeft())
      };
    },
    _rearrange: function (event, i, a, hardRefresh) {
      a ? a[0].appendChild(this.placeholder[0]) : i.item[0].parentNode.insertBefore(this.placeholder[0], this.direction === "down" ? i.item[0] : i.item[0].nextSibling);

      //Various things done here to improve the performance:
      // 1. we create a setTimeout, that calls refreshPositions
      // 2. on the instance, we have a counter variable, that get's higher after every append
      // 3. on the local scope, we copy the counter variable, and check in the timeout,
      // if it's still the same
      // 4. this lets only the last addition to the timeout stack through
      this.counter = this.counter ? ++this.counter : 1;
      var counter = this.counter;
      this._delay(function () {
        if (counter === this.counter) {
          //Precompute after each DOM insertion, NOT on mousemove
          this.refreshPositions(!hardRefresh);
        }
      });
    },
    _clear: function (event, noPropagation) {
      this.reverting = false;

      // We delay all events that have to be triggered to after the point where the placeholder
      // has been removed and everything else normalized again
      var i,
        delayedTriggers = [];

      // We first have to update the dom position of the actual currentItem
      // Note: don't do it if the current item is already removed (by a user), or it gets
      // reappended (see #4088)
      if (!this._noFinalSort && this.currentItem.parent().length) {
        this.placeholder.before(this.currentItem);
      }
      this._noFinalSort = null;
      if (this.helper[0] === this.currentItem[0]) {
        for (i in this._storedCSS) {
          if (this._storedCSS[i] === "auto" || this._storedCSS[i] === "static") {
            this._storedCSS[i] = "";
          }
        }
        this.currentItem.css(this._storedCSS);
        this._removeClass(this.currentItem, "ui-sortable-helper");
      } else {
        this.currentItem.show();
      }
      if (this.fromOutside && !noPropagation) {
        delayedTriggers.push(function (event) {
          this._trigger("receive", event, this._uiHash(this.fromOutside));
        });
      }
      if ((this.fromOutside || this.domPosition.prev !== this.currentItem.prev().not(".ui-sortable-helper")[0] || this.domPosition.parent !== this.currentItem.parent()[0]) && !noPropagation) {
        // Trigger update callback if the DOM position has changed
        delayedTriggers.push(function (event) {
          this._trigger("update", event, this._uiHash());
        });
      }

      // Check if the items Container has Changed and trigger appropriate
      // events.
      if (this !== this.currentContainer) {
        if (!noPropagation) {
          delayedTriggers.push(function (event) {
            this._trigger("remove", event, this._uiHash());
          });
          delayedTriggers.push(function (c) {
            return function (event) {
              c._trigger("receive", event, this._uiHash(this));
            };
          }.call(this, this.currentContainer));
          delayedTriggers.push(function (c) {
            return function (event) {
              c._trigger("update", event, this._uiHash(this));
            };
          }.call(this, this.currentContainer));
        }
      }

      //Post events to containers
      function delayEvent(type, instance, container) {
        return function (event) {
          container._trigger(type, event, instance._uiHash(instance));
        };
      }
      for (i = this.containers.length - 1; i >= 0; i--) {
        if (!noPropagation) {
          delayedTriggers.push(delayEvent("deactivate", this, this.containers[i]));
        }
        if (this.containers[i].containerCache.over) {
          delayedTriggers.push(delayEvent("out", this, this.containers[i]));
          this.containers[i].containerCache.over = 0;
        }
      }

      //Do what was originally in plugins
      if (this.storedCursor) {
        this.document.find("body").css("cursor", this.storedCursor);
        this.storedStylesheet.remove();
      }
      if (this._storedOpacity) {
        this.helper.css("opacity", this._storedOpacity);
      }
      if (this._storedZIndex) {
        this.helper.css("zIndex", this._storedZIndex === "auto" ? "" : this._storedZIndex);
      }
      this.dragging = false;
      if (!noPropagation) {
        this._trigger("beforeStop", event, this._uiHash());
      }

      //$(this.placeholder[0]).remove(); would have been the jQuery way - unfortunately,
      // it unbinds ALL events from the original node!
      this.placeholder[0].parentNode.removeChild(this.placeholder[0]);
      if (!this.cancelHelperRemoval) {
        if (this.helper[0] !== this.currentItem[0]) {
          this.helper.remove();
        }
        this.helper = null;
      }
      if (!noPropagation) {
        for (i = 0; i < delayedTriggers.length; i++) {
          // Trigger all delayed events
          delayedTriggers[i].call(this, event);
        }
        this._trigger("stop", event, this._uiHash());
      }
      this.fromOutside = false;
      return !this.cancelHelperRemoval;
    },
    _trigger: function () {
      if ($.Widget.prototype._trigger.apply(this, arguments) === false) {
        this.cancel();
      }
    },
    _uiHash: function (_inst) {
      var inst = _inst || this;
      return {
        helper: inst.helper,
        placeholder: inst.placeholder || $([]),
        position: inst.position,
        originalPosition: inst.originalPosition,
        offset: inst.positionAbs,
        item: inst.currentItem,
        sender: _inst ? _inst.element : null
      };
    }
  });
});
/*
Unobtrusive JavaScript
https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts
Released under the MIT license
 */

(function () {
  var context = this;
  (function () {
    (function () {
      this.Rails = {
        linkClickSelector: 'a[data-confirm], a[data-method], a[data-remote]:not([disabled]), a[data-disable-with], a[data-disable]',
        buttonClickSelector: {
          selector: 'button[data-remote]:not([form]), button[data-confirm]:not([form])',
          exclude: 'form button'
        },
        inputChangeSelector: 'select[data-remote], input[data-remote], textarea[data-remote]',
        formSubmitSelector: 'form',
        formInputClickSelector: 'form input[type=submit], form input[type=image], form button[type=submit], form button:not([type]), input[type=submit][form], input[type=image][form], button[type=submit][form], button[form]:not([type])',
        formDisableSelector: 'input[data-disable-with]:enabled, button[data-disable-with]:enabled, textarea[data-disable-with]:enabled, input[data-disable]:enabled, button[data-disable]:enabled, textarea[data-disable]:enabled',
        formEnableSelector: 'input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled, input[data-disable]:disabled, button[data-disable]:disabled, textarea[data-disable]:disabled',
        fileInputSelector: 'input[name][type=file]:not([disabled])',
        linkDisableSelector: 'a[data-disable-with], a[data-disable]',
        buttonDisableSelector: 'button[data-remote][data-disable-with], button[data-remote][data-disable]'
      };
    }).call(this);
  }).call(context);
  var Rails = context.Rails;
  (function () {
    (function () {
      var cspNonce;
      cspNonce = Rails.cspNonce = function () {
        var meta;
        meta = document.querySelector('meta[name=csp-nonce]');
        return meta && meta.content;
      };
    }).call(this);
    (function () {
      var expando, m;
      m = Element.prototype.matches || Element.prototype.matchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.msMatchesSelector || Element.prototype.oMatchesSelector || Element.prototype.webkitMatchesSelector;
      Rails.matches = function (element, selector) {
        if (selector.exclude != null) {
          return m.call(element, selector.selector) && !m.call(element, selector.exclude);
        } else {
          return m.call(element, selector);
        }
      };
      expando = '_ujsData';
      Rails.getData = function (element, key) {
        var ref;
        return (ref = element[expando]) != null ? ref[key] : void 0;
      };
      Rails.setData = function (element, key, value) {
        if (element[expando] == null) {
          element[expando] = {};
        }
        return element[expando][key] = value;
      };
      Rails.$ = function (selector) {
        return Array.prototype.slice.call(document.querySelectorAll(selector));
      };
    }).call(this);
    (function () {
      var $, csrfParam, csrfToken;
      $ = Rails.$;
      csrfToken = Rails.csrfToken = function () {
        var meta;
        meta = document.querySelector('meta[name=csrf-token]');
        return meta && meta.content;
      };
      csrfParam = Rails.csrfParam = function () {
        var meta;
        meta = document.querySelector('meta[name=csrf-param]');
        return meta && meta.content;
      };
      Rails.CSRFProtection = function (xhr) {
        var token;
        token = csrfToken();
        if (token != null) {
          return xhr.setRequestHeader('X-CSRF-Token', token);
        }
      };
      Rails.refreshCSRFTokens = function () {
        var param, token;
        token = csrfToken();
        param = csrfParam();
        if (token != null && param != null) {
          return $('form input[name="' + param + '"]').forEach(function (input) {
            return input.value = token;
          });
        }
      };
    }).call(this);
    (function () {
      var CustomEvent, fire, matches, preventDefault;
      matches = Rails.matches;
      CustomEvent = window.CustomEvent;
      if (typeof CustomEvent !== 'function') {
        CustomEvent = function (event, params) {
          var evt;
          evt = document.createEvent('CustomEvent');
          evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
          return evt;
        };
        CustomEvent.prototype = window.Event.prototype;
        preventDefault = CustomEvent.prototype.preventDefault;
        CustomEvent.prototype.preventDefault = function () {
          var result;
          result = preventDefault.call(this);
          if (this.cancelable && !this.defaultPrevented) {
            Object.defineProperty(this, 'defaultPrevented', {
              get: function () {
                return true;
              }
            });
          }
          return result;
        };
      }
      fire = Rails.fire = function (obj, name, data) {
        var event;
        event = new CustomEvent(name, {
          bubbles: true,
          cancelable: true,
          detail: data
        });
        obj.dispatchEvent(event);
        return !event.defaultPrevented;
      };
      Rails.stopEverything = function (e) {
        fire(e.target, 'ujs:everythingStopped');
        e.preventDefault();
        e.stopPropagation();
        return e.stopImmediatePropagation();
      };
      Rails.delegate = function (element, selector, eventType, handler) {
        return element.addEventListener(eventType, function (e) {
          var target;
          target = e.target;
          while (!(!(target instanceof Element) || matches(target, selector))) {
            target = target.parentNode;
          }
          if (target instanceof Element && handler.call(target, e) === false) {
            e.preventDefault();
            return e.stopPropagation();
          }
        });
      };
    }).call(this);
    (function () {
      var AcceptHeaders, CSRFProtection, createXHR, cspNonce, fire, prepareOptions, processResponse;
      cspNonce = Rails.cspNonce, CSRFProtection = Rails.CSRFProtection, fire = Rails.fire;
      AcceptHeaders = {
        '*': '*/*',
        text: 'text/plain',
        html: 'text/html',
        xml: 'application/xml, text/xml',
        json: 'application/json, text/javascript',
        script: 'text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
      };
      Rails.ajax = function (options) {
        var xhr;
        options = prepareOptions(options);
        xhr = createXHR(options, function () {
          var ref, response;
          response = processResponse((ref = xhr.response) != null ? ref : xhr.responseText, xhr.getResponseHeader('Content-Type'));
          if (Math.floor(xhr.status / 100) === 2) {
            if (typeof options.success === "function") {
              options.success(response, xhr.statusText, xhr);
            }
          } else {
            if (typeof options.error === "function") {
              options.error(response, xhr.statusText, xhr);
            }
          }
          return typeof options.complete === "function" ? options.complete(xhr, xhr.statusText) : void 0;
        });
        if (options.beforeSend != null && !options.beforeSend(xhr, options)) {
          return false;
        }
        if (xhr.readyState === XMLHttpRequest.OPENED) {
          return xhr.send(options.data);
        }
      };
      prepareOptions = function (options) {
        options.url = options.url || location.href;
        options.type = options.type.toUpperCase();
        if (options.type === 'GET' && options.data) {
          if (options.url.indexOf('?') < 0) {
            options.url += '?' + options.data;
          } else {
            options.url += '&' + options.data;
          }
        }
        if (AcceptHeaders[options.dataType] == null) {
          options.dataType = '*';
        }
        options.accept = AcceptHeaders[options.dataType];
        if (options.dataType !== '*') {
          options.accept += ', */*; q=0.01';
        }
        return options;
      };
      createXHR = function (options, done) {
        var xhr;
        xhr = new XMLHttpRequest();
        xhr.open(options.type, options.url, true);
        xhr.setRequestHeader('Accept', options.accept);
        if (typeof options.data === 'string') {
          xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        }
        if (!options.crossDomain) {
          xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        }
        CSRFProtection(xhr);
        xhr.withCredentials = !!options.withCredentials;
        xhr.onreadystatechange = function () {
          if (xhr.readyState === XMLHttpRequest.DONE) {
            return done(xhr);
          }
        };
        return xhr;
      };
      processResponse = function (response, type) {
        var parser, script;
        if (typeof response === 'string' && typeof type === 'string') {
          if (type.match(/\bjson\b/)) {
            try {
              response = JSON.parse(response);
            } catch (error) {}
          } else if (type.match(/\b(?:java|ecma)script\b/)) {
            script = document.createElement('script');
            script.nonce = cspNonce();
            script.text = response;
            document.head.appendChild(script).parentNode.removeChild(script);
          } else if (type.match(/\b(xml|html|svg)\b/)) {
            parser = new DOMParser();
            type = type.replace(/;.+/, '');
            try {
              response = parser.parseFromString(response, type);
            } catch (error) {}
          }
        }
        return response;
      };
      Rails.href = function (element) {
        return element.href;
      };
      Rails.isCrossDomain = function (url) {
        var e, originAnchor, urlAnchor;
        originAnchor = document.createElement('a');
        originAnchor.href = location.href;
        urlAnchor = document.createElement('a');
        try {
          urlAnchor.href = url;
          return !((!urlAnchor.protocol || urlAnchor.protocol === ':') && !urlAnchor.host || originAnchor.protocol + '//' + originAnchor.host === urlAnchor.protocol + '//' + urlAnchor.host);
        } catch (error) {
          e = error;
          return true;
        }
      };
    }).call(this);
    (function () {
      var matches, toArray;
      matches = Rails.matches;
      toArray = function (e) {
        return Array.prototype.slice.call(e);
      };
      Rails.serializeElement = function (element, additionalParam) {
        var inputs, params;
        inputs = [element];
        if (matches(element, 'form')) {
          inputs = toArray(element.elements);
        }
        params = [];
        inputs.forEach(function (input) {
          if (!input.name || input.disabled) {
            return;
          }
          if (matches(input, 'select')) {
            return toArray(input.options).forEach(function (option) {
              if (option.selected) {
                return params.push({
                  name: input.name,
                  value: option.value
                });
              }
            });
          } else if (input.checked || ['radio', 'checkbox', 'submit'].indexOf(input.type) === -1) {
            return params.push({
              name: input.name,
              value: input.value
            });
          }
        });
        if (additionalParam) {
          params.push(additionalParam);
        }
        return params.map(function (param) {
          if (param.name != null) {
            return encodeURIComponent(param.name) + "=" + encodeURIComponent(param.value);
          } else {
            return param;
          }
        }).join('&');
      };
      Rails.formElements = function (form, selector) {
        if (matches(form, 'form')) {
          return toArray(form.elements).filter(function (el) {
            return matches(el, selector);
          });
        } else {
          return toArray(form.querySelectorAll(selector));
        }
      };
    }).call(this);
    (function () {
      var allowAction, fire, stopEverything;
      fire = Rails.fire, stopEverything = Rails.stopEverything;
      Rails.handleConfirm = function (e) {
        if (!allowAction(this)) {
          return stopEverything(e);
        }
      };
      allowAction = function (element) {
        var answer, callback, message;
        message = element.getAttribute('data-confirm');
        if (!message) {
          return true;
        }
        answer = false;
        if (fire(element, 'confirm')) {
          try {
            answer = confirm(message);
          } catch (error) {}
          callback = fire(element, 'confirm:complete', [answer]);
        }
        return answer && callback;
      };
    }).call(this);
    (function () {
      var disableFormElement, disableFormElements, disableLinkElement, enableFormElement, enableFormElements, enableLinkElement, formElements, getData, matches, setData, stopEverything;
      matches = Rails.matches, getData = Rails.getData, setData = Rails.setData, stopEverything = Rails.stopEverything, formElements = Rails.formElements;
      Rails.handleDisabledElement = function (e) {
        var element;
        element = this;
        if (element.disabled) {
          return stopEverything(e);
        }
      };
      Rails.enableElement = function (e) {
        var element;
        element = e instanceof Event ? e.target : e;
        if (matches(element, Rails.linkDisableSelector)) {
          return enableLinkElement(element);
        } else if (matches(element, Rails.buttonDisableSelector) || matches(element, Rails.formEnableSelector)) {
          return enableFormElement(element);
        } else if (matches(element, Rails.formSubmitSelector)) {
          return enableFormElements(element);
        }
      };
      Rails.disableElement = function (e) {
        var element;
        element = e instanceof Event ? e.target : e;
        if (matches(element, Rails.linkDisableSelector)) {
          return disableLinkElement(element);
        } else if (matches(element, Rails.buttonDisableSelector) || matches(element, Rails.formDisableSelector)) {
          return disableFormElement(element);
        } else if (matches(element, Rails.formSubmitSelector)) {
          return disableFormElements(element);
        }
      };
      disableLinkElement = function (element) {
        var replacement;
        replacement = element.getAttribute('data-disable-with');
        if (replacement != null) {
          setData(element, 'ujs:enable-with', element.innerHTML);
          element.innerHTML = replacement;
        }
        element.addEventListener('click', stopEverything);
        return setData(element, 'ujs:disabled', true);
      };
      enableLinkElement = function (element) {
        var originalText;
        originalText = getData(element, 'ujs:enable-with');
        if (originalText != null) {
          element.innerHTML = originalText;
          setData(element, 'ujs:enable-with', null);
        }
        element.removeEventListener('click', stopEverything);
        return setData(element, 'ujs:disabled', null);
      };
      disableFormElements = function (form) {
        return formElements(form, Rails.formDisableSelector).forEach(disableFormElement);
      };
      disableFormElement = function (element) {
        var replacement;
        replacement = element.getAttribute('data-disable-with');
        if (replacement != null) {
          if (matches(element, 'button')) {
            setData(element, 'ujs:enable-with', element.innerHTML);
            element.innerHTML = replacement;
          } else {
            setData(element, 'ujs:enable-with', element.value);
            element.value = replacement;
          }
        }
        element.disabled = true;
        return setData(element, 'ujs:disabled', true);
      };
      enableFormElements = function (form) {
        return formElements(form, Rails.formEnableSelector).forEach(enableFormElement);
      };
      enableFormElement = function (element) {
        var originalText;
        originalText = getData(element, 'ujs:enable-with');
        if (originalText != null) {
          if (matches(element, 'button')) {
            element.innerHTML = originalText;
          } else {
            element.value = originalText;
          }
          setData(element, 'ujs:enable-with', null);
        }
        element.disabled = false;
        return setData(element, 'ujs:disabled', null);
      };
    }).call(this);
    (function () {
      var stopEverything;
      stopEverything = Rails.stopEverything;
      Rails.handleMethod = function (e) {
        var csrfParam, csrfToken, form, formContent, href, link, method;
        link = this;
        method = link.getAttribute('data-method');
        if (!method) {
          return;
        }
        href = Rails.href(link);
        csrfToken = Rails.csrfToken();
        csrfParam = Rails.csrfParam();
        form = document.createElement('form');
        formContent = "<input name='_method' value='" + method + "' type='hidden' />";
        if (csrfParam != null && csrfToken != null && !Rails.isCrossDomain(href)) {
          formContent += "<input name='" + csrfParam + "' value='" + csrfToken + "' type='hidden' />";
        }
        formContent += '<input type="submit" />';
        form.method = 'post';
        form.action = href;
        form.target = link.target;
        form.innerHTML = formContent;
        form.style.display = 'none';
        document.body.appendChild(form);
        form.querySelector('[type="submit"]').click();
        return stopEverything(e);
      };
    }).call(this);
    (function () {
      var ajax,
        fire,
        getData,
        isCrossDomain,
        isRemote,
        matches,
        serializeElement,
        setData,
        stopEverything,
        slice = [].slice;
      matches = Rails.matches, getData = Rails.getData, setData = Rails.setData, fire = Rails.fire, stopEverything = Rails.stopEverything, ajax = Rails.ajax, isCrossDomain = Rails.isCrossDomain, serializeElement = Rails.serializeElement;
      isRemote = function (element) {
        var value;
        value = element.getAttribute('data-remote');
        return value != null && value !== 'false';
      };
      Rails.handleRemote = function (e) {
        var button, data, dataType, element, method, url, withCredentials;
        element = this;
        if (!isRemote(element)) {
          return true;
        }
        if (!fire(element, 'ajax:before')) {
          fire(element, 'ajax:stopped');
          return false;
        }
        withCredentials = element.getAttribute('data-with-credentials');
        dataType = element.getAttribute('data-type') || 'script';
        if (matches(element, Rails.formSubmitSelector)) {
          button = getData(element, 'ujs:submit-button');
          method = getData(element, 'ujs:submit-button-formmethod') || element.method;
          url = getData(element, 'ujs:submit-button-formaction') || element.getAttribute('action') || location.href;
          if (method.toUpperCase() === 'GET') {
            url = url.replace(/\?.*$/, '');
          }
          if (element.enctype === 'multipart/form-data') {
            data = new FormData(element);
            if (button != null) {
              data.append(button.name, button.value);
            }
          } else {
            data = serializeElement(element, button);
          }
          setData(element, 'ujs:submit-button', null);
          setData(element, 'ujs:submit-button-formmethod', null);
          setData(element, 'ujs:submit-button-formaction', null);
        } else if (matches(element, Rails.buttonClickSelector) || matches(element, Rails.inputChangeSelector)) {
          method = element.getAttribute('data-method');
          url = element.getAttribute('data-url');
          data = serializeElement(element, element.getAttribute('data-params'));
        } else {
          method = element.getAttribute('data-method');
          url = Rails.href(element);
          data = element.getAttribute('data-params');
        }
        ajax({
          type: method || 'GET',
          url: url,
          data: data,
          dataType: dataType,
          beforeSend: function (xhr, options) {
            if (fire(element, 'ajax:beforeSend', [xhr, options])) {
              return fire(element, 'ajax:send', [xhr]);
            } else {
              fire(element, 'ajax:stopped');
              return false;
            }
          },
          success: function () {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return fire(element, 'ajax:success', args);
          },
          error: function () {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return fire(element, 'ajax:error', args);
          },
          complete: function () {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return fire(element, 'ajax:complete', args);
          },
          crossDomain: isCrossDomain(url),
          withCredentials: withCredentials != null && withCredentials !== 'false'
        });
        return stopEverything(e);
      };
      Rails.formSubmitButtonClick = function (e) {
        var button, form;
        button = this;
        form = button.form;
        if (!form) {
          return;
        }
        if (button.name) {
          setData(form, 'ujs:submit-button', {
            name: button.name,
            value: button.value
          });
        }
        setData(form, 'ujs:formnovalidate-button', button.formNoValidate);
        setData(form, 'ujs:submit-button-formaction', button.getAttribute('formaction'));
        return setData(form, 'ujs:submit-button-formmethod', button.getAttribute('formmethod'));
      };
      Rails.handleMetaClick = function (e) {
        var data, link, metaClick, method;
        link = this;
        method = (link.getAttribute('data-method') || 'GET').toUpperCase();
        data = link.getAttribute('data-params');
        metaClick = e.metaKey || e.ctrlKey;
        if (metaClick && method === 'GET' && !data) {
          return e.stopImmediatePropagation();
        }
      };
    }).call(this);
    (function () {
      var $, CSRFProtection, delegate, disableElement, enableElement, fire, formSubmitButtonClick, getData, handleConfirm, handleDisabledElement, handleMetaClick, handleMethod, handleRemote, refreshCSRFTokens;
      fire = Rails.fire, delegate = Rails.delegate, getData = Rails.getData, $ = Rails.$, refreshCSRFTokens = Rails.refreshCSRFTokens, CSRFProtection = Rails.CSRFProtection, enableElement = Rails.enableElement, disableElement = Rails.disableElement, handleDisabledElement = Rails.handleDisabledElement, handleConfirm = Rails.handleConfirm, handleRemote = Rails.handleRemote, formSubmitButtonClick = Rails.formSubmitButtonClick, handleMetaClick = Rails.handleMetaClick, handleMethod = Rails.handleMethod;
      if (typeof jQuery !== "undefined" && jQuery !== null && jQuery.ajax != null && !jQuery.rails) {
        jQuery.rails = Rails;
        jQuery.ajaxPrefilter(function (options, originalOptions, xhr) {
          if (!options.crossDomain) {
            return CSRFProtection(xhr);
          }
        });
      }
      Rails.start = function () {
        if (window._rails_loaded) {
          throw new Error('rails-ujs has already been loaded!');
        }
        window.addEventListener('pageshow', function () {
          $(Rails.formEnableSelector).forEach(function (el) {
            if (getData(el, 'ujs:disabled')) {
              return enableElement(el);
            }
          });
          return $(Rails.linkDisableSelector).forEach(function (el) {
            if (getData(el, 'ujs:disabled')) {
              return enableElement(el);
            }
          });
        });
        delegate(document, Rails.linkDisableSelector, 'ajax:complete', enableElement);
        delegate(document, Rails.linkDisableSelector, 'ajax:stopped', enableElement);
        delegate(document, Rails.buttonDisableSelector, 'ajax:complete', enableElement);
        delegate(document, Rails.buttonDisableSelector, 'ajax:stopped', enableElement);
        delegate(document, Rails.linkClickSelector, 'click', handleDisabledElement);
        delegate(document, Rails.linkClickSelector, 'click', handleConfirm);
        delegate(document, Rails.linkClickSelector, 'click', handleMetaClick);
        delegate(document, Rails.linkClickSelector, 'click', disableElement);
        delegate(document, Rails.linkClickSelector, 'click', handleRemote);
        delegate(document, Rails.linkClickSelector, 'click', handleMethod);
        delegate(document, Rails.buttonClickSelector, 'click', handleDisabledElement);
        delegate(document, Rails.buttonClickSelector, 'click', handleConfirm);
        delegate(document, Rails.buttonClickSelector, 'click', disableElement);
        delegate(document, Rails.buttonClickSelector, 'click', handleRemote);
        delegate(document, Rails.inputChangeSelector, 'change', handleDisabledElement);
        delegate(document, Rails.inputChangeSelector, 'change', handleConfirm);
        delegate(document, Rails.inputChangeSelector, 'change', handleRemote);
        delegate(document, Rails.formSubmitSelector, 'submit', handleDisabledElement);
        delegate(document, Rails.formSubmitSelector, 'submit', handleConfirm);
        delegate(document, Rails.formSubmitSelector, 'submit', handleRemote);
        delegate(document, Rails.formSubmitSelector, 'submit', function (e) {
          return setTimeout(function () {
            return disableElement(e);
          }, 13);
        });
        delegate(document, Rails.formSubmitSelector, 'ajax:send', disableElement);
        delegate(document, Rails.formSubmitSelector, 'ajax:complete', enableElement);
        delegate(document, Rails.formInputClickSelector, 'click', handleDisabledElement);
        delegate(document, Rails.formInputClickSelector, 'click', handleConfirm);
        delegate(document, Rails.formInputClickSelector, 'click', formSubmitButtonClick);
        document.addEventListener('DOMContentLoaded', refreshCSRFTokens);
        return window._rails_loaded = true;
      };
      if (window.Rails === Rails && fire(document, 'rails:attachBindings')) {
        Rails.start();
      }
    }).call(this);
  }).call(this);
  if (typeof module === "object" && module.exports) {
    module.exports = Rails;
  } else if (typeof define === "function" && define.amd) {
    define(Rails);
  }
}).call(this);
var Pandora = {};
Pandora.Behaviour = {
  list: [],
  register: function (rules, execute) {
    this.list.push(rules);
    if (execute) {
      this.execute(rules);
    }
  },
  start: function () {
    this.add_dom_load_event(function () {
      Pandora.Behaviour.apply(true);
    });
  },
  apply: function (fire_dom_loaded, ancestor) {
    this.list.each(function (rules) {
      Pandora.Behaviour.execute(rules, fire_dom_loaded, ancestor);
    });
  },
  execute: function (rules, fire_dom_loaded, ancestor) {
    $H(rules).each(function (rule) {
      var elements = $$(rule.key);
      if (ancestor) {
        ancestor = $(ancestor);
        elements = elements.select(function (element) {
          return element === ancestor || element.descendantOf(ancestor);
        });
      }
      if (elements.size() > 0) {
        Pandora.Behaviour.apply_rule(rule.value, elements, fire_dom_loaded);
      }
    });
  },
  apply_rule: function (rule, elements, fire_dom_loaded) {
    $H(rule).each(function (pair) {
      var event_name = pair.key;
      var handler = pair.value;

      // this will be during document's dom:loaded (or later), so
      // elements' dom:loaded handlers have to be executed immediately
      if (event_name === 'dom:loaded') {
        if (fire_dom_loaded) {
          elements.each(function (element) {
            handler.bind(element)();
          });
        }
      } else {
        elements.each(function (element) {
          element.observe(event_name, handler.bindAsEventListener(element));
        });
      }
    });
  },
  add_load_event: function (func) {
    Event.observe(window, 'load', func.bindAsEventListener(window));
  },
  add_dom_load_event: function (func) {
    document.observe('dom:loaded', func.bindAsEventListener(document));
  }
};
Pandora.Behaviour.start();
Pandora.Behaviour.register({
  'body': {
    'dom:loaded': function (e) {
      this.removeClassName('nojs');
      this.addClassName('js');
    }
  },
  '.autoselect': {
    'dom:loaded': function (e) {
      this.form_for_autosubmit(function (form) {
        form.reset();
      });
    },
    change: function (e) {
      this.autosubmit();
    }
  },
  '.autosubmit': {
    click: function (e) {
      this.autosubmit();
    }
  },
  '#content': {
    'dom:loaded': function (e) {
      if (window.location.hash) {
        Pandora.Utils.reveal_anchor(window.location.hash.substr(1));
      } else {
        var input = this.select('input[type=text]').first();
        if (input && input.value.blank() && !input.up('.noautofocus')) {
          input.focus();
        }
      }
    }
  },
  'input[type=text], input[type=password]': {
    'dom:loaded': function (e) {
      if (this.id != 'page') {
        var is_mandatory = this.hasClassName('mandatory');
        var is_prompt = this.hasClassName('prompt');
        var insertions = {};
        $A(['before', 'after']).each(function (i) {
          var span = document.createElement('span');
          Element.extend(span);
          span.className = 'input-left-right';
          if (is_mandatory) {
            span.addClassName('mandatory');
          }
          if (is_prompt) {
            span.addClassName('prompt');
          }
          insertions[i] = span;
        });
        this.insert(insertions);
      }
    }
  },
  // '#boxes': {
  //   'dom:loaded': function(e) {
  //     var uri = this.readAttribute('_order_uri');
  //     if (uri) {
  //       Sortable.create(this, {
  //         tag:      'div',
  //         only:     'sidebar_box',
  //         handle:   'box_handle',
  //         format:   Pandora.Utils.id_format,
  //         onUpdate: function(element) {
  //           // REWRITE: adds CSRF token and handle response content
  //           var token = document.querySelector('meta[name=csrf-token]').content;
  //           new Ajax.Request(uri.append_query_string(Sortable.serialize(element)), {
  //             requestHeaders: {'X-CSRF-Token': token},
  //             onSuccess: function(response, xJson) {
  //               $('boxes').replace(response.responseText);
  //             }
  //           });
  //         }
  //       });
  //     }
  //   }
  // },
  // 'div.box_content[_content_uri]': {
  //   'dom:loaded': function(e) {
  //     this.load_content(this.hasClassName('noscript'));
  //   }
  // },
  '.undim input[type=checkbox]': {
    change: function (e) {
      this.toggle_dim();
    }
  },
  'span.short span.a': {
    click: function (e) {
      this.toggle_truncated(e, true);
    }
  },
  'span.full span.a': {
    click: function (e) {
      this.toggle_truncated(e, false);
    }
  },
  '.section_toggle': {
    click: function (e) {
      this.toggle_section();
    }
  },
  '.section_heading a': {
    click: function (e) {
      if (!e.findElement().hasClassName('ignore-handler')) {
        var section_wrap = this.up('.section_wrap');
        if (section_wrap) {
          section_wrap.expand_section();
        }
      }
    }
  },
  '.popup_toggle': {
    click: function (e) {
      if (!this.hasClassName('disabled')) {
        var popup = this.next('.popup');
        if (popup) {
          popup.toggle_popup(this, e);
        }
      }
    }
  },
  '.popup': {
    click: function (e) {
      if (!Event.findElement(e, 'a')) {
        e.stop();
      }
    }
  },
  '#object-summary a': {
    click: function (e) {
      Pandora.Utils.reveal_anchor(this.href.split('#', 2).last());
    }
  },
  '.thumbnail_select td input[checked]': {
    'dom:loaded': function (e) {
      this.up('td').addClassName('checked');
    }
  },
  '.thumbnail_select td.thumbnail': {
    click: function (e) {
      $$('.thumbnail_select td.checked').invoke('removeClassName', 'checked');
      var td = this.previous('td');
      if (td) {
        var radio = td.down('input[type=radio]');
        if (radio) {
          radio.checked = 'checked';
          td.addClassName('checked');
        }
      }
    }
  }
});
Effect.Shadow = Class.create(Effect.Base, {
  initialize: function (element) {
    this.element = $(element);
    if (!this.element) {
      throw Effect._elementDoesNotExistError;
    }
    this.start(Object.extend({
      startcolor: '#FFFF99',
      endcolor: '#FFFFFF'
    }, arguments[1] || {}));
  },
  setup: function () {
    if (this.element.getStyle('display') === 'none') {
      this.cancel();
      return;
    }
    this.oldStyle = {
      boxShadow: this.element.getStyle('boxShadow') || 'none'
    };
    var s = this.options.startcolor;
    var e = this.options.endcolor;
    this._base = $R(0, 2).map(function (i) {
      return parseInt(s.slice(i * 2 + 1, i * 2 + 3), 16);
    });
    var b = this._base;
    this._delta = $R(0, 2).map(function (i) {
      return parseInt(e.slice(i * 2 + 1, i * 2 + 3), 16) - b[i];
    });
  },
  update: function (position) {
    var b = this._base;
    var d = this._delta;
    this.element.setStyle({
      boxShadow: '0 0 3px 3px ' + $R(0, 2).inject('#', function (m, v, i) {
        return m + (b[i] + d[i] * position).round().toColorPart();
      })
    });
  },
  finish: function () {
    this.element.setStyle(this.oldStyle);
  }
});
Pandora.Utils = {
  wrap: function (name, wrapper) {
    this[name] = this[name].wrap(wrapper);
  },
  merge: function () {
    return $A(arguments).inject(new Hash(), function (m, i) {
      m.update(i);
      return m;
    }).toObject();
  },
  modifier_key: function (e) {
    return e.ctrlKey || e.altKey && e.shiftKey || e.metaKey;
  },
  list_toggle: function (name, form) {
    var master = name + '_master';
    var item = name + '_list_item';
    var rules = {};
    rules['.' + master] = {
      click: function (e) {
        var element = $(form);
        element.toggle_checkboxes(item, this.id);
        element.toggle_checkboxes(master, this.id);
        element.toggle_popup_disabled(item);
      }
    };
    rules['.' + item] = {
      click: function (e) {
        var element = $(form);
        element.toggle_masters(item, master);
        element.select_range(this, item, e, function (_this) {
          element.toggle_masters(item, master);
        });
      }
    };
    Pandora.Behaviour.register(rules);
  },
  reveal_anchor: function (anchor) {
    if (anchor && !anchor.blank()) {
      var element;
      var target = $$('a[name="' + anchor + '"]').first();
      if (target) {
        element = target.up('.section_wrap') || target;
      } else {
        element = $(anchor + '-section');
        target = element;
      }
      if (element) {
        if (element.hasClassName('section_wrap')) {
          element.expand_section();
        }
        element.reveal();
        target.scrollTo();
      }
    }
  },
  scroll_to_flash: function () {
    var flash = $$('div.flash').first();
    if (flash) {
      flash.scrollTo();
    }
  },
  toggle_clear_popups: function (install, run) {
    $(document.body).toggle_reset_handler(function () {
      $$('.popup').invoke('toggle_popup');
      Pandora.Utils.toggle_clear_popups();
    }, install, run);
  },
  toggle_clear_croppables: function (install, run) {
    $(document.body).toggle_reset_handler(function () {
      Cropper.reset();
      Pandora.Utils.toggle_clear_croppables();
    }, install, run, 'mousedown');
  },
  clip: function (value, min, max) {
    return [[min, value].max(), max].min();
  },
  update: function (parameters) {
    if (Pandora.update_url) {
      if (/^https?:/.test(Pandora.update_url)) {
        window.location.href = Pandora.update_url + (Pandora.update_url.include('?') ? '&' : '?') + Object.toQueryString(parameters);
      } else {
        // REWRITE we add the CSRF token
        var token = document.querySelector('meta[name=csrf-token]').content;
        var _ = new Ajax.Request(Pandora.update_url, {
          requestHeaders: {
            'X-CSRF-Token': token
          },
          parameters: parameters,
          evalJS: false,
          evalJSON: false,
          asynchronous: false
        });
      }
    }
  },
  extract_id: function (string) {
    var match = string.match(this.id_format);
    return match ? match[1] : '';
  },
  id_format: /[^-]*-(.*)/,
  invisible: $w('hidden noscript'),
  prev_checked: {},
  zoom_enabled: {}
};
Pandora.ElementMethods = {
  apply_rule: function (element, rule) {
    Pandora.Behaviour.apply_rule(rule, $A([$(element)]));
  },
  _original_visible: Element.Methods.visible,
  visible: function (element) {
    element = $(element);
    return Pandora.Utils.invisible.inject(element._original_visible(), function (m, i) {
      return m && !element.hasClassName(i);
    });
  },
  _original_show: Element.Methods.show,
  show: function (element) {
    element = $(element);
    Pandora.Utils.invisible.each(function (i) {
      element.removeClassName(i);
    });
    return element._original_show();
  },
  really_visible: function (element) {
    element = $(element);
    var offset = element.cumulativeOffset();
    return offset[0] !== 0 || offset[1] !== 0;
  },
  reveal: function (element) {
    element = $(element);
    if (!element.visible()) {
      element.show();
    }
    if (!element.really_visible()) {
      var parent = $(element.parentNode);
      if (parent) {
        parent.reveal();
      }
    }
  },
  walk: function () {
    var args = $A(arguments);
    var element = $(args.shift());
    var callback;
    if (Object.isFunction(args.last())) {
      callback = args.pop();
    }
    var target = args.inject(element, function (m, i) {
      if (m) {
        if (Object.isArray(i)) {
          return m[i.shift()].apply(m, i);
        } else {
          return m[i]();
        }
      }
    });
    if (target && callback) {
      return callback(target);
    } else {
      return target;
    }
  },
  select_by_class_name: function (element, class_name) {
    return $(element).select('.' + class_name);
  },
  intermediateAncestors: function (element, parent) {
    element = $(element);
    if (!element.descendantOf(parent)) {
      return;
    }
    var elements = [];
    (function (i) {
      var j = i.parentNode;
      if (j && j !== parent) {
        elements.push(j);
        arguments.callee(j);
      }
    })(element);
    return elements;
  },
  update_selected: function (element, selector, new_content) {
    var selected = $(element).down(selector);
    if (selected) {
      selected.update(new_content);
    }
  },
  group_item_class: function (element) {
    return $(element).id.sub(/group_master/, 'group_item');
  },
  all_checked: function (element, checkbox_class) {
    element = $(element);
    return element.select_by_class_name(checkbox_class).all(function (i) {
      return i.disabled || i.checked;
    });
  },
  any_checked: function (element, checkbox_class) {
    element = $(element);
    return element.select_by_class_name(checkbox_class).any(function (i) {
      return i.disabled || i.checked;
    });
  },
  check: function (element, checked) {
    element = $(element);
    element.checked = checked;
    element.toggle_dim();
  },
  toggle_handler: function (element, name, handler, run, receiver) {
    element = $(element);
    var key = '_' + name + '_handler';
    if (!receiver) {
      receiver = element;
    }
    if (element[key]) {
      Event.stopObserving(receiver, name, element[key]);
      delete element[key];
    }
    if (handler) {
      if (run) {
        handler(run);
      }
      element[key] = handler.bindAsEventListener(receiver);
      Event.observe(receiver, name, element[key]);
    }
  },
  toggle_global_handler: function (element, name, handler, run) {
    $(element).toggle_handler(name, handler, run, document);
  },
  toggle_combined_handler: function (element, handler, install, run, name, key) {
    element = $(element);
    element.toggle_handler(name, install && handler, run);
    element.toggle_global_handler('keydown', install && function (e) {
      if (e.keyCode === key) {
        handler();
      }
    });
  },
  toggle_reset_handler: function (element, handler, install, run, name) {
    $(element).toggle_combined_handler(handler, install, run, name || 'click', Event.KEY_ESC);
  },
  register_cursor_handler: function (element, handler, initial_style) {
    element = $(element);
    if (!initial_style) {
      initial_style = element.getStyle('cursor');
    }
    var cursor = function (cursor_style) {
      element.style.cursor = cursor_style || initial_style;
    };
    element.apply_rule({
      mouseover: function (e) {
        element.toggle_global_handler('keydown', function (e) {
          handler(cursor, e);
        }, e);
        element.toggle_global_handler('keyup', function () {
          cursor();
        });
      },
      mouseout: function (e) {
        cursor();
        element.toggle_global_handler('keydown');
        element.toggle_global_handler('keyup');
      }
    });
    cursor();
  },
  toggle_popup: function (element, toggle, e) {
    element = $(element);
    var visible = element.visible();
    if (toggle) {
      Pandora.Utils.toggle_clear_popups(!visible, true);
      element.toggle();
      $(toggle).toggle_undim();
    } else if (visible) {
      element.hide();
      toggle = element.previous('.popup_toggle');
      if (toggle) {
        toggle.toggle_undim();
      }
    }
    if (e) {
      e.stop();
    }
  },
  toggle_dim: function (element) {
    element = $(element);
    var undim = element.up('.undim');
    if (undim) {
      undim.toggle_class_name_if(element.checked, 'checked');
    }
  },
  toggle_undim: function (element) {
    element = $(element);
    var undim = element.up('.undim');
    if (undim) {
      undim.toggleClassName('undimmed');
    }
  },
  toggle_popup_disabled: function (element, checkbox_class) {
    element = $(element);
    if (element.id === 'image_list_form') {
      element.select_by_class_name('popup_toggle.disable').invoke('toggle_class_name_if', !element.any_checked(checkbox_class), 'disabled');
    }
  },
  toggle_checkbox: function (element, checked) {
    element = $(element);
    if (element && element.disabled === false) {
      element.check(checked == null ? !element.checked : checked);
    }
  },
  toggle_checkboxes: function (element, checkbox_class, master_id) {
    element = $(element);
    element.select_by_class_name(checkbox_class).invoke('toggle_checkbox', master_id ? $(master_id).checked : null);
  },
  toggle_master: function (element, checkbox_class, master_id) {
    element = $(element);
    var master = $(master_id);
    if (master) {
      master.check(element.all_checked(checkbox_class));
    }
  },
  toggle_masters: function (element, checkbox_class, master_class) {
    element = $(element);
    var masters = element.select_by_class_name(master_class);
    var checked = element.all_checked(checkbox_class);
    masters.each(function (i) {
      i.check(checked);
    });
    element.toggle_popup_disabled(checkbox_class);
  },
  toggle_group_master: function (element, start_element, group_master_class) {
    element = $(element);
    start_element.walk(['up', 1], ['previous', '.group_master'], ['down', '.' + group_master_class], function (i) {
      i.check(element.all_checked(i.group_item_class()));
    });
  },
  toggle_group_masters: function (element, group_master_class) {
    element = $(element);
    element.select_by_class_name(group_master_class).each(function (i) {
      i.check(element.all_checked(i.group_item_class()));
    });
  },
  toggle_group: function (element, group_class, group_master_class, group_toggle_class, _this) {
    element = $(_this || element);
    var members = $$('.' + group_class);
    var class_name;
    var is_group_master = element.hasClassName(group_master_class);
    var expanded = is_group_master ? members.any(function (i) {
      return i.visible();
    }) : members.first().visible();
    var expand_class = 'expand';
    var collapse_class = 'collapse';
    if (expanded) {
      members.invoke('hide');
      class_name = expand_class;
    } else {
      members.invoke('show');
      class_name = collapse_class;
    }
    var toggles = $$('.' + group_toggle_class);
    if (is_group_master) {
      toggles.each(function (i) {
        i.down().className = class_name;
      });
    } else {
      element.down().className = class_name;
      class_name = toggles.any(function (i) {
        return i.down().hasClassName(collapse_class);
      }) ? collapse_class : expand_class;
    }
    $$('.' + group_master_class).each(function (i) {
      i.down().className = class_name;
    });
  },
  toggle_elements: function (element, expand_text, collapse_text, element_class) {
    element = $(element);
    var members = $$('.' + element_class);
    var text;
    if (element.innerHTML === collapse_text) {
      members.invoke('hide');
      text = expand_text;
    } else {
      members.invoke('show');
      text = collapse_text;
    }
    element.innerHTML = text;
  },
  select_range: function (element, start_element, checkbox_class, e, callback) {
    element = $(element);
    var prev = Pandora.Utils.prev_checked[checkbox_class];
    Pandora.Utils.prev_checked[checkbox_class] = start_element;
    if (!prev || e && !e.shiftKey) {
      return;
    }
    var checked = start_element.checked;
    var value = start_element.value;
    var prevalue = prev.value;
    var in_range = false;
    var toggle = function (i) {
      if (!i.disabled) {
        i.check(checked);
      }
    };
    element.select_by_class_name(checkbox_class).each(function (i) {
      var ivalue = i.value;
      var boundary = ivalue === value || ivalue === prevalue;
      if (in_range) {
        if (boundary) {
          in_range = false;
        }
        toggle(i);
      } else {
        if (boundary) {
          in_range = true;
          toggle(i);
        }
      }
    });
    if (callback) {
      callback(start_element);
    }
  },
  append_clone: function (element, clone_class, adder) {
    element = $(element);
    number = 0;

    // clone element...
    var clone = element.cloneNode(true);
    Element.extend(clone);

    // ...clearing any input fields and update attributes.
    $A(clone.getElementsByTagName('input')).each(function (i) {
      i.value = '';
      if (clone_class == "added-row") {
        number = i.readAttribute("tabindex");
        number = parseInt(number) + 1;
        i.writeAttribute("id", "search_value[" + number + "]");
        i.writeAttribute("name", "search_value[" + number + "]");
        i.writeAttribute("tabindex", number);
      }
    });

    // ...and selected options
    $A(clone.getElementsByTagName('select')).each(function (i) {
      i.options[i.selectedIndex].selected = false;
      if (clone_class == "added-row") {
        id = i.readAttribute("id");
        if (id.substring(0, 23) == "boolean_fields_selected") {
          i.writeAttribute("id", "boolean_fields_selected[" + number + "]");
          i.writeAttribute("name", "boolean_fields_selected[" + number + "]");
        } else {
          i.writeAttribute("id", "search_field_" + number);
          i.writeAttribute("name", "search_field[" + number + "]");
        }
      }
    });

    // set class name for future reference
    if (clone_class) {
      clone.addClassName(clone_class);
    }

    // hide "adder" if provided
    if (adder) {
      adder.hide();
    }

    // finally insert the new element!
    element.insert({
      after: clone
    });
    return clone;
  },
  fit_dimensions: function (element, width, height) {
    element = $(element);
    if (width) {
      element.fit_width(width);
    }
    if (height) {
      element.fit_height(height);
    }
  },
  reset_dimensions: function (element) {
    element = $(element);
    if (element._original_width) {
      element.width = element._original_width;
    }
    if (element._original_height) {
      element.height = element._original_height;
    }
  },
  fit_width: function (element, width) {
    element = $(element);
    if (element.width <= width) {
      return;
    }
    var original_width = element.width;
    var original_height = element.height;
    if (!element._original_width) {
      element._original_width = original_width;
    }
    if (!element._original_height) {
      element._original_height = original_height;
    }
    element.width = width;
    element.height = original_height * width / original_width;
  },
  fit_height: function (element, height) {
    element = $(element);
    if (element.height <= height) {
      return;
    }
    var original_width = element.width;
    var original_height = element.height;
    if (!element._original_width) {
      element._original_width = original_width;
    }
    if (!element._original_height) {
      element._original_height = original_height;
    }
    element.height = height;
    element.width = original_width * height / original_height;
  },
  fit_scale: function (element, width, height, callback) {
    element = $(element);
    if (!height) {
      height = width || window.innerHeight;
    }
    if (!width) {
      width = window.innerWidth;
    }
    var dim = element.getDimensions();
    var scale = [height / dim.height, width / dim.width].min();
    style = {
      'WebkitTransform': 'scale(' + scale + ')',
      'WebkitTransformOrigin': '0 0',
      'MozTransform': 'scale(' + scale + ')',
      'MozTransformOrigin': '0 0',
      'MsTransform': 'scale(' + scale + ')',
      'MsTransformOrigin': '0 0',
      'OTransform': 'scale(' + scale + ')',
      'OTransformOrigin': '0 0'
    };
    if (callback) {
      callback(style, scale, dim, width, height);
    }
    element.setStyle(style);
  },
  // zoom_enabled: function(element, toggle_class) {
  //   element = $(element);

  //   if (Pandora.Utils.zoom_enabled[toggle_class] == null) {
  //     var zoom_default = false;

  //     var toggle = $$('.' + toggle_class).first();
  //     if (toggle) {
  //       var toggle_attr = toggle.readAttribute('_zoom_enabled');
  //       if (toggle_attr) {
  //         zoom_default = toggle_attr === 'true';
  //       }
  //     }

  //     Pandora.Utils.zoom_enabled[toggle_class] = zoom_default;
  //   }

  //   return Pandora.Utils.zoom_enabled[toggle_class];
  // },

  // toggle_zoom: function(element, enable_text, disable_text, toggle_class) {
  //   element = $(element);

  //   Pandora.Utils.zoom_enabled[toggle_class] = !element.zoom_enabled(toggle_class);
  //   var enabled = Pandora.Utils.zoom_enabled[toggle_class];

  //   $$('.' + toggle_class).each(function(i) {
  //     i.title = enabled ? disable_text : enable_text;

  //     var toggle = i.down('.zoom_link');
  //     if (toggle) {
  //       toggle.toggle_class_names('enabled', 'disabled');
  //     }
  //   });
  // },

  // zoom: function(element, factor, toggle_class) {
  //   element = $(element);

  //   if (!element.height > 0 || !element.zoom_enabled(toggle_class)) {
  //     return;
  //   }

  //   element._zoom_delayed = function() {
  //     if (element.getAttribute('data-error') == 'true') {
  //       return;
  //     }

  //     element._zoom_delayed = null;

  //     var original = element._before_zoom;
  //     if (!original) {
  //       var offset = element.positionedOffset();

  //       original = {
  //         position:  element.style.position,
  //         width:     element.width,
  //         height:    element.height,
  //         top:       offset.top,
  //         left:      offset.left,
  //         zIndex:    element.style.zIndex,
  //         maxWidth:  element.style.maxWidth,
  //         maxHeight: element.style.maxHeight
  //       };

  //       if (element.hasAttribute('_zoom_src')) {
  //         element._zoom_src = element.readAttribute('_zoom_src');
  //         original.src = element.src;
  //       }

  //       element._before_zoom = original;
  //     }

  //     if (element._zoom_src) {
  //       element.src = element._zoom_src;
  //     }

  //     element.setStyle({
  //       position:  'absolute',
  //       width:     original.width * factor + 'px',
  //       height:    original.height * factor + 'px',
  //       top:       original.top - original.height * (factor - 1) / 2 + 'px',
  //       left:      original.left - original.width * (factor - 1) / 2 + 'px',
  //       zIndex:    original.zIndex + 1,
  //       maxWidth:  'none',
  //       maxHeight: 'none'
  //     });
  //   }.delay(0.5);
  // },

  // unzoom: function(element, toggle_class) {
  //   element = $(element);

  //   if (!element.zoom_enabled(toggle_class)) {
  //     return;
  //   }

  //   var timeout = element._zoom_delayed;
  //   if (timeout) {
  //     window.clearTimeout(timeout);
  //     element._zoom_delayed = null;

  //     return;
  //   }

  //   var original = element._before_zoom;
  //   if (!original) {
  //     return;
  //   }

  //   if (original.src) {
  //     element.src = original.src;
  //   }

  //   element.setStyle({
  //     position:  original.position,
  //     width:     original.width + 'px',
  //     height:    original.height + 'px',
  //     top:       original.top + 'px',
  //     left:      original.left + 'px',
  //     zIndex:    original.zIndex,
  //     maxWidth:  original.maxWidth,
  //     maxHeight: original.maxHeight
  //   });
  // },

  hover: function (element, alt) {
    element = $(element);
    var hover_src = element.readAttribute(alt ? '_alt_hover_src' : '_hover_src');
    if (hover_src) {
      if (!element._original_src) {
        element._original_src = element.src;
      }
      element.src = hover_src;
      if (alt || alt == null) {
        element.walk('up', 'next', 'down', function (i) {
          i.hover(true);
        });
      }
      if (!alt) {
        element.walk('up', 'previous', 'down', function (i) {
          i.hover(false);
        });
      }
    }
  },
  unhover: function (element, alt) {
    element = $(element);
    var original_src = element._original_src;
    if (original_src) {
      element.src = original_src;
      if (alt || alt == null) {
        element.walk('up', 'next', 'down', function (i) {
          i.unhover(true);
        });
      }
      if (!alt) {
        element.walk('up', 'previous', 'down', function (i) {
          i.unhover(false);
        });
      }
    }
  },
  toggle_truncated: function (element, e, expand) {
    if (Pandora.Utils.modifier_key(e)) {
      var short, full, parent;
      var parent_attr = element.readAttribute('_parent');
      if (parent_attr) {
        parent = $(parent_attr);
      }
      if (parent) {
        short = parent.select('span.short');
        full = parent.select('span.full');
      } else {
        short = $$('span.short');
        full = $$('span.full');
      }
      var hideshow = expand ? [short, full] : [full, short];
      hideshow[0].invoke('hide');
      hideshow[1].invoke('show');
    } else {
      var d = element.up('span.truncated');
      d.down('span.' + (expand ? 'short' : 'full')).hide();
      d.down('span.' + (expand ? 'full' : 'short')).show();
    }
  },
  autosubmit: function (element) {
    element = $(element);
    var name = element.readAttribute('_name');
    element.form_for_autosubmit(function (form) {
      if (name) {
        form.insert('<input type="hidden" name="' + name + '" value="commit" />');
      }
      if (!form.onsubmit || form.onsubmit()) {
        // REWRITE: when adding multiple images to an existing collection, the
        // entire image list is rendered within the "store" form. Therefore, all
        // (also hidden) form values from inputs, selects and textareas are also
        // submitted, overriding the correct collection_id, we therefore disable
        // them:
        var isCorrectForm = jQuery(form).attr('id') === 'image_list_form' || jQuery(form).attr('id') === 'upload_list_form';
        if (isCorrectForm) {
          jQuery(form).find("select[name='target_collection[collection_id]']").each(function (i, e) {
            e = jQuery(e);
            if (!e.val()) {
              e.prop('disabled', true);
            }
          });
        }
        form[form.hasClassName('ajax-request') ? 'request' : 'submit']();
      }
    }, function (form) {
      var query = {};
      if (name) {
        query[name] = 'commit';
      }
      if (element.getValue) {
        query[element.name] = element.getValue();
      }
      var action = form.readAttribute('_action') || window.location.href;
      if (form.hasClassName('ajax-request')) {
        Ajax.Request(action, {
          parameters: query
        });
      } else {
        window.location.href = action.append_query(query);
      }
    });
  },
  form_for_autosubmit: function (element, real_callback, pseudo_callback) {
    element = $(element);
    var callback;
    var form = element.up('.pseudo-form');
    if (form) {
      callback = pseudo_callback;
    } else {
      form = element.form || element.up('form');
      callback = real_callback;
    }
    if (form && callback) {
      return callback(form);
    } else {
      return form;
    }
  },
  load_content: function (element, skip, attribute) {
    if (!skip) {
      element = $(element);
      if (!attribute) {
        attribute = '_content_uri';
      }

      // REWRITE: add CSRF token
      var e = null;
      var token = null;
      if (e = document.querySelector('meta[name=csrf-token]')) {
        token = e.content;
      }
      var uri = element.readAttribute(attribute);
      if (uri) {
        element.removeAttribute(attribute);
        new Ajax.Updater(element, uri, {
          onComplete: function (response) {
            Pandora.Behaviour.apply(true, element);
          },
          // REWRITE: CSRF, see above
          parameters: {
            authenticity_token: token
          }
        });
      }
    }
  },
  toggle_box: function (element, class_name, box_id, session_key, expand_text, collapse_text) {
    element = $(element);
    if (!element.hasClassName('box_toggle')) {
      element = element.down('.box_toggle');
    }
    var toggle = element.down();
    toggle.toggle_class_names('expand', 'collapse');
    var collapsed = toggle.hasClassName('expand');
    toggle.title = collapsed ? expand_text : collapse_text;
    var value, box;
    if (Object.isString(box_id) && !box_id.empty()) {
      box = $(box_id).down('.' + class_name);
      box.load_content(collapsed);
      box.toggle();
      value = Pandora.Utils.extract_id(box_id) + ':' + collapsed;
    } else {
      element.up(2).select_by_class_name(class_name).invoke('toggle');
      value = collapsed ? new Date().getTime() / 1000 : '';
    }
    value = value.replace(':', '');
    Pandora.Utils.update({
      key: session_key,
      value: value
    });
  },
  /* Toggle the visibility of a section */
  toggle_section: function (element) {
    element = $(element);
    if (!element.hasClassName('section_toggle')) {
      element = element.down('.section_toggle');
    }
    if (element) {
      element.down().toggle_class_names('expand', 'collapse');
      element.up().select_by_class_name('section').invoke('toggle');
    }
  },
  expand_section: function (element) {
    element = $(element);
    var section = element.down('.section');
    if (section && !section.really_visible()) {
      element.toggle_section();
    }
  },
  toggle_class_names: function () {
    var args = $A(arguments);
    var element = $(args.shift());
    args.each(function (i) {
      element.toggleClassName(i);
    });
  },
  toggle_class_name_if: function (element, condition, class_name) {
    element = $(element);
    if (condition) {
      element.addClassName(class_name);
    } else {
      element.removeClassName(class_name);
    }
  },
  setDimensions: function (element, dim, save) {
    element = $(element);
    if (save) {
      element[save] = element.getDimensions();
    }
    if (Object.isString(dim)) {
      dim = element[dim];
    } else if (Object.isElement(dim)) {
      dim = dim.getDimensions();
    } else if (Object.isArray(dim)) {
      dim = {
        width: dim[0],
        height: dim[1]
      };
    }
    element.setStyle({
      width: dim.width + 'px',
      height: dim.height + 'px'
    });
  }

  // make_draggable: function(element, options, object) {
  //   element = $(element);

  //   if (element.hasClassName('placeholder')) {
  //     return;
  //   }

  //   options = Pandora.Utils.merge({
  //     revert: 'failure',
  //     zindex: 10001,
  //     scroll: window,
  //     scrollSensitivity: 1
  //   }, options, object && object.draggable_options);

  //   var on_start   = options.onStart;
  //   var on_dropped = options.onDropped;
  //   var on_end     = options.onEnd;

  //   options.onStart = function(draggable, e) {
  //     if (on_start) {
  //       on_start(draggable, e);
  //     }

  //     draggable.element._dropped = false;

  //     if (Pandora.Utils.modifier_key(e)) {
  //       draggable.element._copy_draggable = true;

  //       draggable._clone = draggable.element.cloneNode(true);

  //       draggable._originallyAbsolute = (draggable.element.getStyle('position') == 'absolute');
  //       if (!draggable._originallyAbsolute) {
  //         Position.absolutize(draggable.element);
  //       }

  //       draggable.element.parentNode.insertBefore(draggable._clone, draggable.element);
  //     }
  //   };

  //   options.onDropped = function(draggable_element) {
  //     if (on_dropped) {
  //       on_dropped(draggable_element);
  //     }

  //     draggable_element._dropped = true;
  //   };

  //   options.onEnd = function(draggable, e) {
  //     if (on_end) {
  //       on_end(draggable, e);
  //     }

  //     if (draggable.element._copy_draggable) {
  //       draggable.element._copy_draggable = false;

  //       if (!draggable.element._dropped) {
  //         if (!draggable._originallyAbsolute) {
  //           Position.relativize(draggable.element);
  //           draggable.element.style.position = 'relative';
  //         }

  //         delete draggable._originallyAbsolute;

  //         Element.remove(draggable._clone);
  //         draggable._clone = null;
  //       }
  //     }
  //     else if (draggable.element._dropped) {
  //       draggable.originalZ = options.zindex;
  //     }
  //   };

  //   var handle;

  //   if (options.handle) {
  //     if (Object.isString(options.handle)) {
  //       handle = element.down('.' + options.handle);
  //     }

  //     if (!handle) {
  //       handle = $(options.handle);
  //     }
  //   }
  //   else {
  //     handle = element;
  //   }

  //   handle.register_cursor_handler(function(cursor, e) {
  //     if (Pandora.Utils.modifier_key(e)) {
  //       cursor('copy');
  //     }
  //   }, 'move');

  //   element.addClassName('draggable');

  //   return new Draggable(element, options);
  // },

  //   make_droppable: function(element, options, object) {
  //     element = $(element);

  //     options = Pandora.Utils.merge({
  //       hoverclass: 'dragdrop'
  //     }, options, object && object.droppable_options);

  //     element.addClassName('droppable');

  //     Droppables.add(element, options);
  //   },

  //   make_croppable: function(element, options, object) {
  //     element = $(element);

  //     options = Pandora.Utils.merge({
  //       minWidth:       20,
  //       minHeight:      20,
  //       singleton:      true,
  //       skipEmpty:      true,
  //       captureKeys:    false,
  //       autoIncludeCSS: '../stylesheets'
  //     }, options, object && object.croppable_options);

  //     var on_end_crop = options.onEndCrop;

  //     options.onEndCrop = function(coords, dimensions, croppable) {
  //       if (on_end_crop) {
  //         on_end_crop(coords, dimensions, croppable);
  //       }

  //       Pandora.Utils.toggle_clear_croppables(true);
  //     };

  //     return new Cropper.Img(element, options);
  //   },

  //   make_resizable: function(element, opts, options, object) {
  //     element = $(element);

  //     var handle, parent, container, intermediates;
  //     var handle_dim, element_dim, max_dim;
  //     var callback, fx, fy, set_dimensions;

  //     if (Object.isElement(opts)) {
  //       handle    = opts;
  //       opts      = {};
  //     }
  //     else {
  //       handle    = opts.handle;
  //       parent    = opts.parent;
  //       container = opts.container;
  //       callback  = opts.callback;
  //     }

  //     options = Pandora.Utils.merge({
  //       handle: handle,
  //       zindex: 10001,
  //       scroll: window,
  //       scrollSensitivity: 1
  //     }, options, object && object.resizable_options);

  //     var on_start = options.onStart;
  //     var on_end   = options.onEnd;
  //     var revert   = options.revert;
  //     var effect   = options.reverteffect;
  //     var snap     = options.snap;

  //     options.onStart = function(draggable, e) {
  //       handle_dim  = handle.getDimensions();
  //       element_dim = element.getDimensions();

  //       var resizables = [element];

  //       if (parent) {
  //         resizables.push(parent);

  //         intermediates = element.intermediateAncestors(parent);

  //         if (container) {
  //           var parent_offset = parent.positionedOffset();
  //           var container_dim = container.getDimensions();

  //           max_dim = {
  //             width:  container_dim.width  - parent_offset.left,
  //             height: container_dim.height - parent_offset.top
  //           };
  //         }
  //       }

  //       var slope = element_dim.height / element_dim.width;
  //       fx = function(x) { return slope * x; };
  //       fy = function(y) { return y / slope; };

  //       set_dimensions = function(x, y) {
  //         resizables.invoke('setDimensions', [
  //           x || element_dim.width,
  //           y || element_dim.height
  //         ]);
  //       };

  //       if (on_start) {
  //         on_start(draggable, e);
  //       }

  //       element.addClassName('resized');

  //       if (parent) {
  //         parent.addClassName('resizing');
  //       }

  //       if (max_dim) {
  //         intermediates.invoke('setDimensions', max_dim);
  //       }
  //     };

  //     options.onEnd = function(draggable, e) {
  //       if (on_end) {
  //         on_end(draggable, e);
  //       }

  //       if (e.keyCode === Event.KEY_ESC) {
  //         set_dimensions();

  //         if (max_dim) {
  //           intermediates.invoke('setDimensions', element_dim);
  //         }

  //         element.removeClassName('resized');
  //       }
  //       else {
  //         handle._dropped = true;

  //         if (intermediates) {
  //           intermediates.invoke('setDimensions', element);
  //         }

  //         if (callback) {
  //           var dim = element.getDimensions();
  //           callback(draggable, e, dim.width, dim.height);
  //         }
  //       }

  //       if (parent) {
  //         parent.removeClassName('resizing');
  //       }
  //     };

  //     if (Object.isUndefined(revert)) {
  //       options.revert = function() {
  //         return !handle._dropped;
  //       };
  //     }

  //     if (Object.isUndefined(effect)) {
  //       var handle_align = {};

  //       $w('top right bottom left').each(function(i) {
  //         handle_align[i] = handle.getStyle(i);
  //       });

  //       options.reverteffect = function() {
  //         handle.setStyle(handle_align);
  //       };
  //     }

  //     options.snap = function(x, y, draggable) {
  //       if (handle.offsetParent) {
  //         if (snap) {
  //           var res = snap(x, y, draggable, handle_dim, max_dim);
  //           x = res[0];
  //           y = res[1];
  //         }
  //         else if (opts.keep_ratio) {
  //           var y2 = fx(x);
  //           if (y2 > y) {
  //             y = y2;
  //           }
  //           else {
  //             x = fy(y);
  //           }

  //           x = Pandora.Utils.clip(x, handle_dim.width,  max_dim.width);
  //           y = fx(x);

  //           y = Pandora.Utils.clip(y, handle_dim.height, max_dim.height);
  //           x = fy(y);
  //         }
  //         else {
  //           x = Pandora.Utils.clip(x, handle_dim.width,  max_dim.width);
  //           y = Pandora.Utils.clip(y, handle_dim.height, max_dim.height);
  //         }

  //         set_dimensions(x, y);
  //       }
  //       else {
  //         var current_dim = element.getDimensions();
  //         x = current_dim.width;
  //         y = current_dim.height;
  //       }

  //       return [x - handle_dim.width, y - handle_dim.height];
  //     };

  //     return new Draggable(handle, options);
  //   }
};

Pandora.StringMethods = {
  append_query: function (query) {
    if (Object.isString(query)) {
      query = encodeURI(query);
    } else {
      query = $H(query).toQueryString();
    }
    return this.append_query_string(query);
  },
  append_query_string: function (query_string) {
    if (!query_string.empty()) {
      return this + (this.include('?') ? '&' : '?') + query_string;
    } else {
      return this;
    }
  }
};
Element.addMethods(Pandora.ElementMethods);
Object.extend(String.prototype, Pandora.StringMethods);
// REWRITE: some urls need the locale prefix, for example images
window.Upgrade = {
  current_locale: function () {
    return document.location.href.match(/^https?:\/\/[^\/]+\/([a-z]+)/)[1];
  },
  sanitize: function (newValues) {
    if ('order' in newValues) {
      newValues['page'] = null;
      var o = newValues['order'];
      newValues['direction'] = {
        'relevance': 'desc',
        'rating_average': 'desc',
        'rating_count': 'desc'
      }[o] || 'asc';
    }
    if ('per_page' in newValues) {
      newValues['page'] = null;
    }
    return newValues;
  },
  setParam: function (key, value) {
    var opts = {};
    opts[key] = value;
    Upgrade.setParams(opts);
  },
  setParams: function (newValues) {
    newValues = Upgrade.sanitize(newValues);
    var newUrl = window.location.origin;
    newUrl += window.location.pathname;
    var q = window.location.search;
    var h = window.location.hash;
    var sp = new URLSearchParams(q);
    for (var key in newValues) {
      var value = newValues[key];
      if (value === null) {
        sp.delete(key);
      } else {
        sp.set(key, value);
      }
    }
    if (sp.toString() !== '') {
      q = '?' + sp.toString();
    } else {
      q = '';
    }
    newUrl += q + h;
    if (newUrl != window.location.href) {
      window.location.href = newUrl;
    }
  },
  SourceList: {
    init: function (list) {
      var groups = list.find('.pm-groups > li');
      for (var i = 0; i < groups.length; i++) {
        var group = groups.slice(i, i + 1);
        Upgrade.SourceList.updateGroupCheckbox(group);
      }
      Upgrade.SourceList.updateAllCheckbox(list);
      Upgrade.SourceList.updateCounts(list);
    },
    updateCounts: function (list) {
      // count and update total selected databases
      //var count = list.find('.pm-databases input[type=checkbox]:checked').length;

      var dataIds = [];
      list.find('.pm-databases input[type=checkbox]:checked').map(function (i, el) {
        dataIds.push(jQuery(el).attr("data-id"));
      });

      // distinct ids necessary since the same database can be listed in different groups
      var count = new Set(dataIds).size;
      list.find('> .pm-header .pm-amount').html(count);

      // count database selections and update group headers
      var groups = list.find('.pm-groups > li');
      for (var i = 0; i < groups.length; i++) {
        var group = jQuery(groups[i]);
        var total = group.find('.pm-databases input[type=checkbox]').length;
        var count = group.find('.pm-databases input[type=checkbox]:checked').length;
        group.find('> .pm-header .pm-amount').text(' (' + count + '/' + total + ')');
      }
    },
    updateGroupCheckbox: function (group) {
      var result = true;
      var checkboxes = group.find('.pm-databases input[type=checkbox]');
      for (var j = 0; j < checkboxes.length; j++) {
        var checkbox = checkboxes.slice(j, j + 1);
        if (!checkbox.prop('checked')) {
          result = false;
          break;
        }
      }
      var target = group.find('.pm-header input[type=checkbox]');
      target.prop('checked', result);
    },
    updateAllCheckbox: function (list) {
      var result = true;
      var groups = list.find('.pm-groups > li');
      for (var i = 0; i < groups.length; i++) {
        var group = groups.slice(i, i + 1);
        var checkbox = group.find('> .pm-header input[type=checkbox]');
        if (!checkbox.prop('checked')) {
          result = false;
          break;
        }
      }
      var target = list.find('> .pm-body > .pm-check input[type=checkbox]');
      target.prop('checked', result);
    },
    updateDatabaseCheckboxes: function (database) {
      var dataId = database.attr('data-id');
      var checked = database.prop('checked');
      jQuery(".pm-source-list .pm-databases .pm-check input[data-id=" + dataId + "]").each(function (i, el) {
        jQuery(el).prop('checked', checked);
      });
    }
  },
  activateStoreImageButtons: function () {
    // only enable/disable collective store button
    // var buttons = jQuery('.popup_toggle');
    var buttons = jQuery('.store_controls .popup_toggle, .pm-edit-selected');
    var inputs = jQuery('.image_check_box input:checked');
    if (inputs.length > 0) {
      buttons.removeClass('disabled');
    } else {
      buttons.addClass('disabled');
    }
  },
  displaySourceQuota: function (sourceKind) {
    if (sourceKind.find("option:selected").attr("value") == "User database") {
      jQuery("tr").has("label[for='source_quota']").show();
    } else {
      jQuery("tr").has("label[for='source_quota']").hide();
    }
  }
};

// box delete xhr success (announcement)
jQuery(document).on('ajax:success', '#announcements [data-method=DELETE]', function (event, data, status, xhr) {
  jQuery('#announcements').hide();
});

// jQuery(document).on('ajax:success', '.on-source-list', function(event, data, status, xhr) {
//   data = event.originalEvent.detail[2].responseText;
//   let element = jQuery('#source-list-table-body')
//   element.html(data);
//   sourceListWrap();
// });

jQuery(document).on('ajax:success', '.on-rating-done', function (event, data, status, xhr) {
  // for some reason, the args are not set as expected
  let html = event.originalEvent.detail[2].responseText;
  jQuery('#rating').html(html);
});

// list and gallery view switch

jQuery(document).ready(function (event) {
  //if (jQuery('#link-to-gallery').hasClass('inactive')) {
  //  updateToGalleryView();
  //}

  var list = jQuery('.pm-source-list');
  if (list.length != 0) {
    Upgrade.SourceList.init(list);
  }
});

/*function updateToListView(event) {
  event.preventDefault();
  let toListLink = jQuery('[id=link-to-list]');
  let toGalleryLink = jQuery('[id=link-to-gallery]');

  toListLink.toggleClass('inactive');
  toGalleryLink.removeClass('inactive');
  jQuery('.search-link').each(function(i, el) {
    el = jQuery(el);
    let href = el.attr("href");
    el.attr("href", href.replace(/(view=)[a-z]+/ig, 'view=list'));
  });
  jQuery("input[name='view']").attr('value', 'list');
  jQuery('.list_row').attr('style', 'width: 100%;');
  jQuery('.list_row').css({width: '100%'});
  jQuery('.list_row.odd').css({backgroundColor: '#303030'});
  jQuery('.gallery-sort-value').hide();
  jQuery('.comment-div-empty').hide();
  jQuery('.metadata').attr('style', 'height: *; width: *;').show();
}

function updateToGalleryView(event) {
  if (event) {event.preventDefault()}
  let toListLink = jQuery('[id=link-to-list]');
  let toGalleryLink = jQuery('[id=link-to-gallery]');

  toListLink.removeClass('inactive');
  toGalleryLink.addClass('inactive');
  jQuery('.search-link').each(function(i, el) {
    el = jQuery(el);
    let href = el.attr("href");
    el.attr("href", href.replace(/(view=)[a-z]+/ig, 'view=gallery'));
  });
  jQuery("input[name='view']").attr('value', 'gallery');
  //jQuery('.list_row').attr('style', 'width: 33%;');
  jQuery('.list_row').css({
    width: '33%',
    background: 'initial'
  });
  // REWRITE: ids are now generated differently by rails
  // sort_value = $('sort[field]').value;
  let sort_value = jQuery('#sort_field').val();
  if (sort_value != 'artist' || sort_value != 'title' || sort_value != 'location' || sort_value == 'date' || sort_value == 'credits') {
    sort_value = 'title';
  }
  let gallery_sort_value = [];
  jQuery('.' + sort_value + '-field').each(function(i, el) {
    gallery_sort_value[i] = el.innerText;
    return true;
  });
  jQuery('.gallery-sort-value').each(function(i, el) {
    el = jQuery(el);
    el.html(gallery_sort_value[i].substring(0, 25) + "...");
    el.attr('title', gallery_sort_value[i]);
    el.show();
    return true;
  });
  jQuery('.comment-div-empty').show();
  jQuery('.metadata').attr('style', 'height: 0px; width: 0px;').hide();
}

jQuery(document).on('click', '[id=link-to-gallery]', updateToGalleryView);
jQuery(document).on('click', '[id=link-to-list]', updateToListView);
*/

// make the new pagination view work when loaded via ajax
// jQuery(document).on('click', '.box_content .pagination a', function(event){
//   event.preventDefault();
//   let a = jQuery(event.target);
//   let url = a.attr('href');

//   jQuery.ajax({
//     url: url,
//     success: function(data) {
//       a.parents('.box_content').html(data);
//     }
//   })
// });

jQuery(document).on('change', '.pm-select-all', function (event) {
  var checked = jQuery(event.target).prop('checked');
  var inputs = jQuery('.image_check_box input');
  for (var i = 0; i < inputs.length; i++) {
    var input = jQuery(inputs[i]);
    if (checked ^ jQuery(input).prop('checked')) {
      input.click();
    }
  }
  Upgrade.activateStoreImageButtons();
});
jQuery(document).on('change', '#institution_master_top, #institution_master_bottom', function (event) {
  var checked = jQuery(event.target).prop('checked');
  var inputs = jQuery('input[type=checkbox].institution_list_item');
  var masters = jQuery('#institution_master_top, #institution_master_bottom');
  inputs.prop('checked', checked);
  masters.prop('checked', checked);
});
jQuery(document).on('change', '.image_check_box input', function (event) {
  Upgrade.activateStoreImageButtons();
});
jQuery(document).on('change', 'select[pm-to-param]', function (event) {
  var e = jQuery(event.target);
  var key = e.attr('pm-to-param');
  var value = e.val();
  Upgrade.setParam(key, value);
});
jQuery(document).on('click', 'a[pm-to-param]', function (event) {
  event.preventDefault();
  var e = jQuery(event.currentTarget);
  // var key = e.attr('pm-to-param');
  // var value = e.attr('pm-value');
  //Upgrade.setParam(key, value);

  var db_group_key = e.attr('pm-to-param');
  var db_group_value = e.attr('pm-value');
  var expand_list_key = 'expand_list';
  var expand_list_value = true;
  var opts = {};
  opts[db_group_key] = db_group_value;
  opts[expand_list_key] = expand_list_value;
  Upgrade.setParams(opts);
});
jQuery(document).on('keydown', 'input[pm-to-param]', function (event) {
  if (event.which == 13) {
    event.preventDefault();
    var e = jQuery(event.target);
    var key = e.attr('pm-to-param');
    var value = e.val();
    Upgrade.setParam(key, value);
  }
});
jQuery(document).on('click', '[pm-submit-to-param]', function (event) {
  event.preventDefault();
  var e = jQuery(event.target);
  var field = e.attr('pm-field');
  var key = e.attr('pm-submit-to-param');
  var value = jQuery("[name='" + field + "']").val();
  Upgrade.setParam(key, value);
});
jQuery(document).on('click', '.pm-pagination-go', function (event) {
  event.preventDefault();
  var e = jQuery(event.currentTarget);
  var field = e.parents('.pagination').find('input[name=page]');
  var value = field.val() || field.attr('placeholder');
  Upgrade.setParam('page', value);
});

// jQuery(document).on('click', '.toggle_zoom a', function(event) {
//   event.preventDefault();
//
//   var element = jQuery('div.zoom_link');
//   element.toggleClass('disabled');
//   element.toggleClass('enabled');
// });

// add image preloader vor image zoom versions (#1396)
jQuery(document).ready(function (event) {
  var images = document.querySelectorAll("img[_zoom_src]");
  var urls = [...images].map(i => i.getAttribute('_zoom_src'));
  var uniq = [...new Set(urls)];
  var loader = document.createElement('div');
  loader.style.backgroundImage = uniq.map(u => `url(${u})`).join(', ');
  var body = document.querySelector('body');
  body.append(loader);
});
jQuery(document).on('mouseover', '.image_list [_zoom_src]', function (event) {
  var img = jQuery(event.target);
  var enabled = jQuery('div.zoom_link').hasClass('enabled');
  if (enabled) {
    if (!img.hasClass('pm-zoomed')) {
      // we do this so that the img element doesn't get width == height == 0 for
      // a short when the src valus is exchanged period because that triggers
      // the below mouseout and the img flickers visibly
      img.css('min-width', img.width());
      img.css('min-height', img.height());
      var tmp = img.attr('_zoom_src');
      img.attr('_zoom_src', img.attr('src'));
      img.attr('src', tmp);
      img.addClass('pm-zoomed');
      img.addClass('pm-detached');
    }
  }
});
jQuery(document).on('mouseout', '.image_list [_zoom_src].pm-zoomed', function (event) {
  var enabled = jQuery('.toggle_zoom div.zoom_link').hasClass('enabled');
  if (enabled) {
    var img = jQuery(event.target);
    var tmp = img.attr('_zoom_src');
    img.attr('_zoom_src', img.attr('src'));
    img.attr('src', tmp);
    img.removeClass('pm-zoomed');
    var events = 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd';
    img.one(events, function (event) {
      img.removeClass('pm-detached');
    });
  }
});
var selector = '.pm-source-list > .pm-body > .pm-check input[type=checkbox]';
jQuery(document).on('change', selector, function (event) {
  var e = jQuery(event.target);
  var checked = e.prop('checked');
  e.parents('.pm-source-list').find('input[type=checkbox]').prop('checked', checked);
  var list = e.parents('.pm-source-list');
  Upgrade.SourceList.updateCounts(list);
});
selector = '.pm-source-list .pm-groups > li > .pm-header .pm-check';
jQuery(document).on('change', selector, function (event) {
  var e = jQuery(event.target);
  var checked = e.prop('checked');

  // update other checkboxes for same database (databases may have several kewords)
  var databaseCheckboxes = e.parents('li').find('.pm-databases input[type=checkbox]');
  databaseCheckboxes.prop('checked', checked);
  databaseCheckboxes.each(function (i, el) {
    Upgrade.SourceList.updateDatabaseCheckboxes(jQuery(el));
  });
  var list = e.parents('.pm-source-list');

  // update all group checkboxes
  var groups = list.find('.pm-groups > li');
  groups.each(function (i, group) {
    Upgrade.SourceList.updateGroupCheckbox(jQuery(group));
  });
  Upgrade.SourceList.updateAllCheckbox(list);
  Upgrade.SourceList.updateCounts(list);
});
selector = '.pm-source-list .pm-databases .pm-check';
jQuery(document).on('change', selector, function (event) {
  var e = jQuery(event.target);

  // update all other checkboxes for same database (databases may have several kewords)
  Upgrade.SourceList.updateDatabaseCheckboxes(e);
  var list = e.parents('.pm-source-list');

  // update all group checkboxes
  var groups = list.find('.pm-groups > li');
  groups.each(function (i, group) {
    Upgrade.SourceList.updateGroupCheckbox(jQuery(group));
  });
  Upgrade.SourceList.updateAllCheckbox(list);
  Upgrade.SourceList.updateCounts(list);
});
selector = '.pm-source-list > .pm-header .pm-toggle a';
jQuery(document).on('click', selector, function (event) {
  event.preventDefault();
  var list = jQuery(event.target).parents('.pm-source-list');
  list.toggleClass('pm-expand');
});

// selector = '.pm-source-list .pm-groups';
// jQuery(document).on('click', '.pm-source-list .pm-show > a', function(event) {
//   event.preventDefault();
//   var list = jQuery(event.target).parents('.pm-source-list');
//   list.toggleClass('pm-expand');
// })

selector = '.pm-source-list .pm-groups > li > .pm-header .pm-toggle';
jQuery(document).on('click', selector, function (event) {
  event.preventDefault();
  var e = jQuery(event.target);
  var group = e.parents('.pm-groups > li');
  group.toggleClass('pm-expand');
});
jQuery(document).on('click', '.pm-submit .button_middle', function (event) {
  var widget = jQuery(event.target).closest('.pm-submit');
  var submit = widget.find('input[type=submit]');
  if (submit.length == 1) {
    submit.click();
  } else {
    var form = jQuery(event.target).closest('form');
    form[0].submit();
  }
});
jQuery(document).on('click', '.row-adder', function (event) {
  window.ev = event;
  var target = jQuery(event.target);
  //var list = target.parents('table');
  var row = target.parents('tr');
  var clone = row.clone();
  var i = parseInt(row.find('input').attr('id').split('_')[2]) + 1;
  clone.find('input').attr('id', 'search_value_' + i).attr('name', 'search_value[' + i + ']').attr('tabindex', i + 1);
  row.find('.row-adder').remove();
  row.after(clone);
  //Pandora.Behaviour.apply(false, added_row);
});

/* section handling */

jQuery(document).on('click', '.pm-section .pm-toggle', function (event) {
  event.preventDefault();
  var section = jQuery(event.target).closest('.section_wrap');
  section.toggleClass('pm-expanded');
});

/* uploads: multi edit */

jQuery(document).on('click', '.pm-edit-selected .button_middle', function (event) {
  var url = Pandora.root_url + Upgrade.current_locale() + '/uploads/edit_selected';
  var params = jQuery(".image_list input[name='image[]']:checked").map(function (i, e) {
    var upload_id = jQuery(e).parents('.list_row').attr('data-upload-id');
    return 'uploads[]=' + upload_id;
  }).toArray();
  url += '?' + params.join('&');
  document.location.href = url;
});

/* comment handling */

jQuery(document).on('click', '.pm-new-comment', function (event) {
  event.preventDefault();
  var section = jQuery(event.target).closest('.section_wrap');
  var section_toggle = section.find('.section_toggle');
  var target = section.find('.pm-comments');
  if (!target.hasClass('pm-new')) {
    target.addClass('pm-new');
    if (!section.hasClass('pm-expanded')) {
      // the section can be expandend, so its not expanded
      section.addClass('pm-expanded');
    }
  } else {
    target.removeClass('pm-new');
    if (section.find('.comment').length == 0) {
      // there are no comments, so we close the section
      section.removeClass('pm-expanded');
    }
  }
});
jQuery(document).on('click', '.pm-edit-comment', function (event) {
  event.preventDefault();
  jQuery(event.target).closest('.comment').toggleClass('pm-edit');
});
jQuery(document).on('click', '.pm-reply-to-comment', function (event) {
  event.preventDefault();
  jQuery(event.target).closest('.comment').toggleClass('pm-reply-to');
});

/* "add to sidebar" handling */

// box delete xhr success (collection)
// jQuery(document).on('ajax:success', '.sidebar_box [data-method=DELETE]', function(event, data, status, xhr) {
//   // for some reason, the args are not set as expected
//   data = event.originalEvent.detail[2].responseText;
//   jQuery('#boxes').html(data);
// });

// // box add xhr success (image)
// jQuery(document).on('ajax:success', '.popup_footer a[data-method=POST]', function(event, data, status, xhr) {
//   // for some reason, the args are not set as expected
//   data = event.originalEvent.detail[2].responseText;
//   jQuery('#boxes').html(data);
// });

// // box add xhr success (collection)
// jQuery(document).on('ajax:success', '.collection-to-sidebar', function(event, data, status, xhr) {
//   // for some reason, the args are not set as expected
//   data = event.originalEvent.detail[2].responseText;
//   jQuery('#boxes').html(data);
// });

// // box add xhr success (collection)
// jQuery(document).on('ajax:complete', '.on-complete-apply-behavior', function(event, data, status, xhr) {
//   // for some reason, the args are not set as expected
//   data = event.originalEvent.detail[0].responseText;
//   // find first parent that specifies data-update attribute
//   let id = jQuery(event.target).parents('[data-update]').attr('data-update');
//   jQuery('#' + id).html(data);
//   Pandora.Behaviour.apply(true, id);
// });

class Boxes {
  constructor(selector) {
    this.root = jQuery(selector);
    this.render = this.render.bind(this);
    this.renderId = this.renderId.bind(this);
    this.onCreate = this.onCreate.bind(this);
    this.onDestroy = this.onDestroy.bind(this);
    this.onToggle = this.onToggle.bind(this);
    this.onReorder = this.onReorder.bind(this);
    this.onPaginate = this.onPaginate.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
  }
  fetchAll() {
    const url = '/' + Upgrade.current_locale() + '/boxes';
    return jQuery.ajax({
      url: url
    }).then(this.render);
  }
  fetchId(id, page = 1) {
    const url = '/' + Upgrade.current_locale() + '/boxes/' + id;
    return jQuery.ajax({
      url: url,
      data: {
        page: page,
        per_page: 6
      }
    });
  }
  render(html) {
    this.root.html(html);
  }
  renderId(id, html) {
    const box = this.root.find(`.sidebar_box[data-id='${id}']`);
    // console.log(box)
    box.replaceWith(html);
  }
  destroy(id) {
    const url = '/' + Upgrade.current_locale() + '/boxes/' + id;
    return jQuery.ajax({
      type: 'DELETE',
      url: url
    }).then(this.render);
  }
  create(type, id) {
    const url = '/' + Upgrade.current_locale() + '/boxes';
    return jQuery.ajax({
      type: 'POST',
      url: url,
      data: {
        box: {
          ref_type: type,
          [`${type}_id`]: id
        }
      }
    }).then(this.render);
  }
  toggle(id) {
    const url = `/${Upgrade.current_locale()}/boxes/${id}/toggle`;
    return jQuery.ajax({
      type: 'POST',
      url: url
    }).then(this.render);
  }
  reorder(ids) {
    const url = `/${Upgrade.current_locale()}/boxes/reorder`;
    return jQuery.ajax({
      type: 'POST',
      url: url,
      data: {
        ids: ids
      }
    });
  }
  onCreate(event) {
    event.preventDefault();
    var a = jQuery(event.currentTarget);
    var type = a.data('type');
    var id = a.data('id');
    this.create(type, id).then(this.render);
  }
  onDestroy(event) {
    event.preventDefault();
    var a = jQuery(event.currentTarget);
    var msg = a.data('pm-confirm');
    var id = a.data('id');
    if (window.confirm(msg)) {
      this.destroy(id).then(this.render);
    }
  }
  onToggle(event) {
    event.preventDefault();
    var a = jQuery(event.currentTarget);
    var id = a.data('id');
    this.toggle(id).then(this.render);
  }
  onReorder(event, ui) {
    const ids = this.root.find('.sidebar_box').toArray().map(e => e.getAttribute('data-id'));
    this.reorder(ids);
  }
  onPaginate(event) {
    event.preventDefault();
    var a = jQuery(event.currentTarget);
    var id = a.closest('.sidebar_box').data('id');
    var page = a.attr('href').match(/page=(\d+)/)[1];
    this.fetchId(id, page).then(html => {
      this.renderId(id, html);
    });
  }
  onSubmit(event) {
    event.preventDefault();
    event.stopImmediatePropagation();
    const form = jQuery(event.target).closest('form');
    const id = form.closest('.sidebar_box').data('id');
    const page = form.find('input[name=page]').val();
    this.fetchId(id, page).then(html => {
      this.renderId(id, html);
    });
  }
  init() {
    this.fetchAll();
    this.root.sortable({
      handle: '.box_handle',
      opacity: 0.5
    });
    this.root.on('sortupdate', this.onReorder);
    this.root.on('click', 'a.pm-from-sidebar', this.onDestroy);
    this.root.on('click', 'a.pm-toggle-box', this.onToggle);
    this.root.on('click', '.pagination a', this.onPaginate);
    this.root.on('submit', '.pagination form', this.onSubmit);
    this.root.on('click', '.pagination .button_middle', this.onSubmit);
    jQuery(document).on('click', 'a.pm-to-sidebar', this.onCreate);
  }
}

/* pagination */

// handle submit for pagination when triggerd via enter key
jQuery(document).on('submit', 'form.page_form', function (event) {
  event.preventDefault();
  var url = document.location.href;
  var newPage = jQuery(event.target).find('input[type=text]').val();
  if (url.match(/[\?\&]page=\d+/)) {
    url = url.replace(/([\?\&])page=\d+/, '$1page=' + newPage);
  } else {
    if (url.match(/\?/)) {
      url += '&page=' + newPage;
    } else {
      url += '?page=' + newPage;
    }
  }
  window.location.href = url;
});

// // we also need to handle the submit event for the sidebar pagination
// jQuery(document).on('click', '.box_content .upgrade-autosubmit', function(event){
//   event.preventDefault();

//   let e = jQuery(event.target);
//   let form = e.parents('form');
//   let page = form.find('[name=page]').val();

//   if (page) {
//     jQuery.ajax({
//       type: 'GET',
//       url: form.attr('action'),
//       data: form.serialize(),
//       success: function(data) {
//         e.parents('.box_content').html(data);
//       }
//     })
//   }
// });

/* handle ratings */

jQuery(document).on('click', '.pm-ratings img', function (event) {
  event.preventDefault();
  var pid = jQuery(event.currentTarget).attr('data-pid');
  var rating = jQuery(event.currentTarget).attr('data-quality');
  var container = jQuery(event.currentTarget).closest('.pm-ratings');
  var rated = container.hasClass('pm-rated');
  if (rated) {
    return true;
  }

  // console.log(pid, rating, rated);
  // return 6

  jQuery.ajax({
    url: '/' + Upgrade.current_locale() + '/image/' + pid + '/vote',
    data: {
      rating: rating
    },
    success: function (html) {
      container.html(html);
    }
  });
});

// keyword admin

class PmKeywordAdmin {
  constructor() {
    jQuery(document).on('click', '.pm-keyword', event => {
      var element = jQuery(event.currentTarget);
      element.toggleClass('selected');
      this.updateOptions();
    });
    jQuery(document).on('click', '.pm-keyword a', event => {
      event.stopPropagation();
    });
    jQuery(document).on('click', '.pm-deselect-keywords', event => {
      event.preventDefault();
      this.selected().removeClass('selected');
      this.updateOptions();
    });
    jQuery(document).on('change', '.pm-merge-control select', event => {
      this.submit();
    });
    jQuery(document).on('change', '.pm-show-controls', event => {
      var val = jQuery(event.currentTarget).prop('checked');
      if (val) {
        jQuery('.keyword-list').addClass('pm-controls');
      } else {
        jQuery('.keyword-list').removeClass('pm-controls');
      }
    });
  }
  selected() {
    return jQuery('.keyword-list .pm-keyword.selected');
  }
  anySelected() {
    return this.selected().length > 0;
  }
  mergeControl() {
    return jQuery('.pm-merge-control');
  }
  mergeSelect() {
    return this.mergeControl().find('select');
  }
  mergeForm() {
    return this.mergeSelect().parents('form');
  }
  updateOptions() {
    this.mergeSelect().empty();
    if (this.anySelected()) {
      this.mergeControl().show();
      this.mergeSelect().append('<option selected>');
      for (var e of this.selected()) {
        var o = document.createElement('option');
        o.innerHTML = e.getAttribute('data-title');
        o.setAttribute('value', e.getAttribute('data-id'));
        this.mergeSelect().append(o);
      }
    } else {
      this.mergeControl().hide();
    }
  }
  submit() {
    var target_id = this.mergeSelect().val();
    var url = '/' + Upgrade.current_locale() + '/keywords/' + target_id + '/merge';
    var other_ids = [];
    for (var e of this.selected()) {
      other_ids.push(e.getAttribute('data-id'));
    }
    // console.log(target_id, url, other_ids.join(','))
    this.mergeForm().attr('action', url);
    this.mergeForm().find('input[name=other_ids]').val(other_ids.join(','));
    this.mergeForm().submit();
  }
}
var keyword_admin = new PmKeywordAdmin();

/* hide/unhide user database quota */
jQuery(document).ready(function () {
  Upgrade.displaySourceQuota(jQuery("#source_kind"));
  jQuery("#source_kind").change(function () {
    Upgrade.displaySourceQuota(jQuery(this));
  });
  const boxes = new Boxes('#boxes');
  boxes.init();
});

/* swap en/de keyword titles in keyword form */
jQuery(document).ready(function (event) {
  jQuery('a.pm-swap-keyword-titles').on('click', function (event) {
    console.log('bal');
    event.preventDefault();
    const en_input = jQuery('#keyword_title');
    const de_input = jQuery('#keyword_title_de');
    const tmp = en_input.val();
    en_input.val(de_input.val());
    de_input.val(tmp);
  });
});

/* restore store-in-collection button state on browser back navigation */
jQuery(document).ready(function () {
  var checked_images = jQuery('input[type=checkbox]:checked');
  if (checked_images.length) {
    jQuery('.store_controls .popup_toggle').removeClass(['disable', 'disabled']);
  }
});

// toggle display of all artists (instead of only the first 2)
function toggleAllArtists(event) {
  event.preventDefault();
  var a = event.currentTarget;
  var labels = a.querySelectorAll('span');
  for (var label of labels) {
    label.classList.toggle('d-none');
  }
  var nodes = a.parentElement.querySelectorAll('.artist');
  artists = Array.from(nodes).slice(2);
  for (var artist of artists) {
    artist.classList.toggle('d-none');
  }
}
