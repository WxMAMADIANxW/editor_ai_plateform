resource "aws_elasticache_subnet_group" "group" {
  name       = local.elasticache_subnet_group_name
  subnet_ids = var.subnet_ids  # Replace with your subnet IDs
}

resource "aws_elasticache_cluster" "redis-cluster" {
  cluster_id               = local.elasticache_cluster_name
  engine                   = "redis"
  engine_version           = "6.x"
  node_type                = "cache.t2.micro"
  num_cache_nodes          = 1
  port                     = 6379
  subnet_group_name        = aws_elasticache_subnet_group.group.name
  parameter_group_name     = "default.redis6.x"
  maintenance_window       = "mon:03:00-mon:04:00"  # Maintenance window in UTC
  snapshot_retention_limit = 5
  snapshot_window          = "08:00-10:00"  # Snapshot window in UTC
}