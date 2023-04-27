browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    
    if (request.type == "getWebInfo") {
        
        let gettingItems = browser.storage.local.get({
        codeSize: "190",
        bgColor: "#ffffff",
        fgColor: "#000000",
        showHostname: "true",
        referralToggle: "true"
        }, (items) => {
            
            var webInfo = {
            hostname: window.location.hostname,
            url: window.location.href,
            codeSize: items.codeSize,
            showHostname: items.showHostname,
            referralToggle: items.referralToggle,
            bgColor: items.bgColor,
            fgColor: items.fgColor
            };
            
            sendResponse({ response: webInfo });
        });
        return true;
    }
    
    if (request.type == "openSettings") {
        
    }
});
