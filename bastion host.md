# 🛡️ Bastion Host

## 📘 Descrição

O **Bastion Host** (ou **Jump Box**) é uma instância criada em uma **sub-rede pública** da VPC, que serve como **ponto de acesso seguro** para gerenciar instâncias localizadas em **sub-redes privadas**.  
Ele é o único servidor com acesso SSH liberado publicamente e funciona como intermediário entre o administrador e os recursos internos da rede.

---

## 🎯 Objetivo

- Permitir **acesso SSH seguro** às instâncias privadas (EC2, RDS, etc).  
- **Restringir a exposição** das instâncias privadas à internet.  
- Facilitar o **gerenciamento remoto** da infraestrutura de forma controlada.  
- Centralizar e **auditar conexões administrativas**.

---

## ⚙️ Configurações Recomendadas

| **Recurso** | **Configuração** |
|--------------|------------------|
| **Sistema Operacional** | Amazon Linux 2 / Ubuntu LTS |
| **Tipo de Instância** | t2.micro (para ambientes de teste) |
| **Sub-rede** | Pública |
| **Elastic IP** | Obrigatório (para IP fixo de acesso) |
| **Key Pair** | Obrigatória para SSH |
| **Acesso SSH** | Somente do IP fixo do administrador |
| **Conexão interna** | Via IP privado para instâncias privadas |


---

## 📊 Security Group - Bastion Host

| **Nome** | **Regras de Entrada (Inbound Rules)** | **Regras de Saída (Outbound Rules)** | **Motivo / Observações** |
|-----------|--------------------------------------|--------------------------------------|---------------------------|
| **Bastion-rules** | - SSH (TCP 22) do **IP fixo do administrador** | Todo tráfego permitido | Permitir acesso SSH apenas do IP confiável. Servirá como ponto seguro de acesso às instâncias privadas. |
| **EC2-web** | - SSH (TCP 22) de **Bastion-rules (SG)** | Todo tráfego permitido | Instâncias web privadas só aceitam SSH proveniente do Bastion Host. |

---

## 🔗 Fluxo de Conexão

