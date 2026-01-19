#!/bin/bash
set -ex
# Activar el IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Limpiar reglas previas
iptables -F
iptables -t nat -F
iptables -Z
iptables -t nat -Z

# ANTI-LOCK rule: Permitir ssh a través de ETH0 para acceder con vagrant
iptables -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -j ACCEPT

# POLÍTICAS POR DEFECTO
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP


##############################
# Reglas de protección local
##############################
# L1. Permitir tráfico de loopback
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# L2. Permitir ping a cualquier máquina interna o externa
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

# L3. Permitir que me hagan ping desde LAN y DMZ
iptables -A INPUT -i eth2 -s 172.1.8.0/24 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i eth3 -s 172.2.8.0/24 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -o eth2 -s 172.1.8.1 -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -o eth3 -s 172.2.8.1 -p icmp --icmp-type echo-reply -j ACCEPT

# L4. Permitir consultas DNS
iptables -A OUTPUT -o eth0 -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -i eth0 -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT

##############################
# Reglas de protección red
##############################

##### Logs para depurar
iptables -A INPUT -j LOG --log-prefix "ARY-INPUT: "
iptables -A FORWARD -j LOG --log-prefix "ARY-INPUT: "
iptables -A OUTPUT -j LOG --log-prefix "ARY-INPUT: "