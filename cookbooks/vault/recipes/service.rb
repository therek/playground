systemd_unit 'vault.service' do
  content({Unit: {
      Description: 'Vault Service',
      Requires: 'network-online.target',
      After: 'network-online.target'
    },
    Service: {
      User: 'vault',
      Group: 'vault',
      PIDFile: '/var/run/vault.pid',
      ExecStart: "#{node['vault']['install_dir']}/vault server -config=#{node['vault']['config_dir']}/vault.hcl -log-level=debug",
      ExecReload: '/bin/kill -HUP $MAINPID',
      KillMode: 'process',
      KillSignal: 'SIGTERM',
      Restart: 'on-failure',
      RestartSec: '42s',
      LimitMEMLOCK: 'infinity'
    },
    Install: {
      WantedBy: 'multi-user.target'
    }
  })
  action [:create, :enable]
  triggers_reload true
end

service 'vault' do
  action [:enable, :start]
end
