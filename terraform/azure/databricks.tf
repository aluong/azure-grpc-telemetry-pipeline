resource "azurerm_template_deployment" "databricksworkspace" {
  name                = "${var.prefix}-databricksworkspace"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  template_body = <<DEPLOY
  {
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "prefix": {
        "type": "string",
        "defaultValue": "[take(tolower(uniqueString(resourceGroup().id)), 12)]"
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
      "databricksWorkspace": "[parameters('prefix')]",
      "managedResourceGroupId": "[concat(subscription().id, '/resourceGroups/databricks-rg-', variables('databricksWorkspace'))]"
    },
    "resources": [
      {
        "apiVersion": "2018-04-01",
        "type": "Microsoft.Databricks/workspaces",
        "name": "[variables('databricksWorkspace')]",
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
    "vnetId" = "${var.vnetId}"
    "databricksPrivateSubnetName" = "${var.databricksPrivateSubnetName}"
    "databricksPublicSubnetName" = "${var.databricksPublicSubnetName}"
    "prefix" = "${var.prefix}"
  }

  deployment_mode = "Incremental"
}