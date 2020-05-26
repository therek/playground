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

1. Visit other Vault instances to unseal them too.

## Set up TLS communication 

First steps are to be done in default configuration without TLS enabled.

### Prepare PKI

To prepare own Vault-based PKI run following commands:

        export VAULT_ADDR="http://<VAULT>:8200"
        export VAULT_TOKEN="<TOKEN>"
        scripts/vault-pki-enable.sh

### Enable TLS in Consul

First generate node certificates. This will generate and save CA certificates in `pki` directory.

        scripts/vault-pki-gencert.sh

Then synchronized files (`vagrant rsync`) and run following commands on each node:

        cp /vagrant/pki/dc1.consul_intermediate.crt /etc/pki/ca-trust/source/anchors/
        update-ca-trust
        systemctl stop consul vault
        cp /etc/consul/consul.json-tls /etc/consul/consul.json
        cp /etc/vault/vault.hcl-tls /etc/vault/vault.hcl
        systemctl start consul
        systemctl start vault
