@description('App Service Name')
param siteName string

@description('VNET Name')
param vnetName string

@description('VNET RG Name')
param vnetRgName string

@description('Subnet Name')
param subnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: subnetName
  parent: vnet
}

resource site 'Microsoft.Web/sites@2021-03-01' existing = {
  name: siteName
}

var subnetRef = subnet.id

resource symbolicname 'Microsoft.Web/sites/networkConfig@2022-09-01' = {
  name: 'virtualNetwork'
  kind: 'string'
  parent: site
  properties: {
    subnetResourceId: subnetRef
  }
}
