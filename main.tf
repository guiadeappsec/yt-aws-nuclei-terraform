# aqui vamos definir as versões utilizadas no nosso terraform.
# este passo é importante para evitar incompatibilidades com versões futuras.
terraform {

    # vamos definir para que providers queremos criar
    # e quais "engines" vamos usar.
    # você pode ver o provider da AWS na documentação oficial aqui:
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.49"
        }
    }
    
    # aqui está a versão do terraform que estamos usando
    required_version = ">= 1.8.3"
}

# vamos definir as infos para nosso provider
provider "aws" {
    # qual profile vamos usar
    profile = "gdas-tf"

    # qual região vamos usar
    region  = "us-east-1"
}

# aqui vamos criar um bucket público
# aws_s3_bucket: tipo de recurso a ser criado
# public_bucket: nome do recurso
resource "aws_s3_bucket" "public_bucket" {
  # id unico do bucket
  bucket = "gdas-my-public-bucket-822412123123"

  # tags para identificar o bucket
  tags = {
    Name        = "Public S3 Bucket"
    Environment = "dev"
  }
}

# aqui vamos definir as regras de acesso ao bucket
# aws_s3_bucket_public_access_block: tipo de recurso a ser criado
# public_bucket: nome do recurso
resource "aws_s3_bucket_public_access_block" "public_bucket" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# aqui vamos definir a política de acesso ao bucket
# aws_s3_bucket_policy: tipo de recurso a ser criado
# public_bucket_policy: nome do recurso
resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicListGet"
        Effect = "Allow"
        Principal = "*" # permite acesso de qualquer origem
        Action = [
          "s3:ListBucket", # permite listar os objetos do bucket
          "s3:GetObject" # permite pegar os objetos do bucket
        ]
        Resource = [
          aws_s3_bucket.public_bucket.arn, # permite acesso ao bucket
          "${aws_s3_bucket.public_bucket.arn}/*" # permite acesso aos objetos do bucket   
        ]
      }
    ]
  })
}