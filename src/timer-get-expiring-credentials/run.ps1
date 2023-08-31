param($Timer)

$currentUTCtime = (Get-Date).ToUniversalTime()
Write-Host "PowerShell timer trigger function is running. TIME: $currentUTCtime"

$Applications = Get-MgApplication -all
$Now = Get-Date
$ExpiryDate = $Now.AddDays([int]$env:DaysUntilExpiration)
$Expiring = @()

foreach ($App in $Applications) {
   
    $AppName = $App.DisplayName
    $ObjectID = $App.Id
    $ClientID = $App.AppId    
    $AppCreds = Get-MgApplication -ApplicationId $ObjectID | Select-Object PasswordCredentials, KeyCredentials
    $Owner = Get-Owner $ObjectID

    $Secrets = $AppCreds.PasswordCredentials | Where-Object { $_.EndDateTime -le $ExpiryDate }
    foreach ($Secret in $Secrets) {
        if ($EndDate -ge $ExpiryDate) {
            $Expiring += [PSCustomObject]@{
                'ApplicationName' = $AppName
                'ApplicationID'   = $ClientID
                'Owner'           = $Owner
                'Type'            = 'Secret'
                'Name'            = $Secret.DisplayName
                'Start Date'      = $Secret.StartDateTime
                'End Date'        = $Secret.EndDateTime
            }
        }       
    }

    $Certs = $AppCreds.KeyCredentials | Where-Object { $_.EndDateTime -le $ExpiryDate }
    foreach ($Cert in $Certs) {
        if ($EndDate -ge $ExpiryDate) {
            $Expiring += [PSCustomObject]@{
                'ApplicationName' = $AppName
                'ApplicationID'   = $ClientID
                'Owner'           = $Owner
                'Type'            = 'Certificate'
                'Name'            = $Cert.DisplayName
                'Start Date'      = $Cert.StartDateTime
                'End Date'        = $Cert.EndDateTime
            }
        }       
    }
}

Write-host ($Expiring | ConvertTo-Json)

Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"