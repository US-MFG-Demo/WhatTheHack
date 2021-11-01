param appInsightsName string
param appServicePlanName string
param computationFunctionAppName string
param computationProxyFunctionAppName string
param financialProxyFunctionAppName string
param hrSystemFunctionAppName string
param hrSystemProxyFunctionAppName string
param logAnalyticsWorkspaceName string
param proxyFunctionAppName string
param storageAccountName string
param weatherFunctionAppName string
param weatherProxyFunctionAppName string

var functionAppNames = [
  weatherFunctionAppName
  weatherProxyFunctionAppName
  financialProxyFunctionAppName
  hrSystemFunctionAppName
  hrSystemProxyFunctionAppName
  computationFunctionAppName
  computationProxyFunctionAppName
]

module funcDeployment 'func.bicep' = [for functionAppName in functionAppNames: {
  name: '${functionAppName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    functionAppName: functionAppName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountName: storageAccountName
  }
}]

module funcProxyDeployment 'func-proxy.bicep' = {
  name: 'funcProxyDeployment'
  dependsOn: [
    funcDeployment
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
