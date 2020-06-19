// HTTP forward proxy server that can also proxy HTTPS requests
// using the CONNECT method

// requires https://github.com/nodejitsu/node-http-proxy

var httpProxy = require('http-proxy'),
    url = require('url'),
    net = require('net'),
    http = require('http');

process.on('uncaughtException', logError);

function truncate(str) {
    var maxLength = 64;
    return (str.length >= maxLength ? str.substring(0,maxLength) + '...' : str);
}

function logRequest(req) {
    console.log(req.method + ' ' + truncate(req.url) + ' [' + req.headers.host + ']');
}

function requestToCurl(req, post_data) {
    function fmt_hdr(hdr) {
        return `-H '${hdr[0]}: ${hdr[1]}'`;
    }
    function fmt_data(data) {
        return data ? `--data '${data}'` : '';
    }
    return `curl '${req.url}' ${Object.entries(req.headers).map(fmt_hdr).join(" ")} ${fmt_data(post_data)}`;
}

function logError(e) {
    console.warn('*** ' + e);
}

// this proxy will handle regular HTTP requests
//var regularProxy = new httpProxy.RoutingProxy();
var regularProxy = httpProxy.createProxyServer({});

// standard HTTP server that will pass requests
// to the proxy
var server = http.createServer(function (req, res) {
  logRequest(req);
  //uri = url.parse(req.url);
  regularProxy.web(req, res, {
      //host: uri.hostname,
      //port: uri.port || 80,
      target: req.url.replace('https:', 'http:'), //'http://' + req.headers.host
      prependPath: false
  });
});

regularProxy.on('proxyRes', function(proxyRes, req, res) {
  console.log('proxyRes', proxyRes);
});

regularProxy.on('end', function(proxyRes, req, res) {
  console.log('proxy end', proxyRes);
});


// when a CONNECT request comes in, the 'upgrade'
// event is emitted
server.on('connect', function(req, socket, head) {
    logRequest(req);
    // URL is in the form 'hostname:port'
    var parts = req.url.split(':', 2);
    // open a TCP connection to the remote host
    var conn = net.connect(parts[1], parts[0], function() {
        // respond to the client that the connection was made
        socket.write("HTTP/1.1 200 OK\r\n\r\n");
        // create a tunnel between the two hosts
        socket.pipe(conn);
        conn.pipe(socket);
    });
});

server.listen(8080);
