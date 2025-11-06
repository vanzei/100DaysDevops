# Ansible Playbooks Resources Guide

## Overview
This guide provides comprehensive information about Ansible playbooks, covering structure, syntax, best practices, and production-ready configurations for enterprise environments.

## What is an Ansible Playbook

An Ansible playbook is a YAML file that defines a series of tasks to be executed on target hosts. Playbooks are the heart of Ansible automation, describing the desired state of your systems and the steps needed to achieve that state.

### Key Characteristics
- **Declarative**: Describe what you want, not how to achieve it
- **Idempotent**: Can be run multiple times safely
- **YAML Format**: Human-readable and version-controllable
- **Modular**: Can include other playbooks and roles
- **Flexible**: Support variables, conditionals, and loops

## Playbook Structure and Anatomy

### Basic Playbook Structure

```yaml
---
# Playbook header
- name: Description of what this playbook does
  hosts: target_hosts_or_groups
  become: yes
  vars:
    variable_name: value
  
  tasks:
    - name: Task description
      module_name:
        parameter: value
      
    - name: Another task
      module_name:
        parameter1: value1
        parameter2: value2
```

### Essential Components

#### 1. Document Header
```yaml
---
# Always start with three dashes
# This indicates the beginning of a YAML document
```

#### 2. Play Definition
```yaml
- name: "Descriptive name for the play"
  hosts: target_hosts
  # Play-level configurations
```

#### 3. Play-Level Directives
- **hosts**: Target hosts or groups
- **become**: Privilege escalation
- **vars**: Play-specific variables
- **gather_facts**: Whether to collect system facts
- **remote_user**: SSH user for connections
- **connection**: Connection type (ssh, local, winrm)

#### 4. Tasks Section
```yaml
tasks:
  - name: "Clear task description"
    module_name:
      parameter: value
    # Task-level configurations
```

## YAML Syntax Fundamentals

### Basic YAML Rules
1. **Indentation**: Use spaces (2 or 4), never tabs
2. **Case Sensitivity**: YAML is case-sensitive
3. **Data Types**: Strings, numbers, booleans, lists, dictionaries
4. **Comments**: Use `#` for comments
5. **Document Separator**: `---` starts a document

### YAML Data Structures

#### Scalars (Simple Values)
```yaml
# Strings
string_var: "Hello World"
unquoted_string: Hello World
multiline_string: |
  This is a multiline
  string that preserves
  line breaks

# Numbers
integer_var: 42
float_var: 3.14

# Booleans
boolean_true: true
boolean_false: false
boolean_yes: yes
boolean_no: no
```

#### Lists (Arrays)
```yaml
# List format 1 (preferred)
packages:
  - nginx
  - mysql
  - php

# List format 2 (inline)
packages: ['nginx', 'mysql', 'php']
```

#### Dictionaries (Key-Value Pairs)
```yaml
# Dictionary format 1 (preferred)
user:
  name: john
  uid: 1001
  shell: /bin/bash

# Dictionary format 2 (inline)
user: {name: john, uid: 1001, shell: /bin/bash}
```

## Core Ansible Modules

### File and Directory Operations

#### file Module
```yaml
- name: Create a directory
  file:
    path: /opt/myapp
    state: directory
    mode: '0755'
    owner: root
    group: root

- name: Create an empty file
  file:
    path: /tmp/myfile.txt
    state: touch
    mode: '0644'

- name: Remove a file
  file:
    path: /tmp/unwanted.txt
    state: absent
```

#### copy Module
```yaml
- name: Copy file from control node
  copy:
    src: /local/path/file.txt
    dest: /remote/path/file.txt
    owner: root
    group: root
    mode: '0644'
    backup: yes

- name: Create file with content
  copy:
    content: |
      This is the content
      of the file
    dest: /tmp/content.txt
```

#### template Module
```yaml
- name: Deploy configuration from template
  template:
    src: config.j2
    dest: /etc/myapp/config.conf
    owner: root
    group: root
    mode: '0644'
    backup: yes
  notify: restart myapp
```

### Package Management

#### package Module (Generic)
```yaml
- name: Install packages (generic)
  package:
    name:
      - git
      - curl
      - vim
    state: present
```

#### yum Module (RHEL/CentOS)
```yaml
- name: Install packages with yum
  yum:
    name:
      - httpd
      - mysql-server
    state: present
    update_cache: yes

- name: Install specific version
  yum:
    name: httpd-2.4.6
    state: present
```

