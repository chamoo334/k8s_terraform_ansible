# Create tasks to add worker nodes to cluster and update AWS role
resource "local_file" "azure_worker_tasks" {
  filename = "./ansible/azure_worker_tasks.txt"
  content  = <<-EOT
%{for node in local.machines~}%{if node != local.machines[0]}
- name: Add ${node} to Azure Kubernetes cluster
  delegate_to: azure_${node}
  run_once: true
  when: inventory_hostname.startswith('azure_worker')
  shell:
    cmd: "{{ hostvars.azure_controller.azure_kube_join }}"

%{endif}%{endfor~}
EOT

  provisioner "local-exec" {
    command = "sed -i '' '/Execute on workers/r ./ansible/azure_worker_tasks.txt' ./ansible/roles/azure/tasks/main.yaml"
  }

  depends_on = [azurerm_linux_virtual_machine.k8s]
}

resource "null_resource" "clean_ansible_role" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
export line1=$(($(grep -n "name: Configure hosts" ./ansible/roles/azure/tasks/main.yaml | cut -d: -f1)+1));
export line2=$(($(grep -n "name: Install iproute" ./ansible/roles/azure/tasks/main.yaml | cut -d: -f1)-2));
sed -i '' -e "$line1","$line2"d ./ansible/roles/azure/tasks/main.yaml;
export line1=$(($(grep -n "Execute on workers" ./ansible/roles/azure/tasks/main.yaml | cut -d: -f1)+1));
export line2=$(($(grep -n "Check nodes on controller" ./ansible/roles/azure/tasks/main.yaml | cut -d: -f1)-2));
sed -i '' -e "$line1","$line2"d ./ansible/roles/azure/tasks/main.yaml;
unset line1;
unset line2;
EOT
  }

  depends_on = [azurerm_linux_virtual_machine.k8s, local_file.k8s_private_ips, local_file.azure_worker_tasks]
}