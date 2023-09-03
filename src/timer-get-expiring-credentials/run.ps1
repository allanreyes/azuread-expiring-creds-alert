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
                ApplicationName = $AppName
                ApplicationID   = $ClientID
                Owner           = $Owner
                Type            = 'Secret'
                Name            = $Secret.DisplayName
                StartDate       = $Secret.StartDateTime
                EndDate         = $Secret.EndDateTime
            }
        }       
    }

    foreach ($Cert in $App.KeyCredentials) {
        if ($Cert.EndDateTime -le $ExpiryDate) {
            $Expiring += [PSCustomObject]@{
                ApplicationName = $AppName
                ApplicationID   = $ClientID
                Owner           = $Owner
                Type            = 'Certificate'
                Name            = $Cert.DisplayName
                StartDate       = $Cert.StartDateTime
                EndDate         = $Cert.EndDateTime
            }
        }       
    }
}

Write-host "Found $($Expiring.Length) credentials that have already expired or are expiring before: $ExpiryDate"

# Save results to Azure Table Storage
foreach ($Row in $Expiring) {
    Push-OutputBinding -Name TableBinding -Value @{
        PartitionKey = $Row.ApplicationID
        RowKey = [Guid]::NewGuid().ToString()
        ApplicationName = $Row.ApplicationName
        Owner           = $Row.Owner
        Type            = $Row.Type
        Name            = $Row.Name
        StartDate       = $Row.StartDate
        EndDate         = $Row.EndDate
    }
}

# Build HTML Email body
$tableRows = ""
foreach ($Row in ($Expiring | Sort-Object -Property ApplicationName, Type)){
    $link = "https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/$($Row.ApplicationID)"
    $tableRows += "<tr><td><a href='$($link)'>$($Row.ApplicationName)</a></td>"
    $tableRows += "<td>$($Row.Owner)</td>"
    $tableRows += "<td>$($Row.Type)</td>"
    $tableRows += "<td>$($Row.Name)</td>"
    $tableRows += "<td>$($Row.StartDate)</td>"
    $tableRows += "<td>$($Row.EndDate)</td></tr>"
} 

$template = @"
<table style='font-family: Arial, Helvetica, sans-serif; font-size: 12px;border-collapse: collapse;' border='1' cellpadding='5' align='center'>
    <tr style='background-color: #f2f2f2;'><th>ApplicationName</th>
    <th>Owner</th>
    <th>Type</th>
    <th>Name</th>
    <th>StartDate</th>
    <th>EndDate</th>
</tr>
${tableRows}
</table>
"@

$payload = @{
    Subject = "Expiring Credentials as of $((Get-Date).ToUniversalTime()) UTC"
    To = $env:EmailTo
    body = $template
}
Invoke-RestMethod $env:SendEmailUrl -Method Post -Body ($payload | ConvertTo-Json ) -ContentType "application/json"

Write-Host "PowerShell timer trigger function ran! TIME: $((Get-Date).ToUniversalTime())"