#### apt Module (Debian/Ubuntu)
```yaml
- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Install packages with apt
  apt:
    name:
      - nginx
      - mysql-server
    state: present
```

### Service Management

#### service Module
```yaml
- name: Start and enable service
  service:
    name: nginx
    state: started
    enabled: yes

- name: Restart service
  service:
    name: httpd
    state: restarted

- name: Stop service
  service:
    name: unwanted-service
    state: stopped
    enabled: no
```

#### systemd Module
```yaml
- name: Start service with systemd
  systemd:
    name: nginx
    state: started
    enabled: yes
    daemon_reload: yes

- name: Reload systemd and restart service
  systemd:
    name: myapp.service
    state: restarted
    daemon_reload: yes
    scope: user
```

### Command Execution

#### command Module
```yaml
- name: Run a simple command
  command: whoami
  register: command_result

- name: Run command with arguments
  command: /usr/bin/make install
  args:
    chdir: /opt/myapp
    creates: /opt/myapp/installed
```

#### shell Module
```yaml
- name: Run shell command with pipes
  shell: ps aux | grep nginx | wc -l
  register: nginx_processes

- name: Run complex shell command
  shell: |
    if [ ! -f /tmp/flag ]; then
      echo "First run" > /tmp/flag
      exit 0
    fi
```

#### script Module
```yaml
- name: Run script on remote host
  script: /local/path/setup.sh
  args:
    creates: /opt/app/installed
```

## Variables and Facts

### Variable Types

#### Play Variables
```yaml
---
- name: Example playbook with variables
  hosts: webservers
  vars:
    http_port: 80
    https_port: 443
    server_name: example.com
  
  tasks:
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
```

#### Host Variables
```yaml
# In inventory file
[webservers]
web1 ansible_host=192.168.1.10 http_port=8080
web2 ansible_host=192.168.1.11 http_port=8081
```

#### Group Variables
```yaml
# In group_vars/webservers.yml
http_port: 80
https_port: 443
ssl_certificate: /etc/ssl/certs/server.crt
```

#### Variable Files
```yaml
---
- name: Load variables from file
  hosts: all
  vars_files:
    - vars/common.yml
    - vars/{{ ansible_os_family }}.yml
```

### Facts (System Information)
```yaml
- name: Display system facts
  debug:
    msg: |
      OS: {{ ansible_os_family }}
      Distribution: {{ ansible_distribution }}
      Version: {{ ansible_distribution_version }}
      Architecture: {{ ansible_architecture }}
      Hostname: {{ ansible_hostname }}
      IP Address: {{ ansible_default_ipv4.address }}
```

### Variable Precedence (Highest to Lowest)
1. Extra vars (`-e` command line)
2. Task vars
3. Block vars
4. Role and include vars
5. Play vars_files
6. Play vars_prompt
7. Play vars
8. Set_facts
9. Host facts
10. Playbook host_vars
11. Playbook group_vars
12. Inventory host_vars
13. Inventory group_vars
14. Inventory vars
15. Role defaults

## Conditionals and Control Structures

### When Conditionals
```yaml
- name: Install package on RedHat family
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"

- name: Install package on Debian family
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"

- name: Complex conditional
  service:
    name: firewalld
    state: started
  when: 
    - ansible_os_family == "RedHat"
    - ansible_distribution_major_version|int >= 7
```

### Loops
```yaml
# Simple loop
- name: Install multiple packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - vim
    - curl

# Loop with dictionaries
- name: Create multiple users
  user:
    name: "{{ item.name }}"
    uid: "{{ item.uid }}"
    shell: "{{ item.shell }}"
  loop:
    - { name: alice, uid: 1001, shell: /bin/bash }
    - { name: bob, uid: 1002, shell: /bin/zsh }

# Loop with register
- name: Check service status
  service:
    name: "{{ item }}"
  register: service_status
  loop:
    - nginx
    - mysql
    - redis
```

### Blocks and Error Handling
```yaml
- name: Handle errors with blocks
  block:
    - name: Attempt risky task
      command: /bin/risky-command
      
    - name: Another task in block
      file:
        path: /tmp/success
        state: touch
        
  rescue:
    - name: Handle failure
      debug:
        msg: "The risky command failed, handling gracefully"
        
    - name: Create failure indicator
      file:
        path: /tmp/failure
        state: touch
        
  always:
    - name: Always run this
      debug:
        msg: "This runs regardless of success or failure"
```

