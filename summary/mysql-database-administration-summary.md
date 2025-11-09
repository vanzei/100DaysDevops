# MySQL Database Administration - 100 Days DevOps Challenge

## Overview

MySQL database administration was covered in Days 9 and 17 of the challenge, focusing on database installation, configuration, security, backup strategies, and performance optimization. This module provided essential database management skills for application data persistence and management.

## What We Practiced

### Database Installation & Setup
- **MySQL server installation** and service management
- **Initial configuration** and security setup
- **User management** and access controls
- **Database creation** and schema management

### Security & Hardening
- **Root password configuration** and secure installation
- **User privileges** and role-based access control
- **Network security** and connection restrictions
- **SSL/TLS encryption** for data in transit

### Backup & Recovery
- **Logical backups** using mysqldump
- **Physical backups** and file system snapshots
- **Point-in-time recovery** and incremental backups
- **Backup automation** and scheduling

### Performance & Monitoring
- **Query optimization** and indexing strategies
- **Configuration tuning** for performance
- **Monitoring tools** and metrics collection
- **Log analysis** and troubleshooting

## Key Commands Practiced

### MySQL Installation & Setup
```bash
# Install MySQL server
sudo yum install mysql-server

# Start and enable MySQL service
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Check service status
sudo systemctl status mysqld

# Secure MySQL installation
sudo mysql_secure_installation

# Connect to MySQL
mysql -u root -p
```

### Database Management
```sql
-- Create database
CREATE DATABASE myapp_db;

-- Create user
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON myapp_db.* TO 'appuser'@'localhost';
GRANT SELECT, INSERT, UPDATE ON myapp_db.* TO 'readonly'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Show databases
SHOW DATABASES;

-- Use database
USE myapp_db;

-- Show tables
SHOW TABLES;

-- Describe table structure
DESCRIBE users;
```

### Backup & Restore Commands
```bash
# Full database backup
mysqldump -u root -p --all-databases > full_backup.sql

# Single database backup
mysqldump -u root -p myapp_db > myapp_backup.sql

# Backup with compression
mysqldump -u root -p myapp_db | gzip > myapp_backup.sql.gz

# Restore from backup
mysql -u root -p myapp_db < myapp_backup.sql

# Restore compressed backup
gunzip < myapp_backup.sql.gz | mysql -u root -p myapp_db

# Backup specific tables
mysqldump -u root -p myapp_db users posts > tables_backup.sql
```

### User Management & Security
```sql
-- Change user password
ALTER USER 'appuser'@'localhost' IDENTIFIED BY 'new_secure_password';

-- Create user with specific host restrictions
CREATE USER 'remoteuser'@'192.168.1.%' IDENTIFIED BY 'password';

-- Revoke privileges
REVOKE INSERT ON myapp_db.users FROM 'appuser'@'localhost';

-- Drop user
DROP USER 'olduser'@'localhost';

-- Show user privileges
SHOW GRANTS FOR 'appuser'@'localhost';

-- Enable SSL for user connections
ALTER USER 'appuser'@'localhost' REQUIRE SSL;
```

### Performance Monitoring
```sql
-- Show running processes
SHOW PROCESSLIST;

-- Show engine status
SHOW ENGINE INNODB STATUS;

-- Show global variables
SHOW GLOBAL VARIABLES LIKE 'max_connections';

-- Show global status
SHOW GLOBAL STATUS LIKE 'Threads_connected';

-- Analyze slow queries
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;

-- Show table indexes
SHOW INDEX FROM users;

-- Analyze table
ANALYZE TABLE users;
```

## Technical Topics Covered

### MySQL Architecture
```text
MySQL Server Instance
├── Connection Manager
│   ├── Network Interfaces (TCP/IP, Unix Socket)
│   └── Connection Thread Pool
├── SQL Layer
│   ├── Parser & Optimizer
│   ├── Query Cache
│   └── Stored Procedures & Functions
├── Storage Engine Layer
│   ├── InnoDB (Default, ACID compliant)
│   ├── MyISAM (Legacy, non-transactional)
│   └── Memory (In-memory tables)
└── File System Layer
    ├── Data Files (.ibd, .frm)
    ├── Log Files (binlog, relay log)
    ├── Configuration Files (my.cnf)
    └── PID & Socket Files
```

### Storage Engines
```sql
-- InnoDB (Default - ACID compliant)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- MyISAM (Legacy - Fast reads)
CREATE TABLE logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT,
    log_level ENUM('INFO', 'WARN', 'ERROR'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM;

-- Memory (In-memory - Fast access, volatile)
CREATE TABLE cache (
    key VARCHAR(255) PRIMARY KEY,
    value TEXT,
    expires_at TIMESTAMP
) ENGINE=MEMORY;
```

