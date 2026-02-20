# 🔒 Security Groups AWS

Este documento descreve os **Security Groups (SGs)** necessários para a infraestrutura AWS, incluindo **EC2, RDS, Bastion, EFS e ALB**, bem como suas respectivas regras de entrada e saída.  

---

## 🚀 Criando um Security Group no Console da AWS

1. No **console da AWS**, pesquise por **EC2** na barra de busca.  
2. No menu lateral, clique em **Security Groups** (Grupos de Segurança).  
3. Clique no botão **Create Security Group** (Criar Grupo de Segurança).  
4. Preencha as informações básicas:  
   - **Name** (Nome): Nome do SG (ex: `EC2-web`)  
   - **Description**: Descrição clara da função do SG (ex: “Permitir tráfego web público para instâncias EC2”)  
   - **VPC**: Selecione a **VPC correta** (fundamental para que o SG funcione nos recursos certos).  
5. Em **Inbound Rules** (Regras de Entrada), adicione as portas/protocolos necessários de acordo com a tabela abaixo.  
6. Em **Outbound Rules** (Regras de Saída), por padrão, mantenha **All traffic (Todo o tráfego)**.  
   > Obs: Se sua política exigir mais segurança, restrinja conforme necessário.  
7. Clique em **Create Security Group** (Criar).  

---

## 📊 Tabela de Security Groups

| **Nome**         | **Regras de Entrada**                                                                 | **Regras de Saída**        | **Motivo / Observações**                                  |
|------------------|---------------------------------------------------------------------------------------|----------------------------|----------------------------------------------------------|
| **EC2-web**      | - HTTP (TCP 80) de `0.0.0.0/0` <br> - HTTPS (TCP 443) de `0.0.0.0/0` <br> - SSH (TCP 22) **apenas de** `Bastion-rules (SG)` | Todo tráfego permitido     | Permitir acesso público via HTTP/HTTPS; SSH restrito apenas via Bastion. |
| **RDS-db**       | - MySQL/Aurora (TCP 3306) de `EC2-web (SG)`                                           | Todo tráfego permitido     | Banco de dados acessível **somente** pelas instâncias web (EC2). |
| **Bastion-rules**| - SSH (TCP 22) do seu **IP fixo** ou **faixa confiável**                              | Todo tráfego permitido     | Bastion host para acesso SSH seguro a instâncias privadas. |
| **EFS-access**   | - NFS (TCP 2049) de `EC2-web (SG)`                                                    | Todo tráfego permitido     | Permitir que as instâncias EC2 montem o EFS.             |
| **ALB-web**      | - HTTP (TCP 80) de `0.0.0.0/0` <br> - HTTPS (TCP 443) de `0.0.0.0/0`                  | HTTP/HTTPS para `EC2-web`  | Balanceador de carga público direcionando tráfego para instâncias web. |

---

## ⚠️ Observações Importantes

- Associe corretamente cada **Security Group** ao recurso correspondente:  
  - **EC2** → SG `EC2-web`  
  - **RDS** → SG `RDS-db`  
  - **Bastion** → SG `Bastion-rules`  
  - **EFS** → SG `EFS-access`  
  - **ALB** → SG `ALB-web`  

- Utilize **IPs específicos** para SSH sempre que possível (evite `0.0.0.0/0` para maior segurança).  
- O tráfego de saída está liberado por padrão, mas pode ser restringido conforme a política de segurança da organização.  
- Lembre-se de **manter a consistência entre SGs** (ex: EC2 acessa RDS, ALB acessa EC2, etc.).  
- Se houver múltiplos ambientes (**dev, stage, prod**), crie SGs separados para evitar riscos de exposição.  

---




