<#
.SYNOPSIS
Assigns Microsoft Graph application permissions to a specified service principal.

.DESCRIPTION
The Add-GraphAppPermissions function assigns one or more Microsoft Graph application permissions to a service principal in Azure AD. It locates the Microsoft Graph service principal, finds the specified app roles (permissions), and creates app role assignments for the target principal.

.PARAMETER principalID
The object ID of the service principal to which permissions will be assigned.

.PARAMETER permissionList
A list of Microsoft Graph permission values (AppRole values) to assign. Each item should match the 'Value' property of an AppRole in the Microsoft Graph service principal.

.PARAMETER AppDisplayName
The display name of the application (service principal) to which permissions are being assigned. (Note: This parameter is not used in the function logic.)

.EXAMPLE
$permissions = @("User.Read.All", "Group.Read.All")
Add-GraphAppPermissions -principalID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -permissionList $permissions -AppDisplayName "MyApp"

.NOTES
Requires Microsoft Graph PowerShell SDK and appropriate permissions to assign app roles.
#>
function Add-GraphAppPermissions {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$principalID,
        [object]$permissionList,
        [string]$AppDisplayName
    )

    try {
        $graphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"
    }
    catch {
        Write-Output $_.Exception.Message
        return
    }

    foreach ($permission in $permissionList) {
        $appRole = $graphServicePrincipal.AppRoles | Where-Object { $_.Value -eq $permission -and $_.AllowedMemberTypes -contains 'Application' }

        if ($appRole -and $principalID) {
            New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $principalID `
                -PrincipalId $principalID `
                -ResourceId $graphServicePrincipal.Id `
                -AppRoleId $appRole.Id
        }
    }
}
