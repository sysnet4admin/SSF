# Service 타입 선택 (LoadBalancer vs ClusterIP)

## 상황

앱을 클러스터에 올린 뒤, 외부 브라우저에서 접속할 길과 앱 내부끼리 통신할 길이 필요하다. 쿠버네티스에서는 Service가 그 길을 만든다.

## 쉬운 비유

- ClusterIP: 건물 내부 전화. 같은 건물(클러스터) 안에서만 통화된다.
- LoadBalancer: 건물 정문 주소. 바깥 손님(브라우저)이 찾아올 수 있다.

## 추천

- frontend: LoadBalancer. 브라우저가 직접 접속해야 하므로 외부 주소가 필요하다.
- backend: ClusterIP. 외부에 노출할 이유가 없고, frontend(nginx)만 내부에서 부르면 된다. 안전하다.

## 비교

| 타입 | 노출 범위 | 외부 IP | 이 과정에서의 용도 |
|------|-----------|---------|--------------------|
| ClusterIP | 클러스터 내부 | 없음 | backend (내부 전용) |
| LoadBalancer | 외부 공개 | 발급됨(공인 IP) | frontend (브라우저 접속점) |

## 핵심 개념

- backend를 ClusterIP로 두면 외부에서 직접 못 들어온다. frontend의 nginx가 `backend-service`라는 이름으로 내부에서 연결한다.
- 이름으로 연결하므로 backend Pod가 늘거나 바뀌어도 주소를 고칠 필요가 없다.
