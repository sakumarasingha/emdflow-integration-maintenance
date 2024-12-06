@description('Location of the resource.')
param location string = resourceGroup().location

@description('Name of the appservice plan.')
param appservicename string 

@description('Id of App service plan')
param appserviceplanid string

@description('Id of App service plan')
param alwayson bool = false

@description('List of App Settings')
param appSettings array = []

@description('List of ConnectionStrings')
param connectionStrings array = []

@description('Log Analytics Workspace Id')
param laWorkspaceId string

@description('Diagnostics settings enabled or not')
param diagnosticsEnabled bool = true

resource appservice 'Microsoft.Web/sites@2022-03-01'={
  location: location
  name: appservicename
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    serverFarmId: appserviceplanid
    httpsOnly: true
  }
  
}

resource appservice_config 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  kind: 'string'
  parent: appservice
  properties: {   
    alwaysOn: alwayson   
    appSettings: appSettings
    connectionStrings: connectionStrings 
    ftpsState: 'FtpsOnly'
    minTlsVersion: '1.2'
  }
  
}

resource appServiceLogAnalyticsDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${appservicename}-diagnosticSettings'
  scope: appservice
  properties: {
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          enabled: diagnosticsEnabled
          days: 7
        }
      }       
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: laWorkspaceId
  }
}

output identity_objectid string = appservice.identity.principalId
