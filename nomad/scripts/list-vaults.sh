#!/bin/bash

echo "Vault servers:"
for vault in `vagrant ssh-config | awk '/HostName/ {print $2}'`; do
  echo "http://$vault:8200/"
done
