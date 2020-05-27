template "#{node['consul']['config_dir']}/agent.hcl" do
  source 'agent.hcl.erb'
  notifies :restart, 'service[consul]'
end

include_recipe "consul::service"
