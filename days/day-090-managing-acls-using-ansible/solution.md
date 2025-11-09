# Day 090: Managing ACLs Using Ansible - Solution

## Challenge Requirements
1. Create playbook.yml under `/home/thor/ansible` directory
2. Create `blog.txt` on app server 1 with group `tony` read permissions
3. Create `story.txt` on app server 2 with user `steve` read/write permissions  
4. Create `media.txt` on app server 3 with group `banner` read/write permissions
5. All files should be owned by root and located in `/opt/sysops/` directory

## Solution Implementation

### Files Created
- `inventory` - App servers configuration
- `playbook.yml` - ACL management playbook with file creation and permission setting
- `solution.md` - This solution documentation
- `resources.md` - Comprehensive ACL guide and best practices

### Inventory Configuration
```ini
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=Ir0nM@n
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=BigGr33n
```

### Playbook Structure
The playbook performs the following tasks:
1. **Install ACL utilities** - Ensures `acl` package is installed
2. **Create directory structure** - Creates `/opt/sysops` directory
3. **Create files with ACL permissions** - Server-specific file creation and ACL configuration
4. **Verification** - Displays ACL information for validation

### Server-Specific Configurations

#### App Server 1 (stapp01)
```yaml
# Create blog.txt with group tony read permissions
- name: Create blog.txt on app server 1
  file:
    path: /opt/sysops/blog.txt
    state: touch
    owner: root
    group: root
    mode: '0644'
  when: inventory_hostname == 'stapp01'
  
- name: Set ACL for group tony on blog.txt
  acl:
    path: /opt/sysops/blog.txt
    entity: tony
    etype: group
    permissions: r
    state: present
  when: inventory_hostname == 'stapp01'
```

#### App Server 2 (stapp02)
```yaml
# Create story.txt with user steve read/write permissions
- name: Create story.txt on app server 2
  file:
    path: /opt/sysops/story.txt
    state: touch
    owner: root
    group: root
    mode: '0644'
  when: inventory_hostname == 'stapp02'
  
- name: Set ACL for user steve on story.txt
  acl:
    path: /opt/sysops/story.txt
    entity: steve
    etype: user
    permissions: rw
    state: present
  when: inventory_hostname == 'stapp02'
```

#### App Server 3 (stapp03)
```yaml
# Create media.txt with group banner read/write permissions
- name: Create media.txt on app server 3
  file:
    path: /opt/sysops/media.txt
    state: touch
    owner: root
    group: root
    mode: '0644'
  when: inventory_hostname == 'stapp03'
  
- name: Set ACL for group banner on media.txt
  acl:
    path: /opt/sysops/media.txt
    entity: banner
    etype: group
    permissions: rw
    state: present
  when: inventory_hostname == 'stapp03'
```

## Execution Instructions

### Step 1: Directory Setup
```bash
# On jump host as thor user
mkdir -p /home/thor/ansible
cd /home/thor/ansible
```

### Step 2: Execute Playbook
```bash
# Run the playbook (exact validation command)
ansible-playbook -i inventory playbook.yml
```

## Expected Results

### Successful Execution Output
```
PLAY [Create files and manage ACLs on app servers] ****************************

TASK [Install ACL utilities] **************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Create /opt/sysops directory] *******************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Create blog.txt on app server 1] ***************************************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [Set ACL for group tony on blog.txt (app server 1)] ********************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [Create story.txt on app server 2] **************************************
skipping: [stapp01]
skipping: [stapp03]
changed: [stapp02]

TASK [Set ACL for user steve on story.txt (app server 2)] *******************
skipping: [stapp01]
skipping: [stapp03]
changed: [stapp02]

TASK [Create media.txt on app server 3] **************************************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

TASK [Set ACL for group banner on media.txt (app server 3)] *****************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

PLAY RECAP *********************************************************************
stapp01                    : ok=4    changed=3    unreachable=0    failed=0
stapp02                    : ok=4    changed=3    unreachable=0    failed=0
stapp03                    : ok=4    changed=3    unreachable=0    failed=0
```

### Verification Commands

#### Check File Creation and Ownership
```bash
# Verify files exist with correct ownership
ansible all -i inventory -m shell -a "ls -la /opt/sysops/*.txt" --become

# Expected output:
# -rw-r--r--+ 1 root root 0 Nov 7 10:00 /opt/sysops/blog.txt    (on stapp01)
# -rw-r--r--+ 1 root root 0 Nov 7 10:00 /opt/sysops/story.txt   (on stapp02)  
# -rw-r--r--+ 1 root root 0 Nov 7 10:00 /opt/sysops/media.txt   (on stapp03)
# Note: The '+' indicates ACL permissions are set
```

#### Check ACL Permissions
```bash
# Verify ACL configurations
ansible all -i inventory -m shell -a "getfacl /opt/sysops/*.txt 2>/dev/null || echo 'No files found'" --become

# Expected ACL output:
# On stapp01 (blog.txt):
# # file: /opt/sysops/blog.txt
# # owner: root
# # group: root
# user::rw-
# group::r--
# group:tony:r--
# mask::r--
# other::r--

# On stapp02 (story.txt):
# # file: /opt/sysops/story.txt
# # owner: root
# # group: root
# user::rw-
# user:steve:rw-
# group::r--
# mask::rw-
# other::r--

# On stapp03 (media.txt):
# # file: /opt/sysops/media.txt
# # owner: root
# # group: root
# user::rw-
# group::r--
# group:banner:rw-
# mask::rw-
# other::r--
```

## Key ACL Concepts Demonstrated

### 1. Entity Types
- **User ACL**: `entity: steve, etype: user` - Grants permissions to specific user
- **Group ACL**: `entity: tony, etype: group` - Grants permissions to specific group

### 2. Permission Levels
- **Read (r)**: View file contents
- **Write (w)**: Modify file contents
- **Read/Write (rw)**: Both read and write access

### 3. ACL vs Traditional Permissions
- Traditional permissions: owner-group-others (3 entities)
- ACL permissions: Multiple users and groups can have specific permissions
- Files with ACLs show '+' in `ls -l` output

## Troubleshooting Guide

### Common Issues and Solutions

1. **ACL utilities not installed**
   ```bash
   # Check if acl package is installed
   rpm -qa | grep acl
   # Install if missing
   yum install -y acl
   ```

2. **Filesystem doesn't support ACLs**
   ```bash
   # Check mount options
   mount | grep -E "(ext[34]|xfs)" | grep acl
   # Remount with ACL support
   mount -o remount,acl /
   ```

3. **Permission denied errors**
   ```bash
   # Ensure become: yes is set in playbook
   # Check user has sudo privileges
   sudo -l
   ```

4. **ACL not taking effect**
   ```bash
   # Check mask permissions
   getfacl /path/to/file
   # Adjust mask if needed
   setfacl -m m::rw /path/to/file
   ```

## Security Considerations

1. **Principle of Least Privilege**: Only grant minimum necessary permissions
2. **Regular Auditing**: Monitor ACL configurations for unauthorized changes
3. **Backup ACLs**: Save ACL configurations before making changes
4. **Documentation**: Maintain records of who has access to what resources

## Advanced Use Cases

The resources.md file provides comprehensive coverage of:
- Production scenarios (web applications, databases, multi-tenant systems)
- Security best practices and auditing
- Performance optimization for large directory structures
- Integration with monitoring and compliance systems

This solution demonstrates fundamental ACL management using Ansible while establishing the foundation for more complex access control scenarios in enterprise environments.