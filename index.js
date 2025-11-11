const http = require('http');
const PORT = process.env.PORT || 80;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(`
    <html>
      <head><title>TP3 Application</title></head>
      <body>
        <h1>TP3 Node.js Application</h1>
        <p>Deployed with Jenkins and Kubernetes</p>
        <p>Build: ${process.env.BUILD_NUMBER || 'local'}</p>
      </body>
    </html>
  `);
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
