@description('Name of the system Topic')
param systemTopicName string

@description('Location of the resource.')
param location string = resourceGroup().location

@description('Id of the resource')
param eventSourceId string

@description('Type of the resource')
param eventSourceType string


resource systemTopic 'Microsoft.EventGrid/systemTopics@2024-06-01-preview' = {
  name: systemTopicName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: eventSourceId
    topicType: eventSourceType
  }
}

output name string = systemTopic.name
