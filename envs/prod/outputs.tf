output "api_url" {
  description = "URL del API Gateway. Usala como VITE_API_URL al construir el frontend."
  value       = module.backend_api.api_url
}

output "cloudfront_domain" {
  description = "Dominio de CloudFront del frontend."
  value       = module.frontend_web.domain_name
}

output "frontend_bucket" {
  description = "Bucket S3 donde se sube el dist/ del frontend."
  value       = module.frontend_web.bucket_name
}

output "distribution_id" {
  description = "ID de CloudFront para invalidaciones."
  value       = module.frontend_web.distribution_id
}

output "google_client_id" {
  description = "Client ID de Google para el frontend (VITE_GOOGLE_CLIENT_ID)."
  value       = var.frontend_google_client_id
}