## Handlers and Notifications

### Basic Handlers
```yaml
---
- name: Web server configuration
  hosts: webservers
  
  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present
      notify: start nginx
      
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify:
        - restart nginx
        - reload nginx
  
  handlers:
    - name: start nginx
      service:
        name: nginx
        state: started
        
    - name: restart nginx
      service:
        name: nginx
        state: restarted
        
    - name: reload nginx
      service:
        name: nginx
        state: reloaded
```

### Handler Best Practices
```yaml
# Use listen for grouping handlers
handlers:
  - name: restart web services
    service:
      name: "{{ item }}"
      state: restarted
    loop:
      - nginx
      - php-fpm
    listen: "restart web stack"

# In tasks, notify the listener
tasks:
  - name: Update web configuration
    template:
      src: config.j2
      dest: /etc/web/config.conf
    notify: "restart web stack"
```

## Advanced Playbook Features

### Includes and Imports

#### Include Tasks
```yaml
- name: Main playbook
  hosts: all
  
  tasks:
    - name: Include common tasks
      include_tasks: tasks/common.yml
      
    - name: Include OS-specific tasks
      include_tasks: "tasks/{{ ansible_os_family }}.yml"
```

#### Import Playbooks
```yaml
---
# site.yml - Main playbook
- import_playbook: webservers.yml
- import_playbook: databases.yml
- import_playbook: monitoring.yml
```

### Tags
```yaml
- name: Configure system
  hosts: all
  
  tasks:
    - name: Install packages
      package:
        name: "{{ item }}"
        state: present
      loop:
        - git
        - vim
      tags:
        - packages
        - install
        
    - name: Configure SSH
      template:
        src: sshd_config.j2
        dest: /etc/ssh/sshd_config
      tags:
        - security
        - ssh
      notify: restart ssh
```

```bash
# Run only specific tags
ansible-playbook playbook.yml --tags "packages"
ansible-playbook playbook.yml --tags "security,ssh"

# Skip specific tags
ansible-playbook playbook.yml --skip-tags "packages"
```

### Vault Integration
```yaml
---
- name: Deploy application with secrets
  hosts: appservers
  vars_files:
    - vars/public.yml
    - vars/vault.yml  # Encrypted with ansible-vault
    
  tasks:
    - name: Configure database connection
      template:
        src: database.conf.j2
        dest: /etc/app/database.conf
      vars:
        db_password: "{{ vault_db_password }}"
```

## Production Best Practices

### 1. Project Structure
```
ansible-project/
├── inventories/
│   ├── production/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   └── staging/
│       ├── hosts.yml
│       └── group_vars/
├── roles/
│   ├── common/
│   ├── webserver/
│   └── database/
├── playbooks/
│   ├── site.yml
│   ├── webservers.yml
│   └── databases.yml
├── group_vars/
│   ├── all.yml
│   └── vault.yml
├── host_vars/
├── library/
├── filter_plugins/
├── templates/
├── files/
└── ansible.cfg
```

### 2. Configuration Management

#### ansible.cfg
```ini
[defaults]
inventory = inventories/production/hosts.yml
remote_user = ansible
host_key_checking = False
timeout = 30
retry_files_enabled = False
roles_path = roles
library = library
filter_plugins = filter_plugins
gathering = smart
fact_caching = memory
stdout_callback = yaml
bin_ansible_callbacks = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
```

### 3. Error Handling and Resilience
```yaml
- name: Resilient task execution
  block:
    - name: Attempt primary action
      uri:
        url: "{{ primary_endpoint }}"
        method: GET
      register: primary_result
      failed_when: false
      
    - name: Fallback action
      uri:
        url: "{{ fallback_endpoint }}"
        method: GET
      when: primary_result.status != 200
      
  rescue:
    - name: Log failure
      debug:
        msg: "Both primary and fallback failed"
        
    - name: Send alert
      mail:
        to: ops@company.com
        subject: "Ansible Task Failed"
        body: "Task failed on {{ inventory_hostname }}"
```

