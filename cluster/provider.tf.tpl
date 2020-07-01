# the kubeconfig file is written for use with kubectl.
# kubernetes resources via terraform use the cluster auth token
# generated in the stack module.
resource "local_file" "kubeconfig" {
  filename 	      = "${path.module}/kubeconfig"
  content  	      = module.stack.kubeconfig
  file_permission = 0644
}

data "aws_eks_cluster_auth" "this" {
  name = module.stack.name
}

provider "kubernetes" {
  host                   = module.stack.cluster_endpoint
  cluster_ca_certificate = base64decode(module.stack.cluster_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
	  host                   = module.stack.cluster_endpoint
	  cluster_ca_certificate = base64decode(module.stack.cluster_certificate)
	  token                  = data.aws_eks_cluster_auth.this.token
	  load_config_file       = false
  }
}