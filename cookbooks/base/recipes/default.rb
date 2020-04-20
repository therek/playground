pkgs = [
    'bind-utils',
    'git',
    'net-tools',
    'vim',
    'wget',
    'unzip',
    'tmux',
]

pkgs.each do |pkg|
    package pkg
end

execute 'generate ssh key for root' do
    user 'root'
    creates '/root/.ssh/id_ed25519'
    command 'ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""'
end