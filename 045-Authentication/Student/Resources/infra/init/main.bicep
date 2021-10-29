param appName string
param environment string
param location string
param subscriptionKeyName string
@secure()
param subscriptionKeyValue string
param aadAdminSid string
param aadAdminUsername string

var longName = '${appName}-${location}-${environment}'
var weatherFunctionAppName = 'func-${longName}'
var weatherProxyFunctionAppName = 'func-${longName}'
var financialAppServiceName = 'func-${longName}'
var financialProxyFunctionAppName = 'func-${longName}'
var hrSystemFunctionAppName = 'func-${longName}'
var hrSystemProxyFunctionAppName = 'func-${longName}'
var computationFunctionAppName = 'func-${longName}'
var computationProxyFunctionAppName = 'func-${longName}'

module loggingDeployment 'logging.bicep' = {
  name: 'loggingDeployment'
  params: {
    longName: longName
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
    financialAppServiceName: financialAppServiceName
    financialProxyFunctionAppName: financialProxyFunctionAppName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    computationFunctionAppName: computationFunctionAppName
    computationProxyFunctionAppName: computationProxyFunctionAppName
  }
}

module storageDeployment 'storage.bicep' = {
  name: 'storageDeployment'
  params: {
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
  }
}

module containerRegistryDeployment 'acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
  }
}

module functionDeployment 'func.bicep' = {
  name: 'functionDeployment'
  params: {
    longName: longName
    storageAccountInputContainerName: storageDeployment.outputs.inputContainerName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    appInsightsName: loggingDeployment.outputs.appInsightsName
    storageAccountQueueName: storageDeployment.outputs.inputQueueName
    storageAccountName: storageDeployment.outputs.storageAccountName
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
    financialProxyFunctionAppName: financialProxyFunctionAppName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    computationFunctionAppName: computationFunctionAppName
    computationProxyFunctionAppName: computationProxyFunctionAppName
  }
}

module appServiceDeployment 'appService.bicep' = {
  name: 'appServiceDeployment'
  params: {
    appInsightsName: loggingDeployment.outputs.appInsightsName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    longName: longName
  }
}

module sqlDeployment 'sql.bicep' = {
  name: 'sqlDeployment'
  params: {
    aadAdminSid: aadAdminSid
    aadAdminUsername: aadAdminUsername
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    longName: longName
  }
}

module keyVaultDeployment 'keyVault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    computationFunctionAppName: computationFunctionAppName
    computationProxyFunctionAppName: computationProxyFunctionAppName
    financialProxyFunctionAppName: financialAppServiceName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    subscriptionKeyName: subscriptionKeyName
    subscriptionKeyValue: subscriptionKeyValue
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
  }
}

output storageAccountName string = storageDeployment.outputs.storageAccountName
output storageAccountInputContainerName string = storageDeployment.outputs.inputContainerName
output storageAccountInputQueueName string = storageDeployment.outputs.inputQueueName
output storageAccountOutputContainerName string = storageDeployment.outputs.outputContainerName
output containerRegistryName string = containerRegistryDeployment.outputs.containerRegistryName
output logAnalyticsWorkspaceName string = loggingDeployment.outputs.logAnalyticsWorkspaceName
output appInsightsName string = loggingDeployment.outputs.appInsightsName
