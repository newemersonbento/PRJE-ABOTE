# 📦 DOWNLOAD - API Completa com Guias VPN

## 🎯 Pacote Disponível

**Arquivo:** `webapp-api-completo-vpn.tar.gz` (67 KB)  
**Localização:** `/home/user/webapp-api-completo-vpn.tar.gz`

---

## 📂 Conteúdo do Pacote

### **📋 Código da API (7 arquivos):**
- `server.js` - Servidor Express com todos os endpoints (18 KB)
- `database.js` - Conexão SQL Server com pool (2.5 KB)
- `test-connection.js` - Script de teste de conexão (1.6 KB)
- `package.json` - Dependências Node.js
- `package-lock.json` - Lock de versões
- `.env.example` - Template de variáveis de ambiente
- `ecosystem.config.cjs` - Configuração PM2

### **🗄️ Scripts SQL (3 arquivos):**
- `schema.sql` - Criação de 13 tabelas + índices + triggers (23 KB)
- `seed.sql` - Dados iniciais (4 unidades, 5 usuários, 8 categorias, 25 indicadores) (19 KB)
- Tabelas: org_units, auth_users, categories, indicators, indicator_history, it_assets, tickets, projects, backups, network_links, resources, stock_movements, activity_log

### **🔐 Guias de Conexão VPN (3 arquivos):**
- `TUNNEL-VPN.md` - Guia completo WireGuard + Tailscale + ZeroTier (15 KB)
- `TUNNEL-CLOUDFLARE.md` - Cloudflare Tunnel (gratuito) (6.5 KB)
- `TUNNEL-NGROK.md` - ngrok para testes rápidos (4.2 KB)
- `INICIO-RAPIDO-VPN.md` - Setup em 5 minutos com Tailscale (4.3 KB)

### **📚 Documentação (7 arquivos):**
- `README.md` - Visão geral do projeto (7.3 KB)
- `SCHEMA-COMPLETO.md` - Documentação do banco de dados (14 KB)
- `INSTRUCOES.md` - Instruções de instalação (7.4 KB)
- `INSTALACAO-LOCAL.md` - Instalação local passo a passo (6.6 KB)
- `CREDENCIAIS-EXEMPLO.md` - Exemplo de credenciais (4 KB)
- `STATUS.md` - Status atual do projeto (8 KB)
- `DOWNLOAD.md` - Este arquivo

### **🔧 Scripts Auxiliares (2 arquivos):**
- `wireguard-client-setup.sh` - Instalação WireGuard no sandbox
- `wireguard-client-configure.sh` - Configuração cliente WireGuard

### **🔒 Segurança:**
- `.gitignore` - Previne commit de credenciais
- `.env` - **NÃO incluído** (você deve criar baseado no .env.example)

---

## 🚀 Como Usar Este Pacote

### **Opção 1: Instalação Local (RECOMENDADO)**

```bash
# 1. Extrair pacote
tar -xzf webapp-api-completo-vpn.tar.gz
cd webapp-api

# 2. Instalar dependências
npm install

# 3. Escolher método de conexão VPN:

## OPÇÃO A - Tailscale (Mais Rápido - 5 minutos)
# Siga: INICIO-RAPIDO-VPN.md

## OPÇÃO B - WireGuard (Mais Controle - 30 minutos)
# Siga: TUNNEL-VPN.md seção WireGuard

## OPÇÃO C - Cloudflare Tunnel (Mais Seguro - 20 minutos)
# Siga: TUNNEL-CLOUDFLARE.md

## OPÇÃO D - ngrok (Testes Rápidos - 5 minutos)
# Siga: TUNNEL-NGROK.md

# 4. Configurar .env
cp .env.example .env
nano .env  # Edite com suas credenciais

# 5. Aplicar schema no SQL Server
# - Abra SQL Server Management Studio (SSMS)
# - Conecte ao servidor 192.168.100.14
# - Abra e execute: schema.sql
# - Abra e execute: seed.sql

# 6. Testar conexão
node test-connection.js

# 7. Iniciar API
npm start
# ou com PM2
pm2 start ecosystem.config.cjs

# 8. Verificar
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/health
```

---

### **Opção 2: Uso no Sandbox (DESENVOLVIMENTO)**

Se você já está no sandbox e quer testar:

```bash
# 1. Escolher método VPN (recomendo Tailscale)
# Siga: INICIO-RAPIDO-VPN.md

# 2. Configurar .env com IP da VPN
cat > .env << 'EOF'
DB_SERVER=<IP_VPN_SERVIDOR>  # Ex: 100.x.x.x (Tailscale) ou 192.168.100.14 (WireGuard)
DB_PORT=1433
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true

PORT=3001
NODE_ENV=production
API_KEY=webapp-api-key-2024-secure-change-in-production

ALLOWED_ORIGINS=http://localhost:3000,https://3000-ig1zg8d9l1gqcefs84wxz-b9b802c4.sandbox.novita.ai
EOF

# 3. Testar conexão
node test-connection.js

# 4. Iniciar API
pm2 start ecosystem.config.cjs
```

---

## 📊 Comparação de Métodos VPN

