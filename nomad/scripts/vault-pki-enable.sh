#!/bin/bash

[[ -z "$VAULT_TOKEN" ]] && echo "Variable VAULT_TOKEN not set" && exit 1

VAULT_ADDR=${VAULT_ADDR:=http://127.0.0.1:8200}
DOMAIN='dc1.consul'

mkdir -p pki

echo -n "Enabling PKI... "
if [[ `vault secrets list |grep ^pki` ]]; then
  echo "Already enabled."
else
  vault secrets enable pki
fi

echo -n "Set PKI max least to 10 years... "
vault secrets tune -max-lease-ttl=87600h pki

echo "Generate root certificate"
vault write -field=certificate pki/root/generate/internal \
  common_name="$DOMAIN" ttl=87600h > pki/${DOMAIN}_CA.crt

echo -n "Configure the CA and CRL URLs... "
vault write pki/config/urls \
  issuing_certificates="${VAULT_ADDR}/v1/pki/ca" \
  crl_distribution_points="${VAULT_ADDR}/v1/pki/crl"

echo -n "Enabling intermediate PKI... "
if [[ `vault secrets list |grep ^pki_int` ]]; then
  echo "Already enabled."
else
  vault secrets enable -path=pki_int pki
fi

echo -n "Set intermediate PKI max least to 5 years... "
vault secrets tune -max-lease-ttl=43800h pki_int

echo "Generate intermediate signing request"
vault write -format=json pki_int/intermediate/generate/internal \
  common_name="${DOMAIN} Intermediate Authority" | \
  jq -r '.data.csr' > pki/${DOMAIN}_intermediate.csr

echo "Sign intermediate certificate"
vault write -format=json pki/root/sign-intermediate csr=@pki/${DOMAIN}_intermediate.csr \
  format=pem_bundle ttl="43800h" | \
  jq -r '.data.certificate' > pki/${DOMAIN}_intermediate.crt

echo -n "Import signed intermediate certificate... "
vault write pki_int/intermediate/set-signed certificate=@pki/${DOMAIN}_intermediate.crt

echo -n "Create a role for generatic certificates... "
vault write pki_int/roles/${DOMAIN//./_} allowed_domains="${DOMAIN}" \
  allow_subdomains=true max_ttl="8760h"
