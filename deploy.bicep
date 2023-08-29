param deployAMAPolicies bool
param deployMainSolution bool
param deployPacks bool
param utctime string = utcNow()
param location string
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string = '1.0.0'
param appInsightsLocation string
param currentUserIdObject string
param functionName string = '${solutionTag}-${split(subscription().subscriptionId,'-')[0]}'
param grafanaLocation string
param grafanaName string = 'AMSP-${split(subscription().subscriptionId,'-')[0]}'
param lawresourceId string
param storageAccountName string
param useExistingAG bool = true
param ExistingActionGroupName string
param exisintingAGResourceGroup string = ''
param emailreceivers array = []
param emailreiceversemails array = []


// Deploy the AMA policy set
module AMAPolicies 'setup/AMAPolicy/amapolicies.bicep' = if (deployAMAPolicies) {
  name: 'AMAPolicies-${utctime}'
  params: {
  location: location
  solutionTag: solutionTag
  solutionVersion: solutionVersion
  }
}

module MainSolution 'setup/backend/code/backend.bicep' = if (deployMainSolution) {

  name: 'MainSolution-${utctime}'
  params: {
    appInsightsLocation: appInsightsLocation
    currentUserIdObject: currentUserIdObject
    functionname: functionName
    grafanalocation: grafanaLocation
    grafanaName: grafanaName
    lawresourceid: lawresourceId
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    storageAccountName: storageAccountName
  }
}

module PackWinOS './Packs/IaaS/WinOS/WinVMMonitoring.bicep' = if (deployPacks) {
  name: 'AMSP-Windows-VM-OS'
  params: {
    actionGroupName: ExistingActionGroupName
    dceId: MainSolution.outputs.dceId
    location: location
    packtag: 'WinOS'
    rulename: 'AMSP-VMI_Server_OS'
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    userManagedIdentityResourceId: MainSolution.outputs.packsUserManagedResourceId
    workspaceId: lawresourceId
  }
}

module PackLxOS './Packs/IaaS/LxOS/LinuxVM.bicep' = if (deployPacks) {
  name: 'AMSP-Linux-VM-OS'
  params: {
    actionGroupName: ExistingActionGroupName
    dceId: MainSolution.outputs.dceId
    location: location
    packtag: 'LxOS'
    rulename: 'AMSP-VMI_Server_Linux'
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    userManagedIdentityResourceId: MainSolution.outputs.packsUserManagedResourceId
    workspaceId: lawresourceId
  }
}

module PackNginx'./Packs/IaaS/Nginx/nginx.bicep' = if (deployPacks) {
  name: 'AMSP-Linux-Nginx'
  params: {
    actionGroupName: ExistingActionGroupName
    dceId: MainSolution.outputs.dceId
    location: location
    packtag: 'Nginx'
    rulename: 'AMSP-nginxMonitoring'
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    userManagedIdentityResourceId: MainSolution.outputs.packsUserManagedResourceId
    workspaceId: lawresourceId
  }
}

module PackIIS './Packs/IaaS/IIS/WinIISMonitoring.bicep' = if (deployPacks) {
  name: 'AMSP-Windows-IIS'
  params: {
    actionGroupName: ExistingActionGroupName
    dceId: MainSolution.outputs.dceId
    location: location
    packtag: 'IIS'
    rulename: 'AMSP-IIS-Server'
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    userManagedIdentityResourceId: MainSolution.outputs.packsUserManagedResourceId
    workspaceId: lawresourceId
    useExistingAG: useExistingAG
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: exisintingAGResourceGroup
  }
}
