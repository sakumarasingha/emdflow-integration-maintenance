@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Service Bus Queue')
param queueName string

@description('Name of the Queue for Forwarding')
param deadLetteredForwardQueueName string = ''

@description('Wait time that the message is locked for other receivers.')
param lockDuration string = 'PT2M'

@description('Duplicate message detection enabaled')
param requiresDuplicateDetection bool = false

@description('Duplicate message detection timewindow')
param duplicateDetectionTimeWindow string = 'PT10M'

@description('Max delivery count before deadlettering')
param maxDeliveryCount int = 3

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: queueName
  properties: {
    lockDuration: lockDuration
    maxDeliveryCount: maxDeliveryCount
    forwardDeadLetteredMessagesTo: !(empty(deadLetteredForwardQueueName))? deadLetteredForwardQueueName : null
    requiresDuplicateDetection: requiresDuplicateDetection
    duplicateDetectionHistoryTimeWindow: (requiresDuplicateDetection)? duplicateDetectionTimeWindow : null
  }
}

output id string = serviceBusQueue.id
