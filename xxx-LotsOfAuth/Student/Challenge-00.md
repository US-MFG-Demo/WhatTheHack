```shell
az deployment group create --resource-group rg-lotsOfAuth-ussc-demo --template-file .\main.bicep --parameters .\demo.parameters.json --parameters subscriptionKeyValue=<add a subscription key here>
```

```shell
az storage blob service-properties update --account-name <storage-account-name> --static-website --404-document <error-document-name> --index-document index.html
```

```shell
az storage account show -n <storage-account-name> -g <resource-group-name> --query "primaryEndpoints.web" --output tsv
```