resource "null_resource" "aws_cli" {
    provisioner "local-exec" {
        command = "echo Inside module: AWS"
    }
}