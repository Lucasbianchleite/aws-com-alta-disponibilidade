<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/022791ab-a063-43ff-8f4d-4e539a5459f5" alt="Image" width="1200" height="auto"></td>
    <td>
      <h1>Projeto: Deploy de WordPress com AWS</h1>
      <div align="center">
        <a href="https://skillicons.dev">
          <img src="https://skillicons.dev/icons?i=aws,docker,wordpress,mysql,linux" alt="My Skills">
        </a>
      </div>
      <p align="center">
        <br>
        <img src="https://github.com/user-attachments/assets/79a2e995-a1be-4192-9ded-771004ef7417" width="200">
      </p>
    </td>
  </tr>
</table>

---

## 📄 Descrição do Projeto

Este projeto tem como objetivo implantar uma aplicação WordPress em uma infraestrutura escalável e segura na AWS, utilizando contêineres Docker ou Containerd, banco de dados gerenciado via RDS, armazenamento compartilhado com EFS e distribuição de tráfego com Load Balancer.

---
## 🛠️ Tecnologias Utilizadas  

### 🚀 Serviços AWS  

| Categoria                         | Serviço / Recurso AWS         | Função                                                                 |
|----------------------------------|--------------------------------|------------------------------------------------------------------------|
| 🌐 **Rede (VPC)**                 | VPC Personalizada              | Criação de rede isolada com subnets públicas e privadas                |
|                                  | Subnets (2 públicas, 4 privadas) | Hospedar recursos (EC2, RDS, EFS e ALB)                               |
|                                  | Route Tables                   | Controle de rotas internas e externas                                  |
|                                  | Internet Gateway (IGW)         | Conexão da VPC com a internet                                          |
|                                  | NAT Gateway                    | Permitir saída à internet para instâncias privadas                     |
| 💻 **Computação (EC2)**           | Amazon EC2                     | Hospedagem do WordPress em contêineres                                 |
|                                  | Launch Template                | Padronização da configuração das instâncias                            |
|                                  | Auto Scaling Group (ASG)       | Escalabilidade automática das instâncias                               |
|                                  | User Data (Bootstrap)          | Script de inicialização (instalação e configuração)                    |
| 🛢️ **Banco de Dados (RDS)**       | Amazon RDS (MySQL/MariaDB)     | Banco de dados gerenciado para o WordPress                             |
|                                  | Security Group dedicado        | Controle de acesso ao banco                                            |
| 📂 **Armazenamento (EFS)**        | Amazon EFS (NFS)               | Armazenamento compartilhado entre instâncias                           |
| ⚖️ **Balanceamento de Carga**     | Application Load Balancer (ALB)| Distribuição de tráfego e health checks                                |
| 📊 **Monitoramento (Extra)**      | Amazon CloudWatch              | Monitoramento de métricas e escalabilidade do ASG                      |



---

### 🛠️ Ferramentas Externas  

| Ferramenta         | Função                                                                 |
|--------------------|------------------------------------------------------------------------|
| 🐳 **Docker**      | Containerização do WordPress e seus serviços                           |
| 📰 **WordPress**   | CMS utilizado para publicação e gerenciamento de conteúdo              |
| 🐧 **Linux (Ubuntu)** | Sistema operacional das instâncias EC2                                |
| 🗄️ **MySQL** | Banco de dados utilizado pelo WordPress (gerenciado no RDS)           |


---

## 🏗️ Estrutura do Projeto

<img src="https://github.com/user-attachments/assets/9a8974e4-2959-4021-87b8-8faa61e205e7" alt="Image">

---

## 1️⃣ Criação da VPC e Configurações de Rede

Vamos criar 6 sub-redes, sendo 4 públicas (sendo 2 para NAT Gateway, junto ao Bastion Host) e 4 privadas (para EC2, RDS e EFS), divididas em 2 AZs para maior disponibilidade.

### Para ver as etapas detalhadas, clique aqui --->

### 📥 Informações das Sub-redes

| AZ           | Tipo     | Nome                  | Motivo                                                      |
|--------------|----------|----------------------|------------------------------------------------------------|
| us-east-1a   | Pública  | NAT-Bastion-subnet    | Ter acesso à EC2 em subnet privada e colocar o NAT Gateway da AZ1 |
| us-east-1a   | Privada  | EC2-1-subnet-private  | Alocar a EC2-1 em subnet privada                            |
| us-east-1a   | Privada  | EFS-1-subnet-private  | Alocar um mount target do EFS para comunicação com a EC2   |
| us-east-1b   | Pública  | NAT-subnet-public2    | NAT Gateway para a EC2 ter acesso à internet               |
| us-east-1b   | Privada  | EC2-2-subnet-private  | Alocar a EC2-2 em subnet privada                            |
| us-east-1b   | Privada  | EFS-2-subnet-private  | Alocar um mount target do EFS para comunicação com a EC2   |

