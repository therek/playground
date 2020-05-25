package 'dnsmasq'

file '/etc/dnsmasq.d/10-consul' do
  content 'server=/consul/127.0.0.1#8600'
  notifies :restart, 'service[dnsmasq]'
end

file '/etc/dnsmasq.d/00-upstream' do
  content "no-resolv\nserver=#{node['network']['default_gateway']}"
  notifies :restart, 'service[dnsmasq]'
end

ruby_block 'configure DNSMasq in /etc/resolv.conf' do
  block do
    fe = Chef::Util::FileEdit.new("/etc/resolv.conf")
    fe.insert_line_if_no_match(/nameserver 127.0.0.1/, "nameserver 127.0.0.1")
    fe.search_file_delete_line(/nameserver #{node['network']['default_gateway']}/)
    fe.write_file
  end
end

service 'dnsmasq' do
  action [:enable, :start]
end
