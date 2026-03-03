# Windows Server Monitor

A PowerShell-based tool to monitor the health and performance of Windows Servers using WMI/CIM.

## Features
- **System Information**: Manufacturer, Model, and Serial Number.
- **Operating System**: OS Name, Edition, and Version.
- **CPU Details**: Processor type, socket count, core count, logical processor count, and average load.
- **Memory Usage**: Total memory and percentage used.
- **Disk Usage**: Free space and size for all logical drives.

## Usage

The main entry point is `Monitor-Servers.ps1`.

```powershell
.\Monitor-Servers.ps1
```

The script `src\Get-ServerMetrics.ps1` contains the core function and can be used directly in other scripts after being imported:

```powershell
. .\src\Get-ServerMetrics.ps1
Get-ServerMetrics -ComputerName "Server01", "Server02"
```

## Requirements
- PowerShell 5.1 or PowerShell 7+
- WinRM enabled on target servers