### Indexing Strategies
```sql
-- Single column index
CREATE INDEX idx_username ON users (username);

-- Composite index
CREATE INDEX idx_user_email ON users (username, email);

-- Unique index
CREATE UNIQUE INDEX idx_unique_email ON users (email);

-- Full-text index
CREATE FULLTEXT INDEX idx_content ON articles (title, content);

-- Show index usage
EXPLAIN SELECT * FROM users WHERE username = 'john_doe';

-- Index cardinality
SELECT
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    PAGES,
    FILTER_CONDITION
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'myapp_db';
```

### Configuration Optimization
```ini
# /etc/my.cnf - MySQL Configuration
[mysqld]
# Basic Settings
bind-address = 127.0.0.1
port = 3306
socket = /var/lib/mysql/mysql.sock

# Connection Settings
max_connections = 100
max_connect_errors = 100000
wait_timeout = 28800

# InnoDB Settings
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 1
innodb_flush_method = O_DIRECT

# Query Cache (MySQL 5.7 and earlier)
query_cache_size = 256M
query_cache_type = ON
query_cache_limit = 1M

# Logging
general_log = OFF
general_log_file = /var/log/mysql/mysql.log
slow_query_log = ON
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time = 2

# Security
skip-name-resolve
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO
```

## Production Environment Considerations

### High Availability
- **Master-Slave Replication**: Read scaling and failover
- **Master-Master Replication**: Bidirectional synchronization
- **MySQL Cluster**: Multi-master clustering
- **Load Balancing**: ProxySQL and HAProxy integration

### Security Hardening
- **Network Security**: Private networking and firewalls
- **Encryption**: Data at rest and in transit
- **Access Controls**: Principle of least privilege
- **Audit Logging**: Database activity monitoring

### Backup Strategies
- **Full Backups**: Complete database snapshots
- **Incremental Backups**: Change-based backups
- **Point-in-Time Recovery**: Precise recovery capabilities
- **Backup Validation**: Restore testing and verification

### Performance Optimization
- **Query Optimization**: Index usage and query rewriting
- **Connection Pooling**: Efficient connection management
- **Caching**: Query cache and application-level caching
- **Resource Tuning**: Memory and CPU optimization

## Real-World Applications

### Web Application Database Setup
```sql
-- Create application database
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create application user
CREATE USER 'ecommerce_app'@'localhost' IDENTIFIED BY 'secure_app_password';

-- Grant specific privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_db.* TO 'ecommerce_app'@'localhost';

-- Create tables
USE ecommerce_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB;

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category_id),
    FULLTEXT idx_name_desc (name, description)
) ENGINE=InnoDB;

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_status (user_id, status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;
```

### Replication Setup
```bash
# Configure Master Server
# /etc/my.cnf on master
[mysqld]
server-id = 1
log-bin = mysql-bin
binlog-do-db = myapp_db

# Create replication user on master
mysql -u root -p -e "
CREATE USER 'replica'@'%' IDENTIFIED BY 'replica_password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
"

# Get master status
mysql -u root -p -e "SHOW MASTER STATUS;"

# Configure Slave Server
# /etc/my.cnf on slave
[mysqld]
server-id = 2
relay-log = mysql-relay-bin

# Configure slave to connect to master
mysql -u root -p -e "
CHANGE MASTER TO
MASTER_HOST='master.example.com',
MASTER_USER='replica',
MASTER_PASSWORD='replica_password',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=154;
START SLAVE;
"

# Check slave status
mysql -u root -p -e "SHOW SLAVE STATUS\G;"
```

### Automated Backup Script
```bash
#!/bin/bash
# MySQL automated backup script

# Configuration
DB_HOST="localhost"
DB_USER="backup"
DB_PASS="backup_password"
DB_NAME="myapp_db"
BACKUP_DIR="/var/backups/mysql"
RETENTION_DAYS=7

# Create backup directory
mkdir -p $BACKUP_DIR

# Generate backup filename
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql.gz"

# Perform backup
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_FILE

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_FILE"

    # Calculate backup size
    BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)
    echo "Backup size: $BACKUP_SIZE"

    # Clean up old backups
    find $BACKUP_DIR -name "${DB_NAME}_*.sql.gz" -mtime +$RETENTION_DAYS -delete

    # Send notification (optional)
    # mail -s "MySQL Backup Success" admin@example.com < /dev/null
else
    echo "Backup failed!"
    exit 1
fi
```

