const electron = require('electron');
const BrowserWindow = electron.BrowserWindow;
const ipcMain = electron.ipcMain;

module.exports = { createAuthWindow: function(mainWindow, loginCallback) {
  var loginWindow = new BrowserWindow({
    frame: false,
    height: 250,
    modal: true,
    parent: mainWindow,
    movable: false,
    resizable: false,
    show: false,
    width: 200,
  });

  loginWindow.once('ready-to-show', function() {
    loginWindow.show();
    loginWindow.focus();
    loginWindow.webContents.executeJavaScript('\
        var ipcRenderer = require("electron").ipcRenderer;\
        const form = document.getElementById("login-form");\
        console.log(form);\
        document.getElementById("trigramme").focus();\
        form.addEventListener("submit", function(event) {\
            console.log("submit");\
            event.preventDefault();\
            const username = document.getElementById("trigramme").value;\
            const password = document.getElementById("password").value;\
            ipcRenderer.send("login-message", [username, password]);\
        });\
        document.addEventListener("keydown", event => {\
            if (event.key === "Escape" || event.keyCode === 27) {\
                window.close();\
            }\
        });'
    );
  });
  loginWindow.loadURL('http://localhost:2626/login');

  ipcMain.once('login-message', function(event, usernameAndPassword) {
    try {
      loginWindow.close();
      loginCallback(usernameAndPassword[0], usernameAndPassword[1]);
    } catch(e) { /* Do nothing */ }
  });
}};
