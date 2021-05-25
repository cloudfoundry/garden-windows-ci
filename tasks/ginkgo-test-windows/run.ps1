$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go.exe version

cd $env:TEST_PATH

~/go/bin/ginkgo.exe -nodes $env:NODES -r -race -keepGoing -randomizeSuites
if ($LastExitCode -ne 0) {
    throw "Testing $env:TEST_PATH returned error code: $LastExitCode"
}
