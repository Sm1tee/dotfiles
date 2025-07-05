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
(async a=>{(await chrome.storage.local.get({convertshorts:a.convertshorts})).convertshorts&&/^\/shorts\/[^\/]+/.test(document.location.pathname)&&document.location.replace("https://www.youtube.com/watch?v="+document.location.pathname.match(/\/shorts\/([^\/]+)/)[1])})(config);