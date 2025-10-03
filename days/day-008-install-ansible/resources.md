# Day 008: Install Ansible - Resources

## Installation Methods for All Users

When installing Python applications that need to be accessible to all users on a system, you have several options. The choice depends on your specific requirements and environment constraints.

### 1. System-wide Installation (requires sudo)

```bash
sudo pip3 install package_name
```

**Details:**
- **Location**: `/usr/local/lib/python3.x/site-packages/`
- **Binaries**: `/usr/local/bin/` (automatically in PATH)
- **Access**: All users can run the application directly
- **Use case**: When you want global, immediate access for all users

**Example for Ansible 4.10.0:**
```bash
sudo pip3 install ansible==4.10.0
```

### 2. Package Manager Installation (requires sudo)

```bash
# Fedora/RHEL/CentOS
sudo dnf install python3-package_name

# Ubuntu/Debian
sudo apt install python3-package_name
```

**Details:**
- **Location**: System directories managed by the package manager
- **Access**: Available to all users
- **Advantage**: Better integration with system updates
- **Limitation**: May not have the exact version you need

### 3. User Installation + PATH Configuration (no sudo needed)

```bash
# Install for current user only
pip3 install --user package_name

# Then configure PATH for all users
sudo echo 'export PATH=$PATH:~/.local/bin' >> /etc/profile
```

**Details:**
- **Location**: `~/.local/lib/python3.x/site-packages/`
- **Binaries**: `~/.local/bin/`
- **Limitation**: Each user needs the package installed individually

### 4. Virtual Environment + Symlinks (hybrid approach)

```bash
# Create system virtual environment
sudo python3 -m venv /opt/myapp-env
sudo /opt/myapp-env/bin/pip install package_name

# Create symlinks for all users
sudo ln -s /opt/myapp-env/bin/package_binary /usr/local/bin/
```

**Details:**
- **Location**: Isolated virtual environment
- **Access**: Via symlinks in system PATH
- **Advantage**: No conflicts with system packages
- **Use case**: Production deployments requiring isolation

## When to Use Each Method

| Method | Use When | Pros | Cons |
|--------|----------|------|------|
| `sudo pip3` | Need immediate global access | Simple, direct | Can conflict with system packages |
| Package manager | Available in repos | System integration | May not have exact version |
| `--user` + PATH | Limited admin rights | No system changes | Each user installs separately |
| Virtual env + symlinks | Production deployments | Isolated, controlled | More complex setup |

## Best Practices

1. **For development tools** (like Ansible): Use `sudo pip3 install`
2. **For production applications**: Use virtual environments
3. **For system utilities**: Prefer package manager when possible
4. **For user-specific tools**: Use `pip3 install --user`

## Complete Ansible 4.10.0 Installation Guide

### Prerequisites
```bash
# Update system packages
sudo dnf update -y

# Install Python 3 and pip3 if not already installed
sudo dnf install -y python3 python3-pip
```

### Installation
```bash
# Install Ansible 4.10.0 globally
sudo pip3 install ansible==4.10.0

# Verify installation
ansible --version
```

### Post-Installation Verification
```bash
# Check if ansible is globally accessible
which ansible
ansible --version

# Test as different user (if available)
su - otheruser -c "ansible --version"
```

### Optional: Additional Components
```bash
# Install useful collections and dependencies
sudo pip3 install ansible-core==2.11.12  # Core component of Ansible 4.10.0
sudo pip3 install paramiko  # For SSH connections
sudo pip3 install requests  # For various modules

# Create ansible configuration directory
sudo mkdir -p /etc/ansible
sudo chown root:root /etc/ansible
sudo chmod 755 /etc/ansible
```

## Key Takeaway

**Do you always need sudo with pip for all users?** 

**No**, but for the specific requirement of "all users should be capable of using ansible after the install," using `sudo pip3 install` is the most straightforward solution because it:
- Installs globally in one command
- Makes binaries immediately available to all users
- Doesn't require additional PATH configuration

The key is matching the installation method to your specific requirements and environment constraints.