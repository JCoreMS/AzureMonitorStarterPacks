<#
    .SYNOPSIS
        Deploy or Updated the Azure Monitor Started packs solution.
    .DESCRIPTION
        This script will deploy the Azure Monitor Started packs solution.
    .NOTES
        N/A
    .LINK
        https://github.com/Azure/AzureMonitorstarterPacks
    .EXAMPLE 
        # Minimal parameters required to deploy the solution:
        .\setup.ps1 -resourceGroup "myResourceGroup" -location "eastus"

        This example will ask for a workspace and a subscription. It will try to use the default DCR based on the MSVMI-<workspacename> pattern.
        It will also ask for an Action Group to be created. If you want to use an existing Action Group, use the -useExistingAG switch.
    #>
param (
    # the log analytics workspace where monitoring data will be sent
    [Parameter(Mandatory=$false)]
    [string]
    $workspaceResourceId,
    # the resource group where the azure monitor starter packs solution will be deployed
    [Parameter(Mandatory=$true)]
    [string]
    $solutionResourceGroup,
    # tag name used to identify the resources created by the solution and specify configuration
    [Parameter()]
    [string]
    $solutionTag='MonitorStarterPacks',
    # azure region where solution components will be deployed. Not all workloads must be deployed in the same region, but cross-region charges may apply.
    [Parameter(Mandatory=$true)]
    [string]
    $location,
    # specify to use an existing Action Group
    [Parameter()]
    [switch]
    $useExistingAG,
    # specify the name of the new or existing Action Group
    [Parameter()]
    [string]
    $actionGroupName,
    # names of recipients configured in the Action Group
    [Parameter()]
    [string[]]
    $emailreceivers=@(), 
    # email addresses of recipients configured in the Action Group
    [Parameter()]
    [string[]]
    $emailreceiversEmails=@(),
    # specify to skip deployment of Policies used to deploy the Azure Monitor Agent on target VMs
    [Parameter()]
    [switch]
    $skipAMAPolicySetup,
    # specify to skip the deployment of the main solution? (workbooks, alerts, etc)
    [Parameter()]
    [switch]
    $skipMainSolutionSetup,
    # specify to skip the deployment of Pack-specific resources
    [Parameter()]
    [switch]
    $skipPacksSetup,
    [Parameter()]
    [switch]
    $confirmEachPack,
    # specify the subscription ID where the solution will be deployed
    [Parameter()]
    [string]
    $subscriptionId,
    # specify to use the same Action Group for all packs, otherwise a new Action Group will be created for each pack
    [Parameter()]
    [switch]
    $useSameAGforAllPacks,
    # specify the location of the packs.json file
    [Parameter()]
    [string]
    $packsFilePath="./Packs/packs.json",
    # specify the discovery method used to identify VMs to monitor
    [Parameter()]
    [string]
    $discoveryType="tags"
)
$solutionVersion="0.1.0"
#region basic initialization
Write-Output "Installing/Loading Azure Graph module."
if ($null -eq (get-module Az.ResourceGraph)) {
    try {
        install-module az.resourcegraph -AllowPrerelease -Force
        import-module az.ResourceGraph #-Force
    }
    catch {
        Write-Error "Unable to install az.resourcegraph module. Please make sure you have the proper permissions to install modules."
        return
    }
}
"Import local common module."
if ($null -eq (get-module AzMPacks-Common)) {
    try {
        import-module ./modules/ps/AzMPacks-common.psm1
    }
    catch {
        Write-Error "Unable to import AzMPacks-Common module. Please make sure the module is present in the modules/ps folder."
        return
    }
}
# tests if subscriptionId is provided. If not, it will ask for one.
if (!([string]::IsNullOrEmpty($subscriptionId))) {
    Write-host "Using subscription $subscriptionId to deploy the packs, log analytics workspace and DCRs."
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop | out-null
    $sub=Get-AzSubscription -SubscriptionId $subscriptionId
}
else {
    # If more subscriptions are present, select one to deploy the packs.
    if ((Get-AzSubscription -ErrorAction SilentlyContinue).count -gt 1) {
        Write-host "Select a subscription to deploy the packs, log analytics workspace and DCRs."
        $sub=select-subscription
        if ($null -eq $sub) {
            Write-Error "No subscription selected. Exiting."
            return
        }
        Select-AzSubscription -SubscriptionId $sub.Id
    }
    else {
        $sub=Get-AzSubscription
        "Using $($sub.Name) subscription since there is no other one."
    }
}
if ($null -eq $sub) {
    Write-Error "No subscription selected. Exiting."
    return
}
#Creates the resource group if it does not exist.
# Add test to see if RG is in the same region as the new requested region.
if (!(Get-AzResourceGroup -name $solutionResourceGroup -ErrorAction SilentlyContinue)) {
    try {
        New-AzResourceGroup -Name $solutionResourceGroup -Location $location
    }
    catch {
        Write-Error "Unable to create resource group $solutionResourceGroup. Please make sure you have the proper permissions to create a resource group in the $location location."
        return
    }
}
else {
    if ((Get-AzResourceGroup -name $solutionResourceGroup -ErrorAction SilentlyContinue).Location -ne $location) {
        Write-Error "Resource group $solutionResourceGroup already exists in a different location. Please select a different resource group name or delete the existing resource group."
        return
    }
    else {
        Write-Host "Using existing resource group $solutionResourceGroup."
    }
}
if ( [string]::IsNullOrEmpty($workspaceResourceId)) {
    $ws=select-workspace -location $location -resourceGroup $solutionResourceGroup -solutionTag $solutionTag
}
else { 
    $ws=Get-AzOperationalInsightsWorkspace -Name $workspaceResourceId.split('/')[8] -ResourceGroupName $workspaceResourceId.split('/')[4] -ErrorAction SilentlyContinue
    if ($null -eq $ws) {
        Write-Error "Workspace $($workspaceResourceId.split('/')[8]) not found. "
        return
    }
}
#$wsfriendlyname=$ws.Name
$userId=(Get-AzADUser -SignedIn).Id

