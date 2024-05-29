#!/bin/bash

#dont enable
#for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

## Dependency install:
cat ACII/installing.txt
#enable before final push commented out for easier testing
#sudo apt-get update
#sudo apt-get install ca-certificates curl
#sudo install -m 0755 -d /etc/apt/keyrings
#sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
#sudo chmod a+r /etc/apt/keyrings/docker.asc

#echo \
#  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#sudo apt-get update

#curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

#sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gzip 

## Checking if docker is installed corectyly and flushing it:
sudo docker run hello-world

sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)

cat ACII/installed.txt

## Creating all folder paths and runing the container:
sudo rm -r ContainerVolumes
mkdir ContainerVolumes
cd ContainerVolumes
mkdir data
mkdir import
mkdir conf
mkdir logs
mkdir scripts
absPath=$(pwd)
cd ..

dockerID1=$(sudo docker run -d --restart always --publish=7474:7474 --publish=7687:7687 --volume=$absPath/data:/data:rw --volume=$absPath/scripts:/var/lib/neo4j/scripts:rw  --volume=$absPath/logs:/logs:rw  --volume=$absPath/conf:/var/lib/neo4j/conf:rw  --volume=$absPath/import:/var/lib/neo4j/import:rw --env NEO4J_AUTH=none --name neo4j neo4j:5.18.0)

## Waiting for start
CONTAINER_NAME="neo4j"
while [[ $(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null) != "true" ]]; 
do
  echo "Waiting for container to start"
  sleep 0.3
  echo "."
  sleep 0.3
  echo ".."
  sleep 0.3
  echo "..."
done
echo "Container has started"

## Changing condfig and finishing up the container:
sudo docker exec -u root neo4j sh -c "mkdir scripts"
sudo docker exec -u root neo4j sh -c "echo 'dbms.security.allow_csv_import_from_file_urls=true' >> conf/neo4j.conf"
sudo docker exec -u root neo4j sh -c "echo 'server.directories.import=/var/lib/neo4j/import' >> conf/neo4j.conf"
sudo docker exec -u root neo4j sh -c "chmod 777 /var/lib/neo4j/scripts/"
cp Scripts/* ContainerVolumes/scripts/

## Waiting for restart:
sudo docker exec -u root neo4j sh -c "neo4j restart"

CONTAINER_NAME="neo4j"
while [[ $(sudo docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null) != "true" ]]; 
do
  echo "Waiting for container to restart"
  sleep 0.3
  echo "."
  sleep 0.3
  echo ".."
  sleep 0.3
  echo "..."
done
echo "Container has been restarted"

## Pulling the database off site:
mkdir TemporaryResources
cd TemporaryResources
#wget "https://drive.usercontent.google.com/download?id=1WOgdyW50iiv2KSQn0JACfOOwmC_KBWbz&export=download&authuser=0&confirm=t&uuid=8b8fd2c8-8990-4604-be1f-c14a0e3467a2&at=APZUnTURu0lxqwuYszinJc1sfxES:171181155254" -O db.gz
gzip -dc db.gz > taxonomy_iw.csv

## Modifying the db csv file:
sed -i '1s/^/source,target\n/' taxonomy_iw.csv
mv taxonomy_iw.csv db.csv

## Puting the db in the container:
sudo docker cp db.csv $dockerID1:/var/lib/neo4j/import
cd ..
#sudo rm -r TemporaryResources
sudo chown 7474:7474 ContainerVolumes/import/db.csv

## Dev:

sudo docker exec -it $dockerID1 bash