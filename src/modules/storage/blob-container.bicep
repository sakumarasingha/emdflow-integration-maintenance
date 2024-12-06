@description('Storage account name')
param storageAccountName string

@description('Storage Blob Container Name')
param blobContainerName string


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccount.name}/default/${blobContainerName}'
  dependsOn: [
    storageAccount
  ]
}

output storageContainerName string = blobContainer.name
