$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

. "$PSScriptRoot\..\shared-functions.ps1"

go.exe version

if ($env:PACKAGE -eq "") {
  Write-Error "Define PACKAGE env variable"
}

if ($env:BINARY_NAME -eq "") {
  Write-Error "Define BINARY_NAME env variable"
}

$binaryDir = "$PWD\binary-output"
$binaryDir = updateDirIfSymlink "$binaryDir"

cd $env:GO_MOD_PATH

go.exe build -o "$binaryDir\$env:BINARY_NAME" $env:PACKAGE
if ($LastExitCode -ne 0) {
  exit $LastExitCode
}
