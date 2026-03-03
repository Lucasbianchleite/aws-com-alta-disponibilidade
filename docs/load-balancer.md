# 06 – 🌐 Application Load Balancer (ALB)

## 🎯 Objetivo

Provisionar um **Application Load Balancer (ALB)** público para distribuir o tráfego HTTP entre múltiplas instâncias EC2 do WordPress, garantindo:

- Alta disponibilidade entre múltiplas Availability Zones  
- Balanceamento de carga automático  
- Monitoramento contínuo de saúde das instâncias (health checks)  
- Integração com o Auto Scaling Group  
- Isolamento entre camada pública e privada  

---

## 🏗 Arquitetura Envolvida

O ALB será:

- 🌍 Internet-facing  
- 🔓 Implantado em **subnets públicas**  
- 🔒 Encaminhando tráfego para instâncias em **subnets privadas**  
- 🎯 Integrado ao Target Group `wordpress-tg`  

### 🔁 Fluxo de Tráfego

```
Internet
   ↓
Application Load Balancer (Public Subnets - Multi-AZ)
   ↓
Target Group (wordpress-tg)
   ↓
EC2 WordPress (Private Subnets - Multi-AZ)
```

O ALB atua como ponto de entrada da aplicação, garantindo que nenhuma instância privada seja exposta diretamente à internet.

---

## 🧩 Etapa 1 – Criar Target Group

1. Acesse **EC2 → Target Groups**
2. Clique em **Create target group**

### ⚙️ Configurações

| Campo | Valor |
|--------|--------|
| Target Type | Instances |
| Name | wordpress-tg |
| Protocol | HTTP |
| Port | 80 |
| VPC | VPC do projeto |

---

### ❤️ Health Check

| Campo | Valor |
|--------|--------|
| Protocol | HTTP |
| Path | `/` |
| Healthy threshold | 3 |
| Unhealthy threshold | 3 |
| Timeout | 5s |
| Interval | 30s |

🔎 O WordPress está exposto na porta 80 via container Docker, portanto o health check deve utilizar HTTP na porta 80.

⚠ Neste momento, o Target Group pode permanecer vazio. As instâncias serão registradas automaticamente após a criação do Auto Scaling Group.

Finalize criando o Target Group.

---

## 🌐 Etapa 2 – Criar Application Load Balancer

1. Acesse **EC2 → Load Balancers**
2. Clique em **Create Load Balancer**
3. Escolha **Application Load Balancer**

---

### ⚙️ Configurações Básicas

| Campo | Valor |
|--------|--------|
| Name | wordpress-alb |
| Scheme | Internet-facing |
| IP type | IPv4 |
| VPC | VPC do projeto |
| Subnets | 2 subnets públicas (AZ diferentes) |

O uso de múltiplas AZs garante maior resiliência contra falhas regionais.

---

## 🔐 Security Group do ALB

O ALB deve utilizar o Security Group `ALB-web` com a seguinte regra de entrada:

| Tipo | Protocolo | Porta | Origem |
|------|-----------|--------|--------|
| HTTP | TCP | 80 | 0.0.0.0/0 |

Isso permite acesso público à aplicação.

---

## 🎧 Listener

Configure o listener da seguinte forma:

| Protocolo | Porta | Ação |
|------------|--------|------|
| HTTP | 80 | Forward to wordpress-tg |

O Listener será responsável por receber requisições HTTP e encaminhá-las para o Target Group configurado.

---

## 🧪 Validação Inicial

Após a criação do ALB:

1. Aguarde o status ficar **Active**
2. Verifique se o Listener HTTP:80 está associado ao Target Group `wordpress-tg`

⚠ Neste momento, o Target Group pode aparecer como **empty** ou com targets unhealthy, pois o Auto Scaling Group ainda não foi provisionado.

A validação completa do tráfego será realizada após a criação do ASG.

---

