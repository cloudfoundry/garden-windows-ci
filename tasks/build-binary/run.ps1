$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

. "$PSScriptRoot\..\shared-functions.ps1"

$env:PATH = "$env:GOPATH\bin;" + $env:PATH

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH

go.exe version

if ($env:PACKAGE -eq "") {
  Write-Error "Define PACKAGE env variable"
}

if ($env:IMPORT_PATH -ne "") {
  if (!$env:IMPORT_PATH.StartsWith("src")) {
    $env:IMPORT_PATH = (Join-Path "src" $env:IMPORT_PATH)
  }
  New-Item -Type Directory -Force -Path $env:IMPORT_PATH
  Copy-Item -Recurse -Force repo/* "$env:IMPORT_PATH"
  $env:GOPATH=$PWD
  $env:PACKAGE = (Resolve-Path (Join-Path $env:IMPORT_PATH $env:PACKAGE) -Relative)
} else {
  $env:GOPATH=(Resolve-Path "repo").Path
  $env:PACKAGE = (Resolve-Path (Join-Path $env:GOPATH $env:PACKAGE) -Relative)
}

if ($env:BINARY_NAME -ne "") {
  $BINARY=$env:BINARY_NAME
} else {
  $BINARY=(Get-Item $env:PACKAGE).BaseName + ".exe"
}

$binaryDir = "$PWD\binary-output"

$binaryDir = updateDirIfSymlink "$binaryDir"

go.exe build -o "$binaryDir\$BINARY" $env:PACKAGE
if ($LastExitCode -ne 0) {
  exit $LastExitCode
}
