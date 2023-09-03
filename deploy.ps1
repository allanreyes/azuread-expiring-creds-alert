### Use Windows PowerShell instead of PowerShell Core because of the AzureAD module dependency
### Uncomment these lines if you're not deploying using Azure Cloud Shell
# Install-Module Az.Accounts -Scope CurrentUser -Force -AllowClobber
# Install-Module Az.Resources -Scope CurrentUser -Force -AllowClobber
# Connect-AzAccount
# az login
###

# Deploy Azure resources
$location = Read-Host "Which Azure location would you like to deploy to? (e.g. canadaeast)" -ForegroundColor Yellow
$suffix = Read-Host "What suffix would you like to use for your resources? (e.g. credsalert)" -ForegroundColor Yellow
$daysUntilExpiration = Read-Host "How many days before the credentials expire should it send a notification? (e.g. 14)" -ForegroundColor Yellow
$emailFrom = Read-Host "What email address should the notification come from? (e.g. admin@contoso.com)" -ForegroundColor Yellow
$emailTo = Read-Host "What email address should the notification go to? (e.g. mailinglist@contoso.com)" -ForegroundColor Yellow

$params = @{ 
    suffix = $suffix
    daysUntilExpiration = $daysUntilExpiration
    emailFrom = $emailFrom 
    emailTo = $emailTo
}

Write-Host "Deploying Azure resources..."
$deployment = New-AzSubscriptionDeployment -Name "$($params.suffix)-deployment" `
    -Location $location `
    -TemplateFile ".\infra\main.bicep" `
    -TemplateParameterObject $params

$deploymentDetailsBsseUrl = "https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/"
Write-Host $deploymentDetailsBsseUrl + [System.Web.HttpUtility]::UrlEncode($deployment.TemplateLink)

if ($deployment.ProvisioningState -eq "Succeeded") {

    $functionAppName = $deployment.Outputs["appName"].Value
    Start-Sleep -Seconds 30

    # Assign Graph API permissions to function app identity
    Install-Module AzureAD -Scope CurrentUser -Force
    Connect-AzureAD -Identity

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
} else {
    Write-Warning "Deployment failed."
}


