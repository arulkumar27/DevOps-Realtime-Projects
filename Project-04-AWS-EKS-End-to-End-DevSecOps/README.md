# Project-04 — AWS EKS End-to-End DevSecOps

> Production-style DevSecOps deployment using Terraform, Jenkins, Docker, Amazon ECR, Amazon EKS, Kubernetes, Argo CD, Prometheus and Grafana.

## Project Overview

This project demonstrates an end-to-end workflow for deploying a containerized web application on Amazon EKS.

```text
GitHub
  │
  ▼
Jenkins CI
  ├── Git Checkout
  ├── SonarQube Analysis
  ├── Quality Gate
  ├── npm Install
  ├── Trivy Security Scan
  ├── Docker Build
  ├── Amazon ECR
  └── Image Cleanup
  │
  ▼
Amazon EKS
  │
  ▼
Argo CD
  │
  ▼
Kubernetes Application
  │
  ▼
AWS LoadBalancer
  │
  ▼
Live Application

Monitoring: Prometheus + Grafana
Infrastructure: Terraform
```

## Architecture

### AWS

- Amazon VPC
- Public and private subnets
- Amazon EKS
- EKS managed node group
- IAM
- Amazon ECR
- AWS LoadBalancer integration
- AWS VPC CNI

### Kubernetes

- Deployment
- ReplicaSet
- Pod
- Service
- Argo CD
- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- Node Exporter
- CoreDNS
- kube-proxy

## DevSecOps CI Pipeline

| Stage | Purpose |
|---|---|
| Git Checkout | Retrieves source from GitHub |
| SonarQube Analysis | Static code quality analysis |
| Quality Gate | Validates code quality |
| npm Install | Installs application dependencies |
| Trivy Scan | Security scanning |
| Docker Build | Creates container image |
| Create ECR Repo | Creates ECR repository when required |
| Login & Tag | Authenticates and tags the image |
| Push Image to ECR | Publishes the image |
| Cleanup | Removes temporary local images |

```text
Source Code
    │
    ▼
 Jenkins
    │
    ├── SonarQube
    ├── Quality Gate
    ├── Trivy
    └── Docker Build
            │
            ▼
        Amazon ECR
```

## Infrastructure as Code

Terraform provisions the AWS infrastructure.

```text
terraform_code/
├── eks_code/
│   ├── eks.tf
│   ├── provider.tf
│   └── vpc.tf
│
└── ec2_server/
    ├── main.tf
    ├── setup.sh
    └── variables.tf
```

Terraform is used for repeatable infrastructure provisioning and cleanup.

## Amazon EKS

The application runs on an Amazon EKS cluster with multiple worker nodes.

```text
Amazon EKS
├── Worker Node 1
│   └── Kubernetes workloads
└── Worker Node 2
    └── Kubernetes workloads
```

The Kubernetes application is exposed through a `LoadBalancer` Service.

```text
AWS LoadBalancer
       │
       ▼
Kubernetes Service
       │
       ▼
Application Pod
       │
       ▼
Container :3000
```

## Kubernetes

Kubernetes manifests are stored in:

```text
k8s_files/
├── deployment.yaml
└── service.yaml
```

The Deployment manages the application Pods, while the Service provides stable access to the workload.

## GitOps with Argo CD

Argo CD manages the desired Kubernetes application state from Git.

```text
GitHub Repository
       │
       ▼
    Argo CD
       │
       ▼
    Amazon EKS
       │
       ▼
Kubernetes Resources
```

The completed deployment demonstrates:

- Healthy application
- Synced application
- Successful synchronization
- Deployment → ReplicaSet → Pod relationship

## Monitoring

The project includes a Kubernetes monitoring stack:

- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- Node Exporter

```text
Kubernetes
    │
    ├── Node Exporter
    ├── kube-state-metrics
    │
    ▼
 Prometheus
    │
    ▼
 Grafana
```

## Containerization

```text
Application Source
       │
       ▼
    Dockerfile
       │
       ▼
   Docker Image
       │
       ▼
    Amazon ECR
       │
       ▼
    Amazon EKS
```

Images are tagged with the Jenkins build number and `latest`.

## Security

Security is integrated into the CI workflow through:

