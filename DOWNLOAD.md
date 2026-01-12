# 📥 DOWNLOAD E INSTALAÇÃO - API SQL Server

## 🎯 Arquivo Pronto para Download

✅ **webapp-api-completo.tar.gz** (43 KB)  
📍 Localização: `/home/user/webapp-api-completo.tar.gz`

## 📦 O que está incluído:

```
webapp-api-completo.tar.gz
│
├── server.js                    # ✅ Servidor Express
├── database.js                  # ✅ Conexão SQL Server
├── schema.sql                   # ✅ Schema 11 tabelas
├── test-connection.js           # ✅ Teste de conexão
├── .env                         # ✅ Suas credenciais já configuradas
├── .env.example                 # ✅ Template
├── .gitignore                   # ✅ Proteção Git
├── package.json                 # ✅ Dependências
├── package-lock.json            # ✅ Versões fixas
├── README.md                    # ✅ Documentação técnica
├── INSTRUCOES.md                # ✅ Guia passo a passo
├── CREDENCIAIS-EXEMPLO.md       # ✅ Exemplos
├── STATUS.md                    # ✅ Status do projeto
└── INSTALACAO-LOCAL.md          # ✅ Guia de instalação
```

**Total**: 13 arquivos + documentação completa

## 🚀 Instalação em 5 Passos

### 1️⃣ Baixar o Arquivo

**Opção A: Via Sandbox (se tiver acesso)**
```bash
# Na sua máquina local
scp user@sandbox:/home/user/webapp-api-completo.tar.gz ~/Downloads/
```

**Opção B: Via Git**
Se você fizer push para o GitHub, pode clonar depois:
```bash
git clone https://github.com/seu-usuario/webapp-api.git
```

**Opção C: Copiar arquivos manualmente**
Copie todos os arquivos de `/home/user/webapp-api/` para sua máquina.

### 2️⃣ Extrair os Arquivos

**Windows (PowerShell):**
```powershell
# Extrair (você pode usar 7-Zip também)
tar -xzf webapp-api-completo.tar.gz
cd webapp-api
```

**Linux/Mac:**
```bash
tar -xzf webapp-api-completo.tar.gz
cd webapp-api
```

### 3️⃣ Instalar Dependências

```bash
npm install
```

Isso vai instalar:
- express
- mssql
- cors
- dotenv
- helmet
- express-rate-limit
- nodemon (dev)

**Total**: ~257 pacotes

### 4️⃣ Criar Tabelas no SQL Server

**Via SSMS (SQL Server Management Studio):**
1. Conecte ao servidor: `192.168.100.14`
2. Banco: `ABOT`
3. Abra o arquivo `schema.sql`
4. Execute (F5)

**Via sqlcmd:**
```bash
sqlcmd -S 192.168.100.14 -U abot -P New@3260 -d ABOT -i schema.sql
```

### 5️⃣ Iniciar a API

```bash
# Testar conexão primeiro
node test-connection.js

# Se passou, iniciar API
npm start
```

✅ **Pronto!** API rodando em `http://localhost:3001`

## 🧪 Testar se está Funcionando

Abra outro terminal:

```bash
# Health check
curl http://localhost:3001/health

# Deve retornar:
{
  "status": "ok",
  "database": "connected",
  "timestamp": "2024-01-12T15:30:00.000Z"
}

# Testar categorias (com API Key)
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" \
     http://localhost:3001/api/categories
```

## 📊 Credenciais Já Configuradas

O arquivo `.env` já vem configurado com suas credenciais:

```env
DB_SERVER=192.168.100.14
DB_PORT=1433
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true

PORT=3001
NODE_ENV=development

API_KEY=webapp-api-key-2024-secure-change-in-production
```

✅ **Não precisa alterar nada!**

⚠️ **IMPORTANTE**: Em produção, mude a `API_KEY` para algo mais seguro!

## 🔗 Conectar o Portal à API

### Portal Local (localhost)

Se você rodar o portal localmente, edite `public/static/app.js`:

```javascript
// Configuração no início do arquivo
const API_BASE_URL = 'http://localhost:3001/api';
const API_KEY = 'webapp-api-key-2024-secure-change-in-production';

// Função fetchAPI
async function fetchAPI(endpoint, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    'X-API-Key': API_KEY,
    ...options.headers
  };
  
  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers
  });
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  
  return response.json();
}
```

### Portal em Produção (Cloudflare Pages)

Você precisa expor a API via **ngrok** ou **localtunnel**:

```bash
# Instalar ngrok
npm install -g ngrok

# Expor a porta 3001
ngrok http 3001

# Você receberá uma URL pública:
# https://abc123.ngrok.io
```

Use essa URL no portal:
```javascript
const API_BASE_URL = 'https://abc123.ngrok.io/api';
```

## 🐳 Manter a API Rodando (PM2)

Para que a API fique rodando em background:

```bash
# Instalar PM2
npm install -g pm2

# Iniciar
pm2 start server.js --name webapp-api

# Ver logs
pm2 logs webapp-api

# Reiniciar
pm2 restart webapp-api

# Parar
pm2 stop webapp-api

# Status
pm2 list
```

## 📁 Estrutura de Pastas

Após extrair e instalar:

```
webapp-api/
├── 📄 Arquivos principais
│   ├── server.js              (Servidor Express)
│   ├── database.js            (Conexão SQL Server)
│   ├── schema.sql             (Schema 11 tabelas)
│   └── test-connection.js     (Teste)
│
├── ⚙️ Configuração
│   ├── .env                   (Suas credenciais)
│   ├── .gitignore             (Proteção Git)
│   ├── package.json
│   └── package-lock.json
│
├── 📚 Documentação
│   ├── README.md              (Docs técnicos)
│   ├── INSTRUCOES.md          (Guia passo a passo)
│   ├── INSTALACAO-LOCAL.md    (Este arquivo)
│   ├── CREDENCIAIS-EXEMPLO.md
│   └── STATUS.md
│
└── 📦 node_modules/           (Gerado após npm install)
```

## ❓ Problemas Comuns

### "Cannot find module 'express'"
```bash
npm install
```

### "ECONNREFUSED" ou "ETIMEOUT"
1. SQL Server está rodando?
2. Firewall liberado na porta 1433?
3. Teste: `telnet 192.168.100.14 1433`

### "Login failed"
Verifique usuário e senha no `.env`

### "Port 3001 already in use"
Mude a porta no `.env`:
```env
PORT=3002
```

## 🎯 Checklist de Instalação

- [ ] Arquivo baixado e extraído
- [ ] Node.js instalado (v14+)
- [ ] `npm install` executado
- [ ] SQL Server acessível
- [ ] Schema executado no banco
- [ ] Teste de conexão passou
- [ ] API iniciada
- [ ] Health check respondendo
- [ ] Portal configurado

## 📞 Suporte

Se tiver problemas:

1. Verifique os logs: `npm start` ou `pm2 logs webapp-api`
2. Teste a conexão: `node test-connection.js`
3. Verifique o firewall
4. Consulte `INSTRUCOES.md` para troubleshooting detalhado

## 🎉 Próximos Passos

Depois que a API estiver rodando:

1. ✅ Testar todos os endpoints
2. ✅ Conectar o portal
3. ✅ Popular o banco com dados
4. ✅ Configurar em produção
5. ✅ Fazer backup do banco

---

**🚀 Boa sorte com a instalação!**

Se precisar de ajuda, consulte os outros arquivos de documentação ou entre em contato.

---

**Versão**: 1.0.0  
**Data**: 2024-01-12  
**Servidor**: 192.168.100.14  
**Banco**: ABOT
