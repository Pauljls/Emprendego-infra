variable "aws_region" {
  description = "Region principal (debe coincidir con la del cluster DSQL)."
  type        = string
  default     = "sa-east-1"
}

variable "project" {
  description = "Nombre del proyecto."
  type        = string
  default     = "emprendego"
}

variable "environment" {
  description = "Nombre del entorno."
  type        = string
  default     = "prod"
}

variable "dsql_cluster_arn" {
  description = "ARN del cluster Aurora DSQL existente."
  type        = string
}

variable "dsql_host" {
  description = "Endpoint del cluster Aurora DSQL."
  type        = string
}

variable "frontend_bucket_name" {
  description = "Nombre globalmente unico del bucket del frontend."
  type        = string
}

variable "secret_key" {
  description = "SECRET_KEY de la app (>=32 chars). Pasala con TF_VAR_secret_key, no en el repo."
  type        = string
  sensitive   = true
}

variable "google_client_ids" {
  description = "IDs de cliente de Google separados por coma."
  type        = string
  default     = ""
}

variable "frontend_google_client_id" {
  description = "Client ID (Web) que usa el frontend para el boton de Google. Se expone como output para el build."
  type        = string
  default     = ""
}

variable "lambda_zip_path" {
  description = "Ruta al zip del backend, relativa a este modulo."
  type        = string
  default     = "../../../emprendego-api/build/backend.zip"
}

variable "enable_snap_start" {
  description = "Activa SnapStart (desactivalo si la region no lo soporta)."
  type        = bool
  default     = true
}
