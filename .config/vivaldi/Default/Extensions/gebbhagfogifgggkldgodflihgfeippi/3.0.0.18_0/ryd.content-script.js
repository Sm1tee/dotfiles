/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ 805:
/***/ ((module, __unused_webpack___webpack_exports__, __webpack_require__) => {

__webpack_require__.a(module, async (__webpack_handle_async_dependencies__, __webpack_async_result__) => { try {
/* harmony import */ var _src_buttons__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(423);
/* harmony import */ var _src_state__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(935);
/* harmony import */ var _src_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(67);
/* harmony import */ var _src_events__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(27);
//---   Import Button Functions   ---//


//---   Import State Functions   ---//


//---   Import Video & Browser Functions   ---//



await (0,_src_state__WEBPACK_IMPORTED_MODULE_1__/* .initExtConfig */ .qg)();

let jsInitChecktimer = null;
let isSetInitialStateDone = false;

async function setEventListeners(evt) {
  async function checkForJS_Finish() {
    try {
      if ((0,_src_state__WEBPACK_IMPORTED_MODULE_1__/* .isShorts */ .ol)() || ((0,_src_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getButtons */ .hS)()?.offsetParent && (0,_src_utils__WEBPACK_IMPORTED_MODULE_2__/* .isVideoLoaded */ .x8)())) {
        clearInterval(jsInitChecktimer);
        jsInitChecktimer = null;
        (0,_src_events__WEBPACK_IMPORTED_MODULE_3__/* .createSmartimationObserver */ .Q$)();
        (0,_src_events__WEBPACK_IMPORTED_MODULE_3__/* .addLikeDislikeEventListener */ .G_)();
        await (0,_src_state__WEBPACK_IMPORTED_MODULE_1__/* .setInitialState */ .KY)();
        isSetInitialStateDone = true;
        (0,_src_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.onChanged.addListener(_src_events__WEBPACK_IMPORTED_MODULE_3__/* .storageChangeHandler */ .F6);
      }
    } catch (exception) {
      if (!isSetInitialStateDone) {
        (0,_src_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)("error");
        await (0,_src_state__WEBPACK_IMPORTED_MODULE_1__/* .setInitialState */ .KY)();
      }
    }
  }

  if (jsInitChecktimer !== null) clearInterval(jsInitChecktimer);
  jsInitChecktimer = setInterval(await checkForJS_Finish, 111);
}

await setEventListeners();

document.addEventListener("yt-navigate-finish", async function (event) {
  if (jsInitChecktimer !== null) clearInterval(jsInitChecktimer);
  await setEventListeners();
});

const s = document.createElement("script");
s.src = chrome.runtime.getURL("menu-fixer.js");
s.onload = function () {
  this.remove();
};
// see also "Dynamic values in the injected code" section in this answer
(document.head || document.documentElement).appendChild(s);

__webpack_async_result__();
} catch(e) { __webpack_async_result__(e); } }, 1);

/***/ }),

/***/ 910:
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   k: () => (/* binding */ createRateBar)
/* harmony export */ });
/* harmony import */ var _buttons__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(423);
/* harmony import */ var _state__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(935);
/* harmony import */ var _utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(67);




