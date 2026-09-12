# 🚀 Project-04-AWS-EKS-End-to-End-DevSecOps

## 📌 Project Overview

This project implements an end-to-end **DevSecOps CI/CD platform on AWS** for deploying a containerized web application on **Amazon EKS**.

The project covers the complete application delivery lifecycle:

**GitHub → Jenkins → SonarQube → Trivy → Docker → Amazon ECR → Amazon EKS → Argo CD → Prometheus → Grafana**

The main goal is to automate application delivery while integrating **code quality, security, containerization, Kubernetes deployment, GitOps, and monitoring**.

---

## 🏗️ Architecture

```text
                         Developer
                             │
                             ▼
                         GitHub
                             │
                             ▼
                      ┌──────────────┐
                      │   Jenkins    │
                      │  CI Pipeline │
                      └──────┬───────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
         SonarQube         Trivy         NPM Build
        Code Quality      Security       Application
              │              │              │
              └──────────────┼──────────────┘
                             ▼
                       Docker Build
                             │
                             ▼
                         Amazon ECR
                             │
                             ▼
                         Amazon EKS
                             │
                             ▼
                         Argo CD
                             │
                             ▼
                       Kubernetes
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
               Prometheus          Grafana