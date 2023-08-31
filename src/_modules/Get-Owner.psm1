function Get-Owner($objectID) {
    
    $Owner    = Get-MgApplicationOwner -ApplicationId $objectID
    $Username = $Owner.AdditionalProperties.userPrincipalName -join ';'

    if ($null -eq $Owner.AdditionalProperties.userPrincipalName) {
        $Username = @(
            $Owner.AdditionalProperties.displayName
            '**<This is an Application>**'
        ) -join ' '
    }
    if ($null -eq $Owner.AdditionalProperties.displayName) {
        $Username = '<<No Owner>>'
    }

    return $Username
}

Export-ModuleMember -Function Get-Owner