
resource "azurerm_template_deployment" "eventhub" {
  name                = "${var.prefix}-eventhub"
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
      "subnetIds": {
        "type": "array",
        "defaultValue": ${var.subnetIds}
      },
      "messageRetentionInDays": {
        "type": "string",
        "defaultValue": "1"
      },
      "partitionCount": {
        "type": "string",
        "defaultValue": "4"
      },
      "captureStorageAccountId": {
        "type": "string"
      },
      "captureStorageContainer": {
        "type": "string",
        "defaultValue": "telemetry"
      }
    },
    "variables": {
      "ehNamespace": "[concat('eh-', parameters('prefix'))]",
      "ehName": "telemetry",
      "consumerGroups": [
        "databricks"
      ]
    },
    "resources": [
      {
        "apiVersion": "2017-04-01",
        "type": "Microsoft.EventHub/namespaces",
        "name": "[variables('ehNamespace')]",
        "location": "[resourceGroup().location]",
        "sku": {
          "name": "Standard",
          "tier": "Standard"
        },
        "properties": {
          "kafkaEnabled": true
        }
      },
      {
        "dependsOn": [
          "[resourceId('Microsoft.EventHub/namespaces', variables('ehNamespace'))]"
        ],
        "apiVersion": "2017-04-01",
        "type": "Microsoft.EventHub/namespaces/eventhubs",
        "name": "[concat(variables('ehNamespace'), '/', variables('ehName'))]",
        "properties": {
          "messageRetentionInDays": "[parameters('messageRetentionInDays')]",
          "partitionCount": "[parameters('partitionCount')]",
          "captureDescription": {
          "enabled": true,
          "skipEmptyArchives": true,
          "encoding": "Avro",
          "intervalInSeconds": 60,
          "sizeLimitInBytes": 10485760,
          "destination": {
            "name": "EventHubArchive.AzureBlockBlob",
            "properties": {
              "storageAccountResourceId": "[parameters('captureStorageAccountId')]",
              "blobContainer": "[parameters('captureStorageContainer')]",
              "archiveNameFormat": "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
            }
          }
        }
        }
      },
      {
        "dependsOn": [
          "[resourceId('Microsoft.EventHub/namespaces/eventHubs', variables('ehNamespace'), variables('ehName'))]"
        ],
        "copy": {
          "name": "cgCopy",
          "count": "[length(variables('consumerGroups'))]"
        },
        "apiVersion": "2017-04-01",
        "type": "Microsoft.EventHub/namespaces/eventhubs/consumergroups",
        "name": "[concat(variables('ehNamespace'), '/', variables('ehName'), '/', variables('consumerGroups')[copyIndex()])]",
        "properties": {}
      },
      {
        "dependsOn": [
          "[resourceId('Microsoft.EventHub/namespaces', variables('ehNamespace'))]"
        ],
        "copy": {
          "name": "networkRuleCopy",
          "count": "[length(parameters('subnetIds'))]"
        },
        "apiVersion": "2018-01-01-preview",
        "type": "Microsoft.EventHub/namespaces/virtualnetworkrules",
        "name": "[concat(variables('ehNamespace'), '/vnet-', copyIndex())]",
        "properties": {
          "virtualNetworkSubnetId": "[parameters('subnetIds')[copyIndex()]]"
        }
      }
    ],
    "outputs": {}
  }

DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "prefix" = "${var.prefix}",
    "messageRetentionInDays" = "${var.messageRetentionInDays}",
    "partitionCount" = "${var.partitionCount}",
    "captureStorageAccountId" = "${azurerm_storage_account.capture.id}"
  }

  deployment_mode = "Incremental"
}