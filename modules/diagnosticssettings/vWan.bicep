param settingName string
param vpnGWName string
param logAnalyticsWSId string

resource vpnGW 'Microsoft.Network/vpnGateways@2023-04-01' existing = {
  name: vpnGWName
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: vpnGW
  properties: {
    workspaceId: logAnalyticsWSId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        timeGrain: null
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
        category: 'AllMetrics'
      }
    ]
  }
}

