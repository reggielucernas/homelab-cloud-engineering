terraform {
    required_version = ">= 1.2.5"
    backend "s3" {
      region = "us-east-1"
      profile = "default"
      key = "terraform-state-file"
      bucket = "terraform-state-bucket-rl0804"
    }
}