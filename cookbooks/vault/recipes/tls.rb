remote_file "Copy CA certificate" do 
  path "/etc/pki/ca-trust/source/anchors/#{node['vault']['domain']}_chain.crt"
  source "file:///vagrant/pki/#{node['vault']['domain']}_chain.crt"
  notifies :run, 'execute[update-ca-trust]', :immediately
end

execute 'update-ca-trust' do
  command '/bin/update-ca-trust'
  action :nothing
end

template "#{node['vault']['config_dir']}/vault.hcl" do
  source 'vault.hcl.erb'
  variables(
    :ipaddress => node[:ipaddress],
    :hostname => node[:hostname],
    :domain => node['vault']['domain'],
    :ssl => true
  )
  notifies :restart, 'service[vault]'
end

include_recipe 'vault::service'