function createRateBar(likes, dislikes) {
  let rateBar = document.getElementById("ryd-bar-container");
  if (!(0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isLikesDisabled */ .$L)()) {
    // sometimes rate bar is hidden
    if (rateBar && !(0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .isInViewport */ .v4)(rateBar)) {
      rateBar.remove();
      rateBar = null;
    }

    const widthPx =
      parseFloat(window.getComputedStyle((0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)()).width) +
      parseFloat(window.getComputedStyle((0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeButton */ .x8)()).width) +
      ((0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isRoundedDesign */ .MB)() ? 0 : 8);

    const widthPercent =
      likes + dislikes > 0 ? (likes / (likes + dislikes)) * 100 : 50;

    var likePercentage = parseFloat(widthPercent.toFixed(1));
    const dislikePercentage = (100 - likePercentage).toLocaleString();
    likePercentage = likePercentage.toLocaleString();

    if (_state__WEBPACK_IMPORTED_MODULE_1__/* .extConfig */ .zO.showTooltipPercentage) {
      var tooltipInnerHTML;
      switch (_state__WEBPACK_IMPORTED_MODULE_1__/* .extConfig */ .zO.tooltipPercentageMode) {
        case "dash_dislike":
          tooltipInnerHTML = `${likes.toLocaleString()}&nbsp;/&nbsp;${dislikes.toLocaleString()}&nbsp;&nbsp;-&nbsp;&nbsp;${dislikePercentage}%`;
          break;
        case "both":
          tooltipInnerHTML = `${likePercentage}%&nbsp;/&nbsp;${dislikePercentage}%`;
          break;
        case "only_like":
          tooltipInnerHTML = `${likePercentage}%`;
          break;
        case "only_dislike":
          tooltipInnerHTML = `${dislikePercentage}%`;
          break;
        default: // dash_like
          tooltipInnerHTML = `${likes.toLocaleString()}&nbsp;/&nbsp;${dislikes.toLocaleString()}&nbsp;&nbsp;-&nbsp;&nbsp;${likePercentage}%`;
      }
    } else {
      tooltipInnerHTML = `${likes.toLocaleString()}&nbsp;/&nbsp;${dislikes.toLocaleString()}`;
    }

    if (!(0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isShorts */ .ol)()) {
      if (!rateBar && !(0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isMobile */ .tq)()) {
        let colorLikeStyle = "";
        let colorDislikeStyle = "";
        if (_state__WEBPACK_IMPORTED_MODULE_1__/* .extConfig */ .zO.coloredBar) {
          colorLikeStyle = "; background-color: " + (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(true);
          colorDislikeStyle = "; background-color: " + (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(false);
        }
        let actions =
          (0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isNewDesign */ .am)() && (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getButtons */ .hS)().id === "top-level-buttons-computed"
            ? (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getButtons */ .hS)()
            : document.getElementById("menu-container");
        (
          actions ||
          document.querySelector("ytm-slim-video-action-bar-renderer")
        ).insertAdjacentHTML(
          "beforeend",
          `
              <div class="ryd-tooltip ryd-tooltip-${(0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isNewDesign */ .am)() ? "new" : "old"}-design" style="width: ${widthPx}px">
              <div class="ryd-tooltip-bar-container">
                <div
                    id="ryd-bar-container"
                    style="width: 100%; height: 2px;${colorDislikeStyle}"
                    >
                    <div
                      id="ryd-bar"
                      style="width: ${widthPercent}%; height: 100%${colorLikeStyle}"
                      ></div>
                </div>
              </div>
              <tp-yt-paper-tooltip position="top" id="ryd-dislike-tooltip" class="style-scope ytd-sentiment-bar-renderer" role="tooltip" tabindex="-1">
                <!--css-build:shady-->${tooltipInnerHTML}
              </tp-yt-paper-tooltip>
              </div>
      		`,
        );

        if ((0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isNewDesign */ .am)()) {
          // Add border between info and comments
          let descriptionAndActionsElement = document.getElementById("top-row");
          descriptionAndActionsElement.style.borderBottom =
            "1px solid var(--yt-spec-10-percent-layer)";
          descriptionAndActionsElement.style.paddingBottom = "10px";

          // Fix like/dislike ratio bar offset in new UI
          document.getElementById("actions-inner").style.width = "revert";
          if ((0,_state__WEBPACK_IMPORTED_MODULE_1__/* .isRoundedDesign */ .MB)()) {
            document.getElementById("actions").style.flexDirection =
              "row-reverse";
          }
        }
      } else {
        document.querySelector(`.ryd-tooltip`).style.width = widthPx + "px";
        document.getElementById("ryd-bar").style.width = widthPercent + "%";
        document.querySelector("#ryd-dislike-tooltip > #tooltip").innerHTML =
          tooltipInnerHTML;
        if (_state__WEBPACK_IMPORTED_MODULE_1__/* .extConfig */ .zO.coloredBar) {
          document.getElementById("ryd-bar-container").style.backgroundColor =
            (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(false);
          document.getElementById("ryd-bar").style.backgroundColor =
            (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(true);
        }
      }
    }
  } else {
    (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)("removing bar");
    if (rateBar) {
      rateBar.parentNode.removeChild(rateBar);
    }
  }
}




/***/ }),

/***/ 423:
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   $1: () => (/* binding */ checkForSignInButton),
/* harmony export */   Eq: () => (/* binding */ getLikeTextContainer),
/* harmony export */   hS: () => (/* binding */ getButtons),
/* harmony export */   x8: () => (/* binding */ getDislikeButton),
/* harmony export */   xP: () => (/* binding */ getDislikeTextContainer),
/* harmony export */   yN: () => (/* binding */ getLikeButton)
/* harmony export */ });
/* harmony import */ var _state__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(935);
/* harmony import */ var _utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(67);



function getButtons() {
  //---   If Watching Youtube Shorts:   ---//
  if ((0,_state__WEBPACK_IMPORTED_MODULE_0__/* .isShorts */ .ol)()) {
    let elements = (0,_state__WEBPACK_IMPORTED_MODULE_0__/* .isMobile */ .tq)()
      ? (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelectorAll */ .Wb)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.shorts.mobile)
      : (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelectorAll */ .Wb)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.shorts.desktop);

    for (let element of elements) {
      //YouTube Shorts can have multiple like/dislike buttons when scrolling through videos
      //However, only one of them should be visible (no matter how you zoom)
      if ((0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .isInViewport */ .v4)(element)) {
        return element;
      }
    }
  }
  //---   If Watching On Mobile:   ---//
  if ((0,_state__WEBPACK_IMPORTED_MODULE_0__/* .isMobile */ .tq)()) {
    return document.querySelector(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.regular.mobile);
  }
  //---   If Menu Element Is Displayed:   ---//
  if ((0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.menuContainer)?.offsetParent === null) {
    return (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.regular.desktopMenu);
    //---   If Menu Element Isn't Displayed:   ---//
  } else {
    return (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.regular.desktopNoMenu);
  }
}

