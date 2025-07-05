/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
var __webpack_exports__ = {};

;// CONCATENATED MODULE: ./Extensions/combined/src/buttons.js



function buttons_getButtons() {
  //---   If Watching Youtube Shorts:   ---//
  if (isShorts()) {
    let elements = isMobile()
      ? querySelectorAll(extConfig.selectors.buttons.shorts.mobile)
      : querySelectorAll(extConfig.selectors.buttons.shorts.desktop);

    for (let element of elements) {
      //YouTube Shorts can have multiple like/dislike buttons when scrolling through videos
      //However, only one of them should be visible (no matter how you zoom)
      if (isInViewport(element)) {
        return element;
      }
    }
  }
  //---   If Watching On Mobile:   ---//
  if (isMobile()) {
    return document.querySelector(extConfig.selectors.buttons.regular.mobile);
  }
  //---   If Menu Element Is Displayed:   ---//
  if (querySelector(extConfig.selectors.menuContainer)?.offsetParent === null) {
    return querySelector(extConfig.selectors.buttons.regular.desktopMenu);
    //---   If Menu Element Isn't Displayed:   ---//
  } else {
    return querySelector(extConfig.selectors.buttons.regular.desktopNoMenu);
  }
}

function buttons_getLikeButton() {
  return buttons_getButtons().children[0].tagName ===
    "YTD-SEGMENTED-LIKE-DISLIKE-BUTTON-RENDERER"
    ? querySelector(extConfig.selectors.buttons.likeButton.segmented) ??
        querySelector(
          extConfig.selectors.buttons.likeButton.segmentedGetButtons,
          buttons_getButtons(),
        )
    : querySelector(
        extConfig.selectors.buttons.likeButton.notSegmented,
        buttons_getButtons(),
      );
}

function buttons_getLikeTextContainer() {
  return querySelector(extConfig.selectors.likeTextContainer, buttons_getLikeButton());
}

function buttons_getDislikeButton() {
  return buttons_getButtons().children[0].tagName ===
    "YTD-SEGMENTED-LIKE-DISLIKE-BUTTON-RENDERER"
    ? querySelector(extConfig.selectors.buttons.dislikeButton.segmented) ??
        querySelector(
          extConfig.selectors.buttons.dislikeButton.segmentedGetButtons,
          buttons_getButtons(),
        )
    : isShorts()
      ? querySelector(["#dislike-button"], buttons_getButtons())
      : querySelector(
          extConfig.selectors.buttons.dislikeButton.notSegmented,
          buttons_getButtons(),
        );
}

