# Etapa 1 – Criação da VPC e Subnets

Nesta etapa, vamos criar a **VPC** e as **subnets** que servirão de base para toda a nossa infraestrutura.


---

## 🔹 Acessando o serviço
1. No **Console da AWS**, vá até a barra de pesquisa.
2. Digite **VPC** e clique na opção que aparecer.

---

## 🔹 Criando a VPC
1. Clique no botão **Criar VPC**.
2. Na seção **Configurações da VPC**, selecione a opção **VPC e mais**.
3. Certifique-se de deixar todas as opções iguais ao modelo abaixo:

---


📌 *Exemplo de configuração (ajuste conforme sua necessidade):*

- **Nome da VPC**: `minha-vpc`
- **Bloco CIDR IPv4**: `10.0.0.0/16`
- **Subnets públicas/privadas**: ativadas
- **NAT Gateway**: não (será configurado em outra etapa)
- **Tabela de rotas**: padrão

---



> 🖼️ **Observação:** confira a imagem abaixo antes de continuar para garantir que as opções estão corretas:  
<img width="1446" height="775" alt="image" src="https://github.com/user-attachments/assets/8d3a3256-5515-4b86-a8a2-d24ee2e45b30" />


---

✅ Agora você terá a sua **VPC** criada junto com as **subnets** definidas automaticamente pela AWS.



# Etapa 2 – Criação dos NAT Gateway e Configuração de Tabelas de Rotas

Nesta etapa, vamos criar os **NAT Gateway** e configurar as **tabelas de rotas** que servirão como rota de saída para as instâncias que estão em **subnets privadas**.


---
# Etapa 2 – Criação dos NAT Gateways (Alta Disponibilidade) e Configuração de Tabelas de Rotas

Nesta etapa, vamos criar **dois NAT Gateways** em **subnets públicas de AZs diferentes**, garantindo **alta disponibilidade**.  
Depois, vamos configurar as **tabelas de rotas** das **subnets privadas** para que usem o NAT Gateway da mesma AZ.

# Etapa 2 – Criação dos NAT Gateways (Alta Disponibilidade) e Configuração de Tabelas de Rotas

> ℹ️ **Observação sobre AZs (Availability Zones):**  
> As **Availability Zones (AZs)** são zonas de disponibilidade dentro de uma **região da AWS**.  
> Cada AZ é basicamente um **data center físico separado**, com energia, rede e conectividade independentes.  
>  
> Exemplo na região **us-east-1 (N. Virginia):**  
> - **us-east-1a**  
> - **us-east-1b**  
> - **us-east-1c**  
> - (existem mais, mas usaremos apenas duas neste tutorial)  
>  
> ✅ Neste projeto, vamos utilizar:  
> - **AZ1 → us-east-1a** (onde ficará uma subnet pública e uma subnet privada)  
> - **AZ2 → us-east-1b** (onde ficará outra subnet pública e outra subnet privada)  
>  
> Cada subnet privada terá sua rota de saída pela Internet utilizando um **NAT Gateway** localizado na mesma AZ. Isso garante **alta disponibilidade**: se uma AZ tiver problemas, a outra continua funcionando.


---

## 🔹 Acessando o serviço
1. No **Console da AWS**, vá até a barra de pesquisa.
2. Digite **VPC** e clique na opção que aparecer.
3. No painel lateral, clique em **NAT Gateway**.

 <img width="1919" height="944" alt="image" src="https://github.com/user-attachments/assets/124e90a6-d93e-4810-aba8-5001b9de0270" />
   
---

## 🔹 Criando os NAT Gateways
### NAT Gateway 1
1. Clique em **Criar NAT Gateway**.
2. Configure:
   - **Nome**: `nat-gateway-az1`
   - **Sub-rede**: escolha uma **subnet pública da AZ1**. 
   - **Elastic IP**: clique em **Alocar Elastic IP**.
3. Clique em **Criar NAT Gateway**.

### NAT Gateway 2
1. Novamente, clique em **Criar NAT Gateway**.
2. Configure:
   - **Nome**: `nat-gateway-az2`
   - **Sub-rede**: escolha uma **subnet pública da AZ2**.
   - **Elastic IP**: clique em **Alocar Elastic IP**.
3. Clique em **Criar NAT Gateway**.

> ⚠️ Aguarde até que ambos os NAT Gateways fiquem no status **Disponível**.

---

## 🔹 Configurando as Tabelas de Rotas
Agora vamos garantir que **cada subnet privada** use o NAT Gateway correspondente à sua AZ.

### Rota para Subnet Privada na AZ1
1. No painel lateral da VPC, clique em **Tabelas de Rotas**.
2. Selecione a **tabela de rotas da subnet privada da AZ1**.
3. Clique em **Editar rotas** > **Adicionar rota**:
   - **Destino**: `0.0.0.0/0`
   - **Encaminhar para**: `nat-gateway-az1`
4. Clique em **Salvar alterações**.

### Rota para Subnet Privada na AZ2
1. No painel lateral da VPC, clique em **Tabelas de Rotas**.
2. Selecione a **tabela de rotas da subnet privada da AZ2**.
3. Clique em **Editar rotas** > **Adicionar rota**:
   - **Destino**: `0.0.0.0/0`
   - **Encaminhar para**: `nat-gateway-az2`
4. Clique em **Salvar alterações**.

---

✅ Agora você tem **dois NAT Gateways configurados em AZs diferentes**, com rotas corretamente associadas para manter a disponibilidade do ambiente.

--- 
## 📡 Estrutura do Projeto  


### Para auxílio, nas configurações abaixo, há uma tabela de sub-redes e NAT Gateway.
> 📝 **Nota:** Os nomes utilizados são apenas exemplos. Eles são **indiferentes** e podem ser **trocados a qualquer momento**.  

---

### 📥 Informações das Sub-redes  

| **AZ**       | **Tipo**   | **Nome**               | **Motivo**                                                                 |
|--------------|------------|------------------------|-----------------------------------------------------------------------------|
| us-east-1a   | Pública    | NAT-Bastion-subnet     | Ter acesso à EC2 em subnet privada e colocar o NAT Gateway da AZ1           |
| us-east-1a   | Privada    | EC2-1-subnet-private   | Alocar a EC2-1 em subnet privada                                            |
| us-east-1a   | Privada    | EFS-1-subnet-private   | Alocar um mount target do EFS para comunicação com a EC2                    |
| us-east-1b   | Pública    | NAT-subnet-public2     | NAT Gateway para a EC2 ter acesso à internet                                |
| us-east-1b   | Privada    | EC2-2-subnet-private   | Alocar a EC2-2 em subnet privada                                            |
| us-east-1b   | Privada    | EFS-2-subnet-private   | Alocar um mount target do EFS para comunicação com a EC2                    |

> ⚡ **Mini tutorial:** Depois de criar as **subnets**, precisamos criar os **NAT Gateways**, dividindo-os nas 2 AZs.  

---

### 📥 Informações dos NAT Gateways  

| **AZ**       | **Sub-rede**            | **Nome**              | **Motivo**                                                                 |
|--------------|-------------------------|-----------------------|-----------------------------------------------------------------------------|
| us-east-1a   | Pública                 | NAT-Bastion-subnet    | Para alocar na tabela de rotas da EC2-1-subnet-private, permitindo comunicação externa |
| us-east-1b   | Pública                 | NAT-subnet-public2    | Para alocar na tabela de rotas da EC2-2-subnet-private, permitindo comunicação externa |
