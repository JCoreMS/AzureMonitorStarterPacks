# Packs documentation - Platform Services Packs

The recommended experience to deploy the packs is by using the provided interface. You can also use ARM and Bicep Templates. See section below.

To deploy all Platform packs, click the icon below:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2FvWan%2FPacks%2FIaaS%2FAllIaaSPacks.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2FvWan%2FPacks%2FCustomSetup%2Fsetup.json)

## KeyVault

This pack leverages Metric and Activity alerts. It implements the following:


[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FFehsecorp%2FAzureMonitorStarterPacks%2FvWan%2FPacks%2FPlatform%2FKeyVault%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FFehsecorp%2FAzureMonitorStarterPacks%2FvWan%2FPacks%2FCustomSetup%2Fsetup.json)

# Using ARM and Bicep Templates.

Each pack is composed of a bicep template that contains the rules and alerts. There is an equivalente ARM template that can be used instead. The ARM template is generated from the bicep template. The ARM template is used by the interface to deploy the packs and, same as bicep template, it can be used to deploy the packs using Azure CLI or PowerShell, in a pipeline for example.
