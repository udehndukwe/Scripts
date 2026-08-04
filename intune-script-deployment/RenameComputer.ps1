[CmdletBinding()]
param()

# Enable verbose logging with the -Verbose switch when running this script.
Write-Verbose "Starting RenameComputer.ps1"

try {
    Write-Verbose "Querying BIOS for serial number (Win32_BIOS)..."
    $bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop
    $Serial = $bios | Select-Object -ExpandProperty SerialNumber
    if (-not $Serial) {
        Throw "Serial number is empty or could not be retrieved from Win32_BIOS."
    }
    Write-Verbose "Serial number retrieved: $Serial"
} catch {
    Write-Error "Failed to retrieve BIOS serial number: $_"
    exit 1
}

$Prefix = "RR-"
Write-Verbose "Using prefix: $Prefix"

$ComputerName = "$Prefix$Serial"
Write-Verbose "Constructed computer name: $ComputerName"

# For Intune script deployment we typically just output the desired name.
# If you want this script to actually rename the computer, replace the Write-Output
# with Rename-Computer -NewName $ComputerName -Force -Restart:$false (and test carefully).

Write-Output "Computer has been renamed to: $ComputerName"
Write-Verbose "RenameComputer.ps1 completed successfully"
