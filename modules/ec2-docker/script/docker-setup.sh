#!/bin/bash
set -e
set -x

install_docker() {
    echo "Installing Docker ..."
    sudo yum update -y
    
    sudo yum install -y amazon-linux-extras
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo amazon-linux-extras enable docker

    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
}

install_docker_compose() {
    echo "Installing Docker Compose..."
    
    # Get latest version
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
}

# Docker installer
docker_setup() {
    echo "Setting up Docker..."
    
    DOCKER_HOME="/opt/app/docker"   
    sudo mkdir -p $DOCKER_HOME
    sudo chown -R ec2-user:ec2-user $DOCKER_HOME
    sudo chmod 755 $DOCKER_HOME

    install_docker

    install_docker_compose

    # Health check
    if docker --version && docker-compose --version; then
        echo "Docker and Docker Compose installed successfully."
    else
        echo "Docker installation failed."
        exit 1
    fi
}

# Main Function
main() {
    docker_setup
}

# Execute main function
main "$@"