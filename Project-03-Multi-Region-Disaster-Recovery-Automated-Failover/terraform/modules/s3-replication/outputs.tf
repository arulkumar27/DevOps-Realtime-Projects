output "primary_bucket_name" {
  value = aws_s3_bucket.primary.id
}

output "replica_bucket_name" {
  value = aws_s3_bucket.replica.id
}

output "replication_role_arn" {
  value = aws_iam_role.replication.arn
}