
console.log("mako", chrome.runtime.id);

window.onmessage = function(ev) {
    console.log("message", ev);
    window.m = ev;
};

var config = { attributes: true, childList: true, subtree: true };

function callback(mutations, observer) { 
    for (let mr of mutations) {
        if (mr.type === 'childList') {
            for (let node of mr.addedNodes) {
                if (node.querySelector("div[class*=_loginBtn]")) {
                    autofill();
                }
            }
        }
    }
}

function autofill() {
    var evt = document.createEvent("CustomEvent");
    evt.initCustomEvent("autofill", true, true, '');
    document.dispatchEvent(evt);
}

var script = document.createElement('script');
script.textContent = `
document.addEventListener('autofill', function() {
    $("div[class*=_loginBtn]").click();
    k = Object.keys($('form')[0]).find(k => k[0] == "_");
    a = $('form')[0][k];
    email = "zippityminded@mailinator.com";
    password = "0makomako";
    a._currentElement._owner._instance.setState({email: {value: email, isValid: true}, password: {value: password, isValid: true}});
    $('form [type=submit]').click()
});
`;
(document.head||document.documentElement).appendChild(script);

var observer = new MutationObserver(callback);

observer.observe(document, config);
