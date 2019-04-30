# Prerequisites
- Create service principal

```az ad sp create-for-rbac --name packer-test```

- Install [packer](https://www.packer.io/intro/getting-started/install.html)
- Install [ansible](https://docs.ansible.com/ansible/2.4/intro_installation.html)


# Export Environment Variables
```
export PACKER_IMAGE_RESOURCE_GROUP=packer-resourcegroup
export PACKER_IMAGE_LOCATION=westus2
export PACKER_PIPELINE_DOWNLOAD_URL=https://github.com/cisco-ie/pipeline-gnmi/raw/master/bin/pipeline
export ARM_CLIENT_ID=<<ClientId>>
export ARM_CLIENT_SECRET=<<ClientSecret>>
export ARM_SUBSCRIPTION_ID=<<SubScriptionId>>
export ARM_TENANT_ID=<<TenantId>>
```

# Create resource group to store custom images
```
az group create -n $PACKER_IMAGE_RESOURCE_GROUP -l $PACKER_IMAGE_LOCATION
```

# Build the custom image
```
packer build vm.json | tee packer.log
CUSTOM_IMAGE_NAME=`cat packer.log | tee packer.log | grep ManagedImageName | sed -n -e 's/^ManagedImageName: //p'`
echo "Created Custom Image: ${CUSTOM_IMAGE_NAME}"
```

# Retrieve the id of the custom image[]
```
CUSTOM_IMAGE_ID=`az image show -g $PACKER_IMAGE_RESOURCE_GROUP --name $CUSTOM_IMAGE_NAME --query id | sed -e "s/\"//g"`
echo "Custom Image Id: ${CUSTOM_IMAGE_ID}"
```

# Quick VM Test: Create Virtual Machine
This creates a VM outside of the pre-defined dev environment.
```
export VM_RESOURCE_GROUP_NAME=packer-test-vm
az group create -n $VM_RESOURCE_GROUP_NAME -l $PACKER_IMAGE_LOCATION
az vm create \
    --resource-group $VM_RESOURCE_GROUP_NAME  \
    --name myVM \
    --image $CUSTOM_IMAGE_ID \
    --admin-username azureuser \
    --generate-ssh-keys
```