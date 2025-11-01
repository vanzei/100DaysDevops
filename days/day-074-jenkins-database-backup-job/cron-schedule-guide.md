# Jenkins Cron Schedule Configuration

## Understanding the Schedule Format

The Jenkins cron expression follows the standard cron format:
```
* * * * *
| | | | |
| | | | +--- Day of week (0-7, where 0 and 7 are Sunday)
| | | +----- Month (1-12)
| | +------- Day of month (1-31)
| +--------- Hour (0-23)
+----------- Minute (0-59)
```

## Required Schedule: `*/10 * * * *`

### Breakdown of `*/10 * * * *`:
- `*/10` - Every 10 minutes
- `*` - Every hour
- `*` - Every day of month
- `*` - Every month
- `*` - Every day of week

This means the job will run **every 10 minutes**, 24/7.

## How to Configure in Jenkins

### Method 1: Using Build Triggers
1. In your Jenkins job configuration page
2. Scroll to "Build Triggers" section
3. Check "Build periodically"
4. In the "Schedule" text box, enter: `*/10 * * * *`
5. Click "Save"

### Method 2: Using Pipeline Script
If using a Pipeline job, add this to your Jenkinsfile:
```groovy
pipeline {
    agent any
    triggers {
        cron('*/10 * * * *')
    }
    stages {
        stage('Database Backup') {
            steps {
                // Your backup script here
            }
        }
    }
}
```

## Schedule Examples for Reference

| Schedule | Description | When it runs |
|----------|-------------|--------------|
| `*/10 * * * *` | Every 10 minutes | 00:00, 00:10, 00:20, etc. |
| `0 * * * *` | Every hour | 00:00, 01:00, 02:00, etc. |
| `0 6 * * *` | Daily at 6 AM | Every day at 06:00 |
| `0 2 * * 0` | Weekly on Sunday at 2 AM | Every Sunday at 02:00 |
| `0 0 1 * *` | Monthly on 1st at midnight | 1st of every month at 00:00 |

## Important Notes

### Timezone Considerations
- Jenkins uses the server's timezone by default
- You can specify timezone using `TZ` parameter:
  ```
  TZ=America/New_York
  */10 * * * *
  ```

### Testing the Schedule
1. After saving, check the job's main page
2. Look for "Build History" on the left side
3. The next scheduled build time appears in the job details

### Schedule Validation
- Jenkins validates cron expressions when you save
- Invalid expressions will show an error message
- Use Jenkins' built-in help (?) icon for syntax reference

## Troubleshooting Common Issues

### Issue: Job not triggering automatically
**Solution:** 
- Verify the cron expression syntax
- Check Jenkins system time vs expected timezone
- Ensure Jenkins service is running continuously

### Issue: Too frequent execution
**Solution:**
- Double-check the minute field (`*/10` means every 10 minutes)
- Consider using `0 */1 * * *` for hourly instead of `*/60 * * * *`

### Issue: Schedule conflicts with system maintenance
**Solution:**
- Plan around backup windows
- Consider using `H/10 * * * *` for hash-based distribution to avoid peak times

## Best Practices

1. **Use Hash Symbol (H):** `H/10 * * * *` distributes load better than `*/10 * * * *`
2. **Document Schedule:** Always comment why a specific schedule was chosen
3. **Monitor Execution:** Set up notifications for failed backup jobs
4. **Avoid Peak Hours:** Consider database load during business hours
5. **Test Thoroughly:** Always test schedule changes in non-production first