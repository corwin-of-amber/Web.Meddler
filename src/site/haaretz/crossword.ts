import fs from 'fs';


class CrosswordAppInterop { 

    static APPDIR = '/Users/corwin/var/workspace/Web.Crossword'
    static OUT_FN = `${CrosswordAppInterop.APPDIR}/data/birman.jpg`

    TAG = ['%c[CrosswordAppInterop]', 'color: blue']

    async fromImageRequest(req: {url: string}) {
        var url = req.url.replace(/\?precrop.*/, '');
        console.log(...this.TAG, url);
        var img = await (await fetch(url)).arrayBuffer(),
            fn = CrosswordAppInterop.OUT_FN;
        fs.writeFileSync(fn, new Uint8Array(img));
        console.log(...this.TAG, 'wrote ' + fn);
    }
}


export { CrosswordAppInterop }