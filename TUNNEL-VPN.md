# 🔐 Conexão VPN para SQL Server - Guia Completo

## 📖 Visão Geral

Conectar a API no sandbox ao SQL Server interno (192.168.100.14:1433) através de **VPN segura**.

---

## 🎯 Opções de VPN Disponíveis

| VPN | Dificuldade | Velocidade | Segurança | Custo | Recomendado Para |
|-----|-------------|------------|-----------|-------|------------------|
| **WireGuard** | ⭐⭐ | ⚡⚡⚡⚡⚡ | 🔒🔒🔒🔒🔒 | Grátis | Produção |
| **Tailscale** | ⭐ | ⚡⚡⚡⚡ | 🔒🔒🔒🔒🔒 | Grátis* | Mais simples |
| **ZeroTier** | ⭐ | ⚡⚡⚡⚡ | 🔒🔒🔒🔒 | Grátis* | Alternativa |
| **OpenVPN** | ⭐⭐⭐ | ⚡⚡⚡ | 🔒🔒🔒🔒 | Grátis | Compatibilidade |

*Free até 3 usuários/100 dispositivos

---

## 🚀 OPÇÃO 1: WireGuard (RECOMENDADO)

### **Por que WireGuard?**
- ✅ 4x mais rápido que OpenVPN
- ✅ Código simples e auditável (4.000 linhas vs 100.000 do OpenVPN)
- ✅ Criptografia moderna (ChaCha20, Curve25519)
- ✅ Baixo consumo de recursos
- ✅ Conexão automática e persistente

---

### **🎯 Arquitetura:**

```
┌──────────────────┐         VPN Tunnel          ┌────────────────────┐
│   API Sandbox    │ ◄═══════════════════════► │  Servidor VPN      │
│   10.0.0.2       │  Criptografado (ChaCha20)  │  10.0.0.1          │
└──────────────────┘                             └────────┬───────────┘
                                                          │
                                                          │ Roteamento
                                                          │
                                              ┌───────────▼──────────┐
                                              │  Rede Interna        │
                                              │  192.168.100.0/24    │
                                              │                      │
                                              │  ┌────────────────┐ │
                                              │  │  SQL Server    │ │
                                              │  │ 192.168.100.14 │ │
                                              │  └────────────────┘ │
                                              └─────────────────────┘
```

---

### **📦 Passo 1: Instalar WireGuard no Servidor (Rede Interna)**

#### **Windows:**

1. **Baixar e Instalar:**
   - https://www.wireguard.com/install/
   - Baixar e executar `wireguard-installer.exe`
   - Instalar como administrador