### Performance Monitoring Dashboard
```sql
-- Create monitoring database
CREATE DATABASE monitoring;

-- Connection monitoring
CREATE TABLE connections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    threads_connected INT,
    threads_running INT,
    max_connections INT
);

-- Query performance monitoring
CREATE TABLE query_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    slow_queries BIGINT,
    select_scan BIGINT,
    select_range BIGINT,
    select_full_join BIGINT
);

-- Insert monitoring data (run periodically)
INSERT INTO connections (threads_connected, threads_running, max_connections)
SELECT
    VARIABLE_VALUE,
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Threads_running'),
    (SELECT VARIABLE_VALUE FROM performance_schema.global_variables WHERE VARIABLE_NAME = 'max_connections')
FROM performance_schema.global_status
WHERE VARIABLE_NAME = 'Threads_connected';
```

### Partitioning for Large Tables
```sql
-- Create partitioned table
CREATE TABLE user_activity (
    id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    activity_type VARCHAR(50),
    activity_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, created_at)
)
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Add new partition
ALTER TABLE user_activity ADD PARTITION (
    PARTITION p2025 VALUES LESS THAN (2026)
);

-- Remove old partition
ALTER TABLE user_activity DROP PARTITION p2023;

-- Show partition information
SELECT
    TABLE_NAME,
    PARTITION_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'user_activity';
```

## Troubleshooting Common Issues

### Connection Issues
```bash
# Check MySQL service status
sudo systemctl status mysqld

# Check if MySQL is listening
sudo netstat -tlnp | grep 3306

# Test local connection
mysql -u root -p -e "SELECT 1;"

# Check error logs
sudo tail -f /var/log/mysql/error.log

# Reset root password
sudo systemctl stop mysqld
sudo mysqld_safe --skip-grant-tables &
mysql -u root -e "UPDATE mysql.user SET authentication_string = PASSWORD('new_password') WHERE User = 'root'; FLUSH PRIVILEGES;"
```

### Performance Issues
```sql
-- Find slow queries
SELECT
    sql_text,
    exec_count,
    avg_timer_wait/1000000000 as avg_time_sec
FROM performance_schema.events_statements_summary_by_digest
ORDER BY avg_timer_wait DESC LIMIT 10;

-- Check for table locks
SHOW OPEN TABLES WHERE In_use > 0;

-- Analyze query execution plan
EXPLAIN FORMAT=JSON SELECT * FROM users WHERE email = 'user@example.com';

-- Check buffer pool usage
SHOW ENGINE INNODB STATUS;
```

### Replication Issues
```bash
# Check slave status
mysql -u root -p -e "SHOW SLAVE STATUS\G;"

# Skip replication error
mysql -u root -p -e "STOP SLAVE; SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1; START SLAVE;"

# Reset slave
mysql -u root -p -e "STOP SLAVE; RESET SLAVE ALL;"

# Check master status
mysql -u root -p -e "SHOW MASTER STATUS;"

# Rebuild slave from master
mysqldump -u root -p --all-databases --master-data > master_dump.sql
# Then restore on slave and configure replication
```

### Disk Space Issues
```bash
# Check disk usage
du -sh /var/lib/mysql/

# Check largest tables
SELECT
    table_schema,
    table_name,
    data_length/1024/1024 as data_mb,
    index_length/1024/1024 as index_mb
FROM information_schema.tables
ORDER BY data_length + index_length DESC LIMIT 10;

# Archive old data
CREATE TABLE archived_orders AS SELECT * FROM orders WHERE created_at < '2023-01-01';
DELETE FROM orders WHERE created_at < '2023-01-01';

# Optimize tables
OPTIMIZE TABLE large_table;
```

## Key Takeaways

1. **ACID Compliance**: InnoDB provides reliable transactions
2. **Backup Strategy**: Regular backups are critical for data protection
3. **Security First**: Least privilege access and network security
4. **Performance Tuning**: Indexing and configuration optimization
5. **Monitoring**: Proactive monitoring prevents issues

## Next Steps

- **MySQL 8.0**: Latest features and improvements
- **MariaDB**: MySQL-compatible alternative
- **Percona Server**: Enhanced MySQL distribution
- **MySQL Cluster**: High availability clustering
- **Cloud Databases**: RDS, Cloud SQL, Aurora

MySQL remains the world's most popular open-source database, powering everything from small applications to large-scale enterprise systems with its reliability, performance, and extensive feature set.