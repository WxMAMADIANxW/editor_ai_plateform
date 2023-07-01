module "ingress" {
  source      = "./modules/ingress"
  app_name    = var.app_name
  region      = var.region
  bucket_name = module.preprocess.s3_raw_bucket_name
}

module "preprocess" {
  source    = "./modules/preprocess"
  app_name  = var.app_name
  region    = var.region
  policy_s3 = var.policy_s3
}

module "queue" {
  source        = "./modules/queue"
  s3_bucket_arn = module.preprocess.s3_bucket_arn
  s3_bucket_id  = module.preprocess.s3_bucket_id
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

module "cache" {
  source            = "./modules/cache"
  app_name          = var.app_name
  subnet_ids        = module.inference.subnet_ids
  vpc_id            = module.inference.vpc_id
  security_group_id = module.inference.security_group_id
  redis_password    = var.redis_password
}

module "postprocess" {
  source            = "./modules/postprocess"
  app_name          = var.app_name
  region            = var.region
  redis_host        = module.cache.redis_host
  redis_username    = module.cache.redis_username
  redis_password    = var.redis_password
  redis_port        = module.cache.redis_port
  input_bucket_name = module.preprocess.s3_splitted_bucket_name
  security_group_id = module.inference.security_group_id
  subnet_ids        = module.inference.subnet_ids
}

module "egress" {
  source      = "./modules/egress"
  app_name    = var.app_name
  region      = var.region
  bucket_name = module.postprocess.s3_bucket_name
}