# 🎯 GUIA RÁPIDO: Conectar à VPN e Iniciar API

## ⚡ Opção Recomendada: Tailscale (MAIS RÁPIDO)

Se você quer a **solução mais rápida e simples**, use Tailscale:

### **🚀 Setup em 5 Minutos:**

#### **1. No Servidor (Windows/Linux onde está o SQL):**

**Windows:**
- Baixe: https://tailscale.com/download/windows
- Instale e faça login
- Anote o IP Tailscale: veja no aplicativo (ex: `100.x.x.x`)

**Linux:**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale ip -4  # Anote o IP
```

#### **2. No Sandbox (API):**

```bash
# Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Conectar (use a MESMA conta do servidor)
sudo tailscale up

# Verificar conexão
tailscale status  # Você deve ver o servidor listado

# Ver IP do servidor
tailscale status | grep <nome-do-servidor>
```

#### **3. Configurar API:**

```bash
cd /home/user/webapp-api

# Atualizar .env com o IP Tailscale do servidor
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

# ⚠️ Substitua 100.x.x.x pelo IP real do Tailscale do servidor!

# Testar conexão
node test-connection.js

# Iniciar API
pm2 start ecosystem.config.cjs

# Ver logs
pm2 logs webapp-api --nostream

# Testar endpoint
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/health
```

**✅ PRONTO! API conectada ao SQL Server via VPN segura!**

---

## 🔧 Opção Avançada: WireGuard

Se você quer **controle total e máxima velocidade**, siga o guia completo em `TUNNEL-VPN.md`.

---

## 📊 Status da Configuração

Execute para verificar tudo:

```bash
# 1. Verificar VPN conectada
tailscale status
# ou
sudo wg show

# 2. Testar ping no SQL Server
ping 192.168.100.14  # WireGuard
# ou
ping <IP_TAILSCALE_SERVIDOR>  # Tailscale

# 3. Verificar API rodando
pm2 list

# 4. Testar endpoint de saúde
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/health

# 5. Ver logs em tempo real
pm2 logs webapp-api
```

---

## 🐛 Troubleshooting Rápido

### **API não conecta ao SQL:**

```bash
# 1. Verificar se VPN está ativa
tailscale status
# ou
sudo wg show

# 2. Testar conectividade SQL
telnet 192.168.100.14 1433
# ou
nc -zv 192.168.100.14 1433

# 3. Ver logs de erro da API
pm2 logs webapp-api --err --nostream

# 4. Testar conexão SQL diretamente
node test-connection.js
```

### **VPN não conecta:**

**Tailscale:**
```bash
# Reconectar
sudo tailscale down
sudo tailscale up

# Ver status detalhado
sudo tailscale status --json
```

**WireGuard:**
```bash
# Reconectar
sudo wg-quick down wg0
sudo wg-quick up wg0

# Ver logs
sudo journalctl -u wg-quick@wg0 -n 50
```

---

## 📚 Documentação Completa

- **TUNNEL-VPN.md** - Guia completo de todas as opções VPN
- **TUNNEL-CLOUDFLARE.md** - Cloudflare Tunnel (alternativa)
- **TUNNEL-NGROK.md** - ngrok (para testes rápidos)
- **SCHEMA-COMPLETO.md** - Estrutura completa do banco
- **INSTALACAO-LOCAL.md** - Como rodar tudo localmente

---

## ✅ Checklist Rápido

- [ ] VPN instalada e conectada (Tailscale ou WireGuard)
- [ ] IP do servidor anotado
- [ ] .env atualizado com IP correto
- [ ] Teste de conexão SQL bem-sucedido (`node test-connection.js`)
- [ ] API iniciada com PM2 (`pm2 start ecosystem.config.cjs`)
- [ ] Endpoint /health respondendo
- [ ] Frontend configurado para apontar para API

---

## 🚀 Próximos Passos

Após conectar a API ao SQL Server:

1. ✅ **Aplicar schema no banco:** Execute `schema.sql` no SSMS
2. ✅ **Popular dados iniciais:** Execute `seed.sql` no SSMS  
3. ✅ **Atualizar frontend:** Configure URL da API no frontend
4. ✅ **Testar endpoints:** Use Postman ou curl para testar todas as rotas
5. ✅ **Deploy final:** Suba tudo para produção

---

**💡 Dica:** Para ambientes de produção, recomendamos **WireGuard** (mais seguro e rápido). Para desenvolvimento, **Tailscale** é perfeito (mais simples).

**🔒 Segurança:** Ambas as opções usam criptografia forte e são adequadas para produção.

**💰 Custo:** Ambas são gratuitas para até 100 dispositivos.
