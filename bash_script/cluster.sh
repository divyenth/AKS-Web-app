#! bin/bash
#creating storage container to store tfsates
az storage container create -n tfstate --account-name tfstat --account-key 0UFxHPF0dsUmDaZNvL4NS0zxBuNWtMBDZrR+zxMxWrujpg5C3g8Ylm7kh0HHrk7oiI2DgPzvsJheaIzxSzs45A==

terraform init -backend-config="storage_account_name=tfstat" -backend-config="container_name=tfstate" -backend-config="access_key=0UFxHPF0dsUmDaZNvL4NS0zxBuNWtMBDZrR+zxMxWrujpg5C3g8Ylm7kh0HHrk7oiI2DgPzvsJheaIzxSzs45A==" -backend-config="key=codelab.microsoft.tfstate"

export TF_VAR_client_id=abca1b85-a1ed-453d-bb39-8686c2929434

export TF_VAR_client_secret=9ydyPAQIr?ruOJK3:pgwZ.IgpuS3b7_b

#creating AKS cluster from terraform scripts
terraform plan -out out.plan
terraform apply out.plan

#setting up kubeconfig
echo "$(terraform output kube_config)" > ./azurek8s
cp azurek8s ~/.kube/config
export KUBECONFIG=~/.kube/config
clear
kubectl get nodes

#creating service and deployments
kubectl apply -f deployment.yaml
sleep 6m

#fetching external ip to expose application
loadbalancer_ip=$(kubectl get service webapp -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl $loadbalancer_ip

kubectl get service webapp -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
