#!/bin/bash
# ============================================================
# SCRIPT DE APERTURA DE PUERTOS Y CONFIGURACIÓN (ORACLE / VPS)
# Puertos por defecto: 80, 8080, 90, 443
# ============================================================

if [ "$EUID" -ne 0 ]; then
  echo "Ejecuta como root: sudo -i"
  exit 1
fi

echo "[1/4] Desactivando conflictos de firewall (UFW / Firewalld)..."
ufw disable 2>/dev/null
systemctl stop firewalld 2>/dev/null
systemctl disable firewalld 2>/dev/null

echo "[2/4] Configurando reglas de IPTables y abriendo puertos (80, 8080, 90, 443)..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Políticas base abiertas
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Apertura específica para los puertos solicitados
for puerto in 80 8080 90 443; do
  iptables -I INPUT -p tcp --dport "$puerto" -j ACCEPT
  iptables -I INPUT -p udp --dport "$puerto" -j ACCEPT
done

# IPv6
ip6tables -F 2>/dev/null
ip6tables -X 2>/dev/null
ip6tables -P INPUT ACCEPT 2>/dev/null
ip6tables -P FORWARD ACCEPT 2>/dev/null
ip6tables -P OUTPUT ACCEPT 2>/dev/null

echo "[3/4] Instalando dependencias para persistencia..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y && apt-get install -y iptables-persistent netfilter-persistent 2>/dev/null

# Guardar cambios para que no se borren al reiniciar
netfilter-persistent save 2>/dev/null
systemctl enable netfilter-persistent 2>/dev/null

echo "[4/4] ¡Listo! Puertos abiertos correctamente."
echo "============================================================"
echo " Puertos configurados y persistentes: 80, 8080, 90, 443"
echo "============================================================"
