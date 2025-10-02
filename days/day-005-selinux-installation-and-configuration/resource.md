# SELinux Installation and Configuration - Reference Resources

## Official Documentation

### Red Hat Enterprise Linux Documentation
- **SELinux User's and Administrator's Guide**: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/index
- **SELinux Policy Guide**: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/selinux_using_selinux/index

### CentOS Documentation
- **CentOS SELinux HowTo**: https://wiki.centos.org/HowTos/SELinux
- **CentOS SELinux FAQ**: https://wiki.centos.org/TipsAndTricks/SelinuxBooleans

## Key Commands Reference

### Installation Commands
```bash
# RHEL/CentOS 7 and earlier
sudo yum update -y
sudo yum install -y selinux-policy selinux-policy-targeted policycoreutils policycoreutils-python setroubleshoot-server

# RHEL/CentOS 8+ / Fedora
sudo dnf update -y
sudo dnf install -y selinux-policy selinux-policy-targeted policycoreutils policycoreutils-python-utils setroubleshoot-server
```

### SELinux Status and Configuration
```bash
# Check SELinux status
sestatus
getenforce

# SELinux configuration file
/etc/selinux/config

# Temporarily disable SELinux (until reboot)
sudo setenforce 0

# Permanently disable SELinux (requires reboot)
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
```

## SELinux Modes
- **Enforcing**: SELinux policy is enforced. Security policy violations are denied and logged.
- **Permissive**: SELinux policy violations are logged but not denied.
- **Disabled**: SELinux is completely disabled.

## Important Files and Directories
- `/etc/selinux/config` - Main SELinux configuration file
- `/var/log/audit/audit.log` - SELinux audit log
- `/var/log/messages` - System messages including SELinux alerts
- `/etc/selinux/targeted/` - Targeted policy files

## Package Descriptions

### Core Packages
- **selinux-policy**: Base SELinux policy package
- **selinux-policy-targeted**: Targeted SELinux policy (most common policy type)
- **policycoreutils**: Core SELinux utilities and commands
- **policycoreutils-python-utils**: Python-based SELinux utilities (RHEL 8+)
- **policycoreutils-python**: Python-based SELinux utilities (RHEL 7)
- **setroubleshoot-server**: SELinux troubleshooting and alert system

### Useful Additional Packages
- **setools-console**: Command-line tools for SELinux policy analysis
- **selinux-policy-devel**: Development tools for SELinux policy

## Man Pages
```bash
man selinux          # SELinux overview
man sestatus         # SELinux status command
man setenforce       # SELinux mode enforcement
man setsebool        # SELinux boolean values
man semanage         # SELinux policy management
man restorecon       # Restore SELinux contexts
```

## Troubleshooting Resources
- **SELinux Troubleshooter**: Run `sealert -a /var/log/audit/audit.log` after installation
- **SELinux Denial Browser**: Available in GUI environments
- **Online SELinux Decoder**: https://access.redhat.com/labs/selinuxpolicyhelper/

## Best Practices
1. Always backup the system before making SELinux changes
2. Test in permissive mode before enforcing
3. Monitor audit logs regularly
4. Use boolean settings instead of custom policies when possible
5. Document any custom policies or contexts

## Community Resources
- **SELinux Project**: https://selinuxproject.org/
- **SELinux Wiki**: https://selinuxproject.org/page/Main_Page
- **Red Hat Customer Portal**: https://access.redhat.com/
- **CentOS Forums**: https://forums.centos.org/
- **Stack Overflow SELinux Tag**: https://stackoverflow.com/questions/tagged/selinux