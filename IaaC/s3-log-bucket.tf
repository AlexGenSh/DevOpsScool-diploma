resource "aws_s3_bucket" "s3-bucket-for-logs" {

  bucket = "s3-bucket-for-logs"
  acl   = "public-read"   # or can be "private"
  tags = {
    Name        = "public-read"
    Environment = "Prod"
  }
  force_destroy = true
}