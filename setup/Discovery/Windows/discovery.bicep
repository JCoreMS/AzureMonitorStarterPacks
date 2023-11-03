targetScope = 'managementGroup'

param location string 
param solutionTag string
param solutionVersion string
param subscriptionId string
param resourceGroupName string
param storageAccountname string
param imageGalleryName string
param lawResourceId string
param tableName string
param userManagedIdentityResourceId string
param mgname string
param assignmentLevel string
param dceId string

//var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'WindowsDiscovery'
//var kind= 'Windows'

var appName = 'windiscovery'
var appDescription = 'Windows Workload discovery'
var OS = 'Windows'

//var resourceGroupName = split(resourceGroupId, '/')[4]

var tableNameToUse = 'Custom${tableName}${OS}_CL'
var lawFriendlyName = split(lawResourceId,'/')[8]

// VM Application to collect the data - this would be ideally an extension
module nginxcollector '../../../modules/aig/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'windiscovery'
  params: {
    aigname: imageGalleryName
    appDescription: appDescription
    appName: appName
    location: location
    osType: OS
  }
}

module upload '../../../modules/DS/uploadDS.bicep' = {
  name: 'upload-discoverywindows'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'discoverywindows'
    fileURL: 'https://github.com/FehseCorp/AzureMonitorStarterPacks/raw/imagegallery/Packs/Discovery/Windows/discover.zip'
    storageAccountName: storageAccountname
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}

module windiscovery '../../../modules/aig/aigappversion.bicep' = {
  name: 'WindowsDiscovery'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    nginxcollector
  ]
  params: {
    aigname: imageGalleryName
    appName: appName
    appVersionName: '1.0.1'
    location: location
    targetRegion: location
    mediaLink: upload.outputs.fileURL
    installCommands: 'powershell -command "ren windiscovery discover.zip; expand-archive ./discover.zip . ; ./install.ps1"'
    removeCommands: 'Unregister-ScheduledTask -TaskName "Monstar Packs Discovery" "\\"'
  }
}
module applicationPolicy '../../../modules/policies/mg/vmapplicationpolicy.bicep' = {
  name: 'applicationPolicy-${appName}'
  params: {
    packtag: 'windiscovery'
    policyDescription: 'Install ${appName} to ${OS} VMs'
    policyName: 'Install ${appName}'
    policyDisplayName: 'Install ${appName} to ${OS} VMs'
    solutionTag: solutionTag
    vmapplicationResourceId: windiscovery.outputs.appVersionId
    roledefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    ]
  }
}
// Table to receive the data
module table '../../../modules/LAW/table.bicep' = {
  name: tableNameToUse
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    parentname: lawFriendlyName
    tableName: tableNameToUse
    retentionDays: 31
  }
}
// DCR to collect the data
module windiscoveryDCR '../discoveryrule.bicep' = {
  name: 'windiscoveryDCR'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    endpointResourceId: dceId
    filepatterns: [
      'C:\\WindowsAzure\\Discovery\\*.csv'
    ]
    kind: 'Windows'
    location: location
    lawResourceId: lawResourceId
    OS: 'Windows'
    solutionTag: solutionTag
    tableName: tableNameToUse
    packtag: 'windiscovery'
  }
}

// Policy to assign DCR to all Windows VMs (in which context? MG if we want to use the same DCR for all subscriptions?)
module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-windoscovery'
  params: {
    dcrId: windiscoveryDCR.outputs.ruleId
    packtag: 'windoscovery'
    solutionTag: solutionTag
    rulename: windiscoveryDCR.outputs.ruleName
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: ruleshortname
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
  }
}