function getLikeButton() {
  return getButtons().children[0].tagName ===
    "YTD-SEGMENTED-LIKE-DISLIKE-BUTTON-RENDERER"
    ? (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.likeButton.segmented) ??
        (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(
          _state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.likeButton.segmentedGetButtons,
          getButtons(),
        )
    : (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(
        _state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.likeButton.notSegmented,
        getButtons(),
      );
}

function getLikeTextContainer() {
  return (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.likeTextContainer, getLikeButton());
}

function getDislikeButton() {
  return getButtons().children[0].tagName ===
    "YTD-SEGMENTED-LIKE-DISLIKE-BUTTON-RENDERER"
    ? (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.dislikeButton.segmented) ??
        (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(
          _state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.dislikeButton.segmentedGetButtons,
          getButtons(),
        )
    : (0,_state__WEBPACK_IMPORTED_MODULE_0__/* .isShorts */ .ol)()
      ? (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(["#dislike-button"], getButtons())
      : (0,_utils__WEBPACK_IMPORTED_MODULE_1__/* .querySelector */ .R2)(
          _state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.buttons.dislikeButton.notSegmented,
          getButtons(),
        );
}

function createDislikeTextContainer() {
  const textNodeClone = (
    getLikeButton().querySelector(
      ".yt-spec-button-shape-next__button-text-content",
    ) ||
    getLikeButton().querySelector("button > div[class*='cbox']") ||
    (
      getLikeButton().querySelector('div > span[role="text"]') ||
      document.querySelector(
        'button > div.yt-spec-button-shape-next__button-text-content > span[role="text"]',
      )
    ).parentNode
  ).cloneNode(true);
  const insertPreChild = getDislikeButton().querySelector("button");
  insertPreChild.insertBefore(textNodeClone, null);
  getDislikeButton()
    .querySelector("button")
    .classList.remove("yt-spec-button-shape-next--icon-button");
  getDislikeButton()
    .querySelector("button")
    .classList.add("yt-spec-button-shape-next--icon-leading");
  if (textNodeClone.querySelector("span[role='text']") === null) {
    const span = document.createElement("span");
    span.setAttribute("role", "text");
    while (textNodeClone.firstChild) {
      textNodeClone.removeChild(textNodeClone.firstChild);
    }
    textNodeClone.appendChild(span);
  }
  textNodeClone.innerText = "";
  return textNodeClone;
}

function getDislikeTextContainer() {
  let result;
  for (const selector of _state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.selectors.dislikeTextContainer) {
    result = getDislikeButton().querySelector(selector);
    if (result !== null) {
      break;
    }
  }
  if (result == null) {
    result = createDislikeTextContainer();
  }
  return result;
}

function checkForSignInButton() {
  if (
    document.querySelector(
      "a[href^='https://accounts.google.com/ServiceLogin']",
    )
  ) {
    return true;
  } else {
    return false;
  }
}




/***/ }),

/***/ 27:
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   F6: () => (/* binding */ storageChangeHandler),
/* harmony export */   G_: () => (/* binding */ addLikeDislikeEventListener),
/* harmony export */   Q$: () => (/* binding */ createSmartimationObserver)
/* harmony export */ });
/* unused harmony exports sendVote, likeClicked, dislikeClicked */
/* harmony import */ var _utils__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(67);
/* harmony import */ var _buttons__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(423);
/* harmony import */ var _state__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(935);
/* harmony import */ var _bar__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(910);





function sendVote(vote) {
  if (_state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.disableVoteSubmission !== true) {
    (0,_utils__WEBPACK_IMPORTED_MODULE_0__/* .getBrowser */ .qs)().runtime.sendMessage({
      message: "send_vote",
      vote: vote,
      videoId: (0,_utils__WEBPACK_IMPORTED_MODULE_0__/* .getVideoId */ .gJ)(window.location.href),
    });
  }
}

function updateDOMDislikes() {
  (0,_state__WEBPACK_IMPORTED_MODULE_2__/* .setDislikes */ .r6)((0,_utils__WEBPACK_IMPORTED_MODULE_0__/* .numberFormat */ .Y4)(_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes));
  (0,_bar__WEBPACK_IMPORTED_MODULE_3__/* .createRateBar */ .k)(_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.likes, _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes);
}

function likeClicked() {
  if ((0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .checkForSignInButton */ .$1)() === false) {
    if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState === _state__WEBPACK_IMPORTED_MODULE_2__/* .DISLIKED_STATE */ .Gv) {
      sendVote(1);
      if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes > 0) _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes--;
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.likes++;
      updateDOMDislikes();
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState = _state__WEBPACK_IMPORTED_MODULE_2__/* .LIKED_STATE */ .AV;
    } else if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState === _state__WEBPACK_IMPORTED_MODULE_2__/* .NEUTRAL_STATE */ .kQ) {
      sendVote(1);
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.likes++;
      updateDOMDislikes();
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState = _state__WEBPACK_IMPORTED_MODULE_2__/* .LIKED_STATE */ .AV;
    } else if ((_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState = _state__WEBPACK_IMPORTED_MODULE_2__/* .LIKED_STATE */ .AV)) {
      sendVote(0);
      if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.likes > 0) _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.likes--;
      updateDOMDislikes();
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState = _state__WEBPACK_IMPORTED_MODULE_2__/* .NEUTRAL_STATE */ .kQ;
    }
    if (_state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.numberDisplayReformatLikes === true) {
      const nativeLikes = (0,_state__WEBPACK_IMPORTED_MODULE_2__/* .getLikeCountFromButton */ .m8)();
      if (nativeLikes !== false) {
        (0,_state__WEBPACK_IMPORTED_MODULE_2__/* .setLikes */ .Xq)((0,_utils__WEBPACK_IMPORTED_MODULE_0__/* .numberFormat */ .Y4)(nativeLikes));
      }
    }
  }
}

