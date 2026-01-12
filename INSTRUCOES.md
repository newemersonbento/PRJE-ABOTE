# 🎯 INSTRUÇÕES PARA CONECTAR AO SQL SERVER

## ⚙️ Configuração Passo a Passo

### 📝 1. Coletar Informações do SQL Server

Antes de começar, você precisa ter em mãos:

- **Servidor**: Endereço do servidor SQL Server
  - Exemplo Azure: `meu-servidor.database.windows.net`
  - Exemplo local: `localhost` ou `192.168.1.100`
  
- **Porta**: Geralmente `1433` (padrão SQL Server)

- **Banco de dados**: Nome do banco de dados
  - Exemplo: `IndicadoresDB`

- **Usuário**: Nome de usuário SQL Server
  - Exemplo: `sa` ou `admin`

- **Senha**: Senha do usuário

- **Tipo de autenticação**:
  - SQL Server Authentication (usuário/senha)
  - Windows Authentication (Active Directory)
  - Azure Active Directory

### 🔧 2. Configurar o Arquivo `.env`

1. Navegue até a pasta da API:
   ```bash
   cd /home/user/webapp-api
   ```

2. Copie o arquivo de exemplo:
   ```bash
   cp .env.example .env
   ```

3. Edite o arquivo `.env` com suas credenciais:
   ```bash
   nano .env
   ```
   ou
   ```bash
   vi .env
   ```

4. Preencha os valores:
   ```env
   # SQL Server Configuration
   DB_SERVER=SEU_SERVIDOR_AQUI          # Ex: meu-servidor.database.windows.net
   DB_PORT=1433                          # Porta padrão
   DB_DATABASE=SEU_BANCO_AQUI           # Ex: IndicadoresDB
   DB_USER=SEU_USUARIO_AQUI             # Ex: admin
   DB_PASSWORD=SUA_SENHA_AQUI           # Sua senha
   DB_ENCRYPT=true                       # true para Azure, pode ser false para local
   DB_TRUST_CERTIFICATE=false            # false é mais seguro

   # API Configuration
   PORT=3001                             # Porta da API
   NODE_ENV=development                  # development ou production

   # Security
   API_KEY=MUDE_ESTA_CHAVE_SECRETA      # Crie uma chave forte

   # CORS - Permitir apenas seu domínio
   ALLOWED_ORIGINS=http://localhost:3000,https://webapp.pages.dev
   ```

### 🗄️ 3. Criar as Tabelas no SQL Server

Você precisa executar o script `schema.sql` no seu SQL Server.

#### Opção A: Via SQL Server Management Studio (SSMS)

1. Abra o SSMS e conecte ao servidor
2. Abra o arquivo `schema.sql`
3. Selecione o banco de dados correto
4. Execute o script (F5)

#### Opção B: Via sqlcmd (Linha de comando)

```bash
sqlcmd -S SEU_SERVIDOR -U SEU_USUARIO -P SUA_SENHA -d SEU_BANCO -i schema.sql
```

#### Opção C: Via Azure Data Studio

1. Conecte ao servidor
2. Abra o arquivo `schema.sql`
3. Execute o script

### 🧪 4. Testar a Conexão

Antes de iniciar a API, teste se a conexão funciona:

```bash
cd /home/user/webapp-api
node test-connection.js
```

✅ **Sucesso** - Você verá:
```
✅ Conectado ao SQL Server com sucesso!
📊 Banco de dados: seu_banco
🖥️  Servidor: seu_servidor
```

❌ **Erro** - Possíveis problemas:

1. **"Login failed"**: Usuário ou senha incorretos
2. **"Cannot connect"**: Servidor inacessível (firewall, VPN)
3. **"Database not found"**: Nome do banco incorreto
4. **"SSL error"**: Ajuste `DB_ENCRYPT` e `DB_TRUST_CERTIFICATE`

### 🚀 5. Iniciar a API

Se o teste de conexão funcionou:

```bash
cd /home/user/webapp-api
npm start
```

Ou para desenvolvimento com auto-reload:

```bash
npm run dev
```

Você verá:

```
🚀 API rodando na porta 3001
🔗 Health check: http://localhost:3001/health
📊 Endpoints disponíveis em: http://localhost:3001/api/
```

### ✅ 6. Verificar se está Funcionando

Em outro terminal:

```bash
# Testar health check
curl http://localhost:3001/health

# Deve retornar:
{
  "status": "ok",
  "database": "connected",
  "timestamp": "2024-01-12T14:30:00.000Z"
}
```

