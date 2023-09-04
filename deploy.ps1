### Use Windows PowerShell instead of PowerShell Core because of the AzureAD module dependency
### Uncomment these lines if you're not deploying using Azure Cloud Shell
# Install-Module Az.Accounts -Scope CurrentUser -Force -AllowClobber
# Install-Module Az.Resources -Scope CurrentUser -Force -AllowClobber
# Connect-AzAccount
# az login
###

# Deploy Azure resources
Write-Host "Which Azure location would you like to deploy to? (Default: canadaeast)" -ForegroundColor Yellow
$location = Read-Host
$location = [string]::IsNullOrEmpty($location) ? "canadaeast" : $location

Write-Host "What suffix would you like to use for your resources? (Default: credsalert)" -ForegroundColor Yellow
$suffix = Read-Host
$suffix = [string]::IsNullOrEmpty($suffix) ? "credsalert" : $suffix

Write-Host "How many days before the credentials expire should it send a notification? (Default: 14)" -ForegroundColor Yellow
$daysUntilExpiration = Read-Host
$daysUntilExpiration = [string]::IsNullOrEmpty($daysUntilExpiration) ? "14" : $daysUntilExpiration

$loggedInUser = az account show --query user.name -o tsv
Write-Host "What email address should the notification come from? (Default: $($loggedInUser))" -ForegroundColor Yellow
$emailFrom = Read-Host
$emailFrom = [string]::IsNullOrEmpty($emailFrom) ? $loggedInUser : $emailFrom

Write-Host "What email address should the notification go to? (Default: $($loggedInUser))" -ForegroundColor Yellow
$emailTo = Read-Host
$emailTo = [string]::IsNullOrEmpty($emailTo) ? $loggedInUser : $emailTo

$params = @{ 
    suffix              = $suffix
    daysUntilExpiration = $daysUntilExpiration
    emailFrom           = $emailFrom 
    emailTo             = $emailTo
}

Write-Host "----------------------------------------"
Write-Host "Deploying Azure resources..."

$deployment = New-AzSubscriptionDeployment -Name "$($params.suffix)-deployment" `
    -Location $location `
    -TemplateFile ".\infra\main.bicep" `
    -TemplateParameterObject $params 

if ($deployment.ProvisioningState -ne "Succeeded") {
    Write-Warning "Deployment failed or has timed out."
    return
}

$functionAppName = $deployment.Outputs["appName"].Value
Start-Sleep -Seconds 10

Write-Host "Assigning Graph API permissions to function app identity..."

Install-Module Microsoft.Graph -Force
Connect-MgGraph -Identity -NoWelcome

$permissions = "Application.ReadWrite.All", "Directory.Read.All"   
$MSI = Get-MgServicePrincipal -Filter "DisplayName eq '$functionAppName'"
$Graph = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"  # Microsoft Graph App ID (DON'T CHANGE)

foreach ($permission in $permissions) {
    Write-Host "Assigning $permission permission..."
    $params = @{
        principalId = $MSI.Id
        resourceId = $Graph.Id
        appRoleId = $Graph.AppRoles | Where-Object { $_.Value -eq $permission }
    }
    New-MgServiceAppRoleAssignment -ServicePrincipalId $MSI.Id  -BodyParameter $params
}

Write-Host "Deploying function app code..."
Set-Location -Path src
func azure functionapp publish $functionAppName --powershell 