fs = require 'fs'
mkdirp = require 'mkdirp'
$ = require 'jquery'

haaretz = require './site/haaretz/crossword'


TMPDIR = '/tmp/Web.Meddler'


$ ->
  $ '#requests' .click 'a' (ev) ->
    ev.preventDefault!
    tr = $(ev.target).closest('tr')
    fname = $(ev.target).attr('data-fname')
    console.log 'click' fname
    if fname && fname.endsWith('.m3u8')
      downloads.commence-download fname, tr
    if fname && fname.endsWith('.jpg')
      (new haaretz.CrosswordAppInterop).fromImageRequest(load(fname))

  add-line = (name, url) -> 
      tds =
        * $ '<td>' .append ($ '<a>' .text name \
                                    .attr 'data-fname' name \
                                    .attr 'href' url)
        * $ '<td>' .text url
      $ '<tr>' .append tds
        $ '#requests' .append ..
        ..0.scrollIntoView!

  window.addEventListener 'message' (message) ->
    m = message.data
    switch m.$
      case 'request' =>
        /* serialize request data */
        fname = save m.request
        /* show in requests table */
        add-line fname, m.request.url
      case 'request-body' =>
        save m.request, '.body.json'
      default
        p = $ '<p>' .text "message #{JSON.stringify m}"
        $ 'body' .append p


save = (request, ext = '.json') ->
  /([^\/?]+)([?].*)?$/.exec request.url
    fname = ..?1 ? ''
  if fname != ''
    mkdirp.sync TMPDIR
    fs.writeFileSync "#{TMPDIR}/#{fname}#{ext}" serialize-request(request)
  return fname

load = (fname, ext = '.json') ->
  return JSON.parse(fs.readFileSync("#{TMPDIR}/#{fname}#{ext}"))

serialize-request = (req) ->
  console.log(req)
  headers = {}
    for {name, value} in req.requestHeaders ? []
      ..[name] = value
  # These are defaults. TODO read from actual request headers
  JSON.stringify {} <<< do -> 
    'user-agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:55.0) Gecko/20100101 Firefox/55.0"
    'accept': "*/*"
    "accept-language":"en-US,en;q=0.5"
    "accept-encoding":"gzip, deflate"
    "connection":"keep-alive"
    headers: headers
  <<< req

#
# Experimental (specifically for mako)
#
ProgressBar = require('progressbar.js')

MAKO_HD = '/Users/corwin/var/workspace/Web.Scrape/src/mako_hd'

class DownloadManager

  ->
    @active-processes = []
    @active-downloads = []

  commence-download: (fname, tr) ->
    require! child_process
    require! path
    #p = child_process.spawn path.join(MAKO_HD, '/download.js'), \
    #  ["#{TMPDIR}/#{fname}.json"], {stdio: 'inherit'}
    #@active-processes.push p
    dl = require(path.join(MAKO_HD, '/download.js'))
    ui =
      pbs: tr && @create-progress-bars(tr)
      msg: (txt) -> console.log txt
      err: (txt, e) -> console.log txt; console.error e
      chunk: (info, progress) ->
        if progress then
          if @pbs then @pbs.chunk.set (progress.downloaded / progress.total)
        else
          console.log info, progress
          if @pbs then @pbs.overall.set (info.idx / info.length)
    promise = dl.main(["#{TMPDIR}/#{fname}.json"], ui)
    @active-downloads.push {ui, promise}
  
  create-progress-bars: (tr) ->
    mk-circle = ->
      pbdiv = $ '<div>' .addClass('download-progress')
        tr.find('td').last!prepend ..
      new ProgressBar.Circle(pbdiv.0, strokeWidth: 20)
    {chunk: mk-circle!, overall: mk-circle!}

  stop-all: ->
    while (p = @active-processes.pop!)
      p.kill 3  # INT
    while (p = @active-downloads.pop!)
      p.ui.stop = true

downloads = new DownloadManager



window <<< {downloads}
