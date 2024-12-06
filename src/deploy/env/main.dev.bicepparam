using '../main.bicep'
param locationFull = 'australiasoutheast'
param environment = 'dev'
param rgName = 'rg-integration-core-dev-ase-002'
param rgCoreService = 'rg-integration-core-dev-ase-001'
param privateDnsZoneRgName = 'rg-integration-core-dev-ase-001'
param omsWorkspaceName = 'log-integration-core-dev-ase-001'
param omsWorkspaceRgName = 'rg-integration-core-dev-ase-001'
param vnetName = 'vnet-integration-dev-ase-001'
param vnetRgName = 'rg-integration-core-dev-ase-002'
param emailRecipients = 'contact@emdflow.com'

param tagList = {
  'Created By': 'https://emdflow.com'
  Owner : 'https://emdflow.com'
  Department : 'Integration'
  Environment : 'DEV'
  Vendor : 'Microsoft'
  Version : '1.0.0'
}

