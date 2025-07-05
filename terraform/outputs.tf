output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = module.vpc.private_subnets
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS cluster's API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID for the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data for the EKS cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "configure_kubectl" {
  description = "Command to configure kubectl for the EKS cluster."
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name}"
}

output "alb_controller_role_arn" {
  description = "The ARN of the IAM role for the ALB Controller."
  value       = module.alb_controller_iam_role.iam_role_arn
}