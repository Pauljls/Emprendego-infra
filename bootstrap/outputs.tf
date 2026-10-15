output "state_bucket" {
  description = "Bucket donde vive el state. Usalo en envs/*/backend.tf."
  value       = aws_s3_bucket.tfstate.bucket
}

output "state_region" {
  description = "Region del bucket de state. Usala en envs/*/backend.tf."
  value       = var.region
}
