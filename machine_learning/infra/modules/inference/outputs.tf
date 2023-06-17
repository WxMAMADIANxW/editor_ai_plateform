output "subnet_id" {
  value = aws_subnet.public.*.id
}

output "vpc_id" {
  value = aws_vpc.aws-vpc.id
}