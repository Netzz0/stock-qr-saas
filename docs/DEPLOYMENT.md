# 🚀 Déploiement - Stock QR SaaS

## Vue d'ensemble

Ce guide couvre le déploiement de Stock QR SaaS sur AWS (avec notes Azure).

## Architecture de Déploiement

```
User/Client
    |
    v
  CDN (CloudFront)
    |
    v
Load Balancer (ALB)
    |
    v
ECS Fargate Cluster (multi-AZ)
    |
    +---> API Containers (min 3)
    |
    +---> Worker Containers (Hangfire)
    |
    v
RDS PostgreSQL Multi-AZ
    |
    v
ElastiCache Redis
    |
    v
S3 / EBS Storage
```

## Pré-requis

- AWS account avec permissions admin
- CLI tools : AWS CLI, kubectl, terraform
- Docker & Docker Compose
- GitHub personal access token

## Phase 1 : Infrastructure (Terraform)

### 1.1 Setup

```bash
# Clone et setup
git clone https://github.com/Netzz0/stock-qr-saas.git
cd stock-qr-saas/infrastructure/terraform

# Configure AWS credentials
aws configure

# Initialize Terraform
terraform init
```

### 1.2 Configuration (terraform.tfvars)

```hcl
aws_region             = "eu-west-1"
environment            = "production"
project_name           = "stock-qr-saas"

# Database
db_engine_version      = "15.2"
db_instance_class      = "db.t3.small"
db_allocated_storage   = 100

# ECS
ecs_task_cpu           = "512"
ecs_task_memory        = "1024"
ecs_desired_count      = 3

# Storage
s3_bucket_name         = "stock-qr-saas-prod"

# Domain
domain_name            = "stock-qr-saas.example.com"
acme_email             = "admin@example.com"
```

### 1.3 Déployer l'infrastructure

```bash
# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Outputs
terraform output
```

Cela créera:
- VPC + Subnets (multi-AZ)
- Security Groups
- RDS PostgreSQL instance
- ElastiCache Redis cluster
- S3 buckets
- ALB + Target Groups
- ECS Cluster + Task Definitions

## Phase 2 : Docker Images

### 2.1 Build Images

```bash
# Backend
docker build -t stock-qr-api:latest ./backend

# Frontend
docker build -t stock-qr-frontend:latest ./frontend
```

### 2.2 Push to ECR

```bash
# Créer les repositories
aws ecr create-repository --repository-name stock-qr-api --region eu-west-1
aws ecr create-repository --repository-name stock-qr-frontend --region eu-west-1

# Login
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin 123456789.dkr.ecr.eu-west-1.amazonaws.com

# Tag et push
docker tag stock-qr-api:latest 123456789.dkr.ecr.eu-west-1.amazonaws.com/stock-qr-api:latest
docker push 123456789.dkr.ecr.eu-west-1.amazonaws.com/stock-qr-api:latest

docker tag stock-qr-frontend:latest 123456789.dkr.ecr.eu-west-1.amazonaws.com/stock-qr-frontend:latest
docker push 123456789.dkr.ecr.eu-west-1.amazonaws.com/stock-qr-frontend:latest
```

## Phase 3 : Kubernetes (EKS)

### 3.1 Setup EKS Cluster

```bash
# Créer le cluster
eksctl create cluster \
  --name stock-qr-prod \
  --region eu-west-1 \
  --nodes 3 \
  --node-type t3.medium

# Configurer kubectl
aws eks update-kubeconfig \
  --name stock-qr-prod \
  --region eu-west-1
```

### 3.2 Déployer les manifests

```bash
# Secrets
kubectl create secret generic stock-qr-secrets \
  --from-literal=jwt-secret=$(openssl rand -base64 32) \
  --from-literal=db-password=$(openssl rand -base64 16) \
  -n stock-qr

# ConfigMaps
kubectl create configmap stock-qr-config \
  --from-file=infrastructure/k8s/config/ \
  -n stock-qr

# Deployments
kubectl apply -f infrastructure/k8s/api-deployment.yaml
kubectl apply -f infrastructure/k8s/frontend-deployment.yaml
kubectl apply -f infrastructure/k8s/services.yaml
kubectl apply -f infrastructure/k8s/ingress.yaml
```

### 3.3 Verify Deployments

```bash
# Check pods
kubectl get pods -n stock-qr

# Check services
kubectl get svc -n stock-qr

# Check ingress
kubectl get ingress -n stock-qr

# View logs
kubectl logs -f deployment/stock-qr-api -n stock-qr
```

## Phase 4 : Database Migration

### 4.1 Connect to RDS

