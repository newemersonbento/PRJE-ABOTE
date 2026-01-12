# 🌐 Túnel Cloudflare para SQL Server

## 📖 Visão Geral

Conectar a API no sandbox Cloudflare ao SQL Server interno (192.168.100.14:1433) usando **Cloudflare Tunnel**.

---

## ✅ Vantagens do Cloudflare Tunnel

- ✅ **Gratuito** - Sem custos
- ✅ **Seguro** - Criptografia TLS end-to-end
- ✅ **Sem abrir portas** - Não precisa mexer no firewall/router
- ✅ **Gerenciado** - Dashboard Cloudflare para monitoramento
- ✅ **Estável** - Reconecta automaticamente

---

## 🚀 Passo a Passo - Instalação

### **1. Pré-requisitos**

Na máquina que tem acesso ao SQL Server (192.168.100.14):
- Windows 10/11 ou Linux
- Acesso à rede interna onde está o SQL Server
- Conta Cloudflare (free tier funciona)

---

### **2. Instalar cloudflared**

#### **Windows:**
```powershell
# Baixar instalador
https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe

# Ou via winget
winget install --id Cloudflare.cloudflared
```

#### **Linux:**
```bash
# Debian/Ubuntu
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Via curl (qualquer distro)
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

---

### **3. Autenticar com Cloudflare**

```bash
cloudflared tunnel login
```

Isso abrirá o navegador para você autorizar o acesso à sua conta Cloudflare.

---

### **4. Criar o Túnel**

```bash
# Criar túnel chamado "way-sql-tunnel"
cloudflared tunnel create way-sql-tunnel

# Saída esperada:
# Tunnel credentials written to: C:\Users\SeuUsuario\.cloudflared\<TUNNEL-ID>.json
# Created tunnel way-sql-tunnel with id <TUNNEL-ID>

# IMPORTANTE: Anote o TUNNEL-ID
```

---

### **5. Criar Arquivo de Configuração**

Crie o arquivo `config.yml` em:
- **Windows:** `C:\Users\SeuUsuario\.cloudflared\config.yml`
- **Linux:** `~/.cloudflared/config.yml`

```yaml
tunnel: <TUNNEL-ID>
credentials-file: /path/to/.cloudflared/<TUNNEL-ID>.json

ingress:
  # Rotear tráfego SQL para o servidor interno
  - hostname: way-sql.yourdomain.com
    service: tcp://192.168.100.14:1433
  
  # Regra padrão (obrigatória)
  - service: http_status:404
```

**⚠️ Substitua:**
- `<TUNNEL-ID>` pelo ID gerado no passo 4
- `/path/to/.cloudflared/` pelo caminho real
- `way-sql.yourdomain.com` por um subdomínio seu (ou use Cloudflare Pages domain)

---

### **6. Adicionar Rota DNS no Cloudflare**

```bash
cloudflared tunnel route dns way-sql-tunnel way-sql.yourdomain.com
```

Ou configure manualmente no dashboard Cloudflare:
1. Acesse **DNS** no painel do seu domínio
2. Adicione registro CNAME:
   - **Name:** `way-sql`
   - **Target:** `<TUNNEL-ID>.cfargotunnel.com`
   - **Proxy status:** Proxied (laranja)

---

### **7. Iniciar o Túnel**

#### **Modo Teste (foreground):**
```bash
cloudflared tunnel run way-sql-tunnel
```

#### **Modo Serviço (background - Windows):**
```powershell
cloudflared service install
cloudflared service start
```

#### **Modo Serviço (background - Linux systemd):**
```bash
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

---

### **8. Verificar Status**

```bash
cloudflared tunnel info way-sql-tunnel

# Ou via dashboard:
# https://one.dash.cloudflare.com/ → Access → Tunnels
```

---

## 🔧 Configurar a API para Usar o Túnel

### **Atualizar `.env` da API:**

```env
# ANTES (não funciona do sandbox)
DB_SERVER=192.168.100.14
DB_PORT=1433

# DEPOIS (via Cloudflare Tunnel)
DB_SERVER=way-sql.yourdomain.com
DB_PORT=1433
DB_ENCRYPT=true
DB_TRUST_CERTIFICATE=false

# Resto permanece igual
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
```

---

## 🧪 Testar Conexão

Na API, execute:

```bash
cd /home/user/webapp-api
node test-connection.js
```

**Saída esperada:**
```
🔍 Testando conexão com SQL Server...
Servidor: way-sql.yourdomain.com:1433
Banco de Dados: ABOT

✅ Conexão bem-sucedida!
📊 Resultado do teste: [{"test":1}]
```

---

## 🔒 Segurança Adicional (Opcional)

### **Restringir Acesso com Cloudflare Access**

1. No dashboard Cloudflare → **Access** → **Applications**
2. Crie uma política:
   - **Application Name:** Way SQL Tunnel
   - **Subdomain:** `way-sql`
   - **Domain:** `yourdomain.com`
3. Configure regras:
   - **Allow** → **Emails** → `admin@waybrasil.com.br`
   - Ou use Service Tokens para autenticação máquina-a-máquina

---

## 📊 Monitoramento

### **Logs em Tempo Real:**
```bash
# Windows
cloudflared tunnel run way-sql-tunnel

# Linux
sudo journalctl -u cloudflared -f
```

### **Dashboard Cloudflare:**
- Acesse: https://one.dash.cloudflare.com/
- Vá em **Access** → **Tunnels** → `way-sql-tunnel`
- Veja métricas de latência, requisições, erros

---

## 🐛 Troubleshooting

### **Problema: Túnel não conecta**
```bash
# Verificar configuração
cloudflared tunnel info way-sql-tunnel

# Testar rota DNS
nslookup way-sql.yourdomain.com

# Verificar logs
cloudflared tunnel run way-sql-tunnel --loglevel debug
```

### **Problema: SQL Server rejeita conexão**
- Verificar se SQL Server aceita conexões TCP/IP (SQL Server Configuration Manager)
- Confirmar que o IP 192.168.100.14 está correto
- Testar conexão local primeiro: `telnet 192.168.100.14 1433`

### **Problema: Timeout na API**
- Aumentar timeout na conexão (database.js):
```javascript
connectionTimeout: 30000, // 30 segundos
requestTimeout: 30000
```

---

## 📚 Referências

- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Cloudflare Tunnel GitHub](https://github.com/cloudflare/cloudflared)
- [TCP Tunneling Guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/use-cases/tcp/)

---

## ✅ Checklist de Implementação

- [ ] Instalar cloudflared na máquina local
- [ ] Autenticar com Cloudflare (`cloudflared tunnel login`)
- [ ] Criar túnel (`cloudflared tunnel create way-sql-tunnel`)
- [ ] Configurar `config.yml` com rota SQL
- [ ] Adicionar rota DNS no Cloudflare
- [ ] Iniciar túnel (`cloudflared tunnel run`)
- [ ] Atualizar `.env` da API com hostname do túnel
- [ ] Testar conexão (`node test-connection.js`)
- [ ] Iniciar API (`npm start`)
- [ ] Configurar túnel como serviço (opcional)
- [ ] Configurar Cloudflare Access para segurança (opcional)

---

**🎯 Tempo estimado de configuração:** 15-30 minutos

**💰 Custo:** Gratuito

**🔒 Segurança:** Alta (TLS + opcional Access policies)
