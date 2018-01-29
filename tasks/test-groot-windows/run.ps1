$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go.exe version

$env:GOPATH = $PWD
$env:PATH="$env:GOPATH\bin;" +$env:PATH

cd $env:GOPATH/src/code.cloudfoundry.org/groot-windows

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo.exe -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
$exitCode = $LastExitCode

Exit $exitCode