function dislikeClicked() {
  if ((0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .checkForSignInButton */ .$1)() == false) {
    if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState === _state__WEBPACK_IMPORTED_MODULE_2__/* .NEUTRAL_STATE */ .kQ) {
      sendVote(-1);
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes++;
      updateDOMDislikes();
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState = _state__WEBPACK_IMPORTED_MODULE_2__/* .DISLIKED_STATE */ .Gv;
    } else if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState === _state__WEBPACK_IMPORTED_MODULE_2__/* .DISLIKED_STATE */ .Gv) {
      sendVote(0);
      if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes > 0) _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes--;
      updateDOMDislikes();
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState = _state__WEBPACK_IMPORTED_MODULE_2__/* .NEUTRAL_STATE */ .kQ;
    } else if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState === _state__WEBPACK_IMPORTED_MODULE_2__/* .LIKED_STATE */ .AV) {
      sendVote(-1);
      if (_state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.likes > 0) _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.likes--;
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.dislikes++;
      updateDOMDislikes();
      _state__WEBPACK_IMPORTED_MODULE_2__/* .storedData */ .vk.previousState = _state__WEBPACK_IMPORTED_MODULE_2__/* .DISLIKED_STATE */ .Gv;
      if (_state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.numberDisplayReformatLikes === true) {
        const nativeLikes = (0,_state__WEBPACK_IMPORTED_MODULE_2__/* .getLikeCountFromButton */ .m8)();
        if (nativeLikes !== false) {
          (0,_state__WEBPACK_IMPORTED_MODULE_2__/* .setLikes */ .Xq)((0,_utils__WEBPACK_IMPORTED_MODULE_0__/* .numberFormat */ .Y4)(nativeLikes));
        }
      }
    }
  }
}

function addLikeDislikeEventListener() {
  if (window.rydPreNavigateLikeButton !== (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getLikeButton */ .yN)()) {
    (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getLikeButton */ .yN)().addEventListener("click", likeClicked);
    (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getLikeButton */ .yN)().addEventListener("touchstart", likeClicked);
    if ((0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getDislikeButton */ .x8)()) {
      (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getDislikeButton */ .x8)().addEventListener("click", dislikeClicked);
      (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getDislikeButton */ .x8)().addEventListener("touchstart", dislikeClicked);
      (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getDislikeButton */ .x8)().addEventListener("focusin", updateDOMDislikes);
      (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getDislikeButton */ .x8)().addEventListener("focusout", updateDOMDislikes);
    }
    window.rydPreNavigateLikeButton = (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getLikeButton */ .yN)();
  }
}

let smartimationObserver = null;

function createSmartimationObserver() {
  if (!smartimationObserver) {
    smartimationObserver = (0,_utils__WEBPACK_IMPORTED_MODULE_0__/* .createObserver */ .zo)(
      {
        attributes: true,
        subtree: true,
        childList: true,
      },
      updateDOMDislikes,
    );
    smartimationObserver.container = null;
  }

  const smartimationContainer = (0,_buttons__WEBPACK_IMPORTED_MODULE_1__/* .getButtons */ .hS)().querySelector("yt-smartimation");
  if (
    smartimationContainer &&
    smartimationObserver.container != smartimationContainer
  ) {
    (0,_utils__WEBPACK_IMPORTED_MODULE_0__/* .cLog */ .D2)("Initializing smartimation mutation observer");
    smartimationObserver.disconnect();
    smartimationObserver.observe(smartimationContainer);
    smartimationObserver.container = smartimationContainer;
  }
}

function storageChangeHandler(changes, area) {
  if (changes.disableVoteSubmission !== undefined) {
    handleDisableVoteSubmissionChangeEvent(
      changes.disableVoteSubmission.newValue,
    );
  }
  if (changes.coloredThumbs !== undefined) {
    handleColoredThumbsChangeEvent(changes.coloredThumbs.newValue);
  }
  if (changes.coloredBar !== undefined) {
    handleColoredBarChangeEvent(changes.coloredBar.newValue);
  }
  if (changes.colorTheme !== undefined) {
    handleColorThemeChangeEvent(changes.colorTheme.newValue);
  }
  if (changes.numberDisplayFormat !== undefined) {
    handleNumberDisplayFormatChangeEvent(changes.numberDisplayFormat.newValue);
  }
  if (changes.numberDisplayReformatLikes !== undefined) {
    handleNumberDisplayReformatLikesChangeEvent(
      changes.numberDisplayReformatLikes.newValue,
    );
  }
}

function handleDisableVoteSubmissionChangeEvent(value) {
  _state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.disableVoteSubmission = value;
}

function handleColoredThumbsChangeEvent(value) {
  _state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.coloredThumbs = value;
}

function handleColoredBarChangeEvent(value) {
  _state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.coloredBar = value;
}

function handleColorThemeChangeEvent(value) {
  if (!value) value = "classic";
  _state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.colorTheme = value;
}

function handleNumberDisplayFormatChangeEvent(value) {
  _state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.numberDisplayFormat = value;
}

function handleNumberDisplayReformatLikesChangeEvent(value) {
  _state__WEBPACK_IMPORTED_MODULE_2__/* .extConfig */ .zO.numberDisplayReformatLikes = value;
}




/***/ }),

