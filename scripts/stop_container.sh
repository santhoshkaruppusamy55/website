set -e
container_id=$(docker ps -q)
docker rm -f $container_id