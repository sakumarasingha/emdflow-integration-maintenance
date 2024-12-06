// --------------------------------------------------------------
// Parameters
// --------------------------------------------------------------
@description('The type of environment being deployed')
param environment string

@description('Tag list and values')
param tagList object

@description('The primary location full being deployed to.')
@allowed([
  'australiaeast'
  'australiasoutheast'
])
param locationFull string

@description('Resource Group for Core Services')
param rgCoreService string

@description('Resource Group Name')
param rgName string

@description('Private Dns Zone Resource Group Name.')
param privateDnsZoneRgName string

@description('Log Analytics Name')
param omsWorkspaceName string

@description('Log Analytics Resource Group Name')
param omsWorkspaceRgName string

@description('VNET Name')
param vnetName string

@description('VNET RG Name')
param vnetRgName string

@description('Email Recipients')
param emailRecipients string

// --------------------------------------------------------------
// Variables
// --------------------------------------------------------------
var region = {
  australiaeast: 'AE'
  australiasoutheast: 'ASE'
  eastasia: 'EA'
  southeastasia: 'SEA'
}

var laNameexpiryProcessing = toLower('logic-custom-alerts-${environment}-${region[locationFull]}')
var appInsightName = toLower('appi-integration-${environment}-${region[locationFull]}-001')
var storageaccountName = toLower('saevents${environment}${region[locationFull]}001')
var laHostingPlanName = toLower('asp-integration-la-${environment}-${region[locationFull]}-001')
var keyvaultName = toLower('kv-integ-${environment}-${region[locationFull]}-001')
var serviceBusNamespaceName = toLower('sb-integration-${environment}-${region[locationFull]}-001')
var subnetName = toLower('snet-app-integration-${environment}-${region[locationFull]}')
var subnetNamePvt = toLower('snet-pvt-integration-${environment}-${region[locationFull]}')
var domainName = toLower('evgd-integration-${environment}-${region[locationFull]}-001')
var queueNameKVEvents = 'sbq-keyvault-events'
var deadLetterContainerName = 'resource-events-failed'
var egdTopicSubNameKvEvents = 'kv-events-all'
var egdTopicName = 'keyvault-resource-events'

resource oms 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  scope: resourceGroup(omsWorkspaceRgName)
  name: omsWorkspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  scope: resourceGroup(rgCoreService)
  name: appInsightName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  scope: resourceGroup(rgName)
  name: storageaccountName
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
  scope: resourceGroup(rgName)
  name: laHostingPlanName
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  scope: resourceGroup(rgCoreService)
  name: keyvaultName
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  scope: resourceGroup(rgCoreService)
  name: serviceBusNamespaceName
}

resource evgd 'Microsoft.EventGrid/domains@2020-06-01' existing = {
  scope: resourceGroup(rgName)
  name: domainName
}

//Office 365 API Connection
module la_office365_connection '../modules/web/logicapp/api/office365-connection.bicep' = {
  name: 'la_office365_connection'
  dependsOn: []
  params: {
    connectionName: 'office365'
    displayName: 'Office 365 Connection ${environment}'
    location: locationFull
    tagList: tagList
  }
}

//Create Logic App - App Registration Expiry Check
module la_expiry_check '../modules/web/logicapp/logicapp.bicep' = {
  name: 'deploy_la_expiry_check'
  dependsOn: [
    storageAccount
    hostingPlan
    la_office365_connection
  ]
  params: {
    location: locationFull
    tagList: union(tagList, { ResourceType: 'LogicApps' })
    logicAppName: laNameexpiryProcessing
    hostingPlanId: hostingPlan.id
    omsWorkspaceId: oms.id
    whitelistingIps: []
    appSettings: [
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appInsights.properties.InstrumentationKey
      }
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~4'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'node'
      }
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '~18'
      }
      {
        name: 'AzureWebJobsStorage'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccountName};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      }
      {
        name: 'APP_KIND'
        value: 'workflowApp'
      }
      {
        name: 'WORKFLOWS_SUBSCRIPTION_ID'
        value: subscription().subscriptionId
      }
      {
        name: 'WORKFLOWS_TENANT_ID'
        value: tenant().tenantId
      }
      {
        name: 'WORKFLOWS_RESOURCE_GROUP_NAME'
        value: resourceGroup().name
      }
      {
        name: 'WORKFLOWS_LOCATION_NAME'
        value: locationFull
      }
      {
        name: 'serviceBus_fullyQualifiedNamespace'
        value: '${serviceBusNamespaceName}.servicebus.windows.net'
      }
      {
        name: 'keyVault_VaultUri'
        value: keyvault.properties.vaultUri
      }
      {
        name: 'emailRecipients'
        value: emailRecipients
      }
      {
        name: 'emailEnvironment'
        value: environment
      }
      {
        name: 'Workflows.AppRegExpiryCheck.FlowState'
        value: environment == 'prd' ? 'Enabled' : 'Disabled'
      }
      {
        name: 'office365ConnectionUrl'
        value: la_office365_connection.outputs.runtimeUrl
      }
    ]
    connectionStrings: []
  }
}

//Office 365 API Connection
module la_office365_connection_policy '../modules/web/logicapp/api/accesspolices.bicep' = {
  name: 'la_office365_connection_policy'
  dependsOn: []
  params: {
    connection_Name: 'office365'
    systemAssignedIdentityObjectId: la_expiry_check.outputs.identity_objectid
    systemAssignedIdentityTenantId: tenant().tenantId
  }
}

