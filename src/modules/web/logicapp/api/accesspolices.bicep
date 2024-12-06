param connection_Name string
param systemAssignedIdentityTenantId string
param systemAssignedIdentityObjectId string

@description('Location for all resources.')
param location string = resourceGroup().location


resource accessPolicy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${connection_Name}/${systemAssignedIdentityObjectId}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: systemAssignedIdentityTenantId
        objectId: systemAssignedIdentityObjectId
      }
    }
  }
}
