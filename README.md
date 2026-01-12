# 🌉 API Bridge - SQL Server para Portal de Indicadores

API REST em Node.js + Express que conecta o Portal de Indicadores (Cloudflare Pages) ao SQL Server.

## 📋 Arquitetura

```
Portal (Cloudflare Pages)
    ↓ HTTPS
API Node.js (Express)
    ↓ TDS Protocol
SQL Server
```

## 🚀 Configuração Rápida

### 1. Instalar Dependências

```bash
cd /home/user/webapp-api
npm install
```

### 2. Configurar Variáveis de Ambiente

Copie o arquivo `.env.example` para `.env`:

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais do SQL Server:

```env
# SQL Server Configuration
DB_SERVER=seu-servidor.database.windows.net
DB_PORT=1433
DB_DATABASE=nome_do_banco
DB_USER=usuario
DB_PASSWORD=senha
DB_ENCRYPT=true
DB_TRUST_CERTIFICATE=false

# API Configuration
PORT=3001
NODE_ENV=development

# Security
API_KEY=sua_chave_secreta_aqui_mude_isso

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://webapp.pages.dev
```

### 3. Criar Schema no SQL Server

Execute o script `schema.sql` no seu SQL Server:

```bash
sqlcmd -S seu-servidor.database.windows.net -U usuario -P senha -d nome_do_banco -i schema.sql
```

Ou copie o conteúdo de `schema.sql` e execute no SQL Server Management Studio.

### 4. Testar Conexão

```bash
node test-connection.js
```

Você deve ver:

```
✅ Conectado ao SQL Server com sucesso!
📊 Banco de dados: nome_do_banco
🖥️  Servidor: seu-servidor.database.windows.net
```

### 5. Iniciar API

```bash
# Desenvolvimento
npm run dev

# Produção
npm start
```

A API estará rodando em: **http://localhost:3001**

## 📡 Endpoints da API

### Health Check

```bash
GET /health
```

Resposta:
```json
{
  "status": "ok",
  "database": "connected",
  "timestamp": "2024-01-12T14:30:00.000Z"
}
```

### Categorias

```bash
# Listar todas
GET /api/categories
Headers: X-API-Key: sua_chave_secreta

# Buscar por ID
GET /api/categories/:id
Headers: X-API-Key: sua_chave_secreta
```

### Indicadores

```bash
# Listar todos
GET /api/indicators
Headers: X-API-Key: sua_chave_secreta

# Buscar por ID (com histórico)
GET /api/indicators/:id
Headers: X-API-Key: sua_chave_secreta

# Indicadores por categoria
GET /api/categories/:id/indicators
Headers: X-API-Key: sua_chave_secreta

# Atualizar valor
POST /api/indicators/:id/update
Headers: 
  X-API-Key: sua_chave_secreta
  Content-Type: application/json
Body:
{
  "value": 150,
  "notes": "Observação sobre a atualização"
}
```

### Dashboard

```bash
GET /api/dashboard/summary
Headers: X-API-Key: sua_chave_secreta
```

### Chamados

```bash
# Listar todos
GET /api/tickets
Headers: X-API-Key: sua_chave_secreta

# Filtrar por status
GET /api/tickets?status=open
Headers: X-API-Key: sua_chave_secreta
```

### Projetos

```bash
GET /api/projects
Headers: X-API-Key: sua_chave_secreta
```

### Ativos de TI

```bash
# Listar todos
GET /api/assets
Headers: X-API-Key: sua_chave_secreta

# Filtrar por status
GET /api/assets?status=active
Headers: X-API-Key: sua_chave_secreta
```

### Backups

```bash
GET /api/backups
Headers: X-API-Key: sua_chave_secreta
```

### Links de Rede

```bash
GET /api/network-links
Headers: X-API-Key: sua_chave_secreta
```

### Recursos

```bash
GET /api/resources
Headers: X-API-Key: sua_chave_secreta
```

## 🔐 Segurança

A API implementa várias camadas de segurança:

1. **Helmet.js** - Headers de segurança HTTP
2. **CORS** - Controle de origem cruzada
3. **Rate Limiting** - Máximo 100 requisições por IP a cada 15 minutos
4. **API Key** - Autenticação via header `X-API-Key`
5. **SQL Injection Protection** - Prepared statements com parâmetros
6. **Connection Pooling** - Conexões gerenciadas e limitadas

