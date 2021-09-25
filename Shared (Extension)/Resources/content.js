// Listen for messages from the popup.
browser.runtime.onMessage.addListener((msg, sender, response) => {
    
  // Validate the structure of the message
  if ((msg.from === 'popup') && (msg.subject === 'getWebInfo')) {
    // Collect the URL and hostname
    var webInfo = {
      hostname: window.location.hostname,
      url: window.location.href,
    };
      
    console.log("from Content: " + webInfo);

    // Directly respond to the popup via callback
    response(webInfo);
  }
});
