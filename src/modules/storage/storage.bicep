@description('Storage account name')
param storageAccountName string

@description('Location of the resource.')
param location string = resourceGroup().location

@description('Storage account sku')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSku string

@description('Storage account access tier, Hot for frequently accessed data or Cool for infreqently accessed data')
@allowed([
  'Hot'
  'Cool'
])
param storageTier string = 'Hot'

@description('Allow the use of SAS Keys to access storage account')
param allowSharedKeyAccess bool = true

@description('Whether anonymous blob access is allowed. Recommend this to be false unless necessary (e.g. static assets for web)')
param allowBlobPublicAccess bool = false

@description('Enable/Disable soft delete Data Protection features')
param enableDataProtection bool = true

@description('Amount of days the soft deleted blob data is stored and available for recovery')
@minValue(1)
@maxValue(365)
param blobDeleteRetentionDays int = 30

@description('Amount of days the soft deleted container is stored and available for recovery')
@minValue(1)
@maxValue(365)
param containerDeleteRetentionDays int = 30

@description('Amount of days the soft deleted File Share is stored and available for recovery')
@minValue(1)
@maxValue(365)
param shareDeleteRetentionDays int = 30

@description('Whether to allow Azure Services to bypass Network Acls.')
@allowed([
  'AzureServices'
  'None'
])
param networkAclsBypass string = 'AzureServices'

@description('Set to Deny if you want to enable the firewall.')
@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Allow'

@description('An array of CIDR ranges for Storage Network ACLs.')
@metadata({
  note: 'Sample input'
  ipRules: [
    {
      action: 'Allow'
      value: 'CIDR Range'
    }
  ]
})
param ipRules array = []

@description('An array of CIDR ranges for Storage Network ACLs.')
@metadata({
  note: 'Sample input'
  resourceAccessRules: [
    {
      resourceId: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/example-dev-rg/providers/microsoft.operationalinsights/workspaces/example-dev-log'
      tenantId: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    }
  ]
})
param resourceAccessRules array = []

@description('An array of CIDR ranges for Storage Network ACLs.')
@metadata({
  note: 'Sample input'
  virtualNetworkRules: [
    {
      action: 'Allow'
      id: '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/example-dev-rg/providers/Microsoft.Network/virtualNetworks/example-dev-vnet/subnets/examplesubnet'
    }
  ]
})
param virtualNetworkRules array = []

@description('Tag list and values')
param tagList object = {}

@description('Enable a Can Not Delete Resource Lock.  Useful for production workloads.')
param enableResourceLock bool = false

@description('Workspace Id for diagnostics ')
param omsWorkspaceId string = ''


resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tagList
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: storageTier
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: allowSharedKeyAccess  
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        queue: {
          enabled: true
        }
        table: {
          enabled: true
        }
      }
    }
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: ipRules
      resourceAccessRules: resourceAccessRules
      virtualNetworkRules: virtualNetworkRules
    }
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: allowBlobPublicAccess
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  parent: storage
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: enableDataProtection
      days: blobDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: enableDataProtection
      days: containerDeleteRetentionDays
    }    
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  parent: storage
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: enableDataProtection
      days: shareDeleteRetentionDays
    }
  }
}

resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-04-01' = {
  parent: storage
  name: 'default'
  properties: {
  }
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2021-04-01' = {
  parent: storage
  name: 'default'
  properties: {
  }
}


// Storage Resource Diagnostics
resource root_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  name: '${storageAccountName}-diagnostics'
  scope: storage
  properties: {
    workspaceId: omsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource blob_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  name: '${storageAccountName}-blobServices-diagnostics'
  scope: blobServices
  properties: {
    workspaceId: omsWorkspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        
      }
      {
        category: 'StorageWrite'
        enabled: true
        
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

resource file_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  name: '${storageAccountName}-fileServices-diagnostics'
  scope: fileServices
  properties: {
    workspaceId: omsWorkspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

resource queue_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  name: '${storageAccountName}-queueServices-diagnostics'
  scope: queueServices
  properties: {
    workspaceId: omsWorkspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled:true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

resource table_diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(omsWorkspaceId)) {
  name: '${storageAccountName}-tableServices-diagnostics'
  scope: tableServices
  properties: {
    workspaceId: omsWorkspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

// Resource Lock
resource storage_deleteLock 'Microsoft.Authorization/locks@2016-09-01' = if (enableResourceLock) {
  name: '${storageAccountName}-delete-lock'
  scope: storage
  properties: {
    level: 'CanNotDelete'
    notes: 'Enabled as part of IaC Deployment'
  }
}

// Output Resource Name and Resource Id as a standard to allow module referencing.
output name string = storage.name
output id string = storage.id
output apiVersion string = storage.apiVersion

