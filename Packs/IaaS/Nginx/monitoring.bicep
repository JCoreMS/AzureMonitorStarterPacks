targetScope = 'managementGroup'

param rulename string
param actionGroupName string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array  = []
param useExistingAG bool = false
param existingAGRG string = ''
param location string 
param workspaceId string
param packtag string
param solutionTag string
param solutionVersion string
param dceId string
param userManagedIdentityResourceId string
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string

var ruleshortname = 'Nginx'

var resourceGroupName = split(resourceGroupId, '/')[4]

var facilityNames = [
  'daemon'
]
var logLevels =[
  'Debug'
  'Info'
  'Notice'
  'Warning'
  'Error'
  'Critical'
  'Alert'
  'Emergency'
]

// Action Group
module ag '../../../modules/actiongroups/ag.bicep' =  {
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

module fileCollectionRule '../../../modules/DCRs/filecollectionSyslogLinux.bicep' = {
  name: 'filecollectionrule-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    endpointResourceId: dceId
    packtag: packtag
    solutionTag: solutionTag
    ruleName: rulename
    filepatterns: [
      '/var/log/nginx/access.log'
    //'/var/log/nginx/error.log'
    ]
    lawResourceId:workspaceId
    tableName: 'NginxLogs'
    facilityNames: facilityNames
    logLevels: logLevels
    syslogDataSourceName: 'NginxLogs-1238219'
  }
}
module Alerts './nginxalerts.bicep' = {
  name: 'Alerts-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    
  }
}
module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: fileCollectionRule.outputs.ruleId
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

//New stuff - VM Application
module nginxcollector '../../../modules/aig/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'nginxcollector-${packtag}'
  params: {
    aigname: 'monstargallery'
    appDescription: 'Nginx MonStar Collector'
    appName: 'nginxmonstarcollector'
    location: location
    osType: 'Linux'
  }
}

module ngnixcolv1 '../../../modules/aig/aigappversion.bicep' = {
  name: 'nginxcollectorv1-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    aigname: 'monstargallery'
    appName: 'nginxmonstarcollector'
    appVersionName: 'nginxmonstarcollectorv1'
    location: location
    targetRegion: location
    mediaLink: 'https://azmonstarpacksgvap.blob.core.windows.net/discovery/amspdiscovery.deb?sp=r&se=2023-09-07T22:06:50Z&sv=2022-11-02&sr=b&sig=VY9z%2FD9%2B7PRKLk28v7i8WIdS0SfRtpmFeWLt3OYKsU8%3D'
    installCommands: 'cd /tmp && sudo apt install ./amspcol.deb -y && ./install.sh'
    removeCommands: 'sudo apt remove amspcol -y'
  }
}
