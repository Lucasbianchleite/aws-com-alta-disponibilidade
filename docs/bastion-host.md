# 🛡️ Bastion Host

## 📘 Descrição

O **Bastion Host** (também conhecido como **Jump Box**) é uma instância localizada em uma **sub-rede pública** da VPC que serve como **ponto de acesso seguro** para gerenciar recursos hospedados em **sub-redes privadas**.

Ele é o único servidor com acesso SSH permitido a partir da internet e atua como intermediário entre o administrador e os recursos internos da infraestrutura.

Esse modelo reduz a exposição direta das instâncias privadas e centraliza o acesso administrativo da rede.

---

## 🎯 Objetivo

- Permitir **acesso SSH seguro** às instâncias privadas da infraestrutura
- **Evitar exposição direta** de servidores internos à internet
- Facilitar o **gerenciamento remoto** da infraestrutura
- Centralizar e **auditar acessos administrativos**

---

## ⚙️ Configurações Recomendadas

| **Recurso** | **Configuração** |
|-------------|------------------|
| **Sistema Operacional** | Amazon Linux 2 ou Ubuntu LTS |
| **Tipo de Instância** | t2.micro (ambientes de teste ou laboratório) |
| **Sub-rede** | Pública |
| **Elastic IP** | Recomendado para IP fixo |
| **Key Pair** | Obrigatória para autenticação SSH |
| **Acesso SSH** | Apenas do IP do administrador |
| **Conexão interna** | Via IP privado para instâncias privadas |

---

## 📊 Security Groups do Bastion

| **Nome** | **Regras de Entrada (Inbound)** | **Regras de Saída (Outbound)** | **Motivo / Observações** |
|----------|----------------------------------|--------------------------------|--------------------------|
| **Bastion-rules** | SSH (TCP 22) **apenas do IP do administrador** | All traffic (padrão AWS) | Permite acesso SSH seguro ao Bastion Host somente a partir de um IP confiável |
| **EC2-web** | SSH (TCP 22) **de Bastion-rules (SG)** | All traffic (padrão AWS) | Instâncias privadas aceitam conexões SSH apenas do Bastion Host |

---

## 💻 Exemplo de Conexão

Primeiro conecte-se ao **Bastion Host** utilizando sua chave SSH:

~~~bash
ssh -A -i "minha-chave.pem" ec2-user@<IP_PUBLICO_BASTION>
~~~

A opção `-A` habilita **SSH Agent Forwarding**, permitindo que sua chave SSH seja utilizada no Bastion sem a necessidade de copiar a chave privada para o servidor.

Após acessar o Bastion Host, conecte-se à instância privada utilizando o **IP privado da EC2**:

~~~bash
ssh ec2-user@<IP_PRIVADO_EC2>
~~~

Dessa forma, o acesso às instâncias privadas ocorre **somente através do Bastion Host**, mantendo a infraestrutura protegida.

---

## 🔐 Boas Práticas de Segurança

Para aumentar a segurança do Bastion Host:

- Permitir acesso SSH **apenas do IP do administrador**
- Nunca liberar **SSH (porta 22) para 0.0.0.0/0**
- Utilizar **Key Pair ao invés de autenticação por senha**
- Evitar copiar **chaves privadas para servidores**
- Utilizar **SSH Agent Forwarding** para acessar instâncias privadas
- Monitorar acessos utilizando **AWS CloudTrail** e **logs do sistema**
- Rotacionar **chaves de acesso periodicamente**

---

## 📌 Fluxo de Acesso

O fluxo de acesso à infraestrutura ocorre da seguinte forma:

Administrador  
↓  
Bastion Host (Subnet Pública)  
↓  
Instâncias EC2 (Subnets Privadas)

---

## ✅ Resultado

Com a implementação do **Bastion Host**, o acesso administrativo à infraestrutura ocorre de forma **segura, controlada e auditável**, garantindo que as instâncias privadas permaneçam protegidas contra acessos diretos da internet.

Esse modelo reduz significativamente a **superfície de ataque da infraestrutura**, pois apenas um servidor possui acesso direto pela internet, enquanto os demais recursos permanecem isolados dentro da rede privada da VPC.
