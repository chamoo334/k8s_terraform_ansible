# https://kubernetes.io/docs/reference/networking/ports-and-protocols/
resource "aws_security_group" "k8s-controller" {
    name = var.sg_name
    description = "Security group for Kubernetes controller"

    dynamic "ingress" {
        for_each = var.sg_k8s_controller_ingress
        content {
            from_port = ingress.value.port
            to_port = ingress.value.port
            protocol = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
            # description = ingress.description
        }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# resource "aws_security_group" "k8s-worker" {
#     name = var.sg_name
#     description = "Security group for Kubernetes controller"

#     ingress {
#         from_port   = 22
#         to_port     = 22
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
# }