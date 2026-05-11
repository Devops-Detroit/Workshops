#!/bin/bash
yum update -y
yum install -y nginx

cat > /usr/share/nginx/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps Detroit - Secondary Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #1a3a5c;
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background-color: #1e4d7a;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }
        h1 { color: #a8d4f0; }
        p  { font-size: 1.2em; }
        .badge {
            display: inline-block;
            background-color: #a8d4f0;
            color: #1a3a5c;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔵 SECONDARY SERVER</h1>
        <h2>DevOps Detroit - Linux Workshop</h2>
        <p>You are connected to the <strong>Secondary</strong> server.</p>
        <p>Hosted on Amazon EC2 — us-east-1b</p>
        <div class="badge">Week 4 - DNS Failover Lab</div>
    </div>
</body>
</html>
HTMLEOF

systemctl enable nginx
systemctl start nginx
