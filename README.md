# infra — Terraform de Emprendego

Infraestructura como codigo para desplegar el backend (FastAPI en Lambda) y el
frontend (SPA en S3 + CloudFront) de Emprendego, usando el cluster **Aurora DSQL**
ya existente.

## Arquitectura

```
CloudFront + S3 (frontend SPA)  ──►  API Gateway HTTP API  ──►  Lambda (FastAPI + Mangum)
        (OAC, fallback SPA)              (ruta $default)              │  rol IAM dsql:DbConnectAdmin
                                                                      ▼
                                                             Aurora DSQL (externa, no gestionada)
```

- Una sola Lambda (monolito modular).
- API Gateway HTTP API con ruta `$default` (proxy completo).
- S3 privado + CloudFront con OAC y fallback a `index.html` (react-router).
- Región principal `sa-east-1` (junto al cluster DSQL).
- State remoto en S3 con locking nativo (`use_lockfile`), sin DynamoDB.

## Estructura

```
emprendego-infra/
├── bootstrap/          # raiz 1: crea el bucket del state (estado local)
├── modules/
│   ├── backend-api/    # IAM + Lambda + API Gateway + logs
│   └── frontend-web/   # S3 + CloudFront + OAC
├── envs/
│   ├── prod/           # raiz 2: une los modulos (backend "s3", key prod/)
│   └── dev/            # raiz 3: idem para dev (backend "s3", key dev/)
└── Makefile            # atajos: plan/apply/deploy-api/deploy-web por entorno
```

## Entornos

Cada entorno es un **root module** independiente que reutiliza los mismos
`modules/*`. Cambian solo sus variables y su state (mismo bucket, distinta `key`).

| Entorno | Directorio | State key | Nombres de recursos |
|---|---|---|---|
| prod | `envs/prod` | `prod/terraform.tfstate` | `emprendego-prod-*` |
| dev  | `envs/dev`  | `dev/terraform.tfstate`  | `emprendego-dev-*`  |

> **DSQL**: Terraform admite **una sola base por cluster**, así que `dev` necesita
> su **propio cluster** (no comparte el de prod). Configura `dsql_cluster_arn` y
> `dsql_host` en `envs/dev/terraform.tfvars`. No reutilices los de prod.

### Comandos por entorno (Makefile)

```bash
export AWS_PROFILE=admin          # credenciales con permisos de deploy
export TF_VAR_secret_key='...'    # >= 32 caracteres

make plan       ENV=dev
make apply      ENV=dev
make deploy-api ENV=prod          # make build del backend + terraform apply
make deploy-web ENV=prod          # frontend desde los outputs (ver abajo)
```

`deploy-web` lee `api_url` y `google_client_id` de los **outputs** de ese entorno,
construye el frontend, sube a S3 e invalida CloudFront — sin escribir URLs a mano.

## Requisitos

- Terraform >= 1.10
- AWS CLI configurado (cuenta 590183982101)
- Docker (para empaquetar la Lambda con binarios correctos)
- Cluster DSQL y migraciones ya aplicadas

## Orden de despliegue

### 1. Bootstrap (una sola vez)

```bash
cd emprendego-infra/bootstrap
terraform init
terraform apply
```

Crea el bucket `emprendego-tfstate-590183982101` (versionado, cifrado, privado).

### 2. Construir el backend

```bash
cd ../../emprendego-api
make build          # genera build/backend.zip
```

### 3. Aplicar la infraestructura

```bash
cd ../emprendego-infra/envs/prod

export TF_VAR_secret_key='...tu-secret-de-al-menos-32-caracteres...'

terraform init
terraform plan
terraform apply
```

Outputs relevantes:
- `api_url` → para `VITE_API_URL`
- `google_client_id` → para `VITE_GOOGLE_CLIENT_ID`
- `cloudfront_domain`
- `frontend_bucket`
- `distribution_id`

### 4. Construir y subir el frontend

La forma recomendada es usar el Makefile, que toma los valores de los outputs:

```bash
make deploy-web ENV=prod
```

Equivale a hacerlo a mano:

```bash
cd ../../../FinGrow-Frontend

VITE_API_URL="$(terraform -chdir=../emprendego-infra/envs/prod output -raw api_url)" \
VITE_GOOGLE_CLIENT_ID="$(terraform -chdir=../emprendego-infra/envs/prod output -raw google_client_id)" \
  npm run build

aws s3 sync dist/ "s3://$(terraform -chdir=../emprendego-infra/envs/prod output -raw frontend_bucket)" \
  --delete

# index.html sin cache
aws s3 cp dist/index.html \
  "s3://$(terraform -chdir=../emprendego-infra/envs/prod output -raw frontend_bucket)/index.html" \
  --cache-control "no-cache,no-store,must-revalidate"

# invalidar el HTML en CloudFront
aws cloudfront create-invalidation \
  --distribution-id "$(terraform -chdir=../emprendego-infra/envs/prod output -raw distribution_id)" \
  --paths "/*"
```

## Destruir

```bash
make destroy ENV=dev     # o: cd envs/prod && terraform destroy
```

> El bucket del state no se destruye con esto; bórralo aparte si dejas de usar el proyecto.

## Entornos y migraciones

Las migraciones (Alembic) **no** las maneja este repo; viven en `emprendego-api/`. Regla de oro:

- **Nunca** pongas el `DSQL_HOST` de prod en tu `.env` local. Usa `DB_DRIVER=local`
  (Postgres local) para desarrollar.
- `alembic/env.py` tiene una guarda: con `DB_DRIVER=dsql` aborta salvo que exportes
  `ALLOW_REMOTE_MIGRATIONS=1`. Así un `alembic upgrade` local no toca prod por error.

## Notas

- **Secretos**: `SECRET_KEY` se inyecta como variable de entorno de la Lambda, por lo
  que queda en el state (bucket privado y cifrado). Para evitarlo, lee el secreto
  desde SSM/Secrets Manager en runtime (mejora futura).
- **DSQL**: Terraform solo lo referencia (ARN/host por variable); no lo crea ni migra.
- **SnapStart**: activado por defecto. Si la región no lo soporta, pon
  `enable_snap_start = false` en `terraform.tfvars`.
- **CI/CD**: pendiente. Se agregará un módulo `ci-oidc` (rol IAM + provider OIDC de
  GitHub) y workflows después de validar el deploy manual.
