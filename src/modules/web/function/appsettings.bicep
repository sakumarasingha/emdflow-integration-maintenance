@description('List of App Settings')
param appSettings array = []

@description('List of ConnectionStrings')
param connectionStrings array = []

@description('Function Name')
param functionName string

resource function 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionName
}

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: function
  properties: {
    appSettings: appSettings
    connectionStrings: connectionStrings
  }
}
