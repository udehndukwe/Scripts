# Variables
$totalDevices = 1000
$batchSize = 20

# Connect to Microsoft Graph with required scope
# Connect-MgGraph -Scopes Device.ReadWrite.All

function Build-DeviceRequest($i) {
    $deviceId = [System.Guid]::NewGuid().ToString()
    $displayName = "DummyDevice$i"
    $accountEnabled = $true
    
    # Generate a unique alternative security ID for each device
    $uniqueSecurityKey = "DummyDevice$i-$deviceId"
    $securityKeyBytes = [System.Text.Encoding]::ASCII.GetBytes($uniqueSecurityKey)
    $securityKeyBase64 = [System.Convert]::ToBase64String($securityKeyBytes)
    
    # Mix of operating systems - cycle through them
    $osIndex = $i % 3
    switch ($osIndex) {
        0 { 
            $operatingSystem = "Windows"
            $operatingSystemVersion = "10"
        }
        1 { 
            $operatingSystem = "macOS"
            $operatingSystemVersion = "14"
        }
        2 { 
            $operatingSystem = "linux"
            $operatingSystemVersion = "22"
        }
    }
    
    return @{
        id = "req$i"
        method = "POST"
        url = "/devices"
        headers = @{ "Content-Type" = "application/json" }
        body = @{
            accountEnabled = $true
            deviceId = $deviceId
            displayName = $displayName
            operatingSystem = $operatingSystem
            operatingSystemVersion = $operatingSystemVersion
            alternativeSecurityIds = @(
                @{
                    type = 2
                    key = $securityKeyBase64
                }
            )
        }
    }
}

Write-Host "Starting creation of $totalDevices dummy devices in batches of $batchSize..." -ForegroundColor Green

for ($start = 1; $start -le $totalDevices; $start += $batchSize) {
    $batchRequests = @()
    $end = [Math]::Min($start + $batchSize - 1, $totalDevices)
    
    for ($i = $start; $i -le $end; $i++) {
        $batchRequests += (Build-DeviceRequest $i)
    }

    $batchBody = @{
        requests = $batchRequests
    } | ConvertTo-Json -Depth 10

    try {
        Write-Host "Processing batch: devices $start to $end..." -ForegroundColor Yellow
        $response = Invoke-MgGraphRequest -Method POST -Uri '/v1.0/$batch' -Body $batchBody -ContentType 'application/json'
        
        # Handle individual response statuses
        $successCount = 0
        $failureCount = 0
        
        foreach ($res in $response.responses) {
            if ($res.status -eq 201) {
                $successCount++
            } else {
                $failureCount++
                Write-Warning "Device creation failed for request $($res.id): Status $($res.status) - $($res.body.error.message)"
            }
        }
        
        Write-Host "Batch completed - Success: $successCount, Failures: $failureCount" -ForegroundColor Green
        
        # Add a small delay between batches to avoid throttling
        Start-Sleep -Milliseconds 500
    }
    catch {
        Write-Error "Batch starting at device $start failed: $_"
        
        # If we hit rate limiting, wait longer before retrying
        if ($_.Exception.Message -like "*throttled*" -or $_.Exception.Message -like "*429*") {
            Write-Host "Rate limiting detected. Waiting 30 seconds before continuing..." -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
}

Write-Host "Device creation process completed!" -ForegroundColor Green

# Uncomment to disconnect when done
# Disconnect-MgGraph
