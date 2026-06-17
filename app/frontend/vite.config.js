import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// 개발 중에는 /api 호출을 로컬 백엔드(8080)로 프록시합니다.
// 운영(컨테이너)에서는 nginx가 /api를 backend-service로 프록시합니다.
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': 'http://localhost:8080',
    },
  },
});
