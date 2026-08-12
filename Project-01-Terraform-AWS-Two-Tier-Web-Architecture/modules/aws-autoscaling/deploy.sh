#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y nginx

INSTANCE_HOSTNAME=$(hostname)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Two-Tier AWS Architecture</title>
  <style>
    body {
      margin: 0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #071426, #123d64);
      color: white;
      font-family: Arial, sans-serif;
      text-align: center;
    }

    .card {
      padding: 45px;
      border-radius: 18px;
      background: rgba(255, 255, 255, 0.1);
    }

    h1 {
      color: #61dafb;
    }

    .status {
      color: #7cfc98;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>Two-Tier AWS Architecture</h1>
    <p class="status">Application is running successfully</p>
    <p>Served by EC2 instance: ${INSTANCE_HOSTNAME}</p>
    <p>Provisioned using Terraform and Auto Scaling</p>
  </div>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
