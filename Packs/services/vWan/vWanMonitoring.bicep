targetScope = 'managementGroup'
param lawId string
param packtag string
param solutionTag string
var resourceType = 'vWan'

module diagnosticsPolicy '../../../modules/policies/mg/diagnostics/associacionpolicyDiagLAWvWan.bicep' = {
  name: 'associacionpolicyDiagLAWvWan'
  params: {
    lawId: lawId
    packtag: packtag
    solutionTag: solutionTag
    policyDescription: 'Policy to associate the diagnostics setting for ${resourceType} resources the tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the diagnostics with the ${resourceType} resources tagged with ${packtag} tag.'
    policyName: 'Associate-diagnostics-${packtag}-${resourceType}'
  }
}
