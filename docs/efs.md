# 📦 Provisionamento Amazon EFS (armazenamento compartilhado)

Este guia documenta a criação e configuração do **Amazon EFS** para servir como armazenamento persistente e compartilhado entre instâncias EC2 (inclusive em Auto Scaling), garantindo que arquivos do WordPress (uploads, temas e plugins) permaneçam consistentes entre todas as instâncias.

---

## 🎯 Objetivo da Infraestrutura

Implementar um **filesystem NFS gerenciado**, com **mount targets em cada subnet privada** (um por AZ), acessível apenas pelas instâncias da aplicação por meio de um **Security Group dedicado**.

---

## Pré-requisitos

- VPC e subnets privadas já criadas (2 AZs).
- Security Group do EFS criado: `EFS-access`, contendo:
  - Entrada: **NFS (TCP 2049)** com origem no Security Group `EC2-web` (instâncias da aplicação).

> Remova o trecho `:contentReference[oaicite:2]{index=2}` do arquivo, pois parece erro de formatação.

---

## 🛠️ Passo a Passo de Configuração

### 1. Criar o File System (EFS)

1. No Console AWS, pesquise por **EFS**.
2. Clique em **File systems** > **Create file system**.
3. Selecione a **VPC do projeto**.
4. Nome sugerido: `efs-wordpress`.
5. **Encryption at rest**: habilitar.
6. **Performance mode**: `General Purpose`.
7. **Throughput mode**: `Bursting`.

---

### 2. Configurar Network (Mount Targets)

1. Abra o filesystem criado (`efs-wordpress`).
2. Acesse a aba **Network** (ou *Manage network access*).
3. Para cada AZ utilizada no projeto, garanta a existência de um **Mount Target** em uma **subnet privada** dessa AZ.
4. Associe exclusivamente o Security Group `EFS-access`.

> Regra importante: deve existir **um mount target por AZ** utilizada pelo Auto Scaling Group.  
> Isso garante acesso local ao EFS e mantém a alta disponibilidade da arquitetura.
