module "preprocess" {
  source    = "./modules/preprocess"
  app_name  = var.app_name
  region    = var.region
  policy_s3 = var.policy_s3
}

module "inference" {
  source             = "./modules/inference"
  app_name           = var.app_name
  region             = var.region
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  sqs_queue_name     = module.queue.queue_name
  redis_host         = module.cache.redis_host
  redis_username     = module.cache.redis_username
  redis_password     = var.redis_password
}

module "queue" {
  source        = "./modules/queue"
  s3_bucket_arn = module.preprocess.s3_bucket_arn
  s3_bucket_id  = module.preprocess.s3_bucket_id
}

module "cache" {
  source            = "./modules/cache"
  app_name          = var.app_name
  subnet_ids        = module.inference.subnet_ids
  vpc_id            = module.inference.vpc_id
  security_group_id = module.inference.security_group_id
  redis_password    = var.redis_password
}

module "ingress" {
  source      = "./modules/ingress"
  app_name    = var.app_name
  region      = var.region
  bucket_name = module.preprocess.s3_raw_bucket_name
}