const http = require('http');
const os = require('os');
const PORT = process.env.PORT || 80;

const server = http.createServer((req, res) => {
  const buildNumber = process.env.BUILD_NUMBER || 'local';
  const hostname = os.hostname();
  const uptime = process.uptime();
  const currentTime = new Date().toLocaleString();
  
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(`
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>TP3 - CI/CD Application</title>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
          }
          .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            max-width: 600px;
            width: 100%;
            animation: fadeIn 0.5s ease-in;
          }
          @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
          }
          h1 {
            color: #667eea;
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-align: center;
          }
          .subtitle {
            color: #666;
            text-align: center;
            font-size: 1.1rem;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
          }
          .info-grid {
            display: grid;
            gap: 15px;
            margin-top: 20px;
          }
          .info-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            border-radius: 10px;
            color: white;
            transition: transform 0.3s ease;
          }
          .info-card:hover {
            transform: translateY(-5px);
          }
          .info-label {
            font-size: 0.9rem;
            opacity: 0.9;
            margin-bottom: 5px;
          }
          .info-value {
            font-size: 1.3rem;
            font-weight: bold;
          }
          .badge {
            display: inline-block;
            background: #4ade80;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: bold;
            margin-top: 10px;
          }
          .tech-stack {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 20px;
            justify-content: center;
          }
          .tech-badge {
            background: #f0f0f0;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.85rem;
            color: #333;
            font-weight: 500;
          }
          .footer {
            text-align: center;
            margin-top: 30px;
            color: #999;
            font-size: 0.9rem;
          }
          @media (max-width: 600px) {
            h1 { font-size: 2rem; }
            .container { padding: 25px; }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>TP3 Application</h1>
          <p class="subtitle">CI/CD Pipeline with Jenkins & Kubernetes</p>
          
          <div class="info-grid">
            <div class="info-card">
              <div class="info-label">Build Number</div>
              <div class="info-value">#${buildNumber}</div>
            </div>
            
            <div class="info-card">
              <div class="info-label">Container Hostname</div>
              <div class="info-value">${hostname}</div>
            </div>
            
            <div class="info-card">
              <div class="info-label">Uptime</div>
              <div class="info-value">${Math.floor(uptime)} seconds</div>
            </div>
            
            <div class="info-card">
              <div class="info-label">Current Time</div>
              <div class="info-value">${currentTime}</div>
            </div>
          </div>
          
          <div style="text-align: center; margin-top: 20px;">
            <span class="badge">✓ Deployment Successful</span>
          </div>
          
          <div class="tech-stack">
            <span class="tech-badge">Node.js</span>
            <span class="tech-badge">Docker</span>
            <span class="tech-badge">Kubernetes</span>
            <span class="tech-badge">Jenkins</span>
            <span class="tech-badge">Helm</span>
          </div>
          
          <div class="footer">
            TP3 - DevOps with CI/CD Automation
          </div>
        </div>
      </body>
    </html>
  `);
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Build: ${process.env.BUILD_NUMBER || 'local'}`);
  console.log(`Hostname: ${os.hostname()}`);
});