/***/ 935:
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   $L: () => (/* binding */ isLikesDisabled),
/* harmony export */   AV: () => (/* binding */ LIKED_STATE),
/* harmony export */   Gv: () => (/* binding */ DISLIKED_STATE),
/* harmony export */   KY: () => (/* binding */ setInitialState),
/* harmony export */   MB: () => (/* binding */ isRoundedDesign),
/* harmony export */   Xq: () => (/* binding */ setLikes),
/* harmony export */   am: () => (/* binding */ isNewDesign),
/* harmony export */   kQ: () => (/* binding */ NEUTRAL_STATE),
/* harmony export */   m8: () => (/* binding */ getLikeCountFromButton),
/* harmony export */   ol: () => (/* binding */ isShorts),
/* harmony export */   qg: () => (/* binding */ initExtConfig),
/* harmony export */   r6: () => (/* binding */ setDislikes),
/* harmony export */   tq: () => (/* binding */ isMobile),
/* harmony export */   vk: () => (/* binding */ storedData),
/* harmony export */   zO: () => (/* binding */ extConfig)
/* harmony export */ });
/* unused harmony exports isVideoDisliked, isVideoLiked, getState, setState */
/* harmony import */ var _buttons__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(423);
/* harmony import */ var _bar__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(910);
/* harmony import */ var _utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(67);




//TODO: Do not duplicate here and in ryd.background.js
const apiUrl = "https://returnyoutubedislikeapi.com";
const LIKED_STATE = "LIKED_STATE";
const DISLIKED_STATE = "DISLIKED_STATE";
const NEUTRAL_STATE = "NEUTRAL_STATE";

let extConfig = {
  disableVoteSubmission: false,
  disableLogging: false,
  coloredThumbs: false,
  coloredBar: false,
  colorTheme: "classic",
  numberDisplayFormat: "compactShort",
  showTooltipPercentage: false,
  tooltipPercentageMode: "dash_like",
  numberDisplayReformatLikes: false,
  selectors: {
    dislikeTextContainer: [],
    likeTextContainer: [],
    buttons: {
      shorts: {
        mobile: [],
        desktop: [],
      },
      regular: {
        mobile: [],
        desktopMenu: [],
        desktopNoMenu: [],
      },
      likeButton: {
        segmented: [],
        segmentedGetButtons: [],
        notSegmented: [],
      },
      dislikeButton: {
        segmented: [],
        segmentedGetButtons: [],
        notSegmented: [],
      },
    },
    menuContainer: [],
    roundedDesign: [],
  },
};

let storedData = {
  likes: 0,
  dislikes: 0,
  previousState: NEUTRAL_STATE,
};

function isMobile() {
  return location.hostname == "m.youtube.com";
}

function isShorts() {
  return location.pathname.startsWith("/shorts");
}

function isNewDesign() {
  return document.getElementById("comment-teaser") !== null;
}

function isRoundedDesign() {
  return (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .querySelector */ .R2)(extConfig.selectors.roundedDesign) !== null;
}

let shortsObserver = null;

if (isShorts() && !shortsObserver) {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)("Initializing shorts mutation observer");
  shortsObserver = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .createObserver */ .zo)(
    {
      attributes: true,
    },
    (mutationList) => {
      mutationList.forEach((mutation) => {
        if (
          mutation.type === "attributes" &&
          mutation.target.nodeName === "TP-YT-PAPER-BUTTON" &&
          mutation.target.id === "button"
        ) {
          // cLog('Short thumb button status changed');
          if (mutation.target.getAttribute("aria-pressed") === "true") {
            mutation.target.style.color =
              mutation.target.parentElement.parentElement.id === "like-button"
                ? (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(true)
                : (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(false);
          } else {
            mutation.target.style.color = "unset";
          }
          return;
        }
        (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)("Unexpected mutation observer event: " + mutation.target + mutation.type);
      });
    },
  );
}

function isLikesDisabled() {
  // return true if the like button's text doesn't contain any number
  if (isMobile()) {
    return /^\D*$/.test((0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getButtons */ .hS)().children[0].querySelector(".button-renderer-text").innerText);
  }
  return /^\D*$/.test((0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeTextContainer */ .Eq)().innerText);
}

function isVideoLiked() {
  if (isMobile()) {
    return (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)().querySelector("button").getAttribute("aria-label") === "true";
  }
  return (
    (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)().classList.contains("style-default-active") ||
    (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)().querySelector("button")?.getAttribute("aria-pressed") === "true"
  );
}

function isVideoDisliked() {
  if (isMobile()) {
    return (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeButton */ .x8)().querySelector("button").getAttribute("aria-label") === "true";
  }
  return (
    (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeButton */ .x8)().classList.contains("style-default-active") ||
    (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeButton */ .x8)().querySelector("button")?.getAttribute("aria-pressed") === "true"
  );
}

function getState(storedData) {
  if (isVideoLiked()) {
    return { current: LIKED_STATE, previous: storedData.previousState };
  }
  if (isVideoDisliked()) {
    return { current: DISLIKED_STATE, previous: storedData.previousState };
  }
  return { current: NEUTRAL_STATE, previous: storedData.previousState };
}

//---   Sets The Likes And Dislikes Values   ---//
function setLikes(likesCount) {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)(`SET likes ${likesCount}`);
  (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeTextContainer */ .Eq)().innerText = likesCount;
}

function setDislikes(dislikesCount) {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)(`SET dislikes ${dislikesCount}`);

  const _container = (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeTextContainer */ .xP)();
  _container?.removeAttribute("is-empty");

  let _dislikeText
  if (!isLikesDisabled()) {
    if (isMobile()) {
      (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getButtons */ .hS)().children[1].querySelector(".button-renderer-text").innerText = dislikesCount;
      return;
    }
    _dislikeText = dislikesCount;
  } else {
    (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)("likes count disabled by creator");
    if (isMobile()) {
      (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getButtons */ .hS)().children[1].querySelector(".button-renderer-text").innerText = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .localize */ .NC)("TextLikesDisabled");
      return;
    }
    _dislikeText = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .localize */ .NC)("TextLikesDisabled");
  }

  if (_dislikeText != null && _container?.innerText !== _dislikeText) {
    _container.innerText = _dislikeText;
  }
}

