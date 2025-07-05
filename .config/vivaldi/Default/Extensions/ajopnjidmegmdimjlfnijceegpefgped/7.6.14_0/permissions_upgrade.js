if (typeof browser === 'undefined') {
  browser = chrome;
}

window.addEventListener('DOMContentLoaded', (event) => {
  document.getElementById('upgrade').addEventListener('click', () => {
    browser.permissions
      .request({
        origins: ['*://*.twitch.tv/*', '*://*.youtube.com/*'],
      })
      .then((granted) => {
        if (!granted) {
          return;
        }
        window.close();
      });
  });

  document.getElementById('page_title').innerText = browser.i18n.getMessage('EXTENSION_PERMISSIONS_UPGRADE_PAGE_TITLE');
  document.getElementById('title').innerText = browser.i18n.getMessage('EXTENSION_PERMISSIONS_UPGRADE_TITLE');
  document.getElementById('body_line_1').innerText = browser.i18n.getMessage('EXTENSION_PERMISSIONS_UPGRADE_BODY_1');
  document.getElementById('body_line_2').innerText = browser.i18n.getMessage('EXTENSION_PERMISSIONS_UPGRADE_BODY_2');
  document.getElementById('upgrade').innerText = browser.i18n.getMessage('EXTENSION_PERMISSIONS_UPGRADE_BUTTON');
});
