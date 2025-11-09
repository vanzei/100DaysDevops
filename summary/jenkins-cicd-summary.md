# Jenkins CI/CD - 100 Days DevOps Challenge

## Overview

Jenkins CI/CD was covered in Days 68-82 of the challenge, focusing on continuous integration, automated testing, deployment pipelines, and DevOps automation. This module integrated all previous technologies into automated workflows for reliable software delivery.

## What We Practiced

### Jenkins Fundamentals
- **Jenkins installation** and server configuration
- **Job creation** and pipeline management
- **Plugin ecosystem** and extension management
- **Security configuration** and user management

### Pipeline Development
- **Declarative pipelines** with Jenkinsfile
- **Scripted pipelines** for complex workflows
- **Multibranch pipelines** for Git branch handling
- **Shared libraries** for reusable pipeline code

### Integration & Automation
- **Git integration** for source control
- **Docker integration** for containerized builds
- **Kubernetes deployment** automation
- **Artifact management** and repository integration

### Advanced Features
- **Parameterized builds** and dynamic configurations
- **Parallel execution** and pipeline optimization
- **Quality gates** and automated testing
- **Notifications** and alerting systems

## Key Commands Practiced

### Jenkins Installation & Setup
```bash
# Install Java (Jenkins prerequisite)
sudo yum install java-11-openjdk-devel

# Add Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
sudo yum install jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Initial setup
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Jenkins CLI Operations
```bash
# Download Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# List jobs
java -jar jenkins-cli.jar -s http://localhost:8080/ list-jobs

# Create job
java -jar jenkins-cli.jar -s http://localhost:8080/ create-job my-job < job.xml

# Build job
java -jar jenkins-cli.jar -s http://localhost:8080/ build my-job

# Get build console output
java -jar jenkins-cli.jar -s http://localhost:8080/ console my-job
```

### Pipeline Syntax
```groovy
// Declarative Pipeline
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building application...'
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'kubectl apply -f deployment.yaml'
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed'
        }
        success {
            echo 'Pipeline succeeded'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
```

### Docker Integration
```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.8.4-openjdk-11'
            args '-v $HOME/.m2:/root/.m2'
        }
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    docker.build("my-app:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'kubectl set image deployment/my-app app=my-app:${BUILD_NUMBER}'
            }
        }
    }
}
```

## Technical Topics Covered

### Jenkins Architecture
```text
Jenkins Master
├── Job Configurations
├── Build Queue
├── Build Executors
├── Plugin Manager
└── Security Realm

Jenkins Agents/Slaves
├── Build Execution
├── Workspace Management
├── Tool Installation
└── Artifact Storage

External Systems
├── Source Control (Git)
├── Artifact Repositories
├── Container Registries
└── Deployment Targets
```

### Pipeline Types
```text
Scripted Pipeline:
- Groovy-based DSL
- Full programming capabilities
- Complex logic and loops
- Imperative approach

Declarative Pipeline:
- Simplified syntax
- Structured stages
- Built-in features
- Declarative approach

Multibranch Pipeline:
- Automatic branch detection
- Branch-specific pipelines
- Pull request validation
- GitOps integration
```

### CI/CD Flow
```text
Developer Push ────► Git Repository ────► Webhook ────► Jenkins
        │                       │                       │
        ▼                       ▼                       ▼
   Code Review            Automated Tests         Build Pipeline
        │                       │                       │
        ▼                       ▼                       ▼
   Merge to Main        Quality Gates Pass      Deploy to Staging
        │                       │                       │
        ▼                       ▼                       ▼
   Release Tag          Security Scan           Production Deploy
        │                       │                       │
        ▼                       ▼                       ▼
   Version Bump         Documentation Update    Monitoring Alert
