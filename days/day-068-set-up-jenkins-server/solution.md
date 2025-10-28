# 1. Install Java 17
yum install -y java-17-openjdk java-17-openjdk-devel

# 2. Add Jenkins repository (using curl)
curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# 3. Install Jenkins
yum install -y jenkins

# 4. Start and enable Jenkins service
systemctl start jenkins
systemctl enable jenkins

# 5. Check status
systemctl status jenkins


Access Jenkins UI:

Click "Jenkins" button on top bar (as mentioned)
Or navigate to: http://jenkins-server:8080
Initial Setup Wizard:

Enter the initial admin password from /var/lib/jenkins/secrets/initialAdminPassword
Choose "Install suggested plugins" (recommended)
Wait for plugin installation to complete
Create Admin User:

Username: theadmin
Password: Adm!n321
Full name: Ravi
Email: ravi@jenkins.stratos.xfusioncorp.com
Instance Configuration:

Keep default Jenkins URL or adjust as needed
Click "Save and Finish"