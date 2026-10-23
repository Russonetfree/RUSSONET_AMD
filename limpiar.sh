#!/bin/bash
# ============================================================
# SCRIPT DE LIMPIEZA PROFUNDA Y RESTAURACIÓN PARA VPS
# ============================================================

if [ "$EUID" -ne 0 ]; then
  echo "Ejecuta como root: sudo -i"
  exit 1
fi

echo "[1/6] Deteniendo y desactivando servicios del panel..."
systemctl stop ws_proxy badvpn v2ray dropbear stunnel4 apache2 lighttpd nginx 2>/dev/null
systemctl disable ws_proxy badvpn v2ray dropbear stunnel4 2>/dev/null
rm -f /etc/systemd/system/ws_proxy.service /etc/systemd/system/badvpn.service
systemctl daemon-reload

echo "[2/6] Eliminando archivos del panel, scripts y ejecutables..."
rm -rf /etc/adm-lite /etc/ADMcgh /etc/v2ray_util /usr/local/bin/ws_proxy.py /usr/local/bin/badvpn-udpgw
rm -rf /usr/bin/menu /usr/bin/adm /usr/bin/ejecutar /bin/ejecutar /usr/bin/autolim /usr/bin/autostart
rm -f /etc/russo_installed /etc/russo_passwords.txt /etc/versin_script* /etc/version_instalacion
rm -f /root/puertos.sh /root/usuarios.db /root/stilos.log /root/proxy.log /root/limpieza.log /root/name /root/speed /root/instalar.sh

echo "[3/6] Limpiando rastros visuales, logos y banners (VPS MX, CHUMO, etc.)..."
> /etc/issue
> /etc/issue.net
> /etc/motd
> /etc/banner
rm -f /etc/update-motd.d/99-banner 2>/dev/null

sed -i '/^menu$/d' /root/.bashrc
sed -i '/^adm$/d' /root/.bashrc
sed -i '/adm-lite/d' /root/.bashrc
sed -i '/^menu$/d' /root/.profile 2>/dev/null

sed -i 's|^Banner.*|#Banner none|' /etc/ssh/sshd_config
systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null

echo "[4/6] Restableciendo reglas de Firewall e IPTables..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

echo "[5/6] Limpiando paquetes huérfanos y caché del sistema..."
apt-get autoremove -y
apt-get clean -y

echo "[6/6] Limpieza completada con éxito."
echo "Reiniciando el servidor en 5 segundos..."
sleep 5
reboot
