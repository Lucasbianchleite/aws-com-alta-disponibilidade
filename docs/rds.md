# 📦 Provisionamento RDS MySQL (Multi-AZ)

Este guia documenta o passo a passo para a criação de uma instância de banco de dados gerenciada utilizando o **Amazon RDS**, seguindo as melhores práticas de alta disponibilidade e segurança em subnets privadas.

---

## 🎯 Objetivo da Infraestrutura
Implementar um banco de dados **MySQL** resiliente, isolado da internet pública e acessível apenas por recursos autorizados dentro da VPC (como instâncias EC2 ou containers).



---

## 🔎 Passo a Passo de Configuração

### 1. Início e Mecanismo
1. No Console AWS, pesquise por **RDS**.
2. Clique em **Bancos de Dados** > **Criar banco de dados**.
3. Escolha o método: **Criação padrão** (*Standard Create*).
4. Opções de mecanismo: **MySQL**.
5. Versão do mecanismo: Selecione a versão estável mais recente (ex: `8.0.x`).

### 2. Opções de Implantação e Modelo
* **Modelo:** Escolha **Produção**.
* **Disponibilidade:** Selecione **Implantação de instância de banco de dados Multi-AZ**.
  > Isso cria uma instância primária e uma réplica síncrona em uma AZ diferente para failover automático.

### 3. Configurações da Instância
| Campo | Valor Sugerido |
| :--- | :--- |
| **Identificador do BD** | `database-wp` |
| **Usuário Master** | `admin` |
| **Gerenciamento de Senha** | Senha autogerenciada |
| **Configuração de Hardware** | Classes `t3` (Burst) ou `m5` (Padrão) |

### 4. Conectividade (Crítico) 🔒
Estas configurações garantem que o banco permaneça privado:

* **VPC:** Selecione a VPC do projeto.
* **Grupo de Subnets:** Selecione o grupo que contém apenas as **subnets privadas**.
* **Acesso Público:** Marque **Não**.
* **VPC Security Group:** * Selecionar **Existente**.
    * Associar o Security Group criado especificamente para o banco (ex: `sg-rds-project`).
    * *Nota: Certifique-se que o SG permite entrada na porta 3306 apenas do SG da aplicação.*

---

## 🔐 Boas Práticas Aplicadas

> [!IMPORTANT]
> **Isolamento de Rede:** O banco não possui IP público. O acesso só é possível via Bastion Host ou pela aplicação dentro da rede.

1. **Alta Disponibilidade:** Multi-AZ garante que, se uma zona de disponibilidade falhar, o RDS altera o DNS para a instância de standby automaticamente.
2. **Segurança de Dados:** Ative a **Criptografia em repouso** (KMS) nas configurações de armazenamento.
3. **Backups:** Configure a retenção de backup para pelo menos 7 dias.

---

## ✅ Verificação Final
Após o status do banco mudar para `Disponível`, colete as seguintes informações para a aplicação:

* **Endpoint:** (Ex: `database-wp.xyz.us-east-1.rds.amazonaws.com`)
* **Porta:** `3306`
* **Nome do Banco:** (Definido nas configurações adicionais)

---
