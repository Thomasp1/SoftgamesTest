    console.log("script started");
    var _bdate = document.getElementById('birthday');
    var _fname = document.getElementById('fname');
    var _lname = document.getElementById('lname');
    function sendToNative(message){
        if(window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.homeMessageHandler) {
            var messageHandler = window.webkit.messageHandlers.homeMessageHandler;
            messageHandler.postMessage(message);
        }
    }
    function syncButtonPressed(){
        sendToNative({ fname: _fname.value, lname: _lname.value });
    }
    function aSyncButtonPressed(){
        sendToNative({ bdate: _bdate.value});
    }