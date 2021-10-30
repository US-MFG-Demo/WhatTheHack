param longName string

resource funcAppServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'asp-func-${longName}'
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

resource webAppServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'asp-web-${longName}'
  location: resourceGroup().location
  kind: 'web'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

output funcAppServicePlanName string = funcAppServicePlan.name
output webAppServicePlanName string = webAppServicePlan.name
