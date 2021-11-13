window.addEventListener("DOMContentLoaded", (event) => {
    
    function handleResponse(message) {
        let info = message.response;
        var url = info.url
        
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
            document.body.style.width = ((info.codeSize+40) + "px")
            new QRCode(document.getElementById("qr-render"), {
                text: url,
                width: info.codeSize,
                height: info.codeSize,
                colorDark : "#000000",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.L
            });
        }
    }

    function handleError(error) {
        console.log(`Error: ${error}`);
    }

    // Request website information and user preferences from content.js
    browser.tabs.query({active: true, currentWindow: true}, function (tabs) {
        var sending = browser.tabs.sendMessage(tabs[0].id, { type: "getWebInfo" });
        sending.then(handleResponse, handleError);
    });
});