2. **Gerar Chaves Criptográficas:**
   ```powershell
   # Abrir PowerShell como Administrador
   cd "C:\Program Files\WireGuard"
   
   # Gerar par de chaves do SERVIDOR
   .\wg.exe genkey | Tee-Object -FilePath server_private.key | .\wg.exe pubkey | Tee-Object -FilePath server_public.key
   
   # Gerar par de chaves do CLIENTE (sandbox)
   .\wg.exe genkey | Tee-Object -FilePath client_private.key | .\wg.exe pubkey | Tee-Object -FilePath client_public.key
   
   # Exibir chaves
   Write-Host "`n=== CHAVES GERADAS ===" -ForegroundColor Green
   Write-Host "`nServidor Privada:" -ForegroundColor Yellow
   Get-Content server_private.key
   Write-Host "`nServidor Pública:" -ForegroundColor Yellow
   Get-Content server_public.key
   Write-Host "`nCliente Privada:" -ForegroundColor Yellow
   Get-Content client_private.key
   Write-Host "`nCliente Pública:" -ForegroundColor Yellow
   Get-Content client_public.key
   ```

   **⚠️ IMPORTANTE: Anote todas as 4 chaves!**

3. **Descobrir Adaptador de Rede:**
   ```powershell
   Get-NetAdapter | Select-Object Name, InterfaceDescription
   ```
   
   Anote o **Name** do adaptador conectado à rede interna (ex: "Ethernet")

4. **Criar Configuração do Servidor:**
   
   Abra o WireGuard GUI → **Add Empty Tunnel** → Cole:

   ```ini
   [Interface]
   PrivateKey = <COLE_server_private.key_AQUI>
   Address = 10.0.0.1/24
   ListenPort = 51820
   
   # Habilitar roteamento para rede interna
   PostUp = netsh interface ipv4 set interface "Ethernet" forwarding=enabled
   PostDown = netsh interface ipv4 set interface "Ethernet" forwarding=disabled
   
   [Peer]
   # Cliente: API Sandbox
   PublicKey = <COLE_client_public.key_AQUI>
   AllowedIPs = 10.0.0.2/32
   PersistentKeepalive = 25
   ```

   **⚠️ Substitua:**
   - `<COLE_server_private.key_AQUI>` → Chave privada do servidor
   - `<COLE_client_public.key_AQUI>` → Chave pública do cliente
   - `"Ethernet"` → Nome do seu adaptador de rede (passo 3)

5. **Salvar como:** `WayBrasil-VPN`

6. **Configurar Firewall Windows:**
   ```powershell
   # Abrir porta UDP 51820
   New-NetFirewallRule -DisplayName "WireGuard VPN" -Direction Inbound -Protocol UDP -LocalPort 51820 -Action Allow
   ```

7. **Descobrir IP Público da Rede:**
   ```powershell
   # Ver IP público
   Invoke-RestMethod -Uri "https://api.ipify.org?format=text"
   ```
   
   **⚠️ Anote este IP PÚBLICO!**

8. **Configurar Port Forwarding no Roteador:**
   
   Acesse o painel do roteador (geralmente http://192.168.100.1):
   
   - **Protocolo:** UDP
   - **Porta Externa:** 51820
   - **IP Interno:** (IP da máquina Windows com WireGuard)
   - **Porta Interna:** 51820
   
   **Como descobrir o IP interno da máquina:**
   ```powershell
   ipconfig | Select-String "IPv4"
   ```

9. **Ativar Túnel:**
   - No WireGuard GUI, clique em **Activate** no túnel `WayBrasil-VPN`

---

#### **Linux (Ubuntu/Debian):**

```bash
# 1. Instalar WireGuard
sudo apt update
sudo apt install wireguard wireguard-tools -y

# 2. Gerar chaves
sudo mkdir -p /etc/wireguard
cd /etc/wireguard

# Servidor
wg genkey | sudo tee server_private.key | wg pubkey | sudo tee server_public.key

# Cliente
wg genkey | sudo tee client_private.key | wg pubkey | sudo tee client_public.key

# Proteger chaves
sudo chmod 600 server_private.key client_private.key

# Exibir chaves
echo "=== CHAVES GERADAS ==="
echo "Servidor Privada:"
sudo cat server_private.key
echo "Servidor Pública:"
sudo cat server_public.key
echo "Cliente Privada:"
sudo cat client_private.key
echo "Cliente Pública:"
sudo cat client_public.key
```

**⚠️ ANOTE TODAS AS 4 CHAVES!**

```bash
# 3. Descobrir interface de rede
ip -o -4 addr show | awk '{print $2, $4}'
```

Anote a interface conectada à rede interna (ex: `eth0`, `enp0s3`)

```bash
# 4. Criar configuração do servidor
sudo nano /etc/wireguard/wg0.conf
```

Cole (substituindo os valores):

```ini
[Interface]
PrivateKey = <COLE_server_private.key>
Address = 10.0.0.1/24
ListenPort = 51820

# Habilitar roteamento (substitua eth0 pela sua interface)
PostUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# Cliente: API Sandbox
PublicKey = <COLE_client_public.key>
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 25
```

```bash
# 5. Habilitar IP forwarding permanente
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 6. Configurar firewall
sudo ufw allow 51820/udp
sudo ufw reload

# 7. Iniciar WireGuard
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# 8. Verificar status
sudo wg show

# 9. Descobrir IP público
curl -4 https://api.ipify.org
```

**⚠️ Anote o IP público!**

---

### **📱 Passo 2: Configurar Cliente no Sandbox**

Agora vamos configurar o cliente WireGuard no sandbox para conectar ao servidor VPN.

**Execute no sandbox:**

```bash
cd /home/user/webapp-api

