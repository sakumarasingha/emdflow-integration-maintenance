// Comment: Bicep Template to deploy integration interfaces and configurations

// --------------------------------------------------------------
// Parameters
// --------------------------------------------------------------
@description('The type of environment being deployed')
param environment string

@description('Tag list and values')
param tagList object

@description('The primary location full being deployed to.')
@allowed([
  'australiaeast'
  'australiasoutheast'
])
param locationFull string

@description('Resource Group for Core Services')
param rgCoreService string

@description('Resource Group for integration')
param rgName string

@description('Private Dns Zone Resource Group Name.')
param privateDnsZoneRgName string

@description('Log Analytics Name')
param omsWorkspaceName string

@description('Log Analytics Resource Group Name')
param omsWorkspaceRgName string

@description('VNET Name')
param vnetName string

@description('VNET RG Name')
param vnetRgName string

@description('Email Recipients')
param emailRecipients string

// Deploy AHPRA CRM Entity Function Configurations
module custom_alert_component './custom-alerts.bicep' = {
  name: 'deploy_custom_alert_component'
  dependsOn: [
  ]
  params: {
    environment: environment
    locationFull: locationFull
    rgName: rgName
    rgCoreService: rgCoreService
    privateDnsZoneRgName: privateDnsZoneRgName
    omsWorkspaceName: omsWorkspaceName
    omsWorkspaceRgName: omsWorkspaceRgName
    vnetName: vnetName
    vnetRgName: vnetRgName
    emailRecipients: emailRecipients
    tagList: tagList
  }
}
