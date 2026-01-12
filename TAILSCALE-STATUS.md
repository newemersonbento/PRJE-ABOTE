# 🎯 Tailscale - Status e Próximos Passos

## 📊 Situação Atual

Você informou que instalou Tailscale com IP: **100.97.26.90**

### **⚠️ IMPORTANTE: Onde está este IP?**

Esse IP **100.97.26.90** está em qual máquina?

**Opção A:** Você instalou Tailscale na **sua máquina local** (não no sandbox)?
- ✅ Perfeito! Vamos configurar para rodar a API lá

**Opção B:** Você instalou Tailscale no **servidor SQL** (192.168.100.14)?
- ✅ Excelente! Vamos configurar o sandbox para conectar

**Opção C:** Você tem Tailscale em **ambas as máquinas**?
- ✅ Perfeito! Já podemos testar a conexão

---

## 🔍 Descobrir Configuração Atual

### **Na máquina que tem IP 100.97.26.90, execute:**

```bash
# Ver todos os dispositivos Tailscale
tailscale status

# Saída mostrará algo como:
# 100.97.26.90   minha-maquina    windows  online
# 100.x.x.x      outro-device     linux    online
```

---

## 🎯 CENÁRIO 1: Tailscale na Sua Máquina Local

Se o IP **100.97.26.90** é da **sua máquina local**, vamos rodar a API lá:

### **1. Baixar Pacote API:**

```bash
# Na sua máquina local, extrair o pacote
tar -xzf webapp-api-completo-vpn.tar.gz
cd webapp-api
```

### **2. Conectar à VPN Way Brasil:**

- Use o cliente VPN corporativo
- Servidor: vpn2.way306.com.br:443
- Usuário: way306\emerson.totvs
- Senha: waybrasil2025@

### **3. Verificar Acesso ao SQL:**

```bash
# Windows PowerShell:
Test-NetConnection -ComputerName 192.168.100.14 -Port 1433

# Linux/Mac:
telnet 192.168.100.14 1433
```

### **4. Configurar e Iniciar API:**

```bash
# Instalar dependências
npm install

# Configurar .env
cat > .env << 'EOF'
DB_SERVER=192.168.100.14
DB_PORT=1433
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true

PORT=3001
NODE_ENV=production
API_KEY=webapp-api-key-2024-secure-change-in-production

ALLOWED_ORIGINS=http://localhost:3000,https://webapp.pages.dev
EOF

# Aplicar schema no SQL Server (via SSMS)
# Execute: schema.sql e seed.sql

# Testar conexão
node test-connection.js

# Iniciar API
npm start
# ou
pm2 start ecosystem.config.cjs
```

### **5. Expor via Tailscale para o Sandbox:**

Como sua máquina tem Tailscale (100.97.26.90), o sandbox pode acessar diretamente:

```bash
# No sandbox, testar conexão
curl http://100.97.26.90:3001/health
```

✅ **Pronto! O sandbox acessa sua API via Tailscale!**

---

## 🎯 CENÁRIO 2: Tailscale no Servidor SQL

Se o IP **100.97.26.90** é do **servidor SQL** (192.168.100.14):

### **1. Instalar Tailscale no Sandbox:**

```bash
# Já tentamos mas deu erro de socket
# Vamos usar abordagem diferente

# Verificar se já está autenticado
sudo tailscale up

# Se pedir autenticação:
# 1. Copie a URL gerada
# 2. Abra no navegador
# 3. Autorize o dispositivo
```

### **2. Após Conectar, Ver Dispositivos:**

```bash
sudo tailscale status

# Deve mostrar:
# 100.x.x.x      sandbox          linux    online
# 100.97.26.90   sql-server       windows  online
```

### **3. Atualizar .env no Sandbox:**

```bash
cd /home/user/webapp-api

cat > .env << 'EOF'
DB_SERVER=100.97.26.90
DB_PORT=1433
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true

PORT=3001
NODE_ENV=production
API_KEY=webapp-api-key-2024-secure-change-in-production

ALLOWED_ORIGINS=http://localhost:3000,https://webapp.pages.dev
EOF
```

