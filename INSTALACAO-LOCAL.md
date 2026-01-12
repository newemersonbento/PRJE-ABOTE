# 🚀 GUIA DE INSTALAÇÃO LOCAL - API SQL Server

## ⚡ Instalação Rápida na Sua Máquina

### Pré-requisitos

- ✅ Node.js instalado (versão 14 ou superior)
- ✅ Acesso ao SQL Server (192.168.100.14)
- ✅ Git instalado (opcional)

### 📥 Passo 1: Baixar os Arquivos da API

Você tem 2 opções:

#### Opção A: Via Git (Recomendado)

Se a API já estiver no GitHub:
```bash
git clone https://github.com/seu-usuario/webapp-api.git
cd webapp-api
```

#### Opção B: Baixar Manualmente

1. Baixe todos os arquivos de `/home/user/webapp-api/`
2. Copie para uma pasta no seu computador, exemplo:
   - Windows: `C:\projetos\webapp-api\`
   - Linux/Mac: `~/projetos/webapp-api/`

### 📦 Passo 2: Instalar Dependências

Abra o terminal/prompt na pasta da API:

```bash
# Windows (PowerShell ou CMD)
cd C:\projetos\webapp-api
npm install

# Linux/Mac
cd ~/projetos/webapp-api
npm install
```

Aguarde até instalar todas as dependências (~257 pacotes).

### ⚙️ Passo 3: Configurar o Arquivo .env

O arquivo `.env` já está configurado com suas credenciais:

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

ALLOWED_ORIGINS=http://localhost:3000,https://3000-ig1zg8d9l1gqcefs84wxz-b9b802c4.sandbox.novita.ai
```

✅ **Já está pronto!** Não precisa alterar nada.

### 🗄️ Passo 4: Criar o Schema no SQL Server

Você precisa executar o arquivo `schema.sql` no seu SQL Server.

#### Opção A: Via SQL Server Management Studio (SSMS)

1. Abra o SSMS
2. Conecte ao servidor: `192.168.100.14`
3. Selecione o banco: `ABOT`
4. Arquivo → Abrir → `schema.sql`
5. Execute (F5)

#### Opção B: Via sqlcmd

```bash
sqlcmd -S 192.168.100.14 -U abot -P New@3260 -d ABOT -i schema.sql
```

#### Opção C: Via Azure Data Studio

1. Conecte ao servidor
2. Abra o arquivo `schema.sql`
3. Execute o script

### 🧪 Passo 5: Testar a Conexão

```bash
node test-connection.js
```

✅ **Sucesso** - Você deve ver:
```
🧪 Testando conexão com SQL Server...

1️⃣ Conectando ao banco...
🔌 Conectando ao SQL Server...
✅ Conectado ao SQL Server com sucesso!
📊 Banco de dados: ABOT
🖥️  Servidor: 192.168.100.14
```

❌ **Erro?** Verifique:
- SQL Server está rodando
- Porta 1433 está aberta no firewall
- Usuário e senha corretos
- Configuração TCP/IP habilitada no SQL Server

### 🚀 Passo 6: Iniciar a API

```bash
# Iniciar em modo desenvolvimento (com auto-reload)
npm run dev

# OU iniciar em modo produção
npm start
```

Você verá:
```
🔌 Conectando ao SQL Server...
✅ Conexão com SQL Server estabelecida!
🚀 API rodando na porta 3001
🔗 Health check: http://localhost:3001/health
📊 Endpoints disponíveis em: http://localhost:3001/api/
```

### ✅ Passo 7: Testar os Endpoints

Abra outro terminal e teste:

```bash
# Health check (sem autenticação)
curl http://localhost:3001/health

# Categorias (com autenticação)
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/api/categories

# Dashboard summary
curl -H "X-API-Key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/api/dashboard/summary
```

### 🌐 Passo 8: Conectar o Portal à API

Agora você precisa configurar o portal para usar sua API local.

#### Se o Portal está no Cloudflare Pages:

O portal não conseguirá acessar `http://localhost:3001` diretamente (CORS/Segurança).

**Solução**: Use um túnel como **ngrok** ou **localtunnel**:

```bash
# Instalar ngrok
npm install -g ngrok

# Criar túnel para a porta 3001
ngrok http 3001
```

O ngrok vai te dar uma URL pública:
```
https://abc123.ngrok.io → http://localhost:3001
```

Use essa URL no portal!

#### Se o Portal está Local:

Edite o arquivo `/home/user/webapp/public/static/app.js`:

```javascript
// No início do arquivo
const API_BASE_URL = 'http://localhost:3001/api';
const API_KEY = 'webapp-api-key-2024-secure-change-in-production';
```

## 🔧 Configuração do Firewall Windows

Se o SQL Server estiver em um servidor Windows, você precisa liberar a porta 1433:

### Passo 1: Abrir o Firewall do Windows

1. Painel de Controle → Sistema e Segurança → Firewall do Windows
2. Configurações Avançadas
3. Regras de Entrada → Nova Regra

### Passo 2: Criar Regra de Entrada

1. Tipo: Porta
2. Protocolo: TCP
3. Porta: 1433
4. Ação: Permitir conexão
5. Perfil: Domínio, Privado, Público
6. Nome: SQL Server Port 1433

### Passo 3: Habilitar TCP/IP no SQL Server

1. Abra o SQL Server Configuration Manager
2. Protocolos para MSSQLSERVER
3. TCP/IP → Habilitar
4. Reinicie o serviço SQL Server

## 📊 Estrutura de Arquivos Necessários

Certifique-se de ter todos esses arquivos:

```
webapp-api/
├── server.js              ✅ Servidor principal
├── database.js            ✅ Conexão SQL Server
├── schema.sql             ✅ Schema do banco
├── test-connection.js     ✅ Teste de conexão
├── .env                   ✅ Suas credenciais
├── package.json           ✅ Dependências
├── package-lock.json      ✅ Versões fixas
└── node_modules/          ✅ (gerado após npm install)
```

## 🐛 Troubleshooting

### Erro: "Cannot find module 'express'"

```bash
npm install
```

### Erro: "ECONNREFUSED" ou "ETIMEOUT"

1. Verifique se o SQL Server está rodando
2. Verifique o firewall
3. Teste: `telnet 192.168.100.14 1433`

### Erro: "Login failed for user 'abot'"

Verifique:
1. Usuário e senha no `.env`
2. Permissões do usuário no SQL Server
3. Modo de autenticação (SQL Server Authentication)

### Erro: "Database 'ABOT' not found"

Verifique se o banco existe:
```sql
SELECT name FROM sys.databases;
```

### Erro: "Port 3001 already in use"

Mude a porta no `.env`:
```env
PORT=3002
```

## 🎯 Checklist Final

- [ ] Node.js instalado
- [ ] Arquivos da API baixados
- [ ] `npm install` executado
- [ ] Arquivo `.env` configurado
- [ ] SQL Server acessível (telnet/ping)
- [ ] Schema executado no banco
- [ ] Teste de conexão passou
- [ ] API iniciada e respondendo
- [ ] Portal configurado para usar a API

## 🎉 Pronto!

Se todos os passos acima funcionaram, sua API está rodando e conectada ao SQL Server!

Acesse: **http://localhost:3001/health**

---

**💡 Dica**: Use PM2 para manter a API rodando em background:

```bash
npm install -g pm2
pm2 start server.js --name webapp-api
pm2 logs webapp-api
pm2 restart webapp-api
pm2 stop webapp-api
```

---

**Precisa de ajuda?** Verifique os logs e me avise do erro!
