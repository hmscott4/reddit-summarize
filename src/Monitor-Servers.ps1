# Monitor-Servers.ps1
# Entry point for the monitoring tool

# 1. Load the helper function
. "$PSScriptRoot\src\Get-ServerMetrics.ps1"

# 2. Define target servers (Load from JSON file)
$serverListFile = "$PSScriptRoot\servers.json"
if (Test-Path $serverListFile) {
    $servers = Get-Content $serverListFile -Raw | ConvertFrom-Json
}
else {
    Write-Warning "File '$serverListFile' not found. Defaulting to localhost."
    $servers = @(@{ ComputerName = "localhost"; Agent = "Default" })
}

Write-Host "Starting Server Monitor..." -ForegroundColor Cyan

# 3. Run the monitor
$results = $servers | Get-ServerMetrics

foreach ($result in $results) {
    if ($result.Status -eq 'Online') {
        $result | Select-Object -ExcludeProperty Disks, Status | Format-List
        Write-Host "Disk Information for $($result.ComputerName):" -ForegroundColor Green
        $result.Disks | Format-Table -AutoSize
    }
    else {
        $result | Format-List
    }
    Write-Host ("-" * 60)
}