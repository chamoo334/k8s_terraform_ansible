# Update Ansible inventory with AWS EC2 instances
resource "null_resource" "aws_inventory" {
    provisioner "local-exec" {
        command = <<-EOT
cat <<EOF >> ./ansible/inventory.yaml
    aws:
      vars:
        ansible_port: 22
        ansible_user: ec2-user
        ansible_ssh_private_key_file: ${local_file.k8s_key.filename}
      hosts:
        aws_controller:
          ansible_host: ${aws_instance.k8s["controller"].public_ip}
      children:
        aws_workers:
          hosts:%{ for node in local.instances }%{ if node != local.instances[0] }
            aws_${node}:
              ansible_host: ${aws_instance.k8s["${node}"].public_ip}%{ endif }%{ endfor }
EOF
EOT
    }
    
    depends_on = [aws_instance.k8s, local_file.k8s_key]
}

# Create tasks to add worker nodes to cluster and update AWS role
resource "local_file" "aws_worker_tasks" {
    filename = "./ansible/aws_worker_tasks.txt"
    content = <<-EOT
%{ for node in local.instances ~}%{ if node != local.instances[0] }
- name: Add ${node} to AWS Kubernetes cluster
  delegate_to: aws_${node}
  run_once: true
  when: inventory_hostname.startswith('aws_worker')
  shell:
    cmd: "{{ hostvars.aws_controller.aws_kube_join }}"

%{ endif }%{ endfor ~}
EOT

    provisioner "local-exec" {
        command = "sed -i '' '/Execute on workers/r ./ansible/aws_worker_tasks.txt' ./ansible/roles/aws/tasks/main.yaml"
    }

    depends_on = [aws_instance.k8s]
}

resource "null_resource" "clean_ansible_role" {
  provisioner "local-exec" {
        when = destroy
        command = <<-EOT
export line1=$(($(grep -n "name: Configure hosts" ./ansible/roles/aws/tasks/main.yaml | cut -d: -f1)+1));
export line2=$(($(grep -n "name: Install iproute" ./ansible/roles/aws/tasks/main.yaml | cut -d: -f1)-2));
sed -i '' -e "$line1","$line2"d ./ansible/roles/aws/tasks/main.yaml;
export line1=$(($(grep -n "Execute on workers" ./ansible/roles/aws/tasks/main.yaml | cut -d: -f1)+1));
export line2=$(($(grep -n "Check nodes on controller" ./ansible/roles/aws/tasks/main.yaml | cut -d: -f1)-2));
sed -i '' -e "$line1","$line2"d ./ansible/roles/aws/tasks/main.yaml;
unset line1;
unset line2;
EOT
    }

  depends_on = [aws_instance.k8s, local_file.k8s_private_ips, local_file.aws_worker_tasks]
}