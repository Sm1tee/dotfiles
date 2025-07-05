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
(b=>{function q(){var a=[],c;for([c,e]of Object.entries(d.customcolors)){if("--shadow"===c){var f=e.replace("#","");var e=parseInt(f.substring(0,2),16);var r=parseInt(f.substring(2,4),16);f=parseInt(f.substring(4,6),16);e=`0 1px .5px rgba(${e}, ${r}, ${f}, .2)`}a.push(c+":"+e)}return":root{"+a.join(";")+"}"}function k(){if(d.darktheme&&"default-dark"!==d.theme){var a=b.createElement("link");a.id="efyt-dark-theme";a.rel="stylesheet";a.href=("enhanced-dark"===d.theme?g+"main.css?v=":h+
"youtube-deep-dark.material.css?v=")+l;b.head.appendChild(a)}}function m(){if(d.darktheme&&"default-dark"!==d.theme){if("enhanced-dark"===d.theme||"youtube-deep-dark"===d.theme){var a=b.createElement("link");a.id="efyt-dark-theme-colors";a.rel="stylesheet";a.href="enhanced-dark"===d.theme?g+d.themevariant:h+d.vendorthemevariant}else"youtube-deep-dark-custom"===d.theme&&(a=b.createElement("style"),a.id="efyt-dark-theme-colors",a.textContent=q());b.head.appendChild(a)}}function n(){if(d.customtheme){var a=
b.createElement("style");a.id="efyt-custom-theme";a.textContent=d.customcss;b.head.appendChild(a)}}var d,l,g,h,p;b.addEventListener("DOMContentLoaded",()=>{d?(m(),k(),n()):p=[m,k,n]},{once:!0});b.addEventListener("efyt-init",a=>{d=a.detail.prefs;l=a.detail.version;g=a.detail.themes;h=a.detail.vendorthemes;p&&p.forEach(c=>{c()})},{once:!0});b.addEventListener("efyt-preference-changed",a=>{var c=a.detail.name;a=a.detail.value;d[c]=a;switch(c){case "customcolors":if(a=b.head.querySelector("#efyt-dark-theme-colors"))a.textContent=
q();break;case "customcss":if(c=b.head.querySelector("#efyt-custom-theme"))c.textContent=a,b.head.appendChild(c);break;case "customtheme":c=b.head.querySelector("#efyt-custom-theme");a&&!c?n():!a&&c&&b.head.removeChild(c);break;case "darktheme":case "theme":"darktheme"===c&&!a||"default-dark"===d.theme?(a=b.head.querySelector("#efyt-dark-theme"),c=b.head.querySelector("#efyt-dark-theme-colors"),a&&b.head.removeChild(a),c&&b.head.removeChild(c)):((a=b.head.querySelector("#efyt-dark-theme-colors"))&&
b.head.removeChild(a),m(),(a=b.head.querySelector("#efyt-dark-theme"))?a.href=("enhanced-dark"===d.theme?g+"main.css?v=":h+"youtube-deep-dark.material.css?v=")+l:k(),d.customtheme&&(c=b.head.querySelector("#efyt-custom-theme"))&&b.head.appendChild(c));break;case "themevariant":case "vendorthemevariant":if(c=b.head.querySelector("#efyt-dark-theme-colors"),null==c?0:c.hasAttribute("href"))c.href=("enhanced-dark"===d.theme?g:h)+a}})})(document);