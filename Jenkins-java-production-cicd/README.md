# Advanced Jenkins CI/CD Project: Java + Maven + Docker + AWS EC2

This repository is a complete production-style learning project. A Git push
triggers Jenkins, Maven compiles and tests the Spring Boot application, Docker
creates an immutable image, Trivy scans it, and a blue/green script deploys the
healthy version behind Nginx. If the new version fails its health check, the
currently running version is left untouched.

The project uses Spring Boot 3.5.x with Java 21 so that learners get a modern
Spring application while staying on the established Spring Boot 3 generation.

## Architecture

```text
Developer -> GitHub -> Jenkins -> Maven tests -> Docker build -> Trivy scan
                                                       |
                                                       v
Browser -> EC2 Security Group -> Nginx :80 -> Blue :8081 or Green :8082
```

## Repository structure

```text
.
├── src/                         Spring Boot application and tests
├── deploy/nginx/                Nginx reverse-proxy configuration
├── deploy/scripts/              Blue/green deployment and rollback
├── scripts/                     EC2 installation and configuration
├── Dockerfile                   Multi-stage non-root container
├── Jenkinsfile                  Complete declarative pipeline
└── pom.xml                      Maven dependencies and JaCoCo
```

## 1. Create the AWS EC2 server

Use:

- Ubuntu Server 24.04 LTS
- `t3.small` minimum for the lab
- 20 GB gp3 EBS
- Elastic IP recommended
- Security group inbound: SSH 22 from **My IP**, HTTP 80 from anywhere, and
  TCP 8080 from **My IP only** while configuring Jenkins
- Never open Docker ports 8081/8082 publicly

Connect:

```bash
chmod 400 jenkins-key.pem
ssh -i jenkins-key.pem ubuntu@EC2_PUBLIC_IP
```

## 2. Put this repository in GitHub

Create an empty GitHub repository named `jenkins-java-production-cicd`, then:

```bash
git init
git add .
git commit -m "Initial production CI/CD project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/jenkins-java-production-cicd.git
git push -u origin main
```

## 3. Install Jenkins, Java, Maven, Docker, Nginx and Trivy

On EC2:

```bash
git clone https://github.com/YOUR_USERNAME/jenkins-java-production-cicd.git
cd jenkins-java-production-cicd
chmod +x scripts/*.sh deploy/scripts/*.sh
./scripts/install-jenkins-docker.sh
sudo reboot
```

Reconnect after reboot:

```bash
cd jenkins-java-production-cicd
./scripts/configure-server.sh
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Open `http://EC2_PUBLIC_IP:8080`, paste the password, install suggested plugins,
and create the admin user.

## 4. Required Jenkins plugins

Go to **Manage Jenkins -> Plugins** and ensure these are installed:

- Pipeline
- Git
- GitHub
- JUnit
- Workspace Cleanup

Restart Jenkins only if Jenkins asks you to.

## 5. Create the Jenkins pipeline

1. Select **New Item**.
2. Name: `product-service-cicd`.
3. Select **Multibranch Pipeline**.
4. Under Branch Sources, select **GitHub**.
5. Add your repository URL.
6. For a public repository, credentials are not required.
7. Build Configuration: **by Jenkinsfile**.
8. Script Path: `Jenkinsfile`.
9. Save and select **Scan Multibranch Pipeline Now**.

The `main` branch performs CI and deployment. Other branches perform CI only.

## 6. Configure the GitHub webhook

In GitHub repository:

1. **Settings -> Webhooks -> Add webhook**
2. Payload URL: `http://EC2_PUBLIC_IP:8080/github-webhook/`
3. Content type: `application/json`
4. Select **Just the push event**
5. Active: enabled

For serious production, place Jenkins behind HTTPS and do not expose port 8080
directly to the internet.

## 7. Run and verify

In Jenkins, run **Build Now** for `main`. Expected stages:

1. Checkout
2. Build and Unit Test
3. Package
4. Build Docker Image
5. Security Scan
6. Deploy Blue/Green
7. Smoke Test

Open:

```text
http://EC2_PUBLIC_IP/api/products
http://EC2_PUBLIC_IP/api/info
http://EC2_PUBLIC_IP/actuator/health
```

Useful EC2 checks:

```bash
sudo systemctl status jenkins --no-pager
sudo systemctl status docker --no-pager
sudo systemctl status nginx --no-pager
docker ps
docker logs product-service-blue
docker logs product-service-green
curl http://localhost/actuator/health
df -h
free -h
```

## 8. Test automatic CI/CD

Edit the initial product in `ProductController.java`, then:

```bash
git add .
git commit -m "Update product catalogue"
git push origin main
```

GitHub sends the webhook. Jenkins automatically tests, scans and deploys the
new version. Refresh `/api/products` after the pipeline succeeds.

## 9. Understand the rollback

Suppose blue is live on port 8081. The next build starts green on port 8082.
The script tests green directly. Only after green reports `UP` does Nginx switch
traffic to it. If green is unhealthy, it is removed and blue stays live.

To deliberately test failure, temporarily change the Dockerfile health-check
URL to `/wrong-health-url`, commit, and push. The deployment stage should fail
without replacing the healthy live application. Restore the correct URL and
push again.

## 10. Common errors

### Jenkins remains offline

```bash
df -h
df -h /tmp
free -h
sudo journalctl -u jenkins -n 100 --no-pager
sudo systemctl restart jenkins
```

Low disk or memory is a frequent cause. Use 20 GB disk and `t3.small`.

### Docker permission denied

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
sudo systemctl restart docker
```

### No Jenkinsfile/script path

The file must be named exactly `Jenkinsfile` in the repository root. Jenkins
Script Path must be exactly `Jenkinsfile`.

### Nginx returns 502

```bash
docker ps
sudo nginx -t
sudo tail -n 100 /var/log/nginx/error.log
curl http://127.0.0.1:8081/actuator/health
curl http://127.0.0.1:8082/actuator/health
```

### Trivy blocks the pipeline

The project intentionally fails for unfixed HIGH or CRITICAL vulnerabilities.
Read the scan result, update the base image/dependency, rebuild, and verify.

## Production improvements after completing this lab

- Push images to Amazon ECR instead of storing them only on Jenkins EC2.
- Separate Jenkins and application servers.
- Use an Application Load Balancer and Auto Scaling Group.
- Store secrets in AWS Secrets Manager or Parameter Store.
- Add SonarQube quality gates.
- Use HTTPS with ACM and a domain.
- Export logs and metrics to CloudWatch, Prometheus and Grafana.
- Use IAM roles instead of long-lived AWS access keys.

## Security notes

- Do not commit AWS keys, passwords, PEM files or `.env` files.
- Restrict SSH and Jenkins access to your IP.
- Docker application ports bind to localhost only.
- The Jenkins sudo rule permits only commands required for Nginx switching.
- Delete the EC2 instance and Elastic IP after practice to avoid charges.
