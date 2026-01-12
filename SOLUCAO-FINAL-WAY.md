# 🎯 SOLUÇÃO FINAL - VPN Way Brasil

## ⚠️ Situação Identificada

**Resultado dos Testes:**
- ❌ DNS `vpn2.way306.com.br` não resolve (rede corporativa isolada)
- ❌ Porta 443 inacessível
- ❌ SQL Server 192.168.100.14:1433 inacessível

**Conclusão:** O sandbox Cloudflare **NÃO consegue** acessar a rede corporativa Way Brasil diretamente.

---

## ✅ SOLUÇÃO RECOMENDADA: Rodar API Localmente

Como você tem **VPN corporativa configurada**, a melhor solução é:

### **🏢 Rodar a API na Sua Máquina Local**

```
┌─────────────────────────────────────────────────────────┐
│                    ARQUITETURA                           │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  [Sua Máquina] ──VPN──> [Way Brasil Network]             │
│       │                       │                           │
│       │                       └──> [SQL Server]           │
│       │                            192.168.100.14:1433    │
│       │                                                    │
│       └──> [API Node.js]                                  │
│            Porta 3001                                     │
│                │                                          │
│                └──> [Expor via ngrok]                     │
│                     https://abc.ngrok.io                  │
│                                                           │
│  [Frontend Cloudflare Pages] ──> [ngrok URL] ──> [API]   │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 GUIA PASSO A PASSO COMPLETO

### **📦 Passo 1: Preparar Sua Máquina**

#### **Windows:**

```powershell
# 1. Verificar Node.js instalado
node --version

# Se não tiver, baixe: https://nodejs.org/

# 2. Verificar conectividade VPN
# Abra o cliente VPN e conecte com:
# - Servidor: vpn2.way306.com.br:443
# - Usuário: way306\emerson.totvs
# - Senha: waybrasil2025@

# 3. Após conectar, testar SQL Server
Test-NetConnection -ComputerName 192.168.100.14 -Port 1433
```

#### **Linux/Mac:**

```bash
# 1. Verificar Node.js
node --version

# Se não tiver:
# Linux: sudo apt install nodejs npm
# Mac: brew install node

# 2. Conectar VPN (use o cliente instalado)

# 3. Testar SQL Server
telnet 192.168.100.14 1433
# ou
nc -zv 192.168.100.14 1433
```

---

### **📥 Passo 2: Baixar e Extrair a API**

```bash
# Baixar o pacote do sandbox
# Localização: /home/user/webapp-api-completo-vpn.tar.gz

# Extrair
tar -xzf webapp-api-completo-vpn.tar.gz
cd webapp-api
```

---

### **⚙️ Passo 3: Instalar Dependências**

```bash
# Instalar pacotes Node.js
npm install

# Verificar instalação
npm list --depth=0
```

---

### **🗄️ Passo 4: Aplicar Schema no SQL Server**

#### **Via SQL Server Management Studio (SSMS):**

1. **Abrir SSMS**
2. **Conectar ao servidor:**
   - **Server name:** 192.168.100.14
   - **Authentication:** SQL Server Authentication
   - **Login:** abot
   - **Password:** New@3260

3. **Executar scripts:**
   ```sql
   -- Selecionar banco de dados
   USE ABOT;
   GO
   
   -- Executar schema.sql (copiar e colar todo o conteúdo)
   -- Depois executar seed.sql
   ```

4. **Verificar criação:**
   ```sql
   -- Listar tabelas
   SELECT TABLE_NAME 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_TYPE = 'BASE TABLE'
   ORDER BY TABLE_NAME;
   
   -- Deve mostrar 13 tabelas
   ```

---

### **🔧 Passo 5: Configurar Variáveis de Ambiente**

```bash
# Criar arquivo .env
cat > .env << 'EOF'
# SQL Server (via VPN Way Brasil)
DB_SERVER=192.168.100.14
DB_PORT=1433
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true

# API
PORT=3001
NODE_ENV=production
API_KEY=webapp-api-key-2024-secure-change-in-production

# CORS - Permitir frontend Cloudflare Pages
ALLOWED_ORIGINS=http://localhost:3000,https://3000-ig1zg8d9l1gqcefs84wxz-b9b802c4.sandbox.novita.ai,https://webapp.pages.dev
EOF

# Proteger arquivo
chmod 600 .env
```

---

### **🧪 Passo 6: Testar Conexão SQL**

```bash
# Testar conexão com o banco
node test-connection.js
```

**Saída esperada:**
```
🔍 Testando conexão com SQL Server...
Servidor: 192.168.100.14:1433
Banco de Dados: ABOT

