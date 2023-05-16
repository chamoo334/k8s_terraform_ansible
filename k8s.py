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
ansible = 'ansible.tf'
outputs = 'outputs.tf'

def read_cloud_providers():
    '''Purpose:'''
    with open(tfvars) as tf_file:
        for num, line in enumerate(tf_file, 1):
            if "cloud_provider" in line:
                for line in range(num + 1, num + 4):
                    text = [x.replace(" ", "").strip('\n') for x in linecache.getline(tfvars, line).split("= ")]
                    cloud_providers[text[0]] = False if text[1] == 'false' else True
                break
    linecache.clearcache()


def read_file(filename):
    '''Purpose:'''
    lines = None
    
    with open(filename) as f:
        lines = f.readlines()
    
    return lines


def write_to_file(filename, content):
    '''Purpose:'''
    with open(filename, 'w') as f:
        for line in content:
            f.write(line)

def remove_comments(content):
    '''Purpose:'''
    for i in range(0, len(content)):
        if '#' in content[i] and content[i][:2] != '#!':
            content[i] = content[i].replace('#', '')


def update_versions_tf():
    '''Purpose:'''
    content = read_file(versions)
    find = Template('$provider = {\n')
    
    if build:
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
    else:
        remove_comments(content)
    
    write_to_file(versions, content)


def update_providers_tf():
    '''Purpose:'''
    content = read_file(providers)
    find = Template('provider "$provider" {\n')
    
    if build:
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
                end_idx = len(content)
            
            if cloud_providers[cp_keys[i]]:
                for j in range(start_idx, end_idx):
                    if '#' in content[j]:
                        content[j] = content[j].replace('#', '')

            else:
                for j in range(start_idx, end_idx):
                    if '#' not in content[j]:
                        content[j] = '#' + content[j]
    else:
        remove_comments(content)
    
    write_to_file(providers, content)


def update_main_tf():
    '''Purpose:'''
    content = read_file(main)
    find_module = Template('module "$provider')
    find_inventory = Template('resource "null_resource" "$provider')
    find_inventory_end = Template('depends_on = \[module.$provider')
  
    # Adjust modules and null_resources based on cloud_providers
    for i in range(0, cp_len):
        find_r_module = re.compile('.*' + find_module.substitute(provider=cp_keys[i])  + '_k8s" {\n')
        start_idx_module = content.index((list(filter(find_r_module.match, content))[0]))

        find_r_inventory = re.compile('.*' + find_inventory.substitute(provider=cp_keys[i]))
        start_idx_inventory = content.index((list(filter(find_r_inventory.match, content))[0]))

        find_r_inventory_end = re.compile('.*' + find_inventory_end.substitute(provider=cp_keys[i]))
        end_idx_inventory = content.index((list(filter(find_r_inventory_end.match, content))[0])) + 2
        depends_idx = end_idx_inventory - 2

        try:
            find_r_module_next = re.compile('.*' + find_module.substitute(provider=cp_keys[i + 1])  + '_k8s" {\n')
            end_idx_module = content.index((list(filter(find_r_module_next.match, content))[0])) - 2
        except:
            find_r_module_next = re.compile('.*' + '#! Add AWS hosts to Ansible inventory\n')
            end_idx_module = content.index((list(filter(find_r_module_next.match, content))[0])) - 1

        if build: 
    
            if cloud_providers[cp_keys[i]]: # Remove commented lines & update dependencies for used modules and resources
                add_depend = [f', null_resource.{x}_inventory' for x in cp_keys if x != cp_keys[i] and cloud_providers[x] and cp_keys.index(x) < i]
                
                if len(add_depend) >= 1:
                    update = content[depends_idx][:-3] +''.join(add_depend) + ']\n'
                    content[depends_idx] = update

                for j in range(start_idx_module, end_idx_module):
                    if '#' in content[j]:
                        content[j] = content[j].replace('#', '')
                
                for k in range(start_idx_inventory, end_idx_inventory):
                    if '#' in content[k]:
                        content[k] = content[k].replace('#', '')

            else: # Comment provider modules and null resources
                for j in range(start_idx_module, end_idx_module):
                    if '#' not in content[j]:
                        content[j] = '#' + content[j]

                for k in range(start_idx_inventory, end_idx_inventory):
                    if '#' not in content[k]:
                        content[k] = '#' + content[k]
        
        else:
            if cloud_providers[cp_keys[i]]: # remove non provider related dependencies and comments
                content[depends_idx] = f'  depends_on = [module.{cp_keys[i]}_k8s]\n'
            
            remove_comments(content)

    write_to_file(main, content)


def update_ansible_tf():
    '''Purpose:'''
    content = read_file(ansible)
    update_depends = f'    depends_on = ['
    
    for i in cp_keys:
        if cloud_providers[i]:
            update_depends += f'null_resource.{i}_inventory, '
    
    update_depends = update_depends[:-2] + ']\n' 
    find_r_add_inventory = re.compile('.*' + '    depends_on = \[\]\n') if build else None
    add_inventory_idx = content.index((list(filter(find_r_add_inventory.match, content))[0])) if build else content.index(update_depends)
    content[add_inventory_idx] = update_depends if build else '    depends_on = []\n'

    write_to_file(ansible, content)


def update_outputs_tf():
    '''Purpose:'''
    content = read_file(outputs)
    find = Template('output "$provider')

    if build:
        for i in range(0, cp_len):
            find_r = re.compile('.*' + find.substitute(provider=cp_keys[i])  + '_ssh_commands" {\n')
            start_idx = content.index((list(filter(find_r.match, content))[0]))
            
            try:
                find_r_next = re.compile('.*' + find.substitute(provider=cp_keys[i + 1])  + '_ssh_commands" {\n')
                end_idx = content.index((list(filter(find_r_next.match, content))[0])) - 1
            except:
                end_idx = len(content)

            if cloud_providers[cp_keys[i]]:
                for j in range(start_idx, end_idx):
                    if '#' in content[j]:
                        content[j] = content[j].replace('#', '')

            else:
                for j in range(start_idx, end_idx):
                    if '#' not in content[j]:
                        content[j] = '#' + content[j]
    else:
        remove_comments(content)
    
    write_to_file(outputs, content)


def confirm_updates():
    '''Purpose:'''
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
    '''Purpose:'''
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
    '''Purpose:'''
    commands = [
        ['ansible-playbook', '-i=./ansible/inventory.yaml', './ansible/playbook.yaml', '-T=720'], # > ./ansible/plays.log
    ]

    if build:
        subprocess.call(commands[0])


def main():
    read_cloud_providers()
    update_versions_tf()
    update_providers_tf()
    update_main_tf()
    update_ansible_tf()
    update_outputs_tf()
    confirm_updates()
    run_terraform()
    run_ansible()

if __name__ == '__main__':
    print(f'Using Terraform variables file {tfvars} to update versions.tf, providers.tf, main.tf, ansible.tf, and outputs.tf')
    main()