$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

. "$PSScriptRoot\..\shared-functions.ps1"

go.exe version

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH

$env:GOPATH=$PWD
$binaryDir = "$PWD\groot-binary"

$binaryDir = updateDirIfSymlink "$binaryDir"

pushd src\code.cloudfoundry.org\groot-windows
  go build -o "$binaryDir\groot.exe" main.go
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  gcc.exe -c ".\volume\quota\quota.c" -o "$env:TEMP\quota.o"
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  gcc.exe -shared -o "$binaryDir\quota.dll" "$env:TEMP\quota.o" -lole32 -loleaut32
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
popd
