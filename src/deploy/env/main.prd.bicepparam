using '../main.bicep'
param locationFull = 'australiasoutheast'
param environment = 'prd'
param rgName = 'rg-integration-core-prd-ase-002'
param rgCoreService = 'rg-integration-core-prd-ase-001'
param privateDnsZoneRgName = 'rg-integration-core-prd-ase-001'
param omsWorkspaceName = 'log-integration-core-prd-ase-001'
param omsWorkspaceRgName = 'rg-integration-core-prd-ase-001'
param vnetName = 'vnet-integration-prd-ase-001'
param vnetRgName = 'rg-integration-core-prd-ase-002'
param emailRecipients = 'contact@emdflow.com'

param tagList = {
  'Created By': 'https://emdflow.com'
  Owner : 'https://emdflow.com'
  Department : 'Integration'
  Environment : 'PRD'
  Vendor : 'Microsoft'
  Version : '1.0.0'
}

