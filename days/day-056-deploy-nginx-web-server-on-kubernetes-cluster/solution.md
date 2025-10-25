# Day 056: Deploy Nginx Web Server - Solution & Troubleshooting

## Problem: Website Not Accessible

### Root Cause Analysis
The service command in the original solution has incorrect syntax, preventing proper service creation.

## Correct Solution

### Step 1: Deploy the Application
```bash
kubectl apply -f dep.yml
```

### Step 2: Create the Service (CORRECTED)

**Option 1: Using YAML file (Recommended)**
```bash
kubectl apply -f service.yml
```
