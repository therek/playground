remote_file "Copy CA certificate" do 
  path "/etc/pki/ca-trust/source/anchors/#{node['nomad']['domain']}_chain.crt"
  source "file:///vagrant/pki/#{node['nomad']['domain']}_chain.crt"
  notifies :run, 'execute[update-ca-trust]', :immediately
end

execute 'update-ca-trust' do
  command '/bin/update-ca-trust'
  action :nothing
end

template node['nomad']['srv_config'] do
    source 'server.hcl.erb'
    variables(
        :hostname => node[:hostname],
        :srv_dir => '/data/nomad/server',
        :domain => node['nomad']['domain'],
        :ssl => true
    )
    notifies :restart, 'service[nomad-server]'
end

template node['nomad']['cln_config'] do
    source 'client.hcl.erb'
    variables(
        :hostname => node[:hostname],
        :cln_dir => '/data/nomad/client',
        :domain => node['nomad']['domain'],
        :ssl => true
    )
    notifies :restart, 'service[nomad-client]'
end


include_recipe 'nomad::service'
