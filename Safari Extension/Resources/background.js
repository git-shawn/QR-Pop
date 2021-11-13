browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    function handleNativeResponse(nativeResponse) {
        sendResponse({ response: nativeResponse });
    }

    function handleNativeError(error) {
        sendResponse({ response: `Error: ${error}` });
    }
    
    if (request.type == "getDefaults") {
        
        // Pass the message from content.js along to the native script
        var sending = browser.runtime.sendNativeMessage("shwndvs.QR-Pop", { message: request.type });
        sending.then(handleNativeResponse, handleNativeError);
        return true;
    }
});
