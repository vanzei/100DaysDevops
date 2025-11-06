# Ansible Inventory Resources Guide

## Overview
This guide provides comprehensive information about Ansible inventory files, focusing on the INI format, credential management, and best practices for both Linux and Windows environments.

## What is an Ansible Inventory?

An Ansible inventory is a file that defines the hosts and groups of hosts upon which commands, modules, and tasks in a playbook operate. The inventory file tells Ansible where your servers are located and how to connect to them.

## Inventory File Formats

Ansible supports multiple inventory formats:
- **INI format** (most common and human-readable)
- **YAML format** (more structured, better for complex configurations)
- **JSON format** (programmatically generated)
- **Dynamic inventory** (scripts that generate inventory on-the-fly)

This guide focuses on the **INI format** as it's the most widely used and easiest to understand.

## INI Format Structure

### Basic Syntax

```ini
# This is a comment
[group_name]
hostname1 ansible_host=192.168.1.10
hostname2 ansible_host=192.168.1.11

[another_group]
server1
server2
```

### Key Components

1. **Groups**: Defined in square brackets `[group_name]`
2. **Hosts**: Listed under groups with optional variables
3. **Variables**: Can be assigned to individual hosts or entire groups
4. **Comments**: Lines starting with `#` are ignored

## Host Definition Patterns

### Simple Host Definition
```ini
[webservers]
web1
web2
web3
```

### Host with IP Address
```ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11
```

### Host with Custom SSH Port
```ini
[webservers]
web1 ansible_host=192.168.1.10 ansible_port=2222
```

### Range Patterns
```ini
[webservers]
web[01:50]  # Creates web01, web02, ... web50

[databases]
db[a:f]     # Creates dba, dbb, dbc, dbd, dbe, dbf
```

## Common Ansible Variables

### Connection Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ansible_host` | Real hostname/IP to connect to | `ansible_host=192.168.1.10` |
| `ansible_port` | SSH port number | `ansible_port=2222` |
| `ansible_user` | SSH username | `ansible_user=ubuntu` |
| `ansible_ssh_private_key_file` | SSH private key path | `ansible_ssh_private_key_file=~/.ssh/id_rsa` |
| `ansible_connection` | Connection type | `ansible_connection=ssh` |

### Authentication Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ansible_password` | SSH password (not recommended) | `ansible_password=mypassword` |
| `ansible_sudo_pass` | Sudo password | `ansible_sudo_pass=sudopassword` |
| `ansible_become` | Enable privilege escalation | `ansible_become=yes` |
| `ansible_become_method` | Escalation method | `ansible_become_method=sudo` |
| `ansible_become_user` | User to become | `ansible_become_user=root` |

### System Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ansible_python_interpreter` | Python path | `ansible_python_interpreter=/usr/bin/python3` |
| `ansible_shell_type` | Shell type | `ansible_shell_type=sh` |

## Linux Environment Configuration

### Basic Linux Host Configuration

```ini
[linux_servers]
# Ubuntu/Debian servers
ubuntu1 ansible_host=192.168.1.10 ansible_user=ubuntu
ubuntu2 ansible_host=192.168.1.11 ansible_user=ubuntu

# CentOS/RHEL servers
centos1 ansible_host=192.168.1.20 ansible_user=centos
centos2 ansible_host=192.168.1.21 ansible_user=ec2-user

# Generic Linux servers
server1 ansible_host=192.168.1.30 ansible_user=admin
```

### Linux with SSH Key Authentication

```ini
[linux_servers]
web1 ansible_host=192.168.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/web_key
db1 ansible_host=192.168.1.20 ansible_user=centos ansible_ssh_private_key_file=~/.ssh/db_key
```

### Linux with Sudo Configuration

```ini
[linux_servers]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu ansible_become=yes ansible_become_method=sudo
server2 ansible_host=192.168.1.11 ansible_user=centos ansible_become=yes ansible_become_user=root
```

### Linux with Custom Python Interpreter

```ini
[linux_servers]
# For systems with Python 3 only
modern_server ansible_host=192.168.1.10 ansible_python_interpreter=/usr/bin/python3

# For systems with custom Python path
custom_server ansible_host=192.168.1.11 ansible_python_interpreter=/opt/python/bin/python
```

## Windows Environment Configuration

### Basic Windows Host Configuration

```ini
[windows_servers]
win1 ansible_host=192.168.1.50
win2 ansible_host=192.168.1.51
```

### Windows with WinRM Configuration

```ini
[windows_servers]
win1 ansible_host=192.168.1.50 ansible_connection=winrm ansible_winrm_transport=ntlm
win2 ansible_host=192.168.1.51 ansible_connection=winrm ansible_winrm_transport=kerberos
```

