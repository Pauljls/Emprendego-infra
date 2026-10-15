terraform {
  backend "s3" {
    bucket       = "emprendego-tfstate-590183982101"
    key          = "prod/terraform.tfstate"
    region       = "sa-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
