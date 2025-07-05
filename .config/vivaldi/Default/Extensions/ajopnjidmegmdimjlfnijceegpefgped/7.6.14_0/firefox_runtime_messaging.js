if (typeof browser === 'undefined') {
  browser = chrome;
}

(async function betterttvFirefoxRuntimeMessaging() {
  const expectedExtensionID = browser.runtime.id;

  window.addEventListener(
    'message',
    (event) => {
      if (event.origin !== window.origin) {
        return;
      }

      try {
        const parsedData = JSON.parse(event.data);
        if (parsedData.extensionId !== expectedExtensionID || parsedData.type !== 'BETTERTTV_EXTENSION_COMMAND') {
          return;
        }

        browser.runtime.sendMessage(parsedData.data, (result) =>
          event.source.postMessage(
            JSON.stringify({
              extensionId: expectedExtensionID,
              type: 'BETTERTTV_EXTENSION_COMMAND_RESPONSE',
              data: result,
            })
          )
        );
      } catch (_) {}
    },
    false
  );
})();
