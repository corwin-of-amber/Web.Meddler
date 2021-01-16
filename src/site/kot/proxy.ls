
httpProxy = require('http-proxy')
url = require('url')
net = require('net')
http = require('http')
concat-stream = require 'concat-stream'
zlib = require 'zlib'
fs = require 'fs'
uuid = require 'uuid/v1'


regularProxy = httpProxy.createProxyServer({})

server = http.createServer (req, res) ->
  req.uid = uuid()
  log-request req
  if req.url is /\.xml$/ && req.method == 'GET'
    console.log req
    u = new URL(req.url)
    fwd =
      method: req.method
      host: u.host
      port: u.port || 80
      path: u.pathname   # note: ignores query string
      headers: req.headers
    http.request fwd, (_res) ->
      console.log("xml document requested...")
      Object.entries(_res.headers).forEach ([k,v]) ->
        if k != 'content-length'
          res.setHeader(k, v)
        console.log k, v

      _res.pipe concat-stream ->
        window.buf = it
        s = (if _res.headers['content-encoding'] == "gzip" then zlib.gunzipSync(it) else it).toString!
        console.log s
        s .= replace /locked="1"/g, 'locked="0"'
        console.log s
        buf = if _res.headers['content-encoding'] == "gzip" then zlib.gzipSync(s) else s
        res.write buf ; res.end!
    .end!
  else
    regularProxy.web req, res, do
      target: req.url.replace 'https:', 'http:'
      prependPath: false

# For HTTPS
server.on 'connect', (req, socket, head)  ->
  logRequest req
  # URL is in the form 'hostname:port'
  parts = req.url.split(':', 2)
  # open a TCP connection to the remote host
  conn = net.connect parts[1], parts[0], ->
    # respond to the client that the connection was made
    socket.write("HTTP/1.1 200 OK\r\n\r\n")
    # create a tunnel between the two hosts
    socket.pipe conn
    conn.pipe socket


log-request = (req) ->
  console.log(req.method + ' ' + (req.url) + ' [' + req.headers.host + ']');
  if (mo = /^(.*?)\?/.exec(req.url))? && J7_URL_RE.exec(mo[1])
    console.log("j7")
    req.pipe concat-stream (post-data) ->
      try
        command = zlib.inflateSync(post-data)
      catch
        command = post-data
      console.log command.toString!
      $ '#traffic' .append do ->
        $ '<tr>' .append do
          $ '<td>' .text command.toString!
          $ '<td>'
  else if /\/$/.exec(req.url) && req.method == 'POST'
    req.pipe concat-stream (post-data) ->
      $ '#traffic' .append do ->
        $ '<tr>' .attr 'uid' req.uid .append do
          $ '<td>' .text req.url + ': ' + post-data.toString!
          $ '<td>'

window.addEventListener 'unload' -> server.close!

server.listen 8080, ->
  console.log "server listening on http://localhost:#{server.address!port}"

regularProxy.on 'proxyRes' (res, o_req, o_res) ->
  console.log 'proxyRes', res.req.method, res.req.path, "[#{o_req.uid}]"
  req = res.req
  if (mo = /^(.*?)\?/.exec(req.path))? && J7_PATH_RE.exec(mo[1])
    res.pipe concat-stream safe ->
      decode = switch res.headers['content-encoding']
        | 'gzip' => zlib.gunzipSync
        | _ => -> it
      resp-data = zlib.inflateSync decode it
      console.log resp-data
      $ '#traffic' .append do ->
        $ '<tr>' .append do
          $ '<td>'
          $ '<td>' .text resp-data.toString!
  else if /\/$/.exec(req.path) && req.method == 'POST'
    res.pipe concat-stream safe (resp-data) ->
      get-response-td(o_req.uid).text resp-data.toString!
  else if /[.]css$/.exec(req.path)
    res.pipe fs.createWriteStream('/tmp/a.css')


safe = (op) -> -> try op ... catch e => console.error e

get-response-td = (uid) ->
  tr = $ "tr[uid=#{uid}]" .last!
  if tr.length == 0
    $ '#traffic' .append (tr = $ '<tr>' .attr 'uid' uid)
  while (td = tr.find('td').eq(1)).length == 0
    tr.append $ '<td>'
  td

export server, regularProxy
