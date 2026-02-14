#!/usr/bin/env bash

# Docker version
DOCKER_V='5:24.0.6-1~ubuntu.22.04~jammy'
BUILDX_V='0.23.0-1~ubuntu.22.04~jammy'
COMPOSE_V='2.35.1-1~ubuntu.22.04~jammy'

INSTALL_CMD=$(cat <<'SCRIPT'
apt-get update
apt-get install docker-ce=DOCKER_V \
                docker-ce-cli=DOCKER_V \
                docker-ce-rootless-extras=DOCKER_V \
                docker-buildx-plugin=BUILDX_V \
                docker-compose-plugin=COMPOSE_V -y
chmod 666 /var/run/docker.sock
SCRIPT
)

# 버전 치환
INSTALL_CMD="${INSTALL_CMD//DOCKER_V/$DOCKER_V}"
INSTALL_CMD="${INSTALL_CMD//BUILDX_V/$BUILDX_V}"
INSTALL_CMD="${INSTALL_CMD//COMPOSE_V/$COMPOSE_V}"

NODE_COUNT=3
TOTAL_STEPS=$((NODE_COUNT + 1))

# Step 1: CP 노드에 로컬 설치
echo "[Step 1/$TOTAL_STEPS] Installing docker on control-plane (local)"
sudo bash -c "$INSTALL_CMD" > /dev/null 2>&1

# Step 2~4: Worker 노드에 원격 설치
for (( i=1; i<=$NODE_COUNT; i++ )); do
  TARGET="192.168.1.10$i"
  echo "[Step $((i+1))/$TOTAL_STEPS] Installing docker on $TARGET"
  sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@$TARGET "$INSTALL_CMD" > /dev/null 2>&1
done
echo "Successfully completed"
