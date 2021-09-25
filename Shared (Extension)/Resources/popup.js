// Update the relevant fields with the new data.
const setWebInfo = info => {
    let matched = window.matchMedia('(prefers-color-scheme: dark)').matches;
    if(matched) {
        new QRCode(document.getElementById("qr-render"), {
            text: info.url,
            width: 512,
            height: 512,
            colorDark : "#ffffff",
            colorLight : "#1D1D1F",
            correctLevel : QRCode.CorrectLevel.L
        });
    } else {
        new QRCode(document.getElementById("qr-render"), {
            text: info.url,
            width: 512,
            height: 512,
            colorDark : "#1D1D1F",
            colorLight : "#ffffff",
            correctLevel : QRCode.CorrectLevel.L
        });
    }
    if(info.hostname){
        document.getElementById('website-title').textContent = info.hostname;
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
