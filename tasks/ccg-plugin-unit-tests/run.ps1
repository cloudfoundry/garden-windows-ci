filter timestamper { "$((get-date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss:fffffff00Z')): $_" }
$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

Write-Output "Installing .NET dependencies" | timestamper
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
C:\ProgramData\chocolatey\bin\choco.exe install -y netfx-4.7.2-devpack
iwr -outf dotnet-install.ps1 -Uri "https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1"
./dotnet-install.ps1

cd .\repo\src\CfCcgPlugin
Write-Output "Building the plugin for testing" | timestamper
dotnet build
$dllPath = Resolve-Path .\bin\Debug\CfCcgPlugin.dll

Write-Output "Change permissions to grant everyone access to dll" | timestamper
cmd.exe /C "icacls $dllPath /grant Everyone:(F)"

Write-Output "Create event log and register event source" | timestamper
reg.exe import .\EventLog.reg
Write-Output "Register the plugin's GUID with CCG" | timestamper
& .\RegisterPluginWithCCG.ps1

Write-Output "Register plugin with the .net framework" | timestamper
function unregisterDLLWithdotNET {
    C:\Windows\Microsoft.NET\Framework64\v4.0.30319\regsvcs.exe /u $dllPath
    C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe /u $dllPath
}
trap { unregisterDLLWithdotNET }
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\RegAsm.exe /codebase /tlb $dllPath
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\regsvcs.exe /fc $dllPath

Write-Output "Change identity of plugin to 'NT AUTHORITY\LocalService'" | timestamper
& .\ChangePluginIdentity.ps1



dotnet test
if ($LastExitCode -ne 0) {
    echo "Dotnet tests failed!!"
    Exit 1
}

unregisterDLLWithdotNET
Exit 0
