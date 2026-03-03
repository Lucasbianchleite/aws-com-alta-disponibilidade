#  Auto Scaling Group (ASG)

## 🎯 Objetivo

Provisionar um **Auto Scaling Group (ASG)** responsável por:

- Garantir alta disponibilidade da aplicação
- Manter no mínimo 2 instâncias ativas
- Distribuir instâncias entre múltiplas Availability Zones
- Integrar automaticamente com o Application Load Balancer
- Escalar horizontalmente conforme necessidade

---

## 🏗 Arquitetura Envolvida

O ASG será:

- Associado ao **Launch Template `wordpress-template`**
- Implantado em **subnets privadas (2 AZs)**
- Integrado ao **Target Group `wordpress-tg`**
- Monitorado via **Health Checks do ALB**

### 🔁 Fluxo de Funcionamento

```
Auto Scaling Group
        ↓
Criação automática de instâncias EC2
        ↓
Registro automático no Target Group
        ↓
Load Balancer distribui tráfego
```

---

## 🧩 Etapa 1 – Criar Auto Scaling Group

1. Acesse **EC2 → Auto Scaling Groups**
2. Clique em **Create Auto Scaling group**

---

### ⚙️ Configurações Iniciais

| Campo | Valor |
|--------|--------|
| Name | wordpress-asg |
| Launch Template | wordpress-template |
| Version | Default |

O Launch Template já contém:

- AMI
- Tipo de instância
- Security Group `EC2-web`
- Script `userdata.sh`

---

## 🌐 Configuração de Rede

| Campo | Valor |
|--------|--------|
| VPC | VPC do projeto |
| Subnets | 2 subnets privadas (AZ diferentes) |

A utilização de múltiplas AZs garante maior resiliência e tolerância a falhas.

---

## ⚖️ Integração com Load Balancer

Na etapa **Load Balancing**, selecione:

- ✅ Attach to an existing load balancer
- Target Group: `wordpress-tg`
- Health Check Type: **ELB**

Isso garante que:

- Instâncias unhealthy sejam automaticamente substituídas
- Apenas instâncias saudáveis recebam tráfego

---

## 📏 Configuração de Capacidade

| Parâmetro | Valor |
|------------|--------|
| Desired Capacity | 2 |
| Minimum Capacity | 2 |
| Maximum Capacity | 4 |

Isso significa:

- Sempre haverá no mínimo 2 instâncias ativas
- O grupo poderá escalar até 4 instâncias em caso de aumento de carga

---

## 📊 Política de Escalonamento

Pode-se utilizar:

### 🔹 Target Tracking Policy (Recomendado)

Exemplo:

- Métrica: Average CPU Utilization
- Target: 50%

Quando a média de CPU ultrapassar o limite configurado, novas instâncias serão provisionadas automaticamente.

---

## 🧪 Validação Final da Arquitetura

Após a criação do ASG:

1. Verifique se 2 instâncias foram criadas automaticamente
2. Acesse **EC2 → Target Groups**
3. Confirme que as instâncias estão com status **healthy**
4. Copie o DNS do ALB
5. Acesse no navegador:

```
http://<DNS-do-ALB>
```

Se tudo estiver correto, o WordPress será exibido.

---

## 🔄 Comportamento Esperado

- Se uma instância falhar, o ASG cria outra automaticamente
- Se a CPU subir além do limite definido, novas instâncias serão criadas
- Se a demanda cair, instâncias excedentes poderão ser encerradas
- O tráfego sempre será distribuído apenas para instâncias saudáveis

---


