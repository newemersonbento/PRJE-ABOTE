# 📤 Upload para GitHub - Guia Completo

## ⚠️ GitHub Não Configurado

Para fazer upload para GitHub, você precisa primeiro **configurar a autorização GitHub** no sandbox.

---

## 🔧 Passo a Passo para Configurar GitHub

### **Opção 1: Configurar via Interface do Sandbox (RECOMENDADO)**

1. **Acesse a aba #github** no painel do sandbox
2. **Autorize o GitHub App** ou **OAuth**
3. **Selecione ou crie um repositório**
4. Após autorização, volte aqui e peça para fazer upload

---

### **Opção 2: Upload Manual (SEM AUTORIZAÇÃO)**

Se você não conseguir configurar pelo sandbox, pode fazer upload manualmente:

#### **A. Baixar o Código:**

```bash
# Localização do pacote:
/home/user/webapp-api-completo-vpn.tar.gz (78 KB)
```

#### **B. Na Sua Máquina Local:**

```bash
# 1. Extrair pacote
tar -xzf webapp-api-completo-vpn.tar.gz
cd webapp-api

# 2. Verificar git
git status

# 3. Criar repositório no GitHub
# Acesse: https://github.com/new
# Nome sugerido: portal-indicadores-way-brasil
# Descrição: Portal de Indicadores de Gestão - Way Brasil (API Node.js + SQL Server)
# Público ou Privado (recomendo Privado por conter credenciais de exemplo)

# 4. Adicionar remote e fazer push
git remote add origin https://github.com/SEU_USUARIO/portal-indicadores-way-brasil.git

# 5. Verificar branch
git branch -M main

# 6. Fazer push
git push -u origin main

# Se pedir autenticação:
# - Username: seu_usuario_github
# - Password: use um Personal Access Token (não a senha)
#   Gere em: https://github.com/settings/tokens
```

---

## 🔐 Criar Personal Access Token (Se Necessário)

1. **Acesse:** https://github.com/settings/tokens
2. **Generate new token** → **Classic**
3. **Nome:** `Portal Way Brasil Upload`
4. **Expiration:** 90 days (ou escolha)
5. **Scopes:** Marque apenas `repo` (acesso total aos repositórios)
6. **Generate token**
7. **Copie o token** (você só verá uma vez!)
8. **Use como senha** ao fazer `git push`

---

## 📋 Checklist Antes de Upload

### **Verificar Segurança:**

```bash
cd /home/user/webapp-api

# 1. Verificar .gitignore
cat .gitignore

# Deve conter:
# node_modules/
# .env
# logs/
# *.log
# .DS_Store

# 2. Verificar se .env NÃO está no git
git status | grep ".env"

# Se aparecer, remover:
git rm --cached .env
git commit -m "Remover .env do git"

# 3. Verificar arquivos que serão enviados
git ls-files
```

---

## 📂 O Que Será Enviado

### **Código (7 arquivos):**
- ✅ `server.js` - API Node.js (18 KB)
- ✅ `database.js` - Conexão SQL Server
- ✅ `test-connection.js` - Teste de conexão
- ✅ `package.json` - Dependências
- ✅ `package-lock.json` - Lock de versões
- ✅ `ecosystem.config.cjs` - Configuração PM2

### **SQL (2 arquivos):**
- ✅ `schema.sql` - 13 tabelas (23 KB)
- ✅ `seed.sql` - Dados iniciais (19 KB)

### **Documentação (17 arquivos MD):**
- ✅ RESUMO-EXECUTIVO.md
- ✅ SOLUCAO-FINAL-WAY.md
- ✅ DECISAO-TAILSCALE.md
- ✅ TAILSCALE-PROXIMO-PASSO.md
- ✅ TAILSCALE-STATUS.md
- ✅ VPN-WAY-BRASIL.md
- ✅ INICIO-RAPIDO-VPN.md
- ✅ TUNNEL-VPN.md
- ✅ TUNNEL-CLOUDFLARE.md
- ✅ TUNNEL-NGROK.md
- ✅ SCHEMA-COMPLETO.md
- ✅ README.md
- ✅ INSTRUCOES.md
- ✅ INSTALACAO-LOCAL.md
- ✅ DOWNLOAD.md
- ✅ CREDENCIAIS-EXEMPLO.md
- ✅ STATUS.md

### **Scripts (3 arquivos):**
- ✅ `test-vpn-way.sh`
- ✅ `wireguard-client-configure.sh`

### **Config (2 arquivos):**
- ✅ `.gitignore`
- ✅ `.env.example` (template sem credenciais reais)

### **❌ O Que NÃO Será Enviado (por segurança):**
- ❌ `node_modules/` (dependências - será instalado via npm)
- ❌ `.env` (credenciais reais)
- ❌ `logs/` (logs da aplicação)
- ❌ `.git/` (histórico git local)

---

## 🎯 Comandos Rápidos de Upload

### **Se já tem repositório GitHub criado:**

