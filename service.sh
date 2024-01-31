#!/bin/bash

# Check if podman-compose is installed
if ! command -v podman-compose &> /dev/null; then
    echo "Error: podman-compose not found. Please install podman-compose."
    exit 1
fi

# The path to your Docker Compose file
compose_file="docker-compose.yml"

# Check if the Docker Compose file exists
if [ ! -f "$compose_file" ]; then
    echo "Error: Docker Compose file ($compose_file) not found."
    exit 1
fi

# Extract the container name from the Docker Compose file
container_name=$(grep -oP "container_name:\s*\K\S+" "$compose_file")

if [ -z "$container_name" ]; then
    echo "Error: Container name not found in the Docker Compose file."
    exit 1
fi

# Define the systemd service name
service_name="container-$container_name"

# Start the container using podman-compose
if ! podman-compose up -d; then
    echo "Error: Failed to start containers with podman-compose."
    exit 1
fi

# Generate podman systemd files
if ! podman generate systemd --new --files --name "$container_name"; then
    echo "Error: Failed to generate podman systemd files."
    exit 1
fi

# Stop and remove containers created with podman-compose
podman-compose down

# Copy the podman service file to systemd user directory
cp -Z "$service_name.service" ~/.config/systemd/user/

# Reload the systemd user service manager
if ! systemctl --user daemon-reload; then
    echo "Error: Failed to reload the systemd user service manager."
    exit 1
fi

# Start the container as a systemd service
if ! systemctl --user start "$service_name.service"; then
    echo "Error: Failed to start the systemd service."
    exit 1
fi

# Enable the systemd service to start on boot
if ! systemctl --user enable "$service_name.service"; then
    echo "Error: Failed to enable the systemd service to start on boot."
    exit 1
fi

# Display status information
echo "Service Status Information:"
echo "---------------------------"
echo "is_active: $(systemctl --user is-active "$service_name.service")"
echo "is_enabled: $(systemctl --user is-enabled "$service_name.service")"
echo "---------------------------"