remote_file "Copy CA certificate" do 
  path "/etc/pki/ca-trust/source/anchors/#{node['consul']['domain']}_intermediate.crt"
  source "file:///vagrant/pki/#{node['consul']['domain']}_intermediate.crt"
  notifies :run, 'execute[update-ca-trust]', :immediately
end

execute 'update-ca-trust' do
  command '/bin/update-ca-trust'
  action :nothing
end

template "#{node['consul']['config_dir']}/consul.json" do
  source 'consul.json.erb'
  variables(
    :hostname => node[:hostname],
    :domain => node['consul']['domain'],
    :ipaddress => node[:ipaddress],
    :ssl => true,
    :data_dir => node['consul']['data_dir'],
  )
  notifies :restart, 'service[consul]'
end

include_recipe 'consul::service'
