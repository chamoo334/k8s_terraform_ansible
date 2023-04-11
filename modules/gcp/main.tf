resource "null_resource" "gcp_cli" {

    provisioner "local-exec" {
        command = "echo Inside module: GCP"
    }
}