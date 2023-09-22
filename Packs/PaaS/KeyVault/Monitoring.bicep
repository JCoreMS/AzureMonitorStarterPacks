targetScope = 'managementGroup'
param workspaceId string
param packtag string
param solutionTag string

param location string //= resourceGroup().location
param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param actionGroupName string = ''
param emailreceivers array = []
param emailreiceversemails array = []
param useExistingAG bool 
param existingAGRG string = ''
param resourceGroupId string
param solutionVersion string

var resourceType = 'Microsoft.KeyVault/vaults'
//var resourceShortType = split(resourceType, '/')[1]

var resourceGroupName = split(resourceGroupId, '/')[4]

// Action Group - the action group is either created or can reference an existing action group, depending on the useExistingAG parameter
module ag '../../../modules/actiongroups/ag.bicep' = {
  name: actionGroupName
  params: {
    actionGroupName: actionGroupName
    existingAGRG: existingAGRG
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    useExistingAG: useExistingAG
    newRGresourceGroup: resourceGroupName
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    location: location
  }
}

module diagnosticsPolicy '../../../modules/policies/mg/diagnostics/associacionpolicyDiag.bicep' = {
  name: 'associacionpolicy-${packtag}-${split(resourceType, '/')[1]}'
  params: {
    logAnalyticsWSResourceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
    policyDescription: 'Policy to associate the diagnostics setting for ${split(resourceType, '/')[1]} resources the tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the diagnostics with the ${split(resourceType, '/')[1]} resources tagged with ${packtag} tag.'
    policyName: 'Associate-diagnostics-${packtag}-${split(resourceType, '/')[1]}'
    resourceType: resourceType
  }
}

module policyassignment '../../../modules/policies/mg/policiesDiag.bicep' =  {
  name: 'diagassignment-${packtag}-${split(resourceType, '/')[1]}'
  dependsOn: [
    diagnosticsPolicy
  ]
  params: {
    location: location
    mgname: mgname
    packtag: packtag
    policydefinitionId: diagnosticsPolicy.outputs.policyId
    resourceType: resourceType
    solutionTag: solutionTag
    subscriptionId: subscriptionId 
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    policyType: 'diag'
  }
}

module KVAlert 'Alerts.bicep' = {
  name: 'Keyvault-Alerts'
  params: {
    packTag: packtag
    policyLocation: location
    solutionTag: solutionTag
    parResourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
    mgname: mgname
    resourceType: resourceType
    assignmentLevel: assignmentLevel
    userManagedIdentityResourceId: userManagedIdentityResourceId
    AGId: ag.outputs.actionGroupResourceId
  }
}
