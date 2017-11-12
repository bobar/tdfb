'use strict';

const electron = require('electron');
var path = require('path');

const app = electron.app;
const BrowserWindow = electron.BrowserWindow;

var authWindow = require('./authWindow');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

function createWindow (railsApp) {
  const {width, height} = electron.screen.getPrimaryDisplay().workAreaSize;
  mainWindow = new BrowserWindow({
    width: width,
    height: height,
    icon: path.join(__dirname, 'app/assets/images/pinte_squared.png'),
    show: false,
  });

  mainWindow.once('ready-to-show', function() {
    mainWindow.show();
  });

  mainWindow.setMenu(null);

  mainWindow.loadURL('http://localhost:2626');

  mainWindow.on('closed', function() {
    if (railsApp) {
      railsApp.kill('SIGINT');
    }
    mainWindow = null;
  });
}

app.on('ready', function() {
  var env = Object.create(process.env);
  env.LOG_LEVEL = 'INFO';
  var railsApp;
  var rp = require('request-promise');

  rp('http://localhost:2626').catch(function () {
    railsApp = require('child_process').spawn('bundle', ['exec', 'rails', 's'], { stdio: 'inherit', env: env });
  });

  function start() {
    rp('http://localhost:2626').then(function () {
      console.log('Rails server started!'); // eslint-disable-line no-console
      createWindow(railsApp);
    }).catch(function () {
      console.log('Waiting on server to start...'); // eslint-disable-line no-console
      setTimeout(start, 1000);
    });
  }
  start();
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', function () {
  if (mainWindow === null) {
    createWindow();
  }
});

app.on('login', (event, webContents, request, authInfo, callback) => {
  event.preventDefault();
  authWindow.createAuthWindow(mainWindow, callback);
});
