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

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
param parResourceGroupTags object = {
    environment: 'test'
}
param parAlertState string = 'true'

module ALBDataPathAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBDataPathAvailabilityAlert'
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
        alertname: 'Deploy_ALB_Availability_Alert'
        alertDisplayName: '[AMSP] Deploy ALB Availability Alert'
        alertDescription: 'AMSP policy to deploy ALB availability alerts Alert'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        parAlertSeverity: '2'
        parAlertState: parAlertState
        parAutoMitigate: 'true'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT1M'
        parThreshold: '90'
        assignmentSuffix: 'ActALBAvl'
        AGId: AGId
        metricName: 'VipAvailability'
        operator: 'LessThan'
    }
}

module ALBBackendAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBBackendAvailabilityAlert'
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
        alertname: 'Deploy_ALB_Availability_Alert'
        alertDisplayName: '[AMSP] Deploy ALB Global Backend Availability Alert'
        alertDescription: 'AMSP policy to deploy ALB Global Backend Alert'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        parAlertSeverity: '1'
        parAlertState: parAlertState
        parAutoMitigate: 'true'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT5M'
        parThreshold: '90'
        assignmentSuffix: 'ActALBAvl'
        AGId: AGId
        metricName: 'VipAvailability'
        operator: 'LessThan'
    }
}
