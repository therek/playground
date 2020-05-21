# Nomad playground

This playground initializes three VMs each running:

* Nomad
* Consul
* Vagrant

## Before you begin

To get the environment fully operational you have to initialize
Vault cluster:

1. List addresses for Vault instances:

        scripts/list-vaults.sh

1. Use the first link to initialize the cluster and unseal
   the instance.

1. Visit other Vault instances and to unseal them.

## Prepare PKI

To prepare own Vault-based PKI run following commands:

        export VAULT_ADDR="http://<VAULT>:8200"
        export VAULT_TOKEN="<TOKEN>"
        scripts/vault-pki-enable.sh
