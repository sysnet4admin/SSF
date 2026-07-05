# 프론트엔드 이미지 (멀티스테이지: node 빌드 -> nginx 정적 서빙)

# 1단계: React 빌드
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
# lockfile 그대로 설치해 빌드 재현성을 보장합니다.
RUN npm ci
COPY . .
RUN npm run build

# 2단계: nginx로 정적 파일 서빙 + /api 프록시
FROM nginx:1.27-alpine
# nginx 공식 이미지가 시작 시 templates/*.template를 envsubst로 처리합니다.
COPY default.conf.template /etc/nginx/templates/default.conf.template
# 시작 시 클러스터 DNS 주소를 읽어 resolver에 채우는 스크립트(envsubst 전에 실행)
COPY 15-set-nameserver.envsh /docker-entrypoint.d/15-set-nameserver.envsh
RUN chmod +x /docker-entrypoint.d/15-set-nameserver.envsh
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
