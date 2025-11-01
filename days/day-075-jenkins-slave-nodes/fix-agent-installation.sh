#!/bin/bash

# Jenkins Slave Agent Installation Fix Script
# This script fixes the common issues with Jenkins agent installation

echo "=== Jenkins Slave Agent Installation Fix ==="

# Function to install agent on each server
install_agent() {
    local server_host=$1
    local username=$2
    local jenkins_dir=$3
    local node_name=$4
    
    echo "Installing agent on ${server_host} for user ${username}..."
    
    # SSH to the server and set up the agent
    ssh ${username}@${server_host} << EOF
        # Create jenkins directory
        mkdir -p ${jenkins_dir}
        cd ${jenkins_dir}
        
        # Download agent jar with correct URL
        # Replace YOUR_JENKINS_URL with actual Jenkins server URL
        curl -sO http://jenkins-server:8080/jnlpJars/agent.jar
        
        # Alternative download method if above fails
        if [ ! -f agent.jar ]; then
            wget http://jenkins-server:8080/jnlpJars/agent.jar
        fi
        
        # Verify download
        if [ -f agent.jar ]; then
            echo "✓ Agent jar downloaded successfully"
            ls -la agent.jar
        else
            echo "✗ Failed to download agent jar"
            exit 1
        fi
        
        # Set permissions
        chmod 644 agent.jar
        
        echo "Agent setup completed for ${node_name}"
EOF
}

# Install Java on app servers if needed
install_java() {
    local server_host=$1
    local username=$2
    
    echo "Checking Java installation on ${server_host}..."
    
    ssh ${username}@${server_host} << 'EOF'
        if ! command -v java &> /dev/null; then
            echo "Installing Java..."
            # For CentOS/RHEL
            if command -v yum &> /dev/null; then
                sudo yum install java-11-openjdk -y
            # For Ubuntu/Debian  
            elif command -v apt &> /dev/null; then
                sudo apt update && sudo apt install openjdk-11-jdk -y
            fi
        else
            echo "✓ Java is already installed: $(java -version 2>&1 | head -n1)"
        fi
EOF
}

# Main installation process
echo "Installing Jenkins agents on all app servers..."

# App Server 1
echo "--- Setting up App Server 1 (stapp01) ---"
install_java stapp01 tony
install_agent stapp01 tony /home/tony/jenkins App_server_1

# App Server 2  
echo "--- Setting up App Server 2 (stapp02) ---"
install_java stapp02 steve
install_agent stapp02 steve /home/steve/jenkins App_server_2

# App Server 3
echo "--- Setting up App Server 3 (stapp03) ---"
install_java stapp03 banner
install_agent stapp03 banner /home/banner/jenkins App_server_3

echo "=== Agent installation completed ==="
echo ""
echo "Next steps:"
echo "1. Configure the slave nodes in Jenkins UI"
echo "2. Use the correct agent command from Jenkins node page"
echo "3. Example correct command format:"
echo "   java -jar agent.jar -url http://jenkins-server:8080/ -secret YOUR_SECRET -name 'App_server_1' -workDir '/home/tony/jenkins'"