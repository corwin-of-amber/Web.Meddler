http = require 'http'
https = require 'https'
url = require 'url'
fs = require 'fs'
zlib = require 'zlib'


options =
  key: fs.readFileSync('data/keys/proxy-ssl-key.pem')
  cert: fs.readFileSync('data/keys/proxy-ssl-cert.pem')


/*
 * To run proxy as https, change to https.createServer options, ...
 */
proxy = http/*s*/.createServer /*options,*/ (req, res) !->
  log-request req
  if (mo = /^[/](\d+)/.exec(req.url))?
    request-id = mo[1]
    original-req = proxy.pending[request-id]
  else if proxy.redirect-path?
    original-req = {url: "#{proxy.redirect-path}#{req.url}"}
  else
    original-req = void

  if original-req?
    #log-request req, original-req
    fwd = {} <<< url.parse(original-req.url)# <<< do
      #headers: req.headers
    fwd.method = req.method
    console.log req.headers
    fwd.headers = {}  <<< req.headers
    delete fwd.headers['host']
    #console.log fwd
    try
      _req = \
      {'http:': http, 'https:': https}[fwd.protocol]
      .request fwd, (_res) !->
        console.log "response #{request-id}"
        Object.entries(_res.headers).forEach ([k,v]) ->
          console.log "header #{k} #{v}"
          if k != 'content-length'
            res.setHeader(k, v)
        resbuf = []
        /*
        _res.on 'data' -> resbuf.push it
        _res.on 'end' ->
          payload = Buffer.concat(resbuf)
          console.log 'res', payload
          decode = switch _res.headers['content-encoding']
            | 'gzip' => zlib.gunzipSync
            | _ => -> it
          resp-data = zlib.inflateSync decode payload
          console.log 'res', JSON.parse resp-data.toString!
          res.write resp-data
          res.end!
        */
        _res.pipe res # fs.createWriteStream("/tmp/req")

      #
      req.on 'data' -> console.log 'req', it
      req.pipe _req
    catch
      console.error "proxy error"
  else
    res.end!



log-request = (req, original-req) ->
  console.log(req.method + ' ' + (req.url) + ' [' + req.headers.host + ']');
  #console.log proxy.pending
  /*
  if (mo = /^(.*?)\?/.exec(req.url))? && J7_URL_RE.exec(mo[1])
    console.log("j7")
    req.pipe concat-stream (post-data) ->
      try
        command = zlib.inflateSync(post-data)
      catch
        command = post-data
      console.log command.toString!
      #$ '#traffic' .append do ->
      #  $ '<tr>' .append do
      #    $ '<td>' .text command.toString!
      #    $ '<td>'
      */

window.addEventListener 'unload' -> proxy.close!

proxy.listen 8009, ->
  console.log "server listening on http://localhost:#{proxy.address!port}"

proxy.pending = {}

export proxy
