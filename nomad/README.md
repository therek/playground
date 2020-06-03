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

### Prepare PKI on Vault

To prepare own Vault-based PKI run following commands:

        export VAULT_ADDR="http://<VAULT>:8200"
        export VAULT_TOKEN="<TOKEN>"
        scripts/vault-pki-enable.sh

### Enable TLS in Consul and Vault

First generate node certificates. This will generate and save CA certificates in `pki` directory.

        scripts/vault-pki-gencert.sh

Then synchronized files (`vagrant rsync`), log in to each server and go to local copy of Chef recepies and run:

        cd /tmp/vagrant-chef/7487e6f2443849d4462e0a967a3b3a4a
        chef-client -z -o consul::tls
        chef-client -z -o vault::tls

## Enable TLS in Nomad

Run on one of the nodes:

        chef-client -z -o nomad::tls

### Enable ACL in Consul

This uses the root token for global management policy. Usually, that is not the best way to go in production environment.

Long to each server and go to local copy of Chef recepies and run `consul::acl`.

        cd /tmp/vagrant-chef/7487e6f2443849d4462e0a967a3b3a4a
        chef-client -z -o consul::acl

Run on one of the nodes:

        export CONSUL_HTTP_ADDR=https://`hostname -I | awk '{print $1}'`:8500
        consul acl bootstrap
        export CONSUL_HTTP_TOKEN=<SecretID-from-bootstrap-output>
        consul acl policy create -name dns -rules @/vagrant/acl/consul/consul-dns-policy.hcl

Modify `/etc/consul/agent.hcl` on all nodes and add following. Restart Consul instance.

        tokens = {
          agent = "<SecretID-from-bootstrap-output"
        }

Modify `/etc/vault/vault.hcl` on all nodes and add following in the `storage` section. Restart Vault instance.

        token = "<SecretID-from-bootstrap-output>"

Modify `/data/nomad/server.hcl` and `/data/nomad/client.hcl` on all nodes and add following  in the `consul` section. Restart `nomad-server` and `nomad-client` services.

        token = "<SecretID-from-bootstrap-output>"
