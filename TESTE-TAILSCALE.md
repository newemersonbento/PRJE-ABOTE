# 🧪 Guia de Testes Tailscale - IP 100.97.26.90

## ❓ Questão Crítica

Você configurou `DB_SERVER=100.97.26.90` (IP Tailscale), mas precisamos **confirmar** onde esse IP está:

- **Opção A**: É o IP da **SUA MÁQUINA** (não tem SQL Server)
- **Opção B**: É o IP do **SERVIDOR SQL** (192.168.100.14 com Tailscale)
- **Opção C**: É **OUTRA MÁQUINA** na rede Tailscale

---

## 🔧 Testes que você DEVE executar (na sua máquina)

### **Windows PowerShell**

```powershell
# Teste 1: Verificar SEU IP Tailscale
tailscale ip -4

# Teste 2: Listar TODOS os dispositivos Tailscale
tailscale status

# Teste 3: Testar conectividade com 100.97.26.90
Test-NetConnection -ComputerName 100.97.26.90 -Port 1433

# Teste 4: Testar SQL Server na rede interna
Test-NetConnection -ComputerName 192.168.100.14 -Port 1433

# Teste 5: Verificar se SQL Server está rodando localmente
Get-Service | Where-Object {$_.Name -like "*SQL*"} | Select-Object Name, Status, DisplayName
```

### **Linux/Mac Terminal**

```bash
# Teste 1: Verificar SEU IP Tailscale
tailscale ip -4

# Teste 2: Listar TODOS os dispositivos Tailscale
tailscale status

# Teste 3: Testar conectividade com 100.97.26.90
nc -zv 100.97.26.90 1433
# OU
telnet 100.97.26.90 1433

# Teste 4: Testar SQL Server na rede interna
nc -zv 192.168.100.14 1433
# OU
telnet 192.168.100.14 1433

# Teste 5: Verificar se SQL Server está rodando localmente
ps aux | grep sql
# OU
systemctl status mssql-server
```

---

## 📊 Interpretação dos Resultados

### **Cenário 1: 100.97.26.90 é a SUA máquina**

**Resultado do Teste 1**:
```
100.97.26.90
```

**O que isso significa**:
- ❌ Você está tentando conectar ao SQL Server **na sua própria máquina**
- ❌ O SQL Server está em **192.168.100.14** (não na sua máquina)
- ✅ **SOLUÇÃO**: Mudar `.env` para usar `DB_SERVER=192.168.100.14`

**Ação correta**:
```env
# Usar IP da rede interna (não Tailscale)
DB_SERVER=192.168.100.14
DB_PORT=1433
DB_DATABASE=ABOT
DB_USER=abot
DB_PASSWORD=New@3260
DB_ENCRYPT=false
DB_TRUST_CERTIFICATE=true
```

---

### **Cenário 2: 100.97.26.90 é o SERVIDOR SQL**

**Resultado do Teste 2 mostra algo como**:
```
100.97.26.90  server-sql      tagged   online
```

**E o Teste 3 retorna**:
```
TcpTestSucceeded : True
```

**O que isso significa**:
- ✅ O servidor SQL (192.168.100.14) **TEM Tailscale instalado**
- ✅ O IP Tailscale do SQL Server é `100.97.26.90`
- ✅ **SOLUÇÃO**: Configuração está CORRETA, mas o **sandbox não consegue acessar**

**Ação correta**:
- Manter `DB_SERVER=100.97.26.90` no `.env` **da sua máquina**
- Rodar a API **localmente** (não no sandbox)
- O sandbox **nunca** conseguirá acessar a rede Tailscale

---

### **Cenário 3: 100.97.26.90 é OUTRA máquina**

**Resultado do Teste 2 mostra**:
```
100.97.26.90  outra-maquina   tagged   online
```

**O que isso significa**:
- ⚠️ Você configurou o IP de uma máquina **que não é o SQL Server**
- ❌ O SQL Server está em outro lugar
- ✅ **SOLUÇÃO**: Identificar o IP correto do SQL Server

**Ação correta**:
1. Execute `tailscale status` e procure por "sql", "server", "192.168.100.14"
2. Ou use `DB_SERVER=192.168.100.14` diretamente

---

## 🎯 Como Decidir

Execute este script completo e **me envie o resultado**:

### **Windows (PowerShell)**

