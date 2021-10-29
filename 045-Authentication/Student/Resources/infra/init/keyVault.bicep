param logAnalyticsWorkspaceName string
param longName string
param subscriptionKeyName string
@secure()
param subscriptionKeyValue string
param weatherFunctionAppName string
param weatherProxyFunctionAppName string
param financialProxyFunctionAppName string
param hrSystemFunctionAppName string
param hrSystemProxyFunctionAppName string
param computationFunctionAppName string
param computationProxyFunctionAppName string

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

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: 'kv-${longName}'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: weatherFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
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
            'set'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: financialProxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'set'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: hrSystemFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'set'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: hrSystemProxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'set'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: computationFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'set'
          ]
        }
      } 
      {
        tenantId: subscription().tenantId
        objectId: computationProxyFunctionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
            'set'
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

output keyVaultName string = keyVault.name
