################ S3 ################

# Create the raw S3 Bucket
resource "aws_s3_bucket" "s3_bucket_raw" {
  bucket        = local.raw_bucket_name
  force_destroy = true
}

# Create the raw S3 Bucket Policy
resource "aws_s3_bucket_public_access_block" "s3_policy_raw" {
  bucket              = aws_s3_bucket.s3_bucket_raw.id
  block_public_acls   = false
  block_public_policy = false
}

#####################################

# Create the splitted S3 Bucket
resource "aws_s3_bucket" "s3_bucket_splitted" {
  bucket        = local.splitted_bucket_name
  force_destroy = true
}

# Create the splitted S3 Bucket Policy
resource "aws_s3_bucket_public_access_block" "s3_policy_splitted" {
  bucket              = aws_s3_bucket.s3_bucket_splitted.id
  block_public_acls   = false
  block_public_policy = false
}