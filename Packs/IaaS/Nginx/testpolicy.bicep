targetScope = 'managementGroup'

//param location string= resourceGroup().location
param packtag string
param solutionTag string

module applicationPolicy '../../../modules/policies/mg/vmapplicationpolicy.bicep' = {
  name: 'applicationPolicy-${packtag}'
  params: {
    packtag: packtag
    policyDescription: 'Install nginx collector to tagged VMs'
    policyName: 'nginxcollector'
    policyDisplayName: 'Install nginx collector'
    solutionTag: solutionTag
    vmapplicationResourceId: '/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/MonStar-rg/providers/Microsoft.Compute/galleries/monstargallery2/applications/nginxmonstarcollector/versions/1.0.0'// ngnixcolv1.outputs.appVersionId
    roledefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    ]
  }
}
