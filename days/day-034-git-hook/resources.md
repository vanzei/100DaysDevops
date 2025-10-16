# Git Hooks - Complete Guide and Real-World Applications

## 🎯 What Are Git Hooks Really?

Git hooks are **scripts that Git executes automatically** at specific points in the Git workflow. Think of them as **event-driven automation** - when certain Git events happen, your custom scripts run automatically.

### **The Reality Check:**
- **Lab Environment:** Hooks often feel "weak" because of setup limitations
- **Production Environment:** Hooks are incredibly powerful for automation
- **Key Insight:** The power comes from **WHERE** and **HOW** they're deployed

---

## 🔍 Why Git Hooks Feel "Weak" in Labs

### **Common Lab Issues:**
1. **Wrong Hook Location:** Client-side vs server-side confusion
2. **Manual Testing:** Having to run hooks manually defeats the purpose
3. **Limited Environment:** No real CI/CD integration to see the power
4. **Simple Examples:** Basic tagging doesn't show real potential

### **Real-World Reality:**
- **Automatic Execution:** Hooks run without human intervention
- **Integration Power:** Connect to CI/CD, notifications, deployments
- **Workflow Enforcement:** Prevent bad commits, enforce standards
- **Business Logic:** Custom automation for specific team needs

---

## 📚 Complete Git Hooks Reference

## 🎯 Client-Side Hooks (Your Local Machine)

### **1. pre-commit**
**When:** Before creating a commit
**Purpose:** Validate code quality, run tests, check formatting

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run code formatting
npm run format

# Run linting
npm run lint
if [ $? -ne 0 ]; then
    echo "❌ Linting failed. Commit aborted."
    exit 1
fi

# Run unit tests
npm test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Commit aborted."
    exit 1
fi

echo "✅ All checks passed. Proceeding with commit."
```

**Real-World Use Cases:**
- **Code Quality:** Prevent commits with linting errors
- **Security:** Scan for secrets/API keys
- **Testing:** Run unit tests before commit
- **Formatting:** Auto-format code

### **2. prepare-commit-msg**
**When:** Before commit message editor opens
**Purpose:** Auto-populate or modify commit messages

```bash
#!/bin/bash
# .git/hooks/prepare-commit-msg

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Add branch name to commit message
BRANCH_NAME=$(git branch --show-current)
if [[ $BRANCH_NAME != "master" && $BRANCH_NAME != "main" ]]; then
    sed -i.bak -e "1s/^/[$BRANCH_NAME] /" $COMMIT_MSG_FILE
fi

# Add ticket number if branch follows pattern
if [[ $BRANCH_NAME =~ ^(feature|bugfix)\/([A-Z]+-[0-9]+) ]]; then
    TICKET=${BASH_REMATCH[2]}
    sed -i.bak -e "1s/^/$TICKET: /" $COMMIT_MSG_FILE
fi
```

### **3. commit-msg**
**When:** After commit message is entered
**Purpose:** Validate commit message format

```bash
#!/bin/bash
# .git/hooks/commit-msg

# Check commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add user login functionality"
    exit 1
fi

echo "✅ Commit message format is valid"
```

### **4. pre-push**
**When:** Before pushing to remote
**Purpose:** Final checks before sharing code

```bash
#!/bin/bash
# .git/hooks/pre-push

# Run integration tests
echo "Running integration tests before push..."
npm run test:integration

if [ $? -ne 0 ]; then
    echo "❌ Integration tests failed. Push aborted."
    exit 1
fi

# Check if pushing to protected branch
protected_branch='main'
current_branch=$(git rev-parse --abbrev-ref HEAD)

if [ $protected_branch = $current_branch ]; then
    echo "❌ Direct push to main branch is not allowed!"
    echo "Please create a pull request instead."
    exit 1
fi

echo "✅ Pre-push checks passed"
```

---

## 🖥️ Server-Side Hooks (Git Server/Repository)

### **1. pre-receive**
**When:** Before any refs are updated on server
**Purpose:** Global validation before accepting push

```bash
#!/bin/bash
# hooks/pre-receive

