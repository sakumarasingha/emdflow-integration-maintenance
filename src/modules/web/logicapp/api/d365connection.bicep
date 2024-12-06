

@description('Api Connection Name')
param name string 

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Connection Display Name')
param displayName string

@secure()
@description('Connection Client Secret')
param crmClientId string = ''

@secure()
@description('Connection Client Id')
param crmClientSecret string = ''

@secure()
@description('Connection Tenant Id')
param crmTenantId string = ''

@description('Connection Resource Url')
param resourceUrl string

@description('Connection Grant type')
param grantType string

@description('Tag list and values')
param tagList object = {}

resource apiconnection 'Microsoft.Web/connections@2016-06-01' = {
  name: name
  location:location
  tags: tagList
  kind: 'V2'
  properties: {
    api: {
      id:'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location }/managedApis/commondataservice'
    }
    displayName:displayName
    parameterValues: {
      'token:clientId': crmClientId
      'token:TenantId': crmTenantId
      'token:clientSecret': crmClientSecret
      'token:grantType': grantType
      'token:resourceUri': resourceUrl
    }
    
    nonSecretParameterValues: {}
  }
}

output id string = apiconnection.id
output name string = apiconnection.name
output runtimeUrl string = apiconnection.properties.connectionRuntimeUrl 