## 🧪 Testar com cURL

```bash
# Health check (sem autenticação)
curl http://localhost:3001/health

# Categorias (com autenticação)
curl -H "X-API-Key: sua_chave_secreta" http://localhost:3001/api/categories

# Indicadores
curl -H "X-API-Key: sua_chave_secreta" http://localhost:3001/api/indicators

# Dashboard
curl -H "X-API-Key: sua_chave_secreta" http://localhost:3001/api/dashboard/summary

# Atualizar indicador
curl -X POST \
  -H "X-API-Key: sua_chave_secreta" \
  -H "Content-Type: application/json" \
  -d '{"value": 150, "notes": "Teste via cURL"}' \
  http://localhost:3001/api/indicators/1/update
```

## 🐳 Deploy com PM2

```bash
# Instalar PM2 (se necessário)
npm install -g pm2

# Iniciar API
pm2 start server.js --name webapp-api

# Ver logs
pm2 logs webapp-api --nostream

# Reiniciar
pm2 restart webapp-api

# Parar
pm2 stop webapp-api

# Status
pm2 list
```

## 📦 Estrutura do Projeto

```
webapp-api/
├── server.js            # Servidor Express principal
├── database.js          # Módulo de conexão SQL Server
├── schema.sql           # Schema do banco de dados
├── test-connection.js   # Script de teste de conexão
├── .env                 # Variáveis de ambiente (NÃO COMMITAR)
├── .env.example         # Template de variáveis
├── package.json         # Dependências Node.js
└── README.md           # Esta documentação
```

## 🔄 Integração com o Portal

Para conectar o portal ao SQL Server via esta API:

1. **Configurar variável de ambiente no portal**:
   ```bash
   # No diretório /home/user/webapp
   echo "VITE_API_URL=http://localhost:3001" >> .env
   echo "VITE_API_KEY=sua_chave_secreta" >> .env
   ```

2. **Atualizar chamadas API no frontend** (`public/static/app.js`):
   ```javascript
   const API_URL = 'http://localhost:3001';
   const API_KEY = 'sua_chave_secreta';
   
   async function fetchData(endpoint) {
     const response = await fetch(`${API_URL}${endpoint}`, {
       headers: {
         'X-API-Key': API_KEY
       }
     });
     return response.json();
   }
   ```

3. **Testar conexão**:
   ```bash
   # Iniciar API
   cd /home/user/webapp-api
   npm start
   
   # Em outro terminal, iniciar portal
   cd /home/user/webapp
   npm run build
   pm2 restart webapp
   ```

## ❓ Troubleshooting

### Erro: "Cannot connect to SQL Server"

1. Verificar credenciais no `.env`
2. Verificar se o SQL Server está acessível (firewall)
3. Testar conexão: `node test-connection.js`

### Erro: "API Key inválida"

Certifique-se de enviar o header `X-API-Key` com o valor correto do `.env`.

### Erro: CORS

Adicione o domínio do portal em `ALLOWED_ORIGINS` no `.env`:
```env
ALLOWED_ORIGINS=http://localhost:3000,https://webapp.pages.dev,https://seu-dominio.com
```

### Erro: "Too many requests"

O rate limit está ativo. Aguarde 15 minutos ou ajuste em `server.js`:
```javascript
max: 1000, // aumentar limite
```

## 📊 Migração de Dados

Se você já tem dados no D1 (SQLite local) e quer migrar para SQL Server:

1. Exportar dados do D1:
   ```bash
   cd /home/user/webapp
   npx wrangler d1 export DB --local --output=data.sql
   ```

2. Converter SQLite para SQL Server (manual)
3. Importar no SQL Server

## 🚀 Próximos Passos

- [ ] Configurar suas credenciais do SQL Server no `.env`
- [ ] Executar o schema no SQL Server
- [ ] Testar a conexão
- [ ] Iniciar a API
- [ ] Integrar com o portal
- [ ] Deploy em produção

## 📞 Suporte

Se precisar de ajuda:

1. Verifique os logs: `pm2 logs webapp-api --nostream`
2. Teste a conexão: `node test-connection.js`
3. Verifique o health check: `curl http://localhost:3001/health`

---

**Versão**: 1.0.0  
**Última atualização**: 2026-01-12
