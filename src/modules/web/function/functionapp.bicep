@description('The name of the function app that you wish to create.')
param functionAppName string = 'fnapp${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Hosting Plan Name')
param hostingPlanId string

@description('List of App Settings')
param appSettings array = []

@description('List of ConnectionStrings')
param connectionStrings array = []

@description('Tag list and values')
param tagList object = {}

@description('Workspace Id for diagnostics ')
param omsWorkspaceId string = ''

@description('Workspace Id for diagnostics ')
param alwaysOn bool = false

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  tags: tagList
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlanId
    siteConfig: {
      appSettings: appSettings
      connectionStrings: connectionStrings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
      alwaysOn: alwaysOn
    }
    httpsOnly: true
  }
}


resource func_existing 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionAppName
}


resource resource_func_diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  scope: func_existing
  name: '${functionAppName}-diagnostics'
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
output identity_objectid string = functionApp.identity.principalId
output resourceId string = functionApp.id
