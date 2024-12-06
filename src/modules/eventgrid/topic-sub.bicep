@description('Name of the Event Grid Domain.')
param domainName string

@description('Name of the Event Grid Domain Topic')
param topicName string

@description('Subscription Name')
param subscriptionName string

@description('Handler endpoint type')
param endpointType string

@description('Endpoint resource Id')
param endpointResourceId string

@description('Event Types for filtering')
param filterEventTypes array = []

@description('Advance Filters to Apply')
param advancedFilters array = []

@description('Storage Account Id for Deadlettering')
param deadLetterResourceId string

@description('Storage Container Name for Deadlettering')
param deadLetterContainerName string

@description('No Of events for batch')
param maxEventsPerBatch int = 0

@description('Size of the message')
param preferredBatchSizeInKilobytes int = 0

resource evgd 'Microsoft.EventGrid/domains@2020-06-01' existing = {
  name: domainName
}

resource eventGridDomainTopic 'Microsoft.EventGrid/domains/topics@2023-12-15-preview' = {
  parent: evgd
  name: topicName
}

resource eventSubscription 'Microsoft.EventGrid/domains/topics/eventSubscriptions@2023-12-15-preview' = {
  name: '${evgd.name}/${topicName}/${subscriptionName}'
  dependsOn: [
    eventGridDomainTopic
  ]
  properties: {
    destination: {
      endpointType: endpointType
      properties: {
        resourceId: endpointResourceId
        maxEventsPerBatch: maxEventsPerBatch == 0 ? null : maxEventsPerBatch
        preferredBatchSizeInKilobytes: preferredBatchSizeInKilobytes == 0 ? null : preferredBatchSizeInKilobytes
        deliveryAttributeMappings: [
          {
            name: 'eventid'
            type: 'Dynamic'
            properties: {
              sourceField: 'id'
            }
          }
        ]
      }
    }
    filter: {
      includedEventTypes: !empty(filterEventTypes) ? filterEventTypes : null
      advancedFilters: !empty(advancedFilters) ? advancedFilters : null
    }
    retryPolicy: {
      maxDeliveryAttempts: 3
      eventTimeToLiveInMinutes: 1440
    }
    deadLetterDestination: {
      endpointType: 'StorageBlob'
      properties: {
        blobContainerName: deadLetterContainerName
        resourceId: deadLetterResourceId
      }
    }
  }
}
