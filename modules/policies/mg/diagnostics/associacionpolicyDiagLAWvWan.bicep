targetScope = 'managementGroup'
param policyName string
param policyDisplayName string
param policyDescription string
param packtag string
param solutionTag string
param lawId string
param roledefinitionIds array =[
  '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
  '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]

resource policy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    description: policyDescription
    displayName: '[AMSP]-${policyDisplayName}'
    metadata: {
      category: 'Monitoring'
      '${solutionTag}': packtag
    }
    policyType: 'Custom'
    mode: 'Indexed'
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag name'
          description: 'A tag to apply the association conditionally.'
        }
        defaultValue: solutionTag
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag value'
          description: 'The value of the tag.'
        }
        defaultValue: packtag
      }
      categoryGroup: {
        type: 'String'
        metadata: {
          displayName: 'Category Group'
          description: 'Diagnostic category group - none, audit, or allLogs.'
        }
        allowedValues: [
          'audit'
          'allLogs'
        ]
        defaultValue: 'allLogs'
      }
      diagnosticSettingName: {
        type: 'String'
        metadata: {
          displayName: 'Diagnostic Setting Name'
          description: 'Diagnostic Setting Name'
        }
        defaultValue: 'setByPolicy-LogAnalytics'
      }
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      lawId: {
        type: 'String'
        metadata: {
          displayName: 'LAW Id'
          description: 'The Id of the Log Analytics workspace.'
        }
        defaultValue: lawId
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]' // No need to use an additional forward square bracket in the expressions as in ARM templates
            contains : '[parameters(\'tagValue\')]'
          }
          {
            field: 'type'
            equals: 'Microsoft.Network/virtualHubs'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Network/virtualHubs/providers/diagnosticSettings'
          existenceCondition: {
            allOf: [
              {
                count: {
                  field: 'Microsoft.Insights/diagnosticSettings/logs[*]'
                  where: {
                    allOf: [
                      {
                        field: 'Microsoft.Insights/diagnosticSettings/logs[*].enabled'
                        equals: ('categoryGroup' == 'allLogs')
                      }
                      {
                        field: 'microsoft.insights/diagnosticSettings/logs[*].categoryGroup'
                        equals: 'allLogs'
                      }
                    ]
                  }
                }
                equals: 1
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
                equals: lawId
              }
            ]
          }
          //roleDefinitionIds: roledefinitionIds
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  diagnosticSettingName: {
                    type: 'string'
                  }
                  logAnalytics: {
                    type: 'string'
                  }
                  categoryGroup: {
                    type: 'string'
                  }
                  packTag: {
                    type: 'string'
                  }
                  resourceName: {
                    type: 'string'
                  }
                }
                variables: {
                }
                resources: [
                  {
                  type: 'microsoft.network/virtualnetworkgateways/providers/diagnosticSettings'
                  name: '[concat(parameters(\'resourceName\'), \'/\', \'Microsoft.Insights/\', parameters(\'diagnosticSettingName\'))]'
                  properties: {
                    workspaceId: '[parameters(\'logAnalytics\')]'
                    logs: [
                      {
                        categoryGroup: 'allLogs'
                        enabled: '[equals(parameters(\'categoryGroup\'), \'allLogs\')]'
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
                ]
              }
              parameters: {
                diagnosticSettingName: {
                  value: '[parameters(\'diagnosticSettingName\')]'
                }
                logAnalytics: {
                  value: '[parameters(\'logAnalytics\')]'
                }
                categoryGroup: {
                  value: '[parameters(\'categoryGroup\')]'
                }
                resourceName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}
output policyId string = policy.id
