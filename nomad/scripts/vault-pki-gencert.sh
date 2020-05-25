#!/bin/bash

[[ $# -ne 1 ]] && echo "Missing certificate name" && exit 1
[[ -z "$VAULT_TOKEN" ]] && echo "Variable VAULT_TOKEN not set" && exit 1

VAULT_ADDR=${VAULT_ADDR:=http://127.0.0.1:8200}

vault write pki_int/issue/dc1_consul common_name="$1" alt_names="server.dc1.consul" ttl="8760h"
