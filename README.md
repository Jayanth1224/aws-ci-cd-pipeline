# AWS EKS & ArgoCD GitOps Pipeline
This project deploys an NGINX application on an AWS EKS cluster using Terraform for infrastructure and ArgoCD for GitOps deployments.

## Prerequisites

- AWS CLI (configured)
- Terraform
- kubectl
- Helm
- Git

## 1. Provision Infrastructure

Navigate to the terraform directory
```
cd terraform
```
Create your own .tfvars file with 'iam_user_arn' & 'iam_username' in the terraform directory.

Initialize and apply
```
 terraform init 
 terraform apply -auto-approve -var-file=terraform.tfvars

```
You don't need to login to console if you can access the kubernetes cluster if you see nodes when you type kubectl get nodes command otherwise do this and continue.

Login to aws console using the IAM user credentials and create an access entry in the EKS cluster dashboard.
  1. Amazon Elastic Kubernetes Service > Clusters > my-devops-cluster (cluster_name) > Create access entry
  2. Enter IAM Principal ARN (search IAM User name) and choose Type Standard and click next.
  3. Policy Name: AmazonEKSClusterAdminPolicy, access_scope: cluster and click add policy
  4. Click next and create

Configure kubectl
```
aws eks --region us-east-1 update-kubeconfig --name my-devops-cluster
```
Verify connection
```
kubectl get nodes
```

## 2. Install ArgoCD & Deploy Application# Install ArgoCD
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
Update `repoURL` in argocd/application.yaml to your forked repo URL

Deploy the ArgoCD application controller
```
kubectl apply -f argocd/application.yaml
```
Access ArgoCD UI:
```
- Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
- Forward Port: kubectl port-forward svc/argocd-server -n argocd 8080:443
```
- URL: https://localhost:8080 (user: admin)

## 3. Install Ingress Controller
Add Helm repo
```
helm repo add eks https://aws.github.io/eks-charts && helm repo update
```

Get IAM Role ARN from Terraform output

- IAM_ROLE_ARN=$(terraform -C terraform/ output -raw alb_controller_role_arn)

Install controller
```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-devops-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$IAM_ROLE_ARN
```
  
## 4. Access NGINX Publicly
The ingress.yaml will be deployed automatically by ArgoCD.

Get the public URL (wait 2-3 mins for ADDRESS to appear)
```
kubectl get ingress nginx-ingress
```

Copy the address from the output and paste it into your browser.
## 5. Cleanup
```
cd terraform
terraform destroy -auto-approve
```
