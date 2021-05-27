$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

. "$PSScriptRoot\..\shared-functions.ps1"

go.exe version

$binaryDir = "$PWD\winc-network-binary"
$binaryDir = updateDirIfSymlink "$binaryDir"

cd winc

go.exe build -o "$binaryDir\winc-network.exe" -tags "hnsAcls" .\cmd\winc-network
if ($LastExitCode -ne 0) {
	exit $LastExitCode
}
