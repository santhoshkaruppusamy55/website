#!/bin/bash
set -e
echo "Stopping and removing existing container"

# Find the container ID for my-app-container (including all states)
container_id=$(docker ps -a -q -f name=my-app-container)

if [ -n "$container_id" ]; then
    echo "Found container $container_id, stopping and removing..."
    docker stop $container_id 2>/dev/null || true  # Ignore errors if already stopped
    docker rm -f $container_id  # Force remove
    echo "Container removed successfully."
else
    echo "No container named 'my-app-container' found."
fi