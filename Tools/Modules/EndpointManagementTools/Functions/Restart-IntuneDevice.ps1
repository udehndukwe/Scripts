<#
.SYNOPSIS
    Sends a restart command to an Intune managed device.

.DESCRIPTION
    The function accepts device names or serial numbers and uses Graph API calls to trigger a reboot
    of the corresponding managed device.

.PARAMETER DeviceName
    Names of one or more devices to restart.

.PARAMETER SerialNumber
    Serial numbers of one or more devices to restart.

.NOTES
    Author: Udeh Ndukwe
    Date: 12/18/2024
#>
function Restart-IntuneDevice {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
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
            $device = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/devices?`$filter=displayName eq '$DeviceName'"
            $managedDeviceID = $device.value.id
        }
        elseif ($SerialNumber) {
            $device = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=serialNumber eq '$SerialNumber'"
            $managedDeviceID = $device.value.id
        }
    }

    process {
        $Name = $device.value.deviceName
        if ($PSCmdlet.ShouldProcess("Device: $Name", "Restart")) {
            Write-Verbose "Sending restart command..." -Verbose

            $URI = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$managedDeviceID/rebootNow"
            Invoke-MgGraphRequest -Method POST -Uri $URI -ErrorAction Stop
        }
    }
}