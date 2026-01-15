# Jenkins GitOps Pipeline GUI Guide

GitOps manages everything declaratively through Git and automatically detects changes for deployment.

## Prerequisites

Log in to Jenkins with admin account.
- Username: `admin`
- Password: `admin`
- Check 'Keep me signed in'

---

## 1. GitHub Repository Setup (Terminal)

### 1.1 Fork the Repository

1. Go to https://github.com/k8s-edu/Bkv2_sub_gitops
2. Click **Fork**
3. Change Repository name to `gitops`
4. Click **Create fork**

### 1.2 Clone to Local

```bash
cd ~
git clone https://github.com/<username>/gitops.git
cd gitops/
ls  # Verify README.md
```

### 1.3 Configure Git User

```bash
git config --global user.name "<your name>"
git config --global user.email "<your email>"
git config --global credential.helper "store --file ~/.git-cred"
```

### 1.4 Verify Configuration

```bash
git config --list
```

### 1.5 Copy Deployment Files and Modify Jenkinsfile

```bash
cp ~/_Book_k8sInfra/ch5/5.5.1/* ~/gitops/
ls  # Verify deployment.yaml, Jenkinsfile, README.md

# Change Git URL in Jenkinsfile to your repository
sed -i 's,Git-URL,https://github.com/<username>/gitops.git,g' Jenkinsfile
cat Jenkinsfile | grep url  # Verify change
```

### 1.6 Push to GitHub

```bash
git add .
git status  # Verify added files
git commit -m "init commit"
git push -u origin main
# Enter Username and Token (first time only)
```

---

## 2. Install Kubernetes CLI Plugin

1. Click **Manage Jenkins** on the home page
2. Click **Plugins**
3. Select **Available plugins** tab
4. Search for `Kubernetes CLI`
5. Select **Kubernetes CLI** plugin
6. Click **Install**
7. Click **Go back to the top page** after installation

## 3. Add Kubeconfig Credentials

### 3.1 Prepare Kubeconfig File (Terminal)

1. Copy kubeconfig file to /tmp
   ```bash
   cp ~/.kube/config /tmp/kubeconfig
   ls /tmp/kubeconfig  # Verify file
   ```

2. Download to local PC via SFTP
   - Use SFTP feature in Tabby or other terminal
   - Save `/tmp/kubeconfig` to local PC

### 3.2 Register Credentials in Jenkins

1. Click **Manage Jenkins** on the home page
2. Click **Credentials**
3. Click **(global)** in Domains section
4. Click **Add Credentials**
5. Enter the following:
   - **Kind**: Secret file
   - **Scope**: Global (Jenkins, nodes, items, all child items, etc)
   - **File**: Select downloaded `kubeconfig` file
   - **ID**: `k8s-auth`
   - **Description**: k8s-auth-kubeconfig
6. Click **Create**
7. Verify `k8s-auth` credential is created

## 4. Create GitOps Pipeline Project

1. Click **New Item** in the left menu
2. Enter item name: `pl-gitops`
3. Select **Pipeline**
4. Click **OK**

## 5. Build Triggers Settings (Poll SCM)

1. Go to **Build Triggers** section
2. Check **Poll SCM** checkbox
3. Enter in **Schedule** field: `*/10 * * * *`
   - Meaning: Check for changes every 10 minutes
   - Example: Start at 4:01 → Check at 4:10, Start at 4:17 → Check at 4:20

## 6. Pipeline Settings

1. Go to **Pipeline** section
2. Select **Pipeline script from SCM** in Definition dropdown
3. Select **Git** in SCM dropdown
4. Enter **Repository URL**
   - e.g., `https://github.com/<username>/gitops.git`
5. Verify/modify **Branch Specifier**
   - Set to `*/main`
6. Verify **Script Path**
   - Default: `Jenkinsfile`
7. Click **Save**

## 7. Verify GitOps Operation

### 7.1 Verify Initial Deployment

1. Wait about 10 minutes after saving (Poll SCM interval)
2. Verify #1 build auto-runs in **Build History**
3. Verify in terminal after build completes:
   ```bash
   kubectl get deploy
   # Verify gitops-nginx deployment (replicas: 2)
   ```

### 7.2 Test Automatic Deployment on Changes

1. Modify deployment.yaml in terminal:
   ```bash
   cd ~/gitops
   sed -i 's/replicas: 2/replicas: 5/' deployment.yaml
   ```

2. Push changes to GitHub:
   ```bash
   git add .
   git commit -m "chg replicas number"
   git push -u origin main
   ```

3. Verify changes in GitHub repository
   - Check if replicas changed to 5 in deployment.yaml

4. After about 10 minutes, verify auto-deployment in Jenkins
   - Verify #2 build auto-runs in **Build History**

5. Verify deployment result in terminal:
   ```bash
   kubectl get deploy
   # Verify gitops-nginx deployment replicas changed to 5
   ```

---

## Jenkinsfile Structure

```groovy
pipeline {
    agent any
    stages {
        stage('git pull') {
            steps {
                git url: 'https://github.com/<username>/gitops.git', branch: 'main'
            }
        }
        stage('k8s deploy'){
            steps {
                withKubeConfig([credentialsId: 'k8s-auth', serverUrl: 'https://192.168.1.10:6443']) {
                    sh 'kubectl apply -f deployment.yaml'
                }
            }
        }
    }
}
```

**Key components:**
- **git pull stage**: Download YAML files from GitHub repository
- **k8s deploy stage**:
  - `withKubeConfig`: Authenticate to Kubernetes using k8s-auth credentials
  - `kubectl apply`: Deploy deployment.yaml to Kubernetes cluster

---

## Benefits of GitOps

1. **Single Source of Truth**
   - Git repository content matches production environment
   - All changes recorded in Git for easy history management
   - Quick rollback when issues occur

2. **Automated Deployment**
   - Automatic deployment on code changes
   - Minimizes human intervention

3. **Error Prevention**
   - Consistency maintained through automation
   - Reduces errors from manual operations
