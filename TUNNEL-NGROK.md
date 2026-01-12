# 🚇 Túnel ngrok para SQL Server

## 📖 Visão Geral

Expor o SQL Server interno (192.168.100.14:1433) para a API no sandbox usando **ngrok**.

---

## ✅ Vantagens do ngrok

- ✅ **Rápido** - Configuração em 5 minutos
- ✅ **Simples** - Um comando para iniciar
- ✅ **Sem configuração de rede** - Não precisa mexer no firewall
- ✅ **Free tier disponível** - Plano gratuito funciona

## ⚠️ Desvantagens

- ❌ **URL muda** - A cada reinício gera nova URL (fixo só em plano pago)
- ❌ **Menos seguro** - URL exposta publicamente (mas com autenticação)
- ❌ **Limite de conexões** - Free: 40 conexões/min
- ❌ **Timeout** - Free: 8 horas de sessão

---

## 🚀 Passo a Passo - Instalação

### **1. Criar Conta ngrok (Gratuita)**

1. Acesse: https://dashboard.ngrok.com/signup
2. Crie conta (pode usar Google/GitHub)
3. Copie o **authtoken** do dashboard

---

### **2. Instalar ngrok**

#### **Windows:**
```powershell
# Baixar ngrok
https://ngrok.com/download

# Extrair ZIP e adicionar ao PATH (ou executar direto da pasta)
```

#### **Linux:**
```bash
# Via snap (Ubuntu/Debian)
sudo snap install ngrok

# Ou baixar binário
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar xvzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/
```

#### **macOS:**
```bash
brew install ngrok/ngrok/ngrok
```

---

### **3. Autenticar ngrok**

```bash
ngrok config add-authtoken <SEU_AUTHTOKEN>
```

**⚠️ Substitua `<SEU_AUTHTOKEN>` pelo token copiado do dashboard ngrok**

---

### **4. Iniciar Túnel TCP para SQL Server**

Na máquina que tem acesso ao SQL Server (192.168.100.14):

```bash
ngrok tcp 192.168.100.14:1433
```

**Saída esperada:**
```
ngrok                                                                          

Session Status                online
Account                       seu-email@exemplo.com (Plan: Free)
Version                       3.5.0
Region                        United States (us)
Latency                       45ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    tcp://0.tcp.ngrok.io:12345 -> 192.168.100.14:1433

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**🔑 IMPORTANTE:** Anote a URL de forwarding:
- **Host:** `0.tcp.ngrok.io`
- **Port:** `12345` (exemplo - o seu será diferente)

---

### **5. Configurar a API para Usar o Túnel**

Atualize o arquivo `.env` da API no sandbox:

```env
# ANTES (não funciona do sandbox)
DB_SERVER=192.168.100.14
DB_PORT=1433

# DEPOIS (via ngrok)
DB_SERVER=0.tcp.ngrok.io
DB_PORT=12345

# Resto permanece igual
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
DB_ENCRYPT=true
DB_TRUST_CERTIFICATE=false
```

**⚠️ Substitua `0.tcp.ngrok.io` e `12345` pelos valores reais do seu túnel!**

---

### **6. Testar Conexão**

<function_calls>
<invoke name="Bash">
<parameter name="command">cd /home/user/webapp-api && cat > test-ngrok.js << 'EOF'
const sql = require('mssql');
require('dotenv').config();

async function testNgrokConnection() {
  const config = {
    server: process.env.DB_SERVER,
    port: parseInt(process.env.DB_PORT),
    database: process.env.DB_DATABASE,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: {
      encrypt: process.env.DB_ENCRYPT === 'true',
      trustServerCertificate: process.env.DB_TRUST_CERTIFICATE === 'true',
      connectTimeout: 30000,
      requestTimeout: 30000
    }
  };

  console.log('🔍 Testando conexão via ngrok...');
  console.log(`Servidor: ${config.server}:${config.port}`);
  console.log(`Banco de Dados: ${config.database}\n`);

  try {
    const pool = await sql.connect(config);
    console.log('✅ Conexão bem-sucedida via ngrok!');
    
    const result = await pool.request().query('SELECT @@VERSION as version');
    console.log('📊 SQL Server Version:', result.recordset[0].version.split('\n')[0]);
    
    await pool.close();
    process.exit(0);
  } catch (err) {
    console.error('❌ Erro ao conectar:', err.message);
    process.exit(1);
  }
}

testNgrokConnection();
EOF
echo "Script de teste ngrok criado!"