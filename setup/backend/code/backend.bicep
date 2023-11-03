targetScope = 'managementGroup'

@description('The name for the function app that you wish to create')
param functionname string
param currentUserIdObject string
param location string
param storageAccountName string
//param kvname string
param lawresourceid string
param grafanaName string
param grafanalocation string
param appInsightsLocation string
//param packageUri string = 'https://amonstarterpacks2abbd.blob.core.windows.net/discovery/discovery.zip'
@description('UTC timestamp used to create distinct deployment scripts for each deployment')
//param utcValue string = utcNow()
//param filename string = 'discovery.zip'
//param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param solutionTag string
param solutionVersion string

param subscriptionId string
param resourceGroupName string
param mgname string

param imageGalleryName string

var linuxDiscoveryTag = 'LxOS'

var packPolicyRoleDefinitionIds=[
  '749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor Role Definition Id for Monitoring Contributor
  '92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor Role Definition Id for Log Analytics Contributor
  //Above role should be able to add diagnostics to everything according to docs.
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]

var backendFunctionRoleDefinitionIds = [
  '4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
  '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' // VM Contributor
  '48b40c6e-82e0-4eb3-90d5-19e40f49b624' // Arc Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
  '749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
  '36243c78-bf99-498c-9df9-86d9f8d28608' // policy contributor
  'f1a07417-d97a-45cb-824c-7a7467783830' // Managed identity Operator
]

//var subscriptionId = subscription().subscriptionId
// var ContributorRoleDefinitionId='4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Contributor Role Definition Id for Tag Contributor
// var VMContributorRoleDefinitionId='9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
// var ArcContributorRoleDefinitionId='48b40c6e-82e0-4eb3-90d5-19e40f49b624'
// var ReaderRoleDefinitionId='acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader Role Definition Id for Reader
// var LogAnalyticsContributorRoleDefinitionId='92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor Role Definition Id for Log Analytics Contributor
// var MonitoringContributorRoleDefinitionId='749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor Role Definition Id for Monitoring Contributor

// var sasConfig = {
//   signedResourceTypes: 'sco'
//   signedPermission: 'r'
//   signedServices: 'b'
//   signedExpiry: sasExpiry
//   signedProtocol: 'https'
//   keyToSign: 'key2'
// }
module gallery 'modules/aig.bicep' = {
  name: 'gallery'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    galleryname: imageGalleryName
    location: location
  }
}

// Module below implements function, storage account, and app insights
module backendFunction 'modules/function.bicep' = {
  name: 'backendFunction'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    functionUserManagedIdentity
  ]
  params: {
    appInsightsLocation: appInsightsLocation
    functionname: functionname
    lawresourceid: lawresourceid
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    storageAccountName: storageAccountName
    userManagedIdentity: functionUserManagedIdentity.outputs.userManagedIdentityResourceId
    userManagedIdentityClientId: functionUserManagedIdentity.outputs.userManagedIdentityClientId
    packsUserManagedId: packsUserManagedIdentity.outputs.userManagedIdentityResourceId
  }
}

module logicapp './modules/logicapp.bicep' = {
  name: 'BackendLogicApp'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    backendFunction
  ]
  params: {
    functioname: functionname
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
module workbook './modules/workbook.bicep' = {
  name: 'workbookdeployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    lawresourceid: lawresourceid
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
module amg 'modules/grafana.bicep' = {
  name: 'azureManagedGrafana'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    location: grafanalocation
    grafanaName: grafanaName
    userObjectId: currentUserIdObject
    lawresourceId: lawresourceid
  }
}

// A DCE in the main region to be used by all rules.
module dataCollectionEndpoint '../../../modules/DCRs/dataCollectionEndpoint.bicep' = {
  name: 'DCE-${solutionTag}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    packtag: 'dceMainRegion'
    solutionTag: solutionTag
    dceName: 'DCE-${solutionTag}-${location}'
  }
}

// This module creates a user managed identity for the packs to use.
module packsUserManagedIdentity 'modules/userManagedIdentity.bicep' = {
  name: 'packsUserManagedIdentity'
  params: {
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    roleDefinitionIds: packPolicyRoleDefinitionIds
    userIdentityName: 'packsUserManagedIdentity'
    mgname: mgname
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
  }
}

// module customRemdiationRole '../../../modules/rbac/subscription/remediationContributor.bicep' = {
//   name: 'customRemediationRole'
//   scope: subscription(subscriptionId)
//   params: {
//   }
// }

module functionUserManagedIdentity 'modules/userManagedIdentity.bicep' = {
  name: 'functionUserManagedIdentity'
  params: {
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    roleDefinitionIds: backendFunctionRoleDefinitionIds//,array('${customRemdiationRole.outputs.roleDefId}'))
    userIdentityName: 'functionUserManagedIdentity'
    mgname: mgname
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
  }
}
//Adding vm application deployment to discover roles in Linux boxes tagged with LxOS

//New stuff - VM Application
module nginxcollector '../../../modules/aig/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'discovery-${linuxDiscoveryTag}'
  params: {
    aigname: 'monstargallery2'
    appDescription: 'Nginx MonStar Collector'
    appName: 'nginxmonstarcollector'
    location: location
    osType: 'Linux'
  }
}

module upload './modules/uploadDS.bicep' = {
  name: 'upload-${linuxDiscoveryTag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'packs'
    fileURL: 'https://github.com/FehseCorp/AzureMonitorStarterPacks/raw/imagegallery/setup/backend/discovery/linux/amspdiscovery.deb'
    storageAccountName: storageAccountName
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}

module ngnixcolv1 '../../../modules/aig/aigappversion.bicep' = {
  name: 'nginxcollectorv1-${linuxDiscoveryTag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    nginxcollector
  ]
  params: {
    aigname: 'monstargallery2'
    appName: 'amspdiscovery'
    appVersionName: '1.0.0'
    location: location
    targetRegion: location
    mediaLink: upload.outputs.fileURL
    installCommands: 'cd /tmp && sudo apt install ./amspdiscovery.deb -y '
    removeCommands: 'sudo apt remove amspdiscovery -y'
  }
}

module applicationPolicy '../../../modules/policies/mg/vmapplicationpolicy.bicep' = {
  name: 'applicationPolicy-${linuxDiscoveryTag}'
  params: {
    packtag: linuxDiscoveryTag
    policyDescription: 'Install discovery collector to tagged VMs'
    policyName: 'linuxDiscoveryCollectorPolicy'
    policyDisplayName: 'Linux Discovery Collector Policy'
    solutionTag: solutionTag
    vmapplicationResourceId: ngnixcolv1.outputs.appVersionId
    roledefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    ]
  }
}



output packsUserManagedIdentityId string = packsUserManagedIdentity.outputs.userManagedIdentityPrincipalId
output packsUserManagedResourceId string = packsUserManagedIdentity.outputs.userManagedIdentityResourceId
