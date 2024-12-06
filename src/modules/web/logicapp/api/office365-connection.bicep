@description('Api Connection Name')
param connectionName string 

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Connection Display Name')
param displayName string

@description('Tag list and values')
param tagList object = {}
 

resource apiconnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  tags: tagList
 kind: 'V2'
  properties: {
    displayName: displayName
    customParameterValues: {}
    nonSecretParameterValues: {}
    api: {
      name: connectionName
      displayName: 'Office 365 Outlook'
      description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organization\'s needs for robust security, reliability, and user productivity.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1706/1.0.1706.3851/${connectionName}/icon.png'
      brandColor: '#0078D4'
      id:'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/${connectionName}'
      type: 'Microsoft.Web/locations/managedApis'
    }
  }
}

output id string = apiconnection.id
output name string = apiconnection.name
output runtimeUrl string = apiconnection.properties.connectionRuntimeUrl 
