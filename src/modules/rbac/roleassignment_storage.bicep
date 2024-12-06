param storageName string
param principalId string
param principalType string = ''

@allowed([
    'Storage Blob Data Contributor'
    'Storage Table Data Contributor'
])
param roleDefinition string

var roles = { 
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'Storage Table Data Contributor': '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
}

var roleDefinitionId = roles[roleDefinition]

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageName
}

resource roleAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: guid('storage-rbac', storageAccount.id, resourceGroup().id, principalId, roleDefinitionId)
    scope: storageAccount
    properties: {
        principalId: principalId
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
        principalType: empty(principalType) ? null : principalType
    }
}
