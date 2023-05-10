import sys, linecache, re
from string import Template
import subprocess

tfvars = sys.argv[1]
build = True if len(sys.argv) > 2 else False
upgrade = False if len(sys.argv) > 2 and sys.argv[2] != 'upgrade' else True
cloud_providers = {
    'aws' : None,
    'azure' : None,
    'gcp' : None
}
cp_keys = list(cloud_providers.keys())
cp_len = len(cloud_providers)
versions = 'versions.tf'
providers = './providers.tf'
main = 'main.tf' 
output = 'outputs.tf'

def read_cloud_providers():
    with open(tfvars) as tf_file:
        for num, line in enumerate(tf_file, 1):
            if "cloud_provider" in line:
                for line in range(num + 1, num + 4):
                    text = [x.replace(" ", "").strip('\n') for x in linecache.getline(tfvars, line).split("= ")]
                    cloud_providers[text[0]] = False if text[1] == 'false' else True
                break
    linecache.clearcache()


def write_to_file(filename, content):
    with open(filename, 'w') as f:
        for line in content:
            f.write(line)


def update_versions_tf():
    content = None
    find = Template('$provider = {\n')
    
    with open(versions) as tf_file:
        content = tf_file.readlines()

    for each in cloud_providers:
        find_r = re.compile('.*' + find.substitute(provider='azurerm')) if each == 'azure' else \
                 re.compile('.*' + find.substitute(provider='google')) if each == 'gcp' else \
                 re.compile('.*' + find.substitute(provider=each))
        
        idx = content.index((list(filter(find_r.match, content))[0]))

        if cloud_providers[each]:
            for i in range(idx, idx+4):
                if '#' in content[i]:
                    content[i] = content[i].replace('#', '')

        else:
            for i in range(idx, idx+4):
                if '#' not in content[i]:
                    content[i] = '#' + content[i]
    
    write_to_file(versions, content)


def update_providers_tf():
    content = None
    find = Template('provider "$provider" {\n')
    
    with open(providers) as tf_file:
        content = tf_file.readlines()
    
    for i in range(0, cp_len):
        find_r = re.compile('.*' + find.substitute(provider='azurerm')) if cp_keys[i] == 'azure' else \
                re.compile('.*' + find.substitute(provider='google')) if cp_keys[i] == 'gcp' else \
                re.compile('.*' + find.substitute(provider=cp_keys[i]))
        
        start_idx = content.index((list(filter(find_r.match, content))[0]))
        
        try:
            find_r_next = re.compile('.*' + find.substitute(provider='azurerm')) if cp_keys[i + 1] == 'azure' else \
                re.compile('.*' + find.substitute(provider='google')) if cp_keys[i + 1] == 'gcp' else \
                re.compile('.*' + find.substitute(provider=cp_keys[i + 1]))
            
            end_idx = content.index((list(filter(find_r_next.match, content))[0])) - 2
        except:
            end_idx = len(content) - 1
        
        if cloud_providers[cp_keys[i]]:
            for j in range(start_idx, end_idx):
                if '#' in content[j]:
                    content[j] = content[j].replace('#', '')

        else:
            for j in range(start_idx, end_idx):
                if '#' not in content[j]:
                    content[j] = '#' + content[j]

    write_to_file(providers, content)


