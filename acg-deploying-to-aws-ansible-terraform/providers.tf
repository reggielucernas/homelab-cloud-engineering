provider "aws" {
  region = var.region-chief
  alias  = "region-chief"
}

provider "aws" {
  region = var.region-worker
  alias  = "region-worker"
}