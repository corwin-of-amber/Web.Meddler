const express = require('express')
const path = require('path')


const app = express()


app.use(express.static(path.join(__dirname, 'static')));
app.use('/node_modules', express.static(path.join(__dirname, 'node_modules')));

app.get('/', (req, res) => res.send('Hello World!'))

app.post('/', (req, res) => {
    console.log(new Date());
    req.on('data', (data) => console.log(data.toString('utf-8')));
    req.on('end', () => {
        console.log("END");
        res.send("OK.");
    });
});
app.listen(3000, () => console.log('Example app listening on port 3000!'))
