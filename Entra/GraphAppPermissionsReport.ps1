$applications = Get-MgApplication -All
$svcPrincipal = foreach ($application in $applications) {
    Get-MgServicePrincipal -Filter "AppID eq '$($application.AppId)'"
}
$graphAppRoles = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'" | Select -expand AppRoles
$grouped = $graphAppRoles | Group-Object -AsHashTable -Property Id

$appRoles = foreach ($principal in $svcPrincipal) {
    Invoke-MgGraphRequest -Method GET -URI "https://graph.microsoft.com/v1.0/servicePrincipals/$($principal.id)/appRoleAssignments" | Select -expand Value
}

$groupApplications = $applications | Group-Object -AsHashTable -Property DisplayName


$report = foreach ($role in $appRoles) {
    $Permission = $grouped[$role.appRoleId].value
    if ($Permission -match "write") {
        $impact = "X"
    }
    else {
        $impact = $null
    }

    $app = $groupApplications[$role.principalDisplayName]

    if ($app.PasswordCredentials) {
        $clientSecretPresent = $true
    } else {
        $clientSecretPresent = $false
    }

    if ($app.KeyCredentials) {
        $CertificatePresent = $true
    } else {
        $CertificatePresent = $false
    }

    if ($app.FederatedIdentityCredentials) {
        $FedCredPresent = $true
    } else {
        $FedCredPresent = $false
    }

    [PSCustomObject]@{
        ServicePrincipalName   = $role.principalDisplayName
        AppPermission          = $Permission
        WritePermissions       = $Impact
        HasClientSecret        = $clientSecretPresent
        HasCertificate         = $CertificatePresent
        HasFederatedCredential = $FedCredPresent
    }
}

$report | Sort ServicePrincipalName | Export-Excel GraphAppPermissionsReport.xlsx -AutoSize -TableName AppPermissionsReport