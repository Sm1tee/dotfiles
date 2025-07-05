"use strict";

// if the site has any restriction that prevent contentScript from running, then this listener will not work and the backgroundScript will know that
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === "contentScriptIsInjected") {
    sendResponse(true);
  }
});
//# sourceMappingURL=https://raw.githubusercontent.com/FilipePS/TWP---Source-Maps/main/maps/10.1.1.0/checkScriptIsInjected.js.map
