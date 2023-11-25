targetScope = 'subscription' 

@maxLength(64)
@description('PolicySet name')
param initiativeName string 

@maxLength(128)
@description('PolicySet display Name')
param initiativeDisplayName string

@description('PolicySet description')
param initiativeDescription string

@minLength(1)
@description('array of policy IDs')
//param initiativePoliciesID array
param solutionTag string
param category string = 'Monitoring' 
param version string = '1.0.0'
param policyDefinitions array

resource policySetDef 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    description: initiativeDescription
    displayName: initiativeDisplayName 
    metadata: {
      category: category
      version: version
      '${solutionTag}': 'Policy Set'
    }
    parameters: {}
    policyDefinitions:  policyDefinitions
    policyType: 'Custom'
  }
}
output policySetDefId string = policySetDef.id
