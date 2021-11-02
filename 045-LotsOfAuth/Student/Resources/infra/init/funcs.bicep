param appInsightsName string
param appServicePlanName string
param computationFunctionAppName string
param computationProxyFunctionAppName string
param financialProxyFunctionAppName string
param hrSystemFunctionAppName string
param hrSystemProxyFunctionAppName string
param keyVaultName string
param logAnalyticsWorkspaceName string
param proxyFunctionAppName string
param storageAccountName string
param subscriptionKeyName string
param weatherFunctionAppName string
param weatherProxyFunctionAppName string
param financialCertificateName string

module funcFinancialProxyFunctionAppDeployment 'func-financial-proxy.bicep' = {
  name: '${financialProxyFunctionAppName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: financialProxyFunctionAppName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
    keyVaultName: keyVaultName
    financialCertificateName: financialCertificateName
  }
}

module funcComputationDeployment 'func-computation.bicep' = {
  name: '${computationFunctionAppName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName 
    functionAppName: computationFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
  }
}

module funcComputationProxyDeployment 'func-computation-proxy.bicep' = {
  name: '${hrSystemProxyFunctionAppName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName 
    functionAppName: hrSystemProxyFunctionAppName
    computationFunctionAppName: computationFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
  }
}

module funcHrSystemDeployment 'func-hrSystem.bicep' = {
  name: '${hrSystemFunctionAppName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName 
    functionAppName: hrSystemFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
  }
}

module funcHrSystemProxyDeployment 'func-hrSystem-proxy.bicep' = {
  name: '${hrSystemProxyFunctionAppName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName 
    functionAppName: hrSystemProxyFunctionAppName
    hrSystemFunctionAppName: hrSystemFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
  }
}

module funcWeatherDeployment 'func-weather.bicep' = {
  name: '${weatherFunctionAppName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: weatherFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
  }
}

module funcWeatherProxyDeployment 'func-weather-proxy.bicep' = {
  name: '${weatherProxyFunctionAppName}Deployment'
  dependsOn: [
    funcWeatherDeployment
  ]
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: weatherProxyFunctionAppName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
    subscriptionKeyName: subscriptionKeyName
    weatherFunctionAppName: weatherFunctionAppName
  }
}

module funcProxyDeployment 'func-proxy.bicep' = {
  name: 'funcProxyDeployment'
  dependsOn: [
    funcFinancialProxyFunctionAppDeployment
    funcComputationDeployment
    funcComputationProxyDeployment
    funcHrSystemDeployment
    funcHrSystemProxyDeployment
    funcWeatherDeployment
    funcWeatherProxyDeployment
  ]
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    computationProxyFunctionAppName: computationProxyFunctionAppName
    financialProxyFunctionAppName: financialProxyFunctionAppName
    functionAppName: proxyFunctionAppName
    hrSystemProxyFunctionAppName: hrSystemProxyFunctionAppName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
    weatherProxyFunctionAppName: weatherProxyFunctionAppName
  }
}
