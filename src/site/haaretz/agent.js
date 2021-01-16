function injectScript(payload) {
    var script = document.createElement('script');
    script.textContent = payload;
    (document.head||document.documentElement).appendChild(script);
}

injectScript(`
window.importCookie = (d) => {
    for (let a of d.split(/;\\s+/)) {
        document.cookie = a + ";max-age=31536000";
    }
};`);