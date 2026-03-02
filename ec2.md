## 🐳 Execução das EC2 via Launch Template + User Data

A criação das instâncias EC2 ocorre através de um **Launch Template**, que contém o script `userdata.sh`.  
Esse script é executado automaticamente no primeiro boot da instância.

Antes de criar o Launch Template, é necessário coletar todas as informações que serão utilizadas nas variáveis do script.

---

# 🔎 1️⃣ Coletando as Informações Necessárias

## 📌 1.1 Informações do Banco de Dados (RDS)

1. Acesse **AWS Console → RDS → Databases**
2. Clique na instância criada
3. Localize e copie:

- **Endpoint** → será usado em `RDS_ENDPOINT`
- **Porta** → normalmente `3306`
- **Master username** → será usado em `DB_USER`

O nome do banco (`DB_NAME`) é o definido durante a criação do RDS.

A senha (`DB_PASS`) é a senha configurada ao criar o banco.

Você utilizará essas informações nas variáveis:

```bash
RDS_ENDPOINT="seu-endpoint.rds.amazonaws.com"
RDS_PORT=3306
DB_NAME="nome_do_banco"
DB_USER="usuario"
DB_PASS="senha"
```

---

## 📌 1.2 Informações do Amazon EFS

1. Acesse **AWS Console → EFS → File systems**
2. Clique no filesystem criado
3. Copie o campo:

- **File system ID** (exemplo: `fs-0a1b2c3d4e5f`)

Utilize no script:

```bash
EFS_FS_ID="fs-xxxxxxxxxxxxxxxxx"
EFS_MOUNT="/mnt/efs"
```

---

# 🚀 2️⃣ Criando o Launch Template com User Data

Após coletar todas as informações, será criado o Launch Template contendo o script.

1. Vá em **EC2 → Launch Templates**
2. Clique em **Create launch template**
3. Configure:

- **Nome**: `wordpress-template`
- **AMI**: Amazon Linux 2
- **Instance Type**: t2.micro (ou similar)
- **Key Pair**: selecione sua chave SSH
- **Security Group**: `EC2-web`

4. Expanda a seção **Advanced Details**
5. No campo **User Data**, cole o script completo `userdata.sh` já com as variáveis alteradas para o seu ambiente
6. Clique em **Create launch template**

---

# 📄 Script completo `userdata.sh`

```bash
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
```
