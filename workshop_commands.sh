#! /bin/bash

# # Demo 1 - building an image
# Building flat image
docker build -t demo:flat -f dockerfiles/dockerfile_app_v1 .

# Building staged image
docker build -t demo:staged -f dockerfiles/dockerfile_app_v2 .

# show differance in image size
docker image ls | grep demo

# Show image layers
docker history demo:flat
docker history demo:staged



# # Demo 2 - images VS containers
# starting 2 containers from the same image
docker run -d --rm --name demo1 demo:staged \
    && docker run -d --rm --name demo2 demo:staged \
    && docker ps

# See base image of both containers
docker container inspect -f "{{ .Image }}" demo1 demo2

# create file inside demo1
docker exec demo1 touch /_demofile

# make sure the file exists
docker exec demo1 ls -l /demofile

# see if the file exists on demo2
docker exec demo2 ls -l /demofile

# cleanup
docker stop demo1 demo2



# # Demo 3 - networking
# list built in networks
docker network ls

# create new user defined bridge network
# defaults (no need to change them in most cases)
# --scope local the network will be available only on the host (overlay will be accessable over a cluster)
# --driver bridge (other options: bridge   ipvlan   macvlan  overlay)
docker network create --subnet 172.16.35.0/24 demo-net

# Connecting container to the network we just created and set it's IP
docker run -p 80:8000 --rm --network demo-net --ip 172.16.35.12  --name demo1 demo:staged

# Connecting to host network
# Note the -p 80:8000 is dropped as ALL the ports exposed in the dockerfile are now exposed
docker run --rm --network host  --name demo1 demo:staged

# go to http://127.0.0.1 (not working, why?)
# go to http://<hostname> or http://<host ip> (working, why?)



# # Demo 4 ports expose
# start container without -p
docker run --rm --network demo-net --ip 172.16.35.12  --name demo1 demo:staged
# go to http://127.0.0.1/productsup (not working, why?)
docker run --rm -it --network demo-net curlimages/curl http://web.domain.local/productsup # and that does

docker ps # the port is there so what's the difference

# Ports that are not exposed with -p will still be available for inter container communication.



# # Demo 5 networking with docker-compose
docker-compose -f docker_compose_files/docker-compose_v1.yml up

# Check alias
docker run --rm -it --network demo-net debian:buster-slim /bin/bash
apt update && apt install iputils-ping -y
ping -c 1 app
ping -c 1 web.domain.local



#  # Demo 6 volumes
# create volume
docker volume create demo-volume

# inspect the volume
docker volume inspect demo-volume

# put a file in the volume
docker run --rm -it --network demo-net --volume demo-volume:/demo debian:buster-slim /bin/bash
df -h # the volume is shown as mount
touch /demo/file-in-volume
echo "volume demo" > /demo/file-in-volume

# file exists in the started container
docker-compose -f docker_compose_files/docker-compose_v2.yml up
docker-compose -f docker_compose_files/docker-compose_v2.yml exec app /bin/bash

# go to http://127.0.0.1 (new page)