### 🔗 7. Conectar o Portal à API

Agora que a API está funcionando, vamos conectar o portal:

1. Editar o arquivo JavaScript do portal:
   ```bash
   cd /home/user/webapp
   nano public/static/app.js
   ```

2. No início do arquivo, adicionar:
   ```javascript
   // Configuração da API SQL Server
   const USE_SQL_SERVER = true; // Mudar para true quando API estiver pronta
   const API_BASE_URL = USE_SQL_SERVER 
     ? 'http://localhost:3001/api' 
     : '/api';
   const API_KEY = 'SUA_CHAVE_SECRETA'; // Mesma do .env
   ```

3. Atualizar a função `fetchAPI`:
   ```javascript
   async function fetchAPI(endpoint, options = {}) {
     const headers = {
       'Content-Type': 'application/json',
       ...options.headers
     };
     
     // Adicionar API Key se estiver usando SQL Server
     if (USE_SQL_SERVER) {
       headers['X-API-Key'] = API_KEY;
     }
     
     const response = await fetch(`${API_BASE_URL}${endpoint}`, {
       ...options,
       headers
     });
     
     if (!response.ok) {
       throw new Error(`HTTP ${response.status}: ${response.statusText}`);
     }
     
     return response.json();
   }
   ```

4. Rebuild e reiniciar o portal:
   ```bash
   cd /home/user/webapp
   npm run build
   pm2 restart webapp
   ```

### 🎨 8. Testar o Portal Completo

Acesse o portal e verifique se os dados do SQL Server estão sendo exibidos:

```
https://3000-ig1zg8d9l1gqcefs84wxz-b9b802c4.sandbox.novita.ai
```

### 🐳 9. Usar PM2 para Manter a API Rodando

Para que a API fique rodando em background:

```bash
# Iniciar com PM2
cd /home/user/webapp-api
pm2 start server.js --name webapp-api

# Ver logs
pm2 logs webapp-api --nostream

# Reiniciar
pm2 restart webapp-api

# Status
pm2 list
```

### 📊 10. Popular o Banco com Dados de Teste (Opcional)

Se quiser dados de exemplo para testar:

1. A API já criou as tabelas vazias
2. Você pode inserir dados manualmente via SSMS
3. Ou aguarde que o portal permita cadastro via interface

## ❓ Troubleshooting

### Problema: "Cannot find module 'mssql'"

```bash
cd /home/user/webapp-api
npm install
```

### Problema: "Port 3001 already in use"

```bash
# Ver o que está usando a porta
lsof -i :3001

# Matar o processo
fuser -k 3001/tcp

# Ou mudar a porta no .env
PORT=3002
```

### Problema: CORS no navegador

Adicione seu domínio em `.env`:
```env
ALLOWED_ORIGINS=http://localhost:3000,https://seu-dominio.com
```

### Problema: SQL Server não aceita conexões remotas

1. Verificar firewall do servidor
2. Verificar firewall do Windows/Linux
3. Azure: Adicionar seu IP nas regras de firewall
4. Verificar se o SQL Server está configurado para TCP/IP

## 🔐 Segurança em Produção

Quando for para produção:

1. **Mudar API_KEY**: Gere uma chave forte
   ```bash
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

2. **Usar HTTPS**: Configure um certificado SSL

3. **Restringir CORS**: Apenas domínios específicos

4. **Firewall**: Proteger a porta 3001

5. **Não expor a API**: Use um proxy reverso (nginx)

## 📝 Checklist Final

- [ ] Arquivo `.env` configurado com credenciais corretas
- [ ] Script `schema.sql` executado no SQL Server
- [ ] Teste de conexão passou (`node test-connection.js`)
- [ ] API iniciada e respondendo (`curl http://localhost:3001/health`)
- [ ] Portal configurado para usar a API
- [ ] Portal rebuild e reiniciado
- [ ] Dados sendo exibidos corretamente no navegador
- [ ] PM2 gerenciando a API em background

## 🎉 Pronto!

Se todos os passos acima funcionaram, seu portal está conectado ao SQL Server!

Qualquer dúvida ou erro, consulte os logs:

```bash
# Logs da API
pm2 logs webapp-api --nostream

# Logs do portal
pm2 logs webapp --nostream
```

---

**Lembre-se**: 
- Nunca commite o arquivo `.env` no Git
- Mantenha suas credenciais seguras
- Use senhas fortes para o SQL Server
- Faça backups regulares do banco de dados
