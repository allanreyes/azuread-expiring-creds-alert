### Use Windows PowerShell instead of PowerShell Core because of the AzureAD module dependency
### Uncomment these lines if you're not deploying using Azure Cloud Shell
# Install-Module Az.Accounts -Scope CurrentUser -Force -AllowClobber
# Install-Module Az.Resources -Scope CurrentUser -Force -AllowClobber
# Connect-AzAccount
# az login
###

# Deploy Azure resources
Write-Host "Which Azure location would you like to deploy to? (e.g. canadaeast)" -ForegroundColor Yellow
$location = Read-Host
Write-Host "What suffix would you like to use for your resources? (e.g. credsalert)" -ForegroundColor Yellow
$suffix = Read-Host 
Write-Host "How many days before the credentials expire should it send a notification? (e.g. 14)" -ForegroundColor Yellow
$daysUntilExpiration = Read-Host 
Write-Host "What email address should the notification come from? (e.g. admin@contoso.com)" -ForegroundColor Yellow
$emailFrom = Read-Host
Write-Host "What email address should the notification go to? (e.g. mailinglist@contoso.com)" -ForegroundColor Yellow
$emailTo = Read-Host

$params = @{ 
    suffix              = $suffix
    daysUntilExpiration = $daysUntilExpiration
    emailFrom           = $emailFrom 
    emailTo             = $emailTo
}


$deployment = New-AzSubscriptionDeployment -Name "$($params.suffix)-deployment" `
    -Location $location `
    -TemplateFile ".\infra\main.bicep" `
    -TemplateParameterObject $params `
    -AsJob
    Write-Host "----------------------------------------"

Write-Host "Deploying Azure resources..."
$timeout = (Get-Date).AddMinutes(10);
while($true){
    Start-Sleep -Seconds 5
    Write-Host "." -NoNewline
    if ($deployment.ProvisioningState -eq "Succeeded" -or (Get-Date -gt $timeout)){
        break;
    }
}    

if ($deployment.ProvisioningState -ne "Succeeded") {
    Write-Warning "Deployment failed or has timed out."
}

$functionAppName = $deployment.Outputs["appName"].Value
Start-Sleep -Seconds 10

Write-Host "Assigning Graph API permissions to function app identity..."
Install-Module AzureAD -Scope CurrentUser -Force
Connect-AzureAD -Identity

$permissions = "Application.ReadWrite.All", "Directory.Read.All"   
$MSI = Get-AzADServicePrincipal -DisplayName $functionAppName
$Graph = Get-AzADServicePrincipal -ApplicationId "00000003-0000-0000-c000-000000000000" # Microsoft Graph App ID (DON'T CHANGE)

foreach ($permission in $permissions) {
    $AppRole = $Graph.AppRole | Where-Object { $_.Value -eq $permission }
    New-AzureAdServiceAppRoleAssignment -ObjectId $MSI.Id -PrincipalId $MSI.Id `
        -ResourceId $Graph.Id -Id $AppRole.Id
}

Write-Host "Deploying function app code..."
Set-Location -Path src
func azure functionapp publish $functionAppName --powershell 