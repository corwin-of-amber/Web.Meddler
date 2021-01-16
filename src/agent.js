console.log("Agent meddler");

const MENU = `
<head>
  <meta charset="utf-8">
</head>
<body>
  <p>-</p>
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
    <li>הארץ
      <ul>
        <li><a href="https://www.haaretz.co.il/gallery/xword/">תשבץ הגיון - בירמן</a>
          <ul>
            <li><a href="https://www.haaretz.co.il/gallery/xword/.premium-MAGAZINE-1.9027679">1788</a></li>
          </ul>
        </li>
      </ul>
    </li>
  </ul>
</body>
`;

if (window.location.protocol == 'about:') {
    document.write(MENU);
}