### 6️⃣ Execução das EC2 via User Data

As instâncias EC2 são iniciadas a partir de um **Launch Template** que executa o script **`userdata.sh`** no primeiro boot. Esse script automatiza a instalação de dependências, a montagem do EFS e o deploy do WordPress via Docker Compose. :contentReference[oaicite:0]{index=0}

---

#### 6.1 Variáveis configuradas no início do script

No `userdata.sh`, você define os parâmetros de conexão com o **RDS** e o identificador do **EFS**:

- `RDS_ENDPOINT` (endpoint do banco)
- `RDS_PORT` (3306)
- `DB_NAME`, `DB_USER`, `DB_PASS`
- `EFS_FS_ID` (ID do filesystem)
- `EFS_MOUNT` (ponto de montagem, ex: `/mnt/efs`) :contentReference[oaicite:1]{index=1}

> Observação: no repositório esses valores aparecem como exemplo. No uso real, substitua pelo endpoint/ID corretos do seu ambiente. :contentReference[oaicite:2]{index=2}

---

#### 6.2 Instalação automática de Docker e utilitários do EFS

O script realiza update e instala os pacotes necessários para:
- executar containers (**Docker**)
- montar o filesystem (**amazon-efs-utils**) :contentReference[oaicite:3]{index=3}

Em seguida, habilita e inicia o serviço do Docker para garantir que ele suba automaticamente. :contentReference[oaicite:4]{index=4}

---

#### 6.3 Instalação do Docker Compose

O `userdata.sh` baixa o binário do **Docker Compose** (release mais recente) e aplica permissão de execução, permitindo subir o WordPress via `docker-compose up -d`. :contentReference[oaicite:5]{index=5}

---

#### 6.4 Montagem do EFS na instância

O script:
1. cria o diretório de montagem (`/mnt/efs`)
2. monta o EFS usando **TLS**:
   - `mount -t efs -o tls ${EFS_FS_ID}:/ ${EFS_MOUNT}`
3. ajusta permissões do diretório montado (owner e modo) :contentReference[oaicite:6]{index=6}

Isso garante **persistência e compartilhamento** de arquivos do WordPress entre múltiplas instâncias do ASG. :contentReference[oaicite:7]{index=7}

---

#### 6.5 Deploy do WordPress via Docker Compose (com RDS + EFS)

O `userdata.sh` gera um `docker-compose.yml` com o serviço do WordPress e configura:

- Variáveis `WORDPRESS_DB_*` apontando para o **RDS** (`RDS_ENDPOINT:RDS_PORT`, nome do banco, usuário e senha) :contentReference[oaicite:8]{index=8}
- Volume persistente do WordPress:
  - `${EFS_MOUNT}:/var/www/html` (mantém uploads/temas/plugins no EFS) :contentReference[oaicite:9]{index=9}

Por fim, ele sobe o container com:

- `docker-compose up -d` :contentReference[oaicite:10]{index=10}

---

#### 6.6 Resultado no Auto Scaling

Quando o Auto Scaling Group cria uma nova instância:
- o User Data executa automaticamente
- a instância monta o EFS, configura o WordPress e conecta no RDS
- o ALB pode enviar tráfego assim que os health checks estiverem OK :contentReference[oaicite:11]{index=11}
