https://linux.die.net/man/5/sshd_config

PermitRootLogin
Specifies whether root can log in using ssh(1). The argument must be ''yes'', ''without-password'', ''forced-commands-only'', or ''no''. The default is ''yes''.

If this option is set to ''without-password'', password authentication is disabled for root.

If this option is set to ''forced-commands-only'', root login with public key authentication will be allowed, but only if the command option has been specified (which may be useful for taking remote backups even if root login is normally not allowed). All other authentication methods are disabled for root.

If this option is set to ''no'', root is not allowed to log in.