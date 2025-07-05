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
(()=>{document.title="Enhancer for YouTube\u2122";var c=document.location.href.split("/pop-up-player/")[1],a=document.createElement("iframe");a.setAttribute("id","pop-up-player");a.setAttribute("allow","accelerometer;autoplay;encrypted-media;gyroscope;picture-in-picture");a.setAttribute("allowfullscreen","");a.setAttribute("src","https://www.youtube.com/embed/"+c);a.addEventListener("DOMContentLoaded",()=>{document.title=a.contentDocument.title});a.addEventListener("load",async()=>{var b=
await chrome.storage.local.get({playlist:{}});0<Object.keys(b.playlist).length&&(a.contentDocument.defaultView.document.dispatchEvent(new a.contentDocument.defaultView.CustomEvent("efyt-pop-up-player-message",{detail:{message:"load-playlist",playlist:b.playlist}})),chrome.storage.local.remove("playlist"))},{once:!0});document.body.appendChild(a)})();