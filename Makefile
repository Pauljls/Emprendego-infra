# Makefile raiz de emprendego-infra
#
# Uso:  make <target> ENV=prod|dev   (ENV por defecto: prod)
#
# Requiere en el PATH: terraform, aws, node/npm, make y docker (para el build del backend).
# Credenciales AWS via entorno, p.ej.:  export AWS_PROFILE=admin
# Secretos via entorno:                 export TF_VAR_secret_key='...'
#
# Targets:
#   make plan        ENV=dev     -> terraform plan del entorno
#   make apply       ENV=dev     -> terraform apply del entorno
#   make destroy     ENV=dev     -> terraform destroy del entorno
#   make deploy-api  ENV=prod    -> empaqueta el backend (make build) + terraform apply
#   make deploy-web  ENV=prod    -> build del frontend desde los outputs + s3 sync + invalidacion

ENV ?= prod

TF  := terraform -chdir=envs/$(ENV)
WEB := ../FinGrow-Frontend

.PHONY: help plan apply destroy deploy-api deploy-web

help:
	@echo "Uso: make <target> ENV=prod|dev  (ENV=$(ENV))"
	@echo ""
	@echo "  plan        terraform plan de envs/$(ENV)"
	@echo "  apply       terraform apply de envs/$(ENV)"
	@echo "  destroy     terraform destroy de envs/$(ENV)"
	@echo "  deploy-api  build del zip del backend + terraform apply"
	@echo "  deploy-web  build del frontend (leyendo outputs) + s3 sync + invalidacion"

plan:
	$(TF) plan

apply:
	$(TF) apply

destroy:
	$(TF) destroy

# Empaqueta el backend y aplica la infraestructura del entorno.
deploy-api:
	$(MAKE) -C ../emprendego-api build
	$(TF) apply

# Construye el frontend con los valores del entorno (tomados de los outputs de
# Terraform: api_url y google_client_id), lo sube a S3 y limpia CloudFront.
# Terraform es la unica fuente de verdad; no hay que escribir URLs a mano.
deploy-web:
	@set -e; \
	api=$$($(TF) output -raw api_url); \
	cid=$$($(TF) output -raw google_client_id); \
	bucket=$$($(TF) output -raw frontend_bucket); \
	dist=$$($(TF) output -raw distribution_id); \
	echo ">> Entorno: $(ENV)"; \
	echo ">> API:     $$api"; \
	echo ">> Bucket:  $$bucket"; \
	echo ">> Build del frontend..."; \
	VITE_API_URL="$$api" VITE_GOOGLE_CLIENT_ID="$$cid" npm --prefix $(WEB) run build; \
	echo ">> Sync a S3..."; \
	aws s3 sync $(WEB)/dist/ "s3://$$bucket" --delete; \
	aws s3 cp $(WEB)/dist/index.html "s3://$$bucket/index.html" \
		--cache-control "no-cache" --content-type "text/html"; \
	echo ">> Invalidacion de CloudFront..."; \
	aws cloudfront create-invalidation --distribution-id "$$dist" \
		--paths '/*' --query 'Invalidation.Id' --output text
