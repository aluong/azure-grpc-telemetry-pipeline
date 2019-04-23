locals {
  eventHubNamespace = "eh-${var.prefix}"
}

resource "azurerm_template_deployment" "eventhub" {
  name                = "${var.prefix}-eventhub"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  template_body = <<DEPLOY
  {
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "ehNamespace": {
        "type": "string"
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
      "ehName": "telemetry",
      "consumerGroups": [
        "databricks"
      ]
    },
    "resources": [
      {
        "apiVersion": "2017-04-01",
        "type": "Microsoft.EventHub/namespaces",
        "name": "[parameters('ehNamespace')]",
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
          "[resourceId('Microsoft.EventHub/namespaces', parameters('ehNamespace'))]"
        ],
        "apiVersion": "2017-04-01",
        "type": "Microsoft.EventHub/namespaces/eventhubs",
        "name": "[concat(parameters('ehNamespace'), '/', variables('ehName'))]",
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
          "[resourceId('Microsoft.EventHub/namespaces/eventHubs', parameters('ehNamespace'), variables('ehName'))]"
        ],
        "copy": {
          "name": "cgCopy",
          "count": "[length(variables('consumerGroups'))]"
        },
        "apiVersion": "2017-04-01",
        "type": "Microsoft.EventHub/namespaces/eventhubs/consumergroups",
        "name": "[concat(parameters('ehNamespace'), '/', variables('ehName'), '/', variables('consumerGroups')[copyIndex()])]",
        "properties": {}
      },
      {
        "dependsOn": [
          "[resourceId('Microsoft.EventHub/namespaces', parameters('ehNamespace'))]"
        ],
        "copy": {
          "name": "networkRuleCopy",
          "count": "[length(parameters('subnetIds'))]"
        },
        "apiVersion": "2018-01-01-preview",
        "type": "Microsoft.EventHub/namespaces/virtualnetworkrules",
        "name": "[concat(parameters('ehNamespace'), '/vnet-', copyIndex())]",
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
    "ehNamespace" = "${local.eventHubNamespace}",
    "messageRetentionInDays" = "${var.messageRetentionInDays}",
    "partitionCount" = "${var.partitionCount}",
    "captureStorageAccountId" = "${azurerm_storage_account.capture.id}"
  }

  deployment_mode = "Incremental"
}

resource "azurerm_eventhub_namespace_authorization_rule" "writer-pipeline" {
  name = "pipeline"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  namespace_name = "${local.eventHubNamespace}"
  listen = false
  send = true
  manage = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "reader-databricks" {
  name = "databricks"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  namespace_name = "${local.eventHubNamespace}"
  listen = true
  send = false
  manage = false
}

resource "azurerm_key_vault_secret" "writer-pipeline" {
  name     = "eh-pipeline"
  value    = "${azurerm_eventhub_namespace_authorization_rule.writer-pipeline.primary_connection_string}"
  key_vault_id = "${var.keyVaultId}"
}

resource "azurerm_key_vault_secret" "reader-databricks" {
  name     = "eh-databricks"
  value    = "${azurerm_eventhub_namespace_authorization_rule.reader-databricks.primary_connection_string}"
  key_vault_id = "${var.keyVaultId}"
}