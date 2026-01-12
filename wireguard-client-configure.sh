#!/bin/bash

echo "🔐 Configurando Cliente WireGuard no Sandbox"
echo ""

# Solicitar informações
read -p "Cole a CHAVE PRIVADA do cliente: " CLIENT_PRIVATE_KEY
read -p "Cole a CHAVE PÚBLICA do servidor: " SERVER_PUBLIC_KEY
read -p "Digite o IP PÚBLICO do servidor VPN: " SERVER_PUBLIC_IP

# Criar arquivo de configuração
sudo tee /etc/wireguard/wg0.conf > /dev/null << WGCONF
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_PUBLIC_IP}:51820
AllowedIPs = 10.0.0.0/24, 192.168.100.0/24
PersistentKeepalive = 25
WGCONF

# Ajustar permissões
sudo chmod 600 /etc/wireguard/wg0.conf

echo ""
echo "✅ Configuração criada em /etc/wireguard/wg0.conf"
echo ""
echo "🚀 Para conectar, execute:"
echo "   sudo wg-quick up wg0"
echo ""
echo "📊 Para verificar status:"
echo "   sudo wg show"
echo ""
echo "🛑 Para desconectar:"
echo "   sudo wg-quick down wg0"
