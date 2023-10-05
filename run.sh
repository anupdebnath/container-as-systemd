#!/bin/bash

# Define the path to your Docker Compose file
compose_file="docker-compose.yml"

# Check if the Docker Compose file exists
if [ ! -f "$compose_file" ]; then
  echo "Docker Compose file ($compose_file) not found."
  exit 1
fi

# Extract the container name from the Docker Compose file
container_name=$(grep -oP "container_name:\s*\K\S+" "$compose_file")

if [ -z "$container_name" ]; then
  echo "Container name not found in the Docker Compose file."
  exit 1
fi

# Define the systemd service name
service_name="container-$container_name"

# Start the container using podman-compose
podman-compose up -d

# Generate podman systemd files
podman generate systemd --new --files --name "$container_name"

# Copy the podman service file to systemd user directory
cp -Z "$service_name.service" ~/.config/systemd/user/

# Reload the systemd user service manager
systemctl --user daemon-reload

# Start the container as a systemd service
systemctl --user start "$service_name.service"

# Check the status of the systemd service
systemctl --user status "$service_name.service"

# Enable the systemd service to start on boot
systemctl --user enable "$service_name.service"

# Check if the service is active and enabled
is_active=$(systemctl --user is-active "$service_name.service")
is_enabled=$(systemctl --user is-enabled "$service_name.service")

# Display status information
echo "Service Active: $is_active"
echo "Service Enabled: $is_enabled"
