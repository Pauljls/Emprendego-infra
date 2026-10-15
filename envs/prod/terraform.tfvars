aws_region  = "sa-east-1"
project     = "emprendego"
environment = "prod"

# Cluster Aurora DSQL existente (no lo gestiona Terraform).
dsql_cluster_arn = "arn:aws:dsql:sa-east-1:590183982101:cluster/fnudi56i53cceezxzamzqmnfhu"
dsql_host        = "fnudi56i53cceezxzamzqmnfhu.dsql.sa-east-1.on.aws"

frontend_bucket_name = "emprendego-web-590183982101"

google_client_ids = "607742440426-j4rq5nis5ju3n41eouc1lr45ber4lmq9.apps.googleusercontent.com,607742440426-qa8rcgfqa1im2kqk3k0il8ed2dpvqnhr.apps.googleusercontent.com"

# Client ID (Web) que usa el frontend para el boton de Google.
frontend_google_client_id = "607742440426-j4rq5nis5ju3n41eouc1lr45ber4lmq9.apps.googleusercontent.com"

enable_snap_start = false

# SECRET_KEY NO va aqui. Pasala por variable de entorno:
#   export TF_VAR_secret_key='...al-menos-32-caracteres...'
