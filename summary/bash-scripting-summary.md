# Bash Scripting - 100 Days DevOps Challenge

## Overview

Bash scripting was covered in Days 10 and 18 of the challenge, focusing on shell scripting fundamentals, automation, system administration tasks, and DevOps automation workflows. This module provided essential scripting skills for infrastructure automation and operational tasks.

## What We Practiced

### Script Fundamentals
- **Bash script creation** and execution permissions
- **Variables and data types** (strings, numbers, arrays)
- **Command execution** and output capture
- **Exit codes** and error handling

### Control Structures
- **Conditional statements** (if/elif/else, case)
- **Loops** (for, while, until)
- **Functions** and code reusability
- **Input validation** and parameter handling

### System Administration
- **File operations** (create, read, modify, delete)
- **Process management** (start, stop, monitor)
- **User management** automation
- **System monitoring** and reporting

### Advanced Features
- **Traps and signals** for cleanup
- **Subshells and command substitution**
- **Here documents** and input redirection
- **Script debugging** and logging

## Key Commands Practiced

### Script Creation & Execution
```bash
# Create script file
touch myscript.sh

# Add shebang
echo '#!/bin/bash' > myscript.sh

# Make executable
chmod +x myscript.sh

# Execute script
./myscript.sh

# Execute with bash
bash myscript.sh

# Debug execution
bash -x myscript.sh
```

### Variables & Data Types
```bash
#!/bin/bash
# Variable examples

# String variables
NAME="John Doe"
echo "Hello, $NAME"
echo "Hello, ${NAME}"

# Integer variables
AGE=25
echo "Age: $AGE"

# Arrays
FRUITS=("apple" "banana" "orange")
echo "First fruit: ${FRUITS[0]}"
echo "All fruits: ${FRUITS[@]}"
echo "Number of fruits: ${#FRUITS[@]}"

# Environment variables
echo "Home directory: $HOME"
echo "Current user: $USER"
echo "Path: $PATH"

# Special variables
echo "Script name: $0"
echo "First argument: $1"
echo "All arguments: $@"
echo "Number of arguments: $#"
echo "Last exit code: $?"
echo "Process ID: $$"
```

### Control Flow Examples
```bash
#!/bin/bash
# Control structures

# If statements
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
elif [ $# -eq 1 ]; then
    echo "One argument: $1"
else
    echo "Multiple arguments: $@"
fi

# Case statement
case $1 in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

# For loops
for i in {1..5}; do
    echo "Iteration $i"
done

for file in *.txt; do
    echo "Processing $file"
done

# While loops
counter=1
while [ $counter -le 5 ]; do
    echo "Count: $counter"
    ((counter++))
done

# Until loops
counter=1
until [ $counter -gt 5 ]; do
    echo "Count: $counter"
    ((counter++))
done
```

### Functions
```bash
#!/bin/bash
# Function examples

# Simple function
greet() {
    echo "Hello, $1!"
}

# Function with return value
is_even() {
    if [ $(($1 % 2)) -eq 0 ]; then
        return 0  # Success (even)
    else
        return 1  # Failure (odd)
    fi
}

# Function with local variables
calculate() {
    local result=$(( $1 + $2 ))
    echo $result
}

# Main script
greet "World"

if is_even 4; then
    echo "4 is even"
else
    echo "4 is odd"
fi

sum=$(calculate 5 3)
echo "5 + 3 = $sum"
```

## Technical Topics Covered

### Bash Script Structure
```bash
#!/bin/bash
# Script header with metadata
# Author: DevOps Engineer
# Description: System monitoring script
# Version: 1.0

# Exit on error
set -e

# Global variables
SCRIPT_NAME=$(basename "$0")
LOG_FILE="/var/log/${SCRIPT_NAME}.log"

# Functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

cleanup() {
    log_message "Cleaning up..."
    # Cleanup code here
}

error_exit() {
    log_message "ERROR: $1"
    cleanup
    exit 1
}

# Trap signals
trap cleanup EXIT
trap 'error_exit "Script interrupted"' INT TERM

# Main script logic
main() {
    log_message "Starting $SCRIPT_NAME"

    # Script body here

    log_message "Completed successfully"
}

# Execute main function
main "$@"
```

### Input/Output Redirection
```bash
#!/bin/bash
# I/O redirection examples

# Output redirection
echo "Hello World" > output.txt          # Overwrite
echo "Hello Again" >> output.txt        # Append

# Input redirection
wc -l < input.txt

# Here document
cat << EOF > config.txt
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
}
EOF

# Here string
grep "error" <<< "This is an error message"

# Command substitution
current_date=$(date)
file_count=$(ls | wc -l)

# Process substitution
diff <(sort file1.txt) <(sort file2.txt)

# File descriptors
exec 3> debug.log                       # Open file descriptor 3
echo "Debug info" >&3                   # Write to file descriptor 3
exec 3>&-                              # Close file descriptor 3
```

