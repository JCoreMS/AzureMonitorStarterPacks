param settingName string
param vWanName string
param storageSyncName string
param workspaceId string

resource vWan 'Microsoft.Network/virtualHubs@2023-04-01' existing = {
  name: vWanName
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: vWan
  properties: {
    workspaceId: workspaceId
    storageAccountId: resourceId('Microsoft.Network/virtualHubs/', storageSyncName)
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

