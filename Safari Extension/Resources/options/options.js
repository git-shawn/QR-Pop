window.onload = function(e){
    let codeSizePicker = document.getElementById("codeSizePicker");
    let showHostname = document.getElementById("showURL");
    let hideUTM = document.getElementById("hideUTM");
    let bgPicker = document.getElementById("bgColorPicker");
    let fgPicker = document.getElementById("fgColorPicker");
    
    browser.storage.local.get({
    codeSize: "200",
    bgColor: "#ffffff",
    fgColor: "#000000",
    showHostname: "true",
    referralToggle: "true",
    }, function (items) {
        codeSizePicker.value = items.codeSize;
        showHostname.checked = items.showHostname === "true";
        hideUTM.checked = items.referralToggle === "true";
        bgPicker.value = items.bgColor;
        fgPicker.value = items.fgColor;
    });
    
    codeSizePicker.addEventListener("change", setCodeSize);
    showHostname.addEventListener("change", setShowURL);
    hideUTM.addEventListener("change", setRemoveUTM);
    bgPicker.addEventListener("change", setBGColor);
    fgPicker.addEventListener("change", setFGColor);
}

function setCodeSize() {
    var value = document.getElementById("codeSizePicker").value;
    browser.storage.local.set({ codeSize: value });
}

function setShowURL() {
    var value = document.getElementById("showURL").checked;
    browser.storage.local.set({ showHostname: value });
}

function setRemoveUTM() {
    var value = document.getElementById("hideUTM").checked;
    browser.storage.local.set({ referralToggle: value });
}

function setBGColor() {
    var value = document.getElementById("bgColorPicker").value;
    browser.storage.local.set({ bgColor: value });
}

function setFGColor() {
    var value = document.getElementById("fgColorPicker").value;
    browser.storage.local.set({ fgColor: value });
}
