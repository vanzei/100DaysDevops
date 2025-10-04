```
# Fix ownership of the MySQL data directory
sudo chown -R mysql:mysql /var/lib/mysql

# Set proper permissions on the data directory
sudo chmod 755 /var/lib/mysql

# Fix ownership of log directory
sudo chown -R mysql:mysql /var/log/mariadb

# Fix ownership of run directory (if exists)
sudo chown -R mysql:mysql /var/run/mariadb

```