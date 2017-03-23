'use strict';

const electron = require('electron');
// Module to control application life.
const app = electron.app;
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow;

var authWindow = require('./authWindow/authWindow');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

function createWindow (railsApp, railsAddr) {
  // Create the browser window.
  const {width, height} = electron.screen.getPrimaryDisplay().workAreaSize
  mainWindow = new BrowserWindow({width, height})

  // and load the rails app of the app.
  mainWindow.loadURL('http://localhost:2626');

  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.

    railsApp.kill('SIGINT');
    mainWindow = null;
  });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
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

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow();
  }
});

app.on('login', (event, webContents, request, authInfo, callback) => {
    // for http authentication
    event.preventDefault();
    authWindow.createAuthWindow(callback);
});
