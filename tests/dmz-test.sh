#!/bin/bash
echo "=== DMZ Test Script ==="

IP=$(ip -4 addr show dev eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "Ejecutando tests desde $IP - $(cat /etc/hostname)"

# 1. Probar conexión HTTP a un servidor de actualizaciones (por ejemplo, Archive Ubuntu)
echo -e "\nProbando actualización vía HTTP..."
curl -s --connect-timeout 5 http://archive.ubuntu.com > /dev/null && echo "[*] OK!!!  HTTP de actualización OK" || echo "[!] Fallo!!! HTTP de actualización fallido"

# 2. Probar conexión HTTPS a un servidor de actualizaciones
echo -e "\nProbando actualización vía HTTPS..."
curl -s --connect-timeout 5 https://archive.ubuntu.com > /dev/null && echo "[*] OK!!!  HTTPS de actualización OK" || echo "[!] Fallo!!!  HTTPS de actualización fallido"

# 3. Probar resolución DNS
echo -e "\nProbando resolución DNS (dig google.com)..."
if command -v dig &>/dev/null; then
    dig +short google.com > /dev/null  && echo "[*] OK!!!  DNS OK" || echo "[!] Fallo!!!  DNS fallido"
else
    echo "No se encuentra dig; intenta con nslookup"
    nslookup google.com
fi

# 4. Probar consulta NTP (con ntpdate en modo query)
echo -e "\nProbando consulta NTP..."
nc -zu -w 5 pool.ntp.org 123 && echo "[*] OK!!! NTP OK!!" || echo "[!] Fallo!!!  NTP fallido"



