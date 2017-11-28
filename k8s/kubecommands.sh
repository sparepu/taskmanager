### Creation of deployment object ######

kubectl create -f ingresscontroller/ingress-nginx.yml #### For adding nginx ingress controller

kubectl create -f <deployment.yml>

kubectl create -f db.yml

kubectl create -f endpoint.yml


##### Scale out #####
kubectl scale deployment <deploymentname> --replicas=<no. of replicas>


#### Container Update #####

kubectl set image deploy/<deploymentname> web=dockerregistry.searchink.com:5000/endpoint:latest1
