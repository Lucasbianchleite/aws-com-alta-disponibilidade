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

---

## 📑 Sumário
1. [Descrição do Projeto](#-descrição-do-projeto)  
2. [Arquitetura AWS](#-arquitetura-aws)  
3. [Ferramentas Utilizadas](#️-ferramentas-externas)  
4. [Estrutura do Projeto](#-estrutura-do-projeto)  
5. [Passos de Implementação](#-passos-de-implementação)  
   - [5️⃣ . 1️⃣ VPC e Rede](#1️⃣-criação-da-vpc-e-configurações-de-rede)  
   - [5️⃣ . 2️⃣ Security Groups](#2️⃣-criação-dos-security-groups)  
   - [5️⃣ . 3️⃣ Bastion Host](#3️⃣-criação-do-bastion-host)  
   - [5️⃣ . 4️⃣ Banco de Dados (RDS)](#4️⃣-criação-e-configuração-do-rds-mysql)  
   - [5️⃣ . 5️⃣ EFS](#5️⃣-criação-e-configuração-do-efs)  
   - [5️⃣ . 6️⃣ EC2 e User Data](#6️⃣-execução-das-ec2-via-user-data)  
   - [5️⃣ . 7️⃣ Load Balancer](#7️⃣--criar-load-balancer-lb)  
   - [5️⃣ . 8️⃣ Auto Scaling Group](#8️⃣--criar-auto-scaling-group-asg)  

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

### 1️⃣ Criação da VPC e Configurações de Rede  
- 6 subnets (2 públicas + 4 privadas) em **2 AZs** para alta disponibilidade  
- NAT Gateway por AZ  
- Bastion Host em sub-rede pública para acessar instâncias privadas


🔗 [Detalhes da configuração de rede](configurações-de-rede.md)

---

### 2️⃣ Criação dos Security Groups  
Criados 5 SGs para:  
- EC2  
- RDS  
- EFS  
- Load Balancer  
- Bastion Host  

---

### 3️⃣ Criação do Bastion Host  
- Servidor de administração via SSH em sub-rede pública  
- Acesso restrito ao IP do administrador  

---

### 4️⃣ Criação e Configuração do RDS (MySQL)  
- Banco em sub-rede privada  
- Backups automáticos e Multi-AZ habilitados  

---

### 5️⃣ Criação e Configuração do EFS  
- Sistema de arquivos distribuído  
- Mount targets em cada subnet privada  

---

### 6️⃣ Execução das EC2 via User Data  
- Instalação automática de Docker/Containerd  
- Deploy do WordPress  
- Conexão com RDS e EFS  

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
