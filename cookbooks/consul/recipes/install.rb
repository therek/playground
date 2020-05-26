version = node['consul']['version']

remote_file '/opt/consul.zip' do
  source "https://releases.hashicorp.com/consul/#{version}/consul_#{version}_linux_amd64.zip"
end

archive_file '/opt/consul.zip' do
  destination node['consul']['install_dir']
  overwrite true
end

[node['consul']['config_dir'], node['consul']['data_dir']].each do |dir|
  directory dir do
    recursive true
  end
end
