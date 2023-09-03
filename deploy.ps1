# Use Windows PowerShell instead of PowerShell Core because of the AzureAD module dependency
Install-Module Az.Accounts -Scope CurrentUser -Force -AllowClobber
Install-Module Az.Resources -Scope CurrentUser -Force -AllowClobber
Install-Module AzureAD -Scope CurrentUser -Force -AllowClobber
Import-Module AzureAD

Connect-AzAccount
Connect-AzureAD
az login

# Deploy Azure resources
$location = "canadaeast"
$params = @{ 
    suffix = "credsalert"
    daysUntilExpiration = 14
    emailFrom = "someone@contoso.com"
    emailTo = "someone@contoso.com"
}

$deployment = New-AzSubscriptionDeployment -Name "$($params.suffix)-deployment" `
    -Location $location `
    -TemplateFile ".\infra\main.bicep" `
    -TemplateParameterObject $params

$functionAppName = $deployment.Outputs["appName"].Value
Start-Sleep -Seconds 30

# Assign Graph API permissions to function app identity
$permissions = "Application.ReadWrite.All", "Directory.Read.All"   
$MSI = Get-AzADServicePrincipal -DisplayName $functionAppName
$Graph = Get-AzADServicePrincipal -ApplicationId "00000003-0000-0000-c000-000000000000" # Microsoft Graph App ID (DON'T CHANGE)

foreach($permission in $permissions){
    $AppRole = $Graph.AppRole | Where-Object { $_.Value -eq $permission }
    New-AzureAdServiceAppRoleAssignment -ObjectId $MSI.Id -PrincipalId $MSI.Id `
        -ResourceId $Graph.Id -Id $AppRole.Id
}

# Deploy function app code
Set-Location -Path src
func azure functionapp publish $functionAppName --powershell 