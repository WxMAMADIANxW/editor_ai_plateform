resource "aws_sqs_queue" "s3-event-queue" {
  name   = "s3-event-queue"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "sqspolicy",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": "arn:aws:sqs:*:*:s3-event-queue",
        "Condition": {
          "ArnEquals": { "aws:SourceArn": "${var.s3_bucket_arn}" }
        }
      }
    ]
  }
  POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_id

  queue {
    queue_arn = aws_sqs_queue.s3-event-queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}