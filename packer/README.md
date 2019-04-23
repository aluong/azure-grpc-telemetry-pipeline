# Prerequisites
- Create service principal

```az ad sp create-for-rbac --name packer-test```

- Install [packer](https://www.packer.io/intro/getting-started/install.html)


# Export Environment Variables
```
export PACKER_IMAGE_RESOURCE_GROUP=packer-test-resourcegroup
export VM_RESOURCE_GROUP_NAME=packer-test-vm
export AZURE_CLIENT_ID=<<ClientId>>
export AZURE_CLIENT_SECRET=<<ClientSecret>>
export AZURE_SUBSCRIPTION_ID=<<SubScriptionId>>
export AZURE_TENANT_ID=<<TenantId>>
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

# Create Virtual Machine
```
az group create -n $VM_RESOURCE_GROUP_NAME -l eastus
az vm create \
    --resource-group $VM_RESOURCE_GROUP_NAME  \
    --name myVM \
    --image $CUSTOM_IMAGE_ID \
    --admin-username azureuser \
    --generate-ssh-keys
```