using '../main.bicep'
param locationFull = 'australiasoutheast'
param environment = 'sit'
param rgName = 'rg-integration-core-sit-ase-002'
param rgCoreService = 'rg-integration-core-sit-ase-001'
param privateDnsZoneRgName = 'rg-integration-core-sit-ase-001'
param omsWorkspaceName = 'log-integration-core-sit-ase-001'
param omsWorkspaceRgName = 'rg-integration-core-sit-ase-001'
param vnetName = 'vnet-integration-sit-ase-001'
param vnetRgName = 'rg-integration-core-sit-ase-002'
param emailRecipients = 'contact@emdflow.com'

param tagList = {
  'Created By': 'https://emdflow.com'
  Owner : 'https://emdflow.com'
  Department : 'Integration'
  Environment : 'SIT'
  Vendor : 'Microsoft'
  Version : '1.0.0'
}

