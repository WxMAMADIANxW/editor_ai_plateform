output "s3_bucket_id" {
  value = aws_s3_bucket.s3_bucket_splitted.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.s3_bucket_splitted.arn
}

output "s3_raw_bucket_name" {
  value = aws_s3_bucket.s3_bucket_raw.bucket
}

output "s3_splitted_bucket_name" {
  value = aws_s3_bucket.s3_bucket_splitted.bucket
}