#! bin/bash

#creating AKS cluster from terraform scripts
terraform plan -out out.plan
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

