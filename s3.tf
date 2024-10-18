resource "aws_s3_bucket" "thumbnail_original_image_bucket" {
  bucket = "cp-origin-image-bucket"
}

resource "aws_s3_bucket" "thumbnail_image_bucket" {
  bucket = "cp-thumb-nail-image-bucket"
}
