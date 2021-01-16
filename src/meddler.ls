fs = require 'fs'
$ = require 'jquery'

#WEBSITE = 'http://towerdefense-kongregate.shinezone.com/?inner=true&region=us&kongregate_game_id=215952&kongregate_user_id=8045438&kongregate_username=corwin0amber&kongregate_game_auth_token=b88cd6c24c66ff52a09a4e40c263d996b1d033673270b43b88ab1c794909a0db'
WEBSITE = "http://google.co.il"
#WEBSITE = "https://dts.co.il/LC_RegistrationDynamic/login.aspx"
#WEBSITE = "http://iana.org"
#WEBSITE = "http://localhost:3000/page.html"

LANDING_PAGE = '''
<head>
  <meta charset="utf-8">
</head>
<body>
  <ul>
    <li> mako-tv
      <ul>
        <li><a href="http://www.mako.co.il/mako-vod-keshet/eretz_nehederet-s18/">ארץ נהדרת</a></li>
        <li><a href="https://www.mako.co.il/mako-vod-keshet/waking-bears">להעיר את הדב</a></li>
      </ul>

    <li> sdarot.tv
      <ul>
        <li><a href="https://sdarot.tv/watch/4691-%D7%A0%D7%97%D7%9E%D7%94-nechama/season/1/episode/9">נחמה</a></li>
      </ul>
    </li>
  </ul>
</body>
'''

#WEBSITE = "https://sdarot.tv/watch/4691-%D7%A0%D7%97%D7%9E%D7%94-nechama/season/1/episode/9"


FILE_RESOURCES =
  * "https://rcs.mako.co.il/js/makotv/loader.js": "data/mako/loader.js"

RECORD_REQUESTS =
  * /[/]chunklist_/
  * /[/]index_/
  * /[/](master|playlist)[.]m3u8/
  * /[/]app[.]js\b/
  * /[/]recaptcha[^.]*[.]js\b/
  * /[/]watch\b/
  * /[.]mp4[?]\b/
  * /[/]\d+[.]jpg\b/
#  * /j7/

BLOCK_REQUESTS =
  * /[/]ajax[/]watch/
  ...

REDIRECT_REQUESTS =
#  * /googlelogo_color/
#  * /j7[.]php/
  * /login[.]aspx/
  ...

FORCE_HTTP =
#  * /[.]js/
  * /j7[.]php/
  ...

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

FILTER_FILES = ['data/mako/adblock.txt', 'data/sdarot/adblock.txt'] #, 'data/haaretz/adblock.txt']


FILTERS = [].concat ...FILTER_FILES.map ->
  fs.readFileSync(it, 'utf-8').split(/\n+/).filter(-> it.length)

OVERRIDES =
  * {pat: /cast_sender[.]js/, local-file: 'data/mako/cast_sender.js'}
  ...

# does not work???!!
#nw.App.addOriginAccessWhitelistEntry "https://dts.co.il/", 'chrome-extension', location.host, true


#nw.App.setProxyConfig "http=localhost:8080"


#traffic = window.open("./traffic.html", "traffic")

