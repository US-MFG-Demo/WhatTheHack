param aadAdminObjectId string
param aadAdminUsername string
param appName string
param environment string
param location string
param subscriptionKeyName string
@secure()
param subscriptionKeyValue string

var adminAppServiceName = 'app-admin-${longName}'
var longName = '${appName}-${location}-${environment}'
var weatherFunctionAppName = 'func-weather-${longName}'
var weatherProxyFunctionAppName = 'func-weatherProxy-${longName}'
var financialAppServiceName = 'app-financial-${longName}'
var financialProxyFunctionAppName = 'func-financialProxy-${longName}'
var hrSystemFunctionAppName = 'func-hrSystem-${longName}'
var hrSystemProxyFunctionAppName = 'func-hrSystemProxy-${longName}'
var computationFunctionAppName = 'func-computation-${longName}'
var computationProxyFunctionAppName = 'func-computationProxy-${longName}'
var proxyFunctionAppName = 'func-proxy-${longName}'
var keyVaultName = 'kv-${longName}'

module loggingDeployment 'logging.bicep' = {
  name: 'loggingDeployment'
  params: {
    adminAppServiceName: adminAppServiceName
    computationFunctionAppName: computationFunctionAppName
    computationProxyFunctionAppName: computationProxyFunctionAppName
    financialAppServiceName: financialAppServiceName
    financialProxyFunctionAppName: financialProxyFunctionAppName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    longName: longName
    proxyFunctionAppName: proxyFunctionAppName
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
  }
}

module storageDeployment 'storage.bicep' = {
  name: 'storageDeployment'
  params: {
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    longName: longName
  }
}

module containerRegistryDeployment 'acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    longName: longName
  }
}

module appServicePlanDeployment 'appServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    longName: longName
  }
}

module functionDeployment 'funcs.bicep' = {
  name: 'functionsDeployment'
  params: {
    appInsightsName: loggingDeployment.outputs.appInsightsName
    appServicePlanName: appServicePlanDeployment.outputs.funcAppServicePlanName
    computationFunctionAppName: computationFunctionAppName
    computationProxyFunctionAppName: computationProxyFunctionAppName
    financialProxyFunctionAppName: financialProxyFunctionAppName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    proxyFunctionAppName: proxyFunctionAppName
    storageAccountName: storageDeployment.outputs.storageAccountName
    subscriptionKeyName: subscriptionKeyName
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
  }
}

module appServiceDeployment 'appServices.bicep' = {
  name: 'appServicesDeployment'
  params: {
    appInsightsName: loggingDeployment.outputs.appInsightsName
    appServicePlanName: appServicePlanDeployment.outputs.webAppServicePlanName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    adminAppServiceName: adminAppServiceName
    financialAppServiceName: financialAppServiceName
  }
}

module sqlDeployment 'sql.bicep' = {
  name: 'sqlDeployment'
  params: {
    aadAdminObjectId: aadAdminObjectId
    aadAdminUsername: aadAdminUsername
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    longName: longName
  }
}

module keyVaultDeployment 'keyVault.bicep' = {
  name: 'keyVaultDeployment'
  dependsOn: [
    appServiceDeployment
    functionDeployment
  ]
  params: {
    adminAppServiceName: adminAppServiceName
    computationFunctionAppName: computationFunctionAppName
    computationProxyFunctionAppName: computationProxyFunctionAppName
    financialAppServiceName: financialAppServiceName
    financialProxyFunctionAppName: financialAppServiceName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    keyVaultName: keyVaultName
    proxyFunctionAppName: proxyFunctionAppName  
    subscriptionKeyName: subscriptionKeyName
    subscriptionKeyValue: subscriptionKeyValue
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
  }
}

module weatherFunctionAppKeyDeployment 'func-weather-key.bicep' = {
  name: 'weatherFunctionAppKeyDeployment'
  params: {
    functionAppName: weatherFunctionAppName
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
    subscriptionKeyValue: subscriptionKeyValue
  }
}

output storageAccountName string = storageDeployment.outputs.storageAccountName
output containerRegistryName string = containerRegistryDeployment.outputs.containerRegistryName
output logAnalyticsWorkspaceName string = loggingDeployment.outputs.logAnalyticsWorkspaceName
output appInsightsName string = loggingDeployment.outputs.appInsightsName
