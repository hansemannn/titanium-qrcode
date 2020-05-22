var QRCode = require('ti.qrcode');

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

win.add(Ti.UI.createImageView({
    image: QRCode.fromString('https://lambus.io')
}));

win.open();