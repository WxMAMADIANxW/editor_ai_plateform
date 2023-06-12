module "preprocess" {
  source = "./modules/preprocess"
  bucket_name = var.bucket_name
  region = var.region
  ecr_repository_name = var.ecr_repository_name
  function_name_pipeline = var.function_name_pipeline
  lambda_role_name = var.lambda_role_name
  s3_bucket_id = var.s3_bucket_id
  lambda_iam_policy_name_pipeline = var.lambda_iam_policy_name_pipeline
  policy_s3 = var.policy_s3
}