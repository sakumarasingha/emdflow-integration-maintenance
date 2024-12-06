@description('Storage account name')
param storageAccountName string

@description('Storage account name')
param storageTableName string

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' existing = {
  name: storageAccountName
}
 

resource symbolicname 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-09-01' = {
  name: '${tableService.name}/default/${storageTableName}'
  properties: {
  }
}
