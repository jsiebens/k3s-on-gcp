#! /bin/bash

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.19.3+k3s3" sh -s - \
    --write-kubeconfig-mode 644 \
    --token "${token}" \
    --tls-san "${internal_lb_ip_address}" \
    --tls-san "${external_lb_ip_address}" \
    --node-taint "CriticalAddonsOnly=true:NoExecute" \
    --disable traefik \
    --datastore-endpoint "postgres://${db_user}:${db_password}@${db_host}:5432/${db_name}"