function createDislikeTextContainer() {
  const textNodeClone = (
    buttons_getLikeButton().querySelector(
      ".yt-spec-button-shape-next__button-text-content",
    ) ||
    buttons_getLikeButton().querySelector("button > div[class*='cbox']") ||
    (
      buttons_getLikeButton().querySelector('div > span[role="text"]') ||
      document.querySelector(
        'button > div.yt-spec-button-shape-next__button-text-content > span[role="text"]',
      )
    ).parentNode
  ).cloneNode(true);
  const insertPreChild = buttons_getDislikeButton().querySelector("button");
  insertPreChild.insertBefore(textNodeClone, null);
  buttons_getDislikeButton()
    .querySelector("button")
    .classList.remove("yt-spec-button-shape-next--icon-button");
  buttons_getDislikeButton()
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

function buttons_getDislikeTextContainer() {
  let result;
  for (const selector of extConfig.selectors.dislikeTextContainer) {
    result = buttons_getDislikeButton().querySelector(selector);
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



;// CONCATENATED MODULE: ./Extensions/combined/src/bar.js




function bar_createRateBar(likes, dislikes) {
  let rateBar = document.getElementById("ryd-bar-container");
  if (!isLikesDisabled()) {
    // sometimes rate bar is hidden
    if (rateBar && !isInViewport(rateBar)) {
      rateBar.remove();
      rateBar = null;
    }

    const widthPx =
      parseFloat(window.getComputedStyle(getLikeButton()).width) +
      parseFloat(window.getComputedStyle(getDislikeButton()).width) +
      (isRoundedDesign() ? 0 : 8);

    const widthPercent =
      likes + dislikes > 0 ? (likes / (likes + dislikes)) * 100 : 50;

    var likePercentage = parseFloat(widthPercent.toFixed(1));
    const dislikePercentage = (100 - likePercentage).toLocaleString();
    likePercentage = likePercentage.toLocaleString();

    if (extConfig.showTooltipPercentage) {
      var tooltipInnerHTML;
      switch (extConfig.tooltipPercentageMode) {
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

    if (!isShorts()) {
      if (!rateBar && !isMobile()) {
        let colorLikeStyle = "";
        let colorDislikeStyle = "";
        if (extConfig.coloredBar) {
          colorLikeStyle = "; background-color: " + getColorFromTheme(true);
          colorDislikeStyle = "; background-color: " + getColorFromTheme(false);
        }
        let actions =
          isNewDesign() && getButtons().id === "top-level-buttons-computed"
            ? getButtons()
            : document.getElementById("menu-container");
        (
          actions ||
          document.querySelector("ytm-slim-video-action-bar-renderer")
        ).insertAdjacentHTML(
          "beforeend",
          `
              <div class="ryd-tooltip ryd-tooltip-${isNewDesign() ? "new" : "old"}-design" style="width: ${widthPx}px">
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

        if (isNewDesign()) {
          // Add border between info and comments
          let descriptionAndActionsElement = document.getElementById("top-row");
          descriptionAndActionsElement.style.borderBottom =
            "1px solid var(--yt-spec-10-percent-layer)";
          descriptionAndActionsElement.style.paddingBottom = "10px";

          // Fix like/dislike ratio bar offset in new UI
          document.getElementById("actions-inner").style.width = "revert";
          if (isRoundedDesign()) {
            document.getElementById("actions").style.flexDirection =
              "row-reverse";
          }
        }
      } else {
        document.querySelector(`.ryd-tooltip`).style.width = widthPx + "px";
        document.getElementById("ryd-bar").style.width = widthPercent + "%";
        document.querySelector("#ryd-dislike-tooltip > #tooltip").innerHTML =
          tooltipInnerHTML;
        if (extConfig.coloredBar) {
          document.getElementById("ryd-bar-container").style.backgroundColor =
            getColorFromTheme(false);
          document.getElementById("ryd-bar").style.backgroundColor =
            getColorFromTheme(true);
        }
      }
    }
  } else {
    cLog("removing bar");
    if (rateBar) {
      rateBar.parentNode.removeChild(rateBar);
    }
  }
}



;// CONCATENATED MODULE: ./Extensions/combined/src/state.js




//TODO: Do not duplicate here and in ryd.background.js
const apiUrl = "https://returnyoutubedislikeapi.com";
const LIKED_STATE = "LIKED_STATE";
const DISLIKED_STATE = "DISLIKED_STATE";
const NEUTRAL_STATE = "NEUTRAL_STATE";

let state_extConfig = {
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

function state_isMobile() {
  return location.hostname == "m.youtube.com";
}

function state_isShorts() {
  return location.pathname.startsWith("/shorts");
}

function state_isNewDesign() {
  return document.getElementById("comment-teaser") !== null;
}

function state_isRoundedDesign() {
  return querySelector(state_extConfig.selectors.roundedDesign) !== null;
}

let shortsObserver = null;

if (state_isShorts() && !shortsObserver) {
  utils_cLog("Initializing shorts mutation observer");
  shortsObserver = createObserver(
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
                ? utils_getColorFromTheme(true)
                : utils_getColorFromTheme(false);
          } else {
            mutation.target.style.color = "unset";
          }
          return;
        }
        utils_cLog("Unexpected mutation observer event: " + mutation.target + mutation.type);
      });
    },
  );
}

function state_isLikesDisabled() {
  // return true if the like button's text doesn't contain any number
  if (state_isMobile()) {
    return /^\D*$/.test(getButtons().children[0].querySelector(".button-renderer-text").innerText);
  }
  return /^\D*$/.test(getLikeTextContainer().innerText);
}

function isVideoLiked() {
  if (state_isMobile()) {
    return getLikeButton().querySelector("button").getAttribute("aria-label") === "true";
  }
  return (
    getLikeButton().classList.contains("style-default-active") ||
    getLikeButton().querySelector("button")?.getAttribute("aria-pressed") === "true"
  );
}

function isVideoDisliked() {
  if (state_isMobile()) {
    return getDislikeButton().querySelector("button").getAttribute("aria-label") === "true";
  }
  return (
    getDislikeButton().classList.contains("style-default-active") ||
    getDislikeButton().querySelector("button")?.getAttribute("aria-pressed") === "true"
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
  cLog(`SET likes ${likesCount}`);
  getLikeTextContainer().innerText = likesCount;
}

function setDislikes(dislikesCount) {
  cLog(`SET dislikes ${dislikesCount}`);

  const _container = getDislikeTextContainer();
  _container?.removeAttribute("is-empty");

  let _dislikeText
  if (!state_isLikesDisabled()) {
    if (state_isMobile()) {
      getButtons().children[1].querySelector(".button-renderer-text").innerText = dislikesCount;
      return;
    }
    _dislikeText = dislikesCount;
  } else {
    cLog("likes count disabled by creator");
    if (state_isMobile()) {
      getButtons().children[1].querySelector(".button-renderer-text").innerText = localize("TextLikesDisabled");
      return;
    }
    _dislikeText = localize("TextLikesDisabled");
  }

  if (_dislikeText != null && _container?.innerText !== _dislikeText) {
    _container.innerText = _dislikeText;
  }
}

function getLikeCountFromButton() {
  try {
    if (state_isShorts()) {
      //Youtube Shorts don't work with this query. It's not necessary; we can skip it and still see the results.
      //It should be possible to fix this function, but it's not critical to showing the dislike count.
      return false;
    }

    let likeButton =
      getLikeButton().querySelector("yt-formatted-string#text") ?? getLikeButton().querySelector("button");

    let likesStr = likeButton.getAttribute("aria-label").replace(/\D/g, "");
    return likesStr.length > 0 ? parseInt(likesStr) : false;
  } catch {
    return false;
  }
}

function processResponse(response, storedData) {
  const formattedDislike = numberFormat(response.dislikes);
  setDislikes(formattedDislike);
  if (state_extConfig.numberDisplayReformatLikes === true) {
    const nativeLikes = getLikeCountFromButton();
    if (nativeLikes !== false) {
      setLikes(numberFormat(nativeLikes));
    }
  }
  storedData.dislikes = parseInt(response.dislikes);
  storedData.likes = getLikeCountFromButton() || parseInt(response.likes);
  createRateBar(storedData.likes, storedData.dislikes);
  if (state_extConfig.coloredThumbs === true) {
    if (state_isShorts()) {
      // for shorts, leave deactivated buttons in default color
      let shortLikeButton = getLikeButton().querySelector("tp-yt-paper-button#button");
      let shortDislikeButton = getDislikeButton().querySelector("tp-yt-paper-button#button");
      if (shortLikeButton.getAttribute("aria-pressed") === "true") {
        shortLikeButton.style.color = getColorFromTheme(true);
      }
      if (shortDislikeButton.getAttribute("aria-pressed") === "true") {
        shortDislikeButton.style.color = getColorFromTheme(false);
      }
      shortsObserver.observe(shortLikeButton);
      shortsObserver.observe(shortDislikeButton);
    } else {
      getLikeButton().style.color = getColorFromTheme(true);
      getDislikeButton().style.color = getColorFromTheme(false);
    }
  }
  //Temporary disabling this - it breaks all places where getButtons()[1] is used
  // createStarRating(response.rating, isMobile());
}

// Tells the user if the API is down
function displayError(error) {
  getDislikeTextContainer().innerText = localize("textTempUnavailable");
}

async function setState(storedData) {
  storedData.previousState = isVideoDisliked() ? DISLIKED_STATE : isVideoLiked() ? LIKED_STATE : NEUTRAL_STATE;
  let statsSet = false;
  cLog("Video is loaded. Adding buttons...");

  let videoId = getVideoId(window.location.href);
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
  cLog("response from api:");
  cLog(JSON.stringify(response));
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
  state_extConfig.selectors = result ?? state_extConfig.selectors;
  console.log(result);
}

function initializeDisableVoteSubmission() {
  getBrowser().storage.sync.get(["disableVoteSubmission"], (res) => {
    if (res.disableVoteSubmission === undefined) {
      getBrowser().storage.sync.set({ disableVoteSubmission: false });
    } else {
      state_extConfig.disableVoteSubmission = res.disableVoteSubmission;
    }
  });
}

function initializeDisableLogging() {
  getBrowser().storage.sync.get(["disableLogging"], (res) => {
    if (res.disableLogging === undefined) {
      getBrowser().storage.sync.set({ disableLogging: true });
    } else {
      state_extConfig.disableLogging = res.disableLogging;
    }
  });
}

function initializeColoredThumbs() {
  getBrowser().storage.sync.get(["coloredThumbs"], (res) => {
    if (res.coloredThumbs === undefined) {
      getBrowser().storage.sync.set({ coloredThumbs: false });
    } else {
      state_extConfig.coloredThumbs = res.coloredThumbs;
    }
  });
}

function initializeColoredBar() {
  getBrowser().storage.sync.get(["coloredBar"], (res) => {
    if (res.coloredBar === undefined) {
      getBrowser().storage.sync.set({ coloredBar: false });
    } else {
      state_extConfig.coloredBar = res.coloredBar;
    }
  });
}

function initializeColorTheme() {
  getBrowser().storage.sync.get(["colorTheme"], (res) => {
    if (res.colorTheme === undefined) {
      getBrowser().storage.sync.set({ colorTheme: false });
    } else {
      state_extConfig.colorTheme = res.colorTheme;
    }
  });
}

function initializeNumberDisplayFormat() {
  getBrowser().storage.sync.get(["numberDisplayFormat"], (res) => {
    if (res.numberDisplayFormat === undefined) {
      getBrowser().storage.sync.set({ numberDisplayFormat: "compactShort" });
    } else {
      state_extConfig.numberDisplayFormat = res.numberDisplayFormat;
    }
  });
}

function initializeTooltipPercentage() {
  getBrowser().storage.sync.get(["showTooltipPercentage"], (res) => {
    if (res.showTooltipPercentage === undefined) {
      getBrowser().storage.sync.set({ showTooltipPercentage: false });
    } else {
      state_extConfig.showTooltipPercentage = res.showTooltipPercentage;
    }
  });
}

function initializeTooltipPercentageMode() {
  getBrowser().storage.sync.get(["tooltipPercentageMode"], (res) => {
    if (res.tooltipPercentageMode === undefined) {
      getBrowser().storage.sync.set({ tooltipPercentageMode: "dash_like" });
    } else {
      state_extConfig.tooltipPercentageMode = res.tooltipPercentageMode;
    }
  });
}

function initializeNumberDisplayReformatLikes() {
  getBrowser().storage.sync.get(["numberDisplayReformatLikes"], (res) => {
    if (res.numberDisplayReformatLikes === undefined) {
      getBrowser().storage.sync.set({ numberDisplayReformatLikes: false });
    } else {
      state_extConfig.numberDisplayReformatLikes = res.numberDisplayReformatLikes;
    }
  });
}



;// CONCATENATED MODULE: ./Extensions/combined/src/utils.js


function utils_numberFormat(numberState) {
  return getNumberFormatter(extConfig.numberDisplayFormat).format(numberState);
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
      utils_cLog("Cannot find browser locale. Use en as default for number formatting.");
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

function utils_localize(localeString) {
  return chrome.i18n.getMessage(localeString);
}

function utils_getBrowser() {
  if (typeof chrome !== "undefined" && typeof chrome.runtime !== "undefined") {
    return chrome;
  } else if (typeof browser !== "undefined" && typeof browser.runtime !== "undefined") {
    return browser;
  } else {
    console.log("browser is not supported");
    return false;
  }
}

function utils_getVideoId(url) {
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

function utils_isInViewport(element) {
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
  const videoId = utils_getVideoId(window.location.href);
  return (
    // desktop: spring 2024 UI
    document.querySelector(`ytd-watch-grid[video-id='${videoId}']`) !== null ||
    // desktop: older UI
    document.querySelector(`ytd-watch-flexy[video-id='${videoId}']`) !== null ||
    // mobile: no video-id attribute
    document.querySelector('#player[loading="false"]:not([hidden])') !== null
  );
}

function utils_cLog(message, writer) {
  if (!state_extConfig.disableLogging) {
    message = `[return youtube dislike]: ${message}`;
    if (writer) {
      writer(message);
    } else {
      console.log(message);
    }
  }
}

function utils_getColorFromTheme(voteIsLike) {
  let colorString;
  switch (state_extConfig.colorTheme) {
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

function utils_querySelector(selectors, element) {
  let result;
  for (const selector of selectors) {
    result = (element ?? document).querySelector(selector);
    if (result !== null) {
      return result;
    }
  }
}

function utils_querySelectorAll(selectors) {
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



;// CONCATENATED MODULE: ./Extensions/combined/popup.js


/*   Config   */
const config = {
  advanced: false,
  disableVoteSubmission: false,
  disableLogging: true,
  coloredThumbs: false,
  coloredBar: false,
  colorTheme: "classic",
  numberDisplayFormat: "compactShort",
  showTooltipPercentage: false,
  tooltipPercentageMode: "dash_like",
  numberDisplayReformatLikes: false,
  showAdvancedMessage:
    '<svg xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" height="24px" viewBox="0 0 24 24" width="24px" fill="currentColor"><rect fill="none" height="24" width="24"/><path d="M19.5,12c0-0.23-0.01-0.45-0.03-0.68l1.86-1.41c0.4-0.3,0.51-0.86,0.26-1.3l-1.87-3.23c-0.25-0.44-0.79-0.62-1.25-0.42 l-2.15,0.91c-0.37-0.26-0.76-0.49-1.17-0.68l-0.29-2.31C14.8,2.38,14.37,2,13.87,2h-3.73C9.63,2,9.2,2.38,9.14,2.88L8.85,5.19 c-0.41,0.19-0.8,0.42-1.17,0.68L5.53,4.96c-0.46-0.2-1-0.02-1.25,0.42L2.41,8.62c-0.25,0.44-0.14,0.99,0.26,1.3l1.86,1.41 C4.51,11.55,4.5,11.77,4.5,12s0.01,0.45,0.03,0.68l-1.86,1.41c-0.4,0.3-0.51,0.86-0.26,1.3l1.87,3.23c0.25,0.44,0.79,0.62,1.25,0.42 l2.15-0.91c0.37,0.26,0.76,0.49,1.17,0.68l0.29,2.31C9.2,21.62,9.63,22,10.13,22h3.73c0.5,0,0.93-0.38,0.99-0.88l0.29-2.31 c0.41-0.19,0.8-0.42,1.17-0.68l2.15,0.91c0.46,0.2,1,0.02,1.25-0.42l1.87-3.23c0.25-0.44,0.14-0.99-0.26-1.3l-1.86-1.41 C19.49,12.45,19.5,12.23,19.5,12z M12.04,15.5c-1.93,0-3.5-1.57-3.5-3.5s1.57-3.5,3.5-3.5s3.5,1.57,3.5,3.5S13.97,15.5,12.04,15.5z"/></svg>',
  hideAdvancedMessage:
    '<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="currentColor"><path d="M0 0h24v24H0V0z" fill="none" opacity=".87"/><path d="M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm4.3 14.3c-.39.39-1.02.39-1.41 0L12 13.41 9.11 16.3c-.39.39-1.02.39-1.41 0-.39-.39-.39-1.02 0-1.41L10.59 12 7.7 9.11c-.39-.39-.39-1.02 0-1.41.39-.39 1.02-.39 1.41 0L12 10.59l2.89-2.89c.39-.39 1.02-.39 1.41 0 .39.39.39 1.02 0 1.41L13.41 12l2.89 2.89c.38.38.38 1.02 0 1.41z"/></svg>',
  links: {
    website: "https://returnyoutubedislike.com",
    github: "https://github.com/Anarios/return-youtube-dislike",
    discord: "https://discord.gg/mYnESY4Md5",
    donate: "https://returnyoutubedislike.com/donate",
    faq: "https://returnyoutubedislike.com/faq",
    help: "https://returnyoutubedislike.com/help",
    changelog: "/changelog/3/changelog_3.0.html",
  },
};

/*   Change language   */
function localizeHtmlPage() {
  //Localize by replacing __MSG_***__ meta tags
  var objects = document.getElementsByTagName("html");
  for (var j = 0; j < objects.length; j++) {
    var obj = objects[j];

    var valStrH = obj.innerHTML.toString();
    var valNewH = valStrH.replace(/__MSG_(\w+)__/g, function (match, v1) {
      return v1 ? chrome.i18n.getMessage(v1) : "";
    });

    if (valNewH != valStrH) {
      obj.innerHTML = valNewH;
    }
  }
}

localizeHtmlPage();

/*   Links   */
createLink(config.links.website, "link_website");
createLink(config.links.github, "link_github");
createLink(config.links.discord, "link_discord");
createLink(config.links.faq, "link_faq");
createLink(config.links.donate, "link_donate");
createLink(config.links.help, "link_help");
createLink(config.links.changelog, "link_changelog");

function createLink(url, id) {
  document.getElementById(id).addEventListener("click", () => {
    chrome.tabs.create({ url: url });
  });
}

document
  .getElementById("disable_vote_submission")
  .addEventListener("click", (ev) => {
    chrome.storage.sync.set({ disableVoteSubmission: ev.target.checked });
  });

document.getElementById("disable_logging").addEventListener("click", (ev) => {
  chrome.storage.sync.set({ disableLogging:ev.target.checked })
});

document.getElementById("colored_thumbs").addEventListener("click", (ev) => {
  chrome.storage.sync.set({ coloredThumbs: ev.target.checked });
});

document.getElementById("colored_bar").addEventListener("click", (ev) => {
  chrome.storage.sync.set({ coloredBar: ev.target.checked });
});

document.getElementById("color_theme").addEventListener("click", (ev) => {
  chrome.storage.sync.set({ colorTheme: ev.target.value });
});

document.getElementById("number_format").addEventListener("change", (ev) => {
  chrome.storage.sync.set({ numberDisplayFormat: ev.target.value });
});

document
  .getElementById("show_tooltip_percentage")
  .addEventListener("click", (ev) => {
    chrome.storage.sync.set({ showTooltipPercentage: ev.target.checked });
  });

document
  .getElementById("tooltip_percentage_mode")
  .addEventListener("change", (ev) => {
    chrome.storage.sync.set({ tooltipPercentageMode: ev.target.value });
  });

document
  .getElementById("number_reformat_likes")
  .addEventListener("click", (ev) => {
    chrome.storage.sync.set({ numberDisplayReformatLikes: ev.target.checked });
  });

/*   Advanced Toggle   */
const advancedToggle = document.getElementById("advancedToggle");
advancedToggle.addEventListener("click", () => {
  const adv = document.getElementById("advancedSettings");
  if (config.advanced) {
    adv.style.transform = "scale(1.1)";
    adv.style.pointerEvents = "none";
    adv.style.opacity = "0";
    advancedToggle.innerHTML = config.showAdvancedMessage;
  } else {
    adv.style.transform = "scale(1)";
    adv.style.pointerEvents = "auto";
    adv.style.opacity = "1";
    advancedToggle.innerHTML = config.hideAdvancedMessage;
  }
  config.advanced = !config.advanced;
});

initConfig();

function initConfig() {
  popup_initializeDisableVoteSubmission();
  popup_initializeDisableLogging();
  initializeVersionNumber();
  popup_initializeColoredThumbs();
  popup_initializeColoredBar();
  popup_initializeColorTheme();
  popup_initializeNumberDisplayFormat();
  popup_initializeTooltipPercentage();
  popup_initializeTooltipPercentageMode();
  popup_initializeNumberDisplayReformatLikes();
}

function initializeVersionNumber() {
  const version = chrome.runtime.getManifest().version;
  document.getElementById("ext-version").innerHTML = "v" + version;

  fetch(
    "https://raw.githubusercontent.com/Anarios/return-youtube-dislike/main/Extensions/combined/manifest-chrome.json",
  )
    .then((response) => response.json())
    .then((json) => {
      if (compareVersions(json.version, version)) {
        document.getElementById("ext-update").innerHTML =
          chrome.i18n.getMessage("textUpdate") + " v" + json.version;
        document.getElementById("ext-update").style.padding = ".25rem .5rem";
      }
    });
  // .catch(console.error);
}

// returns whether current < latest
function compareVersions(latestStr, currentStr) {
  let latestarr = latestStr.split(".");
  let currentarr = currentStr.split(".");
  let outdated = false;
  // goes through version numbers from left to right from greatest to least significant
  for (let i = 0; i < Math.max(latestarr.length, currentarr.length); i++) {
    let latest = i < latestarr.length ? parseInt(latestarr[i]) : 0;
    let current = i < currentarr.length ? parseInt(currentarr[i]) : 0;
    if (latest > current) {
      outdated = true;
      break;
    } else if (latest < current) {
      outdated = false;
      break;
    }
  }
  return outdated;
}

function popup_initializeDisableVoteSubmission() {
  chrome.storage.sync.get(["disableVoteSubmission"], (res) => {
    handleDisableVoteSubmissionChangeEvent(res.disableVoteSubmission);
  });
}

function popup_initializeDisableLogging(){
  chrome.storage.sync.get(['disableLogging'], (res) => {
    handleDisableLoggingChangeEvent(res.disableLogging);
  });
}

function popup_initializeColoredThumbs() {
  chrome.storage.sync.get(["coloredThumbs"], (res) => {
    handleColoredThumbsChangeEvent(res.coloredThumbs);
  });
}

function popup_initializeColoredBar() {
  chrome.storage.sync.get(["coloredBar"], (res) => {
    handleColoredBarChangeEvent(res.coloredBar);
  });
}

function popup_initializeColorTheme() {
  chrome.storage.sync.get(["colorTheme"], (res) => {
    handleColorThemeChangeEvent(res.colorTheme);
  });
}

function popup_initializeTooltipPercentage() {
  chrome.storage.sync.get(["showTooltipPercentage"], (res) => {
    handleShowTooltipPercentageChangeEvent(res.showTooltipPercentage);
  });
}

function popup_initializeTooltipPercentageMode() {
  chrome.storage.sync.get(["tooltipPercentageMode"], (res) => {
    handleTooltipPercentageModeChangeEvent(res.tooltipPercentageMode);
  });
}

function popup_initializeNumberDisplayFormat() {
  chrome.storage.sync.get(["numberDisplayFormat"], (res) => {
    handleNumberDisplayFormatChangeEvent(res.numberDisplayFormat);
  });
  updateNumberDisplayFormatContent();
}

function updateNumberDisplayFormatContent() {
  let testValue = 123456;
  document.getElementById("number_format_compactShort").innerHTML =
    popup_getNumberFormatter("compactShort").format(testValue);
  document.getElementById("number_format_compactLong").innerHTML =
    popup_getNumberFormatter("compactLong").format(testValue);
  document.getElementById("number_format_standard").innerHTML =
    popup_getNumberFormatter("standard").format(testValue);
}

function popup_initializeNumberDisplayReformatLikes() {
  chrome.storage.sync.get(["numberDisplayReformatLikes"], (res) => {
    handleNumberDisplayReformatLikesChangeEvent(res.numberDisplayReformatLikes);
  });
}

chrome.storage.onChanged.addListener(storageChangeHandler);

function storageChangeHandler(changes, area) {
  if (changes.disableVoteSubmission !== undefined) {
    handleDisableVoteSubmissionChangeEvent(
      changes.disableVoteSubmission.newValue,
    );
  }
  if (changes.disableLogging !== undefined) {
    handleDisableLoggingChangeEvent(changes.disableLogging.newValue);
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
  if (changes.showTooltipPercentage !== undefined) {
    handleShowTooltipPercentageChangeEvent(
      changes.showTooltipPercentage.newValue,
    );
  }
  if (changes.numberDisplayReformatLikes !== undefined) {
    handleNumberDisplayReformatLikesChangeEvent(
      changes.numberDisplayReformatLikes.newValue,
    );
  }
}

function handleDisableVoteSubmissionChangeEvent(value) {
  config.disableVoteSubmission = value;
  document.getElementById("disable_vote_submission").checked = value;
}

function handleDisableLoggingChangeEvent(value) {
  config.disableLogging = value;
  document.getElementById("disable_logging").checked = value;
}

function handleColoredThumbsChangeEvent(value) {
  config.coloredThumbs = value;
  document.getElementById("colored_thumbs").checked = value;
}

function handleColoredBarChangeEvent(value) {
  config.coloredBar = value;
  document.getElementById("colored_bar").checked = value;
}

function handleColorThemeChangeEvent(value) {
  if (!value) {
    value = "classic";
  }
  config.colorTheme = value;
  document
    .getElementById("color_theme")
    .querySelector('option[value="' + value + '"]').selected = true;
  updateColorThemePreviewContent(value);
}

function updateColorThemePreviewContent(themeName) {
  document.getElementById("color_theme_example_like").style.backgroundColor =
    popup_getColorFromTheme(themeName, true);
  document.getElementById("color_theme_example_dislike").style.backgroundColor =
    popup_getColorFromTheme(themeName, false);
}

function handleNumberDisplayFormatChangeEvent(value) {
  config.numberDisplayFormat = value;
  document
    .getElementById("number_format")
    .querySelector('option[value="' + value + '"]').selected = true;
}

function handleShowTooltipPercentageChangeEvent(value) {
  config.showTooltipPercentage = value;
  document.getElementById("show_tooltip_percentage").checked = value;
}

function handleTooltipPercentageModeChangeEvent(value) {
  if (!value) {
    value = "dash_like";
  }
  config.tooltipPercentageMode = value;

  document
    .getElementById("tooltip_percentage_mode")
    .querySelector('option[value="' + value + '"]').selected = true;
}

function handleNumberDisplayReformatLikesChangeEvent(value) {
  config.numberDisplayReformatLikes = value;
  document.getElementById("number_reformat_likes").checked = value;
}

function popup_getNumberFormatter(optionSelect) {
  let formatterNotation;
  let formatterCompactDisplay;
  let userLocales;
  try {
    userLocales = new URL(
      Array.from(document.querySelectorAll("head > link[rel='search']"))
        ?.find((n) => n?.getAttribute("href")?.includes("?locale="))
        ?.getAttribute("href"),
    )?.searchParams?.get("locale");
  } catch {}

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
  const formatter = Intl.NumberFormat(
    document.documentElement.lang || userLocales || navigator.language,
    {
      notation: formatterNotation,
      compactDisplay: formatterCompactDisplay,
    },
  );
  return formatter;
}

(async function getStatus() {
  let status = document.getElementById("status");
  let serverStatus = document.getElementById("server-status");
  let resp = await fetch(
    "https://returnyoutubedislikeapi.com/votes?videoId=YbJOTdZBX1g",
  );
  let result = await resp.status;
  if (result === 200) {
    status.innerText = "Online";
    status.style.color = "green";
    serverStatus.style.filter =
      "invert(58%) sepia(81%) saturate(2618%) hue-rotate(81deg) brightness(119%) contrast(129%)";
  } else {
    status.innerText = "Offline";
    status.style.color = "red";
    serverStatus.style.filter =
      "invert(11%) sepia(100%) saturate(6449%) hue-rotate(3deg) brightness(116%) contrast(115%)";
  }
})();

function popup_getColorFromTheme(colorTheme, voteIsLike) {
  let colorString;
  switch (colorTheme) {
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

/* popup-script.js
document.querySelector('#login')
.addEventListener('click', function () {
  chrome.runtime.sendMessage({ message: 'get_auth_token' });
});


document.querySelector("#log_off").addEventListener("click", function () {
  chrome.runtime.sendMessage({ message: "log_off" });
});
*/

/******/ })()
;