#!/bin/bash
NUM=8
SERVIDOR_WEB="172.1.$NUM.3"
FW="172.1.$NUM.1"

echo "=== LAN Test Script ==="
IP=$(ip -4 addr show dev eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "Ejecutando tests desde $IP - $(cat /etc/hostname)"

# 1. Comprobar conectividad a Internet
echo -e "\nProbando ping a Internet (8.8.8.8)..."
ping -c 2 8.8.8.8 > /dev/null && echo "[*] OK!!!  Internet accesible" || echo "[!] FALLO!!!  Fallo en Internet"

# 2. Probar acceso HTTP al servidor web en la DMZ (172.99.1.10)
echo -e "\nProbando conexión HTTP al servidor DMZ ($SERVIDOR_WEB)..."
curl -s --connect-timeout 5 http://$SERVIDOR_WEB > /dev/null && echo "[*] OK!!!  Servidor web DMZ accesible" || echo "[!] Fallo!!! Servidor web DMZ inaccesible"

# 3. Comprobar acceso SSH al servidor web
echo -e "\nProbando conexión SSH al servidor ($SERVIDOR_WEB)..."
nc -z -w5 $SERVIDOR_WEB 22 > /dev/null && echo "SSH al servidor accesible (OK si eres admin-pc, ERROR si no)" || echo "SSH al servidor no accesible (ERROR si eres admin, OK si no)"

# 4. Comprobar acceso SSH al firewall
echo -e "\nProbando conexión SSH al servidor ($FW)..."
nc -z -w5 $FW 22 > /dev/null && echo "SSH al firewall accesible (OK si eres admin-pc, ERROR si no)" || echo "SSH al firewall no accesible (ERROR si eres admin, OK si no)"


# 5. Probar navegación web a un sitio externo
echo -e "\nProbando conexión HTTP a www.google.com..."
curl -s --connect-timeout 5 http://iescelia.org/web/ > /dev/null && echo "[*] OK!!!  Navegación OK" || echo "[!] Fallo!!!  Navegación fallida"

# Fin de lan-test.sh

