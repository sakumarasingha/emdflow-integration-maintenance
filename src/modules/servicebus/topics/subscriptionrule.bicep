@description('Subscription filter type')
@allowed([
  'CorrelationFilter'
  'SqlFilter'
])
param filterType string 

@description('Subscription rule name')
param ruleName string

@description('Subscription rule')
param rule string

@description('Name of the Service Bus topic')
param topicName string

@description('Name of the Service Bus subscriptions')
param subscriptionName string

@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

resource subscriptionrule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2022-10-01-preview' = {
  name: '${serviceBusNamespaceName}/${topicName}/${subscriptionName}/${ruleName}'
  properties: {
    filterType: filterType
    sqlFilter: {
      sqlExpression: rule
    }
  }
}
