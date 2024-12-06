@description('The name of the logic app that you wish to create.')
param logicAppName string = 'fnapp${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Hosting Plan Name')
param hostingPlanId string

@description('List of App Settings')
param appSettings array = []

@description('List of ConnectionStrings')
param connectionStrings array = []

@description('Whitelist IP Address')
param whitelistingIps array = []

@description('Tag list and values')
param tagList object = {}

@description('Workspace Id for diagnostics ')
param omsWorkspaceId string = ''

resource logicApp 'Microsoft.Web/sites@2021-03-01' = {
  name: logicAppName
  tags: tagList
  location: location
  kind: 'functionapp,workflowapp'
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
      vnetPrivatePortsCount: 2
      ipSecurityRestrictions: !empty(whitelistingIps)? whitelistingIps:null
    }
    httpsOnly: true
  }
}

resource logicapp_existing 'Microsoft.Web/sites@2021-03-01' existing = {
  name: logicAppName
}


resource resource_logicapp_diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  scope: logicapp_existing
  name: '${logicAppName}-diagnostics'
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

output identity_objectid string = logicApp.identity.principalId
output resourceId string = logicApp.id
output apiVersion string = logicApp.apiVersion
