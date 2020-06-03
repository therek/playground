version = '0.11.0'
remote_file '/opt/nomad.zip' do
    source "https://releases.hashicorp.com/nomad/#{version}/nomad_#{version}_linux_amd64.zip"
end

archive_file '/opt/nomad.zip' do
    destination node['nomad']['install_dir']
    overwrite true
end

directory node['nomad']['data_dir'] do
    recursive true
end

template node['nomad']['srv_config'] do
    source 'server.hcl.erb'
    variables(
        :srv_dir => '/data/nomad/server',
        :ssl => false
    )
    notifies :restart, 'service[nomad-server]'
end

template node['nomad']['cln_config'] do
    source 'client.hcl.erb'
    variables(
        :hostname => node[:hostname],
        :cln_dir => '/data/nomad/client',
        :ssl => false
    )
    notifies :restart, 'service[nomad-client]'
end

include_recipe "nomad::service"
