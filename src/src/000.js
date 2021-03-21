const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const { exec } = require('child_process');

const cout = (res, str) => res.send(`${str}`);

app.get('/',       	 (req, res) => exec('bin/001', (err, stdout, stderr) => cout(res,(err) ? `${stderr}` : `${stdout}`)))
app.get('/aws',    	 (req, res) => exec('bin/002', (err, stdout, stderr) => cout(res, stdout)))
app.get('/docker',       (req, res) => exec('bin/003', (err, stdout, stderr) => cout(res, stdout)))
app.get('/loadbalanced', (req, res) => exec('bin/004 ' + JSON.stringify(req.headers), (err, stdout, stderr) => cout(res, stdout)))
app.get('/tls',          (req, res) => exec('bin/005 ' + JSON.stringify(req.headers), (err, stdout, stderr) => cout(res, stdout)))
app.get('/secret_word',  (req, res) => exec('bin/006 ' + JSON.stringify(req.headers), (err, stdout, stderr) => cout(res, stdout)))

app.listen(port, () => {
	console.log(`Secret: ${process.env.SECRET_WORD}`);
	console.log(`Rearc quest listening on port ${port}!`);
})
