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


# 🖥️ Infraestrutura WordPress - AWS

![Status](https://img.shields.io/badge/Status-100%25%20Conclu%C3%ADdo-brightgreen)
![AWS](https://img.shields.io/badge/AWS-Infraestrutura-orange)
![WordPress](https://img.shields.io/badge/WordPress-Docker-blue)
  
 
---

## 📄 Descrição do Projeto  

Este projeto tem como objetivo implantar uma aplicação **WordPress** em uma infraestrutura escalável e segura na **AWS**, utilizando:  

- 🐳 **Docker/Containerd** para containerização  
- 🗄️ **RDS (MySQL/MariaDB)** para banco de dados gerenciado  
- 📂 **EFS** para armazenamento compartilhado  
- ⚖️ **Load Balancer** para distribuir tráfego  
- 📈 **Auto Scaling** para elasticidade  

---

# 📦 Controle de Versões da Stack

Para garantir estabilidade e evitar incompatibilidades entre componentes da infraestrutura, as seguintes versões foram utilizadas neste projeto.

| Componente | Versão | Observação |
|---|---|---|
| **AWS EC2 AMI** | Amazon Linux 2 | Sistema operacional das instâncias |
| **Docker** | 24.x | Runtime de containers |
| **Docker Compose** | v2.24.6 | Orquestração dos containers |
| **WordPress** | 6.4.3 (PHP 8.2 Apache) | Imagem oficial Docker |
| **MySQL (RDS)** | 8.0.x | Banco de dados gerenciado |
| **Amazon EFS** | NFS v4.1 | Sistema de arquivos distribuído |
| **Linux Kernel** | padrão Amazon Linux | Gerenciado pela AWS |
| **Porta da Aplicação** | 80 | Exposição do container WordPress |

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


🔗 [Detalhes da configuração de rede](/docs/configurações-de-rede.md)

---

## 2️⃣ Criação dos Security Groups  
Criados 5 SGs para:  
- EC2  
- RDS  
- EFS  
- Load Balancer  
- Bastion Host  

🔗 [Detalhes da configuração de SG](/docs/grupos-de-segurança.md)

---

## 3️⃣ Criação do Bastion Host  
- Servidor de administração via SSH em sub-rede pública  
- Acesso restrito ao IP do administrador  

🔗 [Detalhes do Bastion Host](/docs/bastion-host.md)

---

## 4️⃣ Criação e Configuração do RDS (MySQL)  
- Banco em sub-rede privada  
- Backups automáticos e Multi-AZ habilitados
  
🔗 [Detalhes da configuração do Banco de Dados](/docs/rds.md)

---

## 5️⃣ Criação e Configuração do EFS  
- Sistema de arquivos distribuído  
- Mount targets em cada subnet privada




  🔗 [Detalhes da configuração do EFS](/docs/efs.md)
---

## 6️⃣ Execução das EC2 via User Data  
- Instalação automática de Docker/Containerd  
- Deploy do WordPress  
- Conexão com RDS e EFS
  
🔗 [Detalhes da configuração do Launch template](/docs/ec2.md)
### 📄 Script completo `userdata.sh`

```bash
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
```
---

### 7️⃣ – Criar Load Balancer (LB)  
- Application Load Balancer (ALB)  
- Internet-facing  
- Listener HTTP na porta 80  
- Target Group: `wordpress-tg`

  🔗 [Detalhes da configuração do Load Balancer](/docs/load-balancer.md)
---

### 8️⃣ – Criar Auto Scaling Group (ASG)  
- Nome: `wordpress-asg`  
- Launch Template: `wordpress-template`  
- Subnets privadas (2 AZs)  
- Escalabilidade: mín. 2, máx. 4 instâncias  
- Health checks via ALB + CloudWatch  

🔗 [Detalhes da configuração do Auto Scaling Group](/docs/ASG.md)


---

# ✅ Status do Projeto

<div align="center">

<img src="https://github.com/user-attachments/assets/9762b0f7-0af7-4825-904b-104fa9d92901" width="900">

</div>

A aplicação **WordPress foi implantada com sucesso** na infraestrutura AWS.

Durante o primeiro acesso, o WordPress apresenta a tela de **configuração inicial de idioma**, indicando que:

- O container WordPress foi iniciado corretamente
- A aplicação está rodando nas instâncias EC2
- A comunicação com o banco RDS está funcional
- A infraestrutura provisionada está operacional

Após concluir a configuração inicial do WordPress, o sistema passa a exibir a página padrão do blog com a mensagem **"Olá, mundo!"**, confirmando que a aplicação está pronta para uso.

---

# 🎯 Conclusão

Este projeto demonstra a implementação de uma arquitetura **moderna, escalável e resiliente** para aplicações web na AWS.

Com a utilização de **Load Balancer, Auto Scaling, RDS Multi-AZ e EFS**, a aplicação consegue:

- 📈 Escalar automaticamente conforme a demanda
- 🌍 Manter alta disponibilidade
- 🛡️ Garantir maior resiliência contra falhas
- ⚙️ Automatizar o provisionamento das instâncias

Essa arquitetura segue boas práticas amplamente utilizadas em ambientes profissionais de **Cloud e DevOps**, demonstrando como aplicações web podem ser implantadas de forma **segura, escalável e altamente disponível na AWS**.

---

# 👨‍💻 Autor

Projeto desenvolvido por **Lucas Bianchini Leite**.

🎓 Estudante de **Segurança da Informação**  
☁️ Foco em **Cloud, DevOps e Segurança**

---

## 📬 Contato

Se quiser trocar uma ideia sobre **Cloud, DevOps, AWS ou projetos de infraestrutura**, fique à vontade para entrar em contato.

🔗 **LinkedIn**  
https://www.linkedin.com/in/lucasbianchini01/

📧 **Email**  
Lucas.contato318@gmail.com

---

<p align="center">

⭐ Se este projeto foi útil para você, considere dar uma **star** no repositório!

</p>
