# Jenkins Pipeline (Groovy-based)

## Overview

CI/CD pipeline using Jenkinsfile with Groovy syntax.

> **Supported Platform**: GKE, Vanilla K8s

## Lab Files

| File | Description |
|------|-------------|
| `GUI-GUIDE.md` | Step-by-step Jenkins GUI guide |
| `Jenkinsfile-basic` | Basic pipeline example |
| `deployment.yaml` | Deployment example |

## Pipeline Flow

```
1. Git clone repository
       ↓
2. Execute Jenkinsfile (Groovy)
       ↓
3. Build / Test / Deploy
```

## Prerequisites

### Jenkins Plugins
- Docker Pipeline Plugin

### Credentials
- `harbor-credential`: Harbor username/password

## Pipeline Job Setup

See `GUI-GUIDE.md` for detailed step-by-step instructions.

## Jenkinsfile Example

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t myapp .'
            }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'harbor-credential', ...)]) {
                    sh 'docker push ...'
                }
            }
        }
        stage('Deploy') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }
}
```

## Cleanup

```bash
kubectl delete deployment <deployment-name>
kubectl delete svc <service-name>
```

## Reference

- Slack notification, diff tracking examples: `../_reference/jenkinsfile/`
