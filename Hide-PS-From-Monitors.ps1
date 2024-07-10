   
<# ============================ Hide-PS-From-Monitors ===============================

SYNOPSIS
Uses various methods to determine if the machine is a VM or if debugging or system monitoring software is running.

USAGE
1. Use this line in the powershell script you want to hide:   [Console]::Title = "test-window"
2. Your powershell script will only run if the environment does not have any common monitoring software running
3. when Monitoring software is run, this script will close the named powershell script until no monitors are running.

THIS POWERSHELL WILL STILL BE RUNNING WHEN NAMED CONSOLE IS CLOSED OR OPEN

#>

$ConsoleName = 'test-window' # Name of the Console Window to hide

$testConsolePath = $null
$testConsoleProcess = $null
$pathMatch = $null

while ($true) {
    cls
    Write-Host "Monitoring Software.. " -NoNewline
    $taskManagers = @(
        "taskmgr",       
        "procmon",
        "procmon64",     
        "procexp",
        "procexp64",     
        "perfmon",
        "perfmon64",      
        "resmon",
        "resmon64",        
        "ProcessHacker"   
    )
    $runningTaskManagers = @()
    foreach ($taskManager in $taskManagers) {
        if (Get-Process -Name $taskManager -ErrorAction SilentlyContinue) {
            $runningTaskManagers += $taskManager
        }
    }

    $testConsoleProcess = Get-Process | Where-Object { $_.MainWindowTitle -eq "$ConsoleName" }

    if ($testConsoleProcess) {
        $wmiQuery = "SELECT CommandLine FROM Win32_Process WHERE ProcessId = $($testConsoleProcess.Id)"
        $wmiProcess = Get-WmiObject -Query $wmiQuery

        if(!($pathMatch)){

            if ($wmiProcess) {
                $commandLine = $wmiProcess.CommandLine
                $pathMatch = $commandLine -replace '.*&\s+''([^'']+)''.*', '$1'
                
                if ($pathMatch) {
                    $testConsolePath = $pathMatch
                }
            }

        }
    }


    # Write-Host $testConsolePath

    if ($runningTaskManagers.Count -gt 0) {
        Write-Host "Detected!" -ForegroundColor White -BackgroundColor Red
        if ($testConsoleProcess) {
            Stop-Process -Id $testConsoleProcess.Id -Force
            Write-Host "Stopped PS process" -ForegroundColor Yellow
            $detect = 1
        }
    } 
    else {
        Write-Host "OK" -ForegroundColor Green
        if (-not $testConsoleProcess -and $testConsolePath -and $detect -gt 0) {
            Start-Process PowerShell.exe -ArgumentList ("-NoP -Ep Bypass -File `"{0}`"" -f $testConsolePath)
            Write-Host "Restarted PS process" -ForegroundColor Yellow
            $detect = 0
        }
    }

    sleep 2
}
