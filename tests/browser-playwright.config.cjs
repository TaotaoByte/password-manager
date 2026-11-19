// Run upstream browser tests in the actual installed target browsers.
const path = require('node:path');
const source = path.resolve(__dirname, '../upstream/keepassxc-browser');
module.exports = {
  testDir: path.join(source, 'tests'),
  testMatch: '*.spec.ts',
  globalSetup: path.join(source, 'tests/global-setup.ts'),
  globalTeardown: path.join(source, 'tests/global-teardown.ts'),
  timeout: 30000,
  workers: 2,
  reporter: [['list'], ['json', { outputFile: path.resolve(__dirname, '../build/browser-results.json') }]],
  projects: [
    { name: 'chrome', use: { browserName: 'chromium', channel: 'chrome', headless: true } },
    { name: 'edge', use: { browserName: 'chromium', channel: 'msedge', headless: true } },
  ],
};
