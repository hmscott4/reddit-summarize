function Get-ServerMetrics {
    <#
    .SYNOPSIS
        Retrieves detailed hardware and OS metrics from Windows Servers using CIM/WMI.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = "localhost",

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Agent,

        [pscredential]$Credential
    )

    process {
        foreach ($computer in $ComputerName) {
            $cimParams = @{
                ComputerName = $computer
                ErrorAction  = 'Stop'
            }
            if ($Credential) { $cimParams.Credential = $Credential }

            try {
                # 1. System, BIOS, and OS Info
                $cs = Get-CimInstance @cimParams -ClassName Win32_ComputerSystem
                $bios = Get-CimInstance @cimParams -ClassName Win32_BIOS
                $os = Get-CimInstance @cimParams -ClassName Win32_OperatingSystem

                # 2. CPU Info
                $processors = Get-CimInstance @cimParams -ClassName Win32_Processor
                $cpuSockets = $processors.Count
                $cpuCores = ($processors | Measure-Object -Property NumberOfCores -Sum).Sum
                $cpuLogical = ($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
                $cpuLoad = [math]::Round(($processors | Measure-Object -Property LoadPercentage -Average).Average, 2)

                # 3. Memory Info
                $totalMemGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
                $freeMemGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
                $usedMemPct = if ($totalMemGB -gt 0) { [math]::Round((($totalMemGB - $freeMemGB) / $totalMemGB) * 100, 1) } else { 0 }

                # 4. Disk Space (DriveType 3 = Local Disk)
                $disks = Get-CimInstance @cimParams -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID,
                @{N = 'SizeGB'; E = { [math]::Round($_.Size / 1GB, 2) } },
                @{N = 'FreeGB'; E = { [math]::Round($_.FreeSpace / 1GB, 2) } },
                @{N = 'PercentFree'; E = { [math]::Round(($_.FreeSpace / $_.Size) * 100, 1) } }

                [PSCustomObject]@{
                    ComputerName         = $computer
                    Agent                = $Agent
                    Status               = "Online"
                    Manufacturer         = $cs.Manufacturer
                    Model                = $cs.Model
                    SerialNumber         = $bios.SerialNumber
                    OS                   = $os.Caption
                    OSVersion            = $os.Version
                    CPUType              = ($processors.Name | Get-Unique) -join ", "
                    CPUSockets           = $cpuSockets
                    CPUCores             = $cpuCores
                    CPULogicalProcessors = $cpuLogical
                    CPULoadPercent       = $cpuLoad
                    MemoryTotalGB        = $totalMemGB
                    MemoryUsedPercent    = $usedMemPct
                    Disks                = $disks
                }
            }
            catch {
                Write-Error "Failed to connect to $computer : $($_.Exception.Message)"
                [PSCustomObject]@{ ComputerName = $computer; Agent = $Agent; Status = "Unreachable" }
            }
        }
    }
}