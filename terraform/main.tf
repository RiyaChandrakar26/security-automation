resource "aws_s3_bucket" "tf_state" {
  bucket = "riya-security-automation-tfstate"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Project"
  }
}