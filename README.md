# Podman Container Service as Systemd Configuration Script

This script automates the process of configuring a podman container to start automatically as a systemd service. It uses podman to manage containers and systemd to manage the service.

## Usage

1. Open terminal and navigate to the directory where container is located.
2. Download or copy the `run.sh`.
3. Make the script executable if it's not already:
   ```
   chmod +x run.sh
   ./run.sh
   ```
   Learn more about how to [Configure a container to start automatically as a systemd service](https://www.redhat.com/sysadmin/container-systemd-persist-reboot)
