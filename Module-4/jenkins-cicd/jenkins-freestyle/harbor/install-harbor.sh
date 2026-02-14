#!/usr/bin/env bash
# Harbor 통합 설치 스크립트
# 1-1 ~ 2-4 단계를 순차적으로 실행합니다.
#
# 사용법: ./install-harbor.sh
#
# 포함 단계:
# 1. PKI 인증서 생성
# 2. 인증서 배포 (모든 노드)
# 3. Harbor 다운로드
# 4. Harbor 설정 수정
# 5. Harbor prepare
# 6. Harbor 설치

set -e

# root 권한이 아니면 sudo로 재실행
if [ "$(id -u)" -ne 0 ]; then
    exec sudo bash "$0" "$@"
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HARBOR_FILE_DIR=/opt/harbor
HARBOR_DATA_DIR=/data/harbor
HARBOR_HOST=192.168.1.10:8443
DOCKER_CERT_DIR=/etc/docker/certs.d/$HARBOR_HOST
HOST_CERT_DIR=/usr/local/share/ca-certificates
ARCH=$(uname -m)

echo "=============================================="
echo "Harbor 통합 설치 스크립트"
echo "=============================================="
echo ""

#----------------------------------------------
# 1단계: PKI 인증서 생성 (1-1.create_certs.sh)
#----------------------------------------------
echo "[1/6] PKI 인증서 생성 중..."

mkdir -p $HARBOR_FILE_DIR

# CA key 생성
openssl genrsa -out $HARBOR_FILE_DIR/ca.key 4096

# CA certificate 생성
openssl req -x509 -new -noenc -sha512 -days 3650 \
    -config $SCRIPT_DIR/1.harbor_pki/certificate.csr \
    -key $HARBOR_FILE_DIR/ca.key -out $HARBOR_FILE_DIR/ca.crt

# Server key 생성
openssl genrsa -out $HARBOR_FILE_DIR/server.key 4096

# Server CSR 생성
openssl req -new -sha512 \
    -config $SCRIPT_DIR/1.harbor_pki/certificate.csr \
    -key $HARBOR_FILE_DIR/server.key -out $HARBOR_FILE_DIR/server.csr

# Server certificate 생성
openssl x509 -req -sha512 -days 3650 \
    -extfile $SCRIPT_DIR/1.harbor_pki/certificate_v3.ext \
    -CA $HARBOR_FILE_DIR/ca.crt -CAkey $HARBOR_FILE_DIR/ca.key -CAcreateserial \
    -in $HARBOR_FILE_DIR/server.csr -out $HARBOR_FILE_DIR/server.crt

echo "    인증서 생성 완료"

#----------------------------------------------
# 2단계: 인증서 배포 (1-2.deploy_certs.sh)
#----------------------------------------------
echo "[2/6] 인증서 배포 중..."

# sshpass 설치
apt-get install sshpass -y > /dev/null 2>&1 || true

# Docker 인증서 디렉토리 생성
mkdir -p $DOCKER_CERT_DIR

# Worker 노드에 인증서 복사
for i in {1..3}; do
    if ping -c 1 -W 1 192.168.1.10$i > /dev/null 2>&1; then
        echo "    w$i-k8s 노드에 인증서 복사 중..."
        sshpass -p vagrant scp -o StrictHostKeyChecking=no \
            $HARBOR_FILE_DIR/ca.crt 192.168.1.10$i:$HOST_CERT_DIR/harbor_ca.crt 2>/dev/null || true
        sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@192.168.1.10$i \
            "update-ca-certificates && systemctl restart containerd" 2>/dev/null || true
    fi
done

# Control Plane에 인증서 복사
cp -f $HARBOR_FILE_DIR/ca.crt $DOCKER_CERT_DIR/ca.crt
cp -f $HARBOR_FILE_DIR/ca.crt $HOST_CERT_DIR/harbor_ca.crt
update-ca-certificates
systemctl restart containerd

echo "    인증서 배포 완료"

#----------------------------------------------
# 3단계: Harbor 다운로드 (2-1.get_harbor.sh)
#----------------------------------------------
echo "[3/6] Harbor 다운로드 중..."

# docker-compose 설치 확인
if ! command -v docker-compose &> /dev/null; then
    echo "    docker-compose 설치 중..."
    curl -sL "https://github.com/docker/compose/releases/download/v2.10.0/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 기존 파일 정리
