$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

mkdir "$env:EPHEMERAL_DISK_TEMP_PATH" -ea 0
$env:TEMP = $env:TMP = $env:EPHEMERAL_DISK_TEMP_PATH

go.exe version

cd $env:TEST_PATH

~/go/bin/ginkgo.exe -r -p -race -keepGoing -randomizeSuites
if ($LastExitCode -ne 0) {
    throw "Testing $env:TEST_PATH returned error code: $LastExitCode"
}
