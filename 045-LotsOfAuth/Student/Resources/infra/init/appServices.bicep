param adminAppServiceName string
param appInsightsName string
param appServicePlanName string
param financialAppServiceName string
param logAnalyticsWorkspaceName string

var appServiceNames = [
  adminAppServiceName
  financialAppServiceName
]

module appServiceDeployment 'appService.bicep' = [for appServiceName in appServiceNames: {
  name: '${appServiceName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServicePlanName: appServicePlanName
    appServiceName: appServiceName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}]
