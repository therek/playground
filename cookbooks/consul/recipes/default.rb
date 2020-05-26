version = '1.7.3'
domain = 'dc1.consul'

install_dir = '/usr/local/sbin'
data_dir = '/data/consul'
config_dir = '/etc/consul'

remote_file '/opt/consul.zip' do
  source "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_linux_amd64.zip"
end

archive_file '/opt/consul.zip' do
  destination install_dir
  overwrite true
end

[config_dir, data_dir].each do |dir|
  directory dir do
    recursive true
  end
end

template "#{config_dir}/consul.json" do
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

template "#{config_dir}/consul.json-tls" do
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
      ExecStart: "#{install_dir}/consul agent -config-dir=#{config_dir}",
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
