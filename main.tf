module "aws_k8s" {
    count = var.cloud_provider.aws ? 1 : 0
    source = "./modules/aws"
    ami_id = var.ami_id
    instance_type = var.instance_type
    key_pair_name = var.key_pair_name
}

module "azure_k8s" {
    count = var.cloud_provider.azure ? 1 : 0
    source = "./modules/azure"
}

module "gcp_k8s" {
    count = var.cloud_provider.gcp ? 1 : 0
    source = "./modules/gcp"
}