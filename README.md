<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/022791ab-a063-43ff-8f4d-4e539a5459f5" alt="Infra AWS" width="1200"></td>
    <td>
      <h1>🚀 Projeto: Deploy de WordPress na AWS</h1>
      <div align="center">
        <a href="https://skillicons.dev">
          <img src="https://skillicons.dev/icons?i=aws,docker,wordpress,mysql,linux" alt="My Skills">
        </a>
      </div>
      <p align="center">
        <img src="https://github.com/user-attachments/assets/79a2e995-a1be-4192-9ded-771004ef7417" width="200">
      </p>
    </td>
  </tr>
</table>
s

---

## 📄 Descrição do Projeto  

Este projeto tem como objetivo implantar uma aplicação **WordPress** em uma infraestrutura escalável e segura na **AWS**, utilizando:  

- 🐳 **Docker/Containerd** para containerização  
- 🗄️ **RDS (MySQL/MariaDB)** para banco de dados gerenciado  
- 📂 **EFS** para armazenamento compartilhado  
- ⚖️ **Load Balancer** para distribuir tráfego  
- 📈 **Auto Scaling** para elasticidade  

---

## 🌐 Arquitetura AWS  

| Categoria          | Serviço / Recurso AWS              | Função                                                       |
|--------------------|-------------------------------------|-------------------------------------------------------------|
| 🌐 **Rede**        | VPC, Subnets, Route Tables, IGW, NAT| Configuração da rede isolada, acesso à internet e rotas     |
| 💻 **Computação**  | EC2, Launch Template, ASG, User Data| Hospedagem do WordPress com escalabilidade automática        |
| 🗄️ **Banco**       | Amazon RDS (MySQL)                 | Banco de dados gerenciado                                    |
| 📂 **Armazenamento** | Amazon EFS                        | Compartilhamento de arquivos entre instâncias                |
| ⚖️ **Balanceador** | Application Load Balancer (ALB)    | Distribuição de tráfego e health checks                      |


---

## 🛠️ Ferramentas Externas  

| Ferramenta         | Função                                                                 |
|--------------------|------------------------------------------------------------------------|
| 🐳 **Docker**      | Containerização do WordPress e dependências                            |
| 📰 **WordPress**   | CMS para gerenciamento de conteúdo                                     |
| 🐧 **Linux (Ubuntu)** | Sistema operacional nas instâncias EC2                                |
| 🗄️ **MySQL**       | Banco relacional utilizado pelo WordPress (no RDS)                     |

---

## 🏗️ Estrutura do Projeto  

<p align="center">
  <img src="https://github.com/user-attachments/assets/9a8974e4-2959-4021-87b8-8faa61e205e7" alt="Diagrama da Arquitetura" width="700">
</p>

> 📝 **Nota sobre a arquitetura:**  
> Esta estrutura foi projetada para garantir **escalabilidade, segurança e alta disponibilidade** do WordPress.  
> O **ALB** distribui o tráfego entre instâncias EC2 privadas, que rodam o WordPress em contêineres e podem crescer via **Auto Scaling**.  
> O **RDS (MySQL)** fornece o banco de dados gerenciado, enquanto o **EFS** permite compartilhamento de arquivos entre as instâncias.  
> O **Bastion Host** e os **NAT Gateways** permitem acesso administrativo seguro e saída controlada para a internet.  
> Toda a arquitetura é distribuída em **duas zonas de disponibilidade (AZs)**, aumentando a **tolerância a falhas**.


---

## 🔧 Passos de Implementação  

## 1️⃣ Criação da VPC e Configurações de Rede  
- 6 subnets (2 públicas + 4 privadas) em **2 AZs** para alta disponibilidade  
- NAT Gateway por AZ  
- Bastion Host em sub-rede pública para acessar instâncias privadas


🔗 [Detalhes da configuração de rede](configurações-de-rede.md)

---

## 2️⃣ Criação dos Security Groups  
Criados 5 SGs para:  
- EC2  
- RDS  
- EFS  
- Load Balancer  
- Bastion Host  

🔗 [Detalhes da configuração de SG](grupos-de-segurança.md)

---

## 3️⃣ Criação do Bastion Host  
- Servidor de administração via SSH em sub-rede pública  
- Acesso restrito ao IP do administrador  

🔗 [Detalhes do Bastion Host](bastion-host.md)

---

## 4️⃣ Criação e Configuração do RDS (MySQL)  
- Banco em sub-rede privada  
- Backups automáticos e Multi-AZ habilitados
  
🔗 [Detalhes da configuração do Banco de Dados](rds.md)

---

## 5️⃣ Criação e Configuração do EFS  
- Sistema de arquivos distribuído  
- Mount targets em cada subnet privada  
🔗 [Detalhes da configuração do EFS](efs.md)
---

## 6️⃣ Execução das EC2 via User Data  
- Instalação automática de Docker/Containerd  
- Deploy do WordPress  
- Conexão com RDS e EFS  
🔗 [Detalhes da configuração do Launch template](ec2.md)
### 📄 Script completo `userdata.sh`

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
---

### 7️⃣ – Criar Load Balancer (LB)  
- Application Load Balancer (ALB)  
- Internet-facing  
- Listener HTTP na porta 80  
- Target Group: `wordpress-tg`  

---

### 8️⃣ – Criar Auto Scaling Group (ASG)  
- Nome: `wordpress-asg`  
- Launch Template: `wordpress-template`  
- Subnets privadas (2 AZs)  
- Escalabilidade: mín. 2, máx. 4 instâncias  
- Health checks via ALB + CloudWatch  

---

✅ Com isso, o ambiente fica **escalável, seguro e tolerante a falhas**.
