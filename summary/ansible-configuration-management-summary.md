# Ansible Configuration Management - 100 Days DevOps Challenge

## Overview

Ansible configuration management was covered in Days 83-93 of the challenge, focusing on infrastructure as code, automated configuration, and multi-environment deployments. This module emphasized declarative infrastructure management and automation at scale.

## What We Practiced

### Ansible Fundamentals
- **Ansible installation** and configuration
- **Inventory management** for target hosts
- **Ad-hoc commands** for quick operations
- **Playbook development** and execution

### Infrastructure Automation
- **Role-based architecture** for reusable components
- **Variable management** and templating
- **Handler system** for service management
- **Facts gathering** and dynamic configuration

### Advanced Features
- **Vault** for secrets management
- **Galaxy** for role sharing and discovery
- **Tower/AWX** for enterprise features
- **Custom modules** and plugins development

## Key Commands Practiced

### Ansible Installation & Setup
```bash
# Install Ansible on control node
sudo yum install python3 python3-pip
pip3 install ansible

# Verify installation
ansible --version

# Configure SSH key authentication
ssh-keygen -t rsa -b 4096
ssh-copy-id user@target-server

# Test connectivity
ansible -i inventory.ini all -m ping
```

### Inventory Management
```ini
# /etc/ansible/hosts or custom inventory file
[webservers]
web01 ansible_host=192.168.1.10 ansible_user=centos
web02 ansible_host=192.168.1.11 ansible_user=centos

[databases]
db01 ansible_host=192.168.1.20 ansible_user=centos

[loadbalancers]
lb01 ansible_host=192.168.1.30 ansible_user=centos

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Ad-hoc Commands
```bash
# Ping all hosts
ansible all -i inventory.ini -m ping

# Check disk usage
ansible webservers -m shell -a "df -h"

# Install package
ansible webservers -m yum -a "name=httpd state=present"

# Copy file
ansible webservers -m copy -a "src=/local/file dest=/remote/file"

# Execute command with sudo
ansible webservers -m shell -a "systemctl start httpd" --become

# Gather facts
ansible webservers -m setup
```

### Playbook Execution
```bash
# Run playbook
ansible-playbook -i inventory.ini playbook.yml

# Run with extra variables
ansible-playbook -i inventory.ini -e "env=production" playbook.yml

# Check syntax
ansible-playbook --syntax-check playbook.yml

# Dry run
ansible-playbook --check playbook.yml

# Run on specific hosts
ansible-playbook -i inventory.ini -l webservers playbook.yml

# Verbose output
ansible-playbook -v playbook.yml
```

## Technical Topics Covered

### Ansible Architecture
```text
Control Node (Ansible Server)
├── Ansible Core
├── Modules & Plugins
├── Playbooks & Roles
└── Inventory & Variables

Managed Nodes (Targets)
├── SSH/Python Connection
├── Facts Collection
├── Task Execution
└── State Management

External Systems
├── Version Control (Git)
├── Artifact Repositories
├── Cloud Providers (AWS, Azure)
└── CMDB Systems
```

### Playbook Structure
```yaml
---
# Sample playbook structure
- name: Configure web servers
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    max_clients: 200

  pre_tasks:
    - name: Update package cache
      yum:
        name: '*'
        state: latest
        update_cache: yes

  roles:
    - common
    - webserver

  tasks:
    - name: Install Apache
      yum:
        name: httpd
        state: present

    - name: Configure Apache
      template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: restart apache

    - name: Start Apache service
      service:
        name: httpd
        state: started
        enabled: yes

  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted

  post_tasks:
    - name: Verify web service
      uri:
        url: http://localhost
        return_content: yes
      register: webpage

    - name: Print web content
      debug:
        msg: "{{ webpage.content }}"
```

### Role Structure
```text
webserver/
├── defaults/
│   └── main.yml          # Default variables
├── files/
│   └── index.html        # Static files
├── handlers/
│   └── main.yml          # Service handlers
├── meta/
│   └── main.yml          # Role metadata
├── tasks/
│   └── main.yml          # Main tasks
├── templates/
│   └── httpd.conf.j2     # Jinja2 templates
└── vars/
    └── main.yml          # Role variables
```

### Variable Precedence
```text
Command Line Values (highest priority)
├── -e variables
└── --extra-vars

Role Defaults (role/defaults/main.yml)

Inventory Variables
├── Group variables (group_vars/)
└── Host variables (host_vars/)

Playbook Variables
├── vars: section
└── vars_files:

Role Variables (role/vars/main.yml)

Facts (lowest priority)
└── Ansible gathered facts
```

## Production Environment Considerations

### Security & Compliance
- **SSH hardening**: Key-based authentication, no password auth
- **Vault encryption**: Sensitive data protection
- **RBAC**: Access controls and privilege escalation
- **Audit logging**: Compliance and change tracking

### Scalability & Performance
- **Parallel execution**: Concurrent task processing
- **Asynchronous tasks**: Long-running operation handling
- **Fact caching**: Performance optimization
- **Dynamic inventory**: Cloud and container environments

### Reliability & Error Handling
- **Idempotency**: Safe repeated execution
- **Error handling**: Failure recovery and rollback
- **Validation**: Pre-flight checks and assertions
- **Testing**: Molecule for role testing

### Integration & Ecosystem
- **CI/CD integration**: Automated deployment pipelines
- **Cloud providers**: AWS, Azure, GCP modules
- **Monitoring**: Integration with monitoring systems
- **Documentation**: Automated documentation generation

## Real-World Applications

### Complete Infrastructure Setup
```yaml
# site.yml - Main playbook
---
- name: Configure infrastructure
  hosts: all
  become: yes

  pre_tasks:
    - name: Update system
      package:
        name: '*'
        state: latest

  roles:
    - { role: common, tags: ['common'] }
    - { role: security, tags: ['security'] }

