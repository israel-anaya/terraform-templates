export VAULT_TOKEN=${ROOT_TOKEN}

vault login $VAULT_TOKEN

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760h pki

vault write pki/root/generate/internal \
    common_name=${COMMON_NAME} \
    ttl=8760h

vault write pki/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

vault write pki/roles/${PKI_ROLE} \
    allowed_domains=${COMMON_NAME} \
    enforce_hostnames=false \
    allow_client=true \
    allow_any_name=true \
    allow_bare_domains=true \
    allow_localhost=true \
    allow_wildcard_certificates=true \
    allow_subdomains=true \
    max_ttl=72h

 
vault policy write pki - <<EOF
    path "pki*"                    { capabilities = ["read", "list"] }
    path "pki/sign/${PKI_ROLE}"    { capabilities = ["create", "update"] }
    path "pki/issue/${PKI_ROLE}"   { capabilities = ["create"] }
EOF


# Enable the Kubernetes authentication method.
vault auth enable kubernetes

vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

vault write auth/kubernetes/role/main-vault-issuer \
    bound_service_account_names=${SERVICE_ACCOUNT_NAME} \
    bound_service_account_namespaces=${NAMESPACE} \
    policies=pki \
    ttl=20m


