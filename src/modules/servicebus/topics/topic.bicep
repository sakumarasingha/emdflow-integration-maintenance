@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Service Bus topic')
param topicName string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource serviceBusNamespaceName_serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: topicName
  properties: {
    
  }
}
