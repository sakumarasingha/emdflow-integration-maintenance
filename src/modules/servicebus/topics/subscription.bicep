@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Service Bus topic')
param topicName string

@description('Name of the Service Bus subscriptions')
param subscriptionName string

@description('Forward to anther queue')
param forwardToQueue string = ''

@description('Forward to anther queue')
param maxDeliveryCount int = 3


resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: '${serviceBusNamespaceName}/${topicName}/${subscriptionName}'
  properties: {  
    forwardTo:   !empty(forwardToQueue) ? forwardToQueue : null 
    maxDeliveryCount: maxDeliveryCount
  }
}
