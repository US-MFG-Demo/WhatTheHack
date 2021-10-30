param longName string
param weatherFunctionAppName string
param weatherProxyFunctionAppName string
param financialProxyFunctionAppName string
param hrSystemFunctionAppName string
param hrSystemProxyFunctionAppName string
param computationFunctionAppName string
param computationProxyFunctionAppName string
param financialAppServiceName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'la-${longName}'
  location: resourceGroup().location
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${longName}'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
  }
  tags: {
    'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${weatherFunctionAppName}': 'Resource'
  }
}

output logAnalyticsWorkspaceName string = logAnalytics.name
output appInsightsName string = appInsights.name