window.onload = ->

  page = $('#page')[0]
  window.page = page

  $('button[name=reload]').on 'click', -> page.reload!
  $('button[name=back]').on 'click', -> page.back!
  $('button[name=home]').on 'click', -> goto-home!

  page.addEventListener 'contentload' (ev) ->
    console.log "%cload #{ev.target.src}" 'color:#99f'
    page.contentWindow.postMessage {}, '*'

  page.addContentScripts [
    {
      name: 'rule',
      matches: ['<all_urls>'],
      js: {files: ['src/agent.js', 'src/site/mako/mako.js', 'src/site/haaretz/agent.js']},
      run_at: 'document_start'
    }
  ]

  #proxy = window.open("./site/kot/proxy.html", "proxy")

  page.request.onBeforeRequest.addListener (details) ->
  #chrome.webRequest.onBeforeRequest.addListener (details) ->

    console.log details.url

    for filt in FILTERS
      filt = filt.replace(/^\|\|/, "")
      if details.url.indexOf(filt) >= 0
        console.log "%cfilter: %c#{details.url}%c #{filt}", \
                    "color: red", "text-decoration: underline", "color: #800"
        return {cancel: true}

    for re in RECORD_REQUESTS
      if re.exec details.url
        console.log details.requestId, details.requestBody
        window.postMessage({$: 'request-body', request: details}, "*")

    for re in REDIRECT_REQUESTS
      if re.exec details.url
        proxy.pending[details.requestId] = details
        console.log "redir #{details.requestId} #{details.url}"
        #url = URL.createObjectURL(blob).slice(5)
        #url = "chrome-extension://#{location.host}/data/mako/app.js"
        #console.log url
        #return {redirectUrl: url}
        return {redirectUrl: "http://localhost:8009/#{details.requestId}"}

    for ov in OVERRIDES
      if ov.pat.exec(details.url)
        data = fs.readFileSync ov.local-file
        return {redirectUrl: "data:text/javascript;base64,#{data.toString 'base64'}"}

    if /^https:/.exec(details.url)
      for re in FORCE_HTTP
        if re.exec(details.url)
          return {redirectUrl: details.url.replace(/^https:/, 'http:')}

    {}
  , {urls: ["<all_urls>"]}
  , ['blocking', 'requestBody']

  page.request.onBeforeSendHeaders.addListener (details) ->
    for re in RECORD_REQUESTS
      if re.exec details.url
        console.log details.requestId, details.url, re
        window.postMessage({$: 'request', request: details}, "*")

    for re in BLOCK_REQUESTS
      if re.exec details.url
        return {cancel: true}

    return {}

    if 0 #/[/]complete[/]/.exec(details.url)
      console.log 'redirect'
      redirectUrl: "data:text/html,#{googlejson}"
    else if /[/]not-quite-pong$/.exec(details.url)
      #e = fs.readFileSync 'data/simple-embed.html', 'utf-8'
      e = fs.readFileSync 'data/not-quite-pong' #, 'utf-8'
      redirectUrl: "data:text/html;base64,#{e.toString 'base64'}"
    else if /[/]fake[.]png$/.exec(details.url)
      reddot = fs.readFileSync 'data/reddot.png'
      redirectUrl: "data:image/png;base64,#{reddot.toString 'base64'}"
      #redirectUrl: "http://10.0.0.2:8000/data/reddot.png"
    else if /[/]fake[.]swf$/.exec(details.url)
      #flashData = fs.readFileSync 'data/flashData.swf'
      #redirectUrl: "data:application/x-shockwave-flash;base64,#{flashData.toString 'base64'}"
      redirectUrl: "http://10.0.0.2:8000/data/flashData.swf"
    else if 0 # /[/]NotQuitePong-v1.0.swf/.exec(details.url)
      console.log 'redirect'
      #buf = fs.readFileSync("/tmp/NotQuitePong-v1.0.swf")
      flashData = fs.readFileSync 'src/flashData', 'utf8'
      #redirectUrl: window.location.origin + "/src/flashData"
      #redirectUrl: "data:application/x-shockwave-flash;base64,#{flashData}" # "#{buf.toString 'base64'}"
      {}
    else
      {}

  , {urls: ["<all_urls>"]}
  , ['blocking', 'requestHeaders']


  b = new Blob([LANDING_PAGE] type: 'text/html')
  #home = URL.createObjectURL(b)
  home = 'about:blank'
  goto-home = -> page.src = home

  window <<< {goto-home}

  #proxy.redirect-path = "https://dts.co.il/LC_RegistrationDynamic"  ## HACKACK

  #page.src = WEBSITE
  #window.open(WEBSITE, 'navigator')
  wipe page .then ->
    clear-all-cookies page
    setTimeout goto-home, 100



clear-all-cookies = (page) ->
  sid = page.getCookieStoreId()
  if sid !== 'undefined,0'
    console.log "clearing cookie store #{sid}"
    cookies <- chrome.cookies.getAll {storeId: sid}
    console.log(chrome.runtime.lastError)
    for cookie in cookies ? []
      url = "http#{if cookie.secure then "s" else ""}://#{cookie.domain}#{cookie.path}"
      chrome.cookies.remove {url, cookie.name, storeId: sid}

wipe = (page) ->
  new Promise (resolve, reject) ->
    data =
      appcache: true
      cache: true
      cookies:true
      fileSystems: true
      indexedDB: true
      localStorage: true
      webSQL: true

    if ! page.clearData {since: 0}, data, resolve
      resolve!

googlejson = '''
["n",[["I want",0],["to die",0],["flash",0],["is so bad",0]],{"j":"6","q":"QVWqlgNyVpjafiDuAT7U5RFAppA","t":{"bpc":false,"tlw":false}}]
'''

autofill = ->
  script = '''
  $("div[class*=_loginBtn]").click();
  k = Object.keys($('form')[0]).find(k => k[0] == "_");
  a = $('form')[0][k];
  email = "zippityminded@mailinator.com";
  password = "0makomako";
  a._currentElement._owner._instance.setState({email: {value: email, isValid: true}, password: {value: password, isValid: true}});
  '''
  page.executeScript {code: script, mainWorld: true}


export wipe, autofill, clear-all-cookies
