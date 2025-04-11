#!/bin/bash
# Script para crear la infraestructura base necesaria para probar el módulo ECS
# Este script debe ser ignorado por git

set -e

# Configurar AWS CLI para no usar paginador
export AWS_PAGER=""

# Función para cargar variables de un archivo .env
dotenv() {
  if [ -f .env ]; then
    echo "Cargando variables desde .env"
    set -o allexport
    source .env
    set +o allexport
  else
    echo "Archivo .env no encontrado. Utilizando valores predeterminados o variables de entorno."
  fi
}

# Cargar variables de entorno desde .env si existe
dotenv

bucket_name="terraform-state-$(date +%s)"
echo "Creando bucket S3 para el estado de Terraform: $bucket_name"
aws s3 mb "s3://$bucket_name" --region "$AWS_REGION"

# Habilitar versionamiento en el bucket
aws s3api put-bucket-versioning \
    --bucket "$bucket_name" \
    --versioning-configuration Status=Enabled

# Habilitar cifrado por defecto
aws s3api put-bucket-encryption \
    --bucket "$bucket_name" \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

# 2. Crear tabla de DynamoDB para el bloqueo de estado
dynamodb_table="terraform-locks-$(date +%s)"
echo "Creando tabla DynamoDB para bloqueos de estado: $dynamodb_table"
aws dynamodb create-table \
    --table-name "$dynamodb_table" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION"
if [ -f backend.tf ]; then
    echo "Eliminando archivo backend.tf existente..."
    rm backend.tf
fi
cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "${bucket_name}"
    key            = "terraform.tfstate"
    region         = "${AWS_REGION}"
    dynamodb_table = "${dynamodb_table}"
    encrypt        = true
  }
}
EOF
# Verificar si cleanup-test-infra.sh ya existe, y eliminarlo
if [ -f cleanup-test-infra.sh ]; then
    echo "Eliminando script cleanup-test-infra.sh existente..."
    rm cleanup-test-infra.sh
fi

# Crear script cleanup-test-infra.sh
cat <<EOF > cleanup-test-infra.sh
#!/bin/bash
# Script para limpiar la infraestructura de prueba

set -e

# Configurar AWS CLI para no usar paginador
export AWS_PAGER=""

# Función para cargar variables de un archivo .env
dotenv() {
  if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
  fi
}

# Cargar variables de entorno desde .env si existe
dotenv

echo "Eliminando bucket S3: $bucket_name"
aws s3 rb "s3://$bucket_name" --force

echo "Eliminando tabla DynamoDB: $dynamodb_table"
aws dynamodb delete-table --table-name "$dynamodb_table"
echo "Infraestructura de prueba limpiada exitosamente."
EOF

chmod +x cleanup-test-infra.sh

echo "Script cleanup-test-infra.sh creado exitosamente."