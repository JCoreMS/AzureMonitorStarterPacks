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
//param solutionVersion string

var resourceType = 'Microsoft.Network/loadBalancers'
//var resourceShortType = split(resourceType, '/')[1]

var resourceGroupName = split(resourceGroupId, '/')[4]

// Action Group - the action group is either created or can reference an existing action group, depending on the useExistingAG parameter
module ag '../../../../modules/actiongroups/ag.bicep' = {
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

module LBAlerts 'Alerts.bicep' = {
  name: 'LB-Alerts'
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
