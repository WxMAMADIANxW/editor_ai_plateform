################ S3 ################

# Create the S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

# Create the S3 Bucket Policy
resource "aws_s3_bucket_public_access_block" "s3_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  block_public_acls   = false
  block_public_policy = false
}