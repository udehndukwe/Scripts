function Get-GraphAppAssignedPermissions {
    param (
        [Parameter(Mandatory)]
        [string]$AppObjectId
    )

    try {
        $servicePrincipal = Get-MgServicePrincipal -ServicePrincipalId $AppObjectId -ExpandProperty AppRoleAssignments
        $assignedPermissions = $servicePrincipal.AppRoleAssignments | ForEach-Object {
            $appRoleId = $_.AppRoleId
            $resourceId = $_.ResourceId
            $resourceSp = Get-MgServicePrincipal -ServicePrincipalId $resourceId
            $appRole = $resourceSp.AppRoles | Where-Object { $_.Id -eq $appRoleId }
            [PSCustomObject]@{
                ResourceDisplayName = $resourceSp.DisplayName
                PermissionValue     = $appRole.Value
                PermissionType      = $appRole.AllowedMemberTypes -join ','
            }
        }
        return $assignedPermissions
    }
    catch {
        Write-Output $_.Exception.Message
    }
}
