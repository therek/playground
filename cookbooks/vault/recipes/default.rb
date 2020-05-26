version = '1.3.4'
domain = 'dc1.consul'

install_dir = '/usr/local/sbin'
data_dir = '/data/vault'
config_dir = '/etc/vault'

remote_file '/opt/vault.zip' do
  source "https://releases.hashicorp.com/vault/#{version}/vault_#{version}_linux_amd64.zip"
end

archive_file '/opt/vault.zip' do
  destination install_dir
  overwrite true
end

group 'vault'

user 'vault' do
  gid 'vault'
  home data_dir
end

[data_dir, config_dir].each do |dir|
  directory dir do
    recursive true
  end
end

template "#{config_dir}/vault.hcl" do
  source 'vault.hcl.erb'
  variables(
    :ipaddress => node[:ipaddress],
    :hostname => node[:hostname],
    :domain => domain,
    :ssl => false
  )
  notifies :restart, 'service[vault]'
end

template "#{config_dir}/vault.hcl-tls" do
  source 'vault.hcl.erb'
  variables(
    :ipaddress => node[:ipaddress],
    :hostname => node[:hostname],
    :domain => domain,
    :ssl => true
  )
end

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
      ExecStart: "#{install_dir}/vault server -config=#{config_dir}/vault.hcl -log-level=debug",
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
