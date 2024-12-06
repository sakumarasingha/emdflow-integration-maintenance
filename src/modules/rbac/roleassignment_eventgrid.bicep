

param domainName string = ''
param principalId string
param principalType string = ''

@allowed([
    'EventGrid Data Sender'
    'EventGrid Contributor'
    'EventGrid EventSubscription Reader'
    'EventGrid EventSubscription Contributor'
])
param roleDefinition string

var roles = { 
  'EventGrid Data Sender': 'd5a91429-5739-47e2-a06b-3470a27159e7'
  'EventGrid Contributor': '1e241071-0855-49ea-94dc-649edcd759de'
  'EventGrid EventSubscription Reader': '2414bbcf-6497-4faf-8c65-045460748405'
  'EventGrid EventSubscription Contributor': '428e0ff0-5e57-4d9c-a221-2c70d0e0a443'
}

var roleDefinitionId = roles[roleDefinition]


resource domain 'Microsoft.EventGrid/domains@2023-12-15-preview' existing = {
  name: domainName
}

resource roleAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(domainName)) {
    name: guid('eventgrid-rbac', domain.id, resourceGroup().id, principalId, roleDefinitionId)
    scope: domain
    properties: {
        principalId: principalId
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
        principalType: empty(principalType) ? null : principalType
    }
}
