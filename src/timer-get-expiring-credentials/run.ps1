param($Timer)

Write-Host "PowerShell timer trigger function is running. TIME: $((Get-Date).ToUniversalTime())"

$Applications = Get-MgApplication -all
$ExpiryDate = (Get-Date).AddDays([int]$env:DaysUntilExpiration)
$Expiring = @()

foreach ($App in $Applications) {
    $AppName = $App.DisplayName
    $ObjectID = $App.Id
    $ClientID = $App.AppId    
    $Owner = Get-Owner $ObjectID

    foreach ($Secret in $App.PasswordCredentials) {
        if ($Secret.EndDateTime -le $ExpiryDate) {
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

    foreach ($Cert in $App.KeyCredentials) {
        if ($Cert.EndDateTime -le $ExpiryDate) {
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

Write-host "Found $($Expiring.Length) credentials that have already expired or are expiring before: $ExpiryDate"
Write-Host "PowerShell timer trigger function ran! TIME: $((Get-Date).ToUniversalTime())"