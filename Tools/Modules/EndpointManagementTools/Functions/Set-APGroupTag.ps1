<#
.SYNOPSIS
    Updates the group tag on a Windows Autopilot device.

.DESCRIPTION
    The Set-APGroupTag function looks up an Autopilot device by serial number and sets its GroupTag property
    via Microsoft Graph.

.PARAMETER SerialNumber
    One or more Autopilot device serial numbers (mandatory).

.PARAMETER GroupTag
    The new group tag value to apply.

.NOTES
    Author: Udeh Ndukwe
    Date: 12/18/2024
#>
function Set-APGroupTag {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$SerialNumber,
        [string]$GroupTag
    )
    BEGIN {
        $context = Get-MgContext
        if (-not $context) {
            Connect-MgGraph
        }
        if (-not $apDevices) {
            $apDevices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All
        }
    }

    PROCESS {
        $HashID = $apDevices.Where({ $_.SerialNumber -eq $SerialNumber }).ID
        if ($PSCmdlet.ShouldProcess("Device with Serial Number $SerialNumber", "Update Group Tag to $GroupTag")) {
            try {
                Update-MgDeviceManagementWindowsAutopilotDeviceIdentityDeviceProperty -WindowsAutopilotDeviceIdentityId $HashID -GroupTag $GroupTag -ErrorAction Stop
                Write-Verbose -Message "Group Tag successfully updated. Allow 5-10 minutes for changes to reflect" 
            }
            catch {
                Write-Error -Message $_.Exception.Message
            }
        }
    }
}