@description('Location of the resource.')
param location string = resourceGroup().location

@description('Private DEndpoint Name.')
param privateEndpointName string

@description('VNET Name')
param vnetName string

@description('VNET RG Name')
param vnetRgName string

@description('Subnet Name')
param subnetName string

@description('Private Dns Zone Name.')
param privateDnsZoneName string

@description('Private Dns Zone Resource Group Name.')
param privateDnsZoneRgName string = ''

@description('DNZ Group Name.')
param dnsGroupName string

@description('Tag list and values')
param tagList object = {}

param resourceId string

param subResourceName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: subnetName
  parent: vnet
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: !empty(privateDnsZoneRgName)? resourceGroup(privateDnsZoneRgName): resourceGroup()
  name: privateDnsZoneName
}

var subnetRef = subnet.id

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  tags: tagList
  properties: {
    subnet: {
      id: subnetRef
    }
    privateLinkServiceConnections: [
      {        
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceId
          groupIds: [
            subResourceName
          ]
        }
      }
    ]
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: privateEndpoint
  name: dnsGroupName
  dependsOn: [
    privateDnsZone
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config_1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

