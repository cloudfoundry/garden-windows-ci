$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$ephemeral_disk_temp_path="C:\var\vcap\data\tmp"
mkdir "$ephemeral_disk_temp_path" -ea 0
$env:TEMP = $env:TMP = $ephemeral_disk_temp_path

go.exe version

cd $env:TEST_PATH

~/go/bin/ginkgo.exe -r -p -race -keepGoing -randomizeSuites
if ($LastExitCode -ne 0) {
    throw "Testing $env:TEST_PATH returned error code: $LastExitCode"
}
