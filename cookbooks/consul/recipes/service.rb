systemd_unit 'consul.service' do
  content({Unit: {
      Description: 'Consul Service',
      After: 'network.target'
    },
    Service: {
      ExecStart: "#{node['consul']['install_dir']}/consul agent -config-dir=#{node['consul']['config_dir']}",
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
