resource "null_resource" "aws_cli" {
    count = var.cloud_provider.aws ? 1 : 0

    provisioner "local-exec" {
        command = "echo AWS"
    }
}

resource "null_resource" "azure_cli" {
    count = var.cloud_provider.azure ? 1 : 0

    provisioner "local-exec" {
        command = "echo AZURE"
    }
}

resource "null_resource" "gcp_cli" {
    count = var.cloud_provider.gcp ? 1 : 0

    provisioner "local-exec" {
        command = "echo GCP"
    }
}