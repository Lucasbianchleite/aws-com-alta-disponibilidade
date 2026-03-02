# Provisionamento Amazon EFS (armazenamento compartilhado)
Este guia documenta a criação e configuração do **Amazon EFS** para servir como armazenamento persistente e compartilhado entre instâncias EC2 (inclusive em Auto Scaling), garantindo que arquivos do WordPress (uploads, temas, plugins) sejam consistentes em todas as instâncias.

---

## Objetivo da Infraestrutura
Implementar um **filesystem NFS gerenciado**, com **mount targets em cada subnet privada** (uma por AZ), acessível apenas pelas instâncias da aplicação, via **Security Group dedicado**.

---

## Pré-requisitos
- VPC e subnets privadas já criadas (2 AZs).
- Security Group do EFS criado: `EFS-access`, com:
  - Entrada: **NFS (TCP 2049)** a partir do SG `EC2-web` (SG das instâncias) :contentReference[oaicite:2]{index=2}

---

## Passo a Passo de Configuração

### 1. Criar o File System (EFS)
1. No Console AWS, pesquise por **EFS**.
2. Clique em **File systems** > **Create file system**.
3. Selecione a **VPC do projeto**.
4. Nome sugerido: `efs-wordpress`.
5. **Encryption at rest**: habilitar (recomendado).
6. **Performance mode**: `General Purpose` (padrão para WordPress).
7. **Throughput mode**: `Bursting` (padrão, suficiente para a maioria dos labs).

---

### 2. Configurar Network: Mount Targets nas subnets privadas
1. Abra o filesystem criado (`efs-wordpress`).
2. Vá em **Network** (ou “Manage network access”).
3. Para cada **AZ usada no projeto**, crie/garanta um **Mount target** em uma **subnet privada** dessa AZ.
4. Em **Security group**, associe **somente** o SG `EFS-access`.

> A regra chave é: **um mount target por AZ**. Se o ASG subir instâncias em duas AZs, o EFS precisa ter mount target nas duas.

---
