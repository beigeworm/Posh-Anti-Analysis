
<# ============================ Simple Anti Analysis ===============================

SYNOPSIS
Uses various methods to determine if the machine is a VM or if debugging or system monitoring software is running.

USAGE
1. Add Your code or execution at the END of the script below.
2. Your code will only run if the environment passes the anti-analysis test.

#>

$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host
[Console]::SetWindowSize(50, 10)
[Console]::Title = "VM Detection"

Add-Type -AssemblyName System.Windows.Forms
$isVM = $false
$isDebug = $false
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$Width = $screen.Bounds.Width
$Height = $screen.Bounds.Height
$networkAdapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.MACAddress -ne $null }
$services = Get-Service
$vmServices = @('vmtools', 'vmmouse', 'vmhgfs', 'vmci', 'VBoxService', 'VBoxSF')
$manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
$vmManufacturers = @('Microsoft Corporation', 'VMware, Inc.', 'Xen', 'innotek GmbH', 'QEMU')
$model = (Get-WmiObject Win32_ComputerSystem).Model
$vmModels = @('Virtual Machine', 'VirtualBox', 'KVM', 'Bochs')
$bios = (Get-WmiObject Win32_BIOS).Manufacturer
$vmBios = @('Phoenix Technologies LTD', 'innotek GmbH', 'Xen', 'SeaBIOS')
$runningTaskManagers = @()

Add-Type @"
        using System;
        using System.Runtime.InteropServices;

        public class DebuggerCheck {
            [DllImport("kernel32.dll")]
            public static extern bool IsDebuggerPresent();

            [DllImport("kernel32.dll", SetLastError=true)]
            public static extern bool CheckRemoteDebuggerPresent(IntPtr hProcess, ref bool isDebuggerPresent);
        }
"@

$isDebuggerPresent = [DebuggerCheck]::IsDebuggerPresent()
$isRemoteDebuggerPresent = $false
[DebuggerCheck]::CheckRemoteDebuggerPresent([System.Diagnostics.Process]::GetCurrentProcess().Handle, [ref]$isRemoteDebuggerPresent) | Out-Null

$commonResolutions = @(
    "1280x720",
    "1280x800",
    "1280x1024",
    "1366x768",
    "1440x900",
    "1600x900",
    "1680x1050",
    "1920x1080",
    "1920x1200",
    "2560x1440",
    "3840x2160"
)

$vmChecks = @{
    "VMwareTools" = "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools";
    "VMwareMouseDriver" = "C:\WINDOWS\system32\drivers\vmmouse.sys";
    "VMwareSharedFoldersDriver" = "C:\WINDOWS\system32\drivers\vmhgfs.sys";
    "SystemBiosVersion" = "HKLM:\HARDWARE\Description\System\SystemBiosVersion";
    "VBoxGuestAdditions" = "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions";
    "VideoBiosVersion" = "HKLM:\HARDWARE\Description\System\VideoBiosVersion";
    "VBoxDSDT" = "HKLM:\HARDWARE\ACPI\DSDT\VBOX__";
    "VBoxFADT" = "HKLM:\HARDWARE\ACPI\FADT\VBOX__";
    "VBoxRSDT" = "HKLM:\HARDWARE\ACPI\RSDT\VBOX__";
    "SystemBiosDate" = "HKLM:\HARDWARE\Description\System\SystemBiosDate";
}

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

$currentResolution = "$Width`x$Height"

if (!($commonResolutions -contains $currentResolution)) {$script:isVM = $true}
if ($vmManufacturers -contains $manufacturer) {$script:isVM = $true}
if ($vmModels -contains $model) {$script:isVM = $true}
if ($vmBios -contains $bios) {$script:isVM = $true}

foreach ($service in $vmServices) {
    if ($services -match $service) {$script:isVM = $true}
}

foreach ($check in $vmChecks.GetEnumerator()) {
    if (Test-Path $check.Value) {$script:isVM = $true}
}

foreach ($adapter in $networkAdapters) {
    $macAddress = $adapter.MACAddress -replace ":", ""
    if ($macAddress.StartsWith("080027")) {$script:isVM = $true}
    elseif ($macAddress.StartsWith("000569") -or $macAddress.StartsWith("000C29") -or $macAddress.StartsWith("001C14")) {$script:isVM = $true}
}

foreach ($taskManager in $taskManagers) {
    if (Get-Process -Name $taskManager -ErrorAction SilentlyContinue) {
        $runningTaskManagers += $taskManager
    }
}
if ($runningTaskManagers.Count -gt 0) {
    $script:isdebug = $true
}

if ($isDebuggerPresent -or $isRemoteDebuggerPresent) {
    $script:isdebug = $true
}

Write-Host "Environment Test.. " -NoNewline

if ($isVM) {   
    Write-Host "FAIL!" -ForegroundColor White -BackgroundColor Red
    Write-Host "The environment could be a VM." -ForegroundColor Red
    # exit

}
elseif ($isDebug) {
    Write-Host "FAIL!" -ForegroundColor White -BackgroundColor Red
    Write-Host "Debugging / Monitoring software is Running." -ForegroundColor Red
    # exit

}
else {

    # ---------------- RUN YOUR CODE HERE ---------------------------

    Write-Host "PASS" -ForegroundColor Green
 
 
 
 
 
 
 
    
    
 }
