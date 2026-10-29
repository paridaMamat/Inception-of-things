#!/usr/bin/env bash
set -e

mkdir -p /etc/systemd/resolved.conf.d

cat > /etc/systemd/resolved.conf.d/dns.conf <<EOF
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=9.9.9.9
DNSSEC=no
EOF

systemctl restart systemd-resolved

until getent hosts get.k3s.io >/dev/null 2>&1; do
    sleep 2
done

curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="server --node-ip=192.168.56.110" \
    sh -

until kubectl get nodes >/dev/null 2>&1; do
    sleep 2
done

kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml
kubectl apply -f /vagrant/confs/ingress.yaml