```powershell
Write-Host "=== DIAGNÓSTICO TAILSCALE ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. MEU IP TAILSCALE:" -ForegroundColor Yellow
tailscale ip -4
Write-Host ""

Write-Host "2. DISPOSITIVOS TAILSCALE:" -ForegroundColor Yellow
tailscale status
Write-Host ""

Write-Host "3. TESTE 100.97.26.90:1433:" -ForegroundColor Yellow
Test-NetConnection -ComputerName 100.97.26.90 -Port 1433 | Select-Object ComputerName, RemotePort, TcpTestSucceeded
Write-Host ""

Write-Host "4. TESTE 192.168.100.14:1433:" -ForegroundColor Yellow
Test-NetConnection -ComputerName 192.168.100.14 -Port 1433 | Select-Object ComputerName, RemotePort, TcpTestSucceeded
Write-Host ""

Write-Host "5. SERVIÇOS SQL SERVER LOCAIS:" -ForegroundColor Yellow
Get-Service | Where-Object {$_.Name -like "*SQL*"} | Select-Object Name, Status, DisplayName
Write-Host ""

Write-Host "=== FIM DO DIAGNÓSTICO ===" -ForegroundColor Cyan
```

### **Linux/Mac (Bash)**

```bash
echo "=== DIAGNÓSTICO TAILSCALE ==="
echo ""

echo "1. MEU IP TAILSCALE:"
tailscale ip -4
echo ""

echo "2. DISPOSITIVOS TAILSCALE:"
tailscale status
echo ""

echo "3. TESTE 100.97.26.90:1433:"
timeout 5 bash -c "echo > /dev/tcp/100.97.26.90/1433" 2>&1 && echo "✅ CONECTADO" || echo "❌ FALHOU"
echo ""

echo "4. TESTE 192.168.100.14:1433:"
timeout 5 bash -c "echo > /dev/tcp/192.168.100.14/1433" 2>&1 && echo "✅ CONECTADO" || echo "❌ FALHOU"
echo ""

echo "5. PROCESSOS SQL SERVER:"
ps aux | grep -i sql | grep -v grep
echo ""

echo "=== FIM DO DIAGNÓSTICO ==="
```

---

## ✅ Resposta Rápida

**Com base na configuração `DB_SERVER=100.97.26.90`, responda**:

### **Pergunta 1**: Qual é o resultado de `tailscale ip -4` na sua máquina?
- [ ] `100.97.26.90` (é o IP da minha máquina)
- [ ] Outro IP (ex: `100.x.x.x`)
- [ ] Erro ou comando não encontrado

### **Pergunta 2**: O Teste 3 (`Test-NetConnection 100.97.26.90 -Port 1433`) retorna?
- [ ] `TcpTestSucceeded : True` ✅
- [ ] `TcpTestSucceeded : False` ❌
- [ ] Timeout ou erro

### **Pergunta 3**: Você instalou Tailscale no **servidor SQL** (192.168.100.14)?
- [ ] Sim, eu instalei
- [ ] Não, não tenho acesso ao servidor
- [ ] Não sei

---

## 🚀 Próximos Passos (após os testes)

### **Se 100.97.26.90 = SUA MÁQUINA**
```bash
# Mudar .env para:
DB_SERVER=192.168.100.14

# Rodar API localmente
npm start
```

### **Se 100.97.26.90 = SERVIDOR SQL**
```bash
# .env está correto
DB_SERVER=100.97.26.90

# Rodar API localmente (sandbox não funciona)
npm start
```

### **Se 100.97.26.90 = OUTRA MÁQUINA**
```bash
# Descobrir IP correto do SQL Server
tailscale status | grep -i sql
# OU usar rede interna
DB_SERVER=192.168.100.14

# Rodar API localmente
npm start
```

---

## 📝 Resumo

| Cenário | DB_SERVER | Onde rodar API | Status Sandbox |
|---------|-----------|----------------|----------------|
| **IP = Minha máquina** | `192.168.100.14` | Local | ❌ Não funciona |
| **IP = Servidor SQL** | `100.97.26.90` | Local | ❌ Não funciona |
| **IP = Outra máquina** | Descobrir correto | Local | ❌ Não funciona |

---

## ⚠️ IMPORTANTE

**O sandbox NUNCA conseguirá conectar ao SQL Server**, independentemente da configuração, porque:
1. Não tem acesso à rede interna Way Brasil (192.168.100.x)
2. Não tem acesso à rede Tailscale (100.x.x.x)
3. Está isolado em uma rede Cloudflare separada

**✅ SOLUÇÃO DEFINITIVA**: Rodar a API na **sua máquina local**.

---

## 📞 Me envie os resultados

Execute o script de diagnóstico acima e **cole aqui**:
- Resultado do `tailscale ip -4`
- Resultado do `tailscale status`
- Resultado do teste de conectividade com 100.97.26.90:1433
- Resultado do teste de conectividade com 192.168.100.14:1433

Com essas informações, eu te digo **exatamente** qual configuração usar! 🎯
