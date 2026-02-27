<#
.SYNOPSIS
    Assigns an Intune application to a user or device group.

.DESCRIPTION
    The New-IntuneAppAssignment function simplifies creation of app assignment objects for Intune applications.  It
    supports the special built-in groups "All users" and "All devices" as well as supplying a custom group name.

.PARAMETER GroupName
    The name of the group to assign the application to.  Valid values are "All users", "All devices", or a specific
    Azure AD group display name.

.PARAMETER Intent
    The assignment intent.  Valid values are "required" or "available".

.PARAMETER AppID
    The application ID of the Intune application to assign.

.NOTES
    Author: Udeh Ndukwe
    Date: 12/18/2024
#>
function New-IntuneAppAssignment {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter()]
        [ValidateSet("All users", "All devices")]
        [string]$GroupName,
        [ValidateSet("required", "available")]
        [string]$Intent,
        [string]$AppID
    )
    BEGIN {
        if ($GroupName -eq "All users") {
            $target = @{
                "@odata.type" = "microsoft.graph.groupAssignmentTarget"    
                "groupId"     = "acacacac-9df4-4c7d-9d50-4ef0226f57a9"
            }
        }
        elseif ($GroupName -eq "All devices") {
            $target = @{
                "@odata.type" = "microsoft.graph.groupAssignmentTarget"
                "groupId"     = "adadadad-808e-44e2-905a-0b7873a8a531"
            }
        }
        else {
            $group = Get-MgGroup -Filter "DisplayName eq '$GroupName'"
            $target = @{
                "@odata.type" = "microsoft.graph.groupAssignmentTarget"    
                "groupId"     = $group.Id
            }
        }
    }
    PROCESS {
        if ($PSCmdlet.ShouldProcess("AppID: $AppID", "Assign app to group: $GroupName with intent: $Intent")) {
            try {
                New-MgDeviceAppManagementMobileAppAssignment -MobileAppId $AppID -Intent $Intent -Target $target -ErrorAction Stop
            }
            catch {
                $_.Exception.Message
            }
        }
    }
}