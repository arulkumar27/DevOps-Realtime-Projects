# BlackTunes Multi-Region Disaster Recovery Architecture

```mermaid
flowchart TB
    Users["BlackTunes Users"] --> DNS["Route 53 Failover DNS<br/>dr.blacktunes.in"]

    DNS -->|"Primary healthy"| PALB["Primary ALB<br/>Mumbai"]
    DNS -.->|"Primary unhealthy"| DALB["DR ALB<br/>Hyderabad"]

    subgraph Primary["Primary Region — ap-south-1"]
        PALB --> PASG["Auto Scaling Group"]
        PASG --> PEC2["BlackTunes EC2<br/>Nginx + Gunicorn + Flask"]
        PEC2 --> RDS["RDS MySQL"]
        CW["CloudWatch Alarms"] --> PALB
        AC["Ansible Controller"] --> PEC2
        S3P["Primary S3 Bucket"]
        BV1["AWS Backup Vault"]
        RDS --> BV1
    end

    subgraph DR["Disaster Recovery Region — ap-south-2"]
        DALB --> DASG["DR Auto Scaling Group"]
        DASG --> DEC2["BlackTunes DR EC2<br/>Nginx + Gunicorn + Flask"]
        S3D["Replica S3 Bucket"]
        BV2["DR Backup Vault"]
    end

    S3P -->|"Cross-Region Replication"| S3D
    BV1 -->|"Cross-Region Backup Copy"| BV2
    AC -->|"Ansible over SSH"| DEC2