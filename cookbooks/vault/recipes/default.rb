version = '1.3.4'
data_dir = '/data/vault'
config_dir = node['vault']['config_dir']

remote_file '/opt/vault.zip' do
  source "https://releases.hashicorp.com/vault/#{version}/vault_#{version}_linux_amd64.zip"
end

archive_file '/opt/vault.zip' do
  destination node['vault']['install_dir']
  overwrite true
end

group 'vault'

user 'vault' do
  gid 'vault'
  home data_dir
end

[data_dir, node['vault']['config_dir']].each do |dir|
  directory dir do
    recursive true
  end
end

template "#{node['vault']['config_dir']}/vault.hcl" do
  source 'vault.hcl.erb'
  variables(
    :ipaddress => node[:ipaddress],
    :hostname => node[:hostname],
    :domain => node['vault']['domain'],
    :ssl => false
  )
  notifies :restart, 'service[vault]'
end

include_recipe 'vault::service'
