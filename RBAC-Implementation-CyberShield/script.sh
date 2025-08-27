#!/bin/bash

# === Setup RBAC Environment for Cybershield Corp ===

echo "Creating department groups..."
for dept in engineering hr finance marketing itsupport; do
    groupadd $dept
done

echo "Creating users and assigning to groups..."

# Engineering
for user in alice_eng dave_eng jude_eng kelly_eng fatima_eng; do
    useradd -m $user -G engineering
    echo "$user:Passw0rd123" | chpasswd
done

# HR
for user in bob_hr susan_hr moses_hr tim_hr tolu_hr; do
    useradd -m $user -G hr
    echo "$user:Passw0rd123" | chpasswd
done

# Finance
for user in john_fin clara_fin steve_fin kemi_fin chi_fin; do
    useradd -m $user -G finance
    echo "$user:Passw0rd123" | chpasswd
done

# Marketing
for user in francis_mark rita_mark lukman_mark tom_mark farida_mark; do
    useradd -m $user -G marketing
    echo "$user:Passw0rd123" | chpasswd
done

# IT Support
for user in damilola_it yusuf_it zainab_it kevin_it bolu_it; do
    useradd -m $user -G itsupport
    echo "$user:Passw0rd123" | chpasswd
done

echo "Creating department directories..."
mkdir -p /company/{engineering,hr,finance,marketing,itsupport}

echo "Setting ownership and permissions..."
chown root:engineering /company/engineering
chmod 770 /company/engineering

chown root:hr /company/hr
chmod 770 /company/hr

chown root:finance /company/finance
chmod 770 /company/finance

chown root:marketing /company/marketing
chmod 770 /company/marketing

chown root:itsupport /company/itsupport
chmod 770 /company/itsupport

echo "Creating departmental files..."
touch /company/engineering/source_code.py
echo "Confidential source code" > /company/engineering/source_code.py

touch /company/hr/staff_reviews.txt
echo "HR performance reviews" > /company/hr/staff_reviews.txt

touch /company/finance/budget2025.txt
echo "Finance budget document" > /company/finance/budget2025.txt

touch /company/marketing/ad_campaigns.docx
echo "Marketing plans" > /company/marketing/ad_campaigns.docx

touch /company/itsupport/server_logs.log
echo "IT server logs" > /company/itsupport/server_logs.log

echo "Assigning ownership and cross-group access (with some real-world overlaps)..."

# 1. Over-privilege: Engineering staff owns IT folder
chown jude_eng /company/itsupport

# 2. Cross-department: HR staff added to Finance
usermod -aG finance susan_hr

# 3. Cross-department: Engineering staff added to Finance
usermod -aG finance fatima_eng

# 4. Over-privilege: HR staff added to Engineering
usermod -aG engineering moses_hr

# 5. Over-privilege: Marketing staff added to HR (access to employee reviews)
usermod -aG hr tom_mark

# 6. Over-privilege: IT staff added to Marketing
usermod -aG marketing bolu_it

# 7. Cross-department: Marketing staff owns Finance folder
chown rita_mark /company/finance

# 8. Over-privilege: Finance staff owns HR directory
chown john_fin /company/hr

# 9. Cross-department: Engineering staff added to IT Support
usermod -aG itsupport dave_eng

echo "Applying incorrect permissions to simulate misconfigurations..."

# 10. Too open: Finance folder accessible to all users (world-readable)
chmod 777 /company/finance

# 11. Too open: HR folder readable by all (leaks staff reviews)
chmod 755 /company/hr

# 12. Engineering file accessible to all
chmod 666 /company/engineering/source_code.py

# 13. IT support logs executable (unusual and risky)
chmod 775 /company/itsupport/server_logs.log

# 14. Marketing folder is writable by others (risk of tampering)
chmod 757 /company/marketing

echo "RBAC setup complete for Cybershield Corp!"