### **4. Testar Conexão:**

```bash
# Testar conectividade
timeout 3 bash -c "echo > /dev/tcp/100.97.26.90/1433" && echo "✅ SQL ACESSÍVEL!" || echo "❌ SQL INACESSÍVEL"

# Testar SQL Server
node test-connection.js
```

### **5. Iniciar API:**

```bash
pm2 start ecosystem.config.cjs
pm2 logs webapp-api --nostream
```

✅ **Pronto! API no sandbox conecta ao SQL via Tailscale!**

---

## 🎯 CENÁRIO 3: Tailscale em Ambas as Máquinas

Se você tem Tailscale tanto na **sua máquina** quanto no **servidor SQL**:

### **Arquitetura:**

```
[Sua Máquina Tailscale] ──VPN Way──> [SQL Server 192.168.100.14]
   100.97.26.90 (?)                   (acesso via VPN)
         │
         │ Tailscale Network
         │
   [Sandbox Tailscale] ──────────────> [Sua Máquina API:3001]
     100.x.x.x                          100.97.26.90
```

**Recomendação:** Rode a API na **sua máquina** (CENÁRIO 1)

---

## 📋 PRÓXIMOS PASSOS RECOMENDADOS

### **PASSO 1: Identifique Onde Está o IP 100.97.26.90**

Execute na máquina com este IP:

```bash
# Windows
ipconfig | findstr "100.97"

# Linux/Mac
ip addr | grep "100.97"

# Ver hostname
hostname
```

### **PASSO 2: Ver Todos os Dispositivos Tailscale**

```bash
tailscale status

# Ou no painel web:
# https://login.tailscale.com/admin/machines
```

### **PASSO 3: Decidir Onde Rodar a API**

**Opção A (RECOMENDADO):** Rodar API na sua máquina local
- ✅ Você tem VPN Way Brasil
- ✅ Você tem Tailscale
- ✅ Acesso ao SQL Server direto via VPN
- ✅ Sandbox acessa via Tailscale

**Opção B:** Rodar API no sandbox
- ⚠️ Precisa Tailscale no servidor SQL
- ⚠️ Servidor SQL precisa aceitar conexões do Tailscale IP
- ⚠️ Mais complexo

---

## 🆘 ME INFORME

Para eu te ajudar corretamente, responda:

1. **Onde está o IP 100.97.26.90?**
   - [ ] Na minha máquina local
   - [ ] No servidor SQL (192.168.100.14)
   - [ ] Em outra máquina

2. **Você consegue conectar à VPN Way Brasil?**
   - [ ] Sim, tenho cliente VPN instalado
   - [ ] Não, não tenho acesso

3. **Você consegue acessar 192.168.100.14 via RDP/SSH?**
   - [ ] Sim, posso instalar Tailscale lá
   - [ ] Não, não tenho acesso físico

4. **Qual sistema operacional da máquina com IP 100.97.26.90?**
   - [ ] Windows
   - [ ] Linux
   - [ ] Mac

---

## 🚀 Comando Rápido de Diagnóstico

Execute isso na máquina com IP **100.97.26.90**:

```bash
echo "=== DIAGNÓSTICO TAILSCALE ==="
echo ""
echo "Hostname:"
hostname
echo ""
echo "Sistema Operacional:"
uname -a 2>/dev/null || ver
echo ""
echo "IP Tailscale:"
tailscale ip -4
echo ""
echo "Status Tailscale:"
tailscale status
echo ""
echo "Teste SQL Server:"
timeout 3 bash -c "echo > /dev/tcp/192.168.100.14/1433" 2>&1 && echo "✅ SQL ACESSÍVEL" || echo "❌ SQL INACESSÍVEL"
```

**Copie e cole a saída aqui!**

---

## ✅ Resumo

- ✅ Tailscale está instalado **em algum lugar** (IP: 100.97.26.90)
- ❓ Precisamos saber **onde** está este IP
- ❓ Precisamos saber se **tem Tailscale no servidor SQL**
- ❓ Depois decidimos onde rodar a API

**🎯 Responda as perguntas acima e eu te guio no próximo passo exato!**
