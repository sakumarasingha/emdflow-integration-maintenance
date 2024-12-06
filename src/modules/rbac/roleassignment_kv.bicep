param keyvaultName string
param principalId string
param principalType string = ''

@allowed([
    'Key Vault Secrets User'
    'Key Vault Secrets Officer'
])
param roleDefinition string

var roles = { 
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Key Vault Secrets Officer': 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
}

var roleDefinitionId = roles[roleDefinition]

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvaultName
}

resource roleAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: guid('kv-rbac', keyvault.id, resourceGroup().id, principalId, roleDefinitionId)
    scope: keyvault
    properties: {
        principalId: principalId
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
        principalType: empty(principalType) ? null : principalType
    }
}
