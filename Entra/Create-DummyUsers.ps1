# Variables
$tenantDomain = "relrepairs.com"
$totalUsers = 1000
$batchSize = 20
$password = "Pass@word1"

# Connect to Microsoft Graph with required scope
#Connect-MgGraph -Scopes User.ReadWrite.All

function Build-UserRequest($i) {
    $userPrincipalName = "dummy_user$i@$tenantDomain"
    $displayName = "Dummy User $i"
    $mailNickname = "dummyuser$i"

    return @{
        id = "req$i"
        method = "POST"
        url = "/users"
        headers = @{ "Content-Type" = "application/json" }
        body = @{
            accountEnabled = $true
            displayName = $displayName
            mailNickname = $mailNickname
            userPrincipalName = $userPrincipalName
            passwordProfile = @{
                forceChangePasswordNextSignIn = $false
                password = $password
            }
            usageLocation = "US"
        }
    }
}

for ($start = 1; $start -le $totalUsers; $start += $batchSize) {
    $batchRequests = @()
    for ($i = $start; $i -lt $start + $batchSize -and $i -le $totalUsers; $i++) {
        $batchRequests += (Build-UserRequest $i)
    }

    $batchBody = @{
        requests = $batchRequests
    } | ConvertTo-Json -Depth 10

    try {
        # Fixed batch URI here
        $response = Invoke-MgGraphRequest -Method POST -Uri '/v1.0/$batch' -Body $batchBody -ContentType 'application/json'
        Write-Host "Created users $start to $(($start + $batchSize - 1))"
        
        # Optional: handle individual response statuses
        # foreach ($res in $response.responses) {
        #     if ($res.status -ne 201) {
        #         Write-Warning "User creation failed for request $($res.id): $($res.body.error.message)"
        #     }
        # }
    }
    catch {
        Write-Warning "Batch starting at user $start failed: $_"
    }
}

#Disconnect-MgGraph
