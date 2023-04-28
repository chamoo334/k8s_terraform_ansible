# resource "null_resource" "azure_cli" {
#   count = length(local.sg_controller)
#   provisioner "local-exec" {
#     command = <<-EOT
# echo "${count.index} : ${local.sg_controller[count.index]} : ${var.sg_k8s_controller["${local.sg_controller[count.index]}"].description}"
# EOT
#   }
# }

# resource "null_resource" "azure_info" {
#   provisioner "local-exec" {
#     command = <<-EOT
# echo "length of controller sg: ${local.sg_lengths_1[0]}"
# echo "length of worker sg: ${local.sg_lengths_1[1]}"
# echo "length of controller sg 2: ${length(local.sg_controller)}"
# echo "length of worker sg 2: ${length(local.sg_worker)}"
# EOT
#   }

#   depends_on = [
#     null_resource.azure_cli
#   ]
# }