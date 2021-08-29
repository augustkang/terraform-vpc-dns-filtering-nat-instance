output "s3_bucket_arn" {
  description = "s3 bucket arn"
  value       = aws_s3_bucket.bucket.arn
}