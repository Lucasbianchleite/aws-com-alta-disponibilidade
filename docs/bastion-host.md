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



## 💻 Exemplo de Conexão

1. Conecte-se ao **Bastion Host** utilizando sua chave SSH:

```bash
ssh -i "minha-chave.pem" ec2-user@<IP_ELASTIC_BASTION>
```

2. Após acessar o Bastion Host, envie sua chave privada para ele (caso precise acessar outras instâncias):

```bash
scp -i "minha-chave.pem" minha-chave.pem ec2-user@<IP_ELASTIC_BASTION>:/home/ec2-user/
```

3. Dentro do Bastion Host, ajuste as permissões da chave:

```bash
chmod 400 minha-chave.pem
```

4. Agora conecte-se à instância privada utilizando o **IP privado da EC2**:

```bash
ssh -i "minha-chave.pem" ec2-user@<IP_PRIVADO_EC2>
```

---

## 🔐 Boas Práticas de Segurança

Para aumentar a segurança do Bastion Host, recomenda-se:

- 🔒 Permitir acesso SSH **apenas do IP do administrador**
- 🚫 Não permitir acesso SSH direto às instâncias privadas
- 🔑 Utilizar **Key Pair ao invés de senha**
- 📜 Monitorar acessos utilizando **AWS CloudTrail ou logs do sistema**
- 🔁 Rotacionar chaves de acesso periodicamente

---

## 📌 Fluxo de Acesso

O fluxo de acesso à infraestrutura ocorre da seguinte forma:

```
Administrador
     │
     ▼
Bastion Host (Subnet Pública)
     │
     ▼
Instâncias EC2 (Subnets Privadas)
```

Esse modelo reduz significativamente a superfície de ataque da infraestrutura, pois **apenas um servidor possui acesso direto pela internet**, enquanto todos os demais recursos permanecem protegidos dentro da rede privada da VPC.

---

## ✅ Resultado

Com a implementação do **Bastion Host**, o acesso administrativo à infraestrutura passa a ocorrer de forma **segura, controlada e auditável**, garantindo que as instâncias privadas permaneçam protegidas contra acessos diretos da internet.

  
