param appInsightsName string
param logAnalyticsWorkspaceName string
param longName string
param storageAccountInputContainerName string
param storageAccountName string
param storageAccountQueueName string
param weatherFunctionAppName string
param weatherProxyFunctionAppName string
param financialProxyFunctionAppName string
param hrSystemFunctionAppName string
param hrSystemProxyFunctionAppName string
param computationFunctionAppName string
param computationProxyFunctionAppName string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'asp-${longName}'
  location: resourceGroup().location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource weatherFunctionApp 'Microsoft.Web/sites@2021-01-15' = {
  name: weatherFunctionAppName
  location: resourceGroup().location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    reserved: true
    siteConfig: {
      linuxFxVersion: 'Python|3.8'
      pythonVersion: '3.8'
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
          name: 'AZURE_STORAGE_INPUT_BLOB_CONTAINER_NAME'
          value: storageAccountInputContainerName
        }
        {
          name: 'AZURE_STORAGE_QUEUE_NAME'
          value: storageAccountQueueName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource functionAppDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: weatherFunctionApp
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

