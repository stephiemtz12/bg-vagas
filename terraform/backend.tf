terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-backend-v2"
    dynamodb_table = "terraform-lock-state"
    region         = "us-east-2"
    key            = "asg/blue-green/vagas/terraform.tfstate"
    profile        = "jailson"
  }
}
