$Serial = Get-CimInstance -ClassName Win32_BIOS | Select-Object -ExpandProperty SerialNumber
$Prefix = "RR-"
$ComputerName = $Prefix + $Serial

Write-Output "Computer has been renamed to: $ComputerName"