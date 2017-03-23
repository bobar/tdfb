'use strict';

const electron = require('electron');
const app = electron.app;
const BrowserWindow = electron.BrowserWindow;

var authWindow = require('./authWindow');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

function createWindow (railsApp, railsAddr) {
  const {width, height} = electron.screen.getPrimaryDisplay().workAreaSize
  mainWindow = new BrowserWindow({width, height})

  mainWindow.loadURL('http://localhost:2626');

  mainWindow.on('closed', function() {
    if (railsApp) {
      railsApp.kill('SIGINT');
    }
    mainWindow = null;
  });
}

app.on('ready', function() {
  var env = Object.create( process.env );
  env.LOG_LEVEL = 'INFO';
  var railsApp;
  var rp = require('request-promise');

  rp('http://localhost:2626').catch(function (error) {
    railsApp = require('child_process').spawn('bundle', ['exec', 'rails', 's'], { stdio: 'inherit', env: env });
  });

  function start() {
    rp('http://localhost:2626').then(function (htmlString) {
      console.log('Rails server started!');
      createWindow(railsApp);
    }).catch(function (error) {
      console.log('Waiting on server to start...');
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
