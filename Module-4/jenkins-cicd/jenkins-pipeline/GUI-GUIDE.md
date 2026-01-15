# Jenkins Pipeline Project GUI Guide

## Prerequisites

Log in to Jenkins with admin account.
- Username: `admin`
- Password: `admin`
- Check 'Keep me signed in'

---

## 1. Install Docker Pipeline Plugin

1. Click **Manage Jenkins** on the home page
2. Click **Plugins**
3. Select **Available plugins** tab
4. Search for `Docker pipeline`
5. Select **Docker Pipeline** plugin
6. Click **Install**
7. Click **Go back to the top page** after installation

## 2. Add Harbor Credentials

1. Click **Manage Jenkins** on the home page
2. Click **Credentials**
3. Click **(global)** in Domains section
4. Click **Add Credentials**
5. Enter the following:
   - **Kind**: Username with password (default)
   - **Scope**: Global (default)
   - **Username**: `admin`
   - **Password**: `admin`
   - **ID**: `harbor-credential`
   - **Description**: Harbor credentials (optional)
6. Click **Create**
7. Verify `harbor-credential` is created

## 3. Create New Pipeline Item

1. Click **New Item** in the left menu
2. Enter item name (e.g., `pl-echo-ip`)
3. Select **Pipeline**
4. Click **OK**

## 4. General Settings

1. Keep default values in **General** section
   - Project description and build behavior settings

## 5. Build Triggers Settings

1. Keep default values in **Build Triggers** section
   - Options available:
     - Build after other projects are built
     - Build periodically
     - Poll SCM
     - Quiet period
     - Trigger builds remotely

## 6. Advanced Project Options

1. Keep default values in **Advanced Project Options** section
   - Advanced options added by plugins

## 7. Pipeline Settings

1. Go to **Pipeline** section
2. Select **Pipeline script from SCM** in Definition dropdown
3. Select **Git** in SCM dropdown
4. Enter **Repository URL**
   - e.g., `https://github.com/k8s-edu/Bkv2_sub_echo-ip.git`
5. Verify/modify **Branch Specifier**
   - Set to `*/main`
6. Verify **Script Path**
   - Default: `Jenkinsfile`
7. Click **Save**

## 8. Run Build

1. Click **Build Now** on the project page
2. Check build result in **Build History**
   - Green: Success
   - Red: Failure
3. Click build number → **Console Output** for detailed logs

## 9. Delete Project (Optional)

1. Click **Delete Project** on the project page
2. Confirm deletion
