#!/usr/bin/env bash

# 스크립트 위치 기준 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NODE_COUNT=3
TOTAL_STEPS=$((NODE_COUNT + 1))

# Step 0: CP 노드에 로컬 설치
echo "[Step 1/$TOTAL_STEPS] Installing docker on control-plane (local)"
bash $SCRIPT_DIR/install_docker.sh > /dev/null 2>&1
chmod 666 /var/run/docker.sock

# Step 1~3: Worker 노드에 원격 설치
for (( i=1; i<=$NODE_COUNT; i++ ));
  do
  TARGET="192.168.1.10$i"
  echo "[Step $((i+1))/$TOTAL_STEPS] Installing docker on $TARGET"
  sshpass -p vagrant scp -o StrictHostKeyChecking=no -q $SCRIPT_DIR/install_docker.sh root@$TARGET:/tmp
  sshpass -p vagrant ssh root@$TARGET bash /tmp/install_docker.sh > /dev/null 2>&1
  sshpass -p vagrant ssh root@$TARGET chmod 666 /var/run/docker.sock 2>&1
  done
echo "Successfully completed"
