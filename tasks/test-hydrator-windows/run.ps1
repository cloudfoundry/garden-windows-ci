$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH=$PWD

go get github.com/onsi/ginkgo/ginkgo

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:GOTMPDIR = $env:EPHEMERAL_DISK_TEMP_PATH

$env:WINC_BINARY = "$PWD\winc-binary\winc.exe"
$env:GROOT_BINARY = "$PWD\groot-binary\groot.exe"
$env:DIFF_EXPORTER_BINARY = "$PWD\diff-exporter-binary\diff-exporter.exe"
$env:GROOT_IMAGE_STORE="$env:EPHEMERAL_DISK_TEMP_PATH\groot-hydrator-tests"

& "$env:GOPATH/bin/ginkgo.exe" -nodes $env:NODES -r -race -keepGoing -randomizeSuites src/code.cloudfoundry.org/hydrator
Exit $LastExitCode