def update_main_tf():
    content = None
    find_module = Template('module "$provider')
    # find_inventory = Template('resource "null_resource" "$provider"')
    find_inventory = Template('resource "null_resource" "$provider')
    find_inventory_end = Template('depends_on = \[module.$provider')
    
    with open(main) as tf_file:
        content = tf_file.readlines()
  
    for i in range(0, cp_len):
        find_r_module = re.compile('.*' + find_module.substitute(provider=cp_keys[i])  + '_k8s" {\n')
        start_idx_module = content.index((list(filter(find_r_module.match, content))[0]))

        find_r_inventory = re.compile('.*' + find_inventory.substitute(provider=cp_keys[i]))
        start_idx_inventory = content.index((list(filter(find_r_inventory.match, content))[0]))

        find_r_inventory_end = re.compile('.*' + find_inventory_end.substitute(provider=cp_keys[i]))
        end_idx_inventory = content.index((list(filter(find_r_inventory_end.match, content))[0])) + 2

        try:
            find_r_module_next = re.compile('.*' + find_module.substitute(provider=cp_keys[i + 1])  + '_k8s" {\n')
            end_idx_module = content.index((list(filter(find_r_module_next.match, content))[0])) - 2

        except:
            find_r_module_next = re.compile('.*' + '# Create Ansible playbook\n')
            end_idx_module = content.index((list(filter(find_r_module_next.match, content))[0])) - 2

        if cloud_providers[cp_keys[i]]:
            for j in range(start_idx_module, end_idx_module):
                if '#' in content[j]:
                    content[j] = content[j].replace('#', '')
            
            for k in range(start_idx_inventory, end_idx_inventory):
                if '#' in content[k]:
                    content[k] = content[k].replace('#', '')


        else:
            for j in range(start_idx_module, end_idx_module):
                if '#' not in content[j]:
                    content[j] = '#' + content[j]

            for k in range(start_idx_inventory, end_idx_inventory):
                if '#' not in content[k]:
                    content[k] = '#' + content[k]

    write_to_file(main, content)


def update_outputs_tf():
    content = None
    find = Template('output "$provider') #output "aws_ssh_commands" {

    with open(output) as tf_file:
        content = tf_file.readlines()

    for i in range(0, cp_len):
        find_r = re.compile('.*' + find.substitute(provider=cp_keys[i])  + '_ssh_commands" {\n')
        start_idx = content.index((list(filter(find_r.match, content))[0]))
        
        try:
            find_r_next = re.compile('.*' + find.substitute(provider=cp_keys[i + 1])  + '_ssh_commands" {\n')
            end_idx = content.index((list(filter(find_r_next.match, content))[0])) - 1
        except:
            end_idx = len(content) - 1

        if cloud_providers[cp_keys[i]]:
            for j in range(start_idx, end_idx):
                if '#' in content[j]:
                    content[j] = content[j].replace('#', '')

        else:
            for j in range(start_idx, end_idx):
                if '#' not in content[j]:
                    content[j] = '#' + content[j]

    write_to_file(output, content)


def confirm_updates():
    prompt = "Confirm the updated Terraform files are free from errors.\nNow is the time to add additional resources.\nAre you ready to proceed? (y/n): "
    answer = input(prompt)

    while answer.lower() not in ('y', 'n'):
        answer = input(prompt)

    if answer.lower() == 'y':
        print("Proceeding with Terraform provisioning")
    else:
        print("Exiting...")
        exit()


def run_terraform():
    commands = [
        ['terraform', 'init'],
        ['terraform', 'plan', f'-var-file={tfvars}'],
        ['terraform', 'apply', '-auto-approve', f'-var-file={tfvars}'],
        ['terraform', 'destroy', '-auto-approve', f'-var-file={tfvars}']
    ]

    if build:
        for i in range(0, len(commands)-1):
            if i == 0 and upgrade:
                commands[i].append('-upgrade')

            subprocess.call(commands[i])
    else:
        subprocess.call(commands[-1])


def run_ansible():
    commands = [
        ['export', 'ANSIBLE_ROLES_PATH=./ansible/roles'],
        ['ansible-playbook', '-i=./ansible/inventory.yaml', './ansible/playbook.yaml', '-T=720'], # > ./ansible/plays.log
        ['unset', 'ANSIBLE_ROLES_PATH'],
    ]

    if build:
        for i in range(0, len(commands)-1):
            subprocess.call(commands[i])
    else:
        subprocess.call(commands[-1])


def clean_up():
    all_files = [versions, providers, main, output]

    run_terraform()
    run_ansible()

    for each in all_files:
        content = None

        with open(each) as tf_file:
            content = tf_file.readlines()

        for i in range(0, len(content)):
            if '#' in content[i] and content[i][:2] != '#!':
                content[i] = content[i].replace('#', '')


        write_to_file(each, content)
    pass

if __name__ == '__main__':
    if build:
        print(f'Using Terraform variables file {tfvars} to update versions.tf, providers.tf, main.tf, and outputs.tf')
        # read_cloud_providers()
        # update_versions_tf()
        # update_providers_tf()
        # update_main_tf()
        # update_outputs_tf()
        # confirm_updates()
        run_terraform()
        run_ansible()
    else:
        clean_up()