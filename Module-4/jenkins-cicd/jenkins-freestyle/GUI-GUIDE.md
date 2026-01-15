# Jenkins Freestyle Project GUI Guide

## Prerequisites

Log in to Jenkins with admin account.
- Username: `admin`
- Password: `admin`
- Check 'Keep me signed in'

---

## 1. Create New Item

1. Click **New Item** in the left menu
2. Enter item name (e.g., `fs-echo-ip`)
3. Select **Freestyle project**
4. Click **OK**

## 2. General Settings

1. Uncheck **Restrict where this project can be run**
   - This option restricts execution to agents with specific labels
   - Not needed for this lab

## 3. Source Code Management

1. Select **Git** in Source Code Management section
2. Enter **Repository URL**
   - e.g., `https://github.com/k8s-edu/Bkv2_sub_echo-ip.git`
3. Change **Branch Specifier**
   - Change `*/master` to `*/main`

## 4. Build Steps

1. Go to **Build Steps** section
2. Click **Add build step**
3. Select **Execute shell**
4. Enter shell script:
   ```bash
   # CI tasks
   docker build -t 192.168.1.10:8443/library/echo-ip .
   docker login --username admin --password admin 192.168.1.10:8443
   docker push 192.168.1.10:8443/library/echo-ip

   # CD tasks
   kubectl create deployment fs-echo-ip --image=192.168.1.10:8443/library/echo-ip -n default
   kubectl expose deployment fs-echo-ip --type=LoadBalancer --name=fs-echo-ip-svc --port=80 -n default
   ```
5. Click **Save**

## 5. Run Build

1. Click **Build Now** on the project page
2. Check build result in **Build History**
   - Green: Success
   - Red: Failure
3. Click build number (e.g., #1) → **Console Output** for detailed logs

## 6. Delete Project (Optional)

1. Click **Delete Project** on the project page
2. Confirm deletion
