[CmdletBinding()]
param (
    [Parameter()]
    [string]$Path,
    [string]$scriptName,
    [string]$enforceSigCheck = $false,
    [string]$runAs32Bit = $false,
    [string]$runAsAccount = "system",
    [string]$description = ""
)


$bytes = [System.IO.File]::ReadAllBytes($Path)
$base64 = [Convert]::ToBase64String($bytes)

$params = @{
	"displayName" = $scriptName
	"description" = $description
	"scriptContent" = "$base64"
	"runAsAccount" = $runAsAccount
	"fileName" = "$content.ps1"
	"roleScopeTagIds" = @(
		"0"
	)
	"enforceSignatureCheck" = $enforceSigCheck
	"runAs32Bit" = $runAs32Bit
}

Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts" -Body ($params | ConvertTo-Json -Depth 10) -ContentType "application/json"