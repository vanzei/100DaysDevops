# Day 076: Jenkins Project Security - Complete Solution

## Challenge Overview
Configure project-level security permissions for two developers (sam and rohan) to access an existing Jenkins job named "Packages" with specific permission levels.

## Required Plugins

### Essential Plugin: Matrix Authorization Strategy Plugin
This is the **MOST CRITICAL** plugin needed for this challenge:

**Plugin Name**: `Matrix Authorization Strategy Plugin`
**Plugin ID**: `matrix-auth`

**Why it's needed**: 
- Enables project-level permission management
- Allows granular control over user permissions
- Provides the "Project-based Matrix Authorization Strategy" option

### How to Install the Plugin

1. **Access Jenkins**: Login with admin/Adm!n321
2. **Navigate**: Go to "Manage Jenkins" → "Manage Plugins"
3. **Available Tab**: Click on "Available" tab
4. **Search**: Search for "Matrix Authorization Strategy"
5. **Select**: Check the plugin checkbox
6. **Install**: Click "Install without restart" or "Download now and install after restart"
7. **Restart**: Click "Restart Jenkins when installation is complete and no jobs are running"

## Step-by-Step Configuration Approach

### Step 1: Enable Project-based Matrix Authorization

1. **Navigate to Global Security**:
   - Go to "Manage Jenkins" → "Configure Global Security"

2. **Authorization Section**:
   - Find "Authorization" section
   - Select "Project-based Matrix Authorization Strategy"

3. **Global Permissions** (Keep existing admin permissions):
   - Ensure admin user has all permissions
   - Add admin user if not already present with full permissions

4. **Save Configuration**:
   - Click "Save" to apply global security settings

### Step 2: Configure Project-Level Permissions for Packages Job

1. **Access the Packages Job**:
   - Go to Jenkins dashboard
   - Click on "Packages" job
   - Click "Configure"

2. **Enable Project-based Security**:
   - Scroll down to find "Enable project-based security" checkbox
   - **Check this box** to enable project-level permissions

3. **Inheritance Strategy**:
   - Look for "Inheritance Strategy" dropdown
   - Select **"Inherit permissions from parent ACL"**

4. **Configure User Permissions**:

#### For user 'sam':
Add user 'sam' with these permissions:
- ✅ **Build** (Job/Build)
- ✅ **Configure** (Job/Configure) 
- ✅ **Read** (Job/Read)

#### For user 'rohan':
Add user 'rohan' with these permissions:
- ✅ **Build** (Job/Build)
- ✅ **Cancel** (Job/Cancel)
- ✅ **Configure** (Job/Configure)
- ✅ **Read** (Job/Read)
- ✅ **Update** (Job/Update - this might be under SCM permissions)
- ✅ **Tag** (SCM/Tag)

### Step 3: Detailed Permission Matrix Setup

#### Adding Users to Permission Matrix:

1. **Add sam user**:
   - In the User/group field, type: `sam`
   - Click "Add" button
   - Check the required permissions: Build, Configure, Read

2. **Add rohan user**:
   - In the User/group field, type: `rohan`
   - Click "Add" button  
   - Check the required permissions: Build, Cancel, Configure, Read, Update, Tag

#### Permission Mapping Reference:
```
Permission Name → Jenkins Permission Category
- Build → Job/Build
- Cancel → Job/Cancel  
- Configure → Job/Configure
- Read → Job/Read
- Update → Job/Update (or SCM/Update)
- Tag → SCM/Tag
```

### Step 4: Verify User Accounts

Before configuring permissions, verify the users exist:

1. **Check Users**:
   - Go to "Manage Jenkins" → "Manage Users"
   - Confirm `sam` and `rohan` users exist
   - If not, create them with specified passwords:
     - sam: password `sam@pass12345`
     - rohan: password `rohan@pass12345`

### Step 5: Test the Configuration

#### Test sam user access:
1. Logout from admin account
2. Login as sam (sam@pass12345)
3. Verify sam can:
   - See the Packages job
   - Build the job
   - Configure the job
   - Read job details

#### Test rohan user access:
1. Login as rohan (rohan@pass12345)  
2. Verify rohan can:
   - See the Packages job
   - Build the job
   - Cancel builds
   - Configure the job
   - Read job details
   - Update/Tag (if SCM is configured)

## Complete Configuration Checklist

### Plugin Installation:
- [ ] Matrix Authorization Strategy Plugin installed
- [ ] Jenkins restarted after plugin installation

### Global Security Configuration:
- [ ] "Project-based Matrix Authorization Strategy" selected
- [ ] Admin user retains full global permissions

### Project Security Configuration:
- [ ] "Enable project-based security" checked for Packages job
- [ ] "Inherit permissions from parent ACL" selected
- [ ] sam user added with Build, Configure, Read permissions
- [ ] rohan user added with Build, Cancel, Configure, Read, Update, Tag permissions

### Verification:
- [ ] sam user can access and use Packages job with specified permissions
- [ ] rohan user can access and use Packages job with specified permissions
- [ ] No other job configurations were modified

## Common Issues and Solutions

### Issue 1: Matrix Authorization Plugin Not Available
**Solution**: 
- Refresh plugin list
- Search for "matrix-auth" or "Matrix Authorization Strategy"
- Install and restart Jenkins

### Issue 2: Users Don't Exist
**Solution**:
- Go to "Manage Jenkins" → "Manage Users"
- Create users if they don't exist
- Set correct passwords

### Issue 3: Permissions Not Taking Effect
**Solution**:
- Ensure global security is set to "Project-based Matrix Authorization Strategy"
- Verify "Enable project-based security" is checked in job configuration
- Check inheritance strategy is set correctly

### Issue 4: Can't Find Specific Permissions
**Solution**:
Permission mapping:
- Build = Job/Build
- Cancel = Job/Cancel
- Configure = Job/Configure  
- Read = Job/Read
- Update = Job/Update or SCM/Update
- Tag = SCM/Tag

## Important Notes

1. **Don't Modify Other Jobs**: Only configure the Packages job
2. **Inheritance Strategy**: Must be "Inherit permissions from parent ACL"
3. **Plugin Dependency**: Matrix Authorization Strategy plugin is essential
4. **User Credentials**: 
   - sam: sam@pass12345
   - rohan: rohan@pass12345
5. **Testing**: Test with both users to ensure permissions work correctly

## Security Best Practices

1. **Principle of Least Privilege**: Users get only the permissions they need
2. **Inheritance**: Using parent ACL inheritance maintains security consistency  
3. **Project-level Security**: Isolates permissions to specific jobs
4. **Regular Review**: Periodically review and audit user permissions

This configuration ensures that sam and rohan have the exact permissions specified in the challenge while maintaining overall Jenkins security.