> Mini tutorial: Depois de criar as subnets, precisamos criar os NAT Gateways, dividindo-os nas 2 AZs.

### 📥 Informações dos NAT Gateways

| AZ           | Sub-rede | Nome                  | Motivo                                                                 |
|--------------|----------|----------------------|------------------------------------------------------------------------|
| us-east-1a   | Pública  | NAT-Bastion-subnet    | Para alocar na tabela de rotas da EC2-1-subnet-private, permitindo que as EC2 desse grupo se comuniquem |
| us-east-1b   | Privada  | NAT-subnet-public2    | Para alocar na tabela de rotas da EC2-2-subnet-private, permitindo que as EC2 desse grupo se comuniquem |

---

### 🛠️ Passo a Passo para Alocar NAT Gateways às Sub-redes Privadas

1. Acesse o console da **VPC** no AWS Management Console.  
2. No menu lateral, clique em **Tabelas de Rotas**.  
3. Selecione a **tabela de rotas** associada à sua **sub-rede privada**.  
4. Vá até a aba **Rotas**.  
5. Clique em **Editar rotas**.  
6. Adicione uma rota:  
   - **Destino:** `0.0.0.0/0`  
   - **Alvo:** selecione o **NAT Gateway** correspondente à AZ da sua sub-rede privada.  
7. Salve as alterações.  
8. **Repita o processo para cada sub-rede privada que irá receber uma EC2**, garantindo que cada uma esteja associada ao NAT Gateway correto.  

✅ Com isso, suas sub-redes privadas terão acesso à Internet para baixar atualizações e acessar serviços externos.

| Destino    | Alvo        | NAT Gateway escolhido |
|------------|-------------|------------------------|
| 0.0.0.0/0  | GatewayNat  | Escolha o gateway criado |

---

## 2️⃣ Criação dos Security Groups

No projeto, serão criados 5 Security Groups (SGs), cada um responsável por isolar e proteger um componente específico da arquitetura:

- 🖥️ **Instâncias EC2**  
- 🗄️ **Banco de Dados (RDS MySQL)**  
- 📁 **Elastic File System (EFS)**  
- 🌐 **Load Balancer (ALB)**  
- 🤾 **Bastion Host**


---

## 3️⃣ Criação do Bastion Host

- Servirá para acessar as EC2 em sub-redes privadas via SSH.  
- Conectado às subnets públicas e com regras de Security Group específicas.

---

## 4️⃣ Criação e Configuração do RDS (MySQL)

- Banco de dados gerenciado em sub-redes privadas.  
- Configuração de usuários, permissões e backups automáticos.  

---

## 5️⃣ Criação e Configuração do EFS

- Sistema de arquivos **NFS** para armazenamento compartilhado.  
- Criação de mount targets para cada sub-rede privada para comunicação com as EC2.  

---

## 6️⃣ Execução das EC2 via User Data

- EC2 inicializadas com script de bootstrap.  
- Instalação de Docker/Containerd, WordPress e configuração para conectar ao RDS e EFS.  
- Configuração de variáveis de ambiente e volumes persistentes.  




### 7️⃣ – Criar Load Balancer (LB)

- Acesse o console da AWS > **EC2 > Load Balancers > Criar Load Balancer**
- **Escolher**: `Application Load Balancer`
- **Clique**: `Criar`
- **Nome do Load Balancer**: ✅ `wordpress-alb`
- **Esquema**: `Internet-facing`
- **Mapeamento de rede**:
  - **VPC**: `wordpress-vpc`
  - **Availability Zones e subnets**: sub-redes públicas
    - `wordpress-subnet-public1-us-east-1a`
    - `wordpress-subnet-public2-us-east-1b`
- **Grupos de segurança**: `LB-SG`
- **Listeners e roteamento**:
  - **Protocolo**: `HTTP`
  - **Porta**: `80`
  - **Target Group**: `wordpress-tg`
- ✅ **Criar**

---

### 8️⃣– Criar Auto Scaling Group (ASG)

- Acesse o console da AWS > **EC2 > Auto Scaling Groups > Criar Auto Scaling Group**
- **Nome**: `wordpress-asg`
- **Launch Template**: `wordpress-template`
- **Versão**: ✅ `Default(1)`
- **VPC**: `wordpress-vpc`
- **Subnets**: Selecionar 2 subnets privadas
- **Opção de balanceamento**: `Best balanced effort`
- **Associar ao Load Balancer**:
  - **Selecionar Target Group**: `wordpress-tg`
- **Health checks**:
  - ✅ `Enable Elastic Load Balancing health checks`
- **Capacidade desejada**:
  - **Desejada**: `2`
  - **Mínima**: `2`
  - **Máxima**: `4`
- **Monitoramento (CloudWatch)**:
  - ✅ `Enable metric collection in CloudWatch`
- ✅ **Criar**





