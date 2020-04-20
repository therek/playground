version = '0.11.0'
install_dir = '/usr/local/sbin'
data_dir = '/data/nomad'
srv_config = "#{data_dir}/server.hcl"
cln_config = "#{data_dir}/client.hcl"

remote_file '/opt/nomad.zip' do
    source "https://releases.hashicorp.com/nomad/#{version}/nomad_#{version}_linux_amd64.zip"
end

archive_file '/opt/nomad.zip' do
    destination install_dir
    overwrite true
end

directory data_dir do
    recursive true
end

template srv_config do
    source 'server.hcl.erb'
    variables(
        :srv_dir => '/data/nomad/server'
    )
    notifies :restart, 'service[nomad-server]'
end

template cln_config do
    source 'client.hcl.erb'
    variables(
        :hostname => node[:hostname],
        :cln_dir => '/data/nomad/client'
    )
    notifies :restart, 'service[nomad-client]'
end

systemd_unit 'nomad-client.service' do
    content({Unit: {
            Description: 'Nomad Client',
            After: 'network.target'
        },
        Service: {
            ExecStart: "#{install_dir}/nomad agent -config=#{cln_config}",
            Restart: 'on-failure'

        },
        Install: {
            WantedBy: 'multi-user.target'

        }
    })
    action [:create, :enable]
    triggers_reload true
end

service 'nomad-server' do
    action [:enable, :start]
end
service 'nomad-client' do
    action [:enable, :start]
end
