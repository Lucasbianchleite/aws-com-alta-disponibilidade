# 📦 Provisionamento RDS MySQL (Multi-AZ)

Este guia documenta o passo a passo para criação de uma instância de banco de dados gerenciada utilizando **Amazon RDS**, seguindo boas práticas de **alta disponibilidade, segurança e isolamento de rede**.

---

# 🎯 Objetivo da Infraestrutura

Implementar um banco de dados **MySQL** resiliente, isolado da internet pública e acessível apenas por recursos autorizados dentro da VPC, como:

- Instâncias **EC2**
- Containers da aplicação
- Bastion Host para administração

---

# 🔎 Passo a Passo de Configuração

## 1️⃣ Início e Seleção do Mecanismo

1. No **Console da AWS**, pesquise por **RDS**.
2. Clique em **Bancos de Dados**.
3. Clique em **Criar banco de dados**.
4. Escolha o método **Criação padrão (Standard Create)**.
5. Em **Opções de mecanismo**, selecione:

```
MySQL
```

6. Em **Versão do mecanismo**, selecione a versão estável mais recente (exemplo):

```
MySQL 8.0.x
```

---

## 2️⃣ Opções de Implantação

Selecione as seguintes configurações:

| Configuração | Valor |
|---|---|
| **Modelo** | Produção |
| **Disponibilidade** | Implantação Multi-AZ |

> A implantação **Multi-AZ** cria automaticamente uma instância **primária** e uma **standby** em outra zona de disponibilidade.

Isso permite **failover automático** caso ocorra falha na AZ principal.

---

## 3️⃣ Configurações da Instância

| Campo | Valor Sugerido |
|---|---|
| **Identificador do BD** | `database-wp` |
| **Usuário Master** | `admin` |
| **Gerenciamento de senha** | Senha autogerenciada |
| **Classe de instância** | `t3` ou `m5` |

---

## 4️⃣ Configurações do Banco de Dados

Em **Configurações adicionais**, defina:

| Campo | Valor |
|---|---|
| **Nome inicial do banco** | `meu_banco` |

Este banco será utilizado pela aplicação WordPress.

---

# 🔐 Conectividade (Configuração Crítica)

Estas configurações garantem que o banco **permaneça privado**.

| Configuração | Valor |
|---|---|
| **VPC** | VPC do projeto |
| **Grupo de subnets** | Subnets **privadas** |
| **Acesso público** | **Não** |
| **Security Group** | `sg-rds-project` |

---

## 📊 Security Group do RDS

O Security Group do banco deve permitir acesso apenas da aplicação.

| Regra | Porta | Origem |
|---|---|---|
| MySQL | 3306 | Security Group das instâncias EC2 |

Isso garante que **somente a aplicação possa acessar o banco**.

---

# 🔐 Boas Práticas Aplicadas

> [!IMPORTANT]  
> O banco **não possui IP público**.  
> O acesso ocorre apenas através da aplicação dentro da VPC ou via Bastion Host.

Principais práticas aplicadas:

### 🔹 Isolamento de Rede
O banco está em **subnets privadas**, sem exposição direta à internet.

### 🔹 Alta Disponibilidade
A configuração **Multi-AZ** mantém uma instância standby sincronizada em outra zona de disponibilidade.

### 🔹 Criptografia
Recomenda-se habilitar **criptografia em repouso com AWS KMS**.

### 🔹 Backups
Configure retenção de backup mínima de:

```
7 dias
```

---

# ✅ Verificação Final

Após o banco mudar para o status:

```
Available
```

Colete as seguintes informações para configurar a aplicação:

| Informação | Exemplo |
|---|---|
| Endpoint | `database-wp.xyz.us-east-1.rds.amazonaws.com` |
| Porta | `3306` |
| Banco | `meu_banco` |

Essas informações serão utilizadas na configuração do **WordPress**.

---

# 📌 Fluxo de Conexão

```
WordPress (EC2)
      │
      ▼
Security Group
      │
      ▼
Amazon RDS MySQL (Multi-AZ)
```

A aplicação se conecta ao banco utilizando o **endpoint do RDS**.

---

# 🚀 Resultado

Com essa configuração o banco de dados possui:

- 🌍 **Alta disponibilidade**
- 🔐 **Isolamento de rede**
- 💾 **Backups automáticos**
- ⚙️ **Gerenciamento simplificado**

Essa arquitetura segue boas práticas utilizadas em ambientes profissionais de **Cloud e DevOps**, garantindo maior confiabilidade para aplicações web em produção.
