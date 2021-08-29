output "proxy_instances" {
  description = "private subnet ids"
  value       = aws_instance.proxy_instance.*.id
}