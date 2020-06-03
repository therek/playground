systemd_unit 'nomad-server.service' do
    content({Unit: {
            Description: 'Nomad Server',
            After: 'network.target'
        },
        Service: {
            ExecStart: "#{node['nomad']['install_dir']}/nomad agent -config=#{node['nomad']['srv_config']}",
            Restart: 'on-failure'

        },
        Install: {
            WantedBy: 'multi-user.target'

        }
    })
    action [:create, :enable]
    triggers_reload true
end
systemd_unit 'nomad-client.service' do
    content({Unit: {
            Description: 'Nomad Client',
            After: 'network.target'
        },
        Service: {
            ExecStart: "#{node['nomad']['install_dir']}/nomad agent -config=#{node['nomad']['cln_config']}",
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
