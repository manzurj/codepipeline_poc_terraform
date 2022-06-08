output "s3_state_bucket_name" {
  value       = aws_s3_bucket.tfbootstrap.id
  description = "tfstate Bucket name"
}

output "dynamodb_state_lock_table_name" {
  value       = aws_dynamodb_table.tfbootstrap.id
  description = "State lock DynamoDB table name"
}