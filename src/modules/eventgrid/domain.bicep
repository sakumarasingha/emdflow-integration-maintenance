@description('Location of the resource.')
param location string = resourceGroup().location

@description('Name of the Event Grid Domain.')
param domainName string 

@description('Workspace Id for diagnostics ')
param omsWorkspaceId string = ''

@description('Tag list and values')
param tagList object = {}


resource eventGridDomain 'Microsoft.EventGrid/domains@2023-12-15-preview' = {
  name: domainName
  location: location
  tags: tagList
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}


resource egdomain 'Microsoft.EventGrid/domains@2023-12-15-preview' existing = {
  name: domainName
}

resource egdomain_diagnosticsettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  scope: egdomain
  name: '${domainName}-diagnostics'
  properties: {
    workspaceId: omsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
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

output endpoint string = eventGridDomain.properties.endpoint
output id string = eventGridDomain.id

