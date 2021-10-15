$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go.exe version

cd groot-windows

ginkgo.exe -r -p -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
if ($LastExitCode -ne 0) {
    throw "Testing groot-windows returned error code: $LastExitCode"
}


Exit $exitCode
