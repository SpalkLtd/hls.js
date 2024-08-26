const http = require('http');
const fs = require('fs');
const path = require('path');

const directory = process.argv[2];

if (!directory) {
  console.error('Usage: node server.js <directory>');
  process.exit(1);
}

let contentType = 'application/octet-stream';
if (filePath.endsWith('.m3u8')) {
  contentType = 'application/vnd.apple.mpegurl';
} else if (filePath.endsWith('.ts')) {
  contentType = 'video/mp2t';
}

const server = http.createServer((req, res) => {
  const filePath = path.join(
    directory,
    req.url === '/' ? 'index.html' : req.url,
  );
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.statusCode = 404;
      res.end('Not Found');
    } else {
      res.setHeader('Content-Type', contentType);
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader(
        'Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept',
      );
      res.setHeader(
        'Access-Control-Allow-Methods',
        'GET, POST, PUT, DELETE, OPTIONS',
      );
      res.end(data);
    }
  });
});

const port = 8093;
server.listen(port, () => {
  console.log(`Server started on http://127.0.0.1:${port}`);
});

//http://127.0.0.1:8093/961f5f87-cbd6-4c61-9e58-bde8e801a7c9.m3u8
