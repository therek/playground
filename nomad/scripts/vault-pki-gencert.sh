#!/bin/bash

[[ -z "$VAULT_TOKEN" ]] && echo "Variable VAULT_TOKEN not set" && exit 1
DOMAIN='dc1.consul'
VAULT_ADDR=${VAULT_ADDR:=http://127.0.0.1:8200}

for node in node1 node2 node3; do
  echo "Generate certificate for $node.node.${DOMAIN}"
  TMPFILE=`mktemp`
  vault write -format=json pki_int/issue/${DOMAIN//./_} common_name="$node.node.${DOMAIN}" alt_names="server.${DOMAIN}" ttl="8760h" > $TMPFILE
  cat $TMPFILE | jq '.data.certificate' | xargs echo -e > pki/$node.node.${DOMAIN}.crt
  cat $TMPFILE | jq '.data.certificate' | xargs echo -e > pki/$node.node.${DOMAIN}.chain.crt
  cat $TMPFILE | jq '.data.private_key' | xargs echo -e > pki/$node.node.${DOMAIN}.key
  cat $TMPFILE | jq '.data.issuing_ca'  | xargs echo -e >> pki/$node.node.${DOMAIN}.crt
  rm $TMPFILE
done
