#! bin/bash

#Initializing terraform
terraform init -backend-config="storage_account_name=tfstat" -backend-config="container_name=tfstate" -backend-config="access_key=0UFxHPF0dsUmDaZNvL4NS0zxBuNWtMBDZrR+zxMxWrujpg5C3g8Ylm7kh0HHrk7oiI2DgPzvsJheaIzxSzs45A==" -backend-config="key=codelab.microsoft.tfstate"

#Creating terraform plan
terraform plan -out out.plan
#Creating the cluster
terraform apply out.plan

#setting up kubeconfig
az aks get-credentials --name k8stest --resource-group azure-k8stest --admin -a --file ~/.kube/config
export KUBECONFIG=~/.kube/config

#check status of created nodes
kubectl get nodes

#creating service and deployments
kubectl apply -f deployment.yaml

#wait until external ip is generated
loadbalancer_ip=""
while :
do
  if [$loadbalancer_ip == ""]
  then
    sleep 30
    loadbalancer_ip=$(kubectl get service webapp -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  else
    break
  fi
done

#Testing if application is running

curl $loadbalancer_ip

