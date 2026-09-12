terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
  }
}

provider "aws" {
  region = var.region_name
}

# ============================================================
# STEP 1: SECURITY GROUP
# ============================================================

resource "aws_security_group" "my-sg" {
  name        = "JENKINS-SERVER-SG"
  description = "Jenkins and DevOps Server Ports"

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # etcd
  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube
  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node Exporter
  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes kubelet
  ingress {
    description = "Kubernetes Kubelet"
    from_port   = 10250
    to_port     = 10260
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes NodePort
  ingress {
    description = "Kubernetes NodePort"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ============================================================
# STEP 2: EC2 INSTANCE
# ============================================================

resource "aws_instance" "my-ec2" {

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.my-sg.id
  ]

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = var.server_name
  }


  # ==========================================================
  # REMOTE EXECUTION
  # ==========================================================

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      private_key = file("./key.pem")
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [

      # ------------------------------------------------------
      # SYSTEM UPDATE
      # ------------------------------------------------------

      "sudo apt-get update -y",

      "sudo apt-get install -y curl wget unzip ca-certificates gnupg lsb-release apt-transport-https software-properties-common git",

      # ------------------------------------------------------
      # AWS CLI
      # ------------------------------------------------------

      "curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip",

      "cd /tmp && unzip -q -o awscliv2.zip",

      "sudo /tmp/aws/install --update",

      "aws --version",


      # ------------------------------------------------------
      # DOCKER
      # Official Docker repository
      # ------------------------------------------------------

      "sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc || true",

      "sudo install -m 0755 -d /etc/apt/keyrings",

      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",

      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      "echo \"Types: deb\" | sudo tee /etc/apt/sources.list.d/docker.sources",

      "echo \"URIs: https://download.docker.com/linux/ubuntu\" | sudo tee -a /etc/apt/sources.list.d/docker.sources",

      "echo \"Suites: $(. /etc/os-release && echo $${UBUNTU_CODENAME:-$VERSION_CODENAME})\" | sudo tee -a /etc/apt/sources.list.d/docker.sources",

      "echo \"Components: stable\" | sudo tee -a /etc/apt/sources.list.d/docker.sources",

      "echo \"Architectures: $(dpkg --print-architecture)\" | sudo tee -a /etc/apt/sources.list.d/docker.sources",

      "echo \"Signed-By: /etc/apt/keyrings/docker.asc\" | sudo tee -a /etc/apt/sources.list.d/docker.sources",

      "sudo apt-get update -y",

      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      "sudo systemctl enable docker",

      "sudo systemctl start docker",

      "sudo systemctl is-active docker",

      "docker --version",

      "docker compose version",

      "sudo docker run --rm hello-world",


      # ------------------------------------------------------
      # DOCKER GROUP
      # ------------------------------------------------------

      "sudo usermod -aG docker ubuntu",


      # ------------------------------------------------------
      # SONARQUBE
      # ------------------------------------------------------

      "sudo docker pull sonarqube:lts-community",

      "sudo docker rm -f sonarqube 2>/dev/null || true",

      "sudo docker run -d --name sonarqube --restart unless-stopped -p 9000:9000 sonarqube:lts-community",

      "sudo docker ps --filter name=sonarqube",


      # ------------------------------------------------------
      # TRIVY
      # ------------------------------------------------------

      "sudo apt-get install -y wget gnupg",

      "wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null",

      "echo \"deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main\" | sudo tee /etc/apt/sources.list.d/trivy.list",

      "sudo apt-get update -y",

      "sudo apt-get install -y trivy",

      "trivy --version",


      # ------------------------------------------------------
      # KUBECTL
      # Current stable release
      # ------------------------------------------------------

      "KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)",

      "curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl",

      "curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256",

      "echo \"$(cat kubectl.sha256)  kubectl\" | sha256sum --check",

      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",

      "kubectl version --client",

      "rm -f kubectl kubectl.sha256",


      # ------------------------------------------------------
      # HELM
      # Latest Helm 3
      # ------------------------------------------------------

      "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",

      "helm version",


      # ------------------------------------------------------
      # ARGO CD CLI
      # ------------------------------------------------------

      "ARGOCD_VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)",

      "curl -sSL -o /tmp/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$${ARGOCD_VERSION}/argocd-linux-amd64",

      "sudo install -m 0755 /tmp/argocd-linux-amd64 /usr/local/bin/argocd",

      "rm -f /tmp/argocd-linux-amd64",

      "argocd version --client",


      # ------------------------------------------------------
      # JAVA 21
      # Jenkins current LTS requirement
      # ------------------------------------------------------

      "sudo apt-get update -y",

      "sudo apt-get install -y fontconfig openjdk-21-jre",

      "java -version",


      # ------------------------------------------------------
      # JENKINS CURRENT LTS REPOSITORY
      # ------------------------------------------------------

      "sudo rm -f /etc/apt/sources.list.d/jenkins.list",

      "sudo rm -f /usr/share/keyrings/jenkins-keyring.asc",

      "sudo mkdir -p /etc/apt/keyrings",

      "sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key",

      "echo \"deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",

      "sudo apt-get update -y",

      "sudo apt-cache policy jenkins",

      "sudo apt-get install -y jenkins",


      # ------------------------------------------------------
      # JENKINS SERVICE
      # ------------------------------------------------------

      "sudo systemctl daemon-reload",

      "sudo systemctl enable jenkins",

      "sudo systemctl start jenkins",

      "sudo systemctl is-active jenkins",


      # ------------------------------------------------------
      # JENKINS + DOCKER
      # ------------------------------------------------------

      "sudo usermod -aG docker jenkins",

      "sudo systemctl restart jenkins",


      # ------------------------------------------------------
      # MAVEN
      # ------------------------------------------------------

      "sudo apt-get install -y maven",

      "mvn -version",


      # ------------------------------------------------------
      # FINAL VERIFICATION
      # ------------------------------------------------------

      "echo '===== JAVA ====='",

      "java -version",

      "echo '===== DOCKER ====='",

      "docker --version",

      "echo '===== DOCKER COMPOSE ====='",

      "docker compose version",

      "echo '===== JENKINS ====='",

      "sudo systemctl status jenkins --no-pager",

      "echo '===== MAVEN ====='",

      "mvn -version",

      "echo '===== TRIVY ====='",

      "trivy --version",

      "echo '===== KUBECTL ====='",

      "kubectl version --client",

      "echo '===== HELM ====='",

      "helm version",

      "echo '===== ARGOCD ====='",

      "argocd version --client",

      "echo '===== SONARQUBE CONTAINER ====='",

      "sudo docker ps --filter name=sonarqube",

      # ------------------------------------------------------
      # CONNECTION INFORMATION
      # ------------------------------------------------------

      "IP=$(curl -4 -s https://checkip.amazonaws.com)",

      "echo '============================================'",

      "echo \"Jenkins URL  : http://$IP:8080\"",

      "echo \"SonarQube URL: http://$IP:9000\"",

      "echo '============================================'",

      "echo 'Jenkins Initial Password:'",

      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword || true",

      "echo '============================================'"
    ]
  }
}


# ============================================================
# STEP 3: SSH ACCESS
# ============================================================

output "SERVER-SSH-ACCESS" {
  value = "ubuntu@${aws_instance.my-ec2.public_ip}"
}


# ============================================================
# STEP 4: PUBLIC IP
# ============================================================

output "PUBLIC-IP" {
  value = aws_instance.my-ec2.public_ip
}


# ============================================================
# STEP 5: PRIVATE IP
# ============================================================

output "PRIVATE-IP" {
  value = aws_instance.my-ec2.private_ip
}