### Error Handling & Debugging
```bash
#!/bin/bash
# Error handling and debugging

# Exit on error
set -e

# Exit on undefined variables
set -u

# Print commands before execution (debug)
# set -x

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo "Error at line $line_number: command exited with code $exit_code"
    exit $exit_code
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Validate input
validate_number() {
    local num=$1
    if ! [[ $num =~ ^[0-9]+$ ]]; then
        echo "Error: '$num' is not a valid number"
        return 1
    fi
}

# Safe command execution
safe_command() {
    local cmd=$1
    echo "Executing: $cmd"
    if ! eval "$cmd"; then
        echo "Command failed: $cmd"
        return 1
    fi
}

# Usage example
if [ $# -ne 1 ]; then
    echo "Usage: $0 <number>"
    exit 1
fi

validate_number "$1" || exit 1
safe_command "echo 'Processing number: $1'"
```

### Advanced Scripting Techniques
```bash
#!/bin/bash
# Advanced scripting examples

# Associative arrays (Bash 4+)
declare -A user_info
user_info[name]="John Doe"
user_info[age]="30"
user_info[email]="john@example.com"

echo "User: ${user_info[name]}"
echo "Age: ${user_info[age]}"

# Indirect variable expansion
var_name="my_var"
my_var="Hello World"
echo "${!var_name}"  # Outputs: Hello World

# String manipulation
string="Hello, World!"
echo "${string,,}"    # Lowercase: hello, world!
echo "${string^^}"    # Uppercase: HELLO, WORLD!
echo "${string:7:5}"  # Substring: World
echo "${string/World/Universe}"  # Replace: Hello, Universe!

# Arithmetic operations
a=5
b=3
echo $((a + b))       # Addition: 8
echo $((a - b))       # Subtraction: 2
echo $((a * b))       # Multiplication: 15
echo $((a / b))       # Division: 1
echo $((a % b))       # Modulo: 2

# Floating point with bc
result=$(echo "scale=2; 5.5 * 2.3" | bc)
echo "Result: $result"

# Parallel execution
run_parallel() {
    local max_jobs=4
    local job_count=0

    for item in "$@"; do
        process_item "$item" &

        ((job_count++))
        if [ $job_count -ge $max_jobs ]; then
            wait
            job_count=0
        fi
    done

    wait  # Wait for remaining jobs
}
```

## Production Environment Considerations

### Security Best Practices
- **Input validation**: Sanitize all user inputs
- **Least privilege**: Run scripts with minimal permissions
- **Secure temporary files**: Use mktemp for temporary files
- **Password handling**: Avoid plain text passwords

### Reliability & Monitoring
- **Error handling**: Comprehensive error checking
- **Logging**: Detailed execution logs
- **Timeouts**: Prevent hanging scripts
- **Resource limits**: Control memory and CPU usage

### Maintainability
- **Code organization**: Modular functions and clear structure
- **Documentation**: Comments and usage instructions
- **Version control**: Track script changes
- **Testing**: Automated script testing

### Performance Optimization
- **Efficient commands**: Use built-in bash features
- **Avoid subshells**: Minimize command substitution
- **Parallel processing**: Run independent tasks concurrently
- **Resource monitoring**: Track script performance

## Real-World Applications

### System Monitoring Script
```bash
#!/bin/bash
# System monitoring and alerting script

# Configuration
THRESHOLD_CPU=80
THRESHOLD_MEMORY=90
THRESHOLD_DISK=85
ALERT_EMAIL="admin@example.com"
LOG_FILE="/var/log/system_monitor.log"

# Functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

send_alert() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
}

check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "$cpu_usage"

    if (( $(echo "$cpu_usage > $THRESHOLD_CPU" | bc -l) )); then
        send_alert "High CPU Usage Alert" "CPU usage is at ${cpu_usage}% (threshold: ${THRESHOLD_CPU}%)"
    fi
}

check_memory() {
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    echo "$mem_usage"

    if [ $mem_usage -gt $THRESHOLD_MEMORY ]; then
        send_alert "High Memory Usage Alert" "Memory usage is at ${mem_usage}% (threshold: ${THRESHOLD_MEMORY}%)"
    fi
}

check_disk() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "$disk_usage"

    if [ $disk_usage -gt $THRESHOLD_DISK ]; then
        send_alert "High Disk Usage Alert" "Disk usage is at ${disk_usage}% (threshold: ${THRESHOLD_DISK}%)"
    fi
}

check_services() {
    local services=("sshd" "nginx" "mysql")
    local failed_services=()

    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            failed_services+=("$service")
        fi
    done

    if [ ${#failed_services[@]} -gt 0 ]; then
        send_alert "Service Failure Alert" "The following services are not running: ${failed_services[*]}"
    fi
}

# Main execution
main() {
    log_message "Starting system monitoring"

    local cpu=$(check_cpu)
    local mem=$(check_memory)
    local disk=$(check_disk)

    check_services

    log_message "Monitoring completed - CPU: ${cpu}%, Memory: ${mem}%, Disk: ${disk}%"
}

# Run main function
main
```

### Automated Backup Script
```bash
#!/bin/bash
# Automated backup script with rotation

# Configuration
SOURCE_DIR="/var/www/html"
BACKUP_DIR="/var/backups"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="website_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
LOG_FILE="/var/log/backup.log"

# Functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

cleanup_old_backups() {
    log_message "Cleaning up backups older than ${RETENTION_DAYS} days"
    find "$BACKUP_DIR" -name "website_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete
}

send_notification() {
    local subject="$1"
    local message="$2"
    local status="$3"

    # Send email notification
    echo "$message" | mail -s "$subject" "admin@example.com"

    # Log to monitoring system (example)
    curl -X POST -H "Content-Type: application/json" \
         -d "{\"backup\":\"$BACKUP_NAME\",\"status\":\"$status\",\"size\":\"$BACKUP_SIZE\"}" \
         http://monitoring.example.com/api/backups
}

# Pre-backup checks
pre_backup_check() {
    # Check if source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        log_message "ERROR: Source directory $SOURCE_DIR does not exist"
        exit 1
    fi

    # Check available disk space
    local available_space=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
    local estimated_size=$(du -s "$SOURCE_DIR" | awk '{print $1}')

    if [ $available_space -lt $estimated_size ]; then
        log_message "ERROR: Insufficient disk space for backup"
        exit 1
    fi

    # Check if another backup is running
    if pgrep -f "tar.*${SOURCE_DIR}" > /dev/null; then
        log_message "ERROR: Another backup process is already running"
        exit 1
    fi
}

# Main backup function
perform_backup() {
    log_message "Starting backup of $SOURCE_DIR"

    # Create backup
    if tar -czf "$BACKUP_PATH" -C "$SOURCE_DIR" .; then
        BACKUP_SIZE=$(du -h "$BACKUP_PATH" | awk '{print $1}')
        log_message "Backup completed successfully: $BACKUP_PATH (Size: $BACKUP_SIZE)"
        return 0
    else
        log_message "ERROR: Backup failed"
        return 1
    fi
}

# Main execution
main() {
    log_message "=== Starting backup process ==="

    pre_backup_check

    if perform_backup; then
        cleanup_old_backups
        send_notification "Backup Success" "Backup $BACKUP_NAME completed successfully (Size: $BACKUP_SIZE)" "success"
        log_message "=== Backup process completed successfully ==="
        exit 0
    else
        send_notification "Backup Failed" "Backup $BACKUP_NAME failed" "failed"
        log_message "=== Backup process failed ==="
        exit 1
    fi
}

# Trap for cleanup
trap 'log_message "Backup script interrupted"' INT TERM

# Execute main function
main
```

### Deployment Automation Script
```bash
#!/bin/bash
# Application deployment script

# Configuration
APP_NAME="myapp"
APP_DIR="/opt/${APP_NAME}"
BACKUP_DIR="/opt/${APP_NAME}_backups"
SOURCE_URL="https://github.com/user/myapp/archive/main.tar.gz"
SERVICE_NAME="${APP_NAME}.service"
DEPLOY_USER="deploy"

# Functions
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*"
}

error_exit() {
    log_message "ERROR: $1"
    exit 1
}

create_backup() {
    local backup_name="${APP_NAME}_$(date +%Y%m%d_%H%M%S)"
    local backup_path="${BACKUP_DIR}/${backup_name}.tar.gz"

    log_message "Creating backup: $backup_path"

    if [ -d "$APP_DIR" ]; then
        tar -czf "$backup_path" -C "$APP_DIR" . || error_exit "Backup creation failed"
    else
        log_message "No existing application directory to backup"
    fi
}

download_source() {
    local temp_dir=$(mktemp -d)
    local archive_path="${temp_dir}/source.tar.gz"

    log_message "Downloading source code from $SOURCE_URL"

    curl -L "$SOURCE_URL" -o "$archive_path" || error_exit "Download failed"

    echo "$temp_dir"
}

extract_and_deploy() {
    local temp_dir=$1
    local archive_path="${temp_dir}/source.tar.gz"

    log_message "Extracting and deploying application"

    # Stop service
    sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || log_message "Service was not running"

    # Remove old application
    sudo rm -rf "$APP_DIR"

    # Extract new version
    sudo mkdir -p "$APP_DIR"
    sudo tar -xzf "$archive_path" -C "$APP_DIR" --strip-components=1 || error_exit "Extraction failed"

    # Set permissions
    sudo chown -R "$DEPLOY_USER:$DEPLOY_USER" "$APP_DIR"
    sudo chmod -R 755 "$APP_DIR"

    # Install dependencies (example for Node.js app)
    if [ -f "${APP_DIR}/package.json" ]; then
        cd "$APP_DIR"
        sudo -u "$DEPLOY_USER" npm install --production || error_exit "Dependency installation failed"
    fi

    # Start service
    sudo systemctl start "$SERVICE_NAME" || error_exit "Service start failed"

    # Cleanup
    rm -rf "$temp_dir"
}

verify_deployment() {
    log_message "Verifying deployment"

    # Check service status
    if ! sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        error_exit "Service is not running after deployment"
    fi

    # Check application health (example)
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        log_message "Application health check passed"
    else
        error_exit "Application health check failed"
    fi
}

rollback() {
    log_message "Starting rollback process"

    # Find latest backup
    local latest_backup=$(ls -t "${BACKUP_DIR}"/*.tar.gz 2>/dev/null | head -1)

    if [ -z "$latest_backup" ]; then
        error_exit "No backup found for rollback"
    fi

    log_message "Rolling back to backup: $latest_backup"

    # Stop service
    sudo systemctl stop "$SERVICE_NAME"

    # Restore from backup
    sudo rm -rf "$APP_DIR"
    sudo mkdir -p "$APP_DIR"
    sudo tar -xzf "$latest_backup" -C "$APP_DIR" || error_exit "Rollback failed"

    # Restart service
    sudo systemctl start "$SERVICE_NAME" || error_exit "Service restart failed after rollback"

    log_message "Rollback completed successfully"
}

# Main deployment function
deploy() {
    log_message "=== Starting deployment of $APP_NAME ==="

    create_backup

    local temp_dir=$(download_source)

    if extract_and_deploy "$temp_dir"; then
        verify_deployment
        log_message "=== Deployment completed successfully ==="
    else
        log_message "=== Deployment failed, attempting rollback ==="
        rollback
        error_exit "Deployment failed and rollback completed"
    fi
}

# Command line interface
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    rollback)
        rollback
        ;;
    backup)
        create_backup
        ;;
    *)
        echo "Usage: $0 {deploy|rollback|backup}"
        exit 1
        ;;
esac
```

## Troubleshooting Common Issues

### Script Execution Issues
```bash
# Check script permissions
ls -la script.sh

# Verify shebang
head -1 script.sh

# Debug script execution
bash -x script.sh

# Check for syntax errors
bash -n script.sh
```

### Variable Issues
```bash
# Check variable values
echo "Variable value: $VAR"

# Debug variable expansion
set -x  # Enable debug
echo "$VAR"
set +x  # Disable debug

# Check for undefined variables
set -u  # Exit on undefined variables
```

### Command Substitution Issues
```bash
# Incorrect
result=`command`

# Correct
result=$(command)

# Debug command substitution
echo "Command output: $(command 2>&1)"
```

### Loop and Conditional Issues
```bash
# Debug loops
for i in {1..3}; do
    echo "Processing $i"
    # Add debug output
    set -x
    process_item "$i"
    set +x
done

# Test conditions separately
[ -f file.txt ] && echo "File exists" || echo "File does not exist"
```

## Key Takeaways

1. **Error Handling**: Always check for errors and handle them gracefully
2. **Input Validation**: Validate all inputs to prevent security issues
3. **Modular Design**: Break scripts into reusable functions
4. **Logging**: Comprehensive logging for debugging and monitoring
5. **Testing**: Test scripts thoroughly before production use

## Next Steps

- **Advanced Bash**: Arrays, associative arrays, and advanced features
- **Shell Scripting Best Practices**: Code style and organization
- **Integration**: API calls and external service integration
- **Security**: Secure coding practices and vulnerability assessment
- **Performance**: Script optimization and profiling

Bash scripting is fundamental to DevOps automation, enabling infrastructure teams to create reliable, maintainable automation solutions for complex operational workflows.