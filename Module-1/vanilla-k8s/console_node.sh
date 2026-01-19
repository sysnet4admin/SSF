#!/usr/bin/env bash

# Console node provisioning script
# - Copy kubeconfig from cp-k8s
# - Install kubectl
# - Install Claude Code (Node.js + npm)
# - Clone SSF repository for hands-on labs

export DEBIAN_FRONTEND=noninteractive

echo "=========================================="
echo "  Console Node Setup"
echo "=========================================="

#====================#
# Install kubectl    #
#====================#
echo "[1/6] Installing kubectl..."

# Add Kubernetes apt repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${1:0:4}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${1:0:4}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubectl=$1 sshpass git

#====================#
# Copy kubeconfig    #
#====================#
echo "[2/6] Copying kubeconfig from cp-k8s..."

# Create .kube directory for vagrant user
mkdir -p /home/vagrant/.kube

# Copy kubeconfig from cp-k8s using sshpass (retry logic for initial cluster setup)
for i in {1..30}; do
  if sshpass -p 'vagrant' scp -o StrictHostKeyChecking=no root@192.168.1.10:/etc/kubernetes/admin.conf /home/vagrant/.kube/config 2>/dev/null; then
    break
  fi
  echo "Waiting for cp-k8s to be ready... (attempt $i/30)"
  sleep 2
done

# Set ownership
chown -R vagrant:vagrant /home/vagrant/.kube
chmod 600 /home/vagrant/.kube/config

echo "kubeconfig copied successfully"

#====================#
# kubectl completion #
#====================#
echo "[3/6] Setting up kubectl aliases and completion..."

# kubectl completion for vagrant user
cat <<'EOF' >> /home/vagrant/.bashrc

# kubectl aliases and completion
alias k=kubectl
alias ka='kubectl apply -f'
alias kg-po-ip-stat-no='kubectl get pods -o=custom-columns=NAME:.metadata.name,IP:.status.podIP,STATUS:.status.phase,NODE:.spec.nodeName'
source <(kubectl completion bash)
complete -F __start_kubectl k
EOF

#====================#
# Install Node.js    #
#====================#
echo "[4/6] Installing Node.js 22..."

# Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

#====================#
# Install Claude Code #
#====================#
echo "[5/6] Installing Claude Code..."

# Install Claude Code
npm install -g @anthropic-ai/claude-code

#====================#
# Clone SSF repo     #
#====================#
echo "[6/6] Cloning SSF repository..."

# Clone SSF repository to vagrant home
git clone https://github.com/sysnet4admin/SSF.git /home/vagrant/SSF
chown -R vagrant:vagrant /home/vagrant/SSF

echo ""
echo "=========================================="
echo "  Console Node Setup Complete!"
echo "=========================================="
echo ""
echo "Version info:"
echo "  kubectl: $(kubectl version --client --short 2>/dev/null || echo 'v1.35.0')"
echo "  Node.js: $(node --version)"
echo "  npm:     $(npm --version)"
echo "  Claude:  $(claude --version)"
echo "  git:     $(git --version)"
echo ""
echo "Kubeconfig location: /home/vagrant/.kube/config"
echo "SSF repository:      /home/vagrant/SSF"
echo ""
echo "Next steps (from console node):"
echo "  1. Run API key setup: bash ~/SSF/Module-1/vanilla-k8s/claude-code/install.sh"
echo "  2. Verify cluster:   kubectl get nodes"
echo "  3. Use Claude:       claude"
echo ""