function getLikeCountFromButton() {
  try {
    if (isShorts()) {
      //Youtube Shorts don't work with this query. It's not necessary; we can skip it and still see the results.
      //It should be possible to fix this function, but it's not critical to showing the dislike count.
      return false;
    }

    let likeButton =
      (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)().querySelector("yt-formatted-string#text") ?? (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)().querySelector("button");

    let likesStr = likeButton.getAttribute("aria-label").replace(/\D/g, "");
    return likesStr.length > 0 ? parseInt(likesStr) : false;
  } catch {
    return false;
  }
}

function processResponse(response, storedData) {
  const formattedDislike = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .numberFormat */ .Y4)(response.dislikes);
  setDislikes(formattedDislike);
  if (extConfig.numberDisplayReformatLikes === true) {
    const nativeLikes = getLikeCountFromButton();
    if (nativeLikes !== false) {
      setLikes((0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .numberFormat */ .Y4)(nativeLikes));
    }
  }
  storedData.dislikes = parseInt(response.dislikes);
  storedData.likes = getLikeCountFromButton() || parseInt(response.likes);
  (0,_bar__WEBPACK_IMPORTED_MODULE_1__/* .createRateBar */ .k)(storedData.likes, storedData.dislikes);
  if (extConfig.coloredThumbs === true) {
    if (isShorts()) {
      // for shorts, leave deactivated buttons in default color
      let shortLikeButton = (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)().querySelector("tp-yt-paper-button#button");
      let shortDislikeButton = (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeButton */ .x8)().querySelector("tp-yt-paper-button#button");
      if (shortLikeButton.getAttribute("aria-pressed") === "true") {
        shortLikeButton.style.color = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(true);
      }
      if (shortDislikeButton.getAttribute("aria-pressed") === "true") {
        shortDislikeButton.style.color = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(false);
      }
      shortsObserver.observe(shortLikeButton);
      shortsObserver.observe(shortDislikeButton);
    } else {
      (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getLikeButton */ .yN)().style.color = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(true);
      (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeButton */ .x8)().style.color = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getColorFromTheme */ .t4)(false);
    }
  }
  //Temporary disabling this - it breaks all places where getButtons()[1] is used
  // createStarRating(response.rating, isMobile());
}

// Tells the user if the API is down
function displayError(error) {
  (0,_buttons__WEBPACK_IMPORTED_MODULE_0__/* .getDislikeTextContainer */ .xP)().innerText = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .localize */ .NC)("textTempUnavailable");
}

async function setState(storedData) {
  storedData.previousState = isVideoDisliked() ? DISLIKED_STATE : isVideoLiked() ? LIKED_STATE : NEUTRAL_STATE;
  let statsSet = false;
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)("Video is loaded. Adding buttons...");

  let videoId = (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getVideoId */ .gJ)(window.location.href);
  let likeCount = getLikeCountFromButton() || null;

  let response = await fetch(`${apiUrl}/votes?videoId=${videoId}&likeCount=${likeCount || ""}`, {
    method: "GET",
    headers: {
      Accept: "application/json",
    },
  })
    .then((response) => {
      if (!response.ok) displayError(response.error);
      return response;
    })
    .then((response) => response.json())
    .catch(displayError);
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)("response from api:");
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .cLog */ .D2)(JSON.stringify(response));
  if (response !== undefined && !("traceId" in response) && !statsSet) {
    processResponse(response, storedData);
  }
}

async function setInitialState() {
  await setState(storedData);
}

async function initExtConfig() {
  initializeDisableVoteSubmission();
  initializeDisableLogging();
  initializeColoredThumbs();
  initializeColoredBar();
  initializeColorTheme();
  initializeNumberDisplayFormat();
  initializeTooltipPercentage();
  initializeTooltipPercentageMode();
  initializeNumberDisplayReformatLikes();
  await initializeSelectors();
}

async function initializeSelectors() {
  console.log("initializing selectors");
  let result = await fetch(`${apiUrl}/configs/selectors`, {
    method: "GET",
    headers: {
      Accept: "application/json",
    },
  })
    .then((response) => response.json())
    .catch((error) => {});
  extConfig.selectors = result ?? extConfig.selectors;
  console.log(result);
}

function initializeDisableVoteSubmission() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["disableVoteSubmission"], (res) => {
    if (res.disableVoteSubmission === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ disableVoteSubmission: false });
    } else {
      extConfig.disableVoteSubmission = res.disableVoteSubmission;
    }
  });
}

function initializeDisableLogging() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["disableLogging"], (res) => {
    if (res.disableLogging === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ disableLogging: true });
    } else {
      extConfig.disableLogging = res.disableLogging;
    }
  });
}

function initializeColoredThumbs() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["coloredThumbs"], (res) => {
    if (res.coloredThumbs === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ coloredThumbs: false });
    } else {
      extConfig.coloredThumbs = res.coloredThumbs;
    }
  });
}

function initializeColoredBar() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["coloredBar"], (res) => {
    if (res.coloredBar === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ coloredBar: false });
    } else {
      extConfig.coloredBar = res.coloredBar;
    }
  });
}

