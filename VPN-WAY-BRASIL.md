# 🔐 Credenciais VPN Way Brasil

## 📋 Informações de Conexão VPN

### **Servidor VPN:**
- **Host:** vpn2.way306.com.br
- **Porta:** 443 (HTTPS)
- **Tipo:** VPN Corporativa Way Brasil

### **Credenciais de Acesso:**
- **Domínio\Usuário:** way306\emerson.totvs
- **Senha:** waybrasil2025@

---

## 🎯 Tipo de VPN Detectado

Baseado no endereço `vpn2.way306.com.br:443`, esta é provavelmente uma:
- **VPN SSL/TLS** (porta 443)
- Possíveis protocolos:
  - OpenVPN (Access Server)
  - Fortinet FortiClient
  - Cisco AnyConnect
  - SonicWall NetExtender
  - Palo Alto GlobalProtect

---

## 🚀 OPÇÃO 1: Usar OpenVPN (Mais Comum)

### **Setup no Sandbox:**

```bash
# 1. Instalar OpenVPN
sudo apt update
sudo apt install openvpn -y

# 2. Baixar arquivo de configuração .ovpn
# Você precisa do arquivo .ovpn fornecido pela Way Brasil
# Geralmente disponível em: https://vpn2.way306.com.br

# 3. Criar arquivo de credenciais
cat > /tmp/vpn-credentials.txt << 'EOF'
way306\emerson.totvs
waybrasil2025@
EOF

chmod 600 /tmp/vpn-credentials.txt

# 4. Conectar à VPN
# (assumindo que você tem o arquivo way-brasil.ovpn)
sudo openvpn --config way-brasil.ovpn --auth-user-pass /tmp/vpn-credentials.txt
```

---

## 🚀 OPÇÃO 2: Usar FortiClient (Se for Fortinet)

```bash
# 1. Instalar FortiClient
wget -O forticlient.deb https://links.fortinet.com/forticlient/deb/vpnagent
sudo dpkg -i forticlient.deb
sudo apt-get install -f

# 2. Conectar via linha de comando
sudo /opt/fortinet/forticlient/bin/forticlient connect \
  --server vpn2.way306.com.br:443 \
  --username way306\\emerson.totvs \
  --password 'waybrasil2025@'

# 3. Verificar conexão
sudo /opt/fortinet/forticlient/bin/forticlient status
```

---

## 🚀 OPÇÃO 3: Usar OpenConnect (Cisco AnyConnect Compatible)

```bash
# 1. Instalar OpenConnect
sudo apt update
sudo apt install openconnect -y

# 2. Conectar
echo 'waybrasil2025@' | sudo openconnect \
  --protocol=anyconnect \
  --user=way306\\emerson.totvs \
  --passwd-on-stdin \
  vpn2.way306.com.br:443

# 3. Verificar conexão
ip addr show
```

---

## 📝 Passo a Passo Recomendado

### **1. Identificar o Tipo de VPN**

Primeiro, vamos descobrir qual software VPN a Way Brasil usa:

```bash
# Testar conexão HTTPS
curl -I https://vpn2.way306.com.br:443
```

A resposta vai nos dizer o tipo de servidor VPN.

### **2. Obter Arquivo de Configuração**

Acesse o portal VPN da Way Brasil e baixe o arquivo de configuração:

**URL provável:** https://vpn2.way306.com.br

- Faça login com: `way306\emerson.totvs` / `waybrasil2025@`
- Baixe o arquivo `.ovpn` ou o instalador do cliente VPN

### **3. Instalar Cliente VPN Apropriado**

Baseado no tipo detectado, instale o cliente correto.

---

## 🔧 Script de Conexão Automatizada

Vou criar um script para testar a conexão:

```bash
#!/bin/bash

echo "🔍 Testando conectividade com VPN Way Brasil..."
echo ""

# Testar DNS
echo "1. Testando resolução DNS..."
nslookup vpn2.way306.com.br
echo ""

# Testar conectividade HTTP
echo "2. Testando porta 443..."
timeout 5 nc -zv vpn2.way306.com.br 443 2>&1
echo ""

# Tentar identificar tipo de servidor
echo "3. Identificando tipo de servidor VPN..."
curl -Isk https://vpn2.way306.com.br:443 | head -10
echo ""

echo "✅ Testes concluídos!"
echo ""
echo "📋 Próximos passos:"
echo "1. Acesse https://vpn2.way306.com.br no navegador"
echo "2. Faça login com: way306\emerson.totvs"
echo "3. Baixe o arquivo de configuração ou instalador"
echo "4. Instale o cliente VPN apropriado"
```

---

## 🎯 SOLUÇÃO RÁPIDA: Conexão Manual

Se você estiver em uma **máquina local** (não no sandbox), siga estes passos:

