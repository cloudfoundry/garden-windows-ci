$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Run-Docker {
  param([String[]] $cmd)

  docker @cmd
  if ($LASTEXITCODE -ne 0) {
    Exit $LASTEXITCODE
  }
}

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"
$env:USERPROFILE = "$env:EPHEMERAL_DISK_TEMP_PATH"

restart-service docker

$version=(cat image-version/version)
Run-Docker "--version"

# output systeminfo including hotfixes for documentation
Run-Docker "run", "${env:IMAGE_NAME}:$version", "cmd", "/c", "systeminfo" | Out-File -FilePath C:\notes\notes -append
Run-Docker "run", "${env:IMAGE_NAME}:$version", "powershell", "(get-childitem C:\Windows\System32\msvcr100.dll).VersionInfo | Select-Object -Property FileDescription,ProductVersion"| Out-File -FilePath C:\notes\notes -append
Run-Docker "run", "${env:IMAGE_NAME}:$version", "powershell", "(get-childitem C:\Windows\System32\vcruntime140.dll).VersionInfo | Select-Object -Property FileDescription,ProductVersion" | Out-File -FilePath C:\notes\notes -append