### Windows Authentication Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ansible_connection` | Connection type for Windows | `ansible_connection=winrm` |
| `ansible_winrm_transport` | WinRM transport method | `ansible_winrm_transport=ntlm` |
| `ansible_winrm_server_cert_validation` | Certificate validation | `ansible_winrm_server_cert_validation=ignore` |
| `ansible_winrm_port` | WinRM port | `ansible_winrm_port=5986` |
| `ansible_winrm_scheme` | WinRM scheme | `ansible_winrm_scheme=https` |

### Complete Windows Configuration Example

```ini
[windows_servers]
win-server1 ansible_host=192.168.1.50 ansible_user=Administrator ansible_password=MyPassword123 ansible_connection=winrm ansible_winrm_transport=ntlm ansible_winrm_server_cert_validation=ignore

win-server2 ansible_host=192.168.1.51 ansible_user=domain\\serviceaccount ansible_password=ServicePassword123 ansible_connection=winrm ansible_winrm_transport=kerberos
```

## Group Variables

### Defining Group Variables in Inventory

```ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[webservers:vars]
ansible_user=ubuntu
ansible_become=yes
http_port=80
max_clients=200

[databases]
db1 ansible_host=192.168.1.20
db2 ansible_host=192.168.1.21

[databases:vars]
ansible_user=postgres
db_port=5432
```

### Group of Groups (Parent Groups)

```ini
[atlanta]
host1
host2

[raleigh]
host3
host4

[southeast:children]
atlanta
raleigh

[southeast:vars]
region=southeast
timezone=America/New_York
```

## Credential Management Best Practices

### 1. SSH Key-Based Authentication (Recommended)

**Setup SSH Keys:**
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "ansible@company.com"

# Copy public key to target hosts
ssh-copy-id -i ~/.ssh/id_rsa.pub user@target-host
```

**Inventory Configuration:**
```ini
[servers]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 2. SSH Agent (For Multiple Keys)

**Setup SSH Agent:**
```bash
# Start SSH agent
ssh-agent bash

# Add keys to agent
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/another_key
```

**Inventory Configuration:**
```ini
[servers]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu
server2 ansible_host=192.168.1.11 ansible_user=centos
```

### 3. Ansible Vault (For Sensitive Data)

**Create Vault File:**
```bash
# Create encrypted vault file
ansible-vault create group_vars/all/vault.yml
```

**Vault Content:**
```yaml
vault_db_password: supersecretpassword
vault_api_key: secretapikey123
```

**Reference in Inventory:**
```ini
[databases]
db1 ansible_host=192.168.1.20 ansible_user=postgres

[databases:vars]
db_password="{{ vault_db_password }}"
```

### 4. Environment Variables

**Set Environment Variables:**
```bash
export ANSIBLE_USER=ubuntu
export ANSIBLE_PRIVATE_KEY_FILE=~/.ssh/id_rsa
```

**Use in Inventory:**
```ini
[servers]
server1 ansible_host=192.168.1.10
server2 ansible_host=192.168.1.11
```

## Advanced Inventory Patterns

### Host Aliases

```ini
[webservers]
frontend ansible_host=web-server-01.company.com
backend ansible_host=web-server-02.company.com
database ansible_host=db-server-01.company.com
```

### Multiple Groups for Same Host

```ini
[webservers]
server1

[databases]
server1

[monitoring]
server1
```

### Conditional Variables

```ini
[ubuntu_servers]
server1 ansible_host=192.168.1.10 os_family=debian

[centos_servers]
server2 ansible_host=192.168.1.20 os_family=redhat

[all_servers:children]
ubuntu_servers
centos_servers

[all_servers:vars]
ansible_user=admin
```

## Special Groups

### Built-in Groups

- **all**: Contains all hosts from inventory
- **ungrouped**: Contains hosts not in any other group

### Using Built-in Groups

```ini
[webservers]
web1
web2

[all:vars]
ansible_user=admin
ntp_server=time.company.com

[ungrouped]
standalone_server ansible_host=192.168.1.100
```

## Common Patterns for Different Environments

### Development Environment

```ini
[dev_webservers]
dev-web1 ansible_host=192.168.10.10 ansible_user=developer
dev-web2 ansible_host=192.168.10.11 ansible_user=developer

[dev_databases]
dev-db1 ansible_host=192.168.10.20 ansible_user=postgres

[development:children]
dev_webservers
dev_databases

[development:vars]
environment=development
debug_mode=true
```

### Production Environment

```ini
[prod_webservers]
prod-web1 ansible_host=10.0.1.10 ansible_user=webapp
prod-web2 ansible_host=10.0.1.11 ansible_user=webapp

[prod_databases]
prod-db1 ansible_host=10.0.2.10 ansible_user=postgres

[production:children]
prod_webservers
prod_databases

[production:vars]
environment=production
debug_mode=false
ssl_enabled=true
```

