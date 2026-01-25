## 대시보드 앱

이 저장소는 컨테이너 인프라 환경 구축을 위한 쿠버네티스/도커 책 실습 부분에서 예제로 배포되는 애플리케이션입니다. 애플리케이션은 Svelte로 작성하였으며, 사용자의 활동을 히트맵 형식의 그래프로 보여주는 기능을 제공합니다.

Note: 이 애플리케이션을 단일로 구성하기 위해서는 Node.js 18 버전 이상이 필요합니다.

# 로컬 개발환경
```bash
npm i
npm run dev
```

## 컨테이너 이미지 빌드 방법
```shell
docker build -t <이미지 태그> --build-arg=PHASE=[blue|green]
# 예시 블루
docker build -t dashboard:blue --build-arg=PHASE=blue .
# 예시 그린
docker build -t dashboard:green --build-arg=PHASE=green .
```