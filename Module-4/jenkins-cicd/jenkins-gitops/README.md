# Jenkins GitOps Pipeline

## Overview

GitOps-based declarative deployment using Jenkins Poll SCM.

> **Supported Platform**: Vanilla K8s only (GKE not supported)

## GitOps Flow

```
1. Fork repository & modify manifests
       ↓
2. Push changes to GitHub
       ↓
3. Jenkins detects changes (Poll SCM)
       ↓
4. Pull latest code from Git
       ↓
5. kubectl apply to Kubernetes
```

## Lab Files

| File | Description |
|------|-------------|
| `GUI-GUIDE.md` | Step-by-step Jenkins GUI guide |

## Prerequisites

### Jenkins Plugins
- Kubernetes CLI Plugin

### Credentials
- `k8s-auth`: kubeconfig Secret file

## Quick Start

1. Fork the GitOps repository
   - https://github.com/k8s-edu/Bkv2_sub_gitops

2. Follow the GUI guide
   - See `GUI-GUIDE.md` for detailed steps

3. Verify auto-deployment
   - Modify `deployment.yaml` → Push → Wait 10 min → Check cluster

## Comparison: Freestyle vs Pipeline vs GitOps

| Item | Freestyle | Pipeline | GitOps Pipeline |
|------|-----------|----------|-----------------|
| Configuration | Web UI | Jenkinsfile (Groovy) | Jenkinsfile + Git repo |
| Complexity | Simple tasks | Complex tasks | Declarative deployment |
| Management | Web UI | Version control | Git repository |
| Reusability | Low | High | Very high |
| Traceability | Difficult | Easy (Git history) | Very easy |
| Auto Deploy | Manual trigger | Manual/Auto trigger | Auto detection |
| Change Detection | None | Optional (Poll SCM) | Poll SCM required |
| Use Case | Simple build/deploy | CI/CD pipeline | Declarative infra |

## Cleanup

```bash
kubectl delete deployment gitops-nginx
```

## Reference

- [GitOps Guide for Beginners (Korean)](https://yozm.wishket.com/magazine/detail/2010/)
