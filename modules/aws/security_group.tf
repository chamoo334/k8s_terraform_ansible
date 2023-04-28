# https://kubernetes.io/docs/reference/networking/ports-and-protocols/
# Kubernetes controller security group
resource "aws_security_group" "k8s-controller" {
  name        = "${var.sg_name_prefix}_controller"
  description = "Security group for Kubernetes controller"

  dynamic "ingress" {
    for_each = var.sg_k8s_controller_ingress
    content {
      from_port   = ingress.value.start_port
      to_port     = ingress.value.end_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Kubernetes worker security group
resource "aws_security_group" "k8s-worker" {
  name        = "${var.sg_name_prefix}_worker"
  description = "Security group for Kubernetes controller"

  dynamic "ingress" {
    for_each = var.sg_k8s_worker_ingress
    content {
      from_port   = ingress.value.start_port
      to_port     = ingress.value.end_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}