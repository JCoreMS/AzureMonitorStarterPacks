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
param pathToPackage string = 'https://github.com/FehseCorp/AzureMonitorStarterPacks/raw/imagegallery/setup/Discovery/Linux/discover.tar'

//var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'LinuxDiscovery'
var appName = 'LxDiscovery'
var appDescription = 'Linux Workload discovery'
var OS = 'Linux'

//var resourceGroupName = split(resourceGroupId, '/')[4]

var tableNameToUse = 'Custom${tableName}_CL'
var lawFriendlyName = split(lawResourceId,'/')[8]

// VM Application to collect the data - this would be ideally an extension
module linuxdiscoveryapp '../../../modules/aig/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'linuxdiscovery'
  params: {
    aigname: imageGalleryName
    appDescription: appDescription
    appName: appName
    location: location
    osType: OS
  }
}

module upload '../../../modules/DS/uploadDS.bicep' = {
  name: 'upload-discoverylinux'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'discovery'
    fileURL: pathToPackage
    storageAccountName: storageAccountname
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    resourceName: 'deployscript-MonstarPacksDiscoveryLinux'
  }
}

module linuxDiscovery '../../../modules/aig/aigappversion.bicep' = {
  name: 'linuxDiscoveryAppVersion'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    linuxdiscoveryapp
  ]
  params: {
    aigname: imageGalleryName
    appName: appName
    appVersionName: '1.0.1'
    location: location
    targetRegion: location
    mediaLink: upload.outputs.fileURL
    installCommands: 'tar -xvf ${appName} && ./install.sh'
    removeCommands: '/opt/microsoft/discovery/uninstall.sh'
  }
}
module applicationPolicy '../../../modules/policies/mg/vmapplicationpolicy.bicep' = {
  name: 'applicationPolicy-${appName}'
  params: {
    packtag: 'linusdiscovery'
    policyDescription: 'Install ${appName} to ${OS} VMs'
    policyName: 'Install ${appName}'
    policyDisplayName: 'Install ${appName} to ${OS} VMs'
    solutionTag: solutionTag
    vmapplicationResourceId: linuxDiscovery.outputs.appVersionId
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
module LinuxDiscoveryDCR '../modules/discoveryrule.bicep' = {
  dependsOn: [
    table
  ]
  name: 'LinuxDiscoveryDCR'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    endpointResourceId: dceId
    filepatterns: [
      '/opt/microsoft/discovery/*.csv'
    ]
    kind: 'Linux'
    location: location
    lawResourceId: lawResourceId
    OS: 'Linux'
    solutionTag: solutionTag
    tableName: tableNameToUse
    packtag: 'linuxdiscovery'
  }
}

// Policy to assign DCR to all Windows VMs (in which context? MG if we want to use the same DCR for all subscriptions?)
module policysetup '../modules/policies.bicep' = {
  name: 'policysetup-linuxdiscovery'
  params: {
    dcrId: LinuxDiscoveryDCR.outputs.ruleId
    packtag: 'LxOS'
    solutionTag: solutionTag
    rulename: LinuxDiscoveryDCR.outputs.ruleName
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: ruleshortname
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
  }
}