function initializeColorTheme() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["colorTheme"], (res) => {
    if (res.colorTheme === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ colorTheme: false });
    } else {
      extConfig.colorTheme = res.colorTheme;
    }
  });
}

function initializeNumberDisplayFormat() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["numberDisplayFormat"], (res) => {
    if (res.numberDisplayFormat === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ numberDisplayFormat: "compactShort" });
    } else {
      extConfig.numberDisplayFormat = res.numberDisplayFormat;
    }
  });
}

function initializeTooltipPercentage() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["showTooltipPercentage"], (res) => {
    if (res.showTooltipPercentage === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ showTooltipPercentage: false });
    } else {
      extConfig.showTooltipPercentage = res.showTooltipPercentage;
    }
  });
}

function initializeTooltipPercentageMode() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["tooltipPercentageMode"], (res) => {
    if (res.tooltipPercentageMode === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ tooltipPercentageMode: "dash_like" });
    } else {
      extConfig.tooltipPercentageMode = res.tooltipPercentageMode;
    }
  });
}

function initializeNumberDisplayReformatLikes() {
  (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.get(["numberDisplayReformatLikes"], (res) => {
    if (res.numberDisplayReformatLikes === undefined) {
      (0,_utils__WEBPACK_IMPORTED_MODULE_2__/* .getBrowser */ .qs)().storage.sync.set({ numberDisplayReformatLikes: false });
    } else {
      extConfig.numberDisplayReformatLikes = res.numberDisplayReformatLikes;
    }
  });
}




/***/ }),

/***/ 67:
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   D2: () => (/* binding */ cLog),
/* harmony export */   NC: () => (/* binding */ localize),
/* harmony export */   R2: () => (/* binding */ querySelector),
/* harmony export */   Wb: () => (/* binding */ querySelectorAll),
/* harmony export */   Y4: () => (/* binding */ numberFormat),
/* harmony export */   gJ: () => (/* binding */ getVideoId),
/* harmony export */   qs: () => (/* binding */ getBrowser),
/* harmony export */   t4: () => (/* binding */ getColorFromTheme),
/* harmony export */   v4: () => (/* binding */ isInViewport),
/* harmony export */   x8: () => (/* binding */ isVideoLoaded),
/* harmony export */   zo: () => (/* binding */ createObserver)
/* harmony export */ });
/* unused harmony export getNumberFormatter */
/* harmony import */ var _state__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(935);


function numberFormat(numberState) {
  return getNumberFormatter(_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.numberDisplayFormat).format(numberState);
}

function getNumberFormatter(optionSelect) {
  let userLocales;
  if (document.documentElement.lang) {
    userLocales = document.documentElement.lang;
  } else if (navigator.language) {
    userLocales = navigator.language;
  } else {
    try {
      userLocales = new URL(
        Array.from(document.querySelectorAll("head > link[rel='search']"))
          ?.find((n) => n?.getAttribute("href")?.includes("?locale="))
          ?.getAttribute("href"),
      )?.searchParams?.get("locale");
    } catch {
      cLog("Cannot find browser locale. Use en as default for number formatting.");
      userLocales = "en";
    }
  }

  let formatterNotation;
  let formatterCompactDisplay;
  switch (optionSelect) {
    case "compactLong":
      formatterNotation = "compact";
      formatterCompactDisplay = "long";
      break;
    case "standard":
      formatterNotation = "standard";
      formatterCompactDisplay = "short";
      break;
    case "compactShort":
    default:
      formatterNotation = "compact";
      formatterCompactDisplay = "short";
  }

  const formatter = Intl.NumberFormat(userLocales, {
    notation: formatterNotation,
    compactDisplay: formatterCompactDisplay,
  });
  return formatter;
}

function localize(localeString) {
  return chrome.i18n.getMessage(localeString);
}

function getBrowser() {
  if (typeof chrome !== "undefined" && typeof chrome.runtime !== "undefined") {
    return chrome;
  } else if (typeof browser !== "undefined" && typeof browser.runtime !== "undefined") {
    return browser;
  } else {
    console.log("browser is not supported");
    return false;
  }
}

function getVideoId(url) {
  const urlObject = new URL(url);
  const pathname = urlObject.pathname;
  if (pathname.startsWith("/clip")) {
    return (document.querySelector("meta[itemprop='videoId']") || document.querySelector("meta[itemprop='identifier']"))
      .content;
  } else {
    if (pathname.startsWith("/shorts")) {
      return pathname.slice(8);
    }
    return urlObject.searchParams.get("v");
  }
}

function isInViewport(element) {
  const rect = element.getBoundingClientRect();
  const height = innerHeight || document.documentElement.clientHeight;
  const width = innerWidth || document.documentElement.clientWidth;
  return (
    // When short (channel) is ignored, the element (like/dislike AND short itself) is
    // hidden with a 0 DOMRect. In this case, consider it outside of Viewport
    !(rect.top == 0 && rect.left == 0 && rect.bottom == 0 && rect.right == 0) &&
    rect.top >= 0 &&
    rect.left >= 0 &&
    rect.bottom <= height &&
    rect.right <= width
  );
}

