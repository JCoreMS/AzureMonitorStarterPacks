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

module ALBDipPathAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBDipAvailabilityAlert'
    params: {
        alertname: 'AMSP - Load Balancer Dip Availability'
        alertDisplayName: '[AMSP] Load Balancer Dip Availability'
        alertDescription: 'AMSP policy to deploy Load Balancer Dip Availability'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        metricName: 'DipAvailability'
        operator: 'LessThan'
        parAlertSeverity: '0'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT1M'
        parThreshold: '90'
        assignmentSuffix: 'ActALBDipAvl'
        AGId: AGId
        parAlertState: parAlertState
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
    }
}

module ALBUsedSNATPorts '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBUsedSNATPortsAlert'
    params: {
        alertname: 'AMSP - Load Balancer Metric Alert for ALB Used SNAT Ports'
        alertDisplayName: '[AMSP] Metric Alert for ALB Used SNAT Ports'
        alertDescription: 'AMSP policy to deploy Metric Alert for ALB Used SNAT Ports'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        metricName: 'UsedSNATPorts'
        operator: 'GreaterThan'
        parAlertSeverity: '1'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT1M'
        parThreshold: '900'
        assignmentSuffix: 'ActUserSNAT'
        AGId: AGId
        parAlertState: parAlertState
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
    }
}
module ALBGlobalBackendAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBDGlobalBackendAvailAlert'
    params: {
        alertname: 'AMSP - Load Balancer Global Backend Availability'
        alertDisplayName: '[AMSP] Global Backend Availability '
        alertDescription: 'AMSP policy to deploy Global Backend Availability alert'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        metricName: 'GlobalBackendAvailability'
        operator: 'GreaterThan'
        parAlertSeverity: '0'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT1M'
        parThreshold: '90'
        assignmentSuffix: 'ActALBGlbBEAvl'
        AGId: AGId
        parAlertState: parAlertState
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
    }
}
module ALBBackendAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBBackendAvailabilityAlert'
    params: {
        alertname: 'Deploy_ALB_Availability_Alert'
        alertDisplayName: '[AMSP] Deploy ALB Global Backend Availability Alert'
        alertDescription: 'AMSP policy to deploy ALB Global Backend Alert'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        parAlertSeverity: '0'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT5M'
        parThreshold: '90'
        assignmentSuffix: 'ActALBAvl'
        metricName: 'VipAvailability'
        operator: 'LessThan'
        parAlertState: parAlertState
        AGId: AGId
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
    }
}
