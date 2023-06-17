output "subnet_id" {
  value = aws_subnet.pub_subnet.id
}

output "vpc_id" {
  value = aws_vpc.aws-vpc.id
}