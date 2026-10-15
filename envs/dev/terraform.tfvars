aws_region  = "sa-east-1"
project     = "emprendego"
environment = "dev"

# Cluster Aurora DSQL DE DEV (independiente de prod).
# OJO: DSQL admite UNA sola base por cluster, asi que dev NO puede compartir el
# cluster de prod sin tocar los datos de prod. Crea un cluster dev y pon aqui su
# ARN y host. No dejes los de prod.
dsql_cluster_arn = "" # TODO: arn:aws:dsql:sa-east-1:590183982101:cluster/<cluster-dev>
dsql_host        = "" # TODO: <cluster-dev>.dsql.sa-east-1.on.aws

frontend_bucket_name = "emprendego-dev-web-590183982101"

# Google: usa un client ID Web propio de dev (o el de prod si agregas el dominio
# dev de CloudFront en sus Authorized JavaScript origins).
google_client_ids         = ""
frontend_google_client_id = ""

enable_snap_start = false

# SECRET_KEY NO va aqui. Pasala por variable de entorno:
#   export TF_VAR_secret_key='...al-menos-32-caracteres...'