# Az available for Grafana setup?

$azAvailable=$false
try {
    az
    $azAvailable=$true
}
catch {
    "didn't find az"
    $azAvailable=$false
}
if ($azAvailable) {
    # This should be moved into the install packs routine eventually
    az extension add --name amg
    az account set --subscription $($sub.Id)
}
#endregion
#region AMA policy setup
if (!$skipAMAPolicySetup) {
    Write-Host "Enabling custom policy initiative to enable automatic AMA deployment. The policy only applies to the subscription where the packs are deployed."

    $parameters=@{
        solutionTag=$solutionTag
        location=$location
    }
    Write-Host "Deploying the AMA policy initiative to the current subscription."
    New-AzResourceGroupDeployment -name "amapolicy$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $solutionResourceGroup `
    -TemplateFile './setup/AMAPolicy/amapolicies.bicep' -templateParameterObject $parameters -ErrorAction Stop  | Out-Null 
}
else {
    Write-Host "Skipping AMA policy check and configuration, as requested."
}
#endregion
#region Main solution setup - Backend
# Setup Workbook, function, logic app  for Tag Configuration
if (!($skipMainSolutionSetup)) {

    # generate random storage account name
    $randomstoragechars = -join ((97..122) | Get-Random -Count 4 | ForEach-Object { [char]$_ })

    # zip the Function App's code
    compress-archive ./setup/backend/Function/code/* ./setup/backend/backend.zip -Force
    $existingSAs=Get-AzStorageAccount -ResourceGroupName $solutionResourceGroup -ErrorAction SilentlyContinue
    if ($existingSAs) {
        if ($existingSAs.count -gt 1) {
            $storageaccountName=(create-list -objectList $existingSAs -type "StorageAccount" -fieldName1 "StorageAccountName" -fieldName2 "ResourceGroupName").StorageAccountName
        }
        else {
            $storageaccountName=$existingSAs.StorageAccountName
            Write-Output "Using existing storage account $storageaccountName."
        }
    }
    else {
        $storageaccountName = "azmonstarpacks$randomstoragechars"
        Write-Host "Using storage account name: $storageaccountName"
    }

    # Check if the function app already exists to acount for role assignments, which is annoying.
    # $existingFunctionApp=Get-AzResource -ResourceType 'Microsoft.Web/sites' -ResourceGroupName $solutionResourceGroup -ErrorAction SilentlyContinue
    # if ($existingFunctionApp) {
        
    # }
    $parameters=@{
        functionname="MonitorStarterPacks-$($sub.id.split("-")[0])"
        location=$location
        storageAccountName=$storageAccountName
        lawresourceid=$ws.ResourceId
        appInsightsLocation=$location
        solutionTag=$solutionTag
        solutionVersion=$solutionVersion
        currentUserIdObject=$userId
    }
    Write-Host "Deploying the backend components(function, logic app and workbook)."
    #try {
        $backend=New-AzResourceGroupDeployment -name "maindeployment$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $solutionResourceGroup `
        -TemplateFile './setup/backend/code/backend.bicep' -templateParameterObject $parameters -ErrorAction Stop  | Out-Null #-Verbose
        $packsUserManagedIdentity=$backend.Outputs.packsUserManagedIdentity.value
        "Returning $packsUserManagedIdentity as packsUserManagedIdentity."
    #}
    #catch {
    #    Write-Error "Unable to deploy the backend components. Please make sure you have the proper permissions to deploy resources in the $solutionResourceGroup resource group."
    #    Write-Error $_.Exception.Message
    #    return
    #}
}
# Reads the packs.json file
if (!($skipPacksSetup)) {
    Write-Host "Found the following ENABLED packs in packs.json config file:"

    $packs=Get-Content -Path $packsFilePath | ConvertFrom-Json| Where-Object {$_.Status -eq 'Enabled'}
    $packs | ForEach-Object {Write-Host "$($_.PackName) - $($_.Status)"}
    $dceName="DCE-$solutionTag-$location"
    $dceId="/subscriptions/$($sub.Id)/resourceGroups/$solutionResourceGroup/providers/Microsoft.Insights/dataCollectionEndpoints/$dceName"
    if (!(Get-AzResource -ResourceId $dceId -ErrorAction SilentlyContinue)) {
        Write-Host "Endpoint $dceName ($dceId) not found."
        break
    }
    else {
        Write-Host "Using existing Data Collection Endpoint $dceName"
    }

    # deploy packs if any are enabled
    if ($packs.count -gt 0) {
        if ($useSameAGforAllPacks) {
            Write-host "'useSameAGforAllPacks' flag detected. Please provide AG information to be used to all Packs, either new or existing (depending on useExistingAG switch)"
            if ([string]::IsNullOrEmpty($existingAGName)) {
                $AGinfo=get-AGInfo -useExistingAG $useExistingAG.IsPresent
            }
            else {
                $AG=get-azactionGroup | Where-Object {$_.Name -eq $existingAGName}
                if ($AG.Count -eq 1) {
                    $AGInfo=@{
                        name=$AG.name
                        emailReceivers=$AG.emailReceivers
                        emailReceiversEmails=$AG.emailReceiversEmails
                        resourceGroup=$AG.ResourceGroupName
                    }
                }
                else {
                    Write-Host "Action Group $existingAGName not found or more than one found. Please select AG:"
                    $AGinfo=get-AGInfo -useExistingAG $useExistingAG.IsPresent
                }
            }
        }

        install-packs -packinfo $packs `
            -resourceGroup $solutionResourceGroup `
            -AGInfo $AGinfo `
            -useExistingAG:$useExistingAG.IsPresent `
            -existingAGName $actionGroupName `
            -useSameAGforAllPacks:$useSameAGforAllPacks.IsPresent `
            -workspaceResourceId $ws.ResourceId `
            -discoveryType $discoveryType `
            -solutionTag $solutionTag `
            -solutionVersion $solutionVersion `
            -confirmEachPack:$confirmEachPack.IsPresent `
            -location $location `
            -dceId $dceId `
            -azAvailable $azAvailable

        # Grafana dashboards
        # if ($deploymentResult -eq $true) {
        #     $azAvailable=$false
        #     try {
        #         az
        #         $azAvailable=$true
        #     }
        #     catch {
        #         "didn't find az"
        #         $azAvailable=$false
        #     }
        #     if ($azAvailable) {
        #         # This should be moved into the install packs routine eventually
        #         az extension add --name amg
        #         az account set --subscription $($sub.Id)
        #         foreach ($pack in $packs) {
        #             if (!([string]::IsNullOrEmpty($pack.GrafanaDashboard))) {
        #                 "Installing Grafana dashboard for $($pack.PackName)"
        #                 $temppath=$pack.GrafanaDashboard
        #                 if (get-item $temppath -ErrorAction SilentlyContinue) {
        #                     "Importing $($pack.GrafanaDashboard) dashboard."
        #                     az grafana dashboard import -g $solutionResourceGroup -n "MonstarPacks" --definition $temppath
        #                 }
        #                 else {
        #                     "Dashboard $($pack.GrafanaDashboard) not found."
        #                 }
        #             }
        #         }
        #     }
        # }
        # else {
        #     "Deployment failed for pack $($pack.PackName). Skipping Grafana dashboard deployment, if exists."
        # }
#endregion
    }
    else {
        Write-Error "No packs found in $packsFilePath or no servers identified. Please correct the error and try again."
        return
    }
}
else {
    Write-Host "Skipping Packs setup."
}