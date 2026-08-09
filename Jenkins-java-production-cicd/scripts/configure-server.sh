#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sudo install -m 0644 "$PROJECT_DIR/deploy/nginx/product-service.conf" \
  /etc/nginx/sites-available/product-service
sudo ln -sfn /etc/nginx/sites-available/product-service \
  /etc/nginx/sites-enabled/product-service
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

echo "jenkins ALL=(root) NOPASSWD: /usr/bin/sed, /usr/bin/tee, /usr/bin/mkdir, /usr/sbin/nginx, /usr/bin/systemctl reload nginx" |
  sudo tee /etc/sudoers.d/jenkins-cicd >/dev/null
sudo chmod 0440 /etc/sudoers.d/jenkins-cicd
sudo visudo -cf /etc/sudoers.d/jenkins-cicd
sudo mkdir -p /opt/product-service
sudo chown jenkins:jenkins /opt/product-service
echo "Nginx and limited Jenkins sudo permissions configured."
