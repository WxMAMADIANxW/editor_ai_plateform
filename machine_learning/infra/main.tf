module "preprocess" {
  source    = "./modules/preprocess"
  app_name  = var.app_name
  region    = var.region
  #s3_bucket_id           = var.s3_bucket_id
  policy_s3 = var.policy_s3
}

module "inference" {
  source             = "./modules/inference"
  app_name           = var.app_name
  region             = var.region
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

module "queue" {
  source        = "./modules/queue"
#  app_name      = var.app_name
  s3_bucket_arn = module.preprocess.s3_bucket_arn
  s3_bucket_id  = module.preprocess.s3_bucket_id
}

#module "cache" {
#  source = "./modules/cache"
#  app_name = var.app_name
#  subnet_id = module.inference.subnet_id
#  vpc_id = module.inference.vpc_id
#}