# Titanium QR Code Generator

A simple library for generating QR codes natively.

## Example

```js
import QRCode from 'ti.qrcode';

const win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

win.add(Ti.UI.createImageView({
    image: QRCode.fromString('https://google.com')
}));

win.open();
```

## License

MIT

## Author

Hans Knöchel
