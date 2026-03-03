#!/bin/bash
# ==============================================
# 🚀 Deploy Automático: WordPress + RDS + EFS (EC2 User Data)
# ==============================================
# Melhorias incluídas:
# - Logs do user-data (debug fácil)
# - Fail-fast e validações
# - Persistência do EFS no reboot (/etc/fstab)
# - Docker Compose mais robusto (tenta v2 e fallback v1)
# - Evita "latest" (fixa versão do WordPress)
# - Mensagens mais coerentes (ALB vs IP público)
# ==============================================

set -euo pipefail

# Loga tudo em arquivo (muito útil pra depurar user-data)
exec > >(tee -a /var/log/user-data.log) 2>&1

# ---------- Variáveis ----------
RDS_ENDPOINT="database-wordpress.abcdefghijklmnopqus-east-1.rds.amazonaws.com"
RDS_PORT="3306"
DB_NAME="meu_banco"
DB_USER="admin"
DB_PASS="12345678"
EFS_FS_ID="fs-asdvdfdsfasddasd"
EFS_MOUNT="/mnt/efs"

# Fixe uma versão para evitar surpresas com updates
WP_IMAGE="wordpress:6.4.3-php8.2-apache"

# ---------- Funções ----------
log() { echo -e "[INFO] $*"; }
warn() { echo -e "[WARN] $*"; }
die() { echo -e "[ERROR] $*"; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Comando não encontrado: $1"
}

# ---------- Pré-checks ----------
log "Iniciando deploy..."
require_cmd yum
require_cmd systemctl

# ---------- Atualização e instalação ----------
log "Atualizando pacotes e instalando dependências..."
yum update -y
yum install -y docker amazon-efs-utils curl

# ---------- Docker ----------
log "Habilitando e iniciando Docker..."
systemctl enable docker
systemctl start docker

# Docker pronto?
docker info >/dev/null 2>&1 || die "Docker não iniciou corretamente."

# ---------- Docker Compose (preferir v2, fallback v1) ----------
log "Instalando Docker Compose..."
# Tenta instalar plugin v2 (se disponível no repo)
if yum install -y docker-compose-plugin >/dev/null 2>&1; then
  log "docker compose (v2) instalado via plugin."
else
  warn "docker-compose-plugin não disponível. Instalando docker-compose (binário)."
  curl -fsSL "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Detecta qual comando compose usar
COMPOSE_CMD=""
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  die "Nenhuma versão do Docker Compose encontrada."
fi
log "Usando Compose: ${COMPOSE_CMD}"

# ---------- Montagem do EFS (com persistência) ----------
log "Configurando montagem do EFS..."
mkdir -p "${EFS_MOUNT}"

# Adiciona no fstab para persistir após reboot
FSTAB_LINE="${EFS_FS_ID}:/ ${EFS_MOUNT} efs _netdev,tls 0 0"
if ! grep -q "${EFS_FS_ID}:/ ${EFS_MOUNT}" /etc/fstab; then
  echo "${FSTAB_LINE}" >> /etc/fstab
  log "Entrada adicionada ao /etc/fstab."
else
  log "Entrada do EFS já existe no /etc/fstab."
fi

# Monta agora
if ! mountpoint -q "${EFS_MOUNT}"; then
  mount -a || die "Falha ao montar EFS. Verifique SG do EFS (2049), DNS, mount targets e subnet."
fi

# Permissões (mais neutras; ideal é EFS Access Point, mas você pediu sem Secrets/extra)
chmod 775 "${EFS_MOUNT}" || true

# ---------- Criação do docker-compose.yml ----------
log "Gerando docker-compose.yml..."
cat > /home/ec2-user/docker-compose.yml <<EOF
services:
  wordpress:
    image: ${WP_IMAGE}
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "${RDS_ENDPOINT}:${RDS_PORT}"
      WORDPRESS_DB_NAME: "${DB_NAME}"
      WORDPRESS_DB_USER: "${DB_USER}"
      WORDPRESS_DB_PASSWORD: "${DB_PASS}"
    volumes:
      - "${EFS_MOUNT}:/var/www/html"
EOF

chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml

# ---------- Subida do WordPress ----------
log "Subindo container WordPress..."
cd /home/ec2-user

# Se já existir, atualiza sem quebrar
${COMPOSE_CMD} up -d || die "Falha ao subir o WordPress via Docker Compose."

# ---------- Verificações rápidas ----------
log "Verificando se o container está rodando..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -i wordpress || die "Container wordpress não apareceu em docker ps."

log "Deploy concluído ✅"
echo
echo "👉 A aplicação está no ar."
echo "   - Se você estiver usando ALB: acesse pelo DNS do ALB."
echo "   - Se for teste direto: acesse pelo IP/DNS público da instância (porta 80)."
echo
echo "📄 Logs: /var/log/user-data.log"
