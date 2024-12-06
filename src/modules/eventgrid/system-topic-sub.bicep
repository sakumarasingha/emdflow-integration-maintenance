
@description('Name of the system Topic Sub')
param systemTopicSubName string

@description('Name of the system Topic')
param systemTopicName string

@description('Handler endpoint type')
param endpointType string

@description('Endpoint resource Id')
param endpointResourceId string

@description('Event Types for filtering')
param eventTypes array = []

resource systemTopic 'Microsoft.EventGrid/systemTopics@2024-06-01-preview'  existing ={
  name: systemTopicName
}

resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2024-06-01-preview' = {
  name: '${systemTopicName}/${systemTopicSubName}'
  dependsOn: [
    systemTopic
  ]
  properties: {
    destination: {
      endpointType: endpointType
      properties: {
        resourceId: endpointResourceId
      }
    }
    filter: {
      includedEventTypes: eventTypes
      enableAdvancedFilteringOnArrays: true
    }
    labels: []
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}
