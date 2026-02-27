<#
.SYNOPSIS
    Imports a device identifier (serial number) into Intune.

.DESCRIPTION
    Uses the Graph beta API to create an importedDeviceIdentity record for a given serial number.

.PARAMETER SerialNumber
    The serial number to import.

.NOTES
    Author: Udeh Ndukwe
    Date: 12/18/2024
#>
function Import-DeviceIdentifier {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$SerialNumber
    )
    $URI = "https://graph.microsoft.com/beta/deviceManagement/importedDeviceIdentities/importDeviceIdentityList"
    
    $params = @{
        overwriteImportedDeviceIdentities = $false
        importedDeviceIdentities = @(
            @{
                importedDeviceIdentityType = "serialNumber"
                importedDeviceIdentifier = $SerialNumber
                description = $description
            }
        )
    }


    Invoke-MgGraphRequest -Method POST -Uri $URI -Body $params -ContentType application/json
}