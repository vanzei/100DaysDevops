# Ansible Module Discovery Guide

## Quick Reference: Finding Module Options and Examples

### Primary Method: ansible-doc Command

```bash
# Get complete documentation for any module
ansible-doc <module_name>

# Examples for specific modules
ansible-doc copy                  # File copy operations
ansible-doc file                  # File/directory management
ansible-doc template              # Template deployment
ansible-doc service               # Service management
ansible-doc package               # Package installation
ansible-doc command               # Command execution
ansible-doc shell                 # Shell command execution
```

### Get Examples Only
```bash
# Show only examples section
ansible-doc <module_name> -e

# Examples:
ansible-doc copy -e               # Copy module examples
ansible-doc file -e               # File module examples
ansible-doc template -e           # Template module examples
```

### Module Discovery
```bash
# List all available modules
ansible-doc -l

# Search for specific functionality
ansible-doc -l | grep -i file     # File-related modules
ansible-doc -l | grep -i network  # Network modules
ansible-doc -l | grep -i service  # Service modules
ansible-doc -l | grep -i user     # User management modules
ansible-doc -l | grep -i package  # Package management modules
```

### Module Categories

#### File Operations
- `copy` - Copy files from control node to managed nodes
- `file` - Manage files and directories
- `template` - Deploy Jinja2 templates
- `fetch` - Copy files from managed nodes to control node
- `synchronize` - Sync directories using rsync
- `unarchive` - Extract archives
- `archive` - Create archives

#### System Management
- `command` - Execute commands
- `shell` - Execute shell commands with full shell features
- `service` - Manage services (generic)
- `systemd` - Manage systemd services
- `cron` - Manage cron jobs
- `mount` - Manage filesystem mounts

#### Package Management
- `package` - Generic package manager
- `yum` - RHEL/CentOS package manager
- `apt` - Debian/Ubuntu package manager
- `pip` - Python package manager
- `npm` - Node.js package manager

#### User Management
- `user` - Manage user accounts
- `group` - Manage groups
- `authorized_key` - Manage SSH authorized keys

#### Network Operations
- `uri` - Interact with web services
- `get_url` - Download files from URLs
- `ping` - Test connectivity to nodes

### Understanding Module Parameters

When you run `ansible-doc <module>`, look for these sections:

1. **PARAMETERS** - All available options
   - **Required parameters** are marked clearly
   - **Default values** are shown in parentheses
   - **Parameter types** (string, boolean, list, dict)

2. **EXAMPLES** - Practical usage examples
   - Basic usage patterns
   - Advanced configurations
   - Common use cases

3. **RETURN VALUES** - What the module returns
   - Success/failure indicators
   - Changed status
   - Module-specific return data

### Quick Parameter Reference for Common Modules

#### copy Module
```yaml
copy:
  src: /path/to/source        # Required: source file
  dest: /path/to/destination  # Required: destination path
  mode: '0644'               # Optional: file permissions
  owner: user                # Optional: file owner
  group: group               # Optional: file group
  backup: yes                # Optional: backup existing file
  force: yes                 # Optional: overwrite existing
```

#### file Module
```yaml
file:
  path: /path/to/file        # Required: file/directory path
  state: directory           # Required: directory/file/touch/absent
  mode: '0755'              # Optional: permissions
  owner: user               # Optional: owner
  group: group              # Optional: group
  recurse: yes              # Optional: apply recursively
```

#### service Module
```yaml
service:
  name: httpd               # Required: service name
  state: started            # Required: started/stopped/restarted
  enabled: yes              # Optional: enable at boot
```

### Testing Module Syntax

```bash
# Check playbook syntax
ansible-playbook --syntax-check playbook.yml

# Test specific modules with ad-hoc commands
ansible -i inventory all -m ping
ansible -i inventory all -m setup
ansible -i inventory all -m command -a "uptime"
```

### Best Practices for Module Discovery

1. **Start with ansible-doc**: Always check official documentation first
2. **Use examples**: Copy and modify existing examples
3. **Test incrementally**: Start simple, add complexity gradually
4. **Check return values**: Understand what the module provides back
5. **Validate syntax**: Use --syntax-check before running playbooks

### Common Module Patterns

#### Idempotency Check
Most Ansible modules are idempotent (safe to run multiple times):
```yaml
- name: Ensure directory exists
  file:
    path: /opt/data
    state: directory
    mode: '0755'
```

#### Error Handling
```yaml
- name: Copy file with error handling
  copy:
    src: /source/file
    dest: /dest/file
  ignore_errors: yes
  register: copy_result

- name: Debug copy result
  debug:
    var: copy_result
```

#### Conditional Execution
```yaml
- name: Copy file only if source exists
  copy:
    src: /source/file
    dest: /dest/file
  when: ansible_os_family == "RedHat"
```

This guide gives you all the tools you need to discover and understand any Ansible module!