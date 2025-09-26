# Projeto: Implantação do WordPress em Alta Disponibilidade na AWS  

## 1. Introdução  
Com o crescimento contínuo das aplicações web, a alta disponibilidade, a escalabilidade e a resiliência se tornaram requisitos fundamentais em arquiteturas modernas. Este projeto tem como objetivo a implantação da plataforma **WordPress** na nuvem AWS, simulando um ambiente de produção real, no qual falhas ou interrupções não podem comprometer a disponibilidade do serviço.  

Para isso, foram utilizados serviços gerenciados da AWS que permitem concentrar esforços na lógica de implantação e escalabilidade, sem a necessidade de administrar manualmente bancos de dados ou sistemas de arquivos distribuídos.  

---

## 2. Objetivos  
- Implementar o WordPress em um ambiente escalável e tolerante a falhas.  
- Utilizar boas práticas de arquitetura em nuvem.  
- Aplicar conceitos de infraestrutura como código e provisionamento de recursos na AWS.  
- Desenvolver competências práticas em ambientes resilientes e de alta disponibilidade.  

---

## 3. Arquitetura da Solução  
A arquitetura implementada é composta pelos seguintes recursos da AWS:  

- **VPC personalizada**  
  - Duas subnets públicas (destinadas ao Application Load Balancer).  
  - Quatro subnets privadas (para instâncias EC2 e banco de dados RDS).  
  - Configuração de *Route Tables*, Internet Gateway (IGW) e NAT Gateway.  

- **Amazon RDS (MySQL/MariaDB)**  
  - Banco de dados relacional hospedado em subnets privadas.  
  - Configuração de segurança para permitir acesso somente a partir das instâncias EC2.  

- **Amazon EFS**  
  - Sistema de arquivos compartilhado, montado automaticamente nas instâncias EC2 via script *user-data*.  
  - Utilizado para armazenar arquivos do WordPress, como imagens e vídeos.  

- **EC2 + Auto Scaling Group (ASG)**  
  - Instâncias configuradas via *user-data* para instalar e configurar WordPress.  
  - Escalabilidade automática baseada no uso de CPU.  
  - Distribuição entre zonas de disponibilidade distintas.  

- **Application Load Balancer (ALB)**  
  - Responsável por distribuir o tráfego de forma balanceada entre as instâncias do ASG.  
  - Configuração de *health checks* para garantir resiliência e disponibilidade.  

---

## 4. Etapas de Implementação  
1. **Execução local do WordPress**  
   - Teste do WordPress via Docker Compose.  

2. **Criação da VPC**  
   - Configuração de 6 subnets (2 públicas e 4 privadas), IGW e NAT Gateway.  

3. **Configuração do RDS**  
   - Criação do banco de dados MySQL/MariaDB em subnets privadas.  
   - Restrição de acesso via grupos de segurança.  

4. **Configuração do EFS**  
   - Criação do sistema de arquivos NFS.  
   - Montagem automática nas instâncias EC2.  

5. **Preparação da AMI / Launch Template**  
   - Instalação de Apache, PHP e WordPress.  
   - Script de inicialização para configuração automática.  

6. **Criação do Auto Scaling Group**  
   - Configurado com base no Launch Template.  
   - Associado ao Application Load Balancer.  

7. **Configuração do Application Load Balancer**  
   - Distribuição do tráfego entre instâncias em subnets privadas.  
   - Monitoramento via *health checks*.  

---

## 5. Segurança da Solução  
- As instâncias EC2 foram provisionadas em subnets privadas, sem exposição direta à internet.  
- O banco de dados RDS foi isolado em subnets privadas, acessível apenas pelas EC2 autorizadas.  
- O ALB foi configurado em subnets públicas, funcionando como ponto de entrada controlado.  
- Regras de segurança foram aplicadas em todos os grupos de segurança para restringir o acesso conforme a necessidade.  

---

## 6. Considerações sobre Custos e Boas Práticas  
- Monitoramento diário dos custos via **AWS Cost Explorer**.  
- Exclusão de todos os recursos após a finalização do projeto, evitando cobranças desnecessárias.  
- Utilização de instâncias compatíveis com as restrições da conta de estudo (exemplo: RDS do tipo `db.t3g.micro`).  
- Reconhecimento de boas práticas adicionais, como uso de Memcached, Multi-AZ no RDS e integração com Route53, que não foram aplicadas por restrições de tempo e custo, mas fazem parte das recomendações oficiais da AWS.  

---

## 7. Atividades Extras (opcionais)  
- Automação da infraestrutura via **Terraform** ou **CloudFormation**.  
- Monitoramento de métricas com **CloudWatch**.  
- Testes de escalabilidade por meio de simulação de aumento de tráfego.  

---

## 8. Referências  
- [Imagem oficial do WordPress – Docker Hub](https://hub.docker.com/_/wordpress)  
- [AWS Whitepaper – Best Practices for WordPress](https://docs.aws.amazon.com/whitepapers/latest/best-practices-wordpress/reference-architecture.html)  
