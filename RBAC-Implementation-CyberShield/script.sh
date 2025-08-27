#!/usr/bin/env bash
# CYBERSHIELD CORP – RBAC Implementation (Kali/Debian/Ubuntu)
# Run with: sudo bash script.sh

set -euo pipefail

# ---- Safety checks ----
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root: sudo bash script.sh"
  exit 1
fi

# ---- Vars ----
BASE="/Company"
DEPTS=(engineering hr finance marketing itsupport executive)

# Users (username:primary_group)
USERS=(
  "alice_eng:engineering"
  "kelly_eng:engineering"
  "bob_hr:hr"
  "tim_hr:hr"
  "john_fin:finance"
  "clara_fin:finance"
  "rita_mark:marketing"
  "kevin_it:itsupport"
  "ceo_exec:executive"
)

# ---- Create groups ----
echo "[*] Creating department groups (ok if they already exist)…"
for g in "${DEPTS[@]}"; do
  getent group "$g" >/dev/null || groupadd "$g"
done

# ---- Create base and department dirs ----
echo "[*] Creating directory structure under $BASE …"
mkdir -p "$BASE"
chown root:root "$BASE"
chmod 755 "$BASE"

for d in "${DEPTS[@]}"; do
  mkdir -p "$BASE/$d"
  chown root:"$d" "$BASE/$d"
  chmod 770 "$BASE/$d"
done

# ---- Shared structure ----
mkdir -p "$BASE/shared/campaign_budget" \
         "$BASE/shared/hr_finance_reports" \
         "$BASE/shared/announcements"

# Default secure perms before ACLs
for sd in campaign_budget hr_finance_reports announcements; do
  chown root:root "$BASE/shared/$sd"
  chmod 770 "$BASE/shared/$sd"
done

# ---- Create users and assign to groups ----
echo "[*] Creating users and adding to primary groups…"
for entry in "${USERS[@]}"; do
  usr="${entry%%:*}"
  grp="${entry##*:}"

  if id "$usr" >/dev/null 2>&1; then
    echo "  - $usr exists; ensuring primary group is $grp and home dir present"
    usermod -g "$grp" "$usr" || true
    [[ -d "/home/$usr" ]] || mkdir -p "/home/$usr"
    chown -R "$usr:$grp" "/home/$usr"
  else
    useradd -m -s /bin/bash -g "$grp" "$usr"
    # Force password change on first login (no password set here)
    chage -d 0 "$usr"
  fi
done

# ---- ACLs for shared folders ----
echo "[*] Applying ACLs…"

# /Company/shared/campaign_budget
# Marketing: rwx, Finance: rx
setfacl -b "$BASE/shared/campaign_budget"
setfacl -m g:marketing:rwx,g:finance:rx,m::rwx "$BASE/shared/campaign_budget"
setfacl -d -m g:marketing:rwx,g:finance:rx,m::rwx "$BASE/shared/campaign_budget"

# /Company/shared/hr_finance_reports
# HR: rx, Finance: rx
setfacl -b "$BASE/shared/hr_finance_reports"
setfacl -m g:hr:rx,g:finance:rx,m::rx "$BASE/shared/hr_finance_reports"
setfacl -d -m g:hr:rx,g:finance:rx,m::rx "$BASE/shared/hr_finance_reports"

# /Company/shared/announcements – read/execute for everyone
setfacl -b "$BASE/shared/announcements"
chmod 755 "$BASE/shared/announcements"
# Ensure new files inherit world-read
setfacl -d -m o:rx,m::rx "$BASE/shared/announcements"

# ---- Verification hints ----
echo
echo "[*] Done. Verify with:"
echo "  getfacl $BASE/shared/campaign_budget"
echo "  getfacl $BASE/shared/hr_finance_reports"
echo "  getfacl $BASE/shared/announcements"
echo
echo "[*] Sample checks:"
echo "  id alice_eng"
echo "  ls -ld $BASE/* $BASE/shared/*"
