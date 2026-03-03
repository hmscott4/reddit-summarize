# Monitor-Servers.ps1
# Entry point for the monitoring tool

[CmdletBinding(DefaultParameterSetName = 'FromFile')]
param(
    # Parameter for using a server list file. This is the default.
    [Parameter(ParameterSetName = 'FromFile', HelpMessage = 'Path to the JSON file containing the list of servers to monitor.')]
    [string]$ServerListFile = "$PSScriptRoot\servers.json",

    # Parameter for specifying one or more servers directly.
    [Parameter(ParameterSetName = 'Direct', Mandatory = $true, HelpMessage = 'One or more server names to monitor directly.')]
    [string[]]$ComputerName
)

# 1. Load the helper function
. "$PSScriptRoot\src\Get-ServerMetrics.ps1"

# 2. Define target servers based on parameters
$servers = @()
if ($PSCmdlet.ParameterSetName -eq 'FromFile') {
    if (Test-Path $ServerListFile) {
        try {
            $servers = Get-Content $ServerListFile -Raw | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to parse server list file '$ServerListFile': $_"
        }
    }
    else {
        Write-Warning "Server list file '$ServerListFile' not found."
    }
}
elseif ($PSCmdlet.ParameterSetName -eq 'Direct') {
    # Create server objects for direct input
    $servers = $ComputerName | ForEach-Object {
        [PSCustomObject]@{
            ComputerName = $_
            Agent        = 'DirectInput'
        }
    }
}

Write-Host "Starting Server Monitor..." -ForegroundColor Cyan

# 3. Run the monitor if servers are defined
if ($null -ne $servers -and $servers.Count -gt 0) {
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
}
else {
    Write-Host "No servers to monitor. Please check your server list file or command-line input."
}