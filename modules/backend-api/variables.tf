variable "name" {
  description = "Prefijo de nombres (ej. emprendego-prod-api)."
  type        = string
}

variable "lambda_zip" {
  description = "Ruta local al .zip empaquetado del backend."
  type        = string
}

variable "dsql_cluster_arn" {
  description = "ARN del cluster Aurora DSQL existente (no lo crea Terraform)."
  type        = string
}

variable "dsql_host" {
  description = "Endpoint del cluster Aurora DSQL."
  type        = string
}

variable "frontend_url" {
  description = "Origen del frontend (CloudFront) permitido por CORS."
  type        = string
}

variable "secret_key" {
  description = "SECRET_KEY de la app (>=32 caracteres). Marca el state como sensible."
  type        = string
  sensitive   = true
}

variable "google_client_ids" {
  description = "IDs de cliente de Google separados por coma (puede ir vacio)."
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Runtime de Python de la Lambda."
  type        = string
  default     = "python3.13"
}

variable "architecture" {
  description = "Arquitectura de la Lambda (x86_64 o arm64)."
  type        = string
  default     = "x86_64"
}

variable "memory_size" {
  description = "Memoria de la Lambda en MB (mas memoria = mas CPU)."
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "Timeout en segundos (API Gateway HTTP permite hasta 30)."
  type        = number
  default     = 29
}

variable "enable_snap_start" {
  description = "Activa SnapStart para reducir cold starts (requiere versiones publicadas)."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Retencion de logs en CloudWatch."
  type        = number
  default     = 14
}

variable "reserved_concurrency" {
  description = "Concurrencia reservada (-1 = sin reserva). Acota el pool de conexiones a DSQL."
  type        = number
  default     = -1
}

variable "environment_variables" {
  description = "Variables de entorno adicionales para la Lambda."
  type        = map(string)
  default     = {}
}