# 1. Instalar WireGuard
./wireguard-client-setup.sh

# 2. Configurar conexão (você precisará das chaves e IP público anotados)
./wireguard-client-configure.sh
```

O script pedirá:
1. **Chave privada do cliente** (client_private.key)
2. **Chave pública do servidor** (server_public.key)
3. **IP público do servidor** (anotado no passo anterior)

---

### **🔌 Passo 3: Conectar à VPN**

```bash
# Conectar
sudo wg-quick up wg0

# Verificar conexão
sudo wg show

# Saída esperada:
# interface: wg0
#   public key: ...
#   private key: (hidden)
#   listening port: ...
#
# peer: <chave_pública_servidor>
#   endpoint: <ip_público>:51820
#   allowed ips: 10.0.0.0/24, 192.168.100.0/24
#   latest handshake: X seconds ago
#   transfer: X KiB received, Y KiB sent
```

**✅ Se "latest handshake" aparecer = CONECTADO!**

---

### **🧪 Passo 4: Testar Conexão com SQL Server**

```bash
cd /home/user/webapp-api

# 1. Atualizar .env para usar IP da rede interna
cat > .env << 'EOF'
# SQL Server via VPN
DB_SERVER=192.168.100.14
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

# 2. Testar conexão
node test-connection.js
```

**Saída esperada:**
```
🔍 Testando conexão com SQL Server...
Servidor: 192.168.100.14:1433
Banco de Dados: ABOT

✅ Conexão bem-sucedida!
📊 Resultado do teste: [{"test":1}]
```

---

### **🚀 Passo 5: Iniciar API**

```bash
cd /home/user/webapp-api

# Instalar dependências (se ainda não instalou)
npm install

# Iniciar com PM2
pm2 start ecosystem.config.cjs --name webapp-api

# Verificar logs
pm2 logs webapp-api --nostream

# Testar endpoint
curl -H "x-api-key: webapp-api-key-2024-secure-change-in-production" http://localhost:3001/health
```

---

### **🔧 Comandos Úteis da VPN**

```bash
# Conectar
sudo wg-quick up wg0

# Desconectar
sudo wg-quick down wg0

# Status
sudo wg show

# Ver configuração
sudo cat /etc/wireguard/wg0.conf

# Teste de ping no servidor VPN
ping 10.0.0.1

# Teste de ping no SQL Server
ping 192.168.100.14

# Reconectar (se cair)
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

---

## 🚀 OPÇÃO 2: Tailscale (MAIS SIMPLES)

### **Por que Tailscale?**
- ✅ **Zero configuração** de firewall/roteador
- ✅ WireGuard gerenciado na nuvem
- ✅ Setup em 2 minutos
- ✅ Funciona atrás de NAT/firewall
- ✅ Grátis até 100 dispositivos

### **Desvantagens:**
- ❌ Depende de serviço terceiro (Tailscale Inc.)
- ❌ Requer conta Tailscale

---

### **📦 Setup Tailscale:**

#### **Servidor (Windows/Linux):**

```bash
# Windows: Baixar e instalar
# https://tailscale.com/download/windows

# Linux
curl -fsSL https://tailscale.com/install.sh | sh

# Autenticar (abrirá navegador)
sudo tailscale up

# Ver IP Tailscale
tailscale ip -4
```

#### **Cliente (Sandbox):**

```bash
# Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Autenticar (mesma conta do servidor)
sudo tailscale up

# Ver IP do servidor na rede Tailscale
tailscale status
```

#### **Configurar API:**

```bash
# Atualizar .env
DB_SERVER=<IP_TAILSCALE_DO_SERVIDOR>
DB_PORT=1433

# Testar
node test-connection.js
```

**✅ Pronto! Sem port forwarding, sem firewall!**

---

## 🚀 OPÇÃO 3: ZeroTier (ALTERNATIVA)

Similar ao Tailscale, também gerenciado na nuvem.

```bash
# Servidor e Cliente
curl -s https://install.zerotier.com | sudo bash

# Criar rede em: https://my.zerotier.com/
# Anotar NETWORK_ID

# Entrar na rede
sudo zerotier-cli join <NETWORK_ID>

# Autorizar dispositivos no painel web

# Ver IP
sudo zerotier-cli listnetworks
```

