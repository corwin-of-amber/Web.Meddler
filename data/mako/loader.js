/** @type {boolean} */
var isAndroid = /android/gi.test(navigator.appVersion);
/** @type {boolean} */
var isChromeNotMobile = !!window.chrome && (!isAndroid && !/iPad|iPhone|iPod/.test(navigator.platform));
/** @type {boolean} */
var isChromeVersion = isChromeNotMobile && 54 < navigator.appVersion.match(/(chrome(?=\/))\/?\s*(\d+)/i)[2];
/** @type {boolean} */
var isDevEnvironment = !!location.hostname.match("(int).mako.co.il");
/** @type {boolean} */
var isEdge = /Edge\//gi.test(navigator.appVersion);
/** @type {boolean} */
var isFirefox = "undefined" !== typeof InstallTrigger;
var isSafari = /constructor/i.test(window.HTMLElement) || function(dstUri) {
  return "[object SafariRemoteNotification]" === dstUri.toString();
}(!window.safari || safari.pushNotification);
/** @type {boolean} */
var isMac = 0 <= navigator.platform.toUpperCase().indexOf("MAC");
/** @type {string} */
var query = window.location.search.substring(1);
/** @type {Array.<string>} */
var vars = query.split("&");
/** @type {string} */
var noChrome = "";
window.staticResourcesUriPrefix = window.staticResourcesUriPrefix.replace("http:", "");
/** @type {number} */
var i = 0;
for (;i < vars.length;i++) {
  /** @type {Array.<string>} */
  var pair = vars[i].split("=");
  if ("t" === pair[0]) {
    /** @type {string} */
    noChrome = pair[1].toLowerCase();
  }
}
/** @type {boolean} */
var isHTMLWon = false;
/** @type {number} */
var html5Promil = 1001;
try {
  var rand = localStorage.p13n_user_group;
  if (!localStorage.p13n_user_group) {
    /** @type {number} */
    rand = localStorage.p13n_user_group = Math.floor(1E3 * Math.random());
  }
  if (html5Promil > rand) {
    /** @type {boolean} */
    isHTMLWon = true;
  }
} catch (a$$1) {
}
var scriptsAndLinks = {
  social : "/js/makotv/social.js",
  app : "/js/makotv/app.js",
  style : "/css/makotv/style.css"
};
if (isDevEnvironment) {
  /**
   * @param {Event} evt
   * @return {undefined}
   */
  var selectChange = function(evt) {
    localStorage.vos = evt.target.value;
    location.reload();
    console.log("version", evt.target.value);
  };
  /** @type {Array} */
  var versionArrray = ["master", "develop", "master_unminified", "develop_unminified"];
  var versionOnStorage = localStorage.vos;
  if (!versionOnStorage) {
    /** @type {string} */
    versionOnStorage = localStorage.vos = "master";
  }
  /** @type {Element} */
  var divElem = document.createElement("div");
  /** @type {string} */
  divElem.id = "version";
  /** @type {Element} */
  var selectElem = document.createElement("select");
  /** @type {function (Event): undefined} */
  selectElem.onchange = selectChange;
  /** @type {number} */
  i = 0;
  for (;i < versionArrray.length;i++) {
    /** @type {Element} */
    var optionElem = document.createElement("option");
    optionElem.value = versionArrray[i];
    optionElem.innerHTML = versionArrray[i];
    if (versionOnStorage == versionArrray[i]) {
      /** @type {boolean} */
      optionElem.selected = true;
    }
    selectElem.appendChild(optionElem);
  }
  var style = {
    position : "fixed",
    top : 0,
    right : 0,
    zIndex : 1E4
  };
  var item;
  for (item in style) {
    divElem.style[item] = style[item];
  }
  divElem.appendChild(selectElem);
  document.body.appendChild(divElem);
  scriptsAndLinks = {
    social : "/js/makotv/" + versionOnStorage + "/social.js",
    app : "/js/makotv/" + versionOnStorage + "/app.js",
    style : "/js/makotv/" + versionOnStorage + "/style.css"
  };
}
window.shouldLoadHTMLVersion = "nochrome" !== noChrome && (isHTMLWon && (isChromeNotMobile || (isEdge || (isFirefox || isSafari && isMac)))) || "chrome" == noChrome;
/** @type {Element} */
var socialScript = document.createElement("script");
/** @type {string} */
socialScript.src = staticResourcesUriPrefix + scriptsAndLinks.social + "?v=181017";
document.head.appendChild(socialScript);
if (shouldLoadHTMLVersion) {
  /** @type {Array} */
  var gtmCodes = ["GTM-MJ2NPR", "GTM-PHR3MZ", "GTM-T87PQS", "GTM-WH7Q78"];
  /** @type {number} */
  i = 0;
  for (;i < gtmCodes.length;i++) {
    var gtmId = gtmCodes[i];
    (function(element, context, elem, year, tagName) {
      element[year] = element[year] || [];
      element[year].push({
        "gtm.start" : (new Date).getTime(),
        event : "gtm.js"
      });
      element = context.getElementsByTagName(elem)[0];
      /** @type {Element} */
      context = context.createElement(elem);
      /** @type {boolean} */
      context.async = true;
      /** @type {string} */
      context.src = "//www.googletagmanager.com/gtm.js?id=" + tagName + ("dataLayer" != year ? "&l=" + year : "");
      element.parentNode.insertBefore(context, element);
    })(window, document, "script", "dataLayer", gtmId);
  }
  /** @type {Element} */
  var main = document.createElement("div");
  /** @type {string} */
  main.id = "app";
  /** @type {string} */
  main.dir = "rtl";
  document.body.appendChild(main);
  /** @type {Element} */
  var script = document.createElement("script");
  /** @type {string} */
  script.src = staticResourcesUriPrefix + scriptsAndLinks.app + "?v=021117";
  /** @type {Element} */
  var script2 = document.createElement("script");
  /**
   * @return {undefined}
   */
  script2.onload = function() {
    console.log("hola loaded");
    if (window.hola_cdn) {
      hola_cdn.init_mako_co_il();
    }
  };
  /** @type {boolean} */
  script2.async = true;
  /** @type {string} */
  script2.src = "//player.h-cdn.com/loader.js?customer=mako_co_il";
  /** @type {Element} */
  var link = document.createElement("link");
  /** @type {string} */
  link.rel = "stylesheet";
  /** @type {string} */
  link.href = staticResourcesUriPrefix + scriptsAndLinks.style + "?v=011117";
  document.head.appendChild(link);
  document.head.appendChild(script);
  /**
   * @return {undefined}
   */
  window.onload = function() {
    document.head.appendChild(script2);
  };
} else {
  /** @type {Array} */
  gtmCodes = ["GTM-T87PQS"];
  /** @type {number} */
  i = 0;
  for (;i < gtmCodes.length;i++) {
    gtmId = gtmCodes[i];
    (function(element, context, elem, year, tagName) {
      element[year] = element[year] || [];
      element[year].push({
        "gtm.start" : (new Date).getTime(),
        event : "gtm.js"
      });
      element = context.getElementsByTagName(elem)[0];
      /** @type {Element} */
      context = context.createElement(elem);
      /** @type {boolean} */
      context.async = true;
      /** @type {string} */
      context.src = "//www.googletagmanager.com/gtm.js?id=" + tagName + ("dataLayer" != year ? "&l=" + year : "");
      element.parentNode.insertBefore(context, element);
    })(window, document, "script", "dataLayer", gtmId);
  }
  if (!window.GoogleAnalyticsObject) {
    /** @type {string} */
    window.GoogleAnalyticsObject = "ga";
    window.ga = window.ga || function() {
      (window.ga.q = window.ga.q || []).push(arguments);
    };
    /** @type {number} */
    window.ga.l = 1 * new Date;
    (function(i, d, tag, path, r, el, s) {
      /** @type {string} */
      i.GoogleAnalyticsObject = r;
      i[r] = i[r] || function() {
        (i[r].q = i[r].q || []).push(arguments);
      };
      /** @type {number} */
      i[r].l = 1 * new Date;
      /** @type {Element} */
      el = d.createElement(tag);
      s = d.getElementsByTagName(tag)[0];
      /** @type {number} */
      el.async = 1;
      /** @type {string} */
      el.src = path;
      s.parentNode.insertBefore(el, s);
    })(window, document, "script", "//www.google-analytics.com/analytics.js", "ga");
    var prmCookie = {};
    /** @type {string} */
    prmCookie.cookieDomain = prmCookie.legacyCookieDomain = "mako.co.il";
    ga("create", "UA-3886828-1", prmCookie);
    ga("create", "UA-47291445-1", {
      name : "private"
    }, prmCookie);
    ga("require", "displayfeatures");
    ga("private.require", "displayfeatures");
    ga("send", "pageview");
    ga("private.send", "pageview");
  }
  var elemntsArray = {
    div : ["in", "in2", "in3", "vodflash"],
    script : [staticResourcesUriPrefix + "/js/scripts/swfobject2.js", staticResourcesUriPrefix + "/js/swfaddress/swfaddress.js", staticResourcesUriPrefix + "/js/bigBrother4.js", staticResourcesUriPrefix + "/combined/JSbundle1.js", "//client.h-cdn.com/loader_mako_co_il.js"],
    link : [staticResourcesUriPrefix + "/css/bigBrother4.css", staticResourcesUriPrefix + "/combined/DTCSSBundle.css", "/vgn-ext-templating/common/styles/vgn-ext-templating.css"]
  };
  window.j$ = $;
  for (elem in elemntsArray) {
    var arrayLength = elemntsArray[elem].length;
    /** @type {number} */
    i = 0;
    for (;i < arrayLength;i++) {
      /** @type {Element} */
      var createElem = document.createElement(elem);
      if ("div" === elem) {
        createElem.id = elemntsArray[elem][i];
        document.body.appendChild(createElem);
      }
      if ("script" === elem) {
        /** @type {string} */
        createElem.type = "text/javascript";
        createElem.src = elemntsArray[elem][i];
        document.head.appendChild(createElem);
      }
      if ("link" === elem) {
        /** @type {string} */
        createElem.rel = "stylesheet";
        createElem.href = elemntsArray[elem][i];
        document.head.appendChild(createElem);
      }
    }
  }
  var _params = {
    allowfullscreen : true,
    allowScriptAccess : "always"
  };
  var _flashvars = {
    vcmid : "",
    domain : flashDomain,
    skin : "vodSkin.swf",
    suggestMore : "0",
    bigSuggestPlayerWidth : 9E5,
    floatingBarWidth : 662,
    floatingBarHeight : 80,
    overlay : "",
    showlogo : 0,
    noRollOut : "true",
    showScreenshot : "true",
    openerUrl : flashOpenUrl,
    statsReportTime : 120,
    protectedContent : "true",
    adBlockScreen : "true",
    cancelAutoplayWithoutPreroll : "false"
  };
  var _attributes = {
    id : "flashvod"
  };
  /**
   * @return {undefined}
   */
  window.onload = function() {
    if (window.hola_cdn) {
      hola_cdn.init_mako_co_il();
    }
    swfobject.embedSWF(isDevEnvironment ? staticResourcesUriPrefix + "/flash_swf/makoTVLoader.swf" : "//www.mako.co.il/html/flash_swf/makoTVLoader.swf", "vodflash", "100%", "100%", "11", staticResourcesUriPrefix + "/flash_swf/expressinstallNew.swf", _flashvars, _params, _attributes);
  };
}
/** @type {Element} */
var collectVODStatsScript = document.createElement("script");
collectVODStatsScript.src = staticResourcesUriPrefix + "/js/scripts/collectVodStatsObject.js";
document.head.appendChild(collectVODStatsScript);
/** @type {Element} */
style = document.createElement("style");
/** @type {string} */
style.innerText = "iframe {display:block}";
document.head.appendChild(style);
