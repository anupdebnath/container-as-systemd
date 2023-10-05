#!/bin/bash

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
echo "Starting the container using podman-compose..."
podman-compose up -d

# Generate podman systemd files
echo "Generating podman systemd files..."
podman generate systemd --new --files --name "$container_name"

# Stop and remove containers created with podman-compose
echo "Stopping and removing containers created with podman-compose..."
podman-compose down

# Copy the podman service file to systemd user directory
echo "Copying the podman service file to systemd user directory..."
cp -Z "$service_name.service" ~/.config/systemd/user/

# Reload the systemd user service manager
echo "Reloading the systemd user service manager..."
systemctl --user daemon-reload

# Start the container as a systemd service
echo "Starting the container as a systemd service..."
systemctl --user start "$service_name.service"

# Enable the systemd service to start on boot
echo "Enabling the systemd service to start on boot..."
systemctl --user enable "$service_name.service"

# Display status information
echo "Service Status Information:"
echo "---------------------------"
echo "is_active: $(systemctl --user is-active "$service_name.service")"
echo "is_enabled: $(systemctl --user is-enabled "$service_name.service")"
echo "---------------------------"