| Método | Facilidade | Velocidade | Segurança | Setup | Custo |
|--------|------------|------------|-----------|-------|-------|
| **Tailscale** | ⭐⭐⭐⭐⭐ | ⚡⚡⚡⚡ | 🔒🔒🔒🔒🔒 | 5 min | Grátis* |
| **WireGuard** | ⭐⭐ | ⚡⚡⚡⚡⚡ | 🔒🔒🔒🔒🔒 | 30 min | Grátis |
| **Cloudflare** | ⭐⭐⭐ | ⚡⚡⚡⚡ | 🔒🔒🔒🔒🔒 | 20 min | Grátis |
| **ngrok** | ⭐⭐⭐⭐⭐ | ⚡⚡⚡ | 🔒🔒🔒 | 5 min | Grátis** |

*Grátis até 100 dispositivos  
**URL muda a cada reinício (free)

---

## 🎯 Recomendação por Cenário

### **🚀 Quero testar AGORA (5 minutos):**
→ Use **Tailscale** (INICIO-RAPIDO-VPN.md)

### **🏢 Preciso para produção (controle total):**
→ Use **WireGuard** (TUNNEL-VPN.md)

### **🔒 Máxima segurança empresarial:**
→ Use **Cloudflare Tunnel** (TUNNEL-CLOUDFLARE.md)

### **🧪 Apenas testes rápidos:**
→ Use **ngrok** (TUNNEL-NGROK.md)

---

## 📋 Checklist de Instalação

### **Preparação:**
- [ ] Baixar e extrair `webapp-api-completo-vpn.tar.gz`
- [ ] Instalar Node.js 16+ na máquina
- [ ] Ter acesso ao SQL Server (192.168.100.14:1433)
- [ ] Escolher método VPN

### **Configuração VPN:**
- [ ] Instalar cliente VPN escolhido
- [ ] Conectar à VPN
- [ ] Testar conectividade (ping no SQL Server)
- [ ] Anotar IP/hostname para usar no .env

### **Setup API:**
- [ ] Executar `npm install`
- [ ] Criar `.env` baseado no `.env.example`
- [ ] Aplicar `schema.sql` no SQL Server (SSMS)
- [ ] Aplicar `seed.sql` no SQL Server
- [ ] Testar conexão: `node test-connection.js`
- [ ] Iniciar API: `npm start` ou `pm2 start ecosystem.config.cjs`

### **Verificação:**
- [ ] Endpoint `/health` respondendo
- [ ] Endpoint `/api/categories` retornando 8 categorias
- [ ] Endpoint `/api/indicators` retornando 25 indicadores
- [ ] Logs sem erros: `pm2 logs webapp-api`

---

## 🔧 Comandos Úteis

```bash
# Instalar dependências
npm install

# Testar conexão SQL
node test-connection.js

# Iniciar API (modo dev)
npm start

# Iniciar API (modo produção com PM2)
pm2 start ecosystem.config.cjs

# Ver logs
pm2 logs webapp-api

# Parar API
pm2 stop webapp-api

# Reiniciar API
pm2 restart webapp-api

# Remover API do PM2
pm2 delete webapp-api

# Ver status
pm2 status

# Testar endpoint
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/health
```

---

## 🐛 Troubleshooting

### **Problema: "Cannot connect to SQL Server"**

```bash
# 1. Verificar se VPN está ativa
tailscale status  # Tailscale
sudo wg show      # WireGuard

# 2. Testar conectividade
ping 192.168.100.14
telnet 192.168.100.14 1433

# 3. Verificar .env
cat .env

# 4. Testar conexão diretamente
node test-connection.js
```

### **Problema: "Module not found"**

```bash
# Reinstalar dependências
rm -rf node_modules package-lock.json
npm install
```

### **Problema: "Port 3001 already in use"**

```bash
# Parar processo usando a porta
fuser -k 3001/tcp  # Linux
# ou
pm2 delete all
```

### **Problema: "API retorna 500"**

```bash
# Ver logs de erro
pm2 logs webapp-api --err

# Verificar .env
cat .env

# Testar conexão SQL
node test-connection.js
```

---

## 📚 Documentação Completa

1. **INICIO-RAPIDO-VPN.md** - Setup rápido (5 minutos)
2. **TUNNEL-VPN.md** - Guia completo de VPN (WireGuard, Tailscale, ZeroTier)
3. **TUNNEL-CLOUDFLARE.md** - Cloudflare Tunnel
4. **TUNNEL-NGROK.md** - ngrok para testes
5. **SCHEMA-COMPLETO.md** - Estrutura do banco de dados
6. **INSTRUCOES.md** - Instruções gerais de instalação
7. **README.md** - Visão geral do projeto

---

## 🆘 Suporte

Se tiver problemas:

1. **Verifique a documentação** no arquivo correspondente
2. **Execute os testes** de conexão (`node test-connection.js`)
3. **Veja os logs** com `pm2 logs webapp-api`
4. **Teste a VPN** com `ping` e `telnet`

---

## ✅ Próximos Passos Após Instalação

1. ✅ **Conectar Frontend:** Configure o frontend para usar a API
2. ✅ **Testar Endpoints:** Use Postman ou curl para testar todas as rotas
3. ✅ **Configurar Produção:** Ajuste variáveis de ambiente para produção
4. ✅ **Monitoramento:** Configure logs e alertas
5. ✅ **Backup:** Configure backup regular do banco de dados

---

**📦 Versão do Pacote:** 2.0 (com guias VPN)  
**📅 Data:** 2026-01-12  
**💾 Tamanho:** 67 KB  
**📝 Arquivos:** 24 arquivos (7 código + 3 SQL + 4 VPN + 7 docs + 3 config)

---

**🎯 Tudo pronto para usar! Escolha seu método VPN e comece em minutos!** 🚀
