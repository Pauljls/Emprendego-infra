locals {
  name_prefix = "${var.project}-${var.environment}"
}

module "frontend_web" {
  source = "../../modules/frontend-web"

  name        = "${local.name_prefix}-web"
  bucket_name = var.frontend_bucket_name
}

module "backend_api" {
  source = "../../modules/backend-api"

  name              = "${local.name_prefix}-api"
  lambda_zip        = "${path.module}/${var.lambda_zip_path}"
  dsql_cluster_arn  = var.dsql_cluster_arn
  dsql_host         = var.dsql_host
  frontend_url      = "https://${module.frontend_web.domain_name}"
  secret_key        = var.secret_key
  google_client_ids = var.google_client_ids
  enable_snap_start = var.enable_snap_start
}
