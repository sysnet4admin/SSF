#!/usr/bin/env bash

# init kubernetes (w/ containerd)
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
             --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.1.10 \
             --cri-socket=unix:///run/containerd/containerd.sock

# config for control-plane node only
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# CNI raw address & config for kubernetes's network
CNI_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/CNI"
kubectl apply -f $CNI_ADDR/calico-quay-v3.31.2.yaml

# kubectl completion on bash-completion dir
kubectl completion bash > /etc/bash_completion.d/kubectl

# Install fzf
apt-get install -y fzf

# Install kubectx/kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
ln -s /opt/kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
ln -s /opt/kubectx/completion/kubens.bash /etc/bash_completion.d/kubens

# Install kube-ps1
git clone https://github.com/jonmosco/kube-ps1 /opt/kube-ps1

# Install Node.js 22 and Claude Code
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
npm install -g @anthropic-ai/claude-code

# Create vagrant user's .claude directory
mkdir -p /home/vagrant/.claude
chown -R vagrant:vagrant /home/vagrant/.claude

# Create wrapper script to run Claude Code as vagrant user
cat <<'EOF' > /usr/local/bin/claude-run
#!/bin/bash
# Claude Code wrapper to run as vagrant user (avoid root restrictions)
if [ "$(id -u)" = "0" ]; then
    WORK_DIR="$PWD"
    # Check if vagrant user can access current directory, fallback to /home/vagrant
    if ! su vagrant -c "test -r \"$WORK_DIR\"" 2>/dev/null; then
        WORK_DIR="/home/vagrant"
        echo "Note: Cannot access $PWD, starting from $WORK_DIR"
    fi
    exec su vagrant -c "cd \"$WORK_DIR\" && claude $*"
else
    exec claude "$@"
fi
EOF
chmod +x /usr/local/bin/claude-run

# Clone SSF repository to /opt (accessible by all users)
git clone https://github.com/sysnet4admin/SSF.git /opt/SSF
chmod -R o+rX /opt/SSF
echo "SSF repository cloned to /opt/SSF"

# Create symlinks for both root and vagrant users
ln -s /opt/SSF /root/SSF
ln -s /opt/SSF /home/vagrant/SSF
chown -h vagrant:vagrant /home/vagrant/SSF
echo "SSF symlinks created at /root/SSF and /home/vagrant/SSF"

# alias kubectl to k and setup aliases
echo 'alias k=kubectl'               >> ~/.bashrc
echo "alias ka='kubectl apply -f'"   >> ~/.bashrc
echo "alias kg-po-ip-stat-no='kubectl get pods -o=custom-columns=\
NAME:.metadata.name,IP:.status.podIP,STATUS:.status.phase,NODE:.spec.nodeName'" \
                                     >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
echo ''                              >> ~/.bashrc
echo '# kubectx/kubens aliases'      >> ~/.bashrc
echo 'alias kx=kubectx'              >> ~/.bashrc
echo 'alias kn=kubens'               >> ~/.bashrc
echo ''                              >> ~/.bashrc
echo '# kube-ps1 for kubernetes prompt' >> ~/.bashrc
echo 'source /opt/kube-ps1/kube-ps1.sh' >> ~/.bashrc
echo 'KUBE_PS1_SYMBOL_ENABLE=true'   >> ~/.bashrc
echo 'KUBE_PS1_SYMBOL_USE_IMG=false' >> ~/.bashrc
echo 'KUBE_PS1_NS_ENABLE=true'       >> ~/.bashrc
echo 'KUBE_PS1_CTX_COLOR=cyan'       >> ~/.bashrc
echo 'KUBE_PS1_NS_COLOR=yellow'      >> ~/.bashrc
echo 'PS1="[\u@\h \W]\$(kube_ps1)\$ "' >> ~/.bashrc
echo ''                              >> ~/.bashrc
echo '# Claude Code alias (run as vagrant user)' >> ~/.bashrc
echo 'alias claude=claude-run'        >> ~/.bashrc
echo 'alias claude-skip="claude-run --dangerously-skip-permissions"' >> ~/.bashrc



