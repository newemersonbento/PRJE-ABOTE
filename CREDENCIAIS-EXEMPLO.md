# 📋 EXEMPLO DE CREDENCIAIS

## Formato das Credenciais que Preciso

Por favor, forneça suas credenciais do SQL Server no seguinte formato:

```
Servidor: meu-servidor.database.windows.net
Porta: 1433
Banco de Dados: IndicadoresDB
Usuário: admin_user
Senha: MinhaS3nh@F0rt3!
Tipo de Conexão: Azure SQL / SQL Server Local / SQL Server Express
Criptografia: Sim / Não
```

## 📝 Exemplos por Tipo de Servidor

### 1️⃣ Azure SQL Database

```
Servidor: meuservidor.database.windows.net
Porta: 1433
Banco de Dados: producao_db
Usuário: sqladmin
Senha: P@ssw0rd123!
Tipo de Conexão: Azure SQL
Criptografia: Sim
```

Meu `.env` ficará:
```env
DB_SERVER=meuservidor.database.windows.net
DB_PORT=1433
DB_DATABASE=producao_db
DB_USER=sqladmin
DB_PASSWORD=P@ssw0rd123!
DB_ENCRYPT=true
DB_TRUST_CERTIFICATE=false
```

---

### 2️⃣ SQL Server Local (Rede interna)

```
Servidor: 192.168.1.50
Porta: 1433
Banco de Dados: GestaoIndicadores
Usuário: sa
Senha: Admin123
Tipo de Conexão: SQL Server Local
Criptografia: Não (rede interna)
```

Meu `.env` ficará:
```env
DB_SERVER=192.168.1.50
DB_PORT=1433
DB_DATABASE=GestaoIndicadores
DB_USER=sa
DB_PASSWORD=Admin123
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true
```

---

### 3️⃣ SQL Server Express (Localhost)

```
Servidor: localhost\SQLEXPRESS
Porta: 1433
Banco de Dados: Indicadores
Usuário: app_user
Senha: senha123
Tipo de Conexão: SQL Server Express
Criptografia: Não
```

Meu `.env` ficará:
```env
DB_SERVER=localhost\\SQLEXPRESS
DB_PORT=1433
DB_DATABASE=Indicadores
DB_USER=app_user
DB_PASSWORD=senha123
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true
```

---

### 4️⃣ SQL Server com Windows Authentication

```
Servidor: SERVIDOR-TI\SQLSERVER2019
Porta: 1433
Banco de Dados: WayBrasil
Autenticação: Windows (dominio\usuario)
Tipo de Conexão: SQL Server (Windows Auth)
```

Meu `.env` ficará:
```env
DB_SERVER=SERVIDOR-TI\\SQLSERVER2019
DB_PORT=1433
DB_DATABASE=WayBrasil
DB_DOMAIN=EMPRESA
DB_USER=usuario
DB_PASSWORD=senha_dominio
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true
```

---

## ✅ Checklist de Informações

Antes de me fornecer as credenciais, certifique-se de ter:

- [ ] Endereço completo do servidor (IP ou hostname)
- [ ] Número da porta (geralmente 1433)
- [ ] Nome exato do banco de dados
- [ ] Nome de usuário com permissões de leitura/escrita
- [ ] Senha do usuário
- [ ] Informação se usa criptografia SSL/TLS
- [ ] Se o servidor está acessível da sua rede atual
- [ ] Se há firewall bloqueando a conexão

## 🔍 Como Descobrir Suas Credenciais

### No SQL Server Management Studio (SSMS):

1. Conecte ao servidor
2. Veja o nome na árvore à esquerda
3. Clique com direito no servidor → Propriedades
4. Anote todas as informações

### No Azure Portal:

1. Acesse seu SQL Database
2. Vá em "Settings" → "Connection strings"
3. Copie a string de conexão ADO.NET
4. Eu extraio as informações dela

### String de Conexão (se você tiver):

Se você tem uma string de conexão, me envie ela:

```
Server=tcp:servidor.database.windows.net,1433;Initial Catalog=banco;Persist Security Info=False;User ID=usuario;Password=senha;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

Eu vou extrair as informações automaticamente!

---

## 🔐 Segurança

Suas credenciais são confidenciais e serão:

✅ Armazenadas apenas no arquivo `.env` local  
✅ Nunca enviadas para o Git (`.gitignore` configurado)  
✅ Usadas apenas para conexão direta ao banco  
✅ Protegidas por API Key na API REST  

❌ Nunca armazene credenciais:
- No código-fonte
- Em arquivos públicos
- Em commits do Git
- Em logs ou screenshots

---

## 📞 Pronto para Conectar?

Assim que você me fornecer as credenciais no formato acima, eu vou:

1. ✅ Configurar o arquivo `.env`
2. ✅ Testar a conexão
3. ✅ Executar o schema no banco
4. ✅ Iniciar a API
5. ✅ Conectar o portal
6. ✅ Testar tudo end-to-end

**Aguardando suas credenciais para continuar! 🚀**