```

### Quality Gates
```groovy
pipeline {
    agent any

    stages {
        stage('Quality Checks') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                        junit 'target/surefire-reports/*.xml'
                    }
                }

                stage('Integration Tests') {
                    steps {
                        sh 'mvn verify'
                    }
                }

                stage('Code Quality') {
                    steps {
                        sh 'mvn sonar:sonar'
                    }
                }

                stage('Security Scan') {
                    steps {
                        sh 'mvn org.owasp:dependency-check-maven:check'
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                allOf {
                    branch 'main'
                    expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
                }
            }
            steps {
                echo 'Deploying to production...'
            }
        }
    }
}
```

## Production Environment Considerations

### Scalability & Performance
- **Master-Agent Architecture**: Distributed build execution
- **Pipeline Parallelization**: Concurrent job execution
- **Resource Management**: CPU, memory, and disk optimization
- **Caching Strategies**: Dependency and artifact caching

### Security & Compliance
- **Authentication**: LDAP, Active Directory integration
- **Authorization**: Role-based access control (RBAC)
- **Credential Management**: Secure storage of secrets
- **Audit Logging**: Compliance and security monitoring

### Reliability & Monitoring
- **Backup Strategies**: Configuration and job backups
- **Monitoring**: Performance metrics and alerting
- **High Availability**: Master failover and redundancy
- **Disaster Recovery**: Backup and restore procedures

### Integration & Ecosystem
- **Plugin Management**: Security updates and compatibility
- **API Integration**: REST API for external systems
- **Webhook Management**: Automated trigger configuration
- **Artifact Management**: Nexus, Artifactory integration

## Real-World Applications

### Complete CI/CD Pipeline
```groovy
pipeline {
    agent none

    environment {
        DOCKER_REGISTRY = 'myregistry.com'
        K8S_NAMESPACE = 'production'
    }

    stages {
        stage('Checkout') {
            agent { label 'build' }
            steps {
                checkout scm
                sh 'git submodule update --init --recursive'
            }
        }

        stage('Build & Test') {
            agent {
                docker {
                    image 'maven:3.8.4-openjdk-11'
                    args '-v $HOME/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn clean compile test-compile'
                sh 'mvn test'
                junit 'target/surefire-reports/*.xml'
            }
            post {
                always {
                    publishCoverage adapters: [jacocoAdapter('target/site/jacoco/jacoco.xml')]
                }
            }
        }

        stage('Security Scan') {
            agent { label 'security' }
            steps {
                sh 'mvn org.owasp:dependency-check-maven:check'
                sh 'trivy filesystem --exit-code 1 --no-progress --format json .'
            }
        }

        stage('Build Docker Image') {
            agent { label 'docker' }
            steps {
                script {
                    def appImage = docker.build("${DOCKER_REGISTRY}/my-app:${env.BUILD_NUMBER}")
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'registry-credentials') {
                        appImage.push()
                        appImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            agent { label 'deploy' }
            steps {
                script {
                    kubernetesDeploy(
                        configs: 'k8s/staging/*.yaml',
                        kubeconfigId: 'kubeconfig-staging'
                    )
                }
            }
        }

        stage('Integration Tests') {
            agent { label 'test' }
            steps {
                sh 'npm install -g newman'
                sh 'newman run postman_collection.json --environment staging_env.json'
            }
        }

        stage('Deploy to Production') {
            agent { label 'deploy' }
            when {
                allOf {
                    branch 'main'
                    expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
                }
            }
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Deploy to Production?', ok: 'Deploy'
                }
                script {
                    kubernetesDeploy(
                        configs: 'k8s/production/*.yaml',
                        kubeconfigId: 'kubeconfig-prod'
                    )
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up resources
                sh 'docker system prune -f'

                // Send notifications
                emailext(
                    subject: "${currentBuild.currentResult}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: "${env.JOB_NAME} #${env.BUILD_NUMBER} - ${currentBuild.currentResult}",
                    recipientProviders: [developers(), requestor()]
                )
            }
        }

        success {
            script {
                // Update version in Git
                sh 'git tag -a v${BUILD_NUMBER} -m "Release version ${BUILD_NUMBER}"'
                sh 'git push origin v${BUILD_NUMBER}'
            }
        }

        failure {
            script {
                // Rollback on failure
                sh 'kubectl rollout undo deployment/my-app -n ${K8S_NAMESPACE}'
            }
        }
    }
}
```

### Shared Library Example
```groovy
// vars/deployToK8s.groovy
def call(Map config = [:]) {
    def namespace = config.namespace ?: 'default'
    def manifests = config.manifests ?: 'k8s/*.yaml'
    def credentials = config.credentials ?: 'kubeconfig'

    withKubeConfig([credentialsId: credentials, serverUrl: 'https://kubernetes.default.svc']) {
        sh "kubectl apply -f ${manifests} -n ${namespace}"
        sh "kubectl rollout status deployment/my-app -n ${namespace} --timeout=300s"
    }
}

// Jenkinsfile usage
@Library('my-shared-library') _

pipeline {
    agent any

    stages {
        stage('Deploy') {
            steps {
                deployToK8s(
                    namespace: 'production',
                    manifests: 'k8s/production/*.yaml',
                    credentials: 'prod-kubeconfig'
                )
            }
        }
    }
}
```

### Blue-Green Deployment
```groovy
pipeline {
    agent any

    environment {
        BLUE_DEPLOYMENT = 'my-app-blue'
        GREEN_DEPLOYMENT = 'my-app-green'
        SERVICE = 'my-app-service'
    }

    stages {
        stage('Determine Active Deployment') {
            steps {
                script {
                    def activeDeployment = sh(
                        script: "kubectl get service ${SERVICE} -o jsonpath='{.spec.selector.version}'",
                        returnStdout: true
                    ).trim()

                    if (activeDeployment == 'blue') {
                        env.INACTIVE_DEPLOYMENT = GREEN_DEPLOYMENT
                        env.ACTIVE_VERSION = 'blue'
                        env.INACTIVE_VERSION = 'green'
                    } else {
                        env.INACTIVE_DEPLOYMENT = BLUE_DEPLOYMENT
                        env.ACTIVE_VERSION = 'green'
                        env.INACTIVE_VERSION = 'blue'
                    }
                }
            }
        }

        stage('Deploy to Inactive') {
            steps {
                script {
                    // Update deployment image
                    sh "kubectl set image deployment/${INACTIVE_DEPLOYMENT} app=my-app:${BUILD_NUMBER}"

                    // Wait for rollout
                    sh "kubectl rollout status deployment/${INACTIVE_DEPLOYMENT} --timeout=300s"

                    // Run smoke tests
                    sh "kubectl run smoke-test --image=busybox --rm -it --restart=Never -- wget -O- http://my-app-service/health"
                }
            }
        }

        stage('Switch Traffic') {
            steps {
                script {
                    // Switch service selector
                    sh "kubectl patch service ${SERVICE} -p '{\"spec\":{\"selector\":{\"version\":\"${INACTIVE_VERSION}\"}}}'"

                    // Verify deployment
                    sh "kubectl run verify-deployment --image=busybox --rm -it --restart=Never -- wget -O- http://my-app-service | grep 'version ${INACTIVE_VERSION}'"
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Scale down old deployment
                    sh "kubectl scale deployment ${ACTIVE_DEPLOYMENT} --replicas=0"
                }
            }
        }
    }
}
```

## Troubleshooting Common Issues

### Build Failures
```bash
# Check Jenkins logs
sudo journalctl -u jenkins -f

# Check job console output
# Via Jenkins UI or CLI

# Debug pipeline syntax
# Use Pipeline Syntax tool in Jenkins

# Check agent connectivity
java -jar jenkins-cli.jar -s http://localhost:8080/ list-masters
```

### Performance Issues
```bash
# Monitor system resources
top
df -h
free -h

# Check Jenkins metrics
curl http://localhost:8080/metrics

# Analyze build queue
java -jar jenkins-cli.jar -s http://localhost:8080/ list-queue
```

### Plugin Issues
```bash
# List installed plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins

# Update plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin plugin-name

# Check plugin compatibility
# Jenkins Plugin Manager UI
```

### Security Issues
```bash
# Check user permissions
java -jar jenkins-cli.jar -s http://localhost:8080/ list-users

# Audit security settings
# Jenkins Security configuration

# Check credential usage
# Jenkins Credential Manager
```

## Key Takeaways

1. **Automation First**: Automate everything from build to deployment
2. **Quality Gates**: Never compromise on testing and security
3. **Incremental Delivery**: Small, frequent releases over big deployments
4. **Monitoring**: Comprehensive visibility into pipeline health
5. **Security**: Secure credentials, access controls, and audit trails

## Next Steps

- **Jenkins X**: Next-generation Jenkins with GitOps
- **GitHub Actions**: Cloud-native CI/CD alternatives
- **ArgoCD**: Declarative GitOps deployments
- **Tekton**: Kubernetes-native CI/CD pipelines
- **Pipeline as Code**: Infrastructure as Code for CI/CD

Jenkins remains the cornerstone of CI/CD automation, enabling teams to deliver software faster, more reliably, and with higher quality through comprehensive automation pipelines.