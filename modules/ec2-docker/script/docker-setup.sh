#!/bin/bash

# Docker installer
docker_setup() {
    echo "Setting up Docker..."
    
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    usermod -aG docker ec2-user

    # Install docker-compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

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