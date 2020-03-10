#! bin/bash

#creating storage container to store tfsates
az storage container create -n tfstate --account-name tfstates3 --account-key h8kjUgHgkUPJYg7Y6rXhtY2ZGM59pPLMxrcNkzdlZmdTb0677bsp9p8F7dqR4ZVrM7N8Nz/HtVQ4YNiHSIz/Ww==

terraform init -backend-config="storage_account_name=tfstates3" -backend-config="container_name=tfstate" -backend-config="access_key=h8kjUgHgkUPJYg7Y6rXhtY2ZGM59pPLMxrcNkzdlZmdTb0677bsp9p8F7dqR4ZVrM7N8Nz/HtVQ4YNiHSIz/Ww==" -backend-config="key=codelab.microsoft.tfstate"

export TF_VAR_client_id=55fdafec-ec48-4eba-a16b-1818e58f1978

export TF_VAR_client_secret=FJ?06-tzfUjK75hh.Yzm/O_[M_K.pLF@

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