### 4. Idempotency Patterns
```yaml
# Good: Idempotent file creation
- name: Ensure configuration directory exists
  file:
    path: /etc/myapp
    state: directory
    mode: '0755'

# Good: Idempotent service management
- name: Ensure nginx is running
  service:
    name: nginx
    state: started
    enabled: yes

# Avoid: Non-idempotent commands
- name: Bad example - always creates file
  command: touch /tmp/file.txt

# Better: Use creates parameter
- name: Good example - only if file doesn't exist
  command: setup-application.sh
  args:
    creates: /opt/app/installed
```

### 5. Security Best Practices

#### Sensitive Data Management
```yaml
# Use vault for passwords
- name: Create database user
  mysql_user:
    name: "{{ app_db_user }}"
    password: "{{ vault_app_db_password }}"
    priv: "{{ app_db_name }}.*:ALL"
    
# Use no_log for sensitive tasks
- name: Configure API key
  lineinfile:
    path: /etc/app/config
    line: "api_key={{ vault_api_key }}"
  no_log: true
```

#### Privilege Management
```yaml
- name: Tasks requiring privilege escalation
  block:
    - name: Install system packages
      package:
        name: "{{ required_packages }}"
        state: present
        
    - name: Configure system service
      systemd:
        name: myapp
        enabled: yes
        daemon_reload: yes
  become: yes
  become_user: root
  
- name: User-level tasks
  block:
    - name: Configure user settings
      copy:
        src: user.conf
        dest: "{{ ansible_user_dir }}/.config/app/"
  become: no
```

### 6. Testing and Validation

#### Check Mode
```yaml
# Tasks that support check mode
- name: Install package
  package:
    name: nginx
    state: present
  check_mode: yes

# Tasks that always run in check mode
- name: Validate configuration
  command: nginx -t
  check_mode: no
  changed_when: false
```

#### Assertions
```yaml
- name: Verify system requirements
  assert:
    that:
      - ansible_memtotal_mb >= 1024
      - ansible_processor_cores >= 2
      - ansible_distribution in ['Ubuntu', 'CentOS', 'RedHat']
    fail_msg: "System does not meet minimum requirements"
    success_msg: "System requirements validated"
```

#### Health Checks
```yaml
- name: Application health check
  uri:
    url: "http://{{ inventory_hostname }}:8080/health"
    method: GET
    status_code: 200
  register: health_check
  retries: 5
  delay: 10
  until: health_check.status == 200
```

### 7. Performance Optimization

#### Parallel Execution
```yaml
---
- name: Deploy to multiple servers
  hosts: webservers
  strategy: free  # Don't wait for all hosts
  serial: 50%     # Process 50% of hosts at a time
  
  tasks:
    - name: Deploy application
      unarchive:
        src: app.tar.gz
        dest: /opt/app
```

#### Fact Gathering Control
```yaml
---
- name: Quick deployment
  hosts: all
  gather_facts: no  # Skip fact gathering for speed
  
  tasks:
    - name: Gather minimal facts
      setup:
        gather_subset: min
      when: ansible_os_family is not defined
```

### 8. Logging and Monitoring

#### Comprehensive Logging
```yaml
- name: Task with detailed logging
  command: complex-operation.sh
  register: operation_result
  failed_when: operation_result.rc != 0
  
- name: Log operation results
  debug:
    msg: |
      Operation completed:
      - Return code: {{ operation_result.rc }}
      - Duration: {{ operation_result.delta }}
      - Output: {{ operation_result.stdout }}
      - Errors: {{ operation_result.stderr }}
```

#### Metrics Collection
```yaml
- name: Collect deployment metrics
  set_fact:
    deployment_start: "{{ ansible_date_time.epoch }}"
    
# ... deployment tasks ...

- name: Log deployment completion
  debug:
    msg: "Deployment completed in {{ ansible_date_time.epoch|int - deployment_start|int }} seconds"
```

## Common Patterns and Anti-Patterns

### ✅ Good Practices

#### 1. Clear Task Names
```yaml
# Good: Descriptive task names
- name: Install nginx web server package
  package:
    name: nginx
    state: present

- name: Start and enable nginx service on boot
  service:
    name: nginx
    state: started
    enabled: yes
```

#### 2. Proper Variable Naming
```yaml
# Good: Clear, consistent variable names
vars:
  app_name: mywebapp
  app_version: 1.2.3
  app_port: 8080
  app_config_path: /etc/mywebapp
  db_host: database.internal
  db_port: 5432
```

#### 3. Environment-Specific Configuration
```yaml
# group_vars/production.yml
app_environment: production
debug_mode: false
log_level: warn

# group_vars/development.yml
app_environment: development
debug_mode: true
log_level: debug
```

