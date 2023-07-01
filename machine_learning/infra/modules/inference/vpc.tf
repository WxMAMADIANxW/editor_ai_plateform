resource "aws_vpc" "aws-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_vpc_endpoint" "aws-vpc-endpoint" {
  vpc_id          = aws_vpc.aws-vpc.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.public.id]
}