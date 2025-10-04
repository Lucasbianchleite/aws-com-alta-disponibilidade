#!/bin/bash

# ==============================================
# 🚀 Script de Deploy Automático: WordPress + RDS + EFS
# ==============================================
# Este script configura um ambiente WordPress em uma instância EC2:
# - Banco de dados externo no Amazon RDS
# - Armazenamento persistente no Amazon EFS
# - Container WordPress rodando via Docker Compose
# ==============================================

# ---------- Variáveis de Ambiente ----------
RDS_ENDPOINT="database-wordpress.abcdefghijklmnopqus-east-1.rds.amazonaws.com"   # Endpoint do RDS (MySQL)
RDS_PORT=3306                                                                    # Porta padrão MySQL
DB_NAME="meu_banco"                                                               # Nome do banco de dados
DB_USER="admin"                                                                   # Usuário do banco
DB_PASS="12345678"                                                                # Senha do banco
EFS_FS_ID="fs-asdvdfdsfasddasd"                                                   # ID do EFS
EFS_MOUNT="/mnt/efs"                                                              # Caminho local de montagem do EFS

# ---------- Atualização e instalação de pacotes ----------
echo "📦 Atualizando pacotes e instalando dependências..."
sudo yum update -y
sudo yum install -y docker amazon-efs-utils

# ---------- Configuração do Docker ----------
echo "🐳 Habilitando e iniciando Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# ---------- Instalação do Docker Compose ----------
echo "📥 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# ---------- Montagem do EFS ----------
echo "🗂️ Configurando montagem do EFS..."
sudo mkdir -p ${EFS_MOUNT}
sudo mount -t efs -o tls ${EFS_FS_ID}:/ ${EFS_MOUNT}
sudo chown -R 1000:1000 ${EFS_MOUNT}   # UID 1000 geralmente = www-data ou apache/nginx
sudo chmod -R 775 ${EFS_MOUNT}

# ---------- Criação do arquivo docker-compose ----------
echo "⚙️ Gerando arquivo docker-compose.yml..."
cat <<EOF | sudo tee /home/ec2-user/docker-compose.yml > /dev/null
version: "3.8"

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${RDS_ENDPOINT}:${RDS_PORT}
      WORDPRESS_DB_NAME: ${DB_NAME}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASS}
    volumes:
      - ${EFS_MOUNT}:/var/www/html
EOF

# ---------- Deploy do WordPress ----------
echo "🚀 Subindo container WordPress..."
cd /home/ec2-user
sudo docker-compose up -d

echo "✅ Deploy concluído! Acesse o WordPress pelo IP público da instância (porta 80)."
