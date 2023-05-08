import sys # python3 k8s.py local.tfvars

tfvars = sys.argv[1]
cloud_providers = {
    "aws" : None,
    "azure" : None,
    "gcp" : None,
}

lines = None
with open(tfvars) as tf_file:
    for num, line in enumerate(tf_file, 1):
        if "cloud_provider" in line:
            lines = [x for x in range(num + 1, num + 4)]
            break

for i in lines:
    print(i)

print('Terraform variables file:', tfvars)