### ❌ Anti-Patterns to Avoid

#### 1. Hardcoded Values
```yaml
# Bad: Hardcoded paths and values
- name: Copy config file
  copy:
    src: app.conf
    dest: /opt/myapp/config/app.conf  # Hardcoded path

# Good: Use variables
- name: Copy config file
  copy:
    src: app.conf
    dest: "{{ app_config_path }}/app.conf"
```

#### 2. Complex Shell Commands
```yaml
# Bad: Complex shell one-liner
- name: Setup application
  shell: |
    cd /opt && 
    wget http://example.com/app.tar.gz && 
    tar -xzf app.tar.gz && 
    chown -R app:app myapp

# Good: Break into multiple tasks
- name: Download application archive
  get_url:
    url: http://example.com/app.tar.gz
    dest: /opt/app.tar.gz

- name: Extract application
  unarchive:
    src: /opt/app.tar.gz
    dest: /opt
    remote_src: yes
    owner: app
    group: app
```

#### 3. Ignoring Idempotency
```yaml
# Bad: Always runs, not idempotent
- name: Add user to group
  command: usermod -aG docker myuser

# Good: Idempotent user management
- name: Add user to docker group
  user:
    name: myuser
    groups: docker
    append: yes
```

## Troubleshooting Common Issues

### 1. YAML Syntax Errors
```bash
# Validate YAML syntax
python -c "import yaml; yaml.safe_load(open('playbook.yml'))"

# Use ansible-playbook syntax check
ansible-playbook playbook.yml --syntax-check
```

### 2. Variable Issues
```yaml
# Debug variables
- name: Show all variables for host
  debug:
    var: vars
    
- name: Show specific variable
  debug:
    msg: "Database host is {{ db_host | default('not defined') }}"
```

### 3. Connection Problems
```yaml
# Test connectivity
- name: Test connection
  ping:
  
# Gather minimal facts for debugging
- name: Gather network facts
  setup:
    gather_subset: network
```

### 4. Permission Issues
```yaml
# Debug user context
- name: Show current user
  command: whoami
  register: current_user
  
- name: Show current privileges
  command: id
  register: user_id
  
- name: Display user information
  debug:
    msg: |
      Current user: {{ current_user.stdout }}
      User ID info: {{ user_id.stdout }}
```

## Playbook Templates for Common Scenarios

### 1. Basic Application Deployment
```yaml
---
- name: Deploy web application
  hosts: webservers
  become: yes
  vars:
    app_name: mywebapp
    app_version: "{{ app_version | default('latest') }}"
    app_port: 8080
    
  tasks:
    - name: Install required packages
      package:
        name:
          - python3
          - python3-pip
          - nginx
        state: present
        
    - name: Create application user
      user:
        name: "{{ app_name }}"
        system: yes
        shell: /bin/false
        home: "/opt/{{ app_name }}"
        create_home: yes
        
    - name: Deploy application
      unarchive:
        src: "{{ app_name }}-{{ app_version }}.tar.gz"
        dest: "/opt/{{ app_name }}"
        owner: "{{ app_name }}"
        group: "{{ app_name }}"
        
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/sites-available/{{ app_name }}
      notify: restart nginx
      
    - name: Enable nginx site
      file:
        src: "/etc/nginx/sites-available/{{ app_name }}"
        dest: "/etc/nginx/sites-enabled/{{ app_name }}"
        state: link
      notify: restart nginx
      
    - name: Start application service
      systemd:
        name: "{{ app_name }}"
        state: started
        enabled: yes
        
  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
```

### 2. System Hardening Playbook
```yaml
---
- name: System security hardening
  hosts: all
  become: yes
  
  tasks:
    - name: Update all packages
      package:
        name: "*"
        state: latest
      when: ansible_os_family == "RedHat"
      
    - name: Configure SSH security
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - { regexp: '^PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^X11Forwarding', line: 'X11Forwarding no' }
      notify: restart sshd
      
    - name: Configure firewall
      firewalld:
        port: "{{ item }}"
        permanent: yes
        state: enabled
        immediate: yes
      loop:
        - 22/tcp
        - 80/tcp
        - 443/tcp
      when: ansible_os_family == "RedHat"
      
  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted
```

This comprehensive guide provides everything needed to understand, create, and maintain production-ready Ansible playbooks with proper structure, security, and best practices.