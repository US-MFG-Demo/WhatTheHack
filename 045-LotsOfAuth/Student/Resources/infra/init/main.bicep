param aadAdminObjectId string
param aadAdminUsername string
param appName string
param environment string
param location string
param subscriptionKeyName string
param financialCertificateThumbprintKeyName string
param financialCertificateName string

var adminAppServiceName = 'app-admin-${longName}'
var computationFunctionAppName = 'func-computation-${longName}'
var computationProxyFunctionAppName = 'func-computationProxy-${longName}'
var databaseProxyFunctionAppName = 'func-databaseProxy-${longName}'
var financialAppServiceName = 'app-financial-${longName}'
var financialProxyFunctionAppName = 'func-financialProxy-${longName}'
var hrSystemFunctionAppName = 'func-hrSystem-${longName}'
var hrSystemProxyFunctionAppName = 'func-hrSystemProxy-${longName}'
var keyVaultName = 'kv-${longName}'
var longName = '${appName}-${location}-${environment}'
var proxyFunctionAppName = 'func-proxy-${longName}'
var weatherFunctionAppName = 'func-weather-${longName}'
var weatherProxyFunctionAppName = 'func-weatherProxy-${longName}'

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
    databaseProxyFunctionAppName: databaseProxyFunctionAppName
    financialCertificateName: financialCertificateName
    financialProxyFunctionAppName: financialProxyFunctionAppName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    proxyFunctionAppName: proxyFunctionAppName
    sqlDatabaseName: sqlDeployment.outputs.sqlDatabaseName
    sqlServerName: sqlDeployment.outputs.sqlServerName
    storageAccountName: storageDeployment.outputs.storageAccountName
    subscriptionKeyName: subscriptionKeyName
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
  }
}

module appServiceDeployment 'appServices.bicep' = {
  name: 'appServicesDeployment'
  params: {
    adminAppServiceName: adminAppServiceName
    appInsightsName: loggingDeployment.outputs.appInsightsName
    appServicePlanName: appServicePlanDeployment.outputs.webAppServicePlanName
    certificateThumbprintKeyName: financialCertificateThumbprintKeyName
    financialAppServiceName: financialAppServiceName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
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
    aadAdminObjectId: aadAdminObjectId
    adminAppServiceName: adminAppServiceName
    appInsightsName: loggingDeployment.outputs.appInsightsName
    computationFunctionAppName: computationFunctionAppName
    computationProxyFunctionAppName: computationProxyFunctionAppName
    databaseProxyFunctionAppName: databaseProxyFunctionAppName
    financialAppServiceName: financialAppServiceName
    financialProxyFunctionAppName: financialAppServiceName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    proxyFunctionAppName: proxyFunctionAppName
    storageAccountName: storageDeployment.outputs.storageAccountName
    weatherFunctionAppName: weatherFunctionAppName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
  }
}

output storageAccountName string = storageDeployment.outputs.storageAccountName
output containerRegistryName string = containerRegistryDeployment.outputs.containerRegistryName
output logAnalyticsWorkspaceName string = loggingDeployment.outputs.logAnalyticsWorkspaceName
output appInsightsName string = loggingDeployment.outputs.appInsightsName