---

## 📊 Comparação de Opções VPN

| Critério | WireGuard | Tailscale | ZeroTier | OpenVPN |
|----------|-----------|-----------|----------|---------|
| **Velocidade** | ⚡⚡⚡⚡⚡ | ⚡⚡⚡⚡ | ⚡⚡⚡⚡ | ⚡⚡⚡ |
| **Segurança** | 🔒🔒🔒🔒🔒 | 🔒🔒🔒🔒🔒 | 🔒🔒🔒🔒 | 🔒🔒🔒🔒 |
| **Facilidade** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| **Port Forwarding** | ✅ Necessário | ❌ Não precisa | ❌ Não precisa | ✅ Necessário |
| **Custo** | Grátis | Grátis* | Grátis* | Grátis |
| **Controle** | Total | Parcial | Parcial | Total |
| **Produção** | ✅ Ideal | ✅ Ótimo | ✅ Bom | ✅ Tradicional |

*Free até 100 dispositivos

---

## 🎯 Recomendação Final

### **Se você tem acesso ao roteador e quer controle total:**
→ Use **WireGuard** (OPÇÃO 1)

### **Se quer rapidez e simplicidade:**
→ Use **Tailscale** (OPÇÃO 2)

### **Se Tailscale não funcionar:**
→ Use **ZeroTier** (OPÇÃO 3)

---

## 🐛 Troubleshooting

### **WireGuard não conecta:**

```bash
# Ver logs
sudo journalctl -u wg-quick@wg0 -f

# Verificar porta aberta no servidor
nmap -sU -p 51820 <IP_PUBLICO_SERVIDOR>

# Desabilitar temporariamente firewall para teste
sudo ufw disable  # Linux
# ou no Windows: Desativar Windows Defender Firewall
```

### **Handshake não acontece:**

- Verificar port forwarding no roteador
- Confirmar IP público está correto
- Verificar se ISP bloqueia UDP 51820 (tentar porta 443)
- Verificar relógio sincronizado (WireGuard exige)

### **Conecta mas não acessa SQL Server:**

```bash
# Ping no SQL Server
ping 192.168.100.14

# Testar porta SQL
telnet 192.168.100.14 1433
# ou
nc -zv 192.168.100.14 1433

# Verificar roteamento
ip route show
```

---

## 📚 Próximos Passos

1. ✅ Escolher opção de VPN
2. ✅ Configurar servidor VPN
3. ✅ Configurar cliente no sandbox
4. ✅ Testar conexão SQL Server
5. ✅ Atualizar .env da API
6. ✅ Iniciar API com PM2
7. ✅ Conectar frontend à API

---

## ✅ Checklist Completo

### **WireGuard:**
- [ ] Instalar WireGuard no servidor
- [ ] Gerar 4 chaves (servidor pub/priv, cliente pub/priv)
- [ ] Criar config do servidor (wg0.conf)
- [ ] Abrir porta 51820/UDP no firewall
- [ ] Configurar port forwarding no roteador
- [ ] Anotar IP público do servidor
- [ ] Instalar WireGuard no sandbox
- [ ] Criar config do cliente com as chaves
- [ ] Conectar (`sudo wg-quick up wg0`)
- [ ] Testar handshake (`sudo wg show`)
- [ ] Testar ping no SQL (ping 192.168.100.14)
- [ ] Atualizar .env da API
- [ ] Testar conexão SQL (node test-connection.js)
- [ ] Iniciar API (pm2 start)

### **Tailscale:**
- [ ] Criar conta Tailscale
- [ ] Instalar no servidor
- [ ] Autenticar servidor
- [ ] Anotar IP Tailscale do servidor
- [ ] Instalar no sandbox
- [ ] Autenticar sandbox (mesma conta)
- [ ] Atualizar .env com IP Tailscale
- [ ] Testar conexão SQL
- [ ] Iniciar API

---

**🎯 Tempo estimado:**
- WireGuard: 30-45 minutos
- Tailscale: 5-10 minutos
- ZeroTier: 5-10 minutos

**💰 Custo:** Todos gratuitos

**🔒 Segurança:** Todas as opções são seguras para produção
