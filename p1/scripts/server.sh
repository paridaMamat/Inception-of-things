#!/usr/bin/env bash
set -e

echo "[SERVER] Fixing DNS..."

mkdir -p /etc/systemd/resolved.conf.d

cat > /etc/systemd/resolved.conf.d/dns.conf <<EOF
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=9.9.9.9
DNSSEC=no
EOF

systemctl restart systemd-resolved

echo "[SERVER] Waiting for DNS..."

until getent hosts get.k3s.io >/dev/null 2>&1; do
    sleep 2
done

echo "[SERVER] Installing K3s server..."

curl -sfL https://get.k3s.io | \
    K3S_TOKEN="${K3S_TOKEN}" \
    INSTALL_K3S_EXEC="server --node-ip=192.168.56.110" \
    sh -

echo "[SERVER] Waiting for K3s..."

until kubectl get node >/dev/null 2>&1; do
    sleep 2
done

echo "[SERVER] K3s server ready."

kubectl get nodes -o wide
