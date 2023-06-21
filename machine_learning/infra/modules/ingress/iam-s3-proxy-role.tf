resource "aws_iam_role" "s3_proxy_role" {
  name               = "${var.app_name}-s3-proxy-role-ingress"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.s3_proxy_policy.json
}

data "aws_iam_policy_document" "s3_proxy_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "s3_proxy_role_file_upload_attachment" {
  depends_on = [
    "aws_iam_policy.s3_file_upload_policy",
  ]

  role       = aws_iam_role.s3_proxy_role.name
  policy_arn = aws_iam_policy.s3_file_upload_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_proxy_role_api_gateway_attachment" {
  depends_on = [
    "aws_iam_policy.s3_file_upload_policy",
  ]

  role       = aws_iam_role.s3_proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}
#
#resource "aws_s3_bucket" "file_upload_bucket" {
#  bucket = "file-upload-bucket-${var.environment}"
#  acl    = "private"
#
#  tags {
#    Name        = "file-upload-bucket-${var.environment}"
#    Environment = var.environment
#  }
#
#  depends_on = [
#    "aws_iam_policy.s3_file_upload_policy",
#  ]
#}

################ S3 ################

# Create the raw S3 Bucket
resource "aws_s3_bucket" "s3_bucket_raw" {
  bucket        = local.raw_bucket_name
  force_destroy = true

  depends_on = [
    aws_iam_policy.s3_file_upload_policy,
  ]
}

# Create the raw S3 Bucket Policy
resource "aws_s3_bucket_public_access_block" "s3_policy_raw" {
  bucket              = aws_s3_bucket.s3_bucket_raw.id
  block_public_acls   = false
  block_public_policy = false
}

resource "aws_iam_policy" "s3_file_upload_policy" {
  name        = "${var.app_name}-ingress-s3-file-upload-policy"
  path        = "/"
  description = "${var.app_name} raw s3 bucket file upload policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.raw_bucket_name}/*"
            ]
    }
  ]
}
EOF
}