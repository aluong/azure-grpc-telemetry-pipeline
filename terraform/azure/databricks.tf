resource "azurerm_template_deployment" "databricksworkspace" {
  name                = "databricksworkspace"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  template_body = <<DEPLOY
  {
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "workspaceName": {
        "type": "string"
      },
      "vnetId": {
        "type": "string"
      },
      "databricksPrivateSubnetName": {
        "type": "string"
      },
      "databricksPublicSubnetName": {
        "type": "string"
      }
    },
    "variables": {
      "managedResourceGroupId": "[concat(subscription().id, '/resourceGroups/databricks-rg-', parameters('workspaceName'))]"
    },
    "resources": [
      {
        "apiVersion": "2018-04-01",
        "type": "Microsoft.Databricks/workspaces",
        "name": "[parameters('workspaceName')]",
        "location": "[resourceGroup().location]",
        "sku": {
          "name": "Standard"
        },
        "properties": {
          "managedResourceGroupId": "[variables('managedResourceGroupId')]",
          "parameters": {
            "customVirtualNetworkId": {
              "value": "[parameters('vnetId')]"
            },
            "customPublicSubnetName": {
              "value": "[parameters('databricksPublicSubnetName')]"
            },
            "customPrivateSubnetName": {
              "value": "[parameters('databricksPrivateSubnetName')]"
            }
          }
        }
      }
    ]
  }

DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "workspaceName" = "${local.baseName}"
    "vnetId" = "${var.databricks_vnet_id}"
    "databricksPrivateSubnetName" = "${var.databricks_private_subnet_name}"
    "databricksPublicSubnetName" = "${var.databricks_public_subnet_name}"
  }

  deployment_mode = "Incremental"
}