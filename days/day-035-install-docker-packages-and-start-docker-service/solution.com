# Update system
sudo dnf update -y

# Install dependencies
sudo dnf install -y dnf-utils device-mapper-persistent-data lvm2

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# Install Docker Compose plugin
sudo dnf install -y docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker compose version
sudo docker run hello-world

# Check service status
sudo systemctl status docker