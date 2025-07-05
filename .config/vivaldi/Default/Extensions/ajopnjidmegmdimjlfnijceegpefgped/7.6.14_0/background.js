if (typeof browser === 'undefined') {
  browser = chrome;
}

async function registerDynamicContentScript() {
  let browserName = 'Chrome';
  try {
    const browserInfo = await browser.runtime.getBrowserInfo();
    browserName = browserInfo.name;
  } catch (_) {}

  try {
    const script = {
      id: 'betterttv-youtube',
      allFrames: true,
      js: ['betterttv.js'],
      css: ['betterttv.css'],
      matches: ['*://*.youtube.com/*'],
    };

    // Firefox fails to register if this key even exists in the object
    if (browserName === 'Chrome') {
      script.world = 'MAIN';
    }

    await browser.scripting.registerContentScripts([script]);
  } catch (_) {}

  try {
    // Firefox doesn't support runtime connections from pages, so we need a workaround content script
    if (browserName === 'Firefox') {
      await browser.scripting.registerContentScripts([
        {
          id: 'betterttv-firefox-twitch-runtime-messaging',
          allFrames: true,
          js: ['firefox_runtime_messaging.js'],
          matches: ['*://*.twitch.tv/*'],
        },
      ]);
      await browser.scripting.registerContentScripts([
        {
          id: 'betterttv-firefox-youtube-runtime-messaging',
          allFrames: true,
          js: ['firefox_runtime_messaging.js'],
          matches: ['*://*.youtube.com/*'],
        },
      ]);
    }
  } catch (_) {}
}

async function requestPermission() {
  const granted = await browser.permissions.contains({
    origins: ['*://*.youtube.com/*'],
  });
  if (granted) {
    return false;
  }

  browser.tabs.create({url: 'permissions_upgrade.html'});
  return true;
}

browser.runtime.onMessage.addListener(async (request, sender, sendResponse) => {
  switch (request.type) {
    case 'CHECK_YOUTUBE_PERMISSION':
      sendResponse(
        await browser.permissions.contains({
          origins: ['*://*.youtube.com/*'],
        })
      );
      return;
    case 'REQUEST_YOUTUBE_PERMISSION':
      requestPermission();
      sendResponse(null);
      return;
  }
});

browser.runtime.onMessageExternal.addListener(async (request, sender, sendResponse) => {
  switch (request.type) {
    case 'CHECK_YOUTUBE_PERMISSION':
      sendResponse(
        await browser.permissions.contains({
          origins: ['*://*.youtube.com/*'],
        })
      );
      return;
    case 'REQUEST_YOUTUBE_PERMISSION':
      requestPermission();
      sendResponse(null);
      return;
  }
});

browser.runtime.onInstalled.addListener(({reason}) => {
  if (reason !== 'install') {
    return;
  }

  requestPermission();
});

browser.permissions.onAdded.addListener(() => {
  registerDynamicContentScript();
});

browser.action.onClicked.addListener(async (tab) => {
  const tabs = await browser.tabs.query({active: true, currentWindow: true});
  const activeTabUrl = new URL(tabs[0].url);
  if (
    (activeTabUrl.host.endsWith('.youtube.com') || activeTabUrl.host === 'youtube.com') &&
    (await requestPermission())
  ) {
    return;
  }

  browser.tabs.create({url: 'https://betterttv.com/dashboard'});
});

registerDynamicContentScript();
