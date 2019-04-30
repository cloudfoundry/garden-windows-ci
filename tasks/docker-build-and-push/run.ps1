$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"

function Run-Docker {
  param([String[]] $cmd)

  docker @cmd
  if ($LASTEXITCODE -ne 0) {
    Exit $LASTEXITCODE
  }
}

restart-service docker

$version=(cat version/number)

mkdir buildDir
cp $env:DOCKERFILE buildDir\Dockerfile
cp git-setup\Git-*-64-bit.exe buildDir\
cp tar\tar-*.exe buildDir\

# download.microsoft.com requires TLS 1.0 (it is disabled by default in the stemcell).
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Value 1 -Name 'Enabled' -Type DWORD
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Value 0 -Name 'DisabledByDefault' -Type DWORD
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Value 1 -Name 'Enabled' -Type DWORD
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Value 0 -Name 'DisabledByDefault' -Type DWORD

curl -UseBasicParsing -Outfile buildDir\rewrite.msi -Uri "https://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi"
curl -UseBasicParsing -Outfile buildDir\vc_redist.x64.exe -Uri "https://aka.ms/vs/15/release/vc_redist.x64.exe"
cd buildDir

Run-Docker "--version"
Run-Docker "build", "-t", "$env:IMAGE_NAME", "-t", "${env:IMAGE_NAME}:$version", "-t", "${env:IMAGE_NAME}:${env:OS_VERSION}", "--pull", "."
Run-Docker "images", "-a"
Run-Docker "login", "-u", "$env:DOCKER_USERNAME", "-p", "$env:DOCKER_PASSWORD"
Run-Docker "push", "${env:IMAGE_NAME}:latest"
Run-Docker "push", "${env:IMAGE_NAME}:$version"
Run-Docker "push", "${env:IMAGE_NAME}:${env:OS_VERSION}"
