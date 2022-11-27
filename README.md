# Titanium QR Code Generator & Scanner

A simple library for generating and scanning QR codes natively.

## Example

```js
import QRCode from 'ti.qrcode';

const win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

win.add(Ti.UI.createImageView({
    width: 200,
    height: 200,
    top: 30,
    image: QRCode.fromString('https://google.com')
}));


const btn = Ti.UI.createButton({
    title: 'Start scan',
    top: 250
});

btn.addEventListener('click', () => {
    QRCode.scan({
        callback: event => {
            alert('SUCCESS: ' + event.success + ', TEXT: ' + event.text || 'n/a');
        }
    });
});

win.add(btn);
win.open();
```

## License

MIT

## Author

Hans Knöchel