```bash
# Get RDS endpoint
RDS_ENDPOINT=$(aws rds describe-db-instances \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

# Connect
psql -h $RDS_ENDPOINT -U admin -d stock_qr_db
```

### 4.2 Run Migrations

```bash
# Via EF Core
dotnet ef database update \
  --connection "Host=$RDS_ENDPOINT;Username=admin;Password=***;Database=stock_qr_db"

# Via Flyway (alternative)
flyway -url=jdbc:postgresql://$RDS_ENDPOINT/stock_qr_db \
       -user=admin \
       -password=*** \
       migrate
```

## Phase 5 : CI/CD Setup

### 5.1 GitHub Actions

Déjà configuré dans `.github/workflows/`

```yaml
name: Deploy to EKS
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to EKS
        run: |
          aws eks update-kubeconfig --name stock-qr-prod
          kubectl set image deployment/stock-qr-api \
            api=ECR_URI:$GITHUB_SHA
          kubectl rollout status deployment/stock-qr-api
```

### 5.2 Configure Secrets

Ajouter à GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ECR_REGISTRY`
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

## Phase 6 : Monitoring & Logging

### 6.1 CloudWatch

```bash
# Create log groups
aws logs create-log-group --log-group-name /ecs/stock-qr-api
aws logs create-log-group --log-group-name /ecs/stock-qr-frontend

# Set retention
aws logs put-retention-policy \
  --log-group-name /ecs/stock-qr-api \
  --retention-in-days 30
```

### 6.2 Alarms

```bash
# High CPU
aws cloudwatch put-metric-alarm \
  --alarm-name stock-qr-high-cpu \
  --alarm-description "Alert when CPU > 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold
```

### 6.3 Prometheus & Grafana

```bash
# Deploy Prometheus
kubectl apply -f infrastructure/monitoring/prometheus.yaml

# Deploy Grafana
kubectl apply -f infrastructure/monitoring/grafana.yaml

# Access Grafana
kubectl port-forward svc/grafana 3000:80 -n monitoring
# http://localhost:3000 (admin/admin)
```

## Phase 7 : SSL/TLS Certificate

### 7.1 Let's Encrypt

```bash
# Install cert-manager
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace

# Create ClusterIssuer
kubectl apply -f infrastructure/k8s/cert-issuer.yaml

# Create Certificate
kubectl apply -f infrastructure/k8s/certificate.yaml
```

### 7.2 Auto-renewal

Cert-manager gère automatiquement le renouvellement (90 jours avant expiration).

## Phase 8 : Backup Strategy

### 8.1 RDS Automated Backups

```bash
aws rds modify-db-instance \
  --db-instance-identifier stock-qr-db \
  --backup-retention-period 30 \
  --preferred-backup-window "03:00-04:00"
```

### 8.2 Manual Backups

```bash
# Create snapshot
aws rds create-db-snapshot \
  --db-instance-identifier stock-qr-db \
  --db-snapshot-identifier stock-qr-db-$(date +%Y%m%d)

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier stock-qr-db-restored \
  --db-snapshot-identifier stock-qr-db-20251224
```

### 8.3 Cross-region Replication

```bash
# Create read replica in different region
aws rds create-db-instance-read-replica \
  --db-instance-identifier stock-qr-db-replica \
  --source-db-instance-identifier stock-qr-db \
  --availability-zone eu-west-2a
```

## Production Checklist

- [ ] Infrastructure testée et fonctionnelle
- [ ] Database migrée avec données test
- [ ] Secrets configurés de manière sécurisée
- [ ] SSL/TLS certificates installés
- [ ] Monitoring et alertes activés
- [ ] Backups automatisés et testés
- [ ] Disaster recovery plan documenté
- [ ] Security scan complet réalisé
- [ ] Load testing completé
- [ ] Runbook et escalation processes documentés
- [ ] Team formé et prêt
- [ ] Maintenance windows communiqués

## Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name> -n stock-qr
kubectl logs <pod-name> -n stock-qr
```

### Database connection issues

```bash
# Check security group
aws ec2 describe-security-groups --group-ids sg-xxx

# Test connection
psql -h $RDS_ENDPOINT -U admin -d stock_qr_db
```

### Memory/CPU issues

```bash
kubectl top nodes
kubectl top pods -n stock-qr

# Adjust resources in deployment.yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

## Rollback Procedure

```bash
# View rollout history
kubectl rollout history deployment/stock-qr-api -n stock-qr

# Rollback to previous version
kubectl rollout undo deployment/stock-qr-api -n stock-qr

# Rollback to specific revision
kubectl rollout undo deployment/stock-qr-api --to-revision=2 -n stock-qr
```

---

*For Azure deployment, see [DEPLOYMENT_AZURE.md](DEPLOYMENT_AZURE.md)*
