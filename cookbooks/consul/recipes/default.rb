include_recipe "consul::install"

template "#{node['consul']['config_dir']}/consul.json" do
  source 'consul.json.erb'
  variables(
    :hostname => node[:hostname],
    :domain => node['consul']['domain'],
    :ipaddress => node[:ipaddress],
    :ssl => false,
    :data_dir => node['consul']['data_dir'],
  )
  notifies :restart, 'service[consul]'
end

include_recipe "consul::service"
