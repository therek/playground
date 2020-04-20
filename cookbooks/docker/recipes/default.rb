yum_repository 'docker-ce-stable' do
    description 'Docker CE Stable'
    baseurl 'https://download.docker.com/linux/centos/7/$basearch/stable'
    gpgkey 'https://download.docker.com/linux/centos/gpg'
    action :create
end

package 'docker-ce'

service 'docker' do
    action [:enable, :start]
end