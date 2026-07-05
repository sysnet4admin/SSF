// SSF 15기 실습용 백엔드
// 핵심: 응답에 podName(컨테이너 HOSTNAME = Pod 이름)을 담아
// 부하분산, 스케일, GitOps reconcile을 브라우저에서 눈으로 확인할 수 있게 합니다.

const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 8080;

// MESSAGE는 5회차에서 ConfigMap으로 주입합니다. 비밀값(API_KEY)은 Secret으로 받습니다.
// 코드에 비밀값을 하드코딩하지 않습니다.
const MESSAGE = process.env.MESSAGE || 'SSF 15기 쿠버네티스 실습';

app.get('/api', (req, res) => {
  res.json({
    data: MESSAGE,
    podName: os.hostname(),
  });
});

// 헬스 체크용 (backend-deployment.yaml의 readiness/liveness probe가 사용)
app.get('/healthz', (req, res) => {
  res.status(200).send('ok');
});

app.listen(PORT, () => {
  console.log(`backend listening on ${PORT}`);
});
