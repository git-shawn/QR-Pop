// Update the relevant fields with the new data.
const setWebInfo = info => {

    if(info.hostname && info.url){
        document.getElementById('website-title').textContent = info.hostname;
        new QRCode(document.getElementById("qr-render"), {
            text: info.url,
            width: 170.66,
            height: 170.66,
            colorDark : "#000000",
            colorLight : "#ffffff",
            correctLevel : QRCode.CorrectLevel.L
        });
    }
};

window.addEventListener('DOMContentLoaded', () => {
    console.log("begin");
    browser.tabs.query({
        active: true,
        currentWindow: true
    }, tabs => {
    browser.tabs.sendMessage(
        tabs[0].id,
        {from: 'popup', subject: 'getWebInfo'},
        setWebInfo);
    });
});
