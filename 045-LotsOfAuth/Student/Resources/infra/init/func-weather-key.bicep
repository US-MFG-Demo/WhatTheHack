param functionAppName string
param keyVaultName string
@secure()
param subscriptionKeyValue string

resource weatherFunctionApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: functionAppName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

resource functionAppKey 'Microsoft.Web/sites/functions/keys@2021-02-01' = {
  name: '${weatherFunctionApp.name}/weather/default'
  value: subscriptionKeyValue
}
