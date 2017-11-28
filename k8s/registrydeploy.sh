#!/bin/bash
#### Prepare docker registry volume ######
mkdir -p /opt/registry/data
mkdir -p /opt/registry/auth
mkdir -p /opt/registry/cert

#### Run docker registry container to capture registry credentials ######
docker run --entrypoint htpasswd registry:2 -Bbn admin $1 > /opt/registry/auth/htpasswd

#### Stop and delete docker container ########
x=`docker ps -a | grep -v IMAGE | awk '{print $1}'`
docker stop $x; docker rm $x

###### Create self-signed certificate for registry,  #######
openssl req -newkey rsa:4096 -nodes -sha256 -keyout /opt/registry/cert/domain.key -x509 -days 365 -subj '/emailAddress=it@searchink.com/C=DE/ST=Berlin/L=Berlin/O=SearchInk/OU=IT/CN=dockerregistry.searchink.com' -out /opt/registry/cert/domain.crt

###### Create docker container #########
docker-compose -f k8s/dockerregistry.yml up -d && docker ps

##### Build jar files and create docker images #######
rm -rf endpoints/target; rm -rf scheduler/target
sed -i "" 's/localhost/${DBHOST}/' endpoints/src/main/resources/application.properties
sed -i "" 's/localhost/${DBHOST}/' scheduler/src/main/resources/application.properties
mvn clean install -Pweb; mvn eclipse:clean eclipse:eclipse -Pweb
mvn clean install -Pscheduler; mvn eclipse:clean eclipse:eclipse -Pscheduler
docker build -t dockerregistry.searchink.com:5000/postgres:taskmanager -f dockerfiles/postgres/Dockerfile .
docker build -t dockerregistry.searchink.com:5000/endpoint:latest -f dockerfiles/endpoint/Dockerfile .
docker build -t dockerregistry.searchink.com:5000/scheduler:latest -f dockerfiles/scheduler/Dockerfile .


#### Push Docker images to registry ########

docker login dockerregistry.searchink.com:5000  -u admin -p $1
docker push dockerregistry.searchink.com:5000/postgres:taskmanager
docker push dockerregistry.searchink.com:5000/endpoint:latest
docker push dockerregistry.searchink.com:5000/scheduler:latest

kubectl get secret dockerregistrysi
if [ $? -eq 0 ]
then
kubectl delete secret dockerregistrysi
kubectl create secret docker-registry dockerregistrysi --docker-server=dockerregistry.searchink.com:5000 --docker-username=admin --docker-password=$1 --docker-email=it@searchink.com
else
kubectl create secret docker-registry dockerregistrysi --docker-server=dockerregistry.searchink.com:5000 --docker-username=admin --docker-password=$1 --docker-email=it@searchink.com
fi
