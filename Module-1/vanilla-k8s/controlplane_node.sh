#!/usr/bin/env bash

# init kubernetes (w/ containerd)
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
             --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.1.10 \
             --cri-socket=unix:///run/containerd/containerd.sock

# config for root (required for CNI apply)
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# CNI raw address & config for kubernetes's network
CNI_ADDR="https://raw.githubusercontent.com/sysnet4admin/IaC/main/k8s/CNI"
kubectl apply -f $CNI_ADDR/calico-quay-v3.31.2.yaml

# kubectl completion on bash-completion dir (system-wide)
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

#============================================#
# Vagrant user configuration (main user)    #
#============================================#

# Copy kubeconfig to vagrant user
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Set default namespace for vagrant user
sudo -u vagrant kubectl config set-context --current --namespace=default

# Create vagrant user's .claude directory
mkdir -p /home/vagrant/.claude
chown -R vagrant:vagrant /home/vagrant/.claude

# Clone SSF repository to vagrant home
git clone https://github.com/sysnet4admin/SSF.git /home/vagrant/SSF
chown -R vagrant:vagrant /home/vagrant/SSF
echo "SSF repository cloned to /home/vagrant/SSF"

# Configure vagrant user's .bashrc
cat <<'EOF' >> /home/vagrant/.bashrc

# kubectl aliases and completion
alias k=kubectl
alias ka='kubectl apply -f'
alias kg-po-ip-stat-no='kubectl get pods -o=custom-columns=NAME:.metadata.name,IP:.status.podIP,STATUS:.status.phase,NODE:.spec.nodeName'
complete -F __start_kubectl k

# kubectx/kubens aliases
alias kx=kubectx
alias kn=kubens

# kube-ps1 for kubernetes prompt
source /opt/kube-ps1/kube-ps1.sh
KUBE_PS1_SYMBOL_ENABLE=true
KUBE_PS1_SYMBOL_USE_IMG=false
KUBE_PS1_NS_ENABLE=true
KUBE_PS1_CTX_COLOR=cyan
KUBE_PS1_NS_COLOR=yellow
PS1='[\u@\h \W]$(kube_ps1)\$ '

# Claude Code alias
alias claude-skip='claude --dangerously-skip-permissions'
EOF

echo ""
echo "============================================"
echo "  Control Plane Setup Complete!"
echo "============================================"
echo ""
echo "Login as vagrant user to use all tools:"
echo "  ssh -p 60010 vagrant@127.0.0.1"
echo "  (password: vagrant)"
echo ""
echo "Or switch to vagrant user:"
echo "  su - vagrant"
echo ""
echo "Installed tools (for vagrant user):"
echo "  - kubectl, kubectx, kubens, fzf, kube-ps1"
echo "  - Claude Code (claude, claude-skip)"
echo "  - SSF repository at ~/SSF"
echo ""
