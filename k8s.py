import sys, linecache
# python3 k8s.py local.tfvars

tfvars = sys.argv[1]
cloud_providers = {
    'aws' : [
        None,
        [
'    aws = {\n',
'      source  = "hashicorp/aws"\n',
'      version = "~> 4.0"\n',
'    }\n'
        ],
        ['provider "aws" {\n',
        '  region     = var.aws.creds.region\n',
        '  access_key = var.aws.creds.access_key\n',
        '  secret_key = var.aws.creds.secret_key\n',
        '}\n']
    ],
    'azure' : [
        None,
        ['    azurerm = {\n',
        '      source  = "hashicorp/azurerm"\n',
        '      version = "3.51.0"\n',
        '    }\n'],
        ['provider "azurerm" {\n',
        '  subscription_id = var.azure.creds.subscription_id\n',
        '  tenant_id       = var.azure.creds.tenant_id\n',
        '  client_id       = var.azure.creds.client_id\n',
        '  client_secret   = var.azure.creds.client_secret\n',
        '  features {}\n',
        '}\n']
    ],
    'gcp' : [
        None,
        ['    google = {\n',
        '      source  = "hashicorp/google"\n',
        '      version = "4.61.0"\n',
        '    }\n'],
        ['provider "google" {\n',
        '  project     = var.gcp.creds.project\n',
        '  region      = var.gcp.creds.region\n',
        '  zone        = var.gcp.creds.zone\n',
        '  credentials = var.gcp.creds.credentials\n',
        '}\n']
    ]
}

def update_providers():
    with open(tfvars) as tf_file:
        for num, line in enumerate(tf_file, 1):
            if "cloud_provider" in line:
                for line in range(num + 1, num + 4):
                    text = [x.replace(" ", "").strip('\n') for x in linecache.getline(tfvars, line).split("= ")]
                    cloud_providers[text[0]][0] = False if text[1] == 'false' else True 
                break


def create_versions_tf():
    with open('./test_versions.tf', 'x') as tf_file:
        tf_file.write('terraform {\n  required_providers {\n')
        
        for key in cloud_providers:
            if cloud_providers[key][0]:
                tf_file.writelines(cloud_providers[key][1])
        
        tf_file.write('  }\n}')


def create_providers_tf():
    with open('./test_providers.tf', 'x') as tf_file:
        for key in cloud_providers:
            if cloud_providers[key][0]:
                tf_file.writelines(cloud_providers[key][2])


if __name__ == '__main__':
    print('Terraform variables file:', tfvars)
    update_providers()
    create_versions_tf()
    create_providers_tf()

