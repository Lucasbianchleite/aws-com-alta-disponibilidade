<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/022791ab-a063-43ff-8f4d-4e539a5459f5" alt="Image" width="1200" height="auto"></td>
    <td>
      <h1>Projeto: Deploy de WordPress com AWS</h1>
      <div align="center">
        <a href="https://skillicons.dev">
          <img src="https://skillicons.dev/icons?i=aws,docker,wordpress,mysql,linux" alt="My Skills" 
            <p align="center">
  <br>
    <br>      
  <img src="https://github.com/user-attachments/assets/79a2e995-a1be-4192-9ded-771004ef7417" width="200">
</p>
        </a>
      </div>
    </td>
  </tr>
</table>



## Descrição do Projeto

Este projeto tem como objetivo implantar uma aplicação WordPress em uma infraestrutura escalável e segura na AWS, utilizando contêineres Docker ou Containerd, banco de dados gerenciado via RDS, armazenamento compartilhado com EFS e distribuição de tráfego com Load Balancer.

---


# Tecnologias Utilizadas  
## Serviços e Recursos da AWS  

### 🌐 VPC Personalizada  
- 🌍 2 Subnets públicas (para o ALB)  
- 🔒 4 Subnets privadas (para EC2 e RDS)  
- 🗺️ Route Tables  
- 🌎 Internet Gateway (IGW)  
- 🚪 NAT Gateway  

### 💻 Amazon EC2  
- ⚖️ Auto Scaling Group (ASG)  
- 📑 Launch Template  
- 📝 Script de bootstrap (User Data)  

### 🛢️ Amazon RDS  
- 🗄️ Banco de dados **MySQL/MariaDB**  
- 🔐 Grupo de segurança (Security Group)  
- 🔒 Subnets privadas  

### 📂 Amazon EFS  
- 📁 Sistema de arquivos **NFS**  
- 💽 Montado via EC2  

### ⚖️ Application Load Balancer (ALB)  
- 🔄 Distribuição de tráfego entre instâncias  
- ❤️ Health Checks configurados  

### 📊 Amazon CloudWatch *(Atividade extra)*  
- 👀 Monitoramento  
- 📈 Testes de escalabilidade do ASG  

### 🏗️ Infraestrutura como Código *(Atividade extra)*  
- ⚒️ Terraform  
- ⚙️ AWS CloudFormation  





##  Estrutura do Projeto
<img src="https://github.com/user-attachments/assets/9a8974e4-2959-4021-87b8-8faa61e205e7" alt="Image">

## Ordem das etapas :

## 1- criação de VPC,configuraçoes de subnet, gatewayNAT, Tabelas de rotas,

Nessa etapa, iremos criar e confiigurar a parte de  redes da AWS,
criaremos a vpc




Vamos criar 6 sub-redes, sendo 4 públicas (sendo 2 para NAT Gateway, junto ao Bastion Host) e 4 privadas (para EC2, RDS e EFS), divididas em 2 AZs para maior disponibilidade.

### 📥 Informações das Sub-redes

| AZ           | Tipo     | Nome                  | Motivo                                                      |
|--------------|----------|----------------------|------------------------------------------------------------|
| us-east-1a   | Pública  | NAT-Bastion-subnet    | Ter acesso à EC2 em subnet privada e colocar o NAT Gateway da AZ1 |
| us-east-1a   | Privada  | EC2-1-subnet-private  | Alocar a EC2-1 em subnet privada                            |
| us-east-1a   | Privada  | EFS-1-subnet-private  | Alocar um mount target do EFS para comunicação com a EC2   |
| us-east-1b   | Pública  | NAT-subnet-public2    | NAT Gateway para a EC2 ter acesso à internet               |
| us-east-1b   | Privada  | EC2-2-subnet-private  | Alocar a EC2-2 em subnet privada                            |
| us-east-1b   | Privada  | EFS-2-subnet-private  | Alocar um mount target do EFS para comunicação com a EC2   |

(mini tutorial)



depois de criar as Sub nets, precisamos criar o nat gateway (explicação em nota do que é), entao vamos dividir ele em 2 azs



### 📥 Informações dos GatewayNAT


| AZ           | Sub-rede | Nome                  | Motivo                                                                 |
|--------------|----------|----------------------|------------------------------------------------------------------------|
| us-east-1a   | Pública  | NAT-Bastion-subnet    | Para alocar na tabela de rotas da EC2-1-subnet-private, permitindo que as EC2 desse grupo se comuniquem |
| us-east-1b   | Privada  | NAT-subnet-public2    | Para alocar na tabela de rotas da EC2-2-subnet-private, permitindo que as EC2 desse grupo se comuniquem |

(mini tuto)


### 🛠️ Passo a Passo para Alocar NAT Gateways às Sub-redes Privadas

Após criar os NAT Gateways, siga os passos abaixo para permitir que as sub-redes privadas tenham rotas de saída e consigam baixar atualizações:

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



# 🔐 Etapa: Criação dos Security Groups
No projeto, serão criados 4 Security Groups (SGs), cada um responsável por isolar e proteger um componente específico da arquitetura:

> 🖥️ Instâncias EC2

> 🗄️ Banco de Dados (RDS MySQL)

> 📁 Elastic File System (EFS)

> 🌐 Load Balancer (CLB)


para ver as configurações do security group, clique aqui ->


##3- criação do bastion host



##3- criação e configuração do rds(mySql)

##4- criação e configuração do EFS e monunt targets


##5-execução da ec2 por meio do user DATA

