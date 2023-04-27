const optionsButton = document.getElementById("optionsButton");

window.onload = function() {
    optionsButton.addEventListener("click", openOptions);

    function handleResponse(message) {

        let info = message.response;
        var url = info.url
        let codeSize = parseInt(info.codeSize)+40
        
        if(info.hostname && info.url){
            
            // If the user allows, show the website's hostname in the popup.
            if (info.showHostname) {
                document.getElementById('website-title').textContent = info.hostname;
            } else {
                document.getElementById('website-title').style.display = "none";
            }
            
            // If the user allows, this regex strips tracking parameters.
            if (info.referralToggle) {
                url = url.replace(/(\?)utm[^&]*(?:&utm[^&]*)*&(?=(?!utm[^\s&=]*=)[^\s&=]+=)|\?utm[^&]*(?:&utm[^&]*)*$|&utm[^&]*/gi, '$1')
            }
            
            // Set the QR Code to be the user's desired with.
            // The body should be 40px larger than the code, 20 on each side.
            if (codeSize > 150) {
                document.body.style.width = ((codeSize) + "px")
            } else {
                document.body.style.minWidth = ("150px")
            }
            new QRCode(document.getElementById("qr-render"), {
            text: url,
            width: info.codeSize,
            height: info.codeSize,
                colorDark : info.fgColor,
                colorLight : info.bgColor,
                correctLevel : QRCode.CorrectLevel.L
            });
            
            // Match the QR Code's padding and border to the user's chosen colors.
            document.getElementById("qr-render").getElementsByTagName("img")[0].style.backgroundColor=info.bgColor;
            document.getElementById("qr-render").getElementsByTagName("img")[0].style.borderColor=info.fgColor;

            // Display and set the "Open in QR Pop Button"
            document.getElementById("openQRPopButton").onclick = function() { window.open("qrpop:///buildlink/?"+encodeURIComponent(url)) };
            document.getElementById("openQRPopButton").style.display = "inline-block";
        }
    }
    
    function handleError(error) {
        console.error(`Error: ${error}`);
    }
    
    // Request website information and user preferences from content.js
    browser.tabs.query({active: true, currentWindow: true}, function (tabs) {
        var sending = browser.tabs.sendMessage(tabs[0].id, { type: "getWebInfo" });
        sending.then(handleResponse, handleError);
    });
}

function openOptions() {
    browser.runtime.openOptionsPage();
}
