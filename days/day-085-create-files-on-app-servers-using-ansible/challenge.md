# Day 085: Create Files on App Servers using Ansible
The Nautilus DevOps team is testing various Ansible modules on servers in Stratos DC. They're currently focusing on file creation on remote hosts using Ansible. Here are the details:


a. Create an inventory file ~/playbook/inventory on jump host and include all app servers.


b. Create a playbook ~/playbook/playbook.yml to create a blank file /tmp/nfsshare.txt on all app servers.


c. Set the permissions of the /tmp/nfsshare.txt file to 0777.


d. Ensure the user/group owner of the /tmp/nfsshare.txt file is tony on app server 1, steve on app server 2 and banner on app server 3.


Note: Validation will execute the playbook using the command ansible-playbook -i inventory playbook.yml, so ensure the playbook functions correctly without any additional arguments.