#!/bin/bash
set -e
echo "Stopping existing container"
container_id=$(docker ps -q -f name=my-app-container)
if [ -n "$container_id" ]; then
    docker stop $container_id
    docker rm -f $container_id
fi