- name: Configure web tier
  hosts: webservers
  become: yes
  roles:
    - { role: nginx, tags: ['web', 'nginx'] }
    - { role: php, tags: ['web', 'php'] }
    - { role: app, tags: ['web', 'app'] }

- name: Configure database tier
  hosts: databases
  become: yes
  roles:
    - { role: postgresql, tags: ['db', 'postgresql'] }

- name: Configure load balancers
  hosts: loadbalancers
  become: yes
  roles:
    - { role: haproxy, tags: ['lb', 'haproxy'] }
```

### Dynamic Inventory with AWS
```python
# aws_ec2.yml - Dynamic inventory
plugin: aws_ec2
regions:
  - us-east-1
filters:
  tag:Environment: production
  instance-state-name: running
keyed_groups:
  - key: tags.Role
    prefix: role
  - key: tags.Environment
    prefix: env
hostnames:
  - tag:Name
  - private-ip-address
compose:
  ansible_host: private_ip_address
  ansible_user: ec2-user
```

### Encrypted Secrets with Vault
```bash
# Create encrypted file
ansible-vault create secrets.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Encrypt existing file
ansible-vault encrypt secrets.yml

# Decrypt file
ansible-vault decrypt secrets.yml

# View encrypted file
ansible-vault view secrets.yml
```

```yaml
# secrets.yml (encrypted)
---
db_password: "supersecretpassword"
api_key: "my-api-key"
ssl_cert: |
  -----BEGIN CERTIFICATE-----
  MIICiTCCAg+gAwIBAgIJAJ8l4HnPq7F...
  -----END CERTIFICATE-----
ssl_key: |
  -----BEGIN PRIVATE KEY-----
  MIGHAgEAMBMGByqGSM49AgEGCCqGSM49...
  -----END PRIVATE KEY-----
```

### Jinja2 Templating
```jinja2
# templates/nginx.conf.j2
server {
    listen {{ http_port | default(80) }};
    server_name {{ server_name | default('localhost') }};

    location / {
        proxy_pass http://{{ upstream_servers | join(',') }};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    {% if ssl_enabled | default(false) %}
    listen 443 ssl;
    ssl_certificate {{ ssl_cert_path }};
    ssl_certificate_key {{ ssl_key_path }};
    {% endif %}

    {% for location in additional_locations | default([]) %}
    location {{ location.path }} {
        {{ location.config | indent(8) }}
    }
    {% endfor %}
}
```

### Custom Facts
```python
# custom_facts.py
#!/usr/bin/env python3

import json
import subprocess

def get_system_info():
    """Gather custom system information"""
    facts = {}

    # Get package manager
    try:
        result = subprocess.run(['which', 'yum'], capture_output=True, text=True)
        facts['package_manager'] = 'yum' if result.returncode == 0 else 'unknown'
    except:
        facts['package_manager'] = 'unknown'

    # Get disk usage
    try:
        result = subprocess.run(['df', '-h', '/'], capture_output=True, text=True)
        lines = result.stdout.strip().split('\n')
        if len(lines) > 1:
            fields = lines[1].split()
            facts['root_disk_usage'] = fields[4]  # Use percentage
    except:
        facts['root_disk_usage'] = 'unknown'

    return facts

if __name__ == '__main__':
    facts = get_system_info()
    print(json.dumps(facts, indent=2))
```

### Molecule Testing
```yaml
# molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance
    image: centos:7
    pre_build_image: true
provisioner:
  name: ansible
  playbooks:
    converge: ../playbook.yml
  inventory:
    group_vars:
      all:
        ansible_user: ansible
        ansible_connection: docker
verifier:
  name: ansible
```

## Troubleshooting Common Issues

### Connection Issues
```bash
# Test SSH connectivity
ssh -i ~/.ssh/id_rsa user@target-server

# Check Ansible connectivity
ansible -i inventory.ini target-server -m ping -vvv

# Debug connection
ansible -i inventory.ini target-server -m setup -vvv
```

### Playbook Failures
```bash
# Check syntax
ansible-playbook --syntax-check playbook.yml

# Dry run
ansible-playbook --check playbook.yml

# Run with maximum verbosity
ansible-playbook -vvvv playbook.yml

# Run specific task
ansible-playbook --start-at-task="Install Apache" playbook.yml
```

### Variable Issues
```bash
# Debug variables
ansible-playbook -e "debug=yes" playbook.yml

# Print variables during execution
- debug:
    var: my_variable

# Check variable precedence
ansible-inventory --list -i inventory.ini
```

### Performance Issues
```bash
# Limit parallel execution
ansible-playbook -f 5 playbook.yml

# Use async for long-running tasks
- name: Long running task
  command: sleep 300
  async: 600
  poll: 10

# Enable fact caching
[defaults]
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
```

## Key Takeaways

1. **Idempotency**: Playbooks should be safe to run multiple times
2. **Declarative**: Define desired state, not procedural steps
3. **Modular**: Use roles for reusable, maintainable code
4. **Secure**: Encrypt secrets and use least privilege
5. **Testable**: Validate playbooks with testing frameworks

## Next Steps

- **AWX/Tower**: Web-based Ansible management
- **Ansible Automation Platform**: Enterprise features
- **Infrastructure as Code**: Terraform integration
- **GitOps**: Ansible with Git workflows
- **Custom Modules**: Extend Ansible capabilities

Ansible has revolutionized infrastructure automation, enabling teams to manage complex environments with code, ensuring consistency, reliability, and scalability across all infrastructure components.