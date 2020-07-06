var express = require('express');

var app = module.exports = express();

app.use(express.static(__dirname + '/'));
app.use('/build', express.static('public'));

app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

app.get('/', function(req, res) {
    res.sendFile(path.join(__dirname + './index.html'));
});

app.listen(8000);
console.log("elm dictionary listenting at port 8000: ")