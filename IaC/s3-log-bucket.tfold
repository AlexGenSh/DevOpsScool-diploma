resource "aws_s3_bucket" "devops-school-diploma-s3-bucket-for-logs" {

  bucket = "devops-school-diploma-s3-bucket-for-logs"
  #  acl   = "log-delivery-write"   # or can be "public-read"
  tags = {
    Name        = "private"
    Environment = "Prod"
  }
  force_destroy = true
}