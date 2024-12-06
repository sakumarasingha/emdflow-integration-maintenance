@description('Name of the Event Grid Domain.')
param domainName string 

@description('Name of the Event Grid Domain Topic')
param topicName string 

resource evgd 'Microsoft.EventGrid/domains@2020-06-01' existing ={
  name: domainName
}

resource eventGridDomainTopic 'Microsoft.EventGrid/domains/topics@2023-12-15-preview' = {
  parent: evgd
  name: topicName
}
