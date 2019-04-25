# azure-grpc-telemetry-pipeline

This repository contains a sample implementation of a data pipeline to ingest streaming telemetry from Cisco IOS XR devices and process the data on Azure.

# Usage

Required tools:

* [Terraform](https://www.terraform.io/)

From terraform/azure folder:
- Create a file named terraform.tfvars, copy content from sample.tfvars and update variables with appropriate values.
- Run ```terrform init```
- Run ```terrform apply```

# Development

The sample assumes you'll have your own network configuration and will deploy into your existing VNETs/subnets. To help with dev/test, we've provided a Terraform configuration that deploys everything needed to get up and running quickly.

```shell
cd terraform/dev-env
terraform init
terraform apply -var 'infra_resource_group_name=pipeline-infra'
```

### Accessing Azure VM 
First, we need to create a public ip address and assign it the nic attached to the vm.
```
RESOURCE_GROUP_NAME=azure-pipeline-rg
az network public-ip create -g $RESOURCE_GROUP_NAME --name publicip1 --allocation-method Static
az network nic ip-config create -g $RESOURCE_GROUP_NAME --nic-name <<NIC_NAME>> --name testconfiguration1 --public-ip-address publicip1

```

Finally, we can set the SSH keys so that we can SSH into the vm.
```
az vm user update \
  --resource-group $RESOURCE_GROUP_NAME \
  --name <<VM_NAME>> \
  --username azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub
```

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.