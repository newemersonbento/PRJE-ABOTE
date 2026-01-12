# 🚀 Tailscale Configurado - Próximos Passos

## ✅ Status Atual

**Sandbox Tailscale instalado:**
- ✅ IP Tailscale: `100.97.26.90`
- ✅ Cliente conectado

---

## 🎯 PRÓXIMO PASSO CRÍTICO

Para conectar ao SQL Server, você precisa **instalar Tailscale no servidor onde está o SQL Server** (192.168.100.14).

---

## 📋 Configuração no Servidor SQL (192.168.100.14)

### **Opção 1: Windows Server (mais provável)**

1. **Baixar Tailscale:**
   - Acesse: https://tailscale.com/download/windows
   - Baixe e instale `tailscale-setup.exe`

2. **Instalar e Conectar:**
   - Execute o instalador
   - Clique em "Sign in to Tailscale"
   - **IMPORTANTE:** Use a **MESMA CONTA** que você usou no sandbox
   - Autorize o dispositivo

3. **Ver IP Tailscale do Servidor:**
   - Após conectar, o Tailscale mostrará o IP (ex: `100.x.x.x`)
   - **ANOTE ESTE IP!**

4. **Verificar conexão:**
   ```powershell
   # Ver status Tailscale
   tailscale status
   
   # Ver IP do servidor
   tailscale ip -4
   ```

---

### **Opção 2: Linux Server**

```bash
# 1. Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# 2. Conectar (MESMA CONTA do sandbox)
sudo tailscale up

# 3. Ver IP
tailscale ip -4

# 4. Verificar status
tailscale status
```

---

## 🔄 Após Instalar no Servidor SQL

### **1. Verificar Conexão Entre Dispositivos:**

No **sandbox**, execute:

```bash
# Ver dispositivos Tailscale conectados
tailscale status

# Você deve ver algo como:
# 100.97.26.90   sandbox-device     linux   active
# 100.x.x.x      sql-server         windows active
```

### **2. Testar Conectividade:**

```bash
# Ping no servidor SQL (substitua pelo IP Tailscale real)
ping 100.x.x.x

# Testar porta SQL Server
timeout 3 bash -c "echo > /dev/tcp/100.x.x.x/1433" && echo "✅ SQL ACESSÍVEL!" || echo "❌ SQL INACESSÍVEL"
```

---

## ⚙️ Configurar API com IP Tailscale

Após instalar Tailscale no servidor SQL, atualize o `.env`:

```bash
cd /home/user/webapp-api

# Atualizar .env com IP Tailscale do servidor SQL
cat > .env << 'EOF'
# SQL Server via Tailscale
DB_SERVER=100.x.x.x
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

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://3000-ig1zg8d9l1gqcefs84wxz-b9b802c4.sandbox.novita.ai,https://webapp.pages.dev
EOF

# ⚠️ SUBSTITUA 100.x.x.x pelo IP Tailscale REAL do servidor SQL!
```

---

## 🧪 Testar Conexão

```bash
cd /home/user/webapp-api

# Testar conexão SQL
node test-connection.js

# Saída esperada:
# ✅ Conexão bem-sucedida!
# 📊 Resultado do teste: [{"test":1}]
```

---

## 🚀 Iniciar API

```bash
cd /home/user/webapp-api

# Iniciar com PM2
pm2 start ecosystem.config.cjs

# Ver logs
pm2 logs webapp-api --nostream

# Testar endpoint
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/health
```

---

## 🎯 Fluxo Completo

```
┌────────────────────────────────────────────────────────┐
│  1. INSTALAR TAILSCALE NO SERVIDOR SQL                 │
│     (192.168.100.14)                                    │
│     → Baixar: https://tailscale.com/download           │
│     → MESMA CONTA do sandbox                            │
│     → Anotar IP Tailscale: 100.x.x.x                   │
└────────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────────┐
│  2. VERIFICAR CONEXÃO NO SANDBOX                        │
│     tailscale status                                    │
│     → Deve mostrar os 2 dispositivos                    │
└────────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────────┐
│  3. TESTAR CONECTIVIDADE                                │
│     ping 100.x.x.x                                      │
│     timeout 3 bash -c "echo > /dev/tcp/100.x.x.x/1433" │
└────────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────────┐
│  4. ATUALIZAR .env COM IP TAILSCALE                     │
│     DB_SERVER=100.x.x.x                                 │
└────────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────────┐
│  5. TESTAR CONEXÃO SQL                                  │
│     node test-connection.js                             │
└────────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────────┐
│  6. INICIAR API                                         │
│     pm2 start ecosystem.config.cjs                      │
└────────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────────┐
│  ✅ API CONECTADA AO SQL SERVER VIA TAILSCALE!          │
└────────────────────────────────────────────────────────┘
```

---

## 🐛 Troubleshooting

### **Problema: Não sei qual máquina tem o SQL Server**

Execute na rede Way Brasil:

```powershell
# Windows - Descobrir servidor SQL
sqlcmd -L

# Ou testar conectividade
Test-NetConnection -ComputerName 192.168.100.14 -Port 1433
```

### **Problema: Não consigo instalar Tailscale no servidor**

**Alternativa:** Instale Tailscale em **outra máquina da rede Way Brasil** que tenha acesso ao SQL Server:

```
[Sandbox Tailscale] ←→ [Sua Máquina Tailscale] → [SQL Server 192.168.100.14]
   100.97.26.90           100.x.x.x               192.168.100.14
```

Nesse caso:
1. Instale Tailscale na sua máquina
2. Conecte à VPN Way Brasil
3. Rode a API na sua máquina (veja `SOLUCAO-FINAL-WAY.md`)

---

## ❓ QUAL É A SUA SITUAÇÃO?

**Opção A:** Você tem acesso ao servidor 192.168.100.14?
- ✅ Sim → Instale Tailscale lá diretamente

**Opção B:** Não tem acesso ao servidor?
- ✅ Instale Tailscale na **sua máquina** que acessa a rede Way Brasil
- ✅ Rode a API na sua máquina (veja `SOLUCAO-FINAL-WAY.md`)

**Opção C:** Não tem máquina na rede Way Brasil?
- ⚠️ Contate TI Way Brasil para instalar Tailscale no servidor SQL
- ⚠️ Ou configure port forwarding/proxy

---

## 📞 ME INFORME

Para eu te ajudar melhor, me diga:

1. **Você consegue acessar o servidor 192.168.100.14 fisicamente ou via RDP?**
   - Se SIM → Instale Tailscale nele
   - Se NÃO → Instale Tailscale na sua máquina local

2. **Qual sistema operacional do servidor SQL?**
   - Windows Server → Use instalador .exe
   - Linux → Use script de instalação

3. **Você tem uma máquina na rede Way Brasil onde pode instalar Tailscale?**
   - Se SIM → Podemos rodar API lá
   - Se NÃO → Contate TI Way Brasil

---

## ✅ PRÓXIMO COMANDO

**Se você tem acesso ao servidor SQL:**

```bash
# Ver dispositivos Tailscale conectados
tailscale status

# Você verá:
# 100.97.26.90   sandbox    linux   active (VOCÊ ESTÁ AQUI)
# 100.x.x.x      ???        ???     offline (PRECISA CONECTAR)
```

**Após instalar Tailscale no servidor SQL, execute:**

```bash
# Ver novamente
tailscale status

# Agora você verá:
# 100.97.26.90   sandbox       linux    active
# 100.x.x.x      sql-server    windows  active ✅
```

---

**🎯 Responda qual é a sua situação e eu te guio no próximo passo!**
