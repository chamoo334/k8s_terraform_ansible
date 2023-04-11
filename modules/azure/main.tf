
resource "null_resource" "azure_cli" {

    provisioner "local-exec" {
        command = "echo Inside module: AZURE"
    }
}