# Read all ref updates
while read oldrev newrev refname; do
    # Prevent force pushes to main
    if [[ $refname == "refs/heads/main" ]]; then
        if git merge-base --is-ancestor $newrev $oldrev; then
            echo "❌ Force push to main branch is not allowed!"
            exit 1
        fi
    fi
    
    # Check for large files
    git rev-list $oldrev..$newrev | while read commit; do
        git diff-tree --no-commit-id --name-only -r $commit | while read file; do
            size=$(git cat-file -s "$commit:$file" 2>/dev/null || echo 0)
            if [ $size -gt 10485760 ]; then  # 10MB
                echo "❌ File $file is too large ($size bytes)"
                exit 1
            fi
        done
    done
done
```

### **2. update**
**When:** Before each ref is updated
**Purpose:** Per-branch validation

```bash
#!/bin/bash
# hooks/update

refname="$1"
oldrev="$2"
newrev="$3"

# Allow only certain users to push to main
if [[ $refname == "refs/heads/main" ]]; then
    if [[ $USER != "admin" && $USER != "ci-user" ]]; then
        echo "❌ Only admins can push to main branch"
        exit 1
    fi
fi

# Enforce branch naming convention
if [[ $refname =~ refs/heads/(feature|bugfix|hotfix)/.+ ]]; then
    echo "✅ Branch name follows convention"
else
    echo "❌ Branch must start with feature/, bugfix/, or hotfix/"
    exit 1
fi
```

### **3. post-receive**
**When:** After all refs are updated
**Purpose:** Trigger deployments, notifications

```bash
#!/bin/bash
# hooks/post-receive

while read oldrev newrev refname; do
    # Deploy when main branch is updated
    if [[ $refname == "refs/heads/main" ]]; then
        echo "🚀 Deploying to production..."
        
        # Trigger deployment pipeline
        curl -X POST \
            -H "Authorization: token $DEPLOY_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"ref":"main","inputs":{"environment":"production"}}' \
            "https://api.github.com/repos/company/project/actions/workflows/deploy.yml/dispatches"
        
        # Send Slack notification
        curl -X POST \
            -H 'Content-type: application/json' \
            --data "{\"text\":\"🚀 New deployment to production from commit $(git rev-parse --short $newrev)\"}" \
            $SLACK_WEBHOOK_URL
    fi
    
    # Auto-create release tags
    if [[ $refname == "refs/heads/main" ]]; then
        VERSION=$(date +%Y.%m.%d)
        git tag "release-$VERSION" $newrev
        echo "Created release tag: release-$VERSION"
    fi
done
```

### **4. post-update**
**When:** After refs are updated (similar to post-receive)
**Purpose:** Repository maintenance, mirroring

```bash
#!/bin/bash
# hooks/post-update

# Update git info for web interfaces
git update-server-info

# Mirror to backup repository
git push --mirror backup-origin

# Generate documentation
if [[ -f "docs/generate.sh" ]]; then
    ./docs/generate.sh
    git add docs/
    git commit -m "Auto-update documentation"
fi

echo "Repository maintenance completed"
```

---

## 🎯 Powerful Real-World Hook Examples

### **1. Automated Code Quality Pipeline**

```bash
#!/bin/bash
# .git/hooks/pre-commit
# Comprehensive code quality checks

set -e  # Exit on any error

echo "🔍 Running pre-commit checks..."

# 1. Check for merge conflict markers
if grep -r "<<<<<<< \|======= \|>>>>>>> " --include="*.js" --include="*.ts" --include="*.py" .; then
    echo "❌ Merge conflict markers found!"
    exit 1
fi

# 2. Check for debugging statements
if grep -r "console.log\|debugger\|pdb.set_trace" --include="*.js" --include="*.ts" --include="*.py" .; then
    echo "❌ Debugging statements found!"
    exit 1
