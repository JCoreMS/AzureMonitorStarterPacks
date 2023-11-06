param solutionTag string
param solutionVersion string
param location string
param storageAccountName string
param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param fileURL string
param containerName string
param resourceName string

var filename = split(fileURL, '/')[length(split(fileURL, '/')) - 1]
var tempfilename = 'download.tmp'
var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: sasExpiry
  signedProtocol: 'https'
  keyToSign: 'key2'
}
resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: resourceName
  tags: {
    '${solutionTag}': 'deploymentScript'
    '${solutionTag}-Version': solutionVersion
  }
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: packStorage.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: packStorage.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: fileURL
      }
    ]
    scriptContent: 'wget $CONTENT && az storage blob upload -f ${filename} -c ${containerName} -n ${filename} ' //--overwrite'
  }
}
output fileURL string = '${packStorage.properties.primaryEndpoints.blob}${containerName}/${filename}?${(packStorage.listAccountSAS(packStorage.apiVersion, sasConfig).accountSasToken)}'