//Logic App - VNET Integration
module la_sp_expiry_check_vnet '../modules/web/vnet/vnet.bicep' = {
  name: 'deploy_la_ahpra_processing_vnet'
  dependsOn: [
    la_expiry_check
  ]
  params: {
    siteName: laNameexpiryProcessing
    vnetName: vnetName
    vnetRgName: vnetRgName
    subnetName: subnetName
  }
}

//LA Private Endpoint
module la_sp_expiry_check_pe '../modules/privateendpoint/pe.bicep' = {
  name: 'deploy_la_sp_expiry_check_pe'
  scope: resourceGroup(privateDnsZoneRgName)
  dependsOn: [
    la_expiry_check
  ]
  params: {
    location: locationFull
    privateEndpointName: '${laNameexpiryProcessing}-pe'
    resourceId: la_expiry_check.outputs.resourceId
    subnetName: subnetNamePvt
    subResourceName: 'sites'
    vnetName: vnetName
    vnetRgName: vnetRgName
    dnsGroupName: 'integration-${environment}'
    privateDnsZoneName: 'privatelink.azurewebsites.net'
    privateDnsZoneRgName: privateDnsZoneRgName
    tagList: union(tagList, { ResourceType: 'PrivateEndpoints' })
  }
}

//Role Assigment - KeyVault Secret Reader
module la_sp_expiry_check_kv_secret_reader '../modules/rbac/roleassignment_kv.bicep' = {
  scope: resourceGroup(rgCoreService)
  name: 'deploy_la_sp_expiry_check__kv_secret_reader'
  dependsOn: [
    la_expiry_check
  ]
  params: {
    keyvaultName: keyvault.name
    roleDefinition: 'Key Vault Secrets User'
    principalId: la_expiry_check.outputs.identity_objectid
  }
}

//Role Assigment - Service Bus Receiver
module la_renewal_processing_sb_receiver '../modules/rbac/roleassignment_sb.bicep' = {
  scope: resourceGroup(rgCoreService)
  name: 'deploy_la_renewal_processing_sb_receiver'
  dependsOn: [
    la_expiry_check
  ]
  params: {
    serviceBusNamespaceName: serviceBus.name
    roleDefinition: 'Azure Service Bus Data Receiver'
    principalId: la_expiry_check.outputs.identity_objectid
  }
}

//Role Assigment - Service Bus Sender
module la_renewal_processing_sb_sender '../modules/rbac/roleassignment_sb.bicep' = {
  scope: resourceGroup(rgCoreService)
  name: 'deploy_la_renewal_processing_sb_sender'
  dependsOn: [
    la_expiry_check
  ]
  params: {
    serviceBusNamespaceName: serviceBus.name
    roleDefinition: 'Azure Service Bus Data Sender'
    principalId: la_expiry_check.outputs.identity_objectid
  }
}

//Create service bus queue to receive KeyVault events
module servicebus_queue_kv_events '../modules/servicebus/queue.bicep' = {
  name: 'deploy_servicebus_queue_kv_events'
  scope: resourceGroup(rgCoreService)
  dependsOn: []
  params: {
    serviceBusNamespaceName: serviceBus.name
    queueName: queueNameKVEvents
    duplicateDetectionTimeWindow: 'PT1M'
    lockDuration: 'PT2M'
  }
}

//Blob Container for Event DeadLettering
module st_blobcontainer_deadlettering '../modules/storage/blob-container.bicep' = {
  name: 'deploy_st_blob_deadlettering'
  dependsOn: [
    storageAccount
  ]
  scope: resourceGroup(rgName)
  params: {
    storageAccountName: storageaccountName
    blobContainerName: deadLetterContainerName
  }
}

//Event Grid System Topic
module eventgrid_system_topic_kv_events '../modules/eventgrid/system-topic.bicep' = {
  scope: resourceGroup(rgCoreService)
  name: 'deploy_eventgrid_system_topic_kv_events'
  dependsOn: []
  params: {
    systemTopicName: egdTopicName
    location: locationFull
    eventSourceId: keyvault.id
    eventSourceType: 'Microsoft.KeyVault.vaults'
  }
}

//Event Grid System Topic Subscription
module eventgrid_topic_sub_kv_events '../modules/eventgrid/system-topic-sub.bicep' = {
  scope: resourceGroup(rgCoreService)
  name: 'deploy_eventgrid_topic_sub_kv_events'
  dependsOn: [
    servicebus_queue_kv_events
    evgd
    storageAccount
  ]
  params: {
    systemTopicName: eventgrid_system_topic_kv_events.outputs.name
    systemTopicSubName: egdTopicSubNameKvEvents
    endpointType: 'ServiceBusQueue'
    eventTypes: [
      'Microsoft.KeyVault.CertificateNearExpiry'
      'Microsoft.KeyVault.CertificateExpired'
      'Microsoft.KeyVault.SecretNearExpiry'
      'Microsoft.KeyVault.SecretExpired'
      'Microsoft.KeyVault.KeyNearExpiry'
      'Microsoft.KeyVault.KeyExpired'
    ]
    endpointResourceId: servicebus_queue_kv_events.outputs.id
  }
}