✅ Conexão bem-sucedida!
📊 Resultado do teste: [{"test":1}]
```

Se der erro, verificar:
- ✅ VPN conectada?
- ✅ SQL Server aceita conexões TCP/IP?
- ✅ Credenciais corretas?
- ✅ Firewall do SQL Server configurado?

---

### **▶️ Passo 7: Iniciar a API**

#### **Modo Desenvolvimento (com logs):**

```bash
npm start
```

#### **Modo Produção (com PM2):**

```bash
# Instalar PM2 globalmente (uma vez)
npm install -g pm2

# Iniciar API
pm2 start ecosystem.config.cjs

# Verificar status
pm2 status

# Ver logs
pm2 logs webapp-api --lines 50

# Salvar configuração para auto-start
pm2 save
pm2 startup
```

---

### **✅ Passo 8: Testar Endpoints**

```bash
# Testar health
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" \
  http://localhost:3001/health

# Testar categorias
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" \
  http://localhost:3001/api/categories

# Testar indicadores
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" \
  http://localhost:3001/api/indicators

# Testar dashboard
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" \
  http://localhost:3001/api/dashboard/summary
```

---

### **🌐 Passo 9: Expor API para o Frontend (ngrok)**

Para que o frontend no Cloudflare Pages acesse a API na sua máquina:

```bash
# 1. Criar conta ngrok (grátis)
# https://dashboard.ngrok.com/signup

# 2. Baixar ngrok
# Windows: https://ngrok.com/download
# Linux: wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
# Mac: brew install ngrok

# 3. Autenticar (copiar authtoken do dashboard)
ngrok config add-authtoken <SEU_AUTHTOKEN>

# 4. Expor API
ngrok http 3001

# Saída:
# Forwarding  https://abc123.ngrok.io -> http://localhost:3001
```

**⚠️ Anote a URL ngrok:** `https://abc123.ngrok.io`

---

### **🔗 Passo 10: Conectar Frontend à API**

No frontend (Cloudflare Pages), atualize para usar a URL ngrok:

```javascript
// No arquivo de configuração do frontend
const API_BASE_URL = 'https://abc123.ngrok.io';  // URL do ngrok
const API_KEY = 'webapp-api-key-2024-secure-change-in-production';

// Exemplo de chamada
axios.get(`${API_BASE_URL}/api/categories`, {
  headers: {
    'x-api-key': API_KEY
  }
})
.then(response => {
  console.log('Categorias:', response.data);
})
.catch(error => {
  console.error('Erro:', error);
});
```

---

## 📋 Checklist Completo

### **Preparação:**
- [ ] Node.js instalado (v16+)
- [ ] Cliente VPN Way Brasil instalado
- [ ] Conectado à VPN (`vpn2.way306.com.br:443`)
- [ ] SQL Server acessível (teste: `telnet 192.168.100.14 1433`)

### **Setup API:**
- [ ] Pacote `webapp-api-completo-vpn.tar.gz` baixado
- [ ] Dependências instaladas (`npm install`)
- [ ] Schema aplicado no SQL Server (`schema.sql`)
- [ ] Seed aplicado no SQL Server (`seed.sql`)
- [ ] Arquivo `.env` configurado
- [ ] Teste de conexão OK (`node test-connection.js`)
- [ ] API iniciada (`npm start` ou `pm2 start`)

### **Exposição (ngrok):**
- [ ] ngrok instalado
- [ ] ngrok autenticado
- [ ] Túnel criado (`ngrok http 3001`)
- [ ] URL ngrok anotada

### **Integração Frontend:**
- [ ] Frontend atualizado com URL ngrok
- [ ] Header `x-api-key` configurado
- [ ] CORS permitindo origem do frontend

### **Validação:**
- [ ] Endpoint `/health` respondendo
- [ ] Endpoint `/api/categories` retorna 8 categorias
- [ ] Endpoint `/api/indicators` retorna 25 indicadores
- [ ] Frontend consegue fazer requisições

---

## 🎯 Comandos Úteis

### **VPN:**
```bash
# Verificar conexão VPN (Windows)
ipconfig | findstr "VPN"

# Testar SQL Server
Test-NetConnection -ComputerName 192.168.100.14 -Port 1433
```

### **API:**
```bash
# Ver logs em tempo real
pm2 logs webapp-api

# Reiniciar API
pm2 restart webapp-api

# Parar API
pm2 stop webapp-api

# Remover do PM2
pm2 delete webapp-api

# Ver status
pm2 status
```

### **ngrok:**
```bash
# Iniciar túnel
ngrok http 3001

# Ver status (outro terminal)
curl http://localhost:4040/api/tunnels

# Parar (Ctrl+C)
```

---

## 🐛 Troubleshooting

### **Problema: VPN não conecta**

