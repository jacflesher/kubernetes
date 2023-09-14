var express = required('express');
var app = express();
app.use(express.static('dist/rapidytdl'));
app.get('/', function (req, res, next) {res.redirect('/');});
app.listen(8080);
