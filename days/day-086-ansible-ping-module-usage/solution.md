# Day 086: Ansible Ping Module Usage - Solution

## Challenge Requirements
- Set up passwordless SSH connection between Ansible controller (jump host) and App Server 1
- Test Ansible ping from jump host to App Server 1 using the inventory file

## Solution Steps

### Step 1: Generate SSH Key Pair (on jump host as thor user)
```bash
# Generate SSH key pair without passphrase
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
```

### Step 2: Copy Public Key to App Server 1
```bash
# Copy public key to App Server 1 (will prompt for password: Ir0nM@n)
ssh-copy-id -i ~/.ssh/id_rsa.pub thor@172.16.238.10
```

### Step 3: Test SSH Connection
```bash
# Verify passwordless SSH works
ssh thor@172.16.238.10 "echo 'SSH connection successful'"
```

### Step 4: Update Inventory File (Option 1 - Modify existing)
Edit `/home/thor/ansible/inventory` to use key-based authentication:
```ini
stapp01 ansible_host=172.16.238.10 ansible_user=thor ansible_ssh_private_key_file=~/.ssh/id_rsa
stapp02 ansible_host=172.16.238.11 ansible_ssh_pass=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_ssh_pass=BigGr33n
```

### Step 4: Update Inventory File (Option 2 - Create new file)
Create a new inventory file with passwordless configuration:
```ini
stapp01 ansible_host=172.16.238.10 ansible_user=thor ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Step 5: Test Ansible Ping Module
```bash
# Test Ansible ping to App Server 1
ansible stapp01 -i /home/thor/ansible/inventory -m ping

# Expected output:
# stapp01 | SUCCESS => {
#     "ansible_facts": {
#         "discovered_interpreter_python": "/usr/bin/python"
#     },
#     "changed": false,
#     "ping": "pong"
# }
```

## Key Points
1. **Passwordless SSH** is achieved through SSH key pairs (public/private key authentication)
2. **ansible_ssh_pass** parameter is removed from inventory for passwordless connection
3. **ansible_ssh_private_key_file** parameter specifies the private key location
4. **ansible_user** parameter specifies the remote user (thor)

## Verification
- SSH connection should work without password prompt
- Ansible ping should return "pong" without asking for credentials
- Connection should be established using SSH keys only

## Troubleshooting
If ping fails:
1. Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
2. Check SSH connection manually: `ssh thor@172.16.238.10`
3. Verify inventory file syntax and paths
4. Ensure SSH agent is running if needed: `ssh-add ~/.ssh/id_rsa`