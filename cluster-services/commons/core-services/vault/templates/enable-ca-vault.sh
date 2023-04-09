export VAULT_TOKEN=${ROOT_TOKEN}

vault login $VAULT_TOKEN

# Step 1: Generate root CA

vault secrets enable pki

vault secrets tune -max-lease-ttl=87600h pki


vault write -field=certificate pki/root/generate/internal \
     common_name="${COMMON_NAME}" \
     issuer_name="root-ca" \
     ttl=87600h > root_ca.crt

vault write pki/roles/2022-servers allow_any_name=true

vault write pki/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

# Step 2: Generate intermediate CA

vault secrets enable -path=pki_int pki

vault secrets tune -max-lease-ttl=43800h pki_int

vault write -format=json pki_int/intermediate/generate/internal \
     common_name="${COMMON_NAME} Intermediate Authority" \
     issuer_name="${PKI_ROLE}-intermediate" \
     | jq -r '.data.csr' > pki_intermediate.csr

vault write -format=json pki/root/sign-intermediate \
     issuer_ref="root-ca" \
     csr=@pki_intermediate.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > intermediate.cert.pem

vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem

# Step 3: Create a role

vault write pki_int/roles/${PKI_ROLE} \
     issuer_ref="$(vault read -field=default pki_int/config/issuers)" \
     allowed_domains="${COMMON_NAME}" \
     allow_subdomains=true \
     max_ttl="720h"

# Step 4: Request certificates

vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="24h"

# Step 5: Revoke certificates

vault write pki_int/revoke \
    serial_number="3f:03:a9:10:e0:28:df:dc:d8:a8:f9:50:7b:cd:d4:8c:01:f5:47:5e"


# Step 6: Remove expired certificates
vault write pki_int/tidy tidy_cert_store=true tidy_revoked_certs=true


# Step 7: Rotate Root CA

vault write pki/root/rotate/internal \
    common_name="example.com" \
    issuer_name="root-2023"


# Step 8: Create a cross-signed intermediate

vault write -format=json pki/intermediate/cross-sign \
      common_name="example.com" \
      key_ref="$(vault read pki/issuer/root-2023 \
      | grep -i key_id | awk '{print $2}')" \
      | jq -r '.data.csr' \
      | tee cross-signed-intermediate.csr


vault write -format=json pki/issuer/root-2022/sign-intermediate \
      common_name="example.com" \
      csr=@cross-signed-intermediate.csr \
      | jq -r '.data.certificate' | tee cross-signed-intermediate.crt

vault write pki/intermediate/set-signed \
      certificate=@cross-signed-intermediate.crt


# Step 9: Set default issuer
vault write pki/root/replace default=root-2023

# Step 10: Sunset defunct Root CA

vault write pki/issuer/root-2022 \
      issuer_name="root-2022" \
      usage=read-only,crl-signing | tail -n 5

vault write pki/issuer/root-2022/issue/2022-servers \
    common_name="super.secret.internal.dev" \
    ttl=10m
