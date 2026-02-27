<#
.SYNOPSIS
    Triggers a sync of an Intune managed device.

.DESCRIPTION
    Sends the Graph API sync command for a device identified by name or serial number.

.PARAMETER DeviceName
    Names of one or more devices to sync.

.PARAMETER SerialNumber
    Serial numbers of one or more devices to sync.

.NOTES
    Author: Udeh Ndukwe
    Date: 12/18/2024
#>
function Sync-IntuneDevice {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$DeviceName,
        [string[]]$SerialNumber
    )

    begin {
        $context = Get-MgContext
        if (-not $context) {
            Connect-MgGraph
        }
        if ($DeviceName) {
            $managedDeviceId = (Get-MgDeviceManagementManagedDevice -Filter "DeviceName eq '$DeviceName'").Id
        }
        elseif ($SerialNumber) {
            $managedDeviceId = (Get-MgDeviceManagementManagedDevice -Filter "SerialNumber eq '$SerialNumber'").Id 
        }

    }

    process {
        Write-Verbose "Sending Sync command..." 
        Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $managedDeviceId 
    }
}