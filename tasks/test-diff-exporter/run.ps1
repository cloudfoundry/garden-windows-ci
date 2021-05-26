$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$ephemeral_disk_temp_path="C:\var\vcap\data\tmp"
mkdir "$ephemeral_disk_temp_path" -ea 0
$env:TEMP = $env:TMP = $ephemeral_disk_temp_path
$env:GROOT_IMAGE_STORE = "$ephemeral_disk_temp_path\groot"

go.exe version

$env:GROOT_BINARY = "$PWD\groot-binary\groot.exe"
$env:WINC_BINARY = "$PWD\winc-binary\winc.exe"

& "$env:GROOT_BINARY" --driver-store "$env:GROOT_IMAGE_STORE" pull "$env:WINC_TEST_ROOTFS"

cd diff-exporter

~/go/bin/ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
$exitCode = $LastExitCode
if ($exitCode -ne 0) {
  Exit $exitCode
}
