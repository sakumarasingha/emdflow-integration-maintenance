@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('SKU of the Service Bus namespace')
param serviceBusNamespaceSku string = 'Standard'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tag list and values')
param tagList object = {}

@description('Workspace Id for diagnostics ')
param omsWorkspaceId string = ''

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespaceName
  tags: tagList
  location: location
  sku: {
    name: serviceBusNamespaceSku
  }
  properties: {
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource resource_logicapp_diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  scope: serviceBus
  name: '${serviceBusNamespaceName}-diagnostics'
  properties: {
    workspaceId: omsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
