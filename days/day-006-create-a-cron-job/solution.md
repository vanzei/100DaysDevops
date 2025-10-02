```

# For RHEL/CentOS/Rocky Linux systems
sudo yum install -y cronie

# For newer systems using dnf
sudo dnf install -y cronie

# For Debian/Ubuntu systems (uses cron instead of cronie)
sudo apt update && sudo apt install -y cron



# Start the crond service
sudo systemctl start crond

# Enable crond to start automatically at boot
sudo systemctl enable crond

# Check the status to ensure it's running
sudo systemctl status crond


# Edit root's crontab directly
sudo crontab -e

# Add this line to the crontab file:
*/5 * * * * echo hello > /tmp/cron_text

## Can be done like this too
## echo "*/5 * * * * echo hello > /tmp/cron_text" | sudo crontab -


# List root's cron jobs to verify
sudo crontab -l

# Check if the crond service is running
sudo systemctl status crond

# Monitor the cron log (location varies by system)
sudo tail -f /var/log/cron
# or
sudo journalctl -u crond -f
```