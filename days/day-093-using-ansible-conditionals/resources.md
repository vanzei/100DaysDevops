# Day 093: Using Ansible Conditionals - Resources Guide

## Table of Contents
1. [Challenge Overview](#challenge-overview)
2. [Ansible Conditionals Fundamentals](#ansible-conditionals-fundamentals)
3. [Gathered Facts and Variables](#gathered-facts-and-variables)
4. [The ansible_nodename Variable](#the-ansible_nodename-variable)
5. [When Conditionals Deep Dive](#when-conditionals-deep-dive)
6. [Variable Access Patterns](#variable-access-patterns)
7. [Production Best Practices](#production-best-practices)
8. [Advanced Conditional Examples](#advanced-conditional-examples)
9. [Troubleshooting Guide](#troubleshooting-guide)

## Challenge Overview

### Core Requirements
- **Target**: All app servers (stapp01, stapp02, stapp03)
- **Conditional Logic**: Use `when` statements with `ansible_nodename`
- **File Operations**: Copy different files to different servers based on conditions
- **Permissions**: Set 0777 permissions and appropriate ownership

### Key Learning Objectives
1. Understanding Ansible's `when` conditionals
2. Accessing variables from gathered facts
3. Using `ansible_nodename` for server identification
4. Implementing conditional file operations

## Ansible Conditionals Fundamentals

### What are Ansible Conditionals?

Ansible conditionals allow you to control task execution based on specific conditions. They enable dynamic playbook behavior where tasks only run when certain criteria are met.

### Basic Syntax

```yaml
- name: Task with condition
  module_name:
    # module parameters
  when: condition_expression
```

### Common Conditional Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `==` | Equal to | `ansible_os_family == "RedHat"` |
| `!=` | Not equal to | `ansible_distribution != "Ubuntu"` |
| `in` | Contains | `"web" in group_names` |
| `not in` | Does not contain | `"db" not in group_names` |
| `is defined` | Variable exists | `custom_var is defined` |
| `is not defined` | Variable doesn't exist | `custom_var is not defined` |
| `and` | Logical AND | `condition1 and condition2` |
| `or` | Logical OR | `condition1 or condition2` |

## Gathered Facts and Variables

### What are Gathered Facts?

Gathered facts are system information automatically collected by Ansible from target hosts before executing tasks. These facts provide comprehensive details about the system's hardware, software, network configuration, and more.

### How Facts are Collected

1. **Automatic Collection**: By default, Ansible runs the `setup` module
2. **Fact Gathering Control**: Can be controlled with `gather_facts: yes/no`
3. **Custom Facts**: Can be extended with custom fact modules

### Example Fact Collection Process

```yaml
- name: Example playbook with fact gathering
  hosts: all
  gather_facts: yes  # This triggers fact collection
  
  tasks:
    - name: Display gathered facts
      debug:
        var: ansible_facts
```

### Categories of Gathered Facts

#### **1. System Information**
- `ansible_nodename`: Fully qualified domain name
- `ansible_hostname`: Short hostname
- `ansible_fqdn`: Fully qualified domain name
- `ansible_domain`: Domain name
- `ansible_machine`: Hardware architecture

#### **2. Operating System Facts**
- `ansible_os_family`: OS family (RedHat, Debian, etc.)
- `ansible_distribution`: Specific distribution (CentOS, Ubuntu, etc.)
- `ansible_distribution_version`: OS version
- `ansible_kernel`: Kernel version

#### **3. Hardware Facts**
- `ansible_processor`: CPU information
- `ansible_processor_cores`: Number of CPU cores
- `ansible_memtotal_mb`: Total memory in MB
- `ansible_devices`: Storage devices

#### **4. Network Facts**
- `ansible_default_ipv4`: Default IPv4 configuration
- `ansible_all_ipv4_addresses`: All IPv4 addresses
- `ansible_interfaces`: Network interfaces

## The ansible_nodename Variable

### Definition and Purpose

The `ansible_nodename` variable contains the fully qualified domain name (FQDN) of the target host as reported by the system itself.

### How It's Populated

```bash
# On the target system, this command populates ansible_nodename:
hostname --fqdn
# or
uname -n
```

### Expected Values in KodeKloud Environment

Based on the standard KodeKloud setup:

```yaml
# App Server 1
ansible_nodename: "stapp01.stratos.xfusioncorp.com"

# App Server 2  
ansible_nodename: "stapp02.stratos.xfusioncorp.com"

# App Server 3
ansible_nodename: "stapp03.stratos.xfusioncorp.com"
```

### Accessing ansible_nodename

```yaml
# Direct access in when condition
when: ansible_nodename == "stapp01.stratos.xfusioncorp.com"

# Using in templates or debug
debug:
  msg: "Current node: {{ ansible_nodename }}"

# String matching
when: "'stapp01' in ansible_nodename"

# Pattern matching  
when: ansible_nodename | regex_match('stapp0[1-3]\..*')
```

## When Conditionals Deep Dive

### Basic When Conditions

```yaml
# Simple equality check
- name: Task for specific host
  debug:
    msg: "This is App Server 1"
  when: ansible_nodename == "stapp01.stratos.xfusioncorp.com"

# Multiple conditions with AND
- name: Task with multiple conditions
  debug:
    msg: "RedHat family on App Server 1"
  when: 
    - ansible_os_family == "RedHat"
    - ansible_nodename == "stapp01.stratos.xfusioncorp.com"

# Multiple conditions with OR
- name: Task for App Server 1 or 2
  debug:
    msg: "This runs on App Server 1 or 2"
  when: >
    ansible_nodename == "stapp01.stratos.xfusioncorp.com" or 
    ansible_nodename == "stapp02.stratos.xfusioncorp.com"
```

### Advanced When Conditions

```yaml
# Using in operator
- name: Task for multiple servers
  debug:
    msg: "This runs on selected servers"
  when: ansible_nodename in ['stapp01.stratos.xfusioncorp.com', 'stapp02.stratos.xfusioncorp.com']

# Regular expressions
- name: Pattern matching
  debug:
    msg: "This matches app servers"
  when: ansible_nodename | regex_match('stapp0[1-3]\.stratos\.xfusioncorp\.com')

# Variable existence check
- name: Task when variable exists
  debug:
    msg: "Custom variable is defined"
  when: custom_variable is defined

# Complex boolean logic
- name: Complex condition
  debug:
    msg: "Complex condition met"
  when: >
    (ansible_nodename == "stapp01.stratos.xfusioncorp.com" and ansible_os_family == "RedHat") or
    (ansible_nodename == "stapp02.stratos.xfusioncorp.com" and ansible_memtotal_mb > 1000)
```

## Variable Access Patterns

### Direct Variable Access

```yaml
# Accessing gathered facts directly
- debug:
    msg: "Hostname: {{ ansible_hostname }}"
    
- debug:
    msg: "FQDN: {{ ansible_fqdn }}"
    
- debug:
    msg: "Node name: {{ ansible_nodename }}"
```

### Using Variables in When Conditions

```yaml
# Direct comparison
when: ansible_hostname == "stapp01"

# String operations
when: ansible_nodename.startswith('stapp01')

# List operations
when: ansible_hostname in ['stapp01', 'stapp02']

# Dictionary access
when: ansible_default_ipv4.address == "172.16.238.10"
```

### Variable Debugging and Inspection

```yaml
# Display all facts
- name: Show all gathered facts
  debug:
    var: ansible_facts

# Display specific fact categories
- name: Show system facts
  debug:
    var: ansible_system

# Filter facts
- name: Show facts matching pattern
  debug:
    msg: "{{ item }}: {{ vars[item] }}"
  loop: "{{ vars.keys() | select('match', 'ansible_.*') | list }}"
  when: vars[item] is defined
```

## Production Best Practices

### 1. Fact Gathering Optimization

```yaml
# Selective fact gathering for performance
- name: Optimized playbook
  hosts: all
  gather_facts: yes
  gather_subset:
    - '!all'
    - '!min'
    - 'network'
    - 'hardware'
```

### 2. Error Handling with Conditionals

```yaml
# Safe variable access
- name: Safe task execution
  copy:
    src: "{{ source_file }}"
    dest: "{{ dest_file }}"
  when: 
    - source_file is defined
    - dest_file is defined
    - ansible_nodename is defined
```

### 3. Default Values and Fallbacks

```yaml
# Using default values
- name: Task with defaults
  copy:
    src: "{{ source_file | default('/default/source.txt') }}"
    dest: "/opt/{{ dest_dir | default('default') }}/file.txt"
  when: ansible_nodename == target_server | default('stapp01.stratos.xfusioncorp.com')
```

### 4. Modular Conditional Logic

```yaml
# Define conditions as variables
vars:
  is_app_server_1: "{{ ansible_nodename == 'stapp01.stratos.xfusioncorp.com' }}"
  is_app_server_2: "{{ ansible_nodename == 'stapp02.stratos.xfusioncorp.com' }}"
  is_app_server_3: "{{ ansible_nodename == 'stapp03.stratos.xfusioncorp.com' }}"

tasks:
  - name: Task for App Server 1
    debug:
      msg: "This is App Server 1"
    when: is_app_server_1
```

## Advanced Conditional Examples

### 1. Dynamic File Operations

```yaml
# Challenge 93 implementation with enhanced logic
- name: Advanced file copying with conditionals
  copy:
    src: "/usr/src/itadmin/{{ file_mapping[ansible_nodename].file }}"
    dest: "/opt/itadmin/{{ file_mapping[ansible_nodename].file }}"
    owner: "{{ file_mapping[ansible_nodename].owner }}"
    group: "{{ file_mapping[ansible_nodename].group }}"
    mode: "{{ file_mapping[ansible_nodename].mode }}"
  vars:
    file_mapping:
      "stapp01.stratos.xfusioncorp.com":
        file: "blog.txt"
        owner: "tony"
        group: "tony"
        mode: "0777"
      "stapp02.stratos.xfusioncorp.com":
        file: "story.txt"
        owner: "steve"
        group: "steve"
        mode: "0777"
      "stapp03.stratos.xfusioncorp.com":
        file: "media.txt"
        owner: "banner"
        group: "banner"
        mode: "0777"
  when: ansible_nodename in file_mapping
```

### 2. Environment-Based Conditionals

```yaml
# Different configurations per environment
- name: Environment-specific configuration
  template:
    src: "{{ app_config[environment][ansible_nodename].template }}"
    dest: "/etc/app/config.yml"
  vars:
    environment: "{{ env | default('production') }}"
    app_config:
      production:
        "stapp01.stratos.xfusioncorp.com":
          template: "prod-web-config.yml.j2"
        "stapp02.stratos.xfusioncorp.com":
          template: "prod-api-config.yml.j2"
      staging:
        "stapp01.stratos.xfusioncorp.com":
          template: "stage-web-config.yml.j2"
  when: 
    - environment in app_config
    - ansible_nodename in app_config[environment]
```

### 3. Service Management with Conditionals

```yaml
# Service management based on server role
- name: Start services based on server type
  systemd:
    name: "{{ item }}"
    state: started
    enabled: yes
  loop: "{{ services_by_server[ansible_nodename] | default([]) }}"
  vars:
    services_by_server:
      "stapp01.stratos.xfusioncorp.com": ["httpd", "php-fpm"]
      "stapp02.stratos.xfusioncorp.com": ["nginx", "nodejs"]
      "stapp03.stratos.xfusioncorp.com": ["mysql", "redis"]
  when: services_by_server[ansible_nodename] is defined
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. ansible_nodename Not Matching Expected Value

**Problem:**
```yaml
when: ansible_nodename == "stapp01"
# Fails because actual value is "stapp01.stratos.xfusioncorp.com"
```

**Solution:**
```yaml
# Debug to see actual value
- debug:
    var: ansible_nodename

# Use correct full FQDN
when: ansible_nodename == "stapp01.stratos.xfusioncorp.com"

# Or use pattern matching
when: "'stapp01' in ansible_nodename"
```

#### 2. Facts Not Available

**Problem:**
```yaml
gather_facts: no
# ansible_nodename will be undefined
```

**Solution:**
```yaml
gather_facts: yes  # Ensure fact gathering is enabled

# Or manually gather facts
- name: Gather facts manually
  setup:
```

#### 3. Conditional Logic Errors

**Problem:**
```yaml
when: ansible_nodename = "stapp01"  # Single = instead of ==
```

**Solution:**
```yaml
when: ansible_nodename == "stapp01"  # Use == for comparison
```

#### 4. Complex Condition Parsing

**Problem:**
```yaml
when: condition1 and condition2 or condition3  # Ambiguous precedence
```

**Solution:**
```yaml
when: (condition1 and condition2) or condition3  # Use parentheses
# or
when:
  - condition1
  - condition2 or condition3  # List format for AND
```

### Debugging Techniques

#### 1. Fact Inspection

```yaml
# Display all node-related facts
- name: Debug node information
  debug:
    msg: |
      Nodename: {{ ansible_nodename }}
      Hostname: {{ ansible_hostname }}
      FQDN: {{ ansible_fqdn }}
      Domain: {{ ansible_domain | default('not set') }}

# Check if variable exists
- name: Check variable existence
  debug:
    msg: "ansible_nodename is {{ 'defined' if ansible_nodename is defined else 'not defined' }}"
```

#### 2. Condition Testing

```yaml
# Test conditions before using them
- name: Test condition
  debug:
    msg: "Condition result: {{ ansible_nodename == 'stapp01.stratos.xfusioncorp.com' }}"

- name: Show matched servers
  debug:
    msg: "This server matches condition"
  when: ansible_nodename == 'stapp01.stratos.xfusioncorp.com'
```

#### 3. Variable Exploration

```yaml
# Find all variables containing 'node'
- name: Find node-related variables
  debug:
    msg: "{{ item }}"
  loop: "{{ vars.keys() | select('search', 'node') | list }}"
```

## Challenge 93 Specific Implementation

### Key Variables Used

1. **ansible_nodename**: Primary conditional variable
   - **Source**: System hostname (FQDN)
   - **Access**: Direct variable access from gathered facts
   - **Usage**: `when: ansible_nodename == "stapp01.stratos.xfusioncorp.com"`

2. **File Mapping Logic**:
   ```yaml
   stapp01.stratos.xfusioncorp.com → blog.txt → tony:tony
   stapp02.stratos.xfusioncorp.com → story.txt → steve:steve  
   stapp03.stratos.xfusioncorp.com → media.txt → banner:banner
   ```

3. **Gathered Facts Process**:
   ```
   1. gather_facts: yes → Collects system information
   2. ansible_nodename populated from hostname command
   3. when conditions evaluated per host
   4. Tasks execute only on matching hosts
   ```

### Validation Commands

```bash
# Test the playbook
ansible-playbook -i inventory playbook.yml

# Check results
ansible all -i inventory -m shell -a "ls -la /opt/itadmin/" --become

# Verify conditionals worked
ansible stapp01 -i inventory -m shell -a "test -f /opt/itadmin/blog.txt && echo 'blog.txt found'" --become
ansible stapp02 -i inventory -m shell -a "test -f /opt/itadmin/story.txt && echo 'story.txt found'" --become
ansible stapp03 -i inventory -m shell -a "test -f /opt/itadmin/media.txt && echo 'media.txt found'" --become
```

This comprehensive guide explains how Ansible conditionals work, how variables are accessed from gathered facts, and specifically how `ansible_nodename` is used to implement server-specific logic in Challenge 93.