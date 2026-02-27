# Root script for EndpointManagementTools module
# this file simply imports each function script located in the Functions subfolder.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$functionsPath = Join-Path $scriptDir 'Functions'

Get-ChildItem -Path $functionsPath -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}
