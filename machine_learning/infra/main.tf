module "preprocess" {
  source                 = "./modules/preprocess"
  app_name               = var.app_name
  region                 = var.region
#  function_name_pipeline = var.function_name_pipeline
  s3_bucket_id           = var.s3_bucket_id
  policy_s3              = var.policy_s3
}

#module "inference" {
#  source   = "./modules/inference"
#  app_name = var.app_name
#  region   = var.region
#}

module "queue" {
  source   = "./modules/queue"
#  app_name = var.app_name
  s3_bucket_arn = module.preprocess.s3_bucket_arn
  s3_bucket_id = module.preprocess.s3_bucket_id
}