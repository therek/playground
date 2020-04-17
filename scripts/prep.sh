yum install -y git net-tools vim wget unzip tmux
[[ -f /root/.ssh/id_ed25519 ]] || ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""