output "redis_host" {
  value = aws_memorydb_cluster.redis_cluster.cluster_endpoint.0.address
}

output "redis_port" {
  value = aws_memorydb_cluster.redis_cluster.port
}

output "redis_username" {
  value = aws_memorydb_user.default_user.user_name
}