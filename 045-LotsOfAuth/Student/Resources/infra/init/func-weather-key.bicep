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

resource functionAppKey 'Microsoft.Web/sites/host/functionKeys@2018-11-01' = {
  name: '${weatherFunctionApp.name}/default/sharedAccessKey'
  properties: {
    name: 'sharedAccessKey'
    value: subscriptionKeyValue
  }
}
