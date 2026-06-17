# 백엔드 이미지 (Node 실행)
FROM node:20-alpine

WORKDIR /app

# 의존성 먼저 설치 (레이어 캐시 활용)
COPY package*.json ./
RUN npm install --omit=dev

# 애플리케이션 소스 복사
COPY . .

EXPOSE 8080

CMD ["node", "server.js"]
