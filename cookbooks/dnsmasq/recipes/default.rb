package 'dnsmasq'

file '/etc/dnsmasq.d/10-consul' do
  content 'server=/consul/127.0.0.1#8600'
end

service 'dnsmasq' do
  action [:enable, :start]
end
