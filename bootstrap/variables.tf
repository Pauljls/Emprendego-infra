variable "region" {
  description = "Region donde vivira el bucket de state de Terraform."
  type        = string
  default     = "sa-east-1"
}

variable "state_bucket_name" {
  description = "Nombre globalmente unico del bucket que guardara el state de Terraform."
  type        = string
  default     = "emprendego-tfstate-590183982101"
}

variable "noncurrent_version_expiration_days" {
  description = "Dias antes de expirar versiones antiguas del state."
  type        = number
  default     = 90
}
