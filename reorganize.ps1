# Reorganize repository content into clean structure
if (Test-Path .\Scripts) {
    Move-Item .\Scripts\* .\ -Force
    Remove-Item -Recurse -Force .\Scripts
}

# Create category directories
New-Item -ItemType Directory -Path General,Examples -Force | Out-Null

# Move miscellaneous utilities into General
$generalFiles = @('Format-Json.ps1','installPPPCUtility.sh','remediateRRADMIN.ps1','Remove-Win32Hash.ps1')
foreach ($f in $generalFiles) {
    if (Test-Path $f) { Move-Item -Path $f -Destination .\General -Force }
}

# Move Intune-related scripts into Intune folder
if (Test-Path .\Sync-IntuneDevice.ps1) { Move-Item .\Sync-IntuneDevice.ps1 .\Intune -Force }
if (Test-Path .\userToDeviceGroup.ps1) { Move-Item .\userToDeviceGroup.ps1 .\Intune -Force }

# Move Entra-specific script into Entra folder
if (Test-Path .\NewEntraDynamicGroup.ps1) { Move-Item .\NewEntraDynamicGroup.ps1 .\Entra -Force }

# Move JSON samples into Examples
if (Test-Path .\DeviceTaggingLogicApp.json) { Move-Item .\DeviceTaggingLogicApp.json .\Examples -Force }

# Move Intune app utilities into Tools
Get-ChildItem Get-IntuneApp*.ps1 -ErrorAction SilentlyContinue | ForEach-Object {
    Move-Item -Path $_.FullName -Destination .\Tools -Force
}
