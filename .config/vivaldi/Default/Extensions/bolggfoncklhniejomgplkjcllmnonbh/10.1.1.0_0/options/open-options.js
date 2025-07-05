"use strict";

function checkAuthorization(authorizationToOpenOptions) {
  if (authorizationToOpenOptions === location.hash.split("=")[1]) {
    location.replace(chrome.runtime.getURL('/options/options.html'));
    chrome.storage.local.remove(["authorizationToOpenOptions"]);
  }
}
chrome.storage.local.get(["authorizationToOpenOptions"], onGot => {
  checkAuthorization(onGot.authorizationToOpenOptions);
});
chrome.storage.local.onChanged.addListener(changes => {
  if (changes.authorizationToOpenOptions) {
    checkAuthorization(changes.authorizationToOpenOptions.newValue);
  }
});
//# sourceMappingURL=https://raw.githubusercontent.com/FilipePS/TWP---Source-Maps/main/maps/10.1.1.0/open-options.js.map
