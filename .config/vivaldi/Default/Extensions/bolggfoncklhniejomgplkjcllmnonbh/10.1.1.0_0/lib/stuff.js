"use strict";

function tabsCreate(url, callback = null) {
  const userAgent = navigator.userAgent;
  const isMobile = userAgent.match(/Android/i) || userAgent.match(/BlackBerry/i) || userAgent.match(/iPhone|iPad|iPod/i) || userAgent.match(/Opera Mini/i) || userAgent.match(/IEMobile/i) || userAgent.match(/WPDesktop/i);
  if (isMobile) {
    chrome.tabs.create({
      url
    }, callback);
  } else {
    chrome.tabs.query({
      active: true,
      currentWindow: true
    }, tabs => {
      var _tabs$;
      const openerTabId = (_tabs$ = tabs[0]) !== null && _tabs$ !== void 0 && _tabs$.id ? tabs[0].id : null;
      chrome.tabs.create({
        url,
        openerTabId
      }, callback);
    });
  }
}
//# sourceMappingURL=https://raw.githubusercontent.com/FilipePS/TWP---Source-Maps/main/maps/10.1.1.0/stuff.js.map
