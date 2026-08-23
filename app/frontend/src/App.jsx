import { useEffect, useState } from 'react';

// 백엔드 /api를 호출해 data와 podName을 화면에 크게 표시합니다.
// 새로고침 버튼을 누르면 podName이 바뀌는 것을 눈으로 확인할 수 있습니다(부하분산 가시화).
// 백엔드 주소는 같은 출처의 /api로 호출하며, 실제 라우팅은 nginx가 backend-service로 넘깁니다.
export default function App() {
  const [info, setInfo] = useState(null);
  const [error, setError] = useState(null);

  const load = () => {
    setError(null);
    fetch('/api')
      .then((res) => res.json())
      .then(setInfo)
      .catch((err) => setError(String(err)));
  };

  useEffect(load, []);

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <h1 style={styles.title}>SSF 15기</h1>

        {error && <p style={styles.error}>요청 실패: {error}</p>}

        {info && (
          <>
            <p style={styles.label}>메시지</p>
            <p style={styles.data}>{info.data}</p>

            <p style={styles.label}>응답한 Pod</p>
            <p style={styles.pod}>{info.podName}</p>
          </>
        )}

        <button style={styles.button} onClick={load}>
          새로고침
        </button>
      </div>
    </div>
  );
}

const styles = {
  page: {
    minHeight: '100vh',
    margin: 0,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontFamily: 'system-ui, sans-serif',
    background: '#0f172a',
  },
  card: {
    background: '#ffffff',
    borderRadius: '16px',
    padding: '48px 56px',
    textAlign: 'center',
    boxShadow: '0 10px 30px rgba(0,0,0,0.25)',
    minWidth: '320px',
  },
  title: { margin: '0 0 24px', fontSize: '28px', color: '#0f172a' },
  label: { margin: '16px 0 4px', fontSize: '13px', color: '#64748b' },
  data: { margin: 0, fontSize: '22px', color: '#0f172a' },
  pod: {
    margin: 0,
    fontSize: '24px',
    fontWeight: 700,
    color: '#2563eb',
    fontFamily: 'monospace',
  },
  button: {
    marginTop: '32px',
    padding: '12px 28px',
    fontSize: '16px',
    color: '#ffffff',
    background: '#2563eb',
    border: 'none',
    borderRadius: '8px',
    cursor: 'pointer',
  },
  error: { color: '#dc2626' },
};
