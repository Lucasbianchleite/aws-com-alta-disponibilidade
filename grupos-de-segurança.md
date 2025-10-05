# Security Groups AWS

Este documento descreve os Security Groups (SG) necessários para a infraestrutura AWS, incluindo EC2, RDS, Bastion, EFS e ALB.

---

## Tabela de Security Groups

| Nome            | Regras de Entrada                                        | Regras de Saída        | Motivo / Observações                                  |
|-----------------|---------------------------------------------------------|-----------------------|------------------------------------------------------|
| **EC2-web**     | HTTP: TCP 80, HTTPS: TCP 443 de 0.0.0.0/0<br>SSH: TCP 22 de Bastion-rules (SG) | Todo tráfego permitido | Instâncias web acessíveis publicamente; SSH restrito via Bastion |
| **RDS-db**      | MySQL/Aurora: TCP 3306 de EC2-web (SG)                 | Todo tráfego permitido | Banco acessível apenas pelas instâncias EC2-web     |
| **Bastion-rules** | SSH: TCP 22 do seu IP ou faixa confiável             | Todo tráfego permitido | Acesso SSH seguro para instâncias privadas          |
| **EFS-access**  | NFS: TCP 2049 de EC2-web (SG)                          | Todo tráfego permitido | Permitir que EC2 monte o EFS                         |
| **ALB-web**     | HTTP: TCP 80, HTTPS: TCP 443 de 0.0.0.0/0             | HTTP/HTTPS para EC2-web | Balanceador de carga público direcionando tráfego para EC2-web |
> ⚠️ **Importante:** Associe corretamente os Security Groups (SGs) às instâncias e serviços correspondentes:
> - **EC2-** → SG `EC2-web`  
> - **RDS** → SG `RDS-db`  
> - **Bastion** → SG `Bastion-rules`  
> - **EFS** → SG `EFS-access`  
> - **ALB** → SG `ALB-web`
---




