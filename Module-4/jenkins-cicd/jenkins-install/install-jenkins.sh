#!/usr/bin/env bash
# Jenkins install script (auto-detects GKE / vanilla K8s)
#
# Prerequisites:
# - Helm installed (done in Module-3)
# - edu repo added: helm repo add edu https://k8s-edu.github.io/Bkv2_main/helm-charts/
#
# Note: Uses Jenkins 2.440.3-jdk17 (edu/jenkins chart - managed plugin compatibility)

set -e

# Ensure edu Helm repo exists (added in Module-3)
if ! helm repo list | grep -q "^edu"; then
    echo "Adding edu Helm repository..."
    helm repo add edu https://k8s-edu.github.io/Bkv2_main/helm-charts/
    helm repo update
fi

JK_CFG="https://raw.githubusercontent.com/k8s-edu/Bkv2_main/main/jenkins-cfg"
JK_OPT1="--sessionTimeout=1440"
JK_OPT2="--sessionEviction=86400"
JV_OPT1="-Duser.timezone=Asia/Seoul"
JV_OPT2="-Dcasc.jenkins.config=$JK_CFG/jcasc/jenkins-config.yaml"
JV_OPT3="-Dhudson.model.DownloadService.noSignatureCheck=true"

# Auto-detect environment by checking for Control Plane node
# - Vanilla K8s: CP_NODE set → apply nodeSelector/toleration
# - GKE: CP_NODE empty → skip nodeSelector/toleration
CP_NODE=$(kubectl get nodes -l node-role.kubernetes.io/control-plane \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$CP_NODE" ]; then
  echo "Detected: Vanilla K8s (Control Plane: $CP_NODE)"
else
  echo "Detected: GKE (no Control Plane node)"
fi

helm upgrade --install jenkins edu/jenkins \
  --namespace ci-cd \
  --create-namespace \
  ${CP_NODE:+--set controller.nodeSelector."kubernetes\.io/hostname"=$CP_NODE} \
  ${CP_NODE:+--set controller.tolerations[0].key=node-role.kubernetes.io/control-plane} \
  ${CP_NODE:+--set controller.tolerations[0].effect=NoSchedule} \
  ${CP_NODE:+--set controller.tolerations[0].operator=Exists} \
  --set controller.admin.password=admin \
  --set controller.initContainerEnv[0].name=JENKINS_UC \
  --set controller.initContainerEnv[0].value=$JK_CFG/update-center/update-center.json \
  --set controller.runAsUser=1000 \
  --set controller.runAsGroup=1000 \
  --set controller.image.tag=2.440.3-jdk17 \
  --set controller.serviceType=LoadBalancer \
  --set controller.servicePort=80 \
  --set controller.jenkinsOpts="$JK_OPT1 $JK_OPT2" \
  --set controller.javaOpts="$JV_OPT1 $JV_OPT2 $JV_OPT3"
  # Uses default StorageClass when omitted (compatible with GKE/vanilla K8s)

# Grant cluster-admin to Jenkins SA (for kubectl in freestyle builds)
kubectl create clusterrolebinding jenkins-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=ci-cd:jenkins \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Jenkins installed successfully!"
echo ""
echo "Check access info:"
echo "  kubectl get svc -n ci-cd"
echo ""
echo "Default password: admin"