### Mixed Linux/Windows Environment

```ini
[linux_servers]
ubuntu1 ansible_host=192.168.1.10 ansible_user=ubuntu
centos1 ansible_host=192.168.1.20 ansible_user=centos

[windows_servers]
win1 ansible_host=192.168.1.50 ansible_user=Administrator ansible_connection=winrm
win2 ansible_host=192.168.1.51 ansible_user=ServiceAccount ansible_connection=winrm

[linux_servers:vars]
ansible_become=yes
ansible_python_interpreter=/usr/bin/python3

[windows_servers:vars]
ansible_connection=winrm
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
```

## Testing and Validation

### Test Connectivity

```bash
# Test connectivity to all hosts
ansible all -i inventory -m ping

# Test specific group
ansible webservers -i inventory -m ping

# Test specific host
ansible server1 -i inventory -m ping
```

### Gather Facts

```bash
# Gather system information
ansible all -i inventory -m setup

# Get specific facts
ansible all -i inventory -m setup -a "filter=ansible_os_family"
```

### Run Ad-hoc Commands

```bash
# Check uptime
ansible all -i inventory -a "uptime"

# Check disk space
ansible linux_servers -i inventory -a "df -h"

# Windows equivalent
ansible windows_servers -i inventory -m win_command -a "dir C:\\"
```

## Troubleshooting Common Issues

### SSH Connection Issues

**Problem**: SSH authentication fails
**Solution**:
```ini
# Add explicit SSH options
[servers]
server1 ansible_host=192.168.1.10 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Python Interpreter Issues

**Problem**: Python not found
**Solution**:
```ini
# Specify Python path
[servers]
server1 ansible_host=192.168.1.10 ansible_python_interpreter=/usr/bin/python3
```

### Privilege Escalation Issues

**Problem**: Permission denied for sudo
**Solution**:
```ini
# Configure sudo properly
[servers]
server1 ansible_host=192.168.1.10 ansible_become=yes ansible_become_method=sudo ansible_become_user=root
```

### Windows Connection Issues

**Problem**: WinRM connection fails
**Solution**:
```ini
# Configure WinRM properly
[windows_servers]
win1 ansible_host=192.168.1.50 ansible_connection=winrm ansible_winrm_transport=ntlm ansible_winrm_server_cert_validation=ignore ansible_winrm_port=5985
```

## Security Considerations

### 1. Never Store Passwords in Plain Text
❌ **Bad:**
```ini
[servers]
server1 ansible_host=192.168.1.10 ansible_password=secretpass
```

✅ **Good:**
```ini
[servers]
server1 ansible_host=192.168.1.10 ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 2. Use Ansible Vault for Sensitive Data
```bash
# Encrypt sensitive variables
ansible-vault encrypt_string 'supersecret' --name 'db_password'
```

### 3. Limit SSH Access
```ini
[servers]
server1 ansible_host=192.168.1.10 ansible_user=ansible-user ansible_ssh_private_key_file=~/.ssh/ansible_key
```

### 4. Use Jump Hosts for Secure Networks
```ini
[servers]
server1 ansible_host=10.0.1.10 ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p jumphost"'
```

## Best Practices Summary

1. **Use descriptive host and group names**
2. **Prefer SSH keys over passwords**
3. **Group hosts logically by function or environment**
4. **Use group variables to reduce duplication**
5. **Keep inventory files version controlled**
6. **Document your inventory structure**
7. **Test connectivity before running playbooks**
8. **Use Ansible Vault for sensitive data**
9. **Follow consistent naming conventions**
10. **Regularly review and update inventory files**

## Example Templates

### Basic Web Application Stack

```ini
# Web Application Infrastructure
[loadbalancers]
lb1 ansible_host=192.168.1.5 ansible_user=ubuntu

[webservers]
web1 ansible_host=192.168.1.10 ansible_user=ubuntu
web2 ansible_host=192.168.1.11 ansible_user=ubuntu

[appservers]
app1 ansible_host=192.168.1.20 ansible_user=ubuntu
app2 ansible_host=192.168.1.21 ansible_user=ubuntu

[databases]
db1 ansible_host=192.168.1.30 ansible_user=postgres

[monitoring]
monitor1 ansible_host=192.168.1.40 ansible_user=ubuntu

# Group variables
[webservers:vars]
http_port=80
https_port=443

[appservers:vars]
app_port=8080
java_version=11

[databases:vars]
db_port=5432
max_connections=100

# Global variables
[all:vars]
ansible_ssh_private_key_file=~/.ssh/app_key
ansible_become=yes
ntp_server=pool.ntp.org
```

This comprehensive guide provides all the essential information needed to create and manage Ansible inventory files effectively for both Linux and Windows environments.