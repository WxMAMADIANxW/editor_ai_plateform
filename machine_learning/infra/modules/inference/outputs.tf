output "subnet_ids" {
  value = aws_subnet.public.*.id
}

output "vpc_id" {
  value = aws_vpc.aws-vpc.id
}

output "security_group_id" {
  value = aws_security_group.service_security_group.id
}