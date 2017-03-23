const electron = require('electron');
const BrowserWindow = electron.BrowserWindow;
const ipcMain = electron.ipcMain;
const path = require('path');

module.exports = { createAuthWindow: function(loginCallback) {
    var loginWindow = new BrowserWindow({
        width: 300,
        height: 400,
        frame: false,
        resizable: false
    });
    loginWindow.loadURL('file://' + path.join(__dirname, 'authWindow.html'));

    ipcMain.once('login-message', function(event, usernameAndPassword) {
        loginCallback(usernameAndPassword[0], usernameAndPassword[1]);
        loginWindow.close();
    });
    return loginWindow;
}};