cd $HARBOR_FILE_DIR
rm -f 2-3.prepare 2-4.install.sh common.sh LICENSE harbor.yml.tmpl 2>/dev/null || true

# Harbor 데이터 디렉토리 생성
mkdir -p $HARBOR_DATA_DIR

# 아키텍처별 버전 선택
if [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    HARBOR_VERSION="v2.4.3"
    echo "    ARM64 감지: Harbor $HARBOR_VERSION"
else
    HARBOR_VERSION="v2.10.0"
    echo "    AMD64 감지: Harbor $HARBOR_VERSION"
fi

# Harbor 다운로드 및 압축 해제
curl -sLO https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/harbor-online-installer-${HARBOR_VERSION}.tgz
tar -xf harbor-online-installer-${HARBOR_VERSION}.tgz
mv harbor/* .
rm -rf harbor harbor-online-installer-${HARBOR_VERSION}.tgz

# 파일명 변경
mv prepare 2-3.prepare
mv install.sh 2-4.install.sh

# prepare 스크립트 수정
sed -i '3 i\\HARBOR_BUNDLE_DIR=/opt/harbor' 2-3.prepare

# ARM64 이미지 치환
if [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    sed -i 's,goharbor/prepare:v2.4.3,seongjumoon/prepare:v2.4.3-arm64,gi' 2-3.prepare
    echo '
# ARM64 이미지 치환
sed -i "s,goharbor/,seongjumoon/,gi" /opt/harbor/docker-compose.yml
sed -i "s,:dev-arm,:v2.4.3-arm64,gi" /opt/harbor/docker-compose.yml
' >> 2-3.prepare
fi

# install.sh 수정
sed -i '/prepare $prepare_para/d' 2-4.install.sh
sed -i 's,$DOCKER_COMPOSE,$DOCKER_COMPOSE -f /opt/harbor/docker-compose.yml,' 2-4.install.sh
sed -i 's/up -d/-p harbor up -d/' 2-4.install.sh

# systemd 서비스 생성
cat <<EOF > /usr/lib/systemd/system/harbor.service
[Unit]
Description=Harbor startup service
Requires=docker.service
ConditionPathExists=$HARBOR_FILE_DIR/docker-compose.yml
After=network.target docker.service

[Service]
Type=simple
ExecStart=/usr/bin/docker compose -f $HARBOR_FILE_DIR/docker-compose.yml up
ExecStop=/usr/bin/docker compose -f $HARBOR_FILE_DIR/docker-compose.yml down

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable harbor

echo "    Harbor 다운로드 완료"

#----------------------------------------------
# 4단계: Harbor 설정 수정 (2-2.modify_config.sh)
#----------------------------------------------
echo "[4/6] Harbor 설정 수정 중..."

HARBOR_TEMPLATE=$HARBOR_FILE_DIR/harbor.yml.tmpl
HARBOR_CONFIG=$HARBOR_FILE_DIR/harbor.yml

sed -i 's/hostname: reg.mydomain.com/hostname: 192.168.1.10/' $HARBOR_TEMPLATE
sed -i 's/port: 443/port: 8443/' $HARBOR_TEMPLATE
sed -i 's,certificate: /your/certificate/path,certificate: /opt/harbor/server.crt,' $HARBOR_TEMPLATE
sed -i 's,private_key: /your/private/key/path,private_key: /opt/harbor/server.key,' $HARBOR_TEMPLATE
sed -i 's/harbor_admin_password: Harbor12345/harbor_admin_password: admin/' $HARBOR_TEMPLATE
sed -i 's,data_volume: /data,data_volume: /data/harbor,' $HARBOR_TEMPLATE
mv $HARBOR_TEMPLATE $HARBOR_CONFIG

echo "    설정 수정 완료"

#----------------------------------------------
# 5단계: Harbor prepare (2-3.prepare)
#----------------------------------------------
echo "[5/6] Harbor prepare 실행 중..."

cd $HARBOR_FILE_DIR
./2-3.prepare

echo "    prepare 완료"

#----------------------------------------------
# 6단계: Harbor 설치 (2-4.install.sh)
#----------------------------------------------
echo "[6/6] Harbor 설치 중..."

./2-4.install.sh

echo ""
echo "=============================================="
echo "Harbor 설치 완료!"
echo "=============================================="
echo ""
echo "접속 정보:"
echo "  URL: https://192.168.1.10:8443"
echo "  계정: admin / admin"
echo ""