fi

# 3. Check for secrets
if grep -r "password\|secret\|token" --include="*.js" --include="*.ts" --include="*.py" . | grep -v "# pragma: allowlist secret"; then
    echo "❌ Potential secrets found!"
    exit 1
fi

# 4. Run linting
echo "📋 Running linter..."
npm run lint

# 5. Run tests
echo "🧪 Running tests..."
npm test

# 6. Check test coverage
echo "📊 Checking test coverage..."
COVERAGE=$(npm run test:coverage | grep "All files" | awk '{print $10}' | sed 's/%//')
if [ "$COVERAGE" -lt 80 ]; then
    echo "❌ Test coverage is below 80% ($COVERAGE%)"
    exit 1
fi

echo "✅ All pre-commit checks passed!"
```

### **2. Automatic Semantic Versioning**

```bash
#!/bin/bash
# hooks/post-receive
# Automatic semantic versioning based on commit messages

while read oldrev newrev refname; do
    if [[ $refname == "refs/heads/main" ]]; then
        # Get current version
        CURRENT_VERSION=$(git tag --sort=-version:refname | head -n1 | sed 's/^v//')
        if [[ -z $CURRENT_VERSION ]]; then
            CURRENT_VERSION="0.0.0"
        fi
        
        # Parse version components
        IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
        MAJOR=${VERSION_PARTS[0]}
        MINOR=${VERSION_PARTS[1]}
        PATCH=${VERSION_PARTS[2]}
        
        # Check commit messages for version bump indicators
        COMMITS=$(git rev-list $oldrev..$newrev --pretty=format:"%s")
        
        if echo "$COMMITS" | grep -q "BREAKING CHANGE\|^feat!"; then
            # Major version bump
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
        elif echo "$COMMITS" | grep -q "^feat"; then
            # Minor version bump
            MINOR=$((MINOR + 1))
            PATCH=0
        else
            # Patch version bump
            PATCH=$((PATCH + 1))
        fi
        
        NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        git tag "v$NEW_VERSION" $newrev
        
        echo "🏷️ Created new version tag: v$NEW_VERSION"
        
        # Update package.json
        if [[ -f "package.json" ]]; then
            sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" package.json
            git add package.json
            git commit -m "chore: bump version to $NEW_VERSION"
        fi
    fi
done
```

### **3. Intelligent Deployment Pipeline**

```bash
#!/bin/bash
# hooks/post-receive
# Smart deployment based on branch and changes

