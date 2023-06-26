################ S3 ################

# Create the final S3 Bucket
resource "aws_s3_bucket" "s3_bucket_final" {
  bucket        = local.final_bucket_name
  force_destroy = true
}

# Create the final S3 Bucket Policy
resource "aws_s3_bucket_public_access_block" "s3_policy_raw" {
  bucket              = aws_s3_bucket.s3_bucket_final.id
  block_public_acls   = false
  block_public_policy = false
}