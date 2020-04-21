data_dir = '/data/nginx'

[data_dir, "#{data_dir}/html"].each do |dir|
    directory dir do
        recursive true
    end
end

template "#{data_dir}/default.conf" do
    source 'default-vhost.conf.erb'
end

template "#{data_dir}/html/index.html" do
    source 'index.html.erb'
    variables(
        :hostname => node[:hostname],
        :ipaddress => node[:ipaddress]
    )
end