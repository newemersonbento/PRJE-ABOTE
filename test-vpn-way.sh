#!/bin/bash

echo "🔍 Testando Conectividade VPN Way Brasil"
echo "=========================================="
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Testar DNS
echo "1️⃣  Testando resolução DNS de vpn2.way306.com.br..."
if nslookup vpn2.way306.com.br > /dev/null 2>&1; then
    IP=$(nslookup vpn2.way306.com.br | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
    echo -e "${GREEN}✅ DNS OK - IP: $IP${NC}"
else
    echo -e "${RED}❌ DNS Falhou${NC}"
fi
echo ""

# 2. Testar conectividade porta 443
echo "2️⃣  Testando conectividade na porta 443..."
if timeout 5 bash -c "echo > /dev/tcp/vpn2.way306.com.br/443" 2>/dev/null; then
    echo -e "${GREEN}✅ Porta 443 ABERTA${NC}"
else
    echo -e "${RED}❌ Porta 443 FECHADA ou TIMEOUT${NC}"
fi
echo ""

# 3. Tentar identificar tipo de servidor
echo "3️⃣  Identificando tipo de servidor VPN..."
RESPONSE=$(curl -Isk --connect-timeout 5 https://vpn2.way306.com.br:443 2>/dev/null | head -5)
if [ -n "$RESPONSE" ]; then
    echo "$RESPONSE"
    
    if echo "$RESPONSE" | grep -qi "fortinet"; then
        echo -e "${YELLOW}🔍 Tipo detectado: Fortinet FortiGate${NC}"
    elif echo "$RESPONSE" | grep -qi "cisco"; then
        echo -e "${YELLOW}🔍 Tipo detectado: Cisco AnyConnect${NC}"
    elif echo "$RESPONSE" | grep -qi "openvpn"; then
        echo -e "${YELLOW}🔍 Tipo detectado: OpenVPN${NC}"
    else
        echo -e "${YELLOW}🔍 Tipo: Não identificado automaticamente${NC}"
    fi
else
    echo -e "${RED}❌ Sem resposta do servidor${NC}"
fi
echo ""

# 4. Testar SQL Server (após VPN - vai falhar se não estiver conectado)
echo "4️⃣  Testando conectividade SQL Server (192.168.100.14:1433)..."
if timeout 3 bash -c "echo > /dev/tcp/192.168.100.14/1433" 2>/dev/null; then
    echo -e "${GREEN}✅ SQL Server ACESSÍVEL (VPN provavelmente conectada!)${NC}"
else
    echo -e "${RED}❌ SQL Server INACESSÍVEL (VPN não conectada ou firewall)${NC}"
fi
echo ""

echo "=========================================="
echo "📋 Resumo:"
echo ""
echo "Para conectar à VPN Way Brasil, você precisa:"
echo "1. Acessar: https://vpn2.way306.com.br"
echo "2. Login: way306\emerson.totvs"
echo "3. Senha: waybrasil2025@"
echo "4. Baixar arquivo .ovpn ou instalar cliente VPN"
echo ""
echo "Após conectar, o SQL Server 192.168.100.14:1433 ficará acessível."
