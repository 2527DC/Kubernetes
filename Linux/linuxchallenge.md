# Linux Challenge -- User, Permission & Folder Structure Scenarios

---

## PART 1: Linux User & Permission -- Scenario Based Questions

### Scenario 1: New Developer Joined

Your company hired a developer named `arun`.

1.  Create a user `arun` with home directory and bash shell.
2.  Force him to change password on first login.
3.  Add him to a group called `developers`.
4.  Verify if he belongs to that group.
5.  Lock his account temporarily without deleting it.
6.  Set password expiry to 30 days.
7.  How will you check when his password expires?

---

### Scenario 2: Production Server -- Secure Folder

There is a folder:

`/var/www/project`

Only: - `deploy` user → full access - `developers` group → read only -
Others → no access

1.  Create user `deploy`.
2.  Create group `developers`.
3.  Set correct ownership for folder.
4.  Set correct permissions.
5.  How to make sure new files inside inherit the group?
6.  How to prevent others from accessing it?

---

### Scenario 3: Shared Folder Between Two Users

Users: - `ram` - `shyam`

They should: - Both read/write files - But cannot delete each other's
files

1.  How to create shared folder `/shared/data`?
2.  What permissions should be applied?
3.  What special permission prevents deleting others' files?

---

### Scenario 4: Log File Access

A log file:

`/var/log/app.log`

Only: - `appuser` → read/write - `support` group → read only

1.  How to assign group to file?
2.  How to give group read-only access?
3.  How to remove execute permission if accidentally given?
4.  How to check permission in numeric format?

---

### Scenario 5: Sudo Access Control

You want: - `arun` can restart nginx - But cannot run all root commands

1.  Where do you configure sudo rules?
2.  How to allow only: `systemctl restart nginx`?
3.  How to test without logging out?

---

## PART 2: Linux Folder Structure -- Scenario Based

### Scenario 6: Where Should This Be Stored?

Decide correct directory:

1.  Where should application binaries go?
2.  Where should custom scripts go?
3.  Where should system configuration files go?
4.  Where are user home directories stored?
5.  Where are logs stored?
6.  Where are temporary files stored?
7.  Where are third-party software usually installed?
8.  Where is bootloader stored?
9.  Where are device files stored?

---

### Scenario 7: Server Disk Full

Your server shows 100% disk usage.

1.  How to check disk usage?
2.  How to check folder size?
3.  Which directory usually fills first?
4.  How to check largest files?
5.  Which directory should never be manually deleted?

---

### Scenario 8: Application Deployment

You are deploying a Laravel app.

1.  Where should project be placed?
2.  Where should environment file be stored?
3.  Where are nginx configs stored?
4.  Where are systemd service files stored?
5.  Where do cron jobs live?

---

## Advanced Practice

1.  Set SUID on a file and test it.
2.  Set SGID on a directory and verify inheritance.
3.  Set Sticky Bit on a shared folder.
4.  Use ACL (`setfacl`) to give specific user extra permissions.
5.  Create restricted shell user.
6.  Configure `/etc/sudoers` safely.

---

## Interview Level Questions

1.  What happens if home directory permission is 777?
2.  Difference between `chmod 755` and `chmod 775`?
3.  What is the difference between SUID and SGID?
4.  How does sticky bit work?
5.  What happens if `/etc/passwd` permission changes?
6.  Why should `/tmp` have 1777 permission?