function isVideoLoaded() {
  const videoId = getVideoId(window.location.href);
  return (
    // desktop: spring 2024 UI
    document.querySelector(`ytd-watch-grid[video-id='${videoId}']`) !== null ||
    // desktop: older UI
    document.querySelector(`ytd-watch-flexy[video-id='${videoId}']`) !== null ||
    // mobile: no video-id attribute
    document.querySelector('#player[loading="false"]:not([hidden])') !== null
  );
}

function cLog(message, writer) {
  if (!_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.disableLogging) {
    message = `[return youtube dislike]: ${message}`;
    if (writer) {
      writer(message);
    } else {
      console.log(message);
    }
  }
}

function getColorFromTheme(voteIsLike) {
  let colorString;
  switch (_state__WEBPACK_IMPORTED_MODULE_0__/* .extConfig */ .zO.colorTheme) {
    case "accessible":
      if (voteIsLike === true) {
        colorString = "dodgerblue";
      } else {
        colorString = "gold";
      }
      break;
    case "neon":
      if (voteIsLike === true) {
        colorString = "aqua";
      } else {
        colorString = "magenta";
      }
      break;
    case "classic":
    default:
      if (voteIsLike === true) {
        colorString = "lime";
      } else {
        colorString = "red";
      }
  }
  return colorString;
}

function querySelector(selectors, element) {
  let result;
  for (const selector of selectors) {
    result = (element ?? document).querySelector(selector);
    if (result !== null) {
      return result;
    }
  }
}

function querySelectorAll(selectors) {
  let result;
  for (const selector of selectors) {
    result = document.querySelectorAll(selector);
    if (result.length !== 0) {
      return result;
    }
  }
  return result;
}

function createObserver(options, callback) {
  const observerWrapper = new Object();
  observerWrapper.options = options;
  observerWrapper.observer = new MutationObserver(callback);
  observerWrapper.observe = function (element) {
    this.observer.observe(element, this.options);
  };
  observerWrapper.disconnect = function () {
    this.observer.disconnect();
  };
  return observerWrapper;
}




/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/async module */
/******/ 	(() => {
/******/ 		var webpackQueues = typeof Symbol === "function" ? Symbol("webpack queues") : "__webpack_queues__";
/******/ 		var webpackExports = typeof Symbol === "function" ? Symbol("webpack exports") : "__webpack_exports__";
/******/ 		var webpackError = typeof Symbol === "function" ? Symbol("webpack error") : "__webpack_error__";
/******/ 		var resolveQueue = (queue) => {
/******/ 			if(queue && queue.d < 1) {
/******/ 				queue.d = 1;
/******/ 				queue.forEach((fn) => (fn.r--));
/******/ 				queue.forEach((fn) => (fn.r-- ? fn.r++ : fn()));
/******/ 			}
/******/ 		}
/******/ 		var wrapDeps = (deps) => (deps.map((dep) => {
/******/ 			if(dep !== null && typeof dep === "object") {
/******/ 				if(dep[webpackQueues]) return dep;
/******/ 				if(dep.then) {
/******/ 					var queue = [];
/******/ 					queue.d = 0;
/******/ 					dep.then((r) => {
/******/ 						obj[webpackExports] = r;
/******/ 						resolveQueue(queue);
/******/ 					}, (e) => {
/******/ 						obj[webpackError] = e;
/******/ 						resolveQueue(queue);
/******/ 					});
/******/ 					var obj = {};
/******/ 					obj[webpackQueues] = (fn) => (fn(queue));
/******/ 					return obj;
/******/ 				}
/******/ 			}
/******/ 			var ret = {};
/******/ 			ret[webpackQueues] = x => {};
/******/ 			ret[webpackExports] = dep;
/******/ 			return ret;
/******/ 		}));
/******/ 		__webpack_require__.a = (module, body, hasAwait) => {
/******/ 			var queue;
/******/ 			hasAwait && ((queue = []).d = -1);
/******/ 			var depQueues = new Set();
/******/ 			var exports = module.exports;
/******/ 			var currentDeps;
/******/ 			var outerResolve;
/******/ 			var reject;
/******/ 			var promise = new Promise((resolve, rej) => {
/******/ 				reject = rej;
/******/ 				outerResolve = resolve;
/******/ 			});
/******/ 			promise[webpackExports] = exports;
/******/ 			promise[webpackQueues] = (fn) => (queue && fn(queue), depQueues.forEach(fn), promise["catch"](x => {}));
/******/ 			module.exports = promise;
/******/ 			body((deps) => {
/******/ 				currentDeps = wrapDeps(deps);
/******/ 				var fn;
/******/ 				var getResult = () => (currentDeps.map((d) => {
/******/ 					if(d[webpackError]) throw d[webpackError];
/******/ 					return d[webpackExports];
/******/ 				}))
/******/ 				var promise = new Promise((resolve) => {
/******/ 					fn = () => (resolve(getResult));
/******/ 					fn.r = 0;
/******/ 					var fnQueue = (q) => (q !== queue && !depQueues.has(q) && (depQueues.add(q), q && !q.d && (fn.r++, q.push(fn))));
/******/ 					currentDeps.map((dep) => (dep[webpackQueues](fnQueue)));
/******/ 				});
/******/ 				return fn.r ? promise : getResult();
/******/ 			}, (err) => ((err ? reject(promise[webpackError] = err) : outerResolve(exports)), resolveQueue(queue)));
/******/ 			queue && queue.d < 0 && (queue.d = 0);
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module used 'module' so it can't be inlined
/******/ 	var __webpack_exports__ = __webpack_require__(805);
/******/ 	
/******/ })()
;