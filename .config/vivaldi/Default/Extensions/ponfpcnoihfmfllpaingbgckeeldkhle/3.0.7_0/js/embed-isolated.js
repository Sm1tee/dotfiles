/*
##
##  Enhancer for YouTube™
##  =====================
##
##  Author: Maxime RF <https://www.mrfdev.com>
##
##  This file is protected by copyright laws and international copyright
##  treaties, as well as other intellectual property laws and treaties.
##
##  All rights not expressly granted to you are retained by the author.
##  Read the license.txt file for more details.
##
##  © MRFDEV.com - All Rights Reserved
##
*/
(c=>{window.wrappedJSObject||(chrome.storage.onChanged.addListener(a=>{for(const b in a)void 0!==a[b].newValue&&Object.hasOwn(c,b)&&document.dispatchEvent(new CustomEvent("efyt-preference-changed",{detail:{name:b,value:a[b].newValue}}))}),chrome.storage.local.get(c,a=>{document.dispatchEvent(new CustomEvent("efyt-init",{detail:{prefs:a,version:chrome.runtime.getManifest().version,messages:{screenshot:chrome.i18n.getMessage("screenshot")}}}))}))})(configEmbed);