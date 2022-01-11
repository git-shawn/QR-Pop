browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    
    // Once we have our user defaults from background.js, respond to popup.js
    function handleResponse(message) {
        var codeSize = message.response.codeSize;
        var bgColor = message.response.bgColor;
        var fgColor = message.response.fgColor;
        
        // If the user hasn't changed the settings, codeSize will be 0.
        // In that scenario, we assume the QR code should be 190px.
        if (codeSize == 0) {
            codeSize = 190;
        }
        
        // If the user has chosen colors, use them. Otherwise, default to black and white.
        if (bgColor == "") {
            bgColor = "#ffffff"
        }
        if (fgColor == "") {
            fgColor = "#000000"
        }
        
        // Pass along all defaults, as well as the webpage's URL and hostname.
        var webInfo = {
            hostname: window.location.hostname,
            url: window.location.href,
            codeSize: codeSize,
            showHostname: message.response.showHostname,
            referralToggle: message.response.referralToggle,
            bgColor: bgColor,
            fgColor: fgColor
        };
        
        sendResponse({ response: webInfo });
    }

    function handleError(error) {
        console.log(`Error: ${error}`);
    }
    
    if (request.type == "getWebInfo") {
        
        // Ask background.js to ask the native script what the user defaults are
        var sending = browser.runtime.sendMessage({ type: "getDefaults" });
        sending.then(handleResponse, handleError);
        return true;
    }
});