```bash
# Verificar credenciais
# Usuário: way306\emerson.totvs
# Senha: waybrasil2025@

# Verificar firewall
# Windows: Desabilitar temporariamente Windows Defender Firewall

# Verificar logs do cliente VPN
```

### **Problema: SQL Server não responde**

```bash
# 1. Verificar se está conectado à VPN
ping 192.168.100.14

# 2. Verificar porta SQL
telnet 192.168.100.14 1433

# 3. Verificar SQL Server aceita conexões remotas
# No SQL Server: SQL Server Configuration Manager
# → SQL Server Network Configuration
# → Protocols for MSSQLSERVER
# → TCP/IP: Enabled

# 4. Verificar firewall do SQL Server
# Porta 1433 deve estar aberta
```

### **Problema: API retorna erro de conexão**

```bash
# Ver logs detalhados
pm2 logs webapp-api --err

# Testar conexão diretamente
node test-connection.js

# Verificar .env
cat .env

# Aumentar timeout (database.js)
connectionTimeout: 30000,
requestTimeout: 30000
```

### **Problema: Frontend não acessa API**

```bash
# 1. Verificar ngrok rodando
curl http://localhost:4040/api/tunnels

# 2. Testar endpoint via ngrok
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" \
  https://abc123.ngrok.io/health

# 3. Verificar CORS no .env
# ALLOWED_ORIGINS deve incluir origem do frontend

# 4. Verificar header x-api-key no frontend
console.log(headers)
```

---

## 💡 Dicas de Produção

### **Manter ngrok URL Fixa:**

Upgrade para plano pago (USD $10/mês):
- URL fixa (não muda ao reiniciar)
- Domínio customizado
- Sem timeout

### **Alternativa ao ngrok:**

Configurar **Cloudflare Tunnel** na sua máquina:
- Gratuito
- URL fixa
- Mais seguro
- Veja: `TUNNEL-CLOUDFLARE.md`

### **Auto-start API (Windows):**

```powershell
# Criar tarefa agendada para iniciar PM2
pm2 startup
pm2 save
```

### **Monitoramento:**

```bash
# PM2 Monit (dashboard terminal)
pm2 monit

# Ver métricas
pm2 status

# Ver uso de memória
pm2 describe webapp-api
```

---

## 📊 Arquitetura Final

```
┌─────────────────────────────────────────────────────────┐
│                  USUÁRIO FINAL                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│        Frontend (Cloudflare Pages)                       │
│        https://webapp.pages.dev                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ HTTPS
                     ▼
┌─────────────────────────────────────────────────────────┐
│               ngrok Tunnel                               │
│        https://abc123.ngrok.io                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│         Sua Máquina (conectada via VPN)                  │
│                                                           │
│  ┌────────────────────────────────────────────────┐    │
│  │  API Node.js (PM2)                              │    │
│  │  http://localhost:3001                          │    │
│  │  • 35 endpoints REST                            │    │
│  │  • Autenticação API Key                         │    │
│  │  • Rate limiting                                 │    │
│  └──────────────┬─────────────────────────────────┘    │
│                 │                                        │
│                 │ VPN Way Brasil                         │
│                 │ (vpn2.way306.com.br:443)              │
│                 │                                        │
│                 ▼                                        │
│  ┌────────────────────────────────────────────────┐    │
│  │  Rede Corporativa Way Brasil                    │    │
│  │                                                  │    │
│  │    ┌──────────────────────────────────┐       │    │
│  │    │  SQL Server                       │       │    │
│  │    │  192.168.100.14:1433             │       │    │
│  │    │  Database: ABOT                   │       │    │
│  │    │  • 13 tabelas                     │       │    │
│  │    │  • 35 índices                     │       │    │
│  │    │  • 9 triggers                     │       │    │
│  │    └──────────────────────────────────┘       │    │
│  │                                                  │    │
│  └──────────────────────────────────────────────────┘    │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Próximos Passos

1. ✅ **Conectar à VPN Way Brasil** na sua máquina
2. ✅ **Aplicar schema** no SQL Server (SSMS)
3. ✅ **Configurar e iniciar** a API localmente
4. ✅ **Expor com ngrok** para acesso do frontend
5. ✅ **Atualizar frontend** com URL ngrok
6. ✅ **Testar integração** end-to-end
7. ✅ **Monitorar** logs e performance

---

## 🆘 Precisa de Ajuda?

- **VPN:** Contate TI Way Brasil para suporte
- **SQL Server:** Verifique permissões e firewall
- **API:** Veja logs com `pm2 logs webapp-api`
- **ngrok:** Consulte documentação em https://ngrok.com/docs

---

**🎯 Tudo pronto! Agora é só executar o passo a passo acima!** 🚀
