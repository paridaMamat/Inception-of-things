#!/usr/bin/env bash
set -e

echo "[WORKER] Fixing DNS..."

mkdir -p /etc/systemd/resolved.conf.d

cat > /etc/systemd/resolved.conf.d/dns.conf <<EOF
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=9.9.9.9
DNSSEC=no
EOF

systemctl restart systemd-resolved

echo "[WORKER] Waiting for DNS..."

until getent hosts get.k3s.io >/dev/null 2>&1; do
    sleep 2
done

echo "[WORKER] Waiting for K3s server..."

until nc -z 192.168.56.110 6443; do
    sleep 2
done

echo "[WORKER] Installing K3s agent..."

curl -sfL https://get.k3s.io | \
    K3S_URL="https://192.168.56.110:6443" \
    K3S_TOKEN="${K3S_TOKEN}" \
    INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111" \
    sh -

echo "[WORKER] K3s agent installed."