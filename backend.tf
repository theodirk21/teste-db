# --------------------------------------------------------------------------
# State remoto no S3, com lock via DynamoDB. Como cada repo do Tech Challenge
# roda terraform apply de forma independente, o state NÃO pode ficar local
# nem ser commitado no Git.
#
# Pré-requisito (criar uma vez, manualmente ou em um repo de infra base):
#   - Bucket S3 para guardar o state
#   - Tabela DynamoDB para o lock (chave de partição: LockID, tipo String)
# --------------------------------------------------------------------------
terraform {
  backend "s3" {
    key            = "infra-db/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile =   true
  }
}
