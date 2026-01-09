#!/usr/bin/env bash
HARBOR_FILE_DIR=/opt/harbor
HARBOR_DATA_DIR=/data/harbor
ARCH=$(uname -m)

# docker-compose 설치 확인 및 설치
if ! command -v docker-compose &> /dev/null; then
  echo "Installing docker-compose..."
  curl -L "https://github.com/docker/compose/releases/download/v2.10.0/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  echo "docker-compose $(docker-compose version --short) installed"
fi

echo "Remove existing configuration files"
rm -f 2-3.prepare 2-4.install.sh commom.sh LICENSE

echo "Create Harbor data directory($HARBOR_DATA_DIR)"
mkdir -p $HARBOR_DATA_DIR

# ARM64 아키텍처 감지 및 버전 선택
if [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
  HARBOR_VERSION="v2.4.3"
  echo "Detected ARM64 architecture. Using Harbor $HARBOR_VERSION with ARM64 images..."
else
  HARBOR_VERSION="v2.10.0"
  echo "Detected AMD64 architecture. Using Harbor $HARBOR_VERSION..."
fi

echo "Download harbor-online-installer-$HARBOR_VERSION..."
curl -LO https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/harbor-online-installer-${HARBOR_VERSION}.tgz
tar -xvf harbor-online-installer-${HARBOR_VERSION}.tgz
mv harbor/* .

echo "Remove garbage files"
rm -f harbor-online-installer-${HARBOR_VERSION}.tgz
rm -rf harbor

echo "Add sequence number: "
echo "prepare    >>> 2-3.prepare"
echo "install.sh >>> 2-4.install.sh"
mv prepare 2-3.prepare
mv install.sh 2-4.install.sh

# modify 2-3.prepare.sh
sed -i '3 i\\HARBOR_BUNDLE_DIR=/opt/harbor' 2-3.prepare

# ARM64용 이미지 치환 (파일 이름 변경 후 실행)
if [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
  echo "Applying ARM64 image substitutions..."
  sed -i 's,goharbor/prepare:v2.4.3,seongjumoon/prepare:v2.4.3-arm64,gi' 2-3.prepare
  # prepare 실행 후 docker-compose.yml 수정을 위한 후처리 추가
  echo '
# ARM64 이미지 치환 (자동 생성됨)
sed -i "s,goharbor/,seongjumoon/,gi" /opt/harbor/docker-compose.yml
sed -i "s,:dev-arm,:v2.4.3-arm64,gi" /opt/harbor/docker-compose.yml
' >> 2-3.prepare
fi

# modify 2-4.install.sh
sed -i '/prepare $prepare_para/d' 2-4.install.sh
sed -i 's,$DOCKER_COMPOSE,$DOCKER_COMPOSE -f /opt/harbor/docker-compose.yml,' 2-4.install.sh
sed -i 's/up -d/-p harbor up -d/' 2-4.install.sh

# create systemd startup service for Harbor
cat <<EOF > /usr/lib/systemd/system/harbor.service
[Unit]
Description=Harbor startup service
Requires=docker.service
ConditionPathExists=$HARBOR_FILE_DIR/docker-compose.yml
After=network.target systemd-networkd-wait-online.service systemd-resolved.service syslog.service docker.service
Wants=network.target systemd-networkd-wait-online.service systemd-resolved.service syslog.service docker.service

[Service]
Type=simple
ExecStart=/usr/bin/docker compose -f $HARBOR_FILE_DIR/docker-compose.yml up
ExecStop=/usr/bin/docker compose -f $HARBOR_FILE_DIR/docker-compose.yml down

[Install]
WantedBy=multi-user.target
EOF

# reload and enable systemd service
systemctl daemon-reload
systemctl enable harbor
