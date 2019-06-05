$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

. "$PSScriptRoot\..\shared-functions.ps1"

go.exe version

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH
$env:GOCACHE = "$env:EPHEMERAL_DISK_TEMP_PATH\go-build"

$env:GOPATH=$PWD
$binaryDir = "$PWD\winc-network-binary"

$binaryDir = updateDirIfSymlink "$binaryDir"

pushd src\code.cloudfoundry.org\winc
	go build -o "$binaryDir\winc-network.exe" -tags "hnsAcls" .\cmd\winc-network
popd
