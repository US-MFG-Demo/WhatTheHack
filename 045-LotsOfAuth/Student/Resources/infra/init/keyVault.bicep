param aadAdminObjectId string
param adminAppServiceName string
param appInsightsName string
param computationFunctionAppName string
param computationProxyFunctionAppName string
param financialAppServiceName string
param financialProxyFunctionAppName string
param hrSystemFunctionAppName string
param hrSystemProxyFunctionAppName string
param logAnalyticsWorkspaceName string
param keyVaultName string
param proxyFunctionAppName string
param storageAccountName string
param subscriptionKeyName string
@secure()
param subscriptionKeyValue string
param weatherFunctionAppName string
param weatherProxyFunctionAppName string

resource adminAppService 'Microsoft.Web/sites@2021-02-01' existing = {
  name: adminAppServiceName
}

resource financialAppService 'Microsoft.Web/sites@2021-02-01' existing = {
  name: financialAppServiceName
}

resource weatherFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: weatherFunctionAppName
}

resource weatherProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: weatherProxyFunctionAppName
}

resource financialProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: financialProxyFunctionAppName
}

resource hrSystemFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: hrSystemFunctionAppName
}

resource hrSystemProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: hrSystemProxyFunctionAppName
}

resource computationFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: computationFunctionAppName
}

resource computationProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: computationProxyFunctionAppName
}

resource proxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: proxyFunctionAppName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    enabledForDeployment: true
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: aadAdminObjectId
        permissions: {
          secrets: [
            'all'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: weatherFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: weatherProxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: financialProxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: hrSystemFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: hrSystemProxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: computationFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: computationProxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: adminAppService.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: financialAppService.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: proxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }  
}

resource keyVaultSubscriptionKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: '${keyVault.name}/${subscriptionKeyName}'
  properties: {
    value: subscriptionKeyValue
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = {
  name: 'Logging'
  scope: keyVault
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

// resource weatherFunctionAppKeyVaultConfiguration 'Microsoft.Web/sites/config@2021-02-01' = {
//   name: '${weatherFunctionApp.name}/appsettings'
//   properties: {
//     'AzureWebJobsStorage': 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccount.name), '2019-06-01').keys[0].value}'
//     'AZURE_STORAGE_CONNECTION_STRING': 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccount.name), '2019-06-01').keys[0].value}'
//     'APPINSIGHTS_INSTRUMENTATIONKEY': appInsights.properties.InstrumentationKey
//     'FUNCTIONS_EXTENSION_VERSION': '~3'
//     'FUNCTIONS_WORKER_RUNTIME': 'dotnet'
//     'AzureWebJobsSecretStorageType': 'keyvault'
//     'AzureWebJobsSecretStorageKeyVaultName': keyVault.name
//   }
// }

output keyVaultName string = keyVault.name
