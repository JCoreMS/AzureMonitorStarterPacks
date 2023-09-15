@allowed([
  'rows'
  'Aggregated'
  'metric'
])
param alertType string
param alertRuleName string
param alertRuleDisplayName string
param alertRuleDescription string
param scope string // log analytics workspace resource id or resource id in case of metric alerts.
param actionGroupResourceId string
param alertRuleSeverity int
param location string
param windowSize string = 'PT15M'
param evaluationFrequency string = 'PT15M'
param autoMitigate bool = false
param query string
param metricName string =''
param metricNameSpace string = '' // resource type like microsoft.compute/virtualmachines
param timeAggregation string = 'Average'

//param starterPackName string
param packtag string
param solutionTag string
param solutionVersion string

param threshold int = 0
param metricMeasureColumn string = ''

@allowed([
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
  'Equal'
  'NotEqual'
])
param operator string = 'GreaterThan'

module rowAlert './scheduledqueryruleRows.bicep' = if (alertType == 'rows') {
  name: 'rowAlert-${packtag}-${alertRuleName}'
  params: {
    alertRuleName: alertRuleName
    alertRuleDisplayName: alertRuleDisplayName
    alertRuleDescription: alertRuleDescription
    scope: scope
    actionGroupResourceId: actionGroupResourceId
    alertRuleSeverity: alertRuleSeverity
    location: location
    windowSize: windowSize
    evaluationFrequency: evaluationFrequency
    autoMitigate: autoMitigate
    query: query
    //starterPackName: starterPackName
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}

module aggregateAlert './scheduledqueryruleAggregate.bicep' = if (alertType == 'Aggregated') {
  name: 'AggregateAlert-${packtag}-${alertRuleName}'
  params: {
    alertRuleName: alertRuleName
    alertRuleDisplayName: alertRuleDisplayName
    alertRuleDescription: alertRuleDescription
    scope: scope
    actionGroupResourceId: actionGroupResourceId
    alertRuleSeverity: alertRuleSeverity
    location: location
    windowSize: windowSize
    evaluationFrequency: evaluationFrequency
    autoMitigate: autoMitigate
    query: query
    //starterPackName: starterPackName
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    threshold: threshold
    metricMeasureColumn: metricMeasureColumn
    operator: operator
  }
}

module metricalert './metricalert.bicep' = if (alertType == 'metric') {
  name: 'metricalert-${packtag}-${alertRuleName}'
  params: {
    alertrulename: alertRuleName
    metricName: metricName
    resourceId: scope
    severity: alertRuleSeverity
    metricNamespace: metricNameSpace
    timeAggregation: timeAggregation
    location: location
    windowSize: windowSize
    evaluationFrequency: evaluationFrequency
    //starterPackName: starterPackName
    packtag: packtag
    solutionTag: solutionTag
    threshold: threshold
  }

}
