output "bucket_name" {
  description = "Nombre del bucket S3 del frontend."
  value       = aws_s3_bucket.web.bucket
}

output "bucket_regional_domain_name" {
  description = "Dominio regional del bucket."
  value       = aws_s3_bucket.web.bucket_regional_domain_name
}

output "distribution_id" {
  description = "ID de la distribucion de CloudFront (para invalidaciones)."
  value       = aws_cloudfront_distribution.web.id
}

output "distribution_arn" {
  description = "ARN de la distribucion de CloudFront."
  value       = aws_cloudfront_distribution.web.arn
}

output "domain_name" {
  description = "Dominio de CloudFront (para CORS y VITE_API_URL)."
  value       = aws_cloudfront_distribution.web.domain_name
}
