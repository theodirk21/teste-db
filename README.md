# tech-challenge-infra-db-1

Infraestrutura como código (Terraform) do banco de dados gerenciado do **Tech Challenge — Fase 3**.

## Propósito

Provisiona o banco de dados PostgreSQL gerenciado (Amazon RDS) usado pela aplicação principal do
Tech Challenge, incluindo rede (subnet group), segurança (security group) e credenciais
(Secrets Manager). Este repositório **não** contém migrations nem código de aplicação — isso
fica no repositório da app principal.

## Tecnologias

- Terraform >= 1.5
- AWS Provider (~> 5.0)
- Amazon RDS (PostgreSQL)
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

- Uma VPC já existente (a mesma usada pelo cluster EKS do Repo 3, ou uma com rota até ela)
- Bucket S3 + tabela DynamoDB para o backend remoto do Terraform (ver `backend.tf`)
- Credenciais AWS com permissão para criar RDS, Security Group, Subnet Group e Secrets Manager

## Passos para execução e deploy

### Local

```bash
# 1. Copiar e preencher as variáveis
cp terraform.tfvars.example terraform.tfvars

# 2. Inicializar
terraform init

# 3. Validar e planejar
terraform validate
terraform plan

# 4. Aplicar
terraform apply
```

### Via CI/CD

- Abrir um Pull Request para `main` → dispara `terraform plan` automaticamente
- Merge na `main` → dispara `terraform apply` automaticamente
- Branch `main` é protegida: sem commits diretos, PR obrigatório

### Secrets necessários no GitHub Actions

| Secret                     | Descrição                                   |
|----------------------------|----------------------------------------------|
| `AWS_ACCESS_KEY_ID`        | Credencial AWS                                |
| `AWS_SECRET_ACCESS_KEY`    | Credencial AWS                                |
| `VPC_ID`                   | VPC onde o RDS será criado                    |
| `PRIVATE_SUBNET_IDS`       | Subnets privadas (lista, formato Terraform)   |
| `EKS_SECURITY_GROUP_ID`    | Security Group do cluster EKS                 |

### Destruir a infraestrutura

Como o desafio exige apenas o ambiente de produção durante a gravação do vídeo de demonstração,
a infra pode ser derrubada depois:

```bash
terraform destroy
```

## Outputs relevantes para outros repositórios

- `db_endpoint` — endpoint (host:port) para a aplicação se conectar
- `db_name` — nome do banco
- `secrets_manager_secret_arn` — onde estão as credenciais completas

## Diagrama

Ver seção "Arquitetura deste repositório" acima. Para o diagrama de componentes completo da
solução (API Gateway, Lambda, EKS, RDS, observabilidade), ver a documentação de arquitetura no
repositório principal.

## Swagger / Postman

Não aplicável — este repositório não expõe APIs.
