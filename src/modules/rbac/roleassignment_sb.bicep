param serviceBusNamespaceName string
param principalId string
param principalType string = ''

@allowed([
    'Azure Service Bus Data Receiver'
    'Azure Service Bus Data Sender'
])
param roleDefinition string

var roles = { 
  'Azure Service Bus Data Receiver': '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
  'Azure Service Bus Data Sender': '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
}

var roleDefinitionId = roles[roleDefinition]

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource roleAuthorization 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: guid('sb-rbac', serviceBus.id, resourceGroup().id, principalId, roleDefinitionId)
    scope: serviceBus
    properties: {
        principalId: principalId
        roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
        principalType: empty(principalType) ? null : principalType
    }
}
