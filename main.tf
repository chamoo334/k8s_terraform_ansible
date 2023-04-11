module "aws_k8s" {
    count = var.cloud_provider.aws ? 1 : 0
    source = "./modules/aws"
}

module "azure_k8s" {
    count = var.cloud_provider.azure ? 1 : 0
    source = "./modules/azure"
}

module "gcp_k8s" {
    count = var.cloud_provider.gcp ? 1 : 0
    source = "./modules/gcp"
}