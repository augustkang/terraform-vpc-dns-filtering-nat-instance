resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true

}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "bucket-policy"
    Statement = [
      {
        Sid       = "vpc-endpoint-allow"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:*"]
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = "${var.vpc_endpoint_id}"
          }
        }
      },
    ]
  })
}