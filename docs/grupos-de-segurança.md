# 🔒 Security Groups AWS

Este documento descreve os **Security Groups (SGs)** utilizados na infraestrutura AWS do projeto, incluindo **EC2, RDS, Bastion Host, EFS e Application Load Balancer (ALB)**, bem como suas respectivas regras de entrada e saída.

Os Security Groups funcionam como **firewalls virtuais**, controlando o tráfego de rede permitido entre os recursos da infraestrutura.

---

## 🚀 Criando um Security Group no Console da AWS

1. No console da AWS, pesquise por **EC2** na barra de busca.
2. No menu lateral, clique em **Security Groups (Grupos de Segurança)**.
3. Clique no botão **Create Security Group (Criar Grupo de Segurança)**.

Preencha as informações básicas:

- **Name (Nome):** Nome do SG  
  Exemplo: `EC2-web`

- **Description (Descrição):** Descrição clara da função do SG  
  Exemplo: `Permitir tráfego web do Load Balancer para as instâncias EC2`

- **VPC:** Selecione a **VPC correta** da infraestrutura.

Em **Inbound Rules (Regras de Entrada)**, configure as portas e origens de acordo com a tabela abaixo.

Em **Outbound Rules (Regras de Saída)**, mantenha o padrão **All traffic**, a menos que exista uma política de segurança mais restritiva.

Clique em **Create Security Group (Criar)**.

---

## 📊 Tabela de Security Groups

| **Nome** | **Regras de Entrada** | **Regras de Saída** | **Motivo / Observações** |
|----------|----------------------|---------------------|--------------------------|
| **EC2-web** | - HTTP (TCP 80) **apenas de** `ALB-web (SG)` <br> - SSH (TCP 22) **apenas de** `Bastion-rules (SG)` | All traffic (padrão AWS) | Instâncias web em **subnets privadas**. Recebem tráfego somente do **Load Balancer** e acesso SSH apenas via **Bastion Host**. |
| **RDS-db** | - MySQL/Aurora (TCP 3306) **de** `EC2-web (SG)` | All traffic (padrão AWS) | Banco de dados acessível **somente pelas instâncias EC2 da aplicação**. |
| **Bastion-rules** | - SSH (TCP 22) **do seu IP fixo ou faixa confiável** | All traffic (padrão AWS) | Bastion host utilizado para acesso SSH seguro às instâncias privadas. |
| **EFS-access** | - NFS (TCP 2049) **de** `EC2-web (SG)` | All traffic (padrão AWS) | Permite que as instâncias EC2 montem o sistema de arquivos **Amazon EFS**. |
| **ALB-web** | - HTTP (TCP 80) **de** `0.0.0.0/0` <br> - HTTPS (TCP 443) **de** `0.0.0.0/0` | All traffic (padrão AWS) | **Application Load Balancer público** que recebe tráfego da internet e encaminha para o **Target Group das instâncias EC2**. |

---

## ⚠️ Observações importantes

Associe corretamente cada **Security Group** ao recurso correspondente:

- **EC2 (Auto Scaling)** → `EC2-web`
- **RDS** → `RDS-db`
- **Bastion Host** → `Bastion-rules`
- **EFS** → `EFS-access`
- **Application Load Balancer** → `ALB-web`

---

## 🔐 Boas práticas de segurança

- Utilize **IPs específicos para SSH** sempre que possível.
- Evite liberar **SSH (porta 22) para `0.0.0.0/0`**.
- O tráfego de saída permanece **All traffic por padrão**, mas pode ser restringido conforme a política de segurança da organização.
- Garanta a consistência entre os Security Groups:

ALB → EC2  
EC2 → RDS  
EC2 → EFS

---

## 🏗 Arquitetura de comunicação da aplicação

Internet  
↓  
Application Load Balancer  
↓  
Target Group  
↓  
EC2 (Auto Scaling Group)  
↓  
RDS + EFS

---

## 🧩 Ambientes múltiplos

Caso existam múltiplos ambientes (por exemplo **dev, stage e prod**), crie **Security Groups separados para cada ambiente**, evitando riscos de exposição ou acesso indevido entre aplicações.
