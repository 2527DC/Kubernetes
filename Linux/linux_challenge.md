# 🐧 Linux User, Permission & Folder Structure — Scenario Challenge Questions

> **Goal:** Solve each scenario hands-on in a real Linux terminal.  
> **Practice tip:** Use WSL, KillerCoda (killercoda.com), or Google Cloud Shell — all free!

---

## 🔐 SECTION 1: User & Permission Management Scenarios

---

### 🟡 Scenario 1 — New Employee Onboarding

**Situation:**  
A new developer **"alice"** joins your team. She needs access to `/var/www/html` to deploy code, but should **NOT** be able to modify system files. Create her account, assign her to the `webdev` group, and set appropriate permissions on the directory.

**Your Tasks:**

- Create user `alice`
- Create group `webdev`
- Assign `alice` to the `webdev` group
- Set directory ownership and permissions on `/var/www/html`
- Switch to `alice` and test access

**Commands to explore:** `useradd`, `groupadd`, `usermod -aG`, `chown`, `chmod`, `su - alice`

**Verify with:** `id alice`, `ls -ld /var/www/html`

---

### 🟡 Scenario 2 — Shared Project Folder

**Situation:**  
Three developers **(bob, carol, dan)** are working on the same project. They all need **read/write** access to `/projects/alpha`, but **no one outside** the team should even list the directory.

**Your Tasks:**

- Create users: `bob`, `carol`, `dan`
- Create group `alpha_team` and add all three
- Create `/projects/alpha` with correct group ownership
- Apply **sticky bit** so users can't delete each other's files
- Set permissions so "others" have zero access

**Commands to explore:** `chmod 1770`, `chown :alpha_team`, `usermod -aG`

**Verify with:** `ls -ld /projects/alpha`, switch to a non-member and try `ls /projects/alpha`

---

### 🔴 Scenario 3 — Security Breach Lockdown

**Situation:**  
You suspect user **"mallory"** has been doing suspicious activity. Without deleting her account (for audit purposes), you must **immediately revoke her login access** and expire her password.

**Your Tasks:**

- Lock mallory's account
- Expire her password
- Change her shell to `/sbin/nologin`
- Verify she cannot log in

**Commands to explore:** `usermod -L mallory`, `passwd -e mallory`, `usermod -s /sbin/nologin mallory`

**Verify with:** `getent passwd mallory`, `su - mallory`

---

### 🔴 Scenario 4 — Sudo Access Gone Wrong

**Situation:**  
A junior sysadmin **"john"** was accidentally given full sudo access. You need to restrict him so he can **only restart nginx** and nothing else.

**Your Tasks:**

- Open sudoers file safely
- Remove full sudo access for john
- Add a restricted rule allowing only nginx restart
- Test by logging in as john and trying other sudo commands

**Commands to explore:** `visudo`, edit `/etc/sudoers`

**Sudoers rule to write:**

```
john ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
```

**Verify with:** `sudo systemctl restart nginx` (should work), `sudo apt update` (should be denied)

---

### 🟡 Scenario 5 — File Confidentiality

**Situation:**  
HR drops a file `salaries.csv` in `/hr/reports/`. Only the `hr` group should **read** it, the owner can **read/write**, and **no one else** should touch it.

**Your Tasks:**

- Create `/hr/reports/salaries.csv`
- Set owner to `hrmanager`, group to `hr`
- Apply permission `640`
- Test access as a user outside the `hr` group

**Commands to explore:** `chown hrmanager:hr salaries.csv`, `chmod 640 salaries.csv`

**Verify with:** `ls -l /hr/reports/salaries.csv`, try `cat` as another user

---

### 🔴 Scenario 6 — Executable Script with Elevated Privileges

**Situation:**  
A shell script `/opt/scripts/backup.sh` needs to **run as root** regardless of who executes it (for backup purposes). Set this up safely and understand the risk.

**Your Tasks:**

- Write a simple backup script
- Set the `setuid` bit on it
- Test running it as a non-root user
- Discuss: Why is setuid on shell scripts dangerous?

**Commands to explore:** `chmod u+s /opt/scripts/backup.sh`, `ls -l` (look for the `s` in permissions)

**Think about:** Why does Linux often ignore setuid on shell scripts? What's the safer alternative?

---

## 📁 SECTION 2: Folder Structure Scenarios

---

### 🟡 Scenario 7 — Multi-Site Web Server Structure

**Situation:**  
Your company hosts **3 websites**: `site1.com`, `site2.com`, `site3.com`. Each site has its own logs, configs, and web root. Each site is managed by a **different team**.

**Your Tasks:**

- Design and create the full folder tree under `/var/www/`
- Create a group per site team: `team1`, `team2`, `team3`
- Assign ownership of each site folder to its respective team
- Set permissions so teams can't access each other's folders