while read oldrev newrev refname; do
    BRANCH=$(echo $refname | sed 's/refs\/heads\///')
    
    case $BRANCH in
        "main")
            echo "🚀 Deploying to production..."
            deploy_to_production $newrev
            send_notification "production" $newrev
            ;;
        "staging")
            echo "🧪 Deploying to staging..."
            deploy_to_staging $newrev
            run_e2e_tests
            ;;
        "develop")
            echo "🔧 Deploying to development..."
            deploy_to_development $newrev
            ;;
        feature/*)
            echo "🌟 Creating preview environment..."
            create_preview_environment $BRANCH $newrev
            ;;
    esac
done

deploy_to_production() {
    local commit=$1
    
    # Build application
    docker build -t app:$commit .
    
    # Run security scan
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy image app:$commit
    
    # Deploy with zero downtime
    kubectl set image deployment/app app=app:$commit
    kubectl rollout status deployment/app
    
    # Run smoke tests
    ./scripts/smoke-tests.sh production
}

send_notification() {
    local environment=$1
    local commit=$2
    local short_commit=$(git rev-parse --short $commit)
    
    # Slack notification
    curl -X POST $SLACK_WEBHOOK \
        -H 'Content-type: application/json' \
        -d "{
            \"text\": \"🚀 Deployed commit $short_commit to $environment\",
            \"attachments\": [{
                \"color\": \"good\",
                \"fields\": [{
                    \"title\": \"Commit\",
                    \"value\": \"$(git log --format='%s' -n 1 $commit)\",
                    \"short\": false
                }]
            }]
        }"
}
```

---

## 🛠️ Hook Management and Best Practices

### **1. Sharing Hooks Across Team**

Since hooks aren't included in git repositories, use these strategies:

#### **Option A: Hooks Directory + Setup Script**
```bash
# Project structure
project/
├── .githooks/          # Custom hooks directory
│   ├── pre-commit
│   ├── commit-msg
│   └── pre-push
├── scripts/
│   └── setup-hooks.sh
└── README.md

# setup-hooks.sh
#!/bin/bash
# Copy hooks to .git/hooks/
cp .githooks/* .git/hooks/
chmod +x .git/hooks/*
echo "✅ Git hooks installed"
```

#### **Option B: Git Config (Git 2.9+)**
```bash
# Set hooks directory
git config core.hooksPath .githooks

# All developers automatically use shared hooks
```

### **2. Hook Templates and Libraries**

#### **Reusable Hook Functions**
```bash
# lib/hook-utils.sh
#!/bin/bash

# Common hook utilities
check_branch_name() {
    local branch=$(git branch --show-current)
    if [[ ! $branch =~ ^(feature|bugfix|hotfix)/.+ ]]; then
        echo "❌ Invalid branch name: $branch"
        echo "Use: feature/description, bugfix/description, or hotfix/description"
        return 1
    fi
}

run_tests() {
    local test_type=$1
    echo "🧪 Running $test_type tests..."
    
    case $test_type in
        "unit")
            npm run test:unit
            ;;
        "integration")
            npm run test:integration
            ;;
        "e2e")
            npm run test:e2e
            ;;
    esac
}

send_webhook() {
    local webhook_url=$1
    local message=$2
    
    curl -X POST -H 'Content-type: application/json' \
        -d "{\"text\": \"$message\"}" \
        "$webhook_url"
}
```

### **3. Hook Configuration Management**

```bash
# .git-hooks-config
#!/bin/bash
# Configuration for git hooks

# Enable/disable specific checks
ENABLE_LINTING=true
ENABLE_TESTING=true
ENABLE_COVERAGE_CHECK=true
MIN_COVERAGE=80

# Notification settings
SLACK_WEBHOOK="https://hooks.slack.com/..."
TEAMS_WEBHOOK="https://outlook.office.com/..."

# Deployment settings
PRODUCTION_BRANCH="main"
STAGING_BRANCH="staging"
DEVELOPMENT_BRANCH="develop"
```

---

## 🎯 Advanced Hook Integration Patterns

### **1. CI/CD Integration**

```bash
#!/bin/bash
# hooks/post-receive
# Trigger CI/CD pipeline

while read oldrev newrev refname; do
    BRANCH=$(echo $refname | sed 's/refs\/heads\///')
    
    # Trigger GitHub Actions
    curl -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"ref\":\"$BRANCH\"}" \
        "https://api.github.com/repos/$REPO/actions/workflows/ci.yml/dispatches"
    
    # Trigger Jenkins build
    curl -X POST \
        -H "Authorization: Bearer $JENKINS_TOKEN" \
        "$JENKINS_URL/job/$JOB_NAME/buildWithParameters?branch=$BRANCH"
    
    # Trigger GitLab pipeline
    curl -X POST \
        -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/projects/$PROJECT_ID/pipeline?ref=$BRANCH"
done
```

### **2. Multi-Environment Workflow**

```bash
#!/bin/bash
# hooks/post-receive
# Environment-specific deployments

deploy_strategy() {
    local branch=$1
    local commit=$2
    
    case $branch in
        "main"|"master")
            # Production deployment
            echo "🚀 Production deployment starting..."
            
            # Run full test suite
            run_test_suite "full"
            
            # Security scan
            run_security_scan $commit
            
            # Blue-green deployment
            deploy_blue_green "production" $commit
            
            # Update monitoring
            update_monitoring_dashboard "production" $commit
            ;;
            
        "staging")
            # Staging deployment
            echo "🧪 Staging deployment starting..."
            
            # Integration tests
            run_test_suite "integration"
            
            # Performance tests
            run_performance_tests $commit
            
            # Standard deployment
            deploy_standard "staging" $commit
            ;;
            
        "develop")
            # Development deployment
            echo "🔧 Development deployment starting..."
            
            # Quick smoke tests
            run_test_suite "smoke"
            
            # Fast deployment
            deploy_fast "development" $commit
            ;;
            
        feature/*)
            # Feature branch - create preview
            echo "🌟 Creating preview environment..."
            
            # Create isolated environment
            create_preview_environment $branch $commit
            
            # Run feature tests
            run_feature_tests $branch
            ;;
    esac
}
```

---

## 🚀 Making Hooks Truly Powerful

### **Why Hooks Become Powerful:**

#### **1. Integration with External Systems**
- **CI/CD Pipelines:** Trigger builds and deployments
- **Code Quality Tools:** SonarQube, CodeClimate integration
- **Communication:** Slack, Teams, email notifications
- **Issue Tracking:** JIRA, GitHub Issues automation
- **Security:** Vulnerability scanning, secret detection

#### **2. Business Logic Implementation**
- **Compliance:** Enforce coding standards and policies
- **Workflow Automation:** Auto-assign reviewers, update tickets
- **Release Management:** Semantic versioning, changelog generation
- **Environment Management:** Auto-create/destroy preview environments

#### **3. Team Workflow Enhancement**
- **Code Quality Gates:** Prevent bad code from entering repository
- **Automated Documentation:** Generate docs from code changes
- **Performance Monitoring:** Track build times, test coverage
- **Dependency Management:** Auto-update dependencies, security patches

---

## 💡 Hook Strategy Recommendations

### **For Small Teams (2-5 developers):**
```bash
# Focus on code quality and basic automation
.git/hooks/
├── pre-commit          # Linting, formatting, basic tests
├── commit-msg          # Commit message validation
└── pre-push           # Integration tests, branch protection
```

### **For Medium Teams (5-20 developers):**
```bash
# Add workflow enforcement and notifications
.git/hooks/
├── pre-commit          # Comprehensive code quality
├── commit-msg          # Strict message format
├── pre-push           # Full test suite, security scans
└── post-receive       # Deployment automation, notifications
```

### **For Large Teams (20+ developers):**
```bash
# Full automation and integration ecosystem
.git/hooks/
├── pre-commit          # Multi-language quality checks
├── prepare-commit-msg  # Auto-populate from branch/tickets
├── commit-msg          # Enforce corporate standards
├── pre-push           # Comprehensive validation
├── pre-receive        # Access control, policy enforcement
├── update             # Per-branch validation rules
├── post-receive       # Full deployment pipeline
└── post-update        # Repository maintenance, mirroring
```

---

## 🎯 Conclusion: From "Weak" to Powerful

### **Why Your Lab Experience Felt Weak:**
- **Limited Scope:** Simple tagging example
- **Manual Execution:** Hooks work best when fully automated
- **No Integration:** Real power comes from connecting to other systems
- **Single Purpose:** Production hooks handle complex workflows

### **How Hooks Become Powerful:**
- **Full Automation:** Zero manual intervention
- **System Integration:** Connect Git to your entire development ecosystem
- **Business Logic:** Implement complex team and project requirements
- **Workflow Enforcement:** Maintain quality and consistency automatically

### **Key Takeaway:**
Git hooks are **infrastructure code** - they're most powerful when they're part of a larger automated development ecosystem, not standalone scripts. The real magic happens when hooks orchestrate complex workflows across multiple systems and enforce team practices automatically.

**Think of hooks as the "nervous system" of your development workflow** - they sense what's happening in Git and automatically trigger appropriate responses across your entire development infrastructure. 🚀

---

*Remember: Great hooks are invisible to developers - they just make everything work better automatically!*