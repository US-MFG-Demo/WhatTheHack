param appInsightsName string
param appServicePlanName string
param functionAppName string
param logAnalyticsWorkspaceName string
param storageAccountName string
param computationProxyFunctionAppName string
param financialProxyFunctionAppName string
param hrSystemProxyFunctionAppName string
param weatherProxyFunctionAppName string
param databaseProxyFunctionAppName string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' existing = {
  name: appServicePlanName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource computationProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: computationProxyFunctionAppName
}

resource financialProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: financialProxyFunctionAppName
}

resource hrSystemProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: hrSystemProxyFunctionAppName
}

resource weatherProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: weatherProxyFunctionAppName
}

resource databaseProxyFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: databaseProxyFunctionAppName
}

resource functionApp 'Microsoft.Web/sites@2021-01-15' = {
  name: functionAppName
  location: resourceGroup().location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    reserved: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccount.name), '2019-06-01').keys[0].value}'
        }
        {
          name: 'AZURE_STORAGE_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccount.name), '2019-06-01').keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'COMPUTATION_PROXY_URL'
          value: 'https://${computationProxyFunctionApp.properties.defaultHostName}'
        }
        {
          name: 'FINANCIAL_PROXY_URL'
          value: 'https://${financialProxyFunctionApp.properties.defaultHostName}'
        }
        {
          name: 'HR_SYSTEM_PROXY_URL'
          value: 'https://${hrSystemProxyFunctionApp.properties.defaultHostName}'
        }
        {
          name: 'WEATHER_PROXY_URL'
          value: 'https://${weatherProxyFunctionApp.properties.defaultHostName}'
        }
        {
          name: 'DATABASE_PROXY_URL'
          value: 'https://${databaseProxyFunctionApp.properties.defaultHostName}'
        }
      ]
    }
  }
}

resource functionAppCors 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${functionApp.name}/web'
  properties: {
    cors: {
      allowedOrigins: [
        '*'
      ]
    }
  }
}

// resource functionAppCorsAuthentication 'Microsoft.Web/sites/config@2021-02-01' = {
//   name: '${functionAppCors.name}/authsettingsV2'
//   properties: {
//     globalValidation: {
//       requireAuthentication: true
//       unauthenticatedClientAction: 'RedirectToLoginPage'
//     }
//     identityProviders: {
//       azureActiveDirectory: {
//         registration: {
//           clientId: functionAppCorsClientId
//           clientSecretSettingName: functionAppCorsClientSecretConfigurationName
//           openIdIssuer: 'https://login.microsoftonline.com/${subscription().tenantId}'
//         }
//         validation: {
//           allowedAudiences: [
//             'api://${functionAppCorsClientId}'
//           ]
//         }
//       }
//       login: {
//         tokenStore: {
//           enable: true
//         }
//       }
//     }
//   }
// }

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource functionAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: functionApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'FunctionAppLogs'
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
