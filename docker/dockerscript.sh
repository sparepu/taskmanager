#!/bin/bash
display_usage() { 
echo "Password for docker registry should be provided as argument"
echo -e "\nUsage:\n $0 <passwordfordockerregistry> \n" 
} 
if [  $# -le 1 ] 
then 
display_usage
exit 1
fi 

./k8s/registrydeploy.sh $1

docker-compose -f dockerservices.yml up -d
