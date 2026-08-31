# tech-challenge-infra-db

Infraestrutura como código (Terraform) do banco de dados gerenciado do **Tech Challenge — Fase 3**.

## Propósito

Provisiona uma instância Amazon RDS PostgreSQL para a aplicação principal, com:

- geração de senha aleatória (`random_password`)
- armazenamento de credenciais no AWS Secrets Manager
- subnet group para subnets privadas
- security group liberando acesso apenas para o SG do EKS (porta 5432)
- parameter group com ajustes de log

Este repositório **não** contém migrations nem código da aplicação.

## Tecnologias

- Terraform (required_version `>= 1.5`)
- Providers: `hashicorp/aws` (`~> 5.0`) e `hashicorp/random` (`~> 3.6`)
- Amazon RDS for PostgreSQL
- AWS Secrets Manager
- GitHub Actions

## Arquitetura deste repositório

```
                 ┌───────────────────────┐
                 │   VPC (do EKS)        │
                 │                       │
                 │  ┌─────────────────┐  │
   App (EKS) ───────▶  RDS Postgres   │  │
                 │  └─────────────────┘  │
                 │       ▲               │
                 │  Security Group       │
                 │  (libera só o SG do   │
                 │   EKS na porta 5432)  │
                 └───────────────────────┘

   Credenciais geradas e armazenadas no AWS Secrets Manager
```

## Pré-requisitos

- VPC e subnets privadas já existentes
- Security Group do EKS (ou dos nodes/pods que acessam o banco)
- Bucket S3 para backend remoto do Terraform
- Credenciais AWS com permissão para RDS, Security Group, Subnet Group e Secrets Manager

## Execução local

```bash
# 1) Criar arquivo de variáveis
cp terraform.tfvars.example terraform.tfvars
# No Windows PowerShell, alternativa:
# Copy-Item terraform.tfvars.example terraform.tfvars

# Preencher no terraform.tfvars (obrigatórias):
# - vpc_id = "vpc-..."
# - private_subnet_ids = ["subnet-...","subnet-..."]
# - eks_security_group_id = "sg-..."
# As demais variáveis já têm default em variables.tf

# 2) Inicializar backend e providers
terraform init -backend-config="bucket=<NOME_DO_BUCKET>"

# 3) Qualidade e plano
terraform fmt -check -recursive
terraform validate
terraform plan

# 4) Aplicar
terraform apply
```

## CI/CD (GitHub Actions)

Workflow: `.github/workflows/terraform.yml`

- **Pull Request para `main`**: executa `terraform fmt -check`, `terraform validate` e `terraform plan`
- **Push/Merge em `main`**: executa `terraform apply -auto-approve`

### Secrets necessários no GitHub Actions

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS |
| `AWS_SESSION_TOKEN` | Token de sessão AWS (quando aplicável) |
| `TF_BACKEND_BUCKET` | Nome do bucket S3 do backend Terraform |
| `VPC_ID` | VPC onde o RDS será criado |
| `PRIVATE_SUBNET_IDS` | Lista de subnets privadas no formato Terraform (ex.: `["subnet-a","subnet-b"]`) |
| `EKS_SECURITY_GROUP_ID` | Security Group do EKS autorizado no banco |

## Destruição da infraestrutura

```bash
terraform destroy
```

## Outputs para consumo por outros repositórios

- `db_endpoint` — endpoint completo (host:port)
- `db_address` — host do banco
- `db_port` — porta do banco
- `db_name` — nome do banco
- `db_security_group_id` — SG criado para o banco
- `secrets_manager_secret_arn` — ARN do secret com credenciais

## Observação

Este repositório não expõe API. Portanto, Swagger/Postman não se aplicam aqui.
