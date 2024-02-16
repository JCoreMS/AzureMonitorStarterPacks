targetScope = 'managementGroup'
param solutionTag string
param packTag string
param subscriptionId string
param mgname string
param resourceType string
param policyLocation string
param parResourceGroupName string
param assignmentLevel string
param userManagedIdentityResourceId string
param AGId string
param instanceName string

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
// param parResourceGroupTags object = {
//     environment: 'test'
// }
param parAlertState string = 'true'

module Alert1 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunsFailed'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'RunsFailed - workflows'
      alertDisplayName: 'RunsFailed - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow runs failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunsFailed'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'Metworkflows1'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert2 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ActionsFailed'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'ActionsFailed - workflows'
      alertDisplayName: 'ActionsFailed - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow actions failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'ActionsFailed'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'Metworkflows2'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert3 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggersFailed'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'TriggersFailed - workflows'
      alertDisplayName: 'TriggersFailed - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow triggers failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'TriggersFailed'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'Metworkflows3'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert4 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunLatency'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'RunLatency - workflows'
      alertDisplayName: 'RunLatency - Microsoft.Logic/workflows'
      alertDescription: 'Latency of completed workflow runs.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '99999'
      assignmentSuffix: 'Metworkflows4'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
module Alert5 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunFailurePercentage'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'RunFailurePercentage - workflows'
      alertDisplayName: 'RunFailurePercentage - Microsoft.Logic/workflows'
      alertDescription: 'Percentage of workflow runs failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '2'
      metricName: 'RunFailurePercentage'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT15M'   
      parWindowSize: 'PT1H'
      parThreshold: '50'
      assignmentSuffix: 'Metworkflows5'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert6 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ActionLatency'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'ActionLatency - workflows'
      alertDisplayName: 'ActionLatency - Microsoft.Logic/workflows'
      alertDescription: 'Latency of completed workflow actions.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'ActionLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '15'
      assignmentSuffix: 'Metworkflows6'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
module Alert7 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggerLatency'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'TriggerLatency - workflows'
      alertDisplayName: 'TriggerLatency - Microsoft.Logic/workflows'
      alertDescription: 'Latency of completed workflow triggers.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'TriggerLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '15'
      assignmentSuffix: 'Metworkflows7'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
module Alert8 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggerThrottledEvents'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'TriggerThrottledEvents - workflows'
      alertDisplayName: 'TriggerThrottledEvents - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow trigger throttled events.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'TriggerThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'Metworkflows8'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert9 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ActionThrottledEvents'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'ActionThrottledEvents - workflows'
      alertDisplayName: 'ActionThrottledEvents - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow action throttled events..'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'ActionThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'Metworkflows9'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert10 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggersSkipped'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'TriggersSkipped - workflows'
      alertDisplayName: 'TriggersSkipped - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow triggers skipped.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '2'
      metricName: 'TriggersSkipped'
      operator: 'GreaterThanOrEqual'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      parThreshold: '5'
      assignmentSuffix: 'Metworkflows10'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Count'
    }
  }
module Alert11 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunStartThrottledEvents'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'RunStartThrottledEvents - workflows'
      alertDisplayName: 'RunStartThrottledEvents - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow run start throttled events.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunStartThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'Metworkflows11'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert12 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunThrottledEvents'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: 'RunThrottledEvents - workflows'
      alertDisplayName: 'RunThrottledEvents - Microsoft.Logic/workflows'
      alertDescription: 'Number of workflow action or trigger throttled events.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '1'
      assignmentSuffix: 'Metworkflows12'
      parAutoMitigate: 'False.tolower)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
