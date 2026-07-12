[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory)]
    [string]$scriptName,

    [bool]$enforceSigCheck = $false,
    [bool]$runAs32Bit = $false,
    [string]$runAsAccount = "system",
    [string]$description = "",
    [string[]]$roleScopeTagIds = @("0")
)

# --- Validate input file ---
if (-not (Test-Path -Path $Path -PathType Leaf)) {
    throw "Script file not found at path: $Path"
}

# --- Read and encode script content ---
$bytes = [System.IO.File]::ReadAllBytes($Path)
$base64 = [Convert]::ToBase64String($bytes)

$params = @{
    "displayName"           = $scriptName
    "description"           = $description
    "scriptContent"         = $base64
    "runAsAccount"          = $runAsAccount
    "fileName"              = "$scriptName.ps1"
    "roleScopeTagIds"       = $roleScopeTagIds
    "enforceSignatureCheck" = $enforceSigCheck
    "runAs32Bit"            = $runAs32Bit
}

$baseUri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts"

# --- Check for existing script by displayName ---
# NOTE: Graph filtering on displayName requires exact match; escape single quotes
# in scriptName to avoid breaking the OData filter syntax.
$escapedName = $scriptName -replace "'", "''"
$filterUri = "$baseUri`?`$filter=displayName eq '$escapedName'"

try {
    $existing = Invoke-MgGraphRequest -Method GET -Uri $filterUri
}
catch {
    Write-Error "Failed to query existing scripts for '$scriptName': $($_.Exception.Message)"
    throw
}

if ($existing.value.Count -gt 1) {
    # Guard against ambiguous matches rather than silently picking one
    throw "Multiple existing scripts found with displayName '$scriptName'. Resolve duplicates manually before running this deployment."
}

if ($existing.value.Count -eq 1) {
    $scriptId = $existing.value[0].id
    Write-Output "Existing script found ('$scriptName', id: $scriptId). Updating..."

    try {
        # PATCH does not require displayName to be resent but including it is harmless
        Invoke-MgGraphRequest -Method PATCH `
            -Uri "$baseUri/$scriptId" `
            -Body ($params | ConvertTo-Json -Depth 10) `
            -ContentType "application/json"

        Write-Output "Successfully updated script '$scriptName' (id: $scriptId)"
        Write-Output "::notice::Updated Intune script '$scriptName' (id: $scriptId)"
    }
    catch {
        Write-Error "Failed to update script '$scriptName' (id: $scriptId): $($_.Exception.Message)"
        throw
}
else {
    Write-Output "No existing script found for '$scriptName'. Creating new script..."

    try {
        $response = Invoke-MgGraphRequest -Method POST `
            -Uri $baseUri `
            -Body ($params | ConvertTo-Json -Depth 10) `
            -ContentType "application/json"

        Write-Output "Successfully created script '$scriptName' (id: $($response.id))"
        Write-Output "::notice::Created Intune script '$scriptName' (id: $($response.id))"
    }
    catch {
        Write-Error "Failed to create script '$scriptName': $($_.Exception.Message)"
        throw
    }
}