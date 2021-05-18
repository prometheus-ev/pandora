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
      var re = Prototype.Browser.IE     ? /MSIE ([0-9\.]+)/m                      :
               Prototype.Browser.Opera  ? /Opera\/([0-9\.]+)/m                    :
               Prototype.Browser.WebKit ? /Version\/([0-9\.]+)/m                  :
               Prototype.Browser.Gecko  ? /Gecko\/[0-9]+\s[A-Za-z]+\/([0-9\.]+)/m : null;

      var match = re && navigator.userAgent.match(re);

      return match ? parseFloat(match[1]) : 0.00;
    }
  });

  Object.extend(Prototype.Browser, {
    Version: Prototype.getBrowserVersion()
  });


  var loajaxStarted = false;
  var loajaxVersion = '1.0.0a1';

  Loajax = Class.create ({
    initialize: function(request) {
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
        window.setTimeout(function(lo) { lo._stop(); }, 50, this); // avoids IE race condition where Ajax call is cached
      }
    },

    _stop: function () {
      var frame_name = this._getFrameName();
      if (!$(frame_name)) {
        return;
      }

      if (window.stop) {
        frames[frame_name].stop();
      }
      else if (document.execCommand) {
        frames[frame_name].document.execCommand("Stop");
      }

      $(frame_name).remove();
      loajaxStarted = false;
    },

    _createIframe: function () {
      var frame_name = this._getFrameName();
      var frame_src = this._getFrameSrc();

      iframe = new Element('iframe', { 'name': frame_name, 'id': frame_name}).setStyle({
        display: 'none'
      });

      Element.insert(document.body, {top: iframe});

      if (this.request.options.loajaxTimeout) {
        frame_src+= frame_src.include('?') ? '&' : '?';
        frame_src+= 't='+this.request.options.loajaxTimeout;
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
      return (this.request.options.loajax || defaultUrl);
    },

    _ignore: function () {
      return !(
        Prototype.Browser.IE     ||
        Prototype.Browser.Gecko  ||
        Prototype.Browser.WebKit ||
       (Prototype.Browser.Opera && Prototype.Browser.Version >= 9.0)
      );
    }
  });

  Ajax.Responders.register({
    onCreate:   function(req) {
      // loajax = new Loajax(req);
      // loajax.start();
    },
    onComplete: function(req) {
      // loajax = new Loajax(req);
      // loajax.stop();
    }
  });
}
