$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go.exe version

cd $env:TEST_PATH

Write-Host "Installing Ginkgo"
go.exe get -u github.com/onsi/ginkgo/ginkgo
go.exe get -u github.com/onsi/gomega/...
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

~/go/bin/ginkgo.exe -nodes $env:NODES -r -race -keepGoing -randomizeSuites
if ($LastExitCode -ne 0) {
    throw "Testing $env:TEST_PATH returned error code: $LastExitCode"
}


Exit $exitCode
