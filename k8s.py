import sys, linecache, re
from string import Template
# python3 k8s.py local.tfvars

tfvars = sys.argv[1]
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
    find = Template('module "$provider')
    
    with open(main) as tf_file:
        content = tf_file.readlines()
        
    for i in range(0, cp_len):
        find_r = re.compile('.*' + find.substitute(provider=cp_keys[i])  + '_k8s" {\n')
        start_idx = content.index((list(filter(find_r.match, content))[0]))
        
        try:
            find_r_next = re.compile('.*' + find.substitute(provider=cp_keys[i + 1])  + '_k8s" {\n')
            end_idx = content.index((list(filter(find_r_next.match, content))[0])) - 2
        except:
            find_r_next = re.compile('.*' + '# Create Ansible playbook\n')
            end_idx = content.index((list(filter(find_r_next.match, content))[0])) - 2
 
        if cloud_providers[cp_keys[i]]:
            for j in range(start_idx, end_idx):
                if '#' in content[j]:
                    content[j] = content[j].replace('#', '')

        else:
            for j in range(start_idx, end_idx):
                if '#' not in content[j]:
                    content[j] = '#' + content[j]

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

def confirm_versions_providers_tf():
    prompt = "Confirm the created versions.tf and providers.tf are correct.\nAdd any additional information.\n Are you ready to proceed? (y/n): "
    answer = input(prompt)

    while answer.lower() not in ('y', 'n'):
        answer = input(prompt)

    if answer.lower() == 'y':
        print("Proceeding with Terraform provisioning")
    else:
        print("Exiting...")
        exit()


if __name__ == '__main__':
    print('Terraform variables file:', tfvars)
    read_cloud_providers()
    update_versions_tf()
    update_providers_tf()
    update_main_tf()
    update_outputs_tf()
    confirm_versions_providers_tf()
    print("Run Terraform & Ansible & save output to file")