# Clean Code .NET DevOps Pipeline

This repository contains a full-stack DevOps implementation of a .NET 8 Web API, featuring automated infrastructure provisioning and a modern deployment pipeline.

## 🚀 Project Architecture
- **API:** .NET 8 Web API (Clean Architecture).
- **IaC:** Terraform (Azure RM Provider).
- **Cloud:** Azure Web Apps (B1 Tier) & Azure SQL (Serverless).

## 🛠 Infrastructure Setup
The infrastructure is managed via Terraform in the `/infra` directory.

### Prerequisites
1. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2. [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)

### Deployment Steps
1. Navigate to the infrastructure folder: `cd infra`
2. Authenticate with Azure: `az login`
3. Initialize Terraform: `terraform init`
4. Deploy: `terraform apply`

## 📈 Roadmap
- [x] Sprint 1: .NET 8 API Development
- [x] Sprint 2: Infrastructure as Code (Azure + Terraform)
- [ ] Sprint 3: Containerization (Docker)
- [ ] Sprint 4: CI/CD Pipeline (GitHub Actions)