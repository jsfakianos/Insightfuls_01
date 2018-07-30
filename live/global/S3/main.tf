provider "aws" {  region = "us-west-2"}

resource "aws_s3_bucket" "terraform_state" {  bucket = "mura-radiographies-west-2"  versioning {    enabled = true  }  lifecycle {    prevent_destroy = true  }}