**Expected folder structure:**

```
/var/www/
├── site1.com/
│   ├── html/
│   ├── logs/
│   └── config/
├── site2.com/
│   ├── html/
│   ├── logs/
│   └── config/
└── site3.com/
    ├── html/
    ├── logs/
    └── config/
```

**Commands to explore:** `mkdir -p`, `chown -R`, `chmod -R`, `groupadd`

---

### 🟡 Scenario 8 — Shared Drop Zone vs Private Analytics Folder

**Situation:**  
Your `/data` partition needs two special directories:

- `/data/dropzone` — all users can **drop files** but **cannot delete** each other's files
- `/data/analytics` — **only** the `analytics` group can read it

**Your Tasks:**

- Create both directories
- Apply **sticky bit** on `/data/dropzone`
- Set group restriction on `/data/analytics`
- Test by creating files as different users

**Commands to explore:** `chmod 1777 /data/dropzone`, `chmod 750 /data/analytics`, `chown :analytics /data/analytics`

**Verify:** Can user A delete user B's file in dropzone? Can a non-analytics user read `/data/analytics`?

---

### 🔴 Scenario 9 — Orphaned Files After Employee Departure

**Situation:**  
A developer **"ghost"** left the company. Files they created are scattered all over `/opt/apps`. You need to **find all files owned by ghost** and reassign them to `nobody`.

**Your Tasks:**

- Use `find` to locate all files owned by `ghost`
- Reassign ownership to `nobody`
- Do the same for directories

**Commands to explore:**

```bash
find /opt/apps -user ghost -type f
find /opt/apps -user ghost -exec chown nobody {} \;
```

**Verify with:** `find /opt/apps -user ghost` (should return nothing after fix)

---

### 🔴 Scenario 10 — Broken Permissions Debug

**Situation:**  
A developer reports: **"my app can't write to `/var/log/myapp/`"**. The app process runs as user `appuser`. Diagnose and fix the issue **without giving world-write permissions**.

**Your Tasks:**

- Check current ownership and permissions of `/var/log/myapp/`
- Identify why `appuser` can't write
- Fix it using the least-privilege approach
- Verify the app can now write

**Diagnostic commands:**

```bash
ls -ld /var/log/myapp/
ps aux | grep myapp        # check what user the process runs as
id appuser
```

**Fix options to consider:** `chown appuser /var/log/myapp/` OR create group `applog`, add `appuser`, set `chmod 775`

---

## 🧪 BONUS CHALLENGE — Put It All Together

**Situation:**  
You're setting up a small server from scratch for a startup with the following requirements:

1. 3 developers: `dev1`, `dev2`, `dev3` — can deploy to `/var/www/app` but not touch system files
2. 1 DBA: `dba1` — exclusive access to `/var/db/data`
3. 1 HR user: `hr1` — access only to `/hr/` directory
4. A shared `/tmp/uploads` where everyone can write but not delete others' files
5. `dev1` should be able to restart the app service via sudo only
6. `dba1`'s account should auto-expire in 30 days

**Implement the full setup and document every command you use.**

---

## 🖥️ How to Practice (Free Options)

| Platform               | How to Access                     | Best For                     |
| ---------------------- | --------------------------------- | ---------------------------- |
| **WSL (Windows)**      | Run `wsl --install` in PowerShell | Local hands-on               |
| **KillerCoda**         | killercoda.com                    | Browser-based labs, no setup |
| **Google Cloud Shell** | shell.cloud.google.com            | Free Linux VM in browser     |
| **Play with Docker**   | labs.play-with-docker.com         | Quick Alpine Linux terminals |

---

## 📋 Quick Reference — Key Commands

```bash
# User Management
useradd username              # create user
passwd username               # set password
usermod -aG groupname user    # add user to group
usermod -L username           # lock account
usermod -s /sbin/nologin user # disable login shell
userdel -r username           # delete user + home dir

# Group Management
groupadd groupname            # create group
groups username               # list user's groups
id username                   # full user/group info
getent passwd username        # check user entry

# Permissions
chmod 755 file/dir            # rwxr-xr-x
chmod 640 file                # rw-r-----
chmod 1777 dir                # rwxrwxrwt (sticky bit)
chmod u+s file                # setuid
chown user:group file         # change ownership
chown -R user:group dir/      # recursive ownership

# Finding Files
find /path -user username     # files owned by user
find /path -perm /4000        # files with setuid
find /path -type f -name "*.log"

# Sudo
visudo                        # safely edit sudoers
sudo -l -U username           # list sudo rules for user
```

---

_Happy learning! Work through each scenario in order — they build on each other. 🚀_
