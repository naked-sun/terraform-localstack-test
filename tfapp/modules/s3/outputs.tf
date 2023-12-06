output "backend_bucket" {
  value = aws_s3_bucket.testapp.arn
}

output "backend_instance_profile_id" {
  value = aws_iam_instance_profile.backend_instance.id
}