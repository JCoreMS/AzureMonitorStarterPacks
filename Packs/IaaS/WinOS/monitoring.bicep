targetScope = 'managementGroup'
@description('The Tag value for this pack')
param packtag string = 'WinOS'
@description('Name of the DCR rule to be created')
param rulename string = 'AMSP-Windows-OS'
param actionGroupResourceId string
@description('location for the deployment.')
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param solutionTag string
param solutionVersion string
param dceId string
param userManagedIdentityResourceId string

param assignmentLevel string
param customerTags object

var Tags = (customerTags=={}) ? {'${solutionTag}': packtag
'solutionVersion': solutionVersion} : union({
  '${solutionTag}': packtag
  'solutionVersion': solutionVersion
},customerTags['All'])
var ruleshortname = 'VMI-OS'
var resourceGroupName = split(resourceGroupId, '/')[4]

module vmInsightsDCR '../../../modules/DCRs/DefaultVMI-rule.bicep' = {
  name: 'vmInsightsDCR-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceResourceId: workspaceId
    Tags: Tags
    ruleName: rulename
    dceId: dceId
  }
}

module InsightsAlerts './VMInsightsAlerts.bicep' = {
  name: 'Alerts-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceId: workspaceId
    AGId: actionGroupResourceId
    packtag: packtag
    Tags: Tags
  }
}

module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  scope: managementGroup(mgname)
  params: {
    dcrId: vmInsightsDCR.outputs.VMIRuleId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: ruleshortname
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
  }
}

// Azure recommended Alerts for VMs
// These are the (very) basic recommeded alerts for VM, based on platform metrics
// module vmrecommended 'AzureBasicMetricAlerts.bicep' = if (enableBasicVMPlatformAlerts) {
//   name: 'vmrecommended'
//   params: {
//     vmIDs: vmIDs
//     packtag: packtag
//     solutionTag: solutionTag
//   }
// }
