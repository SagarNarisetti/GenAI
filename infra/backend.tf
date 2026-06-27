terraform {
  backend "s3" {
    bucket       = "sagar-mleng-tfstate-backup-bucket"
    key          = "prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}