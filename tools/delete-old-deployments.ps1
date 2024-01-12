# 15 days or older deployments will be deleted
Get-AzManagementGroupDeployment -ManagementGroupId 'FehseCorpRoot'  | Where-Object -Property Timestamp -LT -Value ((Get-Date).AddDays(-15)) | Remove-AzManagementGroupDeployment

# Count old deployments
Get-AzManagementGroupDeployment -ManagementGroupId 'FehseCorpRoot'  | Where-Object -Property Timestamp -LT -Value ((Get-Date).AddDays(-15)) | Measure-Object