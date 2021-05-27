$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$ephemeral_disk_temp_path="C:\var\vcap\data\tmp"
mkdir "$ephemeral_disk_temp_path" -ea 0
$env:TEMP = $env:TMP = $ephemeral_disk_temp_path

$env:WINC_BINARY = "$PWD\winc-binary\winc.exe"
$env:GROOT_BINARY = "$PWD\groot-binary\groot.exe"
$env:DIFF_EXPORTER_BINARY = "$PWD\diff-exporter-binary\diff-exporter.exe"
$env:GROOT_IMAGE_STORE = "$ephemeral_disk_temp_path\groot"

~/go/bin/ginkgo.exe -nodes $env:NODES -r -race -keepGoing -randomizeSuites src/code.cloudfoundry.org/hydrator
Exit $LastExitCode
