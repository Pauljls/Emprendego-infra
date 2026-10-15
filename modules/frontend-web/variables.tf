variable "name" {
  description = "Prefijo de nombres (ej. emprendego-prod-web)."
  type        = string
}

variable "bucket_name" {
  description = "Nombre globalmente unico del bucket del frontend."
  type        = string
}

variable "price_class" {
  description = "Price class de CloudFront. Para LatAm usa PriceClass_All."
  type        = string
  default     = "PriceClass_All"
}

variable "default_root_object" {
  description = "Objeto raiz por defecto."
  type        = string
  default     = "index.html"
}

variable "tags" {
  description = "Tags adicionales."
  type        = map(string)
  default     = {}
}