### **Windows:**

1. **Baixar Cliente VPN:**
   - Acesse: https://vpn2.way306.com.br
   - Faça login: `way306\emerson.totvs` / `waybrasil2025@`
   - Baixe o cliente VPN (geralmente FortiClient, Cisco AnyConnect, etc.)

2. **Instalar e Conectar:**
   - Instale o cliente baixado
   - Configure:
     - **Servidor:** vpn2.way306.com.br:443
     - **Usuário:** way306\emerson.totvs
     - **Senha:** waybrasil2025@
   - Conecte

3. **Testar Conectividade:**
   ```powershell
   # Após conectar à VPN, teste o SQL Server
   Test-NetConnection -ComputerName 192.168.100.14 -Port 1433
   ```

4. **Configurar API:**
   ```bash
   # Atualizar .env
   DB_SERVER=192.168.100.14
   DB_PORT=1433
   
   # Testar conexão
   node test-connection.js
   
   # Iniciar API
   npm start
   ```

---

## 🐧 Setup no Sandbox (Precisa do Arquivo .ovpn)

```bash
# 1. Fazer upload do arquivo .ovpn para o sandbox
# (você pode colar o conteúdo do arquivo aqui)

# 2. Criar arquivo de credenciais
cat > /etc/openvpn/credentials.txt << 'EOF'
way306\emerson.totvs
waybrasil2025@
EOF

sudo chmod 600 /etc/openvpn/credentials.txt

# 3. Conectar
sudo openvpn --config /etc/openvpn/way-brasil.ovpn \
             --auth-user-pass /etc/openvpn/credentials.txt \
             --daemon

# 4. Verificar conexão
sleep 5
ip addr show tun0

# 5. Testar SQL Server
ping 192.168.100.14
telnet 192.168.100.14 1433
```

---

## ⚠️ IMPORTANTE: Próximos Passos

Como você tem **VPN corporativa já configurada**, temos 2 cenários:

### **Cenário A: Rodar API na Sua Máquina Local**

1. **Conecte sua máquina à VPN Way Brasil**
2. **Extraia o pacote webapp-api-completo-vpn.tar.gz**
3. **Configure .env:**
   ```env
   DB_SERVER=192.168.100.14
   DB_PORT=1433
   DB_DATABASE=ABOT
   DB_USER=abot
   DB_PASSWORD=New@3260
   DB_ENCRYPT=false
   DB_TRUST_CERTIFICATE=true
   ```
4. **Teste:** `node test-connection.js`
5. **Inicie:** `npm start`

✅ **ESTE É O CAMINHO MAIS SIMPLES!**

---

### **Cenário B: Rodar API no Sandbox (Precisa Configurar VPN)**

Para rodar no sandbox, precisamos:

1. **Arquivo de configuração .ovpn** da VPN Way Brasil
2. **Instalar cliente VPN no sandbox**
3. **Conectar à VPN corporativa**
4. **Depois configurar a API**

**⚠️ Você tem o arquivo .ovpn?**

---

## 🎯 RECOMENDAÇÃO IMEDIATA

**OPÇÃO MAIS RÁPIDA:** Rodar a API na **sua máquina local** conectada à VPN:

```bash
# NA SUA MÁQUINA (Windows/Linux/Mac):

# 1. Conectar à VPN Way Brasil
# Use o cliente VPN instalado na sua máquina

# 2. Extrair pacote
tar -xzf webapp-api-completo-vpn.tar.gz
cd webapp-api

# 3. Instalar dependências
npm install

# 4. Configurar .env
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

ALLOWED_ORIGINS=http://localhost:3000,https://3000-ig1zg8d9l1gqcefs84wxz-b9b802c4.sandbox.novita.ai
EOF

# 5. Aplicar schema SQL
# Abra SSMS e execute schema.sql e seed.sql

# 6. Testar conexão
node test-connection.js

# 7. Iniciar API
npm start

# 8. Em outro terminal, expor via ngrok (opcional)
ngrok http 3001
```

✅ **PRONTO! API conectada via VPN corporativa!**

---

## 📋 Checklist VPN Corporativa

- [ ] Já tem cliente VPN instalado na máquina?
- [ ] Consegue conectar à VPN Way Brasil?
- [ ] Após conectar, consegue acessar 192.168.100.14?
- [ ] Tem o arquivo .ovpn para configurar no sandbox?

---

## 🆘 Precisa de Ajuda?

Me informe:
1. **Onde vai rodar a API?** (Sua máquina local OU sandbox)
2. **Tem o arquivo .ovpn?** (Se quiser rodar no sandbox)
3. **Qual sistema operacional?** (Windows, Linux, Mac)

Assim posso dar instruções mais precisas! 🚀
