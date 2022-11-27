import QRCode from 'ti.qrcode';

const window = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

window.add(Ti.UI.createImageView({
    image: QRCode.fromString('https:/google.com')
}));

window.open();