param adminAppServiceName string
param appInsightsName string
param appServicePlanName string
param financialAppServiceName string
param logAnalyticsWorkspaceName string
param keyVaultName string
param certificateThumbprintKeyName string

module appServiceFinancialDeployment 'appService-financial.bicep' = {
  name: '${financialAppServiceName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServiceName: financialAppServiceName
    appServicePlanName: appServicePlanName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    keyVaultName: keyVaultName
    certificateThumbprintKeyName: certificateThumbprintKeyName
  }
}

module appServiceAdminDeployment 'appService-admin.bicep' = {
  name: '${adminAppServiceName}Deployment'
  params: {
    appInsightsName: appInsightsName
    appServiceName: adminAppServiceName
    appServicePlanName: appServicePlanName 
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}