```bash
cd /home/user/webapp-api

# Verificar remote
git remote -v

# Se não tiver remote, adicionar:
git remote add origin https://github.com/SEU_USUARIO/NOME_DO_REPO.git

# Fazer push
git push -u origin main

# Se der erro de autenticação:
# Use Personal Access Token como senha
```

### **Se ainda não tem repositório:**

```bash
# 1. Criar no GitHub:
# https://github.com/new

# 2. Depois:
cd /home/user/webapp-api
git remote add origin https://github.com/SEU_USUARIO/NOME_DO_REPO.git
git branch -M main
git push -u origin main
```

---

## 📊 Estrutura do Repositório no GitHub

Após upload, seu repositório terá:

```
portal-indicadores-way-brasil/
├── 📄 README.md (primeiro arquivo que aparece)
├── 📁 src/
│   ├── server.js
│   └── database.js
├── 📁 sql/
│   ├── schema.sql
│   └── seed.sql
├── 📁 docs/
│   ├── RESUMO-EXECUTIVO.md
│   ├── SOLUCAO-FINAL-WAY.md
│   └── ... (outros 15 docs)
├── 📁 scripts/
│   ├── test-vpn-way.sh
│   └── wireguard-client-configure.sh
├── 📄 package.json
├── 📄 ecosystem.config.cjs
├── 📄 .gitignore
└── 📄 .env.example
```

---

## 🔒 IMPORTANTE: Segurança

### **Antes de fazer upload, CERTIFIQUE-SE:**

```bash
# 1. .env NÃO está rastreado
git ls-files | grep .env
# Não deve aparecer nada

# 2. .env.example SIM está rastreado (sem credenciais reais)
git ls-files | grep .env.example
# Deve aparecer: .env.example

# 3. Verificar se há credenciais expostas
grep -r "New@3260" --exclude-dir=.git --exclude="*.md"
# Só deve aparecer no .env (que não será enviado)
```

### **Se encontrar .env no git:**

```bash
# Remover do histórico
git rm --cached .env
git commit -m "Remover .env do git por segurança"

# Adicionar ao .gitignore se não estiver
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Adicionar .env ao gitignore"
```

---

## 📝 Descrição Sugerida do Repositório

**Nome:**
```
portal-indicadores-way-brasil-api
```

**Descrição:**
```
Portal de Indicadores de Gestão Way Brasil - API REST Node.js + Express + SQL Server com 35 endpoints, autenticação, auditoria e documentação completa.
```

**Tags:**
```
nodejs, express, mssql, sql-server, rest-api, typescript, cloudflare-pages, tailscale, vpn, way-brasil, portal, indicadores, dashboard
```

**README do GitHub:**
O arquivo `README.md` já está pronto e será exibido automaticamente!

---

## 🎯 Próximos Passos Recomendados

### **Após Upload:**

1. **Configurar GitHub Actions** (CI/CD) - opcional
2. **Configurar Branch Protection** (main protegido)
3. **Adicionar Colaboradores** se necessário
4. **Criar Release/Tag** da versão 1.0
5. **Documentar Issues** conhecidos

---

## 🆘 Troubleshooting

### **Erro: "remote origin already exists"**
```bash
git remote remove origin
git remote add origin https://github.com/SEU_USUARIO/NOME_DO_REPO.git
```

### **Erro: "Authentication failed"**
```bash
# Use Personal Access Token como senha
# Não use a senha do GitHub!
```

### **Erro: "repository not found"**
```bash
# Verifique se o repositório existe no GitHub
# Verifique se a URL está correta
git remote -v
```

### **Erro: "Permission denied"**
```bash
# Verifique se você tem permissão de escrita no repositório
# Verifique se o token tem scope "repo"
```

---

## ✅ Checklist Final

Antes de fazer push:

- [ ] Repositório criado no GitHub
- [ ] `.env` NÃO está no git
- [ ] `.env.example` SIM está no git
- [ ] `.gitignore` está correto
- [ ] Sem credenciais expostas no código
- [ ] Personal Access Token criado (se necessário)
- [ ] Remote `origin` configurado
- [ ] Branch `main` configurada

---

## 🚀 AÇÃO RECOMENDADA AGORA

**Escolha uma opção:**

### **Opção 1: Configurar GitHub no Sandbox**
1. Vá na aba #github do sandbox
2. Autorize GitHub
3. Volte aqui e peça upload novamente

### **Opção 2: Download e Upload Manual**
1. Baixe `/home/user/webapp-api-completo-vpn.tar.gz`
2. Extraia na sua máquina
3. Crie repositório no GitHub
4. Faça push manual

### **Opção 3: Aguardar Autorização**
- Se preferir, posso aguardar você configurar o GitHub

---

**🎯 Qual opção você prefere?**

1. Configurar GitHub no sandbox e tentar novamente
2. Fazer upload manual
3. Precisa de mais ajuda

**Responda e eu continuo!** 🚀