- SonarQube static analysis
- SonarQube Quality Gate
- Trivy security scanning
- Amazon ECR image management
- AWS IAM
- Kubernetes access controls
- Terraform-managed infrastructure
- `.gitignore` protection for keys, state and runtime files

## Project Structure

```text
Project-04-AWS-EKS-End-to-End-DevSecOps/
├── docs/
│   └── screenshots/
│       ├── Argo CD – Application Healthy & Synced.png
│       ├── AWS EKS Cluster – Kubernetes Workloads.png
│       ├── Jenkins CI Pipeline – Build, Security & ECR.png
│       └── Live Application – EKS Deployment.png
├── k8s_files/
│   ├── deployment.yaml
│   └── service.yaml
├── pipeline_script/
│   ├── build_pipeline
│   ├── cleanup_pipeline
│   ├── deployment_eks
│   └── deployment_pipeline
├── public/
├── src/
├── terraform_code/
├── .gitignore
├── access.sh
├── Dockerfile
├── package.json
├── package-lock.json
├── Project_WriteUp.docx
└── README.md
```

## Project Screenshots

### 1. Jenkins CI Pipeline — Build, Security Scan & ECR Push

![Jenkins CI Pipeline](docs/screenshots/Jenkins%20CI%20Pipeline%20%E2%80%93%20Build%2C%20Security%20%26%20ECR.png)

### 2. AWS EKS Cluster — Kubernetes Workloads

![AWS EKS Cluster](docs/screenshots/AWS%20EKS%20Cluster%20%E2%80%93%20Kubernetes%20Workloads.png)

### 3. Argo CD — Application Healthy & Synced

![Argo CD](docs/screenshots/Argo%20CD%20%E2%80%93%20Application%20Healthy%20%26%20Synced.png)

### 4. Live Application — EKS Deployment

![Live Application](docs/screenshots/Live%20Application%20%E2%80%93%20EKS%20Deployment.png)

## Deployment Flow

```text
Developer
   │
   ▼
 GitHub
   │
   ▼
Jenkins CI
   │
   ├── SonarQube
   ├── Quality Gate
   ├── Trivy
   └── Docker
          │
          ▼
      Amazon ECR
          │
          ▼
      Amazon EKS
          │
      ┌───┴────┐
      ▼        ▼
   Argo CD  Kubernetes
               │
               ▼
        AWS LoadBalancer
               │
               ▼
        Live Application

Prometheus ──► Grafana
```

## Troubleshooting Experience

During implementation, Kubernetes and Helm issues were investigated using:

```text
kubectl get nodes
kubectl get pods -A
kubectl describe pod
kubectl get events
helm status
kubectl describe svc
kubectl get endpoints
```

A worker-node Pod-capacity scheduling issue was identified during the monitoring-stack deployment. Increasing worker-node capacity allowed the required workloads to be scheduled successfully.

This demonstrates practical troubleshooting across AWS, Kubernetes, Helm, Pods and Services.

## Cleanup

Destroy each independent Terraform state from its corresponding directory:

```bash
terraform destroy
```

Also verify Kubernetes/Helm-created AWS resources such as LoadBalancers and other externally created resources before considering the environment fully cleaned up.

## Skills Demonstrated

**AWS:** EC2, VPC, IAM, EKS, ECR, LoadBalancer

**DevOps:** Git, GitHub, Jenkins, Docker, Terraform

**Kubernetes:** Deployment, Service, Pods, ReplicaSet, EKS

**DevSecOps:** SonarQube, Quality Gate, Trivy, IAM, secure secret handling

**Monitoring:** Prometheus, Grafana, Alertmanager, Node Exporter, kube-state-metrics

**GitOps:** Argo CD

## Interview Summary

> I built an end-to-end AWS EKS DevSecOps project where Terraform provisions the infrastructure, Jenkins performs CI with SonarQube and Trivy security checks, Docker builds and publishes images to Amazon ECR, and the application runs on Amazon EKS. Argo CD provides GitOps-based Kubernetes synchronization, while Prometheus and Grafana provide monitoring and observability. I also troubleshot real Kubernetes scheduling and Helm deployment issues during implementation.

## Repository

GitHub: https://github.com/arulkumar27/DevOps-Realtime-Projects

Project: `Project-04-AWS-EKS-End-to-End-DevSecOps`

---

**Build. Automate. Secure. Deploy. Observe.**