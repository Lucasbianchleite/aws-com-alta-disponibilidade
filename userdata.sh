#!/bin/bash
set -euxo pipefail
trap 'echo "[ERRO] Linha $LINENO: $BASH_COMMAND" >> /var/log/init-error.log' ERR

#########################################
# Configuração inicial
#########################################

# Garantir uso de IPv4 no apt
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/90force-ipv4

# Teste de rede antes de continuar
until ping -c1 1.1.1.1 &>/dev/null; do
    echo "Aguardando conectividade..."
    sleep 3
done

#########################################
# Variáveis de ambiente da aplicação
#########################################
DB_ENDPOINT="wordpress-rds.abcdefghijkl.us-east-1.rds.amazonaws.com"
DB_USER="admin"
DB_PASS="SuaSenhaForteAqui"
DB_NAME="wordpressdb"
DB_ROOT="OutraSenhaForteAqui"

EFS_ID="fs-0a1b2c3d4e5f6g7h"
EFS_DIR="/mnt/wpstorage"
PROJECT_DIR="/home/ubuntu/wp-app"

#########################################
# Instalação do Docker e pacotes básicos
#########################################
apt update -y
apt install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    nfs-common

# Repositório Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker
usermod -aG docker ubuntu

#########################################
# Montagem do EFS
#########################################
mkdir -p $EFS_DIR
if ! mountpoint -q $EFS_DIR; then
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
        ${EFS_ID}.efs.us-east-1.amazonaws.com:/ $EFS_DIR
fi

mkdir -p $EFS_DIR/wp-content
mkdir -p $EFS_DIR/wp-config

#########################################
# Arquivo Docker Compose
#########################################
mkdir -p $PROJECT_DIR
cat > $PROJECT_DIR/docker-compose.yml <<COMPOSE
version: "3.9"
services:
  wordpress:
    image: wordpress:latest
    container_name: wp_app
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${DB_ENDPOINT}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASS}
      WORDPRESS_DB_NAME: ${DB_NAME}
    volumes:
      - ${EFS_DIR}/wp-content:/var/www/html/wp-content
      - ${EFS_DIR}/wp-config:/var/www/html/wp-config
COMPOSE

#########################################
# Inicializar containers
#########################################
cd $PROJECT_DIR
docker compose up -d

echo "[OK] WordPress implantado com sucesso em $(date)" >> /var/log/init-complete.log
