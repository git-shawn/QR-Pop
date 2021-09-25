# QR Pop 💥

QR Pop is an extremely simple iOS & MacOS Safari extension built to display a QR code for the website in focus. Inspired by the quick QR Code feature in Google Chrome, and built using [qrcodejs](https://github.com/davidshimjs/qrcodejs).

[**Download Here!**](https://apps.apple.com/us/app/qr-pop/id1587360435?mt=12)

## Privacy 🕵️

Safari extensions require user permission to access website data, and for good reason. The QR pop app reads the URL of every website a user visits, so that it can generate QR codes when called on.

The code is posted here in the interest of total transparency. All QR code processing happens on-device, so information like those URLs never leave the extension.

## How it Works ⚙️

QR Pop is a Safari extension that creates a popup view of a QR code linking to the webpage in focus. In Safari the "All Websites" permission is preferred to allow the extension to see the URL and hostname of every website so that it can quickly create a QR code.

QR code creation is done entirely in JavaScript utilizing the [qrcodejs](https://github.com/davidshimjs/qrcodejs) library. The URL and hostname is gathered from a website via the extension's content script and sent to the popup script. The popup script then generates the QR code and displays it in the popup html alongside the website's hostname, as a reassurance that the QR code is right. While the QR code displays at 170px, its generated at 512px. This allows the user to save a high-quality image of the code if they want.

That's it! It's an extremely simple extension, but hopefully a useful one.

## Support

Please [open an issue](https://github.com/git-shawn/qr-pop/issues/new) for support.

## License

Yeah go crazy with it. This code is distributed as-is under the MIT license.