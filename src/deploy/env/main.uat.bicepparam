using '../main.bicep'
param locationFull = 'australiasoutheast'
param environment = 'uat'
param rgName = 'rg-integration-core-uat-ase-002'
param rgCoreService = 'rg-integration-core-uat-ase-001'
param privateDnsZoneRgName = 'rg-integration-core-uat-ase-001'
param omsWorkspaceName = 'log-integration-core-uat-ase-001'
param omsWorkspaceRgName = 'rg-integration-core-uat-ase-001'
param vnetName = 'vnet-integration-uat-ase-001'
param vnetRgName = 'rg-integration-core-uat-ase-002'
param emailRecipients = 'contact@emdflow.com'

param tagList = {
  'Created By': 'https://emdflow.com'
  Owner : 'https://emdflow.com'
  Department : 'Integration'
  Environment : 'UAT'
  Vendor : 'Microsoft'
  Version : '1.0.0'
}

