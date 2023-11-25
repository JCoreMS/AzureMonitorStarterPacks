targetScope = 'managementGroup'
param packtag string = 'OperAI'
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string = '0.1.0'
@description('Name of the DCR rule to be created')
param rulename string = ''
@description('Name of the Action Group to be used or created.')
param actionGroupName string
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceivers array = []
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemails array  = []
@description('If set to true, a new Action group will be created')
param useExistingAG bool = false
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string

@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')

param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param resourceGroupId string
param grafanaName string
var resourceType = 'Microsoft.Network/loadBalancers'
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
