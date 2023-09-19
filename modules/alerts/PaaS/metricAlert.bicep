// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

targetScope = 'managementGroup'
param assignmentSuffix string //used to differenciate the assignment names, based on some criteria
param alertname string
param alertDisplayName string
param alertDescription string
param solutionTag string
param packTag string
// param parResourceGroupTags object = {
//   environment: 'test'
// }
// param parResourceGroupName string
param subscriptionId string
param mgname string
param assignmentLevel string
param userManagedIdentityResourceId string
param resourceTypes array

param metricNamespace string

param policyLocation string
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

@allowed([
    '0'
    '1'
    '2'
    '3'
    '4'
])
param parAlertSeverity string = '3'

@allowed([
    'PT1M'
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
    'PT6H'
    'PT12H'
    'P1D'
])
param parWindowSize string = 'PT5M'

@allowed([
    'PT1M'
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
])
param parEvaluationFrequency string = 'PT5M'

@allowed([
    'deployIfNotExists'
    'disabled'
])
param parPolicyEffect string = 'disabled'

param parAutoMitigate string = 'true'

param parAlertState string = 'true'

param parThreshold string = '1000'

param parMonitorDisable string = 'MonitorDisable' 

module metricAlert '../../alz/deploy.bicep' = {
    name: guid(alertname)
    params: {
        name: alertname
        displayName: alertDisplayName
        description: alertDescription
        location: policyLocation
        metadata: {
            version: '1.0.0'
            Category: 'Key Vault'
            source: 'https://github.com/Azure/ALZ-Monitor/'
            '${solutionTag}': packTag
        }
        parameters: {
            severity: {
                type: 'String'
                metadata: {
                    displayName: 'Severity'
                    description: 'Severity of the Alert'
                }
                allowedValues: [
                    '0'
                    '1'
                    '2'
                    '3'
                    '4'
                ]
                defaultValue: parAlertSeverity
            }
            windowSize: {
                type: 'String'
                metadata: {
                    displayName: 'Window Size'
                    description: 'Window size for the alert'
                }
                allowedValues: [
                    'PT1M'
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                    'PT6H'
                    'PT12H'
                    'P1D'
                ]
                defaultValue: parWindowSize
            }
            evaluationFrequency: {
                type: 'String'
                metadata: {
                    displayName: 'Evaluation Frequency'
                    description: 'Evaluation frequency for the alert'
                }
                allowedValues: [
                    'PT1M'
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                ]
                defaultValue: parEvaluationFrequency
            }
            autoMitigate: {
                type: 'String'
                metadata: {
                    displayName: 'Auto Mitigate'
                    description: 'Auto Mitigate for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parAutoMitigate
            }
            enabled: {
                type: 'String'
                metadata: {
                    displayName: 'Alert State'
                    description: 'Alert state for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parAlertState
            }
            threshold: {
                type: 'String'
                metadata: {
                    displayName: 'Threshold'
                    description: 'Threshold for the alert'
                }
                defaultValue: parThreshold
            }
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
                  displayName: 'Tag Value'
                  description: 'A tag to apply the association conditionally.'
                }
                defaultValue: packTag
            }
            metricNamespace: {
                type: 'String'
                metadata: {
                    displayName: 'Metric Namespace'
                    description: 'Metric Namespace for the alert'
                }
                defaultValue: metricNamespace
            }
            effect: {
                type: 'String'
                metadata: {
                    displayName: 'Effect'
                    description: 'Effect of the policy'
                }
                allowedValues: [
                    'deployIfNotExists'
                    'disabled'
                ]
                defaultValue: parPolicyEffect
            }
            // MonitorDisable: {
            //     type: 'String'
            //     metadata: {
            //         displayName: 'Effect'
            //         description: 'Tag name to disable monitoring resource. Set to true if monitoring should be disabled'
            //     }
          
            //     defaultValue: parMonitorDisable
            // }
        }
        policyRule: {
            if: {
                allOf: [
                    {
                        field: 'type'
                        equals: 'microsoft.keyvault/vaults'
                    }
                    {
                        field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
                        contains : '[parameters(\'tagValue\')]'
                    }
                ]
            }
            then: {
                effect: '[parameters(\'effect\')]'
                details: {
                    roleDefinitionIds: deploymentRoleDefinitionIds
                    type: 'Microsoft.Insights/metricAlerts'
                    existenceCondition: {
                        allOf: [
                            {
                                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.allOf[*].metricNamespace'
                                equals: 'microsoft.keyvault/vaults'
                            }
                            {
                                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.allOf[*].metricName'
                                equals: 'ServiceApiLatency'
                            }
                            {
                                field: 'Microsoft.Insights/metricalerts/scopes[*]'
                                equals: '[concat(subscription().id, \'/resourceGroups/\', resourceGroup().name, \'/providers/microsoft.keyvault/vaults/\', field(\'fullName\'))]'
                            }
                            {
                                field: 'Microsoft.Insights/metricAlerts/enabled'
                                equals: '[parameters(\'enabled\')]'
                            }
                        ]
                    }
                    deployment: {
                        properties: {
                            mode: 'incremental'
                            template: {
                                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                contentVersion: '1.0.0.0'
                                parameters: {
                                    resourceName: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'resourceName'
                                            description: 'Name of the resource'
                                        }
                                    }
                                    resourceId: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'resourceId'
                                            description: 'Resource ID of the resource emitting the metric that will be used for the comparison'
                                        }
                                    }
                                    metricNamespace : {
                                      type: 'String'
                                      metadata: {
                                          displayName: 'metricNamespace'
                                          description: 'Metric namespace of the metric that will be used for the comparison'
                                      }
                                    }
                                    description: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'description'
                                            description: 'Description of the alert'
                                        }
                                    }
                                    severity: {
                                        type: 'String'
                                    }
                                    windowSize: {
                                        type: 'String'
                                    }
                                    evaluationFrequency: {
                                        type: 'String'
                                    }
                                    autoMitigate: {
                                        type: 'String'
                                    }
                                    enabled: {
                                        type: 'String'
                                    }
                                    threshold: {
                                        type: 'String'
                                    }
                                }
                                variables: {}
                                resources: [
                                    {
                                        type: 'Microsoft.Insights/metricAlerts'
                                        apiVersion: '2018-03-01'
                                        name: '[concat(parameters(\'resourceName\'), \'-LatencyAlert\')]'
                                        location: 'global'
                                        tags: {
                                            '[parameters(\'solutionTag\')]': '[parameters(\'packTag\')]'
                                        }
                                        properties: {
                                            description: '[parameters(\'description\')]'
                                            severity: '[parameters(\'severity\')]'
                                            enabled: '[parameters(\'enabled\')]'
                                            scopes: [
                                                '[parameters(\'resourceId\')]'
                                            ]
                                            evaluationFrequency: '[parameters(\'evaluationFrequency\')]'
                                            windowSize: '[parameters(\'windowSize\')]'
                                            criteria: {
                                                allOf: [
                                                    {
                                                        name: 'ServiceApiLatency'
                                                        metricNamespace: '[parameters(\'metricNamespace\')]'
                                                        metricName: 'ServiceApiLatency'
                                                        operator: 'GreaterThan'
                                                        threshold: '[parameters(\'threshold\')]'
                                                        timeAggregation: 'Average'
                                                        criterionType: 'StaticThresholdCriterion'
                                                    }
                                                ]
                                                'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
                                            }
                                            autoMitigate: '[parameters(\'autoMitigate\')]'
                                            parameters: {
                                                severity: {
                                                    value: '[parameters(\'severity\')]'
                                                }
                                                windowSize: {
                                                    value: '[parameters(\'windowSize\')]'
                                                }
                                                evaluationFrequency: {
                                                    value: '[parameters(\'evaluationFrequency\')]'
                                                }
                                                autoMitigate: {
                                                    value: '[parameters(\'autoMitigate\')]'
                                                }
                                                enabled: {
                                                    value: '[parameters(\'enabled\')]'
                                                }
                                                threshold: {
                                                    value: '[parameters(\'threshold\')]'
                                                }
                                                metricNamespace: {
                                                    value: '[parameters(\'metricNamespace\')]'
                                                }
                                                description: {
                                                    value: '[parameters(\'description\')]'
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                            parameters: {
                                resourceName: {
                                    value: '[field(\'name\')]'
                                }
                                resourceId: {
                                    value: '[field(\'id\')]'
                                }
                                severity: {
                                    value: '[parameters(\'severity\')]'
                                }
                                windowSize: {
                                    value: '[parameters(\'windowSize\')]'
                                }
                                evaluationFrequency: {
                                    value: '[parameters(\'evaluationFrequency\')]'
                                }
                                autoMitigate: {
                                    value: '[parameters(\'autoMitigate\')]'
                                }
                                enabled: {
                                    value: '[parameters(\'enabled\')]'
                                }
                                threshold: {
                                    value: '[parameters(\'threshold\')]'
                                }
                                metricNamespace: {
                                    value: '[parameters(\'metricNamespace\')]'
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module policyassignment '../../../modules/policies/mg/policiesDiag.bicep' = [for (rt,i) in resourceTypes: {
  name: guid('${alertname}-${i}-${assignmentSuffix}')
  dependsOn: [
    metricAlert
  ]
  params: {
    location: policyLocation
    mgname: mgname
    packtag: packTag
    policydefinitionId: metricAlert.outputs.resourceId
    resourceType: rt
    solutionTag: solutionTag
    subscriptionId: subscriptionId 
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    policyType: 'alert'
    assignmentSuffix: assignmentSuffix
  }
}]

output policyResourceId string = metricAlert.outputs.resourceId
