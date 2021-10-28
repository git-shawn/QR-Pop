# QR Pop 💥

QR Pop is a simple iOS & MacOS app and Safari extension built to make displaying QR codes easy. The Safari Extension is inspired by the quick QR Code feature in Google Chrome, and built using [qrcodejs](https://github.com/davidshimjs/qrcodejs). QR Pop extends the Share Sheet/Share Menu on iOS and macOS to allow users to generate QR codes from most apps that share URLs as well. The app itself can generate QR codes for wifi networks, contacts, links, and more from a user's input.

[**Download Here!**](https://apps.apple.com/us/app/qr-pop/id1587360435?mt=12)

## Privacy 🕵️

Safari extensions require user permission to access website data, and for good reason. The QR pop app reads the URL of every website a user visits, so that it can generate QR codes when called on. Likewise, the app may request information as well that you wuoldn't like to share (like your wifi password to generate a qr code for your network).

The code is posted here in the interest of total transparency. All QR code processing happens on-device, so information like those URLs never leave the extension. There are also no trackers, loggers, etc. in the app.

[**Privacy Policy**](https://fromshawn.dev/qrpop.html#privacy)

## How it Works ⚙️

In Safari, QR Pop simply requests the URL from the page via JavaScript and then generates a QR code of that URL using [qrcodejs](https://github.com/davidshimjs/qrcodejs).

In the Share Sheet/Share Menu, QR Pop accepts a URL (either in Swift's URL format or as a String) and generates a QR code using CoreImage. The app itself also allows for QR code generation using CoreImage. In the app, the user can customize the QR code by selecting a foreground and background.

## License

QR Pop is licensed under GPL-3.0. If you use any of the ideas in here, I'd love to see them!
