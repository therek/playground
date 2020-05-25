version = '1.7.2'
install_dir = '/usr/local/sbin'
data_dir = '/data/consul'
config_file = "#{data_dir}/consul.json"
domain = 'dc1.consul'

remote_file '/opt/consul.zip' do
    source "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_linux_amd64.zip"
end

archive_file '/opt/consul.zip' do
    destination install_dir
    overwrite true
end

directory data_dir do
    recursive true
end

template config_file do
    source 'consul.json.erb'
    variables(
        :hostname => node[:hostname],
        :domain => domain,
        :ipaddress => node[:ipaddress],
        :ssl => false,
        :data_dir => data_dir,
    )
    notifies :restart, 'service[consul]'
end

template "#{config_file}-tls" do
    source 'consul.json.erb'
    variables(
        :hostname => node[:hostname],
        :domain => domain,
        :ipaddress => node[:ipaddress],
        :ssl => true,
        :data_dir => data_dir,
    )
end

systemd_unit 'consul.service' do
    content({Unit: {
            Description: 'Consul Service',
            After: 'network.target'
        },
        Service: {
            ExecStart: "#{install_dir}/consul agent -config-file=#{config_file}",
            Restart: 'on-failure'

        },
        Install: {
            WantedBy: 'multi-user.target'

        }
    })
    action [:create, :enable]
    triggers_reload true
end

service 'consul' do
    action [:enable, :start]
end
