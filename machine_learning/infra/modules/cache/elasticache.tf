resource "aws_memorydb_acl" "memorydb_acl" {
  name       = "${var.app_name}-redis-acl-cluster"
  user_names = [aws_memorydb_user.default_user.user_name]
}

resource "aws_memorydb_subnet_group" "redis_subnet_group" {
  name       = "${var.app_name}-redis-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_memorydb_cluster" "redis_cluster" {
  name               = "${var.app_name}-redis-cluster"
  num_shards         = 1
  subnet_group_name  = aws_memorydb_subnet_group.redis_subnet_group.name
  acl_name           = aws_memorydb_acl.memorydb_acl.name
  node_type          = "db.t4g.small"
  security_group_ids = [var.security_group_id]
}

resource "aws_memorydb_user" "default_user" {
  user_name     = "reda-user"
  access_string = "on ~* &* +@all"

  authentication_mode {
    type      = "password"
    passwords = [var.redis_password]
  }
}