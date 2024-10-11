resource "aws_s3_bucket" "s3" {
  bucket = "Event-driven-bucket"

  tags = {
    Name        = "Event driven